-- The lobby's DETAIL PASS (after lobby, lobby_forest, lobby_remake; standalone, safe to re-run).
-- The park is a cross of two paths round (0, 0, 1000). This pass puts something at the END of each path and fills
-- the clearing between the paths and the queue cabins:
--   north end  : the SHOP (the Hooded Dealer's booth is moved there) with a paved forecourt, torches, banners, stock
--   west end   : the QUEST BOARD (moved there) with a notice yard, wanted posters and a desk
--   south end  : the BESTIARY ALTAR (new: Lobby.BestiaryAltar, part "Prompt" gets the prompt in Server/Lobby)
--   east end   : the leaderboards (already there) get a forecourt and torches
--   the middle : a round cobbled plaza with the ghost fountain and a signpost; the spawn moves 10 studs south
--   the clearing: a graveyard, a camp (fire, tent, wagon, well), a pumpkin patch with scarecrows, a pond with a dock,
--                an old playground; gates on the four paths, curb stones, fireflies, crows.
-- Everything new is in Lobby.Detail (deleted and rebuilt on a re-run). EVERY PROP IS HAND-BUILT from plain blocks in
-- the game's PS2 look (BUILD.* below: gate, fountain, wagon, well, scarecrow, graves, pumpkins, camp fire, book
-- altar). No AI meshes: a first version used generate_mesh props and the user threw them out.
local SS = game:GetService("ServerStorage")
local lobby = workspace:WaitForChild("Lobby")
local assets = SS:WaitForChild("LobbyAssets")
local CX, CZ = 0, 1000
local rng = Random.new(20261117)
local function C(r, g, b) return Color3.fromRGB(r, g, b) end

-- the AI props of the first version are deleted wherever they still are
for _, n in { "LobbyFountain", "LobbyWagon", "LobbyWell", "LobbyScarecrow", "LobbyTombstones", "LobbyBookAltar", "LobbyGate", "LobbyCampfire", "LobbyPumpkins" } do
	for _, where in { workspace, assets } do
		local old = where:FindFirstChild(n)
		while old do old:Destroy(); old = where:FindFirstChild(n) end
	end
end

local oldDetail = lobby:FindFirstChild("Detail")
if oldDetail then oldDetail:Destroy() end
local oldAltar = lobby:FindFirstChild("BestiaryAltar")
if oldAltar then oldAltar:Destroy() end
local detail = Instance.new("Model")
detail.Name = "Detail"
detail.Parent = lobby
local count = 0

local function group(name: string, parent: Instance?): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent or detail
	return m
end
-- solid = players bump into it; everything else is pure decoration
local function P(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, variant: string?, solid: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat
	if variant then p.MaterialVariant = variant end
	p.Anchored = true; p.CanCollide = solid == true; p.CanTouch = false; p.CanQuery = solid == true; p.CastShadow = size.Magnitude > 3
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	count += 1
	return p
end
local function cyl(parent: Instance, name: string, radius: number, height: number, pos: Vector3, color: Color3, mat: Enum.Material, variant: string?, solid: boolean?): Part
	local p = P(parent, name, Vector3.new(height, radius * 2, radius * 2), CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2), color, mat, variant, solid)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function wall(parent: Instance, size: Vector3, cf: CFrame) -- invisible collider
	local p = P(parent, "Collider", size, cf, C(255, 255, 255), Enum.Material.SmoothPlastic, nil, true)
	p.Transparency = 1; p.CastShadow = false
	return p
end
local function glow(p: BasePart, color: Color3, range: number, brightness: number): PointLight
	local l = Instance.new("PointLight")
	l.Color = color; l.Range = range; l.Brightness = brightness; l.Shadows = false; l.Parent = p
	return l
end
local function flame(p: BasePart, color: Color3, size: number)
	local a = Instance.new("Attachment"); a.Position = Vector3.new(0, p.Size.Y / 2, 0); a.Parent = p
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/fire_main.dds"
	pe.Color = ColorSequence.new(color, color:Lerp(C(60, 10, 0), 0.6)); pe.LightEmission = 0.9
	pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, size * 0.2) })
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	pe.Lifetime = NumberRange.new(0.5, 0.9); pe.Speed = NumberRange.new(2, 4); pe.SpreadAngle = Vector2.new(12, 12); pe.Rate = 18
	pe.Acceleration = Vector3.new(0, 3, 0); pe.Parent = a
end
local function text(p: BasePart, face: Enum.NormalId, str: string, color: Color3, font: Enum.Font?, sub: string?)
	local sg = Instance.new("SurfaceGui")
	sg.Face = face; sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; sg.PixelsPerStud = 40; sg.LightInfluence = 0.2; sg.Parent = p
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(0.94, sub and 0.62 or 0.9); t.Position = UDim2.fromScale(0.03, 0.04)
	t.Font = font or Enum.Font.Creepster; t.Text = str; t.TextScaled = true; t.TextColor3 = color
	t.TextStrokeTransparency = 0.25; t.TextStrokeColor3 = C(14, 10, 8); t.Parent = sg
	if sub then
		local s = Instance.new("TextLabel")
		s.BackgroundTransparency = 1; s.Size = UDim2.fromScale(0.94, 0.3); s.Position = UDim2.fromScale(0.03, 0.66)
		s.Font = Enum.Font.SpecialElite; s.Text = sub; s.TextScaled = true; s.TextColor3 = C(220, 210, 185); s.TextStrokeTransparency = 0.4; s.Parent = sg
	end
end
-- the old forest floor (leaves, rocks, stumps, trees) is cleared where something new stands
local forest = lobby:FindFirstChild("Forest")
local function clearAround(x: number, z: number, r: number)
	if not forest then return end
	local function check(inst: Instance)
		local pos: Vector3? = nil
		if inst:IsA("BasePart") then pos = inst.Position elseif inst:IsA("Model") then pos = inst:GetPivot().Position end
		if pos and (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(x, 0, z)).Magnitude < r then inst:Destroy() end
	end
	for _, c in forest:GetChildren() do
		if c.Name == "HandTrees" then
			for _, t in c:GetChildren() do check(t) end
		else
			check(c)
		end
	end
end
-- HAND-BUILT PROPS (blocky PS2 style: plain boxes and cylinders, flat dark colours, the PS2_* materials). Never AI
-- meshes: the user rejected those for good. Each builder gets (model, base, s): base = where it stands on the
-- ground (its front is +Z), s = scale. b(...) makes one block in the prop's own space.
local BUILD: { [string]: (m: Model, base: CFrame, s: number) -> () } = {}
local STONE_A, STONE_B, IRON = C(98, 96, 92), C(70, 70, 72), C(24, 24, 27)
local W_A, W_B = C(92, 66, 44), C(52, 38, 28)
local function kit(m: Model, base: CFrame, s: number)
	return function(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, variant: string?, solid: boolean?): Part
		return P(m, name, size * s, base * (CFrame.new(cf.Position * s) * cf.Rotation), color, mat, variant, solid)
	end
end
local function V(x, y, z) return Vector3.new(x, y, z) end
local function at(x, y, z) return CFrame.new(x, y, z) end
local function rad(d) return math.rad(d) end

-- an iron gate between two stone pillars, its doors standing open
BUILD.LobbyGate = function(m, base, s)
	local b = kit(m, base, s)
	for _, sx in { -1, 1 } do
		local x = sx * 6.1
		b("PillarBase", V(3.8, 1.2, 3.8), at(x, 0.6, 0), STONE_B, Enum.Material.Cobblestone, "PS2_Stone")
		b("Pillar", V(3, 10, 3), at(x, 6.2, 0), STONE_A, Enum.Material.Cobblestone, "PS2_Stone")
		b("PillarBand", V(3.4, 0.6, 3.4), at(x, 8.2, 0), STONE_B, Enum.Material.Slate)
		b("PillarCap", V(3.8, 0.8, 3.8), at(x, 11.6, 0), STONE_B, Enum.Material.Slate)
		b("PillarTop", V(2.6, 0.7, 2.6), at(x, 12.35, 0), STONE_A, Enum.Material.Slate)
		-- an iron lantern on each pillar
		b("LanternCage", V(1, 1.3, 1), at(x, 13.35, 0), IRON, Enum.Material.Metal)
		local core = b("LanternGlow", V(0.6, 0.8, 0.6), at(x, 13.35, 0), C(255, 180, 90), Enum.Material.Neon)
		core.Size = core.Size * 1.05
		glow(core, C(255, 180, 100), 22, 1.1)
		b("LanternRoof", V(1.4, 0.3, 1.4), at(x, 14.15, 0), IRON, Enum.Material.Metal)
		-- the arch: one slanted bar up from each pillar
		b("ArchBar", V(3.4, 0.4, 0.4), at(sx * 4.3, 12.9, 0) * CFrame.Angles(0, 0, rad(-sx * 28)), IRON, Enum.Material.Metal)
		b("ArchBar", V(3.4, 0.3, 0.3), at(sx * 4.3, 12.0, 0) * CFrame.Angles(0, 0, rad(-sx * 28)), IRON, Enum.Material.Metal)
		-- the door, swung open to the back
		local hinge = at(sx * 4.6, 0, 0) * CFrame.Angles(0, rad(sx * -72), 0)
		local function d(name: string, size: Vector3, x1: number, y: number)
			b(name, size, hinge * at(-sx * x1, y, 0), IRON, Enum.Material.Metal)
		end
		d("DoorStile", V(0.35, 9.4, 0.35), 0.2, 4.9); d("DoorStile", V(0.35, 8.2, 0.35), 4.3, 4.3)
		d("DoorRail", V(4.4, 0.3, 0.3), 2.25, 0.6); d("DoorRail", V(4.4, 0.3, 0.3), 2.25, 4.4); d("DoorRail", V(4.4, 0.3, 0.3), 2.25, 7.8)
		for i = 1, 5 do
			local h = 9.6 - i * 0.35
			d("DoorBar", V(0.2, h, 0.2), i * 0.7, h / 2 + 0.3)
			d("DoorSpike", V(0.36, 0.5, 0.36), i * 0.7, h + 0.45)
		end
	end
	b("ArchTop", V(6.2, 0.4, 0.4), at(0, 13.7, 0), IRON, Enum.Material.Metal)
	b("ArchTop", V(6.2, 0.3, 0.3), at(0, 12.8, 0), IRON, Enum.Material.Metal)
	for i = -2, 2 do b("ArchTie", V(0.22, 0.9, 0.22), at(i * 1.4, 13.25, 0), IRON, Enum.Material.Metal) end
	b("ArchSpike", V(0.5, 1.4, 0.5), at(0, 14.5, 0) * CFrame.Angles(0, rad(45), 0), IRON, Enum.Material.Metal)
