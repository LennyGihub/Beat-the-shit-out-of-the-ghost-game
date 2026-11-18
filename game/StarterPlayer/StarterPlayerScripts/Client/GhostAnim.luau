-- Procedural animation for the monster (runs on every client): twitchy float or a walk cycle (walkers),
-- claw wind-up and swipe, a pose per special ability, flailing knockback, arms-wide scare, vanish / shadow fade,
-- white hit flash, dissolve on death. Every monster rig uses the same R15 joint names.
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local EP = require(script.Parent.EntrancePose) -- the body's part in each monster's entrance

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
local phaseSeen, phaseT = "", 0 -- the AbilityPhase attribute and when it last changed (swing timing)
local frozenPh: number? = nil -- (Studio photo hook: the phase time held while DebugFreezeGhost is on)
-- With streaming on, a monster's parts and joints can reach this client a little after the model itself: joints
-- (and the root, for the swirl) that arrive later are picked up as they come, so the monster is never left
-- moving without its animation.
local bindConns = {} :: { RBXScriptConnection }
local function addJoint(d: Instance)
	if d:IsA("Motor6D") and joints[d.Name] ~= d then
		joints[d.Name] = d
		pose[d.Name] = pose[d.Name] or CFrame.new()
	end
end
local function makeSwirl(hrp: Instance)
	if not hrp:IsA("BasePart") or hrp:FindFirstChild("SwirlAtt") then return end
	local a = Instance.new("Attachment"); a.Name = "SwirlAtt"; a.Parent = hrp
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Shape = Enum.ParticleEmitterShape.Sphere; pe.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
	pe.Color = ColorSequence.new(Color3.fromRGB(150, 60, 255), Color3.fromRGB(20, 0, 40))
	pe.Size = NumberSequence.new(1.2, 0.2); pe.Speed = NumberRange.new(-24, -16); pe.Lifetime = NumberRange.new(0.6, 0.9)
	pe.Rate = 120; pe.RotSpeed = NumberRange.new(200, 400); pe.LightEmission = 0.8; pe.Enabled = false
	pe.Parent = a
	swirl = pe
end

