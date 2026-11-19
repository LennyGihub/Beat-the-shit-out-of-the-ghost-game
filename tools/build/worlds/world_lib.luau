-- WORLD LIB (2026-11-19): helpers for the campaign maps' surroundings (ServerStorage.Worlds.<map id>, swapped in
-- for the dark forest by Server/MapLoader while one of that map's buildings is loaded). Prepend after lib2 +
-- furn_lib + maplib + maps/shape_lib, then one worlds/<map>.luau:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--       tools/build/worlds/world_lib.luau tools/build/worlds/camp.luau > run.luau; tools/studio.py luau Edit run.luau
-- The layout every world keeps: the building stands on x -80..80, z -60..60 (its front at z 59); the yard is
-- x -95..95, z 52..165 (invisible walls in workspace.Grounds.Walls); the railway (Grounds.Railway, kept) runs along
-- z = 150 from x -260 to 260 and the train crosses the yard's side fences there (leave z 143..157 open). Everything
-- in a world is decoration (no collision, never hit by a ray) except what a player may stand on in the yard.
local SSw = game:GetService("ServerStorage")
local AST = SSw:WaitForChild("LobbyAssets")
local WROOT: Model = nil :: any
local function WD() return { deco = true } end

local function beginWorld(name: string): Model
	local f = SSw:FindFirstChild("Worlds")
	if not f then f = Instance.new("Folder"); f.Name = "Worlds"; f.Parent = SSw end
	local old = f:FindFirstChild(name); if old then old:Destroy() end
	WROOT = Instance.new("Model"); WROOT.Name = name
	WROOT:SetAttribute("World", name)
	return WROOT
end
local function endWorld(): string
	WROOT.Parent = SSw.Worlds
	local n, l = 0, 0
	for _, d in WROOT:GetDescendants() do
		if d:IsA("BasePart") then
			n += 1
			if not d.CanCollide then d.CanQuery = false; d.CanTouch = false end
		elseif d:IsA("Light") then l += 1 end
	end
	return WROOT.Name .. " world: " .. n .. " parts, " .. l .. " lights"
end

-- a tree (or any LobbyAssets model) standing on the ground at x, z
local function plant(name: string, x: number, z: number, yaw: number, scale: number, parent: Instance, y: number?)
	local src = AST:FindFirstChild(name) :: Model?
	if not src then return end
	local m = src:Clone()
	if scale ~= 1 then m:ScaleTo(scale) end
	m:PivotTo(CFrame.new(x, 0, z) * CFrame.Angles(0, yaw, 0))
	local cf, sz = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + Vector3.new(0, sz.Y / 2 - cf.Position.Y - 0.3 + (y or 0), 0))
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false end
	end
	m.Parent = parent
	return m
end

-- in the yard / the building's box / on the railway: keep out
local function inPlay(x: number, z: number, pad: number?): boolean
	pad = pad or 0
	if x > -100 - pad and x < 100 + pad and z > 45 - pad and z < 172 + pad then return true end -- the yard
	if x > -88 - pad and x < 88 + pad and z > -70 - pad and z < 66 + pad then return true end -- the building
	if math.abs(z - 150) < 9 + pad and math.abs(x) < 280 then return true end -- the railway
	return false
end

