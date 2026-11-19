-- THE MAIN LODGE (Camp Hollowmere, building 5: THE CALLER, then THE LAST CALL). The camp director's two-storey
-- lodge. Ground floor: the entry hall with a grand staircase straight ahead, the GREAT ROOM to the west (a huge
-- stone fireplace, sofas round a rug, an antler chandelier, bookshelves), the camp OFFICE (desks, filing cabinets,
-- the camp map) and the DINING ROOM to the east, and a back hall with the kitchen, restrooms, storage and the
-- boiler room. Upstairs: a gallery round the stairwell, four counselors' rooms and the DIRECTOR'S OFFICE.
-- The Caller's phones come from maps/phones.luau (run it after this, like every map).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_lodge.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local SOOT = st(M.SmoothPlastic, nil, C3(20, 16, 14))
beginMap("Camp_Lodge", campTheme({}))
-- (2026-11-19) its own shape: two storeys under a long roof, a steep cross gable over the entrance, a veranda
local TOP = shell2({ two = true, roof = "gable", rise = 30, over = 3, steps = false,
	front1 = { -60, -36, 36, 60 }, back1 = { -60, -24, 24, 60 }, left1 = { 44, -4, -40 }, right1 = { 44, 10, -40 },
	front2 = { -66, -44, 44, 66 }, back2 = { -60, -30, 30, 60 }, left2 = { 40, 0, -40 }, right2 = { 40, 0, -40 } })
local inn = model(STR, "Interior")
local I = INT()

-- GROUND FLOOR WALLS
wall(inn, "GreatWall", "z", -12, -19.4, 58, F1, 20, { dr(40, 10, 14), dr(6, 10, 14) }, I)
wall(inn, "OfficeWall", "z", 12, -19.4, 58, F1, 20, { dr(44, 8, 12), dr(6, 8, 12) }, I)
wall(inn, "OfficeSplit", "x", 22, 12.6, 78, F1, 20, { dr(44, 8, 12) }, I)
wall(inn, "BackHall", "x", -20, -78, 78, F1, 20, { dr(-58, 8, 12), dr(-20, 8, 12), dr(0, 10, 14), dr(22, 8, 12), dr(60, 8, 12) }, I)
for _, x in { -40, 0, 44 } do wall(inn, "BackRoom" .. x, "z", x, -58, -20.6, F1, 20, {}, I) end
-- (the middle back room, x -40..0, is storage; its door from the back hall is the one at x -20)

-- THE GRAND STAIR: up from the entry hall toward the back (foot at z 34, top at z -2)
local SG = { step = CAMP.plank, trim = CAMP.logD, wall = CAMP.inner, kind = "balusters", wain = CAMP.logD }
grandStair(STR, { cf = CFrame.new(0, F1, 34), w = 10, S = SG, runner = st(M.Fabric, nil, C3(110, 40, 34)) })
-- UPPER FLOOR: slabs round the stairwell (x -5.4..5.4, z -2..34), a railing round its open sides
slab(-78, -58, 78, -2)
slab(-78, -2, -5.4, 58)
slab(5.4, -2, 78, 58)
slab(-5.4, 34, 5.4, 58)
railing("x", 34, -5.4, 5.4, F2)
-- UPSTAIRS WALLS: the gallery runs round the stairwell; rooms either side and at the back
wall(inn, "UpW", "z", -16, -19.4, 58, F2, 20, { dr(40, 8, 12), dr(4, 8, 12) }, I)
wall(inn, "UpE", "z", 16, -19.4, 58, F2, 20, { dr(40, 8, 12), dr(4, 8, 12) }, I)
wall(inn, "UpWsplit", "x", 22, -78, -16.6, F2, 20, {}, I)
wall(inn, "UpEsplit", "x", 22, 16.6, 78, F2, 20, {}, I)
wall(inn, "UpBack", "x", -20, -78, 78, F2, 20, { dr(-44, 8, 12), dr(0, 10, 12), dr(44, 8, 12) }, I)
wall(inn, "UpBackSplit", "z", 0, -58, -20.6, F2, 20, {}, I)

