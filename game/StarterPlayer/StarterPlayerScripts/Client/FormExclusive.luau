--!strict
-- THE EXCLUSIVE FORMS' OWN LOOK (Shared/Forms exclusive = true: a CODE gives them, Server/Codes), drawn on top of
-- the look Client/FormLook gives their rarity:
--   ALPHA GLITCH (code ALPHA TESTER, a fist form): a hologram that doesn't render right. The whole fist look drifts
--   blue -> violet -> magenta and back; two split images of each arm (one red, one cyan: a colour split) shiver beside it
--   and now and then jump away (a glitch, the pixels flare); square pixels blink in and out round the fists and the
--   forearms; a scan line runs up each arm from the fist to the shoulder. Putting it on throws a cloud of pixels.
--   In a fight your first-person fists get the split images and the colour drift too.
-- FormLook calls FX.build (from buildFist), FX.step (every frame), FX.burst (put on), FX.buildVM / FX.stepVM /
-- FX.clearVM (first-person fists). Everything here is named like FormLook's parts ("FormFx"), so its clean-up removes it.
local TweenService = game:GetService("TweenService")

local FX = {}
local cam = workspace.CurrentCamera
local TAG = "FormFx"
local FAR = 160
local WHITE = Color3.new(1, 1, 1)

type Ghost = { weld: Weld, part: BasePart, sign: number }
type Pixel = { part: BasePart, ref: BasePart, t: number, off: CFrame }
type Scan = { part: BasePart, chain: { BasePart }, period: number, phase: number }
type Tint = { inst: Instance, orig: any }
type Glitch = {
	folder: Instance, ref: BasePart, c1: Color3, c2: Color3, ghosts: { Ghost }, pixels: { Pixel }, scans: { Scan },
	tints: { Tint }, jitT: number, tintT: number, jumpAt: number, jumpUntil: number,
}
local active = {} :: { Glitch }
local rng = Random.new()

