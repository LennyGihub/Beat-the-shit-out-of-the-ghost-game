# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-17)

## Corpus Check
- 87 files · ~185,028 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1067 nodes · 2953 edges · 52 communities (38 shown, 14 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 678 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `72def415`
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
- Settings.luau
- Ragdoll.luau
- QuestUI.luau
- RoomPickUI.luau
- Platform.mode
- BestiaryUI.luau
- NameTags.luau
- Platform.luau
- rs_shared_config
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- AdminPanel.luau
- Entrance.luau
- TouchControls.luau
- ReviveUI.luau
- Loading.luau
- LockOn.luau
- CallerMarks.luau
- Sfx.play
- Fire.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- Main.server.luau

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
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau

## Import Cycles
- None detected.

## Communities (52 total, 14 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.17
Nodes (23): Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release() (+15 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.18
Nodes (11): beamOff(), beamTo(), blackout(), disc(), emitter(), jumpscare(), lightsOut(), near() (+3 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.07
Nodes (56): Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get() (+48 more)

### Community 5 - "Input.luau"
Cohesion: 0.14
Nodes (26): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+18 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.19
Nodes (28): Ghost.freeze(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode(), get() (+20 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.32
Nodes (14): bigButton(), button(), heading(), LobbyUI.init(), LobbyUI.togglePlay(), ownedMaps(), paint(), parties() (+6 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.08
Nodes (33): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+25 more)

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
Cohesion: 0.05
Nodes (64): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+56 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.20
Nodes (23): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.arm() (+15 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.10
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (49): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+41 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.15
Nodes (27): Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.hit() (+19 more)

### Community 24 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+7 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "QuestUI.luau"
Cohesion: 0.32
Nodes (9): button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init(), QuestUI.open() (+1 more)

### Community 27 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 29 - "Platform.mode"
Cohesion: 0.22
Nodes (9): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), Platform.label(), Platform.mode(), label() (+1 more)

### Community 30 - "BestiaryUI.luau"
Cohesion: 0.20
Nodes (20): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+12 more)

### Community 31 - "NameTags.luau"
Cohesion: 0.32
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 32 - "Platform.luau"
Cohesion: 0.31
Nodes (11): firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.windowOpen(), setMode() (+3 more)

### Community 34 - "rs_shared_config"
Cohesion: 0.19
Nodes (6): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Furniture.weight()

### Community 35 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.13
Nodes (9): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play(), ease() (+1 more)

### Community 36 - "AdminPanel.luau"
Cohesion: 0.11
Nodes (25): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+17 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 39 - "TouchControls.luau"
Cohesion: 0.32
Nodes (4): LockOn.tracking(), layout(), make(), TC.init()

### Community 40 - "ReviveUI.luau"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 42 - "LockOn.luau"
Cohesion: 0.39
Nodes (7): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), step(), target()

### Community 44 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 46 - "Sfx.play"
Cohesion: 0.30
Nodes (13): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+5 more)

### Community 47 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.38
Nodes (10): Platform.menu(), button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen() (+2 more)

### Community 51 - "Main.server.luau"
Cohesion: 0.11
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

## Knowledge Gaps
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `LobbyUI.luau`, `CineKit.luau`, `ReviveUI.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `QuestUI.luau`, `RoomPickUI.luau`, `BestiaryUI.luau`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._
- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `GoblinLoot.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06919945725915876 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13725490196078433 - nodes in this community are weakly interconnected._
- **Should `CineKit.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08282828282828283 - nodes in this community are weakly interconnected._