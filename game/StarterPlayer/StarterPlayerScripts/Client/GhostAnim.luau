-- Procedural animation for the monster (runs on every client): twitchy float or a walk cycle (walkers),
-- claw wind-up and swipe, a pose per special ability, flailing knockback, arms-wide scare, vanish / shadow fade,
-- white hit flash, dissolve on death. Every monster rig uses the same R15 joint names.
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local GA = {}
local current: Model? = nil
local joints = {} :: { [string]: Motor6D }
local pose = {} :: { [string]: CFrame }
local fade = 0
local twitch = { t = 0, z = 0, x = 0 }
local highlight: Highlight? = nil
local swirl: ParticleEmitter? = nil
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
	local hrp = g:FindFirstChild("HumanoidRootPart")
	if hrp then
		local a = Instance.new("Attachment"); a.Parent = hrp
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		pe.Shape = Enum.ParticleEmitterShape.Sphere; pe.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
		pe.Color = ColorSequence.new(Color3.fromRGB(150, 60, 255), Color3.fromRGB(20, 0, 40))
		pe.Size = NumberSequence.new(1.2, 0.2); pe.Speed = NumberRange.new(-24, -16); pe.Lifetime = NumberRange.new(0.6, 0.9)
		pe.Rate = 120; pe.RotSpeed = NumberRange.new(200, 400); pe.LightEmission = 0.8; pe.Enabled = false
		pe.Parent = a
		swirl = pe
	end
end

function GA.flash(strength: number?)
	if not highlight then return end
	highlight.FillTransparency = 1 - (strength or 0.85)
	TweenService:Create(highlight, TweenInfo.new(0.16), { FillTransparency = 1 }):Play()
end

