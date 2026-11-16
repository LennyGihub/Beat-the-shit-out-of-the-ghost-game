-- Dollmaker's Factory: two full floors of rooms around a double-height production hall.
-- Ground: reception + doll showroom (west front), production hall with the conveyor (centre front, open to the roof,
-- catwalk round it upstairs), sewing room (east front); a corridor; kiln, paint shop, storage, break room, washroom.
-- Upper: director's office (west front), the nursery (east front); a corridor; archive, doll surgery, mannequin room,
-- workers' bunk room. Stairs in the sewing room's corner (east).
local C3 = Color3.fromRGB
beginMap("Factory", {
	floor = st(M.Concrete, nil, C3(120, 116, 110)), floor2 = st(M.DiamondPlate, nil, C3(100, 100, 104)),
	inner = st(M.Brick, nil, C3(150, 110, 96)), wainscot = st(M.CorrodedMetal, nil, C3(90, 80, 70)), wain = true, wainH = 3,
	ext = st(M.Brick, nil, C3(110, 64, 52)), trim = st(M.CorrodedMetal, nil, C3(100, 80, 64)), ceiling = st(M.CorrodedMetal, nil, C3(80, 74, 70)),
	roof = st(M.CorrodedMetal, nil, C3(90, 86, 82)), found = st(M.Concrete, nil, C3(100, 96, 92)), door = st(M.CorrodedMetal, nil, C3(110, 70, 50)),
	porch = st(M.Concrete, nil, C3(120, 116, 110)), stairs = st(M.DiamondPlate, nil, C3(100, 100, 104)),
})
shell({ two = true, roof = "gable", pitch = 0.22 })
local inn = model(STR, "Interior")
local I = INT()
local RUST = st(M.CorrodedMetal, nil, C3(96, 70, 54))
local STEEL = st(M.DiamondPlate, nil, C3(110, 110, 114))
local PAINT = { C3(190, 40, 50), C3(60, 110, 200), C3(230, 190, 60), C3(70, 160, 90), C3(220, 220, 220) }

---------------------------------------------------------------- walls
-- ground floor: corridor z -8.6..8.6
wall(inn, "G_corN", "x", 8.6, -78, 78, F1, 20, { dr(-54, 7), dr(0, 24, 15), dr(54, 7) }, I)
wall(inn, "G_corS", "x", -8.6, -78, 78, F1, 20, { dr(-62, 7), dr(-31, 7), dr(0, 8), dr(31, 7), dr(62, 7) }, I)
wall(inn, "G_frontW", "z", -30, 8.6, 58, F1, 20, { dr(40, 7) }, I)
wall(inn, "G_frontE", "z", 30, 8.6, 58, F1, 20, { dr(40, 7) }, I)
for _, x in { -46, -16, 16, 46 } do wall(inn, "G_back" .. x, "z", x, -58, -8.6, F1, 20, {}, I) end
-- upper floor: back half and the front side wings; the hall in the middle stays open to the roof
slab(-78, -58, 78, 8.6)
slab(-78, 8.6, -30, 58)
slab(30, 8.6, 69.4, 58)
slab(69.4, 8.6, 78, 24)
stairs(70, 77.4, 56)
railing("x", 24.3, 69.6, 78, F2)
wall(inn, "U_corN_W", "x", 8.6, -78, -30, F2, 20, { dr(-54, 7) }, I)
wall(inn, "U_corN_E", "x", 8.6, 30, 69, F2, 20, { dr(50, 7) }, I)
railing("x", 8.4, -30, 30, F2) -- the catwalk edge over the production hall
wall(inn, "U_hallW", "z", -30, 8.6, 58, F2, 20, {}, I)
wall(inn, "U_hallE", "z", 30, 8.6, 58, F2, 20, {}, I)
wall(inn, "U_corS", "x", -8.6, -78, 78, F2, 20, { dr(-59, 7), dr(-20, 7), dr(20, 7), dr(59, 7) }, I)
for _, x in { -40, 0, 40 } do wall(inn, "U_back" .. x, "z", x, -58, -8.6, F2, 20, {}, I) end

