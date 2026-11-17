-- Lobby shop at the Hooded Dealer, picture first: three tabs (ULTIMATES, MAPS, ROBUX: cash packs and the Game
-- Passes of Shared/Passes), each a grid of cards
-- (a PS2-style picture from Shared/ShopArt, a short name, a price tag). Click a card to select it: the strip at the
-- bottom shows its one-line description and the BUY / EQUIP button. Same look as the lobby panel and the fight HUD.
-- Owners of the Double Ultimate pass get a second button on an owned ultimate: EQUIP SLOT 2 (the spare ultimate).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local Ultimates = require(RS.Shared.Ultimates)
local Maps = require(RS.Shared.Maps)
local Config = require(RS.Shared.Config)
local Art = require(RS.Shared.ShopArt)
local Passes = require(RS.Shared.Passes)
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local Shop = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local cashText: TextLabel
local statusText: TextLabel
local selName: TextLabel
local selDesc: TextLabel
local actBtn: TextButton
local actBtn2: TextButton -- EQUIP SLOT 2 (Double Ultimate pass)
local registered = false
local onToggle: ((boolean) -> ())? = nil
local tab = "ults" -- ults | maps | robux
local prices = {} :: { [string]: number }

local RED = Color3.fromRGB(150, 18, 20)
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local BLUE = Color3.fromRGB(44, 72, 120)
local GREY = Color3.fromRGB(64, 58, 52)
local GOLD = Color3.fromRGB(150, 104, 18)
local ROBUX = Color3.fromRGB(30, 120, 60)
local ACCENT = Color3.fromRGB(255, 150, 80)
local CARD = Color3.fromRGB(24, 19, 17)
local RARITY = { Color3.fromRGB(200, 196, 186), Color3.fromRGB(110, 200, 90), Color3.fromRGB(80, 150, 240), Color3.fromRGB(170, 90, 230), Color3.fromRGB(255, 170, 40) }

-- one thing on sale. state() = tag text, tag colour, owned?; act() = what the big button does
-- verb2 / act2 = an optional second button (nil text = hidden)
type Entry = { key: string, name: string, desc: string, color: Color3, state: () -> (string, Color3, boolean), act: () -> (), verb: () -> string,
	verb2: (() -> (string?, Color3?))?, act2: (() -> ())?,
	card: TextButton?, tag: Frame?, tagText: TextLabel?, sel: UIStroke?, img: ImageLabel? }
local entries = {} :: { [string]: { Entry } }
local selected: Entry? = nil
local grids = {} :: { [string]: ScrollingFrame }
local tabBtns = {} :: { [string]: TextButton }
local seedN = 500

local function owned(): { [string]: boolean }
	local o = { Rage = true }
	for id in string.gmatch(lp:GetAttribute("OwnedUlts") or "", "[^,]+") do o[id] = true end
	return o
end
local function ownedMaps(): { [string]: boolean }
	local o = { Mansion = true }
	for id in string.gmatch(lp:GetAttribute("Owned") or "", "[^,]+") do
		local m = string.match(id, "^Map_(.+)$")
		if m then o[m] = true end
	end
	return o
end
-- the spare ultimate of the Double Ultimate pass ("" = none, or no pass)
local function second(): string
	return lp:GetAttribute("DoubleUlt") and (lp:GetAttribute("EquippedUlt2") or "") or ""
end
local function attrId(name: string): number return tonumber(RS:GetAttribute(name)) or 0 end
local function cash(): number return lp:GetAttribute("Cash") or 0 end

-- a brush-stroke button (same as the lobby's)
local function button(parent: Instance, text: string, props: { [string]: any }, color: Color3): TextButton
	seedN += 1
	local z = props.ZIndex or 1
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, color, seedN, 12)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.62), ZIndex = z + 3 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.05 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	return b
end
local function setButton(b: TextButton, text: string, color: Color3)
	(b:FindFirstChild("Label") :: TextLabel).Text = text
	local br = b:FindFirstChild("Brush")
	if br then Grunge.paint(br, color) end
end

