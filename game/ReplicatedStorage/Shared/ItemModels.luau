-- 3D models for the 50 items, all in the blocky PS2 style (flat colours, chunky blocks, no smooth meshes),
-- like the first-person hands. Used by the first-person hands, other players' hands and the event shops.
-- Model space: the right-hand grip is the origin, the item extends toward -Z (barrel, blade, nozzle), +Y is up.
-- Optional parts: "LeftGrip" (where the left hand holds a two-handed item), "Tip" (muzzle / nozzle / blade end).
-- Moving parts live in a folder "Moving" (attribute Mv = kick | spin | flicker) and the chainsaw chain in "Chain";
-- ItemModels.animate moves them every frame.
local ItemModels = {}
local M = Enum.Material
local P = M.SmoothPlastic
local WOOD = Color3.fromRGB(112, 80, 52)
local DARK = Color3.fromRGB(32, 30, 28)
local BLACK = Color3.fromRGB(22, 21, 20)
local STEEL = Color3.fromRGB(150, 150, 146)
local RUST = Color3.fromRGB(120, 70, 40)
local GOLD = Color3.fromRGB(196, 158, 64)
local TAPE = Color3.fromRGB(60, 58, 54)
local GRIME = Color3.fromRGB(60, 52, 44)
local A = CFrame.Angles
local function V(x, y, z) return Vector3.new(x, y, z) end
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end
local function worn(c: Color3, k: number?): Color3 return c:Lerp(GRIME, k or 0.18) end

local function p(m: Model, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): BasePart
	local part = Instance.new("Part")
	part.Size = size; part.CFrame = cf; part.Color = color; part.Material = mat or P
	if shape then part.Shape = shape end
	part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = true; part.CanCollide = false; part.CanQuery = false; part.CanTouch = false; part.CastShadow = false
	part.Parent = m
	return part
end
local function mark(m: Model, name: string, cf: CFrame)
	local q = p(m, Vector3.one * 0.15, cf, BLACK)
	q.Name = name; q.Transparency = 1
	return q
end
-- moving parts: kick = pushed by `a` (model-space Vector3) on each use, spin = turns around axis `a` at `b` rad/s,
-- flicker = flame / light that flickers
local function moving(m: Model, part: BasePart, mode: string, a: any?, b: number?)
	local f = m:FindFirstChild("Moving") or Instance.new("Folder")
	f.Name = "Moving"; f.Parent = m
	part:SetAttribute("Mv", mode)
	part:SetAttribute("Rel", part.CFrame)
	if mode == "kick" then part:SetAttribute("Kick", a) end
	if mode == "spin" then part:SetAttribute("Axis", a); part:SetAttribute("Rate", b) end
	if mode == "flicker" then part:SetAttribute("Base", part.Transparency) end
	part.Parent = f
end
local function flame(m: Model, cf: CFrame, s: number)
	local o = p(m, V(0.34, 0.5, 0.34) * s, cf * CFrame.new(0, 0.2 * s, 0), Color3.fromRGB(255, 120, 30), M.Neon)
	o.Transparency = 0.15; moving(m, o, "flicker")
	local i = p(m, V(0.2, 0.34, 0.2) * s, cf * CFrame.new(0, 0.14 * s, 0), Color3.fromRGB(255, 230, 120), M.Neon)
	i.Transparency = 0.1; moving(m, i, "flicker")
	-- real flame particles licking up from the block core
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/fire_main.dds"
	e.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 170)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 140, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 30, 10)) })
	e.LightEmission = 1; e.LightInfluence = 0
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35 * s), NumberSequenceKeypoint.new(0.4, 0.6 * s), NumberSequenceKeypoint.new(1, 0) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = NumberRange.new(0.25, 0.45); e.Rate = 30; e.Speed = NumberRange.new(1, 2.5)
	e.Acceleration = Vector3.new(0, 6, 0); e.SpreadAngle = Vector2.new(15, 15); e.Rotation = NumberRange.new(0, 360); e.RotSpeed = NumberRange.new(-120, 120)
	e.Parent = o
end

local B = {}
-- MELEE ----------------------------------------------------------------------------------------------
-- tapered wooden bat: knob, taped grip, three widening sections, end cap
function B.bat(m, c, glow)
	local w = worn(c, 0.12)
	p(m, V(0.42, 0.42, 0.16), at(0, 0, 0.55), worn(c, 0.3))
	p(m, V(0.3, 0.3, 1.0), at(0, 0, 0.02), TAPE)
	for i = 0, 2 do p(m, V(0.32, 0.06, 0.08), at(0, 0.15, 0.4 - i * 0.35), BLACK) end -- tape wraps
	p(m, V(0.32, 0.32, 0.7), at(0, 0, -0.82), w)
	p(m, V(0.4, 0.4, 0.75), at(0, 0, -1.5), w)
	p(m, V(0.5, 0.5, 2.1), at(0, 0, -2.88), w)
	p(m, V(0.44, 0.44, 0.1), at(0, 0, -3.97), worn(c, 0.35))
	p(m, V(0.52, 0.08, 0.3), at(0, 0.02, -2.6), worn(c, 0.45)) -- scuffed label
	mark(m, "Tip", at(0, 0, -3.9))
	if not glow then mark(m, "LeftGrip", at(0, 0, -0.42)) end -- two hands on the grip
	if glow then -- burning bat: flames along the barrel
		for i = 0, 4 do flame(m, at(i % 2 == 0 and 0.12 or -0.12, 0.25, -2.1 - i * 0.4), 1 + (i % 2) * 0.3) end
		local f = p(m, V(0.56, 0.56, 2.15), at(0, 0, -2.88), Color3.fromRGB(80, 30, 10), M.CrackedLava)
		f.Transparency = 0.25
	end
end
function B.spikedbat(m, c, glow)
	B.bat(m, c, glow)
	local nail = Color3.fromRGB(170, 168, 160)
	local dirs = { at(0, 0.32, 0), at(0.32, 0, 0, 0, 0, -math.pi / 2), at(0, -0.32, 0, math.pi, 0, 0), at(-0.32, 0, 0, 0, 0, math.pi / 2) }
	for i = 0, 7 do
		local d = dirs[i % 4 + 1]
		p(m, V(0.07, 0.36, 0.07), at(0, 0, -1.85 - i * 0.18) * d, nail, M.Metal)
	end
	for i = 0, 3 do p(m, V(0.54, 0.04, 0.06), at(0, 0.24, -1.9 - i * 0.4), Color3.fromRGB(110, 20, 16)) end -- dried blood
end
-- cast-iron pan, face sideways (normal = +X) so the swing hits flat
function B.pan(m, c)
	local iron = worn(c, 0.05)
	p(m, V(0.2, 0.2, 1.5), at(0, 0, -0.15), BLACK)
	p(m, V(0.12, 0.12, 0.12), at(0, 0, 0.55), STEEL, M.Metal)
	p(m, V(0.12, 0.26, 0.3), at(0, 0, -0.95), iron)
	local zc = -1.95
	p(m, V(0.12, 1.5, 1.5), at(0, 0, zc), iron)
	p(m, V(0.12, 1.1, 1.8), at(0, 0, zc), iron)
	p(m, V(0.12, 1.8, 1.1), at(0, 0, zc), iron)
	for _, s in { -1, 1 } do
		p(m, V(0.3, 0.12, 1.2), at(0.08, s * 0.86, zc), iron)
		p(m, V(0.3, 1.2, 0.12), at(0.08, 0, zc + s * 0.86), iron)
		p(m, V(0.3, 0.12, 0.6), at(0.08, s * 0.65, zc + s * 0.6, 0, 0, 0) * A(0, 0, 0), iron)
	end
	p(m, V(0.02, 1.2, 1.2), at(0.15, 0, zc), Color3.fromRGB(70, 66, 62)) -- inside, a bit lighter
end
function B.crowbar(m, c)
	local red = worn(c, 0.1)
	p(m, V(0.18, 0.18, 3.0), at(0, 0, -1.0), red, M.Metal)
	p(m, V(0.26, 0.06, 0.36), at(0, -0.02, 0.62, 0.15, 0, 0), STEEL, M.Metal) -- chisel end
	p(m, V(0.18, 0.18, 0.4), at(0, 0.12, -2.62, 0.5, 0, 0), red, M.Metal)
	p(m, V(0.18, 0.18, 0.4), at(0, 0.4, -2.78, 1.2, 0, 0), red, M.Metal)
	p(m, V(0.2, 0.12, 0.36), at(0, 0.62, -2.62, 2.2, 0, 0), STEEL, M.Metal) -- claw
	p(m, V(0.04, 0.1, 0.24), at(0, 0.66, -2.5, 2.2, 0, 0), BLACK) -- claw slot
	for i = 0, 3 do p(m, V(0.2, 0.2, 0.04), at(0, 0, -1.2 - i * 0.35), worn(c, 0.5), M.Metal) end -- chipped paint
	mark(m, "Tip", at(0, 0.5, -2.8))
end
function B.pipe(m, c)
	local g = worn(c, 0.12)
	p(m, V(0.34, 0.34, 0.9), at(0, 0, 0.05), TAPE)
	p(m, V(0.28, 0.28, 2.4), at(0, 0, -1.6), g, M.Metal)
	for i = 0, 2 do p(m, V(0.32, 0.32, 0.06), at(0, 0, -2.5 - i * 0.12), worn(c, 0.4), M.Metal) end -- threads
	p(m, V(0.44, 0.44, 0.5), at(0, 0, -2.95), g, M.Metal) -- elbow
	p(m, V(0.3, 0.55, 0.3), at(0, 0.38, -2.95), g, M.Metal)
	p(m, V(0.36, 0.1, 0.36), at(0, 0.68, -2.95), worn(c, 0.4), M.Metal)
	mark(m, "Tip", at(0, 0.3, -3))
