--!strict
-- The monster's BODY during its entrance (Shared/Entrances): for each monster, the joint pose and how see-through
-- it is at `s` seconds into the entrance. Client/GhostAnim plays it while the monster is in its "Spawn" state;
-- Client/Entrance plays the camera, effects and sounds on the same clock (the beats below, EntrancePose.T).
-- The "Root" joint also carries the body's offset from where the monster really stands (rising out of the floor,
-- falling from the ceiling, walking up): the server-side monster never moves during its entrance.
-- Joint signs (same rig for every monster): Shoulder +X = arm forward / up, +Z (right arm) = out to the side;
-- Elbow +X bends; Hip +X = thigh forward; Knee -X bends; Root / Waist / Neck +X = lean back, -X = forward.
local EP = {}
local A = CFrame.Angles
local sin, exp, pi = math.sin, math.exp, math.pi

-- the beats, in seconds from the start (Client/Entrance times its effects with the same numbers)
EP.T = {
	Woman = { rise0 = 0.4, rise1 = 2.7, scream = 3.25, calm = 4.4 },
	Demon = { pillar = 0.95, stand0 = 1.9, stand1 = 2.9, roar = 3.1, calm = 4.3 },
	Pirate = { walk0 = 0.2, walk1 = 2.5, bang1 = 2.8, bang2 = 3.15, raise = 3.5, calm = 4.4 },
	Animatronic = { light = 1.6, head = 2.6, tada = 3.0, snap = 4.0, calm = 4.8 },
	Titan = { fall = 1.5, land = 1.85, rise0 = 3.0, rise1 = 3.9, roar = 3.95, calm = 4.6 },
	Goblin = { puff1 = 0.4, puff2 = 0.95, flip = 1.5, land = 2.0, rub0 = 2.3, rub1 = 3.3, point = 3.45, calm = 4.3 },
	Caller = { flash1 = 0.9, flash2 = 1.9, flash3 = 2.8, raise = 3.1, pump = 3.95 },
	Conqueror = { portal = 0.1, step0 = 1.4, step1 = 3.0, close = 3.1, fist = 3.4, clench = 3.9, calm = 4.9 },
	Rat = { burst = 1.7, peak = 1.98, land = 2.4, rear = 3.4, calm = 4.2 },
	Knight = { breath = 0.15, cut0 = 0.9, cut1 = 2.7, kick = 2.95, fall = 3.4, step0 = 3.3, step1 = 4.5, raise = 4.65, calm = 5.7 },
	Antlered = { crawl0 = 0.3, crawl1 = 1.7, fall = 1.95, land = 2.35, rise0 = 3.0, rise1 = 3.75, roar = 3.85, calm = 4.65 },
	LakeWitch = { hand = 0.9, rise0 = 1.1, rise1 = 2.9, swing0 = 3.0, slam = 4.0, calm = 4.8 },
	Counselor = { strike = 0.9, raise0 = 1.5, raise1 = 2.3, look1 = 3.2, ring = 3.5, calm = 4.5 },
	Scarecrow = { twitch = 1.5, snap = 2.45, burst = 2.6, drop = 3.1, land = 3.4, rise0 = 3.55, rise1 = 4.1, raise = 4.2, calm = 5.0 },
	Clown = { music = 0.1, shake = 1.6, pop = 2.8, land = 3.35, tada = 3.6, calm = 4.5 },
	Strongman = { grip = 0.3, lift0 = 1.0, lift1 = 2.0, press = 2.5, roar = 2.85, drop = 3.7, calm = 4.3 },
	Fortune = { glow = 0.4, face = 1.2, appear0 = 2.0, appear1 = 3.0, cards = 3.5, calm = 4.6 },
	Ringmaster = { spot = 0.3, raise = 1.7, arms = 2.3, crack = 3.1, lights = 3.4, calm = 4.9 },
}
EP.FLASH = 0.16 -- how long each of the Caller's flashes shows him
-- the running entrance's clock, written by Client/Entrance every frame: which monster, the seconds so far, and
-- `back` = how much of the room behind the monster is free (0.25..1: walk-ups start that much closer in a small room)
-- `face` = the way the monster faces during its entrance (toward the camera; the Root joint turns the body there
-- and turns it back to where the server has it looking in the last moments)
EP.clock = { model = nil :: Model?, s = 0, back = 1, face = nil :: Vector3?, ceil = 16 }
-- (`ceil` = how high the ceiling / rafters are above the floor there: the Antlered One crawls along it)

-- the top of the monster's head above the floor, in studs (its Hover attribute = root height above the floor, plus
-- the rest-pose joints up to the head): what the entrances measure their moves and camera heights with
function EP.height(m: Model): number
	local hover = tonumber(m:GetAttribute("Hover")) or 3
	local rel = CFrame.new()
	for _, n in { "Root", "Waist", "Neck" } do
		local j = m:FindFirstChild(n, true)
		if j and j:IsA("Motor6D") then rel = rel * j.C0 * j.C1:Inverse() end
	end
	local head = m:FindFirstChild("Head")
	local half = (head and head:IsA("BasePart")) and head.Size.Y / 2 or 0.6
	return math.clamp(hover + rel.Y + half, 4, 30)
