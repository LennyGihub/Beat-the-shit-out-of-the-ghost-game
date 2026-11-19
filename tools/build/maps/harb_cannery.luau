-- THE CANNERY (Blackwater Harbor, building 2: THE SEWER RAT, grown fat in here - he charges in straight lines and
-- burrows under the floor). The front hall: two long CONVEYOR BELTS (low, on legs: you can jump them, he smashes
-- through what stands in his lane), towers of TINS, a sorting table. Behind a wall with three doorways: the BOILER
-- ROOM - two big boilers with pipes up into the roof, coal heaps, a furnace glowing orange, steam.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_cannery.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 24
local rng = Random.new(21)
beginMap("Harb_Cannery", harbTheme({ floor = st(M.Concrete, nil, C3(110, 108, 102)), inner = st(M.Brick, nil, C3(110, 66, 50)), wain = false,
	ext = st(M.Brick, nil, C3(96, 58, 46)) }))
shell({ two = false, H = H, roof = "gable", pitch = 0.35, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 7, winB = 7, winT = 16 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "BoilerWall", "x", -26, -78, 78, F1, H, { dr(-46, 10, 13), dr(0, 12, 14), dr(46, 10, 13) }, I)

local TIN = st(M.Metal, nil, C3(176, 180, 186))
local LABEL = { st(M.SmoothPlastic, nil, C3(170, 40, 36)), st(M.SmoothPlastic, nil, C3(40, 90, 150)), st(M.SmoothPlastic, nil, C3(200, 160, 50)) }
-- THE CONVEYOR BELTS: a black belt on rollers, iron legs, tins riding along
local belts = model(STR, "Belts")
for _, z in { 30, 2 } do
	box(belts, "Belt", -60, F1 + 2.4, z - 2, 40, F1 + 2.9, z + 2, HARB.black)
	for x = -58, 38, 8 do
		for _, dz in { -1.8, 1.8 } do box(DEC, "Leg", x - 0.3, F1, z + dz - 0.3, x + 0.3, F1 + 2.4, z + dz + 0.3, HARB.iron, DECO) end
	end
	for x = -59, 39, 2 do cyl(DEC, CFrame.new(x, F1 + 2.4, z) * CFrame.Angles(math.pi / 2, 0, 0), "Roller", 0.6, 4.2, 0, 0, 0, HARB.iron, D()) end
	for x = -56, 36, 3.5 do
		cyl(DEC, CFrame.new(x, F1 + 3.6, z + rng:NextNumber(-1, 1)), "Tin", 1.2, 1.4, 0, 0, 0, TIN, D())
	end
	box(DEC, "BeltEnd", 40, F1, z - 2.6, 44, F1 + 5, z + 2.6, HARB.rust, DECO)
end
-- towers of tins (solid stacks: cover) and loose tins on the floor
for _, p in { { -70, 48 }, { 66, 46 }, { 60, 18 }, { -70, 14 }, { 56, -14 } } do
	local h = rng:NextInteger(3, 5)
	for k = 0, h - 1 do
		for i = 0, 2 do
			for j = 0, 1 do
				cyl(STR, CFrame.new(p[1] + i * 1.3 - 1.3, F1 + 0.7 + k * 1.4, p[2] + j * 1.3 - 0.65), "Tin", 1.2, 1.4, 0, 0, 0, TIN)
				cyl(DEC, CFrame.new(p[1] + i * 1.3 - 1.3, F1 + 0.7 + k * 1.4, p[2] + j * 1.3 - 0.65), "Label", 1.25, 0.7, 0, 0, 0, LABEL[(k + i) % 3 + 1], D())
			end
		end
	end
end
for _ = 1, 24 do
	cyl(DEC, CFrame.new(rng:NextNumber(-70, 70), F1 + 0.6, rng:NextNumber(-20, 54)) * CFrame.Angles(0, rng:NextNumber(0, 6), math.pi / 2), "LooseTin", 1.2, 1.4, 0, 0, 0, TIN, D())
end
-- the sorting table and its fish tubs
box(STR, "SortTable", -12, F1, -14, 12, F1 + 3.4, -8, HARB.plankD)
for x = -9, 9, 6 do harbFishCrate(DEC, CFrame.new(x, F1 + 3.4, -11), rng) end
-- pipes along the walls
for _, z in { 56, -22 } do cyl(DEC, CFrame.new(0, F1 + 16, z) * CFrame.Angles(0, 0, -math.pi / 2), "Pipe", 1.4, 150, 0, 0, 0, HARB.rust, D()) end
for _, x in { -76, 76 } do cyl(DEC, CFrame.new(x, F1 + 14, 16), "PipeSide", 1.2, 72, 0, 0, 0, HARB.rust, D()).Orientation = Vector3.new(0, 90, 0) end
-- THE BOILER ROOM: two boilers, the furnace, coal
for _, x in { -40, 40 } do
	local bo = model(STR, "Boiler")
	cyl(bo, CFrame.new(x, F1 + 9, -44), "Boiler", 11, 18, 0, 0, 0, HARB.rust)
	for _, y in { 2, 9, 16 } do cyl(DEC, CFrame.new(x, F1 + y, -44), "Band", 11.4, 0.8, 0, 0, 0, HARB.iron, D()) end
	cyl(DEC, CFrame.new(x, F1 + 22, -44), "Stack", 2.4, 8, 0, 0, 0, HARB.iron, D())
	cyl(DEC, CFrame.new(x, F1 + 7, -38.4) * CFrame.Angles(math.pi / 2, 0, 0), "Gauge", 1.6, 0.3, 0, 0, 0, HARB.white, D())
end
local fur = model(STR, "Furnace")
box(fur, "Furnace", -8, F1, -58, 8, F1 + 10, -50, HARB.iron)
local mouth = box(DEC, "FurnaceMouth", -4, F1 + 1.5, -50.2, 4, F1 + 6, -49.9, st(M.Neon, nil, C3(255, 120, 40)), DECO)
light(mouth, 30, 2, C3(255, 130, 60))
for _, p in { { -20, -54 }, { 20, -54 } } do ball(DEC, CFrame.new(p[1], F1 + 0.8, p[2]), "Coal", 6, 0, 0, 0, st(M.Slate, nil, C3(26, 24, 24)), D()) end
-- steam from the boilers (small, slow)
for _, x in { -40, 40 } do
	local sp = b(DEC, CFrame.new(x, F1 + 12, -44), "Steam", 0.4, 0.4, 0.4, 0, 0, 0, HARB.white, { deco = true, t = 1 })
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/smoke_main.dds"; e.Color = ColorSequence.new(C3(200, 200, 200)); e.Size = NumberSequence.new(1.5, 4)
	e.Transparency = NumberSequence.new(0.75, 1); e.Lifetime = NumberRange.new(2, 3); e.Speed = NumberRange.new(1, 2); e.Rate = 3; e.Parent = sp
end

-- lights: cage lamps on the belts, the furnace glow
for _, p in { { -40, 30 }, { 0, 30 }, { -40, 2 }, { 0, 2 }, { 50, 40 }, { -60, 50 } } do bulb(p[1], F1 + H - 1, p[2], 5, C3(255, 226, 180)) end
for _, p in { { -40, -36 }, { 40, -36 } } do bulb(p[1], F1 + H - 1, p[2], 4, C3(255, 180, 120)) end
for _, p in { { -20, 16 }, { 30, 44 }, { 10, -40 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -50, 44 }, { 30, 44 }, { -20, 16 }, { 40, -12 }, { 0, -40 }, { -60, -40 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-50, -30, 50, -20, F1)
harbSign("THE CANNERY")
harbGrounds()
return endMap()
