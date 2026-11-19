-- CAMP HOLLOWMERE's world (ServerStorage.Worlds.Camp): a summer camp by a black lake at night, deep in the pines.
--   EAST   the lake: a sandy shore with rocks and upturned canoes, the swimming dock, the raft, a line of buoys with
--          red lights, a lifeguard chair, mist on the water, dark mountains on the far side
--   WEST   the cabins among the pines (lit windows), lamp posts, a totem pole, the archery range, the water tower
--   NORTH  pines and a mountain ridge behind the building
--   SOUTH  across the railway: the dirt road, the yellow camp bus, the big CAMP HOLLOWMERE welcome sign
--   YARD   the camp's own corner: the entrance arch over the path, the campfire ring with log benches, the flagpole,
--          a picnic table, a split-rail fence round it (each building adds its own things near its door)
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--   tools/build/worlds/world_lib.luau tools/build/worlds/camp.luau
local C3 = Color3.fromRGB
local rng = Random.new(1962)
local W = beginWorld("Camp")
local LOG = st(M.WoodPlanks, "PS2_Siding1", C3(92, 66, 46))
local LOGD = st(M.Wood, "PS2_DarkBeam1", C3(62, 44, 32))
local PLANK = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(110, 84, 60))
local STONE = st(M.Cobblestone, "PS2_Stone1", C3(104, 100, 94))
local ROCK = st(M.Slate, nil, C3(70, 70, 72))
local SHINGLE = st(M.Slate, nil, C3(56, 50, 46))
local GRASS = st(M.Grass, nil, C3(36, 46, 32))
local DIRT = st(M.Ground, nil, C3(66, 54, 40))
local SAND = st(M.Sand, nil, C3(98, 90, 74))
local HILL = st(M.Slate, nil, C3(26, 34, 34))
local HILL2 = st(M.Slate, nil, C3(34, 42, 38))
local RED = st(M.SmoothPlastic, nil, C3(160, 40, 34))
local WHITE = st(M.SmoothPlastic, nil, C3(214, 206, 186))
local WARM = C3(255, 180, 110)

---------------------------------------------------------------- the ground
local gnd = model(W, "Ground")
box(gnd, "ForestFloor", -900, -0.9, -800, 900, 0.02, 900, GRASS, WD())
box(gnd, "Clearing", -95, 0.02, 52, 95, 0.06, 168, DIRT, WD())
for k = 1, 26 do -- trodden patches in the grass round the yard
	local x, z = rng:NextNumber(-240, 110), rng:NextNumber(-200, 400)
	if not inPlay(x, z, 0) then
		local p = box(gnd, "Patch", x - rng:NextNumber(4, 12), 0.03, z - rng:NextNumber(4, 12), x + rng:NextNumber(4, 12), 0.07, z + rng:NextNumber(4, 12), DIRT, WD())
		p.CFrame = p.CFrame * CFrame.Angles(0, rng:NextNumber(0, 3), 0)
	end
end

---------------------------------------------------------------- the lake (east)
local lake = model(W, "Lake")
local SHORE = 128
water(lake, SHORE + 6, -700, 1200, 800, 0.45, C3(16, 30, 40))
box(lake, "Beach", SHORE - 14, 0.04, -700, SHORE + 8, 0.3, 800, SAND, WD())
-- the shore line: rocks half in the water
for z = -600, 700, 9 do
	if rng:NextNumber() < 0.55 then
		local x = SHORE + 4 + rng:NextNumber(-4, 5)
		local s = rng:NextNumber(2, 6)
		local r = box(lake, "Rock", x - s, -0.5, z - s * 0.7, x + s, s * 0.6, z + s * 0.7, ROCK, WD())
		r.CFrame = r.CFrame * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 3), rng:NextNumber(-0.3, 0.3))
	end
