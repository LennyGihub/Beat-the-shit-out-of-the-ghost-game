--!strict
-- THE FURTHER YOU GO, THE BIGGER IT GETS (2026-11-19, the user: "make the visual effect more impressive and important
-- the further you go in the maps"). The campaign map of the building you fight in (RS attribute MapId -> Shared/
-- Campaign) is a TIER: Camp Hollowmere 1, the Moonlight Carnival 2, Blackwater Harbor 3, the Ashen Abbey 4, the Black
-- Moon 5 (any other map: 1). On top of the game's normal effects (Client/Fx), each tier adds a layer in its map's
-- colours:
--   HITS        tier 2+ coloured sparks, 3+ a shock ring, 4+ embers and a flash of light, 5 forks of lightning
--   CHARGED     tier 3+ a shock sphere, 4+ a burst of fire, 5 an implosion and lightning
--   MONSTER     its AURA (client-only emitters on the monster): 2 sparkles, 3 + mist and a light, 4 + rising embers
--               and flames, 5 + void smoke and orbiting shards
--   DEATH       2 a coloured burst, 3 + shock rings, 4 + a pillar of fire, 5 + an implosion, a starburst, lightning
--   ENTRANCE    3+ an arrival ring, 4 a hellfire eruption, 5 a void portal with lightning
--   AMBIENCE    particles round the camera in the building: Camp fireflies, Carnival glitter, Harbor drizzle, Abbey
--               ash and embers, Moon floating dust and star glints
-- Studio hook: player attribute DebugTier = 1..5 forces a tier (any map).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Campaign = require(RS.Shared.Campaign)
local Settings = require(script.Parent.Settings)
local Sfx = require(script.Parent.Sfx)

local FT = {}
local lp = Players.LocalPlayer
local Fx: any = nil
local HUD: any = nil
local rng = Random.new()
local TEX = "rbxasset://textures/particles/"
local C = Color3.fromRGB

-- each map's colours: main, accent, dark
local PAL = {
	{ main = C(255, 150, 60), accent = C(255, 220, 150), dark = C(80, 40, 20) }, -- Camp: campfire
	{ main = C(255, 80, 180), accent = C(255, 220, 90), dark = C(70, 20, 60) }, -- Carnival: neon and gold
	{ main = C(80, 220, 210), accent = C(200, 240, 255), dark = C(14, 50, 60) }, -- Harbor: sea and storm
	{ main = C(255, 90, 30), accent = C(255, 230, 160), dark = C(60, 10, 6) }, -- Abbey: hellfire and holy light
	{ main = C(170, 110, 255), accent = C(110, 220, 255), dark = C(20, 8, 40) }, -- Moon: void and plasma
}

local mapIndex = {} :: { [string]: number }
for i, m in Campaign.list do mapIndex[m.id] = i end

function FT.tier(): number
	if RunService:IsStudio() then
		local d = tonumber(lp:GetAttribute("DebugTier"))
		if d then return math.clamp(math.floor(d), 1, 5) end
	end
	local st = Campaign.stage(RS:GetAttribute("MapId"))
	return st and math.clamp(mapIndex[st.map] or 1, 1, 5) or 1
end
function FT.palette(): { main: Color3, accent: Color3, dark: Color3 } return PAL[FT.tier()] end
-- how much bigger the effects are: 1, 1.35, 1.7, 2.05, 2.4
function FT.mult(): number return 1 + (FT.tier() - 1) * 0.35 end

local function folder(): Folder
	local f = workspace:FindFirstChild("FxTierLocal") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "FxTierLocal"; nf.Parent = workspace
		f = nf
	end
	return f :: Folder
