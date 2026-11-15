-- Chapel of Thorns: one tall nave full of pews (great for throwing), side chapels, bell tower over the door.
local C3 = Color3.fromRGB
beginMap("Church", {
	floor = st(M.Slate, nil, C3(90, 86, 84)), inner = st(M.Cobblestone, "PS2_Stone1", C3(150, 140, 130)),
	wainscot = st(M.Wood, "PS2_DarkBeam1", C3(70, 48, 36)), wain = true, wainH = 5,
	ext = st(M.Cobblestone, "PS2_Stone1", C3(130, 124, 116)), trim = st(M.Wood, "PS2_DarkBeam1", C3(60, 42, 32)),
	ceiling = st(M.Wood, "PS2_DarkBeam1", C3(70, 50, 38)), roof = st(M.Slate, nil, C3(48, 44, 46)), found = st(M.Cobblestone, "PS2_Stone1", C3(100, 96, 92)),
	glass = st(M.Glass, nil, C3(110, 40, 90)), door = st(M.Wood, "PS2_DarkBeam1", C3(70, 40, 28)), porch = st(M.Cobblestone, "PS2_Stone1", C3(110, 104, 98)),
})
shell({ two = false, H = 34, roof = "gable", pitch = 0.6, winW = 5, winB = 8, winT = 28, left1 = { 44, 22, 0, -22, -44 }, right1 = { 44, 22, 0, -22, -44 }, front1 = { -40, 40 } })
local inn = model(STR, "Interior")
local I = INT()
-- side aisles separated by arcades (open), sacristy at the back
for _, x in { -36, 36 } do
	local arc = model(inn, "Arcade")
	for z = -40, 52, 12 do box(arc, "Pillar", x - 1.4, F1, z - 1.4, x + 1.4, 34, z + 1.4, T.inner) end
	box(arc, "Beam", x - 1.4, 26, -41.4, x + 1.4, 30, 53.4, T.inner)
end
wall(inn, "Sacristy", "x", -44, -78, 78, F1, 34, { dr(-56, 7), dr(0, 14, 16), dr(56, 7) }, I)
box(inn, "Chancel", -30, F1, -44, 30, F1 + 1.5, -26, T.floor)
for i = 1, 3 do box(inn, "ChancelStep", -12, F1, -26 + (i - 1) * 1.4, 12, F1 + 1.5 - (i - 1) * 0.5, -26 + i * 1.4, T.floor) end
-- carpet aisle + pews
rug(-4, -26, 4, 58, F1 + 0.05, st(M.Fabric, nil, C3(110, 20, 24)), st(M.Fabric, nil, C3(150, 120, 50)))
for z = -18, 50, 6 do G2.pew(at(-18, F1, z, "N"), 22); G2.pew(at(18, F1, z, "N"), 22) end
G2.altar(at(0, F1 + 1.5, -36, "S"))
for _, x in { -8, 8 } do candles(x, F1 + 1.5, -36) end
for _, x in { -26, 26 } do candles(x, F1 + 1.5, -30) end
-- side chapels
G2.confessional(at(-60, F1, 10, "E")); G2.confessional(at(60, F1, -10, "W"))
for _, z in { -30, 30 } do G2.pew(at(-57, F1, z, "N"), 14); G2.pew(at(57, F1, z, "N"), 14) end
for _, z in { -40, -10, 20, 45 } do candles(-74, F1, z); candles(74, F1, z) end
F.piano(at(-62, F1, -36, "E"))
-- sacristy
F.wardrobe(at(-70, F1, -54, "N")); F.table(at(-20, F1, -52, "N"), 8, 3.5, 3, Wd.dark, "Table"); F.bookshelf(at(20, F1, -57, "N"), 8, 10)
F.crate(at(60, F1, -52, "N")); F.barrel(at(66, F1, -50, "N"))
-- great cross + rose window glow
local cr = model(DEC, "Cross")
box(cr, "Vert", -1, 14, -43.2, 1, 30, -42.4, st(M.Wood, "PS2_DarkBeam1", C3(50, 30, 22)))
box(cr, "Horiz", -5, 23, -43.2, 5, 25, -42.4, st(M.Wood, "PS2_DarkBeam1", C3(50, 30, 22)))
-- chandeliers
for _, z in { -20, 10, 40 } do bulb(0, 35, z, 8, C3(255, 170, 100)) end
for z = -14, 50, 16 do candles(-31, F1, z); candles(31, F1, z) end
for _, z in { -20, 10, 40 } do
	local core = box(LIT, "NaveGlow", -1, 22, z - 1, 1, 23, z + 1, T.glow, { t = 1, deco = true })
	light(core, 60, 1.6, C3(255, 170, 110))
end
for _, z in { -30, 0, 30 } do sconce(-77.4, 14, z, "E", C3(255, 160, 90)); sconce(77.4, 14, z, "W", C3(255, 160, 90)) end
for _, p in { { 0, F1, 20 }, { -20, F1, -10 }, { 30, F1, 40 } } do blood(p[1], p[2], p[3], 2.4) end
-- bell tower over the front door
local tw = model(STR, "BellTower")
box(tw, "Tower", -10, 36, 50, 10, 70, 62, T.ext)
local cap = part(tw, "Spire", Vector3.new(16, 22, 16), CFrame.new(0, 81, 56) * CFrame.Angles(0, math.pi / 4, 0), T.roof)
cap.Shape = Enum.PartType.Block
box(tw, "BellOpening", -5, 58, 61.9, 5, 66, 62.3, st(M.SmoothPlastic, nil, C3(10, 8, 8)), DECO)
cyl(tw, CFrame.new(0, 62, 56), "Bell", 4, 4, 0, 0, 0, T.brass, DECO)
-- graves by the porch
for _, x in { -40, -32, -24, 24, 32, 40 } do
	local gm = model(DEC, "Grave")
	box(gm, "Stone", x - 1.2, 0, 78, x + 1.2, 4, 78.8, st(M.Slate, nil, C3(110, 110, 112)))
	box(gm, "Mound", x - 1.5, 0, 79, x + 1.5, 0.6, 84, st(M.Ground, nil, C3(70, 56, 40)), DECO)
end
for _, p in { { -56, F1, 0 }, { 56, F1, 0 }, { 0, F1, -36 }, { 0, F1, -52 }, { -20, F1, 40 }, { 20, F1, 10 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
