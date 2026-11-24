# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-24)

## Corpus Check
- 146 files · ~373,511 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1987 nodes · 5497 edges · 102 communities (84 shown, 18 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1157 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8ed59710`
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
- CampFx.luau
- Settings.luau
- CarnivalMonsters.luau
- FxTier.luau
- Sfx.at
- Intro.luau
- AdminPanel.luau
- Evolved.luau
- ClipCam.luau
- SawAudio.luau
- Abilities.luau
- FormsPage.luau
- DailyUI.luau
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
- MonsterFx.luau
- TrainRide.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau
- Server/Daily.luau
- RoomPickUI.luau
- Charge.luau
- LockOn.luau
- CallerMarks.luau
- steps
- Secrets.luau
- game/ServerScriptService/Server/Share.luau
- FormGiant.luau
- SellerUI.luau
- Fire.luau
- CampMonsters.luau
- Cursor.luau
- FreeCam.luau
- A
- Fury.luau
- Events.luau
- script_parent_grunge
- Fx.luau
- Platform.mode
- game/ReplicatedStorage/Shared/Monsters.luau
- AbbeyMonsters.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- HUD.luau
- Hotbar.luau
- TicketShop.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- MoonMonsters.luau
- Leaderboards.luau
- GoblinLoot.luau
- rs_shared_ultimates
- SandboxUI.luau
- Caller.luau
- game/ServerScriptService/Server/Tutorial.luau
- game/ServerScriptService/Server/Run.luau
- CodesUI.luau
- script_parent_furniture
- game/ServerScriptService/Server/Bestiary.luau
- script_parent_remotes
- game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau
- game/ServerScriptService/Server/Mobile.luau
- Server/Quests.luau
- Notify.luau
- CrewAnim.luau
- Levels.of
- Furniture.smash
- game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau
- game/StarterPlayer/StarterPlayerScripts/Client/Translate.luau
- Server/Vip.luau

## God Nodes (most connected - your core abstractions)
1. `Sfx.at()` - 85 edges
2. `Sfx.play()` - 74 edges
3. `Data.get()` - 52 edges
4. `p()` - 50 edges
5. `Grunge.text()` - 49 edges
6. `at()` - 47 edges
7. `V()` - 47 edges
8. `mark()` - 45 edges
9. `worn()` - 40 edges
10. `A()` - 33 edges

## Surprising Connections (you probably didn't know these)
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau

## Import Cycles
- None detected.

## Communities (102 total, 18 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.11
Nodes (39): Admin.start(), Evolved.onSpawn(), bringBack(), claw(), die(), dropIt(), floorBelow(), Ghost.alive() (+31 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.12
Nodes (44): M.reset(), cleanSettings(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage(), Data.codeUsed(), Data.equipForm() (+36 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (22): Charge.active(), Charge.key(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+14 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.20
Nodes (28): Ghost.vuln(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+20 more)

### Community 7 - "Sfx.at"
Cohesion: 0.08
Nodes (86): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+78 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (28): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+20 more)

### Community 12 - "CampFx.luau"
Cohesion: 0.13
Nodes (40): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+32 more)

### Community 13 - "Settings.luau"
Cohesion: 0.21
Nodes (16): KeyHints.init(), refresh(), toggle(), apply(), defaultFx(), load(), save(), Settings.bind() (+8 more)

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
Nodes (14): actionOf(), eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack() (+6 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "ClipCam.luau"
Cohesion: 0.23
Nodes (20): act(), alive(), botFight(), botStrut(), brutFull(), ClipCam.init(), hideUI(), lateStep() (+12 more)

### Community 23 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.13
Nodes (28): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+20 more)

### Community 25 - "FormsPage.luau"
Cohesion: 0.20
Nodes (16): button(), FP.build(), FP.filter(), FP.refresh(), FP.select(), owned(), setIndex(), showDetail() (+8 more)

### Community 26 - "DailyUI.luau"
Cohesion: 0.14
Nodes (19): Daily.cash(), Daily.current(), Daily.label(), Daily.next(), Daily.reward(), Daily.untilTomorrow(), button(), claim() (+11 more)

### Community 27 - "Ragdoll.luau"
Cohesion: 0.32
Nodes (12): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+4 more)

### Community 29 - "game/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.30
Nodes (15): Data.campaign(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), noTicket(), onPad() (+7 more)

### Community 30 - "Grunge.text"
Cohesion: 0.18
Nodes (21): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+13 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
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
Cohesion: 0.17
Nodes (4): f(), crouch(), EP.pose(), stride()

### Community 37 - "Entrance.luau"
Cohesion: 0.07
Nodes (24): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+16 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.28
Nodes (16): Campaign.clean(), Campaign.clock(), Levels.title(), reveal(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel() (+8 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Sfx.play"
Cohesion: 0.17
Nodes (23): Sfx.play(), addForm(), button(), clear(), grid(), heading(), onClosed(), onRequest() (+15 more)

### Community 42 - "CarnivalFx.luau"
Cohesion: 0.25
Nodes (18): ballSmash(), burst(), CF.handle(), CF.init(), cratePop(), crateRattle(), folder(), handOf() (+10 more)

### Community 43 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 44 - "TrainRide.luau"
Cohesion: 0.09
Nodes (40): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+32 more)

### Community 46 - "game/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau"
Cohesion: 0.23
Nodes (18): C(), back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar() (+10 more)

### Community 47 - "Server/Daily.luau"
Cohesion: 0.32
Nodes (16): claim(), Daily.admin(), Daily.bestSet(), Daily.sampleReady(), Daily.setup(), Daily.start(), Daily.useSample(), giveForm() (+8 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 50 - "LockOn.luau"
Cohesion: 0.20
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 51 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 52 - "steps"
Cohesion: 0.12
Nodes (16): ROBLOX_API_KEY, jobs, send, name, on, schedule, workflow_dispatch, cron (+8 more)

### Community 54 - "game/ServerScriptService/Server/Share.luau"
Cohesion: 0.15
Nodes (22): Analytics.cash(), Analytics.custom(), Analytics.joined(), Analytics.lesson(), Analytics.onboard(), Analytics.stage(), fields(), logStep() (+14 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.21
Nodes (14): before(), button(), clear(), level(), owned(), progress(), refresh(), setOpen() (+6 more)

### Community 59 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 62 - "Cursor.luau"
Cohesion: 0.48
Nodes (4): Cursor.hold(), Cursor.init(), Cursor.toggle(), update()

### Community 63 - "FreeCam.luau"
Cohesion: 0.33
Nodes (10): bindKeys(), FC.init(), FC.set(), makeHint(), playerControls(), refreshHint(), setUiHidden(), shiftDown() (+2 more)

### Community 64 - "A"
Cohesion: 0.14
Nodes (14): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+6 more)

### Community 65 - "Fury.luau"
Cohesion: 0.18
Nodes (12): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+4 more)

### Community 66 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 67 - "script_parent_grunge"
Cohesion: 0.11
Nodes (4): CallerUI.call(), build(), Prompts.init(), Shop.result()

### Community 68 - "Fx.luau"
Cohesion: 0.17
Nodes (5): Fx.applyZone(), Fx.init(), clear(), selectedId(), step()

### Community 69 - "Platform.mode"
Cohesion: 0.24
Nodes (16): liftHint(), freeze(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init() (+8 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 73 - "game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau"
Cohesion: 0.27
Nodes (25): abbBody(), abbFist(), att(), bp(), bright(), bulbs(), campBody(), campFist() (+17 more)

### Community 74 - "HUD.luau"
Cohesion: 0.29
Nodes (5): HUD.hint(), HUD.setVisible(), HUD.update(), layoutBars(), updateWaypoint()

### Community 76 - "Hotbar.luau"
Cohesion: 0.32
Nodes (11): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+3 more)

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.33
Nodes (9): arrowShape(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey() (+1 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "Leaderboards.luau"
Cohesion: 0.30
Nodes (10): draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top(), write() (+2 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.20
Nodes (23): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+15 more)

### Community 82 - "rs_shared_ultimates"
Cohesion: 0.18
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

### Community 83 - "SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 84 - "Caller.luau"
Cohesion: 0.15
Nodes (18): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+10 more)

### Community 85 - "game/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.18
Nodes (17): M.start(), Data.setTutorialSeen(), drop(), Guard.int(), Guard.limit(), Guard.num(), Guard.ok(), Guard.vec() (+9 more)

### Community 86 - "game/ServerScriptService/Server/Run.luau"
Cohesion: 0.06
Nodes (73): Campaign.cleared(), Campaign.endlessOpen(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen() (+65 more)

### Community 87 - "CodesUI.luau"
Cohesion: 0.29
Nodes (9): button(), redeem(), say(), UI.close(), UI.init(), UI.open(), UI.result(), Platform.menu() (+1 more)

### Community 88 - "script_parent_furniture"
Cohesion: 0.36
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 89 - "game/ServerScriptService/Server/Bestiary.luau"
Cohesion: 0.31
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 90 - "script_parent_remotes"
Cohesion: 0.09
Nodes (14): Admin.run(), isAdmin(), isFullAdmin(), passId(), M.setup(), settleAndTell(), center(), enter() (+6 more)

### Community 91 - "game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau"
Cohesion: 0.23
Nodes (15): button(), hideCard(), invite(), launchData(), refreshReward(), reward(), say(), shareLink() (+7 more)

### Community 93 - "game/ServerScriptService/Server/Mobile.luau"
Cohesion: 0.48
Nodes (6): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share(), Mobile.start()

### Community 94 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 95 - "Notify.luau"
Cohesion: 0.43
Nodes (5): Notify.debug(), Notify.plan(), Notify.setup(), Notify.start(), write()

### Community 96 - "CrewAnim.luau"
Cohesion: 0.50
Nodes (3): add(), CrewAnim.init(), joint()

### Community 97 - "Levels.of"
Cohesion: 0.83
Nodes (3): Levels.need(), Levels.of(), Levels.total()

### Community 101 - "Furniture.smash"
Cohesion: 0.15
Nodes (25): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.recapture() (+17 more)

### Community 107 - "game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau"
Cohesion: 0.36
Nodes (8): HUD.toast(), clear(), dust(), liftLabel(), monster(), ring(), WeakFx.handle(), WeakFx.init()

### Community 110 - "game/StarterPlayer/StarterPlayerScripts/Client/Translate.luau"
Cohesion: 0.57
Nodes (5): lookup(), remember(), store(), T.auto(), T.t()

### Community 115 - "Server/Vip.luau"
Cohesion: 0.16
Nodes (8): Vip.start(), Intro.play(), Intro.running(), onPlayer(), refresh(), play(), remote(), UI.init()

## Knowledge Gaps
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `CampFx.luau`, `Sfx.at`, `Intro.luau`, `FormsPage.luau`, `DailyUI.luau`, `Grunge.text`, `QuestUI.luau`, `PatchNotesUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `MonsterFx.luau`, `TrainRide.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau`, `RoomPickUI.luau`, `Charge.luau`, `SellerUI.luau`, `script_parent_grunge`, `Platform.mode`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `SandboxUI.luau`, `CodesUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau`, `Server/Vip.luau`?**
  _High betweenness centrality (0.080) - this node is a cross-community bridge._
- **Are the 83 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 83 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1109936575052854 - nodes in this community are weakly interconnected._
- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `EntrancePose.luau`, `CampFx.luau`, `TrainRide.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau`, `Intro.luau`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Are the 72 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 72 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.03278688524590164 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `rs_shared_config`, `CarnivalFx.luau`, `MonsterFx.luau`, `CampFx.luau`, `TrainRide.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau`, `FxTier.luau`, `Sfx.at`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._