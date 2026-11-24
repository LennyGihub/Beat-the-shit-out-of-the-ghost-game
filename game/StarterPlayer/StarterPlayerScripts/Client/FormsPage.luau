--!strict
-- THE INVENTORY's FORMS page (the lobby's INVENTORY window, Client/BestiaryUI: FORMS | MONSTERS | BADGES; the user,
-- 2026-11-22: "an inventory where we can see our bestiary but also all of our forms").
-- Left: every form you own (Shared/Forms), fist forms (Doc Mercy's jars) and body forms (Mother Moth's potions), as
-- tiles: the jar / bottle in the form's colour, name, rarity, xN copies, WORN on the ones you wear; ALL / FIST FORMS /
-- BODY FORMS above. Worn first, then the rarest, the latest map's first. Right: the picked form: its name, rarity and
-- kind, where it comes from (the map's set, or a code), what it does, its story, how many copies you have (the extra
-- ones can be traded) and WEAR IT (Remotes.Forms "equip") / WORN.
-- Read from the player's attributes: Forms (owned ids), FormN (copies > 1, JSON), FormStim / FormPotion (worn).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Forms = require(RS.Shared.Forms)
local Campaign = require(RS.Shared.Campaign)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local VialArt = require(script.Parent.VialArt)
local Remotes = RS:WaitForChild("Remotes")

local FP = {}
local lp = Players.LocalPlayer
local DIM = Color3.fromRGB(150, 140, 125)
local GREEN = Color3.fromRGB(150, 220, 110)
local DARK = Color3.fromRGB(45, 40, 36)
local WEAR = Color3.fromRGB(62, 118, 40)

local filter = "all" -- "all" | "stim" | "potion"
local selected: string? = nil
local grid: ScrollingFrame
local empty: TextLabel
local filterBtns = {} :: { [string]: TextButton }
local detail: Frame
local d = {} :: { [string]: any } -- the detail page's pieces

-- what I own: { [formId] = copies }
local function owned(): { [string]: number }
	local out = {} :: { [string]: number }
	for id in string.gmatch(lp:GetAttribute("Forms") or "", "[^,]+") do
		if Forms.byId[id] then out[id] = 1 end
	end
	local ok, copies = pcall(function() return HttpService:JSONDecode(lp:GetAttribute("FormN") or "{}") end)
	if ok and type(copies) == "table" then
		for id, n in copies do if out[id] and tonumber(n) then out[id] = tonumber(n) :: number end end
	end
	return out
end
local function wornIds(): { [string]: boolean }
	local out = {} :: { [string]: boolean }
	for _, a in { "FormStim", "FormPotion" } do
		local v = lp:GetAttribute(a)
		if type(v) == "string" and v ~= "" then out[v] = true end
	end
	return out
end

local function setIndex(set: string): number return table.find(Forms.sets, set) or 0 end

-- the jar / bottle a form comes out of, drawn in the form's own colour
local function vialFor(fm: Forms.Form): Forms.Vial
	local pick: Forms.Vial? = nil
	for _, v in Forms.vials do
		if v.kind == fm.kind and (v.set == fm.set or pick == nil) then
			pick = v
			if v.set == fm.set then break end
		end
	end
	local c = table.clone(pick or Forms.vials[1]) :: any
	c.color = fm.color
	c.id = "_inv" -- (no picture: the drawn jar / bottle)
	return c
end

local function source(fm: Forms.Form): string
	if fm.exclusive then return "EXCLUSIVE  -  FROM " .. (fm.source or "A CODE") end
	local m = Campaign.mapById[fm.set]
	return (m and m.name or fm.set) .. "  -  " .. (fm.kind == "stim" and "DOC MERCY'S ECTOPLASM" or "MOTHER MOTH'S POTIONS")
end

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true; b.BorderSizePixel = 0; b.BackgroundColor3 = DARK
	b.Font = Grunge.FONT; b.Text = text; b.TextScaled = true; b.TextColor3 = Grunge.PAPER; b.TextStrokeTransparency = 0.3
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.16, 0); pad.PaddingBottom = UDim.new(0.16, 0); pad.Parent = b
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	return b
end

local function sorted(own: { [string]: number }, worn: { [string]: boolean }): { Forms.Form }
	local out = {}
	for id in own do
		local fm = Forms.byId[id]
		if fm and (filter == "all" or fm.kind == filter) then table.insert(out, fm) end
	end
	table.sort(out, function(a, b)
		local wa, wb = worn[a.id] == true, worn[b.id] == true
		if wa ~= wb then return wa end
		local ea, eb = a.exclusive == true, b.exclusive == true
		if ea ~= eb then return ea end
		if a.rarity ~= b.rarity then return a.rarity > b.rarity end
		if a.set ~= b.set then return setIndex(a.set) > setIndex(b.set) end
		if a.kind ~= b.kind then return a.kind == "stim" end
		return a.name < b.name
	end)
	return out
end

