-- Furniture builders. cf = floor point, front = local -Z. Every piece becomes one welded Model tagged "Furniture".
local CS = game:GetService("CollectionService")
local Wd = {
	dark = st(M.Wood, "PS2_DarkBeam1", Color3.fromRGB(70, 48, 36)),
	mid = st(M.Wood, "PS2_DarkBeam1", Color3.fromRGB(120, 84, 58)),
	light = st(M.Wood, "PS2_Wainscot1", Color3.fromRGB(150, 118, 88)),
	plank = st(M.WoodPlanks, "PS2_FloorPlanks2", Color3.fromRGB(120, 100, 84)),
}
local Fab = {
	red = st(M.Fabric, nil, Color3.fromRGB(110, 36, 34)), green = st(M.Fabric, nil, Color3.fromRGB(52, 74, 52)),
	mustard = st(M.Fabric, nil, Color3.fromRGB(150, 118, 52)), blue = st(M.Fabric, nil, Color3.fromRGB(52, 62, 92)),
	cream = st(M.Fabric, nil, Color3.fromRGB(205, 192, 168)), grey = st(M.Fabric, nil, Color3.fromRGB(100, 98, 96)),
	brown = st(M.Leather, nil, Color3.fromRGB(88, 52, 36)), white = st(M.Fabric, nil, Color3.fromRGB(215, 212, 205)),
	pink = st(M.Fabric, nil, Color3.fromRGB(170, 120, 125)),
}
local Por = st(M.SmoothPlastic, nil, Color3.fromRGB(225, 222, 212))
local Blk = st(M.SmoothPlastic, nil, Color3.fromRGB(25, 24, 24))
local rng = Random.new(1337)
local FURN

local function finalize(m, weight, kind)
	local best, bv = nil, -1
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			local v = p.Size.X * p.Size.Y * p.Size.Z
			if v > bv then best, bv = p, v end
		end
	end
	m.PrimaryPart = best
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = (p == best)
			if p ~= best then
				local w = Instance.new("WeldConstraint"); w.Part0 = best; w.Part1 = p; w.Parent = p
			end
		end
	end
	m:SetAttribute("Weight", weight)
	m:SetAttribute("Kind", kind)
	CS:AddTag(m, "Furniture")
	return m
end
local function new(kind) return model(FURN, kind) end

local function legs4(m, cf, w, d, h, s, th)
	th = th or 0.4
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do
		b(m, cf, "Leg", th, h, th, sx * (w / 2 - th), h / 2, sz * (d / 2 - th), s)
	end end
end

local F = {}
function F.chair(cf, s, fab)
	local m = new("Chair")
	legs4(m, cf, 2.4, 2.4, 2.2, s, 0.3)
	b(m, cf, "Seat", 2.6, 0.35, 2.6, 0, 2.35, 0, s)
	if fab then b(m, cf, "Cushion", 2.3, 0.25, 2.3, 0, 2.6, 0, fab) end
	b(m, cf, "Back", 2.6, 3.2, 0.3, 0, 4.1, 1.15, s)
	b(m, cf, "BackPost", 0.35, 3.6, 0.35, -1.1, 4.1, 1.15, s); b(m, cf, "BackPost", 0.35, 3.6, 0.35, 1.1, 4.1, 1.15, s)
	return finalize(m, 1, "Chair")
end
function F.armchair(cf, fab, w)
	w = w or 4
	local m = new("Armchair")
	b(m, cf, "Base", w, 1.8, 3.6, 0, 1.3, 0, fab)
	b(m, cf, "Cushion", w - 1.4, 0.6, 3, 0, 2.5, -0.2, fab)
	b(m, cf, "Back", w, 3.6, 0.9, 0, 3.6, 1.4, fab)
	b(m, cf, "Arm", 0.8, 1.6, 3.6, -w / 2 + 0.4, 2.8, 0, fab); b(m, cf, "Arm", 0.8, 1.6, 3.6, w / 2 - 0.4, 2.8, 0, fab)
	legs4(m, cf, w, 3.6, 0.45, Wd.dark, 0.4)
	return finalize(m, 2, "Armchair")
