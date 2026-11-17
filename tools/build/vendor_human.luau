-- The event shops' vendor (ServerStorage.ShopVendor, used by Server/Events vendor()): a real human, not a block
-- figure. A Roblox R15 body with the classic "Man" body package (proper legs, feet, hands), dressed as a crashed pilot
-- (leather jacket, olive trousers, boots, aviator cap with goggles, fur collar, red scarf, belt) and sitting on the
-- ground against the wreck, the left leg stretched out in a bloody bandage, the right knee up with his arm on it.
-- Face: game-art/icons/vendor_face.png. Standalone (Edit): python3 tools/studio.py luau Edit tools/build/vendor_human.luau
-- Re-running replaces it. The pose is baked: every part is anchored where the joints put it.
-- Model pivot: on the ground under his hips, facing -Z (Events turns him to face the house).
local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local M = Enum.Material
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local FACE = "rbxassetid://131038525637476"
local SKIN, JACKET, PANTS, BOOTS = rgb(196, 150, 120), rgb(92, 58, 36), rgb(66, 70, 52), rgb(34, 28, 24)

for _, n in { "ShopVendor", "PilotLying" } do
	local o = SS:FindFirstChild(n)
	if o then o:Destroy() end
end
local old = workspace:FindFirstChild("VendorPreview")
if old then old:Destroy() end

local desc = Instance.new("HumanoidDescription")
-- the classic "Man" body package
desc.Head = 86498048; desc.Torso = 86500008; desc.LeftArm = 86500036; desc.RightArm = 86500054
desc.LeftLeg = 86500064; desc.RightLeg = 86500078
desc.HeadColor = SKIN; desc.TorsoColor = JACKET; desc.LeftArmColor = JACKET; desc.RightArmColor = JACKET
desc.LeftLegColor = PANTS; desc.RightLegColor = PANTS
desc.HeightScale = 1.1; desc.WidthScale = 1; desc.DepthScale = 1; desc.HeadScale = 1
local m = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
m.Name = "ShopVendor"
local anim = m:FindFirstChild("Animate") if anim then anim:Destroy() end
local hum = m:FindFirstChildOfClass("Humanoid") :: Humanoid
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
local bc = m:FindFirstChildOfClass("BodyColors") if bc then bc:Destroy() end -- the colours below are final
local function P(n: string): BasePart return m:FindFirstChild(n) :: BasePart end
-- the package's own skin textures go (a bare chest and legs): the colours below are the clothes
for _, p in m:GetChildren() do
	if p:IsA("MeshPart") then p.TextureID = "" end
	local sa = p:FindFirstChildOfClass("SurfaceAppearance") if sa then sa:Destroy() end
