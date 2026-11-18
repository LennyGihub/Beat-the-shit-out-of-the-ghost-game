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

-- A FIGURE (the park's PS2 look, but with real joints): legs with knees and shoes, a torso, arms that bend at the
-- shoulder and the elbow, hands with fingers, a head with a face. base = between the feet on the ground, facing -Z.
-- o: skin, legs, shoes, chest (the shirt), hunch (radians forward), armL / armR = { sh = CFrame rotation, el = bend },
-- curl = finger curl, height (scale ~1). Returns the model and the important frames (head, chest, hands, hips).
local function figure(name: string, base: CFrame, o: { [string]: any }): (Model, { [string]: CFrame })
	local m = Instance.new("Model"); m.Name = name; m.Parent = cur
	local old = cur
	cur = m
	local F = {}
	local skin = o.skin
	-- legs: thigh, shin, a shoe with a sole and a toe cap
	for _, s in { -1, 1 } do
		local hip = base * CFrame.new(s * 0.5, 3.05, 0) * (o.legRot and o.legRot(s) or CFrame.new())
		P("Thigh", Vector3.new(0.78, 1.6, 0.82), hip * CFrame.new(0, -0.78, 0), o.legs, M.Fabric)
		local knee = hip * CFrame.new(0, -1.55, 0)
		P("Shin", Vector3.new(0.68, 1.45, 0.72), knee * CFrame.new(0, -0.7, 0), o.legs, M.Fabric)
		local ank = knee * CFrame.new(0, -1.42, 0)
		P("Shoe", Vector3.new(0.78, 0.42, 1.3), ank * CFrame.new(0, -0.02, -0.25), o.shoes, M.SmoothPlastic)
		P("Sole", Vector3.new(0.82, 0.14, 1.36), ank * CFrame.new(0, -0.22, -0.25), C(20, 18, 16), M.Rubber)
		P("ToeCap", Vector3.new(0.7, 0.3, 0.3), ank * CFrame.new(0, -0.05, -0.85), (o.shoes :: Color3):Lerp(C(0, 0, 0), 0.25), M.SmoothPlastic)
	end
	-- hips and chest (leaning forward by `hunch`)
	local hips = base * CFrame.new(0, 3.1, 0)
	F.hips = hips
	P("Pelvis", Vector3.new(1.75, 0.8, 1.0), hips, o.legs, M.Fabric)
	local spine = hips * CFrame.new(0, 0.35, 0) * CFrame.Angles(-(o.hunch or 0), 0, 0)
	local chest = spine * CFrame.new(0, 1.25, 0)
	F.chest = chest
	P("Chest", Vector3.new(1.95, 2.4, 1.05), chest, o.chest, M.Fabric)
	P("Belt", Vector3.new(1.85, 0.3, 1.1), spine * CFrame.new(0, 0.05, 0), o.belt or C(40, 32, 26), M.Leather)
	-- arms: upper arm, elbow, forearm, a cuff, a hand with four fingers and a thumb
	for _, s in { -1, 1 } do
		local A0 = s < 0 and o.armL or o.armR
		local sh = chest * CFrame.new(s * 1.27, 0.95, 0) * (A0 and A0.sh or CFrame.new())
		P("Shoulder", Vector3.new(0.72, 0.6, 0.78), sh * CFrame.new(0, -0.1, 0), o.sleeve or o.chest, M.Fabric)
		P("UpperArm", Vector3.new(0.62, 1.45, 0.66), sh * CFrame.new(0, -0.78, 0), o.sleeve or o.chest, M.Fabric)
		local el = sh * CFrame.new(0, -1.48, 0) * CFrame.Angles(A0 and A0.el or 0.15, 0, 0)
		P("Forearm", Vector3.new(0.56, 1.35, 0.6), el * CFrame.new(0, -0.66, 0), o.sleeve or o.chest, M.Fabric)
		P("Cuff", Vector3.new(0.6, 0.24, 0.64), el * CFrame.new(0, -1.25, 0), o.cuff or (o.sleeve or o.chest), M.Fabric)
		local wr = el * CFrame.new(0, -1.38, 0)
		P("Palm", Vector3.new(0.5, 0.52, 0.26), wr * CFrame.new(0, -0.26, 0), o.hands or skin)
		local curl = o.curl or 0.5
		for i = 0, 3 do
			local f = wr * CFrame.new(-0.18 + i * 0.12, -0.52, 0) * CFrame.Angles(curl, 0, 0)
			P("Finger", Vector3.new(0.1, 0.34, 0.11), f * CFrame.new(0, -0.15, 0), o.hands or skin)
			if o.nails then P("Nail", Vector3.new(0.08, 0.16, 0.06), f * CFrame.new(0, -0.36, -0.03) * CFrame.Angles(0.4, 0, 0), o.nails) end
		end
		P("Thumb", Vector3.new(0.11, 0.3, 0.12), wr * CFrame.new(-s * 0.29, -0.3, -0.08) * CFrame.Angles(0.3, 0, -s * 0.5), o.hands or skin)
		F[s < 0 and "handL" or "handR"] = wr * CFrame.new(0, -0.45, 0)
	end
	-- neck and head: skull, jaw, nose, ears, eyes (white + pupil), brows, mouth
	local neck = chest * CFrame.new(0, 1.3, 0) * CFrame.Angles(o.headTilt or 0, o.headTurn or 0, o.headRoll or 0)
	P("Neck", Vector3.new(0.5, 0.45, 0.5), neck * CFrame.new(0, 0.1, 0), skin)
	local head = neck * CFrame.new(0, 0.95, -0.05)
	F.head = head
	P("Skull", Vector3.new(1.2, 1.25, 1.22), head * CFrame.new(0, 0.1, 0), skin)
	P("Jaw", Vector3.new(1.0, 0.5, 1.0), head * CFrame.new(0, -0.6, -0.08), skin)
	P("Nose", Vector3.new(0.2, (o.noseLen or 0.38), 0.24 + (o.noseOut or 0)), head * CFrame.new(0, -0.12, -0.68 - (o.noseOut or 0) / 2) * CFrame.Angles(o.noseTilt or 0, 0, 0), o.noseColor or skin)
	for _, s in { -1, 1 } do
		P("Ear", Vector3.new(0.14, 0.38, 0.28), head * CFrame.new(s * 0.65, 0.0, 0.05), skin)
		P("EyeWhite", Vector3.new(0.28, 0.16, 0.05), head * CFrame.new(s * 0.27, 0.16, -0.62), o.eyeWhite or C(226, 222, 206), o.eyeGlow and M.Neon or M.SmoothPlastic)
		P("Pupil", Vector3.new(0.11, 0.12, 0.04), head * CFrame.new(s * 0.25, 0.16, -0.645), o.pupil or C(20, 16, 14), o.eyeGlow and M.Neon or M.SmoothPlastic)
		P("Brow", Vector3.new(0.34, 0.09, 0.08), head * CFrame.new(s * 0.27, 0.34, -0.63) * CFrame.Angles(0, 0, s * (o.browTilt or 0.2)), o.brow or C(120, 116, 110))
		P("Cheek", Vector3.new(0.3, 0.2, 0.06), head * CFrame.new(s * 0.36, -0.12, -0.61), (skin :: Color3):Lerp(C(0, 0, 0), 0.12))
	end
	P("Mouth", Vector3.new(0.48, 0.07, 0.05), head * CFrame.new(0.04, -0.47, -0.62) * CFrame.Angles(0, 0, o.mouthTilt or 0.08), C(60, 30, 30))
	cur = old
	return m, F
end

---------------------------------------------------------------------------------------------------------------
-- DOC MERCY: the ambulance at the south-east cabin's spot, its open back toward the path (+Z), lit inside
---------------------------------------------------------------------------------------------------------------
do
	local doc = Instance.new("Model"); doc.Name = "DocMercy"; doc.Parent = sellers
	cur = doc
	local gx, gz = 66, 930
	local gy = groundAt(gx, gz)
	local base = CFrame.new(gx, gy, gz) * A(0, 0, 0.02)
	local WHITE, STRIPE, RUST, DARK = C(196, 190, 172), C(196, 92, 34), C(96, 56, 34), C(28, 26, 26)
	-- THE BOX at the back, hollow (floor, roof, two sides, the bulkhead), so the open doors show its lit inside
	P("Floor", Vector3.new(9, 0.4, 14), base * CFrame.new(0, 1.3, 2), C(70, 74, 70), M.DiamondPlate, nil, true)
	P("RoofPanel", Vector3.new(9.2, 0.4, 14.2), base * CFrame.new(0, 9.5, 2), WHITE, M.Metal, nil, true)
	for _, s in { -1, 1 } do
		P("SideWall", Vector3.new(0.35, 8, 14), base * CFrame.new(s * 4.4, 5.4, 2), WHITE, M.Metal, nil, true)
		P("Stripe", Vector3.new(0.4, 0.9, 14.02), base * CFrame.new(s * 4.42, 5.6, 2), STRIPE, M.SmoothPlastic)
		P("StripeLow", Vector3.new(0.4, 0.35, 14.02), base * CFrame.new(s * 4.42, 4.75, 2), STRIPE:Lerp(C(0, 0, 0), 0.3), M.SmoothPlastic)
		P("SideWindow", Vector3.new(0.42, 1.8, 3), base * CFrame.new(s * 4.42, 7.4, -1), C(40, 60, 54), M.Glass).Transparency = 0.3
		P("InnerSkin", Vector3.new(0.1, 7.6, 13.6), base * CFrame.new(s * 4.17, 5.4, 2), C(160, 170, 162), M.SmoothPlastic)
		for i = 1, 6 do
			P("Rust", Vector3.new(0.42, rng:NextNumber(0.6, 1.6), rng:NextNumber(0.8, 2.2)), base * CFrame.new(s * 4.44, rng:NextNumber(2, 8.6), rng:NextNumber(-4, 8.5)), RUST, M.CorrodedMetal)
		end
	end
	P("Bulkhead", Vector3.new(8.6, 8, 0.35), base * CFrame.new(0, 5.4, -4.9), C(150, 160, 152), M.SmoothPlastic, nil, true)
	P("RoofLip", Vector3.new(9.4, 0.35, 0.5), base * CFrame.new(0, 9.75, 9), C(160, 156, 140), M.Metal)
	-- the cab at the front
	P("Cab", Vector3.new(8.6, 6.4, 5.4), base * CFrame.new(0, 4.1, -7.6), WHITE, M.Metal, nil, true)
	P("Hood", Vector3.new(8.4, 1.4, 2.6), base * CFrame.new(0, 3.2, -11.4), WHITE:Lerp(C(0, 0, 0), 0.08), M.Metal, nil, true)
	P("Windshield", Vector3.new(7.4, 2.4, 0.2), base * CFrame.new(0, 5.9, -10.25) * A(-0.25, 0, 0), C(30, 38, 44), M.Glass)
	P("Grille", Vector3.new(4.2, 1.3, 0.25), base * CFrame.new(0, 2.9, -12.75), DARK, M.Metal)
	P("Bumper", Vector3.new(9, 0.7, 0.7), base * CFrame.new(0, 1.7, -12.9), C(110, 106, 100), M.Metal)
	for _, s in { -1, 1 } do
		P("CabStripe", Vector3.new(8.7, 0.9, 5.45), base * CFrame.new(0, 5.6, -7.6), STRIPE, M.SmoothPlastic)
		local hl = P("Headlight", Vector3.new(1.3, 1, 0.3), base * CFrame.new(s * 3.1, 3.1, -12.75), s < 0 and C(220, 210, 150) or C(60, 56, 50), s < 0 and M.Neon or M.Glass)
		local _ = hl
		P("CabWindow", Vector3.new(0.12, 2.2, 3.2), base * CFrame.new(s * 4.33, 5.8, -7.8), C(30, 38, 44), M.Glass)
		P("Mirror", Vector3.new(0.2, 1, 0.7), base * CFrame.new(s * 4.9, 5.6, -9.8), DARK, M.Metal)
	end
	for _, w in { { -4.3, -9.2 }, { 4.3, -9.2 }, { -4.3, 5.8 }, { 4.3, 5.8 } } do
		local flat = w[1] < 0 and w[2] < 0
		local y = flat and 1.1 or 1.6
		P("Tyre", Vector3.new(1.3, flat and 2.6 or 3.2, 3.2), base * CFrame.new(w[1], y, w[2]) * A(0, 0, math.pi / 2), DARK, M.Rubber, nil, false, Enum.PartType.Cylinder)
		P("Hub", Vector3.new(1.36, 1.3, 1.3), base * CFrame.new(w[1], y, w[2]) * A(0, 0, math.pi / 2), C(130, 126, 120), M.Metal, nil, false, Enum.PartType.Cylinder)
	end
	-- the light bar: one red lamp still glowing
	P("LightBar", Vector3.new(4.2, 0.6, 1.2), base * CFrame.new(0, 10.1, -4.6), DARK, M.Metal)
	glow(P("Lamp", Vector3.new(1.4, 0.7, 1.0), base * CFrame.new(-1.3, 10.5, -4.6), C(200, 30, 30), M.Neon), C(255, 40, 30), 14, 1.2)
	P("LampBroken", Vector3.new(1.4, 0.35, 1.0), base * CFrame.new(1.3, 10.35, -4.6), C(70, 70, 76), M.Glass)
	-- the rear doors, swung wide open
	for _, s in { -1, 1 } do
		local hinge = base * CFrame.new(s * 4.4, 5.4, 9.05) * A(0, s * -2.0, 0)
		P("RearDoor", Vector3.new(4.3, 8, 0.25), hinge * CFrame.new(-s * 2.15, 0, 0), WHITE, M.Metal, nil, true)
		P("DoorWindow", Vector3.new(2.4, 2, 0.28), hinge * CFrame.new(-s * 2.2, 1.8, 0), C(30, 38, 44), M.Glass)
		P("DoorStripe", Vector3.new(4.3, 0.9, 0.3), hinge * CFrame.new(-s * 2.15, 0.4, 0), STRIPE, M.SmoothPlastic)
		P("Handle", Vector3.new(0.6, 0.2, 0.2), hinge * CFrame.new(-s * 3.8, 0, 0.2), C(150, 150, 150), M.Metal)
	end
	P("RearStep", Vector3.new(4, 0.35, 1.4), base * CFrame.new(0, 1.0, 9.7), C(80, 78, 74), M.DiamondPlate)
	-- INSIDE: shelves of specimen jars down both walls, the tank of goo at the back, a gurney, a chart, a bulb
	for _, s in { -1, 1 } do
		for k = 0, 2 do
			local y = 3.0 + k * 2.1
			P("Shelf", Vector3.new(1.5, 0.16, 11), base * CFrame.new(s * 3.4, y, 2.5), C(150, 150, 150), M.Metal)
			P("ShelfLip", Vector3.new(0.1, 0.4, 11), base * CFrame.new(s * 2.66, y + 0.25, 2.5), C(150, 150, 150), M.Metal)
			for j = 0, 5 do
				local col = ({ C(200, 240, 170), C(110, 220, 90), C(190, 90, 240), C(255, 60, 60), C(170, 200, 150) })[rng:NextInteger(1, 5)]
				local jz = -2.2 + j * 1.85
				local jar = P("SpecimenJar", Vector3.new(0.8, 0.9, 0.8), base * CFrame.new(s * 3.4, y + 0.55, jz), C(200, 222, 212), M.Glass)
				jar.Transparency = 0.45
				P("Specimen", Vector3.new(0.6, 0.62, 0.6), base * CFrame.new(s * 3.4, y + 0.5, jz), col, (j + k) % 2 == 0 and M.Neon or M.SmoothPlastic).Transparency = 0.15
				P("JarLid", Vector3.new(0.86, 0.12, 0.86), base * CFrame.new(s * 3.4, y + 1.05, jz), C(70, 66, 60), M.Metal)
			end
		end
	end
	P("TankBase", Vector3.new(2.6, 0.6, 2.6), base * CFrame.new(0, 1.8, -3.2), C(60, 60, 64), M.Metal)
	P("TankTop", Vector3.new(2.6, 0.5, 2.6), base * CFrame.new(0, 7.7, -3.2), C(60, 60, 64), M.Metal)
	P("TankGlass", Vector3.new(2.3, 5.4, 2.3), base * CFrame.new(0, 4.8, -3.2), C(200, 230, 210), M.Glass).Transparency = 0.55
	local goo = P("TankGoo", Vector3.new(2.0, 4.2, 2.0), base * CFrame.new(0, 4.2, -3.2), C(110, 220, 90), M.Neon)
	goo.Transparency = 0.2
	glow(goo, C(130, 230, 100), 12, 0.6)
	for k = 1, 5 do P("TankBubble", Vector3.one * 0.3, base * CFrame.new(rng:NextNumber(-0.7, 0.7), 2.6 + k * 0.8, -3.2 + rng:NextNumber(-0.7, 0.7)), C(190, 255, 160), M.Neon, nil, false, Enum.PartType.Ball) end
	P("Hose", Vector3.new(0.25, 0.25, 3.4), base * CFrame.new(0, 8.2, -1.4) * A(0.4, 0, 0), C(40, 40, 40), M.Rubber)
	P("Chart", Vector3.new(0.06, 2.4, 1.8), base * CFrame.new(-4.1, 7.6, 5.5), C(214, 204, 176), M.SmoothPlastic)
	P("ChartBones", Vector3.new(0.07, 1.8, 0.5), base * CFrame.new(-4.1, 7.6, 5.5), C(120, 40, 34), M.SmoothPlastic)
	P("Gurney", Vector3.new(2.4, 0.3, 5.4), base * CFrame.new(1.6, 3.1, 3.8), C(140, 140, 144), M.Metal)
	P("Sheet", Vector3.new(2.3, 0.6, 4.6), base * CFrame.new(1.6, 3.5, 4.0), C(200, 196, 188), M.Fabric)
	local bulb = P("Bulb", Vector3.new(0.5, 0.6, 0.5), base * CFrame.new(0, 8.6, 4.5), C(220, 240, 200), M.Neon)
	glow(bulb, C(220, 240, 200), 16, 0.7)
	P("Cord", Vector3.new(0.06, 0.6, 0.06), base * CFrame.new(0, 9.1, 4.5), DARK, M.SmoothPlastic)
	-- THE COUNTER: a folding table with a cloth, a rack of the four jars he sells, a lantern, a cash tin, a ledger
	local tcf = base * CFrame.new(0, 0, 13.2)
	P("TableTop", Vector3.new(7, 0.3, 2.8), tcf * CFrame.new(0, 3.2, 0), C(120, 120, 116), M.Metal, nil, true)
	P("Cloth", Vector3.new(7.1, 0.05, 2.9), tcf * CFrame.new(0, 3.37, 0), C(120, 40, 36), M.Fabric)
	P("ClothHang", Vector3.new(7.1, 1.4, 0.05), tcf * CFrame.new(0, 2.7, 1.45), C(120, 40, 36), M.Fabric)
	for _, s in { -1, 1 } do P("TableLeg", Vector3.new(0.2, 3.1, 2.4), tcf * CFrame.new(s * 3.1, 1.6, 0), C(80, 80, 80), M.Metal) end
	P("Rack", Vector3.new(4.8, 0.2, 1.1), tcf * CFrame.new(-1.0, 3.5, 0.1), C(70, 52, 38), M.Wood)
	for i = 0, 3 do
		local col = ({ C(200, 240, 170), C(110, 220, 90), C(190, 90, 240), C(255, 60, 60) })[i + 1]
		local jx = -2.6 + i * 1.1
		local g = P("Jar", Vector3.new(0.8, 1.0, 0.8), tcf * CFrame.new(jx, 4.1, 0.1), C(210, 228, 220), M.Glass)
		g.Transparency = 0.45
		local goo2 = P("Goo", Vector3.new(0.64, 0.75, 0.64), tcf * CFrame.new(jx, 4.02, 0.1), col, M.Neon)
		goo2.Transparency = 0.12
		P("Lid", Vector3.new(0.86, 0.14, 0.86), tcf * CFrame.new(jx, 4.67, 0.1), C(70, 66, 60), M.Metal)
		P("Tag", Vector3.new(0.5, 0.3, 0.04), tcf * CFrame.new(jx, 3.85, 0.52), C(220, 210, 180), M.SmoothPlastic)
	end
	local lan = P("Lantern", Vector3.new(0.7, 1.0, 0.7), tcf * CFrame.new(2.6, 3.95, -0.4), C(255, 210, 140), M.Neon)
	glow(lan, C(255, 200, 140), 12, 0.6)
	P("LanternCap", Vector3.new(0.9, 0.2, 0.9), tcf * CFrame.new(2.6, 4.55, -0.4), DARK, M.Metal)
	P("CashTin", Vector3.new(1.2, 0.6, 0.9), tcf * CFrame.new(1.4, 3.7, 0.5), C(60, 90, 60), M.Metal)
	P("Ledger", Vector3.new(1.1, 0.15, 1.4), tcf * CFrame.new(2.6, 3.47, 0.6) * A(0, 0.3, 0), C(110, 40, 34), M.Leather)
	local prompt = P("Prompt", Vector3.new(7, 4, 3), tcf * CFrame.new(0, 3.5, 1.4), C(255, 255, 255))
	prompt.Transparency = 1
	-- DOC MERCY: a tall thin struck-off doctor behind the table, holding a jar of goo up to the light. Long stained
	-- white coat, shirt and tie, a stethoscope, rubber gloves, round glasses, a head mirror, thinning grey hair, a grin.
	local COAT, SKIN = C(210, 208, 198), C(214, 192, 172)
	local docBase = tcf * CFrame.new(0, 0, -2.3) * A(0, math.pi, 0)
	local _, Fd = figure("Doc", docBase, {
		skin = SKIN, legs = C(44, 44, 50), shoes = C(28, 24, 22), chest = C(150, 176, 168), sleeve = COAT, cuff = C(200, 210, 150),
		hands = C(206, 200, 140), hunch = 0.1, curl = 0.9, headTilt = 0.08, headRoll = -0.12, browTilt = -0.25, mouthTilt = 0.18,
		armR = { sh = A(2.25, 0, 0.25), el = 1.2 }, armL = { sh = A(0.75, 0, -0.08), el = 0.35 },
		noseLen = 0.42, eyeWhite = C(230, 230, 220),
	})
	cur = doc:FindFirstChild("Doc") :: Model
	local ch, hd = Fd.chest, Fd.head
	-- the long coat: back and two front panels open over the shirt, the skirt to the knees, lapels, pockets, buttons
	P("CoatBack", Vector3.new(2.15, 2.6, 0.18), ch * CFrame.new(0, 0, 0.6), COAT, M.Fabric)
	for _, s in { -1, 1 } do
		P("CoatFront", Vector3.new(0.75, 2.5, 0.16), ch * CFrame.new(s * 0.7, -0.05, -0.6), COAT, M.Fabric)
		P("CoatSide", Vector3.new(0.16, 2.5, 1.2), ch * CFrame.new(s * 1.02, -0.05, 0), COAT, M.Fabric)
		P("Lapel", Vector3.new(0.38, 1.1, 0.1), ch * CFrame.new(s * 0.42, 0.65, -0.69) * A(0, 0, s * -0.35), COAT:Lerp(C(0, 0, 0), 0.06), M.Fabric)
		P("Skirt", Vector3.new(1.0, 2.2, 1.3), Fd.hips * CFrame.new(s * 0.52, -1.0, 0.02) * A(0, 0, s * 0.05), COAT, M.Fabric)
		P("Pocket", Vector3.new(0.55, 0.5, 0.05), Fd.hips * CFrame.new(s * 0.6, -0.4, -0.68), COAT:Lerp(C(0, 0, 0), 0.08), M.Fabric)
	end
	for i = 0, 2 do P("Button", Vector3.new(0.12, 0.12, 0.04), ch * CFrame.new(-0.33, 0.3 - i * 0.6, -0.69), C(60, 60, 64), M.SmoothPlastic) end
	P("Tie", Vector3.new(0.26, 1.5, 0.06), ch * CFrame.new(0, 0.35, -0.55), C(110, 26, 30), M.Fabric)
	P("TieKnot", Vector3.new(0.3, 0.22, 0.1), ch * CFrame.new(0, 1.05, -0.56), C(90, 20, 24), M.Fabric)
	P("PenPocket", Vector3.new(0.45, 0.4, 0.04), ch * CFrame.new(0.55, 0.45, -0.69), COAT:Lerp(C(0, 0, 0), 0.08), M.Fabric)
	P("Pen", Vector3.new(0.07, 0.45, 0.07), ch * CFrame.new(0.5, 0.65, -0.72), C(30, 30, 120), M.SmoothPlastic)
	P("NameTag", Vector3.new(0.45, 0.22, 0.04), ch * CFrame.new(-0.55, 0.55, -0.7), C(230, 226, 214), M.SmoothPlastic)
	for i = 1, 5 do
		P("Stain", Vector3.new(rng:NextNumber(0.2, 0.5), rng:NextNumber(0.2, 0.6), 0.03), ch * CFrame.new(rng:NextNumber(-0.9, 0.9), rng:NextNumber(-1.1, 0.2), -0.7),
			C(120, 120, 60):Lerp(C(110, 220, 90), 0.4), M.SmoothPlastic)
	end
	-- the stethoscope round his neck
	for _, s in { -1, 1 } do P("Tube", Vector3.new(0.1, 1.3, 0.1), ch * CFrame.new(s * 0.35, 0.55, -0.6) * A(0, 0, s * 0.25), C(30, 30, 32), M.Rubber) end
	P("Chestpiece", Vector3.new(0.3, 0.3, 0.1), ch * CFrame.new(0.15, -0.15, -0.63), C(190, 190, 196), M.Metal, nil, false, Enum.PartType.Cylinder).CFrame = ch * CFrame.new(0.15, -0.15, -0.64) * A(0, math.pi / 2, 0)
	-- the face: round black-rimmed glasses, the head mirror on its band, thinning grey hair combed back
	for _, s in { -1, 1 } do
		local lc = hd * CFrame.new(s * 0.27, 0.16, -0.67)
		P("Lens", Vector3.new(0.34, 0.3, 0.03), lc, C(170, 210, 190), M.Glass).Transparency = 0.5
		for _, e in { { 0, 0.17, 0.4, 0.05 }, { 0, -0.17, 0.4, 0.05 }, { 0.19, 0, 0.05, 0.36 }, { -0.19, 0, 0.05, 0.36 } } do
			P("Rim", Vector3.new(e[3], e[4], 0.05), lc * CFrame.new(e[1], e[2], 0), C(16, 14, 14), M.SmoothPlastic)
		end
		P("Temple", Vector3.new(0.04, 0.05, 0.66), hd * CFrame.new(s * 0.6, 0.2, -0.32), C(16, 14, 14), M.SmoothPlastic)
		P("HairSide", Vector3.new(0.18, 0.55, 0.8), hd * CFrame.new(s * 0.62, 0.3, 0.2), C(170, 170, 166), M.Fabric)
	end
	P("Bridge", Vector3.new(0.16, 0.05, 0.05), hd * CFrame.new(0, 0.2, -0.68), C(16, 14, 14), M.SmoothPlastic)
	P("HairBack", Vector3.new(1.22, 0.7, 0.3), hd * CFrame.new(0, 0.3, 0.55), C(170, 170, 166), M.Fabric)
	P("HairTop", Vector3.new(1.0, 0.16, 0.8), hd * CFrame.new(0, 0.76, 0.18), C(150, 150, 146), M.Fabric)
	P("HeadBand", Vector3.new(1.28, 0.2, 1.3), hd * CFrame.new(0, 0.58, 0), C(36, 34, 34), M.Fabric)
	P("MirrorMount", Vector3.new(0.2, 0.2, 0.2), hd * CFrame.new(0.2, 0.62, -0.68), C(36, 34, 34), M.Metal)
	P("HeadMirror", Vector3.new(0.06, 0.62, 0.62), hd * CFrame.new(0.2, 0.75, -0.78) * A(0, math.pi / 2, 0) * A(0, 0, -0.35), C(176, 182, 186), M.Metal, nil, false, Enum.PartType.Cylinder)
	P("MirrorHole", Vector3.new(0.07, 0.14, 0.14), hd * CFrame.new(0.2, 0.75, -0.8) * A(0, math.pi / 2, 0) * A(0, 0, -0.35), C(20, 20, 20), M.SmoothPlastic, nil, false, Enum.PartType.Cylinder)
	for i = 0, 3 do P("Tooth", Vector3.new(0.09, 0.09, 0.04), hd * CFrame.new(-0.12 + i * 0.09, -0.43, -0.64), C(220, 214, 180), M.SmoothPlastic) end
	-- the jar he holds up to the light
	local hj = Fd.handR * CFrame.new(0, 0.2, -0.15)
	P("HeldJar", Vector3.new(0.95, 1.15, 0.95), hj, C(210, 228, 220), M.Glass).Transparency = 0.45
	local hg = P("HeldGoo", Vector3.new(0.78, 0.85, 0.78), hj * CFrame.new(0, -0.08, 0), C(110, 220, 90), M.Neon)
	hg.Transparency = 0.12
	glow(hg, C(130, 230, 100), 8, 0.5)
	P("HeldLid", Vector3.new(1.0, 0.16, 1.0), hj * CFrame.new(0, 0.64, 0), C(70, 66, 60), M.Metal)
	cur = doc
	sign(doc, base * CFrame.new(-7.6, 4.5, 14) * A(0, math.pi + 0.35, 0), 6.5, 2.6, "DOC MERCY", "ECTOPLASM - FRESH TONIGHT", C(200, 230, 120))
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
	local PLANK, PLANK2, MOSS, STONE, THATCH = C(66, 52, 40), C(52, 42, 34), C(64, 80, 44), C(92, 90, 86), C(96, 84, 50)
	-- THE HUT: crooked plank walls, a steep thatched roof with moss, a stone chimney, a round glowing window
	local hut = base * CFrame.new(0, 0, 4) * A(0, 0, 0.03)
	P("Floor", Vector3.new(12, 0.6, 10), hut * CFrame.new(0, 0.3, 0), PLANK2, M.Wood, "PS2_DarkBeam", true)
	P("WallBack", Vector3.new(12, 8, 0.8), hut * CFrame.new(0, 4.5, 4.6), PLANK, M.WoodPlanks, "PS2_Siding", true)
	for _, s in { -1, 1 } do
		P("WallSide", Vector3.new(0.8, 8, 10), hut * CFrame.new(s * 5.6, 4.5, 0) * A(0, 0, s * 0.03), PLANK, M.WoodPlanks, "PS2_Siding", true)
		P("WallFront", Vector3.new(3.8, 8, 0.8), hut * CFrame.new(s * 3.9, 4.5, -4.6), PLANK, M.WoodPlanks, "PS2_Siding", true)
		P("Roof", Vector3.new(8, 0.9, 12.8), hut * CFrame.new(s * 3.2, 11, 0) * A(0, 0, s * -0.75), THATCH, M.Grass, nil, true)
		P("RoofMoss", Vector3.new(4, 0.2, 9), hut * CFrame.new(s * 3.3, 11.6, 1) * A(0, 0, s * -0.75), MOSS, M.Grass)
		for k = 0, 3 do P("Corner", Vector3.new(0.9, 8.4, 0.9), hut * CFrame.new(s * 5.7, 4.4, k < 2 and -4.7 or 4.7), C(44, 34, 28), M.Wood, "PS2_DarkBeam") end
		for k = -2, 2 do P("Thatch", Vector3.new(0.4, 1.2, 0.3), hut * CFrame.new(s * 6.8, 8.4, -6.4 + k * 0.05 + k * 2.6) * A(0, 0, s * 0.2), THATCH, M.Grass) end
	end
	-- the gable ends: stepped planks under the roof
	for _, z in { -4.6, 4.6 } do
		for k = 0, 4 do P("Gable", Vector3.new(9.6 - k * 2.2, 0.9, 0.7), hut * CFrame.new(0, 8.9 + k * 0.9, z), PLANK2, M.WoodPlanks, "PS2_Siding") end
	end
	P("Lintel", Vector3.new(4.4, 2, 0.8), hut * CFrame.new(0, 7.5, -4.6), PLANK, M.WoodPlanks, "PS2_Siding", true)
	P("DoorFrame", Vector3.new(4.6, 0.4, 1.0), hut * CFrame.new(0, 6.45, -4.7), C(44, 34, 28), M.Wood)
	P("Door", Vector3.new(3.6, 6.4, 0.3), hut * CFrame.new(-1.0, 3.5, -5.2) * A(0, 0.9, 0) * CFrame.new(1.8, 0, 0), C(48, 36, 28), M.WoodPlanks, "PS2_DarkBeam", true)
	P("Dark", Vector3.new(10, 7.6, 8.5), hut * CFrame.new(0, 4.4, 0), C(10, 12, 8), M.SmoothPlastic)
	glow(P("InGlow", Vector3.new(1, 1, 1), hut * CFrame.new(0, 3, 1), C(120, 200, 80), M.Neon), C(130, 210, 90), 12, 1.2).Parent.Transparency = 1
	local win = P("Window", Vector3.new(0.25, 2, 2), hut * CFrame.new(-6.0, 5.2, -1), C(150, 210, 90), M.Neon, nil, false, Enum.PartType.Cylinder)
	win.Transparency = 0.25
	P("WindowCross", Vector3.new(0.3, 2.1, 0.2), hut * CFrame.new(-6.05, 5.2, -1), C(40, 30, 24), M.Wood)
	P("WindowCross2", Vector3.new(0.3, 0.2, 2.1), hut * CFrame.new(-6.05, 5.2, -1), C(40, 30, 24), M.Wood)
	P("Chimney", Vector3.new(2.2, 7, 2.2), hut * CFrame.new(3.8, 11, 2.5), STONE, M.Cobblestone, "PS2_Stone")
	local top = P("ChimneyTop", Vector3.new(2.6, 0.6, 2.6), hut * CFrame.new(3.8, 14.6, 2.5), STONE:Lerp(C(0, 0, 0), 0.2), M.Cobblestone, "PS2_Stone")
	local sm = Instance.new("ParticleEmitter")
	sm.Texture = "rbxasset://textures/particles/smoke_main.dds"; sm.Rate = 1.5; sm.Lifetime = NumberRange.new(3, 4); sm.Speed = NumberRange.new(2, 3)
	sm.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 3) })
	sm.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
	sm.Color = ColorSequence.new(C(90, 100, 80)); sm.EmissionDirection = Enum.NormalId.Top; sm.Parent = top
	-- a black cat on the roof's edge, its eyes glowing
	local cat = hut * CFrame.new(-3.6, 9.6, -5.8)
	P("CatBody", Vector3.new(0.9, 0.8, 1.5), cat, C(16, 14, 16), M.SmoothPlastic)
	P("CatHead", Vector3.new(0.75, 0.7, 0.7), cat * CFrame.new(0, 0.55, -0.75), C(16, 14, 16), M.SmoothPlastic)
	for _, s in { -1, 1 } do
		P("CatEar", Vector3.new(0.2, 0.3, 0.12), cat * CFrame.new(s * 0.22, 1.0, -0.75), C(16, 14, 16), M.SmoothPlastic)
		P("CatEye", Vector3.new(0.12, 0.08, 0.04), cat * CFrame.new(s * 0.17, 0.6, -1.11), C(230, 230, 60), M.Neon)
	end
	P("CatTail", Vector3.new(0.18, 1.6, 0.18), cat * CFrame.new(0.2, -0.5, 0.75) * A(0.4, 0, 0.3), C(16, 14, 16), M.SmoothPlastic)
	-- strings of herbs, bones and charms hanging from the eave
	for i = -2, 2 do
		local x = i * 1.9
		P("String", Vector3.new(0.05, 1.4, 0.05), hut * CFrame.new(x, 7.6, -5.6), C(90, 80, 60), M.Fabric)
		local kind = (i + 3) % 3
		if kind == 0 then P("Herbs", Vector3.new(0.6, 1.1, 0.6), hut * CFrame.new(x, 6.5, -5.6) * A(0, i, 0), C(80, 110, 50), M.Grass)
		elseif kind == 1 then P("Bone", Vector3.new(0.25, 1.2, 0.25), hut * CFrame.new(x, 6.4, -5.6) * A(0, 0, 0.3), C(220, 210, 180), M.SmoothPlastic)
		else P("Charm", Vector3.new(0.6, 0.8, 0.6), hut * CFrame.new(x, 6.5, -5.6), C(190, 120, 240), M.Neon).Transparency = 0.2 end
	end
	-- her counter: a plank table beside the door, potions in corked bottles, candles, a skull, a mortar
	local sh = base * CFrame.new(-6.2, 0, -4.5) * A(0, 0.2, 0)
	P("Counter", Vector3.new(5, 3, 1.8), sh * CFrame.new(0, 1.5, 0), PLANK2, M.WoodPlanks, "PS2_DarkBeam", true)
	P("CounterTop", Vector3.new(5.4, 0.3, 2.2), sh * CFrame.new(0, 3.15, 0), C(44, 34, 28), M.Wood, "PS2_DarkBeam")
	for j = 0, 5 do
		local col = ({ C(150, 170, 90), C(150, 190, 240), C(200, 70, 200), C(255, 60, 60), C(230, 220, 140), C(110, 200, 200) })[j + 1]
		local px, pz = -2 + j * 0.8, (j % 2 == 0) and -0.4 or 0.3
		P("Bottle", Vector3.new(0.6, 0.6, 0.6), sh * CFrame.new(px, 3.6, pz), C(200, 220, 210), M.Glass, nil, false, Enum.PartType.Ball).Transparency = 0.4
		P("Potion", Vector3.new(0.48, 0.48, 0.48), sh * CFrame.new(px, 3.58, pz), col, M.Neon, nil, false, Enum.PartType.Ball).Transparency = 0.15
		P("Neck", Vector3.new(0.16, 0.35, 0.16), sh * CFrame.new(px, 4.05, pz), C(200, 220, 210), M.Glass).Transparency = 0.4
		P("Cork", Vector3.new(0.18, 0.16, 0.18), sh * CFrame.new(px, 4.28, pz), C(150, 110, 70), M.Wood)
	end
	P("Skull", Vector3.new(0.9, 0.9, 1), sh * CFrame.new(1.7, 3.8, 0.4) * A(0, -0.4, 0), C(220, 212, 186), M.SmoothPlastic)
	for _, s in { -1, 1 } do P("SkullEye", Vector3.new(0.2, 0.2, 0.05), sh * CFrame.new(1.7, 3.8, 0.4) * A(0, -0.4, 0) * CFrame.new(s * 0.2, 0.1, -0.5), C(20, 16, 14)) end
	P("Mortar", Vector3.new(0.8, 0.6, 0.8), sh * CFrame.new(-1.6, 3.6, 0.6), STONE, M.Slate, nil, false, Enum.PartType.Cylinder).CFrame = sh * CFrame.new(-1.6, 3.6, 0.6) * A(0, 0, math.pi / 2)
	for i = 0, 2 do
		local cnd = P("Candle", Vector3.new(0.3, 0.6 + i * 0.2, 0.3), sh * CFrame.new(0.6 + i * 0.4, 3.6 + i * 0.1, 0.75), C(220, 210, 170), M.SmoothPlastic)
		local fl = P("Flame", Vector3.new(0.18, 0.3, 0.18), cnd.CFrame * CFrame.new(0, cnd.Size.Y / 2 + 0.15, 0), C(255, 190, 90), M.Neon)
		if i == 1 then glow(fl, C(255, 170, 90), 9, 0.8) end
	end
	-- mushrooms and a little fence of bones round the yard
	for _, p in { { -9, -8 }, { 8, -9 }, { 9, -3 }, { -8, 0 } } do
		P("MushStem", Vector3.new(0.3, 0.6, 0.3), base * CFrame.new(p[1], 0.3, p[2]), C(220, 210, 190), M.SmoothPlastic)
		P("MushCap", Vector3.new(0.9, 0.35, 0.9), base * CFrame.new(p[1], 0.7, p[2]), C(170, 40, 40), M.SmoothPlastic)
	end
	-- THE CAULDRON in front of the hut, on three stones over a fire, bubbling green
	local cc = base * CFrame.new(1.5, 0, -7.5)
	for k = 0, 2 do
		local a = k * math.pi * 2 / 3
		P("Stone", Vector3.new(1.4, 1.1, 1.4), cc * CFrame.new(math.cos(a) * 2.1, 0.55, math.sin(a) * 2.1) * A(0, a, 0.2), STONE, M.Slate, "PS2_Stone", true)
	end
	for k = 0, 4 do P("Log", Vector3.new(0.6, 0.6, 2.6), cc * CFrame.new(math.cos(k * 1.3) * 0.6, 0.35, math.sin(k * 1.3) * 0.6) * A(0, k * 1.3, 0.15), C(60, 40, 28), M.Wood) end
	local fire = P("Fire", Vector3.new(1.6, 0.9, 1.6), cc * CFrame.new(0, 0.9, 0), C(255, 120, 30), M.Neon)
	fire.Transparency = 0.2
	glow(fire, C(255, 140, 60), 16, 1.6)
	P("PotBelly", Vector3.new(3.9, 2.6, 3.9), cc * CFrame.new(0, 2.6, 0), C(30, 30, 32), M.Metal, nil, true, Enum.PartType.Ball)
	P("PotWall", Vector3.new(1.6, 3.7, 3.7), cc * CFrame.new(0, 3.3, 0) * A(0, 0, math.pi / 2), C(30, 30, 32), M.Metal, nil, false, Enum.PartType.Cylinder)
	P("Rim", Vector3.new(0.4, 4.0, 4.0), cc * CFrame.new(0, 4.25, 0) * A(0, 0, math.pi / 2), C(44, 44, 46), M.Metal, nil, false, Enum.PartType.Cylinder)
	for _, s in { -1, 1 } do P("PotHandle", Vector3.new(0.3, 0.9, 0.3), cc * CFrame.new(s * 2.1, 4.1, 0), C(44, 44, 46), M.Metal) end
	local brew = P("Brew", Vector3.new(0.2, 3.4, 3.4), cc * CFrame.new(0, 4.3, 0) * A(0, 0, math.pi / 2), C(110, 220, 70), M.Neon, nil, false, Enum.PartType.Cylinder)
	glow(brew, C(130, 230, 90), 14, 1.4)
	for k = 1, 5 do P("Bubble", Vector3.one * rng:NextNumber(0.3, 0.6), cc * CFrame.new(rng:NextNumber(-1.1, 1.1), 4.45, rng:NextNumber(-1.1, 1.1)), C(170, 250, 120), M.Neon, nil, false, Enum.PartType.Ball) end
	local steam = Instance.new("ParticleEmitter")
	steam.Texture = "rbxasset://textures/particles/smoke_main.dds"; steam.Rate = 2; steam.Lifetime = NumberRange.new(1.5, 2.2); steam.Speed = NumberRange.new(1.5, 2.5)
	steam.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 2.2) })
	steam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
	steam.Color = ColorSequence.new(C(150, 230, 110)); steam.LightEmission = 0.4; steam.EmissionDirection = Enum.NormalId.Right; steam.Parent = brew
	local bub = Instance.new("Sound"); bub.Name = "Bubbling"; bub.SoundId = "rbxassetid://9120305560"; bub.Looped = true; bub.Volume = 0.35
	bub.RollOffMaxDistance = 40; bub.RollOffMinDistance = 6; bub.Playing = true; bub.Parent = brew
	-- the lantern on a crooked pole, moths round it
	local lp = base * CFrame.new(6.5, 0, -7) * A(0, 0, -0.08)
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
	P("Broom", Vector3.new(0.3, 6.5, 0.3), hut * CFrame.new(4.6, 3.3, -5.3) * A(0.1, 0, 0.25), C(110, 80, 50), M.Wood)
	P("Bristles", Vector3.new(1.0, 1.8, 0.8), hut * CFrame.new(5.35, 0.9, -5.6) * A(0.1, 0, 0.25), C(170, 140, 80), M.Grass)
	local prompt = P("Prompt", Vector3.new(8, 4, 4), cc * CFrame.new(0, 3, -2.5), C(255, 255, 255))
	prompt.Transparency = 1
	-- MOTHER MOTH: a bent old witch BESIDE her cauldron (so you see her whole), stirring it with a long ladle.
	-- Layered ragged robes, a shawl with fringe, a cloak of folded moth wings down her back, a wide drooping
	-- pointed hat with a moth pinned on its band, long grey hair, grey-green skin, a long crooked nose, small
	-- glowing eyes, a necklace of teeth, long dark nails.
	local SKIN, ROBE, ROBE2 = C(150, 162, 130), C(52, 40, 50), C(70, 54, 62)
	local mBase = cc * CFrame.new(4.3, 0, 1.6) * A(0, 0.75, 0) -- (facing the pot and the path, half turned)
	local _, Fm = figure("Moth", mBase, {
		skin = SKIN, legs = ROBE, shoes = C(36, 28, 24), chest = ROBE, sleeve = ROBE2, hands = SKIN, nails = C(30, 26, 22),
		hunch = 0.3, curl = 1.0, headTilt = 0.25, headRoll = 0.12, browTilt = 0.4, mouthTilt = -0.15,
		armR = { sh = A(1.35, 0, 0.3), el = 0.7 }, armL = { sh = A(1.25, 0, -0.25), el = 0.9 },
		noseLen = 0.32, noseOut = 0.55, noseTilt = -0.35, eyeGlow = true, eyeWhite = C(40, 36, 20), pupil = C(255, 230, 120),
		brow = C(180, 180, 170),
	})
	cur = moth:FindFirstChild("Moth") :: Model
	local ch, hd, hp = Fm.chest, Fm.head, Fm.hips
	-- robes: three tiers to the ground, tattered, a rope belt with pouches and charms
	P("RobeTop", Vector3.new(2.2, 1.6, 1.4), hp * CFrame.new(0, -0.6, 0), ROBE, M.Fabric)
	P("RobeMid", Vector3.new(2.5, 1.4, 1.7), hp * CFrame.new(0, -1.9, 0.05), ROBE2, M.Fabric)
	P("RobeHem", Vector3.new(2.8, 1.0, 2.0), hp * CFrame.new(0, -2.9, 0.1), ROBE, M.Fabric)
	for i = -3, 3 do
		P("Tatter", Vector3.new(0.35, rng:NextNumber(0.4, 0.8), 0.1), hp * CFrame.new(i * 0.38, -3.45, -1.0) * A(0, 0, rng:NextNumber(-0.3, 0.3)), ROBE:Lerp(C(0, 0, 0), 0.3), M.Fabric)
	end
	P("RopeBelt", Vector3.new(2.0, 0.22, 1.2), hp * CFrame.new(0, 0.25, 0), C(120, 92, 60), M.Fabric)
	P("Pouch", Vector3.new(0.5, 0.6, 0.35), hp * CFrame.new(0.75, -0.1, -0.55), C(90, 64, 40), M.Leather)
	P("Key", Vector3.new(0.12, 0.5, 0.05), hp * CFrame.new(-0.6, -0.2, -0.62), C(150, 120, 60), M.Metal)
	-- the shawl with its fringe, the necklace of teeth
	P("Shawl", Vector3.new(2.5, 1.0, 1.5), ch * CFrame.new(0, 0.85, 0.05), C(84, 72, 60), M.Fabric)
	for i = -4, 4 do P("Fringe", Vector3.new(0.12, 0.5, 0.06), ch * CFrame.new(i * 0.26, 0.15, -0.76), C(84, 72, 60), M.Fabric) end
	for i = -3, 3 do P("ToothCharm", Vector3.new(0.1, 0.2, 0.08), ch * CFrame.new(i * 0.13, 0.8 - math.abs(i) * 0.06, -0.78), C(226, 216, 190), M.SmoothPlastic) end
	-- THE MOTH-WING CLOAK: two big folded wings hanging down her back, dusty brown, dark veins, eye spots
	for _, s in { -1, 1 } do
		local w = ch * CFrame.new(s * 0.55, 0.6, 0.62) * A(0.12, s * 0.2, s * 0.12)
		P("Wing", Vector3.new(1.6, 3.6, 0.12), w * CFrame.new(s * 0.5, -1.4, 0), C(140, 118, 90), M.Fabric)
		P("WingLow", Vector3.new(1.2, 1.6, 0.13), w * CFrame.new(s * 0.75, -3.4, 0.02) * A(0, 0, s * 0.25), C(120, 100, 78), M.Fabric)
		P("WingEdge", Vector3.new(0.14, 3.6, 0.14), w * CFrame.new(s * 1.28, -1.4, 0), C(70, 56, 44), M.Fabric)
		for k = 0, 2 do P("Vein", Vector3.new(0.06, 2.8, 0.14), w * CFrame.new(s * (0.1 + k * 0.4), -1.6, 0.01) * A(0, 0, s * (0.1 + k * 0.08)), C(80, 64, 50), M.Fabric) end
		local eye = w * CFrame.new(s * 0.55, -1.0, 0.08)
		P("EyeRing", Vector3.new(0.1, 0.9, 0.9), eye * A(0, math.pi / 2, 0), C(60, 40, 30), M.Fabric, nil, false, Enum.PartType.Cylinder)
		P("EyeSpot", Vector3.new(0.12, 0.42, 0.42), eye * CFrame.new(0, 0, 0.02) * A(0, math.pi / 2, 0), C(186, 160, 100), M.Fabric, nil, false, Enum.PartType.Cylinder)
	end
	-- the face: a protruding chin, a wart on the nose, a crooked tooth, wrinkles; grey hair hanging long
	P("Chin", Vector3.new(0.45, 0.35, 0.3), hd * CFrame.new(0, -0.8, -0.55), SKIN)
	P("Wart", Vector3.new(0.13, 0.13, 0.13), hd * CFrame.new(0.1, -0.15, -1.08), C(110, 122, 92))
	P("CrookedTooth", Vector3.new(0.09, 0.16, 0.05), hd * CFrame.new(0.12, -0.52, -0.64), C(220, 206, 150))
	for i = 0, 1 do P("Wrinkle", Vector3.new(0.5, 0.04, 0.03), hd * CFrame.new(0, 0.5 + i * 0.12, -0.63), SKIN:Lerp(C(0, 0, 0), 0.25)) end
	for _, s in { -1, 1 } do
		P("HairSide", Vector3.new(0.35, 2.4, 0.9), hd * CFrame.new(s * 0.72, -0.7, 0.15) * A(0, 0, s * 0.1), C(176, 176, 168), M.Fabric)
		for k = 0, 2 do P("Strand", Vector3.new(0.12, 1.8 + k * 0.3, 0.12), hd * CFrame.new(s * (0.5 + k * 0.12), -0.9, -0.35 + k * 0.1) * A(0, 0, s * 0.18), C(196, 196, 186), M.Fabric) end
	end
	P("HairBack", Vector3.new(1.4, 2.8, 0.45), hd * CFrame.new(0, -0.8, 0.62), C(176, 176, 168), M.Fabric)
	-- THE HAT: a wide brim drooping in four pieces, a band with a buckle and a moth pinned on it, a tall crooked cone
	local hb = hd * CFrame.new(0, 0.82, 0)
	P("BrimCore", Vector3.new(2.4, 0.16, 2.4), hb, C(28, 24, 28), M.Fabric)
	for k = 0, 3 do
		local a = k * math.pi / 2
		P("BrimFlap", Vector3.new(2.2, 0.14, 0.9), hb * A(0, a, 0) * CFrame.new(0, -0.15, -1.45) * A(-0.35, 0, 0), C(28, 24, 28), M.Fabric)
	end
	P("HatBand", Vector3.new(1.45, 0.32, 1.45), hb * CFrame.new(0, 0.28, 0), C(100, 50, 110), M.Fabric)
	P("Buckle", Vector3.new(0.4, 0.3, 0.06), hb * CFrame.new(0, 0.28, -0.74), C(180, 150, 60), M.Metal)
	for _, s in { -1, 1 } do P("PinnedMoth", Vector3.new(0.35, 0.28, 0.04), hb * CFrame.new(0.45 + s * 0.17, 0.32, -0.76) * A(0, 0, s * 0.3), C(214, 200, 160), M.Fabric) end
	local hc = hb * CFrame.new(0, 0.4, 0)
	for k, sz in { 1.35, 1.05, 0.8, 0.55, 0.32 } do
		hc = hc * CFrame.new(0, 0.5, 0) * A(-0.1 - k * 0.04, 0, 0.16 + k * 0.05)
		P("HatCone", Vector3.new(sz, 0.62, sz), hc, C(28, 24, 28), M.Fabric)
	end
	-- the brew lights her face from below (green, soft)
	local faceLight = P("FaceGlow", Vector3.new(0.2, 0.2, 0.2), hd * CFrame.new(0, -1.4, -1.6), C(150, 230, 110), M.SmoothPlastic)
	faceLight.Transparency = 1
	glow(faceLight, C(150, 230, 110), 7, 1.1)
	-- the long ladle in both hands, down in the pot
	local l0 = Fm.handR
	local toPot = (cc * CFrame.new(0, 4.4, 0)).Position
	local mid = (l0.Position + toPot) / 2
	local len = (toPot - l0.Position).Magnitude + 1.2
	P("Ladle", Vector3.new(0.22, 0.22, len), CFrame.lookAt(mid, toPot), C(84, 60, 40), M.Wood)
	P("LadleCup", Vector3.new(0.8, 0.45, 0.8), CFrame.new(toPot), C(60, 60, 62), M.Metal)
	cur = moth
	sign(moth, base * CFrame.new(-9.5, 4.5, -9) * A(0, 0.5, 0), 6.5, 2.6, "MOTHER MOTH", "POTIONS - BREWED TONIGHT", C(200, 140, 240))
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
