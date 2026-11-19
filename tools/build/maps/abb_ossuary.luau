-- THE OSSUARY (the Ashen Abbey, building 4: THE FLAYED GIANT, who eats furniture and walls to heal).
-- A charnel house: the walls are built of SKULLS and long bones (rows of skulls between bands of bones), PILLARS of
-- stacked skulls, a CHANDELIER of bones, heaps of bones on the floor (cover), a giant's RIBCAGE arching over the
-- middle, an altar of skulls at the far end, candles in skull holders. At the back, behind a wall of bones with two
-- doorways: the CHARNEL PIT room (bone carts, a pit of bones). Its east end: a SKULL WALL that slides (Secrets: the
-- stash behind it).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_ossuary.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 26
local rng = Random.new(44)
local BONE = ABB.bone
local SOCKET = st(M.SmoothPlastic, nil, C3(20, 16, 14))
beginMap("Abb_Ossuary", abbTheme({ inner = st(M.Cobblestone, "PS2_Stone1", C3(104, 98, 86)), floor = st(M.Slate, nil, C3(72, 68, 62)) }))
shell({ two = false, H = H, roof = "gable", pitch = 0.45, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 4, winB = 8, winT = 16 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "PitWall", "x", -32, -78, 78, F1, H, { dr(-30, 12, 14), dr(30, 12, 14) }, I)

-- a skull on a wall (deco): the skull, two eye sockets and a nose hole, facing `face`
local function skull(parent: Instance, cf: CFrame)
	b(parent, cf, "Skull", 1.1, 1.0, 0.5, 0, 0, 0, BONE, DECO)
	for _, sx in { -0.24, 0.24 } do b(parent, cf, "Socket", 0.3, 0.3, 0.1, sx, 0.1, -0.26, SOCKET, DECO) end
	b(parent, cf, "Nose", 0.14, 0.2, 0.1, 0, -0.18, -0.26, SOCKET, DECO)
end
-- THE BONE WALLS: rows of skulls between bands of crossed bones, along both side walls and the front
local walls = model(DEC, "BoneWalls")
for _, x in { -77.5, 77.5 } do
	local face = x < 0 and -math.pi / 2 or math.pi / 2
	for z = -27, 55, 1.6 do
		if math.abs(z - 20) < 4 or math.abs(z - 44) < 4 or math.abs(z + 30) < 4 then continue end
		for _, y in { 3, 8.5 } do skull(walls, CFrame.new(x, F1 + y, z) * CFrame.Angles(0, face, 0)) end
	end
	for _, y in { 5.5, 11 } do box(walls, "BoneBand", x - 0.3, F1 + y - 0.3, -28, x + 0.3, F1 + y + 0.3, 56, BONE, DECO) end
end
-- PILLARS of stacked skulls holding the roof
local pillars = model(STR, "Pillars")
for _, p in { { -36, 30 }, { 36, 30 }, { -36, -4 }, { 36, -4 } } do
	box(pillars, "PillarCore", p[1] - 2, F1, p[2] - 2, p[1] + 2, F1 + H - 1, p[2] + 2, ABB.stoneD)
	for y = 1, H - 3, 1.4 do
		for k = 0, 3 do
			local cf = CFrame.new(p[1], F1 + y, p[2]) * CFrame.Angles(0, k * math.pi / 2, 0) * CFrame.new(0, 0, -2.3)
			b(DEC, cf, "Skull", 1.1, 1.0, 0.5, 0, 0, 0, BONE, DECO)
			b(DEC, cf, "Sockets", 0.8, 0.3, 0.1, 0, 0.1, -0.26, SOCKET, DECO)
		end
	end
end
-- THE GIANT'S RIBCAGE arching over the middle of the room (deco): a spine along the ceiling and curved ribs
local rib = model(DEC, "Ribcage")
box(rib, "Spine", -1.2, F1 + H - 3, -20, 1.2, F1 + H - 1, 50, BONE, DECO)
for z = -16, 46, 6 do
	for _, sx in { -1, 1 } do
		for k = 0, 4 do
			local a = 0.25 + k * 0.28
			local r = 16
			local cx = sx * math.sin(a) * r
			local cy = F1 + H - 2 - (1 - math.cos(a)) * r
			part(rib, "Rib", Vector3.new(1.0, 3.6, 1.0), CFrame.new(cx, cy, z) * CFrame.Angles(0, 0, sx * a), BONE, DECO)
		end
	end
end
-- heaps of bones on the floor (cover), skulls on top
local heaps = model(STR, "BoneHeaps")
for _, p in { { -58, 44 }, { 58, 44 }, { -58, 12 }, { 58, 12 }, { -14, 14 }, { 14, 44 }, { 0, -18 } } do
	box(heaps, "Heap", p[1] - 3.5, F1, p[2] - 3, p[1] + 3.5, F1 + 2.6, p[2] + 3, ABB.ash)
	for k = 0, 12 do
		part(DEC, "Bone", Vector3.new(0.4, 0.4, rng:NextNumber(1.6, 3)), CFrame.new(p[1] + rng:NextNumber(-3, 3), F1 + 2.4 + rng:NextNumber(0, 1.4), p[2] + rng:NextNumber(-2.5, 2.5))
			* CFrame.Angles(rng:NextNumber(-0.6, 0.6), rng:NextNumber(0, 6), rng:NextNumber(-0.3, 0.3)), BONE, DECO)
		local _ = k
	end
	for k = 0, 2 do skull(DEC, CFrame.new(p[1] - 1.5 + k * 1.5, F1 + 3.3 + (k % 2) * 0.4, p[2]) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6), 0)) end
