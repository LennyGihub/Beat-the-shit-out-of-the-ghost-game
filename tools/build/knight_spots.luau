-- THE VOID KNIGHT'S FIVE DOORS (Edit, standalone: python3 tools/studio.py luau Edit tools/build/knight_spots.luau)
-- For every map (ServerStorage.Maps.* and the Mansion in the workspace) it finds 5 places on the map's own inside
-- walls (Structure.Interior) where the Void Knight can burn a doorway through and step into a room, and stores
-- them as a Folder "KnightSpots" of invisible parts in the map. Each part stands on the floor, on the wall's middle
-- plane, at the centre of the doorway; its front (LookVector) points into the room he steps into (where the
-- camera of his entrance stands). Attribute Clear = the wall's height above that floor.
-- A good place: the wall is solid there (no door, window or gap), the floor is at the same height on both sides,
-- the room in front is open for 16+ studs (the camera), there are 6+ studs free behind (he stands there), and no
-- lamp, piece of furniture, decor or other structure (stairs, frames) is in the doorway or where he ends up (a picture
-- hung on the wall itself is allowed: the doorway takes it down whole, and a bare wall scores a little better).
-- The five are spread out over the map. Server/KnightDoor uses them. Re-running replaces them.
local SS = game:GetService("ServerStorage")
local UP = Vector3.yAxis
local DW, DH = 5.6, 10 -- doorway size it checks (the real one is cut to his height, never taller than this)
local NEED_ROOM, NEED_BACK = 16, 6

