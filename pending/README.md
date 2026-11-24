# Pending scripts (2026-11-24) - NOT PLAYTESTED

The Studio bridge was off (the dev tunnel answered 404, then timed out), so these 31 scripts were written and
syntax-checked in the cloud, but **nobody has run them in Studio yet**. The PC's "GitHub sync" window
(`roblox-mcp-bridge/pull-from-github.js`, Studio in Edit mode) writes them into the open Studio by itself.
Current code = `game/` with `pending/src/` copied over it.

Pure logic was run with the Luau runtime (`~/.cache/luau/luau`, small stubs): the endless fix (300 waves; the old
code crashes exactly as reported), Server/Guard (buckets, NaN / inf), Client/Translate (patterns with a fake French
translator). Everything else is untested.

## What is in it
- FIX: endless runs froze on a boss wave (Run.startFight / Shared/Monsters).
- Server/Analytics + calls in Data, Tutorial, Forms, Lobby, Run, Quests, Codes, Admin, Bestiary, Trade, Monetization.
- INVITE: Server/Share, Client/ShareUI, the 7th lobby button (Client/LobbyUI), Data `Ref`, Remotes.Share, admin `ref`.
- Server/Guard on every remote handler + 3 NaN holes (Inventory.onUse, Tutorial spawn, party size).
- Phones start on LOW particles (Client/Settings + Data.cleanSettings `fxSet`).
- Client/Translate (HUD toast + objective, SellerUI, FormTutorial).
- Controller: SELECT reaches the lobby column (Client/LobbyUI).
- Main: R6 spawn warning. Patch notes: 3 new entries.

## When the bridge is back (in this order)
1. `tools/studio.py state`, Edit mode. Check Studio has these scripts (the sync ran) or push them:
   `python3 tools/deploy_luau.py --root pending/src $(cd pending/src && find . -name "*.luau")`.
2. Playtest: console clean on start; an ENDLESS run (admin `start Mansion Normal`, then `next` past wave 3, 6, 9)
   keeps spawning; the intro still runs (DebugAutoTutorial) and ServerScriptService `AnalyticsLog` fills; INVITE
   window (`DebugInvite`), the left column with 7 buttons (screenshot: does it fit?), `DebugMoment`; a trade with
   `trade bot`; jars x10; a campaign building start / clear.
3. R15: read a player's Humanoid.RigType in the playtest; set Game Settings > Avatar to R15 if it is not.
4. `tools/build/perf_pass.luau` (report), then with `APPLY = true`.
5. `tools/save_game.sh "game: ..."`, then delete `pending/`.
