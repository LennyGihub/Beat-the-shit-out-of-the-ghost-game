-- Monster special abilities (see Shared/Monsters). Ghost.luau calls:
--   Abilities.try(g, G, now, target, thrp, dist)  in Chase: maybe start the ability (returns true if it did)
--   Abilities.step(g, G, dt, now, target, thrp, hoverY)  while g.state == "Ability"
--   Abilities.tick(G, dt, now)  every frame (gas clouds, hellfire marks, mirror clones)
--   Abilities.clear()  when the monster despawns / dies
-- G is the Ghost module (damagePlayer / hitPlayer / rootPlayer are injected into it by Combat).
local Players = game:GetService("Players")
local Remotes = require(script.Parent.Remotes)
local Sounds = require(game:GetService("ReplicatedStorage").Shared.Sounds)
local Furniture = require(script.Parent.Furniture)
local Loot = require(script.Parent.GoblinLoot) -- the Goblin's "steal"

local Abilities = {}
local rng = Random.new()
local clouds = {} :: { { pos: Vector3, r: number, dps: number, untilT: number, nextTick: number } }
local marks = {} :: { { at: number, pts: { Vector3 }, r: number, dmg: number } }
local clones = {} :: { { model: Model, untilT: number, speed: number, dmg: number, hover: number } }
-- players the Pirate's shield bash sent flying: hitting a wall hurts (once)
local flyers = {} :: { [Player]: { untilT: number, dmg: number } }

local function hrpOf(p: Player): BasePart?
	local ch = p.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	return ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function matchPlayers(): { Player }
	local out = {}
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("InMatch") and hrpOf(p) then table.insert(out, p) end
	end
	return out
end

local function fx(kind: string, ...)
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("InMatch") then Remotes.Fx:FireClient(p, kind, ...) end
	end
end

local function flat(v: Vector3): Vector3
	local f = Vector3.new(v.X, 0, v.Z)
	return f.Magnitude > 0.01 and f.Unit or Vector3.new(0, 0, -1)
end

local function warded(p: Player?): boolean return p ~= nil and p:GetAttribute("Warded") == true end

local function setPhase(g, phase: string, dur: number)
	g.ab.phase = phase
	g.ab.untilT = os.clock() + dur
	g.model:SetAttribute("AbilityPhase", phase)
end

local function start(g, G, phase: string, dur: number, extra: { [string]: any }?)
	g.ab = extra or {}
	g.ab.kind = g.def.ability.kind
	G.setState(g, "Ability")
	g.model:SetAttribute("Ability", g.ab.kind)
	setPhase(g, phase, dur)
end

local function finish(g, G, recover: number?)
	g.ab = nil
	g.model:SetAttribute("Ability", "")
	g.model:SetAttribute("AbilityPhase", "")
	g.nextAbility = os.clock() + g.def.ability.cd * rng:NextNumber(0.85, 1.2)
	g.nextAttack = math.max(g.nextAttack, os.clock() + 0.8)
	G.setState(g, "Recover", recover or 0.5)
end

-- an ability was cut short (the monster got knocked back): drop a held player
function Abilities.interrupt(g)
	if not g.ab then return end
	if g.ab.kind == "grabThrow" and g.ab.victim and g.ab.phase == "hold" then
		Remotes.Fx:FireClient(g.ab.victim, "Released")
	end
	if g.ab.kind == "blackout" then fx("BlackoutEnd"); g.model:SetAttribute("Shadow", false) end
	if g.ab.kind == "steal" then Remotes.Fx:FireAllClients("GoblinUse", g.model, "", "stop", 0) end
	if g.ab.kind == "levitateThrow" and g.ab.obj then Abilities.dropLevitated(g.ab) end
	g.ab = nil
	g.model:SetAttribute("Ability", "")
	g.model:SetAttribute("AbilityPhase", "")
	g.nextAbility = os.clock() + g.def.ability.cd * 0.6
