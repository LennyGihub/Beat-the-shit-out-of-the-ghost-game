-- THE BOATHOUSE (Camp Hollowmere, building 2: THE LAKE WITCH, whose hook drags you toward the water and who floods
-- the floor). The lake comes right inside: a wide boat door in the back wall opens onto it and a SLIP of black water
-- runs down the middle of the boat hall (two rowboats in it), docks either side with canoe racks, oars and life
-- rings. At the front: the workshop, the entry hall and the lifeguard's office. One storey, 24 high.
-- Folder WaterSpots: points in the slip and at the boat door (the Lake Witch drags her victims toward the nearest).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_boathouse.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local WATER = st(M.Glass, nil, C3(30, 62, 66))
local DARKW = st(M.SmoothPlastic, nil, C3(8, 16, 18))
local REDP = st(M.SmoothPlastic, nil, C3(170, 40, 34))
local WHITEP = st(M.SmoothPlastic, nil, C3(220, 214, 200))
local SIDING = st(M.WoodPlanks, "PS2_Siding1", C3(74, 86, 92))
local TRIMW = st(M.Wood, nil, C3(196, 196, 186))
beginMap("Camp_Boathouse", campTheme({ ext = SIDING, inner = st(M.WoodPlanks, "PS2_Siding1", C3(116, 104, 88)), lanternColor = C3(220, 236, 240),
	trim = TRIMW, found = st(M.WoodPlanks, nil, C3(40, 34, 28)), roof = st(M.Slate, nil, C3(52, 62, 60)) }))
-- (2026-11-19) its own shape: a lake boathouse, the gable to the yard, the back over the water with the boat door
local TOP = shell2({ H = 24, ridge = "z", roof = "gable", rise = 30, over = 3, steps = false,
	front1 = { -60, -36, 36, 60 }, left1 = { 44, 8, -30 }, right1 = { 44, 8, -30 }, backOps = { dr(0, 36, 18) }, win = { w = 6, b = 5, t = 13 } })
local ext = STR:FindFirstChild("Exterior")
local inn = model(STR, "Interior")
local I = INT()
-- the front rooms (z 18..58)
wall(inn, "HallWall", "x", 18, -78, 78, F1, 24, { dr(-54, 8, 12), dr(0, 18, 16), dr(54, 8, 12) }, I)
wall(inn, "RoomW", "z", -30, 18.6, 58, F1, 24, { dr(38, 7, 11) }, I)
wall(inn, "RoomE", "z", 30, 18.6, 58, F1, 24, { dr(38, 7, 11) }, I)

-- THE SLIP: black water from the boat door to the middle of the hall, low curbs either side
local slip = model(DEC, "Slip")
box(slip, "SlipBed", -16, F1 + 0.04, -58.5, 16, F1 + 0.08, 10, DARKW, D())
box(slip, "Water", -16, F1 + 0.08, -58.5, 16, F1 + 0.5, 10, WATER, { deco = true, t = 0.3 })
for _, x in { -16.6, 16.6 } do box(STR, "Curb", x - 0.6, F1, -58, x + 0.6, F1 + 0.7, 10.6, CAMP.logD) end
box(STR, "CurbEnd", -17.2, F1, 10, 17.2, F1 + 0.7, 11.2, CAMP.logD)
for z = -52, 4, 8 do
	for _, x in { -17, 17 } do cyl(slip, CFrame.new(x, F1 + 1.5, z), "Piling", 1.2, 3, 0, 0, 0, CAMP.logD, D()) end
