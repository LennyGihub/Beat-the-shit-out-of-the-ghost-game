-- Player combat: escalating punch combos, stamina, brutality + equipped ultimate, lifting and throwing furniture.
-- Everything is validated here; the client only sends intents (punch, grab, throw, ult, sprint).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.Shared.Config)
local Items = require(RS.Shared.Items)
local Ultimates = require(RS.Shared.Ultimates)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Furniture = require(script.Parent.Furniture)
local Ghost = require(script.Parent.Ghost)
local Quests = require(script.Parent.Quests)
local Ragdoll = require(script.Parent.Ragdoll)
local Fury = require(script.Parent.Fury)
local P, ST, BR, CA = Config.Punch, Config.Stamina, Config.Brutality, Config.Carry

local Combat = {}
local state = {} :: { [Player]: any }
Combat.runUltimate = nil :: ((player: Player, def: any, center: Vector3) -> ())?
Combat.explode = nil :: ((player: Player, pos: Vector3, radius: number, color: Color3) -> ())?

-- upgrades were removed: stats are neutral (kept so call sites stay simple)
function Combat.stat(_player: Player, key: string): number
	return (key == "health" or key == "lifesteal") and 0 or 1
end

local function st(player: Player)
	local s = state[player]
	if not s then
		s = { stamina = ST.Max, lastUse = 0, brut = 0, ultUntil = 0, ultDur = 1, buff = {}, ultColor = Color3.new(1, 0.3, 0.1),
			combo = 0, lastHit = 0, lastPunch = 0, carrying = nil, sprinting = false, lastSync = 0, onePunch = false, giantUntil = 0,
			speedMult = 1, speedUntil = 0, shield = 0 }
		state[player] = s
	end
	return s
end
Combat.state = st

local function ult(s): boolean return os.clock() < s.ultUntil end
local function buff(s, key: string): any
	if not ult(s) then return nil end
	return s.buff[key]
end
local function bmul(s, key: string): number return (buff(s, key) :: number?) or 1 end

local function sync(player: Player, s, force: boolean?)
	local now = os.clock()
	if not force and now - s.lastSync < 0.08 then return end
	s.lastSync = now
	player:SetAttribute("Stamina", math.floor(s.stamina + 0.5))
	player:SetAttribute("Brutality", math.floor(s.brut + 0.5))
	player:SetAttribute("UltActive", ult(s))
	player:SetAttribute("Combo", s.combo)
end

local function alive(player: Player): (Humanoid?, BasePart?)
	local ch = player.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hum and hum.Health > 0 and hrp then return hum, hrp end
	return nil, nil
end

local function validDir(v: any): Vector3?
	if typeof(v) ~= "Vector3" then return nil end
	if v.X ~= v.X or v.Y ~= v.Y or v.Z ~= v.Z or v.Magnitude < 0.5 or v.Magnitude > 2 then return nil end
	return v.Unit
end

local function setWalk(player: Player, s)
	local hum = alive(player)
	if not hum then return end
	local base = s.sprinting and not s.blocking and s.stamina > 2 and Config.Player.SprintSpeed or Config.Player.WalkSpeed
	base *= bmul(s, "speed") * (os.clock() < s.speedUntil and s.speedMult or 1)
	if s.carrying and s.carrying.Parent then
		base = math.max(8, base - Furniture.weight(s.carrying) * CA.SlowPerWeight * (ult(s) and 0.3 or 1))
	end
	if s.blocking then base = math.min(base, Config.Player.WalkSpeed * Config.Block.WalkMult) end
	if os.clock() < (s.rootUntil or 0) then base = 0 end
	hum.WalkSpeed = base
end

local function dropCarried(player: Player, s)
	local m = s.carrying
	s.carrying = nil
	player:SetAttribute("Carrying", false)
	if m and m.Parent and not m:GetAttribute("Broken") then
		local hrp = select(2, alive(player))
		local dir = hrp and hrp.CFrame.LookVector or Vector3.new(0, 0, -1)
		Furniture.throw(player, m, dir, 8)
	end
	setWalk(player, s)
