# World builders (Edit-mode Luau)

These scripts built the PS2-style mansion, lighting, furniture, ghost rig, plane and pilot in Studio.
They are a backup: Studio is still the source of truth. Each one needs `lib2.luau` (helpers + PS2 materials) prepended:

```bash
cat tools/build/lib2.luau tools/build/mansion.luau > /tmp/run.luau && python3 tools/studio.py luau Edit /tmp/run.luau
```

Order: `mansion` (walls, floors, stairs, roof, porch) -> `lights` (Lighting + fixtures) -> `furn_lib` + `furn_place`
(prepend both: `cat lib2 furn_lib furn_place`) -> `ghost` (ServerStorage.GhostTemplate) -> `plane`
(ReplicatedStorage.PlaneModel, ServerStorage.MerchantTemplate) -> `stand` (ServerStorage.StandTemplate + PilotLying)
-> `lobby` (PS2 park at z = 1000 with 8 queue rooms and the ultimate dealer; needs ServerStorage.LobbyAssets, the AI meshes).
-> `events_models` (ReplicatedStorage.EventModels: Van, TrainLoco, TrainWagon, TrainShopWagon)
-> `grounds` (dark forest, yard walls/fence, railway; needs LobbyAssets.PineTree + DeadTreeA).
Each script replaces what it built before.
The PS2 textures are MaterialVariants in MaterialService.AssistantMaterials (made with Studio's generate_material).
-> `maplib` + `maps/<id>.luau` (the 10 extra maps into ServerStorage.Maps.<id>; prepend `lib2 furn_lib maplib`:
   `cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/hospital.luau`).
   The Mansion itself becomes ServerStorage.Maps.Mansion at server start (MapLoader.init).
-> `monster_extras` (weapons, glows, fire, particles on ServerStorage.Monsters.*, after the AI monsters are made).
-> `lobby_forest` (after `lobby`: dark forest clearing, AI trees from LobbyAssets.ForestTree1..3, SHOP booth, QUEST board).
-> `lobby_remake` (after `lobby_forest`, standalone): replaces the AI trees with hand-built low-poly pines / oaks / dead trees,
   each queue room's AI shed with a hand-built log cabin, and brightens the clearing (fill lights, lamp posts, ground).
   The lobby's Lighting preset itself is PRESETS.lobby in Client/Fx.luau.
-> `maps/furnish.luau` (prepend `lib2 furn_lib maplib`: extra furniture + detail in every map but the Mansion/Factory;
   one map only: prepend a line `ONLY = "<MapId>"`).
-> `maps/detail.luau` (LAST, on every map incl. the Mansion; prepend a `local TARGET = "<MapId>"` line + `lib2 furn_lib`):
   the detail + fun pass: baseboards / crown trim and themed things on every inside wall (they break with the wall),
   ceiling beams, floor clutter, facade details (downpipes, chimneys or roof vents, ivy or rust, wall lamps), extra
   throwable props and 5 red EXPLOSIVE BARRELS per map (Furniture attribute Explosive; Config.Barrel, UltRunner.barrel).
   Everything it makes has the attribute Detail = true and is replaced when it is re-run.
-> `maps/stairs.luau` (the STAIR PASS, after any map build; prepend a `local TARGET = "<MapId>"` or `"ALL"` line + `lib2 furn_lib maplib`):
   replaces each map's staircase with one from the stair kit in `maplib` (solid steps with nosings, guards with end posts on
   every open side, a handrail on the wall sides, guards round the opening upstairs). Hospital / School / Prison / Factory /
   Funeral / Farm get a half-turn stair in its own well, the Hotel a straight grand stair with a landing, the Ship's plank
   companionways are only dressed (nosings + balustrades). The map files still build the old plain flight: always run this
   after them. The Asylum (`maps/asylum.luau`) builds its own stair with the kit. Wells are ~15.5 x 23.5 on purpose: the
   monster's pathfinding (agent radius 2.2) needs ~6 clear studs on the flights, at the top and round the landing's post.
-> `maps/doors_clear.luau` (standalone, LAST): removes furniture the random passes left standing in a door opening
   (explosive barrels are moved aside). `furnish` and `detail` now skip doorways, stairs and the map's `KeepClear` parts
   (maplib `keepClear(x1, z1, x2, z2, floorY)`: corridors, gallery walks, the foot of a stair) themselves.
-> `maps/facade_fix.luau` (standalone, one-off, already run): pushed the detail pass's ivy / rust patches flush onto the
   outside walls and removed the ones that hung across doorways and windows; `detail` now places them that way itself.
-> `demon`, `animatronic`, `titan` (hand-built part monsters: ServerStorage.Monsters.Demon / .Animatronic = The Party Bear / .Titan = The Flayed Giant;
   standalone, no lib2 needed: `python3 tools/studio.py luau Edit tools/build/animatronic.luau`).

Monsters (ServerStorage.Monsters.<id>) and item meshes (ReplicatedStorage.ItemMeshes.<ItemId>) are AI-made in Studio:
`generate_mesh` (T-pose prompt for monsters) -> `auto_setup_avatar` (Development) -> AnimationConstraints converted to
Motor6Ds with the R15 joint names the GhostAnim code drives. Items: `generate_mesh` upright, pivot moved to the grip,
rotated so the item points toward -Z.

