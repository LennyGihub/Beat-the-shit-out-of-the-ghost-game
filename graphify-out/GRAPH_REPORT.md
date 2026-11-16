# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 52 files · ~85,643 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 638 nodes · 1742 edges · 29 communities (21 shown, 8 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 273 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `96b477ab`
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
- Run.luau
- AdminPanel.luau
- Input.luau
- Settings.luau
- GoblinLoot.luau
- Abilities.luau
- Admin.luau
- Combat.luau
- Run.startFight
- MapLoader.luau
- SawAudio.luau
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
9. `Input.init()` - 18 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `liftHint()` --calls--> `Settings.keyName()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `punch()` --calls--> `VM.punch()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
- `Hotbar.primary()` --calls--> `VM.impactTime()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Hotbar.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau

## Import Cycles
- None detected.

## Communities (29 total, 8 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.07
Nodes (60): Abilities.clear(), checkThrown(), checkThrownPlayers(), Combat.start(), Fire.clear(), Furniture.flingAt(), Furniture.folder(), Furniture.grab() (+52 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.09
Nodes (39): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.banner(), HUD.flash() (+31 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (55): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+47 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.10
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.16
Nodes (31): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns() (+23 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.10
Nodes (23): ItemModels.build(), clear(), selectedId(), step(), addTrail(), ease(), itemOffset(), mirror() (+15 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.14
Nodes (33): Combat.playerNear(), burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts() (+25 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.08
Nodes (48): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), Hotbar.confirmHit() (+40 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.luau"
Cohesion: 0.19
Nodes (14): Monetization.start(), endDeath(), hrpOf(), insideHouse(), onBuy(), reviveOn(), Run.extendRevive(), Run.giveUp() (+6 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.12
Nodes (17): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+9 more)

### Community 18 - "Input.luau"
Cohesion: 0.08
Nodes (39): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+31 more)

### Community 19 - "Settings.luau"
Cohesion: 0.33
Nodes (8): apply(), load(), save(), Settings.bind(), Settings.init(), Settings.keyName(), Settings.reset(), Settings.set()

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.21
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.clear() (+14 more)

### Community 21 - "Abilities.luau"
Cohesion: 0.26
Nodes (18): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+10 more)

### Community 22 - "Admin.luau"
Cohesion: 0.20
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 24 - "Run.startFight"
Cohesion: 0.26
Nodes (14): Inventory.clear(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), onGhostDeath(), Run.endMatch(), Run.matchPlayers() (+6 more)

### Community 25 - "MapLoader.luau"
Cohesion: 0.26
Nodes (10): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+2 more)

### Community 26 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 27 - "onPlayer"
Cohesion: 0.40
Nodes (6): onPlayer(), Events.despawn(), Inventory.give(), Run.addToMatch(), Run.beginMatch(), Run.configure()

### Community 28 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Viewmodel.luau` to `ItemModels.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.125) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07287784679089027 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Viewmodel.luau`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08673469387755102 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Viewmodel.luau` to `LobbyUI.luau`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09686609686609686 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0967741935483871 - nodes in this community are weakly interconnected._