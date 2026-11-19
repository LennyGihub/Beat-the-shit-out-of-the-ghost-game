-- THE GHOST SHIP (Blackwater Harbor, building 5: THE PIRATE, then THE PIRATE KING). (2026-11-19: rebuilt as a real
-- ship.) The captain's ship lies along the quay, broadside to the pier: a black hull with a gold stripe, its pointed
-- bow to the east (bowsprit, a gold figurehead), its rounded stern to the west under the raised stern castle. You
-- board up the gangplank through a door in its side. Inside, the GUN DECK: dark planks between ribs, three MASTS
-- through the deck (cover), CANNONS along both sides at their ports, kegs, the crew's mess table, hammocks. At the
-- stern, behind a wall with a door: THE CAPTAIN'S CABIN - his desk, his charts, his chest; his chart cabinet slides
-- away (Secrets: the treasure hold; its item = the map's attribute SecretSpot). Above: the weather deck with its
-- rails, three masts with yards and torn sails, the rigging, a crow's nest, the black flag.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--   tools/build/maps/harbor_lib.luau tools/build/maps/harb_ship.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 24
local rng = Random.new(55)
local HULL = st(M.WoodPlanks, "PS2_Siding1", C3(40, 34, 30))
local DECK = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(70, 56, 44))
local GOLD = st(M.Metal, nil, C3(190, 150, 60))
local SAIL = st(M.Fabric, nil, C3(176, 168, 150))
local GREEN = C3(120, 255, 150)
beginMap("Harb_Ship", harbTheme({ ext = HULL, inner = st(M.WoodPlanks, "PS2_Siding1", C3(66, 52, 42)), floor = DECK, floor2 = DECK, trim = GOLD, found = HULL }))
-- the hull in plan: the side to the pier (edge 1, the boarding door), the stern round to the west, the bow to the east
local PTS = {
	{ 50, 50 }, { -50, 50 },
	{ -80, 46 }, { -96, 32 }, { -98, 0 }, { -96, -32 }, { -80, -46 },
	{ -50, -50 }, { 50, -50 },
	{ 84, -40 }, { 108, -20 }, { 122, 0 }, { 108, 20 }, { 84, 40 },
}
local TOP = shell2({ poly = PTS, H = H, roof = "flat", roofStyle = DECK, door = { w = 9, t = 14, kind = "open" }, postStyle = HULL, postW = 2.2, stepStyle = DECK })
local inn = model(STR, "Interior")
local I = INT()
-- the cabin wall at the stern (x -64), a door in its middle
wallL(inn, "CabinWall", -64, -48, -64, 48, F1, H, { { c = 48, w = 10, b = 0, t = 13, kind = "open" } }, I)

-- the ribs along both straight sides, deck beams across, the masts through the deck (cover)
for x = -50, 50, 10 do
	for _, sz in { -1, 1 } do box(DEC, "Rib", x - 0.8, F1, sz * 48.6 - 0.9, x + 0.8, F1 + H - 2, sz * 48.6 + 0.9, HARB.beam, DECO) end
end
for x = -56, 100, 12 do
	local hz = 49
	if x > 50 then hz = 49 - (x - 50) * 0.42 end
	box(DEC, "DeckBeam", x - 0.8, F1 + H - 3, -hz, x + 0.8, F1 + H - 1.8, hz, HARB.beam, DECO)
end
local MASTS = { { 70, 54 }, { 10, 72 }, { -44, 50 } } -- x, height over the deck
for _, m in MASTS do
	cyl(STR, CFrame.new(m[1], F1 + H / 2, 0), "Mast", 4, H, 0, 0, 0, HARB.beam)
	cyl(DEC, CFrame.new(m[1], F1 + 1, 0), "MastFoot", 6, 2, 0, 0, 0, GOLD, D())
	for k = 0, 6 do box(DEC, "Ratline", m[1] + 2.1, F1 + 2 + k * 2, -2.6, m[1] + 2.3, F1 + 2.2 + k * 2, 2.6, HARB.rope, DECO) end
