--!strict
-- What the Moonlight Carnival's monsters' moves look and sound like (Server/CarnivalMonsters sends these Fx):
--   ClownHide (model) / CrateRattle (spots, real, t) / CratePop (spot, radius)   Pop the Clown's jack-in-the-box
--   ClownBlow (model, t)                    he blows up his balloon copies (Abilities' clones, kind "balloon")
--   StrongGrunt (model) / StrongLift (model, obj) / StrongThrow (model)          the Strongman's bench throw
--   SlamWarn (spot, radius, t) / Shockwave (spot, radius, t)                     his leap and the ring on the floor
--   CurseWind (model, t) / CurseOrb (part) / CurseHit (pos) / CurseFizzle (pos)  Madame Fortune's curse
--   CardsWind (model, t) / CardsThrow (pos)                                      her tarot cards
--   BallSmash (pos) / BallReform (pos)                                           her crystal ball
--   WhipLine (origin, dir, len, t) / WhipCrack (model, from, dir, len)           the Ringmaster's lash
--   WhipCrackUp (model, t) / CrowdCheer (pos)                                    the mannequins come alive
-- And THE CURSE on this player (player attribute Cursed, set by the server): the screen blurs and goes violet, and
-- the walking controls are reversed (the move keys / left stick are taken from Roblox's controls and the body is
-- moved the other way). Phones keep their controls (only the blur).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local Sfx = require(script.Parent.Sfx)

local CF = {}
local lp = Players.LocalPlayer
local Fx: any = nil

CF.KINDS = { "ClownHide", "CrateRattle", "CratePop", "ClownBlow", "StrongGrunt", "StrongLift", "StrongThrow", "SlamWarn", "Shockwave",
	"CurseWind", "CurseOrb", "CurseHit", "CurseFizzle", "CardsWind", "CardsThrow", "BallSmash", "BallReform", "WhipLine", "WhipCrack",
	"WhipCrackUp", "CrowdCheer" }
local set = {} :: { [string]: boolean }
for _, k in CF.KINDS do set[k] = true end
function CF.handles(kind: string): boolean return set[kind] == true end

local function folder(): Folder
	local f = workspace:FindFirstChild("CarnivalFxLocal") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "CarnivalFxLocal"; nf.Parent = workspace
		f = nf
	end
	return f :: Folder
end
local function part(props: { [string]: any }): BasePart
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do (p :: any)[k] = v end
	p.Parent = folder()
	return p
end
local function near(pos: Vector3, dist: number): number
	local d = (workspace.CurrentCamera.CFrame.Position - pos).Magnitude
	return d < dist and (1 - d / dist) or 0
end
local function shakeNear(pos: Vector3, dist: number, amount: number)
	local k = near(pos, dist)
	if Fx and k > 0 then Fx.shake(amount * k) end
end
local function burst(pos: Vector3, color: Color3, n: number, size: number, speed: number, texture: string?, light: number?)
	local p = part({ Transparency = 1, Size = Vector3.one, Position = pos })
	local e = Instance.new("ParticleEmitter")
	e.Texture = texture or "rbxasset://textures/particles/smoke_main.dds"
	e.Color = ColorSequence.new(color)
	e.LightEmission = light or 0
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, size * 2) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = NumberRange.new(0.6, 1.2); e.Rate = 0; e.Speed = NumberRange.new(speed * 0.5, speed); e.SpreadAngle = Vector2.new(180, 60)
	e.Parent = p
	e:Emit(n)
	Debris:AddItem(p, 2)
