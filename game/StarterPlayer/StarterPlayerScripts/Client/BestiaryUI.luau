--!strict
-- The lobby's BESTIARY panel (long-term goals; grunge, like the quests): two tabs.
-- MONSTERS: a card for every monster and every evolved form (16). One you have beaten shows its name, its mastery
--   stars (Badges.starGoals) and, on the right, the monster itself turning in 3D with its story, its power and how
--   often you beat it; one you have not is a black silhouette called "???".
-- BADGES: every badge (Shared/Badges) with its medal, progress bar and cash reward.
-- Everything is read from the player's attributes (Server/Data publishes Bestiary, Badges, Kills, GhostLevel,
-- NightmareKills); the 3D copies are ReplicatedStorage.BestiaryModels (Server/Bestiary).
-- Also the pop-up cards: BestiaryUI.unlocked(badgeId) and BestiaryUI.discovered(key), in the park and in a run.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Badges = require(RS.Shared.Badges)
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)

local BestiaryUI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local popGui: ScreenGui
local panel: Frame
local onToggle: ((boolean) -> ())? = nil
local registered = false
local tab = "monsters"
local selected = "Woman"

local GOLD = Color3.fromRGB(240, 190, 60)
local RED = Color3.fromRGB(120, 24, 20)
local DARK = Color3.fromRGB(45, 40, 36)
local DIM = Color3.fromRGB(150, 140, 125)
local EVO = Color3.fromRGB(190, 110, 255)
local RARITY = {
	[0] = { "COMMON", Color3.fromRGB(200, 196, 186) }, [1] = { "COMMON", Color3.fromRGB(200, 196, 186) },
	[2] = { "RARE", Color3.fromRGB(80, 150, 240) }, [3] = { "EVOLVED", EVO }, [4] = { "SECRET", Color3.fromRGB(255, 80, 60) },
}

local function book(): { [string]: number }
	local raw = lp:GetAttribute("Bestiary")
	if type(raw) ~= "string" then return {} end
	local ok, d = pcall(function() return HttpService:JSONDecode(raw) end)
	if not ok or type(d) ~= "table" then return {} end
	local out = {} :: { [string]: number }
	for k, v in d :: any do
		if type(k) == "string" and type(v) == "number" then out[k] = v end
	end
	return out
end
local function owned(): { [string]: boolean }
	local out = {} :: { [string]: boolean }
	local raw = lp:GetAttribute("Badges")
	if type(raw) == "string" then
		for id in string.gmatch(raw, "[^,]+") do out[id] = true end
	end
	return out
end
local function num(attr: string): number
	local v = lp:GetAttribute(attr)
	return type(v) == "number" and v or 0
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

-- a round medal in the badge's tier colour: its group's picture when there is one, else the tier in Roman numerals
local ROMAN = { "I", "II", "III", "IV" }
local function medal(parent: Instance, badge: Badges.Badge, props: { [string]: any }): (Frame, UIStroke, TextLabel, ImageLabel)
	local tier = Badges.tiers[badge.tier] or Badges.tiers[1]
	local m = Grunge.frame(parent, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(24, 19, 17) })
	for k, v in props do (m :: any)[k] = v end
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1; ar.Parent = m
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = m
	local st = Instance.new("UIStroke"); st.Color = tier.color; st.Thickness = 4; st.Parent = m
	local numeral = Grunge.text(m, { Text = ROMAN[badge.tier] or "I", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.6), TextColor3 = tier.color, ZIndex = m.ZIndex + 1 })
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1; img.AnchorPoint = Vector2.new(0.5, 0.5); img.Position = UDim2.fromScale(0.5, 0.5); img.Size = UDim2.fromScale(0.78, 0.78)
	img.ScaleType = Enum.ScaleType.Fit; img.ZIndex = m.ZIndex + 1; img.Image = Badges.icons[badge.group] or ""
	img.Parent = m
	if img.Image ~= "" then
		numeral.AnchorPoint = Vector2.new(1, 1); numeral.Position = UDim2.fromScale(1.05, 1.08); numeral.Size = UDim2.fromScale(0.42, 0.42); numeral.ZIndex = m.ZIndex + 2
	end
	return m, st, numeral, img
end

