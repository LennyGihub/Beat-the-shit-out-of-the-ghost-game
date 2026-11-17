-- Ravenhill Asylum (its own layout: it used to be the hospital's corridor plan with other furniture).
-- A red-brick Victorian asylum with a clock tower. Inside, a tall central hall open to the roof: the caged nurse
-- station in the middle, a gallery round it upstairs, and a half-turn stair against its back wall.
--   ground  west wing: a north-south cell corridor (six padded cells), the baths, the restraint store
--           east wing: the day room (north) and the shock room (south);  behind the hall: the boiler room
--   upper   west: the dormitory and the records room;  east: the operating theatre (with viewing tiers) and the
--           superintendent's office;  behind the hall: two isolation cells
-- Prepend lib2 + furn_lib + maplib. Then run maps/furnish.luau (ONLY = "Asylum") and maps/detail.luau (TARGET = "Asylum").
local C3 = Color3.fromRGB
beginMap("Asylum", {
	floor = st(M.Concrete, nil, C3(146, 136, 110)), floor2 = st(M.WoodPlanks, nil, C3(104, 84, 64)),
	inner = st(M.Plaster, "PS2_Plaster", C3(198, 186, 150)), wainscot = st(M.SmoothPlastic, nil, C3(84, 46, 38)), wain = true, wainH = 6,
	ext = st(M.Brick, nil, C3(108, 64, 56)), trim = st(M.Wood, nil, C3(58, 46, 40)), ceiling = st(M.Plaster, "PS2_Plaster", C3(176, 168, 140)),
	roof = st(M.Slate, nil, C3(50, 50, 56)), found = st(M.Cobblestone, "PS2_Stone1", C3(96, 90, 84)), door = st(M.Metal, nil, C3(70, 66, 60)),
	bars = true, porch = st(M.Concrete, nil, C3(120, 114, 104)), stairs = st(M.Concrete, nil, C3(132, 124, 108)),
	lanternColor = C3(255, 200, 130), floodColor = C3(230, 214, 180),
})
shell({ two = true, roof = "gable", pitch = 0.5 })
local inn = model(STR, "Interior")
local I = INT()
local PAD = st(M.Fabric, nil, C3(206, 198, 170))
local RUSTY = st(M.CorrodedMetal, nil, C3(104, 74, 56))
local SICK, WARMB = C3(214, 232, 176), C3(255, 206, 140)
local SG = { step = T.stairs, trim = T.iron, wall = T.inner, wain = T.wainscot, kind = "balusters" }

---------------------------------------------------------------- ground floor walls
-- the hall: x -24..24, z -14..58 (open to the roof between x -15..15, z 20..58)
wall(inn, "G_hallW", "z", -24, -58, 58, F1, 20, { dr(0, 10, 13), dr(36, 8) }, I)
wall(inn, "G_hallE", "z", 24, -58, 58, F1, 20, { dr(-7, 9), dr(36, 10, 13) }, I)
wall(inn, "G_hallS", "x", -14, -23.4, 23.4, F1, 20, { dr(-17, 8), dr(17, 8) }, I)
-- west wing: the cell corridor (x -56..-46) runs north-south, a passage (z -6..6) joins it to the hall
local CELLZ = { -48.3, -29, -9.7, 9.7, 29, 48.3 }
local cellDoors = {}
for _, z in CELLZ do table.insert(cellDoors, dr(z, 7, 11)) end -- wide enough for the monster (its path needs ~6)
wall(inn, "W_corW", "z", -56, -58, 58, F1, 20, cellDoors, I)
for _, z in { -38.7, -19.3, 0, 19.3, 38.7 } do wall(inn, "Cell" .. z, "x", z, -78, -56.6, F1, 20, {}, I) end
wall(inn, "W_corE", "z", -46, -58, 58, F1, 20, { dr(-32, 8), dr(0, 10, 13), dr(32, 8) }, I)
wall(inn, "W_passN", "x", 6, -45.4, -24.6, F1, 20, {}, I)
wall(inn, "W_passS", "x", -6, -45.4, -24.6, F1, 20, {}, I)
-- east wing: day room (north) and shock room (south)
wall(inn, "E_mid", "x", 0, 24.6, 78, F1, 20, { dr(62, 8) }, I)

---------------------------------------------------------------- upper floor
slab(-78, -58, -15, 58); slab(15, -58, 78, 58)
slab(-15, -58, 15, -13.4); slab(-15, -13.4, -8, 20); slab(8, -13.4, 15, 20); slab(-8, 10.1, 8, 20)
-- the stair: in the hall, against its back wall, rising away from the front door and turning back
dogleg(STR, { cf = CFrame.new(0, F1, 10.1), W = 16, L = 23.5, mir = 1, S = SG, low = { a = true, b = true }, up = { a = true, b = true } })
-- the gallery round the hall
local gal = model(STR, "Gallery")
for _, x in { -15.35, 15.35 } do
	guard(gal, Vector3.new(x, F2, 20), Vector3.new(x, F2, 57.6), SG)
	newel(gal, Vector3.new(x, F2, 20), SG)
end
guard(gal, Vector3.new(-15.35, F2, 20.35), Vector3.new(15.35, F2, 20.35), SG)
box(gal, "GalleryEdge", -15.6, 21.4, 19.6, 15.6, 23.05, 20, T.trim)
for _, x in { -15.6, 15.2 } do box(gal, "GalleryEdge", x, 21.4, 20, x + 0.4, 23.05, 58, T.trim) end
wall(inn, "U_hallW", "z", -24, -58, 58, F2, 20, { dr(2, 8), dr(36, 8) }, I)
wall(inn, "U_hallE", "z", 24, -58, 58, F2, 20, { dr(2, 8), dr(36, 8) }, I)
wall(inn, "U_back", "x", -14, -23.4, 23.4, F2, 20, { dr(-16, 7, 11), dr(16, 7, 11) }, I)
wall(inn, "U_iso", "z", 0, -58, -14.6, F2, 20, {}, I)
wall(inn, "U_westS", "x", -14, -78, -24.6, F2, 20, { dr(-50, 8) }, I)
wall(inn, "U_eastS", "x", -14, 24.6, 78, F2, 20, { dr(52, 8) }, I)

-- where the random passes put nothing: the corridor and its passage, the foot of the stair, the whole landing
-- strip upstairs and the gallery walks
keepClear(-55.4, -58, -46.6, 58, F1); keepClear(-46.6, -6, -24, 6, F1); keepClear(-13, 8.5, 13, 21, F1)
keepClear(-24, -14, 24, 20.4, F2); keepClear(-24, 20, -15, 58, F2); keepClear(15, 20, 24, 58, F2)

---------------------------------------------------------------- the hall
-- the nurse station: a low wall with bars up to its roof, a gap toward the front door
local cage = model(STR, "NurseCage")
local CX, CZ, CH = 0, 34, 6
for _, s in { { -CH, -CH, CH, -CH + 0.6 }, { -CH, -CH, -CH + 0.6, CH }, { CH - 0.6, -CH, CH, CH }, { -CH, CH - 0.6, -2.5, CH }, { 2.5, CH - 0.6, CH, CH } } do
	box(cage, "CageWall", CX + s[1], F1, CZ + s[2], CX + s[3], F1 + 3.8, CZ + s[4], T.wainscot)
	box(cage, "CageSill", CX + s[1] - 0.15, F1 + 3.8, CZ + s[2] - 0.15, CX + s[3] + 0.15, F1 + 4.1, CZ + s[4] + 0.15, T.trim, DECO)
end
for i = -CH + 0.5, CH - 0.5, 1 do
	for _, sg in { -1, 1 } do
		box(cage, "Bar", CX + i - 0.1, F1 + 4.1, CZ + sg * (CH - 0.3) - 0.1, CX + i + 0.1, F1 + 10, CZ + sg * (CH - 0.3) + 0.1, T.iron, DECO)
		box(cage, "Bar", CX + sg * (CH - 0.3) - 0.1, F1 + 4.1, CZ + i - 0.1, CX + sg * (CH - 0.3) + 0.1, F1 + 10, CZ + i + 0.1, T.iron, DECO)
	end
end
for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do
	box(cage, "CagePost", CX + sx * CH - 0.5, F1, CZ + sz * CH - 0.5, CX + sx * CH + 0.5, F1 + 10, CZ + sz * CH + 0.5, T.trim)
end end
box(cage, "CageRoof", CX - CH - 0.6, F1 + 10, CZ - CH - 0.6, CX + CH + 0.6, F1 + 10.6, CZ + CH + 0.6, T.trim)
local cg = box(cage, "CageLamp", CX - 0.8, F1 + 9.6, CZ - 0.8, CX + 0.8, F1 + 10, CZ + 0.8, st(M.Neon, nil, SICK), DECO)
light(cg, 26, 1.4, SICK)
F.desk(at(CX, F1, CZ - 2, "S")); F.chair(at(CX, F1, CZ + 1, "N"), Steel); F.cabinet(at(CX - 4, F1, CZ - 3.5, "S"), 3, 7)
for _, z in { 24, 46 } do F.bench(at(-21.5, F1, z, "E"), 8); F.bench(at(21.5, F1, z, "W"), 8) end
G2.wheelchair(at(-12, F1, 50, "S")); G2.gurney(at(19, F1, 26, "N")); F.clock(at(-20, F1, 12, "E"))
rug(-5, 40.5, 5, 57, F1 + 0.05, st(M.Carpet, nil, C3(70, 30, 28)), st(M.Carpet, nil, C3(40, 34, 30)))
-- (the gallery walks stay empty: they are the monster's way round the hall)

---------------------------------------------------------------- west wing: cells, baths, restraint store
for _, cz in CELLZ do
	local pc = model(DEC, "Padding")
	for x = -77.4, -60, 4.2 do
		for _, sg in { -1, 1 } do
			local zf = cz + sg * 9.05
			box(pc, "Pad", x, F1 + 0.5, zf - sg * 0.3, x + 3.9, F1 + 12, zf, PAD, DECO)
		end
	end
	for z = cz - 8.4, cz + 5, 4.2 do box(pc, "Pad", -77.75, F1 + 0.5, z, -77.45, F1 + 12, z + 3.9, PAD, DECO) end
	-- the steel door, swung open against the corridor wall
	box(pc, "CellDoor", -55.3, F1 + 0.1, cz + 3.7, -55, F1 + 10.6, cz + 9.4, T.door, DECO)
	box(pc, "CellHatch", -54.98, F1 + 5.4, cz + 5.6, -54.9, F1 + 6.4, cz + 7.4, T.iron, DECO)
	G2.hospitalBed(at(-71.5, F1, cz - 3, "E"), true)
	bulb(-66, 21, cz, 1.5, SICK)
end
F.toilet(at(-60, F1, CELLZ[2] + 6, "E")); F.toilet(at(-60, F1, CELLZ[5] + 6, "E"))
-- (the cell corridor stays empty: 8.8 wide is just what the monster needs)
-- the baths (x -46..-24, z 6..58)
for _, z in { 18, 31, 44 } do F.bathtub(at(-37, F1, z, "E")) end
for _, x in { -42, -36, -30 } do F.sink(at(x, F1, 56, "N")) end
F.toilet(at(-27, F1, 12, "W")); F.cabinet(at(-43.5, F1, 10, "E"), 5, 8)
box(DEC, "BathTiles", -45.3, F1 + 0.05, 6.7, -24.7, F1 + 0.14, 57.6, st(M.Marble, nil, C3(150, 168, 160)), DECO)
-- the restraint store (x -46..-24, z -58..-6)
for _, z in { -50, -44, -38 } do G2.locker(at(-43.8, F1, z, "E"), C3(84, 88, 80)) end
F.cabinet(at(-30, F1, -55.5, "S"), 6, 9); F.crate(at(-28, F1, -30, "N"), 3.5); F.crate(at(-28.5, F1, -25, "N"), 3)
G2.wheelchair(at(-36, F1, -18, "W")); G2.gurney(at(-34, F1, -42, "E")); G2.steelTable(at(-36, F1, -12, "E"))

---------------------------------------------------------------- east wing: day room, shock room
for _, p in { { 40, 20 }, { 60, 34 }, { 42, 46 } } do
	F.table(at(p[1], F1, p[2], "N"), 8, 4, 3, Wd.light, "Table")
	F.chair(at(p[1] - 3, F1, p[2] + 4, "N"), Steel); F.chair(at(p[1] + 3, F1, p[2] - 4, "S"), Steel)
end
F.tv(at(52, F1, 56, "N")); F.sofa(at(52, F1, 46, "N"), Fab.green, 8); F.rockingChair(at(72, F1, 50, "W")); F.rockingChair(at(72, F1, 14, "W"))
F.piano(at(74, F1, 30, "W")); F.bookshelf(at(30, F1, 4, "S"), 8, 10); G2.wheelchair(at(32, F1, 12, "E"))
rug(44, 40, 60, 54, F1 + 0.05, st(M.Carpet, nil, C3(84, 80, 56)))
-- the shock room: the chair on its platform, the machine, tables of instruments
local shock = model(DEC, "ShockMachine")
box(shock, "Platform", 46, F1, -36, 58, F1 + 0.6, -24, T.trim, DECO)
box(shock, "Machine", 60, F1, -34, 64, F1 + 7, -26, st(M.Metal, nil, C3(70, 74, 70)), DECO)
for i = 0, 2 do box(shock, "Dial", 59.9, F1 + 4.6, -32.5 + i * 2.2, 60, F1 + 5.8, -31.3 + i * 2.2, st(M.Neon, nil, i == 1 and C3(220, 60, 40) or SICK), DECO) end
light(shock:FindFirstChild("Dial"), 14, 0.8, SICK)
for _, z in { -32, -28 } do box(shock, "Cable", 55, F1 + 0.6, z - 0.1, 60, F1 + 0.8, z + 0.1, T.iron, DECO) end
F.armchair(at(52, F1, -30, "W"), Fab.brown, 4)
G2.steelTable(at(36, F1, -40, "N")); G2.steelTable(at(70, F1, -46, "N")); G2.gurney(at(40, F1, -14, "E")); G2.gurney(at(66, F1, -10, "W"))
F.cabinet(at(30, F1, -55.5, "S"), 6, 9); F.cabinet(at(38, F1, -55.5, "S"), 6, 9); F.desk(at(74, F1, -30, "W")); F.sink(at(27, F1, -30, "E"))

---------------------------------------------------------------- behind the hall: the boiler room
local boil = model(DEC, "Boiler")
part(boil, "Tank", Vector3.new(18, 9, 9), CFrame.new(0, F1 + 6, -50), RUSTY, { shape = Enum.PartType.Cylinder })
for _, x in { -6, 6 } do box(boil, "Cradle", x - 1, F1, -54, x + 1, F1 + 3, -46, st(M.Brick, nil, C3(90, 60, 52))) end
local fire = box(boil, "FireDoor", -2, F1 + 3.2, -45.4, 2, F1 + 6.4, -45.1, st(M.Neon, nil, C3(255, 120, 40)), DECO)
light(fire, 30, 1.6, C3(255, 130, 60))
for _, x in { -8, 8 } do
	box(boil, "Pipe", x - 0.5, F1 + 10, -50.5, x + 0.5, F1 + 19.5, -49.5, RUSTY, DECO)
	box(boil, "Pipe", math.min(x, x * 2.8), F1 + 18.5, -50.5, math.max(x, x * 2.8), F1 + 19.5, -49.5, RUSTY, DECO)
end
F.barrel(at(-19, F1, -52, "N")); F.barrel(at(-16, F1, -55, "N")); F.crate(at(18, F1, -40, "N"), 3.5); F.crate(at(19, F1, -34, "N"), 3)
G2.workbench(at(15, F1, -54.5, "S"), 8); F.crate(at(-18, F1, -22, "N"), 3)

---------------------------------------------------------------- upstairs west: dormitory, records
for _, z in { -6, 12, 24, 46, 54 } do G2.hospitalBed(at(-72, F2, z, "E"), true) end
for _, z in { 14, 24, 48 } do G2.hospitalBed(at(-30, F2, z, "W"), true) end
for _, z in { 3, 33 } do F.nightstand(at(-75, F2, z, "E")) end
G2.wheelchair(at(-50, F2, 30, "N")); F.wardrobe(at(-50, F2, 55.5, "N")); F.chair(at(-46, F2, -6, "S"), Steel)
for x = -74, -32, 8 do F.cabinet(at(x, F2, -55.5, "S"), 6, 10) end
for _, x in { -66, -50, -34 } do F.bookshelf(at(x, F2, -36, "N"), 8, 10) end
F.desk(at(-72, F2, -24, "E")); F.chair(at(-68, F2, -24, "W"), Wd.mid, Fab.green)
---------------------------------------------------------------- upstairs east: operating theatre, the superintendent's office
for i = 1, 3 do
	box(STR, "Tier", 77.75 - i * 4, F2, 6, 77.75 - (i - 1) * 4, F2 + (4 - i) * 1.5, 50, T.trim)
end
F.bench(at(75.7, F2 + 4.5, 28, "W"), 12); F.bench(at(71.7, F2 + 3, 28, "W"), 12)
G2.steelTable(at(46, F2, 28, "N")); G2.steelTable(at(46, F2, 14, "N")); G2.gurney(at(34, F2, 44, "E")); G2.gurney(at(56, F2, 46, "W"))
F.cabinet(at(40, F2, 55.5, "N"), 6, 9); F.cabinet(at(48, F2, 55.5, "N"), 6, 9); F.sink(at(27, F2, 16, "E")); F.sink(at(27, F2, 22, "E"))
G2.wheelchair(at(36, F2, -4, "E"))
local lamp = model(LIT, "SurgeryLamp")
box(lamp, "Arm", 45.8, F2 + 12, 27.8, 46.2, F2 + 19, 28.2, T.iron, DECO)
local sl = part(lamp, "Dish", Vector3.new(0.6, 5, 5), CFrame.new(46, F2 + 11.7, 28) * CFrame.Angles(0, 0, math.pi / 2), st(M.Neon, nil, C3(236, 244, 220)), { shape = Enum.PartType.Cylinder, deco = true })
light(sl, 34, 1.8, C3(236, 244, 220)):SetAttribute("Flicker", true)
F.desk(at(60, F2, -44, "N")); F.armchair(at(60, F2, -50, "N"), Fab.brown, 4); F.sofa(at(36, F2, -30, "E"), Fab.brown, 8)
for _, x in { 34, 44, 68 } do F.bookshelf(at(x, F2, -55.5, "S"), 8, 10) end
F.globe(at(72, F2, -22, "N")); F.clock(at(75.5, F2, -40, "W")); F.floorLamp(at(70, F2, -50, "N"))
rug(48, -50, 72, -30, F2 + 0.05, st(M.Carpet, nil, C3(96, 36, 32)), st(M.Carpet, nil, C3(50, 40, 34)))
---------------------------------------------------------------- upstairs back: two isolation cells
for _, sx in { -1, 1 } do
	local pc = model(DEC, "Padding")
	for z = -57.4, -18, 4.2 do
		box(pc, "Pad", sx * 0.6, F2 + 0.5, z, sx * 0.9, F2 + 12, z + 3.9, PAD, DECO)
		box(pc, "Pad", sx * 23.1, F2 + 0.5, z, sx * 23.4, F2 + 12, z + 3.9, PAD, DECO)
	end
	for x = 1.2, 19, 4.2 do box(pc, "Pad", sx * x, F2 + 0.5, -57.75, sx * (x + 3.9), F2 + 12, -57.45, PAD, DECO) end
	G2.hospitalBed(at(sx * 6, F2, -50, "S"), true)
	bulb(sx * 12, 42, -36, 1.5, SICK)
end

---------------------------------------------------------------- lights
-- the hall: one big lamp from the roof, sconces on its walls; bare bulbs elsewhere, sick green tubes where they treat
bulb(0, 43, 46, 9, WARMB); bulb(0, 43, 24, 9, WARMB)
for _, z in { 18, 50 } do sconce(-23.2, F1 + 11, z, "E", WARMB); sconce(23.2, F1 + 11, z, "W", WARMB) end
for _, z in { -40, -15, 15, 40 } do bulb(-51, 21, z, 1.5, WARMB) end
bulb(-35, 21, 0, 1.5, WARMB)
for _, z in { 20, 44 } do fluoro(-35, 21, z, SICK) end
bulb(-35, 21, -34, 2, WARMB)
for _, p in { { 40, 28 }, { 62, 28 }, { 52, 50 } } do bulb(p[1], 21, p[2], 2, WARMB) end
for _, p in { { 40, -30 }, { 64, -30 } } do fluoro(p[1], 21, p[2], SICK) end
bulb(-12, 21, -30, 2, WARMB)
for _, p in { { -60, 4 }, { -40, 30 }, { -60, 46 }, { -50, -36 } } do bulb(p[1], 42, p[2], 2, WARMB) end
for _, p in { { 36, 40 }, { 60, 10 } } do fluoro(p[1], 42, p[2], SICK) end
bulb(52, 42, -36, 2, WARMB)
for _, x in { -20, 20 } do bulb(x, 42, 2, 2, WARMB) end
---------------------------------------------------------------- decor
for _, p in { { -51, F1, -30 }, { -66, F1, 9 }, { 50, F1, -28 }, { 46, F2, 26 }, { 8, F2, -40 }, { -2, F1, 20 } } do blood(p[1], p[2], p[3], 2.8) end
poster(0, F1 + 15.5, -13.3, "S", 7, 5, C3(60, 56, 44), T.trim)
local fac = model(DEC, "Facade")
sign(fac, "RAVENHILL ASYLUM", CFrame.new(0, 40, 60.8) * CFrame.Angles(0, math.pi, 0), 44, 5, st(M.Metal, nil, C3(40, 40, 42)), C3(200, 200, 190), Enum.Font.Merriweather)
-- the clock tower over the entrance
box(fac, "Tower", -10, 44, 46, 10, 70, 61.4, T.ext)
box(fac, "TowerBand", -10.8, 69.4, 45.2, 10.8, 71, 62.2, T.trim)
for i = 0, 3 do box(fac, "TowerRoof", -10 + i * 2.4, 71 + i * 2.6, 46 + i * 1.8, 10 - i * 2.4, 73.6 + i * 2.6, 61.4 - i * 1.8, T.roof) end
box(fac, "Spire", -0.4, 81, 53.3, 0.4, 88, 54.1, T.iron)
local face = part(fac, "ClockFace", Vector3.new(0.5, 10, 10), CFrame.new(0, 59, 61.5) * CFrame.Angles(0, math.pi / 2, 0), st(M.Neon, nil, C3(226, 214, 170)), { shape = Enum.PartType.Cylinder, deco = true })
light(face, 30, 0.8, C3(240, 220, 170))
part(fac, "ClockHand", Vector3.new(0.5, 4.2, 0.2), CFrame.new(0, 59, 61.85) * CFrame.Angles(0, 0, math.rad(-35)) * CFrame.new(0, 2, 0), T.iron, DECO)
part(fac, "ClockHand", Vector3.new(0.4, 3, 0.2), CFrame.new(0, 59, 61.85) * CFrame.Angles(0, 0, math.rad(100)) * CFrame.new(0, 1.4, 0), T.iron, DECO)
for _, x in { -6.5, 6.5 } do box(fac, "TowerSlit", x - 1, 48, 61.3, x + 1, 54, 61.5, T.iron, DECO) end
-- the iron fence along the yard
for x = -70, 70, 7 do if math.abs(x) > 20 then box(fac, "Spike", x - 0.2, 0, 86, x + 0.2, 7, 86.4, T.iron) end end
box(fac, "Rail", -70, 6, 86, -20, 6.4, 86.4, T.iron); box(fac, "Rail", 20, 6, 86, 70, 6.4, 86.4, T.iron)

for _, p in { { -51, F1, -30 }, { -35, F1, 30 }, { 52, F1, 30 }, { 50, F1, -40 }, { 10, F1, -30 }, { -50, F2, 30 }, { 48, F2, 36 }, { 56, F2, -36 }, { 0, F2, 2 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
