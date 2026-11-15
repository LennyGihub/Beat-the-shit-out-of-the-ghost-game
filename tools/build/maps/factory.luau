-- Dollmaker's Factory: a tall production floor with a conveyor and workbenches, doll storage, a catwalk and offices.
local C3 = Color3.fromRGB
beginMap("Factory", {
	floor = st(M.Concrete, nil, C3(120, 116, 110)), floor2 = st(M.DiamondPlate, nil, C3(100, 100, 104)),
	inner = st(M.Brick, nil, C3(150, 110, 96)), wainscot = st(M.CorrodedMetal, nil, C3(90, 80, 70)), wain = true, wainH = 3,
	ext = st(M.Brick, nil, C3(110, 64, 52)), trim = st(M.CorrodedMetal, nil, C3(100, 80, 64)), ceiling = st(M.CorrodedMetal, nil, C3(80, 74, 70)),
	roof = st(M.CorrodedMetal, nil, C3(90, 86, 82)), found = st(M.Concrete, nil, C3(100, 96, 92)), door = st(M.CorrodedMetal, nil, C3(110, 70, 50)),
	porch = st(M.Concrete, nil, C3(120, 116, 110)),
})
shell({ two = false, H = 34, roof = "gable", pitch = 0.25, winW = 8, winB = 16, winT = 28 })
local inn = model(STR, "Interior")
local I = INT()
-- offices + storage along the back (two storeys inside the tall shell), production floor in front
wall(inn, "BackWall", "x", -30, -78, 78, F1, 20, { dr(-50, 8), dr(0, 10, 14), dr(50, 8) }, I)
slab(-78, -58, 78, -30)
wall(inn, "BackWall2", "x", -30, -78, 78, F2, 13, { dr(-60, 6), dr(-20, 6), dr(20, 6), dr(60, 6) }, I)
for _, x in { -26, 26 } do wall(inn, "Office" .. x, "z", x, -58, -30, F1, 20, { dr(-44, 6) }, I) end
-- stairs up to the catwalk (west side, along the wall)
local stc = model(STR, "Stairs")
for i = 1, 21 do box(stc, "Step", -78, F1, -30 + (i - 1) * 1.5, -71, F1 + i, -30 + i * 1.5, st(M.DiamondPlate, nil, C3(100, 100, 104))) end
-- catwalk along the back at the upper level
railing("x", -29.7, -70, 78, F2)
-- conveyor belt through the middle
local cv = model(STR, "Conveyor")
box(cv, "Belt", -60, F1, -4, 60, F1 + 3.2, 4, st(M.Rubber, nil, C3(30, 30, 32)))
for x = -58, 58, 4 do box(cv, "Roller", x - 0.3, F1 + 3.2, -4.2, x + 0.3, F1 + 3.5, 4.2, Steel, DECO) end
for x = -56, 56, 9 do doll(DEC, CFrame.new(x, F1 + 3.5, 0) * CFrame.Angles(0, math.random() * 6, 0), 0.9, Color3.fromHSV(math.random(), 0.5, 0.6)) end
-- workbenches, crates, barrels, doll shelves
for _, x in { -50, -25, 0, 25, 50 } do G2.workbench(at(x, F1, 14, "N"), 9); G2.workbench(at(x, F1, -14, "S"), 9) end
for _, p in { { -70, 30 }, { -70, 40 }, { -64, 50 }, { 70, 30 }, { 66, 44 }, { 60, 52 } } do F.crate(at(p[1], F1, p[2], "N"), 3.5) end
for _, p in { { -74, 10 }, { -74, 16 }, { 74, 10 }, { 74, -10 } } do F.barrel(at(p[1], F1, p[2], "N")) end
for _, x in { -40, -20, 20, 40 } do G2.dollShelf(at(x, F1, 50, "S")) end
-- offices + storage
F.desk(at(-50, F1, -50, "N")); F.chair(at(-50, F1, -46, "N"), Wd.mid, Fab.grey); F.cabinet(at(-70, F1, -55, "N"), 6, 9)
F.desk(at(50, F1, -50, "N")); F.bookshelf(at(70, F1, -57, "N"), 8, 10); F.sofa(at(40, F1, -36, "S"), Fab.brown, 8)
for _, x in { -14, -6, 6, 14 } do G2.dollShelf(at(x, F1, -55, "N")) end
for _, x in { -60, -20, 20, 60 } do F.crate(at(x, F2, -45, "N"), 3); F.crate(at(x + 4, F2, -50, "N"), 3) end
for _, x in { -40, 40 } do G2.dollShelf(at(x, F2, -55, "N")) end
-- hanging dolls + chains from the rafters
for _, p in { { -40, 30 }, { -10, 36 }, { 20, 26 }, { 45, 40 }, { 60, 18 } } do
	local h = model(DEC, "HangingDoll")
	box(h, "Rope", p[1] - 0.1, 22, p[2] - 0.1, p[1] + 0.1, 35, p[2] + 0.1, st(M.Fabric, nil, C3(120, 100, 70)), DECO)
	doll(h, CFrame.new(p[1], 19.6, p[2]) * CFrame.Angles(0, math.random() * 6, 0), 1.3, C3(150, 40, 60))
end
for _, x in { -50, -20, 10, 40, 65 } do bulb(x, 35, 20, 6, C3(255, 200, 150)); bulb(x, 35, -10, 6, C3(255, 200, 150)) end
for _, x in { -50, 0, 50 } do fluoro(x, 21, -44); fluoro(x, 35, -44) end
for _, p in { { -30, F1, 22 }, { 40, F1, -6 }, { 0, F1, -44 } } do blood(p[1], p[2], p[3], 2.4) end
-- smokestacks + sign
local fac = model(DEC, "Facade")
for _, x in { -50, 50 } do cyl(fac, CFrame.new(x, 50, -40), "Smokestack", 7, 60, 0, 0, 0, T.ext) end
sign(fac, "DOLLMAKER & SONS", CFrame.new(0, 32, 60.8) * CFrame.Angles(0, math.pi, 0), 54, 6, st(M.CorrodedMetal, nil, C3(60, 50, 44)), C3(230, 200, 170), Enum.Font.Fondamento)
for _, p in { { -40, F1, 30 }, { 40, F1, 30 }, { 0, F1, 20 }, { -50, F1, -45 }, { 50, F1, -45 }, { 0, F2, -45 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
