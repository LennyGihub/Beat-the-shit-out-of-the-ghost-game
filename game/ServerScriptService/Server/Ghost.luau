-- The monster of the current ghost wave (the Woman on wave 1, then a random one from Shared/Monsters).
-- Floats/walks through walls toward the nearest player, claws, uses its special ability (Abilities.luau),
-- gets knocked flying. Knockback is scripted: it stops at walls (wall slam) and smashes furniture on the way.
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)
local Abilities = require(script.Parent.Abilities)
local Ragdoll = require(script.Parent.Ragdoll)
local Fire = require(script.Parent.Fire)
local Monsters = require(RS.Shared.Monsters)
local MapLoader = require(script.Parent.MapLoader)
local Fury = require(script.Parent.Fury)
local Evolved = require(script.Parent.Evolved)
local Entrances = require(RS.Shared.Entrances)
local C = Config.Ghost

local Ghost = {}
Ghost.current = nil :: any
Ghost.onDeath = nil :: ((g: any) -> ())?
Ghost.damagePlayer = nil :: ((p: Player, n: number, staminaDrain: number?, from: Vector3?) -> ())?
-- injected by Combat: damage + fling a player, and pin a player in place
Ghost.hitPlayer = nil :: any
Ghost.rootPlayer = nil :: any
-- difficulty of the current run (set by Run): multipliers on monster hp / damage / speed
Ghost.diff = { hp = 1, dmg = 1, speed = 1 }
local rng = Random.new()

local function structParams(): RaycastParams
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	local s = workspace:FindFirstChild("Mansion") and workspace.Mansion:FindFirstChild("Structure")
	rp.FilterDescendantsInstances = { s or workspace.Terrain, workspace:FindFirstChild("Baseplate") or workspace.Terrain }
	return rp
end

local function floorBelow(pos: Vector3, rp: RaycastParams): number
	local r = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -60, 0), rp)
	return r and r.Position.Y or (pos.Y - C.HoverHeight)
end

-- knocked into an inside wall this fast, a monster smashes through it (slower: it bounces off, so you can pin it)
local BREAK_SPEED = 50

-- solid monsters (the Demon) cannot walk through walls: the part of their motion that goes into a wall is removed
local function blockWalls(g, v: Vector3): Vector3
	local hv = Vector3.new(v.X, 0, v.Z)
	if hv.Magnitude < 0.1 then return v end
	for _, h in { -1.5, 1.5 } do
		local r = workspace:Raycast(g.hrp.Position + Vector3.new(0, h, 0), hv.Unit * 3, g.rp)
		if r and r.Normal.Y < 0.6 then
			local n = Vector3.new(r.Normal.X, 0, r.Normal.Z)
			if n.Magnitude > 0.01 then
				n = n.Unit
				local d = hv:Dot(n)
				if d < 0 then hv -= n * d end
			end
		end
	end
	return Vector3.new(hv.X, v.Y, hv.Z)
end

-- ...and they walk around walls: the next point of a path to `goal` (recomputed in the background)
local function pathPoint(g, goal: Vector3): Vector3
	local now = os.clock()
	local P = g.path
	if not P then P = { t = 0, goal = goal, busy = false }; g.path = P end
	if not P.busy and (now - P.t > 0.7 or (P.goal - goal).Magnitude > 6) then
		P.busy = true
		task.spawn(function()
			local path = PathfindingService:CreatePath({ AgentRadius = 2.2, AgentHeight = 9, AgentCanJump = false, WaypointSpacing = 4 })
			local feet = g.hrp.Position - Vector3.new(0, g.hover - 0.5, 0)
			local ok = pcall(function() path:ComputeAsync(feet, goal) end)
			P.busy = false; P.t = os.clock(); P.goal = goal
			if ok and path.Status == Enum.PathStatus.Success then P.pts = path:GetWaypoints(); P.i = 2 else P.pts = nil end
		end)
	end
	if P.pts and P.i and P.pts[P.i] then
		local here = Vector3.new(g.hrp.Position.X, 0, g.hrp.Position.Z)
		local wp = P.pts[P.i].Position
		while P.pts[P.i + 1] and (Vector3.new(wp.X, 0, wp.Z) - here).Magnitude < 2.5 do
			P.i += 1
			wp = P.pts[P.i].Position
		end
		return wp
	end
	return goal
end

Ghost.pathPoint = pathPoint
Ghost.blockWalls = blockWalls

local function setState(g, s: string, dur: number?)
	if g.state == "Ability" and s ~= "Ability" and g.ab then Abilities.interrupt(g) end
	if g.state == "Evo" and s ~= "Evo" and g.evo then Evolved.interrupt(g) end -- an evolved power cut short
	if (g.state == "Roar" or g.state == "Lunge") and s ~= g.state then -- a fury move cut short
		g.fury = nil
		g.model:SetAttribute("FuryPhase", "")
	end
	g.state = s
	g.stateStart = os.clock()
	g.stateUntil = os.clock() + (dur or 0)
	g.model:SetAttribute("State", s)
end
Ghost.setState = setState

-- SPECIALS CAN'T BE INTERRUPTED: while a monster does its ability (or its evolved power, or the Woman's vanish and
-- scream) hits still hurt but don't knock it back, ragdoll it, launch it or push it, and a stun or a time stop only
-- PAUSES the move (it carries on afterwards). One exception can still be cut short: the Party Bear's lights-out hunt
-- (blackout).
local function unstoppable(g): boolean
	local s = g.state
	if s == "Ability" then return g.ab ~= nil and g.ab.kind ~= "blackout" end
	if s == "Evo" then return g.evo ~= nil end
	return s == "Vanish" or s == "Scare"
