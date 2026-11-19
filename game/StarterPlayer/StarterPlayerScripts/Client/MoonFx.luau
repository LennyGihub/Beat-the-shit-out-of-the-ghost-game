--!strict
-- What the Black Moon's monsters' moves look and sound like (Server/MoonMonsters sends these Fx). Map 5, the last:
-- the biggest effects in the game (void, plasma, lightning - Client/FxTier):
--   BreachWarn (model, spot, normal, t) / BreachOpen (spot, normal, t, force, r) / BreachSeal (spot)   the Astronaut's
--     hull breach: this client drags its own body toward the hole while it is open (walk against it; cover between
--     you and the hole shelters you)
--   JetIgnite (model, t) / JetTarget (player, t, r) / JetLock (spot, r, t) / JetSlam (spot, r)          his jetpack
--   AcidRear (model, t) / AcidFly (part) / AcidPool (spot, r, life) / AcidBurn (player)                 the Specimen's acid
--   BroodSplit (model, t) / BroodBurst (model)                                                          its brood
--   MissileLock (model, players, t, r) / MissileFire (model, spots, flight, r) / MissileBoom (spots, r)  the Sentinel
--   OverloadCharge (model, t, range) / OverloadOn (model, t, range) / ArcHit (model, player) / OverloadOff (model)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Sfx = require(script.Parent.Sfx)
local Settings = require(script.Parent.Settings)

local MF = {}
local lp = Players.LocalPlayer
local Fx: any = nil
local HUD: any = nil
local TEX = "rbxasset://textures/particles/"
local C = Color3.fromRGB
local VOID = C(150, 110, 255)
local ACID = C(140, 255, 90)
local ALARM = C(255, 50, 40)
local PLASMA = C(110, 220, 255)
local FIRE = C(255, 150, 60)
local rng = Random.new()

MF.KINDS = { "BreachWarn", "BreachOpen", "BreachSeal", "JetIgnite", "JetTarget", "JetLock", "JetSlam", "AcidRear", "AcidFly", "AcidPool", "AcidBurn",
	"BroodSplit", "BroodBurst", "MissileLock", "MissileFire", "MissileBoom", "OverloadCharge", "OverloadOn", "ArcHit", "OverloadOff" }
local set = {} :: { [string]: boolean }
for _, k in MF.KINDS do set[k] = true end
function MF.handles(kind: string): boolean return set[kind] == true end

local function folder(): Folder
	local f = workspace:FindFirstChild("MoonFxLocal") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "MoonFxLocal"; nf.Parent = workspace
		f = nf
	end
	return f :: Folder
end
local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do (p :: any)[k] = v end
	p.Parent = folder()
	return p
end
local function hrpOf(x: Instance?): BasePart?
	if not x then return nil end
	if x:IsA("Player") then return x.Character and x.Character:FindFirstChild("HumanoidRootPart") :: BasePart? end
	return x:FindFirstChild("HumanoidRootPart") :: BasePart?
end
local function near(pos: Vector3, dist: number): number
	local d = (workspace.CurrentCamera.CFrame.Position - pos).Magnitude
	return math.clamp(1 - d / dist, 0, 1)
end
local function shake(pos: Vector3, amount: number, dist: number)
	if Fx then Fx.shake(amount * near(pos, dist)) end
end
local function burst(pos: Vector3, color: Color3, n: number, size: number, speed: number, texture: string?, up: boolean?, light: number?, grav: number?)
	local a = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = pos })
	local e = Instance.new("ParticleEmitter")
	e.Texture = texture or (TEX .. "sparkles_main.dds"); e.Color = ColorSequence.new(color); e.LightEmission = light or 0.4; e.LightInfluence = 0.2
	e.Size = NumberSequence.new(size, 0); e.Transparency = NumberSequence.new(0.05, 1); e.Lifetime = NumberRange.new(0.5, 1.2)
	e.Speed = NumberRange.new(speed * 0.5, speed); e.SpreadAngle = Vector2.new(up and 35 or 180, up and 35 or 180); e.Acceleration = Vector3.new(0, -(grav or 30), 0)
	e.EmissionDirection = Enum.NormalId.Top; e.Rate = 0; e.Drag = 1.2; e.Parent = a
	e:Emit(Settings.fxCount(n))
	Debris:AddItem(a, 2.5)
