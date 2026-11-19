--!strict
-- OPEN OFFLINE, on screen (bottom middle): a card per kind that is opening (Doc Mercy's jars, Mother Moth's
-- potions; Server/Forms "offline"): the jar / potion (Client/VialArt) wobbling harder as it gets close, a bar filling
-- under it with the time left, how many wait in the queue, and ON TOP what it gave (rarity, name, NEW!) the moment
-- it opens. Under the cards: the 24 h RARE+ guarantee counting down. Hidden in a run (and while boarding the train,
-- in the jar cinematic or while a lobby window is open): the jars keep opening on the server, and what opened meanwhile (or while the player was
-- away from the game) comes back as one banner on top: WHILE YOU WERE AWAY / WHILE YOU WERE FIGHTING.
-- State: player attribute "Offline" (JSON: { stim = { q, t }, potion = { q, t }, pity }); results: Fx "OfflineDone".
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Forms = require(RS.Shared.Forms)
local Campaign = require(RS.Shared.Campaign)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local VialArt = require(script.Parent.VialArt)
local Platform = require(script.Parent.Platform)

local OO = {}
local lp = Players.LocalPlayer
local KINDS = { "stim", "potion" }
local HOLD = 8 -- seconds a card stays up after its last jar opened (its result on top)

type Card = {
	root: Frame, scale: UIScale, glow: Frame, artBox: Frame, art: Frame?, artVial: string,
	rarT: TextLabel, nameT: TextLabel, timeT: TextLabel, countT: TextLabel, bar: any, holdUntil: number, shown: boolean,
}

local gui: ScreenGui
local root: Frame
local row: Frame
local pityT: TextLabel
local banner: Frame
local bannerScale: UIScale
local bannerTitle: TextLabel
local bannerLines: { TextLabel } = {}
local bannerUntil = 0
local cards = {} :: { [string]: Card }
local state: any = {}
local pending = {} :: { any } -- results that came while the widget was hidden (a run)
local isBusy: (() -> boolean)? = nil

local function readState()
	local ok, t = pcall(function() return HttpService:JSONDecode(lp:GetAttribute("Offline") or "{}") end)
	state = ok and type(t) == "table" and t or {}
end

local function queueOf(kind: string): ({ string }, number)
	local k = state[kind]
	if type(k) ~= "table" or type(k.q) ~= "table" then return {}, 0 end
	return k.q, tonumber(k.t) or 0
end

local function hidden(): boolean
	if lp:GetAttribute("InMatch") or lp:GetAttribute("Boarding") or Platform.windowOpen() then return true end
	local ph = lp:GetAttribute("IntroPhase")
	if type(ph) == "string" and ph ~= "" and ph ~= "done" then return true end
	return isBusy ~= nil and isBusy()
end

local function newCard(kind: string, order: number): Card
	local c = Grunge.frame(row, { Name = kind, Size = UDim2.fromScale(0.47, 1), LayoutOrder = order, Visible = false, ZIndex = 2 })
	local sc = Instance.new("UIScale"); sc.Parent = c
	-- a dark painted plate behind the bottom half (the bar and the time stay readable over the park)
	Grunge.brush(c, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.7), Size = UDim2.fromScale(1, 0.3), ZIndex = 2 },
		Color3.fromRGB(21, 17, 15), 400 + order, 10, false)
	-- the glow behind the jar (its colour, pulsing)
	local glow = Grunge.frame(c, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.62, 0.62),
		BackgroundTransparency = 0.55, BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2 })
	local ga = Instance.new("UIAspectRatioConstraint"); ga.AspectRatio = 1; ga.Parent = glow
	local gc = Instance.new("UICorner"); gc.CornerRadius = UDim.new(0.5, 0); gc.Parent = glow
	local gg = Instance.new("UIGradient")
	gg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.55, 0.55), NumberSequenceKeypoint.new(1, 1) })
	gg.Parent = glow
	local artBox = Grunge.frame(c, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.62, 0.44), ZIndex = 3 })
	-- ON TOP: what it gave
	local rarT = Grunge.text(c, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.0), Size = UDim2.fromScale(0.98, 0.1), ZIndex = 6 })
	local nameT = Grunge.text(c, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.1), Size = UDim2.fromScale(0.98, 0.17), ZIndex = 6, Rotation = -2 })
	local countT = Grunge.text(c, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.74, 0.62), Size = UDim2.fromScale(0.3, 0.13),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Rotation = 6 })
	-- (the bar's empty track, lighter than the plate)
	Grunge.brush(c, { Position = UDim2.fromScale(0.06, 0.755), Size = UDim2.fromScale(0.88, 0.075), ZIndex = 3 }, Color3.fromRGB(70, 60, 52), 430 + order, 18, false)
	local bar = Grunge.bar(c, { size = UDim2.fromScale(0.88, 0.1), pos = UDim2.fromScale(0.06, 0.74), color = Color3.fromRGB(120, 200, 90), seed = 410 + order, slices = 18, outline = false })
	bar.root.ZIndex = 4
	for _, d in bar.root:GetDescendants() do if d:IsA("GuiObject") then d.ZIndex = math.max(d.ZIndex, 4) end end
	bar:set(0)
	local timeT = Grunge.text(c, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.85), Size = UDim2.fromScale(0.95, 0.12), ZIndex = 6 })
	return { root = c, scale = sc, glow = glow, artBox = artBox, art = nil, artVial = "", rarT = rarT, nameT = nameT, timeT = timeT, countT = countT,
		bar = bar, holdUntil = 0, shown = false }
