# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 51 files · ~81,664 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 607 nodes · 1666 edges · 22 communities (15 shown, 7 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 254 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4dd5cc4b`
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
- SawAudio.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 24 edges
7. `moving()` - 20 edges
8. `Sfx.play()` - 17 edges
9. `Abilities.step()` - 16 edges
10. `Furniture.smash()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `MonsterFx.handle()` --calls--> `Sfx.voice()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `setState()` --calls--> `Abilities.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Abilities.luau

## Import Cycles
- None detected.

## Communities (22 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.07
Nodes (65): Abilities.clear(), checkThrown(), checkThrownPlayers(), Combat.start(), Fire.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab() (+57 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.18
Nodes (22): HUD.banner(), HUD.flash(), blackout(), disc(), emitter(), gassed(), MonsterFx.handle(), near() (+14 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (55): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+47 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.33
Nodes (7): abilityPose(), bind(), GA.update(), goblinClaw(), pirateSlash(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.16
Nodes (31): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns() (+23 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.12
Nodes (25): Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), refresh(), setSpray(), update() (+17 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.11
Nodes (36): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq() (+28 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (41): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), HUD.init() (+33 more)

### Community 12 - "Events.luau"
Cohesion: 0.31
Nodes (16): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+8 more)

### Community 13 - "Run.luau"
Cohesion: 0.05
Nodes (48): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+40 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.12
Nodes (17): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+9 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.26
Nodes (18): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+10 more)

### Community 19 - "Input.luau"
Cohesion: 0.06
Nodes (36): Hotbar.cycle(), Hotbar.drop(), HUD.hint(), HUD.toast(), HUD.update(), updateWaypoint(), aimedFurniture(), allPrompts() (+28 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.14
Nodes (25): ItemModels.build(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), land() (+17 more)

### Community 22 - "SawAudio.luau"
Cohesion: 0.14
Nodes (19): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), oneShot(), SawAudio.attach() (+11 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `GoblinLoot.luau` to `ItemModels.luau`, `Events.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.136) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06526315789473684 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `GoblinLoot.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12315270935960591 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Viewmodel.luau` to `GoblinLoot.luau`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11014492753623188 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08148148148148149 - nodes in this community are weakly interconnected._