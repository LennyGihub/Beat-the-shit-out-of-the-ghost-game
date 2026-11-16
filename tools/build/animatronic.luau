-- Builds ServerStorage.Monsters.Animatronic ("The Party Bear"): an original, worn-out party-mascot bear animatronic
-- in the game's blocky PS2 style. Same R15 joint names as the other monsters (Root, Waist, Neck, shoulders/elbows/
-- wrists, hips/knees/ankles) so GhostAnim drives it. Parts tagged with the Glow attribute (eyes) stay visible when it
-- fades into the dark during its blackout. Run in Studio (Edit). Re-running replaces the old model.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local old = folder:FindFirstChild("Animatronic") if old then old.Parent = nil end

local FUR = Color3.fromRGB(128, 76, 36)
local FUR_D = Color3.fromRGB(96, 56, 26)
local TAN = Color3.fromRGB(186, 128, 70)
local BLACK = Color3.fromRGB(20, 16, 14)
local METAL = Color3.fromRGB(78, 80, 84)
local RUST = Color3.fromRGB(104, 66, 40)
local TEETH = Color3.fromRGB(230, 222, 196)
local EYE = Color3.fromRGB(236, 242, 255)
local IRIS = Color3.fromRGB(80, 150, 255)
local GRIME = Color3.fromRGB(62, 74, 36)
local HAT = Color3.fromRGB(160, 28, 34)
local HAT2 = Color3.fromRGB(226, 182, 48)
local GOLD = Color3.fromRGB(200, 160, 60)
local FAB = Enum.Material.Fabric

local m = Instance.new("Model"); m.Name = "Animatronic"
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or FAB
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = false; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.CastShadow = true
	p.Parent = m
	return p
end
local function weld(body: BasePart, p: BasePart)
	local w = Instance.new("WeldConstraint"); w.Part0 = body; w.Part1 = p; w.Parent = p
