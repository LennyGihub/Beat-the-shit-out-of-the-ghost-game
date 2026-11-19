-- A run (one per match server): fight ghost after ghost in the house. Each kill pays RUN cash; events
-- (plane / van / train) open a shop that sells physical items for run cash and lasts for the next 3 ghosts.
-- Dying or leaving ends your run: you get real cash (for ultimates) based on kills, ghost levels and damage.
-- CAMPAIGN STAGES (Shared/Campaign; the map id is a stage id): one building per trip. The party ARRIVES by train
-- in the yard (Fx "TrainArrive", state "Arrive"), walks in (state "Approach": the fight starts once someone is
-- inside), fights the building's one monster (its last building's monster comes back EVOLVED as phase 2), and
-- the building is CLEARED (saved per player: Data.clearStage, best difficulty): cash + XP paid, Fx "StageClear",
-- state "Cleared". Then Remotes.Stage: "next" (the next building), "again" (same one) - the train leaves
-- (Fx "TrainDepart") and comes back to the other building in this same server - or "lobby".
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
local Monsters = require(RS.Shared.Monsters)
local Maps = require(RS.Shared.Maps)
local Levels = require(RS.Shared.Levels)
local MapLoader = require(script.Parent.MapLoader)
local Quests = require(script.Parent.Quests)
local Friends = require(script.Parent.Friends)
local Bestiary = require(script.Parent.Bestiary)
local Supplies = require(script.Parent.Supplies)
local Campaign = require(RS.Shared.Campaign)

local Run = {}
Run.mode = "Lobby" -- "Lobby" (public / Studio) or "Match" (reserved server)
Run.onReturnLobby = nil :: ((p: Player) -> ())?
local state = "Idle"
local kills = 0
local level = 1
local event = nil :: any
local eventLeft = 0
local lastKind = ""
local lastMonster = ""
local lastEvolved = ""
local prevMonster = "" -- the ghost before the last one
-- the monsters this run has already met (no monster twice until all have come: Monsters.pickFresh)
local seenMonsters = {} :: { [string]: boolean }
local seenEvolved = {} :: { [string]: boolean }
local busy = false
local breakUntil = 0
-- secondChance = the free revive of the SECOND CHANCE pass was used in this run
local stats = {} :: { [Player]: { earned: number, damage: number, kills: number, paid: boolean, revives: number?, secondChance: boolean? } }
local temp = {} :: { Instance }
local rng = Random.new()
local DOOR = Vector3.new(0, 7, 62)
local diff = Maps.diffById[Maps.defaultDiff] -- difficulty of this run (monster stats + cash multiplier)
-- the campaign building of this match (nil = the old endless house run: the Mansion, admin 'start')
local stage: Campaign.Stage? = nil
local phase = 1 -- 2 = the last building's monster came back evolved
local arrived = false -- the party got off the train (startFight from Main is the arrival then)
local approachUntil = 0
local choiceUntil = 0
local TRAIN_ARRIVE = 8.5 -- seconds of the client's arrival cinematic (Client/TrainRide)
local TRAIN_DEPART = 5.5 -- seconds of the client's departure cinematic
local YARD = Vector3.new(0, 3.4, 141) -- where the train lets you off (the yard's railway runs at z = 150)

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
-- in the house: the usual house box, grown to the loaded map's own outside walls (Ghost.houseBounds: the ship is
-- 200 studs long, its ends are past the box)
local function insideHouse(pos: Vector3): boolean
	local mn, mx = Config.House.Min, Config.House.Max
	local B = Ghost.houseBounds()
	mn = Vector3.new(math.min(mn.X, B.min.X), mn.Y, math.min(mn.Z, B.min.Z))
	mx = Vector3.new(math.max(mx.X, B.max.X), mx.Y, math.max(mx.Z, B.max.Z))
	return pos.X > mn.X and pos.X < mx.X and pos.Z > mn.Z and pos.Z < mx.Z and pos.Y < 60
end
local function clearTemp() for _, i in temp do i:Destroy() end temp = {} end

-- run cash multipliers: friend booster, the 2X MONEY pass, the VIP pass (+20%)
local function cashMult(p: Player): number
	return Friends.mult(p) * (p:GetAttribute("Money2") and 2 or 1) * (p:GetAttribute("VIP") and Config.Vip.CashBonus or 1)
end

