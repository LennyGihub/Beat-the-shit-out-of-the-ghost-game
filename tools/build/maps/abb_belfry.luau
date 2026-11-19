-- THE BELL TOWER (the Ashen Abbey, building 3: THE BELL RINGER, who drops bells on you and tolls rings along the floor).
-- The tower's bell chamber, very high: a frame of heavy oak beams, GREAT BRONZE BELLS hanging in it high overhead,
-- their ropes hanging down to the floor (and tied off at cleats), a big wheel, a timber stair up the side wall to a
-- landing (decoration), sacks and crates, pigeons' mess, the clock's works on the back wall. Low walls of stacked
-- crates and a fallen beam are the only cover. At the back, behind a wall with two doorways: the RINGER'S ROOM (his
-- straw bed, a table, bell ropes coiled). Its west end: a WOODEN PANEL that slides (Secrets: the stash behind it).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_belfry.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 34
local rng = Random.new(43)
beginMap("Abb_Belfry", abbTheme({ floor = ABB.plank, floor2 = ABB.plank }))
-- (2026-11-19) its own shape: the bell hall under a hip roof and a GREAT SQUARE TOWER rising out of it
local TOP = shell2({ H = H, roof = "hip", rise = 18, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	win = { w = 4, b = 16, t = 28 }, door = { w = 12, t = 18 } })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "RoomWall", "x", -32, -78, 78, F1, 16, { dr(-30, 10, 12), dr(30, 10, 12) }, I)

-- THE BELL FRAME: oak posts and beams high up
local frame = model(DEC, "BellFrame")
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do box(frame, "Post", x - 1.2, F1, z - 1.2, x + 1.2, F1 + H - 2, z + 1.2, ABB.beam, DECO) end
	box(frame, "Beam", x - 1.2, F1 + 26, -6, x + 1.2, F1 + 28, 38, ABB.beam, DECO)
end
for _, z in { -6, 38 } do box(frame, "Beam", -49, F1 + 26, z - 1.2, 49, F1 + 28, z + 1.2, ABB.beam, DECO) end
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do
		part(frame, "Brace", Vector3.new(0.8, 8, 0.8), CFrame.new(x + 2.4, F1 + 23, z) * CFrame.Angles(0, 0, -0.6), ABB.beam, DECO)
		part(frame, "Brace", Vector3.new(0.8, 8, 0.8), CFrame.new(x - 2.4, F1 + 23, z) * CFrame.Angles(0, 0, 0.6), ABB.beam, DECO)
	end
end
-- the posts are solid (cover)
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do box(STR, "PostCore", x - 1, F1, z - 1, x + 1, F1 + 14, z + 1, ABB.beam) end
end
-- THE GREAT BELLS hanging from the frame (stacked bronze rings), each with its wheel and rope down to the floor
local function bell(x: number, z: number, r: number)
	local m = model(DEC, "GreatBell")
	local top = F1 + 25
	local rows = { { 0.6, 1.0 }, { 0.68, 1.4 }, { 0.78, 1.4 }, { 0.9, 1.4 }, { 1.0, 0.9 } }
	local y = top
	for _, row in rows do
		cyl(m, CFrame.new(x, y - row[2] / 2, z), "Bronze", r * 2 * row[1], row[2], 0, 0, 0, ABB.bronze, D())
		y -= row[2]
	end
	cyl(m, CFrame.new(x, y + 0.3, z), "Lip", r * 2.06, 0.5, 0, 0, 0, st(M.Metal, nil, C3(140, 96, 44)), D())
	ball(m, CFrame.new(x, y + 0.3, z), "Clapper", 1.4, 0, 0, 0, ABB.iron, D())
	cyl(m, CFrame.new(x, top + 1.4, z) * CFrame.Angles(0, 0, -math.pi / 2), "Wheel", 7, 0.5, 0, 0, 0, ABB.beam, D())
	box(m, "Yoke", x - 1, top, z - 4, x + 1, top + 1.6, z + 4, ABB.beam, DECO)
	box(m, "Rope", x - 0.12, F1, z + 3.4, x + 0.12, top + 1, z + 3.64, ABB.cloth, DECO)
	box(m, "Sally", x - 0.35, F1 + 5, z + 3.15, x + 0.35, F1 + 7, z + 3.85, ABB.red, DECO)
	cyl(m, CFrame.new(x, F1 + 0.3, z + 3.5), "RopeCoil", 2, 0.5, 0, 0, 0, ABB.cloth, D())
