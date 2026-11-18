# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 97 files · ~208,612 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1172 nodes · 3195 edges · 60 communities (44 shown, 16 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 727 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5073f0da`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- Intro.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- Fire.luau
- rs_shared_config
- Events.luau
- LockOn.luau
- Admin.luau
- Sfx.at
- MonsterFx.luau
- LobbyUI.luau
- Evolved.luau
- Abilities.luau
- script_parent_grunge
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- UltRunner.luau
- Caller.luau
- Grunge.text
- QuestUI.luau
- MapLoader.luau
- Settings.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- Run.luau
- Sandbox.luau
- script_parent_remotes
- AdminPanel.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltShopUI.luau
- game_getservice
- Run.payout
- Ghost.spawn
- Tutorial.luau
- Supplies.luau
- Fx.luau
- rs_shared_items

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 39 edges
7. `Kit.ring()` - 31 edges
8. `Ghost.step()` - 30 edges
9. `Sfx.at()` - 30 edges
10. `Grunge.text()` - 28 edges

## Surprising Connections (you probably didn't know these)
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `GA.update()` --calls--> `EP.pose()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau → game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau
- `startMusic()` --calls--> `Sfx.loop()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau

## Import Cycles
- None detected.

## Communities (60 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.16
Nodes (26): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze(), Ghost.hit() (+18 more)

### Community 1 - "Intro.luau"
Cohesion: 0.09
Nodes (24): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+16 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.06
Nodes (61): Levels.need(), Levels.of(), Levels.title(), Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings(), Data.addCash() (+53 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (58): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+50 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (48): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+40 more)

### Community 7 - "Fire.luau"
Cohesion: 0.15
Nodes (18): maskBreath(), half(), MaskBreath.start(), pause(), sound(), bladeIgnite(), oneShot(), SawAudio.attach() (+10 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.20
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 15 - "Admin.luau"
Cohesion: 0.14
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.20
Nodes (23): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm() (+15 more)

### Community 23 - "script_parent_grunge"
Cohesion: 0.14
Nodes (10): Loading.isShown(), CallerUI.call(), Intro.play(), Intro.running(), LevelUI.init(), build(), Prompts.init(), play() (+2 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.16
Nodes (28): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+20 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.36
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+3 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "UltRunner.luau"
Cohesion: 0.17
Nodes (23): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+15 more)

### Community 29 - "Caller.luau"
Cohesion: 0.15
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 30 - "Grunge.text"
Cohesion: 0.19
Nodes (22): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+14 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "MapLoader.luau"
Cohesion: 0.27
Nodes (10): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+2 more)

### Community 35 - "Settings.luau"
Cohesion: 0.19
Nodes (17): actionOf(), KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind() (+9 more)

### Community 36 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.13
Nodes (9): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play(), ease() (+1 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (25): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+17 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.40
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "Run.luau"
Cohesion: 0.13
Nodes (33): onPlayer(), Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe() (+25 more)

### Community 44 - "Sandbox.luau"
Cohesion: 0.27
Nodes (13): Events.despawn(), Inventory.clear(), MapLoader.spawnInside(), Run.addToMatch(), Run.beginMatch(), Run.configure(), center(), enter() (+5 more)

### Community 46 - "script_parent_remotes"
Cohesion: 0.18
Nodes (13): Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp() (+5 more)

### Community 47 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "game/StarterPlayer/StarterPlayerScripts/Client/UltShopUI.luau"
Cohesion: 0.25
Nodes (3): Platform.menu(), Shop.open(), Shop.result()

### Community 51 - "game_getservice"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 52 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 53 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 54 - "Tutorial.luau"
Cohesion: 0.31
Nodes (11): Ghost.despawn(), Sandbox.active(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop() (+3 more)

### Community 56 - "Supplies.luau"
Cohesion: 0.32
Nodes (4): alive(), Supplies.clear(), Supplies.pick(), Supplies.spawn()

### Community 59 - "rs_shared_items"
Cohesion: 0.32
Nodes (3): clear(), selectedId(), step()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Supplies.luau`, `rs_shared_items`, `Events.luau`, `Abilities.luau`?**
  _High betweenness centrality (0.089) - this node is a cross-community bridge._
- **Should `Intro.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08961593172119488 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `Supplies.spawn()` connect `Supplies.luau` to `ItemModels.luau`, `MapLoader.luau`, `Inventory.luau`, `Run.luau`, `Events.luau`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06278538812785388 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.055176890619928594 - nodes in this community are weakly interconnected._