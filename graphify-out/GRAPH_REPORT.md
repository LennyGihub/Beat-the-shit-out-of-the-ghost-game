# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 97 files · ~212,703 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1187 nodes · 3220 edges · 55 communities (41 shown, 14 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 728 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8f937506`
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
- Admin.luau
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
- Main.server.luau
- script_parent_remotes
- Sfx.play
- EntrancePose.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- Run.luau
- A
- script_parent_remotes
- AdminPanel.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- TutorialUI.luau
- game_getservice
- LockOn.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 39 edges
7. `Kit.ring()` - 31 edges
8. `Ghost.step()` - 30 edges
9. `Sfx.at()` - 30 edges
10. `Grunge.text()` - 28 edges

## Surprising Connections (you probably didn't know these)
- `startMusic()` --calls--> `Sfx.loop()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Intro.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau

## Import Cycles
- None detected.

## Communities (55 total, 14 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.18
Nodes (24): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.freeze(), Ghost.hit() (+16 more)

### Community 1 - "GhostAnim.luau"
Cohesion: 0.21
Nodes (12): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), saberSlash() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.08
Nodes (50): Levels.need(), Levels.of(), Levels.title(), Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings(), Data.addCash() (+42 more)

### Community 5 - "Input.luau"
Cohesion: 0.15
Nodes (25): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+17 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.09
Nodes (49): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+41 more)

### Community 7 - "Platform.mode"
Cohesion: 0.05
Nodes (56): maskBreath(), HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), actionOf(), freeze() (+48 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.09
Nodes (31): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+23 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.28
Nodes (5): LockOn.isOn(), LockOn.tracking(), layout(), make(), TC.init()

### Community 15 - "Admin.luau"
Cohesion: 0.16
Nodes (16): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Data.loaded(), draw(), fmt() (+8 more)

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Intro.luau"
Cohesion: 0.09
Nodes (14): eyeAt(), eyesOn(), faceOf(), groundAt(), jerks(), kick(), lightsBack(), runScript() (+6 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.12
Nodes (18): Abilities.cloneCount(), add(), begin(), cd(), close(), done(), Evolved.chase(), Evolved.interrupt() (+10 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.10
Nodes (27): attach(), clearLine(), detach(), grab(), hand(), Loot.arm(), Loot.clear(), Loot.drop() (+19 more)

### Community 23 - "script_parent_grunge"
Cohesion: 0.16
Nodes (5): CallerUI.call(), LevelUI.init(), build(), Prompts.init(), Shop.result()

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
Cohesion: 0.15
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.28
Nodes (11): Platform.menu(), button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init() (+3 more)

### Community 32 - "Main.server.luau"
Cohesion: 0.07
Nodes (21): display(), Evolved.dress(), Evolved.onSpawn(), Ghost.despawn(), Ghost.spawn(), structParams(), teamSize(), template() (+13 more)

### Community 34 - "script_parent_remotes"
Cohesion: 0.19
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 35 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 36 - "EntrancePose.luau"
Cohesion: 0.18
Nodes (4): Entrance.play(), structure(), EP.height(), EP.pose()

### Community 37 - "Entrance.luau"
Cohesion: 0.05
Nodes (37): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+29 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "Run.luau"
Cohesion: 0.05
Nodes (63): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.hasTemplate(), Furniture.recapture(), Inventory.clearWorld() (+55 more)

### Community 44 - "A"
Cohesion: 0.20
Nodes (10): A(), about(), at(), drag(), idle(), reach(), scream(), scuttle() (+2 more)

### Community 46 - "script_parent_remotes"
Cohesion: 0.20
Nodes (13): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+5 more)

### Community 47 - "AdminPanel.luau"
Cohesion: 0.16
Nodes (16): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+8 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "TutorialUI.luau"
Cohesion: 0.38
Nodes (5): Intro.play(), Intro.running(), play(), remote(), UI.init()

### Community 51 - "game_getservice"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 52 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

## Knowledge Gaps
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Run.luau`, `Events.luau`, `Abilities.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Entrance.luau`, `Input.luau`, `Platform.mode`, `rs_shared_config`, `Spectate.init`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `TutorialUI.luau`, `Intro.luau`, `LobbyUI.luau`, `Sfx.at`, `script_parent_grunge`, `Grunge.text`, `QuestUI.luau`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07966101694915254 - nodes in this community are weakly interconnected._
- **Why does `Acts.timeStop()` connect `Sfx.at` to `Sfx.play`, `Evolved.luau`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.14717741935483872 - nodes in this community are weakly interconnected._
- **Should `Inventory.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08766233766233766 - nodes in this community are weakly interconnected._