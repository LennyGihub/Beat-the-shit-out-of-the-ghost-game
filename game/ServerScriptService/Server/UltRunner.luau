-- Runs an ultimate's activation actions (see Shared/Ultimates for the action list).
local RS = game:GetService("ReplicatedStorage")
local Remotes = require(script.Parent.Remotes)
local Ragdoll = require(script.Parent.Ragdoll)
local Furniture = require(script.Parent.Furniture)
local Ghost = require(script.Parent.Ghost)
local Combat = require(script.Parent.Combat)
local Fire = require(script.Parent.Fire)
local Config = require(RS.Shared.Config)
local Ultimates = require(RS.Shared.Ultimates)

local Runner = {}
local rng = Random.new()

local function ghostPos(): Vector3?
	local g = Ghost.current
	if g and Ghost.alive() then return g.hrp.Position end
	return nil
end

-- smash furniture outward and blast the ghost if she is inside the radius
local function shock(player: Player, center: Vector3, r: number, d: number, k: number, color: Color3, id: string?)
	Remotes.Fx:FireAllClients("UltShock", center, r, color, id) -- id picks the look (Client/UltActs SHOCK)
	for _, f in Furniture.near(center, r) do
		local c = f:GetBoundingBox().Position
		local out = Vector3.new(c.X - center.X, 0, c.Z - center.Z)
		Furniture.smash(f, (out.Magnitude > 0.1 and out.Unit or Vector3.zero) * (40 + k * 0.3) + Vector3.new(0, 30, 0), 80)
	end
	local gp = ghostPos()
	if gp and (gp - center).Magnitude < r then
		Ghost.hit(player, gp - center, k, d * Combat.stat(player, "damage"), nil, true)
	end
end

-- an explosive barrel went off (Furniture.onExplode): Config.Barrel
function Runner.barrel(pos: Vector3, by: Player?)
	local B = Config.Barrel
	Remotes.Fx:FireAllClients("ItemBoom", pos, B.Radius, Color3.fromRGB(255, 140, 40), true, "Barrel")
	if Ragdoll.breakWalls(pos, Vector3.zero, 9, 6) > 0 then Remotes.Fx:FireAllClients("WallSmash", pos, 120) end
	for _, f in Furniture.near(pos, B.Radius * 0.7) do -- everything near it flies (other barrels go off in turn)
		local c = f:GetBoundingBox().Position
		local out = c - pos
		Furniture.smash(f, (out.Magnitude > 0.1 and out.Unit or Vector3.yAxis) * 70 + Vector3.new(0, 30, 0), 90)
	end
	local gp = ghostPos()
	if gp and (gp - pos).Magnitude < B.Radius then
		local f = 1 - (gp - pos).Magnitude / B.Radius * 0.5
		Ghost.hit(by, gp - pos, B.Knock, B.Damage * f * (by and Combat.stat(by, "damage") or 1), true, true)
		Ghost.burn(6, 4, nil, by)
	end
	Fire.ignite(pos, B.FireRadius, by, 3, true)
	for _, p in game:GetService("Players"):GetPlayers() do
		local hrp = p:GetAttribute("InMatch") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and (hrp.Position - pos).Magnitude < B.PlayerRadius and (p == by or by == nil or Combat.friendlyFire()) then
			local out = hrp.Position - pos
			Combat.hitPlayer(p, nil, B.PlayerDamage, (out.Magnitude > 0.1 and out.Unit or Vector3.yAxis) * 55 + Vector3.new(0, 28, 0), "barrel", true, 1)
		end
	end
end

-- explosive punches (buff.explode)
function Runner.explode(player: Player, pos: Vector3, radius: number, color: Color3)
	Remotes.Fx:FireAllClients("UltShock", pos, radius, color, "explode")
	-- explosions blow holes in the inside walls too
	local w = math.clamp(radius * 0.5, 3, 9)
	if Ragdoll.breakWalls(pos, Vector3.zero, w, w * 0.6) > 0 then Remotes.Fx:FireAllClients("WallSmash", pos, 100) end
	for _, f in Furniture.near(pos, radius) do
		local c = f:GetBoundingBox().Position
		Furniture.smash(f, (c - pos).Unit * 60 + Vector3.new(0, 25, 0), 70)
	end
	local gp = ghostPos()
	if gp and (gp - pos).Magnitude < radius then Ghost.damage(6 * Combat.stat(player, "damage"), player) end
end

