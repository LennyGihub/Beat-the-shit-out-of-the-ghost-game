--!strict
-- CAMP HOLLOWMERE's four monsters' special moves (Shared/Monsters; models: tools/build/camp_monsters.luau; client:
-- Client/CampFx). Abilities hands try / step / interrupt / clear over (like the Caller's and the Knight's); the
-- Scarecrow's chase goes through chaseHold (Ghost's Chase state).
-- Every monster has a MOVESET: Abilities asks `try` once its shared cooldown (ability.cd) is over; the moves whose
-- conditions are met are the candidates, the one used last is left out when another fits, and between two moves
-- the monster just fights (swipes, lunges): never one move over and over. The move is ab.move; each move's phases
-- have their own names (the client poses by Ability + AbilityPhase).
--   THE ANTLERED ONE (rafterDrop):
--     drop    up into the rafters (climb), following you from up there (lurk), a red ring (warn), he drops (fall),
--             dazed on one knee (daze): the time to hit him
--     charge  head down (lower: a red lane on the floor shows where), a straight charge (charge): everyone in the way
--             gored and thrown, the furniture smashed, inside walls burst; an outside wall stops him: his antlers
--             are STUCK in it for a while (stuck), the time to hit him; or he runs out and skids (skid)
--   THE LAKE WITCH (hookPull):
--     hook    the hook thrown (wind, throw: walls stop it), the one caught dragged to the water (pull) and held under
--     grasp   black water wells up under you (summon), then drowned hands come up and grab (hold): rooted + hurt
--     flood   every floodEvery-th move: black water over the whole floor, everyone in it slowed
--   THE BURNED COUNSELOR (firebrand):
--     torch   the torch lobbed where you are going (wind, throw): the wood catches fire (Server/Fire; fireImmune)
--     run     a scream (scream), then he runs at you (run) leaving a trail of fire; a wall or the end of his breath
--             stops him, bent over panting (pant): the time to hit him
--   THE SCARECROW (scareSwap): decoys at the barn's ScarecrowSpots, frozen while anyone looks at him (chaseHold),
--     swaps places with a decoy every swapEvery seconds; when nobody is looking he comes at you, and:
--     crows   arms out, the crows gather on him (gather), then burst at you in a cone (crows): pecked + blinded.
--             Stare at him too long and he sends them anyway (to make you look away).
--     sickle  his sickle thrown like a boomerang (windup, throw: out past you and back), cutting whoever it passes
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)
local Ragdoll = require(script.Parent.Ragdoll)

local CM = {}
local H: any = nil -- Abilities' helpers
function CM.init(h) H = h end
local rng = Random.new()
local floodUntil, floodSlow, nextSlowTick = 0, 0.6, 0

CM.KINDS = { rafterDrop = true, hookPull = true, firebrand = true, scareSwap = true }

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
local function live(): Instance? return workspace:FindFirstChild("Mansion") end
-- a wall (the building itself, not its furniture) within len studs ahead: what stops a charge / a run
local function wallAhead(g, pos: Vector3, dir: Vector3, len: number): RaycastResult?
	local r = workspace:Raycast(pos + Vector3.new(0, 1, 0), dir * len, g.rp)
	if not r or r.Normal.Y > 0.6 then return nil end
	local m = live()
	local st = m and m:FindFirstChild("Structure")
	if st and r.Instance:IsDescendantOf(st) then return r end
	return nil
end
local function getFire(): any return require(script.Parent.Fire) :: any end

-- hit every match player (not warded) within r of pos and at about its height, each once per `hit` table
local function hitAround(g, G, pos: Vector3, r: number, hit: { [Player]: boolean }?, dmg: number, power: number, up: number, kind: string, ragT: number?)
	for _, p in H.matchPlayers() do
		local h = H.hrpOf(p)
		if h and not H.warded(p) and not (hit and hit[p]) then
			local off = h.Position - pos
			if Vector3.new(off.X, 0, off.Z).Magnitude < r and math.abs(off.Y) < 8 then
				if hit then hit[p] = true end
				local dir = H.flat(off)
				G.hitPlayer(p, nil, dmg * H.dmgScale(g), dir * power + Vector3.new(0, up, 0), kind, true, ragT or 1.2)
			end
		end
	end
