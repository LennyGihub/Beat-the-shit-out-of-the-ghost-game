-- CAMP HOLLOWMERE: each building shaped round its monster (run in Edit after the buildings and their furnish /
-- detail / phones / doors_clear passes: tools/studio.py luau Edit tools/build/maps/camp_design.luau). It works on
-- ServerStorage.Maps.Camp_*, adds models named MD_* (and removes its own old ones first, so it can run again), and
-- takes out any furniture standing where it builds. Hand-built blocky parts, PS2 materials.
--   BUNKHOUSE (the Antlered One): six log POSTS down the hall (part of the building, unbreakable: dodge behind one and
--     his charge gets his antlers stuck in it), thin PARTITIONS between the bunks (Interior: his charge smashes
--     through them), his NEST of sticks and bones up on the rafters, claw marks on the beams and posts, moss hanging
--     from the beams, antler trophies on the walls.
--   BOATHOUSE (the Lake Witch): six PILLARS beside the slip and two stacks of CRATES on the docks (cover: her hook
--     stops on them), fishing nets on the walls, weed on the pillars, wet footprints out of the water, puddles.
--   MESS HALL (the Burned Counselor): two POSTS in the middle aisle (his fire run stops on them, panting), a trail of
--     burnt bootprints from the kitchen to the front door, the staff photo board with one photo burnt black, melted
--     candles on the tables, the banner's end burnt.
--   BARN (the Scarecrow): tall stacks of HAY BALES (solid: they block the line of sight, so he can creep up behind
--     them), his empty pole with the ropes cut, crows perched all over, black feathers on the floor.
local SS = game:GetService("ServerStorage")
local maps = SS:WaitForChild("Maps")
local C3 = Color3.fromRGB
local M = Enum.Material
local A = CFrame.Angles
local out = {}
local rng = Random.new(1987)

local LOG = C3(62, 44, 32)
local INNER = C3(138, 108, 78)
local STONE = C3(104, 100, 94)
local BONE = C3(214, 204, 176)
local SOOT = C3(20, 16, 14)
local BLACK = C3(22, 21, 26)