end
Ghost.unstoppable = unstoppable
-- the time fields a special keeps (Abilities / Evolved / Caller / GoblinLoot): moved on by the length of a pause
local TIME_KEYS = { "untilT", "landT", "nextBlink", "nextThrow", "standUntil", "nextBreath", "springAt", "nextTick", "nextPush", "nextShot" }
local function shiftTimers(g, by: number)
	g.stateUntil += by
	for _, t in { g.ab, g.evo } do
		if type(t) == "table" then
			for _, k in TIME_KEYS do
				if type(t[k]) == "number" then t[k] += by end
			end
		end
	end
end

-- the sandbox's training dummy (Server/Sandbox): she stands where she is, watches the nearest player and never
-- attacks, roars or gets enraged; hits, knockbacks, freezes and burns work as always
Ghost.passive = false

function Ghost.alive(): boolean
	return Ghost.current ~= nil and Ghost.current.state ~= "Dead"
end

-- the monster's model: ServerStorage.Monsters.<template> (falls back to the Woman's GhostTemplate)
local function template(def): Model
	local folder = SS:FindFirstChild("Monsters")
	local t = folder and folder:FindFirstChild(def.template)
	return (t or SS:WaitForChild("GhostTemplate")) :: Model
end

-- how many players are in the run (the monster is scaled to them)
local function teamSize(): number
	local n = 0
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("InMatch") then n += 1 end
	end
	-- Studio test hook: ReplicatedStorage attribute DebugTeamSize = n
	local dbg = game:GetService("RunService"):IsStudio() and RS:GetAttribute("DebugTeamSize")
	if type(dbg) == "number" then n = dbg end
	return math.max(1, n)
end

-- evoTier = nil for a normal monster, 1.. for an EVOLVED one (1 = the first of the run, kept beatable)
-- entrance = true: the monster makes its ENTRANCE (Shared/Entrances): it stays in "Spawn" for the length of its
-- cinematic (no damage taken, no moving, no attacking) and the clients get the "Entrance" effect.
function Ghost.spawn(level: number, pos: Vector3, monsterId: string?, evoTier: number?, entrance: boolean?)
	Ghost.despawn()
	Ragdoll.restoreWalls() -- walls she smashed through last time are back
	Fire.clear() -- and the fires are out
	local def = Monsters.byId[monsterId or "Woman"] or Monsters.byId.Woman
	if evoTier then def = Monsters.evolved(def.id, evoTier) end
	local m = template(def):Clone()
	m.Name = "Ghost"
	if (def :: any).evolved then Evolved.dress(m, def) end
	if def.scale ~= 1 then m:ScaleTo(def.scale) end
	local hrp = m:WaitForChild("HumanoidRootPart") :: BasePart
	-- an auto-rigged monster keeps its Humanoid for the joints, but must not walk/fall by itself
	local hum = m:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.EvaluateStateMachine = false
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	end
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then d.Anchored = false; d.CanCollide = false; d.CanTouch = false; d.Massless = d ~= hrp end
	end
	-- walkers stand on the floor: their "hover" is the root's height above their feet
	local hover = def.hover
	if def.walker then
		-- the lowest foot (weapons in the hands can hang lower than the feet, so not the bounding box)
		local bottom = math.huge
		for _, n in { "LeftFoot", "RightFoot" } do
			local f = m:FindFirstChild(n) :: BasePart?
			if f then bottom = math.min(bottom, f.Position.Y - f.Size.Y / 2) end
		end
		if bottom == math.huge then
			local cf, size = m:GetBoundingBox()
			bottom = cf.Position.Y - size.Y / 2
		end
		hover = hrp.Position.Y - bottom
	end
	local att = Instance.new("Attachment"); att.Parent = hrp
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att; lv.MaxForce = math.huge; lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.VectorVelocity = Vector3.zero; lv.Parent = hrp
	local ao = Instance.new("AlignOrientation")
	ao.Attachment0 = att; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.MaxTorque = math.huge; ao.Responsiveness = 30; ao.Parent = hrp
	m:PivotTo(CFrame.new(pos))
	-- more players = a stronger, faster monster (Config.Scaling)
	local SC = Config.Scaling
	local extra = teamSize() - 1
	local maxHp = math.floor((C.BaseHP + (level - 1) * C.HPPerLevel) * def.hp * Ghost.diff.hp * (1 + extra * SC.HpPerPlayer))
	local intro = entrance and Entrances.of(def.id) or Entrances.plain
	local late = intro - Entrances.plain -- its first attack, ability and power wait for the entrance to end
	m:SetAttribute("EntranceTime", entrance and intro or 0)
	m:SetAttribute("Hover", hover) -- root height above the floor (the entrances measure the body with it)
	m:SetAttribute("HP", maxHp)
	m:SetAttribute("MaxHP", maxHp)
	m:SetAttribute("Level", level)
	m:SetAttribute("MonsterId", def.id)
	m:SetAttribute("MonsterName", def.title)
	m:SetAttribute("Rarity", def.rarity)
	m:SetAttribute("Walker", def.walker)
	m:SetAttribute("Ability", "")
	m:SetAttribute("Evolved", (def :: any).evolved == true)
	m:SetAttribute("TeamSize", extra + 1)
	-- the whole monster reaches each client in one go (with streaming on, its parts could otherwise arrive
	-- after the model and its animation would have nothing to drive)
	m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	m.Parent = workspace
	pcall(function() hrp:SetNetworkOwner(nil) end)
	local g = {
		model = m, hrp = hrp, lv = lv, ao = ao, level = level, hp = maxHp, maxHp = maxHp,
		vel = Vector3.zero, state = "Spawn", stateStart = os.clock(), stateUntil = os.clock() + intro,
		nextAttack = os.clock() + 3 + late, nextScare = os.clock() + late + rng:NextNumber(C.ScareMin, C.ScareMax),
		damageBy = {} :: { [Player]: number }, target = nil :: Player?, rp = structParams(),
		frozenUntil = 0, slowMult = 1, slowUntil = 0, vulnMult = 1, vulnUntil = 0, burns = {}, ts = nil :: any, launch = nil :: any, fire = nil :: { Instance }?,
		def = def, hover = hover, bob = def.walker and 0 or 0.35, ab = nil :: any, nextAbility = os.clock() + 5 + late,
		speedMult = def.speed * Ghost.diff.speed * (1 + extra * SC.SpeedPerPlayer),
		dmgMult = def.dmg * Ghost.diff.dmg * (1 + extra * SC.DmgPerPlayer),
		evolved = (def :: any).evolved == true, evo = nil :: any, nextPower = os.clock() + 6 + late,
		cdBase = ((def :: any).atk or 1) * math.max(0.6, 1 - extra * SC.CooldownPerPlayer),
	}
	Ghost.current = g
	Fury.init(g)
	if g.evolved then Evolved.onSpawn(g, Ghost) end
	setState(g, "Spawn", intro)
	-- (pos, monster, evolved, entrance): the fight music is this monster's own; with an entrance its voice comes
	-- from the cinematic
	Remotes.Fx:FireAllClients("GhostSpawn", pos, def.id, g.evolved, entrance == true)
	if entrance then Remotes.Fx:FireAllClients("Entrance", m, def.id, g.evolved, def.title, def.rarity, level, intro) end
	return g
