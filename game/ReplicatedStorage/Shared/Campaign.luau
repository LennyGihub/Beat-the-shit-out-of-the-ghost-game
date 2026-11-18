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
export type CMap = { id: string, name: string, desc: string, color: Color3, stages: { Stage }, soon: boolean? }

local function C(r, g, b) return Color3.fromRGB(r, g, b) end

local List: { CMap } = {
	{ id = "Camp", name = "CAMP HOLLOWMERE", color = C(196, 120, 60),
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
	{ id = "Harbor", name = "BLACKWATER HARBOR", color = C(70, 120, 150), soon = true, stages = {},
		desc = "A fishing port in a storm." },
	{ id = "Carnival", name = "MOONLIGHT CARNIVAL", color = C(200, 70, 130), soon = true, stages = {},
		desc = "An abandoned funfair." },
	{ id = "Abbey", name = "THE ASHEN ABBEY", color = C(170, 60, 40), soon = true, stages = {},
		desc = "A cathedral sinking into hell." },
	{ id = "Moon", name = "THE BLACK MOON", color = C(130, 140, 200), soon = true, stages = {},
		desc = "A moon base." },
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
