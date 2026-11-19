-- THE MOONLIGHT CARNIVAL's world (ServerStorage.Worlds.Carnival): an abandoned funfair under a purple night, all its
-- bulbs still lit.
--   WEST   the giant FERRIS WHEEL (a ring of bulbs, sixteen gondolas) and the SWING RIDE
--   EAST   the wooden ROLLER COASTER on its lattice of supports, a lift hill and drops
--   NORTH  the DROP TOWER rising over the building's roof with its red beacon, two SEARCHLIGHTS sweeping the clouds
--   SOUTH  across the railway: the midway of striped game tents, food stands and sideshow banners under strings of bulbs
--   YARD   the MOONLIGHT CARNIVAL arch over the path, a fence of striped boards and bulb posts round it
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--   tools/build/worlds/world_lib.luau tools/build/worlds/carnival.luau
local C3 = Color3.fromRGB
local rng = Random.new(1931)
local W = beginWorld("Carnival")
local RED = st(M.SmoothPlastic, nil, C3(170, 30, 36))
local WHITE = st(M.SmoothPlastic, nil, C3(230, 222, 204))
local YEL = st(M.SmoothPlastic, nil, C3(222, 180, 50))
local BLUE = st(M.SmoothPlastic, nil, C3(50, 74, 156))
local GREEN = st(M.SmoothPlastic, nil, C3(60, 130, 70))
local PURP = st(M.SmoothPlastic, nil, C3(110, 50, 140))
local IRON = st(M.Metal, nil, C3(60, 58, 64))
local STEEL = st(M.Metal, nil, C3(150, 150, 158))
local GOLD = st(M.Metal, nil, C3(200, 160, 60))
local WOOD = st(M.WoodPlanks, "PS2_Siding1", C3(96, 64, 46))
local WOODD = st(M.Wood, "PS2_DarkBeam1", C3(58, 40, 30))
local LATTICE = st(M.Wood, nil, C3(120, 104, 90))
local CANVAS_R = st(M.Fabric, nil, C3(150, 30, 34))
local CANVAS_W = st(M.Fabric, nil, C3(222, 208, 178))
local VELVET = st(M.Fabric, nil, C3(110, 20, 40))
local GROUND = st(M.Ground, nil, C3(50, 44, 40))
local GRAVEL = st(M.Pebble, nil, C3(92, 84, 76))
local GRASS = st(M.Grass, nil, C3(38, 40, 34))
local BULBS = { C3(255, 214, 140), C3(255, 120, 120), C3(140, 200, 255), C3(255, 240, 160) }
local WARM = C3(255, 206, 140)
local stripes = { CANVAS_R, CANVAS_W }

---------------------------------------------------------------- the ground and the midways
local gnd = model(W, "Ground")
box(gnd, "Field", -900, -0.9, -800, 900, 0.02, 900, GRASS, WD())
box(gnd, "Trodden", -420, 0.02, -360, 420, 0.05, 420, GROUND, WD())
box(gnd, "Yard", -95, 0.05, 52, 95, 0.08, 168, GRAVEL, WD())
-- the midways: gravel lanes between the rides
box(gnd, "Midway", -420, 0.06, 196, 420, 0.1, 222, GRAVEL, WD())
box(gnd, "Midway", -140, 0.06, -300, -114, 0.1, 196, GRAVEL, WD())
box(gnd, "Midway", 114, 0.06, -300, 140, 0.1, 196, GRAVEL, WD())
box(gnd, "Midway", -140, 0.06, -170, 140, 0.1, -144, GRAVEL, WD())
for k = 1, 60 do -- litter: tickets, cups, popcorn
	local x, z = rng:NextNumber(-400, 400), rng:NextNumber(-300, 400)
	if not inPlay(x, z, 0) then
		local c = ({ C3(220, 60, 50), C3(240, 230, 200), C3(60, 120, 220), C3(250, 220, 120) })[rng:NextInteger(1, 4)]
		part(gnd, "Litter", Vector3.new(rng:NextNumber(0.6, 1.4), 0.1, rng:NextNumber(0.6, 1.4)), CFrame.new(x, 0.12, z) * CFrame.Angles(0, rng:NextNumber(0, 3), 0), st(M.SmoothPlastic, nil, c), WD())
	end