-- the colour drift: a hue offset that swings 0.08 .. 0.34 and back (blue -> violet -> magenta for a cyan form; never
-- the split images' own cyan / red, so they always stand out)
local function drift(now: number): number return 0.08 + 0.13 * (1 - math.cos(now * 0.8)) end
function FX.shift(c: Color3, dh: number): Color3
	local h, s, v = c:ToHSV()
	return Color3.fromHSV((h + dh) % 1, s, v)
end
local function shiftSeq(cs: ColorSequence, dh: number): ColorSequence
	local kps = {}
	for _, kp in cs.Keypoints do table.insert(kps, ColorSequenceKeypoint.new(kp.Time, FX.shift(kp.Value, dh))) end
	return ColorSequence.new(kps)
end

-- the split images' colours: cyan and red
local SPLIT1, SPLIT2 = Color3.fromRGB(60, 240, 255), Color3.fromRGB(255, 40, 70)
local function colors(fm: any): (Color3, Color3)
	return fm.color, fm.color2 or Color3.fromRGB(255, 60, 210)
end

local function plain(p: BasePart)
	p.Name = TAG
	p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false; p.Massless = true
end

-- a copy of a limb's shape (a MeshPart clone with nothing inside, or a block)
local function copyOf(limb: BasePart): BasePart
	local s: BasePart? = nil
	if limb:IsA("MeshPart") then
		local ok, c = pcall(function() return limb:Clone() end)
		if ok and c then
			c:ClearAllChildren()
			pcall(function() (c :: any).TextureID = "" end)
			s = c
		end
	end
	if not s then
		local p = Instance.new("Part")
		p.Shape = (limb :: any).Shape or Enum.PartType.Block
		s = p
	end
	local x = s :: BasePart
	plain(x)
	x.Reflectance = 0
	x.LocalTransparencyModifier = 0
	return x
end

local function cube(parent: Instance, size: number, color: Color3, transp: number): Part
	local p = Instance.new("Part")
	plain(p)
	p.Size = Vector3.one * size; p.Color = color; p.Material = Enum.Material.Neon; p.Transparency = transp
	p.Anchored = true
	p.Parent = parent
	return p
end

-- the colours of everything the fist look already has (tinted by the drift)
local function tintable(d: Instance): Tint?
	if d:IsA("BasePart") then return { inst = d, orig = d.Color } end
	if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then return { inst = d, orig = (d :: any).Color } end
	if d:IsA("Light") then return { inst = d, orig = d.Color } end
	return nil
end

-- the glitch look on a character. arms = the covered limbs of each arm, fist first ({ hand, lower?, upper? })
function FX.build(folder: Instance, ch: Model, hrp: BasePart, fm: any, level: string, arms: { { BasePart } })
	if fm.id ~= "AlphaGlitch" then return end
	local c1, c2 = colors(fm)
	local g: Glitch = { folder = folder, ref = hrp, c1 = c1, c2 = c2, ghosts = {}, pixels = {}, scans = {}, tints = {},
		jitT = 0, tintT = 0, jumpAt = os.clock() + rng:NextNumber(1, 2.5), jumpUntil = 0 }
	-- (the fist look built so far: everything FormLook tagged on this character)
	for _, d in ch:GetDescendants() do
		if d.Name == TAG then
			local t = tintable(d)
			if t then table.insert(g.tints, t) end
		end
	end
	for _, chain in arms do
		-- the split images: a cyan copy and a magenta copy of every covered limb, welded a little to each side
		for _, limb in chain do
			for k, col in { SPLIT1, SPLIT2 } do
				local gp = copyOf(limb)
				gp.Size = limb.Size * 1.04 + Vector3.one * 0.02
				gp.Color = col; gp.Material = Enum.Material.Neon; gp.Transparency = 0.62
				gp.Anchored = false
				gp.CFrame = limb.CFrame
				local w = Instance.new("Weld")
				w.Part0 = limb; w.Part1 = gp; w.C0 = CFrame.new(); w.Parent = gp
				gp.Parent = folder
				table.insert(g.ghosts, { weld = w, part = gp, sign = k == 1 and -1 or 1 })
			end
		end
		if level == "low" then continue end
		-- pixels blinking round the fist (10) and the forearm (4)
		local hand, lower = chain[1], chain[2]
		for k = 1, 14 do
			local ref = (k > 10 and lower) or hand
			local px = cube(folder, 0.2, c1, 1)
			table.insert(g.pixels, { part = px, ref = ref, t = 0, off = CFrame.new() })
		end
		-- the scan line up the arm
		local sl = Instance.new("Part")
		plain(sl)
		sl.Material = Enum.Material.Neon; sl.Color = c1:Lerp(WHITE, 0.45); sl.Transparency = 0; sl.Anchored = true
		sl.Size = Vector3.new(1, 0.06, 1)
		sl.Parent = folder
		table.insert(g.scans, { part = sl, chain = chain, period = 1.7, phase = rng:NextNumber(0, 1) })
	end
	table.insert(active, g)
end

-- a pixel goes somewhere new (or hides for a moment)
local function reroll(g: Glitch, px: Pixel, now: number, burst: boolean)
	local hide = not burst and rng:NextNumber() < 0.35
	px.t = now + rng:NextNumber(0.06, burst and 0.12 or 0.3)
	if hide then px.part.Transparency = 1; return end
	local sz = px.ref.Size
	local spread = burst and 2.4 or 1.7
	px.off = CFrame.new((rng:NextNumber() - 0.5) * (sz.X * spread + 0.5), (rng:NextNumber() - 0.5) * (sz.Y * spread + 0.3), (rng:NextNumber() - 0.5) * (sz.Z * spread + 0.5))
	local s = rng:NextNumber(0.1, burst and 0.38 or 0.28)
	px.part.Size = Vector3.one * s
	local r = rng:NextNumber()
	px.part.Color = r < 0.35 and SPLIT1 or (r < 0.6 and g.c2 or (r < 0.8 and SPLIT2 or WHITE))
	px.part.Transparency = rng:NextNumber(0, 0.35)
end

local function stepOne(g: Glitch, dt: number, now: number)
	-- the glitch: every 1.4 - 3.2 s the split images jump away for a moment and the pixels flare
	local jumping = now < g.jumpUntil
	if not jumping and now >= g.jumpAt then
		g.jumpUntil = now + rng:NextNumber(0.1, 0.22)
		g.jumpAt = g.jumpUntil + rng:NextNumber(1.4, 3.2)
		jumping = true
		for _, px in g.pixels do reroll(g, px, now, true) end
	end
	g.jitT += dt
	if g.jitT > 0.06 or jumping then
		g.jitT = 0
		for _, gh in g.ghosts do
			local a = jumping and rng:NextNumber(0.35, 0.8) or rng:NextNumber(0.1, 0.18)
			local y = (rng:NextNumber() - 0.5) * (jumping and 0.6 or 0.1)
			gh.weld.C0 = CFrame.new(gh.sign * a, y, (rng:NextNumber() - 0.5) * (jumping and 0.3 or 0.05))
			gh.part.Transparency = jumping and 0.4 or (0.56 + rng:NextNumber() * 0.12)
		end
	end
	for _, px in g.pixels do
		if now >= px.t then reroll(g, px, now, false) end
		px.part.CFrame = px.ref.CFrame * px.off
	end
	for _, sc in g.scans do
		-- (up the arm in 70% of the period, then a short rest)
		local k = ((now / sc.period) + sc.phase) % 1
		if k > 0.7 then sc.part.Transparency = 1; continue end
		local total = 0
		for _, limb in sc.chain do total += limb.Size.Y end
		local d = (k / 0.7) * total
		for _, limb in sc.chain do
			if d <= limb.Size.Y or limb == sc.chain[#sc.chain] then
				local sz = limb.Size
				sc.part.Size = Vector3.new(sz.X * 1.14 + 0.06, 0.07, sz.Z * 1.14 + 0.06)
				sc.part.CFrame = limb.CFrame * CFrame.new(0, -sz.Y / 2 + math.min(d, sz.Y), 0)
				sc.part.Transparency = 0.4 * (k / 0.7)
				break
			end
			d -= limb.Size.Y
		end
	end
	-- the colour drift (ten times a second is smooth enough: it is slow)
	g.tintT += dt
	if g.tintT > 0.1 then
		g.tintT = 0
		local dh = drift(now)
		for _, t in g.tints do
			local inst = t.inst
			if typeof(t.orig) == "Color3" then (inst :: any).Color = FX.shift(t.orig, dh)
			else (inst :: any).Color = shiftSeq(t.orig, dh) end
		end
	end
end

function FX.step(dt: number)
	if #active == 0 then return end
	local now = os.clock()
	local camPos = cam.CFrame.Position
	for i = #active, 1, -1 do
		local g = active[i]
		if not g.folder.Parent or not g.ref.Parent then table.remove(active, i); continue end
		if (g.ref.Position - camPos).Magnitude > FAR then continue end
		stepOne(g, dt, now)
	end
end

-- putting it on: a cloud of pixels flying out, a cyan and a magenta flash side by side
function FX.burst(pos: Vector3, fm: any)
	if not fm or not fm.exclusive then return end
	local _, c2 = colors(fm)
	local f = Instance.new("Folder")
	f.Name = TAG
	f.Parent = workspace
	for k, col in { SPLIT1, SPLIT2 } do
		local fl = cube(f, 3, col, 0.3)
		fl.Shape = Enum.PartType.Ball
		fl.CFrame = CFrame.new(pos + Vector3.new(k == 1 and -0.8 or 0.8, 0, 0))
		TweenService:Create(fl, TweenInfo.new(0.4), { Size = Vector3.one * 9, Transparency = 1 }):Play()
	end
	for _ = 1, 46 do
		local r = rng:NextNumber()
		local px = cube(f, rng:NextNumber(0.25, 0.7), r < 0.35 and SPLIT1 or (r < 0.6 and c2 or (r < 0.8 and SPLIT2 or WHITE)), 0)
		px.CFrame = CFrame.new(pos)
		local dir = rng:NextUnitVector()
		local to = pos + dir * rng:NextNumber(5, 13) + Vector3.new(0, rng:NextNumber(0, 3), 0)
		TweenService:Create(px, TweenInfo.new(rng:NextNumber(0.5, 1), Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ CFrame = CFrame.new(to), Size = Vector3.one * 0.05, Transparency = 1 }):Play()
	end
	task.delay(1.2, function() f:Destroy() end)
end

----------------------------------------------------------------------------------------------------------------------
-- FIRST PERSON (your fists in a fight: Client/Viewmodel's parts; FormLook places its own shells, these follow)
type VMGhost = { part: BasePart, base: BasePart, sign: number, off: CFrame }
local vmGhosts = {} :: { VMGhost }
local vmTints = {} :: { Tint }
local vmT, vmTint, vmJumpAt, vmJumpUntil = 0, 0, 0, 0

function FX.clearVM()
	vmGhosts = {}
	vmTints = {}
end

-- shells = FormLook's first-person shells (tinted), bases = the fists / arms the split images go round
function FX.buildVM(vm: Instance, fm: any, shells: { BasePart }, bases: { BasePart })
	FX.clearVM()
	if not fm or fm.id ~= "AlphaGlitch" then return end
	for _, s in shells do table.insert(vmTints, { inst = s, orig = s.Color }) end
	for _, b in bases do
		for k, col in { SPLIT1, SPLIT2 } do
			local p = Instance.new("Part")
			plain(p)
			p.Size = b.Size * 1.03; p.Color = col; p.Material = Enum.Material.Neon; p.Transparency = 0.75; p.Anchored = true
			p.Parent = vm
			table.insert(vmGhosts, { part = p, base = b, sign = k == 1 and -1 or 1, off = CFrame.new() })
		end
	end
	vmJumpAt = os.clock() + 2
end

function FX.stepVM(dt: number)
	if #vmGhosts == 0 then return end
	local now = os.clock()
	local jumping = now < vmJumpUntil
	if not jumping and now >= vmJumpAt then
		vmJumpUntil = now + rng:NextNumber(0.08, 0.16)
		vmJumpAt = vmJumpUntil + rng:NextNumber(1.6, 3.5)
		jumping = true
	end
	vmT += dt
	local rejit = vmT > 0.06 or jumping
	if rejit then vmT = 0 end
	for _, gh in vmGhosts do
		if rejit then
			local w = gh.base.Size.X
			local a = jumping and w * rng:NextNumber(0.35, 0.7) or w * rng:NextNumber(0.08, 0.14)
			gh.off = CFrame.new(gh.sign * a, (rng:NextNumber() - 0.5) * w * (jumping and 0.4 or 0.05), 0)
			gh.part.Transparency = jumping and 0.5 or (0.7 + rng:NextNumber() * 0.1)
		end
		gh.part.CFrame = gh.base.CFrame * gh.off
		gh.part.LocalTransparencyModifier = gh.base.LocalTransparencyModifier
	end
	vmTint += dt
	if vmTint > 0.1 then
		vmTint = 0
		local dh = drift(now)
		for _, t in vmTints do
			if t.inst.Parent then (t.inst :: any).Color = FX.shift(t.orig, dh) end
		end
	end
end

return FX
