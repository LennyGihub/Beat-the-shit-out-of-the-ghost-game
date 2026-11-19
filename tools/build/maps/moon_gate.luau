-- THE BLACK GATE (the Black Moon, building 5, the end of the campaign: THE CONQUEROR, then THE GOLDEN CONQUEROR). The
-- base's last hall, built round what they dug up: a huge RING OF BLACK STONE standing on its edge against the back
-- wall, a violet PORTAL swirling inside it (where he came through), carved runes glowing round the ring, broken
-- MACHINERY that was meant to hold it shut (pylons with dead coils - cover), black crystal shards bursting out of the
-- floor (cover), cracks of violet light across the floor (flush), scattered research gear. At the back, behind the
-- gate wall with two doorways: the OBSERVATION ROOM (a long window on the ring, desks, the last log). Its east end: a
-- BLAST DOOR that slides (Secrets).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/moon_lib.luau tools/build/maps/moon_gate.luau
local C3 = Color3.fromRGB
local function D() return { deco = true } end
local H = 34
local rng = Random.new(55)
local OBSIDIAN = st(M.Basalt, nil, C3(26, 22, 32))
local RUNE = st(M.Neon, nil, C3(190, 120, 255))
local VOIDC = st(M.Neon, nil, C3(110, 50, 200))
beginMap("Moon_Gate", moonTheme({ floor = st(M.Slate, nil, C3(56, 54, 64)), inner = st(M.Slate, nil, C3(80, 78, 92)) }))
shell({ two = false, H = H, roof = "flat", front1 = { -60, -36, 36, 60 }, back1 = { -60, 60 }, left1 = { 44, -30 }, right1 = { 44, -30 },
	winW = 5, winB = 8, winT = 14 })
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
moonSign("THE BLACK GATE")
moonGrounds()
return endMap()
