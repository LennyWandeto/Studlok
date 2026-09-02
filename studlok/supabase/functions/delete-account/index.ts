// Studlok — delete-account edge function.
//
// Permanently deletes the caller's account: their uploaded course-material
// files in Storage, then the auth.users row itself (which cascades to
// course_materials / generated_quizzes / quiz_attempts via the `on delete
// cascade` foreign keys in schema.sql — no need to delete those rows here).
//
// Storage cleanup happens BEFORE the auth user is deleted, deliberately:
// once the auth user is gone, nobody's auth.uid() matches that folder
// anymore, so the "delete own objects" RLS policy could never reach those
// files again except via the service-role key — better to clean them up
// while the caller's own identity can still do it under RLS.
//
// Unlike generate-quiz, this needs SUPABASE_SERVICE_ROLE_KEY for one call
// (auth.admin.deleteUser is admin-only, no RLS-scoped equivalent exists) —
// no manual setup needed, Supabase injects that secret into every deployed
// function automatically, same as SUPABASE_URL/SUPABASE_ANON_KEY.
//
// Deploy: paste this into Supabase Dashboard → Edge Functions → New function
// (name it "delete-account"), or `supabase functions deploy delete-account`.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

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

    // Scoped to the caller — identifies who's asking, and (for the Storage
    // cleanup below) can only ever touch that caller's own files under RLS.
    const userClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user) {
      return jsonError("Invalid or expired session.", 401);
    }
    const userId = userData.user.id;

    // --- 1. Delete their Storage files, while their own identity still can.
    const { data: files, error: listError } = await userClient.storage
      .from("course-materials")
      .list(userId);

    if (listError) {
      console.error("storage list failed", listError);
      return jsonError("Couldn't clean up your files. Try again.", 500);
    }

    if (files && files.length > 0) {
      const paths = files.map((f) => `${userId}/${f.name}`);
      const { error: removeError } = await userClient.storage
        .from("course-materials")
        .remove(paths);
      if (removeError) {
        console.error("storage remove failed", removeError);
        return jsonError("Couldn't clean up your files. Try again.", 500);
      }
    }

    // --- 2. Delete the auth user. The one call here that isn't scoped to
    // the caller's own RLS — deleting an auth.users row is admin-only, with
    // no user-facing equivalent. Cascades every table in schema.sql.
    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { error: deleteError } = await adminClient.auth.admin.deleteUser(userId);
    if (deleteError) {
      console.error("delete user failed", deleteError);
      return jsonError("Couldn't delete your account. Try again.", 500);
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("unhandled error", e);
    return jsonError("Something went wrong deleting your account.", 500);
  }
});

function jsonError(message: string, status: number): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}