end

function Ghost.despawn()
	local g = Ghost.current
	if g and g.loot then Abilities.dropLoot(g, Ghost) end
	if g and g.model then g.model:Destroy() end
	Ghost.current = nil
	Abilities.clear()
end

Ghost.restoreWalls = Ragdoll.restoreWalls

-- mirror clones can be punched apart
Ghost.hitClone = Abilities.hitClone

local function pickTarget(g): (Player?, BasePart?)
	local best, bestD, bestHrp = nil, math.huge, nil
	for _, p in Players:GetPlayers() do
		local ch = p.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hum and hum.Health > 0 and hrp and p:GetAttribute("InMatch") then
			local pos = hrp.Position
			local B = Ghost.houseBounds()
			local inside = pos.X > B.min.X and pos.X < B.max.X and pos.Z > B.min.Z and pos.Z < B.max.Z
			if inside then
				local d = (pos - g.hrp.Position).Magnitude + (Fury.inGrace(p) and 40 or 0) -- leave a downed player be
				if d < bestD then best, bestD, bestHrp = p, d, hrp end
			end
		end
	end
	return best, bestHrp
end

local function die(g)
	if g.loot then Abilities.dropLoot(g, Ghost) end
	setState(g, "Dead")
	Abilities.clear()
	g.model:SetAttribute("Shadow", false)
	g.lv.VectorVelocity = Vector3.new(0, 2, 0)
	Remotes.Fx:FireAllClients("GhostDeath", g.hrp.Position)
	if Ghost.onDeath then task.spawn(Ghost.onDeath, g) end
	task.delay(4, function()
		if Ghost.current == g then Ghost.despawn() end
	end)
end

function Ghost.damage(amount: number, by: Player?)
	local g = Ghost.current
	if not g or g.state == "Dead" or g.state == "Spawn" then return end
	if by then g.damageBy[by] = (g.damageBy[by] or 0) + amount end
	if g.ts and os.clock() < g.ts.untilT then
		g.ts.stored += amount -- time is stopped: damage lands all at once later
		return
	end
	if os.clock() < g.frozenUntil then amount *= 1.5 end
	if os.clock() < g.vulnUntil then amount *= g.vulnMult end
	-- Studio test hook: ReplicatedStorage attribute DebugGhostGod = true, she takes the hits but never dies
	if game:GetService("RunService"):IsStudio() and RS:GetAttribute("DebugGhostGod") then amount = math.min(amount, g.hp - 1) end
	g.hp = math.max(0, g.hp - amount)
	g.model:SetAttribute("HP", g.hp)
	if g.hp <= 0 then die(g) elseif not Ghost.passive then Fury.checkEnrage(g) end
end

-- ultimate effects -------------------------------------------------------
-- force = a time stop (the Flayed Giant shrugs off every other stun: Monsters noStagger)
function Ghost.freeze(t: number, force: boolean?)
	local g = Ghost.current
	if not g or g.state == "Dead" then return end
	if (g.def :: any).noStagger and not force then
		Remotes.Fx:FireAllClients("FuryArmor", g.hrp.Position)
		return
	end
	g.frozenUntil = math.max(g.frozenUntil, os.clock() + t)
	if unstoppable(g) then
		-- a special is paused, not cancelled: it goes on where it was once the stun wears off
		g.pauseFrom = g.pauseFrom or os.clock()
		g.model:SetAttribute("Frozen", true)
		return
	end
	if g.state == "WindUp" or g.state == "Swipe" or g.state == "Vanish" or g.state == "Scare" or g.state == "Ability" or g.state == "Roar" or g.state == "Lunge" or g.state == "Evo" then
		g.model:SetAttribute("Vanish", false)
		g.fury = nil
		g.model:SetAttribute("FuryPhase", "")
		setState(g, "Chase")
	end
	g.model:SetAttribute("Frozen", true)
