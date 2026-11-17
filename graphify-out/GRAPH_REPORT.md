# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 94 files · ~209,462 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1142 nodes · 3585 edges · 55 communities (43 shown, 12 thin omitted)
- Extraction: 72% EXTRACTED · 28% INFERRED · 0% AMBIGUOUS · INFERRED: 987 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `dc9790d7`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- MonsterFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Input.luau
- Inventory.luau
- LobbyUI.luau
- CineKit.luau
- Events.luau
- src/StarterPlayer/StarterPlayerScripts/Client/UltActs.luau
- AdminPanel.luau
- Sfx.at
- src/ServerScriptService/Server/Run.luau
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
- src/ServerScriptService/Server/Ghost.luau
- Run.startFight
- game/ServerScriptService/Server/Sandbox.luau
- script_parent_sfx
- Client/Vip.luau
- SawAudio.luau
- Spectate.luau
- Furniture.smash
- MapLoader.luau
- Furniture.near
- src/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- script_parent_sfx
- Friends.luau
- src/ServerScriptService/Server/Sandbox.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- src/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- src/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 51 edges
2. `p()` - 49 edges
3. `V()` - 46 edges
4. `at()` - 45 edges
5. `mark()` - 44 edges
6. `worn()` - 39 edges
7. `Kit.near()` - 36 edges
8. `Sfx.play()` - 35 edges
9. `Kit.ring()` - 31 edges
10. `Kit.ring()` - 31 edges

## Surprising Connections (you probably didn't know these)
- `onPlayer()` --calls--> `Data.load()`  [INFERRED]
  pending/src/ServerScriptService/Main.server.luau → game/ServerScriptService/Server/Data.luau
- `checkThrown()` --calls--> `ult()`  [INFERRED]
  pending/src/ServerScriptService/Server/Combat.luau → game/StarterPlayer/StarterPlayerScripts/Client/Input.luau
- `Combat.start()` --calls--> `Furniture.release()`  [INFERRED]
  pending/src/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Furniture.luau
- `Combat.start()` --calls--> `ult()`  [INFERRED]
  pending/src/ServerScriptService/Server/Combat.luau → game/StarterPlayer/StarterPlayerScripts/Client/Input.luau
- `setState()` --calls--> `Abilities.interrupt()`  [INFERRED]
  pending/src/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Abilities.luau

## Import Cycles
- None detected.

## Communities (55 total, 12 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.29
Nodes (14): Ghost.burn(), Ghost.damage(), Ghost.hit(), Ghost.setVortex(), Ghost.slow(), barrage(), fling(), ghostPos() (+6 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.25
Nodes (16): beamOff(), beamTo(), blackout(), disc(), emitter(), enrage(), gassed(), jumpscare() (+8 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.05
Nodes (13): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+5 more)

### Community 4 - "Data.luau"
Cohesion: 0.10
Nodes (49): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+41 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (55): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+47 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.12
Nodes (40): burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq(), setWildCount() (+32 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.22
Nodes (24): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), Grunge.text() (+16 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "src/StarterPlayer/StarterPlayerScripts/Client/UltActs.luau"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant(), Acts.heal() (+62 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant(), Acts.heal() (+62 more)

### Community 19 - "src/ServerScriptService/Server/Run.luau"
Cohesion: 0.13
Nodes (32): Events.despawn(), Inventory.clearWorld(), onPlayer(), Quests.add(), aliveCount(), aliveIn(), cashMult(), checkWipe() (+24 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.14
Nodes (17): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.step() (+9 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.11
Nodes (36): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+28 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.14
Nodes (22): Abilities.clear(), Evolved.interrupt(), bringBack(), claw(), die(), floorBelow(), Ghost.freeze(), Ghost.launch() (+14 more)

### Community 24 - "Admin.luau"
Cohesion: 0.14
Nodes (10): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Admin.run(), Admin.start(), isAdmin() (+2 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.33
Nodes (10): breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start(), Ragdoll.step() (+2 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "Sfx.play"
Cohesion: 0.18
Nodes (16): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+8 more)

### Community 30 - "Fury.luau"
Cohesion: 0.13
Nodes (8): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp(), Combat.healAll(), Combat.start()

### Community 31 - "refresh"
Cohesion: 0.47
Nodes (3): layout(), make(), TC.init()

### Community 32 - "src/ServerScriptService/Server/Ghost.luau"
Cohesion: 0.14
Nodes (28): Evolved.dress(), Evolved.onSpawn(), Ragdoll.restoreWalls(), Ragdoll.stop(), bringBack(), claw(), die(), floorBelow() (+20 more)

### Community 34 - "Run.startFight"
Cohesion: 0.14
Nodes (33): Ghost.despawn(), Lobby.returnPlayer(), Monetization.start(), Quests.add(), aliveCount(), aliveIn(), cashMult(), checkWipe() (+25 more)

### Community 35 - "game/ServerScriptService/Server/Sandbox.luau"
Cohesion: 0.16
Nodes (14): onPlayer(), Combat.healAll(), Combat.start(), MapLoader.spawnInside(), Run.addToMatch(), Run.beginMatch(), Run.configure(), center() (+6 more)

### Community 36 - "script_parent_sfx"
Cohesion: 0.13
Nodes (7): Fx.applyZone(), Fx.init(), clear(), selectedId(), step(), Fx.applyZone(), Fx.init()

### Community 37 - "Client/Vip.luau"
Cohesion: 0.25
Nodes (7): add(), CrewAnim.init(), HUD.toast(), door(), doors(), isVip(), Vip.init()

### Community 39 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 40 - "Spectate.luau"
Cohesion: 0.57
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 41 - "Furniture.smash"
Cohesion: 0.22
Nodes (16): checkThrown(), checkThrownPlayers(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+8 more)

### Community 42 - "MapLoader.luau"
Cohesion: 0.31
Nodes (9): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+1 more)

### Community 44 - "Furniture.near"
Cohesion: 0.29
Nodes (14): Furniture.near(), Ghost.burn(), Ghost.hit(), Ghost.setVortex(), Ghost.slow(), barrage(), fling(), ghostPos() (+6 more)

### Community 45 - "src/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 46 - "script_parent_sfx"
Cohesion: 0.12
Nodes (12): CallerUI.call(), CallerUI.init(), Platform.menu(), build(), Prompts.init(), productId(), ReviveUI.handle(), ReviveUI.init() (+4 more)

### Community 47 - "Friends.luau"
Cohesion: 0.25
Nodes (4): areFriends(), Friends.mult(), refresh(), Vip.start()

### Community 48 - "src/ServerScriptService/Server/Sandbox.luau"
Cohesion: 0.36
Nodes (8): Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

### Community 50 - "src/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

### Community 51 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.32
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

### Community 52 - "src/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.32
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

## Knowledge Gaps
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.at()` connect `Sfx.at` to `CineKit.luau`, `MonsterFx.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/UltActs.luau`, `Sfx.play`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Are the 49 inferred relationships involving `Sfx.at()` (e.g. with `Kit.boom()` and `EventFx.train()`) actually correct?**
  _`Sfx.at()` has 49 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05180388529139685 - nodes in this community are weakly interconnected._
- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `GoblinLoot.luau`, `script_parent_sfx`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09869375907111756 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `Spectate.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/UltActs.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `src/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `QuestUI.luau`, `RoomPickUI.luau`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.056576576576576575 - nodes in this community are weakly interconnected._