end
function F.sofa(cf, fab, w)
	w = w or 9
	local m = new("Sofa")
	b(m, cf, "Base", w, 1.8, 3.8, 0, 1.3, 0, fab)
	for i = 0, 2 do b(m, cf, "Cushion", (w - 1.6) / 3 - 0.1, 0.6, 3.1, -w / 2 + 0.8 + (w - 1.6) / 6 + i * (w - 1.6) / 3, 2.5, -0.2, fab) end
	b(m, cf, "Back", w, 3.8, 1, 0, 3.7, 1.4, fab)
	b(m, cf, "Arm", 0.8, 1.8, 3.8, -w / 2 + 0.4, 2.9, 0, fab); b(m, cf, "Arm", 0.8, 1.8, 3.8, w / 2 - 0.4, 2.9, 0, fab)
	legs4(m, cf, w, 3.8, 0.45, Wd.dark, 0.4)
	return finalize(m, 3, "Sofa")
end
function F.table(cf, w, d, h, s, kind)
	local m = new(kind or "Table")
	b(m, cf, "Top", w, 0.45, d, 0, h - 0.22, 0, s)
	b(m, cf, "Apron", w - 0.6, 0.7, d - 0.6, 0, h - 0.8, 0, s)
	legs4(m, cf, w - 0.2, d - 0.2, h - 0.45, s, 0.5)
	return m
end
function F.diningTable(cf, w)
	local m = F.table(cf, w, 6, 3.6, Wd.mid, "DiningTable")
	b(m, cf, "Runner", 1.8, 0.05, w - 2, 0, 3.62, 0, Fab.red, DECO).CFrame = cf * CFrame.new(0, 3.62, 0) * CFrame.Angles(0, math.pi / 2, 0)
	for i = -1, 1 do
		local x = i * w / 3
		cyl(m, cf, "CandleBase", 0.7, 0.3, x, 3.75, 0, T.brass, DECO)
		cyl(m, cf, "Candle", 0.3, 1.2, x, 4.5, 0, Por, DECO)
		ball(m, cf, "Flame", 0.3, x, 5.2, 0, T.glow, DECO)
	end
	for i = -3, 3, 2 do cyl(m, cf, "Plate", 1.1, 0.08, i * w / 9, 3.65, -1.8, Por, DECO); cyl(m, cf, "Plate", 1.1, 0.08, i * w / 9, 3.65, 1.8, Por, DECO) end
	return finalize(m, 4, "DiningTable")
end
function F.coffeeTable(cf)
	local m = F.table(cf, 5, 2.8, 1.8, Wd.dark, "CoffeeTable")
	cyl(m, cf, "Cup", 0.5, 0.5, 1.2, 2.05, 0.3, Por, DECO)
	b(m, cf, "Book", 1.2, 0.3, 1.6, -1, 1.95, 0, Fab.green, DECO)
	return finalize(m, 1, "CoffeeTable")
end
function F.sideTable(cf, withLamp, withBranches)
	local m = F.table(cf, 2.6, 2.6, 3.2, Wd.dark, "SideTable")
	if withLamp then
		cyl(m, cf, "LampBase", 0.8, 0.3, -0.4, 3.35, 0, T.brass, DECO)
		cyl(m, cf, "LampStem", 0.2, 1.2, -0.4, 4, 0, T.brass, DECO)
		cyl(m, cf, "LampShade", 1.4, 1, -0.4, 4.9, 0, T.shade, DECO)
		local g = ball(m, cf, "LampBulb", 0.4, -0.4, 4.6, 0, T.glow, DECO)
		light(g, 14, 0.9)
	end
	if withBranches then
		cyl(m, cf, "Vase", 0.7, 1.2, 0.6, 3.8, 0, st(M.SmoothPlastic, nil, Color3.fromRGB(60, 60, 66)), DECO)
		for i = 1, 4 do
			part(m, "Branch", Vector3.new(0.12, 2.6, 0.12), cf * CFrame.new(0.6, 5.3, 0) * CFrame.Angles(rng:NextNumber(-0.6, 0.6), 0, rng:NextNumber(-0.6, 0.6)) * CFrame.new(0, 0.6, 0), Wd.dark, DECO)
		end
	end
	return finalize(m, 1, "SideTable")
