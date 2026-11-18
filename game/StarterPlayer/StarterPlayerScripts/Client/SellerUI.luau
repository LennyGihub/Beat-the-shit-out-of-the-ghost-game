--!strict
-- The sellers' panel (Fx "OpenSeller" kind: "stim" = DOC MERCY's ectoplasm, "potion" = MOTHER MOTH; Shared/Forms).
-- Left: the four jars / potions (picture, price, the odds of every rarity, LEVEL n when still locked, OPEN / DRINK). Right: the
-- form you WEAR and the COLLECTION (every form of that kind: the ones you got, WEAR buttons; the others ???).
-- Buying sends Remotes.Forms "buy"; the server rolls it and the first-person cinematic plays (Client/FormCine),
-- then this panel comes back. Closes when you walk away.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Forms = require(RS.Shared.Forms)
local Levels = require(RS.Shared.Levels)
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local titleT: TextLabel
local subT: TextLabel
local cashT: TextLabel
local statusT: TextLabel
local vialFrame: Frame
local wornFrame: Frame
local list: ScrollingFrame
local collT: TextLabel
local kindOpen: string? = nil
local waiting = false
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local LOCKED = Color3.fromRGB(22, 18, 16)
local ACCENT = { stim = Color3.fromRGB(120, 200, 90), potion = Color3.fromRGB(190, 120, 240) }
local seedN = 700

-- the vials' pictures (tools/make_image.py; Forms.icons when they exist)
local function icon(v: Forms.Vial): string
	local icons = (Forms :: any).icons
	return icons and icons[v.id] or ""
end

local function button(parent: Instance, text: string, props: { [string]: any }, color: Color3): TextButton
	seedN += 1
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local z = props.ZIndex or 1
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, color, seedN, 12)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.88, 0.6), ZIndex = z + 3 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.06 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	return b
end

local function owned(): { [string]: boolean }
	local o = {}
	for id in string.gmatch(lp:GetAttribute("Forms") or "", "[^,]+") do o[id] = true end
	return o
end
local function level(): number return (Levels.of(lp:GetAttribute("XP") or 0)) end

local function clear(f: Instance) for _, c in f:GetChildren() do if c:IsA("GuiObject") then c:Destroy() end end end