local function refresh()
	if not gui or not actBtn or not actBtn2 then return end -- not built yet
	cashText.Text = "$" .. tostring(cash())
	for id, g in grids do g.Visible = id == tab end
	for id, b in tabBtns do
		local br = b:FindFirstChild("Brush")
		if br then Grunge.paint(br, id == tab and RED or DARK) end
	end
	for _, list in entries do
		for _, e in list do
			if e.card and e.tag and e.tagText and e.sel and e.img then
				local text, color, has = e.state()
				e.tagText.Text = text
				Grunge.paint(e.tag, color)
				e.sel.Enabled = selected == e
				e.img.ImageColor3 = has and Color3.new(1, 1, 1) or Color3.fromRGB(170, 170, 170)
			end
		end
	end
	local s = selected
	if s then
		selName.Text = string.upper(s.name)
		selName.TextColor3 = s.color:Lerp(Color3.new(1, 1, 1), 0.25)
		selDesc.Text = s.desc
		local _, color = s.state()
		setButton(actBtn, s.verb(), color)
		actBtn.Visible = true
		-- the second button, when this card has one: the two share the place of the big one
		local text2, color2 = nil, nil
		if s.verb2 then text2, color2 = s.verb2() end
		actBtn2.Visible = text2 ~= nil
		if text2 then
			setButton(actBtn2, text2, color2 or GOLD)
			actBtn.Position = UDim2.fromScale(0.96, 0.835); actBtn.Size = UDim2.fromScale(0.27, 0.07)
		else
			actBtn.Position = UDim2.fromScale(0.96, 0.85); actBtn.Size = UDim2.fromScale(0.27, 0.1)
		end
	else
		selName.Text = "PICK SOMETHING"
		selName.TextColor3 = Grunge.PAPER
		selDesc.Text = ""
		actBtn.Visible = false
		actBtn2.Visible = false
	end
end

local function select(e: Entry)
	selected = e
	statusText.Text = ""
	refresh()
end

