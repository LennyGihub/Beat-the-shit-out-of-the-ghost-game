--!strict
-- THE INTRO: a new player's first minute (Client/TutorialUI starts it on their first join; HOW TO PLAY replays it).
-- It happens in the house of the first map, the Mansion, in its TV room (Server/Tutorial puts the player there,
-- the armchair facing the TV):
--   1 THE TV (a cinematic): night, the player in the armchair, static on the TV. A shape comes closer in the
--     static, her hand presses on the glass from inside, the glass cracks and her claws burst through; she drags
--     herself out head first, drops to the floor, scuttles on all fours to the armchair, unfolds to her full height
--     in three jerks, screams and lunges - and the music drops (the Plague King's "Black Plague"). That Woman is this
--     screen's own copy (ReplicatedStorage.Intro.Woman, tools/build/intro_set.luau); at the drop the real monster
--     takes her place (Server/Tutorial "spawn").
--   2 THE LESSONS, each one frozen (the world stops, the colour drains, the music sinks; one word and the key), on
--     the real Woman with the game's own moves: BLOCK (frozen on her lunge: the press is when the game begins, her
--     claws coming down on the guard), ATTACK (and a few more punches), LIFT (the armchair you sat in), THROW (it
--     can't miss: the server steers it onto her), ULTIMATE (the bar fills with the screen shaking harder and
--     harder, going red: the anger building; the Rage Shockwave: this once it only stuns her).
--   3 THE FIGHT: a short real fight (she swings, waits, swings again): charged hits knock her out and smash her
--     through the walls (the ragdoll). It ends when she is beaten (or after a while).
--   4 THE WAY OUT: in the front hall the shut doors burst open; a train waits across the yard, its door open (this
--     screen's own copy of ReplicatedStorage.Intro.Train on its own stretch of track). Out across the porch, down the
--     yard, up into the carriage, to a window seat; the door shuts and it pulls away, the house sliding off past the
--     window. "BEAT EVERY GHOST!". Still at the window: out of the tunnel at the park's station (Lobby.Station),
--     along the platform, stop; the door opens, the player steps out and walks off toward the park, where the lobby's
--     camera takes over (no black screen); the train backs out into the tunnel.
-- SKIP (the button, or a controller's Select) ends it at any time but in the fight.
-- Player attribute IntroPhase (this client only): enter, tv, freeze:<Action>, lesson, fight, exit, arrive, done.
-- Studio test hooks: player attribute DebugIntroAct = "Block" | "Punch" | "Lift" | "Ultimate" | "Skip" acts as that
-- input (set it to something else first to repeat one); DebugIntroHoldAt = the scene's second at which the
-- cinematic's clock stops (photos; clear it to go on; player attribute IntroClock = that clock now);
-- DebugIntroFight = seconds the fight lasts at most.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Settings = require(script.Parent.Settings)
local Sfx = require(script.Parent.Sfx)
local VM = require(script.Parent.Viewmodel)
local Ultimates = require(RS.Shared.Ultimates)
local Config = require(RS.Shared.Config)

local Intro = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Fx: any = nil
local HUD: any = nil
function Intro.init(fx: any, hud: any) Fx = fx; HUD = hud end

local running = false
function Intro.running(): boolean return running end
local function shake(n: number) if Fx then Fx.shake(n) end end
local function kick(n: number) if Fx then Fx.kick(n) end end

local UP = Vector3.yAxis
local function A(x: number, y: number, z: number): CFrame return CFrame.Angles(x, y, z) end
local function seg(s: number, a: number, b: number): number return math.clamp((s - a) / (b - a), 0, 1) end
local function ss(t: number): number return t * t * (3 - 2 * t) end
-- three jerks instead of one smooth move (0..1 -> 0..1): the unnatural way she unfolds
local function jerks(t: number): number
	local k = 0
	for i = 0, 2 do k += ss(seg(t, i / 3, i / 3 + 0.18)) / 3 end
	return k
end
local RAGE = (Ultimates.byId.Rage and Ultimates.byId.Rage.color) or Color3.fromRGB(255, 70, 30)
local GAMEPAD = { Punch = Enum.KeyCode.ButtonR2, Block = Enum.KeyCode.ButtonB, Lift = Enum.KeyCode.ButtonL2, Ultimate = Enum.KeyCode.ButtonY }
local WORDS = { Block = "BLOCK!", Punch = "ATTACK!", Lift = "LIFT IT!", Throw = "THROW IT!", Ultimate = "ULTIMATE!" }
local TOUCH = { Block = "TAP TO BLOCK", Punch = "TAP TO HIT", Lift = "TAP TO LIFT", Throw = "TAP TO THROW", Ultimate = "TAP FOR YOUR ULTIMATE" }

-- THE WOMAN'S POSES (the copy in the TV; joint -> rotation). Her front is her -Z; +X on a shoulder lifts the arm
-- forward, +Z the right arm out to the side (-Z the left); -X on the waist bends her forward.
type Pose = { [string]: CFrame }
local function mix(a: Pose, b: Pose, k: number): Pose
	local o = {}
	for n, c in a do o[n] = c:Lerp(b[n] or CFrame.new(), k) end
	for n, c in b do if not o[n] then o[n] = CFrame.new():Lerp(c, k) end end
	return o
end
local function idle(t: number): Pose
	local sw = math.sin(t * 1.6)
	return {
		Root = CFrame.new(0, math.sin(t * 1.9) * 0.2, 0), Waist = A(-0.14, sw * 0.04, 0), Neck = A(-0.5 + sw * 0.05, math.sin(t * 0.7) * 0.12, 0.08),
		RightShoulder = A(0.25 + sw * 0.05, 0, 0.14), LeftShoulder = A(0.25 - sw * 0.05, 0, -0.14), RightElbow = A(0.3, 0, 0), LeftElbow = A(0.3, 0, 0),
		RightWrist = A(-0.3, 0, 0), LeftWrist = A(-0.3, 0, 0), RightHip = A(0.12, 0, 0), LeftHip = A(0.2, 0, 0), RightKnee = A(-0.35, 0, 0), LeftKnee = A(-0.25, 0, 0),
		RightAnkle = A(-0.5, 0, 0), LeftAnkle = A(-0.5, 0, 0),
	}
end
-- lying in the TV, her arms over her head: right then left reach out (k: 0 = only the right one)
local function reach(t: number, k: number): Pose
	local c = math.sin(t * 9) * 0.06
	return {
		Root = CFrame.new(), Waist = A(0, c, 0), Neck = A(0.15, 0, 0),
		RightShoulder = A(2.95 + c, 0, 0.18), LeftShoulder = A(0.3 + 2.5 * k, 0, -0.1 - 0.4 * k),
		RightElbow = A(0.25, 0, 0), LeftElbow = A(0.9 - 0.6 * k, 0, 0), RightWrist = A(-0.7, 0, 0), LeftWrist = A(-0.7 * k, 0, 0),
		RightHip = A(0, 0, 0), LeftHip = A(0, 0, 0), RightKnee = A(-0.15, 0, 0), LeftKnee = A(-0.15, 0, 0), RightAnkle = A(-0.6, 0, 0), LeftAnkle = A(-0.6, 0, 0),
	}
end
-- hanging out of the TV head first, her hands down on the floor, dragging herself
local function drag(t: number): Pose
	local g = math.sin(t * 7)
	return {
		Root = CFrame.new(), Waist = A(-0.35, g * 0.08, 0), Neck = A(-0.55, g * 0.12, 0),
		RightShoulder = A(1.9 + g * 0.35, 0, 0.2), LeftShoulder = A(1.9 - g * 0.35, 0, -0.2), RightElbow = A(0.3 - g * 0.2, 0, 0), LeftElbow = A(0.3 + g * 0.2, 0, 0),
		RightWrist = A(0.6, 0, 0), LeftWrist = A(0.6, 0, 0), RightHip = A(0, 0, 0), LeftHip = A(0, 0, 0), RightKnee = A(-0.2, 0, 0), LeftKnee = A(-0.2, 0, 0),
		RightAnkle = A(-0.6, 0, 0), LeftAnkle = A(-0.6, 0, 0),
	}
end
-- on all fours, head up and cocked (`go` = how fast her limbs move: 0 = still)
local function scuttle(t: number, go: number): Pose
	local g = math.sin(t * 14) * go
	return {
		Root = CFrame.new(0, math.abs(g) * 0.25, 0), Waist = A(-0.25, g * 0.1, 0), Neck = A(1.0, 0, 0.5),
		RightShoulder = A(1.65 + g * 0.45, 0, 0.25), LeftShoulder = A(1.65 - g * 0.45, 0, -0.25), RightElbow = A(0.35, 0, 0), LeftElbow = A(0.35, 0, 0),
		RightWrist = A(0.7, 0, 0), LeftWrist = A(0.7, 0, 0), RightHip = A(1.35 - g * 0.3, 0, 0.1), LeftHip = A(1.35 + g * 0.3, 0, -0.1),
		RightKnee = A(-1.6, 0, 0), LeftKnee = A(-1.6, 0, 0), RightAnkle = A(-0.2, 0, 0), LeftAnkle = A(-0.2, 0, 0),
	}
end
local function scream(t: number): Pose
	local q = math.sin(t * 40) * 0.03
	return {
		Root = CFrame.new(0, 0.3, 0), Waist = A(0.22, 0, 0), Neck = A(0.5 + q, q, 0),
		RightShoulder = A(0.6, 0, 1.25), LeftShoulder = A(0.6, 0, -1.25), RightElbow = A(0.5, 0, 0), LeftElbow = A(0.5, 0, 0),
		RightWrist = A(0.4, 0, 0), LeftWrist = A(0.4, 0, 0), RightHip = A(0.1, 0, 0), LeftHip = A(0.1, 0, 0), RightKnee = A(-0.3, 0, 0), LeftKnee = A(-0.3, 0, 0),
		RightAnkle = A(-0.5, 0, 0), LeftAnkle = A(-0.5, 0, 0),
	}
end
local function windup(t: number): Pose
	local q = math.sin(t * 30) * 0.03
	return {
		Root = CFrame.new(0, 0.3, 0), Waist = A(0.18, 0, 0), Neck = A(0.05 + q, 0, 0),
		RightShoulder = A(2.75, 0, 0.35), LeftShoulder = A(2.75, 0, -0.35), RightElbow = A(0.7, 0, 0), LeftElbow = A(0.7, 0, 0),
		RightWrist = A(0.6, 0, 0), LeftWrist = A(0.6, 0, 0), RightHip = A(0.25, 0, 0), LeftHip = A(0.1, 0, 0), RightKnee = A(-0.5, 0, 0), LeftKnee = A(-0.3, 0, 0),
		RightAnkle = A(-0.5, 0, 0), LeftAnkle = A(-0.5, 0, 0),
	}
end

-- the TV room: the TV and the armchair facing it (Server/Tutorial moved it back and marked it)
local function tvRoom(): (Model?, Model?)
	local m = workspace:FindFirstChild("Mansion")
	local f = m and m:FindFirstChild("Furniture")
	local tv = f and f:FindFirstChild("TV")
	if not f or not tv or not tv:IsA("Model") then return nil, nil end
	-- (the one the server moved back for the intro: model attribute IntroSeat; else the nearest to the TV)
	for _, c in f:GetChildren() do
		if c.Name == "Armchair" and c:IsA("Model") and c:GetAttribute("IntroSeat") then return tv, c end
	end
	local best, bestD = nil :: Model?, math.huge
	for _, c in f:GetChildren() do
		if c.Name == "Armchair" and c:IsA("Model") then
			local d = (c:GetPivot().Position - tv:GetPivot().Position).Magnitude
			if d < bestD then best, bestD = c, d end
		end
	end
	return tv, best
end
-- the face of a part that looks along `dir`
local function faceOf(p: BasePart, dir: Vector3): Enum.NormalId
	local n = p.CFrame:VectorToObjectSpace(dir)
	local ax = math.max(math.abs(n.X), math.abs(n.Y), math.abs(n.Z))
	if ax == math.abs(n.X) then return n.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left end
	if ax == math.abs(n.Y) then return n.Y > 0 and Enum.NormalId.Top or Enum.NormalId.Bottom end
	return n.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front
end

function Intro.play(onDone: (() -> ())?)
	if running then return end
	local set = RS:FindFirstChild("Intro")
	local ch = lp.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local remote = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("Tutorial") :: RemoteEvent?
	if not set or not set:FindFirstChild("Woman") or not ch or not hrp or not hum or not remote then
		if onDone then task.spawn(onDone) end
		return
	end
	local R = RS:WaitForChild("Remotes") :: any
	local rem = remote :: RemoteEvent
	local hrpP = hrp :: BasePart
	running = true
	lp:SetAttribute("IntroPhase", "enter")
	local studio = RunService:IsStudio()

	-- THE SCREEN'S OWN LAYER ---------------------------------------------------------------------------------------
	local pg = lp:WaitForChild("PlayerGui")
	local offGuis = {} :: { ScreenGui }
	local function hideGuis()
		for _, g in pg:GetChildren() do
			if g:IsA("ScreenGui") and g.Enabled and g.Name ~= "IntroUI" then g.Enabled = false; table.insert(offGuis, g) end
		end
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)
	end
	local function showGuis()
		for _, g in offGuis do if g.Parent then g.Enabled = true end end
		table.clear(offGuis)
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true) end)
	end
	hideGuis()
	local gui = Instance.new("ScreenGui")
	gui.Name = "IntroUI"; gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false; gui.DisplayOrder = 70
	gui.Parent = pg
	local black = Grunge.frame(gui, { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0, Size = UDim2.fromScale(1, 1), ZIndex = 40 })
	local flashF = Grunge.frame(gui, { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 30 })
	local function flash(c: Color3, a: number, t: number)
		flashF.BackgroundColor3 = c; flashF.BackgroundTransparency = 1 - a
		TweenService:Create(flashF, TweenInfo.new(t), { BackgroundTransparency = 1 }):Play()
	end
	local bars = {}
	for _, top in { true, false } do
		local b = Grunge.frame(gui, { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0, AnchorPoint = Vector2.new(0, top and 0 or 1),
			Position = UDim2.fromScale(0, top and 0 or 1), Size = UDim2.fromScale(1, 0.11), ZIndex = 20 })
		table.insert(bars, { f = b, top = top })
	end
	local function letterbox(on: boolean, t: number)
		for _, b in bars do
			TweenService:Create(b.f, TweenInfo.new(t, Enum.EasingStyle.Quad), { AnchorPoint = Vector2.new(0, (b.top == on) and 0 or 1) }):Play()
		end
	end
	local prompt = Instance.new("TextButton")
	prompt.AutoButtonColor = false; prompt.BackgroundTransparency = 1; prompt.Text = ""
	prompt.AnchorPoint = Vector2.new(0.5, 0.5); prompt.Position = UDim2.fromScale(0.5, 0.66); prompt.Size = UDim2.fromScale(0.5, 0.2)
	prompt.Visible = false; prompt.ZIndex = 25; prompt.Parent = gui
	local pScale = Instance.new("UIScale"); pScale.Parent = prompt
	local word = Grunge.text(prompt, { Text = "", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(1, 0.62),
		TextColor3 = Color3.fromRGB(235, 50, 35), TextStrokeTransparency = 0, ZIndex = 26 })
	local key = Grunge.text(prompt, { Text = "", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.64), Size = UDim2.fromScale(0.7, 0.34),
		TextColor3 = Color3.fromRGB(242, 200, 60), TextStrokeTransparency = 0, ZIndex = 26 })
	local brut = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.95), Size = UDim2.fromScale(0.36, 0.06), Visible = false, ZIndex = 22 })
	Grunge.text(brut, { Text = "BRUTALITY", Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(0.5, 0.45), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 24 })
	local brutTrack = Grunge.brush(brut, { Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromScale(1, 0.48), ZIndex = 22 }, Color3.fromRGB(40, 30, 28), 61, 22, false)
	local brutFill = Grunge.brush(brutTrack, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.006, 0.5), Size = UDim2.fromScale(0.01, 0.72), ZIndex = 23 }, RAGE, 63, 22, false)
	-- the fight's line at the top
	local banner = Grunge.text(gui, { Text = "", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.16), Size = UDim2.fromScale(0.5, 0.09),
		TextColor3 = Color3.fromRGB(235, 50, 35), TextStrokeTransparency = 0, Visible = false, ZIndex = 26 })
	local hint = Grunge.text(gui, { Text = "", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.255), Size = UDim2.fromScale(0.5, 0.045),
		TextColor3 = Color3.fromRGB(242, 200, 60), TextStrokeTransparency = 0, Visible = false, ZIndex = 26 })
	local skipBtn = Instance.new("TextButton")
	skipBtn.AutoButtonColor = false; skipBtn.BackgroundTransparency = 1; skipBtn.Text = ""
	skipBtn.AnchorPoint = Vector2.new(1, 1); skipBtn.Position = UDim2.new(1, -18, 1, -14); skipBtn.Size = UDim2.fromScale(0.09, 0.05)
	skipBtn.ZIndex = 35; skipBtn.Parent = gui
	local smin = Instance.new("UISizeConstraint"); smin.MinSize = Vector2.new(96, 34); smin.Parent = skipBtn
	Grunge.brush(skipBtn, { Size = UDim2.fromScale(1, 1), ZIndex = 35 }, Color3.fromRGB(38, 31, 27), 67, 12, false)
	Grunge.text(skipBtn, { Text = Platform.mode() == "gamepad" and "SKIP [SELECT]" or "SKIP", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.86, 0.62), ZIndex = 37 })
	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "IntroFreeze"; grade.Parent = Lighting
	if Fx then Fx.musicLock = true; Fx.setMusic(false) end -- (the house's fight music stays quiet: this one plays its own)

	-- STATE AND CLEAN-UP ------------------------------------------------------------------------------------------
	local folder = Instance.new("Folder")
	folder.Name = "IntroSet"
	folder.Parent = workspace
	local thread: thread? = nil
	local ended = false
	local restores = {} :: { () -> () }
	local conns = {} :: { RBXScriptConnection }
	local music: Sound? = nil
	local musicVol = 1
	local muffle: EqualizerSoundEffect? = nil
	local hidden = {} :: { [BasePart]: boolean }
	local function hideBodies()
		for _, p in Players:GetPlayers() do
			local c = p.Character
			if c then
				for _, d in c:GetDescendants() do
					if d:IsA("BasePart") and d.LocalTransparencyModifier < 1 then d.LocalTransparencyModifier = 1; hidden[d] = true end
				end
			end
		end
	end
	local function showBodies()
		for p in hidden do if p.Parent then p.LocalTransparencyModifier = 0 end end
		table.clear(hidden)
	end
	local bodiesHidden = false
	local camScripted = false
	local camCF = cam.CFrame
	local camFn: (t: number) -> CFrame = function() return cam.CFrame end
	local camRate = 6
	local fistsOff = false
	local S = 0
	local frozen = false
	local inputSink: (on: boolean) -> ()

	-- arrived = the ending already brought the player back to the park and handed the camera over (no black)
	local function finish(arrived: boolean?)
		if ended then return end
		ended = true
		lp:SetAttribute("IntroPhase", "done")
		if not arrived then
			TweenService:Create(black, TweenInfo.new(0.45), { BackgroundTransparency = 0 }):Play()
			task.wait(0.5)
		end
		if thread and thread ~= coroutine.running() and coroutine.status(thread) ~= "dead" then pcall(task.cancel, thread) end
		RunService:UnbindFromRenderStep("IntroCam")
		inputSink(false)
		for _, c in conns do c:Disconnect() end
		pcall(function() R.Block:FireServer(false) end)
		for i = #restores, 1, -1 do pcall(restores[i]) end
		hrpP.Anchored = false
		showBodies()
		grade:Destroy()
		folder:Destroy()
		-- back to the park (the server takes the player out of the house)
		if not arrived then
			rem:FireServer("done")
			local spawnPart = workspace:FindFirstChild("LobbySpawn") :: BasePart?
			local t0 = os.clock()
			while os.clock() - t0 < 5 do
				if not lp:GetAttribute("InMatch") and spawnPart and (hrpP.Position - spawnPart.Position).Magnitude < 80 then break end
				task.wait(0.1)
			end
		end
		if music then
			local m = music
			TweenService:Create(m, TweenInfo.new(2.5), { Volume = 0 }):Play()
			task.delay(2.6, function() m:Destroy() end)
		end
		if Fx then Fx.musicLock = false; Fx.cineFov = nil; Fx.setMusic(false) end
		cam.CameraType = Enum.CameraType.Custom
		cam.CameraSubject = hum
		showGuis()
		if not arrived then TweenService:Create(black, TweenInfo.new(0.9), { BackgroundTransparency = 1 }):Play() end
		task.delay(1, function() gui:Destroy() end)
		running = false
		if HUD then task.delay(1.2, function() HUD.toast("PRESS PLAY TO START YOUR FIRST RUN", true) end) end
		if onDone then task.spawn(onDone) end
	end
	local function skip()
		if not ended then task.spawn(finish) end
	end
	table.insert(conns, lp.CharacterAdded:Connect(skip)) -- (respawned: it ends)

	-- the camera: one render step for the cinematic and the lessons
	local function studioHold(): boolean
		local h = studio and lp:GetAttribute("DebugIntroHoldAt")
		return type(h) == "number" and S >= h
	end
	local frameFns = {} :: { (dt: number) -> () }
	RunService:BindToRenderStep("IntroCam", Enum.RenderPriority.Camera.Value, function(dt: number)
		if not frozen and not studioHold() then S += dt end
		if studio then lp:SetAttribute("IntroClock", S) end -- (tests: DebugIntroHoldAt relative to now)
		for _, f in frameFns do f(dt) end
		if camScripted then
			if not frozen then camCF = camCF:Lerp(camFn(S), math.min(1, dt * camRate)) end
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = camCF
			-- (the viewmodel - the bare fists - shows when the camera is this close to its focus; not on the train)
			cam.Focus = fistsOff and (camCF * CFrame.new(0, 0, -6)) or camCF
		end
		if bodiesHidden then hideBodies() end
	end)
	local function sleep(t: number)
		local goal = S + t
		while S < goal do task.wait() end
	end

	-- INPUT: during the cinematic and the lessons the game's own controls are quiet; the lessons fire the real ones
	local wantAction: string? = nil
	local gotAction = Instance.new("BindableEvent")
	local onFree: ((action: string) -> ())? = nil
	local function pressed(action: string)
		if action == "Skip" then
			if lp:GetAttribute("IntroPhase") ~= "fight" then skip() end
			return
		end
		if wantAction and action == wantAction then
			wantAction = nil
			gotAction:Fire()
		elseif onFree and not frozen then
			onFree(action)
		end
	end
	local function actionOf(input: InputObject): string?
		if input.KeyCode == Enum.KeyCode.ButtonSelect then return "Skip" end
		for _, a in { "Block", "Punch", "Lift", "Ultimate" } do
			local b = Settings.input(a)
			if input.KeyCode == GAMEPAD[a] then return a end
			if b.EnumType == Enum.KeyCode and input.KeyCode == b then return a end
			if b.EnumType == Enum.UserInputType and input.UserInputType == b then return a end
		end
		return nil
	end
	local inputs = { Settings.input("Punch"), Settings.input("Block"), Settings.input("Lift"), Settings.input("Ultimate"),
		Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonL2, Enum.KeyCode.ButtonY, Enum.KeyCode.ButtonSelect }
	inputSink = function(on: boolean)
		if not on then CAS:UnbindAction("IntroInput"); return end
		CAS:BindActionAtPriority("IntroInput", function(_, st: Enum.UserInputState, input: InputObject)
			if st == Enum.UserInputState.Begin then
				local a = actionOf(input)
				if a then pressed(a) end
			end
			return Enum.ContextActionResult.Sink
		end, false, 3000, table.unpack(inputs))
	end
	inputSink(true)
	prompt.Activated:Connect(function() if wantAction and Platform.mode() == "touch" then pressed(wantAction) end end)
	skipBtn.Activated:Connect(function() pressed("Skip") end)
	if studio then
		table.insert(conns, lp:GetAttributeChangedSignal("DebugIntroAct"):Connect(function()
			local a = lp:GetAttribute("DebugIntroAct")
			if type(a) == "string" then pressed(a) end
		end))
	end

	local function startMusic()
		local s = Sfx.loop("Music_Rat_E")
		if not s then return end
		music = s
		musicVol = s.Volume
		local eq = Instance.new("EqualizerSoundEffect")
		eq.Parent = s
		muffle = eq
	end
	-- FREEZE: the world stops on the lesson (the real Woman is held by the server); the right input lets it go
	local function freeze(action: string, label: string?)
		frozen = true
		lp:SetAttribute("IntroPhase", "freeze:" .. (label or action))
		TweenService:Create(grade, TweenInfo.new(0.18), { Saturation = -0.85, Contrast = 0.18, TintColor = Color3.fromRGB(215, 225, 255) }):Play()
		if music then TweenService:Create(music, TweenInfo.new(0.25), { Volume = musicVol * 0.32 }):Play() end
		if muffle then muffle.HighGain = -30; muffle.MidGain = -10 end
		Sfx.play("Whoosh", { Volume = 0.5, PlaybackSpeed = 0.5 })
		local touch = Platform.mode() == "touch"
		word.Text = touch and (TOUCH[label or action] or "TAP") or (WORDS[label or action] or action)
		key.Text = touch and "" or Platform.label(action)
		prompt.Visible = true
		pScale.Scale = 1.6
		TweenService:Create(pScale, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		local pulse = RunService.Heartbeat:Connect(function() prompt.Rotation = math.sin(os.clock() * 6) * 1.5 end)
		wantAction = action
		gotAction.Event:Wait()
		pulse:Disconnect()
		prompt.Visible = false
		TweenService:Create(grade, TweenInfo.new(0.15), { Saturation = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1) }):Play()
		if music then TweenService:Create(music, TweenInfo.new(0.2), { Volume = musicVol }):Play() end
		if muffle then muffle.HighGain = 0; muffle.MidGain = 0 end
		frozen = false
		lp:SetAttribute("IntroPhase", "lesson")
	end

	-- THE SCRIPT ---------------------------------------------------------------------------------------------------
	local function runScript()
		-- 0 INTO THE HOUSE: the server puts the player in front of the TV room's armchair
		rem:FireServer("enter")
		local t0 = os.clock()
		while lp:GetAttribute("IntroHouse") == nil and os.clock() - t0 < 14 do task.wait(0.1) end
		local tv, chair = tvRoom()
		if lp:GetAttribute("IntroHouse") ~= true or not tv or not chair then
			finish()
			return
		end
		task.wait(0.4) -- (the armchair's new place reaches this screen)
		local tvM, chairM = tv :: Model, chair :: Model
		local screen = (tvM:FindFirstChild("Screen") or tvM.PrimaryPart or tvM:FindFirstChildWhichIsA("BasePart")) :: BasePart
		local tvPivot = tvM:GetPivot()
		local look = Vector3.new(tvPivot.LookVector.X, 0, tvPivot.LookVector.Z).Unit -- the TV looks into the room
		local face = faceOf(screen, look)
		local lsz = screen.CFrame:VectorToObjectSpace(look)
		local depth = (math.abs(lsz.X) * screen.Size.X + math.abs(lsz.Y) * screen.Size.Y + math.abs(lsz.Z) * screen.Size.Z) / 2
		local screenAt = screen.Position + look * depth
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Include
		rp.FilterDescendantsInstances = { workspace.Mansion:FindFirstChild("Structure") :: Instance }
		local fr = workspace:Raycast(screenAt + look * 2 + UP, Vector3.new(0, -20, 0), rp)
		local floorY = fr and fr.Position.Y or (screenAt.Y - 3)
		local chairCF = chairM:GetBoundingBox()
		local seatEye = Vector3.new(chairCF.Position.X, floorY + 3.9, chairCF.Position.Z) + look * 0.5
		local base = CFrame.lookAt(screenAt, screenAt + look) -- the screen's frame: -Z local = into the room
		local function inRoom(d: number, h: number): Vector3
			local p = screenAt + look * d
			return Vector3.new(p.X, floorY + h, p.Z)
		end
		-- (her moves follow the armchair: D = from the glass to where the player stands up in front of it)
		local flatStand = Vector3.new(hrpP.Position.X, 0, hrpP.Position.Z)
		local D = math.max(9, (flatStand - Vector3.new(screenAt.X, 0, screenAt.Z)):Dot(look))
		-- (she always stops well short of the armchair's camera, wherever the player was put)
		local seatD = (Vector3.new(seatEye.X, 0, seatEye.Z) - Vector3.new(screenAt.X, 0, screenAt.Z)):Dot(look)
		local standD = math.clamp(D * 0.42, 3.2, math.max(3.2, seatD - 10))
		local herStand = inRoom(standD, 6.7)

		-- the player: held still and out of sight in front of the armchair
		hrpP.Anchored = true
		bodiesHidden = true
		hideBodies()
		local standEye = hrpP.Position + UP * 1.6

		-- the room darker: the house's lights near the TV down to a third
		local lights = {} :: { { l: Light, b: number } }
		for _, d in workspace.Mansion:GetDescendants() do
			if d:IsA("Light") and d.Parent and d.Parent:IsA("BasePart") and ((d.Parent :: BasePart).Position - screenAt).Magnitude < 40 then
				table.insert(lights, { l = d, b = d.Brightness })
				d.Brightness *= 0.3
			end
		end
		local function lightsBack()
			for _, e in lights do if e.l.Parent then TweenService:Create(e.l, TweenInfo.new(1), { Brightness = e.b }):Play() end end
		end
		table.insert(restores, function() for _, e in lights do if e.l.Parent then e.l.Brightness = e.b end end end)
		-- the TV: static on its screen, its light, its sound; it rocks when she climbs out
		local sg = Instance.new("SurfaceGui")
		sg.Name = "IntroStatic"; sg.Face = face; sg.CanvasSize = Vector2.new(180, 140); sg.LightInfluence = 0; sg.Brightness = 1.8
		sg.Parent = screen
		local CWn, CHn = 18, 14
		local cells = {} :: { Frame }
		local cellXY = {} :: { Vector2 }
		for y = 0, CHn - 1 do
			for x = 0, CWn - 1 do
				local f = Instance.new("Frame")
				f.BorderSizePixel = 0
				f.Size = UDim2.fromScale(1 / CWn + 0.002, 1 / CHn + 0.002)
				f.Position = UDim2.fromScale(x / CWn, y / CHn)
				f.Parent = sg
				table.insert(cells, f)
				table.insert(cellXY, Vector2.new((x + 0.5) / CWn, (y + 0.5) / CHn))
			end
		end
		table.insert(restores, function() sg:Destroy() end)
		local tvLightPart = Instance.new("Part")
		tvLightPart.Anchored = true; tvLightPart.CanCollide = false; tvLightPart.CanQuery = false; tvLightPart.CanTouch = false
		tvLightPart.Transparency = 1; tvLightPart.Size = Vector3.new(0.2, 0.2, 0.2); tvLightPart.CFrame = CFrame.new(screenAt + look * 1.2)
		tvLightPart.Parent = folder
		local tvLight = Instance.new("PointLight")
		tvLight.Color = Color3.fromRGB(175, 200, 255); tvLight.Range = 30; tvLight.Brightness = 2.4; tvLight.Shadows = true
		tvLight.Parent = tvLightPart
		local tvSound = Sfx.on("TvStatic", screen, { Volume = 0.35 })
		local humSound = Sfx.on("TvHum", screen, { Volume = 0.2 })
		table.insert(restores, function()
			if tvSound then tvSound:Destroy() end
			if humSound then humSound:Destroy() end
		end)
		local tv0 = tvM:GetPivot()
		table.insert(restores, function() if tvM.Parent then tvM:PivotTo(tv0) end end)
		local staticOn, staticDark = true, 0.15
		local shape = 0 -- 0..1: her shape coming closer in the static
		local handGlow = 0 -- 0..1: her hand pressed on the glass
		local tvShake = 0
		table.insert(frameFns, function()
			if staticOn and not frozen then
				for _ = 1, 80 do
					local i = math.random(1, #cells)
					local uv = cellXY[i]
					local v = math.random()
					v = v * v * (1 - staticDark)
					-- her shape: a head and shoulders, dark in the middle
					local dx, dy = uv.X - 0.5, uv.Y - 0.55
					local inHead = (dx * dx) / 0.012 + ((dy + 0.17) ^ 2) / 0.02 < shape * 1.6
					local inBody = math.abs(dx) < 0.3 * shape and dy > -0.05 and shape > 0.2
					if inHead or inBody then v *= 0.12 end
					-- her hand on the glass, bright where it presses
					local hx, hy = uv.X - 0.62, uv.Y - 0.42
					if handGlow > 0 and (hx * hx + hy * hy) < 0.018 * handGlow then v = 0.85 + math.random() * 0.15 end
					cells[i].BackgroundColor3 = Color3.new(v, v, v * 1.05)
				end
				tvLight.Brightness = (1.5 + math.random() * 1.1) * (1 - staticDark * 0.7)
			end
			if tvShake > 0.01 and tvM.Parent then
				tvM:PivotTo(tv0 * A(math.sin(os.clock() * 37) * 0.04 * tvShake, 0, math.sin(os.clock() * 29) * 0.05 * tvShake))
				tvShake *= 0.93
			end
		end)
		local function crack(n: number)
			for _ = 1, n do
				local f = Instance.new("Frame")
				f.BorderSizePixel = 0; f.BackgroundColor3 = Color3.new(1, 1, 1); f.AnchorPoint = Vector2.new(0.5, 0.5)
				f.Position = UDim2.fromScale(0.62 + math.random() * 0.06 - 0.03, 0.42 + math.random() * 0.06 - 0.03)
				f.Size = UDim2.fromScale(0.25 + math.random() * 0.35, 0.012)
				f.Rotation = math.random(0, 179); f.ZIndex = 3; f.Parent = sg
			end
		end

		-- THE WOMAN IN THE TV (this screen's copy)
		local woman = ((set :: any).Woman :: Model):Clone()
		local wparts = {} :: { BasePart }
		for _, d in woman:GetDescendants() do
			if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.LocalTransparencyModifier = 1; table.insert(wparts, d) end
		end
		woman.Parent = folder
		local wroot = woman:FindFirstChild("HumanoidRootPart") :: BasePart
		-- (until she has dropped out of the TV only what has come through the glass shows: nothing of her pokes out
		-- of the wall beside the set; her claws are the first thing through)
		local glassCut = true
		local motors = {} :: { [string]: Motor6D }
		for _, d in woman:GetDescendants() do if d:IsA("Motor6D") then motors[d.Name] = d end end
		local poseFn: (t: number) -> Pose = function(t) return reach(t, 0) end
		local poseT0, poseRate = 0, 10
		local cur = {} :: { [string]: CFrame }
		local DOWN = -math.pi / 2 -- lying face down, head toward the room
		-- in the screen's frame: `z` studs into the room from the glass, `y` above the screen's middle, `pitch` (0 = upright)
		local function at(z: number, y: number, pitch: number): CFrame
			return base * CFrame.new(0, y, -z) * A(pitch, 0, 0)
		end
		local herCF = at(-11, 0, DOWN)
		local herGoal: ((s: number) -> CFrame)? = nil
		local function setPose(fn: (t: number) -> Pose, rate: number?) poseFn = fn; poseT0 = S; poseRate = rate or 10 end
		table.insert(frameFns, function(dt)
			if frozen or not woman.Parent then return end
			if herGoal then herCF = herGoal(S) end
			wroot.CFrame = herCF
			local target = poseFn(S - poseT0)
			local k = math.min(1, dt * poseRate)
			for name, m in motors do
				local c = (cur[name] or m.Transform):Lerp(target[name] or CFrame.new(), k)
				cur[name] = c
				m.Transform = c
			end
			for _, p in wparts do
				-- (in front of the glass = -Z in the screen's frame; a part shows once its middle is through)
				p.LocalTransparencyModifier = (glassCut and base:PointToObjectSpace(p.Position).Z > -0.05) and 1 or 0
			end
		end)

		-- the lens: tight on the TV from the far armchair, wider as she comes out, normal again when she lunges
		local fov, fovGoal = 46, 46
		table.insert(frameFns, function(dt)
			if not frozen then fov += (fovGoal - fov) * math.min(1, dt * 1.5) end
			if Fx then Fx.cineFov = fov end
		end)
		table.insert(restores, function() if Fx then Fx.cineFov = nil end end)

		-- 1 THE TV ------------------------------------------------------------------------------------------------
		lp:SetAttribute("IntroPhase", "tv")
		letterbox(true, 0)
		camScripted = true
		camRate = 2.5
		camCF = CFrame.lookAt(seatEye, screenAt)
		camFn = function(s) -- in the armchair, slowly leaning in
			local k = ss(seg(s, 0.4, 3.2))
			return CFrame.lookAt(seatEye + look * (0.9 * k) - UP * (0.2 * k), screenAt + UP * 0.2) * A(0, 0, math.sin(s * 0.8) * 0.01)
		end
		herGoal = function() return at(-11, 0, DOWN) end
		TweenService:Create(black, TweenInfo.new(1.2), { BackgroundTransparency = 1 }):Play()
		sleep(1.0)
		Sfx.play("Thunder", { Volume = 1 })
		flash(Color3.fromRGB(150, 170, 230), 0.18, 0.5)
		sleep(0.6)
		-- a shape comes closer in the static
		local sh0 = S
		table.insert(frameFns, function() if S - sh0 < 1.6 then shape = ss(seg(S - sh0, 0, 1.5)) end end)
		Sfx.play("GhostWail", { Volume = 0.45, PlaybackSpeed = 0.6 })
		sleep(1.6)
		-- her hand on the glass, twice; the glass cracks
		handGlow = 1; shape = 1
		Sfx.at("PunchHeavy", screenAt, { Volume = 0.9, PlaybackSpeed = 0.45 })
		Sfx.at("Glass", screenAt, { Volume = 0.35, PlaybackSpeed = 0.5 })
		tvShake = 1; shake(0.15)
		sleep(0.65)
		Sfx.at("PunchHeavy", screenAt, { Volume = 1.1, PlaybackSpeed = 0.4 })
		crack(5)
		tvShake = 1.4; shake(0.25)
		sleep(0.55)
		-- the claws burst through
		staticDark = 0.45; handGlow = 0
		crack(6)
		Sfx.at("Glass", screenAt, { Volume = 1.1, PlaybackSpeed = 0.8 })
		Sfx.play("GhostScream", { Volume = 0.5, PlaybackSpeed = 0.6 })
		tvShake = 2; shake(0.45)
		flash(Color3.fromRGB(200, 215, 255), 0.25, 0.25)
		setPose(function(t) return reach(t, 0) end, 18)
		local r0 = S
		herGoal = function(s)
			local k = s - r0
			-- the right hand out first (fast), a pause, then the left one grabs the TV's edge
			local z = -10.6 + 2.6 * ss(seg(k, 0, 0.25)) + 0.6 * ss(seg(k, 0.6, 0.9))
			return at(z, -0.2, DOWN) * A(0, 0, math.sin(k * 11) * 0.02)
		end
		sleep(0.6)
		setPose(function(t) return reach(t, seg(t, 0, 0.3)) end, 14)
		sleep(0.6)
		-- she drags herself out head first, her hands going down to the floor
		fovGoal = 56
		setPose(drag, 8)
		local d0 = S
		herGoal = function(s)
			local k = ss(seg(s - d0, 0, 1.6))
			return at(-7.4 + 5.6 * k, -0.6 - 1.2 * k, DOWN - 0.55 * k) * A(0, 0, math.sin((s - d0) * 7) * 0.05)
		end
		camRate = 2
		camFn = function() return CFrame.lookAt(seatEye + look * 0.6, (wroot.Position + wroot.CFrame.UpVector * 4.6) * 0.6 + screenAt * 0.4) end
		tvShake = 1
		sleep(1.65)
		-- the rest of her slides out: she drops to the floor, on all fours
		local fallFrom = herCF
		local landAt = inRoom(2.6, 3.6)
		local crouch = CFrame.lookAt(Vector3.zero, look) * A(DOWN + 0.45, 0, 0)
		local f0 = S
		setPose(function(t) return scuttle(t, 0) end, 9)
		herGoal = function(s)
			local k = ss(seg(s - f0, 0, 0.45))
			local p = fallFrom.Position:Lerp(landAt, k) - UP * math.sin(k * math.pi) * 0.4
			return CFrame.new(p) * (fallFrom - fallFrom.Position):Lerp(crouch, k)
		end
		sleep(0.45)
		glassCut = false -- (all of her is out)
		Sfx.at("Crash", landAt, { Volume = 1, PlaybackSpeed = 0.55 })
		shake(0.6); kick(4)
		tvShake = 0.6
		sleep(0.55)
		-- she scuttles to the armchair in jerks, her head cocked
		fovGoal = 64
		local crawlTo = inRoom(math.max(2.8, standD - 0.4), 3.6)
		local c0 = S
		setPose(function(t) return scuttle(t, (t % 0.55) < 0.32 and 1 or 0) end, 16)
		herGoal = function(s)
			local t = s - c0
			local done = math.min(3, math.floor(t / 0.55)) + math.min(1, (t % 0.55) / 0.32)
			return CFrame.new(landAt:Lerp(crawlTo, math.min(1, done / 3))) * crouch
		end
		camRate = 5
		camFn = function() return CFrame.lookAt(seatEye - look * 0.3, wroot.Position + UP * 1.5) end
		Sfx.play("GhostWail", { Volume = 0.7, PlaybackSpeed = 1.2 })
		sleep(1.7)
		-- she unfolds to her full height, in three jerks
		local u0 = S
		local unfoldFrom = herCF
		local upright = CFrame.lookAt(herStand, herStand + look)
		setPose(function(t) return mix(scuttle(t, 0), idle(t), jerks(seg(t, 0, 1.5))) end, 20)
		herGoal = function(s)
			local k = jerks(seg(s - u0, 0, 1.5))
			return CFrame.new(unfoldFrom.Position:Lerp(upright.Position, k)) * (unfoldFrom - unfoldFrom.Position):Lerp(upright - upright.Position, k)
		end
		camRate = 4
		camFn = function() return CFrame.lookAt(seatEye - look * 0.4, wroot.Position + UP * (1 + 2.6 * seg(S - u0, 0, 1.5))) end
		for i = 0, 2 do
			task.delay(i * 0.5 + 0.02, function()
				if not ended then Sfx.at("PunchLight", wroot.Position, { Volume = 1, PlaybackSpeed = 0.35 + i * 0.05 }) end
			end)
		end
		sleep(1.7)
		-- the head comes up: the scream; the lights die
		setPose(scream, 12)
		Sfx.play("GhostScream", { Volume = 1.3 })
		shake(0.5)
		flash(Color3.fromRGB(200, 220, 255), 0.25, 0.3)
		for _, e in lights do if e.l.Parent then TweenService:Create(e.l, TweenInfo.new(0.2), { Brightness = e.b * 0.08 }):Play() end end
		staticDark = 0
		sleep(0.9)

		-- 2 SHE LUNGES - THE MUSIC DROPS - FROZEN ON HER CLAWS: BLOCK ------------------------------------------------------
		-- the real one is put in her place at once, held in the same swing and out of sight until the press
		setPose(windup, 10)
		local l0 = S
		local close = inRoom(math.max(standD + 1, D - 7), 6.7) -- (7 studs in front of the player: in reach of her claws)
		herGoal = function(s)
			local k = ss(seg(s - l0, 0, 0.45))
			return CFrame.lookAt(herStand:Lerp(close, k), close + look)
		end
		rem:FireServer("spawn", close)
		fovGoal = 74
		startMusic()
		flash(Color3.new(1, 1, 1), 0.6, 0.45)
		shake(0.9); kick(8)
		letterbox(false, 0.35)
		-- up out of the armchair into the player's eyes, following her
		camRate = 9
		camFn = function() return CFrame.lookAt(standEye, wroot.Position + UP * 2) end
		local function eyesOn(target: () -> Vector3): (s: number) -> CFrame
			return function() return CFrame.lookAt(standEye, target()) end
		end
		local function real(): Model? return workspace:FindFirstChild("Ghost") :: Model? end
		local function herChest(): Vector3
			local g = real()
			local r = g and g:FindFirstChild("HumanoidRootPart") :: BasePart?
			return r and (r.Position + UP * 2) or (close + UP * 1.5)
		end
		local function realSeen(on: boolean)
			-- (Client/GhostAnim fades her out while the attribute is on: set on this screen only)
			local g = real()
			if g then g:SetAttribute("IntroHidden", if on then nil else true) end
		end
		local hideReal = true
		table.insert(frameFns, function() if hideReal then realSeen(false) end end)
		sleep(0.5)
		freeze("Block")
		-- the press: the game begins - the real one where she was, her claws coming down on the guard
		R.Block:FireServer(true)
		local w0 = os.clock()
		while not real() and os.clock() - w0 < 2 do task.wait() end
		hideReal = false
		realSeen(true)
		woman:Destroy()
		lightsBack()
		staticOn = false
		for _, c in cells do c.BackgroundColor3 = Color3.new(0.04, 0.04, 0.05) end
		tvLight.Brightness = 0.3
		if tvSound then tvSound:Destroy(); tvSound = nil end
		camFn = eyesOn(herChest)
		lp:SetAttribute("IntroPhase", "lesson")
		task.wait(0.03)
		rem:FireServer("release")
		local function waitHeld(t: number): boolean
			local h0 = os.clock()
			repeat
				local g = real()
				if g and g:GetAttribute("Held") == true then return true end
				task.wait()
			until os.clock() - h0 > t
			return false
		end
		local function aim(): Vector3 return (herChest() - standEye).Unit end
		local combo = 0
		local function punch()
			combo += 1
			VM.punch(combo)
			R.Punch:FireServer(aim(), 0)
		end
		sleep(1.1)
		R.Block:FireServer(false)
		sleep(0.4)
		-- ATTACK (and a few more for fun)
		rem:FireServer("hold")
		waitHeld(2)
		freeze("Punch")
		rem:FireServer("release")
		punch()
		onFree = function(a) if a == "Punch" then punch() end end
		sleep(2.4)
		onFree = nil
		-- LIFT: the armchair you sat in, right behind you (Server/Tutorial: model attribute IntroProp)
		local function introProp(): Model?
			local f = workspace.Mansion:FindFirstChild("Furniture")
			if not f then return nil end
			for _, c in f:GetChildren() do
				if c:IsA("Model") and c:GetAttribute("IntroProp") and c.PrimaryPart and not c:GetAttribute("Broken") then return c end
			end
			return nil
		end
		rem:FireServer("hold")
		local liftThis = introProp()
		local q0 = os.clock()
		while not liftThis and os.clock() - q0 < 2 do task.wait(0.1); liftThis = introProp() end
		if liftThis then
			local prop = liftThis :: Model
			camRate = 5
			camFn = eyesOn(function() return (prop:GetBoundingBox()).Position + UP * 1 end) -- (turned round to it)
			sleep(0.8)
			freeze("Lift")
			R.Grab:FireServer(prop)
			local g0 = os.clock()
			while not lp:GetAttribute("Carrying") and os.clock() - g0 < 1.5 do task.wait() end
			camFn = eyesOn(herChest)
			sleep(0.8)
			-- THROW
			if lp:GetAttribute("Carrying") then
				freeze("Punch", "Throw")
				R.Throw:FireServer(aim())
				VM.slam()
				task.wait(0.05)
				rem:FireServer("release")
				sleep(1.4)
			end
		end
		-- ULTIMATE: the bar fills and the anger builds - the screen shakes harder and harder, the picture goes red, the
		-- heart pounds faster, the bar trembles - full: a jolt; then the Rage Shockwave (this once it only stuns her)
		rem:FireServer("ult")
		brut.Visible = true
		brutFill.Size = UDim2.fromScale(0.01, 0.72)
		TweenService:Create(brutFill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.fromScale(0.988, 0.72) }):Play()
		Sfx.play("Whoosh", { Volume = 0.8, PlaybackSpeed = 0.6 })
		local r0 = S
		local raging = true
		local brutAt = brut.Position
		table.insert(frameFns, function(dt: number)
			if not raging or frozen then return end
			local k = seg(S - r0, 0, 0.95)
			shake(dt * (1.2 + 2.2 * k)) -- (more than the shake wears off, more and more: it builds)
			grade.TintColor = Color3.new(1, 1 - 0.34 * k, 1 - 0.38 * k)
			grade.Contrast = 0.16 * k
			grade.Saturation = 0.25 * k
			local j = 6 * k
			brut.Position = brutAt + UDim2.fromOffset(math.random(-10, 10) / 10 * j, math.random(-10, 10) / 10 * j)
		end)
		for i, at in { 0, 0.36, 0.62, 0.8, 0.92 } do -- (the heart, faster and faster)
			task.delay(at, function()
				if ended then return end
				Sfx.play("PunchHeavy", { Volume = 0.3 + i * 0.1, PlaybackSpeed = 0.3 + i * 0.02 })
				kick(1 + i * 0.8)
			end)
		end
		sleep(0.95)
		raging = false
		brut.Position = brutAt
		Sfx.play("Cash", { PlaybackSpeed = 0.7, Volume = 0.7 })
		flash(RAGE, 0.35, 0.4)
		shake(0.35); kick(6)
		rem:FireServer("hold")
		local b0 = os.clock()
		while (lp:GetAttribute("Brutality") or 0) < Config.Brutality.Max and os.clock() - b0 < 1.5 do task.wait() end
		freeze("Ultimate")
		brut.Visible = false
		R.Ultimate:FireServer()
		task.wait(0.05)
		rem:FireServer("release")
		sleep(2.2)

		-- 3 THE FIGHT: the real thing, for a moment ----------------------------------------------------------------------
		lp:SetAttribute("IntroPhase", "fight")
		rem:FireServer("fight")
		skipBtn.Visible = false
		inputSink(false)
		camScripted = false
		cam.CameraType = Enum.CameraType.Custom
		cam.CameraSubject = hum
		hrpP.Anchored = false
		bodiesHidden = false
		showBodies()
		showGuis()
		banner.Text = "BEAT HER UP!"
		banner.Visible = true
		hint.Text = "HOLD " .. Platform.label("Punch") .. " TO CHARGE: KNOCK HER FLYING"
		hint.Visible = true
		task.delay(6, function() banner.Visible = false; hint.Visible = false end)
		local maxT = (studio and tonumber(lp:GetAttribute("DebugIntroFight"))) or 75
		local f1 = os.clock()
		while os.clock() - f1 < maxT do
			local g = real()
			if not g or g:GetAttribute("State") == "Dead" then break end
			task.wait(0.1)
		end
		banner.Visible = false; hint.Visible = false
		-- she is beaten: Black Plague fades out and the way-out music comes in
		if music then
			local m = music
			TweenService:Create(m, TweenInfo.new(1.6), { Volume = 0 }):Play()
			task.delay(1.7, function() m:Destroy() end)
			music = nil
		end
		task.delay(0.9, function()
			if ended then return end
			local s = Sfx.loop("IntroOutro")
			if not s then return end
			local vol = s.Volume
			s.Volume = 0
			TweenService:Create(s, TweenInfo.new(1.5), { Volume = vol }):Play()
			music = s
		end)
		task.wait(2)

		-- 4 THE WAY OUT --------------------------------------------------------------------------------------------------
		lp:SetAttribute("IntroPhase", "exit")
		TweenService:Create(black, TweenInfo.new(0.6), { BackgroundTransparency = 0 }):Play()
		task.wait(0.65)
		inputSink(true)
		hideGuis()
		pcall(function() R.Block:FireServer(false) end)
		rem:FireServer("exit")
		local e0 = os.clock()
		while not lp:GetAttribute("IntroExit") and os.clock() - e0 < 6 do task.wait(0.1) end
		task.wait(0.5)
		hrpP.Anchored = true
		bodiesHidden = true
		hideBodies()
		-- the front doors (this screen moves them; put back at the end). The house has them standing open (swung in):
		-- they are shut first, behind the black, then they burst open on their hinges, back to how the house has them
		local front = workspace.Mansion:FindFirstChild("Front1", true)
		local leaves = {} :: { { parts: { BasePart }, hinge: Vector3, cf0: { CFrame }, shut: { CFrame }, swing: number } }
		local doorAt = hrpP.Position + hrpP.CFrame.LookVector * 7
		local function yawBetween(a: Vector3, b: Vector3): number return math.atan2(a:Cross(b).Y, a:Dot(b)) end
		local function about(h: Vector3, ang: number): CFrame return CFrame.new(h) * A(0, ang, 0) * CFrame.new(-h) end
		if front then
			local mid, n = Vector3.zero, 0
			for _, d in front:GetDescendants() do
				if d:IsA("BasePart") and d.Name == "DoorLeaf" then mid += d.Position; n += 1 end
			end
			if n > 0 then
				mid /= n
				local out = Vector3.new(mid.X, 0, mid.Z).Unit -- (the house's middle is the origin: outward)
				local along = UP:Cross(out) -- along the wall
				local sides = { [-1] = {} :: { BasePart }, [1] = {} :: { BasePart } }
				for _, d in front:GetDescendants() do
					if d:IsA("BasePart") and (d.Name == "DoorLeaf" or d.Name == "Panel") then
						table.insert(sides[(d.Position - mid):Dot(along) >= 0 and 1 or -1], d)
					end
				end
				local shutSum, shutN = Vector3.zero, 0
				for _, parts in sides do
					local leaf: BasePart? = nil
					for _, p in parts do if p.Name == "DoorLeaf" then leaf = p end end
					if leaf then
						-- its long flat side, the two ends of it, and which one is the hinge
						local rx = leaf.CFrame.RightVector * leaf.Size.X
						local rz = leaf.CFrame.LookVector * leaf.Size.Z
						local fx, fz = Vector3.new(rx.X, 0, rx.Z), Vector3.new(rz.X, 0, rz.Z)
						local long = fx.Magnitude >= fz.Magnitude and fx or fz
						local e1, e2 = leaf.Position + long / 2, leaf.Position - long / 2
						local isOpen = math.abs(long.Unit:Dot(out)) > 0.7
						local hinge: Vector3
						if isOpen then
							hinge = (e1 - e2):Dot(out) > 0 and e1 or e2 -- (swung in: the end at the wall)
						else
							hinge = math.abs((e1 - mid):Dot(along)) > math.abs((e2 - mid):Dot(along)) and e1 or e2 -- (the outer end)
						end
						local free = leaf.Position - hinge
						free = Vector3.new(free.X, 0, free.Z).Unit
						local toMid = along * (mid - hinge):Dot(along)
						toMid = toMid.Magnitude > 0.01 and toMid.Unit or free
						local shutRot = isOpen and yawBetween(free, toMid) or 0
						local cf0, shut = {}, {}
						for i, p in parts do
							cf0[i] = p.CFrame
							shut[i] = about(hinge, shutRot) * p.CFrame
							p.CFrame = shut[i]
						end
						shutSum += leaf.Position
						shutN += 1
						-- it swings into the house: back to how the house has it (or a quarter turn in)
						table.insert(leaves, { parts = parts, hinge = hinge, cf0 = cf0, shut = shut, swing = isOpen and -shutRot or yawBetween(toMid, -out) })
					end
				end
				if shutN > 0 then doorAt = shutSum / shutN end
			end
		end
		table.insert(restores, function()
			for _, lf in leaves do for i, p in lf.parts do if p.Parent then p.CFrame = lf.cf0[i] end end end
		end)
		local outward = Vector3.new(doorAt.X, 0, doorAt.Z).Unit
		local eye = hrpP.Position + UP * 1.6
		camScripted = true
		camRate = 6
		camCF = CFrame.lookAt(eye, doorAt)
		camFn = function() return CFrame.lookAt(eye, doorAt) end
		letterbox(true, 0)
		TweenService:Create(black, TweenInfo.new(0.7), { BackgroundTransparency = 1 }):Play()
		sleep(0.9)
		-- the doors burst open, the moon floods in
		Sfx.at("DoorCreak", doorAt, { Volume = 1.3, PlaybackSpeed = 0.9 })
		Sfx.at("Crash", doorAt, { Volume = 0.7, PlaybackSpeed = 0.8 })
		flash(Color3.fromRGB(170, 190, 240), 0.35, 0.6)
		shake(0.3)
		local o0 = S
		table.insert(frameFns, function()
			-- (thrown open: fast, a little past the stop, then back on it)
			local u = seg(S - o0, 0, 0.6)
			local k = 1 + 2.4 * (u - 1) ^ 3 + 1.4 * (u - 1) ^ 2
			for _, lf in leaves do
				local rot = about(lf.hinge, lf.swing * k)
				for i, p in lf.parts do p.CFrame = rot * lf.shut[i] end
			end
		end)
		sleep(0.8)
		-- THE TRAIN (this screen's own copies of ReplicatedStorage.Intro.Train, tools/build/lobby_station.luau): a helper
		-- that places one, turns its wheels as it rolls, slides its door and makes its windows clear glass from inside
		local gp = RaycastParams.new()
		gp.FilterType = Enum.RaycastFilterType.Exclude
		gp.FilterDescendantsInstances = { ch :: Instance, folder }
		local function newTrain(parent: Instance): any
			local src = set:FindFirstChild("Train") :: Model?
			if not src or not src.PrimaryPart then return nil end
			local m = src:Clone()
			local base = (m.PrimaryPart :: BasePart).CFrame
			local items = {} :: { { p: BasePart, off: CFrame, r: number, cyl: boolean } }
			for _, d in m:GetDescendants() do
				if d:IsA("BasePart") then
					local r = d:GetAttribute("R")
					table.insert(items, { p = d, off = base:ToObjectSpace(d.CFrame), r = type(r) == "number" and r or 0, cyl = d:IsA("Part") and d.Shape == Enum.PartType.Cylinder })
				end
			end
			local doorP, doorW = m:FindFirstChild("Door"), m:FindFirstChild("DoorWindow")
			local fl = m:FindFirstChild("CarFloor") :: BasePart?
			local T: any = { model = m, cf = base, rolled = 0, door = 0, root = m.PrimaryPart,
				doorLocal = Vector3.new(tonumber(m:GetAttribute("DoorX")) or 21.5, 0, 3.3),
				floorLocal = fl and (base:PointToObjectSpace(fl.Position).Y + fl.Size.Y / 2) or 1.2 }
			function T.place()
				for _, e in items do
					local off = e.off
					if e.r > 0 then
						local a = T.rolled / e.r
						off = off * (e.cyl and A(-a, 0, 0) or A(0, 0, a))
					elseif T.door > 0 and (e.p == doorP or e.p == doorW) then
						off = CFrame.new(3.1 * T.door, 0, 0) * off -- (it slides along the side, toward the back)
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
			-- the point `l` (in the train's own frame) in the world now
			function T.at(l: Vector3): Vector3 return T.cf * l end
			T.place()
			m.Parent = parent
			return T
		end
		local function puffAt(cf: CFrame, n: number)
			local p = Instance.new("Part")
			p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.Transparency = 1
			p.Size = Vector3.new(12, 1, 7); p.CFrame = cf
			p.Parent = workspace:FindFirstChild("IntroTrain") or folder
			local e = Instance.new("ParticleEmitter")
			e.Texture = "rbxasset://textures/particles/smoke_main.dds"
			e.Color = ColorSequence.new(Color3.fromRGB(210, 210, 215))
			e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 5) })
			e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) })
			e.Lifetime = NumberRange.new(1.2, 1.8); e.Rate = 0; e.Speed = NumberRange.new(3, 6); e.SpreadAngle = Vector2.new(60, 60)
			e.LightInfluence = 0.7
			e.Parent = p
			e:Emit(n)
			Debris:AddItem(p, 3)
		end
		local SEAT = Vector3.new(28.5, 0, 0.6) -- (by a window on the door's side, in the train's frame: x from its front, z across; y = floor + 4.4)

		-- the train waiting on the yard's railway (Grounds.Railway, tools/build/grounds.luau), its door open toward the
		-- house (a map with no railway gets a stretch of track of its own, this screen only)
		local function groundAt(p: Vector3): number
			local r = workspace:Raycast(Vector3.new(p.X, eye.Y + 1.5, p.Z), Vector3.new(0, -40, 0), gp)
			return r and r.Position.Y or (eye.Y - 4.6)
		end
		local trackAt = Vector3.new(doorAt.X, 0, doorAt.Z) + outward * 42
		local railY: number? = nil
		do
			local g = workspace:FindFirstChild("Grounds")
			local rw = g and g:FindFirstChild("Railway")
			if rw then
				local sum, n, y = Vector3.zero, 0, 0
				for _, p in rw:GetChildren() do
					if p:IsA("BasePart") and p.Name == "Rail" then sum += p.Position; n += 1; y = p.Position.Y end
				end
				if n >= 2 then
					local mid = sum / n
					-- (the railway runs across the yard: the point of it in front of the door)
					trackAt = Vector3.new(doorAt.X, 0, doorAt.Z) + outward * (mid - Vector3.new(doorAt.X, 0, doorAt.Z)):Dot(outward)
					railY = y
				end
			end
		end
		local hTrain = newTrain(folder)
		local insideW = trackAt + UP * (eye.Y - 1)
		local doorW = trackAt - outward * 3.3
		local floorW = eye.Y - 2.4
		if hTrain then
			local rootY = railY and (railY + 0.19) or (groundAt(trackAt) + 1) -- (its wheels on the rails)
			local rot = CFrame.fromMatrix(Vector3.zero, UP:Cross(-outward), UP) -- (its door side, +Z of its own, toward the house)
			local dl = hTrain.doorLocal
			local doorTarget = Vector3.new(trackAt.X, rootY, trackAt.Z) - outward * 3.3
			hTrain.cf = rot + (doorTarget - rot * dl)
			hTrain.door = 1
			hTrain.place()
			hTrain.smoke(5)
			floorW = hTrain.at(Vector3.new(0, hTrain.floorLocal, 0)).Y
			doorW = hTrain.at(Vector3.new(dl.X, hTrain.floorLocal, dl.Z))
			insideW = hTrain.at(Vector3.new(SEAT.X, hTrain.floorLocal + 4.4, SEAT.Z))
			if not railY then
				local tr = Instance.new("Model"); tr.Name = "YardTrack"; tr.Parent = folder
				local function tp(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, variant: string?)
					local p = Instance.new("Part")
					p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat
					if variant then p.MaterialVariant = variant end
					p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.Parent = tr
				end
				local rcf = hTrain.cf
				tp("Ballast", Vector3.new(160, 0.35, 8), rcf * CFrame.new(-20, -0.82, 0), Color3.fromRGB(58, 54, 50), Enum.Material.Slate, "PS2_Stone")
				for lx = -98, 58, 2.2 do
					tp("Sleeper", Vector3.new(0.9, 0.3, 6.6), rcf * CFrame.new(lx, -0.55, 0), Color3.fromRGB(44, 32, 26), Enum.Material.Wood, "PS2_DarkBeam")
				end
				for _, s in { -1, 1 } do
					tp("Rail", Vector3.new(160, 0.42, 0.34), rcf * CFrame.new(-20, -0.19, s * 2.2), Color3.fromRGB(96, 92, 88), Enum.Material.Metal)
				end
			end
		end
		-- on foot (the head bobs): out across the porch and down its steps, the train waiting out there; a blink; the
		-- last steps up into the carriage
		local function eyeAt(p: Vector3): Vector3 return Vector3.new(p.X, groundAt(p) + 4.6, p.Z) end
		local trainLook = Vector3.new(doorW.X, floorW + 3, doorW.Z)
		local function walkPath(pts: { Vector3 }, speed: number, lookAt: Vector3?): number
			local cum = { 0 }
			for i = 2, #pts do cum[i] = cum[i - 1] + (pts[i] - pts[i - 1]).Magnitude end
			local total = cum[#pts]
			local function along(d: number): Vector3
				d = math.clamp(d, 0, total)
				for i = 2, #pts do
					if d <= cum[i] or i == #pts then
						local f = (d - cum[i - 1]) / math.max(0.01, cum[i] - cum[i - 1])
						return pts[i - 1]:Lerp(pts[i], math.clamp(f, 0, 1))
					end
				end
				return pts[#pts]
			end
			local w0 = S
			camFn = function(s)
				local d = math.min(total, (s - w0) * speed)
				local bob = math.abs(math.sin(d * 0.8)) * 0.22 * math.min(1, (total - d) / 3)
				local pos = along(d)
				local tgt = lookAt or along(d + 6)
				if (tgt - pos).Magnitude < 2 then tgt = pos + outward * 6 end
				return CFrame.lookAt(pos + UP * bob, tgt + UP * (bob - 0.4))
			end
			return total / speed
		end
		camRate = 7
		if Fx then Fx.cine = true end
		table.insert(restores, function() if Fx then Fx.cine = false end end)
		if hTrain then Sfx.at("TrainWhistle", hTrain.root.Position, { Volume = 1.2 }) end
		local d1 = walkPath({ eye, eyeAt(doorAt + outward * 1.5), eyeAt(doorAt + outward * 10), eyeAt(doorAt + outward * 19), eyeAt(doorAt + outward * 25) }, 9)
		local lookFrom = S
		local walkFn = camFn
		camFn = function(s) -- (the eyes go to the train once outside)
			local cf = walkFn(s)
			local k = ss(seg(s - lookFrom, d1 * 0.45, d1 * 0.9))
			return CFrame.lookAt(cf.Position, (cf.Position + cf.LookVector * 10):Lerp(trainLook, k))
		end
		sleep(d1 + 0.35)
		TweenService:Create(black, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
		sleep(0.3)
		fistsOff = true
		local near = Vector3.new(doorW.X, 0, doorW.Z) - outward * 7
		local d2 = walkPath({ eyeAt(near), eyeAt(near + outward * 3.8), Vector3.new(doorW.X, floorW + 4.4, doorW.Z) + outward * 0.8, Vector3.new(doorW.X, floorW + 4.4, doorW.Z) + outward * 3.3 }, 6)
		camCF = camFn(S)
		TweenService:Create(black, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
		sleep(math.max(0, d2 - 1))
		if hTrain then hTrain.glass(true) end -- (stepping in: the windows are glass from here)
		sleep(1.15)
		-- in the carriage: to the window seat, turned round to the house; the door slides shut
		local inPos = Vector3.new(doorW.X, floorW + 4.4, doorW.Z) + outward * 3.3
		local t1 = S
		camRate = 5
		camFn = function(s)
			local k = ss(seg(s - t1, 0, 1.2))
			local dir = (outward * math.cos(math.pi * k) + UP:Cross(-outward) * math.sin(math.pi * k) * 0.6)
			local p = inPos:Lerp(insideW, k)
			return CFrame.lookAt(p, p + dir * 10 - UP * 0.4)
		end
		sleep(1.0)
		if hTrain then
			Sfx.at("TrainDoor", doorW, { Volume = 1 })
			local d0 = S
			table.insert(frameFns, function()
				local k = 1 - ss(seg(S - d0, 0, 0.6))
				if k ~= hTrain.door then hTrain.door = k; hTrain.place() end
			end)
		end
		sleep(0.9)
		-- it pulls away: the house slides off past the window
		local rollSnd: Sound? = nil
		local base0 = hTrain and hTrain.cf
		if hTrain then
			Sfx.at("TrainWhistle", hTrain.root.Position, { Volume = 1.1, PlaybackSpeed = 0.95 })
			shake(0.25)
			rollSnd = Sfx.on("TrainRoll", hTrain.root, { Volume = 0.8 })
			hTrain.smoke(16)
			local m0 = S
			table.insert(frameFns, function()
				local t = S - m0
				local dist = 3.5 * t * t -- (gathering speed)
				hTrain.cf = (base0 :: CFrame) * CFrame.new(-dist, 0, 0)
				hTrain.rolled = dist
				hTrain.place()
			end)
		end
		local seatLook = -outward
		camFn = function()
			local p = hTrain and hTrain.at(Vector3.new(SEAT.X, hTrain.floorLocal + 4.4, SEAT.Z)) or insideW
			return CFrame.lookAt(p, p + seatLook * 10 + UP * 0.6)
		end
		camRate = 12
		sleep(3.0)

		-- the title: black, and it slams in
		shake(0.3)
		local card = Grunge.frame(gui, { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 27 })
		TweenService:Create(card, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
		sleep(0.35)
		local title = Grunge.text(gui, { Text = "BEAT EVERY GHOST!", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46),
			Size = UDim2.fromScale(0.8, 0.2), TextColor3 = Color3.fromRGB(235, 50, 35), TextStrokeTransparency = 0, TextTransparency = 1, ZIndex = 28 })
		local tsc = Instance.new("UIScale")
		tsc.Parent = title
		-- (big: about three quarters of the screen's width - TextScaled alone stops at 100 px)
		task.wait()
		local want = math.clamp(cam.ViewportSize.X * 0.72 / math.max(1, title.TextBounds.X), 1, 2.4)
		tsc.Scale = want * 2.2
		title.TextTransparency = 0
		TweenService:Create(tsc, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = want }):Play()
		task.delay(0.3, function()
			if ended then return end
			Sfx.play("PunchHeavy", { Volume = 1.2, PlaybackSpeed = 0.4 })
			Sfx.play("Thunder", { Volume = 0.8, PlaybackSpeed = 1.1 })
			shake(0.6); kick(5)
		end)
		local tPulse = RunService.Heartbeat:Connect(function() title.Rotation = math.sin(os.clock() * 5) * 1.2 end)
		table.insert(conns, tPulse)
		-- behind the title: back to the park (the server takes the player out of the house)
		hrpP.Anchored = false
		rem:FireServer("done")
		local spawnPart = workspace:FindFirstChild("LobbySpawn") :: BasePart?
		local w0 = os.clock()
		local function inPark(): boolean
			return not lp:GetAttribute("InMatch") and spawnPart ~= nil and (hrpP.Position - spawnPart.Position).Magnitude < 80
		end
		while not inPark() and os.clock() - w0 < 6 do task.wait(0.1) end
		task.wait(math.max(0, 1.4 - (os.clock() - w0))) -- (the title stays up a moment)
		if not inPark() or not spawnPart then
			finish() -- (not back in the park: the plain way out)
			return
		end

		-- ARRIVING IN THE PARK, IN THE TRAIN: still at the window seat, out of the tunnel, past the stone arch, along the
		-- platform's lanterns, slower and slower; it stops (Lobby.Station, tools/build/lobby_station.luau). The door slides
		-- open, the player steps out onto the platform and walks off toward the park, the camera following them back to
		-- where the lobby's own camera takes over. Then the train backs out into the tunnel.
		if hTrain then hTrain.model:Destroy() end -- (the one at the house)
		local tf = Instance.new("Folder")
		tf.Name = "IntroTrain" -- (not in the intro's folder: it leaves after the intro is over)
		tf.Parent = workspace
		local train = newTrain(tf)
		if not train then
			finish()
			return
		end
		lp:SetAttribute("IntroPhase", "arrive")
		hrpP.Anchored = true -- (where the server put them, out of sight, until the door opens)
		train.glass(true)
		local stopCF = train.cf
		local RUN, T_IN = 66, 4.6 -- (it starts just out of the tunnel's mouth)
		local trainAt = RUN
		local function setAt(x: number)
			train.rolled += trainAt - x
			trainAt = x
			train.cf = stopCF * CFrame.new(x, 0, 0)
			train.place()
		end
		setAt(RUN)
		train.smoke(14)
		local rollIn = Sfx.on("TrainRoll", train.root, { Volume = 0.9 })
		local a0 = S
		table.insert(frameFns, function()
			if not train.model.Parent then return end
			local u = math.clamp((S - a0) / T_IN, 0, 1)
			setAt(RUN * (1 - u) * (1 - u)) -- (slowing all the way in)
			if rollIn then rollIn.Volume = 0.9 * math.min(1, (1 - u) * 2.5) + 0.05 end
		end)
		local seatY = train.floorLocal + 4.4
		local dl = train.doorLocal
		camRate = 12
		local doorTurn = 0
		camFn = function()
			local p = train.at(Vector3.new(SEAT.X, seatY, SEAT.Z))
			local outLook = train.cf:VectorToWorldSpace(Vector3.new(-0.62, -0.05, 0.78).Unit) -- (out and ahead: along the platform)
			local doorLook = (train.at(Vector3.new(dl.X, seatY - 0.6, dl.Z)) - p).Unit
			return CFrame.lookAt(p, p + outLook:Lerp(doorLook, doorTurn) * 10)
		end
		camCF = camFn(S)
		if Fx then Fx.cineFov = 58 end
		TweenService:Create(card, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(title, TweenInfo.new(0.6), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		sleep(0.6)
		Sfx.play("TrainWhistle", { Volume = 0.8 })
		sleep(T_IN - 0.6)
		-- it stops: a jolt, a clank, a burst of steam outside
		train.smoke(0)
		shake(0.2)
		Sfx.at("TrainClank", train.root.Position, { Volume = 0.9 })
		Sfx.at("TrainSteam", train.root.Position + Vector3.new(6, 0, 0), { Volume = 1 })
		puffAt(stopCF * CFrame.new(7, 0.5, 0), 14)
		if rollIn then rollIn:Destroy() end
		local tt = S
		table.insert(frameFns, function() doorTurn = ss(seg(S - tt, 0.2, 1.0)) end)
		sleep(0.7)
		-- the door slides open
		local doorPos = train.at(Vector3.new(dl.X, train.floorLocal, dl.Z))
		Sfx.at("TrainDoor", doorPos, { Volume = 1 })
		local o1 = S
		table.insert(frameFns, function()
			local k = ss(seg(S - o1, 0, 0.6))
			if k ~= train.door then train.door = k; train.place() end
		end)
		sleep(0.75)
		-- the player in the doorway, seen from behind: out onto the platform, then off toward the park
		local controls: any = nil
		-- (Roblox's PlayerModule, where there is one: the player's own keys stay off while they step out)
		local ps = lp:FindFirstChild("PlayerScripts")
		local pm = ps and ps:FindFirstChild("PlayerModule")
		if pm and pm:IsA("ModuleScript") then pcall(function() controls = (require(pm) :: any):GetControls() end) end
		if controls then
			controls:Disable()
			table.insert(restores, function() controls:Enable() end)
		end
		local hipUp = (hum :: Humanoid).HipHeight + hrpP.Size.Y / 2
		local outDir = train.cf:VectorToWorldSpace(Vector3.new(0, 0, 1)) -- (out of the door)
		local inside = doorPos + UP * hipUp - outDir * 2
		hrpP.CFrame = CFrame.lookAt(inside, inside + outDir)
		bodiesHidden = false
		showBodies()
		-- (all of them: the fight's first-person view had hidden the body before the intro's own hiding did)
		for _, d in (ch :: Model):GetDescendants() do
			if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.LocalTransparencyModifier = 0 end
		end
		hrpP.Anchored = false
		local floorY = doorPos.Y
		local out1 = Vector3.new(doorPos.X, floorY, doorPos.Z) + outDir * 3.6 -- (on the platform)
		local toPark = train.cf:VectorToWorldSpace(Vector3.new(-1, 0, 0)) -- (along it, toward the buffers and the park)
		local out2 = out1 + toPark * 9 - outDir * 0.3
		local fdir = outDir
		local c0 = S
		camRate = 6
		camFn = function(s)
			local lv = hrpP.CFrame.LookVector
			lv = Vector3.new(lv.X, 0, lv.Z)
			if lv.Magnitude > 0.1 then fdir = fdir:Lerp(lv.Unit, 0.07).Unit end
			local head = hrpP.Position + UP * 1.5
			local dist = 3.4 + 9.1 * ss(seg(s - c0, 0.5, 2.4))
			local p = head - (fdir - UP * 0.28).Unit * dist
			-- (once they are out on the platform the camera stays on the platform's side, never over the train)
			if train.cf:PointToObjectSpace(hrpP.Position).Z > 4.6 then
				local l = train.cf:PointToObjectSpace(p)
				if l.Z < 4.4 then p = train.cf * Vector3.new(l.X, l.Y, 4.4) end
			end
			return CFrame.lookAt(p, head)
		end
		;(hum :: Humanoid):MoveTo(out1)
		local wt = os.clock()
		while os.clock() - wt < 1.2 and (Vector3.new(hrpP.Position.X, 0, hrpP.Position.Z) - Vector3.new(out1.X, 0, out1.Z)).Magnitude > 1 do task.wait() end
		;(hum :: Humanoid):MoveTo(out2)
		train.glass(false) -- (from outside its windows glow again)
		letterbox(false, 1.2)
		local f0 = S
		table.insert(frameFns, function() if Fx then Fx.cineFov = 58 + 16 * ss(seg(S - f0, 0, 1.4)) end end)
		sleep(2.1)
		-- the train backs out after a while, its door shut, and is gone into the tunnel
		task.spawn(function()
			task.wait(2.5)
			if not train.model.Parent then return end
			Sfx.at("TrainWhistle", train.root.Position, { Volume = 0.8, PlaybackSpeed = 1.05 })
			local tq = os.clock()
			while os.clock() - tq < 0.6 and train.model.Parent do train.door = 1 - ss((os.clock() - tq) / 0.6); train.place(); task.wait() end
			train.door = 0
			task.wait(0.8)
			local snd = Sfx.on("TrainRoll", train.root, { Volume = 0.6 })
			train.smoke(14)
			local tl = os.clock()
			while train.model.Parent and os.clock() - tl < 9 do
				local u = (os.clock() - tl) / 9
				setAt(150 * u * u) -- (gathering speed)
				task.wait()
			end
			if snd then snd:Destroy() end
			tf:Destroy()
		end)
		-- the lobby's camera takes over from right there
		camScripted = false
		cam.CameraType = Enum.CameraType.Custom
		cam.CameraSubject = hum
		finish(true)
	end
	-- (an error anywhere in it must never leave the player frozen in a cinematic: it ends the plain way)
	thread = task.spawn(function()
		local ok, err = xpcall(runScript, debug.traceback)
		if not ok and not ended then
			warn("[Intro] " .. tostring(err))
			finish()
		end
	end)
end

return Intro
