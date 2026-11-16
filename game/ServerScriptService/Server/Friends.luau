--!strict
-- Friend booster: +10% cash for every Roblox friend in the same server (max +50%).
-- Sets the player attribute FriendBoost (0..0.5) so the UI can show it; Friends.mult(p) is used by the payouts.
local Players = game:GetService("Players")

local Friends = {}
local PER_FRIEND = 0.1
local MAX = 0.5
local cache = {} :: { [string]: boolean } -- "a:b" -> are friends

local function areFriends(a: Player, b: Player): boolean
	local lo, hi = math.min(a.UserId, b.UserId), math.max(a.UserId, b.UserId)
	local key = lo .. ":" .. hi
	if cache[key] == nil then
		local ok, res = pcall(function() return a:IsFriendsWith(b.UserId) end)
		cache[key] = ok and res == true
	end
	return cache[key]
end

local function refresh()
	local list = Players:GetPlayers()
	for _, p in list do
		local n = 0
		for _, o in list do
			if o ~= p and areFriends(p, o) then n += 1 end
		end
		p:SetAttribute("FriendCount", n)
		p:SetAttribute("FriendBoost", math.min(n * PER_FRIEND, MAX))
	end
end

function Friends.mult(p: Player): number
	return 1 + (p:GetAttribute("FriendBoost") or 0)
end

function Friends.start()
	Players.PlayerAdded:Connect(function() task.spawn(refresh) end)
	Players.PlayerRemoving:Connect(function() task.defer(refresh) end)
	task.spawn(refresh)
end

return Friends
