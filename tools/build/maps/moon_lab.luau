-- THE LAB (the Black Moon, building 2: THE SPECIMEN, which spits acid and sends its brood after you). A science lab
-- gone wrong: rows of SPECIMEN TANKS (glass cylinders of green fluid, some smashed and leaking - the whole ones are
-- cover), LAB BENCHES with microscopes and racks of sample tubes, computer desks with screens, hazard signs, green
-- light, slime and claw marks on the floor. At the back, behind a wall with two doorways: the QUARANTINE ROOM (a
-- decon shower, an operating table, freezer drawers). Its west end: a SERVER RACK that slides (Secrets).
-- (No pills, syringes or bottles of anything: Roblox moderation, CLAUDE.md.)
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_lab.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local rng = Random.new(52)
local FLUID = st(M.Neon, nil, C3(90, 200, 90))
local SLIME = st(M.Neon, nil, C3(120, 230, 90))
beginMap("Moon_Lab", moonTheme({ inner = st(M.SmoothPlastic, nil, C3(82, 92, 88)) }))
shell({ two = false, H = H, roof = "flat", front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 6, winB = 5, winT = 12 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "QuarantineWall", "x", -30, -78, 78, F1, H, { dr(-30, 10, 12), dr(30, 10, 12) }, I)

-- THE SPECIMEN TANKS: a base, a glass cylinder with fluid and a shape inside, a cap with pipes
local function tank(x: number, z: number, broken: boolean)
	local m = model(broken and DEC or STR, "Tank")
	cyl(m, CFrame.new(x, F1 + 0.75, z), "Base", 6, 1.5, 0, 0, 0, MOON.steelD, broken and D() or nil)
	cyl(m, CFrame.new(x, F1 + 12.5, z), "Cap", 6, 1.5, 0, 0, 0, MOON.steelD, D())
	for k = 0, 2 do box(DEC, "Pipe", x - 0.3 + (k - 1) * 1.6, F1 + 13, z - 0.3, x + 0.3 + (k - 1) * 1.6, F1 + H, z + 0.3, MOON.steelL, DECO) end
	if broken then
		-- shards of glass round the base, the fluid spilled across the floor
		for k = 0, 6 do
			local a = k / 7 * math.pi * 2
			part(DEC, "Shard", Vector3.new(0.2, rng:NextNumber(1, 4), rng:NextNumber(0.8, 2)), CFrame.new(x + math.cos(a) * 2.6, F1 + 2.5, z + math.sin(a) * 2.6) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), -a, 0), MOON.glass, { deco = true, t = 0.4 })
		end
		cyl(DEC, CFrame.new(x + 2, F1 + 0.03, z + 3), "Spill", 9, 0.05, 0, 0, 0, FLUID, D()).Transparency = 0.3
	else
		cyl(m, CFrame.new(x, F1 + 6.75, z), "Glass", 5.2, 10, 0, 0, 0, MOON.glass, { t = 0.55 })
		local fl = cyl(DEC, CFrame.new(x, F1 + 6, z), "Fluid", 4.8, 8.4, 0, 0, 0, FLUID, D())
		fl.Transparency = 0.45
		light(fl, 16, 1, C3(120, 255, 120))
		-- something curled up inside
		part(DEC, "Thing", Vector3.new(1.6, 3, 1.4), CFrame.new(x, F1 + 6, z) * CFrame.Angles(0.4, rng:NextNumber(0, 6), 0.2), st(M.Slate, nil, C3(110, 130, 100)), DECO)
	end
end
for i, p in { { -48, 44 }, { -48, 20 }, { -48, -4 }, { 48, 44 }, { 48, 20 }, { 48, -4 } } do tank(p[1], p[2], i == 2 or i == 6) end
-- LAB BENCHES with microscopes, sample racks, screens
local benches = model(STR, "Benches")
for _, p in { { -16, 36 }, { 16, 36 }, { -16, 6 }, { 16, 6 } } do
	box(benches, "Bench", p[1] - 7, F1, p[2] - 2, p[1] + 7, F1 + 3.4, p[2] + 2, MOON.panel)
	box(DEC, "BenchTop", p[1] - 7.2, F1 + 3.4, p[2] - 2.2, p[1] + 7.2, F1 + 3.6, p[2] + 2.2, MOON.black, DECO)
	-- a microscope
	box(DEC, "ScopeBase", p[1] - 4.6, F1 + 3.6, p[2] - 0.6, p[1] - 3.4, F1 + 3.9, p[2] + 0.6, MOON.white, DECO)
	part(DEC, "ScopeArm", Vector3.new(0.4, 1.8, 0.4), CFrame.new(p[1] - 4, F1 + 4.8, p[2] + 0.2) * CFrame.Angles(-0.3, 0, 0), MOON.white, DECO)
	-- a rack of sample tubes (coloured liquids: lab samples)
	box(DEC, "Rack", p[1] - 1, F1 + 3.6, p[2] - 0.5, p[1] + 2, F1 + 4.2, p[2] + 0.5, MOON.steelL, DECO)
	for k = 0, 4 do cyl(DEC, CFrame.new(p[1] - 0.6 + k * 0.6, F1 + 4.4, p[2]), "Tube", 0.25, 1, 0, 0, 0, ({ FLUID, MOON.blue, MOON.red })[(k % 3) + 1], D()) end
	moonScreen(DEC, CFrame.new(p[1] + 4.5, F1 + 5, p[2]) * CFrame.Angles(0, math.pi, 0), 3, 2, C3(120, 255, 140))
