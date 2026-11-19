-- THE ASHEN ABBEY: what its five buildings share (Shared/Campaign map 4: one building per train trip). Prepend after
-- lib2 + furn_lib + maplib, then one maps/abb_<building>.luau:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_cloister.luau
-- Every building is a map on the Mansion's footprint. Outside: the abbey's grounds sinking into hell - burnt black
-- earth split by glowing cracks, a stone path from the porch to the railway between broken walls, gravestones and
-- dead trees, iron braziers burning, the ASHEN ABBEY arch over the path, and far behind the building the great
-- cathedral spire against a red sky. On the building: a stone sign board with two iron lanterns over the porch.
-- Then furnish (ONLY = the map), detail (TARGET = the map), doors_clear, and maps/abbey_moon_items.luau.
local C3a = Color3.fromRGB
local ABB = {
	stone = st(M.Cobblestone, "PS2_Stone1", C3a(96, 90, 86)),
	stoneD = st(M.Cobblestone, "PS2_Stone1", C3a(64, 60, 58)),
	stoneL = st(M.Cobblestone, "PS2_Stone1", C3a(130, 124, 116)),
	slab = st(M.Slate, nil, C3a(84, 80, 76)),
	marble = st(M.Marble, nil, C3a(150, 144, 136)),
	beam = st(M.Wood, "PS2_DarkBeam1", C3a(56, 40, 30)),
	plank = st(M.WoodPlanks, "PS2_FloorPlanks2", C3a(80, 62, 48)),
	iron = st(M.Metal, nil, C3a(44, 42, 44)),
	gold = st(M.Metal, nil, C3a(180, 140, 60)),
	bronze = st(M.Metal, nil, C3a(170, 120, 56)),
	red = st(M.Fabric, nil, C3a(110, 20, 20)),
	cloth = st(M.Fabric, nil, C3a(150, 140, 120)),
	bone = st(M.SmoothPlastic, nil, C3a(206, 196, 168)),
	ash = st(M.Slate, nil, C3a(42, 38, 36)),
	earth = st(M.Ground, nil, C3a(46, 34, 28)),
	lava = st(M.Neon, nil, C3a(255, 90, 30)),
	ember = st(M.Neon, nil, C3a(255, 160, 60)),
	holy = st(M.Neon, nil, C3a(255, 230, 170)),
	candle = st(M.SmoothPlastic, nil, C3a(226, 216, 192)),
	glassR = st(M.Glass, nil, C3a(200, 40, 40)),
	glassB = st(M.Glass, nil, C3a(50, 80, 200)),
	glassY = st(M.Glass, nil, C3a(230, 190, 60)),
	glassG = st(M.Glass, nil, C3a(50, 150, 70)),
	moss = st(M.Grass, nil, C3a(46, 56, 34)),
}
local function abbTheme(over: { [string]: any }?)
	local t = {
		floor = st(M.Slate, nil, C3a(78, 74, 70)), floor2 = st(M.Slate, nil, C3a(78, 74, 70)), inner = st(M.Cobblestone, "PS2_Stone1", C3a(112, 106, 100)),
		wainscot = ABB.stoneD, wain = true, ext = ABB.stone, trim = ABB.stoneD, ceiling = ABB.beam, roof = st(M.Slate, nil, C3a(40, 38, 40)),
		found = ABB.stoneD, door = st(M.WoodPlanks, "PS2_Siding1", C3a(60, 40, 30)), porch = ABB.stoneD,
		lanternColor = C3a(255, 170, 90), floodColor = C3a(255, 140, 90),
	}
	for k, v in over or {} do t[k] = v end
	return t
end

-- an iron lantern on a bracket (deco), warm light
local function abbLantern(parent: Instance, p: Vector3, range: number?)
	local m = model(parent, "Lantern")
	box(m, "Cage", p.X - 0.55, p.Y - 0.8, p.Z - 0.55, p.X + 0.55, p.Y + 0.8, p.Z + 0.55, ABB.iron, { deco = true, t = 0.4 })
	box(m, "Cap", p.X - 0.7, p.Y + 0.8, p.Z - 0.7, p.X + 0.7, p.Y + 1.1, p.Z + 0.7, ABB.iron, DECO)
	local g = box(m, "Glow", p.X - 0.3, p.Y - 0.5, p.Z - 0.3, p.X + 0.3, p.Y + 0.5, p.Z + 0.3, ABB.ember, DECO)
	light(g, range or 22, 1.2, C3a(255, 160, 90))
	return m
