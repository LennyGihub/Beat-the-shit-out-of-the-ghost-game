-- THE BELL TOWER (the Ashen Abbey, building 3: THE BELL RINGER, who drops bells on you and tolls rings along the floor).
-- The tower's bell chamber, very high: a frame of heavy oak beams, GREAT BRONZE BELLS hanging in it high overhead,
-- their ropes hanging down to the floor (and tied off at cleats), a big wheel, a timber stair up the side wall to a
-- landing (decoration), sacks and crates, pigeons' mess, the clock's works on the back wall. Low walls of stacked
-- crates and a fallen beam are the only cover. At the back, behind a wall with two doorways: the RINGER'S ROOM (his
-- straw bed, a table, bell ropes coiled). Its west end: a WOODEN PANEL that slides (Secrets: the stash behind it).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_belfry.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 34
local rng = Random.new(43)
beginMap("Abb_Belfry", abbTheme({ floor = ABB.plank, floor2 = ABB.plank }))
shell({ two = false, H = H, roof = "gable", pitch = 0.7, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 4, winB = 16, winT = 28 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "RoomWall", "x", -32, -78, 78, F1, 16, { dr(-30, 10, 12), dr(30, 10, 12) }, I)

-- THE BELL FRAME: oak posts and beams high up
local frame = model(DEC, "BellFrame")
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do box(frame, "Post", x - 1.2, F1, z - 1.2, x + 1.2, F1 + H - 2, z + 1.2, ABB.beam, DECO) end
	box(frame, "Beam", x - 1.2, F1 + 26, -6, x + 1.2, F1 + 28, 38, ABB.beam, DECO)
end
for _, z in { -6, 38 } do box(frame, "Beam", -49, F1 + 26, z - 1.2, 49, F1 + 28, z + 1.2, ABB.beam, DECO) end
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do
		part(frame, "Brace", Vector3.new(0.8, 8, 0.8), CFrame.new(x + 2.4, F1 + 23, z) * CFrame.Angles(0, 0, -0.6), ABB.beam, DECO)
		part(frame, "Brace", Vector3.new(0.8, 8, 0.8), CFrame.new(x - 2.4, F1 + 23, z) * CFrame.Angles(0, 0, 0.6), ABB.beam, DECO)
	end
end
-- the posts are solid (cover)
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do box(STR, "PostCore", x - 1, F1, z - 1, x + 1, F1 + 14, z + 1, ABB.beam) end
end
-- THE GREAT BELLS hanging from the frame (stacked bronze rings), each with its wheel and rope down to the floor
local function bell(x: number, z: number, r: number)
	local m = model(DEC, "GreatBell")
	local top = F1 + 25
	local rows = { { 0.6, 1.0 }, { 0.68, 1.4 }, { 0.78, 1.4 }, { 0.9, 1.4 }, { 1.0, 0.9 } }
	local y = top
	for _, row in rows do
		cyl(m, CFrame.new(x, y - row[2] / 2, z), "Bronze", r * 2 * row[1], row[2], 0, 0, 0, ABB.bronze, D())
		y -= row[2]
	end
	cyl(m, CFrame.new(x, y + 0.3, z), "Lip", r * 2.06, 0.5, 0, 0, 0, st(M.Metal, nil, C3(140, 96, 44)), D())
	ball(m, CFrame.new(x, y + 0.3, z), "Clapper", 1.4, 0, 0, 0, ABB.iron, D())
	cyl(m, CFrame.new(x, top + 1.4, z) * CFrame.Angles(0, 0, -math.pi / 2), "Wheel", 7, 0.5, 0, 0, 0, ABB.beam, D())
	box(m, "Yoke", x - 1, top, z - 4, x + 1, top + 1.6, z + 4, ABB.beam, DECO)
	box(m, "Rope", x - 0.12, F1, z + 3.4, x + 0.12, top + 1, z + 3.64, ABB.cloth, DECO)
	box(m, "Sally", x - 0.35, F1 + 5, z + 3.15, x + 0.35, F1 + 7, z + 3.85, ABB.red, DECO)
	cyl(m, CFrame.new(x, F1 + 0.3, z + 3.5), "RopeCoil", 2, 0.5, 0, 0, 0, ABB.cloth, D())
end
bell(-32, 16, 6); bell(0, 16, 8); bell(32, 16, 6); bell(-32, 44, 4); bell(32, 44, 4)
-- the timber stair up the left wall to a landing (decoration: the floor is the fight)
for k = 0, 11 do box(DEC, "Tread", -77, F1 + k * 1.2, 30 - k * 2.2, -71, F1 + k * 1.2 + 0.4, 28 - k * 2.2, ABB.plank, DECO) end
box(DEC, "Landing", -77.5, F1 + 14, -12, -64, F1 + 14.6, 4, ABB.plank, DECO)
for z = -12, 4, 4 do box(DEC, "Rail", -64.4, F1 + 14.6, z - 0.15, -64, F1 + 18, z + 0.15, ABB.beam, DECO) end
box(DEC, "RailTop", -64.6, F1 + 18, -12, -63.8, F1 + 18.4, 4, ABB.beam, DECO)
-- the clock's works on the back wall: a great wheel of gears
for k = 0, 4 do
	cyl(DEC, CFrame.new(-6 + k * 3, F1 + 20 + (k % 2) * 2, -30.8) * CFrame.Angles(math.pi / 2, 0, 0), "Gear", 3 + (k % 3) * 1.5, 0.5, 0, 0, 0, ABB.bronze, D())
end
-- cover on the floor: crate walls, a fallen beam, sacks
local cover = model(STR, "Cover")
for _, p in { { -46, 52 }, { 46, 52 }, { -60, 10 }, { 60, 24 }, { -14, 0 }, { 14, 30 } } do
	box(cover, "Crates", p[1] - 3, F1, p[2] - 2, p[1] + 3, F1 + 5, p[2] + 2, ABB.plank)
	box(DEC, "CrateTop", p[1] - 2.5, F1 + 5, p[2] - 1.5, p[1] + 0.5, F1 + 7.5, p[2] + 1.5, ABB.plank, DECO)
end
part(cover, "FallenBeam", Vector3.new(2.4, 2.4, 22), CFrame.new(-2, F1 + 1.2, 46) * CFrame.Angles(0, 1.2, 0.1), ABB.beam)
for k = 0, 5 do part(DEC, "Sack", Vector3.new(2.2, 1.4, 1.6), CFrame.new(66 + (k % 3) * 2.4, F1 + 0.7 + math.floor(k / 3) * 1.3, -12) * CFrame.Angles(0, rng:NextNumber(-0.3, 0.3), 0), ABB.cloth, DECO) end
-- pigeons' mess and feathers on the floor
for k = 0, 30 do
	local x, z = rng:NextNumber(-74, 74), rng:NextNumber(-26, 56)
	part(DEC, "Spot", Vector3.new(0.6, 0.04, 0.6), CFrame.new(x, F1 + 0.03, z) * CFrame.Angles(0, rng:NextNumber(0, 6), 0), st(M.SmoothPlastic, nil, C3(190, 186, 176)), DECO)
	local _ = k
end
-- THE RINGER'S ROOM (behind the wall): a straw bed, a table, coiled ropes
box(STR, "Bed", -64, F1, -56, -52, F1 + 1.4, -48, ABB.cloth)
part(DEC, "Straw", Vector3.new(11, 0.6, 7), CFrame.new(-58, F1 + 1.7, -52), st(M.Grass, nil, C3(190, 160, 90)), DECO)
box(STR, "Table", -10, F1, -52, 8, F1 + 3.2, -46, ABB.beam)
cyl(DEC, CFrame.new(-4, F1 + 3.6, -49), "Bowl", 1.6, 0.6, 0, 0, 0, ABB.plank, D())
for _, x in { 20, 28 } do for k = 0, 2 do cyl(DEC, CFrame.new(x, F1 + 0.25 + k * 0.4, -52), "Coil", 3.2 - k * 0.5, 0.4, 0, 0, 0, ABB.cloth, D()) end end
-- THE STASH behind the wooden panel (x -78..-58, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", -58.2, F1, -58, -57, F1 + 12, -42, ABB.beam)
box(sr, "Wall", -78, F1, -43.2, -70, F1 + 12, -42, ABB.beam)
box(sr, "Wall", -64, F1, -43.2, -58.2, F1 + 12, -42, ABB.beam)
box(sr, "Lintel", -70, F1 + 9, -43.2, -64, F1 + 12, -42, ABB.beam)
box(sr, "Ceiling", -78, F1 + 12, -58, -57, F1 + 12.6, -42, ABB.beam)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "WoodPanel")
door:SetAttribute("Slide", Vector3.new(6.4, 0, 0)); door:SetAttribute("Action", "Slide"); door:SetAttribute("Object", "Loose wooden panel")
box(door, "Panel", -70, F1, -42.9, -64, F1 + 9, -40.6, ABB.plank)
for y = 1, 8, 2.4 do box(door, "Panel", -69.8, F1 + y, -40.65, -64.2, F1 + y + 0.3, -40.4, ABB.beam, DECO) end
box(door, "Trigger", -67.5, F1 + 4, -39.6, -66.5, F1 + 5, -38.6, ABB.plank, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", -63 + k * 1.4, F1 + 0.06, -40 + k * 0.2, -62 + k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(150, 130, 100)), DECO) end
local loot = model(DEC, "Stash")
abbCandles(loot, Vector3.new(-74, F1, -54), rng, 5)
for k = 0, 2 do cyl(loot, CFrame.new(-66 + k * 3, F1 + 0.8, -55), "HandBell", 1.4, 1.6, 0, 0, 0, ABB.bronze, D()) end

-- lights: lanterns on the posts, a red glow through the louvres
for _, x in { -48, -16, 16, 48 } do
	for _, z in { -6, 38 } do abbLantern(LIT, Vector3.new(x, F1 + 10, z + (z < 10 and 1.6 or -1.6)), 26) end
end
for _, p in { { -30, -46 }, { 30, -46 } } do bulb(p[1], F1 + 15, p[2], 2, C3(255, 180, 110)) end
for _, p in { { -20, 20 }, { 40, 0 }, { -40, -50 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 52 }, { 40, 52 }, { 0, 30 }, { -30, 0 }, { 30, 0 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-62, -42, -54, -34, F1)
abbSign("THE BELL TOWER")
abbGrounds()
return endMap()