end
-- hazard signs, slime and claw marks
for _, p in { { -77.6, 6, 32, math.pi / 2 }, { 77.6, 6, 8, -math.pi / 2 } } do
	local cf = CFrame.new(p[1], F1 + p[2], p[3]) * CFrame.Angles(0, p[4], 0)
	part(DEC, "Hazard", Vector3.new(3, 3, 0.2), cf * CFrame.Angles(0, 0, math.pi / 4), MOON.yellow, DECO)
	part(DEC, "HazardMark", Vector3.new(0.4, 1.4, 0.25), cf * CFrame.new(0, 0.2, 0), MOON.black, DECO)
end
for k = 0, 10 do
	local x, z = rng:NextNumber(-60, 60), rng:NextNumber(-20, 50)
	cyl(DEC, CFrame.new(x, F1 + 0.03, z), "Slime", rng:NextNumber(1.5, 3.5), 0.04, 0, 0, 0, SLIME, D()).Transparency = 0.35
	local _ = k
end
for k = 0, 5 do
	local x, z = rng:NextNumber(-40, 40), rng:NextNumber(-20, 50)
	for j = -1, 1 do part(DEC, "Claw", Vector3.new(0.15, 0.03, 3), CFrame.new(x + j * 0.5, F1 + 0.03, z) * CFrame.Angles(0, 0.4, 0), MOON.black, DECO) end
end
-- computer desks along the front wall
for _, x in { -40, 40 } do
	box(STR, "Desk", x - 6, F1, 52, x + 6, F1 + 3, 56, MOON.panelD)
	moonScreen(DEC, CFrame.new(x - 2.5, F1 + 5.2, 55.5) * CFrame.Angles(0, math.pi, 0), 3.4, 2.2)
	moonScreen(DEC, CFrame.new(x + 2.5, F1 + 5.2, 55.5) * CFrame.Angles(0, math.pi, 0), 3.4, 2.2, C3(255, 120, 90))
end
-- THE QUARANTINE ROOM (behind the wall): the decon shower, an operating table, freezer drawers
box(STR, "OpTable", -6, F1, -50, 6, F1 + 3.2, -44, MOON.steelL)
box(DEC, "OpLamp", -2, F1 + 14, -49, 2, F1 + 14.6, -45, MOON.white, DECO)
local ol = b(DEC, CFrame.new(0, F1 + 13.7, -47), "OpGlow", 3, 0.2, 3, 0, 0, 0, st(M.Neon, nil, C3(230, 255, 240)), DECO)
light(ol, 20, 1.4, C3(220, 255, 230))
for _, x in { 30, 36, 42 } do
	for _, y in { 1, 4.5, 8 } do box(DEC, "Drawer", x - 2.6, F1 + y, -57.8, x + 2.6, F1 + y + 3, -57, MOON.steelL, DECO); box(DEC, "Handle", x - 1, F1 + y + 1.3, -57, x + 1, F1 + y + 1.7, -56.7, MOON.black, DECO) end
end
for _, x in { -40, -34 } do box(DEC, "Shower", x - 0.2, F1, -54, x + 0.2, F1 + 12, -53.6, MOON.steelL, DECO) end
box(DEC, "ShowerHead", -40.5, F1 + 11.6, -55, -33.5, F1 + 12, -53, MOON.steelL, DECO)
box(DEC, "ShowerTray", -41, F1 + 0.02, -57, -33, F1 + 0.1, -50, MOON.panelD, DECO)
-- THE STASH behind the server rack (x -78..-58, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", -58.2, F1, -58, -57, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", -78, F1, -43.2, -70, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", -64, F1, -43.2, -58.2, F1 + 12, -42, MOON.steelD)
box(sr, "Lintel", -70, F1 + 9, -43.2, -64, F1 + 12, -42, MOON.steelD)
box(sr, "Ceiling", -78, F1 + 12, -58, -57, F1 + 12.6, -42, MOON.panelD)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "ServerRack")
door:SetAttribute("Slide", Vector3.new(6.4, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "Humming server rack")
box(door, "Panel", -70, F1, -42.9, -64, F1 + 9, -40.6, MOON.black)
for y = 1, 8 do box(door, "Panel", -69.6, F1 + y, -40.65, -64.4, F1 + y + 0.15, -40.4, (y % 2 == 0) and MOON.green or MOON.blue, DECO) end
box(door, "Trigger", -67.5, F1 + 4, -39.6, -66.5, F1 + 5, -38.6, MOON.black, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", -63 + k * 1.4, F1 + 0.06, -40 + k * 0.2, -62 + k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(150, 150, 156)), DECO) end
local loot = model(DEC, "Stash")
tank(-68, -52, false)
local sg = b(loot, CFrame.new(-66, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, MOON.green, { deco = true, t = 1 })
light(sg, 18, 1, C3(150, 255, 160))

-- lights: green-white strips over the benches and tanks
for _, p in { { -16, 36 }, { 16, 36 }, { -16, 6 }, { 16, 6 }, { -48, 20 }, { 48, 20 } } do fluoro(p[1], F1 + H - 1, p[2], C3(210, 255, 225)) end
for _, p in { { -30, -46 }, { 30, -46 } } do fluoro(p[1], F1 + H - 1, p[2], C3(225, 240, 255)) end
for _, p in { { -30, 30 }, { 20, -14 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 50 }, { 40, 50 }, { 0, 20 }, { -30, -10 }, { 30, -10 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-62, -42, -54, -34, F1)
moonSign("THE LAB")
moonGrounds()
return endMap()