end

-- blocking (right click): a hit from the front (from = where it came from; the monster if nil) is mostly stopped and
-- costs stamina; without enough stamina the guard breaks. Returns the damage multiplier (1 = not blocked).
local BL = Config.Block
local function setBlocking(player: Player, s, on: boolean)
	s.blocking = on
	player:SetAttribute("Blocking", on)
	setWalk(player, s)
end
local function guard(player: Player, s, amount: number, from: Vector3?): number
	if not s.blocking or amount <= 0 then return 1 end
	local _, hrp = alive(player)
	if not hrp then return 1 end
	local src = from or (Ghost.current and Ghost.current.hrp and Ghost.current.hrp.Position)
	if src then
		local to = Vector3.new(src.X - hrp.Position.X, 0, src.Z - hrp.Position.Z)
		local look = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
		if to.Magnitude > 0.1 and look.Magnitude > 0.1 and look.Unit:Dot(to.Unit) < BL.FrontDot then return 1 end -- from behind
	end
	local cost = BL.Cost + amount * BL.PerDamage
	s.lastUse = os.clock()
	if s.stamina >= cost then
		s.stamina -= cost
		sync(player, s, true)
		Remotes.Fx:FireClient(player, "Blocked", amount, false)
		Quests.add(player, "blocks")
		return BL.Damage
	end
	-- out of stamina: the guard breaks, the hit lands in full
	s.stamina = 0
	s.blockBrokenUntil = os.clock() + BL.BreakTime
	setBlocking(player, s, false)
	sync(player, s, true)
	Remotes.Fx:FireClient(player, "Blocked", amount, true)
	return 1
end
Combat.guard = function(player: Player, amount: number, from: Vector3?): number return guard(player, st(player), amount, from) end

-- monster hits: the second one within Knockdown.Window seconds knocks you down. Returns true when it does
-- (the counter starts over).
local KD = Config.Knockdown
local function knockdownHit(player: Player, s): boolean
	local now = os.clock()
	if s.lastMonsterHit and now - s.lastMonsterHit <= KD.Window then
		s.lastMonsterHit = nil
		return true
	end
	s.lastMonsterHit = now
	return false
end
local function knockDown(player: Player, from: Vector3?)
	local _, hrp = alive(player)
	if not hrp then return end
	Fury.downed(player, KD.Time) -- no claws on a player who is down
	local src = from or (Ghost.current and Ghost.current.hrp and Ghost.current.hrp.Position) or (hrp.Position - hrp.CFrame.LookVector)
	local away = Vector3.new(hrp.Position.X - src.X, 0, hrp.Position.Z - src.Z)
	away = away.Magnitude > 0.1 and away.Unit or -hrp.CFrame.LookVector
	Remotes.Fx:FireClient(player, "Fling", away * KD.Speed + Vector3.new(0, KD.Lift, 0), KD.Time, "", "knockdown")
end

-- from = where the hit came from (for blocking; the monster if nil). Vector3.zero = not a monster's blow (fire,
-- gas, or already handled by hitPlayer): no blocking, no knockdown count.
function Combat.damagePlayer(player: Player, amount: number, staminaDrain: number?, from: Vector3?)
	local hum = alive(player)
	if not hum then return end
	local s = st(player)
	local blowFromMonster = from ~= Vector3.zero and amount > 0
	if blowFromMonster then
		local mult = guard(player, s, amount, from)
		amount *= mult
		if mult < 1 then blowFromMonster = false end -- blocked: doesn't count toward the knockdown
	end
	if player:GetAttribute("Warded") or player:GetAttribute("AdminGod") then return end
	if blowFromMonster and knockdownHit(player, s) then knockDown(player, from) end
	-- a monster can't take more than a set share of your health in a few seconds (Config.Fury.BurstCap)
	if from ~= Vector3.zero then amount = Fury.cap(player, amount, hum.MaxHealth) end
	if s.shield > 0 then
		local absorbed = math.min(s.shield, amount)
		s.shield -= absorbed
		amount -= absorbed
		player:SetAttribute("Shield", math.floor(s.shield))
	end
	hum:TakeDamage(amount)
	if staminaDrain then
		s.stamina = math.max(0, s.stamina - staminaDrain)
		s.lastUse = os.clock()
		sync(player, s, true)
	end
