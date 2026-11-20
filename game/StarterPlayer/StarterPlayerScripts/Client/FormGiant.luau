--!strict
-- THE GIANT (the user, 2026-11-19: "the latest jar / potion need a way bigger visual, to flex even more, it can be 10
-- times as big as the player"). A form of the latest set (the Black Moon's jars and potions: Forms set "Moon") makes
-- its wearer's GIANT stand over them: an energy copy of their own body, SCALE x as tall (MOON COMMON 3.5x .. MYTHIC
-- 10x), that copies every move they make (walk, punch, wave) and rises out of the ground when the form goes on.
--   BODY (Mother Moth's Moon potions): the giant's body glows in the potion's colour; stars drift inside it, nebula
--     clouds roll round it, a ring of lights (a planet's ring) turns round its waist; RARE: moons ride the ring;
--     EPIC: a halo of stars over its head; LEGENDARY: its heart beats and every beat rolls a shock ring along the
--     ground; MYTHIC: a black hole behind its head and a pillar of light into the sky.
--   FISTS (Doc Mercy's Moon goo): the giant's arms are the jar's colour and its fists burn like stars (a light, sparks);
--     UNCOMMON: comet trails behind every punch; RARE: plasma flames; EPIC: rocks orbiting each fist; LEGENDARY:
--     lightning between the fists and down to the ground; MYTHIC: dark smoke off the arms and a black moon round
--     each fist.
--   Only one of the two worn: the other half of the giant is a faint shadow (its arms, or its body).
-- Shown in the park (never while the wearer is in a fight: it would fill the room). Client only, drawn by every client
-- for every player (Client/FormLook calls it). It never hides its own player: a part of it between a camera and its
-- player (or round the camera) fades out on that screen.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FG = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local TAG = "FormGiant"
local TEX = "rbxasset://textures/particles/"
local FAR = 650 -- (it is seen from far away; further than this it is put away)
local RISE = 1.6 -- seconds it takes to rise out of the ground
local BACK = 0.42 -- it stands this far behind its player (x its scale)
-- how many times its player's size, by set and rarity
local SCALE: { [string]: { number } } = {
	Moon = { 3.5, 4.5, 5.5, 7, 8.5, 10 },
}
local ARMS = { RightUpperArm = true, RightLowerArm = true, RightHand = true, LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
	["Right Arm"] = true, ["Left Arm"] = true }
local HANDS = { RightHand = true, LeftHand = true, ["Right Arm"] = true, ["Left Arm"] = true }
local BODY = { "Head", "UpperTorso", "LowerTorso", "Torso", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm",
	"LeftHand", "Right Arm", "Left Arm", "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Right Leg", "Left Leg" }

type Limb = { src: BasePart, outer: BasePart, inner: BasePart, size: Vector3, pulse: { lo: number, hi: number, speed: number, phase: number }?, fade: number }
type Orbit = { part: BasePart, ref: BasePart, radius: number, height: number, speed: number, phase: number, tilt: number }
type Arc = { beam: Beam, a0: Attachment, a1: Attachment }
type Giant = {
	player: Player, folder: Folder, deco: Folder, hrp: BasePart, h0: number, scale: number, born: number, decoOn: boolean,
	limbs: { Limb }, byName: { [string]: Limb }, orbits: { Orbit }, arcs: { Arc }, ring: BasePart?, ringTilt: number,
	hole: BasePart?, beat: { att: Attachment, e: ParticleEmitter, last: number }?, pillar: Beam?, level: string, shown: boolean,
	stim: any, pot: any, sized: boolean, extras: { Instance }, -- (extras: things put on its player's root part)
}
local giants = {} :: { [Player]: Giant }
local holder: Folder? = nil

local function bright(c: Color3, k: number): Color3 return c:Lerp(Color3.new(1, 1, 1), k) end
local function dark(c: Color3, k: number): Color3 return c:Lerp(Color3.new(0, 0, 0), k) end
local function numSeq(a: number, b: number, c: number?): NumberSequence
	if c then return NumberSequence.new({ NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(0.5, b), NumberSequenceKeypoint.new(1, c) }) end
	return NumberSequence.new(a, b)
end

local function root(): Folder
	if holder and holder.Parent then return holder end
	local f = Instance.new("Folder")
	f.Name = "FormGiants"
	f.Parent = workspace
	holder = f
	return f
end

-- the giant's scale for a form (nil = an ordinary form)
function FG.scaleOf(fm: any): number?
	if not fm then return nil end
	local t = SCALE[fm.set]
	return t and t[math.clamp(fm.rarity, 1, #t)] or nil
end

local function part(parent: Instance, size: Vector3, color: Color3, mat: Enum.Material, transp: number, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = TAG
	p.Size = size; p.Color = color; p.Material = mat; p.Transparency = transp
	if shape then p.Shape = shape end
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Parent = parent
	return p
end
-- a copy of a body part (same shape, no face / texture / joints), anchored
local function copy(parent: Instance, limb: BasePart, color: Color3, mat: Enum.Material, transp: number): BasePart
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
	sh.Color = color; sh.Material = mat; sh.Transparency = transp; sh.Reflectance = 0
	sh.Anchored = true; sh.CanCollide = false; sh.CanQuery = false; sh.CanTouch = false; sh.CastShadow = false
	sh.LocalTransparencyModifier = 0
	sh.Parent = parent
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
local function weldTo(base: BasePart, p: BasePart, cf: CFrame)
	p.Anchored = false; p.Massless = true
	p.CFrame = base.CFrame * cf
	local w = Instance.new("WeldConstraint"); w.Part0 = base; w.Part1 = p; w.Parent = p
end

function FG.clear(p: Player)
	local g = giants[p]
	if g then
		giants[p] = nil
		g.folder:Destroy()
		for _, x in g.extras do x:Destroy() end
	end
end

-- where its player's feet are, below the root (the giant's feet stand on the same ground)
local function rootHeight(ch: Model, hrp: BasePart): number
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then return hum.HipHeight + hrp.Size.Y / 2 end
	return hrp.Size.Y / 2 + 2
end

----------------------------------------------------------------------------------------------------------------------
-- the extras, added once the giant has risen (they are built at its full size)
local function decorate(g: Giant)
	if g.decoOn or not g.folder.Parent then return end
	g.decoOn = true
	local S = g.scale
	local low = g.level == "low"
	local rate = g.level == "high" and 1 or 0.6
	local chest = g.byName.UpperTorso or g.byName.Torso
	local waist = g.byName.LowerTorso or g.byName.Torso
	local head = g.byName.Head
	local pot, stim = g.pot, g.stim
	-- BODY (potion)
	if pot and chest then
		local col = pot.color
		local r = pot.rarity
		if not low then
			-- stars drifting inside the body, nebula round it
			emitter(chest.outer, {
				Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(Color3.new(1, 1, 1), bright(col, 0.4)), LightEmission = 1,
				Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
				Size = numSeq(0.1 * S, 0.02 * S), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(1.5, 3),
				Speed = NumberRange.new(0.05 * S, 0.2 * S), SpreadAngle = Vector2.new(180, 180), Rate = (14 + r * 3) * rate,
			})
			emitter(chest.outer, {
				Texture = TEX .. "smoke_main.dds", Color = ColorSequence.new(bright(col, 0.25), dark(col, 0.3)), LightEmission = 0.5,
				Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
				Size = numSeq(0.8 * S, 1.8 * S), Transparency = numSeq(0.82, 0.88, 1), Lifetime = NumberRange.new(4, 6),
				Speed = NumberRange.new(0.05 * S, 0.12 * S), SpreadAngle = Vector2.new(180, 180), Rate = 2.5 * rate,
				RotSpeed = NumberRange.new(-20, 20), Rotation = NumberRange.new(0, 360),
			})
		end
		-- the ring round its waist: a circle of lights (turned in step())
		if waist then
			local core = part(g.deco, Vector3.one * 0.2, col, Enum.Material.SmoothPlastic, 1)
			g.ring = core
			g.ringTilt = 0.32
			local R = waist.size.X * S * 1.25
			local n = 40
			for k = 1, n do
				local a = k / n * math.pi * 2
				local seg = part(g.deco, Vector3.new(0.09 * S, 0.06 * S, R * 2 * math.pi / n * 0.82), bright(col, 0.35), Enum.Material.Neon, (k % 2 == 0) and 0.15 or 0.4)
				weldTo(core, seg, CFrame.Angles(0, a, 0) * CFrame.new(R, 0, 0))
				local seg2 = part(g.deco, Vector3.new(0.05 * S, 0.04 * S, R * 1.32 * 2 * math.pi / n * 0.7), col, Enum.Material.Neon, 0.65)
				weldTo(core, seg2, CFrame.Angles(0, a + 0.05, 0) * CFrame.new(R * 1.32, 0, 0))
			end
			-- RARE: moons riding the ring
			if r >= 3 then
				for k = 1, 3 do
					local moon = part(g.deco, Vector3.one * 0.32 * S, bright(col, 0.1 * k), Enum.Material.Neon, 0.1, Enum.PartType.Ball)
					weldTo(core, moon, CFrame.Angles(0, k * math.pi * 2 / 3, 0) * CFrame.new(R * 1.16, 0, 0))
					local glow = part(g.deco, Vector3.one * 0.5 * S, col, Enum.Material.ForceField, 0, Enum.PartType.Ball)
					weldTo(core, glow, CFrame.Angles(0, k * math.pi * 2 / 3, 0) * CFrame.new(R * 1.16, 0, 0))
				end
			end
		end
		-- EPIC: a halo of stars over the head
		if r >= 4 and head then
			for k = 1, 14 do
				local h = part(g.deco, Vector3.one * 0.13 * S, bright(col, 0.6), Enum.Material.Neon, 0, Enum.PartType.Ball)
				table.insert(g.orbits, { part = h, ref = head.outer, radius = head.size.X * S * 0.85, height = head.size.Y * S * 0.75, speed = 0.9,
					phase = k * math.pi * 2 / 14, tilt = 0 })
			end
		end
		-- LEGENDARY: the heart beats (the chest pulses fast) and shock rings roll along the ground
		if r >= 5 then
			if chest then chest.pulse = { lo = 0.45, hi = 0.8, speed = 6.5, phase = 0 } end
			local a = Instance.new("Attachment"); a.Name = TAG; a.Parent = g.hrp
			a.Position = Vector3.new(0, -g.h0 + 0.2, 0)
			table.insert(g.extras, a)
			local e = emitter(a, {
				Texture = TEX .. "explosion01_shockwave_main.dds", Color = ColorSequence.new(bright(col, 0.3)), LightEmission = 1,
				Orientation = Enum.ParticleOrientation.VelocityPerpendicular, EmissionDirection = Enum.NormalId.Top, Speed = NumberRange.new(0.01),
				Size = numSeq(0.5 * S, 7 * S), Transparency = numSeq(0.2, 1), Lifetime = NumberRange.new(1.6), Rate = 0, LockedToPart = false,
			})
			g.beat = { att = a, e = e, last = 0 }
		end
		-- MYTHIC: a black hole behind the head, a pillar of light into the sky
		if r >= 6 and head then
			-- (a black disc ringed with light: the ring makes the dark read as a hole, even against the night sky)
			local hole = part(g.deco, Vector3.new(0.1 * S, 2.8 * S, 2.8 * S), Color3.fromRGB(6, 2, 12), Enum.Material.SmoothPlastic, 0, Enum.PartType.Cylinder)
			g.hole = hole
			for ringN, R in { 1.48 * S, 1.75 * S } do
				local n = 36
				for k = 1, n do
					local a = k / n * math.pi * 2
					local seg = part(g.deco, Vector3.new(0.06 * S, (ringN == 1 and 0.16 or 0.07) * S, R * 2 * math.pi / n * 0.9),
						ringN == 1 and bright(col, 0.55) or col, Enum.Material.Neon, ringN == 1 and ((k % 3 == 0) and 0.35 or 0) or 0.45)
					weldTo(hole, seg, CFrame.Angles(a, 0, 0) * CFrame.new(0, R, 0))
				end
			end
			local glow = part(g.deco, Vector3.new(0.05 * S, 4.2 * S, 4.2 * S), col, Enum.Material.ForceField, 0, Enum.PartType.Cylinder)
			weldTo(hole, glow, CFrame.new(-0.06 * S, 0, 0))
			if not low then
				local va = Instance.new("Attachment"); va.Name = TAG; va.Parent = hole
				emitter(va, {
					Texture = TEX .. "forcefield_vortex_main.dds", Color = ColorSequence.new(bright(col, 0.2), dark(col, 0.4)), LightEmission = 1,
					Orientation = Enum.ParticleOrientation.VelocityPerpendicular, EmissionDirection = Enum.NormalId.Right, Speed = NumberRange.new(0.01),
					Size = numSeq(4.4 * S, 1.2 * S), Transparency = numSeq(0.3, 1), Lifetime = NumberRange.new(2.2), Rate = 2.5,
					RotSpeed = NumberRange.new(-120, -60), Rotation = NumberRange.new(0, 360), LockedToPart = true,
				})
			end
			local a0 = Instance.new("Attachment"); a0.Name = TAG; a0.Parent = g.hrp; a0.Position = Vector3.new(0, -g.h0, 0)
			local a1 = Instance.new("Attachment"); a1.Name = TAG; a1.Parent = g.hrp; a1.Position = Vector3.new(0, -g.h0 + 22 * S, 0)
			local b = Instance.new("Beam")
			b.Name = TAG; b.Attachment0 = a0; b.Attachment1 = a1; b.FaceCamera = true; b.Segments = 1
			b.Width0 = 2.2 * S; b.Width1 = 0.8 * S; b.LightEmission = 1; b.LightInfluence = 0
			b.Texture = TEX .. "forcefield_glow_main.dds"; b.TextureMode = Enum.TextureMode.Stretch; b.TextureLength = 1
			b.Color = ColorSequence.new(bright(col, 0.4), col)
			b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(0.5, 0.65), NumberSequenceKeypoint.new(1, 1) })
			b.Parent = g.hrp
			g.pillar = b
			table.insert(g.extras, a0); table.insert(g.extras, a1); table.insert(g.extras, b)
		end
	end
	-- FISTS (jar)
	if stim then
		local col = stim.color
		local r = stim.rarity
		local fists = {} :: { Limb }
		for name, l in g.byName do if HANDS[name] then table.insert(fists, l) end end
		for i, f in fists do
			f.pulse = { lo = 0.35, hi = 0.75, speed = 3 + r * 0.4, phase = i }
			f.inner.Transparency = 0.5
			local l = Instance.new("PointLight")
			l.Name = TAG; l.Color = col; l.Range = math.min(60, 5 * S); l.Brightness = 1.6; l.Shadows = false
			l.Parent = f.outer
			if not low then
				emitter(f.outer, {
					Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(bright(col, 0.5), col), LightEmission = 1,
					Size = numSeq(0.12 * S, 0), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(0.5, 1),
					Speed = NumberRange.new(0.3 * S, 0.9 * S), SpreadAngle = Vector2.new(70, 70), Acceleration = Vector3.new(0, 0.4 * S, 0),
					Rate = (8 + r * 3) * rate, RotSpeed = NumberRange.new(-200, 200),
				})
			end
			-- UNCOMMON: comet trails behind the punches
			if r >= 2 then
				local a0 = Instance.new("Attachment"); a0.Name = TAG; a0.Position = Vector3.new(0, f.size.Y * S * 0.45, 0); a0.Parent = f.outer
				local a1 = Instance.new("Attachment"); a1.Name = TAG; a1.Position = Vector3.new(0, -f.size.Y * S * 0.45, 0); a1.Parent = f.outer
				local tr = Instance.new("Trail")
				tr.Name = TAG; tr.Attachment0 = a0; tr.Attachment1 = a1
				tr.Lifetime = 0.45; tr.MinLength = 0.1; tr.LightEmission = 1; tr.LightInfluence = 0; tr.FaceCamera = true
				tr.Color = ColorSequence.new(bright(col, 0.5), col); tr.Transparency = numSeq(0.2, 1); tr.WidthScale = numSeq(1, 0.1)
				tr.Parent = f.outer
			end
			-- RARE: plasma flames
			if r >= 3 and not low then
				emitter(f.outer, {
					Texture = TEX .. "fire_main.dds", Color = ColorSequence.new(bright(col, 0.6), col), LightEmission = 0.9,
					Size = numSeq(0.75 * S, 0.12 * S), Transparency = numSeq(0.25, 1), Lifetime = NumberRange.new(0.5, 0.9),
					Speed = NumberRange.new(0.2 * S, 0.5 * S), SpreadAngle = Vector2.new(25, 25), Acceleration = Vector3.new(0, 0.9 * S, 0),
					EmissionDirection = Enum.NormalId.Top, Rate = (10 + r * 2) * rate, RotSpeed = NumberRange.new(-90, 90), Rotation = NumberRange.new(0, 360),
				})
			end
			-- EPIC: rocks orbiting the fist
			if r >= 4 then
				for k = 1, 4 do
					local rock = part(g.deco, Vector3.new(0.3, 0.24, 0.27) * S * (0.8 + (k % 2) * 0.35), Color3.fromRGB(70, 66, 80), Enum.Material.Slate, 0)
					local edge = part(g.deco, rock.Size * 1.12, col, Enum.Material.ForceField, 0)
					weldTo(rock, edge, CFrame.new())
					table.insert(g.orbits, { part = rock, ref = f.outer, radius = f.size.X * S * 1.4, height = 0, speed = (i == 1 and 2.2 or -2.2) + k * 0.15,
						phase = k * math.pi / 2, tilt = 0.5 * ((k % 2) * 2 - 1) })
				end
			end
			-- MYTHIC: a black moon round each fist
			if r >= 6 then
				local moon = part(g.deco, Vector3.one * 0.55 * S, Color3.fromRGB(14, 10, 20), Enum.Material.SmoothPlastic, 0, Enum.PartType.Ball)
				local halo = part(g.deco, Vector3.one * 0.72 * S, bright(col, 0.2), Enum.Material.ForceField, 0, Enum.PartType.Ball)
				weldTo(moon, halo, CFrame.new())
				table.insert(g.orbits, { part = moon, ref = f.outer, radius = f.size.X * S * 2.2, height = f.size.Y * S * 0.2, speed = i == 1 and 1.3 or -1.3,
					phase = i * math.pi, tilt = 0.25 })
			end
		end
		-- LEGENDARY: lightning between the fists and down to the ground
		if r >= 5 and #fists >= 2 then
			local pairsOf = { { fists[1].outer, fists[2].outer }, { fists[1].outer, g.hrp }, { fists[2].outer, g.hrp } }
			for k, pr in pairsOf do
				for _ = 1, 2 do
					local a0 = Instance.new("Attachment"); a0.Name = TAG; a0.Parent = pr[1]
					local a1 = Instance.new("Attachment"); a1.Name = TAG; a1.Parent = pr[2]
					if pr[2] == g.hrp then a1.Position = Vector3.new(0, -g.h0, 0); table.insert(g.extras, a1) end
					local b = Instance.new("Beam")
					b.Name = TAG; b.Attachment0 = a0; b.Attachment1 = a1
					b.Color = ColorSequence.new(Color3.new(1, 1, 1), bright(col, 0.3)); b.LightEmission = 1; b.LightInfluence = 0
					b.Width0 = 0.07 * S; b.Width1 = 0.04 * S; b.Segments = 10; b.FaceCamera = true; b.Transparency = numSeq(0, 0.25)
					b.Parent = pr[1]
					table.insert(g.arcs, { beam = b, a0 = a0, a1 = a1 })
				end
				local _ = k
			end
		end
		-- MYTHIC: dark smoke off the arms
		if r >= 6 and not low then
			for name, l in g.byName do
				if ARMS[name] and not HANDS[name] then
					emitter(l.outer, {
						Texture = TEX .. "smoke_main.dds", Color = ColorSequence.new(Color3.fromRGB(16, 8, 24), dark(col, 0.5)), LightEmission = 0,
						Size = numSeq(0.4 * S, 1.1 * S), Transparency = numSeq(0.55, 1), Lifetime = NumberRange.new(1, 1.6),
						Speed = NumberRange.new(0.1 * S, 0.25 * S), SpreadAngle = Vector2.new(60, 60), Acceleration = Vector3.new(0, 0.3 * S, 0),
						Rate = 6 * rate, RotSpeed = NumberRange.new(-60, 60), Rotation = NumberRange.new(0, 360),
					})
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------
-- build (or remove) the giant of a player: stim / pot = the worn forms (any set; only the giant sets count)
function FG.set(p: Player, ch: Model, hrp: BasePart, stim: any, pot: any, level: string)
	FG.clear(p)
	local ss, sp = FG.scaleOf(stim), FG.scaleOf(pot)
	if not ss and not sp then return end
	if p:GetAttribute("InMatch") then return end -- (in a fight it would fill the room)
	local S = math.max(ss or 0, sp or 0)
	stim = ss and stim or nil
	pot = sp and pot or nil
	local folder = Instance.new("Folder")
	folder.Name = p.Name
	folder.Parent = root()
	local deco = Instance.new("Folder"); deco.Name = "Deco"; deco.Parent = folder
	-- the body's parts in one model, outlined as one glowing silhouette (a Highlight)
	local body = Instance.new("Model"); body.Name = "Body"; body.Parent = folder
	local hl = Instance.new("Highlight")
	hl.Name = TAG; hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.OutlineColor = bright(pot and pot.color or stim.color, 0.35); hl.OutlineTransparency = 0.05
	hl.FillTransparency = 1 -- (the outline only: a fill would tint the whole screen of anyone looking through it)
	hl.Parent = body
	local g: Giant = { player = p, folder = folder, deco = deco, hrp = hrp, h0 = rootHeight(ch, hrp), scale = S, born = os.clock(), decoOn = false,
		limbs = {}, byName = {}, orbits = {}, arcs = {}, ring = nil, ringTilt = 0, hole = nil, beat = nil, pillar = nil, level = level, shown = true,
		stim = stim, pot = pot, sized = false, extras = {} }
	-- colours: the arms are the jar's, the rest the potion's; the half without a giant form is a faint shadow
	local armCol = stim and stim.color or (pot and pot.color or Color3.new(1, 1, 1))
	local bodyCol = pot and pot.color or armCol
	for _, n in BODY do
		local limb = ch:FindFirstChild(n)
		if not (limb and limb:IsA("BasePart")) then continue end
		local isArm = ARMS[n] == true
		local real = (isArm and stim ~= nil) or (not isArm and pot ~= nil)
		local col = isArm and armCol or bodyCol
		local outer = copy(body, limb, bright(col, 0.25), Enum.Material.ForceField, real and 0 or 0.55)
		local inner = copy(body, limb, col, Enum.Material.Neon, real and 0.76 or 0.93)
		local L: Limb = { src = limb, outer = outer, inner = inner, size = limb.Size,
			pulse = real and { lo = 0.7, hi = 0.82, speed = 1.4, phase = #g.limbs * 0.4 } or nil, fade = 0 }
		table.insert(g.limbs, L)
		g.byName[n] = L
	end
	if #g.limbs == 0 then folder:Destroy(); return end
	giants[p] = g
end

-- the giant of a form just put on: a flash, rings, a rumble (Client/FormLook's burst plays on top)
function FG.burst(p: Player, at: Vector3, color: Color3, S: number)
	if (at - cam.CFrame.Position).Magnitude > FAR then return end
	local f = root()
	local ring = part(f, Vector3.new(0.4, 2, 2), color, Enum.Material.Neon, 0.2, Enum.PartType.Cylinder)
	ring.CFrame = CFrame.new(at) * CFrame.Angles(0, 0, math.pi / 2)
	TweenService:Create(ring, TweenInfo.new(1.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = Vector3.new(0.2, 9 * S, 9 * S), Transparency = 1 }):Play()
	-- a column of light shooting up out of the ground
	local col = part(f, Vector3.new(2, 1.4 * S, 1.4 * S), bright(color, 0.4), Enum.Material.Neon, 0.1, Enum.PartType.Cylinder)
	col.CFrame = CFrame.new(at) * CFrame.Angles(0, 0, math.pi / 2)
	TweenService:Create(col, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(30 * S, 0.25 * S, 0.25 * S), CFrame = CFrame.new(at + Vector3.new(0, 15 * S, 0)) * CFrame.Angles(0, 0, math.pi / 2), Transparency = 1 }):Play()
	local l = Instance.new("PointLight"); l.Color = color; l.Range = 60; l.Brightness = 5; l.Parent = col
	local a = Instance.new("Attachment"); a.Parent = ring
	local e = emitter(a, {
		Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(Color3.new(1, 1, 1), color), LightEmission = 1,
		Speed = NumberRange.new(2 * S, 5 * S), SpreadAngle = Vector2.new(180, 180), Size = numSeq(0.35 * S, 0), Transparency = numSeq(0, 1),
		Lifetime = NumberRange.new(0.8, 1.4), Rate = 0, Drag = 2, Acceleration = Vector3.new(0, -0.4 * S, 0),
	})
	e:Emit(90)
	task.delay(1.6, function() ring:Destroy(); col:Destroy() end)
	local _ = p
end

----------------------------------------------------------------------------------------------------------------------
-- does the segment a -> b (in a box's own space) go through the box of half size h?
local function slab(a: number, d: number, h: number, t0: number, t1: number): (number, number)
	if math.abs(d) < 1e-6 then
		if a < -h or a > h then return 1, 0 end
		return t0, t1
	end
	local u, v = (-h - a) / d, (h - a) / d
	if u > v then u, v = v, u end
	return math.max(t0, u), math.min(t1, v)
end
local function segHits(a: Vector3, b: Vector3, h: Vector3): boolean
	local d = b - a
	local t0, t1 = slab(a.X, d.X, h.X, 0, 1)
	if t0 > t1 then return false end
	t0, t1 = slab(a.Y, d.Y, h.Y, t0, t1)
	if t0 > t1 then return false end
	t0, t1 = slab(a.Z, d.Z, h.Z, t0, t1)
	return t0 <= t1
end

local arcT = 0
function FG.step(dt: number)
	if next(giants) == nil then return end
	local now = os.clock()
	local camPos = cam.CFrame.Position
	arcT += dt
	local rearc = arcT > 0.07
	if rearc then arcT = 0 end
	for p, g in giants do
		if not g.folder.Parent or not g.hrp.Parent then FG.clear(p); continue end
		local hrpCF = g.hrp.CFrame
		local near = (hrpCF.Position - camPos).Magnitude < FAR
		if near ~= g.shown then
			g.shown = near
			g.folder.Parent = near and root() or nil
		end
		if not near then continue end
		-- it rises out of the ground (scale 0 -> S), then the extras come on
		local u = math.clamp((now - g.born) / RISE, 0, 1)
		local k = 1 - (1 - u) ^ 3
		local s = math.max(0.05, g.scale * k)
		if u >= 1 and not g.decoOn then decorate(g) end
		local sizing = u < 1 or not g.sized
		local flat = hrpCF.LookVector * Vector3.new(1, 0, 1)
		if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) end
		flat = flat.Unit
		local anchor = hrpCF + Vector3.new(0, (s - 1) * g.h0 - (1 - k) * g.h0 * s, 0) - flat * (BACK * s)
		local eye = hrpCF.Position + Vector3.new(0, 1.2, 0) -- (its player's chest: never hidden by it)
		for _, L in g.limbs do
			local rel = hrpCF:ToObjectSpace(L.src.CFrame)
			local cf = anchor * CFrame.new(rel.Position * s) * rel.Rotation
			if sizing then
				L.outer.Size = L.size * s
				L.inner.Size = L.size * s * 0.94
			end
			L.outer.CFrame = cf
			L.inner.CFrame = cf
			if L.pulse then
				local w = 0.5 + 0.5 * math.sin(now * L.pulse.speed + L.pulse.phase)
				L.inner.Transparency = L.pulse.lo + (L.pulse.hi - L.pulse.lo) * w
			end
			-- (a part between this camera and its player, or round the camera, fades out)
			local half = L.outer.Size / 2 + Vector3.one * 1.2
			local want = segHits(cf:PointToObjectSpace(camPos), cf:PointToObjectSpace(eye), half) and 1 or 0
			if want ~= L.fade then
				L.fade = want > L.fade and math.min(want, L.fade + dt * 5) or math.max(want, L.fade - dt * 3)
				L.outer.LocalTransparencyModifier = L.fade * 0.88
				L.inner.LocalTransparencyModifier = L.fade
			end
		end
		if u >= 1 then g.sized = true end
		if not g.decoOn then continue end
		local waist = g.byName.LowerTorso or g.byName.Torso
		if g.ring and waist then
			g.ring.CFrame = CFrame.new(waist.outer.Position) * CFrame.fromAxisAngle(Vector3.new(flat.Z, 0, -flat.X), g.ringTilt) * CFrame.Angles(0, now * 0.35, 0)
		end
		local head = g.byName.Head
		if g.hole and head then
			g.hole.CFrame = CFrame.lookAt(head.outer.Position - flat * (head.size.Z * g.scale * 1.1), head.outer.Position - flat * 1000)
				* CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(now * 0.4, 0, 0)
		end
		for _, o in g.orbits do
			local ang = now * o.speed + o.phase
			local base = CFrame.new(o.ref.Position) * CFrame.Angles(o.tilt, 0, o.tilt * 0.5)
			o.part.CFrame = base * CFrame.new(math.cos(ang) * o.radius, o.height, math.sin(ang) * o.radius) * CFrame.Angles(ang, ang * 0.7, 0)
		end
		if rearc then
			for _, a in g.arcs do
				a.beam.Enabled = math.random() < 0.7
				a.beam.CurveSize0 = (math.random() - 0.5) * 2.5 * g.scale
				a.beam.CurveSize1 = (math.random() - 0.5) * 2.5 * g.scale
				a.a0.Position = Vector3.new((math.random() - 0.5), (math.random() - 0.5), (math.random() - 0.5)) * 0.4 * g.scale
			end
		end
		if g.beat then
			-- a heartbeat: two quick rings, then a pause
			local ph = (now * 0.9) % 1
			if (ph < 0.05 or (ph > 0.18 and ph < 0.23)) and now - g.beat.last > 0.15 then
				g.beat.last = now
				g.beat.e:Emit(1)
			end
		end
		if g.pillar then
			g.pillar.Width0 = (1.9 + 0.5 * (0.5 + 0.5 * math.sin(now * 2.2))) * g.scale
		end
	end
end

-- Studio photos: the scale of every giant (player attribute DebugGiantScale on the local player: a number = that scale)
if RunService:IsStudio() then
	lp:GetAttributeChangedSignal("DebugGiantScale"):Connect(function()
		local v = tonumber(lp:GetAttribute("DebugGiantScale"))
		if not v then return end
		for _, g in giants do
			g.scale = v
			g.born = os.clock()
			g.decoOn = false
			g.deco:ClearAllChildren()
			table.clear(g.orbits); table.clear(g.arcs)
			g.ring = nil; g.hole = nil; g.beat = nil; g.pillar = nil; g.sized = false
			for _, x in g.extras do x:Destroy() end
			table.clear(g.extras)
			for _, L in g.limbs do L.outer:ClearAllChildren(); L.pulse = nil end
		end
	end)
end

return FG
