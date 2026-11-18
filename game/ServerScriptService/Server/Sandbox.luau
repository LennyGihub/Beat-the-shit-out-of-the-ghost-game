--!strict
-- Sandbox: try any ultimate, owned or not, on a training dummy. It runs in the lobby server itself (no teleport):
-- the shop's TRY NOW button puts the player in the house of the first map with the Woman, who stands still, never
-- attacks, takes every hit and comes back in the middle of the house when she is knocked out. LEAVE (the grey
-- button at the top of the screen) brings the player back to the park.
-- The house is shared: everyone in the sandbox of this server trains on the same dummy; it closes with the last
-- one out. Nothing in here pays: no cash, no kills, no quests (Run.addToMatch noPay, Quests.add, Ghost.onDeath).
-- Player attributes: Sandbox = true while in it, TrialUlt = the ultimate that Q fires there (Combat.onUltimate).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Remotes = require(script.Parent.Remotes)
local Run = require(script.Parent.Run)
local Ghost = require(script.Parent.Ghost)
local Combat = require(script.Parent.Combat)
local Furniture = require(script.Parent.Furniture)
local Inventory = require(script.Parent.Inventory)
local MapLoader = require(script.Parent.MapLoader)
local Data = require(script.Parent.Data)
local Ultimates = require(RS.Shared.Ultimates)
local Maps = require(RS.Shared.Maps)

local Sandbox = {}
local active = false
local token = 0 -- one pending dummy respawn at a time
local lastAsk = {} :: { [Player]: number }
local rng = Random.new()
local RESPAWN = 3.2 -- seconds between her knockout and the new dummy (her death plays out first)

function Sandbox.active(): boolean return active end

-- the middle of the house on the ground floor, or the nearest clear spot to it (the exact middle can be a wall)
local function center(): Vector3
	local inside = MapLoader.spawnInside()
	local B = Ghost.houseBounds()
	local live = workspace:FindFirstChild("Mansion")
	local structure = live and live:FindFirstChild("Structure")
	local mid = Vector3.new((B.min.X + B.max.X) / 2, inside.Y + 3, (B.min.Z + B.max.Z) / 2)
	if not structure then return Vector3.new(mid.X, inside.Y, mid.Z) end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { structure }
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = { structure }
	local offsets = { Vector3.zero }
	for r = 4, 28, 4 do
		for i = 0, 7 do
			local a = i / 8 * math.pi * 2
			table.insert(offsets, Vector3.new(math.cos(a) * r, 0, math.sin(a) * r))
		end
	end
	for _, off in offsets do
		local floor = workspace:Raycast(mid + off, Vector3.new(0, -30, 0), rp)
		if floor and floor.Normal.Y > 0.7 then
			local spot = floor.Position + Vector3.new(0, 3.5, 0)
			if #workspace:GetPartBoundsInBox(CFrame.new(spot + Vector3.new(0, 0.5, 0)), Vector3.new(5, 6, 5), op) == 0 then return spot end
		end
	end
	return inside
end

-- a fresh dummy in a fresh room: the furniture is back, the walls are whole (Ghost.spawn), the fires are out
local function spawnDummy()
	Furniture.reset()
	Ghost.spawn(1, center(), "Woman")
end

-- players whose sandbox ended some other way (left the game, an admin ended the run) are cleared here, and the
-- sandbox closes with the last one out
local function sweep()
	local n = 0
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("Sandbox") then
			if p:GetAttribute("InMatch") then
				n += 1
			else
				p:SetAttribute("Sandbox", nil)
				p:SetAttribute("TrialUlt", nil)
			end
		end
	end
	if active and n == 0 then
		active = false
		token += 1
		Ghost.passive = false
		Run.setSandbox(false) -- the dummy goes, the house is put back
	end
end

local function toast(p: Player, text: string, good: boolean?)
	Remotes.Fx:FireClient(p, "Toast", text, good)
end

