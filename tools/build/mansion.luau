-- Mansion shell: 160 x 120 footprint, great hall (double height), wings, upstairs rooms.
local old = workspace:FindFirstChild("MatPreview"); if old then old:Destroy() end
local root = getRoot("Mansion")
local F = fresh(root, "Structure")
local F1, F2, H = 2, 23, 20

local function mapS(along, fixed, s, y, d) if along == "x" then return s, y, fixed + d end return fixed + d, y, s end
local function boxS(m, name, along, fixed, s1, y1, d1, s2, y2, d2, sty, o)
	local x1, yy1, z1 = mapS(along, fixed, s1, y1, d1)
	local x2, yy2, z2 = mapS(along, fixed, s2, y2, d2)
	return box(m, name, x1, yy1, z1, x2, yy2, z2, sty, o)
end

local function opening(m, along, fixed, op, y0, th)
	local o1, o2 = op.c - op.w / 2, op.c + op.w / 2
	local d, TR = th / 2 + 0.6, 0.6
	boxS(m, "Frame", along, fixed, o1 - TR, y0 + op.b, -d, o1, y0 + op.t + TR, d, T.trim)
	boxS(m, "Frame", along, fixed, o2, y0 + op.b, -d, o2 + TR, y0 + op.t + TR, d, T.trim)
	boxS(m, "Frame", along, fixed, o1 - TR, y0 + op.t, -d, o2 + TR, y0 + op.t + TR, d, T.trim)
	if op.kind == "window" then
		boxS(m, "Sill", along, fixed, o1 - 1, y0 + op.b - 0.4, -(d + 0.3), o2 + 1, y0 + op.b, d + 0.3, T.trim)
		boxS(m, "Glass", along, fixed, o1, y0 + op.b, -0.1, o2, y0 + op.t, 0.1, T.glass, { t = 0.35 })
		boxS(m, "Mullion", along, fixed, op.c - 0.2, y0 + op.b, -0.25, op.c + 0.2, y0 + op.t, 0.25, T.trim, DECO)
		for _, f in { 0.33, 0.66 } do
			local yy = y0 + op.b + (op.t - op.b) * f
			boxS(m, "Mullion", along, fixed, o1, yy - 0.2, -0.25, o2, yy + 0.2, 0.25, T.trim, DECO)
		end
	elseif op.kind == "double" then
		local inward, leafW = op.inward, op.w / 2 - 0.1
		for _, hs in { { o1, o1 + 0.5 }, { o2 - 0.5, o2 } } do
			local d1, d2 = inward * (th / 2), inward * (th / 2 + leafW)
			boxS(m, "DoorLeaf", along, fixed, hs[1], y0 + 0.05, math.min(d1, d2), hs[2], y0 + op.t - 0.1, math.max(d1, d2), T.wainscot)
			for k = 0, 1 do
				local pd1, pd2 = inward * (th / 2 + 0.6 + k * leafW / 2), inward * (th / 2 + leafW / 2 - 0.3 + k * leafW / 2)
				local sm = (hs[1] + hs[2]) / 2
				boxS(m, "Panel", along, fixed, sm - 0.35, y0 + 1.5, math.min(pd1, pd2), sm + 0.35, y0 + op.t - 2, math.max(pd1, pd2), T.trim, DECO)
			end
		end
	end
end

local function wall(parent, name, along, fixed, a1, a2, y0, h, ops, style)
	local m = model(parent, name)
	local th = style.th
	table.sort(ops, function(p, q) return p.c < q.c end)
	local skinSide = {}
	for _, sk in style.skins do skinSide[sk.side] = true end
	local function seg(s1, s2, b1, b2)
		if s2 - s1 < 0.01 or b2 - b1 < 0.01 then return end
		boxS(m, "Wall", along, fixed, s1, y0 + b1, -th / 2, s2, y0 + b2, th / 2, style.core)
		for _, sk in style.skins do
			local d1, d2 = sk.side * th / 2, sk.side * (th / 2 + 0.25)
			boxS(m, "Skin", along, fixed, s1, y0 + b1, math.min(d1, d2), s2, y0 + b2, math.max(d1, d2), sk.s)
		end
		if b1 == 0 then
			for _, side in style.wain do
				local base = th / 2 + (skinSide[side] and 0.25 or 0)
				local top = math.min(b2, 4.5)
				local d1, d2 = side * base, side * (base + 0.25)
				boxS(m, "Wainscot", along, fixed, s1, y0, math.min(d1, d2), s2, y0 + top, math.max(d1, d2), T.wainscot, DECO)
				if b2 >= 4.9 then
					d1, d2 = side * base, side * (base + 0.5)
					boxS(m, "ChairRail", along, fixed, s1, y0 + 4.5, math.min(d1, d2), s2, y0 + 4.9, math.max(d1, d2), T.trim, DECO)
				end
			end
		end
	end
	local cur = a1
	for _, op in ops do
		local o1, o2 = op.c - op.w / 2, op.c + op.w / 2
		seg(cur, o1, 0, h); seg(o1, o2, 0, op.b); seg(o1, o2, op.t, h)
		cur = o2
		opening(m, along, fixed, op, y0, th)
	end
	seg(cur, a2, 0, h)
	return m
