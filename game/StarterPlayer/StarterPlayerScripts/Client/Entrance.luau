--!strict
-- ENTRANCES: the short cinematic each monster makes when it comes into the house (Shared/Entrances has the
-- lengths, Client/EntrancePose moves the monster's body). The server fires Fx "Entrance" (model, id, evolved, title,
-- rarity, ghost number, seconds) right after spawning the monster; this module then, for that long:
--   * takes the camera to the monster (letterbox bars, the HUD hidden) and hands it back at the end,
--   * plays that monster's effects and sounds (SCRIPTS below, one per monster; an evolved monster plays its base
--     monster's entrance in its own colours, with something extra),
--   * slams the monster's NAME CARD on the screen at its big moment.
-- Everything runs on one clock, `s` (seconds since the start), shared with EntrancePose through EntrancePose.clock,
-- so the body, the camera and the effects stay together.
-- Studio test hooks (ReplicatedStorage attributes, set on the server): DebugEntranceFreezeAt = seconds at which the
-- clock stops (with DebugFreezeGhost the monster stays in its entrance), DebugEntranceScale = clock speed.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Monsters = require(RS.Shared.Monsters)
local EP = require(script.Parent.EntrancePose)
local Sfx = require(script.Parent.Sfx)
local Settings = require(script.Parent.Settings)
local Grunge = require(script.Parent.Grunge)
local MaskBreath = require(script.Parent.MaskBreath)

local Entrance = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local rng = Random.new()
local Fx: any = nil
local token = 0
function Entrance.init(fx: any, _hud: any) Fx = fx end

local UP = Vector3.yAxis
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
local FIRE = "rbxasset://textures/particles/fire_main.dds"
local function C(r: number, g: number, b: number): Color3 return Color3.fromRGB(r, g, b) end
local function seg(s: number, a: number, b: number): number return math.clamp((s - a) / (b - a), 0, 1) end
local function ss(x: number): number return x * x * (3 - 2 * x) end
local function lerp(a: number, b: number, x: number): number return a + (b - a) * x end

-- the two colours of each entrance: { normal, evolved }
local COLORS: { [string]: { { Color3 } } } = {
	Woman = { { C(170, 215, 225), C(60, 90, 100) }, { C(185, 100, 245), C(70, 20, 110) } },
	Demon = { { C(255, 120, 30), C(190, 30, 16) }, { C(230, 36, 20), C(90, 6, 6) } },
	Pirate = { { C(80, 215, 180), C(30, 90, 84) }, { C(255, 120, 36), C(150, 40, 10) } },
	Animatronic = { { C(255, 224, 160), C(200, 120, 60) }, { C(255, 208, 70), C(200, 140, 20) } },
	Titan = { { C(176, 140, 116), C(110, 60, 50) }, { C(232, 222, 200), C(150, 140, 124) } },
	Goblin = { { C(130, 230, 70), C(50, 110, 30) }, { C(246, 206, 66), C(50, 120, 44) } },
	Caller = { { C(236, 238, 244), C(120, 124, 136) }, { C(255, 48, 44), C(110, 10, 12) } },
	Conqueror = { { C(170, 96, 255), C(70, 20, 130) }, { C(255, 204, 76), C(160, 80, 255) } },
	Rat = { { C(150, 128, 104), C(70, 54, 40) }, { C(150, 220, 80), C(50, 76, 34) } },
	Knight = { { C(255, 40, 30), C(120, 10, 10) }, { C(190, 90, 255), C(70, 20, 120) } },
	Antlered = { { C(214, 204, 176), C(70, 56, 44) }, { C(255, 60, 40), C(90, 20, 14) } },
	LakeWitch = { { C(120, 200, 190), C(14, 34, 38) }, { C(90, 255, 200), C(10, 50, 40) } },
	Counselor = { { C(255, 140, 40), C(150, 40, 14) }, { C(255, 60, 20), C(80, 10, 6) } },
	Scarecrow = { { C(214, 182, 96), C(70, 54, 30) }, { C(255, 90, 40), C(60, 20, 10) } },
	Clown = { { C(255, 120, 120), C(120, 40, 40) }, { C(255, 210, 80), C(150, 60, 20) } },
	Strongman = { { C(200, 170, 130), C(90, 70, 50) }, { C(255, 120, 60), C(110, 30, 10) } },
	Fortune = { { C(200, 120, 255), C(60, 20, 90) }, { C(255, 120, 220), C(90, 10, 70) } },
	Ringmaster = { { C(255, 90, 90), C(120, 10, 20) }, { C(255, 210, 90), C(150, 80, 10) } },
	Nun = { { C(235, 230, 255), C(40, 30, 60) }, { C(255, 80, 60), C(60, 10, 10) } },
	Gravedigger = { { C(150, 255, 120), C(50, 40, 30) }, { C(255, 120, 60), C(60, 30, 10) } },
	Ringer = { { C(230, 170, 70), C(90, 60, 30) }, { C(255, 90, 40), C(90, 20, 10) } },
	Astronaut = { { C(255, 170, 80), C(70, 80, 100) }, { C(170, 110, 255), C(30, 10, 60) } },
	Specimen = { { C(140, 255, 90), C(30, 70, 20) }, { C(255, 90, 200), C(60, 10, 50) } },
	Sentinel = { { C(255, 60, 50), C(60, 20, 20) }, { C(110, 220, 255), C(10, 40, 70) } },
}

type Ctx = {
	model: Model, hrp: BasePart, id: string, evolved: boolean, D: number, s: number,
	floor: Vector3, look: Vector3, cdir: Vector3, cright: Vector3, clear: number, ceil: number, H: number, back: number,
	c1: Color3, c2: Color3, folder: Folder, gui: ScreenGui, dark: Frame, flashF: Frame,
	events: { { t: number, fn: () -> () } }, frames: { (s: number, dt: number) -> () },
	camera: ((s: number) -> (Vector3, Vector3))?, card: () -> (), alive: () -> boolean, cleanup: { () -> () },
	-- the Void Knight's doorway in a real wall of the map (Server/KnightDoor), nil elsewhere
	door: { pos: Vector3, look: Vector3, w: number, h: number, plugs: { BasePart }, model: Instance? }?,
}

-- helpers ---------------------------------------------------------------------------------------------------
local function at(x: Ctx, t: number, fn: () -> ()) table.insert(x.events, { t = t, fn = fn }) end
local function each(x: Ctx, fn: (s: number, dt: number) -> ()) table.insert(x.frames, fn) end
local function shake(n: number) if Fx then Fx.shake(n) end end
local function kick(n: number) if Fx then Fx.kick(n) end end

local function part(x: Ctx, props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Material = Enum.Material.Neon; p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do (p :: any)[k] = v end
	p.Parent = x.folder
	return p
end
-- a flat disc lying on the floor (radius r)
local function disc(x: Ctx, pos: Vector3, r: number, color: Color3, transparency: number): Part
	return part(x, { Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, r * 2, r * 2), CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2),
		Color = color, Transparency = transparency })
end
-- a shockwave on the floor: a disc that grows from r0 to r1 and fades
local function ring(x: Ctx, pos: Vector3, color: Color3, r0: number, r1: number, life: number)
	local p = disc(x, pos + UP * 0.15, r0, color, 0.35)
	TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.12, r1 * 2, r1 * 2), Transparency = 1 }):Play()
	Debris:AddItem(p, life + 0.1)
end
local function emitter(x: Ctx, pos: Vector3, props: { [string]: any }): ParticleEmitter
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = SMOKE
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Rate = 0
	for k, v in props do (pe :: any)[k] = v end
	pe.Parent = a
	-- cleaned up with the entrance (after the last particles have died)
	table.insert(x.cleanup, function()
		pe.Enabled = false
		Debris:AddItem(a, 3)
	end)
	return pe
end
-- one burst of particles
local function burst(x: Ctx, pos: Vector3, props: { [string]: any }, n: number)
	local pe = emitter(x, pos, props)
	pe:Emit(Settings.fxCount(n))
	Debris:AddItem(pe.Parent :: Instance, 4)
end
-- particles from s = t0 to t1
local function stream(x: Ctx, t0: number, t1: number, pos: Vector3, props: { [string]: any }, rate: number): ParticleEmitter
	local pe = emitter(x, pos, props)
	pe.Enabled = false
	pe.Rate = rate
	each(x, function(s) pe.Enabled = s >= t0 and s < t1 end)
	return pe
end
local function light(x: Ctx, pos: Vector3, color: Color3, range: number, brightness: number): PointLight
	local p = part(x, { Size = Vector3.one * 0.2, Transparency = 1, Position = pos })
	local l = Instance.new("PointLight")
	l.Color = color; l.Range = range; l.Brightness = brightness; l.Shadows = false
	l.Parent = p
	return l
end
-- a jagged bolt of lightning from a to b
local function bolt(x: Ctx, a: Vector3, b: Vector3, color: Color3, width: number, life: number)
	local n = 6
	local last = a
	local side = (b - a).Magnitude * 0.12
	for i = 1, n do
		local p = a:Lerp(b, i / n)
		if i < n then p += Vector3.new(rng:NextNumber(-side, side), rng:NextNumber(-side, side), rng:NextNumber(-side, side)) end
		local len = (p - last).Magnitude
		local seg1 = part(x, { Size = Vector3.new(width, width, len), CFrame = CFrame.lookAt(last:Lerp(p, 0.5), p), Color = color, Transparency = 0.05 })
		TweenService:Create(seg1, TweenInfo.new(life), { Transparency = 1, Size = Vector3.new(width * 0.2, width * 0.2, len) }):Play()
		Debris:AddItem(seg1, life + 0.05)
		last = p
	end
end
-- chunks of rubble thrown out from pos
local function chunks(x: Ctx, pos: Vector3, n: number, color: Color3, mat: Enum.Material, speed: number)
	for _ = 1, Settings.fxCount(n) do
		local sz = rng:NextNumber(0.4, 1.5)
		local p = Instance.new("Part")
		p.Size = Vector3.new(sz, sz * rng:NextNumber(0.3, 0.8), sz * rng:NextNumber(0.6, 1.2))
		p.Color = color:Lerp(Color3.new(0, 0, 0), rng:NextNumber(0, 0.35)); p.Material = mat
		p.CanCollide = true; p.CanQuery = false; p.CanTouch = false; p.CollisionGroup = "Debris"
		p.CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-2, 2), rng:NextNumber(0.5, 2), rng:NextNumber(-2, 2))) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0)
		p.Parent = x.folder
		local a = rng:NextNumber(0, math.pi * 2)
		p.AssemblyLinearVelocity = Vector3.new(math.cos(a), rng:NextNumber(0.5, 1.4), math.sin(a)) * speed * rng:NextNumber(0.5, 1)
		p.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-12, 12), rng:NextNumber(-12, 12), rng:NextNumber(-12, 12))
	end
end
local function flash(x: Ctx, color: Color3, amount: number, time: number)
	x.flashF.BackgroundColor3 = color
	x.flashF.BackgroundTransparency = 1 - amount
	TweenService:Create(x.flashF, TweenInfo.new(time), { BackgroundTransparency = 1 }):Play()
end
-- the screen goes dark (amount 0..1) over `time` seconds
local function darkness(x: Ctx, amount: number, time: number)
	if time <= 0 then x.dark.BackgroundTransparency = 1 - amount; return end
	TweenService:Create(x.dark, TweenInfo.new(time), { BackgroundTransparency = 1 - amount }):Play()
end
-- a point in the camera's frame around the monster: `dist` in front (never past the free distance), `side`, `height`
local function spot(x: Ctx, dist: number, side: number, height: number): Vector3
	return x.floor + x.cdir * math.min(dist, x.clear) + x.cright * side + UP * math.min(height, x.ceil - 0.8)
end
-- where the body is while the Root joint carries it `z` studs back (EntrancePose) and `y` up
local function body(x: Ctx, z: number, y: number): Vector3
	return x.floor - x.look * (z * x.back) + UP * y
end
local function limb(x: Ctx, name: string): Vector3
	local p = x.model:FindFirstChild(name)
	return (p and p:IsA("BasePart")) and p.Position or (x.floor + UP * x.H * 0.6)
end
local SMOKE_FLOOR = { Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 8) }),
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.55), NumberSequenceKeypoint.new(1, 1) }),
	Lifetime = NumberRange.new(1.6, 2.6), Speed = NumberRange.new(2, 6), SpreadAngle = Vector2.new(88, 88), Drag = 1.5, RotSpeed = NumberRange.new(-30, 30),
	Rotation = NumberRange.new(0, 360), EmissionDirection = Enum.NormalId.Top }
local function with(base: { [string]: any }, more: { [string]: any }): { [string]: any }
	local t = table.clone(base)
	for k, v in more do t[k] = v end
	return t
end

-- the entrances ---------------------------------------------------------------------------------------------
local SCRIPTS: { [string]: (x: Ctx) -> () } = {}

-- THE WOMAN: a black pool of mist opens on the floor and she rises out of it, head down; then the scream
SCRIPTS.Woman = function(x)
	local T = EP.T.Woman
	local f = x.floor
	at(x, 0, function()
		Sfx.play("GhostWhisper", { Volume = 1.4, PlaybackSpeed = 0.7 })
		local pool = disc(x, f + UP * 0.08, 0.5, C(4, 6, 8), 0.1)
		pool.Material = Enum.Material.SmoothPlastic
		local rim = disc(x, f + UP * 0.05, 0.6, x.c1, 0.6)
		each(x, function(s)
			local r = 6.5 * ss(seg(s, 0, 1.1)) * (1 - ss(seg(s, x.D - 1.0, x.D - 0.3)))
			pool.Size = Vector3.new(0.12, r * 2, r * 2)
			rim.Size = Vector3.new(0.1, r * 2.16, r * 2.16)
		end)
		local l = light(x, f + UP * 2.5, x.c1, 28, 0)
		each(x, function(s) l.Brightness = 0.9 * seg(s, 0, 1) * (1 - seg(s, x.D - 0.8, x.D - 0.2)) + (s > T.scream and 1.2 * (1 - seg(s, T.scream, T.scream + 0.6)) or 0) end)
	end)
	stream(x, 0.1, T.calm, f + UP * 0.3, with(SMOKE_FLOOR, { Color = ColorSequence.new(x.c2, C(10, 12, 16)) }), 26)
	stream(x, T.rise0, T.scream, f + UP * 0.5, { Texture = SPARK, Color = ColorSequence.new(x.c1), LightEmission = 0.8, Size = NumberSequence.new(0.5, 0),
		Lifetime = NumberRange.new(1, 1.8), Speed = NumberRange.new(4, 9), SpreadAngle = Vector2.new(14, 14), EmissionDirection = Enum.NormalId.Top }, 22)
	at(x, 1.1, function() Sfx.play("GhostWail", { Volume = 0.5, PlaybackSpeed = 0.7 }) end)
	at(x, T.scream - 0.04, function()
		Sfx.play("GhostScream", { Volume = 1.1, PlaybackSpeed = 0.85 })
		flash(x, Color3.new(1, 1, 1), 0.55, 0.5)
		shake(0.9); kick(12)
		ring(x, f, x.c1, 2, 30, 0.7)
		task.delay(0.12, function() if x.alive() then ring(x, f, Color3.new(1, 1, 1), 2, 22, 0.6) end end)
		burst(x, f + UP * 1, with(SMOKE_FLOOR, { Color = ColorSequence.new(x.c2), Speed = NumberRange.new(18, 34), Lifetime = NumberRange.new(0.6, 1.2) }), 50)
		if x.evolved then
			for i = 1, 7 do
				local a = i / 7 * math.pi * 2
				bolt(x, f + UP * x.H * 0.7, f + Vector3.new(math.cos(a) * 11, rng:NextNumber(0, 6), math.sin(a) * 11), x.c1, 0.35, 0.35)
			end
		end
		x.card()
	end)
	x.camera = function(s)
		local k = ss(seg(s, 0, T.scream))
		local rise = ss(seg(s, T.rise0, T.rise1))
		local back = s > T.scream and seg(s, T.scream, T.scream + 0.25) * 2.5 or 0
		return spot(x, lerp(15, 8.5, k) + back, lerp(3.5, 1, k), lerp(1.4, x.H * 0.72, k)),
			f + UP * math.max(0.6, x.H * 0.86 - (x.H + 1.5) * (1 - rise))
	end
end

