-- Builds ServerStorage.Monsters.Knight ("The Void Knight"): an original dark lord in the game's blocky PS2 style:
-- tall and broad in black plate armour, big pauldrons, a red reactor core glowing in the breastplate, a dark lord's
-- war mask (rounded dome, flared neck guard, slanted dark eye lenses, a slotted mouth grill), a long tattered cape, and a red energy blade in
-- his right fist (the blade points forward when the arm hangs: a low guard). His left hand is empty and open: it
-- is the one he reaches out with (Server/Knight, Client/GhostAnim "forcePush").
-- Part names the game relies on: the R15 body parts, LeftHand (the force effects start there), Blade.
-- Same R15 joint names as the other monsters (GhostAnim drives it). Run in Studio (Edit); re-running replaces it.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local old = folder:FindFirstChild("Knight") if old then old.Parent = nil end
local SCALE = 1.12

local ARMOR = Color3.fromRGB(17, 17, 20)
local ARMOR_L = Color3.fromRGB(38, 38, 44)
local ARMOR_D = Color3.fromRGB(8, 8, 10)
local STEEL = Color3.fromRGB(70, 72, 80)
local CAPE = Color3.fromRGB(10, 9, 11)
local CAPE_IN = Color3.fromRGB(60, 8, 10)
local RED = Color3.fromRGB(255, 40, 30)
local PLATE = Enum.Material.Metal
local CLOTH = Enum.Material.Fabric

local m = Instance.new("Model"); m.Name = "Knight"
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or PLATE
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
-- rounded blocks: a body part is three overlapping slabs (the game's PS2 look)
local K = 0.8
local function rbody(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = part(name, Vector3.new(size.X, size.Y * K, size.Z * K), cf, color, mat)
	deco(p, name .. "Round", Vector3.new(size.X * K, size.Y, size.Z * K), CFrame.new(), color, mat)
	deco(p, name .. "Round", Vector3.new(size.X * K, size.Y * K, size.Z), CFrame.new(), color, mat)
	return p
end
local function joint(name: string, p0: BasePart, p1: BasePart, c0: CFrame)
	local j = Instance.new("Motor6D"); j.Name = name; j.Part0 = p0; j.Part1 = p1
	j.C0 = c0; j.C1 = p1.CFrame:Inverse() * p0.CFrame * c0; j.Parent = p1
end
local A = CFrame.Angles
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end
local function neon(body: BasePart, name: string, size: Vector3, rel: CFrame): BasePart
	local p = deco(body, name, size, rel, RED, Enum.Material.Neon)
	p.CastShadow = false
	return p
end

-- body (rest pose, root at the origin, facing -Z): broad shoulders, a deep chest
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), ARMOR); hrp.Transparency = 1
local lower = rbody("LowerTorso", Vector3.new(2.2, 1.0, 1.4), CFrame.new(0, 0, 0), ARMOR)
local upper = rbody("UpperTorso", Vector3.new(2.8, 2.3, 1.6), CFrame.new(0, 1.65, 0), ARMOR)
local head = rbody("Head", Vector3.new(1.35, 1.5, 1.4), CFrame.new(0, 3.65, 0), ARMOR_D)
joint("Root", hrp, lower, CFrame.new())
joint("Waist", lower, upper, CFrame.new(0, 0.5, 0))
joint("Neck", upper, head, CFrame.new(0, 1.15, 0))

