# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 84 files · ~176,539 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1032 nodes · 2890 edges · 59 communities (43 shown, 16 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 660 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6e3f3ff7`
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
- BestiaryUI.luau
- rs_shared_items
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- rs_shared_config
- Viewmodel.luau
- AdminPanel.luau
- Entrance.luau
- script_parent_remotes
- Spectate.luau
- Loading.luau
- CrewAnim.luau
- rs_shared_config
- CallerMarks.luau
- Sfx.play
- Fire.luau
- onPlayer
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- MapLoader.luau
- Lobby.luau
- game/ServerScriptService/Server/Sandbox.luau
- Leaderboards.luau
- Friends.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 37 edges
7. `Kit.ring()` - 31 edges
8. `Sfx.at()` - 30 edges
9. `Ghost.step()` - 28 edges
10. `Kit.chunks()` - 25 edges

## Surprising Connections (you probably didn't know these)
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `ringPhone()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `MonsterFx.handle()` --calls--> `Sfx.voice()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau

## Import Cycles
- None detected.

## Communities (59 total, 16 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.30
Nodes (14): Furniture.near(), Furniture.smash(), Ghost.burn(), Ghost.setVortex(), Ghost.slow(), barrage(), fling(), ghostPos() (+6 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.25
Nodes (16): beamOff(), beamTo(), blackout(), disc(), emitter(), enrage(), gassed(), jumpscare() (+8 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.05
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 4 - "Data.luau"
Cohesion: 0.20
Nodes (25): Bestiary.check(), Bestiary.record(), cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt() (+17 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (55): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+47 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.21
Nodes (26): Ghost.vuln(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+18 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Grunge.luau"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 15 - "script_parent_sfx"
Cohesion: 0.13
Nodes (9): CallerUI.call(), Platform.menu(), build(), Prompts.init(), productId(), ReviveUI.handle(), ReviveUI.init(), Shop.open() (+1 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.12
Nodes (34): Events.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), Quests.add(), aliveCount(), aliveIn(), cashMult() (+26 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (49): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+41 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.13
Nodes (31): Abilities.clear(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage() (+23 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.28
Nodes (12): Ghost.hit(), breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick() (+4 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 30 - "BestiaryUI.luau"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "rs_shared_items"
Cohesion: 0.32
Nodes (3): clear(), selectedId(), step()

### Community 32 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.32
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

### Community 34 - "rs_shared_config"
Cohesion: 0.21
Nodes (7): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Furniture.weight(), ult()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 39 - "script_parent_remotes"
Cohesion: 0.14
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 40 - "Spectate.luau"
Cohesion: 0.57
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "CrewAnim.luau"
Cohesion: 0.50
Nodes (3): add(), CrewAnim.init(), joint()

### Community 43 - "rs_shared_config"
Cohesion: 0.24
Nodes (7): Fury.comboCount(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp()

### Community 44 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 46 - "Sfx.play"
Cohesion: 0.19
Nodes (16): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+8 more)

### Community 47 - "Fire.luau"
Cohesion: 0.25
Nodes (13): burningNear(), closestPoint(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq(), setWildCount() (+5 more)

### Community 48 - "onPlayer"
Cohesion: 0.26
Nodes (11): onPlayer(), Bestiary.setup(), claim(), progress(), publish(), Quests.setup(), Quests.start(), state() (+3 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

### Community 50 - "MapLoader.luau"
Cohesion: 0.24
Nodes (12): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+4 more)

### Community 52 - "Lobby.luau"
Cohesion: 0.36
Nodes (11): hrpOf(), launch(), leaveParty(), onPad(), onParty(), partyOf(), prepSign(), publish() (+3 more)

### Community 53 - "game/ServerScriptService/Server/Sandbox.luau"
Cohesion: 0.40
Nodes (7): center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 54 - "Leaderboards.luau"
Cohesion: 0.39
Nodes (8): Data.loaded(), draw(), fmt(), Leaderboards.start(), nameOf(), screen(), top(), write()

### Community 56 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `GoblinLoot.luau`, `rs_shared_items`?**
  _High betweenness centrality (0.070) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05426356589147287 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06252587991718427 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `Spectate.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `QuestUI.luau`, `RoomPickUI.luau`, `BestiaryUI.luau`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Should `script_parent_sfx` be split into smaller, more focused modules?**
  _Cohesion score 0.13157894736842105 - nodes in this community are weakly interconnected._
- **Should `Sfx.at` be split into smaller, more focused modules?**
  _Cohesion score 0.12203829925348912 - nodes in this community are weakly interconnected._