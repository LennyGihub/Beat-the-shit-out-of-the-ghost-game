-- The Old Sewer: the city waterworks. You come in through the pump house; behind it a brick canal hall runs the
-- whole width of the building (a strip of green water down its middle, a walkway each side), with five rooms on the
-- pump-house side (filter room, workshop, the entry hall, control room, store) and three overflow chambers behind
-- (the pipe gallery, the cistern, the rat's nest). One storey, flat roof, no stairs. Rusty pipes everywhere.
-- Build: cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/sewer.luau
-- then furnish (ONLY = "Sewer"), detail (TARGET = "Sewer"), phones and doors_clear like every other map.
local C3 = Color3.fromRGB
local BRICK = st(M.Brick, nil, C3(104, 84, 72))
local BRICK_D = st(M.Brick, nil, C3(74, 62, 56))
local CONC = st(M.Concrete, nil, C3(104, 106, 102))
local CONC_D = st(M.Concrete, nil, C3(62, 66, 62))
local RUST = st(M.CorrodedMetal, nil, C3(126, 84, 56))
local RUST_D = st(M.CorrodedMetal, nil, C3(86, 60, 44))
local IRON = st(M.Metal, nil, C3(44, 44, 46))
local SLIME = st(M.SmoothPlastic, nil, C3(70, 110, 56))
local GLOW = C3(190, 230, 150)
local function D() return { deco = true } end -- (a fresh table each time: cyl / ball write the shape into it)

beginMap("Sewer", {
	floor = CONC, floor2 = CONC, inner = BRICK, wain = false, ext = st(M.Brick, nil, C3(120, 92, 78)), trim = st(M.Concrete, nil, C3(84, 84, 82)),
	ceiling = BRICK_D, roof = st(M.Concrete, nil, C3(70, 70, 72)), found = CONC_D, door = RUST, porch = CONC,
	lanternColor = GLOW, floodColor = C3(190, 220, 190),
})
shell({ two = false, H = 20, roof = "flat", front1 = { -52, 52 }, back1 = {}, left1 = {}, right1 = {}, winW = 5, winB = 9, winT = 15 })
local inn = model(STR, "Interior")
local I = INT()

-- THE CANAL HALL: z -12..12, the whole width
wall(inn, "CanalN", "x", 12.6, -78, 78, F1, 20, { dr(-60, 8, 12), dr(-26.5, 8, 12), dr(0, 14, 15), dr(26.5, 8, 12), dr(60, 8, 12) }, I)
wall(inn, "CanalS", "x", -12.6, -78, 78, F1, 20, { dr(-55, 9, 13), dr(-14, 8, 12), dr(14, 8, 12), dr(55, 9, 13) }, I)
-- the pump-house side: five rooms (z 12..58)
wall(inn, "RoomA", "z", -40, 13.2, 58, F1, 20, { dr(36, 7, 11) }, I)
wall(inn, "RoomB", "z", -13, 13.2, 58, F1, 20, { dr(40, 7, 11) }, I)
wall(inn, "RoomC", "z", 13, 13.2, 58, F1, 20, { dr(40, 7, 11) }, I)
wall(inn, "RoomD", "z", 40, 13.2, 58, F1, 20, { dr(36, 7, 11) }, I)
-- the overflow chambers behind (z -58..-12)
wall(inn, "ChamberW", "z", -30, -58, -13.2, F1, 20, { dr(-36, 9, 13) }, I)
wall(inn, "ChamberE", "z", 30, -58, -13.2, F1, 20, { dr(-36, 9, 13) }, I)

-- the water: a dark channel down the middle of the hall, a film of green water on it (you wade through)
local wet = model(DEC, "Canal")
box(wet, "Channel", -77, F1 + 0.05, -6.5, 77, F1 + 0.1, 6.5, CONC_D, D())
box(wet, "Water", -77, F1 + 0.1, -6, 77, F1 + 0.3, 6, st(M.Glass, nil, C3(52, 92, 60)), { deco = true, t = 0.35 })
for _, z in { -6.6, 6.6 } do box(wet, "Curb", -77, F1 + 0.05, z - 0.5, 77, F1 + 0.32, z + 0.5, st(M.Concrete, nil, C3(130, 130, 124)), D()) end
for _, x in { -64, -38, -12, 14, 40, 66 } do
	box(wet, "Slime", x - 2.5, F1 + 0.31, -2 + (x % 5), x + 2.5, F1 + 0.34, 1 + (x % 5), SLIME, { deco = true, t = 0.25 })
end
-- plank bridges across it (flat: only to look at) and iron grates in the walkways
for _, x in { -44, 0, 44 } do
	for i = -1, 1 do box(wet, "Plank", x + i * 1.7 - 0.75, F1 + 0.32, -7.4, x + i * 1.7 + 0.75, F1 + 0.44, 7.4, st(M.WoodPlanks, "PS2_FloorPlanks2", C3(84, 66, 48)), D()) end
end
for _, p in { { -62, 9.5 }, { -20, -9.5 }, { 22, 9.5 }, { 64, -9.5 }, { 0, 34 }, { -55, -36 }, { 55, -36 } } do
	local gm = model(DEC, "Grate")
	box(gm, "GratePit", p[1] - 2.2, F1 + 0.05, p[2] - 2.2, p[1] + 2.2, F1 + 0.09, p[2] + 2.2, st(M.SmoothPlastic, nil, C3(6, 8, 6)), D())
	for i = -3, 3 do box(gm, "GrateBar", p[1] + i * 0.6 - 0.12, F1 + 0.09, p[2] - 2.2, p[1] + i * 0.6 + 0.12, F1 + 0.2, p[2] + 2.2, IRON, D()) end
end

-- PIPES. Two mains under the hall's ceiling, drops to the floor, outfalls pouring into the canal, valve wheels.
local pipes = model(DEC, "Pipes")
local ALONG_X, ALONG_Z = CFrame.Angles(0, 0, math.pi / 2), CFrame.Angles(math.pi / 2, 0, 0)
for _, z in { -10.2, 10.2 } do
	cyl(pipes, CFrame.new(0, 18.6, z) * ALONG_X, "Main", 2.4, 154, 0, 0, 0, RUST, D())
	for x = -70, 70, 28 do
		cyl(pipes, CFrame.new(x, 18.6, z) * ALONG_X, "Collar", 3, 1, 0, 0, 0, RUST_D, D())
		box(pipes, "Hanger", x - 0.2, 19.8, z - 0.2, x + 0.2, 21.5, z + 0.2, IRON, D())
	end
end
for _, p in { { -72, 10.2 }, { -18, -10.2 }, { 34, 10.2 }, { 72, -10.2 } } do
	cyl(pipes, CFrame.new(p[1], F1 + 8.2, p[2]), "Drop", 1.6, 16.6, 0, 0, 0, RUST, D())
	local wheel = cyl(pipes, CFrame.new(p[1], F1 + 5, p[2] + (p[2] > 0 and -1.1 or 1.1)) * ALONG_Z, "Valve", 2.2, 0.3, 0, 0, 0, st(M.Metal, nil, C3(150, 34, 28)), D())
	wheel.Name = "ValveWheel"
end
-- outfalls: big pipe mouths in the hall's walls, a thread of green water falling from each
for _, o in { { -39, -11.9, 1 }, { 39, -11.9, 1 }, { -44, 11.9, -1 }, { 44, 11.9, -1 } } do
	local x, z, s = o[1], o[2], o[3]
	cyl(pipes, CFrame.new(x, F1 + 6, z + s * 1.2) * ALONG_Z, "Outfall", 6, 3.4, 0, 0, 0, RUST_D, D())
	cyl(pipes, CFrame.new(x, F1 + 6, z + s * 2.95) * ALONG_Z, "OutfallDark", 4.8, 0.1, 0, 0, 0, st(M.SmoothPlastic, nil, C3(4, 6, 4)), D())
	box(pipes, "Stream", x - 0.9, F1 + 0.3, z + s * 3, x + 0.9, F1 + 4.2, z + s * 3.5, st(M.Glass, nil, C3(70, 130, 80)), { deco = true, t = 0.45 })
	box(pipes, "SlimeStain", x - 2, F1 + 1, z + s * 0.75, x + 2, F1 + 4, z + s * 0.8, SLIME, { deco = true, t = 0.3 })
end
-- the pipe gallery (west chamber): fat pipes crossing the room at three heights, you walk between and under them
for i, zc in { -24, -36, -48 } do
	cyl(pipes, CFrame.new(-54, F1 + 11 + (i % 2) * 4, zc) * ALONG_X, "GalleryPipe", 3.2, 46, 0, 0, 0, i % 2 == 0 and RUST or RUST_D, D())
end
for _, xc in { -66, -42 } do
	cyl(pipes, CFrame.new(xc, F1 + 17, -35) * ALONG_Z, "GalleryPipe", 2.2, 44, 0, 0, 0, RUST, D())
	cyl(pipes, CFrame.new(xc, F1 + 8.5, -56.6), "GalleryDrop", 2.2, 17, 0, 0, 0, RUST_D, D())
end
-- the cistern (middle chamber): a round basin of still water under a ring of pipes
local cis = model(DEC, "Cistern")
cyl(cis, CFrame.new(0, F1 + 0.12, -36), "BasinFloor", 22, 0.1, 0, 0, 0, CONC_D, D())
cyl(cis, CFrame.new(0, F1 + 0.26, -36), "BasinWater", 20, 0.16, 0, 0, 0, st(M.Glass, nil, C3(40, 80, 56)), { deco = true, t = 0.3 })
for i = 0, 11 do
	local a = i / 12 * math.pi * 2
	part(cis, "BasinStone", Vector3.new(5.9, 0.5, 1.2), CFrame.new(math.cos(a) * 11, F1 + 0.3, -36 + math.sin(a) * 11) * CFrame.Angles(0, -a + math.pi / 2, 0), st(M.Concrete, nil, C3(130, 130, 124)), D())
end
cyl(cis, CFrame.new(0, F1 + 19, -36), "Shaft", 9, 2, 0, 0, 0, BRICK_D, D())
local moon = cyl(cis, CFrame.new(0, F1 + 18.1, -36), "ShaftLight", 6, 0.2, 0, 0, 0, st(M.Neon, nil, C3(170, 210, 190)), { deco = true, t = 0.3 })
light(moon, 40, 1.2, C3(170, 215, 195))
-- the rat's nest (east chamber): heaps of rubbish and bones, a gnawed hole in the back wall
local nest = model(DEC, "Nest")
for _, h in { { 60, -50, 9 }, { 44, -44, 6 }, { 70, -30, 5 } } do
	cyl(nest, CFrame.new(h[1], F1 + 0.5, h[2]), "Heap", h[3] * 2, 1, 0, 0, 0, st(M.Mud, "PS2_Mud", C3(58, 50, 40)), D())
	cyl(nest, CFrame.new(h[1] + 0.6, F1 + 1.3, h[2] - 0.4), "Heap", h[3] * 1.2, 0.9, 0, 0, 0, st(M.Mud, "PS2_Mud", C3(66, 56, 44)), D())
	for i = 1, 5 do
		part(nest, "Bone", Vector3.new(0.3, 0.3, 1.6 + i * 0.2), CFrame.new(h[1] + math.cos(i * 1.3) * h[3] * 0.6, F1 + 1.2, h[2] + math.sin(i * 1.3) * h[3] * 0.6) * CFrame.Angles(0.2 * i, i, 0.1), st(M.SmoothPlastic, nil, C3(214, 204, 180)), D())
	end
end
cyl(nest, CFrame.new(64, F1 + 5.5, -57.3) * ALONG_Z, "RatHole", 10, 0.3, 0, 0, 0, st(M.SmoothPlastic, nil, C3(4, 4, 4)), D())
for i = 0, 7 do
	local a = i / 8 * math.pi * 2
	part(nest, "BrokenBrick", Vector3.new(1.8, 1.2, 0.8), CFrame.new(64 + math.cos(a) * 5.4, F1 + 5.5 + math.sin(a) * 5.4, -57.1) * CFrame.Angles(0, 0, a), BRICK_D, D())
end

-- LIGHTS: caged bulbs down the hall and one in every room (a sick yellow-green)
for _, x in { -65, -39, -13, 13, 39, 65 } do bulb(x, 21, 0, 3, GLOW) end
for _, p in { { -59, 36 }, { -26.5, 36 }, { 0, 34 }, { 26.5, 36 }, { 59, 36 }, { -55, -30 }, { -55, -48 }, { 55, -36 }, { 0, -20 } } do bulb(p[1], 21, p[2], 3, GLOW) end

-- SIGNS
sign(DEC, "DANGER  -  HIGH WATER", at(0, 16.5, 11.9, "S"), 16, 2.2, st(M.Metal, nil, C3(190, 160, 40)), C3(20, 16, 10), Enum.Font.SpecialElite)
sign(DEC, "FILTER ROOM", at(-60, 14.5, 11.9, "S"), 8, 1.6, IRON, C3(220, 214, 190)); sign(DEC, "WORKSHOP", at(-26.5, 14.5, 11.9, "S"), 8, 1.6, IRON, C3(220, 214, 190))
sign(DEC, "CONTROL", at(26.5, 14.5, 11.9, "S"), 8, 1.6, IRON, C3(220, 214, 190)); sign(DEC, "STORE", at(60, 14.5, 11.9, "S"), 8, 1.6, IRON, C3(220, 214, 190))
sign(DEC, "OVERFLOW 1", at(-55, 15.5, -11.9, "N"), 9, 1.6, IRON, C3(220, 214, 190)); sign(DEC, "KEEP OUT", at(55, 15.5, -11.9, "N"), 9, 1.8, st(M.Metal, nil, C3(150, 30, 26)), C3(236, 226, 200))
for _, p in { { -30, F1, 4 }, { 22, F1, -3 }, { 58, F1, -40 }, { -8, F1, 44 } } do blood(p[1], p[2], p[3], 2.4) end

-- FURNITURE (everything here can be lifted, thrown and smashed)
-- the entry hall: the watchman's desk, lockers, a bench
F.desk(at(-8, F1, 52, "S")); F.chair(at(-8, F1, 48, "N"), Wd.mid, Fab.brown)
for i = 0, 2 do G2.locker(at(9, F1, 30 + i * 3.2, "W"), C3(70, 96, 84)) end
F.bench(at(-10, F1, 26, "E"), 8, Wd.dark)
-- the filter room: steel tables, barrels of chemicals
G2.steelTable(at(-62, F1, 46, "S")); G2.steelTable(at(-50, F1, 26, "E"))
for _, p in { { -74, 54 }, { -70, 54 }, { -74, 50 }, { -46, 54 }, { -72, 20 } } do F.barrel(at(p[1], F1, p[2])) end
-- the workshop
G2.workbench(at(-26.5, F1, 55, "S"), 16); G2.workbench(at(-37, F1, 30, "E"), 10)
F.crate(at(-17, F1, 24), 3); F.crate(at(-17, F1, 20), 2.4); F.chair(at(-26, F1, 48, "N"), Wd.mid, Fab.brown); F.cabinet(at(-16, F1, 50, "W"), 5, 8)
-- the control room: switchboards (cabinets), a desk, chairs
F.cabinet(at(20, F1, 56, "S"), 6, 9); F.cabinet(at(28, F1, 56, "S"), 6, 9); F.cabinet(at(36, F1, 56, "S"), 5, 9)
F.desk(at(26, F1, 30, "N")); F.chair(at(26, F1, 34, "S"), Wd.mid, Fab.brown); F.chair(at(34, F1, 24, "W"), Wd.mid, Fab.brown); F.table(at(18, F1, 22), 5, 3.4, 3, Wd.dark)
-- the store: crates and barrels stacked high
for _, p in { { 48, 54, 3.2 }, { 52, 54, 2.6 }, { 56, 53, 3 }, { 72, 50, 3.4 }, { 72, 44, 2.6 }, { 62, 22, 3 }, { 66, 22, 2.4 }, { 46, 20, 2.8 } } do F.crate(at(p[1], F1, p[2]), p[3]) end
for _, p in { { 74, 30 }, { 74, 26 }, { 70, 28 }, { 44, 46 } } do F.barrel(at(p[1], F1, p[2])) end
-- the canal hall: crates, barrels and benches along both walkways
for _, p in { { -70, 10 }, { -48, 9.5 }, { -6, 10 }, { 12, 9.8 }, { 50, 10 }, { 74, 9.6 }, { -74, -9.8 }, { -30, -10 }, { 2, -9.6 }, { 36, -10 }, { 68, -9.8 } } do
	if (p[1] + 74) % 3 == 0 then F.barrel(at(p[1], F1, p[2])) else F.crate(at(p[1], F1, p[2]), 2.6) end
end
F.bench(at(-34, F1, 10.4, "S"), 7, Wd.dark); F.bench(at(24, F1, -10.4, "N"), 7, Wd.dark)
-- the chambers
for _, p in { { -72, -20 }, { -40, -52 }, { -64, -52 }, { -36, -22 } } do F.barrel(at(p[1], F1, p[2])) end
F.crate(at(-70, F1, -44), 3); F.crate(at(-48, F1, -30), 2.6)
for _, p in { { -22, -20 }, { 22, -20 }, { -22, -52 }, { 22, -52 } } do F.crate(at(p[1], F1, p[2]), 2.8) end
F.bench(at(0, F1, -55, "N"), 8, Wd.dark)
for _, p in { { 38, -20 }, { 74, -20 }, { 36, -52 }, { 52, -24 } } do F.barrel(at(p[1], F1, p[2])) end
F.crate(at(74, F1, -44), 3); F.crate(at(48, F1, -54), 2.4); F.table(at(62, F1, -20), 5, 3.4, 3, Wd.dark)

-- the front: CITY WATERWORKS over the door, two pipes down the facade
local fac = model(DEC, "Facade")
sign(fac, "CITY WATERWORKS", at(0, 19.4, 60.5, "S"), 26, 3, st(M.Metal, nil, C3(40, 52, 46)), C3(200, 226, 190), Enum.Font.SpecialElite, nil, 14)
for _, x in { -30, 30 } do
	cyl(fac, CFrame.new(x, 12, 60.9), "FacadePipe", 2, 20, 0, 0, 0, RUST, D())
	cyl(fac, CFrame.new(x, 4, 62.2) * ALONG_Z, "FacadeElbow", 2, 3, 0, 0, 0, RUST_D, D())
end
-- keep the canal and the doorways' walks clear for the later passes
keepClear(-77, -7, 77, 7, F1); keepClear(-7, 12, 7, 58, F1)

for _, p in { { -59, F1, 36 }, { 59, F1, 36 }, { -26.5, F1, 36 }, { 26.5, F1, 36 }, { -55, F1, -36 }, { 55, F1, -36 }, { 0, F1, -36 }, { -60, F1, 0 }, { 60, F1, 0 } } do gspawn(p[1], p[2], p[3]) end
MAP:SetAttribute("SpawnInside", Vector3.new(0, 5, 44))
return endMap()
