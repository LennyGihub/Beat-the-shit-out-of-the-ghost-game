-- THE FISH MARKET (Blackwater Harbor, building 1: THE DEEP ONE, who spits ink and dives into the floor after you).
-- The hall: a white tiled floor, rows of stone FISH SLABS on ice (cover from his ink), stalls under canvas awnings,
-- fish hanging on hooks, a big DRAIN into the harbor in the middle (where he came up), scales and ice boxes. At the
-- back, behind a wall with two doorways: the COLD ROOM (crates of ice, hanging fish). Its east end: a rusty ICE
-- LOCKER that pulls away (Secrets: the stash behind it; item spot by maps/harb_items.luau).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_market.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local rng = Random.new(12)
local IRONG = st(M.Metal, nil, C3(46, 86, 70)) -- (the market's green-painted cast iron)
beginMap("Harb_Market", harbTheme({ floor = HARB.tile, inner = st(M.Plaster, nil, C3(104, 118, 114)), ext = st(M.Brick, nil, C3(110, 70, 56)), trim = IRONG }))
-- (2026-11-19) its own shape: a Victorian iron-and-glass market hall, its glass gable to the yard, a clerestory on top
local TOP = shell2({ H = H, ridge = "z", roof = "gable", rise = 28, roofStyle = st(M.Metal, nil, C3(70, 96, 86)),
	front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 }, win = { w = 6, b = 5, t = 13 }, postStyle = IRONG })
local inn = model(STR, "Interior")
local I = INT()
-- the cold room's wall (z = -32), two doorways
wall(inn, "ColdWall", "x", -32, -78, 78, F1, H, { dr(-30, 10, 12), dr(30, 10, 12) }, I)

-- the tiles: a green checker over the white floor
local fl = model(DEC, "Tiles")
for x = -76, 72, 8 do
	for z = -30, 54, 8 do
		if ((x + z) / 8) % 2 == 0 then box(fl, "Tile", x, F1 + 0.02, z, x + 8, F1 + 0.05, z + 8, HARB.tileD, DECO) end
	end
end
-- THE FISH SLABS: stone counters with ice and fish, in rows
local slabs = model(STR, "Slabs")
for _, p in { { -50, 30 }, { -50, 4 }, { 50, 30 }, { 50, 4 }, { -18, 40 }, { 18, 40 }, { -18, -12 }, { 18, -12 } } do
	box(slabs, "Slab", p[1] - 9, F1, p[2] - 3, p[1] + 9, F1 + 3.4, p[2] + 3, HARB.stone)
	box(DEC, "Ice", p[1] - 8.6, F1 + 3.4, p[2] - 2.6, p[1] + 8.6, F1 + 3.7, p[2] + 2.6, HARB.ice, DECO)
	for k = 0, 4 do
		harbFishCrate(DEC, CFrame.new(p[1] - 7 + k * 3.5, F1 + 3.4, p[2]) * CFrame.Angles(0, rng:NextNumber(-0.3, 0.3), 0), rng)
	end
	-- a price board on a stick
	cyl(DEC, CFrame.new(p[1] + 8, F1 + 5, p[2] + 2.6), "Stick", 0.2, 3, 0, 0, 0, HARB.beam, D())
	box(DEC, "PriceBoard", p[1] + 7, F1 + 6.2, p[2] + 2.5, p[1] + 9, F1 + 7.4, p[2] + 2.7, HARB.white, DECO)
end
-- the stalls' canvas awnings over the side slabs, stripes
for _, x in { -50, 50 } do
	for _, z in { 30, 4 } do
		for k = 0, 5 do
			box(DEC, "Awning", x - 10 + k * 3.4, F1 + 11, z - 4, x - 10 + (k + 1) * 3.4, F1 + 11.4, z + 4, k % 2 == 0 and HARB.red or HARB.white, DECO)
		end
		for _, dx in { -10, 10 } do cyl(DEC, CFrame.new(x + dx, F1 + 5.5, z + 4), "AwningPole", 0.4, 11, 0, 0, 0, HARB.beam, D()) end
	end
end
-- fish hanging on hooks from rails under the roof
for _, z in { 22, -4 } do
	box(DEC, "HookRail", -30, F1 + 15, z - 0.2, 30, F1 + 15.4, z + 0.2, HARB.iron, DECO)
	for x = -28, 28, 4 do
		box(DEC, "HookLine", x - 0.05, F1 + 12.5, z - 0.05, x + 0.05, F1 + 15, z + 0.05, HARB.iron, DECO)
		box(DEC, "HangFish", x - 0.4, F1 + 9.6, z - 0.25, x + 0.4, F1 + 12.5, z + 0.25, st(M.SmoothPlastic, nil, ({ C3(140, 150, 160), C3(170, 130, 110), C3(110, 130, 120) })[rng:NextInteger(1, 3)]), DECO)
	end
