# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-15)

## Corpus Check
- 25 files · ~23,353 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 232 nodes · 558 edges · 15 communities (10 shown, 5 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 129 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `721b3512`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- Fx.luau
- Combat.luau
- GhostAnim.luau
- Data.luau
- Input.luau
- Round.luau
- HUD.luau
- Props.luau
- Lobby.luau

## God Nodes (most connected - your core abstractions)
1. `Fx.handle()` - 22 edges
2. `p()` - 17 edges
3. `Round.startFight()` - 13 edges
4. `Data.get()` - 11 edges
5. `Runner.run()` - 11 edges
6. `Sfx.at()` - 11 edges
7. `Ghost.step()` - 10 edges
8. `Furniture.smash()` - 9 edges
9. `setState()` - 9 edges
10. `Ghost.damage()` - 9 edges

## Surprising Connections (you probably didn't know these)
- `onThrow()` --calls--> `Furniture.throw()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Furniture.luau
- `onBuy()` --calls--> `Combat.refreshHealth()`  [INFERRED]
  game/ServerScriptService/Server/Round.luau → game/ServerScriptService/Server/Combat.luau
- `Round.startFight()` --calls--> `Combat.healAll()`  [INFERRED]
  game/ServerScriptService/Server/Round.luau → game/ServerScriptService/Server/Combat.luau
- `Fx.handle()` --calls--> `GA.flash()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- `Fx.handle()` --calls--> `HUD.combo()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (15 total, 5 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.12
Nodes (40): checkThrown(), onGrab(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+32 more)

### Community 1 - "Fx.luau"
Cohesion: 0.13
Nodes (32): burst(), flashBall(), Fx.applyZone(), Fx.handle(), Fx.init(), Fx.kick(), Fx.shake(), jumpscare() (+24 more)

### Community 2 - "Combat.luau"
Cohesion: 0.18
Nodes (6): Combat.healAll(), Combat.refreshHealth(), Combat.start(), onThrow(), onUltimate(), ult()

### Community 3 - "GhostAnim.luau"
Cohesion: 0.47
Nodes (4): bind(), GA.flash(), GA.update(), target()

### Community 4 - "Data.luau"
Cohesion: 0.31
Nodes (15): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsUlt() (+7 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (13): HUD.hint(), aimedFurniture(), grab(), Input.init(), look(), punch(), setSprint(), mk() (+5 more)

### Community 6 - "Round.luau"
Cohesion: 0.19
Nodes (22): onPlayer(), billboard(), buildStand(), buildWreck(), clearSpawned(), crash(), hrpOf(), insideHouse() (+14 more)

### Community 7 - "HUD.luau"
Cohesion: 0.13
Nodes (18): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), HUD.combo() (+10 more)

### Community 12 - "Props.luau"
Cohesion: 0.22
Nodes (17): builders.book(), builders.boots(), builders.bottle(), builders.can(), builders.charm(), builders.cross(), builders.gloves(), builders.jacket() (+9 more)

### Community 13 - "Lobby.luau"
Cohesion: 0.29
Nodes (10): Data.save(), Data.start(), hrpOf(), launch(), Lobby.returnPlayer(), Lobby.start(), onPad(), setSign() (+2 more)

## Knowledge Gaps
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `buildStand()` connect `Round.luau` to `Props.luau`, `Data.luau`?**
  _High betweenness centrality (0.140) - this node is a cross-community bridge._
- **Are the 14 inferred relationships involving `Fx.handle()` (e.g. with `GA.flash()` and `HUD.banner()`) actually correct?**
  _`Fx.handle()` has 14 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11655874190564293 - nodes in this community are weakly interconnected._
- **Why does `Props.build()` connect `Props.luau` to `Round.luau`?**
  _High betweenness centrality (0.132) - this node is a cross-community bridge._
- **Are the 6 inferred relationships involving `Round.startFight()` (e.g. with `onPlayer()` and `Combat.healAll()`) actually correct?**
  _`Round.startFight()` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Should `Fx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12560975609756098 - nodes in this community are weakly interconnected._
- **Why does `Fx.handle()` connect `Fx.luau` to `GhostAnim.luau`, `Input.luau`, `HUD.luau`?**
  _High betweenness centrality (0.084) - this node is a cross-community bridge._