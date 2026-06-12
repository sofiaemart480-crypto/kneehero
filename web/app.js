/* KneeHero Space Command — web app
 * Single state object persisted to localStorage. All screens are rendered
 * by replacing #app's innerHTML; game screens attach a canvas + loop.
 */

const STORAGE_KEY = "kneehero_state_v1";
const app = document.getElementById("app");

const COLORS = ["#ffffff", "#4dd9e8", "#4d9bf2", "#b06bf2", "#ff9f4d", "#ff5d5d", "#4dd97a", "#ffd84d", "#222222"];

let state = loadState();
let gameHandle = null; // active rAF/interval handle for cleanup
let timerHandle = null;

function defaultState() {
  return {
    screen: "welcome",
    name: "",
    avatar: { suit: "#4d9bf2", eyes: "#4dd9e8", rocketBody: "#ffffff", rocketFin: "#ff5d5d", rocketWindow: "#4dd9e8" },
    plan: { ...DEFAULT_PLAN },
    currentSession: 1,
    currentPlanetIndex: 0,
    missionTimeRemaining: DEFAULT_PLAN.holdMinutes * 60,
    timerRunning: false,
    fuel: 0,
    history: []
  };
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return defaultState();
    return { ...defaultState(), ...JSON.parse(raw) };
  } catch (e) {
    console.warn("Could not load saved state, starting fresh.", e);
    return defaultState();
  }
}

function saveState() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch (e) {
    console.warn("Could not save state — browser storage may be full or disabled.", e);
  }
}

function go(screen) {
  stopGameLoop();
  state.screen = screen;
  saveState();
  render();
}

function update(patch) {
  Object.assign(state, patch);
  saveState();
}

function stopGameLoop() {
  if (gameHandle) {
    cancelAnimationFrame(gameHandle.raf);
    clearInterval(gameHandle.interval);
    gameHandle = null;
  }
}

/* ---------------- Mission timer ---------------- */
function ensureTimer() {
  if (timerHandle) return;
  timerHandle = setInterval(() => {
    if (state.timerRunning && state.missionTimeRemaining > 0) {
      state.missionTimeRemaining -= 1;
      saveState();
      const el = document.querySelector("[data-timer]");
      if (el) el.textContent = formatTime(state.missionTimeRemaining);
    }
  }, 1000);
}

