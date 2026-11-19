-- THE GHOST TRAIN (the Moonlight Carnival, building 6: THE PARTY BEAR, then THE GOLDEN BEAR). The dark ride: a TRACK
-- loops round the hall (rails, sleepers) through three zones split by black-curtained walls: the GRAVEYARD (west:
-- tombstones, a dead tree cut-out, a coffin), the HAUNTED HALL (middle: a painted moon, portraits, hanging bats, a
-- witch cut-out, cobwebs) and SHOWTIME (east: the Party Bear's stage - curtains, footlights, a drum kit, spotlights).
-- Three ride cars wait on the track by the entrance; the GHOST TRAIN sign with its skull over the door inside.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_ghosttrain.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 22
local CUT = st(M.WoodPlanks, nil, C3(40, 36, 48))
beginMap("Carn_GhostTrain", carnTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(30, 30, 40)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(36, 32, 44)), wain = false }))
shell({ two = false, H = H, roof = "gable", pitch = 0.45, front1 = { -60, -36, 36, 60 }, back1 = {}, left1 = {}, right1 = {}, winW = 6, winB = 5, winT = 13 })
carnFrieze(H)
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
carnMarquee("THE GHOST TRAIN")
carnGrounds()
return endMap()