end
local function ring(spot: Vector3, color: Color3, r0: number, r1: number, t: number, transp: number?, thick: number?)
	local r = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = color, Transparency = transp or 0.35,
		Size = Vector3.new(thick or 0.14, r0 * 2, r0 * 2), CFrame = CFrame.new(spot + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(r, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(thick or 0.14, r1 * 2, r1 * 2), Transparency = 1 }):Play()
	Debris:AddItem(r, t + 0.1)
	return r
end
local function flashLight(pos: Vector3, color: Color3, range: number, bright: number, t: number)
	local p = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = pos })
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range; l.Brightness = bright; l.Shadows = false; l.Parent = p
	TweenService:Create(l, TweenInfo.new(t), { Brightness = 0 }):Play()
	Debris:AddItem(p, t + 0.1)
end
local function fireball(pos: Vector3, size: number, color: Color3)
	local b = part({ Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = color, Transparency = 0.05, Size = Vector3.one * size * 0.3, Position = pos })
	TweenService:Create(b, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * size, Transparency = 1 }):Play()
	Debris:AddItem(b, 0.5)
end
local function exclude(): RaycastParams
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local ex = { folder() }
	for _, p in Players:GetPlayers() do if p.Character then table.insert(ex, p.Character) end end
	for _, n in { "Ghost", "MoonFx" } do
		local g = workspace:FindFirstChild(n)
		if g then table.insert(ex, g) end
	end
	rp.FilterDescendantsInstances = ex
	return rp
end
local function floorUnder(pos: Vector3): Vector3
	local r = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -30, 0), exclude())
	return r and r.Position or (pos - Vector3.new(0, 3, 0))
end
-- a jagged bolt of lightning a -> b that flickers away
local function bolt(a: Vector3, b: Vector3, color: Color3, width: number, life: number)
	local n = 7
	local last = a
	local side = math.min(3, (b - a).Magnitude * 0.12)
	for i = 1, n do
		local p = a:Lerp(b, i / n)
		if i < n then p += Vector3.new(rng:NextNumber(-side, side), rng:NextNumber(-side, side), rng:NextNumber(-side, side)) end
		local len = (p - last).Magnitude
		local s = part({ Material = Enum.Material.Neon, Color = color, Size = Vector3.new(width, width, len), CFrame = CFrame.lookAt(last:Lerp(p, 0.5), p) })
		TweenService:Create(s, TweenInfo.new(life), { Transparency = 1, Size = Vector3.new(width * 0.2, width * 0.2, len) }):Play()
		Debris:AddItem(s, life + 0.05)
		last = p
	end
end
local function partOf(m: Model?, name: string): BasePart?
	return m and m:FindFirstChild(name, true) :: BasePart?
end

---------------------------------------------------------------------------------------------- the Lost Astronaut
local breach: { spot: Vector3, untilT: number, force: number, r: number, parts: { Instance }, conn: RBXScriptConnection? }? = nil
local function sealBreach()
	local b = breach
	if not b then return end
	breach = nil
	if b.conn then b.conn:Disconnect() end
	for _, p in b.parts do
		if p:IsA("BasePart") then TweenService:Create(p, TweenInfo.new(0.6), { Transparency = 1 }):Play() end
		Debris:AddItem(p, 0.7)
	end
end
local function breachWarn(m: Model?, spot: Vector3, normal: Vector3, t: number)
	-- cracks spread on the wall, a red alarm light starts turning
	local cf = CFrame.lookAt(spot, spot + normal)
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		local len = rng:NextNumber(2, 5)
		local c = part({ Color = C(10, 10, 14), Size = Vector3.new(0.25, len, 0.06), CFrame = cf * CFrame.Angles(0, 0, a) * CFrame.new(0, len / 2 + 0.6, 0.05) })
		c.Transparency = 1
		TweenService:Create(c, TweenInfo.new(t * 0.8), { Transparency = 0 }):Play()
		Debris:AddItem(c, t + 0.2)
	end
	local glow = part({ Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = ALARM, Transparency = 0.4, Size = Vector3.one * 1.5, CFrame = cf * CFrame.new(0, 0, 0.3) })
	TweenService:Create(glow, TweenInfo.new(t), { Size = Vector3.one * 4, Transparency = 0.1 }):Play()
	Debris:AddItem(glow, t + 0.05)
	Sfx.at("Klaxon", spot, { Volume = 1.2 })
	local h = hrpOf(m)
	if h then Sfx.at(Sfx.voice("WindUp", "Astronaut"), h.Position, { Volume = 1.2 }) end
