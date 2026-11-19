-- THE FUNHOUSE (the Moonlight Carnival, building 4: POP THE CLOWN, who jumps out of the crates and fills the room
-- with balloon copies of himself). The front hall: a checkerboard floor, CRATES everywhere (folder PopCrates: their
-- parts are where Server/CarnivalMonsters makes the crates rattle and he bursts out of one), a spinning-barrel
-- tunnel, leaning crooked panels. Between the halls: a GIANT CLOWN HEAD - its open mouth is the doorway. The back
-- hall: the BALL PIT, a slide off a platform, warped mirrors, balloon bunches, a clown car.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_funhouse.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 24
beginMap("Carn_Funhouse", carnTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(150, 60, 120)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(70, 110, 140)) }))
-- (2026-11-19) its own shape: a gable to the yard and the whole front is a GIANT CLOWN FACE (in through his mouth)
local TOP = shell2({ H = H, ridge = "z", roof = "gable", rise = 30, roofStyle = st(M.Slate, nil, C3(70, 40, 100)),
	front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 }, win = { w = 6, b = 5, t = 13 },
	postStyle = st(M.SmoothPlastic, nil, C3(240, 200, 50)) })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "HeadWall", "x", 0, -78, 78, F1, H, { dr(0, 12, 13), dr(-54, 8, 12), dr(54, 8, 12) }, I)

-- THE CHECKERBOARD FLOOR of the front hall
local fl = model(DEC, "Checker")
for x = -72, 60, 12 do
	for z = 4, 40, 12 do
		if ((x + z) / 12) % 2 == 0 then box(fl, "Tile", x, F1 + 0.02, z, x + 12, F1 + 0.06, z + 12, st(M.SmoothPlastic, nil, C3(20, 18, 22)), DECO) end
	end
end
-- THE CRATES (PopCrates: the parts themselves are the crates; their marks are decoration)
local pc = Instance.new("Folder"); pc.Name = "PopCrates"; pc.Parent = MAP
local CRATE = st(M.WoodPlanks, "PS2_Siding1", C3(150, 110, 70))
for _, p in { { -60, 46 }, { -24, 30 }, { 18, 44 }, { 52, 26 }, { 64, 48 }, { -46, 12 }, { 30, 10 }, { 0, 22 },
	{ -64, -16 }, { -10, -40 }, { 28, -24 }, { 62, -48 }, { 46, -10 }, { -36, -50 } } do
	local s = 4
	local c = box(pc, "Crate", p[1] - s / 2, F1, p[2] - s / 2, p[1] + s / 2, F1 + s, p[2] + s / 2, CRATE)
	local _ = c
	for _, f in { { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } } do
		local cf = CFrame.lookAt(Vector3.new(p[1] + f[1] * (s / 2 + 0.03), F1 + s / 2, p[2] + f[2] * (s / 2 + 0.03)), Vector3.new(p[1] + f[1] * 10, F1 + s / 2, p[2] + f[2] * 10))
		b(DEC, cf, "Mark", 1.2, 1.6, 0.05, 0, 0.2, 0, CARN.red, D())
		b(DEC, cf, "MarkDot", 0.5, 0.5, 0.05, 0, -0.9, 0, CARN.red, D())
		b(DEC, cf * CFrame.Angles(0, 0, math.pi / 4), "Slat", s * 1.25, 0.3, 0.05, 0, 0, -0.01, CARN.woodD, D())
	end
end
-- THE SPINNING BARREL: a striped tube you walk through (its bottom left open)
local br = model(STR, "Barrel")
for k = 0, 15 do
	local a = k / 16 * math.pi * 2
	if not (a > math.pi * 1.25 and a < math.pi * 1.75) then
		b(br, CFrame.new(-40, F1 + 5.2, 28) * CFrame.Angles(0, 0, a), "Stave", 2.2, 0.5, 16, 0, 5, 0, k % 2 == 0 and CARN.red or CARN.yellow)
	end
end
-- crooked panels leaning on the walls, a crooked doorframe
for _, p in { { -77.2, 30, 0.18 }, { -77.2, 10, -0.14 }, { 77.2, 34, -0.16 }, { 77.2, 12, 0.2 } } do
	b(DEC, CFrame.new(p[1], F1 + 7, p[2]) * CFrame.Angles(p[3], 0, p[1] > 0 and -0.12 or 0.12), "Crooked", 0.4, 13, 9, 0, 0, 0, st(M.WoodPlanks, nil, C3(90, 150, 170)), D())
end

