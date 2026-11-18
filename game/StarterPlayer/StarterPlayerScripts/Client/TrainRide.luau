--!strict
-- TRAIN RIDES: every trip to a map's building goes by train (Shared/Campaign). Client only, on this screen's own
-- copy of ReplicatedStorage.Intro.Train (tools/build/lobby_station.luau):
--   TrainRide.depart(stageId, diffId, byName, fromPark): at a window seat; the train pulls out (the park: it backs
--     into the station's tunnel; the yard: it rolls off along the railway into the woods), black, and the next
--     building's title card ("CAMP HOLLOWMERE / THE BUNKHOUSE / NORMAL") until the trip itself takes over.
--   TrainRide.arrive(stageId, diffId): the title card, then the train rolls along the yard's railway (Grounds.Railway,
--     z = 150) and stops in front of the building; the door slides open and you're out in the yard (the server
--     holds your body out of sight for the ride, Server/Run). The train then waits there (TrainRide.parked) for the
--     ride to the next building.
-- During a ride the player is anchored, their body hidden, the HUD off and the camera scripted (hands hidden).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Campaign = require(RS.Shared.Campaign)
local Maps = require(RS.Shared.Maps)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)

local TR = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local A = CFrame.Angles
local Fx: any = nil
local HUD: any = nil
local riding = false
local yardTrain: any = nil -- the copy parked on the yard's railway between rides
local SEAT = Vector3.new(28.5, 0, 0.6) -- (by a window on the door's side, in the train's frame)
local RAIL_Z, RAIL_Y = 150, 1.1 -- the yard's railway (tools/build/grounds.luau)
local STOP_X = 0 -- the door stops in front of the house's front door

function TR.init(fx, hud) Fx = fx; HUD = hud end
function TR.busy(): boolean return riding end

local function ss(x: number): number x = math.clamp(x, 0, 1); return x * x * (3 - 2 * x) end

-- a copy of the train: place() moves it (wheels turn with `rolled`), door 0..1 slides its door, glass() clears the windows
local function newTrain(parent: Instance): any
	local set = RS:FindFirstChild("Intro")
	local src = set and set:FindFirstChild("Train") :: Model?
	if not src or not src.PrimaryPart then return nil end
	local m = src:Clone()
	m.Name = "RideTrain"
	local base = (m.PrimaryPart :: BasePart).CFrame
	local items = {} :: { { p: BasePart, off: CFrame, r: number, cyl: boolean } }
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true; d.CanCollide = false; d.CanQuery = false; d.CanTouch = false
			local r = d:GetAttribute("R")
			table.insert(items, { p = d, off = base:ToObjectSpace(d.CFrame), r = type(r) == "number" and r or 0, cyl = d:IsA("Part") and d.Shape == Enum.PartType.Cylinder })
		end
	end
	local doorP, doorW = m:FindFirstChild("Door"), m:FindFirstChild("DoorWindow")
	local fl = m:FindFirstChild("CarFloor") :: BasePart?
	local T: any = { model = m, cf = base, home = base, rolled = 0, door = 0, root = m.PrimaryPart,
		doorLocal = Vector3.new(tonumber(m:GetAttribute("DoorX")) or 21.5, 0, 3.3),
		floorLocal = fl and (base:PointToObjectSpace(fl.Position).Y + fl.Size.Y / 2) or 1.2 }
	function T.place()
		for _, e in items do
			local off = e.off
			if e.r > 0 then
				local a = T.rolled / e.r
				off = off * (e.cyl and A(-a, 0, 0) or A(0, 0, a))
			elseif T.door > 0 and (e.p == doorP or e.p == doorW) then
				off = CFrame.new(3.1 * T.door, 0, 0) * off
			end
			e.p.CFrame = T.cf * off
		end
	end
	function T.glass(on: boolean)
		for _, e in items do
			if e.p.Name == "Window" or e.p.Name == "DoorWindow" then
				e.p.Material = on and Enum.Material.Glass or Enum.Material.Neon
				e.p.Transparency = on and 0.82 or 0.35
			end
		end
	end
	local smokeAt = m:FindFirstChild("SmokeOut") :: BasePart?
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(Color3.fromRGB(70, 66, 64), Color3.fromRGB(40, 38, 38))
	pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 4) })
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
	pe.Lifetime = NumberRange.new(1.2, 1.8); pe.Rate = 0; pe.Speed = NumberRange.new(4, 7)
	pe.EmissionDirection = Enum.NormalId.Top; pe.SpreadAngle = Vector2.new(12, 12)
	pe.Acceleration = Vector3.new(0, 2, 0); pe.LightInfluence = 0.6
	pe.Parent = smokeAt or m.PrimaryPart
	function T.smoke(rate: number) pe.Rate = rate end
	-- a warm lamp in the carriage (the rides happen at night: the seat, the windows and the door must show)
	local lampAt = fl or m.PrimaryPart
	if lampAt then
		local lamp = Instance.new("PointLight")
		lamp.Name = "RideLamp"; lamp.Color = Color3.fromRGB(255, 196, 140); lamp.Range = 22; lamp.Brightness = 1.8; lamp.Shadows = false
		lamp.Parent = lampAt
	end
	function T.at(l: Vector3): Vector3 return T.cf * l end
	-- roll along its own X by dx (positive = backward, toward its back end)
	function T.roll(x: number)
		T.rolled += x - (T.x or 0)
		T.x = x
		T.cf = T.home * CFrame.new(x, 0, 0)
		T.place()
	end
	T.x = 0
	T.place()
	m.Parent = parent
	return T
