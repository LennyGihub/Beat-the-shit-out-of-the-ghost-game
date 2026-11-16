# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 52 files · ~87,207 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 639 nodes · 1749 edges · 28 communities (19 shown, 9 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 272 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f73f0a73`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Viewmodel.luau
- Inventory.luau
- LobbyUI.luau
- Events.luau
- Run.onDied
- AdminPanel.luau
- Input.luau
- HUD.luau
- GoblinLoot.luau
- Combat.luau
- Admin.luau
- Run.startFight
- MapLoader.luau
- onPlayer
- Friends.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 22 edges
7. `Sfx.play()` - 21 edges
8. `moving()` - 20 edges
9. `Input.init()` - 19 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `punch()` --calls--> `VM.punch()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `update()` --calls--> `VM.itemTip()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Hotbar.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau

## Import Cycles
- None detected.

## Communities (28 total, 9 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.06
Nodes (80): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try() (+72 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.07
Nodes (49): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.banner(), HUD.flash() (+41 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (55): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+47 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.10
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.15
Nodes (32): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+24 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.10
Nodes (23): ItemModels.build(), clear(), selectedId(), step(), addTrail(), ease(), itemOffset(), mirror() (+15 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.16
Nodes (32): burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts(), Ghost.burn() (+24 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (48): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), Hotbar.confirmHit() (+40 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.onDied"
Cohesion: 0.33
Nodes (7): Monetization.start(), endDeath(), reviveOn(), Run.extendRevive(), Run.giveUp(), Run.onDied(), Run.revive()

### Community 15 - "AdminPanel.luau"
Cohesion: 0.13
Nodes (17): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+9 more)

### Community 18 - "Input.luau"
Cohesion: 0.14
Nodes (26): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+18 more)

### Community 19 - "HUD.luau"
Cohesion: 0.13
Nodes (21): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep(), openMenu() (+13 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.19
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.clear() (+14 more)

### Community 22 - "Admin.luau"
Cohesion: 0.18
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 24 - "Run.startFight"
Cohesion: 0.20
Nodes (19): Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), hrpOf(), insideHouse(), onBuy(), onGhostDeath() (+11 more)

### Community 25 - "MapLoader.luau"
Cohesion: 0.23
Nodes (11): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+3 more)

### Community 27 - "onPlayer"
Cohesion: 0.40
Nodes (5): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.running()

### Community 28 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

## Knowledge Gaps
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.124) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05726975222066386 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06892655367231638 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Viewmodel.luau` to `LobbyUI.luau`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09686609686609686 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0967741935483871 - nodes in this community are weakly interconnected._