// Studlok — AI quiz generation edge function.
//
// Takes a course_material_id, pulls that file from Storage, and asks Claude
// to turn it into a multiple-choice quiz. Runs entirely with the CALLER'S
// own forwarded JWT (not the service-role key) — every DB/Storage call below
// is scoped by Row Level Security exactly as if the user made it directly,
// so a bug here can't leak another user's data. The only secret this
// function needs is ANTHROPIC_API_KEY.
//
// Deploy: paste this into Supabase Dashboard → Edge Functions → New function
// (name it "generate-quiz"), or `supabase functions deploy generate-quiz`.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const DAILY_GENERATION_CAP = 5;
const MIN_QUESTIONS = 10;
const MAX_QUESTIONS = 15;
const ANTHROPIC_MODEL = "claude-sonnet-5";

interface Question {
  question: string;
  options: string[];
  correct_index: number;
}

type GenerationResult =
  | { ok: true; questions: Question[] }
  | { ok: false; reason: "unreadable" | "invalid" };

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return jsonError("Use POST.", 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonError("Missing Authorization header.", 401);
    }

    // Scoped to the caller: every query below runs as this user, under RLS.
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return jsonError("Invalid or expired session.", 401);
    }
    const userId = userData.user.id;

    const body = await req.json().catch(() => ({}));
    const courseMaterialId = body?.course_material_id;
    if (typeof courseMaterialId !== "string" || courseMaterialId.length === 0) {
      return jsonError("course_material_id is required.", 400);
    }

    // --- 1. Rate limit, BEFORE calling the LLM. -----------------------------
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const { count, error: countError } = await supabase
      .from("generated_quizzes")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", since);

    if (countError) {
      console.error("rate limit check failed", countError);
      return jsonError("Couldn't check your daily limit. Try again.", 500);
    }
    if ((count ?? 0) >= DAILY_GENERATION_CAP) {
      return jsonError(
        `You've hit today's limit of ${DAILY_GENERATION_CAP} quiz generations. Try again tomorrow.`,
        429,
      );
    }

    // --- 2. Look up the material and pull its file from Storage. -----------
    const { data: material, error: materialError } = await supabase
      .from("course_materials")
      .select("id, storage_path")
      .eq("id", courseMaterialId)
      .maybeSingle();

    if (materialError || !material) {
      return jsonError("Course material not found.", 404);
    }

    const { data: fileBlob, error: downloadError } = await supabase.storage
      .from("course-materials")
      .download(material.storage_path);

    if (downloadError || !fileBlob) {
      console.error("storage download failed", downloadError);
      return jsonError("Couldn't read the uploaded file. Try re-uploading it.", 404);
    }
    if (fileBlob.size === 0) {
      return jsonError("That file appears to be empty.", 400);
    }

    const mimeType = fileBlob.type || guessMimeFromPath(material.storage_path);
    const base64 = encodeBase64(new Uint8Array(await fileBlob.arrayBuffer()));

    // --- 3. Ask Claude, one retry on a bad shape. ---------------------------
    let result = await generateQuestions(base64, mimeType, false);
    if (!result.ok && result.reason === "invalid") {
      // Only retry a malformed response — retrying a genuine "unreadable"
      // verdict just burns another API call for the same answer.
      result = await generateQuestions(base64, mimeType, true);
    }

    if (!result.ok) {
      const message = result.reason === "unreadable"
        ? "Couldn't make out enough from that file to build a quiz. Try a clearer photo or a different file."
        : "Couldn't generate a clean quiz from that file. Try again in a moment.";
      return jsonError(message, 422);
    }

    // --- 4. Save. ------------------------------------------------------------
    const { data: inserted, error: insertError } = await supabase
      .from("generated_quizzes")
      .insert({ user_id: userId, course_material_id: material.id, questions: result.questions })
      .select()
      .single();

    if (insertError) {
      console.error("insert failed", insertError);
      return jsonError("Generated the quiz but couldn't save it. Try again.", 500);
    }

    return new Response(JSON.stringify(inserted), {
      status: 200,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("unhandled error", e);
    return jsonError("Something went wrong generating your quiz.", 500);
  }
});