end
-- reeds in clumps along the water
for k = 1, 40 do
	local z = rng:NextNumber(-500, 600)
	local x = SHORE + rng:NextNumber(6, 16)
	if math.abs(z - 40) > 20 then
		for i = 1, 5 do
			local h = rng:NextNumber(2.5, 5)
			local p = box(lake, "Reed", x + rng:NextNumber(-1.5, 1.5) - 0.1, 0, z + rng:NextNumber(-1.5, 1.5) - 0.1, 0, h, 0, st(M.Grass, nil, C3(56, 70, 40)), WD())
			p.Size = Vector3.new(0.2, h, 0.2)
			p.CFrame = CFrame.new(p.Position.X, h / 2, p.Position.Z) * CFrame.Angles(rng:NextNumber(-0.2, 0.2), 0, rng:NextNumber(-0.2, 0.2))
		end
	end
end
-- THE SWIMMING DOCK: a long jetty from the beach with a T at the end, a rowboat tied to it, a ladder
local dk = model(lake, "Dock")
local DY = 1.6
box(dk, "Deck", SHORE - 6, DY - 0.4, 34, SHORE + 70, DY, 44, PLANK, WD())
box(dk, "TDeck", SHORE + 62, DY - 0.4, 16, SHORE + 74, DY, 62, PLANK, WD())
for x = SHORE - 4, SHORE + 72, 8 do
	for _, z in { 34.5, 43.5 } do cyl(dk, CFrame.new(x, 0, z), "Piling", 1.1, 4.4, 0, 0, 0, LOGD, WD()) end
end
for _, z in { 17, 61 } do for _, x in { SHORE + 63, SHORE + 73 } do cyl(dk, CFrame.new(x, 0, z), "Piling", 1.1, 4.4, 0, 0, 0, LOGD, WD()) end end
for k = 0, 3 do box(dk, "LadderRung", SHORE + 73.5, DY - 1 - k * 0.8, 38, SHORE + 74.5, DY - 0.8 - k * 0.8, 40, LOGD, WD()) end
do -- the rowboat
	local cf = CFrame.new(SHORE + 50, 0.6, 50) * CFrame.Angles(0, 1.45, 0.05)
	local hull = st(M.WoodPlanks, "PS2_Siding1", C3(120, 50, 40))
	b(dk, cf, "Hull", 4.6, 1.4, 11, 0, 0.5, 0, hull, WD())
	b(dk, cf, "Inside", 3.8, 0.2, 10, 0, 1.15, 0, st(M.Wood, nil, C3(40, 30, 24)), WD())
	for _, z in { -2.5, 1.5 } do b(dk, cf, "Seat", 4, 0.3, 1, 0, 1.3, z, LOGD, WD()) end
	part(dk, "Rope", Vector3.new(0.15, 0.15, 7), CFrame.lookAt(Vector3.new(SHORE + 50, 1.6, 45), Vector3.new(SHORE + 47, DY, 43.5)), st(M.Fabric, nil, C3(170, 150, 110)), WD())
end
-- the raft out on the lake and the buoy line round the swimming area
local raft = model(lake, "Raft")
box(raft, "Deck", 230, 0.6, -26, 244, 1.6, -12, PLANK, WD())
for _, c in { { 231, -25 }, { 243, -25 }, { 231, -13 }, { 243, -13 } } do cyl(raft, CFrame.new(c[1], 0.4, c[2]), "Drum", 2.4, 2, 0, 0, 0, st(M.Metal, nil, C3(90, 90, 86)), WD()) end
box(raft, "Board", 236, 1.6, -26, 238, 2.0, -34, WHITE, WD())
local buoys = model(lake, "Buoys")
local function buoyRun(a: Vector3, z: Vector3)
	local n = math.floor((z - a).Magnitude / 6)
	for i = 0, n do
		local p = a:Lerp(z, i / n)
		ball(buoys, CFrame.new(p.X, 0.5, p.Z), "Float", 1.2, 0, 0, 0, i % 2 == 0 and RED or WHITE, WD())
	end
end
buoyRun(Vector3.new(SHORE + 10, 0, -60), Vector3.new(300, 0, -60))
buoyRun(Vector3.new(300, 0, -60), Vector3.new(300, 0, 110))
buoyRun(Vector3.new(300, 0, 110), Vector3.new(SHORE + 10, 0, 110))
for _, p in { { 300, -60 }, { 300, 110 }, { 220, -60 } } do
	local g = ball(buoys, CFrame.new(p[1], 1.6, p[2]), "BuoyLight", 0.8, 0, 0, 0, st(M.Neon, nil, C3(255, 60, 40)), WD())
	light(g, 14, 1, C3(255, 70, 50))
	cyl(buoys, CFrame.new(p[1], 0.6, p[2]), "BuoyBody", 2, 2, 0, 0, 0, RED, WD())
