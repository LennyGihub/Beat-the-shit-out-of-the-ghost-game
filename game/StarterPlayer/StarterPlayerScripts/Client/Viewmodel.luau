-- First-person hands: guard pose, alternating jabs, hooks on high combos, carry pose, ultimate glow,
-- and the held item with a keyframed animation per weapon style (wind-up -> strike -> follow-through),
-- hit-stop on impact, swing trails, two-handed grips, pump/recoil for guns, drink/inject for consumables.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local ItemModels = require(RS.Shared.ItemModels)
local RunService = game:GetService("RunService")

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
local heldOffset = CFrame.new()
local heldLen = 2
local leftGripLocal: CFrame? = nil -- where the left hand holds the item (part "LeftGrip"), relative to its pivot
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
-- per-style right-hand hold pose (replaces the default item guard); the chainsaw sits low on the right,
-- angled toward the crosshair so its side, bar and chain show
-- left fist on an item's LeftGrip: forearm comes from the lower left, not across the screen
local LEFT_GRIP_ROT = A(0.4, -0.9, -0.6)
local HOLD = {
	saw = C(0.9, -1.2, -1.6, 0.7, 0.45, 1.3), -- on its side, top handle to the left, bar up toward the crosshair
}

-- weapon styles ------------------------------------------------------------------------------------
local STYLE = {
	FireAxe = "heavy", Sledgehammer = "heavy", StormHammer = "heavy", Shovel = "heavy", FrostPickaxe = "heavy",
	BaseballBat = "bat", SpikedBat = "bat", BurningBat = "bat", LeadPipe = "bat", Crowbar = "bat", FryingPan = "bat", GolfClub = "golf",
	Katana = "slash", DemonBlade = "slash", Machete = "slash", HolyCross = "thrust", Chainsaw = "saw",
	NailGun = "pistol", Taser = "pistol", FlareGun = "pistol", SilverRevolver = "pistol",
	SaltShotgun = "shotgun", PotatoCannon = "longgun", StakeCrossbow = "longgun", HarpoonGun = "longgun",
	EnergyDrink = "drink", Painkillers = "drink", Adrenaline = "inject", RageSerum = "inject",
	Medkit = "apply", KevlarVest = "apply", Talisman = "raise", PocketWatch = "raise", BearTrap = "place",
}
local TWO_HANDED = { heavy = true, saw = true, shotgun = true, longgun = true, golf = true }
local DUR = { heavy = 0.78, bat = 0.42, golf = 0.5, slash = 0.27, thrust = 0.34, saw = 0.12, pistol = 0.2, shotgun = 0.62,
	longgun = 0.45, throw = 0.48, drink = 0.9, inject = 0.8, apply = 0.8, raise = 0.9, place = 0.6, spray = 0.1 }

