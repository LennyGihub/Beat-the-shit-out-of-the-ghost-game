-- One match per server: Intro -> Fight -> Victory -> Outside (go out the front door) -> plane crash
-- -> Shop (pilot's stand with a random stock) -> back inside for the next ghost.
-- In a reserved match server every player is in the match; in Studio a lobby queue starts a local match here.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.Shared.Config)
local Items = require(RS.Shared.Items)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Furniture = require(script.Parent.Furniture)
local Ghost = require(script.Parent.Ghost)
local Combat = require(script.Parent.Combat)
local Props = require(script.Parent.Props)

local Round = {}
Round.mode = "Lobby" -- "Lobby" (public / Studio) or "Match" (reserved server)
Round.onReturnLobby = nil :: ((p: Player) -> ())?
local state = "Idle"
local level = 1
local spawned = {} :: { Instance }
local busy = false
local rng = Random.new()
local DOOR = Vector3.new(0, 7, 62)
local SPAWNS = {
	Vector3.new(0, 27.6, -24), Vector3.new(-57, 6.6, -30), Vector3.new(57, 6.6, 30),
	Vector3.new(-57, 6.6, 30), Vector3.new(-18, 27.6, -44), Vector3.new(18, 6.6, -44),
}

local function setState(s: string, objective: string?)
	state = s
	RS:SetAttribute("RoundState", s)
	RS:SetAttribute("Objective", objective or "")
	RS:SetAttribute("GhostLevel", level)
end
local function setWaypoint(pos: Vector3?, label: string?)
	RS:SetAttribute("Waypoint", pos)
	RS:SetAttribute("WaypointLabel", label or "")
end

function Round.state(): string return state end

function Round.matchPlayers(): { Player }
	local out = {}
	for _, p in Players:GetPlayers() do if p:GetAttribute("InMatch") then table.insert(out, p) end end
	return out
end

local function hrpOf(p: Player): BasePart?
	return p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function insideHouse(pos: Vector3): boolean
	local mn, mx = Config.House.Min, Config.House.Max
	return pos.X > mn.X and pos.X < mx.X and pos.Z > mn.Z and pos.Z < mx.Z and pos.Y < 60
end

local function clearSpawned()
	for _, i in spawned do i:Destroy() end
	spawned = {}
end
local function keep(i: Instance) table.insert(spawned, i); return i end

local function prompt(parent: Instance, action: string, object: string, hold: number?, key: Enum.KeyCode?): ProximityPrompt
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = action; pp.ObjectText = object; pp.HoldDuration = hold or 0
	pp.MaxActivationDistance = 10; pp.RequiresLineOfSight = false
	pp.KeyboardKeyCode = key or Enum.KeyCode.F -- E is "lift furniture"
	pp.Parent = parent
	return pp
end

function Round.addToMatch(p: Player)
	p:SetAttribute("InMatch", true)
	local sp = workspace:FindFirstChild("MatchSpawn")
	if sp then p.RespawnLocation = sp :: SpawnLocation end
end

function Round.removeFromMatch(p: Player)
	p:SetAttribute("InMatch", false)
	local sp = workspace:FindFirstChild("LobbySpawn")
	if sp then p.RespawnLocation = sp :: SpawnLocation end
end

function Round.running(): boolean return state ~= "Idle" end

function Round.startFight()
	if busy then return end
	busy = true
	level = 1
	local list = Round.matchPlayers()
	for _, p in list do
		local d = Data.get(p)
		if d then level = math.max(level, d.GhostLevel) end
	end
	clearSpawned()
	setWaypoint(nil)
	Ghost.despawn()
	Furniture.reset()
	Combat.healAll(list)
	for _, p in list do
		local hrp = hrpOf(p)
		if hrp and not insideHouse(hrp.Position) then
			(p.Character :: Model):PivotTo(CFrame.new(Config.SpawnInside + Vector3.new(rng:NextInteger(-6, 6), 0, 0)))
		end
	end
	setState("Intro", "Something is in the house...")
	for _, p in list do Remotes.Fx:FireClient(p, "Intro", level) end
	task.wait(6)
	if #Round.matchPlayers() == 0 then busy = false; return end
	local best, bestD = SPAWNS[1], -1
	for _, sp in SPAWNS do
		local d = math.huge
		for _, p in Round.matchPlayers() do
			local hrp = hrpOf(p)
			if hrp then d = math.min(d, (hrp.Position - sp).Magnitude) end
		end
		if d > bestD and d < math.huge then best, bestD = sp, d end
	end
	Ghost.spawn(level, best)
	setState("Fight", "")
	busy = false
end

