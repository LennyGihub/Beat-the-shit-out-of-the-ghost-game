--!strict
-- What the Ashen Abbey's monsters' moves look and sound like (Server/AbbeyMonsters sends these Fx). Map 4: the
-- effects are bigger than the earlier maps' (holy fire, hellfire, ash, shockwaves - Client/FxTier):
--   VeilFade (model, t) / VeilStalk (from, victim, t) / VeilPool (spot, t) / VeilStrike (spot, look)   the Nun's veil
--   HymnSing (model, t) / HymnPools (spots, r, t, wave) / HymnBurn (spots, r)                          her hymn
--   HandsDig (model, t) / HandsWave (origin, dir, speed, len, width) / HandsGrab (player, t)            the Gravedigger's hands
--   CoffinHeave (model, t) / CoffinFly (part) / CoffinBurst (spot, r)                                  his coffin
--   BellYank (model, t) / BellShadow (player, t, r) / BellLock (spot, r, t) / BellDrop (spot, r, t) / BellRise (spot, r)
--   TollLift (model, t) / TollSlam (model, center, rings, gap, speed, range)                           the Bell Ringer
-- And on this player: Rung (attribute) = deafened: the sound goes dull, the view wobbles and blurs.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Sfx = require(script.Parent.Sfx)
local Settings = require(script.Parent.Settings)

local AF = {}
local lp = Players.LocalPlayer
local Fx: any = nil
local HUD: any = nil
local TEX = "rbxasset://textures/particles/"
local C = Color3.fromRGB
local TEAR = C(14, 10, 14)
local HOLY = C(255, 236, 170)
local HOLY2 = C(255, 170, 70)
local EARTH = C(76, 62, 46)
local BRONZE = C(196, 146, 64)
local rng = Random.new()

AF.KINDS = { "VeilFade", "VeilStalk", "VeilPool", "VeilStrike", "HymnSing", "HymnPools", "HymnBurn", "HandsDig", "HandsWave", "HandsGrab",
	"CoffinHeave", "CoffinFly", "CoffinBurst", "BellYank", "BellShadow", "BellLock", "BellDrop", "BellRise", "TollLift", "TollSlam" }
local set = {} :: { [string]: boolean }
for _, k in AF.KINDS do set[k] = true end
function AF.handles(kind: string): boolean return set[kind] == true end

local function folder(): Folder
	local f = workspace:FindFirstChild("AbbeyFxLocal") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "AbbeyFxLocal"; nf.Parent = workspace
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
local function burst(pos: Vector3, color: Color3, n: number, size: number, speed: number, texture: string?, up: boolean?, light: number?)
	local a = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = pos })
	local e = Instance.new("ParticleEmitter")
	e.Texture = texture or (TEX .. "sparkles_main.dds"); e.Color = ColorSequence.new(color); e.LightEmission = light or 0.3; e.LightInfluence = 0.3
	e.Size = NumberSequence.new(size, 0); e.Transparency = NumberSequence.new(0.1, 1); e.Lifetime = NumberRange.new(0.5, 1.2)
	e.Speed = NumberRange.new(speed * 0.5, speed); e.SpreadAngle = Vector2.new(up and 35 or 180, up and 35 or 180); e.Acceleration = Vector3.new(0, -30, 0)
	e.EmissionDirection = Enum.NormalId.Top; e.Rate = 0; e.Drag = 1.5; e.Parent = a
	e:Emit(Settings.fxCount(n))
	Debris:AddItem(a, 2.5)
end
-- a flat ring on the floor: grows from r0 to r1 over t, fading
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
local function floorUnder(pos: Vector3): Vector3
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local ex = { folder() }
	for _, p in Players:GetPlayers() do if p.Character then table.insert(ex, p.Character) end end
	local g = workspace:FindFirstChild("Ghost")
	if g then table.insert(ex, g) end
	local af = workspace:FindFirstChild("AbbeyFx")
	if af then table.insert(ex, af) end
	rp.FilterDescendantsInstances = ex
	local r = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -30, 0), rp)
	return r and r.Position or (pos - Vector3.new(0, 3, 0))
end
local function shake(pos: Vector3, amount: number, dist: number)
	if Fx then Fx.shake(amount * near(pos, dist)) end
end

