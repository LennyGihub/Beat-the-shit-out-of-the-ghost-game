-- THE REACTOR (the Black Moon, building 3: THE SENTINEL, who rains missiles and overloads with lightning). The power
-- hall: the REACTOR CORE in the middle (a tall glowing column in a ring of steel, cooling rings round it - cover),
-- four COOLANT TOWERS round it (cover from its lightning), thick pipes along the walls and across the ceiling, a
-- control desk, warning lights, a glowing coolant channel across the floor (flush), catwalk rails high up. At the
-- back, behind a wall with two doorways: the PUMP ROOM (pumps, valves, gauges). Its east end: a FUSE PANEL that
-- slides (Secrets).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_reactor.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 30
local rng = Random.new(53)
local CORE = st(M.Neon, nil, C3(90, 210, 255))
beginMap("Moon_Reactor", moonTheme())
-- (2026-11-19) its own shape: the power hall with the CORE STACK glowing through its roof and two COOLING TOWERS
local TOP = shell2({ H = H, roof = "flat", roofStyle = st(M.Metal, nil, C3(70, 74, 82)), front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, -30 }, right1 = { 44, -30 },
	win = { w = 5, b = 6, t = 12 } })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "PumpWall", "x", -30, -78, 78, F1, 18, { dr(-30, 10, 12), dr(30, 10, 12) }, I)

-- THE REACTOR CORE: a steel drum with a glowing column, cooling rings, cables to the ceiling
local core = model(STR, "Core")
cyl(core, CFrame.new(0, F1 + 2, 14), "Drum", 16, 4, 0, 0, 0, MOON.steelD)
cyl(core, CFrame.new(0, F1 + 12, 14), "Housing", 9, 16, 0, 0, 0, MOON.steel, { t = 0.2 })
local col = cyl(DEC, CFrame.new(0, F1 + 12, 14), "CoreGlow", 6, 20, 0, 0, 0, CORE, D())
light(col, 50, 2.5, C3(110, 220, 255))
for k = 0, 3 do cyl(DEC, CFrame.new(0, F1 + 6 + k * 4.5, 14), "CoolRing", 11, 0.8, 0, 0, 0, MOON.steelL, D()) end
for k = 0, 5 do
	local a = k / 6 * math.pi * 2
	box(DEC, "Cable", math.cos(a) * 4 - 0.3, F1 + 20, 14 + math.sin(a) * 4 - 0.3, math.cos(a) * 4 + 0.3, F1 + H, 14 + math.sin(a) * 4 + 0.3, MOON.black, DECO)
end
-- warning stripes on the floor round it
for k = 0, 23 do
	local a = k / 24 * math.pi * 2
	part(DEC, "Stripe", Vector3.new(2.2, 0.06, 1.2), CFrame.new(math.cos(a) * 11, F1 + 0.05, 14 + math.sin(a) * 11) * CFrame.Angles(0, -a, 0), k % 2 == 0 and MOON.yellow or MOON.black, DECO)
end
-- THE COOLANT TOWERS (cover)
for _, p in { { -36, 40 }, { 36, 40 }, { -36, -10 }, { 36, -10 } } do
	cyl(STR, CFrame.new(p[1], F1 + 7, p[2]), "Tower", 7, 14, 0, 0, 0, MOON.white)
	cyl(DEC, CFrame.new(p[1], F1 + 10, p[2]), "TowerBand", 7.2, 1, 0, 0, 0, MOON.orange, D())
	cyl(DEC, CFrame.new(p[1], F1 + 14.4, p[2]), "TowerCap", 5, 0.8, 0, 0, 0, MOON.steelD, D())
	local g = box(DEC, "Gauge", p[1] - 0.8, F1 + 6, p[2] - 3.7, p[1] + 0.8, F1 + 7.6, p[2] - 3.5, MOON.blue, DECO)
	light(g, 10, 0.8, C3(120, 200, 255))
	-- a pipe from each tower into the core
	local a = Vector3.new(p[1], F1 + 12, p[2])
	local z = Vector3.new(0, F1 + 12, 14)
	part(DEC, "CorePipe", Vector3.new(1.4, 1.4, (z - a).Magnitude - 8), CFrame.lookAt((a + z) / 2, z), MOON.steelL, DECO)
end
-- the coolant channel across the floor (flush, glowing), pipes along the walls and the ceiling
box(DEC, "Channel", -76, F1 + 0.02, 52, 76, F1 + 0.08, 55, CORE, DECO)
for _, z in { -24, 26, 50 } do box(DEC, "CeilPipe", -78, F1 + H - 4, z - 0.8, 78, F1 + H - 2.4, z + 0.8, MOON.steelL, DECO) end
for _, x in { -77, 77 } do
	for _, y in { 4, 8, 12 } do box(DEC, "WallPipe", x - 0.6, F1 + y, -28, x + 0.6, F1 + y + 1.2, 56, (y == 8) and MOON.orange or MOON.steelL, DECO) end
