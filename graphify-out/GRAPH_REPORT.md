# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 75 files · ~152,675 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 916 nodes · 2635 edges · 47 communities (35 shown, 12 thin omitted)
- Extraction: 76% EXTRACTED · 24% INFERRED · 0% AMBIGUOUS · INFERRED: 621 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5d7f9749`
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
- LockOn.luau
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
- Fire.luau
- SawAudio.luau
- onPlayer
- Run.startFight
- game/ServerScriptService/Server/Sandbox.luau
- AdminPanel.luau
- CrewAnim.luau
- Settings.luau
- Spectate.luau
- build
- MapLoader.luau
- Combat.luau
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
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `CallerUI.call()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/CallerUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `make()` --calls--> `Settings.group()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau

## Import Cycles
- None detected.

## Communities (47 total, 12 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.17
Nodes (25): checkThrown(), checkThrownPlayers(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+17 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (30): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+22 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.05
Nodes (14): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step(), abilityPose(), addJoint(), bind() (+6 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (41): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+33 more)

### Community 5 - "Input.luau"
Cohesion: 0.08
Nodes (44): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+36 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.19
Nodes (28): Ghost.freeze(), Ghost.shove(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode() (+20 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.33
Nodes (15): Grunge.text(), bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint() (+7 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.13
Nodes (30): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+22 more)

### Community 12 - "Events.luau"
Cohesion: 0.23
Nodes (22): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+14 more)

### Community 13 - "Grunge.luau"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 15 - "LockOn.luau"
Cohesion: 0.18
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "onPlayer"
Cohesion: 0.17
Nodes (16): Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), checkWipe(), endDeath(), hrpOf(), onBuy() (+8 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.15
Nodes (28): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.windUp(), attach(), clearLine() (+20 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.10
Nodes (39): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+31 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.14
Nodes (27): Abilities.clear(), Evolved.dress(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive() (+19 more)

### Community 24 - "Admin.luau"
Cohesion: 0.19
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.35
Nodes (10): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+2 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "Fire.luau"
Cohesion: 0.23
Nodes (13): burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq(), setWildCount() (+5 more)

### Community 30 - "SawAudio.luau"
Cohesion: 0.35
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 32 - "onPlayer"
Cohesion: 0.29
Nodes (6): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Vip.start()

### Community 34 - "Run.startFight"
Cohesion: 0.28
Nodes (13): Inventory.clearWorld(), clearTemp(), doorPrompt(), insideHouse(), onGhostDeath(), Run.endMatch(), Run.running(), Run.start() (+5 more)

### Community 35 - "game/ServerScriptService/Server/Sandbox.luau"
Cohesion: 0.38
Nodes (9): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 36 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (24): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+16 more)

### Community 39 - "Settings.luau"
Cohesion: 0.23
Nodes (14): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.get() (+6 more)

### Community 40 - "Spectate.luau"
Cohesion: 0.57
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 42 - "MapLoader.luau"
Cohesion: 0.31
Nodes (9): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+1 more)

### Community 43 - "Combat.luau"
Cohesion: 0.25
Nodes (3): Combat.healAll(), Combat.refreshHealth(), Combat.start()

### Community 46 - "script_parent_sfx"
Cohesion: 0.14
Nodes (7): CallerUI.call(), Platform.menu(), productId(), ReviveUI.handle(), ReviveUI.init(), Shop.open(), Shop.result()

### Community 47 - "Friends.luau"
Cohesion: 0.29
Nodes (6): areFriends(), Friends.mult(), refresh(), Quests.add(), cashMult(), Run.payout()

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

## Knowledge Gaps
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `GoblinLoot.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13257575757575757 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05410628019323672 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `MonsterFx.luau` to `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `build`, `Spectate.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `QuestUI.luau`, `RoomPickUI.luau`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11945031712473574 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0750151240169389 - nodes in this community are weakly interconnected._