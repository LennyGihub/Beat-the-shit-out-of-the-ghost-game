-- THE NET LOFT (Blackwater Harbor, building 4: THE NETMAN, who nets you where you stand and whirls his anchor round
-- the room on its chain). A tall timber loft: NETS hanging from every beam with orange floats, drying racks, a
-- rowing boat up on trestles (cover from the net), stacks of lobster pots, barrels and coils of rope round the
-- walls, and an open floor in the middle where the anchor swings. A back room behind a wall: the mending room.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/harbor_lib.luau tools/build/maps/harb_netloft.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 26
local rng = Random.new(44)
local TAR = st(M.WoodPlanks, "PS2_Siding1", C3(40, 36, 34))
beginMap("Harb_NetLoft", harbTheme({ ext = TAR, inner = st(M.WoodPlanks, "PS2_Siding1", C3(110, 88, 66)), trim = st(M.Wood, nil, C3(200, 196, 184)),
	found = st(M.WoodPlanks, nil, C3(38, 32, 28)) }))
-- (2026-11-19) its own shape: a tall tarred loft with TWO steep gables side by side facing the yard, on pilings
local TOP = shell2({ H = H, roof = "none", front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	win = { w = 6, b = 6, t = 14 } })
for _, half in { { -80, 0 }, { 0, 80 } } do
	local cx = (half[1] + half[2]) / 2
	extrude(STR.Roof, -60, 60, { { cx - 43, TOP - 2.4 }, { cx, TOP + 30 }, { cx + 43, TOP - 2.4 } }, st(M.Slate, nil, C3(40, 40, 44)),
		{ axis = "z", ends = TAR, endParent = STR, endProf = { { cx - 40, TOP }, { cx, TOP + 30 }, { cx + 40, TOP } }, over = 2 })
end
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
-- OUTSIDE (2026-11-19): THE NETMAN'S LOFT. Tarred black boards and white trim, two steep gables, each with a loft door
-- and a hoist beam (a bundle of net and floats on its rope), NETS draped down the front, pilings in the black water
-- behind, and his ANCHOR - a huge one - leaning by the door on its chain.
local OUT = model(DEC, "Outside")
local WT = T.trim
for _, cx in { -40, 40 } do
	for _, sx in { -1, 1 } do
		local a, z = Vector3.new(cx + sx * 42, TOP - 2, 61), Vector3.new(cx, TOP + 30.4, 61)
		part(OUT, "BargeBoard", Vector3.new(0.6, 1.8, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), WT, D())
	end
	box(OUT, "LoftDoor", cx - 4, TOP + 6, 60.2, cx + 4, TOP + 16, 60.6, HARB.black, DECO)
	for _, e in { { -4.6, -4 }, { 4, 4.6 } } do box(OUT, "LoftFrame", cx + e[1], TOP + 6, 60.4, cx + e[2], TOP + 16.6, 61, WT, DECO) end
	box(OUT, "LoftFrame", cx - 4.6, TOP + 16, 60.4, cx + 4.6, TOP + 16.6, 61, WT, DECO)
	box(OUT, "Hoist", cx - 0.7, TOP + 22, 52, cx + 0.7, TOP + 23.4, 69, HARB.beam, DECO)
	box(OUT, "HoistRope", cx - 0.1, TOP + 4, 67.9, cx + 0.1, TOP + 22, 68.1, HARB.rope, DECO)
	ball(OUT, CFrame.new(cx, TOP + 3, 68), "NetBundle", 4.4, 0, 0, 0, st(M.Fabric, nil, C3(110, 120, 90)), D())
	for k = 0, 3 do ball(OUT, CFrame.new(cx + math.cos(k * 1.6) * 2.4, TOP + 2 + k * 0.6, 68 + math.sin(k * 1.6) * 2.4), "Float", 1.2, 0, 0, 0, st(M.SmoothPlastic, nil, C3(240, 120, 30)), D()) end
