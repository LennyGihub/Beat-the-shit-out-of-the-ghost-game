--!strict
-- UltPose: the arm pose OTHER players see when someone casts an ultimate (the caster sees the first-person hands
-- in Viewmodel). One pose list per cast animation, played over the character's own animation for a second by
-- writing the R15 arm and waist joints' Transform after the Animator each frame.
local RunService = game:GetService("RunService")
local Kit = require(script.Parent.UltKit)

local Pose = {}
-- a key: { t, right shoulder { x, z }, right elbow, left shoulder { x, z } or nil (mirror), left elbow, waist }
-- shoulder x = arm swung forward/up (3 = straight up), z = arm out to the side; elbow = bend; waist < 0 = lean in
type Key = { any }
local function K(t: number, rx: number, rz: number, re: number, w: number, lx: number?, lz: number?, le: number?): Key
	return { t, rx, rz, re, lx or rx, lz or -rz, le or re, w }
end
local REST = K(0, 0, 0, 0, 0)
local function seq(...: Key): { Key }
	local list = { REST, ... }
	local last = table.clone(REST)
	last[1] = 1
	table.insert(list, last)
	return list
end
local POSES: { [string]: { Key } } = {
	slam = seq(K(0.26, 3.0, 0.1, 0.2, 0.25), K(0.34, 3.1, 0.1, 0.2, 0.3), K(0.42, 0.9, 0, 0.3, -0.6), K(0.62, 0.9, 0, 0.3, -0.55)),
	sweep = seq(K(0.28, 1.4, 1.2, 0.2, 0, 1.4, 0.7, 0.2), K(0.44, 1.4, -0.8, 0.1, -0.1, 1.4, -1.3, 0.1), K(0.62, 1.3, -0.9, 0.2, -0.1, 1.3, -1.4, 0.2)),
	uppercut = seq(K(0.26, -0.6, 0.2, 0.9, -0.4, 0.9, 0, 1.6), K(0.42, 2.9, 0, 0.4, 0.3, 0.9, 0, 1.6), K(0.6, 3.0, 0, 0.3, 0.3, 0.9, 0, 1.6)),
	flip = seq(K(0.26, 0.3, 0.2, 0.3, -0.55), K(0.42, 2.6, 0.3, 0.2, 0.3), K(0.6, 2.8, 0.3, 0.2, 0.35)),
	tele = seq(K(0.27, 1.9, 0.6, 0.5, 0.15), K(0.36, 2.0, 0.6, 0.5, 0.2), K(0.44, 1.5, 0.1, 0, -0.2), K(0.62, 1.5, 0.1, 0, -0.2)),
	sky = seq(K(0.22, 3.0, 0, 0, 0.2, 0.5, 0, 1.2), K(0.38, 3.1, 0, 0, 0.25, 0.5, 0, 1.2), K(0.46, 0.6, 0, 0.3, -0.35, 0.5, 0, 1.2), K(0.64, 0.6, 0, 0.3, -0.3, 0.5, 0, 1.2)),
	clap = seq(K(0.28, 0.4, 1.5, 0, 0.15), K(0.4, 1.5, -0.3, 0.1, -0.15), K(0.56, 1.5, -0.3, 0.1, -0.15)),
	pull = seq(K(0.22, 1.5, -0.3, 0.1, -0.1), K(0.34, 1.5, -0.3, 0.1, -0.1), K(0.42, 0.5, 1.5, 0, 0.2), K(0.68, 0.5, 1.55, 0, 0.25)),
	flex = seq(K(0.22, 1.2, -0.5, 1.6, -0.25), K(0.33, 1.2, -0.5, 1.6, -0.25), K(0.4, 0.3, 1.1, 0.9, 0.3), K(0.72, 0.3, 1.15, 0.9, 0.35)),
	push = seq(K(0.26, 0.5, 0.2, 1.9, 0.1), K(0.42, 1.6, 0, 0, -0.25), K(0.62, 1.6, 0, 0, -0.2)),
	chug = seq(K(0.18, 1.9, -0.2, 1.7, 0.2, 0, 0, 0), K(0.36, 2.0, -0.2, 1.8, 0.3, 0, 0, 0), K(0.46, 0.4, 0.9, 0.3, 0, 0, 0, 0), K(0.85, 0.6, 0.3, 1.2, 0, 0.6, -0.3, 1.2)),
	pray = seq(K(0.24, 1.2, -0.4, 1.5, -0.1), K(0.36, 1.3, -0.4, 1.5, 0), K(0.46, 2.5, 0.6, 0.2, 0.2), K(0.75, 2.6, 0.6, 0.2, 0.25)),
	windup = seq(K(0.25, -0.9, 0.3, 1.8, 0, 1.5, 0, 0), K(0.7, -0.9, 0.3, 1.8, 0, 1.5, 0, 0)),
	bump = seq(K(0.24, 0.6, 0.8, 0.6, 0), K(0.4, 1.3, -0.5, 1.2, -0.1), K(0.66, 1.0, 0, 1.3, 0)),
	snap = seq(K(0.3, 2.2, 0, 0.8, 0.1, 0, 0, 0), K(0.7, 2.2, 0, 0.8, 0.1, 0, 0, 0)),
	claw = seq(K(0.24, 2.4, 0.6, 0.5, 0.1, 0.5, 0, 1), K(0.4, 0.6, -0.6, 0.3, -0.2, 2.4, -0.6, 0.5), K(0.52, 0.6, -0.5, 0.3, -0.2, 0.6, 0.6, 0.3), K(0.66, 0.4, 0, 0.6, -0.1, 0.6, 0.5, 0.3)),
	breath = seq(K(0.36, 0.3, 1.3, 0, 0.3), K(0.5, 0.35, 1.35, 0, 0.35), K(0.64, 0.7, 0.2, 1.5, 0), K(0.8, 0.7, 0.2, 1.5, 0)),
	flurry = seq(K(0.3, 0.5, 0.2, 1.8, 0), K(0.4, 1.6, 0, 0, -0.1, 0.5, -0.2, 1.8), K(0.485, 0.5, 0.2, 1.8, -0.1, 1.6, 0, 0), K(0.57, 1.6, 0, 0, -0.1, 0.5, -0.2, 1.8),
		K(0.655, 0.5, 0.2, 1.8, -0.1, 1.6, 0, 0), K(0.74, 1.6, 0, 0, -0.1, 0.5, -0.2, 1.8), K(0.825, 0.5, 0.2, 1.8, -0.1, 1.6, 0, 0)),
	point = seq(K(0.2, 3.0, 0, 0, 0.15, 1.0, 0, 2.2), K(0.3, 3.0, 0, 0, 0.15, 1.0, 0, 2.2), K(0.38, 1.6, 0, 0, -0.1, 1.0, 0, 2.2), K(0.75, 1.6, 0, 0, -0.1, 1.0, 0, 2.2)),
	stomp = seq(K(0.27, 0.2, 0.3, 0.6, -0.55), K(0.4, 0.6, 1.2, 0.4, 0.3), K(0.72, 0.6, 1.25, 0.4, 0.35)),
}
local DUR: { [string]: number } = { tele = 1.1, pull = 1.1, flex = 1.1, chug = 1.3, pray = 1.1, windup = 1.4, bump = 0.95, breath = 1.1, point = 1.2, stomp = 1.1 }

