-- BLACKWATER HARBOR: what its five buildings share (Shared/Campaign map 3: one building per train trip). Prepend
-- after lib2 + furn_lib + maplib, then one maps/harb_<building>.luau:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_market.luau
-- Every building is a map on the Mansion's footprint. Outside: the harbor at night - a wooden PIER from the porch to
-- the railway (the train stops at z = 150, the party gets off at z = 141) over black water on both sides, boats
-- moored along it, mooring posts and ropes, fish crates, lamp posts, the BLACKWATER HARBOR arch, and far off to the
-- west a striped LIGHTHOUSE with its lamp. On the building: a sign board with two lanterns over the porch.
-- Then furnish (ONLY = the map) and doors_clear like every map, and maps/harb_items.luau (item spots, secret rooms).
local C3h = Color3.fromRGB
local function Dh() return { deco = true } end -- (a fresh table each time: cyl / ball write the shape into it)
local HARB = {
	siding = st(M.WoodPlanks, "PS2_Siding1", C3h(70, 84, 92)),
	sidingD = st(M.WoodPlanks, "PS2_Siding1", C3h(48, 56, 62)),
	plank = st(M.WoodPlanks, "PS2_FloorPlanks2", C3h(92, 78, 62)),
	plankD = st(M.WoodPlanks, "PS2_FloorPlanks2", C3h(62, 52, 44)),
	beam = st(M.Wood, "PS2_DarkBeam1", C3h(58, 44, 34)),
	rope = st(M.Fabric, nil, C3h(170, 150, 104)),
	iron = st(M.Metal, nil, C3h(52, 54, 58)),
	rust = st(M.CorrodedMetal, nil, C3h(120, 70, 44)),
	stone = st(M.Cobblestone, "PS2_Stone1", C3h(84, 88, 92)),
	tile = st(M.SmoothPlastic, nil, C3h(118, 128, 126)), -- (darker: the brightened maps turned white tiles to glare)
	tileD = st(M.SmoothPlastic, nil, C3h(78, 94, 94)),
	water = st(M.Glass, nil, C3h(14, 30, 36)),
	ice = st(M.Ice, nil, C3h(190, 220, 230)),
	lamp = st(M.Neon, nil, C3h(255, 210, 140)),
	red = st(M.SmoothPlastic, nil, C3h(150, 36, 30)),
	white = st(M.SmoothPlastic, nil, C3h(220, 216, 204)),
	yellow = st(M.SmoothPlastic, nil, C3h(200, 160, 50)),
	navy = st(M.SmoothPlastic, nil, C3h(30, 40, 64)),
	canvas = st(M.Fabric, nil, C3h(150, 140, 116)),
	black = st(M.SmoothPlastic, nil, C3h(16, 16, 18)),
	weed = st(M.Grass, nil, C3h(40, 80, 40)),
}
local function harbTheme(over: { [string]: any }?)
	local t = {
		floor = HARB.plank, floor2 = HARB.plank, inner = st(M.WoodPlanks, "PS2_Siding1", C3h(96, 104, 100)), wainscot = HARB.beam, wain = true,
		ext = HARB.siding, trim = HARB.beam, ceiling = HARB.beam, roof = st(M.Slate, nil, C3h(44, 48, 52)), found = HARB.stone,
		door = st(M.WoodPlanks, "PS2_Siding1", C3h(54, 70, 80)), porch = HARB.plankD,
		lanternColor = C3h(255, 210, 140), floodColor = C3h(190, 210, 230),
	}
	for k, v in over or {} do t[k] = v end
	return t
end

-- a ship's lantern on a hook (deco): iron cage, warm glow, a light
local function harbLantern(parent: Instance, p: Vector3, range: number?)
	local m = model(parent, "Lantern")
	box(m, "Cage", p.X - 0.5, p.Y - 0.7, p.Z - 0.5, p.X + 0.5, p.Y + 0.7, p.Z + 0.5, HARB.iron, { deco = true, t = 0.4 })
	box(m, "Cap", p.X - 0.6, p.Y + 0.7, p.Z - 0.6, p.X + 0.6, p.Y + 0.95, p.Z + 0.6, HARB.iron, DECO)
	local g = box(m, "Glow", p.X - 0.3, p.Y - 0.45, p.Z - 0.3, p.X + 0.3, p.Y + 0.45, p.Z + 0.3, HARB.lamp, DECO)
	light(g, range or 22, 1.2, C3h(255, 196, 130))
	return m
