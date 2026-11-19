-- THE BIG TOP (the Moonlight Carnival, building 1: THE RINGMASTER, whose whip pulls you in and wakes the
-- mannequins in the stands). One huge tent hall, 34 high: the RING in the middle (a red and white curb, sawdust, his
-- podium, two striped king poles to hide behind), BLEACHERS down both long walls full of seated MANNEQUINS (folder
-- Mannequins: Server/CarnivalMonsters wakes them), the band stand at the back, the human cannon, fire hoops,
-- trapezes and bunting overhead. The SECRET: the curtain in the back-left corner is not a backdrop - behind it is
-- the costume room (Secrets folder, a tier-3 item spot from maps/carn_items.luau).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/carnival_lib.luau tools/build/maps/carn_bigtop.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 34
beginMap("Carn_BigTop", carnTheme({ ext = CARN.canvasR, inner = CARN.canvasW, wain = false, floor = CARN.board }))
shell({ two = false, H = H, roof = "gable", pitch = 0.5, front1 = { -60, -36, 36, 60 }, back1 = {}, left1 = { 44, 0, -44 }, right1 = { 44, 0, -44 },
	winW = 6, winB = 6, winT = 14 })
carnFrieze(H)
local inn = model(STR, "Interior")
local top = F1 + H

-- THE RING: a curb of red and white blocks, sawdust inside, the podium, two king poles
local ring = model(STR, "Ring")
local R = 22
for k = 0, 27 do
	local a = k / 28 * math.pi * 2
	b(ring, CFrame.new(0, F1, 0) * CFrame.Angles(0, a, 0), "Curb", 5.2, 1.3, 1.3, 0, 0.65, -R, k % 2 == 0 and CARN.red or CARN.white)
end
cyl(DEC, CFrame.new(0, F1 + 0.04, 0), "Sawdust", R * 2 - 1, 0.08, 0, 0, 0, CARN.sawdust, D())
cyl(ring, CFrame.new(0, F1 + 0.6, 0), "Podium", 6, 1.2, 0, 0, 0, CARN.red)
cyl(DEC, CFrame.new(0, F1 + 1.25, 0), "PodiumRim", 6.3, 0.15, 0, 0, 0, CARN.gold, D())
for _, x in { -11, 11 } do
	local pole = model(STR, "KingPole")
	for k = 0, math.floor(H / 3) - 1 do
		cyl(pole, CFrame.new(x, F1 + 1.5 + k * 3, 0), "Pole", 1.8, 3, 0, 0, 0, k % 2 == 0 and CARN.red or CARN.white)
	end
	cyl(pole, CFrame.new(x, F1 + 0.4, 0), "Foot", 3, 0.8, 0, 0, 0, CARN.iron)
end
-- bunting from the pole tops to the walls, a trapeze high over the ring
for _, x in { -11, 11 } do
	for _, z in { -50, -20, 20, 50 } do carnBunting(DEC, Vector3.new(x, top - 3, 0), Vector3.new(x * 6.5, top - 6, z), 12) end
end
local tr = model(DEC, "Trapeze")
for _, x in { -4, 4 } do box(tr, "Rope", x - 0.1, top - 12, -12.1, x + 0.1, top - 1, -11.9, CARN.canvasW, DECO) end
cyl(tr, CFrame.new(0, top - 12, -12) * CFrame.Angles(0, math.pi / 2, 0), "Bar", 0.3, 8.4, 0, 0, 0, CARN.gold, D())
-- spotlights on the ring (and the ring lit)
for _, p in { { -16, -16 }, { 16, -16 }, { 0, 18 } } do
	local sp = b(DEC, CFrame.new(p[1], top - 1.5, p[2]), "Spot", 1.4, 1.4, 1.4, 0, 0, 0, CARN.iron, D())
	local l = Instance.new("SpotLight"); l.Face = Enum.NormalId.Bottom; l.Range = 45; l.Angle = 40; l.Brightness = 1.6; l.Color = C3(255, 236, 200); l.Parent = sp
end

