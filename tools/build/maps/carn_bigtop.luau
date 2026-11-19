-- THE BIG TOP (the Moonlight Carnival, building 1: THE RINGMASTER, whose whip pulls you in and wakes the
-- mannequins in the stands). (2026-11-19: rebuilt as a real round circus tent.) An oval tent of 24 red and white
-- canvas panels under a striped cone; two striped KING POLES rise from the ring through the peak. Inside: the RING
-- in the middle (a red and white curb, sawdust, his podium, the poles to hide behind), curved BLEACHERS on both
-- sides full of seated MANNEQUINS (folder Mannequins: Server/CarnivalMonsters wakes them), the band stand and the
-- red curtains at the back, the human cannon, fire hoops, a trapeze and bunting in the canvas sky. THE SECRET: a
-- curtain in the tent wall at the back-left hides the PERFORMERS' WAGON parked against the tent (the costume room:
-- Secrets folder, its tier-3 item spot = the map's attribute SecretSpot, read by maps/carn_items.luau).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--   tools/build/maps/carnival_lib.luau tools/build/maps/carn_bigtop.luau
-- then furnish (ONLY), doors_clear, carn_items.
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local CX, CZ, RX, RZ, N = 0, -2, 78, 60, 24
beginMap("Carn_BigTop", carnTheme({ ext = CARN.canvasR, inner = CARN.canvasW, wain = false, floor = CARN.board, found = CARN.board }))
local PTS = ring(CX, CZ, RX, RZ, N)
-- edge 10 (centred at 225 degrees: the back-left) has the curtain into the wagon
local SECRET_EDGE = 10
local ops = {}
do
	local p, q = PTS[SECRET_EDGE], PTS[SECRET_EDGE + 1]
	local len = math.sqrt((q[1] - p[1]) ^ 2 + (q[2] - p[2]) ^ 2)
	ops[SECRET_EDGE] = { { c = len / 2, w = 5, b = 0, t = 9, kind = "hole" } }
end
local H = 18
local TOP = shell2({ poly = PTS, H = H, roof = "cone", rise = 44, over = 2.5, roofStyle = CARN.canvasR, stripe = CARN.canvasW,
	door = { w = 12, t = 15 }, ops = ops, postStyle = CARN.gold, postW = 1.4, steps = true, stepStyle = CARN.board })
-- the panels in red and white
for i = 1, N do
	local w = STR.Exterior:FindFirstChild("Wall" .. i)
	if w and i % 2 == 0 then for _, d in w:GetChildren() do if d.Name == "Wall" then d.Color = CARN.canvasW.color end end end
end
local inn = model(STR, "Interior")
local function E(f: number, deg: number, y: number?): Vector3 -- a point on the oval scaled by f, at an angle (degrees)
	local a = math.rad(deg)
	return Vector3.new(CX + RX * f * math.cos(a), y or F1, CZ + RZ * f * math.sin(a))
end
local O = Vector3.new(CX, F1, CZ)

-- THE RING: a curb of red and white blocks, sawdust inside, the podium, two king poles up through the peak
local ring0 = model(STR, "Ring")
local R = 22
for k = 0, 27 do
	local a = k / 28 * math.pi * 2
	b(ring0, CFrame.new(CX, F1, CZ) * CFrame.Angles(0, a, 0), "Curb", 5.2, 1.3, 1.3, 0, 0.65, -R, k % 2 == 0 and CARN.red or CARN.white)
