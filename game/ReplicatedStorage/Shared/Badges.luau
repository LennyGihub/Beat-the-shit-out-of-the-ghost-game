--!strict
-- LONG-TERM GOALS: the bestiary (every monster you have beaten, normal and evolved) and the badges.
-- The server (Server/Bestiary) counts each monster a player knocks out in the save (`Bestiary`: key -> times beaten,
-- key = the monster's id, or id .. "_E" for its evolved form) and unlocks badges from those counts; the lobby's
-- BESTIARY panel (Client/BestiaryUI) shows both.
--
-- A badge is unlocked once, by itself, the moment its goal is reached, and pays `reward` cash. robloxId = the id of
-- a real Roblox badge (Creator Hub > Badges) given with it through BadgeService; 0 = none set up yet.
-- stat = what is measured (Badges.value):
--   kills (monsters beaten in all), wave (highest ghost number beaten), nightmare (beaten on NIGHTMARE),
--   seen (different monsters beaten), seenE (different evolved monsters beaten), evolved (evolved monsters beaten in all),
--   top (the count of the monster you have beaten most), is_<key> (that bestiary entry beaten at least once).
local Monsters = require(script.Parent.Monsters)

export type Badge = { id: string, name: string, text: string, stat: string, goal: number, reward: number, tier: number, group: string, robloxId: number }

-- group = which icon it wears (Badges.icons), tier = 1 bronze, 2 silver, 3 gold, 4 blood ruby
local function b(id: string, group: string, tier: number, name: string, text: string, stat: string, goal: number, reward: number): Badge
	return { id = id, name = name, text = text, stat = stat, goal = goal, reward = reward, tier = tier, group = group, robloxId = 0 }
end

local List: { Badge } = {
	b("hunt1", "hunter", 1, "ROOKIE HUNTER", "Beat 10 monsters", "kills", 10, 300),
	b("hunt2", "hunter", 2, "MONSTER HUNTER", "Beat 100 monsters", "kills", 100, 2000),
	b("hunt3", "hunter", 3, "LEGEND OF THE HOUSE", "Beat 500 monsters", "kills", 500, 8000),
	b("hunt4", "hunter", 4, "THE HOUSE FEARS YOU", "Beat 2000 monsters", "kills", 2000, 25000),
	b("wave1", "wave", 1, "NIGHT OWL", "Beat ghost 5 in one run", "wave", 5, 400),
	b("wave2", "wave", 2, "DEEP IN THE NIGHT", "Beat ghost 10 in one run", "wave", 10, 1500),
	b("wave3", "wave", 3, "ENDLESS NIGHT", "Beat ghost 20 in one run", "wave", 20, 6000),
	b("wave4", "wave", 4, "DAWN BREAKER", "Beat ghost 30 in one run", "wave", 30, 15000),
	b("book1", "book", 1, "FIELD NOTES", "Beat 3 different monsters", "seen", 3, 500),
	b("book2", "book", 2, "KNOW YOUR ENEMY", "Beat 7 different monsters", "seen", 7, 3000),
	b("book3", "book", 3, "FULL BESTIARY", "Beat every monster and every evolved form", "all", 1, 20000),
	b("evo1", "evolved", 1, "SOMETHING WORSE", "Beat an evolved monster", "evolved", 1, 500),
	b("evo2", "evolved", 2, "EVOLUTION EXPERT", "Beat 4 different evolved monsters", "seenE", 4, 3000),
	b("evo3", "evolved", 3, "APEX PREDATOR", "Beat 7 different evolved monsters", "seenE", 7, 10000),
	b("top1", "mastery", 1, "SPECIALIST", "Beat the same monster 25 times", "top", 25, 1500),
	b("top2", "mastery", 3, "OBSESSED", "Beat the same monster 100 times", "top", 100, 8000),
	b("giant", "mastery", 2, "GIANT SLAYER", "Beat the Flayed Giant", "is_Titan", 1, 1000),
	b("gold", "mastery", 3, "LIGHTS OUT FOR GOOD", "Beat the Golden Bear", "is_Animatronic_E", 1, 2500),
	b("night1", "nightmare", 2, "NO SLEEP", "Beat 25 monsters on NIGHTMARE", "nightmare", 25, 4000),
	b("night2", "nightmare", 4, "NIGHTMARE FUEL", "Beat 150 monsters on NIGHTMARE", "nightmare", 150, 15000),
	b("secret1", "secret", 3, "WHAT WAS THAT?", "Beat the secret monster", "is_Conqueror", 1, 5000),
	b("secret2", "secret", 4, "GOLD STANDARD", "Beat the secret monster's evolved form", "is_Conqueror_E", 1, 15000),
}
local byId: { [string]: Badge } = {}
for _, x in List do byId[x.id] = x end

local TIERS = {
	{ name = "BRONZE", color = Color3.fromRGB(176, 112, 62) },
	{ name = "SILVER", color = Color3.fromRGB(190, 196, 204) },
	{ name = "GOLD", color = Color3.fromRGB(240, 190, 60) },
	{ name = "BLOOD RUBY", color = Color3.fromRGB(214, 36, 46) },
}

-- the bestiary's entries, in the order the book shows them: every monster, then its evolved form
export type Entry = { key: string, id: string, evolved: boolean, title: string, desc: string, rarity: number, color: Color3, secret: boolean, ability: string }
local ABILITY = {
	scare = "VANISH AND SCREAM", levitateThrow = "THROWS THE FURNITURE", shieldBash = "SHIELD BASH", blackout = "LIGHTS OUT",
	titanGrab = "GRAB AND THROW", steal = "STEALS YOUR ITEM", ambush = "THE PHONE CALL", warp = "PORTAL STEP",
	doubles = "SPLITS INTO DOUBLES", armed = "COMES ARMED", army = "SKELETON CREW", snap = "FINGER SNAP", shotgun = "12 GAUGE",
	laser = "GAUNTLET BEAM", eat = "EATS THE HOUSE",
}
local Entries: { Entry } = {}
local entryByKey: { [string]: Entry } = {}
for _, d in Monsters.list do
	local secret = (d :: any).secret == true
	local e: Entry = { key = d.id, id = d.id, evolved = false, title = d.title, desc = d.desc, rarity = d.rarity, color = d.color, secret = secret,
		ability = ABILITY[d.ability.kind] or string.upper(d.ability.kind) }
	table.insert(Entries, e)
	local evo = Monsters.evo[d.id]
	if evo then
		local power = evo.power and evo.power.kind or (evo.ability and evo.ability.kind) or d.ability.kind
		local ev: Entry = { key = d.id .. "_E", id = d.id, evolved = true, title = evo.title, desc = evo.desc, rarity = secret and 4 or 3, color = evo.color, secret = secret,
			ability = ABILITY[power] or string.upper(power) }
		table.insert(Entries, ev)
	end
end
for _, e in Entries do entryByKey[e.key] = e end

-- mastery stars of one entry: times beaten needed for 1..4 stars
local STARS = { 1, 5, 15, 40 }
local function stars(count: number): number
	local n = 0
	for i, need in STARS do if count >= need then n = i end end
	return n
end

-- the value of a badge's stat for a save (book = the Bestiary table, kills / wave / nightmare from the save)
local function value(stat: string, book: { [string]: number }, kills: number, wave: number, nightmare: number): number
	if stat == "kills" then return kills end
	if stat == "wave" then return wave end
	if stat == "nightmare" then return nightmare end
	local seen, seenE, evolved, top, all = 0, 0, 0, 0, 1
	for _, e in Entries do
		local c = book[e.key] or 0
		if c > 0 then
			if e.evolved then seenE += 1; evolved += c else seen += 1 end
		else
			all = 0
		end
		top = math.max(top, c)
	end
	if stat == "seen" then return seen end
	if stat == "seenE" then return seenE end
	if stat == "evolved" then return evolved end
	if stat == "top" then return top end
	if stat == "all" then return all end
	local key = string.match(stat, "^is_(.+)$")
	if key then return (book[key] or 0) > 0 and 1 or 0 end
	return 0
end

return {
	list = List, byId = byId, tiers = TIERS, entries = Entries, entryByKey = entryByKey, stars = stars, starGoals = STARS, value = value,
	-- one picture per badge group (tools/make_image.py --style ps2); "" = the UI draws a plain medal
	icons = { hunter = "", wave = "", book = "", evolved = "", mastery = "", nightmare = "", secret = "" } :: { [string]: string },
}