end

function Ghost.timeStop(t: number, mult: number)
	local g = Ghost.current
	if not g or g.state == "Dead" then return end
	g.ts = { untilT = os.clock() + t, stored = 0, mult = mult }
	g.model:SetAttribute("TimeStop", true)
	Ghost.freeze(t, true)
end

function Ghost.slow(mult: number, t: number)
	local g = Ghost.current
	if not g then return end
	g.slowMult = mult
	g.slowUntil = os.clock() + t
end

function Ghost.burn(dps: number, t: number, color: Color3?, by: Player?)
	local g = Ghost.current
	if not g or g.state == "Dead" then return end
	table.insert(g.burns, { dps = dps, untilT = os.clock() + t, color = color or Color3.fromRGB(255, 110, 30), by = by })
end

function Ghost.launch(h: number, d: number, by: Player?)
	local g = Ghost.current
	if not g or g.state == "Dead" or g.state == "Spawn" or g.state == "Ragdoll" then return end
	if unstoppable(g) then return end
	g.model:SetAttribute("Vanish", false)
	g.launch = { phase = "up", topY = g.hrp.Position.Y + h, d = d, by = by }
	setState(g, "Launched")
end

-- she takes extra damage for a while (cursed doll)
function Ghost.vuln(mult: number, t: number)
	local g = Ghost.current
	if not g then return end
	g.vulnMult = mult
	g.vulnUntil = os.clock() + t
	g.model:SetAttribute("Vulnerable", true)
	task.delay(t, function() if g.model.Parent and os.clock() >= g.vulnUntil - 0.05 then g.model:SetAttribute("Vulnerable", false) end end)
end

-- push her with a velocity (leaf blower, shop vac, harpoon) without damage
function Ghost.shove(v: Vector3)
	local g = Ghost.current
	if not g or g.state == "Dead" or g.state == "Spawn" or g.state == "Launched" or g.state == "Ragdoll" then return end
	if g.ts and os.clock() < g.ts.untilT then return end
	if unstoppable(g) or (g.def :: any).noStagger then return end
	g.vel = v
	if g.state ~= "Knocked" then setState(g, "Knocked", 0.12) end
end

function Ghost.setVortex(t: number)
	local g = Ghost.current
	if not g then return end
	g.model:SetAttribute("Vortex", true)
	task.delay(t, function() if g.model.Parent then g.model:SetAttribute("Vortex", false) end end)
	Ghost.slow(0.05, t)
end

local function stepLaunched(g, dt: number)
	local L = g.launch
	local pos = g.hrp.Position
	if L.phase == "up" then
		local r = workspace:Raycast(pos, Vector3.new(0, 6, 0), g.rp)
		if r and r.Instance:GetAttribute("Breakable") and Ragdoll.breakWalls(r.Position + Vector3.new(0, 0.5, 0), Vector3.new(0, 75, 0)) > 0 then
			Remotes.Fx:FireAllClients("WallSmash", r.Position, 90) -- straight up through the deck
			r = nil
		end
		if pos.Y >= L.topY or r then
			if r then Remotes.Fx:FireAllClients("WallSlam", r.Position, 90) end
			L.phase = "down"
		end
		g.lv.VectorVelocity = Vector3.new(0, 75, 0)
	else
		g.lv.VectorVelocity = Vector3.new(0, -170, 0)
		local r = workspace:Raycast(pos, Vector3.new(0, -7, 0), g.rp)
		if r and r.Instance:GetAttribute("Breakable") and Ragdoll.breakWalls(r.Position - Vector3.new(0, 0.5, 0), Vector3.new(0, -170, 0)) > 0 then
			-- slammed down through a breakable deck: keep falling to the next floor
			Remotes.Fx:FireAllClients("WallSmash", r.Position, 160)
			for _, f in Furniture.near(r.Position, 10) do Furniture.smash(f, Vector3.new(0, 30, 0), 80) end
			Ghost.damage(L.d * 0.4, L.by)
			r = nil
		end
		if r then
			Remotes.Fx:FireAllClients("WallSlam", r.Position, 160)
			for _, f in Furniture.near(r.Position, 14) do Furniture.smash(f, Vector3.new(0, 40, 0), 90) end
			g.launch = nil
			setState(g, "Recover", 0.7)
			Ghost.damage(L.d, L.by)
		end
	end
end

