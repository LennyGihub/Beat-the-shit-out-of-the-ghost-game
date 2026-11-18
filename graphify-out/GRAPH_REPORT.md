# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 105 files · ~231,212 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1274 nodes · 3519 edges · 70 communities (55 shown, 15 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 811 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a372fa33`
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
- Platform.mode
- rs_shared_config
- Events.luau
- LockOn.luau
- Admin.luau
- Monsters.luau
- Sfx.at
- Intro.luau
- LobbyUI.luau
- Evolved.luau
- Abilities.luau
- script_parent_grunge
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- UltRunner.luau
- Caller.luau
- Grunge.text
- QuestUI.luau
- Knight.luau
- Sfx.play
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- Run.luau
- TrainRide.luau
- script_parent_remotes
- AdminPanel.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- TutorialUI.luau
- game_getservice
- Admin.luau
- Settings.luau
- FormCine.luau
- Lobby.luau
- SellerUI.luau
- Ghost.spawn
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- Tutorial.luau
- Fx.luau
- Server/Forms.luau
- Bestiary.luau
- Server/Quests.luau
- HUD.luau
- Charge.luau
- Viewmodel.luau
- runScript

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 47 edges
4. `mark()` - 45 edges
5. `Sfx.play()` - 44 edges
6. `worn()` - 40 edges
7. `Sfx.at()` - 32 edges
8. `Grunge.text()` - 32 edges
9. `Kit.ring()` - 31 edges
10. `Ghost.step()` - 30 edges

## Surprising Connections (you probably didn't know these)
- `layoutBars()` --calls--> `Platform.mode()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `TR.depart()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TrainRide.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `mirror()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau
- `startMusic()` --calls--> `Sfx.loop()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau

## Import Cycles
- None detected.

## Communities (70 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.17
Nodes (26): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.despawn(), Ghost.freeze() (+18 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.19
Nodes (13): EP.pose(), abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash() (+5 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.06
Nodes (6): apply(), clearOn(), emitter(), FL.init(), lowFx(), watch()

### Community 4 - "Data.luau"
Cohesion: 0.17
Nodes (28): cleanSettings(), Data.addCash(), Data.addForm(), Data.addXP(), Data.campaign(), Data.clearStage(), Data.equipForm(), Data.equipped() (+20 more)

### Community 5 - "Input.luau"
Cohesion: 0.20
Nodes (18): Charge.active(), Charge.key(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab(), hitDown() (+10 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.12
Nodes (41): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+33 more)

### Community 7 - "Platform.mode"
Cohesion: 0.20
Nodes (17): liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init() (+9 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.20
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 15 - "Admin.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (20): A(), about(), at(), drag(), eyeAt(), eyesOn(), groundAt(), idle() (+12 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.54
Nodes (7): refreshPicks(), LobbyUI.init(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList(), refreshVisible(), setOpen()

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.16
Nodes (23): attach(), clearLine(), detach(), grab(), hand(), Loot.arm(), Loot.clear(), Loot.drop() (+15 more)

### Community 23 - "script_parent_grunge"
Cohesion: 0.14
Nodes (6): CallerUI.call(), LevelUI.init(), build(), Prompts.init(), UI.close(), Shop.result()

### Community 24 - "Abilities.luau"
Cohesion: 0.16
Nodes (28): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+20 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "UltRunner.luau"
Cohesion: 0.17
Nodes (23): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+15 more)

### Community 29 - "Caller.luau"
Cohesion: 0.14
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 30 - "Grunge.text"
Cohesion: 0.18
Nodes (23): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+15 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 34 - "Knight.luau"
Cohesion: 0.43
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 35 - "Sfx.play"
Cohesion: 0.28
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.drop(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse() (+4 more)

### Community 36 - "EntrancePose.luau"
Cohesion: 0.20
Nodes (3): Entrance.play(), structure(), EP.height()

### Community 37 - "Entrance.luau"
Cohesion: 0.05
Nodes (37): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+29 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.41
Nodes (11): reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+3 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "Run.luau"
Cohesion: 0.05
Nodes (77): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), onPlayer() (+69 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.13
Nodes (29): maskBreath(), half(), MaskBreath.start(), pause(), sound(), bladeIgnite(), Settings.group(), make() (+21 more)

### Community 46 - "script_parent_remotes"
Cohesion: 0.22
Nodes (13): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+5 more)

### Community 47 - "AdminPanel.luau"
Cohesion: 0.11
Nodes (24): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+16 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "TutorialUI.luau"
Cohesion: 0.24
Nodes (6): f(), Intro.play(), Intro.running(), play(), remote(), UI.init()

### Community 51 - "game_getservice"
Cohesion: 0.28
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 52 - "Admin.luau"
Cohesion: 0.13
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 53 - "Settings.luau"
Cohesion: 0.19
Nodes (17): actionOf(), KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind() (+9 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.23
Nodes (17): bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF(), mk() (+9 more)

### Community 56 - "Lobby.luau"
Cohesion: 0.31
Nodes (14): Campaign.stage(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), onPad(), onParty() (+6 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.27
Nodes (12): Platform.menu(), button(), clear(), icon(), level(), owned(), refresh(), UI.close() (+4 more)

### Community 59 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 60 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 61 - "Tutorial.luau"
Cohesion: 0.35
Nodes (10): Data.setTutorialSeen(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 63 - "Server/Forms.luau"
Cohesion: 0.31
Nodes (6): Levels.need(), Levels.of(), Levels.title(), buy(), sellerPart(), toast()

### Community 64 - "Bestiary.luau"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 65 - "Server/Quests.luau"
Cohesion: 0.53
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 66 - "HUD.luau"
Cohesion: 0.29
Nodes (6): HUD.hint(), HUD.setVisible(), HUD.toast(), HUD.update(), layoutBars(), updateWaypoint()

### Community 67 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 68 - "Viewmodel.luau"
Cohesion: 0.50
Nodes (3): ease(), mirror(), sample()

### Community 69 - "runScript"
Cohesion: 0.50
Nodes (4): faceOf(), runScript(), tvRoom(), inRoom()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `Intro.luau` to `GhostAnim.luau`, `ItemModels.luau`, `Viewmodel.luau`, `TrainRide.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Are the 42 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 42 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05609756097560976 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Grunge.text` to `Input.luau`, `Platform.mode`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `LobbyUI.luau`, `script_parent_grunge`, `QuestUI.luau`, `Sfx.play`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `TrainRide.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `TutorialUI.luau`, `FormCine.luau`, `SellerUI.luau`, `Charge.luau`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11717171717171718 - nodes in this community are weakly interconnected._
- **Why does `at()` connect `ItemModels.luau` to `Intro.luau`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Should `rs_shared_config` be split into smaller, more focused modules?**
  _Cohesion score 0.13940256045519203 - nodes in this community are weakly interconnected._