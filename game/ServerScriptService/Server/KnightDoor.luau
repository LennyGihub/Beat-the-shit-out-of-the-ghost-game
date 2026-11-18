--!strict
-- THE VOID KNIGHT'S DOORWAY. He never appears in the open: he comes through one of the map's KnightSpots (five
-- places on the map's own inside walls, found by tools/build/knight_spots.luau). He spawns in the room he steps
-- into, the doorway is cut out of the REAL wall (Ragdoll.cutDoor: the wall is split around it) and the doorway's own
-- piece of every wall layer is kept as a plug in workspace.KnightDoor, so the wall still looks whole. His entrance
-- (Client/Entrance, SCRIPTS.Knight) burns the outline into that wall with his blade, knocks the piece flat and walks
-- him through. The plugs stop blocking when the piece falls and are gone after the entrance; the doorway stays open
-- for the fight and the wall comes back for the next monster (Ragdoll.restoreWalls, like every hole).
-- A map without spots keeps the old way (Client/Entrance builds a wall for the shot).
local Players = game:GetService("Players")
local Ragdoll = require(script.Parent.Ragdoll)

local KnightDoor = {}
local KICK = 2.95 -- when the cut-out falls (Client/EntrancePose T.Knight.kick)
local W = 5.6 -- doorway width (Client/Entrance draws the cut at this size)
local STAND = 3.6 -- he ends up this far in front of the wall's middle
local MAX_H = 10 -- the spots were checked for a doorway this tall
local rng = Random.new()

local function spots(): { BasePart }
	local m = workspace:FindFirstChild("Mansion")
	local f = m and m:FindFirstChild("KnightSpots")
	local out = {}
	if f then
		for _, p in f:GetChildren() do
			if p:IsA("BasePart") then table.insert(out, p) end
		end
	end
	return out
end

-- one of the spots: a random one at least minDist from every player (where he ends up), else the furthest one
function KnightDoor.pick(minDist: number): BasePart?
	local list = spots()
	if #list == 0 then return nil end
	local players = {}
	for _, p in Players:GetPlayers() do
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and p:GetAttribute("InMatch") then table.insert(players, hrp.Position) end
	end
	local far, best, bestD = {}, nil :: BasePart?, -1
	for _, s in list do
		local stand = s.Position + s.CFrame.LookVector * STAND
		local d = math.huge
		for _, p in players do d = math.min(d, (p - stand).Magnitude) end
		if d >= minDist then table.insert(far, s) end
		if d > bestD then best, bestD = s, d end
	end
	if #far > 0 then return far[rng:NextInteger(1, #far)] end
	return best
end

-- cut the doorway for monster m (h = its height, intro = its entrance's length). Sets the model's attributes
-- KnightDoor (CFrame: the doorway's bottom centre on the wall's middle plane, looking into the room he steps into),
-- KnightDoorW / KnightDoorH, and returns where he must spawn (4.6 above the floor, like MapLoader's spawn points);
-- nil if nothing could be cut there.
function KnightDoor.open(m: Model, spot: BasePart, h: number, intro: number): Vector3?
	local lv = spot.CFrame.LookVector
	local look = Vector3.new(lv.X, 0, lv.Z)
	if look.Magnitude < 0.1 then return nil end
	look = look.Unit
	local base = spot.Position
	local clear = spot:GetAttribute("Clear")
	local dh = math.min(h + 1.2, (type(clear) == "number" and clear or 12) - 0.8, MAX_H)
	local old = workspace:FindFirstChild("KnightDoor")
	if old then old:Destroy() end
	local plugs = Instance.new("Model")
	plugs.Name = "KnightDoor"
	plugs.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	-- the hole in world axes (the walls are square to them): across the wall (every layer on both faces), from the
	-- floor up to his height, the doorway's width along the wall
	local acrossX = math.abs(look.X) > math.abs(look.Z)
	local size = acrossX and Vector3.new(6, dh, W) or Vector3.new(W, dh, 6)
	local n = Ragdoll.cutDoor(CFrame.new(base + Vector3.yAxis * (dh / 2 + 0.02)), size, plugs)
	if n == 0 then
		plugs:Destroy()
		return nil
	end
	plugs.Parent = workspace
	m:SetAttribute("KnightDoor", CFrame.lookAt(base, base + look))
	m:SetAttribute("KnightDoorW", W)
	m:SetAttribute("KnightDoorH", dh)
	-- the plugs block the doorway until the piece falls, and are gone once he is through
	task.delay(KICK + 0.15, function()
		for _, p in plugs:GetDescendants() do
			if p:IsA("BasePart") then p.CanCollide = false; p.CanQuery = false end
		end
	end)
	task.delay(intro + 0.5, function() plugs:Destroy() end)
	return base + look * STAND + Vector3.yAxis * 4.6
end

return KnightDoor
