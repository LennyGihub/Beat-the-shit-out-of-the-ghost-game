--!strict
-- BLACKWATER HARBOR's three new monsters' special moves (Shared/Monsters; models: tools/build/harbor_monsters.luau;
-- client: Client/HarborFx). Abilities hands try / step / interrupt / tick / clear over, like Server/CarnivalMonsters:
-- a MOVESET per monster (the moves whose conditions fit, never the last one when another fits; ability.cd keeps
-- plain swipes between them), the move is ab.move, every phase has its own name (Client/GhostAnim poses them).
--   THE DEEP ONE (deepOne):
--     ink      a gurgle (gurgle), he spits a blob of ink (spit): it flies at you; hit = hurt and INKED (player
--              attribute Inked: black ink over the screen for a few seconds, Client/HarborFx)
--     dive     he sinks into the floor (sink), a ripple follows you (swim), stops (rise: get out of the ring!) and he
--              bursts up out of it (burst): everyone in it is thrown up; then he gasps for air (gasp): hit him now
--   THE KEEPER (keeper):
--     beam     he raises his lantern (raise) and its beam sweeps the room (sweep): whoever it touches burns and is
--              slowed (walls and cover stop it)
--     flash    the lantern grows white hot (charge): whoever is LOOKING AT HIM when it flashes is blinded (player
--              attribute Flashed) and he lunges at them (lunge). Look away!
--   THE NETMAN (netman):
--     net      he swings a weighted net (swing) and throws it (throw): caught = held in place (rooted) and hurt
--     anchor   he winds up (windup) and whirls his anchor round him on its chain (spin): it sweeps everything along
--              the floor round him - jump over it or stay right under him
local Players = game:GetService("Players")

local HM = {}
local H: any = nil -- Abilities' helpers
function HM.init(h) H = h end
local rng = Random.new()

HM.KINDS = { deepOne = true, keeper = true, netman = true }

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
	local f = workspace:FindFirstChild("HarborFx") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "HarborFx"; nf.Parent = workspace
		f = nf
	end
	return f :: Folder
