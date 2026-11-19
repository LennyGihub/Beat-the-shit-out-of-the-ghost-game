-- THE BLACK GATE (the Black Moon, building 5, the end of the campaign: THE CONQUEROR, then THE GOLDEN CONQUEROR). The
-- base's last hall, built round what they dug up: a huge RING OF BLACK STONE standing on its edge against the back
-- wall, a violet PORTAL swirling inside it (where he came through), carved runes glowing round the ring, broken
-- MACHINERY that was meant to hold it shut (pylons with dead coils - cover), black crystal shards bursting out of the
-- floor (cover), cracks of violet light across the floor (flush), scattered research gear. At the back, behind the
-- gate wall with two doorways: the OBSERVATION ROOM (a long window on the ring, desks, the last log). Its east end: a
-- BLAST DOOR that slides (Secrets).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_gate.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 34
local rng = Random.new(55)
local OBSIDIAN = st(M.Basalt, nil, C3(26, 22, 32))
local RUNE = st(M.Neon, nil, C3(190, 120, 255))
local VOIDC = st(M.Neon, nil, C3(110, 50, 200))
beginMap("Moon_Gate", moonTheme({ floor = st(M.Slate, nil, C3(56, 54, 64)), inner = st(M.Slate, nil, C3(80, 78, 92)) }))
-- (2026-11-19) its own shape: a sloped ARMOURED BUNKER, black crystals bursting out of it, a violet beam into the sky
local TOP = shell2({ H = H, roof = "flat", roofStyle = st(M.Metal, nil, C3(40, 40, 48)), front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, -30 }, right1 = { 44, -30 },
	win = { w = 5, b = 8, t = 14 }, door = { w = 14, t = 20 } })
local inn = model(STR, "Interior")
local I = INT()
wall(inn, "GateWall", "x", -32, -78, 78, F1, H, { dr(-60, 10, 12), dr(60, 10, 12) }, I)

-- THE RING OF BLACK STONE standing against the gate wall: segments of obsidian round a violet portal
local ring = model(DEC, "GateRing")
local center = Vector3.new(0, F1 + 15, -29)
for k = 0, 23 do
	local a = k / 24 * math.pi * 2
	local p = center + Vector3.new(math.cos(a) * 14, math.sin(a) * 14, 0)
	if p.Y < F1 - 0.5 then continue end
	part(ring, "Segment", Vector3.new(6, 3.6, 4), CFrame.new(p) * CFrame.Angles(0, 0, a + math.pi / 2), OBSIDIAN, DECO)
	if k % 2 == 0 then part(ring, "Rune", Vector3.new(1.2, 1.2, 0.2), CFrame.new(p + Vector3.new(0, 0, 2.05)) * CFrame.Angles(0, 0, a + math.pi / 4), RUNE, DECO) end
end
local portal = cyl(ring, CFrame.new(center + Vector3.new(0, 0, 0.4)) * CFrame.Angles(math.pi / 2, 0, 0), "Portal", 25, 0.4, 0, 0, 0, VOIDC, D())
portal.Transparency = 0.15
cyl(ring, CFrame.new(center + Vector3.new(0, 0, 0.7)) * CFrame.Angles(math.pi / 2, 0, 0), "PortalCore", 14, 0.3, 0, 0, 0, st(M.Neon, nil, C3(20, 6, 40)), D())
for k = 0, 5 do
	local a = k / 6 * math.pi * 2
	part(ring, "Swirl", Vector3.new(1.2, 11, 0.2), CFrame.new(center + Vector3.new(0, 0, 0.9)) * CFrame.Angles(0, 0, a) * CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, 0.5), RUNE, DECO).Transparency = 0.3
