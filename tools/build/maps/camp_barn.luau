-- THE BARN (Camp Hollowmere, building 4: THE SCARECROW, who hides among the other scarecrows and only moves when
-- nobody looks at him). The camp's old red barn: one tall hall, a HAYLOFT over the back half (two ladders up),
-- horse stalls down the west wall, a tractor, hay everywhere, and the workshop corner where the camp made its
-- scarecrows (straw, sacks, a bench of pumpkin heads). One storey, 32 high.
-- Folder ScarecrowSpots: where the decoy scarecrows stand (the Scarecrow's ability puts copies of himself there).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_barn.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local PUMPKIN = st(M.SmoothPlastic, nil, C3(214, 110, 30))
local STRAW = st(M.Grass, nil, C3(200, 170, 90))
beginMap("Camp_Barn", campTheme({
	ext = st(M.WoodPlanks, "PS2_Siding1", C3(126, 38, 32)), trim = st(M.Wood, nil, C3(220, 214, 200)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(140, 112, 80)),
	roof = st(M.CorrodedMetal, nil, C3(100, 92, 84)), floor = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(104, 84, 60)), wain = false,
	door = st(M.WoodPlanks, "PS2_Siding1", C3(110, 34, 28)),
}))
-- (2026-11-19) its own shape: a red gambrel barn, the gambrel gable to the yard, big sliding doors
local TOP = shell2({ H = 32, ridge = "z", roof = "gambrel", low = 30, high = 16, over = 3, door = { w = 14, t = 18 },
	front1 = { -60, 60 }, back1 = { -50, 50 }, left1 = { 40, 0, -40 }, right1 = { 40, 0, -40 }, win = { w = 6, b = 8, t = 16 } })
local inn = model(STR, "Interior")
-- THE HAYLOFT over the back half (z -58..-14), a railing along its edge, two ladders up
box(STR, "Loft", -78, 16, -58, 78, 17, -14, T.floor)
for _, x in { -78, -40, 0, 40, 78 } do box(STR, "LoftPost", x - 0.8, F1, -15.2, x + 0.8, 16, -13.6, T.trim) end
railing("x", -13.9, -78, -68, 17)
railing("x", -13.9, -54, 30, 17) -- (gaps: the hay steps at x -66..-56, the ladder at x 40)
railing("x", -13.9, 50, 78, 17)
for _, lx in { 40 } do
	local lad = model(STR, "Ladder")
	for y = 3, 16, 1.5 do box(lad, "Rung", lx - 3, y - 0.15, -13.4, lx + 3, y + 0.15, -12.8, T.trim) end
	for _, x in { lx - 3, lx + 3 } do box(lad, "Side", x - 0.2, 2, -13.4, x + 0.2, 19, -12.8, T.trim) end
end
-- a ramp of hay bales up to the loft at the west side (the second way up)
local stepY = { 4.4, 8.8, 13.2 }
for i, y in stepY do box(STR, "HayStep", -66, F1, -13 + (3 - i) * 5, -56, F1 + y, -8 + (3 - i) * 5, STRAW) end

-- THE STALLS down the west wall (open fronts, half walls between)
local stalls = model(STR, "Stalls")
for _, z in { -8, 6, 20, 34, 48 } do box(stalls, "StallWall", -78, F1, z - 0.4, -64, F1 + 6, z + 0.4, T.inner) end
for _, z in { -1, 13, 27, 41 } do
	box(DEC, "Trough", -76.5, F1, z - 2.5, -74.5, F1 + 2, z + 2.5, CAMP.logD, D())
	G2.hay(at(-70, F1, z + 2, "E"))