-- THE GREAT ROOM (west): the stone fireplace, sofas round a rug, the antler chandelier, bookshelves
local fp = model(STR, "Fireplace")
box(fp, "Breast", -78, F1, 8, -70, 44, 32, CAMP.stone)
box(fp, "Hearth", -70, F1, 10, -66, F1 + 0.8, 30, CAMP.stone)
box(fp, "Mantel", -70.5, F1 + 9, 7.5, -68.5, F1 + 9.8, 32.5, CAMP.logD)
box(DEC, "FireboxDark", -70.1, F1 + 0.8, 14, -69.6, F1 + 7.5, 26, SOOT, D())
local ember = box(DEC, "FireEmbers", -69.6, F1 + 0.8, 15, -68, F1 + 1.6, 25, CAMP.ember, D())
light(ember, 30, 1.6, C3(255, 140, 60))
-- a mounted head of antlers over the mantel (wood, plain blocks)
local ant = model(DEC, "Antlers")
box(ant, "Plaque", -69.8, F1 + 12, 17, -69.2, F1 + 15, 23, CAMP.logD, D())
for _, s in { -1, 1 } do
	part(ant, "Beam", Vector3.new(0.4, 4, 0.4), CFrame.new(-68.8, F1 + 15.6, 20 + s * 1.2) * CFrame.Angles(s * 0.5, 0, 0), st(M.SmoothPlastic, nil, C3(200, 186, 150)), { deco = true })
	part(ant, "Tine", Vector3.new(0.3, 2, 0.3), CFrame.new(-68.8, F1 + 16.4, 20 + s * 2.6) * CFrame.Angles(s * -0.3, 0, 0), st(M.SmoothPlastic, nil, C3(200, 186, 150)), { deco = true })
end
rug(-60, 10, -30, 32, F1, st(M.Fabric, nil, C3(120, 54, 40)), st(M.Fabric, nil, C3(70, 40, 30)))
F.sofa(at(-44, F1, 8, "N"), Fab.green, 10)
F.sofa(at(-44, F1, 34, "S"), Fab.brown, 10)
F.armchair(at(-56, F1, 21, "E"), Fab.red, 4)
F.coffeeTable(at(-44, F1, 21, "N"))
F.bookshelf(at(-50, F1, 57, "N"), 8, 10)
F.bookshelf(at(-30, F1, 57, "N"), 8, 10)
F.piano(at(-74, F1, 48, "E"))
F.rockingChair(at(-24, F1, 44, "W"))
F.floorLamp(at(-20, F1, 30, "N"))
-- the antler chandelier: a wooden wheel of candles on chains
local ch = model(LIT, "Chandelier")
cyl(ch, CFrame.new(-44, 17, 21), "Wheel", 7, 0.6, 0, 0, 0, CAMP.logD, D())
for _, dx in { -0.5, 0.5 } do box(ch, "Chain", -44 + dx - 0.05, 17.3, 20.95, -44 + dx + 0.05, 22, 21.05, CAMP.iron, D()) end
for k = 0, 5 do
	local a = k / 6 * math.pi * 2
	local cx, cz = -44 + math.cos(a) * 3, 21 + math.sin(a) * 3
	box(ch, "Candle", cx - 0.2, 17.3, cz - 0.2, cx + 0.2, 18.2, cz + 0.2, st(M.SmoothPlastic, nil, C3(230, 220, 190)), D())
	box(ch, "Flame", cx - 0.12, 18.2, cz - 0.12, cx + 0.12, 18.6, cz + 0.12, st(M.Neon, nil, C3(255, 190, 110)), D())
