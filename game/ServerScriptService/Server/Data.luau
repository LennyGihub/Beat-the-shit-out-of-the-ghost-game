-- Player save data: Cash, owned items, next ghost level, kills, the equipped ultimate (and the second one of the
-- Double Ultimate pass, Equipped2), settings (volumes + keybinds), and the Robux
-- purchases already granted (Receipts: the last 100 PurchaseIds, so a cash pack is never given twice).
-- Long-term goals (Server/Bestiary): Bestiary (monster key -> times beaten), Badges (set of unlocked badge ids),
-- Nightmare (monsters beaten on NIGHTMARE). XP: the player's total XP (Shared/Levels: the level and its title).
-- Campaign: stage id -> best difficulty rank cleared (Shared/Campaign). Forms: the fist / body forms got from Doc
-- Mercy's ectoplasm and Mother Moth's potions (id -> true), FormStim / FormPotion = the ones worn (Shared/Forms).
-- Offline: the jars / potions opening by themselves (Server/Forms: a queue of vial ids per kind + when the first one
-- started, and the opening time towards the RARE+ guarantee). Trips: train tickets used ({ n, reset }: Campaign.TRIPS).
-- Codes: the codes this player already redeemed (normalized code -> true; Server/Codes).
-- A cleared map brings the player's level up to what that map's best jar / potion needs (Data.mapLevel).
-- Never overwrites a save that failed to load; saves on leave, every 90 s and on shutdown.
local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Remotes = require(script.Parent.Remotes)
local Guard = require(script.Parent.Guard)
local Levels = require(game:GetService("ReplicatedStorage").Shared.Levels)
local Campaign = require(game:GetService("ReplicatedStorage").Shared.Campaign)
local Forms = require(game:GetService("ReplicatedStorage").Shared.Forms)
local PatchNotes = require(game:GetService("ReplicatedStorage").Shared.PatchNotes)
local Analytics = require(script.Parent.Analytics)

