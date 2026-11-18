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
--     claws coming down on the guard), ATTACK (and a few more punches), LIFT (the chair beside you), THROW (into
--     her), ULTIMATE (the Rage Shockwave knocks her flying).
--   3 THE FIGHT: a short real fight (she swings, waits, swings again): charged hits knock her out and smash her
--     through the walls (the ragdoll). It ends when she is beaten (or after a while).
--   4 THE WAY OUT: in the front hall, the doors burst open; out onto the porch, the yard, up over the house to the
--     purple rift in the sky; the game's name. Black, and back in the park.
-- SKIP (the button, or a controller's Select) ends it at any time but in the fight.
-- Player attribute IntroPhase (this client only): enter, tv, freeze:<Action>, lesson, fight, exit, done.
-- Studio test hooks: player attribute DebugIntroAct = "Block" | "Punch" | "Lift" | "Ultimate" | "Skip" acts as that
-- input (set it to something else first to repeat one); DebugIntroHoldAt = the scene's second at which the
-- cinematic's clock stops (photos; clear it to go on); DebugIntroFight = seconds the fight lasts at most.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
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

-- the TV room: the TV and the armchair facing it (Server/Tutorial finds them the same way)
local function tvRoom(): (Model?, Model?)
	local m = workspace:FindFirstChild("Mansion")
	local f = m and m:FindFirstChild("Furniture")
	local tv = f and f:FindFirstChild("TV")
	if not f or not tv or not tv:IsA("Model") then return nil, nil end
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
	local S = 0
	local frozen = false
	local inputSink: (on: boolean) -> ()

	local function finish()
		if ended then return end
		ended = true
		lp:SetAttribute("IntroPhase", "done")
		TweenService:Create(black, TweenInfo.new(0.45), { BackgroundTransparency = 0 }):Play()
		task.wait(0.5)
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
		rem:FireServer("done")
		local spawnPart = workspace:FindFirstChild("LobbySpawn") :: BasePart?
		local t0 = os.clock()
		while os.clock() - t0 < 5 do
			if not lp:GetAttribute("InMatch") and spawnPart and (hrpP.Position - spawnPart.Position).Magnitude < 80 then break end
			task.wait(0.1)
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
		TweenService:Create(black, TweenInfo.new(0.9), { BackgroundTransparency = 1 }):Play()
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
		for _, f in frameFns do f(dt) end
		if camScripted then
			if not frozen then camCF = camCF:Lerp(camFn(S), math.min(1, dt * camRate)) end
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = camCF
			cam.Focus = camCF -- (the viewmodel shows when the camera is this close to its focus)
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
	thread = task.spawn(function()
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
		local herStand = inRoom(D * 0.42, 6.7)

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
		woman.Parent = folder
		local wroot = woman:FindFirstChild("HumanoidRootPart") :: BasePart
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
		Sfx.at("Crash", landAt, { Volume = 1, PlaybackSpeed = 0.55 })
		shake(0.6); kick(4)
		tvShake = 0.6
		sleep(0.55)
		-- she scuttles to the armchair in jerks, her head cocked
		fovGoal = 64
		local crawlTo = inRoom(D * 0.4, 3.6)
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
		local close = inRoom(D - 5, 6.7)
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
		-- LIFT: the chair beside you (Server/Tutorial put it there: model attribute IntroProp; else the armchair)
		local liftThis: Model = chairM
		for _, c in (workspace.Mansion:FindFirstChild("Furniture") :: Instance):GetChildren() do
			if c:IsA("Model") and c:GetAttribute("IntroProp") then liftThis = c end
		end
		rem:FireServer("hold")
		camRate = 5
		camFn = eyesOn(function() return liftThis:GetPivot().Position + UP * 0.3 end)
		sleep(0.8)
		freeze("Lift")
		R.Grab:FireServer(liftThis)
		local g0 = os.clock()
		while not lp:GetAttribute("Carrying") and os.clock() - g0 < 1.5 do task.wait() end
		camFn = eyesOn(herChest)
		sleep(0.8)
		-- THROW
		freeze("Punch", "Throw")
		R.Throw:FireServer(aim())
		VM.slam()
		task.wait(0.05)
		rem:FireServer("release")
		sleep(1.4)
		-- ULTIMATE: the bar fills, the Rage Shockwave knocks her flying
		rem:FireServer("ult")
		brut.Visible = true
		brutFill.Size = UDim2.fromScale(0.01, 0.72)
		TweenService:Create(brutFill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.fromScale(0.988, 0.72) }):Play()
		Sfx.play("Whoosh", { Volume = 0.8, PlaybackSpeed = 0.6 })
		sleep(0.95)
		Sfx.play("Cash", { PlaybackSpeed = 0.7, Volume = 0.7 })
		flash(RAGE, 0.25, 0.3)
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
		local maxT = (studio and tonumber(lp:GetAttribute("DebugIntroFight"))) or 45
		local f1 = os.clock()
		while os.clock() - f1 < maxT do
			local g = real()
			if not g or g:GetAttribute("State") == "Dead" then break end
			task.wait(0.1)
		end
		banner.Visible = false; hint.Visible = false
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
		-- the front doors (this screen moves them; put back at the end)
		local front = workspace.Mansion:FindFirstChild("Front1", true)
		local leaves = {} :: { { parts: { BasePart }, hinge: Vector3, sign: number, cf0: { CFrame } } }
		local doorAt = hrpP.Position + hrpP.CFrame.LookVector * 7
		if front then
			local sides = { [-1] = {} :: { BasePart }, [1] = {} :: { BasePart } }
			local mid = Vector3.zero
			local n = 0
			for _, d in front:GetDescendants() do
				if d:IsA("BasePart") and d.Name == "DoorLeaf" then mid += d.Position; n += 1 end
			end
			if n > 0 then mid /= n; doorAt = mid end
			for _, d in front:GetDescendants() do
				if d:IsA("BasePart") and (d.Name == "DoorLeaf" or d.Name == "Panel") then
					table.insert(sides[d.Position.X >= mid.X and 1 or -1], d)
				end
			end
			for sgn, parts in sides do
				if #parts > 0 then
					local edge = sgn > 0 and -math.huge or math.huge
					for _, p in parts do
						local half = p.CFrame:VectorToWorldSpace(p.Size / 2)
						local ex = math.abs(half.X)
						edge = sgn > 0 and math.max(edge, p.Position.X + ex) or math.min(edge, p.Position.X - ex)
					end
					local cf0 = {}
					for i, p in parts do cf0[i] = p.CFrame end
					table.insert(leaves, { parts = parts, hinge = Vector3.new(edge, mid.Y, mid.Z), sign = sgn, cf0 = cf0 })
				end
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
			local k = ss(seg(S - o0, 0, 0.7))
			for _, lf in leaves do
				local h = CFrame.new(lf.hinge)
				local rot = h * A(0, lf.sign * math.rad(100) * k, 0) * h:Inverse()
				for i, p in lf.parts do p.CFrame = rot * lf.cf0[i] end
			end
		end)
		sleep(0.8)
		-- out of the house, down the yard, up over it to the rift in the sky
		local riftAt = Vector3.new(doorAt.X, doorAt.Y + 120, doorAt.Z - 90)
		local rift = set:FindFirstChild("Rift") :: Model?
		if rift then
			local r = rift:Clone()
			r:PivotTo(CFrame.new(riftAt))
			r.Parent = folder
		end
		local houseAt = Vector3.new(doorAt.X, doorAt.Y + 8, doorAt.Z - 30)
		local path = {
			eye, doorAt + outward * 1 + UP * 0.5, doorAt + outward * 9 + UP * 1, doorAt + outward * 30 + UP * 4, doorAt + outward * 52 + UP * 22, doorAt + outward * 60 + UP * 34,
		}
		local aims = { doorAt, doorAt + outward * 20, doorAt + outward * 60, houseAt, riftAt, riftAt }
		local p0 = S
		local DUR = 6.5
		camRate = 7
		camFn = function(s)
			local u = math.clamp((s - p0) / DUR, 0, 1) * (#path - 1)
			local i = math.min(#path - 1, math.floor(u) + 1)
			local f = ss(u - (i - 1))
			return CFrame.lookAt(path[i]:Lerp(path[i + 1], f), aims[i]:Lerp(aims[i + 1], f))
		end
		if Fx then Fx.cine = true end
		table.insert(restores, function() if Fx then Fx.cine = false end end)
		sleep(3.3)
		Sfx.play("Thunder", { Volume = 1.1, PlaybackSpeed = 0.9 })
		flash(Color3.fromRGB(190, 160, 255), 0.35, 0.5)
		sleep(1.6)
		local title = Grunge.text(gui, { Text = "BEAT THE GHOST", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42),
			Size = UDim2.fromScale(0.7, 0.18), TextColor3 = Color3.fromRGB(235, 50, 35), TextStrokeTransparency = 0, TextTransparency = 1, ZIndex = 28 })
		TweenService:Create(title, TweenInfo.new(0.6), { TextTransparency = 0 }):Play()
		sleep(2.2)
		finish()
	end)
end

return Intro