end

local function seg(s: number, a: number, b: number): number return math.clamp((s - a) / (b - a), 0, 1) end
local function ss(x: number): number return x * x * (3 - 2 * x) end
local function pulse(s: number, at: number, w: number): number
	local d = (s - at) / w
	return exp(-d * d)
end
-- servo steps (the Party Bear): 0..1 in n jerks
local function steps(x: number, n: number): number return math.floor(x * n + 0.5) / n end

type Pose = { [string]: CFrame }

-- a squat, k = 0 (standing) .. 1 (deep)
local function crouch(p: Pose, k: number)
	p.RightHip = A(1.15 * k, 0, 0.14 * k); p.LeftHip = A(0.95 * k, 0, -0.14 * k)
	p.RightKnee = A(-1.7 * k, 0, 0); p.LeftKnee = A(-1.5 * k, 0, 0)
	p.RightAnkle = A(0.5 * k, 0, 0); p.LeftAnkle = A(0.5 * k, 0, 0)
end
-- a walk on the spot (the server-side monster is standing still), ph = phase, am = how much
local function stride(p: Pose, ph: number, am: number)
	local w = sin(ph)
	p.RightHip = A(w * 0.6 * am, 0, 0); p.LeftHip = A(-w * 0.6 * am, 0, 0)
	p.RightKnee = A(-math.max(0, -w) * 0.9 * am - 0.1 * am, 0, 0); p.LeftKnee = A(-math.max(0, w) * 0.9 * am - 0.1 * am, 0, 0)
end

local POSES: { [string]: (p: Pose, s: number, t: number, H: number, evolved: boolean) -> number } = {}

-- THE WOMAN: rises out of the floor, head down; her head snaps up and she screams, arms wide
POSES.Woman = function(p, s, t, H)
	local T = EP.T.Woman
	local rise = ss(seg(s, T.rise0, T.rise1))
	local up = seg(s, T.scream - 0.15, T.scream)
	local scream = seg(s, T.scream, T.scream + 0.22) * (1 - seg(s, T.calm, T.calm + 0.5))
	p.Root = CFrame.new(0, -(H + 1.5) * (1 - rise), 0) * A(-0.14 + 0.36 * scream, 0, sin(t * 1.3) * 0.04)
	p.Waist = A(-0.1 + 0.2 * scream, 0, 0)
	p.Neck = A(-0.9 + 0.95 * up + 0.2 * scream + sin(t * 50) * 0.06 * scream, sin(t * 43) * 0.12 * scream, 0.3 * (1 - up) + sin(t * 37) * 0.1 * scream)
	p.RightShoulder = A(0.15 + 0.95 * scream, 0, 0.08 + 1.2 * scream); p.LeftShoulder = A(0.15 + 0.95 * scream, 0, -0.08 - 1.2 * scream)
	p.RightElbow = A(0.2 + 0.3 * scream, 0, 0); p.LeftElbow = A(0.25 + 0.3 * scream, 0, 0)
	p.RightWrist = A(0.3 + 0.6 * scream, 0, 0); p.LeftWrist = A(0.35 + 0.6 * scream, 0, 0)
	p.RightHip = A(0.12, 0, 0.05); p.LeftHip = A(0.2, 0, -0.05)
	p.RightKnee = A(-0.35, 0, 0); p.LeftKnee = A(-0.5, 0, 0)
	p.RightAnkle = A(-0.7, 0, 0); p.LeftAnkle = A(-0.6, 0, 0)
	return 0.5 * (1 - rise)
end

-- THE RED DEMON: on one knee in the fire, stands up slowly, throws his arms out and roars
POSES.Demon = function(p, s, t, H)
	local T = EP.T.Demon
	local k = 1 - ss(seg(s, T.stand0, T.stand1))
	local roar = seg(s, T.roar, T.roar + 0.22) * (1 - seg(s, T.calm, T.calm + 0.5))
	p.Root = CFrame.new(0, -H * 0.16 * k, 0) * A(-0.5 * k + 0.32 * roar, 0, 0)
	crouch(p, k)
	p.Waist = A(-0.3 * k + 0.25 * roar, 0, 0)
	p.Neck = A(-0.6 * k + 0.5 * roar + sin(t * 44) * 0.04 * roar, 0, 0)
	p.RightShoulder = A(0.55 * k - 0.3 * roar, 0, 0.15 + 1.25 * roar); p.LeftShoulder = A(0.55 * k - 0.3 * roar, 0, -0.15 - 1.25 * roar)
	p.RightElbow = A(0.3 + 0.7 * roar, 0, 0); p.LeftElbow = A(0.3 + 0.7 * roar, 0, 0)
	p.RightWrist = A(0.5 * roar, 0, 0); p.LeftWrist = A(0.5 * roar, 0, 0)
	return s < T.pillar and 1 or 0
end