end

-- the picture shows the jar / potion that is opening now
local function setArt(c: Card, v: Forms.Vial)
	if c.artVial == v.id then return end
	if c.art then c.art:Destroy() end
	c.art = VialArt.draw(c.artBox, v, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ZIndex = 3 })
	c.artVial = v.id
	c.glow.BackgroundColor3 = v.color
	c.bar:color(v.color)
end

local function pop(obj: Instance, from: number)
	local s = obj:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = obj
	s.Scale = from
	TweenService:Create(s, TweenInfo.new(0.45, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

-- a result on top of its card
local function showResult(r: any, extra: number)
	local c = cards[r.kind]
	local fm = Forms.byId[r.form]
	if not c or not fm then return end
	local rr = Forms.rarity[fm.rarity]
	c.rarT.Text = (r.pity and "24 H GUARANTEE!  " or "") .. rr.name .. (r.new and "  -  NEW!" or "") .. (extra > 0 and ("   +" .. extra .. " MORE") or "")
	c.rarT.TextColor3 = r.pity and Color3.fromRGB(255, 215, 90) or rr.color
	c.nameT.Text = fm.name
	c.nameT.TextColor3 = fm.color
	pop(c.nameT, fm.rarity >= 3 and 2.2 or 1.6)
	pop(c.rarT, 1.4)
	c.glow.BackgroundTransparency = 0
	TweenService:Create(c.glow, TweenInfo.new(0.8), { BackgroundTransparency = 0.55 }):Play()
	c.holdUntil = os.clock() + HOLD
	if fm.rarity >= 3 then Sfx.play("MagicBurst", { Volume = 0.7 }) else Sfx.play("FormMagic", { Volume = 0.6 }) end
end

-- the WHILE YOU WERE AWAY banner: how many opened and the best ones
local function showBanner(list: { any }, title: string)
	if #list == 0 then return end
	table.sort(list, function(a, b)
		local fa, fb = Forms.byId[a.form], Forms.byId[b.form]
		local ra, rb = fa and fa.rarity or 0, fb and fb.rarity or 0
		if ra ~= rb then return ra > rb end
		return (a.new and 1 or 0) > (b.new and 1 or 0)
	end)
	local newN = 0
	for _, r in list do if r.new then newN += 1 end end
	bannerTitle.Text = title .. ":  " .. #list .. " OPENED" .. (newN > 0 and ("  -  " .. newN .. " NEW") or "")
	for i, t in bannerLines do
		local r = list[i]
		local fm = r and Forms.byId[r.form]
		if fm then
			t.Text = Forms.rarity[fm.rarity].name .. "  " .. fm.name .. (r.new and "  NEW!" or "") .. (r.pity and "  (24 H GUARANTEE)" or "")
			t.TextColor3 = fm.color
		else
			t.Text = ""
		end
	end
	banner.Visible = true
	bannerScale.Scale = 0.6
	TweenService:Create(bannerScale, TweenInfo.new(0.4, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	bannerUntil = os.clock() + 10
	local best = Forms.byId[list[1].form]
	Sfx.play(best and best.rarity >= 3 and "MagicBurst" or "FormMagic", { Volume = 0.7 })
end

-- Fx "OfflineDone": results (in the order they opened), away = they opened while the player was not in the game
function OO.done(results: any, away: boolean?)
	if type(results) ~= "table" then return end
	if away then showBanner(table.clone(results), "WHILE YOU WERE AWAY"); return end
	if hidden() then
		for _, r in results do table.insert(pending, r) end
		return
	end
	-- the last one of each kind goes on top of its card ("+n more" when several opened at once)
	local last = {} :: { [string]: any }
	local count = {} :: { [string]: number }
	for _, r in results do
		last[r.kind] = r
		count[r.kind] = (count[r.kind] or 0) + 1
	end
	for kind, r in last do showResult(r, (count[kind] or 1) - 1) end
end

-- the RARE+ guarantee: finished opening time + the running ones
local function pityLeft(now: number): number
	local p = tonumber(state.pity) or 0
	for _, kind in KINDS do
		local q, t = queueOf(kind)
		local v = q[1] and Forms.vialById[q[1]]
		if v then p += math.clamp(now - t, 0, Forms.openTime(v)) end
	end
	return math.max(0, Forms.OFFLINE.pity - p)
end

local function step()
	local hide = hidden()
	local now = workspace:GetServerTimeNow()
	local clock = os.clock()
	local any = false
	for i, kind in KINDS do
		local c = cards[kind]
		local q, t = queueOf(kind)
		local v = q[1] and Forms.vialById[q[1]]
		local show = (v ~= nil or clock < c.holdUntil) and not hide
		if show ~= c.shown then
			c.shown = show
			c.root.Visible = show
			if show then pop(c.root, 0.5) end
		end
		if not show then continue end
		any = true
		if v then
			setArt(c, v)
			local dur = Forms.openTime(v)
			local f = math.clamp((now - t) / dur, 0, 1)
			c.bar:set(f, 1 / 30)
			c.timeT.Text = "OPENING  " .. Campaign.clock(dur - (now - t))
			c.countT.Text = #q > 1 and ("x" .. #q) or ""
			if c.rarT.Text == "" then
				c.rarT.Text = "???"
				c.rarT.TextColor3 = Grunge.PAPER
				c.nameT.Text = kind == "stim" and "WHAT'S IN THE JAR?" or "WHAT'S IN THE BOTTLE?"
				c.nameT.TextColor3 = Color3.fromRGB(190, 180, 160)
			end
			-- it wobbles harder as it gets close, and shakes in the last seconds
			if c.art then
				local amp = 3 + f * 9
				local speed = 3 + f * 9
				local shake = f > 0.9 and math.sin(clock * 60) * 4 or 0
				c.art.Rotation = math.sin(clock * speed + i) * amp + shake
				c.art.Position = UDim2.fromScale(0.5, 0.5 + math.sin(clock * speed * 0.5 + i) * 0.03)
			end
			c.glow.Size = UDim2.fromScale(0.62 + math.sin(clock * 2.4 + i) * 0.05 + f * 0.12, 0.62)
		else
			c.bar:set(1, 1 / 30)
			c.timeT.Text = "DONE!"
			c.countT.Text = ""
			if c.art then c.art.Rotation = 0 end
		end
	end
	root.Visible = any
	if any then
		pityT.Text = "RARE+ GUARANTEED AFTER " .. Campaign.clock(pityLeft(now)) .. " MORE OPENING"
	end
	banner.Visible = (not hide) and clock < bannerUntil
	-- back from a run: what opened meanwhile
	if not hide and #pending > 0 then
		local list = pending
		pending = {}
		showBanner(list, "WHILE YOU WERE FIGHTING")
	end
end

function OO.init(busy: (() -> boolean)?)
	isBusy = busy
	gui = Instance.new("ScreenGui")
	gui.Name = "OfflineOpen"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 2
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	root = Grunge.frame(gui, { Name = "Opening", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.985), Size = UDim2.fromScale(0.5, 0.26), Visible = false })
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.9; ar.Parent = root
	row = Grunge.frame(root, { Size = UDim2.fromScale(1, 0.88) })
	local rl = Instance.new("UIListLayout"); rl.FillDirection = Enum.FillDirection.Horizontal; rl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rl.Padding = UDim.new(0.04, 0); rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Parent = row
	for i, kind in KINDS do cards[kind] = newCard(kind, i) end
	pityT = Grunge.text(root, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.9), Size = UDim2.fromScale(0.9, 0.09),
		TextColor3 = Color3.fromRGB(255, 215, 90), ZIndex = 6 })
	-- the banner (on top of the cards)
	banner = Grunge.slab(gui, { Name = "Away", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 0.71), Size = UDim2.fromScale(0.36, 0.16), Visible = false, ZIndex = 3 },
		Color3.fromRGB(21, 17, 15), 420, 4, false)
	local bar2 = Instance.new("UIAspectRatioConstraint"); bar2.AspectRatio = 3.6; bar2.Parent = banner
	bannerScale = Instance.new("UIScale"); bannerScale.Parent = banner
	bannerTitle = Grunge.text(banner, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.05, 0.06), Size = UDim2.fromScale(0.9, 0.3), ZIndex = 6,
		TextColor3 = Color3.fromRGB(150, 200, 255), Rotation = -1 })
	for i = 1, 3 do
		bannerLines[i] = Grunge.text(banner, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.07, 0.36 + (i - 1) * 0.2), Size = UDim2.fromScale(0.86, 0.18), ZIndex = 6 })
	end
	readState()
	lp:GetAttributeChangedSignal("Offline"):Connect(function()
		local before = {} :: { [string]: number }
		for _, kind in KINDS do before[kind] = #(queueOf(kind)) end
		readState()
		-- a new jar went in: a little pop on its card
		for _, kind in KINDS do
			local q = queueOf(kind)
			if #q > (before[kind] or 0) and cards[kind].shown then pop(cards[kind].countT, 1.8) end
		end
	end)
	local acc = 0
	RunService.Heartbeat:Connect(function(dt)
		acc += dt
		if acc < 1 / 30 then return end
		acc = 0
		step()
	end)
end

return OO
