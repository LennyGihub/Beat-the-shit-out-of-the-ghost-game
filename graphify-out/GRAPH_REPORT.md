# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 97 files · ~202,749 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1147 nodes · 3156 edges · 57 communities (41 shown, 16 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 716 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7924d5ce`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- MonsterFx.luau
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
- Server/Tutorial.luau
- Platform.mode
- Evolved.luau
- Abilities.luau
- rs_shared_config
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- AdminPanel.luau
- Ghost.step
- Grunge.text
- script_parent_ragdoll
- Main.server.luau
- MapLoader.luau
- TouchControls.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- Entrance.luau
- Mobile.luau
- Spectate.init
- Loading.luau
- Run.luau
- Sandbox.luau
- Sfx.play
- TutorialUI.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- Settings.luau
- game_getservice
- Run.payout
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
10. `Grunge.text()` - 28 edges

## Surprising Connections (you probably didn't know these)
- `UI.init()` --calls--> `Loading.isShown()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TutorialUI.luau → game/ReplicatedFirst/Loading.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `setState()` --calls--> `Evolved.interrupt()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `stepKnocked()` --calls--> `Furniture.weight()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Furniture.luau
- `TC.init()` --calls--> `LockOn.isOn()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TouchControls.luau → game/StarterPlayer/StarterPlayerScripts/Client/LockOn.luau

## Import Cycles
- None detected.

## Communities (57 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.16
Nodes (26): bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage(), Ghost.despawn(), Ghost.hit() (+18 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.06
Nodes (61): Levels.need(), Levels.of(), Levels.title(), Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings(), Data.addCash() (+53 more)

### Community 5 - "Input.luau"
Cohesion: 0.14
Nodes (26): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+18 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.19
Nodes (29): Ghost.freeze(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode(), get() (+21 more)

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
Cohesion: 0.20
Nodes (5): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Server/Tutorial.luau"
Cohesion: 0.18
Nodes (9): Sandbox.active(), complete(), fightFor(), finish(), progress(), setStep(), start(), stop() (+1 more)

### Community 20 - "Platform.mode"
Cohesion: 0.15
Nodes (20): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), fit(), navStep() (+12 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.10
Nodes (21): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+13 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.13
Nodes (31): Fury.canFling(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch(), Fury.tick(), Fury.unragdollable() (+23 more)

### Community 23 - "rs_shared_config"
Cohesion: 0.09
Nodes (7): CallerUI.call(), Fx.applyZone(), Fx.init(), LevelUI.init(), build(), Prompts.init(), Shop.result()

### Community 24 - "Abilities.luau"
Cohesion: 0.07
Nodes (50): Abilities.blocks(), Abilities.clear(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step() (+42 more)

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
Cohesion: 0.15
Nodes (26): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+18 more)

### Community 30 - "Grunge.text"
Cohesion: 0.08
Nodes (55): BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges(), buildMonsters() (+47 more)

### Community 31 - "script_parent_ragdoll"
Cohesion: 0.50
Nodes (3): KnightDoor.open(), KnightDoor.pick(), spots()

### Community 32 - "Main.server.luau"
Cohesion: 0.11
Nodes (6): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running()

### Community 34 - "MapLoader.luau"
Cohesion: 0.29
Nodes (10): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.randomGhostSpawn() (+2 more)

### Community 35 - "TouchControls.luau"
Cohesion: 0.47
Nodes (3): layout(), make(), TC.init()

### Community 36 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.13
Nodes (9): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play(), ease() (+1 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.05
Nodes (35): bolt(), burst(), C(), chunks(), darkness(), disc(), each(), emitter() (+27 more)

### Community 39 - "Mobile.luau"
Cohesion: 0.39
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

### Community 40 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (9): grab(), Loading.build(), Loading.hide(), Loading.isShown(), Loading.progress(), Loading.show(), Loading.teleport(), N() (+1 more)

### Community 42 - "Run.luau"
Cohesion: 0.12
Nodes (32): Friends.mult(), Inventory.clearWorld(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe() (+24 more)

### Community 44 - "Sandbox.luau"
Cohesion: 0.50
Nodes (8): Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep(), toast()

### Community 46 - "Sfx.play"
Cohesion: 0.33
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+4 more)

### Community 47 - "TutorialUI.luau"
Cohesion: 0.30
Nodes (12): answer(), button(), closeOffer(), fill(), inTutorial(), keyText(), nextCard(), offer() (+4 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+7 more)

### Community 51 - "game_getservice"
Cohesion: 0.28
Nodes (4): Vip.start(), build(), onPlayer(), refresh()

### Community 56 - "Supplies.luau"
Cohesion: 0.21
Nodes (6): alive(), Supplies.pick(), Supplies.spawn(), clear(), selectedId(), step()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Supplies.luau`, `Events.luau`, `Abilities.luau`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12666666666666668 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Entrance.luau`, `Input.luau`, `Fire.luau`, `rs_shared_config`, `Spectate.init`, `TutorialUI.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `rs_shared_config`, `Grunge.text`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06060606060606061 - nodes in this community are weakly interconnected._
- **Why does `Acts.timeStop()` connect `Sfx.at` to `Evolved.luau`, `Sfx.play`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.061458718992965566 - nodes in this community are weakly interconnected._
- **Should `Input.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.14204545454545456 - nodes in this community are weakly interconnected._