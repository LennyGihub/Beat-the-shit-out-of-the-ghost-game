-- Cellblock 9: two tiers of barred cells around a tall open block, a mess hall, the warden's office and a watchtower.
local C3 = Color3.fromRGB
beginMap("Prison", {
	floor = st(M.Concrete, nil, C3(100, 100, 104)), floor2 = st(M.DiamondPlate, nil, C3(110, 112, 116)),
	inner = st(M.Concrete, nil, C3(118, 118, 124)), wainscot = st(M.SmoothPlastic, nil, C3(70, 80, 100)), wain = true, wainH = 4,
	ext = st(M.Concrete, nil, C3(120, 120, 124)), trim = st(M.Metal, nil, C3(80, 84, 90)), ceiling = st(M.Concrete, nil, C3(80, 80, 84)),
	roof = st(M.Concrete, nil, C3(90, 90, 94)), found = st(M.Concrete, nil, C3(100, 100, 104)), door = st(M.Metal, nil, C3(70, 74, 80)),
	bars = true, porch = st(M.Concrete, nil, C3(120, 120, 124)),
})
shell({ two = true, roof = "flat", winW = 3, winB = 8, winT = 14 })
local inn = model(STR, "Interior")
local I = INT()
local BAR = st(M.Metal, nil, C3(60, 62, 68))
-- the block: open from z -40..40 between x -52..52 (double height); cells along both long sides in 2 tiers
local function cellRow(x0, x1, zWall, zBars, y)
	local w = (x1 - x0) / 5
	for i = 0, 4 do
		local a = x0 + i * w
		box(inn, "CellWall", a - 0.4, y, math.min(zWall, zBars), a + 0.4, y + 14, math.max(zWall, zBars), T.inner)
		for x = a + 1, a + w - 1, 1.1 do box(inn, "CellBar", x - 0.15, y, zBars - 0.15, x + 0.15, y + 14, zBars + 0.15, BAR) end
		box(inn, "BarTop", a, y + 13.4, zBars - 0.3, a + w, y + 14, zBars + 0.3, BAR)
		local cx = a + w / 2
		G2.bunk(at(cx - 2, y, (zWall + zBars) / 2, "E"))
		F.toilet(at(cx + 4, y, zWall + (zWall < zBars and 1.5 or -1.5), zWall < zBars and "S" or "N"))
		bulb(cx, y + 14, (zWall + zBars) / 2, 1, C3(220, 230, 255))
	end
	box(inn, "CellWall", x1 - 0.4, y, math.min(zWall, zBars), x1 + 0.4, y + 14, math.max(zWall, zBars), T.inner)