end
-- the tractor (solid) under the loft
local tr = model(STR, "Tractor")
local RED = st(M.Metal, nil, C3(150, 40, 30))
box(tr, "Body", 20, F1 + 1.4, -44, 32, F1 + 6, -36, RED)
box(tr, "Cab", 20, F1 + 6, -44, 26, F1 + 11, -36, RED)
box(tr, "Hood", 26, F1 + 6, -42, 32, F1 + 7.4, -38, RED)
for _, p in { { 21.5, -44.8 }, { 21.5, -35.2 } } do cyl(tr, CFrame.new(p[1], F1 + 3.4, p[2]) * CFrame.Angles(math.pi / 2, 0, 0), "BigWheel", 6.8, 1.6, 0, 0, 0, st(M.Rubber, nil, C3(26, 24, 24))) end
for _, p in { { 30.5, -44.4 }, { 30.5, -35.6 } } do cyl(tr, CFrame.new(p[1], F1 + 2, p[2]) * CFrame.Angles(math.pi / 2, 0, 0), "Wheel", 4, 1.2, 0, 0, 0, st(M.Rubber, nil, C3(26, 24, 24))) end
-- hay everywhere (and on the loft)
for _, p in { { -20, 30 }, { -14, 34 }, { 30, 44 }, { 36, 40 }, { 60, 10 }, { 6, -4 }, { -36, -30 }, { -30, -36 }, { 60, -50 } } do G2.hay(at(p[1], F1, p[2], "N")) end
for _, p in { { -60, -40 }, { -50, -50 }, { -20, -48 }, { 10, -50 }, { 60, -30 }, { 66, -44 } } do G2.hay(at(p[1], 17, p[2], "E")) end
-- THE WORKSHOP CORNER (front east): the bench where the camp made its scarecrows
G2.workbench(at(64, F1, 54, "N"), 10)
G2.workbench(at(76, F1, 40, "W"), 8)
local ph = model(DEC, "PumpkinHeads")
for i = 0, 4 do
	local x = 60 + i * 2
	ball(ph, CFrame.new(x, F1 + 4.9, 54), "Pumpkin", 1.6, 0, 0, 0, PUMPKIN, D())
	box(ph, "Stem", x - 0.12, F1 + 5.6, 53.88, x + 0.12, F1 + 6.1, 54.12, st(M.Wood, nil, C3(70, 90, 40)), D())
end
for k = 0, 3 do box(DEC, "Sack", 44 + k * 3, F1, 55, 46.6 + k * 3, F1 + 3, 57.6, st(M.Fabric, nil, C3(170, 150, 110)), D()) end
box(DEC, "StrawPile", 46, F1, 40, 56, F1 + 1.4, 50, STRAW, D())
F.barrel(at(40, F1, 30, "N")); F.barrel(at(-40, F1, 50, "N")); F.crate(at(0, F1, 50, "N"), 3.5); F.crate(at(-50, F1, 20, "N"), 3)
-- pumpkins on the floor
for _, p in { { -30, 10 }, { 14, 20 }, { 50, -6 }, { -50, 40 }, { 30, 6 } } do
	ball(DEC, CFrame.new(p[1], F1 + 0.9, p[2]), "Pumpkin", 1.8, 0, 0, 0, PUMPKIN, D())
end
-- lights: bare bulbs high up, lanterns on the posts
for _, p in { { -40, 20 }, { 40, 20 }, { 0, 44 }, { 0, 4 } } do bulb(p[1], 31, p[2], 8, C3(255, 190, 120)) end
for _, p in { { -40, -36 }, { 40, -36 }, { 0, -50 } } do bulb(p[1], 31, p[2], 6, C3(255, 180, 110)) end
for _, p in { { -10, 30 }, { 50, 20 }, { -40, -46 } } do blood(p[1], F1, p[2], 2) end
-- where the decoy scarecrows stand (the floor and the loft)
local ss = Instance.new("Folder"); ss.Name = "ScarecrowSpots"; ss.Parent = MAP
for _, p in { { -30, F1, 24 }, { 26, F1, 36 }, { 54, F1, 4 }, { -46, F1, 4 }, { 8, F1, 12 }, { -60, F1, 52 }, { 66, F1, 30 }, { -24, 17, -40 }, { 20, 17, -30 }, { 60, 17, -24 }, { -56, 17, -26 }, { 0, F1, -6 } } do
	local m = Instance.new("Part"); m.Name = "Spot"; m.Anchored = true; m.CanCollide = false; m.CanQuery = false; m.CanTouch = false
	m.Transparency = 1; m.Size = Vector3.one; m.Position = Vector3.new(p[1], p[2], p[3]); m.Parent = ss