-- Called by combat for punches, throws and the ultimate shockwave.
-- obj = the hit is a thrown object (furniture, a thrown item): the monster's objTaken applies
-- power = a charged hit (breaks the Fury armour: roar, counter-swipe)
-- noRagdoll = knocked back at most, never knocked out (thrown items)
function Ghost.hit(by: Player?, dir: Vector3, knock: number, damage: number, obj: boolean?, power: boolean?, noRagdoll: boolean?)
	local g = Ghost.current
	if not g or g.state == "Dead" or g.state == "Spawn" then return end
	local locked = unstoppable(g) -- in the middle of a special: it takes the damage and keeps going
	if g.model:GetAttribute("Vanish") and not locked then g.model:SetAttribute("Vanish", false) end
	if obj then damage *= (g.def :: any).objTaken or 1 end
	-- the Caller, found in his corner before he could strike: this hit counts several times and staggers him
	local found = Abilities.ambushHit(g, by)
	damage *= found
	-- the Pirate's raised shield blocks hits from the front: punches and swings almost fully, thrown objects by half
	if Abilities.blocks and Abilities.blocks(g, dir) then
		if obj then
			damage *= 0.5
			knock *= 0.5
		else
			damage *= 0.2
			knock = 0
		end
		Remotes.Fx:FireAllClients("ShieldBlock", g.hrp.Position + g.hrp.CFrame.LookVector * 2)
	end
	Ghost.damage(damage, by)
	-- any hit on the Party Bear while it hunts you in the dark breaks the hunt: the lights come back and it never
	-- reaches you (no strike, no jumpscare), even from weapons with no knockback
	if g.state == "Ability" and g.ab and g.ab.kind == "blackout" and g.def.ability.lightsOut then
		setState(g, "Recover", 0.6)
	end
	if knock <= 0 then return end
	if noRagdoll then knock = math.min(knock, Ragdoll.MIN_KNOCK - 1) end
	-- enraged, in a no-knockout window (Fury.checkEnrage): a knockout blow only knocks it back
	if knock >= Ragdoll.MIN_KNOCK and g.state ~= "Ragdoll" and Fury.unragdollable(g) then
		knock = Ragdoll.MIN_KNOCK - 1
		Remotes.Fx:FireAllClients("FuryArmor", g.hrp.Position)
	end
	if locked and unstoppable(g) then
		if g.state ~= "Dead" then Remotes.Fx:FireAllClients("FuryArmor", g.hrp.Position) end
		return
	end
	if g.state == "Dead" then return end
	Fury.onHit(g, knock, knock >= Ragdoll.MIN_KNOCK and g.state ~= "Ragdoll")
	-- roaring, or swiping back after a beating: plain hits and combos still hurt but don't stagger it.
	-- A charged hit or a really heavy blow (Config.Fury.ArmorBreakKnock) still sends it flying.
	if Fury.armored(g) and not power and knock < Config.Fury.ArmorBreakKnock then
		Remotes.Fx:FireAllClients("FuryArmor", g.hrp.Position)
		return
	end
	if g.ts and os.clock() < g.ts.untilT then return end -- frozen in time: no knockback
	if g.state == "Launched" then return end
	local flat = Vector3.new(dir.X, 0, dir.Z)
	flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
	-- a big hit knocks her out: she goes limp and flies (through walls)
	local ragVel = flat * math.clamp(knock * 0.75, 55, 115) + Vector3.new(0, 26 + knock * 0.1, 0)
	if g.state == "Ragdoll" then
		Ragdoll.kick(g, flat * math.clamp(knock * 0.7, 30, 100) + Vector3.new(0, 30, 0)) -- juggle her while she is down
		return
	end
	-- the Flayed Giant is never staggered: anything short of a knockout blow hurts him but doesn't move him or
	-- hold up his next swipe
	if (g.def :: any).noStagger and knock < Ragdoll.MIN_KNOCK then
		if os.clock() - (g.lastArmorFx or 0) > 0.5 then
			g.lastArmorFx = os.clock()
			Remotes.Fx:FireAllClients("FuryArmor", g.hrp.Position)
		end
		return
	end
	if knock >= Ragdoll.MIN_KNOCK then
		if g.loot then Abilities.dropLoot(g, Ghost) end -- the Goblin lets go of what he stole
		g.model:SetAttribute("Vanish", false)
		setState(g, "Ragdoll", 4.5)
		Ragdoll.start(g, ragVel)
		Remotes.Fx:FireAllClients("GhostRagdoll", g.hrp.Position)
		g.nextAttack = math.max(g.nextAttack, os.clock() + 2)
		return
	end
	g.vel = flat * knock + Vector3.new(0, math.min(knock * 0.15, 18), 0)
	setState(g, "Knocked", 0.12)
	-- a small hit only delays its next swipe a little; once beaten up enough (Fury pressure) not at all
	if Fury.pressure(g) < Config.Fury.ArmorPressure then g.nextAttack = math.max(g.nextAttack, os.clock() + 0.12) end
end

local function stepKnocked(g, dt: number, now: number)
	local pos = g.hrp.Position
	local floorY = floorBelow(pos, g.rp)
	local hoverY = floorY + g.hover
	-- a simple hit: it flies back for a split second, then brakes hard and is straight back on its feet
	g.vel *= math.exp(-(os.clock() - g.stateStart < 0.15 and 1.7 or 6) * dt)
	g.vel += Vector3.new(0, (hoverY - pos.Y) * 6 * dt - g.vel.Y * 2.5 * dt, 0)
	local step = g.vel * dt
	local speed = g.vel.Magnitude
	if step.Magnitude > 0.001 then
		local r = workspace:Raycast(pos, step.Unit * (step.Magnitude + 2.2), g.rp)
		if r and r.Normal.Y < 0.6 and speed > BREAK_SPEED and Ragdoll.breakWalls(r.Position, g.vel) > 0 then
			-- hit hard enough: straight through the (inside) wall
			Remotes.Fx:FireAllClients("WallSmash", r.Position, speed)
			Ghost.damage(speed * C.WallSlamFactor, nil)
			g.vel *= 0.8
		elseif r and r.Normal.Y < 0.6 then
			if speed > 24 then
				Ghost.damage(speed * C.WallSlamFactor, nil)
				Remotes.Fx:FireAllClients("WallSlam", r.Position, speed)
			end
			local n = r.Normal
			g.vel = (g.vel - 2 * g.vel:Dot(n) * n) * 0.22
		end
	end
	if speed > 14 then
		for _, f in Furniture.near(pos, 4.5) do
			local w = Furniture.weight(f)
			Furniture.smash(f, g.vel, speed)
			Ghost.damage(w * C.FurnitureHitDamagePerWeight, nil)
			g.vel *= 0.88
			if not Ghost.alive() then return end
		end
	end
	g.lv.VectorVelocity = g.vel
	if g.vel.Magnitude < 8 and now > g.stateUntil then setState(g, "Recover", 0.12) end
