--!strict
-- What Blackwater Harbor's monsters' moves look and sound like (Server/HarborMonsters sends these Fx):
--   InkWind (model, t) / InkFly (part) / InkSplat (pos)                     the Deep One's ink
--   DiveSink (model, floor) / DiveRing (player, t, r) / DiveLock (spot, r, t) / DiveBurst (spot, r)   his dive
--   BeamRaise (model, t) / BeamSweep (model, yaw, dirn, arc, t, len, width) / BeamBurn (player)       the Keeper's beam
--   FlashCharge (model, t) / FlashBang (pos)                                 his lamp's flash
--   NetWind (model, t) / NetFly (part) / NetHit (player, t) / NetMiss (pos)  the Netman's net
--   AnchorWarn (model, floor, r, t) / AnchorSpin (model, r, t, turns, a0)    his anchor on its chain
-- And on this player (attributes set by the server): Inked = black ink splats over the screen, Flashed = a white
-- blinding flash that fades, Netted = a net over the view.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Sfx = require(script.Parent.Sfx)
local Grunge = require(script.Parent.Grunge)

local HF = {}
local lp = Players.LocalPlayer
local Fx: any = nil
local HUD: any = nil
local TEX = "rbxasset://textures/particles/"
local C = Color3.fromRGB
local INK = C(12, 10, 18)
local WATER = C(60, 130, 140)
local LAMP = C(255, 236, 180)

HF.KINDS = { "InkWind", "InkFly", "InkSplat", "DiveSink", "DiveRing", "DiveLock", "DiveBurst", "BeamRaise", "BeamSweep", "BeamBurn",
	"FlashCharge", "FlashBang", "NetWind", "NetFly", "NetHit", "NetMiss", "AnchorWarn", "AnchorSpin" }
local set = {} :: { [string]: boolean }
for _, k in HF.KINDS do set[k] = true end
function HF.handles(kind: string): boolean return set[kind] == true end

local function folder(): Folder
	local f = workspace:FindFirstChild("HarborFxLocal") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "HarborFxLocal"; nf.Parent = workspace
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
local function near(pos: Vector3, dist: number): boolean
	return (workspace.CurrentCamera.CFrame.Position - pos).Magnitude < dist
end
local function burst(pos: Vector3, color: Color3, n: number, size: number, speed: number, texture: string?, up: boolean?)
	local a = part({ Size = Vector3.one * 0.2, Transparency = 1, Position = pos })
	local e = Instance.new("ParticleEmitter")
	e.Texture = texture or (TEX .. "sparkles_main.dds"); e.Color = ColorSequence.new(color); e.LightInfluence = 0.3
	e.Size = NumberSequence.new(size, 0); e.Transparency = NumberSequence.new(0.1, 1); e.Lifetime = NumberRange.new(0.5, 1.1)
	e.Speed = NumberRange.new(speed * 0.5, speed); e.SpreadAngle = Vector2.new(up and 40 or 180, up and 40 or 180); e.Acceleration = Vector3.new(0, -30, 0)
	e.EmissionDirection = Enum.NormalId.Top; e.Rate = 0; e.Parent = a
	e:Emit(n)
	Debris:AddItem(a, 2)
end
-- a flat ring on the floor: grows from r0 to r1 over t, fading
local function ring(spot: Vector3, color: Color3, r0: number, r1: number, t: number, transp: number?)
	local r = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = color, Transparency = transp or 0.4,
		Size = Vector3.new(0.12, r0 * 2, r0 * 2), CFrame = CFrame.new(spot + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(r, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.12, r1 * 2, r1 * 2), Transparency = 1 }):Play()
	Debris:AddItem(r, t + 0.1)
	return r
end
local function floorUnder(pos: Vector3): Vector3
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local ex = { folder() }
	for _, p in Players:GetPlayers() do if p.Character then table.insert(ex, p.Character) end end
	local g = workspace:FindFirstChild("Ghost")
	if g then table.insert(ex, g) end
	rp.FilterDescendantsInstances = ex
	local r = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -30, 0), rp)
	return r and r.Position or (pos - Vector3.new(0, 3, 0))
end
local function lampOf(m: Model?): BasePart?
	return m and m:FindFirstChild("Flame", true) :: BasePart?
end