end
local function breachOpen(spot: Vector3, normal: Vector3, t: number, force: number, r: number)
	sealBreach()
	local parts = {} :: { Instance }
	local cf = CFrame.lookAt(spot, spot + normal)
	-- the hole: black space with stars, a jagged rim, sparks
	local hole = part({ Shape = Enum.PartType.Cylinder, Color = C(2, 2, 6), Size = Vector3.new(0.2, 7, 7), CFrame = cf * CFrame.new(0, 0, 0.15) * CFrame.Angles(0, math.pi / 2, 0) })
	table.insert(parts, hole)
	for i = 1, 10 do
		local st = part({ Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = Color3.new(1, 1, 1), Size = Vector3.one * rng:NextNumber(0.1, 0.25),
			CFrame = cf * CFrame.new(rng:NextNumber(-2.5, 2.5), rng:NextNumber(-2.5, 2.5), 0.3) })
		table.insert(parts, st)
		local _ = i
	end
	for i = 1, 12 do
		local a = i / 12 * math.pi * 2
		local sh = part({ Color = C(120, 124, 136), Material = Enum.Material.Metal, Size = Vector3.new(0.6, rng:NextNumber(1, 2.2), 0.3),
			CFrame = cf * CFrame.Angles(0, 0, a) * CFrame.new(0, 3.6, 0.4) * CFrame.Angles(rng:NextNumber(-0.5, 0.5), 0, 0) })
		table.insert(parts, sh)
	end
	-- air and dust streaming into it from the room
	local src = part({ Size = Vector3.new(30, 10, 30), Transparency = 1, CFrame = cf * CFrame.new(0, 0, 16) })
	table.insert(parts, src)
	local e = Instance.new("ParticleEmitter")
	e.Texture = TEX .. "smoke_main.dds"; e.Color = ColorSequence.new(C(200, 210, 230)); e.Size = NumberSequence.new(0.6, 0.1); e.Transparency = NumberSequence.new(0.5, 1)
	e.Lifetime = NumberRange.new(0.6, 1); e.Speed = NumberRange.new(30, 46); e.Rate = Settings.fxCount(90)
	e.EmissionDirection = Enum.NormalId.Back; e.SpreadAngle = Vector2.new(8, 8); e.Parent = src
	local streak = Instance.new("ParticleEmitter")
	streak.Texture = TEX .. "sparkles_main.dds"; streak.Color = ColorSequence.new(VOID); streak.LightEmission = 1; streak.Size = NumberSequence.new(0.3, 0)
	streak.Lifetime = NumberRange.new(0.5, 0.8); streak.Speed = NumberRange.new(40, 60); streak.Rate = Settings.fxCount(60)
	streak.EmissionDirection = Enum.NormalId.Back; streak.SpreadAngle = Vector2.new(5, 5); streak.Parent = src
	-- a red alarm light sweeping round
	local al = part({ Size = Vector3.one * 0.3, Transparency = 1, CFrame = cf * CFrame.new(0, 6, 3) })
	table.insert(parts, al)
	local sp = Instance.new("SpotLight"); sp.Color = ALARM; sp.Range = 60; sp.Angle = 70; sp.Brightness = 5; sp.Parent = al
	burst(spot, C(200, 210, 230), 60, 1.6, 30, TEX .. "smoke_main.dds")
	fireball(spot, 9, ALARM)
	Sfx.at("Explosion", spot, { Volume = 1, PlaybackSpeed = 1.2 })
	Sfx.at("GlassBreak", spot, { Volume = 1.4, PlaybackSpeed = 0.8 })
	local wind = Sfx.at("Airlock", spot, { Volume = 1.5, PlaybackSpeed = 0.7, Looped = true })
	if wind then table.insert(parts, wind) end
	shake(spot, 1.0, 80)
	local b = { spot = spot, untilT = os.clock() + t, force = force, r = r, parts = parts, conn = nil :: RBXScriptConnection? }
	breach = b
	local rp = exclude()
	b.conn = RunService.Heartbeat:Connect(function()
		if os.clock() > b.untilT then sealBreach(); return end
		al.CFrame = cf * CFrame.new(0, 6, 3) * CFrame.Angles(0, os.clock() * 6, 0)
		-- THE PULL on this player: toward the hole, on top of their own walking (walking away beats it slowly)
		local ch = lp.Character
		local h = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if not h or not hum or hum.Health <= 0 or not lp:GetAttribute("InMatch") then return end
		local to = Vector3.new(spot.X - h.Position.X, 0, spot.Z - h.Position.Z)
		if to.Magnitude < 1.5 or to.Magnitude > 120 then return end
		-- (cover between you and the hole shelters you)
		if workspace:Raycast(h.Position, spot - h.Position - (spot - h.Position).Unit * 2, rp) then return end
		local walk = hum.MoveDirection * hum.WalkSpeed
		local pull = to.Unit * b.force * math.clamp(1.4 - to.Magnitude / 120, 0.6, 1.3)
		h.AssemblyLinearVelocity = Vector3.new(walk.X + pull.X, h.AssemblyLinearVelocity.Y, walk.Z + pull.Z)
		if to.Magnitude < r and HUD and os.clock() % 0.4 < 0.02 then HUD.flash(C(40, 20, 80), 0.2) end
	end)
