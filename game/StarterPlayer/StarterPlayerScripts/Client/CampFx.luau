--!strict
-- What Camp Hollowmere's monsters' moves look like (Server/CampMonsters sends these Fx; this screen's own parts):
--   AntlerClimb (model, t)            creaking wood as the Antlered One goes up into the rafters
--   DropWarn (spot, radius, t)        a red ring on the floor, tightening: where he comes down
--   DropLand (spot, radius)           a burst of dust and splinters, the floor shakes
--   HookWind (model, t)               the Lake Witch's chain rattles
--   HookThrow (model, from, dir, speed, len)   the hook flies, its chain paying out behind it
--   HookCatch (model, player, t)      the chain from her hand to the one she caught
--   HookPull (dest, t, speed)         (to the victim only) dragged toward the water: this client moves its own body
--   HookMiss (model, pos?)            the hook clanks into a wall / falls, the chain goes
--   HookDrown (pos)                   a splash
--   FloodStart (t) / FloodEnd         black water rises over the whole floor, then drains
--   TorchWind (model, t) / TorchThrow (model, from, to, t) / TorchLand (spot)   the Burned Counselor's torch
--   ScareSwap (a, b)                  straw bursts where the Scarecrow and his decoy swapped
--   ChargeLine (model, origin, dir, len, t) / ChargeGo (model, t) / ChargeSmash (pos) / AntlersStuck (model, pos, t)
--                                     the Antlered One's charge: a red lane filling out, the snort, dust, the wall
--   FloodCall (model, t)              the Lake Witch calls the water (before FloodStart)
--   GraspWarn (model, spot, radius, t) / GraspHands (spot, radius, hold)   black water wells up, drowned hands grab
--   CounselorScream (model, t) / CounselorPant (model, t)   the Counselor's run: the scream, the panting after
--   CrowsGather (model, t) / Crows (model, dir, t, range)   the Scarecrow's crows circle him, then burst at you
--   Blinded (t)                       (to the one pecked) black wings beating over the screen, fading
--   SickleWind (model, t) / SickleThrow (model, from, to, flight) / SickleDrop (model)   his sickle, thrown and back
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Sfx = require(script.Parent.Sfx)

local CF = {}
local lp = Players.LocalPlayer
local Fx: any = nil
function CF.init(fx) Fx = fx end

CF.KINDS = { "AntlerClimb", "DropWarn", "DropLand", "HookWind", "HookThrow", "HookCatch", "HookPull", "HookMiss", "HookDrown",
	"FloodStart", "FloodEnd", "TorchWind", "TorchThrow", "TorchLand", "ScareSwap",
	"ChargeLine", "ChargeGo", "ChargeSmash", "AntlersStuck", "FloodCall", "GraspWarn", "GraspHands", "CounselorScream",
	"CounselorPant", "CrowsGather", "Crows", "Blinded", "SickleWind", "SickleThrow", "SickleDrop" }
local set = {} :: { [string]: boolean }
for _, k in CF.KINDS do set[k] = true end
function CF.handles(kind: string): boolean return set[kind] == true end

local function folder(): Folder
	local f = workspace:FindFirstChild("CampFx") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "CampFx"; nf.Parent = workspace
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
	local cam = workspace.CurrentCamera
	local d = (cam.CFrame.Position - pos).Magnitude
	return d < dist and (1 - d / dist) or 0
end
local function burst(pos: Vector3, color: Color3, n: number, size: number, speed: number, texture: string?)
	local p = part({ Transparency = 1, Size = Vector3.one, Position = pos })
	local e = Instance.new("ParticleEmitter")
	e.Texture = texture or "rbxasset://textures/particles/smoke_main.dds"
	e.Color = ColorSequence.new(color)
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, size * 2.2) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = NumberRange.new(0.8, 1.4); e.Rate = 0; e.Speed = NumberRange.new(speed * 0.5, speed); e.SpreadAngle = Vector2.new(180, 60)
	e.Acceleration = Vector3.new(0, 2, 0); e.Parent = p
	e:Emit(n)
	Debris:AddItem(p, 2)
end

-- THE ANTLERED ONE ------------------------------------------------------------------------------------------
local function dropWarn(spot: Vector3, radius: number, t: number)
	local ring = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.2, radius * 2, radius * 2), Color = Color3.fromRGB(220, 30, 26),
		Material = Enum.Material.Neon, Transparency = 0.55, CFrame = CFrame.new(spot + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2) })
	local core = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.22, 0.6, 0.6), Color = Color3.fromRGB(255, 70, 50),
		Material = Enum.Material.Neon, Transparency = 0.3, CFrame = ring.CFrame })
	TweenService:Create(core, TweenInfo.new(t, Enum.EasingStyle.Linear), { Size = Vector3.new(0.22, radius * 2, radius * 2), Transparency = 0.15 }):Play()
	Sfx.at("DoorCreak", spot + Vector3.new(0, 18, 0), { Volume = 1, PlaybackSpeed = 0.7 })
	Debris:AddItem(ring, t + 0.15); Debris:AddItem(core, t + 0.15)
