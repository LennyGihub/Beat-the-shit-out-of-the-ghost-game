-- Hollow Creek Farm: the farmhouse (west) joined to a big hay barn (east) with a hayloft.
local C3 = Color3.fromRGB
beginMap("Farm", {
	floor = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(120, 96, 70)), floor2 = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(110, 88, 64)),
	inner = st(M.WoodPlanks, "PS2_Siding1", C3(150, 128, 100)), wainscot = st(M.Wood, "PS2_DarkBeam1", C3(90, 64, 44)), wain = true,
	ext = st(M.WoodPlanks, "PS2_Siding1", C3(140, 40, 34)), trim = st(M.Wood, nil, C3(220, 214, 200)), ceiling = st(M.Wood, "PS2_DarkBeam1", C3(90, 66, 48)),
	roof = st(M.CorrodedMetal, nil, C3(110, 100, 90)), found = st(M.Cobblestone, "PS2_Stone1", C3(110, 104, 96)), door = st(M.WoodPlanks, "PS2_Siding1", C3(120, 36, 30)),
	porch = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(110, 90, 66)),
})
shell({ two = true, roof = "gable", pitch = 0.55 })
local inn = model(STR, "Interior")
local I = INT()
local HAY = st(M.Grass, nil, C3(200, 170, 90))
-- house (x -78..-10): kitchen, living, stairs; barn (x -10..78): open double height with a hayloft at the back
wall(inn, "Divider", "z", -10, -58, 58, F1, 20, { dr(30, 8), dr(-30, 8) }, I)
wall(inn, "Divider2", "z", -10, -58, 58, F2, 20, { dr(-40, 8) }, I)
wall(inn, "HouseMid", "x", 0, -78, -10.6, F1, 20, { dr(-44, 8), dr(-24, 8) }, I)
slab(-78, -58, -10, 18.6); slab(-78, 18.6, -60, 58); slab(-52.6, 18.6, -10, 58)
stairs(-59.4, -53.2, 56)
-- hayloft over the back of the barn
slab(-10, -58, 78, -24)
railing("x", -23.7, -10, 78, F2)
local lad = model(STR, "Ladder")
for y = 3, 22, 1.6 do box(lad, "Rung", 40, y - 0.15, -23.4, 46, y + 0.15, -22.8, T.trim) end
for _, x in { 40, 46 } do box(lad, "Side", x - 0.2, 2, -23.4, x + 0.2, 25, -22.8, T.trim) end
box(STR, "BarnFloor", -9.4, 2.05, -24, 78, 2.3, 58, st(M.Ground, nil, C3(110, 90, 60)))
-- house rooms
F.stove(at(-72, F1, -52, "N")); F.counter(at(-60, F1, -55, "N"), 10); F.table(at(-60, F1, -30, "N"), 10, 5, 3, Wd.mid, "Table")
for _, x in { -64, -56 } do F.chair(at(x, F1, -25, "N"), Wd.mid); F.chair(at(x, F1, -35, "S"), Wd.mid) end
F.fridge(at(-30, F1, -55, "N")); F.barrel(at(-20, F1, -50, "N"))
F.sofa(at(-45, F1, 30, "S"), Fab.green, 10); F.armchair(at(-30, F1, 40, "W"), Fab.mustard); F.rockingChair(at(-70, F1, 12, "E"))
F.clock(at(-20, F1, 56, "S")); F.bookshelf(at(-76.5, F1, 40, "E"), 7, 9)
-- upstairs bedrooms
F.bed(at(-70, F2, -40, "E"), 6, 9, Fab.blue); F.dresser(at(-40, F2, -55, "N"), 6); F.bed(at(-40, F2, 36, "S"), 6, 9, Fab.pink); F.crib(at(-25, F2, 40, "S"))
F.wardrobe(at(-22, F2, -40, "W"))
-- barn: hay, stalls, tools, tractor shape
for _, p in { { 10, 40 }, { 15, 40 }, { 10, 34 }, { 60, 50 }, { 64, 44 }, { 20, -10 }, { 25, -14 }, { 70, -12 } } do G2.hay(at(p[1], F1, p[2], "N")) end
for _, p in { { 0, F2, -40 }, { 6, F2, -44 }, { 30, F2, -50 }, { 55, F2, -40 }, { 60, F2, -46 }, { 66, F2, -36 } } do G2.hay(at(p[1], p[2], p[3], "E")) end
local stalls = model(STR, "Stalls")
for _, z in { -20, -6, 8 } do box(stalls, "StallWall", 66, F1, z - 0.3, 78, F1 + 6, z + 0.3, T.inner) end
G2.workbench(at(30, F1, 54, "S")); F.barrel(at(40, F1, 54, "S")); F.crate(at(48, F1, 52, "S")); F.crate(at(48, F1 + 3, 52, "S"), 2.5)
local tr = model(DEC, "Tractor")
box(tr, "Body", 20, 2.6, 10, 30, 7, 16, st(M.Metal, nil, C3(150, 40, 30)))
box(tr, "Cab", 20, 7, 10, 25, 11, 16, st(M.Metal, nil, C3(150, 40, 30)))
for _, p in { { 21, 9.5 }, { 21, 16.5 } } do cyl(tr, CFrame.new(p[1], 5, p[2]) * CFrame.Angles(math.pi / 2, 0, 0), "BigWheel", 6, 1.4, 0, 0, 0, Blk) end
for _, p in { { 29, 9.8 }, { 29, 16.2 } } do cyl(tr, CFrame.new(p[1], 3.5, p[2]) * CFrame.Angles(math.pi / 2, 0, 0), "Wheel", 3.5, 1, 0, 0, 0, Blk) end
-- lights: bare bulbs
for _, p in { { -45, 21, -30 }, { -45, 21, 35 }, { -70, 21, 0 }, { -45, 42, -30 }, { -45, 42, 35 } } do bulb(p[1], p[2], p[3], 2) end
for _, p in { { 10, 0 }, { 40, 20 }, { 60, 40 }, { 30, -40 }, { 60, -40 }, { 10, 40 }, { 40, -5 }, { 65, 10 } } do bulb(p[1], 43, p[2], 8, C3(255, 190, 120)) end
for _, p in { { -60, 21, -50 }, { -25, 21, 20 }, { -70, 42, -40 }, { -25, 42, 45 } } do bulb(p[1], p[2], p[3], 2) end
for _, p in { { 20, F1, 20 }, { -60, F1, -30 }, { 40, F2, -40 } } do blood(p[1], p[2], p[3], 2.4) end
-- yard bits
local fac = model(DEC, "Facade")
for x = 22, 70, 6 do box(fac, "FencePost", x - 0.3, 0, 78, x + 0.3, 4, 78.6, T.trim) end
box(fac, "FenceRail", 22, 2.6, 78.1, 70, 3, 78.5, T.trim)
sign(fac, "HOLLOW CREEK FARM", CFrame.new(-40, 30, 60.8) * CFrame.Angles(0, math.pi, 0), 40, 5, st(M.Wood, nil, C3(220, 214, 200)), C3(120, 30, 26), Enum.Font.Merriweather)
for _, p in { { -45, F1, -30 }, { -45, F1, 35 }, { 30, F1, 20 }, { 60, F1, -10 }, { 40, F2, -45 }, { -45, F2, 35 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
