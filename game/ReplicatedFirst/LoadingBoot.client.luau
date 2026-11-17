--!strict
-- Runs first on every client: replaces Roblox's default loading screen with ours (ReplicatedFirst/Loading) and keeps
-- it up until the game is ready to play: the place has loaded, the character is in, and on a match server the run
-- has taken the player in (player attribute InMatch). A teleport's card (Loading.teleport) is picked up as it is.
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")
local Loading = require(script.Parent:WaitForChild("Loading"))

local lp = Players.LocalPlayer
local arriving = TeleportService:GetArrivingTeleportGui()
local data: any = nil
pcall(function() data = TeleportService:GetLocalPlayerTeleportData() end)
local toMatch = type(data) == "table" and type(data.map) == "string"

Loading.show(toMatch and "ENTERING THE HOUSE..." or "LOADING...", arriving)
ReplicatedFirst:RemoveDefaultLoadingScreen()

local t0 = os.clock()
-- 1) the place (progress follows the asset queue)
local startQueue = math.max(1, ContentProvider.RequestQueueSize)
while not game:IsLoaded() and os.clock() - t0 < 30 do
	local left = ContentProvider.RequestQueueSize
	Loading.progress(0.6 * (1 - math.clamp(left / startQueue, 0, 1)))
	task.wait(0.1)
end
-- 2) the character
Loading.status(toMatch and "ENTERING THE HOUSE..." or "WAKING THE DEAD...")
Loading.progress(0.7)
if not lp.Character then
	local t1 = os.clock()
	while not lp.Character and os.clock() - t1 < 20 do task.wait(0.1) end
end
-- 3) a match server: until the run has the player (the others may still be on their way)
if toMatch then
	Loading.status("WAITING FOR YOUR TEAM...")
	Loading.progress(0.85)
	local t2 = os.clock()
	while lp:GetAttribute("InMatch") ~= true and os.clock() - t2 < 20 do task.wait(0.1) end
end
Loading.status("GOOD LUCK.")
Loading.hide(2.5)
