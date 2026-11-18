-- Player save data: Cash, owned items, next ghost level, kills, the equipped ultimate (and the second one of the
-- Double Ultimate pass, Equipped2), settings (volumes + keybinds), and the Robux
-- purchases already granted (Receipts: the last 100 PurchaseIds, so a cash pack is never given twice).
-- Long-term goals (Server/Bestiary): Bestiary (monster key -> times beaten), Badges (set of unlocked badge ids),
-- Nightmare (monsters beaten on NIGHTMARE). XP: the player's total XP (Shared/Levels: the level and its title).
-- Campaign: stage id -> best difficulty rank cleared (Shared/Campaign). Forms: the fist / body forms got from Doc
-- Mercy's ectoplasm and Mother Moth's potions (id -> true), FormStim / FormPotion = the ones worn (Shared/Forms).
-- Never overwrites a save that failed to load; saves on leave, every 90 s and on shutdown.
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Remotes = require(script.Parent.Remotes)
local Levels = require(game:GetService("ReplicatedStorage").Shared.Levels)
local Campaign = require(game:GetService("ReplicatedStorage").Shared.Campaign)
local Forms = require(game:GetService("ReplicatedStorage").Shared.Forms)

local Data = {}
-- v2 (2026-11-17): every save was wiped before release (the testers' saves held gifted cash) by starting a new store.
-- The old saves are still in "GhostBrawl_v1"; nothing reads them.
local okStore, store = pcall(function() return DSS:GetDataStore("GhostBrawl_v2") end)
local profiles = {} -- [Player] = { loaded = bool, data = table }

local function fresh()
	return { Cash = 0, Owned = {}, GhostLevel = 1, Kills = 0, Ults = { Rage = true }, Equipped = "Rage", Receipts = {},
		Bestiary = {} :: { [string]: number }, Badges = {} :: { [string]: boolean }, Nightmare = 0, XP = 0,
		Campaign = {} :: { [string]: number }, Forms = {} :: { [string]: boolean }, FormStim = nil :: string?, FormPotion = nil :: string?,
		Tutorial = false } -- Tutorial = the tutorial was offered (taken or refused): the lobby's popup is not shown again
end
local MAX_RECEIPTS = 100

-- settings sent by the client: volumes 0..1 and keyboard keybinds (action -> KeyCode / mouse button name)
local BIND_ACTIONS = { Punch = true, Block = true, Lift = true, Ultimate = true, Sprint = true, Drop = true, Use = true, Settings = true, SwapUlt = true, Hints = true }
local MOUSE = { MouseButton1 = true, MouseButton2 = true, MouseButton3 = true }
local function cleanSettings(s: any): { [string]: any }?
	if type(s) ~= "table" then return nil end
	local out = { sfx = 1, music = 1, binds = {}, hideKeys = s.hideKeys == true } -- hideKeys: controls reminder hidden (H)
	-- fx: particle amount (low-end computers)
	out.fx = (s.fx == "low" or s.fx == "high") and s.fx or "medium"
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
	player:SetAttribute("EquippedUlt2", p.data.Equipped2 or "")
	-- long-term goals: the bestiary counts (JSON) and the unlocked badges
	player:SetAttribute("Bestiary", HttpService:JSONEncode(p.data.Bestiary))
	local badges = {}
	for id in p.data.Badges do table.insert(badges, id) end
	table.sort(badges)
	player:SetAttribute("Badges", table.concat(badges, ","))
	player:SetAttribute("Kills", p.data.Kills)
	player:SetAttribute("NightmareKills", p.data.Nightmare)
	player:SetAttribute("XP", p.data.XP)
	player:SetAttribute("Level", (Levels.of(p.data.XP))) -- (over the head in the lobby: Client/NameTags)
	player:SetAttribute("TutorialSeen", p.data.Tutorial == true) -- false: Client/TutorialUI offers the tutorial
	-- the campaign (JSON: stage id -> best difficulty rank) and the forms (owned list, worn ones)
	player:SetAttribute("Campaign", HttpService:JSONEncode(p.data.Campaign))
	local forms = {}
	for id in p.data.Forms do table.insert(forms, id) end
	table.sort(forms)
	player:SetAttribute("Forms", table.concat(forms, ","))
	player:SetAttribute("FormStim", p.data.FormStim or "")
	player:SetAttribute("FormPotion", p.data.FormPotion or "")
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
					if type(res.Equipped2) == "string" and prof.data.Ults[res.Equipped2] and res.Equipped2 ~= prof.data.Equipped then
						prof.data.Equipped2 = res.Equipped2
					end
					prof.data.Settings = cleanSettings(res.Settings)
					if type(res.Owned) == "table" then
						for id, v in res.Owned do if type(id) == "string" and v == true then prof.data.Owned[id] = true end end
					end
					if type(res.Quests) == "table" then prof.data.Quests = res.Quests end -- cleaned up by Server/Quests
					if type(res.Bestiary) == "table" then
						for key, n in res.Bestiary do
							local c = tonumber(n)
							if type(key) == "string" and #key <= 40 and c and c == c and c > 0 then prof.data.Bestiary[key] = math.floor(c) end
						end
					end
					if type(res.Badges) == "table" then
						for id, v in res.Badges do if type(id) == "string" and #id <= 40 and v == true then prof.data.Badges[id] = true end end
					end
					prof.data.Nightmare = math.max(0, math.floor(tonumber(res.Nightmare) or 0))
					prof.data.XP = math.max(0, math.floor(tonumber(res.XP) or 0))
					prof.data.Tutorial = res.Tutorial == true
					prof.data.Campaign = Campaign.clean(res.Campaign)
					if type(res.Forms) == "table" then
						for id, v in res.Forms do if type(id) == "string" and Forms.byId[id] and v == true then prof.data.Forms[id] = true end end
					end
					for _, key in { "FormStim", "FormPotion" } do
						local id = res[key]
						local fm = type(id) == "string" and Forms.byId[id] or nil
						if fm and prof.data.Forms[fm.id] and fm.kind == (key == "FormStim" and "stim" or "potion") then prof.data[key] = fm.id end
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
	local snap = { Cash = prof.data.Cash, GhostLevel = prof.data.GhostLevel, Kills = prof.data.Kills, Owned = table.clone(prof.data.Owned), Ults = table.clone(prof.data.Ults), Equipped = prof.data.Equipped, Equipped2 = prof.data.Equipped2, Settings = prof.data.Settings, Receipts = table.clone(prof.data.Receipts),
		Bestiary = table.clone(prof.data.Bestiary), Badges = table.clone(prof.data.Badges), Nightmare = prof.data.Nightmare, XP = prof.data.XP,
		Tutorial = prof.data.Tutorial == true,
		Campaign = table.clone(prof.data.Campaign), Forms = table.clone(prof.data.Forms), FormStim = prof.data.FormStim, FormPotion = prof.data.FormPotion,
		Quests = prof.data.Quests and HttpService:JSONDecode(HttpService:JSONEncode(prof.data.Quests)) or nil }
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
-- the save changed outside this module (Server/Bestiary): send the player's attributes again
function Data.refresh(player: Player) publish(player) end
-- the save loaded (false: playing without saving, e.g. in Studio)
function Data.loaded(player: Player): boolean local p = profiles[player]; return p ~= nil and p.loaded end

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

-- slot 1 = the ultimate that fires; slot 2 = the spare one of the Double Ultimate pass (the caller checks the pass).
-- An ultimate is never in both slots: equipping the other slot's ultimate swaps the two.
function Data.equipUlt(player: Player, id: string, slot: number?): boolean
	local d = Data.get(player)
	if not d or not d.Ults[id] then return false end
	if slot == 2 then
		if d.Equipped == id then
			if not d.Equipped2 then return false end -- slot 1 can't be left empty
			d.Equipped, d.Equipped2 = d.Equipped2, d.Equipped
		else
			d.Equipped2 = id
		end
	elseif d.Equipped2 == id then
		d.Equipped, d.Equipped2 = d.Equipped2, d.Equipped
	else
		d.Equipped = id
	end
	publish(player)
	return true
end

-- Double Ultimate: the spare ultimate becomes the one that fires (and the other way round)
function Data.swapUlts(player: Player): boolean
	local d = Data.get(player)
	if not d or not d.Equipped2 or not d.Ults[d.Equipped2] then return false end
	d.Equipped, d.Equipped2 = d.Equipped2, d.Equipped
	publish(player)
	return true
end

function Data.equipped(player: Player): string
	local d = Data.get(player); return d and d.Equipped or "Rage"
end

-- the tutorial was offered to this player (taken or refused)
function Data.setTutorialSeen(player: Player)
	local d = Data.get(player)
	if d and not d.Tutorial then d.Tutorial = true; publish(player) end
end

-- XP for a run (Server/Run.payout): returns the level before and after
function Data.addXP(player: Player, n: number): (number, number)
	local d = Data.get(player)
	if not d then return 1, 1 end
	local before = (Levels.of(d.XP))
	d.XP += math.max(0, math.floor(n))
	publish(player)
	return before, (Levels.of(d.XP))
end

-- CAMPAIGN: a building cleared on a difficulty (rank 1..4). Returns true the first time it is cleared at all.
function Data.clearStage(player: Player, stageId: string, rank: number): boolean
	local d = Data.get(player)
	if not d or not Campaign.stage(stageId) then return false end
	local before = d.Campaign[stageId] or 0
	d.Campaign[stageId] = math.max(before, math.clamp(math.floor(rank), 1, 4))
	publish(player)
	return before <= 0
end
function Data.campaign(player: Player): { [string]: number }
	local d = Data.get(player)
	return d and d.Campaign or {}
end

-- FORMS: add one to the collection (true = it is new)
function Data.addForm(player: Player, id: string): boolean
	local d = Data.get(player)
	if not d or not Forms.byId[id] then return false end
	local new = not d.Forms[id]
	d.Forms[id] = true
	publish(player)
	return new
end
function Data.ownsForm(player: Player, id: string): boolean
	local d = Data.get(player)
	return d ~= nil and d.Forms[id] == true
end
-- wear an owned form (its kind's slot)
function Data.equipForm(player: Player, id: string): boolean
	local d = Data.get(player)
	local fm = Forms.byId[id]
	if not d or not fm or not d.Forms[id] then return false end
	if fm.kind == "stim" then d.FormStim = id else d.FormPotion = id end
	publish(player)
	return true
end
function Data.formOf(player: Player, kind: string): string?
	local d = Data.get(player)
	if not d then return nil end
	return kind == "stim" and d.FormStim or d.FormPotion
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
