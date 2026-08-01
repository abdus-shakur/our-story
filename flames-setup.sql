-- ============================================================
--  FLAMES plays log
--  Run each block separately in Supabase → SQL Editor
-- ============================================================

-- ---------- BLOCK 1: the table ----------
create table if not exists public.flames_plays (
  id           bigserial primary key,
  played_at    timestamptz not null default now(),
  session_id   text,
  name1        text,
  name2        text,
  result       text,          -- F / L / A / M / E / S
  result_word  text,          -- Friends / Lovers / ...
  letter_count int
);

create index if not exists flames_plays_played_at_idx on public.flames_plays (played_at desc);


-- ---------- BLOCK 2: RLS off, grants do the work ----------
-- anon may INSERT but never SELECT, so nobody can read the
-- names back out of the page.
alter table public.flames_plays disable row level security;


-- ---------- BLOCK 3: grants ----------
grant usage on schema public to anon;
grant insert on public.flames_plays to anon;


-- ---------- BLOCK 4: the id sequence ----------
grant usage, select on sequence public.flames_plays_id_seq to anon;


-- ---------- BLOCK 5: refresh the API ----------
notify pgrst, 'reload schema';


-- ============================================================
--  Handy queries
-- ============================================================
-- Every play, newest first:
--   select played_at, name1, name2, result_word
--   from flames_plays order by played_at desc;
--
-- Most-entered names:
--   select name, count(*) from (
--     select lower(trim(name1)) as name from flames_plays
--     union all
--     select lower(trim(name2)) from flames_plays
--   ) t group by name order by count(*) desc;
--
-- Result breakdown:
--   select result_word, count(*) from flames_plays
--   group by result_word order by count(*) desc;
--
-- Join plays to the visit that made them:
--   select f.played_at, f.name1, f.name2, f.result_word,
--          v.country, v.city, v.device, v.ip
--   from flames_plays f
--   left join page_visits v on v.session_id = f.session_id
--   order by f.played_at desc;
