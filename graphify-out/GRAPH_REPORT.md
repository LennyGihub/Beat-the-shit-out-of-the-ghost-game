# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 58 files · ~97,229 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 698 nodes · 1889 edges · 23 communities (15 shown, 8 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 300 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1f9da4a4`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
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
- RoomPickUI.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 25 edges
7. `Sfx.play()` - 23 edges
8. `moving()` - 20 edges
9. `Input.init()` - 19 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Abilities.try()` --calls--> `Loot.try()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau
- `Abilities.step()` --calls--> `Loot.step()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau

## Import Cycles
- None detected.

## Communities (23 total, 8 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.06
Nodes (79): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try() (+71 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.09
Nodes (42): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.banner(), HUD.flash() (+34 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.08
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.10
Nodes (40): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+32 more)

### Community 5 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.15
Nodes (32): burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts(), Ghost.burn() (+24 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (48): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+40 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.luau"
Cohesion: 0.05
Nodes (56): onPlayer(), checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.start(), Events.despawn(), areFriends() (+48 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.14
Nodes (18): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), build(), button(), cmd() (+10 more)

### Community 18 - "Input.luau"
Cohesion: 0.05
Nodes (60): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+52 more)

### Community 19 - "HUD.luau"
Cohesion: 0.12
Nodes (22): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+14 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.14
Nodes (25): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.clear() (+17 more)

### Community 21 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Input.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.117) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.056100981767180924 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Input.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08521870286576169 - nodes in this community are weakly interconnected._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07575757575757576 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09795918367346938 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07720782654680064 - nodes in this community are weakly interconnected._