-- THE RED DEMON: a burning circle, a pillar of fire, and he stands up inside it and roars
SCRIPTS.Demon = function(x)
	local T = EP.T.Demon
	local f = x.floor
	local R = 5.5
	at(x, 0, function()
		Sfx.play("Telekinesis", { Volume = 0.9, PlaybackSpeed = 0.8 })
		-- the circle and its five-pointed star, drawn stroke by stroke
		local pts = {}
		for i = 0, 4 do
			local a = i / 5 * math.pi * 2 + math.pi / 2
			table.insert(pts, f + Vector3.new(math.cos(a) * R, 0.1, math.sin(a) * R))
		end
		local strokes = {} :: { Part }
		for i = 1, 5 do
			local a, b = pts[i], pts[(i + 1) % 5 + 1]
			table.insert(strokes, part(x, { Size = Vector3.new(0.3, 0.1, (b - a).Magnitude), CFrame = CFrame.lookAt(a:Lerp(b, 0.5), b), Color = x.c1, Transparency = 1 }))
		end
		for i = 1, 20 do
			local a0, a1 = (i - 1) / 20 * math.pi * 2, i / 20 * math.pi * 2
			local a, b = f + Vector3.new(math.cos(a0) * R, 0.1, math.sin(a0) * R), f + Vector3.new(math.cos(a1) * R, 0.1, math.sin(a1) * R)
			table.insert(strokes, part(x, { Size = Vector3.new(0.35, 0.1, (b - a).Magnitude + 0.1), CFrame = CFrame.lookAt(a:Lerp(b, 0.5), b), Color = x.c1, Transparency = 1 }))
		end
		each(x, function(s)
			for i, p in strokes do
				local on = seg(s, i * 0.03, i * 0.03 + 0.12) * (1 - seg(s, x.D - 0.9, x.D - 0.3))
				p.Transparency = 1 - on * (0.85 + math.sin(s * 9 + i) * 0.15)
			end
		end)
		for _, p in pts do
			stream(x, 0.3, x.D - 0.8, p, { Texture = FIRE, Color = ColorSequence.new(x.c1, x.c2), LightEmission = 0.9, Size = NumberSequence.new(1.6, 0.2),
				Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(4, 8), SpreadAngle = Vector2.new(10, 10), EmissionDirection = Enum.NormalId.Top }, 16)
		end
		local l = light(x, f + UP * 3, x.c1, 34, 0)
		each(x, function(s) l.Brightness = (0.8 + math.sin(s * 23) * 0.25) * seg(s, 0, 0.6) * (1 - seg(s, x.D - 0.7, x.D - 0.2)) + (s > T.pillar and 2 * (1 - seg(s, T.pillar, T.pillar + 1)) or 0) end)
	end)
	at(x, T.pillar, function()
		Sfx.play("Explosion", { Volume = 0.8, PlaybackSpeed = 1.15 })
		Sfx.play("FireLoop", { Volume = 1.2, PlaybackSpeed = 1.3 })
		shake(0.8); kick(8)
		flash(x, x.c1, 0.4, 0.4)
		local h = math.min(x.ceil, 40)
		local outer = part(x, { Shape = Enum.PartType.Cylinder, Color = x.c1, Transparency = 0.3 })
		local inner = part(x, { Shape = Enum.PartType.Cylinder, Color = C(255, 240, 190), Transparency = 0.1 })
		each(x, function(s)
			local r = 3.4 * (1 - ss(seg(s, T.pillar + 0.25, T.pillar + 1.15))) + 0.01
			for i, p in { outer, inner } do
				local rr = i == 1 and r or r * 0.5
				p.Size = Vector3.new(h, rr * 2, rr * 2)
				p.CFrame = CFrame.new(f + UP * h / 2) * CFrame.Angles(0, 0, math.pi / 2)
				p.Transparency = r < 0.05 and 1 or (i == 1 and 0.3 or 0.1)
			end
		end)
		ring(x, f, x.c1, 2, 18, 0.5)
		burst(x, f + UP * 1, { Texture = SPARK, Color = ColorSequence.new(x.c1), LightEmission = 1, Size = NumberSequence.new(0.7, 0), Lifetime = NumberRange.new(0.6, 1.3),
			Speed = NumberRange.new(20, 45), Acceleration = Vector3.new(0, -30, 0) }, 70)
	end)
	stream(x, T.pillar, T.pillar + 1.0, f + UP * 0.5, { Texture = FIRE, Color = ColorSequence.new(x.c1, x.c2), LightEmission = 1, Size = NumberSequence.new(3.5, 0.5),
		Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(26, 46), SpreadAngle = Vector2.new(8, 8), EmissionDirection = Enum.NormalId.Top }, 70)
	at(x, T.roar, function()
		Sfx.play(Sfx.voice("Spawn", "Demon"), { Volume = 1.3 })
		Sfx.play("DemonRoar", { Volume = 0.9, PlaybackSpeed = 0.9 })
		shake(0.9); kick(12)
		flash(x, x.c1, 0.3, 0.35)
		ring(x, f, x.c1, 3, 30, 0.7)
		burst(x, f + UP * x.H * 0.5, { Texture = SPARK, Color = ColorSequence.new(x.c1), LightEmission = 1, Size = NumberSequence.new(0.6, 0), Lifetime = NumberRange.new(0.7, 1.4),
			Speed = NumberRange.new(16, 36), Acceleration = Vector3.new(0, 6, 0) }, 90)
		if x.evolved then
			for i = 1, 4 do
				local a = i / 4 * math.pi * 2 + math.pi / 4
				local base = f + Vector3.new(math.cos(a) * 9, 0, math.sin(a) * 9)
				local h = math.min(x.ceil, 30)
				local col = part(x, { Shape = Enum.PartType.Cylinder, Color = x.c1, Transparency = 0.25, Size = Vector3.new(h, 1.6, 1.6), CFrame = CFrame.new(base + UP * h / 2) * CFrame.Angles(0, 0, math.pi / 2) })
				TweenService:Create(col, TweenInfo.new(0.9), { Size = Vector3.new(h, 0.05, 0.05), Transparency = 1 }):Play()
			end
		end
		x.card()
	end)
	x.camera = function(s)
		local k = ss(seg(s, 0, x.D))
		local stand = ss(seg(s, T.stand0, T.stand1))
		return spot(x, lerp(14, 10.5, k), lerp(-4.5, -1.5, k), lerp(2, 3.4, k)), f + UP * x.H * lerp(0.36, 0.64, stand)
	end
end

-- THE PIRATE: walks out of the sea fog, bangs his cutlass on his shield twice, then raises it
SCRIPTS.Pirate = function(x)
	local T = EP.T.Pirate
	local f = x.floor
	local fogCol = x.evolved and ColorSequence.new(x.c1, C(40, 14, 6)) or ColorSequence.new(x.c1, C(16, 40, 44))
	for i = 1, 3 do
		stream(x, 0, T.walk1 + 0.3, body(x, 3 + i * 3, 0.6) + x.cright * (i - 2) * 3, with(SMOKE_FLOOR, { Color = fogCol, Size = NumberSequence.new(5, 12), LightEmission = x.evolved and 0.5 or 0.25,
			Speed = NumberRange.new(3, 9) }), 16)
	end
	if x.evolved then
		stream(x, 0, x.D - 0.6, body(x, 5, 0.4), { Texture = SPARK, Color = ColorSequence.new(x.c1), LightEmission = 1, Size = NumberSequence.new(0.5, 0), Lifetime = NumberRange.new(1, 2),
			Speed = NumberRange.new(4, 12), SpreadAngle = Vector2.new(40, 40), EmissionDirection = Enum.NormalId.Top }, 30)
	end
	at(x, 0, function()
		local l = light(x, body(x, 10, x.H * 0.8), x.c1, 36, 0)
		each(x, function(s) l.Brightness = 1.3 * seg(s, 0, 0.5) * (1 - seg(s, x.D - 0.8, x.D - 0.2)) end)
	end)
	for _, t in { 0.15, 1.25 } do
		at(x, t, function() Sfx.play("ShieldBlock", { Volume = 0.9, PlaybackSpeed = 0.42 }) end) -- a ship's bell, far off
	end
	for i = 0, 5 do
		at(x, T.walk0 + 0.25 + i * 0.39, function()
			if x.s < T.walk1 then Sfx.play("PunchLight", { Volume = 0.45, PlaybackSpeed = 0.5 }); shake(0.08) end
		end)
	end
	for _, t in { T.bang1, T.bang2 } do
		at(x, t, function()
			local at1 = limb(x, "LeftHand")
			Sfx.play("ShieldBlock", { Volume = 1.5, PlaybackSpeed = 1 })
			shake(0.3)
			burst(x, at1, { Texture = SPARK, Color = ColorSequence.new(C(255, 220, 150)), LightEmission = 1, Size = NumberSequence.new(0.5, 0), Lifetime = NumberRange.new(0.15, 0.4),
				Speed = NumberRange.new(12, 26) }, 26)
		end)
	end
	at(x, T.raise + 0.12, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.3 })
		shake(0.6); kick(10)
		flash(x, x.c1, 0.25, 0.4)
		ring(x, f, x.c1, 2, 26, 0.7)
		burst(x, f + UP, with(SMOKE_FLOOR, { Color = fogCol, Speed = NumberRange.new(16, 30), Lifetime = NumberRange.new(0.6, 1.2) }), 40)
		x.card()
	end)
	x.camera = function(s)
		local k = ss(seg(s, 0, T.raise))
		local walk = seg(s, T.walk0, T.walk1)
		return spot(x, lerp(13, 9.5, k), lerp(6, 2.5, k), x.H * lerp(0.5, 0.62, k)), body(x, 10 * (1 - walk), x.H * 0.62)
	end
end

-- THE PARTY BEAR: the lights go out, a music box plays, a spotlight snaps on: showtime
SCRIPTS.Animatronic = function(x)
	local T = EP.T.Animatronic
	local f = x.floor
	local box: Sound? = nil
	at(x, 0, function()
		darkness(x, 0.95, 0.35)
		box = Sfx.play("MusicBox", { Volume = 0.9, PlaybackSpeed = 0.85 })
	end)
	at(x, T.light, function()
		Sfx.play("Breaker", { Volume = 1.2, PlaybackSpeed = 0.6 })
		darkness(x, 0.5, 0.05)
		shake(0.2)
		local top = f + UP * math.min(x.ceil - 0.4, x.H + 12)
		local lamp = part(x, { Size = Vector3.new(1.2, 0.3, 1.2), Position = top, Color = x.c1, Transparency = 0 })
		local sl = Instance.new("SpotLight")
		sl.Face = Enum.NormalId.Bottom; sl.Angle = 46; sl.Range = 50; sl.Brightness = 4; sl.Color = x.c1; sl.Parent = lamp
		local h = (top - f).Magnitude
		local cone = part(x, { Shape = Enum.PartType.Cylinder, Color = x.c1, Transparency = 0.9, Size = Vector3.new(h, x.H * 1.0, x.H * 1.0), CFrame = CFrame.new(f + UP * h / 2) * CFrame.Angles(0, 0, math.pi / 2) })
		local pool = disc(x, f + UP * 0.06, x.H * 0.62, x.c1, 0.72)
		each(x, function(s)
			local flick = (s > T.calm and math.sin(s * 60) > 0.2) and 0.3 or 1
			local out = 1 - seg(s, x.D - 0.5, x.D - 0.15)
			sl.Brightness = 4 * flick * out
			cone.Transparency = 1 - 0.1 * flick * out
			pool.Transparency = 1 - 0.28 * flick * out
		end)
	end)
	local confetti = ColorSequence.new({ ColorSequenceKeypoint.new(0, C(255, 80, 80)), ColorSequenceKeypoint.new(0.35, x.c1), ColorSequenceKeypoint.new(0.7, C(90, 170, 255)), ColorSequenceKeypoint.new(1, C(120, 230, 110)) })
	if x.evolved then confetti = ColorSequence.new(x.c1, C(255, 244, 190)) end
	stream(x, T.light, x.D - 0.4, f + UP * math.min(x.ceil - 1, x.H + 8), { Texture = SPARK, Color = confetti, LightEmission = 0.5, Size = NumberSequence.new(0.45), Lifetime = NumberRange.new(2, 3),
		Speed = NumberRange.new(2, 7), SpreadAngle = Vector2.new(70, 70), EmissionDirection = Enum.NormalId.Bottom, Acceleration = Vector3.new(0, -9, 0), RotSpeed = NumberRange.new(-200, 200) }, 26)
	for i = 0, 2 do
		at(x, T.head + i * 0.13, function() Sfx.play("Click", { Volume = 0.8, PlaybackSpeed = 0.6 }) end)
	end
	at(x, T.tada + 0.1, function()
		Sfx.play(Sfx.voice("Spawn", "Animatronic"), { Volume = 1.3 })
		shake(0.45); kick(10)
		flash(x, x.c1, 0.25, 0.35)
		burst(x, f + UP * (x.H + 1), { Texture = SPARK, Color = confetti, LightEmission = 0.6, Size = NumberSequence.new(0.5), Lifetime = NumberRange.new(1.5, 2.6), Speed = NumberRange.new(10, 26),
			Acceleration = Vector3.new(0, -16, 0), RotSpeed = NumberRange.new(-200, 200) }, 90)
		x.card()
	end)
	at(x, T.tada + 0.85, function() Sfx.play("AnimGrowl", { Volume = 0.8, PlaybackSpeed = 0.8 }) end)
	if x.evolved then
		-- the Golden Bear's finger snap brings every light back at once
		at(x, T.snap, function()
			Sfx.play("FingerSnap", { Volume = 3 })
			task.delay(0.16, function() Sfx.play("FingerSnap", { Volume = 0.9, PlaybackSpeed = 0.8 }) end)
			flash(x, Color3.new(1, 1, 1), 0.85, 0.5)
			darkness(x, 0, 0)
			shake(0.6)
			ring(x, f, x.c1, 2, 30, 0.7)
			burst(x, limb(x, "RightHand"), { Texture = SPARK, Color = ColorSequence.new(x.c1), LightEmission = 1, Size = NumberSequence.new(0.8, 0), Lifetime = NumberRange.new(0.2, 0.5),
				Speed = NumberRange.new(16, 30) }, 40)
		end)
	else
		at(x, T.calm, function() darkness(x, 0, 0.6) end)
	end
	at(x, T.calm, function()
		local b = box
		if b and b.Parent then
			TweenService:Create(b, TweenInfo.new(0.6), { Volume = 0 }):Play()
			Debris:AddItem(b, 0.7)
		end
	end)
	x.camera = function(s)
		local zoom = ss(seg(s, T.tada, T.tada + 0.18))
		return spot(x, lerp(13, 9, zoom), 0.4, x.H * 0.6), f + UP * x.H * lerp(0.6, 0.72, zoom)
	end
end

