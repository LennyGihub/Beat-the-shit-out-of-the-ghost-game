# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 40 files · ~55,895 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 465 nodes · 1301 edges · 24 communities (16 shown, 8 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 207 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `efab6d4d`
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
- SawAudio.luau
- Input.luau
- Hotbar.luau
- ThirdPersonItems.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 48 edges
2. `V()` - 45 edges
3. `at()` - 44 edges
4. `mark()` - 43 edges
5. `worn()` - 38 edges
6. `Fx.handle()` - 25 edges
7. `moving()` - 20 edges
8. `Run.startFight()` - 15 edges
9. `Ghost.step()` - 14 edges
10. `MonsterFx.handle()` - 14 edges

## Surprising Connections (you probably didn't know these)
- `punch()` --calls--> `VM.punch()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
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

## Communities (24 total, 8 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.11
Nodes (41): Abilities.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+33 more)

### Community 1 - "Fx.handle"
Cohesion: 0.07
Nodes (51): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), burst(), flashBall() (+43 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.20
Nodes (54): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+46 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.39
Nodes (6): abilityPose(), bind(), GA.flash(), GA.update(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.18
Nodes (25): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsMap() (+17 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.16
Nodes (18): ItemModels.build(), addTrail(), ease(), itemOffset(), mirror(), mk(), punchOffset(), sample() (+10 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (31): Admin.run(), Admin.start(), isAdmin(), checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.refreshHealth() (+23 more)

### Community 7 - "RoomPickUI.luau"
Cohesion: 0.19
Nodes (18): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), build() (+10 more)

### Community 12 - "Events.luau"
Cohesion: 0.31
Nodes (16): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+8 more)

### Community 13 - "Run.luau"
Cohesion: 0.09
Nodes (33): onPlayer(), Events.despawn(), Furniture.recapture(), Inventory.clearWorld(), Lobby.returnPlayer(), folder(), MapLoader.exists(), MapLoader.ghostSpawns() (+25 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.32
Nodes (16): Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish(), flat() (+8 more)

### Community 20 - "SawAudio.luau"
Cohesion: 0.35
Nodes (10): Hotbar.primary(), oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound() (+2 more)

### Community 21 - "Input.luau"
Cohesion: 0.36
Nodes (8): aimedFurniture(), grab(), Input.init(), look(), punch(), setSprint(), ult(), VM.slam()

### Community 22 - "Hotbar.luau"
Cohesion: 0.27
Nodes (7): Hotbar.init(), Hotbar.select(), refresh(), setSpray(), update(), VM.itemTip(), VM.setSpraying()

### Community 23 - "ThirdPersonItems.luau"
Cohesion: 0.38
Nodes (3): clear(), selectedId(), step()

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`, `ThirdPersonItems.luau`?**
  _High betweenness centrality (0.135) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11193339500462535 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Should `Fx.handle` be split into smaller, more focused modules?**
  _Cohesion score 0.06990622335890878 - nodes in this community are weakly interconnected._
- **Why does `Fx.handle()` connect `Fx.handle` to `ClientMain.client.luau`, `Viewmodel.luau`, `SawAudio.luau`, `Input.luau`, `Hotbar.luau`?**
  _High betweenness centrality (0.094) - this node is a cross-community bridge._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09608843537414966 - nodes in this community are weakly interconnected._
- **Should `Run.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08865248226950355 - nodes in this community are weakly interconnected._