# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 52 files · ~84,767 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 636 nodes · 1737 edges · 23 communities (16 shown, 7 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 274 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9ac13e39`
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
- Input.luau
- HUD.luau
- GoblinLoot.luau
- GhostAnim.luau
- SawAudio.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 22 edges
7. `Sfx.play()` - 21 edges
8. `moving()` - 20 edges
9. `Input.init()` - 18 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `punch()` --calls--> `VM.punch()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau

## Import Cycles
- None detected.

## Communities (23 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.06
Nodes (78): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try() (+70 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.10
Nodes (39): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), Hotbar.cycle(), HUD.banner() (+31 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (55): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+47 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.07
Nodes (12): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.setSea() (+4 more)

### Community 4 - "Data.luau"
Cohesion: 0.16
Nodes (31): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns() (+23 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.11
Nodes (30): ItemModels.build(), Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+22 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.11
Nodes (35): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq() (+27 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (38): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), bigButton() (+30 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.luau"
Cohesion: 0.06
Nodes (43): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+35 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Input.luau"
Cohesion: 0.13
Nodes (25): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+17 more)

### Community 19 - "HUD.luau"
Cohesion: 0.12
Nodes (22): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+14 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.13
Nodes (25): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.clear() (+17 more)

### Community 21 - "GhostAnim.luau"
Cohesion: 0.33
Nodes (7): abilityPose(), bind(), GA.update(), goblinClaw(), pirateSlash(), target(), walkPose()

### Community 22 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.125) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05967540574282147 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09620721554116558 - nodes in this community are weakly interconnected._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06685633001422475 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1051693404634581 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11416490486257928 - nodes in this community are weakly interconnected._