---------------------------------------------------------------------------------------------- the screen (this player)
local gui: ScreenGui
local inkFrame: Frame
local flashFrame: Frame
local netFrame: Frame
local function screen()
	gui = Instance.new("ScreenGui")
	gui.Name = "HarborFxScreen"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 4
	gui.Parent = lp:WaitForChild("PlayerGui")
	inkFrame = Grunge.frame(gui, { Size = UDim2.fromScale(1, 1), Visible = false })
	flashFrame = Grunge.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1, 1, 1), Visible = false })
	netFrame = Grunge.frame(gui, { Size = UDim2.fromScale(1, 1), Visible = false })
	-- the net over the view: a loose grid of rope, a little crooked
	for i = 0, 9 do
		local v = Instance.new("Frame"); v.BorderSizePixel = 0; v.BackgroundColor3 = C(150, 130, 90); v.BackgroundTransparency = 0.15
		v.AnchorPoint = Vector2.new(0.5, 0.5); v.Position = UDim2.fromScale(i / 9, 0.5); v.Size = UDim2.new(0, 5, 1.3, 0); v.Rotation = (i % 2 == 0) and 7 or -6; v.Parent = netFrame
		local h = Instance.new("Frame"); h.BorderSizePixel = 0; h.BackgroundColor3 = C(150, 130, 90); h.BackgroundTransparency = 0.15
		h.AnchorPoint = Vector2.new(0.5, 0.5); h.Position = UDim2.fromScale(0.5, i / 9); h.Size = UDim2.new(1.3, 0, 0, 5); h.Rotation = (i % 2 == 0) and -4 or 5; h.Parent = netFrame
	end
