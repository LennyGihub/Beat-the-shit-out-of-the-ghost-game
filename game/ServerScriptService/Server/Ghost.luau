-- The woman ghost: floats through walls toward the nearest player, claws, scares, gets knocked flying.
-- Knockback is scripted: it stops at walls (wall slam) and smashes furniture on the way.
local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)
local C = Config.Ghost

local Ghost = {}
Ghost.current = nil :: any
Ghost.onDeath = nil :: ((g: any) -> ())?
Ghost.damagePlayer = nil :: ((p: Player, n: number, staminaDrain: number?) -> ())?
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

local function setState(g, s: string, dur: number?)
	g.state = s
	g.stateStart = os.clock()
	g.stateUntil = os.clock() + (dur or 0)
	g.model:SetAttribute("State", s)
end

function Ghost.alive(): boolean
	return Ghost.current ~= nil and Ghost.current.state ~= "Dead"
end

function Ghost.spawn(level: number, pos: Vector3)
	Ghost.despawn()
	local m = (SS:WaitForChild("GhostTemplate") :: Model):Clone()
	m.Name = "Ghost"
	local hrp = m:WaitForChild("HumanoidRootPart") :: BasePart
	local att = Instance.new("Attachment"); att.Parent = hrp
	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = att; lv.MaxForce = math.huge; lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.VectorVelocity = Vector3.zero; lv.Parent = hrp
	local ao = Instance.new("AlignOrientation")
	ao.Attachment0 = att; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	ao.MaxTorque = math.huge; ao.Responsiveness = 30; ao.Parent = hrp
	m:PivotTo(CFrame.new(pos))
	local maxHp = C.BaseHP + (level - 1) * C.HPPerLevel
	m:SetAttribute("HP", maxHp)
	m:SetAttribute("MaxHP", maxHp)
	m:SetAttribute("Level", level)
	m.Parent = workspace
	pcall(function() hrp:SetNetworkOwner(nil) end)
	local g = {
		model = m, hrp = hrp, lv = lv, ao = ao, level = level, hp = maxHp, maxHp = maxHp,
		vel = Vector3.zero, state = "Spawn", stateStart = os.clock(), stateUntil = os.clock() + 2.2,
		nextAttack = os.clock() + 3, nextScare = os.clock() + rng:NextNumber(C.ScareMin, C.ScareMax),
		damageBy = {} :: { [Player]: number }, target = nil :: Player?, rp = structParams(),
		frozenUntil = 0, slowMult = 1, slowUntil = 0, burns = {}, ts = nil :: any, launch = nil :: any, fire = nil :: Fire?,
	}
	Ghost.current = g
	setState(g, "Spawn", 2.2)
	Remotes.Fx:FireAllClients("GhostSpawn", pos)
	return g
end

function Ghost.despawn()
	local g = Ghost.current
	if g and g.model then g.model:Destroy() end
	Ghost.current = nil
end

local function pickTarget(g): (Player?, BasePart?)
	local best, bestD, bestHrp = nil, math.huge, nil
	for _, p in Players:GetPlayers() do
		local ch = p.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hum and hum.Health > 0 and hrp and p:GetAttribute("InMatch") then
			local pos = hrp.Position
			local inside = pos.X > Config.House.Min.X and pos.X < Config.House.Max.X and pos.Z > Config.House.Min.Z and pos.Z < Config.House.Max.Z
			if inside then
				local d = (pos - g.hrp.Position).Magnitude
				if d < bestD then best, bestD, bestHrp = p, d, hrp end
			end
		end
	end
	return best, bestHrp
end

local function die(g)
	setState(g, "Dead")
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
	g.hp = math.max(0, g.hp - amount)
	g.model:SetAttribute("HP", g.hp)
	if g.hp <= 0 then die(g) end
end

-- ultimate effects -------------------------------------------------------
function Ghost.freeze(t: number)
	local g = Ghost.current
	if not g or g.state == "Dead" then return end
	g.frozenUntil = math.max(g.frozenUntil, os.clock() + t)
	if g.state == "WindUp" or g.state == "Swipe" or g.state == "Vanish" or g.state == "Scare" then
		g.model:SetAttribute("Vanish", false)
		setState(g, "Chase")
	end
	g.model:SetAttribute("Frozen", true)
end

function Ghost.timeStop(t: number, mult: number)
	local g = Ghost.current
	if not g or g.state == "Dead" then return end
	g.ts = { untilT = os.clock() + t, stored = 0, mult = mult }
	g.model:SetAttribute("TimeStop", true)
	Ghost.freeze(t)
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
	if not g or g.state == "Dead" or g.state == "Spawn" then return end
	g.model:SetAttribute("Vanish", false)
	g.launch = { phase = "up", topY = g.hrp.Position.Y + h, d = d, by = by }
	setState(g, "Launched")
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
		if pos.Y >= L.topY or r then
			if r then Remotes.Fx:FireAllClients("WallSlam", r.Position, 90) end
			L.phase = "down"
		end
		g.lv.VectorVelocity = Vector3.new(0, 75, 0)
	else
		g.lv.VectorVelocity = Vector3.new(0, -170, 0)
		local r = workspace:Raycast(pos, Vector3.new(0, -7, 0), g.rp)
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
function Ghost.hit(by: Player?, dir: Vector3, knock: number, damage: number)
	local g = Ghost.current
	if not g or g.state == "Dead" or g.state == "Spawn" then return end
	if g.model:GetAttribute("Vanish") then g.model:SetAttribute("Vanish", false) end
	Ghost.damage(damage, by)
	if g.state == "Dead" then return end
	if g.ts and os.clock() < g.ts.untilT then return end -- frozen in time: no knockback
	if g.state == "Launched" then return end
	local flat = Vector3.new(dir.X, 0, dir.Z)
	flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
	g.vel = flat * knock + Vector3.new(0, math.min(knock * 0.15, 18), 0)
	setState(g, "Knocked", 0.18)
	g.nextAttack = math.max(g.nextAttack, os.clock() + 0.9)
