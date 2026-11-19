-- Builds BLACKWATER HARBOR's three new monsters into ServerStorage.Monsters (Edit, standalone; re-running replaces
-- them): python3 tools/studio.py luau Edit tools/build/harbor_monsters.luau
--   DeepOne  THE DEEP ONE: a hunched fish-man, grey-green scales and a pale belly, a big fish head with bulging
--            glowing eyes, a lipless mouth full of needle teeth, gill slits, a ragged dorsal fin down his back, webbed
--            fins on his forearms, flipper feet, seaweed hanging off him.
--   Keeper   THE KEEPER: the drowned lighthouse keeper - a yellow oilskin coat to the knees and a sou'wester, a big
--            grey beard, a pale dead face with white pinpoint eyes, black boots, his lamp in his right hand (the part
--            "Flame": Server/HarborMonsters shoots its beam from it; Client/Entrance lights it in his entrance).
--   Netman   THE NETMAN: a huge drowned dockhand - blue-grey skin, a red knit cap, a striped shirt and a rubber
--            apron, a cargo hook for a left hand, a fishing net over his shoulder and an anchor on his back.
-- Hand-built from plain parts (the camp monsters' rig builder, copied from tools/build/carnival_monsters.luau): the
-- joint layout every monster rig shares, so Client/GhostAnim drives them.
local SS = game:GetService("ServerStorage")
local folder = SS:FindFirstChild("Monsters") or Instance.new("Folder")
folder.Name = "Monsters"; folder.Parent = SS
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local A = CFrame.Angles
local M = Enum.Material
local function at(x, y, z, rx, ry, rz) return CFrame.new(x, y, z) * A(rx or 0, ry or 0, rz or 0) end

-- a rig builder: R = { part, deco, joint }; returns the model and its body parts by name
local function rig(name: string)
	local old = folder:FindFirstChild(name) if old then old:Destroy() end
	local m = Instance.new("Model"); m.Name = name
	local R = {}
	function R.part(pname: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): BasePart
		local p = Instance.new("Part")
		p.Name = pname; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or M.SmoothPlastic
		if shape then p.Shape = shape end
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Anchored = false; p.CanCollide = false; p.CanTouch = false; p.CastShadow = true
		p.Parent = m
		return p
	end
	function R.deco(body: BasePart, pname: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): BasePart
		local p = R.part(pname, size, body.CFrame * rel, color, mat, shape)
		local w = Instance.new("WeldConstraint"); w.Part0 = body; w.Part1 = p; w.Parent = p
		return p
	end
	function R.joint(jname: string, p0: BasePart, p1: BasePart, c0: CFrame, c1: CFrame)
		local j = Instance.new("Motor6D"); j.Name = jname; j.Part0 = p0; j.Part1 = p1; j.C0 = c0; j.C1 = c1; j.Parent = p1
	end
	-- a humanoid body: o = sizes / colours; returns the parts
	function R.body(o)
		local B = {}
		B.hrp = R.part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(), o.skin); B.hrp.Transparency = 1
		B.lower = R.part("LowerTorso", o.lowerSize, CFrame.new(0, 0, 0), o.lowerColor)
		local uy = o.lowerSize.Y / 2 + o.upperSize.Y / 2 - 0.1
		B.upper = R.part("UpperTorso", o.upperSize, CFrame.new(0, uy, 0), o.upperColor, o.upperMat)
		local hy = uy + o.upperSize.Y / 2 + o.headSize.Y / 2 + 0.15
		B.head = R.part("Head", o.headSize, CFrame.new(0, hy, 0), o.headColor or o.skin, o.headMat)
		R.joint("Root", B.hrp, B.lower, CFrame.new(), CFrame.new())
		R.joint("Waist", B.lower, B.upper, CFrame.new(0, o.lowerSize.Y / 2 - 0.1, 0), CFrame.new(0, -o.upperSize.Y / 2, 0))
		R.joint("Neck", B.upper, B.head, CFrame.new(0, o.upperSize.Y / 2, 0), CFrame.new(0, -o.headSize.Y / 2 - 0.15, 0))
		local sx = o.upperSize.X / 2 + o.armW / 2
		local shY = uy + o.upperSize.Y / 2 - 0.4
		local hipX = o.lowerSize.X / 2 - o.legW / 2
		for _, s in { -1, 1 } do
			local L = s < 0 and "Left" or "Right"
			local ua = R.part(L .. "UpperArm", Vector3.new(o.armW, o.upperArm, o.armW), CFrame.new(s * sx, shY - o.upperArm / 2, 0), o.sleeve or o.upperColor, o.sleeveMat)
			local la = R.part(L .. "LowerArm", Vector3.new(o.armW * 0.85, o.lowerArm, o.armW * 0.85), CFrame.new(s * sx, shY - o.upperArm - o.lowerArm / 2, 0), o.forearm or o.skin, o.forearmMat)
			local hd = R.part(L .. "Hand", Vector3.new(o.armW * 0.9, o.hand, o.armW * 0.9), CFrame.new(s * sx, shY - o.upperArm - o.lowerArm - o.hand / 2, 0), o.handColor or o.skin)
			R.joint(L .. "Shoulder", B.upper, ua, CFrame.new(s * sx, o.upperSize.Y / 2 - 0.4, 0), CFrame.new(0, o.upperArm / 2, 0))
			R.joint(L .. "Elbow", ua, la, CFrame.new(0, -o.upperArm / 2, 0), CFrame.new(0, o.lowerArm / 2, 0))
			R.joint(L .. "Wrist", la, hd, CFrame.new(0, -o.lowerArm / 2, 0), CFrame.new(0, o.hand / 2, 0))
			local hipY = -o.lowerSize.Y / 2 + 0.1
			local ul = R.part(L .. "UpperLeg", Vector3.new(o.legW, o.upperLeg, o.legW), CFrame.new(s * hipX, hipY - o.upperLeg / 2, 0), o.legColor, o.legMat)
			local ll = R.part(L .. "LowerLeg", Vector3.new(o.legW * 0.85, o.lowerLeg, o.legW * 0.85), CFrame.new(s * hipX, hipY - o.upperLeg - o.lowerLeg / 2, 0), o.shinColor or o.legColor, o.legMat)
			local ft = R.part(L .. "Foot", Vector3.new(o.legW * 0.95, 0.45, o.footLen), CFrame.new(s * hipX, hipY - o.upperLeg - o.lowerLeg - 0.22, -o.footLen / 2 + 0.4), o.footColor)
			R.joint(L .. "Hip", B.lower, ul, CFrame.new(s * hipX, hipY, 0), CFrame.new(0, o.upperLeg / 2, 0))
			R.joint(L .. "Knee", ul, ll, CFrame.new(0, -o.upperLeg / 2, 0), CFrame.new(0, o.lowerLeg / 2, 0))
			R.joint(L .. "Ankle", ll, ft, CFrame.new(0, -o.lowerLeg / 2, 0), CFrame.new(0, 0.22, -o.footLen / 2 + 0.4))
			B[L .. "UpperArm"] = ua; B[L .. "LowerArm"] = la; B[L .. "Hand"] = hd
			B[L .. "UpperLeg"] = ul; B[L .. "LowerLeg"] = ll; B[L .. "Foot"] = ft
		end
		B.hover = o.lowerSize.Y / 2 - 0.1 + o.upperLeg + o.lowerLeg + 0.45
		return B
	end
	function R.finish(B, extra: number?)
		m.PrimaryPart = B.hrp
		m:PivotTo(CFrame.new(0, B.hover + (extra or 0), 0))
		m:SetAttribute("Hover", B.hover)
		m.Parent = folder
		return m
	end
	return R, m
