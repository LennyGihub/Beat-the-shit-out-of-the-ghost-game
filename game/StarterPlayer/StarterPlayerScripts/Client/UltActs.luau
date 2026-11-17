--!strict
-- UltActs: what each ultimate ACTION looks like (see Shared/Ultimates for the action list), built from UltKit's
-- blocks. Server events: shock, strike, freeze, timeStop, timeResume, onePunch, fling. Started by the cast on the
-- client itself (UltFx reads the ultimate's actions): vortex, launch, burn, slow, heal, stamina, giant.
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Kit = require(script.Parent.UltKit)
local Sfx = require(script.Parent.Sfx)

local Acts = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Fx: any -- set by init (shake / kick)
local HUD: any
local E = Kit.ease
local rand = Kit.rand
local UP = Vector3.yAxis
local SP = Enum.Material.SmoothPlastic
local function rgb(r: number, g: number, b: number): Color3 return Color3.fromRGB(r, g, b) end
local WHITE = Color3.new(1, 1, 1)
local FIRE = { rgb(255, 225, 100), rgb(255, 140, 40), rgb(230, 60, 20) }
local SMOKE = { rgb(62, 58, 56), rgb(42, 40, 40), rgb(84, 78, 74) }
local ROCK = { rgb(92, 80, 68), rgb(70, 62, 56), rgb(112, 100, 86) }
local ICE = { rgb(120, 190, 235), rgb(78, 150, 215), rgb(170, 222, 245) }
local DUST = { rgb(196, 180, 150), rgb(170, 156, 132), rgb(214, 204, 180) }
local WOOD = { rgb(120, 84, 52), rgb(92, 64, 40), rgb(150, 110, 70) }

-- three shades of an ultimate's colour
local function tint(c: Color3): { Color3 }
	return { c:Lerp(WHITE, 0.6), c, c:Lerp(Color3.new(0, 0, 0), 0.35) }
end
Acts.tint = tint

local function ghost(): (Model?, BasePart?)
	local g = workspace:FindFirstChild("Ghost")
	local hrp = g and g:FindFirstChild("HumanoidRootPart")
	if g and g:IsA("Model") and hrp and hrp:IsA("BasePart") then return g, hrp end
	return nil, nil
end
Acts.ghost = ghost
-- the monster's rough size (monsters go from a small goblin to a giant)
local function ghostSize(g: Model): Vector3
	local s = g:GetExtentsSize()
	return Vector3.new(math.clamp(math.max(s.X, s.Z), 3, 14), math.clamp(s.Y, 5, 22), 0)
end

-- one shared picture grade (time stop, bullet time, blood moon); the last caller wins
local gradeFx: ColorCorrectionEffect
local gradeToken = 0
local function grade(props: { [string]: any }, dur: number, fadeIn: number?)
	gradeToken += 1
	local tk = gradeToken
	Kit.tween(gradeFx, fadeIn or 0.15, props)
	Kit.after(dur, function()
		if tk == gradeToken then Kit.tween(gradeFx, 0.5, { Saturation = 0, Contrast = 0, Brightness = 0, TintColor = WHITE }) end
	end)
end
Acts.grade = grade

local function flash(pos: Vector3, color: Color3, amount: number, range: number)
	local d = Kit.dist(pos)
	if d < range and HUD then HUD.flash(color, amount * (1 - d / range * 0.7)) end
end

-- a puff of block flames that rise and shrink
local function flames(pos: Vector3, n: number, s: number, colors: { Color3 }?, spread: number?)
	Kit.chunks(pos, n, { colors = colors or FIRE, smin = 0.5 * s, smax = 1.2 * s, speed = 4 * s, up = 7 * s, g = -22, life = 0.7, spread = spread or s, spin = 0.6 })
end
Acts.flames = flames
local function rubble(pos: Vector3, n: number, speed: number, floorY: number?, colors: { Color3 }?, s: number?)
	local k: number = s or 1
	Kit.chunks(pos, n, { colors = colors or ROCK, mat = SP, smin = 0.4 * k, smax = 1.2 * k, speed = speed, up = 30 + speed * 0.3, floor = floorY, life = 1.5 })
end
local function scorch(floor: Vector3, s: number)
	local p = Kit.part(Vector3.new(s, 0.08, s), CFrame.new(floor + UP * 0.05) * CFrame.Angles(0, rand(0, 3), 0), rgb(16, 14, 13), SP, 0.15)
	local q = Kit.part(Vector3.new(s * 0.75, 0.08, s * 0.75), CFrame.new(floor + UP * 0.07) * CFrame.Angles(0, rand(0, 3), 0), rgb(10, 9, 9), SP, 0.1)
	Kit.fade(p, 4, 1.5); Kit.fade(q, 4, 1.5)
end

-- SHOCKWAVES -------------------------------------------------------------------------------------------
local SHOCK: { [string]: string } = {
	Rage = "rage", GroundPound = "rock", StreetSweeper = "dust", Bulldozer = "rock", Hellfire = "fire", IceAge = "ice",
	AbsoluteZero = "ice", Armageddon = "fire", Earthquake = "quake", Supernova = "nova", Ragnarok = "rage", Colossus = "rock",
	GhostNuke = "nuke", explode = "pop",
}
local shocks: { [string]: (center: Vector3, floor: Vector3, r: number, color: Color3) -> () } = {}

function shocks.rage(center, floor, r, color)
	Kit.ring(floor, { r0 = 1.5, r1 = r, n = 20, h = 2.4, h1 = 0.5, w = 1.1, color = color, dur = 0.55 })
	Kit.after(0.07, function() Kit.ring(floor, { r0 = 1, r1 = r * 0.8, n = 20, h = 1, h1 = 0.2, w = 0.6, color = color:Lerp(WHITE, 0.7), dur = 0.5 }) end)
	Kit.poly(floor + UP * 1.5, 2, r * 0.45, color, 0.4, { tr = 0.25 })
	Kit.cracks(floor, r * 0.55, 9, color)
	rubble(floor + UP, 16, r * 1.1, floor.Y)
	Kit.chunks(floor + UP, 14, { colors = tint(color), smin = 0.25, smax = 0.6, speed = r * 1.4, up = 26, life = 0.7 })
	Kit.light(floor + UP * 3, color, 40, 6, 0.5)
	Sfx.at("PunchHeavy", center, { PlaybackSpeed = 0.5, Volume = 1.1 })
	Kit.near(center, 0.5 + r / 100, r * 2.5)
end

-- the floor breaks: slabs of rock jump up in rings running outward
function shocks.rock(center, floor, r, color)
	for k = 1, 3 do
		Kit.after((k - 1) * 0.07, function()
			Kit.spikes(floor, { r = r * 0.27 * k, n = 5 + k * 3, h = 2 + k * 1.3, w = 1.8 + k * 0.5, tilt = 0.55, colors = ROCK, life = 1.7 - k * 0.2, stagger = 0.05 })
		end)
	end
	Kit.ring(floor, { r0 = 1, r1 = r, n = 18, h = 1.8, h1 = 0.4, w = 1.4, color = DUST[1], mat = SP, tr = 0.35, dur = 0.7 })
	Kit.ring(floor, { r0 = 1, r1 = r * 0.9, n = 18, h = 0.5, w = 0.5, color = color, dur = 0.45 })
	Kit.cracks(floor, r * 0.7, 11, nil, 5)
	rubble(floor + UP, 26, r * 1.0, floor.Y)
	Sfx.at("Crash", center, { PlaybackSpeed = 0.6, Volume = 1.2 })
	Sfx.at("PunchHeavy", center, { PlaybackSpeed = 0.4, Volume = 1.1 })
	Kit.near(center, 0.6 + r / 90, r * 2.5)
end

-- a wall of dust that sweeps the room clean
function shocks.dust(center, floor, r, color)
	Kit.ring(floor, { r0 = 2, r1 = r, n = 18, h = 7, h1 = 2, w = 1.2, color = DUST[1], mat = SP, tr = 0.25, dur = 0.6, ease = E.out })
	Kit.after(0.06, function() Kit.ring(floor, { r0 = 1, r1 = r * 0.9, n = 18, h = 4, h1 = 1, w = 0.9, color = DUST[2], mat = SP, tr = 0.35, dur = 0.6 }) end)
	Kit.after(0.12, function() Kit.ring(floor, { r0 = 1, r1 = r * 0.8, n = 18, h = 1.2, h1 = 0.3, w = 0.6, color = color, dur = 0.55 }) end)
	Kit.chunks(floor + UP * 1.5, 40, { colors = DUST, mat = SP, smin = 0.25, smax = 0.7, speed = r * 2.2, up = 10, g = 25, drag = 1.2, life = 1.1, slab = true })
	Sfx.at("Whoosh", center, { PlaybackSpeed = 0.5, Volume = 1.6 })
	Sfx.at("PunchHeavy", center, { PlaybackSpeed = 0.6, Volume = 0.9 })
	Kit.near(center, 0.45, r * 2.5)
end

-- rings of block flames marching outward and burning on
function shocks.fire(center, floor, r, color)
	local pal = { FIRE[1], color, FIRE[3] }
	Kit.ring(floor, { r0 = 1.5, r1 = r, n = 20, h = 3, h1 = 0.6, w = 1.2, color = FIRE[1], color1 = FIRE[3], dur = 0.6 })
	Kit.poly(floor + UP * 2, 2, r * 0.5, FIRE[2], 0.45, { tr = 0.2, color1 = FIRE[3] })
	for wave = 0, 9 do
		Kit.after(wave * 0.11, function()
			local rr = r * math.min(1, 0.25 + wave * 0.16)
			local n = math.floor(6 + rr * 0.5)
			local ph = rand(0, 6.3)
			for i = 1, n do
				local a = ph + i / n * math.pi * 2
				flames(floor + Vector3.new(math.cos(a) * rr, 0.6, math.sin(a) * rr), 2, 1.3, pal, 0.8)
			end
		end)
	end
	Kit.cracks(floor, r * 0.5, 8, FIRE[2])
	scorch(floor, r * 0.5)
	Kit.light(floor + UP * 4, FIRE[2], 50, 7, 1.2)
	Sfx.at("Flamethrower", center, { PlaybackSpeed = 0.8, Volume = 1.2 })
	Sfx.at("Explosion", center, { PlaybackSpeed = 0.7, Volume = 0.9 })
	Kit.near(center, 0.5 + r / 100, r * 2.5)
end

-- ice crystals burst out of a frosted floor, stand a moment, then shatter
function shocks.ice(center, floor, r, color)
	local waves = r > 40 and 5 or 4
	for k = 1, waves do
		Kit.after((k - 1) * 0.08, function()
			Kit.spikes(floor, { r = r / waves * k * 0.9, n = 5 + k * 3, h = 2.5 + k * 1.2, w = 1.1 + k * 0.25, tilt = 0.35, colors = ICE, mat = SP,
				tr = 0.12, life = 2.6 - k * 0.2, crystal = true, shatter = true, stagger = 0.06 })
		end)
	end
	Kit.ring(floor, { r0 = 1, r1 = r, n = 22, h = 0.14, w = 2.2, color = rgb(120, 170, 205), mat = SP, tr = 0.5, dur = 2.8, ease = E.out3, hold = 0.75 })
	Kit.ring(floor, { r0 = 1, r1 = r, n = 22, h = 2, h1 = 0.4, w = 0.9, color = color, dur = 0.55 })
	Kit.chunks(floor + UP * 2, 26, { colors = ICE, mat = Enum.Material.Ice, smin = 0.2, smax = 0.5, speed = r * 0.9, up = 22, g = 30, life = 1.4, slab = true })
	Kit.light(floor + UP * 4, ICE[2], 40, 1.6, 1)
	Sfx.at("Glass", center, { PlaybackSpeed = 0.5, Volume = 1.3 })
	Sfx.at("PunchHeavy", center, { PlaybackSpeed = 0.55, Volume = 1 })
	Kit.after(2.4, function() Sfx.at("Glass", center, { PlaybackSpeed = 1.2, Volume = 0.8 }) end)
	Kit.near(center, 0.5 + r / 100, r * 2.5)
end

-- an earthquake pulse: long cracks, heaving slabs, and the ceiling rains rubble
function shocks.quake(center, floor, r, color)
	Kit.cracks(floor, r * 0.8, 8, color, 5)
	Kit.spikes(floor, { r = r * 0.35, n = 9, h = 3.5, w = 2.6, tilt = 0.7, colors = ROCK, life = 1.2, jitter = 0.6, stagger = 0.15 })
	Kit.ring(floor, { r0 = 1, r1 = r, n = 20, h = 1.2, h1 = 0.3, w = 1.6, color = ROCK[3], mat = SP, tr = 0.2, dur = 0.8 })
	rubble(floor + UP, 20, r * 0.8, floor.Y, nil, 1.3)
	local top = math.min(Kit.ceiling(center, 30), center.Y + 26) - 0.5
	for _ = 1, 16 do
		local a, d = rand(0, 6.3), rand(2, r * 0.6)
		Kit.chunks(Vector3.new(center.X + math.cos(a) * d, top, center.Z + math.sin(a) * d), 2, { colors = DUST, mat = SP, smin = 0.3, smax = 0.9, speed = 2, up = 0, g = 70, floor = floor.Y, life = 1.6 })
	end
	Sfx.at("Crash", center, { PlaybackSpeed = 0.45, Volume = 1.4 })
	Sfx.at("PunchHeavy", center, { PlaybackSpeed = 0.35, Volume = 1.2 })
	Kit.near(center, 0.9, r * 3)
end

-- a star goes off: white core, hard rays, two crossing rings
function shocks.nova(center, floor, r, color)
	local c = center + UP
	Kit.poly(c, 3, r * 0.6, WHITE, 0.55, { tr = 0, color1 = color, n = 4, spin = 2.5 })
	Kit.poly(c, 2, r * 0.4, color, 1.0, { tr = 0.3, color1 = FIRE[3] })
	for _ = 1, 16 do
		local dir = Kit.rng:NextUnitVector()
		dir = Vector3.new(dir.X, math.abs(dir.Y) * 0.6, dir.Z).Unit
		local len = r * rand(0.5, 0.9)
		local p = Kit.part(Vector3.new(0.9, 0.9, 1), CFrame.lookAt(c, c + dir), WHITE)
		Kit.loop(0.6, function(a)
			local l = len * E.out3(a)
			p.Size = Vector3.new(0.9 * (1 - a), 0.9 * (1 - a), l)
			p.CFrame = CFrame.lookAt(c + dir * l / 2, c + dir * l)
			if a >= 1 then p:Destroy() end
			return nil
		end)
	end
	Kit.ring(floor, { r0 = 2, r1 = r, n = 24, h = 4, h1 = 0.6, w = 1.6, color = WHITE, color1 = color, dur = 0.7 })
	Kit.ring(CFrame.new(c) * CFrame.Angles(0.6, 0, 0.3), { r0 = 2, r1 = r * 0.8, n = 24, h = 0.8, w = 0.8, color = color, dur = 0.6, lift = false })
	Kit.cracks(floor, r * 0.4, 12, color, 5)
	Kit.chunks(c, 50, { colors = tint(color), smin = 0.3, smax = 0.9, speed = r * 1.3, up = 40, g = 40, life = 1.3 })
	rubble(floor + UP, 20, r * 0.9, floor.Y)
	Kit.light(c + UP * 3, color, 60, 10, 1.4)
	flash(center, WHITE, 0.7, r * 2)
	Sfx.at("Explosion", center, { PlaybackSpeed = 0.55, Volume = 1.8 })
	Sfx.at("Ultimate", center, { PlaybackSpeed = 0.7, Volume = 1.2 })
	Kit.near(center, 1.2, r * 3)
end

-- the blast wave of the nuke: a tall wall of dust rolling over the whole house
function shocks.nuke(center, floor, r, color)
	Kit.ring(floor, { r0 = 6, r1 = r, n = 26, h = 9, h1 = 3, w = 3, color = DUST[1], mat = SP, tr = 0.3, dur = 1.5, ease = E.out })
	Kit.ring(floor, { r0 = 4, r1 = r * 0.9, n = 26, h = 1.5, w = 1.2, color = color, dur = 1.1 })
	Kit.chunks(floor + UP * 2, 40, { colors = DUST, mat = SP, smin = 0.4, smax = 1.2, speed = 90, up = 20, g = 40, drag = 0.8, life = 1.6, slab = true })
end

-- an explosive punch: a small hard pop
function shocks.pop(center, _floor, r, color)
	Kit.poly(center, 1, r * 0.8, FIRE[1], 0.3, { tr = 0.1, color1 = color })
	Kit.ring(CFrame.new(center) * CFrame.Angles(rand(-0.5, 0.5), 0, rand(-0.5, 0.5)), { r0 = 0.5, r1 = r * 0.7, n = 12, h = 0.5, w = 0.5, color = color, dur = 0.3, lift = false })
	Kit.chunks(center, 9, { colors = { FIRE[1], color, SMOKE[1] }, smin = 0.25, smax = 0.6, speed = 26, up = 18, life = 0.6 })
	Kit.light(center, color, 24, 4, 0.25)
	Sfx.at("Explosion", center, { PlaybackSpeed = 1.15, Volume = 0.5 })
	Kit.near(center, 0.25, 50)
end

function Acts.shock(center: Vector3, r: number, color: Color3, id: string?)
	local style = SHOCK[id or ""] or "rage"
	shocks[style](center, style == "pop" and center or Kit.floor(center), r, color)
end

-- STRIKES ----------------------------------------------------------------------------------------------
local function boltPath(top: Vector3, to: Vector3, w: number, color: Color3, life: number)
	local pts = { top }
	local n = 8
	for i = 1, n - 1 do
		local a = i / n
		local j = 1 + 3.5 * math.sin(a * math.pi)
		table.insert(pts, top:Lerp(to, a) + Vector3.new(rand(-j, j), 0, rand(-j, j)))
	end
	table.insert(pts, to)
	local white = color:Lerp(WHITE, 0.75)
	for i = 1, #pts - 1 do
		local ww = w * (1.25 - i / #pts * 0.5)
		Kit.fade(Kit.line(pts[i], pts[i + 1], ww, i % 2 == 0 and white or color), life * 0.4, life * 0.6)
	end
	for _ = 1, 2 do -- forks
		local at = pts[Kit.rng:NextInteger(3, n - 1)]
		for _ = 1, 3 do
			local nxt = at + Vector3.new(rand(-4, 4), rand(-5, -2), rand(-4, 4))
			Kit.fade(Kit.line(at, nxt, w * 0.45, white), 0, life * 0.8)
			at = nxt
		end
	end
end

local function lightning(to: Vector3, color: Color3, big: boolean)
	local floor = Kit.floor(to)
	local top = floor + Vector3.new(rand(-10, 10), 62, rand(-10, 10))
	local w = big and 0.7 or 0.45
	boltPath(top, floor, w, color, 0.14)
	Kit.after(0.08, function() boltPath(top, floor, w * 0.6, color, 0.2) end) -- the flicker of a second stroke
	Kit.poly(floor + UP, 1.5, big and 12 or 8, WHITE, 0.25, { tr = 0.05, color1 = color })
	Kit.ring(floor, { r0 = 0.5, r1 = big and 9 or 6, n = 12, h = 0.4, w = 0.5, color = color, dur = 0.3 })
	Kit.chunks(floor + UP * 0.5, big and 14 or 9, { colors = { WHITE, color }, smin = 0.15, smax = 0.4, speed = 24, up = 26, floor = floor.Y, life = 0.8 })
	scorch(floor, big and 5 or 3.5)
	Kit.light(floor + UP * 2, color, 45, 4, 0.25)
	Sfx.at("TaserZap", floor, { PlaybackSpeed = rand(0.7, 1.1), Volume = 0.8 })
	Sfx.at("Explosion", floor, { PlaybackSpeed = rand(1, 1.25), Volume = big and 0.75 or 0.55 })
	Kit.near(floor, big and 0.45 or 0.35, 60)
end

-- a tumbling rock of blocks with a hot core, a trail of fire and smoke, a target on the floor, and a crater
local function meteor(to: Vector3, color: Color3, size: number, dur: number)
	local floor = Kit.floor(to)
	local from = floor + Vector3.new(rand(-30, 30), 90, rand(-30, 30))
	local pal = { FIRE[1], color, FIRE[3] }
	Kit.ring(floor + UP * 0.1, { r0 = size * 2.2, r1 = size * 0.6, n = 4, h = 0.12, w = 0.4, color = rgb(255, 40, 20), dur = dur, ease = E.inq, spin = 3, hold = 0.95, fill = 0.75 })
	local shapes = {
		{ CFrame.new(), Vector3.one * size, rgb(48, 40, 38), SP },
		{ CFrame.new(size * 0.3, size * 0.2, 0) * CFrame.Angles(0.6, 0.4, 0.2), Vector3.one * size * 0.7, rgb(64, 52, 46), SP },
		{ CFrame.new(-size * 0.25, -size * 0.2, size * 0.2) * CFrame.Angles(0.2, 0.9, 0.5), Vector3.one * size * 0.75, rgb(40, 34, 32), SP },
		{ CFrame.Angles(math.pi / 4, math.pi / 4, 0), Vector3.one * size * 0.9, FIRE[2], Enum.Material.Neon },
	}
	local parts: { Part } = {}
	for i, s in shapes do parts[i] = Kit.part(s[2] :: Vector3, CFrame.new(from), s[3] :: Color3, s[4] :: Enum.Material) end
	local acc = 0
	local sx, sy = rand(4, 8), rand(4, 8)
	Kit.loop(dur, function(a, dt)
		local pos = from:Lerp(floor + UP * size * 0.4, a * a)
		local rot = CFrame.new(pos) * CFrame.Angles(a * sx, a * sy, 0)
		for i, p in parts do p.CFrame = rot * (shapes[i][1] :: CFrame) end
		acc += dt
		if acc > 0.03 then
			acc = 0
			Kit.chunks(pos, 2, { colors = pal, smin = size * 0.3, smax = size * 0.6, speed = 3, up = 3, g = -6, life = 0.4, spread = size * 0.3 })
			Kit.chunks(pos, 1, { colors = SMOKE, mat = SP, tr = 0.3, smin = size * 0.4, smax = size * 0.8, speed = 2, up = 2, g = -3, life = 0.8, spread = size * 0.3 })
		end
		if a >= 1 then
			for _, p in parts do p:Destroy() end
			Kit.poly(floor + UP * 1.5, size, size * 5, FIRE[1], 0.45, { tr = 0.05, color1 = FIRE[3] })
			Kit.ring(floor, { r0 = 1, r1 = size * 3.5, n = 14, h = 1.6, h1 = 0.3, w = 0.8, color = color, dur = 0.4 })
			Kit.spikes(floor, { r = size * 1.1, n = 7, h = size * 0.7, w = size * 0.55, tilt = 0.9, colors = { rgb(48, 40, 38), rgb(64, 52, 46) }, life = 3 })
			rubble(floor + UP, 10, 30, floor.Y, { rgb(48, 40, 38), rgb(64, 52, 46) })
			flames(floor + UP, 12, size * 0.4, pal, size * 0.8)
			scorch(floor, size * 2)
			Kit.cracks(floor, size * 2.2, 6, FIRE[2], 3.5)
			Kit.light(floor + UP * 3, FIRE[2], 45, 7, 0.6)
			Sfx.at("Explosion", floor, { Volume = math.min(1.6, 0.6 + size / 10) })
			Kit.near(floor, math.min(1.2, 0.3 + size / 15), 80 + size * 5)
		end
		return nil
	end)
end

-- a holy beam: a halo closes on the floor, then an eight-sided pillar of light slams down through it
local function holy(to: Vector3, color: Color3, grand: boolean)
	local floor = Kit.floor(to)
	local w = grand and 8 or 5.5
	local pale = color:Lerp(WHITE, 0.5)
	Kit.ring(floor + UP * 0.1, { r0 = w * 1.6, r1 = w * 0.55, n = 16, h = 0.14, w = 0.5, color = color, dur = 0.34, ease = E.inq, hold = 0.95, spin = 1.5 })
	local thin = Kit.part(Vector3.new(0.25, 90, 0.25), CFrame.new(floor + UP * 45), pale, nil, 0.3)
	Kit.kill(thin, 0.3)
	Kit.after(0.28, function()
		Kit.column(floor, w * 0.25, w, 90, pale, 0.75, 0.12, 0.5)
		for i = 1, 4 do -- an eight-point star on the floor
			local s = Kit.part(Vector3.new(0.5, 0.1, w * 2.4), CFrame.new(floor + UP * 0.08) * CFrame.Angles(0, i * math.pi / 4, 0), color)
			Kit.fade(s, 0.5, 0.7)
		end
		for i = 1, 3 do
			Kit.after(i * 0.07, function()
				Kit.ring(floor + UP * (16 - i * 4.5), { r0 = w * 0.5, r1 = w * (0.9 + i * 0.25), n = 12, h = 0.35, w = 0.4, color = color, dur = 0.45, lift = false })
			end)
		end
		Kit.chunks(floor + UP * 0.5, grand and 20 or 12, { colors = { pale, WHITE }, smin = 0.15, smax = 0.4, speed = 5, up = 14, g = -10, life = 1.1, spread = w * 0.6 })
		Kit.light(floor + UP * 5, color, 50, 8, 0.7)
		Sfx.at("Ultimate", floor, { PlaybackSpeed = 1.1, Volume = 0.7 })
		Sfx.at("PunchHeavy", floor, { PlaybackSpeed = 0.8, Volume = 0.7 })
		Kit.near(floor, grand and 0.45 or 0.3, 55)
	end)
end

-- the nuke: a fat bomb drops on a blinking target, then a white flash, a fireball and a mushroom cloud of blocks
local function nuke(to: Vector3, color: Color3)
	local floor = Kit.floor(to)
	local dur = 1.6
	local red = rgb(255, 30, 20)
	Kit.ring(floor + UP * 0.1, { r0 = 16, r1 = 5, n = 4, h = 0.14, w = 0.6, color = red, dur = dur, ease = E.inq, spin = 5, hold = 0.97, fill = 0.7 })
	Kit.ring(floor + UP * 0.1, { r0 = 9, r1 = 2.5, n = 8, h = 0.14, w = 0.4, color = red, dur = dur, ease = E.inq, spin = -4, hold = 0.97, fill = 0.5 })
	local steel, dark = rgb(70, 82, 64), rgb(40, 44, 40)
	local shapes = {
		{ CFrame.new(), Vector3.new(3.4, 7, 3.4), steel },
		{ CFrame.new(0, -4.3, 0), Vector3.new(2.6, 1.6, 2.6), steel },
		{ CFrame.new(0, -5.6, 0), Vector3.new(1.6, 1, 1.6), rgb(210, 190, 40) },
		{ CFrame.new(0, 4.6, 0), Vector3.new(0.4, 2.6, 5), dark },
		{ CFrame.new(0, 4.6, 0), Vector3.new(5, 2.6, 0.4), dark },
		{ CFrame.new(0, 1.5, 0), Vector3.new(3.5, 0.7, 3.5), rgb(210, 190, 40) },
	}
	local parts: { Part } = {}
	local from = floor + UP * 150
	for i, s in shapes do parts[i] = Kit.part(s[2] :: Vector3, CFrame.new(from), s[3] :: Color3, SP) end
	-- the bomb coming down: a low rush of air (it used to be an engine sound pitched up to a rising whine)
	local whistle = Sfx.at("Whoosh", floor, { PlaybackSpeed = 0.55, Volume = 1.3 })
	local acc = 0
	Kit.loop(dur, function(a, dt)
		local pos = from:Lerp(floor + UP * 5, a * a)
		local rot = CFrame.new(pos) * CFrame.Angles(0, a * 5, 0)
		for i, p in parts do p.CFrame = rot * (shapes[i][1] :: CFrame) end
		if whistle then whistle.PlaybackSpeed = 0.55 + a * 0.3 end
		acc += dt
		if acc > 0.04 then
			acc = 0
			Kit.chunks(pos + UP * 6, 1, { colors = { rgb(220, 220, 215), rgb(190, 190, 186) }, mat = SP, tr = 0.3, smin = 1, smax = 2, speed = 1.5, up = 0, g = 0, life = 0.9 })
		end
		if a < 1 then return nil end
		for _, p in parts do p:Destroy() end
		if whistle then whistle:Stop() end
		local c = floor + UP * 4
		-- the fireball
		Kit.poly(c, 5, 44, WHITE, 0.6, { tr = 0, color1 = FIRE[1], n = 4, hold = 0.4 })
		Kit.poly(c, 4, 60, FIRE[1], 1.1, { tr = 0.1, color1 = FIRE[3], n = 4, hold = 0.35 })
		Kit.poly(c, 4, 74, FIRE[2], 1.7, { tr = 0.35, color1 = SMOKE[2], hold = 0.3 })
		-- the stem and the cap of the mushroom
		local stem: { Part } = {}
		for i = 1, 5 do stem[i] = Kit.part(Vector3.one, CFrame.new(c), FIRE[2], nil, 0.05) end
		local cap: { { p: Part, ang: number, r: number, y: number, s: number } } = {}
		for i = 1, 12 do
			local ring = i <= 4 and 0.35 or 1
			cap[i] = { p = Kit.part(Vector3.one, CFrame.new(c), FIRE[1], nil, 0.05), ang = i * 2.4, r = ring * rand(0.7, 1), y = (i <= 4 and 0.5 or 0) + rand(-0.2, 0.2), s = rand(0.75, 1.15) }
		end
		Kit.loop(6.5, function(b, _, t)
			local rise = E.out3(math.min(1, t / 2.6))
			local h = 58 * rise
			local cool = math.clamp((t - 0.5) / 2.5, 0, 1)
			local fade = math.clamp((t - 4.8) / 1.7, 0, 1)
			local stemC = FIRE[2]:Lerp(SMOKE[1], cool)
			for i, p in stem do
				local y = h * (i - 0.5) / 5
				local w = 9 + math.sin(t * 2 + i) * 1.2 + (i == 1 and 6 or 0)
				p.Size = Vector3.new(w, h / 5 + 0.4, w)
				p.CFrame = CFrame.new(c + UP * y) * CFrame.Angles(0, i * 0.6 + t * 0.3, 0)
				p.Color = stemC; p.Material = cool > 0.6 and SP or Enum.Material.Neon
				p.Transparency = 0.05 + fade * 0.95
			end
			local capR = 6 + 24 * rise
			for i, k in cap do
				local a2 = k.ang + t * 0.25
				local s = (9 + 9 * rise) * k.s
				k.p.Size = Vector3.one * s
				k.p.CFrame = CFrame.new(c + Vector3.new(math.cos(a2) * capR * k.r, h + k.y * 12, math.sin(a2) * capR * k.r)) * CFrame.Angles(t * 0.5 + i, t * 0.3, i)
				local cc = cool * (i % 2 == 0 and 1 or 0.8)
				k.p.Color = FIRE[1]:Lerp(FIRE[3], math.min(1, cc * 2)):Lerp(SMOKE[2], math.clamp(cc * 2 - 1, 0, 1))
				k.p.Material = cool > 0.75 and SP or Enum.Material.Neon
				k.p.Transparency = 0.05 + fade * 0.95
			end
			if b >= 1 then
				for _, p in stem do p:Destroy() end
				for _, k in cap do k.p:Destroy() end
			end
			return nil
		end)
		Kit.ring(floor, { r0 = 4, r1 = 60, n = 26, h = 3, h1 = 0.6, w = 2, color = WHITE, color1 = color, dur = 0.7 })
		Kit.cracks(floor, 30, 14, FIRE[2], 6)
		scorch(floor, 34)
		rubble(floor + UP * 2, 60, 95, floor.Y, nil, 1.6)
		flames(floor + UP, 30, 2.4, nil, 16)
		Kit.light(c + UP * 6, FIRE[1], 60, 12, 2.2)
		Sfx.at("Explosion", floor, { PlaybackSpeed = 0.45, Volume = 2.4 })
		Kit.after(0.35, function() Sfx.at("Crash", floor, { PlaybackSpeed = 0.35, Volume = 1.6 }) end)
		if HUD then HUD.flash(Color3.new(1, 1, 0.9), 1) end
		if Fx then Fx.shake(1.3); Fx.kick(25) end
		for i = 1, 4 do Kit.after(i * 0.3, function() Kit.near(floor, 0.5, 400) end) end
		return nil
	end)
end

function Acts.strike(style: string, pos: Vector3, color: Color3, id: string?)
	if style == "lightning" then
		lightning(pos, color, id == "WrathOfZeus" or id == "Ragnarok")
	elseif style == "meteor" then
		meteor(pos, color, (id == "Armageddon" or id == "DragonFist") and 5 or 4, 0.7)
	elseif style == "holy" then
		holy(pos, color, id == "GrandExorcism")
	elseif style == "nuke" then
		nuke(pos, color)
	end
end

-- FREEZE: a prison of ice crystals that grows over her and shatters when she breaks free -----------------
function Acts.freeze(gpos: Vector3, t: number)
	local g, hrp = ghost()
	local floor = Kit.floor(gpos)
	local size = g and ghostSize(g) or Vector3.new(5, 10, 0)
	local w, h = size.X, size.Y
	local feet = floor.Y - gpos.Y
	-- crystal: offset from her root (x, z), lean (x, z), height and width as fractions of her size
	local spec = {
		{ 0, 0, 0, 0, 1.12, 0.62 }, { 0.42, 0.1, 0.1, -0.32, 0.8, 0.4 }, { -0.4, 0.15, 0.08, 0.34, 0.86, 0.42 },
		{ 0.1, 0.42, -0.34, 0.05, 0.72, 0.38 }, { -0.12, -0.42, 0.36, -0.06, 0.76, 0.4 }, { 0.36, -0.34, 0.26, -0.28, 0.5, 0.3 },
		{ -0.36, 0.34, -0.26, 0.28, 0.54, 0.3 }, { 0.5, 0.44, -0.3, -0.36, 0.34, 0.24 }, { -0.5, -0.4, 0.3, 0.38, 0.38, 0.26 },
	}
	local parts: { Part } = {}
	for i in spec do
		parts[i] = Kit.part(Vector3.one, CFrame.new(gpos), ICE[(i % 3) + 1], SP, i == 1 and 0.45 or 0.2)
	end
	Kit.ring(floor + UP * 0.05, { r0 = 1, r1 = w * 1.6, n = 14, h = 0.12, w = w * 0.6, color = rgb(120, 170, 205), mat = SP, tr = 0.5, dur = math.max(1, t), ease = E.out3, hold = 0.8 })
	Kit.ring(floor, { r0 = 0.5, r1 = w * 1.8, n = 14, h = 1.4, h1 = 0.2, w = 0.6, color = ICE[2], dur = 0.4 })
	Kit.chunks(gpos, 14, { colors = ICE, mat = Enum.Material.Ice, smin = 0.2, smax = 0.45, speed = 14, up = 16, g = 40, life = 0.9, slab = true })
	Kit.light(gpos, ICE[2], 26, 1.5, 0.6)
	Sfx.at("Glass", gpos, { PlaybackSpeed = 0.6 })
	local last = CFrame.new(gpos)
	local acc = 0
	Kit.loop(t + 0.5, function(a, dt, el)
		local held = g ~= nil and g.Parent ~= nil and (g:GetAttribute("Frozen") == true or el < 0.4)
		if hrp and hrp.Parent then last = CFrame.new(hrp.Position) * CFrame.Angles(0, select(2, hrp.CFrame:ToOrientation()), 0) end
		for i, s in spec do
			local grow = E.back(math.clamp((el - (i - 1) * 0.035) / 0.22, 0, 1))
			local hh = math.max(0.05, h * s[5] * grow)
			local ww = w * s[6]
			parts[i].Size = Vector3.new(ww, hh, ww)
			parts[i].CFrame = last * CFrame.new(s[1] * w, feet, s[2] * w) * CFrame.Angles(s[3], math.pi / 4 + i, s[4]) * CFrame.new(0, hh / 2 - 0.3, 0)
		end
		acc += dt
		if acc > 0.25 then -- cold falling off her
			acc = 0
			Kit.chunks(last.Position + UP * h * 0.3, 1, { colors = ICE, smin = 0.12, smax = 0.25, speed = 1.5, up = 0, g = 6, life = 1, spread = w * 0.7, tr = 0.3 })
		end
		if a >= 1 or not held then
			for i, p in parts do
				if i % 2 == 1 then
					Kit.chunks(p.Position, 5, { colors = ICE, mat = Enum.Material.Ice, tr = 0.2, smin = 0.3, smax = 0.8, speed = 20, up = 22, life = 1, slab = true })
				end
				p:Destroy()
			end
			Kit.poly(last.Position, 2, w * 2, ICE[3], 0.3, { tr = 0.4 })
			Sfx.at("Glass", last.Position, { PlaybackSpeed = 1.1, Volume = 1 })
			return false
		end
		return nil
	end)
end

-- TIME STOP: the picture drains, a clock hangs over her and jams, dust hangs in the air ---------------------
function Acts.timeStop(t: number)
	local g, hrp = ghost()
	local origin = hrp and hrp.Position or (cam.CFrame.Position + cam.CFrame.LookVector * 12)
	local gold = rgb(255, 232, 150)
	grade({ Saturation = -1, Contrast = 0.3, TintColor = rgb(220, 215, 255) }, t, 0.08)
	if HUD then HUD.flash(WHITE, 0.6); HUD.banner("TIME STOPS", "", t * 0.6) end
	Kit.poly(origin, 4, 130, WHITE, 0.55, { tr = 0.75, n = 2, ease = E.out })
	Sfx.play("Ultimate", { PlaybackSpeed = 0.4, Volume = 1.2 })
	-- the clock: a faceted rim, twelve ticks and two hands, facing the camera
	local size = g and ghostSize(g) or Vector3.new(5, 10, 0)
	local R = 6.5
	local flat = Vector3.new(cam.CFrame.Position.X - origin.X, 0, cam.CFrame.Position.Z - origin.Z)
	local top = math.min(Kit.ceiling(origin, 40) - R - 0.5, origin.Y + size.Y * 0.5 + R + 2)
	local face = CFrame.lookAt(Vector3.new(origin.X, math.max(top, origin.Y + 2), origin.Z), Vector3.new(origin.X, math.max(top, origin.Y + 2), origin.Z) + (flat.Magnitude > 0.5 and flat.Unit or Vector3.zAxis))
	local parts: { Part } = {}
	local function add(sz: Vector3, off: CFrame, c: Color3, tr: number?): Part
		local p = Kit.part(sz, face * off, c, nil, tr)
		table.insert(parts, p)
		return p
	end
	for i = 1, 24 do add(Vector3.new(R * 2 * math.tan(math.pi / 24) * 1.02, 0.45, 0.3), CFrame.Angles(0, 0, i / 24 * math.pi * 2) * CFrame.new(0, R, 0), gold, 0.1) end
	for i = 1, 12 do
		local big = i % 3 == 0
		add(Vector3.new(big and 0.55 or 0.3, big and 1.5 or 0.9, 0.3), CFrame.Angles(0, 0, i / 12 * math.pi * 2) * CFrame.new(0, R - (big and 1.1 or 0.8), 0), WHITE)
	end
	add(Vector3.new(0.8, 0.8, 0.5), CFrame.Angles(0, 0, math.pi / 4), gold)
	local minute = add(Vector3.new(0.4, R * 0.82, 0.3), CFrame.new(), WHITE)
	local hour = add(Vector3.new(0.55, R * 0.55, 0.3), CFrame.new(), gold)
	local motes: { Part } = {}
	for i = 1, 34 do
		local o = Kit.rng:NextUnitVector() * rand(4, 16)
		motes[i] = Kit.part(Vector3.one * rand(0.15, 0.4), CFrame.new(origin + Vector3.new(o.X, math.abs(o.Y) * 0.6 - 1, o.Z)) * CFrame.Angles(rand(0, 3), rand(0, 3), 0), i % 3 == 0 and gold or rgb(225, 225, 235), nil, 0.1)
	end
	local lastTick = 0
	Kit.loop(t, function(a, _, el)
		-- the hands race, slow down and jam; just before time resumes they whip backwards
		local run = 14 * (1 - (1 - math.min(1, el / 0.8)) ^ 3)
		local jam = el > 0.8 and math.sin(el * 40) * 0.025 * (1 - (el % 1)) or 0
		local back = math.max(0, el - (t - 0.45))
		local ang = -(run + jam) + back * back * 60
		minute.CFrame = face * CFrame.Angles(0, 0, ang) * CFrame.new(0, R * 0.36, -0.2)
		hour.CFrame = face * CFrame.Angles(0, 0, ang / 12 + 1) * CFrame.new(0, R * 0.22, -0.35)
		if el > 0.8 and math.floor(el) > lastTick then
			lastTick = math.floor(el)
			Sfx.play("Click", { PlaybackSpeed = 0.6, Volume = 0.9 })
		end
		if a >= 1 then
			for _, p in parts do
				Kit.chunks(p.Position, 1, { color = p.Color, smin = 0.3, smax = 0.7, speed = 14, up = 12, life = 0.9 })
				p:Destroy()
			end
			for _, p in motes do
				Kit.chunks(p.Position, 1, { color = p.Color, smin = p.Size.X, smax = p.Size.X, speed = 1, up = 0, g = 60, life = 0.8 })
				p:Destroy()
			end
			Sfx.play("Glass", { PlaybackSpeed = 1.4, Volume = 0.6 })
		end
		return nil
	end)
end

-- time runs again: every stored hit lands, one after the other, then the big one
function Acts.timeResume(pos: Vector3, stored: number)
	local gold = rgb(255, 240, 160)
	local big = 14 + math.min(stored, 400) * 0.07
	for i = 1, 6 do
		Kit.after(i * 0.045, function()
			local at = pos + Vector3.new(rand(-3, 3), rand(-2, 4), rand(-3, 3))
			Kit.poly(at, 0.8, 4.5, WHITE, 0.16, { tr = 0.05, n = 2 })
			Sfx.at("PunchLight", at, { PlaybackSpeed = 1 + i * 0.08, Volume = 0.7 })
		end)
	end
	Kit.after(0.33, function()
		local floor = Kit.floor(pos)
		Kit.poly(pos, 3, big, gold, 0.55, { tr = 0.05, color1 = FIRE[2], n = 4 })
		Kit.ring(floor, { r0 = 1, r1 = big * 0.9, n = 18, h = 2, h1 = 0.3, w = 0.9, color = gold, dur = 0.5 })
		Kit.ring(CFrame.new(pos) * CFrame.Angles(math.pi / 2, 0, 0), { r0 = 1, r1 = big * 0.7, n = 16, h = 0.6, w = 0.6, color = WHITE, dur = 0.4, lift = false })
		Kit.chunks(pos, 24, { colors = { gold, WHITE }, smin = 0.25, smax = 0.6, speed = 40, up = 30, life = 0.9 })
		Kit.cracks(floor, big * 0.5, 8, gold)
		Kit.light(pos, gold, 50, 8, 0.6)
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.45, Volume = 1.5 })
		Kit.near(pos, 1.1, 100)
		if HUD then HUD.banner(tostring(math.floor(stored)) .. " DAMAGE", "TIME RESUMES", 2) end
	end)
