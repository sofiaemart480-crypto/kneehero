// Planet container — add a new planet by pushing a new object onto PLANETS.
// Each game's `type` maps to a generic engine in app.js (tapCollect, flappy, runner, snake).
const PLANETS = [
  {
    id: 0,
    name: "Aurora Shores",
    subtitle: "Crystal Lagoon",
    scene: "scene-aurora",
    games: [
      {
        id: "alienFishing",
        name: "Alien Fishing",
        type: "tapCollect",
        emoji: "🎣",
        collectEmoji: ["🐟", "🐡", "🐠"],
        avoidEmoji: ["🦑"],
        color: "blue",
        desc: "Tap the alien fish as they drift down. Watch out for squid — tapping them costs a point."
      },
      {
        id: "spaceSnake",
        name: "Space Snake Rescue",
        type: "snake",
        emoji: "🐍",
        collectEmoji: "💠",
        color: "purple",
        desc: "Steer the rescue snake to collect glowing crystals. Don't run into yourself!"
      }
    ]
  },
  {
    id: 1,
    name: "Oceanus Prime",
    subtitle: "Coral City Reef",
    scene: "scene-oceanus",
    games: [
      {
        id: "flappyManta",
        name: "Flappy Manta",
        type: "flappy",
        emoji: "🐠",
        color: "blue",
        desc: "Tap to glide the manta ray through the coral gaps. Difficulty increases with your score."
      },
      {
        id: "reefBuilder",
        name: "Reef Builder",
        type: "tapCollect",
        emoji: "🪸",
        collectEmoji: ["🪸", "🐚", "⭐"],
        avoidEmoji: ["🦈"],
        color: "purple",
        desc: "Tap glowing coral pieces to build the reef. Avoid tapping sharks."
      },
      {
        id: "currentRider",
        name: "Current Rider",
        type: "runner",
        emoji: "🌊",
        color: "cyan",
        obstacleEmoji: ["🪨", "🦈", "🚢", "⚡", "🐙"],
        collectEmoji: ["🫧", "💠", "🗝️"],
        desc: "Dodge rocks, sharks, lasers, broken subs and tentacles. Collect oxygen cells, energy shards and ancient keys."
      }
    ]
  },
  {
    id: 2,
    name: "Frost Nova",
    subtitle: "Crystal Glacier Caves",
    scene: "scene-frost",
    games: [
      {
        id: "iceCrystalDash",
        name: "Ice Crystal Dash",
        type: "tapCollect",
        emoji: "💎",
        collectEmoji: ["💎", "❄️", "✨"],
        avoidEmoji: [],
        color: "cyan",
        desc: "Tap the glowing crystals before they fade away."
      },
      {
        id: "penguinRescue",
        name: "Penguin Rescue",
        type: "tapCollect",
        emoji: "🐧",
        collectEmoji: ["🐧"],
        avoidEmoji: [],
        color: "blue",
        desc: "Tap the alien penguins to send them home to the colony."
      }
    ]
  }
];

// Default treatment plan (degrees of knee extension target per session, minutes to hold)
const DEFAULT_PLAN = {
  session1Angle: 30,
  session2Angle: 60,
  session3Angle: 90,
  holdMinutes: 5
};
