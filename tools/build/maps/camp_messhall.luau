-- THE MESS HALL (Camp Hollowmere, building 3: THE BURNED COUNSELOR, who sets the place on fire with the wildfire
-- system). A long dining hall (four long tables and their benches, a stone fireplace, the camp's banner over the
-- serving hatch), and behind the hatch the kitchen (stoves, counters, a butcher block, a huge pot), the pantry and
-- the walk-in cooler. Scorch marks round the kitchen: it has burnt before. One storey, 24 high.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_messhall.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local SOOT = st(M.SmoothPlastic, nil, C3(20, 16, 14))
beginMap("Camp_MessHall", campTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(100, 70, 46)), lanternColor = C3(255, 190, 110) }))
-- (2026-11-19) its own shape: a long hall under a hip roof, a bell cupola on the ridge, a burnt corner
local TOP = shell2({ H = 24, roof = "hip", rise = 24, over = 3, roofStyle = st(M.Slate, nil, C3(48, 42, 38)),
	front1 = { -60, -36, 36, 60 }, back1 = { -60, -30, 54 }, left1 = { 44, 20, -4, -40 }, right1 = { 44, -4, -40 }, win = { w = 6, b = 5, t = 13 } })
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
-- OUTSIDE (2026-11-19): the Burned Counselor's mess hall. A hip roof with the dinner bell in a cupola on the ridge,
-- a stone chimney, a gabled canopy over the door with the iron triangle, and the corner of the roof that burnt:
-- charred, the rafters showing, still smoking. Soot over the windows he set alight.
local OUT = model(DEC, "Outside")
local function roofY(z: number): number return TOP + (60 - z) * 0.4 end -- (the front slope: rise 24 over 60)
-- the chimney up the east end
box(OUT, "Chimney", 81, 0, 17, 89, TOP + 26, 29, CAMP.stone, DECO)
box(OUT, "ChimneyCap", 80.4, TOP + 26, 16.4, 89.6, TOP + 27, 29.6, CAMP.iron, DECO)
-- the bell cupola on the ridge (x -20..20 at TOP + 24)
do
	local ry = TOP + 24
	local cu = model(OUT, "BellCupola")
	for _, c in { { -3.5, -3.5 }, { 3.5, -3.5 }, { -3.5, 3.5 }, { 3.5, 3.5 } } do box(cu, "Post", c[1] - 0.4, ry - 1, c[2] - 0.4, c[1] + 0.4, ry + 7, c[2] + 0.4, CAMP.logD, DECO) end
	box(cu, "Floor", -4.2, ry - 1, -4.2, 4.2, ry, 4.2, CAMP.logD, DECO)
	local apex = Vector3.new(0, ry + 12, 0)
	local cs = { Vector3.new(-5.5, ry + 7, -5.5), Vector3.new(5.5, ry + 7, -5.5), Vector3.new(5.5, ry + 7, 5.5), Vector3.new(-5.5, ry + 7, 5.5) }
	for k = 1, 4 do tri(cu, "CupolaRoof", cs[k], cs[k % 4 + 1], apex, T.roof, 0.6, D()) end
	cyl(cu, CFrame.new(0, ry + 4.2, 0), "Bell", 3, 3, 0, 0, 0, st(M.Metal, nil, C3(150, 120, 60)), D())
	cyl(cu, CFrame.new(0, ry + 2.7, 0), "BellLip", 3.8, 0.4, 0, 0, 0, st(M.Metal, nil, C3(150, 120, 60)), D())
