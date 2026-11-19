--!strict
-- Lobby screen (grunge, like the fight HUD): PLAY, SHOP and QUESTS buttons on the left (QUESTS shows how many
-- quests are ready to claim), the friend booster tag, and the
-- PLAY panel: create a lobby (a campaign MAP and one of its BUILDINGS you have opened - Shared/Campaign -,
-- difficulty, 1-4 players) or join an open one, then the host presses START: the party boards the train.
-- Lobbies live on the server (Lobby.luau, Remotes.Party); the list comes in the ReplicatedStorage attribute "Parties".
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Maps = require(RS.Shared.Maps)
local Campaign = require(RS.Shared.Campaign)
local Grunge = require(script.Parent.Grunge)
local TicketShop = require(script.Parent.TicketShop)
local Platform = require(script.Parent.Platform)
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
local pickMap, pickDiff, pickSize = "Camp_Bunkhouse", Maps.defaultDiff, 2 -- pickMap = a building (stage id)
local pickCamp = "Camp" -- the campaign map shown
local campBtns = {} :: { [string]: TextButton }
local stageRows = {} :: { [string]: { b: TextButton, info: TextLabel } }
local pickPrivate = false
local pickFF = true -- friendly fire in the run you create
local privBtn: TextButton
local minePriv: TextButton
local ffBtn: TextButton
local mineFF: TextButton
local inviteList: ScrollingFrame
local invitePop: Frame
local invitePopText: TextLabel
local invitePartyId: string? = nil
local mapBtns = {} :: { [string]: TextButton }
local diffBtns = {} :: { [string]: TextButton }
local sizeBtns = {} :: { [number]: TextButton }
local openShop: (() -> ())? = nil
local onToggle: ((boolean) -> ())? = nil

-- the fight HUD's palette: health red, stamina mustard, brutality orange, cash green, ink
local RED = Color3.fromRGB(150, 18, 20)
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local LOCKED = Color3.fromRGB(22, 18, 16)
local PURPLE = Color3.fromRGB(80, 40, 100)
local ACCENT = Color3.fromRGB(255, 150, 80) -- the HUD's ult-name orange
local seedN = 100

-- a brush-stroke button (like the HUD bars). setText / paint below change it; b:GetAttribute("Label") = its text
local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	seedN += 1
	local z = props.ZIndex or 1
	local col = props.BackgroundColor3 or RED
	local font = props.Font or Grunge.FONT
	local tcol = props.TextColor3 or Grunge.PAPER
	props.BackgroundColor3 = nil; props.Font = nil; props.TextColor3 = nil
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, col, seedN, 12)
	local lbl = Grunge.text(b, { Name = "Label", Text = text, Font = font, TextColor3 = tcol, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.62), ZIndex = z + 3, Rotation = (seedN % 3 - 1) * 0.8 })
	b:SetAttribute("Label", text)
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.06 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	b.MouseButton1Down:Connect(function() sc.Scale = 0.94 end)
	b.MouseButton1Up:Connect(function() sc.Scale = 1.06 end)
	return b
end
local function setText(b: TextButton, text: string)
	(b:FindFirstChild("Label") :: TextLabel).Text = text
	b:SetAttribute("Label", text)
end
local function setTextColor(b: TextButton, c: Color3, transp: number?)
	local l = b:FindFirstChild("Label") :: TextLabel
	l.TextColor3 = c; l.TextTransparency = transp or 0
end
local function paint(b: TextButton, c: Color3)
	local br = b:FindFirstChild("Brush")
	if br then Grunge.paint(br, c) end
end

-- a section heading like the HUD's bar labels (marker font, slightly tilted) with a short red brush under it
local function heading(parent: Instance, text: string, x: number, y: number, w: number, z: number)
	Grunge.text(parent, { Text = text, Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, 0.05), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1.5, ZIndex = z + 1 })
	seedN += 1
	Grunge.brush(parent, { Position = UDim2.fromScale(x, y + 0.047), Size = UDim2.fromScale(w * 0.45, 0.012), ZIndex = z }, RED, seedN, 10, false)
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

