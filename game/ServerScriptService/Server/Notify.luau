--!strict
-- PUSH NOTIFICATIONS (2026-11-24, week 1 of the retention plan). The game PLANS each player's next reminders when they
-- leave; a job OUTSIDE Roblox sends them (tools/notify/send.py, run every hour by GitHub Actions:
-- .github/workflows/notify.yml), through Roblox's Open Cloud user notifications API, so they go out even when no
-- server of the game is running (most hours, at this game's size).
-- Roblox's rules: only players 13+ who said yes (Client/DailyUI asks with ExperienceNotificationService after a
-- reward), at most ONE notification per player per day from this game (the sender moves a refused one to the next day).
-- Store: MemoryStore sorted map MAP, key = UserId, value = { list = { { t = send time, k = kind, a = { parameters } } } }
-- (sorted by time, one per UTC day at most, 3 at most), sort key = the first one's time. Joining removes it (they came
-- back); leaving writes it again. Kinds (their texts: notification strings made in Creator Hub, ids in
-- tools/notify/config.json):
--   welcome - the welcome jar is ready (at its time)
--   streak  - "your {days}-day streak ends soon, day {next} is waiting" (about 22 h after leaving, inside the last day
--             the streak can still be saved)
--   daily   - "your daily reward is ready" (no streak to lose yet: about 22 h after leaving)
--   miss    - "the ghosts are back" (3 days after leaving, once)
-- A notification opens the game with LaunchData "notif:<kind>" (Analytics custom event NotifJoin).
-- Studio (no MemoryStore): the last plan is JSON in ServerScriptService attribute NotifyLog, nothing is written.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Shared = require(RS.Shared.Daily)
local Data = require(script.Parent.Data)
local Analytics = require(script.Parent.Analytics)

local Notify = {}
local MAP = "Notify_v1"
local HOUR = 3600
local STUDIO = RunService:IsStudio()
local okMap, map = pcall(function() return MemoryStoreService:GetSortedMap(MAP) end)
local last = {} :: { [Player]: any } -- the latest Daily state seen (the save may be gone when PlayerRemoving runs)

type Entry = { t: number, k: string, a: { [string]: string }, last: number? } -- (last: the latest time it still makes sense)

-- the reminders for a player leaving now, from their Daily state
function Notify.plan(st: Shared.State, now: number): { Entry }
	local today = Shared.day(now)
	local list = {} :: { Entry }
	if st.w > 0 and not st.wg then
		table.insert(list, { t = math.max(st.w, now + HOUR), k = "welcome", a = {} })
	end
	-- the streak: claimed on day d, it goes on with a claim on d + 1 (with the shield: d + 2)
	local cur = Shared.current(st, today)
	local claimDay = st.d == today and today + 1 or today -- (the next day a claim is possible)
	local at = now + 22 * HOUR
	if cur >= 2 then
		local lastDay = st.d + 1 + (Shared.shieldReady(st, claimDay) and 1 or 0) -- the last UTC day it can be saved
		local deadline = (lastDay + 1) * 86400
		at = math.clamp(at, claimDay * 86400 + HOUR, deadline - 3 * HOUR)
		if at > now + HOUR then
			table.insert(list, { t = at, k = "streak", a = { days = tostring(cur), next = tostring(cur + 1) }, last = deadline - 2 * HOUR })
		end
	else
		table.insert(list, { t = math.max(at, claimDay * 86400 + HOUR), k = "daily", a = {} })
	end
	table.insert(list, { t = now + 72 * HOUR, k = "miss", a = {} })
	table.sort(list, function(a, b) return a.t < b.t end)
	-- one per UTC day: a later one on a day already taken moves a day on (dropped if that is past its `last`); 3 at most
	local out = {} :: { Entry }
	local usedDay = {} :: { [number]: boolean }
	for _, e in list do
		while usedDay[Shared.day(e.t)] do e.t += 86400 end
		if (e.last == nil or e.t <= e.last) and #out < 3 then
			usedDay[Shared.day(e.t)] = true
			e.last = nil
			table.insert(out, e)
		end
	end
	table.sort(out, function(a, b) return a.t < b.t end)
	return out
end

local function write(p: Player, st: any)
	if not st then return end
	local now = os.time()
	local list = Notify.plan(Shared.clean(st), now)
	if #list == 0 then return end
	local key = tostring(p.UserId)
	local ttl = math.clamp(list[#list].t - now + 2 * 86400, 60, 45 * 86400 - 60)
	if STUDIO then
		game:GetService("ServerScriptService"):SetAttribute("NotifyLog", HttpService:JSONEncode({ user = key, now = now, list = list }))
		return
	end
	if not okMap then return end
	local ok, err = pcall(function() (map :: MemoryStoreSortedMap):SetAsync(key, { list = list }, ttl, list[1].t) end)
	if not ok then warn("[Notify] plan not saved: " .. tostring(err)) end
end

function Notify.setup(p: Player)
	-- came back: whatever was planned is dropped (it is planned again on leaving)
	if okMap and not STUDIO then
		task.spawn(function() pcall(function() (map :: MemoryStoreSortedMap):RemoveAsync(tostring(p.UserId)) end) end)
	end
	-- came from a notification
	local ok, join = pcall(function() return p:GetJoinData() end)
	local launch = ok and type(join) == "table" and join.LaunchData
	local kind = type(launch) == "string" and string.match(launch, "^notif:(%a+)$") or nil
	if kind then Analytics.custom(p, "NotifJoin", 1, kind) end
end

function Notify.start()
	-- keep the latest Daily state of everyone (PlayerRemoving may run after the save is gone)
	task.spawn(function()
		while true do
			for _, p in Players:GetPlayers() do
				local d = Data.get(p)
				if d and d.Daily and (Data.loaded(p) or STUDIO) then last[p] = HttpService:JSONDecode(HttpService:JSONEncode(d.Daily)) end
			end
			task.wait(20)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		local d = Data.get(p)
		local st = (d and d.Daily and (Data.loaded(p) or STUDIO)) and d.Daily or last[p]
		last[p] = nil
		local ok, err = pcall(write, p, st)
		if not ok then warn("[Notify] " .. tostring(err)) end
	end)
end

-- Studio / admin: the plan for this player right now (written to NotifyLog in Studio)
function Notify.debug(p: Player): string
	local d = Data.get(p)
	if not d then return "no save" end
	write(p, d.Daily)
	return HttpService:JSONEncode(Notify.plan(Shared.clean(d.Daily), os.time()))
end

return Notify