-- THE FLAYED GIANT: the ceiling shakes three times, then he comes down through it and lands on one fist
SCRIPTS.Titan = function(x)
	local T = EP.T.Titan
	local f = x.floor
	local top = f + UP * (x.ceil - 0.6)
	local dust = { Color = ColorSequence.new(x.c1, x.c2), Size = NumberSequence.new(2.5, 7), Transparency = NumberSequence.new(0.35, 1), Lifetime = NumberRange.new(1, 2.2), Drag = 2 }
	for i, t in { 0, 0.5, 1.0 } do
		at(x, t, function()
			Sfx.play("Crash", { Volume = 0.35 + i * 0.12, PlaybackSpeed = 0.5 })
			shake(0.2 + i * 0.1)
			burst(x, top, with(dust, { Speed = NumberRange.new(2, 8), Acceleration = Vector3.new(0, -26, 0), SpreadAngle = Vector2.new(60, 60), EmissionDirection = Enum.NormalId.Bottom,
				Size = NumberSequence.new(1.2, 3) }), 10 + i * 6)
			if i > 1 then chunks(x, top - UP * 2, 3, x.c1, Enum.Material.Concrete, 6) end
		end)
	end
	at(x, T.fall, function() Sfx.play("Whoosh", { Volume = 1.3, PlaybackSpeed = 0.5 }) end)
	at(x, T.land, function()
		Sfx.play("Explosion", { Volume = 0.9, PlaybackSpeed = 0.8 })
		Sfx.play("WoodBreak", { Volume = 1.2, PlaybackSpeed = 0.8 })
		Sfx.play("Crash", { Volume = 1 })
		shake(1.2); kick(14)
		flash(x, Color3.new(1, 1, 1), 0.4, 0.35)
		ring(x, f, x.c1, 3, 32, 0.8)
		task.delay(0.1, function() if x.alive() then ring(x, f, Color3.new(1, 1, 1), 2, 20, 0.5) end end)
		chunks(x, f + UP, 18, x.c1, x.evolved and Enum.Material.Marble or Enum.Material.WoodPlanks, 34)
		chunks(x, top - UP * 2, 12, x.c2, Enum.Material.Concrete, 16)
		burst(x, f + UP * 1.5, with(dust, { Speed = NumberRange.new(14, 38), SpreadAngle = Vector2.new(85, 85), EmissionDirection = Enum.NormalId.Top }), 110)
		-- cracks in the floor round his fist
		for i = 1, 9 do
			local a = i / 9 * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
			local len = rng:NextNumber(5, 11)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local c = part(x, { Material = Enum.Material.SmoothPlastic, Color = C(8, 6, 6), Size = Vector3.new(rng:NextNumber(0.25, 0.6), 0.08, len),
				CFrame = CFrame.lookAt(f + dir * (len / 2 + 1.5) + UP * 0.06, f + dir * 40 + UP * 0.06) * CFrame.Angles(0, rng:NextNumber(-0.25, 0.25), 0) })
			each(x, function(s) c.Transparency = seg(s, x.D - 0.7, x.D - 0.2) end)
		end
	end)
	stream(x, T.land, T.roar, f + UP * x.H * 0.5, { Color = ColorSequence.new(C(230, 225, 220)), Size = NumberSequence.new(1.5, 5), Transparency = NumberSequence.new(0.6, 1), Lifetime = NumberRange.new(1, 2),
		Speed = NumberRange.new(3, 7), SpreadAngle = Vector2.new(30, 30), EmissionDirection = Enum.NormalId.Top }, 14)
	at(x, T.roar + 0.05, function()
		Sfx.play("DemonRoar", { Volume = 1.4, PlaybackSpeed = 0.72 })
		shake(1.0); kick(12)
		ring(x, f, x.c1, 3, 30, 0.7)
		burst(x, f + UP * x.H * 0.75, with(dust, { Speed = NumberRange.new(20, 40), Lifetime = NumberRange.new(0.5, 1) }), 50)
		x.card()
	end)
	at(x, 0, function()
		local l = light(x, spot(x, 6, 2, x.H * 0.7), C(255, 226, 200), 40, 0)
		each(x, function(s) l.Brightness = 0.6 * seg(s, T.fall, T.land) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	x.camera = function(s)
		local fall = seg(s, T.fall, T.land)
		local rise = ss(seg(s, T.rise0, T.rise1))
		local y: number
		if s < T.fall then
			y = lerp(x.H * 0.5, x.ceil - 1, ss(seg(s, 0, 1.1)))
		elseif s < T.land then
			y = lerp(x.ceil - 1, x.H * 0.35, fall * fall)
		else
			y = x.H * lerp(0.35, 0.62, rise)
		end
		local pull = s >= T.land and 3 * (1 - seg(s, T.land, T.land + 1.2)) or 0
		return spot(x, lerp(17, 13.5, ss(seg(s, 0, x.D))) + pull, 5, lerp(1.5, 2.6, rise)), f + UP * y
	end
end

-- THE GOBLIN: smoke puffs here, there... and he somersaults out of the last one, rubs his hands and points at you
SCRIPTS.Goblin = function(x)
	local T = EP.T.Goblin
	local f = x.floor
	local smoke = { Color = ColorSequence.new(x.c1, x.c2), Size = NumberSequence.new(2, 6), Transparency = NumberSequence.new(0.25, 1), Lifetime = NumberRange.new(0.6, 1.3),
		Speed = NumberRange.new(6, 16), Drag = 3, LightEmission = 0.3 }
	local p1 = f + x.cright * 6.5 + x.cdir * 1.5
	local p2 = f - x.cright * 6 + x.cdir * 2.5
	local function puff(pos: Vector3, n: number)
		burst(x, pos + UP * 1.5, smoke, n)
		burst(x, pos + UP * 1.5, { Texture = SPARK, Color = ColorSequence.new(x.c1), LightEmission = 1, Size = NumberSequence.new(0.6, 0), Lifetime = NumberRange.new(0.3, 0.7),
			Speed = NumberRange.new(8, 20) }, n)
		local l = light(x, pos + UP * 2, x.c1, 22, 4)
		TweenService:Create(l, TweenInfo.new(0.6), { Brightness = 0 }):Play()
		Sfx.play("Whoosh", { Volume = 0.9, PlaybackSpeed = 1.7 })
	end
	at(x, 0, function() Sfx.play("GoblinCackle", { Volume = 1 }) end)
	at(x, T.puff1, function() puff(p1, 26) end)
	at(x, T.puff2, function() puff(p2, 26); Sfx.play("GoblinGrowl", { Volume = 0.7, PlaybackSpeed = 1.2 }) end)
	at(x, T.flip, function() puff(f + UP * 5, 50); shake(0.25) end)
	at(x, T.land, function()
		Sfx.play("PunchHeavy", { Volume = 1, PlaybackSpeed = 0.7 })
		shake(x.evolved and 0.8 or 0.4); kick(8)
		ring(x, f, x.c1, 1.5, x.evolved and 24 or 12, 0.5)
		-- coins
		burst(x, f + UP, { Texture = SPARK, Color = ColorSequence.new(C(255, 214, 80)), LightEmission = 1, Size = NumberSequence.new(0.5, 0.2), Lifetime = NumberRange.new(0.8, 1.5),
			Speed = NumberRange.new(14, 30), SpreadAngle = Vector2.new(50, 50), EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, -50, 0) }, 50)
		if x.evolved then Sfx.play("Crash", { Volume = 0.7 }); chunks(x, f + UP, 8, C(90, 70, 50), Enum.Material.WoodPlanks, 22) end
	end)
	at(x, T.point, function()
		Sfx.play(Sfx.voice("Spawn", "Goblin"), { Volume = 1.3 })
		Sfx.play("GoblinCackle", { Volume = 1.1, PlaybackSpeed = 1.1 })
		shake(0.35); kick(8)
		flash(x, x.c1, 0.2, 0.3)
		x.card()
	end)
	at(x, 0, function()
		local l = light(x, spot(x, 5, 0, x.H * 0.9), C(235, 255, 215), 30, 0)
		each(x, function(s) l.Brightness = 0.6 * seg(s, T.flip, T.land) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	x.camera = function(s)
		local fl = seg(s, T.flip, T.land)
		local target: Vector3
		if s < T.puff2 - 0.1 then
			target = (f + UP * 2):Lerp(p1 + UP * 2, ss(seg(s, T.puff1 - 0.25, T.puff1 + 0.05)))
		elseif s < T.flip - 0.12 then
			target = (p1 + UP * 2):Lerp(p2 + UP * 2, ss(seg(s, T.puff2 - 0.1, T.puff2 + 0.12)))
		else
			local y = 7.5 * (1 - fl) * (1 + fl * 0.6)
			target = (p2 + UP * 2):Lerp(f + UP * (y + x.H * 0.5), ss(seg(s, T.flip - 0.12, T.flip + 0.1)))
		end
		local k = ss(seg(s, T.land, T.point))
		return spot(x, lerp(13, 10, k), lerp(0, 1.5, k), x.H * lerp(0.75, 0.55, k)), target
	end
end

-- THE CALLER: a phone rings in the dark, and every flash of light shows him closer
SCRIPTS.Caller = function(x)
	local T = EP.T.Caller
	local f = x.floor
	local phone: Sound? = nil
	local function ringPhone()
		if phone then phone:Destroy() end
		phone = Sfx.play("PhoneRing", { Volume = 1 })
	end
	at(x, 0, function()
		darkness(x, 0.94, 0.3)
		ringPhone()
	end)
	local function strobe(last: boolean)
		Sfx.play("Breaker", { Volume = 0.7, PlaybackSpeed = 1.5 })
		darkness(x, last and 0.42 or 0.12, 0)
		flash(x, x.evolved and x.c1 or Color3.new(1, 1, 1), 0.5, 0.2)
		local l = light(x, spot(x, 4, 1, x.H * 0.8), x.c1, 46, 3)
		if last then
			TweenService:Create(l, TweenInfo.new(0.5), { Brightness = 0.8 }):Play()
			each(x, function(s) if s > x.D - 0.6 then l.Brightness = 0.8 * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end end)
		else
			task.delay(EP.FLASH, function()
				l.Brightness = 0
				if x.alive() and x.s < T.flash3 then darkness(x, 0.94, 0) end
			end)
		end
	end
	at(x, T.flash1, function() strobe(false) end)
	at(x, T.flash1 + 0.35, ringPhone)
	at(x, T.flash2, function() strobe(false); shake(0.2) end)
	at(x, T.flash3, function()
		strobe(true)
		shake(0.45); kick(10)
		if phone then phone:Destroy(); phone = nil end
		Sfx.play("Click", { Volume = 1.2, PlaybackSpeed = 0.5 }) -- he hangs up
	end)
	at(x, T.raise + 0.5, function()
		Sfx.play(Sfx.voice("Spawn", "Caller"), { Volume = 1, PlaybackSpeed = 0.9 })
		x.card()
	end)
	if x.evolved then
		at(x, T.pump, function()
			Sfx.play("ShotgunPump", { Volume = 1.4 })
			shake(0.3)
		end)
	end
	at(x, x.D - 0.7, function() darkness(x, 0, 0.5) end)
	table.insert(x.cleanup, function() if phone then phone:Destroy() end end)
	x.camera = function(s)
		local push = ss(seg(s, T.flash3, x.D))
		return spot(x, lerp(10, 7.5, push), lerp(0.6, 1.4, push), x.H * 0.64), f + UP * x.H * lerp(0.62, 0.74, push)
	end
end

-- THE CONQUEROR: a portal tears open behind where he will stand; he walks out of it and closes his fist
SCRIPTS.Conqueror = function(x)
	local T = EP.T.Conqueror
	local f = x.floor
	local R = math.clamp(x.H * 0.72, 5, x.ceil * 0.5 - 0.3)
	local center = body(x, 6, R + 0.3)
	local rimCol = x.evolved and x.c1 or x.c2
	local core = x.evolved and x.c2 or x.c1
	at(x, T.portal, function()
		Sfx.play("Telekinesis", { Volume = 1, PlaybackSpeed = 0.7 })
		local face = CFrame.lookAt(center, center + x.look) * CFrame.Angles(0, math.pi / 2, 0)
		local rim = part(x, { Shape = Enum.PartType.Cylinder, Color = rimCol, Transparency = 0.1 })
		local hole = part(x, { Shape = Enum.PartType.Cylinder, Color = core, Transparency = 0.05 })
		local dark = part(x, { Shape = Enum.PartType.Cylinder, Color = C(6, 2, 12), Material = Enum.Material.SmoothPlastic, Transparency = 0 })
		local l = light(x, center + x.look * 2, core, 40, 0)
		local nextBolt = 0
		each(x, function(s)
			local r = R * ss(seg(s, T.portal, T.portal + 1.1)) * (1 - ss(seg(s, T.close, T.close + 0.35)))
			local wob = 1 + math.sin(s * 14) * 0.03
			rim.Size = Vector3.new(0.3, r * 2.14 * wob, r * 2.14 * wob); rim.CFrame = face * CFrame.new(-0.12, 0, 0)
			hole.Size = Vector3.new(0.34, r * 2, r * 2); hole.CFrame = face
			dark.Size = Vector3.new(0.38, r * 1.5, r * 1.5); dark.CFrame = face * CFrame.new(0.02, 0, 0)
			local vis = r > 0.05
			rim.Transparency = vis and 0.1 or 1; hole.Transparency = vis and 0.05 or 1; dark.Transparency = vis and 0 or 1
			l.Brightness = 2 * (r / R)
			if vis and s >= nextBolt and s < T.close then
				nextBolt = s + 0.13
				local a = rng:NextNumber(0, math.pi * 2)
				local from = center + (x.cright * math.cos(a) + UP * math.sin(a)) * r
				bolt(x, from, from + (x.cright * math.cos(a) + UP * math.sin(a)) * rng:NextNumber(3, 8) + x.look * rng:NextNumber(-2, 5), rng:NextNumber() < 0.5 and core or rimCol, 0.3, 0.22)
				shake(0.03)
			end
		end)
	end)
	stream(x, T.portal + 0.2, T.close, center, { Texture = SPARK, Color = ColorSequence.new(core, rimCol), LightEmission = 1, Size = NumberSequence.new(1.1, 0.1), Lifetime = NumberRange.new(0.5, 0.8),
		Speed = NumberRange.new(-16, -9), Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, RotSpeed = NumberRange.new(200, 400) }, 70)
	for i = 0, 2 do
		at(x, T.step0 + 0.3 + i * 0.5, function()
			Sfx.play("Crash", { Volume = 0.6, PlaybackSpeed = 0.6 })
			shake(0.45)
			local z = 7.5 * (1 - seg(x.s, T.step0, T.step1))
			ring(x, body(x, z, 0), x.c2, 1, 9, 0.45)
		end)
	end
	at(x, T.close, function()
		Sfx.play("Whoosh", { Volume = 1.1, PlaybackSpeed = 0.6 })
		flash(x, core, 0.25, 0.3)
	end)
	at(x, T.clench, function()
		Sfx.play("DemonRoar", { Volume = 1.3, PlaybackSpeed = 0.85 })
		Sfx.play("Explosion", { Volume = 0.6, PlaybackSpeed = 1.2 })
		shake(1.0); kick(12)
		flash(x, core, 0.4, 0.4)
		ring(x, f, core, 3, 32, 0.8)
		task.delay(0.12, function() if x.alive() then ring(x, f, rimCol, 2, 22, 0.6) end end)
		local fist = limb(x, "RightHand")
		for i = 1, 9 do
			local a = i / 9 * math.pi * 2
			bolt(x, fist, f + Vector3.new(math.cos(a) * 13, rng:NextNumber(0, 2), math.sin(a) * 13), i % 2 == 0 and core or rimCol, 0.4, 0.4)
		end
		burst(x, fist, { Texture = SPARK, Color = ColorSequence.new(core), LightEmission = 1, Size = NumberSequence.new(1.2, 0), Lifetime = NumberRange.new(0.3, 0.7), Speed = NumberRange.new(20, 40) }, 60)
		if x.evolved then
			local h = math.max(4, x.ceil - x.H)
			local beam = part(x, { Shape = Enum.PartType.Cylinder, Color = x.c1, Transparency = 0.15, Size = Vector3.new(h, 1.6, 1.6), CFrame = CFrame.new(fist + UP * h / 2) * CFrame.Angles(0, 0, math.pi / 2) })
			TweenService:Create(beam, TweenInfo.new(0.9), { Size = Vector3.new(h, 0.05, 0.05), Transparency = 1 }):Play()
		end
		x.card()
	end)
	at(x, 0, function()
		local l = light(x, spot(x, 6, -2, x.H * 0.7), C(240, 225, 255), 40, 0)
		each(x, function(s) l.Brightness = 0.6 * seg(s, T.step0, T.step1) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	x.camera = function(s)
		local k = ss(seg(s, 0, x.D))
		local walk = seg(s, T.step0, T.step1)
		return spot(x, lerp(16, 11.5, k), lerp(-3.5, -1.5, k), lerp(2, x.H * 0.42, k)), body(x, lerp(6, 0, walk), x.H * lerp(0.5, 0.66, ss(seg(s, T.fist, T.clench))))
	end
end

-- THE SEWER RAT: the floor bulges and cracks, and he bursts out of it; he sniffs the air, rears up and shrieks
SCRIPTS.Rat = function(x)
	local T = EP.T.Rat
	local f = x.floor
	local DIRT, MUD = C(86, 66, 48), C(52, 40, 30)
	local dirt = { Color = ColorSequence.new(DIRT, MUD), Size = NumberSequence.new(1.5, 5), Transparency = NumberSequence.new(0.25, 1), Lifetime = NumberRange.new(0.6, 1.3), Drag = 2 }
	at(x, 0, function()
		Sfx.play("Crash", { Volume = 0.5, PlaybackSpeed = 0.5 })
		-- the bulge
		local mound = disc(x, f + UP * 0.15, 0.5, MUD, 0)
		mound.Material = Enum.Material.Slate
		each(x, function(s)
			local r = 5.5 * ss(seg(s, 0, T.burst)) * (1 - seg(s, x.D - 0.9, x.D - 0.3))
			mound.Size = Vector3.new(0.3 + 0.9 * seg(s, 0.3, T.burst), r * 2 + 0.01, r * 2 + 0.01)
			if s < T.burst then shake(0.012) end
		end)
		-- cracks creeping out from it
		for i = 1, 9 do
			local a = i / 9 * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
			local len = rng:NextNumber(5, 10)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local c = part(x, { Material = Enum.Material.SmoothPlastic, Color = C(8, 6, 6), Transparency = 1, Size = Vector3.new(rng:NextNumber(0.25, 0.5), 0.08, len),
				CFrame = CFrame.lookAt(f + dir * (len / 2 + 2) + UP * 0.07, f + dir * 40 + UP * 0.07) })
			each(x, function(s) c.Transparency = 1 - seg(s, 0.3 + i * 0.12, 0.5 + i * 0.12) * (1 - seg(s, x.D - 0.8, x.D - 0.3)) end)
		end
	end)
	for _, t in { 0.5, 1.0, 1.35 } do
		at(x, t, function()
			Sfx.play("Dig", { Volume = 1.2, PlaybackSpeed = 0.9 })
			shake(0.2)
			burst(x, f + UP * 0.5, with(dirt, { Speed = NumberRange.new(8, 18), SpreadAngle = Vector2.new(50, 50), EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, -40, 0) }), 16)
		end)
	end
	at(x, T.burst, function()
		Sfx.play("Explosion", { Volume = 0.8, PlaybackSpeed = 1.05 })
		Sfx.play("RatSqueal", { Volume = 1.2 })
		shake(1.0); kick(12)
		flash(x, Color3.new(1, 1, 1), 0.3, 0.3)
		ring(x, f, x.c1, 2, 26, 0.7)
		chunks(x, f + UP, 18, DIRT, Enum.Material.Slate, 34)
		burst(x, f + UP * 1.5, with(dirt, { Speed = NumberRange.new(16, 40), SpreadAngle = Vector2.new(70, 70), EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, -30, 0) }), 100)
	end)
	at(x, T.land, function()
		Sfx.play("PunchHeavy", { Volume = 1, PlaybackSpeed = 0.6 })
		shake(0.6)
		ring(x, f, x.c2, 1.5, 14, 0.45)
	end)
	at(x, T.rear + 0.15, function()
		Sfx.play(Sfx.voice("Spawn", "Rat"), { Volume = 1.4 })
		shake(0.8); kick(10)
		flash(x, x.c1, 0.2, 0.35)
		ring(x, f, x.c1, 2, 28, 0.7)
		if x.evolved then
			burst(x, f + UP * x.H * 0.5, { Color = ColorSequence.new(x.c1), LightEmission = 0.6, Size = NumberSequence.new(3, 8), Transparency = NumberSequence.new(0.5, 1),
				Lifetime = NumberRange.new(0.8, 1.6), Speed = NumberRange.new(8, 20) }, 40) -- a cloud of plague
		end
		x.card()
	end)
	at(x, 0, function()
		local l = light(x, spot(x, 5, 1, x.H * 0.9), C(255, 232, 200), 32, 0)
		each(x, function(s) l.Brightness = 0.7 * seg(s, T.burst - 0.4, T.burst) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	x.camera = function(s)
		local up = seg(s, T.burst, T.peak)
		local down = seg(s, T.peak, T.land)
		local rear = ss(seg(s, T.rear, T.rear + 0.3))
		local y = s < T.burst and 0.8 or (5 * up * (1 - down * down) + x.H * lerp(0.3, 0.62, rear))
		local k = ss(seg(s, 0, x.D))
		return spot(x, lerp(13, 10.5, k), lerp(4, 2, k), lerp(1.6, x.H * 0.5, ss(seg(s, T.burst, T.rear)))), f + UP * y
	end
end

-- THE VOID KNIGHT: in the dark, his breathing behind a wall of the map itself (one of its KnightSpots: Server/
-- KnightDoor). The red blade burns a doorway through it (sparks, a molten outline); the cut-out falls flat (the
-- Hollow Emperor blasts it away with the force), and he steps through and raises the blade before his face, his left
-- hand held out. On a map without spots a wall is built for the shot.
-- his breathing through the mask (Client/MaskBreath): one long breath, a deep inhale, a pause, a deep exhale
local function maskBreath(vol: number)
	MaskBreath.start(nil, vol, { once = true })
end
SCRIPTS.Knight = function(x)
	local T = EP.T.Knight
	local glow = x.c1
	local hot = C(255, 175, 70)
	local door = x.door
	local DW: number, DH: number
	local base: CFrame -- the wall's middle at the doorway's foot; local -Z = toward the camera
	local wz: number -- the wall's middle is this far (times x.back) behind where he ends up
	local fz: number, bz: number -- the wall's front face (camera side) and back face, from its middle along x.look
	local slabs = {} :: { BasePart } -- what falls: the doorway's piece of the wall (every layer of it)
	-- the look of the nearest wall of the room (plaster if there is none)
	local function wallLook(): { Color: Color3, Material: Enum.Material, MaterialVariant: string }
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Include
		local mansion = workspace:FindFirstChild("Mansion")
		rp.FilterDescendantsInstances = { (mansion and mansion:FindFirstChild("Structure")) or mansion or workspace.Terrain }
		local chest = x.floor + UP * math.min(x.H * 0.5, x.ceil - 1)
		for _, d in { -x.look, x.cright, -x.cright, x.look } do
			local r = workspace:Raycast(chest, d * 30, rp)
			if r and r.Instance:IsA("BasePart") and r.Normal.Y < 0.5 then
				return { Color = r.Instance.Color, Material = r.Instance.Material, MaterialVariant = r.Instance.MaterialVariant }
			end
		end
		return { Color = C(196, 182, 160), Material = Enum.Material.SmoothPlastic, MaterialVariant = "" }
	end
	local look = { Color = C(196, 182, 160), Material = Enum.Material.SmoothPlastic, MaterialVariant = "" }
	local function slabPart(size: Vector3, cf: CFrame): Part
		return part(x, { Size = size, CFrame = cf, Color = look.Color, Material = look.Material, MaterialVariant = look.MaterialVariant, CastShadow = true })
	end
	if door then
		-- A REAL WALL: the server cut the doorway out of it and left the doorway's pieces in place (the plugs); they
		-- are copied for the shot (the copies fall) and the real ones hidden on this screen
		DW, DH = door.w, door.h
		base = CFrame.lookAt(door.pos, door.pos + x.look)
		wz = (x.floor - door.pos):Dot(x.look)
		fz, bz = 0.3, -0.3
		local biggest = 0
		for _, p in door.plugs do
			local c = p:Clone()
			c.Anchored = true; c.CanCollide = false; c.CanQuery = false; c.CanTouch = false
			c.LocalTransparencyModifier = 0
			c.Parent = x.folder
			table.insert(slabs, c)
			p.LocalTransparencyModifier = 1
			for _, d in p:GetDescendants() do
				if d:IsA("Decal") or d:IsA("Texture") then d.Transparency = 1 end
			end
			local off = (p.Position - door.pos):Dot(x.look)
			local l = p.CFrame:VectorToObjectSpace(x.look)
			local half = math.abs(l.X) * p.Size.X / 2 + math.abs(l.Y) * p.Size.Y / 2 + math.abs(l.Z) * p.Size.Z / 2
			fz = math.max(fz, off + half); bz = math.min(bz, off - half)
			local vol = p.Size.X * p.Size.Y * p.Size.Z
			if vol > biggest then biggest = vol; look = { Color = p.Color, Material = p.Material, MaterialVariant = p.MaterialVariant } end
		end
		if #slabs == 0 then
			-- (the plugs did not reach this screen) a stand-in in the wall's look fills the doorway
			look = wallLook()
			table.insert(slabs, slabPart(Vector3.new(DW, DH, fz - bz), base * CFrame.new(0, DH / 2, -(fz + bz) / 2)))
		end
	else
		-- no spot on this map: a wall is built for the shot, in the look of the room's own walls
		local W = 14
		local Ht = math.min(x.ceil - 0.05, math.max(x.H + 5, 11))
		local TH = 0.7
		DW, DH = 5.6, math.min(x.H + 1.2, Ht - 1.4)
		wz = 3.6
		base = CFrame.lookAt(body(x, wz, 0), body(x, wz, 0) + x.look)
		fz, bz = TH / 2, -TH / 2
		look = wallLook()
		local side = (W - DW) / 2
		slabPart(Vector3.new(side, Ht, TH), base * CFrame.new(-(DW / 2 + side / 2), Ht / 2, 0))
		slabPart(Vector3.new(side, Ht, TH), base * CFrame.new(DW / 2 + side / 2, Ht / 2, 0))
		slabPart(Vector3.new(DW, Ht - DH, TH), base * CFrame.new(0, DH + (Ht - DH) / 2, 0))
		table.insert(slabs, slabPart(Vector3.new(DW, DH, TH), base * CFrame.new(0, DH / 2, 0)))
	end
	-- the cut: up the right side of the doorway, across the top, down the left (wall coordinates, front face)
	local path = { Vector2.new(DW / 2, 0.1), Vector2.new(DW / 2, DH), Vector2.new(-DW / 2, DH), Vector2.new(-DW / 2, 0.1) }
	local lens = {}
	local total = 0
	for i = 1, #path - 1 do lens[i] = (path[i + 1] - path[i]).Magnitude; total += lens[i] end
	local lines = {}
	for i = 1, #path - 1 do lines[i] = part(x, { Color = hot, Transparency = 1, Size = Vector3.new(0.18, 0.18, 0.1) }) end
	local front = -fz - 0.05
	local function wallPt(v: Vector2, z: number): Vector3 return (base * CFrame.new(v.X, v.Y, z)).Position end
	local tip = part(x, { Color = glow, Transparency = 1, Size = Vector3.new(0.22, 0.22, 1.8) })
	local cutLight = light(x, wallPt(path[1], front - 0.6), glow, 16, 0)
	local sparks = stream(x, T.cut0, T.cut1, wallPt(path[1], front), { Texture = SPARK, Color = ColorSequence.new(hot, glow), LightEmission = 1,
		Size = NumberSequence.new(0.35, 0), Lifetime = NumberRange.new(0.25, 0.6), Speed = NumberRange.new(8, 18), SpreadAngle = Vector2.new(60, 60),
		Acceleration = Vector3.new(0, -40, 0), EmissionDirection = Enum.NormalId.Top }, 90)
	local burn: Sound? = nil
	at(x, T.breath, function()
		darkness(x, 0.55, 0)
		maskBreath(1.8)
	end)
	at(x, T.cut0, function()
		Sfx.play("SaberHum", { Volume = 0.9, PlaybackSpeed = 1.4 })
		burn = Sfx.play("SaberBurn", { Volume = 1, Looped = true })
		darkness(x, 0.3, 0.6)
	end)
	each(x, function(sNow)
		local p = ss(seg(sNow, T.cut0, T.cut1)) * total
		local cutting = sNow >= T.cut0 and sNow < T.cut1
		local acc = 0
		local cur = path[1]
		for i = 1, #path - 1 do
			local a, b = path[i], path[i + 1]
			local k = math.clamp((p - acc) / lens[i], 0, 1)
			local e = a:Lerp(b, k)
			if k > 0 then
				local mid = (a + e) / 2
				local len = (e - a).Magnitude
				local horizontal = math.abs(b.Y - a.Y) < 0.01
				lines[i].Size = horizontal and Vector3.new(len + 0.18, 0.2, 0.12) or Vector3.new(0.2, len + 0.18, 0.12)
				lines[i].CFrame = base * CFrame.new(mid.X, mid.Y, front)
				-- molten while fresh, cooling to a dark red glow once the slab has fallen
				local cool = seg(sNow, T.fall, T.fall + 1.4)
				lines[i].Color = hot:Lerp(glow, 0.35 + 0.4 * cool)
				lines[i].Transparency = 0.05 + 0.6 * cool
			end
			if k > 0 and k < 1 then cur = e end
			if k >= 1 then cur = b end
			acc += lens[i]
		end
		-- the blade's point, poking through the wall where it cuts
		local wob = math.sin(sNow * 40) * 0.05
		tip.CFrame = base * CFrame.new(cur.X + wob, cur.Y, front - 0.9)
		tip.Transparency = cutting and 0.05 or 1
		cutLight.Brightness = cutting and (2.2 + math.sin(sNow * 50) * 0.6) or 0
		;(cutLight.Parent :: BasePart).Position = wallPt(cur, front - 0.6)
		;(sparks.Parent :: Attachment).WorldPosition = wallPt(cur, front)
		if cutting and rng:NextNumber() < 0.12 then shake(0.05) end
	end)
	at(x, T.cut1, function()
		if burn then burn:Destroy() end
		Sfx.play("SaberSwish", { Volume = 1, PlaybackSpeed = 0.8 })
	end)
	-- the slab goes: it falls flat toward the camera, hinged at its bottom edge (the Hollow Emperor blasts it away)
	at(x, T.kick, function()
		Sfx.play("Crash", { Volume = 0.8, PlaybackSpeed = 0.9 })
		darkness(x, 0, 0.5)
		if x.evolved then
			flash(x, glow, 0.35, 0.3)
			Sfx.play("Explosion", { Volume = 0.7, PlaybackSpeed = 1.1 })
			shake(0.7)
			chunks(x, (base * CFrame.new(0, DH / 2, -fz)).Position, 18, look.Color, look.Material, 40)
		end
	end)
	-- (the pieces move as one: each keeps its place relative to the hinge, or to the middle when it is blasted)
	local hinge = base * CFrame.new(0, 0, -fz) -- the front face's bottom edge
	local mid = base * CFrame.new(0, DH / 2, -(fz + bz) / 2)
	local relH, relM = {} :: { CFrame }, {} :: { CFrame }
	for i, p in slabs do relH[i] = hinge:ToObjectSpace(p.CFrame); relM[i] = mid:ToObjectSpace(p.CFrame) end
	each(x, function(sNow)
		if sNow < T.kick then return end
		local k = seg(sNow, T.kick, T.fall)
		if x.evolved then
			local c = (mid + x.look * (22 * ss(k)) + UP * (2 * math.sin(k * math.pi))) * CFrame.Angles(k * 2.4, k * 0.8, 0)
			for i, p in slabs do
				p.CFrame = c * relM[i]
				p.Transparency = seg(sNow, T.kick + 0.2, T.fall)
			end
		else
			local h = hinge * CFrame.Angles(-(math.pi / 2) * k * k, 0, 0)
			for i, p in slabs do p.CFrame = h * relH[i] end
		end
	end)
	-- the fallen piece stays on the floor through the fight (on this screen; gone with him, or after two minutes)
	if not x.evolved then
		table.insert(x.cleanup, function()
			if x.s < T.fall then return end
			local old = workspace:FindFirstChild("KnightSlab")
			if old then old:Destroy() end
			local keep = Instance.new("Folder")
			keep.Name = "KnightSlab"
			keep.Parent = workspace
			for _, p in slabs do if p.Parent then p.Parent = keep end end
			local m = x.model
			task.spawn(function()
				local t = 0
				while keep.Parent and m.Parent and t < 120 do t += task.wait(1) end
				keep:Destroy()
			end)
		end)
	end
	at(x, T.fall, function()
		shake(0.65); kick(6)
		Sfx.play("WoodBreak", { Volume = 1.2, PlaybackSpeed = 0.75 })
		local landed = wallPt(Vector2.new(0, 0), -fz - DH / 2)
		burst(x, landed + UP * 0.6, with(SMOKE_FLOOR, { Color = ColorSequence.new(look.Color:Lerp(C(120, 110, 100), 0.5)) }), 26)
		if not x.evolved then chunks(x, landed + UP, 8, look.Color, look.Material, 18) end
	end)
	-- the blade raised: its hum swells, the card
	at(x, T.raise, function()
		Sfx.play("SaberSwish", { Volume = 1.2, PlaybackSpeed = 0.65 })
		Sfx.play("SaberHum", { Volume = 1, PlaybackSpeed = 0.75 })
		shake(0.35)
		flash(x, glow, 0.18, 0.35)
		x.card()
	end)
	x.camera = function(sNow)
		local walk = seg(sNow, T.step0, T.step1)
		local out = ss(seg(sNow, T.kick, T.step0 + 0.4))
		local up = ss(seg(sNow, T.raise - 0.3, T.raise + 0.6))
		local p0 = spot(x, 7.5, 1.6, x.H * 0.55)
		local p1 = spot(x, 11.5, -2, x.H * 0.5)
		local p2 = spot(x, 8.5, -2.6, x.H * 0.3)
		local at0 = body(x, wz, DH * 0.6)
		local at1 = body(x, 7 * (1 - walk), x.H * 0.6)
		local at2 = body(x, 0, x.H * 0.78)
		return p0:Lerp(p1, out):Lerp(p2, up), at0:Lerp(at1, out):Lerp(at2, up)
	end
end

-- the stage ---------------------------------------------------------------------------------------------------
-- CAMP HOLLOWMERE ---------------------------------------------------------------------------------------------
-- THE ANTLERED ONE: the rafters creak, dust trickles down from wherever he is; he crawls toward you upside down,
-- drops, lands in a crouch (splinters, a shockwave), stands up and bellows (his breath steaming)
SCRIPTS.Antlered = function(x)
	local T = EP.T.Antlered
	local f = x.floor
	local cl = math.min(x.ceil, 26)
	local hv = tonumber(x.model:GetAttribute("Hover")) or 7
	local yRoot = math.max(0, cl - 2 * hv)
	local chestUp = math.max(2, hv + yRoot - (x.H - hv) * 0.45) -- (his chest while upside down)
	local function zAt(s: number): number return 9 * (1 - ss(seg(s, T.crawl0, T.crawl1))) end
	local dust = { Color = ColorSequence.new(C(150, 132, 110), C(80, 66, 52)), Size = NumberSequence.new(0.6, 2), Transparency = NumberSequence.new(0.4, 1),
		Lifetime = NumberRange.new(1, 1.8), Acceleration = Vector3.new(0, -22, 0), Speed = NumberRange.new(1, 4), SpreadAngle = Vector2.new(40, 40), EmissionDirection = Enum.NormalId.Bottom }
	at(x, 0, function()
		darkness(x, 0.35, 0.4)
		Sfx.play("DoorCreak", { Volume = 1, PlaybackSpeed = 0.5 })
	end)
	for i, t in { 0.35, 0.85, 1.35 } do
		at(x, t, function()
			Sfx.play("DoorCreak", { Volume = 0.8 + i * 0.1, PlaybackSpeed = 0.42 + i * 0.05 })
			shake(0.1 + i * 0.05)
			burst(x, body(x, zAt(t), cl - 0.6), dust, 8 + i * 4)
		end)
	end
	at(x, T.fall - 0.3, function() Sfx.play("BullSnort", { Volume = 1.4, PlaybackSpeed = 0.7 }) end)
	at(x, T.fall, function() Sfx.play("Whoosh", { Volume = 1.2, PlaybackSpeed = 0.55 }) end)
	at(x, T.land, function()
		Sfx.play("Crash", { Volume = 0.9 })
		Sfx.play("WoodBreak", { Volume = 1.2, PlaybackSpeed = 0.7 })
		shake(1.1); kick(13)
		ring(x, f, x.c1, 3, 26, 0.7)
		chunks(x, f + UP, 14, C(96, 74, 52), Enum.Material.WoodPlanks, 28)
		burst(x, f + UP * 1.2, with(dust, { Speed = NumberRange.new(12, 30), Acceleration = Vector3.zero, SpreadAngle = Vector2.new(85, 85),
			EmissionDirection = Enum.NormalId.Top, Size = NumberSequence.new(2, 6) }), 70)
		darkness(x, 0, 0.6)
	end)
	at(x, T.roar, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.4 })
		Sfx.play("BullSnort", { Volume = 1.4, PlaybackSpeed = 0.55 })
		shake(0.9); kick(10)
		ring(x, f, x.c1, 3, 30, 0.8)
		-- his breath, steaming out of the skull
		burst(x, limb(x, "Head") + x.cdir * 1.2, { Color = ColorSequence.new(C(220, 220, 220)), Size = NumberSequence.new(1, 4), Transparency = NumberSequence.new(0.5, 1),
			Lifetime = NumberRange.new(0.6, 1.2), Speed = NumberRange.new(4, 10), SpreadAngle = Vector2.new(25, 25) }, 20)
		x.card()
	end)
	at(x, 0, function()
		local l = light(x, spot(x, 5, 2, x.H * 0.6), C(255, 230, 200), 36, 0)
		each(x, function(s) l.Brightness = 0.6 * seg(s, T.land - 0.2, T.land + 0.3) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	x.camera = function(s)
		local fall = seg(s, T.fall, T.land)
		local rise = ss(seg(s, T.rise0, T.rise1))
		local hy: number
		if s < T.fall then hy = chestUp elseif s < T.land then hy = lerp(chestUp, x.H * 0.4, fall * fall) else hy = x.H * lerp(0.4, 0.7, rise) end
		local pull = s >= T.land and 2.5 * (1 - seg(s, T.land, T.land + 1)) or 0
		return spot(x, lerp(13, 11, ss(seg(s, 0, x.D))) + pull, 3.5, lerp(1.6, 2.4, rise)), body(x, s < T.fall and zAt(s) or 0, hy)
	end
end

-- THE LAKE WITCH: black water spreads over the floor and bubbles; a hand breaks the surface, then she rises out of
-- it with the lake pouring off her; she whirls her hook over her head and slams it into the floor
SCRIPTS.LakeWitch = function(x)
	local T = EP.T.LakeWitch
	local f = x.floor
	at(x, 0, function()
		Sfx.play("Bubbles", { Volume = 1.2, PlaybackSpeed = 0.7 })
		Sfx.play("GhostWhisper", { Volume = 1, PlaybackSpeed = 0.6 })
		local pool = disc(x, f + UP * 0.07, 0.5, C(10, 24, 28), 0.04)
		pool.Material = Enum.Material.SmoothPlastic
		pool.Reflectance = 0.3
		local rim = disc(x, f + UP * 0.04, 0.6, x.c1, 0.55)
		each(x, function(s)
			local r = 7 * ss(seg(s, 0, 1.0)) * (1 - ss(seg(s, x.D - 0.9, x.D - 0.3)))
			pool.Size = Vector3.new(0.12, r * 2, r * 2)
			rim.Size = Vector3.new(0.1, r * 2.12, r * 2.12)
		end)
		local l = light(x, f + UP * 2, x.c1, 26, 0)
		each(x, function(s) l.Brightness = 0.8 * seg(s, 0, 1) * (1 - seg(s, x.D - 0.8, x.D - 0.2)) end)
	end)
	at(x, 0.6, function() Sfx.play("Bubbles", { Volume = 1.1, PlaybackSpeed = 0.55 }) end)
	-- bubbles through the black water, then the water pouring off her as she rises
	stream(x, 0.2, T.rise1, f + UP * 0.3, { Texture = SPARK, Color = ColorSequence.new(x.c1), Size = NumberSequence.new(0.35, 0.1), Transparency = NumberSequence.new(0.2, 1),
		Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(2, 5), SpreadAngle = Vector2.new(50, 50), EmissionDirection = Enum.NormalId.Top }, 40)
	stream(x, T.rise0 + 0.3, T.swing0 + 0.5, f + UP * x.H * 0.75, { Texture = SPARK, Color = ColorSequence.new(C(150, 200, 210)), Size = NumberSequence.new(0.25, 0.1),
		Transparency = NumberSequence.new(0.3, 1), Lifetime = NumberRange.new(0.5, 0.9), Speed = NumberRange.new(0.5, 2), Acceleration = Vector3.new(0, -40, 0),
		SpreadAngle = Vector2.new(70, 70) }, 60)
	at(x, T.hand, function()
		Sfx.play("FormGulp", { Volume = 1, PlaybackSpeed = 0.5 })
		burst(x, f + UP * 0.5, { Color = ColorSequence.new(C(120, 170, 180)), Size = NumberSequence.new(0.6, 2), Transparency = NumberSequence.new(0.4, 1),
			Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(4, 10), SpreadAngle = Vector2.new(40, 40), EmissionDirection = Enum.NormalId.Top }, 18)
	end)
	at(x, T.rise0 + 0.4, function() Sfx.play(Sfx.voice("WindUp", x.id), { Volume = 1 }) end)
	-- the hook whirled over her head: the chain rattling and whirring
	at(x, T.swing0, function() Sfx.play("ShieldBlock", { Volume = 0.6, PlaybackSpeed = 1.5 }) end)
	for i = 0, 3 do
		at(x, T.swing0 + i * 0.24, function() Sfx.play("Whoosh", { Volume = 0.9, PlaybackSpeed = 0.75 + i * 0.05 }) end)
	end
	at(x, T.slam, function()
		Sfx.play("Crash", { Volume = 0.8 })
		Sfx.play("WoodBreak", { Volume = 1, PlaybackSpeed = 0.9 })
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.3 })
		shake(1.0); kick(12)
		flash(x, x.c1, 0.35, 0.4)
		local hp = f + x.cdir * 3.5 -- (the hook comes down in front of her)
		ring(x, f, x.c1, 2, 24, 0.7)
		burst(x, hp + UP, { Color = ColorSequence.new(C(130, 180, 190), C(40, 70, 80)), Size = NumberSequence.new(1, 3.5), Transparency = NumberSequence.new(0.3, 1),
			Lifetime = NumberRange.new(0.6, 1.2), Speed = NumberRange.new(10, 26), SpreadAngle = Vector2.new(70, 70), EmissionDirection = Enum.NormalId.Top,
			Acceleration = Vector3.new(0, -40, 0) }, 60)
		chunks(x, hp, 8, C(90, 70, 50), Enum.Material.WoodPlanks, 18)
		x.card()
	end)
	x.camera = function(s)
		local rise = ss(seg(s, T.rise0, T.rise1))
		local k = ss(seg(s, 0, T.slam))
		local back = s > T.slam and seg(s, T.slam, T.slam + 0.25) * 2 or 0
		return spot(x, lerp(14, 9.5, k) + back, lerp(-3.5, -1.2, k), lerp(1.0, x.H * 0.6, k)),
			f + UP * math.max(0.8, x.H * 0.8 - (x.H + 1.5) * (1 - rise))
	end
end

-- THE BURNED COUNSELOR: the room goes dark and his torch is out; it catches; he brings it up beside his burned face
-- and tilts his head at you; then the scream: the torch thrown up high and a ring of fire bursting up round him
SCRIPTS.Counselor = function(x)
	local T = EP.T.Counselor
	local f = x.floor
	-- the dark (this screen only): it lifts with the fire
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "EntranceDark"
	cc.Parent = game:GetService("Lighting")
	table.insert(x.cleanup, function() cc:Destroy() end)
	each(x, function(s)
		local d = seg(s, 0, 0.4) * (1 - ss(seg(s, T.ring - 0.05, T.ring + 0.6)))
		cc.Brightness = -0.3 * d; cc.Contrast = 0.15 * d; cc.Saturation = -0.12 * d
		cc.TintColor = Color3.new(1, 1, 1):Lerp(C(196, 196, 214), d)
	end)
	-- his torch, out until it catches
	local flame = x.model:FindFirstChild("Flame") :: BasePart?
	local lit = {} :: { Instance }
	if flame then
		flame:SetAttribute("LocalHide", true) -- (Client/GhostAnim keeps it hidden)
		for _, d in flame:GetDescendants() do
			if d:IsA("Fire") or d:IsA("Light") or d:IsA("ParticleEmitter") then
				table.insert(lit, d)
				local dd: any = d
				dd.Enabled = false
			end
		end
	end
	local function relight()
		if flame then flame:SetAttribute("LocalHide", nil) end
		for _, d in lit do (d :: any).Enabled = true end
	end
	table.insert(x.cleanup, relight)
	at(x, 0.2, function() Sfx.play("GhostWhisper", { Volume = 0.9, PlaybackSpeed = 0.55 }) end)
	at(x, T.strike, function()
		relight()
		Sfx.play("Flamethrower", { Volume = 0.8, PlaybackSpeed = 1.5 })
		burst(x, limb(x, "Flame"), { Texture = SPARK, Color = ColorSequence.new(x.c1), LightEmission = 1, Size = NumberSequence.new(0.4, 0),
			Lifetime = NumberRange.new(0.3, 0.7), Speed = NumberRange.new(4, 10) }, 24)
		local l = light(x, limb(x, "Flame"), C(255, 150, 60), 22, 0)
		local holder = l.Parent :: BasePart
		each(x, function(s)
			holder.Position = limb(x, "Flame")
			l.Brightness = (3 + math.sin(s * 23) * 0.5 + math.sin(s * 37) * 0.3) * seg(s, T.strike, T.strike + 0.2) * (1 - seg(s, x.D - 0.6, x.D - 0.1))
		end)
	end)
	at(x, T.raise1, function() Sfx.play("GhostWhisper", { Volume = 1, PlaybackSpeed = 0.8 }) end)
	at(x, T.ring, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.4 })
		Sfx.play("Flamethrower", { Volume = 1.2, PlaybackSpeed = 0.8 })
		shake(0.9); kick(11)
		flash(x, C(255, 150, 60), 0.45, 0.5)
		ring(x, f, x.c1, 2, 10, 0.5)
		-- the ring of fire round him
		local n = 14
		for i = 1, n do
			local a = i / n * math.pi * 2
			stream(x, T.ring, x.D - 0.4, f + Vector3.new(math.cos(a) * 6, 0.3, math.sin(a) * 6), { Texture = FIRE, Color = ColorSequence.new(C(255, 200, 80), C(200, 50, 20)),
				LightEmission = 1, Size = NumberSequence.new(2.2, 0.4), Transparency = NumberSequence.new(0.2, 1), Lifetime = NumberRange.new(0.5, 0.9),
				Speed = NumberRange.new(4, 8), SpreadAngle = Vector2.new(12, 12), EmissionDirection = Enum.NormalId.Top }, 16)
		end
		local l = light(x, f + UP * 3, C(255, 140, 50), 34, 0)
		each(x, function(s) l.Brightness = 1.6 * seg(s, T.ring, T.ring + 0.2) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
		x.card()
	end)
	x.camera = function(s)
		local push = ss(seg(s, 0, T.ring))
		local back = s > T.ring and ss(seg(s, T.ring, T.ring + 0.6)) * 5 or 0
		local tgt = s < T.ring and lerp(x.H * 0.68, x.H * 0.84, ss(seg(s, T.raise0, T.raise1))) or x.H * 0.65
		return spot(x, lerp(10, 6.5, push) + back, lerp(2.2, 1.0, push), lerp(x.H * 0.7, x.H * 0.8, push) - back * 0.4), f + UP * tgt
	end
end

-- THE SCARECROW: hung on a pole in the dark with crows sitting on his arms; his head twitches, then snaps up at
-- you; the crows burst off him straight at the camera; he drops off the pole, stands and raises his sickle
local function entranceCrow(x: Ctx): { parts: { { p: BasePart, rel: CFrame } }, wl: BasePart, wr: BasePart, ph: number }
	local K = 1.4 -- (their size)
	local function P(size: Vector3, color: Color3?): Part
		return part(x, { Size = size * K, Color = color or C(24, 22, 28), Material = Enum.Material.SmoothPlastic })
	end
	local c = { parts = {} :: { { p: BasePart, rel: CFrame } }, wl = P(Vector3.new(1.0, 0.05, 0.55)), wr = P(Vector3.new(1.0, 0.05, 0.55)), ph = rng:NextNumber(0, 6) }
	table.insert(c.parts, { p = P(Vector3.new(0.45, 0.42, 0.95)), rel = CFrame.new() })
	table.insert(c.parts, { p = P(Vector3.new(0.34, 0.34, 0.36)), rel = CFrame.new(0, 0.18 * K, -0.6 * K) })
	table.insert(c.parts, { p = P(Vector3.new(0.1, 0.1, 0.32), C(70, 66, 60)), rel = CFrame.new(0, 0.14 * K, -0.9 * K) })
	table.insert(c.parts, { p = P(Vector3.new(0.36, 0.06, 0.5)), rel = CFrame.new(0, 0.05 * K, 0.65 * K) })
	return c
end
local function placeEntranceCrow(c, cf: CFrame, flap: number)
	for _, e in c.parts do e.p.CFrame = cf * e.rel end
	c.wl.CFrame = cf * CFrame.new(-0.31, 0.17, 0) * CFrame.Angles(0, 0, flap) * CFrame.new(-0.7, 0, 0)
	c.wr.CFrame = cf * CFrame.new(0.31, 0.17, 0) * CFrame.Angles(0, 0, -flap) * CFrame.new(0.7, 0, 0)
end
SCRIPTS.Scarecrow = function(x)
	local T = EP.T.Scarecrow
	local f = x.floor
	local WOOD = C(104, 82, 58)
	-- a cold light from above and in front: the pole, the crossbar and the crows show against the dark
	at(x, 0, function()
		local l = light(x, f + UP * (x.H + 4) + x.cdir * 5, C(170, 186, 220), 30, 0)
		each(x, function(s) l.Brightness = 1.4 * seg(s, 0, 0.6) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	-- his pole: a post behind him and a crossbar under his arms (placed at his hands until he drops)
	local bar = part(x, { Material = Enum.Material.Wood, Color = WOOD, Size = Vector3.new(0.6, 0.6, 1) })
	local pole = part(x, { Material = Enum.Material.Wood, Color = WOOD, Size = Vector3.new(0.8, 1, 0.8) })
	local barA, barB = f + UP * 5 - x.cright * 3, f + UP * 5 + x.cright * 3
	-- the crows: on the crossbar out past his hands, and one on his hat
	local crows = {}
	for i = 1, 5 do crows[i] = entranceCrow(x) end
	local seats = { -1.05, -0.8, 0.8, 1.05 }
	local flyFrom = {} :: { Vector3 }
	local flyDir = {} :: { Vector3 }
	each(x, function(s, _dt)
		if s < T.drop then
			local a = limb(x, "LeftHand") - x.cdir * 0.55
			local b = limb(x, "RightHand") - x.cdir * 0.55
			local d = b - a
			if d.Magnitude > 0.5 then barA, barB = a - d.Unit * 1.4, b + d.Unit * 1.4 end
		end
		local mid = (barA + barB) / 2
		local len = (barB - barA).Magnitude
		bar.Size = Vector3.new(0.6, 0.6, math.max(1, len))
		bar.CFrame = CFrame.lookAt(mid, barB)
		local topY = mid.Y + 1.2
		pole.Size = Vector3.new(0.8, math.max(1, topY - f.Y), 0.8)
		pole.CFrame = CFrame.new(Vector3.new(mid.X, (topY + f.Y) / 2, mid.Z))
		local fade = seg(s, x.D - 0.8, x.D - 0.3)
		bar.Transparency = fade; pole.Transparency = fade
		-- the crows: sitting (hopping, pecking), then flying at you and scattering
		for i, c in crows do
			if s < T.burst then
				local seat: Vector3
				if i <= #seats then
					local u = seats[i]
					seat = mid + (barB - mid) * u + UP * 0.5
				else
					seat = limb(x, "Head") + UP * 1.6
				end
				local hop = math.max(0, math.sin(s * 5 + c.ph * 3)) ^ 6 * 0.4
				local yaw = math.sin(s * 1.3 + c.ph) * 0.9
				placeEntranceCrow(c, CFrame.lookAt(seat, seat + x.cdir) * CFrame.Angles(0, yaw, 0) + UP * hop, hop > 0.1 and 0.6 or 0.05)
				flyFrom[i] = seat
				flyDir[i] = (x.cdir + x.cright * rng:NextNumber(-0.5, 0.5) + UP * rng:NextNumber(0.05, 0.35)).Unit
			else
				local k = s - T.burst
				local p = flyFrom[i] + flyDir[i] * (k * 16) + UP * math.max(0, k - 0.5) ^ 2 * 10
				placeEntranceCrow(c, CFrame.lookAt(p, p + flyDir[i]), math.sin(s * 30 + c.ph) * 0.9)
				local gone = seg(k, 0.9, 1.3)
				for _, e in c.parts do e.p.Transparency = gone end
				c.wl.Transparency = gone; c.wr.Transparency = gone
			end
		end
	end)
	at(x, 0, function()
		darkness(x, 0.3, 0.4)
		Sfx.play("CrowCaw", { Volume = 0.8, PlaybackSpeed = 0.95 })
	end)
	at(x, 0.9, function() Sfx.play("CrowCaw", { Volume = 0.9, PlaybackSpeed = 0.85 }) end)
	at(x, T.twitch, function() Sfx.play("DoorCreak", { Volume = 0.8, PlaybackSpeed = 1.3 }) end)
	at(x, T.snap, function()
		Sfx.play("PunchLight", { Volume = 1, PlaybackSpeed = 0.6 })
		shake(0.4); kick(8)
	end)
	at(x, T.burst, function()
		Sfx.play("CrowFlock", { Volume = 1.4 })
		for i = 0, 2 do task.delay(i * 0.18, function() if x.alive() then Sfx.play("CrowCaw", { Volume = 1.1, PlaybackSpeed = 0.9 + i * 0.1 }) end end) end
		burst(x, limb(x, "UpperTorso"), { Texture = SPARK, Color = ColorSequence.new(C(214, 182, 96)), Size = NumberSequence.new(0.3, 0.1), Lifetime = NumberRange.new(0.6, 1.2),
			Speed = NumberRange.new(6, 14), Acceleration = Vector3.new(0, -20, 0) }, 30)
		flash(x, Color3.new(0, 0, 0), 0.4, 0.3)
	end)
	at(x, T.drop, function() Sfx.play("Whoosh", { Volume = 1, PlaybackSpeed = 0.6 }) end)
	at(x, T.land, function()
		Sfx.play("Crash", { Volume = 0.6, PlaybackSpeed = 0.8 })
		shake(0.6); kick(8)
		ring(x, f, x.c1, 2, 18, 0.6)
		burst(x, f + UP, { Texture = SPARK, Color = ColorSequence.new(C(214, 182, 96)), Size = NumberSequence.new(0.35, 0.1), Lifetime = NumberRange.new(0.6, 1.2),
			Speed = NumberRange.new(8, 18), SpreadAngle = Vector2.new(80, 80), EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, -20, 0) }, 40)
		darkness(x, 0, 0.5)
	end)
	at(x, T.raise, function()
		Sfx.play("BladeScrape", { Volume = 1.2 })
		Sfx.play("GhostWhisper", { Volume = 1, PlaybackSpeed = 0.8 })
		x.card()
	end)
	x.camera = function(s)
		local push = ss(seg(s, 0, T.snap))
		local after = ss(seg(s, T.land, x.D))
		local tgt = s < T.drop and lerp(x.H * 0.75, x.H * 0.9, push) or lerp(x.H * 0.55, x.H * 0.7, after)
		return spot(x, lerp(13, 7.5, push) + 3 * after, lerp(2.5, 0.6, push), lerp(x.H * 0.55, x.H * 0.8, push) - after), f + UP * tgt
	end
end

-- THE MOONLIGHT CARNIVAL ----------------------------------------------------------------------------------------
-- POP THE CLOWN: a striped jack-in-the-box on the floor plays its tune, shakes harder and harder; POP: the lid flies,
-- he springs out on a coil in a burst of confetti, lands with a bounce and throws his arms out (ta-da)
SCRIPTS.Clown = function(x)
	local T = EP.T.Clown
	local f = x.floor
	local box = part(x, { Material = Enum.Material.WoodPlanks, Color = C(200, 40, 40), Size = Vector3.new(4, 4.2, 4), CFrame = CFrame.new(f + UP * 2.1) })
	local stripes = {}
	for i = -1, 1 do
		table.insert(stripes, part(x, { Material = Enum.Material.SmoothPlastic, Color = C(240, 200, 60), Size = Vector3.new(4.06, 0.5, 4.06), CFrame = CFrame.new(f + UP * (2.1 + i * 1.3)) }))
	end
	local lid = part(x, { Material = Enum.Material.WoodPlanks, Color = C(60, 90, 200), Size = Vector3.new(4.3, 0.4, 4.3), CFrame = CFrame.new(f + UP * 4.4) })
	local crank = part(x, { Material = Enum.Material.Metal, Color = C(200, 180, 90), Size = Vector3.new(0.3, 0.3, 1.6), CFrame = CFrame.new(f + UP * 2.4 + x.cright * 2.2) })
	local coil = {} :: { Part }
	for i = 1, 6 do
		table.insert(coil, part(x, { Shape = Enum.PartType.Cylinder, Material = Enum.Material.Metal, Color = C(190, 190, 196), Size = Vector3.new(0.25, 2.2, 2.2), Transparency = 1,
			CFrame = CFrame.new(f + UP * (4 + i * 0.6)) * CFrame.Angles(0, 0, math.pi / 2) }))
	end
	local home = box.CFrame
	local lidOff = false
	local music: Sound? = nil
	each(x, function(s)
		-- the box shakes harder as the tune winds up; the crank turns
		local k = seg(s, T.music, T.pop) ^ 2
		local wob = CFrame.new(math.sin(s * 37) * 0.12 * k, math.abs(math.sin(s * 23)) * 0.2 * k, 0) * CFrame.Angles(0, 0, math.sin(s * 29) * 0.07 * k)
		if s < T.pop then
			box.CFrame = home * wob
			for i, st in stripes do st.CFrame = home * wob * CFrame.new(0, (i - 2) * 1.3, 0) end
			if not lidOff then lid.CFrame = home * wob * CFrame.new(0, 2.3, 0) end
			crank.CFrame = CFrame.new(f + UP * 2.4 + x.cright * 2.2) * CFrame.fromAxisAngle(x.cright, s * 8)
		end
		-- the spring: out of the box under him for a moment
		local show = s > T.pop and s < T.land + 0.25
		local top = limb(x, "LeftFoot").Y
		for i, c in ipairs(coil) do
			c.Transparency = show and 0 or 1
			if show then c.CFrame = CFrame.new(Vector3.new(f.X, f.Y + 4.2 + (top - f.Y - 4.2) * i / #coil, f.Z)) * CFrame.Angles(0, 0, math.pi / 2) end
		end
		local fade = seg(s, x.D - 0.9, x.D - 0.3)
		for _, pp in { box, lid, crank, table.unpack(stripes) } do pp.Transparency = fade end
	end)
	at(x, T.music, function() music = Sfx.play("MusicBox", { Volume = 1, PlaybackSpeed = 1.25 }) end)
	for i, tt in { 0.5, 0.9, 1.3, 1.7, 2.0, 2.3, 2.55 } do
		at(x, tt, function() Sfx.play("Click", { Volume = 0.5 + i * 0.05, PlaybackSpeed = 0.8 + i * 0.05 }) end)
	end
	at(x, T.pop, function()
		if music then music:Stop() end
		lidOff = true
		lid.Anchored = false
		lid.AssemblyLinearVelocity = x.cdir * 18 + UP * 40
		lid.AssemblyAngularVelocity = Vector3.new(8, 3, 6)
		Sfx.play("MagicBurst", { Volume = 1.2 })
		Sfx.play("BalloonPop", { Volume = 1.3 })
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.3 })
		shake(0.7); kick(10)
		flash(x, Color3.new(1, 1, 1), 0.4, 0.3)
		for _, col in { C(255, 80, 90), C(80, 160, 255), C(255, 220, 80), C(120, 230, 120) } do
			burst(x, f + UP * 5, { Texture = SPARK, Color = ColorSequence.new(col), LightEmission = 0.4, Size = NumberSequence.new(0.4, 0.25),
				Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(10, 26), Acceleration = Vector3.new(0, -25, 0), SpreadAngle = Vector2.new(60, 60), EmissionDirection = Enum.NormalId.Top }, 26)
		end
	end)
	at(x, T.land, function() Sfx.play("Bonk", { Volume = 1, PlaybackSpeed = 0.8 }); shake(0.3) end)
	at(x, T.tada, function() x.card() end)
	table.insert(x.cleanup, function() if music then music:Stop() end end)
	x.camera = function(s)
		local push = ss(seg(s, 0, T.pop))
		local back = s > T.pop and ss(seg(s, T.pop, T.pop + 0.4)) * 4 or 0
		local tgt = s < T.pop and 3 or lerp(6, x.H * 0.65, seg(s, T.pop, T.land + 0.3))
		return spot(x, lerp(13, 9, push) + back, lerp(2.5, 1.2, push), lerp(3, x.H * 0.55, seg(s, T.pop, T.land))), f + UP * tgt
	end
end

-- THE STRONGMAN: crouched over a giant barbell; he pulls it up to his shoulders, presses it over his head, roars,
-- and drops it: the floor cracks, dust and a ring roll out
SCRIPTS.Strongman = function(x)
	local T = EP.T.Strongman
	local f = x.floor
	local IRON = C(30, 30, 32)
	local bar = part(x, { Shape = Enum.PartType.Cylinder, Material = Enum.Material.Metal, Color = C(170, 170, 176), Size = Vector3.new(10, 0.45, 0.45) })
	local plates = {} :: { { p: Part, off: number } }
	for _, sgn in { -1, 1 } do
		for k, w in { 0.6, 0.45 } do
			table.insert(plates, { p = part(x, { Shape = Enum.PartType.Cylinder, Material = Enum.Material.Metal, Color = IRON, Size = Vector3.new(w, 3.4 - k * 0.7, 3.4 - k * 0.7) }), off = sgn * (3.6 + k * 0.55) })
		end
	end
	local dropped = false
	local restCF: CFrame? = nil
	local function place(cf: CFrame)
		bar.CFrame = cf
		for _, pl in plates do pl.p.CFrame = cf * CFrame.new(pl.off, 0, 0) end
	end
	each(x, function(s)
		local fade = seg(s, x.D - 0.7, x.D - 0.2)
		bar.Transparency = fade
		for _, pl in plates do pl.p.Transparency = fade end
		if dropped then
			if restCF then place(restCF) end
			return
		end
		-- the bar sits in his hands (between them), across him
		local l, r = limb(x, "LeftHand"), limb(x, "RightHand")
		local mid = (l + r) / 2
		local across = r - l
		across = across.Magnitude > 0.1 and across.Unit or x.cright
		place(CFrame.fromMatrix(mid, across, UP:Cross(across).Magnitude > 0.1 and across:Cross(UP:Cross(across)).Unit or UP))
	end)
	at(x, 0, function()
		Sfx.play(Sfx.voice("WindUp", x.id), { Volume = 1.2 })
		darkness(x, 0.25, 0.4)
	end)
	at(x, T.lift0, function() Sfx.play("ShieldBlock", { Volume = 0.6, PlaybackSpeed = 0.6 }) end)
	at(x, T.press, function() Sfx.play("Whoosh", { Volume = 0.8, PlaybackSpeed = 0.6 }); shake(0.2) end)
	at(x, T.roar, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.4 })
		shake(0.6); kick(10)
		x.card()
	end)
	at(x, T.drop + 0.12, function()
		dropped = true
		local land = f + UP * 1.7 + x.cdir * 3
		restCF = CFrame.fromMatrix(land, x.cright, UP)
		place(restCF)
		Sfx.play("HeavyImpact", { Volume = 1.6, PlaybackSpeed = 0.7 })
		Sfx.play("Explosion", { Volume = 0.7, PlaybackSpeed = 0.55 })
		shake(1.2); kick(14)
		ring(x, f, x.c1, 3, 32, 0.8)
		burst(x, f + UP, { Color = ColorSequence.new(x.c1, x.c2), Size = NumberSequence.new(2, 6), Transparency = NumberSequence.new(0.4, 1), Lifetime = NumberRange.new(0.8, 1.6),
			Speed = NumberRange.new(14, 34), SpreadAngle = Vector2.new(85, 85), EmissionDirection = Enum.NormalId.Top, Drag = 2 }, 80)
		chunks(x, land, 14, C(110, 90, 70), Enum.Material.WoodPlanks, 26)
		darkness(x, 0, 0.5)
	end)
	x.camera = function(s)
		local rise = ss(seg(s, T.lift0, T.press))
		local pull = s > T.drop and 3 * (1 - seg(s, T.drop, T.drop + 1)) or 0
		return spot(x, lerp(11, 13, rise) + pull, 3, lerp(1.6, 1.2, rise)), f + UP * lerp(x.H * 0.4, x.H * 0.75, rise)
	end
end

-- MADAME FORTUNE: a little round table in the dark, her crystal ball glowing on it; two eyes open inside the ball;
-- she fades in behind it, hands over the ball; tarot cards circle her and fly at you
SCRIPTS.Fortune = function(x)
	local T = EP.T.Fortune
	local f = x.floor
	local tc = f + x.cdir * 2.6
	local top = part(x, { Shape = Enum.PartType.Cylinder, Material = Enum.Material.Fabric, Color = C(70, 20, 60), Size = Vector3.new(0.3, 4.4, 4.4),
		CFrame = CFrame.new(tc + UP * 3.2) * CFrame.Angles(0, 0, math.pi / 2) })
	local cloth = part(x, { Shape = Enum.PartType.Cylinder, Material = Enum.Material.Fabric, Color = C(110, 36, 120), Size = Vector3.new(2.8, 4.6, 4.6),
		CFrame = CFrame.new(tc + UP * 1.8) * CFrame.Angles(0, 0, math.pi / 2), Transparency = 0.05 })
	local orb = part(x, { Shape = Enum.PartType.Ball, Material = Enum.Material.Glass, Color = C(200, 160, 255), Size = Vector3.one * 1.8, Transparency = 0.35,
		CFrame = CFrame.new(tc + UP * 4.25) })
	local core = part(x, { Shape = Enum.PartType.Ball, Color = C(190, 100, 255), Size = Vector3.one * 0.6, CFrame = orb.CFrame })
	local eyes = {} :: { Part }
	for _, sgn in { -1, 1 } do
		table.insert(eyes, part(x, { Color = C(255, 200, 255), Size = Vector3.new(0.18, 0.08, 0.05), Transparency = 1,
			CFrame = CFrame.lookAt(orb.Position + x.cdir * 0.7 + x.cright * sgn * 0.22 + UP * 0.1, orb.Position + x.cdir * 3) }))
	end
	local l = light(x, orb.Position, C(190, 110, 255), 26, 0)
	local cards = {} :: { Part }
	for i = 1, 5 do
		table.insert(cards, part(x, { Material = Enum.Material.SmoothPlastic, Color = C(236, 226, 196), Size = Vector3.new(1.3, 1.9, 0.08), Transparency = 1 }))
	end
	local flying = false
	each(x, function(s)
		local glow = seg(s, T.glow, T.glow + 0.8)
		l.Brightness = 2.5 * glow * (1 - seg(s, x.D - 0.6, x.D - 0.1)) + math.sin(s * 9) * 0.3 * glow
		core.Size = Vector3.one * (0.5 + 0.5 * glow + math.sin(s * 6) * 0.08)
		local eyeK = seg(s, T.face, T.face + 0.3) * (1 - seg(s, T.appear1, T.appear1 + 0.3))
		for _, e in eyes do e.Transparency = 1 - eyeK end
		-- the cards circle her, then fly at the camera
		local cardsOn = seg(s, T.appear0 + 0.4, T.appear1)
		local c = limb(x, "UpperTorso")
		for i, cd in cards do
			if not flying then
				local a = s * 2.2 + i / #cards * math.pi * 2
				local p = c + Vector3.new(math.cos(a) * 3.4, math.sin(a * 2) * 0.6 + 1.2, math.sin(a) * 3.4)
				cd.CFrame = CFrame.lookAt(p, c) * CFrame.Angles(0, math.pi / 2, 0)
				cd.Transparency = 1 - cardsOn
			end
		end
		local fade = seg(s, x.D - 0.8, x.D - 0.3)
		top.Transparency = fade; cloth.Transparency = math.max(0.05, fade); orb.Transparency = math.max(0.35, fade); core.Transparency = fade
	end)
	at(x, 0, function()
		darkness(x, 0.55, 0.4)
		Sfx.play("GhostWhisper", { Volume = 1.1, PlaybackSpeed = 0.75 })
	end)
	at(x, T.glow, function() Sfx.play("MagicBurst", { Volume = 0.6, PlaybackSpeed = 0.6 }) end)
	at(x, T.face, function() Sfx.play("GhostWhisper", { Volume = 1.2, PlaybackSpeed = 1.1 }) end)
	at(x, T.appear0, function() Sfx.play("Telekinesis", { Volume = 0.9, PlaybackSpeed = 0.8 }) end)
	at(x, T.cards, function()
		flying = true
		local eye = spot(x, 6, 0.6, x.H * 0.62)
		for i, cd in cards do
			local from = cd.CFrame
			TweenService:Create(cd, TweenInfo.new(0.35 + i * 0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ CFrame = CFrame.lookAt(eye + x.cright * (i - 3) * 0.8, eye + x.cdir) * CFrame.Angles(0, 0, i) }):Play()
			local _ = from
			task.delay(0.5, function() if cd.Parent then cd.Transparency = 1 end end)
		end
		Sfx.play("Whoosh", { Volume = 1.2, PlaybackSpeed = 1.2 })
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.2 })
		task.delay(0.35, function()
			if not x.alive() then return end
			flash(x, C(200, 120, 255), 0.5, 0.4)
			shake(0.5); kick(8)
		end)
		darkness(x, 0.15, 0.6)
		x.card()
	end)
	x.camera = function(s)
		local reveal = ss(seg(s, T.face + 0.3, T.appear1))
		local eyeTgt = orb.Position:Lerp(f + UP * x.H * 0.7, reveal)
		return spot(x, lerp(7.5, 11, reveal), lerp(0.4, 1.4, reveal), lerp(4.6, x.H * 0.62, reveal)), eyeTgt
	end