end
local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
local function hrpOf(m: Model?): BasePart? return m and m:FindFirstChild("HumanoidRootPart") :: BasePart? end
local function ring(spot: Vector3, color: Color3, r0: number, r1: number, t: number, thick: number?)
	local p = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(thick or 0.15, r0 * 2, r0 * 2), Color = color, Material = Enum.Material.Neon,
		Transparency = 0.3, CFrame = CFrame.new(spot + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(p, TweenInfo.new(t, Enum.EasingStyle.Linear), { Size = Vector3.new(thick or 0.15, r1 * 2, r1 * 2), Transparency = 0.85 }):Play()
	Debris:AddItem(p, t + 0.05)
	return p
end

-- POP THE CLOWN ------------------------------------------------------------------------------------------------
-- the crates rattle: the building's crate parts (PopCrates) shake on this screen; with no crate there, one is put down
local function crateRattle(spots: { Vector3 }, real: number, t: number)
	local live = workspace:FindFirstChild("Mansion")
	local f = live and live:FindFirstChild("PopCrates")
	for i, spot in spots do
		local crate: BasePart? = nil
		if f then
			for _, c in f:GetChildren() do
				if c:IsA("BasePart") and (c.Position - spot).Magnitude < 0.5 then crate = c end
			end
		end
		local temp = false
		if not crate then
			crate = part({ Size = Vector3.new(3.4, 3, 3.4), Position = spot, Color = Color3.fromRGB(150, 110, 70), Material = Enum.Material.WoodPlanks })
			temp = true
		end
		local c = crate :: BasePart
		local home = c.CFrame
		local hard = i == real and 1 or 0.55
		local t0 = os.clock()
		local conn: RBXScriptConnection
		conn = RunService.RenderStepped:Connect(function()
			local tt = os.clock() - t0
			if tt > t or not c.Parent then
				conn:Disconnect()
				if c.Parent then c.CFrame = home end
				if temp then c:Destroy() end
				return
			end
			local k = hard * math.clamp(tt / t, 0.3, 1)
			c.CFrame = home * CFrame.new(math.sin(tt * 47) * 0.12 * k, math.abs(math.sin(tt * 31)) * 0.25 * k, 0) * CFrame.Angles(0, 0, math.sin(tt * 39) * 0.06 * k)
		end)
		task.delay(i * 0.25, function() Sfx.at("WoodBreak", spot, { Volume = 0.35, PlaybackSpeed = 1.6 + i * 0.1 }) end)
	end
	Sfx.at("EvilLaugh", spots[real] or spots[1], { Volume = 0.5, PlaybackSpeed = 1.35 })
end
local function cratePop(spot: Vector3, radius: number)
	burst(spot + Vector3.new(0, 2, 0), Color3.fromRGB(150, 110, 70), 16, 1.2, 18)
	for _, col in { Color3.fromRGB(255, 80, 90), Color3.fromRGB(80, 160, 255), Color3.fromRGB(255, 220, 80) } do
		burst(spot + Vector3.new(0, 3, 0), col, 14, 0.3, 24, SPARK, 0.4)
	end
	ring(spot, Color3.fromRGB(255, 200, 80), 1, radius, 0.4)
	Sfx.at("MagicBurst", spot, { Volume = 1, PlaybackSpeed = 1.1 })
	Sfx.at("WoodBreak", spot, { Volume = 1, PlaybackSpeed = 0.9 })
	Sfx.at("EvilLaugh", spot, { Volume = 1, PlaybackSpeed = 1.25 })
	shakeNear(spot, 50, 0.6)
end

-- THE STRONGMAN -------------------------------------------------------------------------------------------------
local function slamWarn(spot: Vector3, radius: number, t: number)
	local r = ring(spot, Color3.fromRGB(230, 40, 30), 4, 4, t, 0.18)
	r.Transparency = 0.4
	local core = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, 1, 1), Color = Color3.fromRGB(255, 80, 50), Material = Enum.Material.Neon,
		Transparency = 0.3, CFrame = CFrame.new(spot + Vector3.new(0, 0.14, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(core, TweenInfo.new(t, Enum.EasingStyle.Linear), { Size = Vector3.new(0.2, 8, 8) }):Play()
	Debris:AddItem(core, t + 0.1)
	local _ = radius
end
-- the shockwave: a ring of dust and cracked floor rolling out to `radius` in t seconds (its height = jump over it)
local function shockwave(spot: Vector3, radius: number, t: number)
	local wall = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.2, 4, 4), Color = Color3.fromRGB(200, 170, 120), Material = Enum.Material.Neon,
		Transparency = 0.45, CFrame = CFrame.new(spot + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	local inner = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.3, 2, 2), Color = Color3.fromRGB(30, 26, 22), Material = Enum.Material.SmoothPlastic,
		Transparency = 1, CFrame = wall.CFrame })
	local t0 = os.clock()
	local conn: RBXScriptConnection
	conn = RunService.RenderStepped:Connect(function()
		local u = (os.clock() - t0) / t
		if u >= 1 then conn:Disconnect(); wall:Destroy(); inner:Destroy(); return end
		local r = math.max(1, u * radius)
		wall.Size = Vector3.new(1.4, r * 2 + 1.2, r * 2 + 1.2)
		wall.Transparency = 0.45 + u * 0.5
		inner.Size = Vector3.new(1.42, r * 2 - 1.6, r * 2 - 1.6)
	end)
	-- (the inside of the ring is drawn as a gap: only the band shows)
	inner.Transparency = 1
	burst(spot + Vector3.new(0, 1, 0), Color3.fromRGB(140, 120, 96), 40, 2.4, 28)
	Sfx.at("HeavyImpact", spot, { Volume = 1.5, PlaybackSpeed = 0.8 })
	Sfx.at("Explosion", spot, { Volume = 0.6, PlaybackSpeed = 0.6 })
	shakeNear(spot, 90, 1.1)
