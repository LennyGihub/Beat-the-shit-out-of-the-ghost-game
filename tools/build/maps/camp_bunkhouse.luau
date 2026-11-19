-- THE BUNKHOUSE (Camp Hollowmere, building 1: THE ANTLERED ONE, who climbs into the rafters and drops on you).
-- One huge dorm hall under high open rafters, bunks down both long walls with a footlocker at each, a pot-belly
-- stove and a long table in the middle; at the back (low walls, the rafters run over them) the washroom, the
-- storeroom and the counselor's room. One storey, 30 high.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_bunkhouse.luau
-- then furnish (ONLY = "Camp_Bunkhouse"), detail (TARGET = "Camp_Bunkhouse"), phones and doors_clear.
local C3 = Color3.fromRGB
local function D() return { deco = true } end
beginMap("Camp_Bunkhouse", campTheme({}))
-- (2026-11-19) its own shape: the steep gable faces the yard, a log hall with crossed corner logs
local TOP = shell2({ H = 30, ridge = "z", roof = "gable", rise = 40, over = 4, roofStyle = CAMP.shingle, steps = false,
	front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -4 }, right1 = { 44, 20, -4 }, win = { w = 6, b = 5, t = 13 } })
local inn = model(STR, "Interior")
local I = INT()
-- the back rooms (z -58..-30): 14 high, a low ceiling of their own
wall(inn, "BackRooms", "x", -30, -78, 78, F1, 14, { dr(-52, 8, 11), dr(0, 8, 11), dr(52, 8, 11) }, I)
wall(inn, "DividerW", "z", -26, -58, -30.6, F1, 14, {}, I)
wall(inn, "DividerE", "z", 26, -58, -30.6, F1, 14, {}, I)
box(STR, "BackCeiling", -78, F1 + 14, -58, 78, F1 + 14.6, -29.4, CAMP.logD)

-- THE RAFTERS: tie beams across the hall, king posts up to the ridge, two purlins along it (he climbs these)
local rf = model(STR, "Rafters")
for z = -24, 54, 13 do
	box(rf, "TieBeam", -78, 23.5, z - 0.9, 78, 25.3, z + 0.9, CAMP.logD)
	box(rf, "KingPost", -0.7, 25.3, z - 0.7, 0.7, 31, z + 0.7, CAMP.logD)
end
for _, x in { -30, 30 } do box(rf, "Purlin", x - 0.8, 25.3, -28, x + 0.8, 26.9, 58, CAMP.logD) end

-- the bunks down both walls, heads to the wall, a footlocker at the foot of each
for _, z in { -20, -7, 6, 19, 32, 45 } do
	G2.bunk(at(-73, F1, z, "E"))
	G2.bunk(at(73, F1, z, "W"))
	F.toyChest(at(-67, F1, z, "E"))
	F.toyChest(at(67, F1, z, "W"))
end
-- the pot-belly stove (solid) and its pipe to the roof
local sv = model(STR, "Stove")
cyl(sv, CFrame.new(0, F1 + 2.6, 12), "Belly", 3.4, 4.4, 0, 0, 0, CAMP.iron)
cyl(sv, CFrame.new(0, F1 + 0.3, 12), "Foot", 4, 0.6, 0, 0, 0, CAMP.iron)
cyl(sv, CFrame.new(0, 17, 12), "Pipe", 0.9, 24, 0, 0, 0, CAMP.iron, D())
local ember = box(sv, "Grate", -0.8, F1 + 1.6, 10.2, 0.8, F1 + 2.4, 10.4, CAMP.ember, D())
light(ember, 18, 1.2, C3(255, 140, 60))
box(DEC, "StoveMat", -4, F1 + 0.02, 8, 4, F1 + 0.1, 16, CAMP.stone, D())
-- the long table and its benches, a ping-pong table, chairs
F.table(at(-26, F1, 26, "N"), 16, 5, 3.2, Wd.mid, "Table")
F.bench(at(-26, F1, 22.6, "N"), 14)
F.bench(at(-26, F1, 29.4, "S"), 14)
F.table(at(28, F1, 30, "E"), 10, 5.4, 3, st(M.Wood, nil, C3(46, 88, 60)), "PingPong")
for _, p in { { 20, 40, "N" }, { 36, 22, "S" }, { -40, 44, "E" } } do F.chair(at(p[1], F1, p[2], p[3]), Wd.mid) end
F.barrel(at(-10, F1, 50, "N"))
F.crate(at(10, F1, 52, "N"), 3)
-- the washroom (west back room): sinks, two stalls, a mirror
for _, x in { -72, -64, -56 } do F.sink(at(x, F1, -56, "S")) end
for _, x in { -44, -34 } do
	F.toilet(at(x, F1, -55.5, "S"))
	box(inn, "Stall", x + 4.4, F1, -58, x + 4.8, F1 + 8, -48, CAMP.inner)
