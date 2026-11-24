# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-24)

## Corpus Check
- 171 files · ~437,124 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 2222 nodes · 6485 edges · 119 communities (102 shown, 17 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 1409 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7863f50c`
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
- src/ServerScriptService/Server/Data.luau
- Settings.luau
- CarnivalMonsters.luau
- FxTier.luau
- Sfx.at
- Intro.luau
- AdminPanel.luau
- Evolved.luau
- Viewmodel.luau
- SawAudio.luau
- Abilities.luau
- FormsPage.luau
- MapLoader.luau
- Ragdoll.luau
- game/ServerScriptService/Server/Lobby.luau
- Grunge.text
- QuestUI.luau
- PatchNotesUI.luau
- FormExclusive.luau
- HarborMonsters.luau
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Sfx.play
- CarnivalFx.luau
- script_parent_remotes
- TrainRide.luau
- fightBody
- src/ServerScriptService/Server/Run.luau
- RoomPickUI.luau
- Charge.luau
- LockOn.luau
- CallerMarks.luau
- Furniture.luau
- Supplies.luau
- game/ServerScriptService/Server/Share.luau
- FormGiant.luau
- SellerUI.luau
- src/ServerScriptService/Server/Inventory.luau
- CampMonsters.luau
- game/ServerScriptService/Main.server.luau
- Cursor.luau
- FreeCam.luau
- Sandbox.luau
- Friends.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- src/StarterPlayer/StarterPlayerScripts/ClientMain.client.luau
- Fire.luau
- Platform.mode
- SandboxUI.luau
- AbbeyMonsters.luau
- src/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- src/ServerScriptService/Server/Lobby.luau
- Hotbar.luau
- TicketShop.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- MoonMonsters.luau
- Leaderboards.luau
- GoblinLoot.luau
- Run.stageCleared
- Ghost.spawn
- Caller.luau
- game/ServerScriptService/Server/Tutorial.luau
- game/ServerScriptService/Server/Run.luau
- CodesUI.luau
- Knight.luau
- src/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- script_parent_remotes
- game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau
- src/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- Server/Quests.luau
- Data.load
- src/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- Levels.of
- Guard.ok
- src/StarterPlayer/StarterPlayerScripts/Client/SellerUI.luau
- src/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau
- game/ServerScriptService/Server/UltRunner.luau
- src/ServerScriptService/Server/Analytics.luau
- src/ServerScriptService/Server/Share.luau
- src/ServerScriptService/Server/Tutorial.luau
- fightBody
- eyesOn
- game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau
- Guard.ok
- Monetization.start
- game/StarterPlayer/StarterPlayerScripts/Client/Translate.luau
- src/ServerScriptService/Server/Mobile.luau
- enter
- src/StarterPlayer/StarterPlayerScripts/Client/Translate.luau
- Server/Vip.luau
- Bestiary.check

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 85 edges
2. `Sfx.play()` - 80 edges
3. `Grunge.text()` - 56 edges
4. `p()` - 50 edges
5. `at()` - 47 edges
6. `V()` - 47 edges
7. `Data.get()` - 47 edges
8. `Data.get()` - 45 edges
9. `mark()` - 45 edges
10. `worn()` - 40 edges

## Surprising Connections (you probably didn't know these)
- `UI.reward()` --calls--> `Sfx.play()`  [INFERRED]
  pending/src/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `layoutBars()` --calls--> `Platform.mode()`  [INFERRED]
  pending/src/StarterPlayer/StarterPlayerScripts/Client/HUD.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau
- `explode()` --calls--> `Furniture.near()`  [INFERRED]
  pending/src/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Furniture.luau
- `explode()` --calls--> `Furniture.smash()`  [INFERRED]
  pending/src/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Furniture.luau
- `ghostAlive()` --calls--> `Ghost.alive()`  [INFERRED]
  pending/src/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau

## Import Cycles
- None detected.

## Communities (119 total, 17 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.12
Nodes (36): Furniture.near(), Furniture.smash(), bringBack(), claw(), die(), dropIt(), floorBelow(), Ghost.alive() (+28 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.13
Nodes (40): Bestiary.check(), Bestiary.record(), M.reset(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.codeUsed() (+32 more)

### Community 5 - "Input.luau"
Cohesion: 0.16
Nodes (21): Charge.active(), Charge.key(), Hotbar.cycle(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable() (+13 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.18
Nodes (29): Ghost.vuln(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+21 more)

### Community 7 - "Sfx.at"
Cohesion: 0.08
Nodes (85): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+77 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.09
Nodes (54): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+46 more)

### Community 12 - "src/ServerScriptService/Server/Data.luau"
Cohesion: 0.15
Nodes (34): M.reset(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.codeUsed(), Data.equipForm(), Data.equipped() (+26 more)

### Community 13 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), defaultFx(), load(), save(), Settings.bind() (+7 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.16
Nodes (26): armBall(), ball(), begin(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt() (+18 more)

### Community 16 - "FxTier.luau"
Cohesion: 0.27
Nodes (24): bolt(), buildAura(), burst(), clearAura(), emit(), flashLight(), floorRing(), floorUnder() (+16 more)

### Community 18 - "Sfx.at"
Cohesion: 0.07
Nodes (110): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+102 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (17): A(), about(), actionOf(), at(), drag(), eyeAt(), faceOf(), groundAt() (+9 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.29
Nodes (12): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+4 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.13
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Viewmodel.luau"
Cohesion: 0.40
Nodes (4): C(), ease(), mirror(), sample()

### Community 23 - "SawAudio.luau"
Cohesion: 0.20
Nodes (12): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+4 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.14
Nodes (25): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.spawnClones(), Abilities.step(), Abilities.tick(), Abilities.try() (+17 more)

### Community 25 - "FormsPage.luau"
Cohesion: 0.22
Nodes (16): button(), FP.build(), FP.filter(), FP.refresh(), FP.select(), owned(), setIndex(), showDetail() (+8 more)

### Community 26 - "MapLoader.luau"
Cohesion: 0.16
Nodes (19): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+11 more)

### Community 27 - "Ragdoll.luau"
Cohesion: 0.32
Nodes (12): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+4 more)

### Community 29 - "game/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.24
Nodes (18): Campaign.stage(), Data.campaign(), Data.equipped(), Data.ownsMap(), Data.tripsLeft(), hrpOf(), launch(), leaveParty() (+10 more)

### Community 30 - "Grunge.text"
Cohesion: 0.16
Nodes (23): refreshPicks(), BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges() (+15 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 32 - "PatchNotesUI.luau"
Cohesion: 0.32
Nodes (9): build(), button(), fitText(), refreshButton(), UI.close(), UI.init(), UI.open(), Platform.windowOpen() (+1 more)

### Community 34 - "FormExclusive.luau"
Cohesion: 0.23
Nodes (10): collectTints(), colors(), copyOf(), cube(), FX.shift(), newGlitch(), plain(), shiftSeq() (+2 more)

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
Cohesion: 0.25
Nodes (17): Campaign.clean(), Levels.title(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab() (+9 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.12
Nodes (28): CallerUI.call(), Grunge.paint(), UI.result(), Sfx.play(), addForm(), button(), clear(), grid() (+20 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 43 - "script_parent_remotes"
Cohesion: 0.18
Nodes (8): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Admin.run(), isAdmin(), isFullAdmin()

### Community 44 - "TrainRide.luau"
Cohesion: 0.06
Nodes (56): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+48 more)

### Community 46 - "fightBody"
Cohesion: 0.29
Nodes (15): Events.despawn(), Inventory.clearWorld(), clearTemp(), doorPrompt(), fightBody(), freshStats(), holdBody(), onGhostDeath() (+7 more)

### Community 47 - "src/ServerScriptService/Server/Run.luau"
Cohesion: 0.14
Nodes (26): onPlayer(), Lobby.returnPlayer(), aliveCount(), aliveIn(), cashMult(), checkWipe(), doorPrompt(), endDeath() (+18 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "Charge.luau"
Cohesion: 0.39
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 50 - "LockOn.luau"
Cohesion: 0.20
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 51 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 52 - "Furniture.luau"
Cohesion: 0.19
Nodes (13): answer(), placeHint(), M.start(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid() (+5 more)

### Community 53 - "Supplies.luau"
Cohesion: 0.29
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

### Community 54 - "game/ServerScriptService/Server/Share.luau"
Cohesion: 0.14
Nodes (24): Analytics.cash(), Analytics.custom(), Analytics.joined(), Analytics.lesson(), Analytics.onboard(), Analytics.stage(), fields(), logStep() (+16 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.23
Nodes (13): before(), button(), clear(), level(), owned(), progress(), refresh(), setOpen() (+5 more)

### Community 59 - "src/ServerScriptService/Server/Inventory.luau"
Cohesion: 0.22
Nodes (26): alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear(), Inventory.give() (+18 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.09
Nodes (39): C(), pick(), begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face() (+31 more)

### Community 61 - "game/ServerScriptService/Main.server.luau"
Cohesion: 0.13
Nodes (4): Bestiary.setup(), display(), Evolved.dress(), display()

### Community 62 - "Cursor.luau"
Cohesion: 0.48
Nodes (5): Cursor.hold(), Cursor.init(), Cursor.toggle(), update(), Settings.input()

### Community 63 - "FreeCam.luau"
Cohesion: 0.33
Nodes (10): bindKeys(), FC.init(), FC.set(), makeHint(), playerControls(), refreshHint(), setUiHidden(), shiftDown() (+2 more)

### Community 64 - "Sandbox.luau"
Cohesion: 0.48
Nodes (7): Run.setSandbox(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 65 - "Friends.luau"
Cohesion: 0.40
Nodes (4): areFriends(), Friends.mult(), refresh(), cashMult()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.15
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 68 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 69 - "Platform.mode"
Cohesion: 0.19
Nodes (19): setSpray(), update(), liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu() (+11 more)

### Community 70 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "src/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau"
Cohesion: 0.23
Nodes (17): C(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+9 more)

### Community 73 - "game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau"
Cohesion: 0.27
Nodes (25): abbBody(), abbFist(), att(), bp(), bright(), bulbs(), campBody(), campFist() (+17 more)

### Community 74 - "game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau"
Cohesion: 0.29
Nodes (5): HUD.hint(), HUD.setVisible(), HUD.update(), layoutBars(), updateWaypoint()

### Community 75 - "src/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.25
Nodes (17): Campaign.endlessOpen(), Data.campaign(), Data.ownsMap(), Data.tripsLeft(), hrpOf(), launch(), leaveParty(), Lobby.start() (+9 more)

### Community 76 - "Hotbar.luau"
Cohesion: 0.44
Nodes (8): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh()

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.19
Nodes (14): arrowShape(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey() (+6 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "Leaderboards.luau"
Cohesion: 0.30
Nodes (10): draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top(), write() (+2 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.13
Nodes (31): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+23 more)

### Community 82 - "Run.stageCleared"
Cohesion: 0.32
Nodes (12): Campaign.cleared(), Campaign.clock(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen() (+4 more)

### Community 83 - "Ghost.spawn"
Cohesion: 0.16
Nodes (14): Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open(), KnightDoor.pick(), spots() (+6 more)

### Community 84 - "Caller.luau"
Cohesion: 0.15
Nodes (17): Abilities.clear(), smashHurled(), buildPhone(), Caller.clear(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 85 - "game/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.33
Nodes (10): Sandbox.active(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 86 - "game/ServerScriptService/Server/Run.luau"
Cohesion: 0.20
Nodes (19): onPlayer(), Monetization.start(), aliveCount(), aliveIn(), checkWipe(), endDeath(), hrpOf(), insideHouse() (+11 more)

### Community 87 - "CodesUI.luau"
Cohesion: 0.29
Nodes (9): button(), redeem(), say(), UI.close(), UI.init(), UI.open(), UI.result(), Platform.menu() (+1 more)

### Community 88 - "Knight.luau"
Cohesion: 0.31
Nodes (7): Abilities.interrupt(), Caller.interrupt(), face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 89 - "src/StarterPlayer/StarterPlayerScripts/Client/Settings.luau"
Cohesion: 0.19
Nodes (11): apply(), defaultFx(), load(), save(), Settings.bind(), Settings.fxScale(), Settings.init(), Settings.reset() (+3 more)

### Community 90 - "script_parent_remotes"
Cohesion: 0.14
Nodes (4): M.setup(), settleAndTell(), M.setup(), settleAndTell()

### Community 91 - "game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau"
Cohesion: 0.23
Nodes (15): button(), hideCard(), invite(), launchData(), refreshReward(), reward(), say(), shareLink() (+7 more)

### Community 93 - "src/StarterPlayer/StarterPlayerScripts/Client/HUD.luau"
Cohesion: 0.22
Nodes (4): HUD.setVisible(), HUD.update(), layoutBars(), updateWaypoint()

### Community 94 - "Server/Quests.luau"
Cohesion: 0.53
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 95 - "Data.load"
Cohesion: 0.29
Nodes (7): cleanSettings(), Data.grantCashReceipt(), Data.grantTripsReceipt(), Data.save(), Data.start(), publishSettings(), Lobby.returnPlayer()

### Community 96 - "src/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.33
Nodes (9): arrowShape(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey() (+1 more)

### Community 97 - "Levels.of"
Cohesion: 0.43
Nodes (6): Levels.need(), Levels.of(), Levels.total(), Data.load(), Data.mapLevel(), fresh()

### Community 98 - "Guard.ok"
Cohesion: 0.23
Nodes (14): drop(), Guard.int(), Guard.limit(), Guard.num(), Guard.ok(), Guard.vec(), claim(), progress() (+6 more)

### Community 99 - "src/StarterPlayer/StarterPlayerScripts/Client/SellerUI.luau"
Cohesion: 0.23
Nodes (13): before(), button(), clear(), level(), owned(), progress(), refresh(), setOpen() (+5 more)

### Community 100 - "src/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau"
Cohesion: 0.23
Nodes (15): button(), hideCard(), invite(), launchData(), refreshReward(), reward(), say(), shareLink() (+7 more)

### Community 101 - "game/ServerScriptService/Server/UltRunner.luau"
Cohesion: 0.28
Nodes (12): Ghost.burn(), Ghost.setVortex(), Ghost.slow(), barrage(), fling(), ghostPos(), Runner.barrel(), Runner.explode() (+4 more)

### Community 102 - "src/ServerScriptService/Server/Analytics.luau"
Cohesion: 0.27
Nodes (11): Analytics.cash(), Analytics.custom(), Analytics.joined(), Analytics.lesson(), Analytics.onboard(), Analytics.stage(), fields(), logStep() (+3 more)

### Community 103 - "src/ServerScriptService/Server/Share.luau"
Cohesion: 0.24
Nodes (13): Data.addCash(), Data.isNew(), Data.loaded(), Data.offline(), cancel(), claim(), credit(), Share.debugLink() (+5 more)

### Community 104 - "src/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.38
Nodes (10): Sandbox.active(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 105 - "fightBody"
Cohesion: 0.38
Nodes (11): Furniture.reset(), Ghost.despawn(), Supplies.clear(), Inventory.clearWorld(), clearTemp(), fightBody(), holdBody(), onStageChoice() (+3 more)

### Community 106 - "eyesOn"
Cohesion: 0.29
Nodes (7): eyesOn(), jerks(), kick(), lightsBack(), seg(), shake(), ss()

### Community 107 - "game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau"
Cohesion: 0.36
Nodes (8): HUD.toast(), clear(), dust(), liftLabel(), monster(), ring(), WeakFx.handle(), WeakFx.init()

### Community 108 - "Guard.ok"
Cohesion: 0.33
Nodes (7): drop(), Guard.int(), Guard.limit(), Guard.num(), Guard.ok(), Guard.vec(), Mobile.start()

### Community 109 - "Monetization.start"
Cohesion: 0.25
Nodes (9): cleanSettings(), Data.grantCashReceipt(), Data.grantTripsReceipt(), Data.save(), Data.start(), publishSettings(), Monetization.start(), Run.extendRevive() (+1 more)

### Community 110 - "game/StarterPlayer/StarterPlayerScripts/Client/Translate.luau"
Cohesion: 0.57
Nodes (5): lookup(), remember(), store(), T.auto(), T.t()

### Community 111 - "src/ServerScriptService/Server/Mobile.luau"
Cohesion: 0.48
Nodes (6): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share(), Mobile.start()

### Community 112 - "enter"
Cohesion: 0.48
Nodes (7): Run.setSandbox(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 113 - "src/StarterPlayer/StarterPlayerScripts/Client/Translate.luau"
Cohesion: 0.57
Nodes (5): lookup(), remember(), store(), T.auto(), T.t()

### Community 115 - "Server/Vip.luau"
Cohesion: 0.33
Nodes (3): Vip.start(), onPlayer(), refresh()

### Community 116 - "Bestiary.check"
Cohesion: 0.67
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

## Knowledge Gaps
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `FormsPage.luau`, `Grunge.text`, `QuestUI.luau`, `PatchNotesUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `Charge.luau`, `SellerUI.luau`, `CampMonsters.luau`, `Platform.mode`, `SandboxUI.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `CodesUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/SellerUI.luau`, `src/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau`, `eyesOn`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Are the 83 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 83 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12439024390243902 - nodes in this community are weakly interconnected._
- **Why does `TR.arrive()` connect `TrainRide.luau` to `Sfx.play`, `Sfx.at`, `game/ServerScriptService/Server/Tutorial.luau`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Are the 78 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 78 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.03773584905660377 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `Sfx.at`, `rs_shared_config`, `CarnivalFx.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau`, `TrainRide.luau`, `FxTier.luau`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._