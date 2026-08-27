-- Studlok — AI quiz feature schema
-- Run this once in Supabase Dashboard → SQL Editor → Run.
--
-- Three tables, each scoped to auth.uid() via RLS so a user can only ever
-- see or touch their own rows. Cascading deletes: deleting a course
-- material takes its generated quizzes with it, and deleting a quiz takes
-- its attempt history with it.

create table if not exists public.course_materials (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  uploaded_at timestamptz not null default now(),
  storage_path text not null
);

create table if not exists public.generated_quizzes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  course_material_id uuid not null references public.course_materials (id) on delete cascade,
  created_at timestamptz not null default now(),
  -- Array of {question, options: [4 strings], correct_index: 0-3}
  questions jsonb not null
);

create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  quiz_id uuid not null references public.generated_quizzes (id) on delete cascade,
  correct_count integer not null,
  total_count integer not null,
  completed_at timestamptz not null default now()
);

-- Indexes: RLS filters every query on user_id, and both FKs get joined on
-- often (e.g. "all quizzes for this material", "all attempts for this quiz").
create index if not exists course_materials_user_id_idx on public.course_materials (user_id);
create index if not exists generated_quizzes_user_id_idx on public.generated_quizzes (user_id);
create index if not exists generated_quizzes_course_material_id_idx on public.generated_quizzes (course_material_id);
create index if not exists quiz_attempts_user_id_idx on public.quiz_attempts (user_id);
create index if not exists quiz_attempts_quiz_id_idx on public.quiz_attempts (quiz_id);

-- Row Level Security: every table, every operation, always scoped to the
-- caller's own rows. Nothing here trusts user_id from the client — insert
-- policies re-check it against auth.uid(), so a forged user_id in the
-- payload is simply rejected rather than silently written under someone
-- else's id.
alter table public.course_materials enable row level security;
alter table public.generated_quizzes enable row level security;
alter table public.quiz_attempts enable row level security;

create policy "select own course_materials" on public.course_materials
  for select using (auth.uid() = user_id);
create policy "insert own course_materials" on public.course_materials
  for insert with check (auth.uid() = user_id);
create policy "update own course_materials" on public.course_materials
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own course_materials" on public.course_materials
  for delete using (auth.uid() = user_id);

create policy "select own generated_quizzes" on public.generated_quizzes
  for select using (auth.uid() = user_id);
create policy "insert own generated_quizzes" on public.generated_quizzes
  for insert with check (auth.uid() = user_id);
create policy "update own generated_quizzes" on public.generated_quizzes
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own generated_quizzes" on public.generated_quizzes
  for delete using (auth.uid() = user_id);

create policy "select own quiz_attempts" on public.quiz_attempts
  for select using (auth.uid() = user_id);
create policy "insert own quiz_attempts" on public.quiz_attempts
  for insert with check (auth.uid() = user_id);
create policy "update own quiz_attempts" on public.quiz_attempts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own quiz_attempts" on public.quiz_attempts
  for delete using (auth.uid() = user_id);