-- one tile
local function tile(fm: Forms.Form, n: number, worn: boolean, order: number)
	local rr = Forms.rarityOf(fm)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundColor3 = Color3.fromRGB(26, 21, 18); b.Text = ""
	b.ZIndex = 11; b.Name = fm.id; b.LayoutOrder = order
	b.Parent = grid
	local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0.08, 0); cr.Parent = b
	local on = fm.id == selected
	local st = Instance.new("UIStroke"); st.Color = on and Color3.new(1, 1, 1) or rr.color; st.Thickness = on and 4 or (fm.rarity >= 4 and 3 or 2)
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	local glow = Instance.new("Frame")
	glow.BorderSizePixel = 0; glow.BackgroundColor3 = rr.color; glow.BackgroundTransparency = 0.82; glow.Size = UDim2.fromScale(1, 0.62); glow.ZIndex = 11
	glow.Parent = b
	local gc = Instance.new("UICorner"); gc.CornerRadius = UDim.new(0.08, 0); gc.Parent = glow
	VialArt.draw(b, vialFor(fm), { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.04), Size = UDim2.fromScale(0.62, 0.52), ZIndex = 12 })
	Grunge.text(b, { Text = fm.name, Font = Grunge.FONT, Position = UDim2.fromScale(0.04, 0.6), Size = UDim2.fromScale(0.92, 0.17), ZIndex = 15 })
	Grunge.text(b, { Text = rr.name, Font = Grunge.TYPE, TextColor3 = rr.color, Position = UDim2.fromScale(0.04, 0.78), Size = UDim2.fromScale(0.92, 0.12), ZIndex = 15 })
	if n > 1 then
		Grunge.text(b, { Text = "x" .. n, Font = Grunge.FONT, TextColor3 = Color3.fromRGB(255, 220, 120), AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(0.97, 0.02), Size = UDim2.fromScale(0.42, 0.18), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 16 })
	end
	if worn then
		Grunge.text(b, { Text = "WORN", Font = Grunge.FONT, TextColor3 = GREEN, Position = UDim2.fromScale(0.04, 0.02), Size = UDim2.fromScale(0.5, 0.16),
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 16 })
	end
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1.05 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1 }):Play() end)
	b.Activated:Connect(function()
		Sfx.play("Click")
		selected = fm.id
		FP.refresh()
	end)
end

local function showDetail(fm: Forms.Form?, n: number, worn: boolean)
	detail.Visible = fm ~= nil
	if not fm then return end
	local rr = Forms.rarityOf(fm)
	local art = d.art :: Frame
	for _, c in art:GetChildren() do if c.Name == "Vial" then c:Destroy() end end
	VialArt.draw(art, vialFor(fm), { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.7, 0.85), ZIndex = 12 })
	;(d.glow :: Frame).BackgroundColor3 = rr.color
	;(d.artStroke :: UIStroke).Color = rr.color
	;(d.stamp :: TextLabel).Visible = worn
	d.name.Text = fm.name; d.name.TextColor3 = fm.color
	d.kind.Text = rr.name .. "  " .. (fm.kind == "stim" and "FIST FORM" or "BODY FORM"); d.kind.TextColor3 = rr.color
	d.src.Text = source(fm)
	local lines = Forms.lines(fm)
	d.l1.Text = lines[1] or ""; d.l2.Text = lines[2] or ""
	d.desc.Text = fm.desc
	d.copies.Text = n > 1 and ("YOU HAVE " .. n .. " COPIES  -  THE EXTRA ONES CAN BE TRADED") or "YOU HAVE 1 COPY"
	local wb = d.wear :: TextButton
	wb.Text = worn and "WORN" or "WEAR IT"
	wb.BackgroundColor3 = worn and DARK or WEAR
	wb.AutoButtonColor = not worn
end

-- redraw the page; returns how many different forms you own and how many there are
function FP.refresh(): (number, number)
	if not grid then return 0, #Forms.list end
	local own, worn = owned(), wornIds()
	local count = 0
	for _ in own do count += 1 end
	for k, b in filterBtns do
		b.BackgroundColor3 = k == filter and Color3.fromRGB(40, 110, 120) or DARK
	end
	for _, c in grid:GetChildren() do if c:IsA("GuiButton") then c:Destroy() end end
	local list = sorted(own, worn)
	if selected == nil or own[selected] == nil or not table.find(list, Forms.byId[selected]) then
		selected = list[1] and list[1].id or nil
	end
	for i, fm in list do tile(fm, own[fm.id], worn[fm.id] == true, i) end
	empty.Visible = #list == 0
	empty.Text = count == 0 and "NO FORMS YET. OPEN A JAR AT DOC MERCY'S OR DRINK A POTION AT MOTHER MOTH'S."
		or (filter == "stim" and "NO FIST FORMS YET. OPEN A JAR AT DOC MERCY'S." or "NO BODY FORMS YET. DRINK A POTION AT MOTHER MOTH'S.")
	local fm = selected and Forms.byId[selected] or nil
	showDetail(fm, fm and own[fm.id] or 0, fm ~= nil and worn[fm.id] == true)
	return count, #Forms.list
end

function FP.select(id: string)
	if Forms.byId[id] then
		local fm = Forms.byId[id]
		if filter ~= "all" and fm.kind ~= filter then filter = "all" end
		selected = id
		FP.refresh()
	end