end

-- THE RINGMASTER: one spotlight in the dark on him, head bowed; he looks up, arms wide, the whip cracks, the ghost
-- crowd roars and coloured spotlights sweep the room
SCRIPTS.Ringmaster = function(x)
	local T = EP.T.Ringmaster
	local f = x.floor
	local top = f + UP * math.min(x.ceil - 0.5, 26)
	local function shaft(color: Color3): (Part, SpotLight)
		local p = part(x, { Shape = Enum.PartType.Cylinder, Color = color, Size = Vector3.new(1, 5, 5), Transparency = 1 })
		local holder = part(x, { Size = Vector3.one * 0.3, Transparency = 1, CFrame = CFrame.new(top) })
		local sl = Instance.new("SpotLight")
		sl.Face = Enum.NormalId.Bottom; sl.Color = color; sl.Range = 60; sl.Angle = 22; sl.Brightness = 0; sl.Shadows = true; sl.Parent = holder
		return p, sl
	end
	local main, mainL = shaft(C(255, 240, 210))
	local function aimShaft(p: Part, sl: SpotLight, at: Vector3, alpha: number)
		local from = top
		local d = (at - from)
		p.Size = Vector3.new(d.Magnitude, 6, 6)
		p.CFrame = CFrame.lookAt((from + at) / 2, at) * CFrame.Angles(0, math.pi / 2, 0)
		p.Transparency = 1 - 0.13 * alpha
		local holder = sl.Parent :: BasePart
		holder.CFrame = CFrame.lookAt(from, at) * CFrame.Angles(math.pi / 2, 0, 0) -- (its bottom face toward the floor spot)
		sl.Brightness = 6 * alpha
	end
	local sweep = {} :: { { p: Part, l: SpotLight, ph: number } }
	for i, col in { C(255, 60, 60), C(255, 210, 70), C(120, 160, 255) } do
		local p, l = shaft(col)
		table.insert(sweep, { p = p, l = l, ph = i * 2.1 })
	end
	each(x, function(s)
		local on = seg(s, T.spot, T.spot + 0.15) * (1 - seg(s, x.D - 0.6, x.D - 0.1))
		aimShaft(main, mainL, f, on)
		local lights = seg(s, T.lights, T.lights + 0.3) * (1 - seg(s, x.D - 0.6, x.D - 0.1))
		for _, sw in sweep do
			local a = s * 1.6 + sw.ph
			aimShaft(sw.p, sw.l, f + Vector3.new(math.cos(a) * 12, 0, math.sin(a) * 12), lights)
		end
	end)
	at(x, 0, function()
		darkness(x, 0.82, 0.25)
		Sfx.play("Crowd", { Volume = 0.35, PlaybackSpeed = 0.7 })
	end)
	at(x, T.spot, function() Sfx.play("Breaker", { Volume = 1, PlaybackSpeed = 0.7 }); darkness(x, 0.55, 0.2) end)
	at(x, T.arms, function() Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.3 }) end)
	at(x, T.crack, function()
		Sfx.play("WhipCrack", { Volume = 1.6 })
		shake(0.6); kick(10)
		flash(x, Color3.new(1, 1, 1), 0.35, 0.25)
		burst(x, limb(x, "RightHand") + UP * 3, { Texture = SPARK, Color = ColorSequence.new(C(255, 230, 200)), LightEmission = 1, Size = NumberSequence.new(0.5, 0),
			Lifetime = NumberRange.new(0.3, 0.7), Speed = NumberRange.new(8, 20) }, 30)
	end)
	at(x, T.lights, function()
		Sfx.play("Crowd", { Volume = 1.2, PlaybackSpeed = 0.85 })
		darkness(x, 0.25, 0.5)
		x.card()
	end)
	x.camera = function(s)
		local push = ss(seg(s, 0, T.crack))
		return spot(x, lerp(16, 10.5, push), lerp(4, 1.5, push), lerp(2.2, x.H * 0.5, push)), f + UP * x.H * lerp(0.55, 0.72, push)
	end
