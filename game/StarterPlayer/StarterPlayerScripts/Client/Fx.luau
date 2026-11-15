-- Client effects: camera shake, impact flashes and particles, smash dust, wall slams, claw slashes,
-- jumpscare, ultimate shockwave, intro/victory banners, music, outdoor exposure.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Config = require(RS.Shared.Config)
local Sfx = require(script.Parent.Sfx)
local HUD = require(script.Parent.HUD)
local VM = require(script.Parent.Viewmodel)
local GA = require(script.Parent.GhostAnim)
local Grunge = require(script.Parent.Grunge)

local Fx = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local trauma = 0
local fovKick = 0
local baseFov = 74
local ambience: Sound? = nil
local music: Sound? = nil
local rng = Random.new()
local blur: BlurEffect
local grade: ColorCorrectionEffect
local slashGui: ScreenGui

function Fx.shake(amount: number) trauma = math.min(1.2, trauma + amount) end
function Fx.kick(amount: number) fovKick = math.max(fovKick, amount) end

local function flashBall(pos: Vector3, color: Color3, size: number, life: number)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Size = Vector3.one * size * 0.4
	p.Position = pos
	p.Transparency = 0.1
	p.Parent = workspace.Terrain
	TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * size, Transparency = 1 }):Play()
	Debris:AddItem(p, life + 0.05)
end

local function burst(pos: Vector3, color: Color3, count: number, speed: number, size: number, texture: string?)
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = texture or "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(color)
	pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, size * 2.2) })
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	pe.Speed = NumberRange.new(speed * 0.4, speed)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Lifetime = NumberRange.new(0.4, 1.1)
	pe.Drag = 4
	pe.Acceleration = Vector3.new(0, -6, 0)
	pe.Rate = 0
	pe.Parent = a
	pe:Emit(count)
	Debris:AddItem(a, 2)
end

local function slash()
	for i = 1, 3 do
		local f = Grunge.frame(slashGui, {
			BackgroundTransparency = 0.05, BackgroundColor3 = Color3.fromRGB(120, 0, 0), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.42 + i * 0.06, 0.5), Size = UDim2.new(0, 10, 0.9, 0), Rotation = 28 + rng:NextNumber(-4, 4),
		})
		TweenService:Create(f, TweenInfo.new(1.2), { BackgroundTransparency = 1 }):Play()
		Debris:AddItem(f, 1.3)
	end
end

local function jumpscare()
	Sfx.play("Jumpscare", { Volume = 1.2 })
	Fx.shake(1.2)
	Fx.kick(-22)
	HUD.flash(Color3.new(1, 1, 1), 0.9)
	blur.Size = 24
	grade.Contrast = 0.8
	grade.Saturation = -1
	TweenService:Create(blur, TweenInfo.new(1.2), { Size = 0 }):Play()
	TweenService:Create(grade, TweenInfo.new(1.4), { Contrast = 0, Saturation = 0 }):Play()
	task.delay(0.12, function() HUD.flash(Color3.new(0, 0, 0), 0.95) end)
	task.delay(0.24, function() HUD.flash(Color3.fromRGB(140, 0, 0), 0.7) end)
end

local function setMusic(fight: boolean)
	if fight then
		if not music then music = Sfx.loop("FightMusic") end
	else
		if music then
			local m = music
			music = nil
			TweenService:Create(m, TweenInfo.new(2), { Volume = 0 }):Play()
			task.delay(2.1, function() m:Destroy() end)
		end
	end
end

