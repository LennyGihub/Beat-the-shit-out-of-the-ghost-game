--!strict
-- EVERY MAP'S FORMS LOOK BETTER THAN THE LAST (the user, 2026-11-20: "make progressive better visual for EVERY
-- potion / jar, progressive better for each map"). On top of Client/FormLook's look (which grows with rarity, and is
-- itself stronger map after map: FormLook's tier boost), each campaign map's forms add their own layer round the
-- wearer, bigger and richer map after map (and, in a map, with the form's rarity):
--   CAMP HOLLOWMERE  - potion: FIREFLIES drifting round you (RARE: embers at your feet; LEGENDARY: a ring of little
--                      campfire flames on the ground); jar: EMBERS rising off the fists.
--   MOONLIGHT CARNIVAL - potion: a RING OF MARQUEE BULBS turning round your waist, the lights chasing each other (RARE:
--                      a second ring over your head; EPIC: a spotlight from above; LEGENDARY: confetti; MYTHIC:
--                      fireworks); jar: a ring of bulbs round each fist and ribbon streamers behind the punches.
--   BLACKWATER HARBOR - potion: a WATER VORTEX, three rings of water and foam spiralling up round you (bubbles; EPIC:
--                      spray; LEGENDARY: a tide ring rolling out along the ground); jar: water rings whirling round the
--                      forearms, splashing (EPIC: a ball of water round each fist).
--   THE ASHEN ABBEY  - potion: WINGS OF LIGHT on your back, slowly beating, 6 to 15 studs across (a halo; feathers of
--                      light drifting down; MYTHIC: a second pair); jar: holy fire on the fists and a ring of
--                      stained-glass shards round each one.
--   THE BLACK MOON   - the GIANT (Client/FormGiant).
-- In the park only (never while the wearer is in a fight). Client only, every client draws every player's.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Forms = require(RS.Shared.Forms)

local FS = {}
local cam = workspace.CurrentCamera
local TAG = "FormSet"
local TEX = "rbxasset://textures/particles/"
local FAR = 260

type Spin = { core: BasePart, ref: BasePart, offset: CFrame, speed: number, flat: boolean }
type Orbit = { part: BasePart, ref: BasePart, radius: number, height: number, speed: number, phase: number, bob: number }
type Chase = { parts: { BasePart }, lit: number, dim: number, cols: { Color3 }? }
type Wing = { core: BasePart, ref: BasePart, side: number, scale: number, feathers: { BasePart } }
type Layer = {
	player: Player, folder: Folder, hrp: BasePart, shown: boolean, spins: { Spin }, orbits: { Orbit }, chases: { Chase },
	wings: { Wing }, extras: { Instance }, pulses: { { e: ParticleEmitter, every: number, n: number, last: number } }, wingFade: number,
}
local layers = {} :: { [Player]: Layer }
local holder: Folder? = nil

local function bright(c: Color3, k: number): Color3 return c:Lerp(Color3.new(1, 1, 1), k) end
local function numSeq(a: number, b: number, c: number?): NumberSequence
	if c then return NumberSequence.new({ NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(0.5, b), NumberSequenceKeypoint.new(1, c) }) end
	return NumberSequence.new(a, b)
end
local function root(): Folder
	if holder and holder.Parent then return holder end
	local f = Instance.new("Folder")
	f.Name = "FormSets"
	f.Parent = workspace
	holder = f
	return f
end

-- the set's place in the campaign: 1 (Camp) .. 5 (Moon)
function FS.tierOf(fm: any): number
	if not fm then return 1 end
	return table.find(Forms.sets, fm.set) or 1
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
local function weldTo(base: BasePart, p: BasePart, cf: CFrame)
	p.Anchored = false; p.Massless = true
	p.CFrame = base.CFrame * cf
	local w = Instance.new("WeldConstraint"); w.Part0 = base; w.Part1 = p; w.Parent = p
end
local function emitter(parent: Instance, props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Name = TAG
	e.LightInfluence = 0
	for k, v in props do (e :: any)[k] = v end
	e.Parent = parent
	return e
end
-- an attachment on the wearer's own body (cleaned up with the layer)
local function att(L: Layer, parent: BasePart, pos: Vector3): Attachment
	local a = Instance.new("Attachment"); a.Name = TAG; a.Position = pos; a.Parent = parent
	table.insert(L.extras, a)
	return a
end
-- a ring of n pieces round an anchored core (turned in step)
local function ring(L: Layer, ref: BasePart, offset: CFrame, speed: number, n: number, radius: number, make: (k: number) -> BasePart, tilt: number?): (BasePart, { BasePart })
	local core = part(L.folder, Vector3.one * 0.2, Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	core.CFrame = ref.CFrame * offset
	local parts = {}
	for k = 1, n do
		local a = k / n * math.pi * 2
		local p = make(k)
		weldTo(core, p, CFrame.Angles(0, a, 0) * CFrame.new(radius, 0, 0) * CFrame.Angles(0, 0, tilt or 0))
		table.insert(parts, p)
	end
	table.insert(L.spins, { core = core, ref = ref, offset = offset, speed = speed, flat = true })
	return core, parts
end

function FS.clear(p: Player)
	local L = layers[p]
	if L then
		layers[p] = nil
		L.folder:Destroy()
		for _, x in L.extras do x:Destroy() end
	end
end

local function bp(ch: Model, n: string): BasePart?
	local x = ch:FindFirstChild(n)
	return (x and x:IsA("BasePart")) and x or nil
end
local function hands(ch: Model): { BasePart }
	local out = {}
	for _, n in { "RightHand", "LeftHand", "Right Arm", "Left Arm" } do
		local h = bp(ch, n)
		if h then table.insert(out, h) end
	end
	return out
end
local function feetY(ch: Model, hrp: BasePart): number
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then return -(hum.HipHeight + hrp.Size.Y / 2) end
	return -(hrp.Size.Y / 2 + 2)
end

----------------------------------------------------------------------------------------------------------------------
-- CAMP HOLLOWMERE: fireflies, embers, campfire flames
local function campBody(L: Layer, ch: Model, hrp: BasePart, fm: any, low: boolean)
	local r, col = fm.rarity, fm.color
	local fly = Color3.fromRGB(220, 255, 120):Lerp(col, 0.45)
	local n = 4 + r
	for k = 1, n do
		local f = part(L.folder, Vector3.one * (0.2 + r * 0.02), bright(fly, 0.3), Enum.Material.Neon, 0, Enum.PartType.Ball)
		if k <= 2 then
			local l = Instance.new("PointLight"); l.Name = TAG; l.Color = fly; l.Range = 5 + r; l.Brightness = 0.8; l.Shadows = false; l.Parent = f
		end
		table.insert(L.orbits, { part = f, ref = hrp, radius = 2.3 + (k % 3) * 0.45, height = -1.2 + (k % 4) * 0.9, speed = 0.6 + (k % 3) * 0.25 * ((k % 2) * 2 - 1),
			phase = k * 2.4, bob = 0.5 })
	end
	if low then return end
	local fy = feetY(ch, hrp)
	if r >= 3 then
		emitter(att(L, hrp, Vector3.new(0, fy + 0.2, 0)), {
			Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 200, 90), col), LightEmission = 1,
			Shape = Enum.ParticleEmitterShape.Disc, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume, EmissionDirection = Enum.NormalId.Top,
			Size = numSeq(0.18, 0), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(1, 2.5),
			Acceleration = Vector3.new(0, 1, 0), Rate = 4 + r * 1.5, SpreadAngle = Vector2.new(20, 20),
		})
	end
	-- LEGENDARY: a ring of little campfire flames on the ground round you
	if r >= 5 then
		for k = 1, 6 do
			local a = k / 6 * math.pi * 2
			emitter(att(L, hrp, Vector3.new(math.cos(a) * 2.8, fy + 0.15, math.sin(a) * 2.8)), {
				Texture = TEX .. "fire_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 210, 120), bright(col, 0.2)), LightEmission = 0.9,
				Size = numSeq(0.7, 0.1), Transparency = numSeq(0.2, 1), Lifetime = NumberRange.new(0.4, 0.7), Speed = NumberRange.new(1, 2),
				EmissionDirection = Enum.NormalId.Top, Rate = 12, Rotation = NumberRange.new(0, 360), LockedToPart = false,
			})
		end
	end
end
local function campFist(L: Layer, ch: Model, fm: any, low: boolean)
	if low then return end
	local r, col = fm.rarity, fm.color
	for _, h in hands(ch) do
		emitter(att(L, h, Vector3.zero), {
			Texture = TEX .. "fire_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 190, 90), col), LightEmission = 1,
			Size = numSeq(0.22 + r * 0.03, 0), Transparency = numSeq(0.1, 1), Lifetime = NumberRange.new(0.7, 1.3), Speed = NumberRange.new(0.8, 1.8),
			Acceleration = Vector3.new(0, 2.5, 0), Rate = 5 + r * 1.5, SpreadAngle = Vector2.new(40, 40), LockedToPart = false,
		})
	end
end

----------------------------------------------------------------------------------------------------------------------
-- THE MOONLIGHT CARNIVAL: marquee bulbs, a spotlight, confetti, fireworks, streamers
local WARM = Color3.fromRGB(255, 236, 190)
local function bulbs(L: Layer, ref: BasePart, offset: CFrame, speed: number, n: number, radius: number, size: number, col: Color3)
	local cols = {}
	local _, parts = ring(L, ref, offset, speed, n, radius, function(k)
		local c = (k % 2 == 0) and bright(col, 0.25) or WARM
		table.insert(cols, c)
		return part(L.folder, Vector3.one * size, c, Enum.Material.Neon, 0, Enum.PartType.Ball)
	end)
	table.insert(L.chases, { parts = parts, lit = 0, dim = 0.6, cols = cols })
end
local function carnBody(L: Layer, ch: Model, hrp: BasePart, fm: any, low: boolean)
	local r, col = fm.rarity, fm.color
	local k = (r - 1) / 5
	local R = 3.4 + 1.8 * k
	bulbs(L, hrp, CFrame.new(0, -0.6, 0), 0.5, 14 + r * 2, R, 0.36 + 0.05 * k, col)
	local l = Instance.new("PointLight"); l.Name = TAG; l.Color = col; l.Range = 10 + r * 1.5; l.Brightness = 1; l.Shadows = false
	l.Parent = L.spins[#L.spins].core
	-- RARE: a second, smaller ring over the head, the other way round
	if r >= 3 then bulbs(L, hrp, CFrame.new(0, 3.4, 0), -0.7, 10 + r, R * 0.62, 0.3, col) end
	local fy = feetY(ch, hrp)
	-- EPIC: a spotlight from above
	if r >= 4 then
		local a0 = att(L, hrp, Vector3.new(0, fy + 16, 0))
		local a1 = att(L, hrp, Vector3.new(0, fy + 0.1, 0))
		local b = Instance.new("Beam")
		b.Name = TAG; b.Attachment0 = a0; b.Attachment1 = a1; b.FaceCamera = true; b.Segments = 1
		b.Width0 = 0.6; b.Width1 = R * 1.6; b.LightEmission = 1; b.LightInfluence = 0
		b.Texture = TEX .. "forcefield_glow_main.dds"; b.TextureMode = Enum.TextureMode.Stretch
		b.Color = ColorSequence.new(WARM, bright(col, 0.5)); b.Transparency = numSeq(0.55, 0.8)
		b.Parent = hrp
		table.insert(L.extras, b)
	end
	if low then return end
	-- LEGENDARY: confetti falling round you
	if r >= 5 then
		local c = part(L.folder, Vector3.new(R * 2, 0.2, R * 2), col, Enum.Material.SmoothPlastic, 1)
		table.insert(L.spins, { core = c, ref = hrp, offset = CFrame.new(0, 7, 0), speed = 0, flat = true })
		emitter(c, {
			Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, col), ColorSequenceKeypoint.new(0.5, WARM),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 220, 255)) }), LightEmission = 0.8,
			EmissionDirection = Enum.NormalId.Bottom, Size = numSeq(0.28, 0.2), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(2.5, 3.5),
			Speed = NumberRange.new(1, 2), Rate = 10, RotSpeed = NumberRange.new(-300, 300), Rotation = NumberRange.new(0, 360), SpreadAngle = Vector2.new(30, 30),
		})
	end
	-- MYTHIC: fireworks over your head every few seconds
	if r >= 6 then
		local a = att(L, hrp, Vector3.new(0, 9, 0))
		local e = emitter(a, {
			Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(Color3.new(1, 1, 1), col), LightEmission = 1,
			Size = numSeq(0.5, 0), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(0.9, 1.4), Speed = NumberRange.new(9, 13),
			SpreadAngle = Vector2.new(180, 180), Drag = 3, Acceleration = Vector3.new(0, -4, 0), Rate = 0, LockedToPart = false,
		})
		table.insert(L.pulses, { e = e, every = 2.6, n = 60, last = 0 })
	end
