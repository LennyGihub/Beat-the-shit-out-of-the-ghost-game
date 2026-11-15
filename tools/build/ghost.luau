-- Builds ServerStorage.GhostTemplate: a part-built PS2-style woman ghost with a Motor6D rig (faces -Z).
local SS = game:GetService("ServerStorage")
local old = SS:FindFirstChild("GhostTemplate"); if old then old:Destroy() end
local g = Instance.new("Model"); g.Name = "GhostTemplate"
local SKIN = st(M.SmoothPlastic, nil, Color3.fromRGB(150, 172, 176))
local CLOTH = st(M.Fabric, nil, Color3.fromRGB(138, 160, 160))
local HAIR = st(M.SmoothPlastic, nil, Color3.fromRGB(10, 10, 12))
local VOID = st(M.SmoothPlastic, nil, Color3.fromRGB(4, 2, 2))
local GUM = st(M.SmoothPlastic, nil, Color3.fromRGB(70, 20, 22))
local NAIL = st(M.SmoothPlastic, nil, Color3.fromRGB(200, 214, 210))

local function P(name, size, pos, s, o)
	o = o or {}
	local p = part(g, name, size, CFrame.new(pos), s, o)
	p.Anchored = false; p.CanCollide = false; p.CanTouch = false; p.Massless = true
	return p
end
local function weld(p0, p1)
	local w = Instance.new("WeldConstraint"); w.Part0 = p0; w.Part1 = p1; w.Parent = p1
end
local function motor(name, p0, p1, pos)
	local m6 = Instance.new("Motor6D"); m6.Name = name
	local jw = CFrame.new(pos)
	m6.Part0 = p0; m6.Part1 = p1
	m6.C0 = p0.CFrame:Inverse() * jw; m6.C1 = p1.CFrame:Inverse() * jw
	m6.Parent = p1
	return m6
end