local function bind(g: Model)
	for _, c in bindConns do c:Disconnect() end
	table.clear(bindConns)
	current = g
	joints = {}
	pose = {}
	swirl = nil
	for _, d in g:GetDescendants() do addJoint(d) end
	table.insert(bindConns, g.DescendantAdded:Connect(function(d)
		addJoint(d)
		if d.Name == "HumanoidRootPart" then makeSwirl(d) end
	end))
	table.insert(bindConns, g.DescendantRemoving:Connect(function(d)
		if d:IsA("Motor6D") and joints[d.Name] == d then joints[d.Name] = nil end
	end))
	highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = g
	local hrp = g:FindFirstChild("HumanoidRootPart")
	if hrp then makeSwirl(hrp) end
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
	if ab == "ambush" then
		local sincePhase = os.clock() - phaseT
		-- On this rig a POSITIVE x angle tips a part's top BACK (its lower end comes forward): legs and arms swing
		-- forward with +, the torso and the head lean back with + and bend forward / down with -.
		-- drop = how far his hips come down to sit on the floor (his root floats at hip height; the rig is scaled)
		local drop = 3.85 * (current and current:GetScale() or 1)
		if phase == "hide" then -- asleep on the floor in his corner: leaning back on the wall, slumped, chin on his chest, one leg out, one knee up with the knife hand on it
			local br = s(t * 1.3) * 0.035
			p.Root = CFrame.new(0, -drop, 0.3) * A(0.2, 0, 0); p.Waist = A(-0.45 - br, 0, 0.06); p.Neck = A(-0.7 - br, 0.12, 0)
			p.RightHip = A(2.1, 0, 0.15); p.RightKnee = A(-1.3, 0, 0); p.RightAnkle = A(0.3, 0, 0)
			p.LeftHip = A(1.37, 0, -0.2); p.LeftKnee = A(-0.12, 0, 0); p.LeftAnkle = A(0.3, 0, 0)
			p.RightShoulder = A(1.25, 0, 0.1); p.RightElbow = A(0.2, 0, 0); p.RightWrist = A(0.2, 0, 0)
			p.LeftShoulder = A(0.4, 0, -0.3); p.LeftElbow = A(0.15, 0, 0)
		elseif phase == "wake" then -- seen: his head snaps up, then he pushes himself off the floor, bent forward, knife out
			local k = math.clamp((sincePhase - 0.12) / 0.5, 0, 1)
			local d = 1 - k
			p.Root = CFrame.new(0, -drop * d, 0.3 * d) * A(0.2 * d - 0.2 * k, 0, 0); p.Waist = A(-0.45 * d - 0.15 * k, 0, 0); p.Neck = A(0.25 * d + 0.3 * k, 0, 0)
			p.RightHip = A(2.1 * d, 0, 0.15 * d); p.RightKnee = A(-1.3 * d, 0, 0); p.RightAnkle = A(0.3 * d, 0, 0)
			p.LeftHip = A(1.37 * d, 0, -0.2 * d); p.LeftKnee = A(-0.12 * d, 0, 0); p.LeftAnkle = A(0.3 * d, 0, 0)
			p.RightShoulder = A(1.25 + 0.5 * k, 0, 0.3); p.RightElbow = A(0.2 + 1.0 * k, 0, 0)
			p.LeftShoulder = A(0.4 + 0.3 * k, 0, -0.35); p.LeftElbow = A(0.15 + 0.6 * k, 0, 0)
		elseif phase == "spring" then -- nobody is looking: off the floor into a low crouch, bent forward, eyes on them, the knife by his cheek
			p.Root = CFrame.new(0, -1.9, 0) * A(-0.3, 0, 0); p.Waist = A(-0.35, 0, 0); p.Neck = A(0.55, 0, 0)
			p.RightHip = A(1.65, 0, 0.12); p.LeftHip = A(1.8, 0, -0.12); p.RightKnee = A(-2.1, 0, 0); p.LeftKnee = A(-2.2, 0, 0)
			p.RightAnkle = A(0.6, 0, 0); p.LeftAnkle = A(0.6, 0, 0)
			p.RightShoulder = A(1.3, 0, 0.35); p.RightElbow = A(1.5, 0, 0); p.RightWrist = A(0.1 + s(t * 2.2) * 0.08, 0, 0)
			p.LeftShoulder = A(0.5, 0, -0.3); p.LeftElbow = A(1.1, 0, 0)
		elseif phase == "strike" then -- out of the corner in one bound, the knife coming down
			p.Root = A(0.5, 0, 0) * CFrame.new(0, -0.3, -1.2); p.Waist = A(0.35, -0.3, 0); p.Neck = A(-0.5, 0.2, 0)
			p.RightShoulder = A(2.3 - a * 1.5, 0, 0.2); p.RightElbow = A(0.5, 0, 0)
			p.LeftShoulder = A(1.4, 0, -0.5); p.LeftElbow = A(0.4, 0, 0)
			p.RightHip = A(-0.7, 0, 0); p.LeftHip = A(0.9, 0, 0); p.LeftKnee = A(-0.9, 0, 0); p.RightKnee = A(-0.3, 0, 0)
		else -- slipping away: turned, shoulders in
			p.Root = A(0.15, 0, 0); p.Waist = A(0.25, 0.4, 0); p.Neck = A(-0.1, -0.6, 0)
			p.RightShoulder = A(0.9, 0, 0.3); p.RightElbow = A(1.5, 0, 0); p.LeftShoulder = A(0.2, 0, -0.2)
		end
	elseif ab == "forcePush" then
		-- the Void Knight: the blade low at his side, the open left hand reaching out (wind), raised with the player
		-- in its grip (hold), then thrown forward (push)
		p.RightShoulder = A(0.15, 0, 0.3); p.RightElbow = A(0.3, 0, 0)
		p.RightHip = A(-0.22, 0, 0.1); p.LeftHip = A(0.28, 0, -0.1); p.LeftKnee = A(-0.2, 0, 0)
		if phase == "wind" then
			p.Root = A(-0.05 * a, 0, 0); p.Waist = A(-0.06 * a, 0.3 * a, 0); p.Neck = A(0.08, -0.25 * a, 0)
			p.LeftShoulder = A(1.45 * a, 0, 0.12 * a); p.LeftElbow = A(0.25, 0, 0); p.LeftWrist = A(-0.9 * a + s(t * 26) * 0.05, 0, 0)
		elseif phase == "hold" then
			p.Root = A(-0.1, 0, 0); p.Waist = A(-0.12, 0.3, 0); p.Neck = A(0.2, -0.25, 0)
			p.LeftShoulder = A(1.95 + s(t * 24) * 0.03, 0, 0.1); p.LeftElbow = A(0.5, 0, 0); p.LeftWrist = A(-1.1, 0, 0)
		else
			p.Root = A(0.18, 0, 0) * CFrame.new(0, -0.2, -0.6); p.Waist = A(0.2, -0.35, 0); p.Neck = A(-0.1, 0.3, 0)
			p.LeftShoulder = A(1.5, 0, -0.35); p.LeftElbow = A(0.02, 0, 0); p.LeftWrist = A(0.5, 0, 0)
			p.LeftHip = A(0.6, 0, 0); p.RightHip = A(-0.45, 0, 0); p.LeftKnee = A(-0.5, 0, 0)
		end
	elseif ab == "warp" then
		if phase == "wind" then -- the gauntlet raised in front of him, tearing a portal open
			p.Root = A(-0.08 * a, 0, 0); p.Waist = A(-0.1 * a, -0.25 * a, 0); p.Neck = A(0.1, 0.2 * a, 0)
			p.RightShoulder = A(1.75 * a, 0, -0.15 * a); p.RightElbow = A(0.2, 0, 0); p.RightWrist = A(-0.5 * a + s(t * 30) * 0.06, 0, 0)
			p.LeftShoulder = A(-0.25, 0, -0.2); p.LeftElbow = A(0.5, 0, 0)
			p.RightHip = A(-0.2, 0, 0.1); p.LeftHip = A(0.25, 0, -0.1)
		else -- stepping out: one stride, arms loose, looking down at you
			p.Root = A(0.1, 0, 0); p.Waist = A(0.12, 0, 0); p.Neck = A(0.2, 0, 0)
			p.RightShoulder = A(0.3, 0, 0.15); p.LeftShoulder = A(-0.2, 0, -0.15)
			p.RightElbow = A(0.5, 0, 0); p.LeftElbow = A(0.5, 0, 0)
			p.RightHip = A(0.55, 0, 0); p.LeftHip = A(-0.35, 0, 0); p.RightKnee = A(-0.4, 0, 0)
		end
	elseif ab == "blackout" then -- stalking in the dark: hunched, arms reaching, head cocked
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
		if phase == "summon" then -- both arms thrown up at the ceiling, head back, shaking: calling furniture up from below
			local sh = s(t * 34) * 0.05
			p.Root = A(0.16, 0, 0); p.Waist = A(0.18, 0, 0); p.Neck = A(0.5, 0, s(t * 27) * 0.06)
			p.RightShoulder = A(2.75 + sh, 0, 0.55); p.LeftShoulder = A(2.75 - sh, 0, -0.55)
			p.RightElbow = A(0.35, 0, 0); p.LeftElbow = A(0.35, 0, 0)
			p.RightWrist = A(-0.7, 0, 0); p.LeftWrist = A(-0.7, 0, 0)
			p.RightHip = A(0.1, 0, 0.12); p.LeftHip = A(0.1, 0, -0.12)
		elseif phase == "lift" or phase == "aim" then -- right hand raised, fingers spread, controlling the object
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
	elseif ab == "ratRush" then
		-- the Sewer Rat. On all fours for the charge (pawing the floor first), scooping his way into the floor,
		-- bursting back out of it with his claws wide, swaying when he is dizzy.
		local ph = os.clock() - phaseT
		local function allFours(low: number, gallop: number)
			local w = s(t * 26) * gallop
			p.Root = CFrame.new(0, -low, 0) * A(-1.2, 0, 0)
			p.Waist = A(-0.15, 0, 0); p.Neck = A(1.05, 0, 0)
			p.RightShoulder = A(1.35 + w * 0.7, 0, 0.1); p.LeftShoulder = A(1.35 - w * 0.7, 0, -0.1)
			p.RightElbow = A(0.3, 0, 0); p.LeftElbow = A(0.3, 0, 0)
			p.RightHip = A(1.2 - w * 0.6, 0, 0.1); p.LeftHip = A(1.2 + w * 0.6, 0, -0.1)
			p.RightKnee = A(-1.3, 0, 0); p.LeftKnee = A(-1.3, 0, 0)
		end
		if phase == "wind" then
			allFours(1.9, 0)
			p.Root = CFrame.new(0, -1.9, 0.6 + s(t * 9) * 0.25) * A(-1.05, 0, 0) -- rocking back on his haunches
			p.RightShoulder = A(1.35 + s(t * 16) * 0.7, 0, 0.1) -- one paw rakes the floor
			p.Neck = A(0.9, s(t * 21) * 0.08, 0)
		elseif phase == "dash" then
			allFours(2.1, 1)
		elseif phase == "dizzy" then
			p.Root = A(0.12, 0, s(t * 4.5) * 0.28)
			p.Waist = A(-0.2, s(t * 3.1) * 0.2, 0)
			p.Neck = A(0.25, s(t * 6) * 0.5, s(t * 4.2) * 0.4)
			p.RightShoulder = A(0.2, 0, 0.25 + s(t * 4.5) * 0.2); p.LeftShoulder = A(0.2, 0, -0.25 + s(t * 4.5) * 0.2)
		elseif phase == "dig" then
			allFours(1.9, 0)
			local sink = math.clamp(ph / 0.7, 0, 1)
			p.Root = CFrame.new(0, -1.9 - 9 * sink * sink, 0) * A(-1.35, 0, 0)
			p.RightShoulder = A(1.5 + s(t * 30) * 0.9, 0, 0.1); p.LeftShoulder = A(1.5 - s(t * 30) * 0.9, 0, -0.1)
		elseif phase == "under" or phase == "warn" then
			p.Root = CFrame.new(0, -12, 0)
		else -- pop: up out of the floor, higher than he stands, claws wide, then down on his feet
			local up = math.clamp(ph / 0.22, 0, 1)
			local down = math.clamp((ph - 0.22) / 0.35, 0, 1)
			p.Root = CFrame.new(0, -10 * (1 - up) + 4.5 * up * (1 - down * down), 0) * A(0.25 * (1 - down), 0, 0)
			p.Neck = A(0.5 * (1 - down), 0, 0)
			p.RightShoulder = A(2.3, 0, 0.7); p.LeftShoulder = A(2.3, 0, -0.7)
			p.RightElbow = A(0.5, 0, 0); p.LeftElbow = A(0.5, 0, 0)
			p.RightHip = A(0.5 * (1 - down), 0, 0.15); p.LeftHip = A(0.3 * (1 - down), 0, -0.15)
			p.RightKnee = A(-0.7 * (1 - down), 0, 0); p.LeftKnee = A(-0.5 * (1 - down), 0, 0)
		end
	elseif ab == "titanGrab" then
		-- the Flayed Giant: reach, carry the victim out in front, swing them across (twice), lift and throw
		local ph = os.clock() - phaseT
		if phase == "wind" then
			-- THE TELL (the server's wind time, AbilityPhaseDur): he rears back, head up, both arms raised high and wide
			-- and shaking, then in the last moment lunges both hands forward to grab
			local dur = current and current:GetAttribute("AbilityPhaseDur") or 1.15
			local f = ph / math.max(0.2, dur)
			local e = math.clamp(f / 0.35, 0, 1); e = e * e * (3 - 2 * e)
			local k = math.clamp((f - 0.72) / 0.28, 0, 1); k = k * k * (3 - 2 * k)
			local shake = s(t * 34) * 0.05 * (1 - k)
			local function mix(x: number, y: number): number return x + (y - x) * k end
			p.Root = A(mix(0.16 * e, -0.35), 0, 0)
			p.Waist = A(mix(0.18 * e, -0.25), shake, 0)
			p.Neck = A(mix(0.4 * e, -0.2), 0, 0)
			p.RightShoulder = A(mix(2.7 * e, 1.6) + shake, 0, mix(-0.9 * e, -0.12))
			p.LeftShoulder = A(mix(2.7 * e, 1.6) - shake, 0, mix(0.9 * e, 0.12))
			p.RightElbow = A(mix(0.6 * e, 0.05), 0, 0); p.LeftElbow = A(mix(0.6 * e, 0.05), 0, 0)
			p.RightHip = A(mix(-0.1 * e, 0.35), 0, 0); p.LeftHip = A(mix(0.1 * e, -0.25), 0, 0)
			p.RightKnee = A(mix(0, -0.4), 0, 0)
		elseif phase == "carry" then
			p.Waist = A(0.1, 0.2, 0); p.Neck = A(-0.15, 0, 0)
			p.RightShoulder = A(1.55, 0, -0.15); p.RightElbow = A(0.15, 0, 0)
			p.LeftShoulder = A(s(t * 6) * 0.4, 0, 0.15)
			local w = t * 6
			p.RightHip = A(s(w) * 0.55, 0, 0); p.LeftHip = A(-s(w) * 0.55, 0, 0)
			p.RightKnee = A(-math.max(0, s(w + 1.2)) * 0.8, 0, 0); p.LeftKnee = A(-math.max(0, -s(w + 1.2)) * 0.8, 0, 0)
		elseif phase == "swing" or phase == "swing2" then
			local k = math.clamp(ph / 0.42, 0, 1)
			k = k * k * (3 - 2 * k)
			p.Root = A(0.1, 0, 0)
			p.Waist = A(0.15, 1.1 - 2.3 * k, 0) -- a full twist from his right to his left
			p.Neck = A(-0.1, -0.5 + k, 0)
			p.RightShoulder = A(1.45, 0, -1.25 + 0.4 * k); p.RightElbow = A(0.1, 0, 0)
			p.LeftShoulder = A(0.5, 0, 0.6); p.LeftElbow = A(0.6, 0, 0)
			p.RightHip = A(-0.2, 0, 0); p.LeftHip = A(0.3, 0, 0); p.LeftKnee = A(-0.3, 0, 0)
		else -- hold: lift the victim overhead, then the throw
			p.Waist = A(-0.25, 0.3, 0); p.Neck = A(-0.3, 0, 0)
			p.RightShoulder = A(2.9, 0, -0.2); p.RightElbow = A(0.3, 0, 0)
			p.LeftShoulder = A(0.6, 0, 0.6)
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

-- the Void Knight's blade: drawn back over his right shoulder, then a long cut across and down (WindUp -> Swipe)
local function saberSlash(state: string, _t: number, since: number): { [string]: CFrame }
	local p = {}
	local a = math.min(1, since / 0.35)
	p.LeftShoulder = A(0.35, 0, -0.3); p.LeftElbow = A(0.6, 0, 0)
	if state == "WindUp" then
		p.Root = A(-0.06 * a, 0, 0); p.Waist = A(-0.08, -0.7 * a, 0); p.Neck = A(0.05, 0.55 * a, 0)
		p.RightShoulder = A(2.5 * a, 0, 0.75 * a); p.RightElbow = A(0.7 * a, 0, 0); p.RightWrist = A(0.5 * a, 0, 0)
		p.RightHip = A(-0.28, 0, 0.1); p.LeftHip = A(0.3, 0, -0.1)
	else
		p.Root = A(0.16, 0, 0) * CFrame.new(0, -0.25, -0.9); p.Waist = A(0.2, 0.85, 0); p.Neck = A(-0.1, -0.55, 0)
		p.RightShoulder = A(0.95, 0, -1.0); p.RightElbow = A(0.05, 0, 0); p.RightWrist = A(-0.3, 0, 0)
		p.LeftHip = A(0.6, 0, 0); p.RightHip = A(-0.45, 0, 0); p.LeftKnee = A(-0.45, 0, 0)
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
	-- the Golden Conqueror's beam: braced, the gauntlet held straight out (a little shake from the recoil)
	if state == "Laser" then
		local a = math.min(1, sinceState / 0.5)
		p.Root = A(-0.06, 0, 0); p.Waist = A(-0.08, -0.3 * a, 0); p.Neck = A(0.05, 0.3 * a, 0)
		p.RightShoulder = A(1.55 * a + s(t * 38) * 0.02, 0, -0.1); p.RightElbow = A(0.05, 0, 0); p.RightWrist = A(-0.35 * a, 0, 0)
		p.LeftShoulder = A(0.9 * a, 0, 0.7 * a); p.LeftElbow = A(1.3 * a, 0, 0) -- left hand steadying the forearm
		p.RightHip = A(-0.35, 0, 0.12); p.LeftHip = A(0.35, 0, -0.12); p.LeftKnee = A(-0.3, 0, 0); p.RightKnee = A(-0.15, 0, 0)
		return p
	end
	-- the Last Call's shotgun: side on, the gun arm (left) straight out along the barrel, the knife hand under it
	if state == "Shotgun" then
		local a = math.min(1, sinceState / 0.45)
		p.Root = A(-0.05, 0, 0); p.Waist = A(-0.05, 0.35 * a, 0); p.Neck = A(0.05, -0.35 * a, 0.15 * a)
		p.LeftShoulder = A(1.57 * a, 0, 0.12 * a); p.LeftElbow = A(0.04, 0, 0); p.LeftWrist = A(0, 0, 0)
		p.RightShoulder = A(1.25 * a, 0, -0.75 * a); p.RightElbow = A(0.9 * a, 0, 0)
		p.RightHip = A(-0.3, 0, 0.1); p.LeftHip = A(0.3, 0, -0.1); p.LeftKnee = A(-0.25, 0, 0)
		return p
	end
	-- the Caller's knife: raised by his ear, then driven down and in (WindUp -> Swipe)
	if (state == "WindUp" or state == "Swipe") and g:GetAttribute("MonsterId") == "Caller" then
		local a = math.min(1, sinceState / 0.3)
		if state == "WindUp" then
			p.Root = A(-0.12 * a, 0, 0); p.Waist = A(-0.2 * a, -0.35 * a, 0); p.Neck = A(0.15, 0.3 * a, 0)
			p.RightShoulder = A(2.25 * a, 0, 0.25 * a); p.RightElbow = A(0.6 * a, 0, 0); p.RightWrist = A(0.1, 0, 0)
			p.LeftShoulder = A(0.9 * a, 0, -0.5 * a); p.LeftElbow = A(0.8, 0, 0)
			p.RightHip = A(-0.3, 0, 0.1); p.LeftHip = A(0.35, 0, -0.1); p.LeftKnee = A(-0.3, 0, 0)
		else
			p.Root = A(0.35, 0, 0) * CFrame.new(0, -0.3, -0.9); p.Waist = A(0.4, 0.45, 0); p.Neck = A(-0.35, -0.35, 0)
			p.RightShoulder = A(0.85, 0, -0.25); p.RightElbow = A(0.15, 0, 0); p.RightWrist = A(-0.3, 0, 0)
			p.LeftShoulder = A(-0.5, 0, -0.4); p.LeftElbow = A(0.5, 0, 0)
			p.LeftHip = A(0.7, 0, 0); p.RightHip = A(-0.5, 0, 0); p.LeftKnee = A(-0.6, 0, 0)
		end
		return p
	end
	-- the Goblin and the Conqueror punch (haymakers and a two-fisted slam) instead of clawing
	if (state == "WindUp" or state == "Swipe") and (g:GetAttribute("MonsterId") == "Goblin" or g:GetAttribute("MonsterId") == "Conqueror") then
		return goblinClaw(state, t, sinceState)
	end
	if (state == "WindUp" or state == "Swipe") and g:GetAttribute("MonsterId") == "Pirate" then
		return pirateSlash(state, t, sinceState)
	end
	if (state == "WindUp" or state == "Swipe") and g:GetAttribute("MonsterId") == "Knight" then
		return saberSlash(state, t, sinceState)
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
		elseif g:GetAttribute("MonsterId") == "Caller" then
			-- leaning into his run, the knife held up by his shoulder, head tilted
			p.Waist = (p.Waist or CFrame.new()) * A(0.28, 0, 0)
			p.Neck = A(-0.22, s(t * 1.3) * 0.12, 0.22)
			p.RightShoulder = A(1.35 + s(t * 9) * 0.08, 0, 0.3); p.RightElbow = A(1.55, 0, 0); p.RightWrist = A(0.15, 0, 0)
		elseif g:GetAttribute("MonsterId") == "Knight" then
			-- upright and unhurried: the chest out, the blade held low beside him, the left fist at his belt
			p.Waist = (p.Waist or CFrame.new()) * A(-0.06, 0, 0)
			p.Neck = A(0.06, 0, 0)
			p.RightShoulder = A(0.12, 0, 0.28); p.RightElbow = A(0.35, 0, 0); p.RightWrist = A(-0.15, 0, 0)
			p.LeftShoulder = A(0.2 + s(t * 5) * 0.06, 0, -0.18); p.LeftElbow = A(0.9, 0, 0)
		elseif g:GetAttribute("MonsterId") == "Pirate" then
			p.Waist = (p.Waist or CFrame.new()) * A(0.18, 0, 0) -- a crooked skeleton walk, shield up, cutlass low
			p.Neck = A(-0.15, s(t * 1.1) * 0.15, s(t * 2.7) * 0.1)
			p.LeftShoulder = A(0.15, 0.25, -0.25); p.LeftElbow = A(1.35, 0, 0)
			p.RightElbow = A(0.5, 0, 0)
		elseif g:GetAttribute("MonsterId") == "Rat" then
			-- a fat rat on its hind legs: hunched over its belly, paws held up in front, nose twitching, sniffing
			p.Waist = (p.Waist or CFrame.new()) * A(-0.32, 0, 0)
			p.Neck = A(0.3 + s(t * 11) * 0.04, s(t * 1.9) * 0.3, 0)
			p.RightShoulder = A(0.85 + s(t * 9) * 0.1, 0, -0.2); p.LeftShoulder = A(0.85 - s(t * 9) * 0.1, 0, 0.2)
			p.RightElbow = A(1.1, 0, 0); p.LeftElbow = A(1.1, 0, 0)
			p.RightWrist = A(0.4, 0, 0); p.LeftWrist = A(0.4, 0, 0)
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
local heldTotal = 0 -- (time spent held by the tutorial: model attribute Held, Server/Tutorial; her pose stops)
local warned = false
local height = 8 -- the bound monster's height (entrances move the body by it)
function GA.update(dt: number)
	local g = workspace:FindFirstChild("Ghost") :: Model?
	if g ~= current then
		if g then
			bind(g)
			stateSeen = "" -- a new monster: its first state starts now
			height = EP.height(g)
		else
			current = nil
		end
	end
	if not current or not current.Parent then return end
	if current:GetAttribute("Held") == true then heldTotal += dt end
	local t = os.clock() - heldTotal
	local state = current:GetAttribute("State") or "Chase"
	-- Fury moves reuse the attack poses: roar / lunge crouch = wind-up, lunge dash = swipe
	if state == "Evo" and current:GetAttribute("EvoPower") == "laser" then state = "Laser"
	elseif state == "Evo" and current:GetAttribute("EvoPower") == "shotgun" then state = "Shotgun"
	elseif state == "Roar" or state == "Evo" then state = "WindUp"
	elseif state == "Lunge" then state = current:GetAttribute("FuryPhase") == "dash" and "Swipe" or "WindUp" end
	local ph = current:GetAttribute("AbilityPhase") or ""
	if ph ~= phaseSeen then phaseSeen = ph; phaseT = t end
	-- Studio photo hook: ReplicatedStorage DebugFreezeGhost also holds the ability poses where they are
	if RunService:IsStudio() and game:GetService("ReplicatedStorage"):GetAttribute("DebugFreezeGhost") then
		phaseT = t - (frozenPh or (t - phaseT))
		frozenPh = t - phaseT
	else
		frozenPh = nil
	end
	if state ~= stateSeen then
		stateSeen = state; stateT = t
		if state == "WindUp" then gobVariant = gobVariant % 3 + 1 end
	end
	-- vanish / spawn / death fade
	local want = 0
	if current:GetAttribute("Vanish") then want = 1 end
	local shadow = current:GetAttribute("Shadow") == true
	-- the stalker in the dark: the Woman is barely visible, the Party Bear is gone except for its eyes
	if shadow then want = current:GetAttribute("MonsterId") == "Animatronic" and 1 or 0.88 end
	if state == "Dead" then want = math.min(1, (t - stateT) / 2.5) end
	if state == "Spawn" then want = 1 - math.min(1, (t - stateT) / 1.8) end
	fade += (want - fade) * math.min(1, dt * (state == "Dead" and 3 or 6))
	-- its ENTRANCE (Shared/Entrances): the body follows EntrancePose on the cinematic's clock, with no smoothing
	local entrance: { [string]: CFrame }? = nil
	if state == "Spawn" and (tonumber(current:GetAttribute("EntranceTime")) or 0) > 0 then
		local s = EP.clock.model == current and EP.clock.s or (t - stateT)
		local ep, alpha = EP.pose(current:GetAttribute("MonsterId") or "", current:GetAttribute("Evolved") == true, s, t, height)
		if ep then
			entrance = ep
			fade = alpha
			-- turned toward the cinematic's camera, and back to where the server has it looking at the very end
			local face = EP.clock.model == current and EP.clock.face or nil
			local root = current:FindFirstChild("HumanoidRootPart")
			if face and root and root:IsA("BasePart") then
				local dur = tonumber(current:GetAttribute("EntranceTime")) or 5
				local l = root.CFrame:VectorToObjectSpace(face)
				local back = math.clamp((s - (dur - 0.95)) / 0.6, 0, 1)
				ep.Root = CFrame.Angles(0, math.atan2(-l.X, -l.Z) * (1 - back * back * (3 - 2 * back)), 0) * (ep.Root or CFrame.new())
			end
		end
	end
	if shadow and want >= 1 then fade = 1 end -- the lights cut: the Party Bear is gone at once
	local neonEyes = shadow and state ~= "Dead"
	for _, d in current:GetDescendants() do
		-- parts with the Glow attribute (the Party Bear's eyes) stay visible in the dark; DarkNeon parts light up there
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			d.LocalTransparencyModifier = (d:GetAttribute("Glow") and state ~= "Dead") and 0 or fade
			if d:GetAttribute("DarkNeon") then
				local mat = neonEyes and Enum.Material.Neon or Enum.Material.SmoothPlastic
				if d.Material ~= mat then d.Material = mat end
			end
		elseif d:IsA("PointLight") and d.Parent and d.Parent:GetAttribute("DarkNeon") then
			d.Brightness = neonEyes and 1.4 or 0.5
		elseif d:IsA("BillboardGui") and d.Name == "EyeHalo" then
			d.Enabled = neonEyes
		end
	end
	-- the pose (in a pcall: an error here must never skip the fade above, which hides the Party Bear in the dark)
	local ok, err = pcall(function()
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
		local tp = entrance or target(state, t, t - stateT)
		local speed = (state == "Swipe" or state == "Knocked" or state == "Ability") and 22 or 12
		local a = entrance and 1 or (1 - math.exp(-speed * dt))
		for name, m in joints do
			if frozen then m.Transform = pose[name]; continue end
			local want = tp[name] or CFrame.new()
			pose[name] = pose[name]:Lerp(want, a)
			m.Transform = pose[name]
		end
	end)
	if not ok and not warned then
		warned = true
		warn("[GhostAnim] pose failed: " .. tostring(err))
	end
end

function GA.init()
	RunService:BindToRenderStep("GhostAnim", Enum.RenderPriority.Character.Value + 1, GA.update)
end

return GA
