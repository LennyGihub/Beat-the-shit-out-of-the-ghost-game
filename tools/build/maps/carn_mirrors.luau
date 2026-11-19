-- THE HALL OF MIRRORS (the Moonlight Carnival, building 2: MADAME FORTUNE, whose orb curses you until her crystal
-- ball is smashed). The front: the ticket hall. The middle: the MIRROR MAZE (mirror panels on a 12-stud grid, a
-- seeded maze with extra openings - every panel is Interior: monsters crash through and break them; they also stop
-- her orb and her cards). The back: her PARLOUR (drapes, candles, tarot posters, a huge painted eye) with the
-- CRYSTAL BALL on its table (part CrystalBall: the prompt to smash it is put on it by Server/CarnivalMonsters).
-- The SECRET: a cracked mirror on the parlour's east wall swings away - her stash behind it.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_mirrors.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local MIRROR = st(M.Glass, nil, C3(196, 206, 220))
local FRAME = st(M.Metal, nil, C3(150, 120, 60))
local DRAPE = st(M.Fabric, nil, C3(70, 20, 80))
beginMap("Carn_Mirrors", carnTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(60, 30, 80)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(70, 40, 76)), wain = true }))
shell({ two = false, H = H, roof = "gable", pitch = 0.45, front1 = { -60, -36, 36, 60 }, back1 = {}, left1 = { 44 }, right1 = { 44 }, winW = 6, winB = 5, winT = 13 })
carnFrieze(H)
local inn = model(STR, "Interior")
local I = INT()

-- the ticket hall / maze wall (z 40), the parlour wall (z -22) with its arch
wall(inn, "MazeFront", "x", 40, -78, 78, F1, H, { dr(0, 10, 12), dr(-48, 8, 12), dr(48, 8, 12) }, I)
wall(inn, "ParlourWall", "x", -22, -78, 78, F1, H, { dr(0, 12, 13) }, I)

