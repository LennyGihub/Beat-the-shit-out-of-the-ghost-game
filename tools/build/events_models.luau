-- ReplicatedStorage.EventModels: Van, TrainLoco, TrainWagon, TrainShopWagon. Front = -Z, pivot on the ground.
local RSv = game:GetService("ReplicatedStorage")
local old = RSv:FindFirstChild("EventModels"); if old then old:Destroy() end
local F = Instance.new("Folder"); F.Name = "EventModels"; F.Parent = RSv
local O = CFrame.new()
local IRON = st(M.Metal, nil, Color3.fromRGB(38, 38, 40))
local RUST = st(M.CorrodedMetal, nil, Color3.fromRGB(110, 70, 48))
local GLASS = st(M.Glass, nil, Color3.fromRGB(50, 66, 76))
local PLANKS = st(M.WoodPlanks, "PS2_FloorPlanks2", Color3.fromRGB(110, 92, 74))
local function slot(parent: BasePart, name: string, worldCF: CFrame)
	local a = Instance.new("Attachment"); a.Name = name; a.WorldCFrame = worldCF; a.Parent = parent
end
local function wheels(m, xs, zs, d, y, s)
	for _, x in xs do for _, z in zs do
		local w = cyl(m, O, "Wheel", d, 0.8, x, y, z, s or IRON)
		w.CFrame = CFrame.new(x, y, z)
	end end
end
local function finish(m: Model, primary: BasePart)
	for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true end end
	m.PrimaryPart = primary
	m.WorldPivot = CFrame.new()
	m.Parent = F
end

-- VAN (cab at -Z, open cargo at +Z with the shop inside)
local van = Instance.new("Model"); van.Name = "Van"
local WHITE = st(M.SmoothPlastic, nil, Color3.fromRGB(200, 196, 182))
local floor = b(van, O, "CargoFloor", 6.6, 0.4, 11, 0, 1.6, 2.5, PLANKS)
b(van, O, "SideL", 0.3, 6, 11, -3.3, 4.6, 2.5, WHITE); b(van, O, "SideR", 0.3, 6, 11, 3.3, 4.6, 2.5, WHITE)
b(van, O, "Roof", 7, 0.3, 11.4, 0, 7.6, 2.5, WHITE)
b(van, O, "Stripe", 7.05, 0.6, 11, 0, 3.6, 2.5, st(M.SmoothPlastic, nil, Color3.fromRGB(150, 30, 26)), DECO)
b(van, O, "Bulkhead", 6.6, 6, 0.3, 0, 4.6, -3, WHITE)
b(van, O, "Cab", 7, 5.2, 5, 0, 4, -5.5, WHITE)
b(van, O, "Windshield", 6.2, 2.4, 0.2, 0, 5.2, -8.05, GLASS, { t = 0.2 })
b(van, O, "Hood", 7, 2.2, 2.6, 0, 2.5, -9.2, WHITE)
b(van, O, "Bumper", 7.2, 0.8, 0.6, 0, 1.4, -10.6, IRON)
for _, x in { -2.6, 2.6 } do b(van, O, "Headlight", 1, 0.6, 0.2, x, 2.8, -10.55, st(M.Neon, nil, Color3.fromRGB(255, 240, 200)), DECO) end
-- rear doors swung open
for _, sx in { -1, 1 } do part(van, "RearDoor", Vector3.new(0.25, 5.6, 3.2), CFrame.new(sx * 3.3, 4.5, 8.1) * CFrame.Angles(0, sx * math.rad(80), 0) * CFrame.new(0, 0, 1.6), WHITE) end
wheels(van, { -3.1, 3.1 }, { -7, 5.5 }, 2.6, 1.3)
-- shelves inside: a rack on the bulkhead and crates near the doors
b(van, O, "Rack", 6.2, 0.3, 1.6, 0, 3.6, -2.0, PLANKS)
b(van, O, "Crate", 6, 1.2, 2.2, 0, 2.4, 6.4, PLANKS)
for i, x in { -2, 0, 2 } do
	slot(floor, "Slot" .. i, CFrame.new(x, 3.0, 6.4))
	slot(floor, "Slot" .. (i + 3), CFrame.new(x, 3.75, -2.0))
end
local vl = b(van, O, "CargoLamp", 0.6, 0.4, 0.6, 0, 7.3, 3, T.glow, DECO)
light(vl, 16, 1.2, Color3.fromRGB(255, 200, 140))
finish(van, floor)