end
local function part(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Material = Enum.Material.Neon
	for k, v in props do (p :: any)[k] = v end
	p.Parent = folder()
	return p
end
local function burst(pos: Vector3, colors: ColorSequence, n: number, size: number, speed: number, texture: string?, grav: number?, life: number?)
	if n <= 0 then return end
	local a = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = pos })
	local e = Instance.new("ParticleEmitter")
	e.Texture = texture or (TEX .. "sparkles_main.dds"); e.Color = colors; e.LightEmission = 1; e.LightInfluence = 0
	e.Size = NumberSequence.new(size, 0); e.Transparency = NumberSequence.new(0, 1); e.Lifetime = NumberRange.new((life or 0.6) * 0.6, life or 0.6)
	e.Speed = NumberRange.new(speed * 0.4, speed); e.SpreadAngle = Vector2.new(180, 180); e.Acceleration = Vector3.new(0, -(grav or 20), 0)
	e.Drag = 2; e.Rate = 0; e.Parent = a
	e:Emit(Settings.fxCount(n))
	Debris:AddItem(a, (life or 0.6) + 1.5)
end
local function seq(a: Color3, b: Color3): ColorSequence return ColorSequence.new(a, b) end
-- a ring that faces the camera, growing and fading
local function shockRing(pos: Vector3, color: Color3, r1: number, t: number)
	local cam = workspace.CurrentCamera
	local r = part({ Shape = Enum.PartType.Cylinder, Color = color, Transparency = 0.25, Size = Vector3.new(0.1, 0.6, 0.6),
		CFrame = CFrame.lookAt(pos, cam.CFrame.Position) * CFrame.Angles(0, math.pi / 2, 0) })
	TweenService:Create(r, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.05, r1 * 2, r1 * 2), Transparency = 1 }):Play()
	Debris:AddItem(r, t + 0.05)
end
local function floorRing(pos: Vector3, color: Color3, r1: number, t: number, thick: number?)
	local r = part({ Shape = Enum.PartType.Cylinder, Color = color, Transparency = 0.3, Size = Vector3.new(thick or 0.15, 1, 1),
		CFrame = CFrame.new(pos + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(r, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(thick or 0.15, r1 * 2, r1 * 2), Transparency = 1 }):Play()
	Debris:AddItem(r, t + 0.05)
end
local function sphere(pos: Vector3, color: Color3, s0: number, s1: number, t: number, transp: number?)
	local b = part({ Shape = Enum.PartType.Ball, Color = color, Transparency = transp or 0.3, Size = Vector3.one * s0, Position = pos })
	TweenService:Create(b, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * s1, Transparency = 1 }):Play()
	Debris:AddItem(b, t + 0.05)
end
local function flashLight(pos: Vector3, color: Color3, range: number, bright: number, t: number)
	local p = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = pos })
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range; l.Brightness = bright; l.Shadows = false; l.Parent = p
	TweenService:Create(l, TweenInfo.new(t), { Brightness = 0 }):Play()
	Debris:AddItem(p, t + 0.05)
end
local function bolt(a: Vector3, b: Vector3, color: Color3, width: number, life: number)
	local n = 6
	local last = a
	local side = math.min(2.5, (b - a).Magnitude * 0.15)
	for i = 1, n do
		local p = a:Lerp(b, i / n)
		if i < n then p += Vector3.new(rng:NextNumber(-side, side), rng:NextNumber(-side, side), rng:NextNumber(-side, side)) end
		local len = (p - last).Magnitude
		local s = part({ Color = color, Size = Vector3.new(width, width, len), CFrame = CFrame.lookAt(last:Lerp(p, 0.5), p) })
		TweenService:Create(s, TweenInfo.new(life), { Transparency = 1, Size = Vector3.new(width * 0.2, width * 0.2, len) }):Play()
		Debris:AddItem(s, life + 0.05)
		last = p
	end
end
local function floorUnder(pos: Vector3): Vector3
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local ex = { folder() }
	for _, p in Players:GetPlayers() do if p.Character then table.insert(ex, p.Character) end end
	local g = workspace:FindFirstChild("Ghost")
	if g then table.insert(ex, g) end
	rp.FilterDescendantsInstances = ex
	local r = workspace:Raycast(pos + Vector3.new(0, 1, 0), Vector3.new(0, -40, 0), rp)
	return r and r.Position or (pos - Vector3.new(0, 4, 0))
end
local function near(pos: Vector3, dist: number): number
	return math.clamp(1 - (workspace.CurrentCamera.CFrame.Position - pos).Magnitude / dist, 0, 1)
end

