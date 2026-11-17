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
	SnapWind = true, Snap = true, TitanEat = true, TitanHeal = true, -- evolved monsters
}
local Settings = require(script.Parent.Settings)
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
	end
end

MonsterFx.release = release

function MonsterFx.init(fx, hud, sfx)
	Fx, HUD, Sfx = fx, hud, sfx
	if RunService:IsStudio() then
		-- Studio test hook: player attribute DebugJumpscare = true plays the Party Bear jumpscare with the current
		-- monster (DebugJumpscareHold = true keeps the last frame on screen until it is cleared)
		lp:GetAttributeChangedSignal("DebugJumpscare"):Connect(function()
			if lp:GetAttribute("DebugJumpscare") then jumpscare(workspace:FindFirstChild("Ghost")) end
		end)
	end
end

return MonsterFx
