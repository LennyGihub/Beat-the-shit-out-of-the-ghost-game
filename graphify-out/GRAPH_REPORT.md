# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 107 files · ~236,839 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1318 nodes · 3597 edges · 72 communities (57 shown, 15 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 822 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b61da1c1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- GhostAnim.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- Platform.mode
- rs_shared_config
- Events.luau
- LockOn.luau
- Settings.luau
- AdminPanel.luau
- Sfx.at
- Intro.luau
- LobbyUI.luau
- Evolved.luau
- Abilities.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- UltRunner.luau
- Caller.luau
- Grunge.text
- QuestUI.luau
- script_parent_remotes
- Sfx.play
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- Run.startFight
- TrainRide.luau
- Run.luau
- Fx.luau
- RoomPickUI.luau
- CampFx.luau
- TutorialUI.luau
- game_getservice
- Admin.luau
- MapLoader.luau
- FormCine.luau
- SandboxUI.luau
- SellerUI.luau
- Ghost.spawn
- CampMonsters.luau
- Tutorial.luau
- Supplies.luau
- Charge.luau
- HUD.luau
- Intro.play
- Sandbox.luau
- Run.stageCleared
- Viewmodel.luau
- game_getservice
- Run.payout
- runScript

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `at()` - 47 edges
3. `V()` - 47 edges
4. `Sfx.play()` - 46 edges
5. `mark()` - 45 edges
6. `worn()` - 40 edges
7. `Sfx.at()` - 38 edges
8. `Grunge.text()` - 32 edges
9. `Kit.ring()` - 31 edges
10. `Ghost.step()` - 30 edges

## Surprising Connections (you probably didn't know these)
- `TR.depart()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TrainRide.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `TC.init()` --calls--> `LockOn.isOn()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TouchControls.luau → game/StarterPlayer/StarterPlayerScripts/Client/LockOn.luau

## Import Cycles
- None detected.

## Communities (72 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.16
Nodes (24): Furniture.weight(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.hit() (+16 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.19
Nodes (13): EP.pose(), abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash() (+5 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.06
Nodes (68): Campaign.stage(), Levels.of(), Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings(), Data.addCash(), Data.addForm() (+60 more)

### Community 5 - "Input.luau"
Cohesion: 0.19
Nodes (19): Charge.active(), Charge.key(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+11 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (49): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+41 more)

### Community 7 - "Platform.mode"
Cohesion: 0.21
Nodes (17): liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init() (+9 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.33
Nodes (8): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target()

### Community 15 - "Settings.luau"
Cohesion: 0.19
Nodes (17): actionOf(), KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind() (+9 more)

### Community 16 - "AdminPanel.luau"
Cohesion: 0.29
Nodes (12): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+4 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (20): A(), about(), at(), drag(), eyeAt(), eyesOn(), groundAt(), idle() (+12 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.44
Nodes (8): refreshPicks(), LobbyUI.init(), LobbyUI.invite(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList(), refreshVisible(), setOpen()

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.20
Nodes (23): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm() (+15 more)

### Community 23 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 24 - "Abilities.luau"
Cohesion: 0.16
Nodes (28): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+20 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.36
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+3 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "UltRunner.luau"
Cohesion: 0.17
Nodes (23): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+15 more)

### Community 29 - "Caller.luau"
Cohesion: 0.15
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "script_parent_remotes"
Cohesion: 0.16
Nodes (13): Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp() (+5 more)

### Community 35 - "Sfx.play"
Cohesion: 0.20
Nodes (15): CallerUI.call(), Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse() (+7 more)

### Community 36 - "EntrancePose.luau"
Cohesion: 0.20
Nodes (3): Entrance.play(), structure(), EP.height()

### Community 37 - "Entrance.luau"
Cohesion: 0.05
Nodes (37): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+29 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.17
Nodes (13): pick(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat() (+5 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "Run.startFight"
Cohesion: 0.20
Nodes (21): Events.despawn(), Furniture.reset(), Inventory.clear(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), freshStats() (+13 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.10
Nodes (36): maskBreath(), apply(), clearOn(), emitter(), FL.init(), lowFx(), watch(), half() (+28 more)

### Community 46 - "Run.luau"
Cohesion: 0.17
Nodes (17): Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), endDeath(), hrpOf(), insideHouse() (+9 more)

### Community 47 - "Fx.luau"
Cohesion: 0.12
Nodes (14): Fx.applyZone(), Fx.init(), oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId() (+6 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "CampFx.luau"
Cohesion: 0.22
Nodes (16): burst(), CF.handle(), clearHook(), dropLand(), dropWarn(), floodStart(), folder(), handOf() (+8 more)

### Community 50 - "TutorialUI.luau"
Cohesion: 0.47
Nodes (4): Intro.running(), play(), remote(), UI.init()

### Community 51 - "game_getservice"
Cohesion: 0.22
Nodes (6): Levels.need(), Levels.title(), Vip.start(), build(), onPlayer(), refresh()

### Community 52 - "Admin.luau"
Cohesion: 0.10
Nodes (7): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), sellerPart(), toast()

### Community 53 - "MapLoader.luau"
Cohesion: 0.27
Nodes (10): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+2 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF(), mk() (+9 more)

### Community 56 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.14
Nodes (15): LevelUI.init(), Platform.menu(), button(), clear(), icon(), level(), owned(), refresh() (+7 more)

### Community 59 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.24
Nodes (7): CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), live(), sees()

### Community 61 - "Tutorial.luau"
Cohesion: 0.31
Nodes (11): Ghost.despawn(), Sandbox.active(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop() (+3 more)

### Community 62 - "Supplies.luau"
Cohesion: 0.38
Nodes (4): alive(), Supplies.clear(), Supplies.pick(), Supplies.spawn()

### Community 63 - "Charge.luau"
Cohesion: 0.39
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 64 - "HUD.luau"
Cohesion: 0.29
Nodes (6): HUD.hint(), HUD.setVisible(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint()

### Community 66 - "Sandbox.luau"
Cohesion: 0.30
Nodes (13): onPlayer(), MapLoader.spawnInside(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.setSandbox(), center(), enter() (+5 more)

### Community 67 - "Run.stageCleared"
Cohesion: 0.36
Nodes (8): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), Run.stageCleared()

### Community 68 - "Viewmodel.luau"
Cohesion: 0.50
Nodes (3): ease(), mirror(), sample()

### Community 69 - "game_getservice"
Cohesion: 0.38
Nodes (3): layout(), make(), TC.init()

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 71 - "runScript"
Cohesion: 0.50
Nodes (4): faceOf(), runScript(), tvRoom(), inRoom()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Platform.mode`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `LobbyUI.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `TutorialUI.luau`, `FormCine.luau`, `SandboxUI.luau`, `SellerUI.luau`, `Charge.luau`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **Are the 44 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 44 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.045454545454545456 - nodes in this community are weakly interconnected._
- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `Viewmodel.luau`, `TrainRide.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05917721518987342 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `Intro.luau`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._