-- The park's two FORM sellers (Shared/Forms, Server/Forms) and the train you board for every trip. Edit mode,
-- standalone: python3 tools/studio.py luau Edit tools/build/sellers.luau. Re-running replaces what it built.
--   * DOC MERCY (workspace.Lobby.Sellers.DocMercy): a struck-off ghost doctor selling jars of ECTOPLASM (glowing
--     ghost goo) out of the back of a rusted old ambulance (rear doors open, specimen jars on the shelves, a glass
--     tank of bubbling goo, a bare bulb), a folding table of goo jars in front. (No syringes, pills or drug-like
--     props anywhere: Roblox moderation, see CLAUDE.md.)
--   * MOTHER MOTH (workspace.Lobby.Sellers.MotherMoth): a hunched witch with a moth-wing cloak stirring a cauldron
--     in front of her crooked hut by the pond (jars, hanging herbs, a lantern with moths round it).
--   Each has a "Prompt" part (Server/Forms puts the ProximityPrompt on it).
--   * workspace.Lobby.Station.ParkedTrain: a copy of ReplicatedStorage.Intro.Train standing at the platform, its
--     "BoardPrompt" part by the door (Server/Lobby: "Board the train" opens the PLAY panel).
-- The two east queue cabins (Room4a / Room4b) make room for the sellers, and the queue pads and signs of the other
-- cabins go (the train is the only way to the maps now): all of it is kept in ServerStorage.LobbyBackup.
-- All hand-built from plain parts in the park's PS2 look: chunky, few parts, dark flat colours, PS2_* variants.
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local M = Enum.Material
local lobby = workspace:WaitForChild("Lobby")
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local A = CFrame.Angles
local rng = Random.new(7)

-- BACKUP: the two east cabins whole, the pads / signs of the others
local backup = SS:FindFirstChild("LobbyBackup") or Instance.new("Folder")
backup.Name = "LobbyBackup"; backup.Parent = SS
local rooms = lobby:FindFirstChild("Rooms")
if rooms then
	for _, r in rooms:GetChildren() do
		if r.Name == "Room4a" or r.Name == "Room4b" then
			r.Parent = backup
		else
			local keep = backup:FindFirstChild(r.Name .. "_Pad") or Instance.new("Folder")
			keep.Name = r.Name .. "_Pad"; keep.Parent = backup
			for _, c in r:GetChildren() do
				if c.Name == "Pad" or c.Name == "PadGlow" or c.Name == "Sign" or c.Name == "SignPost" or c.Name == "SignLamp" then c.Parent = keep end
			end
		end
	end
end

local sellers = lobby:FindFirstChild("Sellers")
if sellers then sellers:Destroy() end
sellers = Instance.new("Folder"); sellers.Name = "Sellers"; sellers.Parent = lobby

local function groundAt(x: number, z: number): number
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	local g = lobby:FindFirstChild("Ground")
	rp.FilterDescendantsInstances = { g or lobby }
	local r = workspace:Raycast(Vector3.new(x, 60, z), Vector3.new(0, -120, 0), rp)
	return r and r.Position.Y or 0.5
end

local cur: Instance = sellers
local function P(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, mv: string?, solid: boolean?, shape: Enum.PartType?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat or M.SmoothPlastic
	if mv then p.MaterialVariant = mv end
	if shape then p.Shape = shape end
	p.Anchored = true; p.CanCollide = solid == true; p.CanQuery = solid == true; p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = cur
	return p
end
local function glow(p: BasePart, color: Color3, range: number, bright: number)
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range; l.Brightness = bright; l.Shadows = false; l.Parent = p
	return l
end
local function sign(parent: Instance, cf: CFrame, w: number, h: number, title: string, sub: string, fg: Color3)
	local old = cur
	cur = parent
	local board = P("SignBoard", Vector3.new(w, h, 0.3), cf, C(70, 52, 38), M.Wood, "PS2_DarkBeam", true)
	for _, s in { -1, 1 } do P("SignPost", Vector3.new(0.4, h + 3.5, 0.4), cf * CFrame.new(s * (w / 2 - 0.4), -1.7, 0.25), C(54, 40, 30), M.Wood, "PS2_DarkBeam") end
	local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.PixelsPerStud = 40; sg.LightInfluence = 0.6; sg.Parent = board
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 0.62); t.Text = title; t.TextScaled = true
	t.Font = Enum.Font.Creepster; t.TextColor3 = fg; t.Parent = sg
	local s2 = Instance.new("TextLabel"); s2.BackgroundTransparency = 1; s2.Position = UDim2.fromScale(0, 0.6); s2.Size = UDim2.fromScale(1, 0.36); s2.Text = sub
	s2.TextScaled = true; s2.Font = Enum.Font.SpecialElite; s2.TextColor3 = C(220, 210, 190); s2.Parent = sg
	cur = old
end

