# 🎬 S & H

A single-page cinematic love story. Live at
**https://abdus-shakur.github.io/our-story/**

Pure HTML/CSS/JS in one file — no build step, no dependencies, no
framework. Everything is served straight from this repo.

## The experience

1. **Landing** — a blurred photo behind a teasing question, with a
   "deny" button that runs away on tap and escalating taunts
2. **The cut** — confetti, then a fade to blush
3. **Title card** — *A true story presents · S & H* over falling rain,
   with a live counter since the day they met
4. **Ten scenes** — each with its own dreamy blurred backdrop, telling
   the story from a rainy June evening through Pondicherry
5. **Post-credits letter** — an envelope that unfolds
6. **Rolling credits** — ending on *to be continued…*
7. **FLAMES** — the playground algorithm, with the elimination animation

Throughout: letterbox bars, film grain, a vignette, falling rain and
occasional lightning.

## Editing it

Everything personal lives in the `CONFIG` object near the top of the
`<script>` in `index.html`:

| Key | What it controls |
|---|---|
| `herName` | the name on the landing screen |
| `anniversary` | the date the live counter counts from |
| `question`, `yesLabel`, `noLabel`, `noTaunts` | the landing screen |
| `filmTitle`, `filmTagline` | the title card |
| `milestones` | the scenes — text plus photo/video per entry |
| `letter` | the letter, one string per paragraph |
| `credits` | the rolling credits |

**Scene media** accepts a few shapes:

```js
media: "assets/x.jpg"                      // one photo, full width
media: "assets/x.mp4"                      // one video
media: ["assets/a.jpg", "assets/b.jpg"]    // photos pair up side by side
media: [{src: "assets/a.jpg", full: true}] // force full width
media: false                               // no media card at all
bg:    "assets/x.jpg"                      // override the blurred backdrop
```

Missing files degrade gracefully to a styled emoji card, so nothing
breaks if an asset is absent.

Add `?preview` to the URL to skip straight into the film while editing
(it also disables visit logging).

## Visitor logging

Visits and FLAMES plays are logged to Supabase. Credentials live in the
`ANALYTICS` object at the bottom of `index.html` — leave `SUPABASE_URL`
empty to switch logging off entirely.

Two tables, linked by `flames_plays.visit_id → page_visits.id`:

- **`page_visits`** — one row per load: IP, city, country, device, OS,
  browser, screen, timezone, referrer, plus engagement (did they tap
  through, scroll depth, time on page, did they open the letter)
- **`flames_plays`** — one row per calculation: both names, the result,
  and which visit produced it

The public key can `INSERT` but never `SELECT`, so the log cannot be
read back through the page.

SQL lives in `sql/`:

| File | Purpose |
|---|---|
| `01-setup.sql` | creates both tables, indexes, grants — run once |
| `02-queries.sql` | read-only queries for browsing the data |
| `03-maintenance.sql` | repair, clear, or drop data — one block at a time |

## Running it locally

```bash
python3 -m http.server 8000
# then open http://localhost:8000
```

## Deploying

Any push to `main` republishes automatically:

```bash
git add -A && git commit -m "..." && git push
```

## Note

The repo is public, which is what makes free GitHub Pages hosting work.
Anyone with the link can see the photos, videos and letter. For genuine
access control, host on Cloudflare Pages or Netlify instead — both offer
real password protection on their free tiers.
