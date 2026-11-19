-- THE CATHEDRAL (the Ashen Abbey, building 5: THE RED DEMON, then THE DEMON LORD - he throws the furniture, so the
-- nave is full of pews). The great nave, very high: two rows of tall COLUMNS with pointed arches, rows of PEWS down
-- both sides (furniture to throw), a red carpet down the middle, the ALTAR on a dais under a great ROSE WINDOW at the
-- back, candle stands, banners; and the floor of the nave SPLIT OPEN down the middle by glowing cracks of hellfire
-- (decoration, flush with the floor), with smoke and embers coming up. At the back, behind the altar wall with two
-- doorways: the SACRISTY (vestment chests, chalices, a font). Its west end: a TAPESTRY that slides (Secrets).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/abbey_lib.luau tools/build/maps/abb_nave.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 36
local rng = Random.new(45)
beginMap("Abb_Nave", abbTheme({ floor = st(M.Marble, nil, C3(96, 88, 84)) }))
-- (2026-11-19) its own shape: a GOTHIC CATHEDRAL - a steep gable to the yard with a rose window, twin spired towers,
-- flying buttresses down the sides
local TOP = shell2({ H = H, ridge = "z", roof = "gable", rise = 46, over = 2, front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, 20, -30 }, right1 = { 44, 20, -30 },
	win = { w = 5, b = 10, t = 28 }, door = { w = 12, t = 22 } })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "AltarWall", "x", -32, -78, 78, F1, H, { dr(-50, 10, 13), dr(50, 10, 13) }, I)

-- THE COLUMNS down both sides of the nave, pointed arches between them
local cols = model(STR, "Columns")
for z = -22, 50, 12 do
	for _, x in { -30, 30 } do
		cyl(cols, CFrame.new(x, F1 + 11, z), "Column", 3, 22, 0, 0, 0, ABB.stoneL)
		box(DEC, "ColBase", x - 2.2, F1, z - 2.2, x + 2.2, F1 + 1.2, z + 2.2, ABB.stone, DECO)
		box(DEC, "Capital", x - 2.4, F1 + 21.4, z - 2.4, x + 2.4, F1 + 22.6, z + 2.4, ABB.stone, DECO)
		cyl(DEC, CFrame.new(x, F1 + 28, z), "Shaft", 2, 12, 0, 0, 0, ABB.stoneL, D())
	end
end
for z = -22, 38, 12 do
	for _, x in { -30, 30 } do
		part(DEC, "ArchL", Vector3.new(1.6, 9, 2), CFrame.new(x, F1 + 25.5, z + 3) * CFrame.Angles(-0.55, 0, 0), ABB.stone, DECO)
		part(DEC, "ArchR", Vector3.new(1.6, 9, 2), CFrame.new(x, F1 + 25.5, z + 9) * CFrame.Angles(0.55, 0, 0), ABB.stone, DECO)
	end
end
-- the red carpet down the middle, gold edges
box(DEC, "Carpet", -5, F1 + 0.02, -28, 5, F1 + 0.14, 56, ABB.red, DECO)
for _, x in { -5.3, 5.3 } do box(DEC, "CarpetEdge", x - 0.3, F1 + 0.02, -28, x + 0.3, F1 + 0.16, 56, ABB.gold, DECO) end
-- THE CRACKS OF HELLFIRE splitting the nave floor (flush: walkable), smoke and embers rising from them
abbCrack(DEC, Vector3.new(-12, 0, 52), Vector3.new(8, 0, -20), F1 + 0.18, rng, 1.2)
abbCrack(DEC, Vector3.new(-20, 0, 20), Vector3.new(-56, 0, 6), F1 + 0.18, rng, 0.7)
abbCrack(DEC, Vector3.new(10, 0, 10), Vector3.new(60, 0, 30), F1 + 0.18, rng, 0.7)
abbCrack(DEC, Vector3.new(0, 0, -6), Vector3.new(-40, 0, -24), F1 + 0.18, rng, 0.6)
for _, p in { { -6, 40 }, { 2, 14 }, { 6, -12 } } do
	local e = b(DEC, CFrame.new(p[1], F1 + 0.3, p[2]), "Smoke", 4, 0.2, 8, 0, 0, 0, ABB.lava, { deco = true, t = 1 })
	local sm = Instance.new("ParticleEmitter")
	sm.Texture = "rbxasset://textures/particles/smoke_main.dds"; sm.Color = ColorSequence.new(C3(60, 30, 24)); sm.Size = NumberSequence.new(2, 5)
	sm.Transparency = NumberSequence.new(0.75, 1); sm.Lifetime = NumberRange.new(2, 3); sm.Speed = NumberRange.new(2, 4); sm.Rate = 3; sm.Parent = e
	local em = Instance.new("ParticleEmitter")
	em.Texture = "rbxasset://textures/particles/sparkles_main.dds"; em.Color = ColorSequence.new(C3(255, 150, 60)); em.LightEmission = 1; em.Size = NumberSequence.new(0.2, 0)
	em.Lifetime = NumberRange.new(1.5, 2.5); em.Speed = NumberRange.new(3, 6); em.Rate = 6; em.Parent = e
	light(e, 24, 1.4, C3(255, 90, 40))
