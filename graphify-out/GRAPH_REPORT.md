# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 41 files · ~58,234 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 470 nodes · 1276 edges · 20 communities (13 shown, 7 thin omitted)
- Extraction: 86% EXTRACTED · 14% INFERRED · 0% AMBIGUOUS · INFERRED: 182 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8333e41e`
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
- ClientMain.client.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 48 edges
2. `V()` - 45 edges
3. `at()` - 44 edges
4. `mark()` - 43 edges
5. `worn()` - 38 edges
6. `moving()` - 20 edges
7. `Ghost.step()` - 18 edges
8. `Run.startFight()` - 15 edges
9. `Furniture.smash()` - 14 edges
10. `Abilities.step()` - 13 edges

## Surprising Connections (you probably didn't know these)
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `Ghost.spawn()` --calls--> `Ragdoll.restoreWalls()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (20 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.08
Nodes (54): checkThrown(), checkThrownPlayers(), Combat.start(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near() (+46 more)

### Community 1 - "Fx.handle"
Cohesion: 0.08
Nodes (36): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.banner(), HUD.flash() (+28 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.20
Nodes (54): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+46 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.39
Nodes (5): abilityPose(), bind(), GA.update(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.18
Nodes (25): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsMap() (+17 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.08
Nodes (34): ItemModels.build(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), refresh(), setSpray(), update(), HUD.hint() (+26 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.25
Nodes (22): Combat.playerNear(), Ghost.burn(), alive(), applyFx(), consume(), explode(), get(), ghostAlive() (+14 more)

### Community 7 - "RoomPickUI.luau"
Cohesion: 0.19
Nodes (18): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), build() (+10 more)

### Community 12 - "Events.luau"
Cohesion: 0.31
Nodes (16): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+8 more)

### Community 13 - "Run.luau"
Cohesion: 0.06
Nodes (40): onPlayer(), Abilities.clear(), Admin.run(), Admin.start(), isAdmin(), Combat.healAll(), Combat.refreshHealth(), Events.despawn() (+32 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.14
Nodes (17): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+9 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.32
Nodes (16): Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish(), flat() (+8 more)

### Community 19 - "ClientMain.client.luau"
Cohesion: 0.09
Nodes (12): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+4 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `ClientMain.client.luau`, `Events.luau`?**
  _High betweenness centrality (0.134) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07936507936507936 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Should `Fx.handle` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07928118393234672 - nodes in this community are weakly interconnected._
- **Should `Run.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05970149253731343 - nodes in this community are weakly interconnected._