// Sent to Claude as a forced tool call rather than free-text JSON — this
// rules out the usual failure modes (markdown fences, stray commentary
// around the JSON) at the source instead of trying to strip them out after.
const SUBMIT_QUIZ_TOOL = {
  name: "submit_quiz",
  description: "Submit the generated multiple-choice quiz, or report that the file couldn't be used.",
  input_schema: {
    type: "object",
    properties: {
      unreadable: {
        type: "boolean",
        description:
          "True only if the file's content could not be read, or is too sparse/unrelated to build a meaningful quiz from. When true, omit questions.",
      },
      questions: {
        type: "array",
        minItems: MIN_QUESTIONS,
        maxItems: MAX_QUESTIONS,
        items: {
          type: "object",
          properties: {
            question: { type: "string" },
            options: {
              type: "array",
              items: { type: "string" },
              minItems: 4,
              maxItems: 4,
            },
            correct_index: { type: "integer", minimum: 0, maximum: 3 },
          },
          required: ["question", "options", "correct_index"],
        },
      },
    },
    required: [],
  },
};

async function generateQuestions(
  base64: string,
  mimeType: string,
  strict: boolean,
): Promise<GenerationResult> {
  const isPdf = mimeType === "application/pdf";
  const fileBlock = isPdf
    ? { type: "document", source: { type: "base64", media_type: "application/pdf", data: base64 } }
    : { type: "image", source: { type: "base64", media_type: mimeType, data: base64 } };

  const instructions = `Read the attached course notes and generate between ${MIN_QUESTIONS} and ${MAX_QUESTIONS} multiple-choice questions that test understanding of the material.

Rules:
- Exactly 4 options per question, each non-empty and distinct from the others.
- correct_index must point at the genuinely correct option (0-3).
- Base every question strictly on the content of the attached file — do not invent facts not present in it.
- If the file's content is unreadable, blank, or too sparse/unrelated to write ${MIN_QUESTIONS} real questions from, call the tool with unreadable set to true instead of guessing.${
    strict
      ? "\n\nYour previous attempt did not follow these rules exactly — double check the question count, that all 4 options in every question are unique and non-empty, and that every correct_index is a valid integer 0-3 before submitting."
      : ""
  }`;

  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": Deno.env.get("ANTHROPIC_API_KEY")!,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: ANTHROPIC_MODEL,
      max_tokens: 8192,
      tools: [SUBMIT_QUIZ_TOOL],
      tool_choice: { type: "tool", name: "submit_quiz" },
      messages: [{ role: "user", content: [fileBlock, { type: "text", text: instructions }] }],
    }),
  });

  if (!res.ok) {
    console.error("Anthropic API error", res.status, await res.text());
    return { ok: false, reason: "invalid" };
  }

  const data = await res.json();
  const toolUse = data?.content?.find((block: { type: string }) => block.type === "tool_use");
  if (!toolUse) {
    return { ok: false, reason: "invalid" };
  }

  return validateToolInput(toolUse.input);
}

function validateToolInput(input: unknown): GenerationResult {
  if (typeof input !== "object" || input === null) return { ok: false, reason: "invalid" };
  const { unreadable, questions } = input as Record<string, unknown>;

  if (unreadable === true) return { ok: false, reason: "unreadable" };

  if (!Array.isArray(questions) || questions.length < MIN_QUESTIONS || questions.length > MAX_QUESTIONS) {
    return { ok: false, reason: "invalid" };
  }

  const cleaned: Question[] = [];
  for (const item of questions) {
    if (typeof item !== "object" || item === null) return { ok: false, reason: "invalid" };
    const { question, options, correct_index } = item as Record<string, unknown>;

    if (typeof question !== "string" || question.trim().length === 0) {
      return { ok: false, reason: "invalid" };
    }
    if (!Array.isArray(options) || options.length !== 4) {
      return { ok: false, reason: "invalid" };
    }

    const cleanOptions = options.map((o) => (typeof o === "string" ? o.trim() : ""));
    if (cleanOptions.some((o) => o.length === 0) || new Set(cleanOptions).size !== 4) {
      return { ok: false, reason: "invalid" };
    }
    if (!Number.isInteger(correct_index) || (correct_index as number) < 0 || (correct_index as number) > 3) {
      return { ok: false, reason: "invalid" };
    }

    cleaned.push({ question: question.trim(), options: cleanOptions, correct_index: correct_index as number });
  }

  return { ok: true, questions: cleaned };
}

function guessMimeFromPath(path: string): string {
  const lower = path.toLowerCase();
  if (lower.endsWith(".pdf")) return "application/pdf";
  if (lower.endsWith(".png")) return "image/png";
  if (lower.endsWith(".heic")) return "image/heic";
  return "image/jpeg";
}

function jsonError(message: string, status: number): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}
