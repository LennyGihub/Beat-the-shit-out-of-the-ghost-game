-- BLACKWATER HARBOR's world (ServerStorage.Worlds.Harbor): a fishing port in the fog, black water all round.
--   NORTH  the town climbs a hill behind the building: stone terraces, rows of narrow houses with lit windows, a
--          church steeple at the top
--   EAST   the quay: warehouses, a dock crane, stacked crates and barrels, a rusty trawler moored alongside
--   WEST   the breakwater running out to sea with the red and white HARBOR LIGHT at its end, rocks
--   SOUTH  across the railway (on its trestle): open water, fishing boats at anchor, buoys with lights, the mast of
--          a wreck sticking out of the water
--   YARD   iron bollards and chains round it, the BLACKWATER HARBOR arch
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--   tools/build/worlds/world_lib.luau tools/build/worlds/harbor.luau
local C3 = Color3.fromRGB
local rng = Random.new(1888)
local W = beginWorld("Harbor")
local STONE = st(M.Cobblestone, "PS2_Stone1", C3(84, 88, 92))
local STONED = st(M.Cobblestone, "PS2_Stone1", C3(60, 64, 68))
local ROCK = st(M.Slate, nil, C3(58, 62, 64))
local PLANK = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(92, 78, 62))
local BEAM = st(M.Wood, "PS2_DarkBeam1", C3(58, 44, 34))
local IRON = st(M.Metal, nil, C3(52, 54, 58))
local RUST = st(M.CorrodedMetal, nil, C3(120, 70, 44))
local WHITE = st(M.SmoothPlastic, nil, C3(220, 216, 204))
local RED = st(M.SmoothPlastic, nil, C3(150, 36, 30))
local ROOF = st(M.Slate, nil, C3(44, 46, 52))
local LAMP = C3(255, 210, 140)
local WATERC = C3(12, 22, 26)
-- (the building can be the Ghost Ship, x -96..124: nothing of the world there)
local function keepOut(x: number, z: number): boolean return (x > -110 and x < 140 and z > -70 and z < 66) end

---------------------------------------------------------------- the water and the land
local sea = model(W, "Sea")
water(sea, -1000, -1000, 1000, 1000, 0.1, WATERC)
local land = model(W, "Land")
-- the quay under the yard (stone edge) and along the east side
box(land, "QuayEast", 150, -6, -120, 420, 2, 120, STONE, WD())
box(land, "QuayEdge", 148, 1.4, -120, 152, 2.6, 120, STONED, WD())
-- THE TOWN'S HILL to the north: terraces of stone, each higher than the last
local terraces = { { -150, 4 }, { -205, 16 }, { -260, 30 }, { -315, 46 }, { -370, 60 } }
for i, t in terraces do
	local z0 = t[1]
	box(land, "Terrace", -700, -2, z0 - 55, 700, t[2], z0, i % 2 == 0 and STONED or STONE, WD())
end
-- rows of houses on the terraces
local town = model(W, "Town")
local HOUSECOLS = { C3(70, 84, 100), C3(110, 104, 92), C3(140, 110, 70), C3(96, 50, 46), C3(80, 90, 80), C3(150, 146, 136) }
local function house(parent, x: number, y: number, z: number, w: number, h: number, d: number, col: Color3, lit: boolean)
	local cf = CFrame.new(x, y, z)
	local wall = st(M.Plaster, nil, col)
	b(parent, cf, "House", w, h, d, 0, h / 2, 0, wall, WD())
	gableOn(parent, cf * CFrame.Angles(0, math.pi / 2, 0), d, w, h, d * 0.45, ROOF, wall, 0.8)
	local rows = math.min(2, math.max(1, math.floor((h - 4) / 6)))
	for r = 0, rows - 1 do
		for c = 0, math.min(1, math.max(0, math.floor(w / 5) - 1)) do
			local on = lit and rng:NextNumber() < 0.35
			b(parent, cf, "Window", 1.8, 2.6, 0.3, -w / 2 + 2.6 + c * 5, 4.5 + r * 6, d / 2 + 0.1, on and st(M.Neon, nil, C3(255, 190, 110)) or st(M.SmoothPlastic, nil, C3(20, 24, 28)), WD())
		end
	end
	b(parent, cf, "Chimney", 1.6, 4, 1.6, w / 2 - 2, h + d * 0.3, 0, STONED, WD())