end

local function warded(p: Player?): boolean
	return p ~= nil and p:GetAttribute("Warded") == true
end

local function claw(g, target: Player?, thrp: BasePart?)
	if not target or not thrp or warded(target) or Fury.inGrace(target) then return end
	local to = thrp.Position - g.hrp.Position
	if to.Magnitude <= C.SwipeReach * ((g.def :: any).reach or 1) then
		-- enraged: a smash punch that launches you through the inside walls
		if Fury.smashes(g) and g.comboLeft == 0 and Ghost.hitPlayer then
			Fury.smashPunch(g, Ghost, target, thrp)
			return
		end
		local dmg = Fury.swipeDamage(g)
		if Ghost.damagePlayer then Ghost.damagePlayer(target, dmg) end
		local flat = Vector3.new(to.X, 0, to.Z)
		Remotes.Fx:FireClient(target, "Clawed", flat.Magnitude > 0.01 and flat.Unit or Vector3.zero)
	end
end

-- knocked out of the house (through a window or the front door, under the floor, into an outside wall):
-- teleported back in at the closest monster spawn point
-- The limit is the inner side of the loaded map's outside walls (they are ~2 studs thick): a body centre past
-- it is inside the wall or out of the house. Measured once per map from Structure.Exterior.
local bounds = { map = "", min = Config.House.Min, max = Config.House.Max }
local function houseBounds()
	local live = workspace:FindFirstChild("Mansion")
	local id = live and live:GetAttribute("MapId") or "Mansion"
	if bounds.map == id then return bounds end
	bounds.map = id
	bounds.min, bounds.max = Config.House.Min, Config.House.Max
	local ext = live and live:FindFirstChild("Structure") and live.Structure:FindFirstChild("Exterior")
	if ext then
		local mn, mx = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
		for _, d in ext:GetDescendants() do
			if d:IsA("BasePart") and d.CanCollide and d.Size.Y > 6 then
				local half = d.CFrame:VectorToWorldSpace(d.Size / 2)
				half = Vector3.new(math.abs(half.X), math.abs(half.Y), math.abs(half.Z))
				mn = mn:Min(d.Position - half); mx = mx:Max(d.Position + half)
			end
		end
		if mx.X > mn.X and mx.Z > mn.Z then
			local wall = 1.6
			bounds.min = Vector3.new(mn.X + wall, Config.House.Min.Y, mn.Z + wall)
			bounds.max = Vector3.new(mx.X - wall, mx.Y + 2, mx.Z - wall) -- above the outside walls = in the roof
		end
	end
	-- a map can set its own floor / ceiling limits (the ship: below the hold floor = in the sea)
	local minY, ceil = live and live:GetAttribute("MinY"), live and live:GetAttribute("CeilingY")
	if type(minY) == "number" then bounds.min = Vector3.new(bounds.min.X, minY + 10, bounds.min.Z) end
	if type(ceil) == "number" then bounds.max = Vector3.new(bounds.max.X, ceil, bounds.max.Z) end
	return bounds
end
Ghost.houseBounds = houseBounds
local function outside(p: Vector3): boolean
	local B = houseBounds()
	return p.X < B.min.X or p.X > B.max.X or p.Z < B.min.Z or p.Z > B.max.Z or p.Y < B.min.Y - 10 or p.Y > B.max.Y
end

local function bringBack(g)
	if g.state == "Ragdoll" then Ragdoll.stop(g) end
	g.launch = nil
	local from = g.hrp.Position
	local best, bestD = nil, math.huge
	for _, sp in MapLoader.ghostSpawns() do
		local d = (sp - from).Magnitude
		if d < bestD then best, bestD = sp, d end
	end
	local sp = best or MapLoader.spawnInside()
	local at = Vector3.new(sp.X, floorBelow(sp, g.rp) + g.hover, sp.Z)
	local look = Vector3.new(-sp.X, 0, -sp.Z) -- facing the middle of the house
	look = look.Magnitude > 0.1 and look.Unit or Vector3.new(0, 0, -1)
	g.model:PivotTo(CFrame.lookAt(at, at + look))
	g.ao.CFrame = CFrame.lookAt(Vector3.zero, look)
	g.vel = Vector3.zero
	g.lv.VectorVelocity = Vector3.zero
	g.hrp.AssemblyLinearVelocity = Vector3.zero
	g.hrp.AssemblyAngularVelocity = Vector3.zero
	g.path = nil
	Remotes.Fx:FireAllClients("GhostVanish", from)
	Remotes.Fx:FireAllClients("GhostVanish", at)
	setState(g, "Recover", 0.8)
