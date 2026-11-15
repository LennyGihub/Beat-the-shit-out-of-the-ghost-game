-- Custom grunge look for every ProximityPrompt with Style = Custom (replaces Roblox's default bubble).
local Players = game:GetService("Players")
local PPS = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)

local Prompts = {}
local lp = Players.LocalPlayer
local KEYNAMES = { [Enum.KeyCode.ButtonX] = "X", [Enum.KeyCode.ButtonY] = "Y", [Enum.KeyCode.ButtonA] = "A", [Enum.KeyCode.ButtonB] = "B" }

local function build(prompt: ProximityPrompt, inputType: Enum.ProximityPromptInputType): (BillboardGui, { RBXScriptConnection })
	local conns = {}
	local gui = Instance.new("BillboardGui")
	gui.Name = "GrungePrompt"
	gui.AlwaysOnTop = true
	gui.Size = UDim2.fromOffset(300, 74)
	gui.SizeOffset = Vector2.new(0, 0.9)
	gui.Adornee = prompt.Parent :: any
	gui.Active = true
	-- like Roblox's custom-prompt sample: billboards live in a ScreenGui container in PlayerGui
	local holder = lp:WaitForChild("PlayerGui"):FindFirstChild("PromptHolder")
	if not holder then
		holder = Instance.new("ScreenGui")
		holder.Name = "PromptHolder"; holder.ResetOnSpawn = false
		holder.Parent = lp:WaitForChild("PlayerGui")
	end
	gui.Parent = holder

	local root = Instance.new("TextButton")
	root.Text = ""; root.AutoButtonColor = false; root.BackgroundTransparency = 1; root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui
	-- torn paper backing
	local back = Grunge.frame(root, { BackgroundTransparency = 0.12, BackgroundColor3 = Color3.fromRGB(26, 20, 17), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 34, 0.5, 0), Size = UDim2.new(1, -36, 0.78, 0), Rotation = -1.2 })
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.Parent = back
	Grunge.splat(back, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.75, 0.5), Size = UDim2.fromScale(0.7, 1.8), ImageColor3 = Color3.fromRGB(110, 12, 12), ImageTransparency = 0.6, Rotation = 20 })
	-- hand-drawn key cap
	local key = Grunge.frame(root, { BackgroundTransparency = 0, BackgroundColor3 = Grunge.PAPER, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 36, 0.5, 0), Size = UDim2.fromOffset(56, 56), Rotation = 5, ZIndex = 3 })
	local ks = Instance.new("UIStroke"); ks.Color = Grunge.INK; ks.Thickness = 4; ks.Parent = key
	local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(0, 6); kc.Parent = key
	local keyText = Grunge.text(key, { Size = UDim2.fromScale(0.9, 0.9), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), TextColor3 = Grunge.INK, TextStrokeTransparency = 1, ZIndex = 4 })
	if inputType == Enum.ProximityPromptInputType.Touch then
		keyText.Text = "TAP"
	elseif inputType == Enum.ProximityPromptInputType.Gamepad then
		keyText.Text = KEYNAMES[prompt.GamepadKeyCode] or prompt.GamepadKeyCode.Name
	else
		keyText.Text = UIS:GetStringForKeyCode(prompt.KeyboardKeyCode)
		if keyText.Text == "" then keyText.Text = prompt.KeyboardKeyCode.Name end
	end
	-- hold progress: a red brush stroke filling under the texts
	local bar = Grunge.frame(back, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(170, 25, 20), Position = UDim2.new(0, 40, 1, -9), Size = UDim2.new(0, 0, 0, 6), ZIndex = 2 })
	Grunge.text(back, { Text = string.upper(prompt.ActionText), Position = UDim2.new(0, 42, 0.06, 0), Size = UDim2.new(1, -48, 0.55, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3 })
	Grunge.text(back, { Text = prompt.ObjectText, Font = Grunge.TYPE, Position = UDim2.new(0, 42, 0.58, 0), Size = UDim2.new(1, -48, 0.32, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(195, 185, 165), ZIndex = 3 })
	-- pop in
	local sc = Instance.new("UIScale"); sc.Scale = 0.6; sc.Parent = root
	TweenService:Create(sc, TweenInfo.new(0.16, Enum.EasingStyle.Back), { Scale = 1 }):Play()

	local holdTween: Tween? = nil
	table.insert(conns, prompt.PromptButtonHoldBegan:Connect(function()
		if prompt.HoldDuration > 0 then
			bar.Size = UDim2.new(0, 0, 0, 6)
			holdTween = TweenService:Create(bar, TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear), { Size = UDim2.new(1, -50, 0, 6) })
			holdTween:Play()
		end
		TweenService:Create(key, TweenInfo.new(0.08), { Rotation = -4 }):Play()
	end))
	table.insert(conns, prompt.PromptButtonHoldEnded:Connect(function()
		if holdTween then holdTween:Cancel() end
		bar.Size = UDim2.new(0, 0, 0, 6)
		TweenService:Create(key, TweenInfo.new(0.08), { Rotation = 5 }):Play()
	end))
	table.insert(conns, prompt.Triggered:Connect(function()
		Sfx.play("Click")
		sc.Scale = 1.15
		TweenService:Create(sc, TweenInfo.new(0.15), { Scale = 1 }):Play()
	end))
	root.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then prompt:InputHoldBegin() end
	end)
	root.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then prompt:InputHoldEnd() end
	end)
	return gui, conns
end

function Prompts.init()
	PPS.PromptShown:Connect(function(prompt, inputType)
		if prompt.Style ~= Enum.ProximityPromptStyle.Custom then return end
		local gui, conns = build(prompt, inputType)
		prompt.PromptHidden:Wait()
		for _, c in conns do c:Disconnect() end
		gui:Destroy()
	end)
end

return Prompts
