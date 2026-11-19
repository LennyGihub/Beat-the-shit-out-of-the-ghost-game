-- THE LIGHTHOUSE (Blackwater Harbor, building 3: THE KEEPER, whose lamp's beam sweeps the room and whose flash
-- blinds whoever looks at him). The keeper's house at the foot of the tower: in the middle the TOWER'S STONE BASE
-- (the big cover from his beam) with an iron stair winding up it, stacks of oil barrels and crates of spare lenses
-- (more cover), a lens on a stand. West, behind a wall with two doorways: THE KEEPER'S QUARTERS - his bed, his
-- stove, his table and logbook, a ship in a bottle; his BOOKCASE pulls away (Secrets: the room behind it).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_lighthouse.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 24
local rng = Random.new(33)
beginMap("Harb_Lighthouse", harbTheme({ ext = st(M.Plaster, nil, C3(210, 206, 196)), inner = st(M.Plaster, nil, C3(170, 162, 146)),
	floor = st(M.Cobblestone, "PS2_Stone1", C3(110, 106, 100)) }))
shell({ two = false, H = H, roof = "gable", pitch = 0.45, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 5, winB = 6, winT = 12 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "QuartersWall", "z", -44, -58, 58, F1, H, { dr(30, 9, 12), dr(-20, 9, 12) }, I)

-- THE TOWER'S BASE: a big round stone column through the roof, a red band, the iron stair winding round it
local tw = model(STR, "TowerBase")
cyl(tw, CFrame.new(8, F1 + 16, -4), "Column", 20, 34, 0, 0, 0, HARB.stone)
cyl(DEC, CFrame.new(8, F1 + 8, -4), "RedBand", 20.6, 2, 0, 0, 0, HARB.red, D())
cyl(DEC, CFrame.new(8, F1 + 18, -4), "RedBand", 20.6, 2, 0, 0, 0, HARB.red, D())
for k = 0, 17 do
	local a = k / 18 * math.pi * 2 * 1.5
	local p = Vector3.new(8 + math.cos(a) * 12.2, F1 + 0.6 + k * 1.15, -4 + math.sin(a) * 12.2)
	part(DEC, "StairStep", Vector3.new(4, 0.4, 2.2), CFrame.lookAt(p, Vector3.new(8, p.Y, -4)) * CFrame.Angles(0, math.pi / 2, 0), HARB.iron, DECO)
	part(DEC, "StairPost", Vector3.new(0.2, 3, 0.2), CFrame.new(p + (p - Vector3.new(8, p.Y, -4)).Unit * 1.9 + Vector3.new(0, 1.5, 0)), HARB.iron, DECO)
end
-- a door into the tower (shut), a sign
box(DEC, "TowerDoor", 5, F1, 5.8, 11, F1 + 9, 6.6, HARB.sidingD, DECO)
sign(DEC, "TO THE LAMP", CFrame.new(8, F1 + 10.5, 6.7) * CFrame.Angles(0, math.pi, 0), 6, 1.2, HARB.plankD, C3(230, 215, 170), Enum.Font.Creepster)
-- oil barrels and lens crates (cover)
for _, p in { { -26, 36 }, { 40, 40 }, { 56, 10 }, { -24, -36 }, { 52, -40 } } do
	local st0 = model(STR, "BarrelStack")
	for i = 0, 1 do
		for j = 0, 1 do cyl(st0, CFrame.new(p[1] + i * 3 - 1.5, F1 + 2, p[2] + j * 3 - 1.5), "OilBarrel", 2.8, 4, 0, 0, 0, i == j and HARB.red or HARB.rust) end
	end
	cyl(st0, CFrame.new(p[1], F1 + 6, p[2]), "OilBarrel", 2.8, 4, 0, 0, 0, HARB.rust)
end
for _, p in { { 66, 30 }, { -30, 14 }, { 66, -20 } } do
	box(STR, "LensCrate", p[1] - 3.5, F1, p[2] - 3.5, p[1] + 3.5, F1 + 5, p[2] + 3.5, HARB.plank)
	box(STR, "LensCrate", p[1] - 2.5, F1 + 5, p[2] - 2.5, p[1] + 2.5, F1 + 9, p[2] + 2.5, HARB.plankD)
end
-- a great lens on its stand (spare): rings of glass
local ln = model(DEC, "Lens")
cyl(ln, CFrame.new(40, F1 + 2, 22), "LensStand", 2, 4, 0, 0, 0, HARB.iron, D())
for k = 0, 4 do cyl(ln, CFrame.new(40, F1 + 7, 22) * CFrame.Angles(math.pi / 2, 0, 0), "LensRing", 7 - k * 1.2, 0.6 + k * 0.2, 0, 0, 0, st(M.Glass, nil, C3(230, 240, 220)), { deco = true, t = 0.35 }) end
-- THE KEEPER'S QUARTERS (x -78..-44)
local q = model(STR, "Quarters")
box(q, "Bed", -76, F1, 30, -66, F1 + 2.6, 40, HARB.plankD)
box(DEC, "Blanket", -75.6, F1 + 2.6, 30.4, -66.4, F1 + 3, 39.6, st(M.Fabric, nil, C3(110, 40, 36)), DECO)
box(DEC, "Pillow", -75.4, F1 + 3, 37, -71, F1 + 3.6, 39.4, HARB.white, DECO)
box(q, "Stove", -76, F1, 6, -70, F1 + 5, 12, HARB.iron)
local fire = box(DEC, "StoveFire", -70.1, F1 + 1, 7.5, -69.9, F1 + 3, 10.5, st(M.Neon, nil, C3(255, 120, 40)), DECO)
light(fire, 18, 1.4, C3(255, 140, 70))
cyl(DEC, CFrame.new(-73, F1 + 14, 9), "StovePipe", 1.2, 18, 0, 0, 0, HARB.iron, D())
box(q, "Table", -62, F1, -6, -52, F1 + 3.4, 2, HARB.plank)
box(DEC, "Logbook", -59, F1 + 3.4, -3, -56, F1 + 3.8, -1, st(M.Fabric, nil, C3(90, 50, 30)), DECO)
box(DEC, "Bottle", -54, F1 + 3.4, -4, -53, F1 + 5.6, -3, st(M.Glass, nil, C3(150, 200, 180)), { deco = true, t = 0.4 })
box(DEC, "BottleShip", -54, F1 + 4, -4, -53, F1 + 4.8, -3, HARB.white, DECO)
harbLantern(DEC, Vector3.new(-57, F1 + 4.6, 1))
-- his bookcase on the back wall: it pulls away (Secrets), the stash room behind it (x -78..-60, z -58..-44)
local sr = model(STR, "StashRoom")
box(sr, "Wall", -60, F1, -58, -58.8, F1 + 12, -44, HARB.sidingD)
box(sr, "Wall", -78, F1, -45.2, -72, F1 + 12, -44, HARB.sidingD)
box(sr, "Wall", -66, F1, -45.2, -60, F1 + 12, -44, HARB.sidingD)
box(sr, "Lintel", -72, F1 + 9, -45.2, -66, F1 + 12, -44, HARB.sidingD)
box(sr, "Ceiling", -78, F1 + 12, -58, -58.8, F1 + 12.6, -44, HARB.beam)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "Bookcase")
door:SetAttribute("Slide", Vector3.new(6.2, 0, 0)); door:SetAttribute("Action", "Pull"); door:SetAttribute("Object", "The keeper's bookcase")
box(door, "Panel", -72, F1, -44.6, -66, F1 + 9, -42.6, HARB.plankD)
for r = 0, 2 do
	box(door, "Panel", -71.6, F1 + 1.5 + r * 2.6, -42.7, -66.4, F1 + 1.8 + r * 2.6, -42.4, HARB.beam, DECO)
	for k = 0, 6 do
		box(door, "Panel", -71.4 + k * 0.7, F1 + 1.8 + r * 2.6, -42.9, -70.9 + k * 0.7, F1 + 3.8 + r * 2.6, -42.5,
			st(M.Fabric, nil, ({ C3(110, 40, 36), C3(40, 70, 100), C3(60, 90, 50), C3(120, 100, 60) })[(k + r) % 4 + 1]), DECO)
	end
