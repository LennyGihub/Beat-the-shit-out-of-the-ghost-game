--!strict
-- DAILY REWARDS, the server (rules: Shared/Daily; window: Client/DailyUI). 2026-11-24, week 1 of the retention plan.
-- Saved in Data "Daily" (a raw table like Quests, cleaned here: Shared/Daily.clean). Player attributes:
--   "Daily" (JSON: s = the streak shown, next = the streak a claim today makes (0 = claimed today), shield = a missed
--   day would be forgiven, w = the welcome jar's unlock time (0 = not started), wg = it was opened, fs / fp = today's
--   free jar / potion still to take, best, x30, day = the server's UTC day, level)
--   "Streak" (number, everyone sees it over the head in the park: Client/NameTags).
-- Remotes.Daily: ("claim") today's streak reward; ("welcome") the welcome jar once its time is up. The free samples go
-- through Remotes.Forms "sample" (Server/Forms: at the seller's counter) with Daily.sampleReady / useSample.
-- Every jar / potion given here is rolled here and plays its cinematic on the client (Fx "DailyReward": kind, vialId,
-- formId, isNew, worn, prevId). Analytics: DailyClaim (value = the streak day), WelcomeJar, FreeSample (Server/Forms).
-- Studio / admin: `daily <n>` sets the streak as if day n was claimed yesterday, `daily reset`, `daily welcome` (the
-- welcome jar ready now), `daily sample` (today's samples back) - Server/Admin.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Shared = require(RS.Shared.Daily)
local Forms = require(RS.Shared.Forms)
local Campaign = require(RS.Shared.Campaign)
local Levels = require(RS.Shared.Levels)
local Remotes = require(script.Parent.Remotes)
local Guard = require(script.Parent.Guard)
local Data = require(script.Parent.Data)
local Analytics = require(script.Parent.Analytics)
local Combat = require(script.Parent.Combat)

local Daily = {}
local rng = Random.new()

local function state(p: Player): Shared.State?
	local d = Data.get(p)
	if not d then return nil end
	local st = Shared.clean(d.Daily)
	d.Daily = st
	return st
end

local function level(p: Player): number
	return (Levels.of(tonumber(p:GetAttribute("XP")) or 0))
end

-- the best campaign map's set this player has open (Camp Hollowmere at least)
function Daily.bestSet(p: Player): string
	local prog = Data.campaign(p)
	local best = "Camp"
	for _, cm in Campaign.list do
		if Campaign.mapOpen(prog, cm.id) and #Forms.vialsOf("stim", cm.id) > 0 then best = cm.id end
	end
	return best
end

local function vialFor(p: Player, kind: string, tier: number): Forms.Vial?
	local set = Daily.bestSet(p)
	local best: Forms.Vial? = nil
	for _, v in Forms.vialsOf(kind, set) do
		if v.tier <= tier and (not best or v.tier > best.tier) then best = v end
	end
	return best
end

local function publish(p: Player)
	local st = state(p)
	if not st then return end
	local now = os.time()
	local today = Shared.day(now)
	local nxt, _ = Shared.next(st, today)
	p:SetAttribute("Daily", HttpService:JSONEncode({
		s = Shared.current(st, today), next = nxt, shield = Shared.shieldReady(st, today), w = st.w, wg = st.wg,
		fs = st.f.stim ~= today, fp = st.f.potion ~= today, best = st.best, x30 = st.x30, day = today, level = level(p),
		set = Daily.bestSet(p),
	}))
	p:SetAttribute("Streak", Shared.current(st, today))
end
Daily.publish = publish

-- roll a jar / potion of this kind and tier (min = that rarity or better), add it, play its cinematic
local function giveRoll(p: Player, kind: string, tier: number, min: number?): Forms.Form?
	local v = vialFor(p, kind, tier)
	if not v then return nil end
	local fm = Forms.roll(v, rng, min)
	local prev = Data.formOf(p, kind)
	local isNew = Data.addForm(p, fm.id)
	local worn = prev == nil
	if worn then Data.equipForm(p, fm.id) end
	Remotes.Fx:FireClient(p, "DailyReward", kind, v.id, fm.id, isNew, worn, prev or "")
	return fm
end

local function giveForm(p: Player, id: string)
	local fm = Forms.byId[id]
	if not fm then return end
	local prev = Data.formOf(p, fm.kind)
	local isNew = Data.addForm(p, fm.id)
	local worn = prev == nil
	if worn then Data.equipForm(p, fm.id) end
	Remotes.Fx:FireClient(p, "DailyReward", fm.kind, "", fm.id, isNew, worn, prev or "")
end

local function claim(p: Player)
	-- (no yield in here: two claims can't interleave)
	if p:GetAttribute("InMatch") or (not Data.loaded(p) and not game:GetService("RunService"):IsStudio()) then return end
	local st = state(p)
	if not st then return end
	local today = Shared.day(os.time())
	local n, shield = Shared.next(st, today)
	if n == 0 then return end
	st.s = n; st.d = today
	if shield then st.sh = today end
	st.best = math.max(st.best, n)
	local r = Shared.reward(n)
	local what = ""
	if r.cash then
		local c = Shared.cash(r.cash, level(p))
		Data.addCash(p, c, "Daily", "Streak" .. n)
		what = "$" .. c
	elseif r.kind then
		local fm = giveRoll(p, r.kind, r.tier or 1, r.min)
		what = fm and fm.name or ""
	end
	if n >= Shared.DAY30 and not st.x30 then
		st.x30 = true
		giveForm(p, Shared.DAY30_FORM)
	end
	Combat.refreshHealth(p)
	publish(p)
	task.spawn(Data.save, p)
	Analytics.custom(p, "DailyClaim", n, shield and "shield" or "plain")
	Remotes.Fx:FireClient(p, "Toast", "DAY " .. n .. " CLAIMED" .. (what ~= "" and (": " .. what) or "") .. (shield and "  (YOUR SHIELD SAVED THE STREAK)" or ""), true)
end

-- the welcome jar starts its time the first time the player is in the park after the tutorial
local function startWelcome(p: Player)
	local st = state(p)
	if not st or st.w > 0 or st.wg then return end
	if p:GetAttribute("InMatch") or p:GetAttribute("TutorialSeen") ~= true then return end
	st.w = os.time() + Shared.WELCOME_HOURS * 3600
	publish(p)
	task.spawn(Data.save, p)
	Remotes.Fx:FireClient(p, "Toast", "WELCOME GIFT: A JAR THAT OPENS IN " .. Shared.WELCOME_HOURS .. " HOURS - COME BACK TOMORROW!", true)
end

local function welcome(p: Player)
	if p:GetAttribute("InMatch") then return end
	local st = state(p)
	if not st or st.w == 0 or st.wg or os.time() < st.w then return end
	st.wg = true
	giveRoll(p, "stim", Shared.WELCOME_TIER, Shared.WELCOME_MIN)
	Combat.refreshHealth(p)
	publish(p)
	task.spawn(Data.save, p)
	Analytics.custom(p, "WelcomeJar", 1)
end

-- FREE SAMPLES (Server/Forms "sample" calls these): today's free jar / potion of this kind not taken yet
function Daily.sampleReady(p: Player, kind: string): boolean
	local st = state(p)
	if not st then return false end
	return st.f[kind] ~= Shared.day(os.time())
end
function Daily.useSample(p: Player, kind: string): Forms.Vial?
	local st = state(p)
	if not st or (kind ~= "stim" and kind ~= "potion") then return nil end
	st.f[kind] = Shared.day(os.time())
	publish(p)
	return vialFor(p, kind, Shared.SAMPLE_TIER)
end

-- admin / Studio tests (Server/Admin "daily ...")
function Daily.admin(p: Player, what: string, n: number?): string
	local st = state(p)
	if not st then return "no save" end
	local today = Shared.day(os.time())
	if what == "reset" then
		local d = Data.get(p)
		if d then d.Daily = Shared.clean(nil) end
	elseif what == "welcome" then
		st.w = os.time() - 1; st.wg = false
	elseif what == "sample" then
		st.f.stim = 0; st.f.potion = 0
	elseif what == "streak" and n then
		st.s = math.max(0, math.floor(n)); st.d = today - 1; st.best = math.max(st.best, st.s)
		if st.s >= Shared.DAY30 then st.x30 = true end
	elseif what == "miss" and n then
		st.d = today - 1 - math.max(0, math.floor(n)) -- (n days missed)
	elseif what == "shield" then
		st.sh = 0
	end
	publish(p)
	return HttpService:JSONEncode(st)
end

function Daily.setup(p: Player)
	task.spawn(function()
		while p.Parent and not Data.get(p) do task.wait(0.5) end
		publish(p)
	end)
end

function Daily.start()
	Remotes.Daily.OnServerEvent:Connect(Guard.limit("Daily", function(p: Player, action: any)
		if action == "claim" then claim(p)
		elseif action == "welcome" then welcome(p) end
	end))
	-- every 10 s: start a welcome jar for whoever reached the park, refresh the day when it turns
	local lastDay = Shared.day(os.time())
	task.spawn(function()
		while true do
			task.wait(10)
			local today = Shared.day(os.time())
			for _, p in Players:GetPlayers() do
				local ok, err = pcall(function()
					startWelcome(p)
					if today ~= lastDay then publish(p) end
				end)
				if not ok then warn("[Daily] " .. tostring(err)) end
			end
			lastDay = today
		end
	end)
end

return Daily
