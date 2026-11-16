# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 46 files · ~67,324 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 525 nodes · 1415 edges · 20 communities (13 shown, 7 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 215 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a5b96484`
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
- SawAudio.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 48 edges
2. `V()` - 45 edges
3. `at()` - 44 edges
4. `mark()` - 43 edges
5. `worn()` - 38 edges
6. `Ghost.step()` - 20 edges
7. `moving()` - 20 edges
8. `Sfx.play()` - 16 edges
9. `Run.startFight()` - 15 edges
10. `Abilities.step()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `onPlayer()` --calls--> `Data.load()`  [INFERRED]
  game/ServerScriptService/Main.server.luau → game/ServerScriptService/Server/Data.luau
- `Combat.start()` --calls--> `onPlayer()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Main.server.luau
- `launch()` --calls--> `Run.beginMatch()`  [INFERRED]
  game/ServerScriptService/Server/Lobby.luau → game/ServerScriptService/Server/Run.luau

## Import Cycles
- None detected.

## Communities (20 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.07
Nodes (59): Abilities.clear(), checkThrown(), checkThrownPlayers(), Combat.start(), Fire.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab() (+51 more)

### Community 1 - "Fx.handle"
Cohesion: 0.14
Nodes (25): HUD.banner(), HUD.flash(), HUD.toast(), HUD.update(), updateWaypoint(), blackout(), disc(), emitter() (+17 more)

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
Nodes (38): Fx.applyZone(), Fx.init(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), refresh() (+30 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.12
Nodes (30): Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq() (+22 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.06
Nodes (35): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), bigButton() (+27 more)

### Community 12 - "Events.luau"
Cohesion: 0.17
Nodes (20): ItemModels.build(), ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx() (+12 more)

### Community 13 - "Run.luau"
Cohesion: 0.05
Nodes (46): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+38 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.27
Nodes (17): Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish() (+9 more)

### Community 20 - "SawAudio.luau"
Cohesion: 0.17
Nodes (17): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), oneShot(), SawAudio.attach() (+9 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Events.luau` to `ItemModels.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.124) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07319347319347319 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Events.luau`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Should `Fx.handle` be split into smaller, more focused modules?**
  _Cohesion score 0.13709677419354838 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06787330316742081 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11627906976744186 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.061507936507936505 - nodes in this community are weakly interconnected._