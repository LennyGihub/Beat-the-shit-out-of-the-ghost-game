-- Builds the MOONLIGHT CARNIVAL's four new monsters into ServerStorage.Monsters (Edit, standalone; re-running replaces
-- them): python3 tools/studio.py luau Edit tools/build/carnival_monsters.luau
--   Clown      POP THE CLOWN: white face, red ball nose, blue diamond eyes, a grin, frizzy orange hair, a party hat,
--              a ruff, polka dots, pom-poms, baggy trousers, huge red shoes, a bunch of balloons in his left hand.
--   Strongman  THE STRONGMAN: huge, grey dead skin, a striped singlet, a belt with a gold buckle, a handlebar
--              moustache, glowing yellow eyes, leather wrist cuffs.
--   Fortune    MADAME FORTUNE: a headscarf with gold coins, black hair, glowing violet eyes, a shawl with tassels,
--              strings of beads, bangles, a layered skirt to the floor, three tarot cards in her left hand.
--   Ringmaster THE RINGMASTER: a red tailcoat with gold buttons and epaulettes, a top hat, sunken black eyes with
--              red pinpoints, a waxed moustache, a whip coiled down from his right hand.
-- Hand-built from plain parts (the camp monsters' rig builder, copied from tools/build/camp_monsters.luau): the
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

---------------------------------------------------------------------------------------------- POP THE CLOWN
do
	local R = rig("Clown")
	local WHITE, RED, YEL, BLUE, GRN, ORANGE = C(236, 230, 220), C(196, 36, 36), C(236, 196, 60), C(56, 86, 196), C(70, 160, 80), C(240, 110, 40)
	local B = R.body({ skin = WHITE, lowerSize = Vector3.new(2.3, 1.5, 1.6), lowerColor = YEL, upperSize = Vector3.new(2.7, 2.6, 1.7), upperColor = YEL,
		upperMat = M.Fabric, headSize = Vector3.new(1.5, 1.6, 1.4), headColor = WHITE, armW = 0.78, upperArm = 2.0, lowerArm = 1.9, hand = 0.95,
		sleeve = RED, sleeveMat = M.Fabric, forearm = RED, forearmMat = M.Fabric, handColor = C(246, 246, 246), legW = 1.0, upperLeg = 2.1, lowerLeg = 2.0,
		footLen = 2.8, legColor = RED, legMat = M.Fabric, footColor = RED })
	-- the face: a red ball nose, blue diamond paint round black eyes with a white glint, a huge red grin with teeth
	R.deco(B.head, "Nose", Vector3.new(0.6, 0.6, 0.6), at(0, -0.02, -0.8), C(230, 30, 30), M.SmoothPlastic, Enum.PartType.Ball)
	for _, s in { -1, 1 } do
		R.deco(B.head, "EyePaint", Vector3.new(0.44, 0.44, 0.04), at(s * 0.38, 0.24, -0.71, 0, 0, math.pi / 4), BLUE)
		R.deco(B.head, "Eye", Vector3.new(0.18, 0.2, 0.05), at(s * 0.38, 0.24, -0.735), C(12, 10, 10))
		R.deco(B.head, "Glint", Vector3.new(0.06, 0.06, 0.03), at(s * 0.38 + 0.04, 0.29, -0.76), C(255, 255, 240), M.Neon)
		R.deco(B.head, "Brow", Vector3.new(0.45, 0.1, 0.05), at(s * 0.4, 0.62, -0.71, 0, 0, s * 0.35), C(20, 18, 18))
		R.deco(B.head, "GrinCorner", Vector3.new(0.3, 0.16, 0.05), at(s * 0.52, -0.28, -0.71, 0, 0, s * 0.6), C(180, 20, 24))
		-- frizzy orange hair, three tufts a side
		for k, p in { { 0.86, 0.32, 0.05 }, { 0.92, -0.18, 0.3 }, { 0.72, 0.72, 0.32 } } do
			R.deco(B.head, "Hair", Vector3.one * (0.85 - k * 0.08), at(s * p[1], p[2], p[3]), ORANGE, M.Fabric, Enum.PartType.Ball)
		end
		-- white cuffs, a pom-pom on each shoe
		R.deco(B[(s < 0 and "Left" or "Right") .. "LowerArm"], "Cuff", Vector3.new(0.9, 0.35, 0.9), at(0, -0.8, 0), WHITE, M.Fabric)
		R.deco(B[(s < 0 and "Left" or "Right") .. "Foot"], "ShoePom", Vector3.one * 0.55, at(0, 0.35, -0.9), WHITE, M.Fabric, Enum.PartType.Ball)
		R.deco(B[(s < 0 and "Left" or "Right") .. "Foot"], "ShoeToe", Vector3.new(1.1, 0.7, 0.9), at(0, 0.1, -1.1), RED)
	end
	R.deco(B.head, "Grin", Vector3.new(0.9, 0.24, 0.05), at(0, -0.42, -0.71), C(180, 20, 24))
	for i = -2, 2 do R.deco(B.head, "Tooth", Vector3.new(0.13, 0.13, 0.05), at(i * 0.16, -0.38, -0.735), C(240, 236, 210)) end
	-- a little striped party hat, crooked
	for i = 0, 2 do
		R.deco(B.head, "Hat", Vector3.new(0.75 - i * 0.22, 0.32, 0.75 - i * 0.22), at(0.25, 0.95 + i * 0.3, 0, 0, 0, -0.3), i % 2 == 0 and BLUE or YEL)
	end
	R.deco(B.head, "HatPom", Vector3.one * 0.3, at(0.06, 1.85, 0, 0, 0, -0.3), WHITE, M.Fabric, Enum.PartType.Ball)
	-- the ruff round his neck, polka dots, pom-pom buttons
	for k = 0, 9 do
		local a = k / 10 * math.pi * 2
		R.deco(B.upper, "Ruff", Vector3.new(0.75, 0.32, 0.5), CFrame.new(0, 1.35, 0) * A(0, a, 0) * CFrame.new(0, 0, -1.05) * A(0.35, 0, 0), k % 2 == 0 and WHITE or RED, M.Fabric)
	end
	for _, p in { { -0.8, 0.5, RED }, { 0.7, 0.8, BLUE }, { -0.5, -0.6, GRN }, { 0.85, -0.4, RED }, { 0.1, 0.1, BLUE }, { -0.9, -0.1, BLUE } } do
		R.deco(B.upper, "Dot", Vector3.new(0.42, 0.42, 0.04), at(p[1], p[2], -0.86), p[3])
	end
	for k = 0, 2 do R.deco(B.upper, "PomButton", Vector3.one * 0.38, at(0, 0.7 - k * 0.65, -0.88), ({ RED, BLUE, GRN })[k + 1], M.Fabric, Enum.PartType.Ball) end
	-- baggy trousers: wide cuffs
	for _, s in { -1, 1 } do R.deco(B[(s < 0 and "Left" or "Right") .. "LowerLeg"], "Baggy", Vector3.new(1.3, 0.8, 1.3), at(0, -0.6, 0), YEL, M.Fabric) end
	-- the balloons in his left hand
	local hand = B.LeftHand
	R.deco(hand, "String", Vector3.new(0.06, 4.2, 0.06), at(0, 2.1, -0.2), C(230, 230, 230))
	for k, col in { C(220, 40, 40), C(60, 120, 230), C(240, 200, 50) } do
		local off = ({ { -0.6, 4.6, -0.2 }, { 0.5, 4.9, 0 }, { 0, 5.6, -0.3 } })[k]
		R.deco(hand, "Balloon", Vector3.new(1.3, 1.55, 1.3), at(off[1], off[2], off[3]), col, M.SmoothPlastic, Enum.PartType.Ball).Reflectance = 0.15
	end
	R.finish(B)
	table.insert(out, "Clown hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE STRONGMAN
do
	local R = rig("Strongman")
	local SKIN, SKIN_D = C(168, 164, 148), C(120, 116, 104)
	local CREAM, STRIPE, BLACK, LEATHER, GOLD = C(232, 220, 192), C(160, 36, 36), C(30, 28, 28), C(80, 52, 34), C(210, 170, 60)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(2.9, 1.6, 1.9), lowerColor = BLACK, upperSize = Vector3.new(4.0, 3.4, 2.1), upperColor = CREAM,
		upperMat = M.Fabric, headSize = Vector3.new(1.5, 1.6, 1.5), headColor = SKIN, armW = 1.2, upperArm = 2.6, lowerArm = 2.5, hand = 1.25,
		sleeve = SKIN, forearm = SKIN, handColor = SKIN_D, legW = 1.25, upperLeg = 2.6, lowerLeg = 2.4, footLen = 1.7, legColor = BLACK,
		legMat = M.Fabric, footColor = LEATHER })
	-- the singlet's red stripes and straps, a wide belt with a gold buckle
	for i = 0, 3 do R.deco(B.upper, "Stripe", Vector3.new(4.05, 0.34, 2.15), at(0, -1.2 + i * 0.75, 0), STRIPE, M.Fabric) end
	for _, s in { -1, 1 } do R.deco(B.upper, "Strap", Vector3.new(0.6, 0.5, 2.15), at(s * 1.25, 1.55, 0), CREAM, M.Fabric) end
	R.deco(B.lower, "Belt", Vector3.new(3.0, 0.55, 2.0), at(0, 0.55, 0), LEATHER)
	R.deco(B.lower, "Buckle", Vector3.new(0.9, 0.7, 0.1), at(0, 0.55, -1.02), GOLD, M.Metal)
	-- bald head, a handlebar moustache with curled ends, heavy brows, glowing yellow eyes, a scar
	R.deco(B.head, "Stache", Vector3.new(0.85, 0.24, 0.12), at(0, -0.3, -0.76), BLACK)
	for _, s in { -1, 1 } do
		R.deco(B.head, "StacheArm", Vector3.new(0.5, 0.18, 0.1), at(s * 0.6, -0.22, -0.76, 0, 0, s * 0.5), BLACK)
		R.deco(B.head, "StacheCurl", Vector3.one * 0.2, at(s * 0.82, -0.02, -0.76), BLACK, nil, Enum.PartType.Ball)
		R.deco(B.head, "Brow", Vector3.new(0.5, 0.16, 0.1), at(s * 0.35, 0.36, -0.76, 0, 0, s * -0.25), BLACK)
		R.deco(B.head, "Eye", Vector3.new(0.22, 0.12, 0.05), at(s * 0.35, 0.18, -0.76), C(255, 210, 80), M.Neon)
		R.deco(B.head, "Ear", Vector3.new(0.15, 0.4, 0.3), at(s * 0.78, 0.05, 0), SKIN)
		-- leather wrist cuffs, bruises
		local side = s < 0 and "Left" or "Right"
		R.deco(B[side .. "LowerArm"], "WristCuff", Vector3.new(1.2, 0.6, 1.2), at(0, -0.9, 0), LEATHER)
		R.deco(B[side .. "UpperArm"], "Bruise", Vector3.new(0.7, 0.6, 0.05), at(0, 0.3, -0.62), C(90, 80, 100))
	end
	R.deco(B.head, "Scar", Vector3.new(0.08, 0.7, 0.05), at(0.42, 0.3, -0.765, 0, 0, 0.3), C(110, 60, 60))
	R.deco(B.head, "Jaw", Vector3.new(1.5, 0.45, 1.4), at(0, -0.62, -0.05), SKIN)
	local glow = Instance.new("PointLight"); glow.Color = C(255, 200, 90); glow.Range = 6; glow.Brightness = 0.5; glow.Parent = B.head
	R.finish(B)
	table.insert(out, "Strongman hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- MADAME FORTUNE
do
	local R = rig("Fortune")
	local SKIN = C(158, 146, 170)
	local SCARF, SHAWL, BLOUSE, SKIRT, SKIRT2, GOLD = C(110, 36, 130), C(52, 26, 70), C(150, 60, 104), C(86, 22, 54), C(120, 36, 70), C(220, 180, 70)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(2.0, 1.4, 1.4), lowerColor = SKIRT, upperSize = Vector3.new(2.1, 2.4, 1.3), upperColor = BLOUSE,
		upperMat = M.Fabric, headSize = Vector3.new(1.3, 1.45, 1.3), headColor = SKIN, armW = 0.56, upperArm = 2.0, lowerArm = 1.9, hand = 0.75,
		sleeve = BLOUSE, sleeveMat = M.Fabric, forearm = SKIN, legW = 0.8, upperLeg = 2.2, lowerLeg = 2.2, footLen = 1.0, legColor = SKIRT, footColor = C(30, 20, 20) })
	-- the skirt in layers down to the floor, a gold fringe on each layer
	R.deco(B.lower, "Skirt1", Vector3.new(2.7, 2.4, 2.2), at(0, -1.4, 0), SKIRT2, M.Fabric)
	R.deco(B.lower, "Skirt2", Vector3.new(3.2, 2.3, 2.7), at(0, -3.3, 0), SKIRT, M.Fabric)
	R.deco(B.lower, "Fringe1", Vector3.new(2.75, 0.22, 2.25), at(0, -2.55, 0), GOLD, M.Fabric)
	R.deco(B.lower, "Fringe2", Vector3.new(3.25, 0.24, 2.75), at(0, -4.4, 0), GOLD, M.Fabric)
	-- the headscarf with a row of gold coins, long black hair down her back, hoop earrings
	R.deco(B.head, "Scarf", Vector3.new(1.45, 0.75, 1.45), at(0, 0.5, 0.04), SCARF, M.Fabric)
	R.deco(B.head, "Knot", Vector3.new(0.6, 0.6, 0.5), at(0, 0.25, 0.85), SCARF, M.Fabric)
	R.deco(B.head, "ScarfTail", Vector3.new(0.5, 1.6, 0.15), at(0.25, -0.5, 0.9, 0.2, 0, 0.15), SCARF, M.Fabric)
	for i = -3, 3 do R.deco(B.head, "Coin", Vector3.new(0.17, 0.17, 0.05), at(i * 0.19, 0.12, -0.74), GOLD, M.Metal) end
	R.deco(B.head, "Hair", Vector3.new(1.35, 2.4, 0.35), at(0, -0.8, 0.62), C(18, 14, 16), M.Fabric)
	for _, s in { -1, 1 } do
		R.deco(B.head, "Eye", Vector3.new(0.22, 0.11, 0.05), at(s * 0.3, -0.02, -0.67), C(210, 120, 255), M.Neon)
		R.deco(B.head, "EyeShade", Vector3.new(0.34, 0.12, 0.04), at(s * 0.3, 0.1, -0.665), C(50, 20, 60))
		R.deco(B.head, "Hoop", Vector3.new(0.08, 0.36, 0.36), at(s * 0.68, -0.38, -0.05), GOLD, M.Metal)
		-- bangles
		for k = 0, 1 do R.deco(B[(s < 0 and "Left" or "Right") .. "LowerArm"], "Bangle", Vector3.new(0.62, 0.12, 0.62), at(0, -0.6 - k * 0.22, 0), GOLD, M.Metal) end
	end
	R.deco(B.head, "Lips", Vector3.new(0.4, 0.1, 0.04), at(0, -0.42, -0.665), C(70, 20, 40))
	-- the shawl over her shoulders with tassels, three strings of beads
	R.deco(B.upper, "Shawl", Vector3.new(2.6, 0.55, 1.6), at(0, 1.0, 0), SHAWL, M.Fabric)
	R.deco(B.upper, "ShawlBack", Vector3.new(2.3, 1.6, 0.2), at(0, 0.2, 0.75), SHAWL, M.Fabric)
	for i = -4, 4 do R.deco(B.upper, "Tassel", Vector3.new(0.1, 0.5, 0.1), at(i * 0.27, 0.45, 0.82), GOLD, M.Fabric) end
	for r = 0, 2 do
		for i = -3, 3 do
			local y = 0.55 - r * 0.32 - math.abs(i) * -0.05
			R.deco(B.upper, "Bead", Vector3.one * 0.16, at(i * 0.18, y - (3 - math.abs(i)) * 0.05, -0.7), ({ C(200, 40, 60), GOLD, C(60, 150, 140) })[r + 1], M.SmoothPlastic, Enum.PartType.Ball)
		end
	end
	-- three tarot cards fanned in her left hand
	for k = -1, 1 do
		R.deco(B.LeftHand, "Card", Vector3.new(0.05, 0.9, 0.6), at(0, -0.6, -0.15, k * 0.35, 0, 0), C(236, 226, 196))
		R.deco(B.LeftHand, "CardBack", Vector3.new(0.06, 0.7, 0.42), at(-0.01, -0.6, -0.15, k * 0.35, 0, 0), C(110, 40, 140))
	end
	local glow = Instance.new("PointLight"); glow.Color = C(200, 120, 255); glow.Range = 8; glow.Brightness = 0.7; glow.Parent = B.head
	R.finish(B, 0.6)
	table.insert(out, "Fortune hover " .. string.format("%.2f", B.hover + 0.6))