end

local function stepKnocked(g, dt: number, now: number)
	local pos = g.hrp.Position
	local floorY = floorBelow(pos, g.rp)
	local hoverY = floorY + C.HoverHeight
	g.vel *= math.exp(-1.7 * dt)
	g.vel += Vector3.new(0, (hoverY - pos.Y) * 6 * dt - g.vel.Y * 2.5 * dt, 0)
	local step = g.vel * dt
	local speed = g.vel.Magnitude
	if step.Magnitude > 0.001 then
		local r = workspace:Raycast(pos, step.Unit * (step.Magnitude + 2.2), g.rp)
		if r and r.Normal.Y < 0.6 then
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
	if g.vel.Magnitude < 6 and now > g.stateUntil then setState(g, "Recover", 0.5) end
end

local function claw(g, target: Player?, thrp: BasePart?)
	if not target or not thrp then return end
	local to = thrp.Position - g.hrp.Position
	if to.Magnitude <= C.SwipeReach then
		local dmg = C.SwipeDamage + (g.level - 1) * C.SwipeDamagePerLevel
		if Ghost.damagePlayer then Ghost.damagePlayer(target, dmg) end
		local flat = Vector3.new(to.X, 0, to.Z)
		Remotes.Fx:FireClient(target, "Clawed", flat.Magnitude > 0.01 and flat.Unit or Vector3.zero)
	end
end

function Ghost.step(dt: number)
	local g = Ghost.current
	if not g or not g.model.Parent then return end
	local now = os.clock()
	local s = g.state
	if s == "Dead" then
		g.lv.VectorVelocity = Vector3.new(0, 3, 0)
		return
	end
	-- burning (damage over time) + its fire
	for i = #g.burns, 1, -1 do
		local b = g.burns[i]
		if now > b.untilT then table.remove(g.burns, i) else Ghost.damage(b.dps * dt, b.by) end
	end
	if not Ghost.alive() then return end
	if #g.burns > 0 and not g.fire then
		local f = Instance.new("Fire"); f.Size = 7; f.Heat = 12
		f.Color = g.burns[#g.burns].color; f.SecondaryColor = Color3.new(1, 1, 0.6)
		f.Parent = g.model:FindFirstChild("UpperTorso"); g.fire = f
	elseif #g.burns == 0 and g.fire then
		g.fire:Destroy(); g.fire = nil
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
	local target, thrp = pickTarget(g)
	g.target = target
	local pos = g.hrp.Position
	if s == "Launched" then return stepLaunched(g, dt) end
	if s == "Knocked" then return stepKnocked(g, dt, now) end
	if now < g.frozenUntil then
		g.lv.VectorVelocity = Vector3.zero
		return
	elseif g.model:GetAttribute("Frozen") then
		g.model:SetAttribute("Frozen", false)
	end

	local floorY = floorBelow(thrp and thrp.Position or pos, g.rp)
	local hoverY = floorY + C.HoverHeight + math.sin(now * 2.1) * 0.35
	local function face(tp: Vector3)
		local flat = Vector3.new(tp.X, pos.Y, tp.Z)
		if (flat - pos).Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(pos, flat).Rotation end
	end
	local function moveToward(tp: Vector3, speed: number)
		local to = Vector3.new(tp.X - pos.X, 0, tp.Z - pos.Z)
		local v = to.Magnitude > 0.5 and to.Unit * speed or Vector3.zero
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
			g.lv.VectorVelocity = Vector3.new(0, (hoverY - pos.Y) * 4, 0)
			return
		end
		face(thrp.Position)
		local dist = (Vector3.new(thrp.Position.X, 0, thrp.Position.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude
		local speed = (C.Speed + (g.level - 1) * C.SpeedPerLevel) * (now < g.slowUntil and g.slowMult or 1)
		-- creepy rhythm: she sometimes freezes for a moment, then lunges
		local phase = (now * 0.6) % 1
		if phase < 0.12 and dist > 14 then speed *= 0.1 elseif phase < 0.3 and dist > 14 then speed *= 1.8 end
		moveToward(thrp.Position, speed)
		if dist < C.AttackRange and now > g.nextAttack then
			setState(g, "WindUp", C.WindUp)
			Remotes.Fx:FireAllClients("GhostWindUp", pos)
		elseif now > g.nextScare and dist > 12 then
			setState(g, "Vanish", 1.4)
			g.model:SetAttribute("Vanish", true)
			Remotes.Fx:FireAllClients("GhostVanish", pos)
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
			g.nextAttack = now + C.AttackCooldown
			setState(g, "Chase")
		end
	elseif s == "Vanish" then
		if thrp then moveToward(thrp.Position, 22) end
		if now > g.stateUntil then
			if target and thrp then
				local look = Vector3.new(thrp.CFrame.LookVector.X, 0, thrp.CFrame.LookVector.Z)
				look = look.Magnitude > 0.01 and look.Unit or Vector3.new(0, 0, -1)
				local at = thrp.Position + look * 3.4
				at = Vector3.new(at.X, floorBelow(thrp.Position, g.rp) + C.HoverHeight - 0.4, at.Z)
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
			g.nextScare = now + rng:NextNumber(C.ScareMin, C.ScareMax)
		end
	elseif s == "Scare" then
		g.lv.VectorVelocity = Vector3.zero
		if now > g.stateUntil then
			g.nextAttack = now + 0.5
			setState(g, "Chase")
		end
	end
end

return Ghost
