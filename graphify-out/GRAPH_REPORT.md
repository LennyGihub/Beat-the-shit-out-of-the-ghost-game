# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-19)

## Corpus Check
- 124 files · ~327,088 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1681 nodes · 4739 edges · 85 communities (70 shown, 15 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 1026 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `fd306ba5`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- GhostAnim.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- Sfx.at
- rs_shared_config
- Events.luau
- Platform.mode
- CarnivalMonsters.luau
- FxTier.luau
- Sfx.at
- Intro.luau
- Caller.luau
- Evolved.luau
- Abilities.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- Ghost.step
- Viewmodel.luau
- Fury.luau
- Grunge.text
- QuestUI.luau
- Fire.luau
- HarborMonsters.luau
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Sfx.play
- CarnivalFx.luau
- TrainRide.luau
- Run.luau
- Monsters.luau
- RoomPickUI.luau
- CampFx.luau
- LockOn.luau
- CallerMarks.luau
- Sandbox.luau
- MapLoader.luau
- FormCine.luau
- Lobby.luau
- SellerUI.luau
- Mobile.luau
- CampMonsters.luau
- Tutorial.luau
- Run.startFight
- Leaderboards.luau
- Admin.luau
- script_parent_data
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- LobbyUI.init
- script_parent_sfx
- Knight.luau
- Run.payout
- AbbeyMonsters.luau
- Supplies.luau
- Levels.of
- Server/Quests.luau
- NameTags.luau
- Spots.find
- TicketShop.luau
- VialArt.luau
- MoonMonsters.luau
- SandboxUI.luau
- Combat.luau
- eyesOn
- onPlayer
- Abilities.clear

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 84 edges
2. `Sfx.play()` - 64 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `worn()` - 40 edges
8. `Data.get()` - 38 edges
9. `Grunge.text()` - 38 edges
10. `C()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `Run.stageCleared()` --calls--> `Campaign.cleared()`  [INFERRED]
  game/ServerScriptService/Server/Run.luau → game/ReplicatedStorage/Shared/Campaign.luau
- `UI.show()` --calls--> `pick()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/StageUI.luau → game/ReplicatedStorage/Shared/Monsters.luau
- `chunks()` --calls--> `Settings.fxCount()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `ringPhone()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `crouch()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau

## Import Cycles
- None detected.

## Communities (85 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.14
Nodes (25): Evolved.interrupt(), bringBack(), claw(), floorBelow(), Ghost.freeze(), Ghost.launch(), Ghost.setVortex(), Ghost.slow() (+17 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.13
Nodes (38): cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.equipForm(), Data.equipped() (+30 more)

### Community 5 - "Input.luau"
Cohesion: 0.07
Nodes (48): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+40 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.20
Nodes (28): Ghost.burn(), Ghost.shove(), alive(), applyFx(), consume(), explode(), get(), ghostAlive() (+20 more)

### Community 7 - "Sfx.at"
Cohesion: 0.08
Nodes (88): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+80 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.17
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.20
Nodes (27): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+19 more)

### Community 13 - "Platform.mode"
Cohesion: 0.07
Nodes (49): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+41 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.16
Nodes (26): armBall(), ball(), begin(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt() (+18 more)

### Community 16 - "FxTier.luau"
Cohesion: 0.26
Nodes (25): Campaign.stage(), bolt(), buildAura(), burst(), clearAura(), emit(), flashLight(), floorRing() (+17 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (69): Kit.near(), HUD.banner(), HUD.flash(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant(), Acts.heal() (+61 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (17): A(), about(), at(), drag(), eyeAt(), faceOf(), groundAt(), idle() (+9 more)

### Community 20 - "Caller.luau"
Cohesion: 0.18
Nodes (13): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+5 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.21
Nodes (22): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm() (+14 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.13
Nodes (26): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+18 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "Ghost.step"
Cohesion: 0.15
Nodes (28): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+20 more)

### Community 27 - "Viewmodel.luau"
Cohesion: 0.40
Nodes (4): C(), ease(), mirror(), sample()

### Community 29 - "Fury.luau"
Cohesion: 0.33
Nodes (8): Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp()

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 35 - "HarborMonsters.luau"
Cohesion: 0.18
Nodes (21): angDiff(), begin(), candidates(), dropProj(), face(), floorBelow(), flyStep(), fxFolder() (+13 more)

### Community 36 - "EntrancePose.luau"
Cohesion: 0.17
Nodes (4): f(), crouch(), EP.pose(), stride()

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (33): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+25 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.20
Nodes (15): Campaign.clock(), Levels.title(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab() (+7 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.17
Nodes (22): Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed(), onRequest() (+14 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.14
Nodes (29): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+21 more)

### Community 46 - "Run.luau"
Cohesion: 0.17
Nodes (14): Monetization.start(), aliveCount(), aliveIn(), checkWipe(), doorPrompt(), endDeath(), hrpOf(), onBuy() (+6 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.13
Nodes (40): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+32 more)

### Community 50 - "LockOn.luau"
Cohesion: 0.20
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 51 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 52 - "Sandbox.luau"
Cohesion: 0.21
Nodes (10): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy() (+2 more)

### Community 53 - "MapLoader.luau"
Cohesion: 0.27
Nodes (10): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+2 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+9 more)

### Community 56 - "Lobby.luau"
Cohesion: 0.30
Nodes (15): Data.ownsMap(), Data.tripsLeft(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket(), onPad() (+7 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.17
Nodes (17): Grunge.paint(), Platform.menu(), before(), button(), clear(), level(), owned(), progress() (+9 more)

### Community 59 - "Mobile.luau"
Cohesion: 0.33
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.35
Nodes (10): Data.setTutorialSeen(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "Run.startFight"
Cohesion: 0.23
Nodes (22): Campaign.nextStage(), Ghost.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), freshStats(), holdBody(), insideHouse() (+14 more)

### Community 63 - "Leaderboards.luau"
Cohesion: 0.24
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 64 - "Admin.luau"
Cohesion: 0.21
Nodes (7): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), M.setup(), settleAndTell()

### Community 65 - "script_parent_data"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "LobbyUI.init"
Cohesion: 0.20
Nodes (15): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.stageOpen(), Campaign.ticketsLeft(), LobbyUI.init() (+7 more)

### Community 68 - "script_parent_sfx"
Cohesion: 0.06
Nodes (26): CallerUI.call(), arrowShape(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey() (+18 more)

### Community 69 - "Knight.luau"
Cohesion: 0.31
Nodes (6): Abilities.interrupt(), face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 70 - "Run.payout"
Cohesion: 0.33
Nodes (5): areFriends(), Friends.mult(), refresh(), cashMult(), Run.payout()

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "Supplies.luau"
Cohesion: 0.26
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

### Community 73 - "Levels.of"
Cohesion: 0.32
Nodes (7): Levels.need(), Levels.of(), Levels.total(), Data.campaign(), Data.offline(), cancel(), offline()

### Community 74 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 75 - "NameTags.luau"
Cohesion: 0.29
Nodes (3): Vip.start(), onPlayer(), refresh()

### Community 76 - "Spots.find"
Cohesion: 0.70
Nodes (4): inBox(), Spots.find(), Spots.roomBox(), Spots.scan()

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "VialArt.luau"
Cohesion: 0.83
Nodes (3): fr(), VialArt.draw(), VialArt.icon()

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 81 - "Combat.luau"
Cohesion: 0.25
Nodes (3): KnightDoor.open(), KnightDoor.pick(), spots()

### Community 82 - "eyesOn"
Cohesion: 0.29
Nodes (7): eyesOn(), jerks(), kick(), lightsBack(), seg(), shake(), ss()

### Community 83 - "onPlayer"
Cohesion: 0.40
Nodes (6): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running()

### Community 84 - "Abilities.clear"
Cohesion: 0.50
Nodes (4): Abilities.clear(), smashHurled(), die(), Loot.clear()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Platform.mode`, `Sfx.at`, `MonsterFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `LobbyUI.init`, `script_parent_sfx`, `SandboxUI.luau`, `eyesOn`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **Are the 82 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 82 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13793103448275862 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `FxTier.luau`, `CampFx.luau`, `Sfx.at`, `MonsterFx.luau`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Are the 62 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 62 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._
- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._