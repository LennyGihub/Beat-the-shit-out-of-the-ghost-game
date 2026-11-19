-- THE MOONLIGHT CARNIVAL: what its six buildings share (Shared/Campaign map 2: one building per train trip). Prepend
-- after lib2 + furn_lib + maplib, then one maps/carn_<building>.luau:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_bigtop.luau
-- Every building is a map on the Mansion's footprint. Outside: the fair - a dirt path from the porch to the railway
-- (the train stops at z = 150, the party gets off at z = 141), the MOONLIGHT CARNIVAL arch with bulbs, string lights
-- on poles along the path, a ticket booth, a Ferris wheel, little striped tents, a popcorn cart, balloons on posts.
-- On the building: a striped frieze with bulbs round the top of the walls and the building's name on a marquee.
-- Then furnish (ONLY = the map) and doors_clear like every map, and maps/carn_items.luau (item spots).
local C3k = Color3.fromRGB
local function Dk() return { deco = true } end -- (a fresh table each time: cyl / ball write the shape into it)
local CARN = {
	canvasR = st(M.Fabric, nil, C3k(150, 30, 34)),
	canvasW = st(M.Fabric, nil, C3k(222, 208, 178)),
	wood = st(M.WoodPlanks, "PS2_Siding1", C3k(96, 64, 46)),
	woodD = st(M.Wood, "PS2_DarkBeam1", C3k(58, 40, 30)),
	paint = st(M.WoodPlanks, "PS2_Siding1", C3k(74, 42, 84)),
	board = st(M.WoodPlanks, "PS2_FloorPlanks2", C3k(104, 78, 56)),
	gold = st(M.Metal, nil, C3k(200, 160, 60)),
	iron = st(M.Metal, nil, C3k(44, 42, 44)),
	sawdust = st(M.Ground, nil, C3k(150, 120, 80)),
	bulb = st(M.Neon, nil, C3k(255, 214, 140)),
	red = st(M.SmoothPlastic, nil, C3k(170, 30, 36)),
	white = st(M.SmoothPlastic, nil, C3k(230, 222, 204)),
	yellow = st(M.SmoothPlastic, nil, C3k(222, 180, 50)),
	blue = st(M.SmoothPlastic, nil, C3k(50, 74, 156)),
	green = st(M.SmoothPlastic, nil, C3k(60, 130, 70)),
	stone = st(M.Cobblestone, "PS2_Stone1", C3k(96, 92, 88)),
	dirt = st(M.Ground, nil, C3k(64, 54, 44)),
	black = st(M.Fabric, nil, C3k(18, 16, 18)),
	velvet = st(M.Fabric, nil, C3k(110, 20, 40)),
}
local function carnTheme(over: { [string]: any }?)
	local t = {
		floor = CARN.board, floor2 = CARN.board, inner = st(M.WoodPlanks, "PS2_Siding1", C3k(112, 72, 70)), wainscot = CARN.woodD, wain = true,
		ext = CARN.paint, trim = CARN.gold, ceiling = CARN.woodD, roof = CARN.canvasR, found = CARN.stone,
		door = st(M.WoodPlanks, "PS2_Siding1", C3k(120, 30, 34)), porch = CARN.board,
		lanternColor = C3k(255, 200, 130), floodColor = C3k(220, 190, 170),
	}
	for k, v in over or {} do t[k] = v end
	return t
end

-- a row of small bulbs from a to b (deco), every `step` studs
local function carnBulbs(parent: Instance, a: Vector3, b: Vector3, step: number, color: Color3?)
	local d = b - a
	local n = math.max(1, math.floor(d.Magnitude / step))
	for i = 0, n do
		local p = a:Lerp(b, i / n)
		ball(parent, CFrame.new(p), "Bulb", 0.45, 0, 0, 0, color and st(M.Neon, nil, color) or CARN.bulb, Dk())
	end