-- MONSTERS -----------------------------------------------------------------------------------------------------
type Card = { btn: TextButton, name: TextLabel, tag: TextLabel, count: TextLabel, stars: { Frame }, edge: Frame, stroke: UIStroke }
local cards = {} :: { [string]: Card }
local monstersPage: Frame
local badgesPage: Frame
local view: ViewportFrame
local viewCam: Camera
local viewModel: Model? = nil
local viewKey = ""
local viewDist, viewLook = 12, Vector3.zero
local dTitle: TextLabel
local dTag: TextLabel
local dAbility: TextLabel
local dDesc: TextLabel
local dCount: TextLabel
local dNext: TextLabel
local dStars = {} :: { Frame }
local headCount: TextLabel

local function starRow(parent: Instance, props: { [string]: any }, z: number): { Frame }
	local holder = Grunge.frame(parent, props)
	local out = {}
	for i = 1, #Badges.starGoals do
		local s = Grunge.frame(holder, { BackgroundTransparency = 0, BackgroundColor3 = DARK, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale((i - 1) * 0.26, 0.5), Size = UDim2.fromScale(0.2, 0.9), Rotation = 45, ZIndex = z })
		local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1; ar.Parent = s
		local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 2; st.Parent = s
		table.insert(out, s)
	end
	return out
end
local function setStars(list: { Frame }, n: number)
	for i, s in list do s.BackgroundColor3 = i <= n and GOLD or DARK end
end

local function showModel(key: string, known: boolean)
	if viewKey == key and viewModel then
		view.ImageColor3 = known and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
		return
	end
	if viewModel then viewModel:Destroy(); viewModel = nil end
	viewKey = key
	local folder = RS:FindFirstChild("BestiaryModels")
	local src = folder and folder:FindFirstChild(key)
	if not src or not src:IsA("Model") then return end
	local m = src:Clone()
	m.Parent = view
	viewModel = m
	local cf, size = m:GetBoundingBox()
	viewLook = cf.Position
	viewDist = math.max(size.Y * 1.75, size.X * 1.6, size.Z * 1.6, 6)
	view.ImageColor3 = known and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
end

local function refreshMonsters(): number
	local bk = book()
	local seen = 0
	for _, e in Badges.entries do
		local c = cards[e.key]
		local n = bk[e.key] or 0
		if n > 0 then seen += 1 end
		if c then
			local rar = RARITY[e.rarity] or RARITY[0]
			c.name.Text = n > 0 and e.title or "? ? ?"
			c.name.TextColor3 = n > 0 and Grunge.PAPER or DIM
			c.tag.Text = n > 0 and rar[1] or (e.evolved and "EVOLVED" or "UNKNOWN")
			c.tag.TextColor3 = n > 0 and rar[2] or DIM
			c.count.Text = n > 0 and ("x" .. n) or ""
			c.edge.BackgroundColor3 = n > 0 and e.color or DARK
			c.stroke.Color = e.key == selected and GOLD or Grunge.INK
			c.stroke.Thickness = e.key == selected and 4 or 2
			setStars(c.stars, Badges.stars(n))
		end
	end
	local e = Badges.entryByKey[selected] or Badges.entries[1]
	local n = bk[e.key] or 0
	local known = n > 0
	local rar = RARITY[e.rarity] or RARITY[0]
	dTitle.Text = known and e.title or "? ? ?"
	dTitle.TextColor3 = known and e.color:Lerp(Color3.new(1, 1, 1), 0.25) or DIM
	dTag.Text = known and (rar[1] .. (e.secret and not e.evolved and " MONSTER" or "")) or (e.secret and "A RUMOUR" or (e.evolved and "AN EVOLVED MONSTER" or "NOT BEATEN YET"))
	dTag.TextColor3 = known and rar[2] or DIM
	dAbility.Text = known and ("POWER: " .. e.ability) or "POWER: ? ? ?"
	dDesc.Text = known and e.desc
		or (e.secret and "Nobody agrees on what it is. It does not belong in the house, and it almost never comes."
			or (e.evolved and "Every third ghost of a run is an evolved monster. Beat this one to write its page."
				or "Beat it in a run to write its page."))
	dCount.Text = known and ("BEATEN " .. n .. (n == 1 and " TIME" or " TIMES")) or "BEATEN 0 TIMES"
	local st = Badges.stars(n)
	setStars(dStars, st)
	local nextGoal = Badges.starGoals[st + 1]
	dNext.Text = nextGoal and ("NEXT MASTERY STAR AT " .. nextGoal) or "MASTERED"
	showModel(e.key, known)
	return seen
