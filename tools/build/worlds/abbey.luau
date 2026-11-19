-- THE ASHEN ABBEY's world (ServerStorage.Worlds.Abbey): a hilltop abbey sinking into hell under a blood-red sky.
--   ALL ROUND  the GRAVEYARD: rows of headstones and crosses, mausoleums with iron doors, angel statues on plinths,
--              iron-railed family plots, dead trees, braziers
--   EAST       the RUINS of the old abbey church: roofless walls with pointed window holes, standing columns, a
--              collapsed tower
--   NORTH-WEST the broken BELL TOWER of the old monastery and its dormitory range, leaning as they sink
--   FAR OFF    the hill ends at cliffs; past them the ground has fallen into a glowing ABYSS - red light rising, smoke
--              columns, lava FISSURES splitting the ash closer in
--   YARD       the ASHEN ABBEY arch, an iron spike fence between stone pillars
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--   tools/build/worlds/world_lib.luau tools/build/worlds/abbey.luau
local C3 = Color3.fromRGB
local rng = Random.new(1347)
local W = beginWorld("Abbey")
local STONE = st(M.Cobblestone, "PS2_Stone1", C3(96, 90, 84))
local STONED = st(M.Cobblestone, "PS2_Stone1", C3(64, 60, 58))
local STONEL = st(M.Cobblestone, "PS2_Stone1", C3(130, 124, 116))
local MARBLE = st(M.Marble, nil, C3(150, 144, 136))
local ASH = st(M.Slate, nil, C3(48, 42, 40))
local EARTH = st(M.Ground, nil, C3(50, 36, 30))
local IRON = st(M.Metal, nil, C3(36, 34, 36))
local ROOF = st(M.Slate, nil, C3(40, 38, 40))
local LAVA = st(M.Neon, nil, C3(255, 90, 30))
local EMBER = C3(255, 120, 50)

---------------------------------------------------------------- the ground, the fissures, the cliffs and the abyss
local gnd = model(W, "Ground")
box(gnd, "Plateau", -420, -6, -420, 420, 0.02, 420, ASH, WD())
box(gnd, "Yard", -95, 0.02, 52, 95, 0.05, 168, EARTH, WD())
for k = 1, 40 do
	local x, z = rng:NextNumber(-400, 400), rng:NextNumber(-400, 400)
	if not inPlay(x, z, 0) then
		local p = box(gnd, "Earth", x - rng:NextNumber(6, 18), 0.03, z - rng:NextNumber(6, 18), x + rng:NextNumber(6, 18), 0.07, z + rng:NextNumber(6, 18), EARTH, WD())
		p.CFrame = p.CFrame * CFrame.Angles(0, rng:NextNumber(0, 3), 0)
	end
end
-- lava fissures: a jagged chain of glowing slits in the ash, a red light here and there, smoke from the widest
local function fissure(a: Vector3, z: Vector3, w: number, smoke: boolean)
	local n = math.max(3, math.floor((z - a).Magnitude / 10))
	local prev = a
	for i = 1, n do
		local p = a:Lerp(z, i / n) + Vector3.new(rng:NextNumber(-5, 5), 0, rng:NextNumber(-5, 5))
		local mid = (prev + p) / 2
		part(gnd, "Fissure", Vector3.new(w * rng:NextNumber(0.6, 1.3), 0.2, (p - prev).Magnitude + 1), CFrame.lookAt(Vector3.new(mid.X, 0.05, mid.Z), Vector3.new(p.X, 0.05, p.Z)), LAVA, WD())
		part(gnd, "FissureLip", Vector3.new(w * 2.4, 0.5, (p - prev).Magnitude + 1), CFrame.lookAt(Vector3.new(mid.X, 0.1, mid.Z), Vector3.new(p.X, 0.1, p.Z)), STONED, { deco = true, t = 0.2 })
		if i % 3 == 0 then light(box(gnd, "FissureGlow", mid.X - 0.1, 1.5, mid.Z - 0.1, mid.X + 0.1, 1.7, mid.Z + 0.1, LAVA, { deco = true, t = 1 }), 30, 1.6, EMBER) end
		prev = p
	end
	if smoke then
		local s = box(gnd, "SmokeSource", a.X - 1, 0, a.Z - 1, a.X + 1, 1, a.Z + 1, ASH, { deco = true, t = 1 })
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
		pe.Color = ColorSequence.new(C3(60, 40, 36), C3(30, 26, 26))
		pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1) })
		pe.Size = NumberSequence.new(10, 40); pe.Lifetime = NumberRange.new(10, 14); pe.Rate = 3
		pe.Speed = NumberRange.new(6, 9); pe.SpreadAngle = Vector2.new(15, 15); pe.Acceleration = Vector3.new(1, 0.5, 0)
		pe.Parent = s
	end
