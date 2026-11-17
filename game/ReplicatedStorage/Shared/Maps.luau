--!strict
-- The 12 maps (the Mansion is free, the rest are bought at the Hooded Dealer) and the 4 difficulties.
-- Prices: one good run (8-10 kills on Normal, ~1800-2600 cash) unlocks the next map.
-- Every map is a ServerStorage.Maps.<id> model built on the same footprint as the Mansion
-- (house x -80..80, z -60..60, front door at z = 60 facing the yard), so the run, events and yard all fit.
-- light = the "inside" lighting the client uses for that map (tint, ambient, colour grade).
export type Map = { id: string, name: string, price: number, desc: string, color: Color3, light: { [string]: any } }
export type Difficulty = { id: string, name: string, hp: number, dmg: number, speed: number, reward: number, color: Color3, desc: string }

local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local function light(tint: Color3, ambient: Color3, sat: number, contrast: number, bright: number?): { [string]: any }
	return { Tint = tint, Ambient = ambient, Sat = sat, Contrast = contrast, Brightness = bright or 1.4 }
end

local List: { Map } = {
	{ id = "Mansion", name = "The Mansion", price = 0, desc = "Where it all started. Two floors, a grand hall, a lot of furniture.", color = C(150, 120, 90),
		light = light(C(255, 240, 226), C(30, 27, 25), -0.38, 0.22) },
	{ id = "Hospital", name = "St. Agnes Hospital", price = 1200, desc = "Flickering wards, gurneys and a long white corridor.", color = C(150, 200, 180),
		light = light(C(225, 255, 235), C(30, 36, 34), -0.45, 0.25, 1.6) },
	{ id = "School", name = "Blackwood High", price = 1400, desc = "Lockers, classrooms and a gym nobody left.", color = C(200, 170, 90),
		light = light(C(255, 236, 200), C(28, 26, 22), -0.35, 0.22, 1.2) },
	{ id = "Church", name = "Chapel of Thorns", price = 1600, desc = "Pews, candles and a long nave to throw things down.", color = C(170, 120, 200),
		light = light(C(255, 220, 190), C(40, 30, 32), -0.3, 0.28, 1.5) },
	{ id = "Motel", name = "Last Stop Motel", price = 1800, desc = "A row of cheap rooms off a buzzing neon hallway.", color = C(230, 80, 120),
		light = light(C(255, 210, 230), C(34, 22, 30), -0.2, 0.25) },
	{ id = "Ship", name = "The Ghost Ship", price = 2000, desc = "A rotting galleon adrift at sea: the hold, the deck, the captain's cabin. Don't fall in.", color = C(60, 120, 160),
		light = light(C(210, 228, 255), C(22, 30, 40), -0.3, 0.25, 1.3) },
	{ id = "Farm", name = "Hollow Creek Farm", price = 2200, desc = "A farmhouse and its barn, hay everywhere.", color = C(190, 140, 70),
		light = light(C(255, 226, 180), C(34, 28, 20), -0.3, 0.22) },
	{ id = "Asylum", name = "Ravenhill Asylum", price = 2400, desc = "A caged hall under a gallery, a corridor of padded cells, the baths, the shock room. She was a patient here.", color = C(176, 150, 96),
		light = light(C(255, 236, 196), C(32, 27, 20), -0.5, 0.3, 1.3) },
	{ id = "Hotel", name = "Hotel Morrow", price = 2600, desc = "A red-carpet lobby, a ballroom and long hallways.", color = C(200, 60, 50),
		light = light(C(255, 214, 190), C(36, 24, 20), -0.25, 0.25) },
	{ id = "Prison", name = "Cellblock 9", price = 2800, desc = "Two tiers of cells around a concrete yard.", color = C(140, 140, 150),
		light = light(C(225, 230, 255), C(22, 24, 30), -0.5, 0.3, 1.2) },
	{ id = "Factory", name = "Dollmaker's Factory", price = 3000, desc = "Workbenches, crates and a thousand doll heads.", color = C(220, 150, 160),
		light = light(C(255, 225, 215), C(32, 26, 26), -0.3, 0.25) },
	{ id = "Funeral", name = "Greaves Funeral Home", price = 3200, desc = "Coffins, a viewing room and the morgue downstairs.", color = C(110, 90, 140),
		light = light(C(230, 220, 255), C(24, 22, 30), -0.45, 0.3, 1.2) },
}

local Difficulties: { Difficulty } = {
	{ id = "Easy", name = "EASY", hp = 0.7, dmg = 0.6, speed = 0.9, reward = 0.6, color = C(110, 200, 90), desc = "Weaker monsters, x0.6 cash" },
	{ id = "Normal", name = "NORMAL", hp = 1, dmg = 1, speed = 1, reward = 1, color = C(220, 210, 180), desc = "The real thing, x1 cash" },
	{ id = "Hard", name = "HARD", hp = 1.45, dmg = 1.35, speed = 1.1, reward = 1.6, color = C(240, 140, 50), desc = "Tougher and faster, x1.6 cash" },
	{ id = "Nightmare", name = "NIGHTMARE", hp = 2.1, dmg = 1.8, speed = 1.2, reward = 2.5, color = C(220, 40, 40), desc = "Good luck, x2.5 cash" },
}

local byId: { [string]: Map } = {}
for _, m in List do byId[m.id] = m end
local diffById: { [string]: Difficulty } = {}
for _, d in Difficulties do diffById[d.id] = d end

return { list = List, byId = byId, difficulties = Difficulties, diffById = diffById, default = "Mansion", defaultDiff = "Normal" }
