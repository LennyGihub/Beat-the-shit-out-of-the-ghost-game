-- THE GHOST SHIP, rebuilt bigger (2026-11): a galleon 156 studs long and 92 wide (the old one was 52 wide), THREE
-- DECKS inside the hull and cabins on top.
--   HOLD (y 2):      the brig aft (three cells), the big cargo hold amidships, the powder magazine forward.
--   GUN DECK (y 23): the mess and the surgeon's cabin aft, the gun gallery amidships (cannons at both sides), the
--                    crew's quarters forward.
--   MAIN DECK (y 44, open to the sky): the captain's cabin aft, the forecastle forward, two masts, the bow.
-- Four half-turn stairs (maplib's stair kit): hold <-> gun deck on the centre line (aft and forward), gun deck <->
-- main deck at both sides amidships. Outside, on the yard's side (+Z), a gangway runs down the hull from a gate in
-- the main deck's bulwark to a quay (y 2), past a door into the gun deck half way down.
-- The hull is blocky: straight sides and a stepped bow, every wall on the grid. Structure.Exterior = the hull (the
-- monster's bounds are measured from it); the sea, the old ship's cannons / chests / rope coils are copied from the
-- old model, kept in ServerStorage.MapBackups.Ship_v1.
-- Attributes: AtSea, MinY (below the hold = the sea), CeilingY, SpawnInside (on the main deck), Floors (the deck
-- levels, for MapLoader.randomGhostSpawn).
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/ship.luau
-- then furnish (ONLY = "Ship"), detail (TARGET = "Ship"), phones and doors_clear like every other map.
local C3 = Color3.fromRGB
local SSs = game:GetService("ServerStorage")
local bk = SSs:FindFirstChild("MapBackups") or Instance.new("Folder")
bk.Name = "MapBackups"; bk.Parent = SSs
if not bk:FindFirstChild("Ship_v1") and SSs.Maps:FindFirstChild("Ship") then
	local c = SSs.Maps.Ship:Clone(); c.Name = "Ship_v1"; c.Parent = bk
end
local OLD = bk:FindFirstChild("Ship_v1")

local PLANK = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(92, 74, 56))
local PLANK_D = st(M.WoodPlanks, "PS2_FloorPlanks2", C3(62, 50, 40))
local HULL = st(M.WoodPlanks, "PS2_Siding", C3(66, 52, 42))
local HULL_IN = st(M.WoodPlanks, "PS2_Siding", C3(98, 78, 60))
local BEAM = st(M.Wood, "PS2_DarkBeam1", C3(64, 46, 34))
local IRONS = st(M.Metal, nil, C3(40, 38, 36))
local SAIL = st(M.Fabric, nil, C3(150, 146, 132))
local GLOWC = C3(255, 190, 110)
local function D() return { deco = true } end

beginMap("Ship", {
	floor = PLANK, floor2 = PLANK, inner = HULL_IN, wain = false, ext = HULL, trim = BEAM, ceiling = PLANK_D, roof = PLANK_D,
	found = PLANK_D, door = BEAM, porch = PLANK, lanternColor = GLOWC,
})
local L1, L2, L3 = 2, 23, 44 -- the three decks
local AX1, AX2, HZ = -74, 62, 46 -- the hull's straight part: x AX1..AX2, z -HZ..HZ; then the stepped bow to x 78

-- THE HULL (Structure.Exterior) --------------------------------------------------------------------------------
local ext = model(STR, "Exterior")
-- gate = { x1, x2 }: a gap in the starboard side, open to the sky (an opening made by `wall` would get a lintel)
local function hull(y0, h, starboardOps, gate)
	wall(ext, "Port", "x", -HZ, AX1, AX2, y0, h, {}, EXT(1))
	if gate then
		wall(ext, "Starboard", "x", HZ, AX1, gate[1], y0, h, {}, EXT(-1))
		wall(ext, "Starboard", "x", HZ, gate[2], AX2, y0, h, {}, EXT(-1))
	else
		wall(ext, "Starboard", "x", HZ, AX1, AX2, y0, h, starboardOps or {}, EXT(-1))
	end
	wall(ext, "Stern", "z", AX1, -HZ, HZ, y0, h, {}, EXT(1))
	-- the bow, in two steps
	wall(ext, "BowShoulderP", "z", AX2, -HZ, -34, y0, h, {}, EXT(-1))
	wall(ext, "BowShoulderS", "z", AX2, 34, HZ, y0, h, {}, EXT(-1))
	wall(ext, "BowSideP", "x", -34, AX2, 70, y0, h, {}, EXT(1))
	wall(ext, "BowSideS", "x", 34, AX2, 70, y0, h, {}, EXT(-1))
	wall(ext, "BowCheekP", "z", 70, -34, -20, y0, h, {}, EXT(-1))
	wall(ext, "BowCheekS", "z", 70, 20, 34, y0, h, {}, EXT(-1))
	wall(ext, "BowNoseP", "x", -20, 70, 78, y0, h, {}, EXT(1))
	wall(ext, "BowNoseS", "x", 20, 70, 78, y0, h, {}, EXT(-1))
	wall(ext, "Stem", "z", 78, -20, 20, y0, h, {}, EXT(-1))
end
hull(-4, 27, {}) -- the keel and the hold
hull(L2, 21, { dr(3.5, 7, 11) }) -- the gun deck: a door onto the gangway's landing
hull(L3, 4, nil, { -40, -32 }) -- the main deck's bulwark, with the gangway's gate
box(STR, "HullBottom", AX1, -5, -HZ, 78, -4, HZ, PLANK_D)

-- THE STAIRS (before the decks: each one gives the hole to leave in the deck above) ---------------------------
local SK = { step = PLANK, trim = BEAM, wall = HULL_IN, kind = "balusters" }
local function well(x0, z0, y)
	local _, hole = dogleg(STR, {
		cf = CFrame.lookAt(Vector3.new(x0, y, z0), Vector3.new(x0 + 1, y, z0)), W = 15.5, L = 23.5, mir = 1, S = SK,
		low = { a = true, b = true, e = true }, up = { a = true, b = true, e = true },
	})
	keepClear(x0 - 9, z0 - 9, x0, z0 + 9, y) -- the foot...
	keepClear(x0 - 9, z0 - 9, x0, z0 + 9, y + 21) -- ...and the top stay open
	return hole
end
local h1 = well(-56, 0, L1) -- hold <-> gun deck, aft
local h2 = well(22, 0, L1) -- hold <-> gun deck, forward
local h3 = well(-18, -26, L2) -- gun deck <-> main deck, port
local h4 = well(-18, 26, L2) -- gun deck <-> main deck, starboard

-- THE DECKS (Structure.Floors): tiles, with the stairs' holes cut out ------------------------------------------
local floors = model(STR, "Floors")
local function minus(rects, h)
	local out = {}
	for _, r in rects do
		if h[3] <= r[1] or h[1] >= r[3] or h[4] <= r[2] or h[2] >= r[4] then
			table.insert(out, r)
		else
			if h[1] > r[1] then table.insert(out, { r[1], r[2], h[1], r[4] }) end
			if h[3] < r[3] then table.insert(out, { h[3], r[2], r[3], r[4] }) end
			local a, c = math.max(r[1], h[1]), math.min(r[3], h[3])
			if h[2] > r[2] then table.insert(out, { a, r[2], c, h[2] }) end
			if h[4] < r[4] then table.insert(out, { a, h[4], c, r[4] }) end
		end
	end
	return out
end
local function deck(name, y, holes, breakable)
	local rects = {}
	for i = 0, 7 do
		for j = 0, 5 do
			table.insert(rects, { AX1 + i * 17, -HZ + j * (2 * HZ / 6), AX1 + (i + 1) * 17, -HZ + (j + 1) * (2 * HZ / 6) })
		end
	end
	table.insert(rects, { AX2, -34, 70, 0 }); table.insert(rects, { AX2, 0, 70, 34 })
	table.insert(rects, { 70, -20, 78, 20 })
	for _, h in holes do rects = minus(rects, h) end
	for _, r in rects do
		if r[3] - r[1] > 0.05 and r[4] - r[2] > 0.05 then
			local p = box(floors, name, r[1], y - 1, r[2], r[3], y, r[4], PLANK)
			if breakable then p:SetAttribute("Breakable", true) end
		end
	end
end
deck("HoldFloor", L1, {}, false)
deck("GunDeck", L2, { h1, h2 }, true)
deck("MainDeck", L3, { h3, h4 }, true)

-- BULKHEADS AND CABINS (Structure.Interior: these break) --------------------------------------------------------
local inn = model(STR, "Interior")
local I = INT()
-- the hold
wall(inn, "HoldAft", "z", -26, -45, 45, L1, 20, { dr(-28, 8, 12), dr(28, 8, 12) }, I)
wall(inn, "HoldFore", "z", 14, -45, 45, L1, 20, { dr(-28, 8, 12), dr(28, 8, 12) }, I)
wall(inn, "Brig", "x", -20, -73, -27, L1, 20, { dr(-65, 7, 11), dr(-51, 7, 11), dr(-37, 7, 11) }, I)
wall(inn, "CellA", "z", -58, -45, -21, L1, 20, {}, I)
wall(inn, "CellB", "z", -44, -45, -21, L1, 20, {}, I)
wall(inn, "Magazine", "x", 20, 15, 61, L1, 20, { dr(28, 6, 11), dr(50, 6, 11) }, I)
-- the gun deck
wall(inn, "GunAft", "z", -26, -45, 45, L2, 20, { dr(-40, 6, 12), dr(40, 6, 12), dr(-22, 7, 12), dr(22, 7, 12) }, I) -- (no door on the centre line: the mast)
wall(inn, "GunFore", "z", 14, -45, 45, L2, 20, { dr(-38, 7, 12), dr(38, 7, 12), dr(-12, 6, 12), dr(12, 6, 12) }, I)
wall(inn, "Mess", "x", -14, -73, -27, L2, 20, { dr(-66, 6, 11), dr(-34, 6, 11) }, I)
wall(inn, "Surgeon", "x", 14, -73, -27, L2, 20, { dr(-66, 6, 11), dr(-34, 6, 11) }, I)
wall(inn, "QuartersP", "x", -16, 15, 61, L2, 20, { dr(19, 6, 11), dr(52, 6, 11) }, I)
wall(inn, "QuartersS", "x", 16, 15, 61, L2, 20, { dr(19, 6, 11), dr(52, 6, 11) }, I)
-- the main deck: the captain's cabin aft, the forecastle forward (12 high, a roof on each)
wall(inn, "CabinFront", "z", -44, -38, 38, L3, 12, { dr(-20, 7, 10), dr(20, 7, 10) }, I)
wall(inn, "CabinBack", "z", -72, -38, 38, L3, 12, {}, I)
wall(inn, "CabinPort", "x", -38, -72, -44, L3, 12, {}, I)
wall(inn, "CabinStarboard", "x", 38, -72, -44, L3, 12, {}, I)
wall(inn, "ForecastleBack", "z", 40, -32, 32, L3, 12, { dr(-16, 7, 10), dr(16, 7, 10) }, I)
wall(inn, "ForecastleFront", "z", 61, -32, 32, L3, 12, {}, I)
wall(inn, "ForecastlePort", "x", -32, 40, 61, L3, 12, {}, I)
wall(inn, "ForecastleStarboard", "x", 32, 40, 61, L3, 12, {}, I)
box(floors, "PoopDeck", -73, L3 + 12, -39, -43, L3 + 13, 39, PLANK_D)
box(floors, "ForecastleRoof", 39, L3 + 12, -33, 62, L3 + 13, 33, PLANK_D)
-- the corridors and the gangways between the doors stay clear of furniture
keepClear(-26, -4, 14, 4, L1); keepClear(-26, -4, 14, 4, L2)
keepClear(-42, 38, 40, 45, L3) -- along the starboard rail, to the gate

-- MASTS: through every deck, from the hold to the sky (the yards and sails are only to look at) ---------------
local masts = model(STR, "Masts")
local rig = model(DEC, "Rigging")
-- (the forward one stands clear of the forward stair: right in front of it, the monsters' pathfinding could not
-- get round it)
for i, x in { -30, 10 } do
	local top = i == 1 and 104 or 112
	cyl(masts, CFrame.new(), "Mast", 3.6, top - L1, x, (top + L1) / 2, 0, BEAM)
	for j, y in { 62, 84 } do
		local half = j == 1 and 34 or 26
		box(rig, "Yard", x - 0.7, y, -half, x + 0.7, y + 1.4, half, BEAM, D())
		box(rig, "Sail", x + 0.8, y - 17, -half + 2, x + 1.2, y, half - 2, SAIL, D())
	end
	box(rig, "CrowsNest", x - 3, top - 12, -3, x + 3, top - 11, 3, PLANK_D, D())
end
box(rig, "Bowsprit", 74, L3 + 3, -0.9, 100, L3 + 4.6, 0.9, BEAM, D())

-- THE GANGWAY (Structure.Porch): outside the starboard side, from the gate down to the quay -------------------
local porch = model(STR, "Porch")
local GZ1, GZ2 = HZ + 1, HZ + 9
box(porch, "GangwayTop", -40, L3 - 1, HZ, -32, L3, GZ2, PLANK)
for i = 1, 21 do -- gate -> the landing by the gun deck's door
	local x = -32 + (i - 1) * 1.5
	box(porch, "Step", x, L3 - i - 3, GZ1, x + 1.5, L3 - i, GZ2, PLANK)
	box(porch, "RailPanel", x, L3 - i, GZ2 - 0.4, x + 1.5, L3 - i + 3.6, GZ2, BEAM)
end
box(porch, "Landing", -0.5, L2 - 1, HZ, 7.5, L2, GZ2, PLANK)
box(porch, "RailPanel", -0.5, L2, GZ2 - 0.4, 7.5, L2 + 3.6, GZ2, BEAM)
for i = 1, 21 do -- the landing -> the quay
	local x = 7.5 + (i - 1) * 1.5
	box(porch, "Step", x, math.max(L1 - 1, L2 - i - 3), GZ1, x + 1.5, L2 - i, GZ2, PLANK)
	box(porch, "RailPanel", x, L2 - i, GZ2 - 0.4, x + 1.5, L2 - i + 3.6, GZ2, BEAM)
end
box(porch, "RailPanel", -40, L3, GZ2 - 0.4, -32, L3 + 3.6, GZ2, BEAM)
box(porch, "RailPanel", -40.4, L3, HZ + 1, -40, L3 + 3.6, GZ2, BEAM)
box(porch, "Pier", -46, L1 - 1, GZ1, 46, L1, 62, PLANK)
box(porch, "PierStep", -46, L1 - 2, 62, 46, L1 - 1, 64.5, PLANK_D)
for _, x in { -40, -32, -0.5, 7.5 } do
	for _, z in { GZ1 + 0.6, GZ2 - 0.6 } do box(porch, "GangwayPost", x - 0.5, L1, z - 0.5, x + 0.5, (x < -20) and (L3 - 1) or (L2 - 1), z + 0.5, BEAM) end
end
for _, x in { -44, -22, 0, 22, 44 } do box(DEC, "PierPost", x - 0.6, -2, 61, x + 0.6, L1 + 3, 62.2, BEAM, D()) end

-- THE SEA, as it was --------------------------------------------------------------------------------------------
if OLD then
	for _, d in OLD.Decor:GetChildren() do
		if d:IsA("BasePart") and (d.Name == "Sea" or d.Name == "SeaDeep") then d:Clone().Parent = DEC end
	end
end

-- LANTERNS ------------------------------------------------------------------------------------------------------
for _, y in { L1, L2 } do
	for _, x in { -64, -40, -6, 28, 50 } do
		for _, z in { -30, 0, 30 } do
			-- (not over a stair: the wells on the centre line, and under the main deck the two at the sides)
			if not (z == 0 and (x == -40 or x == 28)) and not (y == L2 and x == -6 and z ~= 0) then bulb(x, y + 19.5, z, 3, GLOWC) end
		end
	end
	bulb(70, y + 19.5, 0, 3, GLOWC)
end
for _, p in { { -58, -20 }, { -58, 20 }, { 50, -16 }, { 50, 16 } } do bulb(p[1], L3 + 11.5, p[2], 2.5, GLOWC) end -- in the cabins
for _, x in { -30, 0, 30, 68 } do -- on posts along both rails of the open deck
	for _, s in { -1, 1 } do
		if not (s == 1 and x == -30) then -- (the gate)
			box(DEC, "LampPost", x - 0.3, L3, s * (HZ - 2.2) - 0.3, x + 0.3, L3 + 7, s * (HZ - 2.2) + 0.3, BEAM, D())
			bulb(x, L3 + 9.6, s * (HZ - 2.2), 2.2, GLOWC)
		end
	end
end
bulb(-36, L3 - 4, HZ + 5, 0.1, GLOWC); bulb(3.5, L2 + 12, HZ + 5, 0.1, GLOWC); bulb(30, L1 + 12, HZ + 8, 0.1, GLOWC) -- the gangway

-- CANNONS, CHESTS, ROPE COILS (copies of the old ship's) and a first load of furniture -------------------------
local proto = {}
if OLD then
	for _, m in OLD.Furniture:GetChildren() do if not proto[m.Name] then proto[m.Name] = m end end
end
-- a copy of an old piece, standing on the floor at cf (its tags and attributes come with the copy)
local function put(kind, cf)
	local src = proto[kind]
	if not src then return end
	local c = src:Clone()
	local bcf, size = c:GetBoundingBox()
	c:PivotTo(cf * CFrame.new(0, size.Y / 2, 0) * bcf:ToObjectSpace(c:GetPivot()))
	c.Parent = FURN
end
-- the gun gallery: a row of cannons at each side, their muzzles to the hull
for _, x in { -20, -10, 8 } do
	put("Cannon", CFrame.new(x == -10 and -22 or x, L2, -40) * CFrame.Angles(0, math.pi, 0))
	put("Cannon", CFrame.new(x == -10 and -22 or x, L2, 40))
end
for _, s in { -1, 1 } do put("Cannon", CFrame.new(10, L2, s * 41) * CFrame.Angles(0, s < 0 and math.pi or 0, 0)) end
-- on the open deck
for _, x in { -8, 26 } do
	put("Cannon", CFrame.new(x, L3, -41) * CFrame.Angles(0, math.pi, 0))
	put("Cannon", CFrame.new(x + 4, L3, 41))
end
put("Chest", CFrame.new(-66, L3, -30)); put("Chest", CFrame.new(-66, L3, 30)); put("Chest", CFrame.new(-8, L1, 36)); put("Chest", CFrame.new(40, L1, 32))
put("Rope", CFrame.new(34, L3, -40)); put("Rope", CFrame.new(-4, L3, 12)); put("Rope", CFrame.new(-20, L1, -38)); put("Rope", CFrame.new(66, L3, 12))
-- the cargo hold: stacks of crates and barrels
for _, p in { { -18, -34 }, { -12, -36 }, { -18, 30 }, { 6, -32 }, { 4, 34 }, { -6, 22 } } do F.crate(at(p[1], L1, p[2], "N"), 3.6) end
for _, p in { { -12, 36 }, { 8, 26 }, { -2, -24 }, { 0, -38 }, { -22, 12 } } do F.barrel(at(p[1], L1, p[2], "N")) end
-- the magazine and the brig
for _, p in { { 24, 30 }, { 30, 38 }, { 44, 36 }, { 56, 28 } } do F.barrel(at(p[1], L1, p[2], "N")) end
for _, x in { -68, -54, -40 } do F.bench(at(x + 3, L1, -40, "N"), 5, st(M.Wood, "PS2_DarkBeam1", C3(70, 52, 40))) end
-- the mess: a long table and benches; the crew's bunks forward
F.table(at(-50, L2, -30, "N"), 12, 5, 3.4, st(M.Wood, "PS2_DarkBeam1", C3(80, 58, 42)), "Table")
F.bench(at(-50, L2, -25, "N"), 10, st(M.Wood, "PS2_DarkBeam1", C3(70, 52, 40)))
F.bench(at(-50, L2, -35, "N"), 10, st(M.Wood, "PS2_DarkBeam1", C3(70, 52, 40)))
for _, x in { 26, 36, 46 } do
	G2.bunk(at(x, L2, -38, "N")); G2.bunk(at(x, L2, 38, "S"))
end
-- the captain's cabin
F.table(at(-58, L3, 0, "E"), 10, 5, 3.4, st(M.Wood, "PS2_DarkBeam1", C3(80, 58, 42)), "Table")
F.chair(at(-64, L3, 0, "E"), st(M.Wood, "PS2_DarkBeam1", C3(80, 58, 42)))
F.barrel(at(46, L3, -24, "N")); F.crate(at(52, L3, 22, "N"), 3.4)

-- WHERE THE MONSTERS COME IN ------------------------------------------------------------------------------------
gspawn(-50, L1, 30); gspawn(-6, L1, -8); gspawn(40, L1, -30)
gspawn(-50, L2, 30); gspawn(-4, L2, 0); gspawn(44, L2, -30)
gspawn(-58, L3, 20); gspawn(50, L3, -16)

MAP:SetAttribute("AtSea", true)
MAP:SetAttribute("MinY", 0)
MAP:SetAttribute("CeilingY", 62)
MAP:SetAttribute("SpawnInside", Vector3.new(-8, L3 + 3, 0))
MAP:SetAttribute("Floors", "2,23,44")
return endMap()