-- left-column button: a full HUD bar (brush stroke, blood splat, pen sketch) with a big marker word and a small line
local function bigButton(text: string, sub: string, color: Color3, y: number, rot: number, onClick: () -> (), h: number?): TextButton
	seedN += 7
	local holder = Grunge.frame(side, { Position = UDim2.fromScale(0, y), Size = UDim2.fromScale(1, h or 0.2) })
	local bar = Grunge.bar(holder, { size = UDim2.fromScale(1, 0.78), pos = UDim2.fromScale(0, 0.18), color = color, rot = rot, seed = seedN, slices = 26, outline = false })
	local word = Grunge.text(holder, { Text = text, Position = UDim2.fromScale(0.05, 0.12), Size = UDim2.fromScale(0.62, 0.82), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = rot - 2, ZIndex = 8 })
	Grunge.text(holder, { Text = sub, Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.95, 0.6), Size = UDim2.fromScale(0.42, 0.26),
		TextXAlignment = Enum.TextXAlignment.Right, Rotation = rot, ZIndex = 8, TextTransparency = 0.1 })
	local b = Instance.new("TextButton")
	b.BackgroundTransparency = 1; b.Size = UDim2.fromScale(1, 1); b.Text = ""; b.ZIndex = 9
	b.Parent = holder
	local scale = Instance.new("UIScale"); scale.Parent = holder
	b.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Scale = 1.07 }):Play()
		TweenService:Create(word, TweenInfo.new(0.15), { TextColor3 = Color3.new(1, 1, 1), Rotation = rot - 4 }):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15), { Scale = 1 }):Play()
		TweenService:Create(word, TweenInfo.new(0.15), { TextColor3 = Grunge.PAPER, Rotation = rot - 2 }):Play()
	end)
	b.Activated:Connect(function() Sfx.play("Click"); onClick() end)
	local _ = bar
	return b
end

local function progress(): Campaign.Progress
	local ok, t = pcall(function() return HttpService:JSONDecode(lp:GetAttribute("Campaign") or "{}") end)
	return Campaign.clean(ok and t or {})
