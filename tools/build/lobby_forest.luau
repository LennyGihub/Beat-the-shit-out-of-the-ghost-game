-- Turns the lobby (built by lobby.luau at (0, 0, 1000)) into a dark forest clearing, keeping its queue rooms, paths,
-- dealer and spawn: removes the swings, benches and old trees; darkens the ground and adds leaf litter, roots, rocks,
-- stumps, fallen logs and a few glowing mushrooms; plants a dense forest of the AI trees in
-- ServerStorage.LobbyAssets (ForestTree1..3) with invisible trunk colliders; builds the SHOP booth around the dealer
-- (walls and a counter so nobody gets behind it, big SHOP sign) and the QUEST BOARD (Lobby.luau adds its prompt).
-- Run in Studio (Edit) after lobby.luau. Re-running replaces what it built.
local SS = game:GetService("ServerStorage")
local Assets = SS:WaitForChild("LobbyAssets")
local L = workspace:WaitForChild("Lobby")
local CX, CZ = 0, 1000
local rng = Random.new(1313)

for _, n in { "Forest", "ShopBooth", "QuestBoard" } do
	local o = L:FindFirstChild(n)
	if o then o:Destroy() end
end
-- the park furniture and the old trees go
for _, c in L:GetChildren() do
	if c.Name == "SwingSet" or c.Name == "Bench" or c.Name == "DeadTreeA" or c.Name == "PineTree" then c:Destroy() end
end

local function model(parent: Instance, name: string): Model
	local m = Instance.new("Model"); m.Name = name; m.Parent = parent
	return m
end
local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, opts: { [string]: any }?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat; p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	if opts then for k, v in opts do (p :: any)[k] = v end end
	p.Parent = parent
	return p
end
local function deco(p: BasePart) p.CanCollide = false; p.CanQuery = false; p.CanTouch = false end
local function light(p: BasePart, range: number, brightness: number, color: Color3)
	local l = Instance.new("PointLight"); l.Range = range; l.Brightness = brightness; l.Color = color; l.Shadows = false; l.Parent = p
end
local function sign(p: BasePart, face: Enum.NormalId, text: string, sub: string?, color: Color3)
	local sg = Instance.new("SurfaceGui"); sg.Face = face; sg.CanvasSize = Vector2.new(600, 160); sg.LightInfluence = 0; sg.Brightness = 1.6; sg.Parent = p
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, sub and 0.72 or 1); t.Font = Enum.Font.Creepster
	t.TextScaled = true; t.Text = text; t.TextColor3 = color; t.TextStrokeTransparency = 0; t.TextStrokeColor3 = Color3.fromRGB(10, 6, 4); t.Parent = sg
	if sub then
		local s = Instance.new("TextLabel"); s.BackgroundTransparency = 1; s.Position = UDim2.fromScale(0, 0.7); s.Size = UDim2.fromScale(1, 0.28)
		s.Font = Enum.Font.SpecialElite; s.TextScaled = true; s.Text = sub; s.TextColor3 = Color3.fromRGB(235, 220, 190); s.TextStrokeTransparency = 0.4; s.Parent = sg
	end
end
local function billboard(p: BasePart, text: string, color: Color3, y: number)
	local b = Instance.new("BillboardGui"); b.Size = UDim2.fromScale(14, 4); b.StudsOffset = Vector3.new(0, y, 0); b.MaxDistance = 260
	b.LightInfluence = 0; b.Brightness = 1.4; b.Parent = p
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 1); t.Font = Enum.Font.Creepster; t.TextScaled = true
	t.Text = text; t.TextColor3 = color; t.TextStrokeTransparency = 0; t.Parent = b
end

-- ground: darker mud and grass, dead leaves everywhere
local ground = L:FindFirstChild("Ground")
if ground then
	for _, p in ground:GetDescendants() do
		if p:IsA("BasePart") then
			if p.Name == "Mud" then p.Color = Color3.fromRGB(58, 50, 42)
			elseif p.Name == "DeadGrass" then p.Color = Color3.fromRGB(46, 50, 34)
			elseif p.Name == "Path" then p.Color = Color3.fromRGB(70, 60, 50) end
		end
	end
