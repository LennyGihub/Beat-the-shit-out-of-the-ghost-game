-- Builds ServerStorage.Monsters.Titan ("The Flayed Giant"): an original skinless giant in the game's blocky PS2 style:
-- exposed red muscle with fibre lines, pale tendons at the joints, a lipless grin of teeth, deep sockets with small
-- glowing eyes, steam rising off the body. Same R15 joint names as the other monsters (GhostAnim drives it). Built at
-- the normal monster size, then scaled up (SCALE). Run in Studio (Edit). Re-running replaces the old model.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local old = folder:FindFirstChild("Titan") if old then old.Parent = nil end
local SCALE = 1.4

local MUSCLE = Color3.fromRGB(158, 52, 40)
local MUSCLE_D = Color3.fromRGB(112, 32, 26)
local MUSCLE_L = Color3.fromRGB(190, 78, 60)
local TENDON = Color3.fromRGB(226, 202, 182)
local BONE = Color3.fromRGB(214, 196, 168)
local TEETH = Color3.fromRGB(236, 228, 206)
local DARK = Color3.fromRGB(26, 10, 8)
local EYE = Color3.fromRGB(255, 236, 170)
local FLESH = Enum.Material.SmoothPlastic

local m = Instance.new("Model"); m.Name = "Titan"
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or FLESH
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = false; p.CanCollide = false; p.CanTouch = false; p.CastShadow = true
	p.Parent = m
	return p
end
local function deco(body: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = part(name, size, body.CFrame * rel, color, mat)
	local w = Instance.new("WeldConstraint"); w.Part0 = body; w.Part1 = p; w.Parent = p
	return p
end
local K = 0.8
local function slabs(p: BasePart, size: Vector3, color: Color3)
	deco(p, p.Name .. "Round", Vector3.new(size.X * K, size.Y, size.Z * K), CFrame.new(), color)
	deco(p, p.Name .. "Round", Vector3.new(size.X * K, size.Y * K, size.Z), CFrame.new(), color)
end
local function rbody(name: string, size: Vector3, cf: CFrame, color: Color3): BasePart
	local p = part(name, Vector3.new(size.X, size.Y * K, size.Z * K), cf, color)
	slabs(p, size, color)
	return p
end
local function rdeco(body: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3): BasePart
	local p = deco(body, name, Vector3.new(size.X, size.Y * K, size.Z * K), rel, color)
	slabs(p, size, color)
	return p
end
-- muscle fibres: thin darker lines running along a limb's front and sides
local function fibres(body: BasePart, len: number, w: number, d: number, n: number)
	for i = 1, n do
		local x = (i - (n + 1) / 2) * (w / (n + 0.5))
		deco(body, "Fibre", Vector3.new(0.06, len, 0.05), CFrame.new(x, 0, -d / 2 - 0.02) * CFrame.Angles(0, 0, (i % 2 == 0 and 0.06 or -0.05)), MUSCLE_D)
	end
end
local function joint(name: string, p0: BasePart, p1: BasePart, c0: CFrame)
	local j = Instance.new("Motor6D"); j.Name = name; j.Part0 = p0; j.Part1 = p1
	j.C0 = c0; j.C1 = p1.CFrame:Inverse() * p0.CFrame * c0; j.Parent = p1
end
local A = CFrame.Angles
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end

-- body (rest pose, root at the origin, facing -Z): lean and long-limbed
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), MUSCLE); hrp.Transparency = 1
local lower = rbody("LowerTorso", Vector3.new(2.4, 1.3, 1.6), CFrame.new(0, 0, 0), MUSCLE_D)
local upper = rbody("UpperTorso", Vector3.new(3.3, 3.1, 1.9), CFrame.new(0, 2.25, 0), MUSCLE)
local head = rbody("Head", Vector3.new(1.75, 2.0, 1.8), CFrame.new(0, 4.95, 0), MUSCLE)
joint("Root", hrp, lower, CFrame.new())
joint("Waist", lower, upper, CFrame.new(0, 0.65, 0))
joint("Neck", upper, head, CFrame.new(0, 1.55, 0))

