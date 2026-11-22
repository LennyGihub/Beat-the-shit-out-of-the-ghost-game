--!strict
-- THE CAMPAIGN: the maps in order. A map is a row of BUILDINGS (stages), one monster in each, fought from the first
-- building to the last; the last one's monster has two phases (its normal form, then its EVOLVED form). Every trip
-- is one building, by train (the lobby's station -> the camp's yard). Beating every building of a map opens the next
-- map. Any building already open can be replayed, on any difficulty (Shared/Maps difficulties).
-- A stage's id is also its Maps.byId entry: its building is the map model ServerStorage.Maps.<id>.
-- Progress (Server/Data "Campaign", player attribute "Campaign" = JSON): stage id -> the best difficulty rank cleared
-- (1 Easy .. 4 Nightmare).
export type Stage = { id: string, map: string, index: number, name: string, monster: string, phases: number,
	level: number, desc: string }
export type CMap = { id: string, name: string, desc: string, color: Color3, stages: { Stage }, soon: boolean?, hp: number?, dmg: number? }

local function C(r, g, b) return Color3.fromRGB(r, g, b) end

local List: { CMap } = {
	-- hp / dmg: the map's monsters are this much tougher than their level makes them (Run.configure), map after map,
	-- so the later maps need the later maps' forms
	{ id = "Camp", name = "CAMP HOLLOWMERE", color = C(196, 120, 60), hp = 1, dmg = 1,
		desc = "A summer camp in the woods at night. Cabins, a lake, a mess hall and a campfire nobody put out.",
		stages = {
			{ id = "Camp_Bunkhouse", map = "Camp", index = 1, name = "THE BUNKHOUSE", monster = "Antlered", phases = 1, level = 1,
				desc = "Rows of bunks under high rafters. Something tall lives up in the dark." },
			{ id = "Camp_Boathouse", map = "Camp", index = 2, name = "THE BOATHOUSE", monster = "LakeWitch", phases = 1, level = 2,
				desc = "The lake comes right inside. Stay away from the water." },
			{ id = "Camp_MessHall", map = "Camp", index = 3, name = "THE MESS HALL", monster = "Counselor", phases = 1, level = 3,
				desc = "Long tables, a kitchen and a counselor who never stopped burning." },
			{ id = "Camp_Barn", map = "Camp", index = 4, name = "THE BARN", monster = "Scarecrow", phases = 1, level = 4,
				desc = "The camp's old barn, full of scarecrows. One of them is watching you." },
			{ id = "Camp_Lodge", map = "Camp", index = 5, name = "THE MAIN LODGE", monster = "Caller", phases = 2, level = 5,
				desc = "The office phone is ringing. He wants you to pick up." },
		} },
	{ id = "Carnival", name = "MOONLIGHT CARNIVAL", color = C(200, 70, 130), hp = 1.4, dmg = 1.25,
		desc = "An abandoned funfair. The big top, the mirrors, the rides and the ghost train: every act still plays.",
		stages = {
			{ id = "Carn_BigTop", map = "Carnival", index = 1, name = "THE BIG TOP", monster = "Ringmaster", phases = 1, level = 6,
				desc = "The show must go on. The crowd in the stands is waiting for you." },
			{ id = "Carn_Mirrors", map = "Carnival", index = 2, name = "THE HALL OF MIRRORS", monster = "Fortune", phases = 1, level = 7,
				desc = "A maze of mirrors with a fortune teller at its heart. Find her crystal ball." },
			{ id = "Carn_Carousel", map = "Carnival", index = 3, name = "THE CAROUSEL", monster = "Strongman", phases = 1, level = 8,
				desc = "The carousel still turns. The strongman still lifts." },
			{ id = "Carn_Funhouse", map = "Carnival", index = 4, name = "THE FUNHOUSE", monster = "Clown", phases = 1, level = 9,
				desc = "Crates, balloons, and a clown who will not stop laughing." },
			{ id = "Carn_Prizes", map = "Carnival", index = 5, name = "THE PRIZE ARCADE", monster = "Goblin", phases = 2, level = 10,
				desc = "Every prize has gone missing. The thief is still in here." },
			{ id = "Carn_GhostTrain", map = "Carnival", index = 6, name = "THE GHOST TRAIN", monster = "Animatronic", phases = 2, level = 11,
				desc = "Take a ride to the Party Bear's last show." },
		} },
	{ id = "Harbor", name = "BLACKWATER HARBOR", color = C(70, 120, 150), hp = 2, dmg = 1.55,
		desc = "A fishing port in a storm. The fish market, the cannery, the lighthouse, the net loft and a ghost ship at the end of the pier.",
		stages = {
			{ id = "Harb_Market", map = "Harbor", index = 1, name = "THE FISH MARKET", monster = "DeepOne", phases = 1, level = 12,
				desc = "Ice, crates and fish on every slab. Something came up out of the harbor with them." },
			{ id = "Harb_Cannery", map = "Harbor", index = 2, name = "THE CANNERY", monster = "Rat", phases = 1, level = 13,
				desc = "Conveyor belts, boilers and towers of tins. The rats grew fat in here." },
			{ id = "Harb_Lighthouse", map = "Harbor", index = 3, name = "THE LIGHTHOUSE", monster = "Keeper", phases = 1, level = 14,
				desc = "The lamp still turns. The keeper never left his post." },
			{ id = "Harb_NetLoft", map = "Harbor", index = 4, name = "THE NET LOFT", monster = "Netman", phases = 1, level = 15,
				desc = "Nets hang from every beam. Watch your feet when the chain starts to swing." },
			{ id = "Harb_Ship", map = "Harbor", index = 5, name = "THE GHOST SHIP", monster = "Pirate", phases = 2, level = 16,
				desc = "Moored at the end of the pier. The captain wants his crew back - and then the Pirate King comes up." },
		} },
	{ id = "Abbey", name = "THE ASHEN ABBEY", color = C(170, 60, 40), hp = 2.8, dmg = 1.9,
		desc = "A great abbey sinking into hell. The cloister, the crypt, the bell tower, the ossuary and a cathedral split open to the fire below.",
		stages = {
			{ id = "Abb_Cloister", map = "Abbey", index = 1, name = "THE CLOISTER", monster = "Nun", phases = 1, level = 17,
				desc = "Cold arcades round a dead garden. A nun weeps somewhere in the dark." },
			{ id = "Abb_Crypt", map = "Abbey", index = 2, name = "THE CRYPT", monster = "Gravedigger", phases = 1, level = 18,
				desc = "Tombs, coffins and a man with a shovel who never stopped digging." },
			{ id = "Abb_Belfry", map = "Abbey", index = 3, name = "THE BELL TOWER", monster = "Ringer", phases = 1, level = 19,
				desc = "The great bells still swing. The ringer still pulls the ropes." },
			{ id = "Abb_Ossuary", map = "Abbey", index = 4, name = "THE OSSUARY", monster = "Titan", phases = 1, level = 20,
				desc = "Walls of skulls and bones. Something huge has been eating the dead." },
			{ id = "Abb_Nave", map = "Abbey", index = 5, name = "THE CATHEDRAL", monster = "Demon", phases = 2, level = 21,
				desc = "The nave is splitting open to hell. The Red Demon waits at the altar - and then the Demon Lord rises." },
		} },
	{ id = "Moon", name = "THE BLACK MOON", color = C(130, 140, 200), hp = 3.9, dmg = 2.35,
		desc = "A base on the dark side of the moon. Docking bay, lab, reactor, control room - and the black gate they opened.",
		stages = {
			{ id = "Moon_Dock", map = "Moon", index = 1, name = "THE DOCKING BAY", monster = "Astronaut", phases = 1, level = 22,
				desc = "Airlocks, cargo pods and a lost crewman who never took his helmet off." },
			{ id = "Moon_Lab", map = "Moon", index = 2, name = "THE LAB", monster = "Specimen", phases = 1, level = 23,
				desc = "The tanks are broken. Whatever grew in them is loose." },
			{ id = "Moon_Reactor", map = "Moon", index = 3, name = "THE REACTOR", monster = "Sentinel", phases = 1, level = 24,
				desc = "The core still glows. The base's guard robot still guards it." },
			{ id = "Moon_Control", map = "Moon", index = 4, name = "THE CONTROL ROOM", monster = "Knight", phases = 1, level = 25,
				desc = "Screens, consoles and a black knight with a red blade." },
			{ id = "Moon_Gate", map = "Moon", index = 5, name = "THE BLACK GATE", monster = "Conqueror", phases = 2, level = 26,
				desc = "The portal at the end of the base. He came through it - and his golden armour came after him." },
		} },
}