-- right-hand keyframes {t, offset from the guard pose}; left hand follows the item when two-handed
local KEYS = {
	heavy = { { 0, C(0, 0, 0) }, { 0.38, C(0.15, 1.25, 0.7, 1.35, 0.1, 0) }, { 0.52, C(-0.1, -0.55, -1.5, -1.25, 0, 0) },
		{ 0.72, C(-0.1, -0.6, -1.4, -1.2, 0, 0) }, { 1, C(0, 0, 0) } },
	bat = { { 0, C(0, 0, 0) }, { 0.28, C(0.6, 0.35, 0.45, 0.25, -1.0, -0.45) }, { 0.5, C(-0.9, 0.05, -1.35, -0.45, 1.15, 0.8) },
		{ 0.72, C(-1.35, -0.3, -0.6, -0.7, 1.55, 1.0) }, { 1, C(0, 0, 0) } },
	golf = { { 0, C(0, 0, 0) }, { 0.32, C(0.7, -0.6, 0.2, -1.2, -0.8, 0) }, { 0.52, C(-0.4, -0.2, -1.4, -0.2, 0.6, 0) },
		{ 0.75, C(-0.8, 1.2, -0.6, 1.2, 1.0, 0) }, { 1, C(0, 0, 0) } },
	slash = { { 0, C(0, 0, 0) }, { 0.2, C(0.7, 0.9, 0.2, 0.6, -0.4, -0.9) }, { 0.55, C(-0.9, -0.6, -1.3, -0.6, 0.7, 1.0) },
		{ 1, C(0, 0, 0) } },
	thrust = { { 0, C(0, 0, 0) }, { 0.3, C(0.1, 0.1, 0.6, 0.2, 0, 0) }, { 0.5, C(-0.25, 0.25, -2.0, -0.2, 0, 0) }, { 1, C(0, 0, 0) } },
	saw = { { 0, C(0, -0.1, -0.5) }, { 0.5, C(0, -0.02, -0.78, -0.1, 0, 0) }, { 1, C(0, -0.1, -0.5) } },
	pistol = { { 0, C(0, 0, 0) }, { 0.15, C(0, 0.18, 0.45, 0.45, 0, 0) }, { 1, C(0, 0, 0) } },
	shotgun = { { 0, C(0, 0, 0) }, { 0.1, C(0, 0.25, 0.6, 0.5, 0, 0) }, { 0.35, C(0, 0.05, 0.1, 0.1, 0, 0) }, { 1, C(0, 0, 0) } },
	longgun = { { 0, C(0, 0, 0) }, { 0.12, C(0, 0.3, 0.75, 0.6, 0, 0) }, { 1, C(0, 0, 0) } },
	throw = { { 0, C(0, 0, 0) }, { 0.38, C(0.4, 1.0, 0.9, 1.3, -0.2, 0) }, { 0.55, C(-0.2, 0.55, -1.6, -0.6, 0.1, 0) },
		{ 0.75, C(-0.3, -0.4, -1.2, -0.9, 0.2, 0) }, { 1, C(0, 0, 0) } },
	drink = { { 0, C(0, 0, 0) }, { 0.3, C(-0.55, 0.65, 0.55, 1.0, 0, 0.3) }, { 0.75, C(-0.55, 0.75, 0.6, 1.5, 0, 0.3) }, { 1, C(0, 0, 0) } },
	inject = { { 0, C(0, 0, 0) }, { 0.35, C(-0.6, 0.1, -0.2, 0.2, 0.9, 0) }, { 0.5, C(-0.9, -0.1, 0.1, 0.2, 1.2, 0) }, { 0.7, C(-0.9, -0.1, 0.1, 0.2, 1.2, 0) }, { 1, C(0, 0, 0) } },
	apply = { { 0, C(0, 0, 0) }, { 0.35, C(-0.4, -0.2, 0.3, -0.4, 0, 0) }, { 0.7, C(-0.4, -0.5, 0.5, -0.8, 0, 0) }, { 1, C(0, 0, 0) } },
	raise = { { 0, C(0, 0, 0) }, { 0.3, C(-0.4, 0.8, -0.6, 0.4, 0, 0) }, { 0.8, C(-0.4, 0.85, -0.7, 0.4, 0, 0) }, { 1, C(0, 0, 0) } },
	place = { { 0, C(0, 0, 0) }, { 0.45, C(-0.2, -1.6, -1.2, -0.9, 0, 0) }, { 1, C(0, 0, 0) } },
	spray = { { 0, C(0, 0, 0) }, { 1, C(0, 0, 0) } },
}

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

-- show an item in the right hand (nil = bare fists)
function VM.setItem(it: any)
	if it == heldItem then return end
	heldItem = it
	anim = nil
	trail = nil
	leftGripLocal = nil
	if held then held:Destroy(); held = nil end
	if not it then return end
	style = STYLE[it.id] or (it.kind == "throw" and "throw" or (it.kind == "spray" and "spray" or (it.kind == "gun" and "pistol" or "bat")))
	local m = ItemModels.build(it.shape, it.color, it.glow, it.id)
	m:ScaleTo(m:GetScale() * 0.55) -- first-person hands are close to the camera (relative: meshes are already scaled)
	for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.CastShadow = false end end
	m.Parent = model
	held = m
	local _, size = m:GetBoundingBox()
	heldLen = math.max(size.X, size.Y, size.Z)
	local lg = m:FindFirstChild("LeftGrip", true) :: BasePart?
	if lg then leftGripLocal = m:GetPivot():ToObjectSpace(lg.CFrame) end
	if it.kind == "melee" then
		heldOffset = style == "saw" and CFrame.new() or (CFrame.new(0, 0.1, 0) * A(math.rad(70), 0, 0) * CFrame.new(0, 0, 0.6))
		addTrail(m)
	elseif it.kind == "gun" or it.kind == "spray" then
		heldOffset = CFrame.new(-0.05, 0.15, -0.1)
	else
		heldOffset = CFrame.new(0, 0.25, -0.15) * A(0, math.rad(25), 0)
	end
end

-- world position of the held item's far end (spray nozzle)
function VM.itemTip(): Vector3?
	if not held then return nil end
	local pivot = held:GetPivot()
	return (pivot * CFrame.new(0, 0, -heldLen * 0.95)).Position
