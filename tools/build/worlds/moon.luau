-- THE BLACK MOON's world (ServerStorage.Worlds.Moon): the base on the dark side of the moon, the Earth over it.
--   ALL ROUND  grey REGOLITH, craters of every size with raised rims, boulders, rover tracks, jagged RIDGES on the
--              horizon; the EARTH huge in the black starry sky (Client/Fx: no atmosphere, 5000 stars, no moon)
--   WEST       the base's HABITAT: glass DOMES lit from inside, joined by TUBES, cylinder modules, solar arrays
--   EAST       the LAUNCH PAD: a white rocket on its pad with a gantry tower, fuel tanks, landing lights
--   NORTH      RADIO DISHES and ANTENNA MASTS with blinking red beacons on the ridge behind the building
--   SOUTH      across the rail: the ROVER parked by a cargo depot, its tracks in the dust
--   YARD       the BLACK MOON BASE arch, a cable fence on posts with blue guide lights
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--   tools/build/worlds/world_lib.luau tools/build/worlds/moon.luau
local C3 = Color3.fromRGB
local rng = Random.new(1969)
local W = beginWorld("Moon")
local REG = st(M.Slate, nil, C3(104, 102, 100))
local REGD = st(M.Slate, nil, C3(72, 70, 70))
local REGL = st(M.Slate, nil, C3(128, 126, 122))
local ROCK = st(M.Basalt, nil, C3(80, 78, 80))
local STEEL = st(M.Metal, nil, C3(112, 116, 124))
local STEELD = st(M.Metal, nil, C3(42, 45, 52))
local PANEL = st(M.SmoothPlastic, nil, C3(150, 152, 158))
local WHITE = st(M.SmoothPlastic, nil, C3(200, 202, 206))
local ORANGE = st(M.SmoothPlastic, nil, C3(220, 110, 40))
local GOLDF = st(M.Foil, nil, C3(210, 170, 70))
local GLASS = st(M.Glass, nil, C3(150, 190, 220))
local BLUE = C3(110, 200, 255)
local RED = C3(255, 60, 50)

---------------------------------------------------------------- the surface
local gnd = model(W, "Surface")
box(gnd, "Regolith", -1200, -2, -1200, 1200, 0.02, 1200, REG, WD())
-- craters: a dark floor, a raised rim of blocks round it
local function crater(cx: number, cz: number, r: number)
	local m = model(gnd, "Crater")
	cyl(m, CFrame.new(cx, 0.06, cz), "CraterFloor", r * 2, 0.1, 0, 0, 0, REGD, WD())
	local n = math.max(8, math.floor(r * 0.9))
	for k = 0, n - 1 do
		local a = k / n * math.pi * 2
		local h = r * rng:NextNumber(0.12, 0.22)
		local p = b(m, CFrame.new(cx, 0, cz) * CFrame.Angles(0, a, 0), "Rim", 2 * math.pi * r / n + 2, h, r * 0.35, 0, h / 2 - 0.3, -r, REGL, WD())
		p.CFrame = p.CFrame * CFrame.Angles(-0.35, 0, 0)
	end
end
for k = 1, 46 do
	local x, z = rng:NextNumber(-900, 900), rng:NextNumber(-900, 900)
	local r = rng:NextNumber() < 0.2 and rng:NextNumber(30, 70) or rng:NextNumber(6, 22)
	if not inPlay(x, z, r + 6) and not (x < -120 and x > -360 and z > -200 and z < 120) and not (x > 140 and x < 360 and z > -160 and z < 80) then crater(x, z, r) end
end
for k = 1, 120 do
	local x, z = rng:NextNumber(-700, 700), rng:NextNumber(-700, 700)
	if not inPlay(x, z, 4) then
		local s = rng:NextNumber(1.5, 7)
		local p = box(gnd, "Boulder", 0, 0, 0, 1, 1, 1, ROCK, WD())
		p.Size = Vector3.new(s, s * rng:NextNumber(0.5, 0.9), s * rng:NextNumber(0.7, 1.2))
		p.CFrame = CFrame.new(x, s * 0.25, z) * CFrame.Angles(rng:NextNumber(-0.5, 0.5), rng:NextNumber(0, 3), rng:NextNumber(-0.5, 0.5))
	end