end

-- MADAME FORTUNE ------------------------------------------------------------------------------------------------
local VIOLET = Color3.fromRGB(190, 90, 255)
local function handOf(m: Model?, side: string): Vector3?
	local h = m and m:FindFirstChild(side .. "Hand") :: BasePart?
	return h and h.Position or nil
end
local function ballSmash(pos: Vector3)
	for _ = 1, 14 do
		local sh = part({ Size = Vector3.new(math.random() * 0.5 + 0.2, math.random() * 0.5 + 0.2, 0.1), Color = Color3.fromRGB(210, 180, 255),
			Material = Enum.Material.Glass, Transparency = 0.2, Position = pos })
		sh.Anchored = false
		sh.AssemblyLinearVelocity = Vector3.new(math.random(-20, 20), math.random(6, 24), math.random(-20, 20))
		Debris:AddItem(sh, 1.6)
	end
	burst(pos, VIOLET, 30, 0.5, 20, SPARK, 1)
	Sfx.at("GlassBreak", pos, { Volume = 1.4 })
	Sfx.at("GhostScream", pos, { Volume = 1, PlaybackSpeed = 1.15 })
	shakeNear(pos, 80, 0.5)
end

-- the curse on this player
local blur: BlurEffect? = nil
local tint: ColorCorrectionEffect? = nil
local cursedOn = false
local KEYS = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.Thumbstick1 }
local function setCursed(on: boolean)
	if on == cursedOn then return end
	cursedOn = on
	if on then
		local b = Instance.new("BlurEffect"); b.Name = "CurseBlur"; b.Size = 10; b.Parent = Lighting
		local c = Instance.new("ColorCorrectionEffect"); c.Name = "CurseTint"; c.TintColor = Color3.fromRGB(220, 180, 255); c.Saturation = -0.2; c.Parent = Lighting
		blur, tint = b, c
		-- the move keys go to us, not to Roblox's controls: the body is moved the other way (back to front)
		CAS:BindActionAtPriority("CurseSink", function() return Enum.ContextActionResult.Sink end, false, 3000, table.unpack(KEYS))
		Sfx.play("GhostWhisper", { Volume = 1, PlaybackSpeed = 0.8 })
		if Fx then Fx.shake(0.4) end
	else
		CAS:UnbindAction("CurseSink")
		if blur then blur:Destroy(); blur = nil end
		if tint then tint:Destroy(); tint = nil end
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:Move(Vector3.zero, true) end
	end
end
local function cursedMove()
	if not cursedOn then return end
	local t = os.clock()
	if blur then blur.Size = 9 + math.sin(t * 2.3) * 4 end
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	if not hum or UIS:GetFocusedTextBox() then return end
	local x, z = 0, 0
	local function down(k: Enum.KeyCode): number return UIS:IsKeyDown(k) and 1 or 0 end
	x = (down(Enum.KeyCode.D) + down(Enum.KeyCode.Right)) - (down(Enum.KeyCode.A) + down(Enum.KeyCode.Left))
	z = (down(Enum.KeyCode.S) + down(Enum.KeyCode.Down)) - (down(Enum.KeyCode.W) + down(Enum.KeyCode.Up))
	for _, st in UIS:GetGamepadState(Enum.UserInputType.Gamepad1) do
		if st.KeyCode == Enum.KeyCode.Thumbstick1 and st.Position.Magnitude > 0.2 then
			x += st.Position.X
			z -= st.Position.Y
		end
	end
	local v = Vector3.new(-x, 0, -z) -- (back to front, left to right)
	hum:Move(v.Magnitude > 1 and v.Unit or v, true)