---------------------------------------------------------------------------------------------- hits
local function onHit(pos: Vector3, combo: number, isUlt: boolean, by: Player?)
	local t = FT.tier()
	if t < 2 then return end
	local P = PAL[t]
	local heavy = combo >= 5 or isUlt
	burst(pos, seq(P.accent, P.main), 5 * (t - 1) + math.min(combo, 12), 0.5 + t * 0.08, 16 + t * 5)
	if t >= 3 then shockRing(pos, P.main, 2.2 + t * 0.6 + (heavy and 2 or 0), 0.28) end
	if t >= 4 then
		burst(pos, seq(P.main, P.dark), 6 + combo, 0.9, 10, TEX .. "fire_main.dds", -6, 0.5)
		flashLight(pos, P.main, 14 + t * 2, heavy and 5 or 3, 0.25)
	end
	if t >= 5 then
		for _ = 1, heavy and 4 or 2 do
			local d = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.4, 1), rng:NextNumber(-1, 1)).Unit * rng:NextNumber(3, 6)
			bolt(pos, pos + d, rng:NextNumber() < 0.5 and P.main or P.accent, 0.16, 0.14)
		end
		if heavy and by == lp and HUD then HUD.flash(P.main, 0.08) end
	end
	if by == lp and Fx and heavy then Fx.shake(0.04 * (t - 1)) end
end
local function onCharged(pos: Vector3, c: number, by: Player?)
	local t = FT.tier()
	if t < 3 then return end
	local P = PAL[t]
	sphere(pos, P.main, 1, 6 + c * 6 + t, 0.35, 0.35)
	if t >= 4 then
		burst(pos, seq(P.accent, P.main), 30 + math.floor(c * 30), 1.4, 30, TEX .. "fire_main.dds", -10, 0.6)
		floorRing(floorUnder(pos), P.main, 10 + c * 8, 0.5, 0.25)
	end
	if t >= 5 then
		sphere(pos, P.dark, 9, 0.5, 0.18, 0.2) -- (the implosion before the blast)
		for _ = 1, 6 do
			local d = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.3, 1), rng:NextNumber(-1, 1)).Unit * rng:NextNumber(5, 10)
			bolt(pos, pos + d, P.accent, 0.22, 0.18)
		end
	end
	if by == lp and Fx then Fx.shake(0.1 * (t - 2)); Fx.kick(1.5 * (t - 2)) end
end

---------------------------------------------------------------------------------------------- the monster's aura
local auraOf: Model? = nil
local auraTier = 0
local orbit = {} :: { BasePart }
local function clearAura()
	if auraOf then
		for _, d in auraOf:GetDescendants() do
			if d:GetAttribute("FxTierAura") then d:Destroy() end
		end
	end
	for _, p in orbit do p:Destroy() end
	table.clear(orbit)
	auraOf = nil
	auraTier = 0
