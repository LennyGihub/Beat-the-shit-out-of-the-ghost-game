-- THE CONTROL ROOM (the Black Moon, building 4: THE VOID KNIGHT, who cuts through the walls and throws you with his
-- grip). The base's bridge: rows of CONSOLES facing a great WINDOW on the back wall (the black sky, the Earth, stars),
-- big wall SCREENS (maps of the base, a red ALERT), the commander's chair on a raised step, a holo table in the middle
-- (a glowing map of the moon), red alert lights. At the back, behind the window wall with two doorways: the COMMS ROOM
-- (radio racks, a desk, headsets). Its west end: a MAP CABINET that slides (Secrets).
-- (The Knight needs KnightSpots: run tools/build/knight_spots.luau after building.)
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_control.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local rng = Random.new(54)
beginMap("Moon_Control", moonTheme({ inner = st(M.SmoothPlastic, nil, C3(68, 70, 80)) }))
shell({ two = false, H = H, roof = "flat", front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 6, winB = 5, winT = 12 })
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
moonSign("THE CONTROL ROOM")
moonGrounds()
return endMap()