-- quiet = no "SANDBOX - TRYING" message (the tutorial, Server/Tutorial, runs in the sandbox and says its own things)
local function enter(p: Player, id: any, quiet: boolean?)
	if Run.mode ~= "Lobby" then return end
	sweep()
	local u = (type(id) == "string" and Ultimates.byId[id]) or Ultimates.byId[Data.equipped(p)] or Ultimates.byId[Ultimates.default]
	if p:GetAttribute("Sandbox") then
		-- already in: TRY NOW on another card only changes the ultimate on trial (ready at once)
		p:SetAttribute("TrialUlt", u.id)
		Combat.endUltimate(p)
		Combat.fillBrutality(p)
		toast(p, "NOW TRYING: " .. string.upper(u.name), true)
		return
	end
	-- (checked again after every wait below: another player may have opened or closed the sandbox meanwhile)
	local function allowed(): boolean
		if p.Parent == nil or p:GetAttribute("InMatch") then return false end
		if Run.running() and not active then
			toast(p, "THE HOUSE IS IN USE - TRY AGAIN IN A MOMENT")
			return false
		end
		local hum = p.Character and (p.Character :: Model):FindFirstChildOfClass("Humanoid")
		return hum ~= nil and hum.Health > 0
	end
	if not allowed() then return end
	if not active then Run.configure(Maps.list[1].id, Maps.defaultDiff) end -- the first map, normal difficulty
	-- the house is far from the park: have it sent to the player before they stand in it (streaming)
	local inside = MapLoader.spawnInside()
	pcall(function() p:RequestStreamAroundAsync(inside, 5) end)
	if not allowed() then return end
	-- from here on nothing waits: the player is in the house and counted before the sandbox opens (sweep)
	Run.addToMatch(p, true) -- like in a run, but nothing is paid
	p:SetAttribute("Sandbox", true)
	p:SetAttribute("TrialUlt", u.id)
	;(p.Character :: Model):PivotTo(CFrame.new(inside + Vector3.new(rng:NextInteger(-6, 6), 0, 0)))
	if not active then
		active = true
		Ghost.passive = true
		Run.setSandbox(true)
		Inventory.clearWorld()
		spawnDummy()
	end
	Combat.healAll({ p })
	Combat.endUltimate(p)
	Combat.fillBrutality(p)
	if not quiet then toast(p, "SANDBOX - TRYING: " .. string.upper(u.name), true) end
end
Sandbox.enter = enter

local function leave(p: Player)
	if not p:GetAttribute("Sandbox") then return end
	p:SetAttribute("Sandbox", nil)
	p:SetAttribute("TrialUlt", nil)
	Combat.endUltimate(p)
	Combat.clearBrutality(p)
	Combat.release(p) -- furniture in the hands stays in the house
	local park = workspace:FindFirstChild("LobbySpawn")
	if park and park:IsA("BasePart") then pcall(function() p:RequestStreamAroundAsync(park.Position, 5) end) end
	-- back to the park (Lobby.returnPlayer: out of the house, lobby spawn, the house is closed if it is empty)
	if p.Parent and p:GetAttribute("InMatch") and Run.onReturnLobby then Run.onReturnLobby(p) end
	sweep()
end
Sandbox.leave = leave

function Sandbox.start()
	-- the dummy never stays down: a new one in the middle of the house (a real run keeps its own handler)
	local runDeath = Ghost.onDeath
	Ghost.onDeath = function(g)
		if not active then
			if runDeath then runDeath(g) end
			return
		end
		token += 1
		local mine = token
		task.wait(RESPAWN)
		if active and mine == token then spawnDummy() end
	end
	Remotes.Sandbox.OnServerEvent:Connect(function(p: Player, action: any, id: any)
		local now = os.clock()
		if now - (lastAsk[p] or 0) < 0.4 then return end
		lastAsk[p] = now
		if action == "enter" then enter(p, id) elseif action == "leave" then leave(p) end
	end)
	Players.PlayerRemoving:Connect(function(p)
		lastAsk[p] = nil
		task.defer(sweep)
	end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			sweep()
		end
	end)
end

return Sandbox