end

local function structure(): RaycastParams
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	local m = workspace:FindFirstChild("Mansion")
	local st = m and m:FindFirstChild("Structure")
	rp.FilterDescendantsInstances = { st or m or workspace.Terrain }
	return rp
end
local function freeDist(from: Vector3, dir: Vector3, want: number, rp: RaycastParams): number
	local r = workspace:Raycast(from, dir * want, rp)
	return r and math.max(1.5, r.Distance - 1.4) or want
end

local RARITY_TAG = { [2] = "RARE MONSTER", [3] = "EVOLVED MONSTER", [4] = "SECRET MONSTER" }

-- Blackwater Harbor: the Deep One rises out of black water like the Lake Witch, the Keeper's lamp catches in the dark
-- like the Counselor's torch (his lamp part is named Flame too), the Netman walks out of the sea fog like the Pirate
SCRIPTS.DeepOne = SCRIPTS.LakeWitch
SCRIPTS.Keeper = SCRIPTS.Counselor
SCRIPTS.Netman = SCRIPTS.Pirate


-- THE ASHEN ABBEY and THE BLACK MOON (2026-11-19): each new monster borrows another monster's body motion
-- (EntrancePose: the Nun the Woman's rise, the Gravedigger the Rat's burst, the Ringer the Giant's fall, the Astronaut
-- the Conqueror's walk, the Specimen the Antlered One's ceiling crawl, the Sentinel the Ringmaster's arms) but has its
-- own camera, effects and sounds, bigger than the earlier maps' (the last two maps: Client/FxTier adds its layer too)

-- THE WEEPING NUN: candles light one by one round a black pool; she rises out of it under a shaft of window light,
-- weeping, then screams with her arms up and the candles flare into holy fire
SCRIPTS.Nun = function(x)
	local T = EP.T.Woman
	local f = x.floor
	local HOLY = C(255, 230, 160)
	at(x, 0, function()
		darkness(x, 0.45, 0.3)
		Sfx.play("Choir", { Volume = 1.3 })
		Sfx.play("GhostWhisper", { Volume = 1.2, PlaybackSpeed = 0.6 })
		local pool = disc(x, f + UP * 0.08, 0.5, C(4, 2, 8), 0.1)
		pool.Material = Enum.Material.SmoothPlastic
		each(x, function(s)
			local r = 6 * ss(seg(s, 0, 1.0)) * (1 - ss(seg(s, x.D - 1.0, x.D - 0.3)))
			pool.Size = Vector3.new(0.12, r * 2, r * 2)
		end)
		-- a shaft of window light from high up, slanting down onto the pool
		local top = f + UP * math.min(x.ceil, 40) - x.cright * 8 + x.look * 4
		local shaft = part(x, { Color = HOLY, Transparency = 1, Size = Vector3.new(7, 7, (top - f).Magnitude), CFrame = CFrame.lookAt((top + f) / 2, top) })
		each(x, function(s) shaft.Transparency = 1 - 0.2 * ss(seg(s, T.rise0, T.rise1)) - 0.25 * seg(s, T.scream - 0.1, T.scream) * (1 - seg(s, T.scream, T.calm)) end)
		-- eight candles round the pool, lit one after another
		for i = 1, 8 do
			local a = i / 8 * math.pi * 2
			local cp = f + Vector3.new(math.cos(a) * 8, 0, math.sin(a) * 8)
			part(x, { Material = Enum.Material.SmoothPlastic, Color = C(230, 222, 200), Size = Vector3.new(0.5, 1.6, 0.5), Position = cp + UP * 0.8 })
			local flame = part(x, { Color = C(255, 200, 110), Size = Vector3.new(0.25, 0.5, 0.25), Position = cp + UP * 1.85, Transparency = 1 })
			local l = Instance.new("PointLight"); l.Color = C(255, 180, 90); l.Range = 10; l.Brightness = 0; l.Parent = flame
			local lit = 0.2 + i * 0.22
			each(x, function(s)
				local on = seg(s, lit, lit + 0.1)
				local flare = seg(s, T.scream, T.scream + 0.15) * (1 - seg(s, T.scream + 0.3, T.calm))
				flame.Transparency = 1 - on
				flame.Size = Vector3.new(0.25, 0.5 + flare * 2.5 + math.sin(s * 30 + i) * 0.05, 0.25)
				l.Brightness = on * (0.8 + flare * 3)
			end)
			at(x, lit, function() Sfx.play("FormHiss", { Volume = 0.3, PlaybackSpeed = 1.6 + i * 0.05 }) end)
		end
	end)
	-- black tears falling into the pool while she rises
	stream(x, T.rise0, T.scream, f + UP * 9, { Texture = SMOKE, Color = ColorSequence.new(C(10, 6, 14)), Size = NumberSequence.new(0.35, 0.2),
		Transparency = NumberSequence.new(0.1, 0.4), Lifetime = NumberRange.new(0.5, 0.8), Speed = NumberRange.new(8, 14), Acceleration = Vector3.new(0, -40, 0),
		SpreadAngle = Vector2.new(25, 25), EmissionDirection = Enum.NormalId.Bottom }, 16)
	stream(x, 0.1, T.calm, f + UP * 0.3, with(SMOKE_FLOOR, { Color = ColorSequence.new(C(30, 20, 40), C(6, 4, 10)) }), 20)
	at(x, T.rise0 + 0.6, function() Sfx.play(Sfx.voice("WindUp", x.id), { Volume = 1.2 }) end)
	at(x, T.scream - 0.04, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.5 })
		Sfx.play("MagicBurst", { Volume = 1, PlaybackSpeed = 0.7 })
		flash(x, Color3.new(1, 1, 1), 0.6, 0.5)
		darkness(x, 0, 0.5)
		shake(1.0); kick(13)
		ring(x, f, HOLY, 2, 34, 0.8)
		task.delay(0.12, function() if x.alive() then ring(x, f, x.c1, 2, 26, 0.7) end end)
		burst(x, f + UP * 1.5, { Texture = FIRE, Color = ColorSequence.new(HOLY, C(255, 140, 50)), LightEmission = 1, Size = NumberSequence.new(1.5, 0),
			Lifetime = NumberRange.new(0.6, 1.1), Speed = NumberRange.new(14, 30), SpreadAngle = Vector2.new(70, 70), EmissionDirection = Enum.NormalId.Top }, 70)
		x.card()
	end)
	x.camera = function(s)
		local k = ss(seg(s, 0, T.scream))
		local rise = ss(seg(s, T.rise0, T.rise1))
		local back = s > T.scream and seg(s, T.scream, T.scream + 0.25) * 2.5 or 0
		return spot(x, lerp(16, 9, k) + back, lerp(-4, -1.2, k), lerp(1.2, x.H * 0.7, k)), f + UP * math.max(0.6, x.H * 0.86 - (x.H + 1.5) * (1 - rise))
	end