end

local function heal(player: Player, n: number)
	local hum = alive(player)
	if hum and n > 0 then hum.Health = math.min(hum.MaxHealth, hum.Health + n) end
end
Combat.heal = heal

function Combat.refillStamina(player: Player)
	local s = st(player)
	s.stamina = ST.Max
	sync(player, s, true)
end

function Combat.speedBuff(player: Player, mult: number, t: number)
	local s = st(player)
	s.speedMult = mult
	s.speedUntil = os.clock() + t
	setWalk(player, s)
	task.delay(t + 0.05, function() if state[player] == s then setWalk(player, s) end end)
end

function Combat.addShield(player: Player, n: number)
	local s = st(player)
	s.shield += n
	player:SetAttribute("Shield", math.floor(s.shield))
end

-- stop a running ultimate at once (admin: equip and try the next one without waiting)
function Combat.endUltimate(player: Player)
	local s = st(player)
	if s.ultUntil <= 0 then return end
	s.ultUntil = 0
	s.brut = 0
	s.onePunch = false
	if os.clock() < (s.giantUntil or 0) then
		s.giantUntil = 0
		local ch = player.Character
		if ch then pcall(function() ch:ScaleTo(1) end) end
	end
	setWalk(player, s)
	sync(player, s, true)
end

-- let go of the furniture in the hands (leaving the sandbox)
function Combat.release(player: Player)
	local s = st(player)
	if s.carrying then dropCarried(player, s) end
end

function Combat.fillBrutality(player: Player)
	local s = st(player)
	if not ult(s) then s.brut = BR.Max; sync(player, s, true) end
end

function Combat.useStamina(player: Player, n: number): boolean
	local s = st(player)
	if buff(s, "staminaFree") then return true end
	if s.stamina < n then
		Remotes.Fx:FireClient(player, "Tired")
		return false
	end
	s.stamina -= n
	s.lastUse = os.clock()
	sync(player, s, true)
	return true
end

function Combat.giant(player: Player, scale: number, dur: number)
	local ch = player.Character
	if not ch then return end
	local s = st(player)
	s.giantUntil = os.clock() + dur
	-- grow (and later shrink) over half a second instead of popping
	local function scaleTo(to: number)
		local from = ch:GetScale()
		for i = 1, 10 do
			if player.Character ~= ch or not ch.Parent then return end
			if to > 1 and os.clock() >= s.giantUntil then return end -- the ultimate was stopped while growing
			local a = i / 10
			pcall(function() ch:ScaleTo(from + (to - from) * (1 - (1 - a) * (1 - a))) end)
			task.wait(0.05)
		end
	end
	task.spawn(scaleTo, scale)
	task.delay(dur, function()
		if os.clock() >= s.giantUntil - 0.05 and player.Character == ch and ch.Parent then scaleTo(1) end
	end)
end

-- where a strike from this player's head along dir hits the ghost (nil = miss)
function Combat.tryHit(player: Player, dir: Vector3, range: number): Vector3?
	local _, hrp = alive(player)
	local g = Ghost.current
	if not hrp or not g or not Ghost.alive() or g.state == "Spawn" or g.model:GetAttribute("Vanish") then return nil end
	local head = (player.Character :: Model):FindFirstChild("Head") :: BasePart?
	local from = head and head.Position or hrp.Position
	range *= math.max(1, (player.Character :: Model):GetScale())
	local best, hitPos = math.huge, nil
	for _, name in { "HumanoidRootPart", "UpperTorso", "Head", "LowerTorso" } do
		local part = g.model:FindFirstChild(name) :: BasePart?
		if part then
			local to = part.Position - from
			if to.Magnitude < best and dir:Dot(to.Unit) >= P.ConeDot then best = to.Magnitude; hitPos = part.Position end
		end
	end
	if best <= range then return hitPos end
	return nil
