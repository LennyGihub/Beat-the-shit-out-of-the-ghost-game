# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 56 files · ~91,567 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 684 nodes · 1843 edges · 28 communities (19 shown, 9 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 289 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `73447573`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- UltFx.luau
- ItemModels.luau
- Data.luau
- Viewmodel.luau
- Inventory.luau
- LobbyUI.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Input.luau
- HUD.luau
- GoblinLoot.luau
- Combat.luau
- Furniture.smash
- Abilities.luau
- Fire.luau
- Ragdoll.luau
- GhostAnim.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Sfx.play()` - 23 edges
7. `Ghost.step()` - 22 edges
8. `moving()` - 20 edges
9. `Input.init()` - 19 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.spawn()` --calls--> `Fire.clear()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fire.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (28 total, 9 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.12
Nodes (27): Abilities.clear(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.despawn(), Ghost.freeze() (+19 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.08
Nodes (42): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), Hotbar.cycle(), HUD.banner() (+34 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 4 - "Data.luau"
Cohesion: 0.09
Nodes (40): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+32 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.07
Nodes (40): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh() (+32 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.22
Nodes (25): Ghost.burn(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+17 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.07
Nodes (50): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), bigButton() (+42 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.luau"
Cohesion: 0.08
Nodes (49): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Inventory.clearWorld(), Lobby.returnPlayer() (+41 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.08
Nodes (22): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), build(), button(), cmd() (+14 more)

### Community 18 - "Input.luau"
Cohesion: 0.13
Nodes (27): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+19 more)

### Community 19 - "HUD.luau"
Cohesion: 0.12
Nodes (22): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+14 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (21): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.drop() (+13 more)

### Community 21 - "Combat.luau"
Cohesion: 0.19
Nodes (7): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Furniture.weight(), ult()

### Community 22 - "Furniture.smash"
Cohesion: 0.18
Nodes (21): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+13 more)

### Community 23 - "Abilities.luau"
Cohesion: 0.26
Nodes (18): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+10 more)

### Community 24 - "Fire.luau"
Cohesion: 0.33
Nodes (8): burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.38
Nodes (9): breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start(), Ragdoll.step() (+1 more)

### Community 29 - "GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

## Knowledge Gaps
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.119) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Viewmodel.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.083710407239819 - nodes in this community are weakly interconnected._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0889894419306184 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07183673469387755 - nodes in this community are weakly interconnected._