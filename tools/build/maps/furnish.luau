-- Extra furniture + detail for the built maps (not the Mansion, not the Factory which has its own full layout).
-- Run after lib2 + furn_lib + maplib:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/furnish.luau
-- For each map: a working copy goes into workspace, random floor spots (ground and upper floor) that are inside
-- (a ceiling above) and clear of walls, doors and other furniture get a piece from that map's list, plus some blood;
-- then the copy replaces ServerStorage.Maps.<id>. Re-running adds more on top (rebuild a map first to start over).
local SSf = game:GetService("ServerStorage")
local C3 = Color3.fromRGB
local PER_MAP = 22
local rngF = Random.new(4242)
local FACES = { "N", "S", "E", "W" }

local THEMES = {
	Hospital = { function(c) G2.gurney(c) end, function(c) G2.wheelchair(c) end, function(c) G2.hospitalBed(c) end,
		function(c) F.cabinet(c, 6, 9) end, function(c) F.chair(c, Wd.mid, Fab.green) end, function(c) G2.steelTable(c) end,
		function(c) F.sideTable(c, true) end, function(c) G2.vending(c, C3(40, 120, 90)) end },
	School = { function(c) G2.schoolDesk(c) end, function(c) G2.schoolDesk(c) end, function(c) G2.locker(c, C3(70, 90, 150)) end,
		function(c) F.bookshelf(c, 8, 10) end, function(c) F.chair(c, Wd.mid, Fab.blue) end, function(c) F.globe(c) end,
		function(c) F.table(c, 8, 4, 3.4, Wd.mid, "Table") end, function(c) F.cabinet(c, 6, 9) end },
	Church = { function(c) G2.pew(c, 8) end, function(c) G2.pew(c, 8) end, function(c) F.bench(c, 7) end, function(c) F.pedestal(c) end,
		function(c) F.armchair(c, Fab.red, 4) end, function(c) F.bookshelf(c, 6, 10) end, function(c) F.cabinet(c, 6, 9) end },
	Motel = { function(c) F.bed(c, 6, 8) end, function(c) F.nightstand(c) end, function(c) F.tv(c) end, function(c) F.armchair(c, Fab.brown, 4) end,
		function(c) F.dresser(c, 6) end, function(c) F.chair(c, Wd.mid, Fab.red) end, function(c) F.sideTable(c, true) end,
		function(c) G2.vending(c, C3(170, 40, 60)) end },
	Ship = { function(c) F.barrel(c) end, function(c) F.crate(c, 3.5) end, function(c) F.crate(c, 3) end, function(c) F.table(c, 7, 4, 3.4, Wd.dark, "Table") end,
		function(c) F.chair(c, Wd.dark, Fab.brown) end, function(c) F.bench(c, 6) end, function(c) G2.bunk(c) end, function(c) F.toyChest(c) end },
	Farm = { function(c) G2.hay(c) end, function(c) G2.hay(c) end, function(c) F.crate(c, 3.5) end, function(c) F.barrel(c) end,
		function(c) G2.workbench(c, 7) end, function(c) F.rockingChair(c) end, function(c) F.table(c, 7, 4, 3.4, Wd.mid, "Table") end,
		function(c) F.chair(c, Wd.mid, Fab.brown) end, function(c) F.dresser(c, 6) end },
	Asylum = { function(c) G2.hospitalBed(c, true) end, function(c) G2.wheelchair(c) end, function(c) G2.steelTable(c) end,
		function(c) F.cabinet(c, 6, 9) end, function(c) F.chair(c, Wd.mid, Fab.grey) end, function(c) G2.gurney(c) end, function(c) G2.bunk(c) end },
	Hotel = { function(c) G2.luggageCart(c) end, function(c) F.sofa(c, Fab.red, 7) end, function(c) F.armchair(c, Fab.red, 4) end,
		function(c) F.sideTable(c, true) end, function(c) F.floorLamp(c) end, function(c) F.coffeeTable(c) end,
		function(c) F.bed(c, 6, 8) end, function(c) F.dresser(c, 6) end, function(c) F.clock(c) end },
	Prison = { function(c) G2.bunk(c) end, function(c) G2.bunk(c) end, function(c) G2.steelTable(c) end, function(c) G2.locker(c, C3(90, 96, 100)) end,
		function(c) F.bench(c, 7) end, function(c) F.toilet(c) end, function(c) F.chair(c, Wd.mid, Fab.grey) end, function(c) F.crate(c, 3) end },
	Funeral = { function(c) G2.coffin(c, rngF:NextNumber() < 0.4) end, function(c) G2.pew(c, 8) end, function(c) F.pedestal(c) end,
		function(c) F.armchair(c, Fab.brown, 4) end, function(c) F.sofa(c, Fab.brown, 7) end, function(c) F.cabinet(c, 6, 9) end,
		function(c) F.floorLamp(c) end },
}
local CANDLES = { Church = true, Funeral = true }