end
local function dropLand(spot: Vector3, radius: number)
	burst(spot + Vector3.new(0, 1, 0), Color3.fromRGB(120, 104, 86), 30, 2, 18)
	burst(spot + Vector3.new(0, 1, 0), Color3.fromRGB(80, 60, 44), 14, 0.6, 30, "rbxasset://textures/particles/sparkles_main.dds")
	Sfx.at("WoodBreak", spot, { Volume = 1.2 })
	Sfx.at("PunchHeavy", spot, { Volume = 1.2, PlaybackSpeed = 0.45 })
	local k = near(spot, radius * 5)
	if Fx and k > 0 then Fx.shake(0.25 + k * 0.6) end
end

-- THE LAKE WITCH -------------------------------------------------------------------------------------------
local RUST = Color3.fromRGB(110, 66, 40)
local hook: { head: BasePart, chain: BasePart, model: Model?, t0: number, from: Vector3, dir: Vector3, speed: number, len: number, done: boolean, victim: Player?, untilT: number }? = nil
local function handOf(model: Model?): Vector3?
	local h = model and model:FindFirstChild("RightHand") :: BasePart?
	return h and h.Position or nil
end
local function clearHook()
	if hook then
		hook.head:Destroy(); hook.chain:Destroy()
		hook = nil
	end
end
local function placeChain(chain: BasePart, a: Vector3, b: Vector3)
	local d = (b - a).Magnitude
	chain.Size = Vector3.new(0.18, 0.18, math.max(0.1, d))
	chain.CFrame = CFrame.lookAt((a + b) / 2, b)
end
local function hookThrow(model: Model, from: Vector3, dir: Vector3, speed: number, len: number)
	clearHook()
	local head = part({ Size = Vector3.new(0.4, 1.2, 0.9), Color = RUST, Material = Enum.Material.CorrodedMetal })
	local chain = part({ Size = Vector3.new(0.18, 0.18, 1), Color = Color3.fromRGB(70, 64, 58), Material = Enum.Material.Metal })
	hook = { head = head, chain = chain, model = model, t0 = os.clock(), from = from, dir = dir, speed = speed, len = len, done = false, victim = nil, untilT = os.clock() + len / speed + 0.3 }
	Sfx.at("Whoosh", from, { Volume = 1, PlaybackSpeed = 0.8 })
end
local pullConn: RBXScriptConnection? = nil
local function hookPull(dest: Vector3, t: number, speed: number)
	local ch = lp.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end
	if pullConn then pullConn:Disconnect() end
	local t0 = os.clock()
	pullConn = RunService.Heartbeat:Connect(function()
		local h = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not h or os.clock() - t0 > t then
			if pullConn then pullConn:Disconnect(); pullConn = nil end
			return
		end
		local d = Vector3.new(dest.X - h.Position.X, 0, dest.Z - h.Position.Z)
		if d.Magnitude < 2 then
			h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0)
			return
		end
		local v = d.Unit * speed
		h.AssemblyLinearVelocity = Vector3.new(v.X, math.min(h.AssemblyLinearVelocity.Y, 4), v.Z)
	end)
	if Fx then Fx.shake(0.2) end
end
local function released()
	if pullConn then pullConn:Disconnect(); pullConn = nil end
end
CF.released = released

local water: BasePart? = nil
local function floodStart(t: number)
	if water then water:Destroy() end
	local live = workspace:FindFirstChild("Mansion")
	local str = live and live:FindFirstChild("Structure")
	local gf = str and str:FindFirstChild("GroundFloor") :: BasePart?
	local y = gf and (gf.Position.Y + gf.Size.Y / 2) or 2.05
	local w = part({ Size = Vector3.new(156, 0.4, 116), Position = Vector3.new(0, y - 0.3, 0), Color = Color3.fromRGB(26, 52, 56),
		Material = Enum.Material.Glass, Transparency = 0.3, Name = "FloodWater" })
	water = w
	TweenService:Create(w, TweenInfo.new(1.6, Enum.EasingStyle.Quad), { Position = Vector3.new(0, y + 1.2, 0) }):Play()
	Sfx.play("Thunder", { Volume = 0.7, PlaybackSpeed = 0.6 })
	Sfx.play("Cauldron", { Volume = 0.8, PlaybackSpeed = 0.7 })
	task.delay(math.max(0.5, t - 1.4), function()
		if water ~= w then return end
		TweenService:Create(w, TweenInfo.new(1.4, Enum.EasingStyle.Quad), { Position = Vector3.new(0, y - 0.4, 0) }):Play()
		task.delay(1.5, function() if water == w then w:Destroy(); water = nil end end)
	end)
end

