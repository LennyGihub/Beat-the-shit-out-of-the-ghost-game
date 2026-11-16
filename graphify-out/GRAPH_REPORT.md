# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 61 files · ~109,205 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 766 nodes · 2081 edges · 28 communities (20 shown, 8 thin omitted)
- Extraction: 82% EXTRACTED · 18% INFERRED · 0% AMBIGUOUS · INFERRED: 377 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `10fb743f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Viewmodel.luau
- Inventory.luau
- LobbyUI.luau
- CineKit.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Input.luau
- HUD.luau
- GoblinLoot.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Combat.luau
- Ragdoll.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 27 edges
7. `Sfx.play()` - 26 edges
8. `moving()` - 20 edges
9. `Input.init()` - 19 edges
10. `PlaneFx.crash()` - 19 edges

## Surprising Connections (you probably didn't know these)
- `Run.startFight()` --calls--> `Combat.healAll()`  [INFERRED]
  game/ServerScriptService/Server/Run.luau → game/ServerScriptService/Server/Combat.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `punch()` --calls--> `VM.punch()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau

## Import Cycles
- None detected.

## Communities (28 total, 8 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.20
Nodes (21): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+13 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.13
Nodes (28): HUD.banner(), HUD.flash(), blackout(), disc(), enrage(), gassed(), jumpscare(), lightsOut() (+20 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.08
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.08
Nodes (40): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+32 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.06
Nodes (45): Fx.applyZone(), Fx.init(), Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse() (+37 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (45): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), burningNear(), closestPoint(), Fire.clear() (+37 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.06
Nodes (62): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+54 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.14
Nodes (30): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+22 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.luau"
Cohesion: 0.10
Nodes (41): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Ghost.despawn(), Inventory.clearWorld(), Lobby.returnPlayer() (+33 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.14
Nodes (22): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+14 more)

### Community 18 - "Input.luau"
Cohesion: 0.13
Nodes (27): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+19 more)

### Community 19 - "HUD.luau"
Cohesion: 0.12
Nodes (22): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+14 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.15
Nodes (28): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp(), attach(), clearLine() (+20 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (16): Abilities.cloneCount(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt(), Evolved.step() (+8 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.19
Nodes (23): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+15 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.15
Nodes (26): Evolved.dress(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage() (+18 more)

### Community 24 - "Combat.luau"
Cohesion: 0.18
Nodes (7): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.start(), Furniture.weight(), ult()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.35
Nodes (10): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+2 more)

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1319073083778966 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07575757575757576 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `LobbyUI.luau` to `CineKit.luau`, `UltFx.luau`, `Input.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07622504537205081 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05552617662612375 - nodes in this community are weakly interconnected._