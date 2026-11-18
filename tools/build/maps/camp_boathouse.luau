-- THE BOATHOUSE (Camp Hollowmere, building 2: THE LAKE WITCH, whose hook drags you toward the water and who floods
-- the floor). The lake comes right inside: a wide boat door in the back wall opens onto it and a SLIP of black water
-- runs down the middle of the boat hall (two rowboats in it), docks either side with canoe racks, oars and life
-- rings. At the front: the workshop, the entry hall and the lifeguard's office. One storey, 24 high.
-- Folder WaterSpots: points in the slip and at the boat door (the Lake Witch drags her victims toward the nearest).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_boathouse.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local WATER = st(M.Glass, nil, C3(30, 62, 66))
local DARKW = st(M.SmoothPlastic, nil, C3(8, 16, 18))
local REDP = st(M.SmoothPlastic, nil, C3(170, 40, 34))
local WHITEP = st(M.SmoothPlastic, nil, C3(220, 214, 200))
beginMap("Camp_Boathouse", campTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(74, 70, 62)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(116, 104, 88)), lanternColor = C3(220, 236, 240) }))
shell({ two = false, H = 24, roof = "gable", pitch = 0.45, front1 = { -60, -36, 36, 60 }, back1 = {}, left1 = { 44, 8, -30 }, right1 = { 44, 8, -30 },
	winW = 6, winB = 5, winT = 13 })
-- the back wall again, with the boat door onto the lake (36 wide, 18 high)
local ext = STR:FindFirstChild("Exterior")
local oldBack = ext and ext:FindFirstChild("Back1")
if oldBack then oldBack:Destroy() end
wall(ext, "Back1", "x", -59, -80, 80, F1, 24, { dr(0, 36, 18) }, EXT(1))
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
-- THE LAKE outside the boat door (deco water over the forest floor) and a log boom across the door
box(DEC, "Lake", -160, 1.3, -260, 160, 1.7, -60.5, WATER, { deco = true, t = 0.25 })
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
campNameBoard("BOATHOUSE")
campYard("BOATHOUSE")
return endMap()
