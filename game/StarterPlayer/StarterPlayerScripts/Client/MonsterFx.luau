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
	GoblinSteal = true, GoblinUse = true, GoblinDrop = true,
	ShieldBlock = true, Slammed = true, AnimJumpscare = true,
}
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
-- the Animatronic's blackout: every lamp in the house goes dark (lights off, glowing neon dulled), a music
-- box plays while it hunts; all put back when it ends
local dimmed = {} :: { [Instance]: any }
local musicBox: Sound? = nil
local function lightsOut(on: boolean)
	if on then
		local house = workspace:FindFirstChild("Mansion")
		if not house then return end
		for _, d in house:GetDescendants() do
			if dimmed[d] == nil then
				if d:IsA("Light") and d.Enabled then
					dimmed[d] = true; d.Enabled = false
				elseif d:IsA("BasePart") and d.Material == Enum.Material.Neon then
					dimmed[d] = d.Color; d.Material = Enum.Material.SmoothPlastic; d.Color = d.Color:Lerp(Color3.new(0, 0, 0), 0.75)
				end
			end
		end
		Sfx.play("Breaker", { Volume = 1.2, PlaybackSpeed = 0.7 })
		if musicBox then musicBox:Destroy() end
		musicBox = Sfx.loop("MusicBox", { PlaybackSpeed = 0.85 })
	else
		for d, v in dimmed do
			if d.Parent then
				if d:IsA("Light") then (d :: Light).Enabled = true
				else (d :: BasePart).Material = Enum.Material.Neon; (d :: BasePart).Color = v end
			end
		end
		table.clear(dimmed)
		if musicBox then musicBox:Destroy(); musicBox = nil end
	end
end

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
		local dark = allLights and { Brightness = -0.42, Contrast = 0.6, Saturation = -0.85 } or { Brightness = -0.32, Contrast = 0.5, Saturation = -0.8 }
		TweenService:Create(cc, TweenInfo.new(allLights and 0.15 or 0.4), dark):Play()
		if allLights then lightsOut(true) end
		task.delay((t or 5) + 0.2, function() blackout(false) end)
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

function MonsterFx.handle(kind: string, ...)
	local a = { ... }
	if kind == "AbilityWind" then
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
