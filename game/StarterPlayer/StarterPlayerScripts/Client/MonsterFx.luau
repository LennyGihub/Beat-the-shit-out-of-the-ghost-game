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
	HellMark = true, HellPillar = true, Charge = true, CloneSpawn = true, CloneShatter = true,
}
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
	if emit then pe.Rate = 0; pe:Emit(emit) end
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

local blackoutCC: ColorCorrectionEffect? = nil
local function blackout(on: boolean, t: number?)
	if not blackoutCC then
		blackoutCC = Instance.new("ColorCorrectionEffect")
		blackoutCC.Name = "Blackout"
		blackoutCC.Parent = Lighting
	end
	local cc = blackoutCC :: ColorCorrectionEffect
	if on then
		Sfx.play("GhostWhisper", { Volume = 1.2, PlaybackSpeed = 0.6 })
		HUD.banner("THE LIGHTS ARE OUT", "IT'S COMING FOR YOU", 2.5)
		TweenService:Create(cc, TweenInfo.new(0.4), { Brightness = -0.32, Contrast = 0.5, Saturation = -0.8 }):Play()
		task.delay((t or 5) + 0.2, function() blackout(false) end)
	else
		TweenService:Create(cc, TweenInfo.new(0.6), { Brightness = 0, Contrast = 0, Saturation = 0 }):Play()
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

function MonsterFx.handle(kind: string, ...)
	local a = { ... }
	if kind == "AbilityWind" then
		local pos, k = a[1], a[2]
		local col = k == "wail" and Color3.fromRGB(160, 230, 240) or (k == "charge" and Color3.fromRGB(220, 220, 240) or Color3.fromRGB(255, 70, 40))
		emitter(pos, { Color = ColorSequence.new(col), LightEmission = 1, Size = NumberSequence.new(2, 0), Speed = NumberRange.new(-14, -8),
			Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, Lifetime = NumberRange.new(0.4, 0.6),
			Texture = "rbxasset://textures/particles/sparkles_main.dds" }, 40, 1.5)
		Sfx.at(k == "wail" and "GhostWail" or "GhostHurt", pos, { PlaybackSpeed = k == "wail" and 0.8 or 0.6, Volume = 1.2 })
		Fx.shake(0.15 * near(pos, 60))
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
			holdConn = RunService.RenderStepped:Connect(function()
				if os.clock() > untilT or not hand.Parent or not hrp.Parent then release(); return end
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.CFrame = hand.CFrame * CFrame.new(0, -1.2, -1.6) * CFrame.Angles(0, math.pi, 0)
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
		blackout(true, a[1])
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
end

return MonsterFx
