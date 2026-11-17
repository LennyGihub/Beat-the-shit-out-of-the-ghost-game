-- Builds ServerStorage.Monsters.Rat (THE SEWER RAT): a huge, fat, blocky rat on its hind legs, hand-built from plain
-- parts in the game's PS2 look (no AI mesh), with the same joint names / layout as every other monster rig (Root,
-- Waist, Neck, shoulders / elbows / wrists, hips / knees / ankles), so Client/GhostAnim drives it.
-- Run in Studio (Edit): python3 tools/studio.py luau Edit tools/build/rat.luau. Re-running replaces the old model.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local old = folder:FindFirstChild("Rat") if old then old:Destroy() end

local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local FUR, FUR_D, FUR_L = C(98, 84, 72), C(62, 54, 48), C(124, 108, 92)
local BELLY, PINK, PINK_D = C(150, 132, 112), C(206, 132, 124), C(160, 92, 90)
local CLAW, TOOTH, EYE = C(30, 26, 24), C(236, 224, 184), C(255, 44, 30)

local m = Instance.new("Model"); m.Name = "Rat"
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
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), FUR); hrp.Transparency = 1
local lower = part("LowerTorso", Vector3.new(3.2, 1.7, 2.6), CFrame.new(0, 0, 0), FUR_D)
local upper = part("UpperTorso", Vector3.new(3.6, 2.7, 2.8), CFrame.new(0, 2.0, 0), FUR)
local head = part("Head", Vector3.new(2.0, 1.7, 2.0), CFrame.new(0, 4.1, -0.2), FUR)
joint("Root", hrp, lower, CFrame.new(), CFrame.new())
joint("Waist", lower, upper, CFrame.new(0, 0.7, 0), CFrame.new(0, -1.3, 0))
joint("Neck", upper, head, CFrame.new(0, 1.3, -0.2), CFrame.new(0, -0.8, 0))
for _, s in { -1, 1 } do
	local L = s < 0 and "Left" or "Right"
	local ua = part(L .. "UpperArm", Vector3.new(0.95, 1.8, 0.95), CFrame.new(s * 2.25, 2.1, 0), FUR)
	local la = part(L .. "LowerArm", Vector3.new(0.8, 1.7, 0.8), CFrame.new(s * 2.25, 0.35, 0), FUR_D)
	local hand = part(L .. "Hand", Vector3.new(0.95, 0.6, 0.95), CFrame.new(s * 2.25, -0.8, 0), PINK)
	joint(L .. "Shoulder", upper, ua, CFrame.new(s * 2.25, 1.0, 0), CFrame.new(0, 0.9, 0))
	joint(L .. "Elbow", ua, la, CFrame.new(0, -0.9, 0), CFrame.new(0, 0.85, 0))
	joint(L .. "Wrist", la, hand, CFrame.new(0, -0.85, 0), CFrame.new(0, 0.3, 0))
	local ul = part(L .. "UpperLeg", Vector3.new(1.3, 1.6, 1.4), CFrame.new(s * 1.0, -1.65, 0), FUR_D)
	local ll = part(L .. "LowerLeg", Vector3.new(1.0, 1.5, 1.0), CFrame.new(s * 1.0, -3.2, 0), FUR_D)
	local foot = part(L .. "Foot", Vector3.new(1.1, 0.4, 2.2), CFrame.new(s * 1.0, -4.15, -0.5), PINK)
	joint(L .. "Hip", lower, ul, CFrame.new(s * 1.0, -0.85, 0), CFrame.new(0, 0.8, 0))
	joint(L .. "Knee", ul, ll, CFrame.new(0, -0.8, 0), CFrame.new(0, 0.75, 0))
	joint(L .. "Ankle", ll, foot, CFrame.new(0, -0.75, 0), CFrame.new(0, 0.2, 0.5))
	deco(ua, "ShoulderFur", Vector3.new(1.2, 0.8, 1.2), at(0, 0.75, 0), FUR_L)
	for i = -1, 1 do
		deco(hand, "Claw", Vector3.new(0.16, 0.6, 0.16), at(i * 0.3, -0.5, -0.3, -0.5, 0, 0), CLAW)
		deco(foot, "ToeClaw", Vector3.new(0.16, 0.2, 0.5), at(i * 0.33, -0.05, -1.25), CLAW)
	end
	deco(ul, "Haunch", Vector3.new(1.5, 1.2, 1.7), at(s * 0.1, 0.3, 0.1), FUR)
	-- big round-cornered ears
	deco(head, "Ear", Vector3.new(1.15, 1.25, 0.25), at(s * 1.05, 1.05, 0.25, 0, s * -0.3, s * -0.2), FUR_D)
	deco(head, "EarInside", Vector3.new(0.8, 0.9, 0.1), at(s * 1.07, 1.05, 0.1, 0, s * -0.3, s * -0.2), PINK_D)
	deco(head, "Eye", Vector3.new(0.32, 0.3, 0.12), at(s * 0.6, 0.35, -1.02), EYE, Enum.Material.Neon)
	deco(head, "Brow", Vector3.new(0.6, 0.18, 0.2), at(s * 0.6, 0.6, -1.02, 0, 0, s * -0.35), FUR_D)
	for w = 0, 1 do
		deco(head, "Whisker", Vector3.new(1.1, 0.05, 0.05), at(s * 1.05, -0.25 - w * 0.2, -2.15, 0, s * 0.3, s * (0.1 + w * 0.25)), C(200, 196, 186))
	end
	deco(head, "Tooth", Vector3.new(0.24, 0.75, 0.14), at(s * 0.17, -0.95, -2.3), TOOTH)