end
local function emit(parent: Instance, props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.LightInfluence = 0
	for k, v in props do (e :: any)[k] = v end
	e:SetAttribute("FxTierAura", true)
	e.Parent = parent
	return e
end
local function buildAura(m: Model, t: number)
	clearAura()
	auraOf = m
	auraTier = t
	if t < 2 then return end
	local P = PAL[t]
	local torso = (m:FindFirstChild("UpperTorso") or m:FindFirstChild("HumanoidRootPart")) :: BasePart?
	local root = m:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not torso or not root then return end
	local scale = m:GetScale()
	emit(torso, { Texture = TEX .. "sparkles_main.dds", Color = seq(P.accent, P.main), LightEmission = 1, Size = NumberSequence.new(0.35 * scale, 0),
		Lifetime = NumberRange.new(0.6, 1.2), Speed = NumberRange.new(1, 3), SpreadAngle = Vector2.new(180, 180), Rate = Settings.fxCount(4 + t * 3) })
	if t >= 3 then
		local a = Instance.new("Attachment"); a.Position = Vector3.new(0, -(m:GetAttribute("Hover") or 4.5) * scale + 0.5, 0); a.Parent = root
		a:SetAttribute("FxTierAura", true)
		emit(a, { Texture = TEX .. "smoke_main.dds", Color = seq(P.main, P.dark), LightEmission = 0.3, Size = NumberSequence.new(2 * scale, 5 * scale),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.8), NumberSequenceKeypoint.new(1, 1) }),
			Lifetime = NumberRange.new(1.2, 2), Speed = NumberRange.new(1, 3), SpreadAngle = Vector2.new(80, 80), EmissionDirection = Enum.NormalId.Top, Rate = Settings.fxCount(6) })
		local l = Instance.new("PointLight"); l.Color = P.main; l.Range = 12 + t * 3; l.Brightness = 0.6 + t * 0.25; l.Shadows = false; l.Parent = torso
		l:SetAttribute("FxTierAura", true)
	end
	if t >= 4 then
		emit(torso, { Texture = TEX .. "fire_main.dds", Color = seq(P.accent, P.main), LightEmission = 0.9, Size = NumberSequence.new(0.9 * scale, 0.1),
			Transparency = NumberSequence.new(0.3, 1), Lifetime = NumberRange.new(0.4, 0.8), Speed = NumberRange.new(2, 5), Acceleration = Vector3.new(0, 8, 0),
			SpreadAngle = Vector2.new(60, 60), EmissionDirection = Enum.NormalId.Top, Rate = Settings.fxCount(14) })
		emit(torso, { Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(P.main), LightEmission = 1, Size = NumberSequence.new(0.25, 0),
			Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(2, 6), Acceleration = Vector3.new(0, 4, 0), SpreadAngle = Vector2.new(180, 180), Rate = Settings.fxCount(10) })
	end
	if t >= 5 then
		emit(torso, { Texture = TEX .. "smoke_main.dds", Color = seq(P.dark, Color3.new(0, 0, 0)), Size = NumberSequence.new(2.5 * scale, 0.5),
			Transparency = NumberSequence.new(0.4, 1), Lifetime = NumberRange.new(0.6, 1.2), Speed = NumberRange.new(4, 8), SpreadAngle = Vector2.new(180, 180),
			Rate = Settings.fxCount(10) })
		-- shards orbiting him
		for i = 1, 6 do
			local sh = part({ Color = i % 2 == 0 and P.main or P.accent, Size = Vector3.new(0.4, 0.9, 0.4) * scale })
			table.insert(orbit, sh)
			local _ = i
		end
	end
end

---------------------------------------------------------------------------------------------- death / entrance
local function onDeath(pos: Vector3)
	local t = FT.tier()
	if t < 2 then return end
	local P = PAL[t]
	burst(pos, seq(P.accent, P.main), 40 * (t - 1), 1 + t * 0.2, 30 + t * 6, nil, 10, 1.2)
	if t >= 3 then
		local f = floorUnder(pos)
		for i = 0, t - 2 do task.delay(i * 0.12, function() floorRing(f, i % 2 == 0 and P.main or P.accent, 22 + i * 8, 0.8, 0.3) end) end
		flashLight(pos, P.main, 50, 6, 1.2)
	end
	if t >= 4 then
		local f = floorUnder(pos)
		local col = part({ Shape = Enum.PartType.Cylinder, Color = P.main, Transparency = 0.15, Size = Vector3.new(4, 6, 6),
			CFrame = CFrame.new(f + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(col, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(60, 1.5, 1.5),
			CFrame = CFrame.new(f + Vector3.new(0, 30, 0)) * CFrame.Angles(0, 0, math.pi / 2), Transparency = 1 }):Play()
		Debris:AddItem(col, 1)
		burst(pos, seq(P.main, P.dark), 60, 2, 20, TEX .. "fire_main.dds", -12, 1)
		Sfx.at("MagicBurst", pos, { Volume = 1.2, PlaybackSpeed = 0.6 })
	end
	if t >= 5 then
		sphere(pos, P.dark, 18, 0.5, 0.35, 0.1)
		task.delay(0.35, function()
			sphere(pos, P.accent, 1, 34, 0.7, 0.1)
			burst(pos, seq(Color3.new(1, 1, 1), P.accent), 120, 0.6, 70, nil, 0, 1.4) -- a starburst
			for _ = 1, 10 do
				local d = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.2, 1), rng:NextNumber(-1, 1)).Unit * rng:NextNumber(10, 22)
				bolt(pos, pos + d, rng:NextNumber() < 0.5 and P.main or P.accent, 0.35, 0.3)
			end
			if HUD and near(pos, 90) > 0 then HUD.flash(P.accent, 0.35) end
			if Fx then Fx.shake(0.8 * near(pos, 90)) end
			Sfx.at("Explosion", pos, { Volume = 1, PlaybackSpeed = 0.7 })
		end)
	end
	if Fx then Fx.shake(0.12 * (t - 1) * near(pos, 90)) end
