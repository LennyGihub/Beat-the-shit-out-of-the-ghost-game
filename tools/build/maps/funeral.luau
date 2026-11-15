-- Greaves Funeral Home: a viewing chapel with open caskets, a reception parlour, the embalming room and a morgue.
local C3 = Color3.fromRGB
beginMap("Funeral", {
	floor = st(M.Carpet, "PS2_Rug1", C3(80, 70, 90)), floor2 = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(90, 80, 74)),
	inner = st(M.Fabric, "PS2_Wallpaper2", C3(120, 110, 140)), wainscot = st(M.Wood, "PS2_Wainscot1", C3(70, 50, 40)), wain = true, wainH = 5,
	ext = st(M.WoodPlanks, "PS2_Siding", C3(70, 66, 80)), trim = st(M.Wood, nil, C3(200, 196, 190)), ceiling = st(M.Plaster, "PS2_Plaster", C3(170, 160, 170)),
	roof = st(M.Slate, nil, C3(40, 36, 44)), found = st(M.Cobblestone, "PS2_Stone1", C3(90, 86, 84)), door = st(M.Wood, "PS2_DarkBeam1", C3(50, 34, 30)),
	porch = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(80, 72, 66)),
})
shell({ two = true, roof = "gable", pitch = 0.65 })
local inn = model(STR, "Interior")
local I = INT()
local TILE = st(M.Marble, nil, C3(190, 196, 196))
-- ground: viewing chapel (centre front), parlour (west), office (east), embalming + morgue (back)
wall(inn, "G_back", "x", -14, -78, 78, F1, 20, { dr(-50, 8), dr(0, 8), dr(50, 8) }, I)
wall(inn, "G_chW", "z", -26, -14, 58, F1, 20, { dr(20, 8) }, I); wall(inn, "G_chE", "z", 26, -14, 58, F1, 20, { dr(20, 8) }, I)
wall(inn, "G_morgue", "z", 0, -58, -14, F1, 20, { dr(-30, 8) }, I)
box(STR, "MorgueFloor", -78, 2.05, -58, 78, 2.2, -14.6, TILE)
-- viewing chapel: rows of chairs facing three caskets
for z = 16, 46, 6 do for x = -20, 20, 4 do if math.abs(x) > 2 then F.chair(at(x, F1, z, "N"), Wd.dark, Fab.pink) end end end
G2.coffin(at(0, F1, -2, "E"), true); G2.coffin(at(-12, F1, 2, "E"), false); G2.coffin(at(12, F1, 2, "E"), false)
for _, x in { -6, 6 } do candles(x, F1, -8) end
poster(0, 12, -13.2, "S", 8, 10, C3(40, 30, 50), T.brass)
-- parlour
F.sofa(at(-52, F1, 30, "E"), Fab.red, 10); F.armchair(at(-40, F1, 44, "S"), Fab.red); F.coffeeTable(at(-46, F1, 30, "N"))
F.piano(at(-66, F1, 0, "E")); F.clock(at(-30, F1, 56, "S")); F.floorLamp(at(-72, F1, 50, "E"))
-- office
F.desk(at(52, F1, 30, "S")); F.chair(at(52, F1, 36, "N"), Wd.dark, Fab.brown); F.bookshelf(at(76.5, F1, 30, "W"), 8, 10); F.cabinet(at(40, F1, 55, "S"), 6, 9)
for _, z in { 0, -6 } do G2.coffin(at(66, F1, z + 4, "E"), false) end
-- embalming (west back) + morgue drawers (east back)
G2.steelTable(at(-50, F1, -36, "N")); G2.steelTable(at(-30, F1, -36, "N")); G2.gurney(at(-66, F1, -26, "E"))
F.cabinet(at(-70, F1, -55, "N"), 6, 9); F.sink(at(-20, F1, -56, "N"))
local mw = model(STR, "MorgueDrawers")
box(mw, "Bank", 10, F1, -58, 76, F1 + 12, -52, Steel)
for x = 14, 72, 6 do for y = F1 + 1.5, F1 + 9, 4 do box(mw, "Door", x - 2.4, y, -52.1, x + 2.4, y + 3.2, -51.9, st(M.Metal, nil, C3(190, 194, 198)), DECO) end end
G2.gurney(at(40, F1, -36, "N")); G2.steelTable(at(26, F1, -30, "N"))
-- upstairs: family apartment + casket storage
slab(-78, -58, 69.4, 58); slab(69.4, -58, 78, 24)
stairs(70, 77.4, 56)
wall(inn, "U_mid", "x", 0, -78, 69, F2, 20, { dr(-50, 8), dr(0, 8), dr(40, 8) }, I)
wall(inn, "U_w", "z", -30, 0.6, 58, F2, 20, { dr(30, 6) }, I)
railing("x", 24.3, 69.6, 78, F2)
F.bed(at(-55, F2, 40, "S"), 7, 9, Fab.blue); F.dresser(at(-70, F2, 10, "E"), 6); F.wardrobe(at(-40, F2, 55, "S"))
F.sofa(at(10, F2, 30, "S"), Fab.green, 9); F.tv(at(10, F2, 50, "N")); F.rockingChair(at(30, F2, 40, "W"))
for x = -70, 50, 9 do G2.coffin(at(x, F2, -40, "N"), false) end
for _, x in { -40, 0, 40 } do F.crate(at(x, F2, -20, "N"), 3) end
-- lights
for _, z in { 0, 30 } do bulb(0, 21, z, 3, C3(220, 200, 255)) end
for _, p in { { -50, 21, 30 }, { 50, 21, 30 }, { -40, 21, -36 }, { 40, 21, -36 }, { -50, 42, 30 }, { 20, 42, 30 }, { -20, 42, -36 }, { 40, 42, -36 } } do bulb(p[1], p[2], p[3], 2) end
for _, z in { 10, 40 } do sconce(-25.4, 12, z, "W", C3(200, 170, 255)); sconce(25.4, 12, z, "E", C3(200, 170, 255)) end
fluoro(-40, 21, -30, C3(210, 235, 235)); fluoro(40, 21, -30, C3(210, 235, 235))
for _, p in { { -40, F1, -36 }, { 0, F1, 6 }, { 30, F2, -30 } } do blood(p[1], p[2], p[3], 2.6) end
-- hearse + sign
local fac = model(DEC, "Facade")
local hz = model(fac, "Hearse")
box(hz, "Body", 30, 1.4, 66, 38, 6, 84, st(M.Metal, nil, C3(20, 20, 22)))
box(hz, "Cabin", 30.4, 6, 70, 37.6, 9, 82, st(M.Metal, nil, C3(20, 20, 22)))
box(hz, "Window", 37.7, 6.4, 72, 37.9, 8.6, 80, st(M.Glass, nil, C3(60, 60, 70)), { t = 0.3 })
for _, z in { 69, 81 } do for _, x in { 30, 38 } do cyl(hz, CFrame.new(x, 1.4, z) * CFrame.Angles(0, 0, 0), "Wheel", 2.8, 1, 0, 0, 0, Blk).CFrame = CFrame.new(x, 1.4, z) end end
sign(fac, "GREAVES FUNERAL HOME", CFrame.new(0, 40, 60.8) * CFrame.Angles(0, math.pi, 0), 54, 5, st(M.Wood, nil, C3(30, 24, 30)), C3(220, 210, 240), Enum.Font.Fondamento)
for _, p in { { -40, F1, -36 }, { 40, F1, -36 }, { 0, F1, 20 }, { -50, F1, 30 }, { -50, F2, -40 }, { 40, F2, 30 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
