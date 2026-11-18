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
	"FloodStart", "FloodEnd", "TorchWind", "TorchThrow", "TorchLand", "ScareSwap" }
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