-- a pose while a special ability runs (Ability / AbilityPhase attributes)
local function abilityPose(ab: string, phase: string, t: number, since: number): { [string]: CFrame }
	local s = math.sin
	local p = {}
	local a = math.min(1, since / 0.35)
	if ab == "blackout" then -- stalking in the dark: hunched, arms reaching, head cocked
		p.Root = A(0.15, 0, 0); p.Waist = A(0.25, 0, 0); p.Neck = A(-0.3, 0, 0.35 + s(t * 0.7) * 0.1)
		p.RightShoulder = A(1.2, 0, -0.15); p.LeftShoulder = A(1.2, 0, 0.15)
		p.RightElbow = A(0.4, 0, 0); p.LeftElbow = A(0.4, 0, 0)
		local ph = t * 6
		p.RightHip = A(s(ph) * 0.5, 0, 0); p.LeftHip = A(-s(ph) * 0.5, 0, 0)
		p.RightKnee = A(-0.3 - math.max(0, s(ph + 1.2)) * 0.7, 0, 0); p.LeftKnee = A(-0.3 - math.max(0, -s(ph + 1.2)) * 0.7, 0, 0)
		return p
	end
	if ab == "shieldBash" then -- the Pirate: shield up and crouched, then a shoulder-first rush, then he straightens up
		if phase == "brace" then
			p.Root = A(0.2 * a, 0, 0) * CFrame.new(0, -0.6 * a, 0); p.Waist = A(0.2, 0.25, 0); p.Neck = A(-0.25, -0.2, 0)
			p.LeftShoulder = A(0.55, 0.3, -0.35); p.LeftElbow = A(1.5, 0, 0)
			p.RightShoulder = A(-0.4, 0, 0.5); p.RightElbow = A(0.6, 0, 0)
			p.RightHip = A(0.45, 0, 0.15); p.LeftHip = A(-0.1, 0, -0.15); p.RightKnee = A(-0.7, 0, 0); p.LeftKnee = A(-0.4, 0, 0)
		elseif phase == "rush" then
			local run = s(t * 22)
			p.Root = A(0.5, 0, 0) * CFrame.new(0, -0.4, 0); p.Waist = A(0.2, 0.35, 0); p.Neck = A(-0.55, -0.3, 0)
			p.LeftShoulder = A(0.7, 0.3, -0.3); p.LeftElbow = A(1.4, 0, 0)
			p.RightShoulder = A(-0.6, 0, 0.4); p.RightElbow = A(0.5, 0, 0)
			p.RightHip = A(run * 0.9, 0, 0); p.LeftHip = A(-run * 0.9, 0, 0)
			p.RightKnee = A(-0.3 - math.max(0, run) * 0.9, 0, 0); p.LeftKnee = A(-0.3 - math.max(0, -run) * 0.9, 0, 0)
		else
			p.Root = A(-0.1, 0, 0); p.Neck = A(0.2, 0, s(t * 25) * 0.1)
			p.LeftShoulder = A(0.3, 0, -0.3); p.LeftElbow = A(1.0, 0, 0); p.RightShoulder = A(0.2, 0, 0.3)
		end
		return p
	end
	if ab == "steal" then -- the Goblin: snatch an item, cackle, then use it
		if phase == "reach" then
			p.Root = A(0.15 * a, 0, 0) * CFrame.new(0, -0.4 * a, -1.0 * a); p.Waist = A(0.35 * a, 0, 0); p.Neck = A(-0.35 * a, 0, 0)
			p.RightShoulder = A(1.55 * a, 0, -0.2); p.RightElbow = A(0.15, 0, 0); p.RightWrist = A(-0.3 * a, 0, 0)
			p.LeftShoulder = A(1.3 * a, 0, 0.25); p.LeftElbow = A(0.3, 0, 0)
		elseif phase == "laugh" then
			p.Root = A(-0.12, 0, 0); p.Waist = A(-0.25 + s(t * 28) * 0.06, 0, 0); p.Neck = A(-0.55 + s(t * 30) * 0.15, 0, s(t * 17) * 0.1)
			p.RightShoulder = A(2.6, 0, -0.45); p.RightElbow = A(0.3, 0, 0)
			p.LeftShoulder = A(0.4, 0, 0.6); p.LeftElbow = A(1.3, 0, 0)
		elseif phase == "swingWind" then
			p.Waist = A(-0.2 * a, -0.45 * a, 0); p.Neck = A(0.1, 0.3 * a, 0)
			p.RightShoulder = A(2.9 * a, 0, -0.35 * a); p.RightElbow = A(0.9 * a, 0, 0); p.RightWrist = A(0.3 * a, 0, 0)
			p.LeftShoulder = A(0.7 * a, 0, 0.4); p.LeftElbow = A(0.5, 0, 0)
		elseif phase == "swing" then
			p.Root = A(0.25, 0, 0) * CFrame.new(0, -0.5, -1.2); p.Waist = A(0.45, 0.6, 0); p.Neck = A(-0.2, -0.3, 0)
			p.RightShoulder = A(0.35, 0, 0.6); p.RightElbow = A(0.1, 0, 0); p.RightWrist = A(-0.3, 0, 0)
			p.LeftHip = A(0.7, 0, 0); p.RightHip = A(-0.5, 0, 0); p.LeftKnee = A(-0.6, 0, 0)
			p.LeftShoulder = A(-0.3, 0, -0.3)
		elseif phase == "aim" or phase == "fire" then
			local kick = phase == "fire" and math.abs(s(t * 48)) * 0.18 or 0
			p.Neck = A(-0.1, 0, 0); p.Waist = A(0.05, 0, 0)
			p.RightShoulder = A(1.57 * a + kick, 0, 0); p.RightElbow = A(-kick * 0.5, 0, 0); p.RightWrist = A(0, 0, 0)
			p.LeftShoulder = A(1.35 * a, 0, 0.55 * a); p.LeftElbow = A(0.4, 0, 0)
		elseif phase == "throwWind" then
			p.Waist = A(-0.3 * a, -0.35 * a, 0)
			p.RightShoulder = A(2.9 * a, 0, 0.25 * a); p.RightElbow = A(1.0 * a, 0, 0)
			p.LeftShoulder = A(1.0 * a, 0, 0.3)
		elseif phase == "throw" then
			p.Root = A(0.2, 0, 0) * CFrame.new(0, -0.3, -0.9); p.Waist = A(0.35, 0.5, 0)
			p.RightShoulder = A(1.0, 0, 0.1); p.RightElbow = A(0.1, 0, 0)
			p.LeftHip = A(0.6, 0, 0); p.RightHip = A(-0.45, 0, 0)
			p.LeftShoulder = A(-0.3, 0, -0.3)
		elseif phase == "spray" then
			p.Waist = A(0.1, s(t * 2.5) * 0.25, 0)
			p.RightShoulder = A(1.5 + s(t * 35) * 0.04, 0, 0); p.RightElbow = A(0, 0, 0)
			p.LeftShoulder = A(1.3, 0, 0.5); p.LeftElbow = A(0.5, 0, 0)
		end
		return p
	end
	if ab == "levitateThrow" then
		if phase == "lift" or phase == "aim" then -- right hand raised, fingers spread, controlling the object
			local shake = phase == "aim" and s(t * 40) * 0.05 or 0
			p.Waist = A(-0.15, -0.25, 0); p.Neck = A(-0.35, -0.2, 0)
			p.RightShoulder = A(2.6 * a + shake, 0, -0.35); p.RightElbow = A(0.25, 0, 0); p.RightWrist = A(-0.7, 0, 0)
			p.LeftShoulder = A(0.6 * a, 0, 0.7 * a); p.LeftElbow = A(0.6, 0, 0)
			p.RightHip = A(0.2, 0, 0); p.LeftHip = A(-0.25, 0, 0)
		else -- throw: the arm whips forward and down, body lunges
			p.Root = A(0.25, 0, 0); p.Waist = A(0.35, 0.3, 0); p.Neck = A(0.2, 0, 0)
			p.RightShoulder = A(0.5, 0, -0.3); p.RightElbow = A(0.1, 0, 0); p.RightWrist = A(0.3, 0, 0)
			p.LeftShoulder = A(-0.4, 0, 0.5)
			p.RightHip = A(-0.4, 0, 0); p.LeftHip = A(0.45, 0, 0); p.LeftKnee = A(-0.4, 0, 0)
		end
	elseif ab == "grabThrow" then
		if phase == "wind" then
			p.Root = A(0.3 * a, 0, 0); p.Waist = A(0.25 * a, 0, 0)
			p.RightShoulder = A(1.4 * a, 0, -0.3); p.LeftShoulder = A(1.4 * a, 0, 0.3)
			p.RightElbow = A(0.2, 0, 0); p.LeftElbow = A(0.2, 0, 0)
		else -- hold: lift the victim overhead with the right arm, then throw
			p.Waist = A(-0.25, 0.3, 0); p.Neck = A(-0.3, 0, 0)
			p.RightShoulder = A(2.9, 0, -0.2); p.RightElbow = A(0.3, 0, 0)
			p.LeftShoulder = A(0.6, 0, 0.6)
		end
	elseif ab == "pounce" then
		if phase == "crouch" then
			p.Root = A(0.6 * a, 0, 0); p.Waist = A(0.4 * a, 0, 0); p.Neck = A(-0.6 * a, 0, s(t * 30) * 0.1)
			p.RightHip = A(1.4 * a, 0, 0); p.LeftHip = A(1.4 * a, 0, 0); p.RightKnee = A(-2.0 * a, 0, 0); p.LeftKnee = A(-2.0 * a, 0, 0)
			p.RightShoulder = A(0.9, 0, 0.3); p.LeftShoulder = A(0.9, 0, -0.3)
		else
			p.Root = A(-0.4, 0, 0); p.RightShoulder = A(2.8, 0, -0.4); p.LeftShoulder = A(2.8, 0, 0.4)
			p.RightHip = A(-0.6, 0, 0); p.LeftHip = A(0.4, 0, 0); p.RightKnee = A(-0.4, 0, 0); p.LeftKnee = A(-1.2, 0, 0)
		end
	elseif ab == "wail" then
		local k = phase == "wind" and a or 1
		p.Root = A(-0.3 * k, 0, 0); p.Waist = A(-0.35 * k, 0, 0); p.Neck = A(-0.7 * k + s(t * 60) * 0.05, s(t * 47) * 0.08, 0)
		p.RightShoulder = A(0.4, 0, 1.9 * k); p.LeftShoulder = A(0.4, 0, -1.9 * k)
		p.RightElbow = A(0.1, 0, 0); p.LeftElbow = A(0.1, 0, 0); p.RightWrist = A(-0.5, 0, 0); p.LeftWrist = A(-0.5, 0, 0)
	elseif ab == "blackout" then
		p.Root = A(0.35, 0, 0); p.Waist = A(0.3, 0, 0); p.Neck = A(-0.3, s(t * 9) * 0.3, 0)
		p.RightShoulder = A(0.9 + s(t * 14) * 0.3, 0, 0.2); p.LeftShoulder = A(0.9 - s(t * 14) * 0.3, 0, -0.2)
		p.RightElbow = A(0.6, 0, 0); p.LeftElbow = A(0.6, 0, 0)
		p.RightHip = A(s(t * 14) * 0.9, 0, 0); p.LeftHip = A(-s(t * 14) * 0.9, 0, 0)
		p.RightKnee = A(-0.4 - math.max(0, s(t * 14)) * 0.6, 0, 0); p.LeftKnee = A(-0.4 - math.max(0, -s(t * 14)) * 0.6, 0, 0)
	elseif ab == "gas" then
		local k = math.min(1, since / 0.3)
		p.Waist = A(0, -0.5 + k * 0.9, 0)
		p.RightShoulder = A(k < 0.6 and 2.6 or 1.2, 0, -0.3); p.RightElbow = A(k < 0.6 and 1.2 or 0.1, 0, 0)
		p.LeftShoulder = A(0.4, 0, 0.3)
	elseif ab == "hellfire" or ab == "furnitureStorm" or ab == "clones" then
		p.Root = A(-0.2, 0, 0); p.Waist = A(-0.2, 0, 0); p.Neck = A(-0.5, 0, s(t * 20) * 0.08)
		p.RightShoulder = A(2.6 * a, 0, -0.5 * a); p.LeftShoulder = A(2.6 * a, 0, 0.5 * a)
		p.RightElbow = A(0.2, 0, 0); p.LeftElbow = A(0.2, 0, 0)
		p.RightWrist = A(-0.4 + s(t * 25) * 0.2, 0, 0); p.LeftWrist = A(-0.4 - s(t * 25) * 0.2, 0, 0)
	elseif ab == "charge" then
		if phase == "wind" then
			p.Root = A(0.15, 0, 0); p.Waist = A(0, -0.6 * a, 0)
			p.RightShoulder = A(1.6 * a, 0.4, -0.4); p.RightElbow = A(0.2, 0, 0)
			p.LeftShoulder = A(0.5, 0, 0.5); p.RightHip = A(0.4, 0, 0); p.LeftHip = A(-0.4, 0, 0)
		else
			p.Root = A(0.45, 0, 0); p.Waist = A(0.2, 0.3, 0)
			p.RightShoulder = A(1.6, 0, -0.1); p.RightElbow = A(0, 0, 0); p.LeftShoulder = A(-0.6, 0, 0.4)
			p.RightHip = A(s(t * 22) * 1.1, 0, 0); p.LeftHip = A(-s(t * 22) * 1.1, 0, 0)
			p.RightKnee = A(-0.3 - math.max(0, s(t * 22)) * 1.0, 0, 0); p.LeftKnee = A(-0.3 - math.max(0, -s(t * 22)) * 1.0, 0, 0)
		end
	end
	return p