end
-- THE ALTAR on its dais against the back wall, candle stands, a great cross, the ROSE WINDOW over it
box(STR, "Dais", -16, F1, -31, 16, F1 + 1.4, -20, ABB.marble)
box(STR, "DaisStep", -18, F1, -20, 18, F1 + 0.7, -18, ABB.marble)
box(STR, "Altar", -7, F1 + 1.4, -29, 7, F1 + 5, -25, ABB.marble)
box(DEC, "AltarCloth", -7.2, F1 + 4.6, -29.2, 7.2, F1 + 5.1, -24.8, ABB.red, DECO)
box(DEC, "AltarClothHang", -7.2, F1 + 2.4, -24.85, 7.2, F1 + 5.1, -24.75, ABB.red, DECO)
for _, x in { -5, 5 } do cyl(DEC, CFrame.new(x, F1 + 6.2, -27), "AltarCandle", 0.5, 2.4, 0, 0, 0, ABB.candle, D()); ball(DEC, CFrame.new(x, F1 + 7.6, -27), "Flame", 0.35, 0, 0, 0, ABB.ember, D()) end
box(DEC, "CrossPost", -0.6, F1 + 5, -30.6, 0.6, F1 + 22, -29.8, ABB.gold, DECO)
box(DEC, "CrossBar", -5, F1 + 16, -30.6, 5, F1 + 17.2, -29.8, ABB.gold, DECO)
local rose = cyl(DEC, CFrame.new(0, F1 + 27, -30.9) * CFrame.Angles(math.pi / 2, 0, 0), "RoseWindow", 16, 0.3, 0, 0, 0, ABB.lava, D())
rose.Color = C3(170, 40, 30); rose.Transparency = 0.1
for k = 0, 7 do
	local a = k / 8 * math.pi * 2
	part(DEC, "RoseSpoke", Vector3.new(0.5, 8, 0.4), CFrame.new(0, F1 + 27, -30.7) * CFrame.Angles(0, 0, a) * CFrame.new(0, 4, 0), ABB.stoneD, DECO)
end
cyl(DEC, CFrame.new(0, F1 + 27, -30.6) * CFrame.Angles(math.pi / 2, 0, 0), "RoseHub", 3, 0.4, 0, 0, 0, ABB.stoneD, D())
light(rose, 50, 2, C3(255, 90, 50))
for _, x in { -14, 14 } do abbCandles(DEC, Vector3.new(x, F1 + 1.4, -24), rng, 7) end
-- banners hanging from the arcades, torn
for z = -16, 44, 12 do
	for _, x in { -30, 30 } do
		box(DEC, "Banner", x - 0.1, F1 + 12, z + 4.6, x + 0.1, F1 + 20, z + 7.4, ABB.red, DECO)
		box(DEC, "BannerTrim", x - 0.15, F1 + 19.6, z + 4.5, x + 0.15, F1 + 20.2, z + 7.5, ABB.gold, DECO)
	end
end
-- stained glass high on the side walls
for _, z in { 30, 2, -16 } do
	abbStained(DEC, CFrame.new(-77.8, F1 + 20, z) * CFrame.Angles(0, math.pi / 2, 0), 6, 14)
	abbStained(DEC, CFrame.new(77.8, F1 + 20, z) * CFrame.Angles(0, -math.pi / 2, 0), 6, 14)
