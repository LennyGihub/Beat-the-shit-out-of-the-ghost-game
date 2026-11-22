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

- **WEAK: lift and throw the monster** (the user: "the monster can get weak at some point and the player can lift him and
  throw him around, when the player does a X5 combo; introduce it into the cinematic tutorial too"). `Shared/Config`
  Weak; `Server/Ghost` states `Weak` (5 s slumped, stars, no attacks, hits hurt but don't move it; once every 18 s)
  and `Carried` (welded over the carrier's head like furniture, breaks free after 4.5 s), `Ghost.weaken / lift /
  throwMonster / dropMonster` (thrown = ragdoll through the inside walls; the landing deals 7% of its max health or the
  thrower's throw damage); `Server/Combat` (the 5th combo hit weakens it, the lift key lifts it, the throw throws it,
  slower walk while carrying, dropped on death); `Client/Input` (E lifts the weak monster first, hint "LIFT THE
  MONSTER!"), `Client/GhostAnim` (kneeling Weak pose, struggling Carried pose, stars), new `Client/WeakFx` (gold
  outline + "WEAK! [E] LIFT IT" tag, banner, slam shake / dust / "SLAM! n DAMAGE"), `ClientMain` wiring. Admin
  `weak` makes it weak now. THE INTRO: a new lesson after the armchair throw: COMBO x5 (the last hits land by
  themselves if the player is slow) -> LIFT HER -> THROW HER at the TV's wall (Server/Tutorial "combo"; she is only
  allowed to go weak from that lesson on; thrown far in a lesson she floats back faster).
- **Fix after the user's test (2026-11-22):** in the COMBO lesson her small lesson knockback broke the combo. From
  that lesson until the fight, hits no longer move her at all (`Ghost.tutorial.noKnock`, set by Server/Tutorial
  "combo"). After being thrown (or any knock-out), she gets up FACING the thrower / her target (`Server/Ghost`:
  turned when the ragdoll ends, and she keeps turning to her target while getting up, while WEAK, and while a lesson
  holds her).

Test when the bridge is back: clear `Camp_Lodge` (admin `start Camp_Lodge Normal`, kill) and check the result screen;
`form Nebula` + `form DarkMatter` then `start Moon_Gate Normal` (should be easy); admin `monster pirate|conqueror|
astronaut|antlered|specimen|caller` with `DebugEntranceFreezeAt` photos; `DebugFormTut` through the train step;
`xp` below / above level 10 for the ENDLESS switch. WEAK: punch any monster x5 (or admin `weak`), lift it (E), walk,
throw it at a wall; let one break free; check the intro's COMBO lesson with `DebugIntro` + `DebugIntroAct` Punch / Lift.

When the bridge is back: playtest them (admin `form <id>` with one form of each map), fix what looks off, run
`tools/save_game.sh`, then delete `pending/`.
