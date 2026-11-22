--!strict
-- TRADING (Server/Trade): swap cash and forms (jar forms = Doc Mercy's ectoplasm, potion forms = Mother Moth's) with
-- another player in the park. Ways in: the TRADE button in the lobby's left column (a list of the players here), or
-- the "Trade" prompt over another player (T). The other player gets a request (ACCEPT / NO), then both see the TRADE
-- window: YOUR OFFER and THEIR OFFER at the top, your own jars / potions below (tap one to add a copy, tap it in your
-- offer to take it back), the cash box and READY. Any change unreadies both and locks READY for a few seconds; when
-- both are READY a 3 s countdown runs, then the server swaps everything.
-- Studio hooks (player attributes): DebugTrade = "pick" opens the player list, "bot" asks the server for the TRADE
-- BOT (admin "trade bot"); DebugTradeAct = "add:<formId>" | "remove:<formId>" | "cash:<n>" | "ready" | "unready" |
-- "cancel" | "tab:jars" | "tab:potions" (set something else first to repeat one).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Forms = require(RS.Shared.Forms)
local Grunge = require(script.Parent.Grunge)
local VialArt = require(script.Parent.VialArt)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")
local TradeRemote = Remotes:WaitForChild("Trade") :: RemoteEvent

local TradeUI = {}
local lp = Players.LocalPlayer

local RED = Color3.fromRGB(150, 18, 20)
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local GOLD = Color3.fromRGB(176, 150, 40)
local GREY = Color3.fromRGB(70, 64, 58)
local MUTED = Color3.fromRGB(190, 180, 160)

local gui: ScreenGui
local pickPanel: Frame
local pickList: ScrollingFrame
local reqPop: Frame
local reqText: TextLabel
local reqBar: Frame
local win: Frame
local title: TextLabel
local myBox: ScrollingFrame
local theirBox: ScrollingFrame
local myCash: TextLabel
local theirCash: TextLabel
local myState: TextLabel
local theirState: TextLabel
local invGrid: ScrollingFrame
local cashBox: TextBox
local readyBtn: TextButton
local status: TextLabel
local tabBtns = {} :: { [string]: TextButton }
local onToggle: ((boolean) -> ())? = nil

local state: any = nil -- the server's last view of the trade
local tab = "stim" -- the inventory tab (stim = jars, potion = potions)
local myOffer = { cash = 0, forms = {} :: { [string]: number } } -- what this client last sent
local reqFrom: number? = nil
local seedN = 400

-- a brush button like the lobby's (Client/LobbyUI)
local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	seedN += 1
	local z = props.ZIndex or 1
	local col = props.BackgroundColor3 or RED
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
local function setText(b: TextButton, text: string) (b:FindFirstChild("Label") :: TextLabel).Text = text end
local function paint(b: TextButton, c: Color3)
	local br = b:FindFirstChild("Brush")
	if br then Grunge.paint(br, c) end
end
local function heading(parent: Instance, text: string, x: number, y: number, w: number, z: number): TextLabel
	local t = Grunge.text(parent, { Text = text, Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, 0.05), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1.2, ZIndex = z + 1 })
	seedN += 1
	Grunge.brush(parent, { Position = UDim2.fromScale(x, y + 0.047), Size = UDim2.fromScale(w * 0.4, 0.01), ZIndex = z }, RED, seedN, 10, false)
	return t
end