end

-- ONE PUNCH: the hit that ends the fight ----------------------------------------------------------------
function Acts.onePunch(pos: Vector3, by: Player)
	local gold = rgb(255, 230, 0)
	local ch = by.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	local dir = root and Vector3.new(pos.X - root.Position.X, 0, pos.Z - root.Position.Z) or cam.CFrame.LookVector
	dir = dir.Magnitude > 0.1 and dir.Unit or Vector3.zAxis
	local floor = Kit.floor(pos)
	if HUD then HUD.flash(WHITE, 1) end
	Kit.poly(pos, 3, 46, WHITE, 0.7, { tr = 0, color1 = gold, n = 4, spin = 3 })
	Kit.poly(pos, 2, 26, gold, 1, { tr = 0.2, color1 = FIRE[2] })
	-- the air torn open behind her: rings marching away along the punch
	local facing = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(math.pi / 2, 0, 0)
	for i = 0, 5 do
		Kit.after(i * 0.04, function()
			Kit.ring(facing + dir * (i * 9), { r0 = 1, r1 = 7 + i * 3.5, n = 16, h = 0.8, w = 0.8, color = i % 2 == 0 and gold or WHITE, dur = 0.5, lift = false })
		end)
	end
	Kit.ring(floor, { r0 = 2, r1 = 50, n = 24, h = 3, h1 = 0.4, w = 1.4, color = gold, dur = 0.7 })
	Kit.cracks(floor, 26, 14, gold, 6)
	rubble(floor + UP, 30, 60, floor.Y, nil, 1.3)
	Kit.chunks(pos, 40, { colors = { gold, WHITE }, smin = 0.3, smax = 0.8, speed = 70, up = 30, dir = dir, cone = 0.5, life = 1 })
	Kit.light(pos, gold, 60, 12, 0.9)
	Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.35, Volume = 1.8 })
	Sfx.at("Explosion", pos, { PlaybackSpeed = 0.6, Volume = 1.3 })
	if Fx then Fx.shake(1.3); Fx.kick(30) end
	if by == lp and HUD then HUD.banner("ONE PUNCH", "", 2) end