end

---------------------------------------------------------------------------------------------- THE RINGMASTER
do
	local R = rig("Ringmaster")
	local SKIN, COAT, COAT_D, GOLD, WHITE, BLACK = C(206, 196, 186), C(150, 18, 26), C(100, 12, 18), C(220, 178, 64), C(232, 228, 218), C(22, 20, 22)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(2.0, 1.4, 1.3), lowerColor = WHITE, upperSize = Vector3.new(2.4, 3.0, 1.4), upperColor = COAT,
		upperMat = M.Fabric, headSize = Vector3.new(1.3, 1.5, 1.3), headColor = SKIN, armW = 0.62, upperArm = 2.3, lowerArm = 2.2, hand = 0.8,
		sleeve = COAT, sleeveMat = M.Fabric, forearm = COAT, forearmMat = M.Fabric, handColor = WHITE, legW = 0.8, upperLeg = 2.6, lowerLeg = 2.6,
		footLen = 1.3, legColor = WHITE, shinColor = BLACK, footColor = BLACK })
	-- the coat: black lapels, a white shirt front and bow tie, two rows of gold buttons, gold epaulettes, long tails
	R.deco(B.upper, "Shirt", Vector3.new(0.7, 1.6, 0.05), at(0, 0.6, -0.71), WHITE)
	R.deco(B.upper, "BowTie", Vector3.new(0.7, 0.28, 0.12), at(0, 1.3, -0.74), BLACK)
	for _, s in { -1, 1 } do
		R.deco(B.upper, "Lapel", Vector3.new(0.4, 1.7, 0.08), at(s * 0.52, 0.65, -0.72, 0, 0, s * -0.25), BLACK)
		for k = 0, 2 do R.deco(B.upper, "Button", Vector3.one * 0.2, at(s * 0.5, -0.3 - k * 0.45, -0.74), GOLD, M.Metal, Enum.PartType.Ball) end
		R.deco(B.upper, "Epaulette", Vector3.new(0.8, 0.25, 0.9), at(s * 1.3, 1.5, 0), GOLD, M.Metal)
		for k = -1, 1 do R.deco(B.upper, "Fringe", Vector3.new(0.1, 0.35, 0.1), at(s * 1.55, 1.25, k * 0.3), GOLD, M.Fabric) end
		R.deco(B.lower, "Tail", Vector3.new(0.85, 3.2, 0.18), at(s * 0.48, -1.3, 0.72, 0.12, 0, s * 0.05), COAT_D, M.Fabric)
		R.deco(B[(s < 0 and "Left" or "Right") .. "LowerArm"], "CuffGold", Vector3.new(0.66, 0.3, 0.66), at(0, -0.9, 0), GOLD, M.Metal)
		-- sunken black eyes with a red pinpoint, a waxed moustache
		R.deco(B.head, "Socket", Vector3.new(0.38, 0.3, 0.05), at(s * 0.3, 0.15, -0.66), C(20, 14, 16))
		R.deco(B.head, "Eye", Vector3.new(0.08, 0.08, 0.04), at(s * 0.3, 0.13, -0.69), C(255, 40, 30), M.Neon)
		R.deco(B.head, "Stache", Vector3.new(0.5, 0.1, 0.06), at(s * 0.28, -0.3, -0.67, 0, 0, s * 0.3), BLACK)
		R.deco(B.head, "Sideburn", Vector3.new(0.12, 0.6, 0.5), at(s * 0.66, -0.05, -0.15), BLACK)
	end
	R.deco(B.head, "Grin", Vector3.new(0.6, 0.08, 0.05), at(0, -0.48, -0.66), C(60, 20, 20))
	R.deco(B.lower, "Waistcoat", Vector3.new(2.05, 0.8, 1.35), at(0, 0.3, 0), COAT, M.Fabric)
	-- the top hat
	R.deco(B.head, "Brim", Vector3.new(1.9, 0.15, 1.9), at(0, 0.8, 0), BLACK)
	R.deco(B.head, "Crown", Vector3.new(1.25, 1.6, 1.25), at(0, 1.65, 0), BLACK)
	R.deco(B.head, "Band", Vector3.new(1.3, 0.3, 1.3), at(0, 1.05, 0), COAT)
	-- the whip in his right hand: the handle and the lash coiled down to the floor
	local hand = B.RightHand
	local handle = R.deco(hand, "WhipHandle", Vector3.new(0.28, 1.4, 0.28), at(0, -0.3, -0.4, -1.2, 0, 0), C(70, 44, 30))
	local last = CFrame.new(0, -0.7, 0)
	for k = 1, 7 do
		local seg = last * A(0.15, 0, (k % 2 == 0 and 1 or -1) * 0.5) * CFrame.new(0, -0.55, 0)
		R.deco(handle, "Lash", Vector3.new(0.12, 1.1, 0.12), seg, C(30, 24, 20))
		last = seg * CFrame.new(0, -0.55, 0)
	end
	R.finish(B)
	table.insert(out, "Ringmaster hover " .. string.format("%.2f", B.hover))
end

return table.concat(out, "\n")