end

-- play the held item's animation (called on use)
function VM.use()
	if not heldItem then return end
	variant = -variant
	freezeUntil, frozenAt = 0, 0
	anim = { t0 = os.clock(), dur = DUR[style] or 0.4, variant = variant }
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

-- the held item's animation offset (right hand) for this frame
local function itemOffset(now: number): CFrame
	if spraying then
		local j = style == "spray" and 0.03 or 0.015
		return CFrame.new((math.random() - 0.5) * j, (math.random() - 0.5) * j, -0.15) * A(-0.05, 0, 0)
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
		return CFrame.new()
	end
	local keys = KEYS[style] or KEYS.bat
	local cf = sample(keys, a)
	if anim.variant < 0 and (style == "bat" or style == "slash") then cf = mirror(cf) end
	if trail then trail.Enabled = a > 0.25 and a < 0.8 end
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
	local base = cam.CFrame * shakeOff * bob * jitter * CFrame.new(-sway.X * 1.2, sway.Y * 1.2, 0)
	local itemCF: CFrame? = nil
	local rightFist: CFrame? = nil
	local twoHand = held ~= nil and TWO_HANDED[style] == true and carryAlpha < 0.5
	for _, side in { "R", "L" } do
		local a = arms[side]
		local sx = side == "R" and 1 or -1
		local guard = CFrame.new(sx * 0.62, -0.62 + (side == "L" and -0.04 or 0), -1.5) * A(0.22, sx * -0.14, sx * -0.25)
		if side == "R" and held then
			guard = HOLD[style] or (CFrame.new(0.5, -0.66, -1.35) * A(0.18, -0.1, -0.2))
			if STUDIO then -- tuning hooks: player attributes DebugHold / DebugHeldOffset (CFrame)
				local g, o = lp:GetAttribute("DebugHold"), lp:GetAttribute("DebugHeldOffset")
				if typeof(g) == "CFrame" then guard = g end
				if typeof(o) == "CFrame" then heldOffset = o end
				local l = lp:GetAttribute("DebugLeftRot")
				if typeof(l) == "CFrame" then LEFT_GRIP_ROT = l end
			end
		end
		local carry = CFrame.new(sx * 0.7, -2.6, -1.2) * A(0.6, 0, sx * -0.15) -- arms drop out of view while lifting
		local pose = guard:Lerp(carry, carryAlpha)
		local fistCF = base * pose * punchOffset(side, now)
		if side == "R" and held then
			fistCF = fistCF * itemOffset(now)
			itemCF = fistCF * heldOffset
			rightFist = fistCF
		end
		if side == "L" and twoHand and itemCF and leftGripLocal then
			-- the item says where the left hand goes (chainsaw top handle); forearm comes in from the left
			fistCF = CFrame.new(((itemCF :: CFrame) * (leftGripLocal :: CFrame)).Position) * base.Rotation * LEFT_GRIP_ROT
		elseif side == "L" and twoHand and itemCF then
			-- second hand further along the handle, same angle as the right hand (forearm toward the camera)
			local along = ((itemCF :: CFrame) * CFrame.new(0, -0.05, -math.min(heldLen * 0.3, 0.9))).Position
			fistCF = CFrame.new(along) * (rightFist :: CFrame).Rotation * A(0, 0.15, 0.2)
		elseif side == "L" and held and (style == "inject" or style == "apply") and anim then
			fistCF = base * CFrame.new(-0.55, -0.75, -1.3) * A(0.3, 0.4, 0.2) -- offer the arm / chest
		end
		a.fist.CFrame = fistCF
		a.arm.CFrame = fistCF * CFrame.new(0, -0.04, 1.05)
		a.sleeve.CFrame = fistCF * CFrame.new(0, -0.04, 2.0)
		a.brass.CFrame = fistCF * CFrame.new(0, 0.1, -0.22)
		a.brass.LocalTransparencyModifier = 1
		a.fist.Material = ult and Enum.Material.Neon or Enum.Material.SmoothPlastic
		a.fist.Color = ult and Color3.fromRGB(255, 70, 30) or skinColor
	end
	if held and itemCF then
		held:PivotTo(itemCF)
		ItemModels.animate(held, anim and 3.2 or 0.35) -- chainsaw chain: races while cutting, crawls at idle
		local hide = carryAlpha > 0.5 or (anim ~= nil and anim.hidden == true)
		for _, p in held:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier = hide and 1 or 0 end end
	end
end

return VM