end

-- THE GRAVEDIGGER: a gravestone in the floor; the ground heaves, the stone tips and falls, he claws his way out on all
-- fours in a spray of grave dirt and green grave-light, sniffs, then rears up and roars
SCRIPTS.Gravedigger = function(x)
	local T = EP.T.Rat
	local f = x.floor
	local DIRT, MUD, GRAVE = C(86, 66, 48), C(52, 40, 30), C(150, 255, 120)
	local dirt = { Color = ColorSequence.new(DIRT, MUD), Size = NumberSequence.new(1.5, 5), Transparency = NumberSequence.new(0.25, 1), Lifetime = NumberRange.new(0.6, 1.3), Drag = 2 }
	at(x, 0, function()
		Sfx.play("BoneRattle", { Volume = 1 })
		local mound = disc(x, f + UP * 0.15, 0.5, MUD, 0)
		mound.Material = Enum.Material.Slate
		each(x, function(s)
			local r = 5.5 * ss(seg(s, 0, T.burst)) * (1 - seg(s, x.D - 0.9, x.D - 0.3))
			mound.Size = Vector3.new(0.3 + 0.9 * seg(s, 0.3, T.burst), r * 2 + 0.01, r * 2 + 0.01)
			if s < T.burst then shake(0.012) end
		end)
		-- the headstone at the head of the grave, behind him; it rocks, then topples at the burst
		local stone = part(x, { Material = Enum.Material.Slate, Color = C(110, 110, 104), Size = Vector3.new(4, 5, 0.8) })
		local base = f - x.look * 5.5
		each(x, function(s)
			local rock = s < T.burst and math.sin(s * 22) * 0.05 * seg(s, 0.4, T.burst) or 0
			local fall = ss(seg(s, T.burst, T.burst + 0.5)) * 1.45
			stone.CFrame = CFrame.lookAt(base, base + x.look) * CFrame.Angles(-(rock + fall), 0, 0) * CFrame.new(0, 2.5, 0)
			stone.Transparency = seg(s, x.D - 0.7, x.D - 0.2)
		end)
		local gl = light(x, f + UP * 1.5, GRAVE, 26, 0)
		each(x, function(s) gl.Brightness = 2.5 * seg(s, 0.3, T.burst) * (1 - seg(s, x.D - 0.8, x.D - 0.2)) end)
	end)
	stream(x, 0.3, T.burst, f + UP * 0.3, { Texture = SPARK, Color = ColorSequence.new(GRAVE), LightEmission = 1, Size = NumberSequence.new(0.4, 0),
		Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(2, 5), SpreadAngle = Vector2.new(50, 50), EmissionDirection = Enum.NormalId.Top }, 20)
	for _, t in { 0.5, 1.0, 1.35 } do
		at(x, t, function()
			Sfx.play("ShovelDig", { Volume = 1.2, PlaybackSpeed = 0.9 })
			shake(0.2)
			burst(x, f + UP * 0.5, with(dirt, { Speed = NumberRange.new(8, 18), SpreadAngle = Vector2.new(50, 50), EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, -40, 0) }), 16)
		end)
	end
	at(x, T.burst, function()
		Sfx.play("Explosion", { Volume = 0.8, PlaybackSpeed = 0.9 })
		Sfx.play("CoffinCreak", { Volume = 1.3 })
		shake(1.1); kick(12)
		flash(x, GRAVE, 0.3, 0.35)
		ring(x, f, GRAVE, 2, 30, 0.7)
		chunks(x, f + UP, 20, DIRT, Enum.Material.Slate, 34)
		chunks(x, f + UP, 8, C(226, 214, 186), Enum.Material.SmoothPlastic, 24) -- bones
		burst(x, f + UP * 1.5, with(dirt, { Speed = NumberRange.new(16, 40), SpreadAngle = Vector2.new(70, 70), EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, -30, 0) }), 110)
	end)
	at(x, T.land, function()
		Sfx.play("PunchHeavy", { Volume = 1, PlaybackSpeed = 0.6 })
		shake(0.6)
		ring(x, f, x.c2, 1.5, 14, 0.45)
	end)
	at(x, T.rear + 0.15, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.5 })
		Sfx.play("BoneRattle", { Volume = 1.2, PlaybackSpeed = 0.8 })
		shake(0.9); kick(11)
		flash(x, x.c1, 0.25, 0.35)
		ring(x, f, x.c1, 2, 30, 0.7)
		burst(x, f + UP * 1, { Texture = SPARK, Color = ColorSequence.new(GRAVE), LightEmission = 1, Size = NumberSequence.new(0.6, 0),
			Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(10, 22), SpreadAngle = Vector2.new(80, 80), EmissionDirection = Enum.NormalId.Top }, 50)
		x.card()
	end)
	x.camera = function(s)
		local up = seg(s, T.burst, T.peak)
		local down = seg(s, T.peak, T.land)
		local rear = ss(seg(s, T.rear, T.rear + 0.3))
		local y = s < T.burst and 0.8 or (5 * up * (1 - down * down) + x.H * lerp(0.3, 0.62, rear))
		local k = ss(seg(s, 0, x.D))
		return spot(x, lerp(14, 10.5, k), lerp(-4, -2, k), lerp(1.4, x.H * 0.5, ss(seg(s, T.burst, T.rear)))), f + UP * y
	end
