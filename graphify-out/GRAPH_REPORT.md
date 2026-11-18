# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 92 files · ~192,024 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1105 nodes · 3052 edges · 59 communities (43 shown, 16 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 689 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `590126c3`
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
- Caller.luau
- CineKit.luau
- Events.luau
- LockOn.luau
- Admin.luau
- Sfx.at
- Run.luau
- Platform.mode
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Abilities.luau
- Ragdoll.luau
- script_parent_grunge
- LobbyUI.luau
- QuestUI.luau
- Grunge.text
- TutorialUI.luau
- script_parent_platform
- MapLoader.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- AdminPanel.luau
- Entrance.luau
- Spectate.init
- Bestiary.luau
- Loading.luau
- Run.onDied
- Sandbox.luau
- Sfx.play
- Furniture.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- SawAudio.luau
- Run.payout
- Server/Tutorial.luau
- Grunge.brush
- NameTags.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 40 edges
7. `Kit.ring()` - 31 edges
8. `Ghost.step()` - 29 edges
9. `Sfx.at()` - 29 edges
10. `Grunge.text()` - 27 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.spawn()` --calls--> `Evolved.onSpawn()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Ragdoll.restoreWalls()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau

## Import Cycles
- None detected.

## Communities (59 total, 16 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.20
Nodes (20): Furniture.near(), Furniture.smash(), Ghost.burn(), Ghost.damage(), Ghost.freeze(), Ghost.hit(), Ghost.setVortex(), Ghost.slow() (+12 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.15
Nodes (11): beamOff(), beamTo(), blackout(), disc(), emitter(), jumpscare(), lightsOut(), near() (+3 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.08
Nodes (53): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.loaded() (+45 more)

### Community 5 - "Input.luau"
Cohesion: 0.09
Nodes (42): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+34 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (45): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+37 more)

### Community 7 - "Caller.luau"
Cohesion: 0.15
Nodes (18): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+10 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.08
Nodes (33): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+25 more)

### Community 12 - "Events.luau"
Cohesion: 0.11
Nodes (31): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+23 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.18
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 15 - "Admin.luau"
Cohesion: 0.14
Nodes (9): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), alive(), Supplies.clear(), Supplies.pick() (+1 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.15
Nodes (25): onPlayer(), Events.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), hrpOf(), insideHouse() (+17 more)

### Community 20 - "Platform.mode"
Cohesion: 0.30
Nodes (13): firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.label(), Platform.mode() (+5 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.13
Nodes (31): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+23 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.13
Nodes (28): Abilities.clear(), Evolved.interrupt(), Furniture.weight(), bringBack(), claw(), die(), floorBelow(), Ghost.alive() (+20 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.18
Nodes (27): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+19 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.restoreWalls(), Ragdoll.start() (+3 more)

### Community 26 - "script_parent_grunge"
Cohesion: 0.23
Nodes (8): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step(), CallerUI.call(), build(), Prompts.init()

### Community 27 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 29 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "TutorialUI.luau"
Cohesion: 0.31
Nodes (12): Loading.isShown(), answer(), button(), closeOffer(), fill(), inTutorial(), nextCard(), offer() (+4 more)

### Community 32 - "script_parent_platform"
Cohesion: 0.20
Nodes (6): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), Platform.windowOpen(), show()

### Community 34 - "MapLoader.luau"
Cohesion: 0.29
Nodes (10): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+2 more)

### Community 35 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 39 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 40 - "Bestiary.luau"
Cohesion: 0.27
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 41 - "Loading.luau"
Cohesion: 0.40
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "Run.onDied"
Cohesion: 0.29
Nodes (10): Monetization.start(), aliveCount(), aliveIn(), checkWipe(), endDeath(), Run.extendRevive(), Run.giveUp(), Run.onDied() (+2 more)

### Community 44 - "Sandbox.luau"
Cohesion: 0.47
Nodes (7): center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 46 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 47 - "Furniture.luau"
Cohesion: 0.29
Nodes (9): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+1 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.20
Nodes (12): Platform.menu(), button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave() (+4 more)

### Community 50 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 52 - "Run.payout"
Cohesion: 0.33
Nodes (5): areFriends(), Friends.mult(), refresh(), cashMult(), Run.payout()

### Community 54 - "Server/Tutorial.luau"
Cohesion: 0.19
Nodes (7): complete(), finish(), progress(), setStep(), start(), stop(), Tutorial.start()

### Community 57 - "Grunge.brush"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 60 - "NameTags.luau"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `Abilities.luau`, `Admin.luau`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `Spectate.init`, `CineKit.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `script_parent_grunge`, `LobbyUI.luau`, `QuestUI.luau`, `Grunge.text`, `TutorialUI.luau`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08240794856808883 - nodes in this community are weakly interconnected._
- **Why does `Supplies.spawn()` connect `Admin.luau` to `ItemModels.luau`, `MapLoader.luau`, `Inventory.luau`, `Events.luau`, `Run.luau`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08597285067873303 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0996078431372549 - nodes in this community are weakly interconnected._