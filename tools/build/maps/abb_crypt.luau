-- THE CRYPT (the Ashen Abbey, building 2: THE GRAVEDIGGER, who digs the dead up under you and throws coffins).
-- A low vaulted crypt: stone ribs across the ceiling, rows of STONE TOMBS with carved lids (cover from his coffins),
-- burial niches with skulls in the walls, open graves in the floor (dark pits with a mound beside), iron grilles,
-- candles everywhere, a shrine of skulls at the far end. At the back, behind a wall of iron grilles and two doorways:
-- the OSSUARY STORE (bone boxes, a cart of dirt, his tools). Its east end: a TOMB DOOR that slides aside (Secrets:
-- the stash behind it).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_crypt.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 20
local rng = Random.new(42)
beginMap("Abb_Crypt", abbTheme({ inner = st(M.Cobblestone, "PS2_Stone1", C3(92, 92, 84)), floor = st(M.Slate, nil, C3(66, 64, 60)) }))
shell({ two = false, H = H, roof = "gable", pitch = 0.3, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 3, winB = 12, winT = 16 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "StoreWall", "x", -32, -78, 78, F1, H, { dr(-30, 10, 12), dr(30, 10, 12) }, I)

-- the vault: stone ribs arching over the room, a heavy pillar under each pair
for z = -24, 54, 13 do
	box(DEC, "Rib", -78, F1 + H - 3, z - 0.8, 78, F1 + H - 1.5, z + 0.8, ABB.stone, DECO)
	for _, x in { -78, 78 } do part(DEC, "RibFoot", Vector3.new(4, 6, 1.6), CFrame.new(x, F1 + H - 4, z) * CFrame.Angles(0, 0, x < 0 and -0.5 or 0.5), ABB.stone, DECO) end
end
local piers = model(STR, "Piers")
for _, x in { -26, 26 } do
	for z = -11, 41, 26 do box(piers, "Pier", x - 2, F1, z - 2, x + 2, F1 + H - 1, z + 2, ABB.stoneL) end
end
-- THE TOMBS: rows of stone chests with carved lids
local tombs = model(STR, "Tombs")
for _, p in { { -52, 40 }, { -52, 14 }, { -52, -12 }, { 52, 40 }, { 52, 14 }, { 52, -12 }, { 0, 30 }, { 0, -2 } } do
	box(tombs, "Tomb", p[1] - 4, F1, p[2] - 2.2, p[1] + 4, F1 + 3.4, p[2] + 2.2, ABB.stoneL)
	box(DEC, "Lid", p[1] - 4.4, F1 + 3.4, p[2] - 2.6, p[1] + 4.4, F1 + 4, p[2] + 2.6, ABB.marble, DECO)
	-- the figure carved on the lid: a knight with his hands folded
	box(DEC, "Effigy", p[1] - 3, F1 + 4, p[2] - 0.8, p[1] + 2.4, F1 + 4.8, p[2] + 0.8, ABB.marble, DECO)
	box(DEC, "EffigyHead", p[1] + 2.4, F1 + 4, p[2] - 0.6, p[1] + 3.4, F1 + 5, p[2] + 0.6, ABB.marble, DECO)
	abbCandles(DEC, Vector3.new(p[1] + 5.5, F1, p[2] + 1.5), rng, 3)
end
-- burial niches with skulls along the side walls
for z = -26, 54, 8 do
	for _, x in { -77.6, 77.6 } do
		local sx = x < 0 and 1 or -1
		for _, y in { 3, 8 } do
			if math.abs(z - 20) < 5 or math.abs(z - 44) < 5 or math.abs(z + 30) < 5 then continue end -- (the shell's windows)
			box(DEC, "Niche", x, F1 + y, z - 2.4, x + sx * 1.4, F1 + y + 3, z + 2.4, st(M.Slate, nil, C3(20, 18, 16)), DECO)
			if rng:NextNumber() < 0.7 then
				part(DEC, "Skull", Vector3.new(1, 1.1, 1.2), CFrame.new(x + sx * 0.8, F1 + y + 0.55, z + rng:NextNumber(-1.2, 1.2)) * CFrame.Angles(0, sx * math.pi / 2 + rng:NextNumber(-0.4, 0.4), 0), ABB.bone, DECO)
			end
		end
	end
end
-- OPEN GRAVES in the floor: a dark pit (flush, walkable) and a mound of earth with a shovel stuck in it
for _, p in { { -26, 28 }, { 26, 2 }, { -10, 46 }, { 30, 46 } } do
	box(DEC, "Pit", p[1] - 2.2, F1 + 0.02, p[2] - 4, p[1] + 2.2, F1 + 0.06, p[2] + 4, st(M.SmoothPlastic, nil, C3(6, 4, 4)), DECO)
	box(DEC, "PitEdge", p[1] - 2.6, F1 + 0.01, p[2] - 4.4, p[1] + 2.6, F1 + 0.05, p[2] + 4.4, ABB.earth, DECO)
	part(DEC, "Mound", Vector3.new(3, 1.6, 6), CFrame.new(p[1] + 4.2, F1 + 0.5, p[2]) * CFrame.Angles(0, 0, 0.3), ABB.earth, DECO)
	part(DEC, "Shovel", Vector3.new(0.25, 5, 0.25), CFrame.new(p[1] + 4.6, F1 + 3, p[2] + 1) * CFrame.Angles(0.15, 0, 0.2), ABB.beam, DECO)
end
-- iron grilles between the side bays
for _, z in { 27, 1 } do
	for _, x in { -66, 66 } do
		for k = -5, 5 do box(DEC, "Grille", x + k * 0.8 - 0.08, F1, z - 0.08, x + k * 0.8 + 0.08, F1 + 9, z + 0.08, ABB.iron, DECO) end
		box(DEC, "GrilleBar", x - 4.2, F1 + 8.6, z - 0.15, x + 4.2, F1 + 9, z + 0.15, ABB.iron, DECO)
	end
end
-- THE SHRINE OF SKULLS at the front end (by the porch side walls): stacked skulls round a cross, candles
for _, x in { -66, 66 } do
	for row = 0, 3 do
		for k = 0, 5 - row do
			part(DEC, "ShrineSkull", Vector3.new(1, 1.1, 1.1), CFrame.new(x - 2.8 + row * 0.5 + k * 1.1, F1 + 0.55 + row * 1.1, 54) * CFrame.Angles(0, math.pi, 0), ABB.bone, DECO)
		end
	end
	box(DEC, "ShrineCross", x - 0.3, F1 + 4.4, 54.2, x + 0.3, F1 + 9, 54.6, ABB.iron, DECO)
	box(DEC, "ShrineCrossBar", x - 1.4, F1 + 7.2, 54.2, x + 1.4, F1 + 7.8, 54.6, ABB.iron, DECO)
	abbCandles(DEC, Vector3.new(x + 4, F1, 52), rng, 6)
end
-- THE STORE (behind the wall): bone boxes, a cart of dirt, tools on the wall
for _, p in { { -60, -46 }, { -44, -50 }, { -6, -50 }, { 12, -44 } } do
	box(STR, "BoneBox", p[1] - 3, F1, p[2] - 2.5, p[1] + 3, F1 + 3.5, p[2] + 2.5, ABB.beam)
	for k = 0, 3 do part(DEC, "Bone", Vector3.new(0.4, 0.4, 2.4), CFrame.new(p[1] - 1.5 + k, F1 + 3.7, p[2]) * CFrame.Angles(0, rng:NextNumber(-0.5, 0.5), 0), ABB.bone, DECO) end
end
box(STR, "Cart", 30, F1 + 1, -54, 40, F1 + 4, -48, ABB.beam)
part(DEC, "CartDirt", Vector3.new(9, 2, 5), CFrame.new(35, F1 + 4.6, -51), ABB.earth, DECO)
for _, x in { 31, 39 } do cyl(DEC, CFrame.new(x, F1 + 1, -54.4) * CFrame.Angles(math.pi / 2, 0, 0), "Wheel", 2, 0.4, 0, 0, 0, ABB.beam, D()) end
for k = 0, 4 do part(DEC, "Tool", Vector3.new(0.25, 5, 0.25), CFrame.new(-30 + k * 2.4, F1 + 5, -57.6) * CFrame.Angles(0, 0, (k - 2) * 0.08), ABB.beam, DECO) end
-- THE STASH behind the tomb door (x 50..78, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", 49, F1, -58, 50.2, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", 50.2, F1, -43.2, 60, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", 66, F1, -43.2, 78, F1 + 12, -42, ABB.stoneD)
box(sr, "Lintel", 60, F1 + 9, -43.2, 66, F1 + 12, -42, ABB.stoneD)
box(sr, "Ceiling", 49, F1 + 12, -58, 78, F1 + 12.6, -42, ABB.stone)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "TombDoor")
door:SetAttribute("Slide", Vector3.new(-6.4, 0, 0)); door:SetAttribute("Action", "Push"); door:SetAttribute("Object", "Cracked tomb door")
box(door, "Panel", 60, F1, -42.9, 66, F1 + 9, -40.6, ABB.marble)
box(door, "Panel", 62.6, F1 + 5, -40.65, 63.4, F1 + 8, -40.4, ABB.stoneD, DECO)
box(door, "Panel", 61.6, F1 + 6.6, -40.65, 64.4, F1 + 7.2, -40.4, ABB.stoneD, DECO)
box(door, "Trigger", 62.5, F1 + 4, -39.6, 63.5, F1 + 5, -38.6, ABB.marble, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", 59 - k * 1.4, F1 + 0.06, -40 + k * 0.2, 60 - k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(120, 110, 96)), DECO) end
local loot = model(DEC, "Stash")
abbCandles(loot, Vector3.new(54, F1, -54), rng, 6)
box(loot, "Sarcophagus", 64, F1, -56, 74, F1 + 3, -50, ABB.gold, DECO)
local sg = b(loot, CFrame.new(64, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, ABB.holy, { deco = true, t = 1 })
light(sg, 18, 1, C3(255, 200, 140))

-- lights: hanging iron candle wheels, a green grave-glow in the store
for _, p in { { -40, 27 }, { 40, 27 }, { 0, 14 }, { -40, 1 }, { 40, 1 }, { 0, 46 } } do bulb(p[1], F1 + H - 1, p[2], 3, C3(255, 180, 110)) end
for _, p in { { -30, -46 }, { 30, -46 } } do bulb(p[1], F1 + H - 1, p[2], 3, C3(170, 255, 150)) end
for _, p in { { -30, 30 }, { 20, -10 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 50 }, { 40, 50 }, { 0, 14 }, { -30, -10 }, { 30, -10 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(56, -42, 70, -34, F1)
abbSign("THE CRYPT")
abbGrounds()
return endMap()
