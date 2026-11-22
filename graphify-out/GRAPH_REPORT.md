# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-22)

## Corpus Check
- 131 files · ~349,165 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1783 nodes · 4977 edges · 90 communities (74 shown, 16 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1032 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `adac9eac`
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
- Main.server.luau
- FormExclusive.luau
- HarborMonsters.luau
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Sfx.play
- CarnivalFx.luau
- HUD.luau
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
- Bestiary.luau
- Friends.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- script_parent_grunge
- game_getservice
- Platform.mode
- CrewAnim.luau
- AbbeyMonsters.luau
- build
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
- game/ServerScriptService/Server/Lobby.luau
- script_parent_remotes
- Knight.luau
- Server/Quests.luau
- game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 85 edges
2. `Sfx.play()` - 64 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `Data.get()` - 40 edges
8. `worn()` - 40 edges
9. `Grunge.text()` - 40 edges
10. `A()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `UI.result()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/SellerUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau

## Import Cycles
- None detected.

## Communities (90 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.14
Nodes (32): Admin.start(), bringBack(), die(), dropIt(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.despawn() (+24 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (43): cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.campaign(), Data.clearStage(), Data.codeUsed() (+35 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (20): Charge.active(), Charge.key(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+12 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (45): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+37 more)

### Community 7 - "Sfx.at"
Cohesion: 0.12
Nodes (58): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+50 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.15
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.20
Nodes (27): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+19 more)

### Community 13 - "Settings.luau"
Cohesion: 0.20
Nodes (16): liftHint(), KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind() (+8 more)

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
Cohesion: 0.07
Nodes (23): graspHands(), makeHand(), A(), about(), actionOf(), at(), drag(), eyeAt() (+15 more)

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
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.11
Nodes (31): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+23 more)

### Community 25 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 26 - "MapLoader.luau"
Cohesion: 0.32
Nodes (10): folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn(), MapLoader.setSurroundings() (+2 more)

### Community 27 - "Ragdoll.luau"
Cohesion: 0.36
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+3 more)

### Community 29 - "HarborFx.luau"
Cohesion: 0.19
Nodes (27): place(), anchorSpin(), anchorWarn(), beamSweep(), burst(), diveBurst(), diveLock(), diveRing() (+19 more)

### Community 30 - "Grunge.text"
Cohesion: 0.19
Nodes (21): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+13 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 32 - "Main.server.luau"
Cohesion: 0.06
Nodes (15): Admin.run(), isAdmin(), isFullAdmin(), passId(), Data.loaded(), draw(), fmt(), isAdmin() (+7 more)

### Community 34 - "FormExclusive.luau"
Cohesion: 0.26
Nodes (16): colors(), copyOf(), cube(), drift(), FX.build(), FX.buildVM(), FX.burst(), FX.clearVM() (+8 more)

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
Cohesion: 0.34
Nodes (13): Campaign.ticketsLeft(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab() (+5 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.17
Nodes (23): Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed(), onRequest() (+15 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 43 - "HUD.luau"
Cohesion: 0.14
Nodes (14): HUD.hint(), HUD.setVisible(), HUD.update(), layoutBars(), updateWaypoint(), eyesOn(), freeze(), kick() (+6 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.10
Nodes (38): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+30 more)

### Community 46 - "Run.luau"
Cohesion: 0.11
Nodes (42): onPlayer(), Events.despawn(), Inventory.clear(), Inventory.clearWorld(), Lobby.returnPlayer(), MapLoader.spawnInside(), Monetization.start(), aliveCount() (+34 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.13
Nodes (38): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+30 more)

### Community 50 - "LockOn.luau"
Cohesion: 0.20
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 51 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 52 - "Furniture.luau"
Cohesion: 0.15
Nodes (25): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.hasTemplate(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+17 more)

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
Cohesion: 0.21
Nodes (14): before(), button(), clear(), level(), owned(), progress(), refresh(), setOpen() (+6 more)

### Community 59 - "Fury.luau"
Cohesion: 0.29
Nodes (10): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+2 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.18
Nodes (21): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+13 more)

### Community 61 - "CodesUI.luau"
Cohesion: 0.29
Nodes (9): button(), redeem(), say(), UI.close(), UI.init(), UI.open(), UI.result(), Platform.menu() (+1 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.48
Nodes (5): Cursor.hold(), Cursor.init(), Cursor.toggle(), update(), Settings.input()

### Community 63 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 64 - "Bestiary.luau"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 65 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.18
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

### Community 67 - "script_parent_grunge"
Cohesion: 0.12
Nodes (3): CallerUI.call(), UI.close(), Shop.result()

### Community 68 - "game_getservice"
Cohesion: 0.16
Nodes (8): Vip.start(), Intro.play(), Intro.running(), onPlayer(), refresh(), play(), remote(), UI.init()

### Community 69 - "Platform.mode"
Cohesion: 0.35
Nodes (11): firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.mode(), setMode() (+3 more)

### Community 70 - "CrewAnim.luau"
Cohesion: 0.50
Nodes (3): add(), CrewAnim.init(), joint()

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 73 - "game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau"
Cohesion: 0.27
Nodes (25): abbBody(), abbFist(), att(), bp(), bright(), bulbs(), campBody(), campFist() (+17 more)

### Community 76 - "Hotbar.luau"
Cohesion: 0.32
Nodes (11): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+3 more)

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.21
Nodes (13): finish(), arrowShape(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel() (+5 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 82 - "Run.stageCleared"
Cohesion: 0.17
Nodes (19): Campaign.clean(), Campaign.cleared(), Campaign.clock(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage() (+11 more)

### Community 83 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 84 - "Caller.luau"
Cohesion: 0.11
Nodes (27): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+19 more)

### Community 85 - "Fx.luau"
Cohesion: 0.17
Nodes (5): Fx.applyZone(), Fx.init(), clear(), selectedId(), step()

### Community 87 - "game/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.30
Nodes (15): Campaign.endlessOpen(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket(), onPad() (+7 more)

### Community 93 - "script_parent_remotes"
Cohesion: 0.12
Nodes (21): M.setup(), settleAndTell(), Furniture.reset(), Run.setSandbox(), center(), enter(), leave(), Sandbox.active() (+13 more)

### Community 97 - "Knight.luau"
Cohesion: 0.43
Nodes (4): face(), Knight.step(), Knight.try(), sees()

### Community 98 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 99 - "game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau"
Cohesion: 0.36
Nodes (8): HUD.toast(), clear(), dust(), liftLabel(), monster(), ring(), WeakFx.handle(), WeakFx.init()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.085) - this node is a cross-community bridge._
- **Are the 83 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 83 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13663663663663664 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `MonsterFx.luau`, `HarborFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Spectate.init`, `CarnivalFx.luau`, `HUD.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `CodesUI.luau`, `script_parent_grunge`, `game_getservice`, `build`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `Run.stageCleared`, `Charge.luau`, `Caller.luau`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Are the 62 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 62 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0392156862745098 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau`, `Sfx.at`, `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `FxTier.luau`, `CampFx.luau`, `Intro.luau`, `MonsterFx.luau`, `HarborFx.luau`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._