end

-- a charged hit's power (0..1), capped by the server's own clock: the client tells the server when the button went
-- down (Remotes.Charge); reaching charge c needs it held MinHold + c * Full seconds (with slack for latency).
-- One press = one charged hit.
local CH = Config.Charge
function Combat.chargeStart(player: Player)
	st(player).holdStart = os.clock()
end
function Combat.validCharge(player: Player, raw: any): number
	local s = st(player)
	local since = s.holdStart
	s.holdStart = nil
	if not since or type(raw) ~= "number" or raw ~= raw or raw <= 0 then return 0 end
	local maxC = (os.clock() - since - CH.MinHold * 0.7) / (CH.Full * 0.8)
	return math.clamp(math.min(raw, maxC), 0, 1)
end

-- a landed hit: combo, ultimate buffs, knockback, brutality, effects. Returns the damage dealt.
-- charge (0..1, already validated) = a charged attack: more damage and knockback
-- obj = a thrown item hit (Ghost.hit applies the monster's objTaken)
function Combat.registerHit(player: Player, dir: Vector3, hitPos: Vector3, baseDmg: number, baseKnock: number, knockPerCombo: number?, comboStep: number?, charge: number?, obj: boolean?): number
	local s = st(player)
	local now = os.clock()
	local step = comboStep or 1
	if buff(s, "comboLock") then
		s.combo += 2 * step
	elseif step > 0 then
		s.combo = (now - s.lastHit <= P.ComboWindow) and s.combo + 1 or 1
	elseif now - s.lastHit > P.ComboWindow then
		s.combo = 0
	end
	s.lastHit = now
	local cscale = math.min(1 + math.max(s.combo - 1, 0) * P.ComboDamageStep, P.MaxComboScale)
	local isUlt = ult(s)
	local dmg = baseDmg * cscale * bmul(s, "damage")
	if buff(s, "onePunch") and s.onePunch then
		dmg *= 20
		s.onePunch = false
		Remotes.Fx:FireAllClients("OnePunch", hitPos, player)
	end
	local knock = math.min(baseKnock + s.combo * (knockPerCombo or P.KnockPerCombo), P.MaxKnock) * bmul(s, "knock")
	local c = charge or 0
	if c > 0 then
		dmg *= 1 + c * CH.DamageBonus
		knock *= 1 + c * CH.KnockBonus
	end
	Ghost.hit(player, dir, knock, dmg, obj, c >= 0.6)
	local ls = (buff(s, "lifesteal") :: number?) or 0
	if ls > 0 then heal(player, dmg * ls) end
	local burn = buff(s, "burnOnHit")
	if burn then Ghost.burn(burn, 3, s.ultColor) end
	local ex = buff(s, "explode")
	if ex and Combat.explode then Combat.explode(player, hitPos, ex, s.ultColor) end
	if not isUlt then s.brut = math.min(BR.Max, s.brut + (BR.PerHit + math.min(s.combo, 20) * BR.PerCombo) * (step > 0 and 1 or 0.35)) end
	Remotes.Fx:FireAllClients("Hit", hitPos, math.max(s.combo, 1), dmg, isUlt, player)
	if c >= CH.MinRelease then Remotes.Fx:FireAllClients("ChargedHit", hitPos, c, player) end
	-- quests: hits (or thrown-object hits), fully charged hits, best combo
	Quests.add(player, obj and "throws" or "hits")
	if c >= 0.95 then Quests.add(player, "charged") end
	Quests.add(player, "combo", s.combo)
	sync(player, s, true)
	return dmg
end

-- a giant (an ultimate that makes you bigger) punches straight through the house's inside walls: the hit aimed at a
-- wall in reach carves a hole the giant's size (the walls are back with the next monster, like the Demon's holes)
function Combat.giantSmash(player: Player, dir: Vector3): boolean
	local s = st(player)
	if os.clock() >= (s.giantUntil or 0) then return false end
	local ch = player.Character
	local head = ch and ch:FindFirstChild("Head") :: BasePart?
	local m = workspace:FindFirstChild("Mansion")
	local structure = m and m:FindFirstChild("Structure")
	if not ch or not head or not structure then return false end
	local scale = math.max(1, ch:GetScale())
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { structure }
	local r = workspace:Raycast(head.Position, dir * (P.Range * scale * 0.8 + 4), rp)
	if not r or r.Normal.Y > 0.6 then return false end
	if Ragdoll.breakWalls(r.Position, dir * 90, 6 + 2 * scale, 4 + 2 * scale) > 0 then
		Remotes.Fx:FireAllClients("WallSmash", r.Position, 120)
		return true
	end
	return false
