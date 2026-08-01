-- ============================================================
--  SIMPLEST WORKING SETUP — run these ONE BLOCK AT A TIME
--  (the Supabase SQL Editor rolls back the whole script if any
--   single statement errors, which is why the last one vanished)
-- ============================================================

-- ---------- BLOCK 1: what do we actually have? ----------
select
  (select count(*) from pg_tables
     where schemaname = 'public' and tablename = 'page_visits')      as table_exists,
  (select relrowsecurity from pg_class
     where oid = 'public.page_visits'::regclass)                     as rls_on,
  (select count(*) from pg_policies
     where schemaname = 'public' and tablename = 'page_visits')      as policy_count,
  (select string_agg(privilege_type, ', ')
     from information_schema.role_table_grants
     where table_schema = 'public' and table_name = 'page_visits'
       and grantee = 'anon')                                         as anon_grants;


-- ---------- BLOCK 2: turn RLS OFF ----------
-- Access is then governed purely by GRANTs, which is exactly what
-- we want: anon may INSERT/UPDATE, and — because we never grant
-- SELECT — anon still cannot read the log back. Same protection,
-- none of the policy complexity.
alter table public.page_visits disable row level security;


-- ---------- BLOCK 3: grant only what the page needs ----------
grant usage on schema public to anon;
grant insert, update on public.page_visits to anon;


-- ---------- BLOCK 4: the id sequence ----------
-- Run this on its own. If it errors "relation does not exist",
-- your id column isn't a bigserial — run BLOCK 4b instead.
grant usage, select on sequence public.page_visits_id_seq to anon;

-- ---------- BLOCK 4b: only if 4 failed ----------
-- Finds the real sequence name whatever it is:
-- select pg_get_serial_sequence('public.page_visits', 'id');
-- then: grant usage, select on sequence <that name> to anon;


-- ---------- BLOCK 5: refresh the API ----------
notify pgrst, 'reload schema';


-- ---------- BLOCK 6: verify anon really cannot read ----------
-- Should return FALSE — proving the public key can't pull the log:
select has_table_privilege('anon', 'public.page_visits', 'SELECT') as anon_can_read;
