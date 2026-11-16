# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 51 files · ~82,986 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 616 nodes · 1678 edges · 23 communities (16 shown, 7 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 262 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `954212f9`
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
- Settings.luau
- SawAudio.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 22 edges
7. `moving()` - 20 edges
8. `Sfx.play()` - 20 edges
9. `Abilities.step()` - 16 edges
10. `Furniture.smash()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `liftHint()` --calls--> `Settings.keyName()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `setState()` --calls--> `Abilities.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Abilities.luau
- `Abilities.try()` --calls--> `Furniture.flingAt()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/Furniture.luau

## Import Cycles
- None detected.

## Communities (23 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.07
Nodes (60): Abilities.clear(), checkThrown(), checkThrownPlayers(), Combat.start(), Fire.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab() (+52 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.08
Nodes (45): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), Fx.applyZone(), Fx.init() (+37 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (55): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+47 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.10
Nodes (7): abilityPose(), bind(), GA.update(), goblinClaw(), pirateSlash(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.16
Nodes (31): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns() (+23 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.11
Nodes (28): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh() (+20 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.11
Nodes (36): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq() (+28 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (35): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), bigButton() (+27 more)

### Community 12 - "Events.luau"
Cohesion: 0.17
Nodes (20): ItemModels.build(), ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx() (+12 more)

### Community 13 - "Run.luau"
Cohesion: 0.05
Nodes (51): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+43 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.26
Nodes (18): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+10 more)

### Community 19 - "Input.luau"
Cohesion: 0.10
Nodes (29): Hotbar.cycle(), Hotbar.drop(), HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), aimedFurniture() (+21 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (21): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.drop() (+13 more)

### Community 21 - "Settings.luau"
Cohesion: 0.33
Nodes (8): apply(), load(), save(), Settings.bind(), Settings.init(), Settings.keyName(), Settings.reset(), Settings.set()

### Community 22 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Events.luau` to `ItemModels.luau`, `GoblinLoot.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.129) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06961770623742455 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Events.luau`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07744107744107744 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Viewmodel.luau` to `Events.luau`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11491935483870967 - nodes in this community are weakly interconnected._