-- THE BURNED COUNSELOR -------------------------------------------------------------------------------------
local function torchThrow(from: Vector3, to: Vector3, t: number)
	local stick = part({ Size = Vector3.new(0.3, 2.2, 0.3), Color = Color3.fromRGB(80, 56, 36), Material = Enum.Material.Wood })
	local flame = part({ Size = Vector3.new(0.6, 0.9, 0.6), Color = Color3.fromRGB(255, 150, 40), Material = Enum.Material.Neon, Transparency = 0.15 })
	local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 150, 60); l.Range = 18; l.Brightness = 2; l.Parent = flame
	local f = Instance.new("Fire"); f.Size = 2.5; f.Heat = 4; f.Parent = flame
	local t0 = os.clock()
	local conn: RBXScriptConnection
	conn = RunService.RenderStepped:Connect(function()
		local u = math.clamp((os.clock() - t0) / t, 0, 1)
		local p = from:Lerp(to, u) + Vector3.new(0, math.sin(u * math.pi) * (6 + (to - from).Magnitude * 0.15), 0)
		local cf = CFrame.new(p) * CFrame.Angles(u * 14, 0, u * 5)
		stick.CFrame = cf
		flame.CFrame = cf * CFrame.new(0, 1.4, 0)
		if u >= 1 then conn:Disconnect(); stick:Destroy(); flame:Destroy() end
	end)
	Sfx.at("Whoosh", from, { Volume = 1, PlaybackSpeed = 0.7 })
end
local function torchLand(spot: Vector3)
	burst(spot + Vector3.new(0, 1, 0), Color3.fromRGB(255, 140, 40), 24, 0.5, 16, "rbxasset://textures/particles/sparkles_main.dds")
	burst(spot + Vector3.new(0, 1, 0), Color3.fromRGB(60, 50, 44), 10, 2, 6)
	Sfx.at("Flamethrower", spot, { Volume = 0.9, PlaybackSpeed = 1.2 })
end

-- THE SCARECROW --------------------------------------------------------------------------------------------
local function straw(pos: Vector3)
	burst(pos, Color3.fromRGB(214, 182, 96), 26, 0.35, 14, "rbxasset://textures/particles/sparkles_main.dds")
	burst(pos, Color3.fromRGB(150, 130, 90), 8, 1.6, 5)
end

-- the second moves ----------------------------------------------------------------------------------------
local A = CFrame.Angles
local function hrpOf(m: Model?): BasePart? return m and m:FindFirstChild("HumanoidRootPart") :: BasePart? end
local function shakeNear(pos: Vector3, dist: number, amount: number)
	local k = near(pos, dist)
	if Fx and k > 0 then Fx.shake(amount * k) end
end
-- a few parts moved together: { part, offset } placed from one CFrame
type Rig = { parts: { { p: BasePart, rel: CFrame } } }
local function rigPlace(r: Rig, cf: CFrame)
	for _, e in r.parts do e.p.CFrame = cf * e.rel end
end
local function rigDestroy(r: Rig)
	for _, e in r.parts do e.p:Destroy() end
end
local function rigAdd(r: Rig, rel: CFrame, props: { [string]: any }): BasePart
	local p = part(props)
	table.insert(r.parts, { p = p, rel = rel })
	return p
end

-- THE ANTLERED ONE's charge: a red lane on the floor filling out from his feet, the snort; the run; the wall
local RED, RED_HOT = Color3.fromRGB(200, 26, 22), Color3.fromRGB(255, 70, 50)
local function chargeLine(model: Model?, origin: Vector3, dir: Vector3, len: number, t: number)
	local o = origin + Vector3.new(0, 0.1, 0)
	local cf = CFrame.lookAt(o, o + dir)
	local lane = part({ Size = Vector3.new(6, 0.1, len), CFrame = cf * CFrame.new(0, 0, -len / 2), Color = RED, Material = Enum.Material.Neon, Transparency = 0.78 })
	local fill = part({ Size = Vector3.new(3.4, 0.12, 0.5), CFrame = cf * CFrame.new(0, 0.01, -0.25), Color = RED_HOT, Material = Enum.Material.Neon, Transparency = 0.35 })
	TweenService:Create(fill, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = Vector3.new(3.4, 0.12, len), CFrame = cf * CFrame.new(0, 0.01, -len / 2) }):Play()
	Debris:AddItem(lane, t + 0.5); Debris:AddItem(fill, t + 0.5)
	local h = hrpOf(model)
	if h then
		Sfx.at("BullSnort", h.Position, { Volume = 1.3, PlaybackSpeed = 0.7 })
		task.delay(t * 0.55, function() Sfx.at("BullSnort", h.Position, { Volume = 1.3, PlaybackSpeed = 0.62 }) end)
	end