end
local function refreshPicks()
	local prog = progress()
	-- (the picked building must be open: else the furthest open one)
	if not Campaign.stageOpen(prog, pickMap) then
		local g = Campaign.goal(prog)
		pickMap = g and g.id or "Camp_Bunkhouse"
	end
	for id, b in campBtns do
		local cm = Campaign.mapById[id]
		local open = Campaign.mapOpen(prog, id)
		paint(b, id == pickCamp and RED or (open and DARK or LOCKED))
		setTextColor(b, Grunge.PAPER, open and 0 or 0.55)
		local done, total = Campaign.cleared(prog, id)
		setText(b, cm.name .. (cm.soon and "\nSOON" or ("\n" .. done .. "/" .. total)))
	end
	for id, r in stageRows do
		local stg = Campaign.stage(id)
		local open = Campaign.stageOpen(prog, id)
		local best = prog[id] or 0
		paint(r.b, id == pickMap and RED or (open and DARK or LOCKED))
		setTextColor(r.b, Grunge.PAPER, open and 0 or 0.55)
		local dd = best > 0 and Maps.diffById[Campaign.rankDiff[best]]
		r.info.Text = not open and "LOCKED" or (dd and ("CLEARED: " .. dd.name) or (stg and stg.phases > 1 and "BOSS - 2 PHASES" or "NOT CLEARED"))
		r.info.TextColor3 = dd and dd.color or (open and Color3.fromRGB(255, 150, 80) or Color3.fromRGB(120, 110, 100))
	end
	for id, b in diffBtns do
		local d = Maps.diffById[id]
		paint(b, id == pickDiff and d.color:Lerp(Color3.new(0, 0, 0), 0.5) or DARK)
		setTextColor(b, id == pickDiff and Grunge.PAPER or d.color)
	end
	for n, b in sizeBtns do paint(b, n == pickSize and RED or DARK) end
	if privBtn then
		setText(privBtn, pickPrivate and "PRIVATE" or "PUBLIC")
		paint(privBtn, pickPrivate and PURPLE or DARK)
	end
	if ffBtn then
		setText(ffBtn, pickFF and "FRIENDLY FIRE: ON" or "FRIENDLY FIRE: OFF")
		paint(ffBtn, pickFF and DARK or GREEN)
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
		local row = Grunge.brush(listFrame, { Size = UDim2.new(1, -10, 0, 58), LayoutOrder = i, ZIndex = 10 }, Color3.fromRGB(30, 24, 21), 300 + i, 22)
		local m = Maps.byId[pt.map]
		local d = Maps.diffById[pt.diff]
		Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = m and m.color or RED, Position = UDim2.new(0, 4, 0.12, 0), Size = UDim2.new(0, 5, 0.76, 0), Rotation = 2, ZIndex = 12 })
		Grunge.text(row, { Text = string.upper(pt.host) .. "'S LOBBY" .. (pt.private and "  [PRIVATE]" or ""), Position = UDim2.new(0, 14, 0.05, 0), Size = UDim2.new(0.62, 0, 0.5, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
		Grunge.text(row, { Text = string.upper((m and m.name or pt.map) .. " - " .. (d and d.name or pt.diff)) .. "   " .. #pt.names .. "/" .. pt.size .. (pt.ff == false and "   FF OFF" or ""), -- (m = the building)
			Font = Grunge.TYPE, Position = UDim2.new(0, 14, 0.56, 0), Size = UDim2.new(0.62, 0, 0.36, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = d and d.color or Grunge.PAPER, ZIndex = 12 })
		local full = #pt.names >= pt.size
		local b = button(row, pt.id == myId and "YOURS" or (full and "FULL" or (invited and "JOIN!" or "JOIN")), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0.26, 0, 0.72, 0),
			BackgroundColor3 = (pt.id == myId or full) and DARK or GREEN, ZIndex = 13 })
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
		setText(minePriv, myParty.private and "PRIVATE" or "PUBLIC")
		paint(minePriv, myParty.private and PURPLE or DARK)
		-- everyone in the lobby sees the friendly fire choice; only the host's press changes it
		setText(mineFF, myParty.ff == false and "FRIENDLY FIRE: OFF" or "FRIENDLY FIRE: ON")
		paint(mineFF, myParty.ff == false and GREEN or DARK)
		mineFF:SetAttribute("Host", host)
		-- invite list: everyone in the server who is not in this lobby and not fighting
		for _, c in inviteList:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
		inviteList.Visible = host
		if host then
			local n = 0
			for _, other in Players:GetPlayers() do
				if other ~= lp and not other:GetAttribute("InMatch") and other:GetAttribute("PartyId") ~= myParty.id then
					n += 1
					local row = Grunge.brush(inviteList, { Size = UDim2.new(1, -8, 0, 40), LayoutOrder = n, ZIndex = 11 }, Color3.fromRGB(30, 24, 21), 400 + n, 16, false)
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
		-- (no train ticket left: said right away)
		local left = Campaign.ticketsLeft(lp:GetAttribute("TripsLeft"), lp:GetAttribute("TripsReset"), workspace:GetServerTimeNow())
		if left <= 0 and (LobbyUI :: any).noTickets then task.delay(0.3, (LobbyUI :: any).noTickets) end
	end
	if onToggle then onToggle(open) end
end

function LobbyUI.togglePlay()
	if panel and not lp:GetAttribute("InMatch") then setOpen(not panel.Visible) end
end
-- the train's prompt at the station (Fx "OpenPlay")
function LobbyUI.openPlay()
	if panel and not lp:GetAttribute("InMatch") and not panel.Visible then setOpen(true) end
end

local function refreshVisible()
	local inMatch = lp:GetAttribute("InMatch") == true
	-- small screens: the buttons step aside while a window is open (they would sit on top of it)
	side.Visible = not inMatch and not (Platform.compact() and Platform.windowOpen())
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

-- quests: opener, how many are ready to claim, and the signal that fires when that may change
function LobbyUI.init(shopOpener: () -> (), toggled: (boolean) -> (), questOpener: (() -> ())?, questCount: (() -> number)?, questChanged: RBXScriptSignal?,
	bestiaryOpener: (() -> ())?)
	openShop = shopOpener
	onToggle = toggled
	gui = Instance.new("ScreenGui")
	gui.Name = "LobbyUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 5
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- left column: PLAY / SHOP / QUESTS, drawn like the fight HUD's bars (health red, stamina mustard, brutality orange)
	side = Grunge.frame(gui, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 28, 0.5, 0), Size = UDim2.fromScale(0.2, 0.54) })
	local sar = Instance.new("UIAspectRatioConstraint"); sar.AspectRatio = 0.82; sar.Parent = side
	bigButton("PLAY", "TAKE THE TRAIN", Color3.fromRGB(150, 18, 20), 0, -1.2, function() setOpen(not panel.Visible) end, 0.19)
	bigButton("SHOP", "ULTIMATES", Color3.fromRGB(176, 150, 40), 0.21, 0.8, function()
		if panel.Visible then setOpen(false) end
		if openShop then openShop() end
	end, 0.19)
	local questBtn = bigButton("QUESTS", "DAILY CASH", Color3.fromRGB(210, 86, 18), 0.42, -0.6, function()
		if panel.Visible then setOpen(false) end
		if questOpener then questOpener() end
	end, 0.19)
	-- long-term goals: the monsters you have beaten and the badges (Client/BestiaryUI)
	bigButton("BESTIARY", "BADGES", Color3.fromRGB(96, 52, 150), 0.63, 0.7, function()
		if panel.Visible then setOpen(false) end
		if bestiaryOpener then bestiaryOpener() end
	end, 0.19)
	-- red badge: quests ready to claim
	local badge = Grunge.frame(questBtn.Parent :: Instance, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.98, 0.2), Size = UDim2.fromScale(0.2, 0.46), BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(200, 30, 24), ZIndex = 10, Visible = false })
	local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0.5, 0); bc.Parent = badge
	local bst = Instance.new("UIStroke"); bst.Color = Grunge.INK; bst.Thickness = 3; bst.Parent = badge
	local bar = Instance.new("UIAspectRatioConstraint"); bar.AspectRatio = 1; bar.Parent = badge
	local badgeText = Grunge.text(badge, { Text = "", Size = UDim2.fromScale(1, 1), TextColor3 = Grunge.PAPER, ZIndex = 11 })
	local function refreshBadge()
		local n = questCount and questCount() or 0
		badge.Visible = n > 0
		badgeText.Text = tostring(n)
	end
	if questChanged then questChanged:Connect(refreshBadge) end
	refreshBadge()
	-- controller: D-pad up opens PLAY (the stick keeps moving the character)
	local padTag = Grunge.text(side, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.94), Size = UDim2.fromScale(1.1, 0.055), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = ACCENT, Rotation = -1 })
	local function padHint() padTag.Text = Platform.mode() == "gamepad" and "D-PAD UP: PLAY   D-PAD LEFT: SETTINGS" or "" end
	padHint()
	Platform.changed:Connect(padHint)
	boostTag = Grunge.text(side, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.02, 0.85), Size = UDim2.fromScale(1.1, 0.065), TextXAlignment = Enum.TextXAlignment.Left, Rotation = -1 })

	-- PLAY panel: a painted ink slab over a blood splat, the title over a red brush (like the ghost name over its bar)
	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.55, 0.52), Size = UDim2.fromScale(0.62, 0.8), Visible = false, ZIndex = 8 }, Color3.fromRGB(21, 17, 15), 33, 6, false) -- no pen lines around the lobby's panels and bars
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 1.45; par.Parent = panel
	Grunge.text(panel, { Text = "FIND A FIGHT", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.025), Size = UDim2.fromScale(0.5, 0.095), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1, ZIndex = 11 })
	local titleBar = Grunge.bar(panel, { size = UDim2.fromScale(0.42, 0.028), pos = UDim2.fromScale(0.04, 0.115), color = RED, rot = 0.4, seed = 51, slices = 30, outline = false })
	titleBar.root.ZIndex = 10
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.035), Size = UDim2.fromScale(0.15, 0.07), BackgroundColor3 = DARK, ZIndex = 12, Modal = true, Rotation = 1.5 })
	close.Activated:Connect(function() Sfx.play("Click"); setOpen(false) end)
	Platform.menu(panel, function() setOpen(false) end)
	-- the train tickets (Campaign.TRIPS: every trip to a building uses one)
	local function ticketsNow(): (number, number)
		local now = workspace:GetServerTimeNow()
		return Campaign.ticketsLeft(lp:GetAttribute("TripsLeft"), lp:GetAttribute("TripsReset"), now), (tonumber(lp:GetAttribute("TripsReset")) or 0) - now
	end
	-- no ticket left: a big red message over the panel (pressing CREATE / START, or opening it)
	local noTicket = Grunge.slab(panel, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.62, 0.34), Visible = false, ZIndex = 30, Rotation = -1.5 },
		Color3.fromRGB(24, 12, 10), 61, 4, false)
	local ntTitle = Grunge.text(noTicket, { Text = "YOU HAVE NO TRAIN TICKETS", Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.05), Size = UDim2.fromScale(0.9, 0.33),
		TextColor3 = Color3.fromRGB(235, 50, 35), ZIndex = 33 })
	local ntSub = Grunge.text(noTicket, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.4), Size = UDim2.fromScale(0.9, 0.2), ZIndex = 33 })
	-- (the TRAIN TICKETS Developer Product: all 5 back now, Client/TicketShop)
	local ntBuy = button(noTicket, TicketShop.label(), { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.79), Size = UDim2.fromScale(0.62, 0.26),
		BackgroundColor3 = Color3.fromRGB(190, 40, 120), ZIndex = 34 })
	ntBuy.Activated:Connect(function()
		Sfx.play("Click")
		if not TicketShop.buy() then setText(ntBuy, "TICKET REFILLS: COMING SOON") end
	end)
	local ntScale = Instance.new("UIScale"); ntScale.Parent = noTicket
	local ntUntil = 0
	local function showNoTicket()
		local _, wait = ticketsNow()
		ntSub.Text = Campaign.TRIPS.max .. " NEW TICKETS IN " .. Campaign.clock(wait) .. "  -  OR REFILL THEM NOW"
		setText(ntBuy, TicketShop.label())
		noTicket.Visible = true
		ntScale.Scale = 0.6
		TweenService:Create(ntScale, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		ntUntil = os.clock() + 7
		Sfx.play("Click", { PlaybackSpeed = 0.6 })
		task.delay(7.1, function() if os.clock() >= ntUntil then noTicket.Visible = false end end)
	end
	(LobbyUI :: any).noTickets = showNoTicket
	local _ = ntTitle
	local ticketT = Grunge.text(panel, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.79, 0.03), Size = UDim2.fromScale(0.26, 0.05),
		TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11, Rotation = 1 })
	local ticketSub = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.79, 0.083), Size = UDim2.fromScale(0.26, 0.032),
		TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11, TextColor3 = Color3.fromRGB(190, 180, 160) })
	task.spawn(function()
		while true do
			if panel.Visible then
				local now = workspace:GetServerTimeNow()
				local left = Campaign.ticketsLeft(lp:GetAttribute("TripsLeft"), lp:GetAttribute("TripsReset"), now)
				local reset = tonumber(lp:GetAttribute("TripsReset")) or 0
				local max = Campaign.TRIPS.max
				ticketT.Text = "TRAIN TICKETS " .. left .. " / " .. max
				ticketT.TextColor3 = left > 0 and Color3.fromRGB(150, 200, 255) or Color3.fromRGB(255, 110, 80)
				ticketSub.Text = (left < max and reset > now) and ("REFILL IN " .. Campaign.clock(reset - now)) or (max .. " TRIPS EVERY " .. (Campaign.TRIPS.window // 3600) .. " HOURS")
				ticketT.Visible = Campaign.TRIPS.enabled; ticketSub.Visible = Campaign.TRIPS.enabled
			end
			task.wait(0.5)
		end
	end)

	-- left half: create a lobby
	createPage = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.14), Size = UDim2.fromScale(0.46, 0.82), ZIndex = 10 })
	-- the campaign: a row of maps, then the picked map's buildings (fought top to bottom)
	heading(createPage, "PICK A MAP", 0, 0, 1, 11)
	local mg = Grunge.frame(createPage, { Position = UDim2.fromScale(0, 0.065), Size = UDim2.fromScale(1, 0.085), ZIndex = 11 })
	local ml = Instance.new("UIListLayout"); ml.FillDirection = Enum.FillDirection.Horizontal; ml.Padding = UDim.new(0.01, 0); ml.SortOrder = Enum.SortOrder.LayoutOrder; ml.Parent = mg
	local stageList: Frame
	local function buildStages()
		for _, c in stageList:GetChildren() do if c:IsA("TextButton") then c:Destroy() end end
		table.clear(stageRows)
		local cm = Campaign.mapById[pickCamp]
		for i, stg in cm.stages do
			local b = button(stageList, i .. "   " .. stg.name, { LayoutOrder = i, Size = UDim2.fromScale(1, math.min(0.185, 0.93 / #cm.stages)), ZIndex = 12, Font = Grunge.FONT })
			local lbl = b:FindFirstChild("Label") :: TextLabel
			lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Size = UDim2.fromScale(0.56, 0.58); lbl.AnchorPoint = Vector2.new(0, 0.5); lbl.Position = UDim2.fromScale(0.04, 0.5)
			local info = Grunge.text(b, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(0.97, 0.5), Size = UDim2.fromScale(0.38, 0.42),
				TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 15 })
			b.Activated:Connect(function()
				Sfx.play("Click")
				if Campaign.stageOpen(progress(), stg.id) then
					pickMap = stg.id
					local cmx = Campaign.mapById[stg.map]
					local tough = cmx and (cmx.hp or 1) > 1 and ("  -  MONSTERS x" .. cmx.hp .. " HEALTH, x" .. (cmx.dmg or 1) .. " DAMAGE: WEAR YOUR BEST FORMS") or ""
					status.Text = stg.desc .. tough
				else
					status.Text = "CLEAR THE BUILDING BEFORE " .. stg.name .. " FIRST"
				end
				refreshPicks()
			end)
			stageRows[stg.id] = { b = b, info = info }
		end
		if #cm.stages == 0 then status.Text = cm.name .. " IS COMING SOON" end
	end
	for i, cm in Campaign.list do
		local b = button(mg, cm.name, { LayoutOrder = i, Size = UDim2.fromScale(0.192, 1), ZIndex = 12, Font = Grunge.TYPE })
		b.Activated:Connect(function()
			Sfx.play("Click")
			if cm.soon then status.Text = cm.name .. " IS COMING SOON"; return end
			if not Campaign.mapOpen(progress(), cm.id) then status.Text = "BEAT EVERY BUILDING OF THE MAP BEFORE IT FIRST"; return end
			pickCamp = cm.id
			buildStages()
			refreshPicks()
		end)
		campBtns[cm.id] = b
	end
	heading(createPage, "PICK A BUILDING", 0, 0.165, 1, 11)
	stageList = Grunge.frame(createPage, { Position = UDim2.fromScale(0, 0.225), Size = UDim2.fromScale(1, 0.34), ZIndex = 11 })
	local sll = Instance.new("UIListLayout"); sll.Padding = UDim.new(0.015, 0); sll.SortOrder = Enum.SortOrder.LayoutOrder; sll.Parent = stageList
	buildStages()
	heading(createPage, "DIFFICULTY", 0, 0.57, 1, 11)
	local dg = Grunge.frame(createPage, { Position = UDim2.fromScale(0, 0.635), Size = UDim2.fromScale(1, 0.09), ZIndex = 11 })
	local dl = Instance.new("UIListLayout"); dl.FillDirection = Enum.FillDirection.Horizontal; dl.Padding = UDim.new(0.015, 0); dl.SortOrder = Enum.SortOrder.LayoutOrder; dl.Parent = dg
	for i, d in Maps.difficulties do
		local b = button(dg, string.upper(d.name), { LayoutOrder = i, Size = UDim2.fromScale(0.24, 1), ZIndex = 12, TextColor3 = d.color })
		b.Activated:Connect(function() Sfx.play("Click"); pickDiff = d.id; refreshPicks() end)
		diffBtns[d.id] = b
	end
	heading(createPage, "PLAYERS", 0, 0.75, 0.55, 11)
	local sg = Grunge.frame(createPage, { Position = UDim2.fromScale(0, 0.815), Size = UDim2.fromScale(0.55, 0.09), ZIndex = 11 })
	local sl = Instance.new("UIListLayout"); sl.FillDirection = Enum.FillDirection.Horizontal; sl.Padding = UDim.new(0.03, 0); sl.SortOrder = Enum.SortOrder.LayoutOrder; sl.Parent = sg
	for n = 1, 4 do
		local b = button(sg, tostring(n), { LayoutOrder = n, Size = UDim2.fromScale(0.22, 1), ZIndex = 12 })
		b.Activated:Connect(function() Sfx.play("Click"); pickSize = n; refreshPicks() end)
		sizeBtns[n] = b
	end
	privBtn = button(createPage, "PUBLIC", { Position = UDim2.fromScale(0.6, 0.745), Size = UDim2.fromScale(0.4, 0.075), BackgroundColor3 = DARK, ZIndex = 12 })
	privBtn.Activated:Connect(function() Sfx.play("Click"); pickPrivate = not pickPrivate; refreshPicks() end)
	ffBtn = button(createPage, "FRIENDLY FIRE: ON", { Position = UDim2.fromScale(0, 0.922), Size = UDim2.fromScale(0.55, 0.07), BackgroundColor3 = DARK, ZIndex = 12, Font = Grunge.TYPE })
	ffBtn.Activated:Connect(function() Sfx.play("Click"); pickFF = not pickFF; refreshPicks() end)
	local create = button(createPage, "CREATE", { Position = UDim2.fromScale(0.58, 0.84), Size = UDim2.fromScale(0.42, 0.13), BackgroundColor3 = GREEN, ZIndex = 12, Rotation = -1.5 })
	create.Activated:Connect(function()
		if (ticketsNow()) <= 0 then showNoTicket(); return end
		Sfx.play("Click"); Remotes.Party:FireServer("create", pickMap, pickDiff, pickSize, pickPrivate, pickFF)
	end)

	-- left half when you are in a lobby: your lobby
	mine = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.14), Size = UDim2.fromScale(0.46, 0.82), ZIndex = 10, Visible = false })
	heading(mine, "YOUR LOBBY", 0, 0, 0.66, 11)
	mineInfo = Grunge.text(mine, { Text = "", Position = UDim2.fromScale(0, 0.07), Size = UDim2.fromScale(1, 0.09), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	minePriv = button(mine, "PUBLIC", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(0.32, 0.07), BackgroundColor3 = DARK, ZIndex = 12 })
	minePriv.Activated:Connect(function()
		Sfx.play("Click")
		Remotes.Party:FireServer("privacy", minePriv:GetAttribute("Label") == "PUBLIC")
	end)
	mineFF = button(mine, "FRIENDLY FIRE: ON", { Position = UDim2.fromScale(0, 0.31), Size = UDim2.fromScale(0.6, 0.075), BackgroundColor3 = DARK, ZIndex = 12, Font = Grunge.TYPE })
	mineFF.Activated:Connect(function()
		if not mineFF:GetAttribute("Host") then return end
		Sfx.play("Click")
		Remotes.Party:FireServer("ff", mineFF:GetAttribute("Label") == "FRIENDLY FIRE: OFF")
	end)
	heading(mine, "INVITE PLAYERS", 0, 0.42, 1, 11)
	inviteList = Instance.new("ScrollingFrame")
	inviteList.BackgroundTransparency = 1; inviteList.BorderSizePixel = 0; inviteList.Position = UDim2.fromScale(0, 0.48); inviteList.Size = UDim2.fromScale(1, 0.2)
	inviteList.ScrollBarThickness = 5; inviteList.AutomaticCanvasSize = Enum.AutomaticSize.Y; inviteList.CanvasSize = UDim2.new(); inviteList.ZIndex = 11; inviteList.Parent = mine
	local il = Instance.new("UIListLayout"); il.Padding = UDim.new(0, 4); il.SortOrder = Enum.SortOrder.LayoutOrder; il.Parent = inviteList
	mineNames = Grunge.text(mine, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.2), Size = UDim2.fromScale(1, 0.08), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 11 })
	startBtn = button(mine, "START", { Position = UDim2.fromScale(0, 0.7), Size = UDim2.fromScale(0.55, 0.16), BackgroundColor3 = GREEN, ZIndex = 12, Rotation = -1.5 })
	startBtn.Activated:Connect(function()
		if (ticketsNow()) <= 0 then showNoTicket(); return end
		Sfx.play("Click"); Remotes.Party:FireServer("start")
	end)
	local leave = button(mine, "LEAVE", { Position = UDim2.fromScale(0.6, 0.72), Size = UDim2.fromScale(0.4, 0.12), BackgroundColor3 = DARK, ZIndex = 12 })
	leave.Activated:Connect(function() Sfx.play("Click"); Remotes.Party:FireServer("leave") end)

	-- right half: open lobbies
	heading(panel, "OPEN LOBBIES", 0.53, 0.14, 0.43, 11)
	listFrame = Instance.new("ScrollingFrame")
	listFrame.BackgroundTransparency = 1; listFrame.BorderSizePixel = 0; listFrame.Position = UDim2.fromScale(0.53, 0.2); listFrame.Size = UDim2.fromScale(0.43, 0.66)
	listFrame.ScrollBarThickness = 6; listFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.CanvasSize = UDim2.new(); listFrame.ZIndex = 10; listFrame.Parent = panel
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 6); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = listFrame
	status = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.53, 0.88), Size = UDim2.fromScale(0.43, 0.05), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = ACCENT, ZIndex = 11 })

	-- invite popup (top centre): "X invited you" with JOIN / NO
	invitePop = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.12), Size = UDim2.fromScale(0.34, 0.15), Rotation = -1, Visible = false, ZIndex = 8 }, Color3.fromRGB(21, 17, 15), 51, 3, false)
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
	for _, a in { "PartyId", "Owned", "Campaign" } do lp:GetAttributeChangedSignal(a):Connect(function() refreshPicks(); refreshList() end) end
	for _, a in { "InMatch", "FriendBoost", "FriendCount" } do lp:GetAttributeChangedSignal(a):Connect(refreshVisible) end
	Platform.windowChanged:Connect(refreshVisible)
	Platform.changed:Connect(refreshVisible)
	refreshVisible()
	-- Studio test hook: player attribute LobbyOpen = true opens the PLAY panel
	if game:GetService("RunService"):IsStudio() then
		lp:GetAttributeChangedSignal("LobbyOpen"):Connect(function() setOpen(lp:GetAttribute("LobbyOpen") == true) end)
	end
end

return LobbyUI