end

local function onPunch(player: Player, look: any, rawCharge: any)
	local dir = validDir(look)
	local hum, hrp = alive(player)
	if not dir or not hum or not hrp then return end
	local s = st(player)
	local now = os.clock()
	if s.carrying or s.blocking then return end
	if now - s.lastPunch < P.Cooldown * 0.8 then return end
	local charge = Combat.validCharge(player, rawCharge)
	if not Combat.useStamina(player, P.StaminaCost * (1 + charge * CH.StaminaBonus)) then return end
	s.lastPunch = now
	local head = (player.Character :: Model):FindFirstChild("Head") :: BasePart?
	local clonePos = Ghost.hitClone((head or hrp).Position, dir, P.Range, charge)
	if clonePos then
		Remotes.Fx:FireAllClients("Hit", clonePos, 1, 0, false, player)
		sync(player, s, true)
		return
	end
	Combat.giantSmash(player, dir)
	local hitPos = Combat.tryHit(player, dir, P.Range)
	if hitPos then Combat.registerHit(player, dir, hitPos, P.BaseDamage, P.BaseKnock, nil, nil, charge) end
	sync(player, s, true)
end

local function onUltimate(player: Player)
	local hum, hrp = alive(player)
	if not hum or not hrp then return end
	local s = st(player)
	if ult(s) or s.brut < BR.Max then return end
	-- the sandbox fires the ultimate on trial (owned or not: Server/Sandbox sets TrialUlt), a run the equipped one
	local trial = player:GetAttribute("Sandbox") and player:GetAttribute("TrialUlt")
	local def = Ultimates.byId[type(trial) == "string" and trial or Data.equipped(player)] or Ultimates.byId[Ultimates.default]
	s.ultDur = def.dur * Combat.stat(player, "ultDuration")
	s.ultUntil = os.clock() + s.ultDur
	s.buff = def.buff
	s.ultColor = def.color
	s.onePunch = def.buff.onePunch == true
	Remotes.Fx:FireAllClients("Ultimate", hrp.Position, player, def.id)
	if Combat.runUltimate then task.spawn(Combat.runUltimate, player, def, hrp.Position) end
	setWalk(player, s)
	sync(player, s, true)
end

local function onGrab(player: Player, m: any)
	local hum, hrp = alive(player)
	if not hum or not hrp then return end
	local s = st(player)
	if s.carrying then return end
	if not Furniture.isValid(m) or m:GetAttribute("CarriedBy") then return end
	local cf, size = m:GetBoundingBox()
	if (cf.Position - hrp.Position).Magnitude > CA.Range + size.Magnitude / 2 then return end
	if Furniture.grab(player, m) then
		s.carrying = m
		player:SetAttribute("Carrying", true)
		player:SetAttribute("CarryWeight", Furniture.weight(m))
		Remotes.Fx:FireAllClients("Lift", cf.Position, player)
		setWalk(player, s)
	end
end