end
local function chargeGo(model: Model?, t: number)
	local h = hrpOf(model)
	if not h then return end
	Sfx.at("DemonRoar", h.Position, { Volume = 1, PlaybackSpeed = 0.7 })
	-- dust kicked up behind him for the whole run
	local at = Instance.new("Attachment"); at.Position = Vector3.new(0, -5, 1); at.Parent = h
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/smoke_main.dds"
	e.Color = ColorSequence.new(Color3.fromRGB(110, 96, 80))
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 4) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = NumberRange.new(0.6, 1); e.Rate = 40; e.Speed = NumberRange.new(2, 5); e.SpreadAngle = Vector2.new(40, 40)
	e.Parent = at
	task.delay(t, function() e.Enabled = false end)
	Debris:AddItem(at, t + 1.2)
	shakeNear(h.Position, 60, 0.35)
end
local function chargeSmash(pos: Vector3)
	Sfx.at("WoodBreak", pos, { Volume = 1.3, PlaybackSpeed = 0.8 })
	burst(pos, Color3.fromRGB(120, 104, 86), 14, 2, 12)
	shakeNear(pos, 70, 0.6)
end
local function antlersStuck(model: Model?, pos: Vector3, t: number)
	Sfx.at("WoodBreak", pos, { Volume = 1.4, PlaybackSpeed = 0.6 })
	Sfx.at("PunchHeavy", pos, { Volume = 1.3, PlaybackSpeed = 0.4 })
	burst(pos + Vector3.new(0, 3, 0), Color3.fromRGB(90, 70, 50), 20, 0.5, 14, "rbxasset://textures/particles/sparkles_main.dds")
	burst(pos + Vector3.new(0, 3, 0), Color3.fromRGB(130, 116, 96), 12, 2, 6)
	shakeNear(pos, 70, 0.8)
	-- he snorts and pulls at it
	local h = hrpOf(model)
	if h then
		for i = 1, 2 do
			task.delay(t * i / 3, function() if h.Parent then Sfx.at("BullSnort", h.Position, { Volume = 1.2, PlaybackSpeed = 0.8 }) end end)
		end
	end
end

-- THE LAKE WITCH's grasp: black water wells up where you stand, then the drowned hands come up through it
local SKIN_D = Color3.fromRGB(104, 122, 112)
local graspDisc: BasePart? = nil
local function graspWarn(model: Model?, spot: Vector3, radius: number, t: number)
	local cf = CFrame.new(spot + Vector3.new(0, 0.08, 0)) * A(0, 0, math.pi / 2)
	local disc = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, 1, 1), CFrame = cf, Color = Color3.fromRGB(10, 22, 24),
		Material = Enum.Material.SmoothPlastic, Reflectance = 0.25, Transparency = 0.08 })
	local ring = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.1, radius * 2 + 0.6, radius * 2 + 0.6), CFrame = cf * CFrame.new(-0.02, 0, 0),
		Color = Color3.fromRGB(60, 150, 130), Material = Enum.Material.Neon, Transparency = 0.6 })
	TweenService:Create(disc, TweenInfo.new(t * 0.7, Enum.EasingStyle.Quad), { Size = Vector3.new(0.12, radius * 2, radius * 2) }):Play()
	TweenService:Create(ring, TweenInfo.new(t, Enum.EasingStyle.Linear), { Transparency = 0.2 }):Play()
	-- bubbles coming up through it
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(Color3.fromRGB(120, 180, 170))
	e.Size = NumberSequence.new(0.25); e.Transparency = NumberSequence.new(0.3)
	e.Lifetime = NumberRange.new(0.3, 0.6); e.Rate = 30; e.Speed = NumberRange.new(2, 4)
	e.EmissionDirection = Enum.NormalId.Right; e.SpreadAngle = Vector2.new(60, 60)
	e.Parent = disc
	if graspDisc then graspDisc:Destroy() end
	graspDisc = disc
	Debris:AddItem(ring, t + 0.1)
	Debris:AddItem(disc, t + 4)
	Sfx.at("Bubbles", spot, { Volume = 1 })
	task.delay(t * 0.5, function() Sfx.at("Bubbles", spot, { Volume = 1, PlaybackSpeed = 0.8 }) end)
	local h = hrpOf(model)
	if h then Sfx.at("GhostWhisper", h.Position, { Volume = 0.8, PlaybackSpeed = 0.7 }) end
end
local function makeHand(): Rig
	local r: Rig = { parts = {} }
	local base = { Anchored = true, Color = SKIN_D, Material = Enum.Material.SmoothPlastic }
	local function P(size: Vector3, rel: CFrame, color: Color3?)
		local props = table.clone(base); props.Size = size; if color then props.Color = color end
		rigAdd(r, rel, props)
	end
	P(Vector3.new(0.75, 2.8, 0.7), CFrame.new(0, -1.4, 0)) -- forearm
	P(Vector3.new(0.8, 0.3, 0.75), CFrame.new(0, -0.6, 0), Color3.fromRGB(60, 72, 60)) -- a rag of sleeve
	P(Vector3.new(1.0, 0.9, 0.42), CFrame.new(0, 0.45, 0)) -- palm
	for i = 0, 3 do
		local x = -0.36 + i * 0.24
		P(Vector3.new(0.18, 0.8, 0.18), CFrame.new(x, 1.2, 0) * A(0.35, 0, (x) * -0.4) * CFrame.new(0, 0, 0))
		P(Vector3.new(0.17, 0.12, 0.17), CFrame.new(x, 1.62, 0.12) * A(0.35, 0, 0), Color3.fromRGB(40, 44, 40)) -- black nails
	end
	P(Vector3.new(0.2, 0.6, 0.2), CFrame.new(0.55, 0.5, 0) * A(0, 0, -0.8)) -- thumb
	return r
