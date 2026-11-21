--!strict
-- THE TUTORIAL's door on the client: the intro itself is Client/Intro (the TV, the Woman, the frozen lessons, the
-- way out); Server/Tutorial saves that it was played.
--   * A NEW PLAYER (player attribute TutorialSeen = false, set by Server/Data): the screen goes all black at once
--     (the park never shows) and, once the loading screen is gone, a READY button waits in the middle of it; READY
--     (click, tap, Enter, a controller's A / Start) starts the intro, which opens on black too. In Studio (where the
--     save never loads) only with the ReplicatedStorage attribute DebugAutoTutorial = true.
--   * HOW TO PLAY: a small button under the lobby's header line plays it; it is gone for good once the player has
--     played the tutorial (player attribute TutorialSeen = true: the user, 2026-11-21).
-- Lobby servers only (ReplicatedStorage attribute TutorialOn, set by Server/Tutorial).
-- Studio test hooks: player attribute DebugIntro = true starts it; DebugReady = true shows the READY screen,
-- DebugReady = "press" presses READY.
local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Intro = require(script.Parent.Intro)
local Loading = require(game:GetService("ReplicatedFirst"):WaitForChild("Loading"))
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local DARK = Color3.fromRGB(38, 31, 27)

local function remote(): RemoteEvent return Remotes:WaitForChild("Tutorial") :: RemoteEvent end

local function play()
	if Intro.running() or lp:GetAttribute("InMatch") or not RS:GetAttribute("TutorialOn") then return end
	remote():FireServer("seen")
	Intro.play()
end