end

-- walk cycle for monsters that walk on the floor (speed = studs / s)
local function walkPose(p: { [string]: CFrame }, t: number, speed: number)
	local s = math.sin
	local k = math.clamp(speed / 14, 0, 1.4)
	local ph = t * (5 + speed * 0.35)
	p.RightHip = A(s(ph) * 0.75 * k, 0, 0); p.LeftHip = A(-s(ph) * 0.75 * k, 0, 0)
	p.RightKnee = A(-0.15 - math.max(0, s(ph + 1.2)) * 0.9 * k, 0, 0); p.LeftKnee = A(-0.15 - math.max(0, -s(ph + 1.2)) * 0.9 * k, 0, 0)
	p.RightAnkle = A(0.15 * k, 0, 0); p.LeftAnkle = A(0.15 * k, 0, 0)
	p.RightShoulder = A(-s(ph) * 0.5 * k + 0.2, 0, 0.08); p.LeftShoulder = A(s(ph) * 0.5 * k + 0.2, 0, -0.08)
	p.RightElbow = A(0.35, 0, 0); p.LeftElbow = A(0.35, 0, 0)
	p.Root = A(0.08 * k, s(ph) * 0.06 * k, 0) * CFrame.new(0, math.abs(s(ph)) * 0.25 * k, 0)
	p.Waist = A(0.05, -s(ph) * 0.12 * k, 0)
