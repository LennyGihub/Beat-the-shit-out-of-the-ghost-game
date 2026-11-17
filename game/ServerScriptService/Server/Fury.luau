--!strict
-- FURY: makes every monster fight back, on top of its own special ability (tuning in Config.Fury).
-- 1 PRESSURE: every hit with knockback adds pressure (a knock-out adds more); it drains over time. Full = the monster
--   ROARS: a short wind-up (red glow + growl; small hits don't stop it, a knock-out hit like a charged punch does),
--   then a shockwave that throws everyone near it away (small, blockable damage). Waking up from a knock-out with
--   pressure left also roars, so it can't be juggled forever.
-- 2 LUNGE: from mid range it crouches (telegraphed) and dashes; the first player in its way is hit and thrown.
-- 3 COMBOS: its swipes come in chains of 2. Enraged, every swipe is a SMASH PUNCH that launches you through the inside walls.
-- 4 ENRAGE below half HP: faster, shorter cooldowns, abilities more often; starts with a roar and a banner.
-- Fairness: a player who was just thrown/knocked down can't be clawed or lunged for a moment (grace), and a monster
-- can never take more than BurstCap of your max health within BurstWindow seconds (Fury.cap, used by Combat).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Remotes = require(script.Parent.Remotes)
local Ragdoll = require(script.Parent.Ragdoll)

local F = Config.Fury
local C = Config.Ghost
local Fury = {}
local rng = Random.new()

-- fairness ---------------------------------------------------------------
local graceUntil = {} :: { [Player]: number }
local recent = {} :: { [Player]: { { t: number, n: number } } }

-- the player was thrown / knocked down by the monster: no melee on them until they are back up
function Fury.downed(p: Player, t: number?)
	graceUntil[p] = math.max(graceUntil[p] or 0, os.clock() + (t or 1) + F.Grace)
end
function Fury.inGrace(p: Player?): boolean
	return p ~= nil and os.clock() < (graceUntil[p] or 0)
end
-- damage a monster is still allowed to deal to p right now (and record it)
function Fury.cap(p: Player, amount: number, maxHealth: number): number
	if amount <= 0 then return amount end
	local now = os.clock()
	p:SetAttribute("LastMonsterHit", now) -- pauses health regen (StarterCharacterScripts.Health)
	local list = recent[p] or {}
	recent[p] = list
	local sum = 0
	for i = #list, 1, -1 do
		if now - list[i].t > F.BurstWindow then table.remove(list, i) else sum += list[i].n end
	end
	local allowed = math.max(0, F.BurstCap * maxHealth - sum)
	local n = math.min(amount, allowed)
	if n > 0 then table.insert(list, { t = now, n = n }) end
	return n
end
Players.PlayerRemoving:Connect(function(p) graceUntil[p] = nil; recent[p] = nil end)

-- helpers ------------------------------------------------------------------
local function hrpOf(p: Player): BasePart?
	local ch = p.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	return ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
end
local function targets(): { Player }
	local out = {}
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("InMatch") and not p:GetAttribute("Spectating") and not p:GetAttribute("Warded") then table.insert(out, p) end
	end
	return out
end
local function flat(v: Vector3): Vector3
	local f = Vector3.new(v.X, 0, v.Z)
	return f.Magnitude > 0.01 and f.Unit or Vector3.new(0, 0, -1)
end
local function swipeDamage(g): number
	return (C.SwipeDamage + (g.level - 1) * C.SwipeDamagePerLevel) * g.dmgMult
end
Fury.swipeDamage = swipeDamage

-- set up a freshly spawned monster
function Fury.init(g)
	g.pressure = 0
	g.lastPress = 0
	g.comboLeft = 0
	g.nextLunge = os.clock() + rng:NextNumber(F.LungeCd[1], F.LungeCd[2])
	g.enraged = false
	g.furySpeed = 1
	g.cdBase = g.cdBase or 1 -- evolved monsters and bigger teams: shorter cooldowns from the start (Ghost.spawn)
	g.cdMult = g.cdBase
	g.roarQueued = false
	g.fury = nil
end

-- a hit landed on the monster (Ghost.hit): knock = the knockback it carries
function Fury.onHit(g, knock: number, knockout: boolean)
	if knock <= 0 or g.state == "Roar" or g.state == "WindUp" or g.state == "Swipe" then return end -- already hitting back
	local now = os.clock()
	-- drain since the last hit
	g.pressure = math.max(0, g.pressure - (now - g.lastPress) * F.PressureDecay)
	if knockout then
		g.pressure += F.KnockoutPressure
	elseif now - g.lastPress >= F.HitSpacing then
		g.pressure += 1
	else
		return -- rapid-fire weapons don't count every tick
	end
	g.lastPress = now
	g.model:SetAttribute("Pressure", math.floor(g.pressure * 10) / 10)
end
local function pressure(g, now: number): number
	return math.max(0, g.pressure - (now - g.lastPress) * F.PressureDecay)
end
Fury.pressure = function(g) return pressure(g, os.clock()) end

-- small hits don't stagger it: while roaring, and while swiping back after a beating (pressure >= ArmorPressure)
function Fury.armored(g): boolean
	if g.state == "Roar" then return true end
	return (g.state == "WindUp" or g.state == "Swipe") and pressure(g, os.clock()) >= F.ArmorPressure
end

-- staggered or getting up but beaten up enough: it swipes back right away instead of taking the whole combo
function Fury.counterCheck(g, G, now: number, target: Player?, thrp: BasePart?): boolean
	if not target or not thrp or now < g.nextAttack or Fury.inGrace(target) then return false end
	if pressure(g, now) < F.ArmorPressure then return false end
	if (thrp.Position - g.hrp.Position).Magnitude > C.AttackRange * ((g.def :: any).reach or 1) * 1.25 then return false end
	g.comboLeft = Fury.comboCount(g)
	G.setState(g, "WindUp", Fury.windUp(g, false))
	Remotes.Fx:FireAllClients("CounterWind", g.hrp.Position)
	return true
end

-- the knock-out is over: roar on the way up if it was beaten up a lot
function Fury.wake(g)
	if pressure(g, os.clock()) >= F.WakeRoar then g.roarQueued = true end
end

-- below EnrageAt of its HP (Ghost.damage). Enraged, it can't be knocked out (ragdolled) for F.RageGuard seconds,
-- and for F.RageStepGuard seconds more each time its health crosses another 10% mark.
function Fury.checkEnrage(g)
	if g.hp <= 0 then return end
	local step = math.ceil(g.hp / g.maxHp * 10) -- 5 = 41..50%, 4 = 31..40%...
	if g.enraged then
		if step < (g.rageStep or step) then
			g.rageStep = step
			g.noRagUntil = math.max(g.noRagUntil or 0, os.clock() + F.RageStepGuard)
			g.model:SetAttribute("NoRagdoll", true)
		end
		return
	end
	if g.hp > g.maxHp * F.EnrageAt then return end
	g.rageStep = step
	g.noRagUntil = os.clock() + F.RageGuard
	g.model:SetAttribute("NoRagdoll", true)
	g.enraged = true
	g.furySpeed = F.EnrageSpeed
	g.cdMult = g.cdBase * F.EnrageCooldown
	g.roarQueued = true
	g.model:SetAttribute("Enraged", true)
	Remotes.Fx:FireAllClients("Enraged", g.model, g.def.title)
end

-- ROAR ---------------------------------------------------------------------
local function startRoar(g, G)
	g.pressure = 0
	g.roarQueued = false
	g.model:SetAttribute("Pressure", 0)
	g.fury = { kind = "roar" }
	g.model:SetAttribute("FuryPhase", "wind")
	G.setState(g, "Roar", F.RoarWind)
	Remotes.Fx:FireAllClients("RoarWind", g.hrp.Position, F.RoarWind)
end

function Fury.stepRoar(g, G, now: number, thrp: BasePart?, hoverY: number)
	local pos = g.hrp.Position
	g.lv.VectorVelocity = Vector3.new(0, (hoverY - pos.Y) * 4, 0)
	if thrp then
		local f = Vector3.new(thrp.Position.X, pos.Y, thrp.Position.Z)
		if (f - pos).Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(pos, f).Rotation end
	end
	if now < g.stateUntil then return end
	-- the blast
	g.model:SetAttribute("FuryPhase", "blast")
	Remotes.Fx:FireAllClients("Roar", pos, F.RoarRadius)
	local dmg = swipeDamage(g) * F.RoarDamage
	for _, p in targets() do
		local hrp = hrpOf(p)
		if hrp and not Fury.inGrace(p) then
			local to = hrp.Position - pos
			local d = to.Magnitude
			if d < F.RoarRadius and math.abs(to.Y) < 9 then
				local f = 1 - d / F.RoarRadius
				Fury.downed(p, F.RoarRag)
				G.hitPlayer(p, nil, dmg * (0.6 + 0.4 * f), flat(to) * F.RoarPush * (0.7 + 0.5 * f) + Vector3.new(0, 30, 0), "roar", true, F.RoarRag)
			end
		end
	end
	g.fury = nil
	g.model:SetAttribute("FuryPhase", "")
	g.nextAttack = math.max(g.nextAttack, now + 0.5)
	G.setState(g, "Recover", 0.35)
end

-- LUNGE --------------------------------------------------------------------
local function startLunge(g, G, thrp: BasePart)
	g.fury = { kind = "lunge", phase = "wind", dir = flat(thrp.Position - g.hrp.Position), hit = false }
	g.nextLunge = os.clock() + rng:NextNumber(F.LungeCd[1], F.LungeCd[2]) * g.cdMult -- also if a punch cuts it short
	g.model:SetAttribute("FuryPhase", "wind")
	G.setState(g, "Lunge", F.LungeWind * (g.enraged and 0.8 or 1))
	Remotes.Fx:FireAllClients("LungeWind", g.hrp.Position)
end

function Fury.stepLunge(g, G, dt: number, now: number, thrp: BasePart?, hoverY: number)
	local L = g.fury
	if not L or L.kind ~= "lunge" then G.setState(g, "Chase"); return end
	local pos = g.hrp.Position
	if L.phase == "wind" then
		-- keeps aiming during most of the crouch, then locks the direction (the dodge window)
		if thrp and now < g.stateUntil - 0.15 then L.dir = flat(thrp.Position - pos) end
		g.ao.CFrame = CFrame.lookAt(pos, pos + L.dir).Rotation
		g.lv.VectorVelocity = -L.dir * 3 + Vector3.new(0, (hoverY - pos.Y) * 4, 0)
		if now >= g.stateUntil then
			L.phase = "dash"
			g.model:SetAttribute("FuryPhase", "dash")
			g.stateUntil = now + F.LungeTime
			Remotes.Fx:FireAllClients("Lunge", pos, L.dir)
		end
		return
	end
	-- dash
	local v = L.dir * F.LungeSpeed * g.furySpeed
	if g.def.solid and G.blockWalls then
		local v2 = G.blockWalls(g, v)
		if v2.Magnitude < v.Magnitude * 0.3 then g.stateUntil = now end -- ran into a wall
		v = v2
	end
	g.lv.VectorVelocity = v + Vector3.new(0, (hoverY - pos.Y) * 4, 0)
	if not L.hit then
		for _, p in targets() do
			local hrp = hrpOf(p)
			if hrp and not Fury.inGrace(p) then
				local to = hrp.Position - pos
				if Vector3.new(to.X, 0, to.Z).Magnitude < F.LungeHitR * ((g.def :: any).reach or 1) and math.abs(to.Y) < 7 then
					L.hit = true
					Fury.downed(p, 1)
					G.hitPlayer(p, nil, swipeDamage(g) * F.LungeDamage, L.dir * 70 + Vector3.new(0, 28, 0), "lunge", true, 1)
					g.stateUntil = now -- stops on the hit
					break
				end
			end
		end
	end
	if now >= g.stateUntil then
		g.fury = nil
		g.model:SetAttribute("FuryPhase", "")
		g.nextAttack = math.max(g.nextAttack, now + 0.4)
		G.setState(g, "Recover", L.hit and 0.45 or 0.6)
	end
end

-- called every frame in Chase (before the normal attacks): roar when due. Returns true when it took over.
function Fury.roarCheck(g, G, now: number, target: Player?): boolean
	if not target then return false end
	local pmax = g.enraged and F.EnragedPressureMax or F.PressureMax
	if g.roarQueued or pressure(g, now) >= pmax then
		startRoar(g, G)
		return true
	end
	return false
end

-- called in Chase when nothing else fired: lunge from mid range
function Fury.lungeCheck(g, G, now: number, target: Player?, thrp: BasePart?, dist: number): boolean
	if not target or not thrp or now < g.nextLunge or now < (g.slowUntil or 0) then return false end
	if dist < F.LungeMin or dist > F.LungeMax or Fury.inGrace(target) then return false end
	if math.abs(thrp.Position.Y - g.hrp.Position.Y) > 8 then return false end -- not across floors
	startLunge(g, G, thrp)
	return true
end

-- SMASH PUNCH (enraged, last swipe of a chain): launches the player; the inside walls in their path break
local flying = {} :: { [Player]: number }
local function smashAhead(g, from: Vector3, vel: Vector3, dist: number): boolean
	local h = Vector3.new(vel.X, 0, vel.Z)
	if h.Magnitude < 30 then return false end
	local r = workspace:Raycast(from, h.Unit * dist, g.rp)
	if r and r.Normal.Y < 0.6 and Ragdoll.breakWalls(r.Position, h, 7, 4) > 0 then
		Remotes.Fx:FireAllClients("WallSmash", r.Position, h.Magnitude)
		return true
	end
	return false
end
-- send a player flying at vel: the inside walls on the way break (the smash punch, the Golden Bear's snap)
function Fury.launch(g, G, p: Player, vel: Vector3, dmg: number, ragT: number, label: string)
	local hrp = hrpOf(p)
	if not hrp then return end
	smashAhead(g, hrp.Position, vel, F.SmashReach) -- the first wall breaks right away (the flight runs on their client)
	flying[p] = os.clock() + ragT + 0.4
	Fury.downed(p, ragT)
	G.hitPlayer(p, nil, dmg, vel, label, true, ragT)
end
function Fury.smashPunch(g, G, p: Player, thrp: BasePart)
	local dir = flat(thrp.Position - g.hrp.Position)
	-- evolved monsters punch harder (def.smash), and harder still once enraged
	local k = ((g.def :: any).smash or 1) * ((g.evolved and g.enraged) and 1.15 or 1)
	local vel = dir * math.min(F.SmashSpeed * k, 190) + Vector3.new(0, F.SmashUp, 0)
	Remotes.Fx:FireAllClients("FurySmash", thrp.Position, dir)
	Fury.launch(g, G, p, vel, swipeDamage(g) * F.SmashDamage, F.SmashTime, "smash")
end
-- does its swipe launch you through the walls? (enraged, an evolved monster, or a born smasher: the Conqueror)
-- enraged and in one of its no-knockout windows (checkEnrage)
function Fury.unragdollable(g): boolean
	local on = g.noRagUntil ~= nil and os.clock() < g.noRagUntil
	if not on and g.model:GetAttribute("NoRagdoll") then g.model:SetAttribute("NoRagdoll", false) end
	return on
end

function Fury.smashes(g): boolean return g.enraged == true or g.evolved == true or (g.def :: any).smasher == true end
-- every frame: walls further along a launched player's path break too
function Fury.tick(g)
	local now = os.clock()
	if g.noRagUntil then Fury.unragdollable(g) end -- (clears the NoRagdoll attribute once the window is over)
	for p, untilT in flying do
		local hrp = hrpOf(p)
		if now > untilT or not hrp then
			flying[p] = nil
		else
			smashAhead(g, hrp.Position, hrp.AssemblyLinearVelocity, 9)
		end
	end
end

-- the swipe chain: how many follow-up swipes a fresh attack gets
function Fury.comboCount(g): number
	return (Fury.smashes(g) and F.EnragedCombo or F.Combo) - 1
end

-- wind-up length of the next swipe (follow-ups are quicker)
function Fury.windUp(g, followUp: boolean): number
	local w = followUp and F.ComboWindUp or C.WindUp
	return w * (g.enraged and 0.85 or 1)
end

return Fury