end
-- an iron brazier on three legs with a fire in it (deco)
local function abbBrazier(parent: Instance, p: Vector3)
	local m = model(parent, "Brazier")
	for k = 0, 2 do
		local a = k / 3 * math.pi * 2
		part(m, "Leg", Vector3.new(0.3, 3.4, 0.3), CFrame.new(p + Vector3.new(math.cos(a) * 0.9, 1.6, math.sin(a) * 0.9)) * CFrame.Angles(math.sin(a) * 0.2, 0, -math.cos(a) * 0.2), ABB.iron, DECO)
	end
	cyl(m, CFrame.new(p.X, p.Y + 3.4, p.Z), "Bowl", 2.6, 0.9, 0, 0, 0, ABB.iron, { deco = true })
	local f = ball(m, CFrame.new(p.X, p.Y + 3.9, p.Z), "Coals", 1.8, 0, 0, 0, ABB.ember, { deco = true })
	local fire = Instance.new("Fire"); fire.Size = 4; fire.Heat = 8; fire.Color = C3a(255, 120, 40); fire.SecondaryColor = C3a(180, 30, 10); fire.Parent = f
	light(f, 26, 1.5, C3a(255, 140, 70))
	return m
end
-- a gravestone (deco): rounded top, a cross on some
local function abbGrave(parent: Instance, cf: CFrame, rng: Random)
	local m = model(parent, "Grave")
	local w, h = rng:NextNumber(2, 3), rng:NextNumber(2.6, 4)
	b(m, cf, "Stone", w, h, 0.6, 0, h / 2, 0, ABB.stoneL, DECO)
	cyl(m, cf * CFrame.new(0, h, 0) * CFrame.Angles(math.pi / 2, 0, 0), "Top", w, 0.6, 0, 0, 0, ABB.stoneL, { deco = true }) -- (a round top: its axis through the stone)
	if rng:NextNumber() < 0.4 then
		b(m, cf, "Cross", 0.4, 1.6, 0.4, 0, h + 1.2, 0, ABB.stoneL, DECO)
		b(m, cf, "CrossBar", 1.2, 0.4, 0.4, 0, h + 1.5, 0, ABB.stoneL, DECO)
	end
	b(m, cf, "Mound", w + 0.6, 0.4, 4, 0, 0.2, -2.4, ABB.earth, DECO)
	return m
end
-- a dead tree (deco): a crooked trunk and bare branches
local function abbDeadTree(parent: Instance, p: Vector3, rng: Random)
	local m = model(parent, "DeadTree")
	local h = rng:NextNumber(10, 16)
	local lean = rng:NextNumber(-0.15, 0.15)
	part(m, "Trunk", Vector3.new(1.2, h, 1.2), CFrame.new(p + Vector3.new(0, h / 2, 0)) * CFrame.Angles(lean, 0, lean * 0.5), ABB.ash, DECO)
	for k = 1, 5 do
		local y = h * rng:NextNumber(0.45, 0.95)
		local a = rng:NextNumber(0, math.pi * 2)
		local len = rng:NextNumber(3, 6)
		part(m, "Branch", Vector3.new(0.4, len, 0.4), CFrame.new(p + Vector3.new(0, y, 0)) * CFrame.Angles(0, a, rng:NextNumber(0.6, 1.1)) * CFrame.new(0, len / 2, 0), ABB.ash, DECO)
		local _ = k
	end
	return m
end
-- a stained-glass window panel set into a wall (deco): coloured panes in a stone frame; face = way it looks
local function abbStained(parent: Instance, cf: CFrame, w: number, h: number)
	local m = model(parent, "Stained")
	b(m, cf, "Frame", w + 1, h + 1, 0.4, 0, 0, 0, ABB.stoneD, DECO)
	local cols = { ABB.glassR, ABB.glassB, ABB.glassY, ABB.glassG }
	local n = 4
	for i = 0, n - 1 do
		for j = 0, 2 do
			local p = b(m, cf, "Pane", w / n - 0.15, h / 3 - 0.15, 0.2, -w / 2 + (i + 0.5) * w / n, -h / 2 + (j + 0.5) * h / 3, -0.15, cols[((i + j) % 4) + 1], DECO)
			p.Transparency = 0.15
			p.Material = Enum.Material.Neon
			p.Color = p.Color:Lerp(Color3.new(0, 0, 0), 0.35)
		end
	end
	b(m, cf, "Lead", 0.15, h, 0.3, 0, 0, -0.2, ABB.iron, DECO)
	b(m, cf, "Lead", w, 0.15, 0.3, 0, 0, -0.2, ABB.iron, DECO)
	return m