end
-- THE CANNONS along both sides, on carriages, pointing out of their ports
local guns = model(STR, "Cannons")
local function cannon(x: number, sz: number)
	local zc = sz * 40
	box(guns, "Carriage", x - 2, F1, zc - 3, x + 2, F1 + 2.4, zc + 3, HARB.plankD)
	cyl(DEC, CFrame.new(x, F1 + 3.4, zc + sz * 1.2) * CFrame.Angles(math.pi / 2, 0, 0), "Barrel", 1.8, 7, 0, 0, 0, HARB.iron, D())
	for _, dx in { -2.1, 2.1 } do cyl(DEC, CFrame.new(x + dx, F1 + 1, zc - sz * 1.6) * CFrame.Angles(0, 0, -math.pi / 2), "Wheel", 2, 0.4, 0, 0, 0, HARB.beam, D()) end
	box(DEC, "Port", x - 1.8, F1 + 2.5, sz * 49 - 0.25, x + 1.8, F1 + 5.5, sz * 49 + 0.25, HARB.black, DECO)
	for k = 0, 2 do ball(DEC, CFrame.new(x - 1 + k, F1 + 0.6, zc - sz * 4), "Shot", 1.1, 0, 0, 0, HARB.iron, D()) end
	-- outside: the port lid propped open and the muzzle out of it
	box(DEC, "PortOut", x - 2, F1 + 2.3, sz * 50.2 - 0.2, x + 2, F1 + 5.7, sz * 50.2 + 0.2, HARB.black, DECO)
	part(DEC, "PortLid", Vector3.new(4.2, 0.4, 3.2), CFrame.new(x, F1 + 6.6, sz * 51.4) * CFrame.Angles(sz * 0.7, 0, 0), HARB.plankD, D())
	cyl(DEC, CFrame.new(x, F1 + 4, sz * 51.4) * CFrame.Angles(math.pi / 2, 0, 0), "Muzzle", 1.6, 2.6, 0, 0, 0, HARB.iron, D())
end
for _, x in { -40, -24, 24, 40 } do cannon(x, 1) end
for _, x in { -40, -24, -8, 8, 24, 40 } do cannon(x, -1) end
-- barrels and powder kegs, the crew's mess table and benches
for _, p in { { 58, 28 }, { 58, -28 }, { -24, 28 }, { 28, -26 }, { -52, -28 }, { 92, 8 } } do
	for k = 0, 2 do cyl(STR, CFrame.new(p[1] + (k - 1) * 3.2, F1 + 2, p[2]), "Keg", 2.8, 4, 0, 0, 0, k == 1 and HARB.red or HARB.plankD) end
end
box(STR, "MessTable", -34, F1, -14, -16, F1 + 3.2, -6, HARB.plank)
for _, z in { -15.6, -4.4 } do box(DEC, "MessBench", -34, F1 + 1.6, z - 0.8, -16, F1 + 2, z + 0.8, HARB.plankD, DECO) end
box(DEC, "Tankard", -28, F1 + 3.2, -11, -27, F1 + 4.4, -10, HARB.iron, DECO)
box(DEC, "Bread", -22, F1 + 3.2, -10, -20, F1 + 3.8, -9, st(M.SmoothPlastic, nil, C3(170, 120, 70)), DECO)
-- hammocks under the beams
for _, p in { { 40, 20 }, { 40, -12 }, { -20, 16 }, { 86, 0 } } do
	for i = 0, 6 do
		local u = i / 6
		box(DEC, "Hammock", p[1] - 5 + u * 10 - 0.75, F1 + 10 - math.sin(u * math.pi) * 1.6, p[2] - 1.4, p[1] - 5 + u * 10 + 0.75, F1 + 10.2 - math.sin(u * math.pi) * 1.6, p[2] + 1.4, HARB.canvas, DECO)
	end
	for _, dx in { -5.5, 5.5 } do box(DEC, "HammockRope", p[1] + dx - 0.05, F1 + 10, p[2] - 0.05, p[1] + dx + 0.05, F1 + H - 3, p[2] + 0.05, HARB.rope, DECO) end
end

