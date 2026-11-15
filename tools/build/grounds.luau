-- Dark forest around the mansion yard, yard boundaries (front yard only, nothing behind the house) and the rail line.
local SSv = game:GetService("ServerStorage")
local A = SSv:WaitForChild("LobbyAssets")
local old = workspace:FindFirstChild("Grounds"); if old then old:Destroy() end
local G = Instance.new("Model"); G.Name = "Grounds"; G.Parent = workspace
local rng = Random.new(4242)
local INVIS = st(M.SmoothPlastic, nil, Color3.new(0, 0, 0))
local FENCE = st(M.Wood, "PS2_DarkBeam1", Color3.fromRGB(70, 56, 44))

local function plant(name: string, x: number, z: number, yaw: number, scale: number, parent: Instance)
	local m = (A:FindFirstChild(name) :: Model):Clone()
	if scale ~= 1 then m:ScaleTo(scale) end
	m:PivotTo(CFrame.new(x, 0, z) * CFrame.Angles(0, yaw, 0))
	local cf, sz = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + Vector3.new(0, sz.Y / 2 - cf.Position.Y - 0.3, 0))
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CastShadow = true end
	end
	m.Parent = parent
end

-- invisible walls: yard is x -95..95, z 60..165 (front only)
local walls = model(G, "Walls")
local function wall(x1, z1, x2, z2) box(walls, "Wall", x1, -2, z1, x2, 60, z2, INVIS, { t = 1 }) end
wall(-97, 50, -95, 168)      -- left
wall(95, 50, 97, 168)        -- right
wall(-97, 165, 97, 167)      -- far edge
wall(-97, 50, -80, 52)       -- block the gap beside the house (left)
wall(80, 50, 97, 52)         -- (right)

-- broken fence so the edge reads as an edge
local fence = model(G, "Fence")
local function fenceLine(x1, z1, x2, z2)
	local len = math.sqrt((x2 - x1) ^ 2 + (z2 - z1) ^ 2)
	local n = math.floor(len / 3)
	for i = 0, n do
		if rng:NextNumber() < 0.85 then
			local t = i / n
			local x, z = x1 + (x2 - x1) * t, z1 + (z2 - z1) * t
			part(fence, "Post", Vector3.new(0.5, rng:NextNumber(3.5, 5.5), 0.5), CFrame.new(x, 2.2, z) * CFrame.Angles(rng:NextNumber(-0.15, 0.15), 0, rng:NextNumber(-0.15, 0.15)), FENCE)
		end
	end
	for _, y in { 1.6, 3.4 } do
		local seg = 0
		while seg < len do
			local l = rng:NextNumber(4, 10)
			if rng:NextNumber() < 0.75 then
				local t1, t2 = seg / len, math.min(seg + l, len) / len
				local a = Vector3.new(x1 + (x2 - x1) * t1, y, z1 + (z2 - z1) * t1)
				local b2 = Vector3.new(x1 + (x2 - x1) * t2, y + rng:NextNumber(-0.4, 0.4), z1 + (z2 - z1) * t2)
				part(fence, "Rail", Vector3.new(0.25, 0.4, (b2 - a).Magnitude), CFrame.lookAt((a + b2) / 2, b2), FENCE, DECO)
			end
			seg += l + rng:NextNumber(0, 3)
		end
	end
end
fenceLine(-95, 55, -95, 165); fenceLine(95, 55, 95, 165); fenceLine(-95, 165, 95, 165)
fenceLine(-95, 52, -80, 52); fenceLine(80, 52, 95, 52)

-- rail line across the yard and into the trees
local rail = model(G, "Railway")
local Z = 150
box(rail, "Ballast", -260, 0, Z - 4, 260, 0.5, Z + 4, st(M.Pebble, nil, Color3.fromRGB(90, 86, 80)), DECO)
for x = -258, 258, 3 do box(rail, "Sleeper", x - 0.6, 0.5, Z - 3.4, x + 0.6, 0.85, Z + 3.4, st(M.Wood, nil, Color3.fromRGB(70, 52, 38)), DECO) end
for _, dz in { -2.4, 2.4 } do box(rail, "Rail", -260, 0.85, Z + dz - 0.2, 260, 1.35, Z + dz + 0.2, st(M.Metal, nil, Color3.fromRGB(110, 106, 100)), DECO) end

-- dark forest ring (pines + dead trees). Nothing is reachable past the walls.
local forest = model(G, "Forest")
local function inYard(x, z) return x > -100 and x < 100 and z > 45 and z < 170 end
local function inHouse(x, z) return x > -86 and x < 92 and z > -68 and z < 66 end
local count = 0
for i = 1, 520 do
	local x, z = rng:NextNumber(-240, 240), rng:NextNumber(-140, 300)
	if not inYard(x, z) and not inHouse(x, z) and math.abs(z - Z) > 6 and not (z > 900) then
		local pine = rng:NextNumber() < 0.7
		plant(pine and "PineTree" or "DeadTreeA", x, z, rng:NextNumber(0, 6.28), pine and rng:NextNumber(1.4, 2.4) or rng:NextNumber(1.1, 1.7), forest)
		count += 1
	end
end
-- a few dead trees inside the yard edges for atmosphere
for _, p in { { -80, 90 }, { 82, 120 }, { -70, 158 }, { 60, 160 }, { -86, 130 } } do plant("DeadTreeA", p[1], p[2], rng:NextNumber(0, 6), 1.2, forest) end
-- dark forest floor
box(G, "ForestFloor", -300, -0.9, -160, 300, 0.02, 320, st(M.Grass, nil, Color3.fromRGB(34, 38, 28)), DECO)
return "trees: " .. count