end
-- a stand of candles on the floor (deco): wax candles of different heights, flames, one light
local function abbCandles(parent: Instance, p: Vector3, rng: Random, n: number?)
	local m = model(parent, "Candles")
	for k = 1, n or 5 do
		local o = Vector3.new(rng:NextNumber(-1, 1), 0, rng:NextNumber(-1, 1))
		local h = rng:NextNumber(0.6, 1.8)
		cyl(m, CFrame.new(p + o + Vector3.new(0, h / 2, 0)) * CFrame.Angles(0, 0, math.pi / 2), "Candle", 0.3, h, 0, 0, 0, ABB.candle, { deco = true })
		ball(m, CFrame.new(p + o + Vector3.new(0, h + 0.15, 0)), "Flame", 0.22, 0, 0, 0, ABB.ember, { deco = true })
	end
	local g = ball(m, CFrame.new(p + Vector3.new(0, 1.6, 0)), "Core", 0.2, 0, 0, 0, ABB.ember, { deco = true, t = 1 })
	light(g, 14, 1, C3a(255, 170, 90))
	return m
end
-- a glowing crack of hellfire across the floor (deco): a jagged chain of thin neon slabs
local function abbCrack(parent: Instance, a: Vector3, z: Vector3, y: number, rng: Random, width: number?)
	local n = 8
	local last = a
	for i = 1, n do
		local p = a:Lerp(z, i / n) + Vector3.new(rng:NextNumber(-1.5, 1.5), 0, rng:NextNumber(-1.5, 1.5))
		local mid = (last + p) / 2
		local len = (p - last).Magnitude
		part(parent, "Crack", Vector3.new(width or 0.7, 0.08, len + 0.4), CFrame.lookAt(Vector3.new(mid.X, y, mid.Z), Vector3.new(p.X, y, p.Z)), ABB.lava, DECO)
		part(parent, "CrackEdge", Vector3.new((width or 0.7) + 1, 0.06, len + 0.6), CFrame.lookAt(Vector3.new(mid.X, y - 0.01, mid.Z), Vector3.new(p.X, y - 0.01, p.Z)), ABB.ash, DECO)
		last = p
	end
end

-- the building's name on a stone board over the porch roof, an iron lantern each side
local function abbSign(text: string)
	local m = model(DEC, "Marquee")
	local cf = CFrame.new(0, 21, 61) * CFrame.Angles(0, math.pi, 0)
	b(m, cf, "Board", 26, 5, 0.6, 0, 0, 0.3, ABB.stoneD, DECO)
	b(m, cf, "Frame", 27.4, 6, 0.4, 0, 0, 0.6, ABB.stone, DECO)
	sign(m, text, cf * CFrame.new(0, 0, -0.05), 23, 3.4, ABB.stoneD, C3a(255, 200, 150), Enum.Font.Creepster)
	for _, x in { -14.8, 14.8 } do abbLantern(m, Vector3.new(x, 19.2, 61.8), 26) end
	-- a cross over it
	b(m, cf, "Cross", 0.8, 5, 0.6, 0, 5, 0.4, ABB.stone, DECO)
	b(m, cf, "CrossBar", 3, 0.8, 0.6, 0, 5.8, 0.4, ABB.stone, DECO)
end

