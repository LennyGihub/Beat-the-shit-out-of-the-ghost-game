-- PS2 night park lobby at (0, 0, 1000): mud ground, dead trees, swings, lamps, 8 queue rooms (1-4 players), ult dealer.
local SSv = game:GetService("ServerStorage")
local A = SSv:WaitForChild("LobbyAssets")
local old = workspace:FindFirstChild("Lobby"); if old then old:Destroy() end
local L = Instance.new("Model"); L.Name = "Lobby"; L.Parent = workspace
local CX, CZ = 0, 1000
local rng = Random.new(77)
local MUD = st(M.Mud, nil, Color3.fromRGB(120, 104, 84))
local GRASS = st(M.Grass, nil, Color3.fromRGB(96, 98, 64))
local PUDDLE = st(M.Glass, nil, Color3.fromRGB(30, 34, 30))
local PLANK = st(M.WoodPlanks, "PS2_FloorPlanks2", Color3.fromRGB(105, 92, 78))
local IRON = st(M.Metal, nil, Color3.fromRGB(28, 28, 26))
for _, d in game:GetService("MaterialService"):GetDescendants() do
	if d:IsA("MaterialVariant") and (string.find(d.Name, "PS2_Mud") or string.find(d.Name, "PS2_DeadGrass")) then d.StudsPerTile = 14 end
end

-- put a model's bottom on y = 0 at (x, z)
local function plant(name: string, x: number, z: number, yaw: number, scale: number?): Model
	local m = (A:FindFirstChild(name) :: Model):Clone()
	if scale and scale ~= 1 then m:ScaleTo(scale) end
	m:PivotTo(CFrame.new(CX + x, 0, CZ + z) * CFrame.Angles(0, yaw, 0))
	local cf, sz = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + Vector3.new(0, (sz.Y / 2) - cf.Position.Y + 0.05, 0))
	for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true end end
	m.Parent = L
	return m
end

-- ground
local G = model(L, "Ground")
box(G, "Mud", CX - 140, -1, CZ - 140, CX + 140, 0.05, CZ + 140, MUD)
for i = 1, 26 do
	local x, z, w, d = rng:NextNumber(-125, 125), rng:NextNumber(-125, 125), rng:NextNumber(10, 34), rng:NextNumber(8, 30)
	box(G, "DeadGrass", CX + x - w / 2, 0, CZ + z - d / 2, CX + x + w / 2, 0.12, CZ + z + d / 2, GRASS, DECO)
end
for i = 1, 18 do
	local x, z, s = rng:NextNumber(-110, 110), rng:NextNumber(-110, 110), rng:NextNumber(3, 9)
	part(G, "Puddle", Vector3.new(0.06, s, s * rng:NextNumber(0.6, 1.4)), CFrame.new(CX + x, 0.1, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 3), math.pi / 2), PUDDLE, { shape = Enum.PartType.Cylinder, deco = true, t = 0.15 })
end
-- dirt path cross
box(G, "Path", CX - 8, 0.02, CZ - 125, CX + 8, 0.14, CZ + 125, st(M.Ground, nil, Color3.fromRGB(88, 76, 62)), DECO)
box(G, "Path", CX - 125, 0.02, CZ - 8, CX + 125, 0.14, CZ + 8, st(M.Ground, nil, Color3.fromRGB(88, 76, 62)), DECO)
-- perimeter iron fence + invisible wall
local fence = model(L, "Fence")
for _, side in { { "x", -130 }, { "x", 130 }, { "z", -130 }, { "z", 130 } } do
	for t = -130, 130, 4 do
		local x, z = side[1] == "x" and side[2] or t, side[1] == "z" and side[2] or t
		box(fence, "Bar", CX + x - 0.15, 0, CZ + z - 0.15, CX + x + 0.15, 6, CZ + z + 0.15, IRON, DECO)
	end
	if side[1] == "x" then
		box(fence, "Rail", CX + side[2] - 0.2, 5, CZ - 130, CX + side[2] + 0.2, 5.4, CZ + 130, IRON, DECO)
		box(fence, "Wall", CX + side[2] - 1, 0, CZ - 132, CX + side[2] + 1, 40, CZ + 132, IRON, { t = 1 })
	else
		box(fence, "Rail", CX - 130, 5, CZ + side[2] - 0.2, CX + 130, 5.4, CZ + side[2] + 0.2, IRON, DECO)
		box(fence, "Wall", CX - 132, 0, CZ + side[2] - 1, CX + 132, 40, CZ + side[2] + 1, IRON, { t = 1 })
	end
end

-- trees (like the picture: many bare dark trees in fog)
for i = 1, 46 do
	local a = rng:NextNumber(0, math.pi * 2)
	local r = rng:NextNumber(40, 122)
	local x, z = math.cos(a) * r, math.sin(a) * r
	if math.abs(x) > 12 and math.abs(z) > 12 then plant("DeadTreeA", x, z, rng:NextNumber(0, 6.28), rng:NextNumber(0.9, 1.6)) end
