-- ============================================================
--  FLAMES plays  —  separate table, linked to page_visits by a
--  real foreign key (visit_id → page_visits.id)
--  Run each block SEPARATELY in Supabase → SQL Editor
-- ============================================================

-- ---------- BLOCK 1: the table ----------
create table if not exists public.flames_plays (
  id           bigserial primary key,
  played_at    timestamptz not null default now(),

  -- the visit that produced this play
  visit_id     bigint references public.page_visits(id) on delete set null,
  session_id   text,          -- fallback link if the visit insert failed

  name1        text,
  name2        text,
  result       text,          -- F / L / A / M / E / S
  result_word  text,          -- Friends / Lovers / Affection / ...
  letter_count int
);


-- ---------- BLOCK 1b: if the table already exists without visit_id ----------
alter table public.flames_plays
  add column if not exists visit_id bigint references public.page_visits(id) on delete set null;


-- ---------- BLOCK 2: indexes ----------
create index if not exists flames_plays_played_at_idx on public.flames_plays (played_at desc);
create index if not exists flames_plays_visit_idx     on public.flames_plays (visit_id);
create index if not exists flames_plays_session_idx   on public.flames_plays (session_id);


-- ---------- BLOCK 3: RLS off, grants do the work ----------
-- anon may INSERT but never SELECT, so nobody can read the names
-- back out through the public key.
alter table public.flames_plays disable row level security;


-- ---------- BLOCK 4: grants ----------
grant usage on schema public to anon;
grant insert on public.flames_plays to anon;
grant usage, select on sequence public.flames_plays_id_seq to anon;
-- NOTE: inserting a row with a foreign key does NOT require SELECT
-- on page_visits — Postgres validates the FK internally as the table
-- owner. So the visit log stays completely unreadable to the public key.


-- ---------- BLOCK 5: refresh the API ----------
notify pgrst, 'reload schema';


-- ============================================================
--  Queries
-- ============================================================
-- Every play with the visit that made it:
--   select f.played_at, f.name1, f.name2, f.result_word,
--          v.ip, v.city, v.country, v.device, v.browser
--   from flames_plays f
--   left join page_visits v on v.id = f.visit_id
--   order by f.played_at desc;
--
-- One line per visitor, all their plays gathered up:
--   select v.id, v.visited_at, v.ip, v.city, v.device,
--          count(f.id) as plays,
--          string_agg(f.name1 || ' & ' || f.name2 || ' → ' || f.result_word, ' | ') as flames
--   from page_visits v
--   left join flames_plays f on f.visit_id = v.id
--   group by v.id order by v.visited_at desc;
--
-- Most-entered names:
--   select name, count(*) from (
--     select lower(trim(name1)) as name from flames_plays
--     union all select lower(trim(name2)) from flames_plays
--   ) t group by name order by count(*) desc;
--
-- Result breakdown:
--   select result_word, count(*) from flames_plays
--   group by result_word order by count(*) desc;
--
-- Orphans (play saved before/without its visit row):
--   select * from flames_plays where visit_id is null;
--
-- REPAIR them — this is the one job session_id exists for. If the
-- visit insert landed after the play, the FK is null but the visit
-- row does exist, so match it back up:
--   update flames_plays f
--   set    visit_id = v.id
--   from   page_visits v
--   where  f.visit_id is null
--     and  v.session_id = f.session_id;
--
-- After running that, anything still null had no visit row at all
-- (the visit insert genuinely failed) — nothing to recover.
