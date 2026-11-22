# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-22)

## Corpus Check
- 131 files · ~350,264 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1784 nodes · 4960 edges · 88 communities (72 shown, 16 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1032 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `224c2513`
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
- MapLoader.luau
- Ragdoll.luau
- HarborFx.luau
- Grunge.text
- QuestUI.luau
- FormExclusive.luau
- HarborMonsters.luau
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Sfx.play
- CarnivalFx.luau
- eyesOn
- TrainRide.luau
- Run.luau
- Monsters.luau
- RoomPickUI.luau
- CampFx.luau
- LockOn.luau
- CallerMarks.luau
- Furniture.luau
- Supplies.luau
- FormCine.luau
- FormGiant.luau
- SellerUI.luau
- Fury.luau
- CampMonsters.luau
- CodesUI.luau
- Cursor.luau
- SawAudio.luau
- script_parent_remotes
- Friends.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- script_parent_grunge
- Sandbox.luau
- Platform.mode
- SandboxUI.luau
- AbbeyMonsters.luau
- LockOn.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- Hotbar.luau
- TicketShop.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- MoonMonsters.luau
- GoblinLoot.luau
- Run.stageCleared
- Charge.luau
- Caller.luau
- Fx.luau
- game/ServerScriptService/Server/Tutorial.luau
- Knight.luau
- game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 85 edges
2. `Sfx.play()` - 64 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `worn()` - 40 edges
8. `Grunge.text()` - 40 edges
9. `Data.get()` - 40 edges
10. `A()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `crouch()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau
- `stride()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau
- `C()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau

## Import Cycles
- None detected.

## Communities (88 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.11
Nodes (37): Abilities.clear(), Admin.start(), Furniture.weight(), bringBack(), claw(), die(), dropIt(), floorBelow() (+29 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.05
Nodes (87): Campaign.stage(), Levels.need(), Levels.of(), Levels.total(), Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings() (+79 more)

### Community 5 - "Input.luau"
Cohesion: 0.16
Nodes (22): Charge.active(), Charge.key(), Hotbar.cycle(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable() (+14 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (45): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+37 more)

### Community 7 - "Sfx.at"
Cohesion: 0.12
Nodes (58): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+50 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+7 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.16
Nodes (26): armBall(), ball(), begin(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt() (+18 more)

### Community 16 - "FxTier.luau"
Cohesion: 0.27
Nodes (24): bolt(), buildAura(), burst(), clearAura(), emit(), flashLight(), floorRing(), floorUnder() (+16 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (18): A(), about(), actionOf(), at(), drag(), eyeAt(), faceOf(), groundAt() (+10 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Viewmodel.luau"
Cohesion: 0.40
Nodes (4): C(), ease(), mirror(), sample()

### Community 23 - "MonsterFx.luau"
Cohesion: 0.14
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.13
Nodes (27): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+19 more)

### Community 25 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 26 - "MapLoader.luau"
Cohesion: 0.27
Nodes (11): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+3 more)

### Community 27 - "Ragdoll.luau"
Cohesion: 0.36
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+3 more)

### Community 29 - "HarborFx.luau"
Cohesion: 0.19
Nodes (27): place(), anchorSpin(), anchorWarn(), beamSweep(), burst(), diveBurst(), diveLock(), diveRing() (+19 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "FormExclusive.luau"
Cohesion: 0.23
Nodes (10): collectTints(), colors(), copyOf(), cube(), FX.shift(), newGlitch(), plain(), shiftSeq() (+2 more)

### Community 35 - "HarborMonsters.luau"
Cohesion: 0.18
Nodes (21): angDiff(), begin(), candidates(), dropProj(), face(), floorBelow(), flyStep(), fxFolder() (+13 more)

### Community 36 - "EntrancePose.luau"
Cohesion: 0.18
Nodes (4): f(), crouch(), EP.pose(), stride()

### Community 37 - "Entrance.luau"
Cohesion: 0.07
Nodes (24): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+16 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.18
Nodes (18): Campaign.clock(), Campaign.ticketsLeft(), Levels.title(), Vip.start(), reveal(), frame(), Grunge.bar(), Grunge.brush() (+10 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.17
Nodes (23): Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed(), onRequest() (+15 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 43 - "eyesOn"
Cohesion: 0.29
Nodes (7): eyesOn(), jerks(), kick(), lightsBack(), seg(), shake(), ss()

### Community 44 - "TrainRide.luau"
Cohesion: 0.10
Nodes (38): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+30 more)

### Community 46 - "Run.luau"
Cohesion: 0.11
Nodes (42): onPlayer(), Events.despawn(), Inventory.clear(), Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn() (+34 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.13
Nodes (40): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+32 more)

### Community 50 - "LockOn.luau"
Cohesion: 0.28
Nodes (5): LockOn.isOn(), LockOn.tracking(), layout(), make(), TC.init()

### Community 51 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 52 - "Furniture.luau"
Cohesion: 0.16
Nodes (24): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+16 more)

### Community 53 - "Supplies.luau"
Cohesion: 0.26
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.25
Nodes (17): C(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+9 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.17
Nodes (17): Campaign.clean(), Grunge.paint(), buildStages(), before(), button(), clear(), level(), owned() (+9 more)

### Community 59 - "Fury.luau"
Cohesion: 0.22
Nodes (13): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+5 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.18
Nodes (21): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+13 more)

### Community 61 - "CodesUI.luau"
Cohesion: 0.29
Nodes (9): button(), redeem(), say(), UI.close(), UI.init(), UI.open(), UI.result(), Platform.menu() (+1 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.25
Nodes (4): Cursor.hold(), Cursor.init(), Cursor.toggle(), update()

### Community 63 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 64 - "script_parent_remotes"
Cohesion: 0.10
Nodes (4): Admin.run(), isAdmin(), isFullAdmin(), passId()

### Community 65 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "script_parent_grunge"
Cohesion: 0.10
Nodes (11): M.setup(), settleAndTell(), CallerUI.call(), Intro.play(), build(), Prompts.init(), UI.close(), play() (+3 more)

### Community 68 - "Sandbox.luau"
Cohesion: 0.44
Nodes (9): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 69 - "Platform.mode"
Cohesion: 0.15
Nodes (22): HUD.hint(), HUD.setVisible(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), freeze(), firstButton() (+14 more)

### Community 70 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 73 - "game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau"
Cohesion: 0.27
Nodes (25): abbBody(), abbFist(), att(), bp(), bright(), bulbs(), campBody(), campFist() (+17 more)

### Community 76 - "Hotbar.luau"
Cohesion: 0.36
Nodes (10): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh() (+2 more)

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.19
Nodes (14): finish(), arrowShape(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel() (+6 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.29
Nodes (17): attach(), clearLine(), detach(), grab(), hand(), Loot.arm(), Loot.drop(), Loot.step() (+9 more)

### Community 82 - "Run.stageCleared"
Cohesion: 0.35
Nodes (9): Campaign.cleared(), Campaign.endlessOpen(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen() (+1 more)

### Community 83 - "Charge.luau"
Cohesion: 0.33
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 84 - "Caller.luau"
Cohesion: 0.14
Nodes (18): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+10 more)

### Community 85 - "Fx.luau"
Cohesion: 0.13
Nodes (5): Fx.applyZone(), Fx.init(), clear(), selectedId(), step()

### Community 93 - "game/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.33
Nodes (10): Sandbox.active(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 97 - "Knight.luau"
Cohesion: 0.36
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 99 - "game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau"
Cohesion: 0.36
Nodes (8): HUD.toast(), clear(), dust(), liftLabel(), monster(), ring(), WeakFx.handle(), WeakFx.init()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Are the 83 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 83 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11498257839721254 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `MonsterFx.luau`, `HarborFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `eyesOn`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `CodesUI.luau`, `script_parent_grunge`, `Platform.mode`, `SandboxUI.luau`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `Charge.luau`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **Are the 62 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 62 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.03571428571428571 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau`, `Sfx.at`, `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `FxTier.luau`, `CampFx.luau`, `MonsterFx.luau`, `HarborFx.luau`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._