local function money(n: number): string
	local s = tostring(math.floor(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if out:sub(1, 1) == "," then out = out:sub(2) end
	return "$" .. out
end
-- "2.5k", "1m", "300" -> number
local function parseCash(text: string): number
	local n, suf = string.match(string.lower((text:gsub("[%$,%s]", ""))), "^([%d%.]+)([kmb]?)$")
	local v = tonumber(n)
	if not v then return 0 end
	return math.floor(v * (({ k = 1e3, m = 1e6, b = 1e9 } :: any)[suf] or 1))
end

-- what I own: { [formId] = copies }
local function owned(): { [string]: number }
	local out = {} :: { [string]: number }
	for id in string.gmatch(lp:GetAttribute("Forms") or "", "[^,]+") do out[id] = 1 end
	local ok, copies = pcall(function() return HttpService:JSONDecode(lp:GetAttribute("FormN") or "{}") end)
	if ok and type(copies) == "table" then
		for id, n in copies do if out[id] and tonumber(n) then out[id] = tonumber(n) :: number end end
	end
	return out
end

-- the jar / bottle a form comes out of (its set's first vial of that kind, in the form's colour)
local function vialFor(fm: Forms.Form): Forms.Vial
	for _, v in Forms.vials do
		if v.kind == fm.kind and v.set == fm.set then
			local c = table.clone(v) :: any
			c.color = fm.color
			c.id = "_trade" -- (no picture: the drawn jar in the form's colour)
			return c
		end
	end
	return Forms.vials[1]
end

-- one form tile: the jar / bottle, the name, the rarity, x copies. tag = small corner text ("OWNED")
local function tile(parent: Instance, fm: Forms.Form, n: number, z: number, tag: string?, onClick: (() -> ())?): TextButton
	local rr = Forms.rarity[fm.rarity]
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundColor3 = Color3.fromRGB(26, 21, 18); b.Text = ""
	b.ZIndex = z; b.Name = fm.id
	b.Parent = parent
	local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0.08, 0); cr.Parent = b
	local st = Instance.new("UIStroke"); st.Color = rr.color; st.Thickness = fm.rarity >= 4 and 3 or 2; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	local glow = Instance.new("Frame")
	glow.BorderSizePixel = 0; glow.BackgroundColor3 = rr.color; glow.BackgroundTransparency = 0.82; glow.Size = UDim2.fromScale(1, 0.62); glow.ZIndex = z
	glow.Parent = b
	local gc = Instance.new("UICorner"); gc.CornerRadius = UDim.new(0.08, 0); gc.Parent = glow
	VialArt.draw(b, vialFor(fm), { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.04), Size = UDim2.fromScale(0.62, 0.52), ZIndex = z + 1 })
	Grunge.text(b, { Text = fm.name, Font = Grunge.FONT, Position = UDim2.fromScale(0.04, 0.6), Size = UDim2.fromScale(0.92, 0.17), ZIndex = z + 4 })
	Grunge.text(b, { Text = rr.name, Font = Grunge.TYPE, TextColor3 = rr.color, Position = UDim2.fromScale(0.04, 0.78), Size = UDim2.fromScale(0.92, 0.12), ZIndex = z + 4 })
	if n > 1 then
		Grunge.text(b, { Text = "x" .. n, Font = Grunge.FONT, TextColor3 = Color3.fromRGB(255, 220, 120), AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(0.97, 0.02), Size = UDim2.fromScale(0.42, 0.18), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = z + 5 })
	end
	if tag then
		Grunge.text(b, { Text = tag, Font = Grunge.FONT, TextColor3 = tag == "NEW!" and Color3.fromRGB(150, 220, 110) or MUTED, Position = UDim2.fromScale(0.04, 0.02), Size = UDim2.fromScale(0.6, 0.16),
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = z + 5 })
	end
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1.05 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.1), { Scale = 1 }):Play() end)
	if onClick then b.Activated:Connect(onClick) end
	return b
end