end
local function proj(name: string, size: Vector3, color: Color3, at: Vector3, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color; p.Material = Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Position = at; p.Parent = fxFolder()
	return p
end
-- a timed player attribute (Inked / Flashed / Netted): on now, off after t (a later one extends it)
local untilAttr = {} :: { [Player]: { [string]: number } }
local function mark(p: Player, attr: string, t: number)
	untilAttr[p] = untilAttr[p] or {}
	untilAttr[p][attr] = os.clock() + t
	p:SetAttribute(attr, true)
end
-- hit every match player (not warded) within r of pos, once per `hit`
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
local function yawOf(v: Vector3): number return math.atan2(v.X, v.Z) end
local function angDiff(a: number, b: number): number
	local d = (a - b) % (math.pi * 2)
	if d > math.pi then d -= math.pi * 2 end
	return d
end
local function lanternPos(g): Vector3
	local l = g.model:FindFirstChild("Flame", true) :: BasePart?
	return l and l.Position or (g.hrp.Position + Vector3.new(0, 3, 0))
end

---------------------------------------------------------------------------------------------- choosing a move
local function candidates(g, a, thrp: BasePart, dist: number): { string }
	local out = {}
	local k = a.kind
	local eye = g.hrp.Position + Vector3.new(0, 2.5, 0)
	local inSight = sees(g, eye, thrp.Position)
	if k == "deepOne" then
		if dist >= a.ink.min and dist <= a.ink.max and inSight then table.insert(out, "ink") end
		if dist <= a.dive.max then table.insert(out, "dive") end
	elseif k == "keeper" then
		if dist <= a.beam.max then table.insert(out, "beam") end
		if dist <= a.flash.max and inSight then table.insert(out, "flash") end
	elseif k == "netman" then
		if dist >= a.net.min and dist <= a.net.max and inSight then table.insert(out, "net") end
		if dist <= a.anchor.max then table.insert(out, "anchor") end
	end
	return out
end

local function begin(g, G, move: string, a, target: Player, thrp: BasePart)
	g.lastMove = move
	if move == "ink" then
		H.start(g, G, "gurgle", a.ink.wind, { move = move, victim = target })
		H.fx("InkWind", g.model, a.ink.wind)
	elseif move == "dive" then
		H.start(g, G, "sink", a.dive.sink, { move = move, victim = target })
		H.fx("DiveSink", g.model, floorBelow(g, g.hrp.Position))
	elseif move == "beam" then
		local yaw = yawOf(H.flat(thrp.Position - g.hrp.Position))
		local dirn = rng:NextNumber() < 0.5 and -1 or 1
		H.start(g, G, "raise", a.beam.raise, { move = move, victim = target, yaw = yaw, dirn = dirn, nextTick = 0 })
		H.fx("BeamRaise", g.model, a.beam.raise)
	elseif move == "flash" then
		H.start(g, G, "charge", a.flash.charge, { move = move, victim = target })
		H.fx("FlashCharge", g.model, a.flash.charge)
	elseif move == "net" then
		H.start(g, G, "swing", a.net.wind, { move = move, victim = target })
		H.fx("NetWind", g.model, a.net.wind)
	elseif move == "anchor" then
		local a0 = rng:NextNumber(0, math.pi * 2)
		H.start(g, G, "windup", a.anchor.wind, { move = move, victim = target, a0 = a0, hit = {} })
		H.fx("AnchorWarn", g.model, floorBelow(g, g.hrp.Position), a.anchor.radius, a.anchor.wind)
	end
end

function HM.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	if H.warded(target) then return false end
	local list = candidates(g, a, thrp, dist)
	if #list == 0 then return false end
	if #list > 1 and g.lastMove then
		for i = #list, 1, -1 do if list[i] == g.lastMove then table.remove(list, i) end end
	end
	begin(g, G, list[rng:NextInteger(1, #list)], a, target, thrp)
	return g.ab ~= nil
end

-- a flying blob / net: moves, stops on walls, catches the first player it reaches. Returns the player caught, or
-- true when it is spent (wall, floor, life), or nil while it flies.
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
	part.CFrame = CFrame.lookAt(to, to + pr.vel) * CFrame.Angles(0, 0, (now - pr.t0) * 9)
	return nil
end
local function launch(g, ab, name: string, size: Vector3, color: Color3, from: Vector3, at: Vector3, speed: number, shape: Enum.PartType?)
	local d = at - from
	local t = math.max(0.2, d.Magnitude / speed)
	local grav = 30
	-- aimed: flat speed to cover the distance in t, plus what the drop needs
	local vel = Vector3.new(d.X / t, d.Y / t + 0.5 * grav * t, d.Z / t)
	local part = proj(name, size, color, from, shape)
	ab.proj = { part = part, pos = from, vel = vel, t0 = os.clock(), grav = grav }
	return part
end
local function dropProj(ab)
	if ab.proj and ab.proj.part.Parent then (ab.proj.part :: Part):Destroy() end
	ab.proj = nil
end

---------------------------------------------------------------------------------------------- THE DEEP ONE
local function stepDeepOne(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	if ab.move == "ink" then
		local c = a.ink
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if ab.phase == "gurgle" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				local head = g.model:FindFirstChild("Head") :: BasePart?
				local from = (head and head.Position or pos + Vector3.new(0, 3, 0)) + g.hrp.CFrame.LookVector * 1.5
				local at = vh and (vh.Position + vh.AssemblyLinearVelocity * Vector3.new(1, 0, 1) * 0.3) or (pos + g.hrp.CFrame.LookVector * 20)
				local part = launch(g, ab, "InkBlob", Vector3.one * 1.8, Color3.fromRGB(12, 10, 18), from, at, c.speed, Enum.PartType.Ball)
				H.fx("InkFly", part)
				H.setPhase(g, "spit", c.life)
			end
		else
			local r = flyStep(g, ab, dt, now, c.radius, c.life)
			if r ~= nil then
				local at = ab.proj and (ab.proj.part :: Part).Position or pos
				if typeof(r) == "Instance" then
					local p = r :: Player
					G.damagePlayer(p, c.dmg * H.dmgScale(g), 30, at)
					mark(p, "Inked", c.blind)
				end
				-- (a splash: anyone very close is inked too)
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) and (h.Position - at).Magnitude < c.radius * 0.8 then mark(p, "Inked", c.blind * 0.7) end
				end
				H.fx("InkSplat", at)
				dropProj(ab)
				H.finish(g, G, 0.35)
			end
		end
	else -- dive
		local c = a.dive
		if ab.phase == "sink" then
			g.lv.VectorVelocity = H.hover(g, hoverY - 4, Vector3.zero)
			if now >= ab.untilT then
				g.model:SetAttribute("Vanish", true)
				H.setPhase(g, "swim", c.swim)
				H.fx("DiveRing", ab.victim, c.swim, c.radius)
			end
		elseif ab.phase == "swim" then
			-- under the floor, after the target
			g.lv.VectorVelocity = Vector3.zero
			if now >= ab.untilT then
				local spot = vh and floorBelow(g, vh.Position) or floorBelow(g, pos)
				ab.spot = spot
				H.setPhase(g, "rise", c.rise)
				H.fx("DiveLock", spot, c.radius, c.rise)
			end
		elseif ab.phase == "rise" then
			g.lv.VectorVelocity = Vector3.zero
			if now >= ab.untilT then
				local spot = ab.spot :: Vector3
				g.model:PivotTo(CFrame.new(spot + Vector3.new(0, g.hover, 0)) * g.model:GetPivot().Rotation)
				g.model:SetAttribute("Vanish", false)
				hitAround(g, G, spot, c.radius, nil, c.dmg, c.power, c.up, "dive", 1.4)
				H.fx("DiveBurst", spot, c.radius)
				if vh then face(g, vh.Position) end
				H.setPhase(g, "burst", 0.5)
			end
		elseif ab.phase == "burst" then
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then H.setPhase(g, "gasp", c.gasp) end
		else -- gasp: out of the water, gasping for air (the time to hit him)
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then H.finish(g, G, 0.3) end
		end
	end
end

---------------------------------------------------------------------------------------------- THE KEEPER
local function stepKeeper(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.move == "beam" then
		local c = a.beam
		if ab.phase == "raise" then
			if now >= ab.untilT then
				H.setPhase(g, "sweep", c.sweep)
				ab.t0 = now
				H.fx("BeamSweep", g.model, ab.yaw, ab.dirn, c.arc, c.sweep, c.max, c.width)
			end
		else
			-- the beam's yaw now, from one side of the target to the other
			local f = math.clamp((now - ab.t0) / c.sweep, 0, 1)
			local yaw = ab.yaw + ab.dirn * (-c.arc + 2 * c.arc * f)
			g.ao.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(math.sin(yaw), 0, math.cos(yaw))) -- (he turns with it)
			if now >= ab.nextTick then
				ab.nextTick = now + c.tick
				local from = lanternPos(g)
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) then
						local off = h.Position - from
						local fd = Vector3.new(off.X, 0, off.Z)
						-- (the beam points along (sin yaw, 0, cos yaw), like Client/HarborFx draws it)
						if fd.Magnitude < c.max and math.abs(angDiff(yawOf(fd), yaw)) < c.width and sees(g, from, h.Position) then
							G.damagePlayer(p, c.dmg * H.dmgScale(g), 4, from)
							if G.slowPlayer then G.slowPlayer(p, c.slow, 1.2) end
							H.fx("BeamBurn", p)
						end
					end
				end
			end
			if now >= ab.untilT then H.finish(g, G, 0.4) end
		end
	else -- flash
		local c = a.flash
		if ab.phase == "charge" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				-- whoever is looking at him is blinded
				local from = lanternPos(g)
				local blinded = {}
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) then
						local to = from - h.Position
						if to.Magnitude < c.max and h.CFrame.LookVector:Dot(to.Unit) > c.dot and sees(g, from, h.Position + Vector3.new(0, 1.5, 0)) then
							mark(p, "Flashed", c.blind)
							table.insert(blinded, p)
						end
					end
				end
				H.fx("FlashBang", from)
				-- he lunges at the nearest blinded one (or his target, if nobody looked)
				local prey: Player? = nil
				local best = math.huge
				for _, p in blinded do
					local h = H.hrpOf(p)
					if h and (h.Position - pos).Magnitude < best then best = (h.Position - pos).Magnitude; prey = p end
				end
				ab.prey = prey or ab.victim
				ab.hit = {}
				H.setPhase(g, "lunge", c.lunge)
			end
		else -- lunge
			local ph = ab.prey and H.hrpOf(ab.prey) or nil
			if ph then
				local d = H.flat(ph.Position - pos)
				face(g, ph.Position)
				g.lv.VectorVelocity = H.hover(g, hoverY, d * c.speed)
				if (ph.Position - pos).Magnitude < 6 and not ab.hit[ab.prey] then
					ab.hit[ab.prey] = true
					G.hitPlayer(ab.prey, nil, c.dmg * H.dmgScale(g), d * 45 + Vector3.new(0, 22, 0), "flash", true, 1.1)
					H.finish(g, G, 0.5)
					return
				end
			end
			if now >= ab.untilT then H.finish(g, G, 0.4) end
		end
	end
end

---------------------------------------------------------------------------------------------- THE NETMAN
local function stepNetman(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	if ab.move == "net" then
		local c = a.net
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if ab.phase == "swing" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				local hand = g.model:FindFirstChild("RightHand") :: BasePart?
				local from = (hand and hand.Position or pos + Vector3.new(0, 3, 0)) + Vector3.new(0, 1.5, 0)
				local at = vh and (vh.Position + vh.AssemblyLinearVelocity * Vector3.new(1, 0, 1) * 0.35) or (pos + g.hrp.CFrame.LookVector * 20)
				local part = launch(g, ab, "Net", Vector3.new(5, 0.3, 5), Color3.fromRGB(150, 130, 90), from, at, c.speed)
				part.Transparency = 1 -- (Client/HarborFx draws the net round it)
				H.fx("NetFly", part)
				H.setPhase(g, "throw", c.life)
			end
		else
			local r = flyStep(g, ab, dt, now, c.radius, c.life)
			if r ~= nil then
				local at = ab.proj and (ab.proj.part :: Part).Position or pos
				if typeof(r) == "Instance" then
					local p = r :: Player
					if G.rootPlayer then G.rootPlayer(p, c.hold) end
					G.damagePlayer(p, c.dmg * H.dmgScale(g), 10, at)
					mark(p, "Netted", c.hold)
					H.fx("NetHit", p, c.hold)
				else
					H.fx("NetMiss", at)
				end
				dropProj(ab)
				H.finish(g, G, 0.4)
			end
		end
	else -- anchor
		local c = a.anchor
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if ab.phase == "windup" then
			if vh then face(g, vh.Position) end
			if now >= ab.untilT then
				ab.t0 = now
				H.setPhase(g, "spin", c.spin)
				H.fx("AnchorSpin", g.model, c.radius, c.spin, c.turns, ab.a0)
			end
		else
			-- the anchor goes round: whoever is on the floor in its path when it passes is thrown
			local f = math.clamp((now - ab.t0) / c.spin, 0, 1)
			local ang = ab.a0 + f * c.turns * math.pi * 2
			for _, p in H.matchPlayers() do
				local h = H.hrpOf(p)
				if h and not ab.hit[p] and not H.warded(p) then
					local off = h.Position - pos
					local fd = Vector3.new(off.X, 0, off.Z)
					local hum = h.Parent and h.Parent:FindFirstChildOfClass("Humanoid")
					local airborne = hum ~= nil and hum.FloorMaterial == Enum.Material.Air -- (a jump clears it)
					if fd.Magnitude > 4 and fd.Magnitude < c.radius + 2 and not airborne and math.abs(off.Y) < 8 then
						if math.abs(angDiff(math.atan2(fd.Z, fd.X), ang)) < 0.3 then
							ab.hit[p] = true
							G.hitPlayer(p, nil, c.dmg * H.dmgScale(g), Vector3.new(-math.sin(ang), 0, math.cos(ang)) * c.power + H.flat(fd) * 25 + Vector3.new(0, 35, 0), "anchor", true, 1.3)
						end
					end
				end
			end
			g.ao.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(math.cos(ang), 0, math.sin(ang))) -- (he turns with the chain)
			if now >= ab.untilT then H.finish(g, G, 0.5) end
		end
	end
end

---------------------------------------------------------------------------------------------- step / interrupt / tick / clear
function HM.step(g, G, dt: number, now: number, target: Player?, _thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	local victim = ab.victim :: Player?
	local vh = victim and H.hrpOf(victim) or nil
	local k = a.kind
	if k == "deepOne" then stepDeepOne(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif k == "keeper" then stepKeeper(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif k == "netman" then stepNetman(g, G, ab, a, dt, now, pos, vh, hoverY)
	else H.finish(g, G, 0.3) end
	local _ = target
end

function HM.interrupt(g)
	local ab = g.ab
	if not ab then return end
	if ab.move == "dive" then g.model:SetAttribute("Vanish", false) end
	dropProj(ab)
end

-- every frame: the timed marks wear off
function HM.tick(_g, now: number)
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

function HM.clear()
	for p, m in untilAttr do
		for attr in m do if p.Parent then p:SetAttribute(attr, nil) end end
	end
	table.clear(untilAttr)
	local f = workspace:FindFirstChild("HarborFx")
	if f then f:ClearAllChildren() end
	for _, p in Players:GetPlayers() do
		for _, attr in { "Inked", "Flashed", "Netted" } do if p:GetAttribute(attr) then p:SetAttribute(attr, nil) end end
	end
end

return HM
