# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-22)

## Corpus Check
- 135 files · ~357,339 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1831 nodes · 5075 edges · 100 communities (83 shown, 17 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1057 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cee9b713`
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
- Cursor.luau
- FreeCam.luau
- Sandbox.luau
- Friends.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- script_parent_grunge
- Fire.luau
- Platform.mode
- SandboxUI.luau
- AbbeyMonsters.luau
- script_parent_data
- game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- Hotbar.luau
- TicketShop.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- MoonMonsters.luau
- Leaderboards.luau
- GoblinLoot.luau
- Run.stageCleared
- rs_shared_config
- Caller.luau
- game/ServerScriptService/Server/Tutorial.luau
- Run.matchPlayers
- CodesUI.luau
- Knight.luau
- LockOn.luau
- Monetization.luau
- Charge.luau
- eyesOn
- Server/Quests.luau
- Data.load
- TutorialUI.luau
- Levels.of
- Spots.find
- Abilities.clear

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 85 edges
2. `Sfx.play()` - 69 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `Grunge.text()` - 45 edges
8. `Data.get()` - 44 edges
9. `worn()` - 40 edges
10. `A()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau

## Import Cycles
- None detected.

## Communities (100 total, 17 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.11
Nodes (38): Evolved.onSpawn(), bringBack(), die(), dropIt(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.dropMonster() (+30 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.15
Nodes (34): Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.campaign(), Data.clearStage(), Data.codeUsed(), Data.equipForm() (+26 more)

### Community 5 - "Input.luau"
Cohesion: 0.17
Nodes (21): Charge.active(), Charge.key(), Hotbar.cycle(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable() (+13 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.22
Nodes (26): Ghost.burn(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.give() (+18 more)

### Community 7 - "Sfx.at"
Cohesion: 0.08
Nodes (88): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+80 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.15
Nodes (30): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+22 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Settings.luau"
Cohesion: 0.20
Nodes (16): liftHint(), KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind() (+8 more)

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
Cohesion: 0.09
Nodes (16): A(), about(), at(), drag(), eyeAt(), faceOf(), groundAt(), idle() (+8 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.07
Nodes (34): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+26 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.10
Nodes (21): Abilities.cloneCount(), Abilities.spawnClones(), display(), add(), begin(), cd(), close(), done() (+13 more)

### Community 22 - "Viewmodel.luau"
Cohesion: 0.40
Nodes (4): C(), ease(), mirror(), sample()

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.15
Nodes (23): Abilities.blocks(), Abilities.hitClone(), Abilities.hurl(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish() (+15 more)

### Community 25 - "FormsPage.luau"
Cohesion: 0.26
Nodes (13): button(), FP.build(), FP.filter(), FP.refresh(), FP.select(), owned(), setIndex(), showDetail() (+5 more)

### Community 26 - "MapLoader.luau"
Cohesion: 0.23
Nodes (14): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+6 more)

### Community 27 - "Ragdoll.luau"
Cohesion: 0.36
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+3 more)

### Community 29 - "game/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.23
Nodes (18): Campaign.endlessOpen(), Data.equipped(), Data.ownsMap(), Data.tripsLeft(), tripWindow(), hrpOf(), launch(), leaveParty() (+10 more)

### Community 30 - "Grunge.text"
Cohesion: 0.19
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

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
Cohesion: 0.18
Nodes (4): f(), crouch(), EP.pose(), stride()

### Community 37 - "Entrance.luau"
Cohesion: 0.07
Nodes (24): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+16 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.18
Nodes (18): Campaign.clock(), Campaign.ticketsLeft(), Levels.title(), Vip.start(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel() (+10 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.17
Nodes (23): Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed(), onRequest() (+15 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 43 - "script_parent_remotes"
Cohesion: 0.15
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 44 - "TrainRide.luau"
Cohesion: 0.08
Nodes (42): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+34 more)

### Community 46 - "Run.luau"
Cohesion: 0.16
Nodes (21): Events.despawn(), Inventory.clearWorld(), cashMult(), clearTemp(), doorPrompt(), freshStats(), hrpOf(), insideHouse() (+13 more)

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
Nodes (10): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+2 more)

### Community 53 - "Supplies.luau"
Cohesion: 0.29
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.22
Nodes (19): C(), back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar() (+11 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.19
Nodes (15): Grunge.paint(), before(), button(), clear(), level(), owned(), progress(), refresh() (+7 more)

### Community 59 - "Fury.luau"
Cohesion: 0.17
Nodes (13): Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp() (+5 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.13
Nodes (32): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+24 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.39
Nodes (6): Cursor.hold(), Cursor.init(), Cursor.toggle(), update(), actionOf(), Settings.input()

### Community 63 - "FreeCam.luau"
Cohesion: 0.33
Nodes (10): bindKeys(), FC.init(), FC.set(), makeHint(), playerControls(), refreshHint(), setUiHidden(), shiftDown() (+2 more)

### Community 64 - "Sandbox.luau"
Cohesion: 0.36
Nodes (9): Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 65 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.21
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "script_parent_grunge"
Cohesion: 0.12
Nodes (6): M.setup(), settleAndTell(), CallerUI.call(), build(), Prompts.init(), Shop.result()

### Community 68 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 69 - "Platform.mode"
Cohesion: 0.35
Nodes (11): firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.mode(), setMode() (+3 more)

### Community 70 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "script_parent_data"
Cohesion: 0.17
Nodes (8): Bestiary.check(), Bestiary.record(), Bestiary.setup(), M.reset(), Data.formCount(), Data.ownsForm(), Data.refresh(), equip()

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

### Community 80 - "Leaderboards.luau"
Cohesion: 0.24
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.21
Nodes (22): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm() (+14 more)

### Community 82 - "Run.stageCleared"
Cohesion: 0.26
Nodes (12): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen() (+4 more)

### Community 83 - "rs_shared_config"
Cohesion: 0.33
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

### Community 84 - "Caller.luau"
Cohesion: 0.17
Nodes (15): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+7 more)

### Community 85 - "game/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.35
Nodes (10): Ghost.despawn(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 86 - "Run.matchPlayers"
Cohesion: 0.23
Nodes (13): onPlayer(), Inventory.clear(), Lobby.returnPlayer(), aliveCount(), aliveIn(), checkWipe(), endDeath(), respawnSpectators() (+5 more)

### Community 87 - "CodesUI.luau"
Cohesion: 0.29
Nodes (9): button(), redeem(), say(), UI.close(), UI.init(), UI.open(), UI.result(), Platform.menu() (+1 more)

### Community 88 - "Knight.luau"
Cohesion: 0.27
Nodes (8): Abilities.dropLevitated(), Abilities.interrupt(), ungrip(), face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 89 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 90 - "Monetization.luau"
Cohesion: 0.20
Nodes (4): Monetization.start(), Run.extendRevive(), Run.revive(), Run.watch()

### Community 91 - "Charge.luau"
Cohesion: 0.23
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 93 - "eyesOn"
Cohesion: 0.22
Nodes (10): eyesOn(), freeze(), jerks(), kick(), lightsBack(), seg(), shake(), ss() (+2 more)

### Community 94 - "Server/Quests.luau"
Cohesion: 0.53
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 95 - "Data.load"
Cohesion: 0.25
Nodes (8): cleanSettings(), Data.grantCashReceipt(), Data.grantTripsReceipt(), Data.load(), Data.save(), Data.start(), fresh(), publishSettings()

### Community 96 - "TutorialUI.luau"
Cohesion: 0.47
Nodes (4): Intro.play(), play(), remote(), UI.init()

### Community 97 - "Levels.of"
Cohesion: 0.70
Nodes (4): Levels.need(), Levels.of(), Levels.total(), Data.mapLevel()

### Community 98 - "Spots.find"
Cohesion: 0.70
Nodes (4): inBox(), Spots.find(), Spots.roomBox(), Spots.scan()

### Community 99 - "Abilities.clear"
Cohesion: 0.67
Nodes (3): Abilities.clear(), smashHurled(), Loot.clear()

## Knowledge Gaps
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.at()` connect `Sfx.at` to `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `FxTier.luau`, `CampFx.luau`, `Sfx.at`, `MonsterFx.luau`?**
  _High betweenness centrality (0.064) - this node is a cross-community bridge._
- **Are the 83 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 83 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.10741971207087486 - nodes in this community are weakly interconnected._
- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Are the 67 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 67 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.034482758620689655 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `MonsterFx.luau`, `FormsPage.luau`, `Grunge.text`, `QuestUI.luau`, `PatchNotesUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `script_parent_grunge`, `SandboxUI.luau`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `Run.stageCleared`, `CodesUI.luau`, `Charge.luau`, `eyesOn`, `TutorialUI.luau`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._