local function grid(parent: Instance, props: { [string]: any }, cols: number): ScrollingFrame
	local s = Instance.new("ScrollingFrame")
	s.BackgroundColor3 = Color3.fromRGB(14, 11, 10); s.BackgroundTransparency = 0.35; s.BorderSizePixel = 0
	s.ScrollBarThickness = 6; s.ScrollBarImageColor3 = MUTED; s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.CanvasSize = UDim2.new(); s.ScrollingDirection = Enum.ScrollingDirection.Y
	for k, v in props do (s :: any)[k] = v end
	s.Parent = parent
	local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 6); pad.PaddingTop = UDim.new(0, 6); pad.PaddingRight = UDim.new(0, 10); pad.Parent = s
	local g = Instance.new("UIGridLayout"); g.SortOrder = Enum.SortOrder.LayoutOrder; g.CellPadding = UDim2.fromOffset(6, 6); g.Parent = s
	local function fit()
		local w = s.AbsoluteSize.X - 16
		local cw = math.floor((w - 6 * (cols - 1)) / cols)
		g.CellSize = UDim2.fromOffset(math.max(20, cw), math.max(24, math.floor(cw * 1.15)))
	end
	s:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()
	return s
end
local function clear(s: Instance)
	for _, c in s:GetChildren() do if c:IsA("GuiButton") or (c:IsA("TextLabel")) then c:Destroy() end end
end
-- sorted: best rarity first, then name
local function sortedIds(t: { [string]: number }, kind: string?): { string }
	local out = {}
	for id in t do
		local fm = Forms.byId[id]
		-- (an exclusive form, a code's, can't be traded: Server/Trade refuses it)
		if fm and not fm.exclusive and (kind == nil or fm.kind == kind) then table.insert(out, id) end
	end
	table.sort(out, function(a, b)
		local fa, fb = Forms.byId[a], Forms.byId[b]
		if fa.rarity ~= fb.rarity then return fa.rarity > fb.rarity end
		return fa.name < fb.name
	end)
	return out
end

