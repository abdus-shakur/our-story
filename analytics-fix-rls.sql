-- ============================================================
--  FIX: "new row violates row-level security policy" (code 42501)
--  Run this whole file in Supabase → SQL Editor → Run
-- ============================================================

-- 1. Make sure the table exists in the public schema
--    (if this errors, run analytics-setup.sql first)
select 1 from public.page_visits limit 0;

-- 2. Make sure RLS is on
alter table public.page_visits enable row level security;

-- 3. Drop any half-created policies from the earlier attempt
drop policy if exists "anon can insert visits" on public.page_visits;
drop policy if exists "anon can update visits" on public.page_visits;
drop policy if exists "public can insert visits" on public.page_visits;
drop policy if exists "public can update visits" on public.page_visits;

-- 4. Recreate them against `public` — this covers the anon role
--    whether your project uses legacy anon keys or the newer
--    publishable keys.
create policy "public can insert visits"
  on public.page_visits
  for insert
  to public
  with check (true);

create policy "public can update visits"
  on public.page_visits
  for update
  to public
  using (true)
  with check (true);

-- 5. PostgREST also needs table-level grants, not just policies.
--    This is the step most often missing.
grant usage on schema public to anon;
grant insert, update on public.page_visits to anon;
grant usage, select on sequence public.page_visits_id_seq to anon;

-- 6. Reload the API schema cache so PostgREST picks it all up
notify pgrst, 'reload schema';

-- ============================================================
--  VERIFY — both of these should return rows now
-- ============================================================
-- Policies:
--   select policyname, cmd, roles, with_check
--   from pg_policies where tablename = 'page_visits';
--
-- Grants:
--   select grantee, privilege_type
--   from information_schema.role_table_grants
--   where table_name = 'page_visits' and grantee = 'anon';
--
-- Note: there is still deliberately NO select policy, so the
-- public key cannot read the log back. That is intentional.
