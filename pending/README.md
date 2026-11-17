# Pending: scripts that are on GitHub but not yet saved from Studio

`pending/src/` holds scripts written while the Studio bridge was off (ngrok's monthly bandwidth ran out on
2026-11-17, `403 ERR_NGROK_725`, back on 2026-12-01). Same layout as `game/`. The current code of the game is
`game/` with `pending/src/` copied over it.

## Getting them into Studio

On the PC, with Studio open in Edit mode: start `roblox-mcp-bridge/start-bridge.bat`. Its **GitHub sync** window
(`pull-from-github.js`) writes every pending script into Studio, without any tunnel. Then save the place.

When a cloud session can reach Studio again:

```bash
tools/save_game.sh "game: ultimates' new animations + sandbox"
```

Then delete `pending/`.

## What is in here

**1. Every ultimate has its own cast animation and blocky effects** (UltKit, UltActs, UltFx, UltPose, Viewmodel,
Fx, GhostAnim, Ultimates, UltRunner, Combat, Ghost, Admin). Deployed and playtested on 2026-11-17, except three
late edits that are only syntax-checked: `Combat.endUltimate`, the admin command `ult <id>` ending a running
ultimate first, Exploding Fists' pops keeping their distance in the caster's own view.

- 27 of the 50 ultimates were cast in the playtest, with no script errors. Photographed and checked: all 20
  first-person hand animations, the third-person poses, the wind-up, the shockwave styles, lightning, the meteor's
  target, the holy beam, the nuke, the ice prison, the time stop clock, the black hole.
- Ran without errors but not looked at from outside: the uppercut's trail and landing, Heavy Hands' iron blocks,
  furniture streaks, the burn, heal and stamina effects, the giant's growth, the auras.
- Never ran: the tornado (Furniture Tornado), Bullet Time, Blood Moon's moon, Exploding Fists' pops, Berserk God's
  arcs, God Mode's pillar and halo, the One Punch hit, time resuming after a time stop.

**2. The sandbox** (Sandbox, SandboxUI, Run, Ghost, Combat, Quests, Remotes, Main, ClientMain, UltShopUI, HUD, Fx).
Written with the bridge off: syntax-checked and read through, NEVER run. To check in a playtest:

- Shop: pick an ultimate, TRY NOW ! puts you in the Mansion with the Woman; she stands still, turns to you, never
  attacks, takes damage; knocked out, a new one appears in the middle of the house about 3 s later.
- Q fires the ultimate on trial (owned or not); brutality refills in 1.5 s; ULTIMATES [U] reopens the shop and
  TRY NOW ! there switches the ultimate.
- LEAVE [L] (grey, top middle) brings you back to the park; the house is cleared when the last player leaves.
- No cash, kills or quest progress from the sandbox; the front door stays shut; dying there puts you back in the
  house.
- Two players at once share the dummy; players in the park see and hear nothing of it.

`tools/ult_shots/` has the scripts that photograph an ultimate (see `run.sh`).