end
-- a fish crate on the floor (deco): slats, ice and a few fish
local function harbFishCrate(parent: Instance, cf: CFrame, rng: Random)
	local m = model(parent, "FishCrate")
	b(m, cf, "Crate", 3.4, 1.2, 2.2, 0, 0.6, 0, HARB.plank, DECO)
	b(m, cf, "Ice", 3.0, 0.2, 1.8, 0, 1.2, 0, HARB.ice, DECO)
	for k = 0, 2 do
		local col = ({ C3h(140, 150, 160), C3h(170, 130, 110), C3h(110, 130, 120) })[k + 1]
		b(m, cf * CFrame.Angles(0, rng:NextNumber(-0.4, 0.4), 0), "Fish", 2.2, 0.35, 0.6, rng:NextNumber(-0.4, 0.4), 1.45, -0.5 + k * 0.5, st(M.SmoothPlastic, nil, col), DECO)
	end
	return m
end
-- a coil of rope on the floor (deco)
local function harbCoil(parent: Instance, p: Vector3)
	for k = 0, 2 do cyl(parent, CFrame.new(p.X, p.Y + 0.2 + k * 0.3, p.Z), "Coil", 2.4 - k * 0.3, 0.3, 0, 0, 0, HARB.rope, Dh()) end
end
-- a sagging rope between two points (deco)
local function harbRope(parent: Instance, a: Vector3, z: Vector3, sag: number)
	local n = 8
	local last = a
	for i = 1, n do
		local u = i / n
		local p = a:Lerp(z, u) - Vector3.new(0, math.sin(u * math.pi) * sag, 0)
		local mid = (last + p) / 2
		part(parent, "Rope", Vector3.new(0.18, 0.18, (p - last).Magnitude + 0.1), CFrame.lookAt(mid, p), HARB.rope, DECO)
		last = p
	end
end

-- the building's name on a weathered board over the porch roof, a lantern each side
local function harbSign(text: string, at: CFrame?)
	local m = model(DEC, "Marquee")
	local cf = (at or CFrame.new(0, 21, 61)) * CFrame.Angles(0, math.pi, 0)
	b(m, cf, "Board", 26, 5, 0.5, 0, 0, 0.3, HARB.plankD, DECO)
	b(m, cf, "Frame", 27, 5.8, 0.3, 0, 0, 0.55, HARB.beam, DECO)
	sign(m, text, cf * CFrame.new(0, 0, -0.05), 23, 3.4, HARB.plankD, C3h(235, 220, 180), Enum.Font.Creepster)
	for _, x in { -14.5, 14.5 } do harbLantern(m, (cf * CFrame.new(x, -1.8, -0.8)).Position, 26) end
	if not at then for _, x in { -12, 12 } do box(m, "Peg", x - 0.25, 17.4, 60.6, x + 0.25, 24.5, 61.2, HARB.beam, DECO) end end
	return m
end