end
-- skin hands, boots on the feet, leather jacket, cloth trousers
for _, n in { "LeftHand", "RightHand" } do P(n).Color = SKIN end
for _, n in { "LeftFoot", "RightFoot" } do P(n).Color = BOOTS; P(n).Material = M.Leather end
for _, n in { "UpperTorso", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm" } do P(n).Material = M.Leather end
for _, n in { "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg" } do P(n).Material = M.Fabric end
local face = P("Head"):FindFirstChildOfClass("Decal")
if not face then face = Instance.new("Decal"); face.Name = "face"; face.Face = Enum.NormalId.Front; face.Parent = P("Head") end
face.Texture = FACE

-- POSE: sitting on the ground, leaning back on the wreck (joint name -> rotation added to its C0, degrees)
local root = P("HumanoidRootPart")
root.CFrame = CFrame.new(0, 20, 0)
local POSE = {
	Root = { 20, 0, 0 }, Waist = { -14, 0, 0 }, Neck = { 14, -18, 6 },
	LeftHip = { 72, 0, -6 }, LeftKnee = { -4, 0, 0 }, LeftAnkle = { -18, 0, 0 },
	RightHip = { 100, 0, 8 }, RightKnee = { -118, 0, 0 }, RightAnkle = { 22, 0, 0 },
	RightShoulder = { 44, 0, -16 }, RightElbow = { 14, 0, 0 }, RightWrist = { 10, 0, 0 },
	LeftShoulder = { 26, 0, 16 }, LeftElbow = { 12, 0, 0 }, LeftWrist = { 0, 0, 0 },
}
-- (no physics in Edit mode: every part is placed from its joint, out from the root. The rig's joints are
-- AnimationConstraints between two attachments: Part1 = Part0 * A0 * pose * A1^-1; Motor6D rigs: Part0 * C0 * pose * C1^-1)
type J = { p0: BasePart, p1: BasePart, a: CFrame, b: CFrame, name: string }
local joints = {} :: { J }
for _, j in m:GetDescendants() do
	if j:IsA("AnimationConstraint") and j.Attachment0 and j.Attachment1 then
		local a0, a1 = j.Attachment0 :: Attachment, j.Attachment1 :: Attachment
		table.insert(joints, { p0 = a0.Parent :: BasePart, p1 = a1.Parent :: BasePart, a = a0.CFrame, b = a1.CFrame, name = j.Name })
	elseif j:IsA("Motor6D") and j.Part0 and j.Part1 then
		table.insert(joints, { p0 = j.Part0, p1 = j.Part1, a = j.C0, b = j.C1, name = j.Name })
	end
end
local placed = { [root] = true }
for _ = 1, #joints do
	for _, j in joints do
		if placed[j.p0] and not placed[j.p1] then
			local r = POSE[j.name] or { 0, 0, 0 }
			j.p1.CFrame = j.p0.CFrame * j.a * CFrame.Angles(math.rad(r[1]), math.rad(r[2]), math.rad(r[3])) * j.b:Inverse()
			placed[j.p1] = true
		end
	end
end
-- a statue from here on: the joints go, every part stays anchored where it now stands
for _, j in m:GetDescendants() do
	if j:IsA("AnimationConstraint") or j:IsA("BallSocketConstraint") or j:IsA("Motor6D") then j:Destroy() end
end
-- accessories / attachments follow their parts already; everything is anchored where it now stands
for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true end end

-- the outfit (plain parts on the posed body)
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, shape: Enum.PartType?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat
	if shape then p.Shape = shape end
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = m
	return p
end
local head, ut, lt = P("Head"), P("UpperTorso"), P("LowerTorso")
local hs = head.Size
-- aviator cap: a leather dome with ear flaps, goggles pushed up on the forehead
part("Cap", Vector3.new(hs.X * 1.08, hs.Y * 0.5, hs.Z * 1.1), head.CFrame * CFrame.new(0, hs.Y * 0.32, 0.03), JACKET:Lerp(BOOTS, 0.3), M.Leather)
for _, s in { -1, 1 } do
	part("EarFlap", Vector3.new(0.14, hs.Y * 0.5, hs.Z * 0.5), head.CFrame * CFrame.new(s * hs.X * 0.53, -hs.Y * 0.02, 0.05), JACKET:Lerp(BOOTS, 0.3), M.Leather)
	part("Goggle", Vector3.new(0.34, 0.34, 0.16), head.CFrame * CFrame.new(s * hs.X * 0.2, hs.Y * 0.36, -hs.Z * 0.56) * CFrame.Angles(math.rad(-20), 0, 0), rgb(150, 120, 60), M.Glass, Enum.PartType.Cylinder).CFrame *= CFrame.Angles(0, math.rad(90), 0)
end
part("GoggleStrap", Vector3.new(hs.X * 1.1, 0.12, hs.Z * 1.12), head.CFrame * CFrame.new(0, hs.Y * 0.36, 0), rgb(40, 34, 30), M.Fabric)
local us = ut.Size
-- fur collar and a red scarf, a belt with a buckle
part("Collar", Vector3.new(us.X * 0.9, 0.26, us.Z * 1.1), ut.CFrame * CFrame.new(0, us.Y * 0.4, 0.05), rgb(168, 148, 118), M.Fabric)
part("Scarf", Vector3.new(0.5, 1.1, 0.18), ut.CFrame * CFrame.new(us.X * 0.18, us.Y * 0.12, -us.Z * 0.55) * CFrame.Angles(0, 0, math.rad(8)), rgb(150, 30, 26), M.Fabric)
local ls = lt.Size
part("Belt", Vector3.new(ls.X * 1.04, 0.28, ls.Z * 1.08), lt.CFrame * CFrame.new(0, ls.Y * 0.32, 0), rgb(40, 30, 24), M.Leather)
part("Buckle", Vector3.new(0.34, 0.24, 0.08), lt.CFrame * CFrame.new(0, ls.Y * 0.32, -ls.Z * 0.56), rgb(180, 150, 80), M.Metal)
-- the hurt leg: a bandage round the left shin, soaked through
local shin = P("LeftLowerLeg")
local ss = shin.Size
part("Bandage", Vector3.new(ss.X * 1.06, ss.Y * 0.3, ss.Z * 1.06), shin.CFrame * CFrame.new(0, ss.Y * 0.05, 0), rgb(196, 186, 164), M.Fabric)
part("Blood", Vector3.new(ss.X * 0.6, ss.Y * 0.22, 0.06), shin.CFrame * CFrame.new(0, ss.Y * 0.05, -ss.Z * 0.58), rgb(110, 12, 12), M.SmoothPlastic)
-- boots: a cuff on each shin
for _, n in { "LeftLowerLeg", "RightLowerLeg" } do
	local l = P(n)
	part("BootCuff", Vector3.new(l.Size.X * 1.1, l.Size.Y * 0.25, l.Size.Z * 1.1), l.CFrame * CFrame.new(0, -l.Size.Y * 0.36, 0), BOOTS, M.Leather)
end

-- the colours once more, last (the Humanoid's description must not paint the hands over), and it goes
local hd = hum:FindFirstChildOfClass("HumanoidDescription") if hd then hd:Destroy() end
for _, n in { "LeftHand", "RightHand", "Head" } do P(n).Color = SKIN end
-- pivot on the ground under the hips, facing -Z
local low = math.huge
for _, p in m:GetDescendants() do
	if p:IsA("BasePart") and p.Transparency < 1 then
		local cf, s = p.CFrame, p.Size
		for _, x in { -0.5, 0.5 } do for _, y in { -0.5, 0.5 } do for _, z in { -0.5, 0.5 } do
			low = math.min(low, (cf * Vector3.new(s.X * x, s.Y * y, s.Z * z)).Y)
		end end end
	end
end
local hips = lt.Position
m.PrimaryPart = root
root.PivotOffset = root.CFrame:ToObjectSpace(CFrame.new(hips.X, low, hips.Z)) -- (the model's pivot follows its PrimaryPart)
for _, p in m:GetDescendants() do
	if p:IsA("BasePart") then p.CanCollide = false; p.CanTouch = false; p.CastShadow = true end
end
-- what he says (Events sets the line for each shop)
local bb = Instance.new("BillboardGui"); bb.Size = UDim2.fromOffset(260, 60); bb.StudsOffset = Vector3.new(0, 2.6, 0); bb.MaxDistance = 40; bb.Parent = head
local q = Instance.new("TextLabel"); q.BackgroundTransparency = 1; q.Size = UDim2.fromScale(1, 1); q.Font = Enum.Font.SpecialElite; q.TextScaled = true
q.Text = "\"ugh... my leg... the stuff's on the table. cash first.\""; q.TextColor3 = Color3.fromRGB(230, 220, 195); q.TextStrokeTransparency = 0.2; q.Parent = bb
m:PivotTo(CFrame.new())
m.Parent = SS
-- a preview copy in the yard (delete it when happy): workspace.VendorPreview
local pv = m:Clone()
pv.Name = "VendorPreview"
pv:PivotTo(CFrame.new(0, 0.5, 92))
pv.Parent = workspace
local _, size = m:GetBoundingBox()
return "ShopVendor built, size " .. tostring(size) .. ", ground offset " .. string.format("%.2f", low)
