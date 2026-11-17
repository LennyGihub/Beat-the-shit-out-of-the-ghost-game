--!strict
-- The game's staff (developers): the owner, the user ids below and the ones in the ReplicatedStorage attribute
-- AdminUserIds ("123,456"). They are full admins (Server/Admin), wear the DEV title (player attribute Dev: the lobby
-- name tag and the chat tag) and never appear on the global leaderboards (Server/Leaderboards).
local RS = game:GetService("ReplicatedStorage")

local Staff = {}
local DEV_IDS: { [number]: boolean } = { [8414349674] = true, [484096331] = true, [3999142176] = true, [11998610710] = true, [8352705213] = true }

-- by user id alone (works for players who are not in this server)
function Staff.isDevId(userId: number): boolean
	if DEV_IDS[userId] then return true end
	if game.CreatorType == Enum.CreatorType.User and userId == game.CreatorId then return true end
	local list = RS:GetAttribute("AdminUserIds")
	if type(list) == "string" then
		for id in string.gmatch(list, "%d+") do if tonumber(id) == userId then return true end end
	end
	return false
end

-- a player in this server (also: rank 255 of the group that owns the game)
function Staff.isDev(p: Player): boolean
	if Staff.isDevId(p.UserId) then return true end
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(function() return p:GetRankInGroup(game.CreatorId) end)
		if ok and rank >= 255 then return true end
	end
	return false
end

return Staff