end
local out = {}

-- the joint signs on this rig: Shoulder +X = arm forward / up, +Z (right arm) = out to the side, -Z (left arm) = out;
-- Root / Waist / Neck +X = lean back.

-- the joint signs on this rig: Shoulder +X = arm forward / up, +Z (right arm) = out to the side, -Z (left arm) = out;
-- Root / Waist / Neck +X = lean back.

---------------------------------------------------------------------------------------------- THE DEEP ONE
do
	local R = rig("DeepOne")
	local SCALE, BELLY, FIN, DARK = C(66, 92, 84), C(148, 158, 126), C(34, 74, 74), C(14, 18, 18)
	local B = R.body({ skin = SCALE, lowerSize = Vector3.new(2.2, 1.4, 1.5), lowerColor = SCALE, upperSize = Vector3.new(2.8, 2.5, 1.9), upperColor = SCALE,
		upperMat = M.Slate, headSize = Vector3.new(2.0, 1.8, 2.3), headColor = SCALE, headMat = M.Slate, armW = 0.8, upperArm = 2.2, lowerArm = 2.3, hand = 1.1,
		sleeve = SCALE, sleeveMat = M.Slate, forearm = SCALE, forearmMat = M.Slate, handColor = C(80, 110, 98), legW = 1.0, upperLeg = 1.9, lowerLeg = 1.9,
		footLen = 2.4, legColor = SCALE, legMat = M.Slate, footColor = FIN })
	-- the pale belly, a scale pattern
	R.deco(B.upper, "Belly", Vector3.new(1.9, 2.1, 0.08), at(0, -0.1, -0.97), BELLY, M.Slate)
	for _, p in { { -0.9, 0.7 }, { 0.9, 0.7 }, { -1.0, -0.3 }, { 1.0, -0.3 }, { 0, 0.95 } } do
		R.deco(B.upper, "Scale", Vector3.new(0.4, 0.3, 0.05), at(p[1], p[2], -0.97, 0, 0, math.pi / 4), FIN)
	end
	-- the fish head: bulging glowing eyes on the sides, a wide mouth with needle teeth, gills
	for _, s in { -1, 1 } do
		R.deco(B.head, "EyeBulge", Vector3.one * 0.75, at(s * 0.95, 0.35, -0.55), C(200, 210, 120), M.Neon, Enum.PartType.Ball)
		R.deco(B.head, "Pupil", Vector3.new(0.1, 0.35, 0.35), at(s * 1.32, 0.35, -0.6), DARK)
		for k = 0, 2 do R.deco(B.head, "Gill", Vector3.new(0.05, 0.6, 0.12), at(s * 1.02, -0.3, 0.2 + k * 0.3), C(120, 30, 40)) end
		R.deco(B[(s < 0 and "Left" or "Right") .. "LowerArm"], "ArmFin", Vector3.new(0.1, 1.6, 0.9), at(s * 0.45, 0, 0.45, 0, 0, s * 0.2), FIN)
		R.deco(B[(s < 0 and "Left" or "Right") .. "Hand"], "Web", Vector3.new(0.05, 0.9, 1.1), at(0, -0.3, -0.3), FIN)
		R.deco(B[(s < 0 and "Left" or "Right") .. "Foot"], "Flipper", Vector3.new(1.4, 0.15, 1.6), at(0, -0.1, -1.0), FIN)
	end
	R.deco(B.head, "Mouth", Vector3.new(1.7, 0.45, 0.08), at(0, -0.5, -1.16), C(40, 10, 14))
	for i = -3, 3 do
		R.deco(B.head, "Tooth", Vector3.new(0.12, 0.28, 0.06), at(i * 0.22, -0.33, -1.19, 0, 0, math.pi), C(236, 232, 210), M.SmoothPlastic, Enum.PartType.Wedge)
		R.deco(B.head, "Tooth", Vector3.new(0.12, 0.25, 0.06), at(i * 0.22 + 0.1, -0.68, -1.19), C(236, 232, 210), M.SmoothPlastic, Enum.PartType.Wedge)
	end
	R.deco(B.head, "Lure", Vector3.new(0.12, 1.3, 0.12), at(0, 1.3, -0.6, -0.6, 0, 0), FIN)
	R.deco(B.head, "LureLight", Vector3.one * 0.4, at(0, 1.95, -1.15), C(120, 255, 210), M.Neon, Enum.PartType.Ball)
	-- the dorsal fin down his head and back
	for k = 0, 4 do
		R.deco(k < 2 and B.head or B.upper, "Dorsal", Vector3.new(0.12, 1.1 - k * 0.12, 0.9), k < 2 and at(0, 1.0, 0.3 + k * 0.6, -0.3, 0, 0) or at(0, 1.2 - (k - 2) * 0.8, 1.05, -0.5, 0, 0), FIN)
	end
	-- seaweed hanging off his shoulders
	for _, p in { { -1.2, 1.2 }, { 1.0, 1.25 }, { 0.3, 1.3 } } do
		for k = 0, 2 do R.deco(B.upper, "Weed", Vector3.new(0.18, 0.7, 0.08), at(p[1] + k * 0.05, p[2] - k * 0.6, -0.95 + k * 0.05, 0, 0, k * 0.2), C(40, 90, 40), M.Grass) end
	end
	local glow = Instance.new("PointLight"); glow.Color = C(120, 255, 210); glow.Range = 10; glow.Brightness = 1.2
	glow.Parent = B.head
	R.finish(B)
	table.insert(out, "DeepOne hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE KEEPER
do
	local R = rig("Keeper")
	local OIL, OILD, FACE, BEARD, BOOT = C(190, 150, 40), C(140, 104, 28), C(150, 162, 156), C(200, 200, 196), C(20, 18, 18)
	local B = R.body({ skin = FACE, lowerSize = Vector3.new(2.1, 1.4, 1.4), lowerColor = OIL, upperSize = Vector3.new(2.5, 2.6, 1.6), upperColor = OIL,
		upperMat = M.SmoothPlastic, headSize = Vector3.new(1.4, 1.5, 1.4), headColor = FACE, armW = 0.8, upperArm = 2.1, lowerArm = 2.0, hand = 0.9,
		sleeve = OIL, sleeveMat = M.SmoothPlastic, forearm = OIL, forearmMat = M.SmoothPlastic, handColor = FACE, legW = 0.95, upperLeg = 2.0, lowerLeg = 2.0,
		footLen = 1.8, legColor = C(40, 44, 56), legMat = M.Fabric, shinColor = BOOT, footColor = BOOT })
	-- the oilskin: buttons, a collar, the skirt of the coat down to his knees (front and back flaps)
	for k = 0, 3 do R.deco(B.upper, "Button", Vector3.new(0.22, 0.22, 0.08), at(0, 0.9 - k * 0.6, -0.82), C(40, 36, 30)) end
	R.deco(B.upper, "Collar", Vector3.new(2.3, 0.5, 1.7), at(0, 1.25, 0, 0.15, 0, 0), OILD)
	for _, s in { -1, 1 } do
		R.deco(B[(s < 0 and "Left" or "Right") .. "UpperLeg"], "CoatSkirt", Vector3.new(1.15, 1.8, 1.5), at(0, 0.2, 0), OIL)
		R.deco(B.head, "Eye", Vector3.new(0.28, 0.2, 0.05), at(s * 0.32, 0.18, -0.71), C(10, 10, 12))
		R.deco(B.head, "Pupil", Vector3.new(0.08, 0.08, 0.04), at(s * 0.32, 0.18, -0.74), C(240, 250, 255), M.Neon)
		R.deco(B.head, "Brow", Vector3.new(0.4, 0.12, 0.08), at(s * 0.34, 0.38, -0.72, 0, 0, s * -0.25), BEARD)
	end
	-- the great grey beard
	R.deco(B.head, "Beard", Vector3.new(1.45, 1.1, 0.5), at(0, -0.7, -0.55), BEARD, M.Fabric)
	R.deco(B.head, "BeardTip", Vector3.new(1.0, 0.9, 0.4), at(0, -1.45, -0.6, 0.15, 0, 0), BEARD, M.Fabric)
	R.deco(B.head, "Moustache", Vector3.new(1.0, 0.25, 0.3), at(0, -0.22, -0.78), BEARD, M.Fabric)
	-- the sou'wester: a rounded crown and a brim that drops at the back
	R.deco(B.head, "Crown", Vector3.new(1.55, 0.6, 1.55), at(0, 0.95, 0.05), OIL)
	R.deco(B.head, "Brim", Vector3.new(2.0, 0.12, 1.5), at(0, 0.66, -0.25), OIL)
	R.deco(B.head, "BackBrim", Vector3.new(2.0, 0.12, 1.2), at(0, 0.45, 0.75, -0.45, 0, 0), OIL)
	-- the lamp in his right hand: a black iron cage, the glass, the flame (its light), a handle
	local hand = B.RightHand
	local lamp = R.deco(hand, "Lamp", Vector3.new(0.9, 1.2, 0.9), at(0, -1.25, 0), C(30, 30, 30), M.Metal)
	lamp.Transparency = 0.55
	R.deco(hand, "LampTop", Vector3.new(1.0, 0.25, 1.0), at(0, -0.55, 0), C(30, 30, 30), M.Metal)
	R.deco(hand, "LampBase", Vector3.new(1.0, 0.25, 1.0), at(0, -1.95, 0), C(30, 30, 30), M.Metal)
	R.deco(hand, "LampRing", Vector3.new(0.12, 0.6, 0.12), at(0, -0.25, 0), C(30, 30, 30), M.Metal)
	local flame = R.deco(hand, "Flame", Vector3.new(0.55, 0.7, 0.55), at(0, -1.25, 0), C(255, 236, 170), M.Neon)
	local l = Instance.new("PointLight"); l.Color = C(255, 220, 150); l.Range = 14; l.Brightness = 0.7; l.Shadows = true; l.Parent = flame
	R.finish(B)
	table.insert(out, "Keeper hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE NETMAN
do
	local R = rig("Netman")
	local SKIN, SHIRT, STRIPE, APRON, CAP, IRON = C(106, 120, 132), C(36, 44, 74), C(150, 146, 136), C(170, 84, 30), C(150, 30, 30), C(60, 60, 64)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(2.7, 1.6, 1.9), lowerColor = C(52, 56, 70), upperSize = Vector3.new(3.5, 3.0, 2.1), upperColor = SHIRT,
		upperMat = M.Fabric, headSize = Vector3.new(1.6, 1.6, 1.5), headColor = SKIN, armW = 1.1, upperArm = 2.3, lowerArm = 2.2, hand = 1.1,
		sleeve = SHIRT, sleeveMat = M.Fabric, forearm = SKIN, handColor = SKIN, legW = 1.2, upperLeg = 2.2, lowerLeg = 2.1,
		footLen = 2.0, legColor = C(52, 56, 70), legMat = M.Fabric, shinColor = C(20, 20, 22), footColor = C(20, 20, 22) })
	-- the stripes, the rubber apron and its straps
	for k = 0, 4 do R.deco(B.upper, "Stripe", Vector3.new(3.55, 0.22, 2.15), at(0, 1.1 - k * 0.55, 0), STRIPE, M.Fabric) end
	R.deco(B.upper, "Apron", Vector3.new(2.4, 2.4, 0.1), at(0, -0.4, -1.1), APRON, M.Plastic)
	R.deco(B.lower, "ApronSkirt", Vector3.new(2.5, 2.6, 0.1), at(0, -1.0, -1.0), APRON, M.Plastic)
	for _, s in { -1, 1 } do
		R.deco(B.upper, "Strap", Vector3.new(0.3, 3.05, 0.12), at(s * 0.95, 0, -1.1), APRON, M.Plastic)
		R.deco(B.head, "Eye", Vector3.new(0.3, 0.2, 0.05), at(s * 0.36, 0.12, -0.76), C(220, 230, 210), M.Neon)
		R.deco(B.head, "Bag", Vector3.new(0.4, 0.18, 0.05), at(s * 0.36, -0.08, -0.76), C(60, 70, 80))
	end
	R.deco(B.head, "Mouth", Vector3.new(0.7, 0.12, 0.05), at(0, -0.45, -0.76), C(30, 20, 20))
	R.deco(B.head, "Stubble", Vector3.new(1.5, 0.6, 0.1), at(0, -0.5, -0.72), C(80, 90, 100))
	-- the red knit cap, rolled up
	R.deco(B.head, "Cap", Vector3.new(1.7, 0.8, 1.6), at(0, 0.75, 0.05), CAP, M.Fabric)
	R.deco(B.head, "CapRoll", Vector3.new(1.75, 0.3, 1.65), at(0, 0.45, 0.05), C(120, 24, 24), M.Fabric)
	-- the cargo hook for a left hand
	local lh = B.LeftHand
	lh.Transparency = 1
	R.deco(lh, "HookCuff", Vector3.new(1.1, 0.5, 1.1), at(0, 0.3, 0), C(80, 60, 40), M.Wood)
	R.deco(lh, "HookShaft", Vector3.new(0.25, 1.0, 0.25), at(0, -0.3, 0), IRON, M.Metal)
	R.deco(lh, "HookCurve", Vector3.new(0.25, 0.25, 0.9), at(0, -0.85, -0.3), IRON, M.Metal)
	R.deco(lh, "HookTip", Vector3.new(0.25, 0.6, 0.25), at(0, -0.6, -0.68, 0.3, 0, 0), IRON, M.Metal)
	-- the net over his right shoulder: a knotted grid
	for i = 0, 4 do
		R.deco(B.upper, "NetH", Vector3.new(1.6, 0.08, 0.08), at(0.9, 1.4 - i * 0.5, 1.12), C(170, 150, 100), M.Fabric)
		R.deco(B.upper, "NetV", Vector3.new(0.08, 2.2, 0.08), at(0.2 + i * 0.35, 0.4, 1.12), C(170, 150, 100), M.Fabric)
	end
	for _, p in { { 0.4, -0.7 }, { 1.4, -0.4 } } do R.deco(B.upper, "Float", Vector3.one * 0.4, at(p[1], p[2], 1.2), C(230, 120, 40), M.SmoothPlastic, Enum.PartType.Ball) end
	-- the anchor on his back
	R.deco(B.upper, "AnchorShank", Vector3.new(0.35, 2.6, 0.35), at(-0.6, 0.1, 1.3, 0, 0, 0.35), IRON, M.Metal)
	R.deco(B.upper, "AnchorStock", Vector3.new(1.4, 0.3, 0.3), at(-0.15, 1.25, 1.3, 0, 0, 0.35), IRON, M.Metal)
	R.deco(B.upper, "AnchorArm", Vector3.new(1.8, 0.35, 0.35), at(-1.05, -1.05, 1.3, 0, 0, 0.35), IRON, M.Metal)
	R.deco(B.upper, "AnchorRing", Vector3.new(0.5, 0.5, 0.15), at(-0.05, 1.55, 1.3), IRON, M.Metal)
	R.finish(B)
	table.insert(out, "Netman hover " .. string.format("%.2f", B.hover))
end

return table.concat(out, "\n")