end
fissure(Vector3.new(-120, 0, 200), Vector3.new(-260, 0, 340), 3, true)
fissure(Vector3.new(140, 0, -60), Vector3.new(300, 0, -200), 4, true)
fissure(Vector3.new(-160, 0, -120), Vector3.new(-320, 0, -40), 2.5, false)
fissure(Vector3.new(180, 0, 240), Vector3.new(330, 0, 320), 3, true)
fissure(Vector3.new(-30, 0, -170), Vector3.new(60, 0, -300), 2.2, false)
-- the cliff all round the plateau, the abyss below it glowing
local cliff = model(W, "Cliffs")
for k = 0, 35 do
	local a = k / 36 * math.pi * 2
	local r = 420 + rng:NextNumber(-20, 20)
	local p = Vector3.new(r * math.cos(a), 0, r * math.sin(a))
	local cf = CFrame.lookAt(p, Vector3.zero)
	local w = 2 * r * math.sin(math.pi / 36) + 12
	b(cliff, cf, "CliffFace", w, 160, 30, 0, -80, 0, STONED, WD())
	for j = 1, 2 do
		local rk = b(cliff, cf, "CliffRock", rng:NextNumber(12, 26), rng:NextNumber(10, 20), rng:NextNumber(10, 20), rng:NextNumber(-w / 2, w / 2), rng:NextNumber(-60, -5), rng:NextNumber(-20, 0), ASH, WD())
		rk.CFrame = rk.CFrame * CFrame.Angles(rng:NextNumber(-0.5, 0.5), rng:NextNumber(0, 3), rng:NextNumber(-0.5, 0.5))
		local _ = j
	end
end
local abyss = box(cliff, "Abyss", -1600, -220, -1600, 1600, -218, 1600, st(M.Neon, nil, C3(150, 30, 10)), WD())
abyss.CastShadow = false
for k = 0, 7 do -- the red light rising from below, round the edge
	local a = k / 8 * math.pi * 2
	local g = box(cliff, "AbyssGlow", 470 * math.cos(a) - 0.1, -20, 470 * math.sin(a) - 0.1, 470 * math.cos(a) + 0.1, -19.8, 470 * math.sin(a) + 0.1, LAVA, { deco = true, t = 1 })
	light(g, 120, 3, EMBER)
end

---------------------------------------------------------------- THE GRAVEYARD
local gy = model(W, "Graveyard")
local function headstone(cf: CFrame, kind: number)
	local s = rng:NextNumber() < 0.5 and STONE or STONED
	if kind == 1 then
		b(gy, cf, "Headstone", 3, 4.4, 0.8, 0, 2.2, 0, s, WD())
		cyl(gy, cf * CFrame.new(0, 4.4, 0) * CFrame.Angles(math.pi / 2, 0, 0), "HeadstoneTop", 3, 0.8, 0, 0, 0, s, WD())
	elseif kind == 2 then
		b(gy, cf, "Cross", 0.8, 6, 0.8, 0, 3, 0, s, WD())
		b(gy, cf, "CrossArm", 3.6, 0.8, 0.8, 0, 4.4, 0, s, WD())
	else
		b(gy, cf, "Obelisk", 1.6, 8, 1.6, 0, 4, 0, s, WD())
		b(gy, cf, "ObeliskBase", 2.6, 1, 2.6, 0, 0.5, 0, s, WD())
	end
	b(gy, cf, "Mound", 3, 0.5, 6, 0, 0.1, 3.4, EARTH, WD())