for _, s in { -1, 1 } do
	local L = s < 0 and "Left" or "Right"
	local ua = rbody(L .. "UpperArm", Vector3.new(0.95, 1.7, 1.0), CFrame.new(s * 1.9, 1.9, 0), ARMOR)
	local la = rbody(L .. "LowerArm", Vector3.new(0.9, 1.7, 0.95), CFrame.new(s * 1.9, 0.2, 0), ARMOR_L)
	local hand = rbody(L .. "Hand", Vector3.new(0.8, 0.8, 0.6), CFrame.new(s * 1.9, -1.05, 0), ARMOR_D)
	joint(L .. "Shoulder", upper, ua, CFrame.new(s * 1.9, 1.0, 0))
	joint(L .. "Elbow", ua, la, CFrame.new(0, -0.85, 0))
	joint(L .. "Wrist", la, hand, CFrame.new(0, -0.85, 0))
	-- pauldron: three stacked plates, the top one swept up and out
	deco(ua, "Pauldron", Vector3.new(1.5, 0.5, 1.7), at(s * 0.1, 0.75, 0), ARMOR_L)
	deco(ua, "Pauldron", Vector3.new(1.35, 0.4, 1.55), at(s * 0.2, 0.35, 0, 0, 0, -s * 0.12), ARMOR)
	deco(ua, "PauldronRim", Vector3.new(0.5, 0.3, 1.8), at(s * 0.75, 1.0, 0, 0, 0, s * 0.45), STEEL)
	-- vambrace with a raised rib, a red line down it
	deco(la, "Vambrace", Vector3.new(1.05, 1.1, 1.1), at(0, -0.1, 0), ARMOR)
	deco(la, "VambraceRib", Vector3.new(0.2, 1.2, 0.2), at(s * 0.5, -0.1, 0), STEEL)
	neon(la, "ArmLine", Vector3.new(0.06, 0.9, 0.08), at(s * 0.62, -0.1, 0))
	for i = -1.5, 1.5 do deco(hand, "Finger", Vector3.new(0.16, 0.46, 0.24), at(i * 0.19, -0.5, -0.03, -0.2, 0, 0), ARMOR_D) end
	deco(hand, "Thumb", Vector3.new(0.18, 0.38, 0.24), at(-s * 0.42, -0.15, -0.15, 0, 0, s * 0.6), ARMOR_D)
	-- legs: cuisses, a knee cap, greaves, heavy boots
	local ul = rbody(L .. "UpperLeg", Vector3.new(1.1, 1.9, 1.2), CFrame.new(s * 0.6, -1.45, 0), ARMOR)
	local ll = rbody(L .. "LowerLeg", Vector3.new(1.0, 1.9, 1.15), CFrame.new(s * 0.6, -3.35, 0), ARMOR_L)
	local foot = rbody(L .. "Foot", Vector3.new(0.95, 0.5, 1.6), CFrame.new(s * 0.6, -4.5, -0.25), ARMOR_D)
	joint(L .. "Hip", lower, ul, CFrame.new(s * 0.6, -0.5, 0))
	joint(L .. "Knee", ul, ll, CFrame.new(0, -0.95, 0))
	joint(L .. "Ankle", ll, foot, CFrame.new(0, -0.95, 0))
	deco(ul, "Tasset", Vector3.new(1.2, 1.1, 0.2), at(s * 0.05, 0.4, -0.62, 0.08, 0, 0), ARMOR_L)
	deco(ll, "KneeCap", Vector3.new(0.9, 0.55, 0.4), at(0, 0.9, -0.5), STEEL)
	deco(ll, "Greave", Vector3.new(0.7, 1.5, 0.2), at(0, -0.05, -0.6), ARMOR)
	deco(foot, "BootToe", Vector3.new(0.95, 0.3, 0.5), at(0, 0.05, -0.75), STEEL)
end

-- breastplate: two chest plates, a gorget, ribs of plate over the belly, and the reactor core burning in the middle
for _, s in { -1, 1 } do
	deco(upper, "ChestPlate", Vector3.new(1.3, 1.25, 0.3), at(s * 0.68, 0.4, -0.82, 0, s * 0.12, 0), ARMOR_L)
	deco(upper, "BackPlate", Vector3.new(1.3, 1.6, 0.25), at(s * 0.68, 0.2, 0.82), ARMOR_L)