end
-- side chapels: candle racks and a saint each
for _, p in { { -66, 40 }, { 66, 40 }, { -66, -14 }, { 66, -14 } } do
	box(STR, "CandleRack", p[1] - 3, F1, p[2] - 1, p[1] + 3, F1 + 3, p[2] + 1, ABB.iron)
	for k = 0, 9 do
		local cx = p[1] - 2.6 + (k % 5) * 1.3
		local cz = p[2] - 0.5 + math.floor(k / 5)
		cyl(DEC, CFrame.new(cx, F1 + 3.4, cz), "RackCandle", 0.3, 0.8, 0, 0, 0, ABB.candle, D())
		ball(DEC, CFrame.new(cx, F1 + 3.95, cz), "Flame", 0.2, 0, 0, 0, ABB.ember, D())
	end
	local g = b(DEC, CFrame.new(p[1], F1 + 5, p[2]), "RackGlow", 0.2, 0.2, 0.2, 0, 0, 0, ABB.ember, { deco = true, t = 1 })
	light(g, 18, 1.2, C3(255, 170, 90))
end
-- THE SACRISTY (behind the altar wall): vestment chests, a font, chalices on a shelf
for _, p in { { -36, -50 }, { 20, -52 }, { 40, -48 } } do
	box(STR, "VestChest", p[1] - 3.5, F1, p[2] - 2, p[1] + 3.5, F1 + 3, p[2] + 2, ABB.beam)
	box(DEC, "ChestBand", p[1] - 3.6, F1 + 1.4, p[2] - 2.1, p[1] + 3.6, F1 + 1.8, p[2] + 2.1, ABB.gold, DECO)
