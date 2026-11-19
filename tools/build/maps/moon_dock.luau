-- THE DOCKING BAY (the Black Moon, building 1: THE LOST ASTRONAUT, who breaks the hull and drops on you with his
-- jetpack). A tall hangar: a LANDING PAD in the middle (a big yellow-striped circle with lights) with a small SHUTTLE
-- parked on it (cover), stacks of CARGO CONTAINERS (cover), a gantry crane over the pad, AIRLOCK doors on the side
-- walls (warning stripes, red lights), fuel tanks, floor markings. At the back, behind a wall with two doorways: the
-- SUIT ROOM (spacesuits on racks, helmets on a shelf, a bench). Its east end: a SUIT LOCKER that slides (Secrets).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_dock.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 30
local rng = Random.new(51)
beginMap("Moon_Dock", moonTheme())
-- (2026-11-19) its own shape: a HANGAR - a ribbed half-cylinder vault, its arched end to the yard, hangar doors
local TOP = shell2({ H = H, ridge = "z", roof = "barrel", rise = 30, n = 14, roofStyle = st(M.CorrodedMetal, nil, C3(110, 114, 120)),
	front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, -30 }, right1 = { 44, -30 }, win = { w = 6, b = 6, t = 12 }, door = { w = 14, t = 20 } })
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
-- OUTSIDE (2026-11-19): THE LOST ASTRONAUT'S DOCKING BAY. A hangar vault with lit ribs, the arched end painted with
-- DOCK 01 and warning stripes round the great door, the two halves of the hangar door rolled aside on their rails,
-- landing lights in the dust, a shuttle parked beside it with its ramp down.
local OUT = model(DEC, "Outside")
-- ribs over the vault, with strip lights
for z = -56, 56, 14 do
	for k = 0, 13 do
		local a1, a2 = math.pi * k / 14, math.pi * (k + 1) / 14
		local p1 = Vector3.new(81.5 * math.cos(a1), TOP + 30.6 * math.sin(a1), z)
		local p2 = Vector3.new(81.5 * math.cos(a2), TOP + 30.6 * math.sin(a2), z)
		part(OUT, "Rib", Vector3.new(1.4, 1.6, (p2 - p1).Magnitude + 0.4), CFrame.lookAt((p1 + p2) / 2, p2) * CFrame.Angles(0, 0, 0), MOON.steelD, D())
	end
	local top = Vector3.new(0, TOP + 31.4, z)
	local g = box(OUT, "RibLight", -0.6, TOP + 31, z - 0.6, 0.6, TOP + 32, z + 0.6, MOON.blue, DECO)
	if z % 28 == 0 then light(g, 30, 1, C3(140, 200, 255)) end
	local _ = top
end
-- the arched end: the dock number, stripes round the door, the door halves rolled aside on a rail
sign(OUT, "DOCK 01", CFrame.new(0, TOP + 14, 60.7) * CFrame.Angles(0, math.pi, 0), 30, 9, st(M.SmoothPlastic, nil, C3(96, 100, 108)), C3(220, 180, 40), Enum.Font.SciFi)
hazard(OUT, -12, 12, 22, 24, 60.5)
for _, sx in { -1, 1 } do
	part(OUT, "DoorStripe", Vector3.new(2, 20, 0.2), CFrame.new(sx * 8, 12, 60.5), MOON.yellow, D())
	box(OUT, "DoorHalf", sx * 9, 2, 60.6, sx * 23, 22, 61.6, MOON.steel, DECO)
	for y = 4, 20, 4 do box(OUT, "DoorRib", sx * 9, y, 61.6, sx * 23, y + 0.6, 62, MOON.steelD, DECO) end
	moonBeacon(OUT, Vector3.new(sx * 9, 23, 61.4), C3(255, 160, 40), 22)
end
box(OUT, "DoorRail", -26, 22, 60.6, 26, 23, 62.2, MOON.steelD, DECO)
-- landing lights in the dust leading in
for z = 70, 110, 8 do for _, x in { -12, 12 } do
	local g = box(OUT, "LandingLight", x - 0.5, 0, z - 0.5, x + 0.5, 0.6, z + 0.5, MOON.blue, DECO)
	if z % 16 == 6 then light(g, 14, 0.8, C3(140, 200, 255)) end
end end
-- the shuttle parked outside (east, beyond the yard's fence), its ramp down
do
	local cf = CFrame.new(120, 0, 10) * CFrame.Angles(0, -0.6, 0)
	b(OUT, cf, "Fuselage", 14, 10, 44, 0, 9, 0, MOON.white, D())
	part(OUT, "Nose", Vector3.new(14, 10, 12), cf * CFrame.new(0, 9, -26) * CFrame.Angles(-0.35, 0, 0), MOON.white, D())
	b(OUT, cf, "Cockpit", 10, 3, 0.4, 0, 12, -30, MOON.glass, D())
	for _, sx in { -1, 1 } do
		part(OUT, "Wing", Vector3.new(22, 1.2, 18), cf * CFrame.new(sx * 16, 6, 8) * CFrame.Angles(0, 0, sx * -0.08), MOON.panelD, D())
		b(OUT, cf, "Engine", 5, 5, 8, sx * 4, 8, 24, MOON.steelD, D())
		local fl = b(OUT, cf, "EngineGlow", 3.6, 3.6, 0.4, sx * 4, 8, 28.2, MOON.blue, D())
		light(fl, 20, 1, C3(140, 200, 255))
	end
	b(OUT, cf, "Tail", 1.2, 12, 10, 0, 18, 18, MOON.white, D())
	part(OUT, "Ramp", Vector3.new(8, 0.6, 14), cf * CFrame.new(0, 2.4, 28) * CFrame.Angles(0.3, 0, 0), MOON.steel, D())
	for _, z in { -10, 10 } do for _, sx in { -1, 1 } do b(OUT, cf, "Gear", 1, 5, 1, sx * 5, 2.5, z, MOON.steelD, D()) end end
end
moonSign("THE DOCKING BAY", CFrame.new(0, 26.6, 61))
washLight(-30, 88, Vector3.new(-20, TOP + 10, 60), C3(190, 210, 255), 100, 2)
washLight(30, 88, Vector3.new(20, TOP + 10, 60), C3(190, 210, 255), 100, 2)
moonGrounds()
return endMap()
