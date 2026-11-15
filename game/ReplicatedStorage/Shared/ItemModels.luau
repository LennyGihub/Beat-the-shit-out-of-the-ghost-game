-- 3D models for the 50 items (stands + first-person hands). Each item has an AI-made textured mesh in
-- ReplicatedStorage.ItemMeshes.<ItemId> (pivot = grip, pointing toward -Z); the part-built shapes below are the fallback.
-- Model space: grip at the origin, the item points/extends toward -Z (barrel, blade tip), +Y is up.
local ItemModels = {}
local M = Enum.Material
local CYL = Enum.PartType.Cylinder
local BALL = Enum.PartType.Ball
local ALONG = CFrame.Angles(0, math.pi / 2, 0) -- cylinder axis (X) -> along Z
local UPC = CFrame.Angles(0, 0, math.pi / 2) -- cylinder axis -> Y
local WOOD = Color3.fromRGB(120, 85, 55)
local DARK = Color3.fromRGB(35, 35, 38)
local STEEL = Color3.fromRGB(190, 192, 198)

local function p(m: Model, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): BasePart
	local part = Instance.new("Part")
	part.Size = size; part.CFrame = cf; part.Color = color; part.Material = mat or M.SmoothPlastic
	if shape then part.Shape = shape end
	part.Anchored = true; part.CanCollide = false; part.CanQuery = false; part.CanTouch = false; part.CastShadow = false
	part.Parent = m
	return part
end
local function stick(m, len, d, color, mat, z0) -- cylinder from z0 toward -Z
	return p(m, Vector3.new(len, d, d), CFrame.new(0, 0, (z0 or 0) - len / 2) * ALONG, color, mat, CYL)
end

local B = {}
function B.bat(m, c) stick(m, 1.2, 0.3, DARK, M.Fabric, 0.4); p(m, Vector3.new(3.4, 0.5, 0.5), CFrame.new(0, 0, -2.3) * ALONG, c, M.Wood, CYL) end
function B.spikedbat(m, c)
	B.bat(m, c)
	for i = 0, 5 do p(m, Vector3.new(0.08, 0.5, 0.08), CFrame.new(0, 0, -1.8 - i * 0.4) * CFrame.Angles(0, 0, i * 1.1) * CFrame.new(0, 0.32, 0), STEEL, M.Metal) end