end
function F.bookshelf(cf, w, h, s)
	w = w or 7; h = h or 11; s = s or Wd.dark
	local m = new("Bookshelf")
	local d = 2
	b(m, cf, "Back", w, h, 0.3, 0, h / 2, d / 2 - 0.15, s)
	b(m, cf, "Side", 0.4, h, d, -w / 2 + 0.2, h / 2, 0, s); b(m, cf, "Side", 0.4, h, d, w / 2 - 0.2, h / 2, 0, s)
	b(m, cf, "Top", w + 0.4, 0.5, d + 0.3, 0, h, 0, s)
	local n = math.floor(h / 2.4)
	for i = 0, n do
		local y = 0.2 + i * (h - 0.6) / n
		b(m, cf, "Shelf", w - 0.6, 0.25, d - 0.2, 0, y, 0, s)
		if i < n then
			local x = -w / 2 + 0.55
			while x < w / 2 - 0.8 do
				local bw = rng:NextNumber(0.25, 0.55); local bh = rng:NextNumber(1.2, 1.9)
				local c = Color3.fromHSV(rng:NextNumber(0, 1), rng:NextNumber(0.3, 0.6), rng:NextNumber(0.25, 0.55))
				if rng:NextNumber() < 0.85 then b(m, cf, "Book", bw, bh, 1.4, x + bw / 2, y + 0.12 + bh / 2, 0.1, st(M.SmoothPlastic, nil, c), DECO) end
				x += bw + 0.03
			end
		end
	end
	return finalize(m, 3, "Bookshelf")
end
function F.cabinet(cf, w, h)
	local m = new("Cabinet")
	b(m, cf, "Body", w, h * 0.45, 2.2, 0, h * 0.225, 0, Wd.mid)
	b(m, cf, "Upper", w - 0.4, h * 0.55, 1.4, 0, h * 0.45 + h * 0.275, 0.3, Wd.mid)
	b(m, cf, "Glass", w - 1, h * 0.5, 0.1, 0, h * 0.45 + h * 0.275, -0.45, T.glass, { t = 0.5, deco = true })
	for i = 0, 2 do cyl(m, cf, "Plate", 1.2, 0.1, -w / 3 + i * w / 3, h * 0.45 + h * 0.3, 0.2, Por, DECO).CFrame = cf * CFrame.new(-w / 3 + i * w / 3, h * 0.45 + h * 0.3, 0.3) end
	for _, x in { -w / 4, w / 4 } do b(m, cf, "Door", w / 2 - 0.5, h * 0.38, 0.1, x, h * 0.225, -1.12, Wd.dark, DECO); b(m, cf, "Knob", 0.25, 0.25, 0.2, x + (x < 0 and 0.8 or -0.8), h * 0.25, -1.2, T.brass, DECO) end
	return finalize(m, 3, "Cabinet")
end
function F.bed(cf, w, l, blanket)
	local m = new("Bed")
	b(m, cf, "Frame", w, 1.4, l, 0, 1.1, 0, Wd.dark)
	b(m, cf, "Mattress", w - 0.4, 1, l - 0.6, 0, 2.3, 0, Fab.white)
	b(m, cf, "Blanket", w - 0.1, 0.2, l * 0.62, 0, 2.85, -l * 0.18, blanket)
	b(m, cf, "BlanketSide", w + 0.05, 1.3, l * 0.62, 0, 2.3, -l * 0.18, blanket, DECO)
	local np = w > 5 and 2 or 1
	for i = 1, np do b(m, cf, "Pillow", np == 2 and w / 2 - 0.5 or w - 1.2, 0.7, 1.5, np == 2 and (i == 1 and -w / 4 or w / 4) or 0, 3.1, l / 2 - 1.3, Fab.cream) end
	b(m, cf, "Headboard", w + 0.6, 6, 0.6, 0, 3, l / 2 + 0.3, Wd.dark)
	b(m, cf, "Footboard", w + 0.6, 3.2, 0.5, 0, 1.6, -l / 2 - 0.25, Wd.dark)
	for _, x in { -w / 2, w / 2 } do b(m, cf, "Post", 0.6, 7, 0.6, x, 3.5, l / 2 + 0.3, Wd.dark) end
	return finalize(m, 4, "Bed")
