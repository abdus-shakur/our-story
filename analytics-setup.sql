-- ============================================================
--  Visitor log for the "S & H" page
--  Run this once in Supabase → SQL Editor → New query → Run
-- ============================================================

create table if not exists page_visits (
  id            bigserial primary key,
  visited_at    timestamptz not null default now(),
  session_id    text,               -- random id, groups events from one visit
  ip            text,
  country       text,
  city          text,
  region        text,
  org           text,               -- ISP / network name
  device        text,               -- mobile | tablet | desktop
  os            text,
  browser       text,
  screen        text,               -- e.g. 390x844
  viewport      text,
  dpr           numeric,            -- device pixel ratio
  language      text,
  timezone      text,
  referrer      text,
  page_url      text,
  user_agent    text,
  reached_film  boolean default false,
  max_scroll    int     default 0,  -- % of page scrolled
  scenes_seen   int     default 0,
  opened_letter boolean default false,
  no_dodges     int     default 0,  -- times they chased the "Speak for yourself" button
  duration_sec  int     default 0
);

-- Helpful indexes
create index if not exists page_visits_visited_at_idx on page_visits (visited_at desc);
create index if not exists page_visits_session_idx    on page_visits (session_id);

-- ------------------------------------------------------------
--  Row Level Security: the public key may INSERT and UPDATE its
--  own row, but may never SELECT. Only you (dashboard / service
--  role) can read the data.
-- ------------------------------------------------------------
alter table page_visits enable row level security;

drop policy if exists "anon can insert visits" on page_visits;
create policy "anon can insert visits"
  on page_visits for insert
  to anon
  with check (true);

-- allows the page to update its own row with engagement stats
drop policy if exists "anon can update visits" on page_visits;
create policy "anon can update visits"
  on page_visits for update
  to anon
  using (true)
  with check (true);

-- NOTE: no SELECT policy on purpose → the public anon key cannot
-- read anyone's data back. You read it in the Supabase dashboard.

-- ============================================================
--  Handy queries for later
-- ============================================================
-- All visits, newest first:
--   select visited_at, ip, country, city, device, os, browser,
--          reached_film, max_scroll, duration_sec
--   from page_visits order by visited_at desc;
--
-- Unique visitors by IP:
--   select ip, country, city, count(*) as visits,
--          max(visited_at) as last_seen,
--          bool_or(reached_film) as watched
--   from page_visits group by ip, country, city order by last_seen desc;
--
-- Exclude your own test devices:
--   select * from page_visits where ip not in ('YOUR.IP.HERE')
--   order by visited_at desc;
--
-- Engagement funnel:
--   select count(*) as visits,
--          count(*) filter (where reached_film)  as tapped_yes,
--          count(*) filter (where opened_letter) as read_letter,
--          round(avg(max_scroll))                as avg_scroll_pct
--   from page_visits;