-- noPay = the sandbox (Server/Sandbox): in the house like in a run, but nothing is ever paid out
function Run.addToMatch(p: Player, noPay: boolean?)
	p:SetAttribute("InMatch", true)
	p:SetAttribute("RunCash", 0)
	p:SetAttribute("RunKills", 0)
	stats[p] = { earned = 0, damage = 0, kills = 0, paid = noPay == true, revives = 0, secondChance = false }
	Inventory.clear(p)
	if p:GetAttribute("GlockPass") then Inventory.give(p, "Glock18") end -- Robux pass: in every run
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

-- real cash for the run so far (paid once). bonusXP: a cleared campaign building's extra XP. reason "cleared" =
-- the caller shows the result (Fx "StageClear"), not the run-over screen. Returns cash, xp, level before, after.
function Run.payout(p: Player, reason: string, bonusXP: number?): (number, number, number, number)
	local st = stats[p]
	if not st or st.paid then return 0, 0, 0, 0 end
	st.paid = true
	if st.kills > 0 then Quests.add(p, "runs") end -- a finished run (at least one monster knocked out)
	local g = Ghost.current
	if g and g.damageBy[p] then st.damage += g.damageBy[p]; g.damageBy[p] = 0 end
	local cash = math.floor((st.earned + st.damage / Config.Payout.DamageDiv * diff.reward) * cashMult(p))
	Data.addCash(p, cash)
	-- and the XP for the player's level (Shared/Levels)
	local xp = Levels.runXP(st.kills, st.damage, diff.id) + math.floor((bonusXP or 0) * Levels.diffMult(diff.id))
	local before, after = Data.addXP(p, xp)
	task.spawn(Data.save, p)
	if reason ~= "cleared" then Remotes.Fx:FireClient(p, "RunOver", reason, cash, st.kills, xp, before, after) end
	return cash, xp, before, after
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
	-- a campaign building: the party arrives by train first (Main calls this once the party is in)
	if stage and not arrived then task.spawn(Run.startStage); return end
	if busy or #Run.matchPlayers() == 0 then return end
	busy = true
	if Run.respawnSpectators then Run.respawnSpectators() end -- (normally done when the last wave ended)
	level = stage and stage.level or kills + 1
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
			(p.Character :: Model):PivotTo(CFrame.new(MapLoader.spawnInside() + Vector3.new(rng:NextInteger(-6, 6), 0, 0)))
		end
	end
	-- ghost 1 is always the Woman; after that the run meets every monster once (the Conqueror too, same odds) before
	-- any comes again, and never one of the last two you fought (Monsters.pickFresh; Studio hook: RS attribute
	-- DebugMonster = id). Every 3rd ghost is an EVOLVED variant (tier 1 = the first one of the run, kept beatable):
	-- those have their own "met" set. EASY has no bosses (Maps difficulty.bosses).
	local def
	local evoTier: number? = nil
	if stage then
		-- a campaign building: its own monster; phase 2 = the same monster EVOLVED (tier by difficulty)
		def = Monsters.byId[stage.monster] or Monsters.byId.Woman
		if phase >= 2 and Monsters.evo[def.id] then evoTier = math.clamp((Campaign.diffRank[diff.id] or 2) - 1, 1, 3) end
	elseif Monsters.isEvolvedWave(level) and diff.bosses then
		evoTier = level // 3
		def = Monsters.pickFresh(seenEvolved, { lastMonster, prevMonster }, rng) -- not the last two you fought
	elseif level <= 1 then
		def = Monsters.byId.Woman
		seenMonsters.Woman = true
	else
		def = Monsters.pickFresh(seenMonsters, { lastMonster, prevMonster }, rng) -- never one of the last two
	end
	local forced = RS:GetAttribute("AdminMonster") or (RunService:IsStudio() and RS:GetAttribute("DebugMonster")) -- admin panel / Studio hook
	if type(forced) == "string" and Monsters.byId[forced] then def = Monsters.byId[forced] end
	local forcedEvo = RS:GetAttribute("AdminEvolved") or (RunService:IsStudio() and RS:GetAttribute("DebugEvolved")) -- admin 'evolved on'
	if forcedEvo then evoTier = type(forcedEvo) == "number" and forcedEvo or math.max(1, level // 3) end
	-- admin 'boss <id> [tier]': that monster's boss variant, this ghost only
	local once = RS:GetAttribute("AdminBossOnce")
	if type(once) == "string" then
		RS:SetAttribute("AdminBossOnce", nil)
		local id, t = string.match(once, "^(%w+):(%d)$")
		if id and Monsters.byId[id] and Monsters.evo[id] then
			def = Monsters.byId[id]
			evoTier = math.clamp(tonumber(t) or 1, 1, 3)
		end
	end
	prevMonster = lastMonster
	lastMonster = def.id
	if evoTier then lastEvolved = def.id end
	local shown = evoTier and Monsters.evolved(def.id, evoTier) or def
	-- a short warning, then the monster makes its entrance (Ghost.spawn -> Client/Entrance): its name comes with it
	setState("Intro", (stage and phase >= 2) and "IT'S NOT DEAD YET..." or (evoTier and "SOMETHING WORSE IS COMING..." or "SOMETHING IS COMING..."))
	for _, p in list do Remotes.Fx:FireClient(p, "Intro", level, shown.title, shown.rarity, evoTier ~= nil) end
	task.wait(3)
	if #Run.matchPlayers() == 0 then busy = false; return end
	-- a random spot in the house, never right next to a player
	local players = {}
	for _, p in Run.matchPlayers() do
		local hrp = hrpOf(p)
		if hrp then table.insert(players, hrp.Position) end
	end
	Ghost.spawn(level, MapLoader.randomGhostSpawn(players, 28), def.id, evoTier, true)
	-- every monster: a medical item is put down somewhere in the house (Server/Supplies)
	if Supplies.spawn(players) then
		for _, p in Run.matchPlayers() do Remotes.Fx:FireClient(p, "Toast", "A MEDICAL ITEM IS LYING SOMEWHERE IN THE HOUSE", true) end
	end
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
	local mult = (g.def and g.def.reward or 1) * diff.reward
	local reward = math.floor((Config.Reward.Base + (g.level - 1) * Config.Reward.PerLevel) * mult)
	for _, p in Run.matchPlayers() do
		local st = stats[p]
		if st then
			st.earned += (Config.Payout.PerKill + Config.Payout.PerLevel * g.level) * mult
			st.kills += 1
			st.damage += g.damageBy[p] or 0
			g.damageBy[p] = 0
			p:SetAttribute("RunKills", st.kills)
		end
		local r = math.floor(reward * cashMult(p))
		p:SetAttribute("RunCash", (p:GetAttribute("RunCash") or 0) + r)
		Data.winGhost(p, g.level)
		Bestiary.record(p, (g.def and g.def.id) or "Woman", g.evolved == true, diff.id == "Nightmare") -- bestiary + badges
		Quests.add(p, "kills")
		Quests.add(p, "kill_" .. ((g.def and g.def.id) or "Woman"))
		Quests.add(p, "wave", g.level)
		if diff.id == "Nightmare" then Quests.add(p, "nightmare") end
		Remotes.Fx:FireClient(p, "Victory", r)
	end
	-- the wave is over: teammates who died during it are back (inside, ready for the break and the next wave)
	Run.respawnSpectators()
	-- a campaign building: the last monster's phase 2, or the building is cleared
	if stage then
		if phase < stage.phases then
			phase += 1
			setState("Victory", "IT'S NOT OVER...")
			task.wait(3.5)
			if #Run.matchPlayers() > 0 and stage then Run.startFight() end
		else
			task.wait(2.5)
			Run.stageCleared()
		end
		return
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
		Events.restock(event) -- same wreck, new items on the shelves
		startBreak()
	end
end

local function spawnEvent(trigger: Vector3, forceKind: string?)
	setState("Event", "")
	setWaypoint(nil)
	for _, i in temp do if i.Name == "ExitBeacon" then i:Destroy() end end
	if event then Events.despawn(event); event = nil end
	local kinds = {}
	for _, k in Events.KINDS do if k ~= lastKind then table.insert(kinds, k) end end
	local kind = kinds[rng:NextInteger(1, #kinds)]
	local forced = RunService:IsStudio() and RS:GetAttribute("DebugEventKind") -- Studio test hook
	if type(forced) == "string" and table.find(Events.KINDS, forced) then kind = forced end
	if forceKind and table.find(Events.KINDS, forceKind) then kind = forceKind end
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
	Quests.add(p, "buys")
	Remotes.Fx:FireClient(p, "BuyResult", true, it.name, at)
end

-- CAMPAIGN: the train brings the party to the building (players stand in the yard, the client rides in)
-- during a train ride the body waits out of sight (anchored under the yard); out = let it off the train
local function holdBody(p: Player, out: Vector3?)
	local ch = p.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not ch or not hrp then return end
	if out then
		ch:PivotTo(CFrame.lookAt(out, out + Vector3.new(0, 0, -1)))
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.Anchored = false
	else
		hrp.Anchored = true
		ch:PivotTo(CFrame.new(YARD + Vector3.new(0, -60, 0)))
	end
end
local function freshStats(p: Player)
	stats[p] = { earned = 0, damage = 0, kills = 0, paid = false, revives = 0, secondChance = false }
	p:SetAttribute("RunCash", 0)
	p:SetAttribute("RunKills", 0)
end
function Run.startStage()
	if busy or not stage or #Run.matchPlayers() == 0 then return end
	busy = true
	arrived = true
	phase = 1
	if Run.respawnSpectators then Run.respawnSpectators() end
	clearTemp()
	setWaypoint(nil)
	Ghost.despawn()
	Ghost.restoreWalls()
	require(script.Parent.Fire).clear()
	Furniture.reset()
	Inventory.clearWorld()
	Supplies.clear()
	-- the building's own items on their spots, its secret doors shut (Server/Supplies, Server/Secrets)
	Supplies.placeMap()
	require(script.Parent.Secrets).arm()
	level = stage.level
	local list = Run.matchPlayers()
	Combat.healAll(list)
	setState("Arrive", "")
	RS:SetAttribute("Stage", stage.id)
	for i, p in list do
		local st = stats[p]
		if not st or st.paid then freshStats(p) end
		holdBody(p)
		Remotes.Fx:FireClient(p, "TrainArrive", stage.id, diff.id)
	end
	task.wait(TRAIN_ARRIVE - 0.6)
	-- the door opens: everyone steps off into the yard, in a row facing the building
	local now = Run.matchPlayers()
	for i, p in now do holdBody(p, YARD + Vector3.new((i - (#now + 1) / 2) * 3.5, 0, 0)) end
	task.wait(0.6)
	busy = false
	if #Run.matchPlayers() == 0 or not stage then return end
	setState("Approach", "GO INTO " .. stage.name)
	setWaypoint(DOOR, stage.name)
	approachUntil = os.clock() + 50
end

-- the building's monster is beaten (both phases): saved, paid, and the result screen
function Run.stageCleared()
	if not stage then return end
	local s0 = stage
	setState("Cleared", s0.name .. " CLEARED")
	setWaypoint(nil)
	local rank = Campaign.diffRank[diff.id] or 2
	local nxt = Campaign.nextStage(s0.id)
	for _, p in Run.matchPlayers() do
		local first = false
		if Campaign.stageOpen(Data.campaign(p), s0.id) then first = Data.clearStage(p, s0.id, rank) end
		local st = stats[p]
		local kills0 = st and st.kills or 0
		local cash, xp, before, after = Run.payout(p, "cleared", first and (60 + 25 * s0.index) or 25)
		local prog = Data.campaign(p)
		-- a cleared map: the player's level is brought up to what its best jar / potion needs
		if Campaign.mapDone(prog, s0.map) then
			local _, lv = Data.mapLevel(p)
			if lv > after then after = lv; task.spawn(Data.save, p) end
		end
		local done, total = Campaign.cleared(prog, s0.map)
		local goal = Campaign.goal(prog)
		Quests.add(p, "stage")
		Remotes.Fx:FireClient(p, "StageClear", {
			stage = s0.id, diff = diff.id, first = first, cash = cash, xp = xp, before = before, after = after, kills = kills0,
			nextId = (nxt and Campaign.stageOpen(prog, nxt.id)) and nxt.id or nil,
			done = done, total = total, mapDone = Campaign.mapDone(prog, s0.map), goal = goal and goal.id or nil,
			best = prog[s0.id] or rank, choice = 60,
		})
	end
	choiceUntil = os.clock() + 60
end

-- the result screen's buttons (Remotes.Stage): "next" / "again" take everyone still here; "lobby" only you
local function onStageChoice(p: Player, choice: any)
	if state ~= "Cleared" or not stage or not p:GetAttribute("InMatch") then return end
	if choice == "lobby" then Run.leave(p, "left"); return end
	if choice ~= "next" and choice ~= "again" then return end
	local target = choice == "again" and stage or Campaign.nextStage(stage.id)
	if not target then return end
	if choice == "next" and not Campaign.stageOpen(Data.campaign(p), target.id) then return end
	-- train tickets (Campaign.TRIPS): the one who picks needs one; everyone who rides uses one, who has none goes back
	-- to the park
	if Data.tripsLeft(p) <= 0 then
		local _, reset = Data.tripsLeft(p)
		Remotes.Fx:FireClient(p, "Toast", "NO TRAIN TICKETS LEFT - " .. Campaign.TRIPS.max .. " MORE IN " .. Campaign.clock(reset - os.time()))
		Remotes.Fx:FireClient(p, "StageRepick")
		return
	end
	setState("Depart", "")
	setWaypoint(nil)
	for _, o in Run.matchPlayers() do
		if not Data.useTrip(o) then
			Remotes.Fx:FireClient(o, "Toast", "NO TRAIN TICKETS LEFT - BACK TO THE PARK")
			task.spawn(Run.leave, o, "left")
		end
	end
	task.wait(0.1)
	if #Run.matchPlayers() == 0 then return end
	for _, o in Run.matchPlayers() do Remotes.Fx:FireClient(o, "TrainDepart", target.id, diff.id, p.DisplayName) end
	task.wait(0.6)
	for _, o in Run.matchPlayers() do holdBody(o) end
	task.wait(TRAIN_DEPART - 0.6)
	if #Run.matchPlayers() == 0 then Run.endMatch(); return end
	Run.configure(target.id, diff.id, RS:GetAttribute("FriendlyFire") ~= false)
	arrived = false
	Run.startStage()
end

local leaving = {} :: { [Player]: boolean }
function Run.leave(p: Player, reason: string)
	if not p:GetAttribute("InMatch") then return end
	leaving[p] = true -- no longer counts as standing for the team (spectators)
	p:SetAttribute("Spectating", nil)
	p:SetAttribute("ReviveUntil", nil)
	Run.payout(p, reason)
	if Run.onReturnLobby then Run.onReturnLobby(p) end
	task.defer(function() if Run.checkWipe then Run.checkWipe() end end)
end
Players.PlayerRemoving:Connect(function(p)
	task.defer(function()
		leaving[p] = nil
		if Run.checkWipe then Run.checkWipe() end
	end)
end)

-- dying in a run.
-- Team still standing: you SPECTATE a teammate (Spectating attribute) and come back for free when the wave's monster
-- is knocked out; a revive window (REVIVE product) lets you come back right away instead.
-- Last one standing: the revive window; if nobody pays, the run ends for you and for the team's spectators.
-- No REVIVE product set up (live game): a short YOU DIED screen instead of the window.
-- Returns how long Main should wait before respawning the character (spectators are respawned here, not by Main).
local REVIVE_WINDOW = 30
local NO_PRODUCT_WINDOW = 6
-- revives are Robux only (the REVIVE Developer Product, ReplicatedStorage attribute ReviveProductId)
local pending = {} :: { [Player]: { untilT: number, at: CFrame, team: boolean, extended: boolean? } }
local function reviveOn(): boolean
	return (tonumber(RS:GetAttribute("ReviveProductId")) or 0) > 0
end
local function aliveIn(p: Player): boolean
	if p:GetAttribute("Spectating") or leaving[p] or not p.Parent then return false end
	local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	return hum ~= nil and hum.Health > 0
end
-- match players still on their feet (not dead, not spectating)
local function aliveCount(except: Player?): number
	local n = 0
	for _, o in Run.matchPlayers() do
		if o ~= except and aliveIn(o) then n += 1 end
	end
	-- Studio test hook: ReplicatedStorage attribute DebugFakeTeammate = true counts one more teammate standing
	if RunService:IsStudio() and RS:GetAttribute("DebugFakeTeammate") then n += 1 end
	return n
end
local function endDeath(p: Player)
	pending[p] = nil
	p:SetAttribute("ReviveUntil", nil)
	p:SetAttribute("Spectating", nil)
	if not p.Parent or not p:GetAttribute("InMatch") then return end
	Run.payout(p, "died")
	task.delay(1.5, function()
		if p.Parent and p:GetAttribute("InMatch") and Run.onReturnLobby then Run.onReturnLobby(p) end
	end)
end
-- nobody left standing (and no last-player revive window still open): the run is over for everyone left
local function checkWipe()
	if state == "Sandbox" then return end -- nobody loses in the sandbox
	if aliveCount() > 0 then return end
	for _, o in Run.matchPlayers() do
		local pd = pending[o]
		if pd and not pd.team and os.clock() < pd.untilT then return end -- the last one can still revive
	end
	for _, o in Run.matchPlayers() do endDeath(o) end
end
Run.checkWipe = checkWipe
-- the wave is over: spectators are back on their feet, inside the house
local function respawnSpectators()
	for _, o in Run.matchPlayers() do
		if o:GetAttribute("Spectating") then
			pending[o] = nil
			o:SetAttribute("ReviveUntil", nil)
			o:SetAttribute("Spectating", nil)
			o:LoadCharacter()
			Remotes.Fx:FireClient(o, "BackFromSpectate")
		end
	end
end
Run.respawnSpectators = respawnSpectators

function Run.onDied(p: Player): number
	if not p:GetAttribute("InMatch") then return 4 end
	if p:GetAttribute("Sandbox") then return 3 end -- the sandbox: simply back on your feet in the house
	local hrp = hrpOf(p)
	local at = hrp and hrp.CFrame or CFrame.new(MapLoader.spawnInside())
	local team = aliveCount(p) > 0
	pending[p] = { untilT = os.clock() + REVIVE_WINDOW, at = at, team = team }
	-- SECOND CHANCE pass: the first death of every run is free (before a bought revive is touched)
	local st = stats[p]
	if p:GetAttribute("SecondChance") and st and not st.secondChance then
		st.secondChance = true
		Remotes.Fx:FireClient(p, "Toast", "SECOND CHANCE - BACK ON YOUR FEET (ONCE PER RUN)", true)
		task.delay(1.5, function() Run.revive(p) end)
		return 99
	end
	-- a revive bought earlier is used right away
	local spare = p:GetAttribute("SpareRevives") or 0
	if spare > 0 then
		p:SetAttribute("SpareRevives", spare - 1)
		task.delay(1.5, function() Run.revive(p) end)
		return 99
	end
	if team then
		-- teammates are still fighting: watch them, back next wave (or revive now). The first one down gets the same
		-- death screen as the last one (an admin revives for free, so they get it without a REVIVE product too).
		p:SetAttribute("Spectating", true)
		if reviveOn() or p:GetAttribute("IsAdmin") then
			p:SetAttribute("ReviveUntil", workspace:GetServerTimeNow() + REVIVE_WINDOW)
			Remotes.Fx:FireClient(p, "ReviveOffer", REVIVE_WINDOW, true)
			task.spawn(function()
				while pending[p] and os.clock() < pending[p].untilT do task.wait(0.25) end
				-- the window closed: keep spectating until the wave ends
				if pending[p] and p:GetAttribute("Spectating") then p:SetAttribute("ReviveUntil", nil) end
			end)
		end
		return 1e6
	end
	-- the last one standing
	local window = reviveOn() and REVIVE_WINDOW or NO_PRODUCT_WINDOW
	pending[p].untilT = os.clock() + window
	p:SetAttribute("ReviveUntil", workspace:GetServerTimeNow() + window)
	Remotes.Fx:FireClient(p, "ReviveOffer", window, false)
	task.spawn(function()
		while pending[p] and os.clock() < pending[p].untilT do task.wait(0.25) end
		if pending[p] then
			endDeath(p)
			checkWipe() -- the spectators' run is over too
		end
	end)
	return window + 3
end
-- the death screen's buttons: "lobby" = leave the run now; "watch" = no revive, keep spectating (team only)
function Run.giveUp(p: Player)
	if not pending[p] then return end
	endDeath(p)
	checkWipe()
end
function Run.watch(p: Player)
	local pd = pending[p]
	if pd and pd.team and p:GetAttribute("Spectating") then
		pd.untilT = 0
		p:SetAttribute("ReviveUntil", nil)
	end
end
-- the player paid (or used the admin panel): back on their feet where they fell, full health, same run
function Run.revive(p: Player): boolean
	local pd = pending[p]
	if not pd or not p.Parent or not p:GetAttribute("InMatch") then return false end
	if not pd.team and os.clock() > pd.untilT + 2 then return false end
	pending[p] = nil
	p:SetAttribute("ReviveUntil", nil)
	p:SetAttribute("Spectating", nil)
	p:LoadCharacter()
	local ch = p.Character
	if ch then ch:PivotTo(pd.at + Vector3.new(0, 3, 0)) end
	Remotes.Fx:FireClient(p, "Revived")
	return true
end
function Run.extendRevive(p: Player, extra: number)
	local pd = pending[p]
	if pd and not pd.extended then
		pd.extended = true
		pd.untilT += extra
		p:SetAttribute("ReviveUntil", (p:GetAttribute("ReviveUntil") or workspace:GetServerTimeNow()) + extra)
	end
end

-- which map and difficulty this match uses (before the first fight); friendlyFire = false: teammates cannot hurt
-- each other in this run (a PLAY-window lobby's choice, read by Combat.friendlyFire)
function Run.configure(mapId: string?, diffId: string?, friendlyFire: boolean?)
	RS:SetAttribute("FriendlyFire", friendlyFire ~= false)
	MapLoader.load(mapId or Maps.default)
	diff = Maps.diffById[diffId or ""] or Maps.diffById[Maps.defaultDiff]
	stage = Campaign.stage(mapId)
	if stage and not MapLoader.exists(stage.id) then warn("[Run] the building " .. stage.id .. " is not built yet: the Mansion stands in for it") end
	RS:SetAttribute("Stage", stage and stage.id or "")
	Ghost.diff = { hp = diff.hp, dmg = diff.dmg, speed = diff.speed, enrage = diff.enrage }
	RS:SetAttribute("Difficulty", diff.id)
end

-- start a match with these players (Studio local match, or the players of a reserved server)
function Run.beginMatch(list: { Player }, mapId: string?, diffId: string?, friendlyFire: boolean?)
	Run.configure(mapId, diffId, friendlyFire)
	kills, level, eventLeft, lastKind, lastMonster = 0, 1, 0, "", ""
	arrived, phase = false, 1
	lastEvolved = ""
	prevMonster = ""
	table.clear(seenMonsters)
	table.clear(seenEvolved)
	if event then Events.despawn(event); event = nil end
	for _, p in list do
		Run.addToMatch(p)
		local ch = p.Character
		if ch then ch:PivotTo(CFrame.new(MapLoader.spawnInside() + Vector3.new(rng:NextInteger(-6, 6), 0, 0))) end
	end
	task.spawn(Run.startFight)
end

-- the sandbox (Server/Sandbox) uses the house without a run: no waves, no cash. While it is on the state is
-- "Sandbox", so a run cannot start on top of it (Run.running) and its players are kept inside the house.
function Run.setSandbox(on: boolean)
	if on then
		if state == "Idle" then setState("Sandbox", "") end
	elseif state == "Sandbox" then
		Run.endMatch()
	end
end

function Run.endMatch()
	Ghost.despawn()
	Ghost.restoreWalls()
	require(script.Parent.Fire).clear()
	clearTemp()
	if event then Events.despawn(event); event = nil end
	Inventory.clearWorld()
	Supplies.clear()
	setWaypoint(nil)
	arrived, phase = false, 1
	setState("Idle", "")
end

-- admin panel: spawn an event outside right now
function Run.adminEvent(kind: string)
	task.spawn(spawnEvent, DOOR + Vector3.new(0, 0, 10), kind)
end

function Run.start()
	Ghost.onDeath = function(g) task.spawn(onGhostDeath, g) end
	Events.onBuy = onBuy
	Events.onLeave = function(p) Run.leave(p, "left") end
	Remotes.Stage.OnServerEvent:Connect(function(p, choice) task.spawn(onStageChoice, p, choice) end)
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
	local lastWarn = {} :: { [Player]: number }
	local nextRoofCheck = 0
	local inRoof = {} :: { [Player]: number } -- since when a player has been above the top ceiling
	Players.PlayerRemoving:Connect(function(p) inRoof[p] = nil; lastWarn[p] = nil end)
	RunService.Heartbeat:Connect(function(dt)
		Ghost.step(dt)
		local now = os.clock()
		-- STUCK IN THE ROOF: a grab or a throw put a player through the top ceiling (above the outside walls, same
		-- limit as the monsters' Ghost.outside). After half a second up there they are put back in the room below.
		if now >= nextRoofCheck and state ~= "Idle" then
			nextRoofCheck = now + 0.25
			local B = Ghost.houseBounds()
			for _, p in Run.matchPlayers() do
				local hrp = hrpOf(p)
				local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				local pos = hrp and hrp.Position
				if pos and hum and hum.Health > 0 and pos.Y > B.max.Y and pos.Y < B.max.Y + 60 and pos.X > B.min.X - 4 and pos.X < B.max.X + 4 and pos.Z > B.min.Z - 4 and pos.Z < B.max.Z + 4 then
					inRoof[p] = inRoof[p] or now
					if now - inRoof[p] >= 0.5 then
						inRoof[p] = nil
						local rp = RaycastParams.new()
						rp.FilterType = Enum.RaycastFilterType.Include
						local live = workspace:FindFirstChild("Mansion")
						rp.FilterDescendantsInstances = { live and live:FindFirstChild("Structure") or workspace.Terrain }
						-- the floor of the room right under them (or a few steps to the side: they can be over a wall)
						local op = OverlapParams.new()
						op.FilterType = Enum.RaycastFilterType.Include
						op.FilterDescendantsInstances = rp.FilterDescendantsInstances
						local at: Vector3? = nil
						for _, off in { Vector3.zero, Vector3.new(4, 0, 0), Vector3.new(-4, 0, 0), Vector3.new(0, 0, 4), Vector3.new(0, 0, -4),
							Vector3.new(6, 0, 6), Vector3.new(-6, 0, 6), Vector3.new(6, 0, -6), Vector3.new(-6, 0, -6) } do
							local floor = workspace:Raycast(Vector3.new(pos.X + off.X, B.max.Y - 4, pos.Z + off.Z), Vector3.new(0, -60, 0), rp)
							if floor and floor.Normal.Y > 0.7 then
								local spot = floor.Position + Vector3.new(0, 3.2, 0)
								if #workspace:GetPartBoundsInBox(CFrame.new(spot + Vector3.new(0, 0.4, 0)), Vector3.new(2.4, 5, 2.4), op) == 0 then
									at = spot
									break
								end
							end
						end
						hrp.AssemblyLinearVelocity = Vector3.zero
						;(p.Character :: Model):PivotTo(CFrame.new(at or (MapLoader.spawnInside() + Vector3.new(0, 3, 0))))
					end
				else
					inRoof[p] = nil
				end
			end
		end
		if state == "Intro" or state == "Sandbox" or (state == "Fight" and Ghost.alive()) then
			-- no running out to the shop while a monster is in the house: back inside (the sandbox is the house only)
			for _, p in Run.matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and (hrp.Position.Z > Config.OutsideZ - 2 or not insideHouse(hrp.Position)) then
					hrp.AssemblyLinearVelocity = Vector3.zero
					;(p.Character :: Model):PivotTo(CFrame.new(MapLoader.spawnInside() + Vector3.new(0, 3, 0)))
					if now - (lastWarn[p] or 0) > 2 then
						lastWarn[p] = now
						Remotes.Fx:FireClient(p, "Toast", state == "Sandbox" and "THE SANDBOX IS THE HOUSE - PRESS LEAVE TO GO BACK TO THE PARK" or "THE DOOR WON'T OPEN WHILE THE MONSTER IS HERE")
					end
				end
			end
		elseif state == "Outside" then
			for _, p in Run.matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and (hrp.Position.Z > Config.OutsideZ or not insideHouse(hrp.Position)) then
					task.spawn(spawnEvent, hrp.Position)
					break
				end
			end
			if state == "Outside" and now > breakUntil then task.spawn(spawnEvent, DOOR + Vector3.new(0, 0, 10)) end
		elseif state == "Approach" then
			-- off the train: the fight starts once someone walks in (or after a while)
			local inside = now > approachUntil
			for _, p in Run.matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and insideHouse(hrp.Position) and hrp.Position.Z < Config.OutsideZ - 6 then inside = true end
			end
			if inside and not busy then task.spawn(Run.startFight) end
		elseif state == "Cleared" and now > choiceUntil then
			-- nobody picked: back to the park
			choiceUntil = math.huge
			for _, p in Run.matchPlayers() do task.spawn(Run.leave, p, "left") end
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
