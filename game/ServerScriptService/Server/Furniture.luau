-- Destructible + carryable furniture. Models tagged "Furniture" in workspace.Mansion.Furniture.
local CS = game:GetService("CollectionService")
local SS = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local Remotes = require(script.Parent.Remotes)

local Furniture = {}
Furniture.thrown = {} :: { [Model]: { by: Player?, t: number, power: number } }
local template: Model? = nil
local debrisFolder: Folder
local rng = Random.new()

function Furniture.init()
	local live = workspace:WaitForChild("Mansion"):WaitForChild("Furniture") :: Model
	template = live:Clone()
	template.Name = "FurnitureTemplate"
	template.Parent = SS
	debrisFolder = Instance.new("Folder")
	debrisFolder.Name = "Debris"
	debrisFolder.Parent = workspace
end

-- a new map was loaded into workspace.Mansion: its furniture becomes the template for every fight
function Furniture.recapture()
	local live = workspace.Mansion:FindFirstChild("Furniture")
	if not live then return end
	if template then template:Destroy() end
	template = live:Clone()
	template.Name = "FurnitureTemplate"
	template.Parent = SS
end

function Furniture.folder(): Instance?
	local m = workspace:FindFirstChild("Mansion")
	return m and m:FindFirstChild("Furniture")
end

function Furniture.reset()
	Furniture.thrown = {}
	local cur = Furniture.folder()
	if cur then cur:Destroy() end
	debrisFolder:ClearAllChildren()
	if template then
		local n = template:Clone()
		n.Name = "Furniture"
		n.Parent = workspace.Mansion
	end
end

function Furniture.isValid(m: any): boolean
	return typeof(m) == "Instance" and m:IsA("Model") and m.Parent ~= nil and CS:HasTag(m, "Furniture")
		and not m:GetAttribute("Broken") and m.PrimaryPart ~= nil
end

function Furniture.weight(m: Model): number return m:GetAttribute("Weight") or 1 end

-- Break a piece into its parts and fling them.
function Furniture.smash(m: Model, vel: Vector3, strength: number?)
	if not Furniture.isValid(m) and not (m and m.Parent and m:GetAttribute("CarriedBy")) then return end
	if m:GetAttribute("Broken") then return end
	m:SetAttribute("Broken", true)
	CS:RemoveTag(m, "Furniture")
	Furniture.thrown[m] = nil
	local cf, size = m:GetBoundingBox()
	Remotes.Fx:FireAllClients("Smash", cf.Position, size.Magnitude, m:GetAttribute("Kind"))
	local s = strength or vel.Magnitude
	local parts = {}
	for _, d in m:GetDescendants() do
		if d:IsA("JointInstance") or d:IsA("WeldConstraint") or d:IsA("Light") or d:IsA("Fire") then d:Destroy()
		elseif d:IsA("BasePart") then table.insert(parts, d) end
	end
	for _, p in parts do
		p.Anchored = false
		p.CanCollide = p.Size.Magnitude > 0.8
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = false
		p.CollisionGroup = "Debris"
		p.Parent = debrisFolder
		local spread = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(0.3, 1.2), rng:NextNumber(-1, 1)) * (14 + s * 0.22)
		p.AssemblyLinearVelocity = vel * 0.5 + spread
		p.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-14, 14), rng:NextNumber(-14, 14), rng:NextNumber(-14, 14))
		Debris:AddItem(p, rng:NextNumber(6, 10))
	end
	m:Destroy()
	-- keep the debris count sane
	local all = debrisFolder:GetChildren()
	if #all > 600 then for i = 1, #all - 600 do all[i]:Destroy() end end
end

-- Furniture whose parts overlap a sphere
function Furniture.near(pos: Vector3, radius: number): { Model }
	local f = Furniture.folder()
	if not f then return {} end
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = { f }
	op.RespectCanCollide = false
	local found, out = {}, {}
	for _, p in workspace:GetPartBoundsInRadius(pos, radius, op) do
		local m: Instance? = p.Parent
		while m and m.Parent ~= f do m = m.Parent end
		if m and not found[m] and Furniture.isValid(m) and not (m :: Model):GetAttribute("CarriedBy") then
			found[m] = true
			table.insert(out, m :: Model)
		end
	end
	return out