end
-- the catwalk rails high up along the sides (decoration)
for _, x in { -70, 70 } do
	box(DEC, "Catwalk", x - 6, F1 + 18, -26, x + 6, F1 + 18.5, 56, MOON.floor, DECO)
	box(DEC, "CatRail", x - (x < 0 and -6 or 6) - 0.15, F1 + 18.5, -26, x - (x < 0 and -6 or 6) + 0.15, F1 + 21.5, 56, MOON.yellow, DECO)
end
-- the control desk facing the core
box(STR, "ControlDesk", -10, F1, 34, 10, F1 + 3.4, 38, MOON.panelD)
for k = -2, 2 do moonScreen(DEC, CFrame.new(k * 4, F1 + 5.4, 37.6), 3.4, 2.2, k % 2 == 0 and C3(90, 220, 255) or C3(255, 120, 90)) end
for k = 0, 9 do box(DEC, "Button", -8 + k * 1.8, F1 + 3.4, 35, -7.4 + k * 1.8, F1 + 3.6, 35.6, k % 3 == 0 and MOON.red or MOON.green, DECO) end
-- warning lights round the hall
for _, p in { { -70, 50 }, { 70, 50 }, { -70, -20 }, { 70, -20 } } do moonBeacon(DEC, Vector3.new(p[1], F1 + 14, p[2]), C3(255, 140, 40), 22) end
-- THE PUMP ROOM (behind the wall): pumps, valves, gauges
for _, x in { -50, -30, 20, 40 } do
	cyl(STR, CFrame.new(x, F1 + 2.5, -48) * CFrame.Angles(math.pi / 2, 0, 0), "Pump", 5, 8, 0, 0, 0, MOON.steelL)
	cyl(DEC, CFrame.new(x, F1 + 6, -48), "Valve", 2.2, 0.4, 0, 0, 0, MOON.red, D())