for _, s in { -1, 1 } do
	local L = s < 0 and "Left" or "Right"
	local ua = rbody(L .. "UpperArm", Vector3.new(1.05, 2.5, 1.05), CFrame.new(s * 2.25, 2.35, 0), MUSCLE)
	local la = rbody(L .. "LowerArm", Vector3.new(0.9, 2.5, 0.9), CFrame.new(s * 2.25, -0.25, 0), MUSCLE)
	local hand = rbody(L .. "Hand", Vector3.new(1.1, 1.0, 0.6), CFrame.new(s * 2.25, -2.05, -0.05), MUSCLE_D)
	joint(L .. "Shoulder", upper, ua, CFrame.new(s * 2.25, 1.35, 0))
	joint(L .. "Elbow", ua, la, CFrame.new(0, -1.3, 0))
	joint(L .. "Wrist", la, hand, CFrame.new(0, -1.3, 0))
	rdeco(ua, "Deltoid", Vector3.new(1.35, 1.0, 1.3), at(0, 1.0, 0), MUSCLE_L)
	rdeco(ua, "Bicep", Vector3.new(0.8, 1.3, 0.55), at(0, 0.1, -0.4), MUSCLE_L)
	fibres(ua, 1.9, 0.9, 1.05, 3)
	deco(la, "ElbowTendon", Vector3.new(0.7, 0.35, 0.95), at(0, 1.2, 0.05), TENDON)
	rdeco(la, "Forearm", Vector3.new(1.0, 1.2, 0.9), at(0, 0.5, 0), MUSCLE)
	fibres(la, 2.0, 0.8, 0.9, 3)
	deco(la, "WristTendon", Vector3.new(0.95, 0.22, 0.95), at(0, -1.12, 0), TENDON)
	for i = -1.5, 1.5 do -- four long fingers
		local f = deco(hand, "Finger", Vector3.new(0.2, 0.75, 0.24), at(i * 0.27, -0.75, -0.05, -0.25, 0, 0), MUSCLE_D)
		deco(f, "Knuckle", Vector3.new(0.22, 0.12, 0.26), at(0, 0.25, 0), TENDON)
	end
	deco(hand, "Thumb", Vector3.new(0.24, 0.55, 0.26), at(-s * 0.6, -0.2, -0.2, 0, 0, s * 0.6), MUSCLE_D)
	-- legs
	local ul = rbody(L .. "UpperLeg", Vector3.new(1.2, 2.4, 1.25), CFrame.new(s * 0.72, -1.85, 0), MUSCLE)
	local ll = rbody(L .. "LowerLeg", Vector3.new(1.0, 2.4, 1.05), CFrame.new(s * 0.72, -4.25, 0), MUSCLE)
	local foot = rbody(L .. "Foot", Vector3.new(1.1, 0.5, 1.9), CFrame.new(s * 0.72, -5.7, -0.3), MUSCLE_D)
	joint(L .. "Hip", lower, ul, CFrame.new(s * 0.72, -0.6, 0))
	joint(L .. "Knee", ul, ll, CFrame.new(0, -1.25, 0))
	joint(L .. "Ankle", ll, foot, CFrame.new(0, -1.2, 0))
	rdeco(ul, "Quad", Vector3.new(1.05, 1.7, 0.5), at(0, 0.2, -0.45), MUSCLE_L)
	fibres(ul, 2.0, 1.0, 1.25, 4)
	deco(ll, "KneeTendon", Vector3.new(0.75, 0.6, 0.3), at(0, 1.05, -0.55), TENDON)
	rdeco(ll, "Calf", Vector3.new(0.85, 1.4, 0.55), at(0, 0.3, 0.4), MUSCLE_L)
	deco(ll, "Shin", Vector3.new(0.3, 2.0, 0.12), at(0, -0.1, -0.55), TENDON)
	for i = -1, 1 do deco(foot, "Toe", Vector3.new(0.3, 0.35, 0.4), at(i * 0.34, -0.05, -1.05), MUSCLE_D) end
end

-- chest: pecs, ab blocks with tendon seams, ribs under the arms, a tendon down the middle
for _, s in { -1, 1 } do
	rdeco(upper, "Pec", Vector3.new(1.45, 1.0, 0.4), at(s * 0.75, 0.75, -0.95, 0, 0, s * 0.08), MUSCLE_L)
	for r = 0, 3 do deco(upper, "Rib", Vector3.new(0.12, 0.18, 1.3), at(s * 1.62, 0.3 - r * 0.42, 0, 0, 0, s * 0.15), TENDON) end
	deco(upper, "Oblique", Vector3.new(0.5, 1.4, 0.3), at(s * 1.2, -0.75, -0.8, 0, 0, s * -0.2), MUSCLE)