end

-- the Goblin's own claw attacks (WindUp -> Swipe), a different one each time:
-- 1 right haymaker, 2 left haymaker, 3 two-fisted overhead slam. Every hit lunges at you.
local gobVariant = 1
local function goblinClaw(state: string, t: number, since: number): { [string]: CFrame }
	local p = {}
	local a = math.min(1, since / 0.4)
	local s = math.sin
	if gobVariant == 3 then
		if state == "WindUp" then
			p.Root = A(-0.3 * a, 0, 0); p.Waist = A(-0.4 * a, 0, 0); p.Neck = A(-0.25, 0, s(t * 30) * 0.05)
			p.RightShoulder = A(3.0 * a, 0, -0.3 * a); p.LeftShoulder = A(3.0 * a, 0, 0.3 * a)
			p.RightElbow = A(0.7 * a, 0, 0); p.LeftElbow = A(0.7 * a, 0, 0)
			p.RightHip = A(0.15, 0, 0.15); p.LeftHip = A(0.15, 0, -0.15); p.RightKnee = A(-0.3, 0, 0); p.LeftKnee = A(-0.3, 0, 0)
		else -- slam: crouch down, both fists to the floor
			p.Root = A(0.55, 0, 0) * CFrame.new(0, -1.3, -1.1); p.Waist = A(0.6, 0, 0); p.Neck = A(-0.5, 0, 0)
			p.RightShoulder = A(0.9, 0, -0.25); p.LeftShoulder = A(0.9, 0, 0.25)
			p.RightElbow = A(0.15, 0, 0); p.LeftElbow = A(0.15, 0, 0)
			p.RightHip = A(1.0, 0, 0.2); p.LeftHip = A(1.0, 0, -0.2); p.RightKnee = A(-1.3, 0, 0); p.LeftKnee = A(-1.3, 0, 0)
			p.RightAnkle = A(0.35, 0, 0); p.LeftAnkle = A(0.35, 0, 0)
		end
		return p
	end
	-- haymaker (k = 1 right hand, -1 left hand: the left one is the mirror image)
	local k = gobVariant == 1 and 1 or -1
	local R, L = k == 1 and "Right" or "Left", k == 1 and "Left" or "Right"
	if state == "WindUp" then -- cock the fist back, torso twisted away, other hand up as a guard
		p.Root = A(-0.1 * a, 0, 0); p.Waist = A(-0.15 * a, -0.75 * a * k, 0); p.Neck = A(0.1, 0.5 * a * k, 0)
		p[R .. "Shoulder"] = A(1.3 * a, 0, 1.25 * a * k); p[R .. "Elbow"] = A(1.6 * a, 0, 0); p[R .. "Wrist"] = A(0.3, 0, 0)
		p[L .. "Shoulder"] = A(1.15 * a, 0, -0.35 * k); p[L .. "Elbow"] = A(1.3, 0, 0)
		p[R .. "Hip"] = A(-0.35, 0, 0.1 * k); p[L .. "Hip"] = A(0.35, 0, -0.1 * k); p[L .. "Knee"] = A(-0.4, 0, 0)
	else -- swing it across with a lunge
		p.Root = A(0.25, 0, 0) * CFrame.new(0, -0.4, -1.3); p.Waist = A(0.25, 0.85 * k, 0); p.Neck = A(-0.2, -0.55 * k, 0)
		p[R .. "Shoulder"] = A(1.6, 0, -0.75 * k); p[R .. "Elbow"] = A(0.1, 0, 0); p[R .. "Wrist"] = A(-0.2, 0, 0)
		p[L .. "Shoulder"] = A(-0.45, 0, -0.4 * k); p[L .. "Elbow"] = A(0.6, 0, 0)
		p[L .. "Hip"] = A(0.75, 0, 0); p[R .. "Hip"] = A(-0.55, 0, 0); p[L .. "Knee"] = A(-0.6, 0, 0); p[R .. "Knee"] = A(-0.2, 0, 0)
	end
	return p