end

-- FLING: a piece of furniture thrown by an ultimate drags a streak of the ultimate's colour -----------------
function Acts.fling(m: Instance?, color: Color3)
	-- (nil when the piece is not on this client: broken already, or too far away to be sent)
	if not m or not m:IsA("Model") then return end
	local prim = m.PrimaryPart
	if not prim then return end
	local pal = tint(color)
	Kit.poly(prim.Position, 1.5, 6, color, 0.3, { tr = 0.45, n = 2 })
	Kit.ring(Kit.floor(prim.Position), { r0 = 0.5, r1 = 4, n = 10, h = 0.6, w = 0.4, color = color, dur = 0.3 })
	local acc = 0
	Kit.loop(1.3, function(a, dt)
		if not prim.Parent then return false end
		acc += dt
		if acc > 0.05 then
			acc = 0
			local s = math.clamp(prim.Size.Magnitude * 0.22, 0.6, 1.8) * (1 - a * 0.5)
			local p = Kit.part(Vector3.one * s, prim.CFrame, pal[Kit.rng:NextInteger(1, 3)], nil, 0.35)
			Kit.tween(p, 0.3, { Size = Vector3.one * 0.1, Transparency = 1 }, E.lin, function() p:Destroy() end)
		end
		return nil
	end)
end