local function onGhostDeath(g)
	setState("Victory", "GO OUTSIDE")
	for _, p in Round.matchPlayers() do
		local reward = math.floor((Config.Reward.Base + (g.level - 1) * Config.Reward.PerLevel) * Combat.stat(p, "cash"))
		Data.addCash(p, reward)
		Data.winGhost(p, g.level)
		task.spawn(Data.save, p)
		Remotes.Fx:FireClient(p, "Victory", reward)
	end
	-- a light shaft at the front door so nobody can miss the exit
	local beam = Instance.new("Part")
	beam.Name = "ExitBeacon"; beam.Anchored = true; beam.CanCollide = false; beam.CanQuery = false; beam.CanTouch = false
	beam.Material = Enum.Material.Neon; beam.Color = Color3.fromRGB(255, 200, 120); beam.Transparency = 0.6
	beam.Size = Vector3.new(10, 26, 1); beam.CFrame = CFrame.new(0, 15, 58.4)
	local l = Instance.new("PointLight"); l.Range = 30; l.Brightness = 2; l.Color = beam.Color; l.Parent = beam
	beam.Parent = workspace
	keep(beam)
	setWaypoint(DOOR, "EXIT")
	task.wait(3)
	setState("Outside", "GO OUTSIDE")
end

local function buildWreck(land: Vector3, facePos: Vector3)
	local tpl = RS:FindFirstChild("PlaneModel") :: Model?
	if not tpl then return end
	local w = tpl:Clone()
	w.Name = "PlaneWreck"
	local yaw = CFrame.lookAt(land, Vector3.new(facePos.X, land.Y, facePos.Z)).Rotation
	w:PivotTo(CFrame.new(land + Vector3.new(0, 2.2, 0)) * yaw * CFrame.Angles(0, math.rad(70), 0) * CFrame.Angles(math.rad(-9), 0, math.rad(7)))
	for _, p in w:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = true end
	end
	for _, name in { "EngineL", "EngineR", "Body" } do
		local part = w:FindFirstChild(name, true) :: BasePart?
		if part then
			local f = Instance.new("Fire"); f.Size = name == "Body" and 9 or 6; f.Heat = 12; f.Parent = part
			local sm = Instance.new("Smoke"); sm.Color = Color3.fromRGB(40, 38, 36); sm.Opacity = 0.35; sm.RiseVelocity = 8; sm.Size = 6; sm.Parent = part
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 130, 60); l.Range = 34; l.Brightness = 0.9; l.Parent = part
		end
	end
	w.Parent = workspace
	keep(w)
end

