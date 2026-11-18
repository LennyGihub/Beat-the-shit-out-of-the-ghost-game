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

-- the building's name, painted on a plank over the porch roof
local function campNameBoard(text: string)
	local m = model(DEC, "NameBoard")
	sign(m, text, CFrame.new(0, 19.6, 60.9) * CFrame.Angles(0, math.pi, 0), 22, 3.4, CAMP.logD, C3c(226, 214, 186), Enum.Font.SpecialElite)
	for _, x in { -10.4, 10.4 } do box(m, "Peg", x - 0.25, 17.4, 60.6, x + 0.25, 21.6, 61.2, CAMP.logD, DECO) end
end

-- the camp in the yard (everything decoration: no collision, never hit by a ray)
local function campYard(name: string)
	local yd = model(DEC, "CampYard")
	-- the path, porch to railway
	box(yd, "Path", -5, 0.02, 76, 5, 0.14, 146, CAMP.dirt, DECO)
	for z = 80, 140, 9 do box(yd, "PathStone", -1.4 + (z % 3), 0.1, z, 0.6 + (z % 3), 0.2, z + 1.6, CAMP.stone, DECO) end
	-- the arch over the path: two log posts, a crossbeam, the camp's name
	for _, x in { -7.5, 7.5 } do
		cyl(yd, CFrame.new(x, 7, 132), "ArchPost", 1.6, 14, 0, 0, 0, CAMP.logD, Dc())
	end
	box(yd, "ArchBeam", -9.5, 13.4, 131.3, 9.5, 14.6, 132.7, CAMP.logD, DECO)
	local s = sign(yd, "CAMP HOLLOWMERE", CFrame.new(0, 12, 131.2) * CFrame.Angles(0, math.pi, 0), 14, 2.4, CAMP.log, C3c(232, 214, 170), Enum.Font.SpecialElite)
	s.Name = "CampSign"
	sign(yd, "CAMP HOLLOWMERE", CFrame.new(0, 12, 132.8), 14, 2.4, CAMP.log, C3c(232, 214, 170), Enum.Font.SpecialElite).Name = "CampSignBack"
	-- the campfire ring with log benches round it (west of the path)
	local fire = model(yd, "Campfire")
	local fc = CFrame.new(-36, 0, 106)
	for k = 0, 9 do
		local a = k / 10 * math.pi * 2
		b(fire, fc * CFrame.Angles(0, a, 0), "RingStone", 1.6, 0.9, 1.2, 0, 0.45, -3.2, CAMP.stone, DECO)
	end
	for k = 0, 3 do b(fire, fc * CFrame.Angles(0, k * 0.8, 0.2), "FireLog", 0.7, 0.7, 3.4, 0, 0.5, 0, CAMP.logD, DECO) end
	local ember = b(fire, fc, "Embers", 2.2, 0.4, 2.2, 0, 0.5, 0, CAMP.ember, DECO)
	light(ember, 26, 1.4, C3c(255, 140, 60))
	for k = 0, 2 do
		local a = k / 3 * math.pi * 2 + 0.4
		local bc = fc * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -8)
		cyl(fire, bc * CFrame.Angles(0, 0, -math.pi / 2), "LogBench", 1.6, 6, -0.8, 0, 0, CAMP.log, Dc()) -- (lying along the ring)
	end
	-- the flagpole and its torn flag (east of the path)
	local fl = model(yd, "Flagpole")
	cyl(fl, CFrame.new(34, 13, 98), "Pole", 0.6, 26, 0, 0, 0, st(M.Metal, nil, C3c(150, 150, 146)), Dc())
	box(fl, "Flag", 34.3, 21.5, 97.9, 40.5, 25.2, 98.1, st(M.Fabric, nil, C3c(60, 90, 56)), DECO)
	box(fl, "FlagTear", 38.5, 21.5, 97.85, 40.6, 22.8, 98.15, st(M.Fabric, nil, C3c(20, 18, 16)), DECO)
	box(fl, "FlagStripe", 34.3, 23.1, 97.85, 40.5, 23.6, 98.15, st(M.Fabric, nil, C3c(220, 210, 180)), DECO)
	box(fl, "Base", 32.8, 0, 96.8, 35.2, 0.8, 99.2, CAMP.stone, DECO)
	-- the signpost: an arrow board for each building, this one first
	local sp = model(yd, "Signpost")
	cyl(sp, CFrame.new(12, 5, 124), "Post", 0.8, 10, 0, 0, 0, CAMP.logD, Dc())
	local names = { "BUNKHOUSE", "BOATHOUSE", "MESS HALL", "BARN", "MAIN LODGE" }
	for i, n in names do
		local rot = (i % 2 == 0) and 0.5 or -0.4
		local bcf = CFrame.new(12, 9.4 - i * 1.25, 124) * CFrame.Angles(0, math.pi + rot, 0) * CFrame.new(1.8, 0, 0)
		local board = sign(sp, n, bcf, 4.6, 0.9, n == name and st(M.SmoothPlastic, nil, C3c(150, 40, 30)) or CAMP.log, C3c(232, 220, 190), Enum.Font.SpecialElite)
		board.Name = "Arrow"
	end
	-- a picnic table
	local pt = model(yd, "PicnicTable")
	box(pt, "Top", 26, 3, 116, 32, 3.4, 120, CAMP.plank, DECO)
	for _, z in { 115, 121 } do box(pt, "Seat", 26, 1.7, z - 0.6, 32, 2, z + 0.6, CAMP.plank, DECO) end
	for _, x in { 26.5, 31.5 } do box(pt, "Leg", x - 0.25, 0, 116.5, x + 0.25, 3, 119.5, CAMP.logD, DECO) end
	-- two lamp posts along the path (dim, warm)
	for _, z in { 96, 118 } do
		local lp = model(yd, "LampPost")
		cyl(lp, CFrame.new(-7, 5, z), "Pole", 0.5, 10, 0, 0, 0, CAMP.iron, Dc())
		local g = box(lp, "Lamp", -7.6, 9.6, z - 0.6, -6.4, 10.8, z + 0.6, st(M.Neon, nil, C3c(255, 200, 140)), DECO)
		light(g, 24, 1.1, C3c(255, 190, 130))
	end
end