-- THE PIRATE: strides out of the fog, bangs his cutlass on his shield twice, then holds it high
POSES.Pirate = function(p, s, t, H)
	local T = EP.T.Pirate
	local walk = seg(s, T.walk0, T.walk1)
	local am = seg(s, T.walk0, T.walk0 + 0.3) * (1 - seg(s, T.walk1 - 0.25, T.walk1))
	local ph = s * 8
	stride(p, ph, am)
	local bang = math.min(1, pulse(s, T.bang1, 0.07) + pulse(s, T.bang2, 0.07))
	local ready = seg(s, T.walk1 - 0.1, T.bang1 - 0.12)
	local raise = ss(seg(s, T.raise, T.raise + 0.3)) * (1 - seg(s, T.calm, T.calm + 0.5))
	p.Root = CFrame.new(0, math.abs(sin(ph)) * 0.25 * am, 10 * EP.clock.back * (1 - walk)) * A(-0.1 * am + 0.16 * raise, 0, 0)
	p.Waist = A(0.18 * (1 - raise), -0.25 * bang, 0)
	p.Neck = A(-0.15 + 0.35 * raise, sin(t * 1.1) * 0.15 * (1 - raise), 0)
	p.LeftShoulder = A(0.15 + 0.5 * ready, 0.25, -0.25); p.LeftElbow = A(1.35, 0, 0)
	local swing = A(0.9 * ready + 0.25 * bang, 0, -0.35 * ready - 0.55 * bang)
	p.RightShoulder = swing:Lerp(A(2.95, 0, 0.18), raise)
	p.RightElbow = A(0.5 + 0.5 * ready - 0.45 * bang - 0.9 * raise, 0, 0)
	p.RightWrist = A(-0.3 * raise, 0, 0)
	return 1 - seg(s, T.walk0, T.walk0 + 1.2)
end

-- THE PARTY BEAR: stands in the spotlight with its head down; the head jerks up, the arms jerk wide (showtime).
-- The Golden Bear then lifts a hand and snaps its fingers.
POSES.Animatronic = function(p, s, t, H, evolved)
	local T = EP.T.Animatronic
	local head = steps(seg(s, T.head, T.head + 0.4), 3)
	local tada = steps(seg(s, T.tada, T.tada + 0.3), 3) * (1 - seg(s, T.calm, T.calm + 0.5))
	local tilt = steps(seg(s, T.tada + 0.8, T.tada + 1.0), 2) * (1 - seg(s, T.calm, T.calm + 0.4))
	p.Root = A(0.06 * tada, 0, 0)
	p.Neck = A(-0.95 * (1 - head), (math.floor(t * 3) % 2) * 0.06, 0.45 * tilt)
	p.RightShoulder = A(0.2 * tada, 0, 0.05 + 1.45 * tada); p.LeftShoulder = A(0.2 * tada, 0, -0.05 - 1.45 * tada)
	p.RightElbow = A(0.55 * tada, 0, 0); p.LeftElbow = A(0.55 * tada, 0, 0)
	p.RightWrist = A(-0.5 * tada, 0, 0); p.LeftWrist = A(-0.5 * tada, 0, 0)
	if evolved then
		local up = ss(seg(s, T.snap - 0.35, T.snap - 0.08)) * (1 - seg(s, T.calm, T.calm + 0.4))
		local click = pulse(s, T.snap, 0.05)
		p.RightShoulder = (p.RightShoulder :: CFrame):Lerp(A(1.75, 0, 0.3), up)
		p.RightElbow = A(0.55 * tada, 0, 0):Lerp(A(1.15, 0, 0), up)
		p.RightWrist = A(-0.5 * tada, 0, 0):Lerp(A(0.35 - 0.8 * click, 0, 0), up)
	end
	return s < T.light and 1 or 0
end

-- THE FLAYED GIANT: falls out of the ceiling with both fists up, lands in a crouch on one fist, stands, roars
POSES.Titan = function(p, s, t, H)
	local T = EP.T.Titan
	local f = seg(s, T.fall, T.land)
	local landed = s >= T.land
	local k = landed and (1 - ss(seg(s, T.rise0, T.rise1))) or 0.35
	local squash = landed and exp(-(s - T.land) / 0.22) or 0
	local roar = seg(s, T.roar, T.roar + 0.22) * (1 - seg(s, T.calm, T.calm + 0.35))
	p.Root = CFrame.new(0, 48 * (1 - f * f) - H * 0.17 * k - H * 0.05 * squash, 0) * A(-0.55 * k + 0.38 * roar, 0, 0)
	crouch(p, k)
	p.Waist = A(-0.25 * k + 0.25 * roar, 0, 0)
	p.Neck = A(-0.2 * k + 0.55 * roar + sin(t * 40) * 0.04 * roar, 0, 0)
	if not landed then
		p.RightShoulder = A(2.8, 0, 0.2); p.LeftShoulder = A(2.8, 0, -0.2)
		p.RightElbow = A(0.4, 0, 0); p.LeftElbow = A(0.4, 0, 0)
	else
		p.RightShoulder = A(1.0 * k + 0.25 * roar, 0, 0.1 + 1.35 * roar); p.LeftShoulder = A(-0.5 * k + 0.25 * roar, 0, -0.45 * k - 1.35 * roar)
		p.RightElbow = A(0.15 + 1.3 * roar, 0, 0); p.LeftElbow = A(0.5 * k + 1.3 * roar, 0, 0)
	end
	return s < T.fall and 1 or 0
end

