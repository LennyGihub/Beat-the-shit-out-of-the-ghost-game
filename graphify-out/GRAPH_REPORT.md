# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 47 files · ~73,672 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 561 nodes · 1526 edges · 23 communities (15 shown, 8 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 230 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3fd9763e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Viewmodel.luau
- Inventory.luau
- LobbyUI.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Abilities.luau
- Input.luau
- GoblinLoot.luau
- Admin.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 22 edges
7. `moving()` - 20 edges
8. `Abilities.step()` - 16 edges
9. `Sfx.play()` - 16 edges
10. `Furniture.smash()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `stock()` --calls--> `ItemModels.build()`  [INFERRED]
  game/ServerScriptService/Server/Events.luau → game/ReplicatedStorage/Shared/ItemModels.luau
- `attach()` --calls--> `ItemModels.build()`  [INFERRED]
  game/ServerScriptService/Server/GoblinLoot.luau → game/ReplicatedStorage/Shared/ItemModels.luau
- `step()` --calls--> `ItemModels.animate()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/ThirdPersonItems.luau → game/ReplicatedStorage/Shared/ItemModels.luau

## Import Cycles
- None detected.

## Communities (23 total, 8 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.08
Nodes (56): checkThrown(), checkThrownPlayers(), Fire.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near() (+48 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.12
Nodes (25): HUD.banner(), HUD.flash(), HUD.toast(), HUD.update(), updateWaypoint(), blackout(), disc(), emitter() (+17 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (55): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+47 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.39
Nodes (5): abilityPose(), bind(), GA.update(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.16
Nodes (29): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsMap() (+21 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.07
Nodes (38): ItemModels.build(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), refresh(), setSpray() (+30 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.13
Nodes (35): Combat.playerNear(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts() (+27 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (43): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), frame(), Grunge.bar() (+35 more)

### Community 12 - "Events.luau"
Cohesion: 0.31
Nodes (16): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+8 more)

### Community 13 - "Run.luau"
Cohesion: 0.08
Nodes (42): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Ghost.despawn(), Inventory.clearWorld() (+34 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.23
Nodes (19): Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+11 more)

### Community 19 - "Input.luau"
Cohesion: 0.21
Nodes (11): Combat.start(), HUD.hint(), aimedFurniture(), grab(), Input.init(), look(), punch(), setSprint() (+3 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (21): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.drop() (+13 more)

### Community 22 - "Admin.luau"
Cohesion: 0.07
Nodes (11): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Combat.healAll(), Combat.refreshHealth(), Fx.applyZone() (+3 more)

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.138) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07785547785547786 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12477718360071301 - nodes in this community are weakly interconnected._
- **Why does `attach()` connect `GoblinLoot.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07358156028368794 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13205128205128205 - nodes in this community are weakly interconnected._