local sendToken = 0
local lastLocal = 0 -- os.clock() of my last change (the server's copy of my offer is taken after a quiet moment)
local function send()
	lastLocal = os.clock()
	sendToken += 1
	local tok = sendToken
	task.delay(0.12, function()
		if tok ~= sendToken or not state then return end
		TradeRemote:FireServer("offer", { cash = myOffer.cash, forms = myOffer.forms })
	end)
end

local render: () -> ()
local function addForm(id: string)
	local have = owned()[id] or 0
	local cur = myOffer.forms[id] or 0
	if cur >= have then Sfx.play("Click", { PlaybackSpeed = 0.6 }); return end
	local n = 0
	for _ in myOffer.forms do n += 1 end
	if cur == 0 and n >= 12 then return end
	myOffer.forms[id] = cur + 1
	Sfx.play("Click")
	render(); send()
end
local function removeForm(id: string)
	local cur = myOffer.forms[id] or 0
	if cur <= 0 then return end
	myOffer.forms[id] = cur > 1 and cur - 1 or nil
	Sfx.play("Click", { PlaybackSpeed = 0.85 })
	render(); send()
end
local function setCash(n: number)
	local have = tonumber(lp:GetAttribute("Cash")) or 0
	myOffer.cash = math.clamp(math.floor(n), 0, math.max(0, have))
	render(); send()
end

render = function()
	if not state or not win then return end
	local mine = owned()
	-- YOUR OFFER (what this client is sending: shown at once, the server's copy follows)
	clear(myBox)
	for i, id in sortedIds(myOffer.forms) do
		local t = tile(myBox, Forms.byId[id], myOffer.forms[id], 14, nil, function() removeForm(id) end)
		t.LayoutOrder = i
	end
	myCash.Text = "CASH: " .. money(myOffer.cash)
	-- THEIR OFFER
	clear(theirBox)
	local theirForms = (state.them and state.them.forms) or {}
	for i, id in sortedIds(theirForms) do
		local fm = Forms.byId[id]
		local t = tile(theirBox, fm, theirForms[id], 14, mine[id] and "YOU OWN IT" or "NEW!", nil)
		t.LayoutOrder = i
	end
	theirCash.Text = "CASH: " .. money(state.them and state.them.cash or 0)
	-- my jars / potions (minus what is in the offer)
	clear(invGrid)
	local any = false
	for i, id in sortedIds(mine, tab) do
		local left = mine[id] - (myOffer.forms[id] or 0)
		if left <= 0 then continue end
		any = true
		local t = tile(invGrid, Forms.byId[id], left, 14, nil, function() addForm(id) end)
		t.LayoutOrder = i
	end
	if not any then
		Grunge.text(invGrid, { Text = tab == "stim" and "NO JAR FORMS TO TRADE" or "NO POTION FORMS TO TRADE", Font = Grunge.TYPE, TextColor3 = MUTED,
			Size = UDim2.fromOffset(260, 40), ZIndex = 14 })
	end
	for k, b in tabBtns do paint(b, k == tab and RED or DARK) end
	-- ready marks and the status line
	local meReady = state.me and state.me.ready
	local themReady = state.them and state.them.ready
	myState.Text = meReady and "READY" or "NOT READY"
	myState.TextColor3 = meReady and Color3.fromRGB(150, 220, 110) or MUTED
	theirState.Text = themReady and "READY" or "NOT READY"
	theirState.TextColor3 = themReady and Color3.fromRGB(150, 220, 110) or MUTED
	title.Text = "TRADE WITH " .. string.upper(state.partner or "?")
end

-- the timers (lock / final countdown) and the READY button
local function tick()
	if not state or not win or not win.Visible then return end
	local now = workspace:GetServerTimeNow()
	local lock = (state.lock or 0) - now
	local final = (state.final or 0) > 0 and (state.final - now) or -1
	local meReady = state.me and state.me.ready
	if final >= 0 then
		status.Text = "TRADING IN " .. math.max(1, math.ceil(final)) .. "...  (UNREADY TO STOP IT)"
		status.TextColor3 = Color3.fromRGB(255, 220, 120)
	elseif lock > 0 then
		status.Text = "OFFER CHANGED - CHECK IT  (" .. math.ceil(lock) .. ")"
		status.TextColor3 = Color3.fromRGB(255, 150, 80)
	elseif meReady then
		status.Text = "WAITING FOR " .. string.upper(state.partner or "THEM") .. " TO BE READY"
		status.TextColor3 = MUTED
	else
		status.Text = "PRESS READY WHEN THE TRADE LOOKS GOOD"
		status.TextColor3 = MUTED
	end
	if meReady then
		setText(readyBtn, "UNREADY"); paint(readyBtn, DARK)
	elseif lock > 0 then
		setText(readyBtn, "WAIT " .. math.ceil(lock)); paint(readyBtn, GREY)
	else
		setText(readyBtn, "READY"); paint(readyBtn, GREEN)
	end
end

local function showWindow(on: boolean)
	if not win then return end
	if on and not win.Visible then
		win.Visible = true
		win:SetAttribute("OpenedAt", os.clock())
		local s = win:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		s.Parent = win; s.Scale = 0.7
		TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		if onToggle then onToggle(true) end
	elseif not on and win.Visible then
		win.Visible = false
		if onToggle then onToggle(false) end
	end
end

local function refreshPick()
	clear(pickList)
	for _, c in pickList:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
	local n = 0
	for _, p in Players:GetPlayers() do
		if p == lp then continue end
		n += 1
		local row = Grunge.frame(pickList, { Size = UDim2.new(1, -10, 0, 54), BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(30, 24, 20), LayoutOrder = n, ZIndex = 13 })
		Grunge.text(row, { Text = string.upper(p.DisplayName), Position = UDim2.fromScale(0.03, 0.1), Size = UDim2.fromScale(0.55, 0.5), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
		local busy = p:GetAttribute("InMatch") and "IN A FIGHT" or (p:GetAttribute("Trading") and "TRADING" or ("LEVEL " .. tostring(p:GetAttribute("Level") or 1)))
		Grunge.text(row, { Text = busy, Font = Grunge.TYPE, TextColor3 = MUTED, Position = UDim2.fromScale(0.03, 0.6), Size = UDim2.fromScale(0.55, 0.32), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
		local b = button(row, "TRADE", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.97, 0.5), Size = UDim2.fromScale(0.3, 0.78), BackgroundColor3 = GOLD, ZIndex = 15 })
		b.Activated:Connect(function()
			Sfx.play("Click")
			TradeRemote:FireServer("request", p.UserId)
			pickPanel.Visible = false
			if onToggle then onToggle(false) end
		end)
	end
	if n == 0 then
		Grunge.text(pickList, { Text = "NOBODY ELSE IS IN THIS SERVER RIGHT NOW", Font = Grunge.TYPE, TextColor3 = MUTED, Size = UDim2.new(1, -10, 0, 50), ZIndex = 14 })
	end
end

function TradeUI.openPicker()
	if not pickPanel or lp:GetAttribute("InMatch") then return end
	if state then showWindow(true); return end
	refreshPick()
	pickPanel.Visible = true
	pickPanel:SetAttribute("OpenedAt", os.clock())
	local s = pickPanel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = pickPanel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end

local function onRequest(fromId: number, fromName: string)
	if lp:GetAttribute("InMatch") or state then return end
	reqFrom = fromId
	reqText.Text = string.upper(fromName) .. " WANTS TO TRADE"
	reqPop.Visible = true
	Sfx.play("Cash", { PlaybackSpeed = 1.3, Volume = 0.6 })
	reqBar.Size = UDim2.fromScale(1, 1)
	TweenService:Create(reqBar, TweenInfo.new(19, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) }):Play()
	local id = fromId
	task.delay(19, function() if reqFrom == id then reqFrom = nil; reqPop.Visible = false end end)
end

local function onState(v: any)
	local fresh = state == nil
	state = v
	if fresh then
		-- a new trade: start from what the server says I offer (nothing), close the other windows
		myOffer = { cash = (v.me and v.me.cash) or 0, forms = table.clone((v.me and v.me.forms) or {}) }
		reqPop.Visible = false; reqFrom = nil
		pickPanel.Visible = false
		cashBox.Text = ""
		Sfx.play("Cash", { PlaybackSpeed = 1.1, Volume = 0.5 })
	elseif os.clock() - lastLocal > 0.6 then
		-- (the server's copy of my offer wins when nothing of mine is on its way: a refused offer goes back)
		myOffer = { cash = (v.me and v.me.cash) or 0, forms = table.clone((v.me and v.me.forms) or {}) }
	end
	showWindow(true)
	render()
	tick()
end

local function onClosed(text: string, done: boolean)
	state = nil
	myOffer = { cash = 0, forms = {} }
	showWindow(false)
	local HUD = require(script.Parent.HUD)
	HUD.toast(text, done and true or false)
	if done then
		Sfx.play("Cash", { Volume = 0.9 })
		pcall(function() (HUD :: any).flash(Color3.fromRGB(255, 220, 120), 0.3) end)
	end
end

-- the "Trade" prompt over the other players (in the park only)
local function promptFor(p: Player)
	local function attach(ch: Model)
		local hrp = ch:WaitForChild("HumanoidRootPart", 10)
		if not hrp then return end
		local pp = Instance.new("ProximityPrompt")
		pp.Name = "TradePrompt"; pp.ActionText = "Trade"; pp.ObjectText = p.DisplayName
		pp.KeyboardKeyCode = Enum.KeyCode.T; pp.HoldDuration = 0.25; pp.MaxActivationDistance = 10
		pp.RequiresLineOfSight = false; pp.Style = Enum.ProximityPromptStyle.Custom
		pp.Enabled = not lp:GetAttribute("InMatch") and not p:GetAttribute("InMatch")
		pp.Parent = hrp
		pp.Triggered:Connect(function()
			if lp:GetAttribute("InMatch") or state then return end
			TradeRemote:FireServer("request", p.UserId)
		end)
		local function upd() pp.Enabled = not lp:GetAttribute("InMatch") and not p:GetAttribute("InMatch") end
		lp:GetAttributeChangedSignal("InMatch"):Connect(upd)
		p:GetAttributeChangedSignal("InMatch"):Connect(upd)
	end
	p.CharacterAdded:Connect(attach)
	if p.Character then task.spawn(attach, p.Character) end
end

function TradeUI.init(toggled: ((boolean) -> ())?)
	onToggle = toggled
	gui = Instance.new("ScreenGui")
	gui.Name = "TradeUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- PLAYER LIST
	pickPanel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.36, 0.62), Visible = false, ZIndex = 10 },
		Color3.fromRGB(21, 17, 15), 71, 6, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 0.95; par.Parent = pickPanel
	Grunge.text(pickPanel, { Text = "TRADE WITH...", Font = Grunge.HORROR, Position = UDim2.fromScale(0.06, 0.03), Size = UDim2.fromScale(0.6, 0.11), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
	Grunge.text(pickPanel, { Text = "SWAP CASH, JAR FORMS AND POTION FORMS", Font = Grunge.TYPE, TextColor3 = MUTED, Position = UDim2.fromScale(0.06, 0.14), Size = UDim2.fromScale(0.88, 0.05),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
	local pclose = button(pickPanel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.95, 0.035), Size = UDim2.fromScale(0.27, 0.085), BackgroundColor3 = DARK, ZIndex = 13 })
	pclose.Activated:Connect(function() Sfx.play("Click"); pickPanel.Visible = false; if onToggle then onToggle(false) end end)
	Platform.menu(pickPanel, function() pickPanel.Visible = false; if onToggle then onToggle(false) end end)
	pickList = Instance.new("ScrollingFrame")
	pickList.BackgroundTransparency = 1; pickList.BorderSizePixel = 0; pickList.Position = UDim2.fromScale(0.05, 0.22); pickList.Size = UDim2.fromScale(0.9, 0.74)
	pickList.ScrollBarThickness = 6; pickList.AutomaticCanvasSize = Enum.AutomaticSize.Y; pickList.CanvasSize = UDim2.new(); pickList.ZIndex = 12
	pickList.Parent = pickPanel
	local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 6); pl.SortOrder = Enum.SortOrder.LayoutOrder; pl.Parent = pickList

	-- REQUEST POPUP (top middle)
	reqPop = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.11), Size = UDim2.fromScale(0.34, 0.13), Visible = false, ZIndex = 40 },
		Color3.fromRGB(26, 20, 16), 77, 3, false)
	local rar = Instance.new("UIAspectRatioConstraint"); rar.AspectRatio = 3.6; rar.Parent = reqPop
	reqText = Grunge.text(reqPop, { Text = "", Position = UDim2.fromScale(0.05, 0.08), Size = UDim2.fromScale(0.9, 0.36), ZIndex = 42 })
	local yes = button(reqPop, "ACCEPT", { Position = UDim2.fromScale(0.08, 0.5), Size = UDim2.fromScale(0.4, 0.34), BackgroundColor3 = GREEN, ZIndex = 43 })
	local no = button(reqPop, "NO", { Position = UDim2.fromScale(0.52, 0.5), Size = UDim2.fromScale(0.4, 0.34), BackgroundColor3 = DARK, ZIndex = 43 })
	local barBg = Grunge.frame(reqPop, { Position = UDim2.fromScale(0.08, 0.89), Size = UDim2.fromScale(0.84, 0.05), BackgroundTransparency = 0.5, BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 42 })
	reqBar = Grunge.frame(barBg, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0, BackgroundColor3 = GOLD, ZIndex = 43 })
	yes.Activated:Connect(function()
		Sfx.play("Click")
		if reqFrom then TradeRemote:FireServer("answer", reqFrom, true) end
		reqFrom = nil; reqPop.Visible = false
	end)
	no.Activated:Connect(function()
		Sfx.play("Click")
		if reqFrom then TradeRemote:FireServer("answer", reqFrom, false) end
		reqFrom = nil; reqPop.Visible = false
	end)

	-- THE TRADE WINDOW
	win = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.53), Size = UDim2.fromScale(0.86, 0.86), Visible = false, ZIndex = 10 },
		Color3.fromRGB(21, 17, 15), 83, 7, false)
	local war = Instance.new("UIAspectRatioConstraint"); war.AspectRatio = 1.6; war.Parent = win
	title = Grunge.text(win, { Text = "TRADE", Font = Grunge.HORROR, Position = UDim2.fromScale(0.03, 0.02), Size = UDim2.fromScale(0.6, 0.085), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -0.8, ZIndex = 12 })
	local cancel = button(win, "CANCEL", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.97, 0.025), Size = UDim2.fromScale(0.14, 0.07), BackgroundColor3 = DARK, ZIndex = 13, Rotation = 1.2 })
	cancel.Activated:Connect(function() Sfx.play("Click"); TradeRemote:FireServer("cancel") end)
	Platform.menu(win, function() TradeRemote:FireServer("cancel") end)

	-- the two offers
	local function offerSide(x: number, label: string, color: Color3): (ScrollingFrame, TextLabel, TextLabel)
		heading(win, label, x, 0.11, 0.45, 12)
		local cashL = Grunge.text(win, { Text = "CASH: $0", Font = Grunge.FONT, TextColor3 = Color3.fromRGB(150, 220, 110), Position = UDim2.fromScale(x, 0.17), Size = UDim2.fromScale(0.25, 0.05),
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
		local st = Grunge.text(win, { Text = "NOT READY", Font = Grunge.FONT, TextColor3 = MUTED, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(x + 0.455, 0.12),
			Size = UDim2.fromScale(0.18, 0.05), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 12 })
		local box = grid(win, { Position = UDim2.fromScale(x, 0.23), Size = UDim2.fromScale(0.455, 0.31), ZIndex = 12 }, 5)
		local edge = Instance.new("UIStroke"); edge.Color = color; edge.Thickness = 2; edge.Transparency = 0.4; edge.Parent = box
		return box, cashL, st
	end
	myBox, myCash, myState = offerSide(0.03, "YOU GIVE", RED)
	theirBox, theirCash, theirState = offerSide(0.515, "THEY GIVE", GOLD)
	Grunge.text(win, { Text = "TAP A FORM IN YOUR OFFER TO TAKE IT BACK", Font = Grunge.TYPE, TextColor3 = MUTED, Position = UDim2.fromScale(0.03, 0.545), Size = UDim2.fromScale(0.45, 0.035),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

	-- your jars / potions
	heading(win, "YOUR FORMS", 0.03, 0.59, 0.3, 12)
	for i, k in { "stim", "potion" } do
		local b = button(win, k == "stim" and "JARS" or "POTIONS", { Position = UDim2.fromScale(0.25 + (i - 1) * 0.15, 0.585), Size = UDim2.fromScale(0.14, 0.06), BackgroundColor3 = DARK, ZIndex = 13 })
		b.Activated:Connect(function() Sfx.play("Click"); tab = k; render() end)
		tabBtns[k] = b
	end
	invGrid = grid(win, { Position = UDim2.fromScale(0.03, 0.66), Size = UDim2.fromScale(0.62, 0.31), ZIndex = 12 }, 7)

	-- cash + READY
	heading(win, "ADD CASH", 0.68, 0.59, 0.29, 12)
	local cashRow = Grunge.frame(win, { Position = UDim2.fromScale(0.68, 0.665), Size = UDim2.fromScale(0.29, 0.075), BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(12, 10, 9), ZIndex = 12 })
	local cst = Instance.new("UIStroke"); cst.Color = MUTED; cst.Thickness = 1.5; cst.Transparency = 0.5; cst.Parent = cashRow
	cashBox = Instance.new("TextBox")
	cashBox.BackgroundTransparency = 1; cashBox.Size = UDim2.fromScale(0.62, 1); cashBox.Position = UDim2.fromScale(0.04, 0); cashBox.Text = ""
	cashBox.PlaceholderText = "$ amount"; cashBox.Font = Grunge.FONT; cashBox.TextScaled = true; cashBox.TextColor3 = Color3.fromRGB(150, 220, 110)
	cashBox.PlaceholderColor3 = Color3.fromRGB(110, 100, 90); cashBox.ClearTextOnFocus = false; cashBox.TextXAlignment = Enum.TextXAlignment.Left; cashBox.ZIndex = 13
	cashBox.Parent = cashRow
	local setB = button(cashRow, "SET", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.99, 0.5), Size = UDim2.fromScale(0.32, 0.86), BackgroundColor3 = GREEN, ZIndex = 14 })
	local function applyCash()
		setCash(parseCash(cashBox.Text))
		cashBox.Text = myOffer.cash > 0 and tostring(myOffer.cash) or ""
	end
	cashBox.FocusLost:Connect(function(enter) if enter then applyCash() end end)
	setB.Activated:Connect(function() Sfx.play("Click"); applyCash() end)
	readyBtn = button(win, "READY", { Position = UDim2.fromScale(0.68, 0.76), Size = UDim2.fromScale(0.29, 0.11), BackgroundColor3 = GREEN, ZIndex = 13, Rotation = -0.8 })
	readyBtn.Activated:Connect(function()
		if not state then return end
		Sfx.play("Click")
		TradeRemote:FireServer("ready", not (state.me and state.me.ready))
	end)
	status = Grunge.text(win, { Text = "", Font = Grunge.TYPE, TextColor3 = MUTED, Position = UDim2.fromScale(0.68, 0.885), Size = UDim2.fromScale(0.29, 0.085), TextWrapped = true, ZIndex = 12 })

	TradeRemote.OnClientEvent:Connect(function(kind: string, a: any, b: any)
		if kind == "request" then onRequest(a, b)
		elseif kind == "state" then onState(a)
		elseif kind == "closed" then onClosed(a, b)
		end
	end)
	-- my forms or cash changed (a seller, a run's reward): the lists follow
	lp:GetAttributeChangedSignal("Forms"):Connect(function() if state then render() end end)
	lp:GetAttributeChangedSignal("FormN"):Connect(function() if state then render() end end)
	lp:GetAttributeChangedSignal("InMatch"):Connect(function()
		if lp:GetAttribute("InMatch") then pickPanel.Visible = false; reqPop.Visible = false end
	end)
	RunService.Heartbeat:Connect(tick)
	for _, p in Players:GetPlayers() do if p ~= lp then promptFor(p) end end
	Players.PlayerAdded:Connect(promptFor)
	Players.PlayerAdded:Connect(function() if pickPanel.Visible then refreshPick() end end)
	Players.PlayerRemoving:Connect(function() if pickPanel.Visible then task.defer(refreshPick) end end)

	-- Studio test hooks
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugTrade"):Connect(function()
			local v = lp:GetAttribute("DebugTrade")
			if v == "pick" then TradeUI.openPicker()
			elseif v == "bot" then
				local rf = Remotes:FindFirstChild("Admin") :: RemoteFunction?
				if rf then task.spawn(function() pcall(function() (rf :: RemoteFunction):InvokeServer("trade bot") end) end) end
			end
		end)
		lp:GetAttributeChangedSignal("DebugTradeAct"):Connect(function()
			local v = tostring(lp:GetAttribute("DebugTradeAct") or "")
			local cmd, arg = string.match(v, "^(%a+):?(.*)$")
			if cmd == "add" then addForm(arg)
			elseif cmd == "remove" then removeForm(arg)
			elseif cmd == "cash" then setCash(tonumber(arg) or 0)
			elseif cmd == "ready" then TradeRemote:FireServer("ready", true)
			elseif cmd == "unready" then TradeRemote:FireServer("ready", false)
			elseif cmd == "cancel" then TradeRemote:FireServer("cancel")
			elseif cmd == "tab" then tab = arg == "potions" and "potion" or "stim"; render()
			end
		end)
	end
end

return TradeUI