end
local function graveRows(x0: number, z0: number, cols: number, rows: number, yaw: number)
	for i = 0, cols - 1 do
		for j = 0, rows - 1 do
			if rng:NextNumber() < 0.85 then
				local x, z = x0 + i * 7 + rng:NextNumber(-1, 1), z0 + j * 10 + rng:NextNumber(-1, 1)
				if not inPlay(x, z, 2) then
					local kind = rng:NextNumber() < 0.6 and 1 or (rng:NextNumber() < 0.7 and 2 or 3)
					headstone(CFrame.new(x, 0, z) * CFrame.Angles(rng:NextNumber(-0.1, 0.1), yaw + rng:NextNumber(-0.25, 0.25), rng:NextNumber(-0.15, 0.15)), kind)
				end
			end
		end
	end
end
graveRows(-230, 60, 16, 6, 0)
graveRows(110, 60, 16, 6, 0)
graveRows(-230, -100, 12, 5, 0)
graveRows(130, -110, 12, 5, 0)
graveRows(-140, 200, 10, 4, math.pi)
graveRows(40, 200, 10, 4, math.pi)
-- mausoleums: a stone house with a pediment, columns, an iron door, an urn on top
local function mausoleum(cf: CFrame, w: number, d: number, h: number)
	local m = model(gy, "Mausoleum")
	b(m, cf, "Body", w, h, d, 0, h / 2, 0, STONEL, WD())
	b(m, cf, "Plinth", w + 2, 1.4, d + 2, 0, 0.7, 0, STONED, WD())
	gableOn(m, cf, w + 1, d + 1, h, w * 0.3, ROOF, STONEL, 0.6)
	for _, x in { -w / 2 + 1.2, w / 2 - 1.2 } do cyl(m, cf * CFrame.new(x, h / 2, -d / 2 - 1.4), "Column", 1.6, h - 1, 0, 0, 0, MARBLE, WD()) end
	b(m, cf, "Door", w * 0.4, h * 0.6, 0.4, 0, h * 0.3 + 0.7, -d / 2 - 0.2, IRON, WD())
	b(m, cf, "Urn", 1.6, 2.4, 1.6, 0, h + w * 0.3 + 1, 0, MARBLE, WD())
	return m
end
for _, p in { { -180, 140, 0.2 }, { 170, 130, -0.3 }, { -260, 20, 1.4 }, { 240, -30, -1.3 }, { -120, -170, 0.1 }, { 200, -160, 0.4 } } do
	mausoleum(CFrame.new(p[1], 0, p[2]) * CFrame.Angles(0, math.pi + p[3], 0), rng:NextNumber(12, 18), rng:NextNumber(14, 20), rng:NextNumber(10, 14))
end
-- angel statues on plinths, wings spread, heads bowed
local function angel(cf: CFrame)
	local m = model(gy, "Angel")
	b(m, cf, "Plinth", 4, 4, 4, 0, 2, 0, STONED, WD())
	b(m, cf, "Robe", 2.4, 6, 1.8, 0, 7, 0, MARBLE, WD())
	b(m, cf, "Head", 1.4, 1.4, 1.4, 0, 10.6, -0.2, MARBLE, WD())
	for _, sx in { -1, 1 } do
		part(m, "Wing", Vector3.new(4, 6, 0.4), cf * CFrame.new(sx * 2.4, 8.6, 0.8) * CFrame.Angles(0, sx * 0.4, sx * -0.3), MARBLE, WD())
	end
	b(m, cf, "Hands", 1.2, 1.6, 1, 0, 9, -1, MARBLE, WD())
end
for _, p in { { -110, 110 }, { 110, 105 }, { -150, -60 }, { 160, 40 }, { -60, 220 }, { 70, 230 } } do angel(CFrame.new(p[1], 0, p[2]) * CFrame.Angles(0, rng:NextNumber(0, 6), 0)) end
-- iron-railed family plots
for _, p in { { -150, 90, 16, 12 }, { 150, 80, 18, 14 }, { -200, -40, 14, 12 } } do
	fenceRun(gy, p[1], p[2], p[1] + p[3], p[2], IRON, IRON, 3, 2, nil)
	fenceRun(gy, p[1], p[2] + p[4], p[1] + p[3], p[2] + p[4], IRON, IRON, 3, 2, nil)
	fenceRun(gy, p[1], p[2], p[1], p[2] + p[4], IRON, IRON, 3, 2, nil)
	fenceRun(gy, p[1] + p[3], p[2], p[1] + p[3], p[2] + p[4], IRON, IRON, 3, 2, nil)
