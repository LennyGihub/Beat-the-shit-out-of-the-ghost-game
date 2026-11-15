-- Hotel Morrow: red-carpet lobby with a grand stair, a ballroom, and guest rooms upstairs off a long hallway.
local C3 = Color3.fromRGB
beginMap("Hotel", {
	floor = st(M.Carpet, "PS2_Rug1", C3(140, 40, 40)), floor2 = st(M.Carpet, "PS2_Rug1", C3(120, 50, 40)),
	inner = st(M.Fabric, "PS2_Wallpaper2", C3(190, 160, 120)), wainscot = st(M.Wood, "PS2_Wainscot1", C3(100, 60, 40)), wain = true,
	ext = st(M.Brick, nil, C3(120, 60, 50)), trim = st(M.Wood, "PS2_DarkBeam1", C3(80, 50, 34)), ceiling = st(M.Plaster, "PS2_Plaster", C3(210, 196, 170)),
	roof = st(M.Slate, nil, C3(50, 46, 48)), found = st(M.Granite, nil, C3(120, 112, 104)), door = st(M.Wood, "PS2_DarkBeam1", C3(90, 50, 30)),
	porch = st(M.Marble, nil, C3(200, 190, 176)),
})
shell({ two = true, roof = "flat" })
local inn = model(STR, "Interior")
local I = INT()
local MARBLE = st(M.Marble, nil, C3(214, 206, 192))
-- ground: lobby (centre, double height), ballroom (west), bar + kitchen (east)
wall(inn, "G_ballE", "z", -30, -58, 58, F1, 20, { dr(30, 10, 14), dr(-20, 10, 14) }, I)
wall(inn, "G_barW", "z", 30, -58, 58, F1, 20, { dr(30, 10, 14), dr(-20, 10, 14) }, I)
wall(inn, "G_kitchen", "x", -20, 30.6, 78, F1, 20, { dr(54, 8) }, I)
box(STR, "LobbyFloor", -29.4, 2.05, -58, 29.4, 2.25, 58, MARBLE)
rug(-6, -40, 6, 58, F1 + 0.25, st(M.Carpet, "PS2_Rug1", C3(150, 30, 34)), st(M.Fabric, nil, C3(180, 140, 60)))
-- grand stair at the back of the lobby, balcony above
slab(-78, -58, -30, 58); slab(30, -58, 78, 58); slab(-30, -58, 30, -38)
stairs(-6, 6, -6.5)
box(STR, "StairLanding", -6, F1, -40, 6, F2, -38, T.floor)
railing("x", -37.7, -30, -6.5, F2); railing("x", -37.7, 6.5, 30, F2)
-- upstairs: hallway z -8.6..8.6 over the wings, rooms both sides
for _, sx in { -1, 1 } do
	local x1, x2 = sx < 0 and -78 or 30, sx < 0 and -30 or 78
	wall(inn, "U_n" .. sx, "x", 8.6, x1, x2, F2, 20, { dr((x1 + x2) / 2 - 12, 6), dr((x1 + x2) / 2 + 12, 6) }, I)
	wall(inn, "U_s" .. sx, "x", -8.6, x1, x2, F2, 20, { dr((x1 + x2) / 2 - 12, 6), dr((x1 + x2) / 2 + 12, 6) }, I)
	wall(inn, "U_mn" .. sx, "z", (x1 + x2) / 2, 8.6, 58, F2, 20, {}, I); wall(inn, "U_ms" .. sx, "z", (x1 + x2) / 2, -58, -8.6, F2, 20, {}, I)
	for _, rx in { (x1 + x2) / 2 - 12, (x1 + x2) / 2 + 12 } do
		F.bed(at(rx, F2, 44, "S"), 7, 9, Fab.red); F.nightstand(at(rx + 6, F2, 54, "S")); F.dresser(at(rx, F2, 12, "N"), 6)
		F.bed(at(rx, F2, -44, "N"), 7, 9, Fab.blue); F.nightstand(at(rx - 6, F2, -54, "N")); F.armchair(at(rx + 6, F2, -14, "S"), Fab.mustard)
		sconce(rx, 31, 7.9, "S"); sconce(rx, 31, -7.9, "N")
	end