-- THE GOBLIN: somersaults out of the last smoke puff, lands low, rubs his hands, then points at you and cackles
POSES.Goblin = function(p, s, t, H)
	local T = EP.T.Goblin
	local fl = seg(s, T.flip, T.land)
	local landed = s >= T.land
	local k = landed and (0.95 - 0.6 * ss(seg(s, T.land, T.land + 0.45))) or 0.7
	local rub = seg(s, T.rub0 - 0.05, T.rub0 + 0.15) * (1 - seg(s, T.rub1, T.rub1 + 0.15))
	local point = seg(s, T.point, T.point + 0.15) * (1 - seg(s, T.calm, T.calm + 0.35))
	p.Root = CFrame.new(0, 7.5 * (1 - fl) * (1 + fl * 0.6) - H * 0.12 * k, 0) * A(-2 * pi * fl - 0.3 * k - 0.2 * point, 0, 0)
	crouch(p, k)
	p.Waist = A(-0.3, 0, 0)
	p.Neck = A(-0.25 + 0.5 * point + sin(t * 30) * 0.1 * point, sin(t * 7) * 0.55 * rub, 0)
	p.RightShoulder = A(0.95 * rub + 1.6 * point, 0, -0.4 * rub); p.LeftShoulder = A(0.95 * rub + 0.2 * point, 0, 0.4 * rub - 0.5 * point)
	p.RightElbow = A(1.45 * rub, 0, 0); p.LeftElbow = A(1.45 * rub + 1.2 * point, 0, 0)
	p.RightWrist = A(sin(t * 18) * 0.4 * rub, 0, 0); p.LeftWrist = A(-sin(t * 18) * 0.4 * rub, 0, 0)
	return s < T.flip and 1 or 0
end

-- THE CALLER: only seen in three flashes of light, each time closer; then he tilts his head and lifts the knife
-- (the Last Call racks his shotgun)
POSES.Caller = function(p, s, t, H, evolved)
	local T = EP.T.Caller
	local z = s < (T.flash1 + T.flash2) / 2 and 17 or (s < (T.flash2 + T.flash3) / 2 and 8.5 or 0)
	local tilt = ss(seg(s, T.raise - 0.1, T.raise + 0.5))
	local raise = ss(seg(s, T.raise, T.raise + 0.6))
	p.Root = CFrame.new(0, 0, z * EP.clock.back)
	p.Waist = A(0.1 * raise, 0, 0)
	p.Neck = A(-0.12, 0, 0.5 * tilt)
	p.RightShoulder = A(1.35 * raise, 0, 0.3 * raise); p.RightElbow = A(1.55 * raise, 0, 0); p.RightWrist = A(0.15 * raise, 0, 0)
	p.LeftShoulder = A(0.05, 0, -0.06)
	if evolved then
		local pump = pulse(s, T.pump, 0.09)
		local hold = seg(s, T.pump - 0.4, T.pump - 0.15)
		p.LeftShoulder = A(1.0 * hold, 0.2 * hold, -0.2 * hold); p.LeftElbow = A((0.9 + 0.45 * pump) * hold, 0, 0)
	end
	local seen = s >= T.flash3 or (s >= T.flash1 and s < T.flash1 + EP.FLASH) or (s >= T.flash2 and s < T.flash2 + EP.FLASH)
	return seen and 0 or 1
end

-- THE CONQUEROR: walks out of his portal with heavy steps, then lifts his gauntlet and closes the fist
POSES.Conqueror = function(p, s, t, H)
	local T = EP.T.Conqueror
	local walk = seg(s, T.step0, T.step1)
	local am = seg(s, T.step0, T.step0 + 0.2) * (1 - seg(s, T.step1 - 0.2, T.step1))
	local ph = (s - T.step0) * 2 * pi
	stride(p, ph, am * 0.8)
	local fist = ss(seg(s, T.fist, T.clench - 0.1)) * (1 - seg(s, T.calm, T.calm + 0.4))
	local clench = seg(s, T.clench - 0.05, T.clench + 0.05)
	p.Root = CFrame.new(0, math.abs(sin(ph)) * 0.18 * am, 7.5 * EP.clock.back * (1 - walk)) * A(-0.05 + 0.1 * fist, 0, 0)
	p.Waist = A(0.15 * fist, 0, 0)
	p.Neck = A(-0.1 + 0.3 * fist, 0, 0)
	p.RightShoulder = A(2.9 * fist + sin(ph + pi) * 0.25 * am, 0, 0.15 * fist); p.RightElbow = A(0.2 + 0.6 * fist * (1 - clench) + 0.35 * clench, 0, 0)
	p.RightWrist = A(0.5 * clench * fist, 0, 0)
	p.LeftShoulder = A(-0.2 * fist + sin(ph) * 0.25 * am, 0, -0.3 * fist); p.LeftElbow = A(0.2 + 0.8 * fist, 0, 0)
	return s < T.step0 and 1 or 0
end