end

-- let go of a levitated object (thrown, or the spell was interrupted): it falls normally again
function Abilities.dropLevitated(ab)
	local obj = ab.obj :: Model?
	if not obj or not obj.Parent then return end
	local hl = obj:FindFirstChild("DemonGrip") if hl then hl:Destroy() end
	local prim = obj.PrimaryPart
	if prim then
		local au = prim:FindFirstChild("DemonAura") if au then au:Destroy() end
		prim.Anchored = false
	end
	obj:SetAttribute("CarriedBy", nil)
	for _, p in obj:GetDescendants() do
		if p:IsA("BasePart") then p.CanCollide = true; p.CanTouch = true; p.CollisionGroup = "Default" end
	end
end

-- melee damage scale of this monster (level, monster and difficulty)
local function dmgScale(g): number return (g.dmgMult or 1) * (1 + (g.level - 1) * 0.08) end

-- maybe start the ability. Called every frame in Chase.
function Abilities.try(g, G, now: number, target: Player?, thrp: BasePart?, dist: number): boolean
	local a = g.def.ability
	if a.kind == "scare" or not target or not thrp then return false end
	if now < (g.nextAbility or 0) then return false end
	local k = a.kind
	if k == "steal" then
		return Loot.try(g, G, now, a, target, thrp, dist)
	elseif k == "shieldBash" then
		if dist < a.min or dist > a.max or warded(target) then return false end
		start(g, G, "brace", a.brace, {})
		fx("AbilityWind", g.hrp.Position, k)
	elseif k == "grabThrow" then
		if dist > a.range or warded(target) then return false end
		start(g, G, "wind", 0.55, { victim = target })
		fx("AbilityWind", g.hrp.Position, k)
	elseif k == "pounce" then
		if dist < a.min or dist > a.max then return false end
		start(g, G, "crouch", 0.55, { aim = thrp.Position })
		fx("AbilityWind", g.hrp.Position, k)
	elseif k == "levitateThrow" then
		if dist > (a.range or 70) then return false end
		local list = Furniture.nearest(g.hrp.Position, 40, 1)
		if #list == 0 then g.nextAbility = now + 2; return false end
		local obj = list[1]
		local prim = obj.PrimaryPart :: BasePart
		-- he takes it with his mind: nobody can grab it, it passes through everything while it floats
		obj:SetAttribute("CarriedBy", -1)
		for _, p in obj:GetDescendants() do
			if p:IsA("BasePart") then p.CanCollide = false; p.CanTouch = false; p.CollisionGroup = "Carried" end
		end
		prim.Anchored = true
		local hl = Instance.new("Highlight")
		hl.Name = "DemonGrip"; hl.FillColor = Color3.fromRGB(255, 40, 20); hl.FillTransparency = 0.6
		hl.OutlineColor = Color3.fromRGB(255, 90, 40); hl.Parent = obj
		local aura = Instance.new("ParticleEmitter")
		aura.Name = "DemonAura"; aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		aura.Color = ColorSequence.new(Color3.fromRGB(255, 60, 30)); aura.LightEmission = 1; aura.Rate = 30
		aura.Size = NumberSequence.new(0.5, 0); aura.Lifetime = NumberRange.new(0.5, 1); aura.Speed = NumberRange.new(1, 3)
		aura.SpreadAngle = Vector2.new(180, 180); aura.Parent = prim
		local function snd(name: string, parent: Instance, vol: number?)
			local s = Instance.new("Sound"); s.SoundId = "rbxassetid://" .. Sounds[name].ids[1]; s.Volume = vol or Sounds[name].volume
			s.RollOffMinDistance = 10; s.RollOffMaxDistance = 140; s.Parent = parent; s:Play()
			game:GetService("Debris"):AddItem(s, 6)
		end
		snd("Telekinesis", prim)
		snd("DemonLaugh", g.model:FindFirstChild("Head") or g.hrp)
		start(g, G, "lift", a.lift or 1.3, { obj = obj, from = obj:GetPivot(), t0 = now, spin = rng:NextNumber(-2, 2), snd = snd })
	elseif k == "furnitureStorm" then
		if dist > 70 then return false end
		local list = Furniture.nearest(g.hrp.Position, 45, a.count)
		if #list == 0 then g.nextAbility = now + 2; return false end
		start(g, G, "cast", 1.1, {})
		fx("AbilityWind", g.hrp.Position, k)
		for i, m in list do
			task.delay(0.25 + i * 0.22, function()
				local hrp = hrpOf(target)
				if hrp and m.Parent then
					Furniture.flingAt(m, hrp.Position + Vector3.new(0, 1, 0), nil, a.power)
					local info = Furniture.thrown[m]
					if info then info.monster = (a.dmg or 12) * dmgScale(g) end
				end
			end)
		end
	elseif k == "wail" then
		if dist > a.radius * 0.8 then return false end
		start(g, G, "wind", 0.9, {})
		fx("AbilityWind", g.hrp.Position, k)
	elseif k == "blackout" then
		if dist < 8 then return false end
		start(g, G, "dark", a.t, {})
		g.model:SetAttribute("Shadow", true)
		fx("Blackout", a.t, a.lightsOut == true)
	elseif k == "gas" then
		if dist > 55 or #clouds >= (a.max or 3) then return false end
		start(g, G, "throw", 0.75, {})
		local from, to = g.hrp.Position + Vector3.new(0, 2, 0), thrp.Position - Vector3.new(0, 2.5, 0)
		fx("GasThrow", from, to, 0.6)
		task.delay(0.6, function()
			table.insert(clouds, { pos = to, r = a.radius, dps = a.dps * dmgScale(g), untilT = os.clock() + a.t, nextTick = 0 })
			fx("GasCloud", to, a.radius, a.t)
		end)
	elseif k == "hellfire" then
		if dist > 80 then return false end
		local pts = {}
		for _, p in matchPlayers() do
			local hrp = hrpOf(p)
			if hrp and (hrp.Position - g.hrp.Position).Magnitude < 90 then table.insert(pts, hrp.Position - Vector3.new(0, 2.8, 0)) end
		end
		for _ = 1, 2 do
			local o = thrp.Position + Vector3.new(rng:NextNumber(-14, 14), -2.8, rng:NextNumber(-14, 14))
			table.insert(pts, o)
		end
		start(g, G, "cast", a.delay + 0.4, {})
		table.insert(marks, { at = now + a.delay, pts = pts, r = a.radius, dmg = a.dmg * dmgScale(g) })
		fx("HellMark", pts, a.radius, a.delay)
	elseif k == "charge" then
		if dist < a.min or dist > a.max then return false end
		start(g, G, "wind", a.wind, { dir = flat(thrp.Position - g.hrp.Position), hit = {} })
		fx("AbilityWind", g.hrp.Position, k)
	elseif k == "clones" then
		if #clones > 0 then return false end
		start(g, G, "cast", 0.9, {})
		fx("AbilityWind", g.hrp.Position, k)
		task.delay(0.5, function()
			if not g.model.Parent or g.state == "Dead" then return end
			for i = 1, a.n do
				local ang = (i / a.n) * math.pi * 2 + rng:NextNumber(-0.3, 0.3)
				local at = g.hrp.Position + Vector3.new(math.cos(ang) * 9, 0, math.sin(ang) * 9)
				local c = g.model:Clone()
				c.Name = "GhostClone"
				for _, d in c:GetDescendants() do
					if d:IsA("Constraint") or d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Humanoid") then d:Destroy()
					elseif d:IsA("BasePart") then d.Anchored = true; d.CanQuery = false; d.CanTouch = false; d.CanCollide = false end
				end
				c:SetAttribute("Clone", true)
				c:SetAttribute("HP", nil); c:SetAttribute("MaxHP", nil)
				c:PivotTo(CFrame.new(at) * g.model:GetPivot().Rotation)
				c.Parent = workspace
				table.insert(clones, { model = c, untilT = os.clock() + a.t, speed = 14 * (g.speedMult or 1), dmg = a.dmg * dmgScale(g), hover = g.hover })
				fx("CloneSpawn", at)
			end
		end)
	else
		return false
	end
	return true