end

-- the train standing on the yard's railway, its door (its +Z side) toward the house, the door at x = STOP_X
local function yardPose(): CFrame
	local outward = Vector3.new(0, 0, 1)
	local UP = Vector3.yAxis
	local rot = CFrame.fromMatrix(Vector3.zero, UP:Cross(-outward), UP)
	local doorTarget = Vector3.new(STOP_X, RAIL_Y + 0.19, RAIL_Z) - outward * 3.3
	return rot + (doorTarget - rot * Vector3.new(21.5, 0, 3.3))
end

-- the server's parked train at the park's station (hidden on this screen while it is ridden)
local function parkTrain(): Model?
	local lobby = workspace:FindFirstChild("Lobby")
	local st = lobby and lobby:FindFirstChild("Station")
	return st and st:FindFirstChild("ParkedTrain") :: Model?
end
local function hideModel(m: Instance?, on: boolean)
	if not m then return end
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then d.LocalTransparencyModifier = on and 1 or 0 end
	end
end

-- the title card: map name, building name, difficulty and the building's number
local cardGui: ScreenGui? = nil
local function card(stageId: string, diffId: string, show: boolean, sub: string?)
	if cardGui then cardGui:Destroy(); cardGui = nil end
	if not show then return end
	local st = Campaign.stage(stageId)
	local mp = st and Campaign.mapById[st.map]
	local d = Maps.diffById[diffId] or Maps.diffById.Normal
	local g = Instance.new("ScreenGui")
	g.Name = "TrainCard"; g.IgnoreGuiInset = true; g.DisplayOrder = 40; g.ResetOnSpawn = false
	g.Parent = lp:WaitForChild("PlayerGui")
	cardGui = g
	local bg = Grunge.frame(g, { BackgroundTransparency = 0, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 1 })
	bg.Name = "Black"
	Grunge.text(g, { Text = mp and mp.name or "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.34),
		Size = UDim2.fromScale(0.6, 0.05), TextColor3 = mp and mp.color or Grunge.PAPER, ZIndex = 3 })
	local t = Grunge.text(g, { Text = st and st.name or "", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromScale(0.8, 0.14), TextColor3 = Color3.fromRGB(235, 50, 35), TextStrokeTransparency = 0, ZIndex = 3 })
	local sc = Instance.new("UIScale"); sc.Scale = 1.4; sc.Parent = t
	TweenService:Create(sc, TweenInfo.new(0.45, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	local total = mp and #mp.stages or 0
	Grunge.text(g, { Text = (st and ("BUILDING " .. st.index .. " OF " .. total .. "   -   ") or "") .. d.name, Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.56), Size = UDim2.fromScale(0.6, 0.05), TextColor3 = d.color, ZIndex = 3 })
	if sub and sub ~= "" then
		Grunge.text(g, { Text = sub, Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.64),
			Size = UDim2.fromScale(0.6, 0.035), TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 3 })
	end