end
local function carnFist(L: Layer, ch: Model, fm: any, low: boolean)
	local r, col = fm.rarity, fm.color
	for i, h in hands(ch) do
		bulbs(L, h, CFrame.new(0, 0.15, 0), i == 1 and 2.5 or -2.5, 6 + (r >= 4 and 2 or 0), math.max(h.Size.X, h.Size.Z) * 0.5 + 0.75, 0.2, col)
		L.spins[#L.spins].flat = false -- (round the fist itself: it turns with the hand)
		if r >= 2 then
			local a0 = att(L, h, Vector3.new(0, h.Size.Y * 0.5, 0))
			local a1 = att(L, h, Vector3.new(0, -h.Size.Y * 0.5, 0))
			local tr = Instance.new("Trail")
			tr.Name = TAG; tr.Attachment0 = a0; tr.Attachment1 = a1; tr.Lifetime = 0.5; tr.LightEmission = 1; tr.LightInfluence = 0; tr.FaceCamera = true
			tr.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, WARM), ColorSequenceKeypoint.new(0.5, col), ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 220, 255)) })
			tr.Transparency = numSeq(0.1, 1); tr.WidthScale = numSeq(1.6, 0.2)
			tr.Parent = h
			table.insert(L.extras, tr)
		end
	end
	local _ = low
