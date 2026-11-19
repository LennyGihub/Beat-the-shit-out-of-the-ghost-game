-- THE MOONLIGHT CARNIVAL: the ITEM SPOTS of its six buildings (run in Edit after the buildings, furnish and
-- doors_clear: tools/studio.py luau Edit tools/build/maps/carn_items.luau; it can run again). Same rules as
-- maps/camp_items.luau (its helpers, copied): tier 1 common things, tier 2 better ones, tier 3 = the secret rooms
-- (the Big Top's costume room, the Hall of Mirrors' stash, the Prize Arcade's hoard - their doors are built by the
-- buildings' own scripts). Every spot is moved off furniture / walls (spiral search) or dropped.
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


-- each map: { tier-1 spots }, { tier-2 spots {x, y?, z} }, the secret room's tier-3 spot or nil
local LIST = {
	Carn_BigTop = { { { -30, 30 }, { 30, 30 }, { -30, -30 }, { 30, -30 }, { 0, -34 }, { -38, 0 }, { 38, 0 }, { -20, 48 }, { 20, 46 } },
		{ { -72, 8.8, 20 }, { 72, 8.8, -20 }, { 10, 2, -48 } }, { -70, -50 } },
	Carn_Mirrors = { { { -66, -16 }, { -30, 4 }, { 6, 28 }, { 42, -10 }, { 66, 16 }, { -54, 30 }, { 30, 50 }, { -50, 48 }, { -30, -40 } },
		{ { 40, 0, -46 }, { -60, 0, -50 }, { 0, 0, 16 } }, { 66, -50 } },
	Carn_Carousel = { { { -40, 10 }, { 40, 10 }, { -50, 40 }, { 50, -30 }, { -60, -20 }, { 20, 40 }, { -10, -44 }, { 60, 20 }, { 0, 30 } },
		{ { 0, 1.6, 6 }, { -30, 0.5, -48 }, { 56, 0, 44 } }, nil },
	Carn_Funhouse = { { { -60, 30 }, { -10, 46 }, { 40, 36 }, { 60, 10 }, { -20, 10 }, { 20, -40 }, { -40, -20 }, { 60, -40 }, { 0, -50 } },
		{ { -40, 0, -42 }, { 36, 9, -51 }, { -70, 0, -50 } }, nil },
	Carn_Prizes = { { { -40, 30 }, { 40, 30 }, { -40, -10 }, { 40, -10 }, { -20, 46 }, { 20, 46 }, { -30, -36 }, { 30, -36 }, { 0, 20 } },
		{ { 0, 0, -14 }, { -56, 0, 0 }, { 56, 0, 20 } }, { 0, -50 } },
	Carn_GhostTrain = { { { -50, 30 }, { -40, -40 }, { 0, 30 }, { 0, -20 }, { 12, 10 }, { 50, 20 }, { 40, -10 }, { -60, 0 }, { 60, 40 } },
		{ { 55, 2.5, -45 }, { -70, 0, -50 }, { 0, 0, -50 } }, nil },
}
for id, l in LIST do
	local map = maps:FindFirstChild(id)
	if not map then table.insert(out, id .. ": missing"); continue end
	local f = map:FindFirstChild("ItemSpots")
	if f then f:Destroy() end
	local F1 = floorY(map)
	for _, p in l[1] do spot(map, p[1], F1, p[2], 1) end
	for _, p in l[2] do spot(map, p[1], F1 + p[2], p[3], 2) end
	if l[3] then spot(map, l[3][1], F1, l[3][2], 3, true) end
	table.insert(out, id .. ": spots " .. #spotsOf(map):GetChildren() .. (map:FindFirstChild("Secrets") and " (secret room)" or ""))
end
return table.concat(out, "\n")