end
local function graspHands(spot: Vector3, radius: number, hold: number)
	local hands = {}
	local n = 6
	for i = 0, n do
		local p: Vector3
		if i == n then p = spot else
			local ang = i / n * math.pi * 2 + math.random() * 0.4
			p = spot + Vector3.new(math.cos(ang), 0, math.sin(ang)) * radius * (0.45 + math.random() * 0.35)
		end
		local yaw = math.random() * math.pi * 2
		local tilt = (math.random() - 0.5) * 0.5
		table.insert(hands, { r = makeHand(), pos = p, yaw = yaw, tilt = tilt, delay = math.random() * 0.15, wig = math.random() * 6 })
	end
	burst(spot + Vector3.new(0, 0.6, 0), Color3.fromRGB(60, 110, 110), 26, 1.0, 14)
	Sfx.at("FormGulp", spot, { Volume = 1.2, PlaybackSpeed = 0.5 })
	Sfx.at("Bubbles", spot, { Volume = 1.2, PlaybackSpeed = 0.6 })
	shakeNear(spot, 40, 0.3)
	local t0 = os.clock()
	local total = hold + 0.5
	local conn: RBXScriptConnection
	conn = RunService.RenderStepped:Connect(function()
		local t = os.clock() - t0
		for _, hd in hands do
			local u = math.clamp((t - hd.delay) / 0.18, 0, 1) -- up fast
			local down = math.clamp((t - hold) / 0.5, 0, 1) -- then back under
			local y = -3.2 + (u * u) * 3.4 - down * 3.6
			local grab = math.sin(t * 9 + hd.wig) * 0.12
			local cf = CFrame.new(hd.pos + Vector3.new(0, y, 0)) * A(0, hd.yaw, 0) * A(hd.tilt + grab, 0, grab)
			rigPlace(hd.r, cf)
		end
		if t > total then
			conn:Disconnect()
			for _, hd in hands do rigDestroy(hd.r) end
		end
	end)
	local d = graspDisc
	if d then
		task.delay(hold, function()
			if d.Parent then TweenService:Create(d, TweenInfo.new(0.8), { Transparency = 1 }):Play() end
		end)
	end
end

-- THE BURNED COUNSELOR's run: the scream with the torch flaring, the panting after
local function torchTip(model: Model?): Vector3?
	local f = model and model:FindFirstChild("Flame") :: BasePart?
	return f and f.Position or nil
end
local function counselorScream(model: Model?, t: number)
	local h = hrpOf(model)
	if not h then return end
	Sfx.at("GhostScream", h.Position, { Volume = 1.1, PlaybackSpeed = 0.7 })
	local tip = torchTip(model)
	if tip then
		burst(tip, Color3.fromRGB(255, 140, 40), 30, 0.45, 16, "rbxasset://textures/particles/sparkles_main.dds")
		Sfx.at("Flamethrower", tip, { Volume = 0.8, PlaybackSpeed = 0.9 })
	end
	shakeNear(h.Position, 50, 0.3)
end
local function counselorPant(model: Model?, t: number)
	local head = model and model:FindFirstChild("Head") :: BasePart?
	if not head then return end
	for i = 0, math.floor(t / 0.45) do
		task.delay(i * 0.45, function()
			if head.Parent then burst(head.Position + head.CFrame.LookVector * 0.8, Color3.fromRGB(70, 66, 62), 4, 0.6, 2) end
		end)
	end
end

-- THE SCARECROW's crows: they gather and circle on him, then burst out at you; blinded = pecked at, black wings
local BLACK = Color3.fromRGB(22, 21, 26)
local CROW = 1.4 -- (their size)
type Crow = { r: Rig, wl: BasePart, wr: BasePart, cf: CFrame, phase: number }
local function makeCrow(): Crow
	local r: Rig = { parts = {} }
	local function P(size: Vector3, rel: CFrame, color: Color3?): BasePart
		return rigAdd(r, rel, { Size = size, Color = color or BLACK, Material = Enum.Material.SmoothPlastic })
	end
	local K = CROW
	P(Vector3.new(0.45, 0.42, 0.95) * K, CFrame.new()) -- body
	P(Vector3.new(0.34, 0.34, 0.36) * K, CFrame.new(0, 0.18 * K, -0.6 * K)) -- head
	P(Vector3.new(0.1, 0.1, 0.32) * K, CFrame.new(0, 0.14 * K, -0.9 * K), Color3.fromRGB(70, 66, 60)) -- beak
	P(Vector3.new(0.36, 0.06, 0.5) * K, CFrame.new(0, 0.05 * K, 0.65 * K)) -- tail
	-- the wings are placed every frame (flapping), not by the rig
	local wl = part({ Size = Vector3.new(1.0, 0.05, 0.55) * K, Color = BLACK, Material = Enum.Material.SmoothPlastic })
	local wr = part({ Size = Vector3.new(1.0, 0.05, 0.55) * K, Color = BLACK, Material = Enum.Material.SmoothPlastic })
	return { r = r, wl = wl, wr = wr, cf = CFrame.new(), phase = math.random() * 6 }