end
function B.shovel(m, c)
	local wood = worn(WOOD, 0.1)
	p(m, V(0.2, 0.22, 3.1), at(0, 0, -1.15), wood)
	p(m, V(0.62, 0.14, 0.14), at(0, 0, 0.55), BLACK) -- D handle
	for _, s in { -1, 1 } do p(m, V(0.12, 0.12, 0.42), at(s * 0.25, 0, 0.32, 0, -s * 0.5, 0), BLACK) end
	p(m, V(0.3, 0.28, 0.5), at(0, 0, -2.85), worn(c, 0.2), M.Metal) -- collar
	local blade = worn(c, 0.05)
	p(m, V(0.95, 0.08, 1.1), at(0, -0.04, -3.6), blade, M.Metal)
	p(m, V(0.7, 0.08, 0.25), at(0, -0.04, -4.25), blade, M.Metal)
	p(m, V(0.12, 0.16, 1.1), at(0.47, 0.02, -3.6), blade, M.Metal)
	p(m, V(0.12, 0.16, 1.1), at(-0.47, 0.02, -3.6), blade, M.Metal)
	p(m, V(0.5, 0.09, 0.4), at(0.1, -0.03, -3.5), RUST) -- rust patch
	mark(m, "LeftGrip", at(0, 0, -1.7))
	mark(m, "Tip", at(0, 0, -4.2))
end
function B.golf(m, c)
	p(m, V(0.18, 0.18, 0.9), at(0, 0, 0.05), BLACK)
	p(m, V(0.2, 0.2, 0.08), at(0, 0, 0.52), DARK)
	p(m, V(0.1, 0.1, 2.7), at(0, 0, -1.75), worn(c, 0.05), M.Metal)
	p(m, V(0.14, 0.14, 0.3), at(0, 0, -3.15), DARK)
	p(m, V(0.24, 0.32, 0.62), at(0.12, -0.14, -3.32, 0, 0.1, 0), worn(c, 0.15), M.Metal) -- iron head
	p(m, V(0.02, 0.24, 0.5), at(0.25, -0.14, -3.32), Color3.fromRGB(110, 110, 112)) -- grooves face
	mark(m, "Tip", at(0.12, -0.15, -3.3))
end
function B.machete(m, c)
	p(m, V(0.2, 0.3, 0.95), at(0, -0.02, 0.05), BLACK)
	for i = 0, 1 do p(m, V(0.22, 0.08, 0.08), at(0, -0.02, 0.3 - i * 0.5), STEEL, M.Metal) end -- rivets
	p(m, V(0.22, 0.4, 0.1), at(0, 0.02, -0.45), DARK)
	local s = worn(c, 0.12)
	p(m, V(0.06, 0.42, 1.2), at(0, 0.02, -1.1), s, M.Metal)
	p(m, V(0.06, 0.54, 1.0), at(0, 0.08, -2.2), s, M.Metal)
	p(m, V(0.06, 0.4, 0.3), at(0, 0.2, -2.85), s, M.Metal)
	p(m, V(0.06, 0.2, 0.2), at(0, 0.32, -3.05), s, M.Metal)
	p(m, V(0.07, 0.1, 2.1), at(0, -0.15, -1.75), Color3.fromRGB(215, 215, 210), M.Metal) -- edge
	p(m, V(0.07, 0.12, 0.5), at(0, 0.1, -1.6), Color3.fromRGB(120, 20, 16)) -- stain
	mark(m, "Tip", at(0, 0.2, -3))
end
function B.katana(m, c, glow)
	p(m, V(0.2, 0.24, 1.15), at(0, 0, 0.1), BLACK)
	for i = 0, 3 do p(m, V(0.22, 0.1, 0.1), at(0, 0.08, 0.5 - i * 0.27, 0, 0, 0.78), Color3.fromRGB(150, 30, 26)) end -- wrap diamonds
	p(m, V(0.24, 0.28, 0.12), at(0, 0, -0.5), GOLD, M.Metal)
	p(m, V(0.5, 0.56, 0.1), at(0, 0.02, -0.6), DARK, M.Metal) -- tsuba
	p(m, V(0.12, 0.26, 0.18), at(0, 0.04, -0.75), GOLD, M.Metal)
	local s = worn(c, 0.05)
	p(m, V(0.05, 0.22, 2.5), at(0, 0.04, -2.05), s, M.Metal)
	p(m, V(0.05, 0.18, 0.5), at(0, 0.08, -3.5, -0.12, 0, 0), s, M.Metal)
	p(m, V(0.05, 0.1, 0.25), at(0, 0.15, -3.8, -0.4, 0, 0), s, M.Metal)
	local edge = p(m, V(0.06, 0.06, 2.9), at(0, 0.17, -2.3), glow and glow or Color3.fromRGB(235, 235, 240), glow and M.Neon or M.Metal)
	if glow then moving(m, edge, "flicker") end
	mark(m, "Tip", at(0, 0.1, -3.8))
end
-- THE DEMON BLADE: a broad, cruel black blade with a red-hot core. Bone grip with a little skull for a pommel, a
-- crossguard of two curled horns with a burning eye in the middle, a jagged spine of teeth along the back, a glowing
-- edge and vein, and embers drifting off it.
function B.demonblade(m, c, glow)
	local hot = glow or Color3.fromRGB(255, 30, 40)
	local OBS = Color3.fromRGB(26, 14, 16) -- obsidian
	local BONE = Color3.fromRGB(214, 200, 172)
	local BLOOD = Color3.fromRGB(110, 12, 16)
	-- grip: black leather wound with red cord, bone ferrules
	p(m, V(0.22, 0.26, 1.15), at(0, 0, 0.1), BLACK, M.Fabric)
	for i = 0, 3 do p(m, V(0.24, 0.09, 0.09), at(0, 0.09, 0.5 - i * 0.27, 0, 0, 0.78), BLOOD) end
	p(m, V(0.26, 0.3, 0.12), at(0, 0, -0.45), BONE)
	p(m, V(0.26, 0.3, 0.12), at(0, 0, 0.66), BONE)
	-- pommel: a small skull, eye sockets glowing
	p(m, V(0.3, 0.32, 0.3), at(0, 0.02, 0.86), BONE)
	p(m, V(0.24, 0.12, 0.22), at(0, -0.15, 0.84), worn(BONE, 0.2)) -- jaw
	for _, x in { -0.07, 0.07 } do
		local e = p(m, V(0.08, 0.08, 0.06), at(x, 0.06, 1.0), hot, M.Neon)
		moving(m, e, "flicker")
	end
	p(m, V(0.08, 0.08, 0.28), at(0, 0, 1.12, 0, 0, 0), OBS, M.Metal) -- spike out of the skull
	-- crossguard: a dark block with two horns curling forward, a burning eye in the middle
	p(m, V(0.34, 0.95, 0.2), at(0, 0.02, -0.58), OBS, M.Metal)
	p(m, V(0.36, 0.5, 0.14), at(0, 0.02, -0.7), BLOOD, M.Metal)
	for _, side in { 1, -1 } do
		p(m, V(0.18, 0.34, 0.16), at(0, side * 0.6, -0.62, side * 0.5, 0, 0), BONE)
		p(m, V(0.14, 0.28, 0.14), at(0, side * 0.82, -0.8, side * 1.0, 0, 0), BONE)
		p(m, V(0.1, 0.22, 0.1), at(0, side * 0.9, -1.02, side * 1.5, 0, 0), worn(BONE, 0.25))
	end
	local eye = p(m, V(0.4, 0.2, 0.2), at(0, 0.02, -0.62), hot, M.Neon, Enum.PartType.Ball)
	moving(m, eye, "flicker")
	-- blade: broad at the guard, a notch, then tapering to a hooked point; teeth along the spine (+Y)
	local b = worn(c, 0.0):Lerp(OBS, 0.72)
	p(m, V(0.07, 0.5, 1.1), at(0, 0.06, -1.25), b, M.Metal)
	p(m, V(0.07, 0.44, 1.1), at(0, 0.08, -2.3), b, M.Metal)
	p(m, V(0.07, 0.36, 0.8), at(0, 0.1, -3.2), b, M.Metal)
	p(m, V(0.07, 0.24, 0.45), at(0, 0.13, -3.78, -0.18, 0, 0), b, M.Metal)
	p(m, V(0.07, 0.12, 0.3), at(0, 0.2, -4.08, -0.5, 0, 0), b, M.Metal)
	for i = 0, 5 do -- the spine's teeth
		p(m, V(0.07, 0.18, 0.18), at(0, 0.34 - i * 0.012, -1.0 - i * 0.5, 0.78, 0, 0), b, M.Metal)
	end
	-- red-hot edge and the vein down the middle (both faces)
	local edge = p(m, V(0.08, 0.07, 3.05), at(0, -0.17, -2.45, 0.025, 0, 0), hot, M.Neon)
	moving(m, edge, "flicker")
	for _, x in { -0.04, 0.04 } do
		local vein = p(m, V(0.02, 0.06, 2.6), at(x, 0.1, -2.15), hot, M.Neon)
		vein.Transparency = 0.15
		moving(m, vein, "flicker")
	end
	-- embers drifting off the blade
	local core = p(m, V(0.05, 0.3, 3), at(0, 0.08, -2.4), hot)
	core.Name = "EmberCore"; core.Transparency = 1
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(Color3.fromRGB(255, 120, 60), hot)
	e.LightEmission = 1; e.LightInfluence = 0
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 0) })
	e.Transparency = NumberSequence.new(0.1, 1)
	e.Lifetime = NumberRange.new(0.5, 1.1); e.Rate = 9; e.Speed = NumberRange.new(0.4, 1.2)
	e.SpreadAngle = Vector2.new(180, 180); e.Acceleration = Vector3.new(0, 2.5, 0); e.Drag = 1
	e.Parent = core
	mark(m, "Tip", at(0, 0.2, -4.15))