end

-- THE RINGMASTER ------------------------------------------------------------------------------------------------
local function whipLine(origin: Vector3, dir: Vector3, len: number, t: number)
	local o = origin + Vector3.new(0, 0.1, 0)
	local cf = CFrame.lookAt(o, o + dir)
	local lane = part({ Size = Vector3.new(4, 0.1, len), CFrame = cf * CFrame.new(0, 0, -len / 2), Color = Color3.fromRGB(200, 26, 22), Material = Enum.Material.Neon, Transparency = 0.8 })
	local fill = part({ Size = Vector3.new(1.4, 0.12, 0.5), CFrame = cf * CFrame.new(0, 0.01, -0.25), Color = Color3.fromRGB(255, 70, 50), Material = Enum.Material.Neon, Transparency = 0.3 })
	TweenService:Create(fill, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = Vector3.new(1.4, 0.12, len), CFrame = cf * CFrame.new(0, 0.01, -len / 2) }):Play()
	Debris:AddItem(lane, t + 0.4); Debris:AddItem(fill, t + 0.4)
end
-- the lash: a black line snapping out along the floor and back, the crack at its tip
local function whipCrack(model: Model?, from: Vector3, dir: Vector3, len: number)
	local hand = handOf(model, "Right") or (from + Vector3.new(0, 3, 0))
	local tip = from + dir * len + Vector3.new(0, 1.2, 0)
	local segs = {}
	for i = 1, 6 do
		table.insert(segs, part({ Size = Vector3.new(0.18, 0.18, 1), Color = Color3.fromRGB(26, 20, 18), Material = Enum.Material.SmoothPlastic }))
	end
	local t0 = os.clock()
	local conn: RBXScriptConnection
	conn = RunService.RenderStepped:Connect(function()
		local u = (os.clock() - t0) / 0.4
		if u >= 1 then conn:Disconnect(); for _, s in segs do s:Destroy() end; return end
		local reach = math.sin(u * math.pi)
		local last = hand
		for i, s in segs do
			local f = i / #segs
			local p = hand:Lerp(tip, f * reach) + Vector3.new(0, math.sin(f * math.pi + u * 9) * 0.8 * (1 - reach), 0)
			local d = (p - last).Magnitude
			s.Size = Vector3.new(0.18, 0.18, math.max(0.1, d))
			s.CFrame = CFrame.lookAt((p + last) / 2, p)
			last = p
		end
	end)
	task.delay(0.18, function()
		Sfx.at("WhipCrack", tip, { Volume = 1.4 })
		burst(tip, Color3.fromRGB(255, 230, 200), 10, 0.3, 12, SPARK, 1)
	end)
	shakeNear(tip, 40, 0.35)
end

