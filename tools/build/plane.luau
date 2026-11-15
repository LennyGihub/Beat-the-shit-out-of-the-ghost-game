-- ReplicatedStorage.PlaneModel (old propeller cargo plane, nose = -Z) and ServerStorage.MerchantTemplate (crashed pilot).
local RSv = game:GetService("ReplicatedStorage")
local SSv = game:GetService("ServerStorage")
for _, n in { { RSv, "PlaneModel" }, { SSv, "MerchantTemplate" } } do local o = n[1]:FindFirstChild(n[2]); if o then o:Destroy() end end

local OLIVE = st(M.Metal, nil, Color3.fromRGB(88, 92, 66))
local RUST = st(M.CorrodedMetal, nil, Color3.fromRGB(110, 76, 52))
local DARKM = st(M.Metal, nil, Color3.fromRGB(42, 42, 40))
local WIN = st(M.Glass, nil, Color3.fromRGB(60, 80, 90))
local pl = Instance.new("Model"); pl.Name = "PlaneModel"
local O = CFrame.new()
local body = b(pl, O, "Body", 7, 7, 34, 0, 0, 0, OLIVE)
b(pl, O, "Belly", 6, 1.5, 30, 0, -3.8, 0, RUST)
b(pl, O, "Nose", 5.6, 5.6, 4, 0, -0.2, -19, OLIVE)
b(pl, O, "NoseCap", 3.6, 3.6, 2, 0, -0.3, -21.8, DARKM)
b(pl, O, "Cockpit", 5.2, 2.2, 5, 0, 3.6, -14, WIN, { t = 0.2 })
b(pl, O, "CockpitFrame", 5.6, 0.4, 5.4, 0, 4.8, -14, DARKM)
for i = -2, 2 do b(pl, O, "Window", 0.2, 1.4, 1.6, 3.55, 1.2, i * 4, WIN); b(pl, O, "Window", 0.2, 1.4, 1.6, -3.55, 1.2, i * 4, WIN) end
b(pl, O, "Tail", 5, 5, 10, 0, 0.8, 21, OLIVE)
b(pl, O, "Fin", 0.8, 9, 6, 0, 7, 24, OLIVE)
b(pl, O, "FinStripe", 0.9, 1.4, 6.1, 0, 9, 24, st(M.SmoothPlastic, nil, Color3.fromRGB(150, 40, 30)))
b(pl, O, "Stabilizer", 18, 0.6, 4.5, 0, 1.5, 24.5, OLIVE)
b(pl, O, "WingL", 26, 0.9, 8, -16.5, 1.6, -3, OLIVE)
b(pl, O, "WingR", 26, 0.9, 8, 16.5, 1.6, -3, RUST)
for _, x in { -11, 11 } do
	local e = cyl(pl, O, x < 0 and "EngineL" or "EngineR", 3.2, 7, x, 0.6, -5, DARKM)
	e.CFrame = CFrame.new(x, 0.6, -5) * CFrame.Angles(math.pi / 2, 0, 0) * CFrame.Angles(0, 0, math.pi / 2)
	b(pl, O, "Prop", 0.4, 8, 0.6, x, 0.6, -8.8, DARKM)
	b(pl, O, "Prop", 8, 0.4, 0.6, x, 0.6, -8.8, DARKM)
	b(pl, O, "Spinner", 1, 1, 1, x, 0.6, -8.9, st(M.SmoothPlastic, nil, Color3.fromRGB(150, 40, 30)))
end
b(pl, O, "Star", 0.2, 2.4, 2.4, 3.6, 0.5, 8, st(M.SmoothPlastic, nil, Color3.fromRGB(215, 210, 195)))
b(pl, O, "Star", 0.2, 2.4, 2.4, -3.6, 0.5, 8, st(M.SmoothPlastic, nil, Color3.fromRGB(215, 210, 195)))
pl.PrimaryPart = body
pl.Parent = RSv

