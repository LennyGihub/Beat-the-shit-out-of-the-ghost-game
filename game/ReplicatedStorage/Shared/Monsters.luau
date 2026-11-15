--!strict
-- The 10 monsters. Ghost 1 of a run is always the Woman; after that a random one by rarity.
-- template = model name in ServerStorage.Monsters (the Woman uses ServerStorage.GhostTemplate).
-- hp/speed/dmg/reward multiply the level-based values in Config.Ghost / Config.Reward.
-- hover = root height above the floor (floaters ~4.6, walkers = their hip height).
-- ability = what the Abilities module runs (cd = seconds between uses).
export type Monster = {
	id: string, name: string, title: string, rarity: number, template: string, color: Color3,
	hp: number, speed: number, dmg: number, reward: number, hover: number, walker: boolean, scale: number,
	ability: { kind: string, cd: number, [string]: any }, desc: string,
}

local RARITY = {
	{ name = "COMMON", color = Color3.fromRGB(200, 196, 186), weight = 60 },
	{ name = "RARE", color = Color3.fromRGB(80, 150, 240), weight = 30 },
	{ name = "LEGENDARY", color = Color3.fromRGB(255, 170, 40), weight = 10 },
}

local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local function m(t: { [string]: any }): Monster return t :: any end

local List: { Monster } = {
	m({ id = "Woman", name = "The Woman", title = "THE WOMAN IN THE HOUSE", rarity = 0, template = "GhostTemplate", color = C(150, 200, 210),
		hp = 1, speed = 1, dmg = 1, reward = 1, hover = 4.6, walker = false, scale = 1,
		ability = { kind = "scare", cd = 18 }, desc = "Vanishes and screams in your face." }),
	-- COMMON ----------------------------------------------------------------
	m({ id = "Butcher", name = "The Butcher", title = "THE BUTCHER", rarity = 1, template = "Butcher", color = C(170, 60, 50),
		hp = 1.25, speed = 0.85, dmg = 1.2, reward = 1.1, hover = 0, walker = true, scale = 1.45,
		ability = { kind = "grabThrow", cd = 7, range = 9, dmg = 16, power = 95 }, desc = "Grabs you and throws you across the room." }),
	m({ id = "Crawler", name = "The Crawler", title = "THE CRAWLER", rarity = 1, template = "Crawler", color = C(190, 190, 170),
		hp = 0.8, speed = 1.35, dmg = 0.9, reward = 1.1, hover = 0, walker = true, scale = 1.1,
		ability = { kind = "pounce", cd = 6, min = 12, max = 42, dmg = 14, pin = 1.4 }, desc = "Leaps from far away and pins you down." }),
	m({ id = "Poltergeist", name = "The Poltergeist", title = "THE POLTERGEIST CHILD", rarity = 1, template = "Poltergeist", color = C(150, 120, 200),
		hp = 0.9, speed = 1.0, dmg = 0.8, reward = 1.1, hover = 3.2, walker = false, scale = 0.8,
		ability = { kind = "furnitureStorm", cd = 7, count = 3, power = 85, dmg = 12 }, desc = "Throws the furniture at you." }),
	-- RARE ------------------------------------------------------------------
	m({ id = "Banshee", name = "The Banshee", title = "THE BANSHEE", rarity = 2, template = "Banshee", color = C(160, 220, 230),
		hp = 1.2, speed = 1.1, dmg = 1.1, reward = 1.4, hover = 5.2, walker = false, scale = 1.1,
		ability = { kind = "wail", cd = 9, radius = 30, dmg = 12, push = 60, drain = 45 }, desc = "Her wail blasts everyone away." }),
	m({ id = "Stalker", name = "The Shadow Stalker", title = "THE SHADOW STALKER", rarity = 2, template = "Stalker", color = C(60, 50, 80),
		hp = 1.1, speed = 1.15, dmg = 1.3, reward = 1.4, hover = 0, walker = true, scale = 1.35,
		ability = { kind = "blackout", cd = 15, t = 5, dmg = 22 }, desc = "Kills the lights, then strikes from behind." }),
	m({ id = "PlagueDoctor", name = "The Plague Doctor", title = "THE PLAGUE DOCTOR", rarity = 2, template = "PlagueDoctor", color = C(110, 170, 60),
		hp = 1.3, speed = 0.95, dmg = 1.0, reward = 1.4, hover = 0, walker = true, scale = 1.15,
		ability = { kind = "gas", cd = 6, radius = 9, dps = 7, t = 8, max = 3 }, desc = "Throws flasks of toxic gas." }),
	-- LEGENDARY -------------------------------------------------------------
	m({ id = "HollowKing", name = "The Hollow King", title = "THE HOLLOW KING", rarity = 3, template = "HollowKing", color = C(255, 110, 30),
		hp = 1.7, speed = 1.0, dmg = 1.3, reward = 2.0, hover = 0, walker = true, scale = 1.6,
		ability = { kind = "hellfire", cd = 8, radius = 7, dmg = 26, delay = 1.3 }, desc = "Fire pillars erupt under your feet." }),
	m({ id = "HeadlessKnight", name = "The Headless Knight", title = "THE HEADLESS KNIGHT", rarity = 3, template = "HeadlessKnight", color = C(170, 170, 185),
		hp = 1.8, speed = 1.05, dmg = 1.4, reward = 2.0, hover = 0, walker = true, scale = 1.4,
		ability = { kind = "charge", cd = 7, min = 14, max = 70, speed = 85, dmg = 30, wind = 0.9 }, desc = "Charges through walls, sword first." }),
	m({ id = "MirrorBride", name = "The Mirror Bride", title = "THE MIRROR BRIDE", rarity = 3, template = "MirrorBride", color = C(235, 230, 245),
		hp = 1.6, speed = 1.1, dmg = 1.2, reward = 2.0, hover = 4.4, walker = false, scale = 1,
		ability = { kind = "clones", cd = 15, n = 3, t = 9, dmg = 14 }, desc = "Splits into mirror copies that shatter on you." }),
}

local byId: { [string]: Monster } = {}
for _, d in List do byId[d.id] = d end

-- ghost 1 = the Woman; then weighted by rarity, never the same monster twice in a row
local function pick(wave: number, last: string?, rng: Random): Monster
	if wave <= 1 then return byId.Woman end
	local total = 0
	for _, r in RARITY do total += r.weight end
	local x, rar = rng:NextNumber(0, total), 1
	for i, r in RARITY do
		x -= r.weight
		if x <= 0 then rar = i; break end
	end
	local pool = {}
	for _, d in List do if d.rarity == rar and d.id ~= last then table.insert(pool, d) end end
	if #pool == 0 then return byId.Woman end
	return pool[rng:NextInteger(1, #pool)]
end

return { list = List, byId = byId, rarity = RARITY, pick = pick }
