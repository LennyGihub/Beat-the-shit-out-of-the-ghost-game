-- Extras on the AI-made monster templates in ServerStorage.Monsters (run after they are rigged + converted):
-- weapons welded to the hand, glows, fire, ghostly transparency, particles. Safe to re-run.
local SS = game:GetService("ServerStorage")
local F = SS:WaitForChild("Monsters")
local out = {}
local function clean(m: Model)
	for _, d in m:GetDescendants() do if d:GetAttribute("Extra") then d:Destroy() end end
end
local function part(m: Model, name: string, size: Vector3, color: Color3, mat: Enum.Material, at: BasePart, offset: CFrame)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color; p.Material = mat
	p.Anchored = false; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.Massless = true
	p.CFrame = at.CFrame * offset
	p:SetAttribute("Extra", true)
	local w = Instance.new("WeldConstraint"); w.Part0 = at; w.Part1 = p; w.Parent = p
	p.Parent = m
	return p
end
local function glow(at: Instance, color: Color3, range: number, bright: number)
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range; l.Brightness = bright; l.Shadows = false
	l:SetAttribute("Extra", true); l.Parent = at
end
local function emitter(at: Instance, props: { [string]: any })
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	for k, v in props do (pe :: any)[k] = v end
	pe:SetAttribute("Extra", true)
	pe.Parent = at
end
local function ghostly(m: Model, t: number)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.Transparency = t end
	end
end
for _, m in F:GetChildren() do
	if not m:IsA("Model") then continue end
	clean(m)
	local hand = m:FindFirstChild("RightHand") :: BasePart?
	local head = m:FindFirstChild("Head") :: BasePart?
	local torso = m:FindFirstChild("UpperTorso") :: BasePart?
	local n = m.Name
	if n == "Butcher" and hand then
		-- a meat cleaver: handle down through the fist, blade pointing forward
		part(m, "CleaverHandle", Vector3.new(0.35, 1.6, 0.35), Color3.fromRGB(60, 40, 28), Enum.Material.Wood, hand, CFrame.new(0, -0.2, -0.3))
		part(m, "CleaverBlade", Vector3.new(0.12, 1.6, 2.6), Color3.fromRGB(170, 170, 175), Enum.Material.Metal, hand, CFrame.new(0, -1.3, -1.2))
		part(m, "CleaverBlood", Vector3.new(0.14, 0.7, 1.2), Color3.fromRGB(90, 8, 8), Enum.Material.SmoothPlastic, hand, CFrame.new(0, -1.7, -1.9))
	elseif n == "HeadlessKnight" and hand then
		part(m, "SwordGrip", Vector3.new(0.35, 1.4, 0.35), Color3.fromRGB(40, 30, 26), Enum.Material.Leather, hand, CFrame.new(0, -0.2, 0))
		part(m, "SwordGuard", Vector3.new(0.3, 0.3, 2.2), Color3.fromRGB(110, 100, 90), Enum.Material.Metal, hand, CFrame.new(0, -0.95, 0))
		part(m, "SwordBlade", Vector3.new(0.15, 6.5, 0.7), Color3.fromRGB(150, 150, 160), Enum.Material.Metal, hand, CFrame.new(0, -4.3, 0))
		if torso then
			emitter(torso, { Color = ColorSequence.new(Color3.fromRGB(120, 0, 0)), Size = NumberSequence.new(0.4, 0.1), Rate = 18, Lifetime = NumberRange.new(0.5, 1),
				Speed = NumberRange.new(2, 5), SpreadAngle = Vector2.new(25, 25), EmissionDirection = Enum.NormalId.Top, Acceleration = Vector3.new(0, -20, 0),
				Texture = "rbxasset://textures/particles/smoke_main.dds" })
		end
		glow(torso or m.PrimaryPart, Color3.fromRGB(170, 190, 255), 14, 0.6)
	elseif n == "HollowKing" and head then
		local f = Instance.new("Fire"); f.Size = 6; f.Heat = 10; f.Color = Color3.fromRGB(255, 100, 20); f.SecondaryColor = Color3.fromRGB(255, 200, 60)
		f:SetAttribute("Extra", true); f.Parent = head
		glow(head, Color3.fromRGB(255, 120, 40), 22, 1.6)
		emitter(torso or head, { Color = ColorSequence.new(Color3.fromRGB(255, 140, 40)), LightEmission = 1, Size = NumberSequence.new(0.25, 0), Rate = 30,
			Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(1, 4), SpreadAngle = Vector2.new(180, 180), Acceleration = Vector3.new(0, 4, 0) })
	elseif n == "Banshee" then
		ghostly(m, 0.25)
		glow(torso or m.PrimaryPart, Color3.fromRGB(160, 220, 235), 16, 1)
		emitter(torso or m.PrimaryPart, { Color = ColorSequence.new(Color3.fromRGB(220, 240, 240)), LightEmission = 1, Size = NumberSequence.new(0.2), Rate = 16,
			Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(0.3, 1), SpreadAngle = Vector2.new(180, 180) })
	elseif n == "Poltergeist" then
		ghostly(m, 0.3)
		glow(torso or m.PrimaryPart, Color3.fromRGB(170, 150, 255), 14, 1)
		emitter(torso or m.PrimaryPart, { Color = ColorSequence.new(Color3.fromRGB(190, 170, 255)), LightEmission = 1, Size = NumberSequence.new(0.18), Rate = 14,
			Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(0.3, 1), SpreadAngle = Vector2.new(180, 180) })
	elseif n == "MirrorBride" then
		ghostly(m, 0.12)
		glow(torso or m.PrimaryPart, Color3.fromRGB(235, 235, 255), 16, 1.2)
		emitter(torso or m.PrimaryPart, { Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)), LightEmission = 1, Size = NumberSequence.new(0.15, 0), Rate = 24,
			Lifetime = NumberRange.new(0.6, 1.2), Speed = NumberRange.new(0.5, 2), SpreadAngle = Vector2.new(180, 180) })
	elseif n == "Stalker" then
		emitter(torso or m.PrimaryPart, { Color = ColorSequence.new(Color3.fromRGB(10, 6, 14)), Size = NumberSequence.new(2, 4), Rate = 10,
			Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(0.5, 1.5), SpreadAngle = Vector2.new(180, 180),
			Transparency = NumberSequence.new(0.6, 1), Texture = "rbxasset://textures/particles/smoke_main.dds" })
		if head then
			for _, x in { -0.25, 0.25 } do
				local e = part(m, "Eye", Vector3.new(0.18, 0.12, 0.08), Color3.new(1, 1, 1), Enum.Material.Neon, head, CFrame.new(x * head.Size.X, 0.1 * head.Size.Y, -head.Size.Z / 2 - 0.03))
				e.CastShadow = false
			end
		end
	elseif n == "PlagueDoctor" then
		glow(torso or m.PrimaryPart, Color3.fromRGB(140, 220, 80), 12, 0.8)
		emitter(torso or m.PrimaryPart, { Color = ColorSequence.new(Color3.fromRGB(110, 170, 50)), Size = NumberSequence.new(1, 3), Rate = 6,
			Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(0.3, 1), SpreadAngle = Vector2.new(180, 180),
			Transparency = NumberSequence.new(0.6, 1), Texture = "rbxasset://textures/particles/smoke_main.dds" })
	end
	table.insert(out, n)
end
return "extras on: " .. table.concat(out, ", ")
