# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-19)

## Corpus Check
- 113 files · ~274,061 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1438 nodes · 3968 edges · 71 communities (55 shown, 16 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 880 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `15ee0c5f`
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
- LobbyUI.init
- Evolved.luau
- Abilities.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- A
- Fury.luau
- Grunge.text
- QuestUI.luau
- Fire.luau
- Sfx.play
- EntrancePose.luau
- Entrance.luau
- UI.show
- Spectate.init
- NameTags.luau
- CarnivalFx.luau
- TrainRide.luau
- Run.onDied
- Monsters.luau
- RoomPickUI.luau
- CampFx.luau
- Lobby.luau
- Leaderboards.luau
- Sandbox.luau
- TutorialUI.luau
- FormCine.luau
- Levels.of
- SellerUI.luau
- Ghost.spawn
- CampMonsters.luau
- Tutorial.luau
- Run.startFight
- MapLoader.luau
- Admin.luau
- script_parent_data
- Server/Quests.luau
- onPlayer
- VialArt.luau
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
8. `Data.get()` - 33 edges
9. `A()` - 33 edges
10. `Kit.ring()` - 31 edges

## Surprising Connections (you probably didn't know these)
- `Run.stageCleared()` --calls--> `Campaign.cleared()`  [INFERRED]
  game/ServerScriptService/Server/Run.luau → game/ReplicatedStorage/Shared/Campaign.luau
- `UI.show()` --calls--> `pick()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/StageUI.luau → game/ReplicatedStorage/Shared/Monsters.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau

## Import Cycles
- None detected.

## Communities (71 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.12
Nodes (38): Evolved.interrupt(), Furniture.near(), Furniture.smash(), bringBack(), die(), floorBelow(), Ghost.alive(), Ghost.burn() (+30 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.19
Nodes (13): EP.pose(), abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash() (+5 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.15
Nodes (33): cleanSettings(), Data.addCash(), Data.addForm(), Data.equipForm(), Data.equipped(), Data.equipUlt(), Data.formOf(), Data.get() (+25 more)

### Community 5 - "Input.luau"
Cohesion: 0.05
Nodes (66): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+58 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.22
Nodes (26): alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear(), Inventory.give() (+18 more)

### Community 7 - "script_parent_grunge"
Cohesion: 0.13
Nodes (4): CallerUI.call(), label(), UI.close(), Shop.result()

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.16
Nodes (26): armBall(), ball(), begin(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt() (+18 more)

### Community 16 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (33): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+25 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (16): eyeAt(), eyesOn(), faceOf(), freeze(), groundAt(), jerks(), kick(), lightsBack() (+8 more)

### Community 20 - "LobbyUI.init"
Cohesion: 0.54
Nodes (7): refreshPicks(), LobbyUI.init(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList(), refreshVisible(), setOpen()

### Community 21 - "Evolved.luau"
Cohesion: 0.14
Nodes (17): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.step() (+9 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.20
Nodes (23): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+15 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.08
Nodes (27): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+19 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.06
Nodes (60): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+52 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "A"
Cohesion: 0.14
Nodes (14): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+6 more)

### Community 29 - "Fury.luau"
Cohesion: 0.26
Nodes (11): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+3 more)

### Community 30 - "Grunge.text"
Cohesion: 0.22
Nodes (18): BestiaryUI.close(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters(), button() (+10 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "Fire.luau"
Cohesion: 0.17
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 35 - "Sfx.play"
Cohesion: 0.18
Nodes (18): BestiaryUI.discovered(), popCard(), Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select() (+10 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.07
Nodes (28): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+20 more)

### Community 39 - "UI.show"
Cohesion: 0.21
Nodes (18): Campaign.clean(), Campaign.cleared(), Campaign.clock(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.stageOpen(), Campaign.ticketsLeft() (+10 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "NameTags.luau"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.09
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

### Community 50 - "Lobby.luau"
Cohesion: 0.29
Nodes (14): Campaign.stage(), Data.clearStage(), hrpOf(), launch(), leaveParty(), noTicket(), onPad(), onParty() (+6 more)

### Community 51 - "Leaderboards.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 52 - "Sandbox.luau"
Cohesion: 0.44
Nodes (9): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 53 - "TutorialUI.luau"
Cohesion: 0.22
Nodes (6): f(), Intro.play(), Intro.running(), play(), remote(), UI.init()

### Community 54 - "FormCine.luau"
Cohesion: 0.22
Nodes (18): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+10 more)

### Community 56 - "Levels.of"
Cohesion: 0.27
Nodes (9): Levels.need(), Levels.of(), Levels.title(), Levels.total(), Data.addXP(), Data.campaign(), Data.mapLevel(), Data.offline() (+1 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.23
Nodes (15): Grunge.paint(), Platform.menu(), before(), button(), clear(), level(), owned(), progress() (+7 more)

### Community 59 - "Ghost.spawn"
Cohesion: 0.13
Nodes (16): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+8 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.33
Nodes (10): Sandbox.active(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "Run.startFight"
Cohesion: 0.16
Nodes (27): Campaign.nextStage(), Furniture.reset(), Ghost.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), freshStats() (+19 more)

### Community 63 - "MapLoader.luau"
Cohesion: 0.24
Nodes (10): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+2 more)

### Community 64 - "Admin.luau"
Cohesion: 0.22
Nodes (7): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), M.setup(), settleAndTell()

### Community 65 - "script_parent_data"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 66 - "Server/Quests.luau"
Cohesion: 0.53
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 67 - "onPlayer"
Cohesion: 0.40
Nodes (6): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running()

### Community 68 - "VialArt.luau"
Cohesion: 0.83
Nodes (3): fr(), VialArt.draw(), VialArt.icon()

### Community 70 - "Run.payout"
Cohesion: 0.33
Nodes (5): areFriends(), Friends.mult(), refresh(), cashMult(), Run.payout()

### Community 72 - "script_parent_remotes"
Cohesion: 0.16
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `Intro.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.113) - this node is a cross-community bridge._
- **Are the 52 inferred relationships involving `Sfx.at()` (e.g. with `antlersStuck()` and `CF.handle()`) actually correct?**
  _`Sfx.at()` has 52 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11980676328502415 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `A`?**
  _High betweenness centrality (0.071) - this node is a cross-community bridge._
- **Are the 46 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 46 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `script_parent_grunge`, `rs_shared_config`, `SandboxUI.luau`, `Sfx.at`, `Intro.luau`, `LobbyUI.init`, `MonsterFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `UI.show`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `TutorialUI.luau`, `FormCine.luau`, `SellerUI.luau`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._