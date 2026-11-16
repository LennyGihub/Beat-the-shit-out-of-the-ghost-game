-- Player save data: Cash, owned items, next ghost level, kills, settings (volumes + keybinds), and the Robux
-- purchases already granted (Receipts: the last 100 PurchaseIds, so a cash pack is never given twice).
-- Never overwrites a save that failed to load; saves on leave, every 90 s and on shutdown.
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Remotes = require(script.Parent.Remotes)

local Data = {}
local okStore, store = pcall(function() return DSS:GetDataStore("GhostBrawl_v1") end)
local profiles = {} -- [Player] = { loaded = bool, data = table }

local function fresh() return { Cash = 0, Owned = {}, GhostLevel = 1, Kills = 0, Ults = { Rage = true }, Equipped = "Rage", Receipts = {} } end
local MAX_RECEIPTS = 100

-- settings sent by the client: volumes 0..1 and keyboard keybinds (action -> KeyCode / mouse button name)
local BIND_ACTIONS = { Punch = true, Block = true, Lift = true, Ultimate = true, Sprint = true, Drop = true, Use = true, Settings = true }
local MOUSE = { MouseButton1 = true, MouseButton2 = true, MouseButton3 = true }
local function cleanSettings(s: any): { [string]: any }?
	if type(s) ~= "table" then return nil end
	local out = { sfx = 1, music = 1, binds = {} }
	for _, k in { "sfx", "music" } do
		local v = tonumber(s[k])
		if v and v == v then out[k] = math.clamp(math.floor(v * 100 + 0.5) / 100, 0, 1) end
	end
	if type(s.binds) == "table" then
		for action, key in s.binds do
			if BIND_ACTIONS[action] and type(key) == "string" and #key <= 24 then
				local ok = MOUSE[key] or pcall(function() return (Enum.KeyCode :: any)[key] end)
				if ok then out.binds[action] = key end
			end
		end
	end
	return out
end

local function publishSettings(player: Player, data)
	if data.Settings then player:SetAttribute("Settings", HttpService:JSONEncode(data.Settings)) end
	player:SetAttribute("SettingsLoaded", true)
end

local function publish(player)
	local p = profiles[player]
	if not p then return end
	publishSettings(player, p.data)
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
					prof.data.Settings = cleanSettings(res.Settings)
					if type(res.Owned) == "table" then
						for id, v in res.Owned do if type(id) == "string" and v == true then prof.data.Owned[id] = true end end
					end
					if type(res.Receipts) == "table" then
						for _, id in res.Receipts do if type(id) == "string" then table.insert(prof.data.Receipts, id) end end
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

-- returns true once the save went through
function Data.save(player: Player): boolean
	local prof = profiles[player]
	if not prof or not prof.loaded or not okStore then return false end
	local snap = { Cash = prof.data.Cash, GhostLevel = prof.data.GhostLevel, Kills = prof.data.Kills, Owned = table.clone(prof.data.Owned), Ults = table.clone(prof.data.Ults), Equipped = prof.data.Equipped, Settings = prof.data.Settings, Receipts = table.clone(prof.data.Receipts) }
	for i = 1, 3 do
		local ok, err = pcall(function()
			store:UpdateAsync("u_" .. player.UserId, function() return snap end)
		end)
		if ok then return true end
		warn("[Data] save failed (" .. i .. "): " .. tostring(err))
		task.wait(1.5 * i)
	end
	return false
end

-- Robux cash pack (Monetization's ProcessReceipt). "granted" = already given (now or in an earlier session),
-- "saved" = given now and saved, "wait" = can't be done safely yet (save not loaded / save failed): Roblox will
-- retry the receipt later. In Studio (no DataStore) the cash is given without saving, for testing.
function Data.grantCashReceipt(player: Player, purchaseId: string, cash: number): string
	local prof = profiles[player]
	if not prof then return "wait" end
	if table.find(prof.data.Receipts, purchaseId) then return "granted" end
	local studio = game:GetService("RunService"):IsStudio()
	if not prof.loaded and not studio then return "wait" end
	prof.data.Cash += math.floor(cash)
	table.insert(prof.data.Receipts, purchaseId)
	while #prof.data.Receipts > MAX_RECEIPTS do table.remove(prof.data.Receipts, 1) end
	publish(player)
	if studio and not prof.loaded then return "saved" end
	-- the cash and the receipt are saved together: if this fails, the next autosave still carries both, and a
	-- retried receipt finds the PurchaseId and is not given twice
	return Data.save(player) and "saved" or "wait"
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

-- maps are stored in Owned as "Map_<id>" (the Mansion is free)
function Data.ownsMap(player: Player, id: string): boolean
	if id == "Mansion" then return true end
	local d = Data.get(player); return d ~= nil and d.Owned["Map_" .. id] == true
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
	local last = {} :: { [Player]: number }
	Remotes.SaveSettings.OnServerEvent:Connect(function(p, s)
		if os.clock() - (last[p] or 0) < 0.4 then return end
		last[p] = os.clock()
		local prof = profiles[p]
		local clean = cleanSettings(s)
		if prof and clean then
			prof.data.Settings = clean
			publishSettings(p, prof.data)
		end
	end)
	Players.PlayerRemoving:Connect(function(p) last[p] = nil end)
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
