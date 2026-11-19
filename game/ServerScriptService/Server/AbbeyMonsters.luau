--!strict
-- THE ASHEN ABBEY's three new monsters' special moves (Shared/Monsters; models: tools/build/abbey_monsters.luau;
-- client: Client/AbbeyFx). Abilities hands try / step / interrupt / tick / clear over, like Server/HarborMonsters:
-- a MOVESET per monster (the moves whose conditions fit, never the last one when another fits; ability.cd keeps
-- plain swipes between them), the move is ab.move, every phase has its own name (Client/GhostAnim poses them).
--   THE WEEPING NUN (nun):
--     veil     she pulls her veil down (veilfade) and is gone (stalk: only her black tears fall on the floor, coming
--              toward you); a black pool opens behind you (rise) and she comes up out of it with her claws (slash)
--     hymn     she sings (sing); three times the windows' light falls on the floor in pools round the players
--              (chant: HymnPools), and a moment later each pool bursts into holy fire (HymnBurn): stay out of them
--   THE GRAVEDIGGER (gravedigger):
--     hands    his shovel bites the floor (dig) and a wave of dead hands bursts up along it toward you (wave): caught
--              = held where you stand and hurt; jump it or step out of its lane
--     coffin   he heaves a coffin onto his shoulder (heave) and hurls it at you (throw); where it lands it bursts:
--              everyone near is thrown, and skeletons climb out and run at you (clones: one hit breaks one)
--   THE BELL RINGER (ringer):
--     bell     he hauls on a bell rope (yank); a great bell's shadow follows you (follow), stops (drop: get out!)
--              and the bell falls: under it you are TRAPPED (held, deafened: player attribute Rung) and hurt
--              while it rings (ring)
--     toll     he lifts his own bell (lift) and slams it down (toll): three rings of sound roll out along the floor
--              one after another - jump each one (hit = thrown and deafened)
local Players = game:GetService("Players")

local AM = {}
local H: any = nil -- Abilities' helpers
function AM.init(h) H = h end
local rng = Random.new()

AM.KINDS = { nun = true, gravedigger = true, ringer = true }

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
	local f = workspace:FindFirstChild("AbbeyFx") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "AbbeyFx"; nf.Parent = workspace
		f = nf
	end
	return f :: Folder
end
local function airborne(h: BasePart): boolean
	local hum = h.Parent and h.Parent:FindFirstChildOfClass("Humanoid")
	return hum ~= nil and hum.FloorMaterial == Enum.Material.Air
end
-- a timed player attribute (Rung): on now, off after t (a later one extends it)
local untilAttr = {} :: { [Player]: { [string]: number } }
local function mark(p: Player, attr: string, t: number)
	untilAttr[p] = untilAttr[p] or {}
	local m = untilAttr[p] :: { [string]: number }
	m[attr] = math.max(m[attr] or 0, os.clock() + t)
	p:SetAttribute(attr, true)
end
-- hit every match player (not warded) within r of pos (flat), once per `hit`
local function hitAround(g, G, pos: Vector3, r: number, hit: { [Player]: boolean }?, dmg: number, power: number, up: number, kind: string, ragT: number?): { Player }
	local out = {}
	for _, p in H.matchPlayers() do
		local h = H.hrpOf(p)
		if h and not H.warded(p) and not (hit and hit[p]) then
			local off = h.Position - pos
			if Vector3.new(off.X, 0, off.Z).Magnitude < r and math.abs(off.Y) < 9 then
				if hit then hit[p] = true end
				G.hitPlayer(p, nil, dmg * H.dmgScale(g), H.flat(off) * power + Vector3.new(0, up, 0), kind, true, ragT or 1.2)
				table.insert(out, p)
			end
		end
	end
	return out
end