end

-- the plaza's dry stone fountain: an eight-sided basin and a hooded figure holding a lantern
BUILD.LobbyFountain = function(m, base, s)
	local b = kit(m, base, s)
	for i = 0, 7 do
		local a = CFrame.Angles(0, rad(i * 45), 0)
		b("BasinWall", V(5.6, 2.6, 1.4), a * at(0, 1.3, 6.3), i % 2 == 0 and STONE_A or STONE_A:Lerp(STONE_B, 0.5), Enum.Material.Cobblestone, "PS2_Stone")
		b("BasinRim", V(6.1, 0.45, 2), a * at(0, 2.8, 6.3), STONE_B, Enum.Material.Slate)
		if i % 3 == 0 then b("Moss", V(2.2, 0.5, 2.1), a * at(rng:NextNumber(-1.5, 1.5), 2.82, 6.3), C(62, 86, 46), Enum.Material.Grass) end
		if i % 2 == 1 then b("Crack", V(0.14, 1.9, 0.1), a * at(rng:NextNumber(-1.8, 1.8), 1.3, 7.02) * CFrame.Angles(0, 0, rad(rng:NextNumber(-25, 25))), C(16, 16, 18), Enum.Material.SmoothPlastic) end
	end
	local floor = b("BasinFloor", V(0.5, 12.4, 12.4), at(0, 0.35, 0) * CFrame.Angles(0, 0, math.pi / 2), STONE_B, Enum.Material.Cobblestone, "PS2_Stone")
	floor.Shape = Enum.PartType.Cylinder
	local water = b("StillWater", V(0.2, 11.4, 11.4), at(0, 1.1, 0) * CFrame.Angles(0, 0, math.pi / 2), C(18, 30, 28), Enum.Material.Glass)
	water.Shape = Enum.PartType.Cylinder; water.Transparency = 0.15
	b("Plinth", V(3.4, 1.8, 3.4), at(0, 0.9, 0), STONE_B, Enum.Material.Cobblestone, "PS2_Stone")
	b("Plinth", V(2.6, 1.2, 2.6), at(0, 2.4, 0), STONE_A, Enum.Material.Slate)
	-- the figure (weathered stone)
	local ST = C(128, 126, 118)
	b("Robe", V(2.8, 3, 2.3), at(0, 4.5, 0), ST, Enum.Material.Slate)
	b("RobeHem", V(3.1, 0.6, 2.6), at(0, 3.3, 0), ST:Lerp(STONE_B, 0.4), Enum.Material.Slate)
	b("Chest", V(2.3, 2.4, 1.9), at(0, 7.1, 0), ST, Enum.Material.Slate)
	b("Shoulders", V(3.1, 0.8, 2), at(0, 8.4, 0), ST, Enum.Material.Slate)
	b("Hood", V(2, 2, 2), at(0, 9.7, -0.1), ST, Enum.Material.Slate)
	b("HoodPeak", V(1.5, 0.6, 1.6), at(0, 10.9, -0.2), ST:Lerp(STONE_B, 0.3), Enum.Material.Slate)
	b("Face", V(1.3, 1.3, 0.25), at(0, 9.6, 0.92), C(8, 8, 10), Enum.Material.SmoothPlastic)
	b("ArmDown", V(0.75, 2.8, 0.8), at(1.5, 6.6, 0.1), ST, Enum.Material.Slate)
	b("ArmOut", V(0.75, 0.8, 2.2), at(-1.5, 7.3, 0.9), ST, Enum.Material.Slate)
	b("Hand", V(0.6, 0.6, 0.6), at(-1.5, 7.2, 2.1), ST:Lerp(STONE_B, 0.3), Enum.Material.Slate)
	b("LanternRing", V(0.15, 0.6, 0.15), at(-1.5, 6.7, 2.1), IRON, Enum.Material.Metal)
	b("LanternCage", V(0.9, 1.1, 0.9), at(-1.5, 5.9, 2.1), IRON, Enum.Material.Metal)
	b("LanternGlow", V(0.62, 0.8, 0.62), at(-1.5, 5.9, 2.1), C(150, 255, 190), Enum.Material.Neon).Size *= 1.06
end

-- a farm cart: one wheel off, a tarp and a crate in the back
BUILD.LobbyWagon = function(m, base, s)
	local b = kit(m, base * CFrame.Angles(0, 0, rad(-5)), s)
	b("Bed", V(3.2, 0.3, 5.4), at(0, 1.6, 0), W_A, Enum.Material.WoodPlanks, "PS2_FloorPlanks")
	for _, sx in { -1, 1 } do
		b("Side", V(0.22, 1.1, 5.4), at(sx * 1.6, 2.25, 0), W_B, Enum.Material.WoodPlanks, "PS2_Siding")
		b("SideRail", V(0.3, 0.2, 5.6), at(sx * 1.6, 2.9, 0), W_B, Enum.Material.Wood, "PS2_DarkBeam")
	end
	b("Board", V(3.2, 1.1, 0.22), at(0, 2.25, -2.7), W_B, Enum.Material.WoodPlanks, "PS2_Siding")
	b("Board", V(3.2, 0.6, 0.22), at(0, 2.0, 2.7), W_B, Enum.Material.WoodPlanks, "PS2_Siding")
	for _, z in { -1.8, 1.8 } do b("Axle", V(4.2, 0.28, 0.28), at(0, 1.1, z), IRON, Enum.Material.Metal) end
	for _, w in { { -2.05, -1.8 }, { 2.05, -1.8 }, { 2.05, 1.8 } } do
		local wheel = b("Wheel", V(0.32, 2.2, 2.2), at(w[1], 1.1, w[2]), W_B, Enum.Material.Wood, "PS2_DarkBeam")
		wheel.Shape = Enum.PartType.Cylinder
		b("Hub", V(0.44, 0.5, 0.5), at(w[1], 1.1, w[2]), IRON, Enum.Material.Metal)
	end
	-- the fourth wheel lies on the ground; a block holds that corner up
	local off = b("WheelOff", V(0.32, 2.2, 2.2), at(-3.4, 0.2, 2.6) * CFrame.Angles(0, 0, rad(84)), W_B, Enum.Material.Wood, "PS2_DarkBeam")
	off.Shape = Enum.PartType.Cylinder
	b("Prop", V(0.8, 1.1, 0.8), at(-1.6, 0.55, 1.8), STONE_B, Enum.Material.Slate)
	b("Tongue", V(0.26, 0.26, 3.6), at(0, 1.0, -4.3) * CFrame.Angles(rad(-14), 0, 0), W_B, Enum.Material.Wood, "PS2_DarkBeam")
	b("Crate", V(1.3, 1.3, 1.3), at(0.7, 2.4, -1.6) * CFrame.Angles(0, 0.3, 0), W_A, Enum.Material.WoodPlanks, "PS2_Siding")
	b("Sack", V(1.2, 0.8, 1.6), at(-0.7, 2.15, -0.6), C(150, 132, 96), Enum.Material.Fabric)
	b("Tarp", V(2.9, 0.16, 2.6), at(0, 2.75, 1.2) * CFrame.Angles(rad(8), 0, rad(4)), C(58, 66, 52), Enum.Material.Fabric)
end

