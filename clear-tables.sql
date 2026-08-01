-- ============================================================
--  CLEAR ALL LOGGED DATA
--  ⚠️  DESTRUCTIVE — deletes every row. Not undoable.
--  Run the block you want in Supabase → SQL Editor.
-- ============================================================


-- ---------- BLOCK 0: look before you delete ----------
select
  (select count(*) from public.page_visits)  as page_visits_rows,
  (select count(*) from public.flames_plays) as flames_plays_rows;


-- ---------- BLOCK 1: wipe both tables, reset ids to 1 ----------
-- Both are truncated together because flames_plays has a foreign key
-- into page_visits. RESTART IDENTITY makes the next row start at id 1.
truncate table public.flames_plays, public.page_visits restart identity;


-- ---------- BLOCK 2: confirm they're empty ----------
select
  (select count(*) from public.page_visits)  as page_visits_rows,
  (select count(*) from public.flames_plays) as flames_plays_rows;


-- ============================================================
--  ALTERNATIVES — use instead of BLOCK 1 if you want something
--  narrower. Each is independent; run only what you need.
-- ============================================================

-- Clear FLAMES plays only, keep the visit log:
--   truncate table public.flames_plays restart identity;

-- Clear visits only (this also empties flames_plays, because of the FK):
--   truncate table public.page_visits, public.flames_plays restart identity;

-- Delete just your own test devices, keeping real visitors:
--   delete from public.flames_plays
--   where visit_id in (select id from public.page_visits where ip = 'YOUR.IP.HERE');
--   delete from public.page_visits where ip = 'YOUR.IP.HERE';

-- Delete everything older than a date:
--   delete from public.flames_plays where played_at  < '2026-08-01';
--   delete from public.page_visits  where visited_at < '2026-08-01';

-- Keep the rows but forget the identifying bits:
--   update public.page_visits set ip = null, city = null, region = null, org = null;


-- ============================================================
--  NUCLEAR — removes the tables and view entirely, not just the
--  rows. Only use this if you want to start over from scratch;
--  you would then re-run analytics-setup.sql and flames-setup.sql.
-- ============================================================
--   drop view  if exists public.visits_with_flames;
--   drop table if exists public.flames_plays;
--   drop table if exists public.page_visits;