-- THE BLEACHERS: four tiers down each long wall, seated mannequins on them
local mq = Instance.new("Folder"); mq.Name = "Mannequins"; mq.Parent = MAP
local rng = Random.new(42)
for _, side in { -1, 1 } do
	local bl = model(STR, "Bleachers")
	for t = 0, 3 do
		local x0 = side * (44 + t * 8)
		local x1 = side * (44 + (t + 1) * 8)
		local y = F1 + 2.2 * (t + 1)
		box(bl, "Tier", math.min(x0, x1), F1, -40, math.max(x0, x1), y, 40, CARN.board)
		box(bl, "Edge", math.min(x0, x1), y - 0.3, -40.1, math.max(x0, x1), y + 0.05, 40.1, t % 2 == 0 and CARN.red or CARN.white, DECO)
		for z = -34, 34, 9 do
			if rng:NextNumber() < 0.5 then
				carnMannequin(mq, CFrame.new(side * (44 + t * 8 + 4.4), y, z + rng:NextNumber(-1.5, 1.5)) * CFrame.Angles(0, side < 0 and -math.pi / 2 or math.pi / 2, 0))
			end
		end
	end
	-- the handrail along the front of the bleachers
	box(bl, "Rail", side * 43.6 - 0.2, F1 + 3.2, -40, side * 43.6 + 0.2, F1 + 3.6, 40, CARN.gold, DECO)
end

-- THE BAND STAND at the back: a stage, a bass drum, music stands, a tuba
local bs = model(STR, "BandStand")
box(bs, "Stage", -22, F1, -58, 22, F1 + 2, -42, CARN.board)
box(bs, "StageFront", -22, F1, -42.1, 22, F1 + 2, -41.9, CARN.velvet, DECO)
cyl(DEC, CFrame.new(0, F1 + 4.6, -52) * CFrame.Angles(0, math.pi / 2, 0), "BassDrum", 5, 2, 0, 0, 0, CARN.red, D())
cyl(DEC, CFrame.new(0, F1 + 4.6, -50.9) * CFrame.Angles(0, math.pi / 2, 0), "DrumFace", 4.4, 0.1, 0, 0, 0, CARN.canvasW, D())
for _, x in { -14, -8, 8, 14 } do
	box(DEC, "MusicStand", x - 0.1, F1 + 2, -47.1, x + 0.1, F1 + 6, -46.9, CARN.iron, DECO)
	box(DEC, "Sheet", x - 1, F1 + 5.4, -47.2, x + 1, F1 + 6.8, -47, CARN.canvasW, DECO)
end
for _, x in { -18, -11, 11, 18 } do F.chair(at(x, F1 + 2, -50, "N"), Wd.dark, Fab.red) end
-- the backdrop: red curtains along the back wall, gold stars
for x = -76, 72, 4 do box(DEC, "Curtain", x, F1, -57.8, x + 4, F1 + 20, -57.4, (x / 4) % 2 == 0 and CARN.velvet or st(M.Fabric, nil, C3(90, 16, 32)), DECO) end
for _, p in { { -30, 14 }, { 0, 17 }, { 30, 14 } } do b(DEC, CFrame.new(p[1], F1 + p[2], -57.2) * CFrame.Angles(0, 0, math.pi / 4), "Star", 2.4, 2.4, 0.2, 0, 0, 0, CARN.gold, D()) end

-- THE HUMAN CANNON (front left), fire hoops and animal drums round the ring
local cn = model(STR, "Cannon")
b(cn, CFrame.new(-44, F1 + 3.6, 34) * CFrame.Angles(0, 0.6, -0.7), "Barrel", 3.4, 11, 3.4, 0, 0, 0, CARN.red)
for k = 0, 2 do b(cn, CFrame.new(-44, F1 + 3.6, 34) * CFrame.Angles(0, 0.6, -0.7), "Band", 3.6, 0.5, 3.6, 0, -3 + k * 3, 0, CARN.gold, DECO) end
box(cn, "Carriage", -48, F1, 31, -40, F1 + 2.2, 37, CARN.woodD)
for _, z in { 30.6, 37.4 } do cyl(cn, CFrame.new(-44, F1 + 1.8, z) * CFrame.Angles(0, math.pi / 2, 0), "Wheel", 3.6, 0.6, 0, 0, 0, CARN.iron, D()) end
for _, p in { { -26, 28 }, { 26, 28 } } do
	local hp = model(DEC, "FireHoop")
	box(hp, "Post", p[1] - 0.2, F1, p[2] - 0.2, p[1] + 0.2, F1 + 4, p[2] + 0.2, CARN.iron, DECO)
	for k = 0, 11 do
		local a = k / 12 * math.pi * 2
		b(hp, CFrame.new(p[1], F1 + 7.5, p[2]) * CFrame.Angles(0, 0, a), "Ring", 1.6, 0.35, 0.35, 0, 3.4, 0, k % 2 == 0 and CARN.red or CARN.yellow, DECO)
	end