end
light(portal, 70, 3, C3(170, 100, 255))
local pe = Instance.new("ParticleEmitter")
pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"; pe.Color = ColorSequence.new(C3(200, 150, 255), C3(110, 50, 200)); pe.LightEmission = 1
pe.Size = NumberSequence.new(0.5, 0); pe.Lifetime = NumberRange.new(1.5, 2.5); pe.Speed = NumberRange.new(2, 6); pe.Rate = 12
pe.EmissionDirection = Enum.NormalId.Top; pe.SpreadAngle = Vector2.new(60, 60); pe.Parent = portal
-- the base of the ring: a stepped plinth of black stone
box(STR, "Plinth", -20, F1, -30.6, 20, F1 + 1.2, -24, OBSIDIAN)
box(STR, "PlinthStep", -16, F1, -24, 16, F1 + 0.6, -21, OBSIDIAN)
-- THE BROKEN MACHINERY round it: pylons with dead coils and cables (cover)
local pyl = model(STR, "Pylons")
for _, p in { { -34, -12 }, { 34, -12 }, { -46, 22 }, { 46, 22 }, { -24, 44 }, { 24, 44 } } do
	box(pyl, "Pylon", p[1] - 2, F1, p[2] - 2, p[1] + 2, F1 + 14, p[2] + 2, MOON.steelD)
	for k = 0, 3 do cyl(DEC, CFrame.new(p[1], F1 + 6 + k * 2, p[2]), "Coil", 5, 0.8, 0, 0, 0, st(M.Metal, nil, C3(150, 100, 50)), D()) end
	local tip = ball(DEC, CFrame.new(p[1], F1 + 15, p[2]), "Tip", 2.4, 0, 0, 0, st(M.Neon, nil, C3(80, 60, 110)), D())
	local _ = tip
	-- a cable snaking to the ring
	local a = Vector3.new(p[1], F1 + 0.4, p[2])
	local z = Vector3.new(p[1] * 0.4, F1 + 0.4, -22)
	part(DEC, "Cable", Vector3.new(0.6, 0.6, (z - a).Magnitude), CFrame.lookAt((a + z) / 2, z), MOON.black, DECO)
end
-- BLACK CRYSTALS bursting out of the floor (cover)
local cry = model(STR, "Crystals")
for _, p in { { -12, 12 }, { 14, 26 }, { -50, 46 }, { 54, 48 }, { -58, -18 }, { 60, -20 } } do
	for k = 0, 2 do
		local h = rng:NextNumber(5, 10)
		part(k == 0 and cry or DEC, "Crystal", Vector3.new(2.4, h, 2.4), CFrame.new(p[1] + (k - 1) * 1.6, F1 + h / 2 - 0.5, p[2] + rng:NextNumber(-1, 1)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6), rng:NextNumber(-0.3, 0.3)), OBSIDIAN, k == 0 and nil or DECO)
	end
	local g = ball(DEC, CFrame.new(p[1], F1 + 1, p[2]), "CrystalGlow", 1.4, 0, 0, 0, RUNE, D())
	light(g, 16, 1.2, C3(170, 100, 255))
end
-- cracks of violet light across the floor (flush), from the ring outward
for k = 0, 5 do
	local a = -math.pi / 2 + (k - 2.5) * 0.45
	local from = Vector3.new(0, 0, -22)
	local to = from + Vector3.new(math.sin(a), 0, -math.cos(a)) * rng:NextNumber(30, 70)
	local last = from
	for i = 1, 6 do
		local p = from:Lerp(to, i / 6) + Vector3.new(rng:NextNumber(-2, 2), 0, rng:NextNumber(-2, 2))
		local mid = (last + p) / 2
		part(DEC, "VoidCrack", Vector3.new(0.6, 0.08, (p - last).Magnitude + 0.3), CFrame.lookAt(Vector3.new(mid.X, F1 + 0.08, mid.Z), Vector3.new(p.X, F1 + 0.08, p.Z)), RUNE, DECO)
		last = p
	end
end
-- research gear left behind: a cart of instruments, a fallen floodlight, crates
box(STR, "InstrumentCart", -40, F1, 2, -32, F1 + 3.4, 6, MOON.panel)
moonScreen(DEC, CFrame.new(-36, F1 + 5, 5.6) * CFrame.Angles(0, math.pi, 0), 4, 2.4, C3(200, 120, 255))
part(DEC, "FallenLight", Vector3.new(3, 3, 1.4), CFrame.new(30, F1 + 1.5, 6) * CFrame.Angles(0.8, 0.6, 0), MOON.steelD, DECO)
-- THE OBSERVATION ROOM (behind the wall): a long window looking at the back of the ring, desks, the last log
box(DEC, "ObsWindow", -40, F1 + 6, -33.4, 40, F1 + 14, -33.1, MOON.glass, { deco = true, t = 0.7 })
for _, x in { -30, -10, 10, 30 } do
	box(STR, "ObsDesk", x - 5, F1, -40, x + 5, F1 + 3, -36, MOON.panelD)
	moonScreen(DEC, CFrame.new(x, F1 + 5, -36.4) * CFrame.Angles(0, math.pi, 0), 4, 2.4, C3(200, 120, 255))
