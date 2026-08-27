-- Studlok — course material storage bucket
-- Run this once in Supabase Dashboard → SQL Editor → Run (after schema.sql).
--
-- Private bucket for uploaded note files (images or PDFs). Objects are
-- stored under a path of "<user_id>/<filename>" — RLS below enforces that
-- a user can only read/write/delete objects under their own folder prefix.
-- The AI-generation edge function (next task) reads files with the
-- service-role key, which bypasses RLS entirely, so no signed URLs or
-- extra client-facing policy is needed for that path.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'course-materials',
  'course-materials',
  false,
  20971520, -- 20 MB
  array['application/pdf', 'image/jpeg', 'image/png', 'image/heic']
)
on conflict (id) do update set
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "select own course-materials objects" on storage.objects
  for select using (
    bucket_id = 'course-materials'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "insert own course-materials objects" on storage.objects
  for insert with check (
    bucket_id = 'course-materials'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "update own course-materials objects" on storage.objects
  for update using (
    bucket_id = 'course-materials'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "delete own course-materials objects" on storage.objects
  for delete using (
    bucket_id = 'course-materials'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