-- merchant: scruffy crashed pilot standing on the ground (y = 0), facing -Z
local mt = Instance.new("Model"); mt.Name = "MerchantTemplate"
local SKN = st(M.SmoothPlastic, nil, Color3.fromRGB(196, 150, 120))
local JKT = st(M.Leather, nil, Color3.fromRGB(96, 60, 36))
local PNT = st(M.Fabric, nil, Color3.fromRGB(60, 64, 50))
local FUR = st(M.Fabric, nil, Color3.fromRGB(200, 186, 160))
b(mt, O, "LeftLeg", 1, 2.6, 1, -0.55, 1.6, 0, PNT); b(mt, O, "RightLeg", 1, 2.6, 1, 0.55, 1.6, 0, PNT)
b(mt, O, "Boots", 2.3, 0.6, 1.4, 0, 0.3, -0.1, DARKM)
local torso = b(mt, O, "Torso", 2.4, 2.6, 1.3, 0, 4.2, 0, JKT)
b(mt, O, "Collar", 2.6, 0.6, 1.5, 0, 5.4, 0, FUR)
b(mt, O, "LeftArm", 0.9, 2.5, 0.9, -1.65, 4.1, 0, JKT); b(mt, O, "RightArm", 0.9, 2.5, 0.9, 1.65, 4.1, 0, JKT)
b(mt, O, "LeftHand", 0.8, 0.7, 0.8, -1.65, 2.6, 0, SKN); b(mt, O, "RightHand", 0.8, 0.7, 0.8, 1.65, 2.6, 0, SKN)
b(mt, O, "Head", 1.5, 1.6, 1.4, 0, 6.5, 0, SKN)
b(mt, O, "Beard", 1.5, 0.8, 0.3, 0, 6.0, -0.7, st(M.Fabric, nil, Color3.fromRGB(70, 56, 46)))
b(mt, O, "Cap", 1.65, 0.8, 1.6, 0, 7.4, 0.05, JKT)
b(mt, O, "Flap", 0.3, 1.2, 1.2, -0.85, 6.7, 0.1, JKT); b(mt, O, "Flap", 0.3, 1.2, 1.2, 0.85, 6.7, 0.1, JKT)
b(mt, O, "Goggles", 1.6, 0.45, 0.3, 0, 7.15, -0.7, st(M.Glass, nil, Color3.fromRGB(150, 120, 60)))
for _, x in { -0.3, 0.3 } do b(mt, O, "Eye", 0.22, 0.12, 0.05, x, 6.75, -0.71, st(M.SmoothPlastic, nil, Color3.fromRGB(20, 18, 16))) end
b(mt, O, "Scarf", 0.5, 1.6, 0.2, 0.5, 4.8, -0.75, st(M.Fabric, nil, Color3.fromRGB(150, 30, 26)))
-- crate counter with a lantern and wares
local cb = b(mt, O, "Counter", 5, 2.6, 2.4, 0, 1.3, -2.6, st(M.WoodPlanks, nil, Color3.fromRGB(120, 96, 70)))
b(mt, O, "Knuckles", 0.9, 0.3, 0.5, -1.4, 2.75, -2.6, st(M.Metal, nil, Color3.fromRGB(200, 160, 70)))
cyl(mt, O, "Can", 0.5, 0.9, 0, 3.05, -2.4, st(M.Metal, nil, Color3.fromRGB(60, 140, 60)))
cyl(mt, O, "PillBottle", 0.45, 0.7, 0.8, 2.95, -2.7, st(M.SmoothPlastic, nil, Color3.fromRGB(200, 120, 40)))
local lan = b(mt, O, "Lantern", 0.7, 1, 0.7, 1.8, 3.1, -2.4, T.glow)
light(lan, 22, 1.6)
for _, p in mt:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true end end
mt.PrimaryPart = torso
mt:PivotTo(CFrame.new(0, 0, 0))
mt.Parent = SSv

-- StarterPlayer settings for first person
local SP = game:GetService("StarterPlayer")
SP.CameraMode = Enum.CameraMode.LockFirstPerson
SP.CharacterWalkSpeed = 17
local gp = workspace:FindFirstChild("GhostPreview"); if gp then gp:Destroy() end
return "plane + merchant ok"