end
bell(-32, 16, 6); bell(0, 16, 8); bell(32, 16, 6); bell(-32, 44, 4); bell(32, 44, 4)
-- the timber stair up the left wall to a landing (decoration: the floor is the fight)
for k = 0, 11 do box(DEC, "Tread", -77, F1 + k * 1.2, 30 - k * 2.2, -71, F1 + k * 1.2 + 0.4, 28 - k * 2.2, ABB.plank, DECO) end
box(DEC, "Landing", -77.5, F1 + 14, -12, -64, F1 + 14.6, 4, ABB.plank, DECO)
for z = -12, 4, 4 do box(DEC, "Rail", -64.4, F1 + 14.6, z - 0.15, -64, F1 + 18, z + 0.15, ABB.beam, DECO) end
box(DEC, "RailTop", -64.6, F1 + 18, -12, -63.8, F1 + 18.4, 4, ABB.beam, DECO)
-- the clock's works on the back wall: a great wheel of gears
for k = 0, 4 do
	cyl(DEC, CFrame.new(-6 + k * 3, F1 + 20 + (k % 2) * 2, -30.8) * CFrame.Angles(math.pi / 2, 0, 0), "Gear", 3 + (k % 3) * 1.5, 0.5, 0, 0, 0, ABB.bronze, D())
end
-- cover on the floor: crate walls, a fallen beam, sacks
local cover = model(STR, "Cover")
for _, p in { { -46, 52 }, { 46, 52 }, { -60, 10 }, { 60, 24 }, { -14, 0 }, { 14, 30 } } do
	box(cover, "Crates", p[1] - 3, F1, p[2] - 2, p[1] + 3, F1 + 5, p[2] + 2, ABB.plank)
	box(DEC, "CrateTop", p[1] - 2.5, F1 + 5, p[2] - 1.5, p[1] + 0.5, F1 + 7.5, p[2] + 1.5, ABB.plank, DECO)
end
part(cover, "FallenBeam", Vector3.new(2.4, 2.4, 22), CFrame.new(-2, F1 + 1.2, 46) * CFrame.Angles(0, 1.2, 0.1), ABB.beam)
for k = 0, 5 do part(DEC, "Sack", Vector3.new(2.2, 1.4, 1.6), CFrame.new(66 + (k % 3) * 2.4, F1 + 0.7 + math.floor(k / 3) * 1.3, -12) * CFrame.Angles(0, rng:NextNumber(-0.3, 0.3), 0), ABB.cloth, DECO) end
-- pigeons' mess and feathers on the floor
for k = 0, 30 do
	local x, z = rng:NextNumber(-74, 74), rng:NextNumber(-26, 56)
	part(DEC, "Spot", Vector3.new(0.6, 0.04, 0.6), CFrame.new(x, F1 + 0.03, z) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), st(M.SmoothPlastic, nil, C3(190, 186, 176)), DECO)
	local _ = k
