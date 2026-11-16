-- Builds ServerStorage.Monsters.Demon: a big blocky red demon rig with the same joint names/layout as the
-- Woman's GhostTemplate (Root, Waist, Neck, shoulders/elbows/wrists, hips/knees/ankles), so GhostAnim drives it.
-- Run in Studio (Edit). Re-running replaces the old model.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local old = folder:FindFirstChild("Demon") if old then old.Parent = nil end

local RED = Color3.fromRGB(176, 34, 26)
local RED_D = Color3.fromRGB(128, 22, 18)
local RED_L = Color3.fromRGB(204, 58, 42)
local HORN = Color3.fromRGB(70, 22, 16)
local HORN_TIP = Color3.fromRGB(28, 14, 12)
local BLACK = Color3.fromRGB(18, 12, 10)
local FANG = Color3.fromRGB(236, 226, 200)
local EYE = Color3.fromRGB(255, 120, 40)

local m = Instance.new("Model"); m.Name = "Demon"
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
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
local function joint(name: string, p0: BasePart, p1: BasePart, c0: CFrame, c1: CFrame)
	local j = Instance.new("Motor6D"); j.Name = name; j.Part0 = p0; j.Part1 = p1; j.C0 = c0; j.C1 = c1; j.Parent = p1
end
local A = CFrame.Angles
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end

-- body (rest pose, root at the origin, facing -Z)
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), RED); hrp.Transparency = 1
local lower = part("LowerTorso", Vector3.new(2.2, 1.3, 1.3), CFrame.new(0, 0, 0), RED_D)
local upper = part("UpperTorso", Vector3.new(3.0, 2.8, 1.6), CFrame.new(0, 2.05, 0), RED)
local head = part("Head", Vector3.new(1.6, 1.7, 1.5), CFrame.new(0, 4.35, 0), RED)
joint("Root", hrp, lower, CFrame.new(), CFrame.new())
joint("Waist", lower, upper, CFrame.new(0, 0.65, 0), CFrame.new(0, -1.4, 0))
joint("Neck", upper, head, CFrame.new(0, 1.4, 0), CFrame.new(0, -0.9, 0))
for _, s in { -1, 1 } do
	local L = s < 0 and "Left" or "Right"
	local ua = part(L .. "UpperArm", Vector3.new(0.85, 2.4, 0.85), CFrame.new(s * 1.95, 2.05, 0), RED)
	local la = part(L .. "LowerArm", Vector3.new(0.75, 2.3, 0.75), CFrame.new(s * 1.95, -0.25, 0), RED_D)
	local hand = part(L .. "Hand", Vector3.new(0.85, 0.8, 0.55), CFrame.new(s * 1.95, -1.8, 0), RED_D)
	joint(L .. "Shoulder", upper, ua, CFrame.new(s * 1.95, 1.0, 0), CFrame.new(0, 1.0, 0))
	joint(L .. "Elbow", ua, la, CFrame.new(0, -1.15, 0), CFrame.new(0, 1.15, 0))
	joint(L .. "Wrist", la, hand, CFrame.new(0, -1.15, 0), CFrame.new(0, 0.4, 0))
	local ul = part(L .. "UpperLeg", Vector3.new(0.95, 2.5, 0.95), CFrame.new(s * 0.6, -1.9, 0), RED_D)
	local ll = part(L .. "LowerLeg", Vector3.new(0.85, 2.5, 0.85), CFrame.new(s * 0.6, -4.4, 0), RED_D)
	local foot = part(L .. "Foot", Vector3.new(0.9, 0.4, 1.4), CFrame.new(s * 0.6, -5.85, -0.25), BLACK)
	joint(L .. "Hip", lower, ul, CFrame.new(s * 0.6, -0.65, 0), CFrame.new(0, 1.25, 0))
	joint(L .. "Knee", ul, ll, CFrame.new(0, -1.25, 0), CFrame.new(0, 1.25, 0))
	joint(L .. "Ankle", ll, foot, CFrame.new(0, -1.25, 0), CFrame.new(0, 0.2, 0.25))
	-- muscles, claws, hooves
	deco(ua, "Bicep", Vector3.new(0.7, 1.1, 0.5), at(0, 0.2, -0.3), RED_L)
	deco(ua, "ShoulderCap", Vector3.new(1.1, 0.7, 1.05), at(0, 0.95, 0), RED_L)
	deco(la, "Forearm", Vector3.new(0.85, 1.0, 0.8), at(0, 0.5, 0), RED)
	for i = -1, 1 do
		deco(hand, "Claw", Vector3.new(0.16, 0.55, 0.16), at(i * 0.25, -0.62, -0.12, -0.35, 0, 0), BLACK)
	end
	deco(hand, "Thumb", Vector3.new(0.2, 0.4, 0.2), at(-s * 0.45, -0.1, -0.15, 0, 0, s * 0.5), RED_D)
	deco(ul, "Thigh", Vector3.new(1.05, 1.3, 1.0), at(0, 0.4, -0.05), RED)
	deco(ll, "Shin", Vector3.new(0.6, 1.4, 0.3), at(0, 0.2, -0.45), RED_L)
	deco(foot, "Hoof", Vector3.new(0.95, 0.25, 0.5), at(0, -0.05, -0.55), HORN_TIP)
