# Graph Report - Beat-the-shit-out-of-the-ghost-game  (2026-11-16)

## Corpus Check
- 56 files · ~93,468 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 3 file(s) not represented in the graph (top: (none) 3)

## Summary
- 684 nodes · 1851 edges · 27 communities (19 shown, 8 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 0% AMBIGUOUS · INFERRED: 291 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `41e8e02a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Ghost.luau
- UltFx.luau
- ItemModels.luau
- ClientMain.client.luau
- Data.luau
- SawAudio.luau
- Inventory.luau
- LobbyUI.luau
- Events.luau
- Run.luau
- AdminPanel.luau
- Input.luau
- HUD.luau
- GoblinLoot.luau
- Combat.luau
- Furniture.smash
- Abilities.luau
- Fire.luau
- Ragdoll.luau

## God Nodes (most connected - your core abstractions)
1. `p()` - 49 edges
2. `V()` - 46 edges
3. `at()` - 45 edges
4. `mark()` - 44 edges
5. `worn()` - 39 edges
6. `Sfx.play()` - 23 edges
7. `Ghost.step()` - 22 edges
8. `moving()` - 20 edges
9. `Input.init()` - 19 edges
10. `Abilities.step()` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Combat.refreshHealth()` --calls--> `alive()`  [INFERRED]
  game/ServerScriptService/Server/Combat.luau → game/ServerScriptService/Server/Inventory.luau
- `applyFx()` --calls--> `Ghost.vuln()`  [INFERRED]
  game/ServerScriptService/Server/Inventory.luau → game/ServerScriptService/Server/Ghost.luau
- `PlaneFx.impact()` --calls--> `Sfx.at()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/PlaneFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/Sfx.luau
- `MonsterFx.handle()` --calls--> `HUD.toast()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/MonsterFx.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau
- `Input.init()` --calls--> `HUD.hint()`  [INFERRED]
  game/StarterPlayer/StarterPlayerScripts/Client/Input.luau → game/StarterPlayer/StarterPlayerScripts/Client/HUD.luau

## Import Cycles
- None detected.

## Communities (27 total, 8 thin omitted)

### Community 0 - "Ghost.luau"
Cohesion: 0.12
Nodes (29): Abilities.clear(), Fire.clear(), bringBack(), claw(), die(), floorBelow(), Ghost.alive(), Ghost.damage() (+21 more)

### Community 1 - "UltFx.luau"
Cohesion: 0.10
Nodes (39): boom(), clone(), EventFx.handle(), EventFx.train(), EventFx.van(), watch(), Hotbar.cycle(), HUD.banner() (+31 more)

### Community 2 - "ItemModels.luau"
Cohesion: 0.19
Nodes (56): at(), B.axe(), B.ball(), B.bat(), B.beartrap(), B.blower(), B.bottle(), B.brick() (+48 more)

### Community 3 - "ClientMain.client.luau"
Cohesion: 0.08
Nodes (9): abilityPose(), addJoint(), bind(), GA.update(), goblinClaw(), makeSwirl(), pirateSlash(), target() (+1 more)

### Community 4 - "Data.luau"
Cohesion: 0.09
Nodes (41): cleanSettings(), Data.addCash(), Data.equipped(), Data.equipUlt(), Data.get(), Data.grantCashReceipt(), Data.load(), Data.own() (+33 more)

### Community 5 - "SawAudio.luau"
Cohesion: 0.40
Nodes (9): oneShot(), SawAudio.attach(), SawAudio.hit(), SawAudio.init(), SawAudio.used(), selectedId(), sound(), step() (+1 more)

### Community 6 - "Inventory.luau"
Cohesion: 0.22
Nodes (25): Ghost.burn(), alive(), applyFx(), consume(), explode(), get(), ghostAlive(), Inventory.clear() (+17 more)

### Community 7 - "LobbyUI.luau"
Cohesion: 0.06
Nodes (53): frame(), Grunge.bar(), Grunge.panel(), Grunge.splat(), Grunge.text(), sketch(), stroke(), bigButton() (+45 more)

### Community 12 - "Events.luau"
Cohesion: 0.15
Nodes (25): ItemModels.isLong(), anchorAll(), blocked(), blockerParams(), burn(), Events.prompt(), Events.rollStock(), Events.spawn() (+17 more)

### Community 13 - "Run.luau"
Cohesion: 0.08
Nodes (50): onPlayer(), Events.despawn(), areFriends(), Friends.mult(), refresh(), Furniture.recapture(), Inventory.clearWorld(), Lobby.returnPlayer() (+42 more)

### Community 15 - "AdminPanel.luau"
Cohesion: 0.07
Nodes (25): Admin.run(), Admin.start(), isAdmin(), isFullAdmin(), passId(), build(), button(), cmd() (+17 more)

### Community 18 - "Input.luau"
Cohesion: 0.06
Nodes (56): build(), Charge.active(), Charge.begin(), Charge.cancel(), Charge.key(), Charge.level(), Charge.release(), Charge.update() (+48 more)

### Community 19 - "HUD.luau"
Cohesion: 0.16
Nodes (19): HUD.update(), layoutBars(), liftHint(), firstButton(), navStep(), openMenu(), Platform.init(), Platform.label() (+11 more)

### Community 20 - "GoblinLoot.luau"
Cohesion: 0.22
Nodes (21): attach(), clearLine(), detach(), grab(), hand(), knockVel(), land(), Loot.drop() (+13 more)

### Community 21 - "Combat.luau"
Cohesion: 0.19
Nodes (6): checkThrown(), checkThrownPlayers(), Combat.healAll(), Combat.refreshHealth(), Combat.start(), Furniture.weight()

### Community 22 - "Furniture.smash"
Cohesion: 0.21
Nodes (19): Furniture.flingAt(), Furniture.folder(), Furniture.grab(), Furniture.isValid(), Furniture.near(), Furniture.nearest(), Furniture.release(), Furniture.reset() (+11 more)

### Community 23 - "Abilities.luau"
Cohesion: 0.26
Nodes (18): Abilities.blocks(), Abilities.dropLevitated(), Abilities.hitClone(), Abilities.interrupt(), Abilities.step(), Abilities.tick(), Abilities.try(), dmgScale() (+10 more)

### Community 24 - "Fire.luau"
Cohesion: 0.39
Nodes (7): burningNear(), closestPoint(), Fire.flames(), Fire.ignite(), seq(), start(), woodParts()

### Community 25 - "Ragdoll.luau"
Cohesion: 0.35
Nodes (10): Ghost.hit(), breakable(), carve(), chunks(), freezeLater(), Ragdoll.breakWalls(), Ragdoll.kick(), Ragdoll.start() (+2 more)

## Knowledge Gaps
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ItemModels.build()` connect `ItemModels.luau` to `Input.luau`, `Events.luau`, `GoblinLoot.luau`?**
  _High betweenness centrality (0.119) - this node is a cross-community bridge._
- **Should `Ghost.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.12121212121212122 - nodes in this community are weakly interconnected._
- **Why does `VM.setItem()` connect `Input.luau` to `ItemModels.luau`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Should `UltFx.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.09620721554116558 - nodes in this community are weakly interconnected._
- **Should `ClientMain.client.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.07575757575757576 - nodes in this community are weakly interconnected._
- **Should `Data.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.08708272859216255 - nodes in this community are weakly interconnected._
- **Should `LobbyUI.luau` be split into smaller, more focused modules?**
  _Cohesion score 0.061569416498993966 - nodes in this community are weakly interconnected._