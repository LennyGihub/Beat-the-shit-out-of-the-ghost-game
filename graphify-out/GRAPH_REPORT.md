# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-19)

## Corpus Check
- 116 files · ~288,438 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1502 nodes · 4164 edges · 67 communities (52 shown, 15 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 920 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `605f3633`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- GhostAnim.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- script_parent_grunge
- rs_shared_config
- Events.luau
- SandboxUI.luau
- CarnivalMonsters.luau
- AdminPanel.luau
- Sfx.at
- Intro.luau
- Sfx.play
- Evolved.luau
- Abilities.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- Furniture.smash
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
- LockOn.luau
- CarnivalFx.luau
- TrainRide.luau
- Run.onDied
- Monsters.luau
- RoomPickUI.luau
- CampFx.luau
- LockOn.luau
- CallerMarks.luau
- Sandbox.luau
- FormCine.luau
- SellerUI.luau
- Ghost.spawn
- CampMonsters.luau
- Tutorial.luau
- Run.startFight
- script_parent_remotes
- script_parent_data
- eyesOn
- FormTutorial.luau
- Run.payout
- Supplies.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 62 edges
2. `Sfx.play()` - 53 edges
3. `p()` - 50 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `worn()` - 40 edges
8. `Data.get()` - 35 edges
9. `A()` - 33 edges
10. `Grunge.text()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `Run.stageCleared()` --calls--> `Campaign.cleared()`  [INFERRED]
  game/ServerScriptService/Server/Run.luau → game/ReplicatedStorage/Shared/Campaign.luau
- `UI.show()` --calls--> `pick()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/StageUI.luau → game/ReplicatedStorage/Shared/Monsters.luau
- `Abilities.clear()` --calls--> `Loot.clear()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau
- `ringPhone()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `crouch()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau

## Import Cycles
- None detected.

## Communities (67 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.19
Nodes (23): bringBack(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze(), Ghost.hit(), Ghost.launch() (+15 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.05
Nodes (82): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.stage(), Campaign.stageOpen(), Levels.need() (+74 more)

### Community 5 - "Input.luau"
Cohesion: 0.05
Nodes (69): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+61 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.20
Nodes (27): Ghost.vuln(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+19 more)

### Community 7 - "script_parent_grunge"
Cohesion: 0.11
Nodes (15): Campaign.clock(), Campaign.ticketsLeft(), refreshPicks(), CallerUI.call(), LevelUI.init(), LobbyUI.init(), LobbyUI.openPlay(), LobbyUI.togglePlay() (+7 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "SandboxUI.luau"
Cohesion: 0.23
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.16
Nodes (27): armBall(), ball(), begin(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt() (+19 more)

### Community 16 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (33): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+25 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (17): A(), about(), at(), drag(), eyeAt(), faceOf(), groundAt(), idle() (+9 more)

### Community 20 - "Sfx.play"
Cohesion: 0.27
Nodes (14): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+6 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.20
Nodes (23): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm() (+15 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.07
Nodes (50): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+42 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "Furniture.smash"
Cohesion: 0.15
Nodes (25): placeHint(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+17 more)

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
Cohesion: 0.32
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
Nodes (55): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+47 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.22
Nodes (15): Levels.title(), Vip.start(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab() (+7 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.24
Nodes (19): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+11 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.10
Nodes (38): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+30 more)

### Community 46 - "Run.onDied"
Cohesion: 0.29
Nodes (10): Monetization.start(), aliveCount(), aliveIn(), checkWipe(), endDeath(), Run.extendRevive(), Run.giveUp(), Run.onDied() (+2 more)

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
Cohesion: 0.38
Nodes (10): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy() (+2 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.18
Nodes (16): Grunge.paint(), Platform.menu(), before(), button(), clear(), level(), owned(), progress() (+8 more)

### Community 59 - "Ghost.spawn"
Cohesion: 0.13
Nodes (16): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+8 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.11
Nodes (30): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+22 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.31
Nodes (11): Furniture.reset(), Ghost.despawn(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop() (+3 more)

### Community 62 - "Run.startFight"
Cohesion: 0.14
Nodes (33): Campaign.nextStage(), onPlayer(), Events.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), cashMult(), clearTemp(), doorPrompt() (+25 more)

### Community 64 - "script_parent_remotes"
Cohesion: 0.11
Nodes (9): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), M.setup(), settleAndTell(), Secrets.arm() (+1 more)

### Community 65 - "script_parent_data"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 67 - "eyesOn"
Cohesion: 0.29
Nodes (7): eyesOn(), jerks(), kick(), lightsBack(), seg(), shake(), ss()

### Community 68 - "FormTutorial.luau"
Cohesion: 0.16
Nodes (11): arrowShape(), FT.init(), FT.play(), Intro.play(), Intro.running(), play(), remote(), UI.init() (+3 more)

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 72 - "Supplies.luau"
Cohesion: 0.42
Nodes (7): alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put(), Supplies.spawn()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.099) - this node is a cross-community bridge._
- **Are the 60 inferred relationships involving `Sfx.at()` (e.g. with `antlersStuck()` and `CF.handle()`) actually correct?**
  _`Sfx.at()` has 60 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.04878048780487805 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `script_parent_grunge`, `rs_shared_config`, `SandboxUI.luau`, `Sfx.at`, `MonsterFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `eyesOn`, `FormTutorial.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Are the 51 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 51 INFERRED edges - model-reasoned connections that need verification._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.054945054945054944 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `Entrance.luau`, `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `CampFx.luau`, `MonsterFx.luau`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._