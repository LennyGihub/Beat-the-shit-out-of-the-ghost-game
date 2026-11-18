# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 93 files · ~197,308 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1123 nodes · 3095 edges · 57 communities (41 shown, 16 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 701 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0b6606d8`
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
- Run.startFight
- Platform.mode
- Evolved.luau
- Abilities.luau
- Ghost.step
- Abilities.luau
- Ragdoll.luau
- CallerMarks.luau
- AdminPanel.luau
- UltRunner.luau
- Grunge.text
- TutorialUI.luau
- script_parent_sfx
- MapLoader.luau
- TouchControls.luau
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- Entrance.luau
- Spectate.init
- onPlayer
- Loading.luau
- Run.luau
- Sandbox.luau
- Sfx.play
- Furniture.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- Settings.luau
- Run.payout
- script_parent_remotes
- rs_shared_config
- Supplies.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `Sfx.play()` - 41 edges
6. `worn()` - 40 edges
7. `Kit.ring()` - 31 edges
8. `Sfx.at()` - 30 edges
9. `Ghost.step()` - 30 edges
10. `Grunge.text()` - 27 edges

## Surprising Connections (you probably didn't know these)
- `ringPhone()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `maskBreath()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Entrance.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `TC.init()` --calls--> `LockOn.isOn()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TouchControls.luau → game/StarterPlayer/StarterPlayerScripts/Client/LockOn.luau
- `TC.init()` --calls--> `LockOn.tracking()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TouchControls.luau → game/StarterPlayer/StarterPlayerScripts/Client/LockOn.luau

## Import Cycles
- None detected.

## Communities (57 total, 16 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.13
Nodes (23): Abilities.clear(), Evolved.interrupt(), Evolved.onSpawn(), die(), Ghost.despawn(), Ghost.freeze(), Ghost.launch(), Ghost.shove() (+15 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.13
Nodes (16): beamOff(), beamTo(), blackout(), bladeSwoosh(), disc(), emitter(), forceRing(), hum() (+8 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.07
Nodes (57): Bestiary.check(), Bestiary.record(), Bestiary.setup(), cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get() (+49 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (20): Charge.active(), Charge.key(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+12 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.05
Nodes (53): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+45 more)

### Community 7 - "Caller.luau"
Cohesion: 0.14
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 8 - "CineKit.luau"
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

### Community 19 - "Run.startFight"
Cohesion: 0.38
Nodes (10): Inventory.clearWorld(), clearTemp(), doorPrompt(), onGhostDeath(), Run.endMatch(), Run.startFight(), setState(), setWaypoint() (+2 more)

### Community 20 - "Platform.mode"
Cohesion: 0.15
Nodes (19): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), fit(), navStep() (+11 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (19): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+11 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.21
Nodes (22): Fury.canFling(), attach(), clearLine(), detach(), grab(), hand(), knockVel(), Loot.arm() (+14 more)

### Community 23 - "Ghost.step"
Cohesion: 0.18
Nodes (19): Furniture.near(), Furniture.smash(), Furniture.weight(), Fury.comboCount(), Fury.flung(), Fury.launch(), Fury.smashes(), Fury.smashPunch() (+11 more)

### Community 24 - "Abilities.luau"
Cohesion: 0.17
Nodes (27): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+19 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 27 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 29 - "UltRunner.luau"
Cohesion: 0.31
Nodes (13): Ghost.damage(), Ghost.hit(), Ghost.setVortex(), Ghost.slow(), barrage(), fling(), ghostPos(), Runner.barrel() (+5 more)

### Community 30 - "Grunge.text"
Cohesion: 0.06
Nodes (66): Vip.start(), BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges() (+58 more)

### Community 31 - "TutorialUI.luau"
Cohesion: 0.32
Nodes (12): answer(), button(), closeOffer(), fill(), inTutorial(), keyText(), nextCard(), offer() (+4 more)

### Community 32 - "script_parent_sfx"
Cohesion: 0.14
Nodes (4): CallerUI.call(), build(), Prompts.init(), Shop.result()

### Community 34 - "MapLoader.luau"
Cohesion: 0.24
Nodes (11): Furniture.recapture(), bringBack(), folder(), MapLoader.exists(), MapLoader.ghostSpawns(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load() (+3 more)

### Community 35 - "TouchControls.luau"
Cohesion: 0.38
Nodes (3): layout(), make(), TC.init()

### Community 36 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.13
Nodes (9): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play(), ease() (+1 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.05
Nodes (35): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+27 more)

### Community 39 - "Spectate.init"
Cohesion: 0.27
Nodes (12): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label(), alive(), button() (+4 more)

### Community 40 - "onPlayer"
Cohesion: 0.50
Nodes (5): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (9): grab(), Loading.build(), Loading.hide(), Loading.isShown(), Loading.progress(), Loading.show(), Loading.teleport(), N() (+1 more)

### Community 42 - "Run.luau"
Cohesion: 0.14
Nodes (22): Friends.mult(), Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), endDeath() (+14 more)

### Community 44 - "Sandbox.luau"
Cohesion: 0.38
Nodes (9): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 46 - "Sfx.play"
Cohesion: 0.33
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+4 more)

### Community 47 - "Furniture.luau"
Cohesion: 0.27
Nodes (10): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+2 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.36
Nodes (11): Platform.menu(), button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave() (+3 more)

### Community 50 - "Settings.luau"
Cohesion: 0.07
Nodes (33): Fx.applyZone(), Fx.init(), KeyHints.init(), refresh(), toggle(), bladeIgnite(), oneShot(), SawAudio.attach() (+25 more)

### Community 53 - "script_parent_remotes"
Cohesion: 0.43
Nodes (5): face(), Knight.interrupt(), Knight.step(), Knight.try(), sees()

### Community 54 - "rs_shared_config"
Cohesion: 0.33
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 56 - "Supplies.luau"
Cohesion: 0.38
Nodes (4): alive(), Supplies.clear(), Supplies.pick(), Supplies.spawn()

## Knowledge Gaps
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Sfx.play()` connect `Sfx.play` to `script_parent_sfx`, `MonsterFx.luau`, `Input.luau`, `Entrance.luau`, `Spectate.init`, `CineKit.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Settings.luau`, `Sfx.at`, `rs_shared_config`, `Grunge.text`, `TutorialUI.luau`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Are the 39 inferred relationships involving `Sfx.play()` (e.g. with `BestiaryUI.discovered()` and `BestiaryUI.init()`) actually correct?**
  _`Sfx.play()` has 39 INFERRED edges - model-reasoned connections that need verification._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12615384615384614 - nodes in this community are weakly interconnected._
- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Supplies.luau`, `Settings.luau`, `Events.luau`, `Abilities.luau`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.13405797101449277 - nodes in this community are weakly interconnected._
- **Why does `Acts.timeStop()` connect `Sfx.at` to `Evolved.luau`, `Sfx.play`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._