# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 66 files · ~115,458 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 789 nodes · 2153 edges · 39 communities (28 shown, 11 thin omitted)
- Extraction: 82% EXTRACTED · 18% INFERRED · 0% AMBIGUOUS · INFERRED: 397 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7ee7ce9f`
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
- Fire.luau
- Ragdoll.luau
- Fx.luau
- RoomPickUI.luau
- SawAudio.luau
- Fury.luau
- Ghost.spawn
- Settings.luau
- HUD.luau
- refresh
- Client/Vip.luau
- CrewAnim.luau

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
- `Vip.start()` --calls--> `onPlayer()`  [INFERRED]
  game/ServerScriptService/Server/Vip.luau → game/ServerScriptService/Main.server.luau
- `layoutBars()` --calls--> `Platform.mode()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau

## Import Cycles
- None detected.

## Communities (39 total, 11 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.22
Nodes (19): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+11 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.13
Nodes (29): HUD.banner(), HUD.flash(), blackout(), disc(), enrage(), gassed(), jumpscare(), lightsOut() (+21 more)

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
Cohesion: 0.13
Nodes (34): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), Combat.start(), Furniture.weight(), Ghost.freeze() (+26 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (49): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+41 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.14
Nodes (30): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+22 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.luau"
Cohesion: 0.07
Nodes (51): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Inventory.clear(), Inventory.clearWorld() (+43 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 19 - "HUD.luau"
Cohesion: 0.42
Nodes (9): liftHint(), firstButton(), navStep(), openMenu(), Platform.init(), Platform.label(), Platform.mode(), setMode() (+1 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.14
Nodes (25): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+17 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (16): Abilities.cloneCount(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt(), Evolved.step() (+8 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.20
Nodes (24): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+16 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.19
Nodes (19): bringBack(), claw(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.launch(), Ghost.setVortex(), Ghost.slow() (+11 more)

### Community 24 - "Fire.luau"
Cohesion: 0.07
Nodes (20): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), burningNear(), closestPoint(), Fire.clear() (+12 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "Fx.luau"
Cohesion: 0.14
Nodes (5): Fx.applyZone(), Fx.init(), UltFx.init(), Shop.result(), VM.setShake()

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 30 - "Fury.luau"
Cohesion: 0.32
Nodes (6): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp()

### Community 31 - "Ghost.spawn"
Cohesion: 0.20
Nodes (11): Abilities.clear(), Evolved.dress(), Evolved.onSpawn(), die(), Ghost.despawn(), Ghost.spawn(), structParams(), teamSize() (+3 more)

### Community 32 - "Settings.luau"
Cohesion: 0.44
Nodes (7): apply(), load(), save(), Settings.bind(), Settings.init(), Settings.reset(), Settings.set()

### Community 34 - "HUD.luau"
Cohesion: 0.33
Nodes (4): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint()

### Community 35 - "refresh"
Cohesion: 0.48
Nodes (6): KeyHints.init(), refresh(), toggle(), Settings.get(), Settings.keyName(), Settings.setFlag()

### Community 36 - "Client/Vip.luau"
Cohesion: 0.60
Nodes (5): HUD.toast(), door(), doors(), isVip(), Vip.init()

## Knowledge Gaps
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12773109243697478 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11515151515151516 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.061569416498993966 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1294871794871795 - nodes in this community are weakly interconnected._