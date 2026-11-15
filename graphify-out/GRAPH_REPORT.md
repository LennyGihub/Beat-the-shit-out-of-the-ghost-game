# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-15)

## Corpus Check
- 39 files · ~49,627 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 447 nodes · 1099 edges · 19 communities (12 shown, 7 thin omitted)
- Extraction: 81% EXTRACTED · 19% INFERRED · 0% AMBIGUOUS · INFERRED: 204 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `03d69ebf`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- Fx.handle
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Viewmodel.luau
- Inventory.luau
- RoomPickUI.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Abilities.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 46 edges
2. `stick()` - 24 edges
3. `Fx.handle()` - 24 edges
4. `Run.startFight()` - 15 edges
5. `Ghost.step()` - 14 edges
6. `MonsterFx.handle()` - 14 edges
7. `Abilities.step()` - 13 edges
8. `Furniture.smash()` - 13 edges
9. `Sfx.at()` - 13 edges
10. `alive()` - 13 edges

## Surprising Connections (you probably didn't know these)
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `Fx.handle()` --calls--> `VM.impact()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Fx.handle()` --calls--> `GA.flash()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (19 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.10
Nodes (45): Abilities.clear(), checkThrown(), checkThrownPlayers(), Combat.start(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid() (+37 more)

### Community 1 - "Fx.handle"
Cohesion: 0.07
Nodes (51): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), burst(), flashBall() (+43 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.10
Nodes (49): B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick(), B.can() (+41 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.39
Nodes (6): abilityPose(), bind(), GA.flash(), GA.update(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.18
Nodes (25): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsMap() (+17 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.06
Nodes (32): Hotbar.init(), Hotbar.primary(), Hotbar.select(), refresh(), setSpray(), update(), aimedFurniture(), grab() (+24 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.29
Nodes (21): Combat.playerNear(), Ghost.burn(), alive(), applyFx(), consume(), explode(), get(), ghostAlive() (+13 more)

### Community 7 - "RoomPickUI.luau"
Cohesion: 0.19
Nodes (18): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), build() (+10 more)

### Community 12 - "Events.luau"
Cohesion: 0.18
Nodes (19): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+11 more)

### Community 13 - "Run.luau"
Cohesion: 0.11
Nodes (34): onPlayer(), Events.despawn(), Furniture.recapture(), Inventory.clear(), Inventory.clearWorld(), Lobby.returnPlayer(), folder(), MapLoader.exists() (+26 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.08
Nodes (18): Admin.run(), Admin.start(), isAdmin(), Combat.healAll(), Combat.refreshHealth(), build(), button(), cmd() (+10 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.32
Nodes (16): Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish(), flat() (+8 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.129) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `Fx.handle()` (e.g. with `GA.flash()` and `HUD.banner()`) actually correct?**
  _`Fx.handle()` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.10180995475113122 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.096) - this node is a cross-community bridge._
- **Are the 8 inferred relationships involving `Run.startFight()` (e.g. with `onPlayer()` and `Combat.healAll()`) actually correct?**
  _`Run.startFight()` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Should `Fx.handle` be split into smaller, more focused modules?**
  _Cohesion score 0.06990622335890878 - nodes in this community are weakly interconnected._
- **Why does `Fx.handle()` connect `Fx.handle` to `ClientMain.client.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.093) - this node is a cross-community bridge._