end
-- chest and abs
for _, s in { -1, 1 } do deco(upper, "Pec", Vector3.new(1.35, 0.9, 0.3), at(s * 0.7, 0.6, -0.85), RED_L) end
for r = 0, 2 do for _, s in { -1, 1 } do deco(upper, "Ab", Vector3.new(0.6, 0.45, 0.22), at(s * 0.35, -0.2 - r * 0.5, -0.82), RED_L) end end
deco(upper, "Traps", Vector3.new(1.9, 0.5, 1.2), at(0, 1.45, 0.05), RED)
deco(lower, "Loincloth", Vector3.new(1.4, 1.4, 0.2), at(0, -0.8, -0.7), BLACK, Enum.Material.Fabric)
deco(lower, "Belt", Vector3.new(2.3, 0.3, 1.4), at(0, 0.4, 0), BLACK, Enum.Material.Fabric)
-- head: brow, eyes, ears, horns, nose, mouth with fangs, chin
deco(head, "Brow", Vector3.new(1.7, 0.32, 0.4), at(0, 0.32, -0.7, 0.15, 0, 0), RED_D)
for _, s in { -1, 1 } do
	deco(head, "BrowAngle", Vector3.new(0.75, 0.22, 0.35), at(s * 0.42, 0.42, -0.72, 0, 0, -s * 0.35), RED_D) -- angry slant
	local e = deco(head, "Eye", Vector3.new(0.34, 0.16, 0.12), at(s * 0.38, 0.12, -0.74, 0, 0, s * 0.2), EYE, Enum.Material.Neon)
	local l = Instance.new("PointLight"); l.Color = EYE; l.Range = 6; l.Brightness = 1.5; l.Parent = e
	deco(head, "Socket", Vector3.new(0.5, 0.3, 0.1), at(s * 0.38, 0.12, -0.71), BLACK)
	deco(head, "Cheek", Vector3.new(0.4, 0.4, 0.3), at(s * 0.6, -0.15, -0.62), RED_L)
	-- pointed ears sticking out sideways and up
	deco(head, "Ear", Vector3.new(0.7, 0.32, 0.18), at(s * 0.95, 0.1, 0, 0, 0, s * 0.5), RED)
	deco(head, "EarTip", Vector3.new(0.4, 0.2, 0.14), at(s * 1.35, 0.38, 0, 0, 0, s * 0.85), RED)
	-- horns: four segments curving up, out and back to a dark tip
	local h = at(s * 0.55, 0.85, 0.05)
	deco(head, "Horn1", Vector3.new(0.62, 0.7, 0.62), h * at(0, 0.22, 0, 0, 0, -s * 0.25), HORN)
	deco(head, "Horn2", Vector3.new(0.52, 0.7, 0.52), h * at(s * 0.26, 0.78, 0.05, 0.2, 0, -s * 0.5), HORN)
	deco(head, "Horn3", Vector3.new(0.42, 0.65, 0.42), h * at(s * 0.62, 1.2, 0.2, 0.45, 0, -s * 0.85), HORN_TIP)
	deco(head, "Horn4", Vector3.new(0.3, 0.55, 0.3), h * at(s * 1.0, 1.48, 0.42, 0.7, 0, -s * 1.15), HORN_TIP)
end
deco(head, "Nose", Vector3.new(0.34, 0.4, 0.3), at(0, -0.12, -0.82, -0.2, 0, 0), RED_D)
deco(head, "Mouth", Vector3.new(1.15, 0.42, 0.12), at(0, -0.5, -0.74), BLACK)
for i = -3, 3 do -- fangs top and bottom (the long ones at the sides)
	local long = math.abs(i) == 2
	deco(head, "FangTop", Vector3.new(0.12, long and 0.36 or 0.18, 0.08), at(i * 0.15, long and -0.42 or -0.36, -0.79), FANG)
	if i ~= 0 then deco(head, "FangBot", Vector3.new(0.11, long and 0.3 or 0.15, 0.08), at(i * 0.15, long and -0.6 or -0.66, -0.79), FANG) end
end
deco(head, "Chin", Vector3.new(1.05, 0.38, 1.2), at(0, -0.88, -0.1), RED)
deco(head, "Jaw", Vector3.new(1.7, 0.6, 1.2), at(0, -0.6, 0.05), RED_D)
-- red mist, embers and a hellish glow around him
local mist = Instance.new("ParticleEmitter")
mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
mist.Color = ColorSequence.new(Color3.fromRGB(200, 40, 25), Color3.fromRGB(60, 20, 40))
mist.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 7) })
mist.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 1) })
mist.Lifetime = NumberRange.new(2, 3.5); mist.Rate = 6; mist.Speed = NumberRange.new(0.5, 1.5)
mist.SpreadAngle = Vector2.new(180, 180); mist.LightEmission = 0.3; mist.RotSpeed = NumberRange.new(-20, 20)
mist.Parent = upper
local embers = Instance.new("ParticleEmitter")
embers.Texture = "rbxasset://textures/particles/sparkles_main.dds"
embers.Color = ColorSequence.new(Color3.fromRGB(255, 140, 40), Color3.fromRGB(255, 40, 20))
embers.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 0) })
embers.Lifetime = NumberRange.new(1, 2); embers.Rate = 10; embers.Speed = NumberRange.new(1, 3)
embers.Acceleration = Vector3.new(0, 3, 0); embers.SpreadAngle = Vector2.new(180, 180); embers.LightEmission = 1
embers.Parent = lower
local glow = Instance.new("PointLight"); glow.Color = Color3.fromRGB(255, 50, 30); glow.Range = 16; glow.Brightness = 1.6
glow.Parent = upper

m.PrimaryPart = hrp
m:PivotTo(CFrame.new(0, 6.05, 0))
m.Parent = folder
return "Demon built: " .. #m:GetDescendants() .. " instances"
