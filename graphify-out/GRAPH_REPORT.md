# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 78 files · ~159,044 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 950 nodes · 2719 edges · 48 communities (35 shown, 13 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 634 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `99ebc396`
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
- script_parent_sfx
- Sfx.at
- Run.luau
- GoblinLoot.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Fx.luau
- Ragdoll.luau
- QuestUI.luau
- RoomPickUI.luau
- SawAudio.luau
- Furniture.near
- rs_shared_items
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- rs_shared_config
- Viewmodel.luau
- AdminPanel.luau
- GhostAnim.luau
- Settings.luau
- Spectate.luau
- Loading.luau
- CrewAnim.luau
- Ghost.step
- CallerMarks.luau
- Sfx.play
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Kit.ring()` - 31 edges
7. `Sfx.at()` - 30 edges
8. `Sfx.play()` - 30 edges
9. `Ghost.step()` - 28 edges
10. `Kit.chunks()` - 25 edges

## Surprising Connections (you probably didn't know these)
- `Vip.start()` --calls--> `onPlayer()`  [INFERRED]
  game/ServerScriptService/Server/Vip.luau → game/ServerScriptService/Main.server.luau
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `Ghost.spawn()` --calls--> `Evolved.dress()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Evolved.onSpawn()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Ragdoll.restoreWalls()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (48 total, 13 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.21
Nodes (22): checkThrown(), checkThrownPlayers(), Combat.start(), Furniture.near(), Furniture.smash(), Furniture.weight(), Ghost.alive(), Ghost.burn() (+14 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.11
Nodes (30): burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq(), setWildCount() (+22 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.05
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 4 - "Data.luau"
Cohesion: 0.07
Nodes (50): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.loaded() (+42 more)

### Community 5 - "Input.luau"
Cohesion: 0.09
Nodes (40): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+32 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.25
Nodes (23): alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.give(), Inventory.giveUses() (+15 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.33
Nodes (15): Grunge.text(), bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint() (+7 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.17
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.20
Nodes (24): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.restock() (+16 more)

### Community 13 - "Grunge.luau"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 15 - "script_parent_sfx"
Cohesion: 0.13
Nodes (9): CallerUI.call(), Platform.menu(), build(), Prompts.init(), productId(), ReviveUI.handle(), ReviveUI.init(), Shop.open() (+1 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (71): Kit.near(), HUD.banner(), HUD.flash(), make(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze() (+63 more)

### Community 19 - "Run.luau"
Cohesion: 0.05
Nodes (64): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+56 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (19): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.dress() (+11 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.10
Nodes (40): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+32 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.15
Nodes (20): Abilities.clear(), Evolved.interrupt(), die(), Ghost.despawn(), Ghost.freeze(), Ghost.launch(), Ghost.setVortex(), Ghost.shove() (+12 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.27
Nodes (12): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.restoreWalls() (+4 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "SawAudio.luau"
Cohesion: 0.35
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 30 - "Furniture.near"
Cohesion: 0.33
Nodes (9): placeHint(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+1 more)

### Community 31 - "rs_shared_items"
Cohesion: 0.32
Nodes (3): clear(), selectedId(), step()

### Community 32 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.32
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 37 - "GhostAnim.luau"
Cohesion: 0.29
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 39 - "Settings.luau"
Cohesion: 0.19
Nodes (17): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxCount() (+9 more)

### Community 40 - "Spectate.luau"
Cohesion: 0.57
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "CrewAnim.luau"
Cohesion: 0.50
Nodes (3): add(), CrewAnim.init(), joint()

### Community 43 - "Ghost.step"
Cohesion: 0.18
Nodes (16): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp(), bringBack() (+8 more)

### Community 44 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 46 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

## Knowledge Gaps
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `GoblinLoot.luau`, `rs_shared_items`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11428571428571428 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.047872340425531915 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `Spectate.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `QuestUI.luau`, `RoomPickUI.luau`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06713286713286713 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08521870286576169 - nodes in this community are weakly interconnected._