end
F.mirror(at(-64, F1, -56.8, "S"))
-- the storeroom (middle): crates, barrels, shelves, paddles
F.cabinet(at(-18, F1, -56, "S"), 6, 9)
F.cabinet(at(18, F1, -56, "S"), 6, 9)
for _, p in { { -12, -40 }, { -6, -50 }, { 8, -44 }, { 14, -36 } } do F.crate(at(p[1], F1, p[2], "N"), 3) end
F.barrel(at(0, F1, -54, "N"))
for i = 0, 3 do
	local pd = model(DEC, "Paddle")
	box(pd, "Shaft", -22.5, F1 + 2, -46 + i * 1.6, -22.1, F1 + 8, -45.6 + i * 1.6, CAMP.logD, D())
	box(pd, "Blade", -22.6, F1 + 0.6, -46.4 + i * 1.6, -22, F1 + 2.4, -45.2 + i * 1.6, st(M.Wood, nil, C3(150, 50, 40)), D())
end
-- the counselor's room (east): bed, desk, wardrobe, a lamp, a rug
F.bed(at(70, F1, -48, "W"), 6, 9, Fab.green)
F.desk(at(40, F1, -55, "S"))
F.chair(at(40, F1, -50, "N"), Wd.mid)
F.wardrobe(at(76, F1, -36, "W"))
F.floorLamp(at(32, F1, -36, "N"))
rug(48, -50, 62, -38, F1, st(M.Fabric, nil, C3(120, 54, 40)), st(M.Fabric, nil, C3(70, 40, 30)))