end

local function EXT(inward) return { core = T.siding, th = 2, skins = { { side = inward, s = T.plaster } }, wain = { inward } } end
local INT = { core = T.plaster, th = 1.2, skins = {}, wain = { 1, -1 } }
local function win(c, w, bb, tt) return { c = c, w = w or 6, b = bb or 4, t = tt or 14, kind = "window" } end
local function dr(c, w, t) return { c = c, w = w or 6, b = 0, t = t or 12, kind = "open" } end
local function wins(list) local r = {} for _, c in list do table.insert(r, win(c)) end return r end

-- ground + foundation
box(F, "Foundation", -81, 0, -61, 81, 2, 61, T.stone)
box(F, "GroundFloor", -78, 1.9, -58, 78, 2.05, 58, T.floor)

-- exterior walls
local ext = model(F, "Exterior")
local front1 = wins({ -22, 22, -48, -66, 48, 66 })
table.insert(front1, { c = 0, w = 10, b = 0, t = 15, kind = "double", inward = -1 })
wall(ext, "Front1", "x", 59, -80, 80, F1, H, front1, EXT(-1))
wall(ext, "Front2", "x", 59, -80, 80, F2, H, wins({ -26, -12, 12, 26, -42, 42, -56, -70, 56, 70 }), EXT(-1))
wall(ext, "Back1", "x", -59, -80, 80, F1, H, wins({ -66, -50, -24, -10, 10, 24, 50, 66 }), EXT(1))
wall(ext, "Back2", "x", -59, -80, 80, F2, H, wins({ -66, -56, -42, -24, -10, 10, 24, 42, 56, 66 }), EXT(1))
wall(ext, "Left1", "z", -79, -58, 58, F1, H, wins({ 45, 15, -15, -45 }), EXT(1))
wall(ext, "Left2", "z", -79, -58, 58, F2, H, wins({ 45, 15, -15, -45 }), EXT(1))
wall(ext, "Right1", "z", 79, -58, 58, F1, H, wins({ 46, 14, -15, -45 }), EXT(-1))
wall(ext, "Right2", "z", 79, -58, 58, F2, H, wins({ 45, 15, -15, -45 }), EXT(-1))
for _, xz in { { -79, -59 }, { 79, -59 }, { -79, 59 }, { 79, 59 } } do
	box(ext, "CornerPost", xz[1] - 1.6, 2, xz[2] - 1.6, xz[1] + 1.6, 44, xz[2] + 1.6, T.trim)
end
for _, yy in { { 22, 23 }, { 43, 44 } } do
	box(ext, "Band", -80.4, yy[1], 58, 80.4, yy[2], 60.4, T.trim)
	box(ext, "Band", -80.4, yy[1], -60.4, 80.4, yy[2], -58, T.trim)
	box(ext, "Band", -80.4, yy[1], -58, -78, yy[2], 58, T.trim)
	box(ext, "Band", 78, yy[1], -58, 80.4, yy[2], 58, T.trim)
end

-- interior walls
local inn = model(F, "Interior")
wall(inn, "G_xm36", "z", -36, -58, 58, F1, H, { dr(30, 10, 14), dr(-10, 8, 13), dr(-45, 6, 12) }, INT)
wall(inn, "G_xp36", "z", 36, -58, 58, F1, H, { dr(30, 10, 14), dr(-45, 6, 12) }, INT)
wall(inn, "G_zm30", "x", -30, -35.4, 35.4, F1, H, { dr(-18, 8, 13), dr(18, 8, 13) }, INT)
wall(inn, "G_x0", "z", 0, -58, -30.6, F1, H, { dr(-44, 6, 12) }, INT)
wall(inn, "G_west_z0", "x", 0, -78, -36.6, F1, H, { dr(-58, 8, 13) }, INT)
wall(inn, "G_east_z0", "x", 0, 36.6, 78, F1, H, { dr(58, 8, 13) }, INT)
wall(inn, "U_xm36", "z", -36, -58, 58, F2, H, { dr(-24, 6, 12) }, INT)
wall(inn, "U_xp36", "z", 36, -58, 58, F2, H, { dr(-24, 6, 12) }, INT)
wall(inn, "U_zm30", "x", -30, -35.4, 35.4, F2, H, { dr(-18, 6, 12), dr(18, 6, 12) }, INT)
wall(inn, "U_x0", "z", 0, -58, -30.6, F2, H, {}, INT)
wall(inn, "U_xm48", "z", -48, -58, 58, F2, H, { dr(30, 6, 12), dr(-30, 6, 12) }, INT)
wall(inn, "U_xp48", "z", 48, -58, 58, F2, H, { dr(30, 6, 12), dr(-30, 6, 12) }, INT)
wall(inn, "U_west_z0", "x", 0, -78, -48.6, F2, H, {}, INT)
wall(inn, "U_east_z0", "x", 0, 48.6, 78, F2, H, {}, INT)

