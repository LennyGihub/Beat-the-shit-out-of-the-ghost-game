--!strict
-- The two sellers of FORMS in the park (Shared/Forms): DOC MERCY's ectoplasm jars and MOTHER MOTH's potions.
-- Their stalls are workspace.Lobby.Sellers.DocMercy / .MotherMoth (tools/build/sellers.luau), each with a "Prompt"
-- part: the prompt opens the client's seller panel (Fx "OpenSeller", kind). Remotes.Forms:
--   ("buy", vialId)  -> level + cash checked, the form is rolled HERE (never by the client), added to the collection
--                       and saved; worn at once if no form of that kind was worn yet. The client then plays the
--                       first-person jar / drink (Fx "FormRolled": kind, vialId, formId, isNew, worn, prevId).
--   ("buy", vialId, 10 | 100) -> X10 / X100: that many rolled at once (no cinematic), all added to the collection,
--                       the best one worn if that kind had none (Fx "FormMulti": kind, vialId, results, bestId, worn, prevId).
--   ("equip", formId) -> wear a form you own (Fx "FormEquipped").
--   ("cancel", kind)  -> cancel that kind's offline queue: the money of every one still waiting comes back.
--   ("offline", vialId) -> OPEN OFFLINE: paid like a buy, the jar / potion joins its kind's queue (Shared/Forms
--                       OFFLINE: a few minutes each, one after the other) and opens by itself, by the clock: in the
--                       park, in a run's server and while the player is away (settled when they come back). Each
--                       finished one is rolled here, added to the collection (worn if that kind had none) and sent
--                       to the client (Fx "OfflineDone": results, away). 24 h of finished offline opening make the
--                       next offline result RARE or better (the count is kept in the save: Offline.pity).
--                       Player attribute "Offline" (JSON) = the queues, for Client/OfflineOpen's bar.
-- Combat.stat reads the worn forms (health, stamina, damage, knockback).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Forms = require(RS.Shared.Forms)
local Levels = require(RS.Shared.Levels)
local Campaign = require(RS.Shared.Campaign)
local Remotes = require(script.Parent.Remotes)
local Guard = require(script.Parent.Guard)
local Data = require(script.Parent.Data)
local Analytics = require(script.Parent.Analytics)
local Combat = require(script.Parent.Combat)
local Daily = require(script.Parent.Daily)
local HttpService = game:GetService("HttpService")

local M = {}
local rng = Random.new()
local lastBuy = {} :: { [Player]: number }
local BUY_GAP = 6 -- seconds between two buys (the cinematic plays in between)
local REACH = 40 -- studs from the seller a buy is accepted from

local function sellerPart(kind: string): BasePart?
	local lobby = workspace:FindFirstChild("Lobby")
	local f = lobby and lobby:FindFirstChild("Sellers")
	local m = f and f:FindFirstChild(kind == "stim" and "DocMercy" or "MotherMoth")
	return m and m:FindFirstChild("Prompt", true) :: BasePart?
end

local function toast(p: Player, text: string, good: boolean?)
	Remotes.Fx:FireClient(p, "FormResult", good == true, text)
end

local MULTI = { [1] = true, [10] = true, [100] = true } :: { [number]: boolean }

