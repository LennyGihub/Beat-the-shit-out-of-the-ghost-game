-- Builds ServerStorage.Monsters.Conqueror ("The Conqueror", the secret monster): an original warlord in the game's
-- blocky PS2 style: huge and broad, purple skin, a heavy grooved jaw, a sleeveless dark blue tunic with gold trim,
-- gold-capped boots and a golden gauntlet on his right fist with one glowing purple stone. His evolved form (gold
-- war armour and a helmet) is dressed over this model by Server/Evolved (DRESS.Conqueror), which relies on the part
-- names used here. Same R15 joint names as the other monsters (GhostAnim drives it).
-- Run in Studio (Edit). Re-running replaces the old model.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local old = folder:FindFirstChild("Conqueror") if old then old.Parent = nil end
local SCALE = 1.0

local SKIN = Color3.fromRGB(146, 108, 180)
local SKIN_D = Color3.fromRGB(108, 76, 142)
local SKIN_L = Color3.fromRGB(172, 134, 202)
local ARMOR = Color3.fromRGB(36, 46, 96)
local ARMOR_D = Color3.fromRGB(22, 28, 60)
local GOLD = Color3.fromRGB(200, 154, 56)
local GOLD_D = Color3.fromRGB(142, 102, 36)
local DARK = Color3.fromRGB(20, 12, 26)
local EYE = Color3.fromRGB(190, 220, 255)
local GEM = Color3.fromRGB(190, 80, 255)
local FLESH = Enum.Material.SmoothPlastic
local METAL = Enum.Material.Metal

local m = Instance.new("Model"); m.Name = "Conqueror"
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
local function rdeco(body: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?): BasePart
	local p = deco(body, name, Vector3.new(size.X, size.Y * K, size.Z * K), rel, color, mat)
	slabs(p, size, color, mat)
	return p
end
local function joint(name: string, p0: BasePart, p1: BasePart, c0: CFrame)
	local j = Instance.new("Motor6D"); j.Name = name; j.Part0 = p0; j.Part1 = p1
	j.C0 = c0; j.C1 = p1.CFrame:Inverse() * p0.CFrame * c0; j.Parent = p1
end
local A = CFrame.Angles
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end

-- body (rest pose, root at the origin, facing -Z): a wall of a man, short thick legs under a huge chest
local hrp = part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), SKIN); hrp.Transparency = 1
local lower = rbody("LowerTorso", Vector3.new(3.1, 1.4, 2.1), CFrame.new(0, 0, 0), ARMOR_D)
local upper = rbody("UpperTorso", Vector3.new(4.4, 3.2, 2.5), CFrame.new(0, 2.3, 0), ARMOR)
local head = rbody("Head", Vector3.new(2.0, 2.1, 2.1), CFrame.new(0, 5.15, 0), SKIN)
joint("Root", hrp, lower, CFrame.new())
joint("Waist", lower, upper, CFrame.new(0, 0.7, 0))
joint("Neck", upper, head, CFrame.new(0, 1.6, 0))