end

---------------------------------------------------------------- the striped tent kit
-- a round tent: striped wall, striped cone roof, a flag on top
local function roundTent(parent: Instance, cx: number, cz: number, r: number, h: number, rise: number, n: number, flag: Color3?)
	local m = model(parent, "Tent")
	local pts = {}
	for k = 0, n - 1 do
		local a = k * 2 * math.pi / n
		table.insert(pts, { cx + r * math.cos(a), cz + r * math.sin(a) })
	end
	for i, p in pts do
		local q = pts[i % n + 1]
		local a, z = Vector3.new(p[1], 0, p[2]), Vector3.new(q[1], 0, q[2])
		part(m, "Wall", Vector3.new(0.6, h, (z - a).Magnitude + 0.3), CFrame.lookAt((a + z) / 2 + Vector3.new(0, h / 2, 0), z + Vector3.new(0, h / 2, 0)), stripes[i % 2 + 1], WD())
	end
	coneRoof(m, pts, h, Vector3.new(cx, h + rise, cz), CANVAS_R, 1.5, 0.6, CANVAS_W)
	box(m, "FlagPole", cx - 0.15, h + rise, cz - 0.15, cx + 0.15, h + rise + 5, cz + 0.15, IRON, WD())
	box(m, "Flag", cx + 0.15, h + rise + 3, cz - 0.1, cx + 3, h + rise + 4.8, cz + 0.1, st(M.Fabric, nil, flag or C3(230, 190, 60)), WD())
	return m
end
-- a game booth: counter, striped awning, prizes hanging, a lit sign
local function booth(parent: Instance, cf: CFrame, w: number, title: string, col)
	local m = model(parent, "Booth")
	b(m, cf, "Back", w, 9, 0.6, 0, 4.5, 3, col, WD())
	for _, x in { -w / 2, w / 2 } do b(m, cf, "Side", 0.6, 9, 6, x, 4.5, 0, col, WD()) end
	b(m, cf, "Counter", w, 3.4, 1.4, 0, 1.7, -2.6, WOOD, WD())
	for k = 0, math.floor(w / 2) - 1 do
		b(m, cf * CFrame.new(-w / 2 + 1 + k * 2, 9.4, -3.6) * CFrame.Angles(0.5, 0, 0), "Awning", 2.05, 0.3, 3.4, 0, 0, 0, stripes[k % 2 + 1], WD())
	end
	for k = 0, math.floor(w / 3) - 1 do
		local tc = ({ C3(220, 120, 160), C3(120, 180, 230), C3(240, 210, 90), C3(150, 220, 140) })[k % 4 + 1]
		b(m, cf, "Prize", 1.8, 2.2, 1.4, -w / 2 + 2 + k * 3, 7, 2.2, st(M.Fabric, nil, tc), WD())
	end
	sign(m, title, cf * CFrame.new(0, 11.4, -3.2), w - 1, 2, VELVET, C3(255, 226, 150), Enum.Font.Creepster)
	local g = b(m, cf, "Glow", 0.2, 0.2, 0.2, 0, 6, -4, YEL, { deco = true, t = 1 })
	light(g, 16, 0.9, WARM)
	return m
end
-- a canvas banner on two poles (the sideshow line)
local function banner(parent: Instance, cf: CFrame, title: string, col: Color3)
	b(parent, cf, "Pole", 0.5, 18, 0.5, -5.5, 9, 0, WOODD, WD())
	b(parent, cf, "Pole", 0.5, 18, 0.5, 5.5, 9, 0, WOODD, WD())
	b(parent, cf, "Canvas", 10.4, 12, 0.3, 0, 11, 0, st(M.Fabric, nil, col), WD())
	b(parent, cf, "Frame", 11, 12.6, 0.2, 0, 11, 0.2, GOLD, WD())
	sign(parent, title, cf * CFrame.new(0, 15, -0.2), 9.6, 2.4, st(M.Fabric, nil, col), C3(255, 236, 190), Enum.Font.Creepster)
