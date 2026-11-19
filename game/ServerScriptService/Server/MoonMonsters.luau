--!strict
-- THE BLACK MOON's three new monsters' special moves (Shared/Monsters; models: tools/build/moon_monsters.luau;
-- client: Client/MoonFx). Abilities hands try / step / interrupt / tick / clear over, like Server/HarborMonsters.
--   THE LOST ASTRONAUT (astronaut):
--     breach   he winds up a punch at the wall nearest you (smash: BreachWarn on the spot), the hull breaks (vent):
--              everyone is dragged toward the hole (Client/MoonFx pulls its own body: walk against it), and the
--              hole itself hurts whoever is in it
--     jetpack  his jetpack fires (ignite) and he goes up under the ceiling (hang: a red ring follows you), the ring
--              locks (dive) and he drops on it in a ring of fire
--   THE SPECIMEN (specimen):
--     acid     it rears back (rear) and spits three globs of acid in a fan (spit): each leaves a pool on the floor
--              that burns whoever stands in it for a few seconds (AcidPool; the pools outlive the move)
--     brood    its back splits (split) and its larvae crawl out and run at you (clones: one hit kills one)
--   THE SENTINEL (sentinel):
--     missiles red rings lock on everyone (aim), its shoulder pods fire (fire) and the missiles come down on the
--              rings a moment later: get out of yours
--     overload it plugs its arms into the floor (plug) and arcs of lightning jump to everyone near it who it can
--              see (arc): get far away or behind something solid
local Players = game:GetService("Players")

local MM = {}
local H: any = nil -- Abilities' helpers
function MM.init(h) H = h end
local rng = Random.new()

MM.KINDS = { astronaut = true, specimen = true, sentinel = true }

local function face(g, at: Vector3)
	local d = H.flat(at - g.hrp.Position)
	if d.Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(Vector3.zero, d) end
end
local function floorBelow(g, pos: Vector3): Vector3
	local r = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -40, 0), g.rp)
	return r and r.Position or (pos - Vector3.new(0, 3, 0))
end
local function sees(g, from: Vector3, to: Vector3): boolean
	local r = workspace:Raycast(from, to - from, g.rp)
	return r == nil or (r.Position - from).Magnitude > (to - from).Magnitude - 2.5
end
local function fxFolder(): Folder
	local f = workspace:FindFirstChild("MoonFx") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "MoonFx"; nf.Parent = workspace
		f = nf
	end
	return f :: Folder
end
local function hitAround(g, G, pos: Vector3, r: number, hit: { [Player]: boolean }?, dmg: number, power: number, up: number, kind: string, ragT: number?)
	for _, p in H.matchPlayers() do
		local h = H.hrpOf(p)
		if h and not H.warded(p) and not (hit and hit[p]) then
			local off = h.Position - pos
			if Vector3.new(off.X, 0, off.Z).Magnitude < r and math.abs(off.Y) < 9 then
				if hit then hit[p] = true end
				G.hitPlayer(p, nil, dmg * H.dmgScale(g), H.flat(off) * power + Vector3.new(0, up, 0), kind, true, ragT or 1.2)
			end
		end
	end
end

-- ACID POOLS (they outlive the Specimen's move): { pos, r, untilT, nextT, tick, dmg }
type Pool = { pos: Vector3, r: number, untilT: number, nextT: number, tick: number, dmg: number }
local pools = {} :: { Pool }

-- a flying glob (several at once): moves on an arc, stops on walls / the floor / a player
type Glob = { part: Part, pos: Vector3, vel: Vector3, t0: number, done: boolean }
local function glob(from: Vector3, at: Vector3, speed: number): Glob
	local d = at - from
	local t = math.max(0.2, d.Magnitude / speed)
	local grav = 36
	local p = Instance.new("Part")
	p.Name = "AcidGlob"; p.Shape = Enum.PartType.Ball; p.Size = Vector3.one * 1.3; p.Color = Color3.fromRGB(140, 255, 90); p.Material = Enum.Material.Neon
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Position = from; p.Parent = fxFolder()
	return { part = p, pos = from, vel = Vector3.new(d.X / t, d.Y / t + 0.5 * grav * t, d.Z / t), t0 = os.clock(), done = false }
end

-- a larva (the Specimen's brood): a clone entry Abilities walks at the players
local function larva(cf: CFrame): Model
	local m = Instance.new("Model")
	m.Name = "Larva"
	local SKIN, VEIN = Color3.fromRGB(196, 206, 170), Color3.fromRGB(120, 255, 90)
	local function P(name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?)
		local p = Instance.new("Part")
		p.Name = name; p.Size = size; p.CFrame = cf * rel; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
		if shape then p.Shape = shape end
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
		p.Parent = m
		return p
	end
	local body = P("UpperTorso", Vector3.new(1.4, 1.1, 2.6), CFrame.new(0, 0, 0), SKIN, Enum.Material.Slate)
	P("Head", Vector3.new(1.2, 1.0, 1.0), CFrame.new(0, 0.15, -1.6), SKIN, Enum.Material.Slate)
	P("Jaw", Vector3.new(1.0, 0.3, 0.6), CFrame.new(0, -0.35, -2.0), Color3.fromRGB(60, 20, 30))
	P("Glow", Vector3.new(1.45, 0.2, 2.3), CFrame.new(0, 0.5, 0.1), VEIN, Enum.Material.Neon)
	for _, s in { -1, 1 } do
		P("Eye", Vector3.new(0.25, 0.25, 0.1), CFrame.new(s * 0.32, 0.35, -2.1), VEIN, Enum.Material.Neon)
		for k = 0, 2 do P("Leg", Vector3.new(0.2, 0.2, 1.4), CFrame.new(s * 0.95, -0.35, -0.8 + k * 0.8) * CFrame.Angles(0, s * 1.2, 0.5 * s), Color3.fromRGB(150, 150, 130)) end
	end
	P("Tail", Vector3.new(0.7, 0.6, 1.4), CFrame.new(0, -0.1, 1.8), SKIN, Enum.Material.Slate)
	m.PrimaryPart = body
	m.Parent = workspace
	return m
end

---------------------------------------------------------------------------------------------- choosing a move
local function candidates(g, a, thrp: BasePart, dist: number): { string }
	local out = {}
	local k = a.kind
	local eye = g.hrp.Position + Vector3.new(0, 2.5, 0)
	local inSight = sees(g, eye, thrp.Position)
	if k == "astronaut" then
		if dist <= a.breach.max then table.insert(out, "breach") end
		if dist >= a.jetpack.min and dist <= a.jetpack.max then table.insert(out, "jetpack") end
	elseif k == "specimen" then
		if dist >= a.acid.min and dist <= a.acid.max and inSight then table.insert(out, "acid") end
		if dist <= a.brood.max then table.insert(out, "brood") end
	elseif k == "sentinel" then
		if dist <= a.missiles.max then table.insert(out, "missiles") end
		if dist <= a.overload.max then table.insert(out, "overload") end
	end
	return out
end

-- the hull spot nearest the victim (a wall 12+ studs away, so they have a chance), or nil
local function breachSpot(g, vh: BasePart): (Vector3?, Vector3?)
	local best: RaycastResult? = nil
	local bestD = math.huge
	for i = 0, 15 do
		local ang = i / 16 * math.pi * 2
		local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
		local r = workspace:Raycast(vh.Position, dir * 90, g.rp)
		if r and math.abs(r.Normal.Y) < 0.3 then
			local d = (r.Position - vh.Position).Magnitude
			if d >= 12 and d < bestD then best, bestD = r, d end
		end
	end
	if not best then return nil, nil end
	local fl = floorBelow(g, best.Position + best.Normal * 2)
	return Vector3.new(best.Position.X, fl.Y + 4, best.Position.Z) + best.Normal * 0.6, best.Normal
end

local function begin(g, G, move: string, a, target: Player, thrp: BasePart): boolean
	g.lastMove = move
	if move == "breach" then
		local spot, normal = breachSpot(g, thrp)
		if not spot then return false end
		H.start(g, G, "smash", a.breach.wind, { move = move, victim = target, spot = spot, normal = normal })
		H.fx("BreachWarn", g.model, spot, normal, a.breach.wind)
	elseif move == "jetpack" then
		local up = workspace:Raycast(g.hrp.Position, Vector3.new(0, 40, 0), g.rp)
		local room = up and (up.Position.Y - g.hrp.Position.Y) or 30
		H.start(g, G, "ignite", a.jetpack.lift, { move = move, victim = target, rise = math.clamp(room - 7, 4, 16) })
		H.fx("JetIgnite", g.model, a.jetpack.lift)
	elseif move == "acid" then
		H.start(g, G, "rear", a.acid.wind, { move = move, victim = target, globs = {} })
		H.fx("AcidRear", g.model, a.acid.wind)
	elseif move == "brood" then
		H.start(g, G, "split", a.brood.wind, { move = move, victim = target })
		H.fx("BroodSplit", g.model, a.brood.wind)
	elseif move == "missiles" then
		local who = {}
		for _, p in H.matchPlayers() do if not H.warded(p) then table.insert(who, p) end end
		H.start(g, G, "aim", a.missiles.lock, { move = move, victim = target, who = who })
		H.fx("MissileLock", g.model, who, a.missiles.lock, a.missiles.radius)
	elseif move == "overload" then
		H.start(g, G, "plug", a.overload.charge, { move = move, victim = target })
		H.fx("OverloadCharge", g.model, a.overload.charge, a.overload.range)
	end
	return true
end

function MM.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	if H.warded(target) then return false end
	local list = candidates(g, a, thrp, dist)
	if #list == 0 then return false end
	if #list > 1 and g.lastMove then
		for i = #list, 1, -1 do if list[i] == g.lastMove then table.remove(list, i) end end
	end
	local pick = list[rng:NextInteger(1, #list)]
	if not begin(g, G, pick, a, target, thrp) then
		-- (no wall to break here: the other move, if there is one)
		for _, m in list do if m ~= pick and begin(g, G, m, a, target, thrp) then break end end
	end
	local _ = now
	return g.ab ~= nil
end

---------------------------------------------------------------------------------------------- THE LOST ASTRONAUT
local function stepAstronaut(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	if ab.move == "breach" then
		local c = a.breach
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if ab.phase == "smash" then
			face(g, ab.spot)
			if now >= ab.untilT then
				ab.nextTick = now + c.tick
				H.setPhase(g, "vent", c.pull)
				H.fx("BreachOpen", ab.spot, ab.normal, c.pull, c.force, c.radius)
			end
		else -- vent: the hole hurts whoever is in it
			if now >= ab.nextTick then
				ab.nextTick = now + c.tick
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) and (h.Position - ab.spot).Magnitude < c.radius then
						G.damagePlayer(p, c.dmg * H.dmgScale(g), 2, ab.spot)
					end
				end
			end
			if now >= ab.untilT then
				H.fx("BreachSeal", ab.spot)
				H.finish(g, G, 0.4)
			end
		end
	else -- jetpack
		local c = a.jetpack
		if ab.phase == "ignite" then
			-- up under the ceiling
			g.lv.VectorVelocity = H.hover(g, hoverY + ab.rise, Vector3.zero)
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				H.setPhase(g, "hang", c.hang)
				H.fx("JetTarget", ab.victim, c.hang, c.radius)
			end
		elseif ab.phase == "hang" then
			-- drifting over the target, high up
			local to = vh and Vector3.new(vh.Position.X - pos.X, 0, vh.Position.Z - pos.Z) or Vector3.zero
			local v = to.Magnitude > 1 and to.Unit * math.min(30, to.Magnitude * 2.5) or Vector3.zero
			g.lv.VectorVelocity = H.hover(g, hoverY + ab.rise, v)
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				ab.spot = vh and floorBelow(g, vh.Position) or floorBelow(g, pos)
				ab.from = pos
				H.setPhase(g, "dive", c.dive)
				H.fx("JetLock", ab.spot, c.radius, c.dive)
			end
		elseif ab.phase == "dive" then
			local goal = (ab.spot :: Vector3) + Vector3.new(0, g.hover, 0)
			local left = math.max(0.05, ab.untilT - now)
			g.lv.VectorVelocity = (goal - pos) / left
			if now >= ab.untilT then
				g.model:PivotTo(CFrame.new(goal) * g.model:GetPivot().Rotation)
				g.lv.VectorVelocity = Vector3.zero
				hitAround(g, G, ab.spot, c.radius, nil, c.dmg, c.power, c.up, "jetpack", 1.3)
				H.fx("JetSlam", ab.spot, c.radius)
				H.setPhase(g, "land", 0.6)
			end
		else -- land
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then H.finish(g, G, 0.35) end
		end
	end
	local _ = dt
end

---------------------------------------------------------------------------------------------- THE SPECIMEN
local function stepSpecimen(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.move == "acid" then
		local c = a.acid
		if ab.phase == "rear" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				local head = g.model:FindFirstChild("Head") :: BasePart?
				local from = (head and head.Position or pos + Vector3.new(0, 3, 0)) + g.hrp.CFrame.LookVector * 1.5
				local at = vh and (vh.Position + vh.AssemblyLinearVelocity * Vector3.new(1, 0, 1) * 0.3) or (pos + g.hrp.CFrame.LookVector * 20)
				local mid = math.floor((c.globs + 1) / 2)
				for i = 1, c.globs do
					local ang = (i - mid) * c.spread
					local off = at - pos
					local rot = CFrame.Angles(0, ang, 0):VectorToWorldSpace(off)
					local gl = glob(from, pos + rot - Vector3.new(0, 2.5, 0), c.speed)
					table.insert(ab.globs, gl)
					H.fx("AcidFly", gl.part)
				end
				H.setPhase(g, "spit", 2.2)
			end
		else -- spit: the globs fly; each one that lands leaves a pool
			local live = 0
			for _, gl in ab.globs :: { Glob } do
				if gl.done then continue end
				live += 1
				gl.vel += Vector3.new(0, -36 * dt, 0)
				local to = gl.pos + gl.vel * dt
				local hit = workspace:Raycast(gl.pos, to - gl.pos, g.rp)
				local victim: Player? = nil
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) and (h.Position - to).Magnitude < 2.6 then victim = p; break end
				end
				if hit or victim or now - gl.t0 > 2 then
					gl.done = true
					local at = hit and hit.Position or to
					if victim then G.damagePlayer(victim, c.dmg * H.dmgScale(g), 10, at) end
					local land = floorBelow(g, at + Vector3.new(0, 1, 0))
					table.insert(pools, { pos = land, r = c.pool, untilT = now + c.life, nextT = now + 0.25, tick = c.tick, dmg = c.tickDmg * H.dmgScale(g) })
					H.fx("AcidPool", land, c.pool, c.life)
					gl.part:Destroy()
				else
					gl.pos = to
					gl.part.Position = to
				end
			end
			if live == 0 or now >= ab.untilT then
				for _, gl in ab.globs :: { Glob } do if gl.part.Parent then gl.part:Destroy() end end
				H.finish(g, G, 0.35)
			end
		end
	else -- brood
		local c = a.brood
		if ab.phase == "split" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				local list = H.clones()
				for i = 1, c.count do
					local ang = (i / c.count) * math.pi * 2 + rng:NextNumber(-0.3, 0.3)
					local spot = pos + Vector3.new(math.cos(ang), 0, math.sin(ang)) * 4
					local f = workspace:Raycast(spot + Vector3.new(0, 3, 0), Vector3.new(0, -12, 0), g.rp)
					local base = f and f.Position or floorBelow(g, pos)
					local lv = larva(CFrame.new(base + Vector3.new(0, 0.9, 0)) * CFrame.Angles(0, ang, 0))
					lv:SetAttribute("Clone", true)
					table.insert(list, { model = lv, untilT = now + c.life, from = now + 0.5, speed = c.speed, dmg = c.dmg * H.dmgScale(g), hover = 0.9, kind = "larva" })
					H.fx("CloneSpawn", base + Vector3.new(0, 0.6, 0), "larva")
				end
				H.fx("BroodBurst", g.model)
				H.setPhase(g, "shudder", 0.7)
			end
		elseif now >= ab.untilT then
			H.finish(g, G, 0.3)
		end
	end
end

---------------------------------------------------------------------------------------------- THE SENTINEL
local function stepSentinel(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.move == "missiles" then
		local c = a.missiles
		if ab.phase == "aim" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				local spots = {} :: { Vector3 }
				for _, p in ab.who :: { Player } do
					local h = H.hrpOf(p)
					if h then
						local f = floorBelow(g, h.Position)
						table.insert(spots, f)
						for _ = 2, c.count do
							local ang = rng:NextNumber(0, math.pi * 2)
							local at = f + Vector3.new(math.cos(ang), 0, math.sin(ang)) * rng:NextNumber(5, 10)
							local fl = workspace:Raycast(at + Vector3.new(0, 4, 0), Vector3.new(0, -12, 0), g.rp)
							if fl then table.insert(spots, fl.Position) end
						end
					end
				end
				ab.spots = spots
				H.setPhase(g, "fire", c.flight)
				H.fx("MissileFire", g.model, spots, c.flight, c.radius)
			end
		else -- fire: the missiles come down
			if now >= ab.untilT then
				local hit = {} :: { [Player]: boolean }
				for _, s in ab.spots :: { Vector3 } do hitAround(g, G, s, c.radius, hit, c.dmg, c.power, c.up, "missile", 1.2) end
				H.fx("MissileBoom", ab.spots, c.radius)
				H.finish(g, G, 0.4)
			end
		end
	else -- overload
		local c = a.overload
		if ab.phase == "plug" then
			if now >= ab.untilT then
				ab.nextTick = now
				H.setPhase(g, "arc", c.t)
				H.fx("OverloadOn", g.model, c.t, c.range)
			end
		else -- arc
			if now >= ab.nextTick then
				ab.nextTick = now + c.tick
				local core = pos + Vector3.new(0, 3, 0)
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) and (h.Position - core).Magnitude < c.range and sees(g, core, h.Position) then
						G.damagePlayer(p, c.dmg * H.dmgScale(g), 6, core)
						H.fx("ArcHit", g.model, p)
					end
				end
			end
			if now >= ab.untilT then
				H.fx("OverloadOff", g.model)
				H.finish(g, G, 0.5)
			end
		end
	end
	local _ = dt
end

---------------------------------------------------------------------------------------------- step / interrupt / tick / clear
function MM.step(g, G, dt: number, now: number, target: Player?, _thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	local victim = ab.victim :: Player?
	local vh = victim and H.hrpOf(victim) or nil
	local k = a.kind
	if k == "astronaut" then stepAstronaut(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif k == "specimen" then stepSpecimen(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif k == "sentinel" then stepSentinel(g, G, ab, a, dt, now, pos, vh, hoverY)
	else H.finish(g, G, 0.3) end
	local _ = target
end

function MM.interrupt(g)
	local ab = g.ab
	if not ab then return end
	if ab.move == "breach" and ab.phase == "vent" then H.fx("BreachSeal", ab.spot) end
	if ab.move == "overload" and ab.phase == "arc" then H.fx("OverloadOff", g.model) end
	if ab.globs then
		for _, gl in ab.globs :: { Glob } do if gl.part.Parent then gl.part:Destroy() end end
	end
end

-- every frame: the acid pools burn and dry up
function MM.tick(G, now: number)
	for i = #pools, 1, -1 do
		local pl = pools[i]
		if now >= pl.untilT then table.remove(pools, i); continue end
		if now >= pl.nextT then
			pl.nextT = now + pl.tick
			for _, p in H.matchPlayers() do
				local h = H.hrpOf(p)
				if h and not H.warded(p) then
					local off = h.Position - pl.pos
					if Vector3.new(off.X, 0, off.Z).Magnitude < pl.r and off.Y > -2 and off.Y < 6 then
						G.damagePlayer(p, pl.dmg, 0, pl.pos)
						H.fx("AcidBurn", p)
					end
				end
			end
		end
	end
end

function MM.clear()
	table.clear(pools)
	local f = workspace:FindFirstChild("MoonFx")
	if f then f:ClearAllChildren() end
	local _ = Players
end

return MM
