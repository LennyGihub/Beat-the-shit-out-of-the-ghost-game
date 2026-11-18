# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 92 files · ~191,051 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1110 nodes · 3074 edges · 63 communities (45 shown, 18 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 704 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `700a80ff`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- MonsterFx.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- Caller.luau
- CineKit.luau
- Events.luau
- Fx.luau
- Admin.luau
- Sfx.at
- Run.luau
- Platform.mode
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Abilities.luau
- Ragdoll.luau
- script_parent_sfx
- LobbyUI.luau
- QuestUI.luau
- Grunge.text
- TutorialUI.luau
- script_parent_platform
- rs_shared_config
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- AdminPanel.luau
- Entrance.luau
- Spectate.init
- Bestiary.luau
- Loading.luau
- Lobby.luau
- Leaderboards.luau
- Sfx.play
- Furniture.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- SawAudio.luau
- Server/Quests.luau
- rs_shared_items
- Server/Tutorial.luau
- CallerMarks.luau
- Grunge.brush
- NameTags.luau
- Viewmodel.luau
- CrewAnim.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 40 edges
7. `Kit.ring()` - 31 edges
8. `Ghost.step()` - 29 edges
9. `Sfx.at()` - 29 edges
10. `Grunge.text()` - 27 edges

## Surprising Connections (you probably didn't know these)
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Abilities.clear()` --calls--> `Loot.clear()`  [INFERRED]
  game/ServerScriptService/Server/Abilities.luau → game/ServerScriptService/Server/GoblinLoot.luau
- `UI.init()` --calls--> `Loading.isShown()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TutorialUI.luau → game/ReplicatedFirst/Loading.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (63 total, 18 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.20
Nodes (23): Admin.start(), checkThrown(), checkThrownPlayers(), Furniture.near(), Furniture.smash(), Furniture.weight(), Ghost.alive(), Ghost.burn() (+15 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.09
Nodes (22): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+14 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.23
Nodes (21): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+13 more)

### Community 5 - "Input.luau"
Cohesion: 0.09
Nodes (42): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+34 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (46): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+38 more)

### Community 7 - "Caller.luau"
Cohesion: 0.15
Nodes (18): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+10 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.19
Nodes (27): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+19 more)

### Community 12 - "Events.luau"
Cohesion: 0.20
Nodes (27): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+19 more)

### Community 15 - "Admin.luau"
Cohesion: 0.14
Nodes (4): Admin.run(), isAdmin(), isFullAdmin(), passId()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.06
Nodes (61): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Inventory.clearWorld(), Lobby.returnPlayer() (+53 more)

### Community 20 - "Platform.mode"
Cohesion: 0.38
Nodes (9): firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), setMode(), shown() (+1 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (19): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+11 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.13
Nodes (32): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+24 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.13
Nodes (28): Abilities.clear(), Evolved.interrupt(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.despawn() (+20 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.18
Nodes (27): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+19 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.35
Nodes (10): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.start(), Ragdoll.step() (+2 more)

### Community 26 - "script_parent_sfx"
Cohesion: 0.14
Nodes (6): CallerUI.call(), bezier(), build(), Prompts.init(), show(), Shop.result()

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
Cohesion: 0.21
Nodes (9): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), Platform.label(), Platform.mode(), Platform.windowOpen(), label() (+1 more)

### Community 34 - "rs_shared_config"
Cohesion: 0.18
Nodes (3): Combat.healAll(), Combat.refreshHealth(), Combat.start()

### Community 35 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.32
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 39 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 40 - "Bestiary.luau"
Cohesion: 0.36
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (9): grab(), Loading.build(), Loading.hide(), Loading.isShown(), Loading.progress(), Loading.show(), Loading.teleport(), N() (+1 more)

### Community 42 - "Lobby.luau"
Cohesion: 0.35
Nodes (13): Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), onPad(), onParty(), partyOf() (+5 more)

### Community 44 - "Leaderboards.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

### Community 46 - "Sfx.play"
Cohesion: 0.18
Nodes (15): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+7 more)

### Community 47 - "Furniture.luau"
Cohesion: 0.29
Nodes (9): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+1 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 52 - "Server/Quests.luau"
Cohesion: 0.44
Nodes (8): claim(), progress(), publish(), Quests.setup(), Quests.start(), state(), today(), untilReset()

### Community 53 - "rs_shared_items"
Cohesion: 0.32
Nodes (3): clear(), selectedId(), step()

### Community 54 - "Server/Tutorial.luau"
Cohesion: 0.40
Nodes (7): complete(), finish(), progress(), setStep(), start(), stop(), Tutorial.start()

### Community 56 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 57 - "Grunge.brush"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 60 - "NameTags.luau"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 62 - "CrewAnim.luau"
Cohesion: 0.50
Nodes (3): add(), CrewAnim.init(), joint()

## Knowledge Gaps
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Run.luau`, `Events.luau`, `rs_shared_items`, `Abilities.luau`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08901515151515152 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `Spectate.init`, `CineKit.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `script_parent_sfx`, `LobbyUI.luau`, `QuestUI.luau`, `Grunge.text`, `TutorialUI.luau`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06060606060606061 - nodes in this community are weakly interconnected._
- **Why does `Supplies.spawn()` connect `Run.luau` to `ItemModels.luau`, `Events.luau`, `Inventory.luau`?**
  _High betweenness centrality (0.042) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08597285067873303 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09224318658280922 - nodes in this community are weakly interconnected._