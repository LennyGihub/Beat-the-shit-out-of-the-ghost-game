# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 66 files · ~118,866 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 793 nodes · 2168 edges · 42 communities (32 shown, 10 thin omitted)
- Extraction: 82% EXTRACTED · 18% INFERRED · 0% AMBIGUOUS · INFERRED: 399 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `700972e5`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Input.luau
- Inventory.luau
- LobbyUI.luau
- CineKit.luau
- Events.luau
- game/ServerScriptService/Server/Run.luau
- AdminPanel.luau
- GhostAnim.luau
- Viewmodel.luau
- GoblinLoot.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Admin.luau
- Ragdoll.luau
- game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau
- RoomPickUI.luau
- Sfx.play
- Fury.luau
- Furniture.near
- Settings.luau
- Run.startFight
- checkThrown
- CrewAnim.luau
- MapLoader.luau
- Main.server.luau
- script_parent_grunge
- Friends.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 27 edges
7. `Sfx.play()` - 26 edges
8. `moving()` - 20 edges
9. `MonsterFx.handle()` - 19 edges
10. `Input.init()` - 19 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `MonsterFx.handle()` --calls--> `Sfx.voice()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau

## Import Cycles
- None detected.

## Communities (42 total, 10 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.30
Nodes (14): Furniture.smash(), Ghost.burn(), Ghost.damage(), Ghost.hit(), Ghost.setVortex(), Ghost.slow(), barrage(), ghostPos() (+6 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.16
Nodes (30): HUD.banner(), HUD.flash(), beamOff(), beamTo(), blackout(), disc(), emitter(), enrage() (+22 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.07
Nodes (18): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+10 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (41): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+33 more)

### Community 5 - "Input.luau"
Cohesion: 0.13
Nodes (27): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+19 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (40): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite() (+32 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.10
Nodes (43): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+35 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (29): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.21
Nodes (23): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock() (+15 more)

### Community 13 - "game/ServerScriptService/Server/Run.luau"
Cohesion: 0.19
Nodes (13): Monetization.start(), aliveCount(), aliveIn(), checkWipe(), doorPrompt(), endDeath(), respawnSpectators(), Run.extendRevive() (+5 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 19 - "Viewmodel.luau"
Cohesion: 0.14
Nodes (19): addTrail(), ease(), itemOffset(), mirror(), mk(), punchOffset(), sample(), solveHold() (+11 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.19
Nodes (24): Fury.tick(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), land() (+16 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.13
Nodes (15): Abilities.cloneCount(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.step(), flat() (+7 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.20
Nodes (24): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+16 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.12
Nodes (28): Abilities.clear(), Evolved.dress(), Evolved.interrupt(), Evolved.onSpawn(), bringBack(), die(), floorBelow(), Ghost.alive() (+20 more)

### Community 24 - "Admin.luau"
Cohesion: 0.18
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.33
Nodes (10): breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start(), Ragdoll.step() (+2 more)

### Community 26 - "game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau"
Cohesion: 0.15
Nodes (7): Fx.applyZone(), Fx.init(), clear(), selectedId(), step(), UltFx.init(), VM.setShake()

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 30 - "Fury.luau"
Cohesion: 0.31
Nodes (7): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.windUp(), claw(), warded()

### Community 31 - "Furniture.near"
Cohesion: 0.35
Nodes (9): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+1 more)

### Community 32 - "Settings.luau"
Cohesion: 0.09
Nodes (28): KeyHints.init(), refresh(), toggle(), oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used() (+20 more)

### Community 34 - "Run.startFight"
Cohesion: 0.24
Nodes (17): Events.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), Quests.add(), clearTemp(), hrpOf(), insideHouse(), onBuy() (+9 more)

### Community 35 - "checkThrown"
Cohesion: 0.60
Nodes (5): checkThrown(), checkThrownPlayers(), Combat.start(), Furniture.weight(), ult()

### Community 42 - "MapLoader.luau"
Cohesion: 0.29
Nodes (10): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+2 more)

### Community 43 - "Main.server.luau"
Cohesion: 0.14
Nodes (6): onPlayer(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running(), Vip.start()

### Community 46 - "script_parent_grunge"
Cohesion: 0.21
Nodes (4): productId(), ReviveUI.handle(), ReviveUI.init(), Shop.result()

### Community 47 - "Friends.luau"
Cohesion: 0.33
Nodes (5): areFriends(), Friends.mult(), refresh(), cashMult(), Run.payout()

## Knowledge Gaps
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau`, `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06871035940803383 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11945031712473574 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13109243697478992 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09568627450980392 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09714285714285714 - nodes in this community are weakly interconnected._