end
-- the ridges on the horizon: jagged low-poly mountains all round
local ridges = model(W, "Ridges")
for k = 0, 15 do
	local a = k / 16 * math.pi * 2 + rng:NextNumber(-0.1, 0.1)
	local d = rng:NextNumber(950, 1150)
	mountain(ridges, rng, d * math.cos(a), d * math.sin(a), rng:NextNumber(180, 300), rng:NextNumber(90, 220), 7, k % 2 == 0 and REGD or REG, REGL)
end
-- THE EARTH, huge in the black sky: oceans, land, clouds, a thin blue glow
do
	local e = model(W, "Earth")
	local ec = CFrame.new(-420, 330, -900)
	ball(e, ec, "Ocean", 230, 0, 0, 0, st(M.Neon, nil, C3(40, 90, 200)), WD())
	for k = 1, 8 do ball(e, ec * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0) * CFrame.new(0, 0, -98), "Land", rng:NextNumber(46, 84), 0, 0, 0, st(M.Neon, nil, C3(70, 140, 70)), WD()) end
	for k = 1, 12 do ball(e, ec * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0) * CFrame.new(0, 0, -104), "Cloud", rng:NextNumber(26, 56), 0, 0, 0, st(M.Neon, nil, C3(220, 230, 240)), { deco = true, t = 0.3 }) end
	ball(e, ec, "Glow", 252, 0, 0, 0, st(M.Neon, nil, C3(120, 180, 255)), { deco = true, t = 0.88 })
	-- the night side: a dark cap over a third of it
	ball(e, ec * CFrame.new(70, -40, 60), "NightSide", 236, 0, 0, 0, st(M.SmoothPlastic, nil, C3(4, 6, 12)), { deco = true, t = 0.15 })
end

---------------------------------------------------------------- THE HABITAT (west): domes, tubes, modules, solar arrays
do
	local hb = model(W, "Habitat")
	local domes = { { -170, -40, 26 }, { -250, 30, 34 }, { -300, -110, 22 }, { -200, -150, 18 } }
	for _, d in domes do
		local cx, cz, r = d[1], d[2], d[3]
		domeRoof(hb, cx, cz, 2, r, r, r * 0.9, 12, 4, GLASS, 0.6)
		for _, p in hb:GetChildren() do if p.Name == "Dome" and p:IsA("BasePart") then p.Transparency = 0.45; p.CastShadow = false end end
		prism(hb, "DomeRing", cx, cz, r + 0.6, 0, 3, 12, STEELD, WD())
		box(hb, "DomeFloor", cx - r * 0.7, 0, cz - r * 0.7, cx + r * 0.7, 2.4, cz + r * 0.7, STEEL, WD())
		-- inside: lit modules, a garden of green under the glass
		box(hb, "Inside", cx - r * 0.3, 2.4, cz - r * 0.3, cx + r * 0.3, 2.4 + r * 0.4, cz + r * 0.3, PANEL, WD())
		box(hb, "Garden", cx - r * 0.6, 2.4, cz + r * 0.35, cx + r * 0.6, 3.4, cz + r * 0.6, st(M.Grass, nil, C3(70, 130, 60)), WD())
		local g = box(hb, "DomeLight", cx - 0.5, r * 0.6, cz - 0.5, cx + 0.5, r * 0.6 + 1, cz + 0.5, st(M.Neon, nil, C3(200, 230, 255)), WD())
		light(g, r * 1.4, 1.2, C3(200, 230, 255))
	end
	-- tubes between the domes
	local function tube(a: Vector3, z: Vector3)
		local mid = (a + z) / 2
		local cf = CFrame.lookAt(mid, z)
		part(hb, "Tube", Vector3.new(7, 7, (z - a).Magnitude), cf, PANEL, WD())
		for t = 0.15, 0.86, 0.14 do
			local p = a:Lerp(z, t)
			part(hb, "TubeRib", Vector3.new(8, 8, 1), CFrame.lookAt(p, z), STEELD, WD())
		end
		part(hb, "TubeWindow", Vector3.new(7.2, 1.2, (z - a).Magnitude * 0.8), cf * CFrame.new(0, 1.2, 0), st(M.Neon, nil, C3(180, 220, 255)), WD())
	end
	tube(Vector3.new(-150, 4, -40), Vector3.new(-104, 4, -40))
	tube(Vector3.new(-190, 4, -24), Vector3.new(-226, 4, 14))
	tube(Vector3.new(-186, 4, -58), Vector3.new(-280, 4, -100))
	tube(Vector3.new(-176, 4, -66), Vector3.new(-196, 4, -134))
	-- cylinder modules lying in the dust
	for i, p in { { -320, 70, 0.3 }, { -140, 90, -0.2 }, { -360, -30, 1.4 } } do
		local cf = CFrame.new(p[1], 7, p[2]) * CFrame.Angles(0, p[3], 0)
		cyl(hb, cf * CFrame.Angles(math.pi / 2, 0, 0), "Module", 14, 34, 0, 0, 0, i % 2 == 0 and PANEL or WHITE, WD())
		for _, z in { -12, 0, 12 } do cyl(hb, cf * CFrame.new(0, 0, z) * CFrame.Angles(math.pi / 2, 0, 0), "ModuleBand", 14.6, 1, 0, 0, 0, STEELD, WD()) end
		for _, sx in { -1, 1 } do b(hb, cf, "ModuleWindow", 0.3, 2, 18, sx * 7, 1, 0, st(M.Neon, nil, C3(255, 220, 170)), WD()) end
		for _, sz in { -1, 1 } do for _, sx in { -1, 1 } do b(hb, cf, "Leg", 1, 7, 1, sx * 5, -4.5, sz * 12, STEELD, WD()) end end
	end
	-- solar arrays
	for k = 0, 9 do
		local x, z = -380 + (k % 5) * 26, 150 + math.floor(k / 5) * 22
		local cf = CFrame.new(x, 6, z) * CFrame.Angles(-0.5, 0, 0)
		part(hb, "Solar", Vector3.new(22, 0.4, 12), cf, st(M.Glass, nil, C3(30, 50, 120)), WD())
		box(hb, "SolarPost", x - 0.5, 0, z - 0.5, x + 0.5, 6, z + 0.5, STEEL, WD())
	end