end
cyl(DEC, CFrame.new(CX, F1 + 0.04, CZ), "Sawdust", R * 2 - 1, 0.08, 0, 0, 0, CARN.sawdust, D())
cyl(ring0, CFrame.new(CX, F1 + 0.6, CZ), "Podium", 6, 1.2, 0, 0, 0, CARN.red)
cyl(DEC, CFrame.new(CX, F1 + 1.25, CZ), "PodiumRim", 6.3, 0.15, 0, 0, 0, CARN.gold, D())
local PEAK = TOP + 44
for _, x in { -11, 11 } do
	local pole = model(STR, "KingPole")
	local top = PEAK - 44 * 11 / RX + 6 -- (the canvas there, and a little through it)
	for k = 0, math.floor((top - F1 - 1.5) / 3) do
		cyl(pole, CFrame.new(x, F1 + 1.5 + k * 3, CZ), "Pole", 1.8, 3, 0, 0, 0, k % 2 == 0 and CARN.red or CARN.white)
	end
	cyl(pole, CFrame.new(x, F1 + 0.4, CZ), "Foot", 3, 0.8, 0, 0, 0, CARN.iron)
	-- its pennant over the peak
	box(DEC, "PennantPole", x - 0.15, top, CZ - 0.15, x + 0.15, top + 8, CZ + 0.15, CARN.gold, DECO)
	tri(DEC, "Pennant", Vector3.new(x + 0.2, top + 8, CZ), Vector3.new(x + 0.2, top + 5, CZ), Vector3.new(x + 6, top + 6.5, CZ), CARN.red, 0.2, D())
end
-- bunting from the poles out to the wall tops, a trapeze high over the ring
for _, x in { -11, 11 } do
	for _, deg in (x < 0 and { 150, 190, 230, 120 } or { 30, -10, -50, 60 }) do
		carnBunting(DEC, Vector3.new(x, F1 + 34, CZ), E(0.97, deg, TOP - 1), 12)
	end
end
local tr = model(DEC, "Trapeze")
for _, x in { -4, 4 } do box(tr, "Rope", x - 0.1, F1 + 18, CZ - 12.1, x + 0.1, F1 + 40, CZ - 11.9, CARN.canvasW, DECO) end
cyl(tr, CFrame.new(CX, F1 + 18, CZ - 12) * CFrame.Angles(0, 0, -math.pi / 2), "Bar", 0.3, 8.4, 0, 0, 0, CARN.gold, D())
-- the lighting rig: spots on a frame between the poles, aimed at the ring
box(DEC, "RigBeam", -14, F1 + 30, CZ - 0.4, 14, F1 + 30.8, CZ + 0.4, CARN.iron, DECO)
for _, p in { { -16, -14 }, { 16, -14 }, { 0, 16 } } do
	local sp = b(DEC, CFrame.new(p[1], F1 + 29, CZ + p[2]), "Spot", 1.6, 1.6, 1.6, 0, 0, 0, CARN.iron, D())
	local l = Instance.new("SpotLight"); l.Face = Enum.NormalId.Bottom; l.Range = 45; l.Angle = 45; l.Brightness = 1.8; l.Color = C3(255, 236, 200); l.Parent = sp
end

-- THE BLEACHERS: four curved tiers on each side of the ring, mannequins seated on them, facing the ring
local mq = Instance.new("Folder"); mq.Name = "Mannequins"; mq.Parent = MAP
local rng = Random.new(42)
local SEGS = 10
for _, side in { { -55, 55 }, { 125, 235 } } do
	local bl = model(STR, "Bleachers")
	for t = 0, 3 do
		local f1, f2 = 0.57 + t * 0.095, 0.57 + (t + 1) * 0.095
		local y = F1 + 2.2 * (t + 1)
		for k = 0, SEGS - 1 do
			local d1 = side[1] + (side[2] - side[1]) * k / SEGS
			local d2 = side[1] + (side[2] - side[1]) * (k + 1) / SEGS
			local dm = (d1 + d2) / 2
			local inner, outer = E(f1, dm), E(f2, dm)
			local mid = (inner + outer) / 2
			local w = (E(f2, d2) - E(f2, d1)).Magnitude + 0.8
			local cf = CFrame.lookAt(Vector3.new(mid.X, (F1 + y) / 2, mid.Z), Vector3.new(outer.X, (F1 + y) / 2, outer.Z))
			part(bl, "Tier", Vector3.new(w, y - F1, (outer - inner).Magnitude + 0.3), cf, CARN.board)
			part(bl, "Edge", Vector3.new(w + 0.05, 0.35, 0.4), CFrame.lookAt(Vector3.new(inner.X, y - 0.12, inner.Z), Vector3.new(outer.X, y - 0.12, outer.Z)), t % 2 == 0 and CARN.red or CARN.white, D())
			if rng:NextNumber() < 0.5 then
				local seat = E(f1 + 0.06, dm + rng:NextNumber(-3, 3), y)
				carnMannequin(mq, CFrame.lookAt(seat, Vector3.new(CX, y, CZ)))
			end
		end
	end
	-- the handrail along the front of the bleachers
	for k = 0, SEGS - 1 do
		local a, z = E(0.555, side[1] + (side[2] - side[1]) * k / SEGS, F1 + 3.4), E(0.555, side[1] + (side[2] - side[1]) * (k + 1) / SEGS, F1 + 3.4)
		part(DEC, "Rail", Vector3.new(0.4, 0.4, (z - a).Magnitude + 0.2), CFrame.lookAt((a + z) / 2, z), CARN.gold, D())
	end