-- a thrown thing (the coffin): flies along a lobbed arc, stops on walls / the floor, catches the first player it
-- reaches. Returns the player caught, true when it is spent, or nil while it flies.
local function launch(ab, name: string, size: Vector3, color: Color3, from: Vector3, at: Vector3, speed: number): Part
	local d = at - from
	local t = math.max(0.25, d.Magnitude / speed)
	local grav = 40
	local vel = Vector3.new(d.X / t, d.Y / t + 0.5 * grav * t, d.Z / t)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color; p.Material = Enum.Material.WoodPlanks
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Position = from; p.Parent = fxFolder()
	ab.proj = { part = p, pos = from, vel = vel, t0 = os.clock(), grav = grav }
	return p
end
local function flyStep(g, ab, dt: number, now: number, radius: number, life: number): (Player | boolean)?
	local pr = ab.proj
	if not pr then return true end
	local part = pr.part :: Part
	local from = pr.pos :: Vector3
	pr.vel += Vector3.new(0, -pr.grav * dt, 0)
	local to = from + pr.vel * dt
	local hit = workspace:Raycast(from, to - from, g.rp)
	for _, p in H.matchPlayers() do
		local h = H.hrpOf(p)
		if h and not H.warded(p) and (h.Position - to).Magnitude < radius then
			part.Position = to
			return p
		end
	end
	if hit or now - pr.t0 > life then
		part.Position = hit and hit.Position or to
		return true
	end
	pr.pos = to
	part.CFrame = CFrame.lookAt(to, to + pr.vel) * CFrame.Angles(0, 0, (now - pr.t0) * 6)
	return nil
end
local function dropProj(ab)
	if ab.proj and ab.proj.part.Parent then (ab.proj.part :: Part):Destroy() end
	ab.proj = nil
end

-- a skeleton that climbs out of the Gravedigger's coffin (a clone entry: Abilities walks it at the players, one hit
-- breaks it into bones - kind "bone")
local BONE = Color3.fromRGB(226, 216, 190)
local function skeleton(cf: CFrame): Model
	local m = Instance.new("Model")
	m.Name = "Skeleton"
	local function P(name: string, size: Vector3, rel: CFrame, color: Color3?, shape: Enum.PartType?)
		local p = Instance.new("Part")
		p.Name = name; p.Size = size; p.CFrame = cf * rel; p.Color = color or BONE; p.Material = Enum.Material.SmoothPlastic
		if shape then p.Shape = shape end
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
		p.Parent = m
		return p
	end
	local spine = P("UpperTorso", Vector3.new(0.5, 2.4, 0.5), CFrame.new(0, 1.2, 0))
	for k = 0, 3 do P("Rib", Vector3.new(1.7 - k * 0.15, 0.22, 1.0), CFrame.new(0, 2.0 - k * 0.42, -0.1)) end
	P("Pelvis", Vector3.new(1.4, 0.5, 0.7), CFrame.new(0, -0.1, 0))
	P("Head", Vector3.new(1.1, 1.2, 1.1), CFrame.new(0, 3.0, -0.05), nil, Enum.PartType.Ball)
	P("Jaw", Vector3.new(0.8, 0.3, 0.7), CFrame.new(0, 2.45, -0.2))
	for _, s in { -1, 1 } do
		P("Eye", Vector3.new(0.3, 0.3, 0.1), CFrame.new(s * 0.25, 3.05, -0.55), Color3.fromRGB(150, 255, 120))
		P("Arm", Vector3.new(0.3, 2.6, 0.3), CFrame.new(s * 1.05, 1.3, -0.7) * CFrame.Angles(1.25, 0, s * 0.1))
		P("Claw", Vector3.new(0.5, 0.3, 0.5), CFrame.new(s * 1.05, 1.6, -2.0))
		P("Leg", Vector3.new(0.35, 3.2, 0.35), CFrame.new(s * 0.45, -1.8, 0))
	end
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and d.Name == "Eye" then d.Material = Enum.Material.Neon end
	end
	m.PrimaryPart = spine
	m.Parent = workspace
	return m
end