end

local function hover(g, hoverY: number, v: Vector3): Vector3
	return Vector3.new(v.X, (hoverY - g.hrp.Position.Y) * 4, v.Z)
end

-- runs while g.state == "Ability"
function Abilities.step(g, G, dt: number, now: number, target: Player?, thrp: BasePart?, hoverY: number)
	local ab = g.ab
	if not ab then G.setState(g, "Chase"); return end
	local a = g.def.ability
	local pos = g.hrp.Position
	local k = ab.kind
	if k == "steal" then return Loot.step(g, G, dt, now, target, thrp, hoverY) end
	local function face(p: Vector3)
		local f = Vector3.new(p.X, pos.Y, p.Z)
		if (f - pos).Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(pos, f).Rotation end
	end
	if k == "grabThrow" then
		local vh = ab.victim and hrpOf(ab.victim)
		if ab.phase == "wind" then
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
			if vh then face(vh.Position) end
			if now >= ab.untilT then
				if vh and (vh.Position - pos).Magnitude <= a.range + 2.5 and not warded(ab.victim) then
					setPhase(g, "hold", 0.9)
					local hand = g.model:FindFirstChild("RightHand") or g.model:FindFirstChild("RightLowerArm") or g.hrp
					Remotes.Fx:FireClient(ab.victim, "Grabbed", hand, 0.9)
					fx("AbilityHit", vh.Position, k)
				else
					finish(g, G, 0.6) -- missed
				end
			end
		elseif ab.phase == "hold" then
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then
				if vh and ab.victim.Parent then
					local look = g.hrp.CFrame.LookVector
					local side = g.hrp.CFrame.RightVector * (rng:NextNumber() < 0.5 and -1 or 1)
					local dir = flat(look * 0.4 + side)
					G.hitPlayer(ab.victim, nil, a.dmg * dmgScale(g), dir * a.power + Vector3.new(0, 42, 0), "grab", true)
				end
				finish(g, G, 0.7)
			end
		end
	elseif k == "pounce" then
		if ab.phase == "crouch" then
			g.lv.VectorVelocity = hover(g, hoverY - 1, Vector3.zero)
			face(ab.aim)
			if now >= ab.untilT then
				local aim = thrp and thrp.Position or ab.aim
				local d = Vector3.new(aim.X - pos.X, 0, aim.Z - pos.Z)
				local T = math.clamp(d.Magnitude / 48, 0.45, 1.0)
				ab.vel = d / T + Vector3.new(0, 60 * T, 0) -- gravity 120 below
				ab.landT = now + T
				ab.aim = aim
				setPhase(g, "leap", T + 0.2)
				fx("Pounce", pos)
			end
		elseif ab.phase == "leap" then
			ab.vel += Vector3.new(0, -120 * dt, 0)
			g.lv.VectorVelocity = ab.vel
			if now >= ab.landT then
				local land = g.hrp.Position
				fx("WallSlam", land - Vector3.new(0, 2, 0), 70)
				for _, p in matchPlayers() do
					local hrp = hrpOf(p)
					if hrp and (hrp.Position - land).Magnitude < 7 and not warded(p) then
						G.hitPlayer(p, nil, a.dmg * dmgScale(g), flat(hrp.Position - land) * 20 + Vector3.new(0, 8, 0), "pounce", true)
						G.rootPlayer(p, a.pin)
					end
				end
				finish(g, G, 0.7)
			end
		end
	elseif k == "levitateThrow" then
		-- lift (rise to over his raised hand) -> aim (it hovers and shakes) -> throw
		g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
		if thrp then face(thrp.Position) end
		local ab = g.ab
		local obj = ab.obj :: Model
		if ab.phase ~= "throw" and (not obj or not obj.Parent or obj:GetAttribute("Broken")) then finish(g, G, 0.3); return end
		local hold = g.hrp.CFrame * CFrame.new(1.5, 7.5, -3.5)
		-- Studio photo hook: ReplicatedStorage attribute DebugHoldCast keeps him aiming with the object up
		if ab.phase == "aim" and game:GetService("RunService"):IsStudio() and game.ReplicatedStorage:GetAttribute("DebugHoldCast") then ab.untilT = now + 0.5 end
		if ab.phase == "lift" or ab.phase == "aim" then
			local f = ab.phase == "lift" and math.clamp((now - ab.t0) / a.lift, 0, 1) or 1
			local e = f * f * (3 - 2 * f)
			local pos = ab.from.Position:Lerp(hold.Position, e) + Vector3.new(0, math.sin(now * 5) * 0.35, 0)
			local shake = ab.phase == "aim" and Vector3.new(rng:NextNumber(-0.2, 0.2), rng:NextNumber(-0.2, 0.2), rng:NextNumber(-0.2, 0.2)) or Vector3.zero
			obj:PivotTo(CFrame.new(pos + shake) * ab.from.Rotation * CFrame.Angles(0, (now - ab.t0) * ab.spin, math.sin(now * 2) * 0.25))
			if ab.phase == "lift" and now >= ab.untilT then setPhase(g, "aim", a.aim or 0.45)
			elseif ab.phase == "aim" and now >= ab.untilT then
				setPhase(g, "throw", 0.5)
				ab.snd("DemonRoar", g.model:FindFirstChild("Head") or g.hrp)
				Abilities.dropLevitated(ab)
				local hrp = hrpOf(target)
				if hrp then
					Furniture.flingAt(obj, hrp.Position + Vector3.new(0, 1, 0), nil, a.power or 150)
					local info = Furniture.thrown[obj]
					if info then info.monster = (a.dmg or 20) * dmgScale(g) end
				end
				ab.obj = nil
			end
		elseif ab.phase == "throw" and now >= ab.untilT then
			finish(g, G, 0.4)
		end
	elseif k == "shieldBash" then
		-- brace (shield up, shuffling toward you) -> rush in a straight line -> recover
		if ab.phase == "brace" then
			if thrp then face(thrp.Position) end
			local to = thrp and flat(thrp.Position - pos) or flat(g.hrp.CFrame.LookVector)
			g.lv.VectorVelocity = hover(g, hoverY, to * 3)
			if now >= ab.untilT then
				local d = thrp and Vector3.new(thrp.Position.X - pos.X, 0, thrp.Position.Z - pos.Z).Magnitude or 20
				ab.dir = to
				ab.hit = {}
				setPhase(g, "rush", math.clamp(d / a.speed + 0.25, 0.3, 0.95))
				fx("Charge", pos, ab.dir)
			end
		elseif ab.phase == "rush" then
			g.ao.CFrame = CFrame.lookAt(Vector3.zero, ab.dir)
			local v = ab.dir * a.speed * (g.speedMult or 1)
			-- a wall in front: he bonks into it and stops
			local wall = workspace:Raycast(pos, ab.dir * 3.2, g.rp)
			if wall and wall.Normal.Y < 0.6 then
				fx("WallSlam", wall.Position, 70)
				setPhase(g, "recover", 0.7)
				return
			end
			g.lv.VectorVelocity = hover(g, hoverY, v)
			for _, p in matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and not ab.hit[p] and (hrp.Position - pos).Magnitude < 7 and not warded(p) then
					ab.hit[p] = true
					local side = flat(hrp.Position - pos)
					local dir = (ab.dir * 0.85 + side * 0.35).Unit
					G.hitPlayer(p, nil, a.dmg * dmgScale(g), dir * a.power + Vector3.new(0, 18, 0), "pirate", true, 1.6)
					flyers[p] = { untilT = now + 1.4, dmg = (a.wallDmg or 15) * dmgScale(g) }
					fx("AbilityHit", hrp.Position, k)
				end
			end
			for _, m in Furniture.near(pos, 5) do Furniture.smash(m, ab.dir * a.speed + Vector3.new(0, 25, 0), 90) end
			if now >= ab.untilT then setPhase(g, "recover", 0.5) end
		elseif ab.phase == "recover" then
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then finish(g, G, 0.3) end
		end
	elseif k == "furnitureStorm" or k == "hellfire" or k == "clones" or k == "gas" then
		g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
		if thrp then face(thrp.Position) end
		if now >= ab.untilT then finish(g, G, 0.3) end
	elseif k == "wail" then
		g.lv.VectorVelocity = hover(g, hoverY + 1, Vector3.zero)
		if thrp then face(thrp.Position) end
		if ab.phase == "wind" and now >= ab.untilT then
			fx("Wail", pos, a.radius)
			for _, p in matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and (hrp.Position - pos).Magnitude <= a.radius and not warded(p) then
					local f = 1 - (hrp.Position - pos).Magnitude / (a.radius + 4)
					G.hitPlayer(p, nil, a.dmg * dmgScale(g) * (0.5 + f * 0.5), flat(hrp.Position - pos) * a.push * (0.6 + f * 0.6) + Vector3.new(0, 24, 0), "wail", true)
					G.damagePlayer(p, 0, a.drain)
				end
			end
			for _, m in Furniture.near(pos, a.radius * 0.6) do
				local c = m:GetBoundingBox().Position
				Furniture.smash(m, flat(c - pos) * 60 + Vector3.new(0, 20, 0), 60)
			end
			setPhase(g, "after", 0.5)
		elseif ab.phase == "after" and now >= ab.untilT then
			finish(g, G, 0.3)
		end
	elseif k == "blackout" then
		-- in the dark she rushes the target; reaching them = a heavy strike from behind
		if thrp and target then
			local to = Vector3.new(thrp.Position.X - pos.X, 0, thrp.Position.Z - pos.Z)
			local sp = (a.speed or 22) * (g.speedMult or 1)
			-- solid monsters (the Animatronic) walk around the walls; the Woman glides through them
			local goal = (g.def.solid and G.pathPoint) and G.pathPoint(g, thrp.Position) or thrp.Position
			local step = Vector3.new(goal.X - pos.X, 0, goal.Z - pos.Z)
			local v = step.Magnitude > 0.5 and step.Unit * sp or Vector3.zero
			if g.def.solid and G.blockWalls then v = G.blockWalls(g, v) end
			face(pos + (v.Magnitude > 0.5 and v or to))
			g.lv.VectorVelocity = hover(g, hoverY, v)
			if to.Magnitude < 5.5 and not warded(target) then
				if a.lightsOut then
					-- the Party Bear: it's suddenly right in your face (jumpscare on the victim's screen), then the hit
					Remotes.Fx:FireClient(target, "AnimJumpscare", g.model)
					G.hitPlayer(target, nil, a.dmg * dmgScale(g), (to.Magnitude > 0.1 and to.Unit or thrp.CFrame.LookVector) * 60 + Vector3.new(0, 22, 0), "stalker", true)
				else
					local back = thrp.Position - thrp.CFrame.LookVector * 3
					g.model:PivotTo(CFrame.lookAt(Vector3.new(back.X, pos.Y, back.Z), Vector3.new(thrp.Position.X, pos.Y, thrp.Position.Z)))
					G.hitPlayer(target, nil, a.dmg * dmgScale(g), thrp.CFrame.LookVector * 55 + Vector3.new(0, 25, 0), "stalker", true)
				end
				fx("AbilityHit", thrp.Position, k)
				fx("BlackoutEnd")
				g.model:SetAttribute("Shadow", false)
				finish(g, G, 0.8)
				return
			end
		else
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
		end
		if now >= ab.untilT then
			fx("BlackoutEnd")
			g.model:SetAttribute("Shadow", false)
			finish(g, G, 0.4)
		end
	elseif k == "charge" then
		if ab.phase == "wind" then
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
			if thrp then ab.dir = flat(thrp.Position - pos); face(thrp.Position) end
			if now >= ab.untilT then
				setPhase(g, "run", 1.4)
				ab.start = pos
				fx("Charge", pos, ab.dir)
			end
		elseif ab.phase == "run" then
			g.ao.CFrame = CFrame.lookAt(Vector3.zero, ab.dir)
			g.lv.VectorVelocity = hover(g, hoverY, ab.dir * a.speed * (g.speedMult or 1))
			for _, p in matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and not ab.hit[p] and (hrp.Position - pos).Magnitude < 6 and not warded(p) then
					ab.hit[p] = true
					local side = flat(hrp.Position - pos)
					G.hitPlayer(p, nil, a.dmg * dmgScale(g), (ab.dir * 0.7 + side * 0.5).Unit * 90 + Vector3.new(0, 35, 0), "charge", true)
				end
			end
			for _, m in Furniture.near(pos, 5) do Furniture.smash(m, ab.dir * a.speed + Vector3.new(0, 25, 0), 100) end
			if now >= ab.untilT or (pos - ab.start).Magnitude > a.max + 10 then
				fx("WallSlam", pos, 60)
				finish(g, G, 0.9)
			end
		end
	else
		finish(g, G, 0.2)
	end