end

-- BADGES -------------------------------------------------------------------------------------------------------
type BadgeRow = { fill: Frame, count: TextLabel, reward: TextLabel, name: TextLabel, ring: UIStroke, num: TextLabel, img: ImageLabel, row: Frame }
local badgeRows = {} :: { [string]: BadgeRow }

local function refreshBadges(): number
	local bk, own = book(), owned()
	local kills, wave, night = num("Kills"), math.max(0, num("GhostLevel") - 1), num("NightmareKills")
	local got = 0
	for _, badge in Badges.list do
		local r = badgeRows[badge.id]
		local tier = Badges.tiers[badge.tier] or Badges.tiers[1]
		local has = own[badge.id] == true
		if has then got += 1 end
		if r then
			local v = has and badge.goal or math.min(badge.goal, Badges.value(badge.stat, bk, kills, wave, night))
			r.fill.Size = UDim2.fromScale(math.clamp(v / badge.goal, 0, 1), 1)
			r.fill.BackgroundColor3 = has and Color3.fromRGB(110, 200, 80) or Color3.fromRGB(230, 96, 20)
			r.count.Text = has and "DONE" or (v .. " / " .. badge.goal)
			r.reward.Text = has and "UNLOCKED" or ("$" .. badge.reward)
			r.reward.TextColor3 = has and tier.color or Color3.fromRGB(150, 220, 110)
			r.name.TextColor3 = has and tier.color or Grunge.PAPER
			r.ring.Color = has and tier.color or Color3.fromRGB(70, 62, 55)
			r.num.TextColor3 = has and tier.color or Color3.fromRGB(90, 80, 72)
			r.img.ImageColor3 = has and Color3.new(1, 1, 1) or Color3.fromRGB(40, 36, 34)
			r.row.BackgroundTransparency = has and 0.35 or 0.55
		end
	end
	return got
end

