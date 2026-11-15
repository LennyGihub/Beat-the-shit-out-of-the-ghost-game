-- The crashed pilot's shop (grunge panel). Buy items with ghost cash, then fight the next ghost.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Items = require(RS.Shared.Items)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local Shop = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local cashText: TextLabel
local statusText: TextLabel
local rows = {} :: { [string]: { btn: TextButton, price: TextLabel } }
local onToggle: ((boolean) -> ())? = nil

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.BackgroundColor3 = Color3.fromRGB(120, 24, 20)
	b.Font = Grunge.FONT
	b.Text = text
	b.TextScaled = true
	b.TextColor3 = Grunge.PAPER
	b.TextStrokeTransparency = 0.3
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.15, 0); pad.PaddingBottom = UDim.new(0.15, 0); pad.Parent = b
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	return b
end

local function refresh()
	if not gui then return end
	cashText.Text = "$" .. tostring(lp:GetAttribute("Cash") or 0)
	local owned = {}
	for id in string.gmatch(lp:GetAttribute("Owned") or "", "[^,]+") do owned[id] = true end
	for id, r in rows do
		if owned[id] then
			r.btn.Text = "OWNED"; r.btn.BackgroundColor3 = Color3.fromRGB(50, 60, 40); r.btn.Active = false
		else
			r.btn.Text = "BUY"; r.btn.BackgroundColor3 = Color3.fromRGB(120, 24, 20); r.btn.Active = true
		end
	end
end

function Shop.init(toggle: (boolean) -> ())
	onToggle = toggle
	gui = Instance.new("ScreenGui")
	gui.Name = "PilotShop"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.62, 0.78), Rotation = -0.6 }, 9)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.25; ar.Parent = panel
	Grunge.text(panel, { Text = "THE PILOT'S BLACK MARKET", Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.03), Size = UDim2.fromScale(0.7, 0.1), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10, TextColor3 = Color3.fromRGB(220, 60, 50) })
	cashText = Grunge.text(panel, { Text = "$0", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.95, 0.04), Size = UDim2.fromScale(0.24, 0.08), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 10, Rotation = 3 })
	Grunge.text(panel, { Text = "\"Survived a plane crash, kid. Ghosts don't scare me. Cash does.\"", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.13), Size = UDim2.fromScale(0.9, 0.045), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10, TextColor3 = Color3.fromRGB(190, 180, 160) })
	local list = Grunge.frame(panel, { Position = UDim2.fromScale(0.05, 0.2), Size = UDim2.fromScale(0.9, 0.58), ZIndex = 10 })
	local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0.015, 0); layout.Parent = list
	for i, it in Items.list do
		local row = Grunge.frame(list, { Size = UDim2.fromScale(1, 1 / #Items.list - 0.015), BackgroundTransparency = 0.6, BackgroundColor3 = Color3.fromRGB(10, 8, 7), ZIndex = 10, LayoutOrder = i, Rotation = (i % 2 == 0) and 0.4 or -0.4 })
		Grunge.text(row, { Text = string.upper(it.name), Position = UDim2.fromScale(0.02, 0.05), Size = UDim2.fromScale(0.5, 0.55), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
		Grunge.text(row, { Text = it.desc, Font = Grunge.TYPE, Position = UDim2.fromScale(0.02, 0.58), Size = UDim2.fromScale(0.55, 0.36), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 11 })
		local price = Grunge.text(row, { Text = "$" .. it.price, Position = UDim2.fromScale(0.6, 0.15), Size = UDim2.fromScale(0.16, 0.7), TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 11 })
		local btn = button(row, "BUY", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.98, 0.5), Size = UDim2.fromScale(0.18, 0.72), ZIndex = 12, Rotation = -2 })
		btn.MouseButton1Click:Connect(function()
			Sfx.play("Click")
			Remotes.Buy:FireServer(it.id)
		end)
		rows[it.id] = { btn = btn, price = price }
	end
	statusText = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.79), Size = UDim2.fromScale(0.9, 0.045), ZIndex = 10 })
	local fight = button(panel, "FIGHT THE NEXT GHOST", { Position = UDim2.fromScale(0.05, 0.86), Size = UDim2.fromScale(0.58, 0.1), ZIndex = 12, Rotation = -1, BackgroundColor3 = Color3.fromRGB(150, 20, 18), Modal = true })
	fight.MouseButton1Click:Connect(function()
		Sfx.play("Click")
		Shop.close()
		Remotes.NextGhost:FireServer()
	end)
	local close = button(panel, "LEAVE", { Position = UDim2.fromScale(0.67, 0.86), Size = UDim2.fromScale(0.28, 0.1), ZIndex = 12, Rotation = 1.5, BackgroundColor3 = Color3.fromRGB(45, 40, 36) })
	close.MouseButton1Click:Connect(function() Sfx.play("Click"); Shop.close() end)
	lp:GetAttributeChangedSignal("Cash"):Connect(refresh)
	lp:GetAttributeChangedSignal("Owned"):Connect(refresh)
end

function Shop.open()
	refresh()
	gui.Enabled = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel
	s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end

function Shop.close()
	gui.Enabled = false
	if onToggle then onToggle(false) end
end

function Shop.result(ok: boolean, msg: string)
	statusText.Text = ok and ("BOUGHT: " .. string.upper(msg)) or string.upper(msg)
	statusText.TextColor3 = ok and Color3.fromRGB(150, 220, 110) or Color3.fromRGB(230, 70, 60)
	if ok then Sfx.play("Cash") end
	refresh()
end

return Shop