end
-- upturned canoes on the beach, a lifeguard chair, a canoe rack
for i, z in { -14, -6, 2 } do
	local cf = CFrame.new(SHORE - 7, 0.9, z) * CFrame.Angles(0, 0.1 * i, math.pi)
	b(lake, cf, "Canoe", 2.6, 1.0, 15, 0, 0, 0, st(M.SmoothPlastic, nil, i == 2 and C3(60, 110, 70) or C3(170, 60, 40)), WD())
end
do
	local lg = model(lake, "LifeguardChair")
	for _, c in { { -1.5, -1.5 }, { 1.5, -1.5 }, { -1.5, 1.5 }, { 1.5, 1.5 } } do
		part(lg, "Leg", Vector3.new(0.5, 9, 0.5), CFrame.new(SHORE - 4 + c[1], 4.4, 84 + c[2]) * CFrame.Angles(c[2] * 0.08, 0, -c[1] * 0.08), WHITE, WD())
	end
	box(lg, "Seat", SHORE - 6, 8.6, 82, SHORE - 2, 9, 86, WHITE, WD())
	box(lg, "Back", SHORE - 6, 9, 81.6, SHORE - 2, 12, 82, WHITE, WD())
	box(lg, "Cross", SHORE - 6.2, 10.8, 81.4, SHORE - 1.8, 11.6, 81.6, RED, WD())
	box(lg, "Cross", SHORE - 4.4, 9.4, 81.4, SHORE - 3.6, 13, 81.6, RED, WD())
end
-- the far shore: dark mountains, and mist low on the water
local mts = model(W, "Mountains")
for k = 1, 7 do
	local z = -650 + k * 190 + rng:NextNumber(-40, 40)
	mountain(mts, rng, rng:NextNumber(760, 1000), z, rng:NextNumber(170, 260), rng:NextNumber(130, 230), 9, k % 2 == 0 and HILL or HILL2)
end
for k = 1, 5 do -- the ridge behind the camp (north) and to the far south-west
	mountain(mts, rng, rng:NextNumber(-700, 400), rng:NextNumber(-900, -760), rng:NextNumber(200, 300), rng:NextNumber(150, 260), 9, k % 2 == 0 and HILL or HILL2)
end
for k = 1, 3 do mountain(mts, rng, rng:NextNumber(-900, -700), rng:NextNumber(-300, 600), rng:NextNumber(180, 260), rng:NextNumber(110, 180), 8, HILL2) end
local mist = model(lake, "Mist")
for k = 1, 6 do
	local m = box(mist, "MistBank", 0, 0, 0, 1, 1, 1, st(M.SmoothPlastic, nil, C3(150, 166, 180)), { deco = true, t = 1 })
	m.Size = Vector3.new(60, 2, 60)
	m.Position = Vector3.new(rng:NextNumber(200, 520), 2, rng:NextNumber(-300, 400))
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(C3(170, 186, 200))
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 0.86), NumberSequenceKeypoint.new(1, 1) })
	pe.Size = NumberSequence.new(18, 28)
	pe.Lifetime = NumberRange.new(10, 14)
	pe.Rate = 1.2
	pe.Speed = NumberRange.new(0.5, 1.5)
	pe.SpreadAngle = Vector2.new(180, 10)
	pe.LightEmission = 0
	pe.Parent = m
end
-- the moon's road on the water: a pale streak toward the far shore
for k = 0, 9 do
	local p = box(lake, "MoonStreak", 300 + k * 50, 0.47, -6 - k * 1.2, 330 + k * 50, 0.5, 6 + k * 1.2, st(M.Neon, nil, C3(120, 140, 170)), { deco = true, t = 0.82 })
	p.CastShadow = false
end