---------------------------------------------------------------------------------------------- the screen: RUNG
local rungUntil = 0
local rungEq: EqualizerSoundEffect? = nil
local rungBlur: BlurEffect? = nil
local function setRung(on: boolean)
	if on then
		rungUntil = os.clock() + 30
		if not rungEq then
			local eq = Instance.new("EqualizerSoundEffect")
			eq.HighGain = -40; eq.MidGain = -18; eq.LowGain = 2; eq.Priority = 5
			eq.Parent = SoundService
			rungEq = eq
		end
		if not rungBlur then
			local b = Instance.new("BlurEffect"); b.Name = "RungBlur"; b.Size = 10; b.Parent = Lighting
			rungBlur = b
		end
		Sfx.play("BellToll", { Volume = 0.35, PlaybackSpeed = 1.6 })
	else
		rungUntil = 0
		if rungEq then rungEq:Destroy(); rungEq = nil end
		if rungBlur then
			local b = rungBlur
			rungBlur = nil
			TweenService:Create(b, TweenInfo.new(0.5), { Size = 0 }):Play()
			Debris:AddItem(b, 0.6)
		end
	end
end

---------------------------------------------------------------------------------------------- the Weeping Nun
local function veilStalk(from: Vector3, who: Player?, t: number)
	-- black tears fall on the floor, one after another, from where she vanished toward you
	local t0 = os.clock()
	local last = from
	local n = 0
	task.spawn(function()
		while os.clock() - t0 < t do
			local h = hrpOf(who)
			if not h then break end
			local k = (os.clock() - t0) / t
			local goal = floorUnder(h.Position)
			local p = last:Lerp(goal, math.clamp(0.18 + k * 0.2, 0, 1))
			p = floorUnder(p + Vector3.new(rng:NextNumber(-0.6, 0.6), 1, rng:NextNumber(-0.6, 0.6)))
			last = p
			n += 1
			local drop = part({ Shape = Enum.PartType.Cylinder, Color = TEAR, Material = Enum.Material.Glass, Transparency = 0.15,
				Size = Vector3.new(0.06, 0.2, 0.2), CFrame = CFrame.new(p + Vector3.new(0, 0.06, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
			local sz = rng:NextNumber(1.2, 2.2)
			TweenService:Create(drop, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Size = Vector3.new(0.06, sz, sz) }):Play()
			task.delay(4, function() if drop.Parent then TweenService:Create(drop, TweenInfo.new(1.5), { Transparency = 1 }):Play() end end)
			Debris:AddItem(drop, 6)
			-- a falling drop above it
			local fall = part({ Shape = Enum.PartType.Ball, Color = TEAR, Material = Enum.Material.Glass, Size = Vector3.new(0.3, 0.5, 0.3), Position = p + Vector3.new(0, 6, 0) })
			TweenService:Create(fall, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = p }):Play()
			Debris:AddItem(fall, 0.32)
			if n % 2 == 0 then Sfx.at("Bubbles", p, { Volume = 0.35, PlaybackSpeed = 2.2 }) end
			if n % 3 == 0 then Sfx.at("GhostWhisper", p, { Volume = 0.4, PlaybackSpeed = 0.8 }) end
			task.wait(0.16)
		end
	end)
end
local function veilPool(spot: Vector3, t: number)
	local pool = part({ Shape = Enum.PartType.Cylinder, Color = C(4, 2, 6), Size = Vector3.new(0.08, 0.5, 0.5),
		CFrame = CFrame.new(spot + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(pool, TweenInfo.new(t, Enum.EasingStyle.Quad), { Size = Vector3.new(0.08, 7, 7) }):Play()
	local rim = ring(spot, C(150, 140, 200), 0.5, 4, t, 0.4)
	local _ = rim
	Debris:AddItem(pool, t + 1.6)
	task.delay(t + 0.2, function() if pool.Parent then TweenService:Create(pool, TweenInfo.new(1.2), { Transparency = 1 }):Play() end end)
	-- black hands of mist come up round it
	local a = part({ Size = Vector3.new(5, 0.2, 5), Transparency = 1, Position = spot + Vector3.new(0, 0.3, 0) })
	local e = Instance.new("ParticleEmitter")
	e.Texture = TEX .. "smoke_main.dds"; e.Color = ColorSequence.new(C(10, 6, 14)); e.Size = NumberSequence.new(1.5, 4); e.Transparency = NumberSequence.new(0.3, 1)
	e.Lifetime = NumberRange.new(0.6, 1.1); e.Speed = NumberRange.new(4, 9); e.SpreadAngle = Vector2.new(15, 15); e.Rate = Settings.fxCount(60); e.Parent = a
	task.delay(t, function() e.Enabled = false end)
	Debris:AddItem(a, t + 1.5)
	Sfx.at(Sfx.voice("WindUp", "Nun"), spot, { Volume = 1.2 })
	Sfx.at("GhostWhisper", spot, { Volume = 1.2, PlaybackSpeed = 0.6 })
	if (workspace.CurrentCamera.CFrame.Position - spot).Magnitude < 10 and HUD then HUD.flash(C(20, 0, 30), 0.25) end
end
local function veilStrike(spot: Vector3, look: Vector3)
	burst(spot + Vector3.new(0, 3, 0), C(20, 14, 26), 60, 2.4, 22, TEX .. "smoke_main.dds")
	burst(spot + Vector3.new(0, 3, 0), C(230, 225, 255), 30, 0.8, 26, nil, false, 1)
	ring(spot, C(200, 190, 255), 1, 14, 0.5, 0.2, 0.3)
	ring(spot, Color3.new(1, 1, 1), 1, 8, 0.35, 0.1)
	-- three claw streaks through the air in front of her
	for i = -1, 1 do
		local cf = CFrame.lookAt(spot + Vector3.new(0, 4 + i * 0.6, 0), spot + Vector3.new(0, 4 + i * 0.6, 0) + look) * CFrame.new(i * 0.9, 0, -3) * CFrame.Angles(0, 0, 0.7)
		local s = part({ Material = Enum.Material.Neon, Color = C(220, 210, 255), Size = Vector3.new(0.15, 4.5, 0.15), CFrame = cf })
		TweenService:Create(s, TweenInfo.new(0.3), { Transparency = 1, Size = Vector3.new(0.05, 6, 0.05) }):Play()
		Debris:AddItem(s, 0.35)
	end
	flashLight(spot + Vector3.new(0, 4, 0), C(200, 190, 255), 30, 6, 0.6)
	Sfx.at(Sfx.voice("Spawn", "Nun"), spot, { Volume = 1.4 })
	Sfx.at("Whoosh", spot, { Volume = 1.2, PlaybackSpeed = 0.7 })
	shake(spot, 0.8, 50)
end

local function hymnSing(m: Model?, t: number)
	local h = hrpOf(m)
	if not h then return end
	Sfx.at("Choir", h.Position, { Volume = 1.3 })
	Sfx.at(Sfx.voice("WindUp", "Nun"), h.Position, { Volume = 1, PlaybackSpeed = 1.2 })
	-- a halo of candle flames round her, rising light
	local ring0 = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = HOLY, Transparency = 0.3,
		Size = Vector3.new(0.2, 3, 3), CFrame = CFrame.new(h.Position + Vector3.new(0, 4.6, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(ring0, TweenInfo.new(t + 3.5), { Size = Vector3.new(0.2, 5, 5), Transparency = 1 }):Play()
	Debris:AddItem(ring0, t + 3.6)
	burst(h.Position + Vector3.new(0, 3, 0), HOLY, 40, 0.7, 10, nil, true, 1)
	flashLight(h.Position + Vector3.new(0, 5, 0), HOLY, 40, 3, t + 3)
end
local function hymnPools(spots: { Vector3 }, r: number, t: number, wave: number)
	-- a shaft of window light falls on each pool: coloured glass light, brightening until it burns
	local cols = { C(255, 210, 120), C(200, 120, 255), C(120, 190, 255), C(255, 120, 120) }
	for i, s in spots do
		local col = cols[((i + wave) % #cols) + 1]
		local pool = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = col, Transparency = 0.75,
			Size = Vector3.new(0.12, r * 2, r * 2), CFrame = CFrame.new(s + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(pool, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 0.2 }):Play()
		Debris:AddItem(pool, t + 0.05)
		-- the shaft from above (a slanted column, like through a high window)
		local top = s + Vector3.new(6, 26, 4)
		local shaft = part({ Material = Enum.Material.Neon, Color = col, Transparency = 0.92, Size = Vector3.new(r * 1.6, r * 1.6, (top - s).Magnitude),
			CFrame = CFrame.lookAt((s + top) / 2, top) })
		TweenService:Create(shaft, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 0.7 }):Play()
		Debris:AddItem(shaft, t + 0.05)
		-- a cross marked in the pool
		for _, rot in { 0, math.pi / 2 } do
			local cr = part({ Material = Enum.Material.Neon, Color = Color3.new(1, 1, 1), Transparency = 0.6, Size = Vector3.new(0.4, 0.05, r * 1.4),
				CFrame = CFrame.new(s + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, rot, 0) })
			Debris:AddItem(cr, t)
		end
	end
	if #spots > 0 then Sfx.at("Choir", spots[1], { Volume = 0.6, PlaybackSpeed = 1 + wave * 0.12 }) end
end
local function hymnBurn(spots: { Vector3 }, r: number)
	for _, s in spots do
		-- a column of holy fire
		local col = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = HOLY, Transparency = 0.1,
			Size = Vector3.new(2, r * 1.6, r * 1.6), CFrame = CFrame.new(s + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
		TweenService:Create(col, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(30, r * 0.4, r * 0.4),
			CFrame = CFrame.new(s + Vector3.new(0, 15, 0)) * CFrame.Angles(0, 0, math.pi / 2), Transparency = 1 }):Play()
		Debris:AddItem(col, 0.6)
		burst(s + Vector3.new(0, 0.5, 0), HOLY2, 30, 1.6, 26, TEX .. "fire_main.dds", true, 1)
		burst(s + Vector3.new(0, 0.5, 0), HOLY, 24, 0.6, 20, nil, false, 1)
		ring(s, HOLY, 1, r + 3, 0.45, 0.15, 0.25)
		flashLight(s + Vector3.new(0, 3, 0), HOLY, 26, 5, 0.5)
	end
	if #spots > 0 then
		Sfx.at("Flamethrower", spots[1], { Volume = 1, PlaybackSpeed = 1.3 })
		Sfx.at("MagicBurst", spots[1], { Volume = 1, PlaybackSpeed = 0.8 })
		shake(spots[1], 0.5, 60)
	end
end

---------------------------------------------------------------------------------------------- the Gravedigger
local function handsWave(origin: Vector3, dir: Vector3, speed: number, len: number, width: number)
	Sfx.at("ShovelDig", origin, { Volume = 1.4 })
	Sfx.at(Sfx.voice("WindUp", "Gravedigger"), origin, { Volume = 1.2 })
	local right = Vector3.new(-dir.Z, 0, dir.X)
	local n = math.floor(len / 2.4)
	for i = 1, n do
		local d = i * 2.4
		task.delay(d / speed, function()
			local base = floorUnder(origin + dir * d + right * rng:NextNumber(-width / 2, width / 2) + Vector3.new(0, 2, 0))
			-- a crack, a spray of dirt, and a bony hand clawing up out of it
			local crack = part({ Color = C(8, 6, 6), Size = Vector3.new(width, 0.06, 1.8), CFrame = CFrame.lookAt(base + Vector3.new(0, 0.05, 0), base + Vector3.new(0, 0.05, 0) + dir) })
			Debris:AddItem(crack, 2.4)
			task.delay(1.6, function() if crack.Parent then TweenService:Create(crack, TweenInfo.new(0.7), { Transparency = 1 }):Play() end end)
			burst(base + Vector3.new(0, 0.4, 0), EARTH, 10, 1.1, 16, TEX .. "smoke_main.dds", true)
			for _, side in { -1, 1 } do
				local hb = base + right * side * rng:NextNumber(0.4, width / 2 - 0.3)
				local arm = part({ Color = C(214, 204, 176), Size = Vector3.new(0.35, 2.6, 0.35), CFrame = CFrame.new(hb - Vector3.new(0, 1.3, 0)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), 0, rng:NextNumber(-0.3, 0.3)) })
				local hand = part({ Color = C(214, 204, 176), Size = Vector3.new(0.8, 0.7, 0.35), CFrame = arm.CFrame * CFrame.new(0, 1.5, 0) })
				TweenService:Create(arm, TweenInfo.new(0.18, Enum.EasingStyle.Back), { CFrame = arm.CFrame + Vector3.new(0, 2.4, 0) }):Play()
				TweenService:Create(hand, TweenInfo.new(0.18, Enum.EasingStyle.Back), { CFrame = hand.CFrame + Vector3.new(0, 2.4, 0) }):Play()
				task.delay(0.9, function()
					if arm.Parent then
						TweenService:Create(arm, TweenInfo.new(0.5), { CFrame = arm.CFrame - Vector3.new(0, 2.6, 0) }):Play()
						TweenService:Create(hand, TweenInfo.new(0.5), { CFrame = hand.CFrame - Vector3.new(0, 2.6, 0) }):Play()
					end
				end)
				Debris:AddItem(arm, 1.5); Debris:AddItem(hand, 1.5)
			end
			if i % 3 == 0 then Sfx.at("BoneRattle", base, { Volume = 0.9, PlaybackSpeed = rng:NextNumber(0.9, 1.2) }) end
			if i % 2 == 0 then shake(base, 0.12, 30) end
		end)
	end
	local _ = dir
end
local function handsGrab(who: Player?, t: number)
	local h = hrpOf(who)
	if not h then return end
	local f = floorUnder(h.Position)
	Sfx.at("BoneRattle", f, { Volume = 1.3 })
	Sfx.at(Sfx.voice("Claw", "Gravedigger"), f, { Volume = 1 })
	burst(f + Vector3.new(0, 0.5, 0), EARTH, 30, 1.4, 14, TEX .. "smoke_main.dds", true)
	-- four hands round the ankles while held
	local hands = {}
	for k = 0, 3 do
		local a = k * math.pi / 2 + 0.4
		local hb = f + Vector3.new(math.cos(a), 0, math.sin(a)) * 1.1
		local arm = part({ Color = C(214, 204, 176), Size = Vector3.new(0.35, 2.2, 0.35), CFrame = CFrame.lookAt(hb, f + Vector3.new(0, 2.5, 0)) * CFrame.Angles(-math.pi / 2, 0, 0) })
		table.insert(hands, arm)
		Debris:AddItem(arm, t + 0.2)
	end
	if who == lp and HUD then HUD.flash(C(60, 40, 20), 0.3); HUD.toast("THE DEAD HAVE YOU", false) end
end
local function coffinFly(pr: BasePart?)
	if not pr then return end
	-- the coffin drawn on the server's flying part: lid, cross, handles
	local lid = part({ Color = C(50, 30, 20), Material = Enum.Material.WoodPlanks, Size = Vector3.new(2.8, 0.3, 6.4) })
	local cross1 = part({ Color = C(200, 170, 90), Material = Enum.Material.Metal, Size = Vector3.new(0.3, 0.08, 2.4) })
	local cross2 = part({ Color = C(200, 170, 90), Material = Enum.Material.Metal, Size = Vector3.new(1.4, 0.08, 0.3) })
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		if not pr.Parent then c:Disconnect(); lid:Destroy(); cross1:Destroy(); cross2:Destroy(); return end
		lid.CFrame = pr.CFrame * CFrame.new(0, 0.85, 0)
		cross1.CFrame = pr.CFrame * CFrame.new(0, 1.05, -0.8)
		cross2.CFrame = pr.CFrame * CFrame.new(0, 1.05, -1.4)
	end)
	Sfx.at("Whoosh", pr.Position, { Volume = 1.3, PlaybackSpeed = 0.5 })
	Sfx.at("CoffinCreak", pr.Position, { Volume = 1 })
end
local function coffinBurst(spot: Vector3, r: number)
	Sfx.at("WoodBreak", spot, { Volume = 1.5, PlaybackSpeed = 0.7 })
	Sfx.at("Crash", spot, { Volume = 1.2 })
	Sfx.at("BoneRattle", spot, { Volume = 1.3, PlaybackSpeed = 0.8 })
	burst(spot + Vector3.new(0, 1, 0), EARTH, 60, 2.2, 30, TEX .. "smoke_main.dds", true)
	burst(spot + Vector3.new(0, 1, 0), C(150, 255, 120), 30, 0.8, 18, nil, false, 1) -- grave light
	ring(spot, C(150, 255, 120), 1, r + 4, 0.55, 0.25, 0.3)
	ring(spot, EARTH, 1, r + 2, 0.7, 0.2, 0.6)
	flashLight(spot + Vector3.new(0, 2, 0), C(150, 255, 120), 34, 5, 0.9)
	-- the planks fly apart
	for _ = 1, Settings.fxCount(10) do
		local p = part({ Color = C(60, 38, 26), Material = Enum.Material.WoodPlanks, Size = Vector3.new(rng:NextNumber(0.4, 0.8), 0.25, rng:NextNumber(1.5, 3.5)),
			CFrame = CFrame.new(spot + Vector3.new(rng:NextNumber(-1, 1), 1.2, rng:NextNumber(-1, 1))) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0) })
		p.Anchored = false; p.CanCollide = true; p.CollisionGroup = "Debris"
		local a = rng:NextNumber(0, math.pi * 2)
		p.AssemblyLinearVelocity = Vector3.new(math.cos(a) * 22, rng:NextNumber(14, 30), math.sin(a) * 22)
		p.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-10, 10), rng:NextNumber(-10, 10), rng:NextNumber(-10, 10))
		Debris:AddItem(p, 3)
	end
	shake(spot, 0.9, 60)
end

---------------------------------------------------------------------------------------------- the Bell Ringer
-- a great bronze bell (local model) and how to place it
local function bellModel(r: number): (Model, (cf: CFrame) -> ())
	local m = Instance.new("Model"); m.Name = "Bell"; m.Parent = folder()
	local parts = {} :: { { p: BasePart, rel: CFrame } }
	local function add(size: Vector3, rel: CFrame, color: Color3, shape: Enum.PartType?, mat: Enum.Material?)
		local p = part({ Size = size, Color = color, Material = mat or Enum.Material.Metal })
		if shape then p.Shape = shape end
		p.CastShadow = true
		p.Parent = m
		table.insert(parts, { p = p, rel = rel })
	end
	-- stacked rings, wide at the lip, narrow at the crown (a blocky bell)
	local rows = { { 1.0, 0.9 }, { 0.9, 1.6 }, { 0.78, 1.6 }, { 0.68, 1.6 }, { 0.6, 1.2 } }
	local y = 0
	for _, row in rows do
		add(Vector3.new(row[2], r * 2 * row[1], r * 2 * row[1]), CFrame.new(0, y + row[2] / 2, 0) * CFrame.Angles(0, 0, math.pi / 2), BRONZE, Enum.PartType.Cylinder)
		y += row[2]
	end
	add(Vector3.new(0.8, r * 1.05, r * 1.05), CFrame.new(0, y + 0.4, 0) * CFrame.Angles(0, 0, math.pi / 2), BRONZE:Lerp(Color3.new(0, 0, 0), 0.2), Enum.PartType.Cylinder)
	add(Vector3.new(1.2, 1.4, 0.5), CFrame.new(0, y + 1.4, 0), C(40, 36, 30))
	add(Vector3.new(0.4, r * 2 * 1.02, r * 2 * 1.02), CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.pi / 2), C(150, 100, 40), Enum.PartType.Cylinder) -- the lip's band
	return m, function(cf: CFrame) for _, x in parts do x.p.CFrame = cf * x.rel end end
end
local bells = {} :: { [string]: { m: Model, place: (cf: CFrame) -> (), spot: Vector3 } }
local function key(v: Vector3): string return string.format("%d_%d", math.floor(v.X + 0.5), math.floor(v.Z + 0.5)) end
local function bellShadow(who: Player?, t: number, r: number)
	local sh = part({ Shape = Enum.PartType.Cylinder, Color = C(10, 8, 6), Transparency = 0.45, Size = Vector3.new(0.08, r * 2, r * 2) })
	local edge = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = C(255, 80, 40), Transparency = 0.55, Size = Vector3.new(0.06, r * 2 + 0.6, r * 2 + 0.6) })
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.Heartbeat:Connect(function()
		local h = hrpOf(who)
		if os.clock() - t0 > t or not h then c:Disconnect(); sh:Destroy(); edge:Destroy(); return end
		local f = floorUnder(h.Position)
		local w = 1 + math.sin(os.clock() * 14) * 0.04
		sh.CFrame = CFrame.new(f + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		edge.CFrame = CFrame.new(f + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		edge.Size = Vector3.new(0.06, (r * 2 + 0.6) * w, (r * 2 + 0.6) * w)
	end)
	Sfx.play("HandBell", { Volume = 0.8 })
end
local function bellLock(spot: Vector3, r: number, t: number)
	local w = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = C(255, 50, 30), Transparency = 0.3,
		Size = Vector3.new(0.12, r * 2 + 0.6, r * 2 + 0.6), CFrame = CFrame.new(spot + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(w, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.75 }):Play()
	Debris:AddItem(w, t + 0.1)
	-- the bell is already falling from the dark above
	local m, place = bellModel(r)
	local top = spot + Vector3.new(0, 34, 0)
	place(CFrame.new(top))
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		local k = math.clamp((os.clock() - t0) / t, 0, 1)
		if not m.Parent then c:Disconnect(); return end
		place(CFrame.new(top:Lerp(spot, k * k)) * CFrame.Angles(0, os.clock() * 0.4, 0))
		if k >= 1 then c:Disconnect() end
	end)
	bells[key(spot)] = { m = m, place = place, spot = spot }
	Sfx.at("Whoosh", spot + Vector3.new(0, 10, 0), { Volume = 1.4, PlaybackSpeed = 0.4 })
end
local function bellDrop(spot: Vector3, r: number, t: number)
	local b = bells[key(spot)]
	if b then b.place(CFrame.new(spot)) end
	Sfx.at("BellToll", spot, { Volume = 1.8 })
	Sfx.at("Crash", spot, { Volume = 1.3, PlaybackSpeed = 0.7 })
	burst(spot + Vector3.new(0, 0.5, 0), C(170, 150, 120), 70, 2.4, 30, TEX .. "smoke_main.dds")
	burst(spot + Vector3.new(0, 1, 0), BRONZE, 30, 0.6, 30, nil, false, 1)
	for i = 0, 2 do
		task.delay(i * 0.12, function() ring(spot, i == 0 and Color3.new(1, 1, 1) or BRONZE, r, r + 18 + i * 6, 0.7, 0.2, 0.35) end)
	end
	flashLight(spot + Vector3.new(0, 3, 0), C(255, 200, 120), 40, 6, 0.6)
	shake(spot, 1.2, 70)
	-- while it rings: it shudders
	if b then
		local t0 = os.clock()
		local c: RBXScriptConnection
		c = RunService.RenderStepped:Connect(function()
			local k = os.clock() - t0
			if k > t or not b.m.Parent then c:Disconnect(); return end
			local s = math.sin(k * 60) * 0.03 * (1 - k / t)
			b.place(CFrame.new(spot) * CFrame.Angles(s, 0, s * 0.7))
		end)
	end
	local _ = t
end
local function bellRise(spot: Vector3, r: number)
	local b = bells[key(spot)]
	bells[key(spot)] = nil
	if not b then return end
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		local k = (os.clock() - t0) / 1.2
		if k > 1 or not b.m.Parent then c:Disconnect(); b.m:Destroy(); return end
		b.place(CFrame.new(spot + Vector3.new(0, 34 * k * k, 0)))
	end)
	burst(spot + Vector3.new(0, 0.5, 0), C(170, 150, 120), 20, 1.6, 10, TEX .. "smoke_main.dds")
	local _ = r