end
for _, p in { { -26, -20 }, { 28, 22 }, { -30, 26 }, { 24, -28 } } do plant("DeadTreeA", p[1], p[2], rng:NextNumber(0, 6), 1.3) end
-- swing sets and benches around the plaza
plant("SwingSet", -22, 0, math.pi / 2, 1.4)
plant("SwingSet", 22, -14, -math.pi / 2, 1.4)
plant("SwingSet", 30, 34, 0.4, 1.4)
for _, b in { { -14, 18, 0 }, { 14, 18, 0 }, { -14, -18, math.pi }, { 14, -18, math.pi }, { -40, 4, math.pi / 2 }, { 40, -4, -math.pi / 2 } } do
	plant("Bench", b[1], b[2], b[3], 1.1)
end
-- lamp posts along the paths with sickly yellow-green light
local LAMP = Color3.fromRGB(220, 230, 150)
for _, p in { { -11, -40 }, { 11, -80 }, { -11, 40 }, { 11, 80 }, { -40, 11 }, { -80, -11 }, { 40, -11 }, { 80, 11 }, { -11, -110 }, { 11, 110 } } do
	local m = plant("LampPost", p[1], p[2], 0, 2)
	local _, sz = m:GetBoundingBox()
	local g = box(m, "Glow", CX + p[1] - 0.6, sz.Y - 2.4, CZ + p[2] - 0.6, CX + p[1] + 0.6, sz.Y - 1.2, CZ + p[2] + 0.6, T.glow, { deco = true, t = 0.4, color = LAMP })
	light(g, 30, 0.8, LAMP, false)
end

-- soft fill lights so the mud and puddles read like the reference picture
for gx = -90, 90, 60 do
	for gz = -90, 90, 60 do
		local f = box(L, "FillLight", CX + gx - 0.5, 22, CZ + gz - 0.5, CX + gx + 0.5, 23, CZ + gz + 0.5, T.glow, { t = 1, deco = true })
		light(f, 60, 0.15, Color3.fromRGB(200, 210, 150), false)
	end
end

-- queue rooms: fenced yard + shack + glowing pad + sign
local rooms = model(L, "Rooms")
local defs = {
	{ "Room1a", 1, -66, 62 }, { "Room2a", 2, -22, 62 }, { "Room3a", 3, 22, 62 }, { "Room4a", 4, 66, 62 },
	{ "Room1b", 1, -66, -62 }, { "Room2b", 2, -22, -62 }, { "Room3b", 3, 22, -62 }, { "Room4b", 4, 66, -62 },
}
local ACCENT = { Color3.fromRGB(200, 196, 186), Color3.fromRGB(110, 200, 90), Color3.fromRGB(80, 150, 240), Color3.fromRGB(230, 90, 60) }
for _, d in defs do
	local name, size, x, z = d[1], d[2], d[3], d[4]
	local face = z > 0 and 0 or math.pi -- shack at the back, open side toward the plaza
	local r = model(rooms, name)
	r:SetAttribute("Size", size)
	local base = CFrame.new(CX + x, 0, CZ + z) * CFrame.Angles(0, face, 0)
	local pad = part(r, "Pad", Vector3.new(16, 0.5, 14), base * CFrame.new(0, 0.25, -2), PLANK)
	for _, e in { { 0, -7, 16, 0.4 }, { 0, 7, 16, 0.4 }, { -8, 0, 0.4, 14 }, { 8, 0, 0.4, 14 } } do
		part(r, "PadGlow", Vector3.new(e[3], 0.12, e[4]), base * CFrame.new(e[1], 0.55, -2 + e[2]), T.glow, { deco = true, color = ACCENT[size] })
	end
	-- low fence on the sides
	for _, sx in { -8.6, 8.6 } do
		for k = -6, 6, 2 do part(r, "Picket", Vector3.new(0.3, 3, 0.3), base * CFrame.new(sx, 1.5, -2 + k), T.trim) end
		part(r, "FenceRail", Vector3.new(0.25, 0.3, 14), base * CFrame.new(sx, 2.4, -2), T.trim)
	end
	local shack = plant("Shed", x, z + (z > 0 and 11 or -11), face + math.pi, 1)
	shack.Parent = r
	-- sign board on two posts
	-- posts stand behind the board (they used to poke through the text)
	for _, sx in { -4.6, 4.6 } do part(r, "SignPost", Vector3.new(0.5, 9, 0.5), base * CFrame.new(sx, 4.45, -9.0), T.trim) end
	local sign = part(r, "Sign", Vector3.new(11, 4.4, 0.4), base * CFrame.new(0, 8.2, -9.5), st(M.WoodPlanks, nil, Color3.fromRGB(70, 56, 44)))
	local sg = Instance.new("SurfaceGui"); sg.Name = "Gui"; sg.Face = Enum.NormalId.Front; sg.CanvasSize = Vector2.new(480, 180)
	sg.LightInfluence = 0; sg.Brightness = 1.2; sg.Parent = sign
	local function lbl(n, y, h, txt, color)
		local t = Instance.new("TextLabel"); t.Name = n; t.BackgroundTransparency = 1; t.Size = UDim2.new(0.94, 0, h, 0); t.Position = UDim2.new(0.03, 0, y, 0)
		t.Font = Enum.Font.PermanentMarker; t.TextScaled = true; t.Text = txt; t.TextColor3 = color; t.TextStrokeTransparency = 0.3; t.Rotation = -2; t.Parent = sg
	end
	lbl("Count", 0.04, 0.5, size .. " PLAYER" .. (size > 1 and "S" or ""), ACCENT[size])
	lbl("Status", 0.56, 0.4, "0 / " .. size, Color3.fromRGB(220, 210, 180))
	local back = sg:Clone(); back.Name = "GuiBack"; back.Face = Enum.NormalId.Back; back.Parent = sign -- readable from the pad
	local lampG = part(r, "SignLamp", Vector3.new(0.8, 0.8, 0.8), base * CFrame.new(0, 10.6, -9.9), T.glow, { deco = true, color = LAMP })
	light(lampG, 24, 0.8, LAMP)
end

-- the hooded ultimate dealer with his cart
local V = model(L, "UltVendor")
local vcf = CFrame.new(CX + 0, 0, CZ - 26) * CFrame.Angles(0, 0, 0) -- faces -Z? turn to face the plaza (+Z)
vcf = vcf * CFrame.Angles(0, math.pi, 0)
local ROBE = st(M.Fabric, nil, Color3.fromRGB(26, 22, 24))
b(V, vcf, "Robe", 3, 6, 2.2, 0, 3, 0, ROBE)
local torso = b(V, vcf, "Torso", 2.6, 2.4, 1.6, 0, 5.4, 0, ROBE)
b(V, vcf, "Hood", 2, 2.2, 2, 0, 7.4, 0.1, ROBE)
b(V, vcf, "Void", 1.4, 1.4, 0.2, 0, 7.2, -0.92, st(M.SmoothPlastic, nil, Color3.fromRGB(4, 4, 4)))
for _, ex in { -0.32, 0.32 } do b(V, vcf, "Eye", 0.25, 0.12, 0.1, ex, 7.4, -1.03, st(M.Neon, nil, Color3.fromRGB(255, 60, 30))) end
b(V, vcf, "Hand", 0.6, 0.6, 0.6, 1.2, 4.4, -0.9, st(M.SmoothPlastic, nil, Color3.fromRGB(150, 160, 150)))
local CART = st(M.WoodPlanks, nil, Color3.fromRGB(90, 66, 48))
b(V, vcf, "Cart", 8, 3, 3.6, 0, 2.2, -3.2, CART)
for _, sx in { -4.2, 4.2 } do cyl(V, vcf * CFrame.Angles(0, 0, 0), "Wheel", 3, 0.5, sx, 1.5, -3.2, IRON).CFrame = vcf * CFrame.new(sx, 1.5, -3.2) end
for _, sx in { -3.6, 3.6 } do b(V, vcf, "Pole", 0.3, 6, 0.3, sx, 6, -4.6, T.trim) end
b(V, vcf, "Canopy", 9, 0.4, 4.4, 0, 9, -3.6, st(M.Fabric, nil, Color3.fromRGB(110, 20, 24)))
local orbColors = { Color3.fromRGB(255, 80, 30), Color3.fromRGB(150, 210, 255), Color3.fromRGB(150, 60, 220), Color3.fromRGB(255, 230, 120), Color3.fromRGB(120, 255, 160) }
for i, c in orbColors do
	local o = ball(V, vcf, "Orb", 0.9, -3.2 + (i - 1) * 1.6, 4.3, -3.2, st(M.Neon, nil, c), DECO)
	light(o, 8, 0.5, c)
end
local vsign = b(V, vcf, "VendorSign", 7, 1.6, 0.3, 0, 8.1, -5.85, CART)
local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Back; sg.CanvasSize = Vector2.new(420, 96); sg.LightInfluence = 0.3; sg.Parent = vsign
local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 1); t.Font = Enum.Font.Creepster; t.TextScaled = true
t.Text = "ULTIMATES"; t.TextColor3 = Color3.fromRGB(255, 120, 60); t.TextStrokeTransparency = 0.3; t.Parent = sg
local vl = b(V, vcf, "Lantern", 0.8, 1, 0.8, 3.6, 7.6, -5, T.glow)
light(vl, 22, 0.8, Color3.fromRGB(255, 150, 70))
V.PrimaryPart = torso

-- spawn in the middle of the park
local sp = workspace:FindFirstChild("LobbySpawn") or Instance.new("SpawnLocation")
sp.Name = "LobbySpawn"; sp.Anchored = true; sp.Size = Vector3.new(10, 0.2, 10); sp.CFrame = CFrame.new(CX, 0.2, CZ + 10)
sp.Transparency = 1; sp.CanCollide = false; sp.Neutral = true; sp.Duration = 0
for _, c in sp:GetChildren() do if c:IsA("Decal") then c:Destroy() end end
sp.Parent = workspace
local ms = workspace:FindFirstChild("MatchSpawn") :: SpawnLocation?
if ms then ms.Neutral = true; ms.Duration = 0 end
return "lobby parts: " .. #L:GetDescendants()