function CF.handle(kind: string, ...)
	local a = table.pack(...)
	if kind == "ClownHide" then
		local h = hrpOf(a[1])
		if h then
			burst(h.Position, Color3.fromRGB(240, 240, 240), 20, 2, 6)
			Sfx.at("EvilLaugh", h.Position, { Volume = 0.9, PlaybackSpeed = 1.3 })
		end
	elseif kind == "CrateRattle" then crateRattle(a[1], a[2], a[3])
	elseif kind == "CratePop" then cratePop(a[1], a[2])
	elseif kind == "ClownBlow" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at("Whoosh", h.Position, { Volume = 0.9, PlaybackSpeed = 1.8 })
			task.delay(a[2] * 0.6, function() Sfx.at("EvilLaugh", h.Position, { Volume = 0.8, PlaybackSpeed = 1.4 }) end)
		end
	elseif kind == "StrongGrunt" then
		local h = hrpOf(a[1])
		if h then Sfx.at("DemonGrowl", h.Position, { Volume = 1, PlaybackSpeed = 0.7 }) end
	elseif kind == "StrongLift" then
		local obj = a[2] :: Model?
		if obj and obj.Parent then
			local p = obj:GetPivot().Position
			Sfx.at("WoodBreak", p, { Volume = 1.2, PlaybackSpeed = 0.7 })
			burst(p, Color3.fromRGB(130, 110, 90), 18, 1.6, 10)
		end
		local h = hrpOf(a[1])
		if h then Sfx.at("DemonRoar", h.Position, { Volume = 0.8, PlaybackSpeed = 0.75 }) end
	elseif kind == "StrongThrow" then
		local h = hrpOf(a[1])
		if h then Sfx.at("Whoosh", h.Position, { Volume = 1.2, PlaybackSpeed = 0.6 }) end
	elseif kind == "SlamWarn" then slamWarn(a[1], a[2], a[3])
	elseif kind == "Shockwave" then shockwave(a[1], a[2], a[3])
	elseif kind == "CurseWind" then
		local m = a[1] :: Model?
		for _, side in { "Left", "Right" } do
			local p = handOf(m, side)
			if p then burst(p, VIOLET, 14, 0.4, 3, SPARK, 1) end
		end
		local h = hrpOf(m)
		if h then Sfx.at("GhostWhisper", h.Position, { Volume = 1.1, PlaybackSpeed = 0.7 }) end
	elseif kind == "CurseOrb" then
		local orb = a[1] :: BasePart?
		if orb then
			local e = Instance.new("ParticleEmitter")
			e.Texture = SPARK; e.Color = ColorSequence.new(VIOLET); e.LightEmission = 1; e.Rate = 40
			e.Size = NumberSequence.new(0.6, 0); e.Lifetime = NumberRange.new(0.3, 0.6); e.Speed = NumberRange.new(0.5, 1.5)
			e.Parent = orb
			Sfx.on("Telekinesis", orb, { Volume = 0.6, Looped = true, PlaybackSpeed = 1.4 })
		end
	elseif kind == "CurseHit" then
		burst(a[1], VIOLET, 30, 0.6, 14, SPARK, 1)
		Sfx.at("GhostScream", a[1], { Volume = 0.7, PlaybackSpeed = 1.4 })
	elseif kind == "CurseFizzle" then
		burst(a[1], VIOLET, 12, 0.5, 6, SPARK, 1)
	elseif kind == "CardsWind" then
		local p = handOf(a[1], "Left")
		if p then Sfx.at("Whoosh", p, { Volume = 0.7, PlaybackSpeed = 1.6 }) end
	elseif kind == "CardsThrow" then
		Sfx.at("Whoosh", a[1], { Volume = 1, PlaybackSpeed = 1.3 })
		Sfx.at("SaberSwish", a[1], { Volume = 0.6, PlaybackSpeed = 1.8 })
	elseif kind == "BallSmash" then ballSmash(a[1])
	elseif kind == "BallReform" then
		burst(a[1], VIOLET, 20, 0.4, 4, SPARK, 1)
		Sfx.at("MagicBurst", a[1], { Volume = 0.8, PlaybackSpeed = 0.8 })
	elseif kind == "WhipLine" then whipLine(a[1], a[2], a[3], a[4])
	elseif kind == "WhipCrack" then whipCrack(a[1], a[2], a[3], a[4])
	elseif kind == "WhipCrackUp" then
		local m = a[1] :: Model?
		local h = hrpOf(m)
		if h then
			task.delay(a[2] * 0.7, function()
				local up = h.Position + Vector3.new(0, 12, 0)
				Sfx.at("WhipCrack", up, { Volume = 1.6, PlaybackSpeed = 0.9 })
				burst(up, Color3.fromRGB(255, 230, 200), 16, 0.4, 16, SPARK, 1)
				shakeNear(up, 60, 0.4)
			end)
		end
	elseif kind == "CrowdCheer" then
		Sfx.at("Crowd", a[1], { Volume = 1.1, PlaybackSpeed = 0.8 })
	end
end

function CF.init(fx: any)
	Fx = fx
	lp:GetAttributeChangedSignal("Cursed"):Connect(function() setCursed(lp:GetAttribute("Cursed") == true) end)
	setCursed(lp:GetAttribute("Cursed") == true)
	RunService:BindToRenderStep("CurseMove", Enum.RenderPriority.Input.Value + 1, cursedMove)
end

return CF
