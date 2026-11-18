--!strict
-- THE TUTORIAL on the client (Server/Tutorial runs it, Shared/Tutorial holds the steps).
--   * THE OFFER: a popup in the lobby the first time a player joins (player attribute TutorialSeen = false, set by
--     Server/Data): PLAY THE TUTORIAL / NO THANKS. Either answer is saved; it is not shown again.
--   * HOW TO PLAY: a small button under the lobby's header line, to take (or retake) the tutorial at any time.
--   * THE CARD, in the house: STEP n / N, what to do right now with the player's own key / controller button /
--     touch button in yellow, what it is for, and a bar that fills as they do it; DONE is stamped on it when the
--     step is finished. Cards that are only read have a NEXT button (Enter, A on a controller, or a tap).
--     QUIT leaves at any time (it is the sandbox's LEAVE: Client/SandboxUI).
-- Lobby servers only (ReplicatedStorage attribute TutorialOn, set by Server/Tutorial).
-- Studio test hook: player attribute DebugTutorial = "ask" shows the offer.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Settings = require(script.Parent.Settings)
local SandboxUI = require(script.Parent.SandboxUI)
local Sfx = require(script.Parent.Sfx)
local Loading = require(game:GetService("ReplicatedFirst"):WaitForChild("Loading"))
local Steps = require(RS.Shared.Tutorial).steps
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local dim: Frame
local pop: Frame
local howBtn: TextButton
local card: Frame
local stepTag: TextLabel
local title: TextLabel
local task_: TextLabel
local why: TextLabel
local count: TextLabel
local doneStamp: TextLabel
local nextBtn: TextButton
local quitBtn: TextButton
local track: Frame
local fillBar: Frame
local shownProg = -1
local lastNext = 0

local RED = Color3.fromRGB(150, 18, 20)
local DARK = Color3.fromRGB(38, 31, 27)
local SLAB = Color3.fromRGB(21, 17, 15)
local GREEN = Color3.fromRGB(110, 200, 90)
local KEY = "#F2C83C" -- the player's key / button, in the task line

local function remote(): RemoteEvent return Remotes:WaitForChild("Tutorial") :: RemoteEvent end

-- a brush-stroke button, like the lobby's
local function button(parent: Instance, text: string, props: { [string]: any }, color: Color3, seed: number): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	local z = props.ZIndex or 10
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, color, seed, 12, false)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.88, 0.6), ZIndex = z + 3 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.05 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	return b
end
local function setLabel(b: TextButton, text: string)
	local l = b:FindFirstChild("Label") :: TextLabel?
	if l then l.Text = text end
end

-- THE OFFER -------------------------------------------------------------------------------------------------
local refresh: () -> ()
local function closeOffer()
	pop.Visible = false
	dim.Visible = false
	refresh()
end
local function answer(yes: boolean)
	if not pop.Visible then return end
	Sfx.play("Click")
	closeOffer()
	remote():FireServer(yes and "start" or "skip")
end
local function offer()
	if pop.Visible or lp:GetAttribute("InMatch") or not RS:GetAttribute("TutorialOn") then return end
	dim.Visible = true
	pop.Visible = true
	local s = pop:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = pop; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	refresh()
end

-- THE CARD --------------------------------------------------------------------------------------------------
-- the player's own key / controller button / touch button for a {Placeholder} of a step's text
local function keyText(action: string): string
	local mode = Platform.mode()
	if action == "Slot" then
		if mode == "gamepad" then return "[L1 / R1]" end
		if mode == "touch" then return "(TAP ITS SLOT)" end
		return "[" .. tostring(lp:GetAttribute("TutorialSlot") or 1) .. "]"
	elseif action == "Throw" then
		return mode == "touch" and "THROW" or Platform.label("Punch")
	elseif action == "Block" and mode == "touch" then
		return "BLOCK"
	end
	return Platform.label(action)
end
local function fill(text: string): string
	return (string.gsub(text, "{(%a+)}", function(a: string) return '<font color="' .. KEY .. '">' .. keyText(a) .. "</font>" end))
end

local function inTutorial(): boolean return lp:GetAttribute("Tutorial") == true and lp:GetAttribute("Sandbox") == true end