end

----------------------------------------------------------------------------------------------------------------------
-- BLACKWATER HARBOR: a water vortex, bubbles, spray, a tide ring; water round the arms
local SEA = Color3.fromRGB(60, 170, 200)
local FOAM = Color3.fromRGB(225, 245, 250)
local function harbBody(L: Layer, ch: Model, hrp: BasePart, fm: any, low: boolean)
	local r, col = fm.rarity, fm.color
	local k = (r - 1) / 5
	local water = SEA:Lerp(col, 0.5)
	local fy = feetY(ch, hrp)
	local R0 = 3.4 + 2.2 * k
	local H = 7 + 5 * k
	-- three rings of water and foam, narrower going up (a funnel), each turning a little faster
	for ringN, def in { { 0.5, 1 }, { H * 0.5, 0.78 }, { H, 0.58 } } do
		local R = R0 * def[2]
		local n = 14
		local chord = R * 2 * math.pi / n * 0.95
		ring(L, hrp, CFrame.new(0, fy + def[1], 0), (1.1 + ringN * 0.45), n, R, function(kk)
			local wv = part(L.folder, Vector3.new(0.25, 1.1 + 0.5 * k, chord), water, Enum.Material.Glass, 0.45)
			wv.Reflectance = 0.25
			local foam = part(L.folder, Vector3.new(0.3, 0.16, chord * 0.9), FOAM, Enum.Material.Neon, (kk % 2 == 0) and 0.2 or 0.45)
			weldTo(wv, foam, CFrame.new(0, wv.Size.Y / 2, 0))
			return wv
		end, 0.45)
	end
	local l = Instance.new("PointLight"); l.Name = TAG; l.Color = water; l.Range = 12 + r * 2; l.Brightness = 1; l.Shadows = false
	l.Parent = L.spins[2].core
	if low then return end
	-- bubbles rising inside it
	local col2 = part(L.folder, Vector3.new(R0 * 1.4, H, R0 * 1.4), water, Enum.Material.SmoothPlastic, 1)
	table.insert(L.spins, { core = col2, ref = hrp, offset = CFrame.new(0, fy + H / 2, 0), speed = 0, flat = true })
	emitter(col2, {
		Texture = TEX .. "forcefield_glow_main.dds", Color = ColorSequence.new(FOAM, water), LightEmission = 0.6,
		Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume, EmissionDirection = Enum.NormalId.Top,
		Size = numSeq(0.35, 0.15), Transparency = numSeq(0.2, 1), Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(1.5, 3),
		Rate = 8 + r * 2, SpreadAngle = Vector2.new(15, 15),
	})
	-- EPIC: spray off the top ring
	if r >= 4 then
		emitter(L.spins[3].core, {
			Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(FOAM, water), LightEmission = 0.7,
			Shape = Enum.ParticleEmitterShape.Disc, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward,
			Size = numSeq(0.3, 0.05), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(0.7, 1.1), Speed = NumberRange.new(4, 7),
			Acceleration = Vector3.new(0, -14, 0), Rate = 14 + r * 3, EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(30, 30),
		})
	end
	-- LEGENDARY: a tide ring rolling out along the ground every couple of seconds
	if r >= 5 then
		local e = emitter(att(L, hrp, Vector3.new(0, fy + 0.15, 0)), {
			Texture = TEX .. "explosion01_shockwave_main.dds", Color = ColorSequence.new(FOAM, water), LightEmission = 0.8,
			Orientation = Enum.ParticleOrientation.VelocityPerpendicular, EmissionDirection = Enum.NormalId.Top, Speed = NumberRange.new(0.01),
			Size = numSeq(R0, R0 * 5), Transparency = numSeq(0.15, 1), Lifetime = NumberRange.new(1.8), Rate = 0, LockedToPart = false,
		})
		table.insert(L.pulses, { e = e, every = 2.2, n = 1, last = 0 })
	end
