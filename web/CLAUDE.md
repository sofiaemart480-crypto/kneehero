# KneeHero Web App

A browser-based port of the KneeHero rehab/therapy game (originally SwiftUI).
Pure HTML/CSS/JS, no build step, no backend.

## Files
- `index.html` — entry point
- `style.css` — theme/layout, mobile-first
- `planets.js` — **planet container**: add a new planet by pushing an object
  onto `PLANETS` with `name`, `subtitle`, `scene` (CSS class), and a `games`
  array. Each game's `type` (`tapCollect`, `flappy`, `runner`, `snake`) reuses
  an existing engine in `app.js` — no new game code needed unless you want a
  genuinely new mechanic.
- `app.js` — state machine, screens, persistence, game engines

## Running locally
No build tools needed. From this directory:

```bash
python3 -m http.server 8000
```

Then open http://localhost:8000 in a browser (use Chrome/Edge mobile
emulation or a real phone on the same network for touch testing).

## Data & persistence
All state (avatar colors, plan, current session/planet, mission timer,
session history) is stored in `localStorage` under `kneehero_state_v1`.
Nothing is sent to a server. "Export History (CSV)" on the dashboard
downloads session history for opening in Excel/Sheets.

## Deploying to GitHub Pages
1. Push this `web/` folder to the repo (or make it the repo root).
2. In GitHub: Settings → Pages → Source → select the branch and `/web`
   folder (or root if you moved files there).
3. Visit the published URL — `index.html` loads everything automatically.

## Adding a new planet
Edit `planets.js` only:

```js
PLANETS.push({
  id: 3,
  name: "New Planet",
  subtitle: "Subtitle",
  scene: "scene-aurora", // or add a new CSS gradient class in style.css
  games: [
    { id: "myGame", name: "My Game", type: "tapCollect", emoji: "🎯",
      collectEmoji: ["🎯"], avoidEmoji: [], color: "blue", desc: "..." }
  ]
});
```

## Known limitations / next steps
- BOA dial is a slider; a future Web Bluetooth integration (Chrome/Android
  only — not supported on iOS Safari) could drive `boa.value` from an ESP32.
- Accounts are name-only (no real auth) — local-only by design.
- Canvas games use emoji glyphs; consider SVG sprites for finer visual
  polish later.
