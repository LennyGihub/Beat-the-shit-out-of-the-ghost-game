-- The SETTINGS window: sound and music volume (- / + buttons or tap the bar), keyboard keybinds
-- (click a key, then press the new one; ESC cancels), RESET, and the controller / touch controls.
-- Opened with the SETTINGS button (top right), the Settings key (P by default) or D-pad left on a controller.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Settings = require(script.Parent.Settings)
local Platform = require(script.Parent.Platform)

local UI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local openBtn: TextButton
local bindRows = {} :: { [string]: TextButton }
local sliders = {} :: { [string]: { fill: Frame, pct: TextLabel } }
local keysPage: Frame
local padText: TextLabel
local listening: string? = nil
local onToggle: ((boolean) -> ())? = nil
local DARK = Color3.fromRGB(45, 40, 36)
local RED = Color3.fromRGB(150, 20, 18)

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true; b.BorderSizePixel = 0; b.BackgroundColor3 = DARK
	b.Font = Grunge.FONT; b.TextScaled = true; b.TextColor3 = Grunge.PAPER; b.TextStrokeTransparency = 0.3; b.Text = text
	for k, v in props do (b :: any)[k] = v end
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.14, 0); pad.PaddingBottom = UDim.new(0.14, 0); pad.Parent = b
	b.Parent = parent
	return b
end

local function refreshSliders()
	for key, s in sliders do
		local v = Settings.get(key) :: number
		s.fill.Size = UDim2.fromScale(v, 1)
		s.pct.Text = math.floor(v * 100 + 0.5) .. "%"
	end
end

local function refreshBinds()
	for id, b in bindRows do
		b.Text = listening == id and "PRESS A KEY..." or Settings.keyName(id)
		b.BackgroundColor3 = listening == id and RED or DARK
	end
end

local function refreshPad()
	local m = Platform.mode()
	if m == "gamepad" then
		padText.Text = "CONTROLLER:  R2 hit  |  L2 lift / throw  |  Y ultimate  |  L3 sprint  |  L1 / R1 switch item  |  D-PAD DOWN drop  |  X interact  |  D-PAD LEFT settings  |  B back"
	elseif m == "touch" then
		padText.Text = "TOUCH:  HIT, LIFT, ULT, RUN and DROP buttons on the right  |  tap a hotbar slot to switch items  |  tap a prompt to use it"
	else
		padText.Text = "CONTROLLER:  R2 hit  |  L2 lift  |  Y ultimate  |  L3 sprint  |  L1 / R1 items  |  D-PAD DOWN drop  |  D-PAD LEFT settings"
	end
	keysPage.Visible = m ~= "touch" -- keybinds are for keyboards
end

function UI.isOpen(): boolean return gui ~= nil and gui.Enabled end

function UI.setOpen(open: boolean)
	if not gui or gui.Enabled == open then return end
	listening = nil
	gui.Enabled = open
	if open then
		refreshSliders(); refreshBinds(); refreshPad()
		local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		s.Parent = panel; s.Scale = 0.75
		TweenService:Create(s, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
	if onToggle then onToggle(open) end
end

function UI.toggle() UI.setOpen(not UI.isOpen()) end

local function slider(parent: Instance, key: string, label: string, y: number)
	Grunge.text(parent, { Text = label, Font = Grunge.TYPE, Position = UDim2.fromScale(0, y), Size = UDim2.fromScale(0.2, 0.07), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(220, 90, 60), ZIndex = 11 })
	local minus = button(parent, "-", { Position = UDim2.fromScale(0.22, y - 0.005), Size = UDim2.fromScale(0.08, 0.08), ZIndex = 12 })
	local track = Instance.new("TextButton")
	track.Text = ""; track.AutoButtonColor = false; track.BorderSizePixel = 0; track.BackgroundColor3 = Color3.fromRGB(24, 19, 16)
	track.Position = UDim2.fromScale(0.32, y + 0.01); track.Size = UDim2.fromScale(0.46, 0.05); track.ZIndex = 12; track.Selectable = false
	track.Parent = parent
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.Parent = track
	local fill = Grunge.frame(track, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(230, 96, 20), Size = UDim2.fromScale(1, 1), ZIndex = 13 })
	local plus = button(parent, "+", { Position = UDim2.fromScale(0.8, y - 0.005), Size = UDim2.fromScale(0.08, 0.08), ZIndex = 12 })
	local pct = Grunge.text(parent, { Text = "100%", Font = Grunge.TYPE, Position = UDim2.fromScale(0.9, y), Size = UDim2.fromScale(0.1, 0.07), ZIndex = 11 })
	sliders[key] = { fill = fill, pct = pct }
	minus.Activated:Connect(function() Settings.set(key, (Settings.get(key) :: number) - 0.1); Sfx.play("Click") end)
	plus.Activated:Connect(function() Settings.set(key, (Settings.get(key) :: number) + 0.1); Sfx.play("Click") end)
	-- click / tap / drag on the bar
	local dragging = false
	local function setFrom(x: number)
		local a = track.AbsolutePosition.X
		Settings.set(key, (x - a) / math.max(1, track.AbsoluteSize.X))
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFrom(input.Position.X)
		end
	end)
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFrom(input.Position.X) end
	end)
end

