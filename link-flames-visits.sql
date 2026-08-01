-- ============================================================
--  Optional: a joined view over the two tables
--  (the link itself is flames_plays.visit_id → page_visits.id,
--   created in flames-setup.sql — this is just convenience)
--  Run each block SEPARATELY in Supabase → SQL Editor
-- ============================================================

-- ---------- BLOCK 0: drop any earlier version of the view ----------
-- `create or replace view` cannot rename or reorder existing columns,
-- so if you ran an earlier version of this file, drop it first.
drop view if exists public.visits_with_flames;


-- ---------- BLOCK 1: a view that joins them ----------
create view public.visits_with_flames as
select
  v.id          as visit_id,
  v.visited_at,
  v.ip,
  v.country,
  v.city,
  v.device,
  v.os,
  v.browser,
  v.referrer,
  v.reached_film,
  v.opened_letter,
  v.max_scroll,
  v.duration_sec,
  f.id          as flames_id,
  f.played_at   as flames_at,
  f.name1,
  f.name2,
  f.result_word
from public.page_visits v
left join public.flames_plays f on f.visit_id = v.id
order by v.visited_at desc;


-- ---------- BLOCK 2: keep the view private ----------
revoke all on public.visits_with_flames from anon;


-- ---------- BLOCK 3: refresh the API ----------
notify pgrst, 'reload schema';


-- ============================================================
--  Use it
-- ============================================================
--   select * from visits_with_flames;
--   select * from visits_with_flames where name1 is not null;
