-- THE CLOISTER (the Ashen Abbey, building 1: THE WEEPING NUN, who vanishes and sings the windows' light into fire).
-- A square cloister: ARCADES of stone columns round a dead GARDEN in the middle (a black fountain, dead grass, a
-- broken statue of a saint), tall STAINED-GLASS windows along the outer walls, candles in the corners, prayer
-- benches, saints' statues in niches; the columns are cover from her light. At the back, behind a wall with two
-- doorways: the CHAPTER HOUSE (a long table, the abbot's chair, lecterns). Its west end: a CONFESSIONAL that slides
-- aside (Secrets: the stash behind it).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_cloister.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 24
local rng = Random.new(41)
beginMap("Abb_Cloister", abbTheme())
shell({ two = false, H = H, roof = "gable", pitch = 0.5, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 5, winB = 6, winT = 18 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "ChapterWall", "x", -30, -78, 78, F1, H, { dr(-40, 10, 13), dr(40, 10, 13) }, I)

-- THE ARCADES: a square of columns round the garden, a stone gallery roof over the walk
local cols = model(STR, "Columns")
for x = -54, 54, 12 do
	for _, z in { -18, 50 } do
		cyl(cols, CFrame.new(x, F1 + 7, z), "Column", 2.4, 14, 0, 0, 0, ABB.stoneL)
		box(DEC, "Capital", x - 1.8, F1 + 13.6, z - 1.8, x + 1.8, F1 + 14.4, z + 1.8, ABB.stone, DECO)
		box(DEC, "Base", x - 1.6, F1, z - 1.6, x + 1.6, F1 + 0.8, z + 1.6, ABB.stone, DECO)
	end
end
for z = -6, 38, 11 do
	for _, x in { -54, 54 } do
		cyl(cols, CFrame.new(x, F1 + 7, z), "Column", 2.4, 14, 0, 0, 0, ABB.stoneL)
		box(DEC, "Capital", x - 1.8, F1 + 13.6, z - 1.8, x + 1.8, F1 + 14.4, z + 1.8, ABB.stone, DECO)
	end
end
-- the arcade's lintels and the gallery roof slanting out to the walls
for _, z in { -18, 50 } do box(DEC, "Lintel", -55.5, F1 + 14.4, z - 1.2, 55.5, F1 + 16, z + 1.2, ABB.stone, DECO) end
for _, x in { -54, 54 } do box(DEC, "Lintel", x - 1.2, F1 + 14.4, -18, x + 1.2, F1 + 16, 50, ABB.stone, DECO) end
-- THE GARDEN in the middle: dead grass, a black fountain, a broken saint
box(DEC, "Garden", -50, F1 + 0.02, -14, 50, F1 + 0.12, 46, ABB.moss, DECO)
for k = 0, 14 do
	local x, z = rng:NextNumber(-46, 46), rng:NextNumber(-10, 42)
	if math.abs(x) < 10 and math.abs(z - 16) < 10 then continue end
	part(DEC, "Tuft", Vector3.new(1.4, 0.8, 0.3), CFrame.new(x, F1 + 0.4, z) * CFrame.Angles(0, rng:NextNumber(0, 6), rng:NextNumber(-0.3, 0.3)), st(M.Grass, nil, C3(70, 66, 40)), DECO)
	local _ = k
end
local fn = model(STR, "Fountain")
cyl(fn, CFrame.new(0, F1 + 1, 16), "Basin", 14, 2, 0, 0, 0, ABB.stoneL)
cyl(DEC, CFrame.new(0, F1 + 2.05, 16), "BlackWater", 12.6, 0.1, 0, 0, 0, st(M.Glass, nil, C3(8, 6, 10)), D()).Reflectance = 0.4
cyl(fn, CFrame.new(0, F1 + 4, 16), "Pillar", 2, 6, 0, 0, 0, ABB.stoneL)
cyl(DEC, CFrame.new(0, F1 + 7.2, 16), "Bowl", 5, 0.8, 0, 0, 0, ABB.stoneL, D())
-- the broken saint on a plinth by the fountain
box(STR, "Plinth", 18, F1, 12, 22, F1 + 3, 16, ABB.stone)
box(DEC, "SaintBody", 18.8, F1 + 3, 12.8, 21.2, F1 + 8, 15.2, ABB.marble, DECO)
box(DEC, "SaintHeadless", 19.4, F1 + 8, 13.4, 20.6, F1 + 8.6, 14.6, ABB.marble, DECO)
part(DEC, "SaintHead", Vector3.one * 1.3, CFrame.new(23.5, F1 + 0.7, 18) * CFrame.Angles(0.4, 0.8, 0.2), ABB.marble, DECO)
-- STAINED GLASS along the outer walls (between the windows of the shell)
for _, z in { 36, 8, -16 } do
	abbStained(DEC, CFrame.new(-77.8, F1 + 13, z) * CFrame.Angles(0, math.pi / 2, 0), 6, 12)
	abbStained(DEC, CFrame.new(77.8, F1 + 13, z) * CFrame.Angles(0, -math.pi / 2, 0), 6, 12)
end
for _, x in { -48, -24, 24, 48 } do abbStained(DEC, CFrame.new(x, F1 + 13, 57.8) * CFrame.Angles(0, math.pi, 0), 6, 12) end
-- the walk round the garden: prayer benches, saints in niches on the walls, candles in the corners
for _, p in { { -66, 30 }, { 66, 30 }, { -66, 0 }, { 66, 0 }, { -30, 54 }, { 30, 54 } } do
	box(STR, "PrayerBench", p[1] - 3, F1, p[2] - 1, p[1] + 3, F1 + 1.6, p[2] + 1, ABB.beam)
end
for _, p in { { -77, 22 }, { 77, 22 }, { -77, -6 }, { 77, -6 } } do
	local sx = p[1] < 0 and 1 or -1
	box(DEC, "Niche", p[1] - 0.2, F1 + 4, p[2] - 2.5, p[1] + sx * 1.6, F1 + 12, p[2] + 2.5, ABB.stoneD, DECO)
	box(DEC, "Saint", p[1] + sx * 0.4 - 0.8, F1 + 4.5, p[2] - 1, p[1] + sx * 0.4 + 0.8, F1 + 10.5, p[2] + 1, ABB.marble, DECO)
end
for _, p in { { -72, 52 }, { 72, 52 }, { -72, -24 }, { 72, -24 }, { 0, 54 } } do abbCandles(DEC, Vector3.new(p[1], F1, p[2]), rng, 7) end
-- THE CHAPTER HOUSE (behind the wall): the long table, the abbot's chair, lecterns, a big book
box(STR, "ChapterTable", -24, F1, -48, 24, F1 + 3.2, -42, ABB.beam)
for x = -20, 20, 8 do
	for _, z in { -50.2, -39.8 } do box(DEC, "Stool", x - 1, F1, z - 1, x + 1, F1 + 2, z + 1, ABB.plank, DECO) end
end
box(STR, "AbbotChair", -1.8, F1, -55, 1.8, F1 + 2.2, -51.6, ABB.red)
box(DEC, "AbbotBack", -1.8, F1 + 2.2, -55, 1.8, F1 + 9, -54, ABB.red, DECO)
part(DEC, "AbbotCrown", Vector3.new(4, 1.6, 1), CFrame.new(0, F1 + 9.6, -54.5), ABB.gold, DECO)
for _, x in { -50, 50 } do
	cyl(DEC, CFrame.new(x, F1 + 2.2, -45), "Lectern", 1, 4.4, 0, 0, 0, ABB.beam, D())
	part(DEC, "LecternTop", Vector3.new(2.4, 0.3, 1.8), CFrame.new(x, F1 + 4.6, -45) * CFrame.Angles(-0.4, 0, 0), ABB.beam, DECO)
	part(DEC, "Book", Vector3.new(2, 0.3, 1.4), CFrame.new(x, F1 + 4.85, -45) * CFrame.Angles(-0.4, 0, 0), ABB.red, DECO)
end
-- THE STASH behind the confessional (x -78..-58, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", -58.2, F1, -58, -57, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", -78, F1, -43.2, -70, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", -64, F1, -43.2, -58.2, F1 + 12, -42, ABB.stoneD)
box(sr, "Lintel", -70, F1 + 9, -43.2, -64, F1 + 12, -42, ABB.stoneD)
box(sr, "Ceiling", -78, F1 + 12, -58, -57, F1 + 12.6, -42, ABB.beam)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "Confessional")
door:SetAttribute("Slide", Vector3.new(6.4, 0, 0)); door:SetAttribute("Action", "Push"); door:SetAttribute("Object", "Old confessional")
box(door, "Panel", -70, F1, -42.9, -64, F1 + 10, -40.4, ABB.beam)
box(door, "Panel", -69.6, F1 + 10, -42.7, -64.4, F1 + 11, -40.6, ABB.beam, DECO)
box(door, "Panel", -68.6, F1 + 4, -40.5, -65.4, F1 + 8, -40.3, st(M.Fabric, nil, C3(70, 20, 20)), DECO)
box(door, "Trigger", -67.5, F1 + 4, -39.4, -66.5, F1 + 5, -38.4, ABB.beam, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", -63 + k * 1.4, F1 + 0.06, -40 + k * 0.2, -62 + k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(120, 110, 96)), DECO) end
local loot = model(DEC, "Stash")
abbCandles(loot, Vector3.new(-74, F1, -54), rng, 6)
box(loot, "Chest", -66, F1, -56, -61, F1 + 2.6, -53, ABB.beam, DECO)
box(loot, "ChestBand", -66.1, F1 + 1.2, -56.1, -60.9, F1 + 1.6, -52.9, ABB.gold, DECO)

-- lights: candle chandeliers over the walk, a cold light over the garden
for _, p in { { -66, 16 }, { 66, 16 }, { 0, 54 }, { -40, -45 }, { 40, -45 } } do bulb(p[1], F1 + H - 1, p[2], 4, C3(255, 190, 120)) end
for _, p in { { -20, 16 }, { 20, 16 } } do bulb(p[1], F1 + H - 1, p[2], 6, C3(200, 200, 230)) end
for _, p in { { -30, 30 }, { 40, 0 }, { -50, -50 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 54 }, { 40, 54 }, { -66, 10 }, { 66, 10 }, { -20, -44 }, { 20, -44 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-62, -42, -54, -34, F1) -- (in front of the confessional)
keepClear(-60, -16, 60, -8, F1) -- (the walk along the arcade)
abbSign("THE CLOISTER")
abbGrounds()
return endMap()