end
function FP.filter(k: string)
	if k == "all" or k == "stim" or k == "potion" then filter = k; FP.refresh() end
end

function FP.build(parent: Frame)
	-- filters
	local row = Grunge.frame(parent, { Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(0.6, 0.075), ZIndex = 10 })
	local rl = Instance.new("UIListLayout"); rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0.015, 0); rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Parent = row
	for i, f in { { "ALL", "all", 0.24 }, { "FIST FORMS", "stim", 0.36 }, { "BODY FORMS", "potion", 0.36 } } do
		local b = button(row, f[1] :: string, { Size = UDim2.fromScale(f[3] :: number, 1), ZIndex = 11, LayoutOrder = i })
		b.MouseButton1Click:Connect(function() Sfx.play("Click"); filter = f[2] :: string; FP.refresh() end)
		filterBtns[f[2] :: string] = b
	end
	-- the tiles
	grid = Instance.new("ScrollingFrame")
	grid.BackgroundColor3 = Color3.fromRGB(14, 11, 10); grid.BackgroundTransparency = 0.35; grid.BorderSizePixel = 0
	grid.Position = UDim2.fromScale(0, 0.095); grid.Size = UDim2.fromScale(0.6, 0.905); grid.ZIndex = 10
	grid.ScrollBarThickness = 6; grid.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grid.CanvasSize = UDim2.new(); grid.ScrollingDirection = Enum.ScrollingDirection.Y
	grid.Parent = parent
	local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 6); pad.PaddingTop = UDim.new(0, 6); pad.PaddingRight = UDim.new(0, 10); pad.PaddingBottom = UDim.new(0, 6); pad.Parent = grid
	local gl = Instance.new("UIGridLayout"); gl.SortOrder = Enum.SortOrder.LayoutOrder; gl.CellPadding = UDim2.fromOffset(6, 6); gl.Parent = grid
	local function fit()
		local cols = 5
		local w = grid.AbsoluteSize.X - 16
		local cw = math.floor((w - 6 * (cols - 1)) / cols)
		gl.CellSize = UDim2.fromOffset(math.max(20, cw), math.max(24, math.floor(cw * 1.15)))
	end
	grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
	empty = Grunge.text(parent, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.3, 0.45), Size = UDim2.fromScale(0.5, 0.2),
		TextWrapped = true, TextColor3 = DIM, ZIndex = 12, Visible = false })
	-- the picked form
	detail = Grunge.frame(parent, { Position = UDim2.fromScale(0.625, 0), Size = UDim2.fromScale(0.375, 1), ZIndex = 10 })
	local art = Grunge.frame(detail, { BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(16, 13, 11), Size = UDim2.fromScale(1, 0.4), ZIndex = 10 })
	d.art = art
	d.artStroke = Instance.new("UIStroke"); d.artStroke.Thickness = 3; d.artStroke.Parent = art
	local glow = Grunge.frame(art, { BackgroundTransparency = 0.82, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), ZIndex = 10 })
	local gg = Instance.new("UIGradient")
	gg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.3) })
	gg.Rotation = 90; gg.Parent = glow
	d.glow = glow
	d.stamp = Grunge.text(art, { Text = "WORN", Font = Grunge.FONT, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.97, 0.04), Size = UDim2.fromScale(0.3, 0.14),
		TextColor3 = GREEN, Rotation = 8, ZIndex = 16, Visible = false })
	d.name = Grunge.text(detail, { Text = "", Font = Grunge.HORROR, Position = UDim2.fromScale(0, 0.42), Size = UDim2.fromScale(1, 0.1), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	d.kind = Grunge.text(detail, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.525), Size = UDim2.fromScale(1, 0.045), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	d.src = Grunge.text(detail, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.575), Size = UDim2.fromScale(1, 0.038), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = DIM, ZIndex = 11 })
	d.l1 = Grunge.text(detail, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0, 0.63), Size = UDim2.fromScale(1, 0.055), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = GREEN, ZIndex = 11 })
	d.l2 = Grunge.text(detail, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0, 0.69), Size = UDim2.fromScale(1, 0.055), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = GREEN, ZIndex = 11 })
	d.desc = Grunge.text(detail, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.755), Size = UDim2.fromScale(1, 0.095), TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextColor3 = Color3.fromRGB(210, 200, 180), ZIndex = 11 })
	local tc = Instance.new("UITextSizeConstraint"); tc.MaxTextSize = 20; tc.MinTextSize = 9; tc.Parent = d.desc
	d.copies = Grunge.text(detail, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.858), Size = UDim2.fromScale(1, 0.035), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 220, 120), ZIndex = 11 })
	d.wear = button(detail, "WEAR IT", { Position = UDim2.fromScale(0, 0.91), Size = UDim2.fromScale(0.55, 0.085), BackgroundColor3 = WEAR, ZIndex = 12 })
	;(d.wear :: TextButton).MouseButton1Click:Connect(function()
		local id = selected
		if not id or wornIds()[id] then return end
		Sfx.play("Click")
		;(Remotes :: any).Forms:FireServer("equip", id)
	end)
end

return FP