local function refresh()
	if not gui then return end
	local seen = refreshMonsters()
	local got = refreshBadges()
	headCount.Text = string.format("%d / %d MONSTERS   -   %d / %d BADGES", seen, #Badges.entries, got, #Badges.list)
	monstersPage.Visible = tab == "monsters"
	badgesPage.Visible = tab == "badges"
end

local function buildMonsters(parent: Frame)
	local grid = Instance.new("ScrollingFrame")
	grid.BackgroundTransparency = 1; grid.BorderSizePixel = 0; grid.Position = UDim2.fromScale(0, 0); grid.Size = UDim2.fromScale(0.5, 1)
	grid.ScrollBarThickness = 6; grid.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grid.CanvasSize = UDim2.new(); grid.ZIndex = 10; grid.Parent = parent
	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.new(0.5, -8, 0, 74); gl.CellPadding = UDim2.fromOffset(8, 8); gl.SortOrder = Enum.SortOrder.LayoutOrder; gl.Parent = grid
	local gp = Instance.new("UIPadding"); gp.PaddingLeft = UDim.new(0, 3); gp.PaddingTop = UDim.new(0, 3); gp.PaddingRight = UDim.new(0, 8); gp.Parent = grid
	for i, e in Badges.entries do
		local b = Instance.new("TextButton")
		b.Text = ""; b.AutoButtonColor = true; b.BorderSizePixel = 0; b.BackgroundColor3 = Color3.fromRGB(14, 11, 10); b.BackgroundTransparency = 0.35
		b.LayoutOrder = i; b.ZIndex = 10; b.Parent = grid
		local stroke = Instance.new("UIStroke"); stroke.Color = Grunge.INK; stroke.Thickness = 2; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Parent = b
		local edge = Grunge.frame(b, { BackgroundTransparency = 0, BackgroundColor3 = DARK, Size = UDim2.new(0, 8, 1, 0), ZIndex = 11 })
		local name = Grunge.text(b, { Text = "", Font = Grunge.HORROR, Position = UDim2.new(0, 16, 0.06, 0), Size = UDim2.new(1, -22, 0.42, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
		local tag = Grunge.text(b, { Text = "", Font = Grunge.TYPE, Position = UDim2.new(0, 16, 0.52, 0), Size = UDim2.new(0.38, 0, 0.22, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
		local count = Grunge.text(b, { Text = "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.2, 0, 0.4, 0), TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 11 })
		local stars = starRow(b, { Position = UDim2.new(0, 20, 0.78, 0), Size = UDim2.new(0.34, 0, 0.14, 0), ZIndex = 11 }, 12)
		cards[e.key] = { btn = b, name = name, tag = tag, count = count, stars = stars, edge = edge, stroke = stroke }
		b.MouseButton1Click:Connect(function()
			Sfx.play("Click")
			selected = e.key
			refresh()
		end)
	end
	-- the page on the right: the monster in 3D, then its text
	local right = Grunge.frame(parent, { Position = UDim2.fromScale(0.52, 0), Size = UDim2.fromScale(0.48, 1), ZIndex = 10 })
	view = Instance.new("ViewportFrame")
	view.BackgroundColor3 = Color3.fromRGB(58, 30, 26); view.BackgroundTransparency = 0; view.BorderSizePixel = 0
	view.Position = UDim2.fromScale(0, 0); view.Size = UDim2.fromScale(1, 0.56); view.ZIndex = 10
	view.Ambient = Color3.fromRGB(150, 140, 140); view.LightColor = Color3.fromRGB(255, 232, 205); view.LightDirection = Vector3.new(-0.6, -1, -0.8)
	view.Parent = right
	local vg = Instance.new("UIGradient")
	vg.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(70, 60, 60)); vg.Rotation = 90; vg.Parent = view
	local vs = Instance.new("UIStroke"); vs.Color = Grunge.INK; vs.Thickness = 4; vs.Parent = view
	viewCam = Instance.new("Camera")
	viewCam.FieldOfView = 40
	viewCam.Parent = view
	view.CurrentCamera = viewCam
	dTitle = Grunge.text(right, { Text = "", Font = Grunge.HORROR, Position = UDim2.fromScale(0, 0.575), Size = UDim2.fromScale(1, 0.1), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	dTag = Grunge.text(right, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.675), Size = UDim2.fromScale(0.48, 0.045), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	dAbility = Grunge.text(right, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.5, 0.675), Size = UDim2.fromScale(0.5, 0.045), TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = Color3.fromRGB(255, 150, 80), ZIndex = 11 })
	dDesc = Grunge.text(right, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.735), Size = UDim2.fromScale(1, 0.14), TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextColor3 = Color3.fromRGB(210, 200, 180), ZIndex = 11 })
	local tc = Instance.new("UITextSizeConstraint"); tc.MaxTextSize = 22; tc.MinTextSize = 10; tc.Parent = dDesc
	dCount = Grunge.text(right, { Text = "", Position = UDim2.fromScale(0, 0.89), Size = UDim2.fromScale(0.5, 0.06), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 11 })
	dStars = starRow(right, { Position = UDim2.fromScale(0.58, 0.895), Size = UDim2.fromScale(0.42, 0.05), ZIndex = 11 }, 12)
	dNext = Grunge.text(right, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.955), Size = UDim2.fromScale(1, 0.04), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = DIM, ZIndex = 11 })
end

local function buildBadges(parent: Frame)
	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.Size = UDim2.fromScale(1, 1)
	list.ScrollBarThickness = 8; list.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(); list.ZIndex = 10; list.Parent = parent
	local gl = Instance.new("UIGridLayout")
	gl.CellSize = UDim2.new(0.5, -10, 0, 92); gl.CellPadding = UDim2.fromOffset(10, 8); gl.SortOrder = Enum.SortOrder.LayoutOrder; gl.Parent = list
	local gp = Instance.new("UIPadding"); gp.PaddingLeft = UDim.new(0, 3); gp.PaddingTop = UDim.new(0, 3); gp.PaddingRight = UDim.new(0, 10); gp.Parent = list
	for i, badge in Badges.list do
		local row = Grunge.frame(list, { BackgroundTransparency = 0.55, BackgroundColor3 = Color3.fromRGB(10, 8, 7), LayoutOrder = i, ZIndex = 10 })
		local _, ring, numLabel, img = medal(row, badge, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromScale(0.2, 0.78), ZIndex = 11 })
		local name = Grunge.text(row, { Text = badge.name, Font = Grunge.HORROR, Position = UDim2.fromScale(0.235, 0.05), Size = UDim2.fromScale(0.52, 0.34), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
		local reward = Grunge.text(row, { Text = "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0.07, 0), Size = UDim2.fromScale(0.22, 0.3), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11 })
		Grunge.text(row, { Text = badge.text, Font = Grunge.TYPE, Position = UDim2.fromScale(0.235, 0.41), Size = UDim2.fromScale(0.74, 0.24), TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color3.fromRGB(200, 190, 170), ZIndex = 11 })
		local back = Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(28, 22, 19), Position = UDim2.fromScale(0.235, 0.72), Size = UDim2.fromScale(0.5, 0.16), ZIndex = 11 })
		local bs = Instance.new("UIStroke"); bs.Color = Grunge.INK; bs.Thickness = 2; bs.Parent = back
		local fill = Grunge.frame(back, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(230, 96, 20), Size = UDim2.fromScale(0, 1), ZIndex = 12 })
		local count = Grunge.text(row, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0.68, 0), Size = UDim2.fromScale(0.22, 0.25), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11 })
		badgeRows[badge.id] = { fill = fill, count = count, reward = reward, name = name, ring = ring, num = numLabel, img = img, row = row }
	end
end

-- POP-UPS ------------------------------------------------------------------------------------------------------
local queue = {} :: { () -> Frame }
local showing = false
local function pump()
	if showing then return end
	local make = table.remove(queue, 1)
	if not make then return end
	showing = true
	local card = make()
	card.Position = UDim2.new(0.5, 0, 0, -160)
	TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0.09, 0) }):Play()
	task.delay(3.6, function()
		local t = TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 0, -160) })
		t:Play()
		t.Completed:Wait()
		card:Destroy()
		showing = false
		pump()
	end)