end
light(ch:FindFirstChild("Wheel") :: BasePart, 36, 1.4, C3(255, 190, 120))
-- THE OFFICE (north-east): two desks, filing cabinets, the camp map, a notice board
F.desk(at(40, F1, 52, "S"))
F.desk(at(60, F1, 40, "W"))
F.chair(at(40, F1, 47, "N"), Wd.mid, Fab.green)
F.chair(at(55, F1, 40, "E"), Wd.mid, Fab.green)
for _, z in { 30, 37 } do F.cabinet(at(76, F1, z, "W"), 5, 8) end
poster(30, 11, 57.6, "N", 14, 9, C3(150, 140, 100), CAMP.logD) -- (the camp map)
poster(13, 10, 40, "E", 6, 5, C3(130, 110, 90), CAMP.logD)
-- THE DINING ROOM (east): a long table and chairs, a sideboard
F.table(at(46, F1, 2, "E"), 20, 6, 3.2, Wd.mid, "DiningTable")
for _, x in { 38, 46, 54 } do F.chair(at(x, F1, -2, "N"), Wd.mid, Fab.red); F.chair(at(x, F1, 6, "S"), Wd.mid, Fab.red) end
F.dresser(at(76, F1, 2, "W"), 6)
-- THE BACK ROOMS: restrooms (west), storage, kitchen, boiler room (east)
for _, x in { -72, -64 } do F.sink(at(x, F1, -56, "S")) end
for _, x in { -52, -46 } do F.toilet(at(x, F1, -55.5, "S")) end
for _, p in { { -34, -54 }, { -26, -50 }, { -10, -54 }, { -16, -36 } } do F.crate(at(p[1], F1, p[2], "N"), 3) end
F.cabinet(at(-4, F1, -56, "S"), 6, 9)
F.stove(at(10, F1, -56, "S")); F.counter(at(24, F1, -56, "S"), 12); F.fridge(at(38, F1, -56, "S")); F.sink(at(18, F1, -56, "S"))
local boiler = model(STR, "Boiler")
cyl(boiler, CFrame.new(64, F1 + 5, -44), "Tank", 7, 10, 0, 0, 0, st(M.Metal, nil, C3(80, 76, 70)))
cyl(boiler, CFrame.new(64, 14, -44), "Flue", 1.4, 12, 0, 0, 0, CAMP.iron, D())
local bglow = box(DEC, "BoilerGlow", 60.6, F1 + 1, -44.8, 61, F1 + 2.4, -43.2, CAMP.ember, D())
light(bglow, 16, 1, C3(255, 140, 60))

-- UPSTAIRS: counselors' rooms (west and the back), the director's office (north-east), a bedroom (south-east)
for _, p in { { -66, 48, "E" }, { -66, -8, "E" }, { -64, -46, "E" }, { 30, -46, "W" } } do
	F.bed(at(p[1], F2, p[2], p[3]), 6, 9, Fab.blue)
