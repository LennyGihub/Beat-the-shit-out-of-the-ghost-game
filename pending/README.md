# Pending: written but NOT yet in Studio

The Studio bridge was down when this was written, so these scripts were syntax-checked (`luau-compile`) but never
pushed to Studio or playtested. `src/` has the same layout as `game/` and holds only the changed files.

What it is:
- **Taser**: its own shot sound and, on a monster, an electric crackle with blue arcs for the length of the stun
  (Inventory fires Fx "Tased"; Client/Fx plays it; Sounds.TaserZap / TaserTick).
- **Flamethrower**: a hissing roar while the trigger is held (Client/Hotbar; Sounds.Flamethrower) and a WILDFIRE
  (Server/Fire `Fire.wildfire`, Config.Wildfire): what it hits keeps spreading through the whole house (floors, up
  walls, through walls, up a floor), burns only the monster, with a roar and a warm glow that grow with it (Client/Fx,
  ReplicatedStorage attribute WildFires) and a "THE HOUSE IS ON FIRE" banner.
- **No monster twice**: Monsters.pickFresh + the seen sets in Run (normal and evolved ghosts).

To finish (Studio in Edit mode, bridge on):

```bash
python3 tools/deploy_luau.py --root pending/src $(find pending/src -name "*.luau")
```

Then playtest (taser on a monster, flamethrower in the house, 6+ waves), fix what is off, run
`tools/save_game.sh "game: taser + flamethrower wildfire + no repeated monsters"` and delete this folder.
The taser and flamethrower sounds are built from sounds the game already has (no new audio could be searched
without Studio): swap real recordings into Shared/Sounds if they don't sound right.
