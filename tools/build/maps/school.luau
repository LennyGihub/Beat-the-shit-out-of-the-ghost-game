-- Blackwood High: classrooms off a locker corridor, a double-height gym on the east side, cafeteria upstairs.
local C3 = Color3.fromRGB
beginMap("School", {
	floor = st(M.Marble, nil, C3(190, 176, 150)), floor2 = st(M.Marble, nil, C3(180, 170, 150)),
	inner = st(M.Brick, nil, C3(160, 142, 112)), wainscot = st(M.SmoothPlastic, nil, C3(130, 60, 40)), wain = true, wainH = 3.5,
	ext = st(M.Brick, nil, C3(150, 70, 52)), trim = st(M.Concrete, nil, C3(190, 186, 176)), ceiling = st(M.SmoothPlastic, nil, C3(150, 146, 136)),
	roof = st(M.Concrete, nil, C3(80, 80, 82)), found = st(M.Concrete, nil, C3(130, 126, 120)), door = st(M.Metal, nil, C3(150, 40, 30)),
	porch = st(M.Concrete, nil, C3(160, 156, 150)), stairs = st(M.Concrete, nil, C3(165, 160, 150)),
})
shell({ two = true, roof = "flat" })
local inn = model(STR, "Interior")
local I = INT()
local GYM = st(M.WoodPlanks, nil, C3(190, 140, 80))
-- ground: corridor z -8.6..8.6 from x -78..30, gym x 30..78 (full height, no upper slab there)
wall(inn, "G_corN", "x", 8.6, -78, 30, F1, 20, { dr(-60, 7), dr(-30, 7), dr(0, 24, 14) }, I)
wall(inn, "G_corS", "x", -8.6, -78, 30, F1, 20, { dr(-60, 7), dr(-30, 7), dr(0, 7) }, I)
wall(inn, "G_gymW", "z", 30, -58, 58, F1, 20, { dr(0, 14, 14), dr(40, 8) }, I)
wall(inn, "G_gymW2", "z", 30, -58, 58, F2, 20, {}, I)
for _, x in { -45, -15 } do wall(inn, "G_n" .. x, "z", x, 8.6, 58, F1, 20, {}, I); wall(inn, "G_s" .. x, "z", x, -58, -8.6, F1, 20, {}, I) end
box(STR, "GymFloor", 30.6, 2.05, -58, 78, 2.25, 58, GYM)
-- upper floor over the classroom half only
slab(-78, -58, -2, 58); slab(-2, -58, 30, 18.6); slab(5.4, 18.6, 30, 58)
stairs(-1.4, 5, 56)
wall(inn, "U_corN", "x", 8.6, -78, -2, F2, 20, { dr(-60, 7), dr(-30, 7) }, I)
wall(inn, "U_corS", "x", -8.6, -78, 30, F2, 20, { dr(-60, 7), dr(-30, 7), dr(15, 7) }, I)
for _, x in { -45, -15 } do wall(inn, "U_n" .. x, "z", x, 8.6, 58, F2, 20, {}, I); wall(inn, "U_s" .. x, "z", x, -58, -8.6, F2, 20, {}, I) end
railing("z", -2.3, 18.6, 58, F2)

-- lockers along the corridor
for x = -76, 26, 2.6 do
	if math.abs(x + 60) > 5 and math.abs(x + 30) > 5 and math.abs(x) > 13 then G2.locker(at(x, F1, 7.4, "S"), C3(60, 80, 120)) end
end
for x = -76, 26, 2.6 do
	if math.abs(x + 60) > 5 and math.abs(x + 30) > 5 and math.abs(x) > 5 then G2.locker(at(x, F1, -7.4, "N"), C3(120, 40, 36)) end
end
-- classrooms: desk grids, teacher desk, chalkboard
local function classroom(x1, x2, z1, z2, y, faceBoard)
	local cx = (x1 + x2) / 2
	local boardZ = faceBoard == "N" and z1 + 0.7 or z2 - 0.7
	poster(cx, y + 8, boardZ, faceBoard == "N" and "S" or "N", 14, 5.5, C3(30, 52, 40), Wd.mid)
	F.desk(at(cx + 6, y, faceBoard == "N" and z1 + 5 or z2 - 5, faceBoard == "N" and "S" or "N"))
	local zs = faceBoard == "N" and { z1 + 13, z1 + 19, z1 + 25, z1 + 31 } or { z2 - 13, z2 - 19, z2 - 25, z2 - 31 }
	for _, z in zs do for dx = -9, 9, 6 do G2.schoolDesk(at(cx + dx, y, z, faceBoard == "N" and "N" or "S")) end end
	fluoro(cx, y + 19, (z1 + z2) / 2, C3(230, 220, 190))
