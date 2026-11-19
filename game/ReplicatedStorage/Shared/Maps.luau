--!strict
-- The 14 maps (the Mansion is free, the rest are bought at the Hooded Dealer) and the 4 difficulties.
-- Prices: one good run (8-10 kills on Normal, ~1800-2600 cash) unlocks the next map.
-- Every map is a ServerStorage.Maps.<id> model built on the same footprint as the Mansion
-- (house x -80..80, z -60..60, front door at z = 60 facing the yard), so the run, events and yard all fit.
-- light = the "inside" lighting the client uses for that map (tint, ambient, colour grade).
-- campaign = a building of a campaign map (Shared/Campaign: reached by train, never bought or picked on its own)
export type Map = { id: string, name: string, price: number, desc: string, color: Color3, light: { [string]: any }, campaign: boolean? }
-- enrage = its monsters ENRAGE (Server/Fury: below half health, faster and harder, smash punches); bosses = every 3rd
-- monster is an EVOLVED boss
export type Difficulty = { id: string, name: string, hp: number, dmg: number, speed: number, reward: number, color: Color3, desc: string,
	enrage: boolean, bosses: boolean }

local function C(r, g, b) return Color3.fromRGB(r, g, b) end
-- exposure: optional, the camera exposure inside that map (darker below 0)
local function light(tint: Color3, ambient: Color3, sat: number, contrast: number, bright: number?, exposure: number?): { [string]: any }
	return { Tint = tint, Ambient = ambient, Sat = sat, Contrast = contrast, Brightness = bright or 1.4, Exposure = exposure }
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
	{ id = "Ship", name = "The Ghost Ship", price = 2000, desc = "A huge rotting galleon adrift at sea, three decks deep: the hold and its brig, the gun deck, the open deck with the captain's cabin. Don't fall in.", color = C(60, 120, 160),
		light = light(C(210, 228, 255), C(22, 30, 40), -0.3, 0.25, 1.3) },
	{ id = "Farm", name = "Hollow Creek Farm", price = 2200, desc = "A farmhouse and its barn, hay everywhere.", color = C(190, 140, 70),
		light = light(C(255, 226, 180), C(34, 28, 20), -0.3, 0.22) },
	{ id = "Asylum", name = "Ravenhill Asylum", price = 2400, desc = "A caged hall under a gallery, a corridor of padded cells, the baths, the shock room. She was a patient here.", color = C(176, 150, 96),
		light = light(C(236, 222, 196), C(17, 15, 12), -0.5, 0.34, 0.8, -0.45) }, -- (kept dark)
	{ id = "Hotel", name = "Hotel Morrow", price = 2600, desc = "A red-carpet lobby, a ballroom and long hallways.", color = C(200, 60, 50),
		light = light(C(255, 214, 190), C(36, 24, 20), -0.25, 0.25) },
	{ id = "Prison", name = "Cellblock 9", price = 2800, desc = "Two tiers of cells around a concrete yard.", color = C(140, 140, 150),
		light = light(C(225, 230, 255), C(22, 24, 30), -0.5, 0.3, 1.2) },
	{ id = "Factory", name = "Dollmaker's Factory", price = 3000, desc = "Workbenches, crates and a thousand doll heads.", color = C(220, 150, 160),
		light = light(C(255, 225, 215), C(32, 26, 26), -0.3, 0.25) },
	{ id = "Funeral", name = "Greaves Funeral Home", price = 3200, desc = "Coffins, a viewing room and the morgue downstairs.", color = C(110, 90, 140),
		light = light(C(230, 220, 255), C(24, 22, 30), -0.45, 0.3, 1.2) },
	-- (tools/build/maps/sewer.luau) the waterworks: a canal hall of green water, pump rooms, overflow chambers
	{ id = "Sewer", name = "The Old Sewer", price = 3400, desc = "The city waterworks: a brick canal hall of green water, pump rooms and overflow chambers. Something big lives down here.", color = C(110, 160, 90),
		light = light(C(214, 240, 200), C(20, 28, 20), -0.4, 0.3, 1.1, -0.2) },
	-- (tools/build/maps/station.luau) a dead warship that came down in the woods: steel, strip lights, a live reactor
	{ id = "Station", name = "Erebus Station", price = 3600, desc = "A dead warship that fell out of the sky: the hangar and its last interceptor, the cells, the bridge, and a reactor still burning in the middle of it.", color = C(120, 170, 230),
		light = light(C(214, 228, 255), C(20, 24, 32), -0.4, 0.3, 1.2, -0.1) },
	-- CAMP HOLLOWMERE (Shared/Campaign): its five buildings, one monster each (tools/build/maps/camp_*.luau)
	{ id = "Camp_Bunkhouse", name = "The Bunkhouse", price = 0, campaign = true, desc = "Rows of bunks under high rafters.", color = C(150, 110, 70),
		light = light(C(255, 226, 190), C(26, 22, 18), -0.35, 0.26, 1.2, -0.15) },
	{ id = "Camp_Boathouse", name = "The Boathouse", price = 0, campaign = true, desc = "The lake comes right inside.", color = C(70, 120, 130),
		light = light(C(206, 232, 240), C(18, 26, 30), -0.4, 0.28, 1.1, -0.2) },
	{ id = "Camp_MessHall", name = "The Mess Hall", price = 0, campaign = true, desc = "Long tables and a burnt kitchen.", color = C(200, 110, 50),
		light = light(C(255, 214, 170), C(30, 22, 16), -0.3, 0.26, 1.3, -0.1) },
	{ id = "Camp_Barn", name = "The Barn", price = 0, campaign = true, desc = "Hay, stalls and a lot of scarecrows.", color = C(170, 130, 70),
		light = light(C(255, 224, 176), C(26, 22, 16), -0.38, 0.28, 1.1, -0.2) },
	{ id = "Camp_Lodge", name = "The Main Lodge", price = 0, campaign = true, desc = "The camp office and the great room.", color = C(180, 50, 40),
		light = light(C(255, 220, 196), C(28, 22, 20), -0.35, 0.28, 1.2, -0.15) },
	-- THE MOONLIGHT CARNIVAL (Shared/Campaign): its six buildings (tools/build/maps/carn_*.luau)
	{ id = "Carn_BigTop", name = "The Big Top", price = 0, campaign = true, desc = "The ring, the stands and their mannequins.", color = C(170, 30, 36),
		light = light(C(255, 214, 190), C(30, 20, 20), -0.3, 0.28, 1.25, -0.1) },
	{ id = "Carn_Mirrors", name = "The Hall of Mirrors", price = 0, campaign = true, desc = "A mirror maze and a fortune teller's parlour.", color = C(150, 80, 200),
		light = light(C(226, 206, 255), C(24, 18, 32), -0.3, 0.3, 1.15, -0.15) },
	{ id = "Carn_Carousel", name = "The Carousel", price = 0, campaign = true, desc = "The ride, the benches and the high striker.", color = C(60, 110, 140),
		light = light(C(255, 220, 190), C(24, 22, 26), -0.3, 0.26, 1.25, -0.1) },
	{ id = "Carn_Funhouse", name = "The Funhouse", price = 0, campaign = true, desc = "Crates, a ball pit and a giant clown head.", color = C(200, 80, 150),
		light = light(C(255, 210, 230), C(28, 20, 26), -0.25, 0.28, 1.2, -0.12) },
	{ id = "Carn_Prizes", name = "The Prize Arcade", price = 0, campaign = true, desc = "Game booths and a wall of prizes.", color = C(220, 170, 50),
		light = light(C(255, 226, 180), C(28, 22, 18), -0.3, 0.26, 1.25, -0.1) },
	{ id = "Carn_GhostTrain", name = "The Ghost Train", price = 0, campaign = true, desc = "A dark ride to the Party Bear's stage.", color = C(90, 200, 120),
		light = light(C(200, 230, 220), C(16, 20, 22), -0.35, 0.3, 1.05, -0.25) },
	-- BLACKWATER HARBOR (Shared/Campaign map 3; tools/build/maps/harbor_lib.luau + harb_<building>.luau)
	{ id = "Harb_Market", name = "The Fish Market", price = 0, campaign = true, desc = "Slabs of ice, crates and a drain into the harbor.", color = C(90, 170, 160),
		light = light(C(210, 236, 240), C(22, 30, 34), -0.3, 0.26, 1.2, -0.1) },
	{ id = "Harb_Cannery", name = "The Cannery", price = 0, campaign = true, desc = "Conveyor belts, boilers and towers of tins.", color = C(170, 140, 90),
		light = light(C(240, 230, 200), C(28, 26, 22), -0.3, 0.26, 1.2, -0.1) },
	{ id = "Harb_Lighthouse", name = "The Lighthouse", price = 0, campaign = true, desc = "The keeper's house at the foot of the tower.", color = C(240, 210, 120),
		light = light(C(255, 236, 200), C(26, 26, 30), -0.3, 0.26, 1.2, -0.1) },
	{ id = "Harb_NetLoft", name = "The Net Loft", price = 0, campaign = true, desc = "Nets on every beam, floats, ropes and barrels.", color = C(200, 110, 60),
		light = light(C(240, 220, 200), C(26, 22, 20), -0.3, 0.26, 1.2, -0.1) },
	{ id = "Harb_Ship", name = "The Ghost Ship", price = 0, campaign = true, desc = "The captain's ship, moored at the end of the pier.", color = C(80, 130, 170),
		light = light(C(200, 220, 255), C(20, 26, 34), -0.3, 0.28, 1.15, -0.15) },
	-- THE ASHEN ABBEY (Shared/Campaign map 4; tools/build/maps/abbey_lib.luau + abb_<building>.luau): ash and hellfire
	{ id = "Abb_Cloister", name = "The Cloister", price = 0, campaign = true, desc = "Arcades round a dead garden, a fountain of black water.", color = C(170, 150, 120),
		light = light(C(255, 226, 200), C(30, 24, 22), -0.25, 0.26, 1.2, -0.1) },
	{ id = "Abb_Crypt", name = "The Crypt", price = 0, campaign = true, desc = "Tombs, coffins, bones in the walls.", color = C(120, 140, 110),
		light = light(C(220, 240, 210), C(22, 26, 22), -0.3, 0.28, 1.15, -0.15) },
	{ id = "Abb_Belfry", name = "The Bell Tower", price = 0, campaign = true, desc = "The bell chamber: ropes, beams and great bronze bells.", color = C(200, 150, 70),
		light = light(C(255, 220, 170), C(30, 24, 18), -0.25, 0.26, 1.2, -0.1) },
	{ id = "Abb_Ossuary", name = "The Ossuary", price = 0, campaign = true, desc = "Walls built of skulls, piles of bones.", color = C(220, 210, 180),
		light = light(C(255, 236, 210), C(28, 24, 20), -0.3, 0.26, 1.15, -0.15) },
	{ id = "Abb_Nave", name = "The Cathedral", price = 0, campaign = true, desc = "The nave split open to the fire below.", color = C(230, 80, 40),
		light = light(C(255, 190, 150), C(40, 20, 16), -0.15, 0.3, 1.25, -0.05) },
	-- THE BLACK MOON (Shared/Campaign map 5; tools/build/maps/moon_lib.luau + moon_<building>.luau): steel, neon, the void
	{ id = "Moon_Dock", name = "The Docking Bay", price = 0, campaign = true, desc = "Airlocks, a lander, cargo pods.", color = C(150, 170, 210),
		light = light(C(210, 225, 255), C(22, 26, 36), -0.2, 0.26, 1.2, -0.1) },
	{ id = "Moon_Lab", name = "The Lab", price = 0, campaign = true, desc = "Broken tanks, lab benches, green light.", color = C(110, 230, 140),
		light = light(C(210, 255, 225), C(20, 30, 26), -0.2, 0.26, 1.2, -0.1) },
	{ id = "Moon_Reactor", name = "The Reactor", price = 0, campaign = true, desc = "The core, its pipes and its coolant.", color = C(90, 200, 255),
		light = light(C(200, 235, 255), C(18, 26, 36), -0.15, 0.28, 1.2, -0.1) },
	{ id = "Moon_Control", name = "The Control Room", price = 0, campaign = true, desc = "Consoles, screens and a window on the Earth.", color = C(230, 70, 70),
		light = light(C(255, 215, 215), C(30, 20, 24), -0.2, 0.28, 1.15, -0.12) },
	{ id = "Moon_Gate", name = "The Black Gate", price = 0, campaign = true, desc = "A ring of black stone and a portal to somewhere else.", color = C(170, 110, 255),
		light = light(C(225, 205, 255), C(24, 18, 36), -0.1, 0.3, 1.2, -0.08) },
}

