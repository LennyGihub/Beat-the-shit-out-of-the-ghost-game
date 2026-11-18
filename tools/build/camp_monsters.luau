-- Builds Camp Hollowmere's four new monsters into ServerStorage.Monsters (Edit, standalone; re-running replaces
-- them): python3 tools/studio.py luau Edit tools/build/camp_monsters.luau
--   Antlered  THE ANTLERED ONE: tall and thin, bark skin, a deer skull with big branching antlers, long clawed arms.
--   LakeWitch THE LAKE WITCH: a drowned woman, pale blue-green skin, long wet black hair hanging over her face, a
--             ragged waterlogged dress with weed on it, a rusty hook on a chain in her right hand.
--   Counselor THE BURNED COUNSELOR: charred skin with glowing cracks, a scorched orange camp shirt, shorts, a whistle
--             on a lanyard, a burning torch in his right hand.
--   Scarecrow THE SCARECROW: a burlap sack head with a stitched mouth and button eyes, a battered straw hat, a ragged
--             coat with straw bursting from the sleeves and collar, a rope belt, a sickle.
-- All hand-built from plain parts (the game's blocky PS2 look, no meshes), with the joint names / layout every
-- monster rig shares (Root, Waist, Neck, shoulders / elbows / wrists, hips / knees / ankles) so Client/GhostAnim
-- drives them. Each model's pivot = its root, its feet `hover` studs below (Shared/Monsters hover).
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

---------------------------------------------------------------------------------------------- THE ANTLERED ONE
do
	local R = rig("Antlered")
	local BARK, BARK_D, BONE, ANTLER, MOSS = C(62, 52, 44), C(40, 34, 30), C(214, 204, 176), C(186, 170, 134), C(70, 86, 50)
	local B = R.body({ skin = BARK, lowerSize = Vector3.new(1.8, 1.3, 1.1), lowerColor = BARK_D, upperSize = Vector3.new(2.3, 3.4, 1.2), upperColor = BARK,
		upperMat = M.Wood, headSize = Vector3.new(1.2, 1.4, 1.5), headColor = BONE, armW = 0.6, upperArm = 2.8, lowerArm = 2.8, hand = 1.0,
		forearm = BARK_D, handColor = BARK_D, legW = 0.75, upperLeg = 3.0, lowerLeg = 3.2, footLen = 1.3, legColor = BARK, footColor = C(24, 20, 18) })
	-- the deer skull: a long snout, black eye holes with white pinpoints, teeth
	R.deco(B.head, "Snout", Vector3.new(0.8, 0.7, 1.5), at(0, -0.25, -1.2), BONE)
	R.deco(B.head, "Nose", Vector3.new(0.5, 0.3, 0.3), at(0, -0.1, -1.95), C(30, 26, 24))
	for _, s in { -1, 1 } do
		R.deco(B.head, "EyeHole", Vector3.new(0.4, 0.38, 0.12), at(s * 0.36, 0.22, -0.74), C(10, 8, 8))
		R.deco(B.head, "Eye", Vector3.new(0.1, 0.1, 0.05), at(s * 0.36, 0.22, -0.8), C(240, 240, 220), M.Neon)
		R.deco(B.head, "Tooth", Vector3.new(0.12, 0.3, 0.12), at(s * 0.2, -0.65, -1.7), C(200, 186, 150))
		-- the antlers: a main beam up and out, three tines, a brow tine forward
		local base = at(s * 0.45, 0.65, 0.1, 0, 0, s * -0.5)
		local beam = R.deco(B.head, "Antler", Vector3.new(0.28, 3.2, 0.28), base * CFrame.new(0, 1.5, 0), ANTLER)
		local _ = beam
		R.deco(B.head, "AntlerBend", Vector3.new(0.24, 2.4, 0.24), base * CFrame.new(0, 3.0, 0) * A(-0.5, 0, s * -0.5) * CFrame.new(0, 1.1, 0), ANTLER)
		for k, h in { 1.2, 2.2, 2.9 } do
			R.deco(B.head, "Tine", Vector3.new(0.18, 1.2 - k * 0.15, 0.18), base * CFrame.new(0, h, 0) * A(-0.9 + k * 0.2, 0, s * 0.6) * CFrame.new(0, 0.55, 0), ANTLER)
		end
		R.deco(B.head, "BrowTine", Vector3.new(0.16, 0.9, 0.16), base * CFrame.new(0, 0.4, 0) * A(-1.2, 0, 0) * CFrame.new(0, 0.45, 0), ANTLER)
		-- long claws
		for i = -1, 1 do R.deco(B[(s < 0 and "Left" or "Right") .. "Hand"], "Claw", Vector3.new(0.12, 0.9, 0.12), at(i * 0.18, -0.85, -0.05, 0.25, 0, 0), C(200, 190, 160)) end
		-- hooves
		R.deco(B[(s < 0 and "Left" or "Right") .. "Foot"], "Hoof", Vector3.new(0.8, 0.3, 0.6), at(0, -0.05, -0.5), C(20, 18, 16))
	end
	-- ribs showing through the bark, moss on the shoulders, a ragged pelt
	for i = 0, 3 do R.deco(B.upper, "Rib", Vector3.new(1.9, 0.18, 0.1), at(0, 0.9 - i * 0.5, -0.62), BONE) end
	R.deco(B.upper, "Sternum", Vector3.new(0.22, 2, 0.12), at(0, 0.3, -0.64), BONE)
	R.deco(B.upper, "Pelt", Vector3.new(2.6, 1.4, 1.5), at(0, 1.3, 0.15), C(70, 56, 44), M.Fabric)
	for _, s in { -1, 1 } do R.deco(B.upper, "Moss", Vector3.new(0.9, 0.35, 1.2), at(s * 1.0, 1.75, 0.1), MOSS, M.Grass) end
	local glow = Instance.new("PointLight"); glow.Color = C(230, 230, 210); glow.Range = 7; glow.Brightness = 0.6; glow.Parent = B.head
	R.finish(B)
	table.insert(out, "Antlered hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE LAKE WITCH
do
	local R = rig("LakeWitch")
	local SKIN, DRESS, DRESS_D, HAIR, WEED, RUST = C(150, 176, 168), C(84, 96, 88), C(56, 66, 60), C(16, 18, 20), C(60, 96, 52), C(110, 66, 40)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(1.8, 1.2, 1.1), lowerColor = DRESS, upperSize = Vector3.new(2.0, 2.4, 1.1), upperColor = DRESS,
		upperMat = M.Fabric, headSize = Vector3.new(1.3, 1.5, 1.3), headColor = SKIN, armW = 0.55, upperArm = 2.0, lowerArm = 2.0, hand = 0.8,
		sleeve = DRESS_D, sleeveMat = M.Fabric, forearm = SKIN, legW = 0.7, upperLeg = 2.2, lowerLeg = 2.2, footLen = 1.0, legColor = SKIN, footColor = SKIN })
	-- the dress: a long ragged skirt to the ankles, weed caught on it, a dark wet hem
	R.deco(B.lower, "Skirt", Vector3.new(2.3, 3.4, 1.7), at(0, -1.7, 0), DRESS, M.Fabric)
	R.deco(B.lower, "SkirtHem", Vector3.new(2.6, 1.2, 2.0), at(0, -3.4, 0), DRESS_D, M.Fabric)
	for i = -2, 2 do R.deco(B.lower, "Rag", Vector3.new(0.45, 0.8, 0.12), at(i * 0.5, -4.1, -1.0, 0, 0, i * 0.15), DRESS_D, M.Fabric) end
	for _, p in { { -0.6, -1.0, -0.86 }, { 0.5, -2.6, -0.98 }, { 0.8, 0.4, -0.58 } } do
		R.deco(B.lower, "Weed", Vector3.new(0.3, 1.2, 0.08), at(p[1], p[2], p[3], 0, 0, 0.3), WEED, M.Grass)
	end
	-- the hair: long wet strands hanging down over the face and the back
	R.deco(B.head, "HairTop", Vector3.new(1.45, 0.4, 1.45), at(0, 0.7, 0), HAIR)
	R.deco(B.head, "HairBack", Vector3.new(1.5, 3.4, 0.4), at(0, -0.9, 0.62), HAIR)
	for i = -2, 2 do
		R.deco(B.head, "HairFront", Vector3.new(0.26, 2.8 + (i % 2) * 0.6, 0.12), at(i * 0.27, -0.6, -0.7, 0, 0, i * 0.03), HAIR)
	end
	for _, s in { -1, 1 } do
		R.deco(B.head, "Eye", Vector3.new(0.16, 0.1, 0.04), at(s * 0.32, 0.12, -0.78), C(150, 240, 230), M.Neon)
		R.deco(B.head, "HairSide", Vector3.new(0.3, 3, 1.1), at(s * 0.72, -0.8, 0), HAIR)
	end
	-- long grey nails
	for _, L in { "Left", "Right" } do
		for i = -1, 1 do R.deco(B[L .. "Hand"], "Nail", Vector3.new(0.1, 0.5, 0.1), at(i * 0.16, -0.6, 0), C(120, 130, 120)) end
	end
	-- the hook on a chain, in her right hand
	local hand = B.RightHand
	for i = 0, 3 do R.deco(hand, "Chain", Vector3.new(0.14, 0.4, 0.3), at(0, -0.6 - i * 0.38, 0, 0, (i % 2) * 1.57, 0), C(70, 64, 58), M.Metal) end
	local shank = R.deco(hand, "HookShank", Vector3.new(0.2, 1.3, 0.2), at(0, -2.7, 0), RUST, M.CorrodedMetal)
	R.deco(shank, "HookBend", Vector3.new(0.2, 0.2, 0.9), at(0, -0.65, -0.35), RUST, M.CorrodedMetal)
	R.deco(shank, "HookPoint", Vector3.new(0.18, 0.7, 0.18), at(0, -0.35, -0.8, 0.3, 0, 0), RUST, M.CorrodedMetal)
	-- a drip of water off her (tiny)
	local drip = Instance.new("ParticleEmitter")
	drip.Texture = "rbxasset://textures/particles/sparkles_main.dds"; drip.Rate = 3; drip.Lifetime = NumberRange.new(0.5, 0.8)
	drip.Speed = NumberRange.new(0, 0.5); drip.Acceleration = Vector3.new(0, -20, 0); drip.Size = NumberSequence.new(0.12)
	drip.Color = ColorSequence.new(C(150, 210, 220)); drip.Transparency = NumberSequence.new(0.3); drip.Parent = B.lower
	local glow = Instance.new("PointLight"); glow.Color = C(120, 220, 210); glow.Range = 8; glow.Brightness = 0.5; glow.Parent = B.head
	R.finish(B)
	table.insert(out, "LakeWitch hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE BURNED COUNSELOR
do
	local R = rig("Counselor")
	local CHAR, CHAR_D, SHIRT, SHORTS, CRACK = C(46, 34, 28), C(28, 22, 20), C(170, 84, 30), C(70, 66, 52), C(255, 120, 40)
	local B = R.body({ skin = CHAR, lowerSize = Vector3.new(2.0, 1.3, 1.2), lowerColor = SHORTS, upperSize = Vector3.new(2.4, 2.8, 1.3), upperColor = SHIRT,
		upperMat = M.Fabric, headSize = Vector3.new(1.4, 1.5, 1.4), headColor = CHAR, armW = 0.65, upperArm = 2.0, lowerArm = 2.0, hand = 0.8,
		sleeve = SHIRT, sleeveMat = M.Fabric, forearm = CHAR, legW = 0.8, upperLeg = 2.2, lowerLeg = 2.2, footLen = 1.4, legColor = SHORTS,
		shinColor = CHAR, footColor = C(30, 28, 26) })
	-- scorched holes in the shirt, the camp patch, the whistle on its lanyard
	for _, p in { { -0.6, 0.6 }, { 0.5, -0.5 }, { 0.2, 1.0 } } do R.deco(B.upper, "Scorch", Vector3.new(0.6, 0.5, 0.08), at(p[1], p[2], -0.66), CHAR_D) end
	R.deco(B.upper, "Patch", Vector3.new(0.6, 0.6, 0.08), at(0.6, 0.7, -0.68), C(60, 90, 56), M.Fabric)
	R.deco(B.upper, "Lanyard", Vector3.new(1.2, 0.1, 0.08), at(0, 1.1, -0.68), C(200, 40, 40), M.Fabric)
	R.deco(B.upper, "LanyardDown", Vector3.new(0.1, 1.0, 0.08), at(0, 0.6, -0.68), C(200, 40, 40), M.Fabric)
	R.deco(B.upper, "Whistle", Vector3.new(0.3, 0.2, 0.4), at(0, 0.05, -0.8), C(190, 190, 194), M.Metal)
	-- the face: melted on one side, glowing cracks, white eyes
	R.deco(B.head, "Melt", Vector3.new(0.6, 0.9, 0.3), at(0.45, -0.4, -0.65, 0, 0, 0.2), CHAR_D)
	for _, s in { -1, 1 } do R.deco(B.head, "Eye", Vector3.new(0.2, 0.14, 0.05), at(s * 0.33, 0.15, -0.72), C(255, 230, 190), M.Neon) end
	R.deco(B.head, "Mouth", Vector3.new(0.7, 0.15, 0.05), at(-0.1, -0.4, -0.72, 0, 0, -0.15), CRACK, M.Neon)
	-- glowing cracks all over the burnt skin
	for _, bp in { "Head", "LeftLowerArm", "RightLowerArm", "LeftLowerLeg", "RightLowerLeg" } do
		local part = bp == "Head" and B.head or B[bp]
		for k = 0, 1 do
			R.deco(part, "Crack", Vector3.new(0.06, part.Size.Y * 0.55, 0.06), at((k - 0.5) * 0.3, 0, -part.Size.Z / 2 - 0.01, 0, 0, (k - 0.5) * 0.6), CRACK, M.Neon)
		end
	end
	-- the torch in his right hand
	local hand = B.RightHand
	local handle = R.deco(hand, "Torch", Vector3.new(0.3, 2.4, 0.3), at(0, -0.2, -0.5, -1.1, 0, 0), C(80, 56, 36), M.Wood)
	R.deco(handle, "Wrap", Vector3.new(0.45, 0.6, 0.45), at(0, 1.1, 0), C(50, 40, 30), M.Fabric)
	local flame = R.deco(handle, "Flame", Vector3.new(0.5, 0.9, 0.5), at(0, 1.75, 0), C(255, 150, 40), M.Neon)
	flame.Transparency = 0.15
	local fl = Instance.new("PointLight"); fl.Color = C(255, 150, 60); fl.Range = 16; fl.Brightness = 1.6; fl.Parent = flame
	local fire = Instance.new("Fire"); fire.Size = 2; fire.Heat = 6; fire.Color = C(255, 140, 40); fire.SecondaryColor = C(200, 40, 20); fire.Parent = flame
	-- thin smoke off his shoulders
	local sm = Instance.new("ParticleEmitter")
	sm.Texture = "rbxasset://textures/particles/smoke_main.dds"; sm.Rate = 2; sm.Lifetime = NumberRange.new(1, 1.6); sm.Speed = NumberRange.new(1, 2)
	sm.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1.6) })
	sm.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
	sm.Color = ColorSequence.new(C(60, 56, 52)); sm.Parent = B.upper
	R.finish(B)
	table.insert(out, "Counselor hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE SCARECROW
do
	local R = rig("Scarecrow")
	local SACK, COAT, COAT_D, STRAW, ROPE, PANTS = C(176, 150, 106), C(56, 66, 46), C(40, 48, 34), C(214, 182, 96), C(120, 92, 60), C(86, 70, 52)
	local B = R.body({ skin = SACK, lowerSize = Vector3.new(1.8, 1.2, 1.0), lowerColor = PANTS, upperSize = Vector3.new(2.2, 2.6, 1.1), upperColor = COAT,
		upperMat = M.Fabric, headSize = Vector3.new(1.5, 1.6, 1.4), headColor = SACK, headMat = M.Fabric, armW = 0.55, upperArm = 2.1, lowerArm = 2.0, hand = 0.7,
		sleeve = COAT, sleeveMat = M.Fabric, forearm = COAT_D, handColor = STRAW, legW = 0.7, upperLeg = 2.3, lowerLeg = 2.2, footLen = 1.2,
		legColor = PANTS, legMat = M.Fabric, footColor = C(50, 40, 32) })
	-- the sack face: button eyes, a stitched grin, the tie round the neck
	for _, s in { -1, 1 } do
		R.deco(B.head, "Button", Vector3.new(0.3, 0.3, 0.08), at(s * 0.35, 0.2, -0.72), C(20, 18, 18))
		R.deco(B.head, "Thread", Vector3.new(0.3, 0.05, 0.02), at(s * 0.35, 0.2, -0.77, 0, 0, 0.8), C(150, 40, 30))
	end
	R.deco(B.head, "Grin", Vector3.new(0.9, 0.06, 0.04), at(0, -0.35, -0.72, 0, 0, 0.05), C(30, 24, 20))
	for i = -3, 3 do R.deco(B.head, "Stitch", Vector3.new(0.05, 0.22, 0.04), at(i * 0.13, -0.35, -0.73), C(30, 24, 20)) end
	R.deco(B.head, "NeckTie", Vector3.new(1.0, 0.25, 1.0), at(0, -0.82, 0), ROPE, M.Fabric)
	-- the straw hat: a wide floppy brim, a squat crown with a hole in it
	R.deco(B.head, "Brim", Vector3.new(2.8, 0.15, 2.8), at(0, 0.82, 0, 0.08, 0, -0.05), STRAW, M.Grass)
	R.deco(B.head, "Crown", Vector3.new(1.4, 0.8, 1.4), at(0, 1.25, 0), STRAW, M.Grass)
	R.deco(B.head, "HatBand", Vector3.new(1.45, 0.2, 1.45), at(0, 0.98, 0), C(110, 30, 26), M.Fabric)
	-- straw bursting out of the collar, the sleeves and the trouser legs
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		R.deco(B.upper, "Straw", Vector3.new(0.12, 0.8, 0.12), at(math.cos(a) * 0.6, 1.5, math.sin(a) * 0.4, math.sin(a) * 0.5, 0, math.cos(a) * 0.5), STRAW, M.Grass)
	end
	for _, L in { "Left", "Right" } do
		for k = -1, 1 do R.deco(B[L .. "Hand"], "Straw", Vector3.new(0.12, 0.9, 0.12), at(k * 0.15, -0.45, 0, 0, 0, k * 0.3), STRAW, M.Grass) end
		for k = -1, 1 do R.deco(B[L .. "LowerLeg"], "Straw", Vector3.new(0.12, 0.6, 0.12), at(k * 0.18, -1.1, -0.2, -0.3, 0, k * 0.3), STRAW, M.Grass) end
	end
	-- the ragged coat tails, patches, the rope belt
	R.deco(B.lower, "CoatTail", Vector3.new(2.3, 2.2, 1.3), at(0, -1.0, 0.05), COAT, M.Fabric)
	for i = -2, 2 do R.deco(B.lower, "Tatter", Vector3.new(0.4, 0.6, 0.1), at(i * 0.45, -2.35, -0.6, 0, 0, i * 0.2), COAT_D, M.Fabric) end
	R.deco(B.upper, "Patch", Vector3.new(0.6, 0.6, 0.06), at(-0.5, -0.3, -0.58), C(130, 60, 50), M.Fabric)
	R.deco(B.lower, "Belt", Vector3.new(1.95, 0.25, 1.15), at(0, 0.45, 0), ROPE, M.Fabric)
	-- the sickle in his right hand
	local hand = B.RightHand
	local handle = R.deco(hand, "SickleHandle", Vector3.new(0.25, 1.4, 0.25), at(0, -0.4, -0.2, -1.2, 0, 0), C(90, 64, 40), M.Wood)
	for k = 0, 4 do
		local a = k * 0.45
		R.deco(handle, "Blade", Vector3.new(0.08, 0.5, 0.5), at(0, 0.8 + math.sin(a) * 0.7, -math.cos(a) * 0.7 + 0.7, a, 0, 0), C(150, 146, 140), M.Metal)
	end
	R.finish(B)
	table.insert(out, "Scarecrow hover " .. string.format("%.2f", B.hover))
end

return table.concat(out, "\n")
