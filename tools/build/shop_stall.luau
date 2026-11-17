-- The RUN SHOP's market stall (ServerStorage.ShopStall): one long counter with six roomy bays, a back wall for the
-- price boards (Server/Events hangs one above every item), a striped canopy and lanterns. Server/Events stands it
-- next to the wreck of every event (plane, van, train) and puts the stock on its Slot1..Slot6 attachments.
-- Pivot = ground level, middle of the counter; the customers' side is -Z. Standalone: run in Studio (Edit).
local SS = game:GetService("ServerStorage")
local old = SS:FindFirstChild("ShopStall")
if old then old:Destroy() end
local m = Instance.new("Model")
m.Name = "ShopStall"
local BAY, N = 4.4, 6
local W = BAY * N + 0.4
local rng = Random.new(7)
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, variant: string?, solid: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat
	if variant then p.MaterialVariant = variant end
	p.Anchored = true; p.CanCollide = solid == true; p.CanTouch = false; p.CanQuery = solid == true
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = m
	return p
end
local WOOD, DARK = C(96, 70, 48), C(58, 42, 30)
-- the counter (solid: nobody walks through the stall)
local top = part("Counter", Vector3.new(W, 0.4, 3.6), CFrame.new(0, 3.0, 0), WOOD, Enum.Material.WoodPlanks, "PS2_FloorPlanks", true)
for i = 0, 11 do
	local x = -W / 2 + (i + 0.5) * (W / 12)
	part("Skirt", Vector3.new(W / 12 - 0.08, 2.8, 0.25), CFrame.new(x, 1.4, -1.68) * CFrame.Angles(0, 0, math.rad(rng:NextNumber(-1.5, 1.5))), WOOD:Lerp(DARK, rng:NextNumber(0, 0.7)), Enum.Material.WoodPlanks, "PS2_Siding", true)
end
for _, sx in { -1, 1 } do
	part("SkirtSide", Vector3.new(0.25, 2.8, 3.6), CFrame.new(sx * (W / 2 - 0.12), 1.4, 0), DARK, Enum.Material.WoodPlanks, "PS2_Siding", true)
end
-- the back wall the price boards hang on
part("BackWall", Vector3.new(W, 10.2, 0.3), CFrame.new(0, 5.1, 1.95), DARK, Enum.Material.WoodPlanks, "PS2_Siding", true)
for i = 0, N do
	part("BackBatten", Vector3.new(0.3, 10.2, 0.12), CFrame.new(-W / 2 + 0.2 + i * BAY, 5.1, 1.76), C(40, 30, 22), Enum.Material.Wood, "PS2_DarkBeam")
end
-- a narrow shelf under the boards, the length of the wall
part("Shelf", Vector3.new(W, 0.2, 0.7), CFrame.new(0, 5.35, 1.5), WOOD, Enum.Material.Wood, "PS2_DarkBeam")
-- posts and the canopy
for _, x in { -W / 2 + 0.2, W / 2 - 0.2 } do -- (none in the middle: nothing stands in front of a price board)
	part("Post", Vector3.new(0.45, 10.9, 0.45), CFrame.new(x, 5.45, -1.75), C(46, 34, 25), Enum.Material.Wood, "PS2_DarkBeam", true)
end
part("Beam", Vector3.new(W + 0.6, 0.4, 0.45), CFrame.new(0, 10.9, -1.75), C(46, 34, 25), Enum.Material.Wood, "PS2_DarkBeam")
for i = 0, 11 do
	local x = -W / 2 + (i + 0.5) * (W / 12)
	local col = i % 2 == 0 and C(120, 28, 24) or C(196, 182, 150)
	part("Canopy", Vector3.new(W / 12, 0.14, 6.6), CFrame.new(x, 11.35, -0.9) * CFrame.Angles(math.rad(-11), 0, 0), col:Lerp(C(40, 34, 30), 0.25), Enum.Material.Fabric)
	part("Valance", Vector3.new(W / 12, 0.9, 0.1), CFrame.new(x, 10.35, -4.12), col:Lerp(C(40, 34, 30), 0.3), Enum.Material.Fabric)
