-- CAMP HOLLOWMERE: what its five buildings share (Shared/Campaign: one building per train trip). Prepend after
-- lib2 + furn_lib + maplib, then one maps/camp_<building>.luau:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/camp_lib.luau tools/build/maps/camp_bunkhouse.luau
-- Every building is a map on the Mansion's footprint (Server/Run treats it like any house); the yard in front of it
-- is the camp: a dirt path from the porch to the railway (the train stops at z = 150 and lets the party off at
-- z = 141), a log arch with the camp's name over the path, a campfire ring with log benches, a flagpole with a torn
-- flag, a signpost to the five buildings, a picnic table, two lamp posts. Then each map's own furnish / detail pass
-- (THEMES Camp_*), phones (the Caller) and doors_clear, like every other map.
local C3c = Color3.fromRGB
local function Dc() return { deco = true } end -- (a fresh table each time: cyl / ball write the shape into it)
local CAMP = {
	log = st(M.WoodPlanks, "PS2_Siding1", C3c(92, 66, 46)),
	logD = st(M.Wood, "PS2_DarkBeam1", C3c(62, 44, 32)),
	plank = st(M.WoodPlanks, "PS2_FloorPlanks2", C3c(110, 84, 60)),
	inner = st(M.WoodPlanks, "PS2_Siding1", C3c(138, 108, 78)),
	shingle = st(M.Slate, nil, C3c(56, 50, 46)),
	stone = st(M.Cobblestone, "PS2_Stone1", C3c(104, 100, 94)),
	dirt = st(M.Ground, nil, C3c(72, 58, 42)),
	ember = st(M.Neon, nil, C3c(255, 120, 40)),
	iron = st(M.Metal, nil, C3c(44, 42, 40)),
	paint = st(M.SmoothPlastic, nil, C3c(214, 204, 176)),
}
local function campTheme(over: { [string]: any }?)
	local t = {
		floor = CAMP.plank, floor2 = CAMP.plank, inner = CAMP.inner, wainscot = CAMP.logD, wain = true,
		ext = CAMP.log, trim = CAMP.logD, ceiling = CAMP.logD, roof = CAMP.shingle, found = CAMP.stone,
		door = st(M.WoodPlanks, "PS2_Siding1", C3c(70, 48, 34)), porch = CAMP.plank,
		lanternColor = C3c(255, 180, 110), floodColor = C3c(200, 190, 170),
	}
	for k, v in over or {} do t[k] = v end
	return t
end

-- the building's name on a plank (cf = its centre, facing +Z = the yard; default: over the old porch roof)
local function campNameBoard(text: string, cf: CFrame?, w: number?, h: number?)
	local m = model(DEC, "NameBoard")
	cf = cf or CFrame.new(0, 19.6, 60.9)
	w = w or 22
	h = h or 3.4
	sign(m, text, (cf :: CFrame) * CFrame.Angles(0, math.pi, 0), w :: number, h :: number, CAMP.logD, C3c(226, 214, 186), Enum.Font.SpecialElite)
	for _, x in { -(w :: number) / 2 + 0.6, (w :: number) / 2 - 0.6 } do
		b(m, cf :: CFrame, "Peg", 0.5, (h :: number) + 1.6, 0.6, x, 0, -0.3, CAMP.logD, DECO)
	end
	return m
end

-- (2026-11-19) the camp's shared yard (the arch, the campfire, the flagpole, the picnic table, the fence) is in the
-- Camp WORLD now (tools/build/worlds/camp.luau). A building keeps: the path from its door to the world's path (z 112),
-- two lamp posts and the signpost with its own name in red. o.noPath = true: the building draws its own way in.
local function campYard(name: string, o: { [string]: any }?)
	o = o or {}
	local yd = model(DEC, "CampYard")
	if not o.noPath then
		box(yd, "Path", -5, 0.08, 64, 5, 0.16, 113, CAMP.dirt, DECO)
		for z = 70, 106, 9 do box(yd, "PathStone", -1.4 + (z % 3), 0.12, z, 0.6 + (z % 3), 0.22, z + 1.6, CAMP.stone, DECO) end
	end
	-- the signpost: an arrow board for each building, this one in red
	local sp = model(yd, "Signpost")
	cyl(sp, CFrame.new(12, 5, 124), "Post", 0.8, 10, 0, 0, 0, CAMP.logD, Dc())
	local names = { "BUNKHOUSE", "BOATHOUSE", "MESS HALL", "BARN", "MAIN LODGE" }
	for i, n in names do
		local rot = (i % 2 == 0) and 0.5 or -0.4
		local bcf = CFrame.new(12, 9.4 - i * 1.25, 124) * CFrame.Angles(0, math.pi + rot, 0) * CFrame.new(1.8, 0, 0)
		local board = sign(sp, n, bcf, 4.6, 0.9, n == name and st(M.SmoothPlastic, nil, C3c(150, 40, 30)) or CAMP.log, C3c(232, 220, 190), Enum.Font.SpecialElite)
		board.Name = "Arrow"
	end
	if not o.noLamps then
		for _, z in { 84, 104 } do
			local lp = model(yd, "LampPost")
			cyl(lp, CFrame.new(-7, 5, z), "Pole", 0.5, 10, 0, 0, 0, CAMP.iron, Dc())
			local g = box(lp, "Lamp", -7.6, 9.6, z - 0.6, -6.4, 10.8, z + 0.6, st(M.Neon, nil, C3c(255, 200, 140)), DECO)
			light(g, 24, 1.1, C3c(255, 190, 130))
		end
	end
	return yd
