-- THE BLACK MOON: what its five buildings share (Shared/Campaign map 5, the last: one building per train trip).
-- Prepend after lib2 + furn_lib + maplib, then one maps/moon_<building>.luau:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_dock.luau
-- Every building is a map on the Mansion's footprint, dressed as a module of the moon base. Outside: the grey lunar
-- surface (regolith, craters, boulders), a metal walkway on struts from the porch to the railway with blue guide
-- lights, a landed lander, a radio dish, solar panels, domes, a flag, the BLACK MOON BASE arch, and the EARTH hanging
-- huge in the black sky. On the building: a steel sign board with two warning lights over the porch.
-- Then furnish (ONLY = the map), detail (TARGET = the map), doors_clear, and maps/abbey_moon_items.luau.
local C3m = Color3.fromRGB
local MOON = {
	steel = st(M.DiamondPlate, nil, C3m(74, 78, 86)),
	steelD = st(M.Metal, nil, C3m(42, 45, 52)),
	steelL = st(M.Metal, nil, C3m(112, 116, 124)),
	panel = st(M.SmoothPlastic, nil, C3m(104, 108, 116)),
	panelD = st(M.SmoothPlastic, nil, C3m(64, 68, 76)),
	floor = st(M.DiamondPlate, nil, C3m(52, 56, 64)),
	rubber = st(M.SmoothPlastic, nil, C3m(30, 30, 34)),
	glass = st(M.Glass, nil, C3m(120, 170, 200)),
	regolith = st(M.Slate, nil, C3m(104, 102, 100)),
	regolithD = st(M.Slate, nil, C3m(70, 68, 68)),
	rock = st(M.Basalt, nil, C3m(80, 78, 80)),
	white = st(M.SmoothPlastic, nil, C3m(150, 152, 158)), -- (mid grey: the lifted interior light turns real white to glare)
	orange = st(M.SmoothPlastic, nil, C3m(220, 110, 40)),
	yellow = st(M.SmoothPlastic, nil, C3m(220, 180, 40)),
	black = st(M.SmoothPlastic, nil, C3m(16, 16, 20)),
	red = st(M.Neon, nil, C3m(255, 50, 40)),
	blue = st(M.Neon, nil, C3m(90, 190, 255)),
	green = st(M.Neon, nil, C3m(120, 255, 120)),
	violet = st(M.Neon, nil, C3m(170, 110, 255)),
	screen = st(M.Neon, nil, C3m(60, 160, 200)),
	gold = st(M.Foil, nil, C3m(210, 170, 70)),
	earth = st(M.Neon, nil, C3m(50, 110, 220)),
	cloud = st(M.Neon, nil, C3m(220, 230, 240)),
	land = st(M.Neon, nil, C3m(70, 150, 70)),
}
local function moonTheme(over: { [string]: any }?)
	local t = {
		floor = MOON.floor, floor2 = MOON.floor, inner = st(M.SmoothPlastic, nil, C3m(78, 82, 92)), wainscot = MOON.steelD, wain = true,
		ext = st(M.DiamondPlate, nil, C3m(96, 100, 108)), trim = MOON.steelD, ceiling = MOON.panelD, roof = st(M.Metal, nil, C3m(70, 74, 82)),
		found = MOON.regolithD, door = MOON.steel, porch = MOON.steelD, iron = MOON.steelD,
		lanternColor = C3m(200, 225, 255), floodColor = C3m(190, 210, 255),
	}
	for k, v in over or {} do t[k] = v end
	return t
end

-- a blinking warning light on a little box (deco)
local function moonBeacon(parent: Instance, p: Vector3, col: Color3?, range: number?)
	local m = model(parent, "Beacon")
	box(m, "Base", p.X - 0.5, p.Y - 0.4, p.Z - 0.5, p.X + 0.5, p.Y, p.Z + 0.5, MOON.steelD, DECO)
	local g = ball(m, CFrame.new(p + Vector3.new(0, 0.4, 0)), "Glow", 0.8, 0, 0, 0, st(M.Neon, nil, col or C3m(255, 60, 50)), { deco = true })
	local l = light(g, math.min(range or 12, 12), 0.8, col or C3m(255, 80, 60)) -- (small: red light over everything turned the moon pink)
	l:SetAttribute("Flicker", true)
	return m