end
local function onEntrance(model: Model?, dur: number?)
	local t = FT.tier()
	if t < 3 or not model then return end
	local P = PAL[t]
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end
	local f = floorUnder(root.Position)
	local D = dur or 5
	floorRing(f, P.main, 26, 1.2, 0.2)
	if t == 4 then
		-- a hellfire eruption: cracks of fire round the spot, embers climbing
		for i = 1, 10 do
			local a = i / 10 * math.pi * 2
			local len = rng:NextNumber(6, 12)
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local cr = part({ Color = P.main, Size = Vector3.new(rng:NextNumber(0.3, 0.6), 0.08, len), CFrame = CFrame.lookAt(f + dir * (len / 2 + 2) + Vector3.new(0, 0.08, 0), f + dir * 40 + Vector3.new(0, 0.08, 0)) })
			cr.Transparency = 1
			TweenService:Create(cr, TweenInfo.new(0.8), { Transparency = 0.1 }):Play()
			task.delay(D - 0.6, function() if cr.Parent then TweenService:Create(cr, TweenInfo.new(0.6), { Transparency = 1 }):Play() end end)
			Debris:AddItem(cr, D + 0.2)
		end
		local a = part({ Size = Vector3.new(14, 0.5, 14), Transparency = 1, Position = f + Vector3.new(0, 0.5, 0) })
		local e = Instance.new("ParticleEmitter")
		e.Texture = TEX .. "sparkles_main.dds"; e.Color = seq(P.accent, P.main); e.LightEmission = 1; e.Size = NumberSequence.new(0.4, 0)
		e.Lifetime = NumberRange.new(1.5, 2.5); e.Speed = NumberRange.new(4, 10); e.EmissionDirection = Enum.NormalId.Top; e.SpreadAngle = Vector2.new(20, 20)
		e.Rate = Settings.fxCount(40); e.Parent = a
		task.delay(D, function() e.Enabled = false end)
		Debris:AddItem(a, D + 3)
		flashLight(f + Vector3.new(0, 4, 0), P.main, 50, 3, D)
	elseif t >= 5 then
		-- a void portal under the monster: a spinning disc of violet, lightning to the floor
		local disc = part({ Shape = Enum.PartType.Cylinder, Color = P.dark, Transparency = 0.1, Size = Vector3.new(0.1, 1, 1),
			CFrame = CFrame.new(f + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		local rim = part({ Shape = Enum.PartType.Cylinder, Color = P.main, Transparency = 0.2, Size = Vector3.new(0.08, 1, 1),
			CFrame = CFrame.new(f + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(disc, TweenInfo.new(0.8, Enum.EasingStyle.Back), { Size = Vector3.new(0.1, 16, 16) }):Play()
		TweenService:Create(rim, TweenInfo.new(0.8, Enum.EasingStyle.Back), { Size = Vector3.new(0.08, 17.5, 17.5) }):Play()
		task.delay(D - 0.6, function()
			if disc.Parent then
				TweenService:Create(disc, TweenInfo.new(0.6), { Size = Vector3.new(0.1, 0.5, 0.5), Transparency = 1 }):Play()
				TweenService:Create(rim, TweenInfo.new(0.6), { Size = Vector3.new(0.08, 0.5, 0.5), Transparency = 1 }):Play()
			end
		end)
		Debris:AddItem(disc, D + 0.1); Debris:AddItem(rim, D + 0.1)
		task.spawn(function()
			local t0 = os.clock()
			while os.clock() - t0 < D - 0.5 and model.Parent do
				local a = rng:NextNumber(0, math.pi * 2)
				bolt(root.Position + Vector3.new(0, 3, 0), f + Vector3.new(math.cos(a) * 8, 0.2, math.sin(a) * 8), rng:NextNumber() < 0.5 and P.main or P.accent, 0.2, 0.15)
				task.wait(rng:NextNumber(0.12, 0.3))
			end
		end)
		flashLight(f + Vector3.new(0, 4, 0), P.main, 60, 4, D)
	end
	-- the moment the name card comes up (about two thirds in): one more burst of the map's colours
	task.delay(D * 0.66, function()
		if not model.Parent then return end
		floorRing(f, P.accent, 34, 0.9, 0.3)
		burst(f + Vector3.new(0, 3, 0), seq(P.accent, P.main), 30 * (t - 2), 1, 36, nil, 6, 1)
	end)
end

---------------------------------------------------------------------------------------------- the ambience
local amb: Part? = nil
local ambTier = 0
local function setAmbience(t: number)
	if t == ambTier and (t == 0 or amb ~= nil) then return end
	ambTier = t
	if amb then amb:Destroy(); amb = nil end
	if t == 0 then return end
	local P = PAL[t]
	local box = part({ Size = Vector3.new(70, 20, 70), Transparency = 1 })
	box.Name = "Ambience"
	local function e(props: { [string]: any })
		local pe = Instance.new("ParticleEmitter")
		pe.LightInfluence = 0; pe.Shape = Enum.ParticleEmitterShape.Box; pe.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
		for k, v in props do (pe :: any)[k] = v end
		pe.Parent = box
	end
	if t == 1 then -- fireflies
		e({ Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(C(220, 255, 140)), LightEmission = 1, Size = NumberSequence.new(0.18),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.2), NumberSequenceKeypoint.new(1, 1) }),
			Lifetime = NumberRange.new(3, 5), Speed = NumberRange.new(0.3, 1), SpreadAngle = Vector2.new(180, 180), Rate = Settings.fxCount(5) })
	elseif t == 2 then -- glitter in the air
		e({ Texture = TEX .. "sparkles_main.dds", Color = seq(P.main, P.accent), LightEmission = 1, Size = NumberSequence.new(0.14),
			Transparency = NumberSequence.new(0.2, 1), Lifetime = NumberRange.new(3, 5), Speed = NumberRange.new(0.5, 1.5), Acceleration = Vector3.new(0, -1, 0),
			RotSpeed = NumberRange.new(-200, 200), SpreadAngle = Vector2.new(180, 180), Rate = Settings.fxCount(10) })
	elseif t == 3 then -- drizzle and sea mist
		e({ Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(C(190, 220, 235)), LightEmission = 0.3, Size = NumberSequence.new(0.08),
			Transparency = NumberSequence.new(0.4, 0.8), Lifetime = NumberRange.new(0.7, 1), Speed = NumberRange.new(30, 40), EmissionDirection = Enum.NormalId.Bottom,
			SpreadAngle = Vector2.new(4, 4), Rate = Settings.fxCount(60) })
		e({ Texture = TEX .. "smoke_main.dds", Color = ColorSequence.new(C(120, 160, 170)), Size = NumberSequence.new(6, 10),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.88), NumberSequenceKeypoint.new(1, 1) }),
			Lifetime = NumberRange.new(4, 6), Speed = NumberRange.new(0.5, 1.5), SpreadAngle = Vector2.new(180, 180), Rate = Settings.fxCount(3) })
	elseif t == 4 then -- ash falling, embers rising
		e({ Texture = TEX .. "smoke_main.dds", Color = ColorSequence.new(C(90, 86, 82)), Size = NumberSequence.new(0.22), Transparency = NumberSequence.new(0.3, 0.6),
			Lifetime = NumberRange.new(4, 6), Speed = NumberRange.new(2, 4), EmissionDirection = Enum.NormalId.Bottom, SpreadAngle = Vector2.new(25, 25),
			RotSpeed = NumberRange.new(-120, 120), Rate = Settings.fxCount(22) })
		e({ Texture = TEX .. "sparkles_main.dds", Color = seq(P.accent, P.main), LightEmission = 1, Size = NumberSequence.new(0.16, 0),
			Lifetime = NumberRange.new(2.5, 4), Speed = NumberRange.new(1.5, 3.5), EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(30, 30),
			Rate = Settings.fxCount(10) })
	else -- floating dust in low gravity, glints of stars
		e({ Texture = TEX .. "smoke_main.dds", Color = ColorSequence.new(C(190, 190, 210)), Size = NumberSequence.new(0.18), Transparency = NumberSequence.new(0.4, 0.8),
			Lifetime = NumberRange.new(5, 8), Speed = NumberRange.new(0.2, 0.8), Acceleration = Vector3.new(0, 0.3, 0), SpreadAngle = Vector2.new(180, 180),
			RotSpeed = NumberRange.new(-40, 40), Rate = Settings.fxCount(16) })
		e({ Texture = TEX .. "sparkles_main.dds", Color = seq(P.accent, P.main), LightEmission = 1, Size = NumberSequence.new(0.3, 0),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }),
			Lifetime = NumberRange.new(0.6, 1.2), Speed = NumberRange.new(0, 0.2), SpreadAngle = Vector2.new(180, 180), Rate = Settings.fxCount(8) })
	end
	amb = box