function refresh()
	local n = lp:GetAttribute("TutorialStep")
	local def = type(n) == "number" and Steps[n] or nil
	local show = inTutorial() and def ~= nil
	card.Visible = show
	if lp:GetAttribute("InMatch") and pop.Visible then -- in a run or in the house: the offer is gone
		pop.Visible = false
		dim.Visible = false
	end
	howBtn.Visible = RS:GetAttribute("TutorialOn") == true and not lp:GetAttribute("InMatch") and not pop.Visible and not Platform.windowOpen()
	if not show or not def then return end
	local mode = Platform.mode()
	stepTag.Text = "STEP " .. n .. " / " .. #Steps
	title.Text = def.title
	local text = def.task
	if def.taskCarry and lp:GetAttribute("Carrying") then text = def.taskCarry
	elseif def.taskTouch and mode == "touch" then text = def.taskTouch end
	task_.Text = fill(text)
	why.Text = def.why
	local done = lp:GetAttribute("TutorialDone") == n
	local info = def.kind == "info"
	local prog = tonumber(lp:GetAttribute("TutorialProg")) or 0
	local f = done and 1 or math.clamp(prog / math.max(def.goal, 0.01), 0, 1)
	track.Visible = not info
	if f ~= shownProg then
		-- the bar grows (a new step starts it empty at once)
		fillBar.Visible = f > 0
		if f < shownProg or shownProg <= 0 then fillBar.Size = UDim2.fromScale(f < shownProg and f or 0.001, 0.74) end
		TweenService:Create(fillBar, TweenInfo.new(0.22), { Size = UDim2.fromScale(math.max(f, 0.001), 0.74) }):Play()
		shownProg = f
	end
	-- a count for the steps that are counted, nothing for the timed ones
	local counted = (def.kind == "hits" or def.kind == "item" or def.kind == "charged" or def.kind == "throw") and def.goal > 1
	count.Text = counted and (math.floor(done and def.goal or prog) .. " / " .. def.goal) or ""
	count.Visible = not info
	nextBtn.Visible = info
	setLabel(nextBtn, n >= #Steps and (mode == "gamepad" and "FINISH  [A]" or (mode == "touch" and "FINISH" or "FINISH  [ENTER]"))
		or (mode == "gamepad" and "NEXT  [A]" or (mode == "touch" and "NEXT" or "NEXT  [ENTER]")))
	setLabel(quitBtn, mode == "gamepad" and "QUIT  [X]" or (mode == "touch" and "QUIT" or "QUIT  [L]"))
	if done and not doneStamp.Visible then
		doneStamp.Visible = true
		Sfx.play("Cash", { PlaybackSpeed = 1.3, Volume = 0.5 })
		local s = doneStamp:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		s.Parent = doneStamp; s.Scale = 2.2
		TweenService:Create(s, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 1 }):Play()
	elseif not done then
		doneStamp.Visible = false
	end
end

local function nextCard()
	local n = lp:GetAttribute("TutorialStep")
	local def = type(n) == "number" and Steps[n] or nil
	if not inTutorial() or not def or def.kind ~= "info" or os.clock() - lastNext < 0.45 then return end
	lastNext = os.clock()
	Sfx.play("Click")
	remote():FireServer("next")
end

