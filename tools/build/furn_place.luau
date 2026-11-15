local root = getRoot("Mansion")
FURN = fresh(root, "Furniture")
local DEC = fresh(root, "Decor")
local G, U = 2, 23

-- rugs + runners (decor, not destructible)
local function rug(x1, z1, x2, z2, y, border)
	box(DEC, "RugBorder", x1 - 0.6, y, z1 - 0.6, x2 + 0.6, y + 0.1, z2 + 0.6, st(M.Fabric, nil, border or Color3.fromRGB(70, 30, 28)), { deco = true })
	box(DEC, "Rug", x1, y + 0.05, z1, x2, y + 0.16, z2, T.rug, { deco = true })
end
rug(-14, 8, 14, 40, G + 0.03)
rug(-66, 10, -48, 48, G + 0.03)
rug(-66, -40, -48, -18, G + 0.03)
rug(52, 20, 72, 40, G + 0.03)
rug(-44, -55, -40, 55, U + 0.03, Color3.fromRGB(40, 30, 26))
rug(40, -55, 44, 55, U + 0.03, Color3.fromRGB(40, 30, 26))
rug(-70, 22, -60, 36, U + 0.03); rug(-68, -46, -58, -34, U + 0.03); rug(-24, -44, -12, -34, U + 0.03); rug(58, 10, 70, 50, U + 0.03)

-- creepy portraits (decor)
local function painting(x, y, z, face, w, h)
	local m = model(DEC, "Painting")
	local cf = at(x, y, z, face)
	b(m, cf, "Frame", w + 1, h + 1, 0.35, 0, 0, 0.18, st(M.Wood, nil, Color3.fromRGB(120, 92, 48)), DECO)
	b(m, cf, "Canvas", w, h, 0.1, 0, 0, -0.02, st(M.SmoothPlastic, nil, Color3.fromRGB(46, 38, 30)), DECO)
	b(m, cf, "Coat", w * 0.6, h * 0.35, 0.1, 0, -h * 0.32, -0.08, st(M.SmoothPlastic, nil, Color3.fromRGB(20, 18, 18)), DECO)
	part(m, "Face", Vector3.new(w * 0.32, h * 0.36, 0.1), cf * CFrame.new(0, h * 0.05, -0.1), st(M.SmoothPlastic, nil, Color3.fromRGB(196, 180, 160)), { shape = Enum.PartType.Cylinder, deco = true }).CFrame = cf * CFrame.new(0, h * 0.05, -0.1) * CFrame.Angles(0, math.pi / 2, 0)
	b(m, cf, "Hair", w * 0.42, h * 0.16, 0.1, 0, h * 0.24, -0.12, st(M.SmoothPlastic, nil, Color3.fromRGB(15, 13, 12)), DECO)
	for _, ex in { -1, 1 } do b(m, cf, "Eye", w * 0.06, h * 0.03, 0.1, ex * w * 0.07, h * 0.08, -0.15, st(M.SmoothPlastic, nil, Color3.fromRGB(10, 8, 8)), DECO) end
end
for _, z in { 8, 44 } do painting(-35.3, 15, z, "E", 6, 8) end
for _, z in { 52 } do painting(35.3, 15, z, "W", 6, 8) end
painting(-26, 16, 57.7, "N", 5, 7); painting(26, 16, 57.7, "N", 5, 7)
painting(-12, 32, -29.3, "S", 5, 7); painting(12, 32, -29.3, "S", 5, 7)
for _, z in { -40, -20, 0, 20, 40 } do painting(-47.3, 31, z, "E", 3.5, 5); painting(47.3, 31, z, "W", 3.5, 5) end
painting(-77.6, 12, 30, "E", 6, 8); painting(77.6, 12, -30, "W", 5, 7); painting(-63, 32, 57.6, "N", 5, 7); painting(63, 32, -57.6, "S", 5, 7)

-- GREAT HALL
for _, x in { -27, -10, 10, 26 } do F.bookshelf(at(x, G, -28.3, "S"), 7, 9) end
F.coffeeTable(at(0, G, 24, "N"))
F.sofa(at(0, G, 30, "N"), Fab.red, 10)
F.armchair(at(-7.5, G, 22, "E"), Fab.red); F.armchair(at(7.5, G, 22, "W"), Fab.red)
F.piano(at(-33.2, G, 2, "E"))
F.sideTable(at(-33.7, G, -6.5, "E"), true, false); F.sideTable(at(-33.7, G, 10.5, "E"), false, true)
F.clock(at(-34.2, G, -15, "E")); F.clock(at(-33, G, 56.5, "N")); F.clock(at(33, G, 56.5, "N"))
F.pedestal(at(-9, G, 55, "N")); F.pedestal(at(9, G, 55, "N"))
F.bench(at(-33.6, G, 45, "E"), 6); F.bench(at(33.6, G, 42, "W"), 6)
F.floorLamp(at(-6, G, 32.5)); F.floorLamp(at(6, G, 32.5))
F.armchair(at(-22, G, -12, "S"), Fab.green); F.armchair(at(-14, G, -12, "S"), Fab.green); F.sideTable(at(-18, G, -12.5), true, false)
F.crate(at(31, G, -26, "S"), 3); F.barrel(at(32, G, -21)); F.crate(at(-31, G, -26), 2.5)
F.globe(at(20, G, -12))
F.sideTable(at(-22, G, 52), false, true); F.sideTable(at(22, G, 52), true, false)