end
-- braziers along the edges of the graveyard
for _, p in { { -110, 60 }, { 110, 60 }, { -110, 160 }, { 110, 160 }, { -100, -90 }, { 100, -90 } } do
	local m = model(gy, "Brazier")
	box(m, "Stand", p[1] - 0.6, 0, p[2] - 0.6, p[1] + 0.6, 5, p[2] + 0.6, IRON, WD())
	cyl(m, CFrame.new(p[1], 5.6, p[2]), "Bowl", 3.4, 1.2, 0, 0, 0, IRON, WD())
	local e = box(m, "Coals", p[1] - 1.2, 6, p[2] - 1.2, p[1] + 1.2, 6.4, p[2] + 1.2, LAVA, WD())
	local f = Instance.new("Fire"); f.Size = 4; f.Heat = 8; f.Color = C3(255, 130, 50); f.SecondaryColor = C3(200, 40, 20); f.Parent = e
	light(e, 30, 1.6, EMBER)
end

---------------------------------------------------------------- THE RUINS of the old abbey church (east)
do
	local ru = model(W, "Ruins")
	local function ruinWall(a: Vector3, z: Vector3, h: number, wins: number)
		local d = z - a
		local len = d.Magnitude
		local cf = CFrame.lookAt(a, z)
		local seg = len / (wins * 2 + 1)
		for k = 0, wins * 2 do
			local isWin = k % 2 == 1
			local hh = isWin and h * 0.3 or h * rng:NextNumber(0.55, 1)
			local p = b(ru, cf, "RuinWall", 3, hh, seg + 0.2, 0, hh / 2, -(k + 0.5) * seg, STONE, WD())
			if isWin then
				-- the pointed top of a window: two leaning stones over the gap
				for _, s in { -1, 1 } do part(ru, "ArchStone", Vector3.new(3, seg * 0.7, 2), cf * CFrame.new(0, h * 0.62, -(k + 0.5) * seg + s * seg * 0.28) * CFrame.Angles(s * 0.6, 0, 0), STONE, WD()) end
			end
			local _ = p
		end
	end
	ruinWall(Vector3.new(170, 0, -40), Vector3.new(320, 0, -40), 34, 5)
	ruinWall(Vector3.new(170, 0, -110), Vector3.new(320, 0, -110), 30, 5)
	ruinWall(Vector3.new(320, 0, -40), Vector3.new(320, 0, -110), 40, 2)
	for x = 190, 300, 22 do cyl(ru, CFrame.new(x, rng:NextNumber(8, 14), -75), "Column", 3.4, rng:NextNumber(16, 28), 0, 0, 0, STONEL, WD()) end
	-- the collapsed tower: a stump and its fallen blocks
	box(ru, "TowerStump", 150, 0, -60, 170, 30, -40, STONED, WD())
	for k = 1, 8 do
		local s = rng:NextNumber(4, 8)
		local p = box(ru, "FallenBlock", 0, 0, 0, 1, 1, 1, STONED, WD())
		p.Size = Vector3.new(s, s, s)
		p.CFrame = CFrame.new(140 - k * 6, s / 2 - 0.5, -50 + rng:NextNumber(-8, 8)) * CFrame.Angles(rng:NextNumber(0, 1), rng:NextNumber(0, 3), rng:NextNumber(0, 1))
	end
end

