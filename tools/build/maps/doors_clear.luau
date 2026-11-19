-- Keeps every doorway clear (standalone, Edit mode, safe to re-run; run it LAST, after furnish / detail):
--   python3 tools/studio.py luau Edit tools/build/maps/doors_clear.luau
-- The furnish and detail passes drop props on random free floor spots, and some land in a doorway. A crate in a
-- door stops the monster: its pathfinding (agent radius 2.2) needs about 6 clear studs. Doorways are read from the
-- wall models (a top "Frame" without a window "Sill" under it); furniture standing IN the opening (its middle
-- between the jambs, within 3.2 studs of the wall) is removed, an explosive barrel is moved beside the door instead
-- (every map keeps its five). A piece beside a door (a clock, a side table against the wall) is left alone.
-- The Mansion is not touched: its furniture is placed by hand (furn_place.luau).
local SS = game:GetService("ServerStorage")

local function clear(map: Instance): string
	local S = map:FindFirstChild("Structure")
	local FURN = map:FindFirstChild("Furniture")
	if not S or not FURN then return map.Name .. ": no Structure / Furniture" end
	local zones = {}
	for _, w in S:GetDescendants() do
		if w:IsA("Model") then
			local sills = {}
			for _, c in w:GetChildren() do if c:IsA("BasePart") and (c.Name == "Sill" or c.Name == "Glass") then table.insert(sills, c.Position) end end
			for _, f in w:GetChildren() do
				if f:IsA("BasePart") and f.Name == "Frame" and f.Size.Y < 0.75 then
					local alongX = f.Size.X > f.Size.Z
					local half = (alongX and f.Size.X or f.Size.Z) / 2 - 0.6
					local window = false
					for _, sp in sills do
						if math.abs(sp.X - f.Position.X) < 1 and math.abs(sp.Z - f.Position.Z) < 1 then window = true; break end
					end
					if not window and half >= 2 then
						table.insert(zones, { x = f.Position.X, z = f.Position.Z, alongX = alongX, half = half, floor = f.Position.Y < 22.5 and 2 or 23 })
					end
				end
			end
		end
	end
	local removed, moved = 0, 0
	for _, m in FURN:GetChildren() do
		if m:IsA("Model") then
			local pv = m:GetPivot()
			local p = pv.Position
			for _, zn in zones do
				local da = zn.alongX and (p.X - zn.x) or (p.Z - zn.z) -- along the wall
				local dp = zn.alongX and (p.Z - zn.z) or (p.X - zn.x) -- through the door
				if math.abs(da) < zn.half - 0.2 and math.abs(dp) < 3.2 and p.Y > zn.floor - 1.5 and p.Y < zn.floor + 7 then
					if m.Name == "ExplosiveBarrel" then
						local sa, sp = da >= 0 and 1 or -1, dp >= 0 and 1 or -1
						local na, np = zn.half + 3.2, 3.2
						local np3 = zn.alongX and Vector3.new(zn.x + sa * na, p.Y, zn.z + sp * np) or Vector3.new(zn.x + sp * np, p.Y, zn.z + sa * na)
						m:PivotTo(pv.Rotation + np3)
						moved += 1
					else
						m:Destroy()
						removed += 1
					end
					break
				end
			end
		end
	end
	return string.format("%s: %d doorways, %d pieces removed, %d barrels moved aside", map.Name, #zones, removed, moved)
end

local out = {}
local maps = SS:FindFirstChild("Maps")
if maps then
	for _, m in maps:GetChildren() do
		-- (a line `ONLYP = "Camp_"` before the script: only the maps whose id starts with it)
		if m.Name ~= "Mansion" and (not ONLYP or string.sub(m.Name, 1, #ONLYP) == ONLYP) then table.insert(out, clear(m)) end
	end
end
return table.concat(out, "\n")
