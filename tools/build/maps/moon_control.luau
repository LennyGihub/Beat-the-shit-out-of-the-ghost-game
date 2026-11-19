-- THE CONTROL ROOM (the Black Moon, building 4: THE VOID KNIGHT, who cuts through the walls and throws you with his
-- grip). The base's bridge: rows of CONSOLES facing a great WINDOW on the back wall (the black sky, the Earth, stars),
-- big wall SCREENS (maps of the base, a red ALERT), the commander's chair on a raised step, a holo table in the middle
-- (a glowing map of the moon), red alert lights. At the back, behind the window wall with two doorways: the COMMS ROOM
-- (radio racks, a desk, headsets). Its west end: a MAP CABINET that slides (Secrets).
-- (The Knight needs KnightSpots: run tools/build/knight_spots.luau after building.)
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_control.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local rng = Random.new(54)
beginMap("Moon_Control", moonTheme({ inner = st(M.SmoothPlastic, nil, C3(68, 70, 80)) }))
-- (2026-11-19) its own shape: the base's COMMAND TOWER - a tall tower with a ring of slanted windows and a radar dish
local TOP = shell2({ H = H, roof = "flat", roofStyle = MOON.panelD, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	win = { w = 6, b = 5, t = 12 } })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "WindowWall", "x", -30, -78, 78, F1, H, { dr(-60, 10, 12), dr(60, 10, 12) }, I)

-- THE GREAT WINDOW in that wall (a glass band over the consoles), the sky and the Earth painted behind it
box(DEC, "WindowBlack", -46, F1 + 6, -30.8, 46, F1 + 18, -30.5, st(M.SmoothPlastic, nil, C3(4, 4, 10)), DECO)
box(DEC, "WindowGlass", -46, F1 + 6, -30.4, 46, F1 + 18, -30.2, MOON.glass, { deco = true, t = 0.75 })
for k = -3, 3 do box(DEC, "Mullion", k * 13 - 0.4, F1 + 6, -30.3, k * 13 + 0.4, F1 + 18, -30, MOON.steelD, DECO) end
for k = 0, 40 do
	local p = b(DEC, CFrame.new(rng:NextNumber(-45, 45), F1 + rng:NextNumber(6.5, 17.5), -30.45), "Star", 0.2, 0.2, 0.05, 0, 0, 0, st(M.Neon, nil, Color3.new(1, 1, 1)), DECO)
	local _ = p
	local _k = k
end
local earth = cyl(DEC, CFrame.new(22, F1 + 13, -30.42) * CFrame.Angles(math.pi / 2, 0, 0), "Earth", 7, 0.05, 0, 0, 0, MOON.earth, D())
cyl(DEC, CFrame.new(20.5, F1 + 14, -30.38) * CFrame.Angles(math.pi / 2, 0, 0), "EarthLand", 3, 0.05, 0, 0, 0, MOON.land, D())
light(earth, 24, 0.8, C3(120, 170, 255))
-- rows of CONSOLES facing the window (cover), each with screens and a chair
local cons = model(STR, "Consoles")
for _, row in { { z = -20 }, { z = -6 } } do
	for _, x in { -36, -12, 12, 36 } do
		part(cons, "Console", Vector3.new(12, 3.4, 3), CFrame.new(x, F1 + 1.7, row.z) * CFrame.Angles(0, 0, 0), MOON.panelD)
		part(DEC, "ConsoleTop", Vector3.new(12, 0.4, 3.4), CFrame.new(x, F1 + 3.6, row.z) * CFrame.Angles(-0.3, 0, 0), MOON.black, DECO)
		for k = -1, 1 do moonScreen(DEC, CFrame.new(x + k * 3.8, F1 + 5.4, row.z - 1.2), 3.2, 2, k == 0 and C3(255, 90, 80) or C3(90, 200, 255)) end
		for k = 0, 5 do box(DEC, "Key", x - 4.5 + k * 1.8, F1 + 3.75, row.z + 0.6, x - 3.9 + k * 1.8, F1 + 3.95, row.z + 1.1, k % 2 == 0 and MOON.green or MOON.blue, DECO) end
	end