function formatTime(sec) {
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${m}:${String(s).padStart(2, "0")}`;
}

/* ---------------- Helpers ---------------- */
function planet(index) {
  return PLANETS[index];
}

function starsHTML(count = 50) {
  let html = '<div class="stars" aria-hidden="true">';
  for (let i = 0; i < count; i++) {
    const size = 1 + Math.random() * 2;
    html += `<div class="star" style="left:${Math.random() * 100}%; top:${Math.random() * 100}%; width:${size}px; height:${size}px; animation-delay:${Math.random() * 2}s;"></div>`;
  }
  html += "</div>";
  return html;
}

function swatchRow(label, key, value, onPick) {
  const swatches = COLORS.map(c =>
    `<button class="swatch ${c === value ? "selected" : ""}" style="background:${c}" aria-label="${label} color ${c}" aria-pressed="${c === value}" data-color="${c}"></button>`
  ).join("");
  return `<div class="swatch-row"><div class="label">${label}</div><div class="swatches" data-swatch-key="${key}">${swatches}</div></div>`;
}

function attachSwatchHandlers(root, onPick) {
  root.querySelectorAll("[data-swatch-key]").forEach(group => {
    const key = group.dataset.swatchKey;
    group.querySelectorAll(".swatch").forEach(btn => {
      btn.addEventListener("click", () => onPick(key, btn.dataset.color));
    });
  });
}

/* ================= SCREENS ================= */

function render() {
  switch (state.screen) {
    case "welcome": return renderWelcome();
    case "login": return renderLogin();
    case "avatarCreator": return renderAvatarCreator();
    case "dashboard": return renderDashboard();
    case "rocketFueling": return renderRocketFueling();
    case "launch": return renderLaunch();
    case "planetArrival": return renderPlanetArrival();
    case "missionChoice": return renderMissionChoice();
    case "missionTimerOnly": return renderMissionTimerOnly();
    case "missionComplete": return renderMissionComplete();
    case "game": return renderGame();
    default: return renderWelcome();
  }
}

function renderWelcome() {
  app.innerHTML = `
    <div class="screen scene-welcome">
      ${starsHTML(70)}
      <div class="spacer"></div>
      <h1>KneeHero</h1>
      <p class="subtitle">Space Command</p>
      <p class="caption">Rehabilitation missions for knee extension therapy</p>
      <div class="spacer"></div>
      <button class="btn btn-blue" id="start">Begin Mission</button>
      <div class="spacer"></div>
    </div>`;
  document.getElementById("start").onclick = () => go(state.name ? "dashboard" : "login");
}

function renderLogin() {
  app.innerHTML = `
    <div class="screen scene-welcome">
      ${starsHTML(40)}
      <div class="spacer"></div>
      <h1>Astronaut Name</h1>
      <p class="caption">Stored only in this browser — no account needed.</p>
      <label for="nameInput">Your name</label>
      <input id="nameInput" type="text" maxlength="24" autocomplete="given-name" value="${state.name || ""}" placeholder="e.g. Jordan" />
      <button class="btn btn-cyan" id="go">Continue</button>
      <div class="spacer"></div>
    </div>`;
  document.getElementById("go").onclick = () => {
    const val = document.getElementById("nameInput").value.trim();
    update({ name: val || "Astronaut" });
    go("avatarCreator");
  };
}

function renderAvatarCreator() {
  const a = state.avatar;
  app.innerHTML = `
    <div class="screen scene-aurora">
      ${starsHTML(40)}
      <h1>Customize Your Gear</h1>
      <p class="subtitle">Welcome, ${state.name}</p>
      <div class="panel">
        <div style="text-align:center; font-size:4rem;">🧑‍🚀</div>
        ${swatchRow("Suit", "suit", a.suit)}
        ${swatchRow("Eyes", "eyes", a.eyes)}
      </div>
      <div class="panel">
        <div style="text-align:center; font-size:4rem;">🚀</div>
        ${swatchRow("Body", "rocketBody", a.rocketBody)}
        ${swatchRow("Fins", "rocketFin", a.rocketFin)}
        ${swatchRow("Window", "rocketWindow", a.rocketWindow)}
      </div>
      <button class="btn btn-cyan" id="save">Save & Continue</button>
    </div>`;
  attachSwatchHandlers(app, (key, color) => {
    state.avatar[key] = color;
    saveState();
    renderAvatarCreator();
  });
  document.getElementById("save").onclick = () => go("dashboard");
}

function renderDashboard() {
  const p = state.plan;
  const sessions = [
    { n: 1, angle: p.session1Angle, planet: "Aurora Shores" },
    { n: 2, angle: p.session2Angle, planet: "Oceanus Prime" },
    { n: 3, angle: p.session3Angle, planet: "Frost Nova" }
  ];
  const sessionCards = sessions.map(s => `
    <div class="card">
      <div class="emoji">🪐</div>
      <div class="text">
        <h3>Session ${s.n} — ${s.planet}</h3>
        <p>Target: ${s.angle}° hold for ${p.holdMinutes} min</p>
      </div>
    </div>`).join("");

  const historyRows = state.history.slice(-10).reverse().map(h => `
    <tr><td>${h.date}</td><td>${h.planet}</td><td>${h.session}</td><td>${h.targetAngle}°</td><td>${h.durationMin} min</td></tr>
  `).join("") || `<tr><td colspan="5" style="text-align:center; color:#9bd">No sessions yet</td></tr>`;

  app.innerHTML = `
    <div class="screen scene-aurora">
      ${starsHTML(30)}
      <h1>Mission Control</h1>
      <p class="subtitle">Welcome back, ${state.name}</p>
      ${sessionCards}
      <button class="btn btn-cyan" id="startMission">Start Assigned Mission (Session ${state.currentSession})</button>
      <button class="btn btn-orange" id="editGear">Edit Mission Gear</button>

      <div class="panel">
        <h2>Session History</h2>
        <table>
          <thead><tr><th>Date</th><th>Planet</th><th>Session</th><th>Target</th><th>Duration</th></tr></thead>
          <tbody>${historyRows}</tbody>
        </table>
        <button class="btn btn-green" id="export">Export History (CSV)</button>
      </div>

      <button class="btn btn-gray" id="logout">Log Out</button>
    </div>`;

  document.getElementById("startMission").onclick = () => {
    update({ fuel: 0, missionTimeRemaining: state.plan.holdMinutes * 60, timerRunning: false });
    go("rocketFueling");
  };
  document.getElementById("editGear").onclick = () => go("avatarCreator");
  document.getElementById("export").onclick = exportHistoryCSV;
  document.getElementById("logout").onclick = () => go("welcome");
}

function exportHistoryCSV() {
  if (!state.history.length) {
    alert("No session history to export yet.");
    return;
  }
  const header = "Date,Planet,Session,Target Angle,Duration (min),Notes\n";
  const rows = state.history.map(h =>
    [h.date, h.planet, h.session, h.targetAngle, h.durationMin, (h.notes || "").replace(/,/g, ";")].join(",")
  );
  const csv = header + rows.join("\n");
  const blob = new Blob([csv], { type: "text/csv" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `kneehero-history-${new Date().toISOString().slice(0, 10)}.csv`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

function renderRocketFueling() {
  app.innerHTML = `
    <div class="screen ${planet(state.currentPlanetIndex).scene}">
      ${starsHTML(40)}
      <div class="spacer"></div>
      <h1>Fuel the Rocket</h1>
      <p class="caption">Tap the button to pump fuel before launch.</p>
      <div style="font-size:5rem; text-align:center;" aria-hidden="true">🚀</div>
      <div class="panel" role="status">
        <div style="background:rgba(255,255,255,0.2); border-radius:10px; height:18px; overflow:hidden;">
          <div id="fuelBar" style="background:var(--cyan); height:100%; width:${state.fuel}%; transition: width 0.2s;"></div>
        </div>
        <p class="caption">${state.fuel}% fueled</p>
      </div>
      <button class="btn btn-yellow" id="pump">Pump Fuel</button>
      <button class="btn btn-cyan" id="launch" ${state.fuel < 100 ? "disabled" : ""}>Launch</button>
      <div class="spacer"></div>
    </div>`;
  document.getElementById("pump").onclick = () => {
    state.fuel = Math.min(100, state.fuel + 10 + Math.floor(Math.random() * 8));
    saveState();
    renderRocketFueling();
  };
  document.getElementById("launch").onclick = () => go("launch");
}

function renderLaunch() {
  app.innerHTML = `
    <div class="screen ${planet(state.currentPlanetIndex).scene}" id="launchScreen" style="justify-content:center;">
      ${starsHTML(60)}
      <h1 id="launchTitle">Leaving ${planet(state.currentPlanetIndex).name}</h1>
      <div id="rocketWrap" style="position:relative; flex:1; width:100%;">
        <div class="rocket" id="rocket" style="left:50%; top:70%; transform:translate(-50%,0) rotate(0deg);">🚀</div>
      </div>
      <p class="caption">Launching from ${planet(state.currentPlanetIndex).name}…</p>
    </div>`;

  const rocket = document.getElementById("rocket");
  requestAnimationFrame(() => {
    rocket.style.top = "-10%";
    rocket.style.transform = "translate(-50%,0) rotate(-10deg)";
  });

  setTimeout(() => {
    state.currentPlanetIndex = Math.min(state.currentPlanetIndex + 1, 2);
    state.currentSession = Math.min(state.currentSession + 1, 3);
    saveState();
    go("planetArrival");
  }, 2200);
}

function targetAngleFor(session) {
  if (session === 1) return state.plan.session1Angle;
  if (session === 2) return state.plan.session2Angle;
  return state.plan.session3Angle;
}

function renderPlanetArrival() {
  const idx = state.currentPlanetIndex;
  const p = planet(idx);
  const target = targetAngleFor(state.currentSession);

  app.innerHTML = `
    <div class="screen ${p.scene}">
      ${starsHTML(40)}
      <h1>${p.name}</h1>
      <p class="subtitle">${p.subtitle}</p>
      <div class="spacer" style="position:relative; width:100%;">
        <div class="rocket" id="rocket" style="left:50%; top:50%; transform:translate(-50%,-50%) rotate(0deg); opacity:0;">🚀</div>
      </div>
      <div class="panel" style="text-align:center;">
        <p id="landingLabel" style="font-weight:800;">Landing Alignment</p>
        <p style="color:var(--cyan); font-weight:800; font-size:1.3rem;" id="angleLabel">Angle: 0° / ${target}°</p>
        <p class="caption">Turn the BOA dial to guide the rocket landing.</p>
        <input type="range" class="boa-slider" id="boa" min="0" max="${target}" value="0" step="1" aria-label="BOA dial angle" />
        <button class="btn btn-green" id="continueBtn" style="display:none;">Continue Mission</button>
      </div>
    </div>`;

  const slider = document.getElementById("boa");
  const rocket = document.getElementById("rocket");
  const angleLabel = document.getElementById("angleLabel");
  const landingLabel = document.getElementById("landingLabel");
  const continueBtn = document.getElementById("continueBtn");

  slider.addEventListener("input", () => {
    const angle = Number(slider.value);
    const progress = target > 0 ? angle / target : 0;
    angleLabel.textContent = `Angle: ${angle}° / ${target}°`;
    rocket.style.opacity = angle > 0 ? "1" : "0";
    const leftPct = 50 - 35 * progress;
    const topPct = 75 - 60 * progress;
    rocket.style.left = `${leftPct}%`;
    rocket.style.top = `${topPct}%`;
    rocket.style.transform = `translate(-50%,-50%) rotate(${-20 + 20 * progress}deg)`;

    if (angle >= target && target > 0) {
      const labels = { 0: "Congrats! You completed your first landing alignment.", 1: "Congrats! You completed your second landing alignment.", 2: "Congrats! You completed your third landing alignment." };
      landingLabel.textContent = labels[idx] || "Landing complete!";
      landingLabel.style.color = "var(--yellow)";
      continueBtn.style.display = "block";
      slider.disabled = true;

      state.history.push({
        date: new Date().toISOString().slice(0, 10),
        planet: p.name,
        session: state.currentSession,
        targetAngle: target,
        durationMin: state.plan.holdMinutes,
        notes: "Landing alignment completed"
      });
      saveState();
    }
  });

  continueBtn.onclick = () => go("missionChoice");
}

function renderMissionChoice() {
  const idx = state.currentPlanetIndex;
  const p = planet(idx);
  ensureTimer();

  const gameCards = p.games.map(g => `
    <div class="card">
      <div class="emoji">${g.emoji}</div>
      <div class="text"><h3>${g.name}</h3><p>${g.desc}</p></div>
    </div>
    <button class="btn btn-${g.color}" data-game="${g.id}">${g.name}</button>
  `).join("");

  app.innerHTML = `
    <div class="screen ${p.scene}">
      ${starsHTML(30)}
      <h1>${p.name}</h1>
      <p class="subtitle">${p.subtitle}</p>
      <div class="spacer"></div>
      <div class="panel">
        <h2>Choose your mission activity</h2>
        ${gameCards}
        <button class="btn btn-green" id="timerOnly">Mission Timer Only</button>
      </div>
    </div>`;

  app.querySelectorAll("[data-game]").forEach(btn => {
    btn.onclick = () => {
      update({ timerRunning: true, activeGame: btn.dataset.game });
      go("game");
    };
  });
  document.getElementById("timerOnly").onclick = () => {
    update({ timerRunning: true });
    go("missionTimerOnly");
  };
}

function renderMissionTimerOnly() {
  const p = planet(state.currentPlanetIndex);
  ensureTimer();
  app.innerHTML = `
    <div class="screen ${p.scene}">
      ${starsHTML(30)}
      <div class="topbar">
        <button class="back" id="back">← Back</button>
        <div class="info"><h2>${p.name}</h2><div class="count">Mission Timer</div></div>
        <div class="timer" data-timer>${formatTime(state.missionTimeRemaining)}</div>
      </div>
      <div class="spacer"></div>
      <h1 style="font-size:3rem;">⏱️</h1>
      <p class="caption">Keep your brace aligned. The mission timer counts down while you hold the position.</p>
      <div class="spacer"></div>
      <button class="btn btn-green" id="finish">Finish Session</button>
    </div>`;
  document.getElementById("back").onclick = () => go("missionChoice");
  document.getElementById("finish").onclick = finishSession;
}

function finishSession() {
  update({ timerRunning: false });
  go("missionComplete");
}

function renderMissionComplete() {
  const idx = state.currentPlanetIndex;
  const last = idx < 2;
  app.innerHTML = `
    <div class="screen ${planet(idx).scene}" style="justify-content:center;">
      ${starsHTML(60)}
      <h1>🎉 Mission Complete 🎉</h1>
      <p class="subtitle">${last ? "Next planet unlocked" : "Galaxy training complete"}</p>
      <p class="caption">Great job holding your mission target.</p>
      <button class="btn btn-cyan" id="next">${last ? "Launch Next Mission" : "Return to Dashboard"}</button>
    </div>`;
  document.getElementById("next").onclick = () => {
    if (last) go("launch");
    else go("dashboard");
  };
}

/* ================= GAMES ================= */

function renderGame() {
  const p = planet(state.currentPlanetIndex);
  const game = p.games.find(g => g.id === state.activeGame);
  ensureTimer();

  app.innerHTML = `
    <div class="screen ${p.scene}" id="gameScreen" style="padding:0; align-items:stretch;">
      <div class="topbar">
        <button class="back" id="back">← Back</button>
        <div class="info"><h2>${game.name}</h2><div class="count" id="scoreLabel">Score: 0</div></div>
        <div class="timer" data-timer>${formatTime(state.missionTimeRemaining)}</div>
      </div>
      <canvas id="canvas"></canvas>
      <div style="position:absolute; bottom:max(14px, env(safe-area-inset-bottom)); left:0; right:0; padding:0 18px;">
        <p class="caption" id="hint" style="background:rgba(0,0,0,0.45); border-radius:14px; padding:8px;"></p>
        <button class="btn btn-green" id="finish">Finish Session</button>
      </div>
    </div>`;

  document.getElementById("back").onclick = () => go("missionChoice");
  document.getElementById("finish").onclick = finishSession;

  const canvas = document.getElementById("canvas");
  const resize = () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  };
  resize();
  window.addEventListener("resize", resize);

  if (game.type === "tapCollect") startTapCollect(canvas, game);
  else if (game.type === "flappy") startFlappy(canvas, game);
  else if (game.type === "runner") startRunner(canvas, game);
  else if (game.type === "snake") startSnake(canvas, game);
}

function setScore(n) {
  const el = document.getElementById("scoreLabel");
  if (el) el.textContent = `Score: ${n}`;
}
function setHint(text) {
  const el = document.getElementById("hint");
  if (el) el.textContent = text;
}

/* ---- Tap & Collect (Alien Fishing, Reef Builder, Ice Crystal Dash, Penguin Rescue) ---- */
function startTapCollect(canvas, game) {
  const ctx = canvas.getContext("2d");
  let score = 0;
  let items = [];
  let lastSpawn = 0;
  setHint("Tap the glowing items as they appear. Avoid red-tinted ones.");

  function spawn() {
    const isAvoid = game.avoidEmoji && game.avoidEmoji.length && Math.random() < 0.25;
    const pool = isAvoid ? game.avoidEmoji : game.collectEmoji;
    items.push({
      x: 40 + Math.random() * (canvas.width - 80),
      y: -30,
      vy: 1.2 + Math.random() * 1.4,
      size: 40,
      emoji: pool[Math.floor(Math.random() * pool.length)],
      isAvoid
    });
  }

  function loop(ts) {
    if (!lastSpawn || ts - lastSpawn > 700) {
      spawn();
      lastSpawn = ts;
    }
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    items.forEach(it => it.y += it.vy);
    items = items.filter(it => it.y < canvas.height + 40);

    ctx.font = "40px serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    items.forEach(it => {
      ctx.save();
      if (it.isAvoid) {
        ctx.shadowColor = "red";
        ctx.shadowBlur = 14;
      } else {
        ctx.shadowColor = "cyan";
        ctx.shadowBlur = 14;
      }
      ctx.fillText(it.emoji, it.x, it.y);
      ctx.restore();
    });

    gameHandle.raf = requestAnimationFrame(loop);
  }

  function onTap(e) {
    const rect = canvas.getBoundingClientRect();
    const point = e.touches ? e.touches[0] : e;
    const x = point.clientX - rect.left;
    const y = point.clientY - rect.top;
    for (let i = items.length - 1; i >= 0; i--) {
      const it = items[i];
      if (Math.hypot(it.x - x, it.y - y) < 32) {
        if (it.isAvoid) score = Math.max(0, score - 1);
        else score += 1;
        setScore(score);
        items.splice(i, 1);
        break;
      }
    }
  }

  canvas.addEventListener("pointerdown", onTap);
  gameHandle = { raf: requestAnimationFrame(loop), interval: null };
  gameHandle.cleanup = () => canvas.removeEventListener("pointerdown", onTap);
  wrapCleanup();
}

/* ---- Flappy Manta ---- */
function startFlappy(canvas, game) {
  const ctx = canvas.getContext("2d");
  let birdY = canvas.height / 2;
  let vy = 0;
  const gravity = 0.45;
  const flapStrength = -7.5;
  let pillars = [];
  let score = 0;
  let running = true;
  const birdX = canvas.width * 0.25;
  const pillarWidth = 60;
  const baseGap = canvas.height * 0.32;

  setHint("Tap anywhere to flap. Avoid the coral pillars — the gaps get smaller as you score more.");

  function level() { return Math.floor(score / 5) + 1; }
  function speed() { return Math.min(2.4 + (level() - 1) * 0.4, 6); }
  function gapHeight() { return Math.max(baseGap - (level() - 1) * 14, canvas.height * 0.22); }

  function spawnPillar(x) {
    pillars.push({ x, gapY: 80 + Math.random() * (canvas.height - 160), gap: gapHeight(), passed: false });
  }
  spawnPillar(canvas.width * 0.9);
  spawnPillar(canvas.width * 1.4);
  spawnPillar(canvas.width * 1.9);

  function reset() {
    birdY = canvas.height / 2;
    vy = 0;
    score = 0;
    setScore(0);
    pillars = [];
    spawnPillar(canvas.width * 0.9);
    spawnPillar(canvas.width * 1.4);
    spawnPillar(canvas.width * 1.9);
    running = true;
  }

  function loop() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (running) {
      vy += gravity;
      birdY += vy;
      if (birdY < 24) { birdY = 24; vy = 0; }
      if (birdY > canvas.height - 24) { birdY = canvas.height - 24; vy = 0; }

      pillars.forEach(p => p.x -= speed());
      pillars.forEach(p => {
        if (!p.passed && p.x < birdX) { p.passed = true; score++; setScore(score); }
        const withinX = Math.abs(p.x - birdX) < (pillarWidth / 2 + 18);
        const withinGap = Math.abs(birdY - p.gapY) < (p.gap / 2 - 18);
        if (withinX && !withinGap) running = false;
      });
      pillars = pillars.filter(p => p.x > -pillarWidth);
      if (pillars.length && pillars[pillars.length - 1].x < canvas.width - 240) {
        spawnPillar(canvas.width + 60);
      }
    }

    // pillars
    ctx.fillStyle = "#d97ad9";
    pillars.forEach(p => {
      ctx.fillRect(p.x - pillarWidth / 2, 0, pillarWidth, p.gapY - p.gap / 2);
      ctx.fillRect(p.x - pillarWidth / 2, p.gapY + p.gap / 2, pillarWidth, canvas.height - (p.gapY + p.gap / 2));
    });

    // manta
    ctx.save();
    ctx.translate(birdX, birdY);
    ctx.rotate(Math.max(-0.4, Math.min(0.6, vy * 0.05)));
    ctx.font = "44px serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.shadowColor = "cyan";
    ctx.shadowBlur = 16;
    ctx.fillText("🦅", 0, 0);
    ctx.restore();

    if (!running) {
      ctx.fillStyle = "rgba(0,0,0,0.55)";
      ctx.fillRect(0, canvas.height / 2 - 60, canvas.width, 120);
      ctx.fillStyle = "white";
      ctx.font = "bold 28px sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(`Score: ${score} — Tap to retry`, canvas.width / 2, canvas.height / 2 - 5);
      ctx.font = "16px sans-serif";
      ctx.fillText(`Level ${level()}`, canvas.width / 2, canvas.height / 2 + 25);
    }

    gameHandle.raf = requestAnimationFrame(loop);
  }

  function onTap() {
    if (!running) { reset(); return; }
    vy = flapStrength;
  }

  canvas.addEventListener("pointerdown", onTap);
  gameHandle = { raf: requestAnimationFrame(loop), interval: null };
  gameHandle.cleanup = () => canvas.removeEventListener("pointerdown", onTap);
  wrapCleanup();
}

/* ---- Current Rider (lane runner) ---- */
function startRunner(canvas, game) {
  const ctx = canvas.getContext("2d");
  const laneX = [canvas.width * 0.25, canvas.width * 0.5, canvas.width * 0.75];
  let lane = 1;
  let items = [];
  let score = 0;
  let running = true;
  const playerY = canvas.height - 120;
  let lastSpawn = 0;
  let boost = false;

  setHint("Tap left or right side of the screen to switch lanes. Avoid obstacles, collect items.");

  function speed() { return (5 + Math.floor(score / 8)) * (boost ? 1.6 : 1); }

  function spawn() {
    const isObstacle = Math.random() < 0.55;
    const pool = isObstacle ? game.obstacleEmoji : game.collectEmoji;
    items.push({ lane: Math.floor(Math.random() * 3), y: -40, emoji: pool[Math.floor(Math.random() * pool.length)], isObstacle });
  }

  function reset() {
    items = [];
    score = 0;
    setScore(0);
    lane = 1;
    running = true;
    boost = false;
  }

  function loop(ts) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (running) {
      if (!lastSpawn || ts - lastSpawn > 600) { spawn(); lastSpawn = ts; }
      items.forEach(it => it.y += speed());

      items.forEach(it => {
        if (Math.abs(it.y - playerY) < 26 && it.lane === lane && !it.done) {
          it.done = true;
          if (it.isObstacle) {
            running = false;
          } else {
            score += 1;
            setScore(score);
            if (it.emoji === "💠") {
              boost = true;
              setTimeout(() => boost = false, 1500);
            }
          }
        }
      });
      items = items.filter(it => it.y < canvas.height + 40);
    }

    // lane guides
    ctx.strokeStyle = "rgba(255,255,255,0.15)";
    laneX.forEach(x => {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, canvas.height);
      ctx.stroke();
    });

    ctx.font = "40px serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    items.forEach(it => {
      ctx.save();
      ctx.shadowColor = it.isObstacle ? "red" : "cyan";
      ctx.shadowBlur = 12;
      ctx.fillText(it.emoji, laneX[it.lane], it.y);
      ctx.restore();
    });

    // player
    ctx.save();
    ctx.shadowColor = "cyan";
    ctx.shadowBlur = 16;
    ctx.font = "46px serif";
    ctx.fillText("🧑‍🚀", laneX[lane], playerY);
    ctx.restore();

    if (!running) {
      ctx.fillStyle = "rgba(0,0,0,0.55)";
      ctx.fillRect(0, canvas.height / 2 - 60, canvas.width, 120);
      ctx.fillStyle = "white";
      ctx.font = "bold 28px sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(`Score: ${score} — Tap to retry`, canvas.width / 2, canvas.height / 2);
    }

    gameHandle.raf = requestAnimationFrame(loop);
  }

  function onTap(e) {
    if (!running) { reset(); return; }
    const rect = canvas.getBoundingClientRect();
    const point = e.touches ? e.touches[0] : e;
    const x = point.clientX - rect.left;
    if (x < canvas.width / 2) lane = Math.max(0, lane - 1);
    else lane = Math.min(2, lane + 1);
  }

  canvas.addEventListener("pointerdown", onTap);
  gameHandle = { raf: requestAnimationFrame(loop), interval: null };
  gameHandle.cleanup = () => canvas.removeEventListener("pointerdown", onTap);
  wrapCleanup();
}

/* ---- Snake (Space Snake Rescue) ---- */
function startSnake(canvas, game) {
  const ctx = canvas.getContext("2d");
  const cell = 24;
  let cols, rows, snake, dir, nextDir, food, score, running, tickAcc;

  function reset() {
    cols = Math.floor(canvas.width / cell);
    rows = Math.floor((canvas.height - 80) / cell);
    snake = [{ x: Math.floor(cols / 2), y: Math.floor(rows / 2) }];
    dir = { x: 1, y: 0 };
    nextDir = dir;
    score = 0;
    setScore(0);
    running = true;
    tickAcc = 0;
    placeFood();
  }

  function placeFood() {
    food = { x: Math.floor(Math.random() * cols), y: Math.floor(Math.random() * rows) };
  }

  reset();
  setHint("Use the arrow buttons to steer the snake to the crystals. Avoid hitting yourself.");

  // D-pad
  const pad = document.createElement("div");
  pad.style.position = "absolute";
  pad.style.bottom = "90px";
  pad.style.left = "50%";
  pad.style.transform = "translateX(-50%)";
  pad.style.display = "grid";
  pad.style.gridTemplateColumns = "56px 56px 56px";
  pad.style.gridTemplateRows = "56px 56px 56px";
  pad.style.gap = "4px";
  pad.innerHTML = `
    <div></div><button class="btn btn-cyan" style="margin:0; padding:0;" data-dir="up">↑</button><div></div>
    <button class="btn btn-cyan" style="margin:0; padding:0;" data-dir="left">←</button><div></div><button class="btn btn-cyan" style="margin:0; padding:0;" data-dir="right">→</button>
    <div></div><button class="btn btn-cyan" style="margin:0; padding:0;" data-dir="down">↓</button><div></div>
  `;
  document.getElementById("gameScreen").appendChild(pad);
  const dirs = { up: { x: 0, y: -1 }, down: { x: 0, y: 1 }, left: { x: -1, y: 0 }, right: { x: 1, y: 0 } };
  pad.querySelectorAll("[data-dir]").forEach(btn => {
    btn.addEventListener("pointerdown", () => {
      const d = dirs[btn.dataset.dir];
      if (d.x !== -dir.x || d.y !== -dir.y) nextDir = d;
      if (!running) reset();
    });
  });

  function loop(ts) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    if (running) {
      tickAcc += 1;
      if (tickAcc >= 8) {
        tickAcc = 0;
        dir = nextDir;
        const head = { x: snake[0].x + dir.x, y: snake[0].y + dir.y };
        if (head.x < 0 || head.y < 0 || head.x >= cols || head.y >= rows || snake.some(s => s.x === head.x && s.y === head.y)) {
          running = false;
        } else {
          snake.unshift(head);
          if (head.x === food.x && head.y === food.y) {
            score++;
            setScore(score);
            placeFood();
          } else {
            snake.pop();
          }
        }
      }
    }

    // grid background
    ctx.fillStyle = "rgba(255,255,255,0.04)";
    for (let y = 0; y < rows; y++) for (let x = 0; x < cols; x++) if ((x + y) % 2 === 0) ctx.fillRect(x * cell, y * cell, cell, cell);

    // food
    ctx.font = `${cell}px serif`;
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText(game.collectEmoji, food.x * cell + cell / 2, food.y * cell + cell / 2);

    // snake
    ctx.fillStyle = "#4dd9e8";
    snake.forEach((s, i) => {
      ctx.globalAlpha = i === 0 ? 1 : 0.7;
      ctx.beginPath();
      ctx.roundRect(s.x * cell + 2, s.y * cell + 2, cell - 4, cell - 4, 6);
      ctx.fill();
    });
    ctx.globalAlpha = 1;

    if (!running) {
      ctx.fillStyle = "rgba(0,0,0,0.55)";
      ctx.fillRect(0, canvas.height / 2 - 60, canvas.width, 120);
      ctx.fillStyle = "white";
      ctx.font = "bold 28px sans-serif";
      ctx.fillText(`Score: ${score} — Tap a direction to retry`, canvas.width / 2, canvas.height / 2);
    }

    gameHandle.raf = requestAnimationFrame(loop);
  }

  gameHandle = { raf: requestAnimationFrame(loop), interval: null };
  gameHandle.cleanup = () => pad.remove();
  wrapCleanup();
}

/* Patch stopGameLoop to also call per-game cleanup */
const _stopGameLoop = stopGameLoop;
function wrapCleanup() {
  const original = gameHandle;
  stopGameLoop = function () {
    if (original && original.cleanup) original.cleanup();
    if (gameHandle) {
      cancelAnimationFrame(gameHandle.raf);
      clearInterval(gameHandle.interval);
      gameHandle = null;
    }
    stopGameLoop = _stopGameLoop;
  };
}

/* ---------------- Init ---------------- */
render();