end

-- THE BELL RINGER: the bells toll in the dark above, dust rains down; he drops out of the bell tower and lands on
-- one fist - the floor rings like a bell (three bronze shockwaves) - stands, and roars
SCRIPTS.Ringer = function(x)
	local T = EP.T.Titan
	local f = x.floor
	local top = f + UP * (x.ceil - 0.6)
	local BRONZE = C(210, 160, 70)
	local dust = { Color = ColorSequence.new(C(170, 150, 120), C(90, 76, 60)), Size = NumberSequence.new(2.5, 7), Transparency = NumberSequence.new(0.35, 1), Lifetime = NumberRange.new(1, 2.2), Drag = 2 }
	for i, t in { 0, 0.5, 1.0 } do
		at(x, t, function()
			Sfx.play("BellToll", { Volume = 0.6 + i * 0.25, PlaybackSpeed = 0.75 + i * 0.05 })
			shake(0.15 + i * 0.1)
			darkness(x, 0.25 * i, 0.2)
			burst(x, top, with(dust, { Speed = NumberRange.new(2, 8), Acceleration = Vector3.new(0, -26, 0), SpreadAngle = Vector2.new(60, 60), EmissionDirection = Enum.NormalId.Bottom,
				Size = NumberSequence.new(1.2, 3) }), 12 + i * 6)
		end)
	end
	at(x, T.fall, function() Sfx.play("Whoosh", { Volume = 1.3, PlaybackSpeed = 0.45 }) end)
	at(x, T.land, function()
		Sfx.play("BellToll", { Volume = 1.8, PlaybackSpeed = 0.6 })
		Sfx.play("Explosion", { Volume = 0.9, PlaybackSpeed = 0.8 })
		Sfx.play("Crash", { Volume = 1 })
		shake(1.3); kick(15)
		darkness(x, 0, 0.4)
		flash(x, C(255, 220, 160), 0.5, 0.4)
		for i = 0, 2 do task.delay(i * 0.18, function() if x.alive() then ring(x, f, i == 1 and Color3.new(1, 1, 1) or BRONZE, 3, 34 + i * 8, 0.9) end end) end
		chunks(x, f + UP, 18, C(120, 110, 100), Enum.Material.Cobblestone, 34)
		burst(x, f + UP * 1.5, with(dust, { Speed = NumberRange.new(14, 38), SpreadAngle = Vector2.new(85, 85), EmissionDirection = Enum.NormalId.Top }), 110)
		for i = 1, 9 do
			local a = i / 9 * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
			local len = rng:NextNumber(5, 11)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local c = part(x, { Color = BRONZE, Size = Vector3.new(rng:NextNumber(0.25, 0.5), 0.08, len),
				CFrame = CFrame.lookAt(f + dir * (len / 2 + 1.5) + UP * 0.06, f + dir * 40 + UP * 0.06) })
			each(x, function(s) c.Transparency = 0.1 + 0.9 * seg(s, x.D - 0.7, x.D - 0.2) end)
		end
	end)
	at(x, T.roar + 0.05, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.5 })
		Sfx.play("HandBell", { Volume = 1.2, PlaybackSpeed = 0.7 })
		shake(1.0); kick(12)
		ring(x, f, x.c1, 3, 32, 0.8)
		burst(x, f + UP * x.H * 0.75, with(dust, { Speed = NumberRange.new(20, 40), Lifetime = NumberRange.new(0.5, 1) }), 50)
		x.card()
	end)
	at(x, 0, function()
		local l = light(x, spot(x, 6, 2, x.H * 0.7), C(255, 220, 170), 40, 0)
		each(x, function(s) l.Brightness = 0.7 * seg(s, T.fall, T.land) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	x.camera = function(s)
		local fall = seg(s, T.fall, T.land)
		local rise = ss(seg(s, T.rise0, T.rise1))
		local y: number
		if s < T.fall then y = lerp(x.H * 0.5, x.ceil - 1, ss(seg(s, 0, 1.1)))
		elseif s < T.land then y = lerp(x.ceil - 1, x.H * 0.35, fall * fall)
		else y = x.H * lerp(0.35, 0.62, rise) end
		local pull = s >= T.land and 3 * (1 - seg(s, T.land, T.land + 1.2)) or 0
		return spot(x, lerp(17, 13.5, ss(seg(s, 0, x.D))) + pull, -5, lerp(1.5, 2.6, rise)), f + UP * y
	end
end

-- THE LOST ASTRONAUT: the klaxon, a red light turning; an airlock door slides open behind him in a burst of cold fog,
-- he walks out with his helmet lamp on, stops, and raises his fist - his jetpack roars
SCRIPTS.Astronaut = function(x)
	local T = EP.T.Conqueror
	local f = x.floor
	local RED = C(255, 50, 40)
	at(x, 0, function()
		darkness(x, 0.5, 0.3)
		Sfx.play("Klaxon", { Volume = 1.2 })
		-- the airlock behind him: a frame and two doors sliding apart
		local back = f - x.look * (7.5 * x.back + 2.5)
		local cf = CFrame.lookAt(back, back + x.look)
		part(x, { Material = Enum.Material.Metal, Color = C(90, 94, 104), Size = Vector3.new(9, 0.8, 0.8), CFrame = cf * CFrame.new(0, 9.5, 0) })
		for _, sx in { -1, 1 } do
			part(x, { Material = Enum.Material.Metal, Color = C(90, 94, 104), Size = Vector3.new(0.8, 10, 0.8), CFrame = cf * CFrame.new(sx * 4.5, 5, 0) })
			local door = part(x, { Material = Enum.Material.DiamondPlate, Color = C(150, 156, 166), Size = Vector3.new(3.6, 9, 0.4) })
			local stripe = part(x, { Material = Enum.Material.Neon, Color = C(255, 200, 40), Size = Vector3.new(3.6, 0.4, 0.45) })
			each(x, function(s)
				local o = ss(seg(s, T.portal + 0.3, T.step0)) * 3.6 * (1 - ss(seg(s, T.close, T.close + 0.5)))
				door.CFrame = cf * CFrame.new(sx * (1.8 + o), 4.6, 0)
				stripe.CFrame = door.CFrame * CFrame.new(0, 2, 0)
				door.Transparency = seg(s, x.D - 0.6, x.D - 0.2); stripe.Transparency = door.Transparency
			end)
		end
		-- the red alarm light turning
		local al = part(x, { Size = Vector3.one * 0.2, Transparency = 1, CFrame = cf * CFrame.new(0, 11, 1) })
		local sp = Instance.new("SpotLight"); sp.Color = RED; sp.Range = 50; sp.Angle = 60; sp.Brightness = 4; sp.Parent = al
		each(x, function(s) al.CFrame = cf * CFrame.new(0, 11, 1) * CFrame.Angles(0, s * 6, -0.6); sp.Brightness = 4 * (1 - seg(s, x.D - 0.8, x.D - 0.2)) end)
		task.delay(T.portal + 0.3, function() if x.alive() then Sfx.play("Airlock", { Volume = 1.5 }) end end)
	end)
	stream(x, T.portal + 0.3, T.step1, f - x.look * (7.5 * x.back + 1), with(SMOKE_FLOOR, { Color = ColorSequence.new(C(220, 230, 245), C(120, 130, 150)),
		Speed = NumberRange.new(6, 12), EmissionDirection = Enum.NormalId.Front }), 40)
	for i = 0, 3 do at(x, T.step0 + i * 0.45, function() Sfx.play("PunchHeavy", { Volume = 0.5, PlaybackSpeed = 0.5 }); shake(0.08) end) end
	at(x, T.fist, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.4 })
		Sfx.play("Jetpack", { Volume = 1.5 })
		darkness(x, 0, 0.4)
		shake(0.9); kick(12)
		flash(x, C(255, 200, 140), 0.4, 0.4)
		ring(x, f, C(255, 150, 60), 2, 30, 0.7)
		burst(x, f + UP * 1, { Texture = FIRE, Color = ColorSequence.new(C(255, 230, 160), C(255, 120, 40)), LightEmission = 1, Size = NumberSequence.new(2, 0),
			Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(14, 30), SpreadAngle = Vector2.new(85, 85), EmissionDirection = Enum.NormalId.Top }, 60)
		burst(x, f + UP * 1, with(SMOKE_FLOOR, { Color = ColorSequence.new(C(220, 220, 230)), Speed = NumberRange.new(16, 30), Lifetime = NumberRange.new(0.8, 1.4) }), 40)
		x.card()
	end)
	x.camera = function(s)
		local k = ss(seg(s, 0, x.D))
		local walk = seg(s, T.step0, T.step1)
		return spot(x, lerp(16, 11.5, k), lerp(3.5, 1.5, k), lerp(2, x.H * 0.42, k)), body(x, lerp(6, 0, walk), x.H * lerp(0.5, 0.66, ss(seg(s, T.fist, T.clench))))
	end
end

-- THE SPECIMEN: green slime drips from the dark ceiling; it crawls along up there upside down, drops in a splash of
-- acid and screeches
SCRIPTS.Specimen = function(x)
	local T = EP.T.Antlered
	local f = x.floor
	local ACIDC = C(140, 255, 90)
	local cl = math.min(x.ceil, 26)
	local hv = tonumber(x.model:GetAttribute("Hover")) or 6
	local yRoot = math.max(0, cl - 2 * hv)
	local chestUp = math.max(2, hv + yRoot - (x.H - hv) * 0.45)
	local function zAt(s: number): number return 9 * (1 - ss(seg(s, T.crawl0, T.crawl1))) end
	at(x, 0, function()
		darkness(x, 0.45, 0.4)
		Sfx.play(Sfx.voice("WindUp", x.id), { Volume = 1.2 })
		local gl = light(x, f + UP * 2, ACIDC, 30, 0)
		each(x, function(s) gl.Brightness = 1.5 * seg(s, 0, 1) * (1 - seg(s, x.D - 0.6, x.D - 0.1)) end)
	end)
	-- slime dripping off it while it crawls
	for i = 0, 5 do
		at(x, 0.2 + i * 0.28, function()
			local p = body(x, zAt(0.2 + i * 0.28), cl - 1)
			burst(x, p, { Texture = SPARK, Color = ColorSequence.new(ACIDC), LightEmission = 1, Size = NumberSequence.new(0.4, 0.2), Lifetime = NumberRange.new(0.6, 0.9),
				Speed = NumberRange.new(1, 3), Acceleration = Vector3.new(0, -50, 0), SpreadAngle = Vector2.new(10, 10), EmissionDirection = Enum.NormalId.Bottom }, 6)
			if i % 2 == 0 then Sfx.play("FormSquish", { Volume = 0.6, PlaybackSpeed = 1.2 + i * 0.05 }) end
		end)
	end
	at(x, T.fall, function() Sfx.play("Whoosh", { Volume = 1.2, PlaybackSpeed = 0.6 }) end)
	at(x, T.land, function()
		Sfx.play("AcidSizzle", { Volume = 1.4 })
		Sfx.play("Crash", { Volume = 0.8 })
		shake(1.0); kick(12)
		darkness(x, 0, 0.5)
		ring(x, f, ACIDC, 3, 28, 0.7)
		local pool = disc(x, f + UP * 0.07, 7, ACIDC, 0.3)
		each(x, function(s) pool.Transparency = 0.3 + 0.7 * seg(s, x.D - 0.8, x.D - 0.2) end)
		burst(x, f + UP * 1, { Texture = SPARK, Color = ColorSequence.new(ACIDC), LightEmission = 1, Size = NumberSequence.new(1, 0.2), Lifetime = NumberRange.new(0.5, 1),
			Speed = NumberRange.new(14, 30), Acceleration = Vector3.new(0, -50, 0), SpreadAngle = Vector2.new(70, 70), EmissionDirection = Enum.NormalId.Top }, 80)
	end)
	at(x, T.roar, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.5 })
		Sfx.play("AlienScreech", { Volume = 1.2 })
		shake(0.9); kick(11)
		flash(x, ACIDC, 0.25, 0.35)
		ring(x, f, x.c1, 3, 32, 0.8)
		x.card()
	end)
	x.camera = function(s)
		local fall = seg(s, T.fall, T.land)
		local rise = ss(seg(s, T.rise0, T.rise1))
		local hy: number
		if s < T.fall then hy = chestUp elseif s < T.land then hy = lerp(chestUp, x.H * 0.4, fall * fall) else hy = x.H * lerp(0.4, 0.7, rise) end
		local pull = s >= T.land and 2.5 * (1 - seg(s, T.land, T.land + 1)) or 0
		return spot(x, lerp(13, 11, ss(seg(s, 0, x.D))) + pull, -3.5, lerp(1.6, 2.4, rise)), body(x, s < T.fall and zAt(s) or 0, hy)
	end