end
-- the park's yellow-green fill lights become a faint cold moonlight
for _, f in L:GetChildren() do
	if f.Name == "FillLight" then
		local l = f:FindFirstChildOfClass("PointLight")
		if l then l.Color = Color3.fromRGB(120, 140, 170); l.Brightness = 0.12 end
	end
end

local F = model(L, "Forest")
-- is (x, z) (relative to the lobby centre) kept clear: paths, rooms, shop, quest board, spawn
local ROOMS = { { -66, 62 }, { -22, 62 }, { 22, 62 }, { 66, 62 }, { -66, -62 }, { -22, -62 }, { 22, -62 }, { 66, -62 } }
local function clear(x: number, z: number, margin: number): boolean
	if math.abs(x) < 11 + margin or math.abs(z) < 11 + margin then return false end -- path cross
	for _, r in ROOMS do
		if math.abs(x - r[1]) < 17 + margin and math.abs(z - r[2]) < 17 + margin then return false end
	end
	if math.abs(x) < 16 + margin and z > -44 - margin and z < -10 + margin then return false end -- shop
	if x < -26 + margin and x > -46 - margin and math.abs(z - 4) < 10 + margin then return false end -- quest board
	return true
end

-- leaf litter, rocks, roots, stumps, logs, mushrooms
local LEAF = { Color3.fromRGB(72, 48, 30), Color3.fromRGB(88, 60, 34), Color3.fromRGB(60, 44, 32), Color3.fromRGB(96, 70, 40) }
for i = 1, 420 do
	local x, z = rng:NextNumber(-126, 126), rng:NextNumber(-126, 126)
	local l = part(F, "Leaf", Vector3.new(rng:NextNumber(0.6, 1.4), 0.05, rng:NextNumber(0.4, 0.9)),
		CFrame.new(CX + x, 0.16, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0), LEAF[rng:NextInteger(1, #LEAF)], Enum.Material.Fabric)
	deco(l)
end
for i = 1, 40 do
	local x, z = rng:NextNumber(-124, 124), rng:NextNumber(-124, 124)
	if clear(x, z, 2) then
		local s = rng:NextNumber(1.5, 4.5)
		local r = part(F, "Rock", Vector3.new(s * 1.3, s * 0.7, s), CFrame.new(CX + x, s * 0.25, CZ + z) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6.28), rng:NextNumber(-0.3, 0.3)),
			Color3.fromRGB(62, 64, 66):Lerp(Color3.fromRGB(40, 46, 38), rng:NextNumber()), Enum.Material.Slate)
		if s < 2.5 then deco(r) end
	end
end
for i = 1, 26 do
	local x, z = rng:NextNumber(-120, 120), rng:NextNumber(-120, 120)
	if clear(x, z, 3) then
		if rng:NextNumber() < 0.5 then
			-- stump with a few roots
			local h = rng:NextNumber(1.2, 2.6)
			part(F, "Stump", Vector3.new(h, 2.2, 2.2), CFrame.new(CX + x, h / 2, CZ + z) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(56, 42, 32), Enum.Material.Wood, { Shape = Enum.PartType.Cylinder })
			part(F, "StumpTop", Vector3.new(0.12, 2, 2), CFrame.new(CX + x, h + 0.02, CZ + z) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(120, 96, 66), Enum.Material.Wood, { Shape = Enum.PartType.Cylinder })
			for k = 1, 3 do
				local a = rng:NextNumber(0, 6.28)
				local root = part(F, "Root", Vector3.new(2.6, 0.45, 0.6), CFrame.new(CX + x + math.cos(a) * 1.5, 0.2, CZ + z + math.sin(a) * 1.5) * CFrame.Angles(0, -a, 0.2), Color3.fromRGB(50, 38, 28), Enum.Material.Wood)
				deco(root)
			end
		else
			-- fallen log
			local len = rng:NextNumber(8, 16)
			part(F, "Log", Vector3.new(len, 1.8, 1.8), CFrame.new(CX + x, 0.85, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0) * CFrame.Angles(0, 0, 0), Color3.fromRGB(52, 40, 30), Enum.Material.Wood, { Shape = Enum.PartType.Cylinder })
		end
	end
end
local SHROOM = { Color3.fromRGB(140, 90, 220), Color3.fromRGB(90, 200, 160) }
for i = 1, 22 do
	local x, z = rng:NextNumber(-118, 118), rng:NextNumber(-118, 118)
	if clear(x, z, 1) then
		local c = SHROOM[rng:NextInteger(1, 2)]
		for k = 1, rng:NextInteger(2, 4) do
			local ox, oz = rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)
			local h = rng:NextNumber(0.4, 0.9)
			local stem = part(F, "ShroomStem", Vector3.new(h, 0.18, 0.18), CFrame.new(CX + x + ox, h / 2, CZ + z + oz) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(200, 196, 180), Enum.Material.SmoothPlastic, { Shape = Enum.PartType.Cylinder })
			deco(stem)
			local cap = part(F, "ShroomCap", Vector3.new(0.6, 0.25, 0.6), CFrame.new(CX + x + ox, h + 0.05, CZ + z + oz), c, Enum.Material.Neon)
			deco(cap)
			if k == 1 then light(cap, 8, 0.35, c) end
		end
	end