end
F.dresser(at(-30, F2, 56, "N"), 6); F.wardrobe(at(-76, F2, 30, "E")); F.wardrobe(at(-20, F2, -56, "S"))
F.nightstand(at(-74, F2, 40, "E")); F.toyChest(at(-50, F2, -50, "N"))
-- the director's office: a big desk, an armchair, bookcases, a portrait, a safe
F.desk(at(46, F2, 50, "S"))
F.armchair(at(46, F2, 44, "N"), Fab.brown, 4)
F.bookshelf(at(76, F2, 40, "W"), 8, 10)
F.bookshelf(at(76, F2, 28, "W"), 8, 10)
poster(30, F2 + 10, 57.6, "N", 6, 8, C3(90, 70, 60), st(M.Metal, nil, C3(170, 140, 70))) -- (the director's portrait)
box(STR, "Safe", 18, F2, 52, 22, F2 + 4, 56, st(M.Metal, nil, C3(56, 58, 60)))
F.bed(at(70, F2, -8, "W"), 6, 9, Fab.green)
F.dresser(at(30, F2, -16, "S"), 6)
rug(-12, 40, 12, 56, F2, st(M.Fabric, nil, C3(110, 40, 34)), nil)

-- lights
for _, p in { { 0, 46 }, { 44, 46 }, { 44, 2 }, { -44, -38 }, { 22, -38 }, { 60, -38 } } do bulb(p[1], 21, p[2], 2, C3(255, 196, 136)) end
for _, p in { { -44, 40 }, { -44, -2 }, { 44, 40 }, { 44, -2 }, { -44, -40 }, { 40, -40 }, { 0, 46 } } do bulb(p[1], 42, p[2], 2, C3(255, 190, 130)) end
for _, p in { { -36, 40 }, { 20, 20 }, { -60, -40 }, { 40, 50 } } do blood(p[1], F1, p[2], 2) end
blood(-40, F2, 20, 2); blood(50, F2, 30, 2.4)
for _, p in { { -44, F1, 40 }, { 44, F1, 40 }, { 44, F1, -4 }, { -60, F1, -40 }, { -44, F2, 40 }, { 44, F2, 40 }, { -40, F2, -40 }, { 40, F2, -40 } } do gspawn(p[1], p[2], p[3]) end
keepClear(-6, 34, 6, 58, F1)
keepClear(-6, -6, 6, 34, F1)
keepClear(-16, -12, 16, 2, F2) -- (the top of the stair)
-- OUTSIDE (2026-11-19): the Caller's lodge. A steep cross gable with a great triangular window over the door, a
-- veranda of log columns along the front, a stone chimney up the west end, and the camp's only telephone line:
-- poles across the yard, the wire running into the lodge, a red phone booth by the path (its light still on).
local OUT = model(DEC, "Outside")
-- the cross gable (its ridge meets the main ridge at y TOP + 30)
extrude(STR, 0, 62, { { -31, TOP - 3.2 }, { 0, TOP + 30 }, { 31, TOP - 3.2 } }, T.roof,
	{ axis = "z", ends = T.ext, endsAt = { 59 }, endProf = { { -28, TOP }, { 0, TOP + 30 }, { 28, TOP } }, over = 0 })
do -- its triangular window: glass, log mullions, a warm glow behind
	local gy = TOP + 3
	tri(OUT, "GableGlass", Vector3.new(-18, gy, 60.3), Vector3.new(18, gy, 60.3), Vector3.new(0, gy + 20, 60.3), st(M.Neon, nil, C3(255, 132, 60)), 0.3, { deco = true, t = 0.45 })
	box(OUT, "GableMullion", -0.4, gy, 60.4, 0.4, gy + 20, 60.9, CAMP.logD, DECO)
	box(OUT, "GableMullion", -12, gy + 6.4, 60.4, 12, gy + 7.2, 60.9, CAMP.logD, DECO)
	box(OUT, "GableSill", -19, gy - 1, 60.2, 19, gy, 61.4, CAMP.logD, DECO)
	for _, sx in { -1, 1 } do
		local a, z = Vector3.new(sx * 18.6, gy, 60.6), Vector3.new(0, gy + 20.6, 60.6)
		part(OUT, "GableFrame", Vector3.new(0.8, 0.8, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), CAMP.logD, D())
		local e1, e2 = Vector3.new(sx * 32, TOP - 3.4, 61.2), Vector3.new(0, TOP + 30.4, 61.2)
		part(OUT, "BargeBoard", Vector3.new(0.6, 1.8, (e2 - e1).Magnitude), CFrame.lookAt((e1 + e2) / 2, e2), CAMP.log, D())
	end
end
campNameBoard("MAIN LODGE", CFrame.new(0, TOP - 2.4, 61), 24, 3.6)
-- logs along the walls and crossed log ends at the corners (two storeys of them)
do
	local holes = holesOf({ -60, -36, 36, 60 }, 6, 4, 14, F1, { 10, 15 })
	for _, h in holesOf({ -66, -44, 44, 66 }, 6, 4, 14, F2) do table.insert(holes, h) end
	logBands("x", 60, -80, 80, 3.5, TOP - 4, 3.4, 1, CAMP.logD, holes)
end
for _, c in { { -80, 60, -1, 1 }, { 80, 60, 1, 1 }, { -80, -60, -1, -1 }, { 80, -60, 1, -1 } } do cornerLogs(c[1], c[2], 3, TOP, c[3], c[4]) end
-- the veranda: a deck along the front, steps in the middle, log columns, a lean-to roof, rails, rocking chairs
box(STR, "VerandaDeck", -66, 0, 60, 66, 2.05, 74, CAMP.plank)
box(STR, "VerandaStep", -10, 0, 74, 10, 1.35, 76.5, CAMP.plank)
box(STR, "VerandaStep", -10, 0, 76.5, 10, 0.7, 79, CAMP.plank)
for x = -64, 64, 16 do cyl(OUT, CFrame.new(x, 11.5, 73), "Column", 1.8, 19, 0, 0, 0, CAMP.logD, D()) end
panel(OUT, "VerandaRoof", Vector3.new(0, 22.6, 60), Vector3.new(0, 19.6, 75.5), Vector3.new(1, 0, 0), 136, T.roof, 0.8, D())
for _, s2 in { -1, 1 } do
	box(OUT, "VerandaRail", s2 * 10, 5.2, 73.2, s2 * 66, 5.6, 73.6, CAMP.log, DECO)
	box(OUT, "VerandaRail", s2 * 10, 3.4, 73.2, s2 * 66, 3.7, 73.6, CAMP.log, DECO)
end
for _, p in { { -30, 67, 0.3 }, { -22, 67, -0.2 }, { 28, 66, 0.1 } } do
	local cf = CFrame.new(p[1], 2.05, p[2]) * CFrame.Angles(0, math.pi + p[3], 0)
	b(OUT, cf, "RockerSeat", 3, 0.4, 3, 0, 2.2, 0, CAMP.log, D())
	b(OUT, cf, "RockerBack", 3, 4, 0.4, 0, 4.2, 1.4, CAMP.log, D())
	for _, x in { -1.4, 1.4 } do b(OUT, cf, "Rocker", 0.3, 0.4, 4.4, x, 0.2, 0, CAMP.logD, D()) end
end
for _, x in { -20, 20, -50, 50 } do campLantern(OUT, x, 14, 60.2) end
-- the stone chimney up the west end, wider at the foot
box(OUT, "ChimneyFoot", -92, 0, 10, -80.5, 18, 30, CAMP.stone, DECO)
box(OUT, "Chimney", -90, 18, 13, -80.5, TOP + 38, 27, CAMP.stone, DECO)
box(OUT, "ChimneyCap", -90.6, TOP + 38, 12.4, -79.9, TOP + 39.2, 27.6, CAMP.iron, DECO)
washLight(-40, 92, Vector3.new(-20, TOP + 4, 60), C3(170, 186, 230), 95, 2)
washLight(40, 92, Vector3.new(20, TOP + 4, 60), C3(170, 186, 230), 95, 2)
-- THE TELEPHONE LINE: three poles across the west of the yard, the wire into the lodge's corner
local LINE = model(DEC, "PhoneLine")
local WIRE = st(M.SmoothPlastic, nil, C3(14, 14, 16))
local poles = { Vector3.new(-62, 0, 88), Vector3.new(-74, 0, 126), Vector3.new(-90, 0, 186) }
local tops = {}
for i, p in poles do
	cyl(LINE, CFrame.new(p.X, 13, p.Z), "Pole", 1.2, 26, 0, 0, 0, st(M.Wood, nil, C3(70, 56, 44)), D())
	box(LINE, "Crossarm", p.X - 3.4, 23, p.Z - 0.3, p.X + 3.4, 23.6, p.Z + 0.3, st(M.Wood, nil, C3(70, 56, 44)), DECO)
	for _, dx in { -2.6, 0, 2.6 } do box(LINE, "Insulator", p.X + dx - 0.25, 23.6, p.Z - 0.25, p.X + dx + 0.25, 24.4, p.Z + 0.25, st(M.Glass, nil, C3(90, 140, 120)), DECO) end
	tops[i] = Vector3.new(p.X, 24.2, p.Z)
end
local function wire(a: Vector3, z: Vector3, sag: number)
	local prev = a
	for k = 1, 6 do
		local t = k / 6
		local q = a:Lerp(z, t) - Vector3.new(0, sag * 4 * t * (1 - t), 0)
		part(LINE, "Wire", Vector3.new(0.12, 0.12, (q - prev).Magnitude), CFrame.lookAt((prev + q) / 2, q), WIRE, D())
		prev = q
	end
end
for _, dx in { -2.6, 0, 2.6 } do
	for i = 1, #tops - 1 do wire(tops[i] + Vector3.new(dx, 0, 0), tops[i + 1] + Vector3.new(dx, 0, 0), 2.2) end
end
wire(tops[1], Vector3.new(-78, 30, 60.6), 1.6)
box(LINE, "WallBox", -79, 28.6, 60, -77, 31, 61, st(M.Metal, nil, C3(60, 60, 58)), DECO)
-- THE PHONE BOOTH by the path, its light on
do
	local pb = model(DEC, "PhoneBooth")
	local cf = CFrame.new(16, 0, 74) * CFrame.Angles(0, math.pi + 0.25, 0)
	local REDS = st(M.SmoothPlastic, nil, C3(160, 30, 28))
	b(pb, cf, "Base", 4.4, 0.4, 4.4, 0, 0.2, 0, REDS, D())
	for _, c in { { -2, -2 }, { 2, -2 }, { -2, 2 }, { 2, 2 } } do b(pb, cf, "Post", 0.5, 9, 0.5, c[1], 4.9, c[2], REDS, D()) end
	b(pb, cf, "Roof", 4.8, 0.8, 4.8, 0, 9.6, 0, REDS, D())
	b(pb, cf, "Dome", 3.6, 0.6, 3.6, 0, 10.3, 0, REDS, D())
	for _, side in { { 0, -2, 4, 0.2 }, { -2, 0, 0.2, 4 }, { 2, 0, 0.2, 4 } } do
		b(pb, cf, "Pane", side[3], 7.6, side[4], side[1], 4.8, side[2], st(M.Glass, nil, C3(150, 170, 160)), { deco = true, t = 0.55 })
	end
	b(pb, cf, "BackPanel", 4, 8, 0.3, 0, 4.8, 2, REDS, D())
	local sgn = b(pb, cf, "TelephoneSign", 3.6, 0.7, 0.2, 0, 8.8, -2.2, st(M.Neon, nil, C3(255, 240, 210)), D())
	local _ = sgn
	b(pb, cf, "Phone", 0.9, 1.4, 0.6, 0, 5.6, 1.6, st(M.SmoothPlastic, nil, C3(20, 20, 20)), D())
	b(pb, cf, "Receiver", 0.4, 1.6, 0.4, 0.8, 4.2, 1.4, st(M.SmoothPlastic, nil, C3(20, 20, 20)), D())
	local g = b(pb, cf, "BoothLight", 0.6, 0.3, 0.6, 0, 9.1, 0, st(M.Neon, nil, C3(255, 236, 200)), D())
	light(g, 18, 1.2, C3(255, 230, 190))
end
-- the camp office's notice board by the steps
do
	for _, x in { -18, -12 } do box(OUT, "BoardLeg", x - 0.3, 0, 80, x + 0.3, 7, 80.6, CAMP.logD, DECO) end
	box(OUT, "NoticeBoard", -19, 3.6, 80.6, -11, 7.4, 81, CAMP.log, DECO)
	for k = 0, 3 do box(OUT, "Notice", -18.4 + k * 1.9, 4.4 + (k % 2) * 1.2, 81, -17 + k * 1.9, 6 + (k % 2) * 1.2, 81.1, st(M.SmoothPlastic, nil, C3(220, 214, 190)), DECO) end
end
campYard("MAIN LODGE")
return endMap()
