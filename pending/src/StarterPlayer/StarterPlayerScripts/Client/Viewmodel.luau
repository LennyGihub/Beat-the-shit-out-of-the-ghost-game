-- First-person hands: guard pose, alternating jabs, hooks on high combos, carry pose, the ultimates' cast
-- animations (CASTS: one keyframed two-hand animation per kind of ultimate) and the glow and aura on the fists,
-- and the held item with a keyframed animation per weapon style (wind-up -> strike -> follow-through),
-- hit-stop on impact, swing trails, two-handed grips, pump/recoil for guns, drink/inject for consumables.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ItemModels = require(RS.Shared.ItemModels)
local RunService = game:GetService("RunService")
local Kit = require(script.Parent.UltKit) -- the effects' clock (a Studio test can freeze it to photograph a cast)

local VM = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local model: Model
local arms = {} :: { [string]: { fist: BasePart, arm: BasePart, sleeve: BasePart, brass: BasePart } }
local punches = {} :: { { side: string, t0: number, kind: string, dur: number, power: number? } }
local nextSide = "R"
local lastCamCF = cam.CFrame
local sway = Vector2.zero
local bobT = 0
local carryAlpha = 0
local shakeOff = CFrame.new()
local skinColor = Color3.fromRGB(120, 88, 70)
local held: Model? = nil
local heldItem: any = nil
local heldLen = 2
local holdCF = CFrame.new() -- camera-space right-fist pose for the held item (from HOLD)
local leftGripPart: BasePart? = nil -- where the left hand holds the item
local tipPart: BasePart? = nil
local lastUse = -1
local style = "bat"
local anim: { t0: number, dur: number, variant: number, hidden: boolean? }? = nil
local variant = 1
local freezeUntil = 0
local frozenAt = 0
local spraying = false
local trail: Trail? = nil
local A = CFrame.Angles
local function C(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end
local STUDIO = RunService:IsStudio()
-- HOLD POSES (camera space: +X right, +Y up, -Z forward) ----------------------------------------------
-- A spec aims the item: the right fist sits at `fist`, the item's tip lands on screen point `aim`
-- (-1..1 across / up the screen, solved from the item's real length) and `roll` turns it round its own axis.
-- A CFrame is used as-is (short items held in the fist, and the hand-tuned chainsaw).
type Hold = { fist: Vector3, aim: Vector2, roll: number }
local HOLD: { [string]: any } = {
	bat = { fist = Vector3.new(0.9, -1.05, -1.8), aim = Vector2.new(-0.05, 0.7), roll = -0.4 },
	golf = { fist = Vector3.new(0.85, -1.05, -1.8), aim = Vector2.new(0.0, 0.5), roll = 0 },
	slash = { fist = Vector3.new(0.85, -1.0, -1.75), aim = Vector2.new(-0.05, 0.75), roll = 1.3 },
	heavy = { fist = Vector3.new(0.75, -1.15, -1.35), aim = Vector2.new(-0.4, 0.72), roll = 1.5 },
	thrust = { fist = Vector3.new(0.65, -1.0, -1.8), aim = Vector2.new(0.05, 0.4), roll = 0 },
	saw = C(0.9, -1.2, -1.6, 0.7, 0.45, 1.3), -- on its side, top handle to the left, bar up toward the crosshair
	pistol = { fist = Vector3.new(0.7, -0.8, -1.45), aim = Vector2.new(0.1, -0.02), roll = 0 },
	glock = C(0.68, -0.7, -1.7, 0.04, 0.36, 0), -- two hands, level, low right, turned in so you see the side of the slide
	shotgun = { fist = Vector3.new(0.72, -0.75, -1.05), aim = Vector2.new(0.14, -0.1), roll = 0 },
	longgun = { fist = Vector3.new(0.72, -0.78, -1.05), aim = Vector2.new(0.14, -0.1), roll = 0 },
	spray = { fist = Vector3.new(0.78, -0.82, -1.5), aim = Vector2.new(-0.12, -0.02), roll = 0 },
	throw = C(0.58, -0.66, -1.45, 0.15, -0.35, 0),
	drink = C(0.55, -0.68, -1.45, 0.1, -0.3, 0),
	inject = C(0.6, -0.7, -1.45, 0.15, 0.35, 0),
	apply = C(0.5, -0.66, -1.55, 0.1, -0.3, 0),
	raise = C(0.52, -0.62, -1.5, 0.15, -0.2, 0),
	place = C(0.55, -0.75, -1.6, 0.2, -0.2, 0),
}
-- per-item overrides of the style's hold and size
local HOLD_ID: { [string]: any } = {
	PepperSpray = C(0.6, -0.62, -1.35, 0.1, 0.25, 0), -- small canister upright in the fist
	Medkit = C(0.5, -0.5, -1.55, 1.15, -0.35, 0), -- tilted so the box faces forward
	FireExtinguisher = { fist = Vector3.new(0.75, -0.95, -1.35), aim = Vector2.new(-0.05, -0.08), roll = 0 },
	UVFlashlight = { fist = Vector3.new(0.72, -0.72, -1.45), aim = Vector2.new(-0.1, 0.02), roll = 0 },
}
local SCALE_ID: { [string]: number } = { PotatoCannon = 0.62, PepperSpray = 0.85, UVFlashlight = 1.0 }
-- left fist on an item's LeftGrip (camera space): the forearm comes in from the lower left
local LEFT_ROT: { [string]: CFrame } = {
	saw = A(0.4, -0.9, -0.6),
	bat = A(0.3, -0.5, -0.3),
	heavy = A(0.5, -0.7, -0.3),
	shotgun = A(1.15, -0.45, -0.2),
	longgun = A(1.15, -0.45, -0.2),
	spray = A(1.1, -0.5, -0.2),
	pistol = A(1.1, -0.5, -0.2),
	glock = A(0.1, -0.25, -0.35), -- cupped under the shooting hand
}
-- first-person size of the held item per style (guns and sprays bigger so the fists don't swallow them)
local SCALE: { [string]: number } = { pistol = 0.8, glock = 1.3, shotgun = 0.85, longgun = 0.85, throw = 0.75, drink = 0.75,
	inject = 0.8, apply = 0.7, raise = 0.75, place = 0.65, heavy = 0.6, spray = 0.95 }
-- the left fist sits under a gun's forend, not on top of it (camera space)
local LEFT_DROP: { [string]: Vector3 } = { shotgun = Vector3.new(0, -0.14, 0), longgun = Vector3.new(0, -0.14, 0), spray = Vector3.new(0, -0.1, 0) }
local LEFT_GRIP_ROT = A(0.4, -0.6, -0.3)

-- weapon styles ------------------------------------------------------------------------------------
local STYLE = {
	FireAxe = "heavy", Sledgehammer = "heavy", StormHammer = "heavy", Shovel = "heavy", FrostPickaxe = "heavy",
	BaseballBat = "bat", SpikedBat = "bat", BurningBat = "bat", LeadPipe = "bat", Crowbar = "bat", FryingPan = "bat", GolfClub = "golf",
	Katana = "slash", DemonBlade = "slash", Machete = "slash", HolyCross = "thrust", Chainsaw = "saw",
	NailGun = "pistol", Taser = "pistol", Glock18 = "glock", FlareGun = "pistol", SilverRevolver = "pistol",
	SaltShotgun = "shotgun", PotatoCannon = "longgun", StakeCrossbow = "longgun", HarpoonGun = "longgun",
	EnergyDrink = "drink", Painkillers = "drink", Adrenaline = "inject", RageSerum = "inject",
	Medkit = "apply", KevlarVest = "apply", Talisman = "raise", PocketWatch = "raise", BearTrap = "place",
}
local DUR = { heavy = 0.78, bat = 0.42, golf = 0.5, slash = 0.3, thrust = 0.34, saw = 0.12, pistol = 0.22, glock = 0.1, shotgun = 0.62,
	longgun = 0.45, throw = 0.48, drink = 0.9, inject = 0.8, apply = 0.8, raise = 0.9, place = 0.6, spray = 0.1 }

-- keyframes {t, offset}: translation and rotation in CAMERA space, turning around the right fist
-- (the chainsaw's keys are in the fist's own frame, LOCAL_KEYS). The left hand follows the item's LeftGrip.
local KEYS = {
	heavy = { { 0, C(0, 0, 0) }, { 0.36, C(0.15, 0.35, 0.1, 0.7, -0.15, 0) }, { 0.5, C(-0.1, -0.35, -0.6, -1.2, 0.1, 0) },
		{ 0.72, C(-0.1, -0.4, -0.55, -1.15, 0.1, 0) }, { 1, C(0, 0, 0) } },
	bat = { { 0, C(0, 0, 0) }, { 0.28, C(0.3, 0.2, 0.35, 0.25, -0.85, -0.35) }, { 0.5, C(-0.6, -0.12, -0.5, -0.45, 1.05, 0.55) },
		{ 0.72, C(-0.8, -0.32, -0.3, -0.75, 1.45, 0.75) }, { 1, C(0, 0, 0) } },
	golf = { { 0, C(0, 0, 0) }, { 0.32, C(0.35, -0.15, 0.25, -0.35, -0.85, 0) }, { 0.52, C(-0.3, 0.0, -0.6, 0.3, 0.8, 0) },
		{ 0.75, C(-0.6, 0.45, -0.35, 1.0, 1.2, 0) }, { 1, C(0, 0, 0) } },
	slash = { { 0, C(0, 0, 0) }, { 0.2, C(0.3, 0.4, 0.25, 0.45, -0.5, -0.55) }, { 0.55, C(-0.65, -0.45, -0.6, -0.75, 0.9, 0.9) },
		{ 1, C(0, 0, 0) } },
	thrust = { { 0, C(0, 0, 0) }, { 0.3, C(0, -0.05, 0.35, 0.1, 0, 0) }, { 0.5, C(-0.2, 0.1, -0.95, -0.05, 0.1, 0) }, { 1, C(0, 0, 0) } },
	saw = { { 0, C(0, -0.1, -0.5) }, { 0.5, C(0, -0.02, -0.78, -0.1, 0, 0) }, { 1, C(0, -0.1, -0.5) } },
	pistol = { { 0, C(0, 0, 0) }, { 0.14, C(0, 0.06, 0.22, 0.38, 0, 0.05) }, { 1, C(0, 0, 0) } },
	glock = { { 0, C(0, 0, 0) }, { 0.25, C(0, 0.03, 0.1, 0.16, 0, 0) }, { 1, C(0, 0, 0) } }, -- short full-auto kick
	shotgun = { { 0, C(0, 0, 0) }, { 0.1, C(0, 0.1, 0.38, 0.42, 0, 0) }, { 0.35, C(0, 0.02, 0.1, 0.08, 0, 0) }, { 1, C(0, 0, 0) } },
	longgun = { { 0, C(0, 0, 0) }, { 0.12, C(0, 0.12, 0.4, 0.45, 0, 0) }, { 1, C(0, 0, 0) } },
	throw = { { 0, C(0, 0, 0) }, { 0.38, C(0.25, 0.4, 0.15, 0.9, 0, 0) }, { 0.55, C(-0.2, 0.3, -0.9, -0.5, 0, 0) },
		{ 0.75, C(-0.25, -0.3, -0.6, -0.8, 0, 0) }, { 1, C(0, 0, 0) } },
	drink = { { 0, C(0, 0, 0) }, { 0.3, C(-0.35, 0.5, 0.25, 1.0, 0, 0.2) }, { 0.75, C(-0.35, 0.55, 0.3, 1.35, 0, 0.2) }, { 1, C(0, 0, 0) } },
	inject = { { 0, C(0, 0, 0) }, { 0.35, C(-0.45, -0.05, 0.15, 0, 0.6, 0) }, { 0.5, C(-0.62, -0.2, 0.3, 0, 0.8, 0) },
		{ 0.7, C(-0.62, -0.2, 0.3, 0, 0.8, 0) }, { 1, C(0, 0, 0) } },
	apply = { { 0, C(0, 0, 0) }, { 0.35, C(-0.3, -0.2, 0.4, -0.3, 0, 0) }, { 0.7, C(-0.3, -0.45, 0.6, -0.6, 0, 0) }, { 1, C(0, 0, 0) } },
	raise = { { 0, C(0, 0, 0) }, { 0.3, C(-0.35, 0.6, -0.3, 0.3, 0, 0) }, { 0.8, C(-0.35, 0.65, -0.35, 0.3, 0, 0) }, { 1, C(0, 0, 0) } },
	place = { { 0, C(0, 0, 0) }, { 0.45, C(-0.1, -0.85, -0.5, -0.6, 0, 0) }, { 1, C(0, 0, 0) } },
	spray = { { 0, C(0, 0, 0) }, { 1, C(0, 0, 0) } },
}
local LOCAL_KEYS = { saw = true }
-- where the arms come from while holding an item (camera space, below and behind the screen corners)
local SHOULDER = { R = Vector3.new(1.0, -1.7, 0.35), L = Vector3.new(-1.0, -1.7, 0.35) }
-- items held in the fist sit in front of it, not inside it (fist frame)
local OUT = CFrame.new(0, 0.1, -0.3)
local ITEM_OFF: { [string]: CFrame } = { throw = OUT, drink = OUT, inject = CFrame.new(0, 0.05, -0.2), apply = OUT, raise = OUT, place = OUT }

local function ease(a: number): number return a * a * (3 - 2 * a) end

local function sample(keys, a: number): CFrame
	for i = 1, #keys - 1 do
		local k0, k1 = keys[i], keys[i + 1]
		if a <= k1[1] then
			local f = (a - k0[1]) / math.max(1e-3, k1[1] - k0[1])
			return k0[2]:Lerp(k1[2], ease(math.clamp(f, 0, 1)))
		end
	end
	return keys[#keys][2]
end

local function mirror(cf: CFrame): CFrame
	local x, y, z = cf.Position.X, cf.Position.Y, cf.Position.Z
	local rx, ry, rz = cf:ToEulerAnglesXYZ()
	return CFrame.new(-x * 0.6, y, z) * A(rx, -ry, -rz)
end

-- ULTIMATE CASTS ---------------------------------------------------------------------------------------------
-- One two-hand animation per kind of ultimate (UltFx picks it). Keys are { t, where, ease, roll } with t = 0..1 of
-- the animation; `where` = the fist in camera space (+X right, +Y up, -Z forward) and `false` = the normal guard
-- pose. The forearm always hangs from the fist toward a point under the screen (see castPose), so a raised fist
-- never becomes a pillar in front of the camera. No L list = the left hand mirrors the right. The hit lands
-- at Ultimates.castTime (0.4 s): the server's effects go off on that beat. tremble = { from, to, size }.
local G = false
local V = Vector3.new
local JAB, BACK = V(0.2, -0.15, -2.4), V(0.5, -0.55, -1.1)
local JABL, BACKL = V(-0.2, -0.15, -2.4), V(-0.5, -0.55, -1.1)
local HIGH = V(0.62, -0.4, -1.5) -- guard held a little higher, fists clenched
type Cast = { dur: number, R: { { any } }, L: { { any } }?, tremble: { number }? }
local CASTS: { [string]: Cast } = {
	-- both fists over the head, then down into the floor
	slam = { dur = 1, R = { { 0, G }, { 0.26, V(1.05, 0.9, -1.75), "out" }, { 0.34, V(1.0, 1.0, -1.7) }, { 0.42, V(0.4, -0.9, -1.8), "in" },
		{ 0.62, V(0.4, -0.85, -1.75) }, { 1, G } }, tremble = { 0.24, 0.36, 0.02 } },
	-- both arms wound up on the right, swept flat across the room
	sweep = { dur = 1, R = { { 0, G }, { 0.28, V(1.6, -0.3, -1.2), "out" }, { 0.44, V(-0.6, -0.3, -1.9), "in" }, { 0.62, V(-1.0, -0.4, -1.5) }, { 1, G } },
		L = { { 0, G }, { 0.28, V(0.5, -0.55, -1.4), "out" }, { 0.44, V(-1.4, -0.4, -1.4), "in" }, { 0.62, V(-1.6, -0.5, -1.1) }, { 1, G } } },
	-- the right fist drops out of sight and comes up through the roof
	uppercut = { dur = 1, R = { { 0, G }, { 0.26, V(0.8, -1.3, -1.1), "out" }, { 0.42, V(0.3, 0.8, -1.8), "in" }, { 0.6, V(0.25, 0.95, -1.7) }, { 1, G } },
		L = { { 0, G }, { 0.26, V(-0.5, -0.45, -1.3) }, { 0.6, V(-0.5, -0.45, -1.3) }, { 1, G } } },
	-- hands under the edge, and heave
	flip = { dur = 1, R = { { 0, G }, { 0.26, V(0.7, -1.2, -1.5), "out" }, { 0.42, V(0.75, 0.7, -1.6), "in" }, { 0.6, V(0.85, 0.9, -1.4) }, { 1, G } } },
	-- hands rise, shaking, holding the room; then throw it forward
	tele = { dur = 1.1, R = { { 0, G }, { 0.27, V(1.0, 0.2, -1.5), "out" }, { 0.36, V(0.8, 0.35, -1.4) }, { 0.44, V(0.5, 0.05, -2.2), "in" },
		{ 0.62, V(0.5, 0.05, -2.15) }, { 1, G } }, tremble = { 0.1, 0.36, 0.03 } },
	-- one fist punched at the sky, then dragged down
	sky = { dur = 1, R = { { 0, G }, { 0.22, V(0.5, 0.9, -1.5), "out" }, { 0.38, V(0.5, 1.0, -1.45) }, { 0.46, V(0.45, -0.75, -1.8), "in" },
		{ 0.64, V(0.45, -0.7, -1.75) }, { 1, G } },
		L = { { 0, G }, { 0.22, V(-0.6, -0.5, -1.35) }, { 0.64, V(-0.6, -0.5, -1.35) }, { 1, G } }, tremble = { 0.22, 0.38, 0.03 } },
	-- arms wide, then a clap
	clap = { dur = 1, R = { { 0, G }, { 0.28, V(1.7, -0.1, -1.4), "out" }, { 0.4, V(0.22, -0.15, -1.7), "in" }, { 0.56, V(0.26, -0.15, -1.65) }, { 1, G } } },
	-- hands together, then the air is torn open
	pull = { dur = 1.1, R = { { 0, G }, { 0.22, V(0.18, -0.2, -1.6), "out" }, { 0.34, V(0.18, -0.2, -1.6) }, { 0.42, V(1.55, -0.05, -1.4), "in" },
		{ 0.68, V(1.65, 0, -1.35) }, { 1, G } }, tremble = { 0.2, 0.7, 0.03 } },
	-- fists crossed on the chest, then flung wide
	flex = { dur = 1.1, R = { { 0, G }, { 0.22, V(-0.25, -0.2, -1.3), "out" }, { 0.33, V(-0.25, -0.2, -1.3) }, { 0.4, V(1.4, 0.15, -1.4), "in" },
		{ 0.72, V(1.45, 0.2, -1.4) }, { 1, G } }, tremble = { 0.2, 0.74, 0.035 } },
	-- both fists drawn to the chest and driven straight out
	push = { dur = 1, R = { { 0, G }, { 0.26, V(0.5, -0.6, -1.0), "out" }, { 0.42, V(0.38, -0.1, -2.3), "in" }, { 0.62, V(0.38, -0.1, -2.25) }, { 1, G } } },
	-- drink it, toss the can, shake
	chug = { dur = 1.3, R = { { 0, G }, { 0.18, V(0.25, -0.1, -0.85), "out" }, { 0.36, V(0.2, 0.02, -0.8), nil, 0.6 }, { 0.46, V(1.0, -0.5, -1.5), "in" },
		{ 0.62, HIGH }, { 0.85, HIGH }, { 1, G } },
		L = { { 0, G }, { 0.46, G }, { 0.62, V(-0.62, -0.4, -1.5) }, { 0.85, V(-0.62, -0.4, -1.5) }, { 1, G } }, tremble = { 0.5, 0.88, 0.04 } },
	-- hands together, then opened to the sky
	pray = { dur = 1.1, R = { { 0, G }, { 0.24, V(0.15, -0.25, -1.4), "out" }, { 0.36, V(0.15, -0.05, -1.4) }, { 0.46, V(1.1, 0.55, -1.5), "out" },
		{ 0.75, V(1.15, 0.6, -1.5) }, { 1, G } } },
	-- the right fist drawn far back, the left hand taking aim
	windup = { dur = 1.4, R = { { 0, G }, { 0.25, V(1.15, -0.55, -0.75), "out" }, { 0.7, V(1.17, -0.55, -0.7) }, { 1, G } },
		L = { { 0, G }, { 0.25, V(-0.25, -0.3, -2.0), "out" }, { 0.7, V(-0.25, -0.3, -2.0) }, { 1, G } }, tremble = { 0.2, 0.72, 0.045 } },
	-- knuckles knocked together
	bump = { dur = 0.95, R = { { 0, G }, { 0.24, V(1.05, -0.35, -1.5), "out" }, { 0.4, V(0.24, -0.3, -1.6), "in" }, { 0.48, V(0.44, -0.3, -1.6), "out" },
		{ 0.66, HIGH }, { 1, G } }, tremble = { 0.48, 0.8, 0.03 } },
	-- a hand held up, and a snap
	snap = { dur = 1, R = { { 0, G }, { 0.3, V(0.4, 0.4, -1.5), "out" }, { 0.36, V(0.4, 0.43, -1.5) }, { 0.41, V(0.4, 0.45, -1.5), "in", -1.3 },
		{ 0.7, V(0.4, 0.45, -1.5), nil, -1.3 }, { 1, G } },
		L = { { 0, G }, { 0.3, V(-0.7, -0.8, -1.4) }, { 0.7, V(-0.7, -0.8, -1.4) }, { 1, G } } },
	-- two crossing claw slashes
	claw = { dur = 1, R = { { 0, G }, { 0.24, V(1.2, 0.6, -1.3), "out" }, { 0.4, V(-0.45, -0.65, -1.8), "in" }, { 0.5, V(-0.5, -0.7, -1.75) }, { 0.72, G }, { 1, G } },
		L = { { 0, G }, { 0.36, V(-1.2, 0.6, -1.3), "out" }, { 0.52, V(0.45, -0.65, -1.8), "in" }, { 0.64, V(0.5, -0.7, -1.75) }, { 1, G } } },
	-- arms open on a deep breath, then the fists close
	breath = { dur = 1.1, R = { { 0, G }, { 0.36, V(1.45, 0.3, -1.3), "out" }, { 0.5, V(1.5, 0.4, -1.3) }, { 0.64, HIGH, "in" }, { 0.8, HIGH }, { 1, G } } },
	-- six jabs faster than the eye
	flurry = { dur = 1, R = { { 0, G }, { 0.3, BACK, "out" }, { 0.36, BACK }, { 0.4, JAB, "in" }, { 0.47, BACK }, { 0.53, BACK }, { 0.57, JAB, "in" },
		{ 0.64, BACK }, { 0.7, BACK }, { 0.74, JAB, "in" }, { 0.82, BACK }, { 1, G } },
		L = { { 0, G }, { 0.3, BACKL, "out" }, { 0.445, BACKL }, { 0.485, JABL, "in" }, { 0.555, BACKL }, { 0.615, BACKL }, { 0.655, JABL, "in" },
			{ 0.725, BACKL }, { 0.785, BACKL }, { 0.825, JABL, "in" }, { 0.9, BACKL }, { 1, G } } },
	-- a hand to the ear, the other raised, then pointed at the target
	point = { dur = 1.2, R = { { 0, G }, { 0.2, V(0.45, 0.85, -1.5), "out" }, { 0.3, V(0.45, 0.9, -1.5) }, { 0.38, V(0.3, -0.2, -2.3), "in" },
		{ 0.75, V(0.3, -0.2, -2.25) }, { 1, G } },
		L = { { 0, G }, { 0.2, V(-0.55, -0.3, -1.0), "out" }, { 0.75, V(-0.55, -0.3, -1.0) }, { 1, G } } },
	-- crouch, then the arms burst up and out as you grow
	stomp = { dur = 1.1, R = { { 0, G }, { 0.27, V(0.85, -1.0, -1.3), "out" }, { 0.4, V(1.35, 0.6, -1.4), "in" }, { 0.72, V(1.4, 0.65, -1.4) }, { 1, G } },
		tremble = { 0.4, 0.74, 0.035 } },
}
local cast: { name: string, t0: number }? = nil
local ultColor = Color3.fromRGB(255, 70, 30)
local auraKind = "rise"
local auras = {} :: { [string]: { BasePart } }
local arcT = 0

-- the fist's pose (camera space) at fraction a of the running cast
local function castPose(side: string, a: number, guard: CFrame): CFrame
	local c = CASTS[(cast :: any).name]
	local keys = (side == "L" and c.L) or c.R
	local sx = (side == "L" and c.L == nil) and -1 or 1 -- mirrored
	local pos, roll = guard.Position, 0
	local function at(k: { any }): (Vector3, number)
		local v = k[2]
		if not v then return guard.Position, 0 end
		return Vector3.new(v.X * sx, v.Y, v.Z), (k[4] or 0) * sx
	end
	for i = 1, #keys - 1 do
		local k0, k1 = keys[i], keys[i + 1]
		if a <= k1[1] then
			local f = math.clamp((a - k0[1]) / math.max(1e-3, k1[1] - k0[1]), 0, 1)
			local e = k1[3]
			f = e == "in" and f * f * f or (e == "out" and 1 - (1 - f) ^ 3 or ease(f))
			local p0, r0 = at(k0)
			local p1, r1 = at(k1)
			pos, roll = p0:Lerp(p1, f), r0 + (r1 - r0) * f
			break
		end
	end
	local tr = c.tremble
	if tr and a > tr[1] and a < tr[2] then
		pos += Vector3.new((math.random() - 0.5) * tr[3], (math.random() - 0.5) * tr[3], 0)
	end
	-- the fist points away from the shoulder; blend out of / back into the guard's own angle at both ends
	local w = ease(math.clamp(math.min(a / keys[2][1], (1 - a) / (1 - keys[#keys - 1][1])), 0, 1))
	-- the forearm hangs from the fist toward a point under the screen, at about the fist's own depth: it never
	-- comes at the camera, so it stays a limb and not a wall
	local away = pos - Vector3.new(side == "R" and 1.5 or -1.5, -2.6, -0.9)
	local rot = guard.Rotation:Lerp(CFrame.lookAt(Vector3.zero, away, Vector3.new(0, 0, -1)).Rotation, w)
	return CFrame.new(pos) * rot * A(0, 0, roll)
end

-- play an ultimate's cast: hands = a CASTS name, color = the ultimate's colour (the fists glow in it while it is
-- active), aura = rise | fall | orbit | arc (what hangs round the fists)
function VM.cast(hands: string, color: Color3, aura: string?)
	cast = { name = CASTS[hands] and hands or "slam", t0 = Kit.now() }
	ultColor = color
	auraKind = aura or "rise"
end
-- seconds the named cast takes
function VM.castTime(hands: string): number return (CASTS[hands] or CASTS.slam).dur end

-- the aura round a glowing fist: small blocks that rise like embers, drip, circle it or crackle
local function auraStep(side: string, fistCF: CFrame, base: CFrame, on: boolean, now: number, jump: boolean)
	for i, p in auras[side] do
		p.LocalTransparencyModifier = on and 0 or 1
		if not on then continue end
		local sd = i * 1.7 + (side == "R" and 0 or 0.9)
		if auraKind == "rise" then
			local ph = (now * 1.5 + i / 6) % 1
			p.Size = Vector3.one * 0.17 * (1.15 - ph)
			p.CFrame = CFrame.new(fistCF.Position + base:VectorToWorldSpace(Vector3.new(math.sin(sd) * 0.24, 0.12 + ph * 0.8, math.cos(sd) * 0.25 - 0.1))) * A(now * 3 + i, now * 2, 0)
			p.Color = Kit.dim(ultColor:Lerp(Color3.new(1, 1, 1), (1 - ph) * 0.4), 0.45)
		elseif auraKind == "fall" then
			local ph = (now * 1.1 + i / 6) % 1
			p.Size = Vector3.new(0.07, 0.17, 0.07)
			p.CFrame = CFrame.new(fistCF.Position + base:VectorToWorldSpace(Vector3.new(math.sin(sd) * 0.22, -0.18 - ph * ph * 0.9, math.cos(sd) * 0.22 - 0.1)))
			p.Color = Kit.dim(ultColor:Lerp(Color3.new(1, 1, 1), 0.25), 0.45)
		elseif auraKind == "orbit" then
			local ang = now * 5 + i / 6 * math.pi * 2
			p.Size = Vector3.new(0.1, 0.1, 0.16)
			p.CFrame = fistCF * CFrame.new(math.cos(ang) * 0.42, math.sin(ang) * 0.42, -0.05 + math.sin(now * 3 + i) * 0.12) * A(0, 0, ang)
			p.Color = Kit.dim(i % 2 == 0 and ultColor or ultColor:Lerp(Color3.new(1, 1, 1), 0.5), 0.45)
		elseif jump then
			p.Size = Vector3.new(0.035, 0.035, 0.25 + math.random() * 0.45)
			p.CFrame = fistCF * CFrame.new((math.random() - 0.5) * 0.6, (math.random() - 0.5) * 0.6, (math.random() - 0.5) * 0.7 - 0.1) * A(math.random() * 6, math.random() * 6, 0)
			p.Color = Kit.dim(math.random() < 0.4 and Color3.new(1, 1, 1) or ultColor, 0.55)
			p.Transparency = math.random() < 0.6 and 0 or 1
		end
	end
end

local function mk(name: string, size: Vector3, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Parent = model
	return p
end

function VM.init()
	model = Instance.new("Model")
	model.Name = "Viewmodel"
	model.Parent = cam
	local skin = Color3.fromRGB(120, 88, 70)
	for _, side in { "L", "R" } do
		arms[side] = {
			fist = mk(side .. "Fist", Vector3.new(0.44, 0.42, 0.5), skin),
			arm = mk(side .. "Arm", Vector3.new(0.34, 0.34, 1.7), skin),
			sleeve = mk(side .. "Sleeve", Vector3.new(0.46, 0.46, 1.2), Color3.fromRGB(46, 42, 40), Enum.Material.Fabric),
			brass = mk(side .. "Brass", Vector3.new(0.48, 0.12, 0.16), Color3.fromRGB(200, 160, 70), Enum.Material.Metal),
		}
		auras[side] = {}
		for i = 1, 6 do
			local p = mk(side .. "Aura", Vector3.one * 0.12, ultColor, Enum.Material.Neon)
			p.LocalTransparencyModifier = 1
			auras[side][i] = p
		end
	end
	local function useSkin(ch: Model)
		local bc = ch:WaitForChild("Body Colors", 5) :: BodyColors?
		local hand = ch:WaitForChild("RightHand", 5) :: BasePart?
		local c = (bc and bc.RightArmColor3) or (hand and hand.Color) or skin
		skinColor = c:Lerp(Color3.new(0, 0, 0), 0.35) -- darker so it does not blow out under the lamps
		for _, a in arms do a.arm.Color = skinColor end
	end
	if lp.Character then task.spawn(useSkin, lp.Character) end
	lp.CharacterAdded:Connect(function(ch) task.spawn(useSkin, ch) end)
	RunService:BindToRenderStep("Viewmodel", Enum.RenderPriority.Camera.Value + 2, VM.update)
end

function VM.punch(combo: number)
	local side = nextSide
	nextSide = side == "R" and "L" or "R"
	local kind = (combo >= 5 and combo % 3 == 0) and "hook" or ((combo >= 8 and combo % 4 == 0) and "upper" or "jab")
	table.insert(punches, { side = side, t0 = os.clock(), kind = kind, dur = kind == "jab" and 0.22 or 0.3 })
end

function VM.slam()
	table.insert(punches, { side = "R", t0 = os.clock(), kind = "slam", dur = 0.45 })
	table.insert(punches, { side = "L", t0 = os.clock(), kind = "slam", dur = 0.45 })
end

function VM.setShake(cf: CFrame) shakeOff = cf end

-- blocking (player attribute Blocking, set by the server): fists come up in front of the face, a held weapon is
-- raised across the body
local blockAlpha = 0

-- charging a hit (Charge.luau): the arms and the held weapon draw back (and a little up, so they stay in view),
-- trembling as the charge fills
local chargeOff = CFrame.new()
function VM.setCharge(c: number)
	if c <= 0.001 then chargeOff = CFrame.new(); return end
	local t = c > 0.6 and (c - 0.6) * 0.06 or 0
	chargeOff = CFrame.new(0.06 * c + (math.random() - 0.5) * t, 0.16 * c + (math.random() - 0.5) * t, 0.3 * c)
		* CFrame.Angles(0.1 * c, 0.12 * c, 0)
end

-- swing trail between the grip and the far end of the held item
local function addTrail(m: Model)
	local _, size = m:GetBoundingBox()
	local root = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
	if not root then return end
	local pivot = m:GetPivot()
	local a0 = Instance.new("Attachment"); a0.Parent = root
	local a1 = Instance.new("Attachment"); a1.Parent = root
	a0.WorldPosition = (pivot * CFrame.new(0, 0, -size.Z * 0.45)).Position
	a1.WorldPosition = (pivot * CFrame.new(0, 0, -size.Z * 0.95)).Position
	local tr = Instance.new("Trail")
	tr.Attachment0 = a0; tr.Attachment1 = a1
	tr.Lifetime = 0.14; tr.MinLength = 0.05; tr.FaceCamera = true; tr.LightEmission = 0.4
	tr.Transparency = NumberSequence.new(0.35, 1)
	tr.Color = ColorSequence.new(heldItem and heldItem.glow or Color3.fromRGB(235, 230, 220))
	tr.Enabled = false
	tr.Parent = root
	trail = tr
end

-- resolve a hold spec into a camera-space right-fist CFrame (see HOLD)
local function solveHold(spec: any, len: number): CFrame
	if typeof(spec) == "CFrame" then return spec end
	local vp = cam.ViewportSize
	local tanV = math.tan(math.rad(cam.FieldOfView) / 2)
	local aspect = vp.X / math.max(1, vp.Y)
	local dir = Vector3.new(spec.aim.X * tanV * aspect, spec.aim.Y * tanV, -1).Unit
	local F = spec.fist
	-- point the item from the fist toward the aim ray, at a depth a bit beyond the item's reach
	local depth = math.max(-F.Z + len * 0.7, 2.0)
	return CFrame.lookAt(F, dir * (depth / -dir.Z), Vector3.yAxis) * A(0, 0, spec.roll or 0)
end

-- show an item in the right hand (nil = bare fists)
function VM.setItem(it: any)
	if it == heldItem then return end
	heldItem = it
	anim = nil
	trail = nil
	leftGripPart = nil
	tipPart = nil
	if held then held:Destroy(); held = nil end
	if not it then return end
	style = STYLE[it.id] or (it.kind == "throw" and "throw" or (it.kind == "spray" and "spray" or (it.kind == "gun" and "pistol" or "bat")))
	local m = ItemModels.build(it.shape, it.color, it.glow, it.id)
	m:ScaleTo(SCALE_ID[it.id] or SCALE[style] or 0.55) -- first-person hands are close to the camera
	m.Parent = model
	held = m
	leftGripPart = m:FindFirstChild("LeftGrip", true) :: BasePart?
	tipPart = m:FindFirstChild("Tip", true) :: BasePart?
	local _, size = m:GetBoundingBox()
	heldLen = math.max(size.X, size.Y, size.Z)
	-- item length along its forward axis (pivot -> tip), for aiming the hold
	local fwd = tipPart and -m:GetPivot():PointToObjectSpace(tipPart.Position).Z or size.Z * 0.8
	holdCF = solveHold(HOLD_ID[it.id] or HOLD[style] or HOLD.bat, math.max(0.3, fwd))
	lastUse = -1
	if it.kind == "melee" then addTrail(m) end
end

-- world position of the held item's far end (spray nozzle, muzzle)
function VM.itemTip(): Vector3?
	if not held then return nil end
	if tipPart then return tipPart.Position end
	return (held:GetPivot() * CFrame.new(0, 0, -heldLen * 0.95)).Position
end

-- play the held item's animation (called on use)
function VM.use()
	if not heldItem then return end
	variant = -variant
	freezeUntil, frozenAt = 0, 0
	lastUse = os.clock()
	anim = { t0 = os.clock(), dur = DUR[style] or 0.4, variant = variant }
end
-- seconds from VM.use() to the moment the swing connects on screen (melee hit sounds play then)
function VM.impactTime(): number
	return (DUR[style] or 0.4) * 0.42
end
-- kept for old callers
function VM.swing(_fast: boolean) VM.use() end
function VM.recoil(_power: number) VM.use() end
function VM.toss() VM.use() end
function VM.setSpraying(on: boolean) spraying = on end

-- the server says the swing connected: freeze the pose for a moment (hit-stop)
function VM.impact(heavy: boolean?)
	freezeUntil = os.clock() + (heavy and 0.09 or 0.055)
	frozenAt = os.clock()
end

local function punchOffset(side: string, now: number): CFrame
	local out = CFrame.new()
	for i = #punches, 1, -1 do
		local p = punches[i]
		local a = (now - p.t0) / p.dur
		if a >= 1 then
			table.remove(punches, i)
		elseif p.side == side then
			local ext = a < 0.28 and (a / 0.28) or (1 - (a - 0.28) / 0.72) ^ 2
			ext = math.sin(ext * math.pi / 2)
			local sx = side == "R" and -1 or 1
			if p.kind == "jab" then
				out = CFrame.new(sx * 0.75 * ext, 0.35 * ext, -1.9 * ext) * A(0, sx * 0.25 * ext, 0)
			elseif p.kind == "hook" then
				out = CFrame.new(sx * 1.4 * ext, 0.45 * ext, -1.2 * ext) * A(0, sx * 1.1 * ext, sx * -0.6 * ext)
			elseif p.kind == "upper" then
				out = CFrame.new(sx * 0.7 * ext, 1.1 * ext, -1.4 * ext) * A(1.0 * ext, 0, 0)
			else -- slam (ultimate)
				out = CFrame.new(sx * 0.4 * ext, -0.6 * ext + (1 - ext) * 1.2, -1.6 * ext) * A(-0.9 * ext, 0, 0)
			end
		end
	end
	return out
end

-- the held item's animation offset for this frame (camera space, or the fist's frame for LOCAL_KEYS styles)
local function itemOffset(now: number): CFrame
	if spraying then
		local j = 0.02
		return CFrame.new((math.random() - 0.5) * j, (math.random() - 0.5) * j, 0.06) * A(0.03, 0, 0)
	end
	local forced = STUDIO and lp:GetAttribute("DebugAnimA") -- Studio test hook: freeze the animation at fraction a
	if type(forced) == "number" then
		local cf = sample(KEYS[style] or KEYS.bat, math.clamp(forced, 0, 1))
		return cf
	end
	if style == "saw" and not anim then
		return CFrame.new((math.random() - 0.5) * 0.015, (math.random() - 0.5) * 0.015, -0.3) -- idling engine
	end
	if not anim then return CFrame.new() end
	-- hit-stop: time stands still for a few frames
	local t = now
	if now < freezeUntil then
		t = frozenAt
	elseif frozenAt > 0 and freezeUntil > 0 then
		anim.t0 += (freezeUntil - frozenAt)
		freezeUntil, frozenAt = 0, 0
	end
	local a = (t - anim.t0) / anim.dur
	if a >= 1 then
		anim = nil
		if trail then trail.Enabled = false end
		return style == "saw" and CFrame.new(0, 0, -0.3) or CFrame.new()
	end
	local keys = KEYS[style] or KEYS.bat
	local cf = sample(keys, a)
	if anim.variant < 0 and (style == "bat" or style == "slash") then cf = mirror(cf) end
	if trail then trail.Enabled = a > 0.22 and a < 0.8 end
	if style == "saw" then cf *= CFrame.new((math.random() - 0.5) * 0.06, (math.random() - 0.5) * 0.06, 0) end
	-- thrown items leave the hand at release and come back
	anim.hidden = style == "throw" and a > 0.52 and a < 0.92
	return cf
end

function VM.update(dt: number)
	local ch = lp.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local firstPerson = (cam.CFrame.Position - cam.Focus.Position).Magnitude < 1.5
	local show = hum ~= nil and hum.Health > 0 and firstPerson
	for _, a in arms do for _, p in a do (p :: BasePart).LocalTransparencyModifier = show and 0 or 1 end end
	if not show then
		for _, list in auras do for _, p in list do p.LocalTransparencyModifier = 1 end end
		lastCamCF = cam.CFrame
		if held then for _, p in held:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier = 1 end end end
		return
	end
	local now = os.clock()
	-- sway from camera turning, bob from walking
	local rx, ry = (lastCamCF:ToObjectSpace(cam.CFrame)):ToOrientation()
	lastCamCF = cam.CFrame
	sway = sway:Lerp(Vector2.new(math.clamp(ry, -0.2, 0.2), math.clamp(rx, -0.2, 0.2)), math.min(1, dt * 10))
	local moving = hum and hum.MoveDirection.Magnitude > 0.1
	if moving then bobT += dt * (hum.WalkSpeed / 2.2) end
	local bob = moving and CFrame.new(math.sin(bobT) * 0.07, math.abs(math.cos(bobT)) * 0.08, 0) or CFrame.new()
	local carrying = lp:GetAttribute("Carrying") == true
	carryAlpha += ((carrying and 1 or 0) - carryAlpha) * math.min(1, dt * 10)
	local ult = lp:GetAttribute("UltActive") == true
	local jitter = ult and CFrame.new(math.random() * 0.03, math.random() * 0.03, 0) or CFrame.new()
	blockAlpha += ((lp:GetAttribute("Blocking") and 1 or 0) - blockAlpha) * math.min(1, dt * 14)
	local blockItem = (held and blockAlpha > 0.001) and (CFrame.new(-0.3 * blockAlpha, 0.28 * blockAlpha, 0.12 * blockAlpha) * A(0.2 * blockAlpha, 0, 0.85 * blockAlpha)) or CFrame.new()
	local base = cam.CFrame * shakeOff * chargeOff * blockItem * bob * jitter * CFrame.new(-sway.X * 1.2, sway.Y * 1.2, 0)
	-- an ultimate's cast takes both hands (a held item is put away for that second)
	local castA = 0
	if cast then
		castA = (Kit.now() - cast.t0) / CASTS[cast.name].dur
		if castA >= 1 then cast = nil end
	end
	local casting = cast ~= nil
	local itemHidden = carryAlpha > 0.5 or (anim ~= nil and anim.hidden == true) or casting
	arcT += dt
	local jump = arcT > 0.05
	if jump then arcT = 0 end
	for _, side in { "R", "L" } do
		local a = arms[side]
		local sx = side == "R" and 1 or -1
		local guard = CFrame.new(sx * 0.62, -0.62 + (side == "L" and -0.04 or 0), -1.5) * A(0.22, sx * -0.14, sx * -0.25)
		if blockAlpha > 0.001 and not held then
			-- fists up in front of the face, forearms upright
			guard = guard:Lerp(CFrame.new(sx * 0.3, -0.42, -1.05) * A(0.85, sx * 0.35, sx * 0.25), blockAlpha)
		end
		local carry = CFrame.new(sx * 0.7, -2.6, -1.2) * A(0.6, 0, sx * -0.15) -- arms drop out of view while lifting
		local fistCF
		if casting then
			fistCF = base * castPose(side, castA, guard)
		elseif side == "R" and held then
			local hold = holdCF
			if STUDIO then -- tuning hooks (player attributes): DebugHold (CFrame) or DebugFist/DebugAim/DebugRoll
				local g = lp:GetAttribute("DebugHold")
				local f, ai = lp:GetAttribute("DebugFist"), lp:GetAttribute("DebugAim")
				if typeof(g) == "CFrame" then hold = g end
				if typeof(f) == "Vector3" and typeof(ai) == "Vector2" then
					local fwd = tipPart and -(held :: Model):GetPivot():PointToObjectSpace(tipPart.Position).Z or heldLen
					hold = solveHold({ fist = f, aim = ai, roll = lp:GetAttribute("DebugRoll") or 0 }, fwd)
				end
			end
			local pose = hold:Lerp(carry, carryAlpha)
			local key = itemOffset(now)
			if LOCAL_KEYS[style] then
				fistCF = base * pose * key
			else
				fistCF = base * (CFrame.new(pose.Position + key.Position) * key.Rotation * pose.Rotation)
			end
			-- the item sits in the fist; move it (and its moving parts) now so the left hand can find its grip
			held:PivotTo(fistCF * (ITEM_OFF[style] or CFrame.identity))
			ItemModels.animate(held :: Model, anim and 3.2 or 0.35, lastUse > 0 and (now - lastUse) or nil)
		else
			fistCF = base * guard:Lerp(carry, carryAlpha) * punchOffset(side, now)
		end
		if casting then
			-- both hands belong to the cast
		elseif side == "L" and held and leftGripPart and carryAlpha < 0.5 and not itemHidden then
			-- two-handed item: the left fist holds the item's LeftGrip, forearm from the lower left
			local rot = LEFT_ROT[style] or LEFT_GRIP_ROT
			if STUDIO then local l = lp:GetAttribute("DebugLeftRot"); if typeof(l) == "CFrame" then rot = l end end
			fistCF = CFrame.new(leftGripPart.Position + base:VectorToWorldSpace(LEFT_DROP[style] or Vector3.zero)) * base.Rotation * rot
		elseif side == "L" and held and (style == "inject" or style == "apply") and anim then
			fistCF = base * CFrame.new(-0.55, -0.75, -1.3) * A(0.3, 0.4, 0.2) -- offer the arm / chest
		end
		a.fist.CFrame = fistCF
		if held and carryAlpha < 0.5 and not casting then
			-- holding an item: the forearm runs from the fist back to the shoulder (off the bottom corner),
			-- so swings and throws never push the arm into the camera
			local sh = base * SHOULDER[side]
			local from = fistCF.Position
			local dir = (sh - from).Unit
			a.arm.CFrame = CFrame.lookAt(from + dir * 1.05, sh, base.UpVector)
			a.sleeve.CFrame = CFrame.lookAt(from + dir * 2.0, sh + dir, base.UpVector)
		else
			a.arm.CFrame = fistCF * CFrame.new(0, -0.04, 1.05)
			a.sleeve.CFrame = fistCF * CFrame.new(0, -0.04, 2.0)
		end
		a.brass.CFrame = fistCF * CFrame.new(0, 0.1, -0.22)
		a.brass.LocalTransparencyModifier = 1
		a.fist.Material = ult and Enum.Material.Neon or Enum.Material.SmoothPlastic
		a.fist.Color = ult and Kit.dim(ultColor, 0.45) or skinColor
		-- the power runs up the arm: the skin takes a dark shade of the ultimate's colour
		a.arm.Color = ult and skinColor:Lerp(Kit.dim(ultColor, 0.22), 0.6) or skinColor
		auraStep(side, fistCF, base, ult or casting, now, jump)
	end
	if held then
		for _, p in held:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier = itemHidden and 1 or 0 end end
	end
end

return VM
