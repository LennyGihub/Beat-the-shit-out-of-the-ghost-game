--!strict
-- THE PATCH NOTES: what is new in the game since the last published update (Client/PatchNotesUI: the WHAT'S NEW window
-- opens by itself once for a player who played before, and the WHAT'S NEW button in the park opens it again).
-- A NEW UPDATE: replace `entries`, change `title` / `date` and raise `version` by one: everyone whose save saw an older
-- version (Data "NotesV") gets the window once. Brand-new players never get it (their save starts at this version).
-- Player-facing text only (no admin tools), in capitals like the rest of the UI.
export type Entry = { tag: string, title: string, text: string }

local PatchNotes = {
	version = 1,
	title = "THE CODES UPDATE",
	date = "NOVEMBER 22",
	entries = {
		{ tag = "NEW", title = "CODES", text = "Press CODES in the lobby and type a code to get its reward. The first code: ALPHA TESTER." },
		{ tag = "NEW", title = "2 EXCLUSIVE FORMS", text = "ALPHA GLITCH (fists: x2.5 punch damage, +35% knockback) and ALPHA HOLOGRAM (body: x2.5 max health, +40% stamina), with a glitching hologram look. They are in no jar and no potion: only the code gives them." },
		{ tag = "NEW", title = "INVENTORY", text = "The BESTIARY button is now INVENTORY: every form you own, how many copies you have, which ones you wear, and WEAR IT in one click. The monsters and badges are in there too." },
		{ tag = "CHANGED", title = "TRADING", text = "Every form can be traded now, the exclusive ones too." },
		{ tag = "NEW", title = "THE NEW TUTORIAL FOR EVERYONE", text = "Everyone plays the new tutorial once, even if you played before. You can skip it." },
		{ tag = "CHANGED", title = "LOBBY CAMERA", text = "Scroll out much further in the park to see everything." },
	} :: { Entry },
}

return PatchNotes
