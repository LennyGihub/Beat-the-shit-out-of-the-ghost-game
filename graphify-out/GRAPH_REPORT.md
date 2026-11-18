# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-18)

## Corpus Check
- 91 files · ~190,090 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 1102 nodes · 3047 edges · 60 communities (45 shown, 15 thin omitted)
- Extraction: 77% EXTRACTED · 23% INFERRED · 0% AMBIGUOUS · INFERRED: 696 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c6d5fe92`
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
- Settings.luau
- Ragdoll.luau
- Charge.luau
- LockOn.luau
- QuestUI.luau
- Grunge.text
- TutorialUI.luau
- script_parent_platform
- rs_shared_config
- game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau
- AdminPanel.luau
- Entrance.luau
- Sandbox.luau
- Bestiary.luau
- Loading.luau
- MapLoader.luau
- Run.startFight
- Sfx.play
- Fire.luau
- RoomPickUI.luau
- game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau
- SawAudio.luau
- Main.server.luau
- script_parent_remotes
- rs_shared_items
- onPlayer
- CallerMarks.luau
- Friends.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 50 edges
2. `V()` - 47 edges
3. `at()` - 46 edges
4. `mark()` - 45 edges
5. `worn()` - 40 edges
6. `Sfx.play()` - 40 edges
7. `Kit.ring()` - 31 edges
8. `Sfx.at()` - 29 edges
9. `Ghost.step()` - 29 edges
10. `Grunge.text()` - 27 edges

## Surprising Connections (you probably didn't know these)
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `layoutBars()` --calls--> `Platform.mode()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau → game/StarterPlayer/StarterPlayerScripts/Client/Platform.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `UI.init()` --calls--> `Loading.isShown()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/TutorialUI.luau → game/ReplicatedFirst/Loading.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (60 total, 15 thin omitted)

### Community 0 - "Furniture.smash"
Cohesion: 0.17
Nodes (24): placeHint(), Furniture.conjure(), Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest() (+16 more)

### Community 1 - "MonsterFx.luau"
Cohesion: 0.18
Nodes (11): beamOff(), beamTo(), blackout(), disc(), emitter(), jumpscare(), lightsOut(), near() (+3 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (57): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+49 more)

### Community 4 - "Data.luau"
Cohesion: 0.08
Nodes (53): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.loaded() (+45 more)

### Community 5 - "Input.luau"
Cohesion: 0.18
Nodes (20): Charge.active(), Charge.key(), Hotbar.drop(), aimedFurniture(), allPrompts(), bindAll(), chargeable(), grab() (+12 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.19
Nodes (29): Ghost.freeze(), Ghost.timeStop(), Ghost.vuln(), alive(), applyFx(), consume(), explode(), get() (+21 more)

### Community 7 - "Caller.luau"
Cohesion: 0.15
Nodes (17): answer(), buildPhone(), Caller.clear(), Caller.interrupt(), Caller.step(), Caller.try(), cleanup(), hideSpot() (+9 more)

### Community 8 - "CineKit.luau"
Cohesion: 0.15
Nodes (29): Config.eventTime(), base(), Kit.boom(), Kit.burst(), Kit.debris(), Kit.dust(), Kit.emitter(), Kit.flat() (+21 more)

### Community 12 - "Events.luau"
Cohesion: 0.22
Nodes (26): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), board(), burn(), Events.prompt(), Events.restock() (+18 more)

### Community 13 - "Fx.luau"
Cohesion: 0.18
Nodes (4): Fx.applyZone(), Fx.init(), Settings.group(), make()

### Community 15 - "Admin.luau"
Cohesion: 0.11
Nodes (6): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Shop.result()

### Community 18 - "Sfx.at"
Cohesion: 0.12
Nodes (70): Kit.near(), HUD.banner(), HUD.flash(), Sfx.at(), Acts.burn(), Acts.fling(), Acts.freeze(), Acts.giant() (+62 more)

### Community 19 - "Run.luau"
Cohesion: 0.14
Nodes (20): Lobby.returnPlayer(), Monetization.start(), aliveCount(), aliveIn(), cashMult(), checkWipe(), endDeath(), hrpOf() (+12 more)

### Community 20 - "Platform.mode"
Cohesion: 0.26
Nodes (15): liftHint(), firstButton(), fit(), navStep(), openMenu(), Platform.compact(), Platform.init(), Platform.label() (+7 more)

### Community 21 - "Evolved.luau"
Cohesion: 0.11
Nodes (20): Abilities.cloneCount(), display(), add(), begin(), cd(), close(), done(), Evolved.chase() (+12 more)

### Community 22 - "Abilities.luau"
Cohesion: 0.08
Nodes (57): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.hurl(), Abilities.interrupt(), Abilities.spawnClones(), Abilities.step(), Abilities.tick() (+49 more)

### Community 23 - "Ghost.luau"
Cohesion: 0.12
Nodes (31): Abilities.clear(), Evolved.onSpawn(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.despawn() (+23 more)

### Community 24 - "Settings.luau"
Cohesion: 0.22
Nodes (15): KeyHints.init(), refresh(), toggle(), apply(), load(), save(), Settings.bind(), Settings.fxScale() (+7 more)

### Community 25 - "Ragdoll.luau"
Cohesion: 0.30
Nodes (11): breakable(), carve(), chunkFolder(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+3 more)

### Community 26 - "Charge.luau"
Cohesion: 0.29
Nodes (6): build(), Charge.begin(), Charge.cancel(), Charge.level(), Charge.release(), Charge.update()

### Community 27 - "LockOn.luau"
Cohesion: 0.18
Nodes (11): isDecoy(), LockOn.init(), LockOn.isOn(), LockOn.set(), LockOn.toggle(), LockOn.tracking(), step(), target() (+3 more)

### Community 29 - "QuestUI.luau"
Cohesion: 0.28
Nodes (11): Platform.menu(), button(), data(), fillRow(), makeRow(), QuestUI.claimable(), QuestUI.close(), QuestUI.init() (+3 more)

### Community 30 - "Grunge.text"
Cohesion: 0.06
Nodes (62): Vip.start(), BestiaryUI.close(), BestiaryUI.discovered(), BestiaryUI.init(), BestiaryUI.open(), BestiaryUI.unlocked(), book(), buildBadges() (+54 more)

### Community 31 - "TutorialUI.luau"
Cohesion: 0.35
Nodes (11): answer(), button(), closeOffer(), fill(), inTutorial(), nextCard(), offer(), refresh() (+3 more)

### Community 32 - "script_parent_platform"
Cohesion: 0.20
Nodes (6): HUD.hint(), HUD.update(), layoutBars(), updateWaypoint(), Platform.windowOpen(), show()

### Community 34 - "rs_shared_config"
Cohesion: 0.19
Nodes (6): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Furniture.weight()

### Community 35 - "game/StarterPlayer/StarterPlayerScripts/Client/UltPose.luau"
Cohesion: 0.13
Nodes (9): add(), CrewAnim.init(), Kit.now(), apply(), joint(), Pose.init(), Pose.play(), ease() (+1 more)

### Community 36 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 37 - "Entrance.luau"
Cohesion: 0.06
Nodes (32): bolt(), burst(), chunks(), darkness(), disc(), each(), emitter(), Entrance.play() (+24 more)

### Community 39 - "Sandbox.luau"
Cohesion: 0.38
Nodes (9): MapLoader.spawnInside(), Run.setSandbox(), center(), enter(), leave(), Sandbox.start(), spawnDummy(), sweep() (+1 more)

### Community 40 - "Bestiary.luau"
Cohesion: 0.27
Nodes (4): Bestiary.check(), Bestiary.record(), Bestiary.setup(), Data.refresh()

### Community 41 - "Loading.luau"
Cohesion: 0.35
Nodes (9): grab(), Loading.build(), Loading.hide(), Loading.isShown(), Loading.progress(), Loading.show(), Loading.teleport(), N() (+1 more)

### Community 42 - "MapLoader.luau"
Cohesion: 0.33
Nodes (7): Furniture.recapture(), folder(), MapLoader.exists(), MapLoader.hookRescue(), MapLoader.init(), MapLoader.load(), MapLoader.setSea()

### Community 44 - "Run.startFight"
Cohesion: 0.38
Nodes (10): Inventory.clearWorld(), clearTemp(), doorPrompt(), onGhostDeath(), Run.endMatch(), Run.startFight(), setState(), setWaypoint() (+2 more)

### Community 46 - "Sfx.play"
Cohesion: 0.25
Nodes (13): CallerUI.call(), Hotbar.confirmHit(), Hotbar.current(), Hotbar.cycle(), Hotbar.init(), Hotbar.primary(), Hotbar.select(), parse() (+5 more)

### Community 47 - "Fire.luau"
Cohesion: 0.23
Nodes (14): burningNear(), closestPoint(), Fire.blood(), Fire.clear(), Fire.flames(), Fire.ignite(), Fire.wildfire(), seq() (+6 more)

### Community 48 - "RoomPickUI.luau"
Cohesion: 0.40
Nodes (9): arrow(), cycleDiff(), cycleMap(), isLeader(), ownedMaps(), refresh(), roomModel(), send() (+1 more)

### Community 49 - "game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau"
Cohesion: 0.49
Nodes (9): button(), free(), inSandbox(), inTutorial(), refresh(), UI.init(), UI.leave(), UI.setShopOpen() (+1 more)

### Community 50 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 51 - "Main.server.luau"
Cohesion: 0.12
Nodes (7): complete(), finish(), progress(), setStep(), start(), stop(), Tutorial.start()

### Community 52 - "script_parent_remotes"
Cohesion: 0.39
Nodes (5): Mobile.cone(), Mobile.ease(), Mobile.is(), Mobile.liftRange(), Mobile.share()

### Community 53 - "rs_shared_items"
Cohesion: 0.32
Nodes (3): clear(), selectedId(), step()

### Community 54 - "onPlayer"
Cohesion: 0.40
Nodes (6): onPlayer(), Events.despawn(), Run.addToMatch(), Run.beginMatch(), Run.configure(), Run.running()

### Community 56 - "CallerMarks.luau"
Cohesion: 0.53
Nodes (5): buildArrow(), Marks.init(), Marks.roomOff(), setPhone(), step()

### Community 57 - "Friends.luau"
Cohesion: 0.50
Nodes (3): areFriends(), Friends.mult(), refresh()

## Knowledge Gaps
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Events.luau`, `rs_shared_items`, `Abilities.luau`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.06060606060606061 - nodes in this community are weakly interconnected._
- **Why does `stock()` connect `Events.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08022598870056497 - nodes in this community are weakly interconnected._
- **Why does `Sfx.play()` connect `Sfx.play` to `MonsterFx.luau`, `Input.luau`, `Entrance.luau`, `CineKit.luau`, `Fx.luau`, `Admin.luau`, `RoomPickUI.luau`, `game/StarterPlayer/StarterPlayerScripts/Client/SandboxUI.luau`, `Sfx.at`, `Charge.luau`, `QuestUI.luau`, `Grunge.text`, `TutorialUI.luau`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Should `Admin.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.11231884057971014 - nodes in this community are weakly interconnected._
- **Should `Sfx.at` be split into smaller, more focused modules?**
  _Cohesion score 0.12203829925348912 - nodes in this community are weakly interconnected._