end
-- a strip of blue floor lights (deco), from a to z
local function moonGuide(parent: Instance, a: Vector3, z: Vector3, n: number)
	for i = 0, n do
		local p = a:Lerp(z, i / n)
		box(parent, "GuideLight", p.X - 0.3, p.Y, p.Z - 0.3, p.X + 0.3, p.Y + 0.2, p.Z + 0.3, MOON.blue, DECO)
	end
end
-- a cargo container (cover when solid): ribbed sides, a coloured stripe, a stencil
local function moonContainer(parent: Instance, cf: CFrame, color: Color3, solid: boolean?)
	local o = solid and nil or DECO
	local m = model(parent, "Container")
	b(m, cf, "Box", 8, 6, 5, 0, 3, 0, st(M.Metal, nil, color), o)
	for k = -3, 3 do b(DEC, cf, "Rib", 0.3, 5.6, 5.2, k * 1.15, 3, 0, st(M.Metal, nil, color:Lerp(Color3.new(0, 0, 0), 0.25)), DECO) end
	b(DEC, cf, "Stripe", 8.1, 0.6, 5.1, 0, 4.6, 0, MOON.yellow, DECO)
	return m
end
-- a wall screen (deco): a dark frame, a glowing display with some bars
local function moonScreen(parent: Instance, cf: CFrame, w: number, h: number, col: Color3?)
	local m = model(parent, "Screen")
	b(m, cf, "Frame", w + 0.6, h + 0.6, 0.3, 0, 0, 0, MOON.black, DECO)
	local s = b(m, cf, "Display", w, h, 0.1, 0, 0, -0.2, st(M.Neon, nil, (col or C3m(60, 160, 200)):Lerp(Color3.new(0, 0, 0), 0.55)), DECO)
	s.Transparency = 0.1
	local rng = Random.new(math.floor(cf.Position.X * 7 + cf.Position.Z * 13))
	for k = 0, 4 do
		local bh = rng:NextNumber(0.2, 0.8) * h * 0.7
		b(m, cf, "Bar", w / 8, bh, 0.1, -w / 2 + (k + 1) * w / 6, -h / 2 + bh / 2 + 0.3, -0.26, st(M.Neon, nil, col or C3m(90, 220, 255)), DECO)
	end
	return m
end

-- the building's name on a steel board over the porch roof, a warning light each side
local function moonSign(text: string, at: CFrame?)
	local m = model(DEC, "Marquee")
	local cf = (at or CFrame.new(0, 21, 61)) * CFrame.Angles(0, math.pi, 0)
	b(m, cf, "Board", 26, 5, 0.5, 0, 0, 0.3, MOON.steelD, DECO)
	b(m, cf, "Frame", 27, 5.8, 0.3, 0, 0, 0.55, MOON.yellow, DECO)
	sign(m, text, cf * CFrame.new(0, 0, -0.05), 23, 3.4, MOON.steelD, C3m(200, 225, 255), Enum.Font.SciFi)
	for _, x in { -14.5, 14.5 } do moonBeacon(m, (cf * CFrame.new(x, -1.4, -0.5)).Position, C3m(255, 60, 50), 22) end
	return m
end