end
function F.nightstand(cf)
	local m = new("Nightstand")
	b(m, cf, "Body", 2.4, 2.8, 2.2, 0, 1.4, 0, Wd.mid)
	b(m, cf, "Drawer", 2, 0.9, 0.1, 0, 2, -1.12, Wd.dark, DECO)
	b(m, cf, "Knob", 0.3, 0.3, 0.2, 0, 2, -1.2, T.brass, DECO)
	cyl(m, cf, "LampBase", 0.7, 0.3, 0, 2.95, 0, T.brass, DECO)
	cyl(m, cf, "LampStem", 0.2, 1, 0, 3.5, 0, T.brass, DECO)
	cyl(m, cf, "LampShade", 1.3, 0.9, 0, 4.3, 0, T.shade, DECO)
	local g = ball(m, cf, "LampBulb", 0.35, 0, 4.05, 0, T.glow, DECO)
	light(g, 12, 0.8)
	return finalize(m, 1, "Nightstand")
end
function F.dresser(cf, w)
	w = w or 6
	local m = new("Dresser")
	b(m, cf, "Body", w, 4, 2.4, 0, 2.2, 0, Wd.mid)
	b(m, cf, "Top", w + 0.3, 0.3, 2.7, 0, 4.35, 0, Wd.dark)
	for r = 0, 2 do for c = 0, 1 do
		local x = -w / 4 + c * w / 2
		b(m, cf, "Drawer", w / 2 - 0.4, 1.05, 0.1, x, 1 + r * 1.2, -1.22, Wd.dark, DECO)
		b(m, cf, "Knob", 0.25, 0.25, 0.2, x, 1 + r * 1.2, -1.3, T.brass, DECO)
	end end
	b(m, cf, "MirrorFrame", w * 0.6, 4, 0.3, 0, 6.5, 0.9, Wd.dark)
	b(m, cf, "Mirror", w * 0.6 - 0.6, 3.4, 0.1, 0, 6.5, 0.72, st(M.Glass, nil, Color3.fromRGB(120, 130, 135)), { deco = true, t = 0.1 })
	return finalize(m, 3, "Dresser")
end
function F.wardrobe(cf)
	local m = new("Wardrobe")
	b(m, cf, "Body", 6, 10, 3, 0, 5.2, 0, Wd.dark)
	b(m, cf, "Crown", 6.6, 0.6, 3.4, 0, 10.4, 0, Wd.dark)
	for _, x in { -1.45, 1.45 } do
		b(m, cf, "Door", 2.8, 8.8, 0.15, x, 5.4, -1.55, Wd.mid, DECO)
		b(m, cf, "Knob", 0.25, 0.6, 0.2, x > 0 and 0.35 or -0.35, 5.4, -1.68, T.brass, DECO)
	end
	legs4(m, cf, 6, 3, 0.4, Wd.dark, 0.5)
	return finalize(m, 4, "Wardrobe")
