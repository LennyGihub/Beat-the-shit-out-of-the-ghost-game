--!strict
-- THE CODES WINDOW (the lobby's CODES button, Client/LobbyUI): type a code, REDEEM. Remotes.Codes ("redeem", text);
-- Server/Codes checks it and answers with Fx "CodeResult" (ok, message: shown here, green or red). A code that gives
-- a form also sends Fx "CodeReward": this window closes and the jar cinematic plays (ClientMain -> Client/FormCine).
-- Studio test hooks (player attributes): DebugCodes = true opens the window; DebugCode = "<text>" types it and
-- presses REDEEM (set it to something else first to send the same text again).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")
local CodesRemote = Remotes:WaitForChild("Codes") :: RemoteEvent

local UI = {}
local lp = Players.LocalPlayer
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local MUTED = Color3.fromRGB(190, 180, 160)
local CYAN = Color3.fromRGB(70, 235, 255)

local gui: ScreenGui
local panel: Frame
local box: TextBox
local status: TextLabel
local onToggle: ((boolean) -> ())? = nil
local seedN = 300
local sending = false

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	seedN += 1
	local z = props.ZIndex or 1
	local col = props.BackgroundColor3 or GREEN
	props.BackgroundColor3 = nil
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, col, seedN, 12)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.62),
		ZIndex = z + 3, Rotation = (seedN % 3 - 1) * 0.8 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.06 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	b.MouseButton1Down:Connect(function() sc.Scale = 0.94 end)
	b.MouseButton1Up:Connect(function() sc.Scale = 1 end)
	return b
end

local function say(text: string, color: Color3)
	status.Text = text
	status.TextColor3 = color
	local s = status:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = status; s.Scale = 1.25
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

local function redeem()
	if sending then return end
	local text = box.Text
	if string.gsub(text, "%s", "") == "" then say("TYPE A CODE FIRST", Color3.fromRGB(230, 90, 70)); return end
	sending = true
	say("CHECKING...", MUTED)
	CodesRemote:FireServer("redeem", text)
	task.delay(1.3, function() sending = false end)
end

function UI.close()
	if panel and panel.Visible then
		panel.Visible = false
		box:ReleaseFocus()
		if onToggle then onToggle(false) end
	end
end

function UI.open()
	if not panel or lp:GetAttribute("InMatch") then return end
	if panel.Visible then return end
	status.Text = ""
	panel.Visible = true
	panel:SetAttribute("OpenedAt", os.clock())
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end
function UI.isOpen(): boolean return panel ~= nil and panel.Visible end

-- the server's answer (Fx "CodeResult")
function UI.result(ok: boolean, msg: string)
	sending = false
	if not panel then return end
	if ok then
		say(msg, Color3.fromRGB(150, 230, 110))
		box.Text = ""
		Sfx.play("Cash", { PlaybackSpeed = 1.2, Volume = 0.7 })
	else
		say(msg, Color3.fromRGB(230, 90, 70))
		Sfx.play("Click", { PlaybackSpeed = 0.7 })
	end
end

function UI.init(toggled: ((boolean) -> ())?)
	onToggle = toggled
	gui = Instance.new("ScreenGui")
	gui.Name = "CodesUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.4, 0.46), Visible = false, ZIndex = 10 },
		Color3.fromRGB(21, 17, 15), 91, 5, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 1.5; par.Parent = panel
	Grunge.text(panel, { Text = "CODES", Font = Grunge.HORROR, Position = UDim2.fromScale(0.06, 0.04), Size = UDim2.fromScale(0.5, 0.15), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1, ZIndex = 12 })
	local tb = Grunge.bar(panel, { size = UDim2.fromScale(0.34, 0.035), pos = UDim2.fromScale(0.06, 0.19), color = Color3.fromRGB(160, 36, 120), rot = 0.5, seed = 92, slices = 24, outline = false })
	tb.root.ZIndex = 11
	Grunge.text(panel, { Text = "TYPE A CODE TO GET ITS REWARD. EVERY CODE WORKS ONCE.", Font = Grunge.TYPE, TextColor3 = MUTED, Position = UDim2.fromScale(0.06, 0.26),
		Size = UDim2.fromScale(0.88, 0.065), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.95, 0.05), Size = UDim2.fromScale(0.22, 0.12), BackgroundColor3 = DARK, ZIndex = 13, Rotation = 1.2 })
	close.Activated:Connect(function() Sfx.play("Click"); UI.close() end)
	Platform.menu(panel, UI.close)

	-- the code box
	local row = Grunge.frame(panel, { Position = UDim2.fromScale(0.06, 0.38), Size = UDim2.fromScale(0.88, 0.17), BackgroundTransparency = 0.15,
		BackgroundColor3 = Color3.fromRGB(10, 9, 8), ZIndex = 12 })
	local st = Instance.new("UIStroke"); st.Color = CYAN; st.Thickness = 2; st.Transparency = 0.45; st.Parent = row
	box = Instance.new("TextBox")
	box.BackgroundTransparency = 1; box.Size = UDim2.fromScale(0.94, 0.7); box.Position = UDim2.fromScale(0.03, 0.15); box.Text = ""
	box.PlaceholderText = "ENTER A CODE..."; box.Font = Grunge.FONT; box.TextScaled = true; box.TextColor3 = Grunge.PAPER
	box.PlaceholderColor3 = Color3.fromRGB(110, 100, 90); box.ClearTextOnFocus = false; box.TextXAlignment = Enum.TextXAlignment.Left; box.ZIndex = 13
	box.Parent = row
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if #box.Text > 40 then box.Text = string.sub(box.Text, 1, 40) end
	end)
	box.FocusLost:Connect(function(enter) if enter then redeem() end end)
	-- (tapping anywhere on the row types in the box)
	local tap = Instance.new("TextButton")
	tap.BackgroundTransparency = 1; tap.Text = ""; tap.Size = UDim2.fromScale(1, 1); tap.ZIndex = 12; tap.Selectable = false; tap.Parent = row
	tap.Activated:Connect(function() box:CaptureFocus() end)

	local go = button(panel, "REDEEM", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.6), Size = UDim2.fromScale(0.44, 0.15), BackgroundColor3 = GREEN, ZIndex = 13, Rotation = -0.8 })
	go.Activated:Connect(function() Sfx.play("Click"); redeem() end)
	status = Grunge.text(panel, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.06, 0.79), Size = UDim2.fromScale(0.88, 0.09), ZIndex = 12 })
	Grunge.text(panel, { Text = "NEW CODES COME WITH UPDATES", Font = Grunge.TYPE, TextColor3 = Color3.fromRGB(130, 120, 108), Position = UDim2.fromScale(0.06, 0.89),
		Size = UDim2.fromScale(0.88, 0.06), ZIndex = 12 })

	lp:GetAttributeChangedSignal("InMatch"):Connect(function() if lp:GetAttribute("InMatch") then UI.close() end end)

	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugCodes"):Connect(function()
			if lp:GetAttribute("DebugCodes") == true then UI.open() else UI.close() end
		end)
		lp:GetAttributeChangedSignal("DebugCode"):Connect(function()
			local v = lp:GetAttribute("DebugCode")
			if type(v) == "string" and v ~= "" then
				UI.open()
				box.Text = v
				sending = false
				redeem()
			end
		end)
	end
end

return UI
