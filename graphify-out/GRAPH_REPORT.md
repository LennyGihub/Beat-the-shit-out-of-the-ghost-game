# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-19)

## Corpus Check
- 124 files · ~328,165 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1683 nodes · 4746 edges · 85 communities (69 shown, 16 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 1025 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `fc98d0f3`
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
- Abilities.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- Ghost.step
- Viewmodel.luau
- HarborFx.luau
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
- Platform.mode
- Run.payout
- AbbeyMonsters.luau
- Supplies.luau
- Levels.of
- Server/Quests.luau
- HUD.luau
- Hotbar.luau
- TicketShop.luau
- FormTutorial.luau
- MoonMonsters.luau
- SandboxUI.luau
- Combat.luau
- Run.stageCleared
- Charge.luau
- LockOn.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 84 edges
2. `Sfx.play()` - 64 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `worn()` - 40 edges
8. `Grunge.text()` - 38 edges
9. `Data.get()` - 38 edges
10. `A()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Evolved.onSpawn()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Ragdoll.restoreWalls()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (85 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.14
Nodes (31): Furniture.weight(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze() (+23 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.13
Nodes (22): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+14 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.16
Nodes (59): f(), at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle() (+51 more)

### Community 4 - "Data.luau"
Cohesion: 0.13
Nodes (38): cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.equipForm(), Data.equipped() (+30 more)

### Community 5 - "Input.luau"
Cohesion: 0.17
Nodes (21): Charge.active(), Charge.key(), Hotbar.cycle(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable() (+13 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.22
Nodes (26): alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear(), Inventory.give() (+18 more)

### Community 7 - "Sfx.at"
Cohesion: 0.12
Nodes (58): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+50 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.17
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.20
Nodes (27): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+19 more)

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
Nodes (15): actionOf(), eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack() (+7 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.08
Nodes (27): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+19 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.10
Nodes (21): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+13 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.14
Nodes (31): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+23 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.06
Nodes (52): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+44 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "Ghost.step"
Cohesion: 0.16
Nodes (24): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+16 more)

### Community 27 - "Viewmodel.luau"
Cohesion: 0.40
Nodes (4): C(), ease(), mirror(), sample()

### Community 29 - "HarborFx.luau"
Cohesion: 0.19
Nodes (27): place(), anchorSpin(), anchorWarn(), beamSweep(), burst(), diveBurst(), diveLock(), diveRing() (+19 more)

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

### Community 37 - "Entrance.luau"
Cohesion: 0.07
Nodes (26): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+18 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.22
Nodes (15): Levels.title(), Vip.start(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab() (+7 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.15
Nodes (25): Grunge.paint(), LobbyUI.invite(), UI.result(), Sfx.play(), addForm(), button(), clear(), grid() (+17 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.08
Nodes (42): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+34 more)

### Community 46 - "Run.luau"
Cohesion: 0.17
Nodes (17): Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), endDeath(), hrpOf(), insideHouse() (+9 more)

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

### Community 52 - "Sandbox.luau"
Cohesion: 0.36
Nodes (10): Run.addToMatch(), Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy() (+2 more)

### Community 53 - "MapLoader.luau"
Cohesion: 0.23
Nodes (14): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+6 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+9 more)

### Community 56 - "Lobby.luau"
Cohesion: 0.28
Nodes (16): Campaign.stage(), Data.ownsMap(), Data.tripsLeft(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket() (+8 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.20
Nodes (15): Platform.menu(), before(), button(), clear(), level(), owned(), progress(), refresh() (+7 more)

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
Cohesion: 0.20
Nodes (22): onPlayer(), Events.despawn(), Ghost.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), freshStats() (+14 more)

### Community 63 - "Leaderboards.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 64 - "Admin.luau"
Cohesion: 0.14
Nodes (7): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), M.setup(), settleAndTell()

### Community 65 - "script_parent_data"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "LobbyUI.init"
Cohesion: 0.20
Nodes (11): Campaign.clock(), Campaign.ticketsLeft(), LevelUI.init(), LobbyUI.init(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList(), refreshVisible() (+3 more)

### Community 68 - "script_parent_sfx"
Cohesion: 0.13
Nodes (9): CallerUI.call(), Intro.play(), Intro.running(), build(), Prompts.init(), play(), remote(), UI.init() (+1 more)

### Community 69 - "Platform.mode"
Cohesion: 0.24
Nodes (16): liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init() (+8 more)

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

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

### Community 75 - "HUD.luau"
Cohesion: 0.17
Nodes (6): HUD.hint(), HUD.setVisible(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint()

### Community 76 - "Hotbar.luau"
Cohesion: 0.36
Nodes (10): Hotbar.confirmHit(), Hotbar.current(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit(), refresh() (+2 more)

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "FormTutorial.luau"
Cohesion: 0.26
Nodes (10): arrowShape(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey(), fr() (+2 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 81 - "Combat.luau"
Cohesion: 0.22
Nodes (3): KnightDoor.open(), KnightDoor.pick(), spots()

### Community 82 - "Run.stageCleared"
Cohesion: 0.36
Nodes (8): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), Run.stageCleared()

### Community 83 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 84 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `GhostAnim.luau` to `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `Intro.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.078) - this node is a cross-community bridge._
- **Are the 82 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 82 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13949579831932774 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `MonsterFx.luau`, `HarborFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `LobbyUI.init`, `script_parent_sfx`, `Platform.mode`, `Hotbar.luau`, `FormTutorial.luau`, `SandboxUI.luau`, `Charge.luau`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._
- **Are the 62 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 62 INFERRED edges - model-reasoned connections that need verification._
- **Should `GhostAnim.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12615384615384614 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `Sfx.at`, `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `FxTier.luau`, `CampFx.luau`, `MonsterFx.luau`, `HarborFx.luau`?**
  _High betweenness centrality (0.061) - this node is a cross-community bridge._