end
box(OUT, "Gutter", -1, TOP - 1, -60, 1, TOP + 0.4, 62, HARB.iron, DECO)
-- nets draped down the front: a sagging mesh between the windows
local function net(x0: number, x1: number, y1: number, drop: number)
	local n = math.floor((x1 - x0) / 1.6)
	for i = 0, n do
		local x = x0 + (x1 - x0) * i / n
		local d = drop * (1 - ((i / n - 0.5) * 2) ^ 2)
		box(OUT, "NetV", x - 0.06, y1 - d, 60.6, x + 0.06, y1, 60.75, HARB.rope, DECO)
	end
	for k = 0, math.floor(drop / 1.6) do
		local y = y1 - k * 1.6
		local sag = 0
		box(OUT, "NetH", x0, y - 0.06 - sag, 60.6, x1, y + 0.06 - sag, 60.75, HARB.rope, DECO)
	end
	for k = 0, 4 do ball(OUT, CFrame.new(x0 + (x1 - x0) * k / 4, y1 - 0.4, 60.9), "NetFloat", 1, 0, 0, 0, st(M.SmoothPlastic, nil, C3(240, 120, 30)), D()) end
end
net(-30, -10, TOP - 1, 12); net(10, 30, TOP - 1, 10); net(-76, -66, TOP - 1, 8); net(66, 76, TOP - 1, 9)
-- the anchor by the door, its chain into the dark
do
	local ac = CFrame.new(16, 0, 66) * CFrame.Angles(0, 0.3, 0.18)
	local AI = st(M.CorrodedMetal, nil, C3(70, 60, 56))
	b(OUT, ac, "Shank", 1.6, 18, 1.6, 0, 10, 0, AI, D())
	b(OUT, ac, "Stock", 10, 1.2, 1.2, 0, 18, 0, AI, D())
	cyl(OUT, ac * CFrame.new(0, 19.6, 0) * CFrame.Angles(math.pi / 2, 0, 0), "Ring", 3, 0.6, 0, 0, 0, AI, D())
	for _, sx in { -1, 1 } do
		part(OUT, "Arm", Vector3.new(1.4, 1.4, 7), ac * CFrame.new(sx * 3.2, 2.6, 0) * CFrame.Angles(0, math.pi / 2, sx * 0.6), AI, D())
		part(OUT, "Fluke", Vector3.new(2.6, 2.6, 0.6), ac * CFrame.new(sx * 5.8, 4.6, 0) * CFrame.Angles(0, 0, sx * 0.6), AI, D())
	end
	for k = 0, 8 do part(OUT, "Chain", Vector3.new(0.5, 0.5, 2), CFrame.new(18 - k * 1.6, 0.3, 70 + k * 0.6) * CFrame.Angles(0, 0.5 + (k % 2) * 0.3, k % 2 == 0 and 0 or math.pi / 2), st(M.Metal, nil, C3(60, 56, 54)), D()) end
end
-- pilings and the black water behind and beside it (it stands out over the harbor)
local lk = box(OUT, "Water", -420, 0.8, -700, 420, 1.15, 50, st(M.SmoothPlastic, nil, C3(12, 22, 26)), DECO)
lk.CastShadow = false
for z = -56, 46, 8 do for _, sx in { -1, 1 } do cyl(OUT, CFrame.new(sx * 82.2, 0.6, z), "Piling", 1.6, 4.4, 0, 0, 0, HARB.beam, D()) end end
-- lobster pots stacked by the door, oars
for k = 0, 5 do
	local x, y = -22 + (k % 3) * 3.6, math.floor(k / 3) * 2.8
	box(OUT, "LobsterPot", x, y, 64, x + 3.2, y + 2.6, 68, st(M.WoodPlanks, nil, C3(110, 90, 66)), DECO)
end
harbSign("THE NET LOFT", CFrame.new(0, 21.6, 61))
washLight(-34, 86, Vector3.new(-40, TOP + 10, 60), C3(200, 210, 230), 90, 2)
washLight(34, 86, Vector3.new(40, TOP + 10, 60), C3(200, 210, 230), 90, 2)
harbGrounds()
return endMap()