end
function F.clock(cf)
	local m = new("GrandfatherClock")
	b(m, cf, "Body", 2.6, 9, 1.8, 0, 4.7, 0, Wd.dark)
	b(m, cf, "Head", 3, 2.6, 2, 0, 10.4, 0, Wd.dark)
	cyl(m, cf, "Face", 2, 0.2, 0, 10.4, -1.02, Por, DECO).CFrame = cf * CFrame.new(0, 10.4, -1.02) * CFrame.Angles(0, math.pi / 2, 0)
	b(m, cf, "Hand", 0.1, 0.8, 0.1, 0, 10.7, -1.15, Blk, DECO)
	b(m, cf, "Window", 1.6, 5, 0.1, 0, 5.5, -0.92, T.glass, { t = 0.4, deco = true })
	b(m, cf, "Pendulum", 0.15, 3, 0.15, 0, 6, -0.7, T.brass, DECO)
	ball(m, cf, "Bob", 0.7, 0, 4.4, -0.7, T.brass, DECO)
	return finalize(m, 3, "GrandfatherClock")
end
function F.piano(cf)
	local m = new("Piano")
	b(m, cf, "Body", 9, 7, 3, 0, 3.9, 0.6, Blk)
	b(m, cf, "KeyBed", 9, 0.8, 2, 0, 3.6, -1.6, Blk)
	b(m, cf, "Keys", 8.4, 0.2, 1.4, 0, 4.05, -1.75, Por, DECO)
	for i = -20, 20, 2 do b(m, cf, "BlackKey", 0.18, 0.2, 0.8, i * 0.2, 4.2, -1.5, Blk, DECO) end
	b(m, cf, "Leg", 0.6, 3.2, 0.6, -4, 1.6, -2.2, Blk); b(m, cf, "Leg", 0.6, 3.2, 0.6, 4, 1.6, -2.2, Blk)
	b(m, cf, "Plinth", 9, 0.5, 3, 0, 0.25, 0.6, Blk)
	return finalize(m, 5, "Piano")
end
function F.bench(cf, w, s)
	local m = F.table(cf, w or 5, 1.6, 2.2, s or Wd.dark, "Bench")
	return finalize(m, 1, "Bench")
end
function F.tv(cf)
	local m = new("TV")
	b(m, cf, "Stand", 4.4, 2.6, 2.4, 0, 1.3, 0, Wd.dark)
	b(m, cf, "Box", 3.8, 3.2, 3.2, 0, 4.2, 0.1, st(M.SmoothPlastic, nil, Color3.fromRGB(60, 58, 56)))
	b(m, cf, "Screen", 3, 2.4, 0.1, -0.1, 4.3, -1.52, st(M.Glass, nil, Color3.fromRGB(40, 55, 60)), DECO)
	b(m, cf, "Antenna", 0.1, 2, 0.1, 0.5, 6.6, 0.4, T.iron, DECO).CFrame = cf * CFrame.new(0.5, 6.6, 0.4) * CFrame.Angles(0, 0, -0.5)
	b(m, cf, "Antenna", 0.1, 2, 0.1, -0.5, 6.6, 0.4, T.iron, DECO).CFrame = cf * CFrame.new(-0.5, 6.6, 0.4) * CFrame.Angles(0, 0, 0.5)
	return finalize(m, 2, "TV")
end
function F.poolTable(cf)
	local m = new("PoolTable")
	b(m, cf, "Felt", 7, 0.4, 13, 0, 3.4, 0, st(M.Fabric, nil, Color3.fromRGB(30, 80, 50)))
	b(m, cf, "Body", 7.4, 1.2, 13.4, 0, 2.6, 0, Wd.dark)
	for _, x in { -3.75, 3.75 } do b(m, cf, "Rail", 0.8, 0.8, 14.2, x, 3.6, 0, Wd.dark) end
	for _, z in { -6.75, 6.75 } do b(m, cf, "Rail", 8.3, 0.8, 0.8, 0, 3.6, z, Wd.dark) end
	legs4(m, cf, 6.6, 12.4, 2.1, Wd.dark, 0.9)
	for i = 1, 6 do ball(m, cf, "Ball", 0.5, rng:NextNumber(-2.5, 2.5), 3.85, rng:NextNumber(-5, 5), st(M.SmoothPlastic, nil, Color3.fromHSV(rng:NextNumber(), 0.8, 0.8)), DECO) end
	return finalize(m, 5, "PoolTable")
