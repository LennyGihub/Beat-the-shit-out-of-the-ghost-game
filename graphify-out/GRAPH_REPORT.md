# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-15)

## Corpus Check
- 30 files · ~32,754 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 325 nodes · 825 edges · 15 communities (10 shown, 5 thin omitted)
- Extraction: 81% EXTRACTED · 19% INFERRED · 0% AMBIGUOUS · INFERRED: 160 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `645abd81`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- Fx.luau
- ItemModels.luau
- GhostAnim.luau
- Data.luau
- Input.luau
- Inventory.luau
- HUD.luau
- Events.luau
- Run.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 46 edges
2. `stick()` - 24 edges
3. `Fx.handle()` - 22 edges
4. `Ghost.damage()` - 12 edges
5. `applyFx()` - 12 edges
6. `Run.startFight()` - 12 edges
7. `Sfx.at()` - 12 edges
8. `Ghost.step()` - 11 edges
9. `Run.start()` - 11 edges
10. `Runner.run()` - 11 edges

## Surprising Connections (you probably didn't know these)
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Fx.handle()` --calls--> `GA.flash()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- `Fx.handle()` --calls--> `HUD.combo()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Fx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (15 total, 5 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.12
Nodes (38): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+30 more)

### Community 1 - "Fx.luau"
Cohesion: 0.10
Nodes (38): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), burst(), flashBall() (+30 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.10
Nodes (47): B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick(), B.can() (+39 more)

### Community 3 - "GhostAnim.luau"
Cohesion: 0.47
Nodes (4): bind(), GA.flash(), GA.update(), target()

### Community 4 - "Data.luau"
Cohesion: 0.27
Nodes (16): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsUlt() (+8 more)

### Community 5 - "Input.luau"
Cohesion: 0.10
Nodes (24): Hotbar.init(), Hotbar.primary(), Hotbar.select(), refresh(), setSpray(), update(), aimedFurniture(), grab() (+16 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.25
Nodes (23): Ghost.burn(), Ghost.freeze(), Ghost.timeStop(), alive(), applyFx(), consume(), explode(), get() (+15 more)

### Community 7 - "HUD.luau"
Cohesion: 0.11
Nodes (21): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), HUD.combo() (+13 more)

### Community 12 - "Events.luau"
Cohesion: 0.36
Nodes (14): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), label() (+6 more)

### Community 13 - "Run.luau"
Cohesion: 0.10
Nodes (32): onPlayer(), Combat.start(), Events.despawn(), Inventory.clearWorld(), hrpOf(), launch(), Lobby.returnPlayer(), Lobby.start() (+24 more)

## Knowledge Gaps
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `Input.luau`?**
  _High betweenness centrality (0.196) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `Fx.handle()` (e.g. with `GA.flash()` and `HUD.banner()`) actually correct?**
  _`Fx.handle()` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11945031712473574 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.145) - this node is a cross-community bridge._
- **Are the 6 inferred relationships involving `Ghost.damage()` (e.g. with `applyFx()` and `step()`) actually correct?**
  _`Ghost.damage()` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Should `Fx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.10459183673469388 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Input.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.105) - this node is a cross-community bridge._