-- VORTEX: a black hole (or a tornado) on her that eats the room ------------------------------------------
local function hole(g: Model, hrp: BasePart, t: number, k: number, color: Color3)
	local black = rgb(6, 4, 10)
	local core: { Part } = {}
	local rots = { CFrame.new(), CFrame.Angles(math.pi / 4, math.pi / 4, 0), CFrame.Angles(0, math.pi / 4, math.pi / 4) }
	for i = 1, 3 do core[i] = Kit.part(Vector3.one, hrp.CFrame, black, SP) end
	local plane = CFrame.Angles(0.42, 0, 0.2)
	local halo: { Part } = {}
	for i = 1, 14 do halo[i] = Kit.part(Vector3.one, hrp.CFrame, WHITE) end
	local disc: { { p: Part, r: number, ang: number, sp: number, s: number } } = {}
	for i = 1, 26 do
		local rr = rand(3.3, 7.6)
		local s = rand(0.5, 1.2) * k
		disc[i] = { p = Kit.part(Vector3.new(s, s * 0.4, s * 1.7), hrp.CFrame, rgb(255, 200, 120):Lerp(color, (rr - 3.3) / 4.3)), r = rr * k, ang = rand(0, 6.3), sp = 26 / rr ^ 1.3, s = s }
	end
	local inflow: { { p: Part, ang: number, r: number, y: number, t0: number } } = {}
	local att = Instance.new("Attachment"); att.Parent = workspace.Terrain
	local light = Instance.new("PointLight"); light.Color = color; light.Range = 45; light.Brightness = 0; light.Shadows = false; light.Parent = att
	local snd = Sfx.loop("Vacuum", { PlaybackSpeed = 0.45, Volume = 0 })
	Sfx.at("Ultimate", hrp.Position, { PlaybackSpeed = 0.5, Volume = 1 })
	local c = hrp.Position + UP * 3.5 * k
	local ending: number? = nil
	local acc = 0
	Kit.loop(t + 4, function(al, dt, el)
		local alive = al < 0.98 and g.Parent ~= nil and hrp.Parent ~= nil and g:GetAttribute("Vortex") == true
		if alive then c = hrp.Position + UP * 3.5 * k elseif not ending then ending = el end
		local s = E.back(math.min(1, el / 0.45))
		if ending then s = math.max(0, 1 - (el - ending) / 0.28) end
		local pulse = 1 + math.sin(el * 9) * 0.05
		for i, p in core do
			p.Size = Vector3.one * 3.4 * k * s * pulse
			p.CFrame = CFrame.new(c) * CFrame.Angles(el * 0.9, el * 1.3, 0) * rots[i]
		end
		local hr = 2.75 * k * s
		for i, p in halo do
			p.Size = Vector3.new(hr * 2 * math.tan(math.pi / 14) * 1.05, 0.3 * k, 0.35 * k)
			p.CFrame = CFrame.new(c) * plane * CFrame.Angles(0, i / 14 * math.pi * 2 + el * 2, 0) * CFrame.new(0, 0, -hr)
		end
		for _, d in disc do
			d.ang += d.sp * dt
			local rr = d.r * s * (1 + math.sin(el * 3 + d.ang) * 0.06)
			d.p.CFrame = CFrame.new(c) * plane * CFrame.Angles(0, d.ang, 0) * CFrame.new(0, 0, -rr) * CFrame.Angles(0, math.pi / 2, 0)
			d.p.Size = Vector3.new(d.s, d.s * 0.4, d.s * 1.7) * math.max(0.05, s)
		end
		acc += dt
		if acc > 0.045 and not ending and #inflow < 34 then -- the room's dust spirals in
			acc = 0
			local s0 = rand(0.3, 0.7) * k
			table.insert(inflow, { p = Kit.part(Vector3.one * s0, CFrame.new(c), Kit.rng:NextNumber() < 0.5 and color or rgb(40, 20, 60)), ang = rand(0, 6.3), r = rand(9, 16) * k, y = rand(-3, 7), t0 = el })
		end
		for i = #inflow, 1, -1 do
			local f = inflow[i]
			local a = (el - f.t0) / 0.75
			if a >= 1 then
				f.p:Destroy()
				table.remove(inflow, i)
			else
				local e = a ^ 1.5
				local ang = f.ang + e * 5
				f.p.CFrame = CFrame.new(c + Vector3.new(math.cos(ang) * f.r * (1 - e), f.y * (1 - e), math.sin(ang) * f.r * (1 - e))) * CFrame.Angles(a * 5, a * 3, 0)
				f.p.Size = Vector3.one * f.p.Size.X * (1 - e * 0.06)
			end
		end
		att.WorldPosition = c
		light.Brightness = 4 * s
		if snd then snd.Volume = math.clamp(1 - Kit.dist(c) / 130, 0, 1) * 0.9 * s end
		if (ending and s <= 0) or al >= 1 then
			for _, p in core do p:Destroy() end
			for _, p in halo do p:Destroy() end
			for _, d in disc do d.p:Destroy() end
			for _, f in inflow do f.p:Destroy() end
			att:Destroy()
			if snd then snd:Destroy() end
			Kit.poly(c, 1, 16 * k, color, 0.4, { tr = 0.1, color1 = WHITE })
			Kit.ring(CFrame.new(c) * plane, { r0 = 1, r1 = 18 * k, n = 18, h = 0.6, w = 0.7, color = color, dur = 0.45, lift = false })
			Kit.chunks(c, 24, { colors = tint(color), smin = 0.3, smax = 0.7, speed = 34, up = 20, life = 0.9 })
			Sfx.at("Explosion", c, { PlaybackSpeed = 1.2, Volume = 0.8 })
			Kit.near(c, 0.5, 80)
			return false
		end
		return nil
	end)
