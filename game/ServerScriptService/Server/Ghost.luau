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
		if hum and hum.Health > 0 and hrp then
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
	g.hp = math.max(0, g.hp - amount)
	g.model:SetAttribute("HP", g.hp)
	if by then g.damageBy[by] = (g.damageBy[by] or 0) + amount end
	if g.hp <= 0 then die(g) end
end

-- Called by combat for punches, throws and the ultimate shockwave.
function Ghost.hit(by: Player?, dir: Vector3, knock: number, damage: number)
	local g = Ghost.current
	if not g or g.state == "Dead" or g.state == "Spawn" then return end
	if g.model:GetAttribute("Vanish") then g.model:SetAttribute("Vanish", false) end
	Ghost.damage(damage, by)
	if g.state == "Dead" then return end
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
	local target, thrp = pickTarget(g)
	g.target = target
	local pos = g.hrp.Position
	if s == "Knocked" then return stepKnocked(g, dt, now) end

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
		local speed = C.Speed + (g.level - 1) * C.SpeedPerLevel
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
