# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 107 files · ~247,729 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1359 nodes · 3747 edges · 72 communities (57 shown, 15 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 846 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b61da1c1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- GhostAnim.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- Platform.mode
- rs_shared_config
- Events.luau
- LockOn.luau
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
- script_parent_grunge
- game_getservice
- Admin.luau
- MapLoader.luau
- FormCine.luau
- SandboxUI.luau
- SellerUI.luau
- Ghost.spawn
- CampMonsters.luau
- Tutorial.luau
- A
- Charge.luau
- HUD.luau
- script_parent_settings
- onPlayer
- Run.stageCleared
- Monsters.luau
- game_getservice
- Run.payout
- Entrance.play

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
- `UI.show()` --calls--> `pick()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/StageUI.luau → game/ReplicatedStorage/Shared/Monsters.luau
- `Abilities.clear()` --calls--> `Loot.clear()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau
- `ringPhone()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `crouch()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau
- `stride()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau

## Import Cycles
- None detected.

## Communities (72 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.18
Nodes (24): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze(), Ghost.hit() (+16 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.15
Nodes (31): Campaign.clean(), cleanSettings(), Data.addCash(), Data.addForm(), Data.addXP(), Data.equipForm(), Data.equipped(), Data.equipUlt() (+23 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (20): Charge.active(), Charge.key(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+12 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (45): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+37 more)

### Community 7 - "Platform.mode"
Cohesion: 0.21
Nodes (17): liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init() (+9 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.09
Nodes (31): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+23 more)

### Community 12 - "Events.luau"
Cohesion: 0.08
Nodes (39): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+31 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.33
Nodes (8): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target()

### Community 15 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+7 more)

### Community 16 - "AdminPanel.luau"
Cohesion: 0.29
Nodes (12): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+4 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (15): actionOf(), eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack() (+7 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.38
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
Cohesion: 0.07
Nodes (50): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+42 more)

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
Cohesion: 0.30
Nodes (14): Data.campaign(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), onPad(), onParty() (+6 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "Leaderboards.luau"
Cohesion: 0.24
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 35 - "Sfx.play"
Cohesion: 0.33
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+4 more)

### Community 36 - "EntrancePose.luau"
Cohesion: 0.17
Nodes (5): f(), crouch(), EP.pose(), stride(), Intro.play()

### Community 37 - "Entrance.luau"
Cohesion: 0.10
Nodes (12): bolt(), C(), disc(), entranceCrow(), part(), ring(), ringPhone(), seg() (+4 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.34
Nodes (12): reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+4 more)

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
Nodes (39): maskBreath(), half(), MaskBreath.start(), pause(), sound(), bladeIgnite(), oneShot(), SawAudio.attach() (+31 more)

### Community 46 - "Run.luau"
Cohesion: 0.11
Nodes (39): Events.despawn(), Furniture.reset(), Ghost.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn() (+31 more)

### Community 47 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.13
Nodes (40): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+32 more)

### Community 50 - "script_parent_grunge"
Cohesion: 0.12
Nodes (9): CallerUI.call(), Intro.running(), LevelUI.init(), build(), Prompts.init(), play(), remote(), UI.init() (+1 more)

### Community 51 - "game_getservice"
Cohesion: 0.21
Nodes (7): Levels.need(), Levels.of(), Levels.title(), Vip.start(), build(), onPlayer(), refresh()

### Community 52 - "Admin.luau"
Cohesion: 0.09
Nodes (17): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), MapLoader.spawnInside(), center(), enter() (+9 more)

### Community 53 - "MapLoader.luau"
Cohesion: 0.27
Nodes (10): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+2 more)

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
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.35
Nodes (10): Data.setTutorialSeen(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "A"
Cohesion: 0.20
Nodes (10): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+2 more)

### Community 63 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 64 - "HUD.luau"
Cohesion: 0.29
Nodes (6): HUD.hint(), HUD.setVisible(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint()

### Community 65 - "script_parent_settings"
Cohesion: 0.46
Nodes (6): apply(), clearOn(), emitter(), FL.init(), lowFx(), watch()

### Community 66 - "onPlayer"
Cohesion: 0.21
Nodes (9): onPlayer(), Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh(), Inventory.clear(), Run.addToMatch(), Run.beginMatch() (+1 more)

### Community 67 - "Run.stageCleared"
Cohesion: 0.33
Nodes (9): Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stage(), Campaign.stageOpen(), Data.clearStage() (+1 more)

### Community 69 - "game_getservice"
Cohesion: 0.38
Nodes (3): layout(), make(), TC.init()

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 71 - "Entrance.play"
Cohesion: 0.67
Nodes (3): Entrance.play(), structure(), EP.height()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `Events.luau`, `CampFx.luau`, `Intro.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.088) - this node is a cross-community bridge._
- **Are the 46 inferred relationships involving `Sfx.at()` (e.g. with `antlersStuck()` and `CF.handle()`) actually correct?**
  _`Sfx.at()` has 46 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.045454545454545456 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Platform.mode`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `LobbyUI.luau`, `MonsterFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `strobe`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `script_parent_grunge`, `FormCine.luau`, `SandboxUI.luau`, `SellerUI.luau`, `Charge.luau`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Are the 45 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 45 INFERRED edges - model-reasoned connections that need verification._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.14583333333333334 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `A`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._