end
for _, p in { { -30, F1, 40 }, { 40, F1, 10 }, { 0, F1, 30 }, { -40, 17, -40 }, { 40, 17, -50 }, { 60, F1, -30 } } do gspawn(p[1], p[2], p[3]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(36, -14, 44, -8, F1) -- (the foot of the ladder)
-- OUTSIDE (2026-11-19): the Scarecrow's barn. Red boards and white trim, sliding doors with white X braces, the
-- hayloft door high in the gambrel with a hoist beam and a bale on the rope, a rooster on the vane, crows all
-- along the ridge, the silo beside it and the cornfield in the yard, scarecrows standing in it.
local OUT = model(DEC, "Outside")
local WHITE = T.trim
local REDB = T.ext
local IRONB = st(M.Metal, nil, C3(50, 48, 46))
-- the gambrel's white edges (eave -> knee -> ridge on both sides)
local kneeX, kneeY, peakY = 80 - 80 * 0.32, TOP + 30, TOP + 46
for _, sx in { -1, 1 } do
	for _, seg in { { Vector3.new(sx * 83, TOP - 1, 61), Vector3.new(sx * kneeX, kneeY, 61) }, { Vector3.new(sx * kneeX, kneeY, 61), Vector3.new(0, peakY, 61) } } do
		part(OUT, "Trim", Vector3.new(0.6, 1.8, (seg[2] - seg[1]).Magnitude), CFrame.lookAt((seg[1] + seg[2]) / 2, seg[2]), WHITE, D())
	end
end
box(OUT, "EaveBand", -80, TOP - 1, 60, 80, TOP, 60.8, WHITE, DECO)
-- the sliding doors pushed open either side of the doorway, on their track
box(OUT, "Track", -26, 20.4, 60.4, 26, 21, 61, IRONB, DECO)
for _, sx in { -1, 1 } do
	local cx = sx * 13.5
	box(OUT, "DoorPanel", cx - 6, 2, 60.6, cx + 6, 20, 61.2, REDB, DECO)
	for _, e in { { -6, -5.4 }, { 5.4, 6 } } do box(OUT, "DoorFrame", cx + e[1], 2, 61.2, cx + e[2], 20, 61.5, WHITE, DECO) end
	for _, y in { 2, 10.7, 19.4 } do box(OUT, "DoorFrame", cx - 6, y, 61.2, cx + 6, y + 0.6, 61.5, WHITE, DECO) end
	for _, half in { { 2.6, 10.7 }, { 11.3, 19.4 } } do
		local mid = (half[1] + half[2]) / 2
		local h = half[2] - half[1]
		local len = math.sqrt(144 + h * h) - 1
		local ang = math.atan2(h, 12)
		part(OUT, "Brace", Vector3.new(len, 0.6, 0.3), CFrame.new(cx, mid, 61.35) * CFrame.Angles(0, 0, ang), WHITE, D())
		part(OUT, "Brace", Vector3.new(len, 0.6, 0.3), CFrame.new(cx, mid, 61.35) * CFrame.Angles(0, 0, -ang), WHITE, D())
	end
end
-- the hayloft door, the hoist beam with its pulley, rope and a bale
box(OUT, "LoftOpening", -6, TOP + 10, 60.2, 6, TOP + 22, 60.6, st(M.SmoothPlastic, nil, C3(14, 10, 8)), DECO)
for _, e in { { -6.6, -6 }, { 6, 6.6 } } do box(OUT, "LoftFrame", e[1], TOP + 10, 60.4, e[2], TOP + 22.6, 61, WHITE, DECO) end
box(OUT, "LoftFrame", -6.6, TOP + 22, 60.4, 6.6, TOP + 22.6, 61, WHITE, DECO)
for _, sx in { -1, 1 } do
	part(OUT, "LoftLeaf", Vector3.new(0.4, 12, 6), CFrame.new(sx * 6.4, TOP + 16, 63.6) * CFrame.Angles(0, sx * 0.25, 0), REDB, D())
end
box(OUT, "LoftHay", -5.6, TOP + 10, 60.6, 5.6, TOP + 12, 62, STRAW, DECO)
box(OUT, "HoistBeam", -0.8, TOP + 32, 52, 0.8, TOP + 33.6, 70, CAMP.logD, DECO)
cyl(OUT, CFrame.new(0, TOP + 31.4, 69) * CFrame.Angles(0, 0, -math.pi / 2), "Pulley", 2, 0.6, 0, 0, 0, IRONB, D())
box(OUT, "HoistRope", -0.1, TOP + 6, 69.9, 0.1, TOP + 31, 70.1, st(M.Fabric, nil, C3(180, 160, 110)), DECO)
box(OUT, "HangingBale", -2.2, TOP + 3, 68, 2.2, TOP + 6, 72, STRAW, DECO)
-- the rooster weathervane and the crows along the ridge
box(OUT, "VaneRod", -0.15, peakY, 39.85, 0.15, peakY + 9, 40.15, IRONB, DECO)
box(OUT, "VaneArrow", -0.15, peakY + 6, 36, 0.15, peakY + 6.3, 44, IRONB, DECO)
b(OUT, CFrame.new(0, peakY + 8.2, 40), "Rooster", 0.3, 2.2, 3, 0, 0, 0, IRONB, D())
b(OUT, CFrame.new(0, peakY + 9.8, 41.2), "RoosterHead", 0.3, 1.4, 1.2, 0, 0, 0, IRONB, D())
part(OUT, "RoosterTail", Vector3.new(0.3, 2.4, 1.4), CFrame.new(0, peakY + 9, 38.6) * CFrame.Angles(-0.5, 0, 0), IRONB, D())
local CROW = st(M.SmoothPlastic, nil, C3(16, 14, 18))
for k, z in { 52, 30, 12, -8, -30, -46 } do
	local cf = CFrame.new(((k % 2 == 0) and 0.6 or -0.6), peakY + 1.1, z) * CFrame.Angles(0, k * 1.1, 0)
	b(OUT, cf, "Crow", 0.9, 0.9, 1.8, 0, 0, 0, CROW, D())
	b(OUT, cf, "CrowHead", 0.6, 0.6, 0.6, 0, 0.6, -0.9, CROW, D())
	b(OUT, cf, "CrowBeak", 0.2, 0.2, 0.6, 0, 0.55, -1.4, st(M.SmoothPlastic, nil, C3(60, 56, 40)), D())
	b(OUT, cf, "CrowTail", 0.7, 0.2, 1, 0, -0.2, 1.2, CROW, D())
end
-- the gooseneck lamp over the doors and moonlight on the front
do
	box(OUT, "LampArm", -0.2, 23, 60.4, 0.2, 23.4, 63, IRONB, DECO)
	local sh = box(OUT, "LampShade", -1.2, 22, 62.4, 1.2, 22.8, 64.2, st(M.Metal, nil, C3(40, 70, 50)), DECO)
	local g = box(OUT, "LampBulb", -0.4, 21.5, 62.9, 0.4, 22, 63.7, st(M.Neon, nil, C3(255, 200, 130)), DECO)
	light(g, 30, 1.4, C3(255, 190, 120))
	local _ = sh
end
washLight(-36, 86, Vector3.new(-18, TOP + 20, 60), C3(170, 186, 230), 95, 2.2)
washLight(36, 86, Vector3.new(18, TOP + 20, 60), C3(170, 186, 230), 95, 2.2)
-- THE SILO beside the barn (west, outside the yard): a stone foot, metal hoops, a dome
do
	local cx, cz = -108, -6
	prism(OUT, "SiloBase", cx, cz, 11.5, 0, 6, 14, CAMP.stone, D())
	prism(OUT, "Silo", cx, cz, 11, 6, 86, 14, st(M.WoodPlanks, "PS2_Siding1", C3(150, 140, 120)), D())
	for y = 14, 82, 12 do prism(OUT, "Hoop", cx, cz, 11.4, y, y + 0.8, 14, IRONB, D()) end
	domeRoof(OUT, cx, cz, 86, 11.8, 11.8, 8, 14, 3, st(M.Metal, nil, C3(110, 104, 96)), 0.6)
	for k = 0, 24 do box(OUT, "SiloRung", cx + 11.2, 4 + k * 3.2, cz - 1, cx + 11.6, 4.3 + k * 3.2, cz + 1, IRONB, DECO) end
end
-- THE CORNFIELD either side of the path, scarecrows standing in it (none of them moves... yet)
local corn = model(DEC, "Cornfield")
local crng = Random.new(77)
local STALK = st(M.Grass, nil, C3(110, 120, 56))
local DRY = st(M.Grass, nil, C3(150, 130, 70))
for _, sx in { -1, 1 } do
	for z = 72, 112, 5 do
		for x = 12, 62, 3.2 do
			if crng:NextNumber() < 0.88 then
				local h = crng:NextNumber(6.5, 9.5)
				local px, pz = sx * (x + crng:NextNumber(-0.6, 0.6)), z + crng:NextNumber(-0.8, 0.8)
				local tilt = CFrame.Angles(crng:NextNumber(-0.12, 0.12), 0, crng:NextNumber(-0.12, 0.12))
				part(corn, "Stalk", Vector3.new(0.4, h, 0.4), CFrame.new(px, h / 2, pz) * tilt, crng:NextNumber() < 0.3 and DRY or STALK, D())
				part(corn, "Leaf", Vector3.new(2.4, 0.15, 0.5), CFrame.new(px, h * 0.6, pz) * tilt * CFrame.Angles(0, crng:NextNumber(0, 3), -0.4), STALK, D())
			end
		end
	end
end
local function scarecrowPole(x: number, z: number, yaw: number)
	local sc = model(corn, "YardScarecrow")
	local cf = CFrame.new(x, 0, z) * CFrame.Angles(0, yaw, 0)
	b(sc, cf, "Pole", 0.6, 12, 0.6, 0, 6, 0, CAMP.logD, D())
	b(sc, cf, "Arms", 9, 0.5, 0.5, 0, 9, 0, CAMP.logD, D())
	b(sc, cf, "Shirt", 5, 4.4, 1.6, 0, 8, 0, st(M.Fabric, nil, C3(120, 60, 40)), D())
	b(sc, cf, "Sleeves", 8.6, 1.2, 1.2, 0, 9.1, 0, st(M.Fabric, nil, C3(120, 60, 40)), D())
	b(sc, cf, "Head", 2.4, 2.6, 2.4, 0, 11.6, 0, st(M.Fabric, nil, C3(190, 160, 110)), D())
	b(sc, cf, "HatBrim", 3.8, 0.3, 3.8, 0, 13, 0, st(M.Fabric, nil, C3(90, 70, 40)), D())
	b(sc, cf, "HatTop", 2.2, 1.6, 2.2, 0, 13.9, 0, st(M.Fabric, nil, C3(90, 70, 40)), D())
	for _, x2 in { -0.5, 0.5 } do b(sc, cf, "Eye", 0.4, 0.4, 0.2, x2, 11.9, -1.25, st(M.SmoothPlastic, nil, C3(10, 8, 6)), D()) end
	for _, x2 in { -4.6, 4.6 } do b(sc, cf, "Straw", 0.8, 1.4, 0.8, x2, 8.5, 0, STRAW, D()) end
end
scarecrowPole(-38, 96, 0.3); scarecrowPole(44, 80, -0.5); scarecrowPole(28, 108, 0.1)
-- the hay wagon and a pumpkin patch by the door
do
	local cf = CFrame.new(-30, 0, 68) * CFrame.Angles(0, 0.2, 0)
	b(OUT, cf, "WagonBed", 8, 0.8, 14, 0, 3, 0, CAMP.plank, D())
	for _, x in { -4, 4 } do for _, z in { -5, 5 } do cyl(OUT, cf * CFrame.new(x, 2, z) * CFrame.Angles(0, 0, -math.pi / 2), "WagonWheel", 4, 0.6, 0, 0, 0, CAMP.logD, D()) end end
	for k = 0, 4 do b(OUT, cf, "Bale", 3.6, 2.6, 5, (k % 2 == 0) and -1.9 or 1.9, 4.7 + math.floor(k / 4) * 2.6, -4 + (k % 3) * 4, STRAW, D()) end
end
for _, p in { { 16, 66 }, { 19, 68 }, { 22, 65 }, { 17, 70 }, { -16, 67 } } do ball(OUT, CFrame.new(p[1], 0.9, p[2]), "Pumpkin", 1.8, 0, 0, 0, PUMPKIN, D()) end
campYard("BARN", { noLamps = true })
for _, x in { -7, 7 } do campLantern(OUT, x * 1.7, 9, 60.2) end
return endMap()
