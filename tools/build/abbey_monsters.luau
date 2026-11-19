-- Builds THE ASHEN ABBEY's three new monsters into ServerStorage.Monsters (Edit, standalone; re-running replaces
-- them): python3 tools/studio.py luau Edit tools/build/abbey_monsters.luau
--   Nun          THE WEEPING NUN: tall and thin in a black habit to the floor, a white coif round a grey dead face,
--                hollow black eyes with black tears running down, a black veil hanging behind, long grey claws,
--                a rosary with a cross at her waist.
--   Gravedigger  THE GRAVEDIGGER: a hunched old man in a long mud-brown coat and a wide black hat, grey stubble,
--                one white eye; his shovel in his right hand (a long handle and an iron blade), a lantern on his belt.
--   Ringer       THE BELL RINGER: a huge hunched brute in a sackcloth hood, one bulging eye, bell ropes wound round
--                his thick arms, iron bands, a bronze bell in his right hand (the part "Bell": his toll).
-- Hand-built from plain parts (the rig builder of tools/build/harbor_monsters.luau, copied): the joint layout every
-- monster rig shares, so Client/GhostAnim drives them.
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

---------------------------------------------------------------------------------------------- THE WEEPING NUN
do
	local R = rig("Nun")
	local HABIT, HABITD, COIF, FACE, CLAW = C(22, 20, 26), C(12, 10, 14), C(220, 216, 206), C(150, 150, 148), C(120, 118, 112)
	local B = R.body({ skin = FACE, lowerSize = Vector3.new(1.8, 1.4, 1.3), lowerColor = HABIT, upperSize = Vector3.new(2.2, 2.6, 1.4), upperColor = HABIT,
		upperMat = M.Fabric, headSize = Vector3.new(1.25, 1.5, 1.25), headColor = FACE, armW = 0.65, upperArm = 2.3, lowerArm = 2.3, hand = 1.0,
		sleeve = HABIT, sleeveMat = M.Fabric, forearm = HABIT, forearmMat = M.Fabric, handColor = CLAW, legW = 0.85, upperLeg = 2.2, lowerLeg = 2.2,
		footLen = 1.4, legColor = HABIT, legMat = M.Fabric, footColor = HABITD })
	-- the habit to the floor: wide panels on the legs, a hem
	for _, s in { -1, 1 } do
		local L = s < 0 and "Left" or "Right"
		R.deco(B[L .. "UpperLeg"], "Habit", Vector3.new(1.3, 2.4, 1.7), at(s * 0.15, 0, 0), HABIT, M.Fabric)
		R.deco(B[L .. "LowerLeg"], "HabitLow", Vector3.new(1.45, 2.5, 1.9), at(s * 0.2, -0.1, 0), HABIT, M.Fabric)
		R.deco(B[L .. "LowerLeg"], "Hem", Vector3.new(1.5, 0.2, 1.95), at(s * 0.2, -1.3, 0), HABITD, M.Fabric)
		-- the wide sleeves, the long claws
		R.deco(B[L .. "LowerArm"], "Sleeve", Vector3.new(1.0, 1.2, 1.0), at(0, -0.7, 0), HABIT, M.Fabric)
		for k = -1, 1 do
			R.deco(B[L .. "Hand"], "Claw", Vector3.new(0.12, 1.1, 0.12), at(k * 0.2, -0.85, -0.1, 0.2, 0, 0), CLAW)
		end
		-- the hollow eyes and the black tears running from them
		R.deco(B.head, "Eye", Vector3.new(0.3, 0.26, 0.05), at(s * 0.3, 0.15, -0.64), C(4, 4, 6))
		R.deco(B.head, "EyeGlint", Vector3.new(0.07, 0.07, 0.04), at(s * 0.3, 0.15, -0.67), C(190, 180, 255), M.Neon)
		R.deco(B.head, "Tear", Vector3.new(0.08, 0.7, 0.04), at(s * 0.3, -0.3, -0.64), C(6, 4, 8))
	end
	-- the coif framing the face, the black veil over it and down her back
	R.deco(B.head, "Coif", Vector3.new(1.45, 1.75, 1.3), at(0, 0.05, 0.1), COIF, M.Fabric)
	R.deco(B.head, "Brow", Vector3.new(1.45, 0.3, 0.2), at(0, 0.6, -0.6), COIF, M.Fabric)
	R.deco(B.head, "Veil", Vector3.new(1.65, 0.9, 1.5), at(0, 0.75, 0.1), HABIT, M.Fabric)
	R.deco(B.head, "VeilBack", Vector3.new(1.7, 2.6, 0.25), at(0, -0.4, 0.75, -0.1, 0, 0), HABIT, M.Fabric)
	R.deco(B.upper, "Collar", Vector3.new(2.0, 0.9, 1.5), at(0, 1.05, 0), COIF, M.Fabric)
	R.deco(B.head, "Mouth", Vector3.new(0.45, 0.12, 0.05), at(0, -0.45, -0.64), C(30, 20, 24))
	-- the rosary at her waist, its cross
	for k = 0, 5 do R.deco(B.lower, "Bead", Vector3.one * 0.2, at(-0.5 + k * 0.12, -0.2 - k * 0.18, -0.7), C(120, 40, 30), M.SmoothPlastic, Enum.PartType.Ball) end
	R.deco(B.lower, "Cross", Vector3.new(0.12, 0.7, 0.08), at(0.2, -1.5, -0.72), C(200, 170, 90), M.Metal)
	R.deco(B.lower, "CrossBar", Vector3.new(0.45, 0.12, 0.08), at(0.2, -1.35, -0.72), C(200, 170, 90), M.Metal)
	local glow = Instance.new("PointLight"); glow.Color = C(180, 170, 255); glow.Range = 8; glow.Brightness = 0.6
	glow.Parent = B.head
	R.finish(B)
	table.insert(out, "Nun hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE GRAVEDIGGER
do
	local R = rig("Gravedigger")
	local COAT, COATD, SKIN, HAT, MUD, IRON = C(92, 70, 48), C(64, 48, 34), C(150, 146, 130), C(20, 18, 18), C(70, 56, 40), C(70, 70, 72)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(2.2, 1.4, 1.5), lowerColor = COAT, upperSize = Vector3.new(2.7, 2.6, 1.8), upperColor = COAT,
		upperMat = M.Fabric, headSize = Vector3.new(1.4, 1.5, 1.4), headColor = SKIN, armW = 0.85, upperArm = 2.2, lowerArm = 2.2, hand = 1.0,
		sleeve = COAT, sleeveMat = M.Fabric, forearm = COAT, forearmMat = M.Fabric, handColor = SKIN, legW = 1.0, upperLeg = 2.0, lowerLeg = 2.0,
		footLen = 1.9, legColor = C(46, 42, 38), legMat = M.Fabric, shinColor = C(30, 26, 22), footColor = C(30, 26, 22) })
	-- the long coat: skirts to the knees, a patched collar, mud splashes
	for _, s in { -1, 1 } do
		local L = s < 0 and "Left" or "Right"
		R.deco(B[L .. "UpperLeg"], "CoatSkirt", Vector3.new(1.25, 2.1, 1.7), at(s * 0.12, -0.1, 0), COAT, M.Fabric)
		R.deco(B[L .. "LowerLeg"], "Mud", Vector3.new(0.95, 0.9, 0.95), at(0, -0.5, 0), MUD, M.Slate)
		R.deco(B.head, "Brow", Vector3.new(0.45, 0.14, 0.08), at(s * 0.33, 0.32, -0.72, 0, 0, s * -0.3), C(90, 88, 80))
	end
	R.deco(B.upper, "Collar", Vector3.new(2.6, 0.6, 1.9), at(0, 1.2, 0, 0.12, 0, 0), COATD, M.Fabric)
	R.deco(B.upper, "Patch", Vector3.new(0.7, 0.7, 0.06), at(0.6, -0.4, -0.92), C(120, 96, 60), M.Fabric)
	R.deco(B.upper, "MudSplash", Vector3.new(1.2, 0.6, 0.06), at(-0.5, -0.9, -0.92, 0, 0, 0.3), MUD, M.Slate)
	R.deco(B.lower, "Belt", Vector3.new(2.3, 0.3, 1.6), at(0, 0.4, 0), C(40, 30, 22), M.Fabric)
	-- the face: stubble, a sunken dark eye and a white dead one, a grim mouth
	R.deco(B.head, "Stubble", Vector3.new(1.3, 0.7, 0.1), at(0, -0.45, -0.68), C(110, 108, 100))
	R.deco(B.head, "Eye", Vector3.new(0.28, 0.2, 0.05), at(-0.32, 0.12, -0.71), C(10, 10, 10))
	R.deco(B.head, "DeadEye", Vector3.new(0.28, 0.24, 0.05), at(0.32, 0.12, -0.71), C(230, 240, 220), M.Neon)
	R.deco(B.head, "Mouth", Vector3.new(0.6, 0.1, 0.05), at(0, -0.35, -0.72), C(30, 20, 18))
	R.deco(B.head, "Nose", Vector3.new(0.25, 0.45, 0.3), at(0, -0.05, -0.8), SKIN)
	-- the wide-brimmed black hat
	R.deco(B.head, "HatCrown", Vector3.new(1.3, 0.9, 1.3), at(0, 1.15, 0.05), HAT, M.Fabric)
	R.deco(B.head, "HatBrim", Vector3.new(2.6, 0.12, 2.5), at(0, 0.72, 0.05, -0.08, 0, 0), HAT, M.Fabric)
	R.deco(B.head, "HatBand", Vector3.new(1.35, 0.18, 1.35), at(0, 0.85, 0.05), C(70, 30, 26), M.Fabric)
	-- his shovel in the right hand, blade down
	local hand = B.RightHand
	R.deco(hand, "ShovelHandle", Vector3.new(0.3, 5.5, 0.3), at(0, 0.8, 0), C(110, 80, 50), M.Wood)
	R.deco(hand, "ShovelGrip", Vector3.new(0.9, 0.25, 0.25), at(0, 3.5, 0), C(110, 80, 50), M.Wood)
	R.deco(hand, "ShovelBlade", Vector3.new(1.3, 1.5, 0.15), at(0, -2.4, 0), IRON, M.Metal)
	R.deco(hand, "ShovelTip", Vector3.new(0.9, 0.3, 0.15), at(0, -3.2, 0), IRON, M.Metal)
	-- a little lantern on his belt (green grave-light)
	R.deco(B.lower, "Lantern", Vector3.new(0.55, 0.75, 0.55), at(-1.25, -0.3, -0.2), C(30, 30, 30), M.Metal).Transparency = 0.4
	local lg = R.deco(B.lower, "LanternGlow", Vector3.new(0.3, 0.4, 0.3), at(-1.25, -0.3, -0.2), C(150, 255, 120), M.Neon)
	local l = Instance.new("PointLight"); l.Color = C(150, 255, 120); l.Range = 10; l.Brightness = 0.9; l.Parent = lg
	R.finish(B)
	table.insert(out, "Gravedigger hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE BELL RINGER
do
	local R = rig("Ringer")
	local SACK, SACKD, SKIN, ROPE, IRON, BRONZE = C(140, 118, 84), C(100, 82, 56), C(170, 140, 120), C(170, 150, 104), C(56, 56, 60), C(196, 146, 64)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(2.8, 1.6, 2.0), lowerColor = SACKD, upperSize = Vector3.new(3.7, 3.0, 2.4), upperColor = SACK,
		upperMat = M.Fabric, headSize = Vector3.new(1.6, 1.5, 1.5), headColor = SKIN, armW = 1.25, upperArm = 2.4, lowerArm = 2.3, hand = 1.2,
		sleeve = SKIN, forearm = SKIN, handColor = SKIN, legW = 1.25, upperLeg = 1.9, lowerLeg = 1.9,
		footLen = 2.0, legColor = SACKD, legMat = M.Fabric, shinColor = C(60, 48, 36), footColor = C(40, 32, 26) })
	-- the hunch: a great lump on his back, the hood over his head
	R.deco(B.upper, "Hunch", Vector3.new(2.6, 1.8, 1.4), at(0.3, 1.0, 0.9, -0.3, 0, 0.1), SACK, M.Fabric)
	R.deco(B.head, "Hood", Vector3.new(1.85, 1.7, 1.8), at(0, 0.2, 0.15), SACK, M.Fabric)
	R.deco(B.head, "HoodTip", Vector3.new(0.9, 0.9, 0.9), at(0, 1.05, 0.5, -0.4, 0, 0), SACK, M.Fabric)
	R.deco(B.upper, "Rope", Vector3.new(3.8, 0.3, 2.5), at(0, -0.6, 0, 0, 0, 0.3), ROPE, M.Fabric)
	-- the face: one bulging eye, one swollen shut, a crooked mouth
	R.deco(B.head, "BigEye", Vector3.new(0.5, 0.5, 0.25), at(-0.35, 0.15, -0.78), C(230, 220, 150), M.Neon, Enum.PartType.Ball)
	R.deco(B.head, "Pupil", Vector3.new(0.15, 0.15, 0.06), at(-0.35, 0.15, -0.9), C(10, 8, 6))
	R.deco(B.head, "Swollen", Vector3.new(0.5, 0.35, 0.2), at(0.35, 0.1, -0.76), C(150, 100, 90))
	R.deco(B.head, "Mouth", Vector3.new(0.8, 0.14, 0.06), at(0.05, -0.4, -0.76, 0, 0, 0.2), C(40, 20, 16))
	for i = -1, 1 do R.deco(B.head, "Tooth", Vector3.new(0.14, 0.2, 0.06), at(i * 0.25, -0.3, -0.79), C(220, 210, 170)) end
	-- bell ropes wound round his arms, iron bands at the wrists
	for _, s in { -1, 1 } do
		local L = s < 0 and "Left" or "Right"
		for k = 0, 2 do R.deco(B[L .. "UpperArm"], "Wrap", Vector3.new(1.32, 0.25, 1.32), at(0, 0.7 - k * 0.6, 0, 0, 0, 0.15), ROPE, M.Fabric) end
		R.deco(B[L .. "LowerArm"], "Band", Vector3.new(1.2, 0.4, 1.2), at(0, -0.9, 0), IRON, M.Metal)
	end
	R.deco(B.lower, "Belt", Vector3.new(2.95, 0.35, 2.1), at(0, 0.5, 0), C(50, 36, 26), M.Fabric)
	-- the bronze bell in his right hand (hung from its iron loop, mouth down)
	local hand = B.RightHand
	R.deco(hand, "BellLoop", Vector3.new(0.3, 0.7, 0.7), at(0, -0.6, 0), IRON, M.Metal)
	R.deco(hand, "BellCrown", Vector3.new(0.5, 1.0, 1.0), at(0, -1.0, 0, 0, 0, math.pi / 2), BRONZE, M.Metal, Enum.PartType.Cylinder)
	R.deco(hand, "Bell", Vector3.new(1.0, 1.6, 1.6), at(0, -1.6, 0, 0, 0, math.pi / 2), BRONZE, M.Metal, Enum.PartType.Cylinder)
	R.deco(hand, "BellLip", Vector3.new(0.4, 2.1, 2.1), at(0, -2.25, 0, 0, 0, math.pi / 2), BRONZE, M.Metal, Enum.PartType.Cylinder)
	R.deco(hand, "Clapper", Vector3.new(0.35, 0.4, 0.35), at(0, -2.5, 0), IRON, M.Metal, Enum.PartType.Ball)
	R.finish(B)
	table.insert(out, "Ringer hover " .. string.format("%.2f", B.hover))
end

return table.concat(out, "\n")
