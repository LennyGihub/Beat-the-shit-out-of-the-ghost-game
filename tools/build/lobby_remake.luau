-- Lobby remake (run after `lobby` + `lobby_forest`, standalone: python3 tools/studio.py luau Edit tools/build/lobby_remake.luau)
-- 1 the AI-mesh trees are replaced by hand-built low-poly trees (pines, oaks, dead trees) made of plain parts
-- 2 every queue room's AI shed is replaced by a hand-built log cabin (porch, lit window, lantern, chimney)
-- 3 the clearing is brighter: stronger moon fill lights and lamp posts, lighter ground
-- (the lobby's Lighting preset itself lives in Client/Fx.luau PRESETS.lobby). Re-running replaces what it built.
local L = workspace:WaitForChild("Lobby")
local F = L:WaitForChild("Forest")
local CX, CZ = 0, 1000
local rng = Random.new(2026)
local M = Enum.Material
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, o: { [string]: any }?): BasePart
	local cls = (o and o.wedge) and "WedgePart" or "Part"
	local p = Instance.new(cls) :: BasePart
	p.Name = name; p.Anchored = true; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	if o then
		if o.shape then (p :: Part).Shape = o.shape end
		if o.t then p.Transparency = o.t end
		if o.mv then p.MaterialVariant = o.mv end
		if o.deco then p.CanCollide = false; p.CanQuery = false; p.CanTouch = false end
		if o.noShadow then p.CastShadow = false end
	end
	p.Parent = parent
	return p
end
local function light(p: BasePart, range: number, brightness: number, color: Color3)
	local l = Instance.new("PointLight"); l.Range = range; l.Brightness = brightness; l.Color = color; l.Shadows = false; l.Parent = p
	return l
end
local DECO = { deco = true }
local FAR = { deco = true, noShadow = true }

-- 1 TREES ---------------------------------------------------------------------
for _, c in F:GetChildren() do
	if c:IsA("Model") or c.Name == "TrunkCollider" then c:Destroy() end -- the AI trees, their colliders, an older HandTrees