end
function F.desk(cf)
	local m = new("Desk")
	b(m, cf, "Top", 7, 0.4, 3.4, 0, 3.4, 0, Wd.mid)
	b(m, cf, "Pedestal", 2.2, 3.2, 3.2, -2.3, 1.6, 0, Wd.mid); b(m, cf, "Pedestal", 2.2, 3.2, 3.2, 2.3, 1.6, 0, Wd.mid)
	for i = 0, 2 do b(m, cf, "Drawer", 1.8, 0.8, 0.1, -2.3, 0.7 + i * 1, -1.62, Wd.dark, DECO) end
	b(m, cf, "Paper", 1.4, 0.05, 1.8, 0.6, 3.63, 0, Por, DECO)
	cyl(m, cf, "LampBase", 0.8, 0.3, 2.5, 3.75, 0.8, T.brass, DECO)
	cyl(m, cf, "LampShade", 1.3, 0.8, 2.5, 4.9, 0.8, st(M.Glass, nil, Color3.fromRGB(40, 110, 60)), { t = 0.2, deco = true })
	b(m, cf, "LampStem", 0.15, 1, 0.15, 2.5, 4.3, 0.8, T.brass, DECO)
	local g = ball(m, cf, "LampBulb", 0.35, 2.5, 4.7, 0.8, T.glow, DECO)
	light(g, 14, 0.8)
	return finalize(m, 3, "Desk")
end
function F.counter(cf, w)
	local m = new("Counter")
	b(m, cf, "Base", w, 3.6, 2.8, 0, 1.8, 0, Wd.light)
	b(m, cf, "Top", w + 0.2, 0.35, 3, 0, 3.75, 0, st(M.Marble, nil, Color3.fromRGB(190, 186, 178)))
	for x = -w / 2 + 1.2, w / 2 - 1, 2.4 do b(m, cf, "Door", 2.1, 2.8, 0.1, x, 1.7, -1.42, Wd.mid, DECO); b(m, cf, "Knob", 0.25, 0.25, 0.2, x + 0.7, 2.5, -1.5, T.iron, DECO) end
	for i = 1, 2 do cyl(m, cf, "Jar", 0.8, 1.2, -w / 2 + i * 1.2, 4.5, 0.5, st(M.Glass, nil, Color3.fromRGB(150, 140, 110)), { t = 0.3, deco = true }) end
	return finalize(m, 3, "Counter")
end
function F.stove(cf)
	local m = new("Stove")
	b(m, cf, "Body", 4.4, 3.8, 3, 0, 1.9, 0, st(M.Metal, nil, Color3.fromRGB(40, 40, 42)))
	for _, x in { -1, 1 } do for _, z in { -0.6, 0.6 } do cyl(m, cf, "Burner", 1.1, 0.15, x, 3.85, z, st(M.Metal, nil, Color3.fromRGB(20, 20, 20)), DECO) end end
	b(m, cf, "OvenDoor", 3.4, 2, 0.1, 0, 1.6, -1.52, st(M.Glass, nil, Color3.fromRGB(30, 30, 30)), DECO)
	cyl(m, cf, "Pot", 1.4, 1.1, -1, 4.5, -0.6, st(M.Metal, nil, Color3.fromRGB(90, 90, 95)), DECO)
	b(m, cf, "Pipe", 0.6, 6, 0.6, 1.5, 6.8, 1.1, st(M.Metal, nil, Color3.fromRGB(35, 35, 35)), DECO)
	return finalize(m, 3, "Stove")
end
function F.fridge(cf)
	local m = new("IceBox")
	b(m, cf, "Body", 4, 8, 3, 0, 4, 0, st(M.SmoothPlastic, nil, Color3.fromRGB(200, 196, 182)))
	b(m, cf, "Seam", 4.02, 0.1, 3.02, 0, 5.4, 0, Blk, DECO)
	b(m, cf, "Handle", 0.3, 1.4, 0.3, 1.5, 6.5, -1.6, T.iron, DECO); b(m, cf, "Handle", 0.3, 1.4, 0.3, 1.5, 4.4, -1.6, T.iron, DECO)
	return finalize(m, 4, "IceBox")
end
function F.barrel(cf)
	local m = new("Barrel")
	cyl(m, cf, "Body", 3, 4.2, 0, 2.1, 0, Wd.plank)
	for _, y in { 0.6, 2.1, 3.6 } do cyl(m, cf, "Hoop", 3.1, 0.25, 0, y, 0, T.iron, DECO) end
	return finalize(m, 2, "Barrel")
end
function F.crate(cf, s)
	s = s or 3
	local m = new("Crate")
	b(m, cf, "Body", s, s, s, 0, s / 2, 0, Wd.plank)
	for _, z in { -s / 2, s / 2 } do b(m, cf, "Slat", s * 1.2, 0.3, 0.1, 0, s / 2, z, Wd.dark, DECO).CFrame = cf * CFrame.new(0, s / 2, z + (z > 0 and 0.05 or -0.05)) * CFrame.Angles(0, 0, math.pi / 4) end
	return finalize(m, 1, "Crate")
end
function F.bathtub(cf)
	local m = new("Bathtub")
	b(m, cf, "Bottom", 4.4, 0.6, 8.4, 0, 1, 0, Por)
	b(m, cf, "Side", 0.5, 2.6, 8.4, -2.2, 2.3, 0, Por); b(m, cf, "Side", 0.5, 2.6, 8.4, 2.2, 2.3, 0, Por)
	b(m, cf, "End", 4.4, 2.6, 0.5, 0, 2.3, -4.2, Por); b(m, cf, "End", 4.4, 2.6, 0.5, 0, 2.3, 4.2, Por)
	b(m, cf, "Water", 3.9, 0.1, 7.9, 0, 2.6, 0, st(M.Glass, nil, Color3.fromRGB(70, 80, 70)), { t = 0.3, deco = true })
	for _, x in { -1.8, 1.8 } do for _, z in { -3.6, 3.6 } do ball(m, cf, "Foot", 0.8, x, 0.4, z, T.brass, DECO) end end
	b(m, cf, "Faucet", 0.3, 1.2, 0.3, 0, 3.8, 4.1, T.brass, DECO)
	return finalize(m, 4, "Bathtub")
end
function F.toilet(cf)
	local m = new("Toilet")
	cyl(m, cf, "Bowl", 2, 1.8, 0, 1.1, -0.2, Por)
	b(m, cf, "Seat", 2.1, 0.2, 2.3, 0, 2.1, -0.3, Wd.light)
	b(m, cf, "Tank", 2.4, 2.4, 1, 0, 3.2, 1.1, Por)
	return finalize(m, 2, "Toilet")
end
function F.sink(cf)
	local m = new("Sink")
	b(m, cf, "Pedestal", 0.9, 3, 0.9, 0, 1.5, 0, Por)
	b(m, cf, "Basin", 3, 0.8, 2.2, 0, 3.3, 0, Por)
	b(m, cf, "Faucet", 0.25, 0.8, 0.25, 0, 4, 0.8, T.brass, DECO)
	b(m, cf, "Mirror", 2.6, 3.2, 0.2, 0, 6.5, 1.1, st(M.Glass, nil, Color3.fromRGB(110, 120, 125)), { t = 0.1 })
	return finalize(m, 2, "Sink")
end
function F.crib(cf)
	local m = new("Crib")
	b(m, cf, "Base", 3.6, 0.5, 6, 0, 2, 0, Wd.light)
	b(m, cf, "Mattress", 3.3, 0.5, 5.7, 0, 2.5, 0, Fab.cream)
	for _, x in { -1.8, 1.8 } do b(m, cf, "Rail", 0.25, 0.25, 6, x, 4.6, 0, Wd.light) end
	for _, z in { -3, 3 } do b(m, cf, "End", 3.85, 4.6, 0.3, 0, 2.3, z, Wd.light) end
	for z = -2.6, 2.6, 0.65 do for _, x in { -1.8, 1.8 } do b(m, cf, "Bar", 0.15, 2.4, 0.15, x, 3.4, z, Wd.light, DECO) end end
	return finalize(m, 2, "Crib")
