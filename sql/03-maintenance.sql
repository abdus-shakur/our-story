-- ============================================================
--  S & H  ·  maintenance
--  ⚠️  These change or delete data. Run ONE block at a time,
--      never the whole file.
-- ============================================================


-- ---------- Row counts (safe, run any time) ----------
select
  (select count(*) from public.page_visits)  as page_visits_rows,
  (select count(*) from public.flames_plays) as flames_plays_rows;


-- ---------- Repair FLAMES plays with a null visit_id ----------
-- Happens when the visit insert landed AFTER the play was saved.
-- This is the only reason session_id exists.
update public.flames_plays f
set    visit_id = v.id
from   public.page_visits v
where  f.visit_id is null
  and  v.session_id = f.session_id;

-- Anything still null after that had no visit row at all — nothing
-- to recover:
--   select * from public.flames_plays where visit_id is null;


-- ============================================================
--  DESTRUCTIVE from here down
-- ============================================================

-- ---------- Wipe everything, reset ids to 1 ----------
-- Both tables go together because of the foreign key.
--   truncate table public.flames_plays, public.page_visits restart identity;


-- ---------- Wipe FLAMES plays only, keep the visit log ----------
--   truncate table public.flames_plays restart identity;


-- ---------- Delete your own test devices ----------
--   delete from public.flames_plays
--   where visit_id in (select id from public.page_visits where ip = 'YOUR.IP.HERE');
--   delete from public.page_visits where ip = 'YOUR.IP.HERE';


-- ---------- Delete everything before a date ----------
--   delete from public.flames_plays where played_at  < '2026-08-01';
--   delete from public.page_visits  where visited_at < '2026-08-01';


-- ---------- Keep the stats, forget the identifying details ----------
--   update public.page_visits
--   set ip = null, city = null, region = null, org = null, user_agent = null;


-- ---------- Start over completely ----------
-- Drops the tables; re-run 01-setup.sql afterwards.
--   drop table if exists public.flames_plays;
--   drop table if exists public.page_visits;


-- ---------- Remove the old joined view ----------
-- Earlier versions of this project created a `visits_with_flames`
-- view. It is no longer used — the queries in 02-queries.sql join
-- the two tables directly. Run this once to clean it up:
--   drop view if exists public.visits_with_flames;
