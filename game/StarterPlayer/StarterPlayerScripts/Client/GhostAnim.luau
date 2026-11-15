-- Procedural animation for the ghost (runs on every client): twitchy float, claw wind-up and swipe,
-- flailing knockback, arms-wide scare, vanish fade, white hit flash, dissolve on death.
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local GA = {}
local current: Model? = nil
local joints = {} :: { [string]: Motor6D }
local pose = {} :: { [string]: CFrame }
local fade = 0
local twitch = { t = 0, z = 0, x = 0 }
local highlight: Highlight? = nil
local rng = Random.new()

local A = CFrame.Angles
local function bind(g: Model)
	current = g
	joints = {}
	pose = {}
	for _, d in g:GetDescendants() do
		if d:IsA("Motor6D") then joints[d.Name] = d; pose[d.Name] = CFrame.new() end
	end
	highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = g
end

function GA.flash(strength: number?)
	if not highlight then return end
	highlight.FillTransparency = 1 - (strength or 0.85)
	TweenService:Create(highlight, TweenInfo.new(0.16), { FillTransparency = 1 }):Play()
end

local function target(state: string, t: number, sinceState: number): { [string]: CFrame }
	local s = math.sin
	local p = {}
	if state == "WindUp" then
		local a = math.min(1, sinceState / 0.45)
		p.Root = A(0.25 * a, 0, 0)
		p.Waist = A(0.2 * a, 0, 0)
		p.Neck = A(0.35 * a, 0, s(t * 40) * 0.08)
		p.RightShoulder = A(2.7 * a, 0, -0.3 * a)
		p.LeftShoulder = A(2.7 * a, 0, 0.3 * a)
		p.RightElbow = A(0.7 * a, 0, 0); p.LeftElbow = A(0.7 * a, 0, 0)
		p.RightWrist = A(0.6 * a, 0, 0); p.LeftWrist = A(0.6 * a, 0, 0)
	elseif state == "Swipe" then
		p.Root = A(-0.45, 0, 0)
		p.Waist = A(-0.35, 0.2, 0)
		p.Neck = A(-0.3, 0, 0.2)
		p.RightShoulder = A(0.5, 0, 0.5); p.LeftShoulder = A(0.5, 0, -0.5)
		p.RightElbow = A(0.2, 0, 0); p.LeftElbow = A(0.2, 0, 0)
		p.RightWrist = A(-0.4, 0, 0); p.LeftWrist = A(-0.4, 0, 0)
	elseif state == "Knocked" or state == "Recover" then
		local f = state == "Knocked" and 1 or 0.5
		p.Root = A(0.55 * f, s(t * 13) * 0.3 * f, s(t * 9) * 0.25 * f)
		p.Waist = A(0.4 * f, 0, 0)
		p.Neck = A(0.75 * f, s(t * 17) * 0.4, s(t * 21) * 0.4)
		p.RightShoulder = A(-1.0 + s(t * 15) * 0.6, 0, 1.3 * f + s(t * 11) * 0.4)
		p.LeftShoulder = A(-1.0 + s(t * 14) * 0.6, 0, -1.3 * f - s(t * 12) * 0.4)
		p.RightElbow = A(0.8, 0, 0); p.LeftElbow = A(0.8, 0, 0)
		p.RightHip = A(-0.7 * f + s(t * 12) * 0.3, 0, 0.2); p.LeftHip = A(-0.4 * f + s(t * 10) * 0.3, 0, -0.2)
		p.RightKnee = A(-0.8, 0, 0); p.LeftKnee = A(-0.5, 0, 0)
	elseif state == "Scare" then
		p.Root = A(-0.25, 0, 0)
		p.Neck = A(-0.25 + s(t * 50) * 0.06, s(t * 43) * 0.12, s(t * 37) * 0.15)
		p.RightShoulder = A(1.1, 0, 1.3); p.LeftShoulder = A(1.1, 0, -1.3)
		p.RightElbow = A(0.5, 0, 0); p.LeftElbow = A(0.5, 0, 0)
		p.RightWrist = A(0.9, 0, 0); p.LeftWrist = A(0.9, 0, 0)
		p.RightHip = A(0.1, 0, 0); p.LeftHip = A(0.1, 0, 0)
		p.RightKnee = A(-0.3, 0, 0); p.LeftKnee = A(-0.3, 0, 0)
	elseif state == "Dead" then
		p.Root = A(0.6, 0, 0.3)
		p.Neck = A(0.9, 0, 0.5)
		p.RightShoulder = A(-0.3, 0, 0.9); p.LeftShoulder = A(-0.3, 0, -0.9)
		p.RightHip = A(-0.4, 0, 0); p.LeftHip = A(-0.2, 0, 0)
	else -- Chase / Spawn / Vanish: dangling float with twitches
		if t > twitch.t then
			twitch.t = t + rng:NextNumber(0.4, 2.2)
			twitch.z = rng:NextNumber(-0.9, 0.9)
			twitch.x = rng:NextNumber(-0.4, 0.5)
		end
		p.Root = A(-0.22 + s(t * 1.7) * 0.05, s(t * 0.9) * 0.08, s(t * 1.3) * 0.06)
		p.Waist = A(-0.1, 0, s(t * 1.1) * 0.08)
		p.Neck = A(twitch.x, 0, twitch.z + s(t * 31) * 0.03)
		p.RightShoulder = A(0.45 + s(t * 2.1) * 0.12, 0, 0.12); p.LeftShoulder = A(0.38 + s(t * 2.3) * 0.12, 0, -0.12)
		p.RightElbow = A(0.35 + s(t * 2.7) * 0.1, 0, 0); p.LeftElbow = A(0.4, 0, 0)
		p.RightWrist = A(0.3, 0, 0); p.LeftWrist = A(0.35 + s(t * 3) * 0.1, 0, 0)
		p.RightHip = A(0.12, 0, 0.05); p.LeftHip = A(0.2, 0, -0.05)
		p.RightKnee = A(-0.35, 0, 0); p.LeftKnee = A(-0.5, 0, 0)
		p.RightAnkle = A(-0.7, 0, 0); p.LeftAnkle = A(-0.6, 0, 0)
	end
	return p
end

local stateSeen, stateT = "", 0
function GA.update(dt: number)
	local g = workspace:FindFirstChild("Ghost") :: Model?
	if g ~= current then
		if g then bind(g) else current = nil end
	end
	if not current or not current.Parent then return end
	local t = os.clock()
	local state = current:GetAttribute("State") or "Chase"
	if state ~= stateSeen then stateSeen = state; stateT = t end
	local tp = target(state, t, t - stateT)
	local speed = (state == "Swipe" or state == "Knocked") and 30 or 10
	local a = 1 - math.exp(-speed * dt)
	for name, m in joints do
		local want = tp[name] or CFrame.new()
		pose[name] = pose[name]:Lerp(want, a)
		m.Transform = pose[name]
	end
	-- vanish / spawn / death fade
	local want = 0
	if current:GetAttribute("Vanish") then want = 1 end
	if state == "Dead" then want = math.min(1, (t - stateT) / 2.5) end
	if state == "Spawn" then want = 1 - math.min(1, (t - stateT) / 1.8) end
	fade += (want - fade) * math.min(1, dt * (state == "Dead" and 3 or 6))
	for _, d in current:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.LocalTransparencyModifier = fade end
	end
end

function GA.init()
	RunService:BindToRenderStep("GhostAnim", Enum.RenderPriority.Character.Value + 1, GA.update)
end

return GA