-- the hall's posters, a camp map, a lost-and-found board
poster(-78.3 + 0.6, 12, 12, "E", 6, 4, C3(80, 110, 70), CAMP.logD)
poster(78.3 - 0.6, 12, 32, "W", 5, 6, C3(180, 160, 110), CAMP.logD)
poster(-20, 10, -29.2, "N", 10, 6, C3(150, 130, 90), CAMP.logD)
poster(20, 10, -29.2, "N", 6, 4, C3(110, 60, 50), CAMP.logD)
-- lights: bulbs hanging from the tie beams, one in each back room
for _, p in { { -40, -2 }, { 40, -2 }, { -40, 37 }, { 40, 37 }, { 0, 24 } } do bulb(p[1], 23.4, p[2], 5, C3(255, 196, 130)) end
for _, x in { -52, 0, 52 } do bulb(x, F1 + 14, -44, 1.5, C3(255, 200, 140)) end
for _, p in { { -50, 30 }, { 46, 8 }, { -12, -46 } } do blood(p[1], F1, p[2], 2) end
-- where the monster can start
for _, p in { { -40, 10 }, { 40, 40 }, { 0, 34 }, { -52, -44 }, { 52, -44 }, { 0, -44 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1) -- (the way in from the front door)
-- OUTSIDE (2026-11-19): the Antlered One's hall. Logs laid along the walls, crossed log ends at the corners, a
-- porch the whole width of the front, the antlers of something enormous nailed over the gable, claw marks.
local OUT = model(DEC, "Outside")
logBands("x", 60, -80, 80, 3.5, 30, 3.2, 1, CAMP.logD, holesOf({ -60, -36, 36, 60 }, 6, 5, 13, F1, { 10, 15 }))
logBands("x", -60, -80, 80, 3.5, 30, 3.2, -1, CAMP.logD, holesOf({ -60, 60 }, 6, 5, 13, F1))
logBands("z", -80, -60, 60, 3.5, 30, 3.2, -1, CAMP.logD, holesOf({ 44, 20, -4 }, 6, 5, 13, F1))
logBands("z", 80, -60, 60, 3.5, 30, 3.2, 1, CAMP.logD, holesOf({ 44, 20, -4 }, 6, 5, 13, F1))
for _, c in { { -80, 60, -1, 1 }, { 80, 60, 1, 1 }, { -80, -60, -1, -1 }, { 80, -60, 1, -1 } } do cornerLogs(c[1], c[2], 3, 31, c[3], c[4]) end
-- the porch: a deck along the whole front, log posts, a lean-to roof, a rail with a gap at the door
box(STR, "PorchDeck", -70, 0, 60, 70, 2.05, 70, CAMP.plank)
box(STR, "PorchStep", -9, 0, 70, 9, 1.35, 72.5, CAMP.plank)
box(STR, "PorchStep", -9, 0, 72.5, 9, 0.7, 75, CAMP.plank)
for _, x in { -70, -56, -42, -28, -14, 14, 28, 42, 56, 70 } do cyl(OUT, CFrame.new(x, 8.5, 69), "PorchPost", 1.4, 13, 0, 0, 0, CAMP.logD, D()) end
panel(OUT, "PorchRoof", Vector3.new(0, 16.2, 60), Vector3.new(0, 13.4, 72), Vector3.new(1, 0, 0), 146, CAMP.shingle, 0.8, D())
for _, s2 in { -1, 1 } do
	box(OUT, "PorchRail", s2 * 7, 4.6, 69.2, s2 * 70, 5.0, 69.6, CAMP.log, DECO)
	box(OUT, "PorchRail", s2 * 7, 3.0, 69.2, s2 * 70, 3.3, 69.6, CAMP.log, DECO)
end
for _, x in { -36, -8, 8, 36 } do campLantern(OUT, x, 11, 60.2) end
campNameBoard("BUNKHOUSE", CFrame.new(0, 18.4, 61), 26, 3.8)
-- the gable: a round window, the antlers and the skull they grew from
do
	local gy = TOP + 14
	cyl(OUT, CFrame.new(0, gy, 60.2) * CFrame.Angles(math.pi / 2, 0, 0), "GableWindowRim", 9, 0.6, 0, 0, 0, CAMP.logD, D())
	cyl(OUT, CFrame.new(0, gy, 60.4) * CFrame.Angles(math.pi / 2, 0, 0), "GableWindow", 7.6, 0.3, 0, 0, 0, st(M.Neon, nil, C3(255, 150, 70)), { deco = true, t = 0.15 })
	box(OUT, "GableBar", -3.8, gy - 0.2, 60.5, 3.8, gy + 0.2, 60.8, CAMP.logD, DECO)
	box(OUT, "GableBar", -0.2, gy - 3.8, 60.5, 0.2, gy + 3.8, 60.8, CAMP.logD, DECO)
	local BONE = st(M.SmoothPlastic, nil, C3(214, 204, 176))
	local sk = CFrame.new(0, TOP + 26, 62)
	b(OUT, sk, "Skull", 5, 5, 6, 0, 0, 0, BONE, D())
	b(OUT, sk, "Snout", 3, 3, 4, 0, -2.4, 2.6, BONE, D())
	for _, x in { -1.3, 1.3 } do b(OUT, sk, "EyeHole", 1.2, 1.2, 0.3, x, 0.6, 3.05, st(M.SmoothPlastic, nil, C3(10, 8, 6)), D()) end
	for _, sx in { -1, 1 } do -- each antler: a beam out and up, tines off it
		local base = sk * CFrame.new(sx * 2.4, 2, 0)
		local p0 = base.Position
		local p1 = p0 + Vector3.new(sx * 9, 7, 0)
		local p2 = p1 + Vector3.new(sx * 6, 9, -1)
		local p3 = p2 + Vector3.new(sx * 2, 7, 0)
		for _, seg in { { p0, p1 }, { p1, p2 }, { p2, p3 } } do
			part(OUT, "Antler", Vector3.new(1.3, 1.3, (seg[2] - seg[1]).Magnitude), CFrame.lookAt((seg[1] + seg[2]) / 2, seg[2]), BONE, D())
		end
		for _, t in { { p0:Lerp(p1, 0.5), Vector3.new(0, 6, 1) }, { p1, Vector3.new(-sx * 1, 7, 0) }, { p1:Lerp(p2, 0.5), Vector3.new(sx * 4, 5, 0) }, { p2, Vector3.new(-sx * 2, 6, 0) } } do
			local a, z = t[1], t[1] + t[2]
			part(OUT, "Tine", Vector3.new(0.9, 0.9, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), BONE, D())
		end
	end
	light(b(OUT, sk, "SkullGlow", 0.2, 0.2, 0.2, 0, 0, 5, BONE, { deco = true, t = 1 }), 20, 0.55, C3(200, 210, 255))
	-- barge boards along the gable's edges (light wood: the roof's outline reads against the night sky)
	for _, sx in { -1, 1 } do
		local a, z = Vector3.new(sx * 84, TOP - 2, 62.4), Vector3.new(0, TOP + 40, 62.4)
		part(OUT, "BargeBoard", Vector3.new(0.6, 1.6, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), CAMP.log, D())
	end
	-- moonlight on the gable from two uplights in the yard, a warm one on the porch
	washLight(-34, 84, Vector3.new(-10, TOP + 18, 60), C3(170, 186, 230), 90, 2.2)
	washLight(34, 84, Vector3.new(10, TOP + 18, 60), C3(170, 186, 230), 90, 2.2)