end

---------------------------------------------------------------------------------------------- hooks
-- called by ClientMain for every Fx the server sends (after the normal handler)
function FT.on(kind: string, ...)
	local a = { ... }
	if not lp:GetAttribute("InMatch") then return end
	if kind == "Hit" then onHit(a[1], a[2] or 0, a[4] == true, a[5])
	elseif kind == "ChargedHit" then onCharged(a[1], a[2] or 0, a[3])
	elseif kind == "GhostDeath" then onDeath(a[1])
	elseif kind == "Entrance" then onEntrance(a[1], a[7])
	elseif kind == "WallSlam" or kind == "WallSmash" then
		local t = FT.tier()
		if t >= 3 then burst(a[1], seq(PAL[t].accent, PAL[t].main), 8 * (t - 2), 0.6, 20) end
	end
end

function FT.init(fx: any, hud: any)
	Fx = fx; HUD = hud
	RunService.RenderStepped:Connect(function()
		local inMatch = lp:GetAttribute("InMatch") == true
		local t = FT.tier()
		-- the monster's aura follows the current monster (and the tier)
		local g = workspace:FindFirstChild("Ghost") :: Model?
		if inMatch and g and g:IsA("Model") then
			if g ~= auraOf or t ~= auraTier then buildAura(g, t) end
			-- (gone under the floor / veiled: the aura must not give him away)
			local hidden = g:GetAttribute("Vanish") == true
			if hidden ~= (g:GetAttribute("FxTierHidden") == true) then
				g:SetAttribute("FxTierHidden", hidden)
				for _, d in g:GetDescendants() do
					if d:GetAttribute("FxTierAura") and (d:IsA("ParticleEmitter") or d:IsA("Light")) then (d :: any).Enabled = not hidden end
				end
				for _, sh in orbit do sh.Transparency = hidden and 1 or 0 end
			end
		elseif auraOf then
			clearAura()
		end
		if #orbit > 0 and auraOf then
			local torso = auraOf:FindFirstChild("UpperTorso") :: BasePart?
			if torso then
				local now = os.clock()
				local sc = auraOf:GetScale()
				for i, sh in orbit do
					local ang = now * 1.6 + i / #orbit * math.pi * 2
					local tilt = math.sin(now * 0.7 + i) * 0.5
					sh.CFrame = CFrame.new(torso.Position) * CFrame.Angles(tilt, ang, 0) * CFrame.new(0, 0, -3.6 * sc) * CFrame.Angles(now * 3, now * 2, 0)
				end
			end
		end
		-- the ambience: only in a campaign building's fight
		local st = Campaign.stage(RS:GetAttribute("MapId"))
		setAmbience((inMatch and (st ~= nil or (RunService:IsStudio() and lp:GetAttribute("DebugTier") ~= nil))) and t or 0)
		if amb then amb.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position + Vector3.new(0, 6, 0)) end
	end)
end

return FT
