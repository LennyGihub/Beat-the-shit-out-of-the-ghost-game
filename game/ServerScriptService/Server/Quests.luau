--!strict
-- Quests (server): daily quests (3 per player per UTC day) and permanent achievements (Shared/Quests), saved with
-- the player's data (data.Quests = { day, daily = { { id, p, c } }, life = { [stat] = n }, ach = { [id] = true } }).
-- The game calls Quests.add(player, stat, n); max-type stats (wave, combo) keep the best value instead.
-- The client sees progress in the player attribute "Quests" (JSON) and claims with Remotes.Quest("claim", id).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Q = require(RS.Shared.Quests)
local Data = require(script.Parent.Data)
local Remotes = require(script.Parent.Remotes)

local Quests = {}
local dirty = {} :: { [Player]: boolean }
local lastClaim = {} :: { [Player]: number }

local function today(): string return os.date("!%Y-%m-%d") :: string end

-- seconds until the dailies reset (midnight UTC)
local function untilReset(): number
	local t = os.time()
	return 86400 - (t % 86400)
end

-- the player's quest save, cleaned up, with today's dailies (a new day = 3 new ones, the same pick all day)
local function state(p: Player): any?
	local d = Data.get(p)
	if not d then return nil end
	local s = d.Quests
	if type(s) ~= "table" then s = {}; d.Quests = s end
	if type(s.life) ~= "table" then s.life = {} end
	if type(s.ach) ~= "table" then s.ach = {} end
	local valid = type(s.daily) == "table" and #s.daily == Q.dailyCount
	if valid then
		for _, e in s.daily do
			if type(e) ~= "table" or not Q.byId[e.id] or type(e.p) ~= "number" then valid = false end
		end
	end
	if s.day ~= today() or not valid then
		local rng = Random.new(p.UserId + (tonumber((today():gsub("-", ""))) or 0))
		local pool = table.clone(Q.daily)
		local picked = {}
		for _ = 1, math.min(Q.dailyCount, #pool) do
			local x = table.remove(pool, rng:NextInteger(1, #pool))
			table.insert(picked, { id = x.id, p = 0, c = false })
		end
		s.day = today()
		s.daily = picked
	end
	return s
end

-- how far the player is on a quest
local function progress(p: Player, s: any, quest: Q.Quest, entry: any?): number
	if entry then return entry.p end
	local d = Data.get(p)
	if quest.stat == "maps" and d then
		local n = 1 -- the Mansion
		for id in d.Owned do if string.sub(id, 1, 4) == "Map_" then n += 1 end end
		return n
	elseif quest.stat == "ults" and d then
		local n = 0
		for _ in d.Ults do n += 1 end
		return n
	end
	return tonumber(s.life[quest.stat]) or 0
end

local function publish(p: Player)
	local s = state(p)
	if not s then return end
	local daily = {}
	for _, e in s.daily do
		local quest = Q.byId[e.id]
		table.insert(daily, { id = e.id, p = math.min(e.p, quest.goal), c = e.c == true })
	end
	local ach = {}
	for _, quest in Q.achievements do
		table.insert(ach, { id = quest.id, p = math.min(progress(p, s, quest), quest.goal), c = s.ach[quest.id] == true })
	end
	p:SetAttribute("Quests", HttpService:JSONEncode({ daily = daily, ach = ach, reset = os.time() + untilReset() }))
end

-- count something the player did (n = how many, or the value for max-type stats)
function Quests.add(p: Player, stat: string, n: number?)
	local s = state(p)
	if not s or not p:GetAttribute("InMatch") then return end
	local v = n or 1
	local isMax = Q.maxStats[stat] == true
	local before = tonumber(s.life[stat]) or 0
	local after = isMax and math.max(before, v) or before + v
	s.life[stat] = after
	for _, e in s.daily do
		local quest = Q.byId[e.id]
		if quest.stat == stat and not e.c and e.p < quest.goal then
			e.p = math.min(quest.goal, isMax and math.max(e.p, v) or e.p + v)
			if e.p >= quest.goal then
				Remotes.Fx:FireClient(p, "Toast", "QUEST DONE: " .. quest.name .. " - claim $" .. quest.reward .. " in the lobby", true)
			end
		end
	end
	for _, quest in Q.achievements do
		if quest.stat == stat and not s.ach[quest.id] and before < quest.goal and after >= quest.goal then
			Remotes.Fx:FireClient(p, "Toast", "ACHIEVEMENT: " .. quest.name .. " - claim $" .. quest.reward .. " in the lobby", true)
		end
	end
	dirty[p] = true
end

local function claim(p: Player, id: any)
	if type(id) ~= "string" then return end
	local now = os.clock()
	if now - (lastClaim[p] or 0) < 0.3 then return end
	lastClaim[p] = now
	local quest = Q.byId[id]
	local s = state(p)
	if not quest or not s then return end
	local entry = nil
	for _, e in s.daily do if e.id == id then entry = e end end
	local isDaily = string.sub(id, 1, 2) == "d_"
	if isDaily then
		if not entry or entry.c or entry.p < quest.goal then return end
		entry.c = true
	else
		if s.ach[id] or progress(p, s, quest) < quest.goal then return end
		s.ach[id] = true
	end
	Data.addCash(p, quest.reward)
	task.spawn(Data.save, p)
	Remotes.Fx:FireClient(p, "Toast", "+$" .. quest.reward .. "  " .. quest.name, true)
	publish(p)
end

-- after Data.load (Main): today's dailies + the first publish
function Quests.setup(p: Player)
	if not Data.get(p) then return end
	publish(p)
	-- owning maps / ultimates counts for the achievements
	for _, a in { "Owned", "OwnedUlts" } do
		p:GetAttributeChangedSignal(a):Connect(function() dirty[p] = true end)
	end
end

function Quests.start()
	Remotes.Quest.OnServerEvent:Connect(function(p, action, id)
		if action == "claim" then claim(p, id) end
	end)
	Players.PlayerRemoving:Connect(function(p) dirty[p] = nil; lastClaim[p] = nil end)
	-- progress goes out at most twice a second; the day rolls over for players who stay online
	local lastDay = today()
	task.spawn(function()
		while true do
			task.wait(0.5)
			local day = today()
			for _, p in Players:GetPlayers() do
				if dirty[p] or day ~= lastDay then
					dirty[p] = nil
					publish(p)
				end
			end
			lastDay = day
		end
	end)
end

return Quests