end

---------------------------------------------------------------- THE LAUNCH PAD (east): rocket, gantry, tanks, lights
do
	local lp = model(W, "LaunchPad")
	local cx, cz = 250, -60
	cyl(lp, CFrame.new(cx, 1, cz), "Pad", 70, 2, 0, 0, 0, st(M.Concrete, nil, C3(110, 108, 104)), WD())
	for k = 0, 15 do
		local a = k / 16 * math.pi * 2
		local p = Vector3.new(cx + 33 * math.cos(a), 2.2, cz + 33 * math.sin(a))
		local g = ball(lp, CFrame.new(p), "PadLight", 1.2, 0, 0, 0, st(M.Neon, nil, k % 2 == 0 and RED or BLUE), WD())
		if k % 4 == 0 then light(g, 22, 1, k % 2 == 0 and RED or BLUE) end
	end
	-- the rocket: stages, fins, a nose cone, black and white bands
	local y = 2
	for i, s in { { 13, 30, WHITE }, { 13, 6, st(M.SmoothPlastic, nil, C3(20, 20, 24)) }, { 11, 26, WHITE }, { 9, 18, WHITE } } do
		cyl(lp, CFrame.new(cx, y + s[2] / 2, cz), "Stage", s[1], s[2], 0, 0, 0, s[3], WD())
		y += s[2]
		local _ = i
	end
	revolve(lp, "NoseCone", cx, cz, { { 4.5, y }, { 3.6, y + 6 }, { 1.6, y + 12 }, { 0, y + 15 } }, 12, WHITE)
	for k = 0, 3 do
		local a = k * math.pi / 2
		part(lp, "Fin", Vector3.new(1, 14, 10), CFrame.new(cx + math.cos(a) * 9, 9, cz + math.sin(a) * 9) * CFrame.Angles(0, -a, 0), ORANGE, WD())
	end
	-- the gantry tower beside it, its arm to the capsule
	local gx = cx + 24
	for _, c in { { -4, -4 }, { 4, -4 }, { -4, 4 }, { 4, 4 } } do box(lp, "GantryLeg", gx + c[1] - 0.7, 0, cz + c[2] - 0.7, gx + c[1] + 0.7, 92, cz + c[2] + 0.7, st(M.Metal, nil, C3(170, 60, 40)), WD()) end
	for yy = 8, 88, 10 do
		for _, s in { -4, 4 } do
			part(lp, "GantryBrace", Vector3.new(0.5, 0.5, 12), CFrame.new(gx + s, yy, cz) * CFrame.Angles((yy / 10) % 2 == 0 and 0.7 or -0.7, 0, 0), st(M.Metal, nil, C3(170, 60, 40)), WD())
		end
	end
	box(lp, "GantryArm", cx + 4, 74, cz - 2, gx - 4, 77, cz + 2, STEELD, WD())
	light(box(lp, "GantryBeacon", gx - 1, 92, cz - 1, gx + 1, 94, cz + 1, st(M.Neon, nil, RED), WD()), 40, 1.6, RED)
	-- fuel tanks
	for _, p in { { cx - 50, cz - 30 }, { cx - 60, cz - 10 }, { cx - 50, cz + 12 } } do
		ball(lp, CFrame.new(p[1], 10, p[2]), "FuelTank", 16, 0, 0, 0, WHITE, WD())
		for _, sx in { -1, 1 } do box(lp, "TankLeg", p[1] + sx * 5 - 0.6, 0, p[2] - 0.6, p[1] + sx * 5 + 0.6, 6, p[2] + 0.6, STEELD, WD()) end
	end
	light(box(lp, "PadFlood", cx - 0.1, 30, cz + 40, cx + 0.1, 30.2, cz + 40.2, st(M.Neon, nil, C3(220, 230, 255)), { deco = true, t = 1 }), 80, 1.4, C3(220, 230, 255))