-- THE SEWER RAT: bursts up out of the floor, lands on all fours, sniffs left and right, then rears up and shrieks
POSES.Rat = function(p, s, t, H)
	local T = EP.T.Rat
	local up = seg(s, T.burst, T.peak)
	local down = seg(s, T.peak, T.land)
	local rear = ss(seg(s, T.rear, T.rear + 0.3)) * (1 - seg(s, T.calm, T.calm + 0.4))
	local four = (s >= T.peak and 1 or up) * (1 - rear) * (1 - seg(s, T.calm, T.calm + 0.4)) -- how much he is on all fours
	local y = -(H + 2) * (1 - up) + 5 * up * (1 - down * down)
	p.Root = CFrame.new(0, y - 2.0 * four * (s >= T.land and 1 or down), 0) * A(-1.15 * four + 0.3 * rear, 0, 0)
	p.Waist = A(-0.15 * four + 0.15 * rear, 0, 0)
	local sniff = seg(s, T.land + 0.1, T.land + 0.3) * (1 - seg(s, T.rear - 0.2, T.rear))
	p.Neck = A(1.0 * four + 0.35 * rear + sin(t * 30) * 0.05 * rear, sin((s - T.land) * 5.5) * 0.7 * sniff, 0)
	p.RightShoulder = A(1.35 * four + 1.2 * rear + 2.2 * up * (1 - down), 0, 0.1 + 1.1 * rear); p.LeftShoulder = A(1.35 * four + 1.2 * rear + 2.2 * up * (1 - down), 0, -0.1 - 1.1 * rear)
	p.RightElbow = A(0.3 + 0.7 * rear, 0, 0); p.LeftElbow = A(0.3 + 0.7 * rear, 0, 0)
	p.RightHip = A(1.2 * four, 0, 0.1); p.LeftHip = A(1.2 * four, 0, -0.1)
	p.RightKnee = A(-1.3 * four, 0, 0); p.LeftKnee = A(-1.3 * four, 0, 0)
	return s < T.burst and 1 or 0
end

-- THE VOID KNIGHT: behind the wall while his blade cuts it (hidden: the wall is in front of him); once the slab
-- falls he walks out through the hole, the blade held low, then raises it before his face, his left hand held out
POSES.Knight = function(p, s, t, H)
	local T = EP.T.Knight
	local walk = seg(s, T.step0, T.step1)
	local am = seg(s, T.step0, T.step0 + 0.2) * (1 - seg(s, T.step1 - 0.2, T.step1))
	local ph = (s - T.step0) * 2 * pi * 0.85
	stride(p, ph, am * 0.7)
	local raise = ss(seg(s, T.raise, T.raise + 0.35)) * (1 - seg(s, T.calm, T.calm + 0.45))
	p.Root = CFrame.new(0, math.abs(sin(ph)) * 0.15 * am, 7 * EP.clock.back * (1 - walk)) * A(-0.04 + 0.08 * raise, 0, 0)
	p.Waist = A(0.05 * raise, 0, 0)
	p.Neck = A(-0.1 + 0.14 * raise, 0, 0)
	local low = A(0.35 + sin(ph + pi) * 0.12 * am, 0, 0.12)
	p.RightShoulder = low:Lerp(A(2.2, 0, -0.28), raise)
	p.RightElbow = A(0.35 + 0.8 * raise, 0, 0)
	p.RightWrist = A(-0.25 * raise, 0, 0)
	p.LeftShoulder = A(sin(ph) * 0.15 * am + 1.45 * raise, 0, -0.1 - 0.25 * raise)
	p.LeftElbow = A(0.25 - 0.15 * raise, 0, 0)
	p.LeftWrist = A(-0.6 * raise, 0, 0)
	return s < T.kick and 1 or 0
end

-- THE ANTLERED ONE: upside down on the ceiling, crawling toward you; he lets go, rolls upright as he falls, lands in
-- a crouch, stands up tall and bellows with his arms thrown wide
POSES.Antlered = function(p, s, t, H)
	local T = EP.T.Antlered
	local m = EP.clock.model
	local hv = (m and tonumber(m:GetAttribute("Hover"))) or 7
	local top = math.max(0, math.min(EP.clock.ceil or 16, 26) - 2 * hv) -- (his feet on the ceiling)
	local crawl = ss(seg(s, T.crawl0, T.crawl1))
	local fall = seg(s, T.fall, T.land)
	local landed = s >= T.land
	local flip = ss(seg(s, T.fall, T.land - 0.05))
	local k = landed and (1 - ss(seg(s, T.rise0, T.rise1))) or 0
	local squash = landed and exp(-(s - T.land) / 0.2) or 0
	local roar = seg(s, T.roar, T.roar + 0.25) * (1 - seg(s, T.calm, T.calm + 0.4))
	local y = (s < T.fall and top or top * (1 - fall * fall)) - H * 0.18 * k - H * 0.05 * squash
	local z = 9 * EP.clock.back * (1 - crawl)
	p.Root = CFrame.new(0, y, z) * A(0, 0, pi * (1 - flip)) * A(-0.5 * k + 0.35 * roar, 0, 0)
	if not landed then
		-- on the ceiling: a slow spider crawl, the skull hanging down and turning to look at you
		local am = (1 - flip) * seg(s, T.crawl0, T.crawl0 + 0.2) * (1 - seg(s, T.crawl1 - 0.2, T.crawl1))
		local ph = s * 7
		stride(p, ph, am * 1.2)
		p.RightShoulder = A(0.4 + sin(ph) * 0.7 * am, 0, 0.5); p.LeftShoulder = A(0.4 - sin(ph) * 0.7 * am, 0, -0.5)
		p.RightElbow = A(0.6, 0, 0); p.LeftElbow = A(0.6, 0, 0)
		p.Neck = A(0.7 * (1 - flip), sin(t * 1.7) * 0.5 * (1 - seg(s, T.crawl1, T.fall)), sin(t * 23) * 0.05)
	else
		crouch(p, k)
		p.Waist = A(-0.3 * k + 0.25 * roar, 0, 0)
		p.Neck = A(-0.3 * k + 0.5 * roar + sin(t * 40) * 0.05 * roar, 0, 0)
		p.RightShoulder = A(1.1 * k + 0.2 * roar, 0, 0.1 + 1.35 * roar); p.LeftShoulder = A(1.1 * k + 0.2 * roar, 0, -0.1 - 1.35 * roar)
		p.RightElbow = A(0.3 + 0.9 * roar, 0, 0); p.LeftElbow = A(0.3 + 0.9 * roar, 0, 0)
		p.RightWrist = A(0.4 * roar, 0, 0); p.LeftWrist = A(0.4 * roar, 0, 0)
	end
	return 1 - seg(s, 0, 0.35)