local Data = {}
-- THE TUTORIAL'S VERSION: a player whose save has seen an older one (TutorialV below this) gets the current one once,
-- from the black READY screen (Client/TutorialUI), even if they played the game before. 2 = the intro in the
-- Mansion's TV room (2026-11-22, the user: "anyone playing the game from now on will get the new tutorial once").
-- Raise it to show a new tutorial to everyone again.
local TUTORIAL_VERSION = 2
-- v2 (2026-11-17): every save was wiped before release (the testers' saves held gifted cash) by starting a new store.
-- The old saves are still in "GhostBrawl_v1"; nothing reads them.
local okStore, store = pcall(function() return DSS:GetDataStore("GhostBrawl_v2") end)
local profiles = {} -- [Player] = { loaded = bool, data = table }

local function fresh()
	return { Cash = 0, Owned = {}, GhostLevel = 1, Kills = 0, Ults = { Rage = true }, Equipped = "Rage", Receipts = {},
		Bestiary = {} :: { [string]: number }, Badges = {} :: { [string]: boolean }, Nightmare = 0, XP = 0,
		Campaign = {} :: { [string]: number }, Forms = {} :: { [string]: boolean }, FormStim = nil :: string?, FormPotion = nil :: string?,
		FormN = {} :: { [string]: number }, -- copies of each owned form (missing = 1): duplicates can be traded (Server/Trade)
		Tutorial = false, -- Tutorial = a tutorial was offered once (taken or refused); TutorialV = the version of the last one (TUTORIAL_VERSION)
		TutorialV = 0,
		NotesV = PatchNotes.version, -- the last patch notes this player saw (a new save: the current ones, nothing to show)
		Trips = { n = 0, reset = 0 },
		FormTut = false, FormTutCash = false, -- the jars / potions tutorial (Client/FormTutorial): done / its starter cash given
		Codes = {} :: { [string]: boolean }, -- the codes already redeemed (Server/Codes)
		Onb = 0 :: number?, -- the onboarding funnel's last step logged (Server/Analytics); nil = a save from before it (not in the funnel)
		Ref = nil :: { by: number, t: number, done: boolean }?, -- who invited this (brand-new) save, its play seconds, rewarded (Server/Share)
		Offline = { stim = { q = {} :: { string }, t = 0 }, potion = { q = {} :: { string }, t = 0 }, pity = 0 } }
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
	out.fxSet = s.fxSet == true -- the player picked it (else a phone starts on low: Client/Settings)
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
	player:SetAttribute("TutorialSeen", (p.data.TutorialV or 0) >= TUTORIAL_VERSION) -- false: Client/TutorialUI starts the tutorial
	player:SetAttribute("NotesV", p.data.NotesV or 0) -- below PatchNotes.version: Client/PatchNotesUI opens WHAT'S NEW once
	-- the campaign (JSON: stage id -> best difficulty rank) and the forms (owned list, worn ones)
	player:SetAttribute("Campaign", HttpService:JSONEncode(p.data.Campaign))
	local forms = {}
	for id in p.data.Forms do table.insert(forms, id) end
	table.sort(forms)
	player:SetAttribute("Forms", table.concat(forms, ","))
	-- copies of the forms owned more than once (JSON id -> n; Client/TradeUI, SellerUI)
	local copies = {}
	for id, n in p.data.FormN do if p.data.Forms[id] and n > 1 then copies[id] = n end end
	player:SetAttribute("FormN", HttpService:JSONEncode(copies))
	player:SetAttribute("FormStim", p.data.FormStim or "")
	player:SetAttribute("FormPotion", p.data.FormPotion or "")
	-- train tickets (the client counts the refill down itself)
	player:SetAttribute("TripsLeft", Campaign.TRIPS.max - p.data.Trips.n)
	player:SetAttribute("TripsReset", p.data.Trips.reset)
	player:SetAttribute("FormTutDone", p.data.FormTut == true)
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
	local prof = { loaded = false, data = fresh(), isNew = false }
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
					prof.data.TutorialV = math.max(0, math.floor(tonumber(res.TutorialV) or 0)) -- (older saves: 0, the new tutorial once)
					prof.data.NotesV = math.max(0, math.floor(tonumber(res.NotesV) or 0)) -- (a save from before the patch notes: 0, they show once)
					prof.data.Campaign = Campaign.clean(res.Campaign)
					if type(res.Forms) == "table" then
						for id, v in res.Forms do if type(id) == "string" and Forms.byId[id] and v == true then prof.data.Forms[id] = true end end
					end
					if type(res.FormN) == "table" then
						for id, v in res.FormN do
							local n = tonumber(v)
							if type(id) == "string" and prof.data.Forms[id] and n and n == n and n > 1 then prof.data.FormN[id] = math.min(math.floor(n), 1e6) end
						end
					end
					for _, key in { "FormStim", "FormPotion" } do
						local id = res[key]
						local fm = type(id) == "string" and Forms.byId[id] or nil
						if fm and prof.data.Forms[fm.id] and fm.kind == (key == "FormStim" and "stim" or "potion") then prof.data[key] = fm.id end
					end
					prof.data.FormTut = res.FormTut == true
					if type(res.Codes) == "table" then
						for code, v in res.Codes do if type(code) == "string" and #code <= 40 and v == true then prof.data.Codes[code] = true end end
					end
					prof.data.FormTutCash = res.FormTutCash == true
					if type(res.Ref) == "table" and tonumber(res.Ref.by) then
						prof.data.Ref = { by = math.floor(tonumber(res.Ref.by) :: number), t = math.max(0, math.floor(tonumber(res.Ref.t) or 0)), done = res.Ref.done == true }
					end
					local onb = tonumber(res.Onb)
					prof.data.Onb = (onb and onb == onb) and math.clamp(math.floor(onb), 0, 100) or nil -- (older saves: nil)
					if type(res.Trips) == "table" then
						prof.data.Trips.n = math.clamp(math.floor(tonumber(res.Trips.n) or 0), 0, Campaign.TRIPS.max)
						prof.data.Trips.reset = math.max(0, math.floor(tonumber(res.Trips.reset) or 0))
					end
					if type(res.Offline) == "table" then
						local o = prof.data.Offline
						for _, kind in { "stim", "potion" } do
							local src = res.Offline[kind]
							if type(src) == "table" and type(src.q) == "table" then
								for _, id in src.q do
									local v = type(id) == "string" and Forms.vialById[id] or nil
									if v and v.kind == kind and #o[kind].q < Forms.OFFLINE.maxQueue then table.insert(o[kind].q, id) end
								end
								o[kind].t = math.max(0, math.floor(tonumber(src.t) or 0))
							end
						end
						o.pity = math.max(0, math.floor(tonumber(res.Offline.pity) or 0))
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
	-- a brand-new save: loaded with nothing stored yet (Studio without DataStore: always)
	prof.isNew = prof.data.Onb == 0 and (prof.loaded or game:GetService("RunService"):IsStudio())
	-- a save that failed to load is not a new player: kept out of the onboarding funnel (Studio, no DataStore: in it)
	if not prof.loaded and not game:GetService("RunService"):IsStudio() then prof.data.Onb = nil end
	Data.mapLevel(player) -- (an older save may have cleared a map before this rule)
	publish(player)
	Analytics.joined(player)
	return prof
end

-- returns true once the save went through
function Data.save(player: Player): boolean
	local prof = profiles[player]
	if not prof or not prof.loaded or not okStore then return false end
	local snap = { Cash = prof.data.Cash, GhostLevel = prof.data.GhostLevel, Kills = prof.data.Kills, Owned = table.clone(prof.data.Owned), Ults = table.clone(prof.data.Ults), Equipped = prof.data.Equipped, Equipped2 = prof.data.Equipped2, Settings = prof.data.Settings, Receipts = table.clone(prof.data.Receipts),
		Bestiary = table.clone(prof.data.Bestiary), Badges = table.clone(prof.data.Badges), Nightmare = prof.data.Nightmare, XP = prof.data.XP,
		Tutorial = prof.data.Tutorial == true, TutorialV = prof.data.TutorialV or 0, NotesV = prof.data.NotesV or 0, Onb = prof.data.Onb,
		Ref = prof.data.Ref and table.clone(prof.data.Ref) or nil,
		Campaign = table.clone(prof.data.Campaign), Forms = table.clone(prof.data.Forms), FormStim = prof.data.FormStim, FormPotion = prof.data.FormPotion,
		FormN = table.clone(prof.data.FormN),
		Trips = table.clone(prof.data.Trips), FormTut = prof.data.FormTut == true, FormTutCash = prof.data.FormTutCash == true,
		Codes = table.clone(prof.data.Codes),
		Offline = { stim = { q = table.clone(prof.data.Offline.stim.q), t = prof.data.Offline.stim.t },
			potion = { q = table.clone(prof.data.Offline.potion.q), t = prof.data.Offline.potion.t }, pity = prof.data.Offline.pity },
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
	Analytics.cash(player, "Source", math.floor(cash), prof.data.Cash, "IAP", "CashPack" .. math.floor(cash))
	table.insert(prof.data.Receipts, purchaseId)
	while #prof.data.Receipts > MAX_RECEIPTS do table.remove(prof.data.Receipts, 1) end
	publish(player)
	if studio and not prof.loaded then return "saved" end
	-- the cash and the receipt are saved together: if this fails, the next autosave still carries both, and a
	-- retried receipt finds the PurchaseId and is not given twice
	return Data.save(player) and "saved" or "wait"
end

function Data.get(player: Player) local p = profiles[player]; return p and p.data end
-- the onboarding funnel's step lives in the save (Server/Analytics can't require Data: Data requires it)
Analytics.bind(function(p: Player): number?
	local d = profiles[p]
	return d and d.data.Onb or nil
end, function(p: Player, n: number)
	local d = profiles[p]
	if d and d.data.Onb ~= nil then d.data.Onb = n end
end)
-- the save changed outside this module (Server/Bestiary): send the player's attributes again
function Data.refresh(player: Player) publish(player) end
-- a brand-new save (no save existed before this session; Server/Share)
function Data.isNew(player: Player): boolean local p = profiles[player]; return p ~= nil and p.isNew == true end
-- the save loaded (false: playing without saving, e.g. in Studio)
function Data.loaded(player: Player): boolean local p = profiles[player]; return p ~= nil and p.loaded end

-- tx / sku: why, for the economy analytics (Server/Analytics.cash: tx = Gameplay, TimedReward, Shop, Trade...)
function Data.addCash(player: Player, n: number, tx: string?, sku: string?)
	local d = Data.get(player); if not d then return end
	d.Cash += math.floor(n); publish(player)
	Analytics.cash(player, n >= 0 and "Source" or "Sink", math.abs(math.floor(n)), d.Cash, tx or "Gameplay", sku)
end

function Data.spend(player: Player, n: number, tx: string?, sku: string?): boolean
	local d = Data.get(player)
	if not d or d.Cash < n then return false end
	d.Cash -= n; publish(player)
	Analytics.cash(player, "Sink", n, d.Cash, tx or "Shop", sku)
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

-- the current tutorial was offered to this player (taken or refused): it never starts by itself again (saved at
-- once, so leaving straight after READY still counts)
function Data.setTutorialSeen(player: Player)
	local d = Data.get(player)
	if d and (d.TutorialV or 0) < TUTORIAL_VERSION then
		d.Tutorial = true
		d.TutorialV = TUTORIAL_VERSION
		publish(player)
		task.spawn(Data.save, player)
	end
end
-- the patch notes (Shared/PatchNotes): this player has read the current ones / admin "notes reset" shows them again
function Data.notesSeen(player: Player)
	local d = Data.get(player)
	if d and (d.NotesV or 0) < PatchNotes.version then
		d.NotesV = PatchNotes.version
		publish(player)
		task.spawn(Data.save, player)
	end
end
function Data.resetNotes(player: Player)
	local d = Data.get(player)
	if d then d.NotesV = 0; publish(player) end
end

-- admin "tutorial reset": as if the current tutorial had never been seen (it starts on the next join)
function Data.resetTutorial(player: Player)
	local d = Data.get(player)
	if d then d.TutorialV = 0; publish(player) end
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
-- A CLEARED MAP gives the level its jars / potions need: the player's XP is raised to the level of the best jar /
-- potion of every map they have cleared (Forms.topLevel). Returns the level before and after.
function Data.mapLevel(player: Player): (number, number)
	local d = Data.get(player)
	if not d then return 1, 1 end
	local before = (Levels.of(d.XP))
	local want = 1
	for _, m in Campaign.list do
		if Campaign.mapDone(d.Campaign, m.id) then want = math.max(want, Forms.topLevel(m.id)) end
	end
	if before < want then
		d.XP = math.max(d.XP, Levels.total(want))
		publish(player)
	end
	return before, (Levels.of(d.XP))
end

-- TRAIN TICKETS (Campaign.TRIPS): how many are left and when they come back (unix, 0 = the window has not started)
local function tripWindow(d: any)
	if d.Trips.reset > 0 and os.time() >= d.Trips.reset then d.Trips.n = 0; d.Trips.reset = 0 end
end
function Data.tripsLeft(player: Player): (number, number)
	if not Campaign.TRIPS.enabled then return Campaign.TRIPS.max, 0 end -- (tickets switched off: Campaign.TRIPS.enabled)
	local d = Data.get(player)
	if not d then return 0, 0 end
	tripWindow(d)
	return Campaign.TRIPS.max - d.Trips.n, d.Trips.reset
end
-- one train trip: false when no ticket is left
function Data.useTrip(player: Player): boolean
	if not Campaign.TRIPS.enabled then return true end -- (tickets switched off: every trip is free)
	local d = Data.get(player)
	if not d then return false end
	tripWindow(d)
	if d.Trips.n >= Campaign.TRIPS.max then return false end
	d.Trips.n += 1
	if d.Trips.reset <= 0 then d.Trips.reset = os.time() + Campaign.TRIPS.window end
	publish(player)
	return true
end
-- the TRAIN TICKETS Developer Product (Server/Monetization): all tickets back, once per PurchaseId (saved with it,
-- like a cash pack: "granted" = already given, "saved" = given now and saved, "wait" = try again later)
function Data.grantTripsReceipt(player: Player, purchaseId: string): string
	local prof = profiles[player]
	if not prof then return "wait" end
	if table.find(prof.data.Receipts, purchaseId) then return "granted" end
	local studio = game:GetService("RunService"):IsStudio()
	if not prof.loaded and not studio then return "wait" end
	prof.data.Trips.n = 0
	prof.data.Trips.reset = 0
	table.insert(prof.data.Receipts, purchaseId)
	while #prof.data.Receipts > MAX_RECEIPTS do table.remove(prof.data.Receipts, 1) end
	publish(player)
	if studio and not prof.loaded then return "saved" end
	return Data.save(player) and "saved" or "wait"
end

-- a trip that did not happen (the teleport failed)
function Data.refundTrip(player: Player)
	if not Campaign.TRIPS.enabled then return end
	local d = Data.get(player)
	if not d then return end
	d.Trips.n = math.max(0, d.Trips.n - 1)
	if d.Trips.n == 0 then d.Trips.reset = 0 end
	publish(player)
end
-- admin: n tickets used (0 = all back)
function Data.setTrips(player: Player, used: number)
	local d = Data.get(player)
	if not d then return end
	d.Trips.n = math.clamp(math.floor(used), 0, Campaign.TRIPS.max)
	d.Trips.reset = d.Trips.n > 0 and os.time() + Campaign.TRIPS.window or 0
	publish(player)
end

-- the jars / potions tutorial: "start" gives its starter cash once (true = given now), "done" marks it done
function Data.formTutorial(player: Player, what: string): boolean
	local d = Data.get(player)
	if not d then return false end
	if what == "start" then
		if d.FormTutCash or d.FormTut then return false end
		d.FormTutCash = true
		d.Cash += 20
		publish(player)
		Analytics.cash(player, "Source", 20, d.Cash, "Onboarding", "StarterCash")
		return true
	elseif what == "done" then
		d.FormTut = true
		publish(player)
	end
	return false
end

-- CODES (Server/Codes): has this player redeemed that code (normalized) / mark it redeemed
function Data.codeUsed(player: Player, code: string): boolean
	local d = Data.get(player)
	return d ~= nil and d.Codes[code] == true
end
function Data.useCode(player: Player, code: string)
	local d = Data.get(player)
	if d then d.Codes[code] = true end
end

-- the offline opening queues (Server/Forms changes them in place)
function Data.offline(player: Player): any
	local d = Data.get(player)
	return d and d.Offline
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
	if not new then d.FormN[id] = (d.FormN[id] or 1) + 1 end -- (a copy: it can be traded)
	d.Forms[id] = true
	publish(player)
	return new
end
-- several at once (X10 / X100): one publish; returns the set of the ones that were new
function Data.addForms(player: Player, ids: { string }): { [string]: boolean }
	local d = Data.get(player)
	local new = {} :: { [string]: boolean }
	if not d then return new end
	for _, id in ids do
		if Forms.byId[id] and not d.Forms[id] then new[id] = true
		elseif Forms.byId[id] then d.FormN[id] = (d.FormN[id] or 1) + 1 end
		if Forms.byId[id] then d.Forms[id] = true end
	end
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
-- how many copies of a form the player owns (0 = none)
function Data.formCount(player: Player, id: string): number
	local d = Data.get(player)
	if not d or not d.Forms[id] then return 0 end
	return d.FormN[id] or 1
end
-- TRADES (Server/Trade): take n copies away (false = not that many owned). The last copy of a worn form: the best
-- other form of that kind is worn instead (or none). publish = false: the caller publishes (Data.refresh).
function Data.takeForm(player: Player, id: string, n: number, publishNow: boolean?): boolean
	local d = Data.get(player)
	local fm = Forms.byId[id]
	if not d or not fm or n < 1 then return false end
	local have = d.Forms[id] and (d.FormN[id] or 1) or 0
	if have < n then return false end
	local left = have - n
	if left <= 0 then
		d.Forms[id] = nil; d.FormN[id] = nil
		local key = fm.kind == "stim" and "FormStim" or "FormPotion"
		if d[key] == id then
			local best, bp = nil, -1
			for oid in d.Forms do
				local o = Forms.byId[oid]
				if o and o.kind == fm.kind and Forms.power(o) > bp then best, bp = oid, Forms.power(o) end
			end
			d[key] = best
		end
	elseif left == 1 then d.FormN[id] = nil
	else d.FormN[id] = left end
	if publishNow ~= false then publish(player) end
	return true
end
-- TRADES: give n copies (worn at once if nothing of that kind is worn)
function Data.giveForm(player: Player, id: string, n: number, publishNow: boolean?)
	local d = Data.get(player)
	local fm = Forms.byId[id]
	if not d or not fm or n < 1 then return end
	local have = d.Forms[id] and (d.FormN[id] or 1) or 0
	d.Forms[id] = true
	if have + n > 1 then d.FormN[id] = have + n end
	local key = fm.kind == "stim" and "FormStim" or "FormPotion"
	if d[key] == nil then d[key] = id end
	if publishNow ~= false then publish(player) end
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
	Remotes.SaveSettings.OnServerEvent:Connect(function(p, s) if not Guard.ok(p, "SaveSettings") then return end
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