end
-- the burnt corner on the front slope (x -58..-30, z 22..46): charred shingles, the rafters through, embers, smoke
do
	local bz = model(OUT, "BurntRoof")
	panel(bz, "Char", Vector3.new(-44, roofY(46) + 0.35, 46), Vector3.new(-44, roofY(22) + 0.35, 22), Vector3.new(1, 0, 0), 28, SOOT, 0.3, D())
	panel(bz, "Hole", Vector3.new(-44, roofY(40) + 0.55, 40), Vector3.new(-44, roofY(28) + 0.55, 28), Vector3.new(1, 0, 0), 14, st(M.SmoothPlastic, nil, C3(6, 4, 4)), 0.3, D())
	for x = -54, -34, 5 do
		local a, z = Vector3.new(x, roofY(44) + 0.6, 44), Vector3.new(x, roofY(24) + 1.2, 24)
		part(bz, "CharredRafter", Vector3.new(1.2, 1.2, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), st(M.Wood, nil, C3(22, 16, 12)), D())
	end
	for k = 0, 4 do
		local e = box(bz, "Ember", -50 + k * 4, roofY(34) + 0.7, 33 - k, -49 + k * 4, roofY(34) + 1.1, 34 - k, CAMP.ember, DECO)
		if k == 2 then light(e, 34, 1.8, C3(255, 120, 50)) end
		if k % 2 == 0 then -- (it still burns: small flames along the hole)
			local f = Instance.new("Fire"); f.Size = 4 + k; f.Heat = 7; f.Color = C3(255, 130, 50); f.SecondaryColor = C3(190, 50, 20); f.Parent = e
		end
	end
	local sm = box(bz, "SmokeSource", -45, roofY(34) + 1, 33, -43, roofY(34) + 2, 35, SOOT, { deco = true, t = 1 })
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(C3(40, 36, 34), C3(80, 76, 72))
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1) })
	pe.Size = NumberSequence.new(3, 12)
	pe.Lifetime = NumberRange.new(5, 7)
	pe.Rate = 4
	pe.Speed = NumberRange.new(3, 5)
	pe.SpreadAngle = Vector2.new(12, 12)
	pe.Acceleration = Vector3.new(1.5, 0.6, 0)
	pe.Parent = sm
end
-- soot up the front wall over the windows nearest the burn, blackened siding at that corner
for _, x in { -60, -36 } do part(OUT, "Soot", Vector3.new(8, 12, 0.2), CFrame.new(x, 20, 60.3), SOOT, { deco = true, t = 0.25 }) end
part(OUT, "Soot", Vector3.new(14, 22, 0.2), CFrame.new(-74, 13, 60.3), SOOT, { deco = true, t = 0.3 })
part(OUT, "Soot", Vector3.new(0.2, 20, 24), CFrame.new(-80.3, 14, 40), SOOT, { deco = true, t = 0.3 })
-- the gabled canopy over the door, the dinner triangle, the name
for _, x in { -8, 8 } do cyl(OUT, CFrame.new(x, 8.5, 71), "CanopyPost", 1.2, 15, 0, 0, 0, CAMP.logD, D()) end
extrude(OUT, 60, 73, { { -10, 15.6 }, { 0, 21 }, { 10, 15.6 } }, T.roof, { axis = "z", ends = CAMP.log, endsAt = { 72.6 }, th = 0.8, over = 0, panelO = D() })
campNameBoard("MESS HALL", CFrame.new(0, 17.4, 73), 14, 2.4)
do
	local tg = model(OUT, "DinnerTriangle")
	local IRONB = st(M.Metal, nil, C3(70, 66, 60))
	box(tg, "Hook", -0.1, 12.6, 72.4, 0.1, 15.6, 72.6, IRONB, DECO)
	part(tg, "Side", Vector3.new(0.3, 3.6, 0.3), CFrame.new(-0.9, 11, 72.5) * CFrame.Angles(0, 0, -0.5), IRONB, D())
	part(tg, "Side", Vector3.new(0.3, 3.6, 0.3), CFrame.new(0.9, 11, 72.5) * CFrame.Angles(0, 0, 0.5), IRONB, D())
	box(tg, "Base", -1.8, 9.4, 72.35, 1.8, 9.7, 72.65, IRONB, DECO)
