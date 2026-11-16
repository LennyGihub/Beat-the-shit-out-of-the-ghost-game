# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 42 files · ~61,299 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 484 nodes · 1318 edges · 20 communities (13 shown, 7 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 193 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `787cdd07`
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
- Hotbar.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Input.luau
- ClientMain.client.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 48 edges
2. `V()` - 45 edges
3. `at()` - 44 edges
4. `mark()` - 43 edges
5. `worn()` - 38 edges
6. `moving()` - 20 edges
7. `Ghost.step()` - 19 edges
8. `Abilities.step()` - 15 edges
9. `Run.startFight()` - 15 edges
10. `Furniture.smash()` - 14 edges

## Surprising Connections (you probably didn't know these)
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `stock()` --calls--> `ItemModels.build()`  [INFERRED]
  game/ServerScriptService/Server/Events.luau → game/ReplicatedStorage/Shared/ItemModels.luau
- `stock()` --calls--> `ItemModels.isLong()`  [INFERRED]
  game/ServerScriptService/Server/Events.luau → game/ReplicatedStorage/Shared/ItemModels.luau
- `Fire.flames()` --calls--> `emitter()`  [INFERRED]
  game/ServerScriptService/Server/Fire.luau → game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau
- `Ghost.step()` --calls--> `Fire.flames()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fire.luau

## Import Cycles
- None detected.

## Communities (20 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.07
Nodes (70): Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+62 more)

### Community 1 - "Fx.handle"
Cohesion: 0.13
Nodes (25): HUD.banner(), HUD.flash(), HUD.toast(), HUD.update(), updateWaypoint(), blackout(), disc(), emitter() (+17 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.21
Nodes (52): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+44 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.39
Nodes (5): abilityPose(), bind(), GA.update(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.18
Nodes (25): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsMap() (+17 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.10
Nodes (23): ItemModels.animate(), ItemModels.build(), scaled(), clear(), selectedId(), step(), addTrail(), ease() (+15 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.12
Nodes (33): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq() (+25 more)

### Community 7 - "Hotbar.luau"
Cohesion: 0.08
Nodes (38): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), frame(), Grunge.bar() (+30 more)

### Community 12 - "Events.luau"
Cohesion: 0.31
Nodes (16): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+8 more)

### Community 13 - "Run.luau"
Cohesion: 0.09
Nodes (33): onPlayer(), Events.despawn(), Furniture.recapture(), Inventory.clearWorld(), Lobby.returnPlayer(), folder(), MapLoader.exists(), MapLoader.ghostSpawns() (+25 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.09
Nodes (20): Admin.run(), Admin.start(), isAdmin(), build(), button(), cmd(), corner(), grid() (+12 more)

### Community 18 - "Input.luau"
Cohesion: 0.21
Nodes (11): Combat.start(), HUD.hint(), aimedFurniture(), grab(), Input.init(), look(), punch(), setSprint() (+3 more)

### Community 19 - "ClientMain.client.luau"
Cohesion: 0.12
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`?**
  _High betweenness centrality (0.131) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06594399277326106 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **Should `Fx.handle` be split into smaller, more focused modules?**
  _Cohesion score 0.13068181818181818 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.10344827586206896 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1173054587688734 - nodes in this community are weakly interconnected._