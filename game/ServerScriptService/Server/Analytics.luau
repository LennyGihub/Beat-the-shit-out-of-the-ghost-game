--!strict
-- ANALYTICS (2026-11-24): what Roblox's Creator Hub > Analytics shows about this game. Server only, so a client can't
-- fake a step, and every call is in pcall: analytics never breaks the game.
--   ONBOARDING FUNNEL: a brand-new save's first steps (STEPS below), each logged once EVER and only forward (Data keeps
--     the highest one in the save's `Onb`; saves from before this have no `Onb` and are never in the funnel).
--     Lessons are counted by the intro's "hold" moments (Server/Tutorial), so they read "Lesson 1..6".
--   FIRST MINUTE: how long a new player takes to press READY (custom event ReadySeconds) and, for one who leaves
--     before the park, the step they left at (OnboardingQuit) and, before READY, after how long (QuitBeforeReady).
--   PROGRESSION: every campaign building start / clear / fail (path "Campaign", level = the building's level 1..26),
--     endless runs as a custom event (EndlessKills, with the house and difficulty).
--   ECONOMY: every change of the saved cash, as a source or a sink with its reason (Data.addCash / Data.spend and
--     the few places that change Cash directly call Analytics.cash).
-- In Studio nothing is sent: the last 40 events are kept as JSON in ServerScriptService's attribute AnalyticsLog
-- (read it from a `luau Server` test script).
local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Analytics = {}

local STUDIO = RunService:IsStudio()

local STEPS = {
	"Joined", "Ready pressed", "Intro started", "Monster appeared",
	"Lesson 1", "Lesson 2", "Lesson 3", "Lesson 4", "Lesson 5", "Lesson 6",
	"Intro fight", "Intro fight won", "In the park", "First jar", "First potion",
	"Boarded the train", "First building fight", "First building cleared", "Camp Hollowmere cleared",
}
-- key -> step number
local STEP: { [string]: number } = {
	join = 1, ready = 2, intro = 3, monster = 4, fight = 11, won = 12, park = 13, jar = 14, potion = 15,
	train = 16, stage = 17, clear = 18, camp = 19,
}
local LESSON0, LESSONS = 4, 6 -- lesson n = step 4 + n

-- the save's step (bound by Server/Data: it owns the save; nil = an older save, not in the funnel)
local getOnb: (Player) -> number? = function() return nil end
local setOnb: (Player, number) -> () = function() end
function Analytics.bind(get: (Player) -> number?, set: (Player, number) -> ())
	getOnb, setOnb = get, set
end

local joinedAt: { [Player]: number } = {}
local lessons: { [Player]: number } = {}
local tracked: { [Player]: number } = {} -- this session's copy of the step (Data may drop the save before PlayerRemoving here)

-- (Studio) the last events, for tests
local log: { string } = {}
local function remember(line: string)
	if not STUDIO then return end
	table.insert(log, line)
	while #log > 40 do table.remove(log, 1) end
	game:GetService("ServerScriptService"):SetAttribute("AnalyticsLog", HttpService:JSONEncode(log))
end

local function fields(a: string?, b: string?, c: string?): { [string]: any }?
	if not a and not b and not c then return nil end
	local f = {}
	if a then f[Enum.AnalyticsCustomFieldKeys.CustomField01.Name] = a end
	if b then f[Enum.AnalyticsCustomFieldKeys.CustomField02.Name] = b end
	if c then f[Enum.AnalyticsCustomFieldKeys.CustomField03.Name] = c end
	return f
end

local function send(line: string, fn: () -> ())
	remember(line)
	if STUDIO then return end
	local ok, err = pcall(fn)
	if not ok then warn("[Analytics] " .. line .. ": " .. tostring(err)) end
end

-- ONBOARDING -------------------------------------------------------------------------------------------------------
local function logStep(p: Player, n: number)
	local cur = getOnb(p)
	if cur == nil or n <= cur then return end
	setOnb(p, n)
	tracked[p] = n
	local name = STEPS[n] or ("Step " .. n)
	send(("onboarding %d %s"):format(n, name), function()
		AnalyticsService:LogOnboardingFunnelStepEvent(p, n, name)
	end)
end

-- a step by key (see STEP): "join", "ready", "intro", "monster", "fight", "won", "park", "jar", "potion", "train",
-- "stage", "clear", "camp"
function Analytics.onboard(p: Player, key: string)
	local n = STEP[key]
	if not n then return end
	local cur = getOnb(p)
	if key == "ready" and cur ~= nil and cur < n and joinedAt[p] then
		local secs = math.floor((os.clock() - joinedAt[p]) * 10) / 10
		Analytics.custom(p, "ReadySeconds", secs)
	elseif key == "park" and cur ~= nil and cur >= STEP.intro and cur < STEP.won then
		-- in the park before the intro's fight was won: skipped (where)
		Analytics.custom(p, "IntroSkipped", cur, STEPS[cur])
	end
	logStep(p, n)
end

-- the intro froze for its next lesson (Server/Tutorial "hold")
function Analytics.lesson(p: Player)
	local n = math.min((lessons[p] or 0) + 1, LESSONS)
	lessons[p] = n
	logStep(p, LESSON0 + n)
end

-- Data.load: the save is in (isNew = no save existed before: the funnel starts)
function Analytics.joined(p: Player)
	joinedAt[p] = os.clock()
	lessons[p] = 0
	tracked[p] = getOnb(p)
	if getOnb(p) == 0 then logStep(p, STEP.join) end
end

-- PROGRESSION -------------------------------------------------------------------------------------------------------
-- what = "start" | "complete" | "fail"; level = the building's level (Shared/Campaign), name = its stage id
function Analytics.stage(p: Player, what: string, level: number, stageId: string, diffId: string?)
	local f = fields(diffId)
	send(("progression %s %s (%d) %s"):format(what, stageId, level, tostring(diffId)), function()
		if what == "start" then
			AnalyticsService:LogProgressionStartEvent(p, "Campaign", level, stageId, f)
		elseif what == "complete" then
			AnalyticsService:LogProgressionCompleteEvent(p, "Campaign", level, stageId, f)
		else
			AnalyticsService:LogProgressionFailEvent(p, "Campaign", level, stageId, f)
		end
	end)
end

-- ECONOMY -----------------------------------------------------------------------------------------------------------
-- flow "Source" (cash in) | "Sink" (cash out); tx = Enum.AnalyticsEconomyTransactionType's name (IAP, Shop, Gameplay,
-- ContextualPurchase, TimedReward, Onboarding) or our own (Trade, Code, Refund, Badge, Admin); sku = what it was
function Analytics.cash(p: Player, flow: string, amount: number, balance: number, tx: string, sku: string?)
	if amount ~= amount or amount <= 0 or amount == math.huge then return end
	local ft = flow == "Sink" and Enum.AnalyticsEconomyFlowType.Sink or Enum.AnalyticsEconomyFlowType.Source
	send(("economy %s %d -> %d %s %s"):format(flow, amount, balance, tx, tostring(sku)), function()
		AnalyticsService:LogEconomyEvent(p, ft, "Cash", amount, balance, tx, sku)
	end)
end

-- CUSTOM ------------------------------------------------------------------------------------------------------------
-- (keep event names few and fixed: Roblox limits how many different ones a game can have)
function Analytics.custom(p: Player, name: string, value: number?, a: string?, b: string?, c: string?)
	local f = fields(a, b, c)
	send(("custom %s %s %s"):format(name, tostring(value), tostring(a)), function()
		AnalyticsService:LogCustomEvent(p, name, value or 1, f)
	end)
end

Players.PlayerRemoving:Connect(function(p)
	local n = tracked[p]
	if n ~= nil and n < STEP.park then
		-- a new player who left before the park: where (and, before READY, after how long)
		Analytics.custom(p, "OnboardingQuit", n, STEPS[n] or "Not started")
		if n < STEP.ready and joinedAt[p] then
			Analytics.custom(p, "QuitBeforeReady", math.floor(os.clock() - joinedAt[p]))
		end
	end
	joinedAt[p] = nil
	lessons[p] = nil
	tracked[p] = nil
end)

return Analytics