end
-- the big sign over the canopy (Server/Events writes the shop's name on it)
local sign = part("Sign", Vector3.new(15, 2.6, 0.35), CFrame.new(0, 13.6, 1.4), C(34, 26, 20), Enum.Material.Wood, "PS2_DarkBeam")
for _, x in { -6.5, 6.5 } do part("SignPost", Vector3.new(0.35, 3.4, 0.35), CFrame.new(x, 12, 1.6), C(46, 34, 25), Enum.Material.Wood, "PS2_DarkBeam") end
local sg = Instance.new("SurfaceGui")
sg.Name = "Gui"; sg.Face = Enum.NormalId.Front; sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; sg.PixelsPerStud = 40; sg.LightInfluence = 0.15
sg.Parent = sign
local title = Instance.new("TextLabel")
title.Name = "Title"; title.BackgroundTransparency = 1; title.Size = UDim2.fromScale(0.96, 0.66); title.Position = UDim2.fromScale(0.02, 0.02)
title.Font = Enum.Font.Creepster; title.Text = "SHOP"; title.TextScaled = true; title.TextColor3 = C(255, 190, 90)
title.TextStrokeTransparency = 0.2; title.TextStrokeColor3 = C(14, 10, 8); title.Parent = sg
local sub = Instance.new("TextLabel")
sub.Name = "Sub"; sub.BackgroundTransparency = 1; sub.Size = UDim2.fromScale(0.96, 0.3); sub.Position = UDim2.fromScale(0.02, 0.68)
sub.Font = Enum.Font.SpecialElite; sub.Text = "RUN CASH ONLY  -  NEW STOCK AFTER EVERY GHOST"; sub.TextScaled = true; sub.TextColor3 = C(150, 220, 110)
sub.TextStrokeTransparency = 0.3; sub.Parent = sg
-- lanterns under the canopy: enough light to read by
for _, x in { -BAY * 2, 0, BAY * 2 } do
	part("LanternCord", Vector3.new(0.08, 1.2, 0.08), CFrame.new(x, 10.1, -2.6), C(20, 18, 16), Enum.Material.Metal)
	local l = part("Lantern", Vector3.new(0.5, 0.7, 0.5), CFrame.new(x, 9.3, -2.6), C(214, 150, 70), Enum.Material.Neon)
	l.Transparency = 0.25
	local pl = Instance.new("PointLight"); pl.Color = C(255, 196, 120); pl.Range = 22; pl.Brightness = 1.3; pl.Shadows = false; pl.Parent = l
end
-- a worn rug where the customers stand, crates and a barrel at the ends
part("Rug", Vector3.new(W - 1, 0.1, 5.5), CFrame.new(0, 0.06, -4.7), C(92, 34, 30), Enum.Material.Carpet, "PS2_Rug")
part("Crate", Vector3.new(2.4, 2.4, 2.4), CFrame.new(W / 2 + 1.6, 1.2, 0.6) * CFrame.Angles(0, 0.3, 0), WOOD, Enum.Material.WoodPlanks, "PS2_Siding", true)
part("Crate", Vector3.new(1.8, 1.8, 1.8), CFrame.new(W / 2 + 1.3, 3.3, 0.5) * CFrame.Angles(0, -0.2, 0), DARK, Enum.Material.WoodPlanks, "PS2_Siding", true)
local barrel = part("Barrel", Vector3.new(3.2, 2.4, 2.4), CFrame.new(-W / 2 - 1.6, 1.6, 0.4) * CFrame.Angles(0, 0, math.pi / 2), C(80, 54, 36), Enum.Material.Wood, "PS2_DarkBeam", true)
barrel.Shape = Enum.PartType.Cylinder
-- the six item slots: one bay each, on the counter
for i = 1, N do
	local a = Instance.new("Attachment")
	a.Name = "Slot" .. i
	a.Position = Vector3.new((i - (N + 1) / 2) * BAY, 0.2, -0.35)
	a.Parent = top
	-- a little mat under each item
	part("Mat", Vector3.new(3.3, 0.06, 2.3), CFrame.new((i - (N + 1) / 2) * BAY, 3.23, -0.35), C(30, 26, 24), Enum.Material.Fabric)
end
m.WorldPivot = CFrame.new(0, 0, 0)
m.Parent = SS
return "ShopStall built: " .. #m:GetDescendants() .. " instances, width " .. W