-- THE MIRROR MAZE: cells 12 x 12 over x -72..72, z -22..40 (12 x 5 cells); a maze carved by a seeded walk, then a
-- third of the remaining walls taken out so it is a maze to fight in, not to get lost in
local mz = model(inn, "MirrorMaze")
local cx, cz = 12, 5
local X0, Z0, S = -72, -22, 12.4
local rng = Random.new(7)
local open = {} :: { [string]: boolean }
local seen = {} :: { [string]: boolean }
local function key(a, b2) return a .. "," .. b2 end
local stack = { { 1, 1 } }
seen[key(1, 1)] = true
while #stack > 0 do
	local c = stack[#stack]
	local nb = {}
	for _, d in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
		local nx, nz = c[1] + d[1], c[2] + d[2]
		if nx >= 1 and nx <= cx and nz >= 1 and nz <= cz and not seen[key(nx, nz)] then table.insert(nb, { nx, nz }) end
	end
	if #nb == 0 then
		table.remove(stack)
	else
		local n = nb[rng:NextInteger(1, #nb)]
		open[key(c[1], c[2]) .. ">" .. key(n[1], n[2])] = true
		open[key(n[1], n[2]) .. ">" .. key(c[1], c[2])] = true
		seen[key(n[1], n[2])] = true
		table.insert(stack, n)
	end
end
local function panel(x1, z1, x2, z2)
	local p = box(mz, "Mirror", x1, F1, z1, x2, F1 + 11, z2, MIRROR)
	p.Reflectance = 0.7
	box(mz, "MirrorTop", x1 - 0.05, F1 + 11, z1 - 0.05, x2 + 0.05, F1 + 11.5, z2 + 0.05, FRAME, DECO)
	box(mz, "MirrorFoot", x1 - 0.05, F1, z1 - 0.05, x2 + 0.05, F1 + 0.6, z2 + 0.05, FRAME, DECO)
end
local nPanels = 0
for i = 1, cx do
	for j = 1, cz do
		local x, z = X0 + (i - 1) * S, Z0 + (j - 1) * S
		-- the east side of the cell
		if i < cx and not open[key(i, j) .. ">" .. key(i + 1, j)] and rng:NextNumber() > 0.33 then
			panel(x + S - 0.3, z + 0.6, x + S + 0.3, z + S - 0.6); nPanels += 1
		end
		-- the north side of the cell
		if j < cz and not open[key(i, j) .. ">" .. key(i, j + 1)] and rng:NextNumber() > 0.33 then
			panel(x + 0.6, z + S - 0.3, x + S - 0.6, z + S + 0.3); nPanels += 1
		end
	end
end
-- tall mirror pillars at some corners
for i = 2, cx - 1, 3 do
	for j = 2, cz - 1, 2 do
		local p = box(mz, "MirrorPillar", X0 + (i - 1) * S - 1, F1, Z0 + (j - 1) * S - 1, X0 + (i - 1) * S + 1, F1 + 14, Z0 + (j - 1) * S + 1, MIRROR)
		p.Reflectance = 0.8
	end
end
-- the maze's floor: dark and light diamonds, a few warped mirrors leaning on the outer walls
local fl = model(DEC, "MazeFloor")
for x = -72, 66, 12 do
	for z = -20, 34, 12 do
		if ((x + z) / 12) % 2 == 0 then box(fl, "Tile", x, F1 + 0.02, z, x + 12, F1 + 0.06, z + 12, st(M.SmoothPlastic, nil, C3(36, 20, 44)), DECO) end
	end
end
for _, z in { -10, 14, 30 } do
	for _, side in { -1, 1 } do
		local p = b(DEC, CFrame.new(side * 77.4, F1 + 6, z) * CFrame.Angles(0, 0, side * 0.08), "Warped", 0.4, 10, 5, 0, 0, 0, MIRROR, D())
		p.Reflectance = 0.9
	end
end

-- THE TICKET HALL (z 40..58): a booth, velvet ropes, the sign
local th = model(STR, "TicketHall")
box(th, "Booth", -30, F1, 44, -18, F1 + 4, 50, CARN.velvet)
box(th, "BoothTop", -30.4, F1 + 4, 43.6, -17.6, F1 + 4.4, 50.4, CARN.gold)
for _, x in { -6, 6 } do
	for z = 42, 54, 6 do cyl(DEC, CFrame.new(x, F1 + 1.6, z), "RopePost", 0.4, 3.2, 0, 0, 0, CARN.gold, D()) end
	box(DEC, "VelvetRope", x - 0.1, F1 + 2.8, 42, x + 0.1, F1 + 3.1, 54, CARN.velvet, DECO)
end
sign(DEC, "HALL OF MIRRORS", CFrame.new(0, F1 + 15, 40.6), 26, 4, CARN.velvet, C3(220, 200, 255), Enum.Font.Creepster)

-- MADAME FORTUNE'S PARLOUR (z -58..-22)
local pl = model(STR, "Parlour")
-- drapes all round, a huge painted eye on the back wall
for x = -76, 72, 4 do box(DEC, "Drape", x, F1, -57.8, x + 4, F1 + H - 1, -57.4, (x / 4) % 2 == 0 and DRAPE or st(M.Fabric, nil, C3(50, 14, 60)), DECO) end
local eye = model(DEC, "PaintedEye")
local ecf = CFrame.new(0, F1 + 13, -57.2)
b(eye, ecf, "EyeWhite", 16, 7, 0.1, 0, 0, 0, st(M.SmoothPlastic, nil, C3(220, 210, 230)), DECO)
b(eye, ecf, "Iris", 5.5, 5.5, 0.12, 0, 0, -0.05, st(M.Neon, nil, C3(150, 60, 220)), DECO)
b(eye, ecf, "Pupil", 2.2, 2.6, 0.14, 0, 0, -0.1, st(M.SmoothPlastic, nil, C3(10, 6, 14)), DECO)
for _, sy in { -1, 1 } do b(eye, ecf * CFrame.Angles(0, 0, sy * 0.25), "Lid", 17, 0.6, 0.16, 0, sy * 3.4, -0.08, CARN.gold, DECO) end
-- the round rug, the table, THE CRYSTAL BALL
cyl(DEC, CFrame.new(0, F1 + 0.05, -40), "Rug", 22, 0.1, 0, 0, 0, st(M.Fabric, nil, C3(90, 20, 50)), D())
cyl(DEC, CFrame.new(0, F1 + 0.08, -40), "RugRing", 18, 0.1, 0, 0, 0, st(M.Fabric, nil, C3(150, 100, 40)), D())
cyl(pl, CFrame.new(0, F1 + 1.6, -40), "TableLeg", 1.2, 3.2, 0, 0, 0, CARN.woodD)
cyl(pl, CFrame.new(0, F1 + 3.3, -40), "Table", 6, 0.3, 0, 0, 0, CARN.woodD)
cyl(DEC, CFrame.new(0, F1 + 2.4, -40), "Cloth", 6.4, 1.8, 0, 0, 0, st(M.Fabric, nil, C3(110, 36, 120)), D())
cyl(DEC, CFrame.new(0, F1 + 3.65, -40), "BallStand", 1.6, 0.6, 0, 0, 0, CARN.gold, D())
local cb = ball(DEC, CFrame.new(0, F1 + 4.95, -40), "CrystalBall", 2.2, 0, 0, 0, st(M.Glass, nil, C3(200, 160, 255)), { deco = true, t = 0.15 })
local cbl = light(cb, 20, 1.6, C3(190, 120, 255))
local _ = cbl
ball(cb, CFrame.new(0, F1 + 4.95, -40), "BallCore", 0.8, 0, 0, 0, st(M.Neon, nil, C3(190, 100, 255)), D()) -- (inside the ball: it goes with it)
for _, a in { 0, 2.1, 4.2 } do F.chair(CFrame.new(math.cos(a) * 6, F1, -40 + math.sin(a) * 6) * CFrame.Angles(0, -a - math.pi / 2, 0), Wd.dark, Fab.red) end
-- tarot posters, candles on stands, a bookshelf of old books, palm reading booths at the sides
for i, x in { -54, -36, 36, 54 } do
	local cf = CFrame.new(x, F1 + 9, -57.1)
	b(DEC, cf, "TarotFrame", 4.4, 7, 0.2, 0, 0, 0, CARN.gold, D())
	b(DEC, cf, "TarotCard", 3.8, 6.4, 0.1, 0, 0, -0.1, st(M.SmoothPlastic, nil, ({ C3(200, 60, 60), C3(60, 80, 200), C3(220, 180, 60), C3(60, 150, 90) })[i]), D())
	b(DEC, cf, "TarotSymbol", 1.6, 1.6, 0.1, 0, 0.6, -0.16, st(M.Neon, nil, C3(250, 230, 200)), D()).CFrame = cf * CFrame.new(0, 0.6, -0.16) * CFrame.Angles(0, 0, math.pi / 4)
end
for _, p in { { -14, -30 }, { 14, -30 }, { -20, -50 }, { 20, -50 } } do
	cyl(DEC, CFrame.new(p[1], F1 + 2, p[2]), "CandleStand", 0.5, 4, 0, 0, 0, CARN.gold, D())
	cyl(DEC, CFrame.new(p[1], F1 + 4.6, p[2]), "Candle", 0.5, 1.2, 0, 0, 0, st(M.SmoothPlastic, nil, C3(230, 220, 200)), D())
	local fl2 = ball(DEC, CFrame.new(p[1], F1 + 5.45, p[2]), "Flame", 0.35, 0, 0, 0, st(M.Neon, nil, C3(255, 170, 70)), D())
	light(fl2, 14, 0.7, C3(255, 160, 80))
end
F.bookshelf(at(-40, F1, -55, "S"), 8, 10)
for _, x in { -62, 62 } do
	box(pl, "Booth", x - 6, F1, -36, x + 6, F1 + 3, -34, CARN.woodD)
	box(DEC, "BoothCurtain", x - 6, F1 + 3, -35.2, x + 6, F1 + 12, -34.8, DRAPE, DECO)
end
-- beads hanging in the arch
for k = 0, 11 do box(DEC, "Beads", -5.5 + k, F1 + 3, -22.05, -5.4 + k, F1 + 13, -21.95, st(M.SmoothPlastic, nil, k % 2 == 0 and C3(200, 160, 255) or C3(220, 180, 70)), DECO) end

-- THE SECRET: her stash in the parlour's east end (x 62..78, z -58..-40), behind a cracked mirror that swings away
local sr = model(STR, "Stash")
local SH = 12
box(sr, "Wall", 61.4, F1, -58, 62.6, F1 + SH, -53, CARN.paint)
box(sr, "Wall", 61.4, F1, -49, 62.6, F1 + SH, -40, CARN.paint)
box(sr, "Lintel", 61.4, F1 + 8, -53, 62.6, F1 + SH, -49, CARN.paint)
box(sr, "Wall", 61.4, F1, -40.6, 78, F1 + SH, -39.4, CARN.paint)
box(sr, "Ceiling", 61.4, F1 + SH, -58, 78, F1 + SH + 0.6, -39.4, CARN.woodD)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "CrackedMirror")
door:SetAttribute("Slide", Vector3.new(0, 0, 4.2)); door:SetAttribute("Action", "Push"); door:SetAttribute("Object", "Cracked mirror")
local dm = box(door, "Panel", 61.5, F1, -53, 62.5, F1 + 8, -49, MIRROR)
dm.Reflectance = 0.8
box(door, "Panel", 61.4, F1 + 8, -53.1, 62.6, F1 + 8.4, -48.9, FRAME, DECO)
for k = -1, 1 do b(door, CFrame.new(61.38, F1 + 4.5 + k * 1.2, -51 + k * 0.6) * CFrame.Angles(0.6 * k + 0.4, 0, 0), "Panel", 0.05, 2.6, 0.08, 0, 0, 0, st(M.SmoothPlastic, nil, C3(30, 26, 34)), DECO) end
box(door, "Trigger", 60, F1 + 4, -51.5, 61, F1 + 5, -50.5, MIRROR, { deco = true, t = 1 })
for k = -1, 1 do box(DEC, "Scrape", 59.4 + k * 0.2, F1 + 0.03, -52.6 + k * 0.9, 61.3, F1 + 0.06, -52.4 + k * 0.9, st(M.SmoothPlastic, nil, C3(160, 130, 100)), { deco = true, t = 0.3 }) end
local props = model(DEC, "StashProps")
box(props, "Chest", 70, F1, -56, 76, F1 + 3, -52, CARN.woodD, DECO)
box(props, "ChestLid", 70, F1 + 3, -56, 76, F1 + 3.4, -52, CARN.gold, DECO)
for k = 0, 9 do cyl(props, CFrame.new(68 + (k % 4) * 1.4, F1 + 0.12 + math.floor(k / 4) * 0.2, -46 + (k % 3) * 1.1), "Coin", 0.9, 0.14, 0, 0, 0, CARN.gold, D()) end
for k = 0, 6 do b(props, CFrame.new(66 + k * 1.3, F1 + 0.05, -44) * CFrame.Angles(0, k * 0.7, 0), "Card", 1.2, 0.04, 1.8, 0, 0, 0, st(M.SmoothPlastic, nil, C3(236, 226, 196)), D()) end
local glow = b(props, CFrame.new(70, F1 + 9, -48), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
light(glow, 18, 0.9, C3(200, 140, 255))

-- lights: violet bulbs over the maze, warm ones in the halls
for _, p in { { -48, 0 }, { 0, 10 }, { 48, 0 }, { -24, 28 }, { 24, 28 } } do bulb(p[1], F1 + H - 1, p[2], 3, C3(200, 150, 255)) end
for _, x in { -40, 40 } do bulb(x, F1 + H - 1, 50, 3, C3(255, 200, 150)) end
bulb(0, F1 + H - 1, -40, 4, C3(220, 160, 255))
for _, p in { { -30, 46 }, { 36, -6 }, { -10, -46 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 20 }, { 40, -10 }, { 0, 46 }, { -50, -44 }, { 50, 30 }, { 30, -50 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-8, -30, 8, -16, F1) -- (the arch)
keepClear(-6, 34, 6, 46, F1) -- (the maze's door)
carnMarquee("HALL OF MIRRORS")
carnGrounds()
return endMap() .. " (mirror panels " .. nPanels .. ")"
