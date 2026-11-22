# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-22)

## Corpus Check
- 132 files · ~352,870 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1802 nodes · 5008 edges · 96 communities (79 shown, 17 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1043 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9baa5efb`
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
- Settings.luau
- CarnivalMonsters.luau
- FxTier.luau
- Sfx.at
- Intro.luau
- AdminPanel.luau
- Evolved.luau
- A
- MonsterFx.luau
- Abilities.luau
- FormsPage.luau
- MapLoader.luau
- Ragdoll.luau
- HarborFx.luau
- Grunge.text
- QuestUI.luau
- script_parent_settings
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
- Sandbox.luau
- Friends.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- script_parent_grunge
- game/ServerScriptService/Server/Lobby.luau
- Platform.mode
- SandboxUI.luau
- AbbeyMonsters.luau
- Run.startFight
- game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- Hotbar.luau
- TicketShop.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- MoonMonsters.luau
- Ghost.spawn
- GoblinLoot.luau
- Run.stageCleared
- rs_shared_config
- Caller.luau
- Fx.luau
- Leaderboards.luau
- Admin.luau
- Levels.of
- Server/Quests.luau
- NameTags.luau
- Charge.luau
- LockOn.luau
- game/ServerScriptService/Server/Tutorial.luau
- ThirdPersonItems.luau
- game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 85 edges
2. `Sfx.play()` - 66 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `Data.get()` - 42 edges
8. `Grunge.text()` - 42 edges
9. `worn()` - 40 edges
10. `A()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau
- `actionOf()` --calls--> `Settings.input()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `startMusic()` --calls--> `Sfx.loop()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau

## Import Cycles
- None detected.

## Communities (96 total, 17 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.10
Nodes (46): Furniture.near(), Furniture.smash(), bringBack(), claw(), die(), dropIt(), floorBelow(), Ghost.alive() (+38 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.13
Nodes (38): cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.codeUsed(), Data.equipForm() (+30 more)

### Community 5 - "Input.luau"
Cohesion: 0.17
Nodes (21): Charge.active(), Charge.key(), Hotbar.cycle(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable() (+13 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (46): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+38 more)

### Community 7 - "Sfx.at"
Cohesion: 0.12
Nodes (58): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+50 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.09
Nodes (55): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+47 more)

### Community 13 - "Settings.luau"
Cohesion: 0.21
Nodes (16): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+8 more)

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
Nodes (15): actionOf(), eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack() (+7 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.25
Nodes (14): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+6 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.13
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "A"
Cohesion: 0.14
Nodes (14): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+6 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.12
Nodes (29): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+21 more)

### Community 25 - "FormsPage.luau"
Cohesion: 0.20
Nodes (16): button(), FP.build(), FP.filter(), FP.refresh(), FP.select(), owned(), setIndex(), showDetail() (+8 more)

### Community 26 - "MapLoader.luau"
Cohesion: 0.19
Nodes (16): Events.despawn(), Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init() (+8 more)

### Community 27 - "Ragdoll.luau"
Cohesion: 0.32
Nodes (12): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+4 more)

### Community 29 - "HarborFx.luau"
Cohesion: 0.19
Nodes (28): place(), anchorSpin(), anchorWarn(), beamSweep(), burst(), diveBurst(), diveLock(), diveRing() (+20 more)

