-- The STAIR PASS: replaces each map's staircase with a proper one from the stair kit in maplib (Edit mode).
-- Prepend a `local TARGET = "<MapId>"` line (or "ALL") + lib2 + furn_lib + maplib:
--   (echo 'local TARGET = "ALL"'; cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/stairs.luau) > /tmp/run.luau
-- The map files still build the old plain flight (a 31-stud wedge that started against the front wall, with a
-- rail across its top); run this pass after any of them. It is safe to re-run: it removes what it finds
-- (Structure.Stairs, the old railing at the stair top, furniture / lights / clutter standing in the new stairwell),
-- closes the old hole in the upper floor, cuts the new one and builds the stair with the map's own materials.
-- The Asylum builds its stairs itself (maps/asylum.luau) and is not in SPECS.
local SSs = game:GetService("ServerStorage")

local function styleOf(p) return st(p.Material, p.MaterialVariant ~= "" and p.MaterialVariant or nil, p.Color) end
local function find(root, name, pred)
	for _, d in root:GetDescendants() do
		if d:IsA("BasePart") and d.Name == name and (not pred or pred(d)) then return d end
	end
	return nil
end

-- the upper floor (parts named Slab, y 22..23): take the rectangle out of every slab it crosses
local function cutSlab(STRm, x1, z1, x2, z2)
	for _, p in STRm:GetChildren() do
		if p:IsA("BasePart") and p.Name == "Slab" and math.abs(p.Position.Y - 22.5) < 0.6 then
			local a1, a2 = p.Position.X - p.Size.X / 2, p.Position.X + p.Size.X / 2
			local b1, b2 = p.Position.Z - p.Size.Z / 2, p.Position.Z + p.Size.Z / 2
			if a1 < x2 - 0.01 and a2 > x1 + 0.01 and b1 < z2 - 0.01 and b2 > z1 + 0.01 then
				local function piece(u1, v1, u2, v2)
					if u2 - u1 < 0.05 or v2 - v1 < 0.05 then return end
					local q = p:Clone()
					q.Size = Vector3.new(u2 - u1, p.Size.Y, v2 - v1)
					q.Position = Vector3.new((u1 + u2) / 2, p.Position.Y, (v1 + v2) / 2)
					q.Parent = STRm
				end
				local mx1, mx2 = math.max(a1, x1), math.min(a2, x2)
				piece(a1, b1, mx1, b2); piece(mx2, b1, a2, b2)
				piece(mx1, b1, mx2, math.max(b1, z1)); piece(mx1, math.min(b2, z2), mx2, b2)
				p:Destroy()
			end
		end
	end
end
local function fillSlab(STRm, x1, z1, x2, z2)
	local sample = find(STRm, "Slab")
	cutSlab(STRm, x1, z1, x2, z2)
	if sample then box(STRm, "Slab", x1, 22, z1, x2, 23, z2, styleOf(sample)) end
end

local function aabb(p)
	local cf, h = p.CFrame, p.Size / 2
	local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
	local e = Vector3.new(math.abs(r.X) * h.X + math.abs(u.X) * h.Y + math.abs(l.X) * h.Z, math.abs(r.Y) * h.X + math.abs(u.Y) * h.Y + math.abs(l.Y) * h.Z,
		math.abs(r.Z) * h.X + math.abs(u.Z) * h.Y + math.abs(l.Z) * h.Z)
	return cf.Position - e, cf.Position + e
end