end
-- THE DRAIN in the middle of the hall: a black grate over dark water, wet tiles round it
local dr0 = model(DEC, "Drain")
cyl(dr0, CFrame.new(0, F1 + 0.04, 18), "DrainWater", 9, 0.06, 0, 0, 0, HARB.water, D())
for k = -3, 3 do box(dr0, "Grate", k * 1.2 - 0.15, F1 + 0.06, 13.6, k * 1.2 + 0.15, F1 + 0.12, 22.4, HARB.iron, DECO) end
cyl(dr0, CFrame.new(0, F1 + 0.03, 18), "Wet", 18, 0.03, 0, 0, 0, st(M.Glass, nil, C3(60, 90, 90)), { deco = true, t = 0.5 })
-- scales, ice boxes, carts by the walls
for _, p in { { -72, 46 }, { 72, 46 }, { -72, -20 }, { 72, -20 } } do
	box(STR, "IceBox", p[1] - 3, F1, p[2] - 2.5, p[1] + 3, F1 + 4, p[2] + 2.5, HARB.white)
	box(DEC, "IceBoxLid", p[1] - 3.2, F1 + 4, p[2] - 2.7, p[1] + 3.2, F1 + 4.4, p[2] + 2.7, HARB.navy, DECO)
end
for _, p in { { -34, 50 }, { 34, 50 } } do
	cyl(DEC, CFrame.new(p[1], F1 + 2.5, p[2]), "ScalePost", 0.4, 5, 0, 0, 0, HARB.iron, D())
	cyl(DEC, CFrame.new(p[1], F1 + 5.2, p[2]) * CFrame.Angles(math.pi / 2, 0, 0), "ScaleDial", 1.8, 0.3, 0, 0, 0, HARB.white, D())
	box(DEC, "ScalePan", p[1] - 1.4, F1 + 3.5, p[2] - 1.4, p[1] + 1.4, F1 + 3.7, p[2] + 1.4, HARB.iron, DECO)
end
-- THE COLD ROOM (behind the wall): stacked ice crates, more fish on hooks
for _, p in { { -60, -46 }, { -44, -50 }, { 0, -50 }, { 16, -44 }, { 40, -52 } } do
	box(STR, "IceCrate", p[1] - 3, F1, p[2] - 3, p[1] + 3, F1 + 5, p[2] + 3, HARB.plankD)
	box(DEC, "IceTop", p[1] - 2.8, F1 + 5, p[2] - 2.8, p[1] + 2.8, F1 + 5.6, p[2] + 2.8, HARB.ice, DECO)
end
for x = -70, 40, 6 do
	box(DEC, "ColdHook", x - 0.05, F1 + 11, -40.05, x + 0.05, F1 + 14, -39.95, HARB.iron, DECO)
	box(DEC, "ColdFish", x - 0.5, F1 + 8, -40.3, x + 0.5, F1 + 11, -39.7, st(M.SmoothPlastic, nil, C3(140, 150, 160)), DECO)
