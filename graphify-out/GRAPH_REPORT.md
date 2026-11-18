# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 88 files · ~186,204 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1073 nodes · 2963 edges · 46 communities (33 shown, 13 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 680 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e7665b11`
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
- Caller.luau
- CineKit.luau
- Events.luau
- Fx.luau
- script_parent_sfx
- Sfx.at
- Run.luau
- Furniture.luau
- Evolved.luau
- Abilities.luau
- Ghost.luau
- Settings.luau
- Ragdoll.luau
- Charge.luau
- ReviveUI.luau
- Grunge.text
- rs_shared_config
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- AdminPanel.luau
- Entrance.luau
- ReviveUI.luau
- Loading.luau
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
8. `Sfx.at()` - 29 edges
9. `Ghost.step()` - 29 edges
10. `Kit.chunks()` - 25 edges

## Surprising Connections (you probably didn't know these)
- `CallerUI.call()` --calls--> `Sfx.play()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/CallerUI.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Ghost.step()` --calls--> `Fury.windUp()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Fury.luau
- `Ghost.spawn()` --calls--> `Evolved.onSpawn()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Evolved.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau
- `Ghost.hit()` --calls--> `Ragdoll.start()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (46 total, 13 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.32
Nodes (15): Furniture.near(), Furniture.smash(), Ghost.damage(), Ghost.hit(), stepKnocked(), stepLaunched(), barrage(), fling() (+7 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.09
Nodes (22): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+14 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.05
Nodes (20): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), liftHint(), firstButton(), fit(), navStep() (+12 more)

### Community 4 - "Data.luau"
Cohesion: 0.06
Nodes (61): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Bestiary.check(), Bestiary.record(), Bestiary.setup() (+53 more)

### Community 5 - "Input.luau"
Cohesion: 0.19
Nodes (19): Charge.active(), Charge.key(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+11 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.21
Nodes (26): Ghost.burn(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+18 more)

### Community 7 - "Caller.luau"
Cohesion: 0.14
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Fx.luau"
Cohesion: 0.13
Nodes (4): Fx.applyZone(), Fx.init(), Settings.group(), make()

### Community 15 - "script_parent_sfx"
Cohesion: 0.13
Nodes (6): CallerUI.call(), Platform.menu(), build(), Prompts.init(), Shop.open(), Shop.result()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.06
Nodes (59): onPlayer(), Combat.healAll(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Inventory.clearWorld() (+51 more)

### Community 20 - "Furniture.luau"
Cohesion: 0.27
Nodes (10): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.nearest(), Furniture.release() (+2 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (56): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+48 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.12
Nodes (29): Abilities.clear(), Evolved.interrupt(), bringBack(), claw(), die(), floorBelow(), Ghost.despawn(), Ghost.freeze() (+21 more)

### Community 24 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+7 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.27
Nodes (12): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.restoreWalls() (+4 more)

### Community 26 - "Charge.luau"
Cohesion: 0.48
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 27 - "ReviveUI.luau"
Cohesion: 0.62
Nodes (6): productId(), ReviveUI.buy(), ReviveUI.canRevive(), ReviveUI.handle(), ReviveUI.init(), ReviveUI.label()

### Community 30 - "Grunge.text"
Cohesion: 0.05
Nodes (71): Vip.start(), BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges() (+63 more)

### Community 34 - "rs_shared_config"
Cohesion: 0.19
Nodes (7): checkThrown(), checkThrownPlayers(), Combat.refreshHealth(), Combat.start(), Furniture.weight(), Ghost.alive(), ult()

### Community 35 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.13
Nodes (9): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play(), ease() (+1 more)

### Community 36 - "AdminPanel.luau"
Cohesion: 0.11
Nodes (25): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+17 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 40 - "ReviveUI.luau"
Cohesion: 0.46
Nodes (6): alive(), button(), choose(), Spectate.active(), Spectate.init(), teammates()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (8): grab(), Loading.build(), Loading.hide(), Loading.progress(), Loading.show(), Loading.teleport(), N(), playerGui()

### Community 46 - "Sfx.play"
Cohesion: 0.33
Nodes (12): Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse(), playHit() (+4 more)

### Community 47 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.53
Nodes (8): button(), free(), inSandbox(), leave(), refresh(), UI.init(), UI.setShopOpen(), ultimates()

### Community 51 - "Main.server.luau"
Cohesion: 0.11
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

## Knowledge Gaps
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `Abilities.luau`, `AdminPanel.luau`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Should `MonsterFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08901515151515152 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.0531986531986532 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Input.luau`, `Entrance.luau`, `CineKit.luau`, `ReviveUI.luau`, `Fx.luau`, `script_parent_sfx`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `Charge.luau`, `ReviveUI.luau`, `Grunge.text`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05524537173082574 - nodes in this community are weakly interconnected._
- **Should `Caller.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.14492753623188406 - nodes in this community are weakly interconnected._