-- a stone well with a little shingled roof, a rope and a bucket
BUILD.LobbyWell = function(m, base, s)
	local b = kit(m, base, s)
	for i = 0, 7 do
		local a = CFrame.Angles(0, rad(i * 45), 0)
		b("WellStone", V(2.15, 2.6, 0.9), a * at(0, 1.3, 2.3), i % 2 == 0 and STONE_A or STONE_B, Enum.Material.Cobblestone, "PS2_Stone")
		b("WellRim", V(2.3, 0.35, 1.2), a * at(0, 2.75, 2.3), STONE_B, Enum.Material.Slate)
	end
	local water = b("WellWater", V(0.2, 4.2, 4.2), at(0, 1.6, 0) * CFrame.Angles(0, 0, math.pi / 2), C(6, 10, 12), Enum.Material.Glass)
	water.Shape = Enum.PartType.Cylinder
	for _, sx in { -1, 1 } do b("WellPost", V(0.45, 4.2, 0.45), at(sx * 2.6, 4.7, 0), W_B, Enum.Material.Wood, "PS2_DarkBeam") end
	b("Crank", V(5.6, 0.3, 0.3), at(0, 5.3, 0), W_B, Enum.Material.Wood, "PS2_DarkBeam")
	b("CrankHandle", V(0.25, 1, 0.25), at(3.0, 5.1, 0), IRON, Enum.Material.Metal)
	for _, sz in { -1, 1 } do
		b("WellRoof", V(6.4, 0.25, 2.5), at(0, 7.2, sz * 0.95) * CFrame.Angles(rad(sz * 38), 0, 0), C(54, 44, 40), Enum.Material.Slate, "PS2_Roof")
	end
	b("RoofRidge", V(6.6, 0.3, 0.3), at(0, 7.95, 0), W_B, Enum.Material.Wood, "PS2_DarkBeam")
	b("Rope", V(0.12, 1.7, 0.12), at(0.4, 4.4, 0), C(150, 130, 90), Enum.Material.Fabric)
	b("Bucket", V(0.95, 0.95, 0.95), at(0.4, 3.2, 0), W_A, Enum.Material.WoodPlanks, "PS2_Siding")
	b("BucketHoop", V(1.05, 0.15, 1.05), at(0.4, 3.45, 0), IRON, Enum.Material.Metal)
end

-- a scarecrow on a cross post: sack head with a stitched grin, torn coat, straw hands, old hat
BUILD.LobbyScarecrow = function(m, base, s)
	local b = kit(m, base, s)
	local SACK, COAT, STRAW = C(184, 164, 116), C(70, 54, 44), C(206, 176, 84)
	b("Post", V(0.4, 7, 0.4), at(0, 3.5, 0), W_B, Enum.Material.Wood, "PS2_DarkBeam")
	b("CrossBar", V(5.4, 0.35, 0.35), at(0, 5.3, 0) * CFrame.Angles(0, 0, rad(4)), W_B, Enum.Material.Wood, "PS2_DarkBeam")
	b("Coat", V(1.9, 2.5, 0.9), at(0, 4.4, 0.1), COAT, Enum.Material.Fabric)
	b("CoatPatch", V(0.6, 0.6, 0.1), at(0.4, 4.2, 0.58), C(110, 60, 40), Enum.Material.Fabric)
	for i = -1, 1 do b("Tatter", V(0.5, rng:NextNumber(0.8, 1.5), 0.14), at(i * 0.62, 2.7, 0.1) * CFrame.Angles(0, 0, rad(rng:NextNumber(-8, 8))), COAT:Lerp(C(30, 26, 24), 0.3), Enum.Material.Fabric) end
	for _, sx in { -1, 1 } do
		b("Sleeve", V(1.7, 0.75, 0.75), at(sx * 1.75, 5.3 + sx * 0.12, 0.05), COAT, Enum.Material.Fabric)
		b("StrawHand", V(0.7, 0.5, 0.5), at(sx * 2.85, 5.3 + sx * 0.2, 0.05), STRAW, Enum.Material.Grass)
		b("StrawHand", V(0.5, 0.9, 0.3), at(sx * 3.05, 5.0 + sx * 0.2, 0.05) * CFrame.Angles(0, 0, rad(sx * 20)), STRAW, Enum.Material.Grass)
	end
	b("StrawNeck", V(1.1, 0.4, 1.1), at(0, 5.8, 0.1), STRAW, Enum.Material.Grass)
	b("Head", V(1.35, 1.45, 1.35), at(0, 6.7, 0.1) * CFrame.Angles(0, 0, rad(-6)), SACK, Enum.Material.Fabric)
	b("Eye", V(0.32, 0.38, 0.1), at(-0.32, 6.95, 0.8), C(10, 10, 10), Enum.Material.SmoothPlastic)
	b("Eye", V(0.26, 0.26, 0.1), at(0.34, 6.9, 0.8), C(10, 10, 10), Enum.Material.SmoothPlastic)
	b("Mouth", V(0.9, 0.1, 0.1), at(0, 6.35, 0.8) * CFrame.Angles(0, 0, rad(-6)), C(10, 10, 10), Enum.Material.SmoothPlastic)
	for i = -1, 1 do b("Stitch", V(0.08, 0.34, 0.1), at(i * 0.3, 6.35 - i * 0.03, 0.81), C(10, 10, 10), Enum.Material.SmoothPlastic) end
	b("HatBrim", V(2.3, 0.16, 2.3), at(0, 7.5, 0.1) * CFrame.Angles(rad(-4), 0, rad(-8)), C(40, 32, 28), Enum.Material.Fabric)
	b("HatCrown", V(1.25, 0.95, 1.25), at(0.05, 8.0, 0.05) * CFrame.Angles(0, 0, rad(-8)), C(40, 32, 28), Enum.Material.Fabric)
	b("HatBand", V(1.3, 0.2, 1.3), at(0.03, 7.7, 0.08) * CFrame.Angles(0, 0, rad(-8)), C(110, 30, 26), Enum.Material.Fabric)
end

-- a small plot of graves: slabs, a cross, a broken stone, on a mound
BUILD.LobbyTombstones = function(m, base, s)
	local b = kit(m, base, s)
	b("Mound", V(5.4, 0.5, 4.2), at(0, 0.2, 0), C(52, 42, 34), Enum.Material.Mud, "PS2_Mud")
	local function slab(x: number, z: number, h: number, yaw: number, lean: number)
		local cf = at(x, 0.3, z) * CFrame.Angles(rad(lean), rad(yaw), rad(lean * 0.6))
		b("GraveBase", V(1.9, 0.4, 0.9), cf * at(0, 0.2, 0), STONE_B, Enum.Material.Slate)
		b("GraveSlab", V(1.5, h, 0.45), cf * at(0, 0.4 + h / 2, 0), STONE_A, Enum.Material.Cobblestone, "PS2_Stone")
		b("GraveTop", V(1.1, 0.35, 0.45), cf * at(0, 0.55 + h, 0), STONE_A, Enum.Material.Cobblestone, "PS2_Stone")
		b("Epitaph", V(0.9, 0.12, 0.06), cf * at(0, 0.4 + h * 0.7, 0.24), C(40, 40, 42), Enum.Material.SmoothPlastic)
		b("Epitaph", V(0.7, 0.12, 0.06), cf * at(0, 0.4 + h * 0.52, 0.24), C(40, 40, 42), Enum.Material.SmoothPlastic)
	end
	slab(-1.6, 0.6, 2.4, 8, -6); slab(1.5, 0.9, 2.0, -12, 5)
	-- the cross
	local c = at(0.1, 0.3, -0.9) * CFrame.Angles(0, rad(5), rad(-5))
	b("CrossBase", V(1.4, 0.5, 1.1), c * at(0, 0.25, 0), STONE_B, Enum.Material.Slate)
	b("CrossPost", V(0.6, 3.6, 0.5), c * at(0, 2.3, 0), STONE_A, Enum.Material.Cobblestone, "PS2_Stone")
	b("CrossArm", V(2.2, 0.6, 0.5), c * at(0, 3.1, 0), STONE_A, Enum.Material.Cobblestone, "PS2_Stone")
	-- a broken one, its top lying beside it
	b("BrokenStump", V(1.3, 0.9, 0.45), at(2.0, 0.75, -0.9) * CFrame.Angles(0, rad(20), 0), STONE_B, Enum.Material.Cobblestone, "PS2_Stone")
	b("BrokenTop", V(1.3, 1.3, 0.45), at(2.3, 0.5, -1.9) * CFrame.Angles(rad(82), rad(30), 0), STONE_B, Enum.Material.Cobblestone, "PS2_Stone")
	b("Moss", V(0.8, 0.3, 0.5), at(-1.6, 0.55, 0.62), C(62, 86, 46), Enum.Material.Grass)
end

-- a heap of pumpkins; the biggest is carved (its face glows)
BUILD.LobbyPumpkins = function(m, base, s)
	local b = kit(m, base, s)
	local function pumpkin(x: number, z: number, d: number, yaw: number, carved: boolean?)
		local cf = at(x, d * 0.4, z) * CFrame.Angles(0, rad(yaw), rad(rng:NextNumber(-6, 6)))
		local col = C(212, 108, 28):Lerp(C(160, 70, 20), rng:NextNumber(0, 0.5))
		b("Pumpkin", V(d, d * 0.8, d), cf, col, Enum.Material.SmoothPlastic)
		b("PumpkinRib", V(d * 1.1, d * 0.68, d * 0.5), cf, col:Lerp(C(240, 140, 40), 0.3), Enum.Material.SmoothPlastic)
		b("PumpkinRib", V(d * 0.5, d * 0.68, d * 1.1), cf, col:Lerp(C(240, 140, 40), 0.3), Enum.Material.SmoothPlastic)
		b("Stem", V(d * 0.2, d * 0.3, d * 0.2), cf * at(0, d * 0.52, 0) * CFrame.Angles(0, 0, rad(12)), C(70, 84, 40), Enum.Material.SmoothPlastic)
		if carved then
			local glowCol = C(255, 196, 70)
			for _, sx in { -1, 1 } do
				b("CarvedEye", V(d * 0.2, d * 0.2, 0.08), cf * at(sx * d * 0.2, d * 0.12, d * 0.56) * CFrame.Angles(0, 0, rad(45)), glowCol, Enum.Material.Neon)
			end
			for i = -2, 2 do
				b("CarvedTooth", V(d * 0.13, d * (i % 2 == 0 and 0.2 or 0.12), 0.08), cf * at(i * d * 0.13, -d * 0.16, d * 0.56), glowCol, Enum.Material.Neon)
			end
		end
	end
	pumpkin(0, 0, 2.3, 0, true)
	pumpkin(-2.1, 0.5, 1.5, 40); pumpkin(1.9, 0.8, 1.7, -30); pumpkin(0.9, -1.7, 1.3, 70); pumpkin(-1.2, -1.5, 1.0, 10)
	b("Vine", V(3.6, 0.12, 0.2), at(-0.6, 0.12, 1.5) * CFrame.Angles(0, rad(20), 0), C(60, 80, 40), Enum.Material.Grass)
	b("Leaf", V(0.8, 0.08, 0.7), at(-2.2, 0.16, 1.9) * CFrame.Angles(0, rad(35), 0), C(60, 84, 40), Enum.Material.Grass)
