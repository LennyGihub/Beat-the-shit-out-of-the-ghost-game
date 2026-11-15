--!strict
-- Admin panel (client): only built for players the server marked IsAdmin. F2 or the ADMIN button opens it.
-- Tabs: PLAYER (cash, heal, god...), ITEMS (give any of the 50 items), ULTS (equip any ultimate),
-- RUN (start a run on any map/difficulty, force a monster, spawn events, skip/kill ghosts).
-- Every button just sends a text command to Remotes.Admin; the command line at the bottom takes the same text.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Items = require(RS.Shared.Items)
local Ultimates = require(RS.Shared.Ultimates)
local Monsters = require(RS.Shared.Monsters)
local Maps = require(RS.Shared.Maps)

local AP = {}
local lp = Players.LocalPlayer
local FONT = Enum.Font.PermanentMarker
local TYPE = Enum.Font.SpecialElite
local INK = Color3.fromRGB(16, 12, 10)
local PAPER = Color3.fromRGB(232, 222, 200)
local BLOOD = Color3.fromRGB(170, 24, 20)
local DARK = Color3.fromRGB(30, 25, 22)
local MID = Color3.fromRGB(58, 48, 42)

local gui: ScreenGui
local panel: Frame
local logLabel: TextLabel
local godBtn: TextButton
local pages = {} :: { [string]: Frame }
local tabs = {} :: { [string]: TextButton }
local onToggle: ((open: boolean) -> ())? = nil
local pickMap, pickDiff = Maps.default, Maps.defaultDiff
local mapBtns = {} :: { [string]: TextButton }
local diffBtns = {} :: { [string]: TextButton }

