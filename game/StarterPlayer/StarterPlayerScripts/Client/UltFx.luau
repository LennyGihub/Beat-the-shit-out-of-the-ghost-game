--!strict
-- UltFx: how each of the 50 ultimates is CAST. Every ultimate has its own hand animation (Viewmodel.cast, seen in
-- first person), an arm pose other players see (UltPose), a wind-up, a signature effect and an aura that stays
-- while it is active. The effects of the ultimate's actions (shockwaves, strikes, ice, time stop...) are in UltActs;
-- the blocks they are all built from are in UltKit.
-- The server waits Ultimates.castTime after the cast before the actions go off: the wind-up ends on that beat.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ultimates = require(RS.Shared.Ultimates)
local Kit = require(script.Parent.UltKit)
local Acts = require(script.Parent.UltActs)
local Pose = require(script.Parent.UltPose)
local VM = require(script.Parent.Viewmodel)
local Sfx = require(script.Parent.Sfx)

local UltFx = {}
local lp = Players.LocalPlayer
local Fx: any
local HUD: any
local E = Kit.ease
local rand = Kit.rand
local UP = Vector3.yAxis
local SP = Enum.Material.SmoothPlastic
local WHITE = Color3.new(1, 1, 1)
local function rgb(r: number, g: number, b: number): Color3 return Color3.fromRGB(r, g, b) end
local CAST: number = Ultimates.castTime
local actMark = false

-- hands = first-person animation (Viewmodel.CASTS) | sig = signature effect (below) | aura = what hangs round the
-- fists and the body while the ultimate is active: rise (embers), fall (drips, frost), orbit, arc (electric)
type Spec = { hands: string, sig: string, aura: string }
local function S(hands: string, sig: string, aura: string): Spec return { hands = hands, sig = sig, aura = aura } end
local SPEC: { [string]: Spec } = {
	Rage = S("slam", "roar", "rise"), GroundPound = S("slam", "none", "orbit"), HeavyHands = S("bump", "iron", "orbit"),
	SecondWind = S("breath", "wind", "rise"), SkyUppercut = S("uppercut", "none", "orbit"), TableFlipper = S("flip", "tele", "orbit"),
	HotHead = S("push", "ignite", "rise"), BrainFreeze = S("push", "chill", "fall"), StreetSweeper = S("sweep", "none", "orbit"),
	Caffeine = S("chug", "caffeine", "arc"),
	ThunderFist = S("sky", "call", "arc"), MeteorPunch = S("point", "call", "rise"), ExplodingFists = S("bump", "fuse", "rise"),
	VampireRush = S("claw", "blood", "fall"), Frostbite = S("clap", "chill", "fall"), Poltergeist = S("tele", "tele", "orbit"),
	Bulldozer = S("push", "none", "orbit"), Hellfire = S("slam", "ignite", "rise"), BulletTime = S("snap", "bullets", "orbit"),
	GiantMode = S("stomp", "none", "rise"),
	BlackHole = S("pull", "void", "orbit"), Thunderstorm = S("sky", "call", "arc"), MeteorShower = S("point", "call", "rise"),
	IceAge = S("slam", "chill", "fall"), FurnitureTornado = S("sweep", "tele", "orbit"), Inferno = S("flex", "ignite", "rise"),
	TimeStop = S("snap", "none", "orbit"), OrbitalUppercut = S("uppercut", "none", "orbit"), BloodMoon = S("flex", "moon", "fall"),
	HolySmite = S("pray", "holy", "orbit"),
	Armageddon = S("slam", "call", "rise"), WrathOfZeus = S("sky", "call", "arc"), Singularity = S("pull", "void", "orbit"),
	TitanForm = S("stomp", "none", "rise"), ReversePossession = S("tele", "tele", "orbit"), DragonFist = S("push", "ignite", "rise"),
	AbsoluteZero = S("clap", "chill", "fall"), Earthquake = S("slam", "none", "orbit"), BerserkGod = S("flex", "berserk", "arc"),
	FurnitureApocalypse = S("flip", "tele", "orbit"),
	GrandExorcism = S("pray", "holy", "orbit"), Supernova = S("flex", "implode", "rise"), EventHorizon = S("pull", "void", "orbit"),
	GodMode = S("breath", "god", "orbit"), Ragnarok = S("sky", "call", "arc"), HouseCollapse = S("flip", "tele", "orbit"),
	Colossus = S("stomp", "none", "rise"), InfiniteCombo = S("flurry", "combo", "arc"), GhostNuke = S("point", "flare", "rise"),
	OnePunch = S("windup", "gold", "orbit"),
}

local function rootOf(by: Player): BasePart?
	local ch = by.Character
	local r = ch and ch:FindFirstChild("HumanoidRootPart")
	return (r and r:IsA("BasePart")) and r or nil
end