local function onThrow(player: Player, look: any)
	local dir = validDir(look)
	local hum, hrp = alive(player)
	if not dir or not hum or not hrp then return end
	local s = st(player)
	local m = s.carrying
	if not m or not m.Parent then
		s.carrying = nil; player:SetAttribute("Carrying", false); return
	end
	s.carrying = nil
	player:SetAttribute("Carrying", false)
	local power = CA.ThrowSpeed * Combat.stat(player, "throw") * bmul(s, "throw")
	if s.stamina < ST.ThrowCost and not buff(s, "staminaFree") then power *= 0.6 end
	if not buff(s, "staminaFree") then s.stamina = math.max(0, s.stamina - ST.ThrowCost) end
	s.lastUse = os.clock()
	Furniture.throw(player, m, dir, power)
	Remotes.Fx:FireAllClients("Throw", hrp.Position, player)
	setWalk(player, s)
	sync(player, s, true)
end

-- PvP: something a player threw hits another player in the run. Damage + a fling, no damage to the thrower.
Combat.PVP_MULT = 0.5 -- player-vs-player damage is half of what the ghost would take
-- raw = vel is the exact fling velocity (monster throws), otherwise it is scaled to a PvP knock; ragT = ragdoll seconds
function Combat.hitPlayer(victim: Player, by: Player?, dmg: number, vel: Vector3, label: string?, raw: boolean?, ragT: number?)
	if victim == by or not victim:GetAttribute("InMatch") then return end
	if not by and victim:GetAttribute("Warded") then return end
	local hum, hrp = alive(victim)
	if not hum or not hrp then return end
	-- blocking: from the attacker (a player) or the monster; a blocked hit also barely moves you
	local byHrp: BasePart? = nil
	if by then
		local _, h = alive(by)
		byHrp = h
	end
	local vs = st(victim)
	local mult = guard(victim, vs, dmg, byHrp and byHrp.Position or nil)
	local amount = dmg * mult
	if not by and not victim:GetAttribute("Warded") and not victim:GetAttribute("AdminGod") then
		amount = Fury.cap(victim, amount, hum.MaxHealth) -- monster blows: burst cap
		Fury.downed(victim, ragT or (raw and 1.2 or 0.9)) -- thrown: a moment before the next claw
	end
	Combat.damagePlayer(victim, amount, nil, Vector3.zero)
	if mult < 1 then vel *= Config.Block.Knock end
	-- a monster's ability blow counts toward the knockdown (it already throws you; the 2nd one keeps you down longer)
	if not by and mult >= 1 and knockdownHit(victim, vs) then ragT = math.max(ragT or 0, KD.Time) end
	local fling = vel
	if not raw then
		local flat = Vector3.new(vel.X, 0, vel.Z)
		flat = flat.Magnitude > 0.1 and flat.Unit or Vector3.new(0, 0, 1)
		fling = flat * math.clamp(vel.Magnitude * 0.6, 30, 70) + Vector3.new(0, 26, 0)
	end
	Remotes.Fx:FireClient(victim, "Fling", fling, ragT or (raw and 1.2 or 0.9), by and by.Name or "", label or "")
	Remotes.Fx:FireAllClients("PlayerHit", hrp.Position, dmg, by, label or "")
end

-- the closest other match player within radius of pos (not the thrower)
function Combat.playerNear(pos: Vector3, radius: number, except: Player?): Player?
	local best, bestD = nil, radius
	for _, p in Players:GetPlayers() do
		if p ~= except and p:GetAttribute("InMatch") then
			local _, hrp = alive(p)
			if hrp then
				local d = (hrp.Position - pos).Magnitude
				if d < bestD then best, bestD = p, d end
			end
		end
	end
	return best
end

local function checkThrownPlayers()
	for m, info in Furniture.thrown do
		local prim = m.PrimaryPart
		-- thrown by a player (PvP) or by a monster (poltergeist: info.monster = its damage)
		if prim and m.Parent and (info.by or info.monster) and os.clock() - info.t > 0.1 then
			local _, size = m:GetBoundingBox()
			local victim = Combat.playerNear(prim.Position, 2.6 + size.Magnitude * 0.25, info.by)
			if victim then
				local w = Furniture.weight(m)
				local vel = prim.AssemblyLinearVelocity
				local dmg = info.monster or (CA.BaseDamage + w * CA.DamagePerWeight) * Combat.PVP_MULT
				Combat.hitPlayer(victim, info.by, dmg, vel, "furniture")
				Furniture.smash(m, vel, 120)
			end
		end
	end