end
classroom(-78, -45, -58, -8.6, F1, "N"); classroom(-45, -15, -58, -8.6, F1, "N"); classroom(-15, 30, -58, -8.6, F1, "N")
classroom(-78, -45, 8.6, 58, F1, "S"); classroom(-45, -15, 8.6, 58, F1, "S")
classroom(-78, -45, -58, -8.6, F2, "N"); classroom(-45, -15, -58, -8.6, F2, "N")
classroom(-78, -45, 8.6, 58, F2, "S")
-- upstairs cafeteria
for _, z in { 20, 34, 48 } do F.table(at(-30, F2, z, "N"), 10, 4, 2.8, Wd.light, "Table"); for _, dz in { -3, 3 } do F.bench(at(-30, F2, z + dz, "N"), 10, Wd.light) end end
G2.vending(at(-16, F2, 52, "W"), C3(30, 80, 160)); G2.vending(at(-16, F2, 46, "W"), C3(160, 30, 30))
-- entrance hall: trophy cabinet
F.cabinet(at(-12, F1, 56, "S"), 8, 10); F.cabinet(at(12, F1, 56, "S"), 8, 10)
-- gym: bleachers, hoops, mats
local gb = model(STR, "Bleachers")
for i = 0, 5 do box(gb, "Step", 66 - i * 2.4, F1, -52, 78, F1 + 1.2 + i * 1.2, 50, GYM) end
for _, z in { -52, 52 } do
	local hp = model(DEC, "Hoop")
	box(hp, "Pole", 53.5, 2, z + (z > 0 and 2 or -2) - 0.4, 54.5, 16, z + (z > 0 and 2 or -2) + 0.4, Steel)
	box(hp, "Board", 50, 14, z - 0.3, 58, 19, z + 0.3, st(M.Glass, nil, C3(220, 230, 235)), { t = 0.3 })
	cyl(hp, CFrame.new(54, 14.5, z + (z > 0 and -1.5 or 1.5)), "Rim", 3, 0.2, 0, 0, 0, st(M.Neon, nil, C3(240, 100, 30)), DECO)
end
for _, p in { { 40, -30 }, { 40, 20 } } do box(DEC, "Mat", p[1] - 4, 2.25, p[2] - 6, p[1] + 4, 2.9, p[2] + 6, st(M.Fabric, nil, C3(40, 70, 140))) end
box(DEC, "CourtLine", 53.8, 2.26, -58, 54.2, 2.3, 58, st(M.SmoothPlastic, nil, C3(240, 240, 240)), DECO)
for _, z in { -20, 20 } do for _, x in { 42, 66 } do bulb(x, 43, z, 4, C3(255, 240, 210)) end end
for _, x in { -60, -30, 0 } do fluoro(x, 21, 0); fluoro(x, 42, 0) end
fluoro(0, 21, 34)
for _, p in { { -30, F1, 0 }, { 50, F1, 10 }, { -60, F2, -30 } } do blood(p[1], p[2], p[3], 2) end
local fac = model(DEC, "Facade")
sign(fac, "BLACKWOOD HIGH SCHOOL", CFrame.new(0, 40, 60.8) * CFrame.Angles(0, math.pi, 0), 64, 6, st(M.Concrete, nil, C3(200, 196, 186)), C3(40, 40, 50), Enum.Font.Merriweather)
box(fac, "FlagPole", -24, 2, 74, -23.4, 40, 74.6, Steel)
box(fac, "Flag", -23.4, 33, 74.1, -15, 38, 74.3, st(M.Fabric, nil, C3(150, 30, 30)), DECO)
for _, p in { { -60, F1, -30 }, { 0, F1, -30 }, { 54, F1, 0 }, { -60, F1, 30 }, { -60, F2, 30 }, { -30, F2, -30 } } do gspawn(p[1], p[2], p[3]) end
MAP:SetAttribute("SpawnInside", Vector3.new(0, 5, 48))
return endMap()