end
-- claw marks raked down the front and the side, a cracked window
for _, c in { { -48, 22, 0.25, 7 }, { 26, 9, -0.2, 5 }, { 62, 25, 0.1, 6 } } do clawMarks(OUT, c[1], c[2], 60.35, c[4], c[3]) end
-- a stone chimney up the east side (the stove pipe's)
box(OUT, "Chimney", 81, 0, 8, 88, TOP + 30, 16, CAMP.stone, DECO)
box(OUT, "ChimneyCap", 80.5, TOP + 30, 7.5, 88.5, TOP + 31, 16.5, CAMP.iron, DECO)

-- THE BUNKHOUSE'S YARD: a clothesline of towels and sleeping bags, a tetherball, duffel bags, a bunk he threw out
local YD = model(DEC, "BunkYard")
for _, x in { -40, -16 } do
	cyl(YD, CFrame.new(x, 4.5, 92), "LinePole", 0.6, 9, 0, 0, 0, CAMP.logD, D())
	box(YD, "LineArm", x - 0.3, 8.6, 90.5, x + 0.3, 9, 93.5, CAMP.logD, DECO)
end
for _, z in { 91, 93 } do box(YD, "Line", -40, 8.7, z - 0.05, -16, 8.8, z + 0.05, st(M.Fabric, nil, C3(200, 200, 190)), DECO) end
local cloth = { C3(170, 50, 40), C3(60, 100, 150), C3(220, 210, 180), C3(70, 110, 60), C3(200, 150, 50) }
for k = 0, 6 do
	local x = -38 + k * 3.2
	box(YD, "Towel", x - 1.2, 5.4 + (k % 2) * 0.8, 90.9 + (k % 2) * 2, x + 1.2, 8.7, 91.1 + (k % 2) * 2, st(M.Fabric, nil, cloth[k % 5 + 1]), DECO)
end
cyl(YD, CFrame.new(28, 6, 86), "TetherPole", 0.5, 12, 0, 0, 0, CAMP.iron, D())
box(YD, "TetherRope", 28.3, 4, 85.9, 28.4, 11.8, 86.0, st(M.Fabric, nil, C3(220, 210, 190)), DECO)
ball(YD, CFrame.new(28.6, 3.6, 86), "Tetherball", 1.8, 0, 0, 0, st(M.SmoothPlastic, nil, C3(200, 170, 40)), D())
for _, p in { { -26, 74, 0.4 }, { 20, 100, 1.2 }, { -34, 110, 2 } } do
	part(YD, "Duffel", Vector3.new(2.2, 1.8, 4), CFrame.new(p[1], 0.9, p[2]) * CFrame.Angles(0, p[3], 0), st(M.Fabric, nil, C3(80, 90, 60)), D())
end
-- the bunk he threw out through the door: on its side, split
do
	local cf = CFrame.new(-22, 0, 78) * CFrame.Angles(0, 0.5, 0) * CFrame.Angles(0, 0, math.rad(78))
	part(YD, "BunkPost", Vector3.new(1, 9, 1), cf * CFrame.new(1, 4.5, -4), CAMP.log, D())
	part(YD, "BunkPost", Vector3.new(1, 9, 1), cf * CFrame.new(1, 4.5, 4), CAMP.log, D())
	part(YD, "BunkFrame", Vector3.new(4, 0.6, 9), cf * CFrame.new(2.5, 2.5, 0), CAMP.logD, D())
	part(YD, "Mattress", Vector3.new(3.6, 0.8, 8.4), cf * CFrame.new(2.5, 3.1, 0), st(M.Fabric, nil, C3(120, 110, 90)), D())
end
campYard("BUNKHOUSE")
return endMap()