---------------------------------------------------------------------------------------------- choosing a move
local function candidates(g, a, thrp: BasePart, dist: number): { string }
	local out = {}
	local k = a.kind
	local eye = g.hrp.Position + Vector3.new(0, 2.5, 0)
	local inSight = sees(g, eye, thrp.Position)
	if k == "nun" then
		if dist <= a.veil.max then table.insert(out, "veil") end
		if dist <= a.hymn.max then table.insert(out, "hymn") end
	elseif k == "gravedigger" then
		if dist >= a.hands.min and dist <= a.hands.max and inSight then table.insert(out, "hands") end
		if dist >= a.coffin.min and dist <= a.coffin.max and inSight then table.insert(out, "coffin") end
	elseif k == "ringer" then
		if dist <= a.bell.max then table.insert(out, "bell") end
		if dist <= a.toll.max then table.insert(out, "toll") end
	end
	return out
end

local function begin(g, G, move: string, a, target: Player, thrp: BasePart)
	g.lastMove = move
	if move == "veil" then
		H.start(g, G, "veilfade", a.veil.fade, { move = move, victim = target })
		H.fx("VeilFade", g.model, a.veil.fade)
	elseif move == "hymn" then
		H.start(g, G, "sing", a.hymn.sing, { move = move, victim = target, wave = 0, pending = {} })
		H.fx("HymnSing", g.model, a.hymn.sing)
	elseif move == "hands" then
		H.start(g, G, "dig", a.hands.wind, { move = move, victim = target, hit = {} })
		H.fx("HandsDig", g.model, a.hands.wind)
	elseif move == "coffin" then
		H.start(g, G, "heave", a.coffin.wind, { move = move, victim = target })
		H.fx("CoffinHeave", g.model, a.coffin.wind)
	elseif move == "bell" then
		H.start(g, G, "yank", a.bell.wind, { move = move, victim = target, trapped = {} })
		H.fx("BellYank", g.model, a.bell.wind)
	elseif move == "toll" then
		H.start(g, G, "lift", a.toll.wind, { move = move, victim = target, hit = {} })
		H.fx("TollLift", g.model, a.toll.wind)
	end
	local _ = thrp
end

