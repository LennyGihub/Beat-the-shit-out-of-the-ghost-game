-- Swaps the house for the chosen map. Maps live in ServerStorage.Maps.<id> (Structure, Furniture, Decor, Lights,
-- optional GhostSpawns folder of parts, optional SpawnInside attribute). workspace.Mansion always holds the loaded
-- map's children, so Ghost / Inventory / Furniture keep working on "workspace.Mansion.Structure / .Furniture".
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Config = require(RS.Shared.Config)
local Maps = require(RS.Shared.Maps)
local Furniture = require(script.Parent.Furniture)

local MapLoader = {}
local current = "Mansion"
local DEFAULT_SPAWNS = {
	Vector3.new(0, 27.6, -24), Vector3.new(-57, 6.6, -30), Vector3.new(57, 6.6, 30),
	Vector3.new(-57, 6.6, 30), Vector3.new(-18, 27.6, -44), Vector3.new(18, 6.6, -44),
}

local function folder(): Folder
	local f = SS:FindFirstChild("Maps")
	if not f then
		f = Instance.new("Folder")
		f.Name = "Maps"
		f.Parent = SS
	end
	return f :: Folder
end

-- the Mansion that is in the place becomes the stored "Mansion" map (once)
function MapLoader.init()
	local f = folder()
	local live = workspace:WaitForChild("Mansion")
	if not f:FindFirstChild("Mansion") then
		local m = Instance.new("Model")
		m.Name = "Mansion"
		for _, c in live:GetChildren() do c:Clone().Parent = m end
		m.Parent = f
	end
	current = live:GetAttribute("MapId") or "Mansion"
	RS:SetAttribute("MapId", current)
end

function MapLoader.current(): string return current end

function MapLoader.exists(id: string): boolean
	return Maps.byId[id] ~= nil and folder():FindFirstChild(id) ~= nil
end

-- load a map into workspace.Mansion (no-op if it is already there)
function MapLoader.load(id: string): boolean
	if not MapLoader.exists(id) then id = "Mansion" end
	if id == current then
		Furniture.recapture()
		return true
	end
	local src = folder():FindFirstChild(id) :: Model
	local live = workspace:FindFirstChild("Mansion") :: Model
	for _, c in live:GetChildren() do c:Destroy() end
	for _, c in src:GetChildren() do c:Clone().Parent = live end
	-- the map's settings (SpawnInside, MinY, CeilingY, AtSea...) replace the old map's
	for k in live:GetAttributes() do live:SetAttribute(k, nil) end
	for k, v in src:GetAttributes() do live:SetAttribute(k, v) end
	live:SetAttribute("MapId", id)
	current = id
	RS:SetAttribute("MapId", id)
	Furniture.recapture()
	MapLoader.setSea(live:GetAttribute("AtSea") == true)
	MapLoader.hookRescue(live)
	return true
end

-- the ship map floats at sea: the forest around the yard is put away while it is loaded (and comes back after)
local hiddenForest: Instance? = nil
function MapLoader.setSea(on: boolean)
	local grounds = workspace:FindFirstChild("Grounds")
	if on and not hiddenForest then
		local f = grounds and grounds:FindFirstChild("Forest")
		if f then hiddenForest = f; f.Parent = SS end
	elseif not on and hiddenForest then
		hiddenForest.Parent = grounds
		hiddenForest = nil
	end
end

-- parts with the Rescue attribute (the sea): a player who falls in is put back at the map's spawn point. The sea
-- also runs under the ship's decks (just below the lowest one): a touch from inside the hull (a hard landing on the
-- bottom deck sinks the feet into it) does not count
function MapLoader.hookRescue(live: Instance)
	-- the hull: the box of the outside walls
	local hullMin, hullMax = nil :: Vector3?, nil :: Vector3?
	local ext = live:FindFirstChild("Structure") and live.Structure:FindFirstChild("Exterior")
	if ext then
		local mn, mx = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
		for _, d in ext:GetDescendants() do
			if d:IsA("BasePart") and d.CanCollide and d.Size.Y > 6 then
				local half = d.CFrame:VectorToWorldSpace(d.Size / 2)
				half = Vector3.new(math.abs(half.X), math.abs(half.Y), math.abs(half.Z))
				mn = mn:Min(d.Position - half); mx = mx:Max(d.Position + half)
			end
		end
		if mx.X > mn.X then hullMin, hullMax = mn, mx end
	end
	local function inHull(pos: Vector3): boolean
		return hullMin ~= nil and hullMax ~= nil and pos.X > hullMin.X and pos.X < hullMax.X and pos.Z > hullMin.Z
			and pos.Z < hullMax.Z and pos.Y > hullMin.Y - 1
	end
	for _, d in live:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("Rescue") then
			d.Touched:Connect(function(hit)
				local ch = hit.Parent
				local p = ch and game:GetService("Players"):GetPlayerFromCharacter(ch)
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
				if p and hrp and not ch:GetAttribute("Rescuing") and not inHull(hrp.Position) then
					ch:SetAttribute("Rescuing", true)
					hrp.AssemblyLinearVelocity = Vector3.zero
					ch:PivotTo(CFrame.new(MapLoader.spawnInside() + Vector3.new(0, 3, 0)))
					task.delay(0.5, function() if ch.Parent then ch:SetAttribute("Rescuing", nil) end end)
				end
			end)
		end
	end