-- everything that is not structure and stands in the box goes (rugs stay: the stair covers them)
local function clearVolume(map, lo, hi, furnMargin)
	local gone = {}
	local function hits(p)
		local a, bb = aabb(p)
		return a.X < hi.X and bb.X > lo.X and a.Y < hi.Y and bb.Y > lo.Y and a.Z < hi.Z and bb.Z > lo.Z
	end
	local function kill(inst, label) inst:Destroy(); gone[label] = (gone[label] or 0) + 1 end
	local fm = furnMargin or 2
	for _, f in map.Furniture:GetChildren() do
		if f:IsA("Model") then
			local pv = f:GetPivot().Position
			if pv.X > lo.X - fm and pv.X < hi.X + fm and pv.Z > lo.Z - fm and pv.Z < hi.Z + fm and pv.Y > lo.Y - 1 and pv.Y < hi.Y then kill(f, f.Name) end
		end
	end
	for _, c in map.Lights:GetChildren() do
		for _, p in c:GetDescendants() do
			if p:IsA("BasePart") and hits(p) then kill(c, "light"); break end
		end
	end
	for _, c in map.Decor:GetChildren() do
		if c.Name == "Detail" then
			for _, p in c:GetChildren() do if p:IsA("BasePart") and hits(p) then kill(p, "clutter") end end
		elseif c.Name ~= "Rug" and c.Name ~= "RugBorder" and c.Name ~= "Facade" then
			for _, p in (c:IsA("BasePart") and { c } or c:GetDescendants()) do
				if p:IsA("BasePart") and hits(p) then kill(c, "decor"); break end
			end
		end
	end
	local wd = map.Structure:FindFirstChild("Interior") and map.Structure.Interior:FindFirstChild("Detail")
	if wd then
		for _, p in wd:GetDescendants() do
			if p:IsA("BasePart") and p.Name ~= "Baseboard" and p.Name ~= "Crown" and hits(p) then kill(p, "wall thing") end
		end
	end
	-- ceiling beams of the lower floor that cross the new opening
	for _, p in map:GetDescendants() do
		if p:IsA("BasePart") and p:GetAttribute("Detail") and string.find(p.Name, "Beam") and hits(p) and p.Position.Y > 18 and p.Position.Y < 23 then kill(p, "beam") end
	end
	local t = {}
	for k, n in gone do table.insert(t, n .. " " .. k) end
	table.sort(t)
	return #t > 0 and table.concat(t, ", ") or "nothing"
end

local function removeOld(STRm, railRects)
	for _, c in STRm:GetChildren() do
		if c.Name == "Stairs" or c.Name == "StairLanding" or c.Name == "StairLight" then c:Destroy() end
	end
	for _, c in STRm:GetChildren() do
		if c.Name == "Railing" and c:IsA("Model") then
			local p = c:GetBoundingBox().Position
			for _, r in railRects do
				if p.X > r[1] and p.X < r[3] and p.Z > r[2] and p.Z < r[4] then c:Destroy(); break end
			end
		end
	end
end