end

-- THE BAND STAND at the back: a stage, a bass drum, music stands, chairs
local bs = model(STR, "BandStand")
box(bs, "Stage", -22, F1, -57, 22, F1 + 2, -43, CARN.board)
box(bs, "StageFront", -22, F1, -43.1, 22, F1 + 2, -42.9, CARN.velvet, DECO)
cyl(DEC, CFrame.new(0, F1 + 4.6, -52) * CFrame.Angles(math.pi / 2, 0, 0), "BassDrum", 5, 2, 0, 0, 0, CARN.red, D())
cyl(DEC, CFrame.new(0, F1 + 4.6, -50.9) * CFrame.Angles(math.pi / 2, 0, 0), "DrumFace", 4.4, 0.1, 0, 0, 0, CARN.canvasW, D())
for _, x in { -14, -8, 8, 14 } do
	box(DEC, "MusicStand", x - 0.1, F1 + 2, -47.1, x + 0.1, F1 + 6, -46.9, CARN.iron, DECO)
	box(DEC, "Sheet", x - 1, F1 + 5.4, -47.2, x + 1, F1 + 6.8, -47, CARN.canvasW, DECO)
end
for _, x in { -18, -11, 11, 18 } do F.chair(at(x, F1 + 2, -50, "N"), Wd.dark, Fab.red) end
-- the red curtains round the back of the tent, gold stars on them
for d = 246, 294, 4 do
	local p = E(0.975, d)
	local cfc = CFrame.lookAt(Vector3.new(p.X, F1 + 10, p.Z), Vector3.new(CX, F1 + 10, CZ))
	part(DEC, "Curtain", Vector3.new(4.6, 20, 0.4), cfc, (d / 4) % 2 == 0 and CARN.velvet or st(M.Fabric, nil, C3(90, 16, 32)), D())
end
for _, d in { 256, 270, 284 } do
	local p = E(0.955, d, F1 + 15)
	part(DEC, "Star", Vector3.new(2.4, 2.4, 0.2), CFrame.lookAt(p, Vector3.new(CX, p.Y, CZ)) * CFrame.Angles(0, 0, math.pi / 4), CARN.gold, D())
end

-- THE HUMAN CANNON (front left), fire hoops and animal drums round the ring
local cn = model(STR, "Cannon")
local ccf = CFrame.new(-24, F1 + 3.6, 42) * CFrame.Angles(0, 0.5, -0.7)
b(cn, ccf, "Barrel", 3.4, 11, 3.4, 0, 0, 0, CARN.red)
for k = 0, 2 do b(cn, ccf, "Band", 3.6, 0.5, 3.6, 0, -3 + k * 3, 0, CARN.gold, DECO) end
box(cn, "Carriage", -28, F1, 39, -20, F1 + 2.2, 45, CARN.woodD)
for _, z in { 38.6, 45.4 } do cyl(cn, CFrame.new(-24, F1 + 1.8, z) * CFrame.Angles(math.pi / 2, 0, 0), "Wheel", 3.6, 0.6, 0, 0, 0, CARN.iron, D()) end
for _, p in { { -26, 26 }, { 26, 26 } } do
	local hp = model(DEC, "FireHoop")
	box(hp, "Post", p[1] - 0.2, F1, p[2] - 0.2, p[1] + 0.2, F1 + 4, p[2] + 0.2, CARN.iron, DECO)
	for k = 0, 11 do
		local a = k / 12 * math.pi * 2
		b(hp, CFrame.new(p[1], F1 + 7.5, p[2]) * CFrame.Angles(0, 0, a), "Ring", 1.6, 0.35, 0.35, 0, 3.4, 0, k % 2 == 0 and CARN.red or CARN.yellow, DECO)
	end