end
-- the commander's step and chair, the holo table in the middle
box(STR, "Step", -10, F1, 22, 10, F1 + 1, 32, MOON.steelD)
box(STR, "ChairBase", -2, F1 + 1, 26, 2, F1 + 3.4, 30, MOON.black)
box(DEC, "ChairBack", -2, F1 + 3.4, 29, 2, F1 + 9, 30, MOON.black, DECO)
for _, sx in { -1, 1 } do box(DEC, "ChairArm", sx * 2.4 - 0.4, F1 + 3.4, 26, sx * 2.4 + 0.4, F1 + 4.6, 30, MOON.red, DECO) end
cyl(STR, CFrame.new(0, F1 + 1.6, 8), "HoloTable", 10, 3.2, 0, 0, 0, MOON.steelD)
local holo = ball(DEC, CFrame.new(0, F1 + 7, 8), "HoloMoon", 5, 0, 0, 0, st(M.Neon, nil, C3(150, 200, 255)), { deco = true, t = 0.55 })
light(holo, 22, 1.2, C3(140, 200, 255))
cyl(DEC, CFrame.new(0, F1 + 3.3, 8), "HoloRing", 8, 0.2, 0, 0, 0, MOON.blue, D())
-- big wall screens on the side walls: maps, a red ALERT
for _, p in { { -77.5, 32, math.pi / 2 }, { 77.5, 32, -math.pi / 2 }, { -77.5, 6, math.pi / 2 }, { 77.5, 6, -math.pi / 2 } } do
	moonScreen(DEC, CFrame.new(p[1], F1 + 9, p[2]) * CFrame.Angles(0, p[3], 0), 12, 6, p[2] == 6 and C3(255, 70, 60) or C3(90, 200, 255))
end
sign(DEC, "ALERT", CFrame.new(0, F1 + 19.5, 57.5) * CFrame.Angles(0, math.pi, 0), 14, 2.4, MOON.black, C3(255, 70, 60), Enum.Font.SciFi)
-- red alert lights along the ceiling
for _, x in { -50, -20, 20, 50 } do moonBeacon(DEC, Vector3.new(x, F1 + H - 1.4, 40), C3(255, 40, 40), 26) end
-- THE COMMS ROOM (behind the wall): radio racks, a desk, headsets
for _, x in { -40, -32, -24 } do
	box(STR, "RadioRack", x - 3, F1, -58, x + 3, F1 + 10, -55, MOON.black)
	for y = 1, 9, 1.5 do box(DEC, "RackLed", x - 2.4, F1 + y, -55, x + 2.4, F1 + y + 0.2, -54.8, (y % 3 < 1.5) and MOON.green or MOON.red, DECO) end