### Community 30 - "Grunge.text"
Cohesion: 0.19
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 32 - "script_parent_settings"
Cohesion: 0.17
Nodes (8): maskBreath(), half(), MaskBreath.start(), pause(), sound(), bladeIgnite(), Settings.group(), make()

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
Cohesion: 0.35
Nodes (13): Campaign.clock(), Campaign.ticketsLeft(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat() (+5 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.15
Nodes (25): CallerUI.call(), UI.result(), Sfx.play(), addForm(), button(), clear(), grid(), heading() (+17 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 43 - "script_parent_remotes"
Cohesion: 0.16
Nodes (10): Bestiary.check(), Bestiary.record(), Bestiary.setup(), M.reset(), Data.formCount(), Data.ownsForm(), Data.refresh(), equip() (+2 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.14
Nodes (29): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+21 more)

### Community 46 - "Run.luau"
Cohesion: 0.14
Nodes (23): onPlayer(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), doorPrompt() (+15 more)

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
Cohesion: 0.26
Nodes (10): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+2 more)

### Community 53 - "Supplies.luau"
Cohesion: 0.26
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.24
Nodes (18): C(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+10 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.21
Nodes (14): Grunge.paint(), before(), button(), clear(), level(), owned(), progress(), refresh() (+6 more)

### Community 59 - "Fury.luau"
Cohesion: 0.16
Nodes (14): Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp() (+6 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.18
Nodes (21): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+13 more)

### Community 61 - "CodesUI.luau"
Cohesion: 0.29
Nodes (9): button(), redeem(), say(), UI.close(), UI.init(), UI.open(), UI.result(), Platform.menu() (+1 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.60
Nodes (4): Cursor.hold(), Cursor.init(), Cursor.toggle(), update()

### Community 63 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 64 - "Sandbox.luau"
Cohesion: 0.24
Nodes (9): Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 65 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "script_parent_grunge"
Cohesion: 0.13
Nodes (8): Intro.play(), Intro.running(), build(), Prompts.init(), play(), remote(), UI.init(), Shop.result()

### Community 68 - "game/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.31
Nodes (15): Campaign.stage(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket(), onPad() (+7 more)

### Community 69 - "Platform.mode"
Cohesion: 0.22
Nodes (17): liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init() (+9 more)

### Community 70 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "Run.startFight"
Cohesion: 0.30
Nodes (14): Furniture.reset(), Inventory.clearWorld(), clearTemp(), freshStats(), holdBody(), onGhostDeath(), Run.endMatch(), Run.startFight() (+6 more)

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
Cohesion: 0.29
Nodes (10): finish(), arrowShape(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel() (+2 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.21
Nodes (22): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), land() (+14 more)

### Community 82 - "Run.stageCleared"
Cohesion: 0.29
Nodes (11): Campaign.clean(), Campaign.cleared(), Campaign.endlessOpen(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage() (+3 more)

### Community 83 - "rs_shared_config"
Cohesion: 0.33
Nodes (5): HUD.hint(), HUD.setVisible(), HUD.update(), layoutBars(), updateWaypoint()

### Community 84 - "Caller.luau"
Cohesion: 0.14
Nodes (18): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+10 more)

### Community 86 - "Leaderboards.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 87 - "Admin.luau"
Cohesion: 0.24
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 88 - "Levels.of"
Cohesion: 0.27
Nodes (9): Levels.need(), Levels.of(), Levels.title(), Levels.total(), Data.campaign(), Data.mapLevel(), Data.offline(), cancel() (+1 more)

### Community 89 - "Server/Quests.luau"
Cohesion: 0.53
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 90 - "NameTags.luau"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 91 - "Charge.luau"
Cohesion: 0.39
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 92 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 93 - "game/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.35
Nodes (10): Data.setTutorialSeen(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 94 - "ThirdPersonItems.luau"
Cohesion: 0.38
Nodes (3): clear(), selectedId(), step()

### Community 99 - "game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau"
Cohesion: 0.36
Nodes (8): HUD.toast(), clear(), dust(), liftLabel(), monster(), ring(), WeakFx.handle(), WeakFx.init()

## Knowledge Gaps
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `AdminPanel.luau`, `MonsterFx.luau`, `FormsPage.luau`, `HarborFx.luau`, `Grunge.text`, `QuestUI.luau`, `script_parent_settings`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `CodesUI.luau`, `script_parent_grunge`, `Platform.mode`, `SandboxUI.luau`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `Charge.luau`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Are the 83 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 83 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.103424178895877 - nodes in this community are weakly interconnected._
- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `Intro.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.058) - this node is a cross-community bridge._
- **Are the 64 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 64 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.03571428571428571 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `A`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._