end
-- THE BONE CHANDELIER over the middle: a ring of bones, skull candle-holders
local ch = model(LIT, "BoneChandelier")
cyl(ch, CFrame.new(0, F1 + 16, 16) * CFrame.Angles(0, 0, 0), "Ring", 9, 0.5, 0, 0, 0, BONE, D())
for k = 0, 9 do
	local a = k / 10 * math.pi * 2
	local p = Vector3.new(math.cos(a) * 4.5, F1 + 16, 16 + math.sin(a) * 4.5)
	skull(ch, CFrame.new(p + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, -a + math.pi / 2, 0))
	cyl(ch, CFrame.new(p + Vector3.new(0, 1.6, 0)) * CFrame.Angles(0, 0, math.pi / 2), "Candle", 0.3, 0.9, 0, 0, 0, ABB.candle, D())
	ball(ch, CFrame.new(p + Vector3.new(0, 2.2, 0)), "Flame", 0.25, 0, 0, 0, ABB.ember, D())
end
for k = 0, 3 do box(ch, "Chain", -0.1 + (k % 2) * 0.2, F1 + 16.3, 16, 0.1 + (k % 2) * 0.2, F1 + H - 1, 16.2, ABB.iron, DECO) end
local cl = b(ch, CFrame.new(0, F1 + 15, 16), "Glow", 0.3, 0.3, 0.3, 0, 0, 0, ABB.ember, { deco = true, t = 1 })
light(cl, 46, 1.6, C3(255, 170, 100))
-- THE ALTAR OF SKULLS by the front (left of the door)
box(STR, "Altar", -34, F1, 50, -20, F1 + 4, 55, ABB.stone)
for k = 0, 9 do skull(DEC, CFrame.new(-33 + k * 1.4, F1 + 4.5, 52.5) * CFrame.Angles(0, math.pi, 0)) end
abbCandles(DEC, Vector3.new(-17, F1, 52), rng, 6)
abbCandles(DEC, Vector3.new(-37, F1, 52), rng, 6)
-- THE CHARNEL PIT ROOM (behind the wall): bone carts, a pit edged with stone, skulls round it
box(DEC, "Pit", -12, F1 + 0.02, -54, 12, F1 + 0.06, -40, st(M.SmoothPlastic, nil, C3(10, 8, 6)), DECO)
for _, z in { -54.6, -39.4 } do box(STR, "PitEdge", -12.6, F1, z - 0.6, 12.6, F1 + 1.2, z + 0.6, ABB.stone) end
for k = 0, 30 do part(DEC, "PitBone", Vector3.new(0.4, 0.4, 2), CFrame.new(rng:NextNumber(-11, 11), F1 + 0.3, rng:NextNumber(-53, -41)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), BONE, DECO) end
for _, p in { { -50, -48 }, { 40, -50 } } do
	box(STR, "BoneCart", p[1] - 4, F1 + 1, p[2] - 2.5, p[1] + 4, F1 + 4, p[2] + 2.5, ABB.beam)
	for k = 0, 6 do skull(DEC, CFrame.new(p[1] - 3 + k, F1 + 4.5, p[2]) * CFrame.Angles(0, rng:NextNumber(0, 6), 0)) end
end
-- THE STASH behind the skull wall (x 50..78, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", 49, F1, -58, 50.2, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", 50.2, F1, -43.2, 60, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", 66, F1, -43.2, 78, F1 + 12, -42, ABB.stoneD)
box(sr, "Lintel", 60, F1 + 9, -43.2, 66, F1 + 12, -42, ABB.stoneD)
box(sr, "Ceiling", 49, F1 + 12, -58, 78, F1 + 12.6, -42, ABB.stone)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "SkullWall")
door:SetAttribute("Slide", Vector3.new(-6.4, 0, 0)); door:SetAttribute("Action", "Push"); door:SetAttribute("Object", "Loose skull wall")
box(door, "Panel", 60, F1, -42.9, 66, F1 + 9, -40.6, ABB.stoneD)
for y = 1, 8, 1.4 do
	for x = 60.8, 65.4, 1.3 do
		local s = b(door, CFrame.new(x, F1 + y, -40.4) * CFrame.Angles(0, math.pi, 0), "Panel", 1.1, 1.0, 0.4, 0, 0, 0, BONE, DECO)
		local _ = s
	end
end
box(door, "Trigger", 62.5, F1 + 4, -39.6, 63.5, F1 + 5, -38.6, BONE, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", 59 - k * 1.4, F1 + 0.06, -40 + k * 0.2, 60 - k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(120, 110, 96)), DECO) end
local loot = model(DEC, "Stash")
abbCandles(loot, Vector3.new(54, F1, -54), rng, 6)
box(loot, "Reliquary", 64, F1, -56, 70, F1 + 3.4, -52, ABB.gold, DECO)
local sg = b(loot, CFrame.new(64, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, ABB.holy, { deco = true, t = 1 })
light(sg, 18, 1, C3(255, 200, 140))

-- lights: skull lanterns along the walls
for _, p in { { -70, 30 }, { 70, 30 }, { -70, 0 }, { 70, 0 }, { -30, -46 }, { 30, -46 } } do abbLantern(LIT, Vector3.new(p[1], F1 + 12, p[2]), 26) end
for _, p in { { -30, 30 }, { 20, 0 }, { -40, -48 } } do blood(p[1], F1, p[2], 2.4) end
for _, p in { { -40, 50 }, { 40, 50 }, { 0, 30 }, { -30, 0 }, { 30, 0 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(56, -42, 70, -34, F1)
abbSign("THE OSSUARY")
abbGrounds()
return endMap()
