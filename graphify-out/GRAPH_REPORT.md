# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-15)

## Corpus Check
- 20 files · ~13,495 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 154 nodes · 367 edges · 12 communities (8 shown, 4 thin omitted)
- Extraction: 83% EXTRACTED · 17% INFERRED · 0% AMBIGUOUS · INFERRED: 64 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a80795c6`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Round.luau
- Fx.luau
- Combat.luau
- ShopUI.luau
- Data.luau
- Input.luau
- Furniture.luau
- Grunge.luau

## God Nodes (most connected - your core abstractions)
1. `Fx.handle()` - 15 edges
2. `alive()` - 11 edges
3. `Round.startFight()` - 11 edges
4. `Combat.stat()` - 10 edges
5. `st()` - 10 edges
6. `sync()` - 10 edges
7. `onUltimate()` - 10 edges
8. `checkThrown()` - 10 edges
9. `Combat.start()` - 10 edges
10. `onPunch()` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Fx.handle()` --calls--> `GA.flash()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Combat.start()` --calls--> `onPlayer()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Main.server.luau
- `Combat.stat()` --calls--> `Data.get()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Data.luau
- `dropCarried()` --calls--> `Furniture.throw()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Furniture.luau

## Import Cycles
- None detected.

## Communities (12 total, 4 thin omitted)

### Community 0 - "Round.luau"
Cohesion: 0.15
Nodes (22): claw(), die(), floorBelow(), Ghost.damage(), Ghost.despawn(), Ghost.hit(), Ghost.spawn(), Ghost.step() (+14 more)

### Community 1 - "Fx.luau"
Cohesion: 0.12
Nodes (19): burst(), flashBall(), Fx.handle(), Fx.init(), Fx.kick(), Fx.shake(), jumpscare(), setMusic() (+11 more)

### Community 2 - "Combat.luau"
Cohesion: 0.35
Nodes (20): alive(), checkThrown(), Combat.damagePlayer(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Combat.stat(), dropCarried() (+12 more)

### Community 3 - "ShopUI.luau"
Cohesion: 0.14
Nodes (11): bind(), GA.flash(), GA.update(), target(), bezier(), PlaneFx.crash(), refresh(), Shop.close() (+3 more)

### Community 4 - "Data.luau"
Cohesion: 0.25
Nodes (14): onPlayer(), Data.addCash(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.save(), Data.spend() (+6 more)

### Community 5 - "Input.luau"
Cohesion: 0.23
Nodes (13): aimedFurniture(), grab(), Input.init(), look(), punch(), setSprint(), ult(), mk() (+5 more)

### Community 6 - "Furniture.luau"
Cohesion: 0.36
Nodes (8): Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.release(), Furniture.reset(), Furniture.smash(), Furniture.throw()

### Community 7 - "Grunge.luau"
Cohesion: 0.56
Nodes (8): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), HUD.init()

## Knowledge Gaps
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `HUD.init()` connect `Grunge.luau` to `Fx.luau`?**
  _High betweenness centrality (0.078) - this node is a cross-community bridge._
- **Are the 7 inferred relationships involving `Fx.handle()` (e.g. with `GA.flash()` and `HUD.banner()`) actually correct?**
  _`Fx.handle()` has 7 INFERRED edges - model-reasoned connections that need verification._
- **Should `Round.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.14532019704433496 - nodes in this community are weakly interconnected._
- **Why does `Fx.handle()` connect `Fx.luau` to `ShopUI.luau`, `Input.luau`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Are the 5 inferred relationships involving `Round.startFight()` (e.g. with `Combat.healAll()` and `Data.get()`) actually correct?**
  _`Round.startFight()` has 5 INFERRED edges - model-reasoned connections that need verification._
- **Should `Fx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12315270935960591 - nodes in this community are weakly interconnected._
- **Why does `Round.startFight()` connect `Round.luau` to `Combat.luau`, `Data.luau`, `Furniture.luau`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._