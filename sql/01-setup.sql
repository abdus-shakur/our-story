-- ============================================================
--  S & H  ·  logging schema
--  Run this ONCE. Safe to re-run — every statement is idempotent.
--
--  HOW TO RUN: Supabase → SQL Editor → New query → paste the whole
--  file → Run. If any statement errors the whole file rolls back,
--  so run it top to bottom and read the error if one appears.
--
--  Two tables:
--    page_visits   — one row per page load
--    flames_plays  — one row per FLAMES calculation,
--                    linked by visit_id → page_visits.id
-- ============================================================


-- ------------------------------------------------------------
--  1. page_visits
-- ------------------------------------------------------------
create table if not exists public.page_visits (
  id            bigserial primary key,
  visited_at    timestamptz not null default now(),
  session_id    text,

  -- network
  ip            text,
  country       text,
  city          text,
  region        text,
  org           text,

  -- device
  device        text,          -- mobile | tablet | desktop
  os            text,
  browser       text,
  screen        text,          -- 390x844
  viewport      text,
  dpr           numeric,

  -- context
  language      text,
  timezone      text,
  referrer      text,
  page_url      text,
  user_agent    text,

  -- engagement
  reached_film  boolean default false,
  opened_letter boolean default false,
  max_scroll    int     default 0,
  scenes_seen   int     default 0,
  no_dodges     int     default 0,
  duration_sec  int     default 0,
  flames_plays  int     default 0,
  flames_last   text
);


-- ------------------------------------------------------------
--  2. flames_plays
-- ------------------------------------------------------------
create table if not exists public.flames_plays (
  id           bigserial primary key,
  played_at    timestamptz not null default now(),

  visit_id     bigint references public.page_visits(id) on delete set null,
  session_id   text,          -- only used to repair a null visit_id

  name1        text,
  name2        text,
  result       text,          -- F / L / A / M / E / S
  result_word  text,          -- Friends / Lovers / Affection / ...
  letter_count int
);


-- ------------------------------------------------------------
--  3. Indexes
-- ------------------------------------------------------------
create index if not exists page_visits_visited_at_idx on public.page_visits (visited_at desc);
create index if not exists page_visits_session_idx    on public.page_visits (session_id);
create index if not exists flames_plays_played_at_idx on public.flames_plays (played_at desc);
create index if not exists flames_plays_visit_idx     on public.flames_plays (visit_id);
create index if not exists flames_plays_session_idx   on public.flames_plays (session_id);


-- ------------------------------------------------------------
--  4. Access control
--
--  RLS is OFF and access is governed purely by GRANTs. The public
--  key gets INSERT (and UPDATE on visits, for the engagement stats
--  sent when the visitor leaves) but never SELECT — so nobody can
--  read the log back through the page. Simpler than RLS policies
--  and gives exactly the same protection here.
-- ------------------------------------------------------------
alter table public.page_visits  disable row level security;
alter table public.flames_plays disable row level security;

grant usage on schema public to anon;

grant insert, update on public.page_visits  to anon;
grant insert          on public.flames_plays to anon;

grant usage, select on sequence public.page_visits_id_seq  to anon;
grant usage, select on sequence public.flames_plays_id_seq to anon;

-- Inserting a row with a foreign key does NOT require SELECT on the
-- parent table — Postgres validates it internally as the table owner.
-- So page_visits stays completely unreadable to the public key.


-- ------------------------------------------------------------
--  5. Tell the API about the changes
-- ------------------------------------------------------------
notify pgrst, 'reload schema';


-- ------------------------------------------------------------
--  6. Verify — expected: both tables exist, anon_can_read = false
-- ------------------------------------------------------------
select
  to_regclass('public.page_visits')  is not null            as page_visits_ok,
  to_regclass('public.flames_plays') is not null            as flames_plays_ok,
  has_table_privilege('anon','public.page_visits','INSERT') as anon_can_insert,
  has_table_privilege('anon','public.page_visits','SELECT') as anon_can_read;
