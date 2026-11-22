# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-22)

## Corpus Check
- 154 files · ~463,835 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 2113 nodes · 6122 edges · 98 communities (80 shown, 18 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1311 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `291ccd11`
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
- Settings.luau
- CarnivalMonsters.luau
- FxTier.luau
- Sfx.at
- Intro.luau
- AdminPanel.luau
- Evolved.luau
- Viewmodel.luau
- MonsterFx.luau
- Abilities.luau
- Ghost.spawn
- src/ServerScriptService/Server/Run.luau
- src/ServerScriptService/Server/Ghost.luau
- src/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau
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
- src/StarterPlayer/StarterPlayerScripts/Client/Intro.luau
- TrainRide.luau
- Run.luau
- RoomPickUI.luau
- CampFx.luau
- LockOn.luau
- CallerMarks.luau
- Furniture.luau
- script_parent_events
- FormCine.luau
- FormGiant.luau
- SellerUI.luau
- rs_shared_config
- CampMonsters.luau
- Cursor.luau
- src/ServerScriptService/Server/Inventory.luau
- Sandbox.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- script_parent_sfx
- game_getservice
- Platform.mode
- AbbeyMonsters.luau
- src/StarterPlayer/StarterPlayerScripts/Client/Input.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- src/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- Hotbar.luau
- TicketShop.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- MoonMonsters.luau
- SandboxUI.luau
- GoblinLoot.luau
- Campaign.luau
- Charge.luau
- Caller.luau
- ThirdPersonItems.luau
- src/ServerScriptService/Server/Lobby.luau
- game/ServerScriptService/Server/Lobby.luau
- src/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- src/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau
- src/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau
- Leaderboards.luau
- script_parent_remotes
- game/ServerScriptService/Server/Tutorial.luau
- Knight.luau
- Server/Quests.luau
- game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau
- Spots.find
- Abilities.clear

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 86 edges
2. `Sfx.play()` - 72 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `Grunge.text()` - 44 edges
8. `worn()` - 40 edges
9. `Data.get()` - 38 edges
10. `Platform.mode()` - 34 edges

## Surprising Connections (you probably didn't know these)
- `startMusic()` --calls--> `Sfx.loop()`  [INFERRED]
  pending/src/StarterPlayer/StarterPlayerScripts/Client/Intro.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `chunks()` --calls--> `Settings.fxCount()`  [INFERRED]
  pending/src/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `ringPhone()` --calls--> `Sfx.play()`  [INFERRED]
  pending/src/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `report()` --calls--> `Platform.mode()`  [INFERRED]
  pending/src/StarterPlayer/StarterPlayerScripts/ClientMain.client.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau
- `setState()` --calls--> `Abilities.interrupt()`  [INFERRED]
  pending/src/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Abilities.luau

## Import Cycles
- None detected.

## Communities (98 total, 18 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.14
Nodes (31): bringBack(), die(), dropIt(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.despawn(), Ghost.dropMonster() (+23 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.16
Nodes (19): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+11 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.10
Nodes (49): Levels.need(), Levels.of(), Levels.total(), Bestiary.check(), Bestiary.record(), cleanSettings(), Data.addCash(), Data.addForm() (+41 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (20): Charge.active(), Charge.key(), Hotbar.cycle(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+12 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.20
Nodes (28): Ghost.burn(), Ghost.vuln(), alive(), applyFx(), consume(), explode(), get(), ghostAlive() (+20 more)

### Community 7 - "Sfx.at"
Cohesion: 0.08
Nodes (85): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+77 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Settings.luau"
Cohesion: 0.19
Nodes (17): actionOf(), KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind() (+9 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.16
Nodes (26): armBall(), ball(), begin(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt() (+18 more)

### Community 16 - "FxTier.luau"
Cohesion: 0.26
Nodes (25): Campaign.stage(), bolt(), buildAura(), burst(), clearAura(), emit(), flashLight(), floorRing() (+17 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (17): eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack(), reach() (+9 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.25
Nodes (14): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+6 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.13
Nodes (17): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.step() (+9 more)

### Community 22 - "Viewmodel.luau"
Cohesion: 0.40
Nodes (4): C(), ease(), mirror(), sample()

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.13
Nodes (26): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+18 more)

### Community 25 - "Ghost.spawn"
Cohesion: 0.11
Nodes (25): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+17 more)

### Community 26 - "src/ServerScriptService/Server/Run.luau"
Cohesion: 0.05
Nodes (68): areFriends(), Friends.mult(), refresh(), Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns() (+60 more)

### Community 27 - "src/ServerScriptService/Server/Ghost.luau"
Cohesion: 0.11
Nodes (48): Evolved.interrupt(), Furniture.near(), Furniture.smash(), Fury.comboCount(), Fury.smashes(), claw(), Ragdoll.breakWalls(), Runner.barrel() (+40 more)

### Community 29 - "src/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau"
Cohesion: 0.08
Nodes (22): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+14 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (19): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+11 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.25
Nodes (11): Platform.menu(), button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init() (+3 more)

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
Cohesion: 0.07
Nodes (24): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+16 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.19
Nodes (25): Campaign.clock(), Campaign.ticketsLeft(), Levels.title(), pick(), reveal(), frame(), Grunge.bar(), Grunge.brush() (+17 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.16
Nodes (24): CallerUI.call(), Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed() (+16 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 43 - "src/StarterPlayer/StarterPlayerScripts/Client/Intro.luau"
Cohesion: 0.08
Nodes (23): A(), about(), at(), drag(), eyeAt(), eyesOn(), faceOf(), groundAt() (+15 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.07
Nodes (48): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+40 more)

### Community 46 - "Run.luau"
Cohesion: 0.12
Nodes (43): onPlayer(), Events.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), MapLoader.spawnInside(), Monetization.start(), aliveCount(), aliveIn() (+35 more)

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

### Community 52 - "Furniture.luau"
Cohesion: 0.16
Nodes (20): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+12 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+9 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.19
Nodes (14): Grunge.paint(), before(), button(), clear(), level(), owned(), progress(), refresh() (+6 more)

### Community 59 - "rs_shared_config"
Cohesion: 0.18
Nodes (11): Fury.flung(), Fury.launch(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp(), Mobile.cone(), Mobile.ease() (+3 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.60
Nodes (4): Cursor.hold(), Cursor.init(), Cursor.toggle(), update()

### Community 63 - "src/ServerScriptService/Server/Inventory.luau"
Cohesion: 0.18
Nodes (30): Ghost.burn(), Ghost.freeze(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode() (+22 more)

### Community 64 - "Sandbox.luau"
Cohesion: 0.47
Nodes (8): center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "script_parent_sfx"
Cohesion: 0.08
Nodes (7): Fx.applyZone(), Fx.init(), HUD.hint(), HUD.setVisible(), layoutBars(), Shop.result(), report()

### Community 68 - "game_getservice"
Cohesion: 0.15
Nodes (10): Vip.start(), onPlayer(), refresh(), play(), remote(), UI.init(), Intro.running(), play() (+2 more)

### Community 69 - "Platform.mode"
Cohesion: 0.17
Nodes (22): HUD.update(), updateWaypoint(), liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu() (+14 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "src/StarterPlayer/StarterPlayerScripts/Client/Input.luau"
Cohesion: 0.27
Nodes (18): Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab(), hitDown(), hitUp() (+10 more)

### Community 73 - "game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau"
Cohesion: 0.27
Nodes (25): abbBody(), abbFist(), att(), bp(), bright(), bulbs(), campBody(), campFist() (+17 more)

### Community 74 - "src/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau"
Cohesion: 0.27
Nodes (25): abbBody(), abbFist(), att(), bp(), bright(), bulbs(), campBody(), campFist() (+17 more)

### Community 76 - "Hotbar.luau"
Cohesion: 0.36
Nodes (10): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh() (+2 more)

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.27
Nodes (10): finish(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey() (+2 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.20
Nodes (23): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), land() (+15 more)

### Community 82 - "Campaign.luau"
Cohesion: 0.35
Nodes (9): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen() (+1 more)

### Community 83 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 84 - "Caller.luau"
Cohesion: 0.18
Nodes (13): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+5 more)

### Community 85 - "ThirdPersonItems.luau"
Cohesion: 0.38
Nodes (3): clear(), selectedId(), step()

### Community 86 - "src/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.29
Nodes (16): Data.ownsMap(), Data.tripsLeft(), Campaign.stage(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket() (+8 more)

### Community 87 - "game/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.31
Nodes (14): Campaign.endlessOpen(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket(), onPad(), onParty() (+6 more)

### Community 88 - "src/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.19
Nodes (14): arrowShape(), fr(), VialArt.draw(), VialArt.icon(), finish(), arrowShape(), boardKey(), FT.init() (+6 more)

### Community 90 - "src/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau"
Cohesion: 0.13
Nodes (7): f(), Entrance.play(), structure(), crouch(), EP.height(), EP.pose(), stride()

### Community 91 - "src/StarterPlayer/StarterPlayerScripts/Client/GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 92 - "Leaderboards.luau"
Cohesion: 0.24
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 93 - "script_parent_remotes"
Cohesion: 0.09
Nodes (13): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Bestiary.setup(), M.setup(), settleAndTell() (+5 more)

### Community 95 - "game/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.20
Nodes (19): Data.setTutorialSeen(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+11 more)

### Community 97 - "Knight.luau"
Cohesion: 0.31
Nodes (6): Abilities.interrupt(), face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 98 - "Server/Quests.luau"
Cohesion: 0.53
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 99 - "game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau"
Cohesion: 0.19
Nodes (15): HUD.toast(), clear(), dust(), liftLabel(), monster(), ring(), WeakFx.handle(), WeakFx.init() (+7 more)

### Community 102 - "Spots.find"
Cohesion: 0.70
Nodes (4): inBox(), Spots.find(), Spots.roomBox(), Spots.scan()

### Community 104 - "Abilities.clear"
Cohesion: 0.67
Nodes (3): Abilities.clear(), smashHurled(), Loot.clear()

## Knowledge Gaps
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `GhostAnim.luau` to `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `Intro.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **Are the 84 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 84 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13968253968253969 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `AdminPanel.luau`, `MonsterFx.luau`, `src/ServerScriptService/Server/Run.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/Intro.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `script_parent_sfx`, `game_getservice`, `Platform.mode`, `src/StarterPlayer/StarterPlayerScripts/Client/Input.luau`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `SandboxUI.luau`, `Charge.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Are the 70 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 70 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `GhostAnim.luau`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._