end

-- where the monster can appear: the map's GhostSpawns parts, else the Mansion's points
function MapLoader.ghostSpawns(): { Vector3 }
	local live = workspace:FindFirstChild("Mansion")
	local gs = live and live:FindFirstChild("GhostSpawns")
	if gs then
		local out = {}
		for _, p in gs:GetChildren() do
			if p:IsA("BasePart") then table.insert(out, p.Position) end
		end
		if #out > 0 then return out end
	end
	return DEFAULT_SPAWNS
end

-- where players stand when a fight starts
-- a random spot anywhere in the house for the next monster: on a floor, under a roof, with room to stand (no
-- wall or furniture), at least minDist from every player. Falls back to a random one of the map's spawn points
-- (one far enough from the players if possible). Returns a point ~4.6 studs above the floor (Ghost.spawn
-- puts walkers on the floor itself).
local spawnRng = Random.new()
function MapLoader.randomGhostSpawn(players: { Vector3 }, minDist: number): Vector3
	local function farEnough(v: Vector3): boolean
		for _, p in players do
			if (p - v).Magnitude < minDist then return false end
		end
		return true
	end
	local live = workspace:FindFirstChild("Mansion")
	local struct = live and live:FindFirstChild("Structure")
	if live and struct then
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Include
		rp.FilterDescendantsInstances = { struct }
		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { live }
		-- a map with its own floor levels (attribute Floors = "2,23,44": the ship's three decks) is searched on
		-- each of them; the others on the usual two storeys
		local levels = {} :: { number }
		local fl = live:GetAttribute("Floors")
		if type(fl) == "string" then
			for n in string.gmatch(fl, "%-?[%d%.]+") do table.insert(levels, tonumber(n) :: number) end
		end
		for _ = 1, 40 do
			-- the house footprint (x -80..80, z -60..60, or the loaded map's own outside walls when it is bigger: the
			-- ship, RS MapMin / MapMax from Ghost.houseBounds); from below the upper floor or from above it
			local x0, x1, z0, z1 = -74, 74, -54, 54
			local mmn, mmx = RS:GetAttribute("MapMin"), RS:GetAttribute("MapMax")
			if typeof(mmn) == "Vector3" and typeof(mmx) == "Vector3" then
				x0, x1 = math.min(x0, mmn.X + 6), math.max(x1, mmx.X - 6)
				z0, z1 = math.min(z0, mmn.Z + 6), math.max(z1, mmx.Z - 6)
			end
			local x, z = spawnRng:NextNumber(x0, x1), spawnRng:NextNumber(z0, z1)
			local startY, maxY, minY = spawnRng:NextNumber() < 0.6 and 18 or 42, 30, -math.huge
			if #levels > 0 then
				local f = levels[spawnRng:NextInteger(1, #levels)]
				startY, maxY, minY = f + 16, f + 2, f - 2 -- (that level's own floor, not the one seen through a stairwell)
			end
			local down = workspace:Raycast(Vector3.new(x, startY, z), Vector3.new(0, -30, 0), rp)
			-- floors only up to the upper storey (y 23): above 30 is the top of a tall hall's ceiling (the attic)
			if down and down.Normal.Y > 0.9 and down.Position.Y < maxY and down.Position.Y > minY then
				local floorY = down.Position.Y
				local at = Vector3.new(x, floorY + 4.6, z)
				local roof = workspace:Raycast(Vector3.new(x, floorY + 3, z), Vector3.new(0, 40, 0), rp)
				if roof and farEnough(at) then
					local clear = true
					for _, h in workspace:GetPartBoundsInBox(CFrame.new(x, floorY + 4.2, z), Vector3.new(5, 7, 5), op) do
						if h.Position.Y + h.Size.Y / 2 > floorY + 0.6 and h.Transparency < 1 then clear = false; break end
					end
					if clear then return at end
				end
			end
		end
	end
	local spots = MapLoader.ghostSpawns()
	local ok = {}
	for _, s in spots do if farEnough(s) then table.insert(ok, s) end end
	if #ok == 0 then ok = spots end
	return ok[spawnRng:NextInteger(1, #ok)]
end

function MapLoader.spawnInside(): Vector3
	local live = workspace:FindFirstChild("Mansion")
	local v = live and live:GetAttribute("SpawnInside")
	if typeof(v) == "Vector3" then return v end
	return Config.SpawnInside
end

return MapLoader