-- the middle of a caster's own effects: the chest, or (your own cast seen in first person) just past your hands,
-- so nothing bursts inside the camera
local function focusOf(by: Player, fallback: Vector3): Vector3
	local r = rootOf(by)
	local p = r and r.Position or fallback
	local cf = workspace.CurrentCamera.CFrame
	if by == lp and (cf.Position - p).Magnitude < 4 then return cf.Position + cf.LookVector * 3.2 - cf.UpVector * 0.9 end
	return p
end

-- SIGNATURES: (by, def, where the caster stands now, the floor there, the caster's look direction) at the beat
type Sig = (by: Player, def: any, pos: Vector3, floor: Vector3, look: Vector3) -> ()
local sigs: { [string]: Sig } = {}
local own = false -- the signature running is your own, seen in first person: keep it out of your face

function sigs.none() end

function sigs.roar(by, def, pos, floor)
	local c = focusOf(by, pos)
	if c == pos then
		Kit.poly(c, 1, 12, def.color, 0.4, { tr = 0.2 })
		Kit.column(floor, 1, 5, 16, def.color, 0.5, 0.3)
	end
	Kit.chunks(c == pos and c or floor + UP, 16, { colors = Acts.tint(def.color), smin = 0.25, smax = 0.6, speed = 22, up = 24, life = 0.8 })
	Sfx.at("DemonRoar", pos, { PlaybackSpeed = 1.3, Volume = 0.5 })
end

-- two blocks of iron drop beside you and crack the floor
function sigs.iron(_by, def, pos, floor, look)
	local right = look:Cross(UP)
	for i, side in { 1, -1 } do
		local at = floor + right * side * 3.2 + look * 1.5
		local p = Kit.part(Vector3.new(2.6, 2.6, 2.6), CFrame.new(at + UP * 14) * CFrame.Angles(0, i, 0), rgb(74, 76, 84), Enum.Material.Metal)
		local q = Kit.part(Vector3.new(2.9, 0.6, 2.9), CFrame.new(at + UP * 14), rgb(40, 42, 48), Enum.Material.Metal)
		Kit.after((i - 1) * 0.09, function()
			Kit.loop(0.22, function(a)
				local y = 14 * (1 - a * a) + 1.3
				p.CFrame = CFrame.new(at + UP * y) * CFrame.Angles(0, i, 0)
				q.CFrame = CFrame.new(at + UP * (y + 1)) * CFrame.Angles(0, i, 0)
				if a >= 1 then
					Kit.cracks(at, 5, 6, nil, 4)
					Kit.ring(at, { r0 = 1, r1 = 6, n = 10, h = 0.8, h1 = 0.2, w = 0.5, color = rgb(170, 170, 180), mat = SP, tr = 0.3, dur = 0.35 })
					Kit.chunks(at + UP, 8, { colors = { rgb(92, 80, 68), rgb(70, 62, 56) }, mat = SP, smin = 0.3, smax = 0.7, speed = 14, up = 18, floor = at.Y, life = 1 })
					Sfx.at("PipeFall", at, { PlaybackSpeed = 0.6, Volume = 1 })
					Sfx.at("Bonk", at, { PlaybackSpeed = 0.5, Volume = 0.8 })
					Kit.near(at, 0.45, 50)
					Kit.fade(p, 1.6, 0.5); Kit.fade(q, 1.6, 0.5)
				end
				return nil
			end)
		end)
	end
end

function sigs.wind(_by, def, pos, floor)
	for i = 0, 2 do
		Kit.after(i * 0.09, function()
			Kit.ring(floor + UP * (0.4 + i * 1.6), { r0 = 0.8, r1 = 9 - i * 2, n = 14, h = 0.5, w = 0.4, color = i == 1 and WHITE or def.color, dur = 0.5, lift = false, spin = 2 })
		end)
	end
	Kit.column(floor, 0.5, 3.5, 12, def.color:Lerp(WHITE, 0.5), 0.5, 0.45)
	Sfx.at("Whoosh", pos, { PlaybackSpeed = 0.8, Volume = 1.3 })
end

-- telekinesis: square frames turn on the floor and climb, the dust lifts
function sigs.tele(_by, def, pos, floor)
	for i = 1, 3 do
		Kit.ring(floor + UP * 0.1, { r0 = 2 + i * 2.2, r1 = 2 + i * 2.2, n = 4, h = 0.16, w = 0.35, color = i == 2 and WHITE or def.color, dur = 1.1, spin = (i % 2 == 0 and -1 or 1) * 2.6, fill = 0.8, hold = 0.6, lift = false })
		Kit.after(0.1 * i, function()
			Kit.ring(floor + UP * (i * 1.8), { r0 = 3, r1 = 4.5, n = 4, h = 0.12, w = 0.25, color = def.color, dur = 0.7, spin = 2, fill = 0.7, lift = false })
		end)
	end
	Kit.chunks(floor + UP * 0.3, 22, { colors = Acts.tint(def.color), smin = 0.15, smax = 0.4, speed = 1.5, up = 5, g = -5, life = 1.3, spread = 7, spin = 0.4 })
	Sfx.at("Telekinesis", pos, { Volume = 0.9 })
end

function sigs.ignite(_by, def, pos, floor)
	local pal = { rgb(255, 225, 100), def.color, rgb(200, 50, 15) }
	local r = own and 6.5 or 3.5
	for i = 1, 10 do
		local a = i / 10 * math.pi * 2
		Acts.flames(floor + Vector3.new(math.cos(a) * r, 0.5, math.sin(a) * r), 3, 1.1, pal, 0.6)
	end
	Kit.ring(floor, { r0 = 1, r1 = 7, n = 14, h = 1.4, h1 = 0.3, w = 0.6, color = pal[1], color1 = pal[3], dur = 0.4 })
	Kit.light(pos, def.color, 30, 5, 0.6)
	Sfx.at("Flamethrower", pos, { PlaybackSpeed = 1.2, Volume = 0.8 })
end

function sigs.chill(_by, def, pos, floor)
	local ice = { rgb(120, 190, 235), rgb(78, 150, 215), rgb(170, 222, 245) }
	Kit.spikes(floor, { r = own and 7 or 3.4, n = own and 12 or 8, h = own and 1.8 or 2.4, w = 0.8, tilt = 0.6, colors = ice, mat = SP, tr = 0.12, life = 1.1, crystal = true, shatter = true })
	Kit.ring(floor, { r0 = 1, r1 = 8, n = 14, h = 1, h1 = 0.2, w = 0.5, color = def.color, dur = 0.4 })
	Kit.chunks(pos, 14, { colors = ice, mat = Enum.Material.Ice, smin = 0.15, smax = 0.4, speed = 12, up = 10, g = 20, life = 1, slab = true })
	Sfx.at("Glass", pos, { PlaybackSpeed = 1.5, Volume = 0.7 })
end

-- the can flies off, sparks jitter round your head
function sigs.caffeine(_by, def, pos, _floor, look)
	local head = pos + UP * 2
	Kit.chunks(head + look * 1.5, 1, { color = rgb(190, 30, 30), mat = Enum.Material.Metal, smin = 0.7, smax = 0.7, speed = 14, up = 16, dir = look:Cross(UP), cone = 0.2, floor = true, life = 1.6, slab = true })
	for i = 1, 6 do
		Kit.after(i * 0.07, function()
			local a = head + Kit.rng:NextUnitVector() * 2
			local b = a + Kit.rng:NextUnitVector() * 1.6
			Kit.fade(Kit.line(a, b, 0.14, i % 2 == 0 and WHITE or rgb(255, 230, 90)), 0.03, 0.12)
		end)
	end
	Sfx.at("TaserTick", pos, { PlaybackSpeed = 1.6, Volume = 0.5 })
	Sfx.at("Click", pos, { PlaybackSpeed = 0.7, Volume = 0.8 })
end

-- calling it down: a thin beam from the caster into the sky
function sigs.call(_by, def, pos, floor)
	local pale = def.color:Lerp(WHITE, 0.5)
	Kit.column(floor, 0.4, 2.2, 90, pale, 0.6, 0.15, 0.35)
	Kit.ring(floor, { r0 = 1, r1 = 9, n = 14, h = 1.2, h1 = 0.2, w = 0.5, color = def.color, dur = 0.45 })
	for i = 1, 3 do
		Kit.after(i * 0.06, function()
			Kit.ring(floor + UP * (2 + i * 4), { r0 = 0.6, r1 = 3.4, n = 10, h = 0.3, w = 0.3, color = pale, dur = 0.4, lift = false })
		end)
	end
	Kit.chunks(pos, 12, { colors = Acts.tint(def.color), smin = 0.2, smax = 0.45, speed = 6, up = 30, g = 10, life = 0.8, spread = 1.5 })
	Kit.light(pos + UP * 3, def.color, 35, 5, 0.5)
	Sfx.at("Ultimate", pos, { PlaybackSpeed = 1.3, Volume = 0.7 })
end

-- lit fuses: pops going off round the caster
function sigs.fuse(_by, def, pos)
	local rr = own and 6 or 3.2 -- read now: the pops go off later
	for i = 1, 7 do
		Kit.after((i - 1) * 0.06, function()
			local a = i / 7 * math.pi * 2
			local at = pos + Vector3.new(math.cos(a) * rr, rand(-1, 2), math.sin(a) * rr)
			Kit.poly(at, 0.6, 3.2, rgb(255, 225, 100), 0.22, { tr = 0.05, color1 = def.color, n = 2 })
			Kit.chunks(at, 4, { colors = { rgb(255, 225, 100), def.color }, smin = 0.15, smax = 0.35, speed = 12, up = 10, life = 0.5 })
			Sfx.at("Explosion", at, { PlaybackSpeed = 2.2 + i * 0.05, Volume = 0.3 })
		end)
	end
end

-- blood drawn in from the room
function sigs.blood(by, def, pos, floor)
	Kit.gather(function() return focusOf(by, pos) end, 30, 14, 0.7, { def.color, rgb(90, 0, 10), rgb(255, 60, 70) }, 0.5)
	Kit.ring(floor + UP * 0.1, { r0 = 12, r1 = 1, n = 16, h = 0.2, w = 0.6, color = def.color, dur = 0.6, ease = E.inq, hold = 0.9 })
	Kit.after(0.6, function()
		local c = focusOf(by, pos)
		if c == pos then Kit.poly(c, 0.6, 7, def.color, 0.3, { tr = 0.3 }) end
		Kit.chunks(c, 14, { colors = { def.color, rgb(90, 0, 10) }, smin = 0.2, smax = 0.4, speed = 9, up = 12, g = 60, floor = floor.Y, life = 1 })
	end)
	Sfx.at("GhostWhisper", pos, { PlaybackSpeed = 0.7, Volume = 1 })
end

-- a blood moon rises behind the caster and the whole picture turns red
function sigs.moon(by, def, pos, floor, look)
	sigs.blood(by, def, pos, floor, look)
	Acts.grade({ TintColor = rgb(255, 170, 165), Contrast = 0.12, Saturation = -0.15 }, def.dur, 0.6)
	local top = math.min(Kit.ceiling(pos, 30) - 4.5, pos.Y + 12)
	local c = Vector3.new(pos.X, top, pos.Z) + look * (own and 14 or -5) -- behind the caster; in front for your own
	local parts: { Part } = {}
	for i = 1, 4 do
		parts[i] = Kit.part(Vector3.new(7.4, 7.4, 0.3), CFrame.new(c), i % 2 == 0 and rgb(170, 10, 20) or def.color, nil, 1)
	end
	local spots = { { -1.2, 1.1, 1.7 }, { 1.5, -0.6, 1.2 }, { -0.4, -1.8, 0.9 } }
	local dark: { Part } = {}
	for i in spots do dark[i] = Kit.part(Vector3.one, CFrame.new(c), rgb(110, 0, 12), nil, 1) end
	Kit.loop(4, function(a, _, el)
		local face = CFrame.lookAt(c + UP * (E.out(math.min(1, el / 1.2)) * 2 - 2), Vector3.new(workspace.CurrentCamera.CFrame.Position.X, c.Y, workspace.CurrentCamera.CFrame.Position.Z))
		local tr = el < 0.6 and 1 - el / 0.6 or math.clamp((el - 3) / 1, 0, 1)
		for i, p in parts do
			p.CFrame = face * CFrame.Angles(0, 0, i * math.pi / 8)
			p.Transparency = 0.1 + tr * 0.9
		end
		for i, s in spots do
			dark[i].Size = Vector3.new(s[3], s[3], 0.36)
			dark[i].CFrame = face * CFrame.new(s[1], s[2], 0) * CFrame.Angles(0, 0, i)
			dark[i].Transparency = 0.05 + tr * 0.95
		end
		if a >= 1 then
			for _, p in parts do p:Destroy() end
			for _, p in dark do p:Destroy() end
		end
		return nil
	end)
	Kit.light(c, def.color, 40, 4, 3.5)
end

-- bullets hang in the air, crawling forward, leaving ripples
function sigs.bullets(_by, def, pos, _floor, look)
	local right = look:Cross(UP)
	for i = 1, 5 do
		local from = pos + UP * rand(0.5, 2.4) + right * rand(-3, 3) + look * rand(2, 5)
		local b = Kit.part(Vector3.new(0.22, 0.22, 0.7), CFrame.lookAt(from, from + look), rgb(214, 170, 70), Enum.Material.Metal)
		local acc = rand(0, 0.5)
		Kit.loop(3.2, function(a, dt, el)
			local at = from + look * el * 2.4
			b.CFrame = CFrame.lookAt(at, at + look) * CFrame.Angles(0, 0, el * 6)
			acc += dt
			if acc > 0.55 then
				acc = 0
				Kit.ring(CFrame.lookAt(at, at + look) * CFrame.Angles(math.pi / 2, 0, 0), { r0 = 0.2, r1 = 1.5, n = 8, h = 0.08, w = 0.08, color = WHITE, tr = 0.3, dur = 0.6, lift = false })
			end
			if a > 0.85 then b.Transparency = (a - 0.85) / 0.15 end
			if a >= 1 then b:Destroy() end
			return nil
		end)
	end
	Kit.ring(Kit.floor(pos), { r0 = 1, r1 = 30, n = 20, h = 0.3, w = 0.5, color = def.color, tr = 0.4, dur = 1.2, ease = E.out3 })
	Sfx.at("Click", pos, { PlaybackSpeed = 0.4, Volume = 1 })
end

-- the light is pulled out of the room
function sigs.void(by, def, pos, floor)
	Kit.gather(function() return focusOf(by, pos) end, 22, 12, 0.5, { rgb(8, 4, 14), def.color, rgb(40, 20, 60) }, 0.6)
	Kit.ring(floor + UP * 0.1, { r0 = 14, r1 = 0.5, n = 16, h = 0.2, w = 0.8, color = def.color, dur = 0.5, ease = E.inq, hold = 0.9, spin = -3 })
	local c = focusOf(by, pos)
	if c == pos then Kit.poly(c, 6, 0.4, rgb(8, 4, 14), 0.45, { tr = 0.3, mat = SP, ease = E.inq, hold = 0.9 }) end
	Sfx.at("Vacuum", pos, { PlaybackSpeed = 0.5, Volume = 0.7 })
end

-- a soft pillar of light on the caster, a halo climbing off the head
function sigs.holy(_by, def, pos, floor)
	local pale = def.color:Lerp(WHITE, 0.5)
	Kit.column(floor, 1, 5, 60, pale, 0.9, 0.55, 0.3)
	for i = 0, 2 do
		Kit.after(i * 0.12, function()
			Kit.ring(pos + UP * (2.6 + i * 0.4), { r0 = 0.9, r1 = 1.6 + i * 1.4, n = 12, h = 0.2, w = 0.2, color = def.color, dur = 0.8, lift = false })
		end)
	end
	Kit.chunks(floor + UP * 0.5, 16, { colors = { pale, WHITE }, smin = 0.12, smax = 0.3, speed = 3, up = 9, g = -6, life = 1.3, spread = 3 })
	Kit.light(pos, def.color, 35, 4, 0.9)
	Sfx.at("Ultimate", pos, { PlaybackSpeed = 1.8, Volume = 0.6 })
end

-- rage with nowhere to go: the floor lifts in pebbles, red arcs crawl over the caster
function sigs.berserk(by, def, pos, floor, look)
	sigs.roar(by, def, pos, floor, look)
	Kit.ring(floor, { r0 = 1, r1 = 14, n = 18, h = 2, h1 = 0.3, w = 0.8, color = def.color, dur = 0.5 })
	Kit.cracks(floor, 9, 9, def.color, 5)
	Kit.chunks(floor + UP * 0.3, 20, { colors = { rgb(92, 80, 68), rgb(70, 62, 56) }, mat = SP, smin = 0.25, smax = 0.7, speed = 1, up = 5, g = -3, life = 1.6, spread = 8, spin = 0.3 })
	for i = 1, own and 0 or 10 do
		Kit.after(i * 0.07, function()
			local r = rootOf(by)
			local c = r and r.Position or pos
			local a = c + Kit.rng:NextUnitVector() * 2.5
			local b = a + Kit.rng:NextUnitVector() * 3
			Kit.fade(Kit.line(a, b, 0.2, i % 2 == 0 and WHITE or def.color), 0.04, 0.14)
		end)
	end
end

-- everything falls into the caster before the star goes off (the nova itself is the shockwave action)
function sigs.implode(by, def, pos, floor)
	if focusOf(by, pos) == pos then Kit.poly(pos + UP, 0.8, 3, WHITE, 0.3, { tr = 0, n = 4 }) end
	Kit.light(floor + UP * 3, def.color, 40, 6, 0.4)
end

-- a pillar of white gold; the floor's dust rises with you
function sigs.god(_by, def, pos, floor)
	local gold = rgb(255, 236, 170)
	Kit.column(floor, 1.5, 5.5, 90, gold, 1.2, 0.55, 0.3)
	for i = 0, 4 do
		Kit.after(i * 0.1, function()
			Kit.ring(floor + UP * (0.5 + i * 2.2), { r0 = 1, r1 = 6 + i, n = 16, h = 0.4, w = 0.4, color = i % 2 == 0 and WHITE or gold, dur = 0.7, lift = false })
		end)
	end
	Kit.ring(floor, { r0 = 1, r1 = 22, n = 22, h = 2.2, h1 = 0.3, w = 1, color = WHITE, color1 = gold, dur = 0.7 })
	Kit.cracks(floor, 10, 10, gold, 5)
	Kit.chunks(floor + UP * 0.3, 30, { colors = { gold, WHITE }, smin = 0.15, smax = 0.5, speed = 2, up = 8, g = -6, life = 1.8, spread = 9, spin = 0.3 })
	Kit.light(pos + UP * 3, gold, 60, 8, 1.4)
	Sfx.at("Ultimate", pos, { PlaybackSpeed = 0.9, Volume = 1.2 })
	if HUD then HUD.flash(WHITE, 0.5) end
end

-- a burst of punches: rings snap out along your look, one per jab
function sigs.combo(_by, def, pos, _floor, look)
	local right = look:Cross(UP)
	for i = 0, 5 do
		Kit.after(i * 0.085, function()
			local at = pos + UP * 1.2 + look * (3 + i * 0.6) + right * (i % 2 == 0 and 0.9 or -0.9)
			Kit.ring(CFrame.lookAt(at, at + look) * CFrame.Angles(math.pi / 2, 0, 0), { r0 = 0.3, r1 = 2.6, n = 10, h = 0.25, w = 0.25, color = i % 2 == 0 and def.color or WHITE, dur = 0.25, lift = false })
			Kit.poly(at, 0.4, 1.6, WHITE, 0.14, { tr = 0.05, n = 2 })
			Sfx.at("PunchLight", at, { PlaybackSpeed = 1.1 + i * 0.07, Volume = 0.6 })
		end)
	end
end

-- a red flare marks the target for the bomber
function sigs.flare(_by, _def, pos, floor)
	local red = rgb(255, 40, 25)
	local g, hrp = Acts.ghost()
	local at = hrp and Kit.floor(hrp.Position) or floor
	if not g then at = floor end
	Kit.loop(1.9, function(a, _, el)
		if math.floor(el / 0.16) % 2 == 0 and a < 1 then
			local p = Kit.part(Vector3.new(0.5, 70, 0.5), CFrame.new(at + UP * 35), red, nil, 0.25)
			Kit.kill(p, 0.08)
		end
		return nil
	end)
	Kit.chunks(at + UP * 0.5, 14, { colors = { red, rgb(255, 150, 120) }, smin = 0.2, smax = 0.5, speed = 4, up = 16, g = -4, life = 1.4, spread = 1 })
	Sfx.at("Click", pos, { PlaybackSpeed = 1.6, Volume = 1 })
	Sfx.at("Breaker", pos, { PlaybackSpeed = 1.4, Volume = 0.4 })
end

-- all the power in the room runs into one fist
function sigs.gold(by, def, pos, floor)
	local function target(): Vector3 return focusOf(by, pos) end
	Kit.gather(target, 46, 16, 0.75, { def.color, WHITE, rgb(255, 170, 0) }, 0.55)
	for i = 0, 2 do
		Kit.after(i * 0.2, function()
			Kit.ring(floor + UP * 0.1, { r0 = 14 - i * 3, r1 = 0.8, n = 16, h = 0.3, w = 0.6, color = def.color, dur = 0.35, ease = E.inq, hold = 0.9 })
		end)
	end
	Kit.after(0.75, function()
		local c = target()
		if c == pos then Kit.poly(c, 1, 9, WHITE, 0.3, { tr = 0, color1 = def.color, n = 4 }) end
		Kit.ring(floor, { r0 = 1, r1 = 16, n = 18, h = 1.6, h1 = 0.2, w = 0.7, color = def.color, dur = 0.45 })
		Kit.cracks(floor, 8, 9, def.color, 5)
		Kit.light(c, def.color, 40, 7, 0.6)
		Sfx.at("PunchHeavy", c, { PlaybackSpeed = 0.6, Volume = 1.2 })
		Kit.near(c, 0.6, 60)
	end)
end

-- AURA: what hangs round the caster's body while the ultimate is active (other players see it) ---------------
local function aura(by: Player, def: any, kind: string)
	local n = 10
	local pal = Acts.tint(def.color)
	local parts: { Part } = {}
	local seed: { { a: number, r: number, sp: number, ph: number, s: number } } = {}
	local mat = (kind == "fall" and def.id ~= "VampireRush" and def.id ~= "BloodMoon") and Enum.Material.Ice or Enum.Material.Neon
	for i = 1, n do
		parts[i] = Kit.part(Vector3.one * 0.3, CFrame.new(0, -500, 0), Kit.dim(pal[i % 3 + 1]), mat, 1)
		seed[i] = { a = i / n * math.pi * 2, r = rand(1.6, 2.8), sp = rand(0.6, 1.3), ph = rand(0, 1), s = rand(0.25, 0.55) }
	end
	local halo: { Part } = {}
	if def.id == "GodMode" or def.id == "GrandExorcism" then
		for i = 1, 10 do halo[i] = Kit.part(Vector3.new(0.5, 0.16, 0.16), CFrame.new(0, -500, 0), rgb(255, 236, 170), nil, 1) end
	end
	local light: PointLight? = nil
	local root0 = rootOf(by)
	if root0 then
		local l = Instance.new("PointLight")
		l.Name = "UltAura"; l.Color = def.color; l.Range = 16; l.Brightness = 1.6; l.Shadows = false
		l.Parent = root0
		light = l
	end
	local tick = 0
	Kit.loop(def.dur * 2 + 4, function(al, dt, el)
		local root = rootOf(by)
		if not root or al >= 1 or (el > 1.2 and not by:GetAttribute("UltActive")) then
			for _, p in parts do p:Destroy() end
			for _, p in halo do p:Destroy() end
			if light then light:Destroy() end
			return false
		end
		local ch = by.Character :: Model
		local sc = math.max(1, ch:GetScale())
		local hide = Kit.dist(root.Position) < 3.5 * sc -- first person: nothing floating in your own face
		local c = root.Position
		tick += dt
		for i, p in parts do
			local s = seed[i]
			if hide then p.Transparency = 1; continue end
			if kind == "rise" then
				local ph = (el * s.sp + s.ph) % 1
				p.Size = Vector3.one * s.s * (1.1 - ph) * sc
				p.CFrame = CFrame.new(c + Vector3.new(math.cos(s.a + ph) * s.r, -2.8 + ph * 6.5, math.sin(s.a + ph) * s.r) * sc) * CFrame.Angles(el * 2 + i, el, 0)
				p.Transparency = ph * 0.6
			elseif kind == "fall" then
				local ph = (el * s.sp * 0.8 + s.ph) % 1
				p.Size = Vector3.new(s.s * 0.5, s.s * 1.1, s.s * 0.5) * sc
				p.CFrame = CFrame.new(c + Vector3.new(math.cos(s.a) * s.r, 2.6 - ph * ph * 5.4, math.sin(s.a) * s.r) * sc)
				p.Transparency = 0.1 + ph * 0.5
			elseif kind == "orbit" then
				local ang = s.a + el * (1.6 + s.sp)
				p.Size = Vector3.new(s.s, s.s * 0.5, s.s * 1.3) * sc
				p.CFrame = CFrame.new(c + Vector3.new(math.cos(ang) * 2.7, math.sin(el * 2 + i * 1.3) * 1.9, math.sin(ang) * 2.7) * sc) * CFrame.Angles(0, -ang, 0)
				p.Transparency = 0.1
			elseif tick > 0.06 then -- arc: crackling slabs that jump about
				local o = Kit.rng:NextUnitVector() * rand(1.2, 2.6) * sc
				p.Size = Vector3.new(0.12, 0.12, rand(0.8, 2.2)) * sc
				p.CFrame = CFrame.lookAt(c + o, c + o + Kit.rng:NextUnitVector())
				p.Color = Kit.dim(Kit.rng:NextNumber() < 0.4 and WHITE or def.color, 0.6)
				p.Transparency = Kit.rng:NextNumber() < 0.55 and 0 or 1
			end
		end
		if tick > 0.06 then tick = 0 end
		for i, p in halo do
			local head = ch:FindFirstChild("Head") :: BasePart?
			local hc = (head and head.Position or c + UP * 2) + UP * 1.3 * sc
			p.CFrame = CFrame.new(hc) * CFrame.Angles(0, i / 10 * math.pi * 2 + el, 0) * CFrame.new(0, 0, -0.85 * sc)
			p.Size = Vector3.new(0.56, 0.16, 0.16) * sc
			p.Transparency = hide and 1 or 0
		end
		return nil
	end)
end

-- THE CAST --------------------------------------------------------------------------------------------------
function UltFx.cast(pos: Vector3, by: Player, ultId: string?)
	local def = Ultimates.byId[ultId or ""] or Ultimates.byId[Ultimates.default]
	local spec = SPEC[def.id] or SPEC.Rage
	local color: Color3 = def.color
	local mine = by == lp
	local rarity: number = def.rarity
	-- Studio photo hook: DebugUltFreezeAt counts from the cast, or (DebugUltMarkOn = "act") from the first
	-- effect the server sends for it
	actMark = RunService:IsStudio() and lp:GetAttribute("DebugUltMarkOn") == "act"
	if actMark then Kit.unmark() else Kit.mark() end
	local function where(): (Vector3, Vector3)
		local r = rootOf(by)
		if r then return r.Position, r.CFrame.LookVector end
		return pos, Vector3.zAxis
	end
	-- where the wind-up's light runs to: the caster's chest, or (your own cast, first person) your hands
	local function focus(): Vector3 return focusOf(by, pos) end
	-- wind-up: the room's light runs into the caster, a ring closes on the floor
	local floor0 = Kit.floor(pos)
	Kit.gather(focus, 8 + rarity * 4, 6 + rarity, CAST, Acts.tint(color), 0.3)
	Kit.ring(floor0 + UP * 0.1, { r0 = 5 + rarity, r1 = 0.8, n = 14, h = 0.16, w = 0.5, color = color, dur = CAST, ease = E.inq, hold = 0.9, spin = 2 })
	if spec.sig == "implode" then Kit.gather(focus, 40, 22, CAST, { WHITE, color }, 0.5) end
	Sfx.at("Ultimate", pos, { Volume = 1.1 })
	Sfx.at("Whoosh", pos, { PlaybackSpeed = 0.6, Volume = 1 })
	Pose.play(by.Character, spec.hands)
	if mine then
		VM.cast(spec.hands, color, spec.aura)
		if HUD then HUD.banner(string.upper(def.name), "", 1.8) end
	else
		aura(by, def, spec.aura)
	end
	if mine and RunService:IsStudio() and lp:GetAttribute("DebugCam") ~= nil then aura(by, def, spec.aura) end -- photo mode
	-- the beat: the signature goes off as the server's actions do
	local buffOnly = #def.acts == 0
	Kit.after(buffOnly and CAST * 0.9 or CAST, function()
		local p, look = where()
		local floor = Kit.floor(p)
		look = Vector3.new(look.X, 0, look.Z)
		look = look.Magnitude > 0.1 and look.Unit or Vector3.zAxis
		Kit.ring(floor, { r0 = 0.8, r1 = 5 + rarity * 1.5, n = 14, h = 0.9, h1 = 0.2, w = 0.5, color = color:Lerp(WHITE, 0.5), dur = 0.35 })
		if rarity >= 4 then
			Kit.column(floor, 0.6, 1.4 + rarity * 0.5, 50, color:Lerp(WHITE, 0.4), 0.5, 0.6)
			Kit.ring(floor, { r0 = 1, r1 = 12 + rarity * 2, n = 20, h = 0.4, w = 0.6, color = color, dur = 0.55 })
		end
		own = mine and (workspace.CurrentCamera.CFrame.Position - p).Magnitude < 4
		sigs[spec.sig](by, def, p, floor, look)
		own = false
		if mine and Fx then
			Fx.shake(0.55 + rarity * 0.1)
			Fx.kick(10 + rarity * 2.5)
			if HUD then HUD.flash(color, 0.3 + rarity * 0.06) end
		else
			Kit.near(p, 0.3 + rarity * 0.05, 50)
		end
		-- the actions the client draws by itself (the server only changes the game state for these)
		for _, a in def.acts do
			local t = a.type
			if t == "vortex" then Acts.vortex(a.t, a.r, color, def.id == "FurnitureTornado")
			elseif t == "launch" then Acts.launch(color, a.h > 60)
			elseif t == "burn" then Acts.burn(a.t, a.dps, a.color or color)
			elseif t == "slow" then Acts.slow(a.t, color)
			elseif t == "heal" then Acts.heal(by, def.id == "GodMode" and rgb(255, 236, 170) or rgb(110, 240, 130))
			elseif t == "stamina" then Acts.stamina(by, rgb(255, 230, 90))
			elseif t == "giant" then Acts.giant(by, a.scale, a.t, color)
			end
		end
	end)
end

-- server events (see Server/UltRunner). go() = false while a Studio photo holds the clock (an effect started
-- on a stopped clock would hang in its first frame)
local function go(): boolean
	if actMark then actMark = false; Kit.mark() end
	return not Kit.frozen()
end
function UltFx.shock(center: Vector3, r: number, color: Color3, id: string?) if go() then Acts.shock(center, r, color, id) end end
function UltFx.strike(style: string, pos: Vector3, color: Color3, id: string?) if go() then Acts.strike(style, pos, color, id) end end
function UltFx.freeze(gpos: Vector3, t: number) if go() then Acts.freeze(gpos, t) end end
function UltFx.timeStop(t: number) if go() then Acts.timeStop(t) end end
function UltFx.timeResume(pos: Vector3, stored: number) if go() then Acts.timeResume(pos, stored) end end
function UltFx.onePunch(pos: Vector3, by: Player) if go() then Acts.onePunch(pos, by) end end
function UltFx.fling(m: Instance, color: Color3) if go() then Acts.fling(m, color) end end

function UltFx.init(fx: any, hud: any)
	Fx = fx; HUD = hud
	Acts.init(fx, hud)
	Pose.init()
	if RunService:IsStudio() then
		-- Studio test hook: player attribute DebugUltFx = "<kind>" replays one effect at the camera's target
		-- (shock:<id> | strike:<style>:<id> | freeze | timestop | resume | onepunch)
		lp:GetAttributeChangedSignal("DebugUltFx"):Connect(function()
			local v = lp:GetAttribute("DebugUltFx")
			if type(v) ~= "string" or v == "" then return end
			local cam = workspace.CurrentCamera
			local _, hrp = Acts.ghost()
			local at = hrp and hrp.Position or (cam.CFrame.Position + cam.CFrame.LookVector * 25)
			local w = string.split(v, ":")
			local def = Ultimates.byId[w[#w]] or Ultimates.byId.Rage
			Kit.mark()
			if w[1] == "shock" then Acts.shock(at, 30, def.color, w[2])
			elseif w[1] == "strike" then Acts.strike(w[2], at, def.color, w[3])
			elseif w[1] == "freeze" then Acts.freeze(at, 4)
			elseif w[1] == "timestop" then Acts.timeStop(4)
			elseif w[1] == "resume" then Acts.timeResume(at, 300)
			elseif w[1] == "onepunch" then Acts.onePunch(at, lp)
			end
		end)
	end
end

return UltFx