-- the harbor in the yard (everything decoration: no collision, never hit by a ray)
local function harbGrounds()
	local yd = model(DEC, "Harbor")
	local rng = Random.new(77)
	-- THE PIER from the porch to the railway: boards on posts, a rail of rope along each side
	box(yd, "Pier", -7, 0.1, 64, 7, 0.6, 146, HARB.plank, DECO) -- (deco: the yard ground carries the players)
	for z = 66, 144, 6 do
		for _, x in { -7.4, 7.4 } do
			cyl(yd, CFrame.new(x, 1.4, z), "PierPost", 0.9, 3.2, 0, 0, 0, HARB.beam, Dh())
			if z < 144 then harbRope(yd, Vector3.new(x, 2.8, z), Vector3.new(x, 2.8, z + 6), 0.6) end
		end
	end
	-- the black water on both sides (a dark glassy sheet a little under the pier)
	box(yd, "Water", -160, 0.02, 62, -7.5, 0.12, 200, HARB.water, { deco = true, t = 0.05 })
	box(yd, "Water", 7.5, 0.02, 62, 160, 0.12, 200, HARB.water, { deco = true, t = 0.05 })
	-- (no reflection: it mirrored the bright skybox as a pale glare at night)
	-- boats moored along the pier: a hull, a cabin, a mast
	for _, p in { { -22, 84, 0.1 }, { 24, 104, -0.15 }, { -26, 124, 0.25 }, { 30, 136, 0.05 } } do
		local bm = model(yd, "Boat")
		local cf = CFrame.new(p[1], 0.6, p[2]) * CFrame.Angles(0, p[3], 0.04)
		b(bm, cf, "Hull", 9, 2.4, 22, 0, 0.4, 0, HARB.sidingD, DECO)
		b(bm, cf, "Keel", 7, 1.2, 18, 0, -0.9, 0, HARB.black, DECO)
		b(bm, cf * CFrame.new(0, 0.5, -11) * CFrame.Angles(0, math.pi / 4, 0), "Bow", 6.2, 2.2, 6.2, 0, 0, 0, HARB.sidingD, DECO)
		b(bm, cf, "Rail", 9.2, 0.4, 22.2, 0, 1.8, 0, HARB.white, DECO)
		b(bm, cf, "Cabin", 5, 3.6, 6, 0, 3.4, 3, HARB.white, DECO)
		b(bm, cf, "CabinRoof", 5.6, 0.4, 6.6, 0, 5.4, 3, HARB.red, DECO)
		b(bm, cf, "Mast", 0.5, 13, 0.5, 0, 8, -3, HARB.beam, DECO)
		local lg = b(bm, cf, "CabinLight", 0.6, 0.6, 0.6, 1.8, 4, -0.1, HARB.lamp, DECO)
		light(lg, 14, 0.8, C3h(255, 200, 140))
		harbRope(yd, (cf * CFrame.new(p[1] < 0 and 4.6 or -4.6, 2, -6)).Position, Vector3.new(p[1] < 0 and -7.4 or 7.4, 2.8, p[2] - 6), 1)
	end
	-- crates, barrels and fish boxes stacked at the pier's foot, nets drying on a rack
	for _, p in { { -11, 70 }, { -14, 74 }, { 12, 72 }, { 14, 68 } } do
		harbFishCrate(yd, CFrame.new(p[1], 0.1, p[2]) * CFrame.Angles(0, rng:NextNumber(-0.5, 0.5), 0), rng)
	end
	for _, p in { { -12, 78 }, { 13, 78 } } do
		cyl(yd, CFrame.new(p[1], 2, p[2]) * CFrame.Angles(0, 0, math.pi / 2), "Barrel", 2.8, 3.8, 0, 0, 0, HARB.plankD, Dh())
	end
	local rack = model(yd, "NetRack")
	for _, x in { 18, 30 } do box(rack, "Post", x - 0.3, 0, 86.7, x + 0.3, 8, 87.3, HARB.beam, DECO) end
	box(rack, "Bar", 18, 7.6, 86.8, 30, 8, 87.2, HARB.beam, DECO)
	for x = 18.5, 29.5, 1 do box(rack, "NetV", x - 0.05, 2, 86.95, x + 0.05, 7.6, 87.05, HARB.rope, DECO) end
	for y = 2.5, 7.5, 1 do box(rack, "NetH", 18, y - 0.05, 86.95, 30, y + 0.05, 87.05, HARB.rope, DECO) end
	-- lamp posts along the pier
	for _, z in { 80, 100, 120, 140 } do
		for _, x in { -8.6, 8.6 } do
			cyl(yd, CFrame.new(x, 4, z), "LampPost", 0.4, 8, 0, 0, 0, HARB.iron, Dh())
			harbLantern(yd, Vector3.new(x, 8.6, z), 26)
		end
	end
	-- (2026-11-19: the arch and the lighthouse on its rocks are in the Harbor WORLD now: tools/build/worlds/harbor.luau)
	-- rocks and seaweed along the water's edge by the building
	for _, x in { -60, -40, 40, 60 } do
		ball(yd, CFrame.new(x + rng:NextNumber(-4, 4), 0.4, 66 + rng:NextNumber(0, 4)), "ShoreRock", 4 + rng:NextNumber(0, 3), 0, 0, 0, HARB.stone, Dh())
		box(yd, "Weed", x - 2, 0.12, 66, x + 2, 0.3, 70, HARB.weed, DECO)
	end
end