end
-- the head: a long snout, a pink nose, a scarred ear
deco(head, "Snout", Vector3.new(1.3, 1.05, 1.6), at(0, -0.2, -1.7), FUR_L)
deco(head, "Jaw", Vector3.new(1.0, 0.35, 1.3), at(0, -0.85, -1.55), FUR_D)
deco(head, "Nose", Vector3.new(0.55, 0.45, 0.35), at(0, 0.05, -2.6), PINK)
deco(head, "Scalp", Vector3.new(1.4, 0.4, 1.4), at(0, 0.95, 0.1), FUR_D)
-- belly, hump and a ridge of matted fur down the back
deco(upper, "Belly", Vector3.new(2.7, 2.3, 0.4), at(0, -0.2, -1.5), BELLY)
deco(lower, "BellyLow", Vector3.new(2.4, 1.2, 0.4), at(0, 0.1, -1.4), BELLY)
deco(upper, "Hump", Vector3.new(3.0, 1.6, 1.3), at(0, 0.8, 1.3), FUR_D)
for i = 0, 4 do
	deco(upper, "Spine", Vector3.new(0.5, 0.7, 0.5), at(0, 1.4 - i * 0.6, 1.95 + (i == 0 and -0.3 or 0), 0.5, 0, 0.78), FUR_D)
end
deco(upper, "Scar", Vector3.new(1.4, 0.12, 0.08), at(-0.5, 0.6, -1.72, 0, 0, 0.5), PINK_D)
-- the tail: pink segments curling down and back
local tailCF = at(0, -0.3, 1.5, -0.35, 0, 0)
local size = 0.62
for i = 1, 6 do
	deco(lower, "Tail", Vector3.new(size, size, 1.5), tailCF * at(0, 0, 0.6), i % 2 == 0 and PINK or PINK_D)
	tailCF = tailCF * at(0, 0, 1.25) * A(i < 3 and -0.28 or 0.22, (i % 2 == 0) and 0.2 or -0.12, 0)
	size *= 0.84
end
-- its eyes glow a little in the dark
local glow = Instance.new("PointLight"); glow.Color = EYE; glow.Range = 10; glow.Brightness = 0.9; glow.Shadows = false
glow.Parent = head

m.PrimaryPart = hrp
m:PivotTo(CFrame.new(0, 4.4, 0))
m.Parent = folder
return "Rat built: " .. #m:GetDescendants() .. " instances"
