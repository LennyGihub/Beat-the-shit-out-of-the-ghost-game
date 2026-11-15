-- Player save data: Cash, owned items, next ghost level, kills.
-- Never overwrites a save that failed to load; saves on leave, every 90 s and on shutdown.
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local Data = {}
local okStore, store = pcall(function() return DSS:GetDataStore("GhostBrawl_v1") end)
local profiles = {} -- [Player] = { loaded = bool, data = table }

local function fresh() return { Cash = 0, Owned = {}, GhostLevel = 1, Kills = 0, Ults = { Rage = true }, Equipped = "Rage" } end

local function publish(player)
	local p = profiles[player]
	if not p then return end
	player:SetAttribute("Cash", p.data.Cash)
	player:SetAttribute("GhostLevel", p.data.GhostLevel)
	local owned = {}
	for id in p.data.Owned do table.insert(owned, id) end
	player:SetAttribute("Owned", table.concat(owned, ","))
	local ults = {}
	for id in p.data.Ults do table.insert(ults, id) end
	player:SetAttribute("OwnedUlts", table.concat(ults, ","))
	player:SetAttribute("EquippedUlt", p.data.Equipped)
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		(ls :: any).Cash.Value = p.data.Cash;
		(ls :: any).Kills.Value = p.data.Kills
	end
end

function Data.load(player: Player)
	local ls = Instance.new("Folder"); ls.Name = "leaderstats"
	local c = Instance.new("IntValue"); c.Name = "Cash"; c.Parent = ls
	local k = Instance.new("IntValue"); k.Name = "Kills"; k.Parent = ls
	ls.Parent = player
	local prof = { loaded = false, data = fresh() }
	profiles[player] = prof
	if okStore then
		local key = "u_" .. player.UserId
		for i = 1, 3 do
			local ok, res = pcall(function() return store:GetAsync(key) end)
			if ok then
				prof.loaded = true
				if type(res) == "table" then
					prof.data.Cash = math.max(0, math.floor(tonumber(res.Cash) or 0))
					prof.data.GhostLevel = math.max(1, math.floor(tonumber(res.GhostLevel) or 1))
					prof.data.Kills = math.max(0, math.floor(tonumber(res.Kills) or 0))
					if type(res.Ults) == "table" then
						for id, v in res.Ults do if type(id) == "string" and v == true then prof.data.Ults[id] = true end end
					end
					if type(res.Equipped) == "string" and prof.data.Ults[res.Equipped] then prof.data.Equipped = res.Equipped end
					if type(res.Owned) == "table" then
						for id, v in res.Owned do if type(id) == "string" and v == true then prof.data.Owned[id] = true end end
					end
				end
				break
			end
			warn("[Data] load failed (" .. i .. "): " .. tostring(res))
			task.wait(1.5 * i)
		end
	end
	if not prof.loaded then warn("[Data] playing without saving for " .. player.Name) end
	publish(player)
	return prof
end

function Data.save(player: Player)
	local prof = profiles[player]
	if not prof or not prof.loaded or not okStore then return end
	local snap = { Cash = prof.data.Cash, GhostLevel = prof.data.GhostLevel, Kills = prof.data.Kills, Owned = table.clone(prof.data.Owned), Ults = table.clone(prof.data.Ults), Equipped = prof.data.Equipped }
	for i = 1, 3 do
		local ok, err = pcall(function()
			store:UpdateAsync("u_" .. player.UserId, function() return snap end)
		end)
		if ok then return end
		warn("[Data] save failed (" .. i .. "): " .. tostring(err))
		task.wait(1.5 * i)
	end
end

function Data.get(player: Player) local p = profiles[player]; return p and p.data end

function Data.addCash(player: Player, n: number)
	local d = Data.get(player); if not d then return end
	d.Cash += math.floor(n); publish(player)
end

function Data.spend(player: Player, n: number): boolean
	local d = Data.get(player)
	if not d or d.Cash < n then return false end
	d.Cash -= n; publish(player)
	return true
end

function Data.own(player: Player, id: string)
	local d = Data.get(player); if not d then return end
	d.Owned[id] = true; publish(player)
end

function Data.owns(player: Player, id: string): boolean
	local d = Data.get(player); return d ~= nil and d.Owned[id] == true
end

function Data.ownsUlt(player: Player, id: string): boolean
	local d = Data.get(player); return d ~= nil and d.Ults[id] == true
end

function Data.ownUlt(player: Player, id: string)
	local d = Data.get(player); if not d then return end
	d.Ults[id] = true; publish(player)
end

function Data.equipUlt(player: Player, id: string): boolean
	local d = Data.get(player)
	if not d or not d.Ults[id] then return false end
	d.Equipped = id; publish(player)
	return true
end

function Data.equipped(player: Player): string
	local d = Data.get(player); return d and d.Equipped or "Rage"
end

function Data.winGhost(player: Player, level: number)
	local d = Data.get(player); if not d then return end
	d.Kills += 1
	d.GhostLevel = math.max(d.GhostLevel, level + 1)
	publish(player)
end

function Data.start()
	Players.PlayerRemoving:Connect(function(p)
		Data.save(p)
		profiles[p] = nil
	end)
	game:BindToClose(function()
		local n = 0
		for p in profiles do
			n += 1
			task.spawn(function() Data.save(p); n -= 1 end)
		end
		local t = os.clock()
		while n > 0 and os.clock() - t < 25 do task.wait(0.2) end
	end)
	task.spawn(function()
		while true do
			task.wait(90)
			for p in profiles do task.spawn(Data.save, p) end
		end
	end)
end

return Data