end
function B.pan(m, c) stick(m, 1.8, 0.2, DARK, M.Metal, 0.4); p(m, Vector3.new(0.15, 1.8, 1.8), CFrame.new(0, 0, -2.2) * UPC, c, M.Metal, CYL) end
function B.crowbar(m, c) p(m, Vector3.new(0.18, 0.18, 3.6), CFrame.new(0, 0, -1.4), c, M.Metal); p(m, Vector3.new(0.18, 0.6, 0.18), CFrame.new(0, 0.25, -3.25) * CFrame.Angles(0.4, 0, 0), c, M.Metal) end
function B.pipe(m, c) stick(m, 3.4, 0.28, c, M.Metal, 0.4); p(m, Vector3.new(0.35, 0.4, 0.4), CFrame.new(0, 0, -2.9) * ALONG, c, M.Metal, CYL) end
function B.shovel(m, c) stick(m, 3.4, 0.2, WOOD, M.Wood, 0.4); p(m, Vector3.new(1, 0.08, 1.3), CFrame.new(0, 0, -3.6), c, M.Metal) end
function B.golf(m, c) stick(m, 3.6, 0.12, c, M.Metal, 0.4); p(m, Vector3.new(0.5, 0.35, 0.3), CFrame.new(0.15, -0.1, -3.3), DARK, M.Metal) end
function B.machete(m, c) stick(m, 0.9, 0.22, DARK, M.Fabric, 0.4); p(m, Vector3.new(0.06, 0.45, 2.2), CFrame.new(0, 0.05, -1.6), c, M.Metal) end
function B.katana(m, c) stick(m, 1.1, 0.18, DARK, M.Fabric, 0.4); p(m, Vector3.new(0.4, 0.1, 0.4), CFrame.new(0, 0, -0.75), Color3.fromRGB(180, 150, 60), M.Metal); p(m, Vector3.new(0.05, 0.22, 3.2), CFrame.new(0, 0, -2.4), c, M.Metal) end
function B.axe(m, c) stick(m, 3, 0.22, WOOD, M.Wood, 0.4); p(m, Vector3.new(0.15, 1, 0.8), CFrame.new(0, 0.4, -2.4), c, M.Metal); p(m, Vector3.new(0.12, 0.4, 0.5), CFrame.new(0, -0.3, -2.4), DARK, M.Metal) end
function B.sledge(m, c) stick(m, 3.4, 0.22, WOOD, M.Wood, 0.4); p(m, Vector3.new(0.7, 0.7, 1.6), CFrame.new(0, 0, -3.2) * CFrame.Angles(0, math.pi / 2, 0), c, M.Metal) end
function B.warhammer(m, c) B.sledge(m, c); p(m, Vector3.new(0.4, 0.4, 0.4), CFrame.new(0, 0, -3.2), Color3.fromRGB(230, 240, 255), M.Neon) end
function B.pickaxe(m, c) stick(m, 3, 0.2, WOOD, M.Wood, 0.4); p(m, Vector3.new(0.15, 0.2, 2.2), CFrame.new(0, 0, -2.6) * CFrame.Angles(0, math.pi / 2, 0), c, M.Ice) end
function B.cross(m, c) p(m, Vector3.new(0.25, 0.25, 2.2), CFrame.new(0, 0, -0.9), c, M.Metal); p(m, Vector3.new(1.2, 0.22, 0.22), CFrame.new(0, 0, -1.4), c, M.Metal) end
-- Chainsaw: blocky PS2-era build (flat colours, chunky blocks, no smooth meshes), like the hands.
-- Right hand = rear handle (origin), left hand = the wrap-around top handle (part "LeftGrip").
-- The chain is 28 teeth in a folder "Chain" that ItemModels.animate slides around the bar.
local SAW_BAR_Y, SAW_BAR_H, SAW_Z0, SAW_Z1 = -0.05, 0.62, -1.55, -5.75 -- bar centre height, height, start, tip
local SAW_X = 0.42
local SAW_TEETH = 34
local function sawLoop(t: number): CFrame
	-- t in [0,1): along the top edge toward the tip, round the nose, back along the bottom edge
	local r = SAW_BAR_H / 2 + 0.04
	local len = SAW_Z0 - SAW_Z1
	local total = 2 * len + math.pi * r
	local d = (t % 1) * total
	if d < len then
		return CFrame.new(SAW_X, SAW_BAR_Y + r, SAW_Z0 - d)
	end
	d -= len
	local arc = math.pi * r
	if d < arc then
		local a = d / r -- 0..pi round the nose
		return CFrame.new(SAW_X, SAW_BAR_Y + math.cos(a) * r, SAW_Z1 - math.sin(a) * r) * CFrame.Angles(-a, 0, 0)
	end
	d -= arc
	return CFrame.new(SAW_X, SAW_BAR_Y - r, SAW_Z1 + d) * CFrame.Angles(math.pi, 0, 0)