end
box(STR, "CommsDesk", 10, F1, -52, 30, F1 + 3, -46, MOON.panelD)
for k = 0, 2 do moonScreen(DEC, CFrame.new(14 + k * 6, F1 + 5, -51.4) * CFrame.Angles(0, 0, 0), 4, 2.4) end
-- THE STASH behind the map cabinet (x -78..-58, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", -58.2, F1, -58, -57, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", -78, F1, -43.2, -70, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", -64, F1, -43.2, -58.2, F1 + 12, -42, MOON.steelD)
box(sr, "Lintel", -70, F1 + 9, -43.2, -64, F1 + 12, -42, MOON.steelD)
box(sr, "Ceiling", -78, F1 + 12, -58, -57, F1 + 12.6, -42, MOON.panelD)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "MapCabinet")
door:SetAttribute("Slide", Vector3.new(6.4, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "Star map cabinet")
box(door, "Panel", -70, F1, -42.9, -64, F1 + 9, -40.6, MOON.panelD)
for y = 1.5, 7.5, 2 do box(door, "Panel", -69.6, F1 + y, -40.65, -64.4, F1 + y + 1.4, -40.4, MOON.steelL, DECO) end
box(door, "Trigger", -67.5, F1 + 4, -39.6, -66.5, F1 + 5, -38.6, MOON.panelD, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", -63 + k * 1.4, F1 + 0.06, -40 + k * 0.2, -62 + k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(150, 150, 156)), DECO) end
local loot = model(DEC, "Stash")
moonContainer(loot, CFrame.new(-68, F1, -52), C3(40, 40, 50), false)
local sg = b(loot, CFrame.new(-66, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, MOON.blue, { deco = true, t = 1 })
light(sg, 18, 1, C3(150, 210, 255))

-- lights: dim strips (the screens and the alerts light the room red and blue)
for _, p in { { -30, 30 }, { 30, 30 }, { -30, -12 }, { 30, -12 } } do fluoro(p[1], F1 + H - 1, p[2], C3(255, 215, 215)) end
for _, p in { { -30, -46 }, { 30, -46 } } do fluoro(p[1], F1 + H - 1, p[2], C3(210, 225, 255)) end
for _, p in { { -30, 40 }, { 20, 10 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 50 }, { 40, 50 }, { -50, 14 }, { 50, 14 }, { 0, -16 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-62, -42, -54, -34, F1)
-- OUTSIDE (2026-11-19): THE VOID KNIGHT'S CONTROL ROOM. The command tower rises from the back of the roof: a steel
-- shaft with lit slits, the cab at the top with a ring of slanted windows glowing red (ALERT), an antenna array and a
-- RADAR DISH that turns (attribute Spin: Client/WorldSpin). A sloped glass front over the door, red alert beacons.
local OUT = model(DEC, "Outside")
local TX, TZ = 0, -34
prism(OUT, "Shaft", TX, TZ, 13, TOP, TOP + 56, 8, MOON.steel, D())
for y = TOP + 8, TOP + 48, 10 do
	for k = 0, 3 do
		local a = k * math.pi / 2 + math.pi / 8
		local w = box(OUT, "ShaftSlit", 0, 0, 0, 1, 1, 1, MOON.blue, DECO)
		w.Size = Vector3.new(2, 5, 0.3)
		w.CFrame = CFrame.new(TX + math.cos(a) * 12.8, y, TZ + math.sin(a) * 12.8) * CFrame.Angles(0, -a + math.pi / 2, 0)
	end
end
-- the cab: a wider ring, slanted windows all round, a roof, the antennas, the dish
local CY = TOP + 56
prism(OUT, "CabFloor", TX, TZ, 22, CY, CY + 2, 12, MOON.steelD, D())
for k = 0, 11 do
	local a = (k + 0.5) * math.pi / 6
	local cf = CFrame.new(TX + math.cos(a) * 21.5, CY + 6.5, TZ + math.sin(a) * 21.5) * CFrame.Angles(0, -a + math.pi / 2, 0) * CFrame.Angles(0.25, 0, 0)
	part(OUT, "CabWindow", Vector3.new(11.6, 9, 0.4), cf, st(M.Neon, nil, C3(255, 70, 60)), { deco = true, t = 0.35 })
	part(OUT, "CabMullion", Vector3.new(0.8, 9.4, 0.8), CFrame.new(TX + math.cos(a + math.pi / 12) * 21.8, CY + 6.5, TZ + math.sin(a + math.pi / 12) * 21.8), MOON.steelD, D())
end
prism(OUT, "CabRoof", TX, TZ, 24, CY + 11, CY + 13, 12, MOON.steel, D())
light(box(OUT, "CabGlow", TX - 0.2, CY + 6, TZ - 0.2, TX + 0.2, CY + 6.4, TZ + 0.2, MOON.red, { deco = true, t = 1 }), 60, 1.8, C3(255, 70, 60))
for k = 0, 2 do
	local x = TX - 12 + k * 12
	box(OUT, "Antenna", x - 0.3, CY + 13, TZ + 10 - 0.3, x + 0.3, CY + 30 + k * 4, TZ + 10 + 0.3, MOON.steelL, DECO)
	moonBeacon(OUT, Vector3.new(x, CY + 30.6 + k * 4, TZ + 10), C3(255, 60, 50), 30)
end
do -- the radar dish on a short mast: it turns
	local rd = model(OUT, "Radar")
	box(rd, "RadarMast", TX - 0.8, CY + 13, TZ - 6.8, TX + 0.8, CY + 22, TZ - 5.2, MOON.steelD, DECO)
	local base = CFrame.new(TX, CY + 24, TZ - 6)
	part(rd, "RadarBar", Vector3.new(28, 2, 1), base, MOON.steelL, D())
	part(rd, "RadarFace", Vector3.new(26, 5, 0.6), base * CFrame.new(0, 0, -1.2) * CFrame.Angles(-0.3, 0, 0), MOON.white, D())
	part(rd, "RadarFeed", Vector3.new(1, 1, 5), base * CFrame.new(0, 0.6, -3.6), MOON.steelD, D())
	rd.WorldPivot = base
	rd:SetAttribute("Spin", 30)
end
-- the sloped glass front over the door, its frame, alert beacons along the roof edge
for k = 0, 5 do
	local x = -30 + k * 12
	if math.abs(x) > 4 then
		part(OUT, "FrontGlass", Vector3.new(11.6, 8, 0.4), CFrame.new(x, TOP - 4, 61.6) * CFrame.Angles(-0.4, 0, 0), st(M.Neon, nil, C3(90, 170, 220)), { deco = true, t = 0.45 })
	end
end
box(OUT, "FrontFrame", -36, TOP - 0.4, 60, 36, TOP + 0.6, 63.4, MOON.steelD, DECO)
for _, x in { -78, -40, 40, 78 } do moonBeacon(OUT, Vector3.new(x, TOP + 1.4, 59), C3(255, 60, 50), 26) end
sign(OUT, "COMMAND", CFrame.new(TX, TOP + 36, TZ + 13.4) * CFrame.Angles(0, math.pi, 0), 14, 3, MOON.steel, C3(200, 225, 255), Enum.Font.SciFi)
moonSign("THE CONTROL ROOM", CFrame.new(0, 20.6, 61))
washLight(-30, 90, Vector3.new(-6, TOP + 40, TZ), C3(200, 210, 255), 160, 2.4)
washLight(30, 90, Vector3.new(6, TOP + 40, TZ), C3(200, 210, 255), 160, 2.4)
moonGrounds()
return endMap()
