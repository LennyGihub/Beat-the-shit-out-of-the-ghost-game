# Pending scripts (not in Studio yet)

Written on 2026-11-20 while the Studio bridge was off (the tunnel answered 404). The PC's "GitHub sync" window
(`roblox-mcp-bridge/pull-from-github.js`) writes these into the open Studio by itself. **Nothing here was playtested.**

- `StarterPlayer/StarterPlayerScripts/Client/FormSets.luau` (NEW): every map's jars / potions get their own layer
  round the wearer in the park, bigger map after map (Camp fireflies / embers, Carnival marquee bulbs, Harbor water
  vortex, Abbey wings of light; the Black Moon keeps its giant, Client/FormGiant).
- `StarterPlayer/StarterPlayerScripts/Client/FormLook.luau`: calls FormSets; a later map's form is stronger in the
  base look too (tierBoost 1 .. 1.88: particle sizes, rates, lights, the put-on burst).
- `StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`: no sound on every step any more, and the distance to
  Doc Mercy / Mother Moth has its own fixed-size label (the instruction no longer pops each time you move).

When the bridge is back: playtest them (admin `form <id>` with one form of each map), fix what looks off, run
`tools/save_game.sh`, then delete `pending/`.