function Fx.handle(kind: string, ...)
	local args = { ... }
	if kind == "Hit" then
		local pos, combo, dmg, isUlt, by = args[1], args[2], args[3], args[4], args[5]
		local mine = by == lp
		GA.flash(isUlt and 1 or 0.85)
		flashBall(pos, isUlt and Color3.fromRGB(255, 80, 30) or Color3.fromRGB(230, 245, 245), 3 + math.min(combo, 14) * 0.5, 0.18)
		burst(pos, Color3.fromRGB(190, 225, 230), 10 + combo * 2, 18 + combo * 2, 0.5)
		local heavy = combo >= 5 or isUlt
		Sfx.at(heavy and "PunchHeavy" or "PunchLight", pos, { PlaybackSpeed = math.max(0.75, 1.15 - combo * 0.03), Volume = 0.8 + math.min(combo, 10) * 0.05 })
		if combo % 3 == 0 then Sfx.at("GhostHurt", pos, { PlaybackSpeed = rng:NextNumber(0.9, 1.15) }) end
		if mine then
			Fx.shake(0.18 + math.min(combo, 15) * 0.045 + (isUlt and 0.3 or 0))
			Fx.kick(2 + math.min(combo, 12) * 0.6)
			HUD.combo(combo, isUlt)
			if heavy then HUD.flash(isUlt and Color3.fromRGB(200, 40, 0) or Color3.fromRGB(255, 255, 255), isUlt and 0.35 or 0.12) end
		end
	elseif kind == "Smash" then
		local pos, size, k = args[1], args[2], args[3]
		Sfx.at("WoodBreak", pos, { PlaybackSpeed = rng:NextNumber(0.85, 1.1), Volume = 1 })
		if k == "Cabinet" or k == "StandingMirror" or k == "TV" or k == "Sink" then Sfx.at("Glass", pos) end
		burst(pos, Color3.fromRGB(120, 100, 80), 18, 20, 1.2)
		local d = (cam.CFrame.Position - pos).Magnitude
		if d < 40 then Fx.shake(0.25 * (1 - d / 40) + 0.05) end
	elseif kind == "WallSlam" then
		local pos, speed = args[1], args[2]
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.6, Volume = 1.2 })
		burst(pos, Color3.fromRGB(170, 160, 140), 30, 25, 1.6)
		local d = (cam.CFrame.Position - pos).Magnitude
		if d < 60 then Fx.shake(math.clamp(speed / 120, 0.2, 0.9) * (1 - d / 60)) end
	elseif kind == "Clawed" then
		local dir = args[1]
		Sfx.play("GhostScream", { Volume = 0.7, PlaybackSpeed = 1.2 })
		Sfx.play("PunchLight", { PlaybackSpeed = 0.7 })
		slash()
		HUD.flash(Color3.fromRGB(150, 0, 0), 0.5)
		Fx.shake(0.6)
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and typeof(dir) == "Vector3" then hrp.AssemblyLinearVelocity = dir * 55 + Vector3.new(0, 22, 0) end
	elseif kind == "Jumpscare" then
		jumpscare()
	elseif kind == "GhostScream" then
		Sfx.at("GhostScream", args[1], { Volume = 1 })
	elseif kind == "GhostWindUp" then
		Sfx.at("GhostWail", args[1], { PlaybackSpeed = 1.4, Volume = 0.8 })
	elseif kind == "GhostVanish" then
		Sfx.at("GhostWhisper", args[1], { Volume = 0.8 })
	elseif kind == "GhostSpawn" then
		Sfx.at("GhostScream", args[1], { Volume = 1.2, PlaybackSpeed = 0.8 })
		Fx.shake(0.4)
		setMusic(true)
	elseif kind == "GhostDeath" then
		local pos = args[1]
		Sfx.play("GhostDeath", { Volume = 1.2 })
		burst(pos, Color3.fromRGB(210, 240, 245), 120, 30, 1.4)
		flashBall(pos, Color3.new(1, 1, 1), 26, 0.9)
		Fx.shake(0.9)
		setMusic(false)
	elseif kind == "Ultimate" then
		local pos, by = args[1], args[2]
		Sfx.at("Ultimate", pos, { Volume = 1.3 })
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.5, Volume = 1.3 })
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Cylinder; ring.Material = Enum.Material.Neon; ring.Color = Color3.fromRGB(255, 60, 20)
		ring.Anchored = true; ring.CanCollide = false; ring.CanQuery = false; ring.CanTouch = false
		ring.Size = Vector3.new(0.6, 2, 2); ring.CFrame = CFrame.new(pos - Vector3.new(0, 2.6, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		ring.Transparency = 0.2; ring.Parent = workspace.Terrain
		TweenService:Create(ring, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Size = Vector3.new(0.6, Config.Brutality.UltShockRadius * 2, Config.Brutality.UltShockRadius * 2), Transparency = 1 }):Play()
		Debris:AddItem(ring, 0.7)
		burst(pos, Color3.fromRGB(255, 90, 30), 60, 40, 1.2)
		if by == lp then
			VM.slam()
			Fx.shake(1)
			Fx.kick(18)
			HUD.flash(Color3.fromRGB(255, 60, 0), 0.6)
			HUD.banner("UNLEASHED", "", 1.6)
		end
	elseif kind == "Lift" then
		Sfx.at("PunchLight", args[1], { PlaybackSpeed = 0.5, Volume = 0.6 })
	elseif kind == "Throw" then
		Sfx.at("Whoosh", args[1], { PlaybackSpeed = 0.7, Volume = 1 })
		if args[2] == lp then Fx.kick(6) end
	elseif kind == "Tired" then
		HUD.flash(Color3.fromRGB(120, 110, 40), 0.25)
	elseif kind == "Intro" then
		HUD.banner("SHE IS IN THE HOUSE", "GHOST LV " .. tostring(args[1]), 4.5)
		Sfx.play("GhostWhisper", { Volume = 1 })
	elseif kind == "Victory" then
		HUD.banner("GHOST DESTROYED", "+$" .. tostring(args[1]), 5)
		Sfx.play("Cash")
		setMusic(false)
	elseif kind == "ShopReady" then
		HUD.banner("SOMEONE SURVIVED THE CRASH", "TALK TO THE PILOT  [F]", 4)
	end
end

function Fx.init()
	blur = Instance.new("BlurEffect"); blur.Size = 0; blur.Parent = Lighting
	grade = Instance.new("ColorCorrectionEffect"); grade.Name = "FxGrade"; grade.Parent = Lighting
	slashGui = Instance.new("ScreenGui"); slashGui.Name = "Slashes"; slashGui.IgnoreGuiInset = true; slashGui.ResetOnSpawn = false
	slashGui.Parent = lp:WaitForChild("PlayerGui")
	ambience = Sfx.loop("Ambience")
	RunService:BindToRenderStep("FxShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
		trauma = math.max(0, trauma - dt * 1.6)
		local s = trauma * trauma
		local t = os.clock() * 40
		local off = CFrame.Angles(math.noise(t, 1) * 0.06 * s, math.noise(t, 2) * 0.06 * s, math.noise(t, 3) * 0.08 * s)
			* CFrame.new(math.noise(t, 4) * 0.5 * s, math.noise(t, 5) * 0.5 * s, 0)
		cam.CFrame = cam.CFrame * off
		VM.setShake(CFrame.new())
		fovKick += (0 - fovKick) * math.min(1, dt * 8)
		cam.FieldOfView = baseFov + fovKick
		-- brighter exposure outside, dark PS2 interior inside
		local pos = cam.CFrame.Position
		local inside = pos.X > Config.House.Min.X and pos.X < Config.House.Max.X and pos.Z > Config.House.Min.Z and pos.Z < Config.House.Max.Z and pos.Y < 45
		local want = inside and 0 or 1.0
		Lighting.ExposureCompensation += (want - Lighting.ExposureCompensation) * math.min(1, dt * 2)
		if ambience then ambience.Volume = inside and 0.45 or 0.15 end
	end)
end

return Fx