end

---------------------------------------------------------------- RADIO DISHES and ANTENNAS (north, behind the building)
do
	local ant = model(W, "Antennas")
	for i, p in { { -60, -260, 34 }, { 90, -300, 46 }, { 220, -240, 28 } } do
		local x, z, r = p[1], p[2], p[3]
		box(ant, "DishMast", x - 2, 0, z - 2, x + 2, r * 0.8, z + 2, STEEL, WD())
		local cf = CFrame.new(x, r * 0.8 + r * 0.3, z) * CFrame.Angles(-0.7, (i - 2) * 0.5, 0)
		revolve(ant, "Dish", 0, 0, { { 0, 0 }, { r * 0.25, r * 0.03 }, { r * 0.5, r * 0.11 } }, 14, WHITE)
		-- (revolve builds round the origin: move the dish parts onto the mast)
		for _, d in ant:GetChildren() do
			if d.Name == "Dish" and d:IsA("BasePart") and not d:GetAttribute("Placed") then
				d.CFrame = cf * d.CFrame
				d:SetAttribute("Placed", true)
			end
		end
		part(ant, "DishHorn", Vector3.new(1, 1, r * 0.5), cf * CFrame.new(0, r * 0.25, 0) * CFrame.Angles(math.pi / 2, 0, 0), STEELD, WD())
		light(box(ant, "DishBeacon", x - 0.8, r * 0.8 + 0.2, z - 0.8, x + 0.8, r * 0.8 + 1.8, z + 0.8, st(M.Neon, nil, RED), WD()), 30, 1.2, RED)
	end
	for _, p in { { -160, -230, 110 }, { 30, -220, 90 }, { 300, -330, 130 } } do
		local x, z, h = p[1], p[2], p[3]
		for _, c in { { -2, -2 }, { 2, -2 }, { 0, 2 } } do part(ant, "MastLeg", Vector3.new(0.6, h, 0.6), CFrame.new(x + c[1] * 0.5, h / 2, z + c[2] * 0.5) * CFrame.Angles(c[2] * -0.01, 0, c[1] * 0.01), STEEL, WD()) end
		for yy = 10, h - 10, 12 do box(ant, "MastRung", x - 1.6, yy, z - 1.6, x + 1.6, yy + 0.4, z + 1.6, STEELD, WD()) end
		light(ball(ant, CFrame.new(x, h + 1, z), "MastBeacon", 2.4, 0, 0, 0, st(M.Neon, nil, RED), WD()), 50, 1.6, RED)
	end
end