end
box(DEC, "LogBook", -2, F1 + 3, -39, 2, F1 + 3.3, -37, MOON.orange, DECO)
-- THE STASH behind the blast door (x 50..78, z -58..-42)
local sr = model(STR, "StashRoom")
box(sr, "Wall", 49, F1, -58, 50.2, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", 50.2, F1, -43.2, 60, F1 + 12, -42, MOON.steelD)
box(sr, "Wall", 66, F1, -43.2, 78, F1 + 12, -42, MOON.steelD)
box(sr, "Lintel", 60, F1 + 9, -43.2, 66, F1 + 12, -42, MOON.steelD)
box(sr, "Ceiling", 49, F1 + 12, -58, 78, F1 + 12.6, -42, MOON.panelD)
local sec = Instance.new("Folder"); sec.Name = "Secrets"; sec.Parent = MAP
local door = model(sec, "BlastDoor")
door:SetAttribute("Slide", Vector3.new(-6.4, 0, 0)); door:SetAttribute("Action", "Open"); door:SetAttribute("Object", "Jammed blast door")
box(door, "Panel", 60, F1, -42.9, 66, F1 + 9, -40.6, MOON.steel)
for k = 0, 5 do part(door, "Panel", Vector3.new(0.1, 1, 2), CFrame.new(61 + k * 0.85, F1 + 4.5, -40.5) * CFrame.Angles(0, math.pi / 2, 0.8), k % 2 == 0 and MOON.yellow or MOON.black, DECO) end
box(door, "Trigger", 62.5, F1 + 4, -39.6, 63.5, F1 + 5, -38.6, MOON.steel, { deco = true, t = 1 })
for k = 0, 3 do box(DEC, "Scrape", 59 - k * 1.4, F1 + 0.06, -40 + k * 0.2, 60 - k * 1.4, F1 + 0.08, -38.8 + k * 0.2, st(M.SmoothPlastic, nil, C3(150, 150, 156)), DECO) end
local loot = model(DEC, "Stash")
for k = 0, 2 do part(loot, "Shard", Vector3.new(1.4, 3, 1.4), CFrame.new(64 + k * 3, F1 + 1.5, -54) * CFrame.Angles(0, k, 0.2), RUNE, DECO) end
local sg = b(loot, CFrame.new(64, F1 + 10, -50), "Glow", 0.2, 0.2, 0.2, 0, 0, 0, MOON.violet, { deco = true, t = 1 })
light(sg, 18, 1, C3(200, 150, 255))

-- lights: a few cold strips; the portal lights the hall violet
for _, p in { { -40, 30 }, { 40, 30 }, { 0, 50 } } do fluoro(p[1], F1 + H - 1, p[2], C3(225, 205, 255)) end
for _, p in { { -30, -46 }, { 30, -46 } } do fluoro(p[1], F1 + H - 1, p[2], C3(210, 225, 255)) end
for _, p in { { -30, 30 }, { 20, 10 }, { -40, -48 } } do blood(p[1], F1, p[2], 2) end
for _, p in { { -40, 52 }, { 40, 52 }, { 0, 30 }, { -46, 0 }, { 46, 0 }, { 0, -46 } } do gspawn(p[1], F1, p[2]) end
keepClear(-6, 40, 6, 58, F1)
keepClear(56, -42, 70, -34, F1)
-- OUTSIDE (2026-11-19): THE CONQUEROR'S BLACK GATE. The hall was armoured to keep it shut: sloped steel plates lean on
-- every wall, the great blast door's halves are torn open, BLACK CRYSTALS burst out through the roof and the walls
-- with violet light in their cracks, and the PORTAL's light goes straight up into the sky as a violet beam.
local OUT = model(DEC, "Outside")
local ARMOR = st(M.DiamondPlate, nil, C3(56, 56, 66))
local CRYS = st(M.Glass, nil, C3(26, 18, 38))
local VIO = C3(170, 110, 255)
-- sloped armour: plates leaning on the front (round the door and the windows) and the sides
for _, seg in { { -80, -64 }, { -56, -42 }, { -30, -10 }, { 10, 30 }, { 42, 56 }, { 64, 80 } } do
	local x0, x1 = seg[1], seg[2]
	part(OUT, "Armor", Vector3.new(x1 - x0, TOP + 2, 1.6), CFrame.new((x0 + x1) / 2, TOP / 2, 63.4) * CFrame.Angles(-0.22, 0, 0), ARMOR, D())
end
for _, sx in { -1, 1 } do
	for z = -54, 46, 20 do part(OUT, "Armor", Vector3.new(1.6, TOP + 2, 18.4), CFrame.new(sx * 84.4, TOP / 2, z) * CFrame.Angles(0, 0, sx * 0.22), ARMOR, D()) end
end
-- the blast door's halves torn open, claw-scored
for _, sx in { -1, 1 } do
	part(OUT, "BlastDoor", Vector3.new(10, 22, 2), CFrame.new(sx * 14, 12, 66) * CFrame.Angles(0, sx * 0.9, sx * 0.06), MOON.steelD, D())
	for k = 0, 3 do part(OUT, "Stripe", Vector3.new(10.2, 1.4, 0.2), CFrame.new(sx * 14, 4 + k * 5, 66) * CFrame.Angles(0, sx * 0.9, sx * 0.06) * CFrame.new(0, 0, 1.1), k % 2 == 0 and MOON.yellow or MOON.black, D()) end
end
sign(OUT, "SECTOR 0  -  DO NOT OPEN", CFrame.new(0, 24.4, 61) * CFrame.Angles(0, math.pi, 0), 26, 2.6, MOON.steelD, C3(255, 80, 70), Enum.Font.SciFi)
-- black crystals bursting out: through the roof and from the walls, violet light in them
local crng = Random.new(13)
local function crystal(base: Vector3, dir: Vector3, len: number, w: number)
	local cf = CFrame.lookAt(base, base + dir) * CFrame.new(0, 0, -len / 2)
	part(OUT, "Crystal", Vector3.new(w, w, len), cf * CFrame.Angles(0, 0, math.pi / 4), CRYS, { deco = true, t = 0.08 })
	part(OUT, "CrystalCore", Vector3.new(w * 0.35, w * 0.35, len * 0.9), cf * CFrame.Angles(0, 0, math.pi / 4), st(M.Neon, nil, VIO), D())
	part(OUT, "CrystalTip", Vector3.new(w * 0.7, w * 0.7, w * 1.2), cf * CFrame.new(0, 0, -len / 2 - w * 0.4) * CFrame.Angles(0, 0, math.pi / 4), CRYS, D())
end
for k = 1, 9 do
	local base = Vector3.new(crng:NextNumber(-60, 60), TOP, crng:NextNumber(-50, 30))
	crystal(base, Vector3.new(crng:NextNumber(-0.6, 0.6), 1, crng:NextNumber(-0.6, 0.6)).Unit, crng:NextNumber(14, 34), crng:NextNumber(4, 9))
end
for _, c in { { -80, 10, -1 }, { 80, -20, 1 }, { -46, 59, 0 }, { 50, 59, 0 } } do
	local dir = c[3] ~= 0 and Vector3.new(c[3], 0.5, crng:NextNumber(-0.3, 0.3)) or Vector3.new(crng:NextNumber(-0.3, 0.3), 0.5, 1)
	crystal(Vector3.new(c[1], crng:NextNumber(6, 16), c[2]), dir.Unit, crng:NextNumber(10, 18), crng:NextNumber(3, 6))
end
light(box(OUT, "CrystalGlow", -0.2, TOP + 12, -10.2, 0.2, TOP + 12.4, -9.8, st(M.Neon, nil, VIO), { deco = true, t = 1 }), 80, 2.2, VIO)
-- the portal's beam straight up into the sky, from the back of the roof (over the ring inside)
do
	local bx, bz = 0, -40
	local beam = part(OUT, "PortalBeam", Vector3.new(14, 900, 14), CFrame.new(bx, TOP + 450, bz), st(M.Neon, nil, VIO), { deco = true, t = 0.55, noShadow = true })
	beam.Shape = Enum.PartType.Cylinder
	beam.Size = Vector3.new(900, 14, 14)
	beam.CFrame = CFrame.new(bx, TOP + 450, bz) * CFrame.Angles(0, 0, math.pi / 2)
	local core = part(OUT, "PortalBeamCore", Vector3.new(900, 6, 6), CFrame.new(bx, TOP + 450, bz) * CFrame.Angles(0, 0, math.pi / 2), st(M.Neon, nil, C3(240, 220, 255)), { deco = true, t = 0.3, noShadow = true })
	core.Shape = Enum.PartType.Cylinder
	cyl(OUT, CFrame.new(bx, TOP + 1, bz), "BeamRing", 26, 2, 0, 0, 0, st(M.Neon, nil, VIO), D())
	light(box(OUT, "BeamGlow", bx - 0.2, TOP + 6, bz - 0.2, bx + 0.2, TOP + 6.4, bz + 0.2, st(M.Neon, nil, VIO), { deco = true, t = 1 }), 90, 2.6, VIO)
end
for _, x in { -60, -36, 36, 60 } do box(OUT, "WindowGlow", x - 2.5, 10, 59.3, x + 2.5, 16, 59.5, st(M.Neon, nil, VIO), { deco = true, t = 0.5 }) end
moonSign("THE BLACK GATE", CFrame.new(0, 29.6, 61))
washLight(-30, 88, Vector3.new(-20, TOP, 60), C3(200, 170, 255), 100, 2.2)
washLight(30, 88, Vector3.new(20, TOP, 60), C3(200, 170, 255), 100, 2.2)
moonGrounds()
return endMap()