end

-- THE LAKE WITCH: one hand comes up out of the black water, then she rises with her head hanging, turning slowly;
-- her head comes up, she whirls the hook over her head and slams it into the floor in front of her
POSES.LakeWitch = function(p, s, t, H)
	local T = EP.T.LakeWitch
	local rise = ss(seg(s, T.rise0, T.rise1))
	local reach = seg(s, T.hand - 0.2, T.hand + 0.15) * (1 - ss(seg(s, T.rise1 - 0.5, T.rise1 + 0.2)))
	local look = ss(seg(s, T.rise1 - 0.3, T.rise1 + 0.4))
	local whirl = seg(s, T.swing0, T.swing0 + 0.25)
	local slam = ss(seg(s, T.slam - 0.14, T.slam)) * (1 - seg(s, T.calm, T.calm + 0.5))
	local up = H + 1.5
	-- (raised a little while the hand is up, so the hand breaks the surface before the head does)
	p.Root = CFrame.new(0, (-up + 1.2 * reach) * (1 - rise), 0) * A(-0.1 - 0.2 * slam, sin(t * 0.8) * 0.2 * (1 - look), 0)
	p.Waist = A(-0.25 * slam, sin(s * 14) * 0.2 * whirl * (1 - slam), 0)
	p.Neck = A(-0.9 + 0.75 * look + 0.35 * slam + sin(t * 45) * 0.05 * slam, 0, 0.3 * (1 - look))
	-- her left hand reaching up out of the water first
	p.LeftShoulder = A(0.25 + 2.75 * reach, 0, -0.15 - 0.5 * slam); p.LeftElbow = A(0.25 + 0.2 * reach, 0, 0); p.LeftWrist = A(-0.4 * reach, 0, 0)
	-- the hook arm: hanging, whirled overhead (the hand circling), then slammed down in front of her
	local hang = A(0.2, 0, 0.1)
	local circle = A(2.7 + math.cos(s * 14) * 0.25, 0, 0.3 + sin(s * 14) * 0.35)
	p.RightShoulder = hang:Lerp(circle, whirl):Lerp(A(0.85, 0, 0.1), slam)
	p.RightElbow = A(0.3 * (1 - whirl) + 0.1, 0, 0)
	p.RightHip = A(0.1, 0, 0.05); p.LeftHip = A(-0.1 + 0.3 * slam, 0, -0.05); p.LeftKnee = A(-0.4 * slam, 0, 0)
	return 0.45 * (1 - rise)
end

-- THE BURNED COUNSELOR: standing in the dark; his torch catches, he brings it up by his burned face and tilts his
-- head; then the torch goes up high, his other arm out, his head back: the scream (a ring of fire round him)
POSES.Counselor = function(p, s, t, H)
	local T = EP.T.Counselor
	local lift = ss(seg(s, T.raise0, T.raise1)) * (1 - ss(seg(s, T.ring - 0.2, T.ring)))
	local tilt = ss(seg(s, T.raise1, T.look1))
	local ring = ss(seg(s, T.ring - 0.12, T.ring + 0.1)) * (1 - seg(s, T.calm, T.calm + 0.5))
	p.Root = A(-0.05 + 0.3 * ring, 0, 0)
	p.Waist = A(0.2 * ring, 0, 0)
	p.Neck = A(-0.25 * (1 - ring) + 0.55 * ring + sin(t * 48) * 0.05 * ring, 0.25 * tilt * (1 - ring), 0.45 * tilt * (1 - ring) + sin(t * 2) * 0.03)
	local low, face, high = A(0.35, 0, 0.1), A(1.7, 0, -0.45), A(2.9, 0, 0.15)
	p.RightShoulder = low:Lerp(face, lift):Lerp(high, ring)
	p.RightElbow = A(0.3 + 1.1 * lift * (1 - ring), 0, 0)
	p.LeftShoulder = A(0.1 + 0.2 * ring, 0, -0.1 - 1.4 * ring); p.LeftElbow = A(0.2 + 0.3 * ring, 0, 0)
	p.RightHip = A(-0.1 * ring, 0, 0.05 + 0.1 * ring); p.LeftHip = A(0.1 * ring, 0, -0.05 - 0.1 * ring)
	return 0