end
for i, t in terraces do
	local zf = t[1] - 8
	local x = -400
	while x < 400 do
		local w = rng:NextNumber(10, 16)
		if not (math.abs(x) < 30 and i == #terraces) then
			house(town, x + w / 2, t[2], zf - 10, w, rng:NextNumber(14, 26), rng:NextNumber(12, 18), HOUSECOLS[rng:NextInteger(1, #HOUSECOLS)], true)
		end
		x += w + rng:NextNumber(0.5, 4)
	end
end
-- a few street lamps along the terrace edges (the lit ones)
for i, t in terraces do
	for k = 1, 7 do
		local x = -360 + k * 90 + rng:NextNumber(-20, 20)
		local lp = lampPost(town, x, t[1] - 2, LAMP, 9, IRON, 26)
		lp:PivotTo(lp:GetPivot() + Vector3.new(0, t[2], 0))
	end
end
-- THE CHURCH at the top of the town: a nave and a tall steeple with a lit clock
do
	local ch = model(W, "Church")
	local y0, z0 = terraces[#terraces][2], terraces[#terraces][1] - 30
	local cf = CFrame.new(0, y0, z0)
	local wall = st(M.Cobblestone, "PS2_Stone1", C3(120, 116, 108))
	b(ch, cf, "Nave", 24, 22, 40, 0, 11, -10, wall, WD())
	gableOn(ch, cf * CFrame.new(0, 0, -10), 24, 40, 22, 12, ROOF, wall, 1)
	b(ch, cf, "Tower", 12, 46, 12, 0, 23, 14, wall, WD())
	spire(ch, 0, z0 + 14, 8.6, y0 + 46, 40, 8, ROOF, WD())
	local clock = b(ch, cf, "Clock", 6, 6, 0.3, 0, 36, 20.2, st(M.Neon, nil, C3(255, 230, 170)), WD())
	light(clock, 30, 1, C3(255, 220, 160))
	b(ch, cf, "Hands", 0.4, 2.6, 0.2, 0, 36.6, 20.4, IRON, WD())
end

---------------------------------------------------------------- THE QUAY (east): warehouses, crane, crates, a trawler
do
	local q = model(W, "Quay")
	for i, wz in { -80, -20, 40 } do
		local cf = CFrame.new(300, 2, wz)
		local wall = st(M.WoodPlanks, "PS2_Siding1", ({ C3(70, 60, 54), C3(60, 70, 74), C3(80, 70, 60) })[i])
		b(q, cf, "Warehouse", 70, 30, 44, 0, 15, 0, wall, WD())
		gableOn(q, cf, 70, 44, 30, 14, ROOF, wall, 1.2)
		b(q, cf, "Door", 16, 18, 0.4, -10, 9, 22.2, st(M.WoodPlanks, nil, C3(40, 34, 30)), WD())
		sign(q, "WAREHOUSE " .. i, cf * CFrame.new(-10, 22, 22.4) * CFrame.Angles(0, math.pi, 0), 18, 3, st(M.WoodPlanks, nil, C3(40, 34, 30)), C3(220, 210, 180), Enum.Font.Creepster)
		light(b(q, cf, "DoorLamp", 1, 1, 1, -10, 20, 23, st(M.Neon, nil, LAMP), WD()), 22, 1, LAMP)
	end
	-- the dock crane: a lattice tower, the cab, a long arm, the hook on its cable
	local cx, cz = 190, 70
	for _, c in { { -4, -4 }, { 4, -4 }, { -4, 4 }, { 4, 4 } } do box(q, "CraneLeg", cx + c[1] - 0.6, 2, cz + c[2] - 0.6, cx + c[1] + 0.6, 62, cz + c[2] + 0.6, RUST, WD()) end
	for y = 8, 56, 8 do
		for _, s in { -4, 4 } do
			part(q, "CraneBrace", Vector3.new(0.4, 0.4, 11.5), CFrame.new(cx + s, y, cz) * CFrame.Angles((y / 8) % 2 == 0 and 0.75 or -0.75, 0, 0), RUST, WD())
			part(q, "CraneBrace", Vector3.new(11.5, 0.4, 0.4), CFrame.new(cx, y, cz + s) * CFrame.Angles(0, 0, (y / 8) % 2 == 0 and 0.75 or -0.75), RUST, WD())
		end
	end
	box(q, "CraneCab", cx - 6, 62, cz - 5, cx + 6, 70, cz + 5, st(M.SmoothPlastic, nil, C3(190, 150, 40)), WD())
	part(q, "CraneArm", Vector3.new(3, 3, 80), CFrame.new(cx - 26, 70, cz - 10) * CFrame.Angles(0, math.rad(-62), 0) * CFrame.Angles(math.rad(8), 0, 0), RUST, WD())
	local tip = (CFrame.new(cx - 26, 70, cz - 10) * CFrame.Angles(0, math.rad(-62), 0) * CFrame.Angles(math.rad(8), 0, 0) * CFrame.new(0, 0, -38)).Position
	box(q, "Cable", tip.X - 0.1, 30, tip.Z - 0.1, tip.X + 0.1, tip.Y, tip.Z + 0.1, IRON, WD())
	box(q, "Hook", tip.X - 1, 27, tip.Z - 0.3, tip.X + 1, 30, tip.Z + 0.3, IRON, WD())
	light(box(q, "CraneLamp", cx - 0.5, 70, cz + 5, cx + 0.5, 71, cz + 6, st(M.Neon, nil, C3(255, 80, 60)), WD()), 26, 1.2, C3(255, 80, 60))
	-- crates and barrels along the quay
	for k = 1, 30 do
		local x, z = rng:NextNumber(160, 260), rng:NextNumber(-110, 110)
		if not keepOut(x, z) then
			local s = rng:NextNumber(3, 5)
			local c = box(q, "Crate", x - s / 2, 2, z - s / 2, x + s / 2, 2 + s, z + s / 2, st(M.WoodPlanks, nil, C3(110, 88, 60)), WD())
			c.CFrame = c.CFrame * CFrame.Angles(0, rng:NextNumber(0, 1), 0)
			if rng:NextNumber() < 0.4 then cyl(q, CFrame.new(x + 4, 4, z + 2), "Barrel", 2.8, 4, 0, 0, 0, rng:NextNumber() < 0.5 and RUST or BEAM, WD()) end
		end
	end
	-- the rusty trawler alongside the quay (south end)
	local cf = CFrame.new(140, 0, 190) * CFrame.Angles(0, math.pi / 2, 0)
	local hull = st(M.CorrodedMetal, nil, C3(70, 40, 34))
	b(q, cf, "Hull", 18, 9, 66, 0, 3, 0, hull, WD())
	b(q, cf * CFrame.new(0, 3, -36) * CFrame.Angles(0, math.pi / 4, 0), "Bow", 12.7, 9, 12.7, 0, 0, 0, hull, WD())
	b(q, cf, "Deck", 17, 0.6, 64, 0, 7.8, 0, PLANK, WD())
	b(q, cf, "Wheelhouse", 12, 9, 12, 0, 12.4, 14, WHITE, WD())
	b(q, cf, "WheelhouseRoof", 13, 0.6, 13, 0, 17.2, 14, RED, WD())
	for k = 0, 2 do b(q, cf, "WhWindow", 2.4, 2.2, 0.3, -4 + k * 4, 13.6, 7.9, st(M.Neon, nil, C3(200, 230, 210)), WD()) end
	b(q, cf, "Mast", 0.8, 26, 0.8, 0, 20, -10, IRON, WD())
	b(q, cf, "Boom", 0.5, 0.5, 20, 0, 12, -18, IRON, WD())
	b(q, cf, "Stack", 3, 8, 3, 0, 20, 20, st(M.SmoothPlastic, nil, C3(30, 30, 30)), WD())
	light(b(q, cf, "MastLight", 0.8, 0.8, 0.8, 0, 33, -10, st(M.Neon, nil, C3(120, 255, 120)), WD()), 24, 1, C3(120, 255, 120))
end

---------------------------------------------------------------- THE BREAKWATER (west) and the harbor light
do
	local bw = model(W, "Breakwater")
	local a, z = Vector3.new(-160, 0, 40), Vector3.new(-420, 0, 300)
	local n = 22
	for k = 0, n do
		local p = a:Lerp(z, k / n)
		local cf = CFrame.lookAt(p, z)
		b(bw, cf, "Wall", 16, 5, 13, 0, 1.5, 0, STONE, WD())
		for _ = 1, 2 do
			local s = rng:NextNumber(3, 6)
			local r = box(bw, "Rock", 0, 0, 0, 1, 1, 1, ROCK, WD())
			r.Size = Vector3.new(s, s * 0.7, s)
			r.CFrame = cf * CFrame.new(rng:NextNumber(-10, 10), 0.4, rng:NextNumber(-6, 6)) * CFrame.Angles(rng:NextNumber(-0.4, 0.4), rng:NextNumber(0, 3), rng:NextNumber(-0.4, 0.4))
		end
	end
	-- the light at its end: red and white rings, a gallery, a lamp
	local lx, lz = z.X, z.Z
	for k = 0, 5 do cyl(bw, CFrame.new(lx, 6 + k * 5, lz), "Ring", 8 - k * 0.4, 5, 0, 0, 0, k % 2 == 0 and WHITE or RED, WD()) end
	cyl(bw, CFrame.new(lx, 34, lz), "Gallery", 9, 0.8, 0, 0, 0, IRON, WD())
	local lamp = ball(bw, CFrame.new(lx, 37, lz), "Lamp", 3, 0, 0, 0, st(M.Neon, nil, C3(255, 70, 50)), WD())
	light(lamp, 70, 2, C3(255, 80, 60))
	cyl(bw, CFrame.new(lx, 40, lz), "Cap", 5, 2, 0, 0, 0, RED, WD())
end

---------------------------------------------------------------- the sea (south): boats at anchor, buoys, a wreck
do
	local s = model(W, "Anchorage")
	for i, p in { { -150, 260, 0.4 }, { 60, 300, -0.2 }, { 220, 330, 1.2 }, { -300, 380, 2.1 }, { 380, 260, 0.8 } } do
		local cf = CFrame.new(p[1], 0.4, p[2]) * CFrame.Angles(0, p[3], 0.05)
		local col = ({ C3(60, 70, 80), C3(110, 40, 34), C3(40, 70, 60), C3(150, 140, 120), C3(50, 50, 70) })[i]
		b(s, cf, "Hull", 9, 3, 24, 0, 0.6, 0, st(M.WoodPlanks, "PS2_Siding1", col), WD())
		b(s, cf * CFrame.new(0, 0.6, -12) * CFrame.Angles(0, math.pi / 4, 0), "Bow", 6.4, 3, 6.4, 0, 0, 0, st(M.WoodPlanks, "PS2_Siding1", col), WD())
		b(s, cf, "Cabin", 5, 4, 6, 0, 4, 4, WHITE, WD())
		b(s, cf, "Mast", 0.5, 16, 0.5, 0, 9, -4, BEAM, WD())
		if i % 2 == 1 then light(b(s, cf, "AnchorLight", 0.6, 0.6, 0.6, 0, 17, -4, st(M.Neon, nil, LAMP), WD()), 20, 0.9, LAMP) end
	end
	for _, p in { { -60, 220 }, { 90, 240 }, { 300, 180 }, { -240, 200 }, { 0, 420 } } do
		cyl(s, CFrame.new(p[1], 1.2, p[2]), "Buoy", 3, 2.4, 0, 0, 0, RED, WD())
		box(s, "BuoyCage", p[1] - 0.8, 2.4, p[2] - 0.8, p[1] + 0.8, 5, p[2] + 0.8, IRON, WD())
		light(ball(s, CFrame.new(p[1], 5.6, p[2]), "BuoyLight", 1, 0, 0, 0, st(M.Neon, nil, C3(120, 255, 120)), WD()), 18, 1, C3(120, 255, 120))
	end
	-- the wreck: a mast and a yard leaning out of the water
	part(s, "WreckMast", Vector3.new(1.4, 40, 1.4), CFrame.new(-90, 12, 340) * CFrame.Angles(0.3, 0, 0.25), BEAM, WD())
	part(s, "WreckYard", Vector3.new(18, 0.8, 0.8), CFrame.new(-86, 26, 344) * CFrame.Angles(0.3, 0.4, 0.5), BEAM, WD())
	part(s, "WreckSail", Vector3.new(10, 8, 0.2), CFrame.new(-86, 22, 344) * CFrame.Angles(0.3, 0.4, 0.5), st(M.Fabric, nil, C3(110, 104, 92)), WD())
	-- the railway's trestle over the water
	for x = -258, 258, 12 do
		if math.abs(x) > 100 then for _, dz in { -3, 3 } do box(s, "TrestlePost", x - 0.6, -4, 150 + dz - 0.6, x + 0.6, 0.6, 150 + dz + 0.6, BEAM, WD()) end end
	end
end

---------------------------------------------------------------- the yard: the arch, bollards and chains, gulls
local yd = model(W, "HarborYard")
for _, x in { -8, 8 } do box(yd, "ArchPost", x - 1, 0, 130.5, x + 1, 15, 132.5, BEAM, WD()) end
box(yd, "ArchBoard", -9.5, 12.6, 131, 9.5, 15.4, 132, st(M.WoodPlanks, "PS2_FloorPlanks2", C3(62, 52, 44)), WD())
sign(yd, "BLACKWATER HARBOR", CFrame.new(0, 14, 130.9) * CFrame.Angles(0, math.pi, 0), 17, 2, st(M.WoodPlanks, nil, C3(62, 52, 44)), C3(230, 215, 170), Enum.Font.Creepster).Name = "HarbSign"
sign(yd, "BLACKWATER HARBOR", CFrame.new(0, 14, 132.1), 17, 2, st(M.WoodPlanks, nil, C3(62, 52, 44)), C3(230, 215, 170), Enum.Font.Creepster).Name = "HarbSignBack"
for _, x in { -8, 8 } do light(ball(yd, CFrame.new(x, 16.2, 131.5), "ArchLamp", 1.2, 0, 0, 0, st(M.Neon, nil, LAMP), WD()), 30, 1.2, LAMP) end
local fence = model(W, "Bollards")
yardEdge(fence, function(parent, x1, z1, x2, z2, gap)
	local a, z = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	local len = (z - a).Magnitude
	local n = math.max(1, math.floor(len / 8))
	local prev = nil
	for i = 0, n do
		local p = a:Lerp(z, i / n)
		if gap and gap(p.X, p.Z) then prev = nil; continue end
		cyl(parent, CFrame.new(p.X, 1.6, p.Z), "Bollard", 1.8, 3.2, 0, 0, 0, IRON, WD())
		ball(parent, CFrame.new(p.X, 3.3, p.Z), "BollardCap", 2.1, 0, 0, 0, IRON, WD())
		if prev then
			for k = 1, 4 do
				local t1, t2 = (k - 1) / 4, k / 4
				local q1 = prev:Lerp(p, t1) + Vector3.new(0, 2.6 - math.sin(t1 * math.pi) * 1.1, 0)
				local q2 = prev:Lerp(p, t2) + Vector3.new(0, 2.6 - math.sin(t2 * math.pi) * 1.1, 0)
				part(parent, "Chain", Vector3.new(0.3, 0.3, (q2 - q1).Magnitude), CFrame.lookAt((q1 + q2) / 2, q2), RUST, WD())
			end
		end
		prev = p
	end
end)
-- gulls standing on posts round the harbor
for _, p in { { -100, 60 }, { 110, 100 }, { 160, 10 }, { -130, 120 } } do
	box(yd, "GullPost", p[1] - 0.5, 0, p[2] - 0.5, p[1] + 0.5, 6, p[2] + 0.5, BEAM, WD())
	local cf = CFrame.new(p[1], 6.6, p[2]) * CFrame.Angles(0, rng:NextNumber(0, 6), 0)
	b(yd, cf, "Gull", 0.9, 0.9, 2, 0, 0, 0, WHITE, WD())
	b(yd, cf, "GullHead", 0.6, 0.6, 0.6, 0, 0.6, -0.9, WHITE, WD())
	b(yd, cf, "GullWing", 1, 0.2, 1.4, 0, 0.3, 0.2, st(M.SmoothPlastic, nil, C3(120, 124, 128)), WD())
	b(yd, cf, "GullBeak", 0.2, 0.2, 0.6, 0, 0.55, -1.4, st(M.SmoothPlastic, nil, C3(220, 170, 40)), WD())
end
return endWorld()
