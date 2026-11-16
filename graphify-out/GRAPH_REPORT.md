# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 60 files · ~102,934 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 738 nodes · 1967 edges · 30 communities (21 shown, 9 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 313 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1891dde4`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- SawAudio.luau
- Inventory.luau
- LobbyUI.luau
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
- Ghost.spawn
- Fury.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 27 edges
7. `Sfx.play()` - 24 edges
8. `moving()` - 20 edges
9. `Input.init()` - 19 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `Ghost.spawn()` --calls--> `Ragdoll.restoreWalls()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Run.startFight()` --calls--> `Combat.healAll()`  [INFERRED]
  game/ServerScriptService/Server/Run.luau → game/ServerScriptService/Server/Combat.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (30 total, 9 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.23
Nodes (18): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+10 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.10
Nodes (39): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.banner(), HUD.flash() (+31 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.08
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.09
Nodes (40): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+32 more)

### Community 5 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.14
Nodes (34): burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts(), Ghost.burn() (+26 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.06
Nodes (61): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+53 more)

### Community 12 - "Events.luau"
Cohesion: 0.14
Nodes (25): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+17 more)

### Community 13 - "Run.luau"
Cohesion: 0.08
Nodes (49): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Inventory.clearWorld(), Lobby.returnPlayer() (+41 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.07
Nodes (23): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), build(), button(), cmd() (+15 more)

### Community 18 - "Input.luau"
Cohesion: 0.06
Nodes (56): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+48 more)

### Community 19 - "HUD.luau"
Cohesion: 0.12
Nodes (22): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+14 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.20
Nodes (23): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+15 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (16): Abilities.cloneCount(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt(), Evolved.step() (+8 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.22
Nodes (21): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+13 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.19
Nodes (19): bringBack(), claw(), floorBelow(), Ghost.alive(), Ghost.freeze(), Ghost.launch(), Ghost.setVortex(), Ghost.slow() (+11 more)

### Community 24 - "Combat.luau"
Cohesion: 0.18
Nodes (7): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.start(), Furniture.weight(), ult()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.restoreWalls() (+3 more)

### Community 26 - "Ghost.spawn"
Cohesion: 0.22
Nodes (10): Abilities.clear(), Evolved.dress(), Evolved.onSpawn(), Fire.clear(), die(), Ghost.despawn(), Ghost.spawn(), structParams() (+2 more)

### Community 27 - "Fury.luau"
Cohesion: 0.32
Nodes (6): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp()

## Knowledge Gaps
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Input.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.112) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09805735430157261 - nodes in this community are weakly interconnected._
- **Why does `attach()` connect `GoblinLoot.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07575757575757576 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08635703918722787 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1422475106685633 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.059940059940059943 - nodes in this community are weakly interconnected._