end
local function popCard(accent: Color3): Frame
	local card = Grunge.frame(popGui, { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromScale(0.34, 0.12), BackgroundTransparency = 0.08, BackgroundColor3 = Color3.fromRGB(18, 14, 12), ZIndex = 40 })
	local sc = Instance.new("UISizeConstraint"); sc.MinSize = Vector2.new(300, 84); sc.MaxSize = Vector2.new(560, 130); sc.Parent = card
	local st = Instance.new("UIStroke"); st.Color = accent; st.Thickness = 3; st.Parent = card
	Grunge.frame(card, { BackgroundTransparency = 0, BackgroundColor3 = accent, Size = UDim2.new(1, 0, 0, 5), ZIndex = 41 })
	return card
end

function BestiaryUI.unlocked(badgeId: string)
	local badge = Badges.byId[badgeId]
	if not badge or not popGui then return end
	local tier = Badges.tiers[badge.tier] or Badges.tiers[1]
	table.insert(queue, function()
		local card = popCard(tier.color)
		medal(card, badge, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.53, 0), Size = UDim2.fromScale(0.2, 0.72), ZIndex = 41 })
		Grunge.text(card, { Text = tier.name .. " BADGE UNLOCKED", Font = Grunge.TYPE, Position = UDim2.fromScale(0.24, 0.1), Size = UDim2.fromScale(0.72, 0.22), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = tier.color, ZIndex = 41 })
		Grunge.text(card, { Text = badge.name, Font = Grunge.HORROR, Position = UDim2.fromScale(0.24, 0.32), Size = UDim2.fromScale(0.72, 0.38), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 41 })
		Grunge.text(card, { Text = badge.text .. "   +$" .. badge.reward, Font = Grunge.TYPE, Position = UDim2.fromScale(0.24, 0.72), Size = UDim2.fromScale(0.72, 0.2), TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 41 })
		Sfx.play("Cash", { PlaybackSpeed = 0.8 })
		return card
	end)
	pump()
end

function BestiaryUI.discovered(key: string)
	local e = Badges.entryByKey[key]
	if not e or not popGui then return end
	table.insert(queue, function()
		local card = popCard(e.color)
		Grunge.text(card, { Text = "NEW BESTIARY ENTRY", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.12), Size = UDim2.fromScale(0.9, 0.22), TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = e.color:Lerp(Color3.new(1, 1, 1), 0.3), ZIndex = 41 })
		Grunge.text(card, { Text = e.title, Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.34), Size = UDim2.fromScale(0.9, 0.4), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 41 })
		Grunge.text(card, { Text = "READ ITS PAGE AT THE BESTIARY IN THE PARK", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.74), Size = UDim2.fromScale(0.9, 0.18), TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = DIM, ZIndex = 41 })
		Sfx.play("Click", { PlaybackSpeed = 0.7 })
		return card
	end)
	pump()