end
-- THE RINGER'S ROOM (behind the wall): a straw bed, a table, coiled ropes
box(STR, "Bed", -64, F1, -56, -52, F1 + 1.4, -48, ABB.cloth)
part(DEC, "Straw", Vector3.new(11, 0.6, 7), CFrame.new(-58, F1 + 1.7, -52), st(M.Grass, nil, C3(190, 160, 90)), DECO)
box(STR, "Table", -10, F1, -52, 8, F1 + 3.2, -46, ABB.beam)
cyl(DEC, CFrame.new(-4, F1 + 3.6, -49), "Bowl", 1.6, 0.6, 0, 0, 0, ABB.plank, D())
for _, x in { 20, 28 } do for k = 0, 2 do cyl(DEC, CFrame.new(x, F1 + 0.25 + k * 0.4, -52), "Coil", 3.2 - k * 0.5, 0.4, 0, 0, 0, ABB.cloth, D()) end end
-- THE STASH behind the wooden panel (x -78..-58, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", -58.2, F1, -58, -57, F1 + 12, -42, ABB.beam)
box(sr, "Wall", -78, F1, -43.2, -70, F1 + 12, -42, ABB.beam)
box(sr, "Wall", -64, F1, -43.2, -58.2, F1 + 12, -42, ABB.beam)
box(sr, "Lintel", -70, F1 + 9, -43.2, -64, F1 + 12, -42, ABB.beam)
box(sr, "Ceiling", -78, F1 + 12, -58, -57, F1 + 12.6, -42, ABB.beam)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "WoodPanel")
door:SetAttribute("Slide", Vector3.new(6.4, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "Loose wooden panel")
box(door, "Panel", -70, F1, -42.9, -64, F1 + 9, -40.6, ABB.plank)
for y = 1, 8, 2.4 do box(door, "Panel", -69.8, F1 + y, -40.65, -64.2, F1 + y + 0.3, -40.4, ABB.beam, DECO) end
box(door, "Trigger", -67.5, F1 + 4, -39.6, -66.5, F1 + 5, -38.6, ABB.plank, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", -63 + k * 1.4, F1 + 0.06, -40 + k * 0.2, -62 + k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(150, 130, 100)), DECO) end
local loot = model(DEC, "Stash")
abbCandles(loot, Vector3.new(-74, F1, -54), rng, 5)
for k = 0, 2 do cyl(loot, CFrame.new(-66 + k * 3, F1 + 0.8, -55), "HandBell", 1.4, 1.6, 0, 0, 0, ABB.bronze, D()) end

-- lights: lanterns on the posts, a red glow through the louvres
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do abbLantern(LIT, Vector3.new(x, F1 + 10, z + (z < 10 and 1.6 or -1.6)), 26) end
end
for _, p in { { -30, -46 }, { 30, -46 } } do bulb(p[1], F1 + 15, p[2], 2, C3(255, 180, 110)) end
for _, p in { { -20, 20 }, { 40, 0 }, { -40, -50 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 52 }, { 40, 52 }, { 0, 30 }, { -30, 0 }, { 30, 0 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-62, -42, -54, -34, F1)
-- OUTSIDE (2026-11-19): THE BELL RINGER'S TOWER. A square stone tower rises out of the hall's roof: buttressed corners,
-- lancet slits, clock faces, the open BELFRY with the great bells hanging in it, a parapet of pinnacles and a tall
-- pyramid spire. A deep pointed portal at the front, a round window over it, crows.
local OUT = model(DEC, "Outside")
local TX0, TX1, TZ0, TZ1 = -20, 20, -40, 0
local TS = ABB.stone
local yb = TOP + 54 -- the belfry's floor
-- the shaft up to the belfry
box(OUT, "TowerShaft", TX0, TOP, TZ0, TX1, yb, TZ1, TS, DECO)
for _, c in { { TX0, TZ0 }, { TX1, TZ0 }, { TX0, TZ1 }, { TX1, TZ1 } } do box(OUT, "TowerCorner", c[1] - 2, TOP, c[2] - 2, c[1] + 2, yb + 22, c[2] + 2, ABB.stoneD, DECO) end
for _, y in { TOP + 10, TOP + 28 } do
	box(OUT, "Slit", -1, y, TZ1 + 0.1, 1, y + 7, TZ1 + 0.3, st(M.SmoothPlastic, nil, C3(14, 8, 8)), DECO)
	box(OUT, "Band", TX0 - 0.6, y + 9, TZ0 - 0.6, TX1 + 0.6, y + 10, TZ1 + 0.6, ABB.stoneD, DECO)
end
-- clock faces on the front and the sides
for _, f in { { 0, TZ1 + 0.3, 0 }, { TX1 + 0.3, -20, -math.pi / 2 }, { TX0 - 0.3, -20, math.pi / 2 } } do
	local cf = CFrame.new(f[1], TOP + 44, f[2]) * CFrame.Angles(0, f[3], 0)
	cyl(OUT, cf * CFrame.Angles(math.pi / 2, 0, 0), "ClockFace", 12, 0.3, 0, 0, 0, st(M.Neon, nil, C3(240, 220, 170)), D())
	cyl(OUT, cf * CFrame.new(0, 0, -0.1) * CFrame.Angles(math.pi / 2, 0, 0), "ClockRim", 13.4, 0.3, 0, 0, 0, ABB.iron, D())
	b(OUT, cf, "HourHand", 0.6, 4, 0.2, 0, 1.6, 0.3, ABB.iron, D())
	part(OUT, "MinuteHand", Vector3.new(0.4, 5.4, 0.2), cf * CFrame.new(1.4, -1.6, 0.3) * CFrame.Angles(0, 0, 0.9), ABB.iron, D())
end
light(box(OUT, "ClockGlow", -0.1, TOP + 44, TZ1 + 4, 0.1, TOP + 44.2, TZ1 + 4.2, ABB.holy, { deco = true, t = 1 }), 26, 1, C3(255, 220, 160))
-- the belfry: open arches on four sides (corner piers + lintels), the bells in their frame
box(OUT, "BelfryFloor", TX0, yb, TZ0, TX1, yb + 1, TZ1, ABB.beam, DECO)
for _, e in { { TX0, TZ0, TX1, TZ0 + 1.6 }, { TX0, TZ1 - 1.6, TX1, TZ1 }, { TX0, TZ0, TX0 + 1.6, TZ1 }, { TX1 - 1.6, TZ0, TX1, TZ1 } } do
	box(OUT, "BelfryLintel", e[1], yb + 17, e[2], e[3], yb + 22, e[4], TS, DECO)
end
box(OUT, "BellBeam", TX0, yb + 15, -21, TX1, yb + 16.4, -19, ABB.beam, DECO)
for _, bp in { { -8, 9 }, { 8, 7 } } do
	local bx, bd = bp[1], bp[2]
	revolve(OUT, "GreatBell", bx, -20, { { bd / 2, yb + 4 }, { bd * 0.46, yb + 6 }, { bd * 0.32, yb + 11 }, { bd * 0.24, yb + 14 }, { 0, yb + 15 } }, 12, ABB.bronze)
	cyl(OUT, CFrame.new(bx, yb + 4.5, -20), "BellLip", bd + 0.6, 1, 0, 0, 0, ABB.bronze, D())
end
light(box(OUT, "BelfryGlow", -0.1, yb + 8, -20.1, 0.1, yb + 8.2, -19.9, ABB.ember, { deco = true, t = 1 }), 60, 2.4, C3(255, 150, 80))
light(box(OUT, "SpireBeacon", -0.6, yb + 79, -20.6, 0.6, yb + 80.2, -19.4, ABB.lava, DECO), 50, 1.6, C3(255, 70, 40))
washLight(0, 100, Vector3.new(0, yb + 14, -2), C3(255, 140, 100), 200, 2.6)
-- the parapet, its pinnacles and the spire
box(OUT, "Parapet", TX0 - 1.4, yb + 22, TZ0 - 1.4, TX1 + 1.4, yb + 25, TZ1 + 1.4, ABB.stoneD, DECO)
for _, c in { { TX0, TZ0 }, { TX1, TZ0 }, { TX0, TZ1 }, { TX1, TZ1 } } do spire(OUT, c[1], c[2], 2.6, yb + 25, 12, 4, ABB.stone, D()) end
spire(OUT, 0, -20, 19, yb + 25, 56, 4, st(M.Slate, nil, C3(34, 32, 36)), D())
box(OUT, "SpireCross", -0.4, yb + 81, -20.4, 0.4, yb + 89, -19.6, ABB.iron, DECO)
box(OUT, "SpireCross", -2.4, yb + 85.6, -20.4, 2.4, yb + 86.4, -19.6, ABB.iron, DECO)
-- the portal: stepped pointed arches round the door, a round window over it, buttresses at the corners
for k = 0, 2 do abbArch(OUT, 0, 2, 60.6 + k * 0.9, 14 + k * 3, 18, k % 2 == 0 and ABB.stoneD or ABB.stone, 1.2, 1) end
cyl(OUT, CFrame.new(0, 31, 60.4) * CFrame.Angles(math.pi / 2, 0, 0), "RoundWindow", 7, 0.4, 0, 0, 0, st(M.Neon, nil, C3(200, 80, 40)), D())
cyl(OUT, CFrame.new(0, 31, 60.2) * CFrame.Angles(math.pi / 2, 0, 0), "RoundRim", 8.4, 0.4, 0, 0, 0, ABB.stoneD, D())
for _, c in { { -80, 1 }, { 80, 1 } } do abbButtress(OUT, c[1], 60, Vector3.new(0, 0, 1), 30) end
for _, x in { -48, 48 } do abbButtress(OUT, x, 60, Vector3.new(0, 0, 1), 26) end
for k = 1, 5 do
	local cf = CFrame.new(-16 + k * 6, yb + 25.4, TZ1 + 0.6) * CFrame.Angles(0, k, 0)
	b(OUT, cf, "Crow", 0.9, 0.9, 1.8, 0, 0, 0, st(M.SmoothPlastic, nil, C3(16, 14, 18)), D())
	b(OUT, cf, "CrowHead", 0.6, 0.6, 0.6, 0, 0.6, -0.9, st(M.SmoothPlastic, nil, C3(16, 14, 18)), D())
end
abbSign("THE BELL TOWER", CFrame.new(0, 24.6, 61.4))
washLight(-30, 88, Vector3.new(-6, TOP + 40, -2), C3(255, 170, 130), 140, 2.4)
washLight(30, 88, Vector3.new(6, TOP + 40, -2), C3(255, 170, 130), 140, 2.4)
abbGrounds()
return endMap()