end
wall(inn, "U_lobW", "z", -30, -58, 58, F2, 20, { dr(-48, 8) }, I); wall(inn, "U_lobE", "z", 30, -58, 58, F2, 20, { dr(-48, 8) }, I)
-- lobby: front desk, sofas, luggage, piano
F.counter(at(18, F1, 40, "W"), 16); F.cabinet(at(26, F1, 52, "W"), 6, 10)
F.sofa(at(-16, F1, 30, "E"), Fab.green, 9); F.sofa(at(16, F1, 10, "W"), Fab.green, 9); F.coffeeTable(at(-8, F1, 30, "N"))
G2.luggageCart(at(10, F1, 50, "S")); G2.luggageCart(at(-18, F1, 52, "S"))
F.clock(at(-26, F1, 56, "S")); F.floorLamp(at(-24, F1, 20, "E")); F.floorLamp(at(24, F1, 0, "W"))
-- ballroom: round tables, piano, stage
for _, p in { { -64, 30 }, { -46, 30 }, { -64, 8 }, { -46, 8 }, { -64, -14 }, { -46, -14 } } do
	F.table(at(p[1], F1, p[2], "N"), 6, 6, 3, Wd.dark, "Table")
	for _, d in { { 0, -4 }, { 0, 4 }, { -4, 0 }, { 4, 0 } } do F.chair(at(p[1] + d[1], F1, p[2] + d[2], d[2] < 0 and "S" or (d[2] > 0 and "N" or (d[1] < 0 and "E" or "W"))), Wd.dark, Fab.red) end
end
box(STR, "Stage", -78, F1, -58, -32, F1 + 3, -38, Wd.dark)
F.piano(at(-60, F1 + 3, -48, "S"))
-- bar + kitchen
F.counter(at(54, F1, 0, "W"), 22); for z = -8, 8, 4 do F.chair(at(48, F1, z, "E"), Wd.dark, Fab.red) end
F.bookshelf(at(76.5, F1, 0, "W"), 10, 10)
F.stove(at(50, F1, -55, "N")); F.stove(at(58, F1, -55, "N")); F.fridge(at(70, F1, -55, "N")); F.counter(at(52, F1, -36, "N"), 14)
-- lights
bulb(0, 43, 20, 10, C3(255, 200, 140)); bulb(0, 43, -10, 10, C3(255, 200, 140)); bulb(0, 43, 45, 10, C3(255, 200, 140))
for _, p in { { -55, 0 }, { -55, 30 }, { 55, 0 } } do
	local core = box(LIT, "Chandelier", p[1] - 1, 18, p[2] - 1, p[1] + 1, 19, p[2] + 1, T.glow, DECO)
	light(core, 45, 1.5, C3(255, 200, 140))
end
for _, p in { { -55, 21, 20 }, { -55, 21, -20 }, { 55, 21, 20 }, { 55, 21, -30 } } do bulb(p[1], p[2], p[3], 2.5) end
for _, x in { -66, -42, 42, 66 } do bulb(x, 42, 0, 1.2, C3(255, 190, 130)) end
for _, z in { 0, 30 } do sconce(-29.4, 12, z, "E"); sconce(29.4, 12, z, "W") end
for _, p in { { 0, F1, 10 }, { -54, F1, 0 }, { 42, F2, 44 } } do blood(p[1], p[2], p[3], 2.4) end
local fac = model(DEC, "Facade")
sign(fac, "HOTEL MORROW", CFrame.new(0, 40, 60.8) * CFrame.Angles(0, math.pi, 0), 40, 6, st(M.Metal, nil, C3(30, 20, 20)), C3(255, 210, 120), Enum.Font.Fondamento)
box(fac, "Awning", -18, 17, 60.4, 18, 17.6, 76, st(M.Fabric, nil, C3(130, 24, 30)))
for _, p in { { -54, F1, -10 }, { 54, F1, -10 }, { 0, F1, 0 }, { -54, F2, 40 }, { 54, F2, -40 }, { 0, F2, -48 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