end
local drums = model(STR, "AnimalDrums")
for _, a in { 0.5, 2.2, 3.8, 5.3 } do
	local p = Vector3.new(math.cos(a) * 30, 0, math.sin(a) * 30)
	if math.abs(p.X) < 40 then
		cyl(drums, CFrame.new(p.X, F1 + 1.4, p.Z), "Drum", 4.4, 2.8, 0, 0, 0, CARN.blue)
		cyl(DEC, CFrame.new(p.X, F1 + 2.85, p.Z), "DrumTop", 4.6, 0.15, 0, 0, 0, CARN.yellow, D())
	end
end

-- THE SECRET: the costume room in the back-left corner (x -78..-58, z -58..-40); its door is a curtain that slides
local cr = model(STR, "CostumeRoom")
local CH = 12
box(cr, "Wall", -58.6, F1, -58, -57.4, F1 + CH, -40, CARN.canvasW)
box(cr, "Wall", -78, F1, -40.6, -72, F1 + CH, -39.4, CARN.canvasW)
box(cr, "Wall", -68, F1, -40.6, -57.4, F1 + CH, -39.4, CARN.canvasW)
box(cr, "Lintel", -72, F1 + 8, -40.6, -68, F1 + CH, -39.4, CARN.canvasW)
box(cr, "Ceiling", -78, F1 + CH, -58, -57.4, F1 + CH + 0.6, -39.4, CARN.woodD)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "CostumeCurtain")
door:SetAttribute("Slide", Vector3.new(4.2, 0, 0)); door:SetAttribute("Action", "Pull aside"); door:SetAttribute("Object", "Heavy curtain")
box(door, "Panel", -72, F1, -40.5, -68, F1 + 8, -39.5, CARN.velvet)
for k = 0, 3 do box(door, "Panel", -71.8 + k, F1, -39.45, -71.6 + k, F1 + 8, -39.35, st(M.Fabric, nil, C3(80, 12, 28)), DECO) end
box(door, "Trigger", -70.5, F1 + 4, -38.6, -69.5, F1 + 5, -37.6, CARN.velvet, { deco = true, t = 1 })
-- (the clue: a draft - the curtain hangs a little short, light under it)
box(DEC, "LightUnder", -72, F1 + 0.02, -39.3, -68, F1 + 0.06, -38.6, st(M.Neon, nil, C3(255, 200, 120)), { deco = true, t = 0.5 })
local props = model(DEC, "CostumeProps")
for k = 0, 2 do
	box(props, "Rack", -76, F1 + 6.5, -56 + k * 5, -70, F1 + 6.8, -55.6 + k * 5, CARN.iron, DECO)
	for j = 0, 4 do box(props, "Costume", -75.5 + j * 1.2, F1 + 2.5, -56.2 + k * 5, -74.7 + j * 1.2, F1 + 6.5, -55.4 + k * 5, ({ CARN.red, CARN.blue, CARN.yellow, CARN.green, CARN.white })[j + 1], DECO) end
end
box(props, "Vanity", -60, F1, -50, -58.7, F1 + 3, -44, CARN.woodD, DECO)
box(props, "VanityMirror", -58.75, F1 + 3.5, -49.5, -58.65, F1 + 8, -44.5, st(M.Glass, nil, C3(200, 210, 220)), DECO).Reflectance = 0.5
carnBulbs(props, Vector3.new(-58.6, F1 + 8.3, -49.5), Vector3.new(-58.6, F1 + 8.3, -44.5), 0.8)
box(props, "Trunk", -68, F1, -57, -63, F1 + 2.6, -54, CARN.woodD, DECO)
local glow = b(props, CFrame.new(-66, F1 + 9, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, CARN.bulb, { deco = true, t = 1 })
light(glow, 18, 0.9, C3(255, 200, 140))

-- lights over the hall, the bleachers
for _, p in { { -30, -30 }, { 30, -30 }, { -30, 30 }, { 30, 30 } } do bulb(p[1], top - 1, p[2], 6, C3(255, 210, 150)) end
for _, x in { -60, 60 } do for _, z in { -24, 24 } do bulb(x, top - 1, z, 4, C3(255, 200, 140)) end end
for _, p in { { -20, 40 }, { 34, -10 }, { -12, -34 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { 0, -30 }, { -30, 20 }, { 30, -20 }, { 0, 34 }, { -30, -34 }, { 30, 36 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-72, -40, -68, -36, F1) -- (in front of the curtain)
carnMarquee("THE BIG TOP")
carnGrounds()
return endMap()
