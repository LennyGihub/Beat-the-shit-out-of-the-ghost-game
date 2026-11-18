# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 107 files · ~236,645 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1314 nodes · 3595 edges · 72 communities (57 shown, 15 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 822 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3a7ea1bd`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- GhostAnim.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Input.luau
- Inventory.luau
- MonsterFx.luau
- rs_shared_config
- Events.luau
- LockOn.luau
- Admin.luau
- Monsters.luau
- Sfx.at
- Intro.luau
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
- Knight.luau
- Sfx.play
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- Run.startFight
- TrainRide.luau
- Run.luau
- AdminPanel.luau
- RoomPickUI.luau
- CampFx.luau
- TutorialUI.luau
- game_getservice
- Admin.luau
- MapLoader.luau
- FormCine.luau
- Lobby.luau
- SellerUI.luau
- Ghost.spawn
- CampMonsters.luau
- Tutorial.luau
- Supplies.luau
- Levels.of
- script_parent_remotes
- Server/Quests.luau
- Sandbox.luau
- Run.stageCleared
- A
- game_getservice
- Run.payout
- part

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `at()` - 47 edges
3. `V()` - 47 edges
4. `Sfx.play()` - 46 edges
5. `mark()` - 45 edges
6. `worn()` - 40 edges
7. `Sfx.at()` - 38 edges
8. `Grunge.text()` - 32 edges
9. `Kit.ring()` - 31 edges
10. `Ghost.step()` - 30 edges

## Surprising Connections (you probably didn't know these)
- `UI.show()` --calls--> `pick()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/StageUI.luau → game/ReplicatedStorage/Shared/Monsters.luau
- `Abilities.interrupt()` --calls--> `Knight.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/Knight.luau
- `Abilities.clear()` --calls--> `Loot.clear()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (72 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.14
Nodes (32): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.burn(), Ghost.damage(), Ghost.freeze() (+24 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.19
Nodes (13): EP.pose(), abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash() (+5 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.17
Nodes (29): cleanSettings(), Data.addCash(), Data.addForm(), Data.addXP(), Data.campaign(), Data.clearStage(), Data.equipForm(), Data.equipped() (+21 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (63): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+55 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (42): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+34 more)

### Community 7 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.33
Nodes (8): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target()

### Community 15 - "Admin.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (15): actionOf(), eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack() (+7 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.44
Nodes (8): refreshPicks(), LobbyUI.init(), LobbyUI.invite(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList(), refreshVisible(), setOpen()

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.13
Nodes (31): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+23 more)

### Community 23 - "script_parent_grunge"
Cohesion: 0.14
Nodes (6): CallerUI.call(), LevelUI.init(), build(), Prompts.init(), UI.close(), Shop.result()

### Community 24 - "Abilities.luau"
Cohesion: 0.16
Nodes (28): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+20 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "UltRunner.luau"
Cohesion: 0.17
Nodes (23): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+15 more)

### Community 29 - "Caller.luau"
Cohesion: 0.12
Nodes (26): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+18 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "Knight.luau"
Cohesion: 0.36
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 35 - "Sfx.play"
Cohesion: 0.33
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+4 more)

### Community 36 - "EntrancePose.luau"
Cohesion: 0.20
Nodes (3): Entrance.play(), structure(), EP.height()

### Community 37 - "Entrance.luau"
Cohesion: 0.10
Nodes (16): burst(), C(), chunks(), darkness(), each(), emitter(), flash(), light() (+8 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.41
Nodes (11): reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+3 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "Run.startFight"
Cohesion: 0.22
Nodes (22): onPlayer(), Ghost.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), freshStats(), holdBody(), insideHouse() (+14 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.10
Nodes (35): maskBreath(), apply(), clearOn(), emitter(), FL.init(), lowFx(), watch(), half() (+27 more)

### Community 46 - "Run.luau"
Cohesion: 0.17
Nodes (14): Monetization.start(), aliveCount(), aliveIn(), checkWipe(), doorPrompt(), endDeath(), hrpOf(), onBuy() (+6 more)

### Community 47 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (33): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+25 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.22
Nodes (16): burst(), CF.handle(), clearHook(), dropLand(), dropWarn(), floodStart(), folder(), handOf() (+8 more)

### Community 50 - "TutorialUI.luau"
Cohesion: 0.24
Nodes (6): f(), Intro.play(), Intro.running(), play(), remote(), UI.init()

### Community 51 - "game_getservice"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 52 - "Admin.luau"
Cohesion: 0.27
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 53 - "MapLoader.luau"
Cohesion: 0.21
Nodes (13): Events.despawn(), Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init() (+5 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF(), mk() (+9 more)

### Community 56 - "Lobby.luau"
Cohesion: 0.31
Nodes (14): Campaign.stage(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), onPad(), onParty() (+6 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.25
Nodes (13): Platform.menu(), button(), clear(), icon(), level(), owned(), refresh(), UI.close() (+5 more)

### Community 59 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.27
Nodes (7): CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), live(), sees()

### Community 61 - "Tutorial.luau"
Cohesion: 0.38
Nodes (9): enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start(), tutorialFight() (+1 more)

### Community 62 - "Supplies.luau"
Cohesion: 0.20
Nodes (3): alive(), Supplies.pick(), Supplies.spawn()

### Community 63 - "Levels.of"
Cohesion: 0.67
Nodes (3): Levels.need(), Levels.of(), Levels.title()

### Community 64 - "script_parent_remotes"
Cohesion: 0.15
Nodes (7): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh(), buy(), sellerPart(), toast()

### Community 65 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 66 - "Sandbox.luau"
Cohesion: 0.38
Nodes (10): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy() (+2 more)

### Community 67 - "Run.stageCleared"
Cohesion: 0.36
Nodes (8): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), Run.stageCleared()

### Community 68 - "A"
Cohesion: 0.14
Nodes (13): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+5 more)

### Community 69 - "game_getservice"
Cohesion: 0.38
Nodes (3): layout(), make(), TC.init()

### Community 70 - "Run.payout"
Cohesion: 0.33
Nodes (5): areFriends(), Friends.mult(), refresh(), cashMult(), Run.payout()

### Community 71 - "part"
Cohesion: 0.40
Nodes (5): bolt(), disc(), part(), ring(), slabPart()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `TrainRide.luau`, `Intro.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Are the 44 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 44 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13968253968253969 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `MonsterFx.luau`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `LobbyUI.luau`, `script_parent_grunge`, `Caller.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `TutorialUI.luau`, `FormCine.luau`, `SellerUI.luau`?**
  _High betweenness centrality (0.070) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `A`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05627705627705628 - nodes in this community are weakly interconnected._