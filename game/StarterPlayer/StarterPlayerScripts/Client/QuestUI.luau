--!strict
-- Lobby QUESTS panel (grunge, like the shop): DAILY (3 a day, new ones at midnight UTC) and ACHIEVEMENTS tabs,
-- each quest with a progress bar and a CLAIM button. Progress comes from the server (player attribute "Quests",
-- JSON, Server/Quests); CLAIM sends Remotes.Quest("claim", id). QuestUI.claimable() = how many are ready.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Q = require(RS.Shared.Quests)
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local QuestUI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local resetText: TextLabel
local tab = "daily"
local onToggle: ((boolean) -> ())? = nil
local registered = false
local changed = Instance.new("BindableEvent")
QuestUI.changed = changed.Event -- fires when the number of claimable quests may have changed

type Row = { row: Frame, fill: Frame, count: TextLabel, btn: TextButton, name: TextLabel, text: TextLabel, reward: TextLabel }
local dailyRows = {} :: { Row }
local achRows = {} :: { [string]: Row }

local GREEN = Color3.fromRGB(60, 120, 50)
local RED = Color3.fromRGB(120, 24, 20)
local GREY = Color3.fromRGB(60, 54, 48)

local function data(): any
	local raw = lp:GetAttribute("Quests")
	if type(raw) ~= "string" then return nil end
	local ok, d = pcall(function() return HttpService:JSONDecode(raw) end)
	return ok and d or nil
end

function QuestUI.claimable(): number
	local d = data()
	if not d then return 0 end
	local n = 0
	for _, list in { d.daily or {}, d.ach or {} } do
		for _, e in list do
			local quest = Q.byId[e.id]
			if quest and not e.c and e.p >= quest.goal then n += 1 end
		end
	end
	return n
end

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true; b.BorderSizePixel = 0; b.BackgroundColor3 = RED
	b.Font = Grunge.FONT; b.Text = text; b.TextScaled = true; b.TextColor3 = Grunge.PAPER; b.TextStrokeTransparency = 0.3
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.14, 0); pad.PaddingBottom = UDim.new(0.14, 0); pad.Parent = b
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	return b
end

-- one quest row: name, what to do, progress bar with "3 / 5", reward, CLAIM button
local function makeRow(list: Instance, order: number): Row
	local row = Grunge.frame(list, { Size = UDim2.new(1, -12, 0, 78), BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(10, 8, 7), ZIndex = 10, LayoutOrder = order })
	Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 110, 60), Size = UDim2.new(0, 8, 1, 0), ZIndex = 11 })
	local name = Grunge.text(row, { Text = "", Font = Grunge.HORROR, Position = UDim2.new(0, 18, 0.04, 0), Size = UDim2.new(0.45, 0, 0.36, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 200, 120), ZIndex = 11 })
	local reward = Grunge.text(row, { Text = "", Position = UDim2.new(0.5, 0, 0.06, 0), Size = UDim2.new(0.22, 0, 0.32, 0), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 11 })
	local text = Grunge.text(row, { Text = "", Font = Grunge.TYPE, Position = UDim2.new(0, 18, 0.42, 0), Size = UDim2.new(0.7, 0, 0.24, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 190, 170), ZIndex = 11 })
	local barBack = Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(28, 22, 19), Position = UDim2.new(0, 18, 0.72, 0), Size = UDim2.new(0.55, 0, 0.17, 0), ZIndex = 11 })
	local bs = Instance.new("UIStroke"); bs.Color = Grunge.INK; bs.Thickness = 2; bs.Parent = barBack
	local fill = Grunge.frame(barBack, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(230, 96, 20), Size = UDim2.fromScale(0, 1), ZIndex = 12 })
	local count = Grunge.text(row, { Text = "", Font = Grunge.TYPE, Position = UDim2.new(0.57, 8, 0.68, 0), Size = UDim2.new(0.16, 0, 0.26, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Grunge.PAPER, ZIndex = 11 })
	local btn = button(row, "", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.22, 0, 0.6, 0), ZIndex = 12 })
	return { row = row, fill = fill, count = count, btn = btn, name = name, text = text, reward = reward }
end

local function fillRow(r: Row, quest: Q.Quest, p: number, claimed: boolean)
	r.name.Text = quest.name
	r.text.Text = quest.text
	r.reward.Text = "$" .. quest.reward
	local f = math.clamp(p / quest.goal, 0, 1)
	r.fill.Size = UDim2.fromScale(f, 1)
	r.fill.BackgroundColor3 = f >= 1 and Color3.fromRGB(110, 200, 80) or Color3.fromRGB(230, 96, 20)
	r.count.Text = math.min(p, quest.goal) .. " / " .. quest.goal
	if claimed then
		r.btn.Text = "DONE"; r.btn.BackgroundColor3 = GREY; r.btn.AutoButtonColor = false
	elseif p >= quest.goal then
		r.btn.Text = "CLAIM"; r.btn.BackgroundColor3 = GREEN; r.btn.AutoButtonColor = true
	else
		r.btn.Text = math.floor(f * 100) .. "%"; r.btn.BackgroundColor3 = GREY; r.btn.AutoButtonColor = false
	end
	r.btn:SetAttribute("QuestId", quest.id)
	r.btn:SetAttribute("Ready", p >= quest.goal and not claimed)
