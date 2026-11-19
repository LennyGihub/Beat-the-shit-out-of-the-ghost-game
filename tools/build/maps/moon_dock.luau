-- THE DOCKING BAY (the Black Moon, building 1: THE LOST ASTRONAUT, who breaks the hull and drops on you with his
-- jetpack). A tall hangar: a LANDING PAD in the middle (a big yellow-striped circle with lights) with a small SHUTTLE
-- parked on it (cover), stacks of CARGO CONTAINERS (cover), a gantry crane over the pad, AIRLOCK doors on the side
-- walls (warning stripes, red lights), fuel tanks, floor markings. At the back, behind a wall with two doorways: the
-- SUIT ROOM (spacesuits on racks, helmets on a shelf, a bench). Its east end: a SUIT LOCKER that slides (Secrets).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_dock.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 30
local rng = Random.new(51)
beginMap("Moon_Dock", moonTheme())
shell({ two = false, H = H, roof = "flat", front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, -30 }, right1 = { 44, -30 },
	winW = 6, winB = 6, winT = 12 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "SuitWall", "x", -30, -78, 78, F1, 16, { dr(-30, 10, 12), dr(30, 10, 12) }, I)

-- THE LANDING PAD: a ring of stripes and lights, the shuttle on it
cyl(DEC, CFrame.new(0, F1 + 0.04, 14), "Pad", 40, 0.08, 0, 0, 0, MOON.panelD, D())
cyl(DEC, CFrame.new(0, F1 + 0.06, 14), "PadRing", 36, 0.08, 0, 0, 0, MOON.yellow, D())
cyl(DEC, CFrame.new(0, F1 + 0.08, 14), "PadIn", 33, 0.08, 0, 0, 0, MOON.panelD, D())
for k = 0, 15 do
	local a = k / 16 * math.pi * 2
	box(DEC, "PadLight", math.cos(a) * 19 - 0.4, F1 + 0.05, 14 + math.sin(a) * 19 - 0.4, math.cos(a) * 19 + 0.4, F1 + 0.3, 14 + math.sin(a) * 19 + 0.4, MOON.blue, DECO)
end
local sh = model(STR, "Shuttle")
local sc = CFrame.new(0, F1, 14)
b(sh, sc, "Hull", 10, 6, 18, 0, 4.4, 0, MOON.white)
b(DEC, sc, "Nose", 8, 4, 4, 0, 4.4, -10.5, MOON.white, DECO)
b(DEC, sc, "Cockpit", 6, 2, 3, 0, 6.2, -10, MOON.glass, DECO)
for _, sx in { -1, 1 } do
	part(DEC, "Wing", Vector3.new(10, 0.6, 8), sc * CFrame.new(sx * 9, 3.4, 3) * CFrame.Angles(0, 0, sx * -0.12), MOON.panelD, DECO)
	cyl(DEC, sc * CFrame.new(sx * 3, 4.4, 10.5) * CFrame.Angles(math.pi / 2, 0, 0), "Engine", 3, 3, 0, 0, 0, MOON.steelD, D())
	local fl = cyl(DEC, sc * CFrame.new(sx * 3, 4.4, 12.1) * CFrame.Angles(math.pi / 2, 0, 0), "EngineGlow", 2.2, 0.2, 0, 0, 0, MOON.blue, D())
	light(fl, 16, 1, C3(120, 200, 255))
	box(DEC, "Gear", sx * 3 - 0.3, F1, 13.7, sx * 3 + 0.3, F1 + 1.4, 14.3, MOON.steelD, DECO)
end
b(DEC, sc, "Stripe", 10.1, 0.6, 18.1, 0, 5.4, 0, MOON.orange, DECO)
-- CARGO CONTAINERS, stacked (cover)
for _, p in { { -56, 46, 0 }, { -56, 40, 0.1 }, { 58, 44, -0.1 }, { 56, -12, 0 }, { -58, -14, 0.05 }, { 34, 46, 1.57 } } do
	moonContainer(STR, CFrame.new(p[1], F1, p[2]) * CFrame.Angles(0, p[3], 0), ({ C3(150, 60, 40), C3(50, 90, 140), C3(70, 110, 60) })[rng:NextInteger(1, 3)], true)
