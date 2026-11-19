-- THE CANNERY (Blackwater Harbor, building 2: THE SEWER RAT, grown fat in here - he charges in straight lines and
-- burrows under the floor). The front hall: two long CONVEYOR BELTS (low, on legs: you can jump them, he smashes
-- through what stands in his lane), towers of TINS, a sorting table. Behind a wall with three doorways: the BOILER
-- ROOM - two big boilers with pipes up into the roof, coal heaps, a furnace glowing orange, steam.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_cannery.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 24
local rng = Random.new(21)
beginMap("Harb_Cannery", harbTheme({ floor = st(M.Concrete, nil, C3(110, 108, 102)), inner = st(M.Brick, nil, C3(110, 66, 50)), wain = false,
	ext = st(M.Brick, nil, C3(96, 58, 46)) }))
-- (2026-11-19) its own shape: a brick factory under a SAWTOOTH roof, a tall smokestack beside it
local TOP = shell2({ H = H, roof = "none", front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	win = { w = 7, b = 7, t = 16 }, postStyle = st(M.Brick, nil, C3(80, 46, 36)) })
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
-- OUTSIDE (2026-11-19): THE BLACKWATER CANNING CO. A brick factory: a SAWTOOTH roof of five teeth with their glass
-- faces to the yard, the tall brick SMOKESTACK smoking over it, rusty pipes along the front, a loading door, a chute
-- spilling tins, the company's name painted across the brick, and rats - big ones - round a sewer grate.
local OUT = model(DEC, "Outside")
local ROOFC = st(M.CorrodedMetal, nil, C3(96, 84, 74))
local BRICK = T.ext
local GL = st(M.Neon, nil, C3(130, 120, 92))
for i = 0, 4 do
	local za, zb = -60 + i * 24, -60 + (i + 1) * 24
	local h = 12
	panel(STR, "Sawtooth", Vector3.new(0, TOP, za), Vector3.new(0, TOP + h, zb), Vector3.new(1, 0, 0), 162, ROOFC, 1.2)
	box(OUT, "SawGlass", -79, TOP, zb - 0.5, 79, TOP + h, zb + 0.1, GL, { deco = true, t = 0.55 })
	for x = -76, 76, 8 do box(OUT, "SawMullion", x - 0.3, TOP, zb - 0.2, x + 0.3, TOP + h, zb + 0.4, HARB.iron, DECO) end
	for _, x in { -80, 80 } do tri(STR, "Gable", Vector3.new(x, TOP, za), Vector3.new(x, TOP, zb), Vector3.new(x, TOP + h, zb), BRICK, 2) end
end
light(box(OUT, "SawGlow", -0.1, TOP + 6, 50, 0.1, TOP + 6.2, 50.2, GL, { deco = true, t = 1 }), 50, 1, C3(220, 200, 150))
-- THE SMOKESTACK (behind, east): brick, white bands, smoke
do
	local sx, sz = 62, -30
	prism(OUT, "Stack", sx, sz, 6, 0, 110, 12, st(M.Brick, nil, C3(110, 60, 46)), D())
	for _, y in { 70, 88, 104 } do prism(OUT, "StackBand", sx, sz, 6.3, y, y + 1.6, 12, HARB.white, D()) end
	prism(OUT, "StackLip", sx, sz, 6.8, 110, 112, 12, st(M.Brick, nil, C3(80, 44, 34)), D())
	local sm = box(OUT, "SmokeSource", sx - 1, 112, sz - 1, sx + 1, 113, sz + 1, HARB.black, { deco = true, t = 1 })
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(C3(60, 58, 56), C3(110, 108, 104))
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) })
	pe.Size = NumberSequence.new(6, 22); pe.Lifetime = NumberRange.new(8, 11); pe.Rate = 5
	pe.Speed = NumberRange.new(4, 6); pe.SpreadAngle = Vector2.new(10, 10); pe.Acceleration = Vector3.new(2, 0.5, 0)
	pe.Parent = sm
	light(box(OUT, "StackLamp", sx - 0.5, 111, sz + 6.4, sx + 0.5, 112, sz + 7.4, st(M.Neon, nil, C3(255, 60, 40)), DECO), 24, 1.4, C3(255, 60, 40))