end

local function shatter(c)
	fx("CloneShatter", c.model:GetPivot().Position)
	c.model:Destroy()
end

-- lingering things: gas clouds, hellfire marks, mirror clones
function Abilities.tick(G, dt: number, now: number)
	Loot.tick(G, dt, now)
	-- shield-bashed players flying across the room: the first wall they hit hurts
	for p, f in flyers do
		local hrp = hrpOf(p)
		local g = G.current
		if not hrp or not g or now > f.untilT then
			flyers[p] = nil
		else
			local v = hrp.AssemblyLinearVelocity
			local hv = Vector3.new(v.X, 0, v.Z)
			if hv.Magnitude > 30 then
				-- walls and furniture both count (a crate in the way breaks)
				local rp = RaycastParams.new()
				rp.FilterType = Enum.RaycastFilterType.Include
				local list = table.clone(g.rp.FilterDescendantsInstances)
				local fur = Furniture.folder()
				if fur then table.insert(list, fur) end
				rp.FilterDescendantsInstances = list
				local r = workspace:Raycast(hrp.Position, hv.Unit * (hv.Magnitude * dt * 2.5 + 2.4), rp)
				if r and r.Normal.Y < 0.6 then
					flyers[p] = nil
					if fur and r.Instance:IsDescendantOf(fur) then
						local m = r.Instance
						while m and m.Parent ~= fur do m = m.Parent end
						if m and m:IsA("Model") then Furniture.smash(m, hv + Vector3.new(0, 20, 0), hv.Magnitude) end
					end
					G.damagePlayer(p, f.dmg)
					fx("WallSlam", r.Position, hv.Magnitude)
					Remotes.Fx:FireClient(p, "Slammed", hv.Magnitude)
				end
			end
		end
	end
	for i = #clouds, 1, -1 do
		local c = clouds[i]
		if now > c.untilT then
			table.remove(clouds, i)
		elseif now >= c.nextTick then
			c.nextTick = now + 0.5
			for _, p in matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and Vector3.new(hrp.Position.X - c.pos.X, 0, hrp.Position.Z - c.pos.Z).Magnitude <= c.r and math.abs(hrp.Position.Y - c.pos.Y) < 10 and not warded(p) then
					G.damagePlayer(p, c.dps * 0.5, 4)
					Remotes.Fx:FireClient(p, "Gassed")
				end
			end
		end
	end
	for i = #marks, 1, -1 do
		local mk = marks[i]
		if now >= mk.at then
			table.remove(marks, i)
			fx("HellPillar", mk.pts, mk.r)
			for _, pt in mk.pts do
				for _, p in matchPlayers() do
					local hrp = hrpOf(p)
					if hrp and Vector3.new(hrp.Position.X - pt.X, 0, hrp.Position.Z - pt.Z).Magnitude <= mk.r and math.abs(hrp.Position.Y - pt.Y) < 9 and not warded(p) then
						G.hitPlayer(p, nil, mk.dmg, Vector3.new(rng:NextNumber(-15, 15), 85, rng:NextNumber(-15, 15)), "hellfire", true)
					end
				end
				for _, m in Furniture.near(pt, mk.r) do Furniture.smash(m, Vector3.new(0, 70, 0), 80) end
			end
		end
	end
	for i = #clones, 1, -1 do
		local c = clones[i]
		if not c.model.Parent then
			table.remove(clones, i)
		elseif now > c.untilT then
			shatter(c); table.remove(clones, i)
		else
			local pos = c.model:GetPivot().Position
			local best, bestD = nil, math.huge
			for _, p in matchPlayers() do
				local hrp = hrpOf(p)
				if hrp and (hrp.Position - pos).Magnitude < bestD then best, bestD = hrp, (hrp.Position - pos).Magnitude end
			end
			if best then
				local to = Vector3.new(best.Position.X - pos.X, 0, best.Position.Z - pos.Z)
				local p = best.Parent and Players:GetPlayerFromCharacter(best.Parent)
				if bestD < 3.8 and p and not warded(p) then
					G.hitPlayer(p, nil, c.dmg, flat(to) * 35 + Vector3.new(0, 18, 0), "clone", true)
					shatter(c); table.remove(clones, i)
				else
					local np = pos + (to.Magnitude > 0.1 and to.Unit or Vector3.zero) * c.speed * dt
					np = Vector3.new(np.X, best.Position.Y - 3 + c.hover + math.sin(now * 3 + i) * 0.3, np.Z)
					c.model:PivotTo(CFrame.lookAt(np, Vector3.new(best.Position.X, np.Y, best.Position.Z)))
				end
			end
		end
	end