end
-- INKED: black splats slap onto the screen and drip away
local function setInked(on: boolean)
	for _, c in inkFrame:GetChildren() do c:Destroy() end
	inkFrame.Visible = on
	if not on then return end
	Sfx.play("FormSquish", { Volume = 1, PlaybackSpeed = 0.7 })
	local rng = Random.new()
	for i = 1, 6 do
		local im = Instance.new("ImageLabel")
		im.BackgroundTransparency = 1; im.Image = Grunge.SPLAT; im.ImageColor3 = INK
		im.AnchorPoint = Vector2.new(0.5, 0.5)
		im.Position = UDim2.fromScale(rng:NextNumber(0.15, 0.85), rng:NextNumber(0.15, 0.85))
		local sz = rng:NextNumber(0.35, 0.6)
		im.Size = UDim2.fromScale(sz, sz * 1.6); im.Rotation = rng:NextNumber(0, 360)
		im.Parent = inkFrame
		local sc = Instance.new("UIScale"); sc.Scale = 0.2; sc.Parent = im
		TweenService:Create(sc, TweenInfo.new(0.15 + i * 0.03, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		-- slides down slowly as it drips
		TweenService:Create(im, TweenInfo.new(4.5, Enum.EasingStyle.Linear), { Position = im.Position + UDim2.fromScale(0, 0.12), ImageTransparency = 0.25 }):Play()
	end
end
local flashT = 0
local function setFlashed(on: boolean)
	if on then
		flashT = os.clock()
		flashFrame.Visible = true
		flashFrame.BackgroundTransparency = 0
		Sfx.play("TvStatic", { Volume = 0.6, PlaybackSpeed = 1.6 })
	end
end
local function setNetted(on: boolean)
	netFrame.Visible = on
	if on then Sfx.play("WoodBreak", { Volume = 0.5, PlaybackSpeed = 1.6 }) end
end

---------------------------------------------------------------------------------------------- the Deep One
local function diveRing(who: Player?, t: number, r: number)
	local h = hrpOf(who)
	if not h then return end
	local ripple = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = WATER, Transparency = 0.5,
		Size = Vector3.new(0.1, r * 2, r * 2) })
	local inner = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Glass, Color = C(20, 50, 60), Transparency = 0.35,
		Size = Vector3.new(0.08, r * 1.6, r * 1.6) })
	local bub = Instance.new("ParticleEmitter")
	bub.Texture = TEX .. "forcefield_glow_main.dds"; bub.Color = ColorSequence.new(C(160, 220, 220)); bub.Size = NumberSequence.new(0.5, 0.1)
	bub.Transparency = NumberSequence.new(0.3, 1); bub.Lifetime = NumberRange.new(0.4, 0.8); bub.Speed = NumberRange.new(2, 5); bub.Rate = 30
	bub.EmissionDirection = Enum.NormalId.Right; bub.Parent = inner
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.Heartbeat:Connect(function()
		local k = os.clock() - t0
		local hh = hrpOf(who)
		if k > t or not hh or not ripple.Parent then
			c:Disconnect(); ripple:Destroy(); inner:Destroy()
			return
		end
		local f = floorUnder(hh.Position)
		local w = 1 + math.sin(k * 10) * 0.06
		ripple.Size = Vector3.new(0.1, r * 2 * w, r * 2 * w)
		ripple.CFrame = CFrame.new(f + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		inner.CFrame = CFrame.new(f + Vector3.new(0, 0.06, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	end)
end
local function diveLock(spot: Vector3, r: number, t: number)
	local warn = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = C(255, 70, 50), Transparency = 0.35,
		Size = Vector3.new(0.12, r * 2, r * 2), CFrame = CFrame.new(spot + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(warn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.75 }):Play()
	Debris:AddItem(warn, t + 0.1)
	burst(spot, C(170, 220, 220), 30, 0.6, 8, TEX .. "forcefield_glow_main.dds", true)
	Sfx.at("Bubbles", spot, { Volume = 1.2, PlaybackSpeed = 0.6 })
end
local function diveBurst(spot: Vector3, r: number)
	local col = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Glass, Color = C(80, 170, 180), Transparency = 0.3,
		Size = Vector3.new(2, r * 1.2, r * 1.2), CFrame = CFrame.new(spot + Vector3.new(0, 1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(col, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(16, r * 0.5, r * 0.5),
		CFrame = CFrame.new(spot + Vector3.new(0, 8, 0)) * CFrame.Angles(0, 0, math.pi / 2), Transparency = 1 }):Play()
	Debris:AddItem(col, 0.6)
	burst(spot, C(150, 210, 220), 70, 1.4, 34, TEX .. "smoke_main.dds", true)
	ring(spot, WATER, 1, r + 4, 0.6, 0.3)
	Sfx.at("Crash", spot, { Volume = 1, PlaybackSpeed = 0.8 })
	Sfx.at("GhostScream", spot, { Volume = 0.8, PlaybackSpeed = 0.5 })
	if near(spot, 40) and Fx then Fx.shake(0.7) end
end

---------------------------------------------------------------------------------------------- the Keeper
local function beamSweep(m: Model?, yaw: number, dirn: number, arc: number, t: number, len: number, width: number)
	local lamp = lampOf(m)
	if not lamp then return end
	local a0 = Instance.new("Attachment"); a0.Parent = lamp
	local endP = part({ Size = Vector3.one * 0.2, Transparency = 1 })
	local a1 = Instance.new("Attachment"); a1.Parent = endP
	local b = Instance.new("Beam")
	b.Attachment0 = a0; b.Attachment1 = a1; b.FaceCamera = true; b.LightEmission = 1; b.LightInfluence = 0; b.Segments = 1
	b.Width0 = 1.2; b.Width1 = math.tan(width) * len * 2
	b.Texture = TEX .. "forcefield_glow_main.dds"; b.TextureMode = Enum.TextureMode.Stretch
	b.Color = ColorSequence.new(LAMP); b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(0.7, 0.7), NumberSequenceKeypoint.new(1, 1) })
	b.Parent = lamp
	-- a real spotlight along the beam (it lights the room as it sweeps)
	local holder = part({ Size = Vector3.one * 0.2, Transparency = 1 })
	local sl = Instance.new("SpotLight"); sl.Color = LAMP; sl.Range = math.min(60, len); sl.Angle = math.deg(width) * 2.4; sl.Brightness = 6; sl.Face = Enum.NormalId.Front
	sl.Shadows = true; sl.Parent = holder
	Sfx.on("SaberHum", lamp, { Volume = 0.6, PlaybackSpeed = 0.5 })
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		local f = (os.clock() - t0) / t
		if f > 1 or not lamp.Parent then
			c:Disconnect(); b:Destroy(); a0:Destroy(); endP:Destroy(); holder:Destroy()
			return
		end
		local y = yaw + dirn * (-arc + 2 * arc * f)
		local dir = Vector3.new(math.sin(y), -0.08, math.cos(y))
		endP.Position = lamp.Position + dir * len
		holder.CFrame = CFrame.lookAt(lamp.Position, lamp.Position + dir)
	end)
end
local function flashCharge(m: Model?, t: number)
	local lamp = lampOf(m)
	if not lamp then return end
	local glow = part({ Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = Color3.new(1, 1, 1), Transparency = 0.2, Size = Vector3.one * 0.6 })
	local l = Instance.new("PointLight"); l.Color = Color3.new(1, 1, 1); l.Range = 30; l.Brightness = 0; l.Parent = glow
	Sfx.on("SaberBurn", lamp, { Volume = 0.8, PlaybackSpeed = 0.6 })
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		local f = (os.clock() - t0) / t
		if f > 1 or not lamp.Parent then c:Disconnect(); glow:Destroy(); return end
		glow.Position = lamp.Position
		glow.Size = Vector3.one * (0.6 + f * f * 3)
		l.Brightness = f * 6
	end)
