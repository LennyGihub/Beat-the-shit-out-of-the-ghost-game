-- Client effects for the monsters' special abilities (server: Abilities.luau):
-- wind-up glows, grab hold, pounce, banshee wail ring, blackout, toxic gas, hellfire marks + pillars,
-- knight charge trail, mirror clone spawn/shatter.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local MonsterFx = {}
local lp = Players.LocalPlayer
local Fx, HUD, Sfx
local rng = Random.new()
local KINDS = {
	AbilityWind = true, AbilityHit = true, Grabbed = true, Released = true, Pounce = true, Wail = true,
	Blackout = true, BlackoutEnd = true, GasThrow = true, GasCloud = true, Gassed = true,
	HellMark = true, HellPillar = true, Charge = true, CloneSpawn = true, CloneShatter = true, StalkerBlink = true, BlackoutExtend = true,
	WarpWind = true, Warp = true, LaserWind = true, LaserBeam = true, LaserEnd = true, LaserHit = true, -- the Conqueror
	AmbushBreath = true, AmbushStrike = true, AmbushStab = true, AmbushFound = true, AmbushWake = true, ShotgunAim = true, ShotgunFire = true, ShotgunPump = true, -- the Caller
	GoblinSteal = true, GoblinUse = true, GoblinDrop = true,
	ShieldBlock = true, Slammed = true, AnimJumpscare = true,
	RoarWind = true, Roar = true, LungeWind = true, Lunge = true, Enraged = true, CounterWind = true, FuryArmor = true, FurySmash = true, -- Fury
	SnapWind = true, Snap = true, TitanEat = true, TitanHeal = true, TitanGrabWind = true, -- evolved monsters / the Giant's grab
	DemonSummon = true, -- the Red Demon conjures furniture
	ForceWind = true, ForceGrab = true, ForceHold = true, ForcePush = true, ForceMiss = true, SaberCut = true, SaberSwing = true, -- the Void Knight
	RatDashWarn = true, RatDash = true, RatDizzy = true, RatDig = true, RatTrail = true, RatWarn = true, RatErupt = true, -- the Sewer Rat
}
local Settings = require(script.Parent.Settings)
local MaskBreath = require(script.Parent.MaskBreath)
local Items = require(game:GetService("ReplicatedStorage").Shared.Items)
local GOBLIN = Color3.fromRGB(130, 230, 70)
local GOLD = Color3.fromRGB(255, 205, 60)
local sprayPE: ParticleEmitter? = nil
function MonsterFx.handles(kind: string): boolean return KINDS[kind] == true end

local function part(props: { [string]: any }): BasePart
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Material = Enum.Material.Neon
	for k, v in props do (p :: any)[k] = v end
	p.Parent = workspace.Terrain
	return p
end

local function disc(pos: Vector3, r: number, color: Color3, t: number): BasePart
	return part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.15, r * 2, r * 2), Color = color, Transparency = t,
		CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2) })
end

local function emitter(pos: Vector3, props: { [string]: any }, emit: number?, life: number?): ParticleEmitter
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.SpreadAngle = Vector2.new(180, 180)
	for k, v in props do (pe :: any)[k] = v end
	pe.Parent = a
	if emit then pe.Rate = 0; pe:Emit(Settings.fxCount(emit)) end -- particle setting (Settings)
	Debris:AddItem(a, life or 3)
	return pe
end

local function near(pos: Vector3, d: number): number
	local cam = workspace.CurrentCamera
	local dist = (cam.CFrame.Position - pos).Magnitude
	return dist < d and (1 - dist / d) or 0
end

-- held in the butcher's hand: pinned to it locally until the throw
local holdConn: RBXScriptConnection? = nil
local function release()
	if holdConn then holdConn:Disconnect(); holdConn = nil end
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

-- the Party Bear's jumpscare: its face rushes at the screen out of the dark (a clone of the monster in a
-- ViewportFrame, eyes lit), with a scream, a white flash and a hard shake
local function jumpscare(model: any)
	Sfx.play("Jumpscare", { Volume = 1.6 })
	Fx.shake(1.1)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then HUD.flash(Color3.new(1, 1, 1), 0.6); return end
	local ok, clone = pcall(function() return (model :: Model):Clone() end)
	if not ok or not clone then return end
	local gui = Instance.new("ScreenGui")
	gui.Name = "Jumpscare"; gui.IgnoreGuiInset = true; gui.DisplayOrder = 60; gui.ResetOnSpawn = false
	local vp = Instance.new("ViewportFrame")
	vp.Size = UDim2.fromScale(1, 1); vp.BackgroundColor3 = Color3.new(0, 0, 0); vp.BorderSizePixel = 0
	vp.Ambient = Color3.fromRGB(70, 60, 55); vp.LightColor = Color3.fromRGB(150, 160, 190); vp.LightDirection = Vector3.new(0.3, -0.4, 1)
	vp.Parent = gui
	for _, d in clone:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true; d.LocalTransparencyModifier = 0
			if d:GetAttribute("DarkNeon") then d.Material = Enum.Material.Neon end
		elseif d:IsA("Constraint") or d:IsA("LuaSourceContainer") or d:IsA("Attachment") then
			d:Destroy()
		end
	end
	clone:PivotTo(CFrame.new())
	clone.Parent = vp
	local head = clone:FindFirstChild("Head") :: BasePart?
	local focus = head and (head.CFrame * Vector3.new(0, 0.1, 0)) or Vector3.new(0, 5, 0)
	if head then
		-- the jaw drops wide open (jaw + its teeth turn about a hinge under the snout)
		local hinge = head.CFrame * CFrame.new(0, -0.85, -0.45)
		local turn = hinge * CFrame.Angles(-0.6, 0, 0) * hinge:Inverse()
		for _, d in clone:GetDescendants() do
			if d:IsA("BasePart") and (d.Name == "Jaw" or d.Name == "JawRound" or d.Name == "Tooth" or d.Name == "MouthInside") then
				d.CFrame = turn * d.CFrame
			end
		end
	end
	local cam = Instance.new("Camera"); cam.FieldOfView = 60; cam.Parent = vp
	vp.CurrentCamera = cam
	gui.Parent = lp:WaitForChild("PlayerGui")
	local t0 = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = os.clock() - t0
		local k = math.min(1, t / 0.18)
		local dist = 10 - 5.2 * (1 - (1 - k) ^ 3) -- lunges from 10 studs to 4.8 (face filling the screen) in a split second
		local jit = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), 0) * (0.08 + 0.1 * (1 - k))
		cam.CFrame = CFrame.lookAt(focus + Vector3.new(0, -0.3, -dist) + jit, focus) * CFrame.Angles(0, 0, math.sin(t * 40) * 0.04)
		if lp:GetAttribute("DebugJumpscareHold") then t0 = os.clock() - 0.5; return end
		if t > 0.85 then
			vp.ImageTransparency = math.min(1, (t - 0.85) / 0.25); vp.BackgroundTransparency = vp.ImageTransparency
		end
		if t > 1.1 then conn:Disconnect(); gui:Destroy() end
	end)
	task.delay(0.85, function() HUD.flash(Color3.new(1, 1, 1), 0.5) end)
end

local blackoutCC: ColorCorrectionEffect? = nil
-- the Party Bear's blackout: every lamp in the house drops to 5% (glowing neon dulled), each player gets a
-- small light around them so they can still find their way, and a music box plays while it hunts; all put back
-- when it ends
local DIM = 0.05
local dimmed = {} :: { [Instance]: any }
local musicBox: Sound? = nil
local bodyLights = {} :: { PointLight }
local function playerLights(on: boolean)
	for _, l in bodyLights do l:Destroy() end
	table.clear(bodyLights)
	if not on then return end
	for _, p in Players:GetPlayers() do
		local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if r then
			local l = Instance.new("PointLight")
			l.Name = "DarkLight"; l.Color = Color3.fromRGB(255, 214, 170); l.Shadows = false -- (it sits inside the body)
			-- yours is a little stronger than your teammates'
			l.Range = p == lp and 16 or 10; l.Brightness = p == lp and 2 or 1.2
			l.Parent = r
			table.insert(bodyLights, l)
		end
	end
end
local function lightsOut(on: boolean)
	if on then
		local house = workspace:FindFirstChild("Mansion")
		if not house then return end
		for _, d in house:GetDescendants() do
			if dimmed[d] == nil then
				if d:IsA("Light") and d.Enabled then
					dimmed[d] = d.Brightness; d.Brightness = d.Brightness * DIM
				elseif d:IsA("BasePart") and d.Material == Enum.Material.Neon then
					dimmed[d] = d.Color; d.Material = Enum.Material.SmoothPlastic; d.Color = d.Color:Lerp(Color3.new(0, 0, 0), 0.75)
				end
			end
		end
		playerLights(true)
		Sfx.play("Breaker", { Volume = 1.2, PlaybackSpeed = 0.7 })
		if musicBox then musicBox:Destroy() end
		musicBox = Sfx.loop("MusicBox", { PlaybackSpeed = 0.85 })
	else
		for d, v in dimmed do
			if d.Parent then
				if d:IsA("Light") then (d :: Light).Brightness = v
				else (d :: BasePart).Material = Enum.Material.Neon; (d :: BasePart).Color = v end
			end
		end
		table.clear(dimmed)
		playerLights(false)
		if musicBox then musicBox:Destroy(); musicBox = nil end
	end
end

local blackoutId = 0
local function blackout(on: boolean, t: number?, allLights: boolean?)
	if not blackoutCC then
		blackoutCC = Instance.new("ColorCorrectionEffect")
		blackoutCC.Name = "Blackout"
		blackoutCC.Parent = Lighting
	end
	local cc = blackoutCC :: ColorCorrectionEffect
	if on then
		Sfx.play("GhostWhisper", { Volume = 1.2, PlaybackSpeed = 0.6 })
		HUD.banner("THE LIGHTS ARE OUT", allLights and "WATCH FOR ITS EYES" or "IT'S COMING FOR YOU", 2.5)
		local dark = allLights and { Brightness = -0.05, Contrast = 0.15, Saturation = -0.4 } or { Brightness = -0.32, Contrast = 0.5, Saturation = -0.8 }
		TweenService:Create(cc, TweenInfo.new(allLights and 0.15 or 0.4), dark):Play()
		if allLights then lightsOut(true) end
		blackoutId += 1
		local id = blackoutId
		-- safety end, ignored if this blackout already ended and a newer one started
		task.delay((t or 5) + 0.2, function() if id == blackoutId then blackout(false) end end)
	else
		TweenService:Create(cc, TweenInfo.new(0.6), { Brightness = 0, Contrast = 0, Saturation = 0 }):Play()
		lightsOut(false)
	end
end

