# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 68 files · ~125,309 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 821 nodes · 2217 edges · 45 communities (35 shown, 10 thin omitted)
- Extraction: 81% EXTRACTED · 19% INFERRED · 0% AMBIGUOUS · INFERRED: 411 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b5d7314b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Input.luau
- Inventory.luau
- LobbyUI.luau
- CineKit.luau
- Events.luau
- game/ServerScriptService/Server/Run.luau
- AdminPanel.luau
- Fire.luau
- Viewmodel.luau
- GoblinLoot.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Admin.luau
- Ragdoll.luau
- QuestUI.luau
- RoomPickUI.luau
- Sfx.play
- Fury.luau
- refresh
- Settings.luau
- Run.startFight
- Combat.luau
- Grunge.luau
- CrewAnim.luau
- SawAudio.luau
- Spectate.luau
- MapLoader.luau
- Main.server.luau
- script_parent_sfx
- Friends.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 27 edges
7. `Sfx.play()` - 27 edges
8. `moving()` - 20 edges
9. `Abilities.step()` - 19 edges
10. `MonsterFx.handle()` - 19 edges

## Surprising Connections (you probably didn't know these)
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `CallerUI.init()` --calls--> `Grunge.text()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/CallerUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Grunge.luau
- `CallerUI.call()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/CallerUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Hotbar.primary()` --calls--> `VM.impactTime()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Hotbar.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau

## Import Cycles
- None detected.

## Communities (45 total, 10 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.31
Nodes (13): Furniture.near(), Furniture.smash(), Ghost.burn(), Ghost.setVortex(), Ghost.slow(), barrage(), ghostPos(), Runner.barrel() (+5 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.13
Nodes (33): HUD.banner(), HUD.flash(), beamOff(), beamTo(), blackout(), disc(), emitter(), enrage() (+25 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.07
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (41): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+33 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (50): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+42 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.20
Nodes (27): Ghost.freeze(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode(), get() (+19 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.33
Nodes (15): Grunge.text(), bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint() (+7 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.16
Nodes (29): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.14
Nodes (26): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock() (+18 more)

### Community 13 - "game/ServerScriptService/Server/Run.luau"
Cohesion: 0.20
Nodes (14): Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), checkWipe(), endDeath(), respawnSpectators(), Run.extendRevive() (+6 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.25
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Fire.luau"
Cohesion: 0.25
Nodes (13): burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq(), setWildCount() (+5 more)

### Community 19 - "Viewmodel.luau"
Cohesion: 0.15
Nodes (18): addTrail(), ease(), itemOffset(), mirror(), mk(), punchOffset(), sample(), solveHold() (+10 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (46): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+38 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.13
Nodes (28): Abilities.clear(), Evolved.dress(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive() (+20 more)

### Community 24 - "Admin.luau"
Cohesion: 0.20
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "Sfx.play"
Cohesion: 0.22
Nodes (16): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+8 more)

### Community 30 - "Fury.luau"
Cohesion: 0.24
Nodes (6): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp()

### Community 31 - "refresh"
Cohesion: 0.22
Nodes (8): refresh(), Platform.menu(), Settings.keyName(), layout(), make(), TC.init(), Shop.open(), Shop.result()

### Community 32 - "Settings.luau"
Cohesion: 0.27
Nodes (12): KeyHints.init(), toggle(), apply(), load(), save(), Settings.bind(), Settings.get(), Settings.init() (+4 more)

### Community 34 - "Run.startFight"
Cohesion: 0.21
Nodes (17): Inventory.clearWorld(), Quests.add(), cashMult(), clearTemp(), doorPrompt(), hrpOf(), insideHouse(), onBuy() (+9 more)

### Community 35 - "Combat.luau"
Cohesion: 0.21
Nodes (6): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), Furniture.weight()

### Community 36 - "Grunge.luau"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 39 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 40 - "Spectate.luau"
Cohesion: 0.57
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 42 - "MapLoader.luau"
Cohesion: 0.29
Nodes (9): folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn(), MapLoader.setSea() (+1 more)

### Community 43 - "Main.server.luau"
Cohesion: 0.13
Nodes (7): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running(), Vip.start()

### Community 46 - "script_parent_sfx"
Cohesion: 0.17
Nodes (4): CallerUI.call(), CallerUI.init(), build(), Prompts.init()

### Community 47 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

## Knowledge Gaps
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Viewmodel.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.097) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12660028449502134 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06606606606606606 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `UltFx.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `Spectate.luau`, `script_parent_sfx`, `QuestUI.luau`, `RoomPickUI.luau`, `refresh`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11945031712473574 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05674044265593561 - nodes in this community are weakly interconnected._