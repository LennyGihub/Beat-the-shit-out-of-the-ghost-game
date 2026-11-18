--!strict
-- EVOLVED monsters (every 3rd ghost, Shared/Monsters.evolved): the same monster, dressed up and with one extra power.
--   Evolved.dress(model, def)   right after the template is cloned (before it is scaled): colours, bones, sceptre...
--   Evolved.onSpawn(g, G)       once it exists (the Goblin King arms himself)
--   Evolved.chase(g, G, ...)    every frame in Chase: maybe start the power (returns true when it took over)
--   Evolved.step(g, G, ...)     while g.state == "Evo"
--   Evolved.interrupt(g)        the power was cut short (knocked back, frozen)
-- Powers (def.power.kind): doubles (Violet Widow), army (Burning Captain), snap (Golden Bear), eat (Bone Giant),
-- armed (Goblin King), laser (Golden Conqueror), shotgun (the Last Call). The Demon Lord's is his own ability with count = 3 (Abilities levitateThrow).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Remotes = require(script.Parent.Remotes)
local Abilities = require(script.Parent.Abilities)
local Furniture = require(script.Parent.Furniture)
local Ragdoll = require(script.Parent.Ragdoll)
local Fire = require(script.Parent.Fire)
local Fury = require(script.Parent.Fury)

local Evolved = {}
local rng = Random.new()
local C = Config.Ghost

-- dressing -------------------------------------------------------------------
local function rgb(r: number, g: number, b: number): Color3 return Color3.fromRGB(r, g, b) end
local function close(a: Color3, b: Color3): boolean
	return math.abs(a.R - b.R) + math.abs(a.G - b.G) + math.abs(a.B - b.B) < 0.035
end
-- swap colours: { from, to, material? }
local function recolor(m: Model, map: { { any } })
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			for _, e in map do
				if close(d.Color, e[1]) then
					d.Color = e[2]
					if e[3] then d.Material = e[3] end
					break
				end
			end
		end
	end
end
local function named(m: Model, names: { string }): { BasePart }
	local set = {}
	for _, n in names do set[n] = true end
	local out = {}
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and set[d.Name] then table.insert(out, d) end
	end
	return out
end
local function paint(m: Model, names: { string }, color: Color3, mat: Enum.Material?, transparency: number?)
	for _, p in named(m, names) do
		p.Color = color
		if mat then p.Material = mat end
		if transparency then p.Transparency = transparency end
	end
end
local function grow(m: Model, names: { string }, sx: number, sy: number, sz: number)
	for _, p in named(m, names) do p.Size = Vector3.new(p.Size.X * sx, p.Size.Y * sy, p.Size.Z * sz) end