-- DINING ROOM
F.diningTable(at(-57, G, 29, "E"), 26)
for z = 29 - 10.5, 29 + 10.6, 3.5 do F.chair(at(-61.8, G, z, "E"), Wd.dark, Fab.red); F.chair(at(-52.2, G, z, "W"), Wd.dark, Fab.red) end
F.chair(at(-57, G, 43.8, "N"), Wd.dark, Fab.red); F.chair(at(-57, G, 14.2, "S"), Wd.dark, Fab.red)
F.cabinet(at(-76.8, G, 30, "E"), 8, 10); F.cabinet(at(-57, G, 56.8, "N"), 8, 10)
F.cabinet(at(-40, G, 6, "W"), 6, 9)
F.floorLamp(at(-75, G, 55)); F.floorLamp(at(-75, G, 4)); F.clock(at(-38, G, 50, "W"))
F.sideTable(at(-38.5, G, 40, "W"), true, false)

-- LIBRARY
for _, x in { -74, -58, -42 } do F.bookshelf(at(x, G, -56.8, "S"), 7, 12) end
for _, z in { -30, -5 } do F.bookshelf(at(-76.8, G, z, "E"), 7, 12) end
for _, x in { -72, -44 } do F.bookshelf(at(x, G, -1.8, "N"), 7, 12) end
for _, z in { -46, -40 } do F.bookshelf(at(-67, G, z, "E"), 6, 9, Wd.mid) end
F.table(at(-55, G, -30, "N"), 9, 4.5, 3.4, Wd.mid, "ReadingTable"); finalize(FURN:FindFirstChild("ReadingTable"), 2, "ReadingTable")
F.chair(at(-55, G, -33.6, "S"), Wd.mid, Fab.green); F.chair(at(-55, G, -26.4, "N"), Wd.mid, Fab.green); F.chair(at(-59, G, -33.6, "S"), Wd.mid, Fab.green); F.chair(at(-51, G, -26.4, "N"), Wd.mid, Fab.green)
F.desk(at(-44, G, -46, "S")); F.chair(at(-44, G, -50.2, "S"), Wd.dark, Fab.brown)
F.globe(at(-62, G, -12)); F.armchair(at(-70, G, -15, "E"), Fab.brown); F.armchair(at(-48, G, -15, "W"), Fab.brown); F.floorLamp(at(-74, G, -18))
F.sideTable(at(-38.5, G, -24, "W"), true, false)

-- KITCHEN
F.counter(at(-28, G, -56.5, "S"), 12); F.stove(at(-18.5, G, -56.4, "S")); F.counter(at(-9, G, -56.5, "S"), 10)
F.fridge(at(-33.2, G, -35, "E")); F.counter(at(-2.9, G, -36, "W"), 8)
F.table(at(-18, G, -42, "N"), 9, 5, 3.4, Wd.plank, "KitchenTable"); finalize(FURN:FindFirstChild("KitchenTable"), 2, "KitchenTable")
F.chair(at(-21, G, -45.8, "S"), Wd.plank); F.chair(at(-15, G, -45.8, "S"), Wd.plank); F.chair(at(-21, G, -38.2, "N"), Wd.plank); F.chair(at(-15, G, -38.2, "N"), Wd.plank)
F.barrel(at(-33, G, -55)); F.barrel(at(-29.5, G, -51)); F.crate(at(-4, G, -48), 3); F.crate(at(-4, G, -48 + 3.4), 2.4)

-- BILLIARD ROOM
F.poolTable(at(18, G, -44, "E"))
F.cabinet(at(28, G, -56.8, "S"), 8, 9); F.bookshelf(at(9, G, -56.8, "S"), 6, 9, Wd.mid)
F.armchair(at(4, G, -36, "E"), Fab.brown); F.armchair(at(32.5, G, -36, "W"), Fab.brown); F.sideTable(at(3.5, G, -41, "E"), true, false)
F.floorLamp(at(33, G, -53)); F.bench(at(18, G, -33, "S"), 8); F.barrel(at(3, G, -55))

-- LIVING ROOM
F.sofa(at(62, G, 30, "E"), Fab.green, 11)
F.armchair(at(69, G, 20.5, "S"), Fab.mustard); F.armchair(at(69, G, 39.5, "N"), Fab.mustard)
F.coffeeTable(at(68, G, 30, "E"))
F.sideTable(at(62, G, 22.8, "E"), true, false); F.sideTable(at(62, G, 37.2, "E"), false, true)
F.tv(at(57, G, 56.5, "N")); F.armchair(at(57, G, 47, "S"), Fab.blue); F.rockingChair(at(46, G, 8, "S"))
for _, z in { 10, 48 } do F.bookshelf(at(38.4, G, z, "E"), 7, 11) end
F.floorLamp(at(76, G, 4)); F.floorLamp(at(76, G, 55)); F.clock(at(76.8, G, 45, "W"))

