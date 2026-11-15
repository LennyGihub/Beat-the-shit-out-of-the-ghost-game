-- Lobby ultimate shop (grunge): 50 ultimates by rarity, buy with cash, equip one.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ultimates = require(RS.Shared.Ultimates)
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
local rows = {} :: { [string]: { btn: TextButton, row: Frame } }
local filter = 0
local onToggle: ((boolean) -> ())? = nil

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true; b.BorderSizePixel = 0; b.BackgroundColor3 = Color3.fromRGB(120, 24, 20)
	b.Font = Grunge.FONT; b.Text = text; b.TextScaled = true; b.TextColor3 = Grunge.PAPER; b.TextStrokeTransparency = 0.3
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.14, 0); pad.PaddingBottom = UDim.new(0.14, 0); pad.Parent = b
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	return b
end

local function owned(): { [string]: boolean }
	local o = { Rage = true }
	for id in string.gmatch(lp:GetAttribute("OwnedUlts") or "", "[^,]+") do o[id] = true end
	return o
end

local function refresh()
	if not gui then return end
	cashText.Text = "$" .. tostring(lp:GetAttribute("Cash") or 0)
	local o = owned()
	local eq = lp:GetAttribute("EquippedUlt") or "Rage"
	for _, u in Ultimates.list do
		local r = rows[u.id]
		r.row.Visible = filter == 0 or u.rarity == filter
		if eq == u.id then
			r.btn.Text = "EQUIPPED"; r.btn.BackgroundColor3 = Color3.fromRGB(60, 110, 50)
		elseif o[u.id] then
			r.btn.Text = "EQUIP"; r.btn.BackgroundColor3 = Color3.fromRGB(50, 70, 110)
		else
			r.btn.Text = "$" .. u.price; r.btn.BackgroundColor3 = Color3.fromRGB(120, 24, 20)
		end
	end
end

function Shop.init(toggle: (boolean) -> ())
	onToggle = toggle
	gui = Instance.new("ScreenGui")
	gui.Name = "UltShop"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Enabled = false
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.7, 0.84), Rotation = 0 }, 21) -- no rotation: rotated frames stop the list from clipping
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.3; ar.Parent = panel
	Grunge.text(panel, { Text = "THE HOODED DEALER", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.02), Size = UDim2.fromScale(0.6, 0.08), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 110, 60), ZIndex = 10 })
	Grunge.text(panel, { Text = "\"Ultimates. Fill your brutality bar, press Q, make her regret dying.\"", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.1), Size = UDim2.fromScale(0.66, 0.035), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 10 })
	cashText = Grunge.text(panel, { Text = "$0", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.025), Size = UDim2.fromScale(0.24, 0.07), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 10, Rotation = 2 })
	-- rarity tabs
	local tabs = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.155), Size = UDim2.fromScale(0.92, 0.055), ZIndex = 10 })
	local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0.01, 0); tl.Parent = tabs
	local names = { "ALL" }
	for _, r in Items.rarity do table.insert(names, r.name) end
	for i, n in names do
		local col = i == 1 and Color3.fromRGB(60, 50, 44) or Items.rarity[i - 1].color:Lerp(Color3.new(0, 0, 0), 0.45)
		local b = button(tabs, n, { Size = UDim2.fromScale(1 / 6 - 0.01, 1), BackgroundColor3 = col, ZIndex = 11, LayoutOrder = i })
		b.MouseButton1Click:Connect(function() Sfx.play("Click"); filter = i - 1; refresh() end)
	end
	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.Position = UDim2.fromScale(0.04, 0.225); list.Size = UDim2.fromScale(0.92, 0.68)
	list.ScrollBarThickness = 8; list.ClipsDescendants = true; list.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(); list.ZIndex = 10; list.Parent = panel
	local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 6); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = list
	for i, u in Ultimates.list do
		local rar = Items.rarity[u.rarity]
		local row = Grunge.frame(list, { Size = UDim2.new(1, -12, 0, 64), BackgroundTransparency = 0.55, BackgroundColor3 = Color3.fromRGB(10, 8, 7), ZIndex = 10, LayoutOrder = i })
		Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = u.color, Size = UDim2.new(0, 8, 1, 0), ZIndex = 11 })
		Grunge.text(row, { Text = string.upper(u.name), Position = UDim2.new(0, 18, 0.04, 0), Size = UDim2.new(0.5, 0, 0.5, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
		Grunge.text(row, { Text = rar.name, Font = Grunge.TYPE, Position = UDim2.new(0.55, 0, 0.08, 0), Size = UDim2.new(0.2, 0, 0.36, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = rar.color, ZIndex = 11 })
		Grunge.text(row, { Text = u.desc, Font = Grunge.TYPE, Position = UDim2.new(0, 18, 0.56, 0), Size = UDim2.new(0.72, 0, 0.38, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 11 })
		local btn = button(row, "", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.2, 0, 0.7, 0), ZIndex = 12 })
		btn.MouseButton1Click:Connect(function()
			Sfx.play("Click")
			local o = owned()
			if o[u.id] then Remotes.EquipUlt:FireServer(u.id) else Remotes.BuyUlt:FireServer(u.id) end
		end)
		rows[u.id] = { btn = btn, row = row }
	end
	statusText = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.92), Size = UDim2.fromScale(0.92, 0.045), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10 })
	local close = button(panel, "LEAVE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.095), Size = UDim2.fromScale(0.2, 0.052), ZIndex = 12, Rotation = 1.5, BackgroundColor3 = Color3.fromRGB(45, 40, 36), Modal = true })
	close.MouseButton1Click:Connect(function() Sfx.play("Click"); Shop.close() end)
	for _, a in { "Cash", "OwnedUlts", "EquippedUlt" } do lp:GetAttributeChangedSignal(a):Connect(refresh) end
end

function Shop.open()
	refresh()
	gui.Enabled = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end

function Shop.close()
	gui.Enabled = false
	if onToggle then onToggle(false) end
end

function Shop.result(ok: boolean, msg: string)
	statusText.Text = string.upper(msg)
	statusText.TextColor3 = ok and Color3.fromRGB(150, 220, 110) or Color3.fromRGB(230, 70, 60)
	if ok then Sfx.play("Cash") end
	refresh()
end

return Shop
