-- Builds ServerStorage.Monsters.Caller ("The Caller"): an original masked killer in the game's blocky PS2 style:
-- tall and thin under a black hooded robe with tattered sleeves and hem, black gloves and boots, a long white
-- screaming ghost mask (drooping eye holes, a long open mouth), and a long knife in a reverse grip in his right fist. His evolved
-- form (blood, a shotgun in the left hand) is dressed over this model by Server/Evolved (DRESS.Caller), which
-- relies on the part names used here (Mask, MaskEye, MaskMouth, KnifeBlade, the R15 body parts).
-- Same R15 joint names as the other monsters (GhostAnim drives it). Run in Studio (Edit); re-running replaces it.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local old = folder:FindFirstChild("Caller") if old then old.Parent = nil end
local SCALE = 0.92

local ROBE = Color3.fromRGB(20, 20, 23)
local ROBE_D = Color3.fromRGB(11, 11, 13)
local ROBE_L = Color3.fromRGB(32, 32, 36)
local MASK = Color3.fromRGB(200, 198, 190)
local MASK_D = Color3.fromRGB(160, 154, 140)
local VOID = Color3.fromRGB(4, 4, 5)
local GLOVE = Color3.fromRGB(14, 14, 15)
local ROPE = Color3.fromRGB(70, 62, 54)
local STEEL = Color3.fromRGB(206, 210, 216)
local CLOTH = Enum.Material.Fabric
local LEAN = 0.5 -- how far the eye holes lean (their lower end swings outwards)

local m = Instance.new("Model"); m.Name = "Caller"
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or CLOTH
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
local function slabs(p: BasePart, size: Vector3, color: Color3, mat: Enum.Material?)
	deco(p, p.Name .. "Round", Vector3.new(size.X * K, size.Y, size.Z * K), CFrame.new(), color, mat)
	deco(p, p.Name .. "Round", Vector3.new(size.X * K, size.Y * K, size.Z), CFrame.new(), color, mat)
end
local function rbody(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = part(name, Vector3.new(size.X, size.Y * K, size.Z * K), cf, color, mat)
	slabs(p, size, color, mat)
	return p
end
local function joint(name: string, p0: BasePart, p1: BasePart, c0: CFrame)
	local j = Instance.new("Motor6D"); j.Name = name; j.Part0 = p0; j.Part1 = p1
	j.C0 = c0; j.C1 = p1.CFrame:Inverse() * p0.CFrame * c0; j.Parent = p1
end
local A = CFrame.Angles
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end
-- strips of torn cloth hanging from a part's lower edge (lengths vary with the seed)
local function tatters(body: BasePart, n: number, width: number, y: number, z: number, minL: number, maxL: number, seed: number)
	local r = Random.new(seed)
	for i = 1, n do
		local x = (i - (n + 1) / 2) * (width / n)
		local len = r:NextNumber(minL, maxL)
		deco(body, "Tatter", Vector3.new(width / n * 0.8, len, 0.08), at(x, y - len / 2, z, r:NextNumber(-0.08, 0.08), 0, r:NextNumber(-0.1, 0.1)), i % 2 == 0 and ROBE or ROBE_D)
	end
end

-- body (rest pose, root at the origin, facing -Z): narrow shoulders, long arms and legs
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), ROBE); hrp.Transparency = 1
local lower = rbody("LowerTorso", Vector3.new(1.9, 1.0, 1.25), CFrame.new(0, 0, 0), ROBE)
local upper = rbody("UpperTorso", Vector3.new(2.3, 2.2, 1.35), CFrame.new(0, 1.6, 0), ROBE)
local head = rbody("Head", Vector3.new(1.3, 1.5, 1.35), CFrame.new(0, 3.55, 0), VOID)
joint("Root", hrp, lower, CFrame.new())
joint("Waist", lower, upper, CFrame.new(0, 0.5, 0))
joint("Neck", upper, head, CFrame.new(0, 1.1, 0))

