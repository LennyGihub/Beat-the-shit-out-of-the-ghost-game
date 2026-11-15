-- St. Agnes Hospital: two floors, a long corridor with wards both sides, reception lobby, ER, surgery upstairs.
local C3 = Color3.fromRGB
beginMap("Hospital", {
	floor = st(M.Marble, nil, C3(196, 202, 198)), floor2 = st(M.Marble, nil, C3(186, 196, 190)),
	inner = st(M.Plaster, "PS2_Plaster", C3(168, 198, 184)), wainscot = st(M.SmoothPlastic, nil, C3(92, 140, 120)), wain = true, wainH = 4,
	ext = st(M.Concrete, nil, C3(196, 194, 186)), trim = st(M.Metal, nil, C3(150, 156, 160)), ceiling = st(M.SmoothPlastic, nil, C3(205, 205, 198)),
	roof = st(M.Concrete, nil, C3(90, 90, 92)), found = st(M.Concrete, nil, C3(120, 118, 112)), door = st(M.Metal, nil, C3(130, 165, 150)),
	porch = st(M.Concrete, nil, C3(150, 148, 142)), stairs = st(M.Concrete, nil, C3(160, 160, 156)),
})
shell({ two = true, roof = "flat" })
local inn = model(STR, "Interior")
local I = INT()
-- ground floor: corridor z -8.6..8.6, front rooms (ER west, lobby centre, waiting east), wards at the back
wall(inn, "G_corN", "x", 8.6, -78, 78, F1, 20, { dr(-49, 8), dr(0, 24, 14), dr(49, 8) }, I)
wall(inn, "G_corS", "x", -8.6, -78, 78, F1, 20, { dr(-62, 7), dr(-32, 7), dr(0, 7), dr(32, 7), dr(62, 7) }, I)
wall(inn, "G_lobW", "z", -20, 8.6, 58, F1, 20, { dr(40, 6) }, I)
wall(inn, "G_lobE", "z", 20, 8.6, 58, F1, 20, { dr(40, 6) }, I)
for _, x in { -47, -16, 16, 47 } do wall(inn, "G_ward" .. x, "z", x, -58, -8.6, F1, 20, {}, I) end
-- upper floor: same corridor, patient rooms + surgery
slab(-78, -58, 69.4, 58); slab(69.4, -58, 78, 24)
stairs(70, 77.4, 56)
wall(inn, "U_corN", "x", 8.6, -78, 69, F2, 20, { dr(-60, 7), dr(-30, 7), dr(0, 7), dr(30, 7), dr(56, 7) }, I)
wall(inn, "U_corS", "x", -8.6, -78, 78, F2, 20, { dr(-62, 7), dr(-32, 7), dr(0, 7), dr(32, 7), dr(62, 7) }, I)
for _, x in { -45, -15, 15, 45 } do wall(inn, "U_n" .. x, "z", x, 8.6, 58, F2, 20, {}, I) end
for _, x in { -47, -16, 16, 47 } do wall(inn, "U_s" .. x, "z", x, -58, -8.6, F2, 20, {}, I) end
railing("x", 24.3, 69.6, 78, F2)

-- reception lobby
F.counter(at(0, F1, 30, "S"), 14)
for _, x in { -12, -8, 8, 12 } do F.chair(at(x, F1, 46, "S"), Wd.mid, Fab.green) end
G2.vending(at(-16, F1, 52, "E"), C3(160, 30, 30))
G2.wheelchair(at(14, F1, 18, "W"))
poster(0, 12, 57.7, "N", 10, 4, C3(200, 40, 40))
-- ER (west front)
G2.gurney(at(-66, F1, 30, "E")); G2.gurney(at(-56, F1, 44, "S")); G2.steelTable(at(-34, F1, 30, "E"))
F.cabinet(at(-70, F1, 54, "S"), 6, 9); G2.wheelchair(at(-40, F1, 50, "S"))
-- waiting (east front)
for _, z in { 20, 28 } do for _, x in { 28, 36, 44, 52, 60 } do F.chair(at(x, F1, z, "N"), Wd.mid, Fab.blue) end end
F.tv(at(40, F1, 55, "N"))
-- wards (back)
for _, wx in { -62, -32, 0, 32, 62 } do
	G2.hospitalBed(at(wx - 6, F1, -40, "N")); G2.hospitalBed(at(wx + 6, F1, -40, "N"))
	F.nightstand(at(wx, F1, -50, "N"))
end
-- corridor junk
G2.gurney(at(-25, F1, 0, "E")); G2.wheelchair(at(40, F1, -2, "W")); F.chair(at(66, F1, 4, "W"), Steel)
-- upstairs: patient rooms north, surgery + morgue south
for _, rx in { -62, -30, 0, 30 } do G2.hospitalBed(at(rx, F2, 40, "S")); F.nightstand(at(rx + 7, F2, 50, "S")); G2.wheelchair(at(rx - 8, F2, 20, "N")) end
G2.steelTable(at(-62, F2, -34, "N")); F.cabinet(at(-72, F2, -54, "N"), 6, 9); G2.gurney(at(-50, F2, -40, "N"))
for _, x in { -30, 0 } do G2.steelTable(at(x - 5, F2, -34, "N")); G2.steelTable(at(x + 5, F2, -34, "N")) end
G2.hospitalBed(at(30, F2, -36, "N"), true); G2.hospitalBed(at(62, F2, -36, "N"), true)
F.cabinet(at(54, F2, -54, "N"), 6, 9)

-- lights: buzzing fluorescents
for _, x in { -60, -30, 0, 30, 60 } do fluoro(x, 21, 0); fluoro(x, 42, 0) end
for _, p in { { -49, 33 }, { 0, 20 }, { 0, 44 }, { 49, 33 } } do fluoro(p[1], 21, p[2]) end
for _, x in { -62, -32, 0, 32, 62 } do fluoro(x, 21, -34); fluoro(x, 42, -34) end
for _, x in { -62, -30, 0, 30, 56 } do fluoro(x, 42, 34) end
-- decor
for _, p in { { -30, F1, 2 }, { 20, F1, -4 }, { -60, F2, -40 }, { 0, F2, -32 }, { 12, F1, 36 } } do blood(p[1], p[2], p[3], 2.5) end
for _, x in { -40, 10, 50 } do poster(x, 10, -8.0, "S", 4, 5, C3(90, 130, 160), Steel) end
local fac = model(DEC, "Facade")
sign(fac, "ST. AGNES HOSPITAL", CFrame.new(0, 40, 60.8) * CFrame.Angles(0, math.pi, 0), 60, 6, st(M.Metal, nil, C3(40, 44, 48)), C3(230, 235, 230), Enum.Font.Oswald)
box(fac, "Cross", -1.5, 29, 60.5, 1.5, 37, 61.2, st(M.Neon, nil, C3(220, 30, 30)), DECO)
box(fac, "Cross", -4, 31.5, 60.5, 4, 34.5, 61.2, st(M.Neon, nil, C3(220, 30, 30)), DECO)
light(fac:FindFirstChild("Cross"), 40, 1.5, C3(255, 60, 50))
sign(fac, "EMERGENCY", CFrame.new(0, 17.2, 73.2) * CFrame.Angles(0, math.pi, 0), 20, 2.4, st(M.SmoothPlastic, nil, C3(180, 20, 20)), C3(255, 255, 255), Enum.Font.Oswald)

for _, p in { { -62, F1, -30 }, { 62, F1, -30 }, { 0, F1, -30 }, { -49, F1, 40 }, { -40, F2, 30 }, { 40, F2, -30 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
