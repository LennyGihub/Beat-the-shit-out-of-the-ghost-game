# Pending: the secret monster (The Conqueror) - written while Studio's place was closed

Not in Studio yet, not tested in a playtest. Every file passed `luau-compile`.

To finish (Studio open on the place, Edit mode):
1. Build the model: `python3 tools/studio.py luau Edit tools/build/conqueror.luau` (creates ServerStorage.Monsters.Conqueror).
2. Push the scripts: `python3 tools/deploy_luau.py --root pending/src` (check first that `game/` has not changed
   since: these are whole files based on main at 1808148).
3. Playtest: admin `monster Conqueror` (+ `evolved 1` for the Golden Conqueror), check the warp, the wall punch,
   the smash punch, the beam (walls, furniture, damage), the model in both forms, the console.
4. `tools/save_game.sh "game: secret monster"` and delete this folder.

What it is: `Shared/Monsters` (Conqueror, secret, 3% per ghost after the first; evolved = laser power),
`Server/Abilities` (warp), `Server/Evolved` (laser + DRESS.Conqueror), `Server/Fury` (smasher), `Server/Run`
(secret roll), client `MonsterFx` (portal, beam), `GhostAnim` (poses), `Sfx`, `Fx`, `HUD` (secret tag / colour).