end

---------------------------------------------------------------- THE FERRIS WHEEL (west)
do
	local fw = model(W, "FerrisWheel")
	local R, cy = 58, 66
	local c = CFrame.new(-200, cy, 70) * CFrame.Angles(0, math.pi / 2 - 0.35, 0) -- (turned a little to face the yard)
	for _, side in { -3, 3 } do
		for k = 0, 15 do
			local a = k / 16 * math.pi * 2
			b(fw, c * CFrame.new(0, 0, side) * CFrame.Angles(0, 0, a), "Spoke", 0.7, R, 0.7, 0, R / 2, 0, STEEL, WD())
			b(fw, c * CFrame.new(0, 0, side) * CFrame.Angles(0, 0, a + math.pi / 16), "Rim", 1, 2 * R * math.sin(math.pi / 16) + 0.6, 1, 0, R * math.cos(math.pi / 16), 0, STEEL, WD())
		end
	end
	cyl(fw, c * CFrame.Angles(math.pi / 2, 0, 0), "Hub", 8, 7, 0, 0, 0, GOLD, WD())
	-- bulbs round the rim and down the spokes
	for k = 0, 47 do
		local a = k / 48 * math.pi * 2
		ball(fw, c * CFrame.new(math.cos(a) * (R + 1), math.sin(a) * (R + 1), 3.6), "RimBulb", 1.2, 0, 0, 0, st(M.Neon, nil, BULBS[k % 4 + 1]), WD())
	end
	for k = 0, 15 do
		local a = k / 16 * math.pi * 2
		for j = 1, 4 do ball(fw, c * CFrame.new(math.cos(a) * R * j / 5, math.sin(a) * R * j / 5, 3.6), "SpokeBulb", 0.9, 0, 0, 0, st(M.Neon, nil, BULBS[(k + j) % 4 + 1]), WD()) end
	end
	-- the gondolas, hanging level
	for k = 0, 15 do
		local a = k / 16 * math.pi * 2 + math.pi / 16
		local p = (c * CFrame.new(math.cos(a) * R, math.sin(a) * R, 0)).Position
		local gcf = CFrame.new(p) * c.Rotation
		b(fw, gcf, "Hanger", 0.4, 4, 0.4, 0, -2, 0, IRON, WD())
		local col = ({ RED, YEL, BLUE, GREEN, PURP })[k % 5 + 1]
		b(fw, gcf, "Gondola", 5.4, 3.6, 4.4, 0, -5.6, 0, col, WD())
		b(fw, gcf, "GondolaRoof", 6, 0.6, 5, 0, -3.6, 0, col, WD())
	end
	-- the A-frame legs, the base and the ticket hut
	for _, sz in { -1, 1 } do
		local base = c * CFrame.new(0, 0, sz * 9)
		for _, sx in { -1, 1 } do
			local foot = (c * CFrame.new(sx * 34, -cy, sz * 14)).Position
			local top = (base).Position
			part(fw, "Leg", Vector3.new(2.2, 2.2, (top - foot).Magnitude), CFrame.lookAt((top + foot) / 2, top), STEEL, WD())
		end
	end
	local glow = b(fw, c, "WheelGlow", 0.2, 0.2, 0.2, 0, 0, 12, YEL, { deco = true, t = 1 })
	light(glow, 90, 1.6, C3(255, 200, 150))
	box(fw, "Platform", -214, 0, 46, -186, 2, 94, WOODD, WD())
end