-- floors / ceilings
local fl = model(F, "Floors")
box(fl, "Slab", -78, 22, -58, -36, 23, 58, T.floor)
box(fl, "Slab", 36, 22, -58, 78, 23, 58, T.floor)
box(fl, "Slab", -36, 22, -58, 36, 23, -18, T.floor)
box(fl, "Band", -36.6, 22, -18, -35.4, 23, 58, T.trim)
box(fl, "Band", 35.4, 22, -18, 36.6, 23, 58, T.trim)
box(fl, "BalconyFascia", -35.4, 21.2, -18.5, 35.4, 23, -17.9, T.trim)
box(fl, "Ceiling", -78, 43, -58, 78, 44, 58, T.beam)
local bm = model(F, "Beams")
for _, z in { -6, 6, 18, 30, 42, 54 } do box(bm, "Coffer", -35.4, 41.4, z - 0.7, 35.4, 43, z + 0.7, T.trim, DECO) end
for _, x in { -24, -12, 0, 12, 24 } do box(bm, "Coffer", x - 0.7, 41.4, -18, x + 0.7, 43, 58, T.trim, DECO) end
for _, x in { -70, -60, -50, -42, 42, 50, 60, 70 } do box(bm, "Joist", x - 0.5, 21, -58, x + 0.5, 22, 58, T.trim, DECO) end
for _, z in { -50, -40, -24 } do box(bm, "Joist", -35.4, 21, z - 0.5, 35.4, 22, z + 0.5, T.trim, DECO) end
for z = -50, 50, 10 do
	box(bm, "Rafter", -78, 42, z - 0.5, -36.6, 43, z + 0.5, T.trim, DECO)
	box(bm, "Rafter", 36.6, 42, z - 0.5, 78, 43, z + 0.5, T.trim, DECO)
end
for _, z in { -50, -40 } do box(bm, "Rafter", -35.4, 42, z - 0.5, 35.4, 43, z + 0.5, T.trim, DECO) end

-- grand staircase (right side of the hall, rising toward the back balcony)
local stc = model(F, "Stairs")
for i = 1, 21 do
	local zA, zB = 13.5 - (i - 1) * 1.5, 13.5 - i * 1.5
	box(stc, "Step", 28, F1, zB, 34.9, F1 + i, zA, T.floor)
	box(stc, "Nosing", 28, F1 + i - 0.2, zA - 0.3, 34.9, F1 + i + 0.05, zA + 0.15, T.trim, DECO)
	box(stc, "SidePanel", 27.6, F1, zB, 28, F1 + i, zA, T.wainscot)
	box(stc, "Baluster", 27.65, F1 + i, (zA + zB) / 2 - 0.15, 27.95, F1 + i + 3.6, (zA + zB) / 2 + 0.15, T.trim, DECO)
end
local th = math.atan(21 / 31.5)
part(stc, "Handrail", Vector3.new(0.6, 0.45, math.sqrt(31.5 ^ 2 + 21 ^ 2)), CFrame.new(27.8, 16.6, -2.25) * CFrame.Angles(th, 0, 0), T.trim)
box(stc, "Newel", 27.1, F1, 13.6, 28.5, F1 + 5, 15, T.trim)
ball(stc, CFrame.new(27.8, F1 + 5.4, 14.3), "NewelCap", 1.5, 0, 0, 0, T.trim)
-- balcony railing
local rl = model(F, "BalconyRail")
box(rl, "Rail", -35.4, F2 + 3.4, -18.3, 28, F2 + 3.9, -17.7, T.trim)
box(rl, "RailLow", -35.4, F2, -18.2, 28, F2 + 0.4, -17.8, T.trim)
for x = -34.8, 27.5, 1.2 do box(rl, "Baluster", x - 0.15, F2 + 0.4, -18.15, x + 0.15, F2 + 3.4, -17.85, T.trim, DECO) end
for _, x in { -35, -24, -12, 0, 12, 24, 27.4 } do box(rl, "Newel", x - 0.5, F2, -18.5, x + 0.5, F2 + 4.6, -17.5, T.trim) end