local function spotsFor(m: Model, live: boolean): (number, string)
	local work = live and m or m:Clone()
	if not live then work.Parent = workspace end
	local st = work:FindFirstChild("Structure")
	local it = st and st:FindFirstChild("Interior")
	if not st or not it then
		if not live then work:Destroy() end
		return 0, "no Structure.Interior"
	end
	local rpS = RaycastParams.new()
	rpS.FilterType = Enum.RaycastFilterType.Include
	rpS.FilterDescendantsInstances = { st }
	rpS.RespectCanCollide = false
	local rpI = RaycastParams.new()
	rpI.FilterType = Enum.RaycastFilterType.Include
	rpI.FilterDescendantsInstances = { it }
	-- everything that must not be in the doorway or where he stands: decor, lights, furniture, other structure
	local blockers = {} :: { Instance }
	for _, n in { "Decor", "Lights", "Furniture" } do
		local f = work:FindFirstChild(n)
		if f then table.insert(blockers, f) end
	end
	for _, c in st:GetChildren() do if c ~= it then table.insert(blockers, c) end end
	-- (boxes, not spatial queries: paintings, trims and much decor have CanQuery off and a query would miss them)
	type Box = { lo: Vector3, hi: Vector3 }
	local function boxOf(p: BasePart): Box
		local cf, h = p.CFrame, p.Size / 2
		local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
		local e = Vector3.new(math.abs(r.X) * h.X + math.abs(u.X) * h.Y + math.abs(l.X) * h.Z,
			math.abs(r.Y) * h.X + math.abs(u.Y) * h.Y + math.abs(l.Y) * h.Z,
			math.abs(r.Z) * h.X + math.abs(u.Z) * h.Y + math.abs(l.Z) * h.Z)
		return { lo = p.Position - e, hi = p.Position + e }
	end
	local function hit(a: Box, b: Box): boolean
		return a.lo.X < b.hi.X and a.hi.X > b.lo.X and a.lo.Y < b.hi.Y and a.hi.Y > b.lo.Y and a.lo.Z < b.hi.Z and a.hi.Z > b.lo.Z
	end
	local blockBoxes, wallBoxes = {} :: { Box }, {} :: { Box }
	for _, f in blockers do
		for _, d in f:GetDescendants() do
			if d:IsA("BasePart") and d.Transparency < 1 then table.insert(blockBoxes, boxOf(d)) end
		end
	end
	for _, d in it:GetDescendants() do
		if d:IsA("BasePart") then table.insert(wallBoxes, boxOf(d)) end
	end
	local function blocked(b: Box): boolean
		for _, o in blockBoxes do if hit(b, o) then return true end end
		return false
	end
	-- the wall's own layers in the doorway (plaster, wainscot, rails, baseboards) must run past both sides of it;
	-- anything shorter hung on the wall there (a painting, a mirror, a frame) would be cut in half
	local function decorated(b: Box, alongX: boolean, a0: number, a1: number): boolean
		for _, o in wallBoxes do
			if hit(b, o) then
				local lo, hi = alongX and o.lo.X or o.lo.Z, alongX and o.hi.X or o.hi.Z
				if lo > a0 - 0.3 or hi < a1 + 0.3 then return true end
			end
		end
		return false
	end
	local function free(from: Vector3, dir: Vector3, want: number): number
		local r = workspace:Raycast(from, dir * want, rpS)
		return r and r.Distance or want
	end
	local function floorAt(p: Vector3): number?
		local r = workspace:Raycast(p + UP * 4, Vector3.new(0, -9, 0), rpS)
		return r and r.Normal.Y > 0.7 and r.Position.Y or nil
	end

	local cands = {}
	local why = { walls = 0, pts = 0, floor = 0, sides = 0, solid = 0, wide = 0, box = 0, stand = 0 }
	for _, w in it:GetDescendants() do
		if not w:IsA("BasePart") or w:GetAttribute("CarvedPiece") then continue end
		local s = w.Size
		if math.abs(w.CFrame.UpVector.Y) < 0.99 or s.Y < 10 or math.min(s.X, s.Z) > 2.5 then continue end
		local alongX = s.X > s.Z
		local len = alongX and s.X or s.Z
		if len < DW + 4 then continue end
		why.walls += 1
		local along = alongX and w.CFrame.RightVector or w.CFrame.LookVector
		local n = alongX and w.CFrame.LookVector or w.CFrame.RightVector
		along = Vector3.new(along.X, 0, along.Z).Unit
		n = Vector3.new(n.X, 0, n.Z).Unit
		local thick = alongX and s.Z or s.X
		local bottom, top = w.Position.Y - s.Y / 2, w.Position.Y + s.Y / 2
		local t = -len / 2 + DW / 2 + 1.5
		while t <= len / 2 - DW / 2 - 1.5 do
			local c = Vector3.new(w.Position.X, bottom, w.Position.Z) + along * t
			why.pts += 1
			local fa = floorAt(c + n * (thick / 2 + 1.5))
			local fb = floorAt(c - n * (thick / 2 + 1.5))
			if fa and fb and math.abs(fa - fb) < 0.6 and bottom <= fa + 0.4 and top - fa >= DH + 0.8 then
				why.floor += 1
				local fy = math.max(fa, fb)
				local base = Vector3.new(c.X, fy, c.Z)
				local function sideFree(dir: Vector3, want: number): number
					local m0 = want
					for _, lat in { -DW / 2 + 0.3, 0, DW / 2 - 0.3 } do
						for _, h in { 2.5, 6.5 } do
							m0 = math.min(m0, free(base + along * lat + dir * (thick / 2 + 0.6) + UP * h, dir, want))
						end
					end
					return m0
				end
				local fA, fB = sideFree(n, 22), sideFree(-n, 12)
				local fA2, fB2 = sideFree(-n, 22), sideFree(n, 12)
				local room, back, dir
				if fA >= NEED_ROOM and fB >= NEED_BACK and (fA >= fA2 or fB2 < NEED_BACK) then room, back, dir = fA, fB, n
				elseif fA2 >= NEED_ROOM and fB2 >= NEED_BACK then room, back, dir = fA2, fB2, -n end
				if dir then
					why.sides += 1
					-- solid all across the doorway, from both sides (no door, window or gap there already)
					local solid = true
					for _, lat in { -DW / 2 + 0.3, 0, DW / 2 - 0.3 } do
						for _, h in { 0.8, DH / 2, DH - 0.4 } do
							for _, sgn in { 1, -1 } do
								local from = base + along * lat + UP * h + dir * sgn * (thick / 2 + 2.5)
								local r = workspace:Raycast(from, -dir * sgn * 3, rpI)
								if not r then solid = false end
							end
						end
					end
					-- the room's side wall must not be right at the door (the camera stands a little to the side)
					local wide = free(base + dir * 5 + UP * 4, along, 6) >= 5 and free(base + dir * 5 + UP * 4, -along, 6) >= 5
					-- nothing in the doorway (both sides of it) or where he ends up, and nothing hung on the wall there
					local ax = math.abs(along.X) > 0.5
					local hw, ht = DW / 2 + 0.5, thick / 2 + 1.1
					local half = ax and Vector3.new(hw, DH / 2 - 0.15, ht) or Vector3.new(ht, DH / 2 - 0.15, hw)
					local mid = base + UP * (DH / 2)
					local doorBox = { lo = mid - half, hi = mid + half }
					local a = ax and base.X or base.Z
					-- (pictures hung on the wall itself are fine: Ragdoll.cutDoor takes them down whole with the cut-out;
					-- a spot with none scores a little better)
					local box = blocked(doorBox)
					local hung = decorated({ lo = mid - half + (ax and Vector3.new(0.5, 0, 0) or Vector3.new(0, 0, 0.5)),
						hi = mid + half - (ax and Vector3.new(0.5, 0, 0) or Vector3.new(0, 0, 0.5)) }, ax, a - DW / 2, a + DW / 2)
					local sp = base + dir * 3.6 + UP * 4.5
					local stand = blocked({ lo = sp - Vector3.new(1.5, 3.5, 1.5), hi = sp + Vector3.new(1.5, 3.5, 1.5) })
					if solid then why.solid += 1 end
					if solid and wide then why.wide += 1 end
					if solid and wide and not box then why.box += 1 end
					if solid and wide and not box and not stand then why.stand += 1 end
					if solid and wide and not box and not stand then
						table.insert(cands, { pos = base, dir = dir, clear = top - fy, room = room, back = back, wall = w,
							score = math.min(room, 22) + math.min(back, 10) * 0.5 + (hung and 0 or 4) })
					end
				end
			end
			t += 2.5
		end
	end
	-- five, spread out: the best one first, then each time the one furthest from those already taken (one per wall)
	table.sort(cands, function(a, b) return a.score > b.score end)
	local chosen = {}
	local function nearest(c): number
		local d = math.huge
		for _, o in chosen do
			if o.wall == c.wall then return -1 end
			d = math.min(d, (o.pos - c.pos).Magnitude)
		end
		return d
	end
	while #chosen < 5 and #cands > 0 do
		local best, bestV = nil, -math.huge
		for _, c in cands do
			local d = #chosen == 0 and 0 or nearest(c)
			if d >= 0 then
				local v = (#chosen == 0 and 0 or math.min(d, 60)) * 2 + c.score
				if v > bestV then best, bestV = c, v end
			end
		end
		if not best then break end
		table.insert(chosen, best)
		table.remove(cands, table.find(cands, best))
	end
	-- store them in the real map (the clone was only for the raycasts)
	local old = m:FindFirstChild("KnightSpots")
	if old then old:Destroy() end
	local f = Instance.new("Folder")
	f.Name = "KnightSpots"
	local lines = {}
	for i, c in chosen do
		local p = Instance.new("Part")
		p.Name = "Spot" .. i
		p.Size = Vector3.new(1, 1, 1)
		p.Transparency = 1
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
		p.CFrame = CFrame.lookAt(c.pos, c.pos + c.dir)
		p:SetAttribute("Clear", math.floor(c.clear * 10) / 10)
		p.Parent = f
		table.insert(lines, string.format("(%.0f,%.0f,%.0f) room %.0f back %.0f clear %.0f %s", c.pos.X, c.pos.Y, c.pos.Z, c.room, c.back, c.clear, c.wall.Name))
	end
	f.Parent = m
	if not live then work:Destroy() end
	local w2 = {}
	for k, v in why do table.insert(w2, k .. "=" .. v) end
	table.sort(w2)
	return #chosen, "[" .. table.concat(w2, " ") .. "] " .. table.concat(lines, "; ")
end

local out = {}
-- (a line `ONLYP = "Camp_"` before the script: only the maps whose id starts with it)
for _, m in SS:WaitForChild("Maps"):GetChildren() do
	if m:IsA("Model") and (not ONLYP or string.sub(m.Name, 1, #ONLYP) == ONLYP) then
		local ok, n, info = pcall(spotsFor, m, false)
		table.insert(out, m.Name .. ": " .. (ok and (n .. " spots " .. info) or ("ERROR " .. tostring(n))))
	end
end
local mansion = workspace:FindFirstChild("Mansion")
if mansion and not ONLYP and (mansion:GetAttribute("MapId") == nil or mansion:GetAttribute("MapId") == "Mansion") then
	local ok, n, info = pcall(spotsFor, mansion, true)
	table.insert(out, "Mansion (workspace): " .. (ok and (n .. " spots " .. info) or ("ERROR " .. tostring(n))))
end
return table.concat(out, "\n")