end
function B.axe(m, c)
	local wood = worn(WOOD, 0.05)
	p(m, V(0.2, 0.26, 3.1), at(0, 0, -1.15), wood)
	p(m, V(0.24, 0.3, 0.2), at(0, 0, 0.45), BLACK)
	p(m, V(0.26, 0.4, 0.5), at(0, 0.05, -2.75), DARK, M.Metal) -- eye
	local red = worn(c, 0.1)
	p(m, V(0.14, 0.7, 0.42), at(0, 0.5, -2.75), red, M.Metal)
	p(m, V(0.14, 0.4, 0.62), at(0, 0.95, -2.75), red, M.Metal)
	p(m, V(0.15, 0.14, 0.8), at(0, 1.18, -2.75), Color3.fromRGB(205, 205, 200), M.Metal) -- edge
	p(m, V(0.14, 0.5, 0.2), at(0, -0.4, -2.75), red, M.Metal) -- back spike
	p(m, V(0.1, 0.2, 0.12), at(0, -0.72, -2.75), Color3.fromRGB(190, 190, 186), M.Metal)
	mark(m, "LeftGrip", at(0, 0, -1.45))
	mark(m, "Tip", at(0, 1.1, -2.75))
end
function B.sledge(m, c)
	local wood = worn(WOOD, 0.08)
	p(m, V(0.22, 0.24, 3.2), at(0, 0, -1.2), wood)
	p(m, V(0.26, 0.28, 0.7), at(0, 0, 0.2), BLACK)
	local h = worn(c, 0.05)
	p(m, V(0.62, 1.4, 0.62), at(0, 0, -3.05), h, M.Metal)
	p(m, V(0.7, 0.14, 0.7), at(0, 0.72, -3.05), worn(c, 0.4), M.Metal)
	p(m, V(0.7, 0.14, 0.7), at(0, -0.72, -3.05), worn(c, 0.4), M.Metal)
	mark(m, "LeftGrip", at(0, 0, -1.6))
	mark(m, "Tip", at(0, 0.7, -3.05))
end
function B.warhammer(m, c, glow)
	B.sledge(m, c)
	for _, y in { -0.35, 0.35 } do p(m, V(0.66, 0.12, 0.66), at(0, y, -3.05), GOLD, M.Metal) end
	local core = p(m, V(0.66, 0.4, 0.66), at(0, 0, -3.05), glow or Color3.fromRGB(200, 230, 255), M.Neon)
	moving(m, core, "flicker")
	for i = 0, 2 do -- crackling bolts
		local b = p(m, V(0.06, 0.5, 0.06), at(0.36, -0.4 + i * 0.4, -3.05, 0, 0, 0.6 * (i - 1)), Color3.fromRGB(220, 240, 255), M.Neon)
		moving(m, b, "flicker")
	end
	p(m, V(0.3, 0.3, 0.3), at(0, 0, -3.55), GOLD, M.Metal) -- top spike
end
function B.pickaxe(m, c, glow)
	local wood = worn(WOOD, 0.05)
	p(m, V(0.2, 0.24, 3.0), at(0, 0, -1.1), wood)
	p(m, V(0.24, 0.28, 0.5), at(0, 0, 0.3), BLACK)
	p(m, V(0.28, 0.34, 0.34), at(0, 0, -2.75), DARK, M.Metal)
	local ice = c
	for _, s in { -1, 1 } do
		p(m, V(0.18, 0.5, 0.24), at(0, s * 0.38, -2.72, s * 0.15, 0, 0), ice, M.Ice)
		p(m, V(0.16, 0.42, 0.2), at(0, s * 0.78, -2.6, s * 0.4, 0, 0), ice, M.Ice)
		p(m, V(0.12, 0.3, 0.14), at(0, s * 1.08, -2.42, s * 0.7, 0, 0), Color3.fromRGB(230, 245, 255), M.Ice)
	end
	if glow then
		for i = 0, 2 do
			local s = p(m, V(0.12, 0.3, 0.12), at(0.12, 0.2 * (i - 1), -2.3 - i * 0.12, 0.3 * i, 0, 0.4), glow, M.Neon)
			moving(m, s, "flicker")
		end
	end
	mark(m, "LeftGrip", at(0, 0, -1.4))
	mark(m, "Tip", at(0, 1.05, -2.45))
end
function B.cross(m, c, glow)
	local g = worn(c, 0.1)
	p(m, V(0.22, 0.22, 0.7), at(0, 0, 0.1), DARK) -- wrapped base
	p(m, V(0.26, 0.26, 2.3), at(0, 0, -1.3), g, M.Metal)
	p(m, V(1.3, 0.26, 0.26), at(0, 0, -1.85), g, M.Metal)
	for _, x in { -0.68, 0.68 } do p(m, V(0.16, 0.36, 0.36), at(x, 0, -1.85), worn(c, 0.3), M.Metal) end
	p(m, V(0.36, 0.36, 0.16), at(0, 0, -2.5), worn(c, 0.3), M.Metal)
	local gem = p(m, V(0.18, 0.3, 0.18), at(0, 0.1, -1.85), glow or Color3.fromRGB(255, 245, 200), M.Neon)
	moving(m, gem, "flicker")
	mark(m, "Tip", at(0, 0, -2.4))
end

-- Chainsaw: blocky PS2-era build (flat colours, chunky blocks, no smooth meshes), like the hands.
-- Right hand = rear handle (origin), left hand = the wrap-around top handle (part "LeftGrip").
-- The chain is 28 teeth in a folder "Chain" that ItemModels.animate slides around the bar.
local SAW_BAR_Y, SAW_BAR_H, SAW_Z0, SAW_Z1 = -0.05, 0.62, -1.55, -5.75 -- bar centre height, height, start, tip
local SAW_X = 0.42
local SAW_TEETH = 34
local function sawLoop(t: number): CFrame
	-- t in [0,1): along the top edge toward the tip, round the nose, back along the bottom edge
	local r = SAW_BAR_H / 2 + 0.04
	local len = SAW_Z0 - SAW_Z1
	local total = 2 * len + math.pi * r
	local d = (t % 1) * total
	if d < len then
		return CFrame.new(SAW_X, SAW_BAR_Y + r, SAW_Z0 - d)
	end
	d -= len
	local arc = math.pi * r
	if d < arc then
		local a = d / r -- 0..pi round the nose
		return CFrame.new(SAW_X, SAW_BAR_Y + math.cos(a) * r, SAW_Z1 - math.sin(a) * r) * CFrame.Angles(-a, 0, 0)
	end
	d -= arc
	return CFrame.new(SAW_X, SAW_BAR_Y - r, SAW_Z1 + d) * CFrame.Angles(math.pi, 0, 0)
end
function B.chainsaw(m, c)
	local body = c:Lerp(Color3.fromRGB(90, 62, 40), 0.42) -- worn, dirty orange
	local bodyDark = c:Lerp(Color3.new(0, 0, 0), 0.35)
	local black = Color3.fromRGB(28, 26, 24)
	local grey = Color3.fromRGB(70, 68, 64)
	local bar = Color3.fromRGB(112, 108, 100)
	local P = M.SmoothPlastic
	-- rear handle: grip on top, trigger guard below, closed at the back
	p(m, Vector3.new(0.3, 0.32, 1.05), CFrame.new(0, 0, 0.02), black, P).Name = "RearGrip"
	p(m, Vector3.new(0.26, 0.16, 0.95), CFrame.new(0, -0.48, 0.05), black, P)
	p(m, Vector3.new(0.26, 0.64, 0.2), CFrame.new(0, -0.24, 0.5), black, P)
	p(m, Vector3.new(0.1, 0.22, 0.16), CFrame.new(0, -0.24, -0.15), Color3.fromRGB(150, 30, 24), P) -- trigger
	-- engine housing
	p(m, Vector3.new(1.0, 1.0, 1.55), CFrame.new(0, 0.12, -1.2), body, P)
	p(m, Vector3.new(0.92, 0.22, 1.3), CFrame.new(0, 0.72, -1.15), grey, P) -- top cover
	p(m, Vector3.new(1.04, 0.14, 1.6), CFrame.new(0, -0.38, -1.2), bodyDark, P) -- base plate
	for i = 0, 3 do p(m, Vector3.new(0.94, 0.06, 0.1), CFrame.new(0, 0.86, -0.75 - i * 0.28), black, P) end -- cooling fins
	p(m, Vector3.new(0.3, 0.12, 0.3), CFrame.new(-0.22, 0.88, -1.62), black, P) -- fuel cap
	-- pull starter on the left side
	p(m, Vector3.new(0.14, 0.72, 0.72), CFrame.new(-0.56, 0.14, -1.1), grey, P)
	p(m, Vector3.new(0.12, 0.44, 0.44), CFrame.new(-0.64, 0.14, -1.1), black, P)
	p(m, Vector3.new(0.14, 0.14, 0.42), CFrame.new(-0.72, 0.42, -0.95), black, P) -- pull handle
	-- clutch cover on the bar side + muffler in front
	p(m, Vector3.new(0.2, 0.7, 0.8), CFrame.new(0.58, 0.04, -1.55), bodyDark, P)
	p(m, Vector3.new(0.62, 0.34, 0.2), CFrame.new(-0.12, -0.08, -2.04), Color3.fromRGB(45, 42, 40), M.Metal)
	-- wrap-around top handle (left hand) + hand guard
	p(m, Vector3.new(1.3, 0.26, 0.26), CFrame.new(-0.12, 1.12, -1.6), black, P)
	p(m, Vector3.new(0.26, 1.02, 0.26), CFrame.new(-0.77, 0.73, -1.6), black, P)
	p(m, Vector3.new(0.26, 0.44, 0.26), CFrame.new(0.53, 1.02, -1.6), black, P)
	p(m, Vector3.new(1.0, 0.5, 0.1), CFrame.new(-0.08, 1.05, -1.86), grey, P) -- hand guard
	local lg = p(m, Vector3.one * 0.2, CFrame.new(-0.3, 1.12, -1.6), black, P)
	lg.Name = "LeftGrip"; lg.Transparency = 1
	mark(m, "Tip", CFrame.new(SAW_X, SAW_BAR_Y, SAW_Z1 - 0.2))
	-- guide bar: flat plate with a stepped (low-poly) nose
	local len = SAW_Z0 - SAW_Z1
	p(m, Vector3.new(0.12, SAW_BAR_H, len), CFrame.new(SAW_X, SAW_BAR_Y, (SAW_Z0 + SAW_Z1) / 2), bar, M.Metal)
	p(m, Vector3.new(0.12, SAW_BAR_H * 0.7, 0.18), CFrame.new(SAW_X, SAW_BAR_Y, SAW_Z1 - 0.09), bar, M.Metal)
	p(m, Vector3.new(0.12, SAW_BAR_H * 0.36, 0.12), CFrame.new(SAW_X, SAW_BAR_Y, SAW_Z1 - 0.22), bar, M.Metal)
	p(m, Vector3.new(0.14, 0.1, len * 0.8), CFrame.new(SAW_X, SAW_BAR_Y, (SAW_Z0 + SAW_Z1) / 2 - 0.1), Color3.fromRGB(70, 67, 62), M.Metal) -- groove
	-- chain teeth
	local chain = Instance.new("Folder"); chain.Name = "Chain"; chain.Parent = m
	for i = 0, SAW_TEETH - 1 do
		local t = p(m, Vector3.new(0.18, 0.12, 0.17), sawLoop(i / SAW_TEETH), i % 2 == 0 and Color3.fromRGB(40, 38, 36) or Color3.fromRGB(78, 75, 70), M.Metal)
		t.Name = "Tooth"; t:SetAttribute("T", i / SAW_TEETH); t.Parent = chain
	end
