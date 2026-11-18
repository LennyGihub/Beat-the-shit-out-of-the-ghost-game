-- THE BARN (Camp Hollowmere, building 4: THE SCARECROW, who hides among the other scarecrows and only moves when
-- nobody looks at him). The camp's old red barn: one tall hall, a HAYLOFT over the back half (two ladders up),
-- horse stalls down the west wall, a tractor, hay everywhere, and the workshop corner where the camp made its
-- scarecrows (straw, sacks, a bench of pumpkin heads). One storey, 32 high.
-- Folder ScarecrowSpots: where the decoy scarecrows stand (the Scarecrow's ability puts copies of himself there).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_barn.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local PUMPKIN = st(M.SmoothPlastic, nil, C3(214, 110, 30))
local STRAW = st(M.Grass, nil, C3(200, 170, 90))
beginMap("Camp_Barn", campTheme({
	ext = st(M.WoodPlanks, "PS2_Siding1", C3(126, 38, 32)), trim = st(M.Wood, nil, C3(220, 214, 200)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(140, 112, 80)),
	roof = st(M.CorrodedMetal, nil, C3(100, 92, 84)), floor = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(104, 84, 60)), wain = false,
	door = st(M.WoodPlanks, "PS2_Siding1", C3(110, 34, 28)),
}))
shell({ two = false, H = 32, roof = "gable", pitch = 0.6, front1 = { -60, 60 }, back1 = { -50, 50 }, left1 = { 40, 0, -40 }, right1 = { 40, 0, -40 },
	winW = 6, winB = 8, winT = 16 })
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
campNameBoard("BARN")
campYard("BARN")
return endMap()
