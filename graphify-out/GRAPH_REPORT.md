# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 93 files · ~195,619 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1121 nodes · 3091 edges · 60 communities (44 shown, 16 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 700 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5a77141a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- MonsterFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Input.luau
- Inventory.luau
- Caller.luau
- CineKit.luau
- Events.luau
- LockOn.luau
- Admin.luau
- Sfx.at
- Run.luau
- Platform.mode
- Evolved.luau
- Abilities.luau
- Ghost.step
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- LobbyUI.luau
- QuestUI.luau
- Grunge.text
- TutorialUI.luau
- script_parent_platform
- MapLoader.luau
- Leaderboards.luau
- AdminPanel.luau
- Entrance.luau
- Spectate.init
- GhostAnim.luau
- Loading.luau
- Run.onDied
- Sandbox.luau
- Sfx.play
- Furniture.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- Settings.luau
- EntrancePose.luau
- Run.payout
- script_parent_remotes
- rs_shared_config
- Supplies.luau
- Grunge.brush

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 40 edges
7. `Kit.ring()` - 31 edges
8. `Sfx.at()` - 30 edges
9. `Ghost.step()` - 30 edges
10. `Grunge.text()` - 27 edges

## Surprising Connections (you probably didn't know these)
- `Abilities.clear()` --calls--> `Loot.clear()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Run.endMatch()` --calls--> `Supplies.clear()`  [INFERRED]
  game/ServerScriptService/Server/Run.luau → game/ServerScriptService/Server/Supplies.luau

## Import Cycles
- None detected.

## Communities (60 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.13
Nodes (30): Abilities.clear(), Evolved.onSpawn(), die(), Ghost.alive(), Ghost.damage(), Ghost.despawn(), Ghost.freeze(), Ghost.hit() (+22 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.06
Nodes (53): Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get() (+45 more)

### Community 5 - "Input.luau"
Cohesion: 0.14
Nodes (26): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+18 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (48): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+40 more)

### Community 7 - "Caller.luau"
Cohesion: 0.15
Nodes (18): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+10 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.16
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.20
Nodes (27): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+19 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.18
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 15 - "Admin.luau"
Cohesion: 0.20
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.18
Nodes (18): Events.despawn(), Inventory.clearWorld(), cashMult(), clearTemp(), doorPrompt(), hrpOf(), insideHouse(), onBuy() (+10 more)

### Community 20 - "Platform.mode"
Cohesion: 0.30
Nodes (13): liftHint(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.label() (+5 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.20
Nodes (23): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+15 more)

### Community 23 - "Ghost.step"
Cohesion: 0.16
Nodes (18): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+10 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.17
Nodes (27): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+19 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 29 - "QuestUI.luau"
Cohesion: 0.28
Nodes (11): Platform.menu(), button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init() (+3 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "TutorialUI.luau"
Cohesion: 0.32
Nodes (12): answer(), button(), closeOffer(), fill(), inTutorial(), keyText(), nextCard(), offer() (+4 more)

### Community 32 - "script_parent_platform"
Cohesion: 0.14
Nodes (9): CallerUI.call(), HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), Platform.windowOpen(), build(), Prompts.init() (+1 more)

### Community 34 - "MapLoader.luau"
Cohesion: 0.24
Nodes (12): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+4 more)

### Community 35 - "Leaderboards.luau"
Cohesion: 0.24
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 36 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (27): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+19 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.09
Nodes (21): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+13 more)

### Community 39 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 40 - "GhostAnim.luau"
Cohesion: 0.24
Nodes (9): abilityPose(), addJoint(), bind(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash(), target() (+1 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (9): grab(), Loading.build(), Loading.hide(), Loading.isShown(), Loading.progress(), Loading.show(), Loading.teleport(), N() (+1 more)

### Community 42 - "Run.onDied"
Cohesion: 0.17
Nodes (17): onPlayer(), Inventory.clear(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), checkWipe(), endDeath() (+9 more)

### Community 44 - "Sandbox.luau"
Cohesion: 0.42
Nodes (8): Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 46 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 47 - "Furniture.luau"
Cohesion: 0.24
Nodes (13): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+5 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "Settings.luau"
Cohesion: 0.10
Nodes (28): KeyHints.init(), refresh(), toggle(), bladeIgnite(), oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init() (+20 more)

### Community 51 - "EntrancePose.luau"
Cohesion: 0.22
Nodes (3): EP.height(), EP.pose(), GA.update()

### Community 52 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 53 - "script_parent_remotes"
Cohesion: 0.31
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 56 - "Supplies.luau"
Cohesion: 0.38
Nodes (4): alive(), Supplies.clear(), Supplies.pick(), Supplies.spawn()

### Community 57 - "Grunge.brush"
Cohesion: 0.24
Nodes (13): Vip.start(), frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat() (+5 more)

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `script_parent_platform`, `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `Spectate.init`, `CineKit.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Settings.luau`, `Sfx.at`, `rs_shared_config`, `LobbyUI.luau`, `QuestUI.luau`, `Grunge.text`, `TutorialUI.luau`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12698412698412698 - nodes in this community are weakly interconnected._
- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Supplies.luau`, `Events.luau`, `Abilities.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.063) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13405797101449277 - nodes in this community are weakly interconnected._
- **Why does `UI.init()` connect `TutorialUI.luau` to `Loading.luau`, `Sfx.play`, `Grunge.brush`, `QuestUI.luau`, `Grunge.text`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05561105561105561 - nodes in this community are weakly interconnected._