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
Each script replaces what it built before.
The PS2 textures are MaterialVariants in MaterialService.AssistantMaterials (made with Studio's generate_material).