---------------------------------------------------------------- THE SWING RIDE (north-west)
do
	local sw = model(W, "SwingRide")
	local cx, cz = -170, -150
	cyl(sw, CFrame.new(cx, 22, cz), "Mast", 4, 44, 0, 0, 0, GOLD, WD())
	local pts = {}
	for k = 0, 15 do local a = k * math.pi / 8; table.insert(pts, { cx + 22 * math.cos(a), cz + 22 * math.sin(a) }) end
	coneRoof(sw, pts, 40, Vector3.new(cx, 50, cz), CANVAS_R, 0, 0.6, CANVAS_W)
	for k = 0, 15 do
		local a = k * math.pi / 8
		local top = Vector3.new(cx + 20 * math.cos(a), 39, cz + 20 * math.sin(a))
		local seat = Vector3.new(cx + 30 * math.cos(a), 22, cz + 30 * math.sin(a))
		part(sw, "Chain", Vector3.new(0.2, 0.2, (seat - top).Magnitude), CFrame.lookAt((top + seat) / 2, seat), IRON, WD())
		box(sw, "Seat", seat.X - 1, seat.Y - 1, seat.Z - 1, seat.X + 1, seat.Y, seat.Z + 1, ({ RED, YEL, BLUE })[k % 3 + 1], WD())
		ball(sw, CFrame.new(cx + 22 * math.cos(a), 39.6, cz + 22 * math.sin(a)), "EdgeBulb", 1, 0, 0, 0, st(M.Neon, nil, BULBS[k % 4 + 1]), WD())
	end
	light(box(sw, "Glow", cx - 0.1, 30, cz - 0.1, cx + 0.1, 30.2, cz + 0.1, YEL, { deco = true, t = 1 }), 50, 1.2, WARM)
	sw.WorldPivot = CFrame.new(cx, 0, cz)
	sw:SetAttribute("Spin", 40) -- (it turns: Client/WorldSpin)
end

---------------------------------------------------------------- THE ROLLER COASTER (east)
do
	local rc = model(W, "Coaster")
	local cx, cz, rx, rz = 320, -60, 130, 160 -- (clear of the railway at z 150)
	local N = 72
	local function at(k: number): Vector3
		local t = (k % N) / N * math.pi * 2
		-- the height: a long lift hill, then drops and smaller hills
		local h = 8 + 70 * math.max(0, math.sin(t * 1)) ^ 3 + 22 * math.max(0, math.sin(t * 3 + 1)) ^ 2 + 8 * math.sin(t * 5) ^ 2
		return Vector3.new(cx + rx * math.cos(t), h, cz + rz * math.sin(t))
	end
	for k = 0, N - 1 do
		local a, z = at(k), at(k + 1)
		local d = (z - a)
		local cf = CFrame.lookAt((a + z) / 2, z)
		for _, sx in { -1.6, 1.6 } do part(rc, "Rail", Vector3.new(0.5, 0.5, d.Magnitude + 0.2), cf * CFrame.new(sx, 0, 0), STEEL, WD()) end
		part(rc, "Tie", Vector3.new(4.6, 0.6, 1.2), cf * CFrame.new(0, -0.6, 0), WOODD, WD())
		-- the lattice under it: two posts and a cross brace every other piece
		if k % 2 == 0 then
			for _, sx in { -2.4, 2.4 } do
				local top = (cf * CFrame.new(sx, -0.8, 0)).Position
				part(rc, "Support", Vector3.new(0.9, top.Y, 0.9), CFrame.new(top.X, top.Y / 2, top.Z), LATTICE, WD())
			end
			if a.Y > 14 then
				local p1 = (cf * CFrame.new(-2.4, -a.Y * 0.3, 0)).Position
				local p2 = (cf * CFrame.new(2.4, -a.Y * 0.75, 0)).Position
				part(rc, "Brace", Vector3.new(0.5, 0.5, (p2 - p1).Magnitude), CFrame.lookAt((p1 + p2) / 2, p2), LATTICE, WD())
			end
		end
		if k % 6 == 0 then ball(rc, CFrame.new(a + Vector3.new(0, 1.2, 0)), "TrackBulb", 0.9, 0, 0, 0, st(M.Neon, nil, BULBS[k % 4 + 1]), WD()) end
	end
	-- a train of cars stopped on the lift hill
	for k = 0, 3 do
		local a, z = at(10 + k), at(11 + k)
		local cf = CFrame.lookAt((a + z) / 2, z)
		b(rc, cf, "Car", 4.2, 2.6, 5, 0, 1.8, 0, ({ RED, YEL })[k % 2 + 1], WD())
	end
	sign(rc, "THE MOONLIGHT EXPRESS", CFrame.new(cx - rx - 2, 34, cz) * CFrame.Angles(0, math.pi / 2, 0), 34, 5, VELVET, C3(255, 226, 150), Enum.Font.Creepster)
	light(box(rc, "Glow", cx - rx, 30, cz - 0.1, cx - rx + 0.2, 30.2, cz + 0.1, YEL, { deco = true, t = 1 }), 60, 1.2, C3(255, 190, 140))
