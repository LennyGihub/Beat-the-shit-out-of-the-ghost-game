# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-15)

## Corpus Check
- 40 files · ~50,505 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 458 nodes · 1125 edges · 21 communities (14 shown, 7 thin omitted)
- Extraction: 82% EXTRACTED · 18% INFERRED · 0% AMBIGUOUS · INFERRED: 207 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9a803cc3`
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
- Fx.luau
- SawAudio.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 46 edges
2. `Fx.handle()` - 25 edges
3. `stick()` - 24 edges
4. `Run.startFight()` - 15 edges
5. `Ghost.step()` - 14 edges
6. `MonsterFx.handle()` - 14 edges
7. `Furniture.smash()` - 13 edges
8. `Sfx.at()` - 13 edges
9. `Abilities.step()` - 13 edges
10. `alive()` - 13 edges

## Surprising Connections (you probably didn't know these)
- `Fx.handle()` --calls--> `GA.flash()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- `Fx.handle()` --calls--> `VM.impact()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Fx.handle()` --calls--> `HUD.combo()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Fx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (21 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.11
Nodes (41): Abilities.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+33 more)

### Community 1 - "Fx.handle"
Cohesion: 0.10
Nodes (42): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), Fx.handle(), Fx.kick() (+34 more)

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
Cohesion: 0.10
Nodes (28): setSpray(), update(), aimedFurniture(), grab(), Input.init(), look(), punch(), setSprint() (+20 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.16
Nodes (28): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), Combat.start(), Furniture.weight(), Ghost.burn() (+20 more)

### Community 7 - "RoomPickUI.luau"
Cohesion: 0.24
Nodes (16): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), arrow() (+8 more)

### Community 12 - "Events.luau"
Cohesion: 0.31
Nodes (16): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+8 more)

### Community 13 - "Run.luau"
Cohesion: 0.07
Nodes (36): onPlayer(), Admin.run(), Admin.start(), isAdmin(), Events.despawn(), Furniture.recapture(), Inventory.clearWorld(), Lobby.returnPlayer() (+28 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.32
Nodes (16): Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish(), flat() (+8 more)

### Community 19 - "Fx.luau"
Cohesion: 0.05
Nodes (17): burst(), flashBall(), Fx.applyZone(), Fx.init(), slash(), Hotbar.init(), Hotbar.select(), refresh() (+9 more)

### Community 20 - "SawAudio.luau"
Cohesion: 0.35
Nodes (10): Hotbar.primary(), oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound() (+2 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Fx.luau`, `Events.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.126) - this node is a cross-community bridge._
- **Are the 17 inferred relationships involving `Fx.handle()` (e.g. with `GA.flash()` and `HUD.banner()`) actually correct?**
  _`Fx.handle()` has 17 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11193339500462535 - nodes in this community are weakly interconnected._
- **Why does `Fx.handle()` connect `Fx.handle` to `ClientMain.client.luau`, `Fx.luau`, `SawAudio.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.094) - this node is a cross-community bridge._
- **Are the 8 inferred relationships involving `Run.startFight()` (e.g. with `onPlayer()` and `Combat.healAll()`) actually correct?**
  _`Run.startFight()` has 8 INFERRED edges - model-reasoned connections that need verification._
- **Should `Fx.handle` be split into smaller, more focused modules?**
  _Cohesion score 0.09579100145137881 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.093) - this node is a cross-community bridge._