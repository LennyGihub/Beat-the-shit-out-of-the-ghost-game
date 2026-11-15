-- Last Stop Motel: a buzzing neon hallway with numbered rooms both sides, an office, a laundry and an ice machine.
local C3 = Color3.fromRGB
beginMap("Motel", {
	floor = st(M.Carpet, "PS2_Rug1", C3(120, 80, 60)), floor2 = st(M.Carpet, "PS2_Rug1", C3(110, 74, 58)),
	inner = st(M.Wood, "PS2_Wainscot1", C3(150, 112, 80)), wainscot = st(M.Wood, "PS2_DarkBeam1", C3(80, 54, 38)), wain = true, wainH = 3.2,
	ext = st(M.Plaster, "PS2_Plaster", C3(210, 190, 160)), trim = st(M.Wood, "PS2_DarkBeam1", C3(100, 60, 40)), ceiling = st(M.Plaster, "PS2_Plaster", C3(200, 190, 170)),
	roof = st(M.Slate, nil, C3(120, 60, 40)), found = st(M.Concrete, nil, C3(120, 116, 110)), door = st(M.Wood, "PS2_DarkBeam1", C3(130, 40, 40)),
	porch = st(M.Concrete, nil, C3(150, 146, 140)),
})
shell({ two = false, H = 20, roof = "gable", pitch = 0.3 })
local inn = model(STR, "Interior")
local I = INT()
-- hallway z -7..7 the whole width, rooms of 26 studs each side
wall(inn, "HallN", "x", 7.6, -78, 78, F1, 20, { dr(-65, 6, 11), dr(-39, 6, 11), dr(0, 18, 14), dr(39, 6, 11), dr(65, 6, 11) }, I)
wall(inn, "HallS", "x", -7.6, -78, 78, F1, 20, { dr(-65, 6, 11), dr(-39, 6, 11), dr(-13, 6, 11), dr(13, 6, 11), dr(39, 6, 11), dr(65, 6, 11) }, I)
for _, x in { -52, -26, 26, 52 } do wall(inn, "RoomN" .. x, "z", x, 7.6, 58, F1, 20, {}, I) end
for _, x in { -52, -26, 0, 26, 52 } do wall(inn, "RoomS" .. x, "z", x, -58, -7.6, F1, 20, {}, I) end
wall(inn, "OfficeW", "z", -13, 7.6, 58, F1, 20, { dr(30, 6, 11) }, I); wall(inn, "OfficeE", "z", 13, 7.6, 58, F1, 20, { dr(30, 6, 11) }, I)
-- each room: bed, TV, nightstand, a little bathroom corner
local n = 1
local function room(cx, cz, face)
	local back = face == "N" and cz - 18 or cz + 18
	F.bed(at(cx - 5, F1, back + (face == "N" and 5 or -5), face == "N" and "S" or "N"), 6, 8.5, Fab.mustard)
	F.nightstand(at(cx + 1, F1, back + (face == "N" and 2 or -2), face == "N" and "S" or "N"))
	F.tv(at(cx + 6, F1, cz + (face == "N" and 12 or -12), face == "N" and "N" or "S"))
	F.chair(at(cx + 8, F1, cz, "W"), Wd.mid, Fab.red)
	F.toilet(at(cx + 9, F1, back + (face == "N" and 2 or -2), face == "N" and "S" or "N"))
	bulb(cx, 21, cz, 2, C3(255, 210, 150))
	local sgn = sign(DEC, tostring(n), at(cx, 14, face == "N" and 7.0 or -7.0, face == "N" and "S" or "N"), 2.4, 2, T.brass, C3(30, 20, 10), Enum.Font.Merriweather)
	n += 1
end
for _, x in { -65, -39, 39, 65 } do room(x, 33, "S") end
for _, x in { -65, -39, -13, 13, 39, 65 } do room(x, -33, "N") end
-- office
F.counter(at(0, F1, 24, "S"), 18); F.cabinet(at(-8, F1, 54, "S"), 6, 9); F.chair(at(4, F1, 34, "S"), Wd.mid, Fab.brown)
poster(0, 12, 57.7, "N", 8, 5, C3(40, 90, 70), Wd.dark)
-- hallway: ice machine, vending, cleaning cart
G2.vending(at(-76, F1, 0, "E"), C3(30, 120, 160)); G2.vending(at(76, F1, 0, "W"), C3(170, 120, 20))
G2.luggageCart(at(-20, F1, 2, "E"))
for _, x in { -60, -30, 0, 30, 60 } do
	local nl = box(LIT, "Neon", x - 3, 20.4, -0.15, x + 3, 20.7, 0.15, st(M.Neon, nil, C3(255, 60, 150)), DECO)
	local l = light(nl, 24, 1.1, C3(255, 70, 160)); l:SetAttribute("Flicker", true)
end
rug(-78, -7, 78, 7, F1 + 0.05, st(M.Carpet, "PS2_Rug1", C3(90, 30, 40)))
for _, p in { { -39, F1, 33 }, { 13, F1, -33 }, { 50, F1, 0 } } do blood(p[1], p[2], p[3], 2.6) end
-- big neon MOTEL sign on a pole in front
local fac = model(DEC, "Facade")
box(fac, "Pole", 30, 0, 80, 31.4, 34, 81.4, st(M.Metal, nil, C3(60, 60, 64)))
local ns = sign(fac, "MOTEL", CFrame.new(30.7, 30, 81) * CFrame.Angles(0, math.pi / 2, 0), 22, 7, st(M.Metal, nil, C3(30, 20, 30)), C3(255, 70, 160), Enum.Font.Bangers, Enum.NormalId.Front, 12)
local ns2 = ns:Clone(); ns2.CFrame = CFrame.new(30.7, 30, 81) * CFrame.Angles(0, -math.pi / 2, 0); ns2.Parent = fac
light(ns, 50, 2, C3(255, 70, 160))
sign(fac, "VACANCY", CFrame.new(30.7, 24.5, 81) * CFrame.Angles(0, math.pi / 2, 0), 12, 2.4, st(M.Metal, nil, C3(30, 20, 30)), C3(80, 255, 120), Enum.Font.Bangers, Enum.NormalId.Front, 14)
for _, p in { { -65, F1, -33 }, { 65, F1, -33 }, { -39, F1, 33 }, { 39, F1, 33 }, { 0, F1, -33 }, { 40, F1, 0 } } do gspawn(p[1], p[2], p[3]) end
return endMap()