end

local function refresh()
	if not gui then return end
	local d = data()
	if d then
		for i, e in d.daily or {} do
			local r, quest = dailyRows[i], Q.byId[e.id]
			if r and quest then fillRow(r, quest, e.p, e.c) end
		end
		for _, e in d.ach or {} do
			local r, quest = achRows[e.id], Q.byId[e.id]
			if r and quest then fillRow(r, quest, e.p, e.c) end
		end
		local left = math.max(0, (tonumber(d.reset) or 0) - os.time())
		resetText.Text = string.format("NEW DAILY QUESTS IN %dH %02dM", left // 3600, (left % 3600) // 60)
	end
	for _, r in dailyRows do r.row.Visible = tab == "daily" end
	for _, r in achRows do r.row.Visible = tab == "ach" end
	resetText.Visible = tab == "daily"
	changed:Fire()
end

function QuestUI.init(toggle: (boolean) -> ())
	onToggle = toggle
	gui = Instance.new("ScreenGui")
	gui.Name = "QuestUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Enabled = false; gui.DisplayOrder = 7
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.62, 0.8), Rotation = 0 }, 45)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.3; ar.Parent = panel
	Grunge.text(panel, { Text = "QUESTS", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.02), Size = UDim2.fromScale(0.5, 0.09), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 110, 60), ZIndex = 10 })
	resetText = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.105), Size = UDim2.fromScale(0.6, 0.035), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 10 })
	local close = button(panel, "LEAVE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.035), Size = UDim2.fromScale(0.2, 0.06), ZIndex = 12, Rotation = 1.5, BackgroundColor3 = Color3.fromRGB(45, 40, 36), Modal = true })
	close.MouseButton1Click:Connect(function() Sfx.play("Click"); QuestUI.close() end)
	local tabs = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.155), Size = UDim2.fromScale(0.92, 0.06), ZIndex = 10 })
	local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0.01, 0); tl.Parent = tabs
	for i, t in { { "DAILY", "daily", Color3.fromRGB(110, 30, 24) }, { "ACHIEVEMENTS", "ach", Color3.fromRGB(40, 70, 90) } } do
		local b = button(tabs, t[1], { Size = UDim2.fromScale(0.5 - 0.005, 1), BackgroundColor3 = t[3], ZIndex = 11, LayoutOrder = i })
		b.MouseButton1Click:Connect(function() Sfx.play("Click"); tab = t[2]; refresh() end)
	end
	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.Position = UDim2.fromScale(0.04, 0.235); list.Size = UDim2.fromScale(0.92, 0.72)
	list.ScrollBarThickness = 8; list.ClipsDescendants = true; list.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(); list.ZIndex = 10; list.Parent = panel
	local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 6); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = list
	local function hook(r: Row)
		r.btn.MouseButton1Click:Connect(function()
			if r.btn:GetAttribute("Ready") then
				Sfx.play("Cash")
				Remotes.Quest:FireServer("claim", r.btn:GetAttribute("QuestId"))
			end
		end)
	end
	for i = 1, Q.dailyCount do
		local r = makeRow(list, i)
		hook(r)
		table.insert(dailyRows, r)
	end
	for i, quest in Q.achievements do
		local r = makeRow(list, 100 + i)
		hook(r)
		achRows[quest.id] = r
	end
	lp:GetAttributeChangedSignal("Quests"):Connect(refresh)
	refresh()
	-- the reset countdown ticks while the panel is open
	task.spawn(function()
		while true do
			task.wait(30)
			if gui.Enabled then refresh() end
		end
	end)
	-- Studio test hook: player attribute QuestTab = "daily" | "ach" opens the panel on that tab
	if game:GetService("RunService"):IsStudio() then
		lp:GetAttributeChangedSignal("QuestTab"):Connect(function()
			local t = lp:GetAttribute("QuestTab")
			if t == "daily" or t == "ach" then tab = t; QuestUI.open() end
		end)
	end
end

function QuestUI.open()
	if not registered then registered = true; Platform.menu(panel, QuestUI.close) end
	refresh()
	gui.Enabled = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end

function QuestUI.close()
	gui.Enabled = false
	if onToggle then onToggle(false) end
end

function QuestUI.isOpen(): boolean return gui ~= nil and gui.Enabled end

return QuestUI