---------------------------------------------------------------- the broken BELL TOWER and dormitory (north-west), sinking
do
	local nw = model(W, "OldMonastery")
	local cf = CFrame.new(-210, -6, -220) * CFrame.Angles(0.05, 0.4, 0.09) -- (leaning: the ground is giving way)
	b(nw, cf, "BellTower", 26, 96, 26, 0, 48, 0, STONED, WD())
	for _, f in { { 0, -13.2 }, { 0, 13.2 }, { -13.2, 0 }, { 13.2, 0 } } do
		local open = b(nw, cf, "Belfry", math.abs(f[1]) > 0 and 0.4 or 10, 14, math.abs(f[2]) > 0 and 0.4 or 10, f[1], 82, f[2], st(M.SmoothPlastic, nil, C3(14, 8, 8)), WD())
		local _ = open
	end
	b(nw, cf, "Bell", 7, 7, 7, 0, 80, 0, st(M.Metal, nil, C3(150, 110, 50)), WD())
	spire(nw, (cf * CFrame.new(0, 96, 0)).Position.X, (cf * CFrame.new(0, 96, 0)).Position.Z, 15, (cf * CFrame.new(0, 96, 0)).Position.Y, 34, 4, ROOF, WD())
	local dcf = CFrame.new(-150, -4, -260) * CFrame.Angles(0.03, -0.2, -0.05)
	b(nw, dcf, "Dormitory", 110, 26, 26, 0, 13, 0, STONE, WD())
	gableOn(nw, dcf * CFrame.Angles(0, math.pi / 2, 0), 26, 110, 26, 12, ROOF, STONE, 1)
	for k = 0, 7 do b(nw, dcf, "DormWindow", 3, 7, 0.3, -48 + k * 13.6, 14, 13.2, (k % 3 == 0) and st(M.Neon, nil, C3(255, 120, 50)) or st(M.SmoothPlastic, nil, C3(14, 8, 8)), WD()) end
	light(b(nw, dcf, "DormGlow", 0.2, 0.2, 0.2, 0, 14, 18, LAVA, { deco = true, t = 1 }), 50, 1.4, EMBER)
end

---------------------------------------------------------------- the yard: the arch and the iron spike fence
local yd = model(W, "AbbeyYard")
for _, x in { -8, 8 } do box(yd, "ArchPier", x - 1.4, 0, 129.5, x + 1.4, 16, 133.5, STONE, WD()) end
box(yd, "ArchLintel", -9.5, 13, 130, 9.5, 16, 133, STONED, WD())
part(yd, "ArchPeak", Vector3.new(14, 14, 3), CFrame.new(0, 16, 131.5) * CFrame.Angles(0, 0, math.pi / 4), STONE, WD())
sign(yd, "THE ASHEN ABBEY", CFrame.new(0, 14.5, 129.9) * CFrame.Angles(0, math.pi, 0), 17, 2, STONED, C3(255, 190, 140), Enum.Font.Creepster).Name = "AbbSign"
sign(yd, "THE ASHEN ABBEY", CFrame.new(0, 14.5, 133.1), 17, 2, STONED, C3(255, 190, 140), Enum.Font.Creepster).Name = "AbbSignBack"
local fence = model(W, "Fence")
yardEdge(fence, function(parent, x1, z1, x2, z2, gap)
	local a, z = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	local len = (z - a).Magnitude
	local dir = (z - a).Unit
	local n = math.floor(len / 1.6)
	for i = 0, n do
		local p = a + dir * (i * 1.6)
		if gap and gap(p.X, p.Z) then continue end
		if i % 10 == 0 then
			box(parent, "Pillar", p.X - 1.2, 0, p.Z - 1.2, p.X + 1.2, 7, p.Z + 1.2, STONE, WD())
			box(parent, "PillarCap", p.X - 1.5, 7, p.Z - 1.5, p.X + 1.5, 7.8, p.Z + 1.5, STONED, WD())
		else
			box(parent, "Bar", p.X - 0.12, 0, p.Z - 0.12, p.X + 0.12, 5.6, p.Z + 0.12, IRON, WD())
			part(parent, "Spike", Vector3.new(0.4, 0.8, 0.4), CFrame.new(p.X, 5.9, p.Z) * CFrame.Angles(0, math.pi / 4, 0), IRON, WD())
		end
	end
	for _, y in { 1, 4.6 } do
		part(parent, "Rail", Vector3.new(0.3, 0.3, len), CFrame.lookAt((a + z) / 2 + Vector3.new(0, y, 0), z + Vector3.new(0, y, 0)), IRON, WD())
	end
end)
-- dead trees
local trees = model(W, "DeadTrees")
forest(trees, rng, 70, -400, -400, 400, 400, { { "DeadTreeA", 1.1, 1.9 } }, function(x, z) return math.abs(x) < 120 and z > 40 and z < 230 end)
return endWorld()