local DIFF_RANK = { Easy = 1, Normal = 2, Hard = 3, Nightmare = 4 } :: { [string]: number }
local RANK_DIFF = { "Easy", "Normal", "Hard", "Nightmare" }

local mapById: { [string]: CMap } = {}
local stageById: { [string]: Stage } = {}
for _, m in List do
	mapById[m.id] = m
	for _, s in m.stages do stageById[s.id] = s end
end

local Campaign = { list = List, mapById = mapById, stageById = stageById, diffRank = DIFF_RANK, rankDiff = RANK_DIFF }
-- TRAIN TICKETS: a player can take `max` train trips (to a building: from the park, NEXT BUILDING or FIGHT AGAIN) in
-- `window` seconds; the window starts at the first trip of it (Server/Data: Trips, player attributes TripsLeft /
-- TripsReset = the unix time the tickets come back). `enabled = false` turns the whole system off (2026-11-19, the
-- user: "disable the train tickets for now but dont remove the script"): every trip is free, nothing is used, the ticket
-- lines and REFILL buttons are hidden. All the code stays; set it back to true to bring tickets back.
Campaign.TRIPS = { enabled = false, max = 5, window = 3 * 3600 }
-- ENDLESS (the old houses' wave runs) opens at this player level (the user, 2026-11-21): below it the PLAY panel's
-- ENDLESS switch is locked and Server/Lobby refuses to create or join an endless lobby
Campaign.ENDLESS_LEVEL = 10
function Campaign.endlessOpen(level: any): boolean return (tonumber(level) or 1) >= Campaign.ENDLESS_LEVEL end
-- "2:41:07" / "41:07"
function Campaign.clock(sec: number): string
	sec = math.max(0, math.floor(sec))
	local h, m, x = sec // 3600, (sec % 3600) // 60, sec % 60
	if h > 0 then return string.format("%d:%02d:%02d", h, m, x) end
	return string.format("%d:%02d", m, x)
end
-- tickets left for a player's attributes (the window may be over already)
function Campaign.ticketsLeft(left: number?, reset: number?, now: number): number
	if not Campaign.TRIPS.enabled then return Campaign.TRIPS.max end
	if (reset or 0) > 0 and now >= (reset :: number) then return Campaign.TRIPS.max end
	return math.clamp(left or Campaign.TRIPS.max, 0, Campaign.TRIPS.max)
end
export type Progress = { [string]: number }

function Campaign.stage(id: string?): Stage?
	return id and stageById[id] or nil
end

-- every building of the map cleared (on any difficulty)
function Campaign.mapDone(progress: Progress, mapId: string): boolean
	local m = mapById[mapId]
	if not m or m.soon or #m.stages == 0 then return false end
	for _, s in m.stages do
		if (progress[s.id] or 0) <= 0 then return false end
	end
	return true
end

-- the first map is always open; any other once the map before it is done
function Campaign.mapOpen(progress: Progress, mapId: string): boolean
	for i, m in List do
		if m.id == mapId then
			if m.soon then return false end
			return i == 1 or Campaign.mapDone(progress, List[i - 1].id)
		end
	end
	return false
end

-- a building is open when its map is and the building before it was cleared
function Campaign.stageOpen(progress: Progress, stageId: string): boolean
	local s = stageById[stageId]
	if not s or not Campaign.mapOpen(progress, s.map) then return false end
	if s.index == 1 then return true end
	local prev = mapById[s.map].stages[s.index - 1]
	return (progress[prev.id] or 0) > 0
end

-- the building after this one (same map), or the first of the next map, or nil
function Campaign.nextStage(stageId: string): Stage?
	local s = stageById[stageId]
	if not s then return nil end
	local m = mapById[s.map]
	if m.stages[s.index + 1] then return m.stages[s.index + 1] end
	for i, mm in List do
		if mm.id == s.map then
			local nm = List[i + 1]
			return nm and not nm.soon and nm.stages[1] or nil
		end
	end
	return nil
end

-- the map's last building (its boss): once it is cleared the run always ends in the park (the result screen offers
-- no NEXT BUILDING / FIGHT AGAIN: the player goes back to buy the next map's jars and potions)
function Campaign.isLast(stageId: string?): boolean
	local s = stageId and stageById[stageId]
	if not s then return false end
	return s.index == #mapById[s.map].stages
end

-- the first building of the player's furthest open map that is not cleared yet (the "next goal"), or nil
function Campaign.goal(progress: Progress): Stage?
	for _, m in List do
		if m.soon or not Campaign.mapOpen(progress, m.id) then continue end
		for _, s in m.stages do
			if (progress[s.id] or 0) <= 0 then return s end
		end
	end
	return nil
end

-- how many buildings of this map are cleared
function Campaign.cleared(progress: Progress, mapId: string): (number, number)
	local m = mapById[mapId]
	if not m then return 0, 0 end
	local n = 0
	for _, s in m.stages do if (progress[s.id] or 0) > 0 then n += 1 end end
	return n, #m.stages
end

-- clean a progress table that came from a save or a JSON attribute
function Campaign.clean(t: any): Progress
	local out: Progress = {}
	if type(t) ~= "table" then return out end
	for id, r in t do
		local n = tonumber(r)
		if type(id) == "string" and stageById[id] and n and n == n then out[id] = math.clamp(math.floor(n), 0, 4) end
	end
	return out
end

return Campaign