function AM.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	if H.warded(target) then return false end
	local list = candidates(g, a, thrp, dist)
	if #list == 0 then return false end
	if #list > 1 and g.lastMove then
		for i = #list, 1, -1 do if list[i] == g.lastMove then table.remove(list, i) end end
	end
	begin(g, G, list[rng:NextInteger(1, #list)], a, target, thrp)
	local _ = now
	return g.ab ~= nil
end

---------------------------------------------------------------------------------------------- THE WEEPING NUN
-- where she comes up: behind the victim (on the floor, nothing in between), else beside them
local function behind(g, vh: BasePart): Vector3
	local look = H.flat(vh.CFrame.LookVector)
	for _, dir in { -look, H.flat(vh.CFrame.RightVector), -H.flat(vh.CFrame.RightVector), look } do
		local want = vh.Position + dir * 4.5
		if not workspace:Raycast(vh.Position, dir * 5.5, g.rp) then
			local f = workspace:Raycast(want + Vector3.new(0, 1, 0), Vector3.new(0, -10, 0), g.rp)
			if f then return f.Position end
		end
	end
	return floorBelow(g, vh.Position)
end

local function stepNun(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	if ab.move == "veil" then
		local c = a.veil
		if ab.phase == "veilfade" then
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				g.model:SetAttribute("Vanish", true)
				H.setPhase(g, "stalk", c.walk)
				H.fx("VeilStalk", floorBelow(g, pos), ab.victim, c.walk)
			end
		elseif ab.phase == "stalk" then
			-- unseen, she walks toward you (her tears show where)
			local to = vh and H.flat(vh.Position - pos) or Vector3.zero
			g.lv.VectorVelocity = H.hover(g, hoverY, to * 14)
			if now >= ab.untilT then
				local spot = vh and behind(g, vh) or floorBelow(g, pos)
				ab.spot = spot
				H.setPhase(g, "rise", c.warn)
				H.fx("VeilPool", spot, c.warn)
			end
		elseif ab.phase == "rise" then
			g.lv.VectorVelocity = Vector3.zero
			if now >= ab.untilT then
				local spot = ab.spot :: Vector3
				local look = vh and H.flat(vh.Position - spot) or H.flat(g.hrp.CFrame.LookVector)
				g.model:PivotTo(CFrame.lookAt(spot + Vector3.new(0, g.hover, 0), spot + Vector3.new(0, g.hover, 0) + look))
				g.ao.CFrame = CFrame.lookAt(Vector3.zero, look)
				g.model:SetAttribute("Vanish", false)
				-- her claws: whoever is in front of her, close
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) then
						local off = h.Position - spot
						local fd = Vector3.new(off.X, 0, off.Z)
						if fd.Magnitude < 7 and math.abs(off.Y) < 8 and (fd.Magnitude < 2.5 or fd.Unit:Dot(look) > 0.1) then
							G.hitPlayer(p, nil, c.dmg * H.dmgScale(g), H.flat(fd) * c.power + Vector3.new(0, c.up, 0), "veil", true, 1.1)
						end
					end
				end
				H.fx("VeilStrike", spot, look)
				H.setPhase(g, "slash", 0.45)
			end
		else -- slash
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then H.finish(g, G, 0.35) end
		end
	else -- hymn
		local c = a.hymn
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if ab.phase == "sing" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				ab.nextWave = now
				H.setPhase(g, "chant", c.waves * c.gap + c.warn + 0.3)
			end
		else -- chant
			if ab.wave < c.waves and now >= ab.nextWave then
				ab.wave += 1
				ab.nextWave = now + c.gap
				local spots = {} :: { Vector3 }
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) then
						-- (a little ahead of where they are going)
						local lead = h.AssemblyLinearVelocity * Vector3.new(1, 0, 1) * 0.35
						table.insert(spots, floorBelow(g, h.Position + lead))
					end
				end
				local n = #spots
				for i = 1, math.min(n, 4) * c.extra do
					local base = spots[((i - 1) % n) + 1]
					local ang = rng:NextNumber(0, math.pi * 2)
					local at = base + Vector3.new(math.cos(ang), 0, math.sin(ang)) * rng:NextNumber(7, 15)
					local f = workspace:Raycast(at + Vector3.new(0, 4, 0), Vector3.new(0, -12, 0), g.rp)
					if f and not workspace:Raycast(base + Vector3.new(0, 2, 0), (at - base), g.rp) then table.insert(spots, f.Position) end
				end
				table.insert(ab.pending, { t = now + c.warn, spots = spots })
				H.fx("HymnPools", spots, c.radius, c.warn, ab.wave)
			end
			for i = #ab.pending, 1, -1 do
				local w = ab.pending[i]
				if now >= w.t then
					table.remove(ab.pending, i)
					local hit = {} :: { [Player]: boolean }
					for _, s in w.spots do
						for _, p in H.matchPlayers() do
							local h = H.hrpOf(p)
							if h and not hit[p] and not H.warded(p) then
								local off = h.Position - s
								if Vector3.new(off.X, 0, off.Z).Magnitude < c.radius and off.Y > -3 and off.Y < 10 then
									hit[p] = true
									G.damagePlayer(p, c.dmg * H.dmgScale(g), 26, s)
								end
							end
						end
					end
					H.fx("HymnBurn", w.spots, c.radius)
				end
			end
			if ab.wave >= c.waves and #ab.pending == 0 then H.finish(g, G, 0.4) end
		end
	end
	local _ = dt
end

---------------------------------------------------------------------------------------------- THE GRAVEDIGGER
local function stepGravedigger(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.move == "hands" then
		local c = a.hands
		if ab.phase == "dig" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				local dir = vh and H.flat(vh.Position - pos) or H.flat(g.hrp.CFrame.LookVector)
				ab.dir = dir
				ab.origin = floorBelow(g, pos + dir * 3)
				ab.t0 = now
				-- (the lane stops at the first wall)
				local wall = workspace:Raycast(ab.origin + Vector3.new(0, 2, 0), dir * c.len, g.rp)
				ab.len = wall and math.max(6, (wall.Position - ab.origin).Magnitude - 1) or c.len
				H.setPhase(g, "wave", ab.len / c.speed + 0.2)
				H.fx("HandsWave", ab.origin, dir, c.speed, ab.len, c.width)
			end
		else -- wave
			local front = (now - ab.t0) * c.speed
			local dir, o = ab.dir :: Vector3, ab.origin :: Vector3
			for _, p in H.matchPlayers() do
				local h = H.hrpOf(p)
				if h and not ab.hit[p] and not H.warded(p) and not airborne(h) then
					local off = h.Position - o
					local along = off:Dot(dir)
					local side = (Vector3.new(off.X, 0, off.Z) - dir * along).Magnitude
					if along > front - 3.5 and along < front + 1 and along < ab.len and side < c.width / 2 + 1 and math.abs(off.Y) < 7 then
						ab.hit[p] = true
						if G.rootPlayer then G.rootPlayer(p, c.hold) end
						G.damagePlayer(p, c.dmg * H.dmgScale(g), 8, h.Position - dir)
						H.fx("HandsGrab", p, c.hold)
					end
				end
			end
			if now >= ab.untilT then H.finish(g, G, 0.35) end
		end
	else -- coffin
		local c = a.coffin
		if ab.phase == "heave" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				local from = pos + Vector3.new(0, 4.5, 0) + g.hrp.CFrame.LookVector * 1.5
				local at = vh and floorBelow(g, vh.Position + vh.AssemblyLinearVelocity * Vector3.new(1, 0, 1) * 0.3) or (pos + g.hrp.CFrame.LookVector * 20)
				local p = launch(ab, "Coffin", Vector3.new(2.6, 1.4, 6.2), Color3.fromRGB(70, 44, 30), from, at, c.speed)
				H.fx("CoffinFly", p)
				H.setPhase(g, "throw", 2.4)
			end
		else -- throw
			local r = flyStep(g, ab, dt, now, 3.2, 2.4)
			if r ~= nil then
				local at = ab.proj and (ab.proj.part :: Part).Position or pos
				local land = floorBelow(g, at + Vector3.new(0, 1, 0))
				hitAround(g, G, land, c.radius, nil, c.dmg, c.power, c.up, "coffin", 1.2)
				H.fx("CoffinBurst", land, c.radius)
				dropProj(ab)
				-- the dead climb out
				local list = H.clones()
				for i = 1, c.skel do
					local ang = (i / c.skel) * math.pi * 2 + rng:NextNumber(-0.4, 0.4)
					local spot = land + Vector3.new(math.cos(ang), 0, math.sin(ang)) * 2.5
					local f = workspace:Raycast(spot + Vector3.new(0, 3, 0), Vector3.new(0, -8, 0), g.rp)
					local base = f and f.Position or land
					local sk = skeleton(CFrame.new(base + Vector3.new(0, 3.6, 0)) * CFrame.Angles(0, ang, 0))
					sk:SetAttribute("Clone", true)
					table.insert(list, { model = sk, untilT = now + c.life, from = now + 0.8, speed = c.skSpeed, dmg = c.skDmg * H.dmgScale(g), hover = 3.6, kind = "bone" })
					H.fx("CloneSpawn", base + Vector3.new(0, 1, 0), "bone")
				end
				H.finish(g, G, 0.4)
			end
		end
	end
end

---------------------------------------------------------------------------------------------- THE BELL RINGER
local function stepRinger(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.move == "bell" then
		local c = a.bell
		if ab.phase == "yank" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				H.setPhase(g, "follow", c.follow)
				H.fx("BellShadow", ab.victim, c.follow, c.radius)
			end
		elseif ab.phase == "follow" then
			if now >= ab.untilT then
				ab.spot = vh and floorBelow(g, vh.Position) or floorBelow(g, pos)
				H.setPhase(g, "drop", c.lock)
				H.fx("BellLock", ab.spot, c.radius, c.lock)
			end
		elseif ab.phase == "drop" then
			if now >= ab.untilT then
				local spot = ab.spot :: Vector3
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) then
						local off = h.Position - spot
						if Vector3.new(off.X, 0, off.Z).Magnitude < c.radius and off.Y > -3 and off.Y < 9 then
							ab.trapped[p] = true
							if G.rootPlayer then G.rootPlayer(p, c.trap) end
							G.damagePlayer(p, c.dmg * H.dmgScale(g), 4, spot)
							mark(p, "Rung", c.trap + 0.6)
						end
					end
				end
				ab.nextTick = now + c.tick
				H.fx("BellDrop", spot, c.radius, c.trap)
				H.setPhase(g, "ring", c.trap)
			end
		else -- ring: the trapped ones are hurt while it rings
			if now >= ab.nextTick then
				ab.nextTick = now + c.tick
				for p in ab.trapped do
					local h = H.hrpOf(p)
					if h and not H.warded(p) and (h.Position - ab.spot).Magnitude < c.radius + 3 then
						G.damagePlayer(p, c.tickDmg * H.dmgScale(g), 0, ab.spot)
					end
				end
			end
			if now >= ab.untilT then
				H.fx("BellRise", ab.spot, c.radius)
				H.finish(g, G, 0.3)
			end
		end
	else -- toll
		local c = a.toll
		if ab.phase == "lift" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				ab.t0 = now
				ab.center = floorBelow(g, pos + g.hrp.CFrame.LookVector * 2)
				for i = 1, c.rings do ab.hit[i] = {} end
				H.setPhase(g, "toll", (c.rings - 1) * c.gap + c.range / c.speed + 0.1)
				H.fx("TollSlam", g.model, ab.center, c.rings, c.gap, c.speed, c.range)
			end
		else -- toll: each ring rolls out along the floor; whoever is on the floor where it passes is thrown
			local center = ab.center :: Vector3
			for i = 1, c.rings do
				local r = (now - (ab.t0 + (i - 1) * c.gap)) * c.speed
				if r > 0 and r < c.range then
					for _, p in H.matchPlayers() do
						local h = H.hrpOf(p)
						local hit = ab.hit[i]
						if h and not hit[p] and not H.warded(p) and not airborne(h) then
							local off = h.Position - center
							local d = Vector3.new(off.X, 0, off.Z).Magnitude
							if d > r - 2.5 and d < r + 1 and math.abs(off.Y) < 7 then
								hit[p] = true
								G.hitPlayer(p, nil, c.dmg * H.dmgScale(g), H.flat(off) * c.power + Vector3.new(0, c.up, 0), "toll", true, 1)
								mark(p, "Rung", c.deaf)
							end
						end
					end
				end
			end
			if now >= ab.untilT then H.finish(g, G, 0.4) end
		end
	end
	local _ = dt
end

---------------------------------------------------------------------------------------------- step / interrupt / tick / clear
function AM.step(g, G, dt: number, now: number, target: Player?, _thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	local victim = ab.victim :: Player?
	local vh = victim and H.hrpOf(victim) or nil
	local k = a.kind
	if k == "nun" then stepNun(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif k == "gravedigger" then stepGravedigger(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif k == "ringer" then stepRinger(g, G, ab, a, dt, now, pos, vh, hoverY)
	else H.finish(g, G, 0.3) end
	local _ = target
end

function AM.interrupt(g)
	local ab = g.ab
	if not ab then return end
	if ab.move == "veil" then g.model:SetAttribute("Vanish", false) end
	if ab.move == "bell" and ab.spot and (ab.phase == "ring" or ab.phase == "drop") then H.fx("BellRise", ab.spot, 6) end
	dropProj(ab)
end

-- every frame: the timed marks wear off
function AM.tick(_g, now: number)
	for p, m in untilAttr do
		if not p.Parent then untilAttr[p] = nil; continue end
		for attr, t in m do
			if now >= t or not p:GetAttribute("InMatch") then
				m[attr] = nil
				p:SetAttribute(attr, nil)
			end
		end
	end
end

function AM.clear()
	for p, m in untilAttr do
		for attr in m do if p.Parent then p:SetAttribute(attr, nil) end end
	end
	table.clear(untilAttr)
	local f = workspace:FindFirstChild("AbbeyFx")
	if f then f:ClearAllChildren() end
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("Rung") then p:SetAttribute("Rung", nil) end
	end
end

return AM
