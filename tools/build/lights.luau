local Lighting = game:GetService("Lighting")
Lighting.ClockTime = 19.1
Lighting.Brightness = 1.4
Lighting.Ambient = Color3.fromRGB(30, 27, 25)
Lighting.OutdoorAmbient = Color3.fromRGB(105, 110, 138)
Lighting.EnvironmentDiffuseScale = 0.3
Lighting.EnvironmentSpecularScale = 0
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.6
Lighting.FogColor = Color3.fromRGB(14, 14, 20)
Lighting.FogStart = 60
Lighting.FogEnd = 420
pcall(function() Lighting.Technology = Enum.Technology.Future end)
for _, c in Lighting:GetChildren() do
	if c:IsA("PostEffect") or c:IsA("Atmosphere") or c:IsA("Sky") then c:Destroy() end
end
local cc = Instance.new("ColorCorrectionEffect"); cc.Name = "PS2Grade"
cc.Saturation = -0.38; cc.Contrast = 0.22; cc.Brightness = -0.04; cc.TintColor = Color3.fromRGB(255, 240, 226); cc.Parent = Lighting
local bl = Instance.new("BloomEffect"); bl.Intensity = 0.7; bl.Size = 30; bl.Threshold = 0.85; bl.Parent = Lighting
local atm = Instance.new("Atmosphere"); atm.Density = 0.12; atm.Offset = 0; atm.Color = Color3.fromRGB(58, 60, 78); atm.Decay = Color3.fromRGB(36, 36, 50); atm.Glare = 0; atm.Haze = 0.6; atm.Parent = Lighting
local sky = Instance.new("Sky"); sky.StarCount = 1500; sky.MoonAngularSize = 14; sky.CelestialBodiesShown = true; sky.Parent = Lighting

local bp = workspace:FindFirstChild("Baseplate")
if bp then
	bp.Material = Enum.Material.Grass; bp.Color = Color3.fromRGB(80, 86, 62)
	for _, c in bp:GetChildren() do if c:IsA("Texture") or c:IsA("Decal") then c:Destroy() end end
end

local root = getRoot("Mansion")
local L = fresh(root, "Lights")

local function sconce(x, y, z, face)
	local m = model(L, "Sconce")
	local cf = at(x, y, z, face)
	b(m, cf, "Plate", 0.9, 1.4, 0.2, 0, 0, 0.1, T.brass, DECO)
	b(m, cf, "Arm", 0.2, 0.2, 0.9, 0, -0.2, -0.45, T.brass, DECO)
	cyl(m, cf, "Shade", 1.1, 1, 0, 0.5, -1, T.shade, DECO)
	local g = ball(m, cf, "Bulb", 0.45, 0, 0.35, -1, T.glow, DECO)
	light(g, 18, 1.1)
end
local function hanging(x, yTop, len, z, big)
	local m = model(L, "HangingLamp")
	local cf = CFrame.new(x, yTop, z)
	cyl(m, cf, "Chain", 0.2, len, 0, -len / 2, 0, T.iron, DECO)
	cyl(m, cf, "Shade", big and 3 or 2.2, 1.4, 0, -len - 0.5, 0, T.shade, DECO)
	local g = ball(m, cf, "Bulb", 0.7, 0, -len - 1, 0, T.glow, DECO)
	light(g, big and 34 or 28, 1.4)
end
local function chandelier(x, yTop, len, z)
	local m = model(L, "Chandelier")
	local cf = CFrame.new(x, yTop, z)
	cyl(m, cf, "Chain", 0.3, len, 0, -len / 2, 0, T.iron, DECO)
	local y = -len
	ball(m, cf, "Hub", 1.6, 0, y, 0, T.brass, DECO)
	for i = 0, 9 do
		local ang = i / 10 * math.pi * 2
		local px, pz = math.cos(ang) * 3.4, math.sin(ang) * 3.4
		part(m, "Arm", Vector3.new(3.4, 0.25, 0.25), cf * CFrame.new(px / 2, y - 0.4, pz / 2) * CFrame.Angles(0, -ang, 0), T.iron, DECO)
		cyl(m, cf, "Cup", 0.7, 0.3, px, y - 0.4, pz, T.iron, DECO)
		cyl(m, cf, "Candle", 0.35, 1.1, px, y, pz, st(Enum.Material.SmoothPlastic, nil, Color3.fromRGB(235, 225, 200)), DECO)
		ball(m, cf, "Flame", 0.35, px, y + 0.8, pz, T.glow, DECO)
	end
	local g = ball(m, cf, "Core", 0.6, 0, y - 0.3, 0, T.glow, { t = 1, deco = true })
	light(g, 60, 1.3, Color3.fromRGB(255, 185, 130), true)
end

-- great hall
chandelier(0, 43, 13, 20)
chandelier(0, 43, 13, 44)
for _, z in { 0, 20, 40 } do sconce(-35.4, 12, z, "E") end
for _, z in { 22, 42 } do sconce(35.4, 12, z, "W") end
sconce(35.4, 18, 2, "W"); sconce(35.4, 27, -10, "W")
for _, x in { -30, -6, 6, 30 } do sconce(x, 10, -29.4, "S") end
for _, x in { -27, 0, 27 } do sconce(x, 31, -29.4, "S") end
for _, x in { -12, 12, -30, 30 } do sconce(x, 12, 57.75, "N") end
-- ground rooms
hanging(-57, 22, 3, 30, true); hanging(-57, 22, 3, -29, true)
hanging(-18, 22, 3, -44, false); hanging(18, 22, 3, -44, false)
hanging(57, 22, 3, 30, true); hanging(57, 22, 3, -29, true)
-- upper rooms
hanging(-63, 43, 3, 29); hanging(-63, 43, 3, -29); hanging(63, 43, 3, 29); hanging(63, 43, 3, -29)
hanging(-18, 43, 3, -44); hanging(18, 43, 3, -44)
-- upstairs corridors (dim, like an old hallway)
for _, z in { -45, -15, 15, 45 } do sconce(-47.4, 31, z, "E"); sconce(47.4, 31, z, "W") end
return "lights ok " .. #L:GetDescendants()