end

-- the Pirate's cutlass slashes (WindUp -> Swipe): overhead-right then a sweep across, shield kept up
local function pirateSlash(state: string, t: number, since: number): { [string]: CFrame }
	local p = {}
	local a = math.min(1, since / 0.4)
	p.LeftShoulder = A(0.55, 0.3, -0.35); p.LeftElbow = A(1.5, 0, 0) -- shield in front
	if state == "WindUp" then
		p.Root = A(-0.08 * a, 0, 0); p.Waist = A(-0.1, -0.6 * a, 0); p.Neck = A(0.05, 0.45 * a, 0)
		p.RightShoulder = A(2.7 * a, 0, 0.6 * a); p.RightElbow = A(0.9 * a, 0, 0); p.RightWrist = A(0.4 * a, 0, 0)
		p.RightHip = A(-0.3, 0, 0.1); p.LeftHip = A(0.3, 0, -0.1)
	else
		p.Root = A(0.2, 0, 0) * CFrame.new(0, -0.3, -1.0); p.Waist = A(0.25, 0.7, 0); p.Neck = A(-0.15, -0.45, 0)
		p.RightShoulder = A(1.2, 0, -0.9); p.RightElbow = A(0.05, 0, 0); p.RightWrist = A(-0.4, 0, 0)
		p.LeftHip = A(0.65, 0, 0); p.RightHip = A(-0.5, 0, 0); p.LeftKnee = A(-0.5, 0, 0)
	end
	return p