end
local function jetFlames(m: Model?, t: number, big: boolean)
	local pack = partOf(m, "Jetpack") or hrpOf(m)
	if not pack then return end
	for _, dx in { -0.6, 0.6 } do
		local a = Instance.new("Attachment"); a.Position = Vector3.new(dx, -1.2, 0.2); a.Parent = pack
		local e = Instance.new("ParticleEmitter")
		e.Texture = TEX .. "fire_main.dds"; e.Color = ColorSequence.new(C(255, 230, 160), FIRE); e.LightEmission = 1
		e.Size = NumberSequence.new(big and 1.6 or 1.1, 0.2); e.Lifetime = NumberRange.new(0.2, 0.4); e.Speed = NumberRange.new(18, 26)
		e.EmissionDirection = Enum.NormalId.Bottom; e.SpreadAngle = Vector2.new(8, 8); e.Rate = Settings.fxCount(90); e.Parent = a
		local l = Instance.new("PointLight"); l.Color = FIRE; l.Range = 18; l.Brightness = 3; l.Parent = a
		Debris:AddItem(a, t)
	end
end
local function jetTarget(who: Player?, t: number, r: number)
	local edge = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = ALARM, Transparency = 0.45, Size = Vector3.new(0.08, r * 2, r * 2) })
	local cross = {}
	for _, rot in { 0, math.pi / 2 } do
		table.insert(cross, { p = part({ Material = Enum.Material.Neon, Color = ALARM, Transparency = 0.3, Size = Vector3.new(0.3, 0.06, r * 1.6) }), rot = rot })
	end
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.Heartbeat:Connect(function()
		local h = hrpOf(who)
		if os.clock() - t0 > t or not h then
			c:Disconnect(); edge:Destroy()
			for _, x in cross do x.p:Destroy() end
			return
		end
		local f = floorUnder(h.Position)
		edge.CFrame = CFrame.new(f + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		for _, x in cross do x.p.CFrame = CFrame.new(f + Vector3.new(0, 0.14, 0)) * CFrame.Angles(0, x.rot + os.clock() * 2, 0) end
	end)
	Sfx.play("Klaxon", { Volume = 0.5, PlaybackSpeed = 1.3 })
end

---------------------------------------------------------------------------------------------- the Specimen
local function acidPool(spot: Vector3, r: number, life: number)
	local pool = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = ACID, Transparency = 0.25,
		Size = Vector3.new(0.1, 1, 1), CFrame = CFrame.new(spot + Vector3.new(0, 0.07, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(pool, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Size = Vector3.new(0.1, r * 2, r * 2) }):Play()
	local dark = part({ Shape = Enum.PartType.Cylinder, Color = C(30, 60, 20), Transparency = 0.2,
		Size = Vector3.new(0.12, r * 1.5, r * 1.5), CFrame = CFrame.new(spot + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	local l = Instance.new("PointLight"); l.Color = ACID; l.Range = r * 3; l.Brightness = 2; l.Parent = pool
	local e = Instance.new("ParticleEmitter")
	e.Texture = TEX .. "forcefield_glow_main.dds"; e.Color = ColorSequence.new(ACID); e.LightEmission = 0.8; e.Size = NumberSequence.new(0.6, 0)
	e.Lifetime = NumberRange.new(0.5, 1); e.Speed = NumberRange.new(1, 3); e.Rate = Settings.fxCount(14); e.EmissionDirection = Enum.NormalId.Right; e.Parent = pool
	local steam = Instance.new("ParticleEmitter")
	steam.Texture = TEX .. "smoke_main.dds"; steam.Color = ColorSequence.new(C(160, 220, 120)); steam.Size = NumberSequence.new(1, 3); steam.Transparency = NumberSequence.new(0.7, 1)
	steam.Lifetime = NumberRange.new(1, 1.6); steam.Speed = NumberRange.new(2, 4); steam.Rate = Settings.fxCount(8); steam.EmissionDirection = Enum.NormalId.Right; steam.Parent = dark
	burst(spot + Vector3.new(0, 0.5, 0), ACID, 24, 0.9, 16, nil, true, 1)
	Sfx.at("AcidSizzle", spot, { Volume = 1 })
	task.delay(life - 0.8, function()
		if pool.Parent then
			e.Enabled = false; steam.Enabled = false
			TweenService:Create(pool, TweenInfo.new(0.8), { Transparency = 1 }):Play()
			TweenService:Create(dark, TweenInfo.new(0.8), { Transparency = 1 }):Play()
			TweenService:Create(l, TweenInfo.new(0.8), { Brightness = 0 }):Play()
		end
	end)
	Debris:AddItem(pool, life + 0.2); Debris:AddItem(dark, life + 0.2)
end

---------------------------------------------------------------------------------------------- the Sentinel
local locks = {} :: { RBXScriptConnection }
local lockParts = {} :: { Instance }
local function clearLocks()
	for _, c in locks do c:Disconnect() end
	for _, p in lockParts do p:Destroy() end
	table.clear(locks); table.clear(lockParts)
end
local function missileLock(m: Model?, who: { Player }, t: number, r: number)
	clearLocks()
	local eye = partOf(m, "Eye")
	for _, p in who do
		local edge = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = ALARM, Transparency = 0.4, Size = Vector3.new(0.08, r * 2, r * 2) })
		local dot = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = ALARM, Transparency = 0.2, Size = Vector3.new(0.1, 1.2, 1.2) })
		table.insert(lockParts, edge); table.insert(lockParts, dot)
		local beamP = part({ Size = Vector3.one * 0.2, Transparency = 1 })
		table.insert(lockParts, beamP)
		local a1 = Instance.new("Attachment"); a1.Parent = beamP
		local bm: Beam? = nil
		if eye then
			local a0 = Instance.new("Attachment"); a0.Parent = eye
			table.insert(lockParts, a0)
			local b = Instance.new("Beam"); b.Attachment0 = a0; b.Attachment1 = a1; b.Color = ColorSequence.new(ALARM); b.LightEmission = 1; b.FaceCamera = true
			b.Width0 = 0.12; b.Width1 = 0.12; b.Transparency = NumberSequence.new(0.2); b.Parent = beamP
			bm = b
		end
		local t0 = os.clock()
		table.insert(locks, RunService.Heartbeat:Connect(function()
			local h = hrpOf(p)
			if not h or os.clock() - t0 > t + 0.2 then return end
			local f = floorUnder(h.Position)
			local k = (os.clock() - t0) / t
			local w = 1 + (1 - k) * 0.6
			edge.Size = Vector3.new(0.08, r * 2 * w, r * 2 * w)
			edge.CFrame = CFrame.new(f + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
			dot.CFrame = CFrame.new(f + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2)
			beamP.Position = h.Position
			if bm then bm.Enabled = (os.clock() * 10) % 2 < 1.4 end
		end))
		local _ = m
	end
	for i = 0, math.floor(t / 0.25) do task.delay(i * 0.25, function() Sfx.play("Klaxon", { Volume = 0.25, PlaybackSpeed = 2 + i * 0.05 }) end) end
end
local function missileFire(m: Model?, spots: { Vector3 }, flight: number, r: number)
	clearLocks()
	local h = hrpOf(m)
	local from = (partOf(m, "Pod") and (partOf(m, "Pod") :: BasePart).Position) or (h and h.Position + Vector3.new(0, 6, 0)) or Vector3.zero
	if h then Sfx.at("MissileLaunch", from, { Volume = 1.4 }) end
	for i, s in spots do
		-- the fixed ring on the floor
		local w = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = ALARM, Transparency = 0.3,
			Size = Vector3.new(0.1, r * 2, r * 2), CFrame = CFrame.new(s + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(w, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.7 }):Play()
		Debris:AddItem(w, flight + 0.05)
		-- the missile: up out of the pod, over and down on the ring
		local mis = part({ Material = Enum.Material.Metal, Color = C(200, 200, 210), Size = Vector3.new(0.6, 0.6, 2.4) })
		local tip = part({ Material = Enum.Material.Neon, Color = ALARM, Size = Vector3.new(0.5, 0.5, 0.5) })
		local a0 = Instance.new("Attachment"); a0.Position = Vector3.new(0, 0.3, 1.2); a0.Parent = mis
		local a1 = Instance.new("Attachment"); a1.Position = Vector3.new(0, -0.3, 1.2); a1.Parent = mis
		local tr = Instance.new("Trail"); tr.Attachment0 = a0; tr.Attachment1 = a1; tr.Lifetime = 0.35; tr.LightEmission = 1
		tr.Color = ColorSequence.new(C(255, 230, 160), FIRE); tr.Transparency = NumberSequence.new(0, 1); tr.Parent = mis
		local fe = Instance.new("ParticleEmitter")
		fe.Texture = TEX .. "smoke_main.dds"; fe.Color = ColorSequence.new(C(200, 200, 200)); fe.Size = NumberSequence.new(0.6, 2); fe.Transparency = NumberSequence.new(0.5, 1)
		fe.Lifetime = NumberRange.new(0.4, 0.8); fe.Speed = NumberRange.new(0.5, 1); fe.Rate = Settings.fxCount(40); fe.Parent = a0
		local start = from + Vector3.new(rng:NextNumber(-1.5, 1.5), 0, rng:NextNumber(-1.5, 1.5))
		local apex = (start + s) / 2 + Vector3.new(0, 22 + i % 3 * 3, 0)
		local t0 = os.clock() + (i - 1) * 0.04
		local c: RBXScriptConnection
		c = RunService.RenderStepped:Connect(function()
			local k = math.clamp((os.clock() - t0) / flight, 0, 1)
			local p = start:Lerp(apex, k):Lerp(apex:Lerp(s, k), k)
			local k2 = math.min(1, k + 0.02)
			local q = start:Lerp(apex, k2):Lerp(apex:Lerp(s, k2), k2)
			mis.CFrame = CFrame.lookAt(p, q + Vector3.new(0, 0.001, 0))
			tip.CFrame = mis.CFrame * CFrame.new(0, 0, -1.3)
			if k >= 1 then c:Disconnect(); mis:Destroy(); tip:Destroy() end
		end)
	end
end
local function missileBoom(spots: { Vector3 }, r: number)
	for i, s in spots do
		task.delay((i - 1) * 0.03, function()
			fireball(s + Vector3.new(0, 1.5, 0), r * 2.2, FIRE)
			fireball(s + Vector3.new(0, 1.5, 0), r * 1.2, C(255, 240, 200))
			burst(s + Vector3.new(0, 1, 0), C(70, 64, 60), 40, 2.6, 26, TEX .. "smoke_main.dds", true, 0.1)
			burst(s + Vector3.new(0, 1, 0), FIRE, 40, 0.7, 40, nil, false, 1)
			ring(s, FIRE, 1, r + 6, 0.5, 0.2, 0.3)
			flashLight(s + Vector3.new(0, 3, 0), FIRE, 40, 6, 0.6)
			Sfx.at("Explosion", s, { Volume = 1.2, PlaybackSpeed = rng:NextNumber(0.9, 1.15) })
			shake(s, 0.8, 70)
		end)
	end
end
local overload: { conn: RBXScriptConnection, parts: { Instance } }? = nil
local function overloadOff()
	local o = overload
	if not o then return end
	overload = nil
	o.conn:Disconnect()
	for _, p in o.parts do Debris:AddItem(p, 0) end
end
local function overloadOn(m: Model?, t: number, range: number)
	overloadOff()
	local h = hrpOf(m)
	if not h then return end
	local parts = {} :: { Instance }
	local floor = floorUnder(h.Position)
	-- the danger zone: a crackling blue ring on the floor at its range
	local edge = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = PLASMA, Transparency = 0.4,
		Size = Vector3.new(0.12, range * 2, range * 2), CFrame = CFrame.new(floor + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	local inner = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = PLASMA, Transparency = 0.88,
		Size = Vector3.new(0.1, range * 2 - 0.6, range * 2 - 0.6), CFrame = CFrame.new(floor + Vector3.new(0, 0.09, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	table.insert(parts, edge); table.insert(parts, inner)
	local glowP = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = h.Position + Vector3.new(0, 3, 0) })
	local l = Instance.new("PointLight"); l.Color = PLASMA; l.Range = range * 1.6; l.Brightness = 4; l.Parent = glowP
	table.insert(parts, glowP)
	local hum = Sfx.on("SaberHum", glowP, { Volume = 1, PlaybackSpeed = 0.7 })
	if hum then table.insert(parts, hum) end
	Sfx.at("ElectricArc", h.Position, { Volume = 1.5 })
	local nextBolt = 0
	local t0 = os.clock()
	local conn = RunService.RenderStepped:Connect(function()
		local hh = hrpOf(m)
		if not hh or os.clock() - t0 > t + 0.3 then overloadOff(); return end
		glowP.Position = hh.Position + Vector3.new(0, 3, 0)
		l.Brightness = 3 + math.random() * 4
		edge.Transparency = 0.3 + math.random() * 0.4
		if os.clock() >= nextBolt then
			nextBolt = os.clock() + 0.06
			local a = rng:NextNumber(0, math.pi * 2)
			local d = rng:NextNumber(4, range)
			bolt(hh.Position + Vector3.new(0, 4, 0), floor + Vector3.new(math.cos(a) * d, 0.2, math.sin(a) * d), PLASMA, 0.25, 0.12)
		end
	end)
	overload = { conn = conn, parts = parts }
	shake(h.Position, 0.5, 60)
end

---------------------------------------------------------------------------------------------- dispatch
function MF.handle(kind: string, ...)
	local a = table.pack(...)
	if kind == "BreachWarn" then
		breachWarn(a[1], a[2], a[3], a[4])
	elseif kind == "BreachOpen" then
		breachOpen(a[1], a[2], a[3], a[4], a[5])
	elseif kind == "BreachSeal" then
		local b = breach
		if b then Sfx.at("Airlock", b.spot, { Volume = 1, PlaybackSpeed = 1.3 }) end
		sealBreach()
	elseif kind == "JetIgnite" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at("Jetpack", h.Position, { Volume = 1.5 })
			Sfx.at(Sfx.voice("WindUp", "Astronaut"), h.Position, { Volume = 1.1 })
			burst(floorUnder(h.Position), C(220, 220, 230), 50, 2.6, 20, TEX .. "smoke_main.dds")
			ring(floorUnder(h.Position), FIRE, 1, 12, 0.6, 0.3)
		end
		jetFlames(a[1], (a[2] or 1) + 2.5, true)
	elseif kind == "JetTarget" then
		jetTarget(a[1], a[2], a[3])
	elseif kind == "JetLock" then
		local spot, r, t = a[1] :: Vector3, a[2] :: number, a[3] :: number
		local w = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = ALARM, Transparency = 0.25,
			Size = Vector3.new(0.12, r * 2, r * 2), CFrame = CFrame.new(spot + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(w, TweenInfo.new(0.07, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.7 }):Play()
		Debris:AddItem(w, t + 0.05)
		Sfx.at("Jetpack", spot + Vector3.new(0, 10, 0), { Volume = 1.6, PlaybackSpeed = 0.8 })
	elseif kind == "JetSlam" then
		local spot, r = a[1] :: Vector3, a[2] :: number
		fireball(spot + Vector3.new(0, 1, 0), r * 2, FIRE)
		burst(spot + Vector3.new(0, 0.5, 0), C(220, 220, 230), 80, 3, 34, TEX .. "smoke_main.dds", false, 0.1, 6)
		burst(spot + Vector3.new(0, 0.5, 0), FIRE, 50, 0.9, 40, nil, false, 1)
		for i = 0, 2 do task.delay(i * 0.1, function() ring(spot, i == 1 and Color3.new(1, 1, 1) or FIRE, 1, r + 10 + i * 6, 0.6, 0.2, 0.4) end) end
		flashLight(spot + Vector3.new(0, 3, 0), FIRE, 50, 7, 0.8)
		Sfx.at("Explosion", spot, { Volume = 1.4 })
		Sfx.at(Sfx.voice("Spawn", "Astronaut"), spot, { Volume = 1 })
		shake(spot, 1.3, 80)
	elseif kind == "AcidRear" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at(Sfx.voice("WindUp", "Specimen"), h.Position, { Volume = 1.3 })
			burst(h.Position + Vector3.new(0, 3, 0), ACID, 20, 0.6, 6, nil, true, 1)
		end
	elseif kind == "AcidFly" then
		local p = a[1] :: BasePart?
		if p then
			local e = Instance.new("ParticleEmitter")
			e.Texture = TEX .. "forcefield_glow_main.dds"; e.Color = ColorSequence.new(ACID); e.LightEmission = 1; e.Size = NumberSequence.new(1, 0.2)
			e.Lifetime = NumberRange.new(0.25, 0.5); e.Speed = NumberRange.new(0.5, 2); e.Rate = Settings.fxCount(60); e.Parent = p
			local l = Instance.new("PointLight"); l.Color = ACID; l.Range = 10; l.Brightness = 2; l.Parent = p
			Sfx.at("FormSquish", p.Position, { Volume = 1, PlaybackSpeed = 0.8 })
		end
	elseif kind == "AcidPool" then
		acidPool(a[1], a[2], a[3])
	elseif kind == "AcidBurn" then
		local who = a[1] :: Player?
		local h = hrpOf(who)
		if h then burst(h.Position - Vector3.new(0, 2, 0), ACID, 8, 0.5, 6, nil, true, 1) end
		if who == lp and HUD then HUD.flash(ACID, 0.18) end
	elseif kind == "BroodSplit" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at(Sfx.voice("WindUp", "Specimen"), h.Position, { Volume = 1.2, PlaybackSpeed = 0.8 })
			Sfx.at("FormSquish", h.Position, { Volume = 1.3, PlaybackSpeed = 0.6 })
			burst(h.Position + Vector3.new(0, 2, 0), ACID, 20, 0.6, 4, TEX .. "forcefield_glow_main.dds", true, 1)
		end
	elseif kind == "BroodBurst" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at("AlienScreech", h.Position, { Volume = 1.4 })
			burst(h.Position + Vector3.new(0, 2, 0), C(160, 200, 120), 60, 1.6, 22, TEX .. "smoke_main.dds")
			burst(h.Position + Vector3.new(0, 2, 0), ACID, 40, 0.8, 26, nil, false, 1)
			flashLight(h.Position + Vector3.new(0, 3, 0), ACID, 34, 5, 0.6)
			shake(h.Position, 0.6, 50)
		end
	elseif kind == "MissileLock" then
		missileLock(a[1], a[2], a[3], a[4])
		local h = hrpOf(a[1])
		if h then Sfx.at(Sfx.voice("WindUp", "Sentinel"), h.Position, { Volume = 1.2 }) end
	elseif kind == "MissileFire" then
		missileFire(a[1], a[2], a[3], a[4])
	elseif kind == "MissileBoom" then
		missileBoom(a[1], a[2])
	elseif kind == "OverloadCharge" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at("RobotServo", h.Position, { Volume = 1.2 })
			Sfx.at("ElectricArc", h.Position, { Volume = 0.8, PlaybackSpeed = 0.7 })
			for i = 0, 5 do
				task.delay(i * (a[2] / 6), function()
					local hh = hrpOf(a[1])
					if hh then bolt(hh.Position + Vector3.new(rng:NextNumber(-2, 2), 5, rng:NextNumber(-2, 2)), floorUnder(hh.Position) + Vector3.new(rng:NextNumber(-4, 4), 0, rng:NextNumber(-4, 4)), PLASMA, 0.2, 0.15) end
				end)
			end
			ring(floorUnder(h.Position), PLASMA, 1, a[3], a[2], 0.5, 0.2)
		end
	elseif kind == "OverloadOn" then
		overloadOn(a[1], a[2], a[3])
	elseif kind == "ArcHit" then
		local h = hrpOf(a[1])
		local ph = hrpOf(a[2])
		if h and ph then
			bolt(h.Position + Vector3.new(0, 4, 0), ph.Position, PLASMA, 0.45, 0.2)
			bolt(h.Position + Vector3.new(0, 4, 0), ph.Position, Color3.new(1, 1, 1), 0.18, 0.15)
			burst(ph.Position, PLASMA, 10, 0.5, 14, nil, false, 1)
			Sfx.at("TaserZap", ph.Position, { Volume = 0.8 })
			if a[2] == lp and HUD then HUD.flash(PLASMA, 0.25) end
		end
	elseif kind == "OverloadOff" then
		local h = hrpOf(a[1])
		if h then burst(h.Position + Vector3.new(0, 3, 0), PLASMA, 30, 0.6, 20, nil, false, 1) end
		overloadOff()
	end
end

function MF.init(fx: any, hud: any?)
	Fx = fx; HUD = hud
	lp:GetAttributeChangedSignal("InMatch"):Connect(function()
		if not lp:GetAttribute("InMatch") then sealBreach(); clearLocks(); overloadOff() end
	end)
end

return MF
