-- THE FISH MARKET (Blackwater Harbor, building 1: THE DEEP ONE, who spits ink and dives into the floor after you).
-- The hall: a white tiled floor, rows of stone FISH SLABS on ice (cover from his ink), stalls under canvas awnings,
-- fish hanging on hooks, a big DRAIN into the harbor in the middle (where he came up), scales and ice boxes. At the
-- back, behind a wall with two doorways: the COLD ROOM (crates of ice, hanging fish). Its east end: a rusty ICE
-- LOCKER that pulls away (Secrets: the stash behind it; item spot by maps/harb_items.luau).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_market.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local rng = Random.new(12)
beginMap("Harb_Market", harbTheme({ floor = HARB.tile, inner = st(M.Plaster, nil, C3(104, 118, 114)), ext = st(M.WoodPlanks, "PS2_Siding1", C3(60, 90, 96)) }))
shell({ two = false, H = H, roof = "gable", pitch = 0.4, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 6, winB = 5, winT = 13 })
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
harbSign("THE FISH MARKET")
harbGrounds()
return endMap()