local gasCC: ColorCorrectionEffect? = nil
local function gassed()
	if not gasCC then
		gasCC = Instance.new("ColorCorrectionEffect")
		gasCC.Name = "Gas"
		gasCC.Parent = Lighting
	end
	local cc = gasCC :: ColorCorrectionEffect
	cc.TintColor = Color3.fromRGB(170, 255, 120)
	TweenService:Create(cc, TweenInfo.new(1.2), { TintColor = Color3.new(1, 1, 1) }):Play()
	Fx.shake(0.12)
end

local FURY = Color3.fromRGB(255, 45, 25)
-- an enraged monster: red glow + embers for the rest of its life
local function enrage(model: Instance?)
	if not model or not model:IsA("Model") or model:FindFirstChild("FuryGlow") then return end
	local hl = Instance.new("Highlight")
	hl.Name = "FuryGlow"; hl.FillColor = FURY; hl.FillTransparency = 0.8; hl.OutlineColor = Color3.fromRGB(255, 90, 40)
	hl.OutlineTransparency = 0.2; hl.DepthMode = Enum.HighlightDepthMode.Occluded; hl.Parent = model
	local root = model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
	if root then
		local pe = Instance.new("ParticleEmitter")
		pe.Name = "FuryEmbers"; pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Color = ColorSequence.new(FURY, Color3.fromRGB(255, 160, 60)); pe.LightEmission = 1
		pe.Size = NumberSequence.new(0.5, 0); pe.Speed = NumberRange.new(2, 5); pe.Lifetime = NumberRange.new(0.6, 1.1)
		pe.Rate = 18; pe.Acceleration = Vector3.new(0, 6, 0); pe.SpreadAngle = Vector2.new(180, 180); pe.Parent = root
	end
end

-- THE CONQUEROR --------------------------------------------------------------------------------------------
local PURPLE = Color3.fromRGB(190, 90, 255)
-- a portal: a dark disc with a purple rim standing where he steps in / out, smoke pouring from it
local function portal(pos: Vector3, facing: Vector3?, life: number)
	local look = facing and Vector3.new(facing.X, 0, facing.Z) or Vector3.zAxis
	look = look.Magnitude > 0.1 and look.Unit or Vector3.zAxis
	local cf = CFrame.lookAt(pos + Vector3.new(0, 1, 0), pos + Vector3.new(0, 1, 0) + look) * CFrame.Angles(0, math.pi / 2, 0)
	local rim = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.5, 1, 1), Color = PURPLE, Transparency = 0.15, CFrame = cf })
	local hole = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.6, 0.8, 0.8), Color = Color3.fromRGB(8, 4, 14), Material = Enum.Material.SmoothPlastic, CFrame = cf })
	local l = Instance.new("PointLight"); l.Color = PURPLE; l.Range = 26; l.Brightness = 3; l.Shadows = false; l.Parent = rim
	local open = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(rim, open, { Size = Vector3.new(0.5, 15, 15) }):Play()
	TweenService:Create(hole, open, { Size = Vector3.new(0.6, 13.6, 13.6) }):Play()
	task.delay(life, function()
		local shut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(rim, shut, { Size = Vector3.new(0.5, 0.2, 0.2), Transparency = 1 }):Play()
		TweenService:Create(hole, shut, { Size = Vector3.new(0.6, 0.1, 0.1), Transparency = 1 }):Play()
		Debris:AddItem(rim, 0.35); Debris:AddItem(hole, 0.35)
	end)
	emitter(pos + Vector3.new(0, 1, 0), { Color = ColorSequence.new(Color3.fromRGB(120, 50, 190), Color3.fromRGB(10, 4, 18)), LightEmission = 0.4,
		Size = NumberSequence.new(2.5, 6), Transparency = NumberSequence.new(0.3, 1), Speed = NumberRange.new(4, 12), Lifetime = NumberRange.new(0.6, 1.2),
		Rate = 60 }, nil, life + 1)
end

-- the Golden Conqueror's beam: one beam, moved to where the server says (eased between its 10 updates a second)
local beam: { core: BasePart, glow: BasePart, tip: BasePart, model: Instance?, from: Vector3, to: Vector3, want: Vector3, last: number, conn: RBXScriptConnection, nextZap: number }? = nil
local function beamOff()
	local b = beam
	if not b then return end
	beam = nil
	b.conn:Disconnect()
	for _, p in { b.core, b.glow, b.tip } do
		TweenService:Create(p, TweenInfo.new(0.2), { Transparency = 1 }):Play()
		Debris:AddItem(p, 0.25)
	end
end
local function beamTo(model: Instance?, from: Vector3, to: Vector3)
	if not beam then
		local core = part({ Shape = Enum.PartType.Cylinder, Color = Color3.fromRGB(245, 225, 255), Transparency = 0 })
		local glowP = part({ Shape = Enum.PartType.Cylinder, Color = PURPLE, Transparency = 0.45 })
		local tip = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(5, 5, 5), Color = PURPLE, Transparency = 0.25 })
		local l = Instance.new("PointLight"); l.Color = PURPLE; l.Range = 34; l.Brightness = 4; l.Shadows = false; l.Parent = tip
		local sparks = Instance.new("ParticleEmitter")
		sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"; sparks.Color = ColorSequence.new(PURPLE, Color3.fromRGB(255, 230, 255))
		sparks.LightEmission = 1; sparks.Size = NumberSequence.new(1.6, 0); sparks.Speed = NumberRange.new(14, 30); sparks.Lifetime = NumberRange.new(0.2, 0.5)
		sparks.SpreadAngle = Vector2.new(180, 180); sparks.Rate = 70; sparks.Parent = tip
		local b = { core = core, glow = glowP, tip = tip, model = model, from = from, to = to, want = to, last = os.clock(), nextZap = 0, conn = nil :: any }
		b.conn = RunService.RenderStepped:Connect(function(dt)
			if os.clock() - b.last > 0.6 then beamOff(); return end -- the server went quiet: no beam left hanging
			b.to = b.to:Lerp(b.want, math.min(1, dt * 14))
			-- it leaves the gauntlet (his arm is animated on this client), or the server's start point
			local hand = b.model and b.model:FindFirstChild("RightHand")
			local a = (hand and hand:IsA("BasePart")) and hand.Position or b.from
			local len = (b.to - a).Magnitude
			if len < 0.5 then return end
			local cf = CFrame.lookAt(a, b.to) * CFrame.new(0, 0, -len / 2) * CFrame.Angles(0, math.pi / 2, 0)
			local pulse = 1 + math.sin(os.clock() * 40) * 0.12
			b.core.Size = Vector3.new(len, 1.3 * pulse, 1.3 * pulse); b.core.CFrame = cf
			b.glow.Size = Vector3.new(len, 3.4 * pulse, 3.4 * pulse); b.glow.CFrame = cf
			b.tip.CFrame = CFrame.new(b.to)
			Fx.shake(0.18 * near(b.to, 45) + 0.06 * near(a, 60))
			if os.clock() >= b.nextZap then
				b.nextZap = os.clock() + 0.35
				Sfx.at("TaserZap", a, { PlaybackSpeed = 0.45, Volume = 1.1 })
				Sfx.at("TaserZap", b.to, { PlaybackSpeed = 0.3, Volume = 0.8 })
			end
		end)
		beam = b
	end
	local b = beam :: any
	b.model = model; b.from = from; b.want = to; b.last = os.clock()
end
local lastLaserHit = 0

-- the Void Knight ------------------------------------------------------------------------------------------
local FORCE = Color3.fromRGB(210, 30, 40) -- his rings of force
local SABER = Color3.fromRGB(255, 40, 30)
local MOLTEN = Color3.fromRGB(255, 150, 40)
-- HIS BLADE'S SOUND: a hum that never stops, on the blade itself (so it comes closer with him). It ignites when he
-- appears (the pitch runs up from nothing); every swing bends the pitch up and back down, like the blade passing
-- your ear; where it goes through a wall the hum screams for a moment at the cut.
local HUM_PITCH, HUM_VOLUME = 1.0, 0.55
local bladeHum: Sound? = nil
local function hum(): Sound?
	if bladeHum and not bladeHum.Parent then bladeHum = nil end
	return bladeHum
end
local function bladeIgnite(g: Instance)
	if g.Name ~= "Ghost" or not g:IsA("Model") then return end
	task.spawn(function()
		local blade = g:WaitForChild("Blade", 6)
		if not blade or g:GetAttribute("MonsterId") ~= "Knight" or not g.Parent then return end
		local s = Sfx.on("SaberHum", blade, { Volume = 0, PlaybackSpeed = 0.3 })
		if not s then return end
		s.RollOffMode = Enum.RollOffMode.InverseTapered
		s.RollOffMinDistance = 9; s.RollOffMaxDistance = 120
		bladeHum = s
		TweenService:Create(s, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { PlaybackSpeed = HUM_PITCH, Volume = HUM_VOLUME }):Play()
		-- HIS BREATHING (Client/MaskBreath): a deep inhale, a pause, a deep exhale, on his head all fight long. It
		-- starts once his entrance (which has its own breath) is over. Loud on purpose: full strength within 25 studs,
		-- still heard across the house (140)
		local head = g:FindFirstChild("Head")
		if head then
			local et = g:GetAttribute("EntranceTime")
			task.delay(type(et) == "number" and et > 0 and et + 1 or 0, function()
				if g.Parent and head.Parent then MaskBreath.start(head, 2, { rollMin = 25, rollMax = 140 }) end
			end)
		end
	end)
end
-- the pitch bend of a swing: up fast, back down slower
local function bladeSwoosh(peak: number, loud: number)
	local s = hum()
	if not s then return end
	TweenService:Create(s, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { PlaybackSpeed = HUM_PITCH * peak, Volume = HUM_VOLUME * loud }):Play()
	task.delay(0.13, function()
		if s.Parent then TweenService:Create(s, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { PlaybackSpeed = HUM_PITCH, Volume = HUM_VOLUME }):Play() end
	end)
end
-- a flat ring (a thin disc) whose face looks along `axis`
local function ringCF(pos: Vector3, axis: Vector3): CFrame
	local up = math.abs(axis.Y) > 0.95 and Vector3.xAxis or Vector3.yAxis
	return CFrame.lookAt(pos, pos + axis, up) * CFrame.Angles(0, math.pi / 2, 0)
end
local function forceRing(pos: Vector3, axis: Vector3, diameter: number, transparency: number): BasePart
	return part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, diameter, diameter), Color = FORCE, Transparency = transparency, CFrame = ringCF(pos, axis) })
