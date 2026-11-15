-- ServerStorage.StandTemplate (market stall, faces -Z, Slot1..6 attachments) + ServerStorage.PilotLying.
local SSv = game:GetService("ServerStorage")
for _, n in { "StandTemplate", "PilotLying" } do local o = SSv:FindFirstChild(n); if o then o:Destroy() end end
local O = CFrame.new()
local WOOD = st(M.WoodPlanks, "PS2_FloorPlanks2", Color3.fromRGB(110, 92, 74))
local POST = st(M.Wood, "PS2_DarkBeam1", Color3.fromRGB(80, 60, 44))
local s = Instance.new("Model"); s.Name = "StandTemplate"
local top = b(s, O, "Table", 11, 0.5, 4.4, 0, 3.4, 0, WOOD)
b(s, O, "Front", 11, 3.1, 0.3, 0, 1.6, -2.05, WOOD)
b(s, O, "Back", 11, 3.1, 0.3, 0, 1.6, 2.05, WOOD)
for _, x in { -5.3, 5.3 } do
	for _, z in { -2, 2 } do b(s, O, "Post", 0.4, 9, 0.4, x, 4.5, z, POST) end
end
for i = 0, 7 do
	local c = i % 2 == 0 and Color3.fromRGB(120, 24, 22) or Color3.fromRGB(205, 192, 165)
	part(s, "Canopy", Vector3.new(11.6 / 8, 0.25, 5.4), CFrame.new(-5.8 + 11.6 / 16 + i * 11.6 / 8, 9.2, -0.2) * CFrame.Angles(math.rad(-10), 0, 0), st(M.Fabric, nil, c))
end
local sign = b(s, O, "Sign", 8, 2.2, 0.3, 0, 7.6, 2.1, WOOD)
local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.CanvasSize = Vector2.new(400, 110); sg.LightInfluence = 0; sg.Brightness = 1.1; sg.Parent = sign
local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 0.62); t.Font = Enum.Font.Creepster; t.TextScaled = true
t.Text = "BLACK MARKET"; t.TextColor3 = Color3.fromRGB(230, 70, 50); t.TextStrokeTransparency = 0.3; t.Parent = sg
local t2 = t:Clone(); t2.Font = Enum.Font.SpecialElite; t2.Text = "no refunds. no questions."; t2.Position = UDim2.fromScale(0, 0.62); t2.Size = UDim2.fromScale(1, 0.34)
t2.TextColor3 = Color3.fromRGB(220, 210, 180); t2.Parent = sg
local lan = b(s, O, "Lantern", 0.8, 1.1, 0.8, 4.6, 8.3, -1.6, T.glow)
light(lan, 26, 1.6, Color3.fromRGB(255, 170, 90))
for i, p in { { -3.4, -1 }, { 0, -1 }, { 3.4, -1 }, { -3.4, 1 }, { 0, 1 }, { 3.4, 1 } } do
	local a = Instance.new("Attachment"); a.Name = "Slot" .. i; a.CFrame = CFrame.new(p[1], 0.25 + (p[2] > 0 and 0.6 or 0), p[2]); a.Parent = top
end
-- risers for the back row
b(s, O, "Riser", 10.6, 0.6, 1.8, 0, 3.95, 1.1, POST)
for _, c in { { 6.6, -1.5 }, { -6.8, 1.2 } } do b(s, O, "Crate", 2.2, 2.2, 2.2, c[1], 1.1, c[2], st(M.WoodPlanks, nil, Color3.fromRGB(130, 104, 74))) end
for _, p in s:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true end end
s.PrimaryPart = top
s:PivotTo(CFrame.new(0, 0, 0))
-- pivot at the floor under the table centre
s.WorldPivot = CFrame.new(0, 0, 0)
s.Parent = SSv

-- injured pilot lying on his back, head toward +Z, groaning
local pl = Instance.new("Model"); pl.Name = "PilotLying"
local SKN = st(M.SmoothPlastic, nil, Color3.fromRGB(196, 150, 120))
local JKT = st(M.Leather, nil, Color3.fromRGB(96, 60, 36))
local PNT = st(M.Fabric, nil, Color3.fromRGB(60, 64, 50))
local FUR = st(M.Fabric, nil, Color3.fromRGB(200, 186, 160))
local R = CFrame.new(0, 0.7, 0) * CFrame.Angles(math.rad(90), 0, 0)
b(pl, R, "LeftLeg", 1, 2.6, 1, -0.55, 1.6, 0, PNT); b(pl, R, "RightLeg", 1, 2.6, 1, 0.75, 1.6, 0, PNT)
b(pl, R, "Bandage", 1.05, 0.6, 1.05, 0.75, 1.4, 0, st(M.Fabric, nil, Color3.fromRGB(220, 215, 200)))
b(pl, R, "BloodStain", 0.5, 0.4, 0.1, 0.75, 1.4, -0.56, st(M.SmoothPlastic, nil, Color3.fromRGB(110, 10, 10)))
local torso = b(pl, R, "Torso", 2.4, 2.6, 1.3, 0, 4.2, 0, JKT)
b(pl, R, "Collar", 2.6, 0.6, 1.5, 0, 5.4, 0, FUR)
b(pl, R, "LeftArm", 0.9, 2.5, 0.9, -1.65, 4.1, 0, JKT)
part(pl, "RightArm", Vector3.new(0.9, 2.5, 0.9), R * CFrame.new(1.9, 5.6, -0.8) * CFrame.Angles(math.rad(-60), 0, math.rad(-20)), JKT)
b(pl, R, "Head", 1.5, 1.6, 1.4, 0, 6.5, 0, SKN)
b(pl, R, "Beard", 1.5, 0.8, 0.3, 0, 6.0, -0.7, st(M.Fabric, nil, Color3.fromRGB(70, 56, 46)))
b(pl, R, "Cap", 1.65, 0.8, 1.6, 0, 7.4, 0.05, JKT)
b(pl, R, "Goggles", 1.6, 0.45, 0.3, 0, 7.15, -0.7, st(M.Glass, nil, Color3.fromRGB(150, 120, 60)))
b(pl, R, "Scarf", 0.5, 1.6, 0.2, 0.5, 4.8, -0.75, st(M.Fabric, nil, Color3.fromRGB(150, 30, 26)))
for _, p in pl:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = false end end
pl.PrimaryPart = torso
pl.WorldPivot = CFrame.new(0, 0, 0)
local bb = Instance.new("BillboardGui"); bb.Size = UDim2.fromOffset(260, 60); bb.StudsOffset = Vector3.new(0, 3, 0); bb.MaxDistance = 40; bb.Parent = torso
local q = Instance.new("TextLabel"); q.BackgroundTransparency = 1; q.Size = UDim2.fromScale(1, 1); q.Font = Enum.Font.SpecialElite; q.TextScaled = true
q.Text = "\"ugh... my leg... the stuff's on the table. cash first.\""; q.TextColor3 = Color3.fromRGB(230, 220, 195); q.TextStrokeTransparency = 0.2; q.Parent = bb
pl.Parent = SSv
-- preview copies near the mansion yard
local pv = s:Clone(); pv.Name = "StandPreview"; pv:PivotTo(CFrame.new(40, 0, 120) * CFrame.Angles(0, math.pi, 0)); pv.Parent = workspace
local pp = pl:Clone(); pp.Name = "PilotPreview"; pp:PivotTo(pv:GetPivot() * CFrame.new(-7.5, 0, 1.5) * CFrame.Angles(0, math.rad(-25), 0)); pp.Parent = workspace
return "stand ok"