local out = {}
local temp = Instance.new("Folder"); temp.Name = "_Furnish"; temp.Parent = workspace
for id, list in THEMES do
	local src = SSf.Maps:FindFirstChild(id)
	if not src then table.insert(out, id .. ": missing"); continue end
	local copy = src:Clone()
	copy.Parent = temp
	MAP = copy
	STR = copy:FindFirstChild("Structure"); DEC = copy:FindFirstChild("Decor"); FURN = copy:FindFirstChild("Furniture")
	local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Include; rp.FilterDescendantsInstances = { STR }
	local op = OverlapParams.new(); op.FilterType = Enum.RaycastFilterType.Include; op.FilterDescendantsInstances = { STR, FURN, DEC }
	local placed, tries = 0, 0
	while placed < PER_MAP and tries < 900 do
		tries += 1
		local x, z = rngF:NextNumber(-74, 74), rngF:NextNumber(-54, 54)
		local down = workspace:Raycast(Vector3.new(x, rngF:NextNumber() < 0.55 and 18 or 40, z), Vector3.new(0, -30, 0), rp)
		if down and down.Normal.Y > 0.9 and down.Position.Y < 30 then
			local fy = down.Position.Y
			local roof = workspace:Raycast(Vector3.new(x, fy + 3, z), Vector3.new(0, 30, 0), rp)
			if roof then
				-- room around it: nothing standing in a 9 x 9 footprint (walls, doors, furniture)
				local clear = true
				for _, h in workspace:GetPartBoundsInBox(CFrame.new(x, fy + 3.2, z), Vector3.new(9, 5.6, 9), op) do
					if h.Transparency < 1 and h.Position.Y + h.Size.Y / 2 > fy + 0.35 then clear = false; break end
				end
				if clear then
					local make = list[rngF:NextInteger(1, #list)]
					local ok = pcall(make, at(x, fy, z, FACES[rngF:NextInteger(1, 4)]))
					if ok then placed += 1 end
				end
			end
		end
	end
	-- detail: blood here and there, candles in the church and the funeral home
	for i = 1, 5 do
		local x, z = rngF:NextNumber(-70, 70), rngF:NextNumber(-50, 50)
		local down = workspace:Raycast(Vector3.new(x, 18, z), Vector3.new(0, -30, 0), rp)
		if down then blood(x, down.Position.Y, z, rngF:NextNumber(1.5, 3)) end
	end
	if CANDLES[id] then
		for i = 1, 8 do
			local x, z = rngF:NextNumber(-70, 70), rngF:NextNumber(-50, 50)
			local down = workspace:Raycast(Vector3.new(x, 18, z), Vector3.new(0, -30, 0), rp)
			if down then pcall(candles, x, down.Position.Y, z) end
		end
	end
	local n = 0
	for _ in FURN:GetChildren() do n += 1 end
	src:Destroy()
	copy.Parent = SSf.Maps
	table.insert(out, string.format("%s: +%d pieces (%d tries), %d furniture now", id, placed, tries, n))
end
temp:Destroy()
return table.concat(out, "\n")
