# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 73 files · ~148,599 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 894 nodes · 2604 edges · 45 communities (34 shown, 11 thin omitted)
- Extraction: 76% EXTRACTED · 24% INFERRED · 0% AMBIGUOUS · INFERRED: 618 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ccfde6bc`
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
- Grunge.luau
- ReviveUI.luau
- Sfx.at
- onPlayer
- GoblinLoot.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Admin.luau
- Ragdoll.luau
- QuestUI.luau
- RoomPickUI.luau
- Sfx.play
- game/ServerScriptService/Server/Fury.luau
- Run.startFight
- game/ServerScriptService/Server/Sandbox.luau
- AdminPanel.luau
- CrewAnim.luau
- Settings.luau
- Spectate.luau
- game/ServerScriptService/Server/Combat.luau
- MapLoader.luau
- script_parent_sfx
- Friends.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Kit.ring()` - 31 edges
7. `Sfx.at()` - 30 edges
8. `Sfx.play()` - 30 edges
9. `Ghost.step()` - 27 edges
10. `Kit.chunks()` - 25 edges

## Surprising Connections (you probably didn't know these)
- `MonsterFx.handle()` --calls--> `Sfx.voice()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Evolved.dress()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Evolved.onSpawn()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Ragdoll.restoreWalls()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (45 total, 11 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.30
Nodes (14): Furniture.near(), Furniture.smash(), Ghost.burn(), Ghost.setVortex(), Ghost.slow(), barrage(), fling(), ghostPos() (+6 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.12
Nodes (29): burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq(), setWildCount() (+21 more)

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
Cohesion: 0.08
Nodes (43): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+35 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.19
Nodes (28): Ghost.freeze(), Ghost.shove(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode() (+20 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.33
Nodes (15): Grunge.text(), bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint() (+7 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.21
Nodes (23): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock() (+15 more)

### Community 13 - "Grunge.luau"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 15 - "ReviveUI.luau"
Cohesion: 0.47
Nodes (5): Platform.menu(), productId(), ReviveUI.handle(), ReviveUI.init(), Shop.open()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (71): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+63 more)

### Community 19 - "onPlayer"
Cohesion: 0.29
Nodes (6): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Vip.start()

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.dress() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (45): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+37 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.18
Nodes (22): Abilities.clear(), bringBack(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.despawn(), Ghost.launch() (+14 more)

### Community 24 - "Admin.luau"
Cohesion: 0.17
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.restoreWalls() (+3 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 30 - "game/ServerScriptService/Server/Fury.luau"
Cohesion: 0.27
Nodes (8): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp(), claw(), warded()

### Community 34 - "Run.startFight"
Cohesion: 0.13
Nodes (32): Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), Quests.add(), aliveCount(), aliveIn(), cashMult(), checkWipe() (+24 more)

### Community 35 - "game/ServerScriptService/Server/Sandbox.luau"
Cohesion: 0.42
Nodes (8): Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (24): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+16 more)

### Community 39 - "Settings.luau"
Cohesion: 0.11
Nodes (25): KeyHints.init(), refresh(), toggle(), oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used() (+17 more)

### Community 40 - "Spectate.luau"
Cohesion: 0.57
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 41 - "game/ServerScriptService/Server/Combat.luau"
Cohesion: 0.19
Nodes (6): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.start(), Furniture.weight(), ult()

### Community 42 - "MapLoader.luau"
Cohesion: 0.29
Nodes (10): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+2 more)

### Community 46 - "script_parent_sfx"
Cohesion: 0.13
Nodes (8): CallerUI.call(), CallerUI.init(), build(), Prompts.init(), layout(), make(), TC.init(), Shop.result()

### Community 47 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

## Knowledge Gaps
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `GoblinLoot.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06825396825396825 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `Settings.luau`, `Spectate.luau`, `script_parent_sfx`, `ReviveUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `QuestUI.luau`, `RoomPickUI.luau`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11945031712473574 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07644110275689223 - nodes in this community are weakly interconnected._