function UI.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TutorialUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9
	gui.Parent = lp:WaitForChild("PlayerGui")
	-- HOW TO PLAY, under the lobby's header line
	local howBtn = Instance.new("TextButton")
	howBtn.AutoButtonColor = false; howBtn.BorderSizePixel = 0; howBtn.BackgroundTransparency = 1; howBtn.Text = ""
	howBtn.AnchorPoint = Vector2.new(0.5, 0); howBtn.Position = UDim2.new(0.5, 0, 0.04, 126); howBtn.Size = UDim2.fromScale(0.1, 0.042)
	howBtn.Rotation = -1; howBtn.Visible = false; howBtn.ZIndex = 4; howBtn.Parent = gui
	Grunge.brush(howBtn, { Size = UDim2.fromScale(1, 1), ZIndex = 4 }, DARK, 79, 12, false)
	Grunge.text(howBtn, { Text = "HOW TO PLAY", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.88, 0.6), ZIndex = 7 })
	local sc = Instance.new("UIScale"); sc.Parent = howBtn
	howBtn.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.05 }):Play() end)
	howBtn.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	local hmin = Instance.new("UISizeConstraint"); hmin.MinSize = Vector2.new(118, 30); hmin.Parent = howBtn
	howBtn.Activated:Connect(function()
		Sfx.play("Click")
		play()
	end)
	local function refresh()
		howBtn.Visible = RS:GetAttribute("TutorialOn") == true and lp:GetAttribute("TutorialSeen") == false and not lp:GetAttribute("InMatch")
			and not Platform.windowOpen() and not Intro.running()
	end
	lp:GetAttributeChangedSignal("TutorialSeen"):Connect(refresh)
	lp:GetAttributeChangedSignal("InMatch"):Connect(refresh)
	lp:GetAttributeChangedSignal("IntroPhase"):Connect(refresh)
	RS:GetAttributeChangedSignal("TutorialOn"):Connect(refresh)
	Platform.windowChanged:Connect(refresh)
	refresh()

	-- A NEW PLAYER: all black at once, then READY in the middle once the loading screen is gone
	local pressReady: (() -> ())? = nil
	local function readyScreen()
		local pg = lp:WaitForChild("PlayerGui")
		if pg:FindFirstChild("ReadyUI") then return end
		local rg = Instance.new("ScreenGui")
		rg.Name = "ReadyUI"; rg.ResetOnSpawn = false; rg.IgnoreGuiInset = true
		rg.DisplayOrder = 65 -- (over the lobby's HUD, under the loading screen and under the intro's own layer)
		rg.Parent = pg
		Grunge.frame(rg, { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1 })
		local btn = Instance.new("TextButton")
		btn.AutoButtonColor = false; btn.BorderSizePixel = 0; btn.BackgroundTransparency = 1; btn.Text = ""
		btn.AnchorPoint = Vector2.new(0.5, 0.5); btn.Position = UDim2.fromScale(0.5, 0.5); btn.Size = UDim2.fromScale(0.22, 0.11)
		btn.Rotation = -1.5; btn.Visible = false; btn.ZIndex = 3; btn.Parent = rg
		local bmin = Instance.new("UISizeConstraint"); bmin.MinSize = Vector2.new(190, 66); bmin.Parent = btn
		Grunge.brush(btn, { Size = UDim2.fromScale(1, 1), ZIndex = 3 }, Color3.fromRGB(122, 20, 16), 91, 14, false)
		Grunge.text(btn, { Text = "READY", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52),
			Size = UDim2.fromScale(0.78, 0.74), TextColor3 = Color3.fromRGB(245, 232, 214), TextStrokeTransparency = 0, ZIndex = 6 })
		local keyHint = Grunge.text(rg, { Text = "", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.56, 8), Size = UDim2.fromScale(0.2, 0.034),
			TextColor3 = Color3.fromRGB(242, 200, 60), TextStrokeTransparency = 0, Visible = false, ZIndex = 6 })
		local sc = Instance.new("UIScale"); sc.Parent = btn
		local hover = false
		btn.MouseEnter:Connect(function() hover = true end)
		btn.MouseLeave:Connect(function() hover = false end)
		local pulse = RunService.Heartbeat:Connect(function()
			local want = hover and 1.08 or (1 + math.sin(os.clock() * 3.2) * 0.035)
			sc.Scale += (want - sc.Scale) * 0.25
		end)
		local done = false
		local function go()
			if done or not btn.Visible then return end
			done = true
			CAS:UnbindAction("TutorialReady")
			pulse:Disconnect()
			Sfx.play("Click")
			keyHint.Visible = false
			TweenService:Create(sc, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 }):Play()
			task.wait(0.25)
			play()
			-- (the intro's own black is up now: this one goes from under it; nothing left if it could not start)
			task.wait(Intro.running() and 1 or 0)
			rg:Destroy()
			pressReady = nil
		end
		pressReady = function() task.spawn(go) end
		btn.Activated:Connect(function() task.spawn(go) end)
		task.spawn(function()
			while Loading.isShown() do task.wait(0.2) end
			while not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) do task.wait(0.2) end
			task.wait(0.3)
			if done or not rg.Parent then return end
			btn.Visible = true
			sc.Scale = 0
			local mode = Platform.mode()
			keyHint.Text = mode == "gamepad" and "[A]" or (mode == "touch" and "" or "[ENTER]")
			keyHint.Visible = keyHint.Text ~= ""
			if mode == "gamepad" then pcall(function() GuiService.SelectedObject = btn end) end
			CAS:BindActionAtPriority("TutorialReady", function(_, st: Enum.UserInputState)
				if st == Enum.UserInputState.Begin then task.spawn(go) end
				return Enum.ContextActionResult.Sink
			end, false, 3000, Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonStart)
		end)
	end
	task.spawn(function()
		while lp:GetAttribute("TutorialSeen") == nil do lp:GetAttributeChangedSignal("TutorialSeen"):Wait() end
		if lp:GetAttribute("TutorialSeen") then return end
		if RunService:IsStudio() and RS:GetAttribute("DebugAutoTutorial") ~= true then return end
		readyScreen()
	end)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugIntro"):Connect(function()
			if lp:GetAttribute("DebugIntro") then play() end
		end)
		lp:GetAttributeChangedSignal("DebugReady"):Connect(function()
			local v = lp:GetAttribute("DebugReady")
			if v == true then task.spawn(readyScreen) elseif v == "press" and pressReady then (pressReady :: () -> ())() end
		end)
	end
end

return UI