function UI.init(toggled: (boolean) -> ())
	onToggle = toggled
	gui = Instance.new("ScreenGui")
	gui.Name = "SettingsUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 50; gui.Enabled = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.56, 0.82) }, 47)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.25; ar.Parent = panel
	Grunge.frame(panel, { BackgroundTransparency = 0.04, BackgroundColor3 = Color3.fromRGB(20, 16, 14), Size = UDim2.fromScale(0.97, 0.95), Position = UDim2.fromScale(0.015, 0.025), ZIndex = 9 })
	Grunge.text(panel, { Text = "SETTINGS", Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.03), Size = UDim2.fromScale(0.4, 0.1), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 110, 60), ZIndex = 10 })
	-- Modal: frees the mouse in first person while the window is open
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.95, 0.045), Size = UDim2.fromScale(0.18, 0.07), ZIndex = 12, Modal = true })
	close.Activated:Connect(function() Sfx.play("Click"); UI.setOpen(false) end)

	local body = Grunge.frame(panel, { Position = UDim2.fromScale(0.06, 0.15), Size = UDim2.fromScale(0.88, 0.8), ZIndex = 10 })
	slider(body, "sfx", "SOUND", 0.0)
	slider(body, "music", "MUSIC", 0.1)

	keysPage = Grunge.frame(body, { Position = UDim2.fromScale(0, 0.21), Size = UDim2.fromScale(1, 0.62), ZIndex = 10 })
	Grunge.text(keysPage, { Text = "KEYBINDS  (click one, then press the new key)", Font = Grunge.TYPE, Size = UDim2.fromScale(1, 0.08), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(220, 90, 60), ZIndex = 11 })
	for i, a in Settings.ACTIONS do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		local x, y = col * 0.51, 0.11 + row * 0.172 -- five rows
		local lab = Grunge.text(keysPage, { Text = a.name, Font = Grunge.TYPE, Position = UDim2.fromScale(x, y + 0.01), Size = UDim2.fromScale(0.25, 0.115), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
		local cap = Instance.new("UITextSizeConstraint"); cap.MaxTextSize = 17; cap.Parent = lab -- same size for every label
		local b = button(keysPage, "", { Position = UDim2.fromScale(x + 0.26, y), Size = UDim2.fromScale(0.22, 0.135), ZIndex = 12, Font = Grunge.TYPE })
		bindRows[a.id] = b
		b.Activated:Connect(function()
			Sfx.play("Click")
			-- start listening on the next input (not the click that pressed this button)
			task.defer(function()
				listening = listening == a.id and nil or a.id
				refreshBinds()
			end)
		end)
	end
	local reset = button(body, "RESET ALL", { Position = UDim2.fromScale(0.72, 0.84), Size = UDim2.fromScale(0.28, 0.075), ZIndex = 12, BackgroundColor3 = Color3.fromRGB(80, 30, 26) })
	reset.Activated:Connect(function() Sfx.play("Click"); listening = nil; Settings.reset() end)
	padText = Grunge.text(body, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.84), Size = UDim2.fromScale(0.7, 0.15), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = Color3.fromRGB(170, 160, 145), ZIndex = 11 })

	-- the new key for the action being rebound
	UIS.InputBegan:Connect(function(input, processed)
		if not listening or not gui.Enabled then return end
		local t = input.UserInputType
		local name: string? = nil
		if t == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then listening = nil; refreshBinds(); return end
			name = input.KeyCode.Name
		elseif (t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3) and not processed then
			name = t.Name -- a click on the window's own buttons doesn't count
		end
		if name then
			local a = listening :: string
			listening = nil
			Settings.bind(a, name)
			Sfx.play("Click")
		end
	end)
	Settings.changed:Connect(function(k)
		if k == "binds" then refreshBinds() else refreshSliders() end
	end)
	Platform.changed:Connect(function() if gui.Enabled then refreshPad() end end)
	Platform.menu(panel, function() UI.setOpen(false) end)
	if game:GetService("RunService"):IsStudio() then -- Studio test hook: player attribute DebugSettings = true opens it
		lp:GetAttributeChangedSignal("DebugSettings"):Connect(function() UI.setOpen(lp:GetAttribute("DebugSettings") == true) end)
	end

	-- the SETTINGS button (top right, under the cash)
	local hud = Instance.new("ScreenGui")
	hud.Name = "SettingsButton"; hud.ResetOnSpawn = false; hud.IgnoreGuiInset = true; hud.DisplayOrder = 6
	hud.Parent = lp:WaitForChild("PlayerGui")
	openBtn = button(hud, "SETTINGS", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 74), Size = UDim2.fromOffset(150, 40), Rotation = -2, Font = Grunge.FONT })
	openBtn.Activated:Connect(function() Sfx.play("Click"); UI.toggle() end)
	local function label()
		local m = Platform.mode()
		openBtn.Text = m == "keyboard" and ("SETTINGS " .. Platform.label("Settings")) or (m == "gamepad" and "SETTINGS [D-PAD LEFT]" or "SETTINGS")
		openBtn.Size = UDim2.fromOffset(m == "touch" and 130 or 190, 40)
	end
	label()
	Platform.changed:Connect(label)
	Settings.changed:Connect(function(k) if k == "binds" then label() end end)
end

return UI