end

---------------------------------------------------------------- THE DROP TOWER (north) and the searchlights
do
	local dt = model(W, "DropTower")
	local cx, cz, H = 70, -210, 150
	prism(dt, "Spine", cx, cz, 4.5, 0, H, 8, STEEL, WD())
	for y = 10, H - 10, 10 do ball(dt, CFrame.new(cx, y, cz + 4.8), "SpineBulb", 1.2, 0, 0, 0, st(M.Neon, nil, BULBS[(y / 10) % 4 + 1]), WD()) end
	-- the ring of seats near the top
	for k = 0, 11 do
		local a = k * math.pi / 6
		box(dt, "Seat", cx + 7 * math.cos(a) - 1.4, H - 30, cz + 7 * math.sin(a) - 1.4, cx + 7 * math.cos(a) + 1.4, H - 26, cz + 7 * math.sin(a) + 1.4, ({ RED, YEL, BLUE })[k % 3 + 1], WD())
	end
	cyl(dt, CFrame.new(cx, H - 31, cz), "Collar", 18, 1.6, 0, 0, 0, GOLD, WD())
	local cap = ball(dt, CFrame.new(cx, H + 3, cz), "Beacon", 4, 0, 0, 0, st(M.Neon, nil, C3(255, 40, 40)), WD())
	light(cap, 60, 2, C3(255, 40, 40))
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do
		local foot = Vector3.new(cx + sx * 16, 0, cz + sz * 16)
		local top = Vector3.new(cx + sx * 4, 40, cz + sz * 4)
		part(dt, "Strut", Vector3.new(1.6, 1.6, (top - foot).Magnitude), CFrame.lookAt((top + foot) / 2, top), STEEL, WD())
	end end
	-- two searchlights crossing in the sky
	for i, p in { { -60, -260, 0.35 }, { 220, -200, -0.4 } } do
		local base = Vector3.new(p[1], 4, p[2])
		box(dt, "SearchlightBase", base.X - 3, 0, base.Z - 3, base.X + 3, 4, base.Z + 3, IRON, WD())
		local dir = (CFrame.Angles(0, p[3], 0) * CFrame.Angles(math.rad(62), 0, 0)).LookVector
		dir = Vector3.new(dir.X, math.abs(dir.Y), dir.Z).Unit
		local len = 520
		local beam = part(dt, "SearchBeam", Vector3.new(5, 5, len), CFrame.lookAt(base + dir * len / 2, base + dir * len), st(M.Neon, nil, C3(200, 190, 255)), { deco = true, t = 0.9, noShadow = true })
		beam.CastShadow = false
	end
end

