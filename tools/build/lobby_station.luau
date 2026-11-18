-- THE PARK STATION (Edit mode, safe to re-run): the lobby's east end becomes the park's entrance by train.
--   * Lobby.Station: a terminus where the path ends (x ~100): buffers with a red lamp, two stone platforms with
--     canopies, lanterns, benches, a clock and luggage, the track (ballast, sleepers, rails) running east under a
--     "PARK STATION" stone arch in the fence, through the pine ring (the pines in the way are moved aside) to a tunnel
--     in a rocky hill (x ~196): the train comes out of the dark.
--   * The leaderboards (Lobby.Leaderboards, drawn by Server/Leaderboards) move to the fountain: an arc on the plaza's
--     north-east edge, facing the fountain, the HALL OF FAME sign over the middle board.
--   * The east gate's sign and the signpost's RANKS arm now say THE STATION / STATION.
--   * ReplicatedStorage.Intro.Train: the train (a steam locomotive and one lit carriage), built where it stops at the
--     platform. Client/Intro clones it for the tutorial's ending: it pulls in, the carriage door ("Door") slides open
--     and the player steps out onto the south platform. Its PrimaryPart "Root" is at the front, on the rails.
-- Everything is hand-built from plain parts in the game's PS2 look (PS2_* materials, Neon only for small lights).
local RS = game:GetService("ReplicatedStorage")
local L = workspace:WaitForChild("Lobby")
local CX, CZ = 0, 1000
local TZ = 1000 -- the track's axis
local rng = Random.new(20261118)
local function C(r: number, g: number, b: number): Color3 return Color3.fromRGB(r, g, b) end
local V = Vector3.new
local M = Enum.Material

local function P(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, variant: string?, collide: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat
	if variant then p.MaterialVariant = variant end
	p.Anchored = true; p.CanCollide = collide == true; p.CanQuery = collide == true; p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
-- a cylinder lying along `axis` (the part's own X)
local function cyl(parent: Instance, name: string, r: number, len: number, cf: CFrame, color: Color3, mat: Enum.Material, collide: boolean?): Part
	local p = P(parent, name, V(len, r * 2, r * 2), cf, color, mat, nil, collide)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function glow(p: BasePart, color: Color3, range: number, bright: number)
	local l = Instance.new("PointLight"); l.Color = color; l.Range = range; l.Brightness = bright; l.Shadows = false; l.Parent = p
end
local function sign(p: BasePart, face: Enum.NormalId, text: string, color: Color3)
	local sg = Instance.new("SurfaceGui"); sg.Face = face; sg.CanvasSize = Vector2.new(800, 140); sg.LightInfluence = 0; sg.Brightness = 1; sg.Parent = p
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 1); t.Font = Enum.Font.Creepster; t.TextScaled = true
	t.Text = text; t.TextColor3 = color; t.TextStrokeTransparency = 0.3; t.Parent = sg
end
local function group(parent: Instance, name: string): Model
	local m = Instance.new("Model"); m.Name = name; m.Parent = parent
	return m
end

local STONE, STONE_D = C(88, 86, 84), C(62, 60, 58)
local BEAM, PLANK = C(44, 32, 26), C(60, 42, 32)
local IRON, RAIL = C(34, 33, 34), C(96, 92, 88)
local WARM = C(255, 180, 100)

-- 0 a re-run starts clean -----------------------------------------------------------------------------------------
local old = L:FindFirstChild("Station")
if old then old:Destroy() end
local intro = RS:WaitForChild("Intro")
local oldTrain = intro:FindFirstChild("Train")
if oldTrain then oldTrain:Destroy() end
local S = Instance.new("Model"); S.Name = "Station"; S.Parent = L

-- 1 THE LEADERBOARDS go to the fountain --------------------------------------------------------------------------------
local moved = 0
local LB = L:FindFirstChild("Leaderboards")
if LB then
	local slots = { Board_Kills = 69, Board_Wave = 45, Board_Cash = 21 } -- degrees from east toward north, on a 30-stud arc
	local wave = LB:FindFirstChild("Board_Wave") :: Model?
	local waveOld = wave and wave:GetPivot()
	for name, deg in slots do
		local b = LB:FindFirstChild(name) :: Model?
		if b then
			local a = math.rad(deg)
			local at = V(CX + math.cos(a) * 30, b:GetPivot().Position.Y, CZ - math.sin(a) * 30)
			local look = V(CX - at.X, 0, CZ - at.Z).Unit -- (the screen faces the fountain)
			b:PivotTo(CFrame.lookAt(at, at + look))
			moved += 1
		end
	end
	if wave and waveOld then
		local d = wave:GetPivot() * waveOld:Inverse()
		for _, c in LB:GetChildren() do
			if c:IsA("BasePart") then c.CFrame = d * c.CFrame end -- (the HALL OF FAME sign and its chains)
		end
	end
end

-- 2 THE SIGNS: the east gate and the signpost's arm ----------------------------------------------------------------------
local detail = L:FindFirstChild("Detail")
local relabelled = 0
if detail then
	for _, d in detail:GetDescendants() do
		if d:IsA("TextLabel") then
			if d.Text == "HALL OF FAME" then d.Text = "THE STATION"; relabelled += 1
			elseif d.Text == "RANKS" then d.Text = "STATION"; relabelled += 1 end
		end
	end
	local g = detail:FindFirstChild("Gate_HALL OF FAME")
	if g then g.Name = "Gate_THE STATION" end
	-- the hall of fame's banners and the loose curb stones where the platforms go
	local fy = detail:FindFirstChild("FameYard")
	if fy then
		for _, c in fy:GetChildren() do
			if c.Name:find("^Banner") or (c.Name == "CurbStone" and c:IsA("BasePart") and c.Position.X > 98) then c:Destroy() end
		end
	end
end

-- 3 THE WAY IN: a gap in the fence, the pines in the way moved aside -------------------------------------------------------
local fence = L:FindFirstChild("Fence")
if fence then
	for _, p in fence:GetDescendants() do
		if p:IsA("BasePart") and math.abs(p.Position.X - 130) < 1 then
			if p.Name == "Bar" and math.abs(p.Position.Z - TZ) < 5 then p:Destroy()
			elseif p.Name == "Rail" and p.Size.Z > 200 then
				-- the long rail is cut in two round the gap
				local z0, z1 = p.Position.Z - p.Size.Z / 2, p.Position.Z + p.Size.Z / 2
				local a = p:Clone(); a.Size = V(p.Size.X, p.Size.Y, (TZ - 4.5) - z0); a.Position = V(p.Position.X, p.Position.Y, (z0 + TZ - 4.5) / 2); a.Parent = p.Parent
				local b = p:Clone(); b.Size = V(p.Size.X, p.Size.Y, z1 - (TZ + 4.5)); b.Position = V(p.Position.X, p.Position.Y, (z1 + TZ + 4.5) / 2); b.Parent = p.Parent
				p:Destroy()
			end
		end
	end
end
local edge = L:FindFirstChild("Edge")
local movedTrees = 0
if edge then
	local trunks = {}
	for _, p in edge:GetDescendants() do
		if p:IsA("BasePart") and p.Name == "Trunk" and p.Position.X > 134 and math.abs(p.Position.Z - TZ) < 15 then table.insert(trunks, p) end
	end
	for _, t in trunks do
		local dz = (t.Position.Z >= TZ and 1 or -1) * (17 - math.abs(t.Position.Z - TZ) + rng:NextNumber(1, 5))
		for _, p in edge:GetDescendants() do
			if p:IsA("BasePart") and math.abs(p.Position.X - t.Position.X) < 0.7 and math.abs(p.Position.Z - t.Position.Z) < 0.7 then
				p.CFrame += V(0, 0, dz)
			end
		end
		movedTrees += 1
	end
end

-- 4 THE TRACK: buffers at the path's end, ballast, sleepers, rails out to the tunnel ---------------------------------------
local X0, X1 = 100, 236 -- buffers .. deep in the tunnel
do
	local g = group(S, "Track")
	P(g, "Ballast", V(X1 - X0, 0.35, 8), CFrame.new((X0 + X1) / 2, 0.18, TZ), C(58, 54, 50), M.Slate, "PS2_Stone")
	local x = X0 + 1.2
	while x < X1 do
		P(g, "Sleeper", V(0.9, 0.3, 6.6), CFrame.new(x, 0.45, TZ) * CFrame.Angles(0, math.rad(rng:NextNumber(-2, 2)), 0), BEAM:Lerp(C(30, 24, 20), rng:NextNumber(0, 0.6)), M.Wood, "PS2_DarkBeam")
		x += 2.2
	end
	for _, s in { -1, 1 } do
		P(g, "Rail", V(X1 - X0, 0.42, 0.34), CFrame.new((X0 + X1) / 2, 0.81, TZ + s * 2.2), RAIL, M.Metal)
	end
	-- the buffer stop: two iron posts, a red beam, a red lamp
	local bx = X0 + 0.4
	for _, s in { -1, 1 } do
		P(g, "BufferPost", V(0.8, 3.2, 0.8), CFrame.new(bx, 1.6, TZ + s * 2.4), IRON, M.Metal, nil, true)
		P(g, "BufferBrace", V(3.2, 0.5, 0.5), CFrame.new(bx - 1.2, 1.4, TZ + s * 2.4) * CFrame.Angles(0, 0, math.rad(-35)), IRON, M.Metal)
		cyl(g, "Buffer", 0.45, 0.8, CFrame.new(bx + 0.8, 2.2, TZ + s * 1.8), C(30, 30, 30), M.Metal)
	end
	P(g, "BufferBeam", V(0.8, 1.1, 6.4), CFrame.new(bx + 0.2, 2.2, TZ), C(140, 24, 18), M.Metal, nil, true)
	local lamp = P(g, "BufferLamp", V(0.6, 0.6, 0.6), CFrame.new(bx, 3.6, TZ), C(255, 40, 30), M.Neon)
	glow(lamp, C(255, 50, 40), 10, 1.2)
end

-- 5 THE PLATFORMS: stone, a worn edge, canopies with lanterns, benches, a clock, luggage ------------------------------------
local PX0, PX1 = 99, 128.5
local PH = 2.2 -- platform top = the carriage's floor (high enough for the wheels under it)
local function platform(side: number)
	local g = group(S, side > 0 and "PlatformSouth" or "PlatformNorth")
	local zIn, zOut = TZ + side * 3.6, TZ + side * 11
	local zc, w = (zIn + zOut) / 2, math.abs(zOut - zIn)
	P(g, "Platform", V(PX1 - PX0, PH, w), CFrame.new((PX0 + PX1) / 2, PH / 2, zc), STONE, M.Cobblestone, "PS2_Stone", true)
	P(g, "Edge", V(PX1 - PX0, 0.12, 0.8), CFrame.new((PX0 + PX1) / 2, PH + 0.06, zIn + side * 0.4), C(150, 132, 92), M.Slate)
	-- a ramp up from the path's end
	local ramp = Instance.new("WedgePart")
	ramp.Name = "Ramp"; ramp.Size = V(w, PH, 6); ramp.CFrame = CFrame.new(PX0 - 3, PH / 2, zc) * CFrame.Angles(0, math.rad(90), 0)
	ramp.Color = STONE_D; ramp.Material = M.Cobblestone; ramp.MaterialVariant = "PS2_Stone"; ramp.Anchored = true; ramp.CanCollide = true
	ramp.TopSurface = Enum.SurfaceType.Smooth; ramp.BottomSurface = Enum.SurfaceType.Smooth; ramp.Parent = g
	-- the canopy: posts along the outer side, a roof sloping down to the track
	local zPost = zOut - side * 0.8
	for _, x in { 102, 110, 118, 126 } do
		P(g, "CanopyPost", V(0.7, 9, 0.7), CFrame.new(x, PH + 4.5, zPost), BEAM, M.Wood, "PS2_DarkBeam", true)
		P(g, "CanopyBrace", V(0.4, 0.4, 4.2), CFrame.new(x, PH + 8.1, zPost - side * 1.9) * CFrame.Angles(side * math.rad(-28), 0, 0), BEAM, M.Wood, "PS2_DarkBeam")
		local lan = P(g, "Lantern", V(0.7, 0.9, 0.7), CFrame.new(x, PH + 6.6, zc - side * 0.5), WARM, M.Neon)
		P(g, "LanternHook", V(0.12, 1.6, 0.12), CFrame.new(x, PH + 7.85, zc - side * 0.5), IRON, M.Metal)
		glow(lan, WARM, 15, 0.95)
	end
	local roofW = w + 1.5
	P(g, "Roof", V(PX1 - PX0 + 1, 0.4, roofW), CFrame.new((PX0 + PX1) / 2, PH + 9.0, zc - side * 0.4) * CFrame.Angles(side * math.rad(9), 0, 0), C(46, 40, 38), M.Slate, "PS2_Roof")
	P(g, "RoofBeam", V(PX1 - PX0 + 1, 0.5, 0.5), CFrame.new((PX0 + PX1) / 2, PH + 8.9, zPost), BEAM, M.Wood, "PS2_DarkBeam")
	-- benches against the back
	for _, x in (side > 0 and { 104, 110 } or { 106, 122 }) do -- (south: clear of the carriage door's way out)
		local zb = zOut - side * 2.2
		P(g, "BenchSeat", V(4.4, 0.3, 1.3), CFrame.new(x, PH + 1.5, zb), PLANK, M.WoodPlanks, "PS2_FloorPlanks", true)
		P(g, "BenchBack", V(4.4, 1.3, 0.25), CFrame.new(x, PH + 2.4, zb + side * 0.6), PLANK, M.WoodPlanks, "PS2_FloorPlanks")
		for _, dx in { -1.8, 1.8 } do P(g, "BenchLeg", V(0.3, 1.4, 1.1), CFrame.new(x + dx, PH + 0.7, zb), IRON, M.Metal) end
	end
	return g
end
local south = platform(1)
platform(-1)
do -- the clock on its post, the luggage on the south platform
	local g = south
	local cx, cz = 116, TZ + 9.6
	P(g, "ClockPost", V(0.5, 7, 0.5), CFrame.new(cx, PH + 3.5, cz), IRON, M.Metal)
	local face = cyl(g, "ClockFace", 1.2, 0.3, CFrame.new(cx, PH + 7.6, cz) * CFrame.Angles(0, math.rad(90), 0), C(222, 210, 180), M.SmoothPlastic)
	face.CastShadow = false
	cyl(g, "ClockRim", 1.35, 0.25, CFrame.new(cx, PH + 7.6, cz) * CFrame.Angles(0, math.rad(90), 0), IRON, M.Metal)
	for _, s in { -1, 1 } do
		P(g, "ClockHand", V(0.12, 0.9, 0.05), CFrame.new(cx, PH + 7.6, cz + s * 0.2) * CFrame.Angles(0, 0, math.rad(40)) * CFrame.new(0, 0.4, 0), C(20, 20, 20), M.Metal)
		P(g, "ClockHand", V(0.12, 0.6, 0.05), CFrame.new(cx, PH + 7.6, cz + s * 0.2) * CFrame.Angles(0, 0, math.rad(-110)) * CFrame.new(0, 0.28, 0), C(20, 20, 20), M.Metal)
	end
	-- luggage: a trunk, a case on it, a bag beside them
	local cases = { { 126.2, 8.8, V(2.2, 1.4, 1.4), C(92, 54, 34), 0 }, { 126.4, 8.7, V(1.6, 1.0, 1.1), C(60, 64, 52), 1.4 }, { 124.3, 9.0, V(1.6, 0.8, 1.1), C(110, 30, 26), 0 } }
	for _, c in cases do
		local sz = c[3] :: Vector3
		P(g, "Luggage", sz, CFrame.new(c[1] :: number, PH + (c[5] :: number) + sz.Y / 2, TZ + (c[2] :: number)) * CFrame.Angles(0, math.rad(rng:NextNumber(-20, 20)), 0), c[4] :: Color3, M.WoodPlanks, "PS2_Siding")
	end
end

-- 6 THE ARCH in the fence: "PARK STATION" -------------------------------------------------------------------------------
do
	local g = group(S, "Arch")
	local ax = 131
	for _, s in { -1, 1 } do
		P(g, "ArchPillar", V(3, 14, 3), CFrame.new(ax, 7, TZ + s * 6), STONE, M.Cobblestone, "PS2_Stone", true)
		P(g, "ArchCap", V(3.6, 0.8, 3.6), CFrame.new(ax, 14.4, TZ + s * 6), STONE_D, M.Cobblestone, "PS2_Stone")
		local lan = P(g, "ArchLantern", V(0.8, 1, 0.8), CFrame.new(ax - 1.9, 9.5, TZ + s * 6), WARM, M.Neon)
		glow(lan, WARM, 16, 1)
	end
	P(g, "ArchBeam", V(2.6, 2.2, 15), CFrame.new(ax, 15.6, TZ), STONE_D, M.Cobblestone, "PS2_Stone")
	local board = P(g, "ArchSign", V(0.4, 2.6, 11), CFrame.new(ax - 1.5, 15.6, TZ), C(34, 26, 20), M.Wood, "PS2_DarkBeam")
	-- (the sign's faces: Left looks into the park (-X), Right out of it)
	sign(board, Enum.NormalId.Left, "PARK STATION", C(240, 190, 90))
	sign(board, Enum.NormalId.Right, "PARK STATION", C(240, 190, 90))
end

-- 7 THE TUNNEL in a rocky hill behind the pines --------------------------------------------------------------------------
do
	local g = group(S, "Tunnel")
	local tx = 196
	-- the portal: a stone face with a dark mouth
	P(g, "PortalLeft", V(4, 16, 9), CFrame.new(tx, 8, TZ - 9.5), STONE, M.Cobblestone, "PS2_Stone")
	P(g, "PortalRight", V(4, 16, 9), CFrame.new(tx, 8, TZ + 9.5), STONE, M.Cobblestone, "PS2_Stone")
	P(g, "PortalTop", V(4, 5, 10), CFrame.new(tx, 13.5, TZ), STONE, M.Cobblestone, "PS2_Stone")
	P(g, "Keystone", V(4.4, 2.2, 2.4), CFrame.new(tx - 0.2, 12.4, TZ), STONE_D, M.Cobblestone, "PS2_Stone")
	-- the dark inside (the train waits in there)
	P(g, "Inside", V(42, 11, 10), CFrame.new(tx + 22, 5.5, TZ), C(6, 6, 6), M.SmoothPlastic)
	-- the hill round it: dark rock on both sides of the mouth and over it, stepping back and up
	for _, sd in { -1, 1 } do
		P(g, "Rock", V(16, 20, 18), CFrame.new(tx + 9, 10, TZ + sd * 14) * CFrame.Angles(0, math.rad(rng:NextNumber(-4, 4)), 0), C(46, 44, 42), M.Slate, "PS2_Stone")
		P(g, "Rock", V(14, 12, 14), CFrame.new(tx + 14, 26, TZ + sd * 12) * CFrame.Angles(0, math.rad(rng:NextNumber(-8, 8)), 0), C(42, 40, 38), M.Slate, "PS2_Stone")
	end
	P(g, "Rock", V(16, 10, 46), CFrame.new(tx + 9, 21, TZ), C(44, 42, 40), M.Slate, "PS2_Stone")
	P(g, "Rock", V(14, 10, 30), CFrame.new(tx + 16, 32, TZ), C(40, 38, 36), M.Slate, "PS2_Stone")
	P(g, "Rock", V(24, 34, 60), CFrame.new(tx + 30, 17, TZ), C(36, 36, 34), M.Slate, "PS2_Stone")
	for i = 1, 8 do
		local sd = i % 2 == 0 and 1 or -1
		P(g, "Boulder", V(rng:NextNumber(4, 9), rng:NextNumber(4, 10), rng:NextNumber(4, 9)), CFrame.new(tx + rng:NextNumber(-3, 8), rng:NextNumber(1, 4), TZ + sd * rng:NextNumber(14, 26)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6), rng:NextNumber(-0.3, 0.3)), C(50, 48, 46), M.Slate, "PS2_Stone")
	end
end

-- 8 THE TRAIN (ReplicatedStorage.Intro.Train): built where it stops, front at the buffers ---------------------------------
local train = Instance.new("Model"); train.Name = "Train"
local FRONT = X0 + 1.5 -- the front of the locomotive when it has stopped
local root = P(train, "Root", V(0.4, 0.4, 0.4), CFrame.new(FRONT, 1, TZ), C(0, 0, 0), M.SmoothPlastic)
root.Transparency = 1
train.PrimaryPart = root
local BLACK, BOILER, BRASS, REDW = C(22, 22, 24), C(30, 36, 33), C(150, 118, 58), C(132, 26, 20)
local MAROON = C(84, 22, 20)
local function wheel(x: number, z: number, r: number)
	local y = r + 0.95 -- (on the rails)
	local w = cyl(train, "Wheel", r, 0.5, CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(90), 0), BLACK, M.Metal)
	w:SetAttribute("R", r)
	local hub = cyl(train, "Wheel", r * 0.55, 0.55, CFrame.new(x, y, z) * CFrame.Angles(0, math.rad(90), 0), REDW, M.Metal)
	hub:SetAttribute("R", r)
	P(train, "Wheel", V(0.25, r * 1.7, 0.56), CFrame.new(x, y, z), BLACK, M.Metal):SetAttribute("R", r) -- (a spoke: it turns too)
end
do -- the locomotive (x FRONT .. FRONT+16)
	local f = FRONT
	P(train, "Frame", V(16, 1, 5.6), CFrame.new(f + 8, 2.9, TZ), BLACK, M.Metal)
	P(train, "BufferBeam", V(0.6, 1.2, 6.2), CFrame.new(f + 0.3, 3.1, TZ), REDW, M.Metal)
	for _, s in { -1, 1 } do cyl(train, "Buffer", 0.4, 0.7, CFrame.new(f - 0.3, 3.1, TZ + s * 1.8), C(40, 40, 40), M.Metal) end
	local cc = P(train, "Cowcatcher", V(1.6, 1.4, 5.4), CFrame.new(f + 0.2, 0.9, TZ) * CFrame.Angles(0, math.rad(180), 0), REDW, M.Metal)
	local wedge = Instance.new("WedgePart")
	wedge.Name = "Cowcatcher"; wedge.Size = V(5.4, 1.4, 1.6); wedge.CFrame = CFrame.new(f - 0.6, 1.8, TZ) * CFrame.Angles(0, math.rad(90), 0)
	wedge.Color = REDW; wedge.Material = M.Metal; wedge.Anchored = true; wedge.CanCollide = false; wedge.CanQuery = false; wedge.CanTouch = false; wedge.Parent = train
	cc:Destroy()
	cyl(train, "Boiler", 2.2, 9.5, CFrame.new(f + 6.6, 5.6, TZ), BOILER, M.Metal)
	cyl(train, "Smokebox", 2.35, 1.4, CFrame.new(f + 1.6, 5.6, TZ), C(18, 18, 20), M.Metal)
	cyl(train, "SmokeboxDoor", 1.6, 0.3, CFrame.new(f + 0.85, 5.6, TZ), C(26, 26, 28), M.Metal)
	for _, x in { 3.4, 6.6, 9.8 } do cyl(train, "Band", 2.28, 0.3, CFrame.new(f + x, 4.6, TZ), BRASS, M.Metal) end
	local chim = cyl(train, "Chimney", 0.7, 2.8, CFrame.new(f + 2.2, 8.9, TZ) * CFrame.Angles(0, 0, math.rad(90)), BLACK, M.Metal)
	cyl(train, "ChimneyTop", 0.95, 0.5, CFrame.new(f + 2.2, 10.3, TZ) * CFrame.Angles(0, 0, math.rad(90)), BLACK, M.Metal)
	local smoke = P(train, "SmokeOut", V(0.3, 0.3, 0.3), CFrame.new(f + 2.2, 10.8, TZ), BLACK, M.SmoothPlastic)
	smoke.Transparency = 1
	local _ = chim
	cyl(train, "Dome", 0.9, 1.3, CFrame.new(f + 7, 8.1, TZ) * CFrame.Angles(0, 0, math.rad(90)), BRASS, M.Metal)
	local lampBox = P(train, "LampBox", V(1, 1.1, 1.1), CFrame.new(f + 1.6, 8.4, TZ), BLACK, M.Metal)
	local _2 = lampBox
	local lamp = P(train, "HeadLamp", V(0.15, 0.8, 0.8), CFrame.new(f + 1.05, 8.4, TZ), C(255, 226, 150), M.Neon)
	local spot = Instance.new("SpotLight"); spot.Face = Enum.NormalId.Left; spot.Range = 60; spot.Angle = 50; spot.Brightness = 3; spot.Color = C(255, 226, 160); spot.Parent = lamp
	-- the cab
	P(train, "CabFloor", V(5.6, 0.4, 6.6), CFrame.new(f + 14.6, 3.6, TZ), BLACK, M.Metal)
	P(train, "CabFront", V(0.4, 4.6, 6.6), CFrame.new(f + 12, 6, TZ), MAROON, M.Metal)
	for _, s in { -1, 1 } do
		P(train, "CabSide", V(5.6, 2.6, 0.3), CFrame.new(f + 14.6, 5, TZ + s * 3.15), MAROON, M.Metal)
		P(train, "CabPillar", V(0.5, 3.4, 0.3), CFrame.new(f + 12.4, 8, TZ + s * 3.15), MAROON, M.Metal)
		P(train, "CabPillar", V(0.5, 3.4, 0.3), CFrame.new(f + 17.1, 8, TZ + s * 3.15), MAROON, M.Metal)
		local win = P(train, "CabWindow", V(0.2, 1.2, 1.2), CFrame.new(f + 11.85, 7.4, TZ + s * 1.8), C(255, 150, 70), M.Neon)
		win.Transparency = 0.3
	end
	P(train, "CabRoof", V(6.6, 0.4, 7.2), CFrame.new(f + 14.6, 9.9, TZ), BLACK, M.Metal)
	local fire = P(train, "Firebox", V(0.6, 0.8, 1.6), CFrame.new(f + 12.4, 4.4, TZ), C(255, 110, 40), M.Neon)
	glow(fire, C(255, 120, 50), 9, 1.5)
	for _, x in { 5.5, 9, 12.5 } do for _, s in { -1, 1 } do wheel(f + x, TZ + s * 2.55, 1.5) end end
	for _, s in { -1, 1 } do wheel(f + 2.4, TZ + s * 2.55, 0.85) end
	P(train, "Coupling", V(1.4, 0.4, 0.4), CFrame.new(f + 16.6, 2.9, TZ), BLACK, M.Metal)
end
do -- the carriage (x FRONT+17.4 .. +35.4): its floor is the platform's height, a door on the south side
	local x0 = FRONT + 17.4
	local L2 = 18
	local xm = x0 + L2 / 2
	local zS, zN = TZ + 3.3, TZ - 3.3
	P(train, "Underframe", V(L2, 0.6, 5.6), CFrame.new(xm, PH - 0.45, TZ), BLACK, M.Metal)
	local floor = P(train, "CarFloor", V(L2, 0.3, 6.6), CFrame.new(xm, PH - 0.15, TZ), C(40, 30, 24), M.WoodPlanks, "PS2_FloorPlanks", true)
	floor:SetAttribute("Floor", true)
	local DX0, DX1 = x0 + 2.6, x0 + 5.6 -- the door's opening (clear of the bogie's wheels under the floor)
	train:SetAttribute("DoorX", (DX0 + DX1) / 2 - FRONT)
	local function wallRun(z: number, from: number, to: number, withWindows: boolean)
		local len = to - from
		if len <= 0.05 then return end
		local xc = (from + to) / 2
		P(train, "Wall", V(len, 2.4, 0.3), CFrame.new(xc, PH + 1.2, z), MAROON, M.WoodPlanks, "PS2_Siding")
		P(train, "Wall", V(len, 1.2, 0.3), CFrame.new(xc, PH + 6.2, z), MAROON, M.WoodPlanks, "PS2_Siding")
		if withWindows then
			-- windows: warm light between narrow posts
			local n = math.max(1, math.floor(len / 2.6))
			local step = len / n
			for i = 0, n - 1 do
				local wx = from + step * (i + 0.5)
				local win = P(train, "Window", V(step - 0.6, 3.2, 0.15), CFrame.new(wx, PH + 4.0, z), C(255, 190, 110), M.Neon)
				win.Transparency = 0.35
			end
			for i = 0, n do
				P(train, "WindowPost", V(0.5, 3.3, 0.32), CFrame.new(from + step * i, PH + 4.0, z), C(60, 18, 16), M.WoodPlanks, "PS2_Siding")
			end
		end
	end
	-- south side: round the door; north side: whole
	wallRun(zS, x0, DX0, true)
	wallRun(zS, DX1, x0 + L2, true)
	P(train, "DoorHead", V(DX1 - DX0, 1.6, 0.3), CFrame.new((DX0 + DX1) / 2, PH + 6.0, zS), MAROON, M.WoodPlanks, "PS2_Siding")
	wallRun(zN, x0, x0 + L2, true)
	for _, x in { x0, x0 + L2 } do P(train, "EndWall", V(0.3, 6.8, 6.6), CFrame.new(x, PH + 3.4, TZ), MAROON, M.WoodPlanks, "PS2_Siding") end
	P(train, "Roof", V(L2 + 0.8, 0.5, 7.4), CFrame.new(xm, PH + 7.05, TZ), C(36, 32, 30), M.Slate, "PS2_Roof")
	P(train, "Clerestory", V(L2 - 2, 0.8, 3), CFrame.new(xm, PH + 7.7, TZ), C(36, 32, 30), M.Slate, "PS2_Roof")
	for _, s in { -1, 1 } do P(train, "Gutter", V(L2 + 0.8, 0.25, 0.3), CFrame.new(xm, PH + 6.8, TZ + s * 3.6), BLACK, M.Metal) end
	-- the door (slides along the side when it opens: Client/Intro) and its warm-lit inside
	local door = P(train, "Door", V(DX1 - DX0, 5.2, 0.25), CFrame.new((DX0 + DX1) / 2, PH + 2.6, zS + 0.2), C(70, 18, 16), M.WoodPlanks, "PS2_Siding")
	local dwin = P(train, "DoorWindow", V(1.4, 1.4, 0.3), CFrame.new((DX0 + DX1) / 2, PH + 3.9, zS + 0.2), C(255, 190, 110), M.Neon)
	dwin.Transparency = 0.35
	local inLight = P(train, "InsideLight", V(0.4, 0.2, 0.4), CFrame.new(xm, PH + 6.5, TZ), C(255, 200, 130), M.Neon)
	glow(inLight, C(255, 190, 120), 14, 1.4)
	P(train, "Step", V(DX1 - DX0, 0.25, 0.6), CFrame.new((DX0 + DX1) / 2, PH - 0.3, zS + 0.35), BLACK, M.Metal)
	for _, bx in { x0 + 3.2, x0 + L2 - 3.2 } do
		for _, dx in { -1.1, 1.1 } do for _, s in { -1, 1 } do wheel(bx + dx, TZ + s * 2.55, 0.6) end end
		P(train, "Bogie", V(3.6, 0.5, 5.0), CFrame.new(bx, 1.55, TZ), BLACK, M.Metal)
	end
end
train.Parent = intro

return string.format("leaderboards moved %d, signs relabelled %d, pines moved %d, station parts %d, train parts %d",
	moved, relabelled, movedTrees, #S:GetDescendants(), #train:GetDescendants())