local function mk(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, mv: string?, deco: boolean?, t: number?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or M.SmoothPlastic
	if mv then p.MaterialVariant = mv end
	p.Anchored = true; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	if deco then p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false end
	if t then p.Transparency = t end
	p.Parent = parent
	return p
end
local function group(parent: Instance, name: string): Model
	local m = Instance.new("Model"); m.Name = "MD_" .. name; m.Parent = parent
	return m
end
local function clearOld(map: Instance)
	local old = {}
	for _, d in map:GetDescendants() do if d:IsA("Model") and string.sub(d.Name, 1, 3) == "MD_" then table.insert(old, d) end end
	for _, d in old do d:Destroy() end
end
local function floorY(map: Instance): number
	local gf = map:FindFirstChild("Structure") and map.Structure:FindFirstChild("GroundFloor") :: BasePart?
	return gf and (gf.Position.Y + gf.Size.Y / 2) or 2.05
end
-- furniture standing where a solid piece goes is taken out (logged)
local function clearFurniture(map: Instance, cf: CFrame, size: Vector3)
	local fur = map:FindFirstChild("Furniture")
	if not fur then return end
	local lo, hi = cf.Position - size / 2 - Vector3.one * 0.6, cf.Position + size / 2 + Vector3.one * 0.6
	for _, m in fur:GetChildren() do
		local mcf, msz
		if m:IsA("Model") then mcf, msz = m:GetBoundingBox() elseif m:IsA("BasePart") then mcf, msz = m.CFrame, m.Size end
		if mcf then
			local a, b = mcf.Position - msz / 2, mcf.Position + msz / 2
			if a.X < hi.X and b.X > lo.X and a.Y < hi.Y and b.Y > lo.Y and a.Z < hi.Z and b.Z > lo.Z then
				table.insert(out, map.Name .. ": took out " .. m.Name)
				m:Destroy()
			end
		end
	end
end
local function solid(map: Instance, parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, mv: string?): Part
	clearFurniture(map, cf, size)
	return mk(parent, name, size, cf, color, mat, mv)
end
-- a log post from the floor up to `top`, on a stone foot
local function logPost(map: Instance, parent: Instance, x: number, z: number, F1: number, top: number, w: number)
	solid(map, parent, "Post", Vector3.new(w, top - F1, w), CFrame.new(x, (F1 + top) / 2, z), LOG, M.Wood, "PS2_DarkBeam1")
	mk(parent, "PostFoot", Vector3.new(w + 0.9, 1.2, w + 0.9), CFrame.new(x, F1 + 0.6, z), STONE, M.Cobblestone, "PS2_Stone1")
	mk(parent, "PostBand", Vector3.new(w + 0.2, 0.4, w + 0.2), CFrame.new(x, F1 + 7, z), C3(44, 42, 40), M.Metal, nil, true)
end
-- three claw scratches on a face (pos on the face, `n` = the face's outward normal)
local function claws(parent: Instance, pos: Vector3, n: Vector3, len: number)
	local cf = CFrame.lookAt(pos + n * 0.03, pos + n * 2)
	for i = -1, 1 do
		mk(parent, "Claw", Vector3.new(0.14, len, 0.05), cf * CFrame.new(i * 0.32, -math.abs(i) * 0.15, 0) * A(0, 0, 0.35), C3(176, 152, 116), M.SmoothPlastic, nil, true)
	end
end
-- a crow sitting, facing `yaw` (perch = the height of what it sits on)
local function crow(parent: Instance, x: number, perch: number, z: number, yaw: number)
	local cf = CFrame.new(x, perch + 0.62, z) * A(0, yaw, 0) * A(-0.15, 0, 0)
	local m = Instance.new("Model"); m.Name = "Crow"; m.Parent = parent
	mk(m, "Body", Vector3.new(0.6, 0.55, 1.2), cf, BLACK, nil, nil, true)
	mk(m, "Head", Vector3.new(0.45, 0.45, 0.48), cf * CFrame.new(0, 0.38, -0.72) * A(0.25, rng:NextNumber(-0.6, 0.6), 0), BLACK, nil, nil, true)
	mk(m, "Beak", Vector3.new(0.14, 0.14, 0.42), cf * CFrame.new(0, 0.32, -1.12), C3(70, 66, 60), nil, nil, true)
	mk(m, "Tail", Vector3.new(0.5, 0.08, 0.75), cf * CFrame.new(0, 0.02, 0.9) * A(0.35, 0, 0), BLACK, nil, nil, true)
	for _, s in { -1, 1 } do
		mk(m, "Wing", Vector3.new(0.1, 0.48, 1.05), cf * CFrame.new(s * 0.33, 0.05, 0.1), C3(30, 28, 34), nil, nil, true)
		mk(m, "Leg", Vector3.new(0.08, 0.4, 0.08), cf * CFrame.new(s * 0.14, -0.42, -0.05), C3(50, 46, 40), nil, nil, true)
	end
	mk(m, "Eye", Vector3.new(0.47, 0.08, 0.08), cf * CFrame.new(0, 0.46, -0.82), C3(150, 140, 110), M.SmoothPlastic, nil, true)
end
-- a pair of footprints at p, heading `yaw`
local function prints(parent: Instance, p: Vector3, yaw: number, color: Color3, t: number, step: boolean)
	local cf = CFrame.new(p) * A(0, yaw, 0)
	mk(parent, "Print", Vector3.new(0.7, 0.04, 1.3), cf * CFrame.new(step and -0.45 or 0.45, 0, 0), color, nil, nil, true, t)
end

---------------------------------------------------------------------------------------------- THE BUNKHOUSE
do
	local map = maps:FindFirstChild("Camp_Bunkhouse")
	if map then
		clearOld(map)
		local F1 = floorY(map)
		local st, dec = map.Structure, map.Decor
		-- the posts under the tie beams (z = -24 + 13k), knee braces up to the beam
		local posts = group(st, "Posts")
		for _, x in { -24, 24 } do
			for _, z in { -11, 15, 41 } do
				logPost(map, posts, x, z, F1, 23.5, 2.4)
				for _, s in { -1, 1 } do
					mk(posts, "Brace", Vector3.new(0.8, 5.4, 0.8), CFrame.new(x + s * 2.9, 21.3, z) * A(0, 0, -s * 0.7), LOG, M.Wood, "PS2_DarkBeam1", true)
				end
				claws(dec, Vector3.new(x, F1 + 11 + rng:NextNumber(-2, 2), z - 1.2), Vector3.new(0, 0, -1), 2.2)
			end
		end
		-- the partitions between the bunks (breakable: they are in Interior)
		local div = group(st.Interior, "BunkDividers")
		for _, side in { -1, 1 } do
			for _, z in { -13.5, -0.5, 12.5, 25.5, 38.5 } do
				local cf = CFrame.new(side * 70.5, F1 + 4.5, z)
				solid(map, div, "Divider", Vector3.new(15, 9, 0.6), cf, INNER, M.WoodPlanks, "PS2_Siding1")
				mk(div, "DividerCap", Vector3.new(15, 0.4, 1), cf * CFrame.new(0, 4.7, 0), LOG, M.Wood, "PS2_DarkBeam1")
			end
		end
		-- his nest on the purlin at the back of the hall: sticks, bones, a deer's skull
		local nest = group(dec, "Nest")
		for _ = 1, 22 do
			local p = Vector3.new(-30 + rng:NextNumber(-2.6, 2.6), 27.1 + rng:NextNumber(0, 1.1), 48 + rng:NextNumber(-4.5, 4.5))
			mk(nest, "Stick", Vector3.new(0.3, 0.3, rng:NextNumber(3, 6)), CFrame.new(p) * A(rng:NextNumber(-0.25, 0.25), rng:NextNumber(0, math.pi), rng:NextNumber(-0.2, 0.2)),
				C3(70 + rng:NextInteger(0, 30), 52, 36), M.Wood, nil, true)
		end
		for _ = 1, 7 do
			local p = Vector3.new(-30 + rng:NextNumber(-2, 2), 28 + rng:NextNumber(0, 0.6), 48 + rng:NextNumber(-3.5, 3.5))
			mk(nest, "Bone", Vector3.new(0.35, 0.35, rng:NextNumber(1.2, 2.2)), CFrame.new(p) * A(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, math.pi), 0), BONE, nil, nil, true)
		end
		local sk = CFrame.new(-29, 28.9, 46) * A(0, 0.7, 0)
		mk(nest, "DeerSkull", Vector3.new(1.1, 0.9, 1.9), sk, BONE, nil, nil, true)
		mk(nest, "SkullEye", Vector3.new(1.15, 0.3, 0.3), sk * CFrame.new(0, 0.15, -0.3), SOOT, nil, nil, true)
		for _, s in { -1, 1 } do
			mk(nest, "Antler", Vector3.new(0.2, 2.2, 0.2), sk * CFrame.new(s * 0.4, 1.3, 0.3) * A(-0.3, 0, -s * 0.4), C3(186, 170, 134), nil, nil, true)
			mk(nest, "Tine", Vector3.new(0.16, 1, 0.16), sk * CFrame.new(s * 0.75, 1.6, 0) * A(-0.9, 0, -s * 0.2), C3(186, 170, 134), nil, nil, true)
		end
		-- claw marks along the tie beams (he climbs these), moss hanging off them
		for z = -24, 54, 13 do
			for _ = 1, 2 do claws(dec, Vector3.new(rng:NextNumber(-66, 66), 24.4, z - 0.92), Vector3.new(0, 0, -1), 1.3) end
			for _ = 1, 2 do
				local len = rng:NextNumber(1.6, 4)
				mk(dec, "Moss", Vector3.new(0.3, len, 0.12), CFrame.new(rng:NextNumber(-70, 70), 23.5 - len / 2, z + rng:NextNumber(-0.7, 0.7)), C3(60, 74, 46), M.Grass, nil, true)
			end
		end
		-- antler trophies on the long walls (over the windows)
		for _, side in { -1, 1 } do
			for _, z in { 8, 32 } do
				local cf = CFrame.new(side * 77.7, 16.5, z) * A(0, side > 0 and math.pi / 2 or -math.pi / 2, 0)
				local tm = Instance.new("Model"); tm.Name = "Trophy"; tm.Parent = dec
				mk(tm, "Plaque", Vector3.new(2, 2.4, 0.3), cf, LOG, M.Wood, "PS2_DarkBeam1", true)
				mk(tm, "Skull", Vector3.new(0.8, 0.8, 1.2), cf * CFrame.new(0, -0.1, -0.7), BONE, nil, nil, true)
				for _, s in { -1, 1 } do
					mk(tm, "Antler", Vector3.new(0.18, 2, 0.18), cf * CFrame.new(s * 0.6, 1.1, -0.6) * A(0, 0, -s * 0.5), C3(186, 170, 134), nil, nil, true)
					mk(tm, "Tine", Vector3.new(0.14, 0.9, 0.14), cf * CFrame.new(s * 1.0, 1.4, -0.6) * A(0, 0, s * 0.3), C3(186, 170, 134), nil, nil, true)
				end
			end
		end
		table.insert(out, "Bunkhouse: posts, dividers, nest, claws, trophies")
	end
end

---------------------------------------------------------------------------------------------- THE BOATHOUSE
do
	local map = maps:FindFirstChild("Camp_Boathouse")
	if map then
		clearOld(map)
		local F1 = floorY(map)
		local st, dec = map.Structure, map.Decor
		-- the pillars beside the slip (cover from her hook)
		local pil = group(st, "Pillars")
		for _, x in { -27, 27 } do
			for _, z in { -46, -22, 2 } do
				logPost(map, pil, x, z, F1, F1 + 24, 2.6)
				-- weed and slime up the bottom of each
				for k = 0, 3 do
					local a = k * math.pi / 2 + rng:NextNumber(-0.3, 0.3)
					local len = rng:NextNumber(2, 4.5)
					mk(dec, "Weed", Vector3.new(0.5, len, 0.1), CFrame.new(x + math.cos(a) * 1.36, F1 + len / 2, z + math.sin(a) * 1.36) * A(0, -a + math.pi / 2, 0),
						C3(46, 70, 50), M.Grass, nil, true)
				end
			end
		end
		-- two stacks of crates on the docks (cover)
		local cr = group(st, "CrateStacks")
		local function stack(cx: number, cz: number)
			local s = 3.6
			for i, o in { { -1, -1, 0 }, { 1, -1, 0 }, { -1, 1, 0 }, { 1, 1, 0 }, { -0.5, 0, 1 }, { 0.6, 0.2, 1 } } do
				local cf = CFrame.new(cx + o[1] * s / 2, F1 + s / 2 + o[3] * s, cz + o[2] * s / 2) * A(0, rng:NextNumber(-0.12, 0.12), 0)
				solid(map, cr, "Crate", Vector3.one * s, cf, i % 2 == 0 and C3(120, 92, 62) or C3(104, 80, 54), M.WoodPlanks, "PS2_Siding1")
				mk(cr, "CrateBand", Vector3.new(s + 0.1, 0.35, s + 0.1), cf * CFrame.new(0, s * 0.3, 0), LOG, M.Wood, nil, true)
			end
		end
		stack(-48, -34)
		stack(50, -16)
		-- fishing nets hung on the long walls
		for _, side in { -1, 1 } do
			for _, z in { -52, 4 } do
				local net = Instance.new("Model"); net.Name = "Net"; net.Parent = dec
				local x = side * 78.1
				for k = 0, 8 do
					local zz = z - 4 + k
					mk(net, "Strand", Vector3.new(0.08, 6 - math.abs(k - 4) * 0.4, 0.08), CFrame.new(x, 12 - math.abs(k - 4) * 0.2, zz), C3(54, 58, 52), nil, nil, true)
				end
				for k = 0, 5 do mk(net, "Strand", Vector3.new(0.08, 0.08, 8.4 - k * 0.6), CFrame.new(x, 9 + k, z), C3(54, 58, 52), nil, nil, true) end
				for k = 0, 2 do mk(net, "Float", Vector3.new(0.5, 0.5, 0.5), CFrame.new(x - side * 0.2, 9.4, z - 3 + k * 3), C3(200, 150, 60), nil, nil, true) end
			end
		end
		-- wet footprints out of the water (she walks the docks), puddles
		local pr = group(dec, "WetPrints")
		for i = 0, 7 do prints(pr, Vector3.new(-18.5 - i * 1.6, F1 + 0.03, -30 + math.sin(i) * 0.6), math.pi / 2, C3(18, 30, 34), 0.25, i % 2 == 0) end
		for i = 0, 7 do prints(pr, Vector3.new(18.5 + i * 1.6, F1 + 0.03, -6 + math.sin(i) * 0.6), -math.pi / 2, C3(18, 30, 34), 0.25, i % 2 == 0) end
		for _, p in { { -36, -44 }, { 34, -8 }, { -24, 8 }, { 40, -48 } } do
			mk(pr, "Puddle", Vector3.new(0.06, rng:NextNumber(3, 5), rng:NextNumber(3, 5)), CFrame.new(p[1], F1 + 0.03, p[2]) * A(0, 0, math.pi / 2), C3(16, 30, 34), M.Glass, nil, true, 0.3).Shape = Enum.PartType.Cylinder
		end
		table.insert(out, "Boathouse: pillars, crate stacks, nets, prints")
	end
end

---------------------------------------------------------------------------------------------- THE MESS HALL
do
	local map = maps:FindFirstChild("Camp_MessHall")
	if map then
		clearOld(map)
		local F1 = floorY(map)
		local st, dec = map.Structure, map.Decor
		local posts = group(st, "Posts")
		for _, z in { 10, 36 } do
			logPost(map, posts, -9, z, F1, F1 + 24, 2.4)
			-- scorched where he ran into them
			mk(dec, "Scorch", Vector3.new(2.5, 5, 0.05), CFrame.new(-9, F1 + 5, z - 1.24), SOOT, nil, nil, true, 0.3)
		end
		-- the trail of burnt bootprints: kitchen hatch -> front door (his round)
		local trail = group(dec, "BurntTrail")
		local pts = { Vector3.new(-14, 0, -4), Vector3.new(-12, 0, 8), Vector3.new(-4, 0, 22), Vector3.new(-2, 0, 36), Vector3.new(0, 0, 50) }
		local step = true
		for i = 1, #pts - 1 do
			local a, b = pts[i], pts[i + 1]
			local d = b - a
			local yaw = math.atan2(-d.X, -d.Z)
			for k = 0, math.floor(d.Magnitude / 1.6) - 1 do
				local p = a + d.Unit * k * 1.6
				prints(trail, Vector3.new(p.X, F1 + 0.03, p.Z), yaw, SOOT, 0.15, step)
				step = not step
				if rng:NextNumber() < 0.18 then
					mk(trail, "Scorch", Vector3.new(rng:NextNumber(1.5, 3), 0.04, rng:NextNumber(1.5, 3)), CFrame.new(p.X, F1 + 0.025, p.Z) * A(0, rng:NextNumber(0, 3), 0), SOOT, nil, nil, true, 0.45)
				end
			end
		end
		-- the staff photo board by the front door: one photo burnt black
		local board = group(dec, "StaffBoard")
		local bcf = CFrame.new(20, F1 + 9, 58.35)
		mk(board, "Board", Vector3.new(9, 5.2, 0.3), bcf, C3(150, 112, 70), M.Fabric, nil, true)
		mk(board, "Frame", Vector3.new(9.6, 5.8, 0.25), bcf * CFrame.new(0, 0, 0.1), LOG, M.Wood, nil, true)
		for i = 0, 5 do
			local col, row = i % 3, math.floor(i / 3)
			local pcf = bcf * CFrame.new(-2.8 + col * 2.8, 1.2 - row * 2.5, -0.2) * A(0, 0, rng:NextNumber(-0.08, 0.08))
			if i == 4 then
				mk(board, "BurntPhoto", Vector3.new(1.7, 2.1, 0.06), pcf, SOOT, nil, nil, true)
				mk(board, "BurntEdge", Vector3.new(1.9, 0.4, 0.05), pcf * CFrame.new(0, -1.1, 0.01) * A(0, 0, 0.2), C3(60, 30, 16), nil, nil, true)
			else
				mk(board, "Photo", Vector3.new(1.6, 2, 0.06), pcf, C3(214, 204, 180), nil, nil, true)
				mk(board, "Face", Vector3.new(0.6, 0.7, 0.02), pcf * CFrame.new(0, 0.25, -0.04), C3(130, 112, 92), nil, nil, true)
				mk(board, "Shirt", Vector3.new(1.1, 0.6, 0.02), pcf * CFrame.new(0, -0.55, -0.04), C3(70, 100, 66), nil, nil, true)
			end
		end
		local title = mk(board, "Title", Vector3.new(7, 1, 0.1), bcf * CFrame.new(0, 3.3, -0.1), C3(232, 220, 190), nil, nil, true)
		local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.PixelsPerStud = 40; sg.Parent = title
		local tl = Instance.new("TextLabel"); tl.Size = UDim2.fromScale(1, 1); tl.BackgroundTransparency = 1; tl.Text = "STAFF  -  SUMMER '87"
		tl.Font = Enum.Font.SpecialElite; tl.TextScaled = true; tl.TextColor3 = C3(40, 30, 24); tl.Parent = sg
		-- melted candles on the tables (no lights: a tiny flame each)
		for _, x in { -40, 22 } do
			for _, z in { 10, 36 } do
				for k = -1, 1 do
					local h = rng:NextNumber(0.5, 1.3)
					local p = Vector3.new(x + k * 5 + rng:NextNumber(-1, 1), F1 + 3.2, z + rng:NextNumber(-1, 1))
					mk(dec, "Wax", Vector3.new(0.05, 1.1, 1.1), CFrame.new(p + Vector3.new(0, 0.03, 0)) * A(0, 0, math.pi / 2), C3(226, 220, 200), nil, nil, true).Shape = Enum.PartType.Cylinder
					mk(dec, "Candle", Vector3.new(h, 0.42, 0.42), CFrame.new(p + Vector3.new(0, h / 2, 0)) * A(0, 0, math.pi / 2), C3(236, 230, 214), nil, nil, true).Shape = Enum.PartType.Cylinder
					mk(dec, "Flame", Vector3.new(0.16, 0.3, 0.16), CFrame.new(p + Vector3.new(0, h + 0.2, 0)), C3(255, 170, 70), M.Neon, nil, true)
				end
			end
		end
		-- the banner's east end, burnt
		mk(dec, "BannerBurn", Vector3.new(9, 3.8, 0.06), CFrame.new(-1.5, 18, -8.85), SOOT, nil, nil, true, 0.15)
		mk(dec, "BannerBurnEdge", Vector3.new(0.6, 3.6, 0.07), CFrame.new(-6, 18, -8.84) * A(0, 0, 0.15), C3(120, 50, 20), nil, nil, true, 0.2)
		table.insert(out, "Mess Hall: posts, burnt trail, staff board, candles")
	end
end

---------------------------------------------------------------------------------------------- THE BARN
do
	local map = maps:FindFirstChild("Camp_Barn")
	if map then
		clearOld(map)
		local F1 = floorY(map)
		local st, dec = map.Structure, map.Decor
		local STRAW = C3(200, 170, 90)
		local hay = group(st, "HayStacks")
		local tops = {} :: { Vector3 }
		-- a stack of bales: nx x nz bales, `layers` high, along x or z; the top layer is short (a step)
		local function hayStack(cx: number, cz: number, alongX: boolean, nx: number, nz: number, layers: number)
			local L, W, Hh = 4.6, 2.6, 2.9
			for l = 0, layers - 1 do
				for i = 0, nx - 1 do
					for j = 0, nz - 1 do
						if not (l == layers - 1 and i == nx - 1 and j == 0 and layers > 1) then
							local ox = (i - (nx - 1) / 2) * (alongX and L or W)
							local oz = (j - (nz - 1) / 2) * (alongX and W or L)
							local cf = CFrame.new(cx + ox, F1 + Hh / 2 + l * Hh, cz + oz) * A(0, (alongX and 0 or math.pi / 2) + rng:NextNumber(-0.06, 0.06), 0)
							solid(map, hay, "Bale", Vector3.new(L, Hh, W), cf, STRAW:Lerp(C3(170, 140, 70), rng:NextNumber(0, 0.5)), M.Grass)
							for _, s in { -1, 1 } do mk(hay, "Twine", Vector3.new(0.14, Hh + 0.04, W + 0.04), cf * CFrame.new(s * 1.2, 0, 0), C3(90, 66, 40), M.Fabric, nil, true) end
							if l == layers - 1 then table.insert(tops, cf.Position + Vector3.new(0, Hh / 2, 0)) end
						end
					end
				end
			end
		end
		hayStack(-16, 14, true, 2, 2, 3)
		hayStack(32, 22, false, 2, 2, 3)
		hayStack(-44, 30, false, 2, 2, 2)
		hayStack(40, -4, true, 2, 2, 2)
		-- his pole, in the middle of the barn: empty, the ropes cut
		local pole = group(st, "EmptyPole")
		solid(map, pole, "Pole", Vector3.new(1.1, 13, 1.1), CFrame.new(-4, F1 + 6.5, 20), C3(92, 72, 50), M.Wood, "PS2_DarkBeam1")
		local bar = mk(pole, "Crossbar", Vector3.new(9, 0.8, 0.8), CFrame.new(-4, F1 + 10.5, 20), C3(92, 72, 50), M.Wood, "PS2_DarkBeam1", true)
		for _, s in { -1, 1 } do
			mk(pole, "Rope", Vector3.new(0.9, 0.5, 0.95), CFrame.new(-4 + s * 3.2, F1 + 10.5, 20), C3(170, 150, 110), M.Fabric, nil, true)
			mk(pole, "RopeEnd", Vector3.new(0.18, 1.6, 0.18), CFrame.new(-4 + s * 3.2, F1 + 9.4, 20) * A(0, 0, s * 0.2), C3(170, 150, 110), M.Fabric, nil, true)
		end
		mk(pole, "StrawPile", Vector3.new(5, 0.5, 4), CFrame.new(-4, F1 + 0.25, 20) * A(0, 0.4, 0), STRAW, M.Grass, nil, true)
		for _ = 1, 8 do
			mk(pole, "Straw", Vector3.new(0.12, 0.08, rng:NextNumber(1, 2)), CFrame.new(-4 + rng:NextNumber(-3.5, 3.5), F1 + 0.55, 20 + rng:NextNumber(-3, 3)) * A(0, rng:NextNumber(0, 3), 0), STRAW, M.Grass, nil, true)
		end
		-- crows perched all over: the loft railing, the tractor, the stalls, the pole, the hay
		local crows = group(dec, "Crows")
		for _, x in { -50, -22, 4, 26, 62 } do crow(crows, x, 20.9, -13.9, rng:NextNumber(-0.8, 0.8)) end
		crow(crows, 22, F1 + 11, -41, 0.6); crow(crows, 25, F1 + 11, -38, -2.4)
		for _, z in { 6, 34 } do crow(crows, -71 + rng:NextNumber(-3, 3), F1 + 6, z, math.pi / 2 + rng:NextNumber(-0.5, 0.5)) end
		crow(crows, -8, F1 + 10.9, 20, 0.3)
		for i = 1, math.min(4, #tops) do
			local p = tops[rng:NextInteger(1, #tops)]
			crow(crows, p.X + rng:NextNumber(-1, 1), p.Y, p.Z, rng:NextNumber(0, math.pi * 2))
		end
		-- black feathers on the floor
		for _ = 1, 26 do
			mk(dec, "Feather", Vector3.new(0.16, 0.03, rng:NextNumber(0.5, 0.9)), CFrame.new(rng:NextNumber(-60, 60), F1 + 0.03, rng:NextNumber(-12, 54)) * A(0, rng:NextNumber(0, 6), 0),
				BLACK, nil, nil, true)
		end
		table.insert(out, "Barn: hay stacks, empty pole, crows, feathers")
	end
end

return table.concat(out, "\n")