end
local function placeCrow(c: Crow, cf: CFrame, t: number)
	c.cf = cf
	rigPlace(c.r, cf)
	local f = math.sin(t * 28 + c.phase) * 0.9
	c.wl.CFrame = cf * CFrame.new(-0.22 * CROW, 0.12 * CROW, 0) * A(0, 0, f) * CFrame.new(-0.5 * CROW, 0, 0)
	c.wr.CFrame = cf * CFrame.new(0.22 * CROW, 0.12 * CROW, 0) * A(0, 0, -f) * CFrame.new(0.5 * CROW, 0, 0)
end
local function crowGone(c: Crow)
	rigDestroy(c.r); c.wl:Destroy(); c.wr:Destroy()
end
local flocks: { [Model]: { crows: { Crow }, conn: RBXScriptConnection? } } = {}
local function crowsGather(model: Model?, t: number)
	local h = hrpOf(model)
	if not model or not h then return end
	local old = flocks[model]
	if old then
		if old.conn then old.conn:Disconnect() end
		for _, c in old.crows do crowGone(c) end
	end
	local fl = { crows = {} :: { Crow }, conn = nil :: RBXScriptConnection? }
	flocks[model] = fl
	for _ = 1, 12 do table.insert(fl.crows, makeCrow()) end
	local t0 = os.clock()
	fl.conn = RunService.RenderStepped:Connect(function()
		local hh = hrpOf(model)
		if not hh then return end
		local tt = os.clock() - t0
		local k = math.min(1, tt / 0.6) -- (they fly in from far)
		for i, c in fl.crows do
			local ang = tt * 3.2 + i / #fl.crows * math.pi * 2
			local rad = 2.6 + (1 - k) * 14 + math.sin(i * 1.7) * 0.6
			local p = hh.Position + Vector3.new(math.cos(ang) * rad, 1.6 + math.sin(i * 2.3) * 1.2 + (1 - k) * 6, math.sin(ang) * rad)
			local fwd = Vector3.new(-math.sin(ang), 0, math.cos(ang))
			placeCrow(c, CFrame.lookAt(p, p + fwd), tt)
		end
	end)
	Sfx.at("CrowCaw", h.Position, { Volume = 1 })
	task.delay(t * 0.4, function() Sfx.at("CrowCaw", h.Position, { Volume = 1, PlaybackSpeed = 0.9 }) end)
	Sfx.at("CrowFlock", h.Position, { Volume = 0.6 })
	task.delay(t + 3, function()
		-- (never left behind if the burst never came)
		if flocks[model] == fl then
			if fl.conn then fl.conn:Disconnect() end
			for _, c in fl.crows do crowGone(c) end
			flocks[model] = nil
		end
	end)
end
local function crowsBurst(model: Model?, dir: Vector3, t: number, range: number)
	local h = hrpOf(model)
	if not model or not h then return end
	local fl = flocks[model]
	if not fl then crowsGather(model, 0.01); fl = flocks[model] end
	if not fl then return end
	if fl.conn then fl.conn:Disconnect() end
	-- each crow flies out along the cone, at its own angle and distance, then scatters up and away
	local paths = {}
	local right = dir:Cross(Vector3.yAxis)
	right = right.Magnitude > 0.01 and right.Unit or Vector3.xAxis
	for i, c in fl.crows do
		local spread = (math.random() - 0.5) * 1.1
		local lift = (math.random() - 0.4) * 0.5
		local d = (dir + right * spread + Vector3.new(0, lift, 0)).Unit
		table.insert(paths, { c = c, from = c.cf.Position, d = d, len = range * (0.65 + math.random() * 0.4), delay = (i - 1) * 0.04 })
	end
	local t0 = os.clock()
	fl.conn = RunService.RenderStepped:Connect(function()
		local tt = os.clock() - t0
		for _, pth in paths do
			local u = math.clamp((tt - pth.delay) / (t * 0.7), 0, 1)
			local p = pth.from + pth.d * pth.len * u
			if u >= 1 then
				-- scatter: up and off
				local s = tt - pth.delay - t * 0.7
				p += Vector3.new(math.sin(s * 5 + pth.len) * 3, s * 14, math.cos(s * 4) * 3)
			end
			placeCrow(pth.c, CFrame.lookAt(p, p + pth.d), tt)
		end
		if tt > t + 1.2 then
			if fl.conn then fl.conn:Disconnect() end
			for _, c in fl.crows do crowGone(c) end
			if flocks[model] == fl then flocks[model] = nil end
		end
	end)
	Sfx.at("CrowFlock", h.Position, { Volume = 1.2 })
	for i = 1, 3 do
		task.delay(i * 0.25, function() Sfx.at("CrowCaw", h.Position + dir * range * 0.4, { Volume = 1.1, PlaybackSpeed = 0.9 + i * 0.08 }) end)
	end