for _, s in { -1, 1 } do
	local L = s < 0 and "Left" or "Right"
	local ua = rbody(L .. "UpperArm", Vector3.new(0.8, 1.7, 0.85), CFrame.new(s * 1.6, 1.85, 0), ROBE)
	local la = rbody(L .. "LowerArm", Vector3.new(0.72, 1.7, 0.78), CFrame.new(s * 1.6, 0.15, 0), ROBE)
	local hand = rbody(L .. "Hand", Vector3.new(0.75, 0.75, 0.55), CFrame.new(s * 1.6, -1.07, 0), GLOVE, Enum.Material.SmoothPlastic)
	joint(L .. "Shoulder", upper, ua, CFrame.new(s * 1.6, 0.95, 0))
	joint(L .. "Elbow", ua, la, CFrame.new(0, -0.85, 0))
	joint(L .. "Wrist", la, hand, CFrame.new(0, -0.85, 0))
	deco(ua, "Shoulder", Vector3.new(1.0, 0.7, 1.05), at(0, 0.6, 0), ROBE_L)
	-- a wide sleeve, open at the wrist, torn strips hanging under the forearm
	deco(la, "Sleeve", Vector3.new(0.98, 1.3, 1.1), at(0, -0.1, 0.05), ROBE_L)
	deco(la, "SleeveMouth", Vector3.new(1.08, 0.3, 1.25), at(0, -0.72, 0.08), ROBE_D)
	tatters(la, 4, 0.9, -0.55, 0.55, 1.0, 2.4, s > 0 and 3 or 7)
	for i = -1.5, 1.5 do deco(hand, "Finger", Vector3.new(0.15, 0.45, 0.22), at(i * 0.18, -0.5, -0.03, -0.2, 0, 0), GLOVE, Enum.Material.SmoothPlastic) end
	deco(hand, "Thumb", Vector3.new(0.17, 0.36, 0.22), at(-s * 0.4, -0.15, -0.15, 0, 0, s * 0.6), GLOVE, Enum.Material.SmoothPlastic)
	-- legs: the robe splits into two long halves that move with them, the hem in rags over the boots
	local ul = rbody(L .. "UpperLeg", Vector3.new(1.0, 1.9, 1.15), CFrame.new(s * 0.5, -1.45, 0), ROBE)
	local ll = rbody(L .. "LowerLeg", Vector3.new(0.92, 1.9, 1.08), CFrame.new(s * 0.5, -3.35, 0), ROBE)
	local foot = rbody(L .. "Foot", Vector3.new(0.85, 0.45, 1.5), CFrame.new(s * 0.5, -4.5, -0.25), GLOVE, Enum.Material.SmoothPlastic)
	joint(L .. "Hip", lower, ul, CFrame.new(s * 0.5, -0.5, 0))
	joint(L .. "Knee", ul, ll, CFrame.new(0, -0.95, 0))
	joint(L .. "Ankle", ll, foot, CFrame.new(0, -0.95, 0))
	deco(ul, "RobeFold", Vector3.new(0.3, 1.8, 0.12), at(s * 0.2, 0, -0.6), ROBE_D)
	tatters(ll, 4, 1.0, -0.5, -0.5, 0.5, 1.1, s > 0 and 11 or 17)
	tatters(ll, 4, 1.0, -0.5, 0.5, 0.6, 1.2, s > 0 and 23 or 29)
end

-- robe: folds down the chest, a rope belt, the hood's cowl over the shoulders
for _, x in { -0.55, 0, 0.55 } do deco(upper, "RobeFold", Vector3.new(0.14, 1.9, 0.1), at(x, -0.05, -0.7, 0, 0, x * 0.12), ROBE_D) end
deco(upper, "Cowl", Vector3.new(2.6, 0.5, 1.5), at(0, 0.95, 0.1), ROBE_L)
deco(lower, "Rope", Vector3.new(2.0, 0.16, 1.36), at(0, 0.35, 0), ROPE)
deco(lower, "RopeEnd", Vector3.new(0.12, 1.1, 0.12), at(0.5, -0.2, -0.7, 0, 0, 0.1), ROPE)
deco(lower, "RopeEnd", Vector3.new(0.12, 0.8, 0.12), at(0.66, -0.1, -0.7, 0, 0, -0.08), ROPE)
tatters(lower, 5, 1.9, -0.45, 0.66, 0.6, 1.5, 41)

