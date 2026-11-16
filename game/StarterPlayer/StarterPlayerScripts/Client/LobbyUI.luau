--!strict
-- Lobby screen (grunge, like the fight HUD): PLAY and SHOP buttons on the left, the friend booster tag, and the
-- PLAY panel: create a lobby (map you own, difficulty, 1-4 players) or join an open one, then the host presses START.
-- Lobbies live on the server (Lobby.luau, Remotes.Party); the list comes in the ReplicatedStorage attribute "Parties".
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Maps = require(RS.Shared.Maps)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local LobbyUI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local side: Frame
local panel: Frame
local boostTag: TextLabel
local createPage: Frame
local listFrame: ScrollingFrame
local mine: Frame
local mineInfo: TextLabel
local mineNames: TextLabel
local startBtn: TextButton
local status: TextLabel
local pickMap, pickDiff, pickSize = Maps.default, Maps.defaultDiff, 2
local pickPrivate = false
local privBtn: TextButton
local minePriv: TextButton
local inviteList: ScrollingFrame
local invitePop: Frame
local invitePopText: TextLabel
local invitePartyId: string? = nil
local mapBtns = {} :: { [string]: TextButton }
local diffBtns = {} :: { [string]: TextButton }
local sizeBtns = {} :: { [number]: TextButton }
local openShop: (() -> ())? = nil
local onToggle: ((boolean) -> ())? = nil

local RED = Color3.fromRGB(120, 24, 20)
local DARK = Color3.fromRGB(45, 40, 36)
local GREEN = Color3.fromRGB(60, 110, 50)

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

local function ownedMaps(): { [string]: boolean }
	local o = { Mansion = true }
	for id in string.gmatch(lp:GetAttribute("Owned") or "", "[^,]+") do
		local m = string.match(id, "^Map_(.+)$")
		if m then o[m] = true end
	end
	return o
end

local function parties(): { any }
	local ok, list = pcall(function() return HttpService:JSONDecode(RS:GetAttribute("Parties") or "[]") end)
	return ok and list or {}
end

-- big splatter button for the left column
local function bigButton(text: string, color: Color3, y: number, rot: number, onClick: () -> ()): TextButton
	local holder = Grunge.frame(side, { Position = UDim2.fromScale(0, y), Size = UDim2.fromScale(1, 0.26) })
	-- a rough painted slab: dark ink shadow, the colour on top, a lighter scratch, ink outline
	Grunge.frame(holder, { BackgroundTransparency = 0, BackgroundColor3 = Grunge.INK, Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.03, 0.08), Rotation = rot })
	local slab = Grunge.frame(holder, { BackgroundTransparency = 0, BackgroundColor3 = color, Size = UDim2.fromScale(1, 1), Rotation = rot, ZIndex = 2 })
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.12), color:Lerp(Color3.new(0, 0, 0), 0.35)); g.Rotation = 90; g.Parent = slab
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 4; st.Parent = slab
	Grunge.frame(slab, { BackgroundTransparency = 0.75, BackgroundColor3 = Grunge.PAPER, Size = UDim2.fromScale(0.85, 0.06), Position = UDim2.fromScale(0.06, 0.1), Rotation = -1, ZIndex = 3 })
	Grunge.splat(holder, { Size = UDim2.fromScale(0.5, 0.9), Position = UDim2.fromScale(0.65, -0.25), ImageColor3 = color:Lerp(Color3.new(0, 0, 0), 0.3), ImageTransparency = 0.2, Rotation = rot * 5, ZIndex = 1 })
	local b = Instance.new("TextButton")
	b.BackgroundTransparency = 1; b.Size = UDim2.fromScale(1, 1); b.Text = ""; b.ZIndex = 4
	b.Parent = holder
	Grunge.text(b, { Text = text, Font = Grunge.HORROR, Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.05, 0.1), Rotation = rot, TextColor3 = Grunge.PAPER, ZIndex = 5 })
	local scale = Instance.new("UIScale"); scale.Parent = holder
	b.MouseEnter:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Scale = 1.08 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(scale, TweenInfo.new(0.15), { Scale = 1 }):Play() end)
	b.Activated:Connect(function() Sfx.play("Click"); onClick() end)
	return b
end

