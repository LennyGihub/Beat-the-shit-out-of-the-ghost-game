-- EREBUS STATION: a dead warship that came down in the woods. Steel everywhere, strip lights that flicker, a reactor
-- still burning in its heart. Two storeys on the usual footprint (maplib's shell), flat roof, hardly a window.
--   GROUND: the HANGAR behind the front door (an interceptor still parked in it), the CARGO BAY to the west and the
--           ARMORY to the east; a corridor across the whole ship; behind it the DETENTION BLOCK (three cells), the
--           REACTOR ROOM and ENGINEERING.
--   UPPER:  the BRIDGE over the hangar (consoles, the commander's chair, a holo table), the CREW QUARTERS and the
--           MESS in the wings; the corridor again; COMMS, the reactor's upper gallery and the OFFICERS' cabin.
-- Two half-turn stairs (maplib's stair kit), one in each wing against the outside wall.
-- Everything is hand-built from blocks (consoles, the reactor, the interceptor): no meshes.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/station.luau
-- then furnish (ONLY = "Station"), detail (TARGET = "Station"), phones and doors_clear like every other map.
local C3 = Color3.fromRGB
local PANEL = st(M.Metal, nil, C3(78, 84, 96))
local PANEL_D = st(M.Metal, nil, C3(46, 50, 58))
local PLATE = st(M.DiamondPlate, nil, C3(58, 62, 70))
local TRIM = st(M.Metal, nil, C3(28, 30, 36))
local HAZARD = st(M.SmoothPlastic, nil, C3(214, 170, 30))
local BLACK = st(M.SmoothPlastic, nil, C3(14, 14, 16))
local RED = C3(255, 60, 44)
local COOL = C3(196, 222, 255)
local SCREEN = C3(90, 200, 255)
local function D() return { deco = true } end
local function neon(c) return st(M.Neon, nil, c) end

beginMap("Station", {
	floor = PLATE, floor2 = PLATE, inner = PANEL, wain = false, ext = st(M.Metal, nil, C3(48, 52, 60)), trim = TRIM,
	ceiling = PANEL_D, roof = st(M.Metal, nil, C3(34, 36, 42)), found = st(M.Concrete, nil, C3(48, 50, 54)), door = PANEL_D, porch = PLATE,
	lanternColor = COOL, floodColor = C3(190, 210, 240), iron = TRIM,
})
shell({ two = true, H = 20, roof = "flat", front1 = { -60, 60 }, back1 = {}, left1 = {}, right1 = {}, front2 = { -24, 0, 24 }, back2 = {}, left2 = {}, right2 = {},
	winW = 5, winB = 9, winT = 14 })
local inn = model(STR, "Interior")
local I = INT()

-- STAIRS (before the upper floor: each one gives its hole) ----------------------------------------------------
local SK = { step = PLATE, trim = TRIM, wall = PANEL, kind = "parapet" }
local _, holeW = dogleg(STR, { cf = CFrame.new(-69.25, F1, 36), W = 15.5, L = 23.5, mir = 1, S = SK, low = { a = true, e = true }, up = { a = true, e = true } })
local _, holeE = dogleg(STR, { cf = CFrame.new(69.25, F1, 36), W = 15.5, L = 23.5, mir = -1, S = SK, low = { a = true, e = true }, up = { a = true, e = true } })
for _, x in { -69.25, 69.25 } do
	keepClear(x - 8, 36, x + 8, 45, F1); keepClear(x - 8, 36, x + 8, 45, F2)
end

-- THE UPPER FLOOR, with the two stair holes cut out -----------------------------------------------------------
local function minus(rects, h)
	local out = {}
	for _, r in rects do
		if h[3] <= r[1] or h[1] >= r[3] or h[4] <= r[2] or h[2] >= r[4] then
			table.insert(out, r)
		else
			if h[1] > r[1] then table.insert(out, { r[1], r[2], h[1], r[4] }) end
			if h[3] < r[3] then table.insert(out, { h[3], r[2], r[3], r[4] }) end
			local a, c = math.max(r[1], h[1]), math.min(r[3], h[3])
			if h[2] > r[2] then table.insert(out, { a, r[2], c, h[2] }) end
			if h[4] < r[4] then table.insert(out, { a, h[4], c, r[4] }) end
		end
	end
	return out
end
local rects = {}
for i = 0, 5 do
	for j = 0, 3 do table.insert(rects, { -78 + i * 26, -58 + j * 29, -78 + (i + 1) * 26, -58 + (j + 1) * 29 }) end
end
rects = minus(minus(rects, holeW), holeE)
for _, r in rects do
	if r[3] - r[1] > 0.05 and r[4] - r[2] > 0.05 then slab(r[1], r[2], r[3], r[4]) end
end

-- WALLS: the same plan on both storeys -------------------------------------------------------------------------
for _, y in { F1, F2 } do
	-- the corridor across the ship (z -6..10)
	wall(inn, "CorridorN", "x", 10, -78, 78, y, 20, { dr(-52, 8, 12), dr(0, 12, 14), dr(52, 8, 12) }, I)
	wall(inn, "CorridorS", "x", -6, -78, 78, y, 20, { dr(-52, 7, 12), dr(0, 10, 13), dr(52, 7, 12) }, I)
	-- the hangar / the bridge in the middle of the front, a wing at each side
	wall(inn, "WingW", "z", -40, 10.6, 58, y, 20, { dr(46, 8, 12) }, I)
	wall(inn, "WingE", "z", 40, 10.6, 58, y, 20, { dr(46, 8, 12) }, I)
	-- behind the corridor: three rooms
	wall(inn, "CoreW", "z", -26, -58, -6.6, y, 20, { dr(-22, 7, 12) }, I)
	wall(inn, "CoreE", "z", 26, -58, -6.6, y, 20, { dr(-22, 7, 12) }, I)
	keepClear(-78, -6, 78, 10, y)
end
-- the detention block: three cells along the back wall
wall(inn, "Cells", "x", -34, -77, -27, F1, 20, { dr(-68, 7, 11), dr(-52, 7, 11), dr(-36, 7, 11) }, I)
wall(inn, "CellA", "z", -60, -58, -34.6, F1, 20, {}, I)
wall(inn, "CellB", "z", -44, -58, -34.6, F1, 20, {}, I)
keepClear(-6, 10, 6, 58, F1) -- from the front door through the hangar to the corridor

-- LIGHTS: flickering strip lights, red lamps where it matters ---------------------------------------------------
for _, y in { F1, F2 } do
	local top = y + 19.6
	for _, x in { -66, -40, -14, 14, 40, 66 } do fluoro(x, top, 2, COOL) end
	for _, p in { { -58, 24 }, { -52, 48 }, { 58, 24 }, { 52, 48 }, { -20, 24 }, { 20, 24 }, { -20, 46 }, { 20, 46 }, { -52, -20 }, { -52, -46 }, { 52, -20 }, { 52, -46 } } do
		fluoro(p[1], top, p[2], COOL)
	end
end
for _, p in { { -68, -46 }, { -52, -46 }, { -36, -46 } } do bulb(p[1], F1 + 19.5, p[2], 3, RED) end -- the cells

-- THE REACTOR: a burning column in a cage of pillars, on both storeys ------------------------------------------
for _, y in { F1, F2 } do
	local m = model(DEC, "Reactor")
	local cf = CFrame.new(0, y, -32)
	cyl(m, cf, "ReactorBase", 16, 1.6, 0, 0.8, 0, PANEL_D)
	cyl(m, cf, "ReactorCollar", 10, 1.2, 0, 2.2, 0, TRIM)
	local core = cyl(m, cf, "ReactorCore", 6, 14, 0, 9.8, 0, neon(RED), D())
	light(core, 46, 2.2, RED)
	cyl(m, cf, "ReactorGlass", 7.4, 14, 0, 9.8, 0, st(M.Glass, nil, C3(120, 30, 26)), { deco = true, t = 0.6 })
	cyl(m, cf, "ReactorCap", 10, 1.2, 0, 17.4, 0, TRIM)
	cyl(m, cf, "ReactorTop", 16, 1.6, 0, 18.8, 0, PANEL_D)
	for i = 0, 3 do
		local a = math.rad(45 + i * 90)
		b(m, cf, "ReactorPillar", 1.4, 16, 1.4, math.cos(a) * 6.6, 9.6, math.sin(a) * 6.6, TRIM)
	end
	for i = 0, 7 do -- hazard chevrons on the floor round it
		local a = math.rad(i * 45)
		part(m, "ReactorMark", Vector3.new(3, 0.1, 1), cf * CFrame.Angles(0, a, 0) * CFrame.new(0, 0.06, -10.5), i % 2 == 0 and HAZARD or BLACK, D())
	end
end

-- CONSOLES ------------------------------------------------------------------------------------------------------
-- a desk-high console, its lit screen leaning back toward whoever stands at its -Z side
local function console(cf, w, color)
	local m = model(DEC, "Console")
	b(m, cf, "ConsoleBase", w, 3, 2.4, 0, 1.5, 0, PANEL_D)
	b(m, cf, "ConsoleTop", w + 0.3, 0.4, 3, 0, 3.2, 0, TRIM)
	local s = part(m, "ConsoleScreen", Vector3.new(w - 0.8, 2, 0.25), cf * CFrame.new(0, 4.4, 0.9) * CFrame.Angles(math.rad(-22), 0, 0), neon(color or SCREEN), D())
	light(s, 12, 0.9, color or SCREEN)
	for i = -1, 1 do b(m, cf, "ConsoleKey", 0.8, 0.12, 0.5, i * 1.3, 3.46, -0.6, neon(i == 0 and RED or C3(240, 200, 60)), D()) end
end
-- the bridge: an arc of consoles looking out of the front windows, the commander's chair on a dais, a holo table
for i = -2, 2 do
	local a = math.rad(i * 16)
	console(CFrame.new(math.sin(a) * 30, F2, 50 - (1 - math.cos(a)) * 30) * CFrame.Angles(0, -a, 0), 7)
end
local br = model(DEC, "Bridge")
cyl(br, CFrame.new(0, F2, 30), "Dais", 12, 0.8, 0, 0.4, 0, PANEL_D)
b(br, CFrame.new(0, F2, 30), "ChairSeat", 3, 0.8, 3, 0, 2.2, 0, BLACK)
b(br, CFrame.new(0, F2, 30), "ChairBack", 3, 4.5, 0.7, 0, 4.4, -1.6, BLACK)
for _, s in { -1, 1 } do b(br, CFrame.new(0, F2, 30), "ChairArm", 0.7, 1.4, 3, s * 1.8, 2.9, 0, TRIM) end
b(br, CFrame.new(0, F2, 30), "ChairPost", 1.2, 1.6, 1.2, 0, 1.4, 0, TRIM)
cyl(br, CFrame.new(-22, F2, 22), "HoloTable", 8, 3, 0, 1.5, 0, PANEL_D)
local holo = cyl(br, CFrame.new(-22, F2, 22), "HoloGlow", 7, 0.2, 0, 3.1, 0, neon(SCREEN), D())
light(holo, 16, 1.2, SCREEN)
cyl(br, CFrame.new(-22, F2, 22), "HoloBeam", 4.5, 5, 0, 5.7, 0, neon(SCREEN), { deco = true, t = 0.75 })
-- engineering and comms: banks of consoles along the walls
for _, z in { -50, -38, -26 } do
	console(CFrame.new(72, F1, z) * CFrame.Angles(0, -math.pi / 2, 0), 8, C3(255, 170, 60))
	console(CFrame.new(-72, F2, z) * CFrame.Angles(0, math.pi / 2, 0), 8)
end
for _, x in { 38, 52, 66 } do
	local g = model(DEC, "Generator")
	local cf = CFrame.new(x, F1, -53)
	b(g, cf, "GeneratorBody", 9, 10, 6, 0, 5, 0, PANEL_D)
	b(g, cf, "GeneratorVent", 7, 3, 0.3, 0, 7, 3.1, TRIM, D())
	local gl = b(g, cf, "GeneratorGlow", 6, 0.5, 0.3, 0, 3, 3.1, neon(C3(255, 170, 60)), D())
	light(gl, 12, 0.8, C3(255, 170, 60))
end

-- THE INTERCEPTOR in the hangar (west half; the middle stays clear for the way in): a dart of a ship on three
-- struts, swept wings, twin engines
do
	local m = model(DEC, "Interceptor")
	local cf = CFrame.new(-22, F1, 34)
	local HULLC = st(M.Metal, nil, C3(64, 68, 78))
	local DARK = st(M.Metal, nil, C3(30, 32, 38))
	b(m, cf, "Fuselage", 5, 3.2, 20, 0, 5, 0, HULLC)
	b(m, cf, "Nose", 3.6, 2.4, 5, 0, 4.8, -12.4, HULLC)
	b(m, cf, "NoseTip", 2, 1.5, 3.5, 0, 4.6, -16.4, DARK)
	b(m, cf, "Canopy", 3, 1.6, 6, 0, 7.2, -4, st(M.Glass, nil, C3(40, 70, 110)), { t = 0.35 })
	b(m, cf, "Spine", 1.6, 1.2, 9, 0, 7.1, 4.5, DARK)
	b(m, cf, "TailFin", 0.6, 5, 5, 0, 9, 7.5, HULLC)
	for _, s in { -1, 1 } do
		part(m, "Wing", Vector3.new(11, 0.7, 8), cf * CFrame.new(s * 7.6, 4.6, 3) * CFrame.Angles(0, s * math.rad(-18), s * math.rad(-6)), HULLC)
		part(m, "WingTip", Vector3.new(0.8, 2.6, 6), cf * CFrame.new(s * 13, 4.6, 5.5) * CFrame.Angles(0, s * math.rad(-18), 0), DARK)
		part(m, "WingStripe", Vector3.new(9, 0.08, 1.2), cf * CFrame.new(s * 7.6, 5.0, 2.5) * CFrame.Angles(0, s * math.rad(-18), s * math.rad(-6)), neon(RED), D())
		part(m, "Engine", Vector3.new(6, 2.6, 2.6), cf * CFrame.new(s * 2.4, 5, 11.5) * CFrame.Angles(0, math.pi / 2, 0), DARK, { shape = Enum.PartType.Cylinder })
		local ex = part(m, "EngineGlow", Vector3.new(0.3, 2, 2), cf * CFrame.new(s * 2.4, 5, 14.6) * CFrame.Angles(0, math.pi / 2, 0), neon(C3(110, 190, 255)), { shape = Enum.PartType.Cylinder, deco = true })
		light(ex, 10, 0.8, C3(110, 190, 255))
		b(m, cf, "Strut", 0.6, 3.4, 0.6, s * 3.2, 1.7, 6, DARK)
		b(m, cf, "StrutFoot", 1.6, 0.3, 2.4, s * 3.2, 0.15, 6, DARK)
	end
	b(m, cf, "Strut", 0.6, 3.6, 0.6, 0, 1.8, -9, DARK)
	b(m, cf, "StrutFoot", 1.6, 0.3, 2.4, 0, 0.15, -9, DARK)
	-- its landing pad: a painted box on the deck
	for _, e in { { -14, 0, 0.6, 30 }, { 14, 0, 0.6, 30 }, { 0, -15, 28, 0.6 }, { 0, 15, 28, 0.6 } } do
		b(m, cf, "PadLine", e[3], 0.08, e[4], e[1], 0.05, e[2], HAZARD, D())
	end
end
-- hazard stripes at the hangar's doors
for _, z in { 12, 56 } do
	for i = -3, 3 do box(DEC, "Hazard", i * 1.6 - 0.5, F1 + 0.04, z - 1, i * 1.6 + 0.5, F1 + 0.1, z + 1, i % 2 == 0 and HAZARD or BLACK, D()) end
end

-- A FIRST LOAD OF FURNITURE (the furnish pass adds more) -------------------------------------------------------
local STEEL = st(M.Metal, nil, C3(90, 94, 104))
for _, p in { { -70, 52 }, { -64, 54 }, { -58, 50 }, { -48, 54 }, { -46, 20 }, { -52, 16 } } do F.crate(at(p[1], F1, p[2], "N"), 3.6) end -- the cargo bay
for _, p in { { -44, 30 }, { -50, 26 }, { 30, 50 }, { 34, 44 }, { 24, 54 } } do F.barrel(at(p[1], F1, p[2], "N")) end
for _, z in { 16, 22, 28, 50, 56 } do G2.locker(at(76, F1, z, "W"), C3(70, 76, 90)) end -- the armory
G2.steelTable(at(52, F1, 44, "N")); G2.steelTable(at(60, F1, 20, "E"))
for _, x in { -68, -52, -36 } do F.bench(at(x, F1, -54, "N"), 5, STEEL) end -- the cells
for _, z in { 16, 26, 46, 54 } do
	G2.bunk(at(-48, F2, z, "E")) -- the crew quarters
end
for _, z in { 20, 46 } do -- the mess
	F.table(at(54, F2, z, "N"), 10, 5, 3.4, STEEL, "Table")
	F.bench(at(54, F2, z + 5, "N"), 9, STEEL); F.bench(at(54, F2, z - 5, "N"), 9, STEEL)
end
F.table(at(52, F2, -36, "N"), 8, 5, 3.4, STEEL, "Table"); F.chair(at(52, F2, -42, "N"), STEEL) -- the officers' cabin
G2.bunk(at(72, F2, -50, "W")); F.cabinet(at(34, F2, -54, "N"), 6, 9)

-- ON THE ROOF: aerials, a dish, red beacons -------------------------------------------------------------------
local roof = model(DEC, "RoofGear")
for _, p in { { -60, -40, 22 }, { 50, 30, 16 }, { 10, -50, 28 } } do
	cyl(roof, CFrame.new(p[1], 45.2, p[2]), "Aerial", 0.8, p[3], 0, p[3] / 2, 0, TRIM, D())
	local bcn = ball(roof, CFrame.new(p[1], 45.2 + p[3], p[2]), "Beacon", 1.4, 0, 0.4, 0, neon(RED), D())
	light(bcn, 30, 1.6, RED)
end
cyl(roof, CFrame.new(-20, 45.2, 30), "DishMast", 1.6, 8, 0, 4, 0, TRIM, D())
part(roof, "Dish", Vector3.new(1, 12, 12), CFrame.new(-20, 55, 30) * CFrame.Angles(0, math.rad(30), math.rad(60)), PANEL, { shape = Enum.PartType.Cylinder, deco = true })

-- WHERE THE MONSTERS COME IN ------------------------------------------------------------------------------------
gspawn(-50, F1, 46); gspawn(18, F1, -18); gspawn(56, F1, 34); gspawn(-52, F1, -20)
gspawn(0, F2, 22); gspawn(-50, F2, -30); gspawn(50, F2, -24); gspawn(56, F2, 34)
return endMap()
