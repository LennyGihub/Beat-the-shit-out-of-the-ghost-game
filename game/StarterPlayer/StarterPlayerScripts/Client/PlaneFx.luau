-- Plane crash cinematic: a burning plane dives out of the sky toward the yard, camera follows it, boom.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Sfx = require(script.Parent.Sfx)

local PlaneFx = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Fx -- set in init (avoid require cycle)

local function bezier(a: Vector3, b: Vector3, c: Vector3, t: number): Vector3
	return a:Lerp(b, t):Lerp(b:Lerp(c, t), t)
end

function PlaneFx.crash(land: Vector3, from: Vector3)
	local tpl = RS:FindFirstChild("PlaneModel") :: Model?
	if not tpl then return end
	local plane = tpl:Clone()
	for _, p in plane:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false; p.CanQuery = false end
	end
	plane.Parent = workspace
	local side = (land - from)
	side = Vector3.new(side.X, 0, side.Z).Unit:Cross(Vector3.yAxis)
	local start = land + side * 320 + Vector3.new(0, 170, 0) + (land - from).Unit * 120
	local mid = land + side * 130 + Vector3.new(0, 110, 0)
	local body = plane:FindFirstChild("Body", true) :: BasePart?
	local engine
	if body then
		local smoke = Instance.new("Smoke"); smoke.Color = Color3.fromRGB(30, 28, 26); smoke.Size = 10; smoke.RiseVelocity = 2; smoke.Opacity = 0.5; smoke.Parent = body
		local fire = Instance.new("Fire"); fire.Size = 10; fire.Heat = 14; fire.Parent = body
		engine = Sfx.loop("PlaneEngine", { Volume = 1.2 })
	end
	-- cinematic camera from the player's eyes
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local eye = hrp and (hrp.Position + Vector3.new(0, 1.5, 0)) or from
	local prevType = cam.CameraType
	cam.CameraType = Enum.CameraType.Scriptable
	local t0 = os.clock()
	local dur = 4.2
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local a = math.min(1, (os.clock() - t0) / dur)
		local e = a * a
		local pos = bezier(start, mid, land + Vector3.new(0, 3, 0), e)
		local ahead = bezier(start, mid, land + Vector3.new(0, 3, 0), math.min(1, e + 0.02))
		local dir = (ahead - pos).Magnitude > 0.01 and (ahead - pos).Unit or Vector3.new(0, -1, 0)
		plane:PivotTo(CFrame.lookAt(pos, pos + dir) * CFrame.Angles(0, 0, os.clock() * 1.7))
		if engine then engine.PlaybackSpeed = 0.8 + a * 0.6 + math.sin(os.clock() * 30) * 0.05 end
		cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(eye, pos), 0.15)
		if a >= 1 then
			conn:Disconnect()
			plane:Destroy()
			if engine then engine:Destroy() end
		end
	end)
	task.delay(dur + 2.2, function()
		cam.CameraType = prevType == Enum.CameraType.Scriptable and Enum.CameraType.Custom or prevType
	end)
end

function PlaneFx.impact(land: Vector3)
	Sfx.at("Explosion", land, { Volume = 1.6, RollOffMaxDistance = 600 })
	Sfx.at("Crash", land, { Volume = 1.3, RollOffMaxDistance = 400 })
	local ex = Instance.new("Explosion")
	ex.Position = land + Vector3.new(0, 4, 0)
	ex.BlastPressure = 0
	ex.BlastRadius = 30
	ex.DestroyJointRadiusPercent = 0
	ex.ExplosionType = Enum.ExplosionType.NoCraters
	ex.Parent = workspace
	local d = (cam.CFrame.Position - land).Magnitude
	if Fx then
		Fx.shake(math.clamp(1.4 - d / 200, 0.3, 1.2))
		Fx.kick(10)
	end
	local flash = Instance.new("Part")
	flash.Shape = Enum.PartType.Ball; flash.Material = Enum.Material.Neon; flash.Color = Color3.fromRGB(255, 170, 60)
	flash.Anchored = true; flash.CanCollide = false; flash.CanQuery = false; flash.Size = Vector3.one * 8
	flash.Position = land + Vector3.new(0, 4, 0); flash.Parent = workspace.Terrain
	local l = Instance.new("PointLight"); l.Range = 120; l.Brightness = 6; l.Color = Color3.fromRGB(255, 150, 60); l.Parent = flash
	game:GetService("TweenService"):Create(flash, TweenInfo.new(1), { Size = Vector3.one * 60, Transparency = 1 }):Play()
	game:GetService("TweenService"):Create(l, TweenInfo.new(1.5), { Brightness = 0 }):Play()
	Debris:AddItem(flash, 1.6)
end

function PlaneFx.init(fx) Fx = fx end

return PlaneFx