end
deco(upper, "Gorget", Vector3.new(2.0, 0.5, 1.7), at(0, 1.2, 0), STEEL)
for i = 0, 2 do deco(upper, "BellyPlate", Vector3.new(2.2 - i * 0.18, 0.3, 0.26), at(0, -0.45 - i * 0.32, -0.78), i % 2 == 0 and ARMOR or ARMOR_L) end
deco(upper, "CoreRim", Vector3.new(0.8, 0.8, 0.2), at(0, 0.35, -0.95, 0, 0, math.pi / 4), STEEL)
local core = neon(upper, "Core", Vector3.new(0.5, 0.5, 0.22), at(0, 0.35, -0.98, 0, 0, math.pi / 4))
local cl = Instance.new("PointLight"); cl.Color = RED; cl.Range = 9; cl.Brightness = 1.6; cl.Parent = core
-- belt and the plate skirt hanging from it
deco(lower, "Belt", Vector3.new(2.4, 0.4, 1.6), at(0, 0.35, 0), STEEL)
deco(lower, "Buckle", Vector3.new(0.6, 0.5, 0.2), at(0, 0.35, -0.82), ARMOR_L)
deco(lower, "Fauld", Vector3.new(0.9, 1.5, 0.18), at(0, -0.75, -0.78, 0.06, 0, 0), ARMOR)
deco(lower, "FauldBack", Vector3.new(2.0, 1.2, 0.18), at(0, -0.6, 0.78, -0.06, 0, 0), ARMOR)

-- the cape: clasped on the shoulders, falling down his back in long torn strips (dark red inside)
deco(upper, "CapeYoke", Vector3.new(3.3, 0.4, 0.5), at(0, 1.05, 0.85), CAPE, CLOTH)
local r = Random.new(9)
for i = 1, 6 do
	local x = (i - 3.5) * 0.55
	local len = r:NextNumber(5.2, 6.4)
	deco(upper, "Cape", Vector3.new(0.6, len, 0.1), at(x, 1.0 - len / 2, 1.05 + math.abs(i - 3.5) * 0.04, -0.07, 0, (i - 3.5) * 0.02), i % 2 == 0 and CAPE or CAPE_IN, CLOTH)
end
for _, s in { -1, 1 } do deco(upper, "CapeClasp", Vector3.new(0.4, 0.4, 0.3), at(s * 1.25, 1.1, 0.7), STEEL) end