end
-- the blade went through a wall here: glowing cuts across the hole, sparks, the hiss of hot metal
local function saberCut(pos: Vector3, dir: Vector3)
	local flatDir = Vector3.new(dir.X, 0, dir.Z)
	flatDir = flatDir.Magnitude > 0.1 and flatDir.Unit or Vector3.new(0, 0, -1)
	local face = CFrame.lookAt(pos + Vector3.new(0, 2.5, 0), pos + Vector3.new(0, 2.5, 0) + flatDir)
	for i, ang in { 0.5, -0.7, 1.35 } do
		local c = part({ Size = Vector3.new(0.3, 11 - i * 1.5, 0.3), Color = i == 1 and SABER or MOLTEN, Transparency = 0.05,
			CFrame = face * CFrame.Angles(0, 0, ang) })
		TweenService:Create(c, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1, Size = Vector3.new(0.06, 11 - i * 1.5, 0.06) }):Play()
		Debris:AddItem(c, 1.15)
	end
	emitter(pos + Vector3.new(0, 2.5, 0), { Color = ColorSequence.new(MOLTEN), LightEmission = 1, Size = NumberSequence.new(0.5, 0), Speed = NumberRange.new(18, 40),
		Acceleration = Vector3.new(0, -60, 0), Lifetime = NumberRange.new(0.3, 0.7), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 46, 1.2)
	-- the hum screams at the cut for a moment (a second voice of it, high and falling), and the blade's own bends
	local scream = Sfx.at("SaberHum", pos, { PlaybackSpeed = 2.6, Volume = 1.5 })
	if scream then
		TweenService:Create(scream, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { PlaybackSpeed = 1.3, Volume = 0 }):Play()
		task.delay(0.6, function() scream:Stop() end)
	end
	Sfx.at("Breaker", pos, { PlaybackSpeed = 1.5, Volume = 0.45 })
	bladeSwoosh(1.5, 1.6)
end

function MonsterFx.handle(kind: string, ...)
	local a = { ... }
	if kind == "RoarWind" then
		-- about to roar: red light sucked in, a deep growl. A charged hit now cancels it.
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(FURY), LightEmission = 1, Size = NumberSequence.new(2.6, 0), Speed = NumberRange.new(-22, -12),
			Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, Lifetime = NumberRange.new(0.5, 0.65),
			Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 70, 1.5)
		local ring = disc(pos - Vector3.new(0, 2.8, 0), 17, FURY, 0.75)
		TweenService:Create(ring, TweenInfo.new(0.65, Enum.EasingStyle.Linear), { Transparency = 0.45 }):Play()
		Debris:AddItem(ring, 0.7)
		Sfx.at(Sfx.voice("WindUp"), pos, { PlaybackSpeed = 0.6, Volume = 1.6 })
		local f = near(pos, 40)
		Fx.shake(0.25 * f)
		if f > 0 then HUD.toast("IT'S ABOUT TO ROAR - BACK OFF OR CHARGE A HIT!", false) end
	elseif kind == "Roar" then
		local pos, r = a[1], a[2]
		Sfx.at(Sfx.voice("Spawn"), pos, { PlaybackSpeed = 0.75, Volume = 2 })
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.45, Volume = 1.6 })
		local ring = part({ Shape = Enum.PartType.Cylinder, Color = FURY, Transparency = 0.2,
			Size = Vector3.new(0.5, 4, 4), CFrame = CFrame.new(pos - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(ring, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.5, r * 2.2, r * 2.2), Transparency = 1 }):Play()
		Debris:AddItem(ring, 0.5)
		emitter(pos - Vector3.new(0, 2.5, 0), { Color = ColorSequence.new(Color3.fromRGB(120, 100, 90)), Size = NumberSequence.new(3, 6),
			Transparency = NumberSequence.new(0.4, 1), Speed = NumberRange.new(30, 45), Lifetime = NumberRange.new(0.5, 0.9),
			SpreadAngle = Vector2.new(180, 10), Drag = 4 }, 40, 1.5)
		local f = near(pos, r + 25)
		Fx.shake(1.0 * f + 0.1)
		Fx.kick(-16 * f)
		if f > 0 then HUD.flash(FURY, 0.4 * f) end
	elseif kind == "LungeWind" then
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(255, 120, 40)), LightEmission = 1, Size = NumberSequence.new(1.6, 0), Speed = NumberRange.new(-12, -6),
			Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, Lifetime = NumberRange.new(0.35, 0.5),
			Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 30, 1.2)
		Sfx.at(Sfx.voice("WindUp"), pos, { PlaybackSpeed = 1.25, Volume = 1.2 })
	elseif kind == "CounterWind" then
		-- it swipes back through your punches: a red flash on it and a snarl (block or back off)
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(FURY), LightEmission = 1, Size = NumberSequence.new(1.4, 0), Speed = NumberRange.new(8, 16),
			Lifetime = NumberRange.new(0.2, 0.35), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 26, 1)
		Sfx.at(Sfx.voice("WindUp"), pos, { PlaybackSpeed = 1.4, Volume = 1.3 })
		if near(pos, 25) > 0 then HUD.toast("IT'S HITTING BACK - BLOCK OR CHARGE A HIT!", false) end
	elseif kind == "SnapWind" then
		-- the Golden Bear raises his hand: gold light gathers on it
		local model = a[1]
		local hand = typeof(model) == "Instance" and (model:FindFirstChild("RightHand") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if hand then
			emitter(hand.Position, { Color = ColorSequence.new(GOLD), LightEmission = 1, Size = NumberSequence.new(1.6, 0), Speed = NumberRange.new(-14, -8),
				Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, Lifetime = NumberRange.new(0.4, 0.6),
				Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 40, 1.5)
			Sfx.at(Sfx.voice("WindUp"), hand.Position, { PlaybackSpeed = 0.8, Volume = 1.3 })
		end
		HUD.toast("HE'S GOING TO SNAP HIS FINGERS - GET BEHIND A WALL OR BLOCK!", false)
	elseif kind == "Snap" then
		local model, pos, mode = a[1], a[2], a[3]
		local hand = typeof(model) == "Instance" and (model:FindFirstChild("RightHand") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if hand then
			-- THE SNAP: a clear finger snap everyone in the house hears (loud and dry, with a soft echo behind it)
			Sfx.play("FingerSnap", { Volume = 3 })
			task.delay(0.16, function() Sfx.play("FingerSnap", { Volume = 0.9, PlaybackSpeed = 0.8 }) end)
			Sfx.at("Breaker", hand.Position, { PlaybackSpeed = 1.9, Volume = 0.5 })
			emitter(hand.Position, { Color = ColorSequence.new(GOLD), LightEmission = 1, Size = NumberSequence.new(0.8, 0), Speed = NumberRange.new(18, 30),
				Lifetime = NumberRange.new(0.15, 0.3), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 24, 0.8)
		end
		if mode == "miss" then
			HUD.toast("THE SNAP MISSED - HE COULDN'T SEE YOU", true)
		elseif typeof(pos) == "Vector3" then
			emitter(pos, { Color = ColorSequence.new(GOLD), LightEmission = 1, Size = NumberSequence.new(2.2, 0), Speed = NumberRange.new(20, 40),
				Lifetime = NumberRange.new(0.2, 0.45), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 40, 1)
			Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.5, Volume = 1.6 })
			Fx.shake(0.6 * near(pos, 50))
		end
	elseif kind == "TitanEat" then
		local model, what = a[1], a[2]
		local head = typeof(model) == "Instance" and (model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if head then
			Sfx.at(Sfx.voice("WindUp"), head.Position, { PlaybackSpeed = 0.7, Volume = 1.4 })
			Sfx.at("WoodBreak", head.Position, { PlaybackSpeed = 0.6, Volume = 1.2 })
		end
		HUD.toast(what == "wall" and "HE'S EATING THE WALL TO HEAL - HIT HIM!" or "HE'S EATING THE FURNITURE TO HEAL - HIT HIM!", false)
	elseif kind == "TitanHeal" then
		local model, amount = a[1], a[2]
		local torso = typeof(model) == "Instance" and (model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if torso then
			emitter(torso.Position, { Color = ColorSequence.new(Color3.fromRGB(120, 255, 120)), LightEmission = 1, Size = NumberSequence.new(1.8, 0),
				Speed = NumberRange.new(4, 10), Acceleration = Vector3.new(0, 12, 0), Lifetime = NumberRange.new(0.6, 1.1),
				Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 50, 2)
			Sfx.at("Crash", torso.Position, { PlaybackSpeed = 0.6, Volume = 1.2 })
			Sfx.at("Ultimate", torso.Position, { PlaybackSpeed = 0.7, Volume = 0.8 })
		end
		HUD.toast("HE HEALED +" .. tostring(math.floor(tonumber(amount) or 0)), false)
	elseif kind == "FurySmash" then
		-- the enraged smash punch: a huge crack, red burst, everyone near feels it
		local pos = a[1]
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.4, Volume = 2 })
		Sfx.at("Crash", pos, { PlaybackSpeed = 0.8, Volume = 1.2 })
		emitter(pos, { Color = ColorSequence.new(FURY, Color3.fromRGB(255, 200, 120)), LightEmission = 1, Size = NumberSequence.new(1.8, 0),
			Speed = NumberRange.new(25, 45), Lifetime = NumberRange.new(0.2, 0.4), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 40, 1)
		local f = near(pos, 50)
		Fx.shake(0.9 * f)
		Fx.kick(-12 * f)
	elseif kind == "FuryArmor" then
		-- a punch that didn't stagger it: a dull clank of sparks
		emitter(a[1], { Color = ColorSequence.new(Color3.fromRGB(255, 120, 60)), LightEmission = 1, Size = NumberSequence.new(0.5, 0),
			Speed = NumberRange.new(10, 20), Lifetime = NumberRange.new(0.1, 0.25), SpreadAngle = Vector2.new(60, 60),
			Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 10, 0.5)
	elseif kind == "Lunge" then
		Sfx.at("Whoosh", a[1], { PlaybackSpeed = 0.7, Volume = 1.4 })
	elseif kind == "Enraged" then
		local model, title = a[1], a[2]
		enrage(model)
		HUD.banner(tostring(title or "IT") .. " IS ENRAGED", "FASTER - HITS HARDER - ROARS MORE", 3)
		Sfx.play(Sfx.voice("Spawn"), { PlaybackSpeed = 0.7, Volume = 1.4 })
		Fx.shake(0.5)
	elseif kind == "AbilityWind" then
		local pos, k = a[1], a[2]
		local col = k == "wail" and Color3.fromRGB(160, 230, 240) or (k == "charge" and Color3.fromRGB(220, 220, 240) or (k == "steal" and GOBLIN or Color3.fromRGB(255, 70, 40)))
		emitter(pos, { Color = ColorSequence.new(col), LightEmission = 1, Size = NumberSequence.new(2, 0), Speed = NumberRange.new(-14, -8),
			Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, Lifetime = NumberRange.new(0.4, 0.6),
			Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 40, 1.5)
		local own = Sfx.voice("WindUp")
		Sfx.at(k == "wail" and "GhostWail" or (own == "GhostWail" and "GhostHurt" or own), pos, { PlaybackSpeed = k == "wail" and 0.8 or (own == "GhostWail" and 0.6 or 1), Volume = 1.2 })
		Fx.shake(0.15 * near(pos, 60))
	elseif kind == "TitanGrabWind" then
		-- the Giant is about to grab: his hands glow red and a red ring on the floor shows how far he reaches
		local model, radius, dur = a[1], a[2], a[3]
		if typeof(model) ~= "Instance" or not model.Parent then return end
		local root = model:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root then return end
		local life = (tonumber(dur) or 1.15) + 0.15
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Exclude
		rp.FilterDescendantsInstances = { model, Players.LocalPlayer.Character :: Instance }
		local down = workspace:Raycast(root.Position, Vector3.new(0, -40, 0), rp)
		local floorY = down and down.Position.Y or root.Position.Y - 4
		local c = Vector3.new(root.Position.X, floorY + 0.12, root.Position.Z)
		local ring = Instance.new("Model"); ring.Name = "GrabRing"; ring.Parent = workspace
		local n = 28
		local r = tonumber(radius) or 18
		local segLen = 2 * math.pi * r / n * 0.82
		local segs = {}
		for i = 1, n do
			local ang = (i / n) * math.pi * 2
			local at = c + Vector3.new(math.cos(ang) * r, 0, math.sin(ang) * r)
			local seg = Instance.new("Part")
			seg.Anchored = true; seg.CanCollide = false; seg.CanQuery = false; seg.CanTouch = false; seg.CastShadow = false
			seg.Material = Enum.Material.Neon; seg.Color = Color3.fromRGB(255, 40, 30); seg.Transparency = 0.25
			seg.Size = Vector3.new(segLen, 0.12, 0.5)
			seg.CFrame = CFrame.lookAt(at, c) * CFrame.Angles(0, math.pi / 2, 0)
			seg.Parent = ring
			table.insert(segs, seg)
		end
		local glow = {}
		for _, h in { "RightHand", "LeftHand" } do
			local hand = model:FindFirstChild(h) :: BasePart?
			if hand then
				local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 50, 30); l.Range = 10; l.Brightness = 3; l.Parent = hand
				local pe = Instance.new("ParticleEmitter")
				pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"; pe.Color = ColorSequence.new(Color3.fromRGB(255, 70, 40))
				pe.LightEmission = 1; pe.Size = NumberSequence.new(0.9, 0); pe.Lifetime = NumberRange.new(0.25, 0.5); pe.Rate = 40
				pe.Speed = NumberRange.new(1, 3); pe.SpreadAngle = Vector2.new(180, 180); pe.Parent = hand
				table.insert(glow, l); table.insert(glow, pe)
			end
		end
		Sfx.at("DemonGrowl", root.Position, { PlaybackSpeed = 0.7, Volume = 1.4 })
		-- the ring pulses faster as the grab comes, and goes the moment he grabs (or the wind-up is cut short)
		task.spawn(function()
			local t0 = os.clock()
			-- (the first moment the phase attributes may not have reached this client yet)
			local function winding() return model:GetAttribute("Ability") == "titanGrab" and model:GetAttribute("AbilityPhase") == "wind" end
			-- (Studio photo hook: DebugFreezeGhost keeps it up as long as the monster is held)
			local function held() return game:GetService("RunService"):IsStudio() and game:GetService("ReplicatedStorage"):GetAttribute("DebugFreezeGhost") == true end
			while (os.clock() - t0 < life + 2 or held()) and ring.Parent and model.Parent and (os.clock() - t0 < 0.4 or winding()) do
				local f = math.min(1, (os.clock() - t0) / life)
				local pulse = 0.5 + 0.5 * math.sin((os.clock() - t0) * (8 + 18 * f))
				for _, seg in segs do seg.Transparency = 0.1 + 0.45 * pulse * (1 - f) end
				task.wait()
			end
			ring:Destroy()
			for _, gl in glow do gl:Destroy() end
		end)
	elseif kind == "ShieldBlock" then
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(255, 230, 150)), LightEmission = 1, Size = NumberSequence.new(0.6, 0),
			Speed = NumberRange.new(14, 28), Lifetime = NumberRange.new(0.15, 0.35), SpreadAngle = Vector2.new(70, 70),
			Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 24, 0.6)
		Sfx.at("ShieldBlock", pos, { Volume = 1 })
		if near(pos, 30) > 0 then HUD.toast("BLOCKED!") end
	elseif kind == "Slammed" then
		-- the Pirate threw you into a wall
		HUD.flash(Color3.fromRGB(120, 0, 0), 0.7)
		Fx.shake(1.1)
		Sfx.play("PunchHeavy", { PlaybackSpeed = 0.55, Volume = 1.3 })
	elseif kind == "GoblinSteal" then
		-- the Goblin snatches an item: green + gold burst, a cackle
		local pos, victim = a[1], a[2]
		emitter(pos, { Color = ColorSequence.new(GOBLIN, GOLD), LightEmission = 1, Size = NumberSequence.new(1.2, 0), Speed = NumberRange.new(8, 20),
			Lifetime = NumberRange.new(0.4, 0.8), SpreadAngle = Vector2.new(180, 180), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 50, 1.5)
		Sfx.at("GoblinCackle", pos, { Volume = 1.3 })
		Sfx.at("Whoosh", pos, { PlaybackSpeed = 1.3 })
		if victim == lp then
			HUD.flash(Color3.fromRGB(60, 150, 30), 0.45)
			Fx.shake(0.35)
		end
	elseif kind == "GoblinUse" then
		-- he swings / fires / throws / sprays the stolen item
		local model, id, how, t = a[1], a[2], a[3], a[4]
		if typeof(model) ~= "Instance" then return end
		local handPart = model:FindFirstChild("RightHand") :: BasePart?
		local loot = model:FindFirstChild("Loot")
		local tip = loot and loot:FindFirstChild("Tip", true) :: BasePart?
		local pos = (tip or handPart or model:FindFirstChild("HumanoidRootPart") :: BasePart).Position
		local it = Items.byId[id or ""]
		local sfx = it and it.sfx
		if how == "stop" then
			if sprayPE then sprayPE:Destroy(); sprayPE = nil end
		elseif how == "spray" and it then
			if sprayPE then sprayPE:Destroy() end
			local at = (tip or handPart) :: BasePart?
			if at then
				local pe = Instance.new("ParticleEmitter")
				pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
				pe.Color = ColorSequence.new(it.particle or Color3.fromRGB(220, 220, 220))
				pe.EmissionDirection = Enum.NormalId.Front
				pe.Speed = NumberRange.new(40, 55); pe.SpreadAngle = Vector2.new(14, 14)
				pe.Size = NumberSequence.new(0.6, 3.5); pe.Lifetime = NumberRange.new(0.35, 0.5)
				pe.Transparency = NumberSequence.new(0.3, 1); pe.Rate = 90
				pe.LightEmission = it.fx and it.fx.burn and 0.8 or 0.1
				pe.Parent = at
				sprayPE = pe
				Debris:AddItem(pe, t or 1.6)
			end
			Sfx.at("Whoosh", pos, { PlaybackSpeed = 0.6, Volume = 1 })
		elseif how == "hit" then
			Sfx.at(sfx and sfx.hit or "PunchHeavy", pos, { PlaybackSpeed = sfx and sfx.speed or 0.8, Volume = 1.1 })
		else -- swing / throw
			Sfx.at(sfx and sfx.use or "Whoosh", pos, { PlaybackSpeed = sfx and sfx.speed or 0.8, Volume = 1 })
		end
	elseif kind == "GoblinDrop" then
		-- he lets go of a stolen item (knocked out) or it breaks in his hands
		local pos, _, broke = a[1], a[2], a[3]
		emitter(pos, { Color = ColorSequence.new(broke and Color3.fromRGB(140, 130, 120) or GOLD), LightEmission = broke and 0 or 1,
			Size = NumberSequence.new(0.9, 0), Speed = NumberRange.new(10, 22), Lifetime = NumberRange.new(0.3, 0.7),
			SpreadAngle = Vector2.new(180, 180), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 30, 1.2)
		Sfx.at(broke and "WoodBreak" or "Cash", pos, { Volume = 0.9 })
	elseif kind == "AbilityHit" then
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(140, 10, 10)), Size = NumberSequence.new(0.8, 1.6), Speed = NumberRange.new(10, 25),
			Lifetime = NumberRange.new(0.4, 0.9), Drag = 3 }, 26, 2)
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.6, Volume = 1.2 })
	elseif kind == "Grabbed" then
		local hand, t = a[1], a[2]
		local ch = lp.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hrp and hum and typeof(hand) == "Instance" and hand:IsA("BasePart") then
			release()
			hum.PlatformStand = true
			HUD.flash(Color3.fromRGB(120, 0, 0), 0.6)
			HUD.toast("GRABBED!")
			Sfx.play("GhostScream", { Volume = 0.8, PlaybackSpeed = 0.7 })
			local untilT = os.clock() + (t or 0.9) + 0.25 -- the server's throw (Fling) ends it sooner
			-- The fist can be up through a ceiling or a wall (the Flayed Giant is taller than the upstairs rooms):
			-- the held player stays inside the room the monster stands in, or the throw would start in the roof.
			local monster = hand:FindFirstAncestorOfClass("Model")
			local root = monster and monster:FindFirstChild("HumanoidRootPart") :: BasePart?
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Include
			local function inRoom(cf: CFrame): CFrame
				local mansion = workspace:FindFirstChild("Mansion")
				local st = mansion and mansion:FindFirstChild("Structure")
				if not root or not st then return cf end
				rp.FilterDescendantsInstances = { st }
				local from = root.Position
				local pos = cf.Position
				-- under the ceiling above the monster's own body...
				local up = workspace:Raycast(from, Vector3.new(0, 60, 0), rp)
				if up and pos.Y > up.Position.Y - 3.4 then pos = Vector3.new(pos.X, math.max(from.Y, up.Position.Y - 3.4), pos.Z) end
				-- ...and on its side of the walls
				local to = Vector3.new(pos.X - from.X, 0, pos.Z - from.Z)
				if to.Magnitude > 0.5 then
					local wall = workspace:Raycast(Vector3.new(from.X, pos.Y, from.Z), to.Unit * (to.Magnitude + 2), rp)
					if wall then
						local d = math.max(0, wall.Distance - 2)
						pos = Vector3.new(from.X + to.Unit.X * d, pos.Y, from.Z + to.Unit.Z * d)
					end
				end
				return cf.Rotation + pos
			end
			holdConn = RunService.RenderStepped:Connect(function()
				if os.clock() > untilT or not hand.Parent or not hrp.Parent then release(); return end
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.CFrame = inRoom(hand.CFrame * CFrame.new(0, -1.2, -1.6) * CFrame.Angles(0, math.pi, 0))
				Fx.shake(0.05)
			end)
		end
	elseif kind == "Released" then
		release()
	elseif kind == "Pounce" then
		Sfx.at("GhostScream", a[1], { PlaybackSpeed = 1.4, Volume = 1 })
	elseif kind == "Wail" then
		local pos, r = a[1], a[2]
		Sfx.at("GhostWail", pos, { PlaybackSpeed = 1.2, Volume = 2 })
		Sfx.at("GhostScream", pos, { PlaybackSpeed = 0.7, Volume = 1.5 })
		local ring = part({ Shape = Enum.PartType.Cylinder, Color = Color3.fromRGB(180, 240, 255), Transparency = 0.3,
			Size = Vector3.new(0.4, 4, 4), CFrame = CFrame.new(pos - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.4, r * 2, r * 2), Transparency = 1 }):Play()
		Debris:AddItem(ring, 0.6)
		local f = near(pos, r + 20)
		Fx.shake(0.9 * f + 0.1)
		Fx.kick(-14 * f)
		if f > 0 then HUD.flash(Color3.fromRGB(200, 240, 255), 0.35 * f) end
	elseif kind == "Blackout" then
		blackout(true, a[1], a[2])
	elseif kind == "AnimJumpscare" then
		jumpscare(a[1])
	elseif kind == "BlackoutEnd" then
		blackout(false)
	elseif kind == "GasThrow" then
		local from, to, t = a[1], a[2], a[3] or 0.6
		local flask = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 0.9, Color = Color3.fromRGB(120, 200, 60), Material = Enum.Material.Glass, Transparency = 0.2 })
		local start = os.clock()
		local conn
		conn = RunService.RenderStepped:Connect(function()
			local k = math.min(1, (os.clock() - start) / t)
			flask.Position = from:Lerp(to, k) + Vector3.new(0, math.sin(k * math.pi) * 8, 0)
			if k >= 1 then conn:Disconnect(); flask:Destroy() end
		end)
	elseif kind == "GasCloud" then
		local pos, r, t = a[1], a[2], a[3]
		Sfx.at("Glass", pos, { Volume = 1 })
		local d = disc(pos + Vector3.new(0, 0.2, 0), r, Color3.fromRGB(110, 180, 40), 0.75)
		task.delay(t, function() TweenService:Create(d, TweenInfo.new(0.6), { Transparency = 1 }):Play() end)
		Debris:AddItem(d, t + 0.7)
		local pe = emitter(pos + Vector3.new(0, 1.5, 0), { Color = ColorSequence.new(Color3.fromRGB(120, 190, 50), Color3.fromRGB(70, 110, 30)),
			Size = NumberSequence.new(5, 9), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.55), NumberSequenceKeypoint.new(1, 1) }),
			Speed = NumberRange.new(1, 3), Lifetime = NumberRange.new(2, 3), Rate = 14, Shape = Enum.ParticleEmitterShape.Cylinder,
			ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume, RotSpeed = NumberRange.new(-20, 20) }, nil, t + 3)
		;(pe.Parent :: Attachment).Parent = workspace.Terrain
		task.delay(t, function() pe.Enabled = false end)
	elseif kind == "Gassed" then
		gassed()
	elseif kind == "HellMark" then
		local pts, r, delay = a[1], a[2], a[3]
		for _, pt in pts do
			local d = disc(pt + Vector3.new(0, 0.15, 0), r, Color3.fromRGB(255, 80, 20), 0.6)
			TweenService:Create(d, TweenInfo.new(delay, Enum.EasingStyle.Linear), { Transparency = 0.15, Color = Color3.fromRGB(255, 200, 60) }):Play()
			Debris:AddItem(d, delay + 0.1)
			Sfx.at("Whoosh", pt, { PlaybackSpeed = 0.5, Volume = 1 })
		end
	elseif kind == "RatDashWarn" then
		-- the line he is about to charge down (feet, direction, length, seconds of warning)
		local feet, dir, len, t = a[1], a[2], a[3], a[4]
		local mid = feet + dir * (len / 2 + 2) + Vector3.new(0, 0.12, 0)
		local lane = part({ Size = Vector3.new(7.5, 0.1, len), CFrame = CFrame.lookAt(mid, mid + dir), Color = Color3.fromRGB(255, 40, 30), Transparency = 1 })
		TweenService:Create(lane, TweenInfo.new(t * 0.4), { Transparency = 0.55 }):Play()
		task.delay(t, function() TweenService:Create(lane, TweenInfo.new(0.35), { Transparency = 1 }):Play() end)
		Debris:AddItem(lane, t + 0.5)
		emitter(feet + Vector3.new(0, 0.4, 0), { Color = ColorSequence.new(Color3.fromRGB(120, 104, 88)), Size = NumberSequence.new(1.5, 4), Transparency = NumberSequence.new(0.4, 1),
			Lifetime = NumberRange.new(0.5, 0.9), Speed = NumberRange.new(6, 14), SpreadAngle = Vector2.new(40, 40), Rate = 26 }, nil, t)
		if near(feet, 70) > 0 then HUD.toast("IT'S GOING TO CHARGE - GET OUT OF THE RED LINE!", false) end
	elseif kind == "RatDash" then
		local model, t = a[1], a[2]
		local root = typeof(model) == "Instance" and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		Sfx.play("Whoosh", { PlaybackSpeed = 0.6, Volume = 1.2 })
		if root then
			Sfx.at("RatSqueal", root.Position, { Volume = 1.4 })
			local dust = Instance.new("ParticleEmitter")
			dust.Texture = "rbxasset://textures/particles/smoke_main.dds"
			dust.Color = ColorSequence.new(Color3.fromRGB(130, 116, 100)); dust.Size = NumberSequence.new(2.5, 6); dust.Transparency = NumberSequence.new(0.45, 1)
			dust.Lifetime = NumberRange.new(0.5, 1); dust.Speed = NumberRange.new(2, 8); dust.SpreadAngle = Vector2.new(180, 180); dust.Rate = 60
			dust.Parent = root
			task.delay(t, function() dust.Enabled = false; Debris:AddItem(dust, 1.2) end)
		end
		Fx.shake(0.35)
	elseif kind == "RatDizzy" then
		-- he has hit something too hard: stars round his head, and he can be hit freely
		local model, t = a[1], a[2]
		local head = typeof(model) == "Instance" and model:FindFirstChild("Head") :: BasePart?
		if head then
			local stars = Instance.new("ParticleEmitter")
			stars.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			stars.Color = ColorSequence.new(Color3.fromRGB(255, 230, 90)); stars.LightEmission = 1; stars.Size = NumberSequence.new(0.7, 0.2)
			stars.Lifetime = NumberRange.new(0.5, 0.8); stars.Speed = NumberRange.new(3, 5); stars.SpreadAngle = Vector2.new(180, 180); stars.Rate = 22
			stars.Shape = Enum.ParticleEmitterShape.Sphere; stars.Parent = head
			task.delay(t, function() stars.Enabled = false; Debris:AddItem(stars, 1) end)
			if near(head.Position, 60) > 0 then HUD.toast("IT'S DIZZY - HIT IT NOW!", true) end
		end
	elseif kind == "RatDig" then
		-- digging himself into the floor: dirt flying, a mound
		local feet, t = a[1], a[2]
		for i = 0, 2 do task.delay(i * 0.22, function() Sfx.at("Dig", feet, { Volume = 1.4, PlaybackSpeed = 1.2 }) end) end
		emitter(feet + Vector3.new(0, 0.5, 0), { Color = ColorSequence.new(Color3.fromRGB(86, 66, 48)), Size = NumberSequence.new(1.2, 3.5), Transparency = NumberSequence.new(0.2, 1),
			Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(10, 24), SpreadAngle = Vector2.new(50, 50), EmissionDirection = Enum.NormalId.Top,
			Acceleration = Vector3.new(0, -40, 0), Rate = 70 }, nil, t)
		local mound = disc(feet + Vector3.new(0, 0.2, 0), 1, Color3.fromRGB(60, 46, 34), 0)
		mound.Material = Enum.Material.Slate
		TweenService:Create(mound, TweenInfo.new(t), { Size = Vector3.new(0.5, 9, 9) }):Play()
		task.delay(t + 3, function() TweenService:Create(mound, TweenInfo.new(1), { Transparency = 1 }):Play() end)
		Debris:AddItem(mound, t + 4.2)
		if near(feet, 70) > 0 then HUD.toast("IT'S DIGGING - KEEP MOVING!", false) end
	elseif kind == "RatTrail" then
		-- where he is, under the floor: a furrow of broken ground
		local pos = a[1]
		local lump = part({ Size = Vector3.new(rng:NextNumber(2, 3.2), 0.5, rng:NextNumber(2, 3.2)), Material = Enum.Material.Slate, Color = Color3.fromRGB(64, 50, 38),
			CFrame = CFrame.new(pos + Vector3.new(0, 0.1, 0)) * CFrame.Angles(rng:NextNumber(-0.2, 0.2), rng:NextNumber(0, 3), rng:NextNumber(-0.2, 0.2)) })
		TweenService:Create(lump, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1, Size = lump.Size * Vector3.new(1, 0.2, 1) }):Play()
		Debris:AddItem(lump, 1.7)
		emitter(pos + Vector3.new(0, 0.4, 0), { Color = ColorSequence.new(Color3.fromRGB(96, 78, 60)), Size = NumberSequence.new(1, 2.6), Transparency = NumberSequence.new(0.4, 1),
			Lifetime = NumberRange.new(0.3, 0.6), Speed = NumberRange.new(3, 8), EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(60, 60) }, 5, 1)
	elseif kind == "RatWarn" then
		-- the floor cracks under your feet: he comes up there in a moment
		local pos, r, t = a[1], a[2], a[3]
		local ring = disc(pos + Vector3.new(0, 0.15, 0), r, Color3.fromRGB(255, 50, 30), 1)
		TweenService:Create(ring, TweenInfo.new(t), { Transparency = 0.45 }):Play()
		Debris:AddItem(ring, t + 0.05)
		for i = 1, 7 do
			local an = i / 7 * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
			local dir = Vector3.new(math.cos(an), 0, math.sin(an))
			local len = rng:NextNumber(r * 0.6, r)
			local crack = part({ Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(8, 6, 6), Size = Vector3.new(0.35, 0.1, len),
				CFrame = CFrame.lookAt(pos + dir * len / 2 + Vector3.new(0, 0.2, 0), pos + dir * 40 + Vector3.new(0, 0.2, 0)) })
			Debris:AddItem(crack, t + 2.5)
		end
		Sfx.at("Crash", pos, { PlaybackSpeed = 0.5, Volume = 0.8 })
		Fx.shake(0.4 * near(pos, 40))
	elseif kind == "RatErupt" then
		local pos, r = a[1], a[2]
		Sfx.at("Explosion", pos, { Volume = 0.8, PlaybackSpeed = 1.1 })
		Sfx.at("RatSpawn", pos, { Volume = 1.4, PlaybackSpeed = 1.5 })
		local ring = disc(pos + Vector3.new(0, 0.2, 0), 2, Color3.fromRGB(140, 120, 100), 0.3)
		TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.15, r * 4, r * 4), Transparency = 1 }):Play()
		Debris:AddItem(ring, 0.55)
		emitter(pos + Vector3.new(0, 1, 0), { Color = ColorSequence.new(Color3.fromRGB(90, 70, 52)), Size = NumberSequence.new(2, 6), Transparency = NumberSequence.new(0.25, 1),
			Lifetime = NumberRange.new(0.6, 1.3), Speed = NumberRange.new(16, 40), SpreadAngle = Vector2.new(60, 60), EmissionDirection = Enum.NormalId.Top,
			Acceleration = Vector3.new(0, -40, 0) }, 70, 2)
		for _ = 1, Settings.fxCount(12) do
			local sz = rng:NextNumber(0.6, 1.6)
			local chunk = Instance.new("Part")
			chunk.Size = Vector3.new(sz, sz * 0.6, sz); chunk.Material = Enum.Material.Slate; chunk.Color = Color3.fromRGB(70, 56, 44)
			chunk.CanQuery = false; chunk.CanTouch = false; chunk.CollisionGroup = "Debris"
			chunk.CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-2, 2), 1, rng:NextNumber(-2, 2)))
			chunk.Parent = workspace.Terrain
			local an = rng:NextNumber(0, math.pi * 2)
			chunk.AssemblyLinearVelocity = Vector3.new(math.cos(an) * 22, rng:NextNumber(30, 55), math.sin(an) * 22)
			Debris:AddItem(chunk, 3)
		end
		Fx.shake(0.9 * near(pos, 50))
	elseif kind == "DemonSummon" then
		-- THE SUMMONING (Server/Abilities levitateThrow, phase "summon"): a burning circle with a five-pointed star
		-- is drawn on the floor at every spot, fire climbs out of it, and after `dur` seconds a pillar of fire leaves
		-- a piece of hell's furniture standing there.
		local spots, dur = a[1], a[2] or 1.7
		local RED, ORANGE = Color3.fromRGB(255, 40, 16), Color3.fromRGB(255, 130, 40)
		Sfx.play("FireLoop", { Volume = 0.9, PlaybackSpeed = 1.2 })
		for _, pt in spots do
			local R = 3.6
			local strokes = {} :: { BasePart }
			local pts = {}
			for i = 0, 4 do
				local an = i / 5 * math.pi * 2 + math.pi / 2
				table.insert(pts, pt + Vector3.new(math.cos(an) * R, 0.12, math.sin(an) * R))
			end
			for i = 1, 5 do
				local p1, p2 = pts[i], pts[(i + 1) % 5 + 1]
				table.insert(strokes, part({ Size = Vector3.new(0.28, 0.1, (p2 - p1).Magnitude), CFrame = CFrame.lookAt(p1:Lerp(p2, 0.5), p2), Color = RED, Transparency = 1 }))
			end
			for i = 1, 16 do
				local a0, a1 = (i - 1) / 16 * math.pi * 2, i / 16 * math.pi * 2
				local p1, p2 = pt + Vector3.new(math.cos(a0) * R, 0.12, math.sin(a0) * R), pt + Vector3.new(math.cos(a1) * R, 0.12, math.sin(a1) * R)
				table.insert(strokes, part({ Size = Vector3.new(0.32, 0.1, (p2 - p1).Magnitude + 0.1), CFrame = CFrame.lookAt(p1:Lerp(p2, 0.5), p2), Color = RED, Transparency = 1 }))
			end
			-- drawn stroke by stroke, gone a moment after the furniture has come
			for i, st in strokes do
				task.delay(i * 0.035, function() TweenService:Create(st, TweenInfo.new(0.12), { Transparency = 0.05 }):Play() end)
				task.delay(dur + 0.5, function() TweenService:Create(st, TweenInfo.new(0.6), { Transparency = 1 }):Play() end)
				Debris:AddItem(st, dur + 1.3)
			end
			local glowPart = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = pt + Vector3.new(0, 2, 0) })
			local l = Instance.new("PointLight"); l.Color = RED; l.Range = 26; l.Brightness = 0; l.Shadows = false; l.Parent = glowPart
			TweenService:Create(l, TweenInfo.new(dur), { Brightness = 3 }):Play()
			Debris:AddItem(glowPart, dur + 1.2)
			-- fire climbing out of the circle, harder and harder
			local fire = emitter(pt + Vector3.new(0, 0.3, 0), { Texture = "rbxasset://textures/particles/fire_main.dds", Color = ColorSequence.new(ORANGE, RED), LightEmission = 1,
				Size = NumberSequence.new(2.4, 0.3), Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(5, 12), SpreadAngle = Vector2.new(16, 16),
				EmissionDirection = Enum.NormalId.Top, Rate = 30 }, nil, dur + 1.5)
			emitter(pt + Vector3.new(0, 0.3, 0), { Color = ColorSequence.new(Color3.fromRGB(30, 10, 10)), Size = NumberSequence.new(2, 5), Transparency = NumberSequence.new(0.5, 1),
				Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(4, 9), SpreadAngle = Vector2.new(24, 24), EmissionDirection = Enum.NormalId.Top, Rate = 12 }, nil, dur + 0.2)
			task.delay(dur, function()
				fire.Enabled = false
				-- it arrives: a pillar of fire, a ring, embers
				local col = part({ Shape = Enum.PartType.Cylinder, Color = ORANGE, Transparency = 0.15, Size = Vector3.new(16, 5, 5), CFrame = CFrame.new(pt + Vector3.new(0, 8, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
				TweenService:Create(col, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1, Size = Vector3.new(20, 0.4, 0.4) }):Play()
				Debris:AddItem(col, 0.6)
				local ring = disc(pt + Vector3.new(0, 0.2, 0), 1.5, RED, 0.3)
				TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.15, 22, 22), Transparency = 1 }):Play()
				Debris:AddItem(ring, 0.55)
				emitter(pt + Vector3.new(0, 1.5, 0), { Color = ColorSequence.new(ORANGE), LightEmission = 1, Size = NumberSequence.new(0.6, 0), Speed = NumberRange.new(14, 30),
					Lifetime = NumberRange.new(0.5, 1.1), Acceleration = Vector3.new(0, -20, 0), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 50, 1.5)
				Sfx.at("Explosion", pt, { Volume = 0.6, PlaybackSpeed = 1.4 })
				Fx.shake(0.5 * near(pt, 50))
			end)
		end
		if near(spots[1] or Vector3.zero, 60) > 0 then HUD.toast("HE IS SUMMONING FURNITURE FROM HELL!", false) end
	elseif kind == "HellPillar" then
		local pts, r = a[1], a[2]
		for _, pt in pts do
			local col = part({ Shape = Enum.PartType.Cylinder, Color = Color3.fromRGB(255, 120, 30), Transparency = 0.1,
				Size = Vector3.new(30, r * 1.6, r * 1.6), CFrame = CFrame.new(pt + Vector3.new(0, 15, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
			TweenService:Create(col, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1, Size = Vector3.new(36, r * 0.4, r * 0.4) }):Play()
			Debris:AddItem(col, 1)
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 120, 40); l.Range = 30; l.Brightness = 4; l.Parent = col
			emitter(pt + Vector3.new(0, 2, 0), { Color = ColorSequence.new(Color3.fromRGB(255, 180, 60), Color3.fromRGB(120, 20, 0)), LightEmission = 0.8,
				Texture = "rbxasset://textures/particles/fire_main.dds", Size = NumberSequence.new(3, 0.5), Speed = NumberRange.new(20, 40),
				SpreadAngle = Vector2.new(20, 20), EmissionDirection = Enum.NormalId.Top, Lifetime = NumberRange.new(0.5, 1) }, 40, 2)
			Sfx.at("Explosion", pt, { Volume = 0.8, PlaybackSpeed = 1.2 })
			Fx.shake(0.5 * near(pt, 50))
		end
	elseif kind == "Charge" then
		local pos = a[1]
		Sfx.at("Whoosh", pos, { PlaybackSpeed = 0.4, Volume = 2 })
		Sfx.at("GhostScream", pos, { PlaybackSpeed = 0.5, Volume = 1.2 })
		Fx.shake(0.3 * near(pos, 60))
	elseif kind == "AmbushBreath" then
		-- the Caller, asleep in his corner: a slow breath you can only just hear, and only from close
		Sfx.at("GhostWhisper", a[1], { PlaybackSpeed = 0.8, Volume = 0.35, RollOffMaxDistance = 55 })
	elseif kind == "AmbushWake" then
		-- somebody looked at him: a sharp breath in, his knife scraping off the floor
		local pos = a[1]
		Sfx.at(Sfx.voice("WindUp"), pos, { PlaybackSpeed = 1.1, Volume = 1.3 })
		Sfx.at("GhostWhisper", pos, { PlaybackSpeed = 1.2, Volume = 0.9 })
		Fx.shake(0.25 * near(pos, 45))
	elseif kind == "AmbushStrike" then
		-- he comes out of his corner at you
		local model = a[1]
		local root = typeof(model) == "Instance" and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			Sfx.at("Jumpscare", root.Position, { Volume = 0.55, PlaybackSpeed = 1.2 })
			Sfx.at("PirateSwing", root.Position, { Volume = 1.6, PlaybackSpeed = 0.8 })
			Fx.shake(0.5 * near(root.Position, 40))
		end
	elseif kind == "AmbushStab" then
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(150, 10, 14)), Size = NumberSequence.new(0.5, 0.1), Speed = NumberRange.new(10, 26),
			Lifetime = NumberRange.new(0.3, 0.6), Acceleration = Vector3.new(0, -60, 0), SpreadAngle = Vector2.new(60, 60) }, 26, 1.5)
		Sfx.at("DemonHit", pos, { PlaybackSpeed = 1.3, Volume = 1.5 })
		Fx.shake(0.6 * near(pos, 30))
	elseif kind == "AmbushFound" then
		-- somebody found him first: he yelps, a white flash where he hid
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(255, 240, 200)), LightEmission = 1, Size = NumberSequence.new(2.4, 0), Speed = NumberRange.new(14, 30),
			Lifetime = NumberRange.new(0.2, 0.45), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 34, 1)
		Sfx.at(Sfx.voice("Hurt"), pos, { PlaybackSpeed = 1.25, Volume = 1.6 })
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.8, Volume = 1.3 })
	elseif kind == "ShotgunAim" then
		-- the Last Call brings the shotgun up: the pump, and a red line from the muzzle to where it points
		local model = a[1]
		local root = typeof(model) == "Instance" and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then Sfx.at("ShotgunPump", root.Position, { Volume = 1.8, PlaybackSpeed = 0.85 }) end
	elseif kind == "ShotgunPump" then
		local model = a[1]
		local root = typeof(model) == "Instance" and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then Sfx.at("ShotgunPump", root.Position, { Volume = 1.8 }) end
	elseif kind == "ShotgunFire" then
		local model, from, to, open = a[1], a[2], a[3], a[4]
		if typeof(from) ~= "Vector3" or typeof(to) ~= "Vector3" then return end
		-- it leaves the gun he is holding (his arm is animated on this client)
		local gun = typeof(model) == "Instance" and model:FindFirstChild("ShotgunMuzzle")
		local muzzle = (gun and gun:IsA("BasePart")) and gun.Position or from
		Sfx.at("ShotgunShot", muzzle, { Volume = 2.4, PlaybackSpeed = 0.9 })
		local flash = part({ Shape = Enum.PartType.Ball, Size = Vector3.new(3.5, 3.5, 3.5), Color = Color3.fromRGB(255, 210, 120), Transparency = 0.2, CFrame = CFrame.new(muzzle) })
		local fl = Instance.new("PointLight"); fl.Color = Color3.fromRGB(255, 200, 110); fl.Range = 40; fl.Brightness = 6; fl.Shadows = false; fl.Parent = flash
		Debris:AddItem(flash, 0.07)
		emitter(muzzle, { Color = ColorSequence.new(Color3.fromRGB(200, 200, 200)), Size = NumberSequence.new(1, 3.5), Transparency = NumberSequence.new(0.5, 1),
			Speed = NumberRange.new(3, 9), Lifetime = NumberRange.new(0.5, 1) }, 12, 1.5)
		-- pellet tracers in a narrow spread
		local dir = to - muzzle
		local len = dir.Magnitude
		if len > 1 then
			for _ = 1, 7 do
				local endP = to + Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)) * math.min(3.5, len * 0.07)
				local d = endP - muzzle
				local tr = part({ Size = Vector3.new(0.09, 0.09, d.Magnitude), Color = Color3.fromRGB(255, 230, 160), Transparency = 0.25,
					CFrame = CFrame.lookAt(muzzle, endP) * CFrame.new(0, 0, -d.Magnitude / 2) })
				TweenService:Create(tr, TweenInfo.new(0.14), { Transparency = 1 }):Play()
				Debris:AddItem(tr, 0.16)
			end
		end
		-- what it hit
		emitter(to, { Color = ColorSequence.new(open and Color3.fromRGB(150, 10, 14) or Color3.fromRGB(190, 170, 140)), Size = NumberSequence.new(0.6, 0.1), Speed = NumberRange.new(10, 28),
			Lifetime = NumberRange.new(0.25, 0.6), Acceleration = Vector3.new(0, -50, 0) }, 22, 1.2)
		Fx.shake(0.55 * near(muzzle, 60) + 0.3 * near(to, 25))
		if not open and near(to, 14) > 0 then HUD.toast("YOUR COVER TOOK THAT ONE - MOVE!", true) end
	elseif kind == "WarpWind" then
		-- the Conqueror tears a portal open in front of him
		local model = a[1]
		local root = typeof(model) == "Instance" and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			portal(root.Position + root.CFrame.LookVector * 5, root.CFrame.LookVector, (a[2] or 0.9) + 0.25)
			Sfx.at("Telekinesis", root.Position, { PlaybackSpeed = 0.6, Volume = 1.4 })
			Sfx.at(Sfx.voice("WindUp"), root.Position, { PlaybackSpeed = 0.7, Volume = 1.2 })
		end
	elseif kind == "Warp" then
		-- ...and steps out of another one, close to his victim
		local from, to = a[1], a[2]
		local cam = workspace.CurrentCamera
		portal(to, cam.CFrame.Position - to, 0.9)
		emitter(from, { Color = ColorSequence.new(PURPLE, Color3.fromRGB(20, 6, 30)), LightEmission = 0.6, Size = NumberSequence.new(3, 0),
			Speed = NumberRange.new(6, 16), Lifetime = NumberRange.new(0.3, 0.7) }, 30, 1.5)
		Sfx.at("Whoosh", to, { PlaybackSpeed = 0.4, Volume = 1.6 })
		Sfx.at("Breaker", to, { PlaybackSpeed = 0.7, Volume = 1.4 })
		Fx.shake(0.45 * near(to, 45))
		if near(to, 30) > 0 then HUD.toast("HE'S BEHIND YOU", false) end
	elseif kind == "LaserWind" then
		-- purple light gathers on the gauntlet
		local model = a[1]
		local hand = typeof(model) == "Instance" and (model:FindFirstChild("RightHand") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if hand then
			local pe = emitter(hand.Position, { Color = ColorSequence.new(PURPLE), LightEmission = 1, Size = NumberSequence.new(2.2, 0), Speed = NumberRange.new(-18, -10),
				Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, Lifetime = NumberRange.new(0.4, 0.6),
				Texture = "rbxasset://textures/particles/sparkles_main.dds", Rate = 80 }, nil, (a[2] or 1.5) + 0.5)
			pe.Enabled = true
			task.delay(a[2] or 1.5, function() pe.Enabled = false end)
			Sfx.at("Telekinesis", hand.Position, { PlaybackSpeed = 1.3, Volume = 1.6 })
			Sfx.at(Sfx.voice("Spawn"), hand.Position, { PlaybackSpeed = 0.75, Volume = 1.1 })
		end
	elseif kind == "LaserBeam" then
		if typeof(a[2]) == "Vector3" and typeof(a[3]) == "Vector3" then beamTo(typeof(a[1]) == "Instance" and a[1] or nil, a[2], a[3]) end
	elseif kind == "LaserEnd" then
		beamOff()
	elseif kind == "LaserHit" then
		-- standing in the beam
		if os.clock() - lastLaserHit > 0.3 then
			lastLaserHit = os.clock()
			HUD.flash(Color3.fromRGB(150, 40, 220), 0.45)
			Sfx.play("TaserZap", { PlaybackSpeed = 0.7, Volume = 0.8 })
			HUD.toast("YOU'RE IN THE BEAM - MOVE!", false)
		end
		Fx.shake(0.25)
	elseif kind == "BlackoutExtend" then
		-- the hunt goes on a little longer (the Party Bear found you again): the dark stays, no new banner
		blackoutId += 1
		local id = blackoutId
		task.delay((a[1] or 4) + 0.2, function() if id == blackoutId then blackout(false) end end)
	elseif kind == "StalkerBlink" then
		-- the Party Bear lost you in the dark and is suddenly close by: a low growl from where he stands now
		local from, to = a[1], a[2]
		for _, pos in { from, to } do
			emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(14, 12, 12)), Size = NumberSequence.new(3, 6), Transparency = NumberSequence.new(0.5, 1),
				Speed = NumberRange.new(1, 4), Lifetime = NumberRange.new(0.5, 0.9) }, 14, 1.5)
		end
		Sfx.at("AnimGrowl", to, { Volume = 1.3, PlaybackSpeed = 0.8 })
		Sfx.at("Whoosh", to, { Volume = 0.7, PlaybackSpeed = 0.5 })
	elseif kind == "CloneSpawn" and a[2] == "bone" then
		-- one of the Burning Captain's crew jumps out of him
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(255, 150, 50), Color3.fromRGB(120, 30, 0)), LightEmission = 0.8, Size = NumberSequence.new(1, 0),
			Speed = NumberRange.new(5, 12), Lifetime = NumberRange.new(0.25, 0.55), Texture = "rbxasset://textures/particles/fire_main.dds" }, 16, 1.5)
		Sfx.at("Bonk", pos, { PlaybackSpeed = 1.5 + rng:NextNumber(0, 0.4), Volume = 0.5 })
	elseif kind == "CloneShatter" and a[2] == "bone" then
		-- ...and falls to bits: a handful of bones
		local pos = a[1]
		for _ = 1, 7 do
			local sh = part({ Size = Vector3.new(rng:NextNumber(0.15, 0.3), rng:NextNumber(0.5, 1.1), rng:NextNumber(0.15, 0.3)), Color = Color3.fromRGB(226, 214, 186),
				Material = Enum.Material.SmoothPlastic, CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-0.6, 0.6), rng:NextNumber(-0.4, 0.8), rng:NextNumber(-0.6, 0.6))) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0) })
			sh.Anchored = false
			sh.AssemblyLinearVelocity = Vector3.new(rng:NextNumber(-12, 12), rng:NextNumber(6, 18), rng:NextNumber(-12, 12))
			sh.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-20, 20), rng:NextNumber(-20, 20), rng:NextNumber(-20, 20))
			Debris:AddItem(sh, 1.4)
		end
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(210, 200, 180)), Size = NumberSequence.new(1.2, 2.4), Transparency = NumberSequence.new(0.5, 1),
			Speed = NumberRange.new(2, 6), Lifetime = NumberRange.new(0.3, 0.6) }, 8, 1.2)
		Sfx.at("WoodBreak", pos, { PlaybackSpeed = 1.7 + rng:NextNumber(0, 0.3), Volume = 0.5 })
	elseif kind == "CloneSpawn" and a[2] == "balloon" then
		-- Pop the Clown's balloon copies: a squeak of air, a puff of confetti
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(255, 120, 140), Color3.fromRGB(120, 180, 255)), LightEmission = 0.4, Size = NumberSequence.new(0.35, 0.1),
			Speed = NumberRange.new(4, 9), Lifetime = NumberRange.new(0.4, 0.8), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 18, 1.2)
		Sfx.at("Whoosh", pos, { PlaybackSpeed = 2.2, Volume = 0.5 })
	elseif kind == "CloneShatter" and a[2] == "balloon" then
		-- ...it pops: confetti in every colour
		local pos = a[1]
		for _, col in { Color3.fromRGB(255, 80, 90), Color3.fromRGB(80, 160, 255), Color3.fromRGB(255, 220, 80), Color3.fromRGB(120, 230, 120) } do
			emitter(pos, { Color = ColorSequence.new(col), LightEmission = 0.3, Size = NumberSequence.new(0.3, 0.2), Speed = NumberRange.new(8, 20),
				Lifetime = NumberRange.new(0.6, 1.2), Acceleration = Vector3.new(0, -30, 0), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 10, 1.6)
		end
		Sfx.at("BalloonPop", pos, { Volume = 1.2, PlaybackSpeed = 0.9 + rng:NextNumber(0, 0.3) })
	elseif kind == "CloneSpawn" and a[2] == "mannequin" then
		-- the Ringmaster's mannequins get up: a creak, dust off them
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(200, 190, 170)), Size = NumberSequence.new(1, 2.5), Transparency = NumberSequence.new(0.5, 1),
			Speed = NumberRange.new(2, 5), Lifetime = NumberRange.new(0.5, 1) }, 10, 1.5)
		Sfx.at("DoorCreak", pos, { PlaybackSpeed = 1.5 + rng:NextNumber(0, 0.4), Volume = 0.7 })
	elseif kind == "CloneShatter" and a[2] == "mannequin" then
		-- ...and fall to plastic bits
		local pos = a[1]
		for _ = 1, 7 do
			local sh = part({ Size = Vector3.new(rng:NextNumber(0.3, 0.8), rng:NextNumber(0.6, 1.6), rng:NextNumber(0.3, 0.6)), Color = Color3.fromRGB(222, 214, 200),
				Material = Enum.Material.SmoothPlastic, CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-0.8, 0.8), rng:NextNumber(-1.5, 1.5), rng:NextNumber(-0.8, 0.8))) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0) })
			sh.Anchored = false
			sh.AssemblyLinearVelocity = Vector3.new(rng:NextNumber(-14, 14), rng:NextNumber(6, 18), rng:NextNumber(-14, 14))
			sh.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-15, 15), rng:NextNumber(-15, 15), rng:NextNumber(-15, 15))
			Debris:AddItem(sh, 1.6)
		end
		Sfx.at("WoodBreak", pos, { PlaybackSpeed = 1.4, Volume = 0.6 })
	elseif kind == "CloneSpawn" then
		local pos = a[1]
		emitter(pos, { Color = ColorSequence.new(Color3.fromRGB(230, 230, 255)), LightEmission = 1, Size = NumberSequence.new(1.5, 0),
			Speed = NumberRange.new(6, 14), Lifetime = NumberRange.new(0.3, 0.7), Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 30, 1.5)
		Sfx.at("Glass", pos, { PlaybackSpeed = 1.4 })
	elseif kind == "CloneShatter" then
		local pos = a[1]
		for _ = 1, 10 do
			local sh = part({ Size = Vector3.new(rng:NextNumber(0.3, 1.2), rng:NextNumber(0.6, 1.6), 0.1), Color = Color3.fromRGB(210, 220, 235),
				Material = Enum.Material.Glass, Transparency = 0.2, CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 2), rng:NextNumber(-1, 1))) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0) })
			sh.Anchored = false
			sh.AssemblyLinearVelocity = Vector3.new(rng:NextNumber(-20, 20), rng:NextNumber(5, 25), rng:NextNumber(-20, 20))
			Debris:AddItem(sh, 1.5)
		end
		Sfx.at("Glass", pos, { Volume = 1.2 })
	-- THE VOID KNIGHT (Server/Knight) --------------------------------------------------------------------
	-- His grip is made visible with RINGS OF FORCE: flat rings of dark red light, always facing along the line
	-- from his open hand to the player. They gather on his palm while he reaches (ForceWind), run from his hand to
	-- the player and circle them while he holds them in the air (ForceGrab), and burst outward when he throws
	-- (ForcePush).
	elseif kind == "ForceWind" then
		local model, victim, wind = a[1], a[2], a[3]
		local hand = typeof(model) == "Instance" and (model:FindFirstChild("LeftHand") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if hand then
			Sfx.at("Telekinesis", hand.Position, { PlaybackSpeed = 0.7, Volume = 1.6 })
			emitter(hand.Position, { Color = ColorSequence.new(FORCE), LightEmission = 1, Size = NumberSequence.new(1.4, 0), Speed = NumberRange.new(-16, -9),
				Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, Lifetime = NumberRange.new(0.35, 0.55) }, 36, 1.5)
			-- rings closing on his palm, one after another
			task.spawn(function()
				local t0 = os.clock()
				while os.clock() - t0 < (wind or 1) and hand.Parent do
					local look = hand.CFrame.LookVector
					local root = (model :: Instance):FindFirstChild("HumanoidRootPart") :: BasePart?
					if root then look = root.CFrame.LookVector end
					local r = forceRing(hand.Position + look * 1.2, look, 7, 0.55)
					TweenService:Create(r, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = Vector3.new(0.12, 0.6, 0.6), Transparency = 0.1 }):Play()
					Debris:AddItem(r, 0.34)
					task.wait(0.13)
				end
			end)
		end
		if victim == lp then HUD.toast("HE REACHES FOR YOU - GET BEHIND A WALL OR HIT HIM!", false) end
	elseif kind == "ForceGrab" then
		local model, victim, hold = a[1], a[2], a[3]
		local hand = typeof(model) == "Instance" and (model:FindFirstChild("LeftHand") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		local ch = typeof(victim) == "Instance" and victim:IsA("Player") and victim.Character or nil
		local body = ch and (ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if hand and body then
			Sfx.at("Telekinesis", body.Position, { PlaybackSpeed = 0.55, Volume = 2 })
			Sfx.at("GhostWhisper", body.Position, { PlaybackSpeed = 0.6, Volume = 1.2 })
			task.spawn(function()
				local t0 = os.clock()
				local n = 0
				while os.clock() - t0 < (hold or 0.9) and hand.Parent and body.Parent do
					n += 1
					local from, to = hand.Position, body.Position
					local dir = (to - from).Magnitude > 0.5 and (to - from).Unit or Vector3.new(0, 0, -1)
					-- a ring leaves his palm and runs to the player, growing
					local r = forceRing(from + dir * 1.5, dir, 1.4, 0.25)
					TweenService:Create(r, TweenInfo.new(0.3, Enum.EasingStyle.Linear), { CFrame = ringCF(to, dir), Size = Vector3.new(0.12, 5.5, 5.5), Transparency = 0.75 }):Play()
					Debris:AddItem(r, 0.32)
					-- and rings close round the player, one flat, one upright, turning
					if n % 2 == 1 then
						local axis = n % 4 == 1 and Vector3.yAxis or dir
						local c = forceRing(to, axis, 7.5, 0.7)
						TweenService:Create(c, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = Vector3.new(0.12, 3.2, 3.2), Transparency = 0.3 }):Play()
						Debris:AddItem(c, 0.32)
					end
					task.wait(0.085)
				end
			end)
		end
	elseif kind == "ForceHold" then
		-- (the victim only) lifted off the floor and held there until he throws
		local hold, lift = a[1], a[2]
		local ch = lp.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hrp and hum then
			release()
			hum.PlatformStand = true
			HUD.flash(Color3.fromRGB(90, 0, 10), 0.7)
			HUD.toast("HE HAS YOU IN HIS GRIP!")
			local base = hrp.CFrame
			local t0 = os.clock()
			local untilT = t0 + (hold or 0.9) + 0.3 -- the server's throw ends it sooner
			-- not up through the ceiling
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Include
			local mansion = workspace:FindFirstChild("Mansion")
			rp.FilterDescendantsInstances = { mansion and mansion:FindFirstChild("Structure") or workspace.Terrain }
			local up = workspace:Raycast(base.Position, Vector3.new(0, 40, 0), rp)
			local rise = math.min(lift or 7, up and math.max(0, up.Distance - 4) or 99)
			holdConn = RunService.RenderStepped:Connect(function()
				local now = os.clock()
				if now > untilT or not hrp.Parent then release(); return end
				local k = math.min(1, (now - t0) / 0.3)
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
				hrp.CFrame = base * CFrame.new(0, rise * (1 - (1 - k) ^ 2) + math.sin(now * 9) * 0.15, 0) * CFrame.Angles(-0.25 * k, 0, math.sin(now * 6) * 0.08)
				Fx.shake(0.06)
			end)
		end
	elseif kind == "ForcePush" then
		local model, pos, dir = a[1], a[2], a[3]
		local hand = typeof(model) == "Instance" and (model:FindFirstChild("LeftHand") or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
		if typeof(pos) == "Vector3" and typeof(dir) == "Vector3" then
			local from = hand and hand.Position or pos
			Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.45, Volume = 2 })
			Sfx.at("Whoosh", pos, { PlaybackSpeed = 0.6, Volume = 1.6 })
			-- a cone of rings blown out from his palm, through the player and on
			for i = 0, 5 do
				local r = forceRing(from + dir * (1.5 + i * 1.2), dir, 1.5 + i * 0.6, 0.15)
				local reach = 10 + i * 9
				TweenService:Create(r, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ CFrame = ringCF(from + dir * reach, dir), Size = Vector3.new(0.12, 7 + i * 3.5, 7 + i * 3.5), Transparency = 1 }):Play()
				Debris:AddItem(r, 0.45)
			end
			emitter(pos, { Color = ColorSequence.new(FORCE), LightEmission = 1, Size = NumberSequence.new(2.4, 0), Speed = NumberRange.new(30, 55),
				Lifetime = NumberRange.new(0.2, 0.4) }, 36, 1)
			Fx.shake(0.8 * near(pos, 60))
		end
	elseif kind == "ForceMiss" then
		local victim, broken = a[2], a[3]
		if victim == lp then HUD.toast(broken and "HIS GRIP BROKE!" or "HE LOST SIGHT OF YOU - THE GRIP MISSED", true) end
	elseif kind == "SaberSwing" then
		-- the red arc of his blade in front of him; where it met a wall, the cut glows (below)
		local model, cutAt, look = a[1], a[2], a[3]
		local root = typeof(model) == "Instance" and model:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			local cf = root.CFrame * CFrame.new(0, 1.2, 0)
			bladeSwoosh(1.9, 2.4)
			Sfx.at("SaberSwish", cf.Position, { PlaybackSpeed = 0.6, Volume = 1.2 })
			for i = -3, 3 do
				local ang = i * 0.3
				local p = part({ Size = Vector3.new(0.25, 0.25, 3.2), Color = SABER, Transparency = 0.15 + math.abs(i) * 0.08,
					CFrame = cf * CFrame.Angles(0, -ang, 0) * CFrame.new(0, -i * 0.25, -5.2) * CFrame.Angles(0, math.pi / 2, 0.25) })
				TweenService:Create(p, TweenInfo.new(0.28), { Transparency = 1, Size = Vector3.new(0.05, 0.05, 3.2) }):Play()
				Debris:AddItem(p, 0.3)
			end
		end
		if typeof(cutAt) == "Vector3" and typeof(look) == "Vector3" then saberCut(cutAt, look) end
	elseif kind == "SaberCut" then
		if typeof(a[1]) == "Vector3" and typeof(a[2]) == "Vector3" then saberCut(a[1], a[2]) end
	end
end

MonsterFx.release = release

function MonsterFx.init(fx, hud, sfx)
	Fx, HUD, Sfx = fx, hud, sfx
	-- the Void Knight's blade starts to hum when he appears
	workspace.ChildAdded:Connect(bladeIgnite)
	local now = workspace:FindFirstChild("Ghost")
	if now then bladeIgnite(now) end
	if RunService:IsStudio() then
		-- Studio test hook: player attribute DebugJumpscare = true plays the Party Bear jumpscare with the current
		-- monster (DebugJumpscareHold = true keeps the last frame on screen until it is cleared)
		lp:GetAttributeChangedSignal("DebugJumpscare"):Connect(function()
			if lp:GetAttribute("DebugJumpscare") then jumpscare(workspace:FindFirstChild("Ghost")) end
		end)
	end
end

return MonsterFx
