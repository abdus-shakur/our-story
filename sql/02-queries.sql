-- ============================================================
--  S & H  ·  read-only queries
--  Nothing here changes data. Run whichever you want.
-- ============================================================


-- ---------- Who visited, newest first ----------
select visited_at, ip, city, country, device, os, browser,
       referrer, reached_film, opened_letter, max_scroll, duration_sec
from public.page_visits
order by visited_at desc;


-- ---------- Every visitor with their FLAMES plays on one line ----------
select v.id, v.visited_at, v.ip, v.city, v.device, v.browser,
       v.reached_film, v.opened_letter, v.max_scroll, v.duration_sec,
       count(f.id) as flames_plays,
       string_agg(f.name1 || ' & ' || f.name2 || ' → ' || f.result_word, ' | '
                  order by f.played_at) as flames
from public.page_visits v
left join public.flames_plays f on f.visit_id = v.id
group by v.id
order by v.visited_at desc;


-- ---------- Every FLAMES play with who played it ----------
select f.played_at, f.name1, f.name2, f.result_word,
       v.ip, v.city, v.country, v.device, v.browser
from public.flames_plays f
left join public.page_visits v on v.id = f.visit_id
order by f.played_at desc;


-- ---------- Unique visitors by IP ----------
select ip, country, city,
       count(*)              as visits,
       max(visited_at)       as last_seen,
       bool_or(reached_film) as watched_film,
       bool_or(opened_letter) as read_letter
from public.page_visits
group by ip, country, city
order by last_seen desc;


-- ---------- Engagement funnel ----------
select count(*)                                        as visits,
       count(*) filter (where reached_film)            as tapped_through,
       count(*) filter (where opened_letter)           as opened_letter,
       round(avg(max_scroll))                          as avg_scroll_pct,
       round(avg(duration_sec))                        as avg_seconds,
       max(no_dodges)                                  as most_button_chases
from public.page_visits;


-- ---------- Most-entered names in FLAMES ----------
select name, count(*) as times
from (
  select lower(trim(name1)) as name from public.flames_plays
  union all
  select lower(trim(name2))          from public.flames_plays
) t
where name <> ''
group by name
order by times desc;


-- ---------- FLAMES result breakdown ----------
select result_word, count(*) as times
from public.flames_plays
group by result_word
order by times desc;


-- ---------- Excluding your own devices ----------
-- put your IPs in the list first
select * from public.page_visits
where ip is distinct from 'YOUR.IP.HERE'
order by visited_at desc;
