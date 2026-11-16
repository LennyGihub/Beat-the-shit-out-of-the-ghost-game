# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 61 files · ~106,469 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 759 nodes · 2054 edges · 30 communities (22 shown, 8 thin omitted)
- Extraction: 82% EXTRACTED · 18% INFERRED · 0% AMBIGUOUS · INFERRED: 368 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `14c0a084`
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
- RoomPickUI.luau
- Fury.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 27 edges
7. `Sfx.play()` - 25 edges
8. `moving()` - 20 edges
9. `PlaneFx.crash()` - 19 edges
10. `Input.init()` - 19 edges

## Surprising Connections (you probably didn't know these)
- `LobbyUI.invite()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/LobbyUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Shop.result()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/UltShopUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Run.startFight()` --calls--> `Combat.healAll()`  [INFERRED]
  game/ServerScriptService/Server/Run.luau → game/ServerScriptService/Server/Combat.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (30 total, 8 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.20
Nodes (21): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+13 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.13
Nodes (31): HUD.banner(), HUD.flash(), blackout(), disc(), emitter(), enrage(), gassed(), jumpscare() (+23 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.08
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.09
Nodes (41): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+33 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.07
Nodes (41): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh() (+33 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.15
Nodes (33): burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts(), Ghost.burn() (+25 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.07
Nodes (50): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+42 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.14
Nodes (30): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+22 more)

### Community 12 - "Events.luau"
Cohesion: 0.21
Nodes (23): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+15 more)

### Community 13 - "Run.luau"
Cohesion: 0.06
Nodes (51): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+43 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.11
Nodes (18): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+10 more)

### Community 18 - "Input.luau"
Cohesion: 0.13
Nodes (27): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+19 more)

### Community 19 - "HUD.luau"
Cohesion: 0.12
Nodes (22): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+14 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.13
Nodes (15): Abilities.cloneCount(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.step(), flat() (+7 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.22
Nodes (21): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+13 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.12
Nodes (30): Abilities.clear(), Evolved.dress(), Evolved.interrupt(), Evolved.onSpawn(), Fire.clear(), bringBack(), claw(), die() (+22 more)

### Community 24 - "Combat.luau"
Cohesion: 0.20
Nodes (7): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.start(), Furniture.weight(), ult()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.restoreWalls() (+3 more)

### Community 26 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 27 - "Fury.luau"
Cohesion: 0.32
Nodes (6): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp()

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.104) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12762762762762764 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.058) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07575757575757576 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `UltFx.luau` to `Viewmodel.luau`, `LobbyUI.luau`, `CineKit.luau`, `AdminPanel.luau`, `Input.luau`, `RoomPickUI.luau`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08708272859216255 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06862745098039216 - nodes in this community are weakly interconnected._