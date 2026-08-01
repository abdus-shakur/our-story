# 🎬 Girlfriend Day Surprise — "Us"

A single-page cinematic surprise app. Opens as a playful pink
"Do you love me?" ask (with a No button that runs away on tap), then
confetti → fade-to-black with a date slate → a dark, movie-style
experience: letterbox bars, film grain, falling rain with lightning
flashes (their story started in a storm ⛈️), a gold movie-title card
with a live "since we met" counter, scroll-revealed scenes, a
post-credits letter in an envelope, and a rolling credits ending.
Pure HTML/CSS/JS — no build step, no dependencies.

## Personalize

Everything personal lives in the `CONFIG` object at the top of the
`<script>` in `index.html`:

- `herName`, `anniversary`, `question`, `signature`
- `filmTitle`, `filmTagline`, `slateText` — the movie framing
- `milestones` — your scenes (text + photo/video per entry)
- `letter` — the paragraphs of your letter
- `credits` — the rolling credits at the end

Media files go in `assets/` — see `assets/README.md`.

## Preview locally

```bash
cd girlfriend-day
python3 -m http.server 8000
# open http://localhost:8000 (or your Mac's IP from your phone on the same Wi-Fi)
```

## Deploy to GitHub Pages

```bash
cd girlfriend-day
git init && git add -A && git commit -m "surprise 💝"
gh repo create girlfriend-day --public --source=. --push
gh api repos/{owner}/girlfriend-day/pages -X POST \
  -f "source[branch]=main" -f "source[path]=/"
```

Your link will be `https://<your-username>.github.io/girlfriend-day/`
(takes a minute or two to go live the first time).

> Note: the repo is public, so anyone with the link can see it.
> Keep that in mind for photos/text you add.