---------------------------------------------------------------- THE ROVER and the cargo depot (south)
do
	local rv = model(W, "Rover")
	local cf = CFrame.new(70, 0, 220) * CFrame.Angles(0, 0.6, 0)
	b(rv, cf, "Chassis", 10, 1.4, 16, 0, 3.6, 0, STEELD, WD())
	b(rv, cf, "Cabin", 8, 5, 7, 0, 6.8, -3, WHITE, WD())
	b(rv, cf, "Visor", 7, 2.2, 0.3, 0, 7.6, -6.6, GOLDF, WD())
	b(rv, cf, "Bed", 9, 2, 7, 0, 5.2, 4.5, PANEL, WD())
	for _, z in { -6, 0, 6 } do for _, x in { -5.6, 5.6 } do cyl(rv, cf * CFrame.new(x, 2.4, z) * CFrame.Angles(0, 0, -math.pi / 2), "Wheel", 4.6, 1.4, 0, 0, 0, st(M.SmoothPlastic, nil, C3(30, 30, 34)), WD()) end end
	b(rv, cf, "Antenna", 0.3, 6, 0.3, 3, 12, 4, STEEL, WD())
	light(b(rv, cf, "Headlight", 2, 1, 0.3, 0, 4.6, -8.2, st(M.Neon, nil, C3(255, 250, 230)), WD()), 30, 1.2, C3(255, 250, 230))
	-- its tracks: two lines of little dents curving away
	for k = 0, 40 do
		local t = k / 40
		local p = Vector3.new(70 - t * 160 + math.sin(t * 4) * 20, 0.05, 220 + t * 120)
		for _, dx in { -4.4, 4.4 } do part(rv, "Track", Vector3.new(1.8, 0.08, 3.2), CFrame.new(p + Vector3.new(dx, 0, 0)) * CFrame.Angles(0, 0.6 - t, 0), REGD, WD()) end
	end
	for k = 0, 5 do
		local x, z = -60 + (k % 3) * 14, 240 + math.floor(k / 3) * 9
		box(rv, "Container", x, 0, z, x + 12, 8, z + 7, ({ ORANGE, PANEL, st(M.SmoothPlastic, nil, C3(60, 90, 140)) })[k % 3 + 1], WD())
	end
end

---------------------------------------------------------------- the yard: the arch, the cable fence with guide lights
local yd = model(W, "BaseYard")
for _, x in { -8, 8 } do box(yd, "ArchPylon", x - 1, 0, 130.5, x + 1, 15, 132.5, STEELD, WD()) end
box(yd, "ArchBeam", -9.5, 12.6, 131, 9.5, 15.4, 132, STEEL, WD())
sign(yd, "BLACK MOON BASE", CFrame.new(0, 14, 130.9) * CFrame.Angles(0, math.pi, 0), 17, 2, STEELD, C3(200, 225, 255), Enum.Font.SciFi).Name = "MoonSign"
sign(yd, "BLACK MOON BASE", CFrame.new(0, 14, 132.1), 17, 2, STEELD, C3(200, 225, 255), Enum.Font.SciFi).Name = "MoonSignBack"
for _, x in { -8, 8 } do light(ball(yd, CFrame.new(x, 15.6, 131.5), "ArchBeacon", 1, 0, 0, 0, st(M.Neon, nil, RED), WD()), 24, 1.2, RED) end
local fence = model(W, "Fence")
yardEdge(fence, function(parent, x1, z1, x2, z2, gap)
	local a, z = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	local len = (z - a).Magnitude
	local n = math.max(1, math.floor(len / 10))
	local prev = nil
	for i = 0, n do
		local p = a:Lerp(z, i / n)
		if gap and gap(p.X, p.Z) then prev = nil; continue end
		box(parent, "Post", p.X - 0.4, 0, p.Z - 0.4, p.X + 0.4, 4.4, p.Z + 0.4, STEEL, WD())
		local g = ball(parent, CFrame.new(p.X, 4.8, p.Z), "PostLight", 0.8, 0, 0, 0, st(M.Neon, nil, BLUE), WD())
		if i % 3 == 0 then light(g, 14, 0.8, BLUE) end
		if prev then
			for _, y in { 2, 3.8 } do part(parent, "Cable", Vector3.new(0.15, 0.15, (p - prev).Magnitude), CFrame.lookAt((prev + p) / 2 + Vector3.new(0, y, 0), p + Vector3.new(0, y, 0)), STEELD, WD()) end
		end
		prev = p
	end
end)
return endWorld()
