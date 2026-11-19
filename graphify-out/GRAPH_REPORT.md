# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-19)

## Corpus Check
- 111 files · ~264,392 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1427 nodes · 3923 edges · 70 communities (54 shown, 16 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 862 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ab78b253`
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
- LockOn.luau
- rs_shared_config
- Events.luau
- Caller.luau
- CarnivalMonsters.luau
- AdminPanel.luau
- Sfx.at
- Intro.luau
- LobbyUI.luau
- Evolved.luau
- Abilities.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- script_parent_grunge
- Furniture.smash
- Fury.luau
- Grunge.text
- QuestUI.luau
- Knight.luau
- Sfx.play
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- CarnivalFx.luau
- TrainRide.luau
- Run.luau
- Monsters.luau
- RoomPickUI.luau
- CampFx.luau
- Lobby.luau
- Leaderboards.luau
- Sandbox.luau
- TutorialUI.luau
- FormCine.luau
- Server/Forms.luau
- SellerUI.luau
- Ghost.spawn
- CampMonsters.luau
- Tutorial.luau
- Run.startFight
- MapLoader.luau
- Admin.luau
- script_parent_data
- Server/Quests.luau
- Run.stageCleared
- Run.payout
- script_parent_remotes

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 54 edges
2. `p()` - 50 edges
3. `Sfx.play()` - 48 edges
4. `at()` - 47 edges
5. `V()` - 47 edges
6. `mark()` - 45 edges
7. `worn()` - 40 edges
8. `A()` - 33 edges
9. `Grunge.text()` - 32 edges
10. `Kit.ring()` - 31 edges

## Surprising Connections (you probably didn't know these)
- `UI.show()` --calls--> `pick()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/StageUI.luau → game/ReplicatedStorage/Shared/Monsters.luau
- `Abilities.interrupt()` --calls--> `Knight.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/Knight.luau
- `Abilities.clear()` --calls--> `Loot.clear()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau
- `ringPhone()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `crouch()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau

## Import Cycles
- None detected.

## Communities (70 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.18
Nodes (24): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze(), Ghost.hit() (+16 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.19
Nodes (13): EP.pose(), abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash() (+5 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.19
Nodes (27): cleanSettings(), Data.addCash(), Data.addForm(), Data.clearStage(), Data.equipForm(), Data.equipped(), Data.equipUlt(), Data.get() (+19 more)

### Community 5 - "Input.luau"
Cohesion: 0.05
Nodes (67): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+59 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.10
Nodes (46): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+38 more)

### Community 7 - "LockOn.luau"
Cohesion: 0.15
Nodes (12): LevelUI.init(), isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step() (+4 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Caller.luau"
Cohesion: 0.12
Nodes (26): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+18 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.17
Nodes (25): armBall(), ball(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt(), CM.step() (+17 more)

### Community 16 - "AdminPanel.luau"
Cohesion: 0.08
Nodes (26): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+18 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.07
Nodes (25): A(), about(), actionOf(), at(), drag(), eyeAt(), eyesOn(), faceOf() (+17 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.20
Nodes (11): refreshPicks(), LobbyUI.init(), LobbyUI.invite(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList(), refreshVisible(), setOpen() (+3 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.10
Nodes (29): attach(), clearLine(), detach(), grab(), hand(), Loot.arm(), Loot.clear(), Loot.drop() (+21 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.15
Nodes (28): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+20 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "script_parent_grunge"
Cohesion: 0.23
Nodes (8): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step(), CallerUI.call(), build(), Prompts.init()

### Community 27 - "Furniture.smash"
Cohesion: 0.15
Nodes (26): placeHint(), begin(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near() (+18 more)

### Community 29 - "Fury.luau"
Cohesion: 0.22
Nodes (13): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+5 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "Knight.luau"
Cohesion: 0.19
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 35 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.07
Nodes (28): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+20 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.17
Nodes (17): Campaign.clean(), Vip.start(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab() (+9 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.12
Nodes (30): maskBreath(), half(), MaskBreath.start(), pause(), sound(), bladeIgnite(), Settings.group(), make() (+22 more)

### Community 46 - "Run.luau"
Cohesion: 0.15
Nodes (19): Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), doorPrompt(), endDeath(), hrpOf() (+11 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.13
Nodes (40): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+32 more)

### Community 50 - "Lobby.luau"
Cohesion: 0.30
Nodes (13): Campaign.stage(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), onPad(), onParty(), partyOf() (+5 more)

### Community 51 - "Leaderboards.luau"
Cohesion: 0.24
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 52 - "Sandbox.luau"
Cohesion: 0.20
Nodes (9): Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 53 - "TutorialUI.luau"
Cohesion: 0.22
Nodes (6): f(), Intro.play(), Intro.running(), play(), remote(), UI.init()

### Community 54 - "FormCine.luau"
Cohesion: 0.15
Nodes (23): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+15 more)

### Community 56 - "Server/Forms.luau"
Cohesion: 0.19
Nodes (9): Levels.need(), Levels.of(), Levels.title(), Data.addXP(), Data.campaign(), Data.formOf(), buy(), sellerPart() (+1 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.25
Nodes (14): Grunge.paint(), before(), button(), clear(), icon(), level(), owned(), progress() (+6 more)

### Community 59 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.35
Nodes (10): Ghost.despawn(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "Run.startFight"
Cohesion: 0.20
Nodes (23): onPlayer(), Events.despawn(), Furniture.reset(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), freshStats(), holdBody() (+15 more)

### Community 63 - "MapLoader.luau"
Cohesion: 0.26
Nodes (11): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+3 more)

### Community 64 - "Admin.luau"
Cohesion: 0.43
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 65 - "script_parent_data"
Cohesion: 0.27
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 66 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 67 - "Run.stageCleared"
Cohesion: 0.42
Nodes (7): Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), Run.stageCleared()

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 72 - "script_parent_remotes"
Cohesion: 0.29
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `FormCine.luau`, `Abilities.luau`?**
  _High betweenness centrality (0.124) - this node is a cross-community bridge._
- **Are the 52 inferred relationships involving `Sfx.at()` (e.g. with `antlersStuck()` and `CF.handle()`) actually correct?**
  _`Sfx.at()` has 52 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.046511627906976744 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `Intro.luau`?**
  _High betweenness centrality (0.085) - this node is a cross-community bridge._
- **Are the 46 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 46 INFERRED edges - model-reasoned connections that need verification._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05134825014343087 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `CampFx.luau`, `MonsterFx.luau`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._