end

local function tornado(g: Model, hrp: BasePart, t: number, color: Color3)
	local rings: { { parts: { Part }, y: number, r: number, sp: number } } = {}
	for i = 1, 7 do
		local parts: { Part } = {}
		for j = 1, 7 do parts[j] = Kit.part(Vector3.one, hrp.CFrame, (i + j) % 3 == 0 and color or DUST[(i + j) % 3 + 1], SP, 0.2) end
		rings[i] = { parts = parts, y = (i - 1) * 3.4 + 1.2, r = 1.5 + (i - 1) * 1.45, sp = 8 - i * 0.65 }
	end
	local debris: { { p: Part, y: number, ang: number, sp: number, vy: number } } = {}
	for i = 1, 16 do
		local s = rand(0.5, 1.3)
		debris[i] = { p = Kit.part(Vector3.new(s, s * rand(0.3, 1), s * rand(0.8, 1.8)), hrp.CFrame, WOOD[i % 3 + 1], SP), y = rand(0, 22), ang = rand(0, 6.3), sp = rand(4, 7), vy = rand(5, 11) }
	end
	local snd = Sfx.loop("Vacuum", { PlaybackSpeed = 0.8, Volume = 0 })
	local base = Kit.floor(hrp.Position)
	local ending: number? = nil
	local acc = 0
	Kit.loop(t + 4, function(al, dt, el)
		local alive = al < 0.98 and g.Parent ~= nil and hrp.Parent ~= nil and g:GetAttribute("Vortex") == true
		if not alive and not ending then ending = el end
		acc += dt
		if alive and acc > 0.4 then
			acc = 0
			base = Kit.floor(hrp.Position)
			Kit.ring(base, { r0 = 1, r1 = 7, n = 12, h = 0.8, h1 = 0.2, w = 0.7, color = DUST[1], mat = SP, tr = 0.4, dur = 0.5 })
		elseif alive then
			base = Vector3.new(hrp.Position.X, base.Y, hrp.Position.Z)
		end
		local s = math.min(1, el / 0.5)
		if ending then s = math.max(0, 1 - (el - ending) / 0.4) end
		for i, r in rings do
			local c = base + Vector3.new(math.sin(el * 2.2 + i * 0.7) * i * 0.3, r.y * s, math.cos(el * 1.8 + i * 0.9) * i * 0.3)
			local rr = r.r * (0.4 + 0.6 * s)
			for j, p in r.parts do
				p.Size = Vector3.new(rr * 2 * math.tan(math.pi / 7) * 0.8, 2.8, 0.5)
				p.CFrame = CFrame.new(c) * CFrame.Angles(0, el * r.sp + j / 7 * math.pi * 2, 0) * CFrame.new(0, 0, -rr) * CFrame.Angles(0.22, 0, 0)
				p.Transparency = 0.2 + (1 - s) * 0.8
			end
		end
		for _, d in debris do
			d.y = (d.y + d.vy * dt) % 24
			d.ang += d.sp * dt
			local rr = (2.2 + d.y * 0.45) * s
			d.p.CFrame = CFrame.new(base + Vector3.new(math.cos(d.ang) * rr, d.y * s, math.sin(d.ang) * rr)) * CFrame.Angles(d.ang * 2, d.ang, 0)
			d.p.Transparency = 1 - s
		end
		if snd then snd.Volume = math.clamp(1 - Kit.dist(base) / 130, 0, 1) * 0.9 * s end
		if (ending and s <= 0) or al >= 1 then
			for _, r in rings do for _, p in r.parts do p:Destroy() end end
			for _, d in debris do
				Kit.chunks(d.p.Position, 1, { color = d.p.Color, mat = SP, smin = 0.5, smax = 1, speed = 20, up = 10, floor = base.Y, life = 1.2 })
				d.p:Destroy()
			end
			if snd then snd:Destroy() end
			return false
		end
		return nil
	end)
