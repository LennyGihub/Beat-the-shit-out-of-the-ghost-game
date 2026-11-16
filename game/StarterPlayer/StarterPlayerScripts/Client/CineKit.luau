-- Shared pieces of the event cinematics (van, train: EventFx; plane: PlaneFx). Everything here is client-only:
-- an animated copy of the vehicle (spinning wheels / propellers), the "watch it from your own eyes" camera,
-- dust, sparks, debris, ground marks and the explosion.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Sfx = require(script.Parent.Sfx)

local Kit = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local rng = Random.new()
local Fx: any = nil
function Kit.init(fx) Fx = fx end

function Kit.shake(n: number) if Fx then Fx.shake(n) end end
function Kit.kick(n: number) if Fx then Fx.kick(n) end end
-- 1 next to the camera, 0 at dist studs and beyond
function Kit.near(pos: Vector3, dist: number): number
	local d = (cam.CFrame.Position - pos).Magnitude
	return d < dist and (1 - d / dist) or 0
end

-- an anchored, non-colliding copy of an event model. spin = { [part name] = "x" | "z" }: parts that turn on their
-- own axis (wheels: x, propellers: z). rig.place(cf) moves it, rig.turn(name, radians) turns those parts.
export type Rig = { model: Model, place: (cf: CFrame) -> (), turn: (name: string, da: number) -> (), part: (name: string) -> BasePart?, destroy: () -> (), cf: CFrame }
function Kit.rig(template: Instance?, spin: { [string]: string }?): Rig?
	if not template or not template:IsA("Model") then return nil end
	local m = template:Clone()
	m.Name = "Cine_" .. template.Name
	local pivot = m:GetPivot()
	local spinners = {} :: { { p: BasePart, rel: CFrame, axis: string, name: string } }
	local angles = {} :: { [string]: number }
	for _, p in m:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
			if spin and spin[p.Name] then
				table.insert(spinners, { p = p, rel = pivot:ToObjectSpace(p.CFrame), axis = spin[p.Name], name = p.Name })
				angles[p.Name] = 0
			end
		end
	end
	m.Parent = workspace
	local rig = { model = m, cf = pivot } :: any
	function rig.place(cf: CFrame)
		rig.cf = cf
		m:PivotTo(cf)
		for _, s in spinners do
			local a = angles[s.name]
			s.p.CFrame = cf * s.rel * (s.axis == "x" and CFrame.Angles(a, 0, 0) or CFrame.Angles(0, 0, a))
		end
	end
	function rig.turn(name: string, da: number) angles[name] = (angles[name] or 0) + da end
	function rig.part(name: string): BasePart? return m:FindFirstChild(name, true) :: BasePart? end
	function rig.destroy() m:Destroy() end
	return rig
end

-- the animation is over: keep the copy until the server's real wreck shows up (no gap), at most `max` seconds
function Kit.handOff(rig: Rig, wreckName: string, max: number)
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < max and not workspace:FindFirstChild(wreckName) do task.wait() end
		task.wait(0.05)
		rig.destroy()
	end)
end

