# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 86 files · ~183,753 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1052 nodes · 2911 edges · 57 communities (42 shown, 15 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 665 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `68920bdb`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- MonsterFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Input.luau
- Inventory.luau
- LobbyUI.luau
- CineKit.luau
- Events.luau
- Grunge.luau
- script_parent_sfx
- Sfx.at
- Run.luau
- Fx.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- game/ServerScriptService/Server/Sandbox.luau
- Ragdoll.luau
- QuestUI.luau
- RoomPickUI.luau
- SawAudio.luau
- BestiaryUI.luau
- NameTags.luau
- rs_shared_items
- rs_shared_config
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- AdminPanel.luau
- Entrance.luau
- script_parent_remotes
- ReviveUI.luau
- Loading.luau
- Viewmodel.luau
- Friends.luau
- CallerMarks.luau
- Sfx.play
- Fire.luau
- onPlayer
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- MapLoader.luau
- Lobby.luau
- CrewAnim.luau
- Leaderboards.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 36 edges
7. `Kit.ring()` - 31 edges
8. `Sfx.at()` - 29 edges
9. `Ghost.step()` - 29 edges
10. `Kit.chunks()` - 25 edges

## Surprising Connections (you probably didn't know these)
- `CallerUI.call()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/CallerUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (57 total, 15 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.16
Nodes (24): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+16 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.09
Nodes (24): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+16 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.05
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 4 - "Data.luau"
Cohesion: 0.20
Nodes (25): Bestiary.check(), Bestiary.record(), cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt() (+17 more)

### Community 5 - "Input.luau"
Cohesion: 0.06
Nodes (57): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+49 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.23
Nodes (24): alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear(), Inventory.give() (+16 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Grunge.luau"
Cohesion: 0.56
Nodes (9): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+1 more)

### Community 15 - "script_parent_sfx"
Cohesion: 0.16
Nodes (4): CallerUI.call(), build(), Prompts.init(), Shop.result()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.13
Nodes (31): Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), clearTemp() (+23 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (56): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+48 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.12
Nodes (33): Abilities.clear(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage() (+25 more)

### Community 24 - "game/ServerScriptService/Server/Sandbox.luau"
Cohesion: 0.21
Nodes (15): onPlayer(), Bestiary.setup(), Events.despawn(), MapLoader.spawnInside(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running() (+7 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 30 - "BestiaryUI.luau"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "NameTags.luau"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 32 - "rs_shared_items"
Cohesion: 0.32
Nodes (3): clear(), selectedId(), step()

### Community 34 - "rs_shared_config"
Cohesion: 0.18
Nodes (6): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Furniture.weight()

### Community 35 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.32
Nodes (4): Kit.now(), apply(), Pose.init(), Pose.play()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 39 - "script_parent_remotes"
Cohesion: 0.13
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 40 - "ReviveUI.luau"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 43 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 44 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 46 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 47 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 48 - "onPlayer"
Cohesion: 0.47
Nodes (9): claim(), progress(), publish(), Quests.add(), Quests.setup(), Quests.start(), state(), today() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.38
Nodes (10): Platform.menu(), button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen() (+2 more)

### Community 50 - "MapLoader.luau"
Cohesion: 0.31
Nodes (9): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+1 more)

### Community 52 - "Lobby.luau"
Cohesion: 0.36
Nodes (11): hrpOf(), launch(), leaveParty(), onPad(), onParty(), partyOf(), prepSign(), publish() (+3 more)

### Community 53 - "CrewAnim.luau"
Cohesion: 0.50
Nodes (3): add(), CrewAnim.init(), joint()

### Community 54 - "Leaderboards.luau"
Cohesion: 0.27
Nodes (11): Data.loaded(), draw(), fmt(), isAdmin(), Leaderboards.start(), nameOf(), screen(), top() (+3 more)

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `rs_shared_items`, `Events.luau`, `Abilities.luau`?**
  _High betweenness centrality (0.090) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09243697478991597 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0467687074829932 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `ReviveUI.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `Fx.luau`, `QuestUI.luau`, `RoomPickUI.luau`, `BestiaryUI.luau`?**
  _High betweenness centrality (0.058) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05898021308980213 - nodes in this community are weakly interconnected._
- **Should `Sfx.at` be split into smaller, more focused modules?**
  _Cohesion score 0.12203829925348912 - nodes in this community are weakly interconnected._