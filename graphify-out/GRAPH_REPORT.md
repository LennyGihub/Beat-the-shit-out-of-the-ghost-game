# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 84 files · ~182,245 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1034 nodes · 2879 edges · 54 communities (40 shown, 14 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 657 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5905048e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Furniture.smash
- MonsterFx.luau
- ItemModels.luau
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
- GoblinLoot.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Bestiary.luau
- Ragdoll.luau
- QuestUI.luau
- RoomPickUI.luau
- Settings.luau
- BestiaryUI.luau
- TouchControls.luau
- LockOn.luau
- rs_shared_config
- AdminPanel.luau
- Entrance.luau
- script_parent_remotes
- Spectate.luau
- Loading.luau
- CallerMarks.luau
- Sfx.play
- Fire.luau
- onPlayer
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- MapLoader.luau
- Main.server.luau
- Lobby.luau
- Leaderboards.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 36 edges
7. `Kit.ring()` - 31 edges
8. `Ghost.step()` - 29 edges
9. `Sfx.at()` - 29 edges
10. `Kit.chunks()` - 25 edges

## Surprising Connections (you probably didn't know these)
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau

## Import Cycles
- None detected.

## Communities (54 total, 14 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.17
Nodes (23): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+15 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.16
Nodes (12): buildPhone(), beamOff(), beamTo(), blackout(), disc(), emitter(), jumpscare(), lightsOut() (+4 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.25
Nodes (19): cleanSettings(), Data.addCash(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own(), Data.owns() (+11 more)

### Community 5 - "Input.luau"
Cohesion: 0.08
Nodes (40): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+32 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.21
Nodes (26): Ghost.freeze(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode(), get() (+18 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (28): base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat(), Kit.handOff() (+20 more)

### Community 12 - "Events.luau"
Cohesion: 0.19
Nodes (28): Config.eventTime(), ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt() (+20 more)

### Community 13 - "Grunge.luau"
Cohesion: 0.37
Nodes (11): frame(), Grunge.bar(), Grunge.brush(), Grunge.paint(), Grunge.panel(), Grunge.slab(), Grunge.splat(), sketch() (+3 more)

### Community 15 - "script_parent_sfx"
Cohesion: 0.15
Nodes (7): CallerUI.call(), Platform.menu(), productId(), ReviveUI.handle(), ReviveUI.init(), Shop.open(), Shop.result()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.13
Nodes (30): Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), clearTemp() (+22 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+14 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (47): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+39 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.14
Nodes (30): Abilities.clear(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage() (+22 more)

### Community 24 - "Bestiary.luau"
Cohesion: 0.27
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "Settings.luau"
Cohesion: 0.11
Nodes (26): KeyHints.init(), refresh(), toggle(), oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used() (+18 more)

### Community 30 - "BestiaryUI.luau"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "TouchControls.luau"
Cohesion: 0.28
Nodes (5): LockOn.isOn(), LockOn.tracking(), layout(), make(), TC.init()

### Community 32 - "LockOn.luau"
Cohesion: 0.48
Nodes (6): isDecoy(), LockOn.init(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 34 - "rs_shared_config"
Cohesion: 0.24
Nodes (6): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Furniture.weight()

### Community 36 - "AdminPanel.luau"
Cohesion: 0.06
Nodes (27): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+19 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 39 - "script_parent_remotes"
Cohesion: 0.14
Nodes (12): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), center(), enter(), leave() (+4 more)

### Community 40 - "Spectate.luau"
Cohesion: 0.57
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

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
Cohesion: 0.25
Nodes (12): areFriends(), Friends.mult(), refresh(), claim(), progress(), publish(), Quests.add(), Quests.setup() (+4 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

### Community 50 - "MapLoader.luau"
Cohesion: 0.22
Nodes (13): Events.despawn(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+5 more)

### Community 51 - "Main.server.luau"
Cohesion: 0.10
Nodes (5): onPlayer(), Inventory.clear(), Run.addToMatch(), Run.running(), Vip.start()

### Community 52 - "Lobby.luau"
Cohesion: 0.31
Nodes (14): Data.equipped(), Data.ownsMap(), hrpOf(), launch(), leaveParty(), Lobby.start(), onPad(), onParty() (+6 more)

### Community 54 - "Leaderboards.luau"
Cohesion: 0.39
Nodes (8): Data.loaded(), draw(), fmt(), Leaderboards.start(), nameOf(), screen(), top(), write()

## Knowledge Gaps
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `GoblinLoot.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.064) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07407407407407407 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `Spectate.luau`, `Grunge.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `QuestUI.luau`, `RoomPickUI.luau`, `Settings.luau`, `BestiaryUI.luau`?**
  _High betweenness centrality (0.059) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08345428156748912 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Should `CineKit.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1492063492063492 - nodes in this community are weakly interconnected._
- **Should `Sfx.at` be split into smaller, more focused modules?**
  _Cohesion score 0.12203829925348912 - nodes in this community are weakly interconnected._