end
-- THE STASH behind the rusty ice locker (x 50..78, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", 49, F1, -58, 50.2, F1 + 12, -42, HARB.sidingD)
box(sr, "Wall", 50.2, F1, -43.2, 60, F1 + 12, -42, HARB.sidingD)
box(sr, "Wall", 66, F1, -43.2, 78, F1 + 12, -42, HARB.sidingD)
box(sr, "Lintel", 60, F1 + 9, -43.2, 66, F1 + 12, -42, HARB.sidingD)
box(sr, "Ceiling", 49, F1 + 12, -58, 78, F1 + 12.6, -42, HARB.beam)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "IceLocker")
door:SetAttribute("Slide", Vector3.new(-6.4, 0, 0)); door:SetAttribute("Action", "Pull"); door:SetAttribute("Object", "Rusty ice locker")
box(door, "Panel", 60, F1, -42.9, 66, F1 + 9, -40.6, HARB.rust)
box(door, "Panel", 60.4, F1 + 6.5, -40.65, 65.6, F1 + 7, -40.4, HARB.iron, DECO)
box(door, "Trigger", 62.5, F1 + 4, -39.6, 63.5, F1 + 5, -38.6, HARB.rust, { deco = true, t = 1 })
-- (the clue: scrape marks on the tiles in front of it)
for k = 0, 3 do box(DEC, "Scrape", 59 - k * 1.4, F1 + 0.06, -40 + k * 0.2, 60 - k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(120, 110, 96)), DECO) end
local loot = model(DEC, "Stash")
for k = 0, 3 do harbFishCrate(loot, CFrame.new(54 + k * 5, F1, -55) * CFrame.Angles(0, rng:NextNumber(-0.4, 0.4), 0), rng) end
harbCoil(loot, Vector3.new(72, F1, -48))
local sg = b(loot, CFrame.new(64, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, HARB.lamp, { deco = true, t = 1 })
light(sg, 18, 1, C3(150, 220, 230))

-- lights: hanging lamps over the slabs, cold blue in the cold room
for _, p in { { -50, 17 }, { 50, 17 }, { -18, 14 }, { 18, 14 }, { 0, 44 }, { 0, -2 } } do bulb(p[1], F1 + H - 1, p[2], 4, C3(255, 220, 170)) end
for _, p in { { -40, -46 }, { 20, -46 } } do bulb(p[1], F1 + H - 1, p[2], 3, C3(170, 220, 255)) end
for _, p in { { -10, 30 }, { 30, -20 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 44 }, { 40, 44 }, { 0, 30 }, { -30, -10 }, { 30, -10 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-6, 12, 6, 24, F1) -- (the drain)
keepClear(56, -42, 70, -34, F1) -- (in front of the ice locker)
-- OUTSIDE (2026-11-19): THE FISH MARKET. Brick walls under a green iron roof; the front gable is a great FAN WINDOW of
-- glass and iron with the market clock over it; a glazed CLERESTORY runs along the ridge; an iron ARCADE of columns
-- and arches covers the stalls along the front (ice, fish on slabs, a scale, the price board); gulls on the ridge.
local OUT = model(DEC, "Outside")
local GLASSG = st(M.Glass, nil, C3(150, 190, 170))
-- the fan window: glass rays round a hub over the door, iron spokes, a rim, a glow behind
local HUB, FR = Vector3.new(0, TOP + 1, 60.3), 24
local rim = {}
for k = 0, 10 do local a = math.pi * k / 10; table.insert(rim, HUB + Vector3.new(FR * math.cos(a), FR * math.sin(a), 0)) end
for k = 1, #rim - 1 do
	tri(OUT, "FanGlass", HUB, rim[k], rim[k + 1], GLASSG, 0.3, { deco = true, t = 0.35 })
	part(OUT, "FanSpoke", Vector3.new(0.6, 0.6, FR), CFrame.lookAt((HUB + rim[k]) / 2 + Vector3.new(0, 0, 0.3), rim[k] + Vector3.new(0, 0, 0.3)), IRONG, D())
	part(OUT, "FanRim", Vector3.new(0.8, 0.8, (rim[k + 1] - rim[k]).Magnitude + 0.4), CFrame.lookAt((rim[k] + rim[k + 1]) / 2 + Vector3.new(0, 0, 0.3), rim[k + 1] + Vector3.new(0, 0, 0.3)), IRONG, D())
end
box(OUT, "FanSill", -FR - 1, TOP - 0.6, 60, FR + 1, TOP + 1, 61.2, IRONG, DECO)
light(box(OUT, "FanGlow", -0.1, TOP + 10, 57, 0.1, TOP + 10.2, 57.2, GLASSG, { deco = true, t = 1 }), 40, 1.2, C3(190, 230, 210))
-- the clock at the gable's top
cyl(OUT, CFrame.new(0, TOP + 27.6, 60.6) * CFrame.Angles(math.pi / 2, 0, 0), "ClockFace", 6, 0.4, 0, 0, 0, st(M.Neon, nil, C3(240, 232, 200)), D())
cyl(OUT, CFrame.new(0, TOP + 27.6, 60.4) * CFrame.Angles(math.pi / 2, 0, 0), "ClockRim", 7, 0.4, 0, 0, 0, IRONG, D())
box(OUT, "Hand", -0.15, TOP + 27.6, 60.9, 0.15, TOP + 30, 61.1, HARB.black, DECO)
box(OUT, "Hand", 0, TOP + 27.45, 60.9, 1.8, TOP + 27.75, 61.1, HARB.black, DECO)
-- the clerestory along the ridge: glazed sides, its own little roof
do
	local y0 = TOP + 18
	for _, sx in { -1, 1 } do
		box(OUT, "ClerestoryWall", sx * 9 - 0.4, y0, -56, sx * 9 + 0.4, y0 + 9, 56, IRONG, DECO)
		for z = -52, 52, 8 do box(OUT, "ClerestoryGlass", sx * 9 - 0.5, y0 + 2, z - 3, sx * 9 + 0.5, y0 + 8, z + 3, st(M.Neon, nil, C3(170, 210, 190)), { deco = true, t = 0.4 }) end
	end
	extrude(OUT, -57, 57, { { -11, y0 + 9 }, { 0, y0 + 14 }, { 11, y0 + 9 } }, st(M.Metal, nil, C3(70, 96, 86)), { axis = "z", ends = IRONG, th = 0.8, over = 0, panelO = D(), endParent = OUT })
end
-- THE ARCADE along the front: iron columns, arches between them, a glass roof sloping out, stalls underneath
local AZ = 69
for x = -72, 72, 12 do
	if math.abs(x) > 8 then cyl(OUT, CFrame.new(x, 9, AZ), "Column", 1.4, 16, 0, 0, 0, IRONG, D()) end
	cyl(OUT, CFrame.new(x, 1.1, AZ), "ColumnFoot", 2.2, 2.2, 0, 0, 0, IRONG, D())
	if x < 72 then
		for _, half in { { x, x + 6 }, { x + 12, x + 6 } } do
			local a, z = Vector3.new(half[1], 15, AZ), Vector3.new(half[2], 17.4, AZ)
			part(OUT, "Arch", Vector3.new(0.6, 0.6, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), IRONG, D())
		end
	end
end
box(OUT, "ArcadeBeam", -73, 17.4, AZ - 0.5, 73, 18.4, AZ + 0.5, IRONG, DECO)
panel(OUT, "ArcadeRoof", Vector3.new(0, 20, 60.4), Vector3.new(0, 18.4, AZ + 0.6), Vector3.new(1, 0, 0), 146, GLASSG, 0.3, { deco = true, t = 0.45 })
harbSign("THE FISH MARKET", CFrame.new(0, 20.6, AZ + 0.6))
for _, sx in { -1, 1 } do
	for k = 0, 2 do
		local x = sx * (22 + k * 16)
		box(OUT, "StallSlab", x - 5, 0, 62, x + 5, 3, 66, HARB.stone, DECO)
		box(OUT, "Ice", x - 4.6, 3, 62.4, x + 4.6, 3.6, 65.6, HARB.ice, DECO)
		for f = 0, 3 do
			local fc = CFrame.new(x - 3.4 + f * 2.3, 3.9, 64) * CFrame.Angles(0, 0.2 * f, 0)
			b(OUT, fc, "Fish", 0.8, 0.6, 3, 0, 0, 0, st(M.SmoothPlastic, nil, ({ C3(150, 160, 170), C3(180, 120, 90), C3(120, 140, 130) })[f % 3 + 1]), D())
		end
	end
end
-- a hanging scale and the price board
box(OUT, "ScaleHook", 8.8, 13, AZ - 0.2, 9.2, 17.4, AZ + 0.2, HARB.iron, DECO)
cyl(OUT, CFrame.new(9, 12, AZ), "ScaleDial", 2.2, 0.6, 0, 0, 0, st(M.SmoothPlastic, nil, C3(220, 214, 196)), D())
box(OUT, "ScalePan", 7.4, 9, AZ - 1.6, 10.6, 9.4, AZ + 1.6, HARB.iron, DECO)
sign(OUT, "TODAY: COD - EEL - CRAB - ???", CFrame.new(-60, 10, 60.6) * CFrame.Angles(0, math.pi, 0), 14, 3, st(M.Slate, nil, C3(30, 34, 30)), C3(230, 230, 220), Enum.Font.SpecialElite)
-- gulls along the ridge
for k, z in { 50, 20, -10, -40 } do
	local cf = CFrame.new(((k % 2 == 0) and 0.8 or -0.8), TOP + 33, z) * CFrame.Angles(0, k * 1.3, 0)
	b(OUT, cf, "Gull", 0.9, 0.9, 2, 0, 0, 0, HARB.white, D())
	b(OUT, cf, "GullHead", 0.6, 0.6, 0.6, 0, 0.6, -0.9, HARB.white, D())
end
washLight(-30, 86, Vector3.new(-14, TOP + 10, 60), C3(180, 220, 210), 90, 2)
washLight(30, 86, Vector3.new(14, TOP + 10, 60), C3(180, 220, 210), 90, 2)
harbGrounds()
return endMap()