end

-- a camp fire: a ring of stones, stacked logs, two log seats
BUILD.LobbyCampfire = function(m, base, s)
	local b = kit(m, base, s)
	for i = 0, 8 do
		local a = CFrame.Angles(0, rad(i * 40), 0)
		b("FireStone", V(1.2, rng:NextNumber(0.6, 0.9), 0.9), a * at(0, 0.35, 2.1) * CFrame.Angles(0, rng:NextNumber(-0.3, 0.3), 0), i % 2 == 0 and STONE_A or STONE_B, Enum.Material.Slate)
	end
	local ash = b("Ash", V(0.16, 3.6, 3.6), at(0, 0.1, 0) * CFrame.Angles(0, 0, math.pi / 2), C(22, 20, 20), Enum.Material.Slate)
	ash.Shape = Enum.PartType.Cylinder
	for i = 0, 3 do
		b("Log", V(0.5, 0.5, 2.6), CFrame.Angles(0, rad(i * 90 + 20), 0) * at(0, 0.95, 0.75) * CFrame.Angles(rad(48), 0, 0), C(30, 22, 18), Enum.Material.Wood, "PS2_DarkBeam")
	end
	for _, e in { { 0, 4.6, 0 }, { 4.4, -1.2, 80 } } do
		local seat = b("LogSeat", V(4.6, 1.3, 1.3), at(e[1], 0.65, e[2]) * CFrame.Angles(0, rad(e[3]), 0), W_A, Enum.Material.Wood, "PS2_DarkBeam", true)
		seat.Shape = Enum.PartType.Cylinder
	end
end

-- the bestiary's altar: a stone lectern with a huge open book, a skull beside it
BUILD.LobbyBookAltar = function(m, base, s)
	local b = kit(m, base, s)
	b("AltarBase", V(4.8, 0.8, 3.8), at(0, 0.4, 0), STONE_B, Enum.Material.Cobblestone, "PS2_Stone")
	b("AltarStep", V(4, 0.5, 3), at(0, 1.05, 0), STONE_A, Enum.Material.Slate)
	b("AltarColumn", V(2.4, 2.4, 2), at(0, 2.5, -0.2), STONE_A, Enum.Material.Cobblestone, "PS2_Stone")
	b("Rune", V(1.2, 0.16, 0.08), at(0, 2.9, 0.82), C(190, 120, 255), Enum.Material.Neon)
	b("Rune", V(0.16, 1.1, 0.08), at(0, 2.5, 0.82), C(190, 120, 255), Enum.Material.Neon)
	b("Rune", V(0.7, 0.16, 0.08), at(0, 2.1, 0.82), C(190, 120, 255), Enum.Material.Neon)
	local top = at(0, 3.95, 0) * CFrame.Angles(rad(20), 0, 0) -- the reading slab leans toward the reader
	b("AltarTop", V(4.6, 0.45, 3.2), top, STONE_B, Enum.Material.Slate)
	b("BookCover", V(4.1, 0.22, 2.7), top * at(0, 0.34, 0), C(64, 26, 22), Enum.Material.Fabric)
	for _, sx in { -1, 1 } do
		b("Pages", V(1.9, 0.4, 2.45), top * at(sx * 0.98, 0.6, 0) * CFrame.Angles(0, 0, rad(sx * 7)), C(224, 212, 180), Enum.Material.SmoothPlastic)
		for i = 0, 4 do b("Writing", V(1.4, 0.03, 0.12), top * at(sx * 0.98, 0.83, -0.8 + i * 0.4) * CFrame.Angles(0, 0, rad(sx * 7)), C(50, 34, 30), Enum.Material.SmoothPlastic) end
		b("Corner", V(0.5, 0.26, 0.5), top * at(sx * 1.85, 0.34, 1.15), C(196, 160, 70), Enum.Material.Metal)
		b("Corner", V(0.5, 0.26, 0.5), top * at(sx * 1.85, 0.34, -1.15), C(196, 160, 70), Enum.Material.Metal)
	end
	b("Ribbon", V(0.24, 0.06, 3.3), top * at(0.15, 0.82, 0.2), C(150, 24, 24), Enum.Material.Fabric)
	-- a monster's skull on the step
	local sk = at(1.5, 1.3, 1.1) * CFrame.Angles(0, rad(-25), 0)
	b("Skull", V(0.95, 0.85, 1.05), sk * at(0, 0.42, 0), C(214, 206, 184), Enum.Material.SmoothPlastic)
	b("SkullJaw", V(0.7, 0.3, 0.7), sk * at(0, 0.02, 0.18), C(196, 188, 166), Enum.Material.SmoothPlastic)
	for _, sx in { -1, 1 } do
		b("SkullEye", V(0.26, 0.26, 0.1), sk * at(sx * 0.22, 0.5, 0.53), C(10, 10, 10), Enum.Material.SmoothPlastic)
		b("SkullHorn", V(0.2, 0.7, 0.2), sk * at(sx * 0.42, 1.0, -0.1) * CFrame.Angles(0, 0, rad(-sx * 25)), C(196, 188, 166), Enum.Material.SmoothPlastic)
	end
end

-- a prop standing on the ground at (x, z), its front (+Z) turned to yaw degrees
local function put(name: string, x: number, z: number, yaw: number, scale: number?, parent: Instance?, _sink: number?): Model?
	local build = BUILD[name]
	if not build then warn("no builder for " .. name); return nil end
	local m = Instance.new("Model")
	m.Name = string.sub(name, 6)
	m.Parent = parent or detail
	build(m, CFrame.new(x, 0.1, z) * CFrame.Angles(0, math.rad(yaw), 0), scale or 1)
	return m
end

local STONE, WOOD, DARKWOOD = C(96, 94, 90), C(92, 66, 44), C(52, 38, 28)
local function torch(parent: Instance, x: number, z: number, color: Color3?)
	local col = color or C(255, 150, 50)
	P(parent, "TorchPost", Vector3.new(0.5, 6.4, 0.5), CFrame.new(x, 3.2, z), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
	local bowl = cyl(parent, "TorchBowl", 0.8, 0.5, Vector3.new(x, 6.5, z), C(40, 36, 34), Enum.Material.Metal)
	local ember = P(parent, "Ember", Vector3.new(0.9, 0.3, 0.9), CFrame.new(x, 6.8, z), col, Enum.Material.Neon)
	ember.Transparency = 0.2
	flame(ember, col, 1.5)
	glow(ember, col, 30, 1.5)
end
local function crate(parent: Instance, x: number, z: number, s: number, y: number?)
	P(parent, "Crate", Vector3.new(s, s, s), CFrame.new(x, (y or 0) + s / 2 + 0.1, z) * CFrame.Angles(0, rng:NextNumber(-0.5, 0.5), 0), WOOD:Lerp(DARKWOOD, rng:NextNumber(0, 0.7)), Enum.Material.WoodPlanks, "PS2_Siding", true)
end
local function barrel(parent: Instance, x: number, z: number)
	cyl(parent, "Barrel", 1.3, 3.2, Vector3.new(x, 1.7, z), C(84, 56, 38), Enum.Material.Wood, "PS2_DarkBeam", true)
	cyl(parent, "Hoop", 1.36, 0.2, Vector3.new(x, 2.6, z), C(40, 38, 36), Enum.Material.Metal)
	cyl(parent, "Hoop", 1.36, 0.2, Vector3.new(x, 0.9, z), C(40, 38, 36), Enum.Material.Metal)
end
local function banner(parent: Instance, x: number, z: number, yaw: number, color: Color3)
	local cf = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(yaw), 0)
	P(parent, "BannerPole", Vector3.new(0.45, 13, 0.45), cf * CFrame.new(0, 6.5, 0), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
	P(parent, "BannerArm", Vector3.new(3.4, 0.3, 0.3), cf * CFrame.new(1.5, 12.4, 0), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam")
	P(parent, "BannerCloth", Vector3.new(2.6, 6.5, 0.12), cf * CFrame.new(1.7, 9, 0) * CFrame.Angles(0, 0, math.rad(2)), color, Enum.Material.Fabric)
	P(parent, "BannerStripe", Vector3.new(2.6, 0.5, 0.16), cf * CFrame.new(1.7, 7, 0) * CFrame.Angles(0, 0, math.rad(2)), C(210, 170, 70), Enum.Material.Fabric)
end
-- a rail fence from a to b (wood) with a post every ~5 studs; skip = chance that a rail is missing (broken)
local function fence(parent: Instance, x1: number, z1: number, x2: number, z2: number, iron: boolean?)
	local a, b = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	local len = (b - a).Magnitude
	local n = math.max(1, math.floor(len / (iron and 3.5 or 5) + 0.5))
	local col = iron and C(26, 26, 28) or DARKWOOD
	for i = 0, n do
		local p = a:Lerp(b, i / n)
		local h = iron and 5 or 3.6
		P(parent, "FencePost", Vector3.new(iron and 0.3 or 0.5, h, iron and 0.3 or 0.5), CFrame.new(p.X, h / 2, p.Z) * CFrame.Angles(0, 0, math.rad(rng:NextNumber(-3, 3))), col,
			iron and Enum.Material.Metal or Enum.Material.Wood, (not iron) and "PS2_DarkBeam" or nil, true)
		if iron then P(parent, "Spike", Vector3.new(0.45, 0.6, 0.45), CFrame.new(p.X, h + 0.2, p.Z) * CFrame.Angles(0, math.pi / 4, 0), col, Enum.Material.Metal) end
		if i < n then
			local q = a:Lerp(b, (i + 1) / n)
			local mid = p:Lerp(q, 0.5)
			local segLen = (q - p).Magnitude
			for _, y in (iron and { 1.2, 4.2 } or { 1.3, 2.7 }) do
				if iron or rng:NextNumber() > 0.14 then
					P(parent, "FenceRail", Vector3.new(iron and 0.18 or 0.3, iron and 0.18 or 0.4, segLen), CFrame.lookAt(Vector3.new(mid.X, y, mid.Z), Vector3.new(q.X, y + (iron and 0 or rng:NextNumber(-0.25, 0.25)), q.Z)),
						col, iron and Enum.Material.Metal or Enum.Material.Wood, (not iron) and "PS2_DarkBeam" or nil)
				end
			end
			if iron then
				for k = 1, 3 do
					local r = p:Lerp(q, k / 4)
					P(parent, "FenceBar", Vector3.new(0.14, 4.2, 0.14), CFrame.new(r.X, 2.5, r.Z), col, Enum.Material.Metal)
				end
			end
		end
	end
	wall(parent, Vector3.new(0.6, 6, len), CFrame.lookAt(a:Lerp(b, 0.5) + Vector3.new(0, 3, 0), b + Vector3.new(0, 3, 0)))
end
local function fireflies(parent: Instance, x: number, z: number, sx: number, sz: number)
	local p = P(parent, "Fireflies", Vector3.new(sx, 6, sz), CFrame.new(x, 4, z), C(0, 0, 0), Enum.Material.SmoothPlastic)
	p.Transparency = 1; p.CastShadow = false
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Color = ColorSequence.new(C(210, 255, 120)); pe.LightEmission = 1; pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.35), NumberSequenceKeypoint.new(1, 0) })
	pe.Lifetime = NumberRange.new(3, 6); pe.Speed = NumberRange.new(0.3, 1.2); pe.SpreadAngle = Vector2.new(180, 180); pe.Rate = sx * sz / 55
	pe.Parent = p
