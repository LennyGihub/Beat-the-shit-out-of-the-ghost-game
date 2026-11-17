-- One-off repair of the detail pass's facade decorations (standalone, Edit mode, safe to re-run):
--   python3 tools/studio.py luau Edit tools/build/maps/facade_fix.luau
-- The ivy patches and rust streaks were placed on the outside walls' bounding box, not on the walls: they hung a
-- stud off the facade and floated across doorways and windows (the Mansion's front door). Every patch that has
-- solid wall behind its whole face is pushed flush against it; the others are removed.
-- (maps/detail.luau now places them with the same test, so a new detail pass does not bring them back.)
local SS = game:GetService("ServerStorage")
local SOLID = { Wall = true, Gable = true }

local function fix(map: Instance): string
	local ext = map:FindFirstChild("Structure") and map.Structure:FindFirstChild("Exterior")
	if not ext then return map.Name .. ": no Structure.Exterior" end
	local walls = {}
	for _, p in ext:GetDescendants() do
		if p:IsA("BasePart") and SOLID[p.Name] then table.insert(walls, { cf = p.CFrame, half = p.Size / 2 }) end
	end
	local roof = map.Structure:FindFirstChild("Roof")
	if roof then
		for _, p in roof:GetDescendants() do
			if p:IsA("BasePart") and SOLID[p.Name] then table.insert(walls, { cf = p.CFrame, half = p.Size / 2 }) end
		end
	end
	local function inWall(q: Vector3): boolean
		for _, w in walls do
			local l = w.cf:PointToObjectSpace(q)
			if math.abs(l.X) <= w.half.X and math.abs(l.Y) <= w.half.Y and math.abs(l.Z) <= w.half.Z then return true end
		end
		return false
	end
	local moved, removed = 0, 0
	for _, p in map:GetDescendants() do
		if p:IsA("BasePart") and (p.Name == "Ivy" or p.Name == "RustStreak") and p:GetAttribute("Detail") ~= false then
			local n = p.CFrame.LookVector -- out of the wall
			local back = p.Position - n * (p.Size.Z / 2)
			-- how far behind the patch the wall starts (it may already be flush)
			local depth: number? = nil
			for t = 0, 3, 0.05 do
				if inWall(back - n * (t + 0.02)) then depth = t; break end
			end
			local ok = depth ~= nil
			if ok then
				-- the whole face must be on the wall: the four corners too (not over a door or a window)
				local hx, hy = p.Size.X / 2 * 0.9, p.Size.Y / 2 * 0.9
				for _, c in { { -hx, -hy }, { hx, -hy }, { -hx, hy }, { hx, hy } } do
					local corner = back + p.CFrame.RightVector * c[1] + p.CFrame.UpVector * c[2]
					if not inWall(corner - n * ((depth :: number) + 0.1)) then ok = false; break end
				end
			end
			if ok then
				if (depth :: number) > 0.02 then p.CFrame = p.CFrame - n * (depth :: number); moved += 1 end
			else
				p:Destroy(); removed += 1
			end
		end
	end
	return string.format("%s: %d pushed onto the wall, %d removed", map.Name, moved, removed)
end

local out = {}
local live = workspace:FindFirstChild("Mansion")
if live then table.insert(out, fix(live)) end
local maps = SS:FindFirstChild("Maps")
if maps then
	for _, m in maps:GetChildren() do
		if not (m.Name == "Mansion" and live and live:GetAttribute("MapId") == nil) then table.insert(out, fix(m)) end
	end
end
return table.concat(out, "\n")