end
local T = Instance.new("Model"); T.Name = "HandTrees"; T.Parent = F
local BARK = { rgb(58, 44, 34), rgb(66, 50, 38), rgb(50, 40, 32) }
local DEADBARK = { rgb(70, 62, 56), rgb(60, 54, 50) }
local PINE = { rgb(26, 52, 40), rgb(22, 44, 36), rgb(32, 60, 44), rgb(24, 48, 44) }
local LEAF = { rgb(40, 66, 36), rgb(34, 58, 34), rgb(48, 74, 38), rgb(58, 70, 34), rgb(32, 54, 40) }
local function pick(t) return t[rng:NextInteger(1, #t)] end
local FOLIAGE = M.Sand -- matte and grainy: flat PS2 foliage, no flower / leaf-litter texture

-- a pine: a tall square trunk in two tapering pieces, then tiers of crossed slabs (an 8-pointed star from above)
-- that shrink toward the top. The lowest tier is well above head height.
local function pine(x: number, z: number, s: number, near: boolean)
	local m = Instance.new("Model"); m.Name = "Pine"; m.Parent = T
	local base = CFrame.new(CX + x, 0, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0) * CFrame.Angles(rng:NextNumber(-0.03, 0.03), 0, rng:NextNumber(-0.03, 0.03))
	local H = rng:NextNumber(34, 46) * s
	local bark = pick(BARK)
	part(m, "Trunk", Vector3.new(2.2 * s, H * 0.5, 2.2 * s), base * CFrame.new(0, H * 0.25, 0), bark, M.Wood, near and nil or FAR)
	part(m, "Trunk", Vector3.new(1.4 * s, H * 0.5, 1.4 * s), base * CFrame.new(0, H * 0.75, 0), bark, M.Wood, near and DECO or FAR)
	local tiers = near and 7 or 5
	local y0 = math.max(H * 0.36, 13)
	for i = 0, tiers - 1 do
		local f = i / (tiers - 1)
		local w = (10.5 - 8 * f) * s
		local y = y0 + (H - y0) * f
		local th = (2.2 - 0.9 * f) * s
		local col = pick(PINE)
		local tilt = CFrame.Angles(rng:NextNumber(-0.06, 0.06), rng:NextNumber(0, 1.5), rng:NextNumber(-0.06, 0.06))
		part(m, "Needles", Vector3.new(w, th, w), base * CFrame.new(0, y, 0) * tilt, col, FOLIAGE, near and DECO or FAR)
		part(m, "Needles", Vector3.new(w * 0.96, th * 0.8, w * 0.96), base * CFrame.new(0, y - th * 0.3, 0) * tilt * CFrame.Angles(0, math.pi / 4, 0), col:Lerp(Color3.new(0, 0, 0), 0.18), FOLIAGE, near and DECO or FAR)
	end
	part(m, "Top", Vector3.new(1.5 * s, 5 * s, 1.5 * s), base * CFrame.new(0, H + 2.5 * s, 0) * CFrame.Angles(0, math.pi / 4, 0), pick(PINE), FOLIAGE, near and DECO or FAR)
end

-- an oak: a thick leaning trunk that forks into boughs, and a tight crown of tilted leaf blocks high up
local function oak(x: number, z: number, s: number, near: boolean)
	local m = Instance.new("Model"); m.Name = "Oak"; m.Parent = T
	local base = CFrame.new(CX + x, 0, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0)
	local H = rng:NextNumber(19, 25) * s
	local bark = pick(BARK)
	local lean = CFrame.Angles(rng:NextNumber(-0.07, 0.07), 0, rng:NextNumber(-0.07, 0.07))
	part(m, "Trunk", Vector3.new(3 * s, H * 0.6, 3 * s), base * lean * CFrame.new(0, H * 0.3, 0), bark, M.Wood, near and nil or FAR)
	part(m, "Trunk", Vector3.new(2.1 * s, H * 0.45, 2.1 * s), base * lean * CFrame.new(0, H * 0.8, 0), bark, M.Wood, near and DECO or FAR)
	local top = base * lean * CFrame.new(0, H, 0)
	local n = near and 3 or 2
	for i = 1, n do
		local a = (i / n) * math.pi * 2 + rng:NextNumber(-0.4, 0.4)
		local len = rng:NextNumber(5, 7) * s
		local bcf = top * CFrame.Angles(0, a, 0) * CFrame.Angles(0, 0, -0.75) * CFrame.new(0, len / 2, 0)
		part(m, "Bough", Vector3.new(1.2 * s, len, 1.2 * s), bcf, bark, M.Wood, near and DECO or FAR)
		local tip = (bcf * CFrame.new(0, len / 2, 0)).Position
		local w = rng:NextNumber(6.5, 8.5) * s
		part(m, "Leaves", Vector3.new(w, w * 0.7, w), CFrame.new(tip + Vector3.new(0, 1.5 * s, 0)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 1.5), rng:NextNumber(-0.3, 0.3)), pick(LEAF), FOLIAGE, near and DECO or FAR)
	end
	local w = rng:NextNumber(8.5, 10.5) * s
	part(m, "Leaves", Vector3.new(w, w * 0.7, w), top * CFrame.new(0, 5.5 * s, 0) * CFrame.Angles(rng:NextNumber(-0.25, 0.25), rng:NextNumber(0, 1.5), rng:NextNumber(-0.25, 0.25)), pick(LEAF), FOLIAGE, near and DECO or FAR)
	if near then
		part(m, "Leaves", Vector3.new(w * 0.65, w * 0.5, w * 0.65), top * CFrame.new(rng:NextNumber(-2, 2) * s, 10 * s, rng:NextNumber(-2, 2) * s) * CFrame.Angles(0.25, 0.7, -0.2), pick(LEAF), FOLIAGE, DECO)
		for k = 1, 3 do -- roots
			local a = rng:NextNumber(0, 6.28)
			part(m, "Root", Vector3.new(4 * s, 0.9 * s, 1.1 * s), base * CFrame.Angles(0, a, 0) * CFrame.new(2.4 * s, 0.3 * s, 0) * CFrame.Angles(0, 0, -0.22), bark, M.Wood, DECO)
		end
	end
end

-- a dead tree: a crooked grey trunk and bare forked branches
local function dead(x: number, z: number, s: number)
	local m = Instance.new("Model"); m.Name = "DeadTree"; m.Parent = T
	local bark = pick(DEADBARK)
	local cf = CFrame.new(CX + x, 0, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0)
	local w = 2.2 * s
	for i = 1, 3 do
		local len = rng:NextNumber(6, 8) * s
		cf = cf * CFrame.Angles(rng:NextNumber(-0.16, 0.16), 0, rng:NextNumber(-0.16, 0.16))
		part(m, "Trunk", Vector3.new(w, len, w), cf * CFrame.new(0, len / 2, 0), bark, M.Wood, i == 1 and nil or DECO)
		cf = cf * CFrame.new(0, len, 0)
		w *= 0.72
		for _ = 1, 2 do
			local a = rng:NextNumber(0, 6.28)
			local bl = rng:NextNumber(4, 8) * s
			local bcf = cf * CFrame.Angles(0, a, 0) * CFrame.Angles(0, 0, -rng:NextNumber(0.7, 1.15)) * CFrame.new(0, bl / 2, 0)
			part(m, "Branch", Vector3.new(w * 0.55, bl, w * 0.55), bcf, bark, M.Wood, DECO)
			local tl = bl * 0.55
			part(m, "Twig", Vector3.new(w * 0.32, tl, w * 0.32), bcf * CFrame.new(0, bl / 2, 0) * CFrame.Angles(0.5, 0, 0.6) * CFrame.new(0, tl / 2, 0), bark, M.Wood, DECO)
		end
	end
end

-- kept clear: the path cross, the rooms (now with their cabins), the shop, the quest board
local ROOMS = { { -66, 62 }, { -22, 62 }, { 22, 62 }, { 66, 62 }, { -66, -62 }, { -22, -62 }, { 22, -62 }, { 66, -62 } }
local function clear(x: number, z: number, margin: number): boolean
	if math.abs(x) < 11 + margin or math.abs(z) < 11 + margin then return false end
	for _, r in ROOMS do
		if math.abs(x - r[1]) < 15 + margin and z * (r[2] > 0 and 1 or -1) > 44 - margin and z * (r[2] > 0 and 1 or -1) < 84 + margin then return false end
	end
	if math.abs(x) < 16 + margin and z > -44 - margin and z < -10 + margin then return false end
	if x < -26 + margin and x > -46 - margin and math.abs(z - 4) < 10 + margin then return false end
	return true
end
local spots = {} :: { Vector2 }
local function free(x: number, z: number, gap: number): boolean
	for _, p in spots do
		if (p - Vector2.new(x, z)).Magnitude < gap then return false end
	end
	return true
end
local placed = 0
for _ = 1, 400 do -- the trees between the rooms: detailed, with solid trunks
	if placed >= 46 then break end
	local x, z = rng:NextNumber(-100, 100), rng:NextNumber(-100, 100)
	if clear(x, z, 5) and free(x, z, 17) then
		table.insert(spots, Vector2.new(x, z))
		placed += 1
		local r = rng:NextNumber()
		local s = rng:NextNumber(0.85, 1.25)
		if r < 0.45 then pine(x, z, s, true) elseif r < 0.8 then oak(x, z, s, true) else dead(x, z, s) end
	end
end
local ring = 0
for _ = 1, 900 do -- a thick wall of forest toward the fence: simpler trees
	if ring >= 190 then break end
	local a = rng:NextNumber(0, math.pi * 2)
	local r = rng:NextNumber(102, 136)
	local x, z = math.clamp(math.cos(a) * r, -134, 134), math.clamp(math.sin(a) * r, -134, 134)
	if clear(x, z, 2) and free(x, z, 8) then
		table.insert(spots, Vector2.new(x, z))
		ring += 1
		local s = rng:NextNumber(1, 1.5)
		if rng:NextNumber() < 0.62 then pine(x, z, s, false) else oak(x, z, s, false) end
	end
end

-- 2 CABINS ----------------------------------------------------------------------
local WALL, WALL_D = rgb(118, 92, 70), rgb(84, 62, 46)
local BEAM = rgb(58, 42, 32)
local STONE = rgb(120, 118, 112)
local ROOF, MOSS = rgb(62, 66, 62), rgb(66, 96, 50)
local WARM = rgb(255, 190, 110)
local function cabin(room: Model, base: CFrame)
	local old = room:FindFirstChild("Shed") if old then old:Destroy() end
	old = room:FindFirstChild("Cabin") if old then old:Destroy() end
	local m = Instance.new("Model"); m.Name = "Cabin"; m.Parent = room
	local cf = base * CFrame.new(0, 0, 12) -- behind the pad; its front (the door) faces -Z, toward the pad
	local function b(name, sx, sy, sz, x, y, z, col, mat, o) return part(m, name, Vector3.new(sx, sy, sz), cf * CFrame.new(x, y, z), col, mat, o) end
	local W, D, HW = 14, 8, 8 -- width, depth, wall height
	b("Foundation", W + 1.2, 1, D + 1.2, 0, 0.5, 0, STONE, M.Cobblestone)
	b("Floor", W, 0.3, D, 0, 1.15, 0, WALL_D, M.WoodPlanks)
	-- walls: plank boards, darker log courses across them, corner posts
	b("Wall", W, HW, 0.7, 0, 1 + HW / 2, D / 2 - 0.35, WALL, M.WoodPlanks)
	for _, sx in { -1, 1 } do b("Wall", 0.7, HW, D, sx * (W / 2 - 0.35), 1 + HW / 2, 0, WALL, M.WoodPlanks) end
	local doorW, doorH = 3.6, 6.4
	local seg = (W - doorW) / 2
	for _, sx in { -1, 1 } do b("Wall", seg, HW, 0.7, sx * (doorW / 2 + seg / 2), 1 + HW / 2, -D / 2 + 0.35, WALL, M.WoodPlanks) end
	b("Lintel", doorW, HW - doorH, 0.7, 0, 1 + doorH + (HW - doorH) / 2, -D / 2 + 0.35, WALL, M.WoodPlanks)
	for _, y in { 2.6, 4.9, 7.2 } do -- log courses on the front and the sides
		for _, sx in { -1, 1 } do
			b("Log", seg + 0.3, 0.45, 0.3, sx * (doorW / 2 + seg / 2), y, -D / 2 - 0.1, WALL_D, M.Wood, DECO)
			b("Log", 0.3, 0.45, D + 0.3, sx * (W / 2 + 0.1), y, 0, WALL_D, M.Wood, DECO)
		end
	end
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do b("Post", 1, HW + 0.6, 1, sx * (W / 2 - 0.2), 1 + HW / 2, sz * (D / 2 - 0.2), BEAM, M.Wood) end
	end
	-- the door (shut), its frame and handle
	b("Door", doorW - 0.3, doorH - 0.1, 0.3, 0, 1 + doorH / 2, -D / 2 + 0.3, rgb(74, 50, 36), M.WoodPlanks)
	for _, sx in { -1, 1 } do b("DoorFrame", 0.4, doorH + 0.3, 0.9, sx * doorW / 2, 1 + doorH / 2, -D / 2 + 0.3, BEAM, M.Wood, DECO) end
	b("DoorFrame", doorW + 0.8, 0.45, 0.9, 0, 1 + doorH + 0.15, -D / 2 + 0.3, BEAM, M.Wood, DECO)
	for _, y in { 2.4, 5.6 } do b("DoorBrace", doorW - 0.5, 0.4, 0.12, 0, y, -D / 2 + 0.1, BEAM, M.Wood, DECO) end
	b("Handle", 0.25, 0.6, 0.3, doorW / 2 - 0.7, 4, -D / 2 + 0.05, rgb(190, 150, 70), M.Metal, DECO)
	-- a lit window on each side of the door
	for _, sx in { -1, 1 } do
		local wx = sx * (doorW / 2 + seg / 2)
		local pane = b("WindowGlow", 2.6, 2.4, 0.15, wx, 5.6, -D / 2 - 0.05, WARM, M.Neon, DECO)
		light(pane, 18, 1.1, WARM)
		b("WindowFrame", 3.1, 0.3, 0.4, wx, 6.95, -D / 2 - 0.1, BEAM, M.Wood, DECO)
		b("WindowFrame", 3.1, 0.3, 0.4, wx, 4.25, -D / 2 - 0.1, BEAM, M.Wood, DECO)
		b("WindowFrame", 0.3, 3, 0.4, wx - 1.4, 5.6, -D / 2 - 0.1, BEAM, M.Wood, DECO)
		b("WindowFrame", 0.3, 3, 0.4, wx + 1.4, 5.6, -D / 2 - 0.1, BEAM, M.Wood, DECO)
		b("WindowBar", 0.18, 2.4, 0.3, wx, 5.6, -D / 2 - 0.12, BEAM, M.Wood, DECO)
		b("WindowBar", 2.6, 0.18, 0.3, wx, 5.6, -D / 2 - 0.12, BEAM, M.Wood, DECO)
	end
	-- pitched roof: two slabs, a ridge beam, gable ends, moss
	local a = math.rad(36)
	local half = D / 2 + 0.9
	local slope = half / math.cos(a)
	local topY = 1 + HW
	for _, sz in { -1, 1 } do
		local rcf = cf * CFrame.new(0, topY + half / 2 * math.tan(a) + 0.25, sz * half / 2) * CFrame.Angles(sz * a, 0, 0)
		part(m, "Roof", Vector3.new(W + 2.4, 0.5, slope + 0.3), rcf, ROOF, M.Slate)
		for k = 1, 3 do
			part(m, "Moss", Vector3.new(rng:NextNumber(2.5, 4.5), 0.12, rng:NextNumber(1.5, 3)), rcf * CFrame.new(rng:NextNumber(-5.5, 5.5), 0.3, rng:NextNumber(-2, 2)) * CFrame.Angles(0, rng:NextNumber(-0.4, 0.4), 0), MOSS, M.Grass, DECO)
		end
	end
	b("Ridge", W + 2.6, 0.55, 0.6, 0, topY + half * math.tan(a) + 0.35, 0, BEAM, M.Wood, DECO)
	local gh = (D / 2) * math.tan(a)
	for _, sx in { -1, 1 } do
		part(m, "Gable", Vector3.new(0.7, gh, D / 2), cf * CFrame.new(sx * (W / 2 - 0.35), topY + gh / 2, -D / 4), WALL, M.WoodPlanks, { wedge = true })
		part(m, "Gable", Vector3.new(0.7, gh, D / 2), cf * CFrame.new(sx * (W / 2 - 0.35), topY + gh / 2, D / 4) * CFrame.Angles(0, math.pi, 0), WALL, M.WoodPlanks, { wedge = true })
	end
	-- stone chimney with a little smoke
	b("Chimney", 2.2, 14, 2.2, -4.4, 7, D / 2 - 1.4, STONE, M.Cobblestone)
	local cap = b("ChimneyCap", 2.8, 0.5, 2.8, -4.4, 14.2, D / 2 - 1.4, rgb(88, 86, 82), M.Cobblestone, DECO)
	local at = Instance.new("Attachment"); at.Position = Vector3.new(0, 0.5, 0); at.Parent = cap
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"; pe.Color = ColorSequence.new(rgb(150, 150, 156)); pe.Rate = 3
	pe.Lifetime = NumberRange.new(4, 6); pe.Speed = NumberRange.new(2, 3); pe.SpreadAngle = Vector2.new(12, 12)
	pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 4.5) })
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) })
	pe.Acceleration = Vector3.new(0.6, 0.4, 0); pe.LightInfluence = 1; pe.Parent = at
	-- porch: deck, two posts, a lean-to roof, a step, a lantern by the door
	b("Porch", W, 0.4, 2.8, 0, 0.9, -D / 2 - 1.4, WALL_D, M.WoodPlanks)
	b("Step", 5, 0.45, 1.1, 0, 0.35, -D / 2 - 3.2, WALL_D, M.WoodPlanks)
	for _, sx in { -1, 1 } do b("PorchPost", 0.6, 6.6, 0.6, sx * (W / 2 - 0.5), 4.4, -D / 2 - 2.5, BEAM, M.Wood) end
	part(m, "PorchRoof", Vector3.new(W + 1.6, 0.35, 3.6), cf * CFrame.new(0, 7.9, -D / 2 - 1.5) * CFrame.Angles(-0.2, 0, 0), ROOF, M.Slate, DECO)
	b("LanternArm", 0.2, 0.2, 1, doorW / 2 + 0.7, 7, -D / 2 - 0.5, rgb(30, 28, 26), M.Metal, DECO)
	local lan = b("Lantern", 0.7, 1, 0.7, doorW / 2 + 0.7, 6.4, -D / 2 - 0.9, rgb(255, 176, 90), M.Neon, DECO)
	light(lan, 30, 1.6, rgb(255, 176, 100))
	-- porch clutter: a barrel and a stack of firewood
	part(m, "Barrel", Vector3.new(2.6, 2, 2), cf * CFrame.new(-W / 2 + 1.6, 2.4, -D / 2 - 1.4) * CFrame.Angles(0, 0, math.pi / 2), rgb(96, 68, 46), M.WoodPlanks, { shape = Enum.PartType.Cylinder })
	for i = 0, 4 do
		local row, col = i // 3, i % 3
		part(m, "Firewood", Vector3.new(2.4, 0.8, 0.8), cf * CFrame.new(W / 2 - 1.7, 1.5 + row * 0.75, -D / 2 - 0.9 - col * 0.8 - row * 0.4) * CFrame.Angles(0, rng:NextNumber(-0.08, 0.08), 0), rgb(110, 82, 56), M.Wood, { shape = Enum.PartType.Cylinder, deco = true })
	end