end
for k = 0, 5 do cyl(DEC, CFrame.new(-20 + k * 6, F1 + 7, -57.6) * CFrame.Angles(math.pi / 2, 0, 0), "Dial", 1.6, 0.3, 0, 0, 0, MOON.white, D()) end
-- THE STASH behind the fuse panel (x 50..78, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", 49, F1, -58, 50.2, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", 50.2, F1, -43.2, 60, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", 66, F1, -43.2, 78, F1 + 12, -42, MOON.steelD)
box(sr, "Lintel", 60, F1 + 9, -43.2, 66, F1 + 12, -42, MOON.steelD)
box(sr, "Ceiling", 49, F1 + 12, -58, 78, F1 + 12.6, -42, MOON.panelD)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "FusePanel")
door:SetAttribute("Slide", Vector3.new(-6.4, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "Fuse panel")
box(door, "Panel", 60, F1, -42.9, 66, F1 + 9, -40.6, MOON.panelD)
for k = 0, 5 do box(door, "Panel", 60.6 + k * 0.9, F1 + 4, -40.65, 61.2 + k * 0.9, F1 + 6.5, -40.4, MOON.yellow, DECO) end
box(door, "Trigger", 62.5, F1 + 4, -39.6, 63.5, F1 + 5, -38.6, MOON.panelD, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", 59 - k * 1.4, F1 + 0.06, -40 + k * 0.2, 60 - k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(150, 150, 156)), DECO) end
local loot = model(DEC, "Stash")
cyl(loot, CFrame.new(68, F1 + 2, -52), "Cell", 3, 4, 0, 0, 0, CORE, D())
local sg = b(loot, CFrame.new(64, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, MOON.blue, { deco = true, t = 1 })
light(sg, 18, 1, C3(150, 210, 255))

-- lights: hard white strips, the core's glow does the rest
for _, p in { { -40, 14 }, { 40, 14 }, { 0, 46 }, { 0, -18 } } do fluoro(p[1], F1 + H - 1, p[2], C3(210, 230, 255)) end
for _, p in { { -30, -46 }, { 30, -46 } } do fluoro(p[1], F1 + 17, p[2], C3(255, 230, 200)) end
for _, p in { { -30, 30 }, { 20, -14 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -46, 50 }, { 46, 50 }, { -20, 14 }, { 20, 14 }, { 0, -18 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(56, -42, 70, -34, F1)
-- OUTSIDE (2026-11-19): THE SENTINEL'S REACTOR. The core rises through the roof as a stack ringed with glowing coils,
-- two great hyperboloid COOLING TOWERS stand behind it breathing steam, thick pipes run from them along the walls,
-- power PYLONS crackle in the yard (frozen arcs between their tips), DANGER HIGH VOLTAGE on the door.
local OUT = model(DEC, "Outside")
local CORE = st(M.Neon, nil, C3(110, 200, 255))
-- the core stack on the roof
prism(OUT, "CoreStack", 0, -6, 9, TOP, TOP + 40, 12, MOON.steelD, D())
for y = TOP + 4, TOP + 36, 6 do prism(OUT, "CoreCoil", 0, -6, 10, y, y + 1.6, 12, CORE, D()) end
revolve(OUT, "CoreCap", 0, -6, { { 11, TOP + 40 }, { 8, TOP + 43 }, { 0, TOP + 45 } }, 12, MOON.steel)
light(box(OUT, "CoreGlow", -0.2, TOP + 20, -6.2, 0.2, TOP + 20.4, -5.8, CORE, { deco = true, t = 1 }), 70, 2.4, C3(110, 200, 255))
-- the cooling towers behind (hyperboloids: wide foot, a waist, a flared lip), steam rising
for _, tw in { { -70, -110 }, { 60, -130 } } do
	local cx, cz = tw[1], tw[2]
	revolve(OUT, "CoolingTower", cx, cz, { { 34, 0 }, { 28, 30 }, { 22, 62 }, { 21, 78 }, { 23, 96 } }, 16, st(M.Concrete, nil, C3(130, 130, 128)), st(M.Concrete, nil, C3(116, 116, 114)))
	prism(OUT, "TowerStripe", cx, cz, 22.4, 82, 86, 16, st(M.SmoothPlastic, nil, C3(180, 50, 40)), D())
	local sm = box(OUT, "SteamSource", cx - 1, 96, cz - 1, cx + 1, 97, cz + 1, MOON.steelD, { deco = true, t = 1 })
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(C3(200, 210, 220))
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) })
	pe.Size = NumberSequence.new(20, 50); pe.Lifetime = NumberRange.new(8, 12); pe.Rate = 3
	pe.Speed = NumberRange.new(5, 8); pe.SpreadAngle = Vector2.new(12, 12); pe.Shape = Enum.ParticleEmitterShape.Disc
	pe.Parent = sm
	light(box(OUT, "TowerLamp", cx - 0.5, 97, cz + 22, cx + 0.5, 98, cz + 23, MOON.red, DECO), 30, 1.4, C3(255, 60, 50))
end
-- pipes from the towers along the side walls
for _, sx in { -1, 1 } do
	for _, y in { 8, 14 } do cyl(OUT, CFrame.new(sx * 82.4, y, -10) * CFrame.Angles(math.pi / 2, 0, 0), "Pipe", 2.6, 100, 0, 0, 0, st(M.Metal, nil, C3(150, 120, 60)), D()) end
	for z = -50, 30, 20 do box(OUT, "PipeClamp", sx * 82.4 - 1.8, 6, z - 0.5, sx * 82.4 + 1.8, 16, z + 0.5, MOON.steelD, DECO) end
end
-- power pylons in the yard with frozen arcs between their tips
local function zig(a: Vector3, z: Vector3)
	local prng = Random.new(math.floor(a.X * 7 + z.Z))
	local prev = a
	for k = 1, 6 do
		local q = a:Lerp(z, k / 6) + (k < 6 and Vector3.new(prng:NextNumber(-1.6, 1.6), prng:NextNumber(-1.6, 1.6), prng:NextNumber(-1.6, 1.6)) or Vector3.zero)
		part(OUT, "Arc", Vector3.new(0.3, 0.3, (q - prev).Magnitude + 0.2), CFrame.lookAt((prev + q) / 2, q), CORE, D())
		prev = q
	end
end
local tips = {}
for i, p0 in { { -40, 84 }, { 40, 84 } } do
	local x, z = p0[1], p0[2]
	for _, c in { { -1.6, -1.6 }, { 1.6, -1.6 }, { 0, 1.6 } } do part(OUT, "PylonLeg", Vector3.new(0.6, 24, 0.6), CFrame.new(x + c[1], 12, z + c[2]) * CFrame.Angles(c[2] * -0.04, 0, c[1] * 0.04), MOON.steelL, D()) end
	for y = 4, 20, 4 do box(OUT, "PylonRung", x - 1.6, y, z - 1.6, x + 1.6, y + 0.3, z + 1.6, MOON.steelD, DECO) end
	local tip = ball(OUT, CFrame.new(x, 25, z), "PylonTip", 2.4, 0, 0, 0, CORE, D())
	light(tip, 26, 1.4, C3(110, 200, 255))
	tips[i] = Vector3.new(x, 25, z)
end
zig(tips[1], tips[2])
zig(tips[1], Vector3.new(-30, TOP, 59))
zig(tips[2], Vector3.new(30, TOP, 59))
-- danger signs and stripes
sign(OUT, "DANGER  -  HIGH VOLTAGE", CFrame.new(0, 19.4, 60.7) * CFrame.Angles(0, math.pi, 0), 20, 2.4, MOON.yellow, C3(20, 20, 20), Enum.Font.SciFi)
for _, x in { -60, -36, 36, 60 } do box(OUT, "WindowGlow", x - 2.5, 8, 59.3, x + 2.5, 14, 59.5, CORE, { deco = true, t = 0.5 }) end
moonSign("THE REACTOR", CFrame.new(0, 25.6, 61))
washLight(-30, 88, Vector3.new(-10, TOP + 20, -6), C3(160, 210, 255), 140, 2.2)
washLight(30, 88, Vector3.new(10, TOP + 20, -6), C3(160, 210, 255), 140, 2.2)
moonGrounds()
return endMap()
