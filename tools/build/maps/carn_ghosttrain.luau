-- THE GHOST TRAIN (the Moonlight Carnival, building 6: THE PARTY BEAR, then THE GOLDEN BEAR). The dark ride: a TRACK
-- loops round the hall (rails, sleepers) through three zones split by black-curtained walls: the GRAVEYARD (west:
-- tombstones, a dead tree cut-out, a coffin), the HAUNTED HALL (middle: a painted moon, portraits, hanging bats, a
-- witch cut-out, cobwebs) and SHOWTIME (east: the Party Bear's stage - curtains, footlights, a drum kit, spotlights).
-- Three ride cars wait on the track by the entrance; the GHOST TRAIN sign with its skull over the door inside.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_ghosttrain.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local CUT = st(M.WoodPlanks, nil, C3(40, 36, 48))
local CSTONE = st(M.Cobblestone, "PS2_Stone1", C3(100, 96, 108))
beginMap("Carn_GhostTrain", carnTheme({ ext = CSTONE, inner = st(M.WoodPlanks, "PS2_Siding1", C3(36, 32, 44)), wain = false, trim = st(M.Slate, nil, C3(40, 38, 46)) }))
-- (2026-11-19) its own shape: a HAUNTED CASTLE - stone walls, battlements, round towers, a skull over the gate
local TOP = shell2({ H = H, roof = "flat", roofStyle = st(M.Slate, nil, C3(30, 28, 34)), front1 = { -60, 60 }, win = { w = 5, b = 6, t = 14 } })
local inn = model(STR, "Interior")
local I = INT()
-- the curtained zone walls (the track goes through at z +-42, a walkway in the middle)
for _, x in { -26, 26 } do
	wall(inn, "ZoneWall", "z", x, -58, 58, F1, 15, { dr(42, 9, 12), dr(-42, 9, 12), dr(0, 10, 12) }, I)
	for z = -56, 54, 3 do
		if math.abs(z - 42) > 6 and math.abs(z + 42) > 6 and math.abs(z) > 6 then
			for _, s in { -1, 1 } do box(DEC, "Curtain", x + s * 0.75, F1, z, x + s * 0.95, F1 + 15, z + 3, CARN.black, DECO) end
		end
	end
end

-- THE TRACK: a loop at x +-62, z +-42 (two rails, sleepers every 4 studs)
local tk = model(DEC, "Track")
local RAIL = st(M.Metal, nil, C3(120, 120, 126))
local SLEEPER = st(M.Wood, "PS2_DarkBeam1", C3(52, 38, 30))
local function run(a: Vector3, bb: Vector3)
	local d = bb - a
	local len = d.Magnitude
	local cf = CFrame.lookAt(a, bb)
	for _, s in { -1.6, 1.6 } do b(tk, cf, "Rail", 0.3, 0.35, len, s, 0.2, -len / 2, RAIL, D()) end
	for k = 0, math.floor(len / 4) do b(tk, cf, "Sleeper", 4.6, 0.18, 0.9, 0, 0.09, -k * 4, SLEEPER, D()) end
end
local y = F1 + 0.02
run(Vector3.new(-62, y, 42), Vector3.new(62, y, 42))
run(Vector3.new(62, y, 42), Vector3.new(62, y, -42))
run(Vector3.new(62, y, -42), Vector3.new(-62, y, -42))
run(Vector3.new(-62, y, -42), Vector3.new(-62, y, 42))
-- the ride cars by the entrance (on the track's front run)
for i, x in { 22, 32, 42 } do
	local car = model(STR, "RideCar")
	box(car, "Body", x - 2.5, F1 + 0.6, 40, x + 2.5, F1 + 3.4, 44, i == 2 and CARN.red or CARN.velvet)
	box(car, "Back", x + 2, F1 + 3.4, 40, x + 2.6, F1 + 6, 44, i == 2 and CARN.red or CARN.velvet)
	box(DEC, "Bar", x - 1.5, F1 + 4.4, 40.2, x - 1.2, F1 + 4.7, 43.8, CARN.gold, DECO)
	b(DEC, CFrame.new(x - 2.55, F1 + 2.2, 42) * CFrame.Angles(0, -math.pi / 2, 0), "Skull", 1.6, 1.6, 0.2, 0, 0, 0, CARN.white, D())
	for _, z in { 40.1, 43.9 } do for _, dx in { -1.6, 1.6 } do cyl(DEC, CFrame.new(x + dx, F1 + 0.6, z) * CFrame.Angles(0, math.pi / 2, 0), "Wheel", 1.2, 0.3, 0, 0, 0, CARN.iron, D()) end end
end
-- the GHOST TRAIN sign over the door (inside), with a skull
sign(DEC, "GHOST TRAIN", CFrame.new(0, F1 + 17, 57.2) * CFrame.Angles(0, math.pi, 0), 22, 3.6, CARN.black, C3(170, 255, 170), Enum.Font.Creepster)
local sk = CFrame.new(0, F1 + 20.2, 57)
b(DEC, sk, "SkullHead", 3, 2.6, 0.4, 0, 0, 0, CARN.white, D())
for _, sx in { -1, 1 } do b(DEC, sk, "SkullEye", 0.8, 0.8, 0.1, sx * 0.7, 0.2, -0.25, st(M.Neon, nil, C3(120, 255, 140)), D()) end

-- THE GRAVEYARD (west): tombstones, a fence, a dead tree cut-out, a coffin, green fog light
local gy = model(STR, "Graveyard")
for _, p in { { -70, 20 }, { -60, 8 }, { -50, 24 }, { -44, -6 }, { -66, -18 }, { -36, 14 }, { -54, -30 } } do
	box(gy, "Tomb", p[1] - 1.4, F1, p[2] - 0.4, p[1] + 1.4, F1 + 3.6, p[2] + 0.4, CARN.stone)
	cyl(DEC, CFrame.new(p[1], F1 + 3.6, p[2]) * CFrame.Angles(math.pi / 2, 0, 0), "TombTop", 2.8, 0.8, 0, 0, 0, CARN.stone, D())
end
for z = -30, 30, 3 do box(DEC, "Picket", -73.5, F1, z, -73, F1 + 3.4, z + 0.4, CUT, DECO) end
box(DEC, "FenceRail", -73.6, F1 + 2.6, -30, -72.9, F1 + 2.9, 30.4, CUT, DECO)
local tree = model(DEC, "TreeCutout")
b(tree, CFrame.new(-56, F1 + 6, -50), "Trunk", 2, 12, 0.4, 0, 0, 0, CUT, D())
for _, br in { { -2.6, 10, 0.7 }, { 2.4, 9, -0.6 }, { -1.4, 12, 0.3 }, { 1.6, 11.6, -0.25 } } do
	b(tree, CFrame.new(-56 + br[1], F1 + br[2], -50) * CFrame.Angles(0, 0, br[3]), "Branch", 0.6, 5, 0.4, 0, 0, 0, CUT, D())
end
G2.coffin(at(-40, F1, -26, "E"), true)
local fog = b(DEC, CFrame.new(-50, F1 + 1, 0), "FogGlow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
light(fog, 40, 1.2, C3(120, 255, 140))

-- THE HAUNTED HALL (middle): a painted moon, portraits, bats, a witch cut-out, cobwebs
local hh = model(DEC, "HauntedHall")
cyl(hh, CFrame.new(0, F1 + 12, -57.3) * CFrame.Angles(0, math.pi / 2, 0), "Moon", 12, 0.2, 0, 0, 0, st(M.Neon, nil, C3(220, 220, 180)), D())
for _, x in { -16, 16 } do
	local pcf = CFrame.new(x, F1 + 9, -57.2)
	b(hh, pcf, "PortraitFrame", 5, 6.6, 0.3, 0, 0, 0, CARN.gold, D())
	b(hh, pcf, "Portrait", 4.2, 5.8, 0.1, 0, 0, -0.16, st(M.SmoothPlastic, nil, C3(60, 50, 60)), D())
	for _, sx in { -1, 1 } do b(hh, pcf, "PortraitEye", 0.4, 0.25, 0.05, sx * 0.7, 1, -0.22, st(M.Neon, nil, C3(255, 60, 40)), D()) end
end
for k = 0, 9 do
	local p = Vector3.new(-20 + k * 4.4, F1 + 15 - (k % 3) * 1.6, -20 + (k % 4) * 12)
	b(hh, CFrame.new(p), "BatString", 0.04, 3, 0.04, 0, 1.5, 0, CARN.white, D())
	b(hh, CFrame.new(p), "Bat", 0.6, 0.6, 0.6, 0, 0, 0, CARN.black, D())
	for _, sx in { -1, 1 } do b(hh, CFrame.new(p) * CFrame.Angles(0, 0, sx * 0.4), "Wing", 1.4, 0.1, 0.7, sx * 0.9, 0, 0, CARN.black, D()) end
end
local wc = CFrame.new(10, F1 + 7, 20) * CFrame.Angles(0, 0.4, 0)
b(hh, wc, "WitchBody", 3, 6, 0.3, 0, 0, 0, CUT, D())
b(hh, wc, "WitchHat", 3.4, 0.4, 0.3, 0, 3.2, 0, CUT, D())
b(hh, wc * CFrame.new(0, 4.6, 0) * CFrame.Angles(0, 0, 0.2), "HatCone", 1.2, 3, 0.3, 0, 0, 0, CUT, D())
b(hh, wc * CFrame.Angles(0, 0, 0.3), "Broom", 8, 0.3, 0.3, 0, -1.6, -0.2, st(M.Wood, nil, C3(110, 80, 50)), D())
for _, c in { { -25, -57 }, { 25, -57 }, { -25, 57 }, { 25, 57 } } do
	for k = 0, 3 do b(hh, CFrame.new(c[1] + (c[1] < 0 and 1 or -1) * k * 0.6, F1 + 14 - k * 0.6, c[2] + (c[2] < 0 and 1 or -1) * k * 0.6) * CFrame.Angles(0, 0.8, 0.6), "Web", 0.06, 3, 0.06, 0, 0, 0, st(M.SmoothPlastic, nil, C3(220, 220, 220)), { deco = true, t = 0.4 }) end
end
local hg = b(hh, CFrame.new(0, F1 + 14, -10), "HallGlow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
light(hg, 36, 1, C3(180, 120, 255))

-- SHOWTIME (east): the Party Bear's stage at the back
local stg = model(STR, "ShowStage")
box(stg, "Stage", 34, F1, -58, 76, F1 + 2.5, -36, CARN.board)
box(DEC, "StageFront", 34, F1, -36.1, 76, F1 + 2.5, -35.9, CARN.velvet, DECO)
for x = 34, 74, 4 do box(DEC, "StageCurtain", x, F1 + 2.5, -57.8, x + 4, F1 + 19, -57.4, (x / 4) % 2 == 0 and CARN.velvet or st(M.Fabric, nil, C3(90, 16, 32)), DECO) end
for _, x in { 34.5, 75.5 } do box(DEC, "SideCurtain", x - 0.5, F1 + 2.5, -50, x + 0.5, F1 + 19, -36, CARN.velvet, DECO) end
box(DEC, "Valance", 34, F1 + 17, -36.6, 76, F1 + 19, -36, CARN.velvet, DECO)
carnBulbs(DEC, Vector3.new(34.5, F1 + 2.7, -35.6), Vector3.new(75.5, F1 + 2.7, -35.6), 2)
sign(DEC, "SHOWTIME!", CFrame.new(55, F1 + 16, -57.2), 18, 3.4, CARN.velvet, C3(255, 210, 90), Enum.Font.Creepster)
-- the drum kit, mic stands, stars
cyl(DEC, CFrame.new(55, F1 + 4.3, -52) * CFrame.Angles(0, math.pi / 2, 0), "KickDrum", 3.6, 1.6, 0, 0, 0, CARN.red, D())
for _, p in { { 52.6, -51 }, { 57.4, -51 } } do cyl(DEC, CFrame.new(p[1], F1 + 5.2, p[2]), "Tom", 1.6, 1.2, 0, 0, 0, CARN.red, D()) end
for _, p in { { 50.6, -53 }, { 59.4, -53 } } do
	box(DEC, "CymbalStand", p[1] - 0.1, F1 + 2.5, p[2] - 0.1, p[1] + 0.1, F1 + 7.4, p[2] + 0.1, CARN.iron, DECO)
	cyl(DEC, CFrame.new(p[1], F1 + 7.4, p[2]), "Cymbal", 2.4, 0.1, 0, 0, 0, CARN.gold, D())
end
for _, x in { 44, 66 } do
	box(DEC, "MicStand", x - 0.1, F1 + 2.5, -42.1, x + 0.1, F1 + 8, -41.9, CARN.iron, DECO)
	ball(DEC, CFrame.new(x, F1 + 8.2, -42), "Mic", 0.5, 0, 0, 0, CARN.iron, D())
end
for _, p in { { 40, 12 }, { 70, 14 }, { 55, 18 } } do b(DEC, CFrame.new(p[1], F1 + p[2], -57.1) * CFrame.Angles(0, 0, math.pi / 4), "Star", 2.4, 2.4, 0.2, 0, 0, 0, CARN.gold, D()) end
for _, x in { 42, 55, 68 } do
	local sp = b(DEC, CFrame.new(x, F1 + H - 1.5, -30), "StageSpot", 1.4, 1.4, 1.4, 0, 0, 0, CARN.iron, D())
	local l = Instance.new("SpotLight"); l.Face = Enum.NormalId.Bottom; l.Range = 40; l.Angle = 45; l.Brightness = 1.4; l.Color = C3(255, 220, 160); l.Parent = sp
end
-- confetti on the stage floor
local rngC = Random.new(3)
for _ = 1, 30 do
	b(DEC, CFrame.new(rngC:NextNumber(36, 74), F1 + 2.55, rngC:NextNumber(-56, -38)) * CFrame.Angles(0, rngC:NextNumber(0, 3), 0), "Confetti", 0.4, 0.03, 0.4, 0, 0, 0,
		st(M.SmoothPlastic, nil, ({ C3(255, 80, 90), C3(80, 160, 255), C3(255, 220, 80) })[rngC:NextInteger(1, 3)]), D())
end

-- lights: dim green / violet
for _, p in { { -50, 30 }, { -50, -30 }, { 0, 30 }, { 0, -30 }, { 50, 30 } } do bulb(p[1], F1 + H - 1, p[2], 3, (p[1] < -20 and C3(150, 255, 160)) or C3(200, 150, 255)) end
for _, p in { { -30, 46 }, { 36, -16 }, { -14, -30 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -50, 10 }, { 0, 20 }, { 50, 10 }, { -50, -30 }, { 0, -30 }, { 50, -20 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
for _, x in { -26, 26 } do keepClear(x - 4, -6, x + 4, 6, F1) end
-- OUTSIDE (2026-11-19): THE GHOST TRAIN CASTLE. Stone walls with battlements, two round towers with black cones
-- and green-lit slits, the gatehouse with a GIANT SKULL (red eyes) over the gate and a raised portcullis, the track
-- coming out of a tunnel in the wall, round a loop in the yard and back in, a ride car waiting on it, the Party
-- Bear's poster, bats.
local OUT = model(DEC, "Outside")
local DSTONE = st(M.Cobblestone, "PS2_Stone1", C3(84, 80, 92))
local BONE = st(M.SmoothPlastic, nil, C3(176, 168, 150))
local SLIT = st(M.Neon, nil, C3(90, 255, 120))
-- battlements along the front and the sides
for x = -80, 77, 6 do box(OUT, "Merlon", x, TOP, 58.2, x + 3.4, TOP + 4, 60.6, CSTONE, DECO) end
for _, sx in { -1, 1 } do for z = -58, 55, 6 do box(OUT, "Merlon", sx * 80 - 1.2, TOP, z, sx * 80 + 1.2, TOP + 4, z + 3.4, CSTONE, DECO) end end
box(OUT, "Band", -80.6, TOP - 1.2, 60, 80.6, TOP, 61, DSTONE, DECO)
-- the round towers at the front corners
for _, sx in { -1, 1 } do
	local tx, tz = sx * 82, 54
	prism(OUT, "Tower", tx, tz, 10, 0, 52, 12, DSTONE) -- (solid)
	for k = 0, 11 do
		local a = k * math.pi / 6
		box(OUT, "TowerMerlon", tx + 10.4 * math.cos(a) - 1.4, 52, tz + 10.4 * math.sin(a) - 1.4, tx + 10.4 * math.cos(a) + 1.4, 55.6, tz + 10.4 * math.sin(a) + 1.4, DSTONE, DECO)
	end
	local cone = {}
	for k = 0, 11 do local a = k * math.pi / 6; table.insert(cone, { tx + 9 * math.cos(a), tz + 9 * math.sin(a) }) end
	coneRoof(OUT, cone, 54, Vector3.new(tx, 78, tz), st(M.Slate, nil, C3(26, 22, 30)), 1, 0.8)
	for _, y in { 14, 28, 42 } do
		local g = box(OUT, "Slit", tx - sx * 0.4 - 0.5, y, tz + 9.8, tx - sx * 0.4 + 0.5, y + 4, tz + 10.4, SLIT, DECO)
		if y == 28 then light(g, 22, 1.2, C3(90, 255, 120)) end
	end
	box(OUT, "TowerFlag", tx - 0.15, 78, tz - 0.15, tx + 0.15, 84, tz + 0.15, CARN.iron, DECO)
	box(OUT, "TowerFlagCloth", tx + 0.15, 81.4, tz - 0.1, tx + 4, 83.8, tz + 0.1, st(M.Fabric, nil, C3(110, 20, 40)), DECO)
end
-- the gatehouse over the entrance, its battlements, the giant skull, the portcullis drawn up
box(OUT, "Gatehouse", -16, TOP - 4, 59, 16, TOP + 14, 62, DSTONE, DECO)
for x = -16, 13, 5 do box(OUT, "Merlon", x, TOP + 14, 59, x + 3, TOP + 18, 62, DSTONE, DECO) end
do
	local sy, sz = TOP + 5, 62.4
	box(OUT, "Skull", -8, sy - 4, sz, 8, sy + 8, sz + 1, BONE, DECO)
	box(OUT, "SkullJaw", -5.5, sy - 8.6, sz, 5.5, sy - 4, sz + 1, BONE, DECO)
	for _, sx in { -1, 1 } do
		box(OUT, "Socket", sx * 3.8 - 2.2, sy + 1, sz + 1, sx * 3.8 + 2.2, sy + 5, sz + 1.2, st(M.SmoothPlastic, nil, C3(14, 8, 8)), DECO)
		local e = ball(OUT, CFrame.new(sx * 3.8, sy + 3, sz + 1.3), "SkullEye", 1.6, 0, 0, 0, st(M.Neon, nil, C3(255, 40, 30)), D())
		light(e, 12, 0.8, C3(255, 50, 40))
	end
	part(OUT, "SkullNose", Vector3.new(2.2, 2.2, 0.2), CFrame.new(0, sy - 1.6, sz + 1.1) * CFrame.Angles(0, 0, math.pi / 4), st(M.SmoothPlastic, nil, C3(14, 8, 8)), D())
	for x = -4.5, 4, 1.8 do box(OUT, "SkullTooth", x, sy - 5, sz + 1, x + 1.4, sy - 3.4, sz + 1.3, BONE, DECO) end
end
for x = -5.5, 5.5, 1.6 do box(OUT, "Portcullis", x - 0.25, 13, 60.6, x + 0.25, 17.4, 61, CARN.iron, DECO) end
for _, y in { 14, 16 } do box(OUT, "Portcullis", -6, y, 60.6, 6, y + 0.4, 61, CARN.iron, DECO) end
sign(OUT, "THE GHOST TRAIN", CFrame.new(0, TOP + 10.4, 62.2) * CFrame.Angles(0, math.pi, 0), 26, 3, DSTONE, C3(120, 255, 140), Enum.Font.Creepster)
-- THE TRACK: out of a tunnel in the west front, a loop in the yard, back in through the east one; a ride car
local TRK = model(OUT, "Track")
local RAIL = st(M.Metal, nil, C3(120, 116, 110))
local function rails(a: Vector3, z: Vector3)
	local cf = CFrame.lookAt((a + z) / 2, z)
	local len = (z - a).Magnitude
	for _, sx in { -1.6, 1.6 } do part(TRK, "Rail", Vector3.new(0.4, 0.4, len + 0.2), cf * CFrame.new(sx, 0.3, 0), RAIL, D()) end
	for t = 0, len - 0.5, 2.5 do part(TRK, "Sleeper", Vector3.new(4.6, 0.3, 0.8), cf * CFrame.new(0, 0.05, -len / 2 + t + 0.4), CARN.woodD, D()) end
end
local loop = {}
for k = 0, 16 do
	local a = math.pi * k / 16
	table.insert(loop, Vector3.new(-36 - 10 * math.cos(a), 0.1, 80 + 14 * math.sin(a)))
end
rails(Vector3.new(-46, 0.1, 60), loop[1])
for k = 1, #loop - 1 do rails(loop[k], loop[k + 1]) end
rails(loop[#loop], Vector3.new(-26, 0.1, 60))
for _, x in { -46, -26 } do
	box(OUT, "Tunnel", x - 4, 2, 60.4, x + 4, 11, 60.7, st(M.SmoothPlastic, nil, C3(6, 6, 8)), DECO)
	box(OUT, "TunnelArch", x - 5, 11, 60.4, x + 5, 13, 61.4, DSTONE, DECO)
	for _, sx in { -1, 1 } do box(OUT, "TunnelSide", x + sx * 4.5 - 0.5, 0, 60.4, x + sx * 4.5 + 0.5, 11, 61.4, DSTONE, DECO) end
	for k = 0, 2 do box(OUT, "Flap", x - 3.6 + k * 2.5, 3, 60.8, x - 1.4 + k * 2.5, 10.6, 61, st(M.Fabric, nil, C3(20, 18, 22)), DECO) end
end
do
	local p = loop[9]
	local cf = CFrame.lookAt(p + Vector3.new(0, 1.6, 0), loop[10] + Vector3.new(0, 1.6, 0))
	b(OUT, cf, "RideCar", 4.6, 2.8, 6, 0, 0.8, 0, st(M.SmoothPlastic, nil, C3(60, 20, 70)), D())
	b(OUT, cf, "CarSeat", 4, 1.4, 1.6, 0, 2.4, 1.4, st(M.SmoothPlastic, nil, C3(140, 20, 30)), D())
	for _, sx in { -1, 1 } do part(OUT, "BatWing", Vector3.new(4, 0.3, 3), cf * CFrame.new(sx * 4, 2.4, 0) * CFrame.Angles(0, 0, sx * 0.4), st(M.SmoothPlastic, nil, C3(20, 16, 22)), D()) end
	b(OUT, cf, "CarSkull", 1.8, 1.8, 1.8, 0, 2.6, -3, BONE, D())
end
-- the Party Bear's poster on the east front, bats on the towers
do
	local cf = CFrame.new(38, 13, 60.5) * CFrame.Angles(0, math.pi, 0)
	b(OUT, cf, "PosterFrame", 18, 16, 0.3, 0, 0, 0.2, CARN.gold, D())
	b(OUT, cf, "Poster", 17, 15, 0.3, 0, 0, 0, st(M.SmoothPlastic, nil, C3(60, 30, 80)), D())
	local FURB = st(M.SmoothPlastic, nil, C3(120, 70, 40))
	cyl(OUT, cf * CFrame.new(0, 1.4, -0.3) * CFrame.Angles(math.pi / 2, 0, 0), "BearHead", 8, 0.2, 0, 0, 0, FURB, D())
	for _, sx in { -1, 1 } do
		cyl(OUT, cf * CFrame.new(sx * 3.4, 5, -0.25) * CFrame.Angles(math.pi / 2, 0, 0), "BearEar", 3, 0.2, 0, 0, 0, FURB, D())
		cyl(OUT, cf * CFrame.new(sx * 1.6, 2.4, -0.45) * CFrame.Angles(math.pi / 2, 0, 0), "BearEye", 1.4, 0.2, 0, 0, 0, st(M.Neon, nil, C3(255, 230, 120)), D())
	end
	b(OUT, cf, "BearGrin", 4, 0.8, 0.2, 0, -0.6, -0.45, st(M.SmoothPlastic, nil, C3(20, 10, 10)), D())
	sign(OUT, "PARTY BEAR - SHOWTIME!", cf * CFrame.new(0, -5.6, -0.4), 15, 2.2, st(M.SmoothPlastic, nil, C3(60, 30, 80)), C3(255, 220, 120), Enum.Font.Creepster)
end
for _, p in { { -80, 46, 62 }, { -86, 38, 58 }, { 84, 44, 62 }, { 78, 34, 60 }, { -40, 30, 61 } } do
	local cf = CFrame.new(p[1], p[2], p[3]) * CFrame.Angles(0, 0, (p[1] % 7) * 0.1)
	b(OUT, cf, "BatBody", 0.8, 1.2, 0.3, 0, 0, 0, st(M.SmoothPlastic, nil, C3(16, 12, 18)), D())
	for _, sx in { -1, 1 } do part(OUT, "BatWing", Vector3.new(2.4, 1, 0.2), cf * CFrame.new(sx * 1.4, 0.2, 0) * CFrame.Angles(0, 0, sx * 0.4), st(M.SmoothPlastic, nil, C3(16, 12, 18)), D()) end
end
washLight(-44, 86, Vector3.new(-50, TOP, 60), C3(150, 255, 170), 100, 2.4)
washLight(44, 86, Vector3.new(50, TOP, 60), C3(190, 150, 255), 100, 2.4)
washLight(-80, 80, Vector3.new(-82, 40, 54), C3(150, 255, 170), 70, 2)
washLight(80, 80, Vector3.new(82, 40, 54), C3(190, 150, 255), 70, 2)
-- torches either side of the gate and on the towers
for _, p in { { -10, 18, 61.4 }, { 10, 18, 61.4 }, { -72, 20, 61 }, { 72, 20, 61 } } do
	box(OUT, "TorchBracket", p[1] - 0.3, p[2] - 2, p[3] - 0.6, p[1] + 0.3, p[2], p[3] + 0.6, CARN.iron, DECO)
	local t = box(OUT, "Torch", p[1] - 0.5, p[2], p[3] - 0.5, p[1] + 0.5, p[2] + 0.6, p[3] + 0.5, st(M.Neon, nil, C3(255, 140, 50)), DECO)
	local f = Instance.new("Fire"); f.Size = 3; f.Heat = 6; f.Color = C3(255, 130, 50); f.SecondaryColor = C3(200, 50, 20); f.Parent = t
	light(t, 22, 1.3, C3(255, 140, 60))
end
carnGrounds()
return endMap()