end
local function tollSlam(m: Model?, center: Vector3, rings: number, gap: number, speed: number, range: number)
	local life = range / speed
	for i = 0, rings - 1 do
		task.delay(i * gap, function()
			Sfx.at("BellToll", center, { Volume = 1.6 - i * 0.2, PlaybackSpeed = 1 - i * 0.08 })
			shake(center, 0.7, 70)
			flashLight(center + Vector3.new(0, 3, 0), C(255, 200, 120), 50, 5, 0.5)
			burst(center + Vector3.new(0, 1, 0), C(170, 150, 120), 40, 2, 26, TEX .. "smoke_main.dds")
			-- the ring of sound: a bronze wall low on the floor (jump it) + a white shimmer above it
			local wall = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = BRONZE, Transparency = 0.25,
				Size = Vector3.new(1.6, 2, 2), CFrame = CFrame.new(center + Vector3.new(0, 0.8, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
			local hole = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.SmoothPlastic, Color = C(10, 8, 6), Transparency = 0.6,
				Size = Vector3.new(0.05, 1, 1), CFrame = CFrame.new(center + Vector3.new(0, 0.06, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
			local t0 = os.clock()
			local c: RBXScriptConnection
			c = RunService.RenderStepped:Connect(function()
				local k = (os.clock() - t0) / life
				if k > 1 then c:Disconnect(); wall:Destroy(); hole:Destroy(); return end
				local rr = math.max(0.5, k * range)
				wall.Size = Vector3.new(1.6, rr * 2, rr * 2)
				wall.Transparency = 0.25 + 0.7 * k
				hole.Size = Vector3.new(0.05, rr * 2 - 0.5, rr * 2 - 0.5)
			end)
		end)
	end
	local _ = m
end

---------------------------------------------------------------------------------------------- dispatch
function AF.handle(kind: string, ...)
	local a = table.pack(...)
	if kind == "VeilFade" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at(Sfx.voice("WindUp", "Nun"), h.Position, { Volume = 1.1 })
			Sfx.at("GhostWhisper", h.Position, { Volume = 1, PlaybackSpeed = 0.7 })
			burst(h.Position + Vector3.new(0, 1, 0), C(16, 10, 20), 50, 2.5, 6, TEX .. "smoke_main.dds", true)
			burst(h.Position + Vector3.new(0, 3, 0), C(220, 220, 240), 20, 0.5, 4, nil, true, 1)
		end
	elseif kind == "VeilStalk" then
		veilStalk(a[1], a[2], a[3])
	elseif kind == "VeilPool" then
		veilPool(a[1], a[2])
	elseif kind == "VeilStrike" then
		veilStrike(a[1], a[2])
	elseif kind == "HymnSing" then
		hymnSing(a[1], a[2])
	elseif kind == "HymnPools" then
		hymnPools(a[1], a[2], a[3], a[4])
	elseif kind == "HymnBurn" then
		hymnBurn(a[1], a[2])
	elseif kind == "HandsDig" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at("ShovelDig", h.Position, { Volume = 1.2 })
			burst(floorUnder(h.Position + h.CFrame.LookVector * 3), EARTH, 20, 1.2, 10, TEX .. "smoke_main.dds", true)
		end
	elseif kind == "HandsWave" then
		handsWave(a[1], a[2], a[3], a[4], a[5])
	elseif kind == "HandsGrab" then
		handsGrab(a[1], a[2])
	elseif kind == "CoffinHeave" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at(Sfx.voice("WindUp", "Gravedigger"), h.Position, { Volume = 1.2 })
			Sfx.at("CoffinCreak", h.Position, { Volume = 1 })
		end
	elseif kind == "CoffinFly" then
		coffinFly(a[1])
	elseif kind == "CoffinBurst" then
		coffinBurst(a[1], a[2])
	elseif kind == "BellYank" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at(Sfx.voice("WindUp", "Ringer"), h.Position, { Volume = 1.3 })
			Sfx.at("ShieldBlock", h.Position, { Volume = 0.6, PlaybackSpeed = 0.5 })
		end
	elseif kind == "BellShadow" then
		bellShadow(a[1], a[2], a[3])
	elseif kind == "BellLock" then
		bellLock(a[1], a[2], a[3])
	elseif kind == "BellDrop" then
		bellDrop(a[1], a[2], a[3])
	elseif kind == "BellRise" then
		bellRise(a[1], a[2])
	elseif kind == "TollLift" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at(Sfx.voice("WindUp", "Ringer"), h.Position, { Volume = 1.3, PlaybackSpeed = 0.9 })
			Sfx.at("HandBell", h.Position, { Volume = 1 })
		end
	elseif kind == "TollSlam" then
		tollSlam(a[1], a[2], a[3], a[4], a[5], a[6])
	end
end

function AF.init(fx: any, hud: any?)
	Fx = fx; HUD = hud
	lp:GetAttributeChangedSignal("Rung"):Connect(function() setRung(lp:GetAttribute("Rung") == true) end)
	-- the deafened view wobbles
	RunService.RenderStepped:Connect(function()
		if rungUntil > 0 and rungBlur then
			rungBlur.Size = 8 + math.sin(os.clock() * 9) * 4
		end
	end)
	lp:GetAttributeChangedSignal("InMatch"):Connect(function()
		if not lp:GetAttribute("InMatch") then
			setRung(false)
			for k, b in bells do b.m:Destroy(); bells[k] = nil end
		end
	end)
end

return AF
