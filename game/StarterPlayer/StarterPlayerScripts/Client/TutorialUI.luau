--!strict
-- THE TUTORIAL's door on the client: the intro itself is Client/Intro (the TV, the Woman, the frozen lessons, the
-- way out); Server/Tutorial saves that it was played.
--   * A NEW PLAYER (player attribute TutorialSeen = false, set by Server/Data) is put straight into it once the
--     loading screen is gone: no question asked. In Studio (where the save never loads) only with the
--     ReplicatedStorage attribute DebugAutoTutorial = true.
--   * HOW TO PLAY: a small button under the lobby's header line plays it again (it has SKIP).
-- Lobby servers only (ReplicatedStorage attribute TutorialOn, set by Server/Tutorial).
-- Studio test hook: player attribute DebugIntro = true starts it.
local Players = game:GetService("Players")
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
		howBtn.Visible = RS:GetAttribute("TutorialOn") == true and not lp:GetAttribute("InMatch") and not Platform.windowOpen() and not Intro.running()
	end
	lp:GetAttributeChangedSignal("InMatch"):Connect(refresh)
	lp:GetAttributeChangedSignal("IntroPhase"):Connect(refresh)
	RS:GetAttributeChangedSignal("TutorialOn"):Connect(refresh)
	Platform.windowChanged:Connect(refresh)
	refresh()

	-- A NEW PLAYER: straight into the intro once the loading screen is gone and the character stands in the park
	task.spawn(function()
		while lp:GetAttribute("TutorialSeen") == nil do lp:GetAttributeChangedSignal("TutorialSeen"):Wait() end
		if lp:GetAttribute("TutorialSeen") then return end
		if RunService:IsStudio() and RS:GetAttribute("DebugAutoTutorial") ~= true then return end
		while Loading.isShown() do task.wait(0.2) end
		while not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) do task.wait(0.2) end
		task.wait(0.3)
		if not lp:GetAttribute("TutorialSeen") then play() end
	end)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugIntro"):Connect(function()
			if lp:GetAttribute("DebugIntro") then play() end
		end)
	end
end

return UI