-- A cinematic shot: the camera leaves the player, stands at camPos() and follows target() for dur seconds, with
-- letterbox bars, the HUD hidden and the yard lit well enough to see (Fx.cine); then everything goes back.
-- fov = the zoom while the target is far (it widens as it comes close).
local shotToken = 0
function Kit.shot(camPos: () -> Vector3, target: () -> Vector3?, dur: number, fov: number?)
	shotToken += 1
	local token = shotToken
	local pg = lp:FindFirstChildOfClass("PlayerGui")
	local hidden = {} :: { ScreenGui }
	if pg then
		for _, g in pg:GetChildren() do -- every screen of the game's UI, back on afterwards
			if g:IsA("ScreenGui") and g.Enabled and g.Name ~= "CineBars" then g.Enabled = false; table.insert(hidden, g) end
		end
	end
	local bars = Instance.new("ScreenGui")
	bars.Name = "CineBars"; bars.IgnoreGuiInset = true; bars.DisplayOrder = 60; bars.ResetOnSpawn = false
	bars.Parent = pg
	local frames = {}
	for _, top in { true, false } do
		local f = Instance.new("Frame")
		f.BackgroundColor3 = Color3.new(0, 0, 0); f.BorderSizePixel = 0; f.AnchorPoint = Vector2.new(0, top and 1 or 0)
		f.Position = UDim2.fromScale(0, top and 0 or 1); f.Size = UDim2.fromScale(1, 0.11); f.Parent = bars
		TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { AnchorPoint = Vector2.new(0, top and 0 or 1) }):Play()
		table.insert(frames, { f = f, top = top })
	end
	if Fx then Fx.cine = true end
	local look: Vector3? = nil
	local t0 = os.clock()
	local name = "CineCam" .. token
	local function finish()
		RunService:UnbindFromRenderStep(name)
		for _, b in frames do
			TweenService:Create(b.f, TweenInfo.new(0.3), { AnchorPoint = Vector2.new(0, b.top and 1 or 0) }):Play()
		end
		Debris:AddItem(bars, 0.4)
		for _, g in hidden do g.Enabled = true end
		if token == shotToken then
			if Fx then Fx.cine = false; Fx.cineFov = nil end
			cam.CameraType = Enum.CameraType.Custom
		end
	end
	-- before Fx's shake step, so the shake lands on top of the shot
	RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value, function(dt)
		if token ~= shotToken or os.clock() - t0 > dur then finish(); return end
		local eye = camPos()
		local tp = target()
		if tp then look = look and look:Lerp(tp, math.min(1, dt * 10)) or tp end
		if not look then return end
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = CFrame.lookAt(eye, look)
		cam.Focus = CFrame.new(look)
		if fov and Fx then
			local d = (look - eye).Magnitude
			local want = 70 + (fov - 70) * math.clamp((d - 50) / 220, 0, 1)
			Fx.cineFov = (Fx.cineFov or 70) + (want - (Fx.cineFov or 70)) * math.min(1, dt * 4)
		end
	end)
end

local function base(props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do (p :: any)[k] = v end
	p.Parent = workspace.Terrain
	return p
end

-- one burst of particles at a point
function Kit.burst(pos: Vector3, props: { [string]: any }, n: number, life: number?)
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.SpreadAngle = Vector2.new(180, 180); pe.Rate = 0
	for k, v in props do (pe :: any)[k] = v end
	pe.Parent = a
	pe:Emit(n)
	Debris:AddItem(a, life or 4)
end
function Kit.dust(pos: Vector3, size: number, n: number, color: Color3?)
	Kit.burst(pos, { Color = ColorSequence.new(color or Color3.fromRGB(120, 104, 84)), Size = NumberSequence.new(size * 0.5, size * 1.6),
		Transparency = NumberSequence.new(0.35, 1), Speed = NumberRange.new(6, 18), Lifetime = NumberRange.new(0.8, 1.8), Drag = 3,
		SpreadAngle = Vector2.new(180, 40), Acceleration = Vector3.new(0, 3, 0) }, n)
end
function Kit.sparks(pos: Vector3, n: number, dir: Vector3?)
	Kit.burst(pos, { Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 200, 90)),
		LightEmission = 1, Size = NumberSequence.new(0.5, 0), Speed = NumberRange.new(20, 45), Lifetime = NumberRange.new(0.15, 0.5),
		Acceleration = Vector3.new(0, -60, 0), SpreadAngle = Vector2.new(50, 50), EmissionDirection = Enum.NormalId.Top }, n, 1.5)
	local _ = dir
end
-- an emitter that keeps running on a part of the rig (exhaust, dust behind the wheels, smoke trail)
function Kit.emitter(part: BasePart, props: { [string]: any }): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	for k, v in props do (pe :: any)[k] = v end
	pe.Parent = part
	return pe
end

-- chunks that fly off and bounce (planks, bricks, scrap metal)
function Kit.debris(pos: Vector3, n: number, colors: { Color3 }, mat: Enum.Material, dir: Vector3, speed: number, size: number?)
	local s = size or 1
	for _ = 1, n do
		local p = base({ Material = mat, Color = colors[rng:NextInteger(1, #colors)],
			Size = Vector3.new(rng:NextNumber(0.4, 2.4), rng:NextNumber(0.25, 0.7), rng:NextNumber(0.4, 1.4)) * s,
			CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-3, 3), rng:NextNumber(0, 4), rng:NextNumber(-3, 3))) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0) })
		p.Anchored = false; p.CanCollide = true
		p.AssemblyLinearVelocity = dir * speed * rng:NextNumber(0.4, 1.1) + Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(0.4, 1.3), rng:NextNumber(-1, 1)) * speed * 0.5
		p.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-18, 18), rng:NextNumber(-18, 18), rng:NextNumber(-18, 18))
		Debris:AddItem(p, rng:NextNumber(5, 9))
	end