end
local function crow(parent: Instance, x: number, y: number, z: number, yaw: number)
	local cf = CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(yaw), 0)
	P(parent, "Crow", Vector3.new(0.5, 0.55, 1.1), cf * CFrame.new(0, 0.3, 0) * CFrame.Angles(math.rad(-15), 0, 0), C(14, 14, 16), Enum.Material.SmoothPlastic)
	P(parent, "Crow", Vector3.new(0.4, 0.4, 0.45), cf * CFrame.new(0, 0.7, -0.55), C(14, 14, 16), Enum.Material.SmoothPlastic)
	P(parent, "Crow", Vector3.new(0.12, 0.12, 0.35), cf * CFrame.new(0, 0.66, -0.9), C(60, 54, 40), Enum.Material.SmoothPlastic)
end
local function forecourt(parent: Instance, x: number, z: number, r: number)
	clearAround(x, z, r + 2)
	cyl(parent, "Paving", r, 0.14, Vector3.new(x, 0.13, z), C(84, 82, 80), Enum.Material.Cobblestone, "PS2_Stone")
	for i = 1, 14 do
		local a = i / 14 * math.pi * 2 + rng:NextNumber(-0.1, 0.1)
		P(parent, "CurbStone", Vector3.new(rng:NextNumber(1.2, 2.2), rng:NextNumber(0.5, 0.9), rng:NextNumber(1, 1.6)), CFrame.new(x + math.cos(a) * r, 0.3, z + math.sin(a) * r) * CFrame.Angles(0, rng:NextNumber(0, 3), 0),
			STONE:Lerp(C(50, 50, 50), rng:NextNumber(0, 0.5)), Enum.Material.Slate)
	end
end
-- a gate (the AI iron gate) across a path, with a hanging name board; yaw = which way its front looks
local function gate(x: number, z: number, yaw: number, name: string, color: Color3)
	local g = group("Gate_" .. name)
	put("LobbyGate", x, z, yaw, 1.25, g)
	local cf = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(yaw), 0)
	for _, sx in { -1, 1 } do wall(g, Vector3.new(4.4, 18, 4.6), cf * CFrame.new(sx * 7.6, 9, 0)) end
	for _, sx in { -1, 1 } do P(g, "SignChain", Vector3.new(0.12, 3, 0.12), cf * CFrame.new(sx * 3, 14.9, 0.6), C(30, 30, 32), Enum.Material.Metal) end
	local board = P(g, "GateSign", Vector3.new(8, 2.2, 0.3), cf * CFrame.new(0, 12.4, 0.6), C(34, 26, 20), Enum.Material.Wood, "PS2_DarkBeam")
	text(board, Enum.NormalId.Back, name, color)
	text(board, Enum.NormalId.Front, name, color)
end

