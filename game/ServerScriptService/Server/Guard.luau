--!strict
-- GUARD (2026-11-24, the security pass): one place for what every remote handler must check.
--   Guard.limit(name, fn) / Guard.ok(player, name): a per-player TOKEN BUCKET per remote (LIMITS: refill per second,
--     burst). Over the limit the request is dropped silently (a real player never gets near these numbers; an
--     exploit script spamming a remote does). Cleared on PlayerRemoving. A player dropping a lot is warned about in
--     the output once a minute (no kick: lag on phones can bunch requests up).
--   Guard.num(x, lo, hi) -> a finite number in [lo, hi] or nil (NaN and inf never pass: they corrupt saves and
--     maths); Guard.int(...) the same, floored; Guard.vec(v, maxLen) -> a finite Vector3 no longer than maxLen or nil;
--     Guard.str(s, maxLen) -> a string no longer than maxLen or nil.
-- The client only ever sends an intent (an id, a direction, an action); prices, damage and rewards are decided by the
-- server. New remote: add its line to LIMITS (else DEFAULT) and connect it as Remote.OnServerEvent:Connect(Guard.limit("Name", fn)).
local Players = game:GetService("Players")

local Guard = {}

-- remote name -> { refill per second, burst }
local LIMITS: { [string]: { number } } = {
	-- the fight (the server keeps its own cooldowns too: these only stop floods)
	Punch = { 12, 20 }, Use = { 30, 40 }, Grab = { 8, 12 }, Throw = { 8, 12 }, Ultimate = { 4, 6 },
	Sprint = { 15, 25 }, Charge = { 15, 25 }, Block = { 15, 25 }, Select = { 20, 30 }, Drop = { 10, 15 },
	-- the lobby and the menus
	Party = { 4, 8 }, RoomPick = { 4, 8 }, BuyUlt = { 4, 8 }, BuyMap = { 4, 8 }, EquipUlt = { 6, 10 }, SwapUlt = { 6, 10 },
	ReturnLobby = { 2, 4 }, Quest = { 6, 12 }, Stage = { 3, 6 }, NextGhost = { 3, 6 }, Revive = { 3, 6 },
	Tutorial = { 10, 25 }, Trade = { 10, 20 }, Codes = { 3, 6 }, Forms = { 8, 15 }, Share = { 1, 3 }, PatchNotes = { 2, 4 }, Daily = { 2, 4 },
	Sandbox = { 4, 6 }, SaveSettings = { 4, 6 }, Platform = { 2, 4 }, FreeCam = { 8, 12 },
}
local DEFAULT = { 10, 20 }

type Bucket = { t: number, n: number }
local buckets: { [Player]: { [string]: Bucket } } = {}
local dropped: { [Player]: { n: number, warned: number } } = {}

local function drop(p: Player, name: string)
	local d = dropped[p]
	if not d then d = { n = 0, warned = 0 }; dropped[p] = d end
	d.n += 1
	local now = os.clock()
	if d.n >= 50 and now - d.warned > 60 then
		d.warned = now
		warn(("[Guard] %s (%d) is flooding remotes: %d requests dropped (last: %s)"):format(p.Name, p.UserId, d.n, name))
		d.n = 0
	end
end

function Guard.ok(p: Player, name: string): boolean
	if typeof(p) ~= "Instance" or not p:IsA("Player") then return false end
	local lim = LIMITS[name] or DEFAULT
	local mine = buckets[p]
	if not mine then mine = {}; buckets[p] = mine end
	local now = os.clock()
	local b = mine[name]
	if not b then b = { t = now, n = lim[2] }; mine[name] = b end
	b.n = math.min(lim[2], b.n + (now - b.t) * lim[1])
	b.t = now
	if b.n < 1 then drop(p, name); return false end
	b.n -= 1
	return true
end

-- a handler with the rate limit in front: Remote.OnServerEvent:Connect(Guard.limit("Name", fn))
function Guard.limit(name: string, fn: (Player, ...any) -> ...any): (Player, ...any) -> ()
	return function(p: Player, ...: any)
		if Guard.ok(p, name) then fn(p, ...) end
	end
end

function Guard.num(x: any, lo: number?, hi: number?): number?
	if type(x) ~= "number" or x ~= x or x == math.huge or x == -math.huge then return nil end
	if lo and x < lo then return nil end
	if hi and x > hi then return nil end
	return x
end

function Guard.int(x: any, lo: number?, hi: number?): number?
	local n = Guard.num(x, lo, hi)
	return n and math.floor(n) or nil
end

function Guard.vec(v: any, maxLen: number?): Vector3?
	if typeof(v) ~= "Vector3" then return nil end
	if not Guard.num(v.X) or not Guard.num(v.Y) or not Guard.num(v.Z) then return nil end
	if maxLen and v.Magnitude > maxLen then return nil end
	return v
end

function Guard.str(s: any, maxLen: number): string?
	if type(s) ~= "string" or #s > maxLen then return nil end
	return s
end

Players.PlayerRemoving:Connect(function(p)
	buckets[p] = nil
	dropped[p] = nil
end)

return Guard