end

-- GUNS (the hand holds the grip at the origin; barrel above it, toward -Z) -----------------------------
-- revolver / flare gun (same frame, the colour decides): grip, frame, cylinder, barrel, hammer that kicks
function B.pistol(m, c, _glow, id)
	local flare = id == "FlareGun"
	local body = worn(c, 0.1)
	local grip = flare and BLACK or Color3.fromRGB(96, 62, 40)
	p(m, V(0.26, 0.66, 0.36), at(0, -0.18, 0.06, -0.25, 0, 0), grip)
	p(m, V(0.28, 0.08, 0.38), at(0, -0.5, 0.15, -0.25, 0, 0), DARK)
	p(m, V(0.28, 0.32, 0.62), at(0, 0.24, -0.2), body, M.Metal) -- frame
	p(m, V(0.1, 0.22, 0.06), at(0, -0.04, -0.22), DARK, M.Metal) -- trigger
	p(m, V(0.12, 0.06, 0.4), at(0, -0.17, -0.25), body, M.Metal) -- guard
	if flare then
		p(m, V(0.42, 0.42, 1.0), at(0, 0.32, -0.95), body)
		p(m, V(0.46, 0.46, 0.14), at(0, 0.32, -1.45), worn(c, 0.35))
		p(m, V(0.24, 0.24, 0.05), at(0, 0.32, -1.53), BLACK)
		p(m, V(0.3, 0.12, 0.4), at(0, 0.56, -0.3), DARK)
	else
		p(m, V(0.38, 0.38, 0.44), at(0, 0.28, -0.52), Color3.fromRGB(120, 120, 124), M.Metal) -- cylinder
		for _, y in { 0.12, 0.44 } do p(m, V(0.4, 0.05, 0.36), at(0, y, -0.52), DARK, M.Metal) end
		p(m, V(0.2, 0.22, 1.0), at(0, 0.33, -1.2), body, M.Metal)
		p(m, V(0.24, 0.1, 1.0), at(0, 0.2, -1.2), worn(c, 0.3), M.Metal) -- ejector rod housing
		p(m, V(0.06, 0.1, 0.08), at(0, 0.48, -1.62), body, M.Metal) -- sight
		p(m, V(0.12, 0.12, 0.05), at(0, 0.33, -1.71), BLACK)
	end
	local ham = p(m, V(0.1, 0.2, 0.16), at(0, 0.44, 0.08, -0.3, 0, 0), DARK, M.Metal)
	moving(m, ham, "kick", V(0, -0.06, 0.12))
	mark(m, "Tip", at(0, flare and 0.32 or 0.33, flare and -1.55 or -1.75))