end
-- a string of pennants from a to b, sagging (deco)
local function carnBunting(parent: Instance, a: Vector3, b: Vector3, n: number)
	local cols = { CARN.red, CARN.yellow, CARN.blue, CARN.white, CARN.green }
	for i = 0, n - 1 do
		local u = (i + 0.5) / n
		local p = a:Lerp(b, u) - Vector3.new(0, math.sin(u * math.pi) * 2.2, 0)
		local dir = (b - a).Unit
		part(parent, "Pennant", Vector3.new(0.08, 1.4, 1.2), CFrame.lookAt(p, p + dir) * CFrame.new(0, -0.7, 0) * CFrame.Angles(0, math.pi / 2, 0), cols[i % #cols + 1], DECO)
	end
end
-- a blocky teddy bear (a prize), sitting (deco)
local function carnTeddy(parent: Instance, cf: CFrame, s: number, color: Color3)
	local fur = st(M.Fabric, nil, color)
	local m = model(parent, "Teddy")
	b(m, cf, "Body", 1.4 * s, 1.6 * s, 1.1 * s, 0, 0.8 * s, 0, fur, DECO)
	b(m, cf, "Head", 1.2 * s, 1.1 * s, 1.1 * s, 0, 2.15 * s, 0, fur, DECO)
	b(m, cf, "Snout", 0.6 * s, 0.45 * s, 0.3 * s, 0, 2.0 * s, -0.65 * s, st(M.Fabric, nil, color:Lerp(C3k(240, 230, 210), 0.5)), DECO)
	for _, sx in { -1, 1 } do
		b(m, cf, "Ear", 0.4 * s, 0.4 * s, 0.25 * s, sx * 0.5 * s, 2.8 * s, 0, fur, DECO)
		b(m, cf, "Eye", 0.14 * s, 0.14 * s, 0.05 * s, sx * 0.25 * s, 2.3 * s, -0.56 * s, CARN.black, DECO)
		b(m, cf, "Arm", 0.45 * s, 1.1 * s, 0.45 * s, sx * 0.85 * s, 1.0 * s, -0.15 * s, fur, DECO)
		b(m, cf, "Leg", 0.55 * s, 0.5 * s, 1.0 * s, sx * 0.4 * s, 0.25 * s, -0.55 * s, fur, DECO)
	end
	b(m, cf, "Bow", 0.9 * s, 0.35 * s, 0.2 * s, 0, 1.6 * s, -0.58 * s, CARN.red, DECO)
	return m
end
-- a mannequin sitting in the stands, facing along cf's front (deco: the Ringmaster's whip wakes them)
local function carnMannequin(parent: Instance, cf: CFrame)
	local W = st(M.SmoothPlastic, nil, C3k(222, 214, 200))
	local J = st(M.SmoothPlastic, nil, C3k(150, 140, 126))
	local m = model(parent, "Mannequin")
	b(m, cf, "Torso", 1.6, 2.0, 0.9, 0, 2.6, 0.2, W, DECO)
	b(m, cf, "Hips", 1.4, 0.8, 1.0, 0, 1.4, 0.1, W, DECO)
	b(m, cf, "Neck", 0.4, 0.4, 0.4, 0, 3.8, 0.2, J, DECO)
	b(m, cf, "Head", 0.9, 1.2, 0.9, 0, 4.5, 0.2, W, DECO)
	for _, sx in { -1, 1 } do
		b(m, cf, "Thigh", 0.55, 0.55, 2.0, sx * 0.4, 1.3, -0.8, W, DECO)
		b(m, cf, "Shin", 0.5, 2.0, 0.5, sx * 0.4, 0.25, -1.8, W, DECO)
		b(m, cf, "Arm", 0.45, 1.9, 0.45, sx * 1.05, 2.4, 0, W, DECO)
		b(m, cf, "Shoulder", 0.5, 0.5, 0.5, sx * 1.0, 3.4, 0.2, J, DECO)
	end
	m:PivotTo(m:GetPivot())
	return m
end
-- a little striped tent (deco): a box body and a pointed top of stacked rings, a pennant on the tip
local function carnTent(parent: Instance, cf: CFrame, w: number, h: number)
	local m = model(parent, "Tent")
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		b(m, cf * CFrame.Angles(0, a, 0), "Side", w * 0.42, h, 0.3, 0, h / 2, -w * 0.5, i % 2 == 0 and CARN.red or CARN.canvasW, DECO)
	end
	for k = 0, 3 do
		cyl(m, cf, "Top", w * (1.05 - k * 0.26), 1.1, 0, h + 0.5 + k * 1.05, 0, k % 2 == 0 and CARN.red or CARN.canvasW, Dk())
	end
	cyl(m, cf, "Pole", 0.2, 2.4, 0, h + 5.2, 0, CARN.woodD, Dk())
	b(m, cf, "Flag", 0.06, 0.8, 1.2, 0, h + 6, -0.6, CARN.yellow, DECO)
	return m
end

-- the building's name on a marquee over the porch roof: a board ringed with bulbs
local function carnMarquee(text: string, at: CFrame?)
	local m = model(DEC, "Marquee")
	local cf = (at or CFrame.new(0, 21, 61)) * CFrame.Angles(0, math.pi, 0)
	b(m, cf, "Back", 26, 5.4, 0.4, 0, 0, 0.3, CARN.velvet, DECO)
	b(m, cf, "Frame", 27, 6.2, 0.3, 0, 0, 0.5, CARN.gold, DECO)
	sign(m, text, cf * CFrame.new(0, 0, -0.05), 23, 3.6, CARN.velvet, C3k(255, 226, 150), Enum.Font.Creepster)
	for i = 0, 25 do
		local x = -13 + i * 26 / 25
		ball(m, cf * CFrame.new(x, 2.9, -0.2), "Bulb", 0.5, 0, 0, 0, CARN.bulb, Dk())
		ball(m, cf * CFrame.new(x, -2.9, -0.2), "Bulb", 0.5, 0, 0, 0, CARN.bulb, Dk())
	end
	local glow = b(m, cf, "Glow", 0.2, 0.2, 0.2, 0, 0, -2, CARN.bulb, { deco = true, t = 1 })
	light(glow, 30, 1.3, C3k(255, 200, 120))
	if not at then for _, x in { -12, 12 } do box(m, "Peg", x - 0.25, 17.4, 60.6, x + 0.25, 24.5, 61.2, CARN.woodD, DECO) end end
	return m
end

-- a frieze round the top of the outside walls: red and cream blocks, a row of bulbs under it
local function carnFrieze(H: number)
	local fr = model(DEC, "Frieze")
	local top = F1 + H
	local y0, y1 = top - 3.4, top - 0.6
	local k = 0
	for x = -78, 74, 4 do
		k += 1
		local s = k % 2 == 0 and CARN.red or CARN.canvasW
		box(fr, "Band", x, y0, 60.15, x + 4, y1, 60.4, s, DECO)
		box(fr, "Band", x, y0, -60.4, x + 4, y1, -60.15, s, DECO)
	end
	k = 0
	for z = -58, 54, 4 do
		k += 1
		local s = k % 2 == 0 and CARN.red or CARN.canvasW
		box(fr, "Band", 80.15, y0, z, 80.4, y1, z + 4, s, DECO)
		box(fr, "Band", -80.4, y0, z, -80.15, y1, z + 4, s, DECO)
	end
	carnBulbs(fr, Vector3.new(-78, y0 - 0.5, 60.6), Vector3.new(78, y0 - 0.5, 60.6), 3)
	carnBulbs(fr, Vector3.new(80.6, y0 - 0.5, -58), Vector3.new(80.6, y0 - 0.5, 58), 4)
	carnBulbs(fr, Vector3.new(-80.6, y0 - 0.5, -58), Vector3.new(-80.6, y0 - 0.5, 58), 4)
end

-- the fair in the yard (everything decoration: no collision, never hit by a ray)
local function carnGrounds()
	local yd = model(DEC, "Fairground")
	-- the path, porch to railway, with a few boards in it
	box(yd, "Path", -5, 0.08, 62, 5, 0.18, 113, CARN.dirt, DECO)
	for z = 80, 110, 10 do box(yd, "PathBoard", -2, 0.1, z, 2, 0.2, z + 1.2, CARN.woodD, DECO) end
	-- (2026-11-19: the arch, the Ferris wheel, the tents and the popcorn cart are in the Carnival WORLD now:
	-- tools/build/worlds/carnival.luau. A building keeps its path, the string lights, the ticket booth, balloons.)
	-- string lights on poles along the path
	for _, z in { 86, 104, 122 } do
		for _, x in { -9, 9 } do cyl(yd, CFrame.new(x, 6, z), "LightPole", 0.4, 12, 0, 0, 0, CARN.woodD, Dk()) end
		carnBulbs(yd, Vector3.new(-9, 11.6, z), Vector3.new(9, 11.6, z), 1.6, C3k(255, 230, 170))
	end
	carnBunting(yd, Vector3.new(-9, 11.8, 86), Vector3.new(-9, 11.8, 122), 18)
	carnBunting(yd, Vector3.new(9, 11.8, 86), Vector3.new(9, 11.8, 122), 18)
	for _, z in { 95, 113 } do
		local lg = b(yd, CFrame.new(0, 10, z), "PathGlow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
		light(lg, 22, 1.1, C3k(255, 200, 140))
	end
	-- the ticket booth (east of the path)
	local tb = model(yd, "TicketBooth")
	box(tb, "Booth", 14, 0, 124, 22, 9, 130, CARN.red, DECO)
	box(tb, "Window", 15.5, 4, 123.8, 20.5, 7, 124.05, CARN.black, DECO)
	box(tb, "Roof", 13, 9, 123, 23, 10, 131, CARN.gold, DECO)
	sign(tb, "TICKETS", CFrame.new(18, 11.3, 123.6) * CFrame.Angles(0, math.pi, 0), 7, 1.6, CARN.velvet, C3k(255, 220, 140), Enum.Font.Creepster)
	for _, p in { { -12, 96 }, { 12, 116 }, { -26, 128 } } do
		cyl(yd, CFrame.new(p[1], 3, p[2]), "BalloonPost", 0.25, 6, 0, 0, 0, CARN.woodD, Dk())
		for k, col in { C3k(220, 40, 40), C3k(60, 120, 230), C3k(240, 200, 50) } do
			local o = Vector3.new((k - 2) * 0.9, 9 + (k % 2) * 0.8, 0)
			b(yd, CFrame.new(p[1], 0, p[2]), "String", 0.05, 3.2, 0.05, o.X * 0.5, 7.4, 0, CARN.white, DECO)
			ball(yd, CFrame.new(p[1] + o.X, o.Y, p[2] + o.Z), "Balloon", 1.5, 0, 0, 0, st(M.SmoothPlastic, nil, col), Dk())
		end
	end
end