end

-- pinned to the floor (crawler pounce): no walking for t seconds
function Combat.root(player: Player, t: number)
	local s = st(player)
	s.rootUntil = os.clock() + t
	setWalk(player, s)
	player:SetAttribute("Pinned", true)
	task.delay(t + 0.05, function()
		if state[player] == s then
			player:SetAttribute("Pinned", false)
			setWalk(player, s)
		end
	end)
end

-- thrown furniture that reaches the ghost hits her hard
local function checkThrown()
	checkThrownPlayers()
	local g = Ghost.current
	if not g or not Ghost.alive() or g.state == "Spawn" then return end
	for m, info in Furniture.thrown do
		local prim = m.PrimaryPart
		if info.monster then continue end -- the monster's own throws (poltergeist) don't hit it
		if not prim or not m.Parent then
			Furniture.thrown[m] = nil
		else
			local _, size = m:GetBoundingBox()
			if (prim.Position - g.hrp.Position).Magnitude < 3.2 + size.Magnitude * 0.3 then
				local by = info.by
				local w = Furniture.weight(m)
				local dmg, knockMul, isUlt = 10 + w * 7, 1, false
				local s
				if by and by.Parent then
					s = st(by)
					isUlt = ult(s)
					dmg = (CA.BaseDamage + w * CA.DamagePerWeight) * Combat.stat(by, "damage") * Combat.stat(by, "throw") * bmul(s, "throw")
					knockMul = isUlt and 1.5 or 1
				end
				local vel = prim.AssemblyLinearVelocity
				Ghost.hit(by, vel, math.min(60 + w * 14, 170) * knockMul, dmg, true)
				if by and by.Parent then Quests.add(by, "throws") end
				if s and not isUlt then s.brut = math.min(BR.Max, s.brut + BR.ThrowHit * Combat.stat(by, "brutality")) end
				Remotes.Fx:FireAllClients("Hit", prim.Position, math.max(s and s.combo or 0, 4), dmg, isUlt, by)
				Furniture.smash(m, vel, 120)
				if s then sync(by, s, true) end
			end
		end
	end
end

local function setupCharacter(player: Player, ch: Model)
	local s = st(player)
	s.carrying = nil
	s.stamina = ST.Max
	s.combo = 0
	s.ultUntil = 0
	s.shield = 0
	s.speedUntil = 0
	player:SetAttribute("Shield", 0)
	player:SetAttribute("Carrying", false)
	local hum = ch:WaitForChild("Humanoid") :: Humanoid
	hum.MaxHealth = Config.Player.MaxHealth + Combat.stat(player, "health")
	hum.Health = hum.MaxHealth
	setWalk(player, s)
	for _, p in ch:GetDescendants() do if p:IsA("BasePart") then p.CollisionGroup = "Players" end end
	ch.DescendantAdded:Connect(function(p) if p:IsA("BasePart") then p.CollisionGroup = "Players" end end)
	hum.Died:Connect(function()
		if s.carrying then dropCarried(player, s) end
		s.ultUntil = 0
		s.brut = math.floor(s.brut * 0.5)
		sync(player, s, true)
	end)
	sync(player, s, true)
end

function Combat.refreshHealth(player: Player)
	local hum = alive(player)
	if hum then
		local mx = Config.Player.MaxHealth + Combat.stat(player, "health")
		hum.MaxHealth = mx
		hum.Health = math.min(hum.Health + 40, mx)
	end
	setWalk(player, st(player))
end

function Combat.healAll(list: { Player }?)
	for _, p in list or Players:GetPlayers() do
		local hum = alive(p)
		if hum then hum.Health = hum.MaxHealth end
		local s = st(p)
		s.stamina = ST.Max
		sync(p, s, true)
	end