end
local function flashBang(pos: Vector3)
	local b = part({ Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = Color3.new(1, 1, 1), Transparency = 0, Size = Vector3.one * 3, Position = pos })
	local l = Instance.new("PointLight"); l.Range = 60; l.Brightness = 12; l.Parent = b
	TweenService:Create(b, TweenInfo.new(0.5), { Size = Vector3.one * 26, Transparency = 1 }):Play()
	TweenService:Create(l, TweenInfo.new(0.6), { Brightness = 0 }):Play()
	Debris:AddItem(b, 0.7)
	Sfx.at("Explosion", pos, { Volume = 0.6, PlaybackSpeed = 1.6 })
	Sfx.at("MagicBurst", pos, { Volume = 1, PlaybackSpeed = 1.3 })
end

---------------------------------------------------------------------------------------------- the Netman
-- a square net of rope (a flat grid) as a local model; returns it and a function to place it
local function netModel(size: number): (Model, (cf: CFrame) -> ())
	local m = Instance.new("Model"); m.Name = "Net"
	local parts = {} :: { { p: BasePart, rel: CFrame } }
	local n = 5
	for i = 0, n do
		local o = -size / 2 + i * size / n
		local a = part({ Size = Vector3.new(size, 0.1, 0.1), Color = C(150, 130, 90), Material = Enum.Material.Fabric })
		local b = part({ Size = Vector3.new(0.1, 0.1, size), Color = C(150, 130, 90), Material = Enum.Material.Fabric })
		a.Parent = m; b.Parent = m
		table.insert(parts, { p = a, rel = CFrame.new(0, 0, o) })
		table.insert(parts, { p = b, rel = CFrame.new(o, 0, 0) })
	end
	for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
		local w = part({ Shape = Enum.PartType.Ball, Size = Vector3.one * 0.5, Color = C(80, 80, 84), Material = Enum.Material.Metal })
		w.Parent = m
		table.insert(parts, { p = w, rel = CFrame.new(c[1] * size / 2, 0, c[2] * size / 2) })
	end
	m.Parent = folder()
	return m, function(cf: CFrame)
		for _, x in parts do x.p.CFrame = cf * x.rel end
	end
end
local function netFly(pr: BasePart?)
	if not pr then return end
	local m, place = netModel(5)
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		if not pr.Parent then c:Disconnect(); m:Destroy(); return end
		place(pr.CFrame)
	end)
	Sfx.at("Whoosh", pr.Position, { Volume = 1, PlaybackSpeed = 0.6 })
end
local function netHit(who: Player?, t: number)
	local h = hrpOf(who)
	if not h then return end
	-- draped over them: a net on each side and on top, following the body
	local nets = {}
	for k = 0, 4 do
		local m, place = netModel(4.2)
		table.insert(nets, { m = m, place = place, k = k })
	end
	Sfx.at("WoodBreak", h.Position, { Volume = 0.7, PlaybackSpeed = 1.5 })
	local t0 = os.clock()
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		local hh = hrpOf(who)
		if os.clock() - t0 > t or not hh then
			c:Disconnect()
			for _, n in nets do n.m:Destroy() end
			return
		end
		local base = CFrame.new(hh.Position)
		for _, n in nets do
			local cf
			if n.k == 4 then cf = base * CFrame.new(0, 2.4, 0)
			else cf = base * CFrame.Angles(0, n.k * math.pi / 2, 0) * CFrame.new(0, 0, -1.3) * CFrame.Angles(math.pi / 2 - 0.1, 0, 0) end
			n.place(cf)
		end
	end)
end
local function netMiss(pos: Vector3)
	local m, place = netModel(5)
	place(CFrame.new(floorUnder(pos) + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, math.random() * 6, 0))
	Debris:AddItem(m, 3)
