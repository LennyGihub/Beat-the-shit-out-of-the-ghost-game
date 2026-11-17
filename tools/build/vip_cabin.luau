-- Builds the VIP cabin in the park: a bigger copy of a room cabin, turned to face the middle, with a gold trim,
-- a VIP sign, a red carpet and an empty lit room. Its door is tagged "VipDoor" (Client/Vip opens it for owners).
local CS = game:GetService("CollectionService")
local lobby = workspace.Lobby
local old = lobby:FindFirstChild("VipCabin")
if old then old:Destroy() end
local m = lobby.Rooms.Room1a.Cabin:Clone()
m.Name = "VipCabin"
m.Parent = lobby
m:ScaleTo(1.5)
m:PivotTo(CFrame.new(108, 20, 996) * CFrame.Angles(0, math.rad(90), 0))
local cf, size = m:GetBoundingBox()
m:PivotTo(m:GetPivot() + Vector3.new(108 - cf.Position.X, 0.05 - (cf.Position.Y - size.Y / 2), 996 - cf.Position.Z))

local GOLD = Color3.fromRGB(214, 170, 66)
local RED = Color3.fromRGB(122, 18, 26)
local goldNames = { DoorFrame = true, DoorBrace = true, WindowFrame = true, WindowBar = true, Ridge = true, PorchPost = true, Handle = true, LanternArm = true }
local door
for _, d in m:GetDescendants() do
	if d:IsA("BasePart") then
		d.Anchored = true
		if d.Name == "Moss" or d.Name == "Barrel" or d.Name == "Firewood" then
			d:Destroy()
		elseif goldNames[d.Name] then
			d.Color = GOLD; d.Material = Enum.Material.Metal
		elseif d.Name == "Roof" or d.Name == "PorchRoof" then
			d.Color = Color3.fromRGB(44, 34, 52)
		elseif d.Name == "Door" then
			door = d
		elseif d.Name == "Lantern" or d.Name == "WindowGlow" then
			d.Color = Color3.fromRGB(255, 200, 96)
		end
	elseif d:IsA("PointLight") then
		d.Color = Color3.fromRGB(255, 196, 110)
	end
end
-- the door: solid for everyone on the server; Client/Vip lets owners through and prompts the others
door.Name = "VipDoor"
door.Color = RED
door.Material = Enum.Material.WoodPlanks
door.CanCollide = true
CS:AddTag(door, "VipDoor")
local pp = Instance.new("ProximityPrompt")
pp.ActionText = "Get VIP"
pp.ObjectText = "VIP cabin"
pp.KeyboardKeyCode = Enum.KeyCode.F
pp.HoldDuration = 0
pp.MaxActivationDistance = 11
pp.RequiresLineOfSight = false
pp.Parent = door

local function part(name, size, cframe, color, mat, collide)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cframe; p.Color = color; p.Material = mat
	p.Anchored = true; p.CanCollide = collide == true; p.CanQuery = collide == true; p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = m
	return p
end
local floor = m:FindFirstChild("Floor")
local porch = m:FindFirstChild("Porch")
local porchRoof = m:FindFirstChild("PorchRoof")
-- red carpet from the steps through the door, and a rug in the room
local front = Vector3.new(-1, 0, 0)
local dcf = door.CFrame
local carpetFrom = Vector3.new(porch.Position.X - porch.Size.Z / 2, porch.Position.Y + porch.Size.Y / 2 + 0.06, dcf.Position.Z)
local carpetTo = Vector3.new(floor.Position.X, floor.Position.Y + floor.Size.Y / 2 + 0.06, dcf.Position.Z)
part("CarpetPorch", Vector3.new(porch.Size.Z + 0.6, 0.1, door.Size.X * 0.9), CFrame.new(porch.Position.X, carpetFrom.Y, dcf.Position.Z), RED, Enum.Material.Fabric)
part("Rug", Vector3.new(floor.Size.Z * 0.72, 0.1, floor.Size.X * 0.62), CFrame.new(floor.Position.X, carpetTo.Y, floor.Position.Z), RED, Enum.Material.Fabric)
part("RugTrim", Vector3.new(floor.Size.Z * 0.72 + 0.6, 0.06, floor.Size.X * 0.62 + 0.6), CFrame.new(floor.Position.X, carpetTo.Y - 0.02, floor.Position.Z), GOLD, Enum.Material.Fabric)
-- warm light in the room
local lamp = part("RoomLamp", Vector3.new(1.2, 1.2, 1.2), CFrame.new(floor.Position.X, floor.Position.Y + 9.5, floor.Position.Z), Color3.fromRGB(255, 206, 120), Enum.Material.Neon)
lamp.Shape = Enum.PartType.Ball
local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 190, 110); l.Range = 26; l.Brightness = 1.6; l.Shadows = false; l.Parent = lamp
part("LampChain", Vector3.new(0.15, 2.2, 0.15), CFrame.new(floor.Position.X, floor.Position.Y + 11.2, floor.Position.Z), Color3.fromRGB(30, 28, 26), Enum.Material.Metal)
-- the sign over the porch
local sign = part("VipSign", Vector3.new(0.5, 3.4, 9), CFrame.new(porchRoof.Position.X - porchRoof.Size.Z / 2 + 0.2, porchRoof.Position.Y + 2.2, dcf.Position.Z), Color3.fromRGB(34, 24, 20), Enum.Material.WoodPlanks)
part("VipSignTrim", Vector3.new(0.3, 3.9, 9.5), CFrame.new(sign.Position.X + 0.2, sign.Position.Y, sign.Position.Z), GOLD, Enum.Material.Metal)
local sg = Instance.new("SurfaceGui")
sg.Face = Enum.NormalId.Left -- the -X side, towards the middle of the park
sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; sg.PixelsPerStud = 40; sg.LightInfluence = 0; sg.Brightness = 1.6
sg.Parent = sign
local t = Instance.new("TextLabel")
t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 1); t.Font = Enum.Font.PermanentMarker; t.TextScaled = true
t.Text = "VIP"; t.TextColor3 = Color3.fromRGB(255, 205, 60); t.TextStrokeColor3 = Color3.fromRGB(60, 36, 4); t.TextStrokeTransparency = 0
t.Parent = sg
local glow = Instance.new("PointLight"); glow.Color = Color3.fromRGB(255, 200, 80); glow.Range = 14; glow.Brightness = 1.2; glow.Shadows = false; glow.Parent = sign

local cf2, s2 = m:GetBoundingBox()
local names = {}
for _, d in m:GetChildren() do names[d.Name] = (names[d.Name] or 0) + 1 end
local list = {}
for k, v in names do table.insert(list, v .. "x" .. k) end
return string.format("VipCabin at %.1f,%.1f,%.1f size %.1f,%.1f,%.1f; door at %s size %s; floor %s size %s; %s", cf2.Position.X, cf2.Position.Y, cf2.Position.Z, s2.X, s2.Y, s2.Z, tostring(door.Position), tostring(door.Size), tostring(floor.Position), tostring(floor.Size), table.concat(list, " "))