end

local function target(state: string, t: number, sinceState: number): { [string]: CFrame }
	local s = math.sin
	local p = {}
	local g = current :: Model
	if state == "Ability" then
		return abilityPose(g:GetAttribute("Ability") or "", g:GetAttribute("AbilityPhase") or "", t, sinceState)
	end
	if (state == "WindUp" or state == "Swipe") and g:GetAttribute("MonsterId") == "Goblin" then
		return goblinClaw(state, t, sinceState)
	end
	if (state == "WindUp" or state == "Swipe") and g:GetAttribute("MonsterId") == "Pirate" then
		return pirateSlash(state, t, sinceState)
	end
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
	elseif g:GetAttribute("Walker") then -- Chase / Spawn: walk (the crawler crawls on all fours)
		local hrp = g:FindFirstChild("HumanoidRootPart") :: BasePart?
		local v = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
		local speed = Vector3.new(v.X, 0, v.Z).Magnitude
		walkPose(p, t, speed)
		if g:GetAttribute("MonsterId") == "Crawler" then
			p.Root = A(1.15, 0, s(t * 9) * 0.1) * CFrame.new(0, -1.6, 0)
			p.Neck = A(-1.1, 0, s(t * 23) * 0.2)
			p.RightShoulder = A(1.6 + s(t * 9) * 0.6, 0, -0.2); p.LeftShoulder = A(1.6 - s(t * 9) * 0.6, 0, 0.2)
			p.RightHip = A(-0.2 - s(t * 9) * 0.5, 0, 0.2); p.LeftHip = A(-0.2 + s(t * 9) * 0.5, 0, -0.2)
		elseif g:GetAttribute("MonsterId") == "Butcher" or g:GetAttribute("MonsterId") == "HollowKing" or g:GetAttribute("MonsterId") == "Demon" then
			p.Waist = (p.Waist or CFrame.new()) * A(0.25, 0, 0) -- hunched
			p.Neck = A(-0.2, 0, s(t * 1.3) * 0.08)
		elseif g:GetAttribute("MonsterId") == "Animatronic" then
			-- servo-jerky: the pose snaps in steps and the head twitches sideways now and then
			for k, v in p do
				local rx, ry, rz = v:ToEulerAnglesXYZ()
				local q = 0.18
				p[k] = CFrame.new(v.Position) * A(math.floor(rx / q + 0.5) * q, math.floor(ry / q + 0.5) * q, math.floor(rz / q + 0.5) * q)
			end
			p.Neck = A(-0.1, (math.floor(t * 0.8) % 3 - 1) * 0.35, (math.floor(t * 1.3) % 2) * 0.25)
		elseif g:GetAttribute("MonsterId") == "Pirate" then
			p.Waist = (p.Waist or CFrame.new()) * A(0.18, 0, 0) -- a crooked skeleton walk, shield up, cutlass low
			p.Neck = A(-0.15, s(t * 1.1) * 0.15, s(t * 2.7) * 0.1)
			p.LeftShoulder = A(0.15, 0.25, -0.25); p.LeftElbow = A(1.35, 0, 0)
			p.RightElbow = A(0.5, 0, 0)
		elseif g:GetAttribute("MonsterId") == "Goblin" then
			p.Waist = (p.Waist or CFrame.new()) * A(0.3, 0, 0) -- hunched, sneaky
			p.Neck = A(-0.35, s(t * 1.7) * 0.25, s(t * 2.3) * 0.08) -- looking around for something to steal
			if (g:GetAttribute("Loot") or "") ~= "" then -- holding a stolen item out in front
				p.RightShoulder = A(0.75 + s(t * 6) * 0.08, 0, -0.1); p.RightElbow = A(0.5, 0, 0)
			end
		end
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
	if state ~= stateSeen then
		stateSeen = state; stateT = t
		if state == "WindUp" then gobVariant = gobVariant % 3 + 1 end
	end
	local frozen = current:GetAttribute("Frozen") == true
	if highlight then
		if frozen then
			highlight.FillColor = Color3.fromRGB(150, 210, 255)
			if highlight.FillTransparency > 0.55 then highlight.FillTransparency = 0.55 end
		elseif highlight.FillColor ~= Color3.new(1, 1, 1) then
			highlight.FillColor = Color3.new(1, 1, 1)
			highlight.FillTransparency = 1
		end
	end
	if swirl then swirl.Enabled = current:GetAttribute("Vortex") == true end
	local tp = target(state, t, t - stateT)
	local speed = (state == "Swipe" or state == "Knocked" or state == "Ability") and 22 or 12
	local a = 1 - math.exp(-speed * dt)
	for name, m in joints do
		if frozen then m.Transform = pose[name]; continue end
		local want = tp[name] or CFrame.new()
		pose[name] = pose[name]:Lerp(want, a)
		m.Transform = pose[name]
	end
	-- vanish / spawn / death fade
	local want = 0
	if current:GetAttribute("Vanish") then want = 1 end
	if current:GetAttribute("Shadow") then want = 0.88 end -- the stalker in the dark: barely visible
	if state == "Dead" then want = math.min(1, (t - stateT) / 2.5) end
	if state == "Spawn" then want = 1 - math.min(1, (t - stateT) / 1.8) end
	fade += (want - fade) * math.min(1, dt * (state == "Dead" and 3 or 6))
	for _, d in current:GetDescendants() do
		-- parts with the Glow attribute (the Animatronic's eyes) stay visible in the dark
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.LocalTransparencyModifier = (d:GetAttribute("Glow") and state ~= "Dead") and 0 or fade end
	end
end

function GA.init()
	RunService:BindToRenderStep("GhostAnim", Enum.RenderPriority.Character.Value + 1, GA.update)
end

return GA
