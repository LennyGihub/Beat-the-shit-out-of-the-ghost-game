-- Shared helpers for the Mansion build scripts (Edit mode). World coords; front door faces +Z.
local M = Enum.Material
local MS = game:GetService("MaterialService")
local function st(mat, mv, color) return { mat = mat, mv = mv, color = color } end
local T = {
	floor = st(M.WoodPlanks, "PS2_FloorPlanks2", Color3.fromRGB(98, 96, 100)),
	plaster = st(M.Plaster, "PS2_Plaster", Color3.fromRGB(196, 188, 172)),
	wainscot = st(M.Wood, "PS2_Wainscot1", Color3.fromRGB(96, 76, 62)),
	beam = st(M.Wood, "PS2_DarkBeam1", Color3.fromRGB(110, 78, 58)),
	rug = st(M.Carpet, "PS2_Rug1", Color3.fromRGB(150, 136, 126)),
	siding = st(M.WoodPlanks, "PS2_Siding", Color3.fromRGB(150, 132, 118)),
	stone = st(M.Cobblestone, "PS2_Stone1", Color3.fromRGB(165, 160, 152)),
	wallpaper = st(M.Fabric, "PS2_Wallpaper2", Color3.fromRGB(205, 215, 195)),
	roof = st(M.Slate, nil, Color3.fromRGB(62, 52, 48)),
	trim = st(M.Wood, "PS2_DarkBeam1", Color3.fromRGB(90, 62, 45)),
	glass = st(M.Glass, nil, Color3.fromRGB(40, 50, 70)),
	brass = st(M.Metal, nil, Color3.fromRGB(190, 150, 70)),
	iron = st(M.Metal, nil, Color3.fromRGB(40, 38, 36)),
	glow = st(M.Neon, nil, Color3.fromRGB(255, 190, 120)),
	shade = st(M.Fabric, nil, Color3.fromRGB(205, 165, 115)),
}
local WARM = Color3.fromRGB(255, 196, 150)
do -- tile sizes
	local tiles = { PS2_FloorPlanks2 = 12, PS2_Plaster = 22, PS2_Wainscot1 = 6, PS2_DarkBeam1 = 8, PS2_Rug1 = 18, PS2_Siding = 10, PS2_Stone1 = 10, PS2_Wallpaper2 = 10 }
	for _, d in MS:GetDescendants() do
		if d:IsA("MaterialVariant") and tiles[d.Name] then d.StudsPerTile = tiles[d.Name] end
	end
end

local function getRoot(name)
	local r = workspace:FindFirstChild(name)
	if not r then r = Instance.new("Model"); r.Name = name; r.Parent = workspace end
	return r
end
local function fresh(parent, name)
	local f = parent:FindFirstChild(name)
	if f then f:Destroy() end
	f = Instance.new("Model"); f.Name = name; f.Parent = parent
	return f
end
local function model(parent, name)
	local m = Instance.new("Model"); m.Name = name; m.Parent = parent
	return m
end

local function part(parent, name, size, cf, s, o)
	local p = Instance.new("Part")
	p.Name = name; p.Anchored = true; p.Size = size; p.CFrame = cf
	p.Color = s.color; p.Material = s.mat
	if s.mv then p.MaterialVariant = s.mv end
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	if o then
		if o.shape then p.Shape = o.shape end
		if o.t then p.Transparency = o.t end
		if o.color then p.Color = o.color end
		if o.deco then p.CanCollide = false; p.CanQuery = false; p.CanTouch = false end
		if o.noShadow then p.CastShadow = false end
	end
	p.Parent = parent
	return p
end
local function box(parent, name, x1, y1, z1, x2, y2, z2, s, o)
	return part(parent, name, Vector3.new(math.abs(x2 - x1), math.abs(y2 - y1), math.abs(z2 - z1)),
		CFrame.new((x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2), s, o)
end
local FACE = { N = 0, S = math.pi, E = -math.pi / 2, W = math.pi / 2 }
local function at(x, y, z, face) return CFrame.new(x, y, z) * CFrame.Angles(0, FACE[face] or face or 0, 0) end
local function b(m, cf, name, sx, sy, sz, x, y, z, s, o) return part(m, name, Vector3.new(sx, sy, sz), cf * CFrame.new(x, y, z), s, o) end
-- (cyl / ball copy their options: they used to write the shape into the table they were given, and the shared DECO
-- table then turned every later decoration into a ball - giant spheres where boards and piers should be)
local function withShape(o, shape) local c = {} if o then for k, v in o do c[k] = v end end c.shape = shape return c end
local function cyl(m, cf, name, d, h, x, y, z, s, o)
	o = withShape(o, Enum.PartType.Cylinder)
	return part(m, name, Vector3.new(h, d, d), cf * CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.pi / 2), s, o)
end
local function ball(m, cf, name, d, x, y, z, s, o)
	o = withShape(o, Enum.PartType.Ball)
	return part(m, name, Vector3.new(d, d, d), cf * CFrame.new(x, y, z), s, o)
end
local function light(p, range, brightness, color, shadows)
	local l = Instance.new("PointLight")
	l.Range = range; l.Brightness = brightness; l.Color = color or WARM; l.Shadows = shadows or false
	l.Parent = p
	return l
end
local DECO = { deco = true }
