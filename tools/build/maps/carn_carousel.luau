-- THE CAROUSEL (the Moonlight Carnival, building 3: THE STRONGMAN, who rips up the benches and the ride and throws
-- them, and whose slam sends a shockwave along the floor). A round pavilion hall, 28 high: the CAROUSEL in the
-- middle (a platform 1.6 up: standing on it you are over the shockwave; a striped canopy, a mirrored centre column,
-- and twelve HORSES on poles that are furniture - he tears them off and throws them, the poles stay), benches round
-- it (furniture too), the TEST YOUR STRENGTH high striker at the back, his weightlifting platform with dumbbells
-- (throwable), a candy floss stand, a ticket booth.
-- (2026-11-19: rebuilt as a real round pavilion: 20 sides round the carousel, a striped scalloped cone roof, a crown on top.)
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_carousel.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 28
beginMap("Carn_Carousel", carnTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(40, 70, 90)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(120, 90, 70)) }))
local CZ = -4 -- the carousel's centre (x 0) = the pavilion's
local RP, NP = 64, 20
local PTS = ring(0, CZ, RP, RP, NP)
local ops = {}
for _, i in { 3, 5, 7, 9, 13, 15, 17, 19 } do ops[i] = { { f = 0.5, w = 6, b = 5, t = 14, kind = "window" } } end
local ROOFB = st(M.Fabric, nil, C3(40, 70, 150))
local TOP = shell2({ poly = PTS, H = H, roof = "cone", rise = 34, over = 3, roofStyle = ROOFB, stripe = CARN.canvasW, ops = ops,
	postStyle = CARN.gold, postW = 2, ceiling = true, stepStyle = CARN.board })
local inn = model(STR, "Interior")
local PR = 18 -- its radius
local PH = 1.6 -- the platform's height

-- THE CAROUSEL: platform, rim, centre column, canopy, poles, horses
local cs = model(STR, "Carousel")
cyl(cs, CFrame.new(0, F1 + PH / 2, CZ), "Platform", PR * 2, PH, 0, 0, 0, CARN.board)
for k = 0, 23 do
	local a = k / 24 * math.pi * 2
	b(DEC, CFrame.new(0, F1, CZ) * CFrame.Angles(0, a, 0), "Rim", 4.8, PH + 0.1, 0.4, 0, PH / 2, -PR - 0.1, k % 2 == 0 and CARN.red or CARN.gold, DECO)
end
cyl(cs, CFrame.new(0, F1 + PH + 7, CZ), "Column", 7, 14, 0, 0, 0, CARN.velvet)
for k = 0, 7 do
	local a = k / 8 * math.pi * 2
	local p = b(DEC, CFrame.new(0, F1 + PH + 7, CZ) * CFrame.Angles(0, a, 0), "ColumnMirror", 2.2, 10, 0.2, 0, 0, -3.55, st(M.Glass, nil, C3(200, 210, 220)), DECO)
	p.Reflectance = 0.7
end
-- the canopy: a wide disc, a stepped cone in red and cream stripes, scalloped edge with bulbs
local cy = F1 + PH + 14
cyl(DEC, CFrame.new(0, cy, CZ), "Canopy", PR * 2 + 2, 0.6, 0, 0, 0, CARN.canvasW, D())
for k = 0, 3 do cyl(DEC, CFrame.new(0, cy + 0.9 + k * 1.1, CZ), "CanopyStep", (PR * 2 + 2) * (0.82 - k * 0.2), 1.1, 0, 0, 0, k % 2 == 0 and CARN.red or CARN.canvasW, D()) end
ball(DEC, CFrame.new(0, cy + 6, CZ), "CanopyTop", 2.4, 0, 0, 0, CARN.gold, D())
for k = 0, 31 do
	local a = k / 32 * math.pi * 2
	b(DEC, CFrame.new(0, cy - 0.8, CZ) * CFrame.Angles(0, a, 0), "Scallop", 3.8, 1.4, 0.2, 0, 0, -PR - 1.05, k % 2 == 0 and CARN.red or CARN.canvasW, DECO)
	ball(DEC, CFrame.new(0, cy - 1.6, CZ) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -PR - 1.1), "Bulb", 0.5, 0, 0, 0, CARN.bulb, D())