for _, s in { -1, 1 } do
	local L = s < 0 and "Left" or "Right"
	local right = s > 0
	-- arms: bare and enormous; the right forearm and fist wear the golden gauntlet
	local ua = rbody(L .. "UpperArm", Vector3.new(1.55, 2.4, 1.6), CFrame.new(s * 3.0, 2.4, 0), SKIN)
	local la = rbody(L .. "LowerArm", Vector3.new(1.4, 2.3, 1.45), CFrame.new(s * 3.0, 0.05, 0), right and GOLD or SKIN, right and METAL or nil)
	local hand = rbody(L .. "Hand", Vector3.new(1.5, 1.1, 1.0), CFrame.new(s * 3.0, -1.65, -0.05), right and GOLD or SKIN_D, right and METAL or nil)
	joint(L .. "Shoulder", upper, ua, CFrame.new(s * 3.0, 1.35, 0))
	joint(L .. "Elbow", ua, la, CFrame.new(0, -1.2, 0))
	joint(L .. "Wrist", la, hand, CFrame.new(0, -1.15, 0))
	rdeco(ua, "Deltoid", Vector3.new(1.9, 1.25, 1.85), at(s * 0.05, 0.95, 0), SKIN_L)
	rdeco(ua, "Bicep", Vector3.new(1.2, 1.3, 0.6), at(0, 0.0, -0.6), SKIN_L)
	rdeco(ua, "Tricep", Vector3.new(1.1, 1.2, 0.5), at(0, 0.1, 0.62), SKIN_D)
	if right then
		-- the gauntlet: a plated sleeve, a flared cuff, armoured fingers, one stone on the back of the hand
		rdeco(la, "Gauntlet", Vector3.new(1.7, 1.8, 1.75), at(0, -0.15, 0), GOLD, METAL)
		deco(la, "GauntletCuff", Vector3.new(1.95, 0.4, 2.0), at(0, 0.85, 0), GOLD_D, METAL)
		deco(la, "GauntletBand", Vector3.new(1.8, 0.22, 1.85), at(0, -0.2, 0), GOLD_D, METAL)
		deco(la, "GauntletBand", Vector3.new(1.75, 0.22, 1.8), at(0, -0.9, 0), GOLD_D, METAL)
		for i = -1.5, 1.5 do
			local f = deco(hand, "GauntletFinger", Vector3.new(0.3, 0.75, 0.4), at(i * 0.36, -0.8, -0.1, -0.2, 0, 0), GOLD_D, METAL)
			deco(f, "Knuckle", Vector3.new(0.34, 0.2, 0.45), at(0, 0.3, -0.05), GOLD, METAL)
		end
		deco(hand, "GauntletThumb", Vector3.new(0.34, 0.6, 0.4), at(-s * 0.8, -0.25, -0.25, 0, 0, s * 0.6), GOLD_D, METAL)
		deco(hand, "GemSocket", Vector3.new(0.8, 0.8, 0.14), at(0, 0.05, 0.52), GOLD_D, METAL)
		local gem = deco(hand, "Gem", Vector3.new(0.55, 0.55, 0.16), at(0, 0.05, 0.6), GEM, Enum.Material.Neon)
		local gl = Instance.new("PointLight"); gl.Color = GEM; gl.Range = 12; gl.Brightness = 1.4; gl.Shadows = false; gl.Parent = gem
	else
		rdeco(la, "Forearm", Vector3.new(1.5, 1.3, 1.5), at(0, 0.4, 0), SKIN)
		rdeco(la, "Bracer", Vector3.new(1.55, 0.8, 1.6), at(0, -0.7, 0), ARMOR)
		deco(la, "Trim", Vector3.new(1.62, 0.16, 1.66), at(0, -0.3, 0), GOLD, METAL)
		for i = -1.5, 1.5 do
			local f = deco(hand, "Finger", Vector3.new(0.28, 0.7, 0.36), at(i * 0.35, -0.78, -0.1, -0.2, 0, 0), SKIN_D)
			deco(f, "Knuckle", Vector3.new(0.3, 0.16, 0.4), at(0, 0.28, -0.03), SKIN)
		end
		deco(hand, "Thumb", Vector3.new(0.32, 0.55, 0.38), at(-s * 0.8, -0.25, -0.25, 0, 0, s * 0.6), SKIN_D)
	end
	-- legs: dark trousers, gold-cuffed boots
	local ul = rbody(L .. "UpperLeg", Vector3.new(1.55, 2.2, 1.7), CFrame.new(s * 0.88, -1.8, 0), ARMOR_D)
	local ll = rbody(L .. "LowerLeg", Vector3.new(1.35, 2.2, 1.5), CFrame.new(s * 0.88, -4.0, 0), ARMOR)
	local foot = rbody(L .. "Foot", Vector3.new(1.45, 0.6, 2.3), CFrame.new(s * 0.88, -5.4, -0.35), ARMOR_D)
	joint(L .. "Hip", lower, ul, CFrame.new(s * 0.88, -0.6, 0))
	joint(L .. "Knee", ul, ll, CFrame.new(0, -1.1, 0))
	joint(L .. "Ankle", ll, foot, CFrame.new(0, -1.1, 0))
	rdeco(ul, "Thigh", Vector3.new(1.4, 1.5, 0.5), at(0, 0.15, -0.65), ARMOR)
	deco(ll, "BootCuff", Vector3.new(1.55, 0.35, 1.7), at(0, 0.85, 0), GOLD, METAL)
	deco(ll, "Stitch", Vector3.new(0.12, 1.5, 0.1), at(0, -0.1, -0.78), GOLD_D, METAL)
	deco(foot, "BootToe", Vector3.new(1.5, 0.45, 0.7), at(0, -0.05, -0.9), GOLD, METAL)
end

