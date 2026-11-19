-- Builds THE BLACK MOON's three new monsters into ServerStorage.Monsters (Edit, standalone; re-running replaces
-- them): python3 tools/studio.py luau Edit tools/build/moon_monsters.luau
--   Astronaut  THE LOST ASTRONAUT: a white spacesuit, scuffed and torn, a square helmet with a black visor and a skull
--              glowing faintly behind it, a chest panel with lights, orange patches, heavy boots, a jetpack on his
--              back (the part "Jetpack": Client/MoonFx puts the flames under it).
--   Specimen   THE SPECIMEN: an escaped alien - pale grey-green skin, long thin limbs, a long head swept back, a mouth
--              of fangs, no eyes but glowing green veins, a ridge of spines down its back, a long tail, claws.
--   Sentinel   THE SENTINEL: the base's guard robot - dark armour plates, one red eye in a visor slit (the part "Eye":
--              its missiles' aiming beams start there), a glowing reactor core in its chest, missile pods on both
--              shoulders (the parts "Pod"), piston arms, heavy hydraulic legs, warning stripes.
-- Hand-built from plain parts (the rig builder of tools/build/harbor_monsters.luau, copied).
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

---------------------------------------------------------------------------------------------- THE LOST ASTRONAUT
do
	local R = rig("Astronaut")
	local SUIT, SUITD, ORANGE, VISOR, BOOT = C(222, 222, 216), C(170, 170, 166), C(220, 110, 40), C(10, 10, 14), C(90, 92, 98)
	local B = R.body({ skin = SUIT, lowerSize = Vector3.new(2.3, 1.4, 1.6), lowerColor = SUIT, upperSize = Vector3.new(2.9, 2.6, 1.9), upperColor = SUIT,
		upperMat = M.Fabric, headSize = Vector3.new(1.9, 1.9, 1.9), headColor = SUIT, headMat = M.SmoothPlastic, armW = 1.0, upperArm = 2.1, lowerArm = 2.1, hand = 1.1,
		sleeve = SUIT, sleeveMat = M.Fabric, forearm = SUIT, forearmMat = M.Fabric, handColor = SUITD, legW = 1.15, upperLeg = 2.1, lowerLeg = 2.1,
		footLen = 2.0, legColor = SUIT, legMat = M.Fabric, shinColor = SUIT, footColor = BOOT })
	-- the helmet: a black visor with a faint skull behind it, a rim, a lamp on the side
	R.deco(B.head, "Visor", Vector3.new(1.5, 1.1, 0.12), at(0, 0.05, -0.95), VISOR, M.Glass).Reflectance = 0.3
	R.deco(B.head, "Skull", Vector3.new(0.7, 0.75, 0.05), at(0, 0.0, -0.88), C(200, 210, 190), M.Neon).Transparency = 0.6
	for _, s in { -1, 1 } do R.deco(B.head, "SkullEye", Vector3.new(0.16, 0.16, 0.04), at(s * 0.17, 0.1, -0.9), C(255, 90, 40), M.Neon) end
	R.deco(B.head, "Rim", Vector3.new(1.95, 0.3, 1.95), at(0, -0.85, 0), SUITD, M.Metal)
	local lamp = R.deco(B.head, "HelmetLamp", Vector3.new(0.35, 0.35, 0.35), at(0.95, 0.5, -0.5), C(255, 240, 200), M.Neon)
	local sl = Instance.new("SpotLight"); sl.Face = Enum.NormalId.Front; sl.Angle = 45; sl.Range = 30; sl.Brightness = 2; sl.Color = C(255, 240, 210); sl.Parent = lamp
	R.deco(B.head, "Antenna", Vector3.new(0.08, 1.2, 0.08), at(-0.7, 1.4, 0.4), SUITD, M.Metal)
	-- the chest panel with its lights, patches, a tear with the dark inside
	R.deco(B.upper, "Panel", Vector3.new(1.3, 0.9, 0.2), at(0, 0.3, -1.0), SUITD, M.Metal)
	for k = 0, 2 do R.deco(B.upper, "PanelLight", Vector3.new(0.2, 0.2, 0.06), at(-0.35 + k * 0.35, 0.35, -1.12), ({ C(255, 60, 40), C(255, 210, 60), C(80, 220, 255) })[k + 1], M.Neon) end
	R.deco(B.upper, "Patch", Vector3.new(0.6, 0.4, 0.06), at(-0.9, 0.9, -0.97), ORANGE, M.Fabric)
	R.deco(B.upper, "Tear", Vector3.new(0.7, 0.3, 0.06), at(0.7, -0.7, -0.97, 0, 0, 0.4), C(20, 16, 20))
	for _, s in { -1, 1 } do
		local L = s < 0 and "Left" or "Right"
		R.deco(B[L .. "LowerArm"], "Cuff", Vector3.new(1.05, 0.35, 1.05), at(0, -0.9, 0), ORANGE, M.Fabric)
		R.deco(B[L .. "LowerLeg"], "BootTop", Vector3.new(1.2, 0.8, 1.2), at(0, -0.6, 0), BOOT, M.Metal)
		R.deco(B[L .. "UpperArm"], "Flag", Vector3.new(0.05, 0.5, 0.7), at(s * 0.53, 0.5, 0), ORANGE, M.Fabric)
	end
	-- the jetpack: a block with two nozzles and a tank
	local pack = R.deco(B.upper, "Jetpack", Vector3.new(2.2, 2.4, 1.0), at(0, 0.1, 1.45), SUITD, M.Metal)
	for _, s in { -1, 1 } do
		R.deco(B.upper, "Nozzle", Vector3.new(0.6, 0.7, 0.6), at(s * 0.6, -1.35, 1.45), C(60, 60, 64), M.Metal)
		R.deco(B.upper, "Tank", Vector3.new(0.6, 2.0, 0.6), at(s * 0.85, 0.2, 2.0), ORANGE, M.Metal)
	end
	local _ = pack
	R.finish(B)
	table.insert(out, "Astronaut hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE SPECIMEN
do
	local R = rig("Specimen")
	local SKIN, SKIND, VEIN, MOUTH, FANG = C(118, 132, 110), C(78, 90, 72), C(130, 255, 90), C(60, 16, 26), C(236, 232, 210)
	local B = R.body({ skin = SKIN, lowerSize = Vector3.new(1.8, 1.4, 1.3), lowerColor = SKIND, upperSize = Vector3.new(2.3, 2.6, 1.5), upperColor = SKIN,
		upperMat = M.Slate, headSize = Vector3.new(1.2, 1.3, 1.6), headColor = SKIN, headMat = M.Slate, armW = 0.6, upperArm = 2.6, lowerArm = 2.6, hand = 1.1,
		sleeve = SKIN, sleeveMat = M.Slate, forearm = SKIN, forearmMat = M.Slate, handColor = SKIND, legW = 0.75, upperLeg = 2.4, lowerLeg = 2.4,
		footLen = 1.8, legColor = SKIN, legMat = M.Slate, footColor = SKIND })
	-- the long head swept back, its jaws and fangs, no eyes
	R.deco(B.head, "Dome", Vector3.new(1.1, 1.1, 2.6), at(0, 0.55, 1.1, -0.5, 0, 0), SKIN, M.Slate)
	R.deco(B.head, "Mouth", Vector3.new(1.0, 0.45, 0.1), at(0, -0.35, -0.82), MOUTH)
	for i = -2, 2 do
		R.deco(B.head, "Fang", Vector3.new(0.1, 0.32, 0.06), at(i * 0.18, -0.2, -0.86, 0, 0, math.pi), FANG, M.SmoothPlastic, Enum.PartType.Wedge)
		R.deco(B.head, "Fang", Vector3.new(0.1, 0.3, 0.06), at(i * 0.18 + 0.09, -0.52, -0.86), FANG, M.SmoothPlastic, Enum.PartType.Wedge)
	end
	-- the glowing veins on its head, body and limbs
	R.deco(B.head, "Vein", Vector3.new(0.08, 0.05, 2.2), at(0, 1.0, 0.8, -0.45, 0, 0), VEIN, M.Neon)
	for _, s in { -1, 1 } do
		local L = s < 0 and "Left" or "Right"
		R.deco(B.head, "Vein", Vector3.new(0.05, 0.6, 0.05), at(s * 0.45, 0.1, -0.78, 0, 0, s * 0.3), VEIN, M.Neon)
		R.deco(B.upper, "Vein", Vector3.new(0.08, 2.2, 0.05), at(s * 0.5, 0, -0.77, 0, 0, s * 0.15), VEIN, M.Neon)
		R.deco(B[L .. "UpperArm"], "Vein", Vector3.new(0.05, 2.2, 0.05), at(0, 0, -0.32), VEIN, M.Neon)
		R.deco(B[L .. "UpperLeg"], "Vein", Vector3.new(0.05, 2.0, 0.05), at(0, 0, -0.4), VEIN, M.Neon)
		-- long claws
		for k = -1, 1 do R.deco(B[L .. "Hand"], "Claw", Vector3.new(0.1, 1.2, 0.1), at(k * 0.18, -0.95, -0.15, 0.25, 0, 0), C(40, 40, 36)) end
		-- ribs showing
		for k = 0, 2 do R.deco(B.upper, "Rib", Vector3.new(0.7, 0.1, 0.05), at(s * 0.7, 0.4 - k * 0.45, -0.77, 0, 0, s * -0.25), SKIND) end
	end
	-- spines down its back, the long tail
	for k = 0, 4 do R.deco(B.upper, "Spine", Vector3.new(0.15, 0.7 - k * 0.06, 0.6), at(0, 1.1 - k * 0.55, 0.85, -0.6, 0, 0), SKIND, M.Slate) end
	for k = 0, 4 do R.deco(B.lower, "Tail", Vector3.new(0.6 - k * 0.09, 0.6 - k * 0.09, 1.3), at(0, -0.6 - k * 0.35, 1.0 + k * 1.15, 0.3, 0, 0), k % 2 == 0 and SKIN or SKIND, M.Slate) end
	R.deco(B.lower, "TailTip", Vector3.new(0.15, 0.6, 0.8), at(0, -2.4, 6.6, 0.6, 0, 0), VEIN, M.Neon)
	local glow = Instance.new("PointLight"); glow.Color = VEIN; glow.Range = 10; glow.Brightness = 1; glow.Parent = B.upper
	R.finish(B)
	table.insert(out, "Specimen hover " .. string.format("%.2f", B.hover))
end

---------------------------------------------------------------------------------------------- THE SENTINEL
do
	local R = rig("Sentinel")
	local ARMOR, ARMORD, JOINT, RED, CORE, STRIPE = C(70, 74, 82), C(44, 46, 52), C(30, 30, 34), C(255, 50, 40), C(110, 220, 255), C(220, 180, 40)
	local B = R.body({ skin = ARMOR, lowerSize = Vector3.new(2.8, 1.6, 2.0), lowerColor = ARMORD, upperSize = Vector3.new(3.8, 3.0, 2.4), upperColor = ARMOR,
		upperMat = M.DiamondPlate, headSize = Vector3.new(1.7, 1.4, 1.6), headColor = ARMOR, headMat = M.Metal, armW = 1.2, upperArm = 2.3, lowerArm = 2.3, hand = 1.3,
		sleeve = JOINT, sleeveMat = M.Metal, forearm = ARMOR, forearmMat = M.Metal, handColor = ARMORD, legW = 1.35, upperLeg = 2.2, lowerLeg = 2.2,
		footLen = 2.4, legColor = JOINT, legMat = M.Metal, shinColor = ARMOR, footColor = ARMORD })
	-- the head: a visor slit with one red eye, a crest, antenna
	R.deco(B.head, "VisorSlit", Vector3.new(1.5, 0.35, 0.1), at(0, 0.1, -0.82), C(10, 10, 12), M.Metal)
	local eye = R.deco(B.head, "Eye", Vector3.new(0.45, 0.3, 0.12), at(0, 0.1, -0.85), RED, M.Neon)
	local el = Instance.new("PointLight"); el.Color = RED; el.Range = 10; el.Brightness = 1.2; el.Parent = eye
	R.deco(B.head, "Crest", Vector3.new(0.3, 0.5, 1.6), at(0, 0.9, 0), ARMORD, M.Metal)
	R.deco(B.head, "Jaw", Vector3.new(1.5, 0.4, 1.3), at(0, -0.65, -0.1), ARMORD, M.Metal)
	-- the chest: plates, the glowing reactor core, warning stripes
	R.deco(B.upper, "ChestPlate", Vector3.new(3.0, 2.0, 0.3), at(0, 0.3, -1.25), ARMORD, M.Metal)
	local core = R.deco(B.upper, "Core", Vector3.new(0.9, 0.9, 0.3), at(0, 0.3, -1.45), CORE, M.Neon)
	local cl = Instance.new("PointLight"); cl.Color = CORE; cl.Range = 14; cl.Brightness = 1.5; cl.Parent = core
	for k = 0, 3 do R.deco(B.lower, "Stripe", Vector3.new(0.4, 0.6, 0.06), at(-0.9 + k * 0.6, 0, -1.03, 0, 0, 0.6), k % 2 == 0 and STRIPE or C(20, 20, 20), M.SmoothPlastic) end
	-- the missile pods on both shoulders, their tubes
	for _, s in { -1, 1 } do
		local pod = R.deco(B.upper, "Pod", Vector3.new(1.3, 1.3, 2.0), at(s * 1.9, 1.9, 0.1), ARMORD, M.Metal)
		local _ = pod
		for i = 0, 1 do for j = 0, 1 do
			R.deco(B.upper, "Tube", Vector3.new(0.35, 0.35, 0.1), at(s * 1.9 - 0.3 + i * 0.6, 1.6 + j * 0.6, -0.92), C(10, 10, 10), M.Metal)
			R.deco(B.upper, "TubeTip", Vector3.new(0.18, 0.18, 0.05), at(s * 1.9 - 0.3 + i * 0.6, 1.6 + j * 0.6, -0.97), RED, M.Neon)
		end end
		local L = s < 0 and "Left" or "Right"
		-- pistons on the arms, armour on the shins, thick hands
		R.deco(B[L .. "UpperArm"], "Shoulder", Vector3.new(1.6, 1.0, 1.6), at(0, 0.9, 0), ARMOR, M.Metal)
		R.deco(B[L .. "LowerArm"], "Piston", Vector3.new(0.3, 2.0, 0.3), at(s * 0.45, 0, 0.5), C(160, 160, 166), M.Metal)
		R.deco(B[L .. "LowerLeg"], "ShinPlate", Vector3.new(1.4, 1.6, 0.3), at(0, 0, -0.75), ARMOR, M.Metal)
		R.deco(B[L .. "LowerLeg"], "Knee", Vector3.new(1.3, 0.6, 1.3), at(0, 1.0, -0.2), STRIPE, M.Metal)
		R.deco(B[L .. "Hand"], "Knuckle", Vector3.new(1.4, 0.4, 1.4), at(0, -0.4, 0), JOINT, M.Metal)
	end
	R.finish(B)
	table.insert(out, "Sentinel hover " .. string.format("%.2f", B.hover))
end

return table.concat(out, "\n")