-- n trees scattered in a box, away from the yard / building / railway and from any `avoid(x, z)`
local function forest(parent: Instance, rng: Random, n: number, x0: number, z0: number, x1: number, z1: number, kinds, avoid)
	local count = 0
	for _ = 1, n * 3 do
		if count >= n then break end
		local x, z = rng:NextNumber(x0, x1), rng:NextNumber(z0, z1)
		if not inPlay(x, z, 4) and not (avoid and avoid(x, z)) then
			local k = kinds[rng:NextInteger(1, #kinds)]
			plant(k[1], x, z, rng:NextNumber(0, 6.28), rng:NextNumber(k[2], k[3]), parent)
			count += 1
		end
	end
	return count
end

-- a low-poly hill / mountain: a jagged cone of n sides (tri faces), radius r, height h
local function mountain(parent: Instance, rng: Random, cx: number, cz: number, r: number, h: number, n: number, sty, cap)
	local pts = {}
	for k = 0, n - 1 do
		local a = k * 2 * math.pi / n + rng:NextNumber(-0.15, 0.15)
		local rr = r * rng:NextNumber(0.75, 1.1)
		table.insert(pts, Vector3.new(cx + rr * math.cos(a), -2, cz + rr * math.sin(a)))
	end
	local apex = Vector3.new(cx + rng:NextNumber(-r, r) * 0.15, h, cz + rng:NextNumber(-r, r) * 0.15)
	-- a ring half way up, pushed in and out: the faces break into facets
	local mid = {}
	for k, p in pts do
		local t = rng:NextNumber(0.42, 0.58)
		local q = p:Lerp(apex, t)
		local outv = (Vector3.new(q.X, 0, q.Z) - Vector3.new(cx, 0, cz)).Unit
		mid[k] = q + outv * rng:NextNumber(-0.06, 0.1) * r
	end
	for k = 1, n do
		local k2 = k % n + 1
		quad(parent, "Slope", pts[k], pts[k2], mid[k2], mid[k], sty, 2, WD())
		tri(parent, "Peak", mid[k], mid[k2], apex, cap or sty, 2, WD())
	end
end

-- a flat sheet of water (dark, a little reflective) with an optional bed
local function water(parent: Instance, x0: number, z0: number, x1: number, z1: number, y: number, color: Color3?, refl: number?)
	local w = box(parent, "Water", x0, y - 0.3, z0, x1, y, z1, st(M.SmoothPlastic, nil, color or Color3.fromRGB(14, 26, 34)), WD())
	w.Reflectance = refl or 0 -- (a reflection shows the skybox texture: a pale-blue glare at night)
	w.CastShadow = false
	return w
end

-- a lamp post (pole + lamp + light)
local function lampPost(parent: Instance, x: number, z: number, color: Color3, h: number?, poleSty, range: number?)
	h = h or 10
	local lp = model(parent, "LampPost")
	cyl(lp, CFrame.new(x, h / 2, z), "Pole", 0.5, h, 0, 0, 0, poleSty or st(M.Metal, nil, Color3.fromRGB(40, 38, 36)), WD())
	local g = box(lp, "Lamp", x - 0.6, h - 0.4, z - 0.6, x + 0.6, h + 0.8, z + 0.6, st(M.Neon, nil, color), WD())
	light(g, range or 22, 1.1, color)
	return lp
end

-- bulbs hanging on a sagging line from a to b (Vector3), every `step` studs; colors cycles
local function bulbLine(parent: Instance, a: Vector3, z: Vector3, step: number, sag: number, colors: { Color3 }, wire: Color3?, lights: number?)
	local m = model(parent, "BulbLine")
	local len = (z - a).Magnitude
	local n = math.max(2, math.floor(len / step))
	local prev = a
	for i = 0, n do
		local t = i / n
		local p = a:Lerp(z, t) - Vector3.new(0, sag * 4 * t * (1 - t), 0)
		if i > 0 then
			local mid = (prev + p) / 2
			part(m, "Wire", Vector3.new(0.1, 0.1, (p - prev).Magnitude), CFrame.lookAt(mid, p), st(M.SmoothPlastic, nil, wire or Color3.fromRGB(20, 20, 20)), WD())
		end
		ball(m, CFrame.new(p - Vector3.new(0, 0.35, 0)), "Bulb", 0.6, 0, 0, 0, st(M.Neon, nil, colors[i % #colors + 1]), WD())
		prev = p
	end
	if lights and lights > 0 then
		for k = 1, lights do
			local t = k / (lights + 1)
			local g = box(m, "Glow", 0, 0, 0, 0.2, 0.2, 0.2, st(M.Neon, nil, colors[1]), { deco = true, t = 1 })
			g.Position = a:Lerp(z, t) - Vector3.new(0, sag * 4 * t * (1 - t) + 1, 0)
			light(g, 18, 0.9, colors[1])
		end
	end
	return m
end

-- a straight fence of posts and rails from (x1, z1) to (x2, z2), with gaps where gap(x, z) says so
local function fenceRun(parent: Instance, x1: number, z1: number, x2: number, z2: number, postSty, railSty, h: number?, step: number?, gap)
	h = h or 4
	step = step or 6
	local a, z = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	local len = (z - a).Magnitude
	local n = math.max(1, math.floor(len / step))
	local dir = (z - a).Unit
	for i = 0, n do
		local p = a + dir * (len * i / n)
		if not (gap and gap(p.X, p.Z)) then
			box(parent, "Post", p.X - 0.35, 0, p.Z - 0.35, p.X + 0.35, h + 0.4, p.Z + 0.35, postSty, WD())
			if i < n then
				local q = a + dir * (len * (i + 1) / n)
				if not (gap and gap(q.X, q.Z)) then
					for _, y in { h * 0.4, h * 0.85 } do
						local m1, m2 = p + Vector3.new(0, y, 0), q + Vector3.new(0, y, 0)
						part(parent, "Rail", Vector3.new(0.3, 0.45, (m2 - m1).Magnitude), CFrame.lookAt((m1 + m2) / 2, m2), railSty, WD())
					end
				end
			end
		end
	end
end
-- the yard's edge (x = +-95 from z 52 to 165, z = 165 across), open where the train crosses
local function yardEdge(parent: Instance, draw)
	local function trainGap(_, z) return math.abs(z - 150) < 7 end
	draw(parent, -95, 54, -95, 165, trainGap)
	draw(parent, 95, 54, 95, 165, trainGap)
	draw(parent, -95, 165, 95, 165, nil)
	draw(parent, -95, 52, -82, 52, nil)
	draw(parent, 82, 52, 95, 52, nil)
end

-- a gable roof over a local box (cf = the centre of the floor, w across x, d along z, walls h high, rise): panels
-- + the two gable triangles, all decoration
local function gableOn(parent: Instance, cf: CFrame, w: number, d: number, h: number, rise: number, roofSty, endSty, over: number?)
	over = over or 1.2
	local hw = w / 2 + over
	local ex = cf.RightVector
	for _, s in { 1, -1 } do
		local p = (cf * CFrame.new(s * hw, h - over * rise / (w / 2), 0)).Position
		local q = (cf * CFrame.new(0, h + rise, 0)).Position
		panel(parent, "Roof", p, q, cf.LookVector, d + over * 2, roofSty, 0.8, WD())
	end
	for _, s in { 1, -1 } do
		local base = cf * CFrame.new(0, 0, s * d / 2)
		tri(parent, "Gable", (base * CFrame.new(-w / 2, h, 0)).Position, (base * CFrame.new(w / 2, h, 0)).Position,
			(base * CFrame.new(0, h + rise, 0)).Position, endSty, 0.6, WD())
	end
	local _ = ex
end

-- a small cabin facing cf.LookVector: log walls, a gable roof, a door, warm lit windows (or dark ones)
local function cabin(parent: Instance, cf: CFrame, w: number, d: number, h: number, wallSty, roofSty, trimSty, lit: boolean?)
	local m = model(parent, "Cabin")
	b(m, cf, "Walls", w, h, d, 0, h / 2, 0, wallSty, WD())
	b(m, cf, "Base", w + 1, 1, d + 1, 0, 0.5, 0, trimSty, WD())
	gableOn(m, cf, w, d, h, w * 0.42, roofSty, wallSty, 1.4)
	-- front: the door and two windows, a little porch roof
	b(m, cf, "Door", 3, 6.5, 0.3, 0, 3.6, -d / 2 - 0.15, trimSty, WD())
	local winSty = lit and st(M.Neon, nil, Color3.fromRGB(255, 176, 96)) or st(M.SmoothPlastic, nil, Color3.fromRGB(14, 16, 20))
	for _, x in { -w / 2 + 3.5, w / 2 - 3.5 } do
		b(m, cf, "Window", 3, 3, 0.3, x, h * 0.55, -d / 2 - 0.15, winSty, WD())
		b(m, cf, "Sill", 3.6, 0.4, 0.6, x, h * 0.55 - 1.7, -d / 2 - 0.3, trimSty, WD())
	end
	for _, z in { -d / 4, d / 4 } do
		b(m, cf, "SideWindow", 0.3, 2.6, 2.6, w / 2 + 0.15, h * 0.55, z, winSty, WD())
	end
	-- log ends at the corners
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
		b(m, cf, "LogEnd", 1.2, h, 1.2, c[1] * (w / 2 + 0.3), h / 2, c[2] * (d / 2 + 0.3), trimSty, WD())
	end
	-- the chimney
	b(m, cf, "Chimney", 2, h + w * 0.42 + 2, 2, w / 2 - 2.5, (h + w * 0.42 + 2) / 2, d / 4, st(M.Cobblestone, "PS2_Stone1", Color3.fromRGB(90, 86, 80)), WD())
	if lit then
		local g = b(m, cf, "Glow", 0.2, 0.2, 0.2, 0, h * 0.55, -d / 2 - 2, winSty, { deco = true, t = 1 })
		light(g, 16, 0.9, Color3.fromRGB(255, 170, 90))
	end
	return m
end
