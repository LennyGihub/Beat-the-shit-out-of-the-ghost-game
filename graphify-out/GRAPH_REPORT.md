# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 95 files · ~200,034 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1137 nodes · 3124 edges · 57 communities (41 shown, 16 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 706 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `700832bb`
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
- Server/Tutorial.luau
- Platform.mode
- Evolved.luau
- Abilities.luau
- Fury.luau
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- AdminPanel.luau
- Ghost.step
- Grunge.text
- TutorialUI.luau
- MapLoader.luau
- TouchControls.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- Entrance.luau
- Spectate.init
- Bestiary.luau
- Loading.luau
- Run.luau
- Sandbox.luau
- Sfx.play
- Furniture.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- Settings.luau
- Run.payout
- rs_shared_config
- Supplies.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 40 edges
7. `Kit.ring()` - 31 edges
8. `Ghost.step()` - 30 edges
9. `Sfx.at()` - 30 edges
10. `Grunge.text()` - 27 edges

## Surprising Connections (you probably didn't know these)
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Evolved.onSpawn()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.spawn()` --calls--> `Ragdoll.restoreWalls()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (57 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.11
Nodes (21): die(), Ghost.despawn(), Ghost.freeze(), Ghost.setVortex(), Ghost.shove(), Ghost.slow(), Ghost.spawn(), Ghost.timeStop() (+13 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.08
Nodes (53): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.loaded() (+45 more)

### Community 5 - "Input.luau"
Cohesion: 0.14
Nodes (26): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+18 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.12
Nodes (39): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+31 more)

### Community 7 - "Caller.luau"
Cohesion: 0.15
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.07
Nodes (49): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+41 more)

### Community 12 - "Events.luau"
Cohesion: 0.11
Nodes (31): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+23 more)

### Community 13 - "LockOn.luau"
Cohesion: 0.33
Nodes (8): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target()

### Community 15 - "Admin.luau"
Cohesion: 0.11
Nodes (6): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Shop.result()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Server/Tutorial.luau"
Cohesion: 0.21
Nodes (7): complete(), finish(), progress(), setStep(), start(), stop(), Tutorial.start()

### Community 20 - "Platform.mode"
Cohesion: 0.30
Nodes (13): liftHint(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.label() (+5 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.10
Nodes (21): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+13 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.17
Nodes (22): attach(), clearLine(), detach(), grab(), hand(), Loot.arm(), Loot.drop(), Loot.step() (+14 more)

### Community 23 - "Fury.luau"
Cohesion: 0.14
Nodes (19): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+11 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.16
Nodes (29): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+21 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.26
Nodes (14): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), overlapping(), Ragdoll.breakWalls(), Ragdoll.cutDoor() (+6 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 29 - "Ghost.step"
Cohesion: 0.21
Nodes (25): Furniture.near(), Furniture.smash(), bringBack(), claw(), floorBelow(), Ghost.alive(), Ghost.burn(), Ghost.damage() (+17 more)

### Community 30 - "Grunge.text"
Cohesion: 0.07
Nodes (57): Vip.start(), BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges() (+49 more)

### Community 31 - "TutorialUI.luau"
Cohesion: 0.32
Nodes (12): answer(), button(), closeOffer(), fill(), inTutorial(), keyText(), nextCard(), offer() (+4 more)

### Community 34 - "MapLoader.luau"
Cohesion: 0.22
Nodes (13): Events.despawn(), Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+5 more)

### Community 35 - "TouchControls.luau"
Cohesion: 0.38
Nodes (3): layout(), make(), TC.init()

### Community 36 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.19
Nodes (7): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play()

### Community 37 - "Entrance.luau"
Cohesion: 0.05
Nodes (35): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+27 more)

### Community 39 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 40 - "Bestiary.luau"
Cohesion: 0.27
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (9): grab(), Loading.build(), Loading.hide(), Loading.isShown(), Loading.progress(), Loading.show(), Loading.teleport(), N() (+1 more)

### Community 42 - "Run.luau"
Cohesion: 0.12
Nodes (34): onPlayer(), Inventory.clear(), Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult() (+26 more)

### Community 44 - "Sandbox.luau"
Cohesion: 0.42
Nodes (8): Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 46 - "Sfx.play"
Cohesion: 0.20
Nodes (15): CallerUI.call(), Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse() (+7 more)

### Community 47 - "Furniture.luau"
Cohesion: 0.24
Nodes (11): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+3 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.36
Nodes (11): Platform.menu(), button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave() (+3 more)

### Community 50 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+7 more)

### Community 52 - "Run.payout"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

### Community 54 - "rs_shared_config"
Cohesion: 0.15
Nodes (6): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), Platform.windowOpen(), show()

### Community 56 - "Supplies.luau"
Cohesion: 0.38
Nodes (4): alive(), Supplies.clear(), Supplies.pick(), Supplies.spawn()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Supplies.luau`, `Events.luau`, `Abilities.luau`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `Spectate.init`, `CineKit.luau`, `Admin.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `Grunge.text`, `TutorialUI.luau`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13405797101449277 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08022598870056497 - nodes in this community are weakly interconnected._