-- the helm: a dark lord's war mask. A stepped, rounded dome with a ridge down the middle and a heavy brow; the
-- neck guard flares out wide at the back and the sides; the face is an angled, skull-like mask with two slanted
-- dark eye lenses (a faint red glint deep inside), a nose ridge, cheek tubes and a triangular, slotted mouth grill.
local GLASS = Color3.fromRGB(12, 12, 16)
local function wedge(body: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("WedgePart")
	p.Name = name; p.Size = size; p.CFrame = body.CFrame * rel; p.Color = color; p.Material = mat or PLATE
	p.Anchored = false; p.CanCollide = false; p.CanTouch = false; p.CastShadow = true
	p.Parent = m
	local w = Instance.new("WeldConstraint"); w.Part0 = body; w.Part1 = p; w.Parent = p
	return p
end
-- dome: three stepped slabs, the ridge over the top, the brow over the eyes
deco(head, "HelmDome", Vector3.new(1.78, 0.62, 1.86), at(0, 0.7, 0.06), ARMOR)
deco(head, "HelmDome", Vector3.new(1.56, 0.5, 1.66), at(0, 1.02, 0.08), ARMOR)
deco(head, "HelmDome", Vector3.new(1.12, 0.28, 1.24), at(0, 1.27, 0.1), ARMOR)
deco(head, "HelmRidge", Vector3.new(0.16, 0.24, 1.7), at(0, 1.32, 0.02), ARMOR_L)
deco(head, "HelmBrow", Vector3.new(1.82, 0.3, 0.42), at(0, 0.44, -0.84, -0.18, 0, 0), ARMOR_L)
-- the neck guard: flared plates round the back and sides, wider at the bottom
deco(head, "HelmGuardBack", Vector3.new(2.0, 1.0, 0.24), at(0, -0.45, 1.0, 0.42, 0, 0), ARMOR)
deco(head, "HelmGuardRim", Vector3.new(2.5, 0.2, 0.5), at(0, -0.95, 1.22, 0.42, 0, 0), ARMOR_L)
for _, s in { -1, 1 } do
	deco(head, "HelmGuardSide", Vector3.new(0.24, 1.05, 1.7), at(s * 0.98, -0.4, 0.28, 0, 0, s * 0.4), ARMOR)
	deco(head, "HelmGuardSideRim", Vector3.new(0.45, 0.2, 1.85), at(s * 1.22, -0.92, 0.3, 0, 0, s * 0.4), ARMOR_L)
	-- the mask's cheeks, angled in toward the mouth (the face comes to a V)
	deco(head, "MaskCheek", Vector3.new(0.6, 1.0, 0.26), at(s * 0.44, -0.3, -0.84, 0, s * 0.32, 0), ARMOR)
	wedge(head, "MaskCheekbone", Vector3.new(0.5, 0.3, 0.3), at(s * 0.5, 0.0, -0.95, 0, s * 0.32, 0) * A(0, 0, 0), ARMOR_L)
	-- eye lenses: slanted dark glass, a faint red glint deep inside
	local lens = deco(head, "EyeLens", Vector3.new(0.5, 0.26, 0.08), at(s * 0.31, 0.18, -0.99, 0, 0, -s * 0.2), GLASS, Enum.Material.Glass)
	lens.Reflectance = 0.25
	local glint = neon(head, "EyeGlint", Vector3.new(0.26, 0.06, 0.03), at(s * 0.31, 0.17, -0.95, 0, 0, -s * 0.2))
	glint.Transparency = 0.35
	-- the tubes by the mouth
	local tube = deco(head, "MaskTube", Vector3.new(0.5, 0.17, 0.17), at(s * 0.4, -0.66, -0.96, 0, 0, s * 1.05), STEEL)
	;(tube :: Part).Shape = Enum.PartType.Cylinder
end
deco(head, "MaskNose", Vector3.new(0.14, 0.46, 0.2), at(0, -0.06, -1.02), ARMOR_L)
-- the mouth grill: a triangle pointing down (plates narrowing to the chin), three dark slots through it
for i = 0, 3 do
	deco(head, "MouthGrill", Vector3.new(0.72 - i * 0.15, 0.15, 0.22), at(0, -0.42 - i * 0.14, -1.0), STEEL)
end
for _, x in { -0.12, 0, 0.12 } do
	deco(head, "GrillSlot", Vector3.new(0.035, 0.42 - math.abs(x) * 1.2, 0.05), at(x, -0.58 + math.abs(x) * 0.5, -1.12), ARMOR_D)
end
deco(head, "MaskChin", Vector3.new(0.95, 0.3, 0.46), at(0, -0.98, -0.7), ARMOR_L)

-- the blade: the hilt in his right fist, the blade running forward out of it (a low guard when the arm hangs)
local rhand = m:FindFirstChild("RightHand") :: BasePart
deco(rhand, "Hilt", Vector3.new(0.28, 0.28, 1.5), at(0, -0.15, -0.1), STEEL)
deco(rhand, "HiltGuard", Vector3.new(0.5, 0.5, 0.2), at(0, -0.15, -0.85), ARMOR_L)
deco(rhand, "HiltPommel", Vector3.new(0.36, 0.36, 0.25), at(0, -0.15, 0.75), ARMOR_L)
local blade = neon(rhand, "Blade", Vector3.new(0.2, 0.2, 5.0), at(0, -0.15, -3.45))
local glow = deco(rhand, "BladeGlow", Vector3.new(0.42, 0.42, 5.0), at(0, -0.15, -3.45), RED, Enum.Material.Neon)
glow.Transparency = 0.6; glow.CastShadow = false
local bl = Instance.new("PointLight"); bl.Color = RED; bl.Range = 14; bl.Brightness = 2.2; bl.Parent = blade

m.PrimaryPart = hrp
m:PivotTo(CFrame.new(0, 4.75, 0))
if SCALE ~= 1 then m:ScaleTo(SCALE) end
m.Parent = folder
local n = 0
for _, d in m:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return "Knight built: " .. n .. " parts, size " .. tostring(m:GetExtentsSize())
