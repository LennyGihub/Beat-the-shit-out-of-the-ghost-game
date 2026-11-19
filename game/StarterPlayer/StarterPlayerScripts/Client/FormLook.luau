--!strict
-- What a worn FORM looks like on a character (Shared/Forms; player attributes FormStim / FormPotion), drawn by every
-- client for every player, so a good form is something to show off. The look grows with the form's rarity:
--   FIST FORM (Doc Mercy's ectoplasm), on the ARMS AND FISTS: an animated energy skin of the form's colour over the
--     fists (COMMON), up the forearms (UNCOMMON), over the whole arms (RARE+), sparks off the knuckles; RARE: the
--     fists glow from inside (pulsing) and light the ground; EPIC: flames off the fists and coloured streaks behind
--     every punch; LEGENDARY: lightning crawling up the arms and a ring of runes spinning round each wrist; MYTHIC:
--     dark smoke pouring off the arms. A few forms have their own skin (THE BLACK HAND: black arms; IRON KNUCKLES:
--     grey metal; MIRROR FISTS: glass).
--   BODY FORM (Mother Moth's potions), on the BODY: an animated aura over the torso and mist rising off it; UNCOMMON:
--     lights circling the waist; RARE: aura rings pulsing out along the ground from the feet, a light; EPIC: the aura
--     down the legs too and sparkles spiralling up round the body; LEGENDARY: a halo of lights over the head and a
--     heartbeat glow in the chest; MYTHIC: a pillar of light from the ground up. (The arms are the fist form's: the
--     body aura never covers them.)
-- Putting a new form on: a burst (a ball of energy, rings, a sound) everyone near sees.
-- Your own body in a fight is first person: the fist form glows on the first-person fists instead (Client/Viewmodel's
-- parts). Nothing animates further than FAR studs from the camera; "low" effects (Settings) keep only the skins.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Forms = require(RS.Shared.Forms)
local Settings = require(script.Parent.Settings)
local Sfx = require(script.Parent.Sfx)

local FL = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local TAG = "FormFx"
local TEX = "rbxasset://textures/particles/"
local FAR = 160
local hideOwn: (() -> boolean)? = nil

type Pulse = { part: BasePart, lo: number, hi: number, speed: number, phase: number, wave: boolean? }
type Orbit = { part: BasePart, ref: BasePart, radius: number, height: number, speed: number, phase: number, tilt: number, axis: string? }
type Arc = { beam: Beam, a0: Attachment, a1: Attachment }
type Look = { folder: Folder, ref: BasePart, pulses: { Pulse }, orbits: { Orbit }, arcs: { Arc }, beams: { Beam } }
local looks = {} :: { [Player]: Look }
-- first-person fists (your own, in a fight)
type VMShell = { part: BasePart, base: BasePart }
local vmShells = {} :: { VMShell }
local vmEmit = {} :: { { e: ParticleEmitter, base: BasePart } }
local vmOn = ""

-- (special skins: the colour / material of an inner layer under the energy skin)
local SKIN = {
	BlackHand = { color = Color3.fromRGB(12, 10, 10), mat = Enum.Material.SmoothPlastic, upTo = "LowerArm" },
	IronKnuckles = { color = Color3.fromRGB(120, 126, 134), mat = Enum.Material.DiamondPlate, upTo = "Hand" },
	MirrorFists = { color = Color3.fromRGB(210, 235, 255), mat = Enum.Material.Glass, upTo = "LowerArm" },
} :: { [string]: { color: Color3, mat: Enum.Material, upTo: string } }

local function fxLevel(): string
	local ok, v = pcall(function() return (Settings :: any).get and (Settings :: any).get("fx") end)
	return ok and type(v) == "string" and v or "medium"
end

local function bright(c: Color3, k: number): Color3 return c:Lerp(Color3.new(1, 1, 1), k) end

local function newPart(folder: Instance, size: Vector3, color: Color3, mat: Enum.Material, transp: number, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = TAG
	p.Size = size; p.Color = color; p.Material = mat; p.Transparency = transp
	if shape then p.Shape = shape end
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false; p.Massless = true
	p.Parent = folder
	return p
end

-- a skin over a limb: a copy of it (same shape) a little bigger, welded on
local function shell(folder: Instance, limb: BasePart, grow: number, color: Color3, mat: Enum.Material, transp: number): BasePart
	local s: BasePart? = nil
	if limb:IsA("MeshPart") then
		local ok, c = pcall(function() return limb:Clone() end)
		if ok and c then
			s = c
			c:ClearAllChildren()
			pcall(function() (c :: any).TextureID = "" end)
		end
	end
	if not s then
		local p = Instance.new("Part")
		p.Shape = (limb :: any).Shape or Enum.PartType.Block
		s = p
	end
	local sh = s :: BasePart
	sh.Name = TAG
	sh.Size = limb.Size * grow + Vector3.one * 0.04
	sh.Color = color; sh.Material = mat; sh.Transparency = transp; sh.Reflectance = mat == Enum.Material.Glass and 0.5 or 0
	sh.Anchored = false; sh.CanCollide = false; sh.CanQuery = false; sh.CanTouch = false; sh.CastShadow = false; sh.Massless = true
	sh.LocalTransparencyModifier = 0
	sh.CFrame = limb.CFrame
	local w = Instance.new("WeldConstraint")
	w.Part0 = limb; w.Part1 = sh; w.Parent = sh
	sh.Parent = folder
	return sh
end

local function emitter(parent: Instance, props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Name = TAG
	e.LightInfluence = 0
	for k, v in props do (e :: any)[k] = v end
	e.Parent = parent
	return e
end

local function numSeq(a: number, b: number, c: number?): NumberSequence
	if c then return NumberSequence.new({ NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(0.5, b), NumberSequenceKeypoint.new(1, c) }) end
	return NumberSequence.new(a, b)
end

-- the limbs of a rig (R15, or R6's single arm / torso)
local function limbs(ch: Model, side: string): { hand: BasePart?, lower: BasePart?, upper: BasePart? }
	local function bp(n: string): BasePart?
		local x = ch:FindFirstChild(n)
		return (x and x:IsA("BasePart")) and x or nil
	end
	local hand = bp(side .. "Hand")
	if hand then return { hand = hand, lower = bp(side .. "LowerArm"), upper = bp(side .. "UpperArm") } end
	return { hand = bp(side .. " Arm"), lower = nil, upper = nil }
end

----------------------------------------------------------------------------------------------------------------------
-- FIST FORM
local function buildFist(look: Look, ch: Model, fm: Forms.Form, level: string)
	local r = fm.rarity
	local col = fm.color
	local skin = SKIN[fm.id]
	local rate = level == "high" and 1 or 0.6
	for i, side in { "Right", "Left" } do
		local L = limbs(ch, side)
		local hand = L.hand
		if not hand then continue end
		local covered = { hand }
		if r >= 2 and L.lower then table.insert(covered, L.lower) end
		if r >= 3 and L.upper then table.insert(covered, L.upper) end
		-- a special skin under the energy (black / metal / glass)
		local skinned = {} :: { [BasePart]: boolean }
		if skin then
			for _, limb in covered do
				local inner = limb == hand or (skin.upTo == "LowerArm" and limb == L.lower) or skin.upTo == "UpperArm"
				if inner then shell(look.folder, limb, 1.03, skin.color, skin.mat, 0); skinned[limb] = true end
			end
		end
		-- the energy skin (ForceField: an animated shimmer) over a colour wash that breathes
		for k, limb in covered do
			shell(look.folder, limb, limb == hand and 1.22 or 1.12, bright(col, 0.15), Enum.Material.ForceField, 0)
			-- (RARE+ fists glow from inside instead, below; a special skin shows through without it)
			if (limb ~= hand or r < 3) and not skinned[limb] then
				local wash = shell(look.folder, limb, 1.05, col, Enum.Material.Neon, 0.8)
				table.insert(look.pulses, { part = wash, lo = 0.88 - r * 0.035, hi = 0.95 - r * 0.015, speed = 1.6 + r * 0.3, phase = k + i })
			end
		end
		if level == "low" then continue end
		-- glowing veins up the arm, a pulse running from the fist to the shoulder
		if r >= 2 then
			local order = 0
			for _, limb in covered do
				if limb == hand then continue end
				local sz = limb.Size
				for _, face in { { x = 0, z = -1 }, { x = (side == "Right" and 1 or -1), z = 0 } } do
					for seg = 1, 3 do
						-- (seg 1 = the end near the hand: the bottom of the limb)
						local y = (-0.5 + (seg - 0.5) / 3) * sz.Y * 0.9
						local v = newPart(look.folder, Vector3.new(face.x == 0 and 0.09 or 0.05, sz.Y * 0.28, face.x == 0 and 0.05 or 0.09), bright(col, 0.35), Enum.Material.Neon, 0.3)
						v.Anchored = false
						v.CFrame = limb.CFrame * CFrame.new(face.x * (sz.X / 2 + 0.03) + (face.x == 0 and (seg - 2) * 0.06 or 0), y, face.z * (sz.Z / 2 + 0.03)) * CFrame.Angles(0, 0, face.x == 0 and (seg - 2) * 0.25 or 0)
						local w = Instance.new("WeldConstraint"); w.Part0 = limb; w.Part1 = v; w.Parent = v
						table.insert(look.pulses, { part = v, lo = 0, hi = 1, speed = -(4 + r * 0.8), phase = (order * 3 + seg) * 0.9, wave = true })
					end
				end
				order += 1
			end
		end
		-- the fists glow from inside (pulsing)
		if r >= 3 then
			local g = shell(look.folder, hand, 1.08, col, Enum.Material.Neon, 0.55)
			if skinned[hand] then g.Size = hand.Size * 1.1 + Vector3.one * 0.04 end
			table.insert(look.pulses, { part = g, lo = 0.35, hi = 0.85, speed = 2 + r * 0.6, phase = i })
			local l = Instance.new("PointLight")
			l.Name = TAG; l.Color = col; l.Range = 5 + r * 1.5; l.Brightness = 1 + r * 0.2; l.Shadows = false
			l.Parent = hand
		end
		-- sparks off the knuckles
		emitter(hand, {
			Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(bright(col, 0.5), col), LightEmission = 1,
			Size = numSeq(0.18 + r * 0.03, 0), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(0.4, 0.8),
			Speed = NumberRange.new(1, 3 + r * 0.4), SpreadAngle = Vector2.new(60, 60), Acceleration = Vector3.new(0, 2.5, 0),
			Rate = (3 + r * 2) * rate, RotSpeed = NumberRange.new(-200, 200),
		})
		-- flames off the fists + streaks behind the punches
		if r >= 4 then
			emitter(hand, {
				Texture = TEX .. "fire_main.dds", Color = ColorSequence.new(bright(col, 0.6), col), LightEmission = 0.8,
				Size = numSeq(0.9 + r * 0.12, 0.15), Transparency = numSeq(0.15, 1), Lifetime = NumberRange.new(0.45, 0.8),
				Speed = NumberRange.new(1, 2.5), SpreadAngle = Vector2.new(20, 20), Acceleration = Vector3.new(0, 6, 0),
				EmissionDirection = Enum.NormalId.Top, LockedToPart = false,
				Rate = (16 + r * 4) * rate, RotSpeed = NumberRange.new(-90, 90), Rotation = NumberRange.new(0, 360),
			})
			local a0 = Instance.new("Attachment"); a0.Name = TAG; a0.Position = Vector3.new(0, hand.Size.Y * 0.45, 0); a0.Parent = hand
			local a1 = Instance.new("Attachment"); a1.Name = TAG; a1.Position = Vector3.new(0, -hand.Size.Y * 0.45, 0); a1.Parent = hand
			local tr = Instance.new("Trail")
			tr.Name = TAG; tr.Attachment0 = a0; tr.Attachment1 = a1
			tr.Lifetime = 0.22; tr.MinLength = 0.05; tr.LightEmission = 1; tr.LightInfluence = 0; tr.FaceCamera = true
			tr.Color = ColorSequence.new(bright(col, 0.4), col); tr.Transparency = numSeq(0.15, 1)
			tr.WidthScale = numSeq(1, 0.2)
			tr.Parent = hand
		end
		-- lightning up the arm + a ring of runes round the wrist
		if r >= 5 then
			local top = L.upper or L.lower or hand
			for k = 1, 2 do
				local a0 = Instance.new("Attachment"); a0.Name = TAG; a0.Parent = hand
				local a1 = Instance.new("Attachment"); a1.Name = TAG; a1.Parent = top
				local b = Instance.new("Beam")
				b.Name = TAG; b.Attachment0 = a0; b.Attachment1 = a1
				b.Color = ColorSequence.new(Color3.new(1, 1, 1), bright(col, 0.3)); b.LightEmission = 1; b.LightInfluence = 0
				b.Width0 = 0.08; b.Width1 = 0.05; b.Segments = 8; b.FaceCamera = true; b.Transparency = numSeq(0, 0.3)
				b.Parent = hand
				table.insert(look.arcs, { beam = b, a0 = a0, a1 = a1 })
				local _ = k
			end
			local wrist = L.lower or hand
			for k = 1, 6 do
				local rune = newPart(look.folder, Vector3.new(0.14, 0.14, 0.14), bright(col, 0.25), Enum.Material.Neon, 0)
				table.insert(look.orbits, { part = rune, ref = wrist, radius = math.max(wrist.Size.X, wrist.Size.Z) * 0.75 + 0.25,
					height = -wrist.Size.Y * 0.3, speed = (i == 1 and 4 or -4), phase = k * math.pi / 3, tilt = 0, axis = "limb" })
			end
		end
		-- dark smoke off the arms
		if r >= 6 then
			for _, limb in covered do
				emitter(limb, {
					Texture = TEX .. "smoke_main.dds", Color = ColorSequence.new(Color3.fromRGB(20, 8, 8), col:Lerp(Color3.new(0, 0, 0), 0.5)),
					LightEmission = 0, Size = numSeq(0.6, 1.8), Transparency = numSeq(0.45, 1), Lifetime = NumberRange.new(0.8, 1.3),
					Speed = NumberRange.new(0.5, 1.2), SpreadAngle = Vector2.new(50, 50), Acceleration = Vector3.new(0, 2, 0),
					Rate = 8 * rate, RotSpeed = NumberRange.new(-60, 60), Rotation = NumberRange.new(0, 360),
				})
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------
-- BODY FORM
local function buildBody(look: Look, ch: Model, fm: Forms.Form, level: string, hrp: BasePart)
	local r = fm.rarity
	local col = fm.color
	local rate = level == "high" and 1 or 0.6
	local function bp(n: string): BasePart?
		local x = ch:FindFirstChild(n)
		return (x and x:IsA("BasePart")) and x or nil
	end
	local torsos = {}
	for _, n in { "UpperTorso", "LowerTorso", "Torso" } do
		local t = bp(n)
		if t then table.insert(torsos, t) end
	end
	local chest = torsos[1]
	if not chest then return end
	-- the aura (ForceField shimmer) over the torso; EPIC+: down the legs too (the arms are the fist form's)
	local covered = table.clone(torsos)
	if r >= 4 then
		for _, n in { "RightUpperLeg", "RightLowerLeg", "LeftUpperLeg", "LeftLowerLeg", "RightFoot", "LeftFoot", "Right Leg", "Left Leg" } do
			local x = bp(n)
			if x then table.insert(covered, x) end
		end
	end
	for k, limb in covered do
		shell(look.folder, limb, 1.1, bright(col, 0.1), Enum.Material.ForceField, 0)
		local wash = shell(look.folder, limb, 1.04, col, Enum.Material.Neon, 0.85)
		table.insert(look.pulses, { part = wash, lo = 0.84 - r * 0.03, hi = 0.94 - r * 0.015, speed = 1.3 + r * 0.25, phase = k })
	end
	if level == "low" then return end
	-- mist rising off the chest
	emitter(chest, {
		Texture = TEX .. "smoke_main.dds", Color = ColorSequence.new(bright(col, 0.35), col), LightEmission = 0.6,
		Size = numSeq(0.6, 2 + r * 0.2), Transparency = numSeq(0.6, 0.7, 1), Lifetime = NumberRange.new(1.2, 2),
		Speed = NumberRange.new(0.6, 1.4), SpreadAngle = Vector2.new(50, 50), Acceleration = Vector3.new(0, 1.5, 0),
		Rate = (2 + r) * rate, RotSpeed = NumberRange.new(-40, 40), Rotation = NumberRange.new(0, 360),
	})
	-- lights circling the waist
	if r >= 2 then
		local n = math.min(2 + r, 7)
		for k = 1, n do
			local m = newPart(look.folder, Vector3.one * (0.22 + r * 0.02), bright(col, 0.35), Enum.Material.Neon, 0, Enum.PartType.Ball)
			table.insert(look.orbits, { part = m, ref = hrp, radius = 2.1 + (k % 2) * 0.35, height = -0.4 + math.sin(k * 1.7) * 0.9,
				speed = 1.6 + (k % 3) * 0.35, phase = k * 2 * math.pi / n, tilt = 0.35 * ((k % 2) * 2 - 1) })
			if r >= 3 then
				local a0 = Instance.new("Attachment"); a0.Name = TAG; a0.Position = Vector3.new(0, 0.1, 0); a0.Parent = m
				local a1 = Instance.new("Attachment"); a1.Name = TAG; a1.Position = Vector3.new(0, -0.1, 0); a1.Parent = m
				local tr = Instance.new("Trail")
				tr.Name = TAG; tr.Attachment0 = a0; tr.Attachment1 = a1; tr.Lifetime = 0.45; tr.LightEmission = 1; tr.LightInfluence = 0
				tr.FaceCamera = true; tr.Color = ColorSequence.new(col); tr.Transparency = numSeq(0.2, 1); tr.WidthScale = numSeq(1, 0)
				tr.Parent = m
			end
		end
	end
	-- aura rings along the ground + a light
	local hum = ch:FindFirstChildOfClass("Humanoid")
	local feetY = -(hrp.Size.Y / 2 + (hum and hum.HipHeight or 2)) + 0.15
	if r >= 3 then
		local feet = Instance.new("Attachment"); feet.Name = TAG; feet.Position = Vector3.new(0, feetY, 0); feet.Parent = hrp
		emitter(feet, {
			Texture = TEX .. "explosion01_shockwave_main.dds", Color = ColorSequence.new(bright(col, 0.3)), LightEmission = 1,
			Orientation = Enum.ParticleOrientation.VelocityPerpendicular, EmissionDirection = Enum.NormalId.Top,
			Speed = NumberRange.new(0.01), Size = numSeq(1, 6 + r), Transparency = numSeq(0.2, 1), Lifetime = NumberRange.new(1.3),
			Rate = 0.5 + r * 0.15, LockedToPart = false,
		})
		local l = Instance.new("PointLight")
		l.Name = TAG; l.Color = col; l.Range = 8 + r * 1.5; l.Brightness = 0.9 + r * 0.15; l.Shadows = false
		l.Parent = chest
	end
	-- sparkles spiralling up round the body
	if r >= 4 then
		local col2 = newPart(look.folder, Vector3.new(4.2, 5.5, 4.2), col, Enum.Material.SmoothPlastic, 1)
		col2.Anchored = false
		col2.CFrame = hrp.CFrame * CFrame.new(0, feetY + 2.75, 0)
		local w = Instance.new("WeldConstraint"); w.Part0 = hrp; w.Part1 = col2; w.Parent = col2
		emitter(col2, {
			Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(Color3.new(1, 1, 1), col), LightEmission = 1,
			Shape = Enum.ParticleEmitterShape.Cylinder, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
			EmissionDirection = Enum.NormalId.Top, Speed = NumberRange.new(2.5, 4.5), Size = numSeq(0.3, 0), Transparency = numSeq(0, 1),
			Lifetime = NumberRange.new(0.9, 1.4), Rate = (8 + r * 3) * rate, Acceleration = Vector3.new(0, 1, 0),
		})
	end
	-- halo over the head + a heartbeat in the chest
	if r >= 5 then
		local head = bp("Head")
		if head then
			for k = 1, 10 do
				local h = newPart(look.folder, Vector3.one * 0.18, bright(col, 0.5), Enum.Material.Neon, 0, Enum.PartType.Ball)
				table.insert(look.orbits, { part = h, ref = head, radius = 0.95, height = head.Size.Y * 0.5 + 0.75, speed = 1.2,
					phase = k * math.pi / 5, tilt = 0 })
			end
		end
		local heart = shell(look.folder, chest, 1.04, col, Enum.Material.Neon, 0.7)
		table.insert(look.pulses, { part = heart, lo = 0.45, hi = 0.92, speed = 7, phase = 0 })
	end
	-- a pillar of light from the ground up
	if r >= 6 then
		local a0 = Instance.new("Attachment"); a0.Name = TAG; a0.Position = Vector3.new(0, feetY, 0); a0.Parent = hrp
		local a1 = Instance.new("Attachment"); a1.Name = TAG; a1.Position = Vector3.new(0, feetY + 16, 0); a1.Parent = hrp
		local b = Instance.new("Beam")
		b.Name = TAG; b.Attachment0 = a0; b.Attachment1 = a1; b.FaceCamera = true
		b.Width0 = 5; b.Width1 = 2; b.LightEmission = 1; b.LightInfluence = 0; b.Segments = 1
		-- (a soft glow stretched along it: soft edges, no flat rectangle)
		b.Texture = TEX .. "forcefield_glow_main.dds"; b.TextureMode = Enum.TextureMode.Stretch; b.TextureLength = 1
		b.Color = ColorSequence.new(bright(col, 0.4), col)
		b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 0.65), NumberSequenceKeypoint.new(1, 1) })
		b.Parent = hrp
		table.insert(look.beams, b)
	end
end

----------------------------------------------------------------------------------------------------------------------
local function clear(p: Player)
	local look = looks[p]
	if look then
		looks[p] = nil
		look.folder:Destroy()
	end
	local ch = p.Character
	if ch then
		for _, d in ch:GetDescendants() do
			if d.Name == TAG then d:Destroy() end
		end
	end
end

local function ownHidden(p: Player): boolean
	if p ~= lp then return false end
	if lp:GetAttribute("InMatch") and not lp:GetAttribute("Spectating") then return true end -- (first person)
	return hideOwn ~= nil and hideOwn()
end

local function apply(p: Player)
	clear(p)
	local ch = p.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not ch or not hrp then return end
	if ownHidden(p) then return end
	local stim = Forms.byId[p:GetAttribute("FormStim") or ""]
	local pot = Forms.byId[p:GetAttribute("FormPotion") or ""]
	if not stim and not pot then return end
	local folder = Instance.new("Folder")
	folder.Name = TAG
	folder.Parent = ch
	local look: Look = { folder = folder, ref = hrp, pulses = {}, orbits = {}, arcs = {}, beams = {} }
	looks[p] = look
	local level = fxLevel()
	if stim then buildFist(look, ch, stim, level) end
	if pot then buildBody(look, ch, pot, level, hrp) end
end

-- putting a new form on: a ball of energy, rings, a sound
local function burst(p: Player, kind: string)
	local ch = p.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	local fm = Forms.byId[p:GetAttribute(kind == "stim" and "FormStim" or "FormPotion") or ""]
	if not hrp or not fm or ownHidden(p) then return end
	if (hrp.Position - cam.CFrame.Position).Magnitude > FAR then return end
	local ball = newPart(workspace, Vector3.one * 2, bright(fm.color, 0.2), Enum.Material.ForceField, 0, Enum.PartType.Ball)
	ball.CFrame = hrp.CFrame
	local big = 10 + fm.rarity * 2.5
	TweenService:Create(ball, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * big, Transparency = 1 }):Play()
	local flash = newPart(workspace, Vector3.one * 3, fm.color, Enum.Material.Neon, 0.2, Enum.PartType.Ball)
	flash.CFrame = hrp.CFrame
	TweenService:Create(flash, TweenInfo.new(0.35), { Size = Vector3.one * 6, Transparency = 1 }):Play()
	local l = Instance.new("PointLight"); l.Color = fm.color; l.Range = 22; l.Brightness = 4; l.Parent = flash
	local ring = Instance.new("Attachment"); ring.Parent = hrp
	local e = emitter(ring, {
		Texture = TEX .. "explosion01_shockwave_main.dds", Color = ColorSequence.new(bright(fm.color, 0.3)), LightEmission = 1,
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular, EmissionDirection = Enum.NormalId.Top, Speed = NumberRange.new(0.01),
		Size = numSeq(2, 18 + fm.rarity * 2), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(0.8), Rate = 0,
	})
	e:Emit(3)
	local sp = emitter(ring, {
		Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(Color3.new(1, 1, 1), fm.color), LightEmission = 1,
		Speed = NumberRange.new(12, 22), SpreadAngle = Vector2.new(180, 180), Size = numSeq(0.6, 0), Transparency = numSeq(0, 1),
		Lifetime = NumberRange.new(0.5, 0.9), Rate = 0, Drag = 4,
	})
	sp:Emit(20 + fm.rarity * 10)
	Sfx.at(fm.rarity >= 4 and "MagicBurst" or "FormMagic", hrp.Position, { Volume = 0.8 })
	task.delay(1.6, function()
		ball:Destroy(); flash:Destroy(); ring:Destroy()
	end)
end

----------------------------------------------------------------------------------------------------------------------
-- YOUR FIRST-PERSON FISTS (a fight): the fist form on Client/Viewmodel's parts
local function clearVM()
	for _, s in vmShells do s.part:Destroy() end
	vmShells = {}
	vmEmit = {}
	local vm = cam:FindFirstChild("Viewmodel")
	if vm then
		for _, d in vm:GetDescendants() do if d.Name == TAG then d:Destroy() end end
	end
	vmOn = ""
end

local function applyVM()
	local want = ""
	local fm = Forms.byId[lp:GetAttribute("FormStim") or ""]
	if fm and lp:GetAttribute("InMatch") and not lp:GetAttribute("Spectating") then want = fm.id .. "|" .. fxLevel() end
	if want == vmOn then return end
	clearVM()
	if want == "" or not fm then return end
	local vm = cam:FindFirstChild("Viewmodel")
	if not vm then return end
	vmOn = want
	local r = fm.rarity
	local col = fm.color
	local level = fxLevel()
	for _, side in { "R", "L" } do
		local fist = vm:FindFirstChild(side .. "Fist") :: BasePart?
		local arm = vm:FindFirstChild(side .. "Arm") :: BasePart?
		if not fist then continue end
		local parts = { fist }
		if r >= 2 and arm then table.insert(parts, arm) end
		for _, base in parts do
			local s = newPart(vm, base.Size * (base == fist and 1.18 or 1.1) + Vector3.one * 0.02, bright(col, 0.15), Enum.Material.ForceField, 0.35)
			table.insert(vmShells, { part = s, base = base })
			if r >= 3 and base == fist then
				local g = newPart(vm, base.Size * 1.06, col, Enum.Material.Neon, 0.6)
				table.insert(vmShells, { part = g, base = base })
			end
		end
		if level == "low" then continue end
		local e1 = emitter(fist, {
			Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(bright(col, 0.5), col), LightEmission = 1, LockedToPart = true,
			Size = numSeq(0.08 + r * 0.01, 0), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(0.25, 0.5),
			Speed = NumberRange.new(0.4, 1.2), SpreadAngle = Vector2.new(70, 70), Rate = 4 + r * 2,
		})
		table.insert(vmEmit, { e = e1, base = fist })
		if r >= 4 then
			local e2 = emitter(fist, {
				Texture = TEX .. "fire_main.dds", Color = ColorSequence.new(bright(col, 0.6), col), LightEmission = 0.9, LockedToPart = true,
				Size = numSeq(0.25, 0.05), Transparency = numSeq(0.45, 1), Lifetime = NumberRange.new(0.25, 0.4),
				Speed = NumberRange.new(0.6, 1.2), EmissionDirection = Enum.NormalId.Top, Rate = 10 + r * 2, Rotation = NumberRange.new(0, 360),
			})
			table.insert(vmEmit, { e = e2, base = fist })
		end
		if r >= 3 then
			local l = Instance.new("PointLight")
			l.Name = TAG; l.Color = col; l.Range = 4 + r; l.Brightness = 0.8; l.Shadows = false
			l.Parent = fist
		end
	end
end

----------------------------------------------------------------------------------------------------------------------
local arcT = 0
local function step(dt: number)
	local now = os.clock()
	local camPos = cam.CFrame.Position
	arcT += dt
	local rearc = arcT > 0.07
	if rearc then arcT = 0 end
	for p, look in looks do
		if not look.folder.Parent then looks[p] = nil; continue end
		if (look.ref.Position - camPos).Magnitude > FAR then continue end
		for _, pu in look.pulses do
			if pu.wave then
				-- a vein: lit when the travelling pulse passes, dim in between
				local k = 0.5 + 0.5 * math.sin(now * pu.speed + pu.phase)
				pu.part.Transparency = 0.85 - 0.85 * k * k * k
			else
				local k = 0.5 + 0.5 * math.sin(now * pu.speed + pu.phase)
				pu.part.Transparency = pu.lo + (pu.hi - pu.lo) * k
			end
		end
		for _, o in look.orbits do
			local ang = now * o.speed + o.phase
			local cf: CFrame
			if o.axis == "limb" then
				-- round the limb's own long axis (a wrist ring)
				cf = o.ref.CFrame * CFrame.new(0, o.height, 0) * CFrame.Angles(0, ang, 0) * CFrame.new(o.radius, 0, 0)
			else
				local base = CFrame.new(o.ref.Position) * CFrame.Angles(o.tilt, 0, o.tilt * 0.5)
				cf = base * CFrame.new(math.cos(ang) * o.radius, o.height, math.sin(ang) * o.radius)
			end
			o.part.CFrame = cf
		end
		if rearc then
			for _, a in look.arcs do
				a.beam.Enabled = math.random() < 0.75
				a.beam.CurveSize0 = (math.random() - 0.5) * 3
				a.beam.CurveSize1 = (math.random() - 0.5) * 3
				a.a0.Position = Vector3.new((math.random() - 0.5) * 0.4, (math.random() - 0.5) * 0.3, (math.random() - 0.5) * 0.4)
			end
		end
		for _, b in look.beams do
			local k = 0.5 + 0.5 * math.sin(now * 2.2)
			b.Width0 = 4.2 + k * 1.6
		end
	end
end

-- after Client/Viewmodel has placed the fists this frame
local function stepVM()
	if #vmShells == 0 then return end
	local now = os.clock()
	for i, s in vmShells do
		s.part.CFrame = s.base.CFrame
		s.part.LocalTransparencyModifier = s.base.LocalTransparencyModifier
		if s.part.Material == Enum.Material.Neon then
			s.part.Transparency = 0.45 + 0.35 * (0.5 + 0.5 * math.sin(now * 5 + i))
		end
	end
	for _, x in vmEmit do x.e.Enabled = x.base.LocalTransparencyModifier < 0.5 end
end

local function watch(p: Player)
	local seen = { FormStim = p:GetAttribute("FormStim"), FormPotion = p:GetAttribute("FormPotion") } :: { [string]: any }
	for _, a in { "FormStim", "FormPotion" } do
		p:GetAttributeChangedSignal(a):Connect(function()
			local v = p:GetAttribute(a)
			local old = seen[a]
			seen[a] = v
			apply(p)
			if p == lp then applyVM() end
			-- a form put on (old == nil: the save loading, no burst)
			if type(v) == "string" and v ~= "" and type(old) == "string" and old ~= v then burst(p, a == "FormStim" and "stim" or "potion") end
		end)
	end
	p.CharacterAdded:Connect(function(ch)
		ch:WaitForChild("HumanoidRootPart", 5)
		task.wait(0.5)
		if p.Character == ch then apply(p) end
	end)
	if p.Character then task.spawn(apply, p) end
end

function FL.init(hidden: (() -> boolean)?)
	hideOwn = hidden
	for _, p in Players:GetPlayers() do watch(p) end
	Players.PlayerAdded:Connect(watch)
	Players.PlayerRemoving:Connect(function(p) looks[p] = nil end)
	for _, a in { "InMatch", "Spectating" } do
		lp:GetAttributeChangedSignal(a):Connect(function() apply(lp); applyVM() end)
	end
	-- your own look hides while a cinematic plays (hidden()), and comes back after
	local wasHidden = false
	RunService.Heartbeat:Connect(function(dt)
		step(dt)
		local h = ownHidden(lp)
		if h ~= wasHidden then
			wasHidden = h
			apply(lp)
		end
	end)
	RunService:BindToRenderStep("FormLookVM", Enum.RenderPriority.Camera.Value + 3, stepVM)
	task.spawn(function()
		while true do
			task.wait(1)
			applyVM()
		end
	end)
end
FL.refresh = apply

-- Studio test hook (client): player attribute DebugFormBurst = "stim" | "potion" plays the put-on burst
if RunService:IsStudio() then
	lp:GetAttributeChangedSignal("DebugFormBurst"):Connect(function()
		local k = lp:GetAttribute("DebugFormBurst")
		if k == "stim" or k == "potion" then burst(lp, k) end
	end)
end

return FL