end

-- a dark mark left on the ground (skid, furrow); fades after a while
function Kit.mark(at: Vector3, dir: Vector3, len: number, width: number, color: Color3?)
	local flat = Vector3.new(dir.X, 0, dir.Z)
	if flat.Magnitude < 0.01 then return end
	local p = base({ Material = Enum.Material.Mud, Color = color or Color3.fromRGB(26, 22, 18), Size = Vector3.new(width, 0.08, len),
		CFrame = CFrame.lookAt(Vector3.new(at.X, 0.16, at.Z), Vector3.new(at.X, 0.16, at.Z) + flat) })
	task.delay(22, function()
		if p.Parent then TweenService:Create(p, TweenInfo.new(3), { Transparency = 1 }):Play() end
	end)
	Debris:AddItem(p, 26)
end

-- the explosion: fireball, flash, a shockwave ring on the ground, a smoke column, sound, shake
function Kit.boom(pos: Vector3, size: number)
	Sfx.at("Explosion", pos, { Volume = 1.6, PlaybackSpeed = rng:NextNumber(0.9, 1.1), RollOffMaxDistance = 600 })
	Sfx.at("Crash", pos, { Volume = 1.4, RollOffMaxDistance = 450 })
	local ball = base({ Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 190, 90), Size = Vector3.one * size * 0.15, Position = pos })
	local l = Instance.new("PointLight"); l.Range = size * 3; l.Brightness = 6; l.Color = Color3.fromRGB(255, 150, 60); l.Parent = ball
	TweenService:Create(ball, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * size, Transparency = 1, Color = Color3.fromRGB(255, 90, 30) }):Play()
	TweenService:Create(l, TweenInfo.new(1.2), { Brightness = 0 }):Play()
	Debris:AddItem(ball, 1.3)
	local ring = base({ Shape = Enum.PartType.Cylinder, Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 220, 170), Transparency = 0.35,
		Size = Vector3.new(0.4, 4, 4), CFrame = CFrame.new(pos.X, 0.5, pos.Z) * CFrame.Angles(0, 0, math.pi / 2) })
	TweenService:Create(ring, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.4, size * 2.6, size * 2.6), Transparency = 1 }):Play()
	Debris:AddItem(ring, 0.8)
	-- fire and a column of black smoke
	Kit.burst(pos, { Texture = "rbxasset://textures/particles/fire_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 170, 60), Color3.fromRGB(200, 50, 20)),
		LightEmission = 0.8, Size = NumberSequence.new(size * 0.18, size * 0.4), Transparency = NumberSequence.new(0.1, 1), Speed = NumberRange.new(size * 0.4, size),
		Lifetime = NumberRange.new(0.4, 0.9), Drag = 4 }, 40)
	Kit.burst(pos, { Color = ColorSequence.new(Color3.fromRGB(28, 26, 24)), Size = NumberSequence.new(size * 0.2, size * 0.7), Transparency = NumberSequence.new(0.3, 1),
		Speed = NumberRange.new(8, 22), Lifetime = NumberRange.new(2, 4), Drag = 2, Acceleration = Vector3.new(0, 10, 0), SpreadAngle = Vector2.new(180, 60) }, 34, 6)
	Kit.sparks(pos, 50)
	local f = Kit.near(pos, 260)
	Kit.shake(0.35 + f * 0.95)
	Kit.kick(6 + f * 8)
end

function Kit.model(name: string): Instance?
	if name == "PlaneModel" then return RS:FindFirstChild("PlaneModel") end
	local f = RS:FindFirstChild("EventModels")
	return f and f:FindFirstChild(name)
end

-- run step(a, dt, now) every frame with a going 0 -> 1 over dur seconds, then done()
function Kit.play(dur: number, step: (a: number, dt: number, now: number) -> (), done: (() -> ())?)
	local t0 = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		local now = os.clock()
		local a = math.min(1, (now - t0) / dur)
		step(a, dt, now)
		if a >= 1 then
			conn:Disconnect()
			if done then done() end
		end
	end)
end

function Kit.flat(v: Vector3): Vector3
	local f = Vector3.new(v.X, 0, v.Z)
	return f.Magnitude > 0.01 and f.Unit or Vector3.new(0, 0, -1)
end
Kit.rng = rng

return Kit