-- the lunar surface round the building (everything decoration: no collision, never hit by a ray)
local function moonGrounds()
	local yd = model(DEC, "MoonGrounds")
	local rng = Random.new(88)
	box(yd, "Regolith", -160, 0.04, 62, 160, 0.14, 200, MOON.regolith, DECO)
	-- craters: a dark floor and a raised rim
	for k = 1, 9 do
		local x = (k % 2 == 0 and -1 or 1) * rng:NextNumber(22, 140)
		local z = rng:NextNumber(70, 190)
		local r = rng:NextNumber(6, 16)
		cyl(yd, CFrame.new(x, 0.16, z), "CraterFloor", r * 2, 0.06, 0, 0, 0, MOON.regolithD, { deco = true })
		cyl(yd, CFrame.new(x, 0.3, z), "CraterRim", r * 2 + 3, 0.5, 0, 0, 0, MOON.regolith, { deco = true })
		cyl(yd, CFrame.new(x, 0.35, z), "CraterIn", r * 2, 0.52, 0, 0, 0, MOON.regolithD, { deco = true })
	end
	for k = 1, 22 do
		local x = (k % 2 == 0 and -1 or 1) * rng:NextNumber(14, 150)
		ball(yd, CFrame.new(x, 0.4, rng:NextNumber(66, 196)) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0), "Boulder", rng:NextNumber(1.5, 5), 0, 0, 0, MOON.rock, { deco = true })
	end
	-- THE WALKWAY on struts from the porch to the railway, blue guide lights along both edges
	box(yd, "Walkway", -6, 1.2, 64, 6, 1.6, 146, MOON.floor, DECO)
	for z = 66, 144, 8 do
		for _, x in { -5, 5 } do box(yd, "Strut", x - 0.4, 0, z - 0.4, x + 0.4, 1.2, z + 0.4, MOON.steelD, DECO) end
		for _, x in { -6.2, 6.2 } do box(yd, "Post", x - 0.15, 1.6, z - 0.15, x + 0.15, 4.4, z + 0.15, MOON.steelL, DECO) end
	end
	for _, x in { -6.2, 6.2 } do box(yd, "Rail", x - 0.15, 4.2, 64, x + 0.15, 4.5, 146, MOON.steelL, DECO) end
	moonGuide(yd, Vector3.new(-5.4, 1.6, 66), Vector3.new(-5.4, 1.6, 144), 26)
	moonGuide(yd, Vector3.new(5.4, 1.6, 66), Vector3.new(5.4, 1.6, 144), 26)
	-- THE LANDER, landed on four legs to the west
	local ld = model(yd, "Lander")
	local lc = CFrame.new(-44, 0, 112)
	b(ld, lc, "Body", 10, 6, 10, 0, 9, 0, MOON.gold, DECO)
	b(ld, lc, "Cabin", 7, 5, 7, 0, 14.5, 0, MOON.panel, DECO)
	b(ld, lc, "Window", 3, 1.6, 0.2, 0, 15, -3.6, MOON.glass, DECO)
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
		part(ld, "Leg", Vector3.new(0.6, 9, 0.6), lc * CFrame.new(c[1] * 6.5, 4, c[2] * 6.5) * CFrame.Angles(c[2] * -0.35, 0, c[1] * 0.35), MOON.steelL, DECO)
		cyl(ld, lc * CFrame.new(c[1] * 8, 0.3, c[2] * 8), "Foot", 2.4, 0.4, 0, 0, 0, MOON.steelL, { deco = true })
	end
	b(ld, lc, "Ladder", 1.6, 7, 0.3, 0, 3.5, -5.4, MOON.steelL, DECO)
	-- THE RADIO DISH and the SOLAR PANELS to the east
	local dish = model(yd, "Dish")
	box(dish, "Mast", 39.5, 0, 99.5, 40.5, 12, 100.5, MOON.steelL, DECO)
	cyl(dish, CFrame.new(40, 15, 100) * CFrame.Angles(0.5, 0.6, math.pi / 2), "Bowl", 14, 1.2, 0, 0, 0, MOON.white, { deco = true })
	box(dish, "Horn", 39.6, 14, 97, 40.4, 17, 97.8, MOON.steelD, DECO)
	moonBeacon(dish, Vector3.new(40, 12.4, 100), C3m(255, 60, 50), 20)
	for k = 0, 3 do
		local cf = CFrame.new(60 + k * 14, 3, 130) * CFrame.Angles(-0.5, 0, 0)
		part(yd, "Solar", Vector3.new(12, 0.3, 7), cf, st(M.Glass, nil, C3m(30, 50, 110)), DECO)
		box(yd, "SolarPost", 59.6 + k * 14, 0, 129.6, 60.4 + k * 14, 3, 130.4, MOON.steelL, DECO)
	end
	-- (2026-11-19: the base's domes, the arch and the Earth are in the Moon WORLD now: tools/build/worlds/moon.luau)
	-- the flag by the walkway (a stiff flag on a pole: no wind on the moon)
	box(yd, "FlagPole", -14.2, 0, 72.8, -13.8, 14, 73.2, MOON.steelL, DECO)
	box(yd, "Flag", -13.8, 10, 72.9, -7, 13.6, 73.1, MOON.white, DECO)
	box(yd, "FlagStripe", -13.8, 11.4, 72.85, -7, 12.2, 73.15, MOON.orange, DECO)
end

-- yellow and black warning stripes along a face at z (facing +Z), from x0 to x1, y0 to y1 (2026-11-19)
local function hazard(parent, x0: number, x1: number, y0: number, y1: number, z: number)
	local k = 0
	for x = x0, x1 - 2, 2.4 do
		k += 1
		part(parent, "Hazard", Vector3.new(2.4, y1 - y0, 0.2), CFrame.new(x + 1.2, (y0 + y1) / 2, z) * CFrame.Angles(0, 0, 0), k % 2 == 0 and MOON.yellow or MOON.black, { deco = true })
	end
end