end
local cg = b(DEC, CFrame.new(0, cy - 2, CZ), "CanopyGlow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
light(cg, 40, 1.6, C3(255, 210, 150))
-- a carousel horse (furniture: he tears it off its pole and throws it); its pole stays (decoration)
local HORSE_COLS = { C3(236, 228, 210), C3(60, 50, 46), C3(150, 96, 60), C3(200, 180, 150) }
local SADDLE_COLS = { CARN.red, CARN.blue, CARN.green, CARN.yellow }
local function horse(cf: CFrame, i: number)
	local m = new("Horse")
	local coat = st(M.SmoothPlastic, nil, HORSE_COLS[(i - 1) % #HORSE_COLS + 1])
	local dark = st(M.SmoothPlastic, nil, C3(40, 30, 26))
	b(m, cf, "Body", 1.6, 1.8, 4.2, 0, 3.4, 0, coat)
	b(m, cf * CFrame.new(0, 4.4, -1.9) * CFrame.Angles(0.6, 0, 0), "Neck", 1.0, 2.4, 1.2, 0, 0.9, 0, coat)
	b(m, cf * CFrame.new(0, 6.0, -2.9) * CFrame.Angles(0.2, 0, 0), "Head", 0.9, 1.0, 2.0, 0, 0, -0.3, coat)
	b(m, cf * CFrame.new(0, 6.6, -2.4), "Mane", 0.4, 1.0, 1.4, 0, 0, 0, dark)
	for _, sx in { -1, 1 } do
		b(m, cf * CFrame.new(sx * 0.3, 6.3, -2.6), "Ear", 0.2, 0.5, 0.2, 0, 0.3, 0, coat)
		b(m, cf * CFrame.new(sx * 0.46, 6.1, -3.4), "Eye", 0.06, 0.2, 0.2, 0, 0, 0, dark)
		-- legs: the front ones up (galloping), the back ones down
		b(m, cf * CFrame.new(sx * 0.5, 2.8, -1.6) * CFrame.Angles(-1.0, 0, 0), "FrontLeg", 0.45, 2.2, 0.45, 0, -0.9, 0, coat)
		b(m, cf * CFrame.new(sx * 0.5, 2.8, 1.6) * CFrame.Angles(0.35, 0, 0), "BackLeg", 0.45, 2.4, 0.45, 0, -1.1, 0, coat)
	end
	b(m, cf, "Saddle", 1.8, 0.4, 1.6, 0, 4.4, 0.3, SADDLE_COLS[(i - 1) % #SADDLE_COLS + 1])
	b(m, cf, "Blanket", 1.75, 1.2, 1.8, 0, 3.9, 0.3, CARN.gold)
	b(m, cf * CFrame.new(0, 3.6, 2.2) * CFrame.Angles(0.6, 0, 0), "Tail", 0.4, 1.8, 0.4, 0, -0.6, 0, dark)
	return finalize(m, 2, "Horse")
end
local hi = 0
for _, ring in { { r = 13, n = 8, off = 0 }, { r = 7.5, n = 4, off = 0.4 } } do
	for k = 0, ring.n - 1 do
		hi += 1
		local a = k / ring.n * math.pi * 2 + ring.off
		local pos = Vector3.new(math.cos(a) * ring.r, F1 + PH, CZ + math.sin(a) * ring.r)
		local fwd = Vector3.new(-math.sin(a), 0, math.cos(a))
		local cf = CFrame.lookAt(pos, pos - fwd) -- (galloping round)
		cyl(DEC, CFrame.new(pos.X, F1 + PH + 6.2, pos.Z), "HorsePole", 0.35, 12.4, 0, 0, 0, CARN.gold, D())
		horse(cf * CFrame.new(0, (k % 2) * 0.8, 0), hi)
	end
end
-- the ticket booth and the gate
local gb = model(STR, "RideGate")
box(gb, "Booth", 18, F1, 22, 24, F1 + 7, 27, CARN.red)
box(gb, "BoothRoof", 17.4, F1 + 7, 21.4, 24.6, F1 + 7.6, 27.6, CARN.gold)
sign(DEC, "RIDE", CFrame.new(21, F1 + 8.8, 21.3) * CFrame.Angles(0, math.pi, 0), 5, 1.4, CARN.velvet, C3(255, 220, 140), Enum.Font.Creepster)

-- benches round the carousel (furniture), facing it
for k = 0, 7 do
	local a = k / 8 * math.pi * 2 + 0.2
	local p = Vector3.new(math.cos(a) * 30, F1, CZ + math.sin(a) * 30)
	if p.Z < 38 and math.abs(p.X) < 70 then
		F.bench(CFrame.lookAt(p, Vector3.new(0, F1, CZ)), 7)
	end
end

-- TEST YOUR STRENGTH (back wall): a pad, the tower with its scale, the bell; the mallet leaning on it
local hs = model(STR, "HighStriker")
box(hs, "Base", -4, F1, -54, 4, F1 + 1, -48, CARN.woodD)
box(hs, "Pad", -1.4, F1 + 1, -51.4, 1.4, F1 + 1.6, -48.6, CARN.red)
box(hs, "Tower", -1.2, F1 + 1, -55, 1.2, F1 + 22, -53, CARN.canvasW)
for k = 0, 6 do box(DEC, "Scale", -1.25, F1 + 3 + k * 2.6, -53.05, 1.25, F1 + 4.6 + k * 2.6, -52.9, ({ CARN.green, CARN.green, CARN.yellow, CARN.yellow, CARN.red, CARN.red, CARN.gold })[k + 1], DECO) end
cyl(DEC, CFrame.new(0, F1 + 23, -54) * CFrame.Angles(0, 0, 0), "Bell", 3, 1.6, 0, 0, 0, CARN.gold, D())
box(DEC, "Puck", -0.7, F1 + 6, -53.1, 0.7, F1 + 6.8, -52.6, CARN.iron, DECO)
sign(DEC, "TEST YOUR STRENGTH", CFrame.new(0, F1 + 25, -54.9) * CFrame.Angles(0, math.pi, 0), 16, 2.6, CARN.velvet, C3(255, 220, 140), Enum.Font.Creepster)
b(DEC, CFrame.new(4.5, F1 + 3, -50) * CFrame.Angles(0, 0, 0.35), "MalletHandle", 0.4, 6, 0.4, 0, 0, 0, CARN.woodD, D())
b(DEC, CFrame.new(5.6, F1 + 5.8, -50) * CFrame.Angles(0, 0, 0.35 + math.pi / 2), "MalletHead", 1.4, 3, 1.4, 0, 0, 0, CARN.red, D())
-- his weightlifting platform: a mat, a rack, a barbell, dumbbells (throwable)
local wp = model(STR, "LiftingPlatform")
box(wp, "Mat", -36, F1, -50, -16, F1 + 0.5, -36, st(M.Rubber, nil, C3(40, 36, 34)))
for _, x in { -32, -20 } do box(wp, "Rack", x - 0.4, F1 + 0.5, -48, x + 0.4, F1 + 7, -47.2, CARN.iron) end
cyl(DEC, CFrame.new(-26, F1 + 6.2, -47.6) * CFrame.Angles(0, 0, -math.pi / 2), "Bar", 0.4, 14, 0, 0, 0, st(M.Metal, nil, C3(170, 170, 176)), D())
for _, x in { -32.8, -19.2 } do cyl(DEC, CFrame.new(x, F1 + 6.2, -47.6) * CFrame.Angles(0, 0, -math.pi / 2), "Plate", 3.4, 0.6, 0, 0, 0, CARN.iron, D()) end -- (on edge: the axis along x)
local function dumbbell(cf: CFrame)
	local m = new("Dumbbell")
	-- (lying on the floor: the axis along the dumbbell's x)
	cyl(m, cf, "Grip", 0.4, 2.2, 0, 0, 0, st(M.Metal, nil, C3(170, 170, 176))).CFrame = cf * CFrame.new(0, 0.9, 0)
	for _, sx in { -1, 1 } do cyl(m, cf, "Weight", 1.8, 0.6, 0, 0, 0, CARN.iron).CFrame = cf * CFrame.new(sx * 1.2, 0.9, 0) end
	return finalize(m, 2, "Dumbbell")
end
for k = 0, 3 do dumbbell(CFrame.new(-34 + k * 4.5, F1 + 0.5, -40) * CFrame.Angles(0, k * 0.4, 0)) end
sign(DEC, "THE GREAT ZORGO", CFrame.new(-26, F1 + 12, -60) * CFrame.Angles(0, math.pi - 0.42, 0), 18, 3, CARN.velvet, C3(255, 220, 140), Enum.Font.Creepster)

-- the candy floss stand (front right) and a broken ride car (front left)
local cf2 = model(STR, "CandyFloss")
box(cf2, "Stand", 28, F1, 30, 38, F1 + 4, 36, CARN.blue)
box(cf2, "Awning", 27, F1 + 8, 29, 39, F1 + 8.6, 37, CARN.red)
for _, x in { 28.4, 37.6 } do box(DEC, "AwningPost", x - 0.2, F1 + 4, 29.4, x + 0.2, F1 + 8, 29.8, CARN.gold, DECO) end
cyl(DEC, CFrame.new(33, F1 + 4.6, 33), "Tub", 4, 1.2, 0, 0, 0, st(M.Metal, nil, C3(200, 200, 205)), D())
for k = 0, 2 do ball(DEC, CFrame.new(30 + k * 3, F1 + 6.4, 31), "Floss", 1.6, 0, 0, 0, st(M.SmoothPlastic, nil, C3(255, 160, 210)), D()) end
local rc = model(STR, "BrokenCar")
b(rc, CFrame.new(-34, F1, 32) * CFrame.Angles(0, 0.4, 0.15), "Car", 6, 3.2, 8, 0, 1.6, 0, CARN.yellow)
b(rc, CFrame.new(-34, F1, 32) * CFrame.Angles(0, 0.4, 0.15), "Seat", 5, 1.2, 2, 0, 3.6, 2, CARN.red)

-- bunting across the hall, lights
for k = 0, 4 do -- bunting from the canopy's top out to the walls, like a tent
	local a = k / 5 * math.pi * 2 + 0.3
	carnBunting(DEC, Vector3.new(0, F1 + 24, CZ), Vector3.new(math.cos(a) * 58, F1 + 22, CZ + math.sin(a) * 58), 16)
end
for _, p in { { -46, -20 }, { 46, -20 }, { -44, 26 }, { 44, 26 } } do bulb(p[1], F1 + H - 1, p[2], 4, C3(255, 210, 150)) end
bulb(0, F1 + H - 1, -48, 3, C3(255, 200, 140))
for _, p in { { -30, 40 }, { 36, -26 }, { -10, -40 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 10 }, { 40, 10 }, { 0, 40 }, { -40, -40 }, { 40, -44 }, { 0, -40 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
-- OUTSIDE (2026-11-19): the Strongman's carousel pavilion. Teal walls between gold posts, a red and cream cone with
-- a scalloped valance and bulbs, a gold crown and a pennant on top, the entrance under a striped canopy.
local OUT = model(DEC, "Outside")
for i, p in PTS do -- the valance: scallops and bulbs along every edge
	local q = PTS[i % NP + 1]
	local a, z = Vector3.new(p[1], TOP - 1.2, p[2]), Vector3.new(q[1], TOP - 1.2, q[2])
	local outv = (Vector3.new((a.X + z.X) / 2, 0, (a.Z + z.Z) / 2) - Vector3.new(0, 0, CZ)).Unit
	local d = z - a
	for k = 0, 3 do
		local m = a + d * ((k + 0.5) / 4) + outv * 1.4
		part(OUT, "Scallop", Vector3.new(d.Magnitude / 4 + 0.1, 2.2, 0.3), CFrame.lookAt(m, m + outv) * CFrame.Angles(0, 0, 0), k % 2 == 0 and CARN.red or CARN.canvasW, D())
		ball(OUT, CFrame.new(m - Vector3.new(0, 1.4, 0) + outv * 0.2), "ValanceBulb", 0.7, 0, 0, 0, CARN.bulb, D())
	end
end
-- a lantern drum where the cone narrows, a second smaller cone over it
local DR = 13
local dy0 = TOP + 34 * (1 - DR / RP) - 1
prism(OUT, "LanternDrum", 0, CZ, DR, dy0, dy0 + 9, 16, st(M.WoodPlanks, "PS2_Siding1", C3(40, 70, 90)), D())
for k = 0, 15 do
	local a = (k + 0.5) * math.pi / 8
	local w = box(OUT, "DrumWindow", 0, 0, 0, 1, 1, 1, st(M.Neon, nil, C3(255, 200, 130)), DECO)
	w.Size = Vector3.new(2.4, 4.4, 0.3)
	w.CFrame = CFrame.new(math.cos(a) * (DR + 0.1), dy0 + 4.5, CZ + math.sin(a) * (DR + 0.1)) * CFrame.Angles(0, -a + math.pi / 2, 0)
end
light(box(OUT, "DrumGlow", -0.1, dy0 + 4, CZ - 0.1, 0.1, dy0 + 4.2, CZ + 0.1, CARN.bulb, { deco = true, t = 1 }), 40, 1.2, C3(255, 200, 140))
local cone2 = {}
for k = 0, 15 do local a = k * math.pi / 8; table.insert(cone2, { math.cos(a) * DR, CZ + math.sin(a) * DR }) end
coneRoof(OUT, cone2, dy0 + 9, Vector3.new(0, dy0 + 22, CZ), ROOFB, 1.6, 0.6, CARN.canvasW)
local apex = dy0 + 22
cyl(OUT, CFrame.new(0, apex + 1.5, CZ), "CrownBase", 6, 3, 0, 0, 0, CARN.gold, D())
for k = 0, 7 do
	local a = k * math.pi / 4
	part(OUT, "CrownPoint", Vector3.new(1, 3.4, 1), CFrame.new(math.cos(a) * 2.6, apex + 4.4, CZ + math.sin(a) * 2.6), CARN.gold, D())
	ball(OUT, CFrame.new(math.cos(a) * 2.6, apex + 6.3, CZ + math.sin(a) * 2.6), "CrownJewel", 0.9, 0, 0, 0, k % 2 == 0 and CARN.red or CARN.blue, D())
end
box(OUT, "PennantPole", -0.2, apex + 3, CZ - 0.2, 0.2, apex + 14, CZ + 0.2, CARN.gold, DECO)
tri(OUT, "Pennant", Vector3.new(0.2, apex + 14, CZ), Vector3.new(0.2, apex + 10, CZ), Vector3.new(8, apex + 12, CZ), CARN.red, 0.2, D())
-- the entrance canopy and the name
local fz = math.max(PTS[1][2], PTS[2][2])
for _, x in { -8, 8 } do cyl(OUT, CFrame.new(x, 8.5, fz + 8), "CanopyPole", 0.8, 15, 0, 0, 0, CARN.gold, D()) end
for k = 0, 7 do
	local x = -8 + k * 2 + 1
	panel(OUT, "Canopy", Vector3.new(x, 18, fz - 1), Vector3.new(x, 15.6, fz + 9), Vector3.new(1, 0, 0), 2.05, k % 2 == 0 and CARN.red or CARN.canvasW, 0.3, D())
end
carnMarquee("THE CAROUSEL", CFrame.new(0, 19.6, fz + 8.7))
washLight(-30, 84, Vector3.new(-12, TOP + 12, 50), C3(200, 220, 255), 90, 2)
washLight(30, 84, Vector3.new(12, TOP + 12, 50), C3(200, 220, 255), 90, 2)
-- a ring of little lights round the walls (the pavilion glows at its feet)
for i, p in PTS do
	if i % 2 == 0 then
		local outv = (Vector3.new(p[1], 0, p[2]) - Vector3.new(0, 0, CZ)).Unit
		local g = ball(OUT, CFrame.new(Vector3.new(p[1], 1.2, p[2]) + outv * 2), "FootLight", 1, 0, 0, 0, CARN.bulb, D())
		if i % 4 == 0 then light(g, 16, 0.8, C3(255, 200, 140)) end
	end
end
sideBarrier(10.5, 60.2, function(bm, x1, x2, z)
	for x = x1, x2 - 3, 4 do
		if math.abs(x + 2) > 30 then box(bm, "Board", x, 0, z - 0.2, x + 3.8, 4.6, z + 0.2, (math.floor(x / 4) % 2 == 0) and CARN.red or CARN.white, DECO) end
	end
end)
carnGrounds()
return endMap()