end

-- THE SENTINEL: powered down in the dark, head bowed; one red eye flickers on, its servos whine, it straightens and
-- spreads its arms, sparks pour off its joints, a red scanning fan sweeps the room, its lights come up
SCRIPTS.Sentinel = function(x)
	local T = EP.T.Ringmaster
	local f = x.floor
	local RED = C(255, 60, 50)
	at(x, 0, function()
		darkness(x, 0.65, 0.2)
		Sfx.play("RobotServo", { Volume = 0.8, PlaybackSpeed = 0.5 })
		local eye = x.model:FindFirstChild("Eye", true) :: BasePart?
		local el = light(x, limb(x, "Head"), RED, 24, 0)
		each(x, function(s)
			local on = s > T.spot and ((s < T.raise and (math.sin(s * 40) > 0.2)) or s >= T.raise) and 1 or 0
			el.Brightness = on * (1.5 + seg(s, T.raise, T.arms) * 2)
			local h = x.model:FindFirstChild("Head") :: BasePart?
			if h then (el.Parent :: BasePart).Position = h.Position + x.look * 1.5 end
			if eye then eye.Transparency = 1 - on end
		end)
	end)
	at(x, T.spot, function() Sfx.play("Breaker", { Volume = 1, PlaybackSpeed = 0.7 }) end)
	at(x, T.raise, function()
		Sfx.play("RobotServo", { Volume = 1.3 })
		Sfx.play(Sfx.voice("WindUp", x.id), { Volume = 1.2 })
		darkness(x, 0.35, 0.4)
	end)
	stream(x, T.arms, T.lights, limb(x, "RightUpperArm"), { Texture = SPARK, Color = ColorSequence.new(C(255, 220, 120)), LightEmission = 1, Size = NumberSequence.new(0.35, 0),
		Lifetime = NumberRange.new(0.3, 0.7), Speed = NumberRange.new(8, 16), Acceleration = Vector3.new(0, -40, 0), SpreadAngle = Vector2.new(60, 60) }, 40)
	stream(x, T.arms, T.lights, limb(x, "LeftUpperArm"), { Texture = SPARK, Color = ColorSequence.new(C(255, 220, 120)), LightEmission = 1, Size = NumberSequence.new(0.35, 0),
		Lifetime = NumberRange.new(0.3, 0.7), Speed = NumberRange.new(8, 16), Acceleration = Vector3.new(0, -40, 0), SpreadAngle = Vector2.new(60, 60) }, 40)
	at(x, T.arms, function()
		Sfx.play("ElectricArc", { Volume = 1.2 })
		-- the scanning fan: red lines from its eye sweeping the room
		local head = limb(x, "Head")
		for i = -3, 3 do
			local ln = part(x, { Color = RED, Transparency = 0.4, Size = Vector3.new(0.12, 0.12, 30) })
			each(x, function(s)
				local k = seg(s, T.arms, T.crack)
				local yaw = (i * 0.12) + math.sin(k * math.pi * 2) * 0.5
				local d = (CFrame.Angles(0, yaw, 0) * (x.look - UP * 0.25)).Unit
				ln.CFrame = CFrame.lookAt(head + d * 15, head + d * 30)
				ln.Transparency = (s > T.arms and s < T.crack) and 0.4 or 1
			end)
		end
	end)
	at(x, T.crack, function()
		Sfx.play(Sfx.voice("Spawn", x.id), { Volume = 1.5 })
		Sfx.play("Klaxon", { Volume = 1 })
		shake(0.9); kick(12)
		flash(x, RED, 0.35, 0.4)
		ring(x, f, RED, 2, 32, 0.8)
		for i = 1, 8 do
			local a = i / 8 * math.pi * 2
			bolt(x, limb(x, "UpperTorso"), f + Vector3.new(math.cos(a) * 9, 0.2, math.sin(a) * 9), C(110, 220, 255), 0.3, 0.3)
		end
	end)
	at(x, T.lights, function()
		darkness(x, 0, 0.5)
		Sfx.play("Breaker", { Volume = 1.2, PlaybackSpeed = 1.1 })
		x.card()
	end)
	x.camera = function(s)
		local push = ss(seg(s, 0, T.crack))
		return spot(x, lerp(16, 11, push), lerp(-4, -1.5, push), lerp(2.2, x.H * 0.5, push)), f + UP * x.H * lerp(0.55, 0.72, push)
	end
end

function Entrance.play(model: Model?, id: string, evolved: boolean, title: string, rarity: number, level: number, dur: number)
	if not SCRIPTS[id] or not lp:GetAttribute("InMatch") then return end
	token += 1
	local my = token
	task.spawn(function()
		local m = model
		if not m or not m.Parent then m = workspace:WaitForChild("Ghost", 2) :: Model? end
		local hrp = m and m:WaitForChild("HumanoidRootPart", 2) :: BasePart?
		if not m or not hrp or my ~= token then return end
		local rp = structure()
		local down = workspace:Raycast(hrp.Position + UP * 2, Vector3.new(0, -60, 0), rp)
		local floor = down and down.Position or (hrp.Position - UP * 5)
		local upHit = workspace:Raycast(floor + UP * 1.5, Vector3.new(0, 80, 0), rp)
		local ceil = upHit and (upHit.Position.Y - floor.Y) or 60
		-- it faces the nearest player of the run (the server turns it the same way)
		local lv = hrp.CFrame.LookVector
		local nearest = math.huge
		for _, p in Players:GetPlayers() do
			local ch = p.Character
			local ph = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
			if ph and p:GetAttribute("InMatch") and (ph.Position - hrp.Position).Magnitude < nearest then
				nearest = (ph.Position - hrp.Position).Magnitude
				lv = ph.Position - hrp.Position
			end
		end
		local look = Vector3.new(lv.X, 0, lv.Z)
		look = look.Magnitude > 0.05 and look.Unit or Vector3.new(0, 0, 1)
		local H = EP.height(m)
		local chest = floor + UP * math.min(H * 0.6, ceil - 1)
		-- the camera stands in front of the monster if there is room, else on the freest side
		-- the Void Knight comes through a real wall of the map (Server/KnightDoor): the camera stands in the room he
		-- steps into, facing that wall
		local door = nil
		local dcf = m:GetAttribute("KnightDoor")
		if id == "Knight" and typeof(dcf) == "CFrame" then
			local dm = workspace:FindFirstChild("KnightDoor") or workspace:WaitForChild("KnightDoor", 1)
			local plugs = {} :: { BasePart }
			if dm then
				for _, p in dm:GetDescendants() do
					if p:IsA("BasePart") then table.insert(plugs, p) end
				end
			end
			local dw, dh = m:GetAttribute("KnightDoorW"), m:GetAttribute("KnightDoorH")
			door = {
				pos = dcf.Position, look = Vector3.new(dcf.LookVector.X, 0, dcf.LookVector.Z).Unit, plugs = plugs, model = dm,
				w = type(dw) == "number" and dw or 5.6, h = type(dh) == "number" and dh or math.min(H + 1.2, 10),
			}
		end
		local best, bestD = look, -1.0
		if door then
			best, bestD = door.look, freeDist(chest, door.look, 17, rp)
		else
			for _, deg in { 0, 25, -25, 50, -50, 80, -80, 115, -115, 180 } do
				local dir = (CFrame.Angles(0, math.rad(deg), 0) * look) :: Vector3
				local d = freeDist(chest, dir, 17, rp)
				if d >= 12 then best, bestD = dir, d; break end
				if d > bestD then best, bestD = dir, d end
			end
		end
		local pal = (COLORS[id] or COLORS.Woman)[evolved and 2 or 1]
		local folder = Instance.new("Folder")
		folder.Name = "EntranceFx"
		folder.Parent = workspace
		local pg = lp:WaitForChild("PlayerGui")
		local gui = Instance.new("ScreenGui")
		gui.Name = "EntranceCine"; gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false; gui.DisplayOrder = 65
		gui.Parent = pg
		local dark = Grunge.frame(gui, { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 1 })
		local flashF = Grunge.frame(gui, { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), ZIndex = 2 })
		local bars = {}
		for _, top in { true, false } do
			local b = Grunge.frame(gui, { BackgroundTransparency = 0, BackgroundColor3 = Color3.new(0, 0, 0), AnchorPoint = Vector2.new(0, top and 1 or 0),
				Position = UDim2.fromScale(0, top and 0 or 1), Size = UDim2.fromScale(1, 0.11), ZIndex = 3 })
			TweenService:Create(b, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { AnchorPoint = Vector2.new(0, top and 0 or 1) }):Play()
			table.insert(bars, { f = b, top = top })
		end
		-- every other screen of the game's UI is hidden for the shot, and comes back afterwards
		local hidden = {} :: { ScreenGui }
		for _, g in pg:GetChildren() do
			if g:IsA("ScreenGui") and g.Enabled and g ~= gui and g.Name ~= "CineBars" then g.Enabled = false; table.insert(hidden, g) end
		end
		local x: Ctx = {
			model = m, hrp = hrp, id = id, evolved = evolved, D = dur, s = 0,
			-- the monster is turned to face the camera (EntrancePose.clock.face), so "its front" is the camera's side
			floor = floor, look = best, cdir = best, cright = best:Cross(UP), clear = bestD, ceil = ceil, H = H,
			back = door and 1 or math.clamp(freeDist(chest, -best, 18, rp) / 18, 0.25, 1), door = door,
			c1 = pal[1], c2 = pal[2], folder = folder, gui = gui, dark = dark, flashF = flashF,
			events = {}, frames = {}, camera = nil, card = function() end, cleanup = {},
			alive = function() return my == token and folder.Parent ~= nil end,
		}
		-- THE NAME CARD: slammed in at the monster's big moment
		local carded = false
		x.card = function()
			if carded then return end
			carded = true
			local def: any = evolved and Monsters.evolved(id, 1) or Monsters.byId[id]
			local holder = Grunge.frame(gui, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0.05, 0.86), Size = UDim2.fromScale(0.62, 0.3), ZIndex = 5 })
			holder.Name = "Card"
			local tag = RARITY_TAG[rarity]
			local top = Grunge.text(holder, { Text = "GHOST " .. tostring(level) .. (tag and ("   -   " .. tag) or ""), Font = Grunge.TYPE, Position = UDim2.fromScale(0.01, 0), Size = UDim2.fromScale(0.9, 0.16),
				TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = pal[1]:Lerp(Color3.new(1, 1, 1), 0.35), ZIndex = 6 })
			Grunge.brush(holder, { Position = UDim2.fromScale(-0.02, 0.2), Size = UDim2.fromScale(0.86, 0.5), ZIndex = 5, Rotation = -1.5 }, pal[2]:Lerp(Color3.new(0, 0, 0), 0.35), 77, 22, false)
			local name = Grunge.text(holder, { Text = title, Font = Grunge.HORROR, Position = UDim2.fromScale(0.01, 0.17), Size = UDim2.fromScale(0.98, 0.56), TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = pal[1]:Lerp(Color3.new(1, 1, 1), 0.2), Rotation = -1.5, ZIndex = 7 })
			local desc = Grunge.text(holder, { Text = def and def.desc or "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.01, 0.76), Size = UDim2.fromScale(0.98, 0.22), TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextColor3 = Grunge.PAPER, ZIndex = 6 })
			local dc = Instance.new("UITextSizeConstraint"); dc.MaxTextSize = 24; dc.MinTextSize = 10; dc.Parent = desc
			local sc = Instance.new("UIScale"); sc.Scale = 2.4; sc.Parent = holder
			TweenService:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Scale = 1 }):Play()
			name.TextTransparency = 1; top.TextTransparency = 1; desc.TextTransparency = 1
			TweenService:Create(name, TweenInfo.new(0.15), { TextTransparency = 0 }):Play()
			TweenService:Create(top, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
			task.delay(0.35, function() TweenService:Create(desc, TweenInfo.new(0.4), { TextTransparency = 0 }):Play() end)
		end
		-- (a broken effect must not stop the cinematic: it is reported and the rest plays on)
		local built, why = pcall(SCRIPTS[id], x)
		if not built then warn("[Entrance] " .. id .. ": " .. tostring(why)) end
		table.sort(x.events, function(a, b) return a.t < b.t end)
		EP.clock.model = m
		EP.clock.s = 0
		EP.clock.back = x.back
		EP.clock.face = best
		EP.clock.ceil = ceil
		if Fx then Fx.cine = true end
		local nextEvent = 1
		local name = "EntranceCam" .. my
		-- what the camera's line of sight goes through: everything but the house itself, the monster, the players
		-- and the effects
		local hiddenParts = {} :: { BasePart }
		local ignore = { m, folder } :: { Instance }
		if x.door and x.door.model then table.insert(ignore, x.door.model) end
		do
			local mansion = workspace:FindFirstChild("Mansion")
			local st = mansion and mansion:FindFirstChild("Structure")
			if st then table.insert(ignore, st) end
			for _, p in Players:GetPlayers() do if p.Character then table.insert(ignore, p.Character) end end
		end
		local sight = RaycastParams.new()
		sight.FilterType = Enum.RaycastFilterType.Exclude
		sight.FilterDescendantsInstances = ignore
		local done = false
		local function finish()
			if done then return end
			done = true
			RunService:UnbindFromRenderStep(name)
			if EP.clock.model == m then EP.clock.model = nil end
			for _, c in x.cleanup do task.spawn(c) end
			for _, d in hiddenParts do if d.Parent then d.LocalTransparencyModifier = 0 end end
			for _, g in hidden do g.Enabled = true end
			if my == token then
				if Fx then Fx.cine = false; Fx.cineFov = nil end
				cam.CameraType = Enum.CameraType.Custom
			end
			for _, b in bars do
				TweenService:Create(b.f, TweenInfo.new(0.3), { AnchorPoint = Vector2.new(0, b.top and 1 or 0) }):Play()
			end
			TweenService:Create(dark, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
			local card = gui:FindFirstChild("Card")
			if card then
				for _, d in card:GetDescendants() do
					if d:IsA("TextLabel") then TweenService:Create(d, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
					elseif d:IsA("Frame") then TweenService:Create(d, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play() end
				end
			end
			Debris:AddItem(gui, 1.6) -- (the name stays a moment while the camera is back in your eyes)
			-- the rubble lies there a little longer; everything else goes now
			for _, d in folder:GetChildren() do
				if d:IsA("BasePart") and d.Anchored then d:Destroy() end
			end
			Debris:AddItem(folder, 2.5)
		end
		RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value, function(dt)
			if my ~= token or not m.Parent or not lp:GetAttribute("InMatch") then finish(); return end
			local scale, freezeAt = 1, nil :: number?
			if RunService:IsStudio() then
				local sc, fr = RS:GetAttribute("DebugEntranceScale"), RS:GetAttribute("DebugEntranceFreezeAt")
				if type(sc) == "number" then scale = sc end
				if type(fr) == "number" then freezeAt = fr end
			end
			local s = x.s + dt * scale
			if freezeAt and s > freezeAt then s = math.max(x.s, freezeAt) end
			x.s = s
			EP.clock.s = s
			if s >= dur - 0.3 then finish(); return end
			while x.events[nextEvent] and x.events[nextEvent].t <= s do
				local e = x.events[nextEvent]
				nextEvent += 1
				task.spawn(e.fn)
			end
			for i = #x.frames, 1, -1 do
				local ok, why = pcall(x.frames[i], s, dt)
				if not ok then
					warn("[Entrance] " .. id .. " frame: " .. tostring(why))
					table.remove(x.frames, i)
				end
			end
			if x.camera then
				local eye, target = x.camera(s)
				-- a small room (the camera can't step back): a wider lens, and the camera comes level with the
				-- monster's chest instead of looking up at it from its feet
				local away = Vector3.new(eye.X - target.X, 0, eye.Z - target.Z).Magnitude
				local tight = math.clamp((10 - away) / 6, 0, 1)
				if tight > 0 then
					local mid = x.floor.Y + math.min(x.H * 0.6, x.ceil - 1)
					eye = Vector3.new(eye.X, lerp(eye.Y, mid, tight * 0.85), eye.Z)
					target = Vector3.new(target.X, lerp(target.Y, mid, tight * 0.6), target.Z)
				end
				if Fx then Fx.cineFov = 74 + 30 * tight end
				-- furniture standing between the camera and the monster is hidden for the shot (only on this screen)
				for _ = 1, 4 do
					local hit = workspace:Raycast(eye, (target - eye) * 0.92, sight)
					if not hit then break end
					local top: Instance = hit.Instance
					while top.Parent and top.Parent:IsA("Model") and top.Parent ~= workspace:FindFirstChild("Mansion") do top = top.Parent end
					for _, d in (top:IsA("BasePart") and { top } or top:GetDescendants()) :: { Instance } do
						if d:IsA("BasePart") then
							d.LocalTransparencyModifier = 1
							table.insert(hiddenParts, d)
						end
					end
					table.insert(ignore, top)
					sight.FilterDescendantsInstances = ignore
				end
				cam.CameraType = Enum.CameraType.Scriptable
				cam.CFrame = CFrame.lookAt(eye, target)
				cam.Focus = CFrame.new(target)
			end
		end)
	end)
end

return Entrance