local hrp = P("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 6.15, 0), SKIN, { t = 1 })
hrp.Massless = false; hrp.CanQuery = true
local lt = P("LowerTorso", Vector3.new(1.75, 1.2, 1), Vector3.new(0, 6.15, 0), CLOTH)
local ut = P("UpperTorso", Vector3.new(2, 2.6, 1), Vector3.new(0, 8.05, 0), CLOTH)
local chest = P("Collarbone", Vector3.new(1.4, 0.5, 0.9), Vector3.new(0, 9.25, -0.02), SKIN); weld(ut, chest)
local belly = P("Belly", Vector3.new(1.3, 0.45, 0.85), Vector3.new(0, 6.85, -0.02), SKIN); weld(ut, belly)
local head = P("Head", Vector3.new(1.25, 1.55, 1.35), Vector3.new(0, 10.45, 0), SKIN)
local neck = P("NeckSkin", Vector3.new(0.5, 0.7, 0.5), Vector3.new(0, 9.6, 0), SKIN); weld(head, neck)
-- face: gaping mouth + sunken eyes
local mouth = P("Mouth", Vector3.new(0.42, 0.95, 0.1), Vector3.new(0, 9.95, -0.69), VOID); weld(head, mouth)
local gum = P("MouthRim", Vector3.new(0.58, 0.95, 0.06), Vector3.new(0, 10.0, -0.66), GUM); weld(head, gum)
for _, x in { -0.3, 0.3 } do local e = P("EyeSocket", Vector3.new(0.3, 0.14, 0.08), Vector3.new(x, 10.62, -0.69), VOID); weld(head, e) end
-- hair
local hair = {
	{ "HairCap", Vector3.new(1.45, 0.55, 1.55), Vector3.new(0, 11.25, 0.05) },
	{ "HairBack", Vector3.new(1.55, 5.2, 0.35), Vector3.new(0, 9.0, 0.78) },
	{ "HairSideL", Vector3.new(0.35, 3.8, 1.3), Vector3.new(-0.75, 9.6, 0.1) },
	{ "HairSideR", Vector3.new(0.35, 3.8, 1.3), Vector3.new(0.75, 9.6, 0.1) },
	{ "HairFront", Vector3.new(0.3, 3.4, 0.14), Vector3.new(-0.5, 9.75, -0.76) },
	{ "HairFront", Vector3.new(0.3, 3.1, 0.14), Vector3.new(0.5, 9.85, -0.76) },
	{ "HairFringeL", Vector3.new(0.55, 0.3, 0.14), Vector3.new(-0.38, 11.05, -0.76) },
	{ "HairFringeR", Vector3.new(0.55, 0.3, 0.14), Vector3.new(0.38, 11.05, -0.76) },
}
for _, h in hair do local p = P(h[1], h[2], h[3], HAIR); weld(head, p) end
for i = 1, 5 do
	local p = P("HairStrand", Vector3.new(0.18, 3 + i * 0.25, 0.12), Vector3.new(-0.7 + i * 0.25, 7.9 - i * 0.1, 0.97), HAIR); weld(head, p)
end
-- arms (very long) with claws
local function arm(side)
	local x = side * 1.2
	local ua = P(side < 0 and "LeftUpperArm" or "RightUpperArm", Vector3.new(0.36, 2.5, 0.36), Vector3.new(x, 7.95, 0), SKIN)
	local la = P(side < 0 and "LeftLowerArm" or "RightLowerArm", Vector3.new(0.32, 2.5, 0.32), Vector3.new(x, 5.45, 0), SKIN)
	local hd = P(side < 0 and "LeftHand" or "RightHand", Vector3.new(0.55, 0.65, 0.28), Vector3.new(x, 3.88, 0), SKIN)
	motor(side < 0 and "LeftShoulder" or "RightShoulder", ut, ua, Vector3.new(x, 9.15, 0))
	motor(side < 0 and "LeftElbow" or "RightElbow", ua, la, Vector3.new(x, 6.7, 0))
	motor(side < 0 and "LeftWrist" or "RightWrist", la, hd, Vector3.new(x, 4.2, 0))
	for i = 0, 3 do
		local fx = x - 0.21 + i * 0.14
		local len = 2.4 + ((i == 1 or i == 2) and 0.5 or 0)
		local f1 = P("Finger", Vector3.new(0.1, len, 0.1), Vector3.new(fx, 3.55 - len / 2, -0.05), SKIN); weld(hd, f1)
		local tip = P("Claw", Vector3.new(0.08, 0.7, 0.08), Vector3.new(fx, 3.55 - len - 0.3, -0.12), NAIL)
		tip.CFrame = CFrame.new(fx, 3.55 - len - 0.25, -0.15) * CFrame.Angles(-0.45, 0, 0); weld(hd, tip)
	end
	local th = P("Thumb", Vector3.new(0.1, 1.3, 0.1), Vector3.new(x - side * 0.3, 3.3, -0.12), SKIN); weld(hd, th)
end
arm(-1); arm(1)
-- legs
local function leg(side)
	local x = side * 0.48
	local ul = P(side < 0 and "LeftUpperLeg" or "RightUpperLeg", Vector3.new(0.5, 2.6, 0.5), Vector3.new(x, 4.25, 0), SKIN)
	local ll = P(side < 0 and "LeftLowerLeg" or "RightLowerLeg", Vector3.new(0.4, 2.6, 0.4), Vector3.new(x, 1.65, 0), SKIN)
	local ft = P(side < 0 and "LeftFoot" or "RightFoot", Vector3.new(0.55, 0.32, 1.1), Vector3.new(x, 0.18, -0.25), SKIN)
	motor(side < 0 and "LeftHip" or "RightHip", lt, ul, Vector3.new(x, 5.55, 0))
	motor(side < 0 and "LeftKnee" or "RightKnee", ul, ll, Vector3.new(x, 2.95, 0))
	motor(side < 0 and "LeftAnkle" or "RightAnkle", ll, ft, Vector3.new(x, 0.35, 0))
end
leg(-1); leg(1)
motor("Root", hrp, lt, Vector3.new(0, 6.15, 0))
motor("Waist", lt, ut, Vector3.new(0, 6.75, 0))
motor("Neck", ut, head, Vector3.new(0, 9.4, 0))
local shorts = P("Shorts", Vector3.new(1.85, 0.9, 1.05), Vector3.new(0, 5.4, 0), CLOTH); weld(lt, shorts)

-- ghostly cold light + floating specks
local glow = Instance.new("PointLight"); glow.Color = Color3.fromRGB(150, 200, 210); glow.Range = 14; glow.Brightness = 0.9; glow.Shadows = false; glow.Parent = ut
local pe = Instance.new("ParticleEmitter"); pe.Name = "Specks"
pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"; pe.Rate = 14; pe.Lifetime = NumberRange.new(1, 2)
pe.Speed = NumberRange.new(0.3, 1); pe.SpreadAngle = Vector2.new(180, 180); pe.Size = NumberSequence.new(0.18)
pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
pe.Color = ColorSequence.new(Color3.fromRGB(220, 240, 240)); pe.LightEmission = 1; pe.Parent = ut

g.PrimaryPart = hrp
for _, p in g:GetDescendants() do if p:IsA("BasePart") then p.Anchored = false end end
g.Parent = SS
-- preview copy (anchored) for a screenshot
local pv = g:Clone(); pv.Name = "GhostPreview"
for _, p in pv:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true end end
pv:PivotTo(CFrame.new(20, 3, 44) * CFrame.Angles(0, math.pi, 0))
pv.Parent = workspace
return "ghost parts: " .. #g:GetDescendants()