end
local drums = model(STR, "AnimalDrums")
for _, a in { 0.5, 2.2, 3.8, 5.3 } do
	local p = Vector3.new(CX + math.cos(a) * 30, 0, CZ + math.sin(a) * 30)
	cyl(drums, CFrame.new(p.X, F1 + 1.4, p.Z), "Drum", 4.4, 2.8, 0, 0, 0, CARN.blue)
	cyl(DEC, CFrame.new(p.X, F1 + 2.85, p.Z), "DrumTop", 4.6, 0.15, 0, 0, 0, CARN.yellow, D())
end

-- THE SECRET: the performers' wagon parked against the back-left of the tent, through a curtain in the wall
do
	local p, q = PTS[SECRET_EDGE], PTS[SECRET_EDGE + 1]
	local cf, len = segCF(p[1], p[2], q[1], q[2])
	local inw = cf:PointToObjectSpace(Vector3.new(CX, 0, CZ)).X > 0 and 1 or -1
	local o = -inw -- (outward)
	local c = len / 2
	local wg = model(STR.Exterior, "Wagon") -- (in Exterior: the house box grows round it)
	local WGOLD = CARN.gold
	local WBODY = st(M.WoodPlanks, "PS2_Siding1", C3(130, 24, 30))
	local WH = 12
	-- floor, walls (the side facing the tent is open: the curtain is there), ceiling, roof
	boxW(STR, "WagonFloor", cf, c - 9, 0, o * 1, c + 9, F1 + 0.05, o * 16, CARN.board)
	boxW(wg, "Wall", cf, c - 9.6, F1, o * 1, c - 8.4, F1 + WH, o * 16, WBODY)
	boxW(wg, "Wall", cf, c + 8.4, F1, o * 1, c + 9.6, F1 + WH, o * 16, WBODY)
	boxW(wg, "Wall", cf, c - 9.6, F1, o * 15.4, c + 9.6, F1 + WH, o * 16.6, WBODY)
	boxW(STR, "WagonCeiling", cf, c - 9.6, F1 + WH, o * 1, c + 9.6, F1 + WH + 0.8, o * 16.6, CARN.woodD)
	boxW(DEC, "WagonRoof", cf, c - 10.4, F1 + WH + 0.8, o * 0.4, c + 10.4, F1 + WH + 1.6, o * 17.4, WGOLD, DECO)
	-- (the gap between the tent wall and the wagon: canvas)
	boxW(STR, "WagonJoin", cf, c - 9.6, F1, o * 0.4, c - 2.5, F1 + WH, o * 1.2, CARN.canvasW)
	boxW(STR, "WagonJoin", cf, c + 2.5, F1, o * 0.4, c + 9.6, F1 + WH, o * 1.2, CARN.canvasW)
	boxW(STR, "WagonJoin", cf, c - 2.5, F1 + 9, o * 0.4, c + 2.5, F1 + WH, o * 1.2, CARN.canvasW)
	-- outside: gold trim, big wheels, a painted name
	for _, s2 in { c - 7, c + 7 } do
		local wp = (cf * CFrame.new(o * 16.9, 3.4, -s2)).Position
		cyl(DEC, CFrame.new(wp) * cf.Rotation * CFrame.Angles(0, 0, -math.pi / 2), "WagonWheel", 6.4, 0.8, 0, 0, 0, WGOLD, D())
	end
	boxW(DEC, "WagonTrim", cf, c - 9.8, F1 + WH - 1, o * 16.6, c + 9.8, F1 + WH, o * 17, WGOLD, DECO)
	boxW(DEC, "WagonTrim", cf, c - 9.8, F1, o * 16.6, c + 9.8, F1 + 1, o * 17, WGOLD, DECO)
	-- the curtain (it slides along the wall when its prompt is used)
	local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
	local door = model(sec, "CostumeCurtain")
	door:SetAttribute("Slide", cf.LookVector * 5.2); door:SetAttribute("Action", "Pull aside"); door:SetAttribute("Object", "Heavy curtain")
	boxW(door, "Panel", cf, c - 2.6, F1, -0.5, c + 2.6, F1 + 9, 0.5, CARN.velvet)
	for k = 0, 3 do boxW(door, "Panel", cf, c - 2.2 + k * 1.3, F1, inw * 0.5, c - 2 + k * 1.3, F1 + 9, inw * 0.62, st(M.Fabric, nil, C3(80, 12, 28)), DECO) end
	boxW(door, "Trigger", cf, c - 0.5, F1 + 4, inw * 1.6, c + 0.5, F1 + 5, inw * 2.6, CARN.velvet, { deco = true, t = 1 })
	boxW(DEC, "LightUnder", cf, c - 2.4, F1 + 0.02, inw * 0.6, c + 2.4, F1 + 0.06, inw * 1.4, st(M.Neon, nil, C3(255, 200, 120)), { deco = true, t = 0.5 })
	-- inside: costume racks, a vanity with a bulb mirror, a trunk
	local props = model(DEC, "CostumeProps")
	for k = 0, 2 do
		boxW(props, "Rack", cf, c + 7.5, F1 + 6.5, o * (4 + k * 4), c + 8, F1 + 6.8, o * (6 + k * 4), CARN.iron, DECO)
		for j = 0, 4 do
			boxW(props, "Costume", cf, c + 6.8, F1 + 2.5, o * (3.6 + k * 4 + j * 0.5), c + 7.6, F1 + 6.5, o * (4 + k * 4 + j * 0.5), ({ CARN.red, CARN.blue, CARN.yellow, CARN.green, CARN.white })[j + 1], DECO)
		end
	end
	boxW(props, "Vanity", cf, c - 8.3, F1, o * 6, c - 7, F1 + 3, o * 12, CARN.woodD, DECO)
	local mir = boxW(props, "VanityMirror", cf, c - 8.35, F1 + 3.5, o * 6.5, c - 8.25, F1 + 8, o * 11.5, st(M.Glass, nil, C3(200, 210, 220)), DECO)
	mir.Reflectance = 0.5
	boxW(props, "Trunk", cf, c - 3, F1, o * 12, c + 2, F1 + 2.6, o * 15, CARN.woodD, DECO)
	local glow = boxW(props, "Glow", cf, c - 0.1, F1 + 9, o * 8, c + 0.1, F1 + 9.2, o * 8.2, CARN.bulb, { deco = true, t = 1 })
	light(glow, 18, 0.9, C3(255, 200, 140))
	-- (where the wagon's item lies, for maps/carn_items.luau) and its floor in the footprint (Server/Ghost)
	MAP:SetAttribute("SecretSpot", (cf * CFrame.new(o * 9, F1, -c)).Position)
	local fp = MAP:FindFirstChild("Footprint")
	if fp then
		boxW(fp, "Foot", cf, c - 8, 0, o * 0, c + 8, 1, o * 15, st(M.SmoothPlastic, nil, Color3.new(1, 0, 1)), { deco = true, t = 1, noShadow = true })
	end
	-- (the floor in front of the curtain stays clear)
	local kp = (cf * CFrame.new(inw * 3.5, F1, -c)).Position
	keepClear(kp.X - 3, kp.Z - 3, kp.X + 3, kp.Z + 3, F1)
end

-- lights over the hall: bulbs hanging from the canvas, lanterns on the bleachers
for _, p in { { -30, -30 }, { 30, -30 }, { -30, 26 }, { 30, 26 } } do bulb(p[1], F1 + 24, p[2], 6, C3(255, 210, 150)) end
for _, deg in { 0, 180 } do local p = E(0.8, deg); bulb(p.X, F1 + 20, p.Z, 4, C3(255, 200, 140)) end
for _, p in { { -20, 40 }, { 34, -10 }, { -12, -34 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { 0, -30 }, { -30, 18 }, { 30, -20 }, { 0, 34 }, { -20, -36 }, { 30, 36 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)

-- OUTSIDE: the entrance (a striped awning on gold poles, the marquee above it), bulbs round the eave, guy ropes
local OUT = model(DEC, "Outside")
local fz = math.max(PTS[1][2], PTS[2][2])
for _, x in { -8, 8 } do cyl(OUT, CFrame.new(x, 8.5, fz + 9), "AwningPole", 0.8, 15, 0, 0, 0, CARN.gold, D()) end
for k = 0, 7 do
	local x = -8 + k * 2 + 1
	panel(OUT, "Awning", Vector3.new(x, 17.6, fz - 1), Vector3.new(x, 15.4, fz + 10), Vector3.new(1, 0, 0), 2.05, k % 2 == 0 and CARN.canvasR or CARN.canvasW, 0.3, D())
end
for k = 0, 7 do ball(OUT, CFrame.new(-7 + k * 2, 15, fz + 10), "AwningBulb", 0.6, 0, 0, 0, CARN.bulb, D()) end
carnMarquee("THE BIG TOP", CFrame.new(0, 19.4, fz + 9.7))
-- bulbs along the eave
for i, p in PTS do
	local q = PTS[i % N + 1]
	local a = Vector3.new(p[1], TOP - 0.4, p[2])
	local z = Vector3.new(q[1], TOP - 0.4, q[2])
	local outv = (Vector3.new((a.X + z.X) / 2, 0, (a.Z + z.Z) / 2) - Vector3.new(CX, 0, CZ)).Unit * 1.4
	carnBulbs(OUT, a + outv, z + outv, 3)
end
-- guy ropes from the eave out to stakes (the sides and the back)
for k = 2, N - 1, 2 do
	local p = PTS[k]
	local top = Vector3.new(p[1], TOP, p[2])
	local outv = (Vector3.new(p[1], 0, p[2]) - Vector3.new(CX, 0, CZ)).Unit
	local stake = Vector3.new(p[1], 0.6, p[2]) + outv * 14
	if stake.Z < 50 then
		part(OUT, "GuyRope", Vector3.new(0.2, 0.2, (stake - top).Magnitude), CFrame.lookAt((top + stake) / 2, stake), CARN.canvasW, D())
		box(OUT, "Stake", stake.X - 0.3, 0, stake.Z - 0.3, stake.X + 0.3, 1.4, stake.Z + 0.3, CARN.woodD, DECO)
	end
end
washLight(-30, 84, Vector3.new(-14, TOP + 10, 50), C3(255, 190, 200), 90, 2)
washLight(30, 84, Vector3.new(14, TOP + 10, 50), C3(255, 190, 200), 90, 2)
-- the yard beside the tent is closed off (nobody walks round it): striped boards along z 56
-- (from the entrance's edge: the strip in front of the curved wall is in the house box)
-- (the canvas rises to y 64 over the ring: up to 40 is still inside the tent, Server/Ghost houseBounds)
MAP:SetAttribute("CeilingY", 40)
sideBarrier(10.5, 58.4, function(bm, x1, x2, z)
	for x = x1, x2 - 3, 4 do
		if math.abs(x + 2) > 30 then box(bm, "Board", x, 0, z - 0.2, x + 3.8, 4.6, z + 0.2, (math.floor(x / 4) % 2 == 0) and CARN.red or CARN.white, DECO) end
	end
end)
carnGrounds()
return endMap()