end

---------------------------------------------------------------- log-built outsides (2026-11-19)
-- horizontal logs laid along a wall face: along "x" at z = fixed (the front / back), or "z" at x = fixed; from a1 to
-- a2, every `step` up from y0 to y1, `out` = which side of the face (+1 / -1). holes = { { c, w, y1, y2 } }: the
-- openings (window / door centre along the wall, width, bottom, top) the logs stop at.
local function logBands(along: string, fixed: number, a1: number, a2: number, y0: number, y1: number, step: number, out: number, sty, holes)
	local m = model(DEC, "LogBands")
	local function run(s1: number, s2: number, y: number)
		if s2 - s1 < 0.6 then return end
		local cf
		-- (cyl stands a cylinder along cf's up vector: tip it over along x or along z)
		if along == "x" then cf = CFrame.new((s1 + s2) / 2, y, fixed + out * 0.55) * CFrame.Angles(0, 0, -math.pi / 2)
		else cf = CFrame.new(fixed + out * 0.55, y, (s1 + s2) / 2) * CFrame.Angles(math.pi / 2, 0, 0) end
		cyl(m, cf, "Log", 1.1, s2 - s1, 0, 0, 0, sty or CAMP.logD, Dc())
	end
	local y = y0
	while y <= y1 do
		local cuts = {}
		for _, h in holes or {} do
			if y > h[3] - 1.4 and y < h[4] + 1.4 then table.insert(cuts, { h[1] - h[2] / 2 - 1.2, h[1] + h[2] / 2 + 1.2 }) end
		end
		table.sort(cuts, function(p, q) return p[1] < q[1] end)
		local cur = math.min(a1, a2)
		for _, c in cuts do run(cur, c[1], y); cur = math.max(cur, c[2]) end
		run(cur, math.max(a1, a2), y)
		y += step
	end
	return m
end
-- the openings of a wall for logBands: window centres (w wide, from y b to t above y0), plus a door at the centre
local function holesOf(list, w: number, bb: number, tt: number, y0: number, door)
	local h = {}
	for _, c in list do table.insert(h, { c, w, y0 + bb, y0 + tt }) end
	if door then table.insert(h, { 0, door[1], y0, y0 + door[2] }) end
	return h
end

-- crossed log ends sticking out at a corner (x, z), from y0 to y1
local function cornerLogs(x: number, z: number, y0: number, y1: number, sx: number, sz: number)
	local m = model(DEC, "CornerLogs")
	local k = 0
	for y = y0, y1, 1.6 do
		if k % 2 == 0 then
			cyl(m, CFrame.new(x + sx * 1.2, y, z) * CFrame.Angles(0, 0, -math.pi / 2), "LogEnd", 1.5, 6, 0, 0, 0, CAMP.log, Dc())
		else
			cyl(m, CFrame.new(x, y, z + sz * 1.2) * CFrame.Angles(math.pi / 2, 0, 0), "LogEnd", 1.5, 6, 0, 0, 0, CAMP.log, Dc())
		end
		k += 1
	end
	return m
end
-- a wall lantern (an iron cage round a warm glow) on a face, facing +Z by default
local function campLantern(parent, x: number, y: number, z: number, color: Color3?, range: number?)
	local lm = model(parent, "Lantern")
	box(lm, "Bracket", x - 0.15, y + 1.2, z - 0.8, x + 0.15, y + 1.5, z + 0.2, CAMP.iron, DECO)
	box(lm, "Cage", x - 0.6, y - 0.8, z + 0.1, x + 0.6, y + 0.8, z + 1.3, CAMP.iron, { t = 0.3, deco = true })
	local g = box(lm, "Glow", x - 0.35, y - 0.6, z + 0.35, x + 0.35, y + 0.6, z + 1.05, st(M.Neon, nil, color or C3c(255, 190, 120)), DECO)
	light(g, range or 22, 1.3, color or C3c(255, 180, 110))
	return lm
end
-- three claw gouges on a face (at x, y on the plane z = fixed, facing +Z), each a dark slash
local function clawMarks(parent, x: number, y: number, z: number, len: number, tilt: number)
	for k = -1, 1 do
		part(parent, "Claw", Vector3.new(0.5, len, 0.2), CFrame.new(x + k * 1.3, y, z) * CFrame.Angles(0, 0, tilt), st(M.SmoothPlastic, nil, C3c(24, 16, 12)), { deco = true })
	end
end