end
cellRow(-52, 52, -58, -42, F1); cellRow(-52, 52, 58 - 0.1, 42, F1)
cellRow(-52, 52, -58, -42, F2); cellRow(-52, 52, 58 - 0.1, 42, F2)
-- front cells would block the door: open a gap in the middle of the north row instead
-- (the front row's middle cell is the entrance hall)
for _, d in inn:GetChildren() do
	if (d.Name == "CellBar" or d.Name == "CellWall" or d.Name == "BarTop") and d.Position.Y < 20 and d.Position.Z > 40 and math.abs(d.Position.X) < 10 then d:Destroy() end
end
for _, d in FURN:GetChildren() do
	local p = d:GetPivot().Position
	if p.Y < 20 and p.Z > 40 and math.abs(p.X) < 12 then d:Destroy() end
end
-- upper walkways in front of the upper cells
slab(-52, -42, 52, -35); slab(-52, 35, 52, 42)
railing("x", -34.7, -52, 52, F2); railing("x", 34.7, -52, 52, F2)
-- side wings: mess hall (west), warden + guard room (east) with stairs
wall(inn, "WestWing", "z", -52, -58, 58, F1, 20, { dr(0, 12, 14) }, I); wall(inn, "EastWing", "z", 52, -58, 58, F1, 20, { dr(0, 12, 14) }, I)
wall(inn, "WestWing2", "z", -52, -58, 58, F2, 20, { dr(-38, 6), dr(38, 6) }, I); wall(inn, "EastWing2", "z", 52, -58, 58, F2, 20, { dr(-38, 6), dr(38, 6) }, I)
slab(-78, -58, -52, 58); slab(52, -58, 66, 58); slab(66, -58, 78, 24)
stairs(67, 77.4, 56)
for _, z in { -40, -20, 0, 20, 40 } do F.table(at(-65, F1, z, "N"), 18, 4, 3, Steel, "Table"); F.bench(at(-65, F1, z - 3.5, "N"), 18, Steel); F.bench(at(-65, F1, z + 3.5, "N"), 18, Steel) end
F.desk(at(60, F1, -40, "W")); F.chair(at(56, F1, -40, "E"), Wd.dark, Fab.brown); F.cabinet(at(74, F1, -54, "W"), 6, 9); F.bookshelf(at(76.5, F1, -20, "W"), 8, 9)
for _, z in { 10, 20 } do G2.locker(at(76, F1, z, "W"), C3(60, 70, 60)) end
-- upper wing rooms: infirmary (west), armoury (east)
for _, z in { -40, -20, 0, 20, 40 } do G2.hospitalBed(at(-66, F2, z, "E"), true) end
for _, z in { -40, -30, -20 } do G2.locker(at(76, F2, z, "W"), C3(50, 60, 50)) end
F.crate(at(60, F2, -50, "N")); F.crate(at(60, F2, -10, "N")); F.barrel(at(56, F2, 10, "N"))
-- block floor: tables + a drain
for _, x in { -30, 0, 30 } do F.table(at(x, F1, 0, "N"), 8, 4, 3, Steel, "Table"); F.chair(at(x - 3, F1, 4, "N"), Steel); F.chair(at(x + 3, F1, -4, "S"), Steel) end
for _, x in { -40, -10, 20, 40 } do bulb(x, 43, 0, 8, C3(220, 230, 255)) end
for _, z in { -30, 30 } do fluoro(-65, 21, z); fluoro(65, 21, z); fluoro(-65, 42, z) end
for _, p in { { -20, F1, -10 }, { 30, F1, 10 }, { -40, F2, -38 } } do blood(p[1], p[2], p[3], 2.6) end
-- outside: watchtower + razor fence
local fac = model(DEC, "Facade")
local tw = model(fac, "Watchtower")
for _, p in { { 50, 74 }, { 58, 74 }, { 50, 82 }, { 58, 82 } } do box(tw, "Leg", p[1] - 0.6, 0, p[2] - 0.6, p[1] + 0.6, 30, p[2] + 0.6, T.trim) end
box(tw, "Hut", 48, 30, 72, 60, 38, 84, T.ext); box(tw, "HutRoof", 47, 38, 71, 61, 39, 85, T.roof)
local sl = box(tw, "Spotlight", 53, 33, 71.6, 55, 35, 72, st(M.Neon, nil, C3(240, 240, 220)), DECO)
local spot = Instance.new("SpotLight"); spot.Range = 60; spot.Angle = 40; spot.Brightness = 3; spot.Face = Enum.NormalId.Front; spot.Parent = sl
for x = -70, 70, 6 do if math.abs(x) > 22 then box(fac, "FencePost", x - 0.2, 0, 90, x + 0.2, 10, 90.4, T.trim) end end
for _, y in { 3, 6, 9 } do box(fac, "Wire", -70, y, 90.1, -22, y + 0.1, 90.3, T.iron); box(fac, "Wire", 22, y, 90.1, 70, y + 0.1, 90.3, T.iron) end
sign(fac, "CELLBLOCK 9", CFrame.new(0, 40, 60.8) * CFrame.Angles(0, math.pi, 0), 34, 6, st(M.Metal, nil, C3(200, 170, 40)), C3(20, 20, 20), Enum.Font.Oswald)
for _, p in { { -30, F1, -50 }, { 30, F1, -50 }, { 0, F1, -10 }, { -65, F1, 0 }, { -20, F2, -50 }, { 20, F2, 50 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