end
function B.chainsaw(m, c)
	local body = c:Lerp(Color3.fromRGB(90, 62, 40), 0.42) -- worn, dirty orange
	local bodyDark = c:Lerp(Color3.new(0, 0, 0), 0.35)
	local black = Color3.fromRGB(28, 26, 24)
	local grey = Color3.fromRGB(70, 68, 64)
	local bar = Color3.fromRGB(112, 108, 100)
	local P = M.SmoothPlastic
	-- rear handle: grip on top, trigger guard below, closed at the back
	p(m, Vector3.new(0.3, 0.32, 1.05), CFrame.new(0, 0, 0.02), black, P).Name = "RearGrip"
	p(m, Vector3.new(0.26, 0.16, 0.95), CFrame.new(0, -0.48, 0.05), black, P)
	p(m, Vector3.new(0.26, 0.64, 0.2), CFrame.new(0, -0.24, 0.5), black, P)
	p(m, Vector3.new(0.1, 0.22, 0.16), CFrame.new(0, -0.24, -0.15), Color3.fromRGB(150, 30, 24), P) -- trigger
	-- engine housing
	p(m, Vector3.new(1.0, 1.0, 1.55), CFrame.new(0, 0.12, -1.2), body, P)
	p(m, Vector3.new(0.92, 0.22, 1.3), CFrame.new(0, 0.72, -1.15), grey, P) -- top cover
	p(m, Vector3.new(1.04, 0.14, 1.6), CFrame.new(0, -0.38, -1.2), bodyDark, P) -- base plate
	for i = 0, 3 do p(m, Vector3.new(0.94, 0.06, 0.1), CFrame.new(0, 0.86, -0.75 - i * 0.28), black, P) end -- cooling fins
	p(m, Vector3.new(0.3, 0.12, 0.3), CFrame.new(-0.22, 0.88, -1.62), black, P) -- fuel cap
	-- pull starter on the left side
	p(m, Vector3.new(0.14, 0.72, 0.72), CFrame.new(-0.56, 0.14, -1.1), grey, P)
	p(m, Vector3.new(0.12, 0.44, 0.44), CFrame.new(-0.64, 0.14, -1.1), black, P)
	p(m, Vector3.new(0.14, 0.14, 0.42), CFrame.new(-0.72, 0.42, -0.95), black, P) -- pull handle
	-- clutch cover on the bar side + muffler in front
	p(m, Vector3.new(0.2, 0.7, 0.8), CFrame.new(0.58, 0.04, -1.55), bodyDark, P)
	p(m, Vector3.new(0.62, 0.34, 0.2), CFrame.new(-0.12, -0.08, -2.04), Color3.fromRGB(45, 42, 40), M.Metal)
	-- wrap-around top handle (left hand) + hand guard
	p(m, Vector3.new(1.3, 0.26, 0.26), CFrame.new(-0.12, 1.12, -1.6), black, P)
	p(m, Vector3.new(0.26, 1.02, 0.26), CFrame.new(-0.77, 0.73, -1.6), black, P)
	p(m, Vector3.new(0.26, 0.44, 0.26), CFrame.new(0.53, 1.02, -1.6), black, P)
	p(m, Vector3.new(1.0, 0.5, 0.1), CFrame.new(-0.08, 1.05, -1.86), grey, P) -- hand guard
	local lg = p(m, Vector3.one * 0.2, CFrame.new(-0.3, 1.12, -1.6), black, P)
	lg.Name = "LeftGrip"; lg.Transparency = 1
	-- guide bar: flat plate with a stepped (low-poly) nose
	local len = SAW_Z0 - SAW_Z1
	p(m, Vector3.new(0.12, SAW_BAR_H, len), CFrame.new(SAW_X, SAW_BAR_Y, (SAW_Z0 + SAW_Z1) / 2), bar, M.Metal)
	p(m, Vector3.new(0.12, SAW_BAR_H * 0.7, 0.18), CFrame.new(SAW_X, SAW_BAR_Y, SAW_Z1 - 0.09), bar, M.Metal)
	p(m, Vector3.new(0.12, SAW_BAR_H * 0.36, 0.12), CFrame.new(SAW_X, SAW_BAR_Y, SAW_Z1 - 0.22), bar, M.Metal)
	p(m, Vector3.new(0.14, 0.1, len * 0.8), CFrame.new(SAW_X, SAW_BAR_Y, (SAW_Z0 + SAW_Z1) / 2 - 0.1), Color3.fromRGB(70, 67, 62), M.Metal) -- groove
	-- chain teeth
	local chain = Instance.new("Folder"); chain.Name = "Chain"; chain.Parent = m
	for i = 0, SAW_TEETH - 1 do
		local t = p(m, Vector3.new(0.18, 0.12, 0.17), sawLoop(i / SAW_TEETH), i % 2 == 0 and Color3.fromRGB(40, 38, 36) or Color3.fromRGB(78, 75, 70), M.Metal)
		t.Name = "Tooth"; t:SetAttribute("T", i / SAW_TEETH); t.Parent = chain
	end
