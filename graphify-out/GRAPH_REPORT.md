# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-19)

## Corpus Check
- 117 files · ~290,658 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1513 nodes · 4189 edges · 79 communities (64 shown, 15 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 923 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ff147cfd`
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
- script_parent_grunge
- rs_shared_config
- Events.luau
- Settings.luau
- CarnivalMonsters.luau
- AdminPanel.luau
- Sfx.at
- Intro.luau
- Caller.luau
- Evolved.luau
- Abilities.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- Ghost.step
- A
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
- FormTutorial.luau
- Knight.luau
- Run.payout
- Run.stageCleared
- Supplies.luau
- Levels.of
- Server/Quests.luau
- NameTags.luau
- Spots.find
- TicketShop.luau
- VialArt.luau

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
- `refresh()` --calls--> `Grunge.paint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/SellerUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Grunge.luau
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

## Communities (79 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.11
Nodes (30): die(), Ghost.burn(), Ghost.damage(), Ghost.freeze(), Ghost.hit(), Ghost.launch(), Ghost.setVortex(), Ghost.shove() (+22 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.14
Nodes (36): cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.equipForm(), Data.equipped() (+28 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (56): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+48 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.22
Nodes (26): alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear(), Inventory.give() (+18 more)

### Community 7 - "script_parent_grunge"
Cohesion: 0.16
Nodes (4): CallerUI.call(), build(), Prompts.init(), UI.close()

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Settings.luau"
Cohesion: 0.11
Nodes (30): Cursor.hold(), Cursor.init(), Cursor.toggle(), update(), actionOf(), KeyHints.init(), refresh(), toggle() (+22 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.16
Nodes (26): armBall(), ball(), begin(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt() (+18 more)

### Community 16 - "AdminPanel.luau"
Cohesion: 0.09
Nodes (26): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+18 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.09
Nodes (14): eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack(), runScript() (+6 more)

### Community 20 - "Caller.luau"
Cohesion: 0.19
Nodes (14): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+6 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.10
Nodes (21): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+13 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.26
Nodes (18): attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm(), Loot.drop() (+10 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.14
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.13
Nodes (27): Abilities.blocks(), Abilities.clear(), Abilities.hitClone(), Abilities.hurl(), Abilities.spawnClones(), Abilities.step(), Abilities.try(), dmgScale() (+19 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "Ghost.step"
Cohesion: 0.13
Nodes (27): Abilities.tick(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+19 more)

### Community 27 - "A"
Cohesion: 0.14
Nodes (14): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+6 more)

### Community 29 - "Fury.luau"
Cohesion: 0.24
Nodes (11): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+3 more)

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

### Community 36 - "EntrancePose.luau"
Cohesion: 0.15
Nodes (5): f(), crouch(), EP.pose(), stride(), Intro.play()

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (55): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+47 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.51
Nodes (10): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+2 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.14
Nodes (28): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+20 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.14
Nodes (29): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+21 more)

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
Cohesion: 0.24
Nodes (9): Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 53 - "MapLoader.luau"
Cohesion: 0.18
Nodes (16): onPlayer(), Events.despawn(), Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue() (+8 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.22
Nodes (18): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+10 more)

### Community 56 - "Lobby.luau"
Cohesion: 0.30
Nodes (15): Campaign.stage(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket(), onPad() (+7 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.13
Nodes (19): LobbyUI.invite(), Platform.menu(), before(), button(), clear(), level(), owned(), progress() (+11 more)

### Community 59 - "Mobile.luau"
Cohesion: 0.48
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.35
Nodes (10): Ghost.despawn(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "Run.startFight"
Cohesion: 0.22
Nodes (20): Furniture.reset(), Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), doorPrompt(), freshStats(), holdBody(), onGhostDeath() (+12 more)

### Community 63 - "Leaderboards.luau"
Cohesion: 0.24
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 64 - "Admin.luau"
Cohesion: 0.24
Nodes (7): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), M.setup(), settleAndTell()

### Community 65 - "script_parent_data"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 66 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 67 - "LobbyUI.init"
Cohesion: 0.36
Nodes (10): Campaign.clock(), Campaign.ticketsLeft(), refreshPicks(), LevelUI.init(), LobbyUI.init(), LobbyUI.openPlay(), LobbyUI.togglePlay(), refreshList() (+2 more)

### Community 68 - "FormTutorial.luau"
Cohesion: 0.16
Nodes (13): arrowShape(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey(), Intro.running() (+5 more)

### Community 69 - "Knight.luau"
Cohesion: 0.24
Nodes (8): Abilities.dropLevitated(), Abilities.interrupt(), ungrip(), face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 71 - "Run.stageCleared"
Cohesion: 0.36
Nodes (8): Campaign.clean(), Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), Run.stageCleared()

### Community 72 - "Supplies.luau"
Cohesion: 0.26
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

### Community 73 - "Levels.of"
Cohesion: 0.27
Nodes (9): Levels.need(), Levels.of(), Levels.title(), Levels.total(), Data.campaign(), Data.mapLevel(), Data.offline(), cancel() (+1 more)

### Community 74 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 75 - "NameTags.luau"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 76 - "Spots.find"
Cohesion: 0.70
Nodes (4): inBox(), Spots.find(), Spots.roomBox(), Spots.scan()

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "VialArt.luau"
Cohesion: 0.83
Nodes (3): fr(), VialArt.draw(), VialArt.icon()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `Intro.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Are the 60 inferred relationships involving `Sfx.at()` (e.g. with `antlersStuck()` and `CF.handle()`) actually correct?**
  _`Sfx.at()` has 60 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.10631229235880399 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `SellerUI.luau` to `Input.luau`, `script_parent_grunge`, `rs_shared_config`, `Settings.luau`, `Sfx.at`, `Intro.luau`, `MonsterFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `LobbyUI.init`, `FormTutorial.luau`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Are the 51 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 51 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `Entrance.luau`, `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `CampFx.luau`, `MonsterFx.luau`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._