function UI.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "TutorialUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- the offer
	dim = Grunge.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.5, BackgroundColor3 = Color3.new(0, 0, 0), Visible = false, ZIndex = 6 })
	pop = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.46, 0.4), Rotation = -1, Visible = false, ZIndex = 8 }, SLAB, 71, 5, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 2; par.Parent = pop
	Grunge.text(pop, { Text = "FIRST NIGHT HERE?", Font = Grunge.HORROR, Position = UDim2.fromScale(0.06, 0.06), Size = UDim2.fromScale(0.88, 0.25), TextColor3 = Color3.fromRGB(220, 40, 30), ZIndex = 11 })
	Grunge.brush(pop, { Position = UDim2.fromScale(0.3, 0.31), Size = UDim2.fromScale(0.4, 0.025), ZIndex = 10 }, RED, 73, 10, false)
	Grunge.text(pop, { Text = "THE WOMAN CAN TEACH YOU HOW TO FIGHT, ONE STEP AT A TIME. IT TAKES TWO MINUTES.", Font = Grunge.TYPE, Position = UDim2.fromScale(0.08, 0.37), Size = UDim2.fromScale(0.84, 0.24),
		TextColor3 = Color3.fromRGB(215, 205, 185), ZIndex = 11 })
	local yes = button(pop, "PLAY THE TUTORIAL", { Position = UDim2.fromScale(0.07, 0.67), Size = UDim2.fromScale(0.5, 0.25), Rotation = 1, ZIndex = 10 }, RED, 75)
	local no = button(pop, "NO THANKS", { Position = UDim2.fromScale(0.63, 0.7), Size = UDim2.fromScale(0.3, 0.19), Rotation = -1, ZIndex = 10 }, DARK, 77)
	yes.Activated:Connect(function() answer(true) end)
	no.Activated:Connect(function() answer(false) end)
	Platform.menu(pop, function() answer(false) end) -- a controller lands on PLAY THE TUTORIAL; B = no thanks

	-- HOW TO PLAY, under the lobby's header line
	howBtn = button(gui, "HOW TO PLAY", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.04, 126), Size = UDim2.fromScale(0.1, 0.042), Rotation = -1, Visible = false, ZIndex = 4 }, DARK, 79)
	local hmin = Instance.new("UISizeConstraint"); hmin.MinSize = Vector2.new(118, 30); hmin.Parent = howBtn
	howBtn.Activated:Connect(function()
		if lp:GetAttribute("InMatch") then return end
		Sfx.play("Click")
		remote():FireServer("start")
	end)

	-- the card, under the monster's health bar
	card = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.09, 36), Size = UDim2.new(0.46, 0, 0.2, 16), Visible = false, ZIndex = 8 }, SLAB, 83, 4, false)
	local cmin = Instance.new("UISizeConstraint"); cmin.MinSize = Vector2.new(330, 104); cmin.Parent = card
	stepTag = Grunge.text(card, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.03, 0.05), Size = UDim2.fromScale(0.2, 0.13), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 11 })
	title = Grunge.text(card, { Text = "", Font = Grunge.HORROR, Position = UDim2.fromScale(0.24, 0.02), Size = UDim2.fromScale(0.52, 0.22), TextColor3 = Color3.fromRGB(220, 40, 30), ZIndex = 11 })
	quitBtn = button(card, "QUIT", { Position = UDim2.fromScale(0.82, 0.04), Size = UDim2.fromScale(0.16, 0.16), Rotation = 1, ZIndex = 10 }, DARK, 85)
	quitBtn.Activated:Connect(function() SandboxUI.leave() end)
	task_ = Grunge.text(card, { Text = "", RichText = true, Position = UDim2.fromScale(0.03, 0.26), Size = UDim2.fromScale(0.94, 0.26), ZIndex = 11 })
	why = Grunge.text(card, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.54), Size = UDim2.fromScale(0.92, 0.24), TextColor3 = Color3.fromRGB(200, 190, 170),
		TextStrokeTransparency = 0.6, ZIndex = 11 })
	-- the step's progress: a grey painted track, the green fills it
	track = Grunge.brush(card, { Position = UDim2.fromScale(0.04, 0.82), Size = UDim2.fromScale(0.62, 0.13), ZIndex = 10 }, Color3.fromRGB(70, 62, 55), 87, 22, false)
	fillBar = Grunge.brush(track, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.005, 0.5), Size = UDim2.fromScale(0.001, 0.74), Visible = false, ZIndex = 12 }, GREEN, 91, 22, false)
	count = Grunge.text(card, { Text = "", Position = UDim2.fromScale(0.68, 0.8), Size = UDim2.fromScale(0.14, 0.18), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = GREEN, ZIndex = 11 })
	nextBtn = button(card, "NEXT", { Position = UDim2.fromScale(0.68, 0.79), Size = UDim2.fromScale(0.29, 0.19), Rotation = -1, Visible = false, ZIndex = 10 }, RED, 89)
	nextBtn.Activated:Connect(nextCard)
	doneStamp = Grunge.text(card, { Text = "DONE", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.86, 0.84), Size = UDim2.fromScale(0.24, 0.3), Rotation = -8, TextColor3 = GREEN,
		TextStrokeTransparency = 0, Visible = false, ZIndex = 14 })

	UIS.InputBegan:Connect(function(input: InputObject, typing: boolean)
		if typing or UIS:GetFocusedTextBox() then return end
		if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter or input.KeyCode == Enum.KeyCode.ButtonA then nextCard() end
	end)
	for _, a in { "Tutorial", "Sandbox", "TutorialStep", "TutorialProg", "TutorialDone", "TutorialSlot", "Carrying", "InMatch" } do
		lp:GetAttributeChangedSignal(a):Connect(refresh)
	end
	RS:GetAttributeChangedSignal("TutorialOn"):Connect(refresh)
	Platform.changed:Connect(refresh)
	Platform.windowChanged:Connect(refresh)
	Settings.changed:Connect(function(k) if k == "binds" then refresh() end end)
	refresh()

	-- the offer, once the player's save says it was never made (and the loading screen is gone)
	task.spawn(function()
		while lp:GetAttribute("TutorialSeen") == nil do lp:GetAttributeChangedSignal("TutorialSeen"):Wait() end
		if lp:GetAttribute("TutorialSeen") then return end
		while Loading.isShown() do task.wait(0.3) end
		task.wait(1.5)
		if not lp:GetAttribute("TutorialSeen") then offer() end
	end)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugTutorial"):Connect(function()
			if lp:GetAttribute("DebugTutorial") == "ask" then offer() end
		end)
	end
end

return UI