end
function B.nailgun(m, c) p(m, Vector3.new(0.6, 0.7, 1.8), CFrame.new(0, 0.2, -0.8), c); p(m, Vector3.new(0.4, 0.9, 0.4), CFrame.new(0, -0.4, 0), DARK) ; p(m, Vector3.new(0.3, 0.3, 0.6), CFrame.new(0, 0.1, -1.9), DARK, M.Metal) end
function B.taser(m, c) p(m, Vector3.new(0.45, 0.5, 1.2), CFrame.new(0, 0.15, -0.6), c); p(m, Vector3.new(0.35, 0.8, 0.35), CFrame.new(0, -0.35, 0), DARK) end
function B.pistol(m, c) p(m, Vector3.new(0.3, 0.35, 1.4), CFrame.new(0, 0.2, -0.65), c, M.Metal); p(m, Vector3.new(0.28, 0.8, 0.35), CFrame.new(0, -0.3, 0), DARK) ; stick(m, 0.6, 0.18, c, M.Metal, -1.3) end
function B.shotgun(m, c) p(m, Vector3.new(0.35, 0.5, 1.6), CFrame.new(0, -0.1, 0.4), c, M.Wood); stick(m, 3.2, 0.22, DARK, M.Metal, -0.4); stick(m, 1.2, 0.3, c, M.Wood, -1.0) end
function B.cannon(m, c) stick(m, 3, 0.6, c, M.SmoothPlastic, 0.4); p(m, Vector3.new(0.3, 0.8, 0.3), CFrame.new(0, -0.5, 0), DARK) end
function B.crossbow(m, c) p(m, Vector3.new(0.3, 0.3, 2.2), CFrame.new(0, 0, -0.9), c, M.Wood); p(m, Vector3.new(2.2, 0.15, 0.2), CFrame.new(0, 0, -1.8), DARK, M.Wood); p(m, Vector3.new(0.12, 0.12, 1.8), CFrame.new(0, 0.18, -1.2), STEEL, M.Metal) end
function B.harpoon(m, c) stick(m, 2.6, 0.35, c, M.Metal, 0.4); p(m, Vector3.new(0.12, 0.12, 1.4), CFrame.new(0, 0, -2.8), STEEL, M.Metal); p(m, Vector3.new(0.5, 0.15, 0.3), CFrame.new(0, 0, -3.4), STEEL, M.Metal) end
function B.brick(m, c) p(m, Vector3.new(0.9, 0.5, 1.6), CFrame.new(0, 0, -0.6), c, M.Brick) end
function B.knife(m, c) stick(m, 0.6, 0.14, DARK, M.Fabric, 0.2); p(m, Vector3.new(0.04, 0.22, 0.9), CFrame.new(0, 0, -0.8), c, M.Metal) end
function B.firecracker(m, c) for i = 0, 2 do p(m, Vector3.new(0.9, 0.22, 0.22), CFrame.new(0.25 * i - 0.25, 0, -0.5) * UPC, c, M.SmoothPlastic, CYL) end end
function B.grenade(m, c) p(m, Vector3.new(0.8, 0.95, 0.8), CFrame.new(0, 0, -0.5), c, M.Metal, BALL); p(m, Vector3.new(0.3, 0.3, 0.3), CFrame.new(0, 0.55, -0.5), DARK, M.Metal) end
function B.bottle(m, c) p(m, Vector3.new(1.1, 0.7, 0.7), CFrame.new(0, 0, -0.5) * UPC, c, M.Glass, CYL); p(m, Vector3.new(0.5, 0.3, 0.3), CFrame.new(0, 0.75, -0.5) * UPC, c, M.Glass, CYL); p(m, Vector3.new(0.15, 0.6, 0.15), CFrame.new(0, 1.2, -0.5), Color3.fromRGB(230, 220, 200), M.Fabric) end
function B.pouch(m, c) p(m, Vector3.new(0.9, 0.9, 0.9), CFrame.new(0, 0, -0.5), c, M.Fabric, BALL); p(m, Vector3.new(0.35, 0.2, 0.35), CFrame.new(0, 0.5, -0.5), Color3.fromRGB(90, 70, 50), M.Fabric) end
function B.ball(m, c) p(m, Vector3.one * 1.3, CFrame.new(0, 0, -0.6), c, M.SmoothPlastic, BALL) end
function B.pipebomb(m, c) stick(m, 1.2, 0.4, c, M.Metal, 0); p(m, Vector3.new(0.05, 0.4, 0.05), CFrame.new(0, 0.3, -0.6), Color3.fromRGB(200, 40, 30)) end
function B.doll(m, c) p(m, Vector3.new(0.5, 0.7, 0.35), CFrame.new(0, 0, -0.5), c, M.Fabric); p(m, Vector3.one * 0.5, CFrame.new(0, 0.55, -0.5), c, M.Fabric, BALL); p(m, Vector3.new(0.08, 0.6, 0.08), CFrame.new(0.1, 0.1, -0.7) * CFrame.Angles(0.6, 0, 0.3), STEEL, M.Metal) end
function B.blower(m, c) p(m, Vector3.new(0.9, 0.9, 1.2), CFrame.new(0, 0, 0), c); stick(m, 2.2, 0.4, c, M.SmoothPlastic, -0.6) end
function B.can(m, c) p(m, Vector3.new(1, 0.5, 0.5), CFrame.new(0, 0, -0.4) * UPC, c, M.Metal, CYL); p(m, Vector3.new(0.15, 0.2, 0.2), CFrame.new(0, 0.55, -0.4) * UPC, DARK, M.Metal, CYL) end
function B.extinguisher(m, c) p(m, Vector3.new(1.6, 0.8, 0.8), CFrame.new(0, -0.2, 0.2) * UPC, c, M.Metal, CYL); stick(m, 1.2, 0.18, DARK, M.Rubber, -0.4) end
function B.flashlight(m, c) stick(m, 1.6, 0.35, DARK, M.Metal, 0.4); p(m, Vector3.new(0.3, 0.55, 0.55), CFrame.new(0, 0, -1.3) * ALONG, c, M.Neon, CYL) end
function B.vacuum(m, c) p(m, Vector3.new(1, 1, 1.2), CFrame.new(0, -0.1, 0.2), c); stick(m, 2.4, 0.35, DARK, M.SmoothPlastic, -0.4); p(m, Vector3.new(0.8, 0.2, 0.4), CFrame.new(0, 0, -2.9), DARK) end
function B.flamethrower(m, c) p(m, Vector3.new(0.6, 0.6, 1.4), CFrame.new(0, 0, 0), c, M.Metal); stick(m, 2.2, 0.25, DARK, M.Metal, -0.7); p(m, Vector3.new(0.2, 0.2, 0.2), CFrame.new(0, 0, -2.95), Color3.fromRGB(255, 120, 30), M.Neon) end
function B.medkit(m, c) p(m, Vector3.new(1.2, 0.8, 0.5), CFrame.new(0, 0, -0.4), c); p(m, Vector3.new(0.5, 0.15, 0.52), CFrame.new(0, 0, -0.4), Color3.fromRGB(200, 20, 20)); p(m, Vector3.new(0.15, 0.5, 0.52), CFrame.new(0, 0, -0.4), Color3.fromRGB(200, 20, 20)) end
function B.pills(m, c) p(m, Vector3.new(0.9, 0.45, 0.45), CFrame.new(0, 0, -0.4) * UPC, c, M.SmoothPlastic, CYL); p(m, Vector3.new(0.2, 0.5, 0.5), CFrame.new(0, 0.5, -0.4) * UPC, Color3.fromRGB(240, 240, 235), M.SmoothPlastic, CYL) end
function B.syringe(m, c) stick(m, 1.1, 0.25, c, M.Glass, 0.2); stick(m, 0.6, 0.05, STEEL, M.Metal, -0.9) end
function B.vest(m, c) p(m, Vector3.new(1.4, 1.5, 0.4), CFrame.new(0, 0, -0.4), c, M.Fabric) end
function B.talisman(m, c) p(m, Vector3.new(0.6, 1.3, 0.05), CFrame.new(0, 0.2, -0.5), c, M.SmoothPlastic); p(m, Vector3.new(0.1, 0.8, 0.06), CFrame.new(0, 0.2, -0.5), Color3.fromRGB(170, 20, 20)) end
function B.watch(m, c) p(m, Vector3.new(0.15, 0.8, 0.8), CFrame.new(0, 0, -0.5) * UPC, c, M.Metal, CYL); p(m, Vector3.new(0.16, 0.65, 0.65), CFrame.new(0, 0.01, -0.5) * UPC, Color3.fromRGB(235, 230, 210), M.SmoothPlastic, CYL) end
function B.beartrap(m, c)
	p(m, Vector3.new(0.15, 1.6, 1.6), CFrame.new(0, 0, -0.6) * UPC, c, M.Metal, CYL)
	for k = 0, 5 do p(m, Vector3.new(0.1, 0.35, 0.1), CFrame.new(0, 0, -0.6) * CFrame.Angles(0, k * math.pi / 3, 0) * CFrame.new(0, 0.2, 0.7), STEEL, M.Metal) end