local function refresh()
	local kind = kindOpen
	if not kind or not panel then return end
	local seller = Forms.SELLER[kind]
	titleT.Text = seller.name
	subT.Text = kind == "stim" and "ECTOPLASM  -  FIST FORMS: PUNCH DAMAGE AND KNOCKBACK" or "POTIONS  -  BODY FORMS: HEALTH AND STAMINA"
	subT.TextColor3 = ACCENT[kind]
	cashT.Text = "$" .. tostring(lp:GetAttribute("Cash") or 0)
	local lvl = level()
	local cash = lp:GetAttribute("Cash") or 0
	-- VIALS
	clear(vialFrame)
	for i, v in Forms.vialsOf(kind) do
		local locked = lvl < v.level
		seedN += 3
		local card = Grunge.brush(vialFrame, { LayoutOrder = i, ZIndex = 11 }, locked and LOCKED or Color3.fromRGB(30, 24, 21), seedN, 16, false)
		local img = Instance.new("ImageLabel")
		img.BackgroundTransparency = 1; img.Image = icon(v); img.ScaleType = Enum.ScaleType.Fit
		img.Position = UDim2.fromScale(0.03, 0.1); img.Size = UDim2.fromScale(0.32, 0.6); img.ZIndex = 12
		img.ImageTransparency = locked and 0.6 or 0; img.Parent = card
		if img.Image == "" then
			-- (no picture: a little jar / bottle drawn with frames - glass, the glowing contents, a lid or a cork)
			local jarF = Grunge.frame(card, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.19, 0.42), Size = UDim2.fromScale(0.2, 0.62), Rotation = -6, ZIndex = 12 })
			local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 0.72; ar.Parent = jarF
			local function fr(props: { [string]: any }): Frame
				props.BorderSizePixel = 0
				return Grunge.frame(jarF, props)
			end
			local glass = fr({ BackgroundTransparency = 0.55, BackgroundColor3 = Color3.fromRGB(200, 225, 215), Position = UDim2.fromScale(0.05, 0.18), Size = UDim2.fromScale(0.9, 0.8), ZIndex = 12 })
			local gc = Instance.new("UICorner"); gc.CornerRadius = UDim.new(0.18, 0); gc.Parent = glass
			local goo = fr({ BackgroundTransparency = locked and 0.6 or 0, BackgroundColor3 = v.color, Position = UDim2.fromScale(0.14, 0.38), Size = UDim2.fromScale(0.72, 0.54), ZIndex = 13 })
			local gc2 = Instance.new("UICorner"); gc2.CornerRadius = UDim.new(0.2, 0); gc2.Parent = goo
			local shine = fr({ BackgroundTransparency = 0.5, BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromScale(0.18, 0.26), Size = UDim2.fromScale(0.1, 0.55), ZIndex = 14 })
			local _ = shine
			if kind == "stim" then
				fr({ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(70, 66, 60), Position = UDim2.fromScale(0, 0.06), Size = UDim2.fromScale(1, 0.15), ZIndex = 14 })
			else
				fr({ BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(150, 110, 70), Position = UDim2.fromScale(0.35, 0), Size = UDim2.fromScale(0.3, 0.2), ZIndex = 14 })
			end
		end
		Grunge.text(card, { Text = v.name, Font = Grunge.FONT, Position = UDim2.fromScale(0.37, 0.06), Size = UDim2.fromScale(0.6, 0.17),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = locked and Color3.fromRGB(120, 110, 100) or v.color, ZIndex = 13 })
		Grunge.text(card, { Text = v.desc, Font = Grunge.TYPE, Position = UDim2.fromScale(0.37, 0.24), Size = UDim2.fromScale(0.6, 0.2), TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = Color3.fromRGB(180, 170, 150), ZIndex = 13 })
		-- the odds: a chip per rarity
		local odds = Grunge.frame(card, { Position = UDim2.fromScale(0.37, 0.47), Size = UDim2.fromScale(0.6, 0.14), ZIndex = 13 })
		local ol = Instance.new("UIListLayout"); ol.FillDirection = Enum.FillDirection.Horizontal; ol.Padding = UDim.new(0.02, 0); ol.SortOrder = Enum.SortOrder.LayoutOrder; ol.Parent = odds
		local ch = Forms.chances(v)
		for r = 1, #Forms.rarity do
			local c = ch[r]
			if c then
				local rr = Forms.rarity[r]
				Grunge.text(odds, { Text = string.sub(rr.name, 1, 1) .. " " .. (c >= 0.1 and math.floor(c * 100 + 0.5) or (math.floor(c * 1000 + 0.5) / 10)) .. "%",
					Font = Grunge.TYPE, Size = UDim2.fromScale(0.18, 1), TextColor3 = rr.color, LayoutOrder = r, ZIndex = 14 })
			end
		end
		if locked then
			Grunge.text(card, { Text = "LEVEL " .. v.level, Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.66, 0.8),
				Size = UDim2.fromScale(0.5, 0.2), TextColor3 = Color3.fromRGB(255, 150, 80), Rotation = -3, ZIndex = 14 })
		else
			local can = cash >= v.price
			local b = button(card, Forms.SELLER[kind].verb .. "  $" .. v.price, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.66, 0.81),
				Size = UDim2.fromScale(0.58, 0.26), ZIndex = 14, Rotation = -1 }, can and GREEN or DARK)
			b.Activated:Connect(function()
				if waiting then return end
				if (lp:GetAttribute("Cash") or 0) < v.price then
					Sfx.play("Click"); statusT.Text = "NOT ENOUGH CASH - BEAT THE BUILDINGS TO EARN MORE"
					return
				end
				Sfx.play("Click")
				waiting = true
				statusT.Text = kind == "stim" and "THE DOC HANDS YOU A JAR..." or "SHE POURS IT OUT OF THE POT..."
				;(Remotes :: any).Forms:FireServer("buy", v.id)
				task.delay(4, function() waiting = false end)
			end)
		end
	end
	-- WORN
	clear(wornFrame)
	local wornId = lp:GetAttribute(kind == "stim" and "FormStim" or "FormPotion") or ""
	local wf = Forms.byId[wornId]
	Grunge.text(wornFrame, { Text = "YOU WEAR", Font = Grunge.TYPE, Size = UDim2.fromScale(1, 0.22), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(170, 160, 145), ZIndex = 12 })
	Grunge.text(wornFrame, { Text = wf and wf.name or "NOTHING YET", Font = Grunge.HORROR, Position = UDim2.fromScale(0, 0.2), Size = UDim2.fromScale(1, 0.42),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = wf and wf.color or Color3.fromRGB(120, 110, 100), ZIndex = 12 })
	Grunge.text(wornFrame, { Text = wf and table.concat(Forms.lines(wf), "   ") or (kind == "stim" and "OPEN A JAR OF ECTOPLASM TO GET A FIST FORM" or "DRINK A POTION TO GET A BODY FORM"),
		Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.66), Size = UDim2.fromScale(1, 0.26), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = wf and Color3.fromRGB(150, 220, 110) or Color3.fromRGB(150, 140, 125), ZIndex = 12 })
	-- COLLECTION
	clear(list)
	local own = owned()
	local all = Forms.ofKind(kind)
	local n = 0
	for i, fm in all do
		local has = own[fm.id] == true
		if has then n += 1 end
		local rr = Forms.rarity[fm.rarity]
		seedN += 1
		local row = Grunge.brush(list, { Size = UDim2.new(1, -8, 0, 46), LayoutOrder = i, ZIndex = 11 }, Color3.fromRGB(30, 24, 21), seedN, 18, false)
		Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = rr.color, Position = UDim2.new(0, 4, 0.14, 0), Size = UDim2.new(0, 5, 0.72, 0), ZIndex = 12 })
		Grunge.text(row, { Text = has and fm.name or "???", Font = Grunge.FONT, Position = UDim2.new(0, 14, 0.06, 0), Size = UDim2.new(0.62, 0, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = has and fm.color or Color3.fromRGB(110, 100, 92), ZIndex = 12 })
		Grunge.text(row, { Text = has and table.concat(Forms.lines(fm), "  ") or rr.name, Font = Grunge.TYPE, Position = UDim2.new(0, 14, 0.56, 0), Size = UDim2.new(0.62, 0, 0.36, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = has and Color3.fromRGB(190, 180, 160) or rr.color, ZIndex = 12 })
		if has then
			local isWorn = fm.id == wornId
			local b = button(row, isWorn and "WORN" or "WEAR", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0.28, 0, 0.74, 0), ZIndex = 13 },
				isWorn and DARK or GREEN)
			b.Activated:Connect(function()
				if isWorn then return end
				Sfx.play("Click")
				;(Remotes :: any).Forms:FireServer("equip", fm.id)
			end)
		end
	end
	collT.Text = "COLLECTION  " .. n .. " / " .. #all