end
moonContainer(DEC, CFrame.new(-56, F1 + 6, 43) * CFrame.Angles(0, 0.05, 0), C3(160, 130, 50), false)
-- THE GANTRY CRANE over the pad
for _, x in { -26, 26 } do box(DEC, "GantryLeg", x - 1, F1, 13, x + 1, F1 + 26, 15, MOON.yellow, DECO) end
box(DEC, "GantryBeam", -27, F1 + 24, 12.5, 27, F1 + 26, 15.5, MOON.yellow, DECO)
box(DEC, "Trolley", -3, F1 + 22.5, 12, 3, F1 + 24, 16, MOON.steelD, DECO)
box(DEC, "Cable", -0.1, F1 + 14, 13.9, 0.1, F1 + 22.5, 14.1, MOON.black, DECO)
box(DEC, "Hook", -0.6, F1 + 13, 13.4, 0.6, F1 + 14, 14.6, MOON.steelL, DECO)
-- AIRLOCK DOORS on the side walls: a frame with hazard stripes, a red light over each
for _, z in { 20, -8 } do
	for _, x in { -77.6, 77.6 } do
		local sx = x < 0 and 1 or -1
		box(DEC, "AirlockFrame", x, F1, z - 6, x + sx * 0.6, F1 + 13, z + 6, MOON.steelD, DECO)
		box(DEC, "AirlockDoor", x + sx * 0.6, F1 + 0.5, z - 5, x + sx * 0.9, F1 + 12, z + 5, MOON.steel, DECO)
		for k = 0, 5 do
			part(DEC, "Hazard", Vector3.new(0.1, 1, 2.2), CFrame.new(x + sx * 0.95, F1 + 1.5 + k * 1.8, z) * CFrame.Angles(0.8, 0, 0), k % 2 == 0 and MOON.yellow or MOON.black, DECO)
		end
		moonBeacon(DEC, Vector3.new(x + sx * 1, F1 + 14, z), C3(255, 50, 40), 20)
	end
end
-- fuel tanks along the back wall of the bay, floor markings
for _, x in { -40, -32, 32, 40 } do
	cyl(STR, CFrame.new(x, F1 + 4, -24), "FuelTank", 6, 8, 0, 0, 0, MOON.white)
	cyl(DEC, CFrame.new(x, F1 + 6, -24), "TankBand", 6.2, 0.8, 0, 0, 0, MOON.orange, D())
end
for z = -22, 54, 8 do box(DEC, "LaneMark", -1, F1 + 0.03, z, 1, F1 + 0.06, z + 4, MOON.yellow, DECO) end
-- THE SUIT ROOM (behind the wall): suits on racks, helmets, a bench
for k = 0, 5 do
	local x = -60 + k * 9
	box(DEC, "SuitBody", x - 1.4, F1 + 3.2, -57.4, x + 1.4, F1 + 7, -55.8, MOON.white, DECO)
	box(DEC, "SuitLegs", x - 1.2, F1 + 0.4, -57.2, x + 1.2, F1 + 3.2, -56, MOON.white, DECO)
	box(DEC, "Helmet", x - 1, F1 + 7.2, -57.4, x + 1, F1 + 9.2, -55.6, MOON.panel, DECO)
	box(DEC, "Visor", x - 0.7, F1 + 7.6, -55.65, x + 0.7, F1 + 8.8, -55.5, MOON.gold, DECO)
end
box(STR, "SuitBench", -20, F1, -44, 20, F1 + 2, -41, MOON.steelD)
box(DEC, "HelmetShelf", 10, F1 + 6, -57.8, 40, F1 + 6.4, -56.4, MOON.steelL, DECO)
for k = 0, 5 do ball(DEC, CFrame.new(12 + k * 5, F1 + 7.4, -57.1), "SpareHelmet", 2, 0, 0, 0, MOON.white, D()) end
-- THE STASH behind the suit locker (x 50..78, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", 49, F1, -58, 50.2, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", 50.2, F1, -43.2, 60, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", 66, F1, -43.2, 78, F1 + 12, -42, MOON.steelD)
box(sr, "Lintel", 60, F1 + 9, -43.2, 66, F1 + 12, -42, MOON.steelD)
box(sr, "Ceiling", 49, F1 + 12, -58, 78, F1 + 12.6, -42, MOON.panelD)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "SuitLocker")
door:SetAttribute("Slide", Vector3.new(-6.4, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "Dented suit locker")
box(door, "Panel", 60, F1, -42.9, 66, F1 + 9, -40.6, MOON.steel)
box(door, "Panel", 60.4, F1 + 7, -40.65, 65.6, F1 + 7.5, -40.4, MOON.orange, DECO)
box(door, "Panel", 62, F1 + 3, -40.65, 64, F1 + 6, -40.4, MOON.screen, DECO)
box(door, "Trigger", 62.5, F1 + 4, -39.6, 63.5, F1 + 5, -38.6, MOON.steel, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", 59 - k * 1.4, F1 + 0.06, -40 + k * 0.2, 60 - k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(150, 150, 156)), DECO) end
local loot = model(DEC, "Stash")
moonContainer(loot, CFrame.new(68, F1, -52) * CFrame.Angles(0, 1.57, 0), C3(60, 60, 70), false)
local sg = b(loot, CFrame.new(60, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, MOON.blue, { deco = true, t = 1 })
light(sg, 18, 1, C3(150, 210, 255))

-- lights: cold floodlights high in the bay, the suit room's strips
for _, p in { { -40, 14 }, { 40, 14 }, { 0, 40 }, { 0, -12 }, { -50, 44 }, { 50, 44 } } do fluoro(p[1], F1 + H - 1, p[2], C3(210, 225, 255)) end
for _, p in { { -30, -46 }, { 30, -46 } } do fluoro(p[1], F1 + 15, p[2], C3(210, 225, 255)) end
for _, p in { { -30, 30 }, { 20, -10 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 50 }, { 40, 50 }, { -36, 14 }, { 36, 14 }, { 0, -18 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(56, -42, 70, -34, F1)
moonSign("THE DOCKING BAY")
moonGrounds()
return endMap()
