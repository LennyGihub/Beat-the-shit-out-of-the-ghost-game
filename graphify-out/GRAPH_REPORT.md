# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-19)

## Corpus Check
- 125 files · ~328,522 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1695 nodes · 4749 edges · 82 communities (67 shown, 15 thin omitted)
- Extraction: 78% EXTRACTED · 22% INFERRED · 0% AMBIGUOUS · INFERRED: 1025 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `86c9227b`
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
- Fury.luau
- MonsterFx.luau
- Abilities.luau
- Ragdoll.luau
- Furniture.smash
- A
- HarborFx.luau
- Grunge.text
- QuestUI.luau
- Main.server.luau
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
- Lobby.luau
- SellerUI.luau
- Mobile.luau
- CampMonsters.luau
- Tutorial.luau
- Cursor.luau
- Sandbox.luau
- script_parent_data
- LobbyUI.init
- script_parent_sfx
- Platform.mode
- Run.payout
- AbbeyMonsters.luau
- Supplies.luau
- Server/Quests.luau
- HUD.luau
- Hotbar.luau
- TicketShop.luau
- FormTutorial.luau
- MoonMonsters.luau
- Caller.luau
- Combat.luau
- Run.stageCleared
- Charge.luau

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
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `crouch()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau
- `stride()` --calls--> `A()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/EntrancePose.luau → game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau

## Import Cycles
- None detected.

## Communities (82 total, 15 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.15
Nodes (18): Furniture.weight(), Fury.windUp(), bringBack(), floorBelow(), Ghost.alive(), Ghost.setVortex(), Ghost.slow(), Ghost.step() (+10 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (42): cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.equipForm(), Data.equipped() (+34 more)

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
Cohesion: 0.15
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
Cohesion: 0.05
Nodes (33): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+25 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.14
Nodes (17): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.step() (+9 more)

### Community 22 - "Fury.luau"
Cohesion: 0.33
Nodes (9): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+1 more)

### Community 23 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.07
Nodes (57): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+49 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.32
Nodes (12): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+4 more)

### Community 26 - "Furniture.smash"
Cohesion: 0.20
Nodes (23): Evolved.interrupt(), Furniture.near(), Furniture.smash(), die(), Ghost.burn(), Ghost.damage(), Ghost.freeze(), Ghost.hit() (+15 more)

### Community 27 - "A"
Cohesion: 0.14
Nodes (14): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+6 more)

### Community 29 - "HarborFx.luau"
Cohesion: 0.19
Nodes (27): place(), anchorSpin(), anchorWarn(), beamSweep(), burst(), diveBurst(), diveLock(), diveRing() (+19 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 32 - "Main.server.luau"
Cohesion: 0.07
Nodes (16): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Data.loaded(), draw(), fmt() (+8 more)

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
Cohesion: 0.07
Nodes (26): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+18 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.53
Nodes (10): frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch(), stroke() (+2 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.17
Nodes (22): Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed(), onRequest() (+14 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.09
Nodes (38): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+30 more)

### Community 46 - "Run.luau"
Cohesion: 0.11
Nodes (42): onPlayer(), Events.despawn(), Inventory.clearWorld(), Lobby.returnPlayer(), MapLoader.spawnInside(), Monetization.start(), aliveCount(), aliveIn() (+34 more)

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
Cohesion: 0.27
Nodes (10): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+2 more)

### Community 53 - "MapLoader.luau"
Cohesion: 0.27
Nodes (11): Furniture.hasTemplate(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+3 more)

### Community 54 - "FormCine.luau"
Cohesion: 0.22
Nodes (18): back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar(), lerpCF() (+10 more)

### Community 56 - "Lobby.luau"
Cohesion: 0.30
Nodes (15): Campaign.stage(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket(), onPad() (+7 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.15
Nodes (18): Campaign.clean(), Grunge.paint(), Platform.menu(), before(), button(), clear(), level(), owned() (+10 more)

### Community 59 - "Mobile.luau"
Cohesion: 0.48
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Tutorial.luau"
Cohesion: 0.35
Nodes (10): Ghost.despawn(), enter(), frontDoor(), hold(), spawnHer(), standSpot(), stop(), Tutorial.start() (+2 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.60
Nodes (4): Cursor.hold(), Cursor.init(), Cursor.toggle(), update()

### Community 64 - "Sandbox.luau"
Cohesion: 0.14
Nodes (11): M.setup(), settleAndTell(), Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start() (+3 more)

### Community 65 - "script_parent_data"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 67 - "LobbyUI.init"
Cohesion: 0.14
Nodes (14): Campaign.clock(), Campaign.ticketsLeft(), refreshPicks(), LevelUI.init(), LobbyUI.init(), LobbyUI.invite(), LobbyUI.openPlay(), LobbyUI.togglePlay() (+6 more)

### Community 68 - "script_parent_sfx"
Cohesion: 0.13
Nodes (10): Vip.start(), CallerUI.call(), Intro.running(), onPlayer(), refresh(), build(), Prompts.init(), play() (+2 more)

### Community 69 - "Platform.mode"
Cohesion: 0.20
Nodes (18): HUD.update(), liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact() (+10 more)

### Community 70 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 72 - "Supplies.luau"
Cohesion: 0.24
Nodes (9): Secrets.arm(), shut(), alive(), spotsFolder(), Supplies.pick(), Supplies.pickTier(), Supplies.placeMap(), Supplies.put() (+1 more)

### Community 74 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 75 - "HUD.luau"
Cohesion: 0.29
Nodes (5): HUD.hint(), HUD.setVisible(), HUD.toast(), layoutBars(), updateWaypoint()

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

### Community 80 - "Caller.luau"
Cohesion: 0.11
Nodes (26): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+18 more)

### Community 81 - "Combat.luau"
Cohesion: 0.13
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 82 - "Run.stageCleared"
Cohesion: 0.21
Nodes (13): Campaign.cleared(), Campaign.goal(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen(), Levels.need(), Levels.of() (+5 more)

### Community 83 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `Sfx.at`, `Intro.luau`, `MonsterFx.luau`, `HarborFx.luau`, `Grunge.text`, `QuestUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `TrainRide.luau`, `RoomPickUI.luau`, `CampFx.luau`, `FormCine.luau`, `SellerUI.luau`, `LobbyUI.init`, `script_parent_sfx`, `Platform.mode`, `Hotbar.luau`, `FormTutorial.luau`, `Caller.luau`, `Charge.luau`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Are the 82 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 82 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `Sfx.at`, `rs_shared_config`, `CarnivalFx.luau`, `TrainRide.luau`, `FxTier.luau`, `CampFx.luau`, `MonsterFx.luau`, `HarborFx.luau`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Are the 62 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 62 INFERRED edges - model-reasoned connections that need verification._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12070874861572536 - nodes in this community are weakly interconnected._
- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `TrainRide.luau`, `CampFx.luau`, `Intro.luau`, `FormCine.luau`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._