end
for _, x in { -14, 14 } do campLantern(OUT, x, 11, 60.2) end
washLight(-34, 84, Vector3.new(-30, TOP + 6, 50), C3(170, 186, 230), 80, 2)
washLight(34, 84, Vector3.new(30, TOP + 6, 50), C3(170, 186, 230), 80, 2)
-- kitchen vent pipes on the back slope
for _, x in { -64, -50 } do
	cyl(OUT, CFrame.new(x, TOP + 12, -40), "VentPipe", 1.6, 12, 0, 0, 0, CAMP.iron, D())
	cyl(OUT, CFrame.new(x, TOP + 18.4, -40), "VentCap", 2.6, 0.8, 0, 0, 0, CAMP.iron, D())
end
-- THE MESS HALL'S YARD: picnic tables, the menu board, trash cans (one still smoking), crates of milk bottles
local YD = model(DEC, "MessYard")
for _, p in { { -32, 86, 0.1 }, { 30, 92, -0.15 } } do
	local cf = CFrame.new(p[1], 0, p[2]) * CFrame.Angles(0, p[3], 0)
	b(YD, cf, "Top", 12, 0.4, 4, 0, 3.2, 0, CAMP.plank, D())
	for _, z in { -3, 3 } do b(YD, cf, "Seat", 12, 0.3, 1.2, 0, 1.8, z, CAMP.plank, D()) end
	for _, x in { -5, 5 } do b(YD, cf, "Leg", 0.4, 3, 3, x, 1.5, 0, CAMP.logD, D()) end
end
do
	local ez = CFrame.new(16, 0, 70) * CFrame.Angles(0, -0.3, 0)
	part(YD, "EaselLeg", Vector3.new(0.3, 7, 0.3), ez * CFrame.new(-1.6, 3.4, 0) * CFrame.Angles(0.15, 0, 0.12), CAMP.logD, D())
	part(YD, "EaselLeg", Vector3.new(0.3, 7, 0.3), ez * CFrame.new(1.6, 3.4, 0) * CFrame.Angles(0.15, 0, -0.12), CAMP.logD, D())
	part(YD, "Board", Vector3.new(4.6, 5.4, 0.3), ez * CFrame.new(0, 4.6, -0.5) * CFrame.Angles(0.15, 0, 0), st(M.Slate, nil, C3(30, 34, 30)), D())
	sign(YD, "TODAY: SLOPPY JOES", ez * CFrame.new(0, 5.2, -0.75) * CFrame.Angles(0.15, math.pi, 0), 4, 1.4, st(M.Slate, nil, C3(30, 34, 30)), C3(230, 230, 220), Enum.Font.SpecialElite)
end
for i, p in { { -20, 64 }, { -24, 65 } } do cyl(YD, CFrame.new(p[1], 2, p[2]), "TrashCan", 3, 4, 0, 0, 0, st(M.Metal, nil, C3(90, 92, 88)), D()) end
do
	cyl(YD, CFrame.new(44, 2, 74), "BurntBarrel", 3.2, 4, 0, 0, 0, SOOT, D())
	local fx = box(YD, "BarrelEmbers", 43, 3.6, 73, 45, 4, 75, CAMP.ember, DECO)
	light(fx, 16, 1, C3(255, 120, 50))
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"; pe.Color = ColorSequence.new(C3(50, 46, 44))
	pe.Transparency = NumberSequence.new(0.6, 1); pe.Size = NumberSequence.new(1.5, 5); pe.Lifetime = NumberRange.new(3, 4)
	pe.Rate = 3; pe.Speed = NumberRange.new(2, 3); pe.Parent = fx
end
for k = 0, 3 do
	box(YD, "MilkCrate", -46 + (k % 2) * 2.6, 0 + math.floor(k / 2) * 1.8, 64, -43.6 + (k % 2) * 2.6, 1.8 + math.floor(k / 2) * 1.8, 66.4, st(M.SmoothPlastic, nil, C3(170, 40, 34)), DECO)
end
campYard("MESS HALL")
return endMap()