-- THE CAPTAIN'S CABIN (x -98..-64): desk, charts, chest, lantern
box(STR, "Desk", -86, F1, -8, -80, F1 + 3.6, 8, st(M.Wood, nil, C3(90, 50, 30)))
box(DEC, "Chart", -85, F1 + 3.6, -6, -81, F1 + 3.7, 4, st(M.SmoothPlastic, nil, C3(200, 180, 130)), DECO)
box(DEC, "Quill", -84, F1 + 3.6, 5, -83.7, F1 + 4.8, 5.3, HARB.white, DECO)
box(STR, "Chest", -90, F1, -30, -84, F1 + 4, -22, st(M.Wood, nil, C3(90, 50, 30)))
box(DEC, "ChestBand", -90.2, F1 + 1, -30.2, -83.8, F1 + 1.6, -21.8, GOLD, DECO)
box(DEC, "ChestLid", -90.2, F1 + 4, -30.2, -83.8, F1 + 4.8, -21.8, st(M.Wood, nil, C3(80, 44, 26)), DECO)
harbLantern(DEC, Vector3.new(-80, F1 + 10, 0), 26)
-- the chart cabinet (Secrets): slides aside to the treasure hold (x -84..-70, z 24..38)
local sr = model(STR, "Hold")
box(sr, "Wall", -84, F1, 37.4, -70, F1 + 12, 38.6, HARB.sidingD)
box(sr, "Wall", -84.6, F1, 24, -83.4, F1 + 12, 38.6, HARB.sidingD)
box(sr, "Wall", -70.6, F1, 24, -69.4, F1 + 12, 38.6, HARB.sidingD)
box(sr, "Wall", -84, F1, 23.4, -80, F1 + 12, 24.6, HARB.sidingD)
box(sr, "Wall", -74, F1, 23.4, -70, F1 + 12, 24.6, HARB.sidingD)
box(sr, "Lintel", -80, F1 + 9, 23.4, -74, F1 + 12, 24.6, HARB.sidingD)
box(sr, "Ceiling", -84.6, F1 + 12, 23.4, -69.4, F1 + 12.6, 38.6, HARB.beam)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "ChartCabinet")
door:SetAttribute("Slide", Vector3.new(6.2, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "The captain's chart cabinet")
box(door, "Panel", -80, F1, 22.6, -74, F1 + 9, 24.6, st(M.Wood, nil, C3(90, 50, 30)))
for r = 0, 3 do box(door, "Panel", -79.6, F1 + 1 + r * 2, 22.3, -74.4, F1 + 1.3 + r * 2, 22.6, GOLD, DECO) end
box(door, "Trigger", -77.5, F1 + 4, 20.8, -76.5, F1 + 5, 21.8, HARB.plank, { deco = true, t = 1 })
for k = 0, 5 do cyl(DEC, CFrame.new(-77 + k * 0.6, F1 + 0.08, 21 - k * 1.5), "TrailCoin", 0.7, 0.1, 0, 0, 0, GOLD, D()) end
local loot = model(DEC, "Treasure")
for _ = 0, 30 do cyl(loot, CFrame.new(rng:NextNumber(-82, -72), F1 + 0.1 + rng:NextNumber(0, 1), rng:NextNumber(30, 37)), "Coin", 0.9, 0.14, 0, 0, 0, GOLD, D()) end
box(loot, "CoinPile", -82, F1, 32, -74, F1 + 1.6, 37, GOLD, DECO)
local sg = b(loot, CFrame.new(-77, F1 + 10, 31), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, HARB.lamp, { deco = true, t = 1 })
light(sg, 18, 1.2, C3(255, 210, 110))
MAP:SetAttribute("SecretSpot", Vector3.new(-77, F1, 30))

-- lights: lanterns on the masts and beams
for _, p in { { 67.6, 0 }, { 7.6, 0 }, { -30, 30 }, { 30, 30 }, { -30, -30 }, { 30, -30 }, { 90, 0 } } do harbLantern(DEC, Vector3.new(p[1], F1 + 12, p[2]), 28) end
for _, p in { { -20, 30 }, { 40, 0 }, { -80, -10 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -30, 30 }, { 30, 30 }, { -30, -30 }, { 30, -30 }, { 80, 0 }, { -80, 10 }, { 50, 0 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 34, 6, 50, F1)
keepClear(-70, -6, -58, 6, F1) -- (the cabin door)
keepClear(-80, 14, -74, 22, F1) -- (in front of the chart cabinet)

-- OUTSIDE: the hull's gold stripe, the gangplank, the weather deck (rails, the stern castle, the forecastle), three
-- masts with yards and torn sails, rigging, the crow's nest and the black flag, the bowsprit and the figurehead
local OUT = model(DEC, "Outside")
for i, p in PTS do
	local q = PTS[i % #PTS + 1]
	local a, z = Vector3.new(p[1], F1 + 15, p[2]), Vector3.new(q[1], F1 + 15, q[2])
	local c = Vector3.new((a.X + z.X) / 2, 0, (a.Z + z.Z) / 2)
	local outv = (c - centroid(PTS)).Unit * 1.15
	part(OUT, "GoldStripe", Vector3.new(0.3, 1.2, (z - a).Magnitude + 0.6), CFrame.lookAt((a + z) / 2 + outv, z + outv), GOLD, D())
	part(OUT, "Wale", Vector3.new(0.6, 0.8, (z - a).Magnitude + 0.6), CFrame.lookAt((a + z) / 2 + outv * 1.2 - Vector3.new(0, 9, 0), z + outv * 1.2 - Vector3.new(0, 9, 0)), HARB.beam, D())
	-- the rail round the weather deck
	local ra, rz = Vector3.new(p[1], TOP + 4, p[2]), Vector3.new(q[1], TOP + 4, q[2])
	part(OUT, "DeckRail", Vector3.new(0.6, 0.6, (rz - ra).Magnitude + 0.4), CFrame.lookAt((ra + rz) / 2, rz), HARB.beam, D())
	part(OUT, "Bulwark", Vector3.new(0.5, 3, (rz - ra).Magnitude + 0.4), CFrame.lookAt((ra + rz) / 2 - Vector3.new(0, 2.2, 0), rz - Vector3.new(0, 2.2, 0)), HULL, D())
end
-- the gangplank from the pier up to the door, rope rails
part(OUT, "Gangplank", Vector3.new(7, 0.5, 16), CFrame.new(0, 1.3, 60) * CFrame.Angles(-0.05, 0, 0), DECK, D())
for _, x in { -3.6, 3.6 } do
	for _, z in { 54, 66 } do box(OUT, "PlankPost", x - 0.2, 0, z - 0.2, x + 0.2, 5, z + 0.2, HARB.beam, DECO) end
	box(OUT, "PlankRope", x - 0.08, 4.4, 54, x + 0.08, 4.6, 66, HARB.rope, DECO)
end
-- THE STERN CASTLE: a raised cabin on the deck at the stern, windows lit, a big lantern
local SC = model(OUT, "SternCastle")
box(SC, "Castle", -93, TOP + 1.2, -31, -66, TOP + 13, 31, HULL, DECO)
box(SC, "CastleTop", -94, TOP + 13, -32, -65, TOP + 14, 32, DECK, DECO)
for z = -28, 28, 8 do box(SC, "CastleWindow", -65.8, TOP + 5, z - 1.6, -65.4, TOP + 9, z + 1.6, st(M.Neon, nil, C3(255, 190, 110)), DECO) end
for z = -24, 24, 12 do box(SC, "SternWindow", -98.6, TOP - 10, z - 2, -98.2, TOP - 4, z + 2, st(M.Neon, nil, C3(255, 190, 110)), DECO) end
light(box(SC, "SternGlow", -101, TOP - 7, -0.1, -100.8, TOP - 6.8, 0.1, HARB.lamp, { deco = true, t = 1 }), 30, 1.2, C3(255, 200, 130))
cyl(SC, CFrame.new(-92, TOP + 17, 0), "SternLanternPost", 0.6, 6, 0, 0, 0, GOLD, D())
local sl = box(SC, "SternLantern", -93.4, TOP + 19, -1.4, -90.6, TOP + 23, 1.4, st(M.Neon, nil, GREEN), DECO)
light(sl, 40, 1.6, GREEN)
for z = -30, 30, 4 do box(SC, "CastleRail", -93.6, TOP + 14, z - 0.2, -93, TOP + 17, z + 0.2, HARB.beam, DECO) end
-- the forecastle at the bow
box(OUT, "Forecastle", 84, TOP + 1.2, -20, 104, TOP + 7, 20, HULL, DECO)
box(OUT, "ForecastleTop", 83, TOP + 7, -21, 105, TOP + 7.8, 21, DECK, DECO)
-- THE MASTS with their yards, torn sails, rigging; the crow's nest and the flag on the mainmast
local srng = Random.new(9)
for mi, m in MASTS do
	local mx, mh = m[1], m[2]
	cyl(OUT, CFrame.new(mx, TOP + mh / 2, 0), "Mast", 3, mh, 0, 0, 0, HARB.beam, D())
	for k, frac in { 0.32, 0.6, 0.86 } do
		local yy = TOP + mh * frac
		local half = 28 - k * 6
		box(OUT, "Yard", mx - 0.6, yy - 0.6, -half, mx + 0.6, yy + 0.6, half, HARB.beam, DECO)
		-- the sail under it: strips of canvas, some torn short, some missing
		local depth = mh * 0.24
		for zz = -half + 2, half - 2, 4 do
			if srng:NextNumber() < 0.82 then
				local d = depth * srng:NextNumber(0.45, 1)
				box(OUT, "Sail", mx - 0.2 + 0.8, yy - d, zz - 2.05, mx + 0.2 + 0.8, yy - 0.6, zz + 2.05, SAIL, { deco = true, t = srng:NextNumber() < 0.3 and 0.25 or 0 })
			end
		end
		-- rigging from the yard's ends down to the deck edge
		for _, sz in { -1, 1 } do
			local a, z = Vector3.new(mx, yy, sz * half), Vector3.new(mx - 14, TOP + 2, sz * 46)
			part(OUT, "Rigging", Vector3.new(0.2, 0.2, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), HARB.rope, D())
		end
	end
	if mi == 2 then
		local ny = TOP + mh * 0.92
		cyl(OUT, CFrame.new(mx, ny, 0), "CrowsNest", 7, 3, 0, 0, 0, HARB.plankD, D())
		box(OUT, "FlagPole", mx - 0.2, TOP + mh, -0.2, mx + 0.2, TOP + mh + 6, 0.2, HARB.beam, DECO)
		box(OUT, "BlackFlag", mx - 0.15, TOP + mh + 1.6, 0.2, mx + 0.15, TOP + mh + 6, 8, HARB.black, DECO)
		box(OUT, "FlagSkull", mx - 0.25, TOP + mh + 3.2, 3.2, mx + 0.25, TOP + mh + 4.8, 4.8, HARB.white, DECO)
		light(box(OUT, "NestLamp", mx - 0.5, ny + 2, 3, mx + 0.5, ny + 3, 4, st(M.Neon, nil, GREEN), DECO), 30, 1.2, GREEN)
	end
end
-- the bowsprit and the figurehead
local tip = Vector3.new(122, TOP - 2, 0)
part(OUT, "Bowsprit", Vector3.new(1.6, 1.6, 34), CFrame.lookAt(tip + Vector3.new(14, 7, 0), tip + Vector3.new(30, 14, 0)), HARB.beam, D())
for _, sz in { -1, 1 } do
	local a, z = Vector3.new(150, TOP + 13, 0), Vector3.new(70, TOP + 40, sz * 0.1)
	part(OUT, "Stay", Vector3.new(0.2, 0.2, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), HARB.rope, D())
end
b(OUT, CFrame.new(123.5, TOP - 8, 0) * CFrame.Angles(0, -math.pi / 2, 0.3), "Figurehead", 2.4, 6, 2, 0, 0, 0, GOLD, D())
ball(OUT, CFrame.new(124.6, TOP - 4.4, 0), "FigureheadHead", 2.4, 0, 0, 0, GOLD, D())
-- the name on the bow, ghost lanterns along the deck, a green glow in the water round the hull
sign(OUT, "THE BLACK GULL", CFrame.new(78, F1 + 18, 44) * CFrame.Angles(0, math.pi - 0.29, 0), 18, 3, HULL, C3(200, 170, 80), Enum.Font.Creepster)
for _, p in { { -50, 46 }, { 50, 46 }, { 0, -46 }, { 100, 18 } } do
	local g = box(OUT, "DeckLantern", p[1] - 0.6, TOP + 4.6, p[2] - 0.6, p[1] + 0.6, TOP + 6, p[2] + 0.6, st(M.Neon, nil, GREEN), DECO)
	light(g, 26, 1, GREEN)
end
for _, p in { { -60, 54 }, { 40, 54 }, { 110, 20 } } do light(box(OUT, "WaterGlow", p[1], 0.4, p[2], p[1] + 0.2, 0.6, p[2] + 0.2, st(M.Neon, nil, GREEN), { deco = true, t = 1 }), 30, 0.8, GREEN) end
harbSign("THE GHOST SHIP", CFrame.new(0, 19.4, 51.2))
washLight(-34, 86, Vector3.new(-30, TOP, 50), C3(170, 230, 200), 100, 2)
washLight(34, 86, Vector3.new(40, TOP, 50), C3(170, 230, 200), 100, 2)
-- the masts and their sails lit from the yard (green, like the ship's own lanterns), the bow and the stern castle
washLight(-60, 90, Vector3.new(-44, TOP + 30, 0), C3(160, 255, 190), 150, 2.6)
washLight(12, 92, Vector3.new(10, TOP + 40, 0), C3(160, 255, 190), 160, 2.6)
washLight(70, 90, Vector3.new(70, TOP + 30, 0), C3(160, 255, 190), 150, 2.6)
washLight(100, 70, Vector3.new(118, TOP - 4, 0), C3(200, 220, 255), 80, 2)
washLight(-80, 70, Vector3.new(-80, TOP + 8, 0), C3(200, 220, 255), 80, 2)
-- the yard beside the hull is closed off (the hull's side is z 50: nothing to walk round)
sideBarrier(5, 56, nil)
harbGrounds()
return endMap()
