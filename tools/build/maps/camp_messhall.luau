-- THE MESS HALL (Camp Hollowmere, building 3: THE BURNED COUNSELOR, who sets the place on fire with the wildfire
-- system). A long dining hall (four long tables and their benches, a stone fireplace, the camp's banner over the
-- serving hatch), and behind the hatch the kitchen (stoves, counters, a butcher block, a huge pot), the pantry and
-- the walk-in cooler. Scorch marks round the kitchen: it has burnt before. One storey, 24 high.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_messhall.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local SOOT = st(M.SmoothPlastic, nil, C3(20, 16, 14))
beginMap("Camp_MessHall", campTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(100, 70, 46)), lanternColor = C3(255, 190, 110) }))
shell({ two = false, H = 24, roof = "gable", pitch = 0.45, front1 = { -60, -36, 36, 60 }, back1 = { -60, -30, 54 }, left1 = { 44, 20, -4, -40 }, right1 = { 44, -4, -40 },
	winW = 6, winB = 5, winT = 13 })
local inn = model(STR, "Interior")
local I = INT()
-- the kitchen wall with its serving hatch, the pantry and the cooler behind
wall(inn, "KitchenWall", "x", -10, -78, 78, F1, 24, { dr(-62, 8, 12), { c = -14, w = 28, b = 4, t = 10, kind = "open" }, dr(54, 8, 12) }, I)
wall(inn, "PantryWall", "z", 30, -58, -10.6, F1, 24, { dr(-46, 7, 11), dr(-20, 7, 11) }, I)
wall(inn, "CoolerWall", "x", -34, 30.6, 78, F1, 24, { dr(54, 7, 11) }, I)

-- THE DINING HALL: four long tables with benches (two columns), the serving counter under the hatch
for _, x in { -40, 22 } do
	for _, z in { 10, 36 } do
		F.table(at(x, F1, z, "E"), 18, 5, 3.2, Wd.mid, "Table")
		F.bench(at(x, F1, z - 4, "N"), 16)
		F.bench(at(x, F1, z + 4, "S"), 16)
	end
end
local sc = model(STR, "ServingCounter")
box(sc, "Counter", -28, F1, -9.4, 0, F1 + 3.8, -7, CAMP.logD)
box(sc, "CounterTop", -28.4, F1 + 3.8, -9.6, 0.4, F1 + 4.2, -6.6, st(M.Metal, nil, C3(150, 150, 146)))
for i = 0, 4 do box(DEC, "Tray", -26 + i * 5.4, F1 + 4.2, -8.8, -23 + i * 5.4, F1 + 4.4, -7.4, st(M.Metal, nil, C3(170, 170, 166)), D()) end
-- the camp's banner over the hatch
sign(DEC, "CAMP HOLLOWMERE  -  MESS HALL", CFrame.new(-14, 18, -9.1) * CFrame.Angles(0, math.pi, 0), 34, 3.6, st(M.Fabric, nil, C3(60, 90, 56)), C3(232, 220, 180), Enum.Font.SpecialElite)
-- the stone fireplace on the east wall
local fp = model(STR, "Fireplace")
box(fp, "Breast", 72, F1, 14, 78, F1 + 22, 32, CAMP.stone)
box(fp, "Hearth", 68, F1, 16, 72, F1 + 0.8, 30, CAMP.stone)
box(fp, "Mantel", 70.5, F1 + 9, 13.5, 72.5, F1 + 9.8, 32.5, CAMP.logD)
box(DEC, "FireboxDark", 71.6, F1 + 0.8, 18.5, 72.1, F1 + 7, 27.5, SOOT, D())
local ember = box(DEC, "FireEmbers", 70, F1 + 0.8, 19.5, 71.6, F1 + 1.6, 26.5, CAMP.ember, D())
light(ember, 26, 1.4, C3(255, 140, 60))
box(DEC, "ChimneyStack", 76, 26, 18, 84, 50, 28, CAMP.stone, D())
F.armchair(at(60, F1, 18, "E"), Fab.red, 4)
F.armchair(at(60, F1, 30, "E"), Fab.green, 4)
-- a piano and a stage corner at the front left, the camp's trophy shelf
F.piano(at(-70, F1, 52, "E"))
box(STR, "Stage", -78, F1, 40, -56, F1 + 1.6, 58, CAMP.plank)
F.bookshelf(at(-40, F1, 57, "N"), 8, 8)
F.clock(at(-20, F1, 57, "N"))