local Difficulties: { Difficulty } = {
	{ id = "Easy", name = "EASY", hp = 0.7, dmg = 0.6, speed = 0.9, reward = 0.6, color = C(110, 200, 90), desc = "Weaker monsters, no bosses, x0.6 cash",
		enrage = false, bosses = false },
	{ id = "Normal", name = "NORMAL", hp = 1, dmg = 1, speed = 1, reward = 1, color = C(220, 210, 180), desc = "The real thing, x1 cash",
		enrage = false, bosses = true },
	{ id = "Hard", name = "HARD", hp = 1.45, dmg = 1.35, speed = 1.1, reward = 1.6, color = C(240, 140, 50), desc = "Tougher and faster, monsters enrage, x1.6 cash",
		enrage = true, bosses = true },
	{ id = "Nightmare", name = "NIGHTMARE", hp = 2.1, dmg = 1.8, speed = 1.2, reward = 2.5, color = C(220, 40, 40), desc = "Monsters enrage. Good luck, x2.5 cash",
		enrage = true, bosses = true },
}

local byId: { [string]: Map } = {}
for _, m in List do byId[m.id] = m end
local diffById: { [string]: Difficulty } = {}
for _, d in Difficulties do diffById[d.id] = d end

return { list = List, byId = byId, difficulties = Difficulties, diffById = diffById, default = "Mansion", defaultDiff = "Normal" }
