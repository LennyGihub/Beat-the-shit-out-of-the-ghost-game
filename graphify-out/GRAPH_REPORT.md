# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 47 files · ~72,811 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 560 nodes · 1523 edges · 22 communities (14 shown, 8 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 230 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `bb1b35f3`
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
- Fx.luau
- GoblinLoot.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 22 edges
7. `moving()` - 21 edges
8. `Abilities.step()` - 16 edges
9. `Sfx.play()` - 16 edges
10. `Furniture.smash()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `setState()` --calls--> `Abilities.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Abilities.luau
- `Abilities.try()` --calls--> `Furniture.flingAt()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/Furniture.luau
- `Abilities.try()` --calls--> `Furniture.nearest()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/Furniture.luau

## Import Cycles
- None detected.

## Communities (22 total, 8 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.07
Nodes (59): Abilities.clear(), checkThrown(), checkThrownPlayers(), Combat.start(), Fire.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab() (+51 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.17
Nodes (22): HUD.banner(), HUD.flash(), blackout(), disc(), emitter(), gassed(), MonsterFx.handle(), near() (+14 more)

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
Cohesion: 0.11
Nodes (37): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq() (+29 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (43): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), frame(), Grunge.bar() (+35 more)

### Community 12 - "Events.luau"
Cohesion: 0.31
Nodes (16): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+8 more)

### Community 13 - "Run.luau"
Cohesion: 0.05
Nodes (46): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+38 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.27
Nodes (17): Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish() (+9 more)

### Community 19 - "Fx.luau"
Cohesion: 0.09
Nodes (16): Fx.applyZone(), Fx.init(), HUD.hint(), HUD.toast(), HUD.update(), updateWaypoint(), aimedFurniture(), grab() (+8 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.21
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.clear() (+14 more)

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.139) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07122153209109731 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07493061979648474 - nodes in this community are weakly interconnected._
- **Why does `attach()` connect `GoblinLoot.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.10917874396135266 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07987012987012987 - nodes in this community are weakly interconnected._