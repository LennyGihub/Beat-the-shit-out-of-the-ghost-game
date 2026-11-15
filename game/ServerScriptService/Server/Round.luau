-- Round flow: Intro -> Fight -> Victory (cash) -> Outside -> plane crash -> Shop -> next ghost.
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

local Round = {}
local state = "Waiting"
local level = 1
local wreck: Model? = nil
local merchant: Model? = nil
local busy = false
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

local function playerHrps(): { [Player]: BasePart }
	local out = {}
	for _, p in Players:GetPlayers() do
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then out[p] = hrp end
	end
	return out
end

local function insideHouse(pos: Vector3): boolean
	local mn, mx = Config.House.Min, Config.House.Max
	return pos.X > mn.X and pos.X < mx.X and pos.Z > mn.Z and pos.Z < mx.Z
end

local function clearShop()
	if wreck then wreck:Destroy(); wreck = nil end
	if merchant then merchant:Destroy(); merchant = nil end
end

function Round.startFight()
	if busy then return end
	busy = true
	level = 1
	for _, p in Players:GetPlayers() do
		local d = Data.get(p)
		if d then level = math.max(level, d.GhostLevel) end
	end
	clearShop()
	Ghost.despawn()
	Furniture.reset()
	Combat.healAll()
	for p, hrp in playerHrps() do
		if not insideHouse(hrp.Position) then
			(p.Character :: Model):PivotTo(CFrame.new(Config.SpawnInside + Vector3.new(math.random(-6, 6), 0, 0)) * CFrame.Angles(0, 0, 0))
		end
	end
	setState("Intro", "Something is in the house...")
	Remotes.Fx:FireAllClients("Intro", level)
	task.wait(6)
	local best, bestD = SPAWNS[1], -1
	for _, sp in SPAWNS do
		local d = math.huge
		for _, hrp in playerHrps() do d = math.min(d, (hrp.Position - sp).Magnitude) end
		if d > bestD and d < math.huge then best, bestD = sp, d end
	end
	Ghost.spawn(level, best)
	setState("Fight", "")
	busy = false
end

local function onGhostDeath(g)
	setState("Victory", "")
	local reward = Config.Reward.Base + (g.level - 1) * Config.Reward.PerLevel
	for _, p in Players:GetPlayers() do
		Data.addCash(p, reward)
		Data.winGhost(p, g.level)
		task.spawn(Data.save, p)
		Remotes.Fx:FireClient(p, "Victory", reward)
	end
	task.wait(5)
	setState("Outside", "Head outside")
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
	-- fire and smoke
	for _, name in { "EngineL", "EngineR", "Body" } do
		local part = w:FindFirstChild(name, true) :: BasePart?
		if part then
			local f = Instance.new("Fire"); f.Size = name == "Body" and 9 or 6; f.Heat = 12; f.Parent = part
			local sm = Instance.new("Smoke"); sm.Color = Color3.fromRGB(40, 38, 36); sm.Opacity = 0.35; sm.RiseVelocity = 8; sm.Size = 6; sm.Parent = part
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 130, 60); l.Range = 34; l.Brightness = 0.9; l.Parent = part
		end
	end
	w.Parent = workspace
	wreck = w
end

local function spawnMerchant(land: Vector3, facePos: Vector3)
	local tpl = SS:FindFirstChild("MerchantTemplate") :: Model?
	if not tpl then return end
	local m = tpl:Clone()
	m.Name = "Merchant"
	local spot = land + (facePos - land).Unit * 12
	spot = Vector3.new(spot.X, 0, spot.Z)
	m:PivotTo(CFrame.lookAt(spot, Vector3.new(facePos.X, 0, facePos.Z)))
	m.Parent = workspace
	local torso = m:FindFirstChild("Torso", true) :: BasePart?
	if torso then
		local pp = Instance.new("ProximityPrompt")
		pp.ActionText = "Shop"; pp.ObjectText = "Crashed Pilot"; pp.HoldDuration = 0
		pp.MaxActivationDistance = 14; pp.RequiresLineOfSight = false; pp.KeyboardKeyCode = Enum.KeyCode.F
		pp.Parent = torso
		pp.Triggered:Connect(function(p) Remotes.Fx:FireClient(p, "OpenShop") end)
	end
	merchant = m
end

local function crash(trigger: BasePart)
	setState("Crash", "")
	local pos = trigger.Position
	local land = Vector3.new(math.clamp(pos.X + 28, -70, 70), 0, math.clamp(pos.Z + 42, 105, 150))
	Remotes.Fx:FireAllClients("PlaneCrash", land, pos)
	task.wait(4.2)
	buildWreck(land, pos)
	Remotes.Fx:FireAllClients("PlaneImpact", land)
	task.wait(2.5)
	spawnMerchant(land, pos)
	setState("Shop", "Talk to the crashed pilot")
	for _, p in Players:GetPlayers() do Remotes.Fx:FireClient(p, "ShopReady") end
end

local function onBuy(player: Player, id: any)
	if type(id) ~= "string" or not merchant then return end
	local it = Items.byId[id]
	if not it then return end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp or (hrp.Position - merchant:GetPivot().Position).Magnitude > 40 then return end
	if Data.owns(player, id) then
		Remotes.Fx:FireClient(player, "BuyResult", false, "Already owned")
		return
	end
	if not Data.spend(player, it.price) then
		Remotes.Fx:FireClient(player, "BuyResult", false, "Not enough cash")
		return
	end
	Data.own(player, id)
	Combat.refreshHealth(player)
	task.spawn(Data.save, player)
	Remotes.Fx:FireClient(player, "BuyResult", true, it.name)
end

function Round.start()
	Ghost.onDeath = function(g) task.spawn(onGhostDeath, g) end
	Remotes.Buy.OnServerEvent:Connect(onBuy)
	Remotes.NextGhost.OnServerEvent:Connect(function()
		if state == "Shop" then task.spawn(Round.startFight) end
	end)
	RunService.Heartbeat:Connect(function(dt)
		Ghost.step(dt)
		if state == "Outside" then
			for _, hrp in playerHrps() do
				if hrp.Position.Z > Config.OutsideZ or not insideHouse(hrp.Position) then
					task.spawn(crash, hrp)
					break
				end
			end
		end
	end)
	setState("Waiting", "")
end

function Round.onPlayerReady()
	if state == "Waiting" then
		task.delay(3, function()
			if state == "Waiting" then Round.startFight() end
		end)
	end
end

return Round
