--!strict
-- THE PATCH NOTES: what is new in the game since the last published update (Client/PatchNotesUI: the WHAT'S NEW window
-- opens by itself once for a player who played before, and the WHAT'S NEW button in the park opens it again).
-- A NEW UPDATE: replace `entries`, change `title` / `date` and raise `version` by one: everyone whose save saw an older
-- version (Data "NotesV") gets the window once. Brand-new players never get it (their save starts at this version).
-- Player-facing text only (no admin tools), in capitals like the rest of the UI. An entry with `section` is a heading.
-- Version 1 (2026-11-22, the user: "list every new thing", the published game was the endless mode only): everything
-- since then (the repository's history from 2026-11-18 on).
export type Entry = { section: string?, tag: string?, title: string?, text: string? }

local function S(name: string): Entry return { section = name } end
local function E(tag: string, title: string, text: string): Entry return { tag = tag, title = title, text = text } end

local PatchNotes = {
	version = 1,
	title = "THE CAMPAIGN UPDATE",
	date = "NOVEMBER 22",
	entries = {
		S("THE CAMPAIGN"),
		E("NEW", "CAMPAIGN MODE", "Press PLAY and pick CAMPAIGN: 5 maps, one haunted building after another, one monster in each. Clear a map to open the next one."),
		E("NEW", "5 NEW MAPS", "CAMP HOLLOWMERE, THE MOONLIGHT CARNIVAL, BLACKWATER HARBOR, THE ASHEN ABBEY and THE BLACK MOON. Each one has its own world around it: a lake and cabins, fair rides, a harbor town, a graveyard over lava, craters on the moon."),
		E("NEW", "26 BUILDINGS", "Every building is made for its monster: a bunkhouse with rafters, a boathouse over the lake, a circus tent, a carousel, a lighthouse, a real ghost ship, a bell tower, a cathedral, a moon base and its reactor..."),
		E("NEW", "17 NEW MONSTERS", "The Antlered One, the Lake Witch, the Burned Counselor, the Scarecrow, Pop the Clown, the Strongman, Madame Fortune, the Ringmaster, the Deep One, the Keeper, the Netman, the Weeping Nun, the Gravedigger, the Bell Ringer, the Lost Astronaut, the Specimen and the Sentinel. Two special moves each, their own entrance, voice and music."),
		E("NEW", "BOSSES IN TWO PHASES", "Every map ends with a boss that comes back stronger: THE LAST CALL, the GOLDEN BEAR, the PIRATE KING, the DEMON LORD and the GOLDEN CONQUEROR."),
		E("NEW", "THE TRAIN", "Board the train at the park's new station: it takes you and your friends to the building. After a win: NEXT BUILDING, FIGHT AGAIN or BACK TO THE PARK."),
		E("NEW", "SECRET ROOMS", "Some buildings hide a secret room behind a panel, a curtain or a shelf, with the best items inside."),
		E("CHANGED", "DIFFICULTY", "Monsters only enrage on HARD and NIGHTMARE, no bosses on EASY, and every map's monsters are tougher than the last."),
		E("CHANGED", "ENDLESS MODE", "The old endless mode is still here: switch PLAY to ENDLESS and pick a house. It opens at level 10."),
		S("FORMS"),
		E("NEW", "DOC MERCY AND MOTHER MOTH", "Two sellers in the park. Doc Mercy's jars of ectoplasm give FIST FORMS (more punch damage and knockback), Mother Moth's potions give BODY FORMS (more health and stamina)."),
		E("NEW", "6 RARITIES", "Every jar and potion gives a random form, from COMMON to MYTHIC. Every map has its own jars and potions, stronger map after map. Opening one plays a cinematic."),
		E("NEW", "OPEN OFFLINE", "Put jars and potions to open by themselves, a few minutes each, even while you fight or are away. 24 hours of offline opening guarantees a RARE or better."),
		E("NEW", "X10 AND X100", "Open 10 or 100 at once and see everything you got on one screen."),
		E("NEW", "SHOW THEM OFF", "Your forms glow on your fists and your body, bigger the rarer they are and the further the map. Black Moon forms raise a GIANT copy of you, up to 10 times your size."),
		E("NEW", "TRADING", "Trade forms and cash with other players: press TRADE, or T next to a player. Both press READY, then a short countdown keeps it safe."),
		E("NEW", "INVENTORY", "The BESTIARY button is now INVENTORY: all your forms, your copies, what you wear and WEAR IT in one click, plus the monsters and badges."),
		S("FIGHTING"),
		E("NEW", "WEAK MONSTERS", "Land a 5-hit combo and the monster goes WEAK: lift it over your head and throw it."),
		E("NEW", "BIGGER EFFECTS", "Hits, auras and deaths get bigger and wilder the further you get in the maps."),
		E("NEW", "NEW MUSIC AND VOICES", "A rock track for every building, heavier on the bosses, and every new monster has its own voice."),
		E("NEW", "FREE MOUSE", "Press LEFT ALT in a fight to free your mouse (you can change the key in the settings)."),
		S("AND MORE"),
		E("NEW", "PLAYER LEVELS", "Earn XP in every fight, get a new title every 5 levels, and show your level over your head in the park."),
		E("NEW", "THE NEW TUTORIAL", "A ghost crawls out of the TV and teaches you to fight. Everyone plays it once, even if you played before. You can skip it."),
		E("NEW", "CODES", "Press CODES in the lobby. The first code: ALPHA TESTER, for 2 exclusive forms: ALPHA GLITCH and ALPHA HOLOGRAM."),
		E("CHANGED", "THE PARK", "A train station at the east end, the leaderboards by the fountain, and you can scroll the camera out much further."),
	} :: { Entry },
}

return PatchNotes
