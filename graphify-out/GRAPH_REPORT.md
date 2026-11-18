# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 97 files · ~206,969 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1169 nodes · 3182 edges · 57 communities (43 shown, 14 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 723 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1c1c6055`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- Intro.luau
- ItemModels.luau
- Data.luau
- Input.luau
- Inventory.luau
- Fire.luau
- rs_shared_config
- Events.luau
- LockOn.luau
- Admin.luau
- Sfx.at
- Run.startFight
- LobbyUI.luau
- Evolved.luau
- Abilities.luau
- script_parent_grunge
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- Furniture.luau
- UltRunner.luau
- Grunge.text
- QuestUI.luau
- Main.server.luau
- MapLoader.luau
- TouchControls.luau
- AdminPanel.luau
- Entrance.luau
- Grunge.brush
- Spectate.init
- Loading.luau
- Run.luau
- Sandbox.luau
- Sfx.play
- TutorialUI.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- ReviveUI.luau
- game_getservice
- Run.payout
- onPlayer
- Supplies.luau

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
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau

## Import Cycles
- None detected.

## Communities (57 total, 14 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.17
Nodes (20): bringBack(), claw(), die(), floorBelow(), Ghost.freeze(), Ghost.launch(), Ghost.setVortex(), Ghost.shove() (+12 more)

### Community 1 - "Intro.luau"
Cohesion: 0.06
Nodes (28): Entrance.play(), structure(), EP.height(), EP.pose(), abilityPose(), addJoint(), bind(), GA.update() (+20 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.07
Nodes (60): Levels.need(), Levels.of(), Levels.title(), Bestiary.check(), Bestiary.record(), cleanSettings(), Data.addCash(), Data.addXP() (+52 more)

### Community 5 - "Input.luau"
Cohesion: 0.05
Nodes (63): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+55 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.20
Nodes (27): Ghost.vuln(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+19 more)

### Community 7 - "Fire.luau"
Cohesion: 0.09
Nodes (32): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+24 more)

### Community 8 - "rs_shared_config"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.33
Nodes (8): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target()

### Community 15 - "Admin.luau"
Cohesion: 0.14
Nodes (4): Admin.run(), isAdmin(), isFullAdmin(), passId()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.startFight"
Cohesion: 0.27
Nodes (15): Inventory.clearWorld(), Lobby.returnPlayer(), clearTemp(), insideHouse(), onGhostDeath(), Run.endMatch(), Run.matchPlayers(), Run.removeFromMatch() (+7 more)

### Community 20 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.08
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.13
Nodes (32): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+24 more)

### Community 23 - "script_parent_grunge"
Cohesion: 0.14
Nodes (5): CallerUI.call(), LevelUI.init(), build(), Prompts.init(), Shop.result()

### Community 24 - "Abilities.luau"
Cohesion: 0.07
Nodes (50): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+42 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.29
Nodes (13): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+5 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "Furniture.luau"
Cohesion: 0.24
Nodes (11): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+3 more)

### Community 29 - "UltRunner.luau"
Cohesion: 0.27
Nodes (18): Admin.start(), Furniture.near(), Furniture.smash(), Ghost.alive(), Ghost.burn(), Ghost.damage(), Ghost.hit(), stepKnocked() (+10 more)

### Community 30 - "Grunge.text"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "QuestUI.luau"
Cohesion: 0.36
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 32 - "Main.server.luau"
Cohesion: 0.06
Nodes (24): Evolved.onSpawn(), Ghost.despawn(), Ghost.spawn(), structParams(), teamSize(), template(), KnightDoor.open(), KnightDoor.pick() (+16 more)

### Community 34 - "MapLoader.luau"
Cohesion: 0.29
Nodes (10): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+2 more)

### Community 35 - "TouchControls.luau"
Cohesion: 0.47
Nodes (3): layout(), make(), TC.init()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (27): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+19 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.05
Nodes (37): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+29 more)

### Community 39 - "Grunge.brush"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 40 - "Spectate.init"
Cohesion: 0.46
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 41 - "Loading.luau"
Cohesion: 0.40
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "Run.luau"
Cohesion: 0.16
Nodes (16): Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), doorPrompt(), endDeath(), hrpOf() (+8 more)

### Community 44 - "Sandbox.luau"
Cohesion: 0.42
Nodes (9): Run.setSandbox(), center(), enter(), leave(), Sandbox.active(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 46 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 47 - "TutorialUI.luau"
Cohesion: 0.28
Nodes (6): Loading.isShown(), Intro.play(), Intro.running(), play(), remote(), UI.init()

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "ReviveUI.luau"
Cohesion: 0.42
Nodes (8): Platform.menu(), productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), Shop.open()

### Community 51 - "game_getservice"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 52 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 53 - "onPlayer"
Cohesion: 0.33
Nodes (7): onPlayer(), Bestiary.setup(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running()

### Community 56 - "Supplies.luau"
Cohesion: 0.47
Nodes (3): alive(), Supplies.pick(), Supplies.spawn()

## Knowledge Gaps
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Supplies.luau`, `Events.luau`, `Abilities.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.070) - this node is a cross-community bridge._
- **Should `Intro.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06207482993197279 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `Entrance.luau`, `Input.luau`, `Fire.luau`, `rs_shared_config`, `Spectate.init`, `TutorialUI.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `ReviveUI.luau`, `Sfx.at`, `LobbyUI.luau`, `script_parent_grunge`, `Grunge.text`, `QuestUI.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Why does `UI.init()` connect `TutorialUI.luau` to `Sfx.play`, `Grunge.text`, `Grunge.brush`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06935908691834942 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05289450484866295 - nodes in this community are weakly interconnected._