-- weighted random stock: rarity first, then an item of that rarity
local function rollStock(n: number): { any }
	local total = 0
	for _, r in Items.rarity do total += r.weight end
	local picked, out = {}, {}
	local tries = 0
	while #out < n and tries < 200 do
		tries += 1
		local x, rar = rng:NextNumber(0, total), 1
		for i, r in Items.rarity do
			x -= r.weight
			if x <= 0 then rar = i; break end
		end
		local pool = {}
		for _, it in Items.list do if it.rarity == rar and not picked[it.id] then table.insert(pool, it) end end
		if #pool > 0 then
			local it = pool[rng:NextInteger(1, #pool)]
			picked[it.id] = true
			table.insert(out, it)
		end
	end
	table.sort(out, function(a, b) return a.rarity > b.rarity end)
	return out
end

local function billboard(parent: BasePart, it, rar, high: boolean)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(150, 58); bb.StudsOffset = Vector3.new(0, high and 3.6 or 2.3, 0); bb.MaxDistance = 22; bb.AlwaysOnTop = false
	bb.Parent = parent
	local function label(text: string, y: number, h: number, color: Color3, font: Enum.Font)
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1; t.Size = UDim2.new(1, 0, h, 0); t.Position = UDim2.new(0, 0, y, 0)
		t.Text = text; t.TextScaled = true; t.Font = font; t.TextColor3 = color
		t.TextStrokeTransparency = 0.2; t.TextStrokeColor3 = Color3.fromRGB(14, 10, 8)
		t.Parent = bb
	end
	label(rar.name, 0, 0.26, rar.color, Enum.Font.SpecialElite)
	label(string.upper(it.name), 0.26, 0.4, Color3.fromRGB(235, 225, 205), Enum.Font.PermanentMarker)
	label("$" .. it.price, 0.66, 0.34, Color3.fromRGB(150, 220, 110), Enum.Font.PermanentMarker)
end

local function onBuy(player: Player, id: string, at: Vector3)
	local it = Items.byId[id]
	if not it or not player:GetAttribute("InMatch") then return end
	local hrp = hrpOf(player)
	if not hrp or (hrp.Position - at).Magnitude > 16 then return end
	if Data.owns(player, id) then
		Remotes.Fx:FireClient(player, "BuyResult", false, "You already own " .. it.name)
		return
	end
	if not Data.spend(player, it.price) then
		Remotes.Fx:FireClient(player, "BuyResult", false, "Not enough cash for " .. it.name)
		return
	end
	Data.own(player, id)
	Combat.refreshHealth(player)
	task.spawn(Data.save, player)
	Remotes.Fx:FireClient(player, "BuyResult", true, it.name, at)
end

local function buildStand(land: Vector3, facePos: Vector3)
	local tpl = SS:FindFirstChild("StandTemplate") :: Model?
	if not tpl then return nil end
	local stand = tpl:Clone()
	local dir = Vector3.new(facePos.X - land.X, 0, facePos.Z - land.Z).Unit
	local spot = land + dir * 30 + dir:Cross(Vector3.yAxis) * 4 -- well clear of the burning wreck
	stand:PivotTo(CFrame.lookAt(Vector3.new(spot.X, 0, spot.Z), Vector3.new(facePos.X, 0, facePos.Z)))
	stand.Parent = workspace
	keep(stand)
	-- the injured pilot lies in the dirt next to his stand
	local pilotTpl = SS:FindFirstChild("PilotLying") :: Model?
	if pilotTpl then
		local pilot = pilotTpl:Clone()
		pilot:PivotTo(stand:GetPivot() * CFrame.new(-7.5, 0, 1.5) * CFrame.Angles(0, math.rad(-25), 0))
		pilot.Parent = workspace
		keep(pilot)
	end
	for i, it in rollStock(6) do
		local slot = stand:FindFirstChild("Slot" .. i, true) :: Attachment?
		if slot then
			local rar = Items.rarity[it.rarity]
			local prop = Props.build(it.kind, rar.color, it.rarity)
			prop.Name = "Item_" .. it.id
			prop:PivotTo(slot.WorldCFrame * CFrame.Angles(0, math.rad(rng:NextNumber(-25, 25)), 0))
			prop.Parent = stand
			billboard(prop.PrimaryPart :: BasePart, it, rar, i > 3)
			local pp = prompt(prop.PrimaryPart :: BasePart, "Buy  $" .. it.price, it.name .. "  (" .. it.desc .. ")", 0.35)
			pp.MaxActivationDistance = 9
			pp.Triggered:Connect(function(p) onBuy(p, it.id, slot.WorldPosition) end)
		end
	end
	local sign = stand:FindFirstChild("Sign", true) :: BasePart?
	if sign then
		local pp = prompt(sign, "Return to lobby", "Leave the house", 1.2, Enum.KeyCode.R)
		pp.Triggered:Connect(function(p) if Round.onReturnLobby then Round.onReturnLobby(p) end end)
	end
	return stand
end

local function crash(trigger: BasePart)
	setState("Crash", "")
	setWaypoint(nil)
	for _, i in spawned do if i.Name == "ExitBeacon" then i:Destroy() end end
	local pos = trigger.Position
	local land = Vector3.new(math.clamp(pos.X + 28, -70, 70), 0, math.clamp(pos.Z + 42, 105, 150))
	for _, p in Round.matchPlayers() do Remotes.Fx:FireClient(p, "PlaneCrash", land, pos) end
	task.wait(4.2)
	buildWreck(land, pos)
	for _, p in Round.matchPlayers() do Remotes.Fx:FireClient(p, "PlaneImpact", land) end
	task.wait(2)
	local stand = buildStand(land, pos)
	-- the front door now starts the next ghost
	local door = Instance.new("Part")
	door.Name = "NextGhostDoor"; door.Anchored = true; door.CanCollide = false; door.Transparency = 1
	door.Size = Vector3.new(10, 14, 2); door.CFrame = CFrame.new(0, 9, 61); door.Parent = workspace
	keep(door)
	local pp = prompt(door, "Fight the next ghost", "Front door", 1.0)
	pp.Triggered:Connect(function(p)
		if state == "Shop" and p:GetAttribute("InMatch") then task.spawn(Round.startFight) end
	end)
	setState("Shop", "BUY AT THE PILOT'S STAND - THEN GO BACK INSIDE")
	if stand then setWaypoint((stand:GetPivot() * CFrame.new(0, 4, 0)).Position, "PILOT'S STAND") end
	for _, p in Round.matchPlayers() do Remotes.Fx:FireClient(p, "ShopReady") end
end

-- start a match with these players (Studio local match, or the players of a reserved server)
function Round.beginMatch(list: { Player })
	for _, p in list do
		Round.addToMatch(p)
		local ch = p.Character
		if ch then ch:PivotTo(CFrame.new(Config.SpawnInside + Vector3.new(rng:NextInteger(-6, 6), 0, 0))) end
	end
	task.spawn(Round.startFight)
end

function Round.endMatch()
	Ghost.despawn()
	clearSpawned()
	setWaypoint(nil)
	setState("Idle", "")
end

function Round.start()
	Ghost.onDeath = function(g) task.spawn(onGhostDeath, g) end
	Remotes.NextGhost.OnServerEvent:Connect(function(p)
		if state == "Shop" and p:GetAttribute("InMatch") then task.spawn(Round.startFight) end
	end)
	RunService.Heartbeat:Connect(function(dt)
		Ghost.step(dt)
		if state == "Outside" then
			for _, p in Round.matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and (hrp.Position.Z > Config.OutsideZ or not insideHouse(hrp.Position)) then
					task.spawn(crash, hrp)
					break
				end
			end
		end
	end)
	setState("Idle", "")
end

return Round