-- tunic: two chest plates, a gold V collar, a gold band across the chest, straps over the shoulders, a wide belt
for _, s in { -1, 1 } do
	rdeco(upper, "ChestPlate", Vector3.new(1.95, 1.3, 0.45), at(s * 1.02, 0.7, -1.25, 0, 0, s * 0.06), ARMOR)
	deco(upper, "Trim", Vector3.new(0.3, 2.2, 0.3), at(s * 0.85, 0.75, -1.5, 0, 0, s * 0.62), GOLD, METAL) -- the V collar
	deco(upper, "ShoulderStrap", Vector3.new(1.3, 0.4, 2.7), at(s * 1.55, 1.62, 0), GOLD, METAL)
	deco(upper, "Stitch", Vector3.new(0.1, 1.5, 0.1), at(s * 1.2, -0.75, -1.3), ARMOR_D)
	deco(upper, "Stitch", Vector3.new(0.1, 1.5, 0.1), at(s * 0.45, -0.75, -1.3), ARMOR_D)
	rdeco(upper, "Lat", Vector3.new(0.7, 2.0, 2.2), at(s * 2.0, -0.2, 0.1), ARMOR_D)
end
deco(upper, "ChestBand", Vector3.new(4.5, 0.3, 2.6), at(0, -0.15, 0), GOLD, METAL)
rdeco(upper, "Traps", Vector3.new(2.9, 0.8, 1.7), at(0, 1.6, 0.2), SKIN)
rdeco(upper, "NeckBase", Vector3.new(1.5, 0.9, 1.5), at(0, 1.75, 0), SKIN_D)
rdeco(lower, "Belt", Vector3.new(3.4, 0.55, 2.3), at(0, 0.45, 0), GOLD, METAL)
deco(lower, "BeltBuckle", Vector3.new(0.9, 0.75, 0.2), at(0, 0.45, -1.2), GOLD_D, METAL)
rdeco(lower, "Skirt", Vector3.new(3.2, 0.9, 2.2), at(0, -0.35, 0), ARMOR)

-- head: bald, a heavy brow over small cold eyes, a broad nose, a hard mouth, and the huge jaw with deep grooves
rdeco(head, "Cranium", Vector3.new(1.85, 0.7, 1.95), at(0, 0.95, 0.05), SKIN)
rdeco(head, "Brow", Vector3.new(1.95, 0.4, 0.5), at(0, 0.45, -0.95), SKIN_D)
for _, s in { -1, 1 } do
	deco(head, "Socket", Vector3.new(0.5, 0.26, 0.1), at(s * 0.45, 0.2, -1.05), DARK)
	local e = deco(head, "Eye", Vector3.new(0.2, 0.12, 0.06), at(s * 0.45, 0.2, -1.1), EYE, Enum.Material.Neon)
	local l = Instance.new("PointLight"); l.Color = EYE; l.Range = 4; l.Brightness = 0.6; l.Shadows = false; l.Parent = e
	deco(head, "Ear", Vector3.new(0.2, 0.6, 0.4), at(s * 1.05, 0.1, 0.1), SKIN_D)
	deco(head, "Cheek", Vector3.new(0.4, 0.8, 0.5), at(s * 0.78, -0.3, -0.75), SKIN_L)
end
deco(head, "Nose", Vector3.new(0.5, 0.6, 0.35), at(0, -0.05, -1.15), SKIN_L)
deco(head, "Mouth", Vector3.new(1.0, 0.1, 0.1), at(0, -0.52, -1.08), DARK)
deco(head, "MouthCorner", Vector3.new(0.12, 0.28, 0.1), at(-0.55, -0.62, -1.06, 0, 0, 0.5), DARK)
deco(head, "MouthCorner", Vector3.new(0.12, 0.28, 0.1), at(0.55, -0.62, -1.06, 0, 0, -0.5), DARK)
rdeco(head, "Chin", Vector3.new(1.75, 0.95, 1.5), at(0, -1.05, -0.4), SKIN)
for i = -2, 2 do deco(head, "ChinGroove", Vector3.new(0.09, 0.7, 0.1), at(i * 0.3, -1.1, -1.17), SKIN_D) end
deco(head, "JawLine", Vector3.new(2.05, 0.3, 1.6), at(0, -0.65, -0.2), SKIN_D)

m.PrimaryPart = hrp
m:PivotTo(CFrame.new(0, 5.75, 0))
if SCALE ~= 1 then m:ScaleTo(SCALE) end
m.Parent = folder
local n = 0
for _, d in m:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return "Conqueror built: " .. n .. " parts, size " .. tostring(m:GetExtentsSize())
