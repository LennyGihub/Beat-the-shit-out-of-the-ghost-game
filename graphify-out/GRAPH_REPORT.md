# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-24)

## Corpus Check
- 145 files · ~371,189 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1958 nodes · 5439 edges · 97 communities (80 shown, 17 thin omitted)
- Extraction: 79% EXTRACTED · 21% INFERRED · 0% AMBIGUOUS · INFERRED: 1156 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1dd87441`
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
- HarborFx.luau
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
- script_parent_settings
- CampMonsters.luau
- Main.server.luau
- Cursor.luau
- FreeCam.luau
- A
- Fury.luau
- Events.luau
- script_parent_grunge
- LockOn.luau
- Platform.mode
- game/ReplicatedStorage/Shared/Monsters.luau
- AbbeyMonsters.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau
- Fx.luau
- Hotbar.luau
- TicketShop.luau
- game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau
- MoonMonsters.luau
- Leaderboards.luau
- GoblinLoot.luau
- Ghost.spawn
- Caller.luau
- game/ServerScriptService/Server/Tutorial.luau
- game/ServerScriptService/Server/Run.luau
- CodesUI.luau
- script_parent_furniture
- script_parent_remotes
- game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau
- Server/Quests.luau
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
- `Share.debugLink()` --calls--> `Data.get()`  [INFERRED]
  game/ServerScriptService/Server/Share.luau → game/ServerScriptService/Server/Data.luau
- `Mobile.start()` --calls--> `Guard.ok()`  [INFERRED]
  game/ServerScriptService/Server/Mobile.luau → game/ServerScriptService/Server/Guard.luau
- `layoutBars()` --calls--> `Platform.mode()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `show()` --calls--> `Platform.windowOpen()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/SettingsUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau

## Import Cycles
- None detected.

## Communities (97 total, 17 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.14
Nodes (32): Admin.start(), bringBack(), claw(), die(), dropIt(), floorBelow(), Ghost.alive(), Ghost.damage() (+24 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.11
Nodes (47): Analytics.cash(), M.reset(), cleanSettings(), Data.addCash(), Data.addForm(), Data.addForms(), Data.addXP(), Data.clearStage() (+39 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (20): Charge.active(), Charge.key(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab(), hitDown() (+12 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (48): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+40 more)

### Community 7 - "Sfx.at"
Cohesion: 0.12
Nodes (58): AF.handle(), AF.init(), bellDrop(), bellLock(), bellModel(), bellRise(), bellShadow(), burst() (+50 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.14
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "CampFx.luau"
Cohesion: 0.13
Nodes (40): antlersStuck(), blinded(), burst(), CF.handle(), chargeGo(), chargeLine(), chargeSmash(), clearHook() (+32 more)

### Community 13 - "Settings.luau"
Cohesion: 0.21
Nodes (16): KeyHints.init(), refresh(), toggle(), apply(), defaultFx(), load(), save(), Settings.bind() (+8 more)

### Community 15 - "CarnivalMonsters.luau"
Cohesion: 0.17
Nodes (25): armBall(), ball(), candidates(), clearCurses(), CM.clear(), CM.hitBall(), CM.interrupt(), CM.step() (+17 more)

### Community 16 - "FxTier.luau"
Cohesion: 0.27
Nodes (24): bolt(), buildAura(), burst(), clearAura(), emit(), flashLight(), floorRing(), floorUnder() (+16 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.08
Nodes (16): actionOf(), eyeAt(), eyesOn(), faceOf(), freeze(), groundAt(), jerks(), kick() (+8 more)

### Community 20 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (19): Abilities.cloneCount(), Abilities.spawnClones(), add(), begin(), cd(), close(), done(), Evolved.chase() (+11 more)

### Community 22 - "HarborFx.luau"
Cohesion: 0.19
Nodes (27): place(), anchorSpin(), anchorWarn(), beamSweep(), burst(), diveBurst(), diveLock(), diveRing() (+19 more)

### Community 23 - "SawAudio.luau"
Cohesion: 0.35
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.12
Nodes (30): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.step(), Abilities.tick() (+22 more)

### Community 25 - "FormsPage.luau"
Cohesion: 0.15
Nodes (16): button(), FP.build(), FP.filter(), FP.refresh(), FP.select(), owned(), setIndex(), showDetail() (+8 more)

### Community 26 - "DailyUI.luau"
Cohesion: 0.14
Nodes (19): Daily.cash(), Daily.current(), Daily.label(), Daily.next(), Daily.reward(), Daily.untilTomorrow(), button(), claim() (+11 more)

### Community 27 - "Ragdoll.luau"
Cohesion: 0.36
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+3 more)

### Community 29 - "game/ServerScriptService/Server/Lobby.luau"
Cohesion: 0.25
Nodes (17): Campaign.endlessOpen(), Campaign.stage(), Data.campaign(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start() (+9 more)

### Community 30 - "Grunge.text"
Cohesion: 0.19
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 32 - "PatchNotesUI.luau"
Cohesion: 0.36
Nodes (8): build(), button(), fitText(), refreshButton(), UI.close(), UI.init(), UI.open(), Platform.windowOpen()

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
Cohesion: 0.31
Nodes (13): Campaign.ticketsLeft(), frame(), Grunge.bar(), Grunge.brush(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+5 more)

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
Cohesion: 0.14
Nodes (29): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui() (+21 more)

### Community 46 - "game/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau"
Cohesion: 0.22
Nodes (19): C(), back(), bottle(), doFlash(), embers(), FC.play(), hideItem(), jar() (+11 more)

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
Cohesion: 0.32
Nodes (5): LockOn.isOn(), LockOn.tracking(), layout(), make(), TC.init()

### Community 51 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 52 - "steps"
Cohesion: 0.12
Nodes (16): ROBLOX_API_KEY, jobs, send, name, on, schedule, workflow_dispatch, cron (+8 more)

### Community 54 - "game/ServerScriptService/Server/Share.luau"
Cohesion: 0.17
Nodes (19): Analytics.custom(), Analytics.joined(), Analytics.lesson(), Analytics.onboard(), Analytics.stage(), fields(), logStep(), send() (+11 more)

### Community 56 - "FormGiant.luau"
Cohesion: 0.25
Nodes (17): bright(), copy(), dark(), decorate(), emitter(), FG.burst(), FG.clear(), FG.scaleOf() (+9 more)

### Community 57 - "SellerUI.luau"
Cohesion: 0.22
Nodes (13): before(), button(), clear(), level(), owned(), refresh(), setOpen(), UI.close() (+5 more)

### Community 59 - "script_parent_settings"
Cohesion: 0.26
Nodes (9): maskBreath(), half(), MaskBreath.start(), pause(), sound(), bladeIgnite(), Settings.group(), make() (+1 more)

### Community 60 - "CampMonsters.luau"
Cohesion: 0.20
Nodes (20): begin(), candidates(), CM.chaseHold(), CM.step(), CM.try(), face(), floorBelow(), getFire() (+12 more)

### Community 61 - "Main.server.luau"
Cohesion: 0.08
Nodes (5): Notify.debug(), Notify.plan(), Notify.setup(), Notify.start(), write()

### Community 62 - "Cursor.luau"
Cohesion: 0.60
Nodes (4): Cursor.hold(), Cursor.init(), Cursor.toggle(), update()

### Community 63 - "FreeCam.luau"
Cohesion: 0.33
Nodes (10): bindKeys(), FC.init(), FC.set(), makeHint(), playerControls(), refreshHint(), setUiHidden(), shiftDown() (+2 more)

### Community 64 - "A"
Cohesion: 0.20
Nodes (10): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+2 more)

### Community 65 - "Fury.luau"
Cohesion: 0.33
Nodes (8): Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable(), Fury.windUp()

### Community 66 - "Events.luau"
Cohesion: 0.08
Nodes (40): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+32 more)

### Community 67 - "script_parent_grunge"
Cohesion: 0.12
Nodes (7): Campaign.clean(), CallerUI.call(), buildStages(), progress(), show(), UI.close(), Shop.result()

### Community 68 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 69 - "Platform.mode"
Cohesion: 0.26
Nodes (15): liftHint(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.label() (+7 more)

### Community 71 - "AbbeyMonsters.luau"
Cohesion: 0.17
Nodes (20): airborne(), AM.interrupt(), AM.step(), AM.try(), begin(), behind(), candidates(), dropProj() (+12 more)

### Community 73 - "game/StarterPlayer/StarterPlayerScripts/Client/FormSets.luau"
Cohesion: 0.27
Nodes (25): abbBody(), abbFist(), att(), bp(), bright(), bulbs(), campBody(), campFist() (+17 more)

### Community 74 - "Fx.luau"
Cohesion: 0.12
Nodes (7): Fx.applyZone(), Fx.init(), HUD.hint(), HUD.setVisible(), HUD.update(), layoutBars(), updateWaypoint()

### Community 76 - "Hotbar.luau"
Cohesion: 0.28
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.drop(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse() (+4 more)

### Community 77 - "TicketShop.luau"
Cohesion: 0.70
Nodes (4): pid(), TS.buy(), TS.label(), TS.ready()

### Community 78 - "game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau"
Cohesion: 0.18
Nodes (14): arrowShape(), boardKey(), FT.init(), FT.play(), owns(), queued(), sellerModel(), talkKey() (+6 more)

### Community 79 - "MoonMonsters.luau"
Cohesion: 0.20
Nodes (15): begin(), breachSpot(), candidates(), face(), floorBelow(), fxFolder(), glob(), hitAround() (+7 more)

### Community 80 - "Leaderboards.luau"
Cohesion: 0.30
Nodes (10): draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top(), write() (+2 more)

### Community 81 - "GoblinLoot.luau"
Cohesion: 0.21
Nodes (22): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm() (+14 more)

### Community 83 - "Ghost.spawn"
Cohesion: 0.18
Nodes (11): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open() (+3 more)

### Community 84 - "Caller.luau"
Cohesion: 0.11
Nodes (27): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+19 more)

### Community 85 - "game/ServerScriptService/Server/Tutorial.luau"
Cohesion: 0.18
Nodes (17): M.start(), Data.setTutorialSeen(), drop(), Guard.int(), Guard.limit(), Guard.num(), Guard.ok(), Guard.vec() (+9 more)

### Community 86 - "game/ServerScriptService/Server/Run.luau"
Cohesion: 0.05
Nodes (81): Campaign.cleared(), Campaign.clock(), Campaign.goal(), Campaign.isLast(), Campaign.mapDone(), Campaign.mapOpen(), Campaign.nextStage(), Campaign.stageOpen() (+73 more)

### Community 87 - "CodesUI.luau"
Cohesion: 0.29
Nodes (9): button(), redeem(), say(), UI.close(), UI.init(), UI.open(), UI.result(), Platform.menu() (+1 more)

### Community 88 - "script_parent_furniture"
Cohesion: 0.21
Nodes (4): face(), Knight.step(), Knight.try(), sees()

### Community 90 - "script_parent_remotes"
Cohesion: 0.09
Nodes (10): Admin.run(), isAdmin(), isFullAdmin(), passId(), Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh() (+2 more)

### Community 91 - "game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau"
Cohesion: 0.23
Nodes (15): button(), hideCard(), invite(), launchData(), refreshReward(), reward(), say(), shareLink() (+7 more)

### Community 94 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 97 - "Levels.of"
Cohesion: 0.60
Nodes (4): Levels.need(), Levels.of(), Levels.title(), Levels.total()

### Community 101 - "Furniture.smash"
Cohesion: 0.14
Nodes (27): begin(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.hasTemplate(), Furniture.isValid(), Furniture.near() (+19 more)

### Community 107 - "game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau"
Cohesion: 0.36
Nodes (8): HUD.toast(), clear(), dust(), liftLabel(), monster(), ring(), WeakFx.handle(), WeakFx.init()

### Community 110 - "game/StarterPlayer/StarterPlayerScripts/Client/Translate.luau"
Cohesion: 0.57
Nodes (5): lookup(), remember(), store(), T.auto(), T.t()

### Community 115 - "Server/Vip.luau"
Cohesion: 0.28
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

## Knowledge Gaps
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `Input.luau`, `Sfx.at`, `rs_shared_config`, `CampFx.luau`, `Sfx.at`, `Intro.luau`, `HarborFx.luau`, `FormsPage.luau`, `DailyUI.luau`, `Grunge.text`, `QuestUI.luau`, `PatchNotesUI.luau`, `Entrance.luau`, `Grunge.brush`, `Spectate.init`, `CarnivalFx.luau`, `MonsterFx.luau`, `TrainRide.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau`, `RoomPickUI.luau`, `Charge.luau`, `SellerUI.luau`, `script_parent_settings`, `script_parent_grunge`, `Hotbar.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`, `Caller.luau`, `CodesUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/ShareUI.luau`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Are the 83 inferred relationships involving `Sfx.at()` (e.g. with `AF.handle()` and `bellDrop()`) actually correct?**
  _`Sfx.at()` has 83 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13663663663663664 - nodes in this community are weakly interconnected._
- **Why does `A()` connect `A` to `GhostAnim.luau`, `ItemModels.luau`, `Events.luau`, `EntrancePose.luau`, `CampFx.luau`, `TrainRide.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/FormCine.luau`, `Intro.luau`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Are the 72 inferred relationships involving `Sfx.play()` (e.g. with `bellShadow()` and `setRung()`) actually correct?**
  _`Sfx.play()` has 72 INFERRED edges - model-reasoned connections that need verification._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._
- **Why does `Sfx.at()` connect `Sfx.at` to `Sfx.at`, `rs_shared_config`, `CarnivalFx.luau`, `MonsterFx.luau`, `CampFx.luau`, `TrainRide.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/WeakFx.luau`, `FxTier.luau`, `HarborFx.luau`, `script_parent_settings`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._