-- A BLOCKY PERSON (the park's PS2 look): o = colours / extras; returns the model. cf = feet on the ground, facing -Z.
local function person(name: string, cf: CFrame, o: { [string]: any }): Model
	local m = Instance.new("Model"); m.Name = name; m.Parent = cur
	local old = cur
	cur = m
	local hunch = o.hunch or 0
	local skin = o.skin
	-- legs + feet
	for _, s in { -1, 1 } do
		P("Leg", Vector3.new(0.85, 2.9, 0.9), cf * CFrame.new(s * 0.55, 1.65, 0), o.legs, M.Fabric)
		P("Shoe", Vector3.new(0.95, 0.45, 1.35), cf * CFrame.new(s * 0.55, 0.22, -0.2), o.shoes, M.SmoothPlastic)
	end
	local hip = cf * CFrame.new(0, 3.1, 0)
	local chest = hip * A(-hunch, 0, 0) * CFrame.new(0, 1.35, 0)
	P("Torso", Vector3.new(2.1, 2.7, 1.15), chest, o.top, M.Fabric)
	if o.coat then
		-- a long coat to the knees, open at the front
		for _, s in { -1, 1 } do
			P("CoatSkirt", Vector3.new(1.05, 2.6, 1.25), hip * CFrame.new(s * 0.55, -1.0, 0.02) * A(0, 0, s * 0.06), o.coat, M.Fabric)
		end
		P("CoatBack", Vector3.new(2.2, 2.8, 0.2), chest * CFrame.new(0, 0, 0.6), o.coat, M.Fabric)
	end
	if o.robe then
		-- a robe to the ground, widening, ragged at the hem
		P("Robe", Vector3.new(2.3, 2.9, 1.5), hip * CFrame.new(0, -1.35, 0), o.robe, M.Fabric)
		P("RobeHem", Vector3.new(2.7, 0.7, 1.9), cf * CFrame.new(0, 0.35, 0), o.robe:Lerp(C(0, 0, 0), 0.2), M.Fabric)
		for i = -2, 2 do P("Rag", Vector3.new(0.4, 0.55, 0.12), cf * CFrame.new(i * 0.5, 0.25, -0.98) * A(0, 0, rng:NextNumber(-0.3, 0.3)), o.robe:Lerp(C(0, 0, 0), 0.3), M.Fabric) end
	end
	-- arms: o.armL / o.armR = shoulder rotations; hands at the end
	local function arm(s: number, rot: CFrame): CFrame
		local sh = chest * CFrame.new(s * 1.35, 1.05, 0) * rot
		P("Arm", Vector3.new(0.8, 2.6, 0.8), sh * CFrame.new(0, -1.2, 0), o.sleeve or o.top, M.Fabric)
		local hand = sh * CFrame.new(0, -2.65, 0)
		P("Hand", Vector3.new(0.72, 0.75, 0.72), hand, o.hands or skin)
		return hand
	end
	local hl = arm(-1, o.armL or A(0.2, 0, 0.08))
	local hr = arm(1, o.armR or A(0.2, 0, -0.08))
	-- head
	local neck = chest * CFrame.new(0, 1.35, 0) * A(hunch * 0.6 + (o.headTilt or 0), 0, 0)
	P("Neck", Vector3.new(0.6, 0.4, 0.6), neck * CFrame.new(0, 0.15, 0), skin)
	local head = neck * CFrame.new(0, 1.15, -0.05)
	P("Head", Vector3.new(1.45, 1.6, 1.4), head, skin)
	cur = old
	m:SetAttribute("Built", true)
	return m, head, hl, hr, chest
end

---------------------------------------------------------------------------------------------------------------
-- DOC MERCY: the ambulance at the south-east cabin's spot, its open back toward the path (+Z)
---------------------------------------------------------------------------------------------------------------
do
	local doc = Instance.new("Model"); doc.Name = "DocMercy"; doc.Parent = sellers
	cur = doc
	local gx, gz = 66, 930
	local gy = groundAt(gx, gz)
	-- the van faces -Z (its cab toward the trees), its back doors open toward the path; a flat front-left tyre
	local base = CFrame.new(gx, gy, gz) * A(0, 0, 0.025)
	local WHITE, STRIPE, RUST, DARK = C(196, 190, 172), C(196, 92, 34), C(96, 56, 34), C(28, 26, 26)
	local vanBody = P("Body", Vector3.new(9, 8.6, 14), base * CFrame.new(0, 5.2, 2), WHITE, M.Metal, nil, true)
	local _ = vanBody
	P("Stripe", Vector3.new(9.08, 0.9, 14.05), base * CFrame.new(0, 5.6, 2), STRIPE, M.SmoothPlastic)
	P("StripeLow", Vector3.new(9.08, 0.35, 14.05), base * CFrame.new(0, 4.75, 2), STRIPE:Lerp(C(0, 0, 0), 0.3), M.SmoothPlastic)
	P("RoofLip", Vector3.new(9.3, 0.4, 14.3), base * CFrame.new(0, 9.6, 2), WHITE:Lerp(C(0, 0, 0), 0.15), M.Metal)
	-- the cab (lower, at the front: -Z)
	P("Cab", Vector3.new(8.6, 6.4, 5.4), base * CFrame.new(0, 4.1, -7.6), WHITE, M.Metal, nil, true)
	P("Hood", Vector3.new(8.4, 1.4, 2.6), base * CFrame.new(0, 3.2, -11.4), WHITE:Lerp(C(0, 0, 0), 0.08), M.Metal, nil, true)
	P("Windshield", Vector3.new(7.4, 2.4, 0.2), base * CFrame.new(0, 5.9, -10.25) * A(-0.25, 0, 0), C(30, 38, 44), M.Glass)
	for _, s in { -1, 1 } do
		P("SideWindow", Vector3.new(0.12, 2.2, 3.2), base * CFrame.new(s * 4.33, 5.8, -7.8), C(30, 38, 44), M.Glass)
		local hlp = P("Headlight", Vector3.new(1.3, 1, 0.3), base * CFrame.new(s * 3.1, 3.1, -12.75), C(220, 210, 150), M.Neon)
		if s > 0 then hlp.Color = C(60, 56, 50); hlp.Material = M.Glass end -- (one is out)
		P("SideStripe", Vector3.new(8.7, 0.9, 5.45), base * CFrame.new(0, 5.6, -7.6), STRIPE, M.SmoothPlastic)
	end
	P("Grille", Vector3.new(4.2, 1.3, 0.25), base * CFrame.new(0, 2.9, -12.75), DARK, M.Metal)
	P("Bumper", Vector3.new(9, 0.7, 0.7), base * CFrame.new(0, 1.7, -12.9), C(110, 106, 100), M.Metal)
	P("RearBumper", Vector3.new(9, 0.7, 0.7), base * CFrame.new(0, 1.3, 9.2), C(110, 106, 100), M.Metal)
	P("RearStep", Vector3.new(4, 0.35, 1.4), base * CFrame.new(0, 1.0, 9.6), C(80, 78, 74), M.DiamondPlate)
	-- wheels (the front left one flat)
	for _, w in { { -4.3, -9.2, 1.6 }, { 4.3, -9.2, 1.6 }, { -4.3, 5.8, 1.6 }, { 4.3, 5.8, 1.6 } } do
		local flat = w[1] < 0 and w[2] < 0
		P("Tyre", Vector3.new(1.3, flat and 2.6 or 3.2, 3.2), base * CFrame.new(w[1], flat and 1.1 or w[3], w[2]) * A(0, 0, math.pi / 2), DARK, M.Rubber, nil, false, Enum.PartType.Cylinder)
		P("Hub", Vector3.new(1.36, 1.3, 1.3), base * CFrame.new(w[1], flat and 1.1 or w[3], w[2]) * A(0, 0, math.pi / 2), C(120, 116, 110), M.Metal, nil, false, Enum.PartType.Cylinder)
	end
	-- rust and grime
	for i = 1, 9 do
		local s = i % 2 == 0 and 1 or -1
		P("Rust", Vector3.new(0.1, rng:NextNumber(0.6, 1.8), rng:NextNumber(0.8, 2.6)), base * CFrame.new(s * 4.52, rng:NextNumber(1.6, 8.6), rng:NextNumber(-4, 8.5)), RUST, M.CorrodedMetal)
	end
	-- the light bar on the roof: one red lamp still glowing, the other smashed
	P("LightBar", Vector3.new(4.2, 0.6, 1.2), base * CFrame.new(0, 10.1, -4.6), DARK, M.Metal)
	local red = P("Lamp", Vector3.new(1.4, 0.7, 1.0), base * CFrame.new(-1.3, 10.5, -4.6), C(200, 30, 30), M.Neon)
	glow(red, C(255, 40, 30), 14, 1.2)
	P("LampBroken", Vector3.new(1.4, 0.35, 1.0), base * CFrame.new(1.3, 10.35, -4.6), C(70, 70, 76), M.Glass)
	-- the open back: two doors swung out, the inside lit by a bare bulb
	for _, s in { -1, 1 } do
		local hinge = base * CFrame.new(s * 4.4, 5.2, 9.05) * A(0, s * -1.9, 0)
		P("RearDoor", Vector3.new(4.3, 8, 0.25), hinge * CFrame.new(-s * 2.15, 0, 0), WHITE, M.Metal, nil, true)
		P("DoorWindow", Vector3.new(2.4, 2, 0.28), hinge * CFrame.new(-s * 2.2, 1.8, 0), C(30, 38, 44), M.Glass)
		P("DoorStripe", Vector3.new(4.3, 0.9, 0.3), hinge * CFrame.new(-s * 2.15, 0.4, 0), STRIPE, M.SmoothPlastic)
	end
	P("Inside", Vector3.new(8.4, 0.2, 13), base * CFrame.new(0, 1.2, 2), C(60, 66, 62), M.DiamondPlate)
	P("InsideBack", Vector3.new(8.4, 8, 0.2), base * CFrame.new(0, 5.2, 8.92), C(30, 34, 32), M.SmoothPlastic).Transparency = 1
	-- shelves on both inner walls, with bottles and boxes
	for _, s in { -1, 1 } do
		for k = 0, 2 do
			local y = 3.2 + k * 2.1
			P("Shelf", Vector3.new(1.6, 0.18, 9), base * CFrame.new(s * 3.4, y, 3), C(150, 150, 150), M.Metal)
			for j = 1, 6 do
				-- specimen jars: wide glass, something murky floating in each (goo, an eye, a claw)
				local col = ({ C(200, 240, 170), C(110, 220, 90), C(190, 90, 240), C(255, 60, 60), C(170, 200, 150) })[rng:NextInteger(1, 5)]
				local jy = y + 0.09 + 0.45
				local jz = -1 + j * 1.3
				local g = P("SpecimenJar", Vector3.new(0.85, 0.9, 0.85), base * CFrame.new(s * 3.4, jy, jz), C(200, 220, 210), M.Glass)
				g.Transparency = 0.45
				P("Specimen", Vector3.new(0.6, 0.65, 0.6), base * CFrame.new(s * 3.4, jy - 0.06, jz), col, j % 2 == 0 and M.Neon or M.SmoothPlastic).Transparency = 0.2
				P("JarLid", Vector3.new(0.9, 0.12, 0.9), base * CFrame.new(s * 3.4, jy + 0.5, jz), C(70, 66, 60), M.Metal)
			end
		end
	end
	-- the gurney inside, a sheet over something
	P("Gurney", Vector3.new(2.6, 0.3, 6.5), base * CFrame.new(-0.5, 3.0, 4), C(140, 140, 144), M.Metal)
	P("Sheet", Vector3.new(2.5, 0.9, 5.2), base * CFrame.new(-0.5, 3.6, 4.3), C(200, 196, 188), M.Fabric)
	P("SheetStain", Vector3.new(1.2, 0.05, 1.6), base * CFrame.new(-0.3, 4.07, 3.6), C(110, 20, 18), M.Fabric)
	-- the bare bulb (sickly green-white)
	local bulb = P("Bulb", Vector3.new(0.5, 0.6, 0.5), base * CFrame.new(0, 8.6, 5), C(220, 240, 200), M.Neon)
	glow(bulb, C(210, 240, 190), 18, 1.6)
	P("Cord", Vector3.new(0.06, 0.9, 0.06), base * CFrame.new(0, 9.2, 5), DARK, M.SmoothPlastic)
	-- a tall glass tank of ectoplasm by the doors, bubbling, a hose to a hand pump
	P("TankBase", Vector3.new(2.4, 0.6, 2.4), base * CFrame.new(2.4, 1.6, 7.2), C(60, 60, 64), M.Metal)
	P("TankTop", Vector3.new(2.4, 0.5, 2.4), base * CFrame.new(2.4, 6.9, 7.2), C(60, 60, 64), M.Metal)
	P("TankGlass", Vector3.new(2.1, 4.9, 2.1), base * CFrame.new(2.4, 4.3, 7.2), C(200, 230, 210), M.Glass).Transparency = 0.55
	local goo = P("TankGoo", Vector3.new(1.8, 3.6, 1.8), base * CFrame.new(2.4, 3.65, 7.2), C(110, 220, 90), M.Neon)
	goo.Transparency = 0.2
	glow(goo, C(130, 230, 100), 12, 1)
	for k = 1, 4 do P("TankBubble", Vector3.one * 0.3, base * CFrame.new(2.4 + rng:NextNumber(-0.6, 0.6), 2.6 + k * 0.8, 7.2 + rng:NextNumber(-0.6, 0.6)), C(190, 255, 160), M.Neon, nil, false, Enum.PartType.Ball) end
	P("Hose", Vector3.new(0.25, 0.25, 3), base * CFrame.new(2.4, 7.2, 5.6) * A(0.5, 0, 0), C(40, 40, 40), M.Rubber)
	-- the counter: a folding table on the path side, a row of goo jars, a cash tin, a clipboard
	local tcf = base * CFrame.new(0, 0, 13.2)
	P("TableTop", Vector3.new(7, 0.3, 2.6), tcf * CFrame.new(0, 3.2, 0), C(120, 120, 116), M.Metal, nil, true)
	for _, s in { -1, 1 } do P("TableLeg", Vector3.new(0.2, 3.1, 2.2), tcf * CFrame.new(s * 3.1, 1.6, 0), C(80, 80, 80), M.Metal) end
	for i = 0, 3 do
		-- the four jars he sells (Shared/Forms: pale, fresh, poltergeist, banshee), each glowing its colour
		local col = ({ C(200, 240, 170), C(110, 220, 90), C(190, 90, 240), C(255, 60, 60) })[i + 1]
		local jx = -2.7 + i * 1.1
		local g = P("Jar", Vector3.new(0.8, 0.95, 0.8), tcf * CFrame.new(jx, 3.83, -0.2), C(210, 228, 220), M.Glass)
		g.Transparency = 0.5
		local goo2 = P("Goo", Vector3.new(0.66, 0.75, 0.66), tcf * CFrame.new(jx, 3.78, -0.2), col, M.Neon)
		goo2.Transparency = 0.15
		P("Lid", Vector3.new(0.86, 0.14, 0.86), tcf * CFrame.new(jx, 4.37, -0.2), C(70, 66, 60), M.Metal)
		if i == 3 then glow(goo2, col, 8, 0.8) end
	end
	P("CashTin", Vector3.new(1.4, 0.7, 1), tcf * CFrame.new(1.6, 3.7, 0.2), C(60, 90, 60), M.Metal)
	P("Clipboard", Vector3.new(1.1, 0.08, 1.5), tcf * CFrame.new(2.8, 3.38, -0.1) * A(0, 0.3, 0), C(150, 110, 70), M.Wood)
	P("Paper", Vector3.new(0.9, 0.02, 1.2), tcf * CFrame.new(2.8, 3.43, -0.1) * A(0, 0.3, 0), C(225, 220, 205), M.SmoothPlastic)
	local prompt = P("Prompt", Vector3.new(7, 4, 3), tcf * CFrame.new(0, 3.5, 1.4), C(255, 255, 255))
	prompt.Transparency = 1
	-- DOC MERCY himself, behind the table at the van's back step: a long stained white coat, rubber gloves, a
	-- surgical mask, round black glasses, a head mirror, grey slicked-back hair, holding a jar of goo up to the light
	local COAT = C(206, 204, 194)
	local _m, head, _hl, hr, chest = person("Doc", tcf * CFrame.new(0, 0, -2.4) * A(0, math.pi, 0), {
		skin = C(214, 190, 170), legs = C(40, 40, 46), shoes = C(24, 22, 22), top = C(120, 150, 140), coat = COAT, sleeve = COAT,
		hands = C(222, 210, 150), hunch = 0.12, armL = A(0.5, 0, 0.12), armR = A(0.95, 0, -0.18), headTilt = -0.05,
	})
	cur = doc:FindFirstChild("Doc") :: Model
	-- the coat front panels and its blood
	for _, s in { -1, 1 } do P("Lapel", Vector3.new(0.85, 2.7, 0.15), chest * CFrame.new(s * 0.65, 0, -0.62), COAT, M.Fabric) end
	P("Tie", Vector3.new(0.3, 1.6, 0.1), chest * CFrame.new(0, 0.3, -0.62), C(110, 26, 30), M.Fabric)
	for i = 1, 6 do
		P("Blood", Vector3.new(rng:NextNumber(0.3, 0.8), rng:NextNumber(0.3, 0.9), 0.05), chest * CFrame.new(rng:NextNumber(-0.9, 0.9), rng:NextNumber(-1.2, 0.8), -0.7), C(120, 16, 16), M.SmoothPlastic)
	end
	P("Pocket", Vector3.new(0.6, 0.5, 0.06), chest * CFrame.new(-0.6, 0.5, -0.71), COAT:Lerp(C(0, 0, 0), 0.1), M.Fabric)
	P("Pen", Vector3.new(0.08, 0.5, 0.08), chest * CFrame.new(-0.45, 0.7, -0.74), C(30, 30, 120), M.SmoothPlastic)
	-- the face: mask, glasses, head mirror, hair
	P("Mask", Vector3.new(1.5, 0.75, 0.2), head * CFrame.new(0, -0.35, -0.72), C(150, 190, 200), M.Fabric)
	for _, s in { -1, 1 } do
		P("MaskStrap", Vector3.new(0.05, 0.12, 1.4), head * CFrame.new(s * 0.75, -0.2, 0), C(200, 210, 210), M.Fabric)
		P("Lens", Vector3.new(0.48, 0.42, 0.06), head * CFrame.new(s * 0.36, 0.2, -0.74), C(20, 20, 22), M.Glass)
		P("Rim", Vector3.new(0.56, 0.5, 0.04), head * CFrame.new(s * 0.36, 0.2, -0.71), C(10, 10, 10), M.Metal)
		P("Glint", Vector3.new(0.12, 0.08, 0.02), head * CFrame.new(s * 0.36 + 0.1, 0.3, -0.78), C(220, 255, 220), M.Neon)
	end
	P("Bridge", Vector3.new(0.3, 0.06, 0.05), head * CFrame.new(0, 0.26, -0.74), C(10, 10, 10), M.Metal)
	P("HeadBand", Vector3.new(1.5, 0.25, 1.45), head * CFrame.new(0, 0.62, 0), C(30, 30, 30), M.Fabric)
	local mirror = P("HeadMirror", Vector3.new(0.75, 0.75, 0.12), head * CFrame.new(0.2, 0.75, -0.78) * A(-0.3, 0, 0), C(210, 220, 225), M.Metal, nil, false, Enum.PartType.Cylinder)
	mirror.Size = Vector3.new(0.1, 0.8, 0.8); mirror.CFrame = head * CFrame.new(0.2, 0.78, -0.8) * A(0, math.pi / 2, 0)
	P("Hair", Vector3.new(1.55, 0.45, 1.5), head * CFrame.new(0, 0.92, 0.05), C(150, 150, 150), M.Fabric)
	P("HairBack", Vector3.new(1.55, 0.9, 0.3), head * CFrame.new(0, 0.5, 0.7), C(150, 150, 150), M.Fabric)
	for _, s in { -1, 1 } do P("Ear", Vector3.new(0.18, 0.4, 0.3), head * CFrame.new(s * 0.78, 0.05, 0), C(214, 190, 170)) end
	-- the jar he holds up, the goo inside lighting his face from below
	local hj = hr * CFrame.new(0, 0.85, -0.1)
	P("HeldJar", Vector3.new(1.0, 1.2, 1.0), hj, C(210, 228, 220), M.Glass).Transparency = 0.5
	local hg = P("HeldGoo", Vector3.new(0.82, 0.9, 0.82), hj * CFrame.new(0, -0.08, 0), C(110, 220, 90), M.Neon)
	hg.Transparency = 0.15
	glow(hg, C(130, 230, 100), 9, 1)
	P("HeldLid", Vector3.new(1.05, 0.16, 1.05), hj * CFrame.new(0, 0.66, 0), C(70, 66, 60), M.Metal)
	cur = doc
	sign(doc, base * CFrame.new(-7.5, 4.5, 14) * A(0, math.pi + 0.35, 0), 6.5, 2.6, "DOC MERCY", "ECTOPLASM - FRESH TONIGHT", C(200, 230, 120))
	doc.WorldPivot = base
end

---------------------------------------------------------------------------------------------------------------
-- MOTHER MOTH: her hut at the north-east cabin's spot (by the pond), its front toward the path (-Z)
---------------------------------------------------------------------------------------------------------------
do
	local moth = Instance.new("Model"); moth.Name = "MotherMoth"; moth.Parent = sellers
	cur = moth
	local gx, gz = 64, 1072
	local gy = groundAt(gx, gz)
	local base = CFrame.new(gx, gy, gz) * A(0, 0.08, 0)
	local PLANK, PLANK2, MOSS, STONE = C(66, 52, 40), C(52, 42, 34), C(64, 80, 44), C(92, 90, 86)
	-- the crooked hut: plank walls (leaning a little), a steep mossy roof, a stone chimney
	local hut = base * CFrame.new(0, 0, 3) * A(0, 0, 0.03)
	P("Floor", Vector3.new(12, 0.6, 10), hut * CFrame.new(0, 0.3, 0), PLANK2, M.Wood, "PS2_DarkBeam", true)
	P("WallBack", Vector3.new(12, 8, 0.8), hut * CFrame.new(0, 4.5, 4.6), PLANK, M.WoodPlanks, "PS2_Siding", true)
	for _, s in { -1, 1 } do
		P("WallSide", Vector3.new(0.8, 8, 10), hut * CFrame.new(s * 5.6, 4.5, 0) * A(0, 0, s * 0.03), PLANK, M.WoodPlanks, "PS2_Siding", true)
		P("WallFront", Vector3.new(3.8, 8, 0.8), hut * CFrame.new(s * 3.9, 4.5, -4.6), PLANK, M.WoodPlanks, "PS2_Siding", true)
		P("Roof", Vector3.new(7.6, 0.7, 12.6), hut * CFrame.new(s * 3.3, 10.8, 0) * A(0, 0, s * -0.72), MOSS, M.Grass, nil, true)
		P("Gable", Vector3.new(0.6, 4.2, 4.2), hut * CFrame.new(0, 9.2, s * 4.6) * A(math.pi / 4, 0, 0) * A(0, 0, 0), PLANK2, M.WoodPlanks, "PS2_Siding")
		for k = 0, 3 do P("Corner", Vector3.new(0.9, 8.4, 0.9), hut * CFrame.new(s * 5.7, 4.4, k < 2 and -4.7 or 4.7), C(44, 34, 28), M.Wood, "PS2_DarkBeam") end
	end
	P("Lintel", Vector3.new(4.4, 2, 0.8), hut * CFrame.new(0, 7.5, -4.6), PLANK, M.WoodPlanks, "PS2_Siding", true)
	P("Door", Vector3.new(3.6, 6.4, 0.3), hut * CFrame.new(-1.0, 3.5, -5.2) * A(0, 0.9, 0) * CFrame.new(1.8, 0, 0), C(48, 36, 28), M.WoodPlanks, "PS2_DarkBeam", true)
	-- the dark inside, a green glow from the back
	P("Dark", Vector3.new(10, 7.6, 8.5), hut * CFrame.new(0, 4.4, 0), C(10, 12, 8), M.SmoothPlastic)
	local inGlow = P("InGlow", Vector3.new(1, 1, 1), hut * CFrame.new(0, 3, 1), C(120, 200, 80), M.Neon)
	inGlow.Transparency = 1
	glow(inGlow, C(130, 210, 90), 12, 1.2)
	-- the round window (a glowing pane) and the chimney with a thin smoke
	P("Window", Vector3.new(0.2, 1.8, 1.8), hut * CFrame.new(-5.95, 5.2, -1), C(150, 210, 90), M.Neon, nil, false, Enum.PartType.Cylinder).Transparency = 0.2
	P("Chimney", Vector3.new(2.2, 7, 2.2), hut * CFrame.new(3.8, 11, 2.5), STONE, M.Cobblestone, "PS2_Stone")
	local top = P("ChimneyTop", Vector3.new(2.6, 0.6, 2.6), hut * CFrame.new(3.8, 14.6, 2.5), STONE:Lerp(C(0, 0, 0), 0.2), M.Cobblestone, "PS2_Stone")
	local sm = Instance.new("ParticleEmitter")
	sm.Texture = "rbxasset://textures/particles/smoke_main.dds"; sm.Rate = 1.5; sm.Lifetime = NumberRange.new(3, 4); sm.Speed = NumberRange.new(2, 3)
	sm.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 3) })
	sm.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
	sm.Color = ColorSequence.new(C(90, 100, 80)); sm.EmissionDirection = Enum.NormalId.Top; sm.Parent = top
	-- herbs, bones and bottles hanging from the eave on strings
	for i = -2, 2 do
		local x = i * 1.9
		P("String", Vector3.new(0.05, 1.4, 0.05), hut * CFrame.new(x, 7.6, -5.6), C(90, 80, 60), M.Fabric)
		local kind = (i + 3) % 3
		if kind == 0 then P("Herbs", Vector3.new(0.6, 1.1, 0.6), hut * CFrame.new(x, 6.5, -5.6) * A(0, i, 0), C(80, 110, 50), M.Grass)
		elseif kind == 1 then P("Bone", Vector3.new(0.25, 1.2, 0.25), hut * CFrame.new(x, 6.4, -5.6) * A(0, 0, 0.3), C(220, 210, 180), M.SmoothPlastic)
		else P("Jar", Vector3.new(0.6, 0.8, 0.6), hut * CFrame.new(x, 6.5, -5.6), C(190, 120, 240), M.Neon).Transparency = 0.2 end
	end
	-- the shelf counter beside the door, full of jars
	local sh = base * CFrame.new(-5.5, 0, -4.5) * A(0, 0.2, 0)
	P("Counter", Vector3.new(5, 3, 1.8), sh * CFrame.new(0, 1.5, 0), PLANK2, M.WoodPlanks, "PS2_DarkBeam", true)
	P("CounterTop", Vector3.new(5.4, 0.3, 2.2), sh * CFrame.new(0, 3.15, 0), C(44, 34, 28), M.Wood, "PS2_DarkBeam")
	for j = 0, 5 do
		local col = ({ C(150, 170, 90), C(150, 190, 240), C(200, 70, 200), C(255, 60, 60), C(230, 220, 140), C(110, 200, 200) })[j + 1]
		local h = rng:NextNumber(0.7, 1.3)
		P("Jar", Vector3.new(0.6, h, 0.6), sh * CFrame.new(-2 + j * 0.8, 3.3 + h / 2, rng:NextNumber(-0.4, 0.4)), col, j % 2 == 0 and M.Neon or M.Glass).Transparency = 0.25
	end
	P("Skull", Vector3.new(0.9, 0.9, 1), sh * CFrame.new(1.6, 3.8, 0.3) * A(0, -0.4, 0), C(220, 212, 186), M.SmoothPlastic)
	for i = 0, 2 do
		local cnd = P("Candle", Vector3.new(0.3, 0.6 + i * 0.2, 0.3), sh * CFrame.new(-1.2 + i * 0.5, 3.6 + i * 0.1, 0.7), C(220, 210, 170), M.SmoothPlastic)
		local fl = P("Flame", Vector3.new(0.18, 0.3, 0.18), cnd.CFrame * CFrame.new(0, cnd.Size.Y / 2 + 0.15, 0), C(255, 190, 90), M.Neon)
		if i == 1 then glow(fl, C(255, 170, 90), 9, 0.8) end
	end
	-- THE CAULDRON in front of the hut, on three stones over a fire, bubbling green
	local cc = base * CFrame.new(1.5, 0, -7.5)
	for k = 0, 2 do
		local a = k * math.pi * 2 / 3
		P("Stone", Vector3.new(1.4, 1.1, 1.4), cc * CFrame.new(math.cos(a) * 2.1, 0.55, math.sin(a) * 2.1) * A(0, a, 0.2), STONE, M.Slate, "PS2_Stone", true)
	end
	for k = 0, 4 do
		local a = k * 1.3
		P("Log", Vector3.new(0.6, 0.6, 2.6), cc * CFrame.new(math.cos(a) * 0.6, 0.35, math.sin(a) * 0.6) * A(0, a, 0.15), C(60, 40, 28), M.Wood)
	end
	local fire = P("Fire", Vector3.new(1.6, 0.9, 1.6), cc * CFrame.new(0, 0.9, 0), C(255, 120, 30), M.Neon)
	fire.Transparency = 0.2
	glow(fire, C(255, 140, 60), 16, 1.6)
	local pot = P("Pot", Vector3.new(3.2, 3.6, 3.6), cc * CFrame.new(0, 2.9, 0) * A(0, 0, math.pi / 2), C(28, 28, 30), M.Metal, nil, true, Enum.PartType.Cylinder)
	pot.Size = Vector3.new(2.6, 3.6, 3.6)
	P("PotBelly", Vector3.new(3.9, 2.4, 3.9), cc * CFrame.new(0, 2.5, 0), C(30, 30, 32), M.Metal, nil, false, Enum.PartType.Ball)
	P("Rim", Vector3.new(0.4, 3.9, 3.9), cc * CFrame.new(0, 4.25, 0) * A(0, 0, math.pi / 2), C(40, 40, 42), M.Metal, nil, false, Enum.PartType.Cylinder)
	local brew = P("Brew", Vector3.new(0.2, 3.3, 3.3), cc * CFrame.new(0, 4.25, 0) * A(0, 0, math.pi / 2), C(110, 220, 70), M.Neon, nil, false, Enum.PartType.Cylinder)
	glow(brew, C(130, 230, 90), 14, 1.4)
	for k = 1, 5 do P("Bubble", Vector3.one * rng:NextNumber(0.3, 0.6), cc * CFrame.new(rng:NextNumber(-1.1, 1.1), 4.4, rng:NextNumber(-1.1, 1.1)), C(170, 250, 120), M.Neon, nil, false, Enum.PartType.Ball) end
	local steam = Instance.new("ParticleEmitter")
	steam.Texture = "rbxasset://textures/particles/smoke_main.dds"; steam.Rate = 2; steam.Lifetime = NumberRange.new(1.5, 2.2); steam.Speed = NumberRange.new(1.5, 2.5)
	steam.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 2.2) })
	steam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
	steam.Color = ColorSequence.new(C(150, 230, 110)); steam.LightEmission = 0.4; steam.EmissionDirection = Enum.NormalId.Top; steam.Parent = brew
	steam.EmissionDirection = Enum.NormalId.Right -- (the brew disc's axis is its X: "Right" is up here)
	local bub = Instance.new("Sound"); bub.Name = "Bubbling"; bub.SoundId = "rbxassetid://9120305560"; bub.Looped = true; bub.Volume = 0.35
	bub.RollOffMaxDistance = 40; bub.RollOffMinDistance = 6; bub.Playing = true; bub.Parent = brew
	-- the lantern on a crooked pole, moths round it (a few pale specks drifting)
	local lp = base * CFrame.new(5.5, 0, -7) * A(0, 0, -0.08)
	P("Pole", Vector3.new(0.5, 9, 0.5), lp * CFrame.new(0, 4.5, 0), C(50, 38, 30), M.Wood, "PS2_DarkBeam")
	P("Arm", Vector3.new(0.4, 0.4, 2.2), lp * CFrame.new(0, 8.8, -0.9), C(50, 38, 30), M.Wood, "PS2_DarkBeam")
	local lan = P("Lantern", Vector3.new(0.9, 1.2, 0.9), lp * CFrame.new(0, 7.8, -1.8), C(255, 220, 150), M.Neon)
	glow(lan, C(255, 210, 150), 18, 1.2)
	P("LanternCap", Vector3.new(1.1, 0.3, 1.1), lp * CFrame.new(0, 8.5, -1.8), C(30, 28, 26), M.Metal)
	local mo = Instance.new("ParticleEmitter")
	mo.Name = "Moths"; mo.Texture = "rbxasset://textures/particles/sparkles_main.dds"; mo.Rate = 2.5; mo.Lifetime = NumberRange.new(2, 3)
	mo.Speed = NumberRange.new(0.5, 1.2); mo.SpreadAngle = Vector2.new(180, 180); mo.RotSpeed = NumberRange.new(-200, 200)
	mo.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 0.15) })
	mo.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	mo.Color = ColorSequence.new(C(230, 220, 190)); mo.Acceleration = Vector3.new(0, 0.3, 0); mo.Parent = lan
	-- a broomstick against the wall, a black cat's eyes in the doorway
	P("Broom", Vector3.new(0.3, 6.5, 0.3), hut * CFrame.new(4.6, 3.3, -5.3) * A(0.1, 0, 0.25), C(110, 80, 50), M.Wood)
	P("Bristles", Vector3.new(1.0, 1.8, 0.8), hut * CFrame.new(5.35, 0.9, -5.6) * A(0.1, 0, 0.25), C(170, 140, 80), M.Grass)
	for _, s in { -1, 1 } do P("CatEye", Vector3.new(0.18, 0.12, 0.05), hut * CFrame.new(0.4 + s * 0.22, 1.4, -4.2), C(230, 230, 60), M.Neon) end
	local prompt = P("Prompt", Vector3.new(8, 4, 4), cc * CFrame.new(0, 3, -2.5), C(255, 255, 255))
	prompt.Transparency = 1
	-- MOTHER MOTH: hunched behind her cauldron, stirring it; a long ragged robe, a cloak of dusty moth wings, a wide
	-- crooked pointed hat, long grey hair, grey-green skin, a long nose, small glowing eyes
	local ROBE = C(46, 36, 44)
	local _m, head, hl, hr, chest = person("Moth", cc * CFrame.new(0, 0, 3.6), {
		skin = C(150, 160, 128), legs = ROBE, shoes = C(30, 24, 22), top = ROBE, robe = ROBE, sleeve = ROBE:Lerp(C(0, 0, 0), 0.15),
		hands = C(140, 150, 118), hunch = 0.45, armL = A(1.15, 0, 0.25), armR = A(1.1, 0, -0.3), headTilt = -0.25,
	})
	cur = moth:FindFirstChild("Moth") :: Model
	-- the moth-wing cloak: two big dusty wings on her back, patterned with eye spots
	for _, s in { -1, 1 } do
		local wcf = chest * CFrame.new(s * 1.1, -0.2, 0.8) * A(0.15, s * 0.5, s * 0.35)
		P("Wing", Vector3.new(3.4, 3.8, 0.15), wcf * CFrame.new(s * 1.2, 0, 0), C(150, 130, 100), M.Fabric)
		P("WingLow", Vector3.new(2.4, 2.4, 0.16), wcf * CFrame.new(s * 0.8, -2.4, 0.02) * A(0, 0, s * 0.3), C(130, 112, 88), M.Fabric)
		P("EyeSpot", Vector3.new(1.0, 1.0, 0.18), wcf * CFrame.new(s * 1.4, 0.5, 0.02), C(60, 40, 30), M.Fabric, nil, false, Enum.PartType.Cylinder).CFrame = wcf * CFrame.new(s * 1.4, 0.5, 0.05) * A(0, math.pi / 2, 0)
		P("EyeDot", Vector3.new(0.4, 0.4, 0.2), wcf * CFrame.new(s * 1.4, 0.5, 0.08), C(220, 200, 120), M.Neon).Transparency = 0.3
		P("WingEdge", Vector3.new(3.5, 0.2, 0.17), wcf * CFrame.new(s * 1.2, 1.85, 0), C(90, 76, 60), M.Fabric)
	end
	P("Shawl", Vector3.new(2.6, 1.0, 1.6), chest * CFrame.new(0, 1.0, 0), C(80, 70, 60), M.Fabric)
	-- the face: nose, glowing eyes, a wart, grey hair down to the shoulders
	P("Nose", Vector3.new(0.3, 0.35, 0.9), head * CFrame.new(0, -0.05, -0.9) * A(-0.35, 0, 0), C(140, 150, 118))
	P("Wart", Vector3.new(0.14, 0.14, 0.14), head * CFrame.new(0.12, 0.05, -1.3), C(110, 120, 90))
	for _, s in { -1, 1 } do
		P("Eye", Vector3.new(0.26, 0.14, 0.05), head * CFrame.new(s * 0.36, 0.28, -0.72), C(255, 240, 140), M.Neon)
		P("Brow", Vector3.new(0.45, 0.12, 0.1), head * CFrame.new(s * 0.36, 0.48, -0.72) * A(0, 0, s * 0.35), C(170, 170, 160), M.Fabric)
		P("HairSide", Vector3.new(0.4, 2.2, 1.3), head * CFrame.new(s * 0.85, -0.6, 0.15) * A(0, 0, s * 0.08), C(170, 170, 162), M.Fabric)
	end
	P("Mouth", Vector3.new(0.6, 0.08, 0.05), head * CFrame.new(0, -0.5, -0.72) * A(0, 0, 0.1), C(60, 40, 40))
	P("HairBack", Vector3.new(1.5, 2.4, 0.4), head * CFrame.new(0, -0.5, 0.7), C(170, 170, 162), M.Fabric)
	-- the hat: a wide floppy brim, a tall crooked cone in three tilted blocks, a band
	P("Brim", Vector3.new(3.6, 0.2, 3.6), head * CFrame.new(0, 0.85, 0) * A(-0.12, 0, 0.06), C(32, 26, 30), M.Fabric)
	P("HatBand", Vector3.new(1.65, 0.35, 1.6), head * CFrame.new(0, 1.05, 0), C(110, 60, 120), M.Fabric)
	local hc = head * CFrame.new(0, 1.0, 0)
	for k, sz in { 1.55, 1.1, 0.7, 0.35 } do
		hc = hc * CFrame.new(0, 0.55, 0) * A(0.12, 0, -0.18)
		P("HatCone", Vector3.new(sz, 0.75, sz), hc, C(32, 26, 30), M.Fabric)
		local _ = k
	end
	-- the ladle in both hands, down in the pot
	local lad = hr * CFrame.new(-0.4, -0.2, 0) * A(0.4, 0, 0.2)
	P("Ladle", Vector3.new(0.25, 4.2, 0.25), lad * CFrame.new(0, -1.6, 0), C(80, 58, 40), M.Wood)
	P("LadleCup", Vector3.new(0.8, 0.4, 0.8), lad * CFrame.new(0, -3.7, 0), C(60, 60, 62), M.Metal)
	local _ = hl
	cur = moth
	sign(moth, base * CFrame.new(-8, 4.5, -9) * A(0, 0.5, 0), 6.5, 2.6, "MOTHER MOTH", "POTIONS - BREWED TONIGHT", C(200, 140, 240))
	moth.WorldPivot = base