end
-- Glock 18: black polymer frame (stippled grip, finger grooves, beavertail, accessory rail, square trigger guard
-- with the trigger safety), dark steel slide that kicks back (front + rear serrations, compensator cuts, brass
-- barrel hood in the port, extractor, white-dot sights), red full-auto selector, long 33-round mag.
-- LeftGrip = the support hand cupped under the shooting hand (held with two hands).
function B.glock(m, c)
	-- the realistic version: ReplicatedStorage.ItemMeshes.Glock18 (a detailed model or mesh, muzzle toward -Z,
	-- centred on its bounding box), placed so its grip sits in the hand. The blocky one below is the fallback.
	local store = game:GetService("ReplicatedStorage"):FindFirstChild("ItemMeshes")
	local mesh = store and store:FindFirstChild("Glock18")
	if mesh then
		local g = mesh:Clone()
		local place = CFrame.new(0, 0.15, -0.42) * CFrame.Angles(0, math.rad(mesh:GetAttribute("Yaw") or 0), 0)
		for _, d in (g:IsA("BasePart") and { g } or g:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Anchored = true; d.CanCollide = false; d.CanQuery = false; d.CanTouch = false; d.CastShadow = false
			end
		end
		if g:IsA("Model") then g:PivotTo(place) else (g :: BasePart).CFrame = place end
		g.Parent = m
		mark(m, "Tip", at(0, 0.5, -1.15))
		mark(m, "LeftGrip", at(-0.42, -0.24, -0.08))
		return
	end
	local poly = worn(c, 0.05)
	local polyD = Color3.fromRGB(22, 22, 24)
	local steel = Color3.fromRGB(56, 57, 60)
	local edge = Color3.fromRGB(96, 97, 102)
	local WHITE = Color3.fromRGB(235, 235, 230)
	local GF = at(0, -0.17, 0.08, -0.28, 0, 0) -- the grip leans back
	local function g(size: Vector3, cf: CFrame, col: Color3, mat: Enum.Material?) return p(m, size, GF * cf, col, mat) end
	-- grip
	g(V(0.28, 0.62, 0.36), CFrame.new(), poly)
	for _, x in { -0.142, 0.142 } do g(V(0.02, 0.38, 0.27), at(x, -0.02, 0.01), polyD) end -- stippling panels
	for i = 0, 2 do g(V(0.26, 0.07, 0.05), at(0, 0.13 - i * 0.15, -0.19), poly) end -- finger grooves
	g(V(0.26, 0.5, 0.04), at(0, -0.02, 0.19), polyD) -- backstrap
	g(V(0.26, 0.08, 0.22), at(0, 0.33, 0.17), poly) -- beavertail
	g(V(0.3, 0.08, 0.38), at(0, -0.3, 0), poly) -- magwell flare
	g(V(0.22, 0.95, 0.25), at(0, -0.8, -0.02), Color3.fromRGB(30, 30, 32)) -- extended mag
	for i = 0, 2 do g(V(0.225, 0.05, 0.05), at(0, -0.55 - i * 0.2, 0.06), Color3.fromRGB(70, 70, 74)) end -- witness holes
	g(V(0.26, 0.1, 0.3), at(0, -1.3, -0.02), BLACK) -- base plate
	-- frame: dust cover, rail, trigger guard, trigger, levers
	p(m, V(0.26, 0.18, 0.82), at(0, 0.14, -0.5), poly)
	p(m, V(0.18, 0.05, 0.5), at(0, 0.03, -0.62), poly) -- accessory rail
	for i = 0, 2 do p(m, V(0.19, 0.06, 0.04), at(0, 0.03, -0.46 - i * 0.14), BLACK) end
	p(m, V(0.1, 0.05, 0.44), at(0, -0.2, -0.22), poly) -- square trigger guard
	p(m, V(0.1, 0.24, 0.05), at(0, -0.09, -0.42), poly)
	p(m, V(0.07, 0.18, 0.05), at(0, -0.07, -0.17, 0.25, 0, 0), BLACK) -- trigger
	p(m, V(0.025, 0.11, 0.025), at(0, -0.06, -0.2, 0.25, 0, 0), Color3.fromRGB(80, 80, 84)) -- trigger safety
	p(m, V(0.03, 0.05, 0.2), at(-0.14, 0.24, -0.2), BLACK) -- slide stop
	p(m, V(0.29, 0.04, 0.06), at(0, 0.22, -0.45), BLACK) -- takedown lever
	-- slide (kicks back when it fires)
	local function sl(size: Vector3, cf: CFrame, col: Color3, mat: Enum.Material?)
		moving(m, p(m, size, cf, col, mat), "kick", V(0, 0, 0.22))
	end
	sl(V(0.3, 0.26, 1.15), at(0, 0.36, -0.36), steel, M.Metal)
	sl(V(0.2, 0.02, 1.13), at(0, 0.495, -0.36), edge, M.Metal) -- flat top
	for _, x in { -0.152, 0.152 } do sl(V(0.01, 0.025, 1.12), at(x, 0.48, -0.36), edge, M.Metal) end -- chamfers
	for i = 0, 4 do sl(V(0.31, 0.19, 0.03), at(0, 0.35, 0.17 - i * 0.06), BLACK) end -- rear serrations
	for i = 0, 2 do sl(V(0.31, 0.15, 0.03), at(0, 0.35, -0.78 - i * 0.06), BLACK) end -- front serrations
	sl(V(0.05, 0.12, 0.3), at(0.14, 0.4, -0.38), Color3.fromRGB(130, 110, 60), M.Metal) -- ejection port
	sl(V(0.16, 0.03, 0.26), at(0, 0.5, -0.36), Color3.fromRGB(150, 128, 70), M.Metal) -- barrel hood
	sl(V(0.03, 0.05, 0.18), at(0.155, 0.43, -0.14), edge, M.Metal) -- extractor
	for i = 0, 1 do sl(V(0.07, 0.025, 0.1), at(0, 0.51, -0.7 - i * 0.14), BLACK) end -- compensator cuts
	sl(V(0.06, 0.09, 0.06), at(0, 0.535, -0.86), BLACK) -- front sight + dot
	sl(V(0.04, 0.04, 0.02), at(0, 0.55, -0.895), WHITE)
	sl(V(0.24, 0.08, 0.06), at(0, 0.53, 0.16), BLACK) -- rear sight + dots
	for _, x in { -0.07, 0.07 } do sl(V(0.035, 0.035, 0.02), at(x, 0.545, 0.125), WHITE) end
	sl(V(0.15, 0.15, 0.03), at(0, 0.37, -0.945), edge, M.Metal) -- barrel crown
	sl(V(0.08, 0.08, 0.03), at(0, 0.37, -0.96), BLACK) -- bore
	sl(V(0.06, 0.06, 0.03), at(0, 0.25, -0.94), BLACK) -- guide rod
	p(m, V(0.04, 0.09, 0.12), at(-0.165, 0.36, 0.08), Color3.fromRGB(200, 40, 30)) -- full-auto selector
	mark(m, "Tip", at(0, 0.37, -1))
	mark(m, "LeftGrip", at(-0.42, -0.24, -0.08)) -- support hand cupped under the shooting hand
end
function B.nailgun(m, c)
	local y = worn(c, 0.12)
	p(m, V(0.3, 0.66, 0.36), at(0, -0.15, 0.02, -0.2, 0, 0), BLACK)
	p(m, V(0.44, 0.6, 1.3), at(0, 0.38, -0.4), y) -- body
	p(m, V(0.46, 0.2, 0.9), at(0, 0.72, -0.3), DARK) -- top cap
	p(m, V(0.18, 0.34, 0.5), at(0, 0.3, 0.42), BLACK) -- air fitting
	local nose = p(m, V(0.24, 0.3, 0.5), at(0, 0.2, -1.25), DARK, M.Metal)
	moving(m, nose, "kick", V(0, 0, 0.18))
	p(m, V(0.16, 0.2, 1.1), at(0, -0.1, -0.85, -0.35, 0, 0), STEEL, M.Metal) -- nail strip
	p(m, V(0.12, 0.12, 0.12), at(0, 0.2, -1.52), Color3.fromRGB(200, 40, 30)) -- safety tip
	mark(m, "Tip", at(0, 0.2, -1.55))
end
function B.taser(m, c)
	p(m, V(0.28, 0.62, 0.34), at(0, -0.15, 0.02, -0.2, 0, 0), BLACK)
	p(m, V(0.34, 0.42, 0.95), at(0, 0.3, -0.35), worn(c, 0.1))
	p(m, V(0.36, 0.1, 0.8), at(0, 0.54, -0.3), BLACK)
	p(m, V(0.38, 0.38, 0.26), at(0, 0.3, -0.95), DARK) -- cartridge
	for _, x in { -0.09, 0.09 } do
		local e = p(m, V(0.08, 0.08, 0.06), at(x, 0.3, -1.1), Color3.fromRGB(120, 200, 255), M.Neon)
		moving(m, e, "flicker")
	end
	p(m, V(0.06, 0.06, 0.06), at(0, 0.56, 0.05), Color3.fromRGB(80, 255, 80), M.Neon) -- ready light
	mark(m, "Tip", at(0, 0.3, -1.12))
end
-- pump shotgun: stock behind the hand, receiver, barrel + tube, pump that slides back on each shot
function B.shotgun(m, c)
	local wood = worn(c, 0.08)
	p(m, V(0.28, 0.42, 1.1), at(0, -0.05, 0.75, 0.12, 0, 0), wood) -- stock
	p(m, V(0.3, 0.5, 0.12), at(0, -0.12, 1.32, 0.12, 0, 0), BLACK) -- butt pad
	p(m, V(0.24, 0.3, 0.3), at(0, -0.06, 0.12), wood) -- wrist
	p(m, V(0.3, 0.42, 0.9), at(0, 0.1, -0.45), DARK, M.Metal) -- receiver
	p(m, V(0.06, 0.2, 0.3), at(0.16, 0.1, -0.4), Color3.fromRGB(70, 70, 72), M.Metal) -- ejection port
	p(m, V(0.18, 0.18, 2.4), at(0, 0.2, -2.05), Color3.fromRGB(48, 48, 50), M.Metal)
	p(m, V(0.16, 0.16, 1.9), at(0, -0.02, -1.8), Color3.fromRGB(58, 58, 60), M.Metal)
	p(m, V(0.08, 0.08, 0.08), at(0, 0.32, -3.15), STEEL, M.Metal) -- bead sight
	p(m, V(0.1, 0.18, 0.06), at(0, -0.14, -0.3), DARK, M.Metal) -- trigger
	local pump = p(m, V(0.3, 0.28, 0.8), at(0, -0.04, -1.6), wood)
	moving(m, pump, "kick", V(0, 0, 0.45))
	for i = 0, 3 do
		local r = p(m, V(0.32, 0.04, 0.06), at(0, 0.08, -1.32 - i * 0.18), worn(c, 0.4))
		moving(m, r, "kick", V(0, 0, 0.45))
	end
	local lg = mark(m, "LeftGrip", at(0, -0.06, -1.6))
	moving(m, lg, "kick", V(0, 0, 0.45))
	mark(m, "Tip", at(0, 0.2, -3.25))
end
-- potato cannon: PVC chamber, reducer, long barrel, tape, igniter
function B.cannon(m, c)
	local pvc = Color3.fromRGB(128, 124, 112)
	p(m, V(0.3, 0.66, 0.34), at(0, -0.2, 0.05, -0.2, 0, 0), BLACK)
	p(m, V(0.8, 0.8, 1.2), at(0, 0.5, 0.25), pvc) -- chamber
	p(m, V(0.86, 0.86, 0.16), at(0, 0.5, 0.92), worn(pvc, 0.3)) -- end cap
	p(m, V(0.62, 0.62, 0.3), at(0, 0.5, -0.5), worn(pvc, 0.2)) -- reducer
	p(m, V(0.46, 0.46, 2.5), at(0, 0.5, -1.85), pvc)
	p(m, V(0.5, 0.5, 0.12), at(0, 0.5, -3.1), worn(pvc, 0.3))
	p(m, V(0.34, 0.34, 0.04), at(0, 0.5, -3.17), BLACK)
	for _, z in { -1.0, -2.4 } do p(m, V(0.5, 0.5, 0.2), at(0, 0.5, z), worn(c, 0.1)) end -- duct tape
	p(m, V(0.2, 0.16, 0.2), at(0, 0.98, 0.35), Color3.fromRGB(200, 40, 30)) -- igniter button
	p(m, V(0.22, 0.12, 0.6), at(0, 0.05, -1.5), BLACK) -- front handle
	mark(m, "LeftGrip", at(0, -0.05, -1.5))
	mark(m, "Tip", at(0, 0.5, -3.2))
end
-- crossbow with a stake loaded; the string kicks forward on each shot
function B.crossbow(m, c)
	local wood = worn(c, 0.08)
	p(m, V(0.26, 0.44, 0.9), at(0, -0.02, 0.6, 0.1, 0, 0), wood) -- butt
	p(m, V(0.24, 0.3, 0.3), at(0, -0.05, 0.05), wood)
	p(m, V(0.26, 0.26, 2.1), at(0, 0.12, -1.05), wood) -- tiller
	p(m, V(0.3, 0.12, 0.5), at(0, 0.3, -0.2), DARK, M.Metal) -- latch
	p(m, V(0.3, 0.3, 0.3), at(0, 0.15, -2.1), DARK, M.Metal) -- limb mount
	for _, s in { -1, 1 } do
		p(m, V(0.7, 0.12, 0.18), at(s * 0.45, 0.2, -2.1, 0, s * 0.15, 0), DARK, M.Metal)
		p(m, V(0.6, 0.12, 0.16), at(s * 1.0, 0.2, -1.92, 0, s * 0.5, 0), DARK, M.Metal)
	end
	for _, s in { -1, 1 } do
		local st = p(m, V(1.2, 0.04, 0.04), at(s * 0.6, 0.27, -1.3, 0, s * -0.55, 0), Color3.fromRGB(210, 205, 190))
		moving(m, st, "kick", V(0, 0, -0.35))
	end
	p(m, V(0.12, 0.12, 1.7), at(0, 0.36, -1.35), Color3.fromRGB(150, 110, 70)) -- stake
	p(m, V(0.08, 0.08, 0.26), at(0, 0.36, -2.3), STEEL, M.Metal)
	mark(m, "LeftGrip", at(0, -0.05, -1.4))
	mark(m, "Tip", at(0, 0.36, -2.4))
end
-- harpoon gun: steel tube with the spear sticking out, pistol grip, front handle
function B.harpoon(m, c)
	local g = worn(c, 0.1)
	p(m, V(0.28, 0.62, 0.34), at(0, -0.15, 0.05, -0.2, 0, 0), BLACK)
	p(m, V(0.34, 0.34, 0.8), at(0, 0.2, 0.6), g, M.Metal) -- stock tube
	p(m, V(0.42, 0.42, 2.4), at(0, 0.28, -0.95), g, M.Metal)
	for _, z in { 0.1, -1.0, -2.1 } do p(m, V(0.46, 0.46, 0.12), at(0, 0.28, z), DARK, M.Metal) end
	p(m, V(0.1, 0.1, 1.2), at(0, 0.28, -2.7), STEEL, M.Metal) -- spear
	p(m, V(0.24, 0.2, 0.3), at(0, 0.28, -3.35), STEEL, M.Metal)
	p(m, V(0.12, 0.12, 0.2), at(0, 0.28, -3.55), Color3.fromRGB(200, 200, 196), M.Metal)
	for _, s in { -1, 1 } do p(m, V(0.06, 0.06, 0.26), at(s * 0.12, 0.28, -3.15, 0, s * 0.6, 0), STEEL, M.Metal) end -- barbs
	p(m, V(0.2, 0.5, 0.24), at(0, -0.12, -1.4), BLACK) -- front grip
	p(m, V(0.06, 0.06, 2.0), at(0.24, 0.1, -1.0), Color3.fromRGB(230, 220, 180)) -- rope
	mark(m, "LeftGrip", at(0, -0.15, -1.4))
	mark(m, "Tip", at(0, 0.28, -3.6))
end

-- THROWABLES (held in the fist: the object sits just in front of the origin) -------------------------
function B.brick(m, c)
	local r = worn(c, 0.1)
	p(m, V(0.62, 0.42, 1.0), at(0, 0.1, -0.45), r)
	p(m, V(0.64, 0.06, 1.02), at(0, 0.0, -0.45), Color3.fromRGB(150, 140, 120)) -- mortar line
	for _, z in { -0.2, -0.45, -0.7 } do p(m, V(0.18, 0.02, 0.16), at(0, 0.32, z), Color3.fromRGB(50, 26, 20)) end -- holes
	p(m, V(0.2, 0.2, 0.2), at(0.24, 0.24, -0.88), worn(c, 0.5)) -- chipped corner
	mark(m, "Tip", at(0, 0.1, -0.95))
end
function B.knife(m, c)
	for i = -1, 1 do
		local k = at(i * 0.1, 0.05, -0.1, 0, i * 0.25, 0)
		p(m, V(0.1, 0.14, 0.45), k * at(0, 0, 0.1), BLACK)
		p(m, V(0.14, 0.18, 0.05), k * at(0, 0, -0.14), DARK, M.Metal)
		p(m, V(0.03, 0.16, 0.55), k * at(0, 0.01, -0.45), worn(c, 0.05), M.Metal)
		p(m, V(0.03, 0.08, 0.15), k * at(0, 0.03, -0.78), worn(c, 0.05), M.Metal)
	end
	mark(m, "Tip", at(0, 0.05, -0.8))
end
function B.firecracker(m, c)
	for i = 0, 4 do
		local x, z = (i % 3 - 1) * 0.17, (i < 3 and -0.3 or -0.47)
		p(m, V(0.16, 0.85, 0.16), at(x, 0.2, z), worn(c, i % 2 == 0 and 0.05 or 0.2))
		p(m, V(0.17, 0.08, 0.17), at(x, 0.6, z), Color3.fromRGB(230, 200, 60))
		p(m, V(0.03, 0.22, 0.03), at(x, 0.72, z, 0, 0, 0.3), Color3.fromRGB(220, 220, 210)) -- fuse
	end
	p(m, V(0.56, 0.2, 0.4), at(0, 0.1, -0.38), Color3.fromRGB(230, 220, 190)) -- paper band
	local spark = p(m, V(0.1, 0.1, 0.1), at(-0.05, 0.86, -0.3), Color3.fromRGB(255, 200, 80), M.Neon)
	moving(m, spark, "flicker")
	mark(m, "Tip", at(0, 0.3, -0.5))
end
function B.grenade(m, c, glow, id)
	local holy = id == "HolyWaterGrenade"
	local g = worn(c, holy and 0 or 0.15)
	local z = -0.4
	p(m, V(0.6, 0.72, 0.6), at(0, 0.18, z), g, holy and M.Glass or P)
	p(m, V(0.7, 0.5, 0.5), at(0, 0.18, z), g, holy and M.Glass or P)
	p(m, V(0.5, 0.5, 0.7), at(0, 0.18, z), g, holy and M.Glass or P)
	if not holy then for _, y in { 0.0, 0.36 } do p(m, V(0.72, 0.05, 0.72), at(0, y, z), worn(c, 0.4)) end end
	p(m, V(0.3, 0.2, 0.3), at(0, 0.62, z), DARK, M.Metal) -- fuze
	p(m, V(0.1, 0.5, 0.16), at(0.3, 0.42, z, 0, 0, -0.2), STEEL, M.Metal) -- spoon
	p(m, V(0.04, 0.22, 0.22), at(-0.2, 0.68, z), STEEL, M.Metal) -- pin ring
	if holy then
		local cr = p(m, V(0.06, 0.4, 0.1), at(0, 0.2, z - 0.36), glow or Color3.fromRGB(255, 240, 170), M.Neon)
		local cr2 = p(m, V(0.06, 0.1, 0.3), at(0, 0.28, z - 0.36), glow or Color3.fromRGB(255, 240, 170), M.Neon)
		moving(m, cr, "flicker"); moving(m, cr2, "flicker")
		p(m, V(0.4, 0.5, 0.4), at(0, 0.15, z), Color3.fromRGB(180, 210, 255), M.Neon).Transparency = 0.5 -- water inside
	else -- stink fumes
		for i = 0, 1 do
			local f = p(m, V(0.2, 0.2, 0.2), at(0.1 - i * 0.2, 0.85 + i * 0.12, z), Color3.fromRGB(140, 170, 60), M.Neon)
			f.Transparency = 0.5; moving(m, f, "flicker")
		end
	end
	mark(m, "Tip", at(0, 0.2, -0.7))
end
function B.bottle(m, c)
	local glass = p(m, V(0.46, 0.8, 0.46), at(0, 0.25, -0.38), c, M.Glass)
	glass.Transparency = 0.25
	p(m, V(0.38, 0.4, 0.38), at(0, 0.12, -0.38), Color3.fromRGB(170, 120, 40)).Transparency = 0.3 -- fuel inside
	p(m, V(0.3, 0.12, 0.3), at(0, 0.72, -0.38), c, M.Glass)
	p(m, V(0.2, 0.34, 0.2), at(0, 0.92, -0.38), c, M.Glass)
	p(m, V(0.26, 0.26, 0.22), at(0, 1.18, -0.38, 0, 0, 0.3), Color3.fromRGB(215, 205, 180), M.Fabric) -- rag
	p(m, V(0.12, 0.3, 0.1), at(0.12, 1.0, -0.26, 0, 0, -0.3), Color3.fromRGB(190, 180, 160), M.Fabric)
	flame(m, at(0, 1.3, -0.38), 1)
	mark(m, "Tip", at(0, 1.3, -0.38))
end
function B.pouch(m, c)
	local cloth = worn(c, 0.12)
	p(m, V(0.74, 0.62, 0.74), at(0, 0.18, -0.42), cloth, M.Fabric)
	p(m, V(0.62, 0.74, 0.62), at(0, 0.18, -0.42), cloth, M.Fabric)
	p(m, V(0.36, 0.2, 0.36), at(0, 0.6, -0.42), worn(c, 0.3), M.Fabric) -- neck
	p(m, V(0.4, 0.06, 0.4), at(0, 0.54, -0.42), Color3.fromRGB(150, 110, 60)) -- string
	p(m, V(0.44, 0.16, 0.36), at(0, 0.76, -0.42), cloth, M.Fabric) -- tied top
	p(m, V(0.14, 0.14, 0.02), at(0.1, 0.2, -0.8), Color3.fromRGB(40, 40, 120)) -- stamp
	mark(m, "Tip", at(0, 0.2, -0.8))
end
function B.ball(m, c)
	local b = worn(c, 0.05)
	local z = -0.55
	p(m, V(1.0, 1.0, 1.0), at(0, 0.3, z), b)
	p(m, V(1.2, 0.72, 0.72), at(0, 0.3, z), b)
	p(m, V(0.72, 1.2, 0.72), at(0, 0.3, z), b)
	p(m, V(0.72, 0.72, 1.2), at(0, 0.3, z), b)
	for i, o in { V(-0.12, 0.62, 0.1), V(0.12, 0.62, 0.1), V(0, 0.62, -0.2) } do -- finger holes on top
		p(m, V(0.14, 0.04, 0.14), at(o.X, 0.3 + o.Y * 0.98, z + o.Z), BLACK)
	end
	p(m, V(0.4, 0.04, 0.3), at(0.2, 0.3, z - 0.61, math.pi / 2, 0, 0), worn(c, 0.5)) -- scuff
	mark(m, "Tip", at(0, 0.3, z - 0.6))
end
function B.pipebomb(m, c)
	local g = worn(c, 0.1)
	p(m, V(0.36, 0.36, 1.0), at(0, 0.12, -0.42), g, M.Metal)
	for _, z in { 0.1, -0.94 } do p(m, V(0.46, 0.46, 0.18), at(0, 0.12, z), DARK, M.Metal) end
	p(m, V(0.38, 0.38, 0.28), at(0, 0.12, -0.45), Color3.fromRGB(140, 110, 50)) -- tape
	p(m, V(0.24, 0.12, 0.16), at(0, 0.34, -0.45), BLACK) -- timer
	local led = p(m, V(0.06, 0.04, 0.06), at(0.06, 0.41, -0.45), Color3.fromRGB(255, 40, 30), M.Neon)
	moving(m, led, "flicker")
	for i, col in { Color3.fromRGB(200, 30, 30), Color3.fromRGB(40, 80, 200) } do
		p(m, V(0.04, 0.04, 0.6), at(-0.12 + i * 0.08, 0.33, -0.2, 0.2, 0, 0), col)
	end
	mark(m, "Tip", at(0, 0.12, -0.95))
end
function B.doll(m, c)
	local cloth = worn(c, 0.1)
	local z = -0.35
	p(m, V(0.42, 0.52, 0.28), at(0, 0.3, z), cloth, M.Fabric) -- body
	p(m, V(0.46, 0.44, 0.38), at(0, 0.78, z), cloth, M.Fabric) -- head
	for _, x in { -0.1, 0.1 } do p(m, V(0.1, 0.1, 0.04), at(x, 0.82, z - 0.2), BLACK) end -- button eyes
	p(m, V(0.22, 0.03, 0.03), at(0, 0.66, z - 0.2), Color3.fromRGB(120, 20, 20)) -- stitched mouth
	for _, x in { -1, 1 } do
		p(m, V(0.14, 0.38, 0.14), at(x * 0.28, 0.32, z, 0, 0, x * 0.4), cloth, M.Fabric) -- arms
		p(m, V(0.15, 0.36, 0.15), at(x * 0.11, -0.12, z), worn(c, 0.3), M.Fabric) -- legs
	end
	p(m, V(0.48, 0.12, 0.42), at(0, 1.02, z), Color3.fromRGB(40, 25, 20), M.Fabric) -- hair
	for i = 0, 2 do -- pins
		p(m, V(0.03, 0.03, 0.4), at(-0.1 + i * 0.1, 0.3 + i * 0.12, z - 0.2, 0.3, 0.2 * i, 0), STEEL, M.Metal)
		p(m, V(0.07, 0.07, 0.07), at(-0.1 + i * 0.1, 0.36 + i * 0.12, z - 0.38), Color3.fromRGB(200, 30, 30))
	end
	mark(m, "Tip", at(0, 0.5, z - 0.3))
end

-- SPRAYS (held like a gun: grip at the origin, nozzle toward -Z) --------------------------------------
function B.blower(m, c)
	local o = worn(c, 0.1)
	p(m, V(0.22, 0.24, 0.7), at(0, 0.05, 0), BLACK) -- top handle
	for _, z in { 0.32, -0.32 } do p(m, V(0.2, 0.4, 0.14), at(0, -0.15, z), BLACK) end
	p(m, V(0.9, 0.85, 1.1), at(0, -0.7, 0.05), o) -- engine
	p(m, V(0.92, 0.2, 1.12), at(0, -0.3, 0.05), DARK)
	p(m, V(0.1, 0.6, 0.6), at(-0.5, -0.7, 0.05), DARK) -- intake
	local fan = p(m, V(0.06, 0.5, 0.12), at(-0.56, -0.7, 0.05), Color3.fromRGB(150, 150, 150))
	moving(m, fan, "spin", V(1, 0, 0), 30)
	p(m, V(0.42, 0.42, 0.6), at(0, -0.6, -0.75), o) -- elbow
	p(m, V(0.36, 0.36, 1.8), at(0, -0.62, -1.9), Color3.fromRGB(60, 60, 58))
	p(m, V(0.42, 0.3, 0.14), at(0, -0.62, -2.82), DARK)
	mark(m, "Tip", at(0, -0.62, -2.9))
end
function B.can(m, c, _glow, id)
	local drink = id == "EnergyDrink"
	local body = worn(c, 0.08)
	if drink then -- soda can held upright, opening on top
		p(m, V(0.4, 0.72, 0.4), at(0, 0.25, -0.3), body, M.Metal)
		p(m, V(0.36, 0.08, 0.36), at(0, 0.65, -0.3), STEEL, M.Metal)
		p(m, V(0.12, 0.03, 0.18), at(0, 0.7, -0.33), Color3.fromRGB(190, 190, 186), M.Metal) -- tab
		p(m, V(0.41, 0.22, 0.41), at(0, 0.3, -0.3), Color3.fromRGB(30, 30, 30)) -- label band
		p(m, V(0.12, 0.2, 0.02), at(0, 0.3, -0.51, 0, 0, 0.6), Color3.fromRGB(240, 240, 60), M.Neon) -- bolt logo
		mark(m, "Tip", at(0, 0.7, -0.3))
	else -- pepper spray canister, nozzle pointing forward
		p(m, V(0.3, 0.8, 0.3), at(0, 0.08, -0.15), body, M.Metal)
		p(m, V(0.31, 0.24, 0.31), at(0, 0.0, -0.15), Color3.fromRGB(240, 230, 200)) -- label
		p(m, V(0.26, 0.2, 0.3), at(0, 0.58, -0.18), BLACK) -- actuator
		p(m, V(0.08, 0.08, 0.1), at(0, 0.6, -0.36), DARK)
		mark(m, "Tip", at(0, 0.6, -0.42))
	end
end
function B.extinguisher(m, c)
	local red = worn(c, 0.08)
	p(m, V(0.22, 0.12, 0.6), at(0, 0.08, 0.05), BLACK) -- carry handle
	p(m, V(0.18, 0.1, 0.5), at(0, 0.24, 0.0, 0.25, 0, 0), BLACK) -- squeeze lever
	p(m, V(0.3, 0.3, 0.36), at(0, -0.1, 0.05), DARK, M.Metal) -- valve
	p(m, V(0.7, 1.6, 0.7), at(0, -1.05, 0.05), red, M.Metal)
	p(m, V(0.55, 1.7, 0.55), at(0, -1.05, 0.05), red, M.Metal)
	p(m, V(0.72, 0.4, 0.72), at(0, -0.95, 0.05), Color3.fromRGB(235, 230, 215)) -- label
	p(m, V(0.12, 0.12, 0.12), at(0.18, 0.02, 0.15), Color3.fromRGB(240, 240, 240)) -- gauge
	p(m, V(0.1, 0.1, 0.7), at(0, -0.2, -0.35, -0.6, 0, 0), BLACK) -- hose
	p(m, V(0.1, 0.1, 0.8), at(0, -0.3, -0.95), BLACK)
	p(m, V(0.22, 0.22, 0.5), at(0, -0.3, -1.5), DARK) -- horn
	p(m, V(0.3, 0.3, 0.12), at(0, -0.3, -1.78), BLACK)
	mark(m, "LeftGrip", at(0, -0.3, -1.25))
	mark(m, "Tip", at(0, -0.3, -1.85))
end
function B.flashlight(m, c)
	p(m, V(0.34, 0.34, 1.3), at(0, 0, -0.25), BLACK, M.Metal)
	for i = 0, 3 do p(m, V(0.36, 0.06, 0.08), at(0, 0.17, 0.2 - i * 0.18), DARK) end -- grip ribs
	p(m, V(0.12, 0.08, 0.16), at(0, 0.2, -0.5), Color3.fromRGB(80, 80, 80)) -- switch
	p(m, V(0.5, 0.5, 0.42), at(0, 0, -1.08), DARK, M.Metal) -- head
	local lens = p(m, V(0.4, 0.4, 0.04), at(0, 0, -1.3), c, M.Neon)
	moving(m, lens, "flicker")
	mark(m, "Tip", at(0, 0, -1.35))
end
function B.vacuum(m, c)
	local y = worn(c, 0.1)
	p(m, V(0.24, 0.26, 0.6), at(0, 0, 0.05), BLACK) -- handle
	p(m, V(0.9, 0.8, 0.9), at(0, -0.7, 0.55), y) -- canister
	p(m, V(0.94, 0.25, 0.94), at(0, -0.22, 0.55), DARK) -- motor head
	p(m, V(0.16, 0.16, 0.8), at(0, -0.4, 0.15, 0.6, 0, 0), BLACK) -- hose
	p(m, V(0.3, 0.3, 2.2), at(0, -0.05, -1.3), Color3.fromRGB(170, 170, 166), M.Metal) -- wand
	p(m, V(0.9, 0.22, 0.42), at(0, -0.15, -2.5), DARK) -- floor nozzle
	p(m, V(0.92, 0.06, 0.06), at(0, -0.26, -2.68), Color3.fromRGB(80, 80, 80))
	mark(m, "LeftGrip", at(0, -0.1, -1.2))
	mark(m, "Tip", at(0, -0.15, -2.75))
end
function B.flamethrower(m, c)
	local g = worn(c, 0.1)
	p(m, V(0.28, 0.6, 0.34), at(0, -0.15, 0.05, -0.2, 0, 0), BLACK)
	p(m, V(0.36, 0.4, 1.3), at(0, 0.25, -0.35), DARK, M.Metal) -- body
	for _, x in { -0.27, 0.27 } do p(m, V(0.36, 0.36, 1.2), at(x, -0.15, 0.2), g, M.Metal) end -- fuel tanks
	for _, x in { -0.27, 0.27 } do p(m, V(0.38, 0.38, 0.1), at(x, -0.15, -0.4), Color3.fromRGB(180, 30, 25)) end
	p(m, V(0.24, 0.24, 1.6), at(0, 0.3, -1.75), Color3.fromRGB(70, 70, 70), M.Metal) -- barrel
	for i = 0, 3 do p(m, V(0.3, 0.3, 0.06), at(0, 0.3, -1.2 - i * 0.25), DARK, M.Metal) end -- heat fins
	p(m, V(0.3, 0.3, 0.22), at(0, 0.3, -2.62), DARK, M.Metal) -- nozzle
	p(m, V(0.2, 0.5, 0.24), at(0, -0.05, -1.4), BLACK) -- front grip
	local pilot = p(m, V(0.1, 0.12, 0.1), at(0, 0.12, -2.68), Color3.fromRGB(90, 160, 255), M.Neon)
	moving(m, pilot, "flicker")
	mark(m, "LeftGrip", at(0, -0.1, -1.4))
	mark(m, "Tip", at(0, 0.3, -2.75))
end

-- USE ITEMS (held in the fist) ------------------------------------------------------------------------
function B.medkit(m, c)
	local box = worn(c, 0.08)
	p(m, V(0.4, 0.12, 0.12), at(0, 0.15, -0.2), BLACK) -- handle
	p(m, V(1.2, 0.8, 0.42), at(0, -0.35, -0.2, 0, math.pi / 2, 0), box)
	p(m, V(1.22, 0.06, 0.44), at(0, -0.12, -0.2, 0, math.pi / 2, 0), worn(c, 0.3)) -- lid seam
	for _, s in { -1, 1 } do
		p(m, V(0.02, 0.15, 0.48), at(s * 0.22, -0.35, -0.2), Color3.fromRGB(200, 20, 20))
		p(m, V(0.02, 0.48, 0.15), at(s * 0.22, -0.35, -0.2), Color3.fromRGB(200, 20, 20))
	end
	mark(m, "Tip", at(0, -0.3, -0.85))
end
function B.pills(m, c)
	local b = p(m, V(0.4, 0.62, 0.4), at(0, 0.2, -0.3), c)
	b.Transparency = 0.15
	p(m, V(0.42, 0.18, 0.42), at(0, 0.6, -0.3), Color3.fromRGB(240, 240, 235)) -- cap
	p(m, V(0.41, 0.3, 0.41), at(0, 0.18, -0.3), Color3.fromRGB(240, 235, 220)) -- label
	p(m, V(0.2, 0.06, 0.02), at(0, 0.22, -0.51), Color3.fromRGB(200, 30, 30))
	mark(m, "Tip", at(0, 0.6, -0.3))
end
-- a fantasy potion flask: a round glass belly, a neck, a cork, the glowing potion inside (the Speed / Rage Potion)
function B.flask(m, c)
	local glass = p(m, V(0.5, 0.5, 0.5), at(0, 0.15, -0.3), Color3.fromRGB(210, 230, 225), M.Glass)
	glass.Shape = Enum.PartType.Ball
	glass.Transparency = 0.45
	local fluid = p(m, V(0.4, 0.4, 0.4), at(0, 0.12, -0.3), c, M.Neon)
	fluid.Shape = Enum.PartType.Ball
	moving(m, fluid, "flicker")
	local neck = p(m, V(0.14, 0.26, 0.14), at(0, 0.47, -0.3), Color3.fromRGB(210, 230, 225), M.Glass)
	neck.Transparency = 0.45
	p(m, V(0.15, 0.13, 0.15), at(0, 0.64, -0.3), Color3.fromRGB(150, 110, 70), M.Wood) -- cork
	p(m, V(0.17, 0.04, 0.17), at(0, 0.53, -0.3), Color3.fromRGB(120, 70, 40), M.Fabric) -- string round the neck
	mark(m, "Tip", at(0, 0.7, -0.3))
end
function B.vest(m, c)
	local v = worn(c, 0.08)
	p(m, V(1.2, 1.4, 0.32), at(0, 0.0, -0.45), v, M.Fabric)
	for _, x in { -0.4, 0.4 } do p(m, V(0.3, 0.4, 0.3), at(x, 0.85, -0.45), v, M.Fabric) end -- shoulder straps
	p(m, V(0.9, 0.9, 0.06), at(0, 0.05, -0.64), worn(c, 0.3), M.Fabric) -- plate
	for i = 0, 2 do p(m, V(0.3, 0.28, 0.1), at(-0.36 + i * 0.36, -0.45, -0.66), worn(c, 0.4), M.Fabric) end -- pouches
	p(m, V(0.5, 0.14, 0.02), at(0, 0.38, -0.68), Color3.fromRGB(220, 220, 210)) -- "POLICE"-style patch, no text
	mark(m, "Tip", at(0, 0, -0.7))
end
function B.talisman(m, c)
	p(m, V(0.62, 1.2, 0.04), at(0, 0.55, -0.35), worn(c, 0.05))
	p(m, V(0.66, 0.08, 0.05), at(0, 1.12, -0.35), Color3.fromRGB(160, 20, 20))
	for i = 0, 4 do -- red brush strokes
		p(m, V(0.12 + (i % 2) * 0.16, 0.06, 0.05), at((i % 2 == 0) and 0 or 0.06, 0.95 - i * 0.17, -0.37), Color3.fromRGB(170, 20, 20))
	end
	p(m, V(0.06, 0.62, 0.05), at(0, 0.5, -0.37), Color3.fromRGB(170, 20, 20))
	local glow = p(m, V(0.66, 1.24, 0.02), at(0, 0.55, -0.32), Color3.fromRGB(255, 220, 140), M.Neon)
	glow.Transparency = 0.8; moving(m, glow, "flicker")
	mark(m, "Tip", at(0, 1.1, -0.35))
end
function B.watch(m, c)
	local g = worn(c, 0.05)
	local z = -0.35
	p(m, V(0.7, 0.7, 0.16), at(0, 0.3, z), g, M.Metal)
	p(m, V(0.84, 0.5, 0.16), at(0, 0.3, z), g, M.Metal)
	p(m, V(0.5, 0.84, 0.16), at(0, 0.3, z), g, M.Metal)
	p(m, V(0.6, 0.6, 0.02), at(0, 0.3, z - 0.09), Color3.fromRGB(235, 228, 205)) -- face
	p(m, V(0.14, 0.14, 0.14), at(0, 0.78, z), g, M.Metal) -- crown
	p(m, V(0.2, 0.06, 0.06), at(0, 0.88, z), g, M.Metal)
	for i = 0, 3 do p(m, V(0.06, 0.06, 0.12), at(0.05 * i, 0.95 + i * 0.1, z + 0.06 * i), GOLD, M.Metal) end -- chain
	local h1 = p(m, V(0.03, 0.24, 0.02), at(0, 0.3, z - 0.11) * CFrame.new(0, 0.1, 0), BLACK)
	local h2 = p(m, V(0.03, 0.16, 0.02), at(0, 0.3, z - 0.11) * CFrame.new(0, 0.07, 0), Color3.fromRGB(150, 20, 20))
	-- hands spin backwards (cursed) around the face centre: rotate about an axis through (0,0.3,z)
	moving(m, h1, "spin", V(0, 0, 1), -3)
	moving(m, h2, "spin", V(0, 0, 1), -0.5)
	h1:SetAttribute("Center", V(0, 0.3, z - 0.11)); h2:SetAttribute("Center", V(0, 0.3, z - 0.11))
	mark(m, "Tip", at(0, 0.3, z - 0.1))
end
function B.beartrap(m, c)
	local g = worn(c, 0.1)
	local z = -0.55
	p(m, V(0.9, 0.08, 0.2), at(0, -0.3, z), DARK, M.Metal) -- base bar
	p(m, V(0.36, 0.06, 0.36), at(0, -0.24, z), Color3.fromRGB(120, 110, 90), M.Metal) -- pan
	for _, s in { -1, 1 } do
		for k = -2, 2 do -- jaw: arc of 5 segments with teeth
			local a = k * 0.32
			local o = at(0, -0.2, z) * A(0, a, 0) * CFrame.new(0, 0.08, s * 0.55)
			p(m, V(0.36, 0.14, 0.08), o, g, M.Metal)
			p(m, V(0.08, 0.16, 0.06), o * CFrame.new(0, 0.14, -s * 0.02), Color3.fromRGB(170, 165, 150), M.Metal)
		end
	end
	for _, x in { -0.62, 0.62 } do p(m, V(0.2, 0.12, 0.5), at(x, -0.28, z), g, M.Metal) end -- springs
	p(m, V(0.06, 0.06, 0.6), at(0, -0.28, z + 0.5), DARK, M.Metal) -- chain
	mark(m, "Tip", at(0, 0, z))
end

function ItemModels.build(shape: string, color: Color3, glow: Color3?, id: string?): Model
	local m = Instance.new("Model")
	m.Name = "Item_" .. shape
	local grip = p(m, Vector3.one * 0.2, CFrame.new(), color)
	grip.Name = "Grip"; grip.Transparency = 1
	m.PrimaryPart = grip
	local f = B[shape] or B.brick
	f(m, color, glow, id)
	if glow then
		local l = Instance.new("PointLight"); l.Color = glow; l.Range = 8; l.Brightness = 1.2; l.Parent = grip
	end
	return m
end

-- per-frame motion of an item's moving parts. chainSpeed = chainsaw chain loops per second,
-- useAge = seconds since the item was last used (kick parts snap back and return), nil = never used.
-- Positions are relative to the model's pivot, so call it after the model is moved.
local function scaled(cf: CFrame, s: number): CFrame return cf - cf.Position + cf.Position * s end
function ItemModels.animate(m: Model, chainSpeed: number, useAge: number?)
	local pivot = m:GetPivot()
	local scale = m:GetScale()
	local now = os.clock()
	local chain = m:FindFirstChild("Chain")
	if chain then
		local shift = (now * chainSpeed) % 1
		for _, t in chain:GetChildren() do
			local base = t:GetAttribute("T")
			if type(base) == "number" then (t :: BasePart).CFrame = pivot * scaled(sawLoop(base + shift), scale) end
		end
	end
	local mv = m:FindFirstChild("Moving")
	if not mv then return end
	local age = useAge or 99
	local k = age < 0.05 and age / 0.05 or math.max(0, 1 - (age - 0.05) / 0.22)
	for _, part in mv:GetChildren() do
		local bp = part :: BasePart
		local mode = bp:GetAttribute("Mv")
		local rel = bp:GetAttribute("Rel")
		if typeof(rel) ~= "CFrame" then continue end
		if mode == "kick" then
			local kick = bp:GetAttribute("Kick") :: Vector3
			bp.CFrame = pivot * scaled(CFrame.new(kick * k) * rel, scale)
		elseif mode == "spin" then
			local axis = bp:GetAttribute("Axis") :: Vector3
			local ang = now * (bp:GetAttribute("Rate") :: number)
			local c = bp:GetAttribute("Center")
			local cf = typeof(c) == "Vector3" and (CFrame.new(c) * CFrame.fromAxisAngle(axis, ang) * CFrame.new(-c) * rel) or (rel * CFrame.fromAxisAngle(axis, ang))
			bp.CFrame = pivot * scaled(cf, scale)
		elseif mode == "flicker" then
			local base = bp:GetAttribute("Base") or 0
			bp.Transparency = math.clamp(base + math.noise(now * 9, bp.Size.X * 10, bp.Size.Y * 10) * 0.45 + 0.1, 0, 0.9)
		end
	end
end

-- long items lie along the shelf in the event shops
function ItemModels.isLong(shape: string): boolean
	local long = { bat = 1, spikedbat = 1, pan = 1, crowbar = 1, pipe = 1, shovel = 1, golf = 1, machete = 1, katana = 1, demonblade = 1, axe = 1, sledge = 1, warhammer = 1,
		pickaxe = 1, chainsaw = 1, shotgun = 1, cannon = 1, harpoon = 1, crossbow = 1, blower = 1, vacuum = 1, flamethrower = 1, cross = 1 }
	return long[shape] ~= nil
end

return ItemModels