-- the grounds (everything decoration: no collision, never hit by a ray)
local function abbGrounds()
	local yd = model(DEC, "AbbeyGrounds")
	local rng = Random.new(66)
	-- burnt earth over the yard, split by glowing cracks
	box(yd, "Ash", -160, 0.04, 62, 160, 0.12, 200, ABB.earth, DECO)
	for k = 0, 9 do
		local x0 = (k % 2 == 0 and -1 or 1) * rng:NextNumber(14, 140)
		local z0 = rng:NextNumber(70, 190)
		abbCrack(yd, Vector3.new(x0, 0, z0), Vector3.new(x0 + rng:NextNumber(-30, 30), 0, z0 + rng:NextNumber(-20, 20)), 0.14, rng, rng:NextNumber(0.5, 1))
	end
	-- the stone path from the porch to the railway, broken walls along it
	box(yd, "Path", -6, 0.1, 64, 6, 0.3, 146, ABB.slab, DECO)
	for z = 66, 144, 6 do
		for _, x in { -6.4, 6.4 } do box(yd, "Kerb", x - 0.4, 0.1, z, x + 0.4, 0.6, z + 5, ABB.stoneD, DECO) end
	end
	for _, sx in { -1, 1 } do
		for k = 0, 4 do
			local z = 76 + k * 16
			local h = rng:NextNumber(2, 6)
			box(yd, "Wall", sx * 12 - 1, 0, z, sx * 12 + 1, h, z + rng:NextNumber(6, 12), ABB.stone, DECO)
		end
	end
	-- gravestones, dead trees, braziers
	for i = 1, 26 do
		local x = (i % 2 == 0 and -1 or 1) * rng:NextNumber(18, 70)
		local z = rng:NextNumber(70, 140)
		abbGrave(yd, CFrame.new(x, 0.1, z) * CFrame.Angles(rng:NextNumber(-0.08, 0.08), rng:NextNumber(-0.3, 0.3) + math.pi, rng:NextNumber(-0.12, 0.12)), rng)
	end
	for i = 1, 10 do
		abbDeadTree(yd, Vector3.new((i % 2 == 0 and -1 or 1) * rng:NextNumber(30, 150), 0, rng:NextNumber(70, 190)), rng)
	end
	for _, z in { 84, 108, 132 } do
		for _, x in { -9, 9 } do abbBrazier(yd, Vector3.new(x, 0, z)) end
	end
	-- THE ARCH over the path: two stone piers and a pointed lintel with the name
	for _, x in { -8, 8 } do box(yd, "ArchPier", x - 1.4, 0, 129.5, x + 1.4, 16, 133.5, ABB.stone, DECO) end
	box(yd, "ArchLintel", -9.5, 13, 130, 9.5, 16, 133, ABB.stoneD, DECO)
	part(yd, "ArchPeak", Vector3.new(14, 14, 3), CFrame.new(0, 16, 131.5) * CFrame.Angles(0, 0, math.pi / 4), ABB.stone, DECO)
	sign(yd, "THE ASHEN ABBEY", CFrame.new(0, 14.5, 129.9) * CFrame.Angles(0, math.pi, 0), 17, 2, ABB.stoneD, C3a(255, 190, 140), Enum.Font.Creepster).Name = "AbbSign"
	sign(yd, "THE ASHEN ABBEY", CFrame.new(0, 14.5, 133.1), 17, 2, ABB.stoneD, C3a(255, 190, 140), Enum.Font.Creepster).Name = "AbbSignBack"
	for _, x in { -8, 8 } do abbLantern(yd, Vector3.new(x, 17, 131.5), 30) end
	-- THE CATHEDRAL far behind the building: a dark nave, two towers, the great spire, a red glow under it
	local cat = model(yd, "Cathedral")
	box(cat, "Nave", -40, 0, -190, 40, 60, -130, ABB.stoneD, DECO)
	for _, x in { -50, 50 } do
		box(cat, "Tower", x - 10, 0, -140, x + 10, 100, -120, ABB.stoneD, DECO)
		part(cat, "TowerSpire", Vector3.new(14, 30, 14), CFrame.new(x, 112, -130) * CFrame.Angles(0, math.pi / 4, 0), ABB.ash, DECO)
	end
	part(cat, "Spire", Vector3.new(16, 70, 16), CFrame.new(0, 95, -160) * CFrame.Angles(0, math.pi / 4, 0), ABB.ash, DECO)
	local rose = cyl(cat, CFrame.new(0, 40, -129.5) * CFrame.Angles(math.pi / 2, 0, 0), "RoseWindow", 22, 0.6, 0, 0, 0, ABB.lava, { deco = true })
	rose.Color = C3a(200, 60, 30)
	light(rose, 80, 2, C3a(255, 90, 40))
	local glowF = box(cat, "HellGlow", -60, 0.2, -200, 60, 1, -110, ABB.lava, DECO)
	glowF.Transparency = 0.5
	light(glowF, 60, 2.5, C3a(255, 70, 20))
end