---------------------------------------------------------------- production hall (centre front, double height)
local cv = model(STR, "Conveyor")
box(cv, "Belt", -24, F1, 26, 24, F1 + 3.2, 32, st(M.Rubber, nil, C3(30, 30, 32)))
for x = -22, 22, 4 do box(cv, "Roller", x - 0.3, F1 + 3.2, 25.8, x + 0.3, F1 + 3.5, 32.2, STEEL, DECO) end
for x = -20, 20, 8 do doll(DEC, CFrame.new(x, F1 + 3.5, 29) * CFrame.Angles(0, math.random() * 6, 0), 0.9, Color3.fromHSV(math.random(), 0.5, 0.6)) end
box(cv, "Hopper", -27, F1, 24, -22, F1 + 9, 34, RUST)
box(cv, "Press", 20, F1, 23, 27, F1 + 11, 35, RUST)
box(cv, "PressHead", 21, F1 + 5, 25, 26, F1 + 7, 33, STEEL, DECO)
for _, x in { -18, -6, 6, 18 } do G2.workbench(at(x, F1, 16, "N"), 8); G2.workbench(at(x, F1, 44, "S"), 8) end
for _, x in { -24, -16, 16, 24 } do F.chair(at(x, F1, 19.5, "S"), Wd.mid, Fab.grey) end
for _, p in { { -24, 52 }, { -19, 54 }, { 22, 52 } } do F.crate(at(p[1], F1, p[2], "N"), 3.5) end
F.barrel(at(26, F1, 12, "N")); F.barrel(at(-26, F1, 12, "N"))
for _, p in { { -14, 36 }, { 2, 40 }, { 15, 22 } } do
	local h = model(DEC, "HangingDoll")
	box(h, "Rope", p[1] - 0.1, 22, p[2] - 0.1, p[1] + 0.1, 42, p[2] + 0.1, st(M.Fabric, nil, C3(120, 100, 70)), DECO)
	doll(h, CFrame.new(p[1], 19.6, p[2]) * CFrame.Angles(0, math.random() * 6, 0), 1.3, C3(150, 40, 60))
end
for _, x in { -18, 0, 18 } do bulb(x, 42, 22, 8, C3(255, 200, 150)); bulb(x, 42, 44, 8, C3(255, 200, 150)) end

---------------------------------------------------------------- reception + doll showroom (west front)
F.counter(at(-54, F1, 30, "S"), 12)
F.chair(at(-54, F1, 26, "N"), Wd.mid, Fab.red)
for _, z in { 46, 52 } do F.sofa(at(-70, F1, z, "E"), Fab.red, 7) end
F.coffeeTable(at(-64, F1, 49, "N"))
for _, p in { { -40, 50 }, { -46, 50 }, { -36, 20 } } do F.pedestal(at(p[1], F1, p[2], "N")) end
for _, p in { { -40, 50 }, { -46, 50 }, { -36, 20 } } do doll(DEC, CFrame.new(p[1], F1 + 4.2, p[2]), 1, C3(120, 30, 70)) end
G2.dollShelf(at(-70, F1, 14, "E")); G2.dollShelf(at(-70, F1, 34, "E"))
F.clock(at(-76, F1, 24, "E")); F.floorLamp(at(-74, F1, 54, "N"))
rug(-62, 40, -46, 56, F1, st(M.Fabric, nil, C3(110, 30, 34)), st(M.Fabric, nil, C3(180, 150, 80)))
poster(-54, 12, 57.7, "N", 12, 4, C3(200, 60, 80))
fluoro(-54, 21, 30); fluoro(-54, 21, 48)

---------------------------------------------------------------- sewing room (east front, stairs in its corner)
for _, z in { 18, 32, 46 } do
	F.table(at(46, F1, z, "N"), 10, 4, 3.4, Wd.mid, "SewingTable")
	for _, x in { 42, 50 } do F.chair(at(x, F1, z - 3.5, "N"), Wd.mid, Fab.blue) end