-- hood: a black shell round the head, deep enough that only the mask shows
deco(head, "HoodTop", Vector3.new(1.7, 0.4, 1.75), at(0, 1.2, 0.08), ROBE)
deco(head, "HoodBack", Vector3.new(1.7, 2.5, 0.4), at(0, 0.15, 0.85), ROBE)
for _, s in { -1, 1 } do deco(head, "HoodSide", Vector3.new(0.3, 2.5, 1.6), at(s * 0.82, 0.15, 0.1), ROBE_L) end
deco(head, "HoodPeak", Vector3.new(1.3, 0.35, 0.5), at(0, 1.35, 0.75, -0.5, 0, 0), ROBE_D)
deco(head, "HoodDrape", Vector3.new(1.5, 0.9, 0.3), at(0, -1.1, 0.9, 0.25, 0, 0), ROBE)

-- the mask: a long white ghost face stretched in a scream: drooping eye holes, two slits for a nose, a long open
-- mouth, the chin running down past the hood. (MaskEye / MaskMouth are the black holes: the evolved form reddens them.)
local mask = deco(head, "Mask", Vector3.new(1.02, 1.5, 0.14), at(0, 0.18, -0.74), MASK, Enum.Material.SmoothPlastic)
deco(mask, "MaskCrown", Vector3.new(0.8, 0.22, 0.14), at(0, 0.84, 0), MASK, Enum.Material.SmoothPlastic)
deco(mask, "MaskChin", Vector3.new(0.78, 0.4, 0.14), at(0, -0.92, 0), MASK, Enum.Material.SmoothPlastic)
deco(mask, "MaskChin", Vector3.new(0.54, 0.3, 0.14), at(0, -1.24, 0), MASK, Enum.Material.SmoothPlastic)
for _, s in { -1, 1 } do
	-- an eye hole: a tall dark shape leaning outwards, its lower end hanging down toward the cheek
	deco(mask, "MaskEye", Vector3.new(0.2, 0.46, 0.06), at(s * 0.27, 0.3, -0.08, 0, 0, s * LEAN), VOID, Enum.Material.SmoothPlastic)
	deco(mask, "MaskEye", Vector3.new(0.14, 0.2, 0.06), at(s * 0.37, 0.07, -0.08, 0, 0, s * LEAN * 1.3), VOID, Enum.Material.SmoothPlastic)
	deco(mask, "MaskNose", Vector3.new(0.05, 0.1, 0.06), at(s * 0.06, -0.2, -0.08), VOID, Enum.Material.SmoothPlastic)
end
-- the mouth: a long narrow hole, a little narrower at both ends
deco(mask, "MaskMouth", Vector3.new(0.16, 0.12, 0.06), at(0, -0.42, -0.08), VOID, Enum.Material.SmoothPlastic)
deco(mask, "MaskMouth", Vector3.new(0.26, 0.62, 0.06), at(0, -0.78, -0.08), VOID, Enum.Material.SmoothPlastic)
deco(mask, "MaskMouth", Vector3.new(0.18, 0.14, 0.06), at(0, -1.15, -0.08), VOID, Enum.Material.SmoothPlastic)

-- the knife: a reverse grip, the blade coming out of the bottom of his fist. With the arm down it trails behind
-- him; with the fist raised by his shoulder it points at you, and a downward swing drives it in.
local rhand = m:FindFirstChild("RightHand") :: BasePart
deco(rhand, "KnifeHandle", Vector3.new(0.2, 0.24, 0.85), at(0, -0.12, 0.05), Color3.fromRGB(26, 22, 20), Enum.Material.SmoothPlastic)
deco(rhand, "KnifeGuard", Vector3.new(0.14, 0.6, 0.1), at(0, -0.12, 0.5), Color3.fromRGB(60, 60, 64), Enum.Material.Metal)
deco(rhand, "KnifeBlade", Vector3.new(0.07, 0.38, 1.9), at(0, -0.12, 1.5), STEEL, Enum.Material.Metal)
deco(rhand, "KnifeTip", Vector3.new(0.07, 0.4, 0.4), at(0, -0.16, 2.5, math.pi / 4, 0, 0), STEEL, Enum.Material.Metal)

m.PrimaryPart = hrp
m:PivotTo(CFrame.new(0, 4.75, 0))
if SCALE ~= 1 then m:ScaleTo(SCALE) end
m.Parent = folder
local n = 0
for _, d in m:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return "Caller built: " .. n .. " parts, size " .. tostring(m:GetExtentsSize())
