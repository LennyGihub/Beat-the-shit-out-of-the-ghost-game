# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-20)

## Corpus Check
- 126 files · ~333,878 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1708 nodes · 4756 edges · 84 communities (67 shown, 17 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1005 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `59311a2a`
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
- Ghost.step
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- UltRunner.luau
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
- Furniture.luau
- MapLoader.luau
- FormCine.luau
- FormGiant.luau
- SellerUI.luau
- rs_shared_config
- CampMonsters.luau
- Tutorial.luau
- Cursor.luau
- script_parent_remotes
- script_parent_data
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- script_parent_sfx
- game_getservice
- Platform.mode
- Run.payout
- AbbeyMonsters.luau
- Supplies.luau
- Monetization.start
- Sandbox.luau
- HUD.luau
- Hotbar.luau
- TicketShop.luau
- FormTutorial.luau
- MoonMonsters.luau
- SandboxUI.luau
- eyesOn
- Campaign.luau
- Charge.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 84 edges
2. `Sfx.play()` - 62 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `worn()` - 40 edges
8. `Data.get()` - 38 edges
9. `Grunge.text()` - 37 edges
10. `A()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `Shop.result()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/UltShopUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `actionOf()` --calls--> `Settings.input()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (84 total, 17 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.10
Nodes (26): Evolved.interrupt(), Evolved.onSpawn(), bringBack(), die(), Ghost.freeze(), Ghost.launch(), Ghost.spawn(), Ghost.timeStop() (+18 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.06
Nodes (80): Levels.need(), Levels.of(), Levels.total(), cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP() (+72 more)

### Community 5 - "Input.luau"
Cohesion: 0.17
Nodes (21): Charge.active(), Charge.key(), Hotbar.cycle(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable() (+13 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.21
Nodes (27): Ghost.shove(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+19 more)

### Community 7 - "Sfx.at"
Cohesion: 0.12
Nodes (58): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+50 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.17
Nodes (27): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+19 more)

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
Cohesion: 0.26
Nodes (25): Campaign.stage(), bolt(), buildAura(), burst(), clearAura(), emit(), flashLight(), floorRing() (+17 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (17): A(), about(), actionOf(), at(), drag(), eyeAt(), faceOf(), groundAt() (+9 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.12
Nodes (25): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+17 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.13
Nodes (19): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+11 more)

### Community 22 - "Ghost.step"
Cohesion: 0.16
Nodes (25): Furniture.near(), Furniture.smash(), Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch() (+17 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.05
Nodes (69): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+61 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.32
Nodes (12): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+4 more)

### Community 26 - "UltRunner.luau"
Cohesion: 0.32
Nodes (12): Ghost.burn(), Ghost.hit(), Ghost.setVortex(), Ghost.slow(), barrage(), fling(), ghostPos(), Runner.barrel() (+4 more)

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
Cohesion: 0.28
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
Nodes (26): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+18 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.42
Nodes (12): Levels.title(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat() (+4 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.17
Nodes (23): Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed(), onRequest() (+15 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.09
Nodes (40): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+32 more)

### Community 46 - "Run.luau"
Cohesion: 0.14
Nodes (31): Campaign.nextStage(), Events.despawn(), Friends.mult(), Ghost.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), cashMult(), clearTemp() (+23 more)

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
Cohesion: 0.24
Nodes (11): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+3 more)

### Community 53 - "MapLoader.luau"
Cohesion: 0.20
Nodes (16): onPlayer(), Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init() (+8 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+9 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.19
Nodes (15): Grunge.paint(), before(), button(), clear(), level(), owned(), progress(), refresh() (+7 more)

### Community 59 - "rs_shared_config"
Cohesion: 0.19
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.33
Nodes (10): Sandbox.active(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.60
Nodes (4): Cursor.hold(), Cursor.init(), Cursor.toggle(), update()

### Community 64 - "script_parent_remotes"
Cohesion: 0.13
Nodes (7): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Secrets.arm(), shut()

### Community 65 - "script_parent_data"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "script_parent_sfx"
Cohesion: 0.09
Nodes (9): M.setup(), settleAndTell(), CallerUI.call(), Fx.applyZone(), Fx.init(), build(), Prompts.init(), UI.close() (+1 more)

### Community 68 - "game_getservice"
Cohesion: 0.29
Nodes (3): Vip.start(), onPlayer(), refresh()

### Community 69 - "Platform.mode"
Cohesion: 0.22
Nodes (17): liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init() (+9 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "Supplies.luau"
Cohesion: 0.42
Nodes (7): alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put(), Supplies.spawn()

### Community 73 - "Monetization.start"
Cohesion: 0.29
Nodes (10): Monetization.start(), aliveCount(), aliveIn(), checkWipe(), endDeath(), Run.extendRevive(), Run.giveUp(), Run.onDied() (+2 more)

### Community 74 - "Sandbox.luau"
Cohesion: 0.50
Nodes (8): Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

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
Cohesion: 0.15
Nodes (15): arrowShape(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey(), Intro.play() (+7 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 81 - "eyesOn"
Cohesion: 0.29
Nodes (7): eyesOn(), jerks(), kick(), lightsBack(), seg(), shake(), ss()

### Community 82 - "Campaign.luau"
Cohesion: 0.23
Nodes (10): Campaign.clean(), Campaign.cleared(), Campaign.clock(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.stageOpen(), Campaign.ticketsLeft() (+2 more)

### Community 83 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

## Knowledge Gaps
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Are the 82 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 82 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09803921568627451 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `MonsterFx.luau`, `HarborFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `script_parent_sfx`, `Platform.mode`, `Hotbar.luau`, `FormTutorial.luau`, `SandboxUI.luau`, `eyesOn`, `Campaign.luau`, `Charge.luau`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Are the 60 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 60 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `Sfx.at`, `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `FxTier.luau`, `CampFx.luau`, `MonsterFx.luau`, `HarborFx.luau`?**
  _High betweenness centrality (0.063) - this node is a cross-community bridge._