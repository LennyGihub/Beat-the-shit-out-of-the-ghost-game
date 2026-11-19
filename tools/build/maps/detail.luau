-- Detail + fun pass for EVERY map (the 11 in ServerStorage.Maps and the Mansion in workspace). Prepend lib2 + furn_lib
-- and a line `local TARGET = "<MapId>"` (or "ALL"):
--   (echo 'local TARGET = "Hospital"'; cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maps/detail.luau) > /tmp/run.luau
-- What it adds, themed per map (THEMES below), all blocky plain parts:
--   walls    baseboards and crown trim on every inside wall, and things hung on them (pictures, pipes, vents, clocks,
--            sconces, crosses, gauges, chains... ) - parented under Structure.Interior so they break with the wall
--   ceilings beams wherever there is a ceiling right above
--   floors   clutter (papers, rubble, stains, bottles, hay, gears... ) on free floor spots
--   outside  downpipes, chimneys / roof vents, ivy or rust streaks on the facade, wall lamps
--   props    more things to throw (crates, barrels, chairs, lamps, busts) and 4-5 red EXPLOSIVE BARRELS
--            (Furniture attribute Explosive: Config.Barrel, UltRunner.barrel)
-- Everything it makes carries the attribute Detail = true: re-running removes the old pass first.
local SSd = game:GetService("ServerStorage")
local CSd = game:GetService("CollectionService")
local C3 = Color3.fromRGB
local rngD = Random.new(90210)
local function pick(t) return t[rngD:NextInteger(1, #t)] end
local function R(a, b) return rngD:NextNumber(a, b) end

-- a plain decoration part
local function d(parent, name, sx, sy, sz, cf, color, mat, shape)
	local p = Instance.new("Part")
	p.Name = name; p.Anchored = true; p.Size = Vector3.new(sx, sy, sz); p.CFrame = cf; p.Color = color; p.Material = mat or M.SmoothPlastic
	if shape then p.Shape = shape end
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Parent = parent
	return p
end
local function glowLight(p, range, bright, color)
	local l = Instance.new("PointLight"); l.Range = range; l.Brightness = bright; l.Color = color; l.Shadows = false; l.Parent = p
end
local DARK, IRON, PAPER, GILT, BLOOD = C3(40, 30, 24), C3(52, 52, 56), C3(214, 206, 184), C3(176, 140, 60), C3(96, 16, 14)
local MUTED = { C3(96, 60, 52), C3(60, 80, 70), C3(70, 70, 100), C3(120, 100, 60), C3(84, 64, 90), C3(50, 60, 54) }

-- WALL things. cf = a point on the wall face, +Z out of the wall, +Y up, +X along the wall. TH = the map's theme.
local WALL = {}
function WALL.picture(p, cf, TH)
	local w, h = R(2.4, 4.2), R(2.6, 4)
	d(p, "Frame", w + 0.5, h + 0.5, 0.25, cf * CFrame.new(0, 0, 0.13) * CFrame.Angles(0, 0, R(-0.05, 0.05)), TH.frame or DARK, M.Wood)
	d(p, "Canvas", w, h, 0.08, cf * CFrame.new(0, 0, 0.28), pick(MUTED), M.Fabric)
	d(p, "Figure", w * 0.4, h * 0.55, 0.05, cf * CFrame.new(R(-0.3, 0.3), -h * 0.12, 0.33), pick(MUTED):Lerp(Color3.new(0, 0, 0), 0.5), M.Fabric)
end
function WALL.poster(p, cf, TH)
	local w, h = R(2.6, 3.4), R(3.6, 4.6)
	local c = pick(TH.posters or MUTED)
	local r = CFrame.Angles(0, 0, R(-0.06, 0.06))
	d(p, "Poster", w, h, 0.06, cf * r * CFrame.new(0, 0, 0.04), c, M.SmoothPlastic)
	d(p, "PosterBand", w * 0.8, h * 0.18, 0.04, cf * r * CFrame.new(0, h * 0.28, 0.08), c:Lerp(Color3.new(1, 1, 1), 0.5), M.SmoothPlastic)
	d(p, "PosterBlock", w * 0.5, h * 0.3, 0.04, cf * r * CFrame.new(0, -h * 0.12, 0.08), c:Lerp(Color3.new(0, 0, 0), 0.5), M.SmoothPlastic)
end
function WALL.board(p, cf, TH)
	d(p, "BoardFrame", 5.4, 3.6, 0.2, cf * CFrame.new(0, 0, 0.1), DARK, M.Wood)
	d(p, "Cork", 5, 3.2, 0.1, cf * CFrame.new(0, 0, 0.2), C3(150, 112, 70), M.Fabric)
	for i = 1, 5 do
		d(p, "Note", R(0.7, 1.2), R(0.8, 1.3), 0.04, cf * CFrame.new(R(-2, 2), R(-1, 1), 0.27) * CFrame.Angles(0, 0, R(-0.25, 0.25)), i % 3 == 0 and C3(200, 190, 110) or PAPER)
	end
end
function WALL.clock(p, cf, TH)
	d(p, "ClockRim", 0.3, 2.5, 2.5, cf * CFrame.new(0, 0, 0.15) * CFrame.Angles(0, math.pi / 2, 0), DARK, M.Wood, Enum.PartType.Cylinder)
	d(p, "ClockFace", 0.32, 2.1, 2.1, cf * CFrame.new(0, 0, 0.18) * CFrame.Angles(0, math.pi / 2, 0), PAPER, M.SmoothPlastic, Enum.PartType.Cylinder)
	d(p, "Hand", 0.12, 0.9, 0.05, cf * CFrame.new(0, 0, 0.37) * CFrame.Angles(0, 0, R(0, 6)) * CFrame.new(0, 0.4, 0), C3(20, 18, 16))
	d(p, "Hand", 0.1, 0.6, 0.05, cf * CFrame.new(0, 0, 0.38) * CFrame.Angles(0, 0, R(0, 6)) * CFrame.new(0, 0.28, 0), C3(20, 18, 16))
end
function WALL.mirror(p, cf, TH)
	d(p, "MirrorFrame", 3, 4.6, 0.25, cf * CFrame.new(0, 0, 0.13), TH.frame or GILT, M.Wood)
	local g = d(p, "MirrorGlass", 2.5, 4.1, 0.08, cf * CFrame.new(0, 0, 0.28), C3(150, 165, 170), M.Glass)
	g.Reflectance = 0.35
	d(p, "Crack", 0.06, 2.2, 0.03, cf * CFrame.new(0.4, 0.3, 0.33) * CFrame.Angles(0, 0, 0.5), C3(30, 34, 36))
end
function WALL.sconce(p, cf, TH)
	d(p, "SconcePlate", 0.8, 1.6, 0.2, cf * CFrame.new(0, 0, 0.1), TH.metal or C3(120, 96, 50), M.Metal)
	d(p, "SconceArm", 0.2, 0.2, 0.9, cf * CFrame.new(0, 0.2, 0.55), TH.metal or C3(120, 96, 50), M.Metal)
	local b = d(p, "SconceGlow", 0.7, 0.9, 0.7, cf * CFrame.new(0, 0.75, 0.95), TH.light, M.Neon)
	glowLight(b, 16, 0.55, TH.light)
end
function WALL.pipes(p, cf, TH, h)
	local x = R(-0.6, 0.6)
	d(p, "Pipe", 0.6, h - 1, 0.6, cf * CFrame.new(x, 0, 0.5), TH.pipe or C3(92, 96, 98), M.Metal)
	d(p, "Pipe", 0.4, h - 1, 0.4, cf * CFrame.new(x + 0.9, 0, 0.4), (TH.pipe or C3(92, 96, 98)):Lerp(C3(120, 60, 30), 0.4), M.CorrodedMetal)
	for _, y in { -h * 0.3, h * 0.25 } do d(p, "PipeClamp", 1.9, 0.3, 0.8, cf * CFrame.new(x + 0.45, y, 0.45), IRON, M.Metal) end
	d(p, "Valve", 0.25, 1.1, 1.1, cf * CFrame.new(x, R(-1, 1), 0.95) * CFrame.Angles(0, math.pi / 2, 0), C3(150, 30, 26), M.Metal, Enum.PartType.Cylinder)
end
function WALL.vent(p, cf, TH)
	d(p, "VentFrame", 3.2, 2.2, 0.2, cf * CFrame.new(0, 0, 0.1), IRON, M.Metal)
	for i = 0, 4 do d(p, "VentSlat", 2.8, 0.16, 0.2, cf * CFrame.new(0, -0.8 + i * 0.4, 0.22) * CFrame.Angles(0.5, 0, 0), C3(30, 30, 32), M.Metal) end
end
function WALL.cross(p, cf, TH)
	local c = TH.frame or GILT
	d(p, "CrossV", 0.5, 3.6, 0.3, cf * CFrame.new(0, 0, 0.15), c, M.Wood)
	d(p, "CrossH", 2.2, 0.5, 0.3, cf * CFrame.new(0, 0.7, 0.15), c, M.Wood)
end
function WALL.shelf(p, cf, TH)
	d(p, "Shelf", 4.2, 0.25, 1.1, cf * CFrame.new(0, -0.6, 0.55), DARK, M.Wood)
	for _, x in { -1.7, 1.7 } do d(p, "Bracket", 0.2, 0.8, 0.9, cf * CFrame.new(x, -1, 0.45), IRON, M.Metal) end
	for i = 1, 4 do
		local hh = R(0.6, 1.3)
		d(p, "ShelfItem", R(0.4, 0.8), hh, R(0.4, 0.7), cf * CFrame.new(-1.5 + i * 0.75 + R(-0.1, 0.1), -0.47 + hh / 2, 0.55), pick(TH.items or MUTED), i % 2 == 0 and M.Glass or M.SmoothPlastic)
	end
end
function WALL.cracks(p, cf, TH)
	local c = CFrame.new(0, 0, 0.03)
	for i = 1, 5 do
		c = c * CFrame.Angles(0, 0, R(-0.9, 0.9)) * CFrame.new(0, -R(0.6, 1.3), 0)
		d(p, "Crack", 0.09, 1.3, 0.04, cf * c, C3(24, 20, 18))
	end
end
function WALL.stain(p, cf, TH)
	local c = pick(TH.stains or { BLOOD, C3(60, 50, 34), C3(44, 56, 40) })
	local s = d(p, "Stain", R(1.6, 3), R(2.4, 4.6), 0.04, cf * CFrame.new(0, 0, 0.03) * CFrame.Angles(0, 0, R(-0.2, 0.2)), c)
	s.Transparency = 0.25
	for i = 1, 3 do d(p, "Drip", 0.18, R(1, 2.6), 0.04, cf * CFrame.new(R(-1, 1), -R(2, 3.4), 0.03), c).Transparency = 0.25 end
end
function WALL.tally(p, cf, TH)
	for g = 0, 2 do
		for i = 0, 3 do d(p, "Tally", 0.07, 0.9, 0.03, cf * CFrame.new(-1.6 + g * 1.4 + i * 0.22, R(-0.05, 0.05), 0.03) * CFrame.Angles(0, 0, R(-0.08, 0.08)), C3(30, 26, 24)) end
		d(p, "Tally", 0.07, 1.2, 0.03, cf * CFrame.new(-1.27 + g * 1.4, 0, 0.04) * CFrame.Angles(0, 0, 0.9), C3(30, 26, 24))
	end
end
function WALL.fusebox(p, cf, TH)
	d(p, "FuseBox", 2.2, 3, 0.7, cf * CFrame.new(0, 0, 0.35), C3(86, 90, 86), M.Metal)
	d(p, "FuseDoor", 1.9, 2.6, 0.1, cf * CFrame.new(0.1, 0, 0.75) * CFrame.Angles(0, 0.25, 0), C3(104, 108, 104), M.Metal)
	d(p, "FuseLamp", 0.25, 0.25, 0.15, cf * CFrame.new(-0.7, 1.7, 0.4), C3(255, 50, 40), M.Neon)
	d(p, "Conduit", 0.3, 4, 0.3, cf * CFrame.new(0.6, 3.4, 0.25), IRON, M.Metal)
end
function WALL.gauge(p, cf, TH)
	for _, x in { -1, 1 } do
		d(p, "GaugeRim", 0.4, 1.7, 1.7, cf * CFrame.new(x, 0, 0.2) * CFrame.Angles(0, math.pi / 2, 0), C3(140, 110, 50), M.Metal, Enum.PartType.Cylinder)
		d(p, "GaugeFace", 0.42, 1.35, 1.35, cf * CFrame.new(x, 0, 0.22) * CFrame.Angles(0, math.pi / 2, 0), PAPER, M.SmoothPlastic, Enum.PartType.Cylinder)
		d(p, "Needle", 0.08, 0.6, 0.04, cf * CFrame.new(x, 0, 0.45) * CFrame.Angles(0, 0, R(-2, 2)) * CFrame.new(0, 0.25, 0), C3(170, 30, 26))
	end
	d(p, "GaugePipe", 3.4, 0.35, 0.35, cf * CFrame.new(0, -1.1, 0.3), C3(92, 96, 98), M.Metal)
end
function WALL.hazard(p, cf, TH)
	for i = 0, 5 do
		d(p, "Hazard", 0.62, 1.3, 0.06, cf * CFrame.new(-1.55 + i * 0.62, 0, 0.04) * CFrame.Angles(0, 0, -0.5), i % 2 == 0 and C3(230, 180, 30) or C3(24, 22, 20))
	end
end
function WALL.lightbox(p, cf, TH)
	d(p, "BoxFrame", 3.6, 2.8, 0.3, cf * CFrame.new(0, 0, 0.15), C3(150, 156, 160), M.Metal)
	d(p, "BoxGlow", 3.2, 2.4, 0.1, cf * CFrame.new(0, 0, 0.32), C3(190, 220, 230), M.Neon)
	for _, x in { -0.8, 0.8 } do
		d(p, "Film", 1.1, 1.9, 0.04, cf * CFrame.new(x, 0, 0.39), C3(28, 34, 44))
		d(p, "Bone", 0.2, 1.4, 0.03, cf * CFrame.new(x, 0, 0.42), C3(170, 190, 200))
		for _, y in { -0.3, 0.1, 0.5 } do d(p, "Bone", 0.8, 0.1, 0.03, cf * CFrame.new(x, y, 0.42), C3(170, 190, 200)) end
	end
end
function WALL.firstaid(p, cf, TH)
	d(p, "AidBox", 2, 2, 0.6, cf * CFrame.new(0, 0, 0.3), C3(225, 225, 220), M.Metal)
	d(p, "AidCross", 0.4, 1.2, 0.05, cf * CFrame.new(0, 0, 0.63), C3(190, 30, 30))
	d(p, "AidCross", 1.2, 0.4, 0.05, cf * CFrame.new(0, 0, 0.63), C3(190, 30, 30))
end
function WALL.tools(p, cf, TH)
	d(p, "Rack", 4.4, 0.3, 0.3, cf * CFrame.new(0, 1.6, 0.15), DARK, M.Wood)
	-- pitchfork, shovel, scythe handle
	d(p, "Handle", 0.22, 4.4, 0.22, cf * CFrame.new(-1.4, -0.6, 0.3), C3(120, 90, 60), M.Wood)
	for _, x in { -1.7, -1.4, -1.1 } do d(p, "Tine", 0.1, 1, 0.1, cf * CFrame.new(x, 2, 0.3), IRON, M.Metal) end
	d(p, "Handle", 0.22, 4, 0.22, cf * CFrame.new(0, -0.4, 0.3), C3(120, 90, 60), M.Wood)
	d(p, "Blade", 0.9, 1.1, 0.12, cf * CFrame.new(0, -2.8, 0.3), IRON, M.Metal)
	d(p, "Handle", 0.22, 4.6, 0.22, cf * CFrame.new(1.4, -0.7, 0.3) * CFrame.Angles(0, 0, 0.12), C3(120, 90, 60), M.Wood)
	d(p, "Blade", 1.8, 0.25, 0.1, cf * CFrame.new(2.1, 1.5, 0.3) * CFrame.Angles(0, 0, -0.4), IRON, M.Metal)
end
function WALL.wreath(p, cf, TH)
	for i = 0, 9 do
		local a = i / 10 * math.pi * 2
		d(p, "WreathLeaf", 0.8, 0.8, 0.4, cf * CFrame.new(math.cos(a) * 1.4, math.sin(a) * 1.4, 0.2) * CFrame.Angles(0, 0, a), i % 2 == 0 and C3(44, 76, 44) or C3(34, 60, 38), M.Fabric)
	end
	for _, a in { 0.6, 2.4, 4.4 } do d(p, "WreathFlower", 0.45, 0.45, 0.3, cf * CFrame.new(math.cos(a) * 1.4, math.sin(a) * 1.4, 0.5), pick({ C3(220, 215, 205), C3(170, 40, 50), C3(120, 80, 150) }), M.Fabric) end
	d(p, "Ribbon", 0.5, 1.6, 0.1, cf * CFrame.new(0, -1.9, 0.3), C3(40, 30, 50), M.Fabric)
end
function WALL.rope(p, cf, TH)
	d(p, "Hook", 0.3, 0.3, 0.7, cf * CFrame.new(0, 1.4, 0.35), IRON, M.Metal)
	d(p, "RopeCoil", 0.5, 2.6, 2.6, cf * CFrame.new(0, 0, 0.3) * CFrame.Angles(0, math.pi / 2, 0), C3(150, 124, 84), M.Fabric, Enum.PartType.Cylinder)
	d(p, "RopeHole", 0.52, 1.5, 1.5, cf * CFrame.new(0, 0, 0.31) * CFrame.Angles(0, math.pi / 2, 0), C3(60, 46, 32), M.Fabric, Enum.PartType.Cylinder)
end
function WALL.lantern(p, cf, TH)
	d(p, "LanternHook", 0.2, 0.2, 1, cf * CFrame.new(0, 1.1, 0.5), IRON, M.Metal)
	d(p, "LanternCage", 0.9, 1.3, 0.9, cf * CFrame.new(0, 0.3, 0.9), IRON, M.Metal).Transparency = 0.4
	local g = d(p, "LanternGlow", 0.55, 0.9, 0.55, cf * CFrame.new(0, 0.3, 0.9), TH.light, M.Neon)
	glowLight(g, 18, 0.7, TH.light)
end
function WALL.neon(p, cf, TH)
	local c = pick({ C3(255, 60, 140), C3(60, 220, 255), C3(255, 170, 40), C3(120, 255, 140) })
	local b = d(p, "NeonTube", R(3, 5), 0.25, 0.25, cf * CFrame.new(0, 0, 0.3) * CFrame.Angles(0, 0, R(-0.08, 0.08)), c, M.Neon)
	d(p, "NeonTube", 0.25, 1.6, 0.25, cf * CFrame.new(-1.6, -0.8, 0.3), c, M.Neon)
	glowLight(b, 14, 0.6, c)
end
function WALL.chains(p, cf, TH)
	for _, x in { -0.8, 0.8 } do
		d(p, "ChainRing", 0.5, 0.5, 0.3, cf * CFrame.new(x, 1.6, 0.15), IRON, M.Metal)
		for i = 0, 6 do d(p, "ChainLink", 0.22, 0.42, 0.14, cf * CFrame.new(x, 1.2 - i * 0.38, 0.2) * CFrame.Angles(0, i % 2 * math.pi / 2, 0), IRON, M.Metal) end
		d(p, "Shackle", 0.6, 0.35, 0.5, cf * CFrame.new(x, -1.6, 0.25), IRON, M.Metal)
	end
end
function WALL.candles(p, cf, TH)
	d(p, "CandleShelf", 2.6, 0.2, 0.9, cf * CFrame.new(0, -0.5, 0.45), TH.frame or DARK, M.Wood)
	for i, x in { -0.8, 0, 0.8 } do
		local hh = R(0.5, 1.1)
		d(p, "Candle", 0.28, hh, 0.28, cf * CFrame.new(x, -0.4 + hh / 2, 0.45), C3(225, 215, 190))
		local f = d(p, "Flame", 0.16, 0.3, 0.16, cf * CFrame.new(x, -0.25 + hh, 0.45), C3(255, 190, 90), M.Neon)
		if i == 2 then glowLight(f, 12, 0.5, C3(255, 180, 100)) end
	end
end
function WALL.stained(p, cf, TH)
	d(p, "GlassFrame", 2.8, 5.4, 0.2, cf * CFrame.new(0, 0, 0.1), DARK, M.Wood)
	local cols = { C3(170, 40, 50), C3(50, 80, 170), C3(200, 160, 50), C3(50, 140, 90) }
	for r = 0, 3 do
		for c = 0, 1 do
			d(p, "GlassPane", 1.1, 1.15, 0.08, cf * CFrame.new(-0.6 + c * 1.2, -1.85 + r * 1.23, 0.22), cols[(r + c) % 4 + 1], M.Neon).Transparency = 0.25
		end
	end
end
function WALL.plaque(p, cf, TH)
	d(p, "Plaque", 1.8, 0.9, 0.12, cf * CFrame.new(0, 0, 0.06), GILT, M.Metal)
	d(p, "PlaqueLine", 1.2, 0.12, 0.03, cf * CFrame.new(0, 0.12, 0.13), C3(60, 44, 20))
	d(p, "PlaqueLine", 0.8, 0.1, 0.03, cf * CFrame.new(0, -0.15, 0.13), C3(60, 44, 20))
end

-- FLOOR clutter. cf = a free point on the floor (Y up).
local FLOOR = {}
local function flatCyl(p, name, r, cf, color, mat, t)
	local c = d(p, name, 0.06, r * 2, r * 2, cf * CFrame.new(0, 0.04, 0) * CFrame.Angles(0, 0, math.pi / 2), color, mat, Enum.PartType.Cylinder)
	if t then c.Transparency = t end
	return c
end
function FLOOR.papers(p, cf) for i = 1, rngD:NextInteger(2, 5) do d(p, "Paper", 0.9, 0.03, 1.2, cf * CFrame.new(R(-1.5, 1.5), 0.03 + i * 0.005, R(-1.5, 1.5)) * CFrame.Angles(0, R(0, 6), 0), i % 3 == 0 and C3(196, 184, 150) or PAPER) end end
function FLOOR.rubble(p, cf, TH) for i = 1, rngD:NextInteger(3, 6) do local s = R(0.3, 0.9); d(p, "Rubble", s * 1.4, s * 0.6, s, cf * CFrame.new(R(-1.2, 1.2), s * 0.3, R(-1.2, 1.2)) * CFrame.Angles(R(-0.3, 0.3), R(0, 6), R(-0.3, 0.3)), TH.rubble or C3(150, 144, 132), M.Concrete) end end
-- an irregular flat patch made of a few overlapping turned blocks (blocky, not a perfect disc)
local function patch(p, name, cf, r, color, mat, t, refl)
	for i = 1, 4 do
		local q = d(p, name, r * R(0.7, 1.5), 0.05, r * R(0.5, 1.1), cf * CFrame.new(R(-r, r) * 0.5, 0.03 + i * 0.004, R(-r, r) * 0.5) * CFrame.Angles(0, R(0, 3.14), 0), color, mat)
		q.Transparency = t or 0
		if refl then q.Reflectance = refl end
	end
end
function FLOOR.stain(p, cf, TH) patch(p, "FloorStain", cf, R(1, 2), pick(TH.stains or { BLOOD, C3(40, 36, 30) }), M.SmoothPlastic, 0.25) end
function FLOOR.puddle(p, cf) patch(p, "Puddle", cf, R(1.2, 2.2), C3(34, 44, 50), M.Glass, 0.35, 0.3) end
function FLOOR.bottles(p, cf) for i = 1, rngD:NextInteger(2, 4) do d(p, "Bottle", 0.9, 0.32, 0.32, cf * CFrame.new(R(-1, 1), 0.17, R(-1, 1)) * CFrame.Angles(0, R(0, 6), 0), pick({ C3(60, 96, 60), C3(110, 70, 36), C3(150, 160, 150) }), M.Glass, Enum.PartType.Cylinder) end end
function FLOOR.books(p, cf) for i = 1, rngD:NextInteger(2, 4) do d(p, "Book", 1, 0.25, 0.75, cf * CFrame.new(R(-0.2, 0.2), 0.13 + (i - 1) * 0.25, R(-0.2, 0.2)) * CFrame.Angles(0, R(0, 6), 0), pick(MUTED), M.Fabric) end end
function FLOOR.hay(p, cf) for i = 1, 4 do d(p, "HayTuft", R(1.4, 2.6), 0.18, R(1, 2), cf * CFrame.new(R(-1.2, 1.2), 0.09 + i * 0.03, R(-1.2, 1.2)) * CFrame.Angles(0, R(0, 6), 0), pick({ C3(196, 164, 80), C3(176, 146, 70) }), M.Fabric) end end
function FLOOR.planks(p, cf) for i = 1, rngD:NextInteger(2, 3) do d(p, "BrokenPlank", R(2, 4), 0.2, 0.6, cf * CFrame.new(R(-1, 1), 0.1 + i * 0.1, R(-1, 1)) * CFrame.Angles(0, R(0, 6), R(-0.08, 0.08)), pick({ C3(110, 82, 56), C3(84, 62, 46) }), M.WoodPlanks) end end
function FLOOR.cans(p, cf) for i = 1, rngD:NextInteger(2, 4) do d(p, "Can", 0.5, 0.35, 0.35, cf * CFrame.new(R(-1, 1), 0.18, R(-1, 1)) * CFrame.Angles(0, R(0, 6), 0), pick({ C3(170, 40, 40), C3(160, 164, 168), C3(50, 90, 150) }), M.Metal, Enum.PartType.Cylinder) end end
function FLOOR.petals(p, cf) for i = 1, 9 do d(p, "Petal", 0.25, 0.03, 0.2, cf * CFrame.new(R(-1.8, 1.8), 0.03, R(-1.8, 1.8)) * CFrame.Angles(0, R(0, 6), 0), pick({ C3(200, 60, 70), C3(225, 215, 205), C3(150, 90, 160) }), M.Fabric) end end
function FLOOR.gears(p, cf) for i = 1, rngD:NextInteger(2, 3) do local r = R(0.4, 0.9); d(p, "Gear", 0.22, r * 2, r * 2, cf * CFrame.new(R(-1, 1), 0.12, R(-1, 1)) * CFrame.Angles(0, 0, math.pi / 2), pick({ C3(110, 112, 116), C3(120, 80, 40) }), M.Metal, Enum.PartType.Cylinder) end; for i = 1, 4 do d(p, "Bolt", 0.18, 0.18, 0.18, cf * CFrame.new(R(-1.5, 1.5), 0.09, R(-1.5, 1.5)), IRON, M.Metal) end end
function FLOOR.pills(p, cf) d(p, "PillBottle", 0.7, 0.3, 0.3, cf * CFrame.new(0, 0.16, 0) * CFrame.Angles(0, R(0, 6), 0), C3(200, 120, 40), M.Glass, Enum.PartType.Cylinder); for i = 1, 7 do d(p, "Pill", 0.14, 0.07, 0.08, cf * CFrame.new(R(-0.9, 0.9), 0.04, R(-0.9, 0.9)), pick({ C3(230, 230, 225), C3(190, 60, 60), C3(90, 140, 200) })) end end
function FLOOR.candlestubs(p, cf) for i = 1, 3 do local hh = R(0.25, 0.7); d(p, "CandleStub", 0.3, hh, 0.3, cf * CFrame.new(R(-0.7, 0.7), hh / 2, R(-0.7, 0.7)), C3(225, 215, 190)); end; flatCyl(p, "Wax", 0.7, cf, C3(215, 205, 180), M.SmoothPlastic) end
function FLOOR.ropecoil(p, cf) d(p, "RopeCoil", 0.45, 2.4, 2.4, cf * CFrame.new(0, 0.23, 0) * CFrame.Angles(0, 0, math.pi / 2), C3(150, 124, 84), M.Fabric, Enum.PartType.Cylinder); d(p, "RopeHole", 0.47, 1.3, 1.3, cf * CFrame.new(0, 0.23, 0) * CFrame.Angles(0, 0, math.pi / 2), C3(60, 46, 32), M.Fabric, Enum.PartType.Cylinder) end
function FLOOR.sawdust(p, cf) for i = 1, 3 do d(p, "Sawdust", R(1.4, 2.6), 0.05, R(1, 2.2), cf * CFrame.new(R(-1, 1), 0.03 + i * 0.004, R(-1, 1)) * CFrame.Angles(0, R(0, 6), 0), C3(186, 156, 104), M.Sand) end end
function FLOOR.dollparts(p, cf) d(p, "DollHead", 0.8, 0.8, 0.8, cf * CFrame.new(R(-0.8, 0.8), 0.4, R(-0.8, 0.8)), C3(226, 190, 170), M.SmoothPlastic, Enum.PartType.Ball); for i = 1, 3 do d(p, "DollLimb", 0.9, 0.28, 0.28, cf * CFrame.new(R(-1.2, 1.2), 0.15, R(-1.2, 1.2)) * CFrame.Angles(0, R(0, 6), 0), C3(226, 190, 170), M.SmoothPlastic, Enum.PartType.Cylinder) end end
function FLOOR.shards(p, cf) for i = 1, 7 do d(p, "Shard", R(0.2, 0.6), 0.04, R(0.2, 0.5), cf * CFrame.new(R(-1.3, 1.3), 0.03, R(-1.3, 1.3)) * CFrame.Angles(0, R(0, 6), 0), C3(190, 210, 220), M.Glass).Transparency = 0.4 end end
function FLOOR.tray(p, cf) d(p, "Tray", 1.8, 0.1, 1.2, cf * CFrame.new(0, 0.06, 0) * CFrame.Angles(0, R(0, 6), 0), C3(140, 144, 148), M.Metal); d(p, "Cup", 0.4, 0.35, 0.35, cf * CFrame.new(R(-0.6, 0.6), 0.2, R(-0.4, 0.4)) * CFrame.Angles(0, 0, math.pi / 2), C3(150, 154, 158), M.Metal, Enum.PartType.Cylinder); d(p, "Slop", 0.7, 0.05, 0.5, cf * CFrame.new(R(-0.4, 0.4), 0.13, 0), C3(110, 96, 60)) end
function FLOOR.suitcase(p, cf) local r = cf * CFrame.Angles(0, R(0, 6), 0); d(p, "Suitcase", 2.2, 0.8, 1.5, r * CFrame.new(0, 0.4, 0), pick({ C3(96, 60, 40), C3(50, 60, 80), C3(110, 40, 40) }), M.Leather); d(p, "SuitcaseStrap", 0.25, 0.84, 1.54, r * CFrame.new(-0.5, 0.4, 0), DARK, M.Leather); d(p, "SuitcaseStrap", 0.25, 0.84, 1.54, r * CFrame.new(0.5, 0.4, 0), DARK, M.Leather) end
function FLOOR.fish(p, cf) for i = 1, 3 do local r = cf * CFrame.new(R(-1, 1), 0.12, R(-1, 1)) * CFrame.Angles(0, R(0, 6), 0); d(p, "Fish", 1.1, 0.22, 0.4, r, C3(130, 150, 160), M.SmoothPlastic); d(p, "FishTail", 0.3, 0.2, 0.5, r * CFrame.new(0.65, 0, 0), C3(110, 130, 140)) end end

-- more things to throw
local function explosiveBarrel(cf)
	local m = new("ExplosiveBarrel")
	cyl(m, cf, "Body", 3, 4.2, 0, 2.1, 0, st(M.Metal, nil, C3(170, 30, 26)))
	for _, y in { 0.5, 3.7 } do cyl(m, cf, "Rim", 3.15, 0.3, 0, y, 0, st(M.Metal, nil, C3(40, 36, 34)), DECO) end
	cyl(m, cf, "Band", 3.08, 0.9, 0, 2.1, 0, st(M.Metal, nil, C3(235, 190, 40)), DECO)
	for i = 0, 5 do -- black hazard marks on the yellow band
		local a = i * math.pi / 3
		b(m, cf * CFrame.Angles(0, a, 0), "Mark", 0.45, 0.9, 0.08, 0, 2.1, -1.55, st(M.Metal, nil, C3(24, 22, 20)), DECO)
	end
	cyl(m, cf, "Cap", 0.7, 0.25, 0.7, 4.3, 0.5, st(M.Metal, nil, C3(40, 36, 34)), DECO)
	finalize(m, 2, "Barrel")
	m:SetAttribute("Explosive", true)
	return m
end
local KIT = {
	crate = function(c) return F.crate(c, R(2.6, 3.6)) end,
	barrel = function(c) return F.barrel(c) end,
	chair = function(c) return F.chair(c, pick({ Wd.mid, Wd.dark }), pick({ Fab.red, Fab.green, Fab.brown, Fab.blue })) end,
	stool = function(c) return F.chair(c, st(M.Metal, nil, C3(120, 124, 128))) end,
	side = function(c) return F.sideTable(c, true) end,
	lamp = function(c) return F.floorLamp(c) end,
	bust = function(c) return F.pedestal(c) end,
	bench = function(c) return F.bench(c, 6) end,
}

-- per map: trim colour, light colour, what hangs on the walls, what lies on the floor, what there is to throw,
-- the facade (ivy = old overgrown brick, rust = streaked concrete), beams
local THEMES = {
	Mansion = { trim = C3(64, 44, 34), light = C3(255, 190, 120), wall = { "picture", "picture", "mirror", "sconce", "clock", "shelf", "cracks", "candles" }, floor = { "papers", "books", "rubble", "shards", "stain" }, kit = { "chair", "side", "lamp", "bust", "crate" }, ext = "ivy", beams = false },
	Hospital = { trim = C3(120, 150, 140), light = C3(210, 235, 225), wall = { "board", "lightbox", "firstaid", "pipes", "vent", "clock", "stain", "poster" }, floor = { "papers", "pills", "stain", "puddle", "shards" }, kit = { "stool", "crate", "side", "lamp" }, ext = "rust", beams = false, posters = { C3(60, 120, 110), C3(190, 190, 180), C3(170, 60, 60) } },
	School = { trim = C3(90, 80, 60), light = C3(255, 230, 190), wall = { "poster", "poster", "board", "clock", "shelf", "vent", "cracks" }, floor = { "papers", "books", "cans", "stain" }, kit = { "chair", "chair", "crate", "bench" }, ext = "rust", beams = false, posters = { C3(200, 170, 60), C3(60, 100, 170), C3(170, 60, 50), C3(60, 140, 90) } },
	Church = { trim = C3(60, 40, 34), light = C3(255, 200, 130), wall = { "cross", "candles", "stained", "sconce", "picture", "cracks" }, floor = { "candlestubs", "rubble", "papers", "petals" }, kit = { "bench", "bust", "chair", "lamp" }, ext = "ivy", beams = true, frame = C3(150, 120, 50) },
	Motel = { trim = C3(70, 40, 44), light = C3(255, 150, 190), wall = { "picture", "neon", "mirror", "poster", "stain", "vent", "cracks" }, floor = { "bottles", "cans", "papers", "stain", "suitcase" }, kit = { "chair", "side", "lamp", "crate" }, ext = "rust", beams = false },
	Ship = { trim = C3(60, 44, 32), light = C3(255, 190, 110), wall = { "rope", "lantern", "shelf", "chains", "cracks" }, floor = { "ropecoil", "fish", "planks", "puddle", "bottles" }, kit = { "barrel", "barrel", "crate", "crate", "bench" }, ext = "none", beams = false },
	-- CAMP HOLLOWMERE (no "pills" / "bottles" anywhere: Roblox moderation, CLAUDE.md)
	Camp_Bunkhouse = { trim = C3(62, 44, 32), light = C3(255, 196, 130), wall = { "picture", "shelf", "lantern", "poster", "cracks", "clock", "rope" }, floor = { "papers", "books", "planks", "stain", "cans" }, kit = { "chair", "crate", "bench", "lamp" }, ext = "lamps", beams = false, posters = { C3(80, 110, 70), C3(180, 150, 90), C3(150, 60, 50) } },
	Camp_Boathouse = { trim = C3(58, 46, 36), light = C3(220, 236, 240), wall = { "rope", "lantern", "shelf", "tools", "cracks", "chains" }, floor = { "ropecoil", "fish", "planks", "puddle", "puddle" }, kit = { "barrel", "crate", "crate", "bench" }, ext = "lamps", beams = true },
	Camp_MessHall = { trim = C3(62, 44, 32), light = C3(255, 206, 150), wall = { "poster", "shelf", "clock", "picture", "cracks", "lantern" }, floor = { "papers", "cans", "tray", "stain", "planks" }, kit = { "chair", "chair", "crate", "barrel", "bench" }, ext = "lamps", beams = true, posters = { C3(200, 150, 60), C3(80, 120, 80), C3(170, 60, 50) } },
	Camp_Barn = { trim = C3(220, 214, 200), light = C3(255, 190, 110), wall = { "tools", "lantern", "shelf", "rope", "cracks" }, floor = { "hay", "hay", "planks", "sawdust" }, kit = { "barrel", "crate", "crate", "bench" }, ext = "lamps", beams = true },
	-- Blackwater Harbor
	Harb_Market = { trim = C3(58, 70, 74), light = C3(220, 236, 240), wall = { "rope", "lantern", "shelf", "cracks", "chains", "clock" }, floor = { "fish", "puddle", "puddle", "planks", "ropecoil" }, kit = { "crate", "barrel", "bench" }, ext = "lamps", beams = true },
	Harb_Cannery = { trim = C3(70, 46, 36), light = C3(255, 226, 180), wall = { "tools", "chains", "shelf", "cracks", "lantern" }, floor = { "cans", "cans", "stain", "planks", "puddle" }, kit = { "crate", "barrel", "crate" }, ext = "lamps", beams = true },
	Harb_Lighthouse = { trim = C3(62, 50, 40), light = C3(255, 220, 160), wall = { "picture", "lantern", "shelf", "rope", "clock", "cracks" }, floor = { "papers", "books", "ropecoil", "puddle" }, kit = { "chair", "crate", "barrel", "lamp" }, ext = "lamps", beams = true },
	Harb_NetLoft = { trim = C3(62, 46, 34), light = C3(255, 210, 160), wall = { "rope", "rope", "lantern", "tools", "chains", "shelf" }, floor = { "ropecoil", "fish", "planks", "puddle" }, kit = { "barrel", "crate", "bench" }, ext = "lamps", beams = false },
	Harb_Ship = { trim = C3(40, 32, 26), light = C3(255, 200, 130), wall = { "rope", "lantern", "chains", "shelf", "cracks" }, floor = { "ropecoil", "planks", "puddle", "stain" }, kit = { "barrel", "crate", "chair" }, ext = "lamps", beams = false },
	Camp_Lodge = { trim = C3(62, 44, 32), light = C3(255, 196, 140), wall = { "picture", "picture", "sconce", "clock", "shelf", "plaque", "mirror" }, floor = { "papers", "books", "stain", "shards" }, kit = { "chair", "side", "lamp", "bust" }, ext = "lamps", beams = false, frame = C3(120, 90, 50) },
	-- the Ashen Abbey
	Abb_Cloister = { trim = C3(60, 56, 52), light = C3(255, 200, 140), wall = { "cross", "candles", "stained", "sconce", "cracks", "picture" }, floor = { "candlestubs", "rubble", "petals", "papers" }, kit = { "bench", "bust", "chair" }, ext = "lamps", beams = true, frame = C3(150, 120, 50) },
	Abb_Crypt = { trim = C3(54, 52, 48), light = C3(255, 190, 130), wall = { "candles", "cross", "cracks", "chains", "sconce" }, floor = { "candlestubs", "rubble", "rubble", "stain" }, kit = { "crate", "bench", "bust" }, ext = "lamps", beams = false },
	Abb_Belfry = { trim = C3(56, 40, 30), light = C3(255, 196, 140), wall = { "rope", "lantern", "shelf", "cracks", "chains", "tools" }, floor = { "planks", "ropecoil", "rubble", "sawdust" }, kit = { "crate", "barrel", "bench" }, ext = "lamps", beams = false },
	Abb_Ossuary = { trim = C3(60, 56, 50), light = C3(255, 190, 130), wall = { "candles", "cracks", "chains", "cross" }, floor = { "rubble", "candlestubs", "stain" }, kit = { "crate", "bench", "bust" }, ext = "lamps", beams = false },
	Abb_Nave = { trim = C3(60, 50, 46), light = C3(255, 170, 120), wall = { "cross", "candles", "stained", "sconce", "picture", "cracks" }, floor = { "candlestubs", "rubble", "petals", "papers" }, kit = { "bench", "bust", "chair", "lamp" }, ext = "lamps", beams = false, frame = C3(150, 120, 50) },
	-- the Black Moon (no "pills" / "bottles": Roblox moderation)
	Moon_Dock = { trim = C3(60, 64, 72), light = C3(210, 225, 255), wall = { "pipes", "vent", "lightbox", "board", "clock" }, floor = { "papers", "cans", "stain", "shards" }, kit = { "crate", "stool", "side" }, ext = "lamps", beams = false, posters = { C3(200, 170, 60), C3(60, 100, 170), C3(170, 60, 50) } },
	Moon_Lab = { trim = C3(70, 80, 78), light = C3(210, 255, 225), wall = { "board", "lightbox", "pipes", "vent", "firstaid", "clock" }, floor = { "papers", "shards", "stain", "puddle" }, kit = { "stool", "side", "crate" }, ext = "lamps", beams = false },
	Moon_Reactor = { trim = C3(56, 62, 72), light = C3(200, 235, 255), wall = { "pipes", "pipes", "vent", "lightbox", "board" }, floor = { "cans", "stain", "puddle", "shards" }, kit = { "crate", "barrel", "stool" }, ext = "lamps", beams = false },
	Moon_Control = { trim = C3(64, 60, 68), light = C3(255, 215, 215), wall = { "lightbox", "board", "vent", "clock", "poster" }, floor = { "papers", "papers", "cans", "stain" }, kit = { "stool", "side", "crate" }, ext = "lamps", beams = false, posters = { C3(200, 60, 60), C3(60, 100, 170), C3(220, 220, 220) } },
	Moon_Gate = { trim = C3(54, 48, 66), light = C3(225, 205, 255), wall = { "pipes", "vent", "cracks", "lightbox" }, floor = { "rubble", "shards", "stain" }, kit = { "crate", "stool", "bust" }, ext = "lamps", beams = false },
	Farm = { trim = C3(70, 50, 36), light = C3(255, 190, 110), wall = { "tools", "lantern", "shelf", "rope", "cracks" }, floor = { "hay", "hay", "planks", "sawdust", "bottles" }, kit = { "barrel", "crate", "crate", "bench", "chair" }, ext = "ivy", beams = true },
	Asylum = { trim = C3(52, 42, 36), light = C3(255, 206, 140), wall = { "tally", "chains", "stain", "vent", "cracks", "pipes", "firstaid" }, floor = { "pills", "papers", "stain", "rubble", "puddle" }, kit = { "stool", "crate", "side" }, ext = "ivy", beams = false, stains = { BLOOD, C3(50, 60, 44), C3(60, 50, 34) } },
	Hotel = { trim = C3(70, 30, 26), light = C3(255, 200, 140), wall = { "picture", "picture", "mirror", "sconce", "plaque", "clock" }, floor = { "suitcase", "papers", "shards", "stain", "bottles" }, kit = { "chair", "side", "lamp", "bust", "bench" }, ext = "ivy", beams = false, frame = C3(176, 140, 60) },
	Station = { trim = C3(34, 36, 44), light = C3(196, 222, 255), wall = { "pipes", "vent", "fusebox", "gauge", "hazard", "lightbox", "cracks" }, floor = { "rubble", "puddle", "stain", "cans" }, kit = { "crate", "crate", "barrel", "stool", "bench" }, ext = "rust", beams = false },
	Sewer = { trim = C3(70, 70, 68), light = C3(190, 230, 150), wall = { "pipes", "vent", "fusebox", "stain", "cracks", "chains" }, floor = { "rubble", "puddle", "stain", "cans", "puddle" }, kit = { "crate", "barrel", "bench", "stool" }, ext = "rust", beams = false },
	Prison = { trim = C3(60, 62, 66), light = C3(210, 220, 235), wall = { "pipes", "vent", "tally", "chains", "fusebox", "stain", "cracks" }, floor = { "tray", "rubble", "puddle", "stain", "cans" }, kit = { "stool", "crate", "bench", "barrel" }, ext = "rust", beams = false },
	Factory = { trim = C3(70, 60, 50), light = C3(255, 200, 140), wall = { "pipes", "gauge", "hazard", "fusebox", "vent", "shelf", "poster" }, floor = { "gears", "sawdust", "dollparts", "stain", "planks" }, kit = { "crate", "crate", "barrel", "stool", "lamp" }, ext = "rust", beams = true, stains = { C3(30, 28, 26), C3(60, 44, 24) } },
	Funeral = { trim = C3(50, 36, 44), light = C3(255, 190, 130), wall = { "wreath", "candles", "cross", "picture", "sconce", "mirror" }, floor = { "petals", "candlestubs", "papers", "stain" }, kit = { "chair", "bust", "side", "lamp", "bench" }, ext = "ivy", beams = false },
}

-- Where nothing may be dropped, because the monster has to get through (its pathfinding needs ~6 clear studs):
-- every doorway (read from the wall models: a top "Frame" with no window "Sill" under it) and the map's KeepClear
-- parts (corridors, gallery walks, the floor in front of a stair; maplib's keepClear). Returns a test (x, floorY, z).
local function noGoTest(MP)
	local zones = {}
	local kc = MP:FindFirstChild("KeepClear")
	if kc then
		for _, p in kc:GetChildren() do
			if p:IsA("BasePart") then
				table.insert(zones, { p.Position.X - p.Size.X / 2, p.Position.Z - p.Size.Z / 2, p.Position.X + p.Size.X / 2, p.Position.Z + p.Size.Z / 2, p.Position.Y - p.Size.Y / 2 - 1.5, p.Position.Y + p.Size.Y / 2 })
			end
		end
	end
	local Sx = MP:FindFirstChild("Structure")
	for _, w in (Sx and Sx:GetDescendants() or {}) do
		if w:IsA("Model") then
			local sills = {}
			for _, c in w:GetChildren() do if c:IsA("BasePart") and (c.Name == "Sill" or c.Name == "Glass") then table.insert(sills, c.Position) end end
			for _, f in w:GetChildren() do
				if f:IsA("BasePart") and f.Name == "Frame" and f.Size.Y < 0.75 then
					local alongX = f.Size.X > f.Size.Z
					local half = (alongX and f.Size.X or f.Size.Z) / 2 - 0.6
					local window = false
					for _, sp in sills do if math.abs(sp.X - f.Position.X) < 1 and math.abs(sp.Z - f.Position.Z) < 1 then window = true; break end end
					if not window and half >= 2 then
						local ha, hp = half + 1.5, 6
						local floor = f.Position.Y < 22.5 and 2 or 23
						local x, z = f.Position.X, f.Position.Z
						table.insert(zones, alongX and { x - ha, z - hp, x + ha, z + hp, floor - 1.5, floor + 8 } or { x - hp, z - ha, x + hp, z + ha, floor - 1.5, floor + 8 })
					end
				end
			end
		end
	end
	return function(x, y, z)
		for _, zn in zones do
			if x > zn[1] and x < zn[3] and z > zn[2] and z < zn[4] and y > zn[5] and y < zn[6] then return true end
		end
		return false
	end
end

local function wipe(M)
	local n = 0
	for _, x in M:GetDescendants() do
		if x.Parent and x:GetAttribute("Detail") then x:Destroy(); n += 1 end
	end
	return n
end

local function detail(MP, id) -- (M is Enum.Material in lib2)
	local TH = THEMES[id] or THEMES.Mansion
	local S = MP:FindFirstChild("Structure")
	local DEC = MP:FindFirstChild("Decor") or model(MP, "Decor")
	FURN = MP:FindFirstChild("Furniture")
	if not S or not FURN then return id .. ": no Structure / Furniture" end
	wipe(MP)
	local INT, EXT = S:FindFirstChild("Interior"), S:FindFirstChild("Exterior")
	local DET = model(DEC, "Detail"); DET:SetAttribute("Detail", true)
	local WDET = INT and model(INT, "Detail") or DET -- wall things break with the wall
	WDET:SetAttribute("Detail", true)
	local counts = { trim = 0, wall = 0, beam = 0, floor = 0, prop = 0, boom = 0, ext = 0 }
	local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Include; rp.FilterDescendantsInstances = { S }
	local op = OverlapParams.new(); op.FilterType = Enum.RaycastFilterType.Include; op.FilterDescendantsInstances = { S, FURN, DEC }

	local noGo = noGoTest(MP)
	-- the play area = where the furniture stands
	local mn, mx = Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
	for _, f in FURN:GetChildren() do
		if f:IsA("Model") then local p = f:GetPivot().Position; mn = mn:Min(p); mx = mx:Max(p) end
	end
	if mn.X > mx.X then mn, mx = Vector3.new(-74, 2, -54), Vector3.new(74, 24, 54) end

	-- 1 walls: trim + things hung on them
	local function wallsOf(folder, inwardOnly)
		if not folder then return end
		for _, p in folder:GetDescendants() do
			if p:IsA("BasePart") and not p:IsDescendantOf(WDET) and p.Transparency < 0.5 and p.CFrame.UpVector.Y > 0.99 and p.Size.Y >= 9 then
				local alongX = p.Size.X >= p.Size.Z
				local len, th = math.max(p.Size.X, p.Size.Z), math.min(p.Size.X, p.Size.Z)
				if th >= 0.8 and th <= 2.8 and len >= 4 then
					local along = alongX and p.CFrame.RightVector or p.CFrame.LookVector
					local n = alongX and p.CFrame.LookVector or p.CFrame.RightVector
					local bottom = p.Position.Y - p.Size.Y / 2
					for _, side in { 1, -1 } do
						local out = n * side
						-- outside walls: only the face toward the middle of the house
						if not inwardOnly or out:Dot(Vector3.new(-p.Position.X, 0, -p.Position.Z)) > 0 then
							-- the wall's face (outside walls carry a 0.25 plaster skin inside); +Z = out of the wall
							local face = CFrame.fromMatrix(p.Position + out * (th / 2 + (inwardOnly and 0.26 or 0.01)), Vector3.yAxis:Cross(out), Vector3.yAxis, out)
							local parent = inwardOnly and DET or WDET
							d(parent, "Baseboard", len, 1.1, 0.5, face * CFrame.new(0, -p.Size.Y / 2 + 0.55, 0.25), TH.trim, M.Wood)
							d(parent, "Crown", len, 0.7, 0.36, face * CFrame.new(0, p.Size.Y / 2 - 0.5, 0.18), TH.trim, M.Wood)
							counts.trim += 2
							local slots = math.floor(len / 10)
							for i = 1, slots do
								if rngD:NextNumber() < 0.78 then
									local x = -len / 2 + (i - 0.5) * len / slots + R(-1, 1)
									local kind = pick(TH.wall)
									local y = (kind == "pipes") and 0 or (-p.Size.Y / 2 + R(6.5, 9))
									local ok = pcall(WALL[kind], parent, face * CFrame.new(x, y, 0.02), TH, p.Size.Y)
									if ok then counts.wall += 1 end
								end
							end
						end
					end
				end
			end
		end
	end
	wallsOf(INT, false)
	wallsOf(EXT, true)
	for _, x in WDET:GetDescendants() do x:SetAttribute("Detail", true) end

	-- 2 ceiling beams where there is a ceiling right above (and a floor below)
	if TH.beams then
		for x = math.floor(mn.X / 16) * 16, mx.X, 16 do
			for z = mn.Z, mx.Z, 8 do
				for _, y in { 4, 25 } do
					local floor = workspace:Raycast(Vector3.new(x, y + 3, z + 4), Vector3.new(0, -8, 0), rp)
					local ceil = floor and workspace:Raycast(Vector3.new(x, floor.Position.Y + 3, z + 4), Vector3.new(0, 40, 0), rp)
					if floor and ceil and ceil.Position.Y - floor.Position.Y > 12 then
						d(DET, "Beam", 1.3, 1.1, 8, CFrame.new(x, ceil.Position.Y - 0.55, z + 4), TH.trim, M.Wood)
						counts.beam += 1
					end
				end
			end
		end
	end

	-- 3 a free point on a floor inside (a ceiling above), clear of walls and furniture in a box of `room` studs
	local function spot(room)
		for _ = 1, 40 do
			local x, z = R(mn.X - 2, mx.X + 2), R(mn.Z - 2, mx.Z + 2)
			local y0 = R(mn.Y, mx.Y + 1) + 6
			local down = workspace:Raycast(Vector3.new(x, y0, z), Vector3.new(0, -14, 0), rp)
			if down and down.Instance:FindFirstAncestor("Stairs") then down = nil end -- nothing on the steps
			if down and down.Normal.Y > 0.9 and not (room >= 4 and noGo(x, down.Position.Y, z)) then -- (flat clutter may lie anywhere)
				local fy = down.Position.Y
				if workspace:Raycast(Vector3.new(x, fy + 2, z), Vector3.new(0, 60, 0), rp) then
					local clear = true
					for _, h in workspace:GetPartBoundsInBox(CFrame.new(x, fy + 3, z), Vector3.new(room, 5.2, room), op) do
						if h.Transparency < 1 and h.Position.Y + h.Size.Y / 2 > fy + 0.4 and not h:GetAttribute("Detail") and not (h.Parent and h.Parent:GetAttribute("Detail")) then clear = false; break end
					end
					if clear then return CFrame.new(x, fy, z) end
				end
			end
		end
		return nil
	end
	local area = math.max(1, (mx.X - mn.X) * (mx.Z - mn.Z))
	for _ = 1, math.clamp(math.floor(area / 150), 40, 130) do
		local cf = spot(3)
		if cf then
			if pcall(FLOOR[pick(TH.floor)], DET, cf, TH) then counts.floor += 1 end
		end
	end

	-- 4 props to throw + explosive barrels (never right at the players' spawn)
	local spawnAt = MP:GetAttribute("SpawnInside") or Vector3.new(0, 5, 46)
	local made = {}
	local function prop(make, gap)
		for _ = 1, 12 do
			local cf = spot(7)
			if cf then
				local okSpot = (cf.Position - spawnAt).Magnitude > gap
				for _, q in made do if (q - cf.Position).Magnitude < 9 then okSpot = false end end
				if okSpot then
					local ok, m = pcall(make, cf * CFrame.Angles(0, R(0, 6.28), 0))
					if ok and m then
						m:SetAttribute("Detail", true)
						table.insert(made, cf.Position)
						return true
					end
				end
			end
		end
		return false
	end
	for _ = 1, math.clamp(math.floor(area / 700), 12, 26) do
		if prop(KIT[pick(TH.kit)], 10) then counts.prop += 1 end
	end
	for _ = 1, 5 do
		if prop(explosiveBarrel, 26) then counts.boom += 1 end
	end

	-- 5 outside: downpipes at the corners, chimneys / vents on the roof, ivy or rust on the facade, wall lamps
	if EXT and TH.ext ~= "none" then
		local ecf, esz = EXT:GetBoundingBox()
		local hx, hz, top, base = esz.X / 2, esz.Z / 2, ecf.Position.Y + esz.Y / 2, ecf.Position.Y - esz.Y / 2
		local c = ecf.Position
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				d(DET, "Downpipe", 0.7, esz.Y, 0.7, CFrame.new(c.X + sx * (hx - 3.2), c.Y, c.Z + sz * (hz + 0.5)), IRON, M.Metal)
				d(DET, "Gutter", 1, 0.6, 1.4, CFrame.new(c.X + sx * (hx - 3.2), top - 0.3, c.Z + sz * (hz + 0.7)), IRON, M.Metal)
				counts.ext += 2
			end
		end
		-- (ext = "lamps": the campaign buildings draw their own outsides - only downpipes and wall lamps here)
		for i = 1, (TH.ext == "lamps" and 0 or 3) do
			local x, z = c.X + R(-hx * 0.7, hx * 0.7), c.Z + R(-hz * 0.5, hz * 0.5)
			local roof = workspace:Raycast(Vector3.new(x, top + 60, z), Vector3.new(0, -90, 0), rp)
			if roof then
				if TH.ext == "ivy" then
					d(DET, "Chimney", 4, 9, 4, CFrame.new(x, roof.Position.Y + 3, z), C3(110, 70, 58), M.Brick)
					d(DET, "ChimneyCap", 4.8, 0.7, 4.8, CFrame.new(x, roof.Position.Y + 7.8, z), C3(60, 56, 54), M.Slate)
				else
					d(DET, "RoofVent", 5, 3, 5, CFrame.new(x, roof.Position.Y + 1.5, z), C3(110, 114, 118), M.Metal)
					d(DET, "RoofVentCap", 5.6, 0.5, 5.6, CFrame.new(x, roof.Position.Y + 3.3, z), C3(70, 72, 76), M.Metal)
					d(DET, "RoofPipe", 0.8, 5, 0.8, CFrame.new(x + 3.6, roof.Position.Y + 2.5, z), IRON, M.CorrodedMetal)
				end
				counts.ext += 2
			end
		end
		-- the front, the back and the sides
		local faces = { { Vector3.new(0, 0, 1), hz, hx }, { Vector3.new(0, 0, -1), hz, hx }, { Vector3.new(1, 0, 0), hx, hz }, { Vector3.new(-1, 0, 0), hx, hz } }
		for _, f in faces do
			local n, depth, half = f[1], f[2], f[3]
			local right = Vector3.yAxis:Cross(n)
			-- a w x h patch only goes where solid outside wall is behind its whole face (never across a doorway or a
			-- window): returns its centre flush on the wall, or nil
			local function onWall(p0, w, h)
				local centre = nil
				for _, o in { { 0, 0 }, { -w / 2, -h / 2 }, { w / 2, -h / 2 }, { -w / 2, h / 2 }, { w / 2, h / 2 } } do
					local from = p0 + right * (o[1] * 0.9) + Vector3.yAxis * (o[2] * 0.9) + n * 4
					local hit = workspace:Raycast(from, -n * 8, rp)
					if not hit or (hit.Instance.Name ~= "Wall" and hit.Instance.Name ~= "Gable") or not hit.Instance:IsDescendantOf(EXT.Parent) then return nil end
					centre = centre or hit.Position
				end
				return centre
			end
			for i = 1, (TH.ext == "lamps" and 0 or 9) do
				local t = R(-half + 6, half - 6)
				local at = c + n * (depth + 0.12) + right * t
				if TH.ext == "ivy" then
					local hgt = R(6, esz.Y * 0.8)
					for k = 1, 5 do
						local w, h = R(1.6, 3.4), R(1.6, 3.6)
						local ip = onWall(Vector3.new(at.X, base + R(0, hgt), at.Z) + right * R(-2.5, 2.5), w, h)
						if ip then
							ip += n * 0.13
							d(DET, "Ivy", w, h, 0.25, CFrame.lookAt(ip, ip + n) * CFrame.Angles(0, 0, R(-0.3, 0.3)), pick({ C3(40, 70, 40), C3(32, 58, 36), C3(52, 82, 44) }), M.Sand)
							counts.ext += 1
						end
					end
				else
					local w, h = R(0.8, 2), R(5, esz.Y * 0.5)
					local rp2 = onWall(Vector3.new(at.X, top - R(5, 11), at.Z), w, h)
					if rp2 then
						rp2 += n * 0.06
						local s = d(DET, "RustStreak", w, h, 0.1, CFrame.lookAt(rp2, rp2 + n), pick({ C3(110, 60, 30), C3(70, 50, 36), C3(50, 52, 50) }))
						s.Transparency = 0.35
						counts.ext += 1
					end
				end
			end
			for _, t in { -half * 0.5, half * 0.5 } do -- a wall lamp either side of each face
				local at = c + n * (depth + 0.5) + right * t
				local lamp = d(DET, "WallLamp", 1, 1.2, 1, CFrame.new(at.X, base + 13, at.Z), TH.light, M.Neon)
				d(DET, "WallLampHood", 1.6, 0.3, 1.6, CFrame.new(at.X, base + 13.8, at.Z), IRON, M.Metal)
				glowLight(lamp, 26, 0.9, TH.light)
				counts.ext += 2
			end
		end
	end
	for _, x in DET:GetDescendants() do x:SetAttribute("Detail", true) end
	local parts = 0
	for _, x in MP:GetDescendants() do if x:IsA("BasePart") then parts += 1 end end
	return string.format("%s: trim %d, wall things %d, beams %d, floor clutter %d, props %d, explosive barrels %d, outside %d | %d parts, %d furniture",
		id, counts.trim, counts.wall, counts.beam, counts.floor, counts.prop, counts.boom, counts.ext, parts, #FURN:GetChildren())
end

-- the Mansion is live in workspace; the others are copied into workspace for the raycasts, then put back
local out = {}
local temp = Instance.new("Folder"); temp.Name = "_DetailTemp"; temp.Parent = workspace
local maps = SSd:FindFirstChild("Maps")
if TARGET == "Mansion" or TARGET == "ALL" then
	local m = workspace:FindFirstChild("Mansion")
	if m then table.insert(out, detail(m, "Mansion")) end
end
if maps then
	for _, src in maps:GetChildren() do
		if (TARGET == "ALL" or src.Name == TARGET) and src.Name ~= "Mansion" then
			local copy = src:Clone()
			copy.Parent = temp
			local ok, res = pcall(detail, copy, src.Name)
			table.insert(out, ok and res or (src.Name .. " FAILED: " .. tostring(res)))
			if ok then
				src:Destroy()
				copy.Parent = maps
			end
		end
	end
end
temp:Destroy()
return table.concat(out, "\n")