end

---------------------------------------------------------------------------------------------- choosing a move
local function candidates(g, a, thrp: BasePart, dist: number): { string }
	local out = {}
	local k = a.kind
	local hand = g.hrp.Position + Vector3.new(0, 2, 0)
	local inSight = sees(g, hand, thrp.Position)
	if k == "rafterDrop" then
		if dist >= a.min then table.insert(out, "drop") end
		local c = a.charge
		if c and dist >= c.min and dist <= c.max and inSight then table.insert(out, "charge") end
	elseif k == "hookPull" then
		if dist >= a.min and dist <= a.max and inSight then table.insert(out, "hook") end
		local c = a.grasp
		if c and dist <= c.max then table.insert(out, "grasp") end
	elseif k == "firebrand" then
		if dist >= a.min and dist <= a.max then table.insert(out, "torch") end
		local c = a.run
		if c and dist >= c.min and dist <= c.max and inSight then table.insert(out, "run") end
	elseif k == "scareSwap" then
		local c = a.crows
		if c and dist <= c.range and inSight then table.insert(out, "crows") end
		local s = a.sickle
		if s and dist >= s.min and dist <= s.max and inSight then table.insert(out, "sickle") end
	end
	return out
end

local function begin(g, G, move: string, a, target: Player, thrp: BasePart)
	g.lastMove = move
	if move == "drop" then
		local up = workspace:Raycast(g.hrp.Position, Vector3.new(0, 60, 0), g.rp)
		local ceil = up and up.Position.Y or (g.hrp.Position.Y + 18)
		local floorY = floorBelow(g, g.hrp.Position).Y
		-- (hanging under the rafters: his feet up there, his head down)
		H.start(g, G, "climb", a.climb, { move = move, victim = target, hangY = math.max(floorY + 12, ceil - 4), floorY = floorY })
		H.fx("AntlerClimb", g.model, a.climb)
	elseif move == "charge" then
		local c = a.charge
		local dir = H.flat(thrp.Position - g.hrp.Position)
		H.start(g, G, "lower", c.wind, { move = move, victim = target, dir = dir, hit = {} })
		H.fx("ChargeLine", g.model, floorBelow(g, g.hrp.Position), dir, math.min(c.speed * c.time, 90), c.wind)
	elseif move == "flood" then
		H.start(g, G, "flood", 1.3, { move = move })
		H.fx("FloodCall", g.model, 1.3)
	elseif move == "hook" then
		H.start(g, G, "wind", a.wind, { move = move, victim = target })
		H.fx("HookWind", g.model, a.wind)
	elseif move == "grasp" then
		local c = a.grasp
		local spot = floorBelow(g, thrp.Position)
		H.start(g, G, "summon", c.warn, { move = move, victim = target, spot = spot })
		H.fx("GraspWarn", g.model, spot, c.radius, c.warn)
	elseif move == "torch" then
		H.start(g, G, "wind", a.wind, { move = move, victim = target })
		H.fx("TorchWind", g.model, a.wind)
	elseif move == "run" then
		local c = a.run
		H.start(g, G, "scream", c.wind, { move = move, victim = target, hit = {}, lastFire = g.hrp.Position })
		H.fx("CounselorScream", g.model, c.wind)
	elseif move == "crows" then
		local c = a.crows
		H.start(g, G, "gather", c.wind, { move = move, victim = target })
		H.fx("CrowsGather", g.model, c.wind)
	elseif move == "sickle" then
		local s = a.sickle
		H.start(g, G, "windup", s.wind, { move = move, victim = target })
		H.fx("SickleWind", g.model, s.wind)
	end
end

