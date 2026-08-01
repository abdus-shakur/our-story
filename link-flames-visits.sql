-- ============================================================
--  Link FLAMES plays to page visits
--  Run each block separately in Supabase → SQL Editor
-- ============================================================

-- ---------- BLOCK 1: two extra columns on the visit row ----------
-- so a single page_visits row already tells you whether that
-- visitor played FLAMES, without needing a join
alter table public.page_visits
  add column if not exists flames_plays int default 0,
  add column if not exists flames_last  text;


-- ---------- BLOCK 2: index the join key on both sides ----------
create index if not exists page_visits_session_idx  on public.page_visits (session_id);
create index if not exists flames_plays_session_idx on public.flames_plays (session_id);


-- ---------- BLOCK 3: a view that joins them ----------
create or replace view public.visits_with_flames as
select
  v.id            as visit_id,
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
  f.played_at     as flames_at,
  f.name1,
  f.name2,
  f.result_word,
  v.session_id
from public.page_visits v
left join public.flames_plays f on f.session_id = v.session_id
order by v.visited_at desc;


-- ---------- BLOCK 4: keep the view private ----------
-- the public key must not be able to read it
revoke all on public.visits_with_flames from anon;


-- ---------- BLOCK 5: refresh the API ----------
notify pgrst, 'reload schema';


-- ============================================================
--  Use it
-- ============================================================
-- Everything, newest first:
--   select * from visits_with_flames;
--
-- Only visitors who actually played FLAMES:
--   select visited_at, city, device, name1, name2, result_word
--   from visits_with_flames where name1 is not null;
--
-- One line per visitor, with all their plays gathered up:
--   select v.visited_at, v.ip, v.city, v.device, v.reached_film,
--          count(f.id) as plays,
--          string_agg(f.name1 || ' & ' || f.name2 || ' → ' || f.result_word, ' | ') as flames
--   from page_visits v
--   left join flames_plays f on f.session_id = v.session_id
--   group by v.id order by v.visited_at desc;
--
-- Plays that have no matching visit row (e.g. the visit insert
-- failed but FLAMES worked) — useful for spotting logging gaps:
--   select f.* from flames_plays f
--   left join page_visits v on v.session_id = f.session_id
--   where v.id is null;
