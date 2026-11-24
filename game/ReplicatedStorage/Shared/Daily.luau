--!strict
-- DAILY REWARDS (2026-11-24, week 1 of the retention plan: "a reason to come back tomorrow"). The rules, shared by
-- Server/Daily (which gives them) and Client/DailyUI (which shows them). Days are UTC days (os.time() // 86400).
--   LOGIN STREAK: one reward a day, claimed in the DAILY window. Days in a row build the streak. Missing ONE day is
--     forgiven once every SHIELD_DAYS days (the shield is used by itself); missing more starts again at day 1.
--     A week = 7 rewards (REWARDS); every week after the first, the jars / potions are one tier better (max 4).
--     Day 7 of every week: a jar or a potion that is EPIC or better. Day 30 of a streak: the exclusive form
--     THIRTY NIGHTS too (Shared/Forms).
--   WELCOME JAR: the first time a player stands in the park after the tutorial, a jar starts its WELCOME_HOURS;
--     then it opens (RARE or better).
--   FREE SAMPLE: one free jar at Doc Mercy and one free potion at Mother Moth per day (the cheapest of the best set
--     you have open).
-- The jars / potions come from the best campaign map's set the player has open (Server/Daily.bestSet).
local Daily = {}

Daily.WELCOME_HOURS = 20
Daily.WELCOME_TIER = 2
Daily.WELCOME_MIN = 3 -- RARE or better
Daily.SHIELD_DAYS = 7
Daily.DAY30 = 30
Daily.DAY30_FORM = "ThirtyNights"
Daily.SAMPLE_TIER = 1

export type Reward = { kind: string?, tier: number?, min: number?, cash: number?, double: boolean? }

-- the 7 days of a week. kind "stim" = a jar (Doc Mercy), "potion" = a potion (Mother Moth), "both" = day 7's pick
-- (a jar on odd weeks, a potion on even ones); cash = a multiple of the player's level reward (Daily.cash)
local REWARDS: { Reward } = {
	{ kind = "stim", tier = 1 },
	{ kind = "potion", tier = 1 },
	{ cash = 1 },
	{ kind = "stim", tier = 2 },
	{ kind = "potion", tier = 2 },
	{ cash = 2 },
	{ kind = "both", tier = 4, min = 4 }, -- EPIC or better
}
Daily.WEEK = #REWARDS

function Daily.day(now: number): number
	return now // 86400
end

-- seconds left until the next UTC day
function Daily.untilTomorrow(now: number): number
	return 86400 - (now % 86400)
end

-- the save's state, cleaned (anything odd = the default)
export type State = { s: number, d: number, best: number, sh: number, w: number, wg: boolean, f: { stim: number, potion: number }, x30: boolean }
function Daily.clean(raw: any): State
	local function n(x: any): number
		local v = tonumber(x)
		if not v or v ~= v or v == math.huge or v == -math.huge then return 0 end
		return math.max(0, math.floor(v))
	end
	local t = type(raw) == "table" and raw or {}
	local f = type(t.f) == "table" and t.f or {}
	return { s = n(t.s), d = n(t.d), best = n(t.best), sh = n(t.sh), w = n(t.w), wg = t.wg == true,
		f = { stim = n(f.stim), potion = n(f.potion) }, x30 = t.x30 == true }
end

-- claiming today: the streak it makes (0 = already claimed today) and whether the shield is used for it
function Daily.next(st: State, today: number): (number, boolean)
	if st.d == today then return 0, false end
	if st.s > 0 and st.d == today - 1 then return st.s + 1, false end
	if st.s > 0 and st.d == today - 2 and today - st.sh >= Daily.SHIELD_DAYS then return st.s + 1, true end
	return 1, false
end

-- the streak shown right now: today's one if claimed, else the one a claim would continue (0 = broken)
function Daily.current(st: State, today: number): number
	if st.d == today then return st.s end
	local n, _ = Daily.next(st, today)
	return n > 1 and n - 1 or 0
end

-- the shield is ready (a missed day would be forgiven)
function Daily.shieldReady(st: State, today: number): boolean
	return today - st.sh >= Daily.SHIELD_DAYS
end

-- the reward of streak day n (1, 2, ...): kind / tier / min for a jar or potion, cash = a multiple of Daily.cash
function Daily.reward(n: number): Reward
	local c = ((n - 1) % Daily.WEEK) + 1
	local week = (n - 1) // Daily.WEEK
	local r = REWARDS[c]
	local out: Reward = { cash = r.cash, min = r.min }
	if r.kind then
		out.kind = r.kind == "both" and (week % 2 == 0 and "stim" or "potion") or r.kind
		out.tier = math.min(4, (r.tier or 1) + math.min(week, 3))
	end
	return out
end

-- the cash a "cash = 1" reward gives at a player level (like the friend reward: 100 + 25 per level)
function Daily.cash(mult: number, level: number): number
	return math.floor((100 + 25 * math.max(1, level)) * mult)
end

-- a short text for a reward (the calendar's tiles): "JAR", "POTION", "$275", "EPIC+ JAR"
function Daily.label(r: Reward, level: number): string
	if r.cash then return "$" .. Daily.cash(r.cash, level) end
	local what = r.kind == "stim" and "JAR" or "POTION"
	if r.min and r.min >= 4 then return "EPIC+ " .. what end
	return what .. " " .. ({ "I", "II", "III", "IV" })[r.tier or 1]
end

return Daily