end
for r = 0, 2 do
	for _, s in { -1, 1 } do rdeco(upper, "Ab", Vector3.new(0.62, 0.48, 0.3), at(s * 0.36, -0.15 - r * 0.52, -0.92), MUSCLE_L) end
end
deco(upper, "Linea", Vector3.new(0.08, 1.7, 0.08), at(0, -0.65, -1.08), TENDON)
deco(upper, "Collar", Vector3.new(2.6, 0.2, 0.2), at(0, 1.45, -0.8), BONE)
rdeco(upper, "Traps", Vector3.new(2.3, 0.6, 1.3), at(0, 1.5, 0.15), MUSCLE)
rdeco(lower, "Hips", Vector3.new(2.6, 0.7, 1.7), at(0, -0.1, 0), MUSCLE_D)

-- neck tendons (two cords from behind the ears to the collarbone)
for _, s in { -1, 1 } do
	deco(upper, "NeckCord", Vector3.new(0.2, 1.3, 0.2), at(s * 0.45, 1.85, -0.4, 0.35, 0, s * 0.25), TENDON)
end

-- head: skull ridge, deep sockets with small glowing eyes, nose holes, lipless grin of teeth, jaw muscles
rdeco(head, "Skull", Vector3.new(1.5, 0.5, 1.6), at(0, 1.05, 0.05), MUSCLE_L)
deco(head, "BrowRidge", Vector3.new(1.6, 0.3, 0.35), at(0, 0.45, -0.85), BONE)
for _, s in { -1, 1 } do
	deco(head, "Socket", Vector3.new(0.48, 0.4, 0.1), at(s * 0.4, 0.15, -0.9), DARK)
	local e = deco(head, "Eye", Vector3.new(0.16, 0.14, 0.06), at(s * 0.4, 0.15, -0.95), EYE, Enum.Material.Neon)
	local l = Instance.new("PointLight"); l.Color = EYE; l.Range = 5; l.Brightness = 0.8; l.Parent = e
	deco(head, "NoseHole", Vector3.new(0.12, 0.28, 0.08), at(s * 0.12, -0.2, -0.93), DARK)
	deco(head, "Cheek", Vector3.new(0.25, 0.9, 0.3), at(s * 0.75, -0.35, -0.7, 0, 0, s * 0.15), MUSCLE_D)
	deco(head, "Masseter", Vector3.new(0.3, 0.8, 0.5), at(s * 0.8, -0.6, -0.3), MUSCLE_L)
end
deco(head, "Mouth", Vector3.new(1.35, 0.62, 0.12), at(0, -0.62, -0.88), DARK)
for i = -4, 4 do
	deco(head, "TopTooth", Vector3.new(0.13, 0.26, 0.08), at(i * 0.15, -0.45, -0.93), TEETH)
	deco(head, "BottomTooth", Vector3.new(0.13, 0.24, 0.08), at(i * 0.15, -0.8, -0.93), TEETH)
end
deco(head, "Gums", Vector3.new(1.4, 0.1, 0.1), at(0, -0.3, -0.92), MUSCLE_D)
rdeco(head, "Chin", Vector3.new(1.0, 0.4, 1.0), at(0, -1.0, -0.35), MUSCLE)

-- steam coming off the body
local function steam(p: BasePart, rate: number)
	local pe = Instance.new("ParticleEmitter")
	pe.Name = "Steam"; pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(Color3.fromRGB(235, 230, 225))
	pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 4) })
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) })
	pe.Lifetime = NumberRange.new(1.2, 2.2); pe.Rate = rate; pe.Speed = NumberRange.new(2, 4)
	pe.Acceleration = Vector3.new(0, 3, 0); pe.SpreadAngle = Vector2.new(25, 25); pe.RotSpeed = NumberRange.new(-30, 30)
	pe.Parent = p
end
steam(upper, 5)
for _, n in { "LeftUpperArm", "RightUpperArm" } do steam(m:FindFirstChild(n) :: BasePart, 2) end

m.PrimaryPart = hrp
m:PivotTo(CFrame.new(0, 5.95, 0))
m:ScaleTo(SCALE)
m.Parent = folder
local n = 0
for _, d in m:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return "Titan built: " .. n .. " parts, size " .. tostring(m:GetExtentsSize())