local function buy(p: Player, vialId: any, count: any)
	local v = type(vialId) == "string" and Forms.vialById[vialId] or nil
	if not v then return end
	local n = (type(count) == "number" and MULTI[count]) and count or 1
	if p:GetAttribute("InMatch") then return end
	if os.clock() - (lastBuy[p] or 0) < (n > 1 and 2 or BUY_GAP) then return end
	-- a set is for sale once its map is open (Camp Hollowmere: always)
	if not Campaign.mapOpen(Data.campaign(p), v.set) then
		local m = Campaign.mapById[v.set]
		toast(p, (m and m.name or v.set) .. " IS NOT OPEN YET")
		return
	end
	local level = (Levels.of(p:GetAttribute("XP") or 0))
	if level < v.level then toast(p, v.name .. " NEEDS LEVEL " .. v.level); return end
	-- (the seller's stall must be near: a buy is made at the counter)
	local at = sellerPart(v.kind)
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if at and hrp and (hrp.Position - at.Position).Magnitude > REACH then return end
	if not Data.spend(p, v.price * n, "Shop", v.id) then toast(p, "NOT ENOUGH CASH FOR " .. (n > 1 and (n .. " x ") or "") .. v.name); return end
	lastBuy[p] = os.clock()
	Analytics.onboard(p, v.kind == "stim" and "jar" or "potion")
	if n > 1 then Analytics.custom(p, "OpenMulti", n, v.id) end
	if n > 1 then
		-- X10 / X100: all at once
		local results, ids = {}, {}
		local best: Forms.Form? = nil
		for _ = 1, n do
			local f = Forms.roll(v, rng)
			table.insert(ids, f.id)
			if not best or f.rarity > best.rarity or (f.rarity == best.rarity and Forms.power(f) > Forms.power(best)) then best = f end
		end
		local newOnes = Data.addForms(p, ids)
		for _, id in ids do
			table.insert(results, { form = id, new = newOnes[id] == true })
			newOnes[id] = nil -- (a form rolled twice is new only the first time)
		end
		local prev = Data.formOf(p, v.kind)
		local worn = false
		if prev == nil and best then worn = Data.equipForm(p, best.id) end
		task.spawn(Data.save, p)
		Combat.refreshHealth(p)
		Remotes.Fx:FireClient(p, "FormMulti", v.kind, v.id, results, best and best.id or "", worn, prev or "")
		return
	end
	local fm = Forms.roll(v, rng)
	local prev = Data.formOf(p, v.kind)
	local isNew = Data.addForm(p, fm.id)
	-- nothing worn yet: wear it now; otherwise the player picks (EQUIP / KEEP on the reveal card)
	local worn = prev == nil
	if worn then Data.equipForm(p, fm.id) end
	task.spawn(Data.save, p)
	Combat.refreshHealth(p)
	Remotes.Fx:FireClient(p, "FormRolled", v.kind, v.id, fm.id, isNew, worn, prev or "")
end

-- FREE SAMPLE (2026-11-24, Server/Daily): one free jar / potion of this kind per day, at the seller's counter (the
-- cheapest of the best set the player has open); plays like a buy (Fx "FormRolled": the seller's panel comes back)
local function sample(p: Player, kind: any)
	if kind ~= "stim" and kind ~= "potion" then return end
	if p:GetAttribute("InMatch") or os.clock() - (lastBuy[p] or 0) < BUY_GAP then return end
	if not Daily.sampleReady(p, kind) then toast(p, "COME BACK TOMORROW FOR ANOTHER FREE " .. (kind == "stim" and "JAR" or "POTION")); return end
	local at = sellerPart(kind)
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if at and hrp and (hrp.Position - at.Position).Magnitude > REACH then return end
	local v = Daily.useSample(p, kind)
	if not v then return end
	lastBuy[p] = os.clock()
	Analytics.custom(p, "FreeSample", 1, kind)
	local fm = Forms.roll(v, rng)
	local prev = Data.formOf(p, v.kind)
	local isNew = Data.addForm(p, fm.id)
	local worn = prev == nil
	if worn then Data.equipForm(p, fm.id) end
	task.spawn(Data.save, p)
	Combat.refreshHealth(p)
	Remotes.Fx:FireClient(p, "FormRolled", v.kind, v.id, fm.id, isNew, worn, prev or "")
end

-- OPEN OFFLINE ----------------------------------------------------------------------------------------------------
local lastOffline = {} :: { [Player]: number }

local function publishOffline(p: Player)
	local o = Data.offline(p)
	if not o then return end
	p:SetAttribute("Offline", HttpService:JSONEncode({
		stim = { q = o.stim.q, t = o.stim.t }, potion = { q = o.potion.q, t = o.potion.t }, pity = o.pity,
	}))
end

-- every jar / potion whose time is up at `now`: rolled, added to the collection (worn if that kind had none).
-- Returns the results ({ kind, vial, form, new, worn, pity }).
local function settle(p: Player, now: number): { any }
	local o = Data.offline(p)
	local out = {}
	if not o then return out end
	local OFF = Forms.OFFLINE
	for _, kind in { "stim", "potion" } do
		local k = o[kind]
		while #k.q > 0 do
			local v = Forms.vialById[k.q[1]]
			if not v then table.remove(k.q, 1); continue end
			if k.t <= 0 then k.t = now end
			local dur = Forms.openTime(v)
			if now < k.t + dur then break end
			table.remove(k.q, 1)
			k.t += dur -- (the next one started when this one finished, even offline)
			o.pity += dur
			local sure = o.pity >= OFF.pity
			if sure then o.pity -= OFF.pity end
			local fm = Forms.roll(v, rng, sure and OFF.pityRarity or nil)
			local isNew = Data.addForm(p, fm.id)
			local worn = false
			if Data.formOf(p, kind) == nil then worn = Data.equipForm(p, fm.id) end
			table.insert(out, { kind = kind, vial = v.id, form = fm.id, new = isNew, worn = worn, pity = sure })
			if #out >= 200 then break end -- (a very long absence: the rest is settled on the next tick)
		end
		if #k.q == 0 then k.t = 0 end
	end
	return out
end

local function settleAndTell(p: Player, away: boolean)
	local res = settle(p, os.time())
	if #res == 0 then return end
	publishOffline(p)
	Combat.refreshHealth(p)
	task.spawn(Data.save, p)
	Remotes.Fx:FireClient(p, "OfflineDone", res, away)
end

local function offline(p: Player, vialId: any, count: any)
	local v = type(vialId) == "string" and Forms.vialById[vialId] or nil
	if not v then return end
	local want = (type(count) == "number" and MULTI[count]) and count or 1
	if p:GetAttribute("InMatch") then return end
	if os.clock() - (lastOffline[p] or 0) < 0.3 then return end
	lastOffline[p] = os.clock()
	if not Campaign.mapOpen(Data.campaign(p), v.set) then
		local m = Campaign.mapById[v.set]
		toast(p, (m and m.name or v.set) .. " IS NOT OPEN YET")
		return
	end
	local level = (Levels.of(p:GetAttribute("XP") or 0))
	if level < v.level then toast(p, v.name .. " NEEDS LEVEL " .. v.level); return end
	local at = sellerPart(v.kind)
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if at and hrp and (hrp.Position - at.Position).Magnitude > REACH then return end
	local o = Data.offline(p)
	if not o then return end
	local k = o[v.kind]
	settle(p, os.time()) -- (a finished one is out of the way first)
	local n = math.min(want, Forms.OFFLINE.maxQueue - #k.q)
	if n <= 0 then toast(p, "THE QUEUE IS FULL (" .. Forms.OFFLINE.maxQueue .. ")"); return end
	if not Data.spend(p, v.price * n, "Shop", v.id) then toast(p, "NOT ENOUGH CASH FOR " .. (n > 1 and (n .. " x ") or "") .. v.name); return end
	Analytics.onboard(p, v.kind == "stim" and "jar" or "potion")
	Analytics.custom(p, "OfflineQueued", n, v.id)
	for _ = 1, n do table.insert(k.q, v.id) end
	if #k.q == n then k.t = os.time() end
	publishOffline(p)
	toast(p, v.name .. " IS OPENING  (" .. #k.q .. " IN THE QUEUE)", true)
end

-- CANCEL a kind's queue: everything still waiting (the one opening too) is paid back; what already opened is kept
local function cancel(p: Player, kind: any)
	if kind ~= "stim" and kind ~= "potion" then return end
	local o = Data.offline(p)
	if not o then return end
	pcall(settleAndTell, p, false) -- (anything already finished is given first)
	local k = o[kind]
	if #k.q == 0 then return end
	local refund, n = 0, #k.q
	for _, id in k.q do
		local v = Forms.vialById[id]
		if v then refund += v.price end
	end
	k.q = {}; k.t = 0
	Data.addCash(p, refund, "Refund", kind)
	publishOffline(p)
	task.spawn(Data.save, p)
	Remotes.Fx:FireClient(p, "Toast", "QUEUE CANCELLED - " .. n .. (kind == "stim" and " JAR" or " POTION") .. (n > 1 and "S" or "") .. ", $" .. refund .. " BACK", true)
end

-- after the save loaded (Main): what finished while the player was away
function M.setup(p: Player)
	publishOffline(p)
	task.delay(5, function()
		if p.Parent then settleAndTell(p, true) end
	end)
end

local function equip(p: Player, id: any)
	local fm = type(id) == "string" and Forms.byId[id] or nil
	if not fm or not Data.ownsForm(p, fm.id) then return end
	if Data.equipForm(p, fm.id) then
		Combat.refreshHealth(p)
		Remotes.Fx:FireClient(p, "FormEquipped", fm.kind, fm.id)
	end
end

function M.start()
	Remotes.Forms.OnServerEvent:Connect(function(p, action, a, b) if not Guard.ok(p, "Forms") then return end
		if action == "buy" then buy(p, a, b)
		elseif action == "offline" then offline(p, a, b)
		elseif action == "cancel" then cancel(p, a)
		elseif action == "equip" then equip(p, a)
		elseif action == "sample" then sample(p, a)
		elseif action == "tutorial" and (a == "start" or a == "done") then
			-- the jars / potions tutorial (Client/FormTutorial): starter cash once, then done
			if Data.formTutorial(p, a) then Remotes.Fx:FireClient(p, "Toast", "+$20 STARTER CASH - GO SEE THE SELLERS", true) end
			if a == "done" then task.spawn(Data.save, p) end
		end
	end)
	Players.PlayerRemoving:Connect(function(p) lastBuy[p] = nil; lastOffline[p] = nil end)
	-- the offline queues open by the clock (here, in a run's server too)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, p in Players:GetPlayers() do
				local o = Data.offline(p)
				if o and (#o.stim.q > 0 or #o.potion.q > 0) then
					local ok, err = pcall(settleAndTell, p, false)
					if not ok then warn("[Forms] offline: " .. tostring(err)) end
				end
			end
		end
	end)
	-- the prompts on the two stalls (they may be built after the server started: look for a while)
	task.spawn(function()
		local done = {} :: { [string]: boolean }
		for _ = 1, 30 do
			for _, kind in { "stim", "potion" } do
				local part = not done[kind] and sellerPart(kind) or nil
				if part then
					done[kind] = true
					local s = Forms.SELLER[kind]
					local pp = Instance.new("ProximityPrompt")
					pp.ActionText = kind == "stim" and "Buy ectoplasm" or "Buy a potion"
					pp.ObjectText = kind == "stim" and "Doc Mercy" or "Mother Moth"
					pp.HoldDuration = 0; pp.MaxActivationDistance = 13; pp.RequiresLineOfSight = false
					pp.KeyboardKeyCode = Enum.KeyCode.F
					pp.Style = Enum.ProximityPromptStyle.Custom
					pp.Parent = part
					pp.Triggered:Connect(function(p)
						if not p:GetAttribute("InMatch") then Remotes.Fx:FireClient(p, "OpenSeller", kind) end
					end)
					local _ = s
				end
			end
			if done.stim and done.potion then break end
			task.wait(2)
		end
	end)
end

return M