end
box(door, "Trigger", -69.5, F1 + 4, -41.8, -68.5, F1 + 5, -40.8, HARB.plank, { deco = true, t = 1 })
-- (the clue: one book sticks out, and the floor is scratched)
box(DEC, "LooseBook", -69.4, F1 + 4.4, -42.4, -68.8, F1 + 6.4, -41.4, st(M.Fabric, nil, C3(200, 160, 50)), DECO)
for k = 0, 3 do box(DEC, "Scrape", -72 + k * 1.6, F1 + 0.06, -42 + k * 0.1, -71 + k * 1.6, F1 + 0.08, -40.6 + k * 0.1, st(M.SmoothPlastic, nil, C3(140, 130, 116)), DECO) end
local loot = model(DEC, "Stash")
harbCoil(loot, Vector3.new(-74, F1, -54))
for k = 0, 2 do cyl(loot, CFrame.new(-66 + k * 2.5, F1 + 2, -55), "OldBarrel", 2.2, 4, 0, 0, 0, HARB.rust, D()) end
local sg = b(loot, CFrame.new(-68, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, HARB.lamp, { deco = true, t = 1 })
light(sg, 18, 1, C3(255, 220, 150))

-- lights: storm lanterns hung round the hall, warm in the quarters
for _, p in { { -30, 40 }, { 40, 48 }, { 60, -2 }, { -30, -10 }, { 30, -40 }, { 66, 44 } } do harbLantern(DEC, Vector3.new(p[1], F1 + 12, p[2]), 28) end
for _, p in { { -62, 30 }, { -62, -20 } } do bulb(p[1], F1 + H - 1, p[2], 3, C3(255, 200, 150)) end
for _, p in { { 20, 30 }, { -10, -30 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -20, 44 }, { 40, 30 }, { 50, -20 }, { -20, -20 }, { -60, 20 }, { 30, 50 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-74, -42, -64, -34, F1) -- (in front of the bookcase)
harbSign("THE LIGHTHOUSE")
harbGrounds()
return endMap()