-- living room fireplace + chimney (east wall)
local ch = model(F, "Fireplace")
box(ch, "Stack", 80, 0, 26, 86, 76, 34, T.stone)
box(ch, "Hearth", 74, F1, 24, 78, F1 + 0.5, 36, T.stone)
box(ch, "Pillar", 75.5, F1, 25, 78, F1 + 9, 27, T.stone)
box(ch, "Pillar", 75.5, F1, 33, 78, F1 + 9, 35, T.stone)
box(ch, "Lintel", 75.5, F1 + 7, 27, 78, F1 + 9, 33, T.stone)
box(ch, "FireBack", 77.6, F1, 27, 78, F1 + 7, 33, st(M.Slate, nil, Color3.fromRGB(30, 26, 24)))
box(ch, "Mantel", 74.8, F1 + 9, 24, 78, F1 + 9.8, 36, T.trim)
box(ch, "Breast", 76.5, F1 + 9.8, 25.5, 78, 22, 34.5, T.stone)
local logs = model(ch, "Logs")
for k = -1, 1, 2 do part(logs, "Log", Vector3.new(0.9, 0.9, 4), CFrame.new(76.5 + k * 0.4, F1 + 0.95, 30) * CFrame.Angles(0, k * 0.3, 0), T.beam) end
local fireP = box(ch, "FirePart", 76.2, F1 + 0.8, 29, 77.2, F1 + 1.8, 31, T.glow, { t = 1, deco = true })
local fire = Instance.new("Fire"); fire.Size = 5; fire.Heat = 9; fire.Color = Color3.fromRGB(255, 120, 40); fire.SecondaryColor = Color3.fromRGB(255, 200, 80); fire.Parent = fireP
light(fireP, 28, 2, Color3.fromRGB(255, 120, 50), true)

-- roof (gable along X)
local rf = model(F, "Roof")
local s = 0.45
local a = math.atan(s)
local span = 63
for _, sg in { 1, -1 } do
	local midZ = span / 2
	local midY = 44 + s * (60 - midZ)
	local n = Vector3.new(0, math.cos(a), math.sin(a))
	part(rf, "RoofPanel", Vector3.new(166, 1.2, span / math.cos(a)), CFrame.new(0, midY + 0.6 * n.Y, sg * (midZ + 0.6 * n.Z)) * CFrame.Angles(sg * a, 0, 0), T.roof)
	box(rf, "Fascia", -83, 41.6, sg * 63 - 0.3, 83, 43.2, sg * 63 + 0.3, T.trim)
end
box(rf, "RidgeCap", -83.5, 71, -1.4, 83.5, 72.6, 1.4, T.trim)
for _, x in { -79, 79 } do
	for k = 0, 22 do
		local hw = 60 - 2.667 * k
		box(rf, "Gable", x - 1, 44 + 1.2 * k, -hw, x + 1, 45.2 + 1.2 * k, hw, T.siding)
	end
end

-- porch
local po = model(F, "Porch")
box(po, "Deck", -16, 1, 60, 16, 2.05, 72, T.floor)
box(po, "Step", -8, 0, 72, 8, 1.35, 74, T.floor)
box(po, "Step", -8, 0, 74, 8, 0.7, 76, T.floor)
for _, x in { -15, -9, 9, 15 } do cyl(po, CFrame.new(x, 9, 71), "Column", 1.6, 14, 0, 0, 0, T.plaster) end
box(po, "PorchRoof", -17, 16, 60.4, 17, 17, 73, T.roof)
box(po, "PorchBeam", -17, 15, 70.2, 17, 16, 71.8, T.trim)
for _, x in { -7.5, 7.5 } do
	local lm = model(po, "Lantern")
	box(lm, "Cage", x - 0.6, 10, 60.5, x + 0.6, 11.6, 61.7, T.iron, { t = 0.3, deco = true })
	local g = box(lm, "Glow", x - 0.35, 10.2, 60.75, x + 0.35, 11.4, 61.45, T.glow, DECO)
	light(g, 20, 1.3)
end

-- spawn inside the hall
local sp = workspace:FindFirstChildOfClass("SpawnLocation")
if sp then
	sp.CFrame = CFrame.new(0, 2.1, 48); sp.Size = Vector3.new(8, 0.2, 8); sp.Transparency = 1; sp.CanCollide = false
	for _, c in sp:GetChildren() do if c:IsA("Decal") then c:Destroy() end end
end

return "structure parts: " .. #F:GetDescendants()