end
Ghost.outside = outside

function Ghost.step(dt: number)
	local g = Ghost.current
	if not g or not g.model.Parent then return end
	local now = os.clock()
	local s = g.state
	if s == "Dead" then
		g.lv.VectorVelocity = Vector3.new(0, 3, 0)
		return
	end
	Abilities.tick(Ghost, dt, now)
	Fury.tick(g)
	-- Studio photo hook: ReplicatedStorage attribute DebugFreezeGhost = true holds the monster still
	if game:GetService("RunService"):IsStudio() and RS:GetAttribute("DebugFreezeGhost") then
		g.lv.VectorVelocity = Vector3.zero
		return
	end
	-- burning (damage over time) + its fire
	for i = #g.burns, 1, -1 do
		local b = g.burns[i]
		if now > b.untilT then table.remove(g.burns, i) else Ghost.damage(b.dps * dt, b.by) end
	end
	if not Ghost.alive() then return end
	if #g.burns > 0 and not g.fire then
		local torso = g.model:FindFirstChild("UpperTorso")
		if torso then g.fire = Fire.flames(torso, 1.3) end -- realistic flames on her body
	elseif #g.burns == 0 and g.fire then
		for _, e in g.fire do e:Destroy() end
		g.fire = nil
	end
	-- time stop ends: everything stored lands at once
	if g.ts and now >= g.ts.untilT then
		local stored = g.ts.stored * g.ts.mult
		g.ts = nil
		g.model:SetAttribute("TimeStop", false)
		Remotes.Fx:FireAllClients("TimeResume", g.hrp.Position, stored)
		Ghost.damage(stored, nil)
		if not Ghost.alive() then return end
	end
	do
		local body = (s == "Ragdoll" and g.model:FindFirstChild("UpperTorso") or g.hrp) :: BasePart
		if outside(body.Position) then bringBack(g); return end
	end
	local target, thrp = pickTarget(g)
	local watch = thrp -- (passive) the player she turns to
	if Ghost.passive then target, thrp = nil, nil end -- nobody to chase or hit
	g.target = target
	local pos = g.hrp.Position
	if s == "Ragdoll" then
		local done = Ragdoll.step(g, dt, function(at: Vector3, speed: number)
			Remotes.Fx:FireAllClients("WallSmash", at, speed)
			Ghost.damage(speed * C.WallSlamFactor * 0.5, nil)
		end)
		local torso = (g.model:FindFirstChild("UpperTorso") or g.hrp) :: BasePart
		local v = torso.AssemblyLinearVelocity
		if v.Magnitude > 14 then
			for _, f in Furniture.near(torso.Position, 4.5) do Furniture.smash(f, v, v.Magnitude) end
		end
		if done and Ghost.alive() then
			Ragdoll.stop(g)
			Fury.wake(g)
			setState(g, "Recover", 0.9)
		end
		return
	end
	if s == "Launched" then return stepLaunched(g, dt) end
	-- Fury: a long beating doesn't stunlock it: it roars or swipes back straight out of a stagger
	if (s == "Knocked" or s == "Recover") and now >= g.frozenUntil and not Ghost.passive then
		if Fury.roarCheck(g, Ghost, now, target) or Fury.counterCheck(g, Ghost, now, target, thrp) then return end
	end
	if s == "Knocked" then return stepKnocked(g, dt, now) end
	if now < g.frozenUntil then
		g.lv.VectorVelocity = Vector3.zero
		return
	elseif g.model:GetAttribute("Frozen") then
		g.model:SetAttribute("Frozen", false)
	end
	if g.pauseFrom then
		-- a paused special picks up where it stopped
		shiftTimers(g, now - g.pauseFrom)
		g.pauseFrom = nil
	end

	local floorY = floorBelow((thrp and not g.def.solid) and thrp.Position or pos, g.rp)
	local hoverY = floorY + g.hover + math.sin(now * 2.1) * g.bob
	local function face(tp: Vector3)
		local flat = Vector3.new(tp.X, pos.Y, tp.Z)
		if (flat - pos).Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(pos, flat).Rotation end
	end
	local function moveToward(tp: Vector3, speed: number)
		local to = Vector3.new(tp.X - pos.X, 0, tp.Z - pos.Z)
		local v = to.Magnitude > 0.5 and to.Unit * speed or Vector3.zero
		if g.def.solid then v = blockWalls(g, v) end
		-- wallBreaker (the Flayed Giant): too big for the doors, he smashes through the inside walls in his way
		if (g.def :: any).wallBreaker and v.Magnitude > 1 and now >= (g.nextWallBreak or 0) then
			local r = workspace:Raycast(pos + Vector3.new(0, 2, 0), v.Unit * 7, g.rp)
			if r and r.Normal.Y < 0.6 and Ragdoll.breakWalls(r.Position + Vector3.new(0, 2, 0), v.Unit * 70, 9, 9) > 0 then
				g.nextWallBreak = now + 0.35
				Remotes.Fx:FireAllClients("WallSmash", r.Position, 110)
			end
		end
		g.lv.VectorVelocity = v + Vector3.new(0, (hoverY - pos.Y) * 4, 0)
	end

	if s == "Spawn" then
		g.lv.VectorVelocity = Vector3.new(0, (hoverY - pos.Y) * 2, 0)
		if thrp then face(thrp.Position) end
		if now > g.stateUntil then setState(g, "Chase") end
	elseif s == "Recover" then
		g.lv.VectorVelocity = Vector3.new(0, (hoverY - pos.Y) * 4, 0)
		if now > g.stateUntil then setState(g, "Chase") end
	elseif s == "Chase" then
		if not thrp then
			if watch then face(watch.Position) end
			g.lv.VectorVelocity = Vector3.new(0, (hoverY - pos.Y) * 4, 0)
			return
		end
		face(thrp.Position)
		local dist = (Vector3.new(thrp.Position.X, 0, thrp.Position.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
		local speed = (C.Speed + (g.level - 1) * C.SpeedPerLevel) * g.speedMult * g.furySpeed * (now < g.slowUntil and g.slowMult or 1)
		-- the Caller, woken in his corner (Server/Caller): a few seconds of flat-out running, no stop-and-go
		local rushing = g.rushUntil ~= nil and now < g.rushUntil
		if rushing then speed *= 1.45 end
		-- creepy rhythm: she sometimes freezes for a moment, then lunges
		local phase = (now * 0.6) % 1
		if rushing then -- (no rhythm)
		elseif phase < 0.12 and dist > 14 then speed *= 0.1 elseif phase < 0.3 and dist > 14 then speed *= 1.8 end
		-- the Caller goes round to the back of a player who is facing him
		local goal = thrp.Position
		if (g.def :: any).flank then goal = Abilities.flankGoal(g, thrp, dist, now) end
		moveToward(g.def.solid and pathPoint(g, goal) or goal, speed)
		if Fury.roarCheck(g, Ghost, now, target) then return end
		if g.evolved and Evolved.chase(g, Ghost, now, target, thrp, dist) then return end
		if now >= g.slowUntil and Abilities.try(g, Ghost, now, target, thrp, dist) then return end
		if dist < C.AttackRange * ((g.def :: any).reach or 1) and now > g.nextAttack and not Fury.inGrace(target) then
			g.comboLeft = Fury.comboCount(g)
			setState(g, "WindUp", Fury.windUp(g, false))
			Remotes.Fx:FireAllClients("GhostWindUp", pos)
		elseif g.def.ability.kind == "scare" and now > g.nextScare and dist > 12 and not warded(target) then
			setState(g, "Vanish", 1.4)
			g.model:SetAttribute("Vanish", true)
			Remotes.Fx:FireAllClients("GhostVanish", pos)
		elseif Fury.lungeCheck(g, Ghost, now, target, thrp, dist) then
			return
		end
	elseif s == "WindUp" then
		if thrp then face(thrp.Position); moveToward(thrp.Position, 4) end
		if now > g.stateUntil then
			setState(g, "Swipe", 0.35)
			claw(g, target, thrp)
		end
	elseif s == "Swipe" then
		g.lv.VectorVelocity = Vector3.new(0, (hoverY - pos.Y) * 4, 0)
		if now > g.stateUntil then
			-- chain: a quicker follow-up swipe while you are still in reach
			local reach = C.AttackRange * ((g.def :: any).reach or 1) * 1.4
			if g.comboLeft > 0 and target and thrp and not Fury.inGrace(target)
				and (thrp.Position - pos).Magnitude < reach then
				g.comboLeft -= 1
				setState(g, "WindUp", Fury.windUp(g, true))
				Remotes.Fx:FireAllClients("GhostWindUp", pos)
			else
				g.comboLeft = 0
				g.nextAttack = now + C.AttackCooldown * g.cdMult
				setState(g, "Chase")
			end
		end
	elseif s == "Vanish" then
		if thrp then moveToward(thrp.Position, 22) end
		if now > g.stateUntil then
			if target and thrp then
				local look = Vector3.new(thrp.CFrame.LookVector.X, 0, thrp.CFrame.LookVector.Z)
				look = look.Magnitude > 0.01 and look.Unit or Vector3.new(0, 0, -1)
				local at = thrp.Position + look * 3.4
				at = Vector3.new(at.X, floorBelow(thrp.Position, g.rp) + g.hover - 0.4, at.Z)
				g.model:PivotTo(CFrame.lookAt(at, Vector3.new(thrp.Position.X, at.Y, thrp.Position.Z)))
				g.ao.CFrame = g.model:GetPivot().Rotation
				g.model:SetAttribute("Vanish", false)
				setState(g, "Scare", 1.0)
				Remotes.Fx:FireClient(target, "Jumpscare")
				Remotes.Fx:FireAllClients("GhostScream", at)
				if Ghost.damagePlayer then Ghost.damagePlayer(target, C.ScareDamage, C.ScareStaminaDrain) end
			else
				g.model:SetAttribute("Vanish", false)
				setState(g, "Chase")
			end
			g.nextScare = now + rng:NextNumber(C.ScareMin, C.ScareMax) * g.cdMult
		end
	elseif s == "Ability" then
		Abilities.step(g, Ghost, dt, now, target, thrp, hoverY)
	elseif s == "Evo" then
		Evolved.step(g, Ghost, dt, now, target, thrp, hoverY)
	elseif s == "Roar" then
		Fury.stepRoar(g, Ghost, now, thrp, hoverY)
	elseif s == "Lunge" then
		Fury.stepLunge(g, Ghost, dt, now, thrp, hoverY)
	elseif s == "Scare" then
		g.lv.VectorVelocity = Vector3.zero
		if now > g.stateUntil then
			g.nextAttack = now + 0.5
			setState(g, "Chase")
		end
	end
end

return Ghost