-- a card in a grid: picture, colour line, short name, price tag
local function card(grid: ScrollingFrame, e: Entry, order: number)
	seedN += 1
	local b = Instance.new("TextButton")
	b.Name = e.key; b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""; b.LayoutOrder = order; b.ZIndex = 11
	b.Parent = grid
	Grunge.brush(b, { Size = UDim2.fromScale(1, 1), ZIndex = 11 }, CARD, seedN, 10)
	local img = Instance.new("ImageLabel")
	img.BorderSizePixel = 0; img.BackgroundColor3 = e.color:Lerp(Color3.new(0, 0, 0), 0.72); img.Image = Art[e.key] or ""
	img.ScaleType = Enum.ScaleType.Crop; img.Position = UDim2.fromScale(0.05, 0.045); img.Size = UDim2.fromScale(0.9, 0.66); img.ZIndex = 13
	img.Parent = b
	if img.Image == "" then -- no picture yet: a splatter in the item's colour
		Grunge.splat(img, { Size = UDim2.fromScale(1, 1), ImageColor3 = e.color, ImageTransparency = 0.25, ZIndex = 14 })
	end
	local sel = Instance.new("UIStroke"); sel.Color = ACCENT; sel.Thickness = 3; sel.Enabled = false; sel.Parent = img
	Grunge.frame(b, { BackgroundTransparency = 0, BackgroundColor3 = e.color, Position = UDim2.fromScale(0.05, 0.71), Size = UDim2.fromScale(0.9, 0.022), ZIndex = 14 })
	Grunge.text(b, { Text = string.upper(e.name), Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.74), Size = UDim2.fromScale(0.9, 0.105), ZIndex = 14 })
	local tag = Grunge.brush(b, { Position = UDim2.fromScale(0.08, 0.86), Size = UDim2.fromScale(0.84, 0.105), ZIndex = 13 }, RED, seedN + 3, 10, false)
	local tagText = Grunge.text(tag, { Text = "", Size = UDim2.fromScale(1, 0.9), Position = UDim2.fromScale(0, 0.05), ZIndex = 15 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.04 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	b.Activated:Connect(function() Sfx.play("Click"); select(e) end)
	e.card, e.tag, e.tagText, e.sel, e.img = b, tag, tagText, sel, img
end

-- a scrolling grid of cards; cells are sized from the frame's width (cols across, card height = width * ratio)
local function grid(id: string, cols: number, ratio: number): ScrollingFrame
	local g = Instance.new("ScrollingFrame")
	g.Name = id; g.BackgroundTransparency = 1; g.BorderSizePixel = 0; g.Position = UDim2.fromScale(0.04, 0.2); g.Size = UDim2.fromScale(0.92, 0.61)
	g.ScrollBarThickness = 8; g.ScrollBarImageColor3 = RED; g.AutomaticCanvasSize = Enum.AutomaticSize.Y; g.CanvasSize = UDim2.new()
	g.ZIndex = 10; g.Visible = false; g.Parent = panel
	local layout = Instance.new("UIGridLayout"); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = g
	local function size()
		local w = g.AbsoluteSize.X - 14
		if w <= 0 then return end
		local pad = math.floor(w * 0.014)
		local cw = math.floor((w - pad * (cols - 1)) / cols)
		layout.CellPadding = UDim2.fromOffset(pad, pad)
		layout.CellSize = UDim2.fromOffset(cw, math.floor(cw * ratio))
	end
	g:GetPropertyChangedSignal("AbsoluteSize"):Connect(size)
	size()
	grids[id] = g
	return g
end

local function prompt(kind: string, id: number, soon: string)
	if id == 0 then Shop.result(false, soon) return end
	if kind == "product" then MarketplaceService:PromptProductPurchase(lp, id) else MarketplaceService:PromptGamePassPurchase(lp, id) end
end
local function robuxState(ownedAttr: string?, idAttr: string, priceKey: string): (string, Color3, boolean)
	if ownedAttr and lp:GetAttribute(ownedAttr) then return "OWNED", GREEN, true end
	if attrId(idAttr) == 0 then return "SOON", GREY, true end
	return "R$ " .. tostring(prices[priceKey] or "?"), ROBUX, true
end

function Shop.init(toggle: (boolean) -> ())
	onToggle = toggle
	gui = Instance.new("ScreenGui")
	gui.Name = "UltShop"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Enabled = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.74, 0.86), ZIndex = 8 }, Color3.fromRGB(21, 17, 15), 21, 6)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.45; ar.Parent = panel
	Grunge.text(panel, { Text = "THE DEALER", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.02), Size = UDim2.fromScale(0.4, 0.085), TextXAlignment = Enum.TextXAlignment.Left, Rotation = -1, ZIndex = 11 })
	local bar = Grunge.bar(panel, { size = UDim2.fromScale(0.3, 0.024), pos = UDim2.fromScale(0.04, 0.1), color = RED, rot = 0.4, seed = 51, slices = 26 })
	bar.root.ZIndex = 10
	cashText = Grunge.text(panel, { Text = "$0", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.78, 0.025), Size = UDim2.fromScale(0.24, 0.075), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 11, Rotation = 2 })
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.03), Size = UDim2.fromScale(0.15, 0.065), ZIndex = 12, Rotation = 1.5, Modal = true }, DARK)
	close.Activated:Connect(function() Sfx.play("Click"); Shop.close() end)
	-- tabs
	for i, t in { { "ults", "ULTIMATES" }, { "maps", "MAPS" }, { "robux", "ROBUX" } } do
		local b = button(panel, t[2], { Position = UDim2.fromScale(0.04 + (i - 1) * 0.2, 0.128), Size = UDim2.fromScale(0.19, 0.058), ZIndex = 12, Rotation = (i - 2) * 0.6 }, DARK)
		b.Activated:Connect(function() Sfx.play("Click"); tab = t[1]; selected = nil; refresh() end)
		tabBtns[t[1]] = b
	end

	-- ULTIMATES: 5 across, sorted by rarity (the colour line), bought with cash, one equipped
	entries.ults = {}
	local gu = grid("ults", 5, 1.22)
	for i, u in Ultimates.list do
		local e: Entry = {
			key = "ult_" .. u.id, name = u.name, desc = u.desc, color = RARITY[u.rarity] or u.color,
			state = function()
				if (lp:GetAttribute("EquippedUlt") or "Rage") == u.id then return "EQUIPPED", GREEN, true end
				if second() == u.id then return "SLOT 2", GOLD, true end
				if owned()[u.id] then return "OWNED", BLUE, true end
				return "$" .. u.price, cash() >= u.price and RED or GREY, false
			end,
			verb = function()
				if (lp:GetAttribute("EquippedUlt") or "Rage") == u.id then return "EQUIPPED" end
				return owned()[u.id] and "EQUIP" or ("BUY  $" .. u.price)
			end,
			act = function()
				if owned()[u.id] then Remotes.EquipUlt:FireServer(u.id) else Remotes.BuyUlt:FireServer(u.id) end
			end,
			-- Double Ultimate pass: the spare slot
			verb2 = function(): (string?, Color3?)
				if not lp:GetAttribute("DoubleUlt") or not owned()[u.id] then return nil, nil end
				if second() == u.id then return "IN SLOT 2", GREY end
				return "EQUIP SLOT 2", GOLD
			end,
			act2 = function()
				if second() ~= u.id then Remotes.EquipUlt:FireServer(u.id, 2) end
			end,
		}
		table.insert(entries.ults, e)
		card(gu, e, i)
	end
	-- MAPS: 3 across (wide pictures), bought once
	entries.maps = {}
	local gm = grid("maps", 3, 0.86)
	for i, m in Maps.list do
		local e: Entry = {
			key = "map_" .. m.id, name = m.name, desc = m.desc, color = m.color,
			state = function()
				if ownedMaps()[m.id] then return "OWNED", GREEN, true end
				return "$" .. m.price, cash() >= m.price and RED or GREY, false
			end,
			verb = function() return ownedMaps()[m.id] and "OWNED" or ("BUY  $" .. m.price) end,
			act = function() if not ownedMaps()[m.id] then Remotes.BuyMap:FireServer(m.id) end end,
		}
		table.insert(entries.maps, e)
		card(gm, e, i)
	end
	-- ROBUX: cash packs (Developer Products), then the passes
	entries.robux = {}
	local gr = grid("robux", 4, 1.22)
	for i, pack in Config.CashPacks do
		local e: Entry = {
			key = "cash" .. i, name = "$" .. pack.cash, desc = pack.name .. ": $" .. pack.cash .. " cash for ultimates and maps, right away.", color = Color3.fromRGB(150, 220, 110),
			state = function() return robuxState(nil, pack.attr, pack.attr) end,
			verb = function() return attrId(pack.attr) == 0 and "SOON" or ("BUY  R$ " .. tostring(prices[pack.attr] or "?")) end,
			act = function() prompt("product", attrId(pack.attr), "Cash packs are not on sale yet") end,
		}
		table.insert(entries.robux, e)
		card(gr, e, i)
	end
	local passes = Passes.list
	for i, p in passes do
		local e: Entry = {
			key = p.key, name = p.name, desc = p.desc, color = p.color,
			state = function() return robuxState(p.own, p.id, p.id) end,
			verb = function()
				if lp:GetAttribute(p.own) then return "OWNED" end
				return attrId(p.id) == 0 and "SOON" or ("BUY  R$ " .. tostring(prices[p.id] or "?"))
			end,
			act = function() if not lp:GetAttribute(p.own) then prompt("pass", attrId(p.id), p.name .. " is not on sale yet") end end,
		}
		table.insert(entries.robux, e)
		card(gr, e, 10 + i)
	end
	-- live Robux prices
	task.spawn(function()
		for _, pack in Config.CashPacks do
			local pid = attrId(pack.attr)
			if pid > 0 then
				local ok, info = pcall(function() return MarketplaceService:GetProductInfo(pid, Enum.InfoType.Product) end)
				if ok and info and info.PriceInRobux then prices[pack.attr] = info.PriceInRobux end
			end
		end
		for _, p in passes do
			local id = attrId(p.id)
			if id > 0 then
				local ok, info = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass) end)
				if ok and info and info.PriceInRobux then prices[p.id] = info.PriceInRobux end
			end
		end
		refresh()
	end)

	-- the strip at the bottom: what is selected, one line about it, the big button
	Grunge.brush(panel, { Position = UDim2.fromScale(0.04, 0.825), Size = UDim2.fromScale(0.92, 0.008), ZIndex = 10 }, RED, 77, 30, false)
	selName = Grunge.text(panel, { Text = "", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.84), Size = UDim2.fromScale(0.6, 0.06), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	selDesc = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.9), Size = UDim2.fromScale(0.62, 0.04), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 190, 170), ZIndex = 11 })
	statusText = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.943), Size = UDim2.fromScale(0.62, 0.035), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	actBtn = button(panel, "BUY", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.85), Size = UDim2.fromScale(0.27, 0.1), ZIndex = 12, Rotation = -1.5 }, RED)
	actBtn.Activated:Connect(function()
		Sfx.play("Click")
		if selected then selected.act() end
	end)
	actBtn2 = button(panel, "EQUIP SLOT 2", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.912), Size = UDim2.fromScale(0.27, 0.07), ZIndex = 12, Rotation = 1, Visible = false }, GOLD)
	actBtn2.Activated:Connect(function()
		Sfx.play("Click")
		if selected and selected.act2 then selected.act2() end
	end)

	for _, a in { "Cash", "OwnedUlts", "EquippedUlt", "EquippedUlt2", "Owned" } do lp:GetAttributeChangedSignal(a):Connect(refresh) end
	for _, pass in Passes.list do
		lp:GetAttributeChangedSignal(pass.own):Connect(refresh)
		RS:GetAttributeChangedSignal(pass.id):Connect(refresh)
	end
	-- Studio test hooks: player attribute ShopTab = "robux" | "maps" | "all" opens the shop on that tab;
	-- ShopPick = a card's key (e.g. "ult_Rage") selects it
	if game:GetService("RunService"):IsStudio() then
		lp:GetAttributeChangedSignal("ShopTab"):Connect(function()
			local t = lp:GetAttribute("ShopTab")
			if t == "robux" then tab = "robux" elseif t == "maps" then tab = "maps" elseif t == "all" then tab = "ults" else return end
			selected = nil
			Shop.open()
		end)
		lp:GetAttributeChangedSignal("ShopPick"):Connect(function()
			local k = lp:GetAttribute("ShopPick")
			for _, list in entries do
				for _, e in list do if e.key == k then select(e) end end
			end
		end)
	end
end

function Shop.open()
	if not registered then registered = true; Platform.menu(panel, Shop.close) end
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
