# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 44 files · ~65,036 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 509 nodes · 1384 edges · 21 communities (14 shown, 7 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 207 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7c80dd81`
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
- LobbyUI.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Abilities.luau
- ClientMain.client.luau
- SawAudio.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 48 edges
2. `V()` - 45 edges
3. `at()` - 44 edges
4. `mark()` - 43 edges
5. `worn()` - 38 edges
6. `Ghost.step()` - 20 edges
7. `moving()` - 20 edges
8. `Run.startFight()` - 15 edges
9. `Abilities.step()` - 15 edges
10. `Furniture.smash()` - 14 edges

## Surprising Connections (you probably didn't know these)
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `onPlayer()` --calls--> `Data.load()`  [INFERRED]
  game/ServerScriptService/Main.server.luau → game/ServerScriptService/Server/Data.luau
- `Admin.start()` --calls--> `onPlayer()`  [INFERRED]
  game/ServerScriptService/Server/Admin.luau → game/ServerScriptService/Main.server.luau
- `Combat.start()` --calls--> `onPlayer()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Main.server.luau

## Import Cycles
- None detected.

## Communities (21 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.08
Nodes (52): checkThrown(), checkThrownPlayers(), Fire.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near() (+44 more)

### Community 1 - "Fx.handle"
Cohesion: 0.10
Nodes (33): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.banner(), HUD.flash() (+25 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.20
Nodes (54): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+46 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.39
Nodes (5): abilityPose(), bind(), GA.update(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.16
Nodes (29): Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns(), Data.ownsMap() (+21 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.07
Nodes (39): ItemModels.build(), Fx.applyZone(), Fx.init(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse() (+31 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.11
Nodes (34): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), Combat.start(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite() (+26 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.15
Nodes (28): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), bigButton() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.17
Nodes (19): ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx(), groundCF() (+11 more)

### Community 13 - "Run.luau"
Cohesion: 0.08
Nodes (37): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Ghost.despawn(), Inventory.clearWorld() (+29 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.13
Nodes (18): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), build(), button(), cmd() (+10 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.25
Nodes (18): Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+10 more)

### Community 19 - "ClientMain.client.luau"
Cohesion: 0.09
Nodes (4): HUD.hint(), HUD.toast(), HUD.update(), updateWaypoint()

### Community 20 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`?**
  _High betweenness centrality (0.127) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08038914490527393 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **Should `Fx.handle` be split into smaller, more focused modules?**
  _Cohesion score 0.09725158562367865 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06901960784313725 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1109936575052854 - nodes in this community are weakly interconnected._