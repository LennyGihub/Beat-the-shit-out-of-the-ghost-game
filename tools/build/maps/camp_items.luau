-- CAMP HOLLOWMERE: the ITEM SPOTS of every building and the SECRET ROOMS of three of them (run in Edit after the
-- buildings, camp_design included: tools/studio.py luau Edit tools/build/maps/camp_items.luau; it can run again).
--   ItemSpots (folder in the map): parts named Spot, attribute Tier = 1 (common things), 2 (better), 3 (the best:
--     only in secret rooms); Server/Supplies puts an item on every spot when a stage starts (a new roll each time).
--     Every spot is moved off any furniture / wall it would land in (spiral search) or dropped.
--   Secrets (folder in the map): one Model per hidden door (Server/Secrets): parts named Panel move by the model's
--     attribute Slide when the prompt on its Trigger part is used (only seen up close); attributes Action / Object.
--   The rooms themselves are MD_Secret* models (walls in Structure, props in Decor).
--     BUNKHOUSE: a loose wall panel in the storeroom (scrape marks on the floor) -> the old counselor's hiding place.
--     MESS HALL: a pantry shelf that is really a door -> the burned counselor's shrine.
--     BARN: a wall of hay bales on the loft (one column sits a little out) -> the room where the scarecrows were made.
local SS = game:GetService("ServerStorage")
local maps = SS:WaitForChild("Maps")
local C3 = Color3.fromRGB
local M = Enum.Material
local A = CFrame.Angles
local out = {}
local rng = Random.new(31)

local LOG = C3(62, 44, 32)
local INNER = C3(138, 108, 78)
local SOOT = C3(20, 16, 14)
local BONE = C3(214, 204, 176)
local STRAW = C3(200, 170, 90)

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
local function boxAt(parent: Instance, name: string, x0: number, y0: number, z0: number, x1: number, y1: number, z1: number, color: Color3, mat: Enum.Material?, mv: string?, deco: boolean?): Part
	return mk(parent, name, Vector3.new(math.abs(x1 - x0), math.abs(y1 - y0), math.abs(z1 - z0)), CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, mat, mv, deco)
end
local function group(parent: Instance, name: string): Model
	local m = Instance.new("Model"); m.Name = name; m.Parent = parent
	return m
end
local function floorY(map: Instance): number
	local gf = map:FindFirstChild("Structure") and map.Structure:FindFirstChild("GroundFloor") :: BasePart?
	return gf and (gf.Position.Y + gf.Size.Y / 2) or 2.05
end
local function overlaps(a0: Vector3, a1: Vector3, cf: CFrame, size: Vector3): boolean
	local half = cf:VectorToWorldSpace(size / 2)
	half = Vector3.new(math.abs(half.X), math.abs(half.Y), math.abs(half.Z))
	local b0, b1 = cf.Position - half, cf.Position + half
	return a0.X < b1.X and a1.X > b0.X and a0.Y < b1.Y and a1.Y > b0.Y and a0.Z < b1.Z and a1.Z > b0.Z
end
-- furniture inside a box is taken out (logged)
local function clearBox(map: Instance, a0: Vector3, a1: Vector3)
	local fur = map:FindFirstChild("Furniture")
	if not fur then return end
	for _, m in fur:GetChildren() do
		local cf, sz
		if m:IsA("Model") then cf, sz = m:GetBoundingBox() elseif m:IsA("BasePart") then cf, sz = m.CFrame, m.Size end
		if cf and overlaps(a0, a1, cf, sz) then
			table.insert(out, map.Name .. ": took out " .. m.Name)
			m:Destroy()
		end
	end
