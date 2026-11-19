-- THE CRYPT (the Ashen Abbey, building 2: THE GRAVEDIGGER, who digs the dead up under you and throws coffins).
-- A low vaulted crypt: stone ribs across the ceiling, rows of STONE TOMBS with carved lids (cover from his coffins),
-- burial niches with skulls in the walls, open graves in the floor (dark pits with a mound beside), iron grilles,
-- candles everywhere, a shrine of skulls at the far end. At the back, behind a wall of iron grilles and two doorways:
-- the OSSUARY STORE (bone boxes, a cart of dirt, his tools). Its east end: a TOMB DOOR that slides aside (Secrets:
-- the stash behind it).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_crypt.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 20
local rng = Random.new(42)
beginMap("Abb_Crypt", abbTheme({ inner = st(M.Cobblestone, "PS2_Stone1", C3(92, 92, 84)), floor = st(M.Slate, nil, C3(66, 64, 60)) }))
-- (2026-11-19) its own shape: a mausoleum sunk into a GRAVE MOUND - only its temple front shows, the rest is under earth
local EARTHM = st(M.Ground, nil, C3(56, 42, 34))
local TOP = shell2({ H = H, roof = "hip", rise = 16, over = 4, roofStyle = EARTHM, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	win = { w = 3, b = 12, t = 16 }, steps = false })
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
-- OUTSIDE (2026-11-19): THE GRAVEDIGGER'S CRYPT. Earth heaped over the sides and the back up to the roof (the mound),
-- graves and a dead tree on top of it; at the front a temple portico - squat columns, an entablature with the
-- name, a pediment with a skull - steps down from it, urns, the iron gates thrown open, his shovel in a fresh heap.
local OUT = model(DEC, "Outside")
-- the mound: earth sloping up from the ground to the eaves on three sides
for _, sx in { -1, 1 } do panel(OUT, "Berm", Vector3.new(sx * 98, -1, 0), Vector3.new(sx * 81, TOP, 0), Vector3.new(0, 0, 1), 124, EARTHM, 2, D()) end
panel(OUT, "Berm", Vector3.new(0, -1, -78), Vector3.new(0, TOP, -61), Vector3.new(1, 0, 0), 196, EARTHM, 2, D())
for _, sx in { -1, 1 } do tri(OUT, "BermEnd", Vector3.new(sx * 81, TOP, 61), Vector3.new(sx * 98, -1, 61), Vector3.new(sx * 81, -1, 61), EARTHM, 1, D()) end
-- graves on the mound (on the slopes of the earth roof), a dead tree on top, tufts
local mrng = Random.new(18)
for k = 1, 16 do
	local x, z = mrng:NextNumber(-60, 60), mrng:NextNumber(-48, 40)
	local y = TOP + 16 * (1 - math.max(math.abs(x) / 80, math.abs(z) / 60)) - 0.5
	local cf = CFrame.new(x, y, z) * CFrame.Angles(mrng:NextNumber(-0.15, 0.15), mrng:NextNumber(0, 6), mrng:NextNumber(-0.15, 0.15))
	if k % 3 == 0 then
		b(OUT, cf, "MoundCross", 0.7, 5, 0.7, 0, 2.5, 0, ABB.stone, D()); b(OUT, cf, "MoundCrossArm", 3, 0.7, 0.7, 0, 3.6, 0, ABB.stone, D())
	else
		b(OUT, cf, "MoundStone", 2.6, 3.6, 0.7, 0, 1.8, 0, k % 2 == 0 and ABB.stone or ABB.stoneD, D())
	end
end
abbDeadTree(OUT, Vector3.new(14, TOP + 12, -10), mrng)
-- THE PORTICO: columns, entablature, pediment with a skull
local PZ = 66
box(STR, "PorticoFloor", -32, 0, 59, 32, 2.05, PZ + 3, ABB.stoneD)
box(STR, "PorticoStep", -14, 0, PZ + 3, 14, 1.35, PZ + 5.5, ABB.stoneD)
box(STR, "PorticoStep", -14, 0, PZ + 5.5, 14, 0.7, PZ + 8, ABB.stoneD)
for _, x in { -27, -17, -8, 8, 17, 27 } do
	cyl(OUT, CFrame.new(x, 2 + 7.5, PZ), "Column", 2.6, 15, 0, 0, 0, ABB.stoneL, D())
	box(OUT, "ColumnBase", x - 1.8, 2, PZ - 1.8, x + 1.8, 3, PZ + 1.8, ABB.stone, DECO)
	box(OUT, "ColumnCap", x - 2, 16.4, PZ - 2, x + 2, 17.4, PZ + 2, ABB.stone, DECO)
end
box(OUT, "Entablature", -31, 17.4, 59, 31, 21, PZ + 2.2, ABB.stone, DECO)
sign(OUT, "REQUIESCANT", CFrame.new(0, 19.2, PZ + 2.3) * CFrame.Angles(0, math.pi, 0), 24, 2.4, ABB.stone, C3(40, 30, 26), Enum.Font.Fantasy)
tri(OUT, "Pediment", Vector3.new(-32, 21, PZ + 1.4), Vector3.new(32, 21, PZ + 1.4), Vector3.new(0, 33, PZ + 1.4), ABB.stoneL, 2, D())
abbSkull(OUT, CFrame.new(0, 25.4, PZ + 2.6) * CFrame.Angles(0, math.pi, 0), 3.4)
for _, sx in { -1, 1 } do
	local a, z = Vector3.new(sx * 33, 20.6, PZ + 2), Vector3.new(0, 33.6, PZ + 2)
	part(OUT, "PedimentTrim", Vector3.new(1, 1, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), ABB.stone, D())
	-- urns at the corners, the iron gates opened outward
	box(OUT, "UrnPlinth", sx * 30 - 1.6, 0, PZ + 6, sx * 30 + 1.6, 3.4, PZ + 9.2, ABB.stone, DECO)
	cyl(OUT, CFrame.new(sx * 30, 4.9, PZ + 7.6), "Urn", 2.6, 3, 0, 0, 0, ABB.stoneD, D())
	for k = 0, 6 do box(OUT, "GateBar", sx * 7 + sx * (k * 0.8), 2, PZ - 1 + k * 0.9, sx * 7 + sx * (k * 0.8) + 0.25, 15, PZ - 0.75 + k * 0.9, ABB.iron, DECO) end
end
-- his shovel in a fresh heap of earth by the steps, a lantern on the column
part(OUT, "Heap", Vector3.new(6, 2, 5), CFrame.new(22, 0.6, 82) * CFrame.Angles(0, 0.3, 0), EARTHM, D())
part(OUT, "ShovelHandle", Vector3.new(0.4, 6, 0.4), CFrame.new(22, 3.4, 82) * CFrame.Angles(0.3, 0, 0.2), ABB.beam, D())
part(OUT, "ShovelBlade", Vector3.new(1.8, 2, 0.3), CFrame.new(21.6, 0.9, 81) * CFrame.Angles(0.3, 0, 0.2), ABB.iron, D())
for _, x in { -12, 12 } do abbLantern(OUT, Vector3.new(x, 13, PZ - 2), 24) end
abbSign("THE CRYPT", CFrame.new(0, 28.6, PZ + 3.8))
washLight(-30, 88, Vector3.new(-10, 20, 64), C3(255, 170, 130), 90, 2)
washLight(30, 88, Vector3.new(10, 20, 64), C3(255, 170, 130), 90, 2)
abbGrounds()
return endMap()