end

function Acts.vortex(t: number, r: number, color: Color3, isTornado: boolean)
	Kit.loop(3, function() -- wait for the server to switch it on
		local g, hrp = ghost()
		if g and hrp and g:GetAttribute("Vortex") then
			if isTornado then tornado(g, hrp, t, color) else hole(g, hrp, t, math.clamp(r / 40, 1, 2), color) end
			return false
		end
		return nil
	end)
end

-- LAUNCH: the uppercut. Streaks under her on the way up, a burst at the top, a crater where she lands -------
function Acts.launch(color: Color3, big: boolean)
	local g, hrp = ghost()
	if not g or not hrp then return end
	local start = Kit.floor(hrp.Position)
	local pale = color:Lerp(WHITE, 0.6)
	Kit.ring(start, { r0 = 1, r1 = big and 16 or 9, n = 14, h = 3, h1 = 0.4, w = 0.9, color = color, dur = 0.4 })
	Kit.column(start, 1, big and 7 or 4, big and 60 or 30, pale, 0.5, 0.35)
	rubble(start + UP, 12, 22, start.Y)
	Sfx.at("Whoosh", start, { PlaybackSpeed = 0.7, Volume = 1.6 })
	Sfx.at("PunchHeavy", start, { PlaybackSpeed = 0.7, Volume = 1.2 })
	Kit.near(start, 0.5, 60)
	local phase = "wait"
	local acc = 0
	Kit.loop(8, function(_, dt, el)
		if not g.Parent or not hrp.Parent then return false end
		local state = g:GetAttribute("State")
		local pos = hrp.Position
		local vy = hrp.AssemblyLinearVelocity.Y
		acc += dt
		if phase == "wait" then
			if state == "Launched" then phase = "up" elseif el > 1.5 then return false end
		elseif state ~= "Launched" then -- she is back on the floor
			local floor = Kit.floor(pos)
			local r = big and 26 or 15
			Kit.ring(floor, { r0 = 1, r1 = r, n = 18, h = 2.4, h1 = 0.4, w = 1.1, color = color, dur = 0.5 })
			Kit.poly(floor + UP * 2, 2, r * 0.6, pale, 0.4, { tr = 0.2 })
			Kit.spikes(floor, { r = r * 0.3, n = 8, h = big and 5 or 3, w = 2, tilt = 0.8, colors = ROCK, life = 2.2 })
			Kit.cracks(floor, r * 0.7, 10, color, 5)
			rubble(floor + UP, big and 30 or 18, r * 1.4, floor.Y)
			Kit.light(floor + UP * 3, color, 45, 6, 0.5)
			Kit.near(floor, big and 1 or 0.7, 90)
			return false
		elseif acc > 0.03 then
			acc = 0
			local down = vy < -20
			if phase == "up" and down then
				phase = "down"
				Kit.poly(pos, 2, big and 14 or 9, pale, 0.3, { tr = 0.1 })
				Kit.ring(CFrame.new(pos), { r0 = 1, r1 = big and 14 or 9, n = 14, h = 0.6, w = 0.6, color = color, dur = 0.35, lift = false })
			end
			-- speed lines trailing behind her
			local o = Vector3.new(rand(-2.5, 2.5), 0, rand(-2.5, 2.5))
			local tail = down and UP * rand(6, 12) or UP * -rand(6, 12)
			Kit.fade(Kit.line(pos + o + tail * 0.2, pos + o + tail, 0.3, Kit.rng:NextNumber() < 0.5 and pale or color, 0.1), 0.04, 0.2)
		end
		return nil
	end)