end
-- the name painted across the brick, pipes along the front, the loading door, a chute of tins
sign(OUT, "BLACKWATER CANNING CO.", CFrame.new(0, 21.4, 60.25) * CFrame.Angles(0, math.pi, 0), 70, 4.4, BRICK, C3(226, 214, 186), Enum.Font.Creepster)
for _, y in { 4, 19 } do cyl(OUT, CFrame.new(0, y, 61.4) * CFrame.Angles(0, 0, -math.pi / 2), "Pipe", 1.4, 156, 0, 0, 0, HARB.rust, D()) end
for _, x in { -72, -48, 24, 72 } do cyl(OUT, CFrame.new(x, 11.5, 61.4), "PipeDown", 1.4, 15, 0, 0, 0, HARB.rust, D()) end
for _, x in { -48, 72 } do cyl(OUT, CFrame.new(x, 3, 62.6), "Valve", 2.4, 0.4, 0, 0, 0, HARB.red, D()) end
box(OUT, "LoadDoor", 42, 2, 60.1, 54, 14, 60.6, st(M.CorrodedMetal, nil, C3(110, 104, 92)), DECO)
for y = 3, 13, 1.2 do box(OUT, "DoorRib", 42, y, 60.6, 54, y + 0.3, 60.8, HARB.iron, DECO) end
box(OUT, "Dock", 38, 0, 60, 58, 2.4, 68, st(M.Concrete, nil, C3(100, 98, 92)), DECO)
part(OUT, "Chute", Vector3.new(4, 0.6, 16), CFrame.new(-28, 7, 66) * CFrame.Angles(-0.55, 0, 0), HARB.iron, D())
local trng = Random.new(5)
for k = 1, 18 do
	cyl(OUT, CFrame.new(-28 + trng:NextNumber(-4, 4), 0.6, 72 + trng:NextNumber(-3, 5)) * CFrame.Angles(trng:NextNumber(0, 3), trng:NextNumber(0, 3), 0), "Tin", 1.2, 1.4, 0, 0, 0, st(M.Metal, nil, C3(170, 172, 168)), D())
end
-- the sewer grate (a green glow under it) and the rats
box(OUT, "Grate", 22, 0.1, 76, 28, 0.3, 82, HARB.iron, DECO)
for x = 22.6, 27.4, 1.2 do box(OUT, "GrateBar", x - 0.15, 0.3, 76, x + 0.15, 0.45, 82, HARB.black, DECO) end
light(box(OUT, "SewerGlow", 24.9, -0.2, 78.9, 25.1, 0, 79.1, st(M.Neon, nil, C3(120, 255, 120)), { deco = true, t = 1 }), 14, 1.2, C3(120, 255, 120))
for _, r in { { 20, 74, 0.6 }, { 30, 84, -1.2 }, { 26, 73, 2.4 }, { -12, 64, 0.2 } } do
	local cf = CFrame.new(r[1], 0.6, r[2]) * CFrame.Angles(0, r[3], 0)
	local FUR = st(M.SmoothPlastic, nil, C3(70, 62, 56))
	b(OUT, cf, "Rat", 1.2, 1, 2.4, 0, 0, 0, FUR, D())
	b(OUT, cf, "RatHead", 0.8, 0.8, 1, 0, 0.1, -1.5, FUR, D())
	b(OUT, cf, "RatTail", 0.2, 0.2, 2.6, 0, -0.3, 2.4, st(M.SmoothPlastic, nil, C3(180, 130, 130)), D())
	b(OUT, cf, "RatEye", 0.9, 0.2, 0.2, 0, 0.35, -1.9, st(M.Neon, nil, C3(255, 40, 30)), D())
end
harbSign("THE CANNERY", CFrame.new(0, 26.4, 60.9))
washLight(-30, 86, Vector3.new(-30, TOP, 60), C3(220, 210, 180), 90, 2)
washLight(30, 86, Vector3.new(30, TOP, 60), C3(220, 210, 180), 90, 2)
harbGrounds()
return endMap()