-- THE KITCHEN: stoves along the back wall, counters, fridges, a butcher block, the huge pot
for _, x in { -70, -60, -50 } do F.stove(at(x, F1, -56, "S")) end
local pot = model(DEC, "StockPot")
cyl(pot, CFrame.new(-60, F1 + 5.6, -56.5), "Pot", 4, 3, 0, 0, 0, CAMP.iron, D())
F.counter(at(-76, F1, -36, "E"), 18)
F.counter(at(-36, F1, -56, "S"), 14)
for _, x in { -26, -20 } do F.sink(at(x, F1, -56, "S")) end
F.fridge(at(20, F1, -56, "S"))
F.fridge(at(26, F1, -56, "S"))
G2.steelTable(at(-40, F1, -34, "N"))
F.cabinet(at(10, F1, -56, "S"), 6, 9)
for _, p in { { 0, -20 }, { 20, -30 } } do F.barrel(at(p[1], F1, p[2], "N")) end
-- scorch marks: it has burnt before
for _, p in { { -66, -50, 9 }, { -54, -46, 6 }, { -40, -24, 7 }, { 4, -14, 5 } } do
	box(DEC, "Scorch", p[1] - p[3] / 2, F1 + 0.06, p[2] - p[3] / 2, p[1] + p[3] / 2, F1 + 0.1, p[2] + p[3] / 2, SOOT, { deco = true, t = 0.25 })
end
for _, x in { -64, -52 } do box(DEC, "SootStreak", x - 3, F1 + 4, -57.75, x + 3, F1 + 18, -57.6, SOOT, { deco = true, t = 0.35 }) end
-- the pantry (south-east): sacks, crates, shelves
for _, p in { { 40, -54 }, { 50, -54 }, { 60, -40 }, { 72, -50 }, { 66, -54 } } do F.crate(at(p[1], F1, p[2], "N"), 3) end
F.cabinet(at(76, F1, -44, "W"), 6, 9)
for k = 0, 2 do box(DEC, "Sack", 34 + k * 3.2, F1, -40, 36.6 + k * 3.2, F1 + 3, -37.4, st(M.Fabric, nil, C3(160, 140, 100)), D()) end
-- the walk-in cooler (north-east): cold light, shelves, crates
F.cabinet(at(76, F1, -24, "W"), 6, 9)
F.cabinet(at(60, F1, -12.5, "N"), 6, 9)
F.crate(at(44, F1, -24, "N"), 3.5)
local cold = box(DEC, "ColdLight", 54, 21, -24, 56, 21.4, -22, st(M.Neon, nil, C3(190, 220, 255)), D())
light(cold, 26, 1.1, C3(170, 210, 255))

-- lights
for _, p in { { -40, 23 }, { 22, 23 }, { -40, 50 }, { 22, 50 }, { -10, 2 } } do bulb(p[1], 21, p[2], 3, C3(255, 200, 140)) end
for _, x in { -60, -30, 10 } do bulb(x, 21, -34, 3, C3(255, 190, 120)) end
bulb(54, 21, -46, 3, C3(255, 200, 140))
for _, p in { { -20, 22 }, { 40, 48 }, { -50, -40 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 23 }, { 22, 48 }, { -50, -34 }, { 54, -46 }, { 54, -22 }, { 60, 24 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
campNameBoard("MESS HALL")
campYard("MESS HALL")
return endMap()
