-- A run (one per match server): fight ghost after ghost in the house. Each kill pays RUN cash; events
-- (plane / van / train) open a shop that sells physical items for run cash and lasts for the next 3 ghosts.
-- Dying or leaving ends your run: you get real cash (for ultimates) based on kills, ghost levels and damage.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Config = require(RS.Shared.Config)
local Items = require(RS.Shared.Items)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Furniture = require(script.Parent.Furniture)
local Ghost = require(script.Parent.Ghost)
local Combat = require(script.Parent.Combat)
local Inventory = require(script.Parent.Inventory)
local Events = require(script.Parent.Events)

local Run = {}
Run.mode = "Lobby" -- "Lobby" (public / Studio) or "Match" (reserved server)
Run.onReturnLobby = nil :: ((p: Player) -> ())?
local state = "Idle"
local kills = 0
local level = 1
local event = nil :: any
local eventLeft = 0
local lastKind = ""
local busy = false
local breakUntil = 0
local stats = {} :: { [Player]: { earned: number, damage: number, kills: number, paid: boolean } }
local temp = {} :: { Instance }
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
function Run.state(): string return state end
function Run.running(): boolean return state ~= "Idle" end

function Run.matchPlayers(): { Player }
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
local function clearTemp() for _, i in temp do i:Destroy() end temp = {} end

function Run.addToMatch(p: Player)
	p:SetAttribute("InMatch", true)
	p:SetAttribute("RunCash", 0)
	p:SetAttribute("RunKills", 0)
	stats[p] = { earned = 0, damage = 0, kills = 0, paid = false }
	Inventory.clear(p)
	local sp = workspace:FindFirstChild("MatchSpawn")
	if sp then p.RespawnLocation = sp :: SpawnLocation end
end

function Run.removeFromMatch(p: Player)
	p:SetAttribute("InMatch", false)
	p:SetAttribute("RunCash", 0)
	Inventory.clear(p)
	local sp = workspace:FindFirstChild("LobbySpawn")
	if sp then p.RespawnLocation = sp :: SpawnLocation end
end

-- real cash for the run so far (paid once)
function Run.payout(p: Player, reason: string): number
	local st = stats[p]
	if not st or st.paid then return 0 end
	st.paid = true
	local g = Ghost.current
	if g and g.damageBy[p] then st.damage += g.damageBy[p]; g.damageBy[p] = 0 end
	local cash = math.floor(st.earned + st.damage / Config.Payout.DamageDiv)
	Data.addCash(p, cash)
	task.spawn(Data.save, p)
	Remotes.Fx:FireClient(p, "RunOver", reason, cash, st.kills)
	return cash
end

local function doorPrompt()
	local door = Instance.new("Part")
	door.Name = "NextGhostDoor"; door.Anchored = true; door.CanCollide = false; door.CanQuery = false; door.Transparency = 1
	door.Size = Vector3.new(10, 14, 2); door.CFrame = CFrame.new(0, 9, 59); door.Parent = workspace
	table.insert(temp, door)
	local pp = Events.prompt(door, "Fight the next ghost", "Front door", 0.8, Enum.KeyCode.F)
	pp.MaxActivationDistance = 12
	pp.Triggered:Connect(function(p)
		if (state == "Break" or state == "Outside") and p:GetAttribute("InMatch") then task.spawn(Run.startFight) end
	end)
end

