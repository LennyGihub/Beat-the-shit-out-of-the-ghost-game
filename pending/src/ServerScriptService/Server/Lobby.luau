-- PS2 park lobby: queue rooms for 1-4 players (step on the pad), countdown, then the party goes to its own
-- reserved match server. In Studio (no teleports) the party plays a local match in this server instead.
-- Also runs the ultimate shop (vendor in the park) and sends players back to the lobby.
-- CAMPAIGN (Shared/Campaign): a party picks a BUILDING (its stage id is the "map") and a difficulty; the host must
-- have that building open. Every trip goes by TRAIN: the party boards the train waiting at the park's station
-- (Fx "TrainDepart" plays the ride out, Client/TrainRide), then the match starts / the teleport goes. The old
-- queue pads in the cabins are off (the train is the only way out of the park).
-- ENDLESS (the run like before the campaign, 2026-11-19 back by the user's request): the party picks one of the old
-- HOUSES (Shared/Maps entries without `campaign`: the Mansion is free, the others are bought at the dealer, Data.ownsMap)
-- and fights ghost after ghost there until everyone is down (Server/Run with no stage). It leaves by the same train
-- (no ticket needed).
-- TRAIN TICKETS (Campaign.TRIPS: 5 trips in 3 hours): every rider uses one when the train leaves; who has none stays
-- in the park (a toast says when they come back); a failed teleport gives them back.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Ultimates = require(RS.Shared.Ultimates)
local Maps = require(RS.Shared.Maps)
local Campaign = require(RS.Shared.Campaign)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Run = require(script.Parent.Run)

local Lobby = {}
local COUNTDOWN = 8 -- seconds once the room is full (time to pick a map)
local rooms = {} :: { any }

local function hrpOf(p: Player): BasePart?
	return p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function onPad(pad: BasePart, pos: Vector3): boolean
	local lp = pad.CFrame:PointToObjectSpace(pos)
	return math.abs(lp.X) <= pad.Size.X / 2 and math.abs(lp.Z) <= pad.Size.Z / 2 and lp.Y > -1 and lp.Y < 9
end

-- the map + difficulty line on the sign (both faces)
local function setMapLine(room)
	if not room.sign then return end
	local m = Maps.byId[room.map] or Maps.byId.Mansion
	local d = Maps.diffById[room.diff] or Maps.diffById.Normal
	for _, gname in { "Gui", "GuiBack" } do
		local gui = room.sign:FindFirstChild(gname)
		local l = gui and gui:FindFirstChild("MapLine") :: TextLabel?
		if l then
			l.Text = string.upper(m.name) .. "  -  " .. d.name
			l.TextColor3 = d.color
		end
	end
end

-- squeeze the two sign lines and add the map line between them
local function prepSign(room)
	if not room.sign then return end
	for _, gname in { "Gui", "GuiBack" } do
		local gui = room.sign:FindFirstChild(gname)
		if gui and not gui:FindFirstChild("MapLine") then
			local count = gui:FindFirstChild("Count") :: TextLabel?
			local status = gui:FindFirstChild("Status") :: TextLabel?
			if count then count.Position = UDim2.new(0.03, 0, 0.02, 0); count.Size = UDim2.new(0.94, 0, 0.38, 0) end
			if status then status.Position = UDim2.new(0.03, 0, 0.66, 0); status.Size = UDim2.new(0.94, 0, 0.3, 0) end
			local l = (count and count:Clone() or Instance.new("TextLabel")) :: TextLabel
			l.Name = "MapLine"; l.Position = UDim2.new(0.08, 0, 0.41, 0); l.Size = UDim2.new(0.84, 0, 0.22, 0); l.Rotation = 0; l.Parent = gui
		end
	end
	setMapLine(room)
end

local function setSign(room, title: string, line: string, color: Color3?)
	if not room.sign then return end
	-- the sign has a front face (plaza side) and a back face (readable from the pad)
	for _, gname in { "Gui", "GuiBack" } do
		local gui = room.sign:FindFirstChild(gname)
		if gui then
			local t = gui:FindFirstChild("Count") :: TextLabel?
			local s = gui:FindFirstChild("Status") :: TextLabel?
			if t then t.Text = title end
			if s then s.Text = line; s.TextColor3 = color or Color3.fromRGB(220, 210, 180) end
		end
	end
end

local TRAIN_DEPART = 5.5 -- seconds of the client's ride out of the station (Client/TrainRide)
local function noTicket(p: Player)
	local _, reset = Data.tripsLeft(p)
	Remotes.Fx:FireClient(p, "Toast", "NO TRAIN TICKETS LEFT - " .. Campaign.TRIPS.max .. " MORE IN " .. Campaign.clock(reset - os.time()))
end

local function launch(room, members: { Player })
	room.countdownStart = nil
	-- all aboard: the train pulls out of the park's station (each client rides it), then the trip itself
	local st = Campaign.stage(room.map)
	local house = not st and Maps.byId[room.map] or nil -- an ENDLESS run's house
	if st or house then
		-- a ticket each for a building (who has none stays in the park); an endless run needs none
		local riders = {}
		for _, p in members do
			if not st or Data.useTrip(p) then table.insert(riders, p) else noTicket(p) end
		end
		members = riders
		if #members == 0 then return end
		for _, p in members do
			p:SetAttribute("Boarding", true)
			Remotes.Fx:FireClient(p, "TrainDepart", room.map, room.diff, nil, true)
		end
		task.wait(TRAIN_DEPART)
		local still = {}
		for _, p in members do
			p:SetAttribute("Boarding", nil)
			if p.Parent and not p:GetAttribute("InMatch") then table.insert(still, p) elseif p.Parent and st then Data.refundTrip(p) end
		end
		members = still
		if #members == 0 then return end
	end
	-- the loading screen (ReplicatedFirst/Loading) comes up for everyone who goes
	local function loading(text: string) for _, p in members do Remotes.Fx:FireClient(p, "Teleporting", text) end end
	local function failed()
		for _, p in members do
			Remotes.Fx:FireClient(p, "TeleportFailed")
			if st then Data.refundTrip(p) end
		end
	end
	if RunService:IsStudio() then
		if Run.running() then
			for _, p in members do
				Remotes.Fx:FireClient(p, "Toast", "A match is already running in this Studio test")
				if st then Data.refundTrip(p) end
			end
			return
		end
		loading(st and ("TO " .. st.name .. "...") or (house and ("TO " .. string.upper(house.name) .. "...") or "LOADING THE HOUSE..."))
		task.wait(0.4) -- (the card is up before the map is built)
		Run.beginMatch(members, room.map, room.diff, room.ff ~= false)
		return
	end
	loading(st and ("TO " .. st.name .. "...") or (house and ("TO " .. string.upper(house.name) .. "...") or "TELEPORTING TO THE HOUSE..."))
	setSign(room, room.size .. " PLAYER" .. (room.size > 1 and "S" or ""), "TELEPORTING...", Color3.fromRGB(150, 220, 110))
	local ok, code = pcall(function() return TeleportService:ReserveServer(game.PlaceId) end)
	if not ok then
		warn("[Lobby] ReserveServer failed: " .. tostring(code))
		failed()
		for _, p in members do Remotes.Fx:FireClient(p, "Toast", "Teleport failed, try again") end
		return
	end
	local opts = Instance.new("TeleportOptions")
	opts.ReservedServerAccessCode = code
	opts:SetTeleportData({ size = #members, map = room.map, diff = room.diff, ff = room.ff ~= false })
	for _, p in members do Data.save(p) end
	local tok, err = pcall(function() TeleportService:TeleportAsync(game.PlaceId, members, opts) end)
	if not tok then
		warn("[Lobby] Teleport failed: " .. tostring(err))
		failed()
		for _, p in members do Remotes.Fx:FireClient(p, "Toast", "Teleport failed, try again") end
	end
end

local function tick()
	local now = os.clock()
	local taken = {} :: { [Player]: boolean }
	for _, room in rooms do
		local members = {}
		for _, p in Players:GetPlayers() do
			local hrp = hrpOf(p)
			if hrp and not taken[p] and not p:GetAttribute("InMatch") and #members < room.size and onPad(room.pad, hrp.Position) then
				table.insert(members, p)
				taken[p] = true
			end
		end
		for _, p in members do p:SetAttribute("QueueRoom", room.name) end
		-- the first player who stepped on the pad picks the map and difficulty
		if not room.leader or not table.find(members, room.leader) then
			room.leader = members[1]
			room.model:SetAttribute("Leader", room.leader and room.leader.UserId or 0)
			-- a new leader who doesn't own the picked map falls back to the Mansion
			if room.leader and not Data.ownsMap(room.leader, room.map) then
				room.map = "Mansion"
				room.model:SetAttribute("Map", room.map)
				setMapLine(room)
			end
		end
		local title = room.size .. " PLAYER" .. (room.size > 1 and "S" or "")
		if #members >= room.size then
			room.countdownStart = room.countdownStart or now
			local left = COUNTDOWN - (now - room.countdownStart)
			if left <= 0 then
				launch(room, members)
			else
				setSign(room, title, "STARTING IN " .. math.ceil(left), Color3.fromRGB(255, 150, 60))
			end
		else
			room.countdownStart = nil
			setSign(room, title, #members .. " / " .. room.size)
		end
	end
	for _, p in Players:GetPlayers() do
		if not taken[p] and p:GetAttribute("QueueRoom") then p:SetAttribute("QueueRoom", nil) end
	end
end

-- PLAY-button lobbies (parties): a host creates one (map, difficulty, 1-4 players, friendly fire on / off), others join from the list,
-- the host presses START. Published to every client as the ReplicatedStorage attribute "Parties" (JSON).
local HttpService = game:GetService("HttpService")
local parties = {} :: { [string]: any }
local function publish()
	local list = {}
	for id, pt in parties do
		local names = {}
		for _, m in pt.members do table.insert(names, m.DisplayName) end
		local inv = {}
		for uid in pt.invited do table.insert(inv, uid) end
		table.insert(list, { id = id, host = pt.host.DisplayName, hostId = pt.host.UserId, map = pt.map, diff = pt.diff, size = pt.size, names = names,
			private = pt.private, invited = inv, ff = pt.ff })
	end
	table.sort(list, function(a, b) return a.id < b.id end)
	RS:SetAttribute("Parties", HttpService:JSONEncode(list))
end
local function partyOf(p: Player): any
	local id = p:GetAttribute("PartyId")
	return id and parties[id] or nil
end
local function leaveParty(p: Player)
	local pt = partyOf(p)
	p:SetAttribute("PartyId", nil)
	if not pt then return end
	local i = table.find(pt.members, p)
	if i then table.remove(pt.members, i) end
	if #pt.members == 0 then
		parties[pt.id] = nil
	elseif pt.host == p then
		pt.host = pt.members[1] -- the next player leads
	end
	publish()
end
local function onParty(p: Player, action: any, a: any, b: any, c: any, d: any, e: any)
	if type(action) ~= "string" or p:GetAttribute("InMatch") then return end
	if action == "create" then
		if type(a) ~= "string" or type(b) ~= "string" or type(c) ~= "number" then return end
		local private = d == true
		local m, dd = Maps.byId[a], Maps.diffById[b]
		if not m or not dd then return end
		-- a campaign building the host has opened, or (ENDLESS) an old house the host owns
		local stg = Campaign.stage(m.id)
		if stg then
			if not Campaign.stageOpen(Data.campaign(p), stg.id) then Remotes.Fx:FireClient(p, "Toast", "Clear the building before " .. stg.name .. " first"); return end
		else
			if m.campaign then return end
			if not Campaign.endlessOpen(p:GetAttribute("Level")) then
				Remotes.Fx:FireClient(p, "Toast", "Endless opens at level " .. Campaign.ENDLESS_LEVEL); return
			end
			if not Data.ownsMap(p, m.id) then Remotes.Fx:FireClient(p, "Toast", "Buy " .. m.name .. " at the dealer first (SHOP > HOUSES)"); return end
		end
		leaveParty(p)
		local id = tostring(p.UserId)
		parties[id] = { id = id, host = p, members = { p }, map = m.id, diff = dd.id, size = math.clamp(math.floor(c), 1, 4), private = private, invited = {},
			ff = e ~= false } -- friendly fire: on unless the host switched it off
		p:SetAttribute("PartyId", id)
		publish()
	elseif action == "join" then
		local pt = type(a) == "string" and parties[a] or nil
		if not pt then Remotes.Fx:FireClient(p, "Toast", "That lobby is gone"); return end
		if #pt.members >= pt.size then Remotes.Fx:FireClient(p, "Toast", "That lobby is full"); return end
		if pt.private and not pt.invited[p.UserId] then Remotes.Fx:FireClient(p, "Toast", "That lobby is private - ask for an invite"); return end
		if not Campaign.stage(pt.map) and not Campaign.endlessOpen(p:GetAttribute("Level")) then
			Remotes.Fx:FireClient(p, "Toast", "Endless opens at level " .. Campaign.ENDLESS_LEVEL); return
		end
		leaveParty(p)
		table.insert(pt.members, p)
		p:SetAttribute("PartyId", pt.id)
		publish()
	elseif action == "invite" then
		-- the host invites a player of this server (a = their UserId): they get a popup with JOIN
		local pt = partyOf(p)
		local who = type(a) == "number" and Players:GetPlayerByUserId(a) or nil
		if not pt or pt.host ~= p or not who or who == p then return end
		pt.invited[who.UserId] = true
		publish()
		Remotes.Fx:FireClient(who, "PartyInvite", p.DisplayName, pt.id)
		Remotes.Fx:FireClient(p, "Toast", "INVITE SENT TO " .. string.upper(who.DisplayName))
	elseif action == "privacy" then
		local pt = partyOf(p)
		if not pt or pt.host ~= p then return end
		pt.private = a == true
		publish()
	elseif action == "ff" then
		-- the host switches friendly fire for the run (a = on)
		local pt = partyOf(p)
		if not pt or pt.host ~= p then return end
		pt.ff = a == true
		publish()
	elseif action == "leave" then
		leaveParty(p)
	elseif action == "start" then
		local pt = partyOf(p)
		if not pt or pt.host ~= p then return end
		if Campaign.stage(pt.map) and Data.tripsLeft(p) <= 0 then noTicket(p); return end
		local members = {}
		for _, m in pt.members do if m.Parent and not m:GetAttribute("InMatch") then table.insert(members, m) end end
		for _, m in pt.members do m:SetAttribute("PartyId", nil) end
		parties[pt.id] = nil
		publish()
		launch({ map = pt.map, diff = pt.diff, size = #members, name = "Party", ff = pt.ff }, members)
	end
end

function Lobby.returnPlayer(p: Player)
	if Run.mode == "Match" then
		Data.save(p)
		Remotes.Fx:FireClient(p, "Teleporting", "BACK TO THE LOBBY...")
		local ok, err = pcall(function() TeleportService:TeleportAsync(game.PlaceId, { p }) end)
		if not ok then
			warn("[Lobby] return failed: " .. tostring(err))
			Remotes.Fx:FireClient(p, "TeleportFailed")
		end
		return
	end
	Run.removeFromMatch(p)
	local sp = workspace:FindFirstChild("LobbySpawn") :: BasePart?
	if sp and p.Character then p.Character:PivotTo(sp.CFrame + Vector3.new(math.random(-6, 6), 4, math.random(-6, 6))) end
	Remotes.Fx:FireClient(p, "BackInLobby")
	if #Run.matchPlayers() == 0 then Run.endMatch() end
end

local function onBuyUlt(p: Player, id: any)
	if type(id) ~= "string" then return end
	local u = Ultimates.byId[id]
	if not u then return end
	if Data.ownsUlt(p, id) then
		Data.equipUlt(p, id)
		Remotes.Fx:FireClient(p, "UltResult", true, "Equipped " .. u.name)
		return
	end
	if not Data.spend(p, u.price) then
		Remotes.Fx:FireClient(p, "UltResult", false, "Not enough cash for " .. u.name)
		return
	end
	Data.ownUlt(p, id)
	Data.equipUlt(p, id)
	task.spawn(Data.save, p)
	Remotes.Fx:FireClient(p, "UltResult", true, "Bought and equipped " .. u.name)
end

function Lobby.start()
	local lobby = workspace:WaitForChild("Lobby", 10)
	local roomFolder = lobby and lobby:FindFirstChild("Rooms")
	-- (the queue pads are off: trips start at the train. Lobby attribute UseRoomPads = true brings them back)
	if roomFolder and lobby:GetAttribute("UseRoomPads") == true then
		for _, r in roomFolder:GetChildren() do
			local pad = r:FindFirstChild("Pad", true) :: BasePart?
			if pad then
				table.insert(rooms, { name = r.Name, size = r:GetAttribute("Size") or 1, pad = pad, sign = r:FindFirstChild("Sign", true), countdownStart = nil,
					model = r, map = "Mansion", diff = "Normal", leader = nil :: Player? })
				r:SetAttribute("Map", "Mansion"); r:SetAttribute("Diff", "Normal"); r:SetAttribute("Leader", 0)
			end
		end
		table.sort(rooms, function(a, b) return a.name < b.name end)
		for _, room in rooms do prepSign(room) end
	end
	local vendor = lobby and lobby:FindFirstChild("UltVendor", true)
	local vTorso = vendor and vendor:FindFirstChild("Torso", true) :: BasePart?
	if vTorso then
		local pp = Instance.new("ProximityPrompt")
		pp.ActionText = "Ultimate Shop"; pp.ObjectText = "The Hooded Dealer"; pp.HoldDuration = 0
		pp.MaxActivationDistance = 12; pp.RequiresLineOfSight = false; pp.KeyboardKeyCode = Enum.KeyCode.F
		pp.Style = Enum.ProximityPromptStyle.Custom
		pp.Parent = vTorso
		pp.Triggered:Connect(function(p) Remotes.Fx:FireClient(p, "OpenUltShop") end)
	end
	-- the quest board (lobby_forest.luau): opens the QUESTS panel
	local qboard = lobby and lobby:FindFirstChild("QuestBoard")
	local qpart = qboard and qboard:FindFirstChild("Board") :: BasePart?
	if qpart then
		local pp = Instance.new("ProximityPrompt")
		pp.ActionText = "Quests"; pp.ObjectText = "Quest Board"; pp.HoldDuration = 0
		pp.MaxActivationDistance = 12; pp.RequiresLineOfSight = false; pp.KeyboardKeyCode = Enum.KeyCode.F
		pp.Style = Enum.ProximityPromptStyle.Custom
		pp.Parent = qpart
		pp.Triggered:Connect(function(p) Remotes.Fx:FireClient(p, "OpenQuests") end)
	end
	-- the bestiary altar (tools/build/lobby_detail.luau): opens the BESTIARY panel (monsters beaten, badges)
	local altar = lobby and lobby:FindFirstChild("BestiaryAltar")
	local apart = altar and altar:FindFirstChild("Prompt") :: BasePart?
	if apart then
		local pp = Instance.new("ProximityPrompt")
		pp.ActionText = "Bestiary"; pp.ObjectText = "Monsters & Badges"; pp.HoldDuration = 0
		pp.MaxActivationDistance = 14; pp.RequiresLineOfSight = false; pp.KeyboardKeyCode = Enum.KeyCode.F
		pp.Style = Enum.ProximityPromptStyle.Custom
		pp.Parent = apart
		pp.Triggered:Connect(function(p) Remotes.Fx:FireClient(p, "OpenBestiary") end)
	end
	-- the train at the station (tools/build/lobby_station.luau ParkedTrain): its door opens the PLAY panel
	local station = lobby and lobby:FindFirstChild("Station")
	local parked = station and station:FindFirstChild("ParkedTrain")
	local board = parked and parked:FindFirstChild("BoardPrompt", true) :: BasePart?
	if board then
		local pp = Instance.new("ProximityPrompt")
		pp.ActionText = "Board the train"; pp.ObjectText = "To the maps"; pp.HoldDuration = 0
		pp.MaxActivationDistance = 14; pp.RequiresLineOfSight = false; pp.KeyboardKeyCode = Enum.KeyCode.F
		pp.Style = Enum.ProximityPromptStyle.Custom
		pp.Parent = board
		pp.Triggered:Connect(function(p) if not p:GetAttribute("InMatch") then Remotes.Fx:FireClient(p, "OpenPlay") end end)
	end
	Remotes.BuyUlt.OnServerEvent:Connect(onBuyUlt)
	Remotes.Party.OnServerEvent:Connect(onParty)
	Players.PlayerRemoving:Connect(leaveParty)
	publish()
	-- the room leader changes the map / difficulty (must own the map)
	Remotes.RoomPick.OnServerEvent:Connect(function(p, roomName, mapId, diffId)
		if type(roomName) ~= "string" or type(mapId) ~= "string" or type(diffId) ~= "string" then return end
		for _, room in rooms do
			if room.name == roomName and room.leader == p then
				if room.countdownStart then room.countdownStart = os.clock() end -- a new pick restarts the countdown
				if Maps.byId[mapId] and Data.ownsMap(p, mapId) then room.map = mapId end
				if Maps.diffById[diffId] then room.diff = diffId end
				room.model:SetAttribute("Map", room.map)
				room.model:SetAttribute("Diff", room.diff)
				setMapLine(room)
			end
		end
	end)
	-- buy a map at the dealer
	Remotes.BuyMap.OnServerEvent:Connect(function(p, mapId)
		local m = type(mapId) == "string" and Maps.byId[mapId]
		if not m or m.campaign then return end -- (the campaign's buildings are never sold)
		if Data.ownsMap(p, m.id) then Remotes.Fx:FireClient(p, "UltResult", true, "You already own " .. m.name); return end
		if not Data.spend(p, m.price) then Remotes.Fx:FireClient(p, "UltResult", false, "Not enough cash for " .. m.name); return end
		Data.own(p, "Map_" .. m.id)
		task.spawn(Data.save, p)
		Remotes.Fx:FireClient(p, "UltResult", true, "Bought " .. m.name .. " - pick it in PLAY > ENDLESS")
	end)
	-- slot 2 = the second ultimate of the Double Ultimate pass
	Remotes.EquipUlt.OnServerEvent:Connect(function(p, id, slot)
		if type(id) ~= "string" then return end
		local second = slot == 2
		if second and not p:GetAttribute("DoubleUlt") then
			Remotes.Fx:FireClient(p, "UltResult", false, "The second slot needs the Double Ultimate pass")
			return
		end
		local u = Ultimates.byId[id]
		if Data.equipUlt(p, id, second and 2 or 1) then
			Remotes.Fx:FireClient(p, "UltResult", true, "Equipped " .. (u and u.name or id) .. (second and " in slot 2" or ""))
		elseif second then
			Remotes.Fx:FireClient(p, "UltResult", false, "Pick another ultimate for slot 2")
		end
	end)
	-- Double Ultimate: switch which of the two fires (in the park or in a fight, not while one is running)
	local lastSwap = {} :: { [Player]: number }
	Remotes.SwapUlt.OnServerEvent:Connect(function(p)
		if not p:GetAttribute("DoubleUlt") or p:GetAttribute("UltActive") then return end
		if os.clock() - (lastSwap[p] or 0) < 0.4 then return end
		lastSwap[p] = os.clock()
		if Data.swapUlts(p) then
			local u = Ultimates.byId[Data.equipped(p)]
			Remotes.Fx:FireClient(p, "UltSwapped", u and u.name or "")
		end
	end)
	Players.PlayerRemoving:Connect(function(p) lastSwap[p] = nil end)
	Remotes.ReturnLobby.OnServerEvent:Connect(function(p)
		if p:GetAttribute("InMatch") then Run.leave(p, "left") end
	end)
	Run.onReturnLobby = Lobby.returnPlayer
	if Run.mode == "Lobby" then
		task.spawn(function()
			while true do
				tick()
				task.wait(0.2)
			end
		end)
	end
end

return Lobby