-- THE GIANT CLOWN HEAD on the head wall (front side): its mouth is the doorway (x -6..6, up to 13)
local hd = model(DEC, "ClownHead")
local zf = 0.75
local WHITE = st(M.SmoothPlastic, nil, C3(236, 230, 220))
box(hd, "Forehead", -17, F1 + 13, zf, 17, F1 + 23, zf + 0.3, WHITE, DECO)
for _, sx in { -1, 1 } do
	box(hd, "Cheek", sx * 6, F1 + 2, zf, sx * 17, F1 + 13, zf + 0.3, WHITE, DECO)
	-- eyes: a blue diamond, black inside, a white glint
	local ecf = CFrame.new(sx * 8, F1 + 18, zf + 0.45)
	b(hd, ecf * CFrame.Angles(0, 0, math.pi / 4), "EyePaint", 5, 5, 0.1, 0, 0, 0, CARN.blue, D())
	b(hd, ecf, "Eye", 2.2, 2.6, 0.12, 0, 0, 0.06, CARN.black, D())
	b(hd, ecf, "Glint", 0.6, 0.6, 0.1, 0.5, 0.5, 0.14, st(M.Neon, nil, C3(255, 255, 240)), D())
	-- frizzy hair
	for k, p in { { 19, 18, 4 }, { 21, 12, 3.6 }, { 18, 23, 3.4 }, { 21, 6, 3 } } do
		ball(hd, CFrame.new(sx * p[1], F1 + p[2], zf + 1), "Hair", p[3] + k * 0.3, 0, 0, 0, st(M.Fabric, nil, C3(240, 110, 40)), D())
	end
	-- the grin's corners turning up
	b(hd, CFrame.new(sx * 7.6, F1 + 12, zf + 0.4) * CFrame.Angles(0, 0, sx * 0.5), "LipCorner", 4, 1.2, 0.2, 0, 0, 0, CARN.red, D())