-- STUDY
F.desk(at(60, G, -46, "N")); F.chair(at(60, G, -50, "S"), Wd.dark, Fab.brown)
for _, z in { -30, -5 } do F.bookshelf(at(76.8, G, z, "W"), 7, 12) end
for _, x in { 42, 58, 74 } do F.bookshelf(at(x, G, -56.8, "S"), 7, 12) end
F.globe(at(45, G, -20)); F.armchair(at(70, G, -18, "W"), Fab.red); F.floorLamp(at(73, G, -12))
F.cabinet(at(38.6, G, -30, "E"), 6, 9); F.crate(at(40, G, -4), 2.6)

-- BALCONY
for _, x in { -8, 8 } do F.bookshelf(at(x, U, -28.3, "S"), 7, 9) end
F.sideTable(at(-30, U, -27.6, "S"), true, true); F.sideTable(at(25, U, -27.6, "S"), false, true)
F.bench(at(-24, U, -21, "N"), 6)

-- WEST CORRIDOR (like the old hallway)
for _, z in { -50, -5, 45 } do F.sideTable(at(-46.1, U, z, "E"), true, true) end
F.bench(at(-46.4, U, 10, "E"), 6); F.clock(at(-38.2, U, 52, "W")); F.crate(at(-44, U, -56), 2.5); F.crate(at(-40, U, -56), 3)
-- W1 bedroom
F.bed(at(-72.1, U, 29, "E"), 7, 10, Fab.red)
F.nightstand(at(-76.6, U, 23.5, "E")); F.nightstand(at(-76.6, U, 34.5, "E"))
F.wardrobe(at(-60, U, 56.4, "N")); F.dresser(at(-63, U, 1.9, "S"), 7); F.mirror(at(-52, U, 50, "W"))
F.rockingChair(at(-55, U, 12, "W")); F.toyChest(at(-64, U, 29, "W"))
-- W2 bedroom
F.bed(at(-63, U, -52.1, "S"), 7, 10, Fab.blue)
F.nightstand(at(-68.3, U, -56.6, "S")); F.nightstand(at(-57.7, U, -56.6, "S"))
F.wardrobe(at(-76.4, U, -20, "E")); F.dresser(at(-63, U, -2.3, "N"), 6); F.armchair(at(-53, U, -40, "W"), Fab.grey)
-- Master bedroom (back left)
F.bed(at(-18, U, -51.6, "S"), 9, 11, Fab.red)
F.nightstand(at(-24.5, U, -56.6, "S")); F.nightstand(at(-11.5, U, -56.6, "S"))
F.wardrobe(at(-32.4, U, -40, "E")); F.dresser(at(-2.9, U, -45, "W"), 7); F.armchair(at(-30, U, -34, "S"), Fab.red); F.mirror(at(-4, U, -34, "S"))
-- Nursery (back right)
F.crib(at(6, U, -53, "S")); F.rockingChair(at(12, U, -40, "S")); F.toyChest(at(25, U, -56.4, "S"))
F.dresser(at(32.6, U, -45, "W"), 6); F.bed(at(26, U, -37, "W"), 5, 8, Fab.pink); F.floorLamp(at(3, U, -33))
-- EAST CORRIDOR
for _, z in { -50, -5, 45 } do F.sideTable(at(46.1, U, z, "W"), true, true) end
F.bench(at(46.4, U, 10, "W"), 6); F.pedestal(at(38.5, U, 52, "W"))
-- Kids room
F.bed(at(73, U, 15, "W"), 5, 8, Fab.blue); F.bed(at(73, U, 45, "W"), 5, 8, Fab.green); F.nightstand(at(76.6, U, 30, "W"))
F.toyChest(at(62, U, 15, "E")); F.toyChest(at(62, U, 45, "E")); F.desk(at(55, U, 56.2, "N")); F.chair(at(55, U, 52.5, "S"), Wd.light)
F.bookshelf(at(51, U, 5, "E"), 6, 9, Wd.light); F.wardrobe(at(62, U, 2.3, "S"))
-- Bathroom / storage
F.bathtub(at(75.4, U, -40, "N")); F.bathtub(at(75.4, U, -22, "N")); F.toilet(at(65, U, -56.6, "S")); F.sink(at(56, U, -56.8, "S")); F.sink(at(51, U, -40, "E"))
for i = 0, 5 do F.crate(at(52 + i * 4, U, -4, i * 0.3), 2.5 + (i % 2)) end
F.barrel(at(74, U, -5)); F.barrel(at(70.5, U, -5))

local n = 0
for _, m in FURN:GetChildren() do if m:GetAttribute("Weight") then n += 1 end end
return "furniture pieces: " .. n .. " parts: " .. #FURN:GetDescendants()