---------------------------------------------------------------- THE MIDWAY (south of the railway)
do
	local mid = model(W, "Midway")
	local titles = { "RING TOSS", "DUCK SHOOT", "HOOPS", "BALLOON DARTS", "GUESS YOUR WEIGHT", "MILK BOTTLES", "LUCKY FISH", "COCONUTS" }
	local cols = { BLUE, PURP, GREEN, RED, YEL, BLUE, PURP, GREEN }
	for i = 1, 8 do
		local x = -330 + i * 72
		booth(mid, CFrame.new(x, 0, 236), 14, titles[i], cols[i]) -- (its counter faces the midway and the yard)
	end
	-- the food stands
	local foods = { { "HOT DOGS", C3(200, 60, 40) }, { "COTTON CANDY", C3(230, 120, 180) }, { "POPCORN", C3(230, 200, 60) } }
	for i, f in foods do
		local cf = CFrame.new(-260 + i * 160, 0, 182)
		b(mid, cf, "Stand", 12, 7, 7, 0, 3.5, 0, st(M.SmoothPlastic, nil, f[2]), WD())
		b(mid, cf, "Roof", 14, 1, 9, 0, 9.5, 0, WHITE, WD())
		for _, x in { -6.4, 6.4 } do b(mid, cf, "Post", 0.4, 2.5, 0.4, x, 7.8, -4, WOODD, WD()) end
		sign(mid, f[1], cf * CFrame.new(0, 11.2, -4.6), 11, 1.8, st(M.SmoothPlastic, nil, f[2]), C3(255, 250, 230), Enum.Font.Creepster)
		light(b(mid, cf, "Glow", 0.2, 0.2, 0.2, 0, 6, -6, YEL, { deco = true, t = 1 }), 18, 0.9, WARM)
	end
	-- the sideshow banners
	local acts = { { "THE WOLF BOY", C3(80, 40, 90) }, { "SNAKE LADY", C3(40, 90, 60) }, { "FIRE EATER", C3(150, 50, 30) }, { "THE LIVING SKELETON", C3(60, 60, 80) }, { "TWO-HEADED CALF", C3(110, 70, 40) } }
	for i, a in acts do banner(mid, CFrame.new(150 + i * 14, 0, 262), a[1], a[2]) end
	-- strings of bulbs over the midway
	for x = -380, 380, 40 do
		box(mid, "BulbPole", x - 0.3, 0, 194.7, x + 0.3, 16, 195.3, WOODD, WD())
		box(mid, "BulbPole", x - 0.3, 0, 222.7, x + 0.3, 16, 223.3, WOODD, WD())
		bulbLine(mid, Vector3.new(x, 15.6, 195), Vector3.new(x, 15.6, 223), 2.8, 2.4, BULBS, nil, x % 120 == 0 and 1 or 0)
	end
	-- round tents scattered round the fair
	for _, t in { { -300, 120, 18, 12, 14 }, { -260, -60, 22, 14, 16 }, { -320, -240, 16, 10, 12 }, { 30, 330, 26, 14, 18 }, { -120, 330, 18, 12, 14 }, { 200, 330, 16, 10, 12 }, { -40, -280, 20, 12, 14 } } do
		roundTent(mid, t[1], t[2], t[3], t[4], t[5], 12, BULBS[rng:NextInteger(1, 4)])
	end
	-- circus wagons parked behind the building
	for i, p in { { -60, -150 }, { -20, -160 }, { 160, -120 } } do
		local cf = CFrame.new(p[1], 0, p[2]) * CFrame.Angles(0, rng:NextNumber(-0.4, 0.4), 0)
		local col = ({ RED, BLUE, PURP })[i]
		b(mid, cf, "WagonBody", 9, 8, 18, 0, 6, 0, col, WD())
		b(mid, cf, "WagonRoof", 10, 1, 19, 0, 10.5, 0, GOLD, WD())
		for _, x in { -4.6, 4.6 } do for _, z in { -6, 6 } do cyl(mid, cf * CFrame.new(x, 2.4, z) * CFrame.Angles(0, 0, -math.pi / 2), "Wheel", 4.6, 0.6, 0, 0, 0, GOLD, WD()) end end
		for _, x in { -4.6, 4.6 } do for k = 0, 4 do b(mid, cf, "Bar", 0.3, 6, 0.3, x, 6, -7 + k * 3.5, GOLD, WD()) end end
	end
	-- lamp posts along the side midways
	for z = -280, 180, 46 do
		lampPost(mid, -127, z, WARM, 12, GOLD, 26)
		lampPost(mid, 127, z, WARM, 12, GOLD, 26)
	end