end

---------------------------------------------------------------------------------------------------------------
-- THE TRAIN waiting at the park's platform (the same pose the intro's train stops at)
---------------------------------------------------------------------------------------------------------------
local station = lobby:FindFirstChild("Station")
local tpl = RS:FindFirstChild("Intro") and RS.Intro:FindFirstChild("Train")
if station and tpl then
	local old = station:FindFirstChild("ParkedTrain") if old then old:Destroy() end
	local t = tpl:Clone()
	t.Name = "ParkedTrain"
	for _, d in t:GetDescendants() do
		if d:IsA("BasePart") then d.Anchored = true end
		if d:IsA("ParticleEmitter") then d.Enabled = false end
	end
	t.Parent = station
	local root = t.PrimaryPart
	local fl = t:FindFirstChild("CarFloor") :: BasePart?
	local floorY = fl and (root.CFrame:PointToObjectSpace(fl.Position).Y + fl.Size.Y / 2) or 1.2
	local dx = tonumber(t:GetAttribute("DoorX")) or 21.5
	local bp = Instance.new("Part")
	bp.Name = "BoardPrompt"; bp.Anchored = true; bp.CanCollide = false; bp.CanQuery = false; bp.CanTouch = false; bp.Transparency = 1
	bp.Size = Vector3.new(4, 6, 2)
	bp.CFrame = root.CFrame * CFrame.new(dx, floorY + 3, 3.3 + 1.2)
	bp.Parent = t
	-- a lamp over the door so the way in shows
	local lamp = Instance.new("Part")
	lamp.Name = "DoorLamp"; lamp.Anchored = true; lamp.CanCollide = false; lamp.CanQuery = false; lamp.CanTouch = false
	lamp.Size = Vector3.new(0.8, 0.5, 0.5); lamp.Material = M.Neon; lamp.Color = C(255, 210, 140)
	lamp.CFrame = root.CFrame * CFrame.new(dx, floorY + 7.6, 3.6)
	lamp.Parent = t
	glow(lamp, C(255, 200, 140), 14, 1.2)
end

local n = 0
for _, d in sellers:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return "sellers built: " .. n .. " parts; parked train: " .. tostring(station and station:FindFirstChild("ParkedTrain") ~= nil)