end
-- the solid things a spot must not land in: furniture, and the building's own parts standing on that floor
local function blocked(map: Instance, p: Vector3): boolean
	local a0, a1 = p + Vector3.new(-1.3, 0.25, -1.3), p + Vector3.new(1.3, 3, 1.3)
	local fur = map:FindFirstChild("Furniture")
	if fur then
		for _, m in fur:GetChildren() do
			local cf, sz
			if m:IsA("Model") then cf, sz = m:GetBoundingBox() elseif m:IsA("BasePart") then cf, sz = m.CFrame, m.Size end
			if cf and overlaps(a0, a1, cf, sz) then return true end
		end
	end
	for _, d in map.Structure:GetDescendants() do
		if d:IsA("BasePart") and d.CanCollide and overlaps(a0, a1, d.CFrame, d.Size) then return true end
	end
	return false
end
local function spotsOf(map: Instance): Folder
	local f = map:FindFirstChild("ItemSpots") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "ItemSpots"; nf.Parent = map
		f = nf
	end
	return f :: Folder
end
-- a spot near (x, y, z): moved off whatever stands there, or left out
local function spot(map: Instance, x: number, y: number, z: number, tier: number, secret: boolean?)
	for ring = 0, 4 do
		for k = 0, ring == 0 and 0 or 7 do
			local a = k * math.pi / 4
			local p = Vector3.new(x + math.cos(a) * ring * 2.2, y, z + math.sin(a) * ring * 2.2)
			if not blocked(map, p) then
				local s = mk(spotsOf(map), "Spot", Vector3.one, CFrame.new(p + Vector3.new(0, 0.1, 0)), C3(255, 255, 255), nil, nil, true, 1)
				s:SetAttribute("Tier", tier)
				if secret then s:SetAttribute("Secret", true) end
				return
			end
		end
	end
	table.insert(out, map.Name .. ": no room for a spot near " .. x .. ", " .. z)
end
local function secretsOf(map: Instance): Folder
	local f = map:FindFirstChild("Secrets") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "Secrets"; nf.Parent = map
		f = nf
	end
	return f :: Folder
end
-- a hidden door: its moving parts are named Panel; Trigger = where the prompt is
local function door(map: Instance, name: string, slide: Vector3, action: string, object: string, trigger: Vector3): Model
	local m = group(secretsOf(map), name)
	m:SetAttribute("Slide", slide); m:SetAttribute("Action", action); m:SetAttribute("Object", object)
	mk(m, "Trigger", Vector3.one, CFrame.new(trigger), C3(255, 255, 255), nil, nil, true, 1)
	return m
end
local function reset(map: Instance)
	for _, n in { "ItemSpots", "Secrets" } do
		local f = map:FindFirstChild(n)
		if f then f:Destroy() end
	end
	local old = {}
	for _, d in map:GetDescendants() do if d:IsA("Model") and string.sub(d.Name, 1, 9) == "MD_Secret" then table.insert(old, d) end end
	for _, d in old do d:Destroy() end
end
local function scrapes(parent: Instance, p: Vector3, dir: Vector3, F1: number)
	local cf = CFrame.lookAt(Vector3.new(p.X, F1 + 0.03, p.Z), Vector3.new(p.X, F1 + 0.03, p.Z) + dir)
	for i = -1, 1 do
		mk(parent, "Scrape", Vector3.new(0.12, 0.03, 2.6), cf * CFrame.new(i * 0.9, 0, -1.3) * A(0, i * 0.25, 0), C3(160, 130, 96), nil, nil, true, 0.2)
	end
end

