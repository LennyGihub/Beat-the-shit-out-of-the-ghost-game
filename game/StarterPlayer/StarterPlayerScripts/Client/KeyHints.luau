--!strict
-- A small reminder of the fight controls on the left of the screen during a run: ATTACK, CHARGE ATTACK, BLOCK and
-- ULTIMATE, with the player's own keys (rebinds and controller buttons follow). H hides it (the CONTROLS PANEL
-- keybind; D-pad right on a controller) and shows it again; hidden, only a faint "[H] CONTROLS" tag is left. The
-- choice is saved with the settings. Phones don't get it: their buttons are already labelled on the screen.
-- Studio test hook: player attribute DebugKeyHints = true / false shows / hides it.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Settings = require(script.Parent.Settings)

local KeyHints = {}
local lp = Players.LocalPlayer
local HIDE_PAD = Enum.KeyCode.DPadRight
local KEY_COLOR = Color3.fromRGB(255, 196, 96)
local DIM = Color3.fromRGB(170, 160, 145)

-- what each row shows: the action, the keybind it follows, and whether the button is held
local ROWS = {
	{ name = "ATTACK", action = "Punch", pad = "R2", hold = false },
	{ name = "CHARGE ATTACK", action = "Punch", pad = "R2", hold = true },
	{ name = "BLOCK", action = "Block", pad = "B", hold = true },
	{ name = "ULTIMATE", action = "Ultimate", pad = "Y", hold = false },
	{ name = "FREE MOUSE", action = "Cursor", pad = nil, hold = false }, -- (Client/Cursor; not shown on a controller)
}

local panel: Frame
local tag: TextLabel
local hideLabel: TextLabel
local keys = {} :: { TextLabel }
local names = {} :: { TextLabel }

local function refresh()
	local mode = Platform.mode()
	local pad = mode == "gamepad"
	for i, r in ROWS do
		local k: string? = if pad then r.pad else Settings.keyName(r.action)
		keys[i].Text = k and ((r.hold and "HOLD " or "") .. k) or ""
		names[i].Visible = k ~= nil
		-- (FREE MOUSE says whether it is free now)
		if r.action == "Cursor" and k then names[i].Text = lp:GetAttribute("MouseFree") and "LOCK MOUSE" or "FREE MOUSE" end
	end
	local hideKey = pad and "D-PAD RIGHT" or Settings.keyName("Hints")
	hideLabel.Text = "[" .. hideKey .. "] HIDE"
	tag.Text = "[" .. hideKey .. "] CONTROLS"
	local show = lp:GetAttribute("InMatch") == true and not lp:GetAttribute("Spectating") and mode ~= "touch"
	local hidden = Settings.get("hideKeys") == true
	panel.Visible = show and not hidden
	tag.Visible = show and hidden
end

local function toggle()
	if not (panel.Visible or tag.Visible) then return end -- only during a run
	Settings.setFlag("hideKeys", not Settings.get("hideKeys"))
end

function KeyHints.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "KeyHints"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	panel = Grunge.frame(gui, {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 18, 0.6, 0), Size = UDim2.fromScale(0.2, 0.2),
		BackgroundTransparency = 0.35, BackgroundColor3 = Grunge.INK, Rotation = -1, Visible = false,
	})
	local lim = Instance.new("UISizeConstraint"); lim.MinSize = Vector2.new(250, 140); lim.MaxSize = Vector2.new(340, 190); lim.Parent = panel
	-- a rough red edge on the left, like the HUD's brush strokes
	Grunge.frame(panel, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(150, 18, 20), Size = UDim2.new(0, 4, 1, 0) })
	local head = Grunge.text(panel, { Text = "CONTROLS", Font = Grunge.HORROR, Position = UDim2.new(0, 14, 0.04, 0), Size = UDim2.new(0.5, -14, 0.22, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 110, 60) })
	local hc = Instance.new("UITextSizeConstraint"); hc.MaxTextSize = 22; hc.Parent = head
	hideLabel = Grunge.text(panel, { Text = "[H] HIDE", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0.07, 0), Size = UDim2.fromScale(0.42, 0.16),
		TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = DIM })
	local hl = Instance.new("UITextSizeConstraint"); hl.MaxTextSize = 13; hl.Parent = hideLabel
	for i, r in ROWS do
		local y = 0.25 + (i - 1) * 0.145
		local name = Grunge.text(panel, { Text = r.name, Font = Grunge.TYPE, Position = UDim2.new(0, 14, y, 0), Size = UDim2.new(0.46, -14, 0.13, 0),
			TextXAlignment = Enum.TextXAlignment.Left })
		local nc = Instance.new("UITextSizeConstraint"); nc.MaxTextSize = 15; nc.Parent = name
		names[i] = name
		local key = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, y, 0), Size = UDim2.fromScale(0.5, 0.13),
			TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = KEY_COLOR })
		local kc = Instance.new("UITextSizeConstraint"); kc.MaxTextSize = 15; kc.Parent = key
		keys[i] = key
	end
	tag = Grunge.text(gui, { Text = "[H] CONTROLS", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 18, 0.6, 0), Size = UDim2.fromOffset(150, 18),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = DIM, TextTransparency = 0.35, Visible = false })

	refresh()
	Settings.changed:Connect(function(k) if k == "binds" or k == "hideKeys" then refresh() end end)
	Platform.changed:Connect(refresh)
	lp:GetAttributeChangedSignal("InMatch"):Connect(refresh)
	lp:GetAttributeChangedSignal("Spectating"):Connect(refresh)
	lp:GetAttributeChangedSignal("MouseFree"):Connect(refresh)
	UIS.InputBegan:Connect(function(input, typing)
		if typing or UIS:GetFocusedTextBox() then return end
		local key = Settings.input("Hints")
		if input.KeyCode == HIDE_PAD or (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == key) or input.UserInputType == key then toggle() end
	end)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugKeyHints"):Connect(function()
			local v = lp:GetAttribute("DebugKeyHints")
			if type(v) == "boolean" then Settings.setFlag("hideKeys", not v) end
		end)
		lp:GetAttributeChangedSignal("DebugPlatform"):Connect(refresh)
	end
end

return KeyHints