end

-- shapes rebuilt in the blocky PS2 style: these ignore the old AI meshes in ReplicatedStorage.ItemMeshes
local BLOCKY = { chainsaw = true }

function ItemModels.build(shape: string, color: Color3, glow: Color3?, id: string?): Model
	local meshes = game:GetService("ReplicatedStorage"):FindFirstChild("ItemMeshes")
	local mesh = id and not BLOCKY[shape] and meshes and meshes:FindFirstChild(id)
	if mesh then
		local m = mesh:Clone()
		m.Name = "Item_" .. shape
		for _, d in m:GetDescendants() do
			if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false; d.CanQuery = false; d.CanTouch = false; d.CastShadow = false end
		end
		if glow then
			local root = m:FindFirstChildWhichIsA("BasePart", true)
			if root then local l = Instance.new("PointLight"); l.Color = glow; l.Range = 8; l.Brightness = 1.2; l.Parent = root end
		end
		return m
	end
	local m = Instance.new("Model")
	m.Name = "Item_" .. shape
	local grip = p(m, Vector3.one * 0.2, CFrame.new(), color)
	grip.Name = "Grip"; grip.Transparency = 1
	m.PrimaryPart = grip
	local f = B[shape] or B.brick
	f(m, color)
	if glow then
		local l = Instance.new("PointLight"); l.Color = glow; l.Range = 8; l.Brightness = 1.2; l.Parent = grip
	end
	return m
end

-- per-frame motion of an item's moving parts (the chainsaw chain). speed = loops per second.
-- Teeth positions are relative to the model's pivot, so call it after the model is moved.
function ItemModels.animate(m: Model, speed: number)
	local chain = m:FindFirstChild("Chain")
	if not chain then return end
	local pivot = m:GetPivot()
	local scale = m:GetScale()
	local shift = (os.clock() * speed) % 1
	for _, t in chain:GetChildren() do
		local base = t:GetAttribute("T")
		if type(base) == "number" then
			local cf = sawLoop(base + shift)
			;(t :: BasePart).CFrame = pivot * (cf - cf.Position + cf.Position * scale)
		end
	end
end

-- how big the model is along its length (for laying it on a shelf)
function ItemModels.isLong(shape: string): boolean
	local long = { bat = 1, spikedbat = 1, pan = 1, crowbar = 1, pipe = 1, shovel = 1, golf = 1, machete = 1, katana = 1, axe = 1, sledge = 1, warhammer = 1,
		pickaxe = 1, chainsaw = 1, shotgun = 1, cannon = 1, harpoon = 1, crossbow = 1, blower = 1, vacuum = 1, flamethrower = 1, cross = 1 }
	return long[shape] ~= nil
end

return ItemModels