end

-- BURN: she goes up in block flames of the ultimate's colour ------------------------------------------------
function Acts.burn(t: number, dps: number, color: Color3)
	local g, hrp = ghost()
	if not g or not hrp then return end
	local pal = { color:Lerp(WHITE, 0.55), color, color:Lerp(rgb(120, 20, 0), 0.45) }
	local k = math.clamp(dps / 12, 0.8, 2)
	local size = ghostSize(g)
	local floor = Kit.floor(hrp.Position)
	flames(hrp.Position - UP, math.floor(14 * k), 1.2 * k, pal, size.X * 0.5)
	Kit.ring(floor, { r0 = 0.5, r1 = 5 * k, n = 12, h = 1.6, h1 = 0.3, w = 0.6, color = color, dur = 0.35 })
	Kit.column(floor, 0.5, size.X * 0.8, size.Y * 1.3, pal[1], 0.4, 0.4)
	Kit.light(hrp.Position, color, 35, 5, 0.6)
	Sfx.at("Flamethrower", hrp.Position, { PlaybackSpeed = 1.1, Volume = 0.9 })
	local acc = 0
	Kit.loop(t, function(_, dt)
		if not g.Parent or not hrp.Parent or g:GetAttribute("State") == "Dead" then return false end
		acc += dt
		if acc > 0.13 then
			acc = 0
			flames(hrp.Position + UP * rand(-size.Y * 0.3, size.Y * 0.3), k > 1.4 and 3 or 2, 0.55 * k, pal, size.X * 0.4)
		end
		return nil
	end)