end
-- a new decoration part welded to a body part (rel = its place in the body part's space)
local function add(on: BasePart, name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = false; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.Massless = true; p.CastShadow = false
	p.CFrame = on.CFrame * rel
	local w = Instance.new("WeldConstraint"); w.Part0 = on; w.Part1 = p; w.Parent = p
	p.Parent = on.Parent
	return p
end
local function glow(p: BasePart, color: Color3, range: number, brightness: number)
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range; l.Brightness = brightness; l.Shadows = false; l.Parent = p
end
local function tint(m: Model, color: Color3)
	for _, d in m:GetDescendants() do
		if d:IsA("PointLight") then d.Color = color
		elseif d:IsA("ParticleEmitter") then d.Color = ColorSequence.new(color) end
	end
end
local function body(m: Model, n: string): BasePart? return m:FindFirstChild(n) :: BasePart? end

local BONE = rgb(206, 192, 166)
local DRESS: { [string]: (m: Model) -> () } = {}

-- the Violet Widow: purple skin, dark violet dress, glowing claws and eyes
DRESS.Woman = function(m)
	recolor(m, {
		{ rgb(150, 172, 176), rgb(150, 96, 200) }, { rgb(138, 160, 160), rgb(66, 36, 104) },
		{ rgb(200, 214, 210), rgb(255, 120, 255), Enum.Material.Neon }, { rgb(70, 20, 22), rgb(130, 30, 150) },
	})
	for _, s in named(m, { "EyeSocket" }) do
		add(s, "EvoEye", Vector3.new(s.Size.X * 0.5, s.Size.Y * 0.5, 0.08), CFrame.new(0, 0, -s.Size.Z / 2 - 0.02), rgb(230, 120, 255), Enum.Material.Neon)
	end
	tint(m, rgb(190, 110, 255))
	local torso = body(m, "UpperTorso")
	if torso then glow(torso, rgb(170, 80, 255), 16, 1.2) end
end

-- the Demon Lord: darker, far more muscle, bigger horns, a sceptre in his right hand
DRESS.Demon = function(m)
	recolor(m, { { rgb(176, 34, 26), rgb(128, 18, 14) }, { rgb(204, 58, 42), rgb(176, 30, 20) }, { rgb(128, 22, 18), rgb(84, 10, 10) } })
	grow(m, { "Bicep", "ShoulderCap", "Forearm", "Thigh", "Shin" }, 1.45, 1.05, 1.45)
	grow(m, { "Pec", "Ab", "Traps" }, 1.15, 1.1, 1.7)
	grow(m, { "Horn1", "Horn2", "Horn3", "Horn4" }, 1.35, 1.35, 1.35)
	paint(m, { "Eye" }, rgb(255, 210, 60), Enum.Material.Neon)
	local hand = body(m, "RightHand")
	if hand then
		local GOLD, DARK = rgb(196, 150, 50), rgb(26, 16, 14)
		local staff = add(hand, "Sceptre", Vector3.new(0.6, 11.5, 0.6), CFrame.new(0, 1.6, -0.6), rgb(84, 54, 30), Enum.Material.Wood)
		add(staff, "SceptreBand", Vector3.new(0.7, 0.35, 0.7), CFrame.new(0, 4.6, 0), GOLD, Enum.Material.Metal)
		add(staff, "SceptreBand", Vector3.new(0.7, 0.35, 0.7), CFrame.new(0, -1.6, 0), GOLD, Enum.Material.Metal)
		add(staff, "SceptreFoot", Vector3.new(0.6, 0.6, 0.6), CFrame.new(0, -5.8, 0) * CFrame.Angles(0, 0, math.pi / 4), GOLD, Enum.Material.Metal)
		for i = 0, 3 do -- four claws holding the orb
			local a = i * math.pi / 2
			add(staff, "SceptreClaw", Vector3.new(0.25, 1.7, 0.25), CFrame.new(math.cos(a) * 0.55, 6.3, math.sin(a) * 0.55) * CFrame.Angles(math.sin(a) * 0.35, 0, -math.cos(a) * 0.35), GOLD, Enum.Material.Metal)
		end
		local orb = add(staff, "SceptreOrb", Vector3.new(1.6, 1.6, 1.6), CFrame.new(0, 6.6, 0), rgb(255, 60, 30), Enum.Material.Neon, Enum.PartType.Ball)
		glow(orb, rgb(255, 70, 30), 18, 2)
	end
end

-- the Plague King: sick green fur, yellow eyes, boils, a rusty crown
DRESS.Rat = function(m)
	recolor(m, { { rgb(98, 84, 72), rgb(74, 104, 52) }, { rgb(62, 54, 48), rgb(44, 66, 36) }, { rgb(124, 108, 92), rgb(104, 136, 64) },
		{ rgb(150, 132, 112), rgb(150, 160, 96) }, { rgb(255, 44, 30), rgb(220, 255, 60), Enum.Material.Neon } })
	local head = body(m, "Head")
	if head then
		local RUST = rgb(150, 96, 40)
		add(head, "Crown", Vector3.new(1.7, 0.4, 1.7), CFrame.new(0, 1.2, 0.1), RUST, Enum.Material.Metal)
		for i = 0, 3 do
			local a = i * math.pi / 2 + math.pi / 4
			add(head, "CrownSpike", Vector3.new(0.35, 0.8, 0.35), CFrame.new(math.cos(a) * 0.75, 1.75, 0.1 + math.sin(a) * 0.75), RUST, Enum.Material.Metal)
		end
	end
	local torso = body(m, "UpperTorso")
	if torso then
		for _, o in { Vector3.new(-1.2, 0.6, -1.5), Vector3.new(0.9, -0.5, -1.55), Vector3.new(1.5, 0.9, 0.4), Vector3.new(-1.7, -0.2, 0.5) } do
			add(torso, "Boil", Vector3.new(0.7, 0.7, 0.7), CFrame.new(o), rgb(190, 220, 80), Enum.Material.Neon, Enum.PartType.Ball)
		end
		glow(torso, rgb(150, 230, 70), 16, 1.1)
	end
	tint(m, rgb(170, 240, 80))
end

-- the Goblin King: fat, forest green, a little crown
DRESS.Goblin = function(m)
	recolor(m, {
		{ rgb(104, 178, 58), rgb(34, 92, 44) }, { rgb(78, 140, 42), rgb(22, 66, 32) }, { rgb(132, 204, 78), rgb(54, 122, 62) },
		{ rgb(96, 166, 52), rgb(30, 84, 40) }, { rgb(40, 70, 25), rgb(14, 40, 20) },
	})
	grow(m, { "UpperTorso", "LowerTorso", "Chest" }, 1.4, 1, 1.5)
	grow(m, { "Belly" }, 1.7, 1.25, 2.0)
	grow(m, { "Belt", "Cheek", "Jaw" }, 1.4, 1.1, 1.4)
	grow(m, { "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg", "Shoulder" }, 1.3, 1, 1.3)
	local head = body(m, "Head")
	if head then
		local GOLD = rgb(250, 196, 52)
		local top = head.Size.Y / 2
		local r = math.min(head.Size.X, head.Size.Z) * 0.42
		add(head, "CrownBand", Vector3.new(r * 2.1, 0.35, r * 2.1), CFrame.new(0, top + 0.5, 0), GOLD, Enum.Material.Metal)
		for i = 0, 5 do
			local a = i * math.pi / 3
			add(head, "CrownSpike", Vector3.new(0.35, 0.9, 0.35), CFrame.new(math.cos(a) * r, top + 1.05, math.sin(a) * r), GOLD, Enum.Material.Metal)
		end
		add(head, "CrownGem", Vector3.new(0.4, 0.4, 0.2), CFrame.new(0, top + 0.5, -r - 0.08), rgb(220, 30, 40), Enum.Material.Neon)
	end
end

-- the Burning Captain: red-hot bones, glowing ribs and blade, on fire
DRESS.Pirate = function(m)
	recolor(m, {
		{ rgb(226, 214, 186), rgb(196, 48, 26) }, { rgb(184, 168, 136), rgb(130, 26, 16) }, { rgb(240, 234, 214), rgb(255, 190, 120) },
		{ rgb(40, 112, 180), rgb(24, 20, 20) }, { rgb(30, 86, 144), rgb(60, 14, 10) }, { rgb(96, 84, 70), rgb(40, 26, 22) },
	})
	paint(m, { "Rib", "Sternum", "Spine" }, rgb(255, 110, 30), Enum.Material.Neon)
	paint(m, { "Eye" }, rgb(255, 220, 80), Enum.Material.Neon)
	paint(m, { "Blade", "Edge", "Tip" }, rgb(255, 140, 40), Enum.Material.Neon)
	tint(m, rgb(255, 120, 40))
	local torso, head = body(m, "UpperTorso"), body(m, "Head")
	if torso then
		Fire.flames(torso, 1.2)
		glow(torso, rgb(255, 110, 40), 20, 1.6)
	end
	if head then Fire.flames(head, 0.6) end
	for _, b in named(m, { "Tip" }) do Fire.flames(b, 0.4) end
end

-- the Golden Bear: gold suit, black top hat, empty black eyes with white pinpoints
DRESS.Animatronic = function(m)
	recolor(m, {
		{ rgb(128, 76, 36), rgb(210, 166, 44) }, { rgb(96, 56, 26), rgb(160, 120, 28) }, { rgb(186, 128, 70), rgb(244, 216, 124) },
		{ rgb(104, 66, 40), rgb(150, 112, 30) }, { rgb(160, 28, 34), rgb(16, 14, 18) }, { rgb(226, 182, 48), rgb(90, 30, 130) },
	})
	paint(m, { "Eye", "Shine" }, rgb(6, 6, 8))
	paint(m, { "Iris" }, rgb(255, 255, 255), Enum.Material.Neon)
	paint(m, { "Pupil" }, rgb(255, 255, 255), Enum.Material.Neon)
	grow(m, { "Iris" }, 0.45, 0.45, 1)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and (close(d.Color, rgb(210, 166, 44)) or close(d.Color, rgb(244, 216, 124))) then d.Reflectance = 0.12 end
	end
	tint(m, rgb(255, 220, 110))
end

-- the Bone Giant: skull face, bare forearms, shins, hands and feet, an open rib cage and spine, pelvis showing
DRESS.Titan = function(m)
	local DARK, FLESH = rgb(44, 12, 10), rgb(128, 34, 26)
	recolor(m, { { rgb(190, 78, 60), FLESH }, { rgb(158, 52, 40), rgb(104, 28, 22) }, { rgb(112, 32, 26), rgb(74, 20, 16) } })
	-- skull
	paint(m, { "Head", "HeadRound", "Skull", "SkullRound", "Chin", "ChinRound", "BrowRidge", "Gums" }, BONE)
	paint(m, { "Cheek" }, DARK)
	-- forearms, hands, shins, feet: bone, thinner; the muscle over them is gone
	paint(m, { "Forearm", "ForearmRound", "Calf", "CalfRound" }, DARK, nil, 1)
	local limbs = { "LeftLowerArm", "LeftLowerArmRound", "RightLowerArm", "RightLowerArmRound", "LeftLowerLeg", "LeftLowerLegRound", "RightLowerLeg", "RightLowerLegRound" }
	paint(m, limbs, BONE)
	grow(m, limbs, 0.6, 1, 0.6)
	paint(m, { "LeftHand", "LeftHandRound", "RightHand", "RightHandRound", "Finger", "Thumb", "LeftFoot", "LeftFootRound", "RightFoot", "RightFootRound", "Toe" }, BONE)
	-- hips and belly: the pelvis shows, the belly is an empty cavity behind the ribs
	paint(m, { "Hips", "HipsRound" }, BONE)
	paint(m, { "Ab", "AbRound", "Oblique", "Linea" }, DARK, nil, 1)
	paint(m, { "LowerTorso", "LowerTorsoRound" }, DARK)
	grow(m, { "LowerTorso", "LowerTorsoRound" }, 0.6, 1, 0.6)
	local ut, lt = body(m, "UpperTorso"), body(m, "LowerTorso")
	if ut then
		local w, h, d = ut.Size.X, ut.Size.Y, ut.Size.Z
		-- rib cage: bars across the front, down each side, and a sternum
		for i = 0, 4 do
			local y = h * 0.28 - i * h * 0.2
			local rw = w * (1.04 - i * 0.05)
			add(ut, "EvoRib", Vector3.new(rw, 0.3, 0.32), CFrame.new(0, y, -d / 2 - 0.22) * CFrame.Angles(0, 0, 0), BONE)
			for _, sx in { -1, 1 } do
				add(ut, "EvoRib", Vector3.new(0.32, 0.3, d * 1.05), CFrame.new(sx * rw / 2, y - 0.1, -0.05) * CFrame.Angles(0.12, 0, 0), BONE)
			end
		end
		add(ut, "EvoSternum", Vector3.new(0.6, h * 0.95, 0.36), CFrame.new(0, -h * 0.08, -d / 2 - 0.34), BONE)
		-- spine down the back, into the hips
		for i = 0, 7 do
			add(ut, "EvoVertebra", Vector3.new(0.75, 0.5, 0.7), CFrame.new(0, h * 0.45 - i * h * 0.24, d / 2 + 0.2), BONE)
		end
		for _, sx in { -1, 1 } do -- shoulder blades
			add(ut, "EvoBlade", Vector3.new(w * 0.3, h * 0.42, 0.3), CFrame.new(sx * w * 0.24, h * 0.18, d / 2 + 0.18) * CFrame.Angles(0, 0, sx * 0.25), BONE)
		end
	end
	if lt then
		add(lt, "EvoSpine", Vector3.new(0.7, lt.Size.Y * 1.15, 0.7), CFrame.new(0, 0, 0), BONE)
	end
	-- a bone showing through each upper arm and thigh
	for _, n in { "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg" } do
		local p = body(m, n)
		if p then
			local sx = string.find(n, "Left") and -1 or 1
			add(p, "EvoBone", Vector3.new(0.45, p.Size.Y * 0.9, 0.45), CFrame.new(sx * (p.Size.X / 2 + 0.05), 0, -p.Size.Z * 0.2), BONE)
		end
	end
end

-- the Last Call: the same robe and mask, soaked in blood, the knife red, and a pump shotgun in his left hand
-- (carried muzzle down along the arm, so it points where the arm points when he aims)
DRESS.Caller = function(m)
	local BLOOD, BLOOD_D = rgb(140, 8, 12), rgb(84, 4, 8)
	local function splat(on: BasePart?, n: number, seed: number)
		if not on then return end
		local r = Random.new(seed)
		local sx, sy, sz = on.Size.X, on.Size.Y, on.Size.Z
		for i = 1, n do
			local front = r:NextNumber() < 0.7 and -1 or 1
			local w, h = r:NextNumber(0.25, 0.7) * math.min(sx, 1.6), r:NextNumber(0.2, 0.75) * math.min(sy, 1.6)
			add(on, "EvoBlood", Vector3.new(w, h, 0.08), CFrame.new(r:NextNumber(-0.4, 0.4) * sx, r:NextNumber(-0.42, 0.42) * sy, front * (sz / 2 + 0.07)) * CFrame.Angles(0, 0, r:NextNumber(-0.6, 0.6)),
				i % 3 == 0 and BLOOD_D or BLOOD)
			if r:NextNumber() < 0.6 then -- a drip running down from it
				add(on, "EvoBlood", Vector3.new(0.1, h * 1.4, 0.07), CFrame.new(r:NextNumber(-0.4, 0.4) * sx, r:NextNumber(-0.42, 0.1) * sy, front * (sz / 2 + 0.06)), BLOOD)
			end
		end
	end
	splat(body(m, "UpperTorso"), 7, 11)
	splat(body(m, "LowerTorso"), 3, 12)
	splat(body(m, "LeftUpperLeg"), 3, 13); splat(body(m, "RightUpperLeg"), 3, 14)
	splat(body(m, "LeftLowerLeg"), 2, 15); splat(body(m, "RightLowerLeg"), 2, 16)
	splat(body(m, "LeftLowerArm"), 2, 17); splat(body(m, "RightLowerArm"), 3, 18)
	-- the mask: a red hand's smear across it, red running from the eyes
	for _, mask in named(m, { "Mask" }) do
		local w, h, d = mask.Size.X, mask.Size.Y, mask.Size.Z
		add(mask, "EvoBlood", Vector3.new(w * 0.75, h * 0.2, 0.05), CFrame.new(w * 0.05, h * 0.3, -d / 2 - 0.03) * CFrame.Angles(0, 0, 0.35), BLOOD)
		add(mask, "EvoBlood", Vector3.new(w * 0.3, h * 0.28, 0.05), CFrame.new(-w * 0.28, -h * 0.3, -d / 2 - 0.03) * CFrame.Angles(0, 0, -0.3), BLOOD_D)
		for _, sx in { -1, 1 } do
			add(mask, "EvoBlood", Vector3.new(0.07, h * 0.42, 0.05), CFrame.new(sx * w * 0.24, -h * 0.08, -d / 2 - 0.035), BLOOD)
		end
	end
	paint(m, { "KnifeBlade" }, rgb(150, 20, 24), Enum.Material.Metal)
	paint(m, { "MaskEye", "MaskMouth" }, rgb(40, 0, 0))
	local hand = body(m, "LeftHand")
	if hand then
		local STEEL, WOOD = rgb(34, 34, 38), rgb(92, 54, 30)
		local gun = add(hand, "Shotgun", Vector3.new(0.5, 2.4, 0.5), CFrame.new(0, -1.0, -0.25), STEEL, Enum.Material.Metal) -- receiver
		add(gun, "ShotgunBarrel", Vector3.new(0.3, 3.4, 0.3), CFrame.new(0, -2.8, -0.06), STEEL, Enum.Material.Metal)
		add(gun, "ShotgunTube", Vector3.new(0.26, 2.9, 0.26), CFrame.new(0, -2.55, 0.26), STEEL, Enum.Material.Metal)
		add(gun, "ShotgunPump", Vector3.new(0.48, 1.3, 0.5), CFrame.new(0, -2.2, 0.24), WOOD, Enum.Material.Wood)
		add(gun, "ShotgunStock", Vector3.new(0.45, 2.1, 0.75), CFrame.new(0, 2.0, 0.18) * CFrame.Angles(0.12, 0, 0), WOOD, Enum.Material.Wood)
		add(gun, "ShotgunMuzzle", Vector3.new(0.36, 0.2, 0.36), CFrame.new(0, -4.5, -0.06), rgb(12, 12, 14), Enum.Material.Metal)
	end
end

-- the Golden Conqueror: his war armour. Gold plate over the chest, shoulders, arms and legs, a crested helmet
-- that leaves the face open, a double-ended war blade in his left fist, and the gauntlet's stone burning bright.
DRESS.Conqueror = function(m)
	local GOLD, GOLD_D, DARK = rgb(190, 140, 40), rgb(118, 84, 26), rgb(30, 24, 30)
	local METAL = Enum.Material.Metal
	paint(m, { "UpperTorso", "UpperTorsoRound", "ChestPlate", "ChestPlateRound" }, GOLD, METAL)
	paint(m, { "LowerTorso", "LowerTorsoRound", "LeftUpperLeg", "LeftUpperLegRound", "RightUpperLeg", "RightUpperLegRound" }, DARK)
	paint(m, { "LeftLowerLeg", "LeftLowerLegRound", "RightLowerLeg", "RightLowerLegRound", "LeftFoot", "LeftFootRound", "RightFoot", "RightFootRound", "Bracer", "BracerRound" }, GOLD, METAL)
	paint(m, { "Trim", "ChestBand", "Belt", "BeltRound", "BootCuff", "BootToe", "ShoulderStrap" }, GOLD_D, METAL)
	paint(m, { "Stitch" }, GOLD_D, METAL)
	paint(m, { "Eye" }, rgb(200, 150, 255), Enum.Material.Neon)
	local ut, head = body(m, "UpperTorso"), body(m, "Head")
	if ut then
		local w, h, d = ut.Size.X, ut.Size.Y, ut.Size.Z
		for i = 0, 2 do -- layered chest plates, a point down the middle
			for _, sx in { -1, 1 } do
				add(ut, "EvoPlate", Vector3.new(w * 0.52, h * 0.24, 0.3), CFrame.new(sx * w * 0.24, h * 0.3 - i * h * 0.26, -d / 2 - 0.2 - (2 - i) * 0.08) * CFrame.Angles(0, 0, sx * -0.3), i == 1 and GOLD_D or GOLD, METAL)
			end
		end
		add(ut, "EvoSpineGuard", Vector3.new(w * 0.3, h * 0.9, 0.35), CFrame.new(0, 0, d / 2 + 0.2), GOLD_D, METAL)
	end
	for _, n in { "LeftUpperArm", "RightUpperArm" } do -- big layered pauldrons
		local p = body(m, n)
		if p then
			local sx = string.find(n, "Left") and -1 or 1
			add(p, "EvoPauldron", Vector3.new(p.Size.X * 1.55, 0.75, p.Size.Z * 1.6), CFrame.new(sx * 0.15, p.Size.Y / 2 + 0.2, 0) * CFrame.Angles(0, 0, sx * -0.22), GOLD, METAL)
			add(p, "EvoPauldron", Vector3.new(p.Size.X * 1.35, 0.6, p.Size.Z * 1.45), CFrame.new(sx * 0.4, p.Size.Y / 2 - 0.35, 0) * CFrame.Angles(0, 0, sx * -0.4), GOLD_D, METAL)
			add(p, "EvoArmBand", Vector3.new(p.Size.X * 1.12, 0.5, p.Size.Z * 1.12), CFrame.new(0, -p.Size.Y * 0.25, 0), GOLD, METAL)
		end
	end
	for _, n in { "LeftUpperLeg", "RightUpperLeg" } do -- thigh plates
		local p = body(m, n)
		if p then add(p, "EvoThigh", Vector3.new(p.Size.X * 1.1, p.Size.Y * 0.7, 0.3), CFrame.new(0, 0.1, -p.Size.Z / 2 - 0.1), GOLD, METAL) end
	end
	for _, n in { "LeftLowerLeg", "RightLowerLeg" } do -- knee caps
		local p = body(m, n)
		if p then add(p, "EvoKnee", Vector3.new(p.Size.X * 1.15, 0.7, 0.5), CFrame.new(0, p.Size.Y / 2 - 0.1, -p.Size.Z / 2 - 0.15), GOLD_D, METAL) end
	end
	if head then
		-- the helmet sits ON the skull: its rim is above the brow ridge, the eyes and the face stay open.
		-- (the Head part is the inner block of the rounded head: its real height and depth are 1 / 0.8 of it)
		local w, h, d = head.Size.X, head.Size.Y / 0.8, head.Size.Z / 0.8
		add(head, "EvoHelm", Vector3.new(w * 1.16, h * 0.36, d * 1.14), CFrame.new(0, h * 0.5, 0.05), GOLD, METAL)
		add(head, "EvoHelmBrow", Vector3.new(w * 1.2, 0.26, 0.4), CFrame.new(0, h * 0.37, -d / 2 - 0.17), GOLD_D, METAL)
		add(head, "EvoHelmBack", Vector3.new(w * 1.1, h * 0.7, 0.4), CFrame.new(0, h * 0.05, d / 2 + 0.1), GOLD, METAL)
		for _, sx in { -1, 1 } do
			add(head, "EvoCheekGuard", Vector3.new(0.35, h * 0.6, d * 0.5), CFrame.new(sx * (w / 2 + 0.12), -h * 0.08, d * 0.14), GOLD, METAL)
			add(head, "EvoFin", Vector3.new(0.25, h * 0.5, d * 0.45), CFrame.new(sx * w * 0.42, h * 0.8, 0.15) * CFrame.Angles(-0.25, 0, sx * -0.28), GOLD_D, METAL)
		end
		add(head, "EvoCrest", Vector3.new(0.4, h * 0.3, d * 1.0), CFrame.new(0, h * 0.74, 0.1), GOLD_D, METAL)
	end
	-- his war blade, in the left fist: a long grip with a heavy cleaver blade at each end (the gauntlet hand stays free)
	local fist = body(m, "LeftHand")
	if fist then
		local STEEL, EDGE = rgb(58, 54, 60), rgb(150, 146, 150)
		-- along the fist's front-back axis, the front end dipped a little
		local grip = add(fist, "SwordGrip", Vector3.new(0.5, 0.5, 3.4), CFrame.new(0, -0.35, -0.1) * CFrame.Angles(-0.32, 0, 0), rgb(40, 28, 22))
		add(grip, "SwordWrap", Vector3.new(0.58, 0.58, 1.3), CFrame.new(0, 0, 0), GOLD_D, METAL)
		for _, sz in { -1, 1 } do
			-- one blade per end; the back one is turned over, so the two edges face opposite ways
			local flip = sz > 0 and CFrame.Angles(0, 0, math.pi) or CFrame.new()
			add(grip, "SwordGuard", Vector3.new(0.7, 1.9, 0.5), CFrame.new(0, 0, sz * 1.85), GOLD, METAL)
			local blade = add(grip, "SwordBlade", Vector3.new(0.22, 1.7, 5.6), CFrame.new(0, 0, sz * 4.85) * flip * CFrame.new(0, 0.25, 0), STEEL, METAL)
			add(blade, "SwordEdge", Vector3.new(0.1, 0.3, 5.6), CFrame.new(0, 0.95, 0), EDGE, METAL)
			add(blade, "SwordSpine", Vector3.new(0.34, 0.4, 5.2), CFrame.new(0, -0.7, sz * -0.2), GOLD_D, METAL)
			add(blade, "SwordTip", Vector3.new(0.2, 1.2, 1.2), CFrame.new(0, 0.2, sz * 2.9) * CFrame.Angles(math.pi / 4, 0, 0), STEEL, METAL)
			for i = 0, 2 do -- notches along the back of the blade
				add(blade, "SwordNotch", Vector3.new(0.26, 0.35, 0.5), CFrame.new(0, -0.95, sz * (-1.6 + i * 1.5)), STEEL, METAL)
			end
		end
	end
	for _, g in named(m, { "Gem" }) do
		g.Size *= 1.35
		for _, l in g:GetChildren() do if l:IsA("PointLight") then l.Range = 15; l.Brightness = 1.8 end end
	end
end

-- THE HOLLOW EMPEROR (the Void Knight): everything that glowed red (the blade, the visor, the core) burns violet
DRESS.Knight = function(m: Model)
	local V = Color3.fromRGB(190, 90, 255)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and d.Material == Enum.Material.Neon then d.Color = V end
		if d:IsA("PointLight") then d.Color = V; d.Brightness *= 1.3 end
	end
end

function Evolved.dress(m: Model, def: any)
	local f = DRESS[def.id]
	if f then
		local ok, err = pcall(f, m)
		if not ok then warn("[Evolved] dress " .. tostring(def.id) .. ": " .. tostring(err)) end
	end
end

-- powers ---------------------------------------------------------------------
local function hrpOf(p: Player?): BasePart?
	local ch = p and p.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	return ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
end
local function flat(v: Vector3): Vector3
	local f = Vector3.new(v.X, 0, v.Z)
	return f.Magnitude > 0.01 and f.Unit or Vector3.new(0, 0, -1)
end
local function cd(g, P): number return (P.cd or 10) * g.cdMult * rng:NextNumber(0.9, 1.15) end
local function toastAll(msg: string)
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("InMatch") then Remotes.Fx:FireClient(p, "Toast", msg) end
	end
end
local function begin(g, G, kind: string, dur: number, data: { [string]: any }?)
	local e = data or {}
	e.kind = kind
	g.evo = e
	G.setState(g, "Evo", dur)
	g.model:SetAttribute("EvoPower", kind)
end
local function done(g, G, P, recover: number?)
	g.evo = nil
	g.model:SetAttribute("EvoPower", "")
	g.nextPower = os.clock() + cd(g, P)
	g.nextAttack = math.max(g.nextAttack, os.clock() + 0.6)
	G.setState(g, "Recover", recover or 0.4)
end
-- a point kept inside the house
local function inHouse(G, p: Vector3): Vector3
	local B = G.houseBounds()
	return Vector3.new(math.clamp(p.X, B.min.X + 4, B.max.X - 4), p.Y, math.clamp(p.Z, B.min.Z + 4, B.max.Z - 4))
end

function Evolved.onSpawn(g, G)
	g.evo = nil
	g.nextPower = os.clock() + 6
	local P = g.def.power
	if P and P.kind == "armed" then
		task.delay(2.4, function()
			if G.current == g and g.state ~= "Dead" then Abilities.armGoblin(g, P.weapons[rng:NextInteger(1, #P.weapons)]) end
		end)
	end
end

-- the power was cut short: let go of what it held
function Evolved.interrupt(g)
	local e = g.evo
	g.evo = nil
	if g.model then
		g.model:SetAttribute("EvoPower", "")
		if e and e.kind == "doubles" then g.model:SetAttribute("Vanish", false) end
	end
	if e and e.obj then Abilities.ungrip(e.obj) end
	if e and e.kind == "laser" then Remotes.Fx:FireAllClients("LaserEnd") end -- knocked back: the beam cuts out
	g.nextPower = os.clock() + 4
end

function Evolved.chase(g, G, now: number, target: Player?, thrp: BasePart?, dist: number): boolean
	local P = g.def.power
	if not P or not target or not thrp or now < (g.nextPower or 0) or now < g.slowUntil then return false end
	local k = P.kind
	if k == "armed" then
		-- lost his weapon: after a while he pulls another one out of the sack
		if not g.loot then Abilities.armGoblin(g, P.weapons[rng:NextInteger(1, #P.weapons)]) end
		g.nextPower = now + 16
		return false
	elseif k == "doubles" then
		if dist > 70 or Abilities.cloneCount() > 0 or target:GetAttribute("Warded") then return false end
		g.model:SetAttribute("Vanish", true)
		Remotes.Fx:FireAllClients("GhostVanish", g.hrp.Position)
		begin(g, G, k, 0.8)
		return true
	elseif k == "army" then
		if dist > 80 or Abilities.cloneCount() > 0 then return false end
		begin(g, G, k, 0.8)
		Remotes.Fx:FireAllClients("AbilityWind", g.hrp.Position, "army")
		toastAll("THE CAPTAIN THROWS HIS CREW AT YOU - PUNCH THEM APART!")
		return true
	elseif k == "shotgun" then
		if dist < P.min or dist > P.range or target:GetAttribute("Warded") or Fury.inGrace(target) then return false end
		-- he only brings it up when he can see his victim (they then have the wind-up to get behind something)
		local eye = g.hrp.Position + Vector3.new(0, 1.2, 0)
		if workspace:Raycast(eye, thrp.Position - eye, g.rp) then return false end
		begin(g, G, k, P.wind, { victim = target, shots = 0 })
		Remotes.Fx:FireAllClients("ShotgunAim", g.model, P.wind)
		toastAll("HE'S RAISING A SHOTGUN - TAKE COVER! (IT BLOWS THROUGH WALLS)")
		return true
	elseif k == "laser" then
		if dist < 9 or dist > P.range * 0.7 or target:GetAttribute("Warded") then return false end
		begin(g, G, k, P.wind, { phase = "charge" })
		Remotes.Fx:FireAllClients("LaserWind", g.model, P.wind)
		toastAll("THE GAUNTLET IS CHARGING - STAY OUT OF THE BEAM!")
		return true
	elseif k == "snap" then
		if dist < P.min or dist > P.max or target:GetAttribute("Warded") or Fury.inGrace(target) then return false end
		begin(g, G, k, P.wind * (g.enraged and 0.85 or 1), { victim = target })
		Remotes.Fx:FireAllClients("SnapWind", g.model, P.wind)
		return true
	elseif k == "eat" then
		if g.hp > g.maxHp * P.below then return false end
		local list = Furniture.nearest(g.hrp.Position, P.range, 1)
		if #list > 0 then
			local obj = list[1]
			Abilities.grip(obj, Color3.fromRGB(120, 255, 120))
			begin(g, G, k, P.t, { obj = obj, from = obj:GetPivot(), t0 = now })
			Remotes.Fx:FireAllClients("TitanEat", g.model, "furniture")
			return true
		end
		-- nothing to eat near him: a bite out of the closest inside wall
		for i = 0, 7 do
			local a = i * math.pi / 4
			local dir = Vector3.new(math.cos(a), 0, math.sin(a))
			local r = workspace:Raycast(g.hrp.Position + Vector3.new(0, 2, 0), dir * 13, g.rp)
			if r and r.Normal.Y < 0.6 then
				begin(g, G, k, P.t * 0.8, { wall = r.Position, dir = dir })
				Remotes.Fx:FireAllClients("TitanEat", g.model, "wall")
				return true
			end
		end
		g.nextPower = now + 3
		return false
	end
	return false
end

function Evolved.step(g, G, dt: number, now: number, target: Player?, thrp: BasePart?, hoverY: number)
	local e, P = g.evo, g.def.power
	if not e or not P then G.setState(g, "Chase"); return end
	local pos = g.hrp.Position
	local hoverV = Vector3.new(0, (hoverY - pos.Y) * 4, 0)
	local function face(tp: Vector3)
		local f = Vector3.new(tp.X, pos.Y, tp.Z)
		if (f - pos).Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(pos, f).Rotation end
	end
	g.lv.VectorVelocity = hoverV
	local k = e.kind
	if k == "doubles" then
		-- gone for a moment, then she and her doubles stand in a ring around you: which one is real?
		if now < g.stateUntil then return end
		g.model:SetAttribute("Vanish", false)
		if thrp then
			-- she and her doubles stand side by side IN FRONT of you, a good way off (P.ring), so you see at once
			-- that there are several of her. A direction with a wall close by is skipped for the next free one.
			local c = thrp.Position
			local n = P.n + 1
			local real = rng:NextInteger(1, n)
			-- measured from standing chest height, whatever the player is doing (knocked down, jumping)
			local floor = workspace:Raycast(c, Vector3.new(0, -14, 0), g.rp)
			if floor then c = Vector3.new(c.X, floor.Position.Y + 3, c.Z) end
			local y = c.Y - 3 + g.hover
			local lookV = thrp.CFrame.LookVector
			if math.abs(lookV.Y) > 0.9 then lookV = g.hrp.Position - c end -- flat on the floor: where she was instead
			local base = math.atan2(lookV.Z, lookV.X)
			local gap = math.rad(P.spread or 26) -- between two of them, seen from the player
			local minR = P.ring * 0.55
			local spots = {} :: { { a: number, r: number } }
			local function room(a: number): number
				local hit = workspace:Raycast(c + Vector3.new(0, 1.5, 0), Vector3.new(math.cos(a), 0, math.sin(a)) * (P.ring + 2), g.rp)
				return hit and hit.Distance - 2 or P.ring
			end
			local function take(off: number)
				if #spots >= n then return end
				for _, sp in spots do
					local d = math.abs((base + off - sp.a + math.pi) % (math.pi * 2) - math.pi)
					if d < gap * 0.95 then return end
				end
				local r = room(base + off)
				if r >= minR then table.insert(spots, { a = base + off, r = r }) end
			end
			-- straight ahead first, then wider and wider on both sides (an even number: nobody dead centre)
			local first = n % 2 == 0 and gap / 2 or 0
			local k = 0
			while #spots < n and first + k * gap / 2 <= math.pi do
				local off = first + k * gap / 2
				take(off)
				if off > 0 then take(-off) end
				k += 1
			end
			-- hemmed in by walls: the rest stand in a ring around you, as before
			local a0 = rng:NextNumber(0, math.pi * 2)
			for i = #spots + 1, n do table.insert(spots, { a = a0 + i / n * math.pi * 2, r = P.ring * 0.65 }) end
			-- which one is real must not depend on where she stands
			for i = #spots, 2, -1 do
				local j = rng:NextInteger(1, i)
				spots[i], spots[j] = spots[j], spots[i]
			end
			local pts = {}
			for i, sp in spots do
				local at = inHouse(G, Vector3.new(c.X + math.cos(sp.a) * sp.r, y, c.Z + math.sin(sp.a) * sp.r))
				if i == real then
					g.model:PivotTo(CFrame.lookAt(at, Vector3.new(c.X, at.Y, c.Z)))
					g.ao.CFrame = g.model:GetPivot().Rotation
				else
					table.insert(pts, at)
				end
			end
			local speed = (C.Speed + (g.level - 1) * C.SpeedPerLevel) * g.speedMult * g.furySpeed
			-- they all stand there screaming for a moment (so do count them), then come at you together
			Abilities.spawnClones(g, pts, P.t, P.dmg * g.dmgMult, speed, { delay = P.pause or 1 })
			Remotes.Fx:FireAllClients("GhostScream", g.hrp.Position)
			toastAll("ONLY ONE OF THEM IS REAL")
		end
		done(g, G, P, P.pause or 1)
	elseif k == "army" then
		if thrp then face(thrp.Position) end
		if now < g.stateUntil then return end
		-- his crew jumps out of him one after the other, right where he stands, and runs at the players
		local feetY = pos.Y - g.hover
		for i = 1, P.n do
			task.delay((i - 1) * 0.16, function()
				if G.current ~= g or g.state == "Dead" or not g.model.Parent then return end
				if g.state == "Ragdoll" or g.state == "Launched" then return end -- knocked flying meanwhile: the rest stay in
				local here = g.hrp.Position
				local a = rng:NextNumber(0, math.pi * 2)
				local dir = Vector3.new(math.cos(a), 0, math.sin(a))
				local r = rng:NextNumber(2.2, 4)
				local wall = workspace:Raycast(here, dir * (r + 1.5), g.rp)
				if wall then r = math.max(0.5, wall.Distance - 1.5) end
				local at = Vector3.new(here.X + dir.X * r, feetY + g.hover * P.size, here.Z + dir.Z * r)
				Abilities.spawnClones(g, { at }, P.t, P.dmg * g.dmgMult, P.speed * rng:NextNumber(0.9, 1.12), { scale = P.size, crew = true })
			end)
		end
		done(g, G, P, 0.5)
	elseif k == "shotgun" then
		-- THE LAST CALL'S 12 GAUGE: he aims at his victim for P.wind, fires, pumps for P.gap and fires again.
		-- Something solid between you and the muzzle takes the shot, and pays for it: furniture is blown apart and
		-- an inside wall gets a hole blasted through it, so the same cover never saves you twice (only the outside
		-- walls, the floors and the stairs hold). In the open, everyone in the narrow blast cone is hit, harder from close.
		local victim = e.victim :: Player
		local vh = hrpOf(victim) or thrp
		if vh then face(vh.Position) end
		if now < g.stateUntil then return end
		e.shots += 1
		local from = pos + flat(g.hrp.CFrame.LookVector) * 2.5 + Vector3.new(0, 1.2, 0)
		if vh then
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Include
			local list = table.clone(g.rp.FilterDescendantsInstances)
			local fur = Furniture.folder()
			if fur then table.insert(list, fur) end
			rp.FilterDescendantsInstances = list
			local to = vh.Position - from
			local r = workspace:Raycast(from, to, rp)
			local covered = r ~= nil and r.Distance < to.Magnitude - 2
			local endPt = (covered and r) and r.Position or (from + to.Unit * math.min(P.range, to.Magnitude + 6))
			if covered and r then
				if fur and r.Instance:IsDescendantOf(fur) then
					local m: Instance? = r.Instance
					while m and m.Parent ~= fur do m = m.Parent end
					if m and m:IsA("Model") then Furniture.smash(m, to.Unit * 80 + Vector3.new(0, 25, 0), 120) end
				elseif Ragdoll.breakWalls(r.Position + to.Unit * 0.6, to.Unit * 70, 7, 5) > 0 then
					Remotes.Fx:FireAllClients("WallSmash", r.Position, 110)
				end
			else
				for _, p in Players:GetPlayers() do
					local hrp = p:GetAttribute("InMatch") and hrpOf(p)
					if hrp and not p:GetAttribute("Warded") then
						local tp = hrp.Position - from
						if tp.Magnitude <= P.range and to.Unit:Dot(tp.Unit) > 0.965 then
							local pr = workspace:Raycast(from, tp, rp)
							if not pr or pr.Distance >= tp.Magnitude - 2 then
								local near = math.clamp(1.25 - tp.Magnitude / P.range, 0.45, 1)
								G.hitPlayer(p, nil, P.dmg * g.dmgMult * near, flat(tp) * P.power + Vector3.new(0, 18, 0), "shotgun", true, 1.2)
							end
						end
					end
				end
			end
			Remotes.Fx:FireAllClients("ShotgunFire", g.model, from, endPt, not covered)
		end
		if e.shots >= P.shots then
			done(g, G, P, 0.8)
		else
			g.stateUntil = now + P.gap
			Remotes.Fx:FireAllClients("ShotgunPump", g.model)
		end
	elseif k == "laser" then
		-- THE GAUNTLET'S BEAM: charged for P.wind, then fired for P.t. It swings after the target slowly (P.turn
		-- degrees a second), cuts the inside walls and the furniture in its way, and burns whoever stands in it.
		if e.phase == "charge" then
			if thrp then face(thrp.Position) end
			if now < g.stateUntil then return end
			e.phase = "fire"
			e.untilT = now + P.t
			e.dir = thrp and flat(thrp.Position - pos) or flat(g.hrp.CFrame.LookVector)
			e.nextTick = 0
			g.stateUntil = now + P.t + 2
		end
		if thrp then
			local want = flat(thrp.Position - pos)
			local ang = math.atan2(e.dir:Cross(want).Y, e.dir:Dot(want))
			-- the sweep is capped in studs a second where the target stands (P.sweep), so far away it turns even more
			-- slowly: walking (17) or sprinting (26) across it always outruns it
			local farD = math.max(8, Vector3.new(thrp.Position.X - pos.X, 0, thrp.Position.Z - pos.Z).Magnitude)
			local lim = math.min(math.rad(P.turn), (P.sweep or 11) / farD) * dt
			e.dir = CFrame.Angles(0, math.clamp(ang, -lim, lim), 0):VectorToWorldSpace(e.dir)
			-- its height follows the target at once (stairs, a knocked-down player): only the sweep is slow
			e.aimY = thrp.Position.Y
			e.aimD = math.max(8, Vector3.new(thrp.Position.X - pos.X, 0, thrp.Position.Z - pos.Z).Magnitude)
		end
		face(pos + e.dir)
		if now >= e.nextTick then
			local tick = 0.1
			e.nextTick = now + tick
			local from = pos + e.dir * 3 + Vector3.new(0, 1.2, 0)
			local dir3 = e.dir
			if e.aimY then dir3 = (e.dir * e.aimD + Vector3.new(0, e.aimY - from.Y, 0)).Unit end
			-- through the house: an inside wall in its way is cut open and it goes on; the first thing that holds
			-- (an outside wall, a floor, the stairs) ends it
			local cur, left = from, P.range
			local endPt = from + dir3 * left
			for _ = 1, 8 do
				local r = workspace:Raycast(cur, dir3 * left, g.rp)
				if not r then endPt = cur + dir3 * left; break end
				if Ragdoll.breakWalls(r.Position + dir3 * 0.6, dir3 * 60, 5, 5) > 0 then
					Remotes.Fx:FireAllClients("WallSmash", r.Position, 90)
					left -= r.Distance + 1.4
					cur = r.Position + dir3 * 1.4
					endPt = cur + dir3 * math.max(0, left)
					if left <= 1 then break end
				else
					endPt = r.Position
					break
				end
			end
			local len = (endPt - from).Magnitude
			for d = 3, len, 6 do
				for _, f in Furniture.near(from + dir3 * d, 3.5) do Furniture.smash(f, dir3 * 70 + Vector3.new(0, 25, 0), 100) end
			end
			-- no block, no knockback, no instant kill: it just burns while you stand in it
			for _, p in Players:GetPlayers() do
				local hrp = p:GetAttribute("InMatch") and hrpOf(p)
				if hrp and not p:GetAttribute("Warded") then
					local along = math.clamp((hrp.Position - from):Dot(dir3), 0, len)
					if (hrp.Position - (from + dir3 * along)).Magnitude <= P.width then
						G.damagePlayer(p, P.dps * g.dmgMult * tick, nil, Vector3.zero)
						Remotes.Fx:FireClient(p, "LaserHit")
					end
				end
			end
			Remotes.Fx:FireAllClients("LaserBeam", g.model, from, endPt)
		end
		if now >= e.untilT then
			Remotes.Fx:FireAllClients("LaserEnd")
			done(g, G, P, 0.9)
		end
	elseif k == "snap" then
		local victim = e.victim :: Player
		local vh = hrpOf(victim)
		if vh then face(vh.Position) end
		if now < g.stateUntil then return end
		-- he needs to see you: behind a wall the snap does nothing
		local head = (g.model:FindFirstChild("Head") or g.hrp) :: BasePart
		local hit = false
		if vh and not victim:GetAttribute("Warded") then
			local to = vh.Position - head.Position
			local r = workspace:Raycast(head.Position, to, g.rp)
			if not r or (r.Position - head.Position).Magnitude > to.Magnitude - 2.5 then
				hit = true
				local dmg = P.dmg * g.dmgMult * (1 + (g.level - 1) * 0.06)
				if rng:NextNumber() < 0.5 then
					-- into the wall behind you (and through the inside ones)
					Remotes.Fx:FireAllClients("Snap", g.model, vh.Position, "wall")
					Fury.launch(g, G, victim, flat(vh.Position - pos) * P.wall + Vector3.new(0, 26, 0), dmg, 1.5, "snap")
				else
					-- straight up into the ceiling
					Remotes.Fx:FireAllClients("Snap", g.model, vh.Position, "up")
					Fury.downed(victim, 1.6)
					G.hitPlayer(victim, nil, dmg, Vector3.new(rng:NextNumber(-6, 6), P.up, rng:NextNumber(-6, 6)), "snap", true, 1.6)
				end
			end
		end
		if not hit then Remotes.Fx:FireAllClients("Snap", g.model, nil, "miss") end
		done(g, G, P, 0.6)
	elseif k == "eat" then
		local head = (g.model:FindFirstChild("Head") or g.hrp) :: BasePart
		if e.obj then
			local obj = e.obj :: Model
			if not obj.Parent or obj:GetAttribute("Broken") then e.obj = nil; done(g, G, P, 0.3); return end
			-- the furniture floats to his mouth
			local mouth = head.Position + g.hrp.CFrame.LookVector * 3.5
			local f = math.clamp((now - e.t0) / (P.t * 0.75), 0, 1)
			obj:PivotTo(CFrame.new(e.from.Position:Lerp(mouth, f * f)) * e.from.Rotation * CFrame.Angles(f * 2, f * 3, 0))
			face(obj:GetPivot().Position)
			if now < g.stateUntil then return end
			Abilities.ungrip(obj)
			e.obj = nil
			Furniture.smash(obj, Vector3.new(0, 30, 0), 70)
			local heal = g.maxHp * P.heal
			g.hp = math.min(g.maxHp, g.hp + heal)
			g.model:SetAttribute("HP", g.hp)
			Remotes.Fx:FireAllClients("TitanHeal", g.model, heal)
			done(g, G, P, 0.5)
		else
			-- walks into the wall and bites a piece out of it
			face(e.wall)
			g.lv.VectorVelocity = e.dir * 6 + hoverV
			if now < g.stateUntil then return end
			if Ragdoll.breakWalls(e.wall + Vector3.new(0, 2, 0), e.dir * 40, 8, 7) > 0 then
				Remotes.Fx:FireAllClients("WallSmash", e.wall, 80)
				local heal = g.maxHp * P.wallHeal
				g.hp = math.min(g.maxHp, g.hp + heal)
				g.model:SetAttribute("HP", g.hp)
				Remotes.Fx:FireAllClients("TitanHeal", g.model, heal)
			end
			done(g, G, P, 0.5)
		end
	else
		done(g, G, P)
	end
end

return Evolved