end

function Combat.start()
	Ghost.damagePlayer = Combat.damagePlayer
	Ghost.hitPlayer = Combat.hitPlayer
	Ghost.rootPlayer = Combat.root
	Remotes.Punch.OnServerEvent:Connect(onPunch)
	Remotes.Ultimate.OnServerEvent:Connect(onUltimate)
	Remotes.Grab.OnServerEvent:Connect(onGrab)
	Remotes.Throw.OnServerEvent:Connect(onThrow)
	Remotes.Sprint.OnServerEvent:Connect(function(player, on)
		local s = st(player)
		s.sprinting = on == true
		setWalk(player, s)
	end)
	Remotes.Charge.OnServerEvent:Connect(function(player) Combat.chargeStart(player) end)
	Remotes.Block.OnServerEvent:Connect(function(player, on)
		local s = st(player)
		local want = on == true and player:GetAttribute("InMatch") == true and not s.carrying and os.clock() >= (s.blockBrokenUntil or 0)
		if want ~= (s.blocking == true) then setBlocking(player, s, want) end
	end)
	local function onPlayer(p: Player)
		st(p)
		if RunService:IsStudio() then
			-- Studio-only test hooks (set these attributes from a server test script)
			p:GetAttributeChangedSignal("DebugBrut"):Connect(function()
				local s = st(p); s.brut = BR.Max; sync(p, s, true)
			end)
			p:GetAttributeChangedSignal("DebugUltEnd"):Connect(function() Combat.endUltimate(p) end)
			p:GetAttributeChangedSignal("DebugCash"):Connect(function() Data.addCash(p, p:GetAttribute("DebugCash") or 0) end)
			p:GetAttributeChangedSignal("DebugUlt"):Connect(function()
				local id = p:GetAttribute("DebugUlt")
				if type(id) == "string" and Ultimates.byId[id] then Data.ownUlt(p, id); Data.equipUlt(p, id) end
			end)
		end
		p.CharacterAdded:Connect(function(ch) setupCharacter(p, ch) end)
		if p.Character then task.spawn(setupCharacter, p, p.Character) end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in Players:GetPlayers() do onPlayer(p) end
	Players.PlayerRemoving:Connect(function(p)
		local s = state[p]
		if s and s.carrying then Furniture.release(s.carrying) end
		state[p] = nil
	end)
	RunService.Heartbeat:Connect(function(dt)
		local now = os.clock()
		for p, s in state do
			local hum = alive(p)
			if s.sprinting and hum and hum.MoveDirection.Magnitude > 0.1 and s.stamina > 0 and not buff(s, "staminaFree") then
				s.stamina = math.max(0, s.stamina - ST.SprintPerSecond * dt)
				s.lastUse = now
				if s.stamina <= 0 then setWalk(p, s) end
			elseif not s.blocking and now - s.lastUse > ST.RegenDelay and s.stamina < ST.Max then
				s.stamina = math.min(ST.Max, s.stamina + ST.Regen * Combat.stat(p, "stamina") * dt)
			end
			if ult(s) then
				s.brut = math.max(0, BR.Max * (s.ultUntil - now) / s.ultDur)
			elseif s.ultUntil > 0 then
				s.ultUntil = 0
				s.brut = 0
				s.onePunch = false
				setWalk(p, s)
				sync(p, s, true)
			elseif p:GetAttribute("Sandbox") and s.brut < BR.Max then
				s.brut = math.min(BR.Max, s.brut + BR.Max * dt / 1.5) -- the sandbox: the next ultimate is ready in 1.5 s
			end
			if s.combo > 0 and not buff(s, "comboLock") and now - s.lastHit > P.ComboWindow * Combat.stat(p, "combo") then s.combo = 0 end
			if s.carrying and (not s.carrying.Parent or s.carrying:GetAttribute("Broken")) then
				s.carrying = nil; p:SetAttribute("Carrying", false); setWalk(p, s)
			end
			sync(p, s)
		end
		checkThrown()
	end)
end

return Combat