-- THE MIDDLE: a cobbled plaza, the fountain, the signpost ----------------------------------------------------------
do
	local g = group("Plaza")
	clearAround(CX, CZ, 24)
	cyl(g, "Paving", 21, 0.14, Vector3.new(CX, 0.14, CZ), C(86, 84, 82), Enum.Material.Cobblestone, "PS2_Stone")
	cyl(g, "PavingRing", 9.5, 0.16, Vector3.new(CX, 0.16, CZ), C(60, 58, 58), Enum.Material.Cobblestone, "PS2_Stone")
	for i = 1, 28 do
		local a = i / 28 * math.pi * 2
		local onPath = math.abs(math.cos(a) * 21) < 8.5 or math.abs(math.sin(a) * 21) < 8.5
		if not onPath then
			P(g, "CurbStone", Vector3.new(rng:NextNumber(1.6, 2.4), rng:NextNumber(0.6, 1), 1.4), CFrame.new(CX + math.cos(a) * 21, 0.35, CZ + math.sin(a) * 21) * CFrame.Angles(0, -a, 0),
				STONE:Lerp(C(50, 50, 50), rng:NextNumber(0, 0.5)), Enum.Material.Slate, nil, true)
		end
	end
	put("LobbyFountain", CX, CZ, 0, 1, g)
	local col = cyl(g, "FountainCollider", 7.2, 4, Vector3.new(CX, 2, CZ), C(255, 255, 255), Enum.Material.SmoothPlastic, nil, true)
	col.Transparency = 1; col.CastShadow = false
	wall(g, Vector3.new(4, 14, 4), CFrame.new(CX, 7, CZ))
	-- the statue's lantern burns a cold green
	local lamp = P(g, "StatueLight", Vector3.new(0.3, 0.3, 0.3), CFrame.new(CX - 1.5, 6, CZ + 2.1), C(150, 255, 190), Enum.Material.Neon)
	lamp.Transparency = 1
	glow(lamp, C(150, 255, 200), 34, 1.6)
	-- the signpost, by the spawn: one board for each end of the paths
	local sx, sz = CX + 11.5, CZ + 13
	P(g, "SignPost", Vector3.new(0.6, 11, 0.6), CFrame.new(sx, 5.5, sz), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
	local boards = { { "SHOP", 180, C(255, 190, 90), 9.6 }, { "QUESTS", -90, C(140, 210, 255), 8.2 }, { "BESTIARY", 0, C(200, 140, 255), 6.8 }, { "RANKS", 90, C(255, 230, 120), 5.4 } }
	for _, b in boards do
		-- yaw 180 = the board points north (-Z), -90 = west, 0 = south, 90 = east
		local cf = CFrame.new(sx, b[4] :: number, sz) * CFrame.Angles(0, math.rad(b[2] :: number), 0)
		local board = P(g, "SignBoard", Vector3.new(0.3, 1.2, 4.6), cf * CFrame.new(0, 0, 2.2), C(60, 44, 30), Enum.Material.WoodPlanks, "PS2_Siding")
		P(g, "SignTip", Vector3.new(0.3, 0.86, 0.86), cf * CFrame.new(0, 0, 4.5) * CFrame.Angles(math.pi / 4, 0, 0), C(60, 44, 30), Enum.Material.WoodPlanks, "PS2_Siding")
		text(board, Enum.NormalId.Left, b[1] :: string, b[3] :: Color3)
		text(board, Enum.NormalId.Right, b[1] :: string, b[3] :: Color3)
	end
	local lantern = P(g, "SignLantern", Vector3.new(0.7, 0.9, 0.7), CFrame.new(sx, 11.4, sz), C(255, 190, 110), Enum.Material.Neon)
	lantern.Transparency = 0.2
	glow(lantern, C(255, 190, 120), 26, 1.3)
	crow(g, sx, 11.9, sz, 40)
	-- the spawn moves a little south, off the plaza's middle
	local sp = workspace:FindFirstChild("LobbySpawn")
	if sp and sp:IsA("BasePart") then sp.CFrame = sp.CFrame.Rotation + Vector3.new(CX, sp.Position.Y, CZ + 26) end
	-- two lamp posts stood where the shop and the altar now are
	for _, lp in lobby:GetChildren() do
		if lp.Name == "LampPost" and lp:IsA("Model") then
			local pos = lp:GetPivot().Position
			if math.abs(pos.X) < 14 and pos.Z < CZ - 100 then lp:PivotTo(lp:GetPivot() + Vector3.new(-12, 0, 14)) end
			if math.abs(pos.X) < 14 and pos.Z > CZ + 100 then lp:PivotTo(lp:GetPivot() + Vector3.new(12, 0, -14)) end
		end
	end
	fireflies(g, CX, CZ, 60, 60)
end

-- curb stones along both paths -----------------------------------------------------------
do
	local g = group("PathEdges")
	for d = -120, 120, 7 do
		if math.abs(d) > 23 then
			for _, side in { -1, 1 } do
				if rng:NextNumber() > 0.2 then
					P(g, "CurbStone", Vector3.new(rng:NextNumber(1, 2), rng:NextNumber(0.4, 0.9), rng:NextNumber(1, 1.8)), CFrame.new(CX + side * 8.6, 0.3, CZ + d + rng:NextNumber(-1, 1)) * CFrame.Angles(0, rng:NextNumber(0, 3), 0),
						STONE:Lerp(C(46, 46, 46), rng:NextNumber(0, 0.6)), Enum.Material.Slate)
				end
				if rng:NextNumber() > 0.2 then
					P(g, "CurbStone", Vector3.new(rng:NextNumber(1, 1.8), rng:NextNumber(0.4, 0.9), rng:NextNumber(1, 2)), CFrame.new(CX + d + rng:NextNumber(-1, 1), 0.3, CZ + side * 8.6) * CFrame.Angles(0, rng:NextNumber(0, 3), 0),
						STONE:Lerp(C(46, 46, 46), rng:NextNumber(0, 0.6)), Enum.Material.Slate)
				end
			end
		end
	end
end

-- gates on the four paths ------------------------------------------------------------------------------------------
gate(CX, CZ - 86, 0, "THE DEALER", C(255, 190, 90))
gate(CX, CZ + 88, 180, "BESTIARY", C(200, 140, 255))
gate(CX - 88, CZ, 90, "QUESTS", C(140, 210, 255))
gate(CX + 82, CZ, -90, "HALL OF FAME", C(255, 230, 120))

-- NORTH END: the shop ------------------------------------------------------------------------------------------------
do
	local g = group("ShopYard")
	local SZ = CZ - 114 -- the booth's middle
	forecourt(g, CX, SZ + 12, 19)
	clearAround(CX, SZ, 22)
	local booth, vendor = lobby:FindFirstChild("ShopBooth"), lobby:FindFirstChild("UltVendor")
	if booth and booth:IsA("Model") then
		local by = (SZ - booth:GetPivot().Position.Z)
		booth:PivotTo(booth:GetPivot() + Vector3.new(0, 0, by))
		if vendor and vendor:IsA("Model") then vendor:PivotTo(vendor:GetPivot() + Vector3.new(0, 0, by)) end
	end
	for _, sx in { -1, 1 } do
		torch(g, CX + sx * 9.5, SZ + 14)
		torch(g, CX + sx * 15, SZ + 24)
		banner(g, CX + sx * 15.5, SZ + 6, sx > 0 and 180 or 0, C(120, 26, 24))
	end
	-- stock stacked round the booth
	crate(g, CX - 16, SZ + 2, 3); crate(g, CX - 16.4, SZ + 2.2, 2.2, 3); crate(g, CX - 19, SZ + 4, 2.4); barrel(g, CX - 18.5, SZ - 1)
	crate(g, CX + 16, SZ + 3, 2.8); barrel(g, CX + 18.5, SZ + 1); barrel(g, CX + 16.5, SZ - 1.5); crate(g, CX + 19, SZ + 5, 2)
	-- a rack of ultimate orbs beside the counter: what the dealer sells
	local rack = CFrame.new(CX + 13.5, 0, SZ + 9) * CFrame.Angles(0, math.rad(-35), 0)
	P(g, "RackSide", Vector3.new(0.3, 6, 1.4), rack * CFrame.new(-2.4, 3, 0), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
	P(g, "RackSide", Vector3.new(0.3, 6, 1.4), rack * CFrame.new(2.4, 3, 0), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
	local orbs = { C(255, 80, 40), C(90, 170, 255), C(170, 90, 255), C(120, 230, 90), C(255, 210, 70), C(255, 110, 190) }
	for row = 0, 1 do
		P(g, "RackShelf", Vector3.new(5, 0.25, 1.4), rack * CFrame.new(0, 2 + row * 2.4, 0), WOOD, Enum.Material.Wood, "PS2_DarkBeam")
		for i = 1, 3 do
			local orb = P(g, "UltOrb", Vector3.new(1, 1, 1), rack * CFrame.new((i - 2) * 1.5, 2.75 + row * 2.4, 0), orbs[row * 3 + i], Enum.Material.Neon)
			orb.Shape = Enum.PartType.Ball; orb.Transparency = 0.15
			if i == 2 then glow(orb, orbs[row * 3 + i], 12, 0.8) end
		end
	end
	P(g, "Rug", Vector3.new(14, 0.1, 7), CFrame.new(CX, 0.24, SZ + 13), C(96, 30, 28), Enum.Material.Carpet, "PS2_Rug")
	crow(g, CX - 16, 3.2, SZ + 2, 120)
	fireflies(g, CX, SZ + 14, 44, 30)
end

-- WEST END: the quest board ------------------------------------------------------------------------------------------
do
	local g = group("QuestYard")
	local QX = CX - 116
	forecourt(g, QX + 9, CZ, 16)
	local board = lobby:FindFirstChild("QuestBoard")
	if board and board:IsA("Model") then
		local piv = board:GetPivot()
		board:PivotTo(piv + Vector3.new(QX - piv.Position.X, 0, CZ - piv.Position.Z))
	end
	torch(g, QX + 4, CZ - 10, C(140, 200, 255)); torch(g, QX + 4, CZ + 10, C(140, 200, 255))
	banner(g, QX - 1, CZ - 13, 90, C(30, 60, 96)); banner(g, QX - 1, CZ + 13, 90, C(30, 60, 96))
	-- wanted posters on two small stands either side of the board
	local posters = { { "WANTED", "THE WOMAN", -8 }, { "REWARD", "DAILY QUESTS", 8 } }
	for _, p in posters do
		local cf = CFrame.new(QX + 1.5, 0, CZ + (p[3] :: number)) * CFrame.Angles(0, math.rad((p[3] :: number) > 0 and -18 or 18), 0)
		P(g, "PosterPost", Vector3.new(0.4, 6.5, 0.4), cf * CFrame.new(0, 3.25, 0), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
		local sheet = P(g, "Poster", Vector3.new(0.15, 3.6, 2.8), cf * CFrame.new(0.3, 4.6, 0), C(214, 200, 168), Enum.Material.SmoothPlastic)
		text(sheet, Enum.NormalId.Right, p[1] :: string, C(120, 20, 16), Enum.Font.Creepster, p[2] :: string)
	end
	-- the clerk's desk: papers, an ink pot, a candle
	local desk = CFrame.new(QX + 9, 0, CZ - 9) * CFrame.Angles(0, math.rad(25), 0)
	P(g, "Desk", Vector3.new(5, 0.4, 2.6), desk * CFrame.new(0, 3, 0), WOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
	for _, o in { Vector3.new(-2.2, 1.5, -1), Vector3.new(2.2, 1.5, -1), Vector3.new(-2.2, 1.5, 1), Vector3.new(2.2, 1.5, 1) } do
		P(g, "DeskLeg", Vector3.new(0.35, 3, 0.35), desk * CFrame.new(o), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam")
	end
	for i = 1, 4 do
		P(g, "Paper", Vector3.new(1, 0.04, 1.3), desk * CFrame.new(rng:NextNumber(-1.6, 1.2), 3.23 + i * 0.01, rng:NextNumber(-0.5, 0.5)) * CFrame.Angles(0, rng:NextNumber(-0.6, 0.6), 0), C(220, 208, 180), Enum.Material.SmoothPlastic)
	end
	cyl(g, "InkPot", 0.25, 0.5, (desk * CFrame.new(1.9, 3.45, -0.6)).Position, C(20, 20, 28), Enum.Material.Glass)
	local candle = cyl(g, "Candle", 0.16, 0.8, (desk * CFrame.new(1.9, 3.6, 0.6)).Position, C(230, 220, 190), Enum.Material.SmoothPlastic)
	local wick = P(g, "CandleFlame", Vector3.new(0.2, 0.3, 0.2), desk * CFrame.new(1.9, 4.15, 0.6), C(255, 200, 110), Enum.Material.Neon)
	glow(wick, C(255, 200, 120), 14, 1)
	P(g, "Stool", Vector3.new(1.4, 1.8, 1.4), desk * CFrame.new(0, 0.9, 2.6), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true)
	crate(g, QX + 2, CZ - 15, 2.4); barrel(g, QX + 3, CZ + 15.5)
	fireflies(g, QX + 10, CZ, 36, 36)
end

-- SOUTH END: the bestiary altar --------------------------------------------------------------------------------------
do
	local AZ = CZ + 114
	local g = group("BestiaryAltar", lobby)
	forecourt(g, CX, AZ - 8, 19)
	clearAround(CX, AZ, 22)
	-- a round dais of three steps
	for i = 1, 3 do
		cyl(g, "Dais", 10.5 - i * 1.8, 0.7, Vector3.new(CX, 0.1 + i * 0.7 - 0.35, AZ), STONE:Lerp(C(40, 40, 44), i * 0.12), Enum.Material.Cobblestone, "PS2_Stone", true)
	end
	local topY = 0.1 + 3 * 0.7
	local altar = put("LobbyBookAltar", CX, AZ + 0.5, 180, 1.35, g)
	if altar then altar:PivotTo(altar:GetPivot() + Vector3.new(0, topY - 0.1, 0)) end
	wall(g, Vector3.new(8, 7, 8), CFrame.new(CX, topY + 3.5, AZ + 0.5))
	-- what Server/Lobby hangs the prompt on
	local prompt = P(g, "Prompt", Vector3.new(2, 2, 2), CFrame.new(CX, topY + 5, AZ - 2), C(255, 255, 255), Enum.Material.SmoothPlastic)
	prompt.Transparency = 1; prompt.CastShadow = false
	local bookGlow = P(g, "BookGlow", Vector3.new(0.4, 0.4, 0.4), CFrame.new(CX, topY + 8.4, AZ), C(200, 140, 255), Enum.Material.Neon)
	bookGlow.Transparency = 1
	glow(bookGlow, C(200, 150, 255), 30, 0.9)
	-- one stone pedestal with a glowing orb for each of the eight monsters, in a half circle behind the book
	local orbs = { C(150, 200, 210), C(200, 40, 30), C(226, 214, 186), C(214, 150, 80), C(170, 58, 44), C(110, 190, 60), C(232, 230, 222), C(150, 104, 190) }
	for i, col in orbs do
		local a = math.rad(200 + (i - 1) * (140 / 7)) -- behind (south of) the altar
		local x, z = CX + math.cos(a) * 14.5, AZ - math.sin(a) * 9 + 3
		cyl(g, "Pedestal", 0.9, 4.4, Vector3.new(x, 2.3, z), STONE:Lerp(C(40, 40, 44), 0.3), Enum.Material.Cobblestone, "PS2_Stone", true)
		cyl(g, "PedestalCap", 1.2, 0.4, Vector3.new(x, 4.7, z), STONE, Enum.Material.Slate)
		local orb = P(g, "MonsterOrb", Vector3.new(1.3, 1.3, 1.3), CFrame.new(x, 5.7, z), col, Enum.Material.Neon)
		orb.Shape = Enum.PartType.Ball; orb.Transparency = 0.2
		glow(orb, col, 10, 0.9)
	end
	-- two tall braziers with a violet fire, and the name over the altar
	for _, sx in { -1, 1 } do
		cyl(g, "BrazierStem", 0.4, 6, Vector3.new(CX + sx * 9, 3.1, AZ - 9), C(30, 28, 30), Enum.Material.Metal, nil, true)
		cyl(g, "BrazierBowl", 1.5, 0.9, Vector3.new(CX + sx * 9, 6.4, AZ - 9), C(36, 32, 34), Enum.Material.Metal)
		local ember = P(g, "Ember", Vector3.new(1.6, 0.3, 1.6), CFrame.new(CX + sx * 9, 6.9, AZ - 9), C(190, 110, 255), Enum.Material.Neon)
		ember.Transparency = 0.3
		flame(ember, C(190, 110, 255), 2.2)
		glow(ember, C(190, 120, 255), 34, 1.8)
		banner(g, CX + sx * 14, AZ - 14, sx > 0 and 180 or 0, C(60, 30, 96))
	end
	local arch = CFrame.new(CX, 0, AZ + 9)
	for _, sx in { -1, 1 } do P(g, "SignPost", Vector3.new(0.7, 14, 0.7), arch * CFrame.new(sx * 7, 7, 0), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam", true) end
	local sign = P(g, "BestiarySign", Vector3.new(14.6, 3, 0.4), arch * CFrame.new(0, 12.4, 0), C(30, 22, 34), Enum.Material.Wood, "PS2_DarkBeam")
	text(sign, Enum.NormalId.Front, "BESTIARY", C(200, 140, 255), Enum.Font.Creepster, "EVERY MONSTER YOU HAVE BEATEN  -  BADGES")
	crow(g, CX - 7, 14.1, AZ + 9, 200)
	-- candles on the steps
	for i = 1, 9 do
		local a = math.rad(rng:NextNumber(20, 160))
		local r = rng:NextNumber(6, 9.5)
		local x, z = CX + math.cos(a) * r, AZ - math.sin(a) * r
		local y = r > 8.7 and 0.1 or (r > 6.9 and 0.8 or 1.5)
		local h = rng:NextNumber(0.5, 1.2)
		cyl(g, "Candle", 0.18, h, Vector3.new(x, y + h / 2, z), C(226, 216, 190), Enum.Material.SmoothPlastic)
		local f = P(g, "CandleFlame", Vector3.new(0.18, 0.28, 0.18), CFrame.new(x, y + h + 0.16, z), C(255, 200, 110), Enum.Material.Neon)
		if i % 3 == 0 then glow(f, C(255, 200, 120), 9, 0.7) end
	end
	fireflies(g, CX, AZ - 8, 44, 30)
end

-- EAST END: the leaderboards get a forecourt -------------------------------------------------------------------------
do
	local g = group("FameYard")
	forecourt(g, CX + 104, CZ, 15)
	torch(g, CX + 97, CZ - 13, C(255, 220, 110)); torch(g, CX + 97, CZ + 13, C(255, 220, 110))
	banner(g, CX + 108, CZ - 22, -90, C(120, 96, 24)); banner(g, CX + 108, CZ + 22, -90, C(120, 96, 24))
end

-- THE CLEARING (between the paths and the cabins; the walks up to the cabins at x = +-22 and +-66 stay open) -------------
-- north-west: the graveyard
do
	local g = group("Graveyard")
	local x1, x2, z1, z2 = CX - 58, CX - 30, CZ - 46, CZ - 13
	clearAround((x1 + x2) / 2, (z1 + z2) / 2, 22)
	fence(g, x1, z1, x2, z1, true); fence(g, x1, z1, x1, z2, true); fence(g, x2, z1, x2, z2 - 9, true)
	fence(g, x1, z2, x1 + 9, z2, true); fence(g, x2 - 9, z2, x2, z2, true) -- (a gap in the middle: the way in)
	local spots = { { -51, -40, 20 }, { -37, -38, -30 }, { -50, -26, 160 }, { -38, -22, 200 }, { -44, -32, 90 } }
	for _, s in spots do put("LobbyTombstones", CX + s[1], CZ + s[2], s[3], rng:NextNumber(0.85, 1.15), g, 0.25) end
	for _ = 1, 7 do
		local x, z = rng:NextNumber(x1 + 3, x2 - 3), rng:NextNumber(z1 + 3, z2 - 3)
		P(g, "GraveMound", Vector3.new(2.6, 0.5, 5), CFrame.new(x, 0.25, z) * CFrame.Angles(0, rng:NextNumber(-0.2, 0.2), 0), C(50, 40, 32), Enum.Material.Mud, "PS2_Mud")
	end
	local lamp = P(g, "GraveLantern", Vector3.new(0.6, 0.8, 0.6), CFrame.new(CX - 44, 1.2, CZ - 30), C(140, 220, 255), Enum.Material.Neon)
	lamp.Transparency = 0.3
	glow(lamp, C(140, 210, 255), 30, 1.4)
	crow(g, x2, 5.3, z1 + 7, 260); crow(g, x1 + 4.5, 5.3, z2, 30)
	-- more graves further west, outside the fence
	clearAround(CX - 94, CZ - 30, 18)
	for _, s in { { -102, -36, 40 }, { -88, -24, -20 }, { -94, -40, 100 } } do put("LobbyTombstones", CX + s[1], CZ + s[2], s[3], 1, g, 0.25) end
	put("LobbyScarecrow", CX - 96, CZ - 20, 150, 1.3, g, 0.2)
end
-- north-east: the camp
do
	local g = group("Camp")
	clearAround(CX + 44, CZ - 30, 20)
	put("LobbyCampfire", CX + 44, CZ - 30, 0, 1.15, g)
	local fire = P(g, "CampFire", Vector3.new(1.6, 0.4, 1.6), CFrame.new(CX + 44, 1.2, CZ - 30), C(255, 140, 40), Enum.Material.Neon)
	fire.Transparency = 0.4
	flame(fire, C(255, 150, 50), 3)
	glow(fire, C(255, 150, 60), 46, 2.2)
	local s = Instance.new("Sound"); s.Name = "Crackle"; s.SoundId = "rbxassetid://9079463756"; s.Looped = true; s.Volume = 0.5; s.RollOffMaxDistance = 60; s.RollOffMinDistance = 8; s.Playing = true; s.Parent = fire
	-- a patched tent
	local tent = CFrame.new(CX + 53, 0, CZ - 40) * CFrame.Angles(0, math.rad(-35), 0)
	for _, sx in { -1, 1 } do
		P(g, "TentSide", Vector3.new(0.15, 6.6, 9), tent * CFrame.new(sx * 2.2, 2.75, 0) * CFrame.Angles(0, 0, math.rad(sx * 38)), sx > 0 and C(86, 82, 60) or C(76, 72, 54), Enum.Material.Fabric, nil, true)
	end
	P(g, "TentRidge", Vector3.new(0.3, 0.3, 9.6), tent * CFrame.new(0, 5.35, 0), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam")
	P(g, "TentPole", Vector3.new(0.3, 5.4, 0.3), tent * CFrame.new(0, 2.7, 4.6), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam")
	P(g, "TentPole", Vector3.new(0.3, 5.4, 0.3), tent * CFrame.new(0, 2.7, -4.6), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam")
	P(g, "Bedroll", Vector3.new(2.2, 0.5, 5.4), tent * CFrame.new(0.4, 0.35, 0), C(110, 50, 44), Enum.Material.Fabric)
	crate(g, CX + 36, CZ - 39, 2.4); crate(g, CX + 38.6, CZ - 40.5, 1.8); barrel(g, CX + 34, CZ - 36)
	-- the wagon and the well, further east
	clearAround(CX + 94, CZ - 30, 20)
	put("LobbyWagon", CX + 96, CZ - 34, 70, 1.9, g)
	wall(g, Vector3.new(8, 8, 12), CFrame.new(CX + 96, 4, CZ - 34) * CFrame.Angles(0, math.rad(70), 0))
	put("LobbyWell", CX + 84, CZ - 20, 200, 1.15, g)
	wall(g, Vector3.new(6.4, 8, 6.4), CFrame.new(CX + 84, 4, CZ - 20))
	crate(g, CX + 104, CZ - 24, 2.6); barrel(g, CX + 101, CZ - 20.5)
	fireflies(g, CX + 70, CZ - 30, 80, 30)
end
-- south-west: the pumpkin patch
do
	local g = group("PumpkinPatch")
	local x1, x2, z1, z2 = CX - 58, CX - 30, CZ + 14, CZ + 46
	clearAround((x1 + x2) / 2, (z1 + z2) / 2, 22)
	fence(g, x1, z2, x2, z2); fence(g, x1, z1 + 2, x1, z2); fence(g, x2, z1 + 10, x2, z2)
	for r = 0, 3 do
		P(g, "Furrow", Vector3.new(24, 0.3, 2.4), CFrame.new((x1 + x2) / 2, 0.2, z1 + 6 + r * 7), C(74, 58, 44), Enum.Material.Mud, "PS2_Mud")
	end
	for _, s in { { -52, 20, 30, 0.8 }, { -40, 20, 200, 0.6 }, { -47, 27, 110, 0.9 }, { -36, 34, -40, 0.7 }, { -53, 41, 170, 0.75 }, { -42, 41, 60, 0.6 } } do
		put("LobbyPumpkins", CX + s[1], CZ + s[2], s[3], s[4], g, 0.1)
	end
	local jack = P(g, "PumpkinGlow", Vector3.new(0.5, 0.5, 0.5), CFrame.new(CX - 47, 1.6, CZ + 27), C(255, 150, 40), Enum.Material.Neon)
	jack.Transparency = 1
	glow(jack, C(255, 150, 50), 26, 1.5)
	put("LobbyScarecrow", CX - 44, CZ + 35, 0, 1.4, g, 0.2)
	for i = 1, 3 do
		cyl(g, "HayBale", 1.6, 3.4, Vector3.new(CX - 33 - i * 0.3, 1.7, CZ + 16 + i * 3.6), C(176, 150, 74), Enum.Material.Grass, nil, true).CFrame *= CFrame.Angles(0, 0, math.pi / 2)
	end
	crow(g, CX - 44, 11.9, CZ + 35, 180)
	-- further west: hay, a cart of pumpkins
	clearAround(CX - 94, CZ + 30, 18)
	put("LobbyWagon", CX - 96, CZ + 32, -60, 1.7, g)
	wall(g, Vector3.new(7, 7, 11), CFrame.new(CX - 96, 3.5, CZ + 32) * CFrame.Angles(0, math.rad(-60), 0))
	put("LobbyPumpkins", CX - 88, CZ + 26, 20, 1, g, 0.1)
	put("LobbyPumpkins", CX - 102, CZ + 22, 250, 0.7, g, 0.1)
	fireflies(g, CX - 70, CZ + 30, 80, 30)
end
-- south-east: the pond and the old playground
do
	local g = group("Pond")
	local px, pz = CX + 44, CZ + 31
	clearAround(px, pz, 21)
	local water = cyl(g, "Water", 12, 0.16, Vector3.new(px, 0.16, pz), C(16, 30, 34), Enum.Material.Glass)
	water.Reflectance = 0.25
	cyl(g, "WaterDeep", 8, 0.18, Vector3.new(px + 1, 0.17, pz - 1), C(8, 16, 20), Enum.Material.Glass)
	for i = 1, 16 do
		local a = i / 16 * math.pi * 2 + rng:NextNumber(-0.15, 0.15)
		P(g, "BankStone", Vector3.new(rng:NextNumber(1.5, 3), rng:NextNumber(0.6, 1.3), rng:NextNumber(1.4, 2.4)), CFrame.new(px + math.cos(a) * 12.2, 0.4, pz + math.sin(a) * 12.2) * CFrame.Angles(0, rng:NextNumber(0, 3), 0),
			STONE:Lerp(C(40, 46, 40), rng:NextNumber(0, 0.6)), Enum.Material.Slate, nil, true)
	end
	wall(g, Vector3.new(17, 5, 17), CFrame.new(px, 2.5, pz + 1.5)) -- nobody wades in
	-- a short dock from the north bank, and a rowboat
	for i = 0, 5 do
		P(g, "DockPlank", Vector3.new(4.2, 0.3, 1.5), CFrame.new(px - 3, 1.1, pz - 13 + i * 1.6) * CFrame.Angles(0, rng:NextNumber(-0.04, 0.04), 0), WOOD:Lerp(DARKWOOD, rng:NextNumber(0, 0.6)), Enum.Material.WoodPlanks, "PS2_Siding", true)
	end
	for _, o in { Vector3.new(-5, 0, -13), Vector3.new(-1, 0, -13), Vector3.new(-5, 0, -5.4), Vector3.new(-1, 0, -5.4) } do
		P(g, "DockPost", Vector3.new(0.5, 3.4, 0.5), CFrame.new(px + o.X, 1.3, pz + o.Z), DARKWOOD, Enum.Material.Wood, "PS2_DarkBeam")
	end
	local boat = CFrame.new(px + 3.5, 0.5, pz + 1) * CFrame.Angles(0, math.rad(35), math.rad(4))
	P(g, "BoatHull", Vector3.new(3, 0.4, 7), boat, C(70, 50, 36), Enum.Material.WoodPlanks, "PS2_Siding")
	for _, sx in { -1, 1 } do P(g, "BoatSide", Vector3.new(0.3, 1.1, 7), boat * CFrame.new(sx * 1.5, 0.6, 0) * CFrame.Angles(0, 0, math.rad(-sx * 12)), C(60, 42, 30), Enum.Material.WoodPlanks, "PS2_Siding") end
	P(g, "BoatSeat", Vector3.new(2.8, 0.25, 0.9), boat * CFrame.new(0, 0.7, 0.5), WOOD, Enum.Material.Wood, "PS2_DarkBeam")
	for i = 1, 14 do
		local a = rng:NextNumber(0, math.pi * 2)
		local r = rng:NextNumber(10.5, 12)
		P(g, "Reed", Vector3.new(0.14, rng:NextNumber(2.5, 4.5), 0.14), CFrame.new(px + math.cos(a) * r, 1.6, pz + math.sin(a) * r) * CFrame.Angles(rng:NextNumber(-0.15, 0.15), 0, rng:NextNumber(-0.15, 0.15)), C(70, 84, 44), Enum.Material.Grass)
	end
	local moon = P(g, "PondGlow", Vector3.new(0.5, 0.5, 0.5), CFrame.new(px, 3, pz), C(120, 190, 200), Enum.Material.Neon)
	moon.Transparency = 1
	glow(moon, C(110, 180, 200), 34, 1.1)
	-- the old playground, further east
	clearAround(CX + 94, CZ + 30, 18)
	local swing, bench = assets:FindFirstChild("SwingSet"), assets:FindFirstChild("Bench")
	for _, e in { { swing, CX + 96, CZ + 34, 20 }, { bench, CX + 84, CZ + 22, 140 }, { bench, CX + 104, CZ + 20, 220 } } do
		local src = e[1] :: Instance?
		if src and (src:IsA("Model") or src:IsA("BasePart")) then
			local m = src:Clone()
			local target = CFrame.new(e[2] :: number, 0, e[3] :: number) * CFrame.Angles(0, math.rad(e[4] :: number), 0)
			if m:IsA("Model") then
				m:PivotTo(target + Vector3.new(0, 20, 0))
				local cf, size = m:GetBoundingBox()
				m:PivotTo(m:GetPivot() + Vector3.new(0, 0.1 - (cf.Position.Y - size.Y / 2), 0))
			else
				m.CFrame = target + Vector3.new(0, m.Size.Y / 2 + 0.1, 0)
			end
			for _, d in (m:IsA("BasePart") and { m } or m:GetDescendants()) :: { Instance } do
				if d:IsA("BasePart") then d.Anchored = true end
			end
			m.Parent = g
		end
	end
	fireflies(g, CX + 94, CZ + 30, 36, 30)
end

return "lobby detail built: " .. count .. " parts and props"