function Run.startFight()
	if busy or #Run.matchPlayers() == 0 then return end
	busy = true
	level = kills + 1
	clearTemp()
	setWaypoint(nil)
	Ghost.despawn()
	Furniture.reset()
	Inventory.clearWorld()
	local list = Run.matchPlayers()
	Combat.healAll(list)
	for _, p in list do
		local hrp = hrpOf(p)
		if hrp and not insideHouse(hrp.Position) then
			(p.Character :: Model):PivotTo(CFrame.new(Config.SpawnInside + Vector3.new(rng:NextInteger(-6, 6), 0, 0)))
		end
	end
	setState("Intro", "GHOST " .. level .. " IS COMING...")
	for _, p in list do Remotes.Fx:FireClient(p, "Intro", level) end
	task.wait(5)
	if #Run.matchPlayers() == 0 then busy = false; return end
	local best, bestD = SPAWNS[1], -1
	for _, sp in SPAWNS do
		local d = math.huge
		for _, p in Run.matchPlayers() do
			local hrp = hrpOf(p)
			if hrp then d = math.min(d, (hrp.Position - sp).Magnitude) end
		end
		if d > bestD and d < math.huge then best, bestD = sp, d end
	end
	Ghost.spawn(level, best)
	setState("Fight", "")
	busy = false
end

local function startBreak()
	breakUntil = os.clock() + Config.BreakTime
	setState("Break", "")
	doorPrompt()
	if event then setWaypoint(event.shopPos, event.label) end
end

local function onGhostDeath(g)
	kills += 1
	local reward = Config.Reward.Base + (g.level - 1) * Config.Reward.PerLevel
	for _, p in Run.matchPlayers() do
		local st = stats[p]
		if st then
			st.earned += Config.Payout.PerKill + Config.Payout.PerLevel * g.level
			st.kills += 1
			st.damage += g.damageBy[p] or 0
			g.damageBy[p] = 0
			p:SetAttribute("RunKills", st.kills)
		end
		p:SetAttribute("RunCash", (p:GetAttribute("RunCash") or 0) + reward)
		Data.winGhost(p, g.level)
		Remotes.Fx:FireClient(p, "Victory", reward)
	end
	-- a new event is due after the first kill and every EventLife kills after that
	if event then eventLeft -= 1 end
	if not event or eventLeft <= 0 then
		setState("Victory", "GO OUTSIDE")
		local beam = Instance.new("Part")
		beam.Name = "ExitBeacon"; beam.Anchored = true; beam.CanCollide = false; beam.CanQuery = false; beam.CanTouch = false
		beam.Material = Enum.Material.Neon; beam.Color = Color3.fromRGB(255, 200, 120); beam.Transparency = 0.6
		beam.Size = Vector3.new(10, 26, 1); beam.CFrame = CFrame.new(0, 15, 58.4); beam.Parent = workspace
		local l = Instance.new("PointLight"); l.Range = 30; l.Brightness = 2; l.Color = beam.Color; l.Parent = beam
		table.insert(temp, beam)
		setWaypoint(DOOR, "EXIT")
		task.wait(3)
		setState("Outside", "GO OUTSIDE")
		breakUntil = os.clock() + 60 -- if nobody goes out, the event still comes
	else
		task.wait(3)
		startBreak()
	end
end

