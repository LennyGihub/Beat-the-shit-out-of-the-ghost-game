-- Client cinematics for the van and train events (the plane lives in PlaneFx).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Sfx = require(script.Parent.Sfx)

local EventFx = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Fx

local function clone(name: string): Model?
	local f = RS:FindFirstChild("EventModels")
	local t = f and f:FindFirstChild(name) :: Model?
	if not t then return nil end
	local m = t:Clone()
	for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false; p.CanQuery = false end end
	m.Parent = workspace
	return m
end

-- watch something from your own eyes for a few seconds
local function watch(getTarget: () -> Vector3?, dur: number)
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end
	local eye = hrp.Position + Vector3.new(0, 1.5, 0)
	cam.CameraType = Enum.CameraType.Scriptable
	local t0 = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local tp = getTarget()
		if tp then cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(eye, tp), 0.12) end
		if os.clock() - t0 > dur then
			conn:Disconnect()
			cam.CameraType = Enum.CameraType.Custom
		end
	end)
end

local function boom(pos: Vector3, size: number)
	Sfx.at("Crash", pos, { Volume = 1.4, RollOffMaxDistance = 400 })
	Sfx.at("Explosion", pos, { Volume = 1.1, PlaybackSpeed = 1.2, RollOffMaxDistance = 400 })
	local f = Instance.new("Part")
	f.Shape = Enum.PartType.Ball; f.Material = Enum.Material.Neon; f.Color = Color3.fromRGB(255, 170, 70)
	f.Anchored = true; f.CanCollide = false; f.CanQuery = false; f.Size = Vector3.one * 4; f.Position = pos; f.Parent = workspace.Terrain
	local l = Instance.new("PointLight"); l.Range = 80; l.Brightness = 4; l.Color = f.Color; l.Parent = f
	TweenService:Create(f, TweenInfo.new(0.8), { Size = Vector3.one * size, Transparency = 1 }):Play()
	Debris:AddItem(f, 0.9)
	if Fx then
		local d = (cam.CFrame.Position - pos).Magnitude
		Fx.shake(math.clamp(1.3 - d / 200, 0.3, 1.2))
		Fx.kick(8)
	end
end

function EventFx.van(final: CFrame)
	local v = clone("Van")
	if not v then return end
	local start = final * CFrame.new(0, 0, 150)
	local engine = Sfx.loop("PlaneEngine", { PlaybackSpeed = 1.8, Volume = 1 })
	local t0, dur = os.clock(), 2.7
	watch(function() return v.Parent and v:GetPivot().Position or nil end, dur + 1.4)
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local a = math.min(1, (os.clock() - t0) / dur)
		local e = a ^ 1.6
		local bump = math.sin(os.clock() * 25) * 0.25 * (1 - a)
		v:PivotTo(start:Lerp(final, e) * CFrame.new(0, bump, 0) * CFrame.Angles(0, math.sin(os.clock() * 6) * 0.06 * (1 - a), 0))
		if engine then engine.PlaybackSpeed = 1.4 + a * 0.8 end
		if a >= 1 then
			conn:Disconnect()
			v:Destroy()
			if engine then engine:Destroy() end
		end
	end)
end

function EventFx.train(locoCF: CFrame, w1CF: CFrame, w2CF: CFrame)
	local cars = { { clone("TrainLoco"), locoCF }, { clone("TrainWagon"), w1CF }, { clone("TrainShopWagon"), w2CF } }
	local horn = Sfx.loop("PlaneEngine", { PlaybackSpeed = 0.55, Volume = 1.2 })
	local t0, dur = os.clock(), 4
	local ONRAILS = CFrame.Angles(0, -math.pi / 2, 0)
	watch(function() local c = cars[1][1]; return c and c.Parent and c:GetPivot().Position or nil end, dur + 1.2)
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local a = math.min(1, (os.clock() - t0) / dur)
		for i, c in cars do
			local m, final = c[1], c[2]
			if m then
				-- on the rails, upright, coming from the left; the last 30% it leaves the rails and tumbles into place
				local railCF = CFrame.new(final.Position.X - 260 * (1 - math.min(a / 0.7, 1)), 0, 150) * ONRAILS
				local cf
				if a < 0.7 then
					cf = railCF
				else
					local b = (a - 0.7) / 0.3
					cf = railCF:Lerp(final, 1 - (1 - b) ^ 3)
				end
				m:PivotTo(cf * CFrame.new(0, math.sin(os.clock() * 30 + i) * 0.08, 0))
			end
		end
		if horn then horn.PlaybackSpeed = 0.55 + a * 0.3 end
		if a >= 1 then
			conn:Disconnect()
			for _, c in cars do if c[1] then c[1]:Destroy() end end
			if horn then horn:Destroy() end
		end
	end)
end

function EventFx.handle(kind: string, ...)
	local args = { ... }
	if kind == "VanCrash" then EventFx.van(args[1])
	elseif kind == "VanImpact" then boom(args[1], 30)
	elseif kind == "TrainCrash" then EventFx.train(args[1], args[2], args[3])
	elseif kind == "TrainImpact" then boom(args[1], 50)
	end
end

function EventFx.init(fx) Fx = fx end

return EventFx