end

-- SLOW (bullet time): the picture cools, she leaves frames of herself behind, rings close on her ------------
function Acts.slow(t: number, color: Color3)
	local g, hrp = ghost()
	grade({ Saturation = -0.5, Contrast = 0.12, TintColor = rgb(205, 218, 255) }, t, 0.25)
	Sfx.play("Ultimate", { PlaybackSpeed = 0.3, Volume = 0.9 })
	if not g or not hrp then return end
	local size = ghostSize(g)
	local acc, acc2 = 0, 0.5
	Kit.loop(t, function(_, dt)
		if not g.Parent or not hrp.Parent then return false end
		acc += dt; acc2 += dt
		if acc > 0.22 then -- a frame where she stood
			acc = 0
			local cf = hrp.CFrame
			local w, h = size.X * 0.8, size.Y * 0.9
			for _, e in { { 0, h / 2, w, 0.15 }, { 0, -h / 2, w, 0.15 }, { w / 2, 0, 0.15, h }, { -w / 2, 0, 0.15, h } } do
				local p = Kit.part(Vector3.new(e[3], e[4], 0.15), cf * CFrame.new(e[1], e[2], 0), color, nil, 0.35)
				Kit.fade(p, 0, 0.7)
			end
		end
		if acc2 > 0.9 then
			acc2 = 0
			Kit.ring(Kit.floor(hrp.Position) + UP * 0.1, { r0 = size.X * 2.2, r1 = size.X * 0.5, n = 14, h = 0.15, w = 0.4, color = color, dur = 0.8, ease = E.inq, hold = 0.6 })
			Sfx.at("Click", hrp.Position, { PlaybackSpeed = 0.5, Volume = 0.5 })
		end
		return nil
	end)
end

-- HEAL / STAMINA / GIANT (on the caster) -------------------------------------------------------------------
local function rootOf(by: Player): BasePart?
	local ch = by.Character
	local r = ch and ch:FindFirstChild("HumanoidRootPart")
	return (r and r:IsA("BasePart")) and r or nil
end

-- plus signs climbing round the player
function Acts.heal(by: Player, color: Color3)
	local root = rootOf(by)
	if not root then return end
	local floor = Kit.floor(root.Position)
	Kit.ring(floor, { r0 = 0.5, r1 = 7, n = 14, h = 0.8, h1 = 0.15, w = 0.5, color = color, dur = 0.5 })
	Kit.light(root.Position, color, 30, 4, 0.8)
	Sfx.at("Cash", root.Position, { PlaybackSpeed = 1.5, Volume = 0.7 })
	if by == lp and HUD then HUD.flash(color, 0.35) end
	for i = 1, 8 do
		local a = Kit.part(Vector3.new(0.9, 0.28, 0.28), root.CFrame, color)
		local b = Kit.part(Vector3.new(0.28, 0.9, 0.28), root.CFrame, color)
		local ang0, r, sp = i / 8 * math.pi * 2, rand(2.4, 3.4), rand(1.6, 2.6)
		local wait = i * 0.05
		Kit.loop(1.5, function(al, _, el)
			if not root.Parent then a:Destroy(); b:Destroy(); return false end
			local u = math.max(0, el - wait) / (1.5 - wait)
			local cf = CFrame.new(Vector3.new(root.Position.X, floor.Y, root.Position.Z)) * CFrame.Angles(0, ang0 + u * sp * 3, 0) * CFrame.new(0, 0.5 + u * 7, -r)
			a.CFrame = cf; b.CFrame = cf
			local tr = u <= 0 and 1 or math.clamp((u - 0.6) / 0.4, 0, 1)
			a.Transparency = tr; b.Transparency = tr
			if al >= 1 then a:Destroy(); b:Destroy() end
			return nil
		end)
	end
end

-- chevrons shooting up: a second wind
function Acts.stamina(by: Player, color: Color3)
	local root = rootOf(by)
	if not root then return end
	local floor = Kit.floor(root.Position)
	Kit.ring(floor, { r0 = 4, r1 = 0.8, n = 12, h = 0.5, w = 0.4, color = color, dur = 0.3, ease = E.inq, hold = 0.9 })
	for i = 1, 7 do
		local ang = i / 7 * math.pi * 2
		local l = Kit.part(Vector3.new(0.8, 0.22, 0.22), root.CFrame, color)
		local r = Kit.part(Vector3.new(0.8, 0.22, 0.22), root.CFrame, color)
		local wait = (i % 4) * 0.07
		Kit.loop(0.9, function(al, _, el)
			if not root.Parent then l:Destroy(); r:Destroy(); return false end
			local u = math.max(0, el - wait) / (0.9 - wait)
			local cf = CFrame.new(Vector3.new(root.Position.X, floor.Y, root.Position.Z)) * CFrame.Angles(0, ang, 0) * CFrame.new(0, 0.5 + E.out(u) * 9, -2.6)
			l.CFrame = cf * CFrame.new(-0.26, 0, 0) * CFrame.Angles(0, 0, 0.75)
			r.CFrame = cf * CFrame.new(0.26, 0, 0) * CFrame.Angles(0, 0, -0.75)
			local tr = u <= 0 and 1 or math.clamp((u - 0.5) / 0.5, 0, 1)
			l.Transparency = tr; r.Transparency = tr
			if al >= 1 then l:Destroy(); r:Destroy() end
			return nil
		end)
	end
end

-- growing into a giant: the floor gives way, rings climb the body, and every step lands like a hammer
function Acts.giant(by: Player, scale: number, t: number, color: Color3)
	local root = rootOf(by)
	if not root then return end
	local floor = Kit.floor(root.Position)
	local r = 5 * scale
	Kit.cracks(floor, r * 1.4, 10, color, 6)
	Kit.ring(floor, { r0 = 1, r1 = r * 2, n = 18, h = 2, h1 = 0.4, w = 1.2, color = DUST[1], mat = SP, tr = 0.3, dur = 0.7 })
	Kit.spikes(floor, { r = r * 0.8, n = 8, h = 1.5 * scale, w = 1.6, tilt = 0.9, colors = ROCK, life = 1.6, stagger = 0.2 })
	rubble(floor + UP, 22, r * 2.4, floor.Y)
	for i = 1, 4 do
		Kit.after(i * 0.12, function()
			if root.Parent then
				Kit.ring(Vector3.new(root.Position.X, floor.Y + i * 1.6 * scale, root.Position.Z), { r0 = 1, r1 = 2 + scale * 1.5, n = 12, h = 0.5, w = 0.45, color = color, dur = 0.45, lift = false })
			end
		end)
	end
	Kit.light(root.Position, color, 40, 5, 0.9)
	Sfx.at("Crash", root.Position, { PlaybackSpeed = 0.5, Volume = 1.2 })
	Sfx.at("DemonRoar", root.Position, { PlaybackSpeed = 0.8, Volume = 0.5 })
	Kit.near(root.Position, 0.7, 70)
	local walked, last = 0, root.Position
	Kit.loop(t, function()
		if not root.Parent or not by:GetAttribute("UltActive") then return false end
		local p = root.Position
		walked += Vector3.new(p.X - last.X, 0, p.Z - last.Z).Magnitude
		last = p
		if walked > 5.5 * scale then
			walked = 0
			local f = Kit.floor(p)
			Kit.ring(f, { r0 = 0.5, r1 = 3 * scale, n = 10, h = 0.7, h1 = 0.15, w = 0.5, color = DUST[1], mat = SP, tr = 0.35, dur = 0.4 })
			Kit.chunks(f + UP * 0.5, 5, { colors = ROCK, mat = SP, smin = 0.25, smax = 0.6, speed = 10, up = 14, floor = f.Y, life = 0.8 })
			Sfx.at("PunchHeavy", f, { PlaybackSpeed = 0.4, Volume = 0.55 })
			Kit.near(f, 0.22, 50)
		end
		return nil
	end)
end

function Acts.init(fx: any, hud: any)
	Fx = fx; HUD = hud
	Kit.init()
	Kit.setShake(function(n) fx.shake(n) end)
	local old = Lighting:FindFirstChild("UltGrade")
	if old then old:Destroy() end
	gradeFx = Instance.new("ColorCorrectionEffect")
	gradeFx.Name = "UltGrade"
	gradeFx.Parent = Lighting
end

return Acts