end

function UI.close()
	if panel and panel.Visible then panel.Visible = false end
	kindOpen = nil
end
function UI.isOpen(): boolean return panel ~= nil and panel.Visible end

function UI.open(kind: string)
	if lp:GetAttribute("InMatch") or not Forms.SELLER[kind] then return end
	kindOpen = kind
	statusT.Text = ""
	waiting = false
	refresh()
	panel.Visible = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

-- a buy went wrong (Fx "FormResult")
function UI.result(good: boolean, text: string)
	waiting = false
	if statusT then statusT.Text = string.upper(text) end
	if not good then Sfx.play("Click", { PlaybackSpeed = 0.6 }) end
end

-- the buy went through: the cinematic plays (then the panel comes back)
function UI.rolled(): string?
	local k = kindOpen
	UI.close()
	waiting = false
	return k
end

function UI.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "SellerUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 6
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.7, 0.82), Visible = false, ZIndex = 8 },
		Color3.fromRGB(21, 17, 15), 77, 6, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 1.5; par.Parent = panel
	titleT = Grunge.text(panel, { Text = "", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.025), Size = UDim2.fromScale(0.5, 0.095), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1, ZIndex = 11, TextColor3 = Color3.fromRGB(235, 50, 35) })
	subT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.12), Size = UDim2.fromScale(0.6, 0.04), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	cashT = Grunge.text(panel, { Text = "$0", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.78, 0.03), Size = UDim2.fromScale(0.22, 0.07), TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 11, Rotation = 2 })
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.03), Size = UDim2.fromScale(0.15, 0.065), ZIndex = 12, Rotation = 1.5, Modal = true }, DARK)
	close.Activated:Connect(function() Sfx.play("Click"); UI.close() end)
	Platform.menu(panel, function() UI.close() end)
	-- the vials: 2 x 2
	Grunge.text(panel, { Text = "YOU NEVER KNOW WHAT YOU GET", Font = Grunge.FONT, Position = UDim2.fromScale(0.04, 0.18), Size = UDim2.fromScale(0.55, 0.045),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	vialFrame = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.24), Size = UDim2.fromScale(0.56, 0.64), ZIndex = 10 })
	local grid = Instance.new("UIGridLayout"); grid.CellSize = UDim2.fromScale(0.49, 0.485); grid.CellPadding = UDim2.fromScale(0.02, 0.03)
	grid.SortOrder = Enum.SortOrder.LayoutOrder; grid.Parent = vialFrame
	statusT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.9), Size = UDim2.fromScale(0.56, 0.045), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 150, 80), ZIndex = 11 })
	-- worn + collection
	wornFrame = Grunge.frame(panel, { Position = UDim2.fromScale(0.63, 0.18), Size = UDim2.fromScale(0.33, 0.17), ZIndex = 10 })
	collT = Grunge.text(panel, { Text = "COLLECTION", Font = Grunge.FONT, Position = UDim2.fromScale(0.63, 0.37), Size = UDim2.fromScale(0.33, 0.045),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.Position = UDim2.fromScale(0.63, 0.43); list.Size = UDim2.fromScale(0.33, 0.52)
	list.ScrollBarThickness = 5; list.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(); list.ZIndex = 10; list.Parent = panel
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 4); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = list
	for _, a in { "Cash", "XP", "Forms", "FormStim", "FormPotion" } do
		lp:GetAttributeChangedSignal(a):Connect(function() if panel.Visible then refresh() end end)
	end
	-- walking away closes it
	RunService.Heartbeat:Connect(function()
		if not panel.Visible or not kindOpen then return end
		local lobby = workspace:FindFirstChild("Lobby")
		local f = lobby and lobby:FindFirstChild("Sellers")
		local m = f and f:FindFirstChild(kindOpen == "stim" and "DocMercy" or "MotherMoth")
		local p = m and m:FindFirstChild("Prompt", true) :: BasePart?
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if lp:GetAttribute("InMatch") or (p and hrp and (hrp.Position - p.Position).Magnitude > 22) then UI.close() end
	end)
	-- Studio test hook: player attribute DebugSeller = "stim" | "potion" opens that panel ("" closes it)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugSeller"):Connect(function()
			local k = lp:GetAttribute("DebugSeller")
			if k == "stim" or k == "potion" then UI.open(k) else UI.close() end
		end)
	end
end

return UI