end
function F.rockingChair(cf)
	local m = new("RockingChair")
	b(m, cf, "Seat", 2.6, 0.3, 2.6, 0, 2.4, 0, Wd.dark)
	b(m, cf, "Back", 2.6, 4, 0.3, 0, 4.6, 1.3, Wd.dark).CFrame = cf * CFrame.new(0, 4.5, 1.4) * CFrame.Angles(-0.2, 0, 0)
	for _, x in { -1.1, 1.1 } do
		b(m, cf, "Rocker", 0.3, 0.3, 4, x, 0.4, 0, Wd.dark)
		b(m, cf, "Leg", 0.3, 2, 0.3, x, 1.3, -1, Wd.dark); b(m, cf, "Leg", 0.3, 2, 0.3, x, 1.3, 1, Wd.dark)
	end
	return finalize(m, 1, "RockingChair")
end
function F.toyChest(cf)
	local m = new("ToyChest")
	b(m, cf, "Body", 4, 2.2, 2.4, 0, 1.1, 0, st(M.Wood, nil, Color3.fromRGB(120, 60, 50)))
	b(m, cf, "Lid", 4.2, 0.4, 2.6, 0, 2.4, 0, st(M.Wood, nil, Color3.fromRGB(100, 50, 40)))
	ball(m, cf, "Toy", 1.2, -1, 3.2, 0, Fab.pink, DECO)
	b(m, cf, "Block", 0.8, 0.8, 0.8, 1, 3, 0.2, Fab.blue, DECO)
	return finalize(m, 1, "ToyChest")
end
function F.globe(cf)
	local m = new("Globe")
	cyl(m, cf, "Stand", 1.6, 0.3, 0, 0.15, 0, Wd.dark)
	b(m, cf, "Post", 0.3, 2.6, 0.3, 0, 1.5, 0, Wd.dark)
	ball(m, cf, "World", 2.2, 0, 3.8, 0, st(M.SmoothPlastic, nil, Color3.fromRGB(120, 140, 110)))
	return finalize(m, 1, "Globe")
end
function F.floorLamp(cf)
	local m = new("FloorLamp")
	cyl(m, cf, "Base", 1.4, 0.3, 0, 0.15, 0, T.brass)
	b(m, cf, "Stem", 0.25, 6, 0.25, 0, 3.2, 0, T.brass)
	cyl(m, cf, "Shade", 2, 1.4, 0, 6.6, 0, T.shade)
	local g = ball(m, cf, "Bulb", 0.5, 0, 6.2, 0, T.glow, DECO)
	light(g, 18, 1)
	return finalize(m, 1, "FloorLamp")
end
function F.pedestal(cf)
	local m = new("Bust")
	b(m, cf, "Column", 1.8, 4, 1.8, 0, 2, 0, st(M.Marble, nil, Color3.fromRGB(190, 186, 176)))
	b(m, cf, "Shoulders", 1.8, 1, 1, 0, 4.5, 0, st(M.Marble, nil, Color3.fromRGB(190, 186, 176)))
	ball(m, cf, "Head", 1.3, 0, 5.6, 0, st(M.Marble, nil, Color3.fromRGB(190, 186, 176)))
	return finalize(m, 2, "Bust")
end
function F.mirror(cf)
	local m = new("StandingMirror")
	b(m, cf, "Frame", 3, 7, 0.4, 0, 4.2, 0, Wd.dark)
	b(m, cf, "Glass", 2.4, 6.4, 0.1, 0, 4.2, -0.22, st(M.Glass, nil, Color3.fromRGB(110, 120, 128)), { deco = true })
	b(m, cf, "Foot", 3, 0.4, 2, 0, 0.2, 0, Wd.dark)
	return finalize(m, 2, "StandingMirror")
end