local function refreshPicks()
	local om = ownedMaps()
	for id, b in mapBtns do
		b.BackgroundColor3 = id == pickMap and RED or (om[id] and DARK or Color3.fromRGB(25, 22, 20))
		b.TextTransparency = om[id] and 0 or 0.6
	end
	for id, b in diffBtns do b.BackgroundColor3 = id == pickDiff and RED or DARK end
	for n, b in sizeBtns do b.BackgroundColor3 = n == pickSize and RED or DARK end
	if privBtn then
		privBtn.Text = pickPrivate and "PRIVATE" or "PUBLIC"
		privBtn.BackgroundColor3 = pickPrivate and Color3.fromRGB(70, 40, 90) or DARK
	end
end

local function refreshList()
	if not panel then return end
	local list = parties()
	local myId = lp:GetAttribute("PartyId")
	local myParty = nil
	for _, c in listFrame:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
	local shown = 0
	for i, pt in list do
		if pt.id == myId then myParty = pt end
		-- private lobbies only show to their members and to invited players
		local invited = table.find(pt.invited or {}, lp.UserId) ~= nil
		if pt.private and pt.id ~= myId and not invited then continue end
		shown += 1
		local row = Grunge.frame(listFrame, { Size = UDim2.new(1, -10, 0, 58), BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(10, 8, 7), LayoutOrder = i })
		local m = Maps.byId[pt.map]
		local d = Maps.diffById[pt.diff]
		Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = m and m.color or RED, Size = UDim2.new(0, 6, 1, 0) })
		Grunge.text(row, { Text = string.upper(pt.host) .. "'S LOBBY" .. (pt.private and "  [PRIVATE]" or ""), Position = UDim2.new(0, 14, 0.05, 0), Size = UDim2.new(0.62, 0, 0.5, 0), TextXAlignment = Enum.TextXAlignment.Left })
		Grunge.text(row, { Text = string.upper((m and m.name or pt.map) .. " - " .. (d and d.name or pt.diff)) .. "   " .. #pt.names .. "/" .. pt.size,
			Font = Grunge.TYPE, Position = UDim2.new(0, 14, 0.56, 0), Size = UDim2.new(0.62, 0, 0.36, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = d and d.color or Grunge.PAPER })
		local full = #pt.names >= pt.size
		local b = button(row, pt.id == myId and "YOURS" or (full and "FULL" or (invited and "JOIN!" or "JOIN")), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0.26, 0, 0.72, 0),
			BackgroundColor3 = (pt.id == myId or full) and DARK or GREEN })
		b.Activated:Connect(function()
			if pt.id ~= myId and not full then Sfx.play("Click"); Remotes.Party:FireServer("join", pt.id) end
		end)
	end
	-- your own lobby (top right) or the create form
	mine.Visible = myParty ~= nil
	createPage.Visible = myParty == nil
	if myParty then
		local m, d = Maps.byId[myParty.map], Maps.diffById[myParty.diff]
		mineInfo.Text = string.upper((m and m.name or myParty.map) .. " - " .. (d and d.name or myParty.diff))
		mineNames.Text = table.concat(myParty.names, ", ") .. "   (" .. #myParty.names .. "/" .. myParty.size .. ")"
		local host = myParty.hostId == lp.UserId
		startBtn.Visible = host
		minePriv.Visible = host
		minePriv.Text = myParty.private and "PRIVATE" or "PUBLIC"
		minePriv.BackgroundColor3 = myParty.private and Color3.fromRGB(70, 40, 90) or DARK
		-- invite list: everyone in the server who is not in this lobby and not fighting
		for _, c in inviteList:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
		inviteList.Visible = host
		if host then
			local n = 0
			for _, other in Players:GetPlayers() do
				if other ~= lp and not other:GetAttribute("InMatch") and other:GetAttribute("PartyId") ~= myParty.id then
					n += 1
					local row = Grunge.frame(inviteList, { Size = UDim2.new(1, -8, 0, 40), BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(10, 8, 7), LayoutOrder = n, ZIndex = 11 })
					Grunge.text(row, { Text = other.DisplayName, Font = Grunge.TYPE, Position = UDim2.new(0, 8, 0.15, 0), Size = UDim2.new(0.6, 0, 0.7, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
					local sent = table.find(myParty.invited or {}, other.UserId) ~= nil
					local ib = button(row, sent and "SENT" or "INVITE", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.new(0.34, 0, 0.8, 0),
						BackgroundColor3 = sent and DARK or GREEN, ZIndex = 13 })
					ib.Activated:Connect(function() Sfx.play("Click"); Remotes.Party:FireServer("invite", other.UserId) end)
				end
			end
			if n == 0 then
				local row = Grunge.frame(inviteList, { Size = UDim2.new(1, -8, 0, 40), ZIndex = 11 })
				Grunge.text(row, { Text = "NOBODY ELSE IN THE PARK", Font = Grunge.TYPE, Size = UDim2.fromScale(1, 0.7), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(150, 140, 125), ZIndex = 12 })
			end
		end
	end
	status.Text = shown == 0 and "NO OPEN LOBBIES - CREATE ONE" or ""
end

local function setOpen(open: boolean)
	panel.Visible = open
	if open then
		refreshPicks(); refreshList()
		local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		s.Parent = panel; s.Scale = 0.7
		TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end
	if onToggle then onToggle(open) end
end

local function refreshVisible()
	local inMatch = lp:GetAttribute("InMatch") == true
	side.Visible = not inMatch
	if inMatch and panel.Visible then setOpen(false) end
	local b = lp:GetAttribute("FriendBoost") or 0
	local n = lp:GetAttribute("FriendCount") or 0
	boostTag.Text = b > 0 and ("FRIEND BOOST +" .. math.floor(b * 100 + 0.5) .. "% CASH  (" .. n .. " FRIEND" .. (n > 1 and "S" or "") .. ")") or "FRIEND BOOST: +10% CASH PER FRIEND"
	boostTag.TextColor3 = b > 0 and Color3.fromRGB(150, 220, 110) or Color3.fromRGB(190, 180, 160)
end

-- someone invited you (Fx "PartyInvite")
function LobbyUI.invite(hostName: string, partyId: string)
	if lp:GetAttribute("InMatch") then return end
	invitePartyId = partyId
	invitePopText.Text = string.upper(hostName) .. " INVITED YOU"
	invitePop.Visible = true
	Sfx.play("Cash", { PlaybackSpeed = 1.4, Volume = 0.6 })
	task.delay(15, function() if invitePartyId == partyId then invitePop.Visible = false end end)
end

function LobbyUI.init(shopOpener: () -> (), toggled: (boolean) -> ())
	openShop = shopOpener
	onToggle = toggled
	gui = Instance.new("ScreenGui")
	gui.Name = "LobbyUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 5
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- left column: PLAY / SHOP
	side = Grunge.frame(gui, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 28, 0.5, 0), Size = UDim2.fromScale(0.17, 0.42) })
	local sar = Instance.new("UIAspectRatioConstraint"); sar.AspectRatio = 0.85; sar.Parent = side
	bigButton("PLAY", Color3.fromRGB(150, 20, 18), 0, -4, function() setOpen(not panel.Visible) end)
	bigButton("SHOP", Color3.fromRGB(170, 120, 24), 0.33, 3, function()
		if panel.Visible then setOpen(false) end
		if openShop then openShop() end
	end)
	boostTag = Grunge.text(side, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.66), Size = UDim2.fromScale(1.3, 0.1), TextXAlignment = Enum.TextXAlignment.Left, Rotation = -2 })

	-- PLAY panel
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.55, 0.52), Size = UDim2.fromScale(0.62, 0.8), Rotation = 0, Visible = false }, 33)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 1.45; par.Parent = panel
	-- solid backing so the HUD text behind does not show through
	Grunge.frame(panel, { BackgroundTransparency = 0.04, BackgroundColor3 = Color3.fromRGB(20, 16, 14), Size = UDim2.fromScale(0.97, 0.95), Position = UDim2.fromScale(0.015, 0.025), ZIndex = 9 })
	Grunge.text(panel, { Text = "PLAY", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.02), Size = UDim2.fromScale(0.3, 0.1), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 110, 60), ZIndex = 10 })
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.035), Size = UDim2.fromScale(0.16, 0.065), BackgroundColor3 = DARK, ZIndex = 12, Modal = true })
	close.Activated:Connect(function() Sfx.play("Click"); setOpen(false) end)

	-- left half: create a lobby
	createPage = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.14), Size = UDim2.fromScale(0.46, 0.82), ZIndex = 10 })
	local function heading(parent: Instance, text: string, y: number)
		Grunge.text(parent, { Text = text, Font = Grunge.TYPE, Position = UDim2.fromScale(0, y), Size = UDim2.fromScale(1, 0.055), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(220, 90, 60), ZIndex = 11 })
	end
	heading(createPage, "CREATE A LOBBY - MAP", 0)
	local mg = Grunge.frame(createPage, { Position = UDim2.fromScale(0, 0.065), Size = UDim2.fromScale(1, 0.48), ZIndex = 11 })
	local grid = Instance.new("UIGridLayout"); grid.CellSize = UDim2.fromScale(0.32, 0.165); grid.CellPadding = UDim2.fromScale(0.015, 0.02); grid.SortOrder = Enum.SortOrder.LayoutOrder; grid.Parent = mg
	for i, m in Maps.list do
		local b = button(mg, string.upper(m.name), { LayoutOrder = i, ZIndex = 12, Font = Grunge.TYPE })
		b.Activated:Connect(function()
			Sfx.play("Click")
			if ownedMaps()[m.id] then pickMap = m.id; refreshPicks() else status.Text = "BUY " .. string.upper(m.name) .. " IN THE SHOP (MAPS)" end
		end)
		mapBtns[m.id] = b
	end
	heading(createPage, "DIFFICULTY", 0.57)
	local dg = Grunge.frame(createPage, { Position = UDim2.fromScale(0, 0.635), Size = UDim2.fromScale(1, 0.09), ZIndex = 11 })
	local dl = Instance.new("UIListLayout"); dl.FillDirection = Enum.FillDirection.Horizontal; dl.Padding = UDim.new(0.015, 0); dl.SortOrder = Enum.SortOrder.LayoutOrder; dl.Parent = dg
	for i, d in Maps.difficulties do
		local b = button(dg, string.upper(d.name), { LayoutOrder = i, Size = UDim2.fromScale(0.24, 1), ZIndex = 12, TextColor3 = d.color })
		b.Activated:Connect(function() Sfx.play("Click"); pickDiff = d.id; refreshPicks() end)
		diffBtns[d.id] = b
	end
	heading(createPage, "PLAYERS", 0.75)
	local sg = Grunge.frame(createPage, { Position = UDim2.fromScale(0, 0.815), Size = UDim2.fromScale(0.55, 0.09), ZIndex = 11 })
	local sl = Instance.new("UIListLayout"); sl.FillDirection = Enum.FillDirection.Horizontal; sl.Padding = UDim.new(0.03, 0); sl.SortOrder = Enum.SortOrder.LayoutOrder; sl.Parent = sg
	for n = 1, 4 do
		local b = button(sg, tostring(n), { LayoutOrder = n, Size = UDim2.fromScale(0.22, 1), ZIndex = 12 })
		b.Activated:Connect(function() Sfx.play("Click"); pickSize = n; refreshPicks() end)
		sizeBtns[n] = b
	end
	privBtn = button(createPage, "PUBLIC", { Position = UDim2.fromScale(0.6, 0.745), Size = UDim2.fromScale(0.4, 0.075), BackgroundColor3 = DARK, ZIndex = 12 })
	privBtn.Activated:Connect(function() Sfx.play("Click"); pickPrivate = not pickPrivate; refreshPicks() end)
	local create = button(createPage, "CREATE", { Position = UDim2.fromScale(0.6, 0.84), Size = UDim2.fromScale(0.4, 0.12), BackgroundColor3 = GREEN, ZIndex = 12, Rotation = -1.5 })
	create.Activated:Connect(function() Sfx.play("Click"); Remotes.Party:FireServer("create", pickMap, pickDiff, pickSize, pickPrivate) end)

	-- left half when you are in a lobby: your lobby
	mine = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.14), Size = UDim2.fromScale(0.46, 0.82), ZIndex = 10, Visible = false })
	heading(mine, "YOUR LOBBY", 0)
	mineInfo = Grunge.text(mine, { Text = "", Position = UDim2.fromScale(0, 0.07), Size = UDim2.fromScale(1, 0.09), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	minePriv = button(mine, "PUBLIC", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(0.32, 0.07), BackgroundColor3 = DARK, ZIndex = 12 })
	minePriv.Activated:Connect(function()
		Sfx.play("Click")
		Remotes.Party:FireServer("privacy", minePriv.Text == "PUBLIC")
	end)
	heading(mine, "INVITE PLAYERS", 0.42)
	inviteList = Instance.new("ScrollingFrame")
	inviteList.BackgroundTransparency = 1; inviteList.BorderSizePixel = 0; inviteList.Position = UDim2.fromScale(0, 0.48); inviteList.Size = UDim2.fromScale(1, 0.2)
	inviteList.ScrollBarThickness = 5; inviteList.AutomaticCanvasSize = Enum.AutomaticSize.Y; inviteList.CanvasSize = UDim2.new(); inviteList.ZIndex = 11; inviteList.Parent = mine
	local il = Instance.new("UIListLayout"); il.Padding = UDim.new(0, 4); il.SortOrder = Enum.SortOrder.LayoutOrder; il.Parent = inviteList
	mineNames = Grunge.text(mine, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.2), Size = UDim2.fromScale(1, 0.08), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 11 })
	startBtn = button(mine, "START", { Position = UDim2.fromScale(0, 0.7), Size = UDim2.fromScale(0.55, 0.16), BackgroundColor3 = GREEN, ZIndex = 12, Rotation = -1.5 })
	startBtn.Activated:Connect(function() Sfx.play("Click"); Remotes.Party:FireServer("start") end)
	local leave = button(mine, "LEAVE", { Position = UDim2.fromScale(0.6, 0.72), Size = UDim2.fromScale(0.4, 0.12), BackgroundColor3 = DARK, ZIndex = 12 })
	leave.Activated:Connect(function() Sfx.play("Click"); Remotes.Party:FireServer("leave") end)

	-- right half: open lobbies
	Grunge.text(panel, { Text = "OPEN LOBBIES", Font = Grunge.TYPE, Position = UDim2.fromScale(0.53, 0.14), Size = UDim2.fromScale(0.43, 0.045), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(220, 90, 60), ZIndex = 11 })
	listFrame = Instance.new("ScrollingFrame")
	listFrame.BackgroundTransparency = 1; listFrame.BorderSizePixel = 0; listFrame.Position = UDim2.fromScale(0.53, 0.2); listFrame.Size = UDim2.fromScale(0.43, 0.66)
	listFrame.ScrollBarThickness = 6; listFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.CanvasSize = UDim2.new(); listFrame.ZIndex = 10; listFrame.Parent = panel
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 6); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = listFrame
	status = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.53, 0.88), Size = UDim2.fromScale(0.43, 0.05), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 11 })

	-- invite popup (top centre): "X invited you" with JOIN / NO
	invitePop = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.12), Size = UDim2.fromScale(0.34, 0.15), Rotation = -1, Visible = false }, 51)
	local ipr = Instance.new("UIAspectRatioConstraint"); ipr.AspectRatio = 4.2; ipr.Parent = invitePop
	invitePopText = Grunge.text(invitePop, { Text = "", Position = UDim2.fromScale(0.05, 0.1), Size = UDim2.fromScale(0.9, 0.38), ZIndex = 10 })
	local ij = button(invitePop, "JOIN", { Position = UDim2.fromScale(0.12, 0.55), Size = UDim2.fromScale(0.36, 0.34), BackgroundColor3 = GREEN, ZIndex = 12 })
	ij.Activated:Connect(function()
		Sfx.play("Click"); invitePop.Visible = false
		if invitePartyId then Remotes.Party:FireServer("join", invitePartyId) end
	end)
	local inn = button(invitePop, "NO", { Position = UDim2.fromScale(0.52, 0.55), Size = UDim2.fromScale(0.36, 0.34), BackgroundColor3 = DARK, ZIndex = 12 })
	inn.Activated:Connect(function() Sfx.play("Click"); invitePop.Visible = false end)
	Players.PlayerAdded:Connect(refreshList)
	Players.PlayerRemoving:Connect(function() task.defer(refreshList) end)
	RS:GetAttributeChangedSignal("Parties"):Connect(refreshList)
	for _, a in { "PartyId", "Owned" } do lp:GetAttributeChangedSignal(a):Connect(function() refreshPicks(); refreshList() end) end
	for _, a in { "InMatch", "FriendBoost", "FriendCount" } do lp:GetAttributeChangedSignal(a):Connect(refreshVisible) end
	refreshVisible()
	-- Studio test hook: player attribute LobbyOpen = true opens the PLAY panel
	if game:GetService("RunService"):IsStudio() then
		lp:GetAttributeChangedSignal("LobbyOpen"):Connect(function() setOpen(lp:GetAttribute("LobbyOpen") == true) end)
	end
end

return LobbyUI
