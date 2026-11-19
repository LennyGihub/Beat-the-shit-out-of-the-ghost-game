-- THE NET LOFT (Blackwater Harbor, building 4: THE NETMAN, who nets you where you stand and whirls his anchor round
-- the room on its chain). A tall timber loft: NETS hanging from every beam with orange floats, drying racks, a
-- rowing boat up on trestles (cover from the net), stacks of lobster pots, barrels and coils of rope round the
-- walls, and an open floor in the middle where the anchor swings. A back room behind a wall: the mending room.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_netloft.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 26
local rng = Random.new(44)
beginMap("Harb_NetLoft", harbTheme({ ext = st(M.WoodPlanks, "PS2_Siding1", C3(90, 70, 56)), inner = st(M.WoodPlanks, "PS2_Siding1", C3(110, 88, 66)) }))
shell({ two = false, H = H, roof = "gable", pitch = 0.5, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	winW = 6, winB = 6, winT = 14 })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "MendWall", "x", -34, -78, 78, F1, H, { dr(-40, 10, 13), dr(40, 10, 13) }, I)

local FLOAT = st(M.SmoothPlastic, nil, C3(230, 120, 40))
-- the roof beams, and nets hanging off them in loose curtains
for _, z in { 46, 26, 6, -14 } do
	box(DEC, "Beam", -78, F1 + H - 4, z - 0.6, 78, F1 + H - 2.8, z + 0.6, HARB.beam, DECO)
	for x0 = -70, 60, 26 do
		local w, drop = 12 + rng:NextNumber(0, 6), 8 + rng:NextNumber(0, 5)
		local top = F1 + H - 4
		for x = x0, x0 + w, 1.2 do
			local sag = math.sin((x - x0) / w * math.pi) * 2
			box(DEC, "NetV", x - 0.05, top - drop - sag, z - 0.05, x + 0.05, top, z + 0.05, HARB.rope, DECO)
		end
		for y = top - drop, top, 1.2 do box(DEC, "NetH", x0, y - 0.05, z - 0.05, x0 + w, y + 0.05, z + 0.05, HARB.rope, DECO) end
		for k = 0, 3 do ball(DEC, CFrame.new(x0 + 1 + k * w / 4, top - drop - 0.6, z), "Float", 0.9, 0, 0, 0, FLOAT, D()) end
	end
end
-- drying racks of net along the side walls (solid frames: cover)
for _, x in { -64, 64 } do
	local rk = model(STR, "Rack")
	for _, z in { 40, 14 } do box(rk, "Post", x - 0.4, F1, z - 0.4, x + 0.4, F1 + 10, z + 0.4, HARB.beam) end
	box(rk, "Bar", x - 0.4, F1 + 9.6, 14, x + 0.4, F1 + 10, 40, HARB.beam)
	for z = 14.5, 39.5, 1.2 do box(DEC, "RackNetV", x - 0.05, F1 + 2, z - 0.05, x + 0.05, F1 + 9.6, z + 0.05, HARB.rope, DECO) end
	for y = 2.5, 9.5, 1.2 do box(DEC, "RackNetH", x - 0.05, F1 + y - 0.05, 14, x + 0.05, F1 + y + 0.05, 40, HARB.rope, DECO) end
end
-- THE ROWING BOAT on trestles
local bt = model(STR, "RowBoat")
for _, z in { -6, 6 } do box(bt, "Trestle", -40, F1, z - 0.5, -32, F1 + 3, z + 0.5, HARB.beam) end
box(bt, "Hull", -42, F1 + 3, -9, -30, F1 + 5.4, 9, HARB.sidingD)
box(DEC, "HullRail", -42.2, F1 + 5.4, -9.2, -29.8, F1 + 5.8, 9.2, HARB.white, DECO)
box(DEC, "Oar", -44, F1 + 5.8, -6, -43.4, F1 + 6.2, 8, HARB.plank, DECO)
-- lobster pots, barrels, rope coils by the walls
for _, p in { { 30, 50 }, { 36, 50 }, { 33, 46 }, { 50, -24 }, { 56, -24 }, { -56, -26 } } do
	local pot = model(STR, "LobsterPot")
	box(pot, "Pot", p[1] - 2, F1, p[2] - 1.6, p[1] + 2, F1 + 2.6, p[2] + 1.6, st(M.WoodPlanks, nil, C3(120, 96, 64)))
	for k = 0, 2 do box(DEC, "PotHoop", p[1] - 2.1 + k * 2, F1, p[2] - 1.7, p[1] - 1.9 + k * 2, F1 + 2.8, p[2] + 1.7, HARB.rope, DECO) end
end
for _, p in { { -72, 50 }, { 72, 50 }, { -72, -28 }, { 72, -2 } } do harbCoil(DEC, Vector3.new(p[1], F1, p[2])) end
for _, p in { { 70, 26 }, { -70, 0 }, { 20, -26 } } do cyl(STR, CFrame.new(p[1], F1 + 2, p[2]), "Barrel", 3, 4, 0, 0, 0, HARB.plankD) end
-- the anchor stand in the middle of the floor (a heavy spare anchor on a block: you can stand on the block)
box(STR, "AnchorBlock", 6, F1, 18, 14, F1 + 2, 26, HARB.stone)
box(DEC, "SpareShank", 9.6, F1 + 2, 21.6, 10.4, F1 + 8, 22.4, HARB.iron, DECO)
box(DEC, "SpareArm", 7, F1 + 2, 21.6, 13, F1 + 2.8, 22.4, HARB.iron, DECO)
-- THE MENDING ROOM (behind the wall): a long table of nets, needles of bone, stools
box(STR, "MendTable", -30, F1, -50, 30, F1 + 3.4, -44, HARB.plank)
for x = -26, 26, 6 do box(DEC, "MendNet", x - 2, F1 + 3.4, -49, x + 2, F1 + 3.6, -45, HARB.rope, DECO) end
for x = -24, 24, 8 do cyl(DEC, CFrame.new(x, F1 + 1.2, -40), "Stool", 1.6, 2.4, 0, 0, 0, HARB.plankD, D()) end

-- lights: lanterns on the beams, a lamp over the mending table
for _, p in { { -40, 46 }, { 40, 46 }, { -40, 6 }, { 40, 6 }, { 0, 26 }, { 0, -14 } } do harbLantern(DEC, Vector3.new(p[1], F1 + H - 5.4, p[2]), 30) end
for _, p in { { -20, -47 }, { 20, -47 } } do bulb(p[1], F1 + H - 1, p[2], 6, C3(255, 210, 160)) end
for _, p in { { -10, 36 }, { 30, 0 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -20, 44 }, { 30, 36 }, { -50, 10 }, { 40, -10 }, { 0, -40 }, { -50, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-20, -10, 20, 14, F1) -- (the open floor in the middle)
harbSign("THE NET LOFT")
harbGrounds()
return endMap()