-- TRAIN LOCOMOTIVE
local loco = Instance.new("Model"); loco.Name = "TrainLoco"
local chassis = b(loco, O, "Chassis", 7.6, 1, 20, 0, 1.8, 0, IRON)
local boiler = cyl(loco, O, "Boiler", 6, 12, 0, 5.2, -3, IRON)
boiler.CFrame = CFrame.new(0, 5.2, -3) * CFrame.Angles(0, math.pi / 2, 0)
b(loco, O, "Cab", 7.4, 7, 6, 0, 5.8, 6.5, st(M.Metal, nil, Color3.fromRGB(120, 30, 26)))
b(loco, O, "CabRoof", 8, 0.5, 7, 0, 9.5, 6.5, IRON)
cyl(loco, O, "Chimney", 1.6, 3.4, 0, 9, -7.5, IRON)
b(loco, O, "Cowcatcher", 7, 1.4, 1.4, 0, 1.4, -10.5, RUST)
cyl(loco, O, "Lamp", 1.4, 0.6, 0, 6.5, -9.2, st(M.Neon, nil, Color3.fromRGB(255, 230, 160))).CFrame = CFrame.new(0, 6.5, -9.2) * CFrame.Angles(0, math.pi / 2, 0)
wheels(loco, { -3.6, 3.6 }, { -7, -2, 3, 7.5 }, 2.6, 1.3, RUST)
finish(loco, chassis)

-- WAGONS (plain boxcar + shop boxcar with its -X side open)
local function wagon(name: string, shop: boolean)
	local w = Instance.new("Model"); w.Name = name
	local BROWN = st(M.WoodPlanks, nil, Color3.fromRGB(110, 60, 40))
	local fl = b(w, O, "Floor", 7.6, 0.6, 18, 0, 2.4, 0, IRON)
	b(w, O, "WallRight", 0.4, 6.4, 18, 3.6, 5.9, 0, BROWN)
	b(w, O, "Front", 7.6, 6.4, 0.4, 0, 5.9, -8.8, BROWN); b(w, O, "Back", 7.6, 6.4, 0.4, 0, 5.9, 8.8, BROWN)
	b(w, O, "Body", 7.8, 0.5, 18.4, 0, 9.3, 0, st(M.Metal, nil, Color3.fromRGB(70, 60, 55)))
	if shop then
		-- left side: two short wall stubs and a slid-open door, so the inside is visible
		b(w, O, "WallLeftA", 0.4, 6.4, 4, -3.6, 5.9, -7, BROWN); b(w, O, "WallLeftB", 0.4, 6.4, 4, -3.6, 5.9, 7, BROWN)
		b(w, O, "SlidDoor", 0.3, 6, 6, -4, 5.9, 6.6, st(M.WoodPlanks, nil, Color3.fromRGB(90, 50, 34)))
		-- a counter right at the open side (reachable from outside) and a shelf behind it
		local shelf1 = b(w, O, "Counter", 2.2, 1.6, 10, -2.2, 3.5, 0, PLANKS)
		b(w, O, "Shelf", 1.6, 0.3, 10, 1.2, 5.2, 0, PLANKS)
		for k, z in { -3.5, 0, 3.5 } do
			slot(shelf1, "Slot" .. k, CFrame.new(-2.2, 4.3, z))
			slot(shelf1, "Slot" .. (k + 3), CFrame.new(1.2, 5.35, z))
		end
		local lamp = b(w, O, "ShopLamp", 0.6, 0.5, 0.6, -1.5, 8.6, 0, T.glow, DECO)
		light(lamp, 22, 2, Color3.fromRGB(255, 190, 120))
		local sign = b(w, O, "ShopSign", 0.2, 1.6, 6, -3.95, 8.4, 0, PLANKS)
		local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Left; sg.CanvasSize = Vector2.new(360, 96); sg.LightInfluence = 0; sg.Parent = sign
		local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 1); t.Font = Enum.Font.Creepster
		t.TextScaled = true; t.Text = "EVERYTHING MUST GO"; t.TextColor3 = Color3.fromRGB(230, 70, 50); t.Parent = sg
	else
		b(w, O, "WallLeft", 0.4, 6.4, 18, -3.6, 5.9, 0, BROWN)
	end
	wheels(w, { -3.6, 3.6 }, { -6, 6 }, 2.6, 1.3, RUST)
	finish(w, fl)
end
wagon("TrainWagon", false)
wagon("TrainShopWagon", true)
return "event models: " .. #F:GetChildren()
