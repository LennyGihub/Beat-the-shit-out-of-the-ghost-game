-- PHONE TABLES for the Caller (standalone, Edit mode, safe to re-run; run it after furnish / detail / stairs):
--   python3 tools/studio.py luau Edit tools/build/maps/phones.luau
-- The Caller's phone used to be put on whatever table was near (on top of its lamp, on a thrown desk...) and often
-- hung in the air. Every map now has three small telephone tables of its own, built into the house against a wall
-- (folder <map>.PhoneSpots, models "PhoneTable" with a part "Top"): Server/Caller rings the phone on one of them.
-- They are not furniture: nobody can lift or smash them, so the phone never ends up floating.
-- A spot needs: a floor with a roof over it, a plain wall right behind (no door, no window), nothing standing there,
-- free floor in front, not in a doorway / near a stair / in a KeepClear zone, away from where the players start.
-- The three are spread through the house (the upper floor gets one when it has a fitting wall).
local SS = game:GetService("ServerStorage")
local PER_MAP = 3
local WALL = { Wall = true, Skin = true, Wainscot = true }
local WOOD, WOOD2, CLOTH, PAPER = Color3.fromRGB(64, 44, 34), Color3.fromRGB(84, 58, 42), Color3.fromRGB(206, 196, 168), Color3.fromRGB(222, 214, 190)

local function noGoTest(MP)
	local zones = {}
	local kc = MP:FindFirstChild("KeepClear")
	if kc then
		for _, p in kc:GetChildren() do
			if p:IsA("BasePart") then
				table.insert(zones, { p.Position.X - p.Size.X / 2, p.Position.Z - p.Size.Z / 2, p.Position.X + p.Size.X / 2, p.Position.Z + p.Size.Z / 2, p.Position.Y - p.Size.Y / 2 - 1.5, p.Position.Y + p.Size.Y / 2 })
			end
		end
	end
	for _, w in MP.Structure:GetDescendants() do
		if w:IsA("Model") then
			local sills = {}
			for _, c in w:GetChildren() do if c:IsA("BasePart") and (c.Name == "Sill" or c.Name == "Glass") then table.insert(sills, c.Position) end end
			for _, f in w:GetChildren() do
				if f:IsA("BasePart") and f.Name == "Frame" and f.Size.Y < 0.75 then
					local alongX = f.Size.X > f.Size.Z
					local half = (alongX and f.Size.X or f.Size.Z) / 2 - 0.6
					local window = false
					for _, sp in sills do if math.abs(sp.X - f.Position.X) < 1 and math.abs(sp.Z - f.Position.Z) < 1 then window = true; break end end
					if not window and half >= 2 then
						local ha, hp = half + 2.5, 7
						local floor = f.Position.Y < 22.5 and 2 or 23
						local x, z = f.Position.X, f.Position.Z
						table.insert(zones, alongX and { x - ha, z - hp, x + ha, z + hp, floor - 1.5, floor + 8 } or { x - hp, z - ha, x + hp, z + ha, floor - 1.5, floor + 8 })
					end
				end
			end
		end
	end
	-- round a staircase (9 studs): its foot and its top must stay wide open. (Not on the Ship: its companionways
	-- are one model spanning the whole hull.)
	if MP.Name ~= "Ship" then
		for _, st in MP.Structure:GetChildren() do
			if st.Name == "Stairs" and st:IsA("Model") then
				local cf, size = st:GetBoundingBox()
				local p = cf.Position
				table.insert(zones, { p.X - size.X / 2 - 9, p.Z - size.Z / 2 - 9, p.X + size.X / 2 + 9, p.Z + size.Z / 2 + 9, -10, 60 })
			end
		end
	end
	return function(x, y, z)
		for _, zn in zones do
			if x > zn[1] and x < zn[3] and z > zn[2] and z < zn[4] and y > zn[5] and y < zn[6] then return true end
		end
		return false
	end
end

