-- THE GHOST SHIP (Blackwater Harbor, building 5: THE PIRATE, then THE PIRATE KING). The captain's ship moored at
-- the end of the pier; inside, the GUN DECK: dark planks between ribs, two MASTS through the deck (cover), CANNONS
-- along both sides, barrels and powder kegs, hammocks swinging under the beams, the crew's mess table. At the back,
-- behind a wall with a door: THE CAPTAIN'S CABIN - his desk, maps, a chest, a lamp; his chart cabinet slides away
-- (Secrets: the treasure hold behind it). Outside, the building is dressed as a hull: black planks, portholes, a
-- figurehead and a bowsprit over the porch.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_ship.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 24
local rng = Random.new(55)
local HULL = st(M.WoodPlanks, "PS2_Siding1", C3(40, 34, 30))
local DECK = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(70, 56, 44))
local GOLD = st(M.Metal, nil, C3(190, 150, 60))
beginMap("Harb_Ship", harbTheme({ ext = HULL, inner = st(M.WoodPlanks, "PS2_Siding1", C3(66, 52, 42)), floor = DECK, floor2 = DECK, trim = GOLD }))
shell({ two = false, H = H, roof = "gable", pitch = 0.25, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 4, winB = 7, winT = 11 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "CabinWall", "x", -30, -50, 50, F1, H, { dr(0, 10, 13) }, I)

-- the ribs of the hull along both side walls and over the deck
for z = -26, 54, 10 do
	for _, x in { -77.2, 77.2 } do box(DEC, "Rib", x - 1, F1, z - 0.8, x + 1, F1 + H - 2, z + 0.8, HARB.beam, DECO) end
	box(DEC, "DeckBeam", -78, F1 + H - 3, z - 0.8, 78, F1 + H - 1.8, z + 0.8, HARB.beam, DECO)
end
-- THE MASTS (cover), rope ladders up them
for _, z in { 32, 4 } do
	cyl(STR, CFrame.new(0, F1 + 18, z), "Mast", 4, 36, 0, 0, 0, HARB.beam)
	cyl(DEC, CFrame.new(0, F1 + 1, z), "MastFoot", 6, 2, 0, 0, 0, GOLD, D())
	for k = 0, 6 do box(DEC, "Ratline", -2.6, F1 + 2 + k * 2, z + 2.1, 2.6, F1 + 2.2 + k * 2, z + 2.3, HARB.rope, DECO) end
end
-- THE CANNONS along both sides, on carriages, pointing out of their ports
local guns = model(STR, "Cannons")
for z = -20, 50, 14 do
	for _, sx in { -1, 1 } do
		local x = sx * 68
		box(guns, "Carriage", x - 3, F1, z - 2, x + 3, F1 + 2.4, z + 2, HARB.plankD)
		cyl(DEC, CFrame.new(x + sx * 1.2, F1 + 3.4, z) * CFrame.Angles(0, 0, -math.pi / 2), "Barrel", 1.8, 7, 0, 0, 0, HARB.iron, D())
		for _, dz in { -2.1, 2.1 } do cyl(DEC, CFrame.new(x - sx * 1.6, F1 + 1, z + dz) * CFrame.Angles(math.pi / 2, 0, 0), "Wheel", 2, 0.4, 0, 0, 0, HARB.beam, D()) end
		box(DEC, "Port", x + sx * 8.6, F1 + 2.5, z - 1.8, x + sx * 9.1, F1 + 5.5, z + 1.8, HARB.black, DECO)
		for k = 0, 2 do ball(DEC, CFrame.new(x - sx * 4, F1 + 0.6, z - 1 + k * 1), "Shot", 1.1, 0, 0, 0, HARB.iron, D()) end
	end
end
-- barrels and powder kegs, the crew's mess table and benches
for _, p in { { -40, 50 }, { 40, 50 }, { -46, 16 }, { 46, -14 }, { -30, -20 } } do
	for k = 0, 2 do cyl(STR, CFrame.new(p[1] + (k - 1) * 3.2, F1 + 2, p[2]), "Keg", 2.8, 4, 0, 0, 0, k == 1 and HARB.red or HARB.plankD) end
end
box(STR, "MessTable", 18, F1, 12, 36, F1 + 3.2, 20, HARB.plank)
for _, z in { 10.4, 21.6 } do box(DEC, "MessBench", 18, F1 + 1.6, z - 0.8, 36, F1 + 2, z + 0.8, HARB.plankD, DECO) end
box(DEC, "Tankard", 24, F1 + 3.2, 15, 25, F1 + 4.4, 16, HARB.iron, DECO)
box(DEC, "Bread", 30, F1 + 3.2, 16, 32, F1 + 3.8, 17, st(M.SmoothPlastic, nil, C3(170, 120, 70)), DECO)
-- hammocks under the beams
for _, p in { { -30, 40 }, { -30, 24 }, { 34, 40 }, { -54, 0 } } do
	for i = 0, 6 do
		local u = i / 6
		box(DEC, "Hammock", p[1] - 5 + u * 10 - 0.75, F1 + 10 - math.sin(u * math.pi) * 1.6, p[2] - 1.4, p[1] - 5 + u * 10 + 0.75, F1 + 10.2 - math.sin(u * math.pi) * 1.6, p[2] + 1.4, HARB.canvas, DECO)
	end
	for _, dx in { -5.5, 5.5 } do box(DEC, "HammockRope", p[1] + dx - 0.05, F1 + 10, p[2] - 0.05, p[1] + dx + 0.05, F1 + H - 3, p[2] + 0.05, HARB.rope, DECO) end
end
-- THE CAPTAIN'S CABIN (z -58..-30, x -50..50)
for _, x in { -50, 50 } do box(inn, "CabinSide", x - 0.6, F1, -58, x + 0.6, F1 + H, -30, st(M.WoodPlanks, "PS2_Siding1", C3(66, 52, 42))) end
box(STR, "Desk", -8, F1, -48, 8, F1 + 3.6, -42, st(M.Wood, nil, C3(90, 50, 30)))
box(DEC, "Chart", -6, F1 + 3.6, -47, 4, F1 + 3.7, -43, st(M.SmoothPlastic, nil, C3(200, 180, 130)), DECO)
box(DEC, "Quill", 5, F1 + 3.6, -46, 5.3, F1 + 4.8, -45.7, HARB.white, DECO)
box(STR, "Chest", 20, F1, -54, 28, F1 + 4, -48, st(M.Wood, nil, C3(90, 50, 30)))
box(DEC, "ChestBand", 19.8, F1 + 1, -54.2, 28.2, F1 + 1.6, -47.8, GOLD, DECO)
box(DEC, "ChestLid", 19.8, F1 + 4, -54.2, 28.2, F1 + 4.8, -47.8, st(M.Wood, nil, C3(80, 44, 26)), DECO)
harbLantern(DEC, Vector3.new(0, F1 + 10, -45), 26)
-- the chart cabinet (Secrets): slides aside to the treasure hold (x -50..-30, z -58..-46)
local sr = model(STR, "Hold")
box(sr, "Wall", -30.6, F1, -58, -29.4, F1 + 12, -46, HARB.sidingD)
box(sr, "Wall", -50, F1, -47.2, -44, F1 + 12, -46, HARB.sidingD)
box(sr, "Wall", -38, F1, -47.2, -30.6, F1 + 12, -46, HARB.sidingD)
box(sr, "Lintel", -44, F1 + 9, -47.2, -38, F1 + 12, -46, HARB.sidingD)
box(sr, "Ceiling", -50, F1 + 12, -58, -29.4, F1 + 12.6, -46, HARB.beam)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "ChartCabinet")
door:SetAttribute("Slide", Vector3.new(6.2, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "The captain's chart cabinet")
box(door, "Panel", -44, F1, -46.6, -38, F1 + 9, -44.6, st(M.Wood, nil, C3(90, 50, 30)))
for r = 0, 3 do box(door, "Panel", -43.6, F1 + 1 + r * 2, -44.7, -38.4, F1 + 1.3 + r * 2, -44.4, GOLD, DECO) end
box(door, "Trigger", -41.5, F1 + 4, -43.8, -40.5, F1 + 5, -42.8, HARB.plank, { deco = true, t = 1 })
for k = 0, 5 do cyl(DEC, CFrame.new(-40 + k * 0.6, F1 + 0.08, -44 + k * 1.5), "TrailCoin", 0.7, 0.1, 0, 0, 0, GOLD, D()) end
local loot = model(DEC, "Treasure")
for _ = 0, 30 do cyl(loot, CFrame.new(rng:NextNumber(-48, -32), F1 + 0.1 + rng:NextNumber(0, 1), rng:NextNumber(-57, -49)), "Coin", 0.9, 0.14, 0, 0, 0, GOLD, D()) end
box(loot, "CoinPile", -46, F1, -56, -38, F1 + 1.6, -51, GOLD, DECO)
local sg = b(loot, CFrame.new(-40, F1 + 10, -52), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, HARB.lamp, { deco = true, t = 1 })
light(sg, 18, 1.2, C3(255, 210, 110))

-- OUTSIDE: dressed as a hull (portholes along the side walls, a gold stripe, a figurehead and bowsprit over the porch)
local hull = model(DEC, "HullDress")
for z = -50, 50, 12 do
	for _, x in { -80.3, 80.3 } do
		cyl(hull, CFrame.new(x, F1 + 8, z) * CFrame.Angles(0, 0, -math.pi / 2), "Porthole", 2.6, 0.3, 0, 0, 0, GOLD, D())
		local g = cyl(hull, CFrame.new(x, F1 + 8, z) * CFrame.Angles(0, 0, -math.pi / 2), "PortGlass", 2, 0.35, 0, 0, 0, st(M.Neon, nil, C3(255, 200, 120)), D())
		local _ = g
	end
end
for _, x in { -80.3, 80.3 } do box(hull, "Stripe", x - 0.15, F1 + 13, -58, x + 0.15, F1 + 14, 58, GOLD, DECO) end
b(hull, CFrame.new(0, F1 + 16, 64) * CFrame.Angles(-0.35, 0, 0), "Bowsprit", 1.4, 1.4, 24, 0, 0, 6, HARB.beam, DECO)
b(hull, CFrame.new(0, F1 + 12, 61.5), "Figurehead", 2.4, 4.4, 2, 0, 0, 0, GOLD, DECO)
ball(hull, CFrame.new(0, F1 + 15, 61.8), "FigureheadHead", 2.2, 0, 0, 0, GOLD, D())

-- lights: lanterns on the masts and beams
for _, p in { { -2.6, 32 }, { 2.6, 4 }, { -50, 30 }, { 50, 30 }, { -50, -6 }, { 50, -6 }, { 28, 16 } } do harbLantern(DEC, Vector3.new(p[1], F1 + 12, p[2]), 28) end
for _, p in { { -20, 30 }, { 40, 0 }, { 10, -40 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -20, 44 }, { 20, 44 }, { -40, 6 }, { 40, 30 }, { 0, -40 }, { -30, -10 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-6, -30, 6, -20, F1) -- (the cabin door)
keepClear(-46, -44, -36, -36, F1) -- (in front of the chart cabinet)
harbSign("THE GHOST SHIP")
harbGrounds()
return endMap()
