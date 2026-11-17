# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 76 files · ~153,698 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 942 nodes · 2562 edges · 48 communities (35 shown, 13 thin omitted)
- Extraction: 82% EXTRACTED · 18% INFERRED · 0% AMBIGUOUS · INFERRED: 472 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1c1f8bfc`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- UltFx.luau
- ItemModels.luau
- Data.luau
- Viewmodel.luau
- Inventory.luau
- LobbyUI.luau
- CineKit.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- GhostAnim.luau
- HUD.luau
- GoblinLoot.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Admin.luau
- Ragdoll.luau
- Fx.luau
- RoomPickUI.luau
- SawAudio.luau
- Fury.luau
- Abilities.clear
- Settings.luau
- src/ServerScriptService/Server/Run.luau
- MonsterFx.handle
- Client/Vip.luau
- CrewAnim.luau
- src/ServerScriptService/Server/Abilities.luau
- src/ServerScriptService/Server/Evolved.luau
- script_parent_grunge
- MapLoader.luau
- Main.server.luau
- src/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- ReviveUI.luau
- Friends.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 28 edges
7. `Sfx.play()` - 26 edges
8. `Furniture.smash()` - 20 edges
9. `moving()` - 20 edges
10. `MonsterFx.handle()` - 19 edges

## Surprising Connections (you probably didn't know these)
- `Run.removeFromMatch()` --calls--> `Inventory.clear()`  [INFERRED]
  pending/src/ServerScriptService/Server/Run.luau → game/ServerScriptService/Server/Inventory.luau
- `layoutBars()` --calls--> `Platform.mode()`  [INFERRED]
  pending/src/StarterPlayer/StarterPlayerScripts/Client/HUD.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau
- `Abilities.try()` --calls--> `Furniture.flingAt()`  [INFERRED]
  pending/src/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/Furniture.luau
- `Abilities.try()` --calls--> `Furniture.nearest()`  [INFERRED]
  pending/src/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/Furniture.luau
- `Abilities.try()` --calls--> `Loot.try()`  [INFERRED]
  pending/src/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau

## Import Cycles
- None detected.

## Communities (48 total, 13 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.19
Nodes (22): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+14 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.16
Nodes (30): HUD.banner(), HUD.flash(), beamOff(), beamTo(), blackout(), disc(), emitter(), enrage() (+22 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (41): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+33 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.06
Nodes (59): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+51 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (46): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), Combat.start(), burningNear(), closestPoint() (+38 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.10
Nodes (41): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+33 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.18
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.21
Nodes (23): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock() (+15 more)

### Community 13 - "Run.luau"
Cohesion: 0.15
Nodes (31): Lobby.returnPlayer(), Monetization.start(), Quests.add(), aliveCount(), aliveIn(), cashMult(), checkWipe(), clearTemp() (+23 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 19 - "HUD.luau"
Cohesion: 0.22
Nodes (13): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep(), openMenu() (+5 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.15
Nodes (27): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+19 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.dress(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.22
Nodes (24): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+16 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.16
Nodes (25): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze(), Ghost.launch() (+17 more)

### Community 24 - "Admin.luau"
Cohesion: 0.17
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (11): breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.restoreWalls(), Ragdoll.start() (+3 more)

### Community 26 - "Fx.luau"
Cohesion: 0.12
Nodes (8): Fx.applyZone(), Fx.init(), bezier(), UltFx.init(), Shop.result(), VM.setShake(), Fx.applyZone(), Fx.init()

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "SawAudio.luau"
Cohesion: 0.20
Nodes (12): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+4 more)

### Community 30 - "Fury.luau"
Cohesion: 0.32
Nodes (6): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp()

### Community 31 - "Abilities.clear"
Cohesion: 0.67
Nodes (3): Abilities.clear(), Loot.clear(), Abilities.clear()

### Community 32 - "Settings.luau"
Cohesion: 0.25
Nodes (13): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.get() (+5 more)

### Community 34 - "src/ServerScriptService/Server/Run.luau"
Cohesion: 0.12
Nodes (29): Friends.mult(), Ghost.despawn(), Inventory.clearWorld(), aliveCount(), aliveIn(), cashMult(), checkWipe(), clearTemp() (+21 more)

### Community 35 - "MonsterFx.handle"
Cohesion: 0.13
Nodes (26): Settings.group(), make(), Sfx.voice(), HUD.banner(), HUD.flash(), beamOff(), beamTo(), blackout() (+18 more)

### Community 36 - "Client/Vip.luau"
Cohesion: 0.60
Nodes (5): HUD.toast(), door(), doors(), isVip(), Vip.init()

### Community 39 - "src/ServerScriptService/Server/Abilities.luau"
Cohesion: 0.20
Nodes (24): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+16 more)

### Community 40 - "src/ServerScriptService/Server/Evolved.luau"
Cohesion: 0.12
Nodes (15): Abilities.cloneCount(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.step(), flat() (+7 more)

### Community 41 - "script_parent_grunge"
Cohesion: 0.15
Nodes (7): layout(), make(), TC.init(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint()

### Community 42 - "MapLoader.luau"
Cohesion: 0.20
Nodes (13): Events.despawn(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+5 more)

### Community 43 - "Main.server.luau"
Cohesion: 0.15
Nodes (5): onPlayer(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Vip.start()

### Community 44 - "src/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 46 - "ReviveUI.luau"
Cohesion: 0.47
Nodes (5): Platform.menu(), productId(), ReviveUI.handle(), ReviveUI.init(), Shop.open()

## Knowledge Gaps
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `SawAudio.luau`, `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11945031712473574 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.061569416498993966 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08636363636363636 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.10283687943262411 - nodes in this community are weakly interconnected._