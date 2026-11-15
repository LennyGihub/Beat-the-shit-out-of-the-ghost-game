-- Ravenhill Asylum: barred windows, padded cells along a long ward, a day room and an operating theatre upstairs.
local C3 = Color3.fromRGB
beginMap("Asylum", {
	floor = st(M.Concrete, nil, C3(140, 146, 140)), floor2 = st(M.Concrete, nil, C3(130, 136, 130)),
	inner = st(M.Plaster, "PS2_Plaster", C3(180, 190, 176)), wainscot = st(M.SmoothPlastic, nil, C3(80, 110, 96)), wain = true, wainH = 5,
	ext = st(M.Cobblestone, "PS2_Stone1", C3(120, 118, 114)), trim = st(M.Concrete, nil, C3(100, 100, 98)), ceiling = st(M.Plaster, "PS2_Plaster", C3(170, 172, 164)),
	roof = st(M.Slate, nil, C3(56, 56, 60)), found = st(M.Cobblestone, "PS2_Stone1", C3(96, 94, 90)), door = st(M.Metal, nil, C3(90, 100, 96)),
	bars = true, porch = st(M.Concrete, nil, C3(120, 120, 116)),
})
shell({ two = true, roof = "gable", pitch = 0.5 })
local inn = model(STR, "Interior")
local I = INT()
local PAD = st(M.Fabric, nil, C3(210, 210, 196))
-- ground: ward corridor z -8.6..8.6, cells at the back (8 x 13 each), day room + nurse station at the front
wall(inn, "G_corN", "x", 8.6, -78, 78, F1, 20, { dr(-50, 8), dr(0, 20, 14), dr(50, 8) }, I)
wall(inn, "G_corS", "x", -8.6, -78, 78, F1, 20, { dr(-67, 5, 9), dr(-48, 5, 9), dr(-29, 5, 9), dr(-10, 5, 9), dr(10, 5, 9), dr(29, 5, 9), dr(48, 5, 9), dr(67, 5, 9) }, I)
for _, x in { -57.5, -38.5, -19.5, 0, 19.5, 38.5, 57.5 } do wall(inn, "Cell" .. x, "z", x, -58, -8.6, F1, 20, {}, I) end
wall(inn, "G_frontW", "z", -24, 8.6, 58, F1, 20, { dr(30, 8) }, I); wall(inn, "G_frontE", "z", 24, 8.6, 58, F1, 20, { dr(30, 8) }, I)
-- padded cells: quilted walls + a cot
for _, cx in { -67, -48, -29, -10, 10, 29, 48, 67 } do
	local pc = model(DEC, "Padding")
	for z = -56, -12, 4 do box(pc, "Pad", cx - 8.5, F1 + 0.5, z, cx - 8.2, F1 + 12, z + 3.6, PAD, DECO); box(pc, "Pad", cx + 8.2, F1 + 0.5, z, cx + 8.5, F1 + 12, z + 3.6, PAD, DECO) end
	G2.hospitalBed(at(cx, F1, -44, "N"), true)
	bulb(cx, 21, -34, 1.5, C3(220, 240, 220))
end
-- day room (west front) + nurse station (centre) + showers (east)
for _, p in { { -60, 30 }, { -40, 40 } } do F.table(at(p[1], F1, p[2], "N"), 8, 4, 3, Wd.light, "Table"); F.chair(at(p[1] - 3, F1, p[2] + 4, "N"), Steel); F.chair(at(p[1] + 3, F1, p[2] - 4, "S"), Steel) end
F.tv(at(-60, F1, 55, "N")); G2.wheelchair(at(-36, F1, 20, "E")); F.rockingChair(at(-70, F1, 46, "E"))
F.counter(at(0, F1, 30, "S"), 16); F.cabinet(at(-10, F1, 55, "S"), 6, 9); F.cabinet(at(10, F1, 55, "S"), 6, 9)
for _, x in { 34, 44, 54, 64 } do F.sink(at(x, F1, 56, "S")) end
F.bathtub(at(50, F1, 30, "E")); F.toilet(at(70, F1, 40, "W"))
-- upstairs: dormitory north, operating theatre + records south
slab(-78, -58, 69.4, 58); slab(69.4, -58, 78, 24)
stairs(70, 77.4, 56)
wall(inn, "U_corS", "x", -8.6, -78, 78, F2, 20, { dr(-50, 8), dr(0, 8), dr(50, 8) }, I)
wall(inn, "U_s", "z", -25, -58, -8.6, F2, 20, {}, I); wall(inn, "U_s2", "z", 25, -58, -8.6, F2, 20, {}, I)
railing("x", 24.3, 69.6, 78, F2)
for x = -70, 50, 12 do G2.hospitalBed(at(x, F2, 44, "S"), true) end
G2.steelTable(at(0, F2, -34, "N")); G2.gurney(at(-10, F2, -24, "E")); F.cabinet(at(10, F2, -55, "N"), 6, 9)
for x = -74, -32, 7 do F.cabinet(at(x, F2, -55, "N"), 6, 10) end
for _, z in { -40, -25 } do F.desk(at(50, F2, z, "W")) end
G2.wheelchair(at(-20, F2, 0, "E")); G2.gurney(at(30, F2, 2, "W"))
for _, x in { -60, -30, 0, 30, 60 } do fluoro(x, 21, 0, C3(200, 230, 210)); fluoro(x, 42, 0, C3(200, 230, 210)); fluoro(x, 42, 34, C3(200, 230, 210)) end
for _, x in { -50, 0, 50 } do fluoro(x, 21, 34); fluoro(x, 42, -34) end
for _, p in { { -48, F1, -40 }, { 10, F1, -30 }, { 0, F2, -36 }, { -30, F1, 0 }, { 30, F2, 40 } } do blood(p[1], p[2], p[3], 2.8) end
local fac = model(DEC, "Facade")
sign(fac, "RAVENHILL ASYLUM", CFrame.new(0, 40, 60.8) * CFrame.Angles(0, math.pi, 0), 44, 5, st(M.Metal, nil, C3(40, 40, 42)), C3(200, 200, 190), Enum.Font.Merriweather)
for x = -70, 70, 7 do if math.abs(x) > 20 then box(fac, "Spike", x - 0.2, 0, 86, x + 0.2, 7, 86.4, T.iron) end end
box(fac, "Rail", -70, 6, 86, -20, 6.4, 86.4, T.iron); box(fac, "Rail", 20, 6, 86, 70, 6.4, 86.4, T.iron)
for _, p in { { -48, F1, -40 }, { 48, F1, -40 }, { 0, F1, 0 }, { -50, F1, 30 }, { 0, F2, -36 }, { -40, F2, 40 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