local function N(class: string, props: { [string]: any }, parent: Instance?): any
	local o = Instance.new(class)
	for k, v in props do (o :: any)[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function corner(p: Instance, r: number) N("UICorner", { CornerRadius = UDim.new(0, r) }, p) end
local function stroke(p: Instance, t: number, c: Color3) N("UIStroke", { Thickness = t, Color = c, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function label(p: Instance, text: string, props: { [string]: any }?): TextLabel
	local l = N("TextLabel", { BackgroundTransparency = 1, Text = text, Font = FONT, TextScaled = true, TextColor3 = PAPER,
		TextStrokeColor3 = INK, TextStrokeTransparency = 0.3, Size = UDim2.fromScale(1, 1) }, p)
	if props then for k, v in props do (l :: any)[k] = v end end
	return l
end

local function log(ok: boolean, msg: string)
	logLabel.Text = msg
	logLabel.TextColor3 = ok and Color3.fromRGB(150, 220, 110) or Color3.fromRGB(255, 110, 90)
end

local rf: RemoteFunction? = nil
local function cmd(line: string)
	if not rf then rf = RS:WaitForChild("Remotes"):WaitForChild("Admin", 5) :: RemoteFunction? end
	if not rf then log(false, "Admin remote missing"); return end
	local ok, a, b = pcall(function() return (rf :: RemoteFunction):InvokeServer(line) end)
	if not ok then log(false, tostring(a)); return end
	log(a == true, tostring(b))
end

-- chunky button: dark slab, coloured left stripe, marker text
local function button(parent: Instance, text: string, color: Color3, onClick: () -> (), props: { [string]: any }?): TextButton
	local b = N("TextButton", { Text = "", AutoButtonColor = false, BackgroundColor3 = DARK, BorderSizePixel = 0 }, parent)
	if props then for k, v in props do (b :: any)[k] = v end end
	corner(b, 4)
	stroke(b, 2, Color3.fromRGB(8, 6, 5))
	N("Frame", { Name = "Stripe", BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.new(0, 5, 1, 0) }, b)
	label(b, text, { Name = "Label", Size = UDim2.new(1, -16, 0.7, 0), Position = UDim2.new(0, 11, 0.15, 0), TextXAlignment = Enum.TextXAlignment.Left })
	b.MouseEnter:Connect(function() b.BackgroundColor3 = MID end)
	b.MouseLeave:Connect(function() b.BackgroundColor3 = DARK end)
	b.Activated:Connect(onClick)
	return b
end

-- scrolling grid whose cells keep `cols` per row whatever the screen size
local function grid(parent: Instance, cols: number, ratio: number, props: { [string]: any }): ScrollingFrame
	local s = N("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 6, ScrollBarImageColor3 = BLOOD,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y }, parent)
	for k, v in props do (s :: any)[k] = v end
	local g = N("UIGridLayout", { CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder }, s)
	local function fit()
		local w = (s.AbsoluteSize.X - 10 - 6 * (cols - 1)) / cols
		g.CellSize = UDim2.fromOffset(math.max(20, w), math.max(16, w / ratio))
	end
	s:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
	return s
end

local function heading(parent: Instance, text: string, y: number)
	label(parent, text, { Size = UDim2.fromScale(1, 0.06), Position = UDim2.fromScale(0, y), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(220, 70, 50) })
end

local function rarityColor(list: { any }, r: number): Color3
	local x = list[r]
	return x and x.color or PAPER
end

local function showPage(name: string)
	for n, p in pages do p.Visible = n == name end
	for n, t in tabs do
		t.BackgroundColor3 = n == name and BLOOD or DARK
	end
end

local function setOpen(open: boolean)
	panel.Visible = open
	if onToggle then onToggle(open) end
end

local function refreshPicks()
	for id, b in mapBtns do (b:FindFirstChild("Stripe") :: Frame).Size = UDim2.new(0, id == pickMap and 14 or 5, 1, 0) end
	for id, b in diffBtns do (b:FindFirstChild("Stripe") :: Frame).Size = UDim2.new(0, id == pickDiff and 14 or 5, 1, 0) end
end

local function build()
	gui = N("ScreenGui", { Name = "AdminPanel", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 50, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, lp:WaitForChild("PlayerGui"))

	local toggle = button(gui, "ADMIN", BLOOD, function() setOpen(not panel.Visible) end,
		{ Name = "Toggle", Size = UDim2.fromOffset(96, 34), Position = UDim2.new(0, 12, 0, 70) })
	toggle.ZIndex = 2

	panel = N("Frame", { Name = "Panel", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.62, 0.74),
		BackgroundColor3 = Color3.fromRGB(14, 11, 9), BackgroundTransparency = 0.06, BorderSizePixel = 0, Visible = false }, gui)
	corner(panel, 6)
	stroke(panel, 3, BLOOD)
	N("UIAspectRatioConstraint", { AspectRatio = 1.55 }, panel)
	N("UIPadding", { PaddingLeft = UDim.new(0.02, 0), PaddingRight = UDim.new(0.02, 0), PaddingTop = UDim.new(0.02, 0), PaddingBottom = UDim.new(0.02, 0) }, panel)
	-- a modal button frees the mouse while the panel is open (first-person locks it)
	N("TextButton", { Name = "Modal", Modal = true, Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(0, 0) }, panel)

	label(panel, "ADMIN PANEL", { Size = UDim2.fromScale(0.4, 0.08), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(230, 60, 40), Rotation = -1.5 })
	button(panel, "X", BLOOD, function() setOpen(false) end, { Size = UDim2.fromScale(0.06, 0.08), Position = UDim2.fromScale(0.94, 0) })

	local tabBar = N("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(0.5, 0.07), Position = UDim2.fromScale(0.43, 0.005) }, panel)
	N("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0.02, 0) }, tabBar)
	for _, name in { "PLAYER", "ITEMS", "ULTS", "RUN" } do
		tabs[name] = button(tabBar, name, PAPER, function() showPage(name) end, { Size = UDim2.fromScale(0.235, 1) })
		pages[name] = N("Frame", { Name = name, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.76), Position = UDim2.fromScale(0, 0.1), Visible = false }, panel)
	end

	-- PLAYER -------------------------------------------------------------------------------------
	do
		local g = grid(pages.PLAYER, 3, 4.2, { Size = UDim2.fromScale(1, 1) })
		local G = Color3.fromRGB(110, 190, 80)
		local Y = Color3.fromRGB(220, 180, 60)
		local R = Color3.fromRGB(200, 60, 40)
		local B = Color3.fromRGB(90, 150, 230)
		button(g, "+1K CASH", G, function() cmd("cash 1k") end)
		button(g, "+10K CASH", G, function() cmd("cash 10k") end)
		button(g, "+100K CASH", G, function() cmd("cash 100k") end)
		button(g, "+500 RUN CASH", Y, function() cmd("runcash 500") end)
		button(g, "+5K RUN CASH", Y, function() cmd("runcash 5k") end)
		button(g, "+50K RUN CASH", Y, function() cmd("runcash 50k") end)
		button(g, "HEAL + STAMINA", G, function() cmd("heal") end)
		button(g, "FULL BRUTALITY", Color3.fromRGB(230, 96, 20), function() cmd("brut") end)
		godBtn = button(g, "GOD MODE: OFF", R, function() cmd("god") end)
		button(g, "UNLOCK ALL ULTS", B, function() cmd("allults") end)
		button(g, "UNLOCK ALL MAPS", B, function() cmd("allmaps") end)
		button(g, "CLEAR HOTBAR", R, function() cmd("clearitems") end)
		button(g, "LEAVE RUN", R, function() cmd("leave") end)
		local function god()
			(godBtn:FindFirstChild("Label") :: TextLabel).Text = lp:GetAttribute("AdminGod") and "GOD MODE: ON" or "GOD MODE: OFF"
		end
		lp:GetAttributeChangedSignal("AdminGod"):Connect(god)
	end

	-- ITEMS / ULTS: searchable grids ---------------------------------------------------------------
	local function listPage(page: Frame, list: { any }, rar: { any }, verb: string, sub: (x: any) -> string)
		local search = N("TextBox", { PlaceholderText = "search...", Text = "", ClearTextOnFocus = false, Font = TYPE, TextScaled = true,
			TextColor3 = PAPER, PlaceholderColor3 = Color3.fromRGB(130, 120, 105), BackgroundColor3 = DARK, BorderSizePixel = 0,
			Size = UDim2.fromScale(0.4, 0.08), TextXAlignment = Enum.TextXAlignment.Left }, page)
		corner(search, 4)
		N("UIPadding", { PaddingLeft = UDim.new(0, 8) }, search)
		label(page, "click = " .. verb, { Font = TYPE, Size = UDim2.fromScale(0.5, 0.06), Position = UDim2.fromScale(0.45, 0.01), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(160, 150, 130) })
		local g = grid(page, 4, 2.9, { Size = UDim2.fromScale(1, 0.89), Position = UDim2.fromScale(0, 0.11) })
		local tiles = {} :: { { x: any, b: TextButton } }
		for i, x in list do
			local b = button(g, string.upper(x.name), rarityColor(rar, x.rarity), function() cmd(verb .. " " .. x.id) end, { LayoutOrder = i })
			local l = b:FindFirstChild("Label") :: TextLabel
			l.Size = UDim2.new(1, -16, 0.5, 0); l.Position = UDim2.new(0, 11, 0.08, 0)
			label(b, sub(x), { Font = TYPE, Size = UDim2.new(1, -16, 0.3, 0), Position = UDim2.new(0, 11, 0.6, 0), TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = rarityColor(rar, x.rarity), TextStrokeTransparency = 1 })
			table.insert(tiles, { x = x, b = b })
		end
		search:GetPropertyChangedSignal("Text"):Connect(function()
			local q = string.lower(search.Text)
			for _, t in tiles do
				t.b.Visible = q == "" or string.find(string.lower(t.x.name), q, 1, true) ~= nil or string.find(string.lower(t.x.id), q, 1, true) ~= nil
			end
		end)
	end
	listPage(pages.ITEMS, Items.list, Items.rarity, "give", function(it) return string.upper(it.kind) .. "  -  " .. Items.rarity[it.rarity].name end)
	local ultRar = { { name = "COMMON", color = Color3.fromRGB(200, 196, 186) }, { name = "RARE", color = Color3.fromRGB(80, 150, 240) },
		{ name = "EPIC", color = Color3.fromRGB(190, 90, 240) }, { name = "LEGENDARY", color = Color3.fromRGB(255, 170, 40) }, { name = "MYTHIC", color = Color3.fromRGB(255, 60, 60) } }
	listPage(pages.ULTS, Ultimates.list, ultRar, "ult", function(u) return (ultRar[u.rarity] and ultRar[u.rarity].name or "") .. "  -  " .. u.dur .. " S" end)

	-- RUN ------------------------------------------------------------------------------------------
	do
		local page = pages.RUN
		heading(page, "MAP", 0)
		local mg = grid(page, 6, 3.2, { Size = UDim2.fromScale(1, 0.25), Position = UDim2.fromScale(0, 0.06), ScrollBarThickness = 0 })
		for i, m in Maps.list do
			mapBtns[m.id] = button(mg, string.upper(m.name), m.color, function() pickMap = m.id; refreshPicks() end, { LayoutOrder = i })
		end
		heading(page, "DIFFICULTY", 0.32)
		local dg = grid(page, 6, 3.2, { Size = UDim2.fromScale(1, 0.1), Position = UDim2.fromScale(0, 0.38), ScrollBarThickness = 0 })
		for i, d in Maps.difficulties do
			diffBtns[d.id] = button(dg, string.upper(d.name), d.color, function() pickDiff = d.id; refreshPicks() end, { LayoutOrder = i })
		end
		local A = Color3.fromRGB(110, 190, 80)
		local R = Color3.fromRGB(200, 60, 40)
		local O = Color3.fromRGB(230, 140, 40)
		heading(page, "RUN + EVENTS (events need a run)", 0.5)
		local ag = grid(page, 7, 2.7, { Size = UDim2.fromScale(1, 0.1), Position = UDim2.fromScale(0, 0.56), ScrollBarThickness = 0 })
		button(ag, "START RUN", A, function() cmd("start " .. pickMap .. " " .. pickDiff) end, { LayoutOrder = 1 })
		button(ag, "NEXT GHOST", O, function() cmd("next") end, { LayoutOrder = 2 })
		button(ag, "KILL GHOST", O, function() cmd("killghost") end, { LayoutOrder = 3 })
		button(ag, "END RUN", R, function() cmd("endrun") end, { LayoutOrder = 4 })
		heading(page, "FORCE MONSTER (spawns now during a run)", 0.68)
		local monG = grid(page, 6, 3.2, { Size = UDim2.fromScale(1, 0.26), Position = UDim2.fromScale(0, 0.74), ScrollBarThickness = 0 })
		button(monG, "RANDOM", PAPER, function() cmd("monster off") end, { LayoutOrder = 0 })
		for i, m in Monsters.list do
			button(monG, string.upper(m.name), m.color, function() cmd("monster " .. m.id) end, { LayoutOrder = i })
		end
		button(ag, "PLANE CRASH", O, function() cmd("event plane") end, { LayoutOrder = 5 })
		button(ag, "VAN CRASH", O, function() cmd("event van") end, { LayoutOrder = 6 })
		button(ag, "TRAIN DERAIL", O, function() cmd("event train") end, { LayoutOrder = 7 })
		refreshPicks()
	end

	-- bottom: result line + command box
	logLabel = label(panel, "F2 opens / closes this panel. Type 'help' for every command.", { Font = TYPE, Size = UDim2.fromScale(1, 0.05), Position = UDim2.fromScale(0, 0.87),
		TextXAlignment = Enum.TextXAlignment.Left, TextStrokeTransparency = 1, TextColor3 = Color3.fromRGB(170, 160, 140) })
	local box = N("TextBox", { PlaceholderText = "> type a command (help, cash 50k, give chainsaw, monster butcher...) and press Enter", Text = "",
		ClearTextOnFocus = false, Font = TYPE, TextScaled = true, TextColor3 = PAPER, PlaceholderColor3 = Color3.fromRGB(110, 100, 90),
		BackgroundColor3 = Color3.fromRGB(8, 6, 5), BorderSizePixel = 0, Size = UDim2.fromScale(1, 0.07), Position = UDim2.fromScale(0, 0.93),
		TextXAlignment = Enum.TextXAlignment.Left }, panel)
	corner(box, 4)
	stroke(box, 1.5, MID)
	N("UIPadding", { PaddingLeft = UDim.new(0, 8) }, box)
	box.FocusLost:Connect(function(enter)
		if enter and box.Text ~= "" then
			local line = box.Text
			box.Text = ""
			cmd(line)
		end
	end)

	showPage("PLAYER")
	UIS.InputBegan:Connect(function(input, processed)
		if input.KeyCode == Enum.KeyCode.F2 and not (processed and UIS:GetFocusedTextBox()) then setOpen(not panel.Visible) end
	end)
	-- Studio test hook: player attribute AdminOpen = "PLAYER" | "ITEMS" | "ULTS" | "RUN" | "" opens / closes the panel
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("AdminOpen"):Connect(function()
			local v = lp:GetAttribute("AdminOpen")
			if type(v) == "string" and pages[v] then showPage(v); setOpen(true) else setOpen(false) end
		end)
	end
end

function AP.init(toggled: (open: boolean) -> ())
	onToggle = toggled
	task.spawn(function()
		while lp:GetAttribute("IsAdmin") == nil do lp:GetAttributeChangedSignal("IsAdmin"):Wait() end
		if lp:GetAttribute("IsAdmin") == true then build() end
	end)
end

function AP.isOpen(): boolean return panel ~= nil and panel.Visible end

return AP
