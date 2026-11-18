# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 108 files · ~248,240 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1362 nodes · 3759 edges · 75 communities (60 shown, 15 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 847 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `61330ac8`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- GhostAnim.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- eyesOn
- rs_shared_config
- Events.luau
- Caller.luau
- Settings.luau
- AdminPanel.luau
- Sfx.at
- Intro.luau
- LobbyUI.luau
- Evolved.luau
- Abilities.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- UltRunner.luau
- Lobby.luau
- Grunge.text
- QuestUI.luau
- Leaderboards.luau
- Sfx.play
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- strobe
- TrainRide.luau
- Run.luau
- Server/Quests.luau
- RoomPickUI.luau
- CampFx.luau
- script_parent_sfx
- game_getservice
- Sandbox.luau
- MapLoader.luau
- FormCine.luau
- SandboxUI.luau
- SellerUI.luau
- Ghost.spawn
- CampMonsters.luau
- Tutorial.luau
- Run.startFight
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- Admin.luau
- Server/Forms.luau
- onPlayer
- Run.stageCleared
- Cursor.luau
- KeyHints.luau
- Run.payout
- Entrance.play
- Supplies.luau
- onPlayer
- Viewmodel.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `Sfx.at()` - 48 edges
3. `at()` - 47 edges
4. `V()` - 47 edges
5. `Sfx.play()` - 47 edges
6. `mark()` - 45 edges
7. `worn()` - 40 edges
8. `A()` - 33 edges
9. `Grunge.text()` - 32 edges
10. `Kit.ring()` - 31 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau

## Import Cycles
- None detected.

## Communities (75 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.18
Nodes (24): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze(), Ghost.hit() (+16 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.19
Nodes (13): EP.pose(), abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash() (+5 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.20
Nodes (25): Levels.of(), cleanSettings(), Data.addCash(), Data.addXP(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt() (+17 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (56): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+48 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.08
Nodes (45): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+37 more)

### Community 7 - "eyesOn"
Cohesion: 0.25
Nodes (9): eyesOn(), freeze(), jerks(), kick(), lightsBack(), seg(), shake(), ss() (+1 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.19
Nodes (27): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+19 more)

### Community 12 - "Events.luau"
Cohesion: 0.20
Nodes (27): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+19 more)

### Community 13 - "Caller.luau"
Cohesion: 0.14
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 15 - "Settings.luau"
Cohesion: 0.36
Nodes (9): apply(), load(), save(), Settings.bind(), Settings.fxScale(), Settings.init(), Settings.reset(), Settings.set() (+1 more)

### Community 16 - "AdminPanel.luau"
Cohesion: 0.11
Nodes (24): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+16 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (17): A(), about(), at(), drag(), eyeAt(), faceOf(), groundAt(), idle() (+9 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.44
Nodes (8): refreshPicks(), LobbyUI.init(), LobbyUI.invite(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList(), refreshVisible(), setOpen()

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.13
Nodes (32): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+24 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.14
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

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
Cohesion: 0.16
Nodes (24): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+16 more)

### Community 29 - "Lobby.luau"
Cohesion: 0.27
Nodes (14): Campaign.stage(), Data.campaign(), Data.clearStage(), hrpOf(), launch(), leaveParty(), onPad(), onParty() (+6 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "Leaderboards.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 35 - "Sfx.play"
Cohesion: 0.33
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+4 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.10
Nodes (12): bolt(), C(), disc(), entranceCrow(), part(), ring(), ringPhone(), seg() (+4 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.14
Nodes (16): Levels.need(), Levels.title(), pick(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel() (+8 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "strobe"
Cohesion: 0.18
Nodes (12): burst(), chunks(), darkness(), each(), emitter(), flash(), light(), puff() (+4 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.10
Nodes (36): maskBreath(), apply(), clearOn(), emitter(), FL.init(), lowFx(), watch(), half() (+28 more)

### Community 46 - "Run.luau"
Cohesion: 0.17
Nodes (17): Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), endDeath(), hrpOf(), insideHouse() (+9 more)

### Community 47 - "Server/Quests.luau"
Cohesion: 0.53
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.13
Nodes (40): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+32 more)

### Community 50 - "script_parent_sfx"
Cohesion: 0.09
Nodes (9): CallerUI.call(), Fx.applyZone(), Fx.init(), LevelUI.init(), bezier(), build(), Prompts.init(), label() (+1 more)

### Community 51 - "game_getservice"
Cohesion: 0.13
Nodes (9): f(), Vip.start(), Intro.play(), Intro.running(), onPlayer(), refresh(), play(), remote() (+1 more)

### Community 52 - "Sandbox.luau"
Cohesion: 0.23
Nodes (9): Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 53 - "MapLoader.luau"
Cohesion: 0.23
Nodes (13): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+5 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (18): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+10 more)

### Community 56 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.25
Nodes (13): Platform.menu(), button(), clear(), icon(), level(), owned(), refresh(), UI.close() (+5 more)

### Community 59 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.13
Nodes (25): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+17 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.35
Nodes (10): Ghost.despawn(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "Run.startFight"
Cohesion: 0.24
Nodes (19): Events.despawn(), Furniture.reset(), Inventory.clearWorld(), clearTemp(), doorPrompt(), freshStats(), holdBody(), onGhostDeath() (+11 more)

### Community 63 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 64 - "Admin.luau"
Cohesion: 0.31
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 65 - "Server/Forms.luau"
Cohesion: 0.27
Nodes (8): Data.addForm(), Data.equipForm(), Data.formOf(), Data.ownsForm(), buy(), equip(), sellerPart(), toast()

### Community 66 - "onPlayer"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 67 - "Run.stageCleared"
Cohesion: 0.36
Nodes (8): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), Run.stageCleared()

### Community 68 - "Cursor.luau"
Cohesion: 0.39
Nodes (6): Cursor.hold(), Cursor.init(), Cursor.toggle(), update(), actionOf(), Settings.input()

### Community 69 - "KeyHints.luau"
Cohesion: 0.48
Nodes (6): KeyHints.init(), refresh(), toggle(), Settings.get(), Settings.keyName(), Settings.setFlag()

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 71 - "Entrance.play"
Cohesion: 0.67
Nodes (3): Entrance.play(), structure(), EP.height()

### Community 72 - "Supplies.luau"
Cohesion: 0.47
Nodes (3): alive(), Supplies.pick(), Supplies.spawn()

### Community 73 - "onPlayer"
Cohesion: 0.40
Nodes (5): onPlayer(), Inventory.clear(), Lobby.returnPlayer(), Run.addToMatch(), Run.removeFromMatch()

### Community 74 - "Viewmodel.luau"
Cohesion: 0.50
Nodes (3): ease(), mirror(), sample()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `Viewmodel.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.071) - this node is a cross-community bridge._
- **Are the 46 inferred relationships involving `Sfx.at()` (e.g. with `antlersStuck()` and `CF.handle()`) actually correct?**
  _`Sfx.at()` has 46 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.04878048780487805 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `eyesOn`, `rs_shared_config`, `Sfx.at`, `LobbyUI.luau`, `MonsterFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `strobe`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `script_parent_sfx`, `game_getservice`, `FormCine.luau`, `SandboxUI.luau`, `SellerUI.luau`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 45 INFERRED edges - model-reasoned connections that need verification._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.056338028169014086 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `Intro.luau`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._