-- THE PRIZE ARCADE (the Moonlight Carnival, building 5: THE GOBLIN, the prize-booth thief, then THE GOBLIN KING).
-- Game booths down both long walls (a counter, a striped awning, shelves of prizes behind, the game on the counter:
-- ring toss, duck pond, whack-a-mole, skee-ball, balloon board, a claw machine), the PRIZE COUNTER island in the
-- middle with a giant teddy on it, the GRAND PRIZES wall at the back. The SECRET: the middle section of the grand
-- prize shelf is a door - behind it the Goblin's hoard (coins, stolen prizes; a tier-3 item from carn_items).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_prizes.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
beginMap("Carn_Prizes", carnTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(160, 110, 40)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(120, 50, 50)) }))
shell({ two = false, H = H, roof = "gable", pitch = 0.45, front1 = { -60, -36, 36, 60 }, back1 = {}, left1 = {}, right1 = {}, winW = 6, winB = 5, winT = 13 })
carnFrieze(H)
local inn = model(STR, "Interior")
local rng = Random.new(11)
local PRIZE = { C3(220, 120, 160), C3(120, 170, 230), C3(240, 200, 80), C3(140, 210, 130), C3(200, 150, 100), C3(230, 230, 220) }

-- a booth against a long wall: side = -1 (west) / 1 (east), z = its middle, kind = the game on its counter
local function booth(side: number, z: number, kind: string, n: number)
	local bm = model(STR, "Booth")
	local xIn, xWall = side * 62, side * 77.5
	local cx = (xIn + xWall) / 2
	box(bm, "Counter", math.min(xIn, xIn + side * 3), F1, z - 8, math.max(xIn, xIn + side * 3), F1 + 3.6, z + 8, n % 2 == 0 and CARN.red or CARN.blue)
	box(bm, "CounterTop", math.min(xIn, xIn + side * 3) - 0.2, F1 + 3.6, z - 8.2, math.max(xIn, xIn + side * 3) + 0.2, F1 + 4, z + 8.2, CARN.gold)
	for _, dz in { -8, 8 } do box(bm, "Post", xIn - 0.3, F1 + 4, z + dz - 0.3, xIn + 0.3, F1 + 12, z + dz + 0.3, CARN.woodD) end
	-- the awning: alternating stripes, sloping down toward the hall
	for k = 0, 7 do
		b(DEC, CFrame.new(cx, F1 + 12.6, z - 7 + k * 2) * CFrame.Angles(0, 0, side * 0.25), "Awning", 17, 0.3, 2, 0, 0, 0, k % 2 == 0 and CARN.red or CARN.canvasW, D())
	end
	-- shelves of prizes on the back wall
	for r = 0, 1 do
		box(DEC, "Shelf", side * 74.5 - 1.5, F1 + 4 + r * 3.8, z - 7, side * 74.5 + 1.5, F1 + 4.3 + r * 3.8, z + 7, CARN.woodD, DECO)
		for k = 0, 2 do
			carnTeddy(DEC, CFrame.new(side * 74.5, F1 + 4.3 + r * 3.8, z - 4.6 + k * 4.6) * CFrame.Angles(0, side < 0 and -math.pi / 2 or math.pi / 2, 0), 0.85, PRIZE[rng:NextInteger(1, #PRIZE)])
		end
	end
	-- the game
	local top = F1 + 4
	local gx = side * 63.5
	if kind == "rings" then
		for i = 0, 3 do for j = 0, 2 do cyl(DEC, CFrame.new(gx, top + 0.6, z - 5 + i * 3.3), "Peg", 0.3, 1.2, side * j * 0.5, 0, 0, CARN.white, D()) end end
	elseif kind == "ducks" then
		box(DEC, "Pond", gx - 1.2, top, z - 6, gx + 1.2, top + 0.5, z + 6, st(M.Glass, nil, C3(60, 120, 170)), DECO)
		for i = 0, 4 do
			local dk = model(DEC, "Duck")
			box(dk, "DuckBody", gx - 0.4, top + 0.5, z - 5 + i * 2.4, gx + 0.4, top + 1.1, z - 4 + i * 2.4, CARN.yellow, DECO)
			box(dk, "DuckHead", gx - 0.25, top + 1.1, z - 5 + i * 2.4, gx + 0.25, top + 1.6, z - 4.5 + i * 2.4, CARN.yellow, DECO)
		end
	elseif kind == "moles" then
		for i = 0, 2 do for j = 0, 1 do
			cyl(DEC, CFrame.new(gx + side * j * 1.2 - side * 0.6, top + 0.04, z - 4 + i * 4), "Hole", 1.4, 0.08, 0, 0, 0, CARN.black, D())
			if (i + j) % 2 == 0 then ball(DEC, CFrame.new(gx + side * j * 1.2 - side * 0.6, top + 0.5, z - 4 + i * 4), "Mole", 1, 0, 0, 0, st(M.SmoothPlastic, nil, C3(110, 80, 60)), D()) end
		end end
	elseif kind == "skee" then
		for i = -1, 1 do
			b(DEC, CFrame.new(gx, top + 0.6, z + i * 4.5) * CFrame.Angles(0, 0, side * 0.2), "Lane", 3, 0.3, 3.4, 0, 0, 0, CARN.green, D())
			cyl(DEC, CFrame.new(gx + side * 1.2, top + 1.2, z + i * 4.5), "Target", 1.6, 0.2, 0, 0, 0, CARN.white, D())
		end
	elseif kind == "balloons" then
		box(DEC, "Board", side * 75.5 - 0.2, F1 + 3, z - 6, side * 75.5 + 0.2, F1 + 13, z + 6, CARN.canvasW, DECO)
		for i = 0, 4 do for j = 0, 2 do
			ball(DEC, CFrame.new(side * 75, F1 + 5 + j * 3, z - 4.8 + i * 2.4), "Balloon", 1.4, 0, 0, 0, st(M.SmoothPlastic, nil, PRIZE[(i + j) % #PRIZE + 1]), D())
		end end
	elseif kind == "claw" then
		local cm = model(STR, "ClawMachine")
		box(cm, "Cabinet", gx - 2, F1, z - 3, gx + 2, F1 + 4, z + 3, CARN.blue)
		box(cm, "Glass", gx - 2, F1 + 4, z - 3, gx + 2, F1 + 10, z + 3, st(M.Glass, nil, C3(200, 220, 240)), { t = 0.6 })
		box(DEC, "ClawTop", gx - 2.1, F1 + 10, z - 3.1, gx + 2.1, F1 + 11, z + 3.1, CARN.red, DECO)
		box(DEC, "Claw", gx - 0.1, F1 + 8, z - 0.1, gx + 0.1, F1 + 10, z + 0.1, CARN.iron, DECO)
		for i = 0, 3 do carnTeddy(DEC, CFrame.new(gx + rng:NextNumber(-1, 1), F1 + 4, z - 2 + i * 1.3), 0.5, PRIZE[rng:NextInteger(1, #PRIZE)]) end
	end
end
local kinds = { "rings", "ducks", "moles", "skee", "balloons", "claw" }
local n = 0
for _, side in { -1, 1 } do
	for i, z in { -40, -20, 0, 20, 40 } do
		n += 1
		booth(side, z, kinds[(n - 1) % #kinds + 1], n)
	end
end

-- THE PRIZE COUNTER (middle): a ring of counters, a register, tickets, a giant teddy on top
local pcm = model(STR, "PrizeCounter")
box(pcm, "CounterN", -10, F1, 6, 10, F1 + 4, 8, CARN.red)
box(pcm, "CounterS", -10, F1, -8, 10, F1 + 4, -6, CARN.red)
box(pcm, "CounterW", -10, F1, -6, -8, F1 + 4, 6, CARN.blue)
box(pcm, "CounterE", 8, F1, -6, 10, F1 + 4, 6, CARN.blue)
box(pcm, "Plinth", -4, F1, -3, 4, F1 + 4.5, 3, CARN.gold)
carnTeddy(DEC, CFrame.new(0, F1 + 4.5, 0) * CFrame.Angles(0, math.pi, 0), 2.6, C3(200, 150, 100))
box(DEC, "Register", 6, F1 + 4, 6.2, 9, F1 + 5.6, 7.8, CARN.iron, DECO)
for k = 0, 9 do b(DEC, CFrame.new(rng:NextNumber(-8, 8), F1 + 4.05, rng:NextNumber(6.2, 7.8)) * CFrame.Angles(0, rng:NextNumber(0, 3), 0), "Ticket", 1.2, 0.04, 0.6, 0, 0, 0, CARN.red, D()) end
sign(DEC, "PRIZES", CFrame.new(0, F1 + 15, 7.9) * CFrame.Angles(0, math.pi, 0), 12, 3, CARN.velvet, C3(255, 220, 140), Enum.Font.Creepster)

-- THE GRAND PRIZES wall at the back (shelves of big teddies); its middle section is THE SECRET door
local gp = model(STR, "GrandPrizes")
for _, seg in { { -60, -16 }, { 16, 60 } } do
	for r = 0, 2 do
		box(gp, "Shelf", seg[1], F1 + 4 + r * 4.5, -57, seg[2], F1 + 4.4 + r * 4.5, -54, CARN.woodD)
		for x = seg[1] + 3, seg[2] - 3, 5.5 do carnTeddy(DEC, CFrame.new(x, F1 + 4.4 + r * 4.5, -55.5), 1.1, PRIZE[rng:NextInteger(1, #PRIZE)]) end
	end
end
sign(DEC, "GRAND PRIZES", CFrame.new(0, F1 + 18, -57.4), 22, 3, CARN.velvet, C3(255, 220, 140), Enum.Font.Creepster)
-- the hoard room (x -16..16, z -58..-46): walls, and the shelf section in the middle that swings away
local hr = model(STR, "HoardRoom")
local RH = 14
box(hr, "Wall", -16.6, F1, -58, -15.4, F1 + RH, -45.4, CARN.paint)
box(hr, "Wall", 15.4, F1, -58, 16.6, F1 + RH, -45.4, CARN.paint)
box(hr, "Wall", -15.4, F1, -46.6, -2.2, F1 + RH, -45.4, CARN.paint)
box(hr, "Wall", 2.2, F1, -46.6, 15.4, F1 + RH, -45.4, CARN.paint)
box(hr, "Lintel", -2.2, F1 + 9, -46.6, 2.2, F1 + RH, -45.4, CARN.paint)
box(hr, "Ceiling", -16.6, F1 + RH, -58, 16.6, F1 + RH + 0.6, -45.4, CARN.woodD)
for _, seg in { { -15.4, -2.2 }, { 2.2, 15.4 } } do
	for r = 0, 1 do
		box(DEC, "Shelf", seg[1], F1 + 4 + r * 4.5, -45.4, seg[2], F1 + 4.4 + r * 4.5, -43.4, CARN.woodD, DECO)
		for x = seg[1] + 2.5, seg[2] - 2, 4.5 do carnTeddy(DEC, CFrame.new(x, F1 + 4.4 + r * 4.5, -44.4) * CFrame.Angles(0, math.pi, 0), 0.9, PRIZE[rng:NextInteger(1, #PRIZE)]) end
	end
end
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "PrizeShelf")
door:SetAttribute("Slide", Vector3.new(0, -9.2, 0)); door:SetAttribute("Action", "Pull"); door:SetAttribute("Object", "Wobbly prize shelf")
box(door, "Panel", -2.2, F1, -46.5, 2.2, F1 + 9, -45.5, CARN.paint)
for r = 0, 1 do
	box(door, "Panel", -2.2, F1 + 4 + r * 4.5, -45.5, 2.2, F1 + 4.4 + r * 4.5, -43.6, CARN.woodD, DECO)
	local t = carnTeddy(door, CFrame.new(0, F1 + 4.4 + r * 4.5, -44.4) * CFrame.Angles(0, math.pi, 0), 0.9, PRIZE[r + 1])
	for _, d in t:GetDescendants() do if d:IsA("BasePart") then d.Name = "Panel" end end
end
box(door, "Trigger", -0.5, F1 + 4, -42.6, 0.5, F1 + 5, -41.6, CARN.paint, { deco = true, t = 1 })
-- (the clue: the shelf sits crooked, a trail of gold coins leads under it)
for k = 0, 5 do cyl(DEC, CFrame.new(-1 + k * 0.5, F1 + 0.08, -43 + k * 1.6), "TrailCoin", 0.7, 0.1, 0, 0, 0, CARN.gold, D()) end
local props = model(DEC, "Hoard")
for k = 0, 40 do cyl(props, CFrame.new(rng:NextNumber(-14, 14), F1 + 0.1 + rng:NextNumber(0, 1.2), rng:NextNumber(-57, -48)), "Coin", 0.9, 0.14, 0, 0, 0, CARN.gold, D()) end
box(props, "CoinPile", -12, F1, -57, -4, F1 + 1.6, -52, CARN.gold, DECO)
for k = 0, 4 do carnTeddy(props, CFrame.new(6 + k * 1.8, F1, -56) * CFrame.Angles(0, rng:NextNumber(-0.5, 0.5), rng:NextNumber(-0.3, 0.3)), 0.7, PRIZE[k + 1]) end
local glow = b(props, CFrame.new(0, F1 + 10, -52), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
light(glow, 20, 1.2, C3(255, 210, 110))

-- bunting, lights
for _, z in { -30, 0, 30 } do carnBunting(DEC, Vector3.new(-60, F1 + 18, z), Vector3.new(60, F1 + 18, z), 26) end
for _, p in { { -36, -30 }, { 36, -30 }, { -36, 30 }, { 36, 30 }, { 0, 0 } } do bulb(p[1], F1 + H - 1, p[2], 4, C3(255, 214, 150)) end
for _, p in { { -30, 40 }, { 36, -16 }, { -14, -30 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -36, 30 }, { 36, 30 }, { 0, 40 }, { -36, -30 }, { 36, -34 }, { 0, -30 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-3, -46, 3, -40, F1) -- (in front of the prize shelf)
carnMarquee("PRIZE ARCADE")
carnGrounds()
return endMap()