end
ball(hd, CFrame.new(0, F1 + 16.5, zf + 2.6), "Nose", 6, 0, 0, 0, st(M.SmoothPlastic, nil, C3(230, 30, 30)), D())
box(hd, "LipTop", -6.5, F1 + 13, zf + 0.35, 6.5, F1 + 14.2, zf + 0.6, CARN.red, DECO)
for x = -5, 4, 2 do box(hd, "Tooth", x + 0.1, F1 + 11.8, zf + 0.35, x + 1.6, F1 + 13, zf + 0.55, WHITE, DECO) end
box(hd, "LipBottom", -6.5, F1, zf + 0.35, 6.5, F1 + 0.6, zf + 0.6, CARN.red, DECO)
cyl(hd, CFrame.new(0, F1 + 23.4, zf + 0.6) * CFrame.Angles(math.pi / 2, 0, 0), "HatBrim", 10, 0.6, 0, 0, 0, CARN.blue, D())
local hg = b(hd, CFrame.new(0, F1 + 16, 8), "HeadGlow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
light(hg, 30, 1.1, C3(255, 200, 200))

-- THE BACK HALL: the ball pit, the slide, warped mirrors, a clown car, balloons
local pit = model(STR, "BallPit")
box(pit, "PitWall", -62, F1, -54, -20, F1 + 2.6, -53, CARN.red)
box(pit, "PitWall", -62, F1, -31, -20, F1 + 2.6, -30, CARN.red)
box(pit, "PitWall", -62, F1, -53, -61, F1 + 2.6, -31, CARN.yellow)
box(pit, "PitWall", -21, F1, -53, -20, F1 + 2.6, -44, CARN.yellow)
local rngB = Random.new(5)
local BALLS = { C3(220, 40, 40), C3(60, 120, 230), C3(240, 200, 50), C3(70, 180, 80), C3(230, 120, 200) }
for _ = 1, 70 do
	ball(DEC, CFrame.new(rngB:NextNumber(-60, -22), F1 + rngB:NextNumber(0.6, 2.2), rngB:NextNumber(-52, -32)), "PitBall", 1.3, 0, 0, 0, st(M.SmoothPlastic, nil, BALLS[rngB:NextInteger(1, #BALLS)]), D())
end
local sl = model(STR, "Slide")
box(sl, "Platform", 30, F1, -56, 42, F1 + 9, -46, CARN.blue)
box(sl, "Rail", 30, F1 + 9, -56, 42, F1 + 11, -55, CARN.yellow)
for y = 1, 8 do box(sl, "Rung", 42, F1 + y, -51.5, 43.5, F1 + y + 0.3, -50.5, CARN.gold) end
local sa = math.atan(9 / 22)
b(sl, CFrame.new(20, F1 + 4.5, -51) * CFrame.Angles(0, 0, -sa), "SlideBed", 23.8, 0.6, 6, 0, 0, 0, CARN.red)
for _, z in { -54.2, -47.8 } do b(DEC, CFrame.new(20, F1 + 5.3, z) * CFrame.Angles(0, 0, -sa), "SlideSide", 23.8, 1.2, 0.3, 0, 0, 0, CARN.yellow, D()) end
for _, x in { -10, 2, 14 } do
	local p = b(DEC, CFrame.new(x, F1 + 6, -57.4) * CFrame.Angles(0, 0, 0.06), "WarpedMirror", 7, 11, 0.3, 0, 0, 0, st(M.Glass, nil, C3(200, 210, 220)), D())
	p.Reflectance = 0.85
	b(DEC, CFrame.new(x, F1 + 6, -57.6), "MirrorFrame", 8, 12, 0.2, 0, 0, 0, CARN.gold, D())
end
local car = model(STR, "ClownCar")
box(car, "Body", 52, F1 + 1, -30, 62, F1 + 4.4, -24, CARN.yellow)
box(car, "Cabin", 54, F1 + 4.4, -29.4, 59, F1 + 7.4, -24.6, CARN.red)
for _, p in { { 53.5, -30.2 }, { 60.5, -30.2 }, { 53.5, -23.8 }, { 60.5, -23.8 } } do cyl(DEC, CFrame.new(p[1], F1 + 1.2, p[2]) * CFrame.Angles(0, math.pi / 2, 0), "Wheel", 2.4, 0.6, 0, 0, 0, CARN.iron, D()) end
for _, p in { { -70, -10 }, { 70, -50 }, { -70, 50 }, { 70, 50 }, { 0, -20 } } do
	cyl(DEC, CFrame.new(p[1], F1 + 2.5, p[2]), "Weight", 1, 1, 0, -2, 0, CARN.iron, D())
	for k, col in { C3(220, 40, 40), C3(60, 120, 230), C3(240, 200, 50), C3(70, 180, 80) } do
		local o = Vector3.new((k - 2.5) * 1.2, 8 + (k % 2) * 1.2, (k % 2) * 0.6)
		b(DEC, CFrame.new(p[1], F1, p[2]), "String", 0.05, 6.5, 0.05, o.X * 0.5, 4.2, 0, CARN.white, D())
		ball(DEC, CFrame.new(p[1] + o.X, F1 + o.Y, p[2] + o.Z), "Balloon", 1.7, 0, 0, 0, st(M.SmoothPlastic, nil, col), D())
	end
end

-- bunting, lights (pink and green bulbs)
for _, z in { 20, -30 } do carnBunting(DEC, Vector3.new(-76, F1 + 20, z), Vector3.new(76, F1 + 20, z), 30) end
for _, p in { { -50, 30 }, { 50, 30 }, { -40, -30 }, { 40, -30 } } do bulb(p[1], F1 + H - 1, p[2], 3, C3(255, 170, 210)) end
for _, p in { { 0, 40 }, { 0, -44 } } do bulb(p[1], F1 + H - 1, p[2], 3, C3(170, 255, 190)) end
for _, p in { { -30, 40 }, { 36, -16 }, { -10, -26 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 40 }, { 40, 30 }, { 0, 34 }, { -50, -20 }, { 30, -40 }, { 0, -34 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-7, -6, 7, 6, F1) -- (the mouth)
keepClear(-48, 19, -32, 37, F1) -- (the barrel)
-- OUTSIDE (2026-11-19): POP THE CLOWN'S FUNHOUSE. The front is his face: a white head, diamond eyes, a red ball
-- nose, a red grin whose open middle is the door (teeth over it), orange and blue tufts of hair, a striped cone hat.
-- Black and white checkerboard either side, two crooked candy-striped towers, his name tilted on a marquee.
local OUT = model(DEC, "Outside")
local WHITEF = st(M.SmoothPlastic, nil, C3(206, 200, 190))
local REDF = st(M.SmoothPlastic, nil, C3(200, 30, 40))
local BLK = st(M.SmoothPlastic, nil, C3(20, 18, 24))
local YELF = st(M.SmoothPlastic, nil, C3(240, 200, 50))
local FZ = 60.9
-- the head: strips round a circle, the doorway left open (x -7..7 up to y 18)
local HY, HR = 24, 22
for y = HY - HR + 1, HY + HR - 1, 2 do
	local w = math.sqrt(math.max(0, HR * HR - (y + 1 - HY) ^ 2))
	if w > 1 then
		if y < 18 then
			if w > 7.4 then box(OUT, "Face", -w, math.max(y, 2), FZ - 0.4, -7.4, y + 2, FZ, WHITEF, DECO); box(OUT, "Face", 7.4, math.max(y, 2), FZ - 0.4, w, y + 2, FZ, WHITEF, DECO) end
		else box(OUT, "Face", -w, y, FZ - 0.4, w, y + 2, FZ, WHITEF, DECO) end
	end
end
-- the grin round the door, teeth along the top lip
box(OUT, "Lip", -13, 17.4, FZ, 13, 19.6, FZ + 0.4, REDF, DECO)
for _, sx in { -1, 1 } do
	box(OUT, "Lip", sx * 7.4, 2, FZ, sx * 13, 17.4, FZ + 0.4, REDF, DECO)
	part(OUT, "LipCorner", Vector3.new(6, 2.2, 0.4), CFrame.new(sx * 15, 20.4, FZ + 0.2) * CFrame.Angles(0, 0, sx * 0.55), REDF, D())
end
for x = -6, 5, 2.4 do box(OUT, "Tooth", x, 15.6, FZ + 0.4, x + 2, 17.4, FZ + 0.7, WHITEF, DECO) end
-- the nose, the eyes, the brows, the cheeks
ball(OUT, CFrame.new(0, 25, FZ + 2.6), "Nose", 6, 0, 0, 0, st(M.Neon, nil, C3(255, 40, 50)), D())
light(box(OUT, "NoseGlow", -0.1, 25, FZ + 6, 0.1, 25.2, FZ + 6.2, REDF, { deco = true, t = 1 }), 14, 0.7, C3(255, 60, 60))
for _, sx in { -1, 1 } do
	part(OUT, "Eye", Vector3.new(5, 5, 0.3), CFrame.new(sx * 8, 32, FZ + 0.2) * CFrame.Angles(0, 0, math.pi / 4), BLK, D())
	part(OUT, "EyeShine", Vector3.new(1.4, 1.4, 0.3), CFrame.new(sx * 8 - 0.8, 32.8, FZ + 0.4), WHITEF, D())
	part(OUT, "Brow", Vector3.new(7, 1, 0.3), CFrame.new(sx * 8, 37.2, FZ + 0.2) * CFrame.Angles(0, 0, sx * 0.3), BLK, D())
	cyl(OUT, CFrame.new(sx * 13, 24, FZ + 0.1) * CFrame.Angles(math.pi / 2, 0, 0), "Cheek", 4.6, 0.3, 0, 0, 0, st(M.SmoothPlastic, nil, C3(240, 130, 150)), D())
end
-- the hair tufts and the hat
for _, sx in { -1, 1 } do
	for k, p in { { 22, 30, 9 }, { 26, 22, 8 }, { 20, 38, 8 }, { 28, 32, 7 } } do
		ball(OUT, CFrame.new(sx * p[1], p[2], FZ - 2), "Hair", p[3], 0, 0, 0, st(M.SmoothPlastic, nil, k % 2 == 0 and C3(250, 120, 30) or C3(60, 120, 240)), D())
	end
end
revolve(OUT, "Hat", 0, FZ - 3, { { 9, HY + HR - 2 }, { 6, HY + HR + 6 }, { 3, HY + HR + 13 }, { 0, HY + HR + 19 } }, 12, YELF, REDF)
ball(OUT, CFrame.new(0, HY + HR + 19.5, FZ - 3), "PomPom", 3.2, 0, 0, 0, st(M.SmoothPlastic, nil, C3(60, 120, 240)), D())
-- checkerboard on the rest of the front (two bands), skipping the windows
local function isWin(x, y) for _, c in { -60, -36, 36, 60 } do if math.abs(x - c) < 4.4 and y > 5 and y < 17 then return true end end return false end
for _, band in { { 2, 6 }, { 18, 26 } } do
	for x = -78, 74, 4 do
		if math.abs(x + 2) > 25 then
			for y = band[1], band[2] - 4, 4 do
				if not isWin(x + 2, y + 2) then
					box(OUT, "Check", x, y, FZ - 0.5, x + 4, y + 4, FZ - 0.2, ((x / 4 + y / 4) % 2 == 0) and BLK or WHITEF, DECO)
				end
			end
		end
	end
end
-- two crooked candy-striped towers at the front corners, tilted hats with bells
for _, sx in { -1, 1 } do
	local tw = model(OUT, "CrookedTower")
	for k = 0, 9 do
		part(tw, "Ring", Vector3.new(9, 4, 9), CFrame.new(sx * 84 + sx * k * 0.35, 2 + k * 4, 54) * CFrame.Angles(0, k * 0.08, sx * -0.03), k % 2 == 0 and REDF or WHITEF) -- (solid)
	end
	local hx = sx * 84 + sx * 3.6
	revolve(tw, "TowerHat", hx, 54, { { 6, 42 }, { 3, 49 }, { 0, 56 } }, 8, YELF, st(M.SmoothPlastic, nil, C3(120, 60, 180)))
	ball(tw, CFrame.new(hx + sx * 1, 56.4, 54), "Bell", 1.6, 0, 0, 0, YELF, D())
end
carnMarquee("THE FUNHOUSE", CFrame.new(-46, 34, FZ + 0.6) * CFrame.Angles(0, 0, 0.12))
washLight(-34, 84, Vector3.new(-30, 22, 60), C3(255, 150, 210), 80, 1.6)
washLight(34, 84, Vector3.new(30, 22, 60), C3(150, 230, 255), 80, 1.6)
carnGrounds()
return endMap()