---------------------------------------------------------------- the camp to the west: cabins in the pines
local camp = model(W, "Cabins")
local cabinSpots = { { -150, 96, 0.3 }, { -178, 30, 0.05 }, { -160, -34, -0.2 }, { -214, 214, 0.5 }, { -146, 232, 0.9 }, { -250, 90, 0.1 }, { -230, -80, -0.3 } }
for i, c in cabinSpots do
	local cf = CFrame.new(c[1], 0, c[2]) * CFrame.Angles(0, -math.pi / 2 + c[3], 0) -- (the door faces the yard, +x)
	cabin(camp, cf, 16, 20, 9, LOG, SHINGLE, LOGD, i % 3 ~= 0)
	-- a number board over the door
	sign(camp, "CABIN " .. i, cf * CFrame.new(0, 10.2, -10.4), 5, 1.2, LOGD, C3(226, 214, 186), Enum.Font.SpecialElite)
end
-- the paths between them and their lamp posts
for i = 1, #cabinSpots - 1 do
	local a, z = cabinSpots[i], cabinSpots[i + 1]
	if math.abs(a[2] - z[2]) < 140 then
		local pa, pz = Vector3.new(a[1] + 12, 0.05, a[2]), Vector3.new(z[1] + 12, 0.05, z[2])
		part(camp, "Path", Vector3.new(5, 0.08, (pz - pa).Magnitude), CFrame.lookAt((pa + pz) / 2, pz), DIRT, WD())
	end
end
for _, p in { { -126, 64 }, { -134, 0 }, { -126, 190 }, { -200, 150 } } do lampPost(camp, p[1], p[2], WARM, 10, nil, 20) end
-- the totem pole
do
	local tp = model(camp, "TotemPole")
	local cols = { C3(150, 50, 36), C3(40, 90, 110), C3(200, 160, 60), C3(60, 100, 50) }
	for k = 0, 5 do
		cyl(tp, CFrame.new(-120, 2 + k * 3.4, 120), "Block", 3.4, 3.4, 0, 0, 0, st(M.Wood, nil, cols[k % 4 + 1]), WD())
		box(tp, "Eyes", -118.4, 2.6 + k * 3.4, 119, -118, 3.2 + k * 3.4, 121, st(M.SmoothPlastic, nil, C3(20, 20, 20)), WD())
	end
	box(tp, "Wings", -120.5, 19, 114, -119.5, 20.4, 126, st(M.Wood, nil, cols[3]), WD())
end
-- the archery range: four targets on stands, a bench, a quiver rack
do
	local ar = model(camp, "Archery")
	for k = 0, 3 do
		local z = -100 + k * 14
		local cf = CFrame.new(-150, 0, z) * CFrame.Angles(0, -math.pi / 2, 0)
		for _, x in { -1.6, 1.6 } do b(ar, cf, "Leg", 0.4, 6, 0.4, x, 3, 0.8, LOGD, WD()) end
		local rings = { { 5, C3(220, 214, 196) }, { 3.8, C3(30, 30, 30) }, { 2.6, C3(50, 90, 170) }, { 1.6, C3(180, 40, 30) }, { 0.7, C3(230, 190, 50) } }
		for i, r in rings do cyl(ar, cf * CFrame.new(0, 5, -i * 0.06) * CFrame.Angles(math.pi / 2, 0, 0), "Ring", r[1], 0.3, 0, 0, 0, st(M.SmoothPlastic, nil, r[2]), WD()) end
	end
	box(ar, "Bench", -112, 1.6, -96, -110, 2, -60, PLANK, WD())
	box(ar, "Line", -114, 0.07, -104, -113, 0.1, -50, WHITE, WD())