end

---------------------------------------------------------------- the yard: the arch and the fence
local yd = model(W, "FairYard")
box(yd, "Path", -5, 0.08, 112, 5, 0.16, 146, GROUND, WD())
for _, x in { -8, 8 } do
	for k = 0, 6 do box(yd, "Tower", x - 1.2, k * 2.2, 131, x + 1.2, k * 2.2 + 2.2, 133.4, k % 2 == 0 and CANVAS_R or CANVAS_W, WD()) end
	ball(yd, CFrame.new(x, 16.2, 132.2), "TowerBall", 2, 0, 0, 0, GOLD, WD())
end
box(yd, "ArchBeam", -9.5, 13.4, 131.4, 9.5, 15.6, 133, VELVET, WD())
sign(yd, "MOONLIGHT CARNIVAL", CFrame.new(0, 14.5, 131.3) * CFrame.Angles(0, math.pi, 0), 17, 2, VELVET, C3(255, 220, 140), Enum.Font.Creepster).Name = "CarnSign"
sign(yd, "MOONLIGHT CARNIVAL", CFrame.new(0, 14.5, 133.1), 17, 2, VELVET, C3(255, 220, 140), Enum.Font.Creepster).Name = "CarnSignBack"
bulbLine(yd, Vector3.new(-9.4, 16.2, 131.2), Vector3.new(9.4, 16.2, 131.2), 1.4, 0, BULBS)
light(box(yd, "ArchGlow", -0.1, 12, 127.9, 0.1, 12.2, 128.1, YEL, { deco = true, t = 1 }), 30, 1.4, C3(255, 190, 120))
local fence = model(W, "Fence")
yardEdge(fence, function(parent, x1, z1, x2, z2, gap)
	local a, z = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	local len = (z - a).Magnitude
	local dir = (z - a).Unit
	local n = math.floor(len / 4)
	for i = 0, n - 1 do
		local p = a + dir * (i * 4 + 2)
		if not (gap and gap(p.X, p.Z)) then
			part(parent, "Board", Vector3.new(0.4, 4.6, 3.8), CFrame.lookAt(p + Vector3.new(0, 2.3, 0), p + Vector3.new(0, 2.3, 0) + dir), i % 2 == 0 and RED or WHITE, WD())
			if i % 3 == 0 then
				box(parent, "BulbPost", p.X - 0.3, 0, p.Z - 0.3, p.X + 0.3, 6, p.Z + 0.3, GOLD, WD())
				ball(parent, CFrame.new(p.X, 6.4, p.Z), "PostBulb", 1, 0, 0, 0, st(M.Neon, nil, BULBS[i % 4 + 1]), WD())
			end
		end
	end
end)
-- hills far round the fair (low, dark) and a few trees at the edges
local hills = model(W, "Hills")
for k = 1, 12 do
	local a = k / 12 * math.pi * 2
	mountain(hills, rng, 760 * math.cos(a), 760 * math.sin(a) + 100, rng:NextNumber(200, 300), rng:NextNumber(60, 130), 8, st(M.Slate, nil, C3(30, 26, 40)))
end
local trees = model(W, "Trees")
forest(trees, rng, 90, -700, -650, 700, 700, { { "DeadTreeA", 1.1, 1.6 }, { "PineTree", 1.4, 2.2 } }, function(x, z) return math.abs(x) < 430 and z > -330 and z < 420 end)
return endWorld()