end
local blindGui: ScreenGui? = nil
local function blinded(t: number)
	local pg = lp:FindFirstChildOfClass("PlayerGui")
	if not pg then return end
	if blindGui then blindGui:Destroy() end
	local g = Instance.new("ScreenGui")
	g.Name = "Blinded"; g.ResetOnSpawn = false; g.IgnoreGuiInset = true; g.DisplayOrder = 40
	g.Parent = pg
	blindGui = g
	local back = Instance.new("Frame")
	back.Size = UDim2.fromScale(1, 1); back.BackgroundColor3 = Color3.new(0, 0, 0); back.BackgroundTransparency = 0.04; back.BorderSizePixel = 0
	back.Parent = g
	-- black wings beating across the screen
	local wings = {}
	for i = 1, 9 do
		local w = Instance.new("Frame")
		w.AnchorPoint = Vector2.new(0.5, 0.5)
		w.Size = UDim2.fromScale(0.35 + math.random() * 0.25, 0.08 + math.random() * 0.05)
		w.Position = UDim2.fromScale(math.random(), math.random())
		w.BackgroundColor3 = Color3.fromRGB(26, 24, 28); w.BorderSizePixel = 0
		w.Rotation = math.random(-40, 40)
		w.Parent = g
		table.insert(wings, { f = w, ph = math.random() * 6, rot = w.Rotation })
	end
	local t0 = os.clock()
	local conn: RBXScriptConnection
	conn = RunService.RenderStepped:Connect(function()
		local tt = os.clock() - t0
		local fade = math.clamp((tt - 0.7) / math.max(0.2, t - 0.7), 0, 1)
		back.BackgroundTransparency = 0.04 + fade * 0.96
		for _, w in wings do
			w.f.Rotation = w.rot + math.sin(tt * 26 + w.ph) * 25
			w.f.BackgroundTransparency = math.min(1, fade * 1.3 + (math.sin(tt * 13 + w.ph) > 0.6 and 0.5 or 0))
		end
		if tt > t or blindGui ~= g then
			conn:Disconnect()
			g:Destroy()
			if blindGui == g then blindGui = nil end
		end
	end)
	Sfx.play("CrowFlock", { Volume = 0.9 })
	Sfx.play("CrowCaw", { Volume = 1 })
	if Fx then Fx.shake(0.5) end
end

-- THE SCARECROW's sickle: thrown spinning flat, out past you and back to his hand
local sickles: { [Model]: { conn: RBXScriptConnection, parts: { BasePart }, flying: Rig } } = {}
local function sickleParts(model: Model): { BasePart }
	local out = {}
	for _, p in model:GetChildren() do
		if p:IsA("BasePart") and (p.Name == "SickleHandle" or p.Name == "Blade") then table.insert(out, p) end
	end
	return out
end
local function sickleDone(model: Model)
	local s = sickles[model]
	if not s then return end
	s.conn:Disconnect()
	rigDestroy(s.flying)
	for _, p in s.parts do p:SetAttribute("LocalHide", nil) end
	sickles[model] = nil
end
local function sickleThrow(model: Model?, from: Vector3, to: Vector3, flight: number)
	if not model then return end
	sickleDone(model)
	local ps = sickleParts(model)
	local handle: BasePart? = nil
	for _, p in ps do if p.Name == "SickleHandle" then handle = p end end
	-- a flying copy of his sickle, lying flat and spinning
	local flying: Rig = { parts = {} }
	if handle then
		for _, p in ps do
			rigAdd(flying, A(math.pi / 2, 0, 0) * handle.CFrame:ToObjectSpace(p.CFrame), { Size = p.Size, Color = p.Color, Material = p.Material })
		end
	end
	for _, p in ps do p:SetAttribute("LocalHide", true) end -- (Client/GhostAnim keeps them hidden)
	local t0 = os.clock()
	local lastWhoosh = 0
	local conn = RunService.RenderStepped:Connect(function()
		local tt = os.clock() - t0
		local u = tt / flight
		local p: Vector3
		if u <= 1 then p = from:Lerp(to, u) else
			local hand = model:FindFirstChild("RightHand") :: BasePart?
			p = to:Lerp(hand and hand.Position or from, math.min(1, u - 1))
		end
		rigPlace(flying, CFrame.new(p) * A(0, -tt * 24, 0))
		if tt - lastWhoosh > 0.16 then
			lastWhoosh = tt
			Sfx.at("Whoosh", p, { Volume = 0.7, PlaybackSpeed = 1.4 })
		end
		if u >= 2 then sickleDone(model) end
	end)
	sickles[model] = { conn = conn, parts = ps, flying = flying }
	task.delay(flight * 2 + 1, function() if sickles[model] and sickles[model].conn == conn then sickleDone(model) end end)