end
-- THE WATER TOWER (seen over the building's roof): four legs, cross braces, the tank, a ladder, the camp's name
do
	local wt = model(W, "WaterTower")
	local cx, cz, legH = -140, -150, 46
	for _, c in { { -9, -9 }, { 9, -9 }, { -9, 9 }, { 9, 9 } } do
		part(wt, "Leg", Vector3.new(1.4, legH + 2, 1.4), CFrame.new(cx + c[1] * 0.85, legH / 2, cz + c[2] * 0.85) * CFrame.Angles(c[2] * 0.035, 0, -c[1] * 0.035), LOGD, WD())
	end
	for k = 1, 3 do
		local y = k * legH / 4
		for _, s in { -1, 1 } do
			part(wt, "Brace", Vector3.new(0.6, 0.6, 26), CFrame.new(cx + s * 8.2, y, cz) * CFrame.Angles((k % 2 == 0) and 0.5 or -0.5, 0, 0), LOGD, WD())
			part(wt, "Brace", Vector3.new(26, 0.6, 0.6), CFrame.new(cx, y, cz + s * 8.2) * CFrame.Angles(0, 0, (k % 2 == 0) and 0.5 or -0.5), LOGD, WD())
		end
	end
	box(wt, "Platform", cx - 12, legH, cz - 12, cx + 12, legH + 1, cz + 12, PLANK, WD())
	prism(wt, "Tank", cx, cz, 10, legH + 1, legH + 17, 12, st(M.WoodPlanks, "PS2_Siding1", C3(110, 82, 56)), WD())
	for _, y in { legH + 4, legH + 9, legH + 14 } do prism(wt, "Hoop", cx, cz, 10.4, y, y + 0.6, 12, st(M.Metal, nil, C3(40, 40, 40)), WD()) end
	local apex = Vector3.new(cx, legH + 25, cz)
	local base = {}
	for k = 0, 11 do local a = k * math.pi / 6; table.insert(base, { cx + 11.5 * math.cos(a), cz + 11.5 * math.sin(a) }) end
	coneRoof(wt, base, legH + 17, apex, SHINGLE, 0, 0.8)
	for k = 0, 18 do box(wt, "Rung", cx + 10.6, 2 + k * 2.4, cz - 1, cx + 11, 2.3 + k * 2.4, cz + 1, LOGD, WD()) end
	local s1 = sign(wt, "HOLLOWMERE", CFrame.new(cx + 6, legH + 9, cz + 8.3) * CFrame.Angles(0, math.pi * 0.2, 0), 12, 3, st(M.WoodPlanks, nil, C3(110, 82, 56)), C3(230, 214, 180), Enum.Font.SpecialElite)
	s1.Name = "TowerName"
	local g = ball(wt, CFrame.new(cx, legH + 26, cz), "Beacon", 1.2, 0, 0, 0, st(M.Neon, nil, C3(255, 60, 50)), WD())
	light(g, 20, 1, C3(255, 60, 50))
end

---------------------------------------------------------------- south, across the railway: the road, the bus, the sign
local south = model(W, "Road")
box(south, "Road", -900, 0.04, 196, 900, 0.1, 214, DIRT, WD())
for x = -880, 880, 24 do box(south, "Rut", x, 0.1, 200, x + 14, 0.12, 201, st(M.Ground, nil, C3(52, 42, 32)), WD()) end
do -- the camp bus, parked (yellow, rusty, one window lit)
	local bus = model(south, "CampBus")
	local cf = CFrame.new(54, 0, 222) * CFrame.Angles(0, math.pi / 2 + 0.06, 0)
	local Y = st(M.SmoothPlastic, nil, C3(196, 150, 40))
	b(bus, cf, "Body", 9, 8, 34, 0, 6, 0, Y, WD())
	b(bus, cf, "Roof", 8.6, 0.8, 33.6, 0, 10.3, 0, st(M.SmoothPlastic, nil, C3(210, 200, 180)), WD())
	b(bus, cf, "Hood", 8, 4.4, 6, 0, 4.2, -19.5, Y, WD())
	b(bus, cf, "Grille", 6, 2.4, 0.3, 0, 4.4, -22.6, st(M.Metal, nil, C3(60, 60, 60)), WD())
	b(bus, cf, "Stripe", 9.1, 0.6, 34, 0, 6.4, 0, st(M.SmoothPlastic, nil, C3(20, 20, 20)), WD())
	for k = 0, 6 do
		local z = -13 + k * 4.2
		for _, x in { -4.55, 4.55 } do b(bus, cf, "Window", 0.2, 2.6, 3.2, x, 8.2, z, (k == 4 and x > 0) and st(M.Neon, nil, C3(255, 190, 120)) or st(M.Glass, nil, C3(30, 36, 44)), WD()) end
	end
	b(bus, cf, "Windshield", 8, 3, 0.3, 0, 8.4, -17.1, st(M.Glass, nil, C3(30, 36, 44)), WD())
	for _, z in { -14, 10 } do
		for _, x in { -4.4, 4.4 } do cyl(bus, cf * CFrame.new(x, 1.8, z) * CFrame.Angles(0, 0, -math.pi / 2), "Wheel", 3.6, 1.4, 0, 0, 0, st(M.SmoothPlastic, nil, C3(20, 20, 20)), WD()) end
	end
	sign(bus, "CAMP HOLLOWMERE", cf * CFrame.new(4.62, 7, 0) * CFrame.Angles(0, -math.pi / 2, 0), 18, 1.8, Y, C3(20, 20, 20), Enum.Font.SpecialElite)
end
do -- THE WELCOME SIGN facing the yard: two log posts, a carved board, a little roof, lanterns
	local ws = model(south, "WelcomeSign")
	local cx, cz = -40, 190
	for _, x in { -14, 14 } do cyl(ws, CFrame.new(cx + x, 8, cz), "Post", 1.8, 16, 0, 0, 0, LOGD, WD()) end
	box(ws, "Board", cx - 15, 7, cz - 0.6, cx + 15, 14, cz + 0.6, LOG, WD())
	sign(ws, "CAMP HOLLOWMERE", CFrame.new(cx, 11.6, cz - 0.7), 27, 3.4, LOG, C3(236, 220, 180), Enum.Font.SpecialElite)
	sign(ws, "EST. 1962  -  LAKESIDE SUMMER CAMP", CFrame.new(cx, 8.4, cz - 0.7), 26, 1.6, LOG, C3(200, 180, 140), Enum.Font.SpecialElite)
	extrude(ws, cx - 16, cx + 16, { { cz - 3, 14.5 }, { cz, 16.6 }, { cz + 3, 14.5 } }, SHINGLE, { ends = false, th = 0.6, over = 0, panelO = WD() })
	for _, x in { -16, 16 } do
		local g = box(ws, "Lantern", cx + x - 0.6, 12, cz - 1.8, cx + x + 0.6, 13.4, cz - 0.6, st(M.Neon, nil, WARM), WD())
		light(g, 18, 1, WARM)
	end
end

---------------------------------------------------------------- the yard's shared corner
local yd = model(W, "CampYard")
-- the path from the yard's railway stop to the buildings
box(yd, "Path", -5, 0.06, 112, 5, 0.14, 146, DIRT, WD())
-- the entrance arch over the path
for _, x in { -7.5, 7.5 } do cyl(yd, CFrame.new(x, 7, 132), "ArchPost", 1.6, 14, 0, 0, 0, LOGD, WD()) end
box(yd, "ArchBeam", -9.5, 13.4, 131.3, 9.5, 14.6, 132.7, LOGD, WD())
sign(yd, "CAMP HOLLOWMERE", CFrame.new(0, 12, 131.2) * CFrame.Angles(0, math.pi, 0), 14, 2.4, LOG, C3(232, 214, 170), Enum.Font.SpecialElite).Name = "CampSign"
sign(yd, "CAMP HOLLOWMERE", CFrame.new(0, 12, 132.8), 14, 2.4, LOG, C3(232, 214, 170), Enum.Font.SpecialElite).Name = "CampSignBack"
for _, x in { -9.5, 9.5 } do
	ball(yd, CFrame.new(x, 15.4, 132), "Antler", 1.4, 0, 0, 0, st(M.SmoothPlastic, nil, C3(200, 190, 160)), WD())
end
-- the campfire ring with log benches (west of the path)
do
	local fire = model(yd, "Campfire")
	local fc = CFrame.new(-56, 0, 112)
	for k = 0, 9 do b(fire, fc * CFrame.Angles(0, k / 10 * math.pi * 2, 0), "RingStone", 1.6, 0.9, 1.2, 0, 0.45, -3.2, STONE, WD()) end
	for k = 0, 3 do b(fire, fc * CFrame.Angles(0, k * 0.8, 0.2), "FireLog", 0.7, 0.7, 3.4, 0, 0.5, 0, LOGD, WD()) end
	local ember = b(fire, fc, "Embers", 2.2, 0.4, 2.2, 0, 0.5, 0, st(M.Neon, nil, C3(255, 120, 40)), WD())
	light(ember, 26, 1.4, C3(255, 140, 60))
	local fx = Instance.new("Fire"); fx.Size = 5; fx.Heat = 6; fx.Color = C3(255, 140, 60); fx.SecondaryColor = C3(200, 60, 20); fx.Parent = ember
	for k = 0, 2 do
		local bc = fc * CFrame.Angles(0, k / 3 * math.pi * 2 + 0.4, 0) * CFrame.new(0, 0, -8)
		cyl(fire, bc * CFrame.Angles(0, 0, -math.pi / 2), "LogBench", 1.6, 6, -0.8, 0, 0, LOG, WD())
	end
end
-- the flagpole and its torn flag (east of the path)
do
	local fl = model(yd, "Flagpole")
	cyl(fl, CFrame.new(60, 13, 100), "Pole", 0.6, 26, 0, 0, 0, st(M.Metal, nil, C3(150, 150, 146)), WD())
	box(fl, "Flag", 60.3, 21.5, 99.9, 66.5, 25.2, 100.1, st(M.Fabric, nil, C3(60, 90, 56)), WD())
	box(fl, "FlagTear", 64.5, 21.5, 99.85, 66.6, 22.8, 100.15, st(M.Fabric, nil, C3(20, 18, 16)), WD())
	box(fl, "FlagStripe", 60.3, 23.1, 99.85, 66.5, 23.6, 100.15, WHITE, WD())
	box(fl, "Base", 58.8, 0, 98.8, 61.2, 0.8, 101.2, STONE, WD())
end
-- a picnic table, a trash barrel, a wood pile
do
	local pt = model(yd, "PicnicTable")
	box(pt, "Top", 62, 3, 124, 68, 3.4, 128, PLANK, WD())
	for _, z in { 123, 129 } do box(pt, "Seat", 62, 1.7, z - 0.6, 68, 2, z + 0.6, PLANK, WD()) end
	for _, x in { 62.5, 67.5 } do box(pt, "Leg", x - 0.25, 0, 124.5, x + 0.25, 3, 127.5, LOGD, WD()) end
	cyl(yd, CFrame.new(-70, 2, 138), "TrashBarrel", 3, 4, 0, 0, 0, st(M.Metal, nil, C3(60, 70, 60)), WD())
	for k = 0, 5 do cyl(yd, CFrame.new(-76, 0.8 + (k % 3) * 1.5, 84 + math.floor(k / 3) * 1.6) * CFrame.Angles(math.pi / 2, 0, 0), "Firewood", 1.4, 6, 0, 0, 0, LOGD, WD()) end
end
-- the split-rail fence round the yard
local fence = model(W, "Fence")
yardEdge(fence, function(parent, x1, z1, x2, z2, gap) fenceRun(parent, x1, z1, x2, z2, LOGD, LOG, 4, 7, gap) end)

---------------------------------------------------------------- the pines
local trees = model(W, "Forest")
local PINES = { { "PineTree", 1.5, 2.5 }, { "PineTree", 1.8, 2.8 }, { "ForestTree1", 1.2, 1.8 } }
local function nearCabin(x, z)
	for _, c in cabinSpots do if math.abs(x - c[1]) < 22 and math.abs(z - c[2]) < 22 then return true end end
	if x > -170 and x < -110 and z > -110 and z < -40 then return true end -- archery
	if math.abs(x + 140) < 16 and math.abs(z + 150) < 16 then return true end -- water tower
	return false
end
local n = 0
n += forest(trees, rng, 260, -760, -650, -104, 760, PINES, nearCabin)
n += forest(trees, rng, 70, -104, -620, SHORE - 18, -80, PINES, nil)
n += forest(trees, rng, 60, -104, 220, SHORE - 18, 700, PINES, function(x, z) return (z > 190 and z < 236) or (math.abs(x - 54) < 30 and z < 250) end)
n += forest(trees, rng, 14, 100, -80, SHORE - 18, 190, PINES, nil)
-- a few dead ones at the yard's edges
return endWorld() .. " (trees " .. n .. ")"