end
local function deco(body: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = part(name, size, body.CFrame * rel, color, mat)
	weld(body, p)
	return p
end
-- a chamfered "rounded" block in three slabs: the PS2 way to make a plump shape out of boxes
local K = 0.78
local function slabs(p: BasePart, size: Vector3, color: Color3, mat: Enum.Material?)
	deco(p, p.Name .. "Round", Vector3.new(size.X * K, size.Y, size.Z * K), CFrame.new(), color, mat)
	deco(p, p.Name .. "Round", Vector3.new(size.X * K, size.Y * K, size.Z), CFrame.new(), color, mat)
end
local function rbody(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = part(name, Vector3.new(size.X, size.Y * K, size.Z * K), cf, color, mat)
	slabs(p, size, color, mat)
	return p
end
local function rdeco(body: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = deco(body, name, Vector3.new(size.X, size.Y * K, size.Z * K), rel, color, mat)
	slabs(p, size, color, mat)
	return p
end
local function cyl(body: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = deco(body, name, size, rel, color, mat)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function joint(name: string, p0: BasePart, p1: BasePart, c0: CFrame)
	local j = Instance.new("Motor6D"); j.Name = name; j.Part0 = p0; j.Part1 = p1
	j.C0 = c0; j.C1 = p1.CFrame:Inverse() * p0.CFrame * c0; j.Parent = p1
end
local function glow(p: BasePart) p:SetAttribute("Glow", true); p.CastShadow = false end
local A = CFrame.Angles
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end
local MET = Enum.Material.Metal
local CORR = Enum.Material.CorrodedMetal

-- body (rest pose, root at the origin, facing -Z)
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), FUR, Enum.Material.SmoothPlastic); hrp.Transparency = 1
local lower = rbody("LowerTorso", Vector3.new(2.7, 1.35, 2.0), CFrame.new(0, 0, 0), FUR)
local upper = rbody("UpperTorso", Vector3.new(3.4, 3.0, 2.35), CFrame.new(0, 2.2, 0), FUR)
local head = rbody("Head", Vector3.new(2.7, 2.3, 2.3), CFrame.new(0, 5.1, 0), FUR)
joint("Root", hrp, lower, CFrame.new())
joint("Waist", lower, upper, CFrame.new(0, 0.65, 0))
joint("Neck", upper, head, CFrame.new(0, 1.5, 0))

for _, s in { -1, 1 } do
	local L = s < 0 and "Left" or "Right"
	-- arms: thick fur segments with bare metal joints in the gaps
	local ua = rbody(L .. "UpperArm", Vector3.new(1.15, 2.0, 1.15), CFrame.new(s * 2.4, 2.25, 0), FUR)
	local la = rbody(L .. "LowerArm", Vector3.new(1.05, 1.9, 1.05), CFrame.new(s * 2.4, 0.08, 0), FUR)
	local hand = rbody(L .. "Hand", Vector3.new(1.0, 0.9, 0.8), CFrame.new(s * 2.4, -1.45, -0.05), FUR_D)
	joint(L .. "Shoulder", upper, ua, CFrame.new(s * 2.4, 1.1, 0))
	joint(L .. "Elbow", ua, la, CFrame.new(0, -1.1, 0))
	joint(L .. "Wrist", la, hand, CFrame.new(0, -1.0, 0))
	rdeco(ua, "ShoulderPad", Vector3.new(1.35, 0.8, 1.35), at(0, 0.85, 0), FUR)
	cyl(upper, "ShoulderJoint", Vector3.new(0.7, 0.55, 0.55), at(s * 1.85, 1.0, 0), METAL, MET)
	cyl(la, "ElbowJoint", Vector3.new(0.7, 0.55, 0.55), at(0, 1.05, 0), METAL, MET)
	deco(la, "ElbowBolt", Vector3.new(0.16, 0.22, 0.22), at(s * 0.38, 1.05, 0), RUST, CORR)
	deco(la, "WristBand", Vector3.new(1.1, 0.16, 1.1), at(0, -0.72, 0), BLACK, MET)
	if s < 0 then
		-- left hand: three chunky fur fingers and a thumb
		for i = -1, 1 do
			rdeco(hand, "Finger", Vector3.new(0.3, 0.6, 0.36), at(i * 0.32, -0.62, -0.08, -0.3, 0, 0), FUR_D)
		end
		rdeco(hand, "Thumb", Vector3.new(0.32, 0.5, 0.32), at(-s * 0.55, -0.15, -0.25, 0, 0, s * 0.5), FUR_D)
	else
		-- right hand: the fur is torn off two fingers, the metal endoskeleton fingers poke out
		rdeco(hand, "Finger", Vector3.new(0.3, 0.6, 0.36), at(-0.32, -0.62, -0.08, -0.3, 0, 0), FUR_D)
		for i = 0, 1 do
			local f = deco(hand, "MetalFinger", Vector3.new(0.14, 0.55, 0.14), at(i * 0.32, -0.6, -0.08, -0.35, 0, 0), METAL, MET)
			deco(f, "MetalFingerTip", Vector3.new(0.13, 0.4, 0.13), at(0, -0.4, -0.08, -0.5, 0, 0), RUST, CORR)
			deco(f, "Knuckle", Vector3.new(0.2, 0.16, 0.2), at(0, -0.24, 0), BLACK, MET)
		end
		deco(hand, "TornEdge", Vector3.new(0.75, 0.14, 0.5), at(0.15, -0.43, -0.05, 0.15, 0, 0.1), FUR_D)
		rdeco(hand, "Thumb", Vector3.new(0.32, 0.5, 0.32), at(-s * 0.55, -0.15, -0.25, 0, 0, s * 0.5), FUR_D)
	end
	-- legs: fur thigh and shin, metal knee and ankle, big three-toed paws
	local ul = rbody(L .. "UpperLeg", Vector3.new(1.3, 2.1, 1.35), CFrame.new(s * 0.78, -1.65, 0), FUR)
	local ll = rbody(L .. "LowerLeg", Vector3.new(1.2, 2.2, 1.25), CFrame.new(s * 0.78, -3.9, 0), FUR)
	local foot = rbody(L .. "Foot", Vector3.new(1.55, 0.85, 2.3), CFrame.new(s * 0.78, -5.6, -0.35), FUR)
	joint(L .. "Hip", lower, ul, CFrame.new(s * 0.78, -0.55, 0))
	joint(L .. "Knee", ul, ll, CFrame.new(0, -1.1, 0))
	joint(L .. "Ankle", ll, foot, CFrame.new(0, -1.15, 0))
	cyl(ll, "KneeJoint", Vector3.new(0.9, 0.6, 0.6), at(0, 1.15, 0), METAL, MET)
	rdeco(ll, "KneeCap", Vector3.new(0.8, 0.55, 0.4), at(0, 0.85, -0.6), FUR_D)
	deco(ll, "Seam", Vector3.new(0.08, 1.4, 0.06), at(s * 0.3, -0.2, -0.64), BLACK)
	cyl(foot, "AnkleJoint", Vector3.new(0.8, 0.5, 0.5), at(0, 0.5, 0.35), METAL, MET)
	for i = -1, 1 do
		rdeco(foot, "Toe", Vector3.new(0.48, 0.6, 0.55), at(i * 0.5, -0.12, -1.15), FUR)
		deco(foot, "ToeGap", Vector3.new(0.06, 0.5, 0.3), at(i * 0.5 + 0.25, -0.12, -1.3), BLACK)
	end
end

-- torso: big tan belly, grime stains, a ripped patch at the right shoulder with the wiring hanging out
rdeco(upper, "Gut", Vector3.new(3.6, 1.6, 2.6), at(0, -0.7, 0), FUR)
rdeco(upper, "Belly", Vector3.new(2.6, 2.4, 0.5), at(0, -0.45, -1.2), TAN)
rdeco(lower, "LowerBelly", Vector3.new(2.0, 0.95, 0.45), at(0, 0.15, -0.88), TAN)
-- grime: overlapping crooked blotches running down the belly
for _, b in { { -0.9, 0.1, 0.42, 0.5, 0.3 }, { -0.82, -0.35, 0.34, 0.6, -0.2 }, { -0.95, -0.8, 0.3, 0.55, 0.5 }, { -0.7, -1.2, 0.36, 0.3, 0.1 }, { -0.55, -0.6, 0.18, 0.25, 0.7 } } do
	deco(upper, "Stain", Vector3.new(b[3], b[4], 0.05), at(b[1], b[2], -1.45, 0, 0, b[5]), GRIME)
end
deco(upper, "Stain", Vector3.new(0.22, 0.3, 0.05), at(0.75, -1.0, -1.45, 0, 0, 0.4), FUR_D)
deco(upper, "Rip", Vector3.new(0.6, 0.45, 0.06), at(1.3, 1.05, -1.17, 0, 0, 0.5), BLACK)
deco(upper, "Rip", Vector3.new(0.45, 0.5, 0.06), at(1.12, 0.9, -1.17, 0, 0, -0.3), BLACK)
deco(upper, "EndoPlate", Vector3.new(0.3, 0.25, 0.05), at(1.22, 1.0, -1.2, 0, 0, 0.2), METAL, MET)
for i, c in { Color3.fromRGB(130, 30, 30), BLACK, Color3.fromRGB(30, 50, 120) } do
	deco(upper, "Wire", Vector3.new(0.06, 0.6, 0.06), at(1.05 + i * 0.1, 0.62, -1.24, -0.15, 0, (i - 2) * 0.25), c, Enum.Material.SmoothPlastic)
end
deco(upper, "WaistRing", Vector3.new(2.3, 0.22, 1.75), at(0, -1.55, 0), METAL, MET)
-- collar with a dented brass bell
deco(upper, "Collar", Vector3.new(2.1, 0.32, 2.0), at(0, 1.48, 0), HAT, Enum.Material.Leather)
local bell = deco(upper, "Bell", Vector3.new(0.6, 0.6, 0.6), at(0, 1.15, -1.1), GOLD, MET)
bell.Shape = Enum.PartType.Ball
deco(bell, "BellSlit", Vector3.new(0.4, 0.07, 0.05), at(0, -0.12, -0.28), BLACK, MET)

-- head: rounded cranium, snout, open jaw with flat teeth, wide round eyes, round ears, party hat
rdeco(head, "Cranium", Vector3.new(2.3, 0.45, 2.0), at(0, 1.2, 0), FUR)
rdeco(head, "Snout", Vector3.new(2.0, 0.85, 1.1), at(0, -0.48, -1.2), TAN)
rdeco(head, "Nose", Vector3.new(0.8, 0.42, 0.4), at(0, -0.12, -1.72), BLACK, Enum.Material.SmoothPlastic)
for _, s in { -1, 1 } do
	for k = 0, 2 do deco(head, "Freckle", Vector3.new(0.09, 0.09, 0.05), at(s * (0.5 + (k % 2) * 0.16), -0.45 - k * 0.1, -1.76), FUR_D) end
end
deco(head, "Lip", Vector3.new(1.7, 0.1, 0.1), at(0, -0.86, -1.72), BLACK)
local jaw = rdeco(head, "Jaw", Vector3.new(1.7, 0.45, 1.15), at(0, -1.12, -1.0, 0.18, 0, 0), TAN)
deco(jaw, "MouthInside", Vector3.new(1.4, 0.06, 0.9), at(0, 0.24, 0.0), BLACK)
for i = -2, 2 do
	deco(jaw, "Tooth", Vector3.new(0.24, 0.26, 0.08), at(i * 0.26, 0.28, -0.52), TEETH, Enum.Material.SmoothPlastic)
end
for i = -2, 2 do
	deco(head, "TopTooth", Vector3.new(0.24, 0.24, 0.07), at(i * 0.27, -1.0, -1.7), TEETH, Enum.Material.SmoothPlastic)
end
for _, s in { -1, 1 } do
	deco(head, "Socket", Vector3.new(0.86, 0.68, 0.1), at(s * 0.58, 0.32, -1.13), BLACK, Enum.Material.SmoothPlastic)
	local white = deco(head, "Eye", Vector3.new(0.68, 0.52, 0.08), at(s * 0.58, 0.32, -1.17), EYE, Enum.Material.SmoothPlastic)
	glow(white); white:SetAttribute("DarkNeon", true)
	local iris = deco(head, "Iris", Vector3.new(0.3, 0.34, 0.06), at(s * 0.5, 0.28, -1.22), IRIS, Enum.Material.Neon)
	glow(iris)
	local pupil = deco(head, "Pupil", Vector3.new(0.13, 0.15, 0.04), at(s * 0.5, 0.28, -1.25), BLACK, Enum.Material.SmoothPlastic)
	glow(pupil)
	local shine = deco(head, "Shine", Vector3.new(0.07, 0.07, 0.03), at(s * 0.46, 0.33, -1.275), EYE, Enum.Material.Neon)
	glow(shine)
	local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(190, 215, 255); l.Range = 5; l.Brightness = 0.5; l.Parent = white
	-- soft halo, only on in the blackout (GhostAnim): a few pixels minimum so the eyes read from across a room
	local halo = Instance.new("BillboardGui"); halo.Name = "EyeHalo"; halo.Enabled = false; halo.LightInfluence = 0
	halo.Size = UDim2.new(1.3, 5, 1.1, 4); halo.Parent = white
	for i, sc in { 1, 0.55 } do
		local f = Instance.new("Frame"); f.AnchorPoint = Vector2.new(0.5, 0.5); f.Position = UDim2.fromScale(0.5, 0.5)
		f.Size = UDim2.fromScale(sc, sc); f.BorderSizePixel = 0; f.BackgroundColor3 = Color3.fromRGB(200, 222, 255)
		f.BackgroundTransparency = i == 1 and 0.82 or 0.55; f.Parent = halo
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = f
	end
	deco(head, "Brow", Vector3.new(0.78, 0.16, 0.12), at(s * 0.6, 0.8, -1.16, 0, 0, -s * 0.12), BLACK, Enum.Material.SmoothPlastic)
	-- round ears: a fur disc with a tan inner disc, on a short stalk
	local ear = cyl(head, "Ear", Vector3.new(0.38, 1.2, 1.2), at(s * 1.05, 1.35, 0.15, 0, 0, s * 0.3) * A(0, math.pi / 2, 0), FUR, FAB)
	cyl(ear, "InnerEar", Vector3.new(0.1, 0.72, 0.72), at(0.18, 0, 0), TAN, FAB)
	deco(head, "EarStalk", Vector3.new(0.5, 0.45, 0.35), at(s * 0.85, 1.05, 0.15, 0, 0, s * 0.3), FUR)
	rdeco(head, "Cheek", Vector3.new(0.55, 0.7, 0.9), at(s * 1.2, -0.35, -0.55), FUR)
end
-- crooked party hat: stacked red boxes with a yellow band, a pom-pom on top
local hatBase = at(-0.1, 1.42, 0.1, 0.1, 0, 0.18)
local hy = 0
for i, w in { 1.0, 0.82, 0.65, 0.48, 0.33, 0.2 } do
	deco(head, "Hat", Vector3.new(w, 0.32, w), hatBase * at(0, hy + 0.16, 0), (i == 2 or i == 4) and HAT2 or HAT, Enum.Material.SmoothPlastic)
	hy += 0.3
end
local pom = deco(head, "HatPom", Vector3.new(0.38, 0.38, 0.38), hatBase * at(0, hy + 0.12, 0), HAT2, FAB)
pom.Shape = Enum.PartType.Ball

m.PrimaryPart = hrp
m:PivotTo(CFrame.new(0, 6.05, 0))
m.Parent = folder
local n = 0
for _, d in m:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return "Animatronic built: " .. n .. " parts, size " .. tostring(m:GetExtentsSize())