end

-- THE SCARECROW: hung on his pole, arms out along the crossbar, head slumped; it twitches, then snaps up at you;
-- he drops off the pole into a crouch, stands and raises his sickle
POSES.Scarecrow = function(p, s, t, H)
	local T = EP.T.Scarecrow
	local hang = s < T.drop
	local fall = seg(s, T.drop, T.land)
	local landed = s >= T.land
	local k = landed and (1 - ss(seg(s, T.rise0, T.rise1))) or 0
	local squash = landed and exp(-(s - T.land) / 0.18) or 0
	local raise = ss(seg(s, T.raise, T.raise + 0.25)) * (1 - seg(s, T.calm, T.calm + 0.5))
	local snap = seg(s, T.snap, T.snap + 0.06)
	local tw = pulse(s, T.twitch, 0.05) + pulse(s, T.twitch + 0.35, 0.04) + pulse(s, T.twitch + 0.6, 0.03)
	local y = (hang and 2.4 or 2.4 * (1 - fall * fall)) - H * 0.16 * k - H * 0.05 * squash
	p.Root = CFrame.new(0, y, 0) * A(-0.45 * k, 0, 0)
	if hang then
		p.RightShoulder = A(0, 0, 1.45 + tw * 0.08); p.LeftShoulder = A(0, 0, -1.45)
		p.RightElbow = A(0.1, 0, 0); p.LeftElbow = A(0.1, 0, 0)
		p.RightHip = A(0.05, 0, 0.05); p.LeftHip = A(0.1, 0, -0.05); p.RightKnee = A(-0.15, 0, 0); p.LeftKnee = A(-0.25, 0, 0)
		p.Neck = A(-0.75 * (1 - snap) + 0.1 * snap + tw * 0.3, tw * 0.4, 0.45 * (1 - snap) + 0.3 * snap + sin(t * 37) * 0.04 * snap)
	else
		local off = 1 - fall -- (the arms come off the crossbar as he drops)
		crouch(p, k)
		p.Neck = A(-0.2 * k + 0.1, 0, 0.3 + sin(t * 30) * 0.03 * raise)
		p.RightShoulder = A(0.6 * k + 2.7 * raise, 0, 0.2 + 1.2 * off * (landed and 0 or 1)); p.RightElbow = A(0.3 + 0.4 * raise, 0, 0)
		p.LeftShoulder = A(0.6 * k, 0, -0.3 - 1.1 * off * (landed and 0 or 1) - 0.3 * raise); p.LeftElbow = A(0.2, 0, 0)
	end
	return 0
end

-- POP THE CLOWN: down inside his box; POP: up on the spring, high, down with a bounce; arms flung wide (ta-da)
POSES.Clown = function(p, s, t, H)
	local T = EP.T.Clown
	local up = seg(s, T.pop, T.pop + 0.16)
	local down = seg(s, T.pop + 0.16, T.land)
	local bounce = s > T.land and exp(-(s - T.land) / 0.15) * sin((s - T.land) * 25) * 0.5 or 0
	local y = -H * 0.9 * (1 - up) + 4.5 * up * (1 - down * down) + bounce
	local tada = ss(seg(s, T.tada, T.tada + 0.25)) * (1 - seg(s, T.calm, T.calm + 0.5))
	local fly = up * (1 - down)
	p.Root = CFrame.new(0, y, 0) * A(0.15 * tada, 0, sin(t * 4) * 0.05 * tada)
	p.Neck = A(0.25 * tada + 0.2 * fly, 0, 0.35 * tada + sin(t * 9) * 0.06 * tada)
	p.RightShoulder = A(1.2 * fly + 0.4 * tada, 0, 0.4 + 1.6 * fly + 0.9 * tada); p.LeftShoulder = A(1.2 * fly + 0.4 * tada, 0, -0.4 - 1.6 * fly - 0.9 * tada)
	p.RightElbow = A(0.3, 0, 0); p.LeftElbow = A(0.3, 0, 0)
	p.RightHip = A(0.6 * fly - 0.3 * tada, 0, 0.1); p.LeftHip = A(0.6 * fly + 0.5 * tada, 0, -0.1)
	p.RightKnee = A(-0.9 * fly, 0, 0); p.LeftKnee = A(-0.9 * fly - 0.6 * tada, 0, 0)
	return s < T.pop and 1 or 0
end

