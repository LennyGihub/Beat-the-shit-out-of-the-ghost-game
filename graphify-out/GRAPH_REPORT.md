# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 55 files · ~90,341 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 672 nodes · 1816 edges · 34 communities (23 shown, 11 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 286 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `420bf8f4`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- UltFx.luau
- ItemModels.luau
- Data.luau
- Viewmodel.luau
- Inventory.luau
- script_parent_sfx
- Events.luau
- Run.luau
- AdminPanel.luau
- Input.luau
- HUD.luau
- GoblinLoot.luau
- Combat.luau
- Admin.luau
- Run.startFight
- MapLoader.luau
- LobbyUI.luau
- onPlayer
- Friends.luau
- GhostAnim.luau
- QuestUI.luau
- RoomPickUI.luau
- Grunge.panel

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 22 edges
7. `Sfx.play()` - 22 edges
8. `moving()` - 20 edges
9. `Input.init()` - 19 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `LobbyUI.invite()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/LobbyUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `punch()` --calls--> `VM.punch()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau

## Import Cycles
- None detected.

## Communities (34 total, 11 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.06
Nodes (76): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try() (+68 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.09
Nodes (40): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.banner(), HUD.flash() (+32 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (40): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+32 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.07
Nodes (41): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh() (+33 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.13
Nodes (34): burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts(), Ghost.burn() (+26 more)

### Community 7 - "script_parent_sfx"
Cohesion: 0.17
Nodes (9): Platform.menu(), build(), Prompts.init(), productId(), ReviveUI.handle(), ReviveUI.init(), layout(), make() (+1 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Run.luau"
Cohesion: 0.18
Nodes (15): Monetization.start(), Quests.add(), endDeath(), hrpOf(), insideHouse(), onBuy(), reviveOn(), Run.extendRevive() (+7 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.13
Nodes (17): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+9 more)

### Community 18 - "Input.luau"
Cohesion: 0.13
Nodes (27): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+19 more)

### Community 19 - "HUD.luau"
Cohesion: 0.12
Nodes (22): HUD.hint(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), navStep() (+14 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.19
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.clear() (+14 more)

### Community 22 - "Admin.luau"
Cohesion: 0.18
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 24 - "Run.startFight"
Cohesion: 0.26
Nodes (14): Inventory.clear(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), onGhostDeath(), Run.endMatch(), Run.matchPlayers() (+6 more)

### Community 25 - "MapLoader.luau"
Cohesion: 0.29
Nodes (10): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+2 more)

### Community 26 - "LobbyUI.luau"
Cohesion: 0.36
Nodes (12): Grunge.text(), bigButton(), button(), LobbyUI.init(), LobbyUI.invite(), LobbyUI.togglePlay(), ownedMaps(), parties() (+4 more)

### Community 27 - "onPlayer"
Cohesion: 0.40
Nodes (6): onPlayer(), Events.despawn(), Inventory.give(), Run.addToMatch(), Run.beginMatch(), Run.configure()

### Community 28 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 29 - "GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 30 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 31 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 32 - "Grunge.panel"
Cohesion: 0.71
Nodes (6): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), sketch(), stroke()

## Knowledge Gaps
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.119) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06138975966562173 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Viewmodel.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08897959183673469 - nodes in this community are weakly interconnected._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11960132890365449 - nodes in this community are weakly interconnected._
- **Should `Viewmodel.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06980392156862746 - nodes in this community are weakly interconnected._