end
local function cardFade(t: number)
	local g = cardGui
	if not g then return end
	for _, d in g:GetDescendants() do
		if d:IsA("TextLabel") then TweenService:Create(d, TweenInfo.new(t), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		elseif d:IsA("Frame") and d.Name == "Black" then TweenService:Create(d, TweenInfo.new(t), { BackgroundTransparency = 1 }):Play() end
	end
	task.delay(t + 0.1, function() if cardGui == g then g:Destroy(); cardGui = nil end end)
end
local blackGui: ScreenGui? = nil
local function black(on: boolean, t: number)
	if not blackGui then
		local g = Instance.new("ScreenGui")
		g.Name = "TrainBlack"; g.IgnoreGuiInset = true; g.DisplayOrder = 39; g.ResetOnSpawn = false
		g.Parent = lp:WaitForChild("PlayerGui")
		local f = Instance.new("Frame"); f.Name = "F"; f.BackgroundColor3 = Color3.new(0, 0, 0); f.BorderSizePixel = 0
		f.Size = UDim2.fromScale(1, 1); f.BackgroundTransparency = 1; f.Parent = g
		blackGui = g
	end
	local f = (blackGui :: ScreenGui):FindFirstChild("F") :: Frame
	TweenService:Create(f, TweenInfo.new(t), { BackgroundTransparency = on and 0 or 1 }):Play()
end

-- every other screen is put away during a ride (the PLAY panel, the shop, the HUD...) and comes back after
local hiddenGuis = {} :: { ScreenGui }
local function hideScreens(on: boolean)
	if on then
		for _, g in lp:WaitForChild("PlayerGui"):GetChildren() do
			if g:IsA("ScreenGui") and g.Enabled and g.Name ~= "TrainBlack" and g.Name ~= "TrainCard" and g.Name ~= "PromptHolder" then
				g.Enabled = false
				table.insert(hiddenGuis, g)
			end
		end
	else
		for _, g in hiddenGuis do if g.Parent then g.Enabled = true end end
		table.clear(hiddenGuis)
	end
end

-- the ride's frame: player held still, body hidden, HUD off, camera = camFn() every frame
local function ride(camFn: () -> CFrame, fov: number): () -> ()
	riding = true
	hideScreens(true)
	local ch = lp.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp then hrp.Anchored = true end
	if HUD then HUD.setVisible(false) end
	if Fx then Fx.cineFov = fov; Fx.cine = true end
	cam.CameraType = Enum.CameraType.Scriptable
	RunService:BindToRenderStep("TrainRide", Enum.RenderPriority.Camera.Value + 2, function()
		local cf = camFn()
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = cf
		cam.Focus = cf * CFrame.new(0, 0, -30) -- (far focus: the first-person hands stay hidden)
		local c = lp.Character
		if c then
			for _, d in c:GetDescendants() do
				if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
			end
		end
	end)
	return function()
		RunService:UnbindFromRenderStep("TrainRide")
		local c = lp.Character
		local h = c and c:FindFirstChild("HumanoidRootPart") :: BasePart?
		if h then h.Anchored = false end
		if c then
			for _, d in c:GetDescendants() do
				if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.LocalTransparencyModifier = 0 end
			end
		end
		cam.CameraType = Enum.CameraType.Custom
		if Fx then Fx.cineFov = nil; Fx.cine = false end
		if HUD then HUD.setVisible(true) end
		hideScreens(false)
		riding = false
	end
end

-- the seat's camera: out of the door-side window, `ahead` = how much it looks along the train (+ = toward its front)
local function seatCam(T: any, ahead: number, down: number?): CFrame
	local p = T.at(Vector3.new(SEAT.X, T.floorLocal + 4.4, SEAT.Z))
	local look = T.cf:VectorToWorldSpace(Vector3.new(-ahead, -(down or 0.05), 1).Unit)
	return CFrame.lookAt(p, p + look * 10)
end

local function clearYard()
	if yardTrain then yardTrain.model:Destroy(); yardTrain = nil end
end

-- the train waits on the yard's railway (between the arrival and the next ride); off = take it away
function TR.parked(on: boolean)
	if not on then clearYard(); return end
	if yardTrain then return end
	local f = workspace:FindFirstChild("YardTrain") or Instance.new("Folder")
	f.Name = "YardTrain"; f.Parent = workspace
	local T = newTrain(f)
	if not T then return end
	T.home = yardPose()
	T.roll(0)
	T.glass(true)
	T.door = 1; T.place()
	T.smoke(3)
	yardTrain = T
end

-- leave: from the park's station (fromPark) or from the yard
function TR.depart(stageId: string, diffId: string, byName: string?, fromPark: boolean?)
	if riding then return end
	local Loading = require(game:GetService("ReplicatedFirst"):WaitForChild("Loading")) :: any
	local f = workspace:FindFirstChild("RideTrainFolder") or Instance.new("Folder")
	f.Name = "RideTrainFolder"; f.Parent = workspace
	local T: any
	if fromPark then
		T = newTrain(f)
		if not T then return end
		hideModel(parkTrain(), true)
	else
		if not yardTrain then TR.parked(true) end
		T = yardTrain
		if not T then return end
	end
	T.glass(true)
	T.door = 1; T.place()
	local t0 = os.clock()
	local dir = fromPark and 1 or -1 -- the park: backs into the tunnel (+X); the yard: forward into the woods (-X)
	black(true, 0.25)
	task.wait(0.3)
	local stop = ride(function()
		local t = os.clock() - t0
		return seatCam(T, dir > 0 and -0.35 or 0.4, 0.02) * CFrame.new(0, math.sin(t * 9) * 0.03 * math.min(1, t / 2), 0)
	end, 62)
	black(false, 0.35)
	if byName and byName ~= "" and HUD then HUD.toast(string.upper(byName) .. " TOOK THE TRAIN", true) end
	-- the door slides shut, the whistle, it pulls away
	local shut0 = os.clock()
	Sfx.at("TrainDoor", T.at(T.doorLocal), { Volume = 1 })
	while os.clock() - shut0 < 0.6 do
		T.door = 1 - ss((os.clock() - shut0) / 0.55); T.place()
		RunService.RenderStepped:Wait()
	end
	Sfx.at("TrainWhistle", T.root.Position, { Volume = 1.1 })
	if Fx then Fx.shake(0.25) end
	local rollSnd = Sfx.on("TrainRoll", T.root, { Volume = 0.8 })
	T.smoke(16)
	local g0 = os.clock()
	local dur = 4.2
	while os.clock() - g0 < dur do
		local t = os.clock() - g0
		T.roll(dir * 3.4 * t * t)
		if t > dur - 1.1 then black(true, 0.9) end
		RunService.RenderStepped:Wait()
	end
	card(stageId, diffId, true, "ALL ABOARD...")
	if rollSnd then rollSnd:Destroy() end
	stop()
	if fromPark then
		T.model:Destroy()
		hideModel(parkTrain(), false)
		-- (the trip takes over: the loading card in front of the title card)
		task.delay(1.6, function() card("", "", false); black(false, 0.1) end)
	else
		clearYard()
		-- (the server brings the next building: TR.arrive replaces the card)
		task.delay(6, function() if not riding then card("", "", false); black(false, 0.3) end end)
	end
	local _ = Loading
end

-- arrive in the yard of a building
function TR.arrive(stageId: string, diffId: string)
	if riding then return end
	local Loading = require(game:GetService("ReplicatedFirst"):WaitForChild("Loading")) :: any
	pcall(function() Loading.hide(0.2) end)
	clearYard()
	black(true, 0)
	card(stageId, diffId, true)
	local f = workspace:FindFirstChild("YardTrain") or Instance.new("Folder")
	f.Name = "YardTrain"; f.Parent = workspace
	local T = newTrain(f)
	if not T then
		task.wait(2); card("", "", false); black(false, 0.4)
		return
	end
	yardTrain = T
	T.home = yardPose()
	T.glass(true)
	local RUN, T_IN = 150, 5.6 -- (it comes out of the woods to the west, slowing all the way)
	T.roll(RUN)
	T.smoke(14)
	local t0 = os.clock()
	local doorTurn = 0
	local stop = ride(function()
		local t = os.clock() - t0
		local cf = seatCam(T, 0.75 * (1 - doorTurn), 0.03 + 0.1 * doorTurn)
		return cf * CFrame.new(0, math.sin(t * 8) * 0.03 * (1 - doorTurn), 0)
	end, 60)
	local rollIn = Sfx.on("TrainRoll", T.root, { Volume = 0.9 })
	task.wait(1.4)
	cardFade(0.9)
	black(false, 0.9) -- (the ride shows: out of the woods, along the yard)
	Sfx.play("TrainWhistle", { Volume = 0.8 })
	local a0 = os.clock()
	while os.clock() - a0 < T_IN do
		local u = math.clamp((os.clock() - a0) / T_IN, 0, 1)
		T.roll(RUN * (1 - u) * (1 - u))
		if rollIn then rollIn.Volume = 0.9 * math.min(1, (1 - u) * 2.5) + 0.05 end
		doorTurn = ss((u - 0.75) / 0.25) * 0.6
		RunService.RenderStepped:Wait()
	end
	T.roll(0)
	T.smoke(3)
	if rollIn then rollIn:Destroy() end
	if Fx then Fx.shake(0.2) end
	Sfx.at("TrainClank", T.root.Position, { Volume = 0.9 })
	Sfx.at("TrainSteam", T.root.Position, { Volume = 1 })
	-- the door slides open, a blink, and you're standing in the yard
	local o1 = os.clock()
	Sfx.at("TrainDoor", T.at(T.doorLocal), { Volume = 1 })
	while os.clock() - o1 < 0.7 do
		doorTurn = 0.6 + 0.4 * ss((os.clock() - o1) / 0.6)
		T.door = ss((os.clock() - o1) / 0.6); T.place()
		RunService.RenderStepped:Wait()
	end
	T.door = 1; T.place()
	black(true, 0.25)
	task.wait(0.35)
	stop()
	-- standing in the yard, looking at the building's front door
	local ch = lp.Character
	local head = ch and ch:FindFirstChild("Head") :: BasePart?
	if head then cam.CFrame = CFrame.lookAt(head.Position, Vector3.new(0, 8, 60)) end
	black(false, 0.45)
end

-- the server takes this player out of the house (or the run ends): no ride left on screen
function TR.reset()
	clearYard()
	card("", "", false)
	if blackGui then (blackGui:FindFirstChild("F") :: Frame).BackgroundTransparency = 1 end
end

return TR