-- THE STRONGMAN: crouched gripping the bar; he pulls it to his shoulders, presses it overhead, roars, drops it
POSES.Strongman = function(p, s, t, H)
	local T = EP.T.Strongman
	local crouchK = 1 - ss(seg(s, T.lift0, T.lift1))
	local press = ss(seg(s, T.lift1 + 0.15, T.press))
	local roar = seg(s, T.roar, T.roar + 0.2) * (1 - seg(s, T.drop - 0.1, T.drop))
	local dropK = ss(seg(s, T.drop - 0.1, T.drop + 0.15)) * (1 - seg(s, T.calm, T.calm + 0.5))
	crouch(p, crouchK * 0.9)
	p.Root = CFrame.new(0, -H * 0.15 * crouchK, 0) * A(-0.35 * crouchK + 0.15 * roar, 0, 0)
	p.Waist = A(-0.3 * crouchK + 0.12 * press, 0, 0)
	p.Neck = A(0.2 * crouchK + 0.55 * roar + sin(t * 45) * 0.04 * roar, 0, 0)
	-- arms: down to the bar -> the bar at his shoulders (elbows bent, forward) -> straight up -> swung down
	local grip = A(0.7, 0, 0.15)
	local rack = A(1.4, 0, 0.35)
	local top = A(3.05, 0, 0.3)
	local dropped = A(0.4, 0, 0.5)
	local arm = grip:Lerp(rack, 1 - crouchK):Lerp(top, press):Lerp(dropped, dropK)
	p.RightShoulder = arm
	local rx, ry, rz = arm:ToEulerAnglesXYZ()
	p.LeftShoulder = A(rx, -ry, -rz)
	local el = 0.2 + 1.6 * (1 - crouchK) * (1 - press) + 0.2 * press
	p.RightElbow = A(el, 0, 0); p.LeftElbow = A(el, 0, 0)
	return 0
end

-- MADAME FORTUNE: not there yet, then fading in behind her table, head bowed over the ball, then looking up
POSES.Fortune = function(p, s, t, H)
	local T = EP.T.Fortune
	local appear = ss(seg(s, T.appear0, T.appear1))
	local look = ss(seg(s, T.appear1, T.appear1 + 0.4))
	local fling = ss(seg(s, T.cards - 0.15, T.cards + 0.15)) * (1 - seg(s, T.calm, T.calm + 0.5))
	p.Root = CFrame.new(0, sin(t * 1.6) * 0.25, 0)
	p.Neck = A(-0.55 * (1 - look) + 0.1 * fling, 0, sin(t * 1.1) * 0.08)
	p.Waist = A(-0.2 * (1 - look), 0, 0)
	local over = A(1.25, 0, 0.25) -- hands hovering over the ball
	local wide = A(1.8, 0, 1.2)
	p.RightShoulder = over:Lerp(wide, fling)
	p.LeftShoulder = A(1.25 + 0.55 * fling, 0, -0.25 - 0.95 * fling)
	p.RightElbow = A(0.8 * (1 - fling) + 0.1, 0, 0); p.LeftElbow = A(0.8 * (1 - fling) + 0.1, 0, 0)
	p.RightWrist = A(-0.6 + sin(t * 6) * 0.15, 0, 0); p.LeftWrist = A(-0.6 - sin(t * 6) * 0.15, 0, 0)
	return 1 - appear
end

-- THE RINGMASTER: in the spotlight, head bowed, hands folded; head up, arms wide; the whip arm up for the crack
POSES.Ringmaster = function(p, s, t, H)
	local T = EP.T.Ringmaster
	local up = ss(seg(s, T.raise, T.raise + 0.4))
	local wide = ss(seg(s, T.arms, T.arms + 0.35))
	local crack = pulse(s, T.crack, 0.12)
	local calm = 1 - seg(s, T.calm, T.calm + 0.5)
	p.Root = A(0.05 * wide * calm, 0, 0)
	p.Waist = A(-0.2 * (1 - up) + 0.1 * wide * calm, 0, 0)
	p.Neck = A(-0.65 * (1 - up) + 0.2 * wide * calm, 0, 0)
	local folded = A(0.6, 0, -0.35)
	local out = A(0.35, 0, 1.4)
	local overhead = A(3.0, 0, 0.2)
	p.RightShoulder = folded:Lerp(out, wide * calm):Lerp(overhead, crack)
	p.LeftShoulder = A(0.6 * (1 - wide) + 0.35 * wide, 0, 0.35 * (1 - wide) - 1.4 * wide * calm)
	p.RightElbow = A(1.3 * (1 - wide) + 0.15, 0, 0); p.LeftElbow = A(1.3 * (1 - wide) + 0.15, 0, 0)
	p.RightHip = A(-0.1 * wide, 0, 0.1 * wide); p.LeftHip = A(0.1 * wide, 0, -0.1 * wide)
	return 0
end

-- the pose and the see-through amount (0 = solid, 1 = gone) of monster `id`, s seconds into its entrance
-- (t = the clock, for shakes; H = the monster's height in studs). nil = this monster has no entrance pose.
-- Blackwater Harbor's monsters use a fitting entrance of another monster (Shared/Entrances)
EP.T.DeepOne = EP.T.LakeWitch; POSES.DeepOne = POSES.LakeWitch
EP.T.Keeper = EP.T.Counselor; POSES.Keeper = POSES.Counselor
EP.T.Netman = EP.T.Pirate; POSES.Netman = POSES.Pirate

function EP.pose(id: string, evolved: boolean, s: number, t: number, H: number): (Pose?, number)
	local f = POSES[id]
	if not f then return nil, 0 end
	local p: Pose = {}
	local alpha = f(p, s, t, H, evolved)
	return p, alpha
end

return EP