-- cf = on the floor, against the wall, -Z into the room
local function buildTable(parent: Instance, cf: CFrame): Model
	local m = Instance.new("Model")
	m.Name = "PhoneTable"
	local function part(name, sx, sy, sz, x, y, z, color, mat, solid)
		local p = Instance.new("Part")
		p.Name = name; p.Size = Vector3.new(sx, sy, sz); p.CFrame = cf * CFrame.new(x, y, z); p.Color = color; p.Material = mat
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Anchored = true; p.CanTouch = false; p.CanCollide = solid; p.CanQuery = solid
		p.Parent = m
		return p
	end
	local top = part("Top", 3.2, 0.3, 2, 0, 3.05, 0, WOOD, Enum.Material.Wood, true)
	part("Apron", 2.9, 0.5, 1.7, 0, 2.65, 0, WOOD2, Enum.Material.Wood, true)
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do part("Leg", 0.3, 2.9, 0.3, sx * 1.35, 1.45, sz * 0.75, WOOD, Enum.Material.Wood, true) end end
	part("Shelf", 2.7, 0.2, 1.5, 0, 0.9, 0, WOOD2, Enum.Material.Wood, false)
	part("Doily", 2.2, 0.05, 1.6, 0, 3.22, 0, CLOTH, Enum.Material.Fabric, false)
	part("Notepad", 0.7, 0.08, 0.9, 1.15, 3.26, 0.35, PAPER, Enum.Material.SmoothPlastic, false).CFrame = cf * CFrame.new(1.15, 3.26, 0.35) * CFrame.Angles(0, 0.3, 0)
	part("Book", 1.6, 0.3, 1.1, -0.3, 1.15, 0, Color3.fromRGB(86, 30, 28), Enum.Material.SmoothPlastic, false)
	m.PrimaryPart = top
	m.Parent = parent
	return m
end