end
local function harbFist(L: Layer, ch: Model, fm: any, low: boolean)
	local r, col = fm.rarity, fm.color
	local water = SEA:Lerp(col, 0.5)
	local arms = {}
	for _, n in { "RightLowerArm", "LeftLowerArm" } do
		local a = bp(ch, n)
		if a then table.insert(arms, a) end
	end
	if #arms == 0 then arms = hands(ch) end
	for i, a in arms do
		local R = math.max(a.Size.X, a.Size.Z) * 0.5 + 0.6
		for j = 1, 2 do
			ring(L, a, CFrame.new(0, (j - 1.5) * a.Size.Y * 0.6, 0), (i == 1 and 4 or -4) * (j == 1 and 1 or -1.3), 8, R + j * 0.12, function()
				return part(L.folder, Vector3.new(0.12, 0.3, R * 0.85), water, Enum.Material.Glass, 0.3)
			end, 0.5)
			L.spins[#L.spins].flat = false
		end
	end
	for _, h in hands(ch) do
		if r >= 4 then
			local orb = part(L.folder, Vector3.one * (math.max(h.Size.X, h.Size.Y) + 1), water, Enum.Material.Glass, 0.6, Enum.PartType.Ball)
			orb.Reflectance = 0.3
			table.insert(L.spins, { core = orb, ref = h, offset = CFrame.new(), speed = 1.5, flat = false })
		end
		if not low then
			emitter(att(L, h, Vector3.zero), {
				Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(FOAM, water), LightEmission = 0.7,
				Size = numSeq(0.2, 0.05), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(0.5, 0.9), Speed = NumberRange.new(2, 4),
				SpreadAngle = Vector2.new(90, 90), Acceleration = Vector3.new(0, -12, 0), Rate = 6 + r * 2, LockedToPart = false,
			})
		end
	end
end

----------------------------------------------------------------------------------------------------------------------
-- THE ASHEN ABBEY: wings of light, a halo, drifting feathers; holy fire and stained glass on the fists
local GLASS = { Color3.fromRGB(220, 60, 50), Color3.fromRGB(60, 110, 230), Color3.fromRGB(250, 200, 70), Color3.fromRGB(80, 190, 110), Color3.fromRGB(170, 80, 220) }
local function wing(L: Layer, ref: BasePart, side: number, scale: number, col: Color3, up: number, low: boolean)
	local core = part(L.folder, Vector3.one * 0.2, col, Enum.Material.SmoothPlastic, 1)
	core.CFrame = ref.CFrame
	local w: Wing = { core = core, ref = ref, side = side, scale = scale, feathers = {} }
	local n = 6
	for i = 0, n - 1 do
		local len = scale * (1 - i * 0.11)
		local th = -side * math.rad(28 + i * 15 + up) -- (from up-and-out to down-and-out)
		local cf = CFrame.Angles(0, 0, th) * CFrame.Angles(math.rad(12 + i * 2), 0, 0) * CFrame.new(0, len / 2, 0)
		local glowF = part(L.folder, Vector3.new(0.5 + scale * 0.06, len * 1.04, 0.2), col, Enum.Material.ForceField, 0)
		weldTo(core, glowF, cf)
		local f = part(L.folder, Vector3.new(0.32 + scale * 0.04, len, 0.1), bright(col, 0.55), Enum.Material.Neon, 0.25)
		weldTo(core, f, cf)
		table.insert(w.feathers, glowF); table.insert(w.feathers, f)
		if i == 2 and not low then
			emitter(f, {
				Texture = TEX .. "sparkles_main.dds", Color = ColorSequence.new(Color3.new(1, 1, 1), col), LightEmission = 1,
				Size = numSeq(0.25, 0), Transparency = numSeq(0, 1), Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(0.3, 0.8),
				Acceleration = Vector3.new(0, -1.5, 0), Rate = 6, SpreadAngle = Vector2.new(180, 180), RotSpeed = NumberRange.new(-100, 100),
			})
		end
	end
	table.insert(L.wings, w)
end
local function abbBody(L: Layer, ch: Model, hrp: BasePart, fm: any, low: boolean)
	local r, col = fm.rarity, fm.color
	local k = (r - 1) / 5
	local back = bp(ch, "UpperTorso") or bp(ch, "Torso") or hrp
	local S = 3 + 4.5 * k -- (the longest feather: 3 .. 7.5 studs, wings ~6 .. 15 studs across)
	for _, side in { 1, -1 } do wing(L, back, side, S, col, 0, low) end
	if r >= 6 then for _, side in { 1, -1 } do wing(L, back, side, S * 0.62, bright(col, 0.3), 55, low) end end
	-- the halo
	local head = bp(ch, "Head")
	if head then
		local _, parts = ring(L, head, CFrame.new(0, head.Size.Y * 0.5 + 0.7, 0), 0.6, 14, 0.95 + 0.25 * k, function()
			return part(L.folder, Vector3.new(0.12, 0.1, 0.42), bright(col, 0.6), Enum.Material.Neon, 0)
		end)
		local _ = parts
	end
	local l = Instance.new("PointLight"); l.Name = TAG; l.Color = col; l.Range = 12 + r * 2; l.Brightness = 1.2; l.Shadows = false
	l.Parent = L.wings[1].core
	local _ = hrp
end
local function abbFist(L: Layer, ch: Model, fm: any, low: boolean)
	local r, col = fm.rarity, fm.color
	for i, h in hands(ch) do
		local R = math.max(h.Size.X, h.Size.Z) * 0.5 + 1
		ring(L, h, CFrame.new(0, 0.1, 0), i == 1 and 1.8 or -1.8, 6 + (r >= 4 and 2 or 0), R, function(kk)
			return part(L.folder, Vector3.new(0.08, 0.45, 0.3), GLASS[(kk - 1) % #GLASS + 1]:Lerp(col, 0.25), Enum.Material.Neon, 0.15)
		end, 0.3)
		if not low then
			emitter(att(L, h, Vector3.zero), {
				Texture = TEX .. "fire_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 240, 200), bright(col, 0.2)), LightEmission = 1,
				Size = numSeq(1.1 + r * 0.12, 0.2), Transparency = numSeq(0.2, 1), Lifetime = NumberRange.new(0.4, 0.7), Speed = NumberRange.new(1.5, 3),
				EmissionDirection = Enum.NormalId.Top, Rate = 16 + r * 3, Rotation = NumberRange.new(0, 360), Acceleration = Vector3.new(0, 5, 0), LockedToPart = false,
			})
		end
	end
end

----------------------------------------------------------------------------------------------------------------------
local BODY = { campBody, carnBody, harbBody, abbBody }
local FIST = { campFist, carnFist, harbFist, abbFist }

-- build (or remove) a player's layers: stim / pot = the worn forms (the Moon's are Client/FormGiant's)
function FS.set(p: Player, ch: Model, hrp: BasePart, stim: any, pot: any, level: string)
	FS.clear(p)
	if p:GetAttribute("InMatch") then return end
	local ts, tp = stim and FS.tierOf(stim) or 0, pot and FS.tierOf(pot) or 0
	local fb = FIST[ts]
	local bb = BODY[tp]
	if not fb and not bb then return end
	local folder = Instance.new("Folder")
	folder.Name = p.Name
	folder.Parent = root()
	local L: Layer = { player = p, folder = folder, hrp = hrp, shown = true, spins = {}, orbits = {}, chases = {}, wings = {}, extras = {}, pulses = {}, wingFade = 0 }
	layers[p] = L
	local low = level == "low"
	local ok, err = pcall(function()
		if bb then bb(L, ch, hrp, pot, low) end
		if fb then fb(L, ch, stim, low) end
	end)
	if not ok then warn("[FormSets] " .. tostring(err)); FS.clear(p) end
end

local chaseT = 0
local step0 = 0
function FS.step(dt: number)
	if next(layers) == nil then return end
	local now = os.clock()
	local camPos = cam.CFrame.Position
	chaseT += dt
	local chase = chaseT > 0.12
	if chase then chaseT = 0; step0 += 1 end
	for p, L in layers do
		if not L.folder.Parent or not L.hrp.Parent then FS.clear(p); continue end
		local hpos = L.hrp.Position
		local near = (hpos - camPos).Magnitude < FAR
		if near ~= L.shown then
			L.shown = near
			L.folder.Parent = near and root() or nil
		end
		if not near then continue end
		for _, s in L.spins do
			local base: CFrame
			if s.flat then
				-- (level, round its part's position: turns with the player but never tilts)
				local cf = s.ref.CFrame
				local look = cf.LookVector * Vector3.new(1, 0, 1)
				if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
				base = CFrame.lookAt(cf.Position, cf.Position + look) * CFrame.new(s.offset.Position)
			else
				base = s.ref.CFrame * s.offset
			end
			s.core.CFrame = base * CFrame.Angles(0, now * s.speed, 0)
		end
		for _, o in L.orbits do
			local a = now * o.speed + o.phase
			o.part.CFrame = CFrame.new(o.ref.Position + Vector3.new(math.cos(a) * o.radius, o.height + math.sin(now * 1.3 + o.phase) * o.bob, math.sin(a) * o.radius))
		end
		if chase then
			for _, c in L.chases do
				for i, b in c.parts do b.Transparency = ((i + step0) % 3 == 0) and 0 or c.dim end
			end
		end
		-- the wings beat slowly; seen from behind they fade (they would hide their player)
		if #L.wings > 0 then
			local behind = (camPos - hpos):Dot(L.hrp.CFrame.LookVector) < 0 and (camPos - hpos).Magnitude < 40
			local want = behind and 0.6 or 0
			if math.abs(L.wingFade - want) > 0.01 then
				L.wingFade += (want - L.wingFade) * math.min(1, dt * 6)
				for _, w in L.wings do for _, f in w.feathers do f.LocalTransparencyModifier = L.wingFade end end
			end
			local beat = math.sin(now * 1.7)
			for _, w in L.wings do
				w.core.CFrame = w.ref.CFrame * CFrame.new(w.side * 0.35, 0.35, w.ref.Size.Z * 0.5 + 0.15)
					* CFrame.Angles(0, -w.side * math.rad(18 + beat * 14), w.side * math.rad(beat * 6))
			end
		end
		for _, pu in L.pulses do
			if now - pu.last > pu.every then pu.last = now; pu.e:Emit(pu.n) end
		end
	end
end

return FS
