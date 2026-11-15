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

Monsters (ServerStorage.Monsters.<id>) and item meshes (ReplicatedStorage.ItemMeshes.<ItemId>) are AI-made in Studio:
`generate_mesh` (T-pose prompt for monsters) -> `auto_setup_avatar` (Development) -> AnimationConstraints converted to
Motor6Ds with the R15 joint names the GhostAnim code drives. Items: `generate_mesh` upright, pivot moved to the grip,
rotated so the item points toward -Z.

