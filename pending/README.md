# Pending scripts (not in Studio yet)

Written on 2026-11-20 while the Studio bridge was off (the tunnel answered 404). The PC's "GitHub sync" window
(`roblox-mcp-bridge/pull-from-github.js`) writes these into the open Studio by itself. **Nothing here was playtested.**

- `StarterPlayer/StarterPlayerScripts/Client/FormSets.luau` (NEW): every map's jars / potions get their own layer
  round the wearer in the park, bigger map after map (Camp fireflies / embers, Carnival marquee bulbs, Harbor water
  vortex, Abbey wings of light; the Black Moon keeps its giant, Client/FormGiant).
- `StarterPlayer/StarterPlayerScripts/Client/FormLook.luau`: calls FormSets; a later map's form is stronger in the
  base look too (tierBoost 1 .. 1.88: particle sizes, rates, lights, the put-on burst).
- `StarterPlayer/StarterPlayerScripts/Client/FormTutorial.luau`: no sound on every step any more, and the distance to
  Doc Mercy / Mother Moth has its own fixed-size label (the instruction no longer pops each time you move).

Added on 2026-11-21 (bridge still off, 404; **not playtested either**):

- **A map's last building ends in the park.** `Shared/Campaign` (`isLast`), `Server/Run` (stageCleared sends `final`,
  onStageChoice refuses next / again there, 30 s to the park), `Client/StageUI` (only one big BACK TO THE PARK
  button, "<MAP> CLEARED! NEXT MAP: ... - TAKE THE TRAIN IN THE PARK"). Other buildings keep NEXT / AGAIN / PARK.
- **Forms rebalanced** (`Shared/Forms`): each map's forms are sized to its monsters (COMMON = that map feels like Camp
  with no form, LEGENDARY = 2.5x that: really easy; numbers in the file's BALANCE comment). Big bonuses show as
  "x58 PUNCH DAMAGE" (`Forms.bonusText`). `Server/Combat`: block stamina cost per damage / the health multiplier
  (`Combat.healthMult`); `Server/Inventory` + `Server/UltRunner`: heals and shields grow with it.
- **Entrances: no more walking at the camera** (`Client/EntrancePose`, `Client/Entrance`, `Shared/Entrances` texts):
  Pirate / Netman turn round in the fog, Conqueror takes shape in front of his portal (portal right behind him) and
  stamps, Astronaut gets his own pose (airlock right behind him, steam, jetpack hop), Antlered / Specimen hang right
  above instead of crawling up, the Caller's flashes show him left / right / middle. The Void Knight still steps out
  through his wall.
- **HOW TO PLAY** (`Client/TutorialUI`) only shows while `TutorialSeen` is false: gone once the tutorial was played.
- **Jars / potions tutorial step 3 = THE TRAIN** (`Client/FormTutorial`, `Client/LobbyUI` isOpen / inParty /
  createButton / startButton, `ClientMain` passes LobbyUI): walk to the parked train (arrow, gold line, outline) ->
  board -> CREATE (ringed) -> START (ringed) -> done on `Boarding`. The tip now shows 9 s between step 2 and 3.
- **ENDLESS opens at level 10** (`Campaign.ENDLESS_LEVEL`): the PLAY panel's switch says "ENDLESS  LV 10" and stays
  on CAMPAIGN below it; `Server/Lobby` refuses creating / joining an endless lobby below level 10.

- **Rock fight music** (`Shared/Sounds`, the user picked it after listening to the list): every campaign building gets a
  rock / metal track, each map from its lightest (building 1, volume 1.3) to its heaviest (the boss, 1.7; its phase 2
  1.8). Camp: Avalanche Addict A, Breaking Bones A, Deep Earth Grinder A, Fight Hard or Die, Get Ready for the
  Onslaught / From Alpha to Omega. Carnival: Dark Circus A, Lucid Dream, Fighting Heart, Dysteria, Troll / Soul Banger,
  Machine Gun Toy / Chain Reaction. Harbor: Ominous Doom A, Infectious, Down in the Maelstrom, Metal Storm Breaks,
  Sword and Shield / The Speed of Light. Abbey: Lost In Eternity, Soulbound Crypt, Occult Forces, Repulsion, Divine
  Curse / Soldier of Death. Moon: Exoplanet, Black Hole, Artificial Armageddon A, Parallel World, Extreme Speed /
  Black Plague. Check in a playtest that each one loads and that the volumes sit well against the fight sounds.

Test when the bridge is back: clear `Camp_Lodge` (admin `start Camp_Lodge Normal`, kill) and check the result screen;
`form Nebula` + `form DarkMatter` then `start Moon_Gate Normal` (should be easy); admin `monster pirate|conqueror|
astronaut|antlered|specimen|caller` with `DebugEntranceFreezeAt` photos; `DebugFormTut` through the train step;
`xp` below / above level 10 for the ENDLESS switch.

When the bridge is back: playtest them (admin `form <id>` with one form of each map), fix what looks off, run
`tools/save_game.sh`, then delete `pending/`.