local function place(MP: Instance, id: string): string
	local S, FURN, DEC = MP:FindFirstChild("Structure"), MP:FindFirstChild("Furniture"), MP:FindFirstChild("Decor")
	if not S or not FURN then return id .. ": no Structure / Furniture" end
	local old = MP:FindFirstChild("PhoneSpots"); if old then old:Destroy() end
	local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Include; rp.FilterDescendantsInstances = { S }
	local op = OverlapParams.new(); op.FilterType = Enum.RaycastFilterType.Include; op.FilterDescendantsInstances = { S, FURN, DEC }
	local noGo = noGoTest(MP)
	local spawnAt = MP:GetAttribute("SpawnInside")
	if typeof(spawnAt) ~= "Vector3" then spawnAt = Vector3.new(0, 5, 46) end
	local anyWall = id == "Ship" -- the hull and bulkheads have their own names
	local function wallish(inst: BasePart): boolean
		if not inst.CanCollide or inst:FindFirstAncestor("Stairs") or inst:FindFirstAncestor("StairRails") then return false end
		if anyWall then return inst.Size.Y >= 6 or math.max(inst.Size.X, inst.Size.Z) >= 10 end
		return WALL[inst.Name] == true and inst.Size.Y >= 6
	end
	local function blocked(cf: CFrame, size: Vector3): boolean
		for _, h in workspace:GetPartBoundsInBox(cf, size, op) do
			if h.CanCollide and h.Transparency < 1 then return true end
		end
		return false
	end
	local cands = {}
	local heights = { 8, 29, spawnAt.Y + 4 }
	for x = -75, 75, 2.5 do
		for z = -55, 55, 2.5 do
			local seen = {}
			for _, y0 in heights do
				local down = workspace:Raycast(Vector3.new(x, y0, z), Vector3.new(0, -9, 0), rp)
				if down and down.Normal.Y > 0.9 and not down.Instance:FindFirstAncestor("Stairs") then
					local fy = down.Position.Y
					local key = math.floor(fy + 0.5)
					if not seen[key] and not noGo(x, fy, z) and (Vector3.new(x, fy, z) - spawnAt).Magnitude > 24
						and workspace:Raycast(Vector3.new(x, fy + 2, z), Vector3.new(0, 40, 0), rp) then
						seen[key] = true
						for _, d in { Vector3.xAxis, -Vector3.xAxis, Vector3.zAxis, -Vector3.zAxis } do
							local o = Vector3.new(x, fy + 3.5, z)
							local r = workspace:Raycast(o, d * 4, rp)
							if r and math.abs(r.Normal.Y) < 0.1 and r.Normal:Dot(d) < -0.95 and wallish(r.Instance :: BasePart) then
								local lat = Vector3.yAxis:Cross(d)
								local plain = true
								for _, oo in { o + lat * 1.9, o - lat * 1.9, Vector3.new(x, fy + 1, z), Vector3.new(x, fy + 7, z) } do
									local r2 = workspace:Raycast(oo, d * 4, rp)
									if not r2 or math.abs(r2.Distance - r.Distance) > 0.6 then plain = false; break end
								end
								if plain then
									local n = -d
									local foot = Vector3.new(r.Position.X, fy, r.Position.Z) + n * 1.1
									local cf = CFrame.lookAt(foot, foot + n)
									-- nothing where the table goes, and free floor in front of it
									if not blocked(cf * CFrame.new(0, 2.4, 0), Vector3.new(3.8, 4, 1.9)) and not blocked(cf * CFrame.new(0, 3, -3.6), Vector3.new(4, 5, 4.6))
										and not noGo(foot.X + n.X * 3, fy, foot.Z + n.Z * 3) then
										table.insert(cands, { cf = cf, pos = foot })
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if #cands == 0 then return id .. ": no wall fits a phone table" end
	-- spread them: the first far from the start, then each as far as possible from the ones already chosen
	-- (a floor apart counts double, so the upper floor gets one)
	local function gap(a: Vector3, b: Vector3): number
		local d = a - b
		return math.sqrt(d.X * d.X + d.Z * d.Z) + math.abs(d.Y) * 2
	end
	local chosen = {}
	for i = 1, math.min(PER_MAP, #cands) do
		local best, bestScore = nil, -math.huge
		for _, c in cands do
			local score
			if i == 1 then
				local ds = gap(c.pos, spawnAt)
				score = math.abs(c.pos.Y - spawnAt.Y) < 6 and -math.abs(ds - 55) + 200 or -1000
			else
				score = math.huge
				for _, ch in chosen do score = math.min(score, gap(c.pos, ch.pos)) end
				-- the third one goes back on the players' floor (two downstairs, one up)
				if i == 3 and math.abs(c.pos.Y - spawnAt.Y) >= 6 then score -= 1000 end
			end
			if not best or score > bestScore then best, bestScore = c, score end
		end
		if not best then break end
		table.insert(chosen, best)
	end
	local folder = Instance.new("Folder"); folder.Name = "PhoneSpots"; folder.Parent = MP
	local where = {}
	for _, c in chosen do
		buildTable(folder, c.cf)
		table.insert(where, string.format("(%.0f, %.0f, %.0f)", c.pos.X, c.pos.Y, c.pos.Z))
	end
	return string.format("%s: %d phone tables of %d fitting walls: %s", id, #chosen, #cands, table.concat(where, " "))
end

-- the Mansion is live in workspace; the others are copied into workspace for the raycasts, then put back
local out = {}
local live = workspace:FindFirstChild("Mansion")
if live then table.insert(out, place(live, "Mansion")) end
local maps = SS:FindFirstChild("Maps")
if maps then
	local temp = Instance.new("Folder"); temp.Name = "_PhoneTemp"; temp.Parent = workspace
	for _, src in maps:GetChildren() do
		if src.Name ~= "Mansion" then
			local copy = src:Clone()
			copy.Parent = temp
			local ok, res = pcall(place, copy, src.Name)
			table.insert(out, ok and res or (src.Name .. " FAILED: " .. tostring(res)))
			if ok then
				src:Destroy()
				copy.Parent = maps
			else
				copy:Destroy()
			end
		end
	end
	temp:Destroy()
end
return table.concat(out, "\n")