end
for i = 0, 5 do
	local c = PAINT[i % #PAINT + 1]
	cyl(DEC, CFrame.new(36 + i * 1.6, F1 + 0.8, 55) * CFrame.Angles(0, 0, math.pi / 2), "FabricRoll", 1.4, 4, 0, 0, 0, st(M.Fabric, nil, c), DECO)
end
for _, z in { 20, 40 } do doll(DEC, CFrame.new(62, F1, z) * CFrame.Angles(0, -math.pi / 2, 0), 2.2, C3(220, 210, 200)) end -- dress forms
F.cabinet(at(34, F1, 54, "S"), 6, 9)
fluoro(48, 21, 24); fluoro(48, 21, 44)

---------------------------------------------------------------- back rooms, ground floor
-- kiln (x -78..-46): the furnace glows
local kiln = box(STR, "Kiln", -76, F1, -56, -64, F1 + 12, -44, st(M.Brick, nil, C3(80, 50, 40)))
local mouth = box(DEC, "KilnFire", -66, F1 + 2, -51, -63.6, F1 + 6, -47, st(M.Neon, nil, C3(255, 120, 40)), DECO)
light(mouth, 26, 2, C3(255, 120, 50))
for _, p in { { -54, -50 }, { -50, -54 }, { -56, -16 } } do F.barrel(at(p[1], F1, p[2], "N")) end
for _, p in { { -72, -20 }, { -72, -14 } } do F.crate(at(p[1], F1, p[2], "N"), 3) end
G2.steelTable(at(-58, F1, -32, "E"))
-- paint shop (x -46..-16)
for _, z in { -50, -30 } do G2.workbench(at(-31, F1, z, "N"), 10) end
for i = 1, 10 do
	local x, z = -44 + math.random() * 26, -56 + math.random() * 44
	local s = 1 + math.random() * 2.5
	box(DEC, "PaintSplat", x - s, F1 + 0.06, z - s * 0.7, x + s, F1 + 0.1, z + s * 0.7, st(M.SmoothPlastic, nil, PAINT[math.random(1, #PAINT)]), DECO)
end
for i = 1, 6 do
	cyl(DEC, CFrame.new(-44 + i * 1.6, F1 + 0.7, -56), "PaintCan", 1.2, 1.4, 0, 0, 0, st(M.Metal, nil, PAINT[(i % #PAINT) + 1]), DECO)
end
for _, z in { -40, -20 } do doll(DEC, CFrame.new(-20, F1 + 3.6, z) * CFrame.Angles(0, math.pi / 2, 0), 0.9, C3(240, 240, 240)) end
-- storage (x -16..16)
for _, x in { -12, -4, 4, 12 } do
	F.crate(at(x, F1, -50, "N"), 3.5); F.crate(at(x, F1 + 3.5, -50, "N"), 3)
end
for _, x in { -10, 10 } do G2.dollShelf(at(x, F1, -30, "S")) end
F.barrel(at(0, F1, -20, "N"))
-- break room (x 16..46)
F.diningTable(at(31, F1, -30, "N"), 10)
F.fridge(at(44, F1, -55, "W")); F.stove(at(38, F1, -56, "N")); F.sink(at(32, F1, -56, "N")); F.counter(at(24, F1, -56, "N"), 6)
G2.vending(at(19, F1, -14, "E"), C3(40, 90, 160))
F.tv(at(44, F1, -14, "S"))
-- washroom (x 46..78)
for _, x in { 52, 60, 68 } do F.toilet(at(x, F1, -55, "N")) end
for _, x in { 52, 60, 68 } do box(inn, "Stall", x + 3.5, F1, -58, x + 3.8, F1 + 8, -50, st(M.Metal, nil, C3(120, 130, 120))) end
for _, x in { 56, 66 } do F.sink(at(x, F1, -14, "S")) end
for _, x in { 74, 76.5 } do G2.locker(at(x, F1, -30, "W"), C3(80, 100, 90)) end
for _, x in { -62, -31, 0, 31, 62 } do fluoro(x, 21, -33) end
fluoro(-40, 21, 0); fluoro(0, 21, 0); fluoro(40, 21, 0)

---------------------------------------------------------------- upper floor
-- director's office (west front)
F.desk(at(-54, F2, 40, "S")); F.armchair(at(-54, F2, 45, "S"), Fab.brown, 4)
F.chair(at(-58, F2, 34, "N"), Wd.dark, Fab.red); F.chair(at(-50, F2, 34, "N"), Wd.dark, Fab.red)
F.bookshelf(at(-77, F2, 30, "E"), 8, 12); F.bookshelf(at(-77, F2, 44, "E"), 8, 12)
F.globe(at(-40, F2, 52, "N")); F.clock(at(-34, F2, 20, "W")); F.cabinet(at(-70, F2, 14, "N"), 6, 9)
rug(-64, 28, -44, 50, F2, st(M.Fabric, nil, C3(60, 30, 40)), st(M.Fabric, nil, C3(170, 140, 70)))
poster(-54, F2 + 10, 57.7, "N", 8, 5, C3(120, 80, 60))
fluoro(-54, 42, 34)
-- the nursery (east front)
for _, x in { 36, 46, 56 } do F.crib(at(x, F2, 50, "S")) end
F.rockingChair(at(60, F2, 20, "W")); F.toyChest(at(40, F2, 14, "N")); F.toyChest(at(52, F2, 14, "N"))
for i = 1, 8 do doll(DEC, CFrame.new(34 + math.random() * 30, F2, 18 + math.random() * 26) * CFrame.Angles(0, math.random() * 6, 0), 0.8, Color3.fromHSV(math.random(), 0.4, 0.7)) end
rug(38, 24, 60, 42, F2, st(M.Fabric, nil, C3(190, 150, 160)), st(M.Fabric, nil, C3(120, 80, 90)))
bulb(48, 42, 32, 6, C3(255, 180, 190))
-- archive (x -78..-40)
for _, z in { -50, -38, -26, -14 } do F.bookshelf(at(-66, F2, z, "S"), 10, 12) end
F.cabinet(at(-46, F2, -55, "N"), 6, 9); F.cabinet(at(-46, F2, -40, "W"), 6, 9)
F.desk(at(-46, F2, -20, "W"))
-- doll surgery (x -40..0)
G2.steelTable(at(-28, F2, -40, "N")); G2.steelTable(at(-12, F2, -40, "N"))
G2.gurney(at(-20, F2, -22, "E"))
for _, x in { -28, -12 } do doll(DEC, CFrame.new(x, F2 + 3.4, -40) * CFrame.Angles(math.pi / 2, 0, 0), 1, C3(220, 200, 190)) end
F.cabinet(at(-36, F2, -56, "N"), 6, 9)
blood(-20, F2, -34, 2.4)
-- mannequin room (x 0..40)
for _, x in { 8, 18, 28 } do
	for _, z in { -48, -32, -18 } do
		F.pedestal(at(x, F2, z, "N"))
		doll(DEC, CFrame.new(x, F2 + 4.2, z) * CFrame.Angles(0, math.random() * 6, 0), 1.4, Color3.fromHSV(math.random(), 0.3, 0.8))
	end
end
F.mirror(at(36, F2, -56, "N"))
-- workers' bunk room (x 40..78)
for _, x in { 48, 58, 68 } do G2.bunk(at(x, F2, -50, "N")); G2.bunk(at(x, F2, -24, "S")) end
for _, x in { 74, 76.5 } do G2.locker(at(x, F2, -36, "W"), C3(80, 90, 110)) end
F.table(at(62, F2, -37, "N"), 6, 4, 3, Wd.mid, "CardTable"); F.chair(at(58, F2, -37, "E"), Wd.mid, Fab.grey); F.chair(at(66, F2, -37, "W"), Wd.mid, Fab.grey)
for _, x in { -59, -20, 20, 59 } do fluoro(x, 42, -33) end
fluoro(-40, 42, 0); fluoro(0, 42, 0); fluoro(40, 42, 0)
for _, p in { { -30, F1, 22 }, { 40, F2, -6 }, { 0, F1, -14 }, { -20, F2, -48 } } do blood(p[1], p[2], p[3], 2.4) end

---------------------------------------------------------------- outside: smokestacks + sign
local fac = model(DEC, "Facade")
for _, x in { -50, 50 } do cyl(fac, CFrame.new(x, 60, -40), "Smokestack", 7, 50, 0, 0, 0, T.ext) end
sign(fac, "DOLLMAKER & SONS", CFrame.new(0, 32, 60.8) * CFrame.Angles(0, math.pi, 0), 54, 6, st(M.CorrodedMetal, nil, C3(60, 50, 44)), C3(230, 200, 170), Enum.Font.Fondamento)

-- monster spawn points: one per room, both floors
for _, p in {
	{ 0, F1, 36 }, { -54, F1, 44 }, { 50, F1, 30 }, { -62, F1, -30 }, { -31, F1, -40 }, { 0, F1, -36 }, { 31, F1, -42 }, { 62, F1, -30 },
	{ -54, F2, 26 }, { 46, F2, 32 }, { -58, F2, -30 }, { -20, F2, -50 }, { 20, F2, -34 }, { 58, F2, -37 },
} do gspawn(p[1], p[2], p[3]) end
return endMap()
