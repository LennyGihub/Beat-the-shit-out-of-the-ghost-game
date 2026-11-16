# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 51 files · ~79,123 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 600 nodes · 1643 edges · 23 communities (16 shown, 7 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 250 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `11c0b129`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- Viewmodel.luau
- Ragdoll.luau
- LobbyUI.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Abilities.luau
- Input.luau
- GoblinLoot.luau
- Settings.luau
- SawAudio.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Ghost.step()` - 22 edges
7. `moving()` - 20 edges
8. `Sfx.play()` - 17 edges
9. `Abilities.step()` - 16 edges
10. `Furniture.smash()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `update()` --calls--> `VM.itemTip()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Hotbar.luau → game/StarterPlayer/StarterPlayerScripts/Client/Viewmodel.luau
- `liftHint()` --calls--> `Settings.keyName()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/Settings.luau
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `Ghost.hit()` --calls--> `Ragdoll.kick()`  [INFERRED]
  game/ServerScriptService/Server/Ghost.luau → game/ServerScriptService/Server/Ragdoll.luau

## Import Cycles
- None detected.

## Communities (23 total, 7 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.05
Nodes (89): Abilities.clear(), checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.playerNear(), Combat.refreshHealth(), Combat.start(), burningNear() (+81 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.11
Nodes (29): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), HUD.flash(), disc() (+21 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (55): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+47 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.36
Nodes (6): abilityPose(), bind(), GA.update(), goblinClaw(), target(), walkPose()

### Community 4 - "Data.luau"
Cohesion: 0.16
Nodes (31): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.load(), Data.own(), Data.owns() (+23 more)

### Community 5 - "Viewmodel.luau"
Cohesion: 0.16
Nodes (17): addTrail(), ease(), itemOffset(), mirror(), mk(), punchOffset(), sample(), solveHold() (+9 more)

### Community 6 - "Ragdoll.luau"
Cohesion: 0.33
Nodes (10): breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.restoreWalls(), Ragdoll.start() (+2 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.05
Nodes (51): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), Hotbar.current() (+43 more)

### Community 12 - "Events.luau"
Cohesion: 0.17
Nodes (20): ItemModels.build(), ItemModels.isLong(), anchorAll(), burn(), Events.prompt(), Events.rollStock(), Events.spawn(), fx() (+12 more)

### Community 13 - "Run.luau"
Cohesion: 0.06
Nodes (45): onPlayer(), Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), Events.despawn(), areFriends() (+37 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.27
Nodes (13): build(), button(), cmd(), corner(), grid(), heading(), label(), log() (+5 more)

### Community 18 - "Abilities.luau"
Cohesion: 0.27
Nodes (17): Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale(), finish() (+9 more)

### Community 19 - "Input.luau"
Cohesion: 0.07
Nodes (33): Fx.applyZone(), Fx.init(), Hotbar.cycle(), Hotbar.drop(), HUD.hint(), HUD.toast(), HUD.update(), layoutBars() (+25 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (21): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.drop() (+13 more)

### Community 21 - "Settings.luau"
Cohesion: 0.33
Nodes (8): apply(), load(), save(), Settings.bind(), Settings.init(), Settings.keyName(), Settings.reset(), Settings.set()

### Community 22 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

## Knowledge Gaps
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `Events.luau` to `ItemModels.luau`, `GoblinLoot.luau`, `Viewmodel.luau`?**
  _High betweenness centrality (0.137) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05070958809276566 - nodes in this community are weakly interconnected._
- **Why does `p()` connect `ItemModels.luau` to `Events.luau`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.112375533428165 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Viewmodel.luau` to `Events.luau`, `LobbyUI.luau`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05387861084063616 - nodes in this community are weakly interconnected._
- **Should `Run.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.05555555555555555 - nodes in this community are weakly interconnected._