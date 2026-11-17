local STUDIO = game:GetService("RunService"):IsStudio()
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
local Ragdoll = require(script.Parent.Ragdoll)

local Abilities = {}
local rng = Random.new()
local clouds = {} :: { { pos: Vector3, r: number, dps: number, untilT: number, nextTick: number } }
local marks = {} :: { { at: number, pts: { Vector3 }, r: number, dmg: number } }
-- crew = one of the Burning Captain's little skeletons: it walks round the walls (nav), and a hit doesn't shatter
-- it, it knocks it out (limp, flying, then it falls to bits)
-- from = when it starts to move (the Widow's doubles stand still for a moment first, so you see them all)
local clones = {} :: { { model: Model, untilT: number, from: number, speed: number, dmg: number, hover: number, crew: boolean?, nav: any } }
local limp = {} :: { { model: Model, untilT: number } }
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
	g.nextAbility = os.clock() + g.def.ability.cd * rng:NextNumber(0.85, 1.2) * (g.cdMult or 1) -- enraged: more often
	g.nextAttack = math.max(g.nextAttack, os.clock() + 0.8)
	G.setState(g, "Recover", recover or 0.5)
end

-- an ability was cut short (the monster got knocked back): drop a held player
function Abilities.interrupt(g)
	if not g.ab then return end
	if g.ab.kind == "grabThrow" and g.ab.victim and g.ab.phase == "hold" then
		Remotes.Fx:FireClient(g.ab.victim, "Released")
	end
	if g.ab.kind == "titanGrab" and g.ab.victim and g.ab.phase ~= "wind" then
		Remotes.Fx:FireClient(g.ab.victim, "Released") -- knocked out of his grip: the victim drops
	end
	if g.ab.kind == "blackout" then fx("BlackoutEnd"); g.model:SetAttribute("Shadow", false) end
	if g.ab.kind == "warp" then g.model:SetAttribute("Vanish", false) end
	if g.ab.kind == "steal" then Remotes.Fx:FireAllClients("GoblinUse", g.model, "", "stop", 0) end
	if g.ab.kind == "levitateThrow" and g.ab.obj then Abilities.dropLevitated(g.ab) end
	g.ab = nil
	g.model:SetAttribute("Ability", "")
	g.model:SetAttribute("AbilityPhase", "")
	g.nextAbility = os.clock() + g.def.ability.cd * 0.6 * (g.cdMult or 1)
end

-- let go of one levitated / gripped object: it falls normally again
local function ungrip(obj: Model?)
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
-- take a piece of furniture with the mind (nobody can grab it, it passes through everything while it floats)
local function grip(obj: Model, color: Color3?)
	local prim = obj.PrimaryPart :: BasePart
	obj:SetAttribute("CarriedBy", -1)
	for _, p in obj:GetDescendants() do
		if p:IsA("BasePart") then p.CanCollide = false; p.CanTouch = false; p.CollisionGroup = "Carried" end
	end
	prim.Anchored = true
	local col = color or Color3.fromRGB(255, 40, 20)
	local hl = Instance.new("Highlight")
	hl.Name = "DemonGrip"; hl.FillColor = col; hl.FillTransparency = 0.6
	hl.OutlineColor = col:Lerp(Color3.new(1, 1, 1), 0.2); hl.Parent = obj
	local aura = Instance.new("ParticleEmitter")
	aura.Name = "DemonAura"; aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	aura.Color = ColorSequence.new(col); aura.LightEmission = 1; aura.Rate = 30
	aura.Size = NumberSequence.new(0.5, 0); aura.Lifetime = NumberRange.new(0.5, 1); aura.Speed = NumberRange.new(1, 3)
	aura.SpreadAngle = Vector2.new(180, 180); aura.Parent = prim
end
Abilities.grip = grip
Abilities.ungrip = ungrip
-- the spell was interrupted (or is over): everything still floating drops
function Abilities.dropLevitated(ab)
	if ab.objs then
		for _, o in ab.objs do
			if not o.thrown then ungrip(o.obj) end
		end
	else
		ungrip(ab.obj)
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
	elseif k == "grabThrow" or k == "titanGrab" then
		if dist > a.range or warded(target) then return false end
		start(g, G, "wind", k == "titanGrab" and 0.7 or 0.55, { victim = target })
		fx("AbilityWind", g.hrp.Position, k)
	elseif k == "pounce" then
		if dist < a.min or dist > a.max then return false end
		start(g, G, "crouch", 0.55, { aim = thrp.Position })
		fx("AbilityWind", g.hrp.Position, k)
	elseif k == "levitateThrow" then
		if dist > (a.range or 70) then return false end
		-- a.count pieces at once (the evolved Demon Lord lifts several)
		local list = Furniture.nearest(g.hrp.Position, 40, a.count or 1)
		if #list == 0 then g.nextAbility = now + 2; return false end
		local objs = {}
		for i, obj in list do
			grip(obj)
			table.insert(objs, { obj = obj, from = obj:GetPivot(), spin = rng:NextNumber(-2, 2), slot = i, thrown = false })
		end
		local function snd(name: string, parent: Instance, vol: number?)
			local s = Instance.new("Sound"); s.SoundId = "rbxassetid://" .. Sounds[name].ids[1]; s.Volume = vol or Sounds[name].volume
			s.RollOffMinDistance = 10; s.RollOffMaxDistance = 140; s.Parent = parent; s:Play()
			game:GetService("Debris"):AddItem(s, 6)
		end
		snd("Telekinesis", list[1].PrimaryPart :: BasePart)
		snd("DemonLaugh", g.model:FindFirstChild("Head") or g.hrp)
		start(g, G, "lift", a.lift or 1.3, { obj = list[1], objs = objs, t0 = now, snd = snd })
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
	elseif k == "warp" then
		-- the Conqueror is slow: from far enough he opens a portal, steps in, and comes out a few strides from you
		if dist < a.min or warded(target) then return false end
		start(g, G, "wind", a.wind, { victim = target })
		fx("WarpWind", g.model, a.wind)
	elseif k == "clones" then
		if #clones > 0 then return false end
		start(g, G, "cast", 0.9, {})
		fx("AbilityWind", g.hrp.Position, k)
		task.delay(0.5, function()
			if not g.model.Parent or g.state == "Dead" then return end
			local pts = {}
			for i = 1, a.n do
				local ang = (i / a.n) * math.pi * 2 + rng:NextNumber(-0.3, 0.3)
				table.insert(pts, g.hrp.Position + Vector3.new(math.cos(ang) * 9, 0, math.sin(ang) * 9))
			end
			Abilities.spawnClones(g, pts, a.t, a.dmg * dmgScale(g), 14 * (g.speedMult or 1))
		end)
	else
		return false
	end
	return true
end

local function hover(g, hoverY: number, v: Vector3): Vector3
	return Vector3.new(v.X, (hoverY - g.hrp.Position.Y) * 4, v.Z)
end

-- copies of the monster that walk at the players and burst when they touch one or get punched (mirror clones, the
-- Violet Widow's doubles, the Burning Captain's little skeletons). scale = a smaller copy (its small parts are dropped).
-- opts: scale = a smaller copy, crew = the Captain's little skeletons (see `clones` above), delay = seconds they
-- stand still before they come.
function Abilities.spawnClones(g, pts: { Vector3 }, t: number, dmg: number, speed: number, opts: { scale: number?, crew: boolean?, delay: number? }?)
	local scale, crew, delay = opts and opts.scale, opts and opts.crew, opts and opts.delay or 0
	local full = g.model:GetScale()
	for _, at in pts do
		local c = g.model:Clone()
		c.Name = "GhostClone"
		for _, d in c:GetDescendants() do
			if d:IsA("Constraint") or d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Humanoid") or d:IsA("Highlight") then d:Destroy()
			elseif d:IsA("BasePart") then
				if scale and math.max(d.Size.X, d.Size.Y, d.Size.Z) < 0.75 * full then
					d:Destroy() -- a little copy: no teeth, fingers and other tiny parts
				else
					d.Anchored = true; d.CanQuery = false; d.CanTouch = false; d.CanCollide = false
				end
			end
		end
		local loot = c:FindFirstChild("Loot") if loot then loot:Destroy() end
		c:SetAttribute("Clone", true)
		if crew then c:SetAttribute("Crew", true) end
		c:SetAttribute("HP", nil); c:SetAttribute("MaxHP", nil)
		if scale then c:ScaleTo(full * scale) end
		c:PivotTo(CFrame.new(at) * g.model:GetPivot().Rotation)
		c.Parent = workspace
		local hover = g.hover * (scale or 1)
		local root = c:FindFirstChild("HumanoidRootPart")
		if crew and root and root:IsA("BasePart") then
			-- the crew runs (Client/CrewAnim): only the root stays anchored, the body hangs on its joints. A part
			-- whose joint went with a dropped tiny part stays anchored, or it would fall out of the world.
			for _, p in root:GetConnectedParts(true) do
				if p ~= root then p.Anchored = false; p.Massless = true end
			end
		end
		table.insert(clones, { model = c, untilT = os.clock() + t + delay, from = os.clock() + delay, speed = speed, dmg = dmg, hover = hover, crew = crew,
			nav = (crew and root) and { hrp = root, hover = hover } or nil })
		fx("CloneSpawn", at, crew and "bone" or nil)
	end
end
function Abilities.cloneCount(): number return #clones end
-- the Goblin King starts armed (and re-arms): Loot.arm
Abilities.armGoblin = Loot.arm
Abilities.finish = finish

-- THE PARTY BEAR LOST YOU IN THE DARK (stuck behind a wall or under another floor, or too far to walk to you before
-- the lights come back): instead of giving the hunt up he appears close by and keeps coming. Never on top of the
-- player: 9-12 studs away, on the same floor, with nothing between them, and behind their back when there is room.
local function stalkSpot(g, G, thrp: BasePart): Vector3?
	local c = thrp.Position
	local down = workspace:Raycast(c, Vector3.new(0, -12, 0), g.rp)
	if not down then return nil end -- in the air / falling: not now
	local look = flat(thrp.CFrame.LookVector)
	for _, r in { 12, 9 } do
		local best: Vector3?, bestScore = nil, -math.huge
		for i = 0, 11 do
			local ang = i * math.pi / 6 + rng:NextNumber(-0.2, 0.2)
			local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
			local at = c + dir * r
			if not G.outside(at) and not workspace:Raycast(c, dir * (r + 3), g.rp) then
				local floor = workspace:Raycast(at + Vector3.new(0, 1, 0), Vector3.new(0, -9, 0), g.rp)
				if floor and math.abs(floor.Position.Y - down.Position.Y) < 2.5 then
					local score = -look:Dot(dir) + rng:NextNumber(0, 0.5)
					if score > bestScore then best, bestScore = Vector3.new(at.X, floor.Position.Y + g.hover, at.Z), score end
				end
			end
		end
		if best then return best end
	end
	return nil
end

local function stalkBlink(g, G, thrp: BasePart): boolean
	local at = stalkSpot(g, G, thrp)
	if not at then return false end
	local from = g.hrp.Position
	local cf = CFrame.lookAt(at, Vector3.new(thrp.Position.X, at.Y, thrp.Position.Z))
	g.model:PivotTo(cf)
	g.ao.CFrame = cf.Rotation
	g.lv.VectorVelocity = Vector3.zero
	g.hrp.AssemblyLinearVelocity = Vector3.zero
	g.hrp.AssemblyAngularVelocity = Vector3.zero
	g.path = nil
	fx("StalkerBlink", from, at)
	return true
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
	if k == "warp" then
		g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
		if ab.phase == "wind" then
			if thrp then face(thrp.Position) end
			-- he fades into the portal just before the jump and out of the other one just after it
			if not ab.faded and now >= ab.untilT - 0.3 then
				ab.faded = true
				g.model:SetAttribute("Vanish", true)
			end
			if now >= ab.untilT then
				-- out of the portal near his victim: never on top of them, behind their back when there is room
				local vh = (ab.victim and hrpOf(ab.victim)) or thrp
				local at = vh and stalkSpot(g, G, vh)
				if vh and at then
					local cf = CFrame.lookAt(at, Vector3.new(vh.Position.X, at.Y, vh.Position.Z))
					g.model:PivotTo(cf)
					g.ao.CFrame = cf.Rotation
					g.hrp.AssemblyLinearVelocity = Vector3.zero
					g.hrp.AssemblyAngularVelocity = Vector3.zero
					g.path = nil
					fx("Warp", pos, at)
					setPhase(g, "out", 0.8) -- he stands there for a moment: time to turn round
				else
					g.model:SetAttribute("Vanish", false)
					finish(g, G, 0.3) -- no room near them right now
				end
			end
		else
			if now >= ab.untilT - 0.55 then g.model:SetAttribute("Vanish", false) end
			if now >= ab.untilT then finish(g, G, 0.15) end
		end
		return
	end
	if k == "titanGrab" then
		-- the Flayed Giant: grab, then (another player standing) carry the victim over and swing them into that
		-- player twice, then throw; (alone) throw right away
		local vh = ab.victim and hrpOf(ab.victim)
		local victimOk = vh ~= nil and ab.victim.Parent ~= nil and not warded(ab.victim)
		local function throwVictim()
			if victimOk then
				local side = g.hrp.CFrame.RightVector * (rng:NextNumber() < 0.5 and -1 or 1)
				local dir = flat(g.hrp.CFrame.LookVector * 0.6 + side * 0.8)
				G.hitPlayer(ab.victim, nil, a.dmg * dmgScale(g), dir * a.power + Vector3.new(0, 48, 0), "titan", true, 1.4)
			end
			finish(g, G, 0.8)
		end
		local function otherAlive(): (Player?, BasePart?)
			local best, bestHrp, bestD = nil, nil, a.swingRange or 60
			for _, p in matchPlayers() do
				local h = hrpOf(p)
				local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				if p ~= ab.victim and h and hum and hum.Health > 0 and not warded(p) and not p:GetAttribute("Spectating") then
					local d = (h.Position - pos).Magnitude
					if d < bestD then best, bestHrp, bestD = p, h, d end
				end
			end
			return best, bestHrp
		end
		if ab.phase == "wind" then
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
			if vh then face(vh.Position) end
			if now >= ab.untilT then
				if vh and (vh.Position - pos).Magnitude <= a.range + 3 and not warded(ab.victim) then
					local hand = g.model:FindFirstChild("RightHand") or g.model:FindFirstChild("RightLowerArm") or g.hrp
					local other = otherAlive()
					Remotes.Fx:FireClient(ab.victim, "Grabbed", hand, other and 6.5 or 1)
					fx("AbilityHit", vh.Position, k)
					if other then
						ab.other = other
						ab.swings = 0
						setPhase(g, "carry", 3.5)
					else
						setPhase(g, "hold", 0.8)
					end
				else
					finish(g, G, 0.6) -- missed
				end
			end
		elseif ab.phase == "hold" then
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT or not victimOk then throwVictim() end
		elseif ab.phase == "carry" then
			-- walk over to the other player with the victim in his fist
			local oh = ab.other and hrpOf(ab.other)
			if not victimOk then finish(g, G, 0.6); return end
			if not oh then setPhase(g, "hold", 0.4); return end
			local to = Vector3.new(oh.Position.X - pos.X, 0, oh.Position.Z - pos.Z)
			face(oh.Position)
			if to.Magnitude <= (a.swingReach or 13) then
				setPhase(g, "swing", 0.5)
			elseif now >= ab.untilT then
				setPhase(g, "hold", 0.3) -- couldn't reach them: just throw
			else
				g.lv.VectorVelocity = hover(g, hoverY, to.Unit * (a.carrySpeed or 26) * (g.speedMult or 1))
			end
		elseif ab.phase == "swing" or ab.phase == "swing2" then
			-- the victim is the club: two swings into the other player (two phase names so the arm swings twice)
			g.lv.VectorVelocity = hover(g, hoverY, Vector3.zero)
			local oh = ab.other and hrpOf(ab.other)
			if oh then face(oh.Position) end
			if now >= ab.untilT then
				ab.swings += 1
				if oh and victimOk and (oh.Position - pos).Magnitude <= (a.swingReach or 13) + 5 then
					local side = flat(oh.Position - pos)
					G.hitPlayer(ab.other, nil, a.swingDmg * dmgScale(g), side * 70 + g.hrp.CFrame.RightVector * -30 + Vector3.new(0, 30, 0), "titan", true, 1.0)
					G.damagePlayer(ab.victim, a.swingDmg * 0.5 * dmgScale(g), nil, Vector3.zero) -- being swung hurts too
					fx("AbilityHit", oh.Position, k)
				end
				if ab.swings >= 2 then setPhase(g, "hold", 0.35) else setPhase(g, "swing2", 0.55) end
			end
		end
		return
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
		local objs = ab.objs
		local n = #objs
		-- pieces that broke or vanished are out
		local live = 0
		for _, o in objs do
			if not o.thrown and (not o.obj.Parent or o.obj:GetAttribute("Broken")) then o.thrown = true end
			if not o.thrown then live += 1 end
		end
		if ab.phase ~= "throw" and live == 0 then finish(g, G, 0.3); return end
		-- Studio photo hook: ReplicatedStorage attribute DebugHoldCast keeps him aiming with the object up
		if ab.phase == "aim" and game:GetService("RunService"):IsStudio() and game.ReplicatedStorage:GetAttribute("DebugHoldCast") then ab.untilT = now + 0.5 end
		-- every piece still held floats over his raised hand (several: fanned out above him)
		local f = ab.phase == "lift" and math.clamp((now - ab.t0) / a.lift, 0, 1) or 1
		local e = f * f * (3 - 2 * f)
		for _, o in objs do
			if not o.thrown then
				local off = n == 1 and CFrame.new(1.5, 7.5, -3.5) or CFrame.new((o.slot - (n + 1) / 2) * 6.5, 9 + (o.slot % 2) * 2.5, -3)
				local hold = (g.hrp.CFrame * off).Position
				local p = o.from.Position:Lerp(hold, e) + Vector3.new(0, math.sin(now * 5 + o.slot) * 0.35, 0)
				local shake = ab.phase ~= "lift" and Vector3.new(rng:NextNumber(-0.2, 0.2), rng:NextNumber(-0.2, 0.2), rng:NextNumber(-0.2, 0.2)) or Vector3.zero
				o.obj:PivotTo(CFrame.new(p + shake) * o.from.Rotation * CFrame.Angles(0, (now - ab.t0) * o.spin, math.sin(now * 2) * 0.25))
			end
		end
		if ab.phase == "lift" and now >= ab.untilT then
			setPhase(g, "aim", a.aim or 0.45)
		elseif ab.phase == "aim" and now >= ab.untilT then
			-- thrown one after the other (0.3 s apart), each at where its target stands at that moment
			setPhase(g, "throw", 0.5 + 0.3 * (n - 1))
			ab.snd("DemonRoar", g.model:FindFirstChild("Head") or g.hrp)
			ab.nextThrow = now
		end
		if ab.phase == "throw" then
			if live > 0 and now >= (ab.nextThrow or 0) then
				ab.nextThrow = now + 0.3
				for _, o in objs do
					if not o.thrown then
						o.thrown = true
						ungrip(o.obj)
						local hrp = hrpOf(target)
						if hrp then
							Furniture.flingAt(o.obj, hrp.Position + Vector3.new(0, 1, 0), nil, a.power or 150)
							local info = Furniture.thrown[o.obj]
							if info then info.monster = (a.dmg or 20) * dmgScale(g) end
						end
						break
					end
				end
			end
			if now >= ab.untilT then finish(g, G, 0.4) end
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
			local sp = (a.speed or 22) * (g.speedMult or 1) * (ab.rush or 1)
			-- Studio test hook: ReplicatedStorage attribute DebugHuntHold = true makes the hunter stand still in the dark
			if STUDIO and game:GetService("ReplicatedStorage"):GetAttribute("DebugHuntHold") then sp = 0 end
			-- feet to feet: a player on another floor is not "reached" through the ceiling
			local dy = math.abs((thrp.Position.Y - 3) - (pos.Y - g.hover))
			if a.lightsOut and sp > 0 then
				-- lost you? (see stalkSpot) Checked from 1.5 s into the hunt, at most twice per hunt.
				ab.t0 = ab.t0 or now
				if not ab.mark or now - ab.markT >= 1.2 then
					ab.stuck = ab.mark ~= nil and (pos - ab.mark).Magnitude < 2.5 -- hardly moved since the last look
					ab.mark, ab.markT = pos, now
				end
				local P = g.path
				-- the way that is left (round the walls, down the stairs) against the time that is left
				local walk = to.Magnitude
				if P ~= nil and P.pts ~= nil and P.i ~= nil and P.pts[P.i] then
					local at = pos
					walk = 0
					for i = P.i, #P.pts do
						local wp = P.pts[i].Position
						walk += Vector3.new(wp.X - at.X, 0, wp.Z - at.Z).Magnitude
						at = wp
					end
				end
				local tooFar = walk > sp * (ab.untilT - now) * 0.85
				local away = to.Magnitude > 8 or dy > 7
				if away and (ab.stuck or tooFar) and now - ab.t0 > 1.5 and now >= (ab.nextBlink or 0) and (ab.blinks or 0) < 2 then
					ab.nextBlink = now + 0.5 -- no room near the player right now: look again in a moment
					if stalkBlink(g, G, thrp) then
						-- Studio test hook: why he blinked (model attribute BlinkWhy)
						if STUDIO then g.model:SetAttribute("BlinkWhy", (ab.stuck and "stuck " or "") .. (tooFar and "tooFar" or "")) end
						ab.blinks = (ab.blinks or 0) + 1
						ab.nextBlink = now + 3.5
						ab.mark, ab.stuck = nil, false
						-- he growls where he stands for a moment (time to turn round, hit him or run), then the last
						-- steps are quicker than his stalk (walking away doesn't save you, a sprint does)
						ab.standUntil = now + 0.9
						ab.rush = 1.3
						-- time to cover those last steps: the dark holds a little longer
						if ab.untilT - now < 4.5 then
							ab.untilT = now + 4.5
							fx("BlackoutExtend", 4.5)
						end
						return
					end
				end
			end
			if ab.standUntil and now < ab.standUntil then sp = 0 end
			-- solid monsters (the Animatronic) walk around the walls; the Woman glides through them
			local goal = (g.def.solid and G.pathPoint) and G.pathPoint(g, thrp.Position) or thrp.Position
			local step = Vector3.new(goal.X - pos.X, 0, goal.Z - pos.Z)
			local v = step.Magnitude > 0.5 and step.Unit * sp or Vector3.zero
			if g.def.solid and G.blockWalls then v = G.blockWalls(g, v) end
			face(pos + (v.Magnitude > 0.5 and v or to))
			g.lv.VectorVelocity = hover(g, hoverY, v)
			if to.Magnitude < 5.5 and dy < 7 and not warded(target) then
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
	fx("CloneShatter", c.model:GetPivot().Position, c.crew and "bone" or nil)
	c.model:Destroy()
end

-- a little skeleton got hit: it goes limp and flies off like the big monsters do, then falls to bits
local function knockOut(c, vel: Vector3)
	Ragdoll.toss(c.model, vel)
	table.insert(limp, { model = c.model, untilT = os.clock() + 1.7 })
end

-- lingering things: gas clouds, hellfire marks, mirror clones
-- (Studio photo hook: RS attribute DebugFreezeGhost also holds the doubles and the crew where they are)
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
					G.damagePlayer(p, c.dps * 0.5, 4, Vector3.zero) -- gas: not blockable
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
	local hold = STUDIO and game:GetService("ReplicatedStorage"):GetAttribute("DebugFreezeGhost") == true
	for i = #limp, 1, -1 do
		local l = limp[i]
		if not l.model.Parent then
			table.remove(limp, i)
		elseif hold then
			l.untilT += dt
		elseif now > l.untilT then
			local torso = (l.model:FindFirstChild("UpperTorso") or l.model:FindFirstChild("HumanoidRootPart")) :: BasePart?
			fx("CloneShatter", torso and torso.Position or l.model:GetPivot().Position, "bone")
			l.model:Destroy()
			table.remove(limp, i)
		end
	end
	local boss = G.current
	for i = #clones, 1, -1 do
		local c = clones[i]
		if not c.model.Parent then
			table.remove(clones, i)
		elseif hold then
			c.untilT += dt
		elseif now < c.from then
			-- standing there for a moment before they come
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
					if c.crew then
						G.hitPlayer(p, nil, c.dmg, flat(to) * 12 + Vector3.new(0, 6, 0), "clone", true) -- a nip, barely a shove
					else
						G.hitPlayer(p, nil, c.dmg, flat(to) * 35 + Vector3.new(0, 18, 0), "clone", true)
					end
					shatter(c); table.remove(clones, i)
				elseif c.crew then
					-- the crew runs on the floor and round the walls, like their Captain
					local goal = best.Position
					if c.nav and G.pathPoint then goal = G.pathPoint(c.nav, best.Position) end
					local step = Vector3.new(goal.X - pos.X, 0, goal.Z - pos.Z)
					local dir = step.Magnitude > 0.1 and step.Unit or flat(to)
					local np = pos + dir * c.speed * dt
					local y = best.Position.Y - 3 + c.hover
					local floor = boss and workspace:Raycast(Vector3.new(np.X, pos.Y + 3, np.Z), Vector3.new(0, -40, 0), boss.rp)
					if floor then y = floor.Position.Y + c.hover end
					y = pos.Y + (y - pos.Y) * math.min(1, dt * 12)
					np = Vector3.new(np.X, y, np.Z)
					c.model:PivotTo(CFrame.lookAt(np, np + dir))
				else
					local np = pos + (to.Magnitude > 0.1 and to.Unit or Vector3.zero) * c.speed * dt
					np = Vector3.new(np.X, best.Position.Y - 3 + c.hover + math.sin(now * 3 + i) * 0.3, np.Z)
					c.model:PivotTo(CFrame.lookAt(np, Vector3.new(best.Position.X, np.Y, best.Position.Z)))
				end
			end
		end
	end
end

-- a punch/swing that reaches a mirror clone shatters it (returns where). The Captain's little skeletons are so
-- weak that one swing sends every one of them in front of you flying, limp (charge 0..1 = a charged hit: further).
function Abilities.hitClone(from: Vector3, dir: Vector3, range: number, charge: number?): Vector3?
	local first: Vector3? = nil
	local fdir = flat(dir)
	for i = #clones, 1, -1 do
		local c = clones[i]
		local p = c.model:GetPivot().Position
		local to = p - from
		if c.crew then
			-- they only come up to your knees: aimed on the flat, not at their height
			local ft = Vector3.new(to.X, 0, to.Z)
			if ft.Magnitude <= range + 1.5 and math.abs(to.Y) < 9 and (ft.Magnitude < 2 or fdir:Dot(ft.Unit) >= 0.2) then
				table.remove(clones, i)
				local k = math.clamp(charge or 0, 0, 1)
				local side = ft.Magnitude > 0.5 and ft.Unit or fdir
				knockOut(c, (fdir * 0.75 + side * 0.25).Unit * (62 + 40 * k) + Vector3.new(0, 26 + 12 * k, 0))
				first = first or p
			end
		elseif not first and to.Magnitude <= range + 1.5 and dir:Dot(to.Unit) >= 0.35 then
			shatter(c)
			table.remove(clones, i)
			return p
		end
	end
	return first
end

function Abilities.clear()
	Loot.clear()
	flyers = {}
	for _, c in clones do if c.model.Parent then c.model:Destroy() end end
	clones = {}
	for _, l in limp do if l.model.Parent then l.model:Destroy() end end
	limp = {}
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