end
local glowL = box(slip, "UnderGlow", -1, F1 + 0.1, -30, 1, F1 + 0.2, -28, WATER, { deco = true, t = 1 })
light(glowL, 40, 0.8, C3(80, 170, 170))
-- THE LAKE all round the back half and the sides (it joins the camp's lake to the east), the shore at z ~ 50
local lk = box(DEC, "Lake", -420, 0.8, -700, 420, 1.15, 50, st(M.SmoothPlastic, nil, C3(16, 30, 40)), DECO)
lk.CastShadow = false
-- and a log boom across the door
local boom = model(STR, "Boom")
for _, x in { -17, 0, 17 } do box(boom, "BoomPost", x - 0.5, F1, -59.4, x + 0.5, F1 + 4.4, -58.4, CAMP.logD) end
for _, y in { 1.4, 3.8 } do box(boom, "BoomLog", -18, F1 + y - 0.4, -59.3, 18, F1 + y + 0.4, -58.5, CAMP.logD) end

-- two rowboats in the slip
local function rowboat(cf: CFrame, color)
	local bt = model(DEC, "Rowboat")
	local hull = st(M.WoodPlanks, "PS2_Siding1", color)
	b(bt, cf, "Hull", 4.6, 1.4, 10, 0, 0.9, 0, hull, D())
	b(bt, cf, "Keel", 2.6, 0.6, 9, 0, 0.1, 0, hull, D())
	part(bt, "Bow", Vector3.new(4.6, 1.4, 3), cf * CFrame.new(0, 0.9, -6.4) * CFrame.Angles(0, 0, 0), hull, { deco = true })
	b(bt, cf, "Inside", 3.8, 0.2, 9, 0, 1.55, 0, st(M.Wood, nil, C3(40, 30, 24)), D())
	for _, z in { -2.5, 1.5 } do b(bt, cf, "Seat", 4, 0.3, 1, 0, 1.7, z, CAMP.logD, D()) end
	b(bt, cf, "Oar", 0.25, 0.25, 8, 2.2, 1.9, 0, CAMP.logD, D())
end
rowboat(CFrame.new(-7, F1 - 0.4, -38) * CFrame.Angles(0, 0.06, 0.04), C3(120, 50, 40))
rowboat(CFrame.new(7, F1 - 0.5, -14) * CFrame.Angles(0, -0.1, -0.05), C3(60, 90, 110))
-- the docks: canoe racks along both long walls, life rings, oars, rope
local function canoeRack(x: number, z: number, face: string)
	local cf = at(x, F1, z, face)
	local rk = model(DEC, "CanoeRack")
	for _, dz in { -6, 6 } do
		b(rk, cf, "Upright", 0.5, 9, 0.5, 0, 4.5, dz, CAMP.logD, D())
		for _, y in { 2.5, 5.5, 8.5 } do b(rk, cf, "Arm", 3.2, 0.4, 0.4, 0, y, dz, CAMP.logD, D()) end
	end
	for i, y in { 3.1, 6.1 } do
		local col = i == 1 and C3(170, 60, 40) or C3(60, 110, 70)
		b(rk, cf, "Canoe", 2.6, 1.0, 15, 0, y, 0, st(M.SmoothPlastic, nil, col), D())
		b(rk, cf, "CanoeRim", 2.8, 0.2, 15.2, 0, y + 0.5, 0, st(M.Wood, nil, C3(90, 66, 44)), D())
	end
end
canoeRack(-75, -40, "E"); canoeRack(-75, -10, "E"); canoeRack(75, -40, "W"); canoeRack(75, -10, "W")
local function lifeRing(x: number, y: number, z: number, face: string)
	local cf = at(x, y, z, face)
	local lr = model(DEC, "LifeRing")
	for k = 0, 7 do
		local a = k / 8 * math.pi * 2
		b(lr, cf * CFrame.Angles(0, 0, a), "RingPiece", 0.9, 1.3, 0.6, 0, 1.6, 0, k % 2 == 0 and REDP or WHITEP, D())
	end
end
lifeRing(-78.5 + 0.8, 11, -25, "E"); lifeRing(78.5 - 0.8, 11, -25, "W"); lifeRing(-40, 11, 17.2, "S"); lifeRing(40, 11, 17.2, "S")
for _, p in { { -46, -52 }, { 46, -50 }, { -50, 6 }, { 52, 4 } } do F.barrel(at(p[1], F1, p[2], "N")) end
for _, p in { { -40, -24 }, { 40, -30 }, { -56, -6 } } do F.crate(at(p[1], F1, p[2], "N"), 3.5) end
G2.workbench(at(-48, F1, 14.5, "N"), 8)
G2.workbench(at(48, F1, 14.5, "N"), 8)
-- the workshop (west front room): a rowboat on sawhorses, tools, paint
local saw = model(DEC, "Sawhorses")
for _, z in { 28, 44 } do
	box(saw, "Horse", -62, F1, z - 0.4, -50, F1 + 3, z + 0.4, CAMP.logD, D())
end
rowboat(CFrame.new(-56, F1 + 3, 36) * CFrame.Angles(math.pi, 0, 0) * CFrame.new(0, -1.8, 0), C3(110, 96, 70))
G2.workbench(at(-70, F1, 54, "S"), 10)
F.cabinet(at(-36, F1, 55, "S"), 6, 9)
for _, p in { { -40, 26 }, { -72, 24 } } do F.barrel(at(p[1], F1, p[2], "N")) end
-- the entry hall (middle front): benches, a canoe on the wall, a notice board
F.bench(at(-18, F1, 40, "E"), 8)
F.bench(at(18, F1, 40, "W"), 8)
poster(0, 11, 58.6, "N", 10, 6, C3(140, 120, 80), CAMP.logD)
-- the lifeguard's office (east front room): desk, chair, a cot, a radio, a whistle board
F.desk(at(44, F1, 55, "S"))
F.chair(at(44, F1, 50, "N"), Wd.mid, Fab.red)
F.bed(at(72, F1, 30, "W"), 5, 8, Fab.blue)
F.cabinet(at(74, F1, 52, "W"), 6, 9)
F.floorLamp(at(34, F1, 24, "N"))
box(DEC, "Radio", 42, F1 + 3.8, 54.2, 45, F1 + 5.2, 55.6, st(M.Metal, nil, C3(60, 64, 58)), D())
-- lights: bulbs over the hall (cold), the rooms (warm)
for _, p in { { -40, -36 }, { 40, -36 }, { -40, -4 }, { 40, -4 }, { 0, -20 } } do bulb(p[1], 21, p[2], 3, C3(220, 236, 240)) end
for _, x in { -54, 0, 54 } do bulb(x, 21, 38, 3, C3(255, 200, 140)) end
for _, p in { { -30, -44 }, { 34, -12 }, { 0, 30 } } do blood(p[1], F1, p[2], 2) end
-- where the water is (the Lake Witch drags people toward these)
local ws = Instance.new("Folder"); ws.Name = "WaterSpots"; ws.Parent = MAP
for _, p in { { 0, -50 }, { 0, -30 }, { 0, -10 }, { 0, 6 } } do
	local m = Instance.new("Part"); m.Name = "Water"; m.Anchored = true; m.CanCollide = false; m.CanQuery = false; m.CanTouch = false
	m.Transparency = 1; m.Size = Vector3.one; m.Position = Vector3.new(p[1], F1 + 0.5, p[2]); m.Parent = ws
end
for _, p in { { -44, -40 }, { 44, -20 }, { 0, 36 }, { -54, 36 }, { 54, 36 }, { -40, 4 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-17, -58, 17, 11, F1) -- (the slip: nothing dropped in the water)
-- OUTSIDE (2026-11-19): the Lake Witch's boathouse. Board and batten, white trim, the name across the gable with
-- crossed oars, life rings by the door, a cupola with a fish on the vane, pilings and piers in the black water.
local OUT = model(DEC, "Outside")
for x = -76, 76, 4 do box(OUT, "Batten", x - 0.25, 2, 60, x + 0.25, TOP, 60.5, SIDING, DECO) end
for z = -56, 56, 4 do for _, sx in { -1, 1 } do box(OUT, "Batten", sx * 80 - 0.25 + sx * 0.25, 2, z - 0.25, sx * 80 + 0.25 + sx * 0.25, TOP, z + 0.25, SIDING, DECO) end end
-- barge boards and the name across the gable, crossed oars under it
for _, sx in { -1, 1 } do
	local a, z = Vector3.new(sx * 83, TOP - 1.6, 61), Vector3.new(0, TOP + 30, 61)
	part(OUT, "BargeBoard", Vector3.new(0.6, 1.8, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), TRIMW, D())
end
campNameBoard("BOATHOUSE", CFrame.new(0, TOP + 9, 60.6), 30, 4.4)
for _, sx in { -1, 1 } do
	part(OUT, "Oar", Vector3.new(0.5, 16, 0.4), CFrame.new(0, TOP + 2, 60.9) * CFrame.Angles(0, 0, sx * 0.9), CAMP.logD, D())
	part(OUT, "OarBlade", Vector3.new(1.8, 4, 0.3), CFrame.new(0, TOP + 2, 61) * CFrame.Angles(0, 0, sx * 0.9) * CFrame.new(0, 7, 0), REDP, D())
end
local function ringOn(x: number, y: number)
	local lr = model(OUT, "LifeRing")
	for k = 0, 7 do
		b(lr, CFrame.new(x, y, 60.7) * CFrame.Angles(0, 0, k / 8 * math.pi * 2), "RingPiece", 0.9, 1.3, 0.6, 0, 1.6, 0, k % 2 == 0 and REDP or WHITEP, D())
	end
end
for _, x in { -18, 18, -48, 48 } do ringOn(x, 12) end
-- the cupola on the ridge with its fish weathervane
do
	local cz, ry = 26, TOP + 30 * (1 - 0) -- (the ridge is at x 0)
	local cu = model(OUT, "Cupola")
	box(cu, "Base", -5, ry - 4, cz - 5, 5, ry + 4, cz + 5, SIDING, DECO)
	for _, f in { { 0, 5.1 }, { 0, -5.1 } } do
		for k = -1, 1 do box(cu, "Louvre", -3.4, ry + 0.5 + k * 1.4, cz + f[2] - 0.3, 3.4, ry + 1.1 + k * 1.4, cz + f[2] + 0.3, TRIMW, DECO) end
	end
	local apex = Vector3.new(0, ry + 10, cz)
	local cs = { Vector3.new(-6, ry + 4, cz - 6), Vector3.new(6, ry + 4, cz - 6), Vector3.new(6, ry + 4, cz + 6), Vector3.new(-6, ry + 4, cz + 6) }
	for k = 1, 4 do tri(cu, "CupolaRoof", cs[k], cs[k % 4 + 1], apex, T.roof, 0.6, D()) end
	box(cu, "VaneRod", -0.15, ry + 10, cz - 0.15, 0.15, ry + 16, cz + 0.15, CAMP.iron, DECO)
	local fish = st(M.Metal, nil, C3(60, 70, 66))
	b(cu, CFrame.new(0, ry + 15, cz), "VaneFish", 0.3, 1.6, 5, 0, 0, 0, fish, D())
	part(cu, "VaneTail", Vector3.new(0.3, 2.4, 1.6), CFrame.new(0, ry + 15, cz + 3) * CFrame.Angles(0.6, 0, 0), fish, D())
	local g = box(cu, "CupolaLamp", -1, ry - 1, cz - 1, 1, ry + 1, cz + 1, st(M.Neon, nil, C3(200, 230, 240)), DECO)
	light(g, 30, 1, C3(190, 225, 240))
end
-- pilings along the sides where the water is, and a pier off each side with boats tied to it
for z = -56, 46, 8 do
	for _, sx in { -1, 1 } do cyl(OUT, CFrame.new(sx * 82.2, 0.6, z), "Piling", 1.6, 4.4, 0, 0, 0, CAMP.logD, D()) end
end
for _, sx in { -1, 1 } do
	box(OUT, "PierDeck", sx * 81, 1.9, -24, sx * 140, 2.4, -14, CAMP.plank, DECO)
	for x = 86, 138, 9 do for _, z in { -23.5, -14.5 } do cyl(OUT, CFrame.new(sx * x, 0.4, z), "PierPost", 1, 4, 0, 0, 0, CAMP.logD, D()) end end
	for i, x in { 100, 124 } do
		local cf = CFrame.new(sx * x, 1.1, -32 + i * 2) * CFrame.Angles(0, math.pi / 2 + sx * 0.12 * i, 0.04)
		local hull = st(M.WoodPlanks, "PS2_Siding1", i == 1 and C3(120, 50, 40) or C3(60, 90, 110))
		b(OUT, cf, "Hull", 4.6, 1.4, 11, 0, 0.5, 0, hull, D())
		b(OUT, cf, "Inside", 3.8, 0.2, 10, 0, 1.15, 0, st(M.Wood, nil, C3(40, 30, 24)), D())
	end
end
-- the shore across the front corners, a little reed and rock
for _, sx in { -1, 1 } do
	for k = 0, 5 do
		local x = sx * (84 + k * 2.4)
		box(OUT, "ShoreRock", x - 1.5, -0.2, 49 - (k % 2), x + 1.5, 1.5 + (k % 3) * 0.4, 52 - (k % 2), st(M.Slate, nil, C3(70, 70, 72)), DECO)
	end
end
-- the way in: a plank boardwalk with rope rails, lanterns at the door, moonlight on the gable
box(STR, "Boardwalk", -6, 0, 60, 6, 2.05, 68, CAMP.plank)
box(STR, "BoardStep", -6, 0, 68, 6, 1.35, 70.5, CAMP.plank)
box(STR, "BoardStep", -6, 0, 70.5, 6, 0.7, 73, CAMP.plank)
box(OUT, "Walk", -5, 0.08, 73, 5, 0.3, 112, CAMP.plank, DECO)
for z = 76, 110, 6 do for _, x in { -5.5, 5.5 } do box(OUT, "RopePost", x - 0.3, 0, z - 0.3, x + 0.3, 3.4, z + 0.3, CAMP.logD, DECO) end end
for _, x in { -5.5, 5.5 } do box(OUT, "Rope", x - 0.1, 2.9, 76, x + 0.1, 3.1, 110, st(M.Fabric, nil, C3(170, 150, 110)), DECO) end
for _, x in { -8, 8 } do campLantern(OUT, x, 11, 60.2, C3(220, 236, 240)) end
washLight(-30, 84, Vector3.new(-6, TOP + 14, 60), C3(170, 196, 220), 90, 2.2)
washLight(30, 84, Vector3.new(6, TOP + 14, 60), C3(170, 196, 220), 90, 2.2)
-- THE BOATHOUSE'S YARD: a rowboat on a trailer, a kayak, fishing rods, a bait cooler, a warning sign
local YD = model(DEC, "BoatYard")
do
	local cf = CFrame.new(-30, 0, 88) * CFrame.Angles(0, 0.3, 0)
	b(YD, cf, "TrailerBar", 0.5, 0.5, 14, -1.6, 1.6, 0, CAMP.iron, D()); b(YD, cf, "TrailerBar", 0.5, 0.5, 14, 1.6, 1.6, 0, CAMP.iron, D())
	b(YD, cf, "Tongue", 0.5, 0.5, 6, 0, 1.6, -9, CAMP.iron, D())
	for _, x in { -2.2, 2.2 } do cyl(YD, cf * CFrame.new(x, 1, 2) * CFrame.Angles(0, 0, -math.pi / 2), "Wheel", 2, 0.8, 0, 0, 0, st(M.SmoothPlastic, nil, C3(20, 20, 20)), D()) end
	b(YD, cf, "Hull", 4.6, 1.4, 11, 0, 2.6, 0, st(M.WoodPlanks, "PS2_Siding1", C3(160, 150, 120)), D())
	b(YD, cf, "Inside", 3.8, 0.2, 10, 0, 3.25, 0, st(M.Wood, nil, C3(40, 30, 24)), D())
end
part(YD, "Kayak", Vector3.new(2, 1, 13), CFrame.new(26, 0.6, 80) * CFrame.Angles(0, -0.4, 0), st(M.SmoothPlastic, nil, C3(220, 180, 40)), D())
for k = 0, 2 do part(YD, "Rod", Vector3.new(0.2, 11, 0.2), CFrame.new(-6.5 + k * 0.6, 5.5, 61.2) * CFrame.Angles(0.1, 0, 0.12 - k * 0.1), CAMP.logD, D()) end
box(YD, "Cooler", 18, 0, 70, 22, 2.4, 72.6, WHITEP, DECO)
box(YD, "CoolerLid", 17.8, 2.4, 69.8, 22.2, 2.8, 72.8, st(M.SmoothPlastic, nil, C3(50, 90, 140)), DECO)
cyl(YD, CFrame.new(32, 3.5, 104), "SignPost", 0.5, 7, 0, 0, 0, CAMP.logD, D())
sign(YD, "NO SWIMMING AFTER DARK", CFrame.new(32, 6.4, 104.3) * CFrame.Angles(0, math.pi, 0), 7, 1.6, WHITEP, C3(150, 30, 26), Enum.Font.SpecialElite)
campYard("BOATHOUSE", { noPath = true })
return endMap()