local function strike(player: Player, a, color: Color3, id: string)
	local delayFor = { lightning = 0.08, meteor = 0.7, holy = 0.35, nuke = 1.6 }
	for i = 1, a.n do
		local gp = ghostPos()
		if not gp then return end
		local spread = a.style == "lightning" and 3 or (a.style == "nuke" and 0 or 4)
		local pos = gp + Vector3.new(rng:NextNumber(-spread, spread), 0, rng:NextNumber(-spread, spread))
		Remotes.Fx:FireAllClients("UltStrike", a.style, pos, color, id)
		local d = a.d * Combat.stat(player, "damage")
		task.delay(delayFor[a.style] or 0.2, function()
			local now = ghostPos()
			if not now then return end
			local radius = a.style == "nuke" and 60 or (a.style == "meteor" and 9 or 7)
			if (now - pos).Magnitude < radius + 3 then
				if a.style == "lightning" then
					Ghost.damage(d, player)
				else
					Ghost.hit(player, now - pos + Vector3.new(0, 0, 0.01), a.style == "nuke" and 220 or 50, d, nil, true)
				end
			end
			for _, f in Furniture.near(pos, radius) do
				Furniture.smash(f, ((f:GetBoundingBox().Position - pos).Unit + Vector3.new(0, 0.6, 0)) * 70, 90)
			end
		end)
		if a.gap > 0 then task.wait(a.gap) end
	end
end

-- a piece of furniture an ultimate throws: the clients draw a streak behind it
local function fling(f: Model, target: Vector3, player: Player, power: number, color: Color3)
	Remotes.Fx:FireAllClients("UltFling", f, color)
	Furniture.flingAt(f, target, player, power)
end

local function vortex(player: Player, a, color: Color3)
	local t0 = os.clock()
	Ghost.setVortex(a.t)
	while os.clock() - t0 < a.t do
		local gp = ghostPos()
		if not gp then return end
		for _, f in Furniture.nearest(gp, a.r, 2) do
			fling(f, gp, player, 115, color)
		end
		Ghost.damage(1.5 * Combat.stat(player, "damage"), player)
		task.wait(0.3)
	end
end

local function barrage(player: Player, a, color: Color3)
	local gp = ghostPos()
	if not gp then return end
	for _, f in Furniture.nearest(gp, 110, a.n) do
		local now = ghostPos()
		if not now then return end
		fling(f, now + Vector3.new(0, 1, 0), player, 130, color)
		task.wait(0.08)
	end
end

function Runner.run(player: Player, def, center: Vector3)
	local color = def.color
	-- the wind-up: the cast animation lands its hit castTime after the button (the buff is already running)
	task.wait(Ultimates.castTime)
	local function here(): Vector3
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		return hrp and hrp.Position or center
	end
	if not player.Parent then return end
	center = here()
	for _, a in def.acts do
		task.spawn(function()
			local t = a.type
			if a.wait then task.wait(a.wait) end
			if t == "shock" then
				shock(player, a.atGhost and ghostPos() or center, a.r, a.d, a.k, color, def.id)
			elseif t == "pulses" then
				for _ = 1, a.n do
					shock(player, here(), a.r, a.d, a.k, color, def.id)
					task.wait(a.gap)
				end
			elseif t == "strike" then
				strike(player, a, color, def.id)
			elseif t == "freeze" then
				Ghost.freeze(a.t)
				local gp = ghostPos()
				if gp then Remotes.Fx:FireAllClients("UltFreeze", gp, a.t) end
			elseif t == "timestop" then
				Ghost.timeStop(a.t, a.mult)
				Remotes.Fx:FireAllClients("TimeStop", a.t)
			elseif t == "launch" then
				Ghost.launch(a.h, a.d * Combat.stat(player, "damage"), player)
			elseif t == "vortex" then
				vortex(player, a, color)
			elseif t == "barrage" then
				barrage(player, a, color)
			elseif t == "burn" then
				Ghost.burn(a.dps * Combat.stat(player, "damage"), a.t, a.color or color, player)
			elseif t == "slow" then
				Ghost.slow(a.mult, a.t)
			elseif t == "heal" then
				Combat.heal(player, a.hp)
			elseif t == "stamina" then
				Combat.refillStamina(player)
			elseif t == "giant" then
				Combat.giant(player, a.scale, a.t)
			end
		end)
	end
end

function Runner.start()
	Combat.runUltimate = Runner.run
	Combat.explode = Runner.explode
	Furniture.onExplode = Runner.barrel
end

return Runner