---------------------------------------------------------------------------------------------- THE BUNKHOUSE
do
	local map = maps:FindFirstChild("Camp_Bunkhouse")
	if map then
		reset(map)
		local F1 = floorY(map)
		local st, dec = map.Structure, map.Decor
		-- the secret room: the storeroom's east end (x 14..26, z -58..-30.6), a wall at x 14 with a loose panel
		clearBox(map, Vector3.new(13, F1, -58), Vector3.new(26, F1 + 14, -30.6))
		local room = group(st, "MD_SecretBunk")
		local H = 14
		boxAt(room, "Wall", 13.6, F1, -58, 14.4, F1 + H, -42, INNER, M.WoodPlanks, "PS2_Siding1")
		boxAt(room, "Wall", 13.6, F1, -38, 14.4, F1 + H, -30.6, INNER, M.WoodPlanks, "PS2_Siding1")
		boxAt(room, "Lintel", 13.6, F1 + 8, -42, 14.4, F1 + H, -38, INNER, M.WoodPlanks, "PS2_Siding1")
		local d = door(map, "BunkPanel", Vector3.new(0, -8.2, 0), "Push", "Loose panel", Vector3.new(13.2, F1 + 4, -40))
		boxAt(d, "Panel", 13.62, F1, -42, 14.38, F1 + 8, -38, INNER:Lerp(C3(90, 70, 50), 0.12), M.WoodPlanks, "PS2_Siding1")
		boxAt(d, "Panel", 13.5, F1 + 7.7, -42, 13.6, F1 + 8, -38, SOOT, nil, nil, true) -- (a dark gap round it)
		boxAt(d, "Panel", 13.5, F1, -42.05, 13.6, F1 + 8, -41.85, SOOT, nil, nil, true)
		boxAt(d, "Panel", 13.5, F1, -38.15, 13.6, F1 + 8, -37.95, SOOT, nil, nil, true)
		scrapes(dec, Vector3.new(11.6, 0, -40), Vector3.new(-1, 0, 0), F1)
		-- inside: the old counselor who hid here (bones in a chair), a lantern, a cot, the stash
		local props = group(dec, "MD_SecretBunkProps")
		boxAt(props, "Cot", 16, F1, -57, 24, F1 + 1.6, -53, C3(70, 80, 60), M.Fabric, nil, true)
		boxAt(props, "Chair", 22, F1, -36, 25, F1 + 2.4, -33, LOG, M.Wood, nil, true)
		boxAt(props, "ChairBack", 24.6, F1 + 2.4, -36, 25, F1 + 6, -33, LOG, M.Wood, nil, true)
		mk(props, "Skull", Vector3.new(1, 1, 1.1), CFrame.new(23.4, F1 + 5.4, -34.5), BONE, nil, nil, true)
		boxAt(props, "Ribs", 23, F1 + 2.6, -35.4, 24.2, F1 + 4.8, -33.6, BONE, nil, nil, true)
		for _, z in { -35, -34 } do mk(props, "Leg", Vector3.new(2.4, 0.35, 0.35), CFrame.new(21.4, F1 + 2.5, z) * A(0, 0, -0.3), BONE, nil, nil, true) end
		local lamp = mk(props, "Lantern", Vector3.new(0.9, 1.2, 0.9), CFrame.new(17, F1 + 0.6, -32.5), C3(255, 190, 110), M.Neon, nil, true)
		local l = Instance.new("PointLight"); l.Color = C3(255, 180, 110); l.Range = 16; l.Brightness = 0.9; l.Parent = lamp
		for i = 0, 3 do boxAt(props, "Photo", 25.85, F1 + 6 + (i % 2) * 2.2, -50 + i * 2.6, 25.95, F1 + 7.6 + (i % 2) * 2.2, -48.4 + i * 2.6, C3(200, 190, 170), nil, nil, true) end
		spot(map, 20, F1, -46, 3, true)
		-- the item spots in the building
		for _, p in { { -50, 0 }, { 50, 20 }, { -12, 40 }, { 12, -6 }, { -40, 52 }, { 60, 48 }, { -64, -40 }, { -4, -44 }, { 40, -44 } } do spot(map, p[1], F1, p[2], 1) end
		for _, p in { { -30, 10 }, { 36, -6 }, { -56, -50 } } do spot(map, p[1], F1, p[2], 2) end
		table.insert(out, "Bunkhouse: secret room, spots " .. #spotsOf(map):GetChildren())
	end
end

---------------------------------------------------------------------------------------------- THE BOATHOUSE (no secret)
do
	local map = maps:FindFirstChild("Camp_Boathouse")
	if map then
		reset(map)
		local F1 = floorY(map)
		for _, p in { { -50, -20 }, { 50, -44 }, { -36, 4 }, { 36, -30 }, { -60, -52 }, { 64, -6 }, { -50, 40 }, { 0, 46 }, { 50, 30 } } do spot(map, p[1], F1, p[2], 1) end
		for _, p in { { -24, -54 }, { 60, 10 }, { -70, 30 } } do spot(map, p[1], F1, p[2], 2) end
		table.insert(out, "Boathouse: spots " .. #spotsOf(map):GetChildren())
	end
end

---------------------------------------------------------------------------------------------- THE MESS HALL
do
	local map = maps:FindFirstChild("Camp_MessHall")
	if map then
		reset(map)
		local F1 = floorY(map)
		local st, dec = map.Structure, map.Decor
		-- the secret room: the pantry's south-east corner (x 64..78, z -58..-44); its door is a shelf full of tins
		clearBox(map, Vector3.new(63, F1, -58), Vector3.new(78, F1 + 12, -43))
		local room = group(st, "MD_SecretMess")
		local H = 12
		boxAt(room, "Wall", 63.6, F1, -58, 64.4, F1 + H, -53, INNER, M.WoodPlanks, "PS2_Siding1")
		boxAt(room, "Wall", 63.6, F1, -49, 64.4, F1 + H, -43.6, INNER, M.WoodPlanks, "PS2_Siding1")
		boxAt(room, "Lintel", 63.6, F1 + 8, -53, 64.4, F1 + H, -49, INNER, M.WoodPlanks, "PS2_Siding1")
		boxAt(room, "Wall", 63.6, F1, -44.4, 78, F1 + H, -43.6, INNER, M.WoodPlanks, "PS2_Siding1")
		boxAt(room, "Ceiling", 63.6, F1 + H, -58, 78, F1 + H + 0.6, -43.6, LOG, M.Wood, "PS2_DarkBeam1")
		local d = door(map, "PantryShelf", Vector3.new(0, -8.2, 0), "Pull", "Heavy shelf", Vector3.new(62.6, F1 + 4, -51))
		boxAt(d, "Panel", 63.6, F1, -53, 64.4, F1 + 8, -49, LOG, M.Wood, "PS2_DarkBeam1")
		for k = 0, 2 do
			boxAt(d, "Panel", 62.8, F1 + 1.6 + k * 2.4, -53, 63.6, F1 + 1.9 + k * 2.4, -49, C3(120, 90, 62), M.Wood, nil, true)
			for j = 0, 3 do
				local col = ({ C3(170, 50, 40), C3(200, 180, 90), C3(70, 110, 60), C3(150, 150, 146) })[j + 1]
				mk(d, "Panel", Vector3.new(0.6, 0.9, 0.6), CFrame.new(63.2, F1 + 2.35 + k * 2.4, -52.4 + j * 1.05), col, M.Metal, nil, true).Shape = Enum.PartType.Cylinder
			end
		end
		scrapes(dec, Vector3.new(61.8, 0, -51), Vector3.new(-1, 0, 0), F1)
		-- inside: his shrine (the staff photo with his face, melted candles round it), a burnt cot, the stash
		local props = group(dec, "MD_SecretMessProps")
		boxAt(props, "Table", 74, F1, -56, 77.6, F1 + 3, -46, LOG, M.Wood, nil, true)
		boxAt(props, "Photo", 77.65, F1 + 4, -52.5, 77.8, F1 + 7, -49.5, C3(214, 204, 180), nil, nil, true)
		boxAt(props, "PhotoBurn", 77.6, F1 + 4, -51.4, 77.66, F1 + 7, -49.5, SOOT, nil, nil, true)
		for i = 0, 5 do
			local h = rng:NextNumber(0.4, 1.1)
			local p = Vector3.new(75 + (i % 2) * 1.6, F1 + 3 + h / 2, -55 + i * 1.6)
			mk(props, "Candle", Vector3.new(h, 0.4, 0.4), CFrame.new(p) * A(0, 0, math.pi / 2), C3(236, 230, 214), nil, nil, true).Shape = Enum.PartType.Cylinder
			mk(props, "Flame", Vector3.new(0.16, 0.3, 0.16), CFrame.new(p + Vector3.new(0, h / 2 + 0.2, 0)), C3(255, 170, 70), M.Neon, nil, true)
		end
		local glow = mk(props, "Glow", Vector3.new(0.2, 0.2, 0.2), CFrame.new(75, F1 + 6, -51), C3(255, 160, 80), nil, nil, true, 1)
		local l = Instance.new("PointLight"); l.Color = C3(255, 150, 70); l.Range = 18; l.Brightness = 1; l.Parent = glow
		boxAt(props, "BurntCot", 65, F1, -57.5, 71, F1 + 1.4, -54, SOOT, M.Fabric, nil, true)
		for _ = 1, 4 do
			mk(props, "Scorch", Vector3.new(rng:NextNumber(2, 4), 0.04, rng:NextNumber(2, 4)), CFrame.new(rng:NextNumber(66, 76), F1 + 0.03, rng:NextNumber(-57, -46)) * A(0, rng:NextNumber(0, 3), 0), SOOT, nil, nil, true, 0.35)
		end
		spot(map, 70, F1, -50, 3, true)
		for _, p in { { -60, 24 }, { 40, 24 }, { -24, 48 }, { 6, 20 }, { -60, -30 }, { -10, -40 }, { 50, -24 }, { 40, -50 }, { 60, 48 } } do spot(map, p[1], F1, p[2], 1) end
		for _, p in { { -70, 44 }, { 0, -50 }, { 70, -20 } } do spot(map, p[1], F1, p[2], 2) end
		table.insert(out, "Mess Hall: secret room, spots " .. #spotsOf(map):GetChildren())
	end
end

---------------------------------------------------------------------------------------------- THE BARN
do
	local map = maps:FindFirstChild("Camp_Barn")
	if map then
		reset(map)
		local F1 = floorY(map)
		local LOFT = 17
		local st, dec = map.Structure, map.Decor
		-- the secret room on the loft (x -78..-62, z -58..-40), walled in by hay bales; one column of bales moves
		clearBox(map, Vector3.new(-78, LOFT, -58), Vector3.new(-61, LOFT + 10, -39))
		local room = group(st, "MD_SecretBarn")
		local function bale(parent: Instance, cf: CFrame, deco: boolean?)
			local b = mk(parent, deco and "Panel" or "Bale", Vector3.new(4.6, 2.9, 2.6), cf, STRAW:Lerp(C3(170, 140, 70), rng:NextNumber(0, 0.5)), M.Grass, nil, false)
			if deco then b.Name = "Panel" end
			for _, s in { -1, 1 } do mk(parent, deco and "Panel" or "Twine", Vector3.new(0.14, 2.94, 2.64), cf * CFrame.new(s * 1.2, 0, 0), C3(90, 66, 40), M.Fabric, nil, true) end
		end
		local d = door(map, "HayDoor", Vector3.new(-3.6, 0, 0), "Push", "Loose bales", Vector3.new(-60.4, LOFT + 3, -48))
		-- the wall along z at x -62 (bales turned along z), three high; the column at z -50..-46 is the door
		for l = 0, 2 do
			for z = -56.7, -41, 4.6 do
				local cf = CFrame.new(-62, LOFT + 1.45 + l * 2.9, z) * A(0, math.pi / 2, 0)
				if z > -50.5 and z < -45.5 then
					bale(d, cf * CFrame.new(0, 0, -0.35), true) -- (sits a little out: the clue)
				else
					bale(room, cf)
				end
			end
			for x = -75.7, -63, 4.6 do bale(room, CFrame.new(x, LOFT + 1.45 + l * 2.9, -40)) end
		end
		-- inside: where the scarecrows were made: a sewing table, a straw dummy with no head, buttons, sacks
		local props = group(dec, "MD_SecretBarnProps")
		boxAt(props, "Table", -77, LOFT, -57, -70, LOFT + 3, -53, LOG, M.Wood, nil, true)
		for i = 0, 5 do mk(props, "Button", Vector3.new(0.1, 0.4, 0.4), CFrame.new(-75 + i * 0.7, LOFT + 3.05, -55) * A(0, 0, math.pi / 2), C3(30, 28, 26), nil, nil, true).Shape = Enum.PartType.Cylinder end
		boxAt(props, "DummyPost", -68.4, LOFT, -44.4, -67.6, LOFT + 7, -43.6, LOG, M.Wood, nil, true)
		boxAt(props, "DummyBody", -69.5, LOFT + 3, -45, -66.5, LOFT + 6.5, -43, C3(110, 90, 60), M.Fabric, nil, true)
		boxAt(props, "DummyArms", -71.5, LOFT + 5.6, -44.4, -64.5, LOFT + 6.3, -43.6, C3(110, 90, 60), M.Fabric, nil, true)
		for _ = 1, 10 do
			mk(props, "Straw", Vector3.new(0.12, 0.08, rng:NextNumber(1, 2.2)), CFrame.new(rng:NextNumber(-76, -64), LOFT + 0.05, rng:NextNumber(-56, -42)) * A(0, rng:NextNumber(0, 3), 0), STRAW, M.Grass, nil, true)
		end
		for k = 0, 2 do boxAt(props, "Sack", -77.5, LOFT, -50 + k * 2.8, -75, LOFT + 2.6, -47.6 + k * 2.8, C3(170, 150, 110), M.Fabric, nil, true) end
		mk(props, "SackHead", Vector3.new(1.6, 1.8, 1.6), CFrame.new(-73, LOFT + 3.9, -55), C3(196, 176, 130), M.Fabric, nil, true)
		local glow = mk(props, "Glow", Vector3.new(0.2, 0.2, 0.2), CFrame.new(-70, LOFT + 6, -50), C3(255, 200, 140), nil, nil, true, 1)
		local l = Instance.new("PointLight"); l.Color = C3(255, 190, 130); l.Range = 16; l.Brightness = 0.8; l.Parent = glow
		spot(map, -69, LOFT, -50, 3, true)
		for _, p in { { -30, 40 }, { 20, 10 }, { 50, 30 }, { -50, 10 }, { 60, -6 }, { 0, -40 }, { -30, -30 }, { 30, -50 } } do spot(map, p[1], F1, p[2], 1) end
		for _, p in { { 40, LOFT, -30 }, { 0, LOFT, -50 }, { -70, F1, 20 } } do spot(map, p[1], p[2], p[3], 2) end
		table.insert(out, "Barn: secret room, spots " .. #spotsOf(map):GetChildren())
	end
end

---------------------------------------------------------------------------------------------- THE MAIN LODGE (no secret)
do
	local map = maps:FindFirstChild("Camp_Lodge")
	if map then
		reset(map)
		local F1 = floorY(map)
		for _, p in { { -40, 20 }, { -60, 40 }, { -30, -4 }, { 40, 30 }, { 60, 0 }, { 30, 50 }, { -60, -40 }, { -20, -40 }, { 20, -40 }, { 60, -40 } } do spot(map, p[1], F1, p[2], 1) end
		for _, p in { { -70, -50 }, { 64, -12 }, { -50, 0 } } do spot(map, p[1], F1, p[2], 2) end
		table.insert(out, "Lodge: spots " .. #spotsOf(map):GetChildren())
	end
end

return table.concat(out, "\n")
