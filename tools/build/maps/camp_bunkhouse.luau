-- THE BUNKHOUSE (Camp Hollowmere, building 1: THE ANTLERED ONE, who climbs into the rafters and drops on you).
-- One huge dorm hall under high open rafters, bunks down both long walls with a footlocker at each, a pot-belly
-- stove and a long table in the middle; at the back (low walls, the rafters run over them) the washroom, the
-- storeroom and the counselor's room. One storey, 30 high.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_bunkhouse.luau
-- then furnish (ONLY = "Camp_Bunkhouse"), detail (TARGET = "Camp_Bunkhouse"), phones and doors_clear.
local C3 = Color3.fromRGB
local function D() return { deco = true } end
beginMap("Camp_Bunkhouse", campTheme({}))
shell({ two = false, H = 30, roof = "gable", pitch = 0.5, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -4 }, right1 = { 44, 20, -4 },
	winW = 6, winB = 5, winT = 13 })
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
campNameBoard("BUNKHOUSE")
campYard("BUNKHOUSE")
return endMap()