end

function CF.handle(kind: string, ...)
	local a = table.pack(...)
	if kind == "AntlerClimb" then
		local m = a[1] :: Model?
		local hrp = m and m:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then Sfx.at("DoorCreak", hrp.Position, { Volume = 1.1, PlaybackSpeed = 0.55 }) end
	elseif kind == "DropWarn" then dropWarn(a[1], a[2], a[3])
	elseif kind == "DropLand" then dropLand(a[1], a[2])
	elseif kind == "HookWind" then
		local p = handOf(a[1])
		if p then Sfx.at("ShieldBlock", p, { Volume = 0.6, PlaybackSpeed = 1.6 }) end
	elseif kind == "HookThrow" then hookThrow(a[1], a[2], a[3], a[4], a[5])
	elseif kind == "HookCatch" then
		if hook then hook.done = true; hook.victim = a[2]; hook.untilT = os.clock() + (a[3] or 1) end
		Sfx.play("PunchHeavy", { Volume = 0.8, PlaybackSpeed = 1.3 })
	elseif kind == "HookPull" then hookPull(a[1], a[2], a[3])
	elseif kind == "HookMiss" then
		local pos = a[2]
		if typeof(pos) == "Vector3" then Sfx.at("ShieldBlock", pos, { Volume = 0.8 }) end
		clearHook()
	elseif kind == "HookDrown" then
		burst(a[1], Color3.fromRGB(120, 180, 190), 24, 1.2, 10)
		Sfx.at("FormGulp", a[1], { Volume = 1, PlaybackSpeed = 0.6 })
		clearHook()
		released()
	elseif kind == "FloodStart" then floodStart(a[1])
	elseif kind == "FloodEnd" then
		if water then water:Destroy(); water = nil end
		clearHook()
		released()
	elseif kind == "TorchWind" then
		local m = a[1] :: Model?
		local hrp = m and m:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then Sfx.at("Whoosh", hrp.Position, { Volume = 0.8, PlaybackSpeed = 0.6 }) end
	elseif kind == "TorchThrow" then torchThrow(a[2], a[3], a[4])
	elseif kind == "TorchLand" then torchLand(a[1])
	elseif kind == "ScareSwap" then
		straw(a[1]); straw(a[2])
		Sfx.at("Whoosh", a[1], { Volume = 0.8, PlaybackSpeed = 0.5 })
	elseif kind == "ChargeLine" then chargeLine(a[1], a[2], a[3], a[4], a[5])
	elseif kind == "ChargeGo" then chargeGo(a[1], a[2])
	elseif kind == "ChargeSmash" then chargeSmash(a[1])
	elseif kind == "AntlersStuck" then antlersStuck(a[1], a[2], a[3])
	elseif kind == "FloodCall" then
		local h = hrpOf(a[1])
		if h then
			Sfx.at("GhostWail", h.Position, { Volume = 1, PlaybackSpeed = 0.6 })
			Sfx.at("Bubbles", h.Position, { Volume = 1 })
		end
	elseif kind == "GraspWarn" then graspWarn(a[1], a[2], a[3], a[4])
	elseif kind == "GraspHands" then graspHands(a[1], a[2], a[3])
	elseif kind == "CounselorScream" then counselorScream(a[1], a[2])
	elseif kind == "CounselorPant" then counselorPant(a[1], a[2])
	elseif kind == "CrowsGather" then crowsGather(a[1], a[2])
	elseif kind == "Crows" then crowsBurst(a[1], a[2], a[3], a[4])
	elseif kind == "Blinded" then blinded(a[1])
	elseif kind == "SickleWind" then
		local h = hrpOf(a[1])
		if h then Sfx.at("BladeScrape", h.Position, { Volume = 1 }) end
	elseif kind == "SickleThrow" then sickleThrow(a[1], a[2], a[3], a[4])
	elseif kind == "SickleDrop" then if a[1] then sickleDone(a[1]) end
	end
end

-- the hook in flight / the chain to its victim, every frame
RunService.RenderStepped:Connect(function()
	local h = hook
	if not h then return end
	local from = handOf(h.model) or h.from
	if os.clock() > h.untilT then clearHook(); return end
	if h.done then
		local v = h.victim
		local vh = v and v.Character and v.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if vh then
			h.head.CFrame = CFrame.new(vh.Position + Vector3.new(0, 0.5, 0))
			placeChain(h.chain, from, vh.Position)
		end
	else
		local d = math.min(h.len, (os.clock() - h.t0) * h.speed)
		local p = h.from + h.dir * d
		h.head.CFrame = CFrame.lookAt(p, p + h.dir) * CFrame.Angles(math.pi / 2, 0, 0)
		placeChain(h.chain, from, p)
	end
end)

return CF