end

function Furniture.grab(player: Player, m: Model): boolean
	local char = player and player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp or not Furniture.isValid(m) or m:GetAttribute("CarriedBy") then return false end
	local prim = m.PrimaryPart :: BasePart
	local cf, size = m:GetBoundingBox()
	m:SetAttribute("CarriedBy", player.UserId)
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.CanCollide = false; p.CanTouch = false; p.Massless = true; p.CollisionGroup = "Carried"
		end
	end
	prim.Anchored = false
	local w = Instance.new("Weld")
	w.Name = "CarryWeld"
	w.Part0 = hrp
	w.Part1 = prim
	-- held over the head, a little in front
	w.C0 = CFrame.new(0, 2.8 + size.Y / 2, -1.6 - size.Z * 0.2)
	w.C1 = prim.CFrame:ToObjectSpace(CFrame.new(cf.Position) * (hrp.CFrame - hrp.Position))
	w.Parent = prim
	return true
end

function Furniture.release(m: Model)
	if not m or not m.Parent then return end
	local prim = m.PrimaryPart
	if prim then
		local w = prim:FindFirstChild("CarryWeld")
		if w then w:Destroy() end
	end
	m:SetAttribute("CarriedBy", nil)
end

function Furniture.throw(player: Player?, m: Model, dir: Vector3, power: number)
	if not m or not m.Parent or m:GetAttribute("Broken") then return end
	Furniture.release(m)
	local prim = m.PrimaryPart :: BasePart
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.CanCollide = true; p.CanTouch = true; p.Massless = false; p.CollisionGroup = "Thrown"
		end
	end
	prim.Anchored = false
	pcall(function() prim:SetNetworkOwner(nil) end)
	prim.AssemblyLinearVelocity = dir * power + Vector3.new(0, 10, 0)
	prim.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-6, 6), rng:NextNumber(-6, 6), rng:NextNumber(-6, 6))
	Furniture.thrown[m] = { by = player, t = os.clock(), power = power }
	local char = player and player.Character
	local conns = {}
	local function onTouch(hit: BasePart)
		if not Furniture.thrown[m] then return end
		if hit:IsDescendantOf(m) or (char and hit:IsDescendantOf(char)) then return end
		if os.clock() - Furniture.thrown[m].t < 0.08 then return end
		for _, c in conns do c:Disconnect() end
		Furniture.smash(m, prim.AssemblyLinearVelocity, power)
	end
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then table.insert(conns, p.Touched:Connect(onTouch)) end
	end
	task.delay(5, function()
		if Furniture.thrown[m] and m.Parent then Furniture.smash(m, Vector3.zero, 20) end
	end)
end

-- launch a piece straight at a point (ultimate barrages / black holes)
function Furniture.flingAt(m: Model, target: Vector3, by: Player?, power: number)
	if not Furniture.isValid(m) or m:GetAttribute("CarriedBy") then return end
	local from = m:GetBoundingBox().Position
	local to = target - from
	if to.Magnitude < 0.5 then return end
	-- lift it a bit first so it does not scrape the floor
	local prim = m.PrimaryPart :: BasePart
	prim.CFrame += Vector3.new(0, 2, 0)
	Furniture.throw(by, m, (to + Vector3.new(0, to.Magnitude * 0.08, 0)).Unit, power)
end

-- furniture models sorted by distance to a point
function Furniture.nearest(pos: Vector3, maxDist: number, count: number): { Model }
	local f = Furniture.folder()
	if not f then return {} end
	local list = {}
	for _, m in f:GetChildren() do
		if m:IsA("Model") and Furniture.isValid(m) and not m:GetAttribute("CarriedBy") and m.PrimaryPart then
			local d = (m.PrimaryPart.Position - pos).Magnitude
			if d < maxDist then table.insert(list, { m = m, d = d }) end
		end
	end
	table.sort(list, function(a, b) return a.d < b.d end)
	local out = {}
	for i = 1, math.min(count, #list) do out[i] = list[i].m end
	return out
end

return Furniture