end
local rooms = L:WaitForChild("Rooms")
local built = 0
for _, r in ROOMS do
	for _, room in rooms:GetChildren() do
		local pad = room:FindFirstChild("Pad") :: BasePart?
		if pad and math.abs(pad.Position.X - (CX + r[1])) < 3 and math.abs(pad.Position.Z - (CZ + r[2])) < 6 then
			cabin(room :: Model, CFrame.new(CX + r[1], 0, CZ + r[2]) * CFrame.Angles(0, r[2] > 0 and 0 or math.pi, 0))
			built += 1
		end
	end
end

-- 3 BRIGHTER --------------------------------------------------------------------
local lamps = 0
for _, c in L:GetChildren() do
	if c.Name == "FillLight" then
		local l = c:FindFirstChildOfClass("PointLight")
		if l then l.Color = rgb(150, 172, 215); l.Brightness = 0.7; l.Range = 60 end
	elseif c.Name == "LampPost" then
		for _, d in c:GetDescendants() do
			if d:IsA("PointLight") then d.Brightness = 2.2; d.Range = 38; lamps += 1 end
		end
	end
end
local ground = L:FindFirstChild("Ground")
if ground then
	for _, p in ground:GetDescendants() do
		if p:IsA("BasePart") then
			if p.Name == "Mud" then p.Color = rgb(88, 76, 62)
			elseif p.Name == "DeadGrass" then p.Color = rgb(66, 76, 48)
			elseif p.Name == "Path" then p.Color = rgb(104, 90, 72) end
		end
	end
end
return string.format("trees %d + %d (%d parts), cabins %d, lamp lights %d", placed, ring, #T:GetDescendants(), built, lamps)