end
local function anchorWarn(m: Model?, floor: Vector3, r: number, t: number)
	local w = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = C(255, 70, 50), Transparency = 0.6,
		Size = Vector3.new(0.1, r * 2 + 4, r * 2 + 4), CFrame = CFrame.new(floor + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	local hole = part({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.SmoothPlastic, Color = C(20, 16, 14), Transparency = 0.3,
		Size = Vector3.new(0.12, 8, 8), CFrame = CFrame.new(floor + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(w, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.85 }):Play()
	Debris:AddItem(w, t + 0.2); Debris:AddItem(hole, t + 0.2)
	local _ = m
	Sfx.at("ShieldBlock", floor, { Volume = 0.8, PlaybackSpeed = 0.5 })
end
local function anchorSpin(m: Model?, r: number, t: number, turns: number, a0: number)
	local hrp = hrpOf(m)
	if not hrp then return end
	local IRON = C(60, 60, 64)
	local am = Instance.new("Model"); am.Name = "Anchor"; am.Parent = folder()
	local pieces = {
		{ p = part({ Size = Vector3.new(0.7, 4.2, 0.7), Color = IRON, Material = Enum.Material.Metal }), rel = CFrame.new(0, 0.6, 0) },
		{ p = part({ Size = Vector3.new(3.6, 0.7, 0.7), Color = IRON, Material = Enum.Material.Metal }), rel = CFrame.new(0, -1.3, 0) },
		{ p = part({ Size = Vector3.new(0.7, 1.4, 0.7), Color = IRON, Material = Enum.Material.Metal }), rel = CFrame.new(-1.6, -0.8, 0) * CFrame.Angles(0, 0, 0.4) },
		{ p = part({ Size = Vector3.new(0.7, 1.4, 0.7), Color = IRON, Material = Enum.Material.Metal }), rel = CFrame.new(1.6, -0.8, 0) * CFrame.Angles(0, 0, -0.4) },
		{ p = part({ Size = Vector3.new(2.4, 0.5, 0.5), Color = IRON, Material = Enum.Material.Metal }), rel = CFrame.new(0, 2.4, 0) },
	}
	for _, x in pieces do x.p.Parent = am end
	local links = {} :: { BasePart }
	for i = 1, 10 do
		local l = part({ Size = Vector3.new(0.35, 0.35, r / 10 + 0.2), Color = C(90, 90, 96), Material = Enum.Material.Metal })
		l.Parent = am
		links[i] = l
	end
	local trail = part({ Size = Vector3.one * 0.2, Transparency = 1 })
	trail.Parent = am
	local ta0 = Instance.new("Attachment"); ta0.Position = Vector3.new(0, 1, 0); ta0.Parent = trail
	local ta1 = Instance.new("Attachment"); ta1.Position = Vector3.new(0, -1, 0); ta1.Parent = trail
	local tr = Instance.new("Trail"); tr.Attachment0 = ta0; tr.Attachment1 = ta1; tr.Lifetime = 0.25; tr.Color = ColorSequence.new(C(200, 200, 210))
	tr.Transparency = NumberSequence.new(0.4, 1); tr.LightEmission = 0.3; tr.Parent = trail
	local t0 = os.clock()
	local lastHalf = -1
	local c: RBXScriptConnection
	c = RunService.RenderStepped:Connect(function()
		local f = (os.clock() - t0) / t
		local h = hrpOf(m)
		if f > 1 or not h then c:Disconnect(); am:Destroy(); return end
		local ang = a0 + f * turns * math.pi * 2
		local floorY = floorUnder(h.Position).Y
		local center = Vector3.new(h.Position.X, floorY + 1.6, h.Position.Z)
		local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
		local at = center + dir * r
		local cf = CFrame.lookAt(at, at + dir) * CFrame.Angles(0, 0, math.pi / 2)
		for _, x in pieces do x.p.CFrame = cf * x.rel end
		trail.CFrame = cf
		local hand = h.Position + Vector3.new(0, 2, 0)
		for i, l in links do
			local a = hand:Lerp(at, (i - 0.5) / #links)
			l.CFrame = CFrame.lookAt(a, at) * CFrame.Angles(0, 0, i * 0.8)
		end
		local half = math.floor(f * turns * 2)
		if half ~= lastHalf then lastHalf = half; Sfx.at("Whoosh", at, { Volume = 1, PlaybackSpeed = 0.55 }) end
	end)
end

---------------------------------------------------------------------------------------------- dispatch
function HF.handle(kind: string, ...)
	local a = table.pack(...)
	if kind == "InkWind" then
		local m = a[1] :: Model?
		local head = m and m:FindFirstChild("Head") :: BasePart?
		if head then
			Sfx.at("Bubbles", head.Position, { Volume = 1.2, PlaybackSpeed = 0.5 })
			burst(head.Position, INK, 20, 0.6, 4, TEX .. "smoke_main.dds", true)
		end
	elseif kind == "InkFly" then
		local p = a[1] :: BasePart?
		if p then
			local e = Instance.new("ParticleEmitter")
			e.Texture = TEX .. "smoke_main.dds"; e.Color = ColorSequence.new(INK); e.Size = NumberSequence.new(1.2, 0.2); e.Transparency = NumberSequence.new(0.2, 1)
			e.Lifetime = NumberRange.new(0.3, 0.6); e.Speed = NumberRange.new(0.5, 1); e.Rate = 40; e.Acceleration = Vector3.new(0, -20, 0); e.Parent = p
			Sfx.at("FormSquish", p.Position, { Volume = 1, PlaybackSpeed = 0.6 })
		end
	elseif kind == "InkSplat" then
		local pos = a[1] :: Vector3
		burst(pos, INK, 40, 1.4, 16, TEX .. "smoke_main.dds")
		ring(floorUnder(pos), INK, 1, 6, 0.6, 0.2)
		Sfx.at("FormSquish", pos, { Volume = 1.2, PlaybackSpeed = 0.5 })
	elseif kind == "DiveSink" then
		local fl = a[2] :: Vector3
		ring(fl, WATER, 1, 7, 0.6, 0.3)
		burst(fl, C(150, 210, 220), 30, 0.9, 14, TEX .. "smoke_main.dds", true)
		Sfx.at("FormGulp", fl, { Volume = 1.2, PlaybackSpeed = 0.5 })
	elseif kind == "DiveRing" then
		diveRing(a[1], a[2], a[3])
	elseif kind == "DiveLock" then
		diveLock(a[1], a[2], a[3])
	elseif kind == "DiveBurst" then
		diveBurst(a[1], a[2])
	elseif kind == "BeamRaise" then
		local lamp = lampOf(a[1])
		if lamp then Sfx.at("ShieldBlock", lamp.Position, { Volume = 0.6, PlaybackSpeed = 1.4 }) end
	elseif kind == "BeamSweep" then
		beamSweep(a[1], a[2], a[3], a[4], a[5], a[6], a[7])
	elseif kind == "BeamBurn" then
		local who = a[1] :: Player?
		local h = hrpOf(who)
		if h then burst(h.Position, C(255, 200, 120), 8, 0.5, 5, nil, true) end
		if who == lp and HUD then HUD.flash(C(255, 190, 110), 0.3) end
	elseif kind == "FlashCharge" then
		flashCharge(a[1], a[2])
	elseif kind == "FlashBang" then
		flashBang(a[1])
	elseif kind == "NetWind" then
		local m = a[1] :: Model?
		local h = hrpOf(m)
		if h then for i = 0, 2 do task.delay(i * 0.2, function() Sfx.at("Whoosh", h.Position, { Volume = 0.8, PlaybackSpeed = 0.8 + i * 0.1 }) end) end end
	elseif kind == "NetFly" then
		netFly(a[1])
	elseif kind == "NetHit" then
		netHit(a[1], a[2])
	elseif kind == "NetMiss" then
		netMiss(a[1])
	elseif kind == "AnchorWarn" then
		anchorWarn(a[1], a[2], a[3], a[4])
	elseif kind == "AnchorSpin" then
		anchorSpin(a[1], a[2], a[3], a[4], a[5])
	end
end

function HF.init(fx: any, hud: any?)
	Fx = fx; HUD = hud
	screen()
	lp:GetAttributeChangedSignal("Inked"):Connect(function() setInked(lp:GetAttribute("Inked") == true) end)
	lp:GetAttributeChangedSignal("Flashed"):Connect(function() setFlashed(lp:GetAttribute("Flashed") == true) end)
	lp:GetAttributeChangedSignal("Netted"):Connect(function() setNetted(lp:GetAttribute("Netted") == true) end)
	-- the flash fades over the blind time (white, then slowly back)
	RunService.RenderStepped:Connect(function()
		if flashFrame.Visible then
			local k = os.clock() - flashT
			local blind = lp:GetAttribute("Flashed") == true
			flashFrame.BackgroundTransparency = blind and math.clamp((k - 1.2) / 2, 0, 0.35) or math.clamp(0.35 + (k - 1.2) * 0.6, 0.35, 1)
			if not blind and flashFrame.BackgroundTransparency >= 1 then flashFrame.Visible = false end
		end
	end)
	lp:GetAttributeChangedSignal("InMatch"):Connect(function()
		if not lp:GetAttribute("InMatch") then setInked(false); setNetted(false); flashFrame.Visible = false end
	end)
end

return HF
