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

-- parts with the Rescue attribute (the sea): a player who falls in is put back at the map's spawn point
function MapLoader.hookRescue(live: Instance)
	for _, d in live:GetDescendants() do
		if d:IsA("BasePart") and d:GetAttribute("Rescue") then
			d.Touched:Connect(function(hit)
				local ch = hit.Parent
				local p = ch and game:GetService("Players"):GetPlayerFromCharacter(ch)
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
				if p and hrp and not ch:GetAttribute("Rescuing") then
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
function MapLoader.spawnInside(): Vector3
	local live = workspace:FindFirstChild("Mansion")
	local v = live and live:GetAttribute("SpawnInside")
	if typeof(v) == "Vector3" then return v end
	return Config.SpawnInside
end

return MapLoader