end
cyl(STR, CFrame.new(0, F1 + 1.6, -46), "Font", 5, 3.2, 0, 0, 0, ABB.marble)
cyl(DEC, CFrame.new(0, F1 + 3.25, -46), "FontWater", 4.2, 0.1, 0, 0, 0, st(M.Glass, nil, C3(120, 30, 20)), D())
box(DEC, "Shelf", -10, F1 + 6, -57.8, 10, F1 + 6.4, -56.6, ABB.beam, DECO)
for k = 0, 5 do cyl(DEC, CFrame.new(-8 + k * 3.2, F1 + 7, -57.2), "Chalice", 0.8, 1.2, 0, 0, 0, ABB.gold, D()) end
-- THE STASH behind the tapestry (x -78..-58, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", -58.2, F1, -58, -57, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", -78, F1, -43.2, -70, F1 + 12, -42, ABB.stoneD)
box(sr, "Wall", -64, F1, -43.2, -58.2, F1 + 12, -42, ABB.stoneD)
box(sr, "Lintel", -70, F1 + 9, -43.2, -64, F1 + 12, -42, ABB.stoneD)
box(sr, "Ceiling", -78, F1 + 12, -58, -57, F1 + 12.6, -42, ABB.stone)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "Tapestry")
door:SetAttribute("Slide", Vector3.new(6.4, 0, 0)); door:SetAttribute("Action", "Pull"); door:SetAttribute("Object", "Heavy tapestry")
box(door, "Panel", -70, F1, -42.9, -64, F1 + 9.5, -40.6, ABB.red)
box(door, "Panel", -70.2, F1 + 9.3, -42.9, -63.8, F1 + 9.8, -40.5, ABB.gold, DECO)
box(door, "Panel", -68, F1 + 3, -40.65, -66, F1 + 7, -40.4, ABB.gold, DECO)
box(door, "Trigger", -67.5, F1 + 4, -39.6, -66.5, F1 + 5, -38.6, ABB.red, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", -63 + k * 1.4, F1 + 0.06, -40 + k * 0.2, -62 + k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(120, 110, 96)), DECO) end
local loot = model(DEC, "Stash")
abbCandles(loot, Vector3.new(-74, F1, -54), rng, 6)
box(loot, "Reliquary", -66, F1, -56, -61, F1 + 3, -53, ABB.gold, DECO)
local sg = b(loot, CFrame.new(-66, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, ABB.holy, { deco = true, t = 1 })
light(sg, 18, 1, C3(255, 200, 140))

-- lights: great iron chandeliers down the nave, a red glow
for _, z in { -10, 14, 38 } do bulb(0, F1 + H - 1, z, 10, C3(255, 170, 100)) end
for _, p in { { -50, 14 }, { 50, 14 }, { -30, -46 }, { 30, -46 } } do bulb(p[1], F1 + H - 1, p[2], 8, C3(255, 150, 90)) end
for _, p in { { -20, 30 }, { 20, 0 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 50 }, { 40, 50 }, { 0, 30 }, { -46, 0 }, { 46, 0 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(-62, -42, -54, -34, F1)
keepClear(-20, -32, 20, -16, F1) -- (the altar's dais)
-- OUTSIDE (2026-11-19): THE DEMON'S CATHEDRAL. The front gable carries a great ROSE WINDOW glowing red; two square
-- TOWERS with lancets, pinnacles and spires stand at its corners; FLYING BUTTRESSES arch over to piers down both
-- sides; the portal is three pointed arches deep; and the hellfire crack runs out of the door across the yard.
local OUT = model(DEC, "Outside")
-- the rose window: petals of glass round a hub, stone tracery, a rim
local RC, RR = Vector3.new(0, TOP + 14, 60.4), 13
local pet = {}
for k = 0, 16 do local a = 2 * math.pi * k / 16; table.insert(pet, RC + Vector3.new(RR * math.cos(a), RR * math.sin(a), 0)) end
local GL = { st(M.Neon, nil, C3(190, 40, 30)), st(M.Neon, nil, C3(60, 70, 170)), st(M.Neon, nil, C3(220, 170, 50)) }
for k = 1, 16 do
	tri(OUT, "RosePetal", RC, pet[k], pet[k + 1], GL[k % 3 + 1], 0.3, D())
	part(OUT, "Tracery", Vector3.new(0.7, 0.7, RR), CFrame.lookAt((RC + pet[k]) / 2 + Vector3.new(0, 0, 0.3), pet[k] + Vector3.new(0, 0, 0.3)), ABB.stoneD, D())
	part(OUT, "RoseRim", Vector3.new(1.2, 1.2, (pet[k + 1] - pet[k]).Magnitude + 0.5), CFrame.lookAt((pet[k] + pet[k + 1]) / 2 + Vector3.new(0, 0, 0.3), pet[k + 1] + Vector3.new(0, 0, 0.3)), ABB.stone, D())
end
cyl(OUT, CFrame.new(RC + Vector3.new(0, 0, 0.5)) * CFrame.Angles(math.pi / 2, 0, 0), "RoseHub", 3, 0.6, 0, 0, 0, ABB.stoneD, D())
light(box(OUT, "RoseGlow", -0.1, TOP + 14, 64, 0.1, TOP + 14.2, 64.2, ABB.lava, { deco = true, t = 1 }), 50, 1.6, C3(255, 90, 50))
-- the twin towers at the front corners (solid at the foot), lancets, pinnacles, spires
for _, sx in { -1, 1 } do
	local tx, tz, half = sx * 86, 50, 11
	box(OUT, "Tower", tx - half, 0, tz - half, tx + half, TOP + 34, tz + half, ABB.stone) -- (solid)
	for _, y in { 14, 40, 62 } do
		box(OUT, "TowerLancet", tx - 1.6, y, tz + half + 0.1, tx + 1.6, y + 10, tz + half + 0.4, (y == 62) and st(M.Neon, nil, C3(255, 110, 50)) or st(M.SmoothPlastic, nil, C3(14, 8, 8)), DECO)
		box(OUT, "TowerBand", tx - half - 0.5, y + 12, tz - half - 0.5, tx + half + 0.5, y + 13, tz + half + 0.5, ABB.stoneD, DECO)
	end
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do spire(OUT, tx + c[1] * half, tz + c[2] * half, 2.2, TOP + 34, 12, 4, ABB.stone, D()) end
	spire(OUT, tx, tz, half - 1, TOP + 34, 50, 8, st(M.Slate, nil, C3(34, 32, 36)), D())
	box(OUT, "TowerCross", tx - 0.4, TOP + 84, tz - 0.4, tx + 0.4, TOP + 90, tz + 0.4, ABB.iron, DECO)
	light(box(OUT, "TowerGlow", tx - 0.1, 66, tz + half + 2, tx + 0.1, 66.2, tz + half + 2.2, ABB.lava, { deco = true, t = 1 }), 26, 1.2, C3(255, 110, 50))
end
-- flying buttresses down both sides: a pier out in the ash, an arch over to the wall's top, a pinnacle
for _, sx in { -1, 1 } do
	for _, z in { -42, -16, 10, 34 } do
		local px = sx * 100
		box(OUT, "Pier", px - 2.5, 0, z - 2.5, px + 2.5, TOP + 6, z + 2.5, ABB.stone, DECO)
		spire(OUT, px, z, 2.6, TOP + 6, 12, 4, ABB.stone, D())
		local a, c = Vector3.new(px - sx * 2.5, TOP, z), Vector3.new(sx * 80, TOP - 4, z)
		part(OUT, "FlyingArch", Vector3.new(2.2, 2.6, (c - a).Magnitude + 1), CFrame.lookAt((a + c) / 2, c), ABB.stoneD, D())
		local a2, c2 = Vector3.new(px - sx * 2.5, TOP - 12, z), Vector3.new(sx * 80, TOP - 16, z)
		part(OUT, "FlyingArch", Vector3.new(2, 2.2, (c2 - a2).Magnitude + 1), CFrame.lookAt((a2 + c2) / 2, c2), ABB.stoneD, D())
	end
end
-- the portal: three pointed arches deep, statues in niches either side
for k = 0, 2 do abbArch(OUT, 0, 2, 60.6 + k * 1, 16 + k * 3.6, 22, k % 2 == 0 and ABB.stoneD or ABB.stone, 1.4, 1) end
for _, sx in { -1, 1 } do
	box(OUT, "StatueNiche", sx * 15 - 2.4, 4, 60.1, sx * 15 + 2.4, 16, 60.5, st(M.SmoothPlastic, nil, C3(20, 14, 12)), DECO)
	local cf = CFrame.new(sx * 15, 4, 61) * CFrame.Angles(0, math.pi, 0)
	b(OUT, cf, "SaintRobe", 2.6, 8, 1.6, 0, 4, 0, ABB.marble, D())
	b(OUT, cf, "SaintHead", 1.4, 1.6, 1.4, 0, 8.8, 0, ABB.marble, D())
end
-- the gable's crockets and the cross at its top
for _, sx in { -1, 1 } do
	for k = 1, 6 do
		local u = k / 7
		local p0 = Vector3.new(sx * 80 * (1 - u), TOP + 46 * u + 1, 60.6)
		part(OUT, "Crocket", Vector3.new(1.4, 2, 1.4), CFrame.new(p0) * CFrame.Angles(0, 0, -sx * 0.5), ABB.stone, D())
	end
end
box(OUT, "GableCross", -0.6, TOP + 46, 59.4, 0.6, TOP + 56, 60.6, ABB.iron, DECO)
box(OUT, "GableCross", -3, TOP + 51.4, 59.4, 3, TOP + 52.6, 60.6, ABB.iron, DECO)
-- the crack of hellfire out of the door across the yard
do
	local crng = Random.new(666)
	local prev = Vector3.new(0, 0, 62)
	for k = 1, 9 do
		local p0 = Vector3.new(crng:NextNumber(-4, 4), 0, 62 + k * 6)
		local mid = (prev + p0) / 2
		part(OUT, "HellCrack", Vector3.new(crng:NextNumber(1, 2.2), 0.2, (p0 - prev).Magnitude + 1), CFrame.lookAt(Vector3.new(mid.X, 0.36, mid.Z), Vector3.new(p0.X, 0.36, p0.Z)), ABB.lava, D())
		if k % 3 == 0 then light(box(OUT, "CrackGlow", mid.X - 0.1, 1.4, mid.Z - 0.1, mid.X + 0.1, 1.6, mid.Z + 0.1, ABB.lava, { deco = true, t = 1 }), 24, 1.4, C3(255, 90, 40)) end
		prev = p0
	end
end
abbSign("THE CATHEDRAL", CFrame.new(0, 30, 62.6))
washLight(-34, 90, Vector3.new(-14, TOP + 18, 60), C3(255, 150, 120), 110, 2.2)
washLight(34, 90, Vector3.new(14, TOP + 18, 60), C3(255, 150, 120), 110, 2.2)
abbGrounds()
return endMap()