end

-- the forest: the AI trees, scaled and turned at random, each with an invisible trunk collider
local TREES = {}
for _, n in { "ForestTree1", "ForestTree2", "ForestTree3" } do
	local t = Assets:FindFirstChild(n)
	if t then table.insert(TREES, t) end
end
local planted = 0
local function plantTree(x: number, z: number)
	if #TREES == 0 then return end
	local src = TREES[rng:NextInteger(1, #TREES)]
	local t = src:Clone()
	local s = rng:NextNumber(0.85, 1.35)
	if t:IsA("Model") then t:ScaleTo(s) end
	t:PivotTo(CFrame.new(CX + x, 0, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0))
	local cf, size = t:GetBoundingBox()
	t:PivotTo(t:GetPivot() + Vector3.new(0, size.Y / 2 - cf.Position.Y - 0.3, 0))
	for _, p in t:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false end
	end
	t.Parent = F
	local trunk = part(F, "TrunkCollider", Vector3.new(14, 2.6 * s, 2.6 * s), CFrame.new(CX + x, 7, CZ + z) * CFrame.Angles(0, 0, math.pi / 2), Color3.new(), Enum.Material.Wood, { Shape = Enum.PartType.Cylinder, Transparency = 1 })
	trunk.CanQuery = false; trunk.CanTouch = false
	planted += 1
end
-- inner trees between the rooms, then a thick wall of forest toward the fence
for i = 1, 60 do
	local x, z = rng:NextNumber(-100, 100), rng:NextNumber(-100, 100)
	if clear(x, z, 4) then plantTree(x, z) end
end
for i = 1, 260 do
	local a = rng:NextNumber(0, math.pi * 2)
	local r = rng:NextNumber(96, 128)
	local x, z = math.clamp(math.cos(a) * r, -127, 127), math.clamp(math.sin(a) * r, -127, 127)
	if clear(x, z, 2) then plantTree(x, z) end
end

-- the SHOP booth around the Hooded Dealer (at (0, 974), facing +Z): back and side walls, a counter in front,
-- a roof with a big SHOP sign. Closed all round so nobody walks behind the dealer.
local B = model(L, "ShopBooth")
local WOOD = Color3.fromRGB(70, 50, 36)
local WOOD_D = Color3.fromRGB(46, 32, 24)
local TRIM = Color3.fromRGB(150, 30, 26)
local bz = CZ - 26
part(B, "BackWall", Vector3.new(16, 13, 1), CFrame.new(CX, 6.5, bz - 5), WOOD_D, Enum.Material.WoodPlanks)
for _, s in { -1, 1 } do
	part(B, "SideWall", Vector3.new(1, 11, 11.5), CFrame.new(CX + s * 7.5, 5.5, bz + 0.6), WOOD_D, Enum.Material.WoodPlanks)
	part(B, "Post", Vector3.new(1.2, 13, 1.2), CFrame.new(CX + s * 7.5, 6.5, bz + 6.2), WOOD, Enum.Material.Wood)
	local lan = part(B, "Lantern", Vector3.new(0.9, 1.3, 0.9), CFrame.new(CX + s * 7.5, 10.2, bz + 7.2), Color3.fromRGB(255, 170, 80), Enum.Material.Neon)
	deco(lan)
	light(lan, 22, 1.1, Color3.fromRGB(255, 160, 80))
end
-- the counter across the open front (waist high, solid): customers stand in front of it
part(B, "Counter", Vector3.new(14, 3.6, 1.6), CFrame.new(CX, 1.8, bz + 6.4), WOOD, Enum.Material.WoodPlanks)
part(B, "CounterTop", Vector3.new(14.6, 0.35, 2.2), CFrame.new(CX, 3.75, bz + 6.4), WOOD_D, Enum.Material.Wood)
part(B, "CounterTrim", Vector3.new(14.2, 0.5, 0.2), CFrame.new(CX, 3.0, bz + 7.25), TRIM, Enum.Material.Fabric)
-- an invisible wall above the counter: no jumping over
part(B, "NoJump", Vector3.new(14, 9, 0.6), CFrame.new(CX, 8.2, bz + 6.4), Color3.new(), Enum.Material.SmoothPlastic, { Transparency = 1 })
part(B, "Roof", Vector3.new(18, 0.8, 15), CFrame.new(CX, 13.4, bz + 1) * CFrame.Angles(-0.12, 0, 0), WOOD_D, Enum.Material.WoodPlanks)
for i = -3, 3 do -- striped awning edge
	local a = part(B, "Awning", Vector3.new(2.2, 1.4, 0.3), CFrame.new(CX + i * 2.3, 12.3, bz + 8.1), i % 2 == 0 and TRIM or Color3.fromRGB(220, 200, 160), Enum.Material.Fabric)
	deco(a)
end
local board = part(B, "SignBoard", Vector3.new(15, 4.2, 0.6), CFrame.new(CX, 17.4, bz + 7.4), WOOD_D, Enum.Material.Wood)
sign(board, Enum.NormalId.Front, "SHOP", "ULTIMATES  -  MAPS  -  ROBUX", Color3.fromRGB(255, 150, 60))
sign(board, Enum.NormalId.Back, "SHOP", "ULTIMATES  -  MAPS  -  ROBUX", Color3.fromRGB(255, 150, 60))
-- (the sign faces the plaza: the board's Front is -Z, so turn it)
board.CFrame = board.CFrame * CFrame.Angles(0, math.pi, 0)
for _, s in { -1, 1 } do
	local f = part(B, "SignFrame", Vector3.new(0.3, 4.6, 0.3), CFrame.new(CX + s * 7.6, 17.4, bz + 7.75), Color3.fromRGB(255, 110, 40), Enum.Material.Neon)
	deco(f)
end
local glow = part(B, "SignLight", Vector3.new(1, 1, 1), CFrame.new(CX, 16, bz + 10), Color3.new(), Enum.Material.SmoothPlastic, { Transparency = 1 })
deco(glow)
light(glow, 18, 0.9, Color3.fromRGB(255, 140, 60))
billboard(board, "SHOP", Color3.fromRGB(255, 150, 60), 4.5)
-- crates and barrels beside the booth
for _, c in { { -10, 3 }, { -10.5, -1 }, { 10.4, 2 }, { 11, -2.5 } } do
	part(B, "Crate", Vector3.new(2.6, 2.6, 2.6), CFrame.new(CX + c[1], 1.3, bz + c[2]) * CFrame.Angles(0, rng:NextNumber(-0.4, 0.4), 0), Color3.fromRGB(96, 72, 48), Enum.Material.WoodPlanks)
end
part(B, "Barrel", Vector3.new(3.2, 2.2, 2.2), CFrame.new(CX - 10, 4.3, bz + 3) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(80, 56, 36), Enum.Material.Wood, { Shape = Enum.PartType.Cylinder })
-- the dealer's old sign over the cart now names him
local vend = L:FindFirstChild("UltVendor")
local vs = vend and vend:FindFirstChild("VendorSign", true)
local vt = vs and vs:FindFirstChildOfClass("SurfaceGui")
local vl = vt and vt:FindFirstChildOfClass("TextLabel")
if vl then vl.Text = "THE HOODED DEALER" end

-- the QUEST BOARD (west of the spawn, facing the plaza): a notice board covered in notes, its own sign and lantern
local Q = model(L, "QuestBoard")
local qx, qz = CX - 36, CZ + 4
local qcf = CFrame.new(qx, 0, qz) * CFrame.Angles(0, -math.pi / 2, 0) -- its front faces +X (the plaza)
local function qp(name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material, opts: { [string]: any }?): BasePart
	return part(Q, name, size, qcf * rel, color, mat, opts)
end
for _, s in { -1, 1 } do qp("Post", Vector3.new(0.8, 10, 0.8), CFrame.new(s * 5, 5, 0), WOOD, Enum.Material.Wood) end
local qboard = qp("Board", Vector3.new(10.5, 6, 0.5), CFrame.new(0, 5.2, 0), Color3.fromRGB(96, 74, 52), Enum.Material.WoodPlanks)
qp("Roof", Vector3.new(12, 0.5, 2.6), CFrame.new(0, 10.3, 0.2) * CFrame.Angles(-0.25, 0, 0), WOOD_D, Enum.Material.WoodPlanks)
local NOTE = { Color3.fromRGB(226, 214, 180), Color3.fromRGB(210, 196, 160), Color3.fromRGB(190, 70, 60), Color3.fromRGB(236, 226, 200) }
for i = 1, 11 do
	local n = qp("Note", Vector3.new(rng:NextNumber(1.2, 2), rng:NextNumber(1.4, 2.2), 0.06), CFrame.new(rng:NextNumber(-4.2, 4.2), rng:NextNumber(3.2, 7.2), -0.29) * CFrame.Angles(0, 0, rng:NextNumber(-0.2, 0.2)), NOTE[rng:NextInteger(1, #NOTE)], Enum.Material.Fabric)
	deco(n)
	local pin = qp("Pin", Vector3.new(0.18, 0.18, 0.12), n.CFrame:ToObjectSpace(qcf):Inverse() * CFrame.new(0, 0, 0), Color3.fromRGB(200, 40, 30), Enum.Material.SmoothPlastic)
	pin.CFrame = n.CFrame * CFrame.new(0, n.Size.Y / 2 - 0.25, -0.06)
	deco(pin)
end
local qsign = qp("QuestSign", Vector3.new(10, 2.6, 0.4), CFrame.new(0, 12, 0), WOOD_D, Enum.Material.Wood)
sign(qsign, Enum.NormalId.Front, "QUESTS", "DAILY QUESTS  -  ACHIEVEMENTS", Color3.fromRGB(120, 200, 255))
sign(qsign, Enum.NormalId.Back, "QUESTS", nil, Color3.fromRGB(120, 200, 255))
billboard(qsign, "QUESTS", Color3.fromRGB(120, 200, 255), 3.5)
local qlan = qp("Lantern", Vector3.new(0.9, 1.3, 0.9), CFrame.new(5.6, 9, -0.8), Color3.fromRGB(150, 210, 255), Enum.Material.Neon)
deco(qlan)
light(qlan, 20, 1, Color3.fromRGB(150, 200, 255))
Q.PrimaryPart = qboard

return string.format("forest: %d trees, %d parts; shop booth + quest board built", planted, #F:GetDescendants())