-- a ceiling lamp over the stair (the map's own light colour)
local function stairLight(map, pos)
	local col = Color3.fromRGB(255, 214, 170)
	for _, d in map.Lights:GetDescendants() do if d:IsA("PointLight") then col = d.Color; break end end
	local m = model(map.Structure, "StairLight")
	part(m, "Housing", Vector3.new(2.6, 0.4, 2.6), CFrame.new(pos), st(M.Metal, nil, Color3.fromRGB(44, 44, 48)), DECO)
	local g = part(m, "Glow", Vector3.new(1.8, 0.3, 1.8), CFrame.new(pos - Vector3.new(0, 0.3, 0)), st(M.Neon, nil, col), DECO)
	light(g, 40, 1.3, col)
end

local PI = math.pi
-- The wells are ~15.5 wide: each flight then leaves ~7 studs between its guards, which the monster's pathfinding
-- (agent radius 2.2) needs; at 12.75 it could climb the flights but not pass between the posts at the top.
-- They are 23.5 long: an 8.5 deep landing, so it can also make the turn round the middle post (6 was too tight).
-- kind: the guard style. well: the half-turn stair's entry (x, z, facing "N" = it rises toward +Z, "S" toward -Z),
-- mir, W, L. oldHole: the old opening to close. rails: rectangles whose old Railing models go.
local SPECS = {
	Hospital = { kind = "parapet", well = { 69.875, 34.25, "N", -1, 15.75, 23.5 }, oldHole = { 69.4, 24, 78, 58 }, rails = { { 68, 22, 79, 27 } }, low = { b = true }, up = { b = true } },
	Factory = { kind = "balusters", well = { 69.875, 34.25, "N", -1, 15.75, 23.5 }, oldHole = { 69.4, 24, 78, 58 }, rails = { { 68, 22, 79, 27 } }, low = { b = true }, up = { b = true } },
	Funeral = { kind = "balusters", well = { 69.875, 34.25, "N", -1, 15.75, 23.5 }, oldHole = { 69.4, 24, 78, 58 }, rails = { { 68, 22, 79, 27 } }, low = { b = true }, up = { b = true } },
	Prison = { kind = "balusters", well = { 69.875, 34.25, "N", -1, 15.75, 23.5 }, oldHole = { 66, 24, 78, 58 }, rails = {}, low = { b = true }, up = { b = true } },
	School = { kind = "parapet", well = { 21.7, 32.7, "S", 1, 15.4, 23.5 }, oldHole = { -2, 18.6, 5.4, 58 }, rails = { { -4, 18, 0, 59 } }, low = { b = true }, up = { b = true, e = true } },
	Farm = { kind = "balusters", well = { -69.875, 34.25, "N", 1, 15.75, 23.5 }, oldHole = { -60, 18.6, -52.6, 58 }, rails = {}, low = { b = true }, up = { b = true } },
	Hotel = { kind = "balusters", grand = { 0, -2, 12 } },
}

-- THE SHIP keeps its plank companionways (hold -> deck -> quarterdeck / forecastle): they only get dressed. Each run
-- of steps gets dark nosings, and on every side that is not against a bulkhead a balustrade with end posts.
local function dressRuns(map)
	local STRm = map.Structure
	local old = STRm:FindFirstChild("StairRails"); if old then old:Destroy() end
	local m = model(STRm, "StairRails")
	local solid = {}
	for _, p in STRm:GetDescendants() do
		if p:IsA("BasePart") and p.CanCollide and not p:IsDescendantOf(STRm.Stairs) and not p:IsDescendantOf(m) then
			local a, bb = aabb(p)
			table.insert(solid, { a, bb })
		end
	end
	local function blocked(q)
		for _, s in solid do
			if q.X > s[1].X and q.X < s[2].X and q.Y > s[1].Y and q.Y < s[2].Y and q.Z > s[1].Z and q.Z < s[2].Z then return true end
		end
		return false
	end
	-- group the steps into runs (same row, same size)
	local runs = {}
	for _, p in STRm.Stairs:GetChildren() do
		if p:IsA("BasePart") and p.Name == "Step" then
			local key = string.format("%.1f/%.1f/%.1f", p.Position.Z, p.Size.X, p.Size.Z)
			runs[key] = runs[key] or {}
			table.insert(runs[key], p)
		end
	end
	local n = 0
	for _, steps in runs do
		table.sort(steps, function(p, q) return p.Position.Y + p.Size.Y / 2 < q.Position.Y + q.Size.Y / 2 end)
		local first, last = steps[1], steps[#steps]
		local dir = (last.Position - first.Position) * Vector3.new(1, 0, 1)
		if #steps >= 3 and dir.Magnitude > 0.5 then
			dir = dir.Unit
			local side = Vector3.yAxis:Cross(dir)
			local alongX = math.abs(dir.X) > 0.5
			local run = alongX and first.Size.X or first.Size.Z
			local w = alongX and first.Size.Z or first.Size.X
			local topOf = function(p) return p.Position.Y + p.Size.Y / 2 end
			local rise = (topOf(last) - topOf(first)) / (#steps - 1)
			local S = { step = styleOf(first), trim = st(M.Wood, nil, first.Color:Lerp(Color3.new(0, 0, 0), 0.55)), wall = styleOf(first), kind = "balusters" }
			for _, p in steps do
				local c = Vector3.new(p.Position.X, topOf(p) - 0.08, p.Position.Z) - dir * (run / 2 - 0.1)
				part(m, "Nosing", alongX and Vector3.new(0.5, 0.22, w + 0.02) or Vector3.new(w + 0.02, 0.22, 0.5), CFrame.new(c), S.trim, DECO)
			end
			-- the line through the nosings, from the first step's front edge to the floor it reaches
			local a = Vector3.new(first.Position.X, topOf(first), first.Position.Z) - dir * (run / 2)
			local bb = Vector3.new(last.Position.X, topOf(last) + rise, last.Position.Z) + dir * (run / 2)
			local mid = (a + bb) / 2
			for _, sg in { -1, 1 } do
				local off = side * sg * (w / 2 - 0.3)
				local probe = mid + side * sg * (w / 2 + 1) + Vector3.new(0, 2.5, 0)
				if not blocked(probe) then
					guard(m, a + off, bb + off, S)
					newel(m, a + off - dir * 0.5 - Vector3.new(0, rise, 0), S)
					newel(m, bb + off + dir * 0.4, S, 1.4)
					n += 1
				end
			end
		end
	end
	return string.format("%s: companionways dressed (%d balustrades)", map.Name, n)
end

local function pass(map)
	if map.Name == "Ship" then return dressRuns(map) end
	local sp = SPECS[map.Name]
	if not sp then return map.Name .. ": no staircase to replace" end
	local STRm = map.Structure
	-- the map's own materials, read before the old stair goes
	local oldStairs = STRm:FindFirstChild("Stairs")
	local stepP = oldStairs and find(oldStairs, "Step")
	local trimP = oldStairs and find(oldStairs, "Handrail")
	local wallP = STRm:FindFirstChild("Interior") and find(STRm.Interior, "Wall")
	if not stepP or not trimP then return map.Name .. ": no old Stairs to read the materials from" end
	local wainP = find(STRm, "Wainscot")
	local S = { step = styleOf(stepP), trim = styleOf(trimP), wall = wallP and styleOf(wallP) or styleOf(stepP), wain = wainP and styleOf(wainP) or nil, kind = sp.kind }
	removeOld(STRm, sp.rails or {})
	local cleared
	if sp.grand then
		local g = sp.grand
		local cf = CFrame.new(g[1], F1, g[2])
		cleared = clearVolume(map, Vector3.new(g[1] - g[3] / 2 - 0.5, F1 + 0.4, g[2] - 36), Vector3.new(g[1] + g[3] / 2 + 0.5, F1 + 24, g[2] + 1), 0)
		local runnerP = find(map.Decor, "Rug")
		grandStair(STRm, { cf = cf, w = g[3], S = S, runner = runnerP and styleOf(runnerP) or nil })
	else
		local w = sp.well
		local cf = CFrame.new(w[1], F1, w[2]) * CFrame.Angles(0, w[3] == "N" and PI or 0, 0)
		if sp.oldHole then local h = sp.oldHole; fillSlab(STRm, h[1], h[2], h[3], h[4]) end
		local _, hole = dogleg(STRm, { cf = cf, W = w[5], L = w[6], mir = w[4], S = S, low = sp.low, up = sp.up })
		-- the opening runs to the outside wall where the well stands against one
		local x1, z1, x2, z2 = hole[1], hole[2], hole[3], hole[4]
		if x2 > 77 then x2 = 78.2 end
		if x1 < -77 then x1 = -78.2 end
		if z2 > 57 then z2 = 58.2 end
		if z1 < -57 then z1 = -58.2 end
		cutSlab(STRm, x1, z1, x2, z2)
		-- the stair model is new: clear the well around it (not the stair itself)
		local stairsNew = STRm:FindFirstChild("Stairs")
		stairsNew.Parent = nil
		cleared = clearVolume(map, Vector3.new(hole[1] + 0.3, F1 + 0.4, hole[2] + 0.3), Vector3.new(hole[3] - 0.3, F2 + 9, hole[4] - 0.3))
		stairsNew.Parent = STRm
		-- and the floor in front of the entry (below) and of the exit (above): 8 studs, furniture only
		local n = 0
		for _, f in map.Furniture:GetChildren() do
			if f:IsA("Model") then
				local l = cf:PointToObjectSpace(f:GetPivot().Position)
				if math.abs(l.X) < w[5] / 2 + 1 and l.Z > 0 and l.Z < 8 and l.Y > -1.5 and l.Y < 29 and f.Name ~= "ExplosiveBarrel" then f:Destroy(); n += 1 end
			end
		end
		if n > 0 then cleared = cleared .. ", " .. n .. " piece(s) at the foot / top of the stair" end
		stairLight(map, Vector3.new((hole[1] + hole[3]) / 2, 42.6, (hole[2] + hole[4]) / 2))
	end
	local n = 0
	for _, d in STRm.Stairs:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
	return string.format("%s: new stair (%d parts, %s guards); removed from the stairwell: %s", map.Name, n, sp.kind, cleared)
end

local out = {}
local maps = SSs:FindFirstChild("Maps")
for _, map in maps:GetChildren() do
	if TARGET == "ALL" or map.Name == TARGET then
		local ok, res = pcall(pass, map)
		table.insert(out, ok and res or (map.Name .. " FAILED: " .. tostring(res)))
	end
end
return table.concat(out, "\n")
