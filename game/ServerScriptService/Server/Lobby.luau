-- PS2 park lobby: queue rooms for 1-4 players (step on the pad), countdown, then the party goes to its own
-- reserved match server. In Studio (no teleports) the party plays a local match in this server instead.
-- Also runs the ultimate shop (vendor in the park) and sends players back to the lobby.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Ultimates = require(RS.Shared.Ultimates)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Run = require(script.Parent.Run)

local Lobby = {}
local COUNTDOWN = 5
local rooms = {} :: { any }

local function hrpOf(p: Player): BasePart?
	return p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function onPad(pad: BasePart, pos: Vector3): boolean
	local lp = pad.CFrame:PointToObjectSpace(pos)
	return math.abs(lp.X) <= pad.Size.X / 2 and math.abs(lp.Z) <= pad.Size.Z / 2 and lp.Y > -1 and lp.Y < 9
end

local function setSign(room, title: string, line: string, color: Color3?)
	local gui = room.sign and room.sign:FindFirstChild("Gui")
	if not gui then return end
	local t = gui:FindFirstChild("Count") :: TextLabel?
	local s = gui:FindFirstChild("Status") :: TextLabel?
	if t then t.Text = title end
	if s then s.Text = line; s.TextColor3 = color or Color3.fromRGB(220, 210, 180) end
end

local function launch(room, members: { Player })
	room.countdownStart = nil
	if RunService:IsStudio() then
		if Run.running() then
			for _, p in members do Remotes.Fx:FireClient(p, "Toast", "A match is already running in this Studio test") end
			return
		end
		Run.beginMatch(members)
		return
	end
	setSign(room, room.size .. " PLAYER" .. (room.size > 1 and "S" or ""), "TELEPORTING...", Color3.fromRGB(150, 220, 110))
	local ok, code = pcall(function() return TeleportService:ReserveServer(game.PlaceId) end)
	if not ok then
		warn("[Lobby] ReserveServer failed: " .. tostring(code))
		for _, p in members do Remotes.Fx:FireClient(p, "Toast", "Teleport failed, try again") end
		return
	end
	local opts = Instance.new("TeleportOptions")
	opts.ReservedServerAccessCode = code
	opts:SetTeleportData({ size = #members })
	for _, p in members do Data.save(p) end
	local tok, err = pcall(function() TeleportService:TeleportAsync(game.PlaceId, members, opts) end)
	if not tok then
		warn("[Lobby] Teleport failed: " .. tostring(err))
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

function Lobby.returnPlayer(p: Player)
	if Run.mode == "Match" then
		Data.save(p)
		local ok, err = pcall(function() TeleportService:TeleportAsync(game.PlaceId, { p }) end)
		if not ok then warn("[Lobby] return failed: " .. tostring(err)) end
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
	if roomFolder then
		for _, r in roomFolder:GetChildren() do
			local pad = r:FindFirstChild("Pad", true) :: BasePart?
			if pad then
				table.insert(rooms, { name = r.Name, size = r:GetAttribute("Size") or 1, pad = pad, sign = r:FindFirstChild("Sign", true), countdownStart = nil })
			end
		end
		table.sort(rooms, function(a, b) return a.name < b.name end)
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
	Remotes.BuyUlt.OnServerEvent:Connect(onBuyUlt)
	Remotes.EquipUlt.OnServerEvent:Connect(function(p, id)
		if type(id) == "string" and Data.equipUlt(p, id) then
			local u = Ultimates.byId[id]
			Remotes.Fx:FireClient(p, "UltResult", true, "Equipped " .. (u and u.name or id))
		end
	end)
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