local active: { [Model]: { name: string, t0: number, hold: number? } } = {}

-- the joint is a Motor6D on older rigs and an AnimationConstraint on newer avatars: both have Transform
local function joint(ch: Model, part: string, name: string): any
	local p = ch:FindFirstChild(part)
	local m = p and p:FindFirstChild(name)
	return (m and (m:IsA("Motor6D") or m:IsA("AnimationConstraint"))) and m or nil
end

local function apply(ch: Model, k: { number }, w: number)
	local function set(part: string, name: string, cf: CFrame)
		local m = joint(ch, part, name)
		if m then m.Transform = m.Transform:Lerp(cf, w) end
	end
	set("RightUpperArm", "RightShoulder", CFrame.Angles(k[2], 0, k[3]))
	set("RightLowerArm", "RightElbow", CFrame.Angles(k[4], 0, 0))
	set("LeftUpperArm", "LeftShoulder", CFrame.Angles(k[5], 0, k[6]))
	set("LeftLowerArm", "LeftElbow", CFrame.Angles(k[7], 0, 0))
	set("UpperTorso", "Waist", CFrame.Angles(k[8], 0, 0))
end

-- hold = a fixed moment of the pose (0..1), kept until the next play (Studio tests photograph it)
function Pose.play(ch: Model?, name: string, hold: number?)
	if ch then active[ch] = { name = POSES[name] and name or "slam", t0 = Kit.now(), hold = hold } end
end

function Pose.init()
	RunService.Stepped:Connect(function()
		for ch, st in active do
			local a = st.hold or (Kit.now() - st.t0) / (DUR[st.name] or 1)
			if a >= 1 or not ch.Parent then
				active[ch] = nil
				continue
			end
			local keys = POSES[st.name]
			for i = 1, #keys - 1 do
				local k0, k1 = keys[i], keys[i + 1]
				if a <= k1[1] then
					local f = math.clamp((a - k0[1]) / math.max(1e-3, k1[1] - k0[1]), 0, 1)
					f = f * f * (3 - 2 * f)
					local k = table.create(8, 0)
					for j = 2, 8 do k[j] = k0[j] + (k1[j] - k0[j]) * f end
					apply(ch, k, st.hold and 1 or math.clamp(math.min(a / 0.1, (1 - a) / 0.15), 0, 1))
					break
				end
			end
		end
	end)
end

return Pose