end

-- a punch/swing that reaches a mirror clone shatters it (returns where)
function Abilities.hitClone(from: Vector3, dir: Vector3, range: number): Vector3?
	for i, c in clones do
		local p = c.model:GetPivot().Position
		local to = p - from
		if to.Magnitude <= range + 1.5 and dir:Dot(to.Unit) >= 0.35 then
			shatter(c)
			table.remove(clones, i)
			return p
		end
	end
	return nil
end

function Abilities.clear()
	Loot.clear()
	flyers = {}
	for _, c in clones do if c.model.Parent then c.model:Destroy() end end
	clones = {}
	clouds = {}
	marks = {}
end

-- the Pirate's raised shield (bracing for the bash) blocks hits from the front. dir = the hit's direction
function Abilities.blocks(g, dir: Vector3): boolean
	if not g.ab or g.ab.kind ~= "shieldBash" or g.ab.phase ~= "brace" then return false end
	return flat(dir):Dot(flat(g.hrp.CFrame.LookVector)) < -0.25
end

-- the Goblin gives back a stolen item (knocked out, killed, despawned)
Abilities.dropLoot = Loot.drop

Loot.init({
	setPhase = setPhase, start = start, finish = finish, hover = hover, flat = flat, warded = warded,
	hrpOf = hrpOf, matchPlayers = matchPlayers, fx = fx,
})

return Abilities