---------------------------------------------------------------------------------------------- try
function CM.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	if H.warded(target) then return false end
	-- the Lake Witch: every floodEvery-th move is the flood (the moves in between count)
	if a.kind == "hookPull" and (g.movesSinceFlood or 0) >= (a.floodEvery or 3) - 1 and now > floodUntil then
		g.movesSinceFlood = 0
		begin(g, G, "flood", a, target, thrp)
		return true
	end
	local list = candidates(g, a, thrp, dist)
	if #list == 0 then return false end
	-- not the same move twice in a row when another one fits
	if #list > 1 and g.lastMove then
		for i = #list, 1, -1 do if list[i] == g.lastMove then table.remove(list, i) end end
	end
	local move = list[rng:NextInteger(1, #list)]
	if a.kind == "hookPull" then g.movesSinceFlood = (g.movesSinceFlood or 0) + 1 end
	begin(g, G, move, a, target, thrp)
	return true
end

---------------------------------------------------------------------------------------------- the Antlered One
local function stepDrop(g, G, ab, a, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	if ab.phase == "climb" then
		g.lv.VectorVelocity = Vector3.new(0, (ab.hangY - pos.Y) * 5, 0)
		if now >= ab.untilT then H.setPhase(g, "lurk", a.lurk) end
	elseif ab.phase == "lurk" then
		-- up in the rafters, following his target across the room
		local v = Vector3.zero
		if vh then
			local d = Vector3.new(vh.Position.X - pos.X, 0, vh.Position.Z - pos.Z)
			v = d.Magnitude > 1 and d.Unit * math.min(a.lurkSpeed, d.Magnitude * 3) or Vector3.zero
			face(g, vh.Position)
		end
		g.lv.VectorVelocity = Vector3.new(v.X, (ab.hangY - pos.Y) * 5, v.Z)
		if now >= ab.untilT then
			local spot = vh and floorBelow(g, vh.Position) or Vector3.new(pos.X, ab.floorY, pos.Z)
			ab.spot = spot
			H.setPhase(g, "warn", a.warn)
			H.fx("DropWarn", spot, a.radius, a.warn)
		end
	elseif ab.phase == "warn" then
		local spot = ab.spot :: Vector3
		local d = Vector3.new(spot.X - pos.X, 0, spot.Z - pos.Z)
		g.lv.VectorVelocity = Vector3.new(d.X * 6, (ab.hangY - pos.Y) * 5, d.Z * 6)
		if now >= ab.untilT then H.setPhase(g, "fall", 0.8) end
	elseif ab.phase == "fall" then
		local spot = ab.spot :: Vector3
		local d = Vector3.new(spot.X - pos.X, 0, spot.Z - pos.Z)
		g.lv.VectorVelocity = Vector3.new(d.X * 6, -150, d.Z * 6)
		if pos.Y <= spot.Y + g.hover + 0.6 or now >= ab.untilT then
			-- THE LANDING: everyone in the ring is hit and thrown out of it, the furniture with them
			hitAround(g, G, spot, a.radius, nil, a.dmg, a.power, 38, "drop", 1.4)
			for _, m in Furniture.near(spot, a.radius) do
				local dir = H.flat(m:GetPivot().Position - spot)
				Furniture.smash(m, dir * 60 + Vector3.new(0, 40, 0), 90)
			end
			H.fx("DropLand", spot, a.radius)
			H.setPhase(g, "daze", a.daze)
		end
	elseif ab.phase == "daze" then
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if now >= ab.untilT then H.finish(g, G, 0.4) end
	end
end

local function stepCharge(g, G, ab, a, now: number, pos: Vector3, hoverY: number)
	local c = a.charge
	local dir = ab.dir :: Vector3
	if ab.phase == "lower" then
		-- head down, pawing the floor: the lane is on the floor
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		face(g, pos + dir * 10)
		if now >= ab.untilT then
			H.setPhase(g, "charge", c.time)
			H.fx("ChargeGo", g.model, c.time)
		end
	elseif ab.phase == "charge" then
		face(g, pos + dir * 10)
		-- what is in front of the antlers: an inside wall bursts, anything else (an outside wall, a post) stops him
		local ahead = wallAhead(g, pos, dir, 6)
		if ahead then
			if Ragdoll.breakWalls(ahead.Position + Vector3.new(0, 2, 0), dir * 130, 9, 6) > 0 then
				H.fx("ChargeSmash", ahead.Position)
			else
				H.fx("AntlersStuck", g.model, ahead.Position, c.stuck)
				H.setPhase(g, "stuck", c.stuck)
				g.lv.VectorVelocity = Vector3.zero
				return
			end
		end
		g.lv.VectorVelocity = H.hover(g, hoverY, dir * c.speed)
		for _, m in Furniture.near(pos + dir * 3, 7) do Furniture.smash(m, dir * c.speed + Vector3.new(0, 34, 0), 120) end
		hitAround(g, G, pos + dir * 2, 7, ab.hit, c.dmg, c.power, 30, "gore", 1.6)
		if now >= ab.untilT then H.setPhase(g, "skid", 0.7) end
	elseif ab.phase == "stuck" then
		-- antlers caught in the wall: he thrashes to pull them out
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if now >= ab.untilT then H.finish(g, G, 0.4) end
	else -- skid: sliding to a stop
		g.lv.VectorVelocity = H.hover(g, hoverY, dir * 18 * math.max(0, ab.untilT - now))
		if now >= ab.untilT then H.finish(g, G, 0.4) end
	end
end

---------------------------------------------------------------------------------------------- the Lake Witch
local function stepHook(g, G, ab, a, dt: number, now: number, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	local victim = ab.victim :: Player?
	if ab.phase == "flood" then
		-- arms up: the water comes
		if now >= ab.untilT then
			floodUntil = now + a.flood
			floodSlow = a.floodSlow
			H.fx("FloodStart", a.flood)
			H.finish(g, G, 0.3)
		end
	elseif ab.phase == "wind" then
		if vh then face(g, vh.Position) end
		if now >= ab.untilT then
			local from = g.hrp.Position + Vector3.new(0, 2, 0)
			local aim = vh and (vh.Position - from) or g.hrp.CFrame.LookVector
			ab.hook = from
			ab.dir = aim.Magnitude > 0.1 and aim.Unit or Vector3.new(0, 0, -1)
			ab.victim = nil
			H.setPhase(g, "throw", (a.max + 6) / a.hookSpeed)
			H.fx("HookThrow", g.model, from, ab.dir, a.hookSpeed, a.max + 6)
		end
	elseif ab.phase == "throw" then
		local step = a.hookSpeed * dt
		local nextPos = ab.hook + ab.dir * step
		local r = workspace:Raycast(ab.hook, ab.dir * step, g.rp)
		if r then
			H.fx("HookMiss", g.model, r.Position)
			H.finish(g, G, 0.6)
			return
		end
		ab.hook = nextPos
		for _, p in H.matchPlayers() do
			local h = H.hrpOf(p)
			if h and not H.warded(p) and (h.Position - nextPos).Magnitude < 4 then
				-- caught: dragged toward the water
				local dest = g.hrp.Position
				local best = math.huge
				local ws = live() and (live() :: Instance):FindFirstChild("WaterSpots")
				if ws then
					for _, w in ws:GetChildren() do
						if w:IsA("BasePart") then
							local d = (w.Position - h.Position).Magnitude
							if d < best then best, dest = d, w.Position end
						end
					end
				end
				ab.victim = p
				H.setPhase(g, "pull", a.pull)
				Remotes.Fx:FireClient(p, "HookPull", dest, a.pull, a.pullSpeed)
				H.fx("HookCatch", g.model, p, a.pull)
				return
			end
		end
		if now >= ab.untilT then
			H.fx("HookMiss", g.model, nextPos)
			H.finish(g, G, 0.6)
		end
	elseif ab.phase == "pull" then
		if vh then face(g, vh.Position) end
		if now >= ab.untilT then
			-- held under: drowning
			if victim and vh then
				G.damagePlayer(victim, a.dmg * H.dmgScale(g), 40, vh.Position)
				H.fx("HookDrown", vh.Position)
			end
			H.finish(g, G, 0.5)
		end
	end
end

local function stepGrasp(g, G, ab, a, now: number, vh: BasePart?, hoverY: number)
	local c = a.grasp
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if vh then face(g, vh.Position) end
	if ab.phase == "summon" and now >= ab.untilT then
		-- the hands come up: everyone still in the ring is grabbed (held in place) and pulled at
		local spot = ab.spot :: Vector3
		for _, p in H.matchPlayers() do
			local h = H.hrpOf(p)
			if h and not H.warded(p) then
				local off = h.Position - spot
				if Vector3.new(off.X, 0, off.Z).Magnitude < c.radius and math.abs(off.Y) < 7 then
					if G.rootPlayer then G.rootPlayer(p, c.hold) end
					G.damagePlayer(p, c.dmg * H.dmgScale(g), 20, spot)
				end
			end
		end
		H.fx("GraspHands", spot, c.radius, c.hold)
		H.setPhase(g, "hold", c.hold * 0.6)
	elseif ab.phase == "hold" and now >= ab.untilT then
		H.finish(g, G, 0.4)
	end
end

---------------------------------------------------------------------------------------------- the Burned Counselor
local function stepTorch(g, G, ab, a, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.phase == "wind" then
		if vh then face(g, vh.Position) end
		if now >= ab.untilT then
			-- lobbed at where the target is going
			local spot = vh and floorBelow(g, vh.Position + vh.AssemblyLinearVelocity * Vector3.new(1, 0, 1) * 0.4) or floorBelow(g, pos + g.hrp.CFrame.LookVector * 12)
			ab.spot = spot
			H.setPhase(g, "throw", a.flight)
			H.fx("TorchThrow", g.model, g.hrp.Position + Vector3.new(1, 3, 0), spot, a.flight)
		end
	elseif ab.phase == "throw" and now >= ab.untilT then
		local spot = ab.spot :: Vector3
		getFire().ignite(spot + Vector3.new(0, 0.5, 0), a.radius, nil, a.fires, true)
		H.fx("TorchLand", spot)
		-- anyone right where it lands is burnt at once
		for _, p in H.matchPlayers() do
			local h = H.hrpOf(p)
			if h and (h.Position - spot).Magnitude < 4 then G.damagePlayer(p, a.dmg * H.dmgScale(g), nil, spot) end
		end
		H.finish(g, G, 0.4)
	end
end

local function stepRun(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	local c = a.run
	if ab.phase == "scream" then
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if vh then face(g, vh.Position) end
		if now >= ab.untilT then
			ab.dir = vh and H.flat(vh.Position - pos) or H.flat(g.hrp.CFrame.LookVector)
			H.setPhase(g, "run", c.time)
		end
	elseif ab.phase == "run" then
		-- he runs at you, turning slowly (you can sidestep him), the floor catching fire behind him
		local want = vh and H.flat(vh.Position - pos) or ab.dir
		local dir = H.flat((ab.dir :: Vector3):Lerp(want, 1 - math.exp(-dt * c.turn)))
		ab.dir = dir
		face(g, pos + dir * 10)
		if wallAhead(g, pos, dir, 5) then
			H.fx("CounselorPant", g.model, c.pant)
			H.setPhase(g, "pant", c.pant)
			return
		end
		g.lv.VectorVelocity = H.hover(g, hoverY, dir * c.speed)
		for _, m in Furniture.near(pos + dir * 3, 5) do Furniture.smash(m, dir * c.speed + Vector3.new(0, 26, 0), 80) end
		if (pos - ab.lastFire).Magnitude > c.fireEvery then
			ab.lastFire = pos
			getFire().ignite(floorBelow(g, pos) + Vector3.new(0, 0.5, 0), 3, nil, 1, true)
		end
		hitAround(g, G, pos, 5.5, ab.hit, c.dmg, c.power, 26, "burnrun", 1.3)
		if now >= ab.untilT then
			H.fx("CounselorPant", g.model, c.pant)
			H.setPhase(g, "pant", c.pant)
		end
	else
		-- out of breath: bent over, hands on his knees
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if now >= ab.untilT then H.finish(g, G, 0.3) end
	end
end

---------------------------------------------------------------------------------------------- the Scarecrow
local function stepCrows(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	local c = a.crows
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.phase == "gather" then
		if vh then face(g, vh.Position) end
		if now >= ab.untilT then
			local to = vh and (vh.Position - pos) or g.hrp.CFrame.LookVector
			ab.dir = to.Magnitude > 0.1 and to.Unit or Vector3.new(0, 0, -1)
			ab.blinded = {}
			H.setPhase(g, "crows", c.time)
			H.fx("Crows", g.model, ab.dir, c.time, ab.range or c.range)
		end
	elseif ab.phase == "crows" then
		-- everyone in the cone is pecked (a little every 0.3 s: no knockdowns, the damage is small; the blinding is
		-- what matters) and blinded, once
		local tick = now >= (ab.nextPeck or 0)
		if tick then ab.nextPeck = now + 0.3 end
		for _, p in H.matchPlayers() do
			local h = H.hrpOf(p)
			if h and not H.warded(p) then
				local to = h.Position - pos
				if to.Magnitude < (ab.range or c.range) and to.Magnitude > 0.1 and to.Unit:Dot(ab.dir) > c.cone then
					if tick then G.damagePlayer(p, c.dps * 0.3 * H.dmgScale(g), 2, Vector3.zero) end
					if not ab.blinded[p] then
						ab.blinded[p] = true
						Remotes.Fx:FireClient(p, "Blinded", c.blind)
						-- (while blinded they can't hold him still with a look)
						local mark = now
						p:SetAttribute("Blinded", mark)
						task.delay(c.blind, function() if p:GetAttribute("Blinded") == mark then p:SetAttribute("Blinded", nil) end end)
					end
				end
			end
		end
		if now >= ab.untilT then H.finish(g, G, 0.4) end
	end
end

local function stepSickle(g, G, ab, a, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	local s = a.sickle
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.phase == "windup" then
		if vh then face(g, vh.Position) end
		if now >= ab.untilT then
			local from = pos + Vector3.new(0, 1.5, 0)
			local to = vh and vh.Position or (from + g.hrp.CFrame.LookVector * s.max)
			local d = to - from
			to = from + (d.Magnitude > 0.1 and d.Unit or g.hrp.CFrame.LookVector) * math.min(s.max, d.Magnitude + 8) -- (a little past you)
			-- a wall stops it short
			local r = workspace:Raycast(from, to - from, g.rp)
			if r then to = r.Position - (to - from).Unit * 1.5 end
			ab.from, ab.to, ab.t0, ab.hit, ab.hitBack = from, to, now, {}, {}
			H.setPhase(g, "throw", s.flight * 2)
			H.fx("SickleThrow", g.model, from, to, s.flight)
		end
	elseif ab.phase == "throw" then
		-- out, then back to his hand: whoever it passes is cut (once each way)
		local u = (now - ab.t0) / s.flight
		local back = u > 1
		local p: Vector3 = if back then (ab.to :: Vector3):Lerp(pos + Vector3.new(0, 1.5, 0), math.min(1, u - 1)) else (ab.from :: Vector3):Lerp(ab.to, u)
		local set = if back then ab.hitBack else ab.hit
		for _, pl in H.matchPlayers() do
			local h = H.hrpOf(pl)
			if h and not H.warded(pl) and not set[pl] and (h.Position - p).Magnitude < 4.5 then
				set[pl] = true
				local dir = H.flat(h.Position - pos)
				G.hitPlayer(pl, nil, s.dmg * H.dmgScale(g), dir * s.power + Vector3.new(0, 14, 0), "sickle", true, 0.8)
			end
		end
		if now >= ab.untilT then H.finish(g, G, 0.3) end
	end
end

---------------------------------------------------------------------------------------------- step
function CM.step(g, G, dt: number, now: number, _target: Player?, _thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	local victim = ab.victim :: Player?
	local vh = victim and H.hrpOf(victim) or nil
	local mv = ab.move
	if mv == "drop" then stepDrop(g, G, ab, a, now, pos, vh, hoverY)
	elseif mv == "charge" then stepCharge(g, G, ab, a, now, pos, hoverY)
	elseif mv == "hook" or mv == "flood" then stepHook(g, G, ab, a, dt, now, vh, hoverY)
	elseif mv == "grasp" then stepGrasp(g, G, ab, a, now, vh, hoverY)
	elseif mv == "torch" then stepTorch(g, G, ab, a, now, pos, vh, hoverY)
	elseif mv == "run" then stepRun(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif mv == "crows" then stepCrows(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif mv == "sickle" then stepSickle(g, G, ab, a, now, pos, vh, hoverY)
	else H.finish(g, G, 0.3) end
end

function CM.interrupt(g)
	local ab = g.ab
	if not ab then return end
	if ab.move == "hook" and ab.phase == "pull" and ab.victim then
		Remotes.Fx:FireClient(ab.victim, "Released")
		H.fx("HookMiss", g.model, nil)
	end
	if ab.move == "sickle" then H.fx("SickleDrop", g.model) end
end

-- the Scarecrow: true = he holds still this frame (someone is looking at him); also places his decoys, swaps with
-- them, and breaks a long stare with his crows
local decoysFor: Model? = nil
function CM.chaseHold(g, G, now: number, _thrp: BasePart?, hoverY: number): boolean
	local a = g.def.ability
	if a.kind ~= "scareSwap" then return false end
	-- his decoys, once per monster
	if decoysFor ~= g.model then
		decoysFor = g.model
		g.nextSwap = now + a.swapEvery
		local spots = live() and (live() :: Instance):FindFirstChild("ScarecrowSpots")
		local pts = {}
		if spots then
			for _, s in spots:GetChildren() do
				if s:IsA("BasePart") and (s.Position - g.hrp.Position).Magnitude > 10 then
					table.insert(pts, Vector3.new(s.Position.X, s.Position.Y + g.hover, s.Position.Z))
				end
			end
		end
		while #pts > a.decoys do table.remove(pts, rng:NextInteger(1, #pts)) end
		if #pts > 0 then H.spawnClones(g, pts, 900, 0, 0, { delay = 0 }) end
	end
	-- is anyone looking at him? (facing him, within the cone, nothing in between)
	local watcher: Player? = nil
	local head = (g.model:FindFirstChild("Head") or g.hrp) :: BasePart
	for _, p in H.matchPlayers() do
		local h = H.hrpOf(p)
		if h and not p:GetAttribute("Blinded") then
			local eye = h.Position + Vector3.new(0, 1.5, 0)
			local to = head.Position - eye
			if to.Magnitude < a.range and H.flat(h.CFrame.LookVector):Dot(H.flat(to)) > a.cone and sees(g, eye, head.Position) then
				watcher = p
				break
			end
		end
	end
	local watched = watcher ~= nil
	if g.model:GetAttribute("Watched") ~= watched then g.model:SetAttribute("Watched", watched) end
	if watched then g.watchedSince = g.watchedSince or now else g.watchedSince = nil end
	-- every so often: he swaps places with one of his decoys (a puff of straw at both)
	if now >= (g.nextSwap or 0) then
		g.nextSwap = now + a.swapEvery * rng:NextNumber(0.8, 1.3)
		local list = H.clones()
		if #list > 0 then
			local c = list[rng:NextInteger(1, #list)]
			local mine = g.model:GetPivot()
			local theirs = c.model:GetPivot()
			g.model:PivotTo(theirs)
			c.model:PivotTo(mine)
			H.fx("ScareSwap", mine.Position, theirs.Position)
		end
	end
	if watched then
		-- stared at too long: the crows go for the one staring (blinded, they have to look away)
		local c = a.crows
		local wh = watcher and H.hrpOf(watcher)
		if c and wh and now - g.watchedSince > c.stare and now >= (g.nextAbility or 0) and not H.warded(watcher) then
			g.watchedSince = nil
			g.model:SetAttribute("Watched", false)
			begin(g, G, "crows", a, watcher :: Player, wh)
			-- (however far away they stand: the crows fly all the way to them)
			g.ab.range = math.max(c.range, (wh.Position - g.hrp.Position).Magnitude + 6)
			return true
		end
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		return true
	end
	return false
end

---------------------------------------------------------------------------------------------- tick / clear
-- the flood: everyone standing in the water is slowed (Abilities.tick, every frame)
function CM.tick(G, now: number)
	if now < floodUntil and now >= nextSlowTick then
		nextSlowTick = now + 0.4
		for _, p in H.matchPlayers() do
			if H.hrpOf(p) and G.slowPlayer then G.slowPlayer(p, floodSlow, 0.6) end
		end
	end
end

function CM.clear()
	floodUntil = 0
	decoysFor = nil
	H.fx("FloodEnd")
end

return CM