local function spawnEvent(trigger: Vector3)
	setState("Event", "")
	setWaypoint(nil)
	for _, i in temp do if i.Name == "ExitBeacon" then i:Destroy() end end
	if event then Events.despawn(event); event = nil end
	local kinds = {}
	for _, k in Events.KINDS do if k ~= lastKind then table.insert(kinds, k) end end
	local kind = kinds[rng:NextInteger(1, #kinds)]
	local forced = RunService:IsStudio() and RS:GetAttribute("DebugEventKind") -- Studio test hook
	if type(forced) == "string" and table.find(Events.KINDS, forced) then kind = forced end
	lastKind = kind
	event = Events.spawn(kind, trigger)
	eventLeft = Config.EventLife
	for _, p in Run.matchPlayers() do Remotes.Fx:FireClient(p, "ShopReady", kind) end
	startBreak()
end

local function onBuy(p: Player, id: string, at: Vector3)
	local it = Items.byId[id]
	if not it or not p:GetAttribute("InMatch") then return end
	local hrp = hrpOf(p)
	if not hrp or (hrp.Position - at).Magnitude > 18 then return end
	local cash = p:GetAttribute("RunCash") or 0
	if cash < it.price then
		Remotes.Fx:FireClient(p, "BuyResult", false, "Not enough run cash for " .. it.name)
		return
	end
	if not Inventory.give(p, id) then
		Remotes.Fx:FireClient(p, "BuyResult", false, "Hotbar full - drop something (X)")
		return
	end
	p:SetAttribute("RunCash", cash - it.price)
	Remotes.Fx:FireClient(p, "BuyResult", true, it.name, at)
end

function Run.leave(p: Player, reason: string)
	if not p:GetAttribute("InMatch") then return end
	Run.payout(p, reason)
	if Run.onReturnLobby then Run.onReturnLobby(p) end
end

function Run.onDied(p: Player)
	if not p:GetAttribute("InMatch") then return end
	Run.payout(p, "died")
	task.delay(4, function()
		if p.Parent and p:GetAttribute("InMatch") and Run.onReturnLobby then Run.onReturnLobby(p) end
	end)
end

-- start a match with these players (Studio local match, or the players of a reserved server)
function Run.beginMatch(list: { Player })
	kills, level, eventLeft, lastKind = 0, 1, 0, ""
	if event then Events.despawn(event); event = nil end
	for _, p in list do
		Run.addToMatch(p)
		local ch = p.Character
		if ch then ch:PivotTo(CFrame.new(Config.SpawnInside + Vector3.new(rng:NextInteger(-6, 6), 0, 0))) end
	end
	task.spawn(Run.startFight)
end

function Run.endMatch()
	Ghost.despawn()
	clearTemp()
	if event then Events.despawn(event); event = nil end
	Inventory.clearWorld()
	setWaypoint(nil)
	setState("Idle", "")
end

function Run.start()
	Ghost.onDeath = function(g) task.spawn(onGhostDeath, g) end
	Events.onBuy = onBuy
	Events.onLeave = function(p) Run.leave(p, "left") end
	Remotes.NextGhost.OnServerEvent:Connect(function(p)
		if state == "Break" and p:GetAttribute("InMatch") then task.spawn(Run.startFight) end
	end)
	Players.PlayerRemoving:Connect(function(p)
		if p:GetAttribute("InMatch") then
			Run.payout(p, "left")
			Data.save(p)
		end
		stats[p] = nil
		task.defer(function()
			if Run.running() and #Run.matchPlayers() == 0 then Run.endMatch() end
		end)
	end)
	local lastTick = 0
	RunService.Heartbeat:Connect(function(dt)
		Ghost.step(dt)
		local now = os.clock()
		if state == "Outside" then
			for _, p in Run.matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and (hrp.Position.Z > Config.OutsideZ or not insideHouse(hrp.Position)) then
					task.spawn(spawnEvent, hrp.Position)
					break
				end
			end
			if state == "Outside" and now > breakUntil then task.spawn(spawnEvent, DOOR + Vector3.new(0, 0, 10)) end
		elseif state == "Break" and now - lastTick > 0.5 then
			lastTick = now
			local left = math.max(0, math.ceil(breakUntil - now))
			RS:SetAttribute("Objective", (event and (event.label .. " IS OPEN OUTSIDE - ") or "") .. "NEXT GHOST IN " .. left)
			if left <= 0 then task.spawn(Run.startFight) end
		end
	end)
	if RunService:IsStudio() then
		-- Studio test hook: RS attribute DebugSpawnEvent = "plane" | "van" | "train" spawns that event now
		RS:GetAttributeChangedSignal("DebugSpawnEvent"):Connect(function()
			local k = RS:GetAttribute("DebugSpawnEvent")
			if type(k) == "string" and Run.running() then
				RS:SetAttribute("DebugEventKind", (string.gsub(k, "#.*", "")))
				task.spawn(spawnEvent, DOOR + Vector3.new(0, 0, 10))
			end
		end)
	end
	setState("Idle", "")
end

return Run