end

function BestiaryUI.init(toggle: (boolean) -> ())
	onToggle = toggle
	local pg = lp:WaitForChild("PlayerGui")
	popGui = Instance.new("ScreenGui")
	popGui.Name = "GoalPopups"; popGui.ResetOnSpawn = false; popGui.IgnoreGuiInset = true; popGui.DisplayOrder = 30
	popGui.Parent = pg
	gui = Instance.new("ScreenGui")
	gui.Name = "BestiaryUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Enabled = false; gui.DisplayOrder = 7
	gui.Parent = pg
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.78, 0.86), Rotation = 0 }, 61)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.55; ar.Parent = panel
	Grunge.text(panel, { Text = "BESTIARY", Font = Grunge.HORROR, Position = UDim2.fromScale(0.035, 0.02), Size = UDim2.fromScale(0.4, 0.09), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 110, 60), ZIndex = 10 })
	headCount = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.035, 0.108), Size = UDim2.fromScale(0.6, 0.035), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 10 })
	local close = button(panel, "LEAVE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.965, 0.035), Size = UDim2.fromScale(0.15, 0.06), ZIndex = 12, Rotation = 1.5, BackgroundColor3 = DARK, Modal = true })
	close.MouseButton1Click:Connect(function() Sfx.play("Click"); BestiaryUI.close() end)
	local tabs = Grunge.frame(panel, { Position = UDim2.fromScale(0.035, 0.158), Size = UDim2.fromScale(0.93, 0.06), ZIndex = 10 })
	local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0.01, 0); tl.Parent = tabs
	for i, t in { { "MONSTERS", "monsters", Color3.fromRGB(110, 30, 24) }, { "BADGES", "badges", Color3.fromRGB(120, 92, 26) } } do
		local b = button(tabs, t[1] :: string, { Size = UDim2.fromScale(0.5 - 0.005, 1), BackgroundColor3 = t[3], ZIndex = 11, LayoutOrder = i })
		b.MouseButton1Click:Connect(function() Sfx.play("Click"); tab = t[2] :: string; refresh() end)
	end
	monstersPage = Grunge.frame(panel, { Position = UDim2.fromScale(0.035, 0.24), Size = UDim2.fromScale(0.93, 0.72), ZIndex = 10 })
	badgesPage = Grunge.frame(panel, { Position = UDim2.fromScale(0.035, 0.24), Size = UDim2.fromScale(0.93, 0.72), ZIndex = 10, Visible = false })
	buildMonsters(monstersPage)
	buildBadges(badgesPage)
	for _, a in { "Bestiary", "Badges", "Kills", "GhostLevel", "NightmareKills" } do
		lp:GetAttributeChangedSignal(a):Connect(function() if gui.Enabled then refresh() end end)
	end
	-- the monster turns slowly while the panel is open
	RunService.RenderStepped:Connect(function()
		if not gui.Enabled or tab ~= "monsters" or not viewModel then return end
		local a = os.clock() * 0.5
		local eye = viewLook + Vector3.new(math.sin(a) * viewDist, viewDist * 0.12, math.cos(a) * viewDist)
		viewCam.CFrame = CFrame.lookAt(eye, viewLook)
	end)
	-- Studio test hooks: player attribute BestiaryTab = "monsters" | "badges" opens the panel on that tab,
	-- BestiarySelect = an entry's key shows that page
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("BestiaryTab"):Connect(function()
			local t = lp:GetAttribute("BestiaryTab")
			if t == "monsters" or t == "badges" then tab = t; BestiaryUI.open() end
		end)
		lp:GetAttributeChangedSignal("BestiarySelect"):Connect(function()
			local k = lp:GetAttribute("BestiarySelect")
			if type(k) == "string" and Badges.entryByKey[k] then selected = k; refresh() end
		end)
	end
end

function BestiaryUI.open()
	if not gui then return end
	if not registered then registered = true; Platform.menu(panel, BestiaryUI.close) end
	refresh()
	gui.Enabled = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end

function BestiaryUI.close()
	gui.Enabled = false
	if onToggle then onToggle(false) end
end

function BestiaryUI.isOpen(): boolean return gui ~= nil and gui.Enabled end

return BestiaryUI
