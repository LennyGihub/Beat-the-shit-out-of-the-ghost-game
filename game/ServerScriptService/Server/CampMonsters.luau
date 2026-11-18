--!strict
-- CAMP HOLLOWMERE's four monsters' special moves (Shared/Monsters; models: tools/build/camp_monsters.luau).
-- Abilities hands try / step / interrupt / clear over (like the Caller's and the Knight's), and the Scarecrow's
-- chase goes through chaseHold (Ghost's Chase state).
--   rafterDrop (THE ANTLERED ONE): he climbs up into the rafters (climb), follows his target from up there (lurk),
--     a red ring shows where he will come down (warn), he drops (fall): everyone in the ring is hit and thrown,
--     then he is dazed for a moment (daze) - the time to hit him.
--   hookPull (THE LAKE WITCH): she draws back her hook (wind) and throws it (throw: a real projectile, walls stop it);
--     whoever it catches is dragged toward the water (pull: the building's WaterSpots, or toward her) and held
--     under (damage). Every few throws she FLOODS the floor instead: black water rises for a while and everyone
--     standing in it is slowed.
--   firebrand (THE BURNED COUNSELOR): he raises his torch (wind) and lobs it where his target stands (throw); where it
--     lands the wood catches fire (Server/Fire: the wildfire system; it burns players, not him - fireImmune).
--   scareSwap (THE SCARECROW): his decoys (exact copies, standing still) fill the building's ScarecrowSpots; he does
--     not move while ANY player looks at him (chaseHold: frozen in their stiff pose, model attribute Watched), and
--     every so often he swaps places with one of his decoys in a puff of straw. Punching a decoy bursts it.
local Players = game:GetService("Players")
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)

local CM = {}
local H: any = nil -- Abilities' helpers
function CM.init(h) H = h end
local rng = Random.new()
local floodUntil, floodSlow, nextSlowTick = 0, 0.6, 0

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

---------------------------------------------------------------------------------------------- try
function CM.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	local k = a.kind
	if H.warded(target) then return false end
	if k == "rafterDrop" then
		if dist < a.min then return false end
		-- the rafters (or the ceiling) above him
		local up = workspace:Raycast(g.hrp.Position, Vector3.new(0, 60, 0), g.rp)
		local ceil = up and up.Position.Y or (g.hrp.Position.Y + 18)
		local floorY = floorBelow(g, g.hrp.Position).Y
		local hangY = math.max(floorY + 12, ceil - 4) -- (hanging under it: his feet up there, his head down)
		H.start(g, G, "climb", a.climb, { victim = target, hangY = hangY, floorY = floorY })
		H.fx("AntlerClimb", g.model, a.climb)
		return true
	elseif k == "hookPull" then
		-- every floodEvery-th move is the flood (the throws in between count)
		if (g.hooksSinceFlood or 0) >= (a.floodEvery or 3) - 1 and now > floodUntil then
			g.hooksSinceFlood = 0
			H.start(g, G, "flood", 1.3, {})
			return true
		end
		if dist < a.min or dist > a.max then return false end
		local hand = g.hrp.Position + Vector3.new(0, 2, 0)
		if not sees(g, hand, thrp.Position) then return false end
		g.hooksSinceFlood = (g.hooksSinceFlood or 0) + 1
		H.start(g, G, "wind", a.wind, { victim = target })
		H.fx("HookWind", g.model, a.wind)
		return true
	elseif k == "firebrand" then
		if dist < a.min or dist > a.max then return false end
		H.start(g, G, "wind", a.wind, { victim = target })
		H.fx("TorchWind", g.model, a.wind)
		return true
	end
	return false
end

---------------------------------------------------------------------------------------------- step
function CM.step(g, G, dt: number, now: number, _target: Player?, _thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	local victim = ab.victim :: Player?
	local vh = victim and H.hrpOf(victim) or nil
	if ab.kind == "rafterDrop" then
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
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and not H.warded(p) and (Vector3.new(h.Position.X - spot.X, 0, h.Position.Z - spot.Z)).Magnitude < a.radius and math.abs(h.Position.Y - spot.Y) < 8 then
						local dir = H.flat(h.Position - spot)
						if dir.Magnitude < 0.1 then dir = Vector3.new(1, 0, 0) end
						G.hitPlayer(p, nil, a.dmg * H.dmgScale(g), dir * a.power + Vector3.new(0, 38, 0), "drop", true, 1.4)
					end
				end
				for _, m in Furniture.near(spot, a.radius) do
					local dir = H.flat(m:GetPivot().Position - spot)
					Furniture.smash(m, (dir.Magnitude > 0.1 and dir.Unit or Vector3.new(0, 0, 1)) * 60 + Vector3.new(0, 40, 0), 90)
				end
				H.fx("DropLand", spot, a.radius)
				H.setPhase(g, "daze", a.daze)
			end
		elseif ab.phase == "daze" then
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then H.finish(g, G, 0.4) end
		end
		return
	elseif ab.kind == "hookPull" then
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
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
				ab.travel = 0
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
			ab.travel += step
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
					ab.dest = dest
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
		return
	elseif ab.kind == "firebrand" then
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
		elseif ab.phase == "throw" then
			if now >= ab.untilT then
				local spot = ab.spot :: Vector3
				local Fire = require(script.Parent.Fire) :: any
				Fire.ignite(spot + Vector3.new(0, 0.5, 0), a.radius, nil, a.fires, true)
				H.fx("TorchLand", spot)
				-- anyone right where it lands is burnt at once
				for _, p in H.matchPlayers() do
					local h = H.hrpOf(p)
					if h and (h.Position - spot).Magnitude < 4 then G.damagePlayer(p, a.dmg * H.dmgScale(g), nil, spot) end
				end
				H.finish(g, G, 0.4)
			end
		end
		return
	end
	H.finish(g, G, 0.3)
end

function CM.interrupt(g)
	local ab = g.ab
	if not ab then return end
	if ab.kind == "hookPull" and ab.phase == "pull" and ab.victim then
		Remotes.Fx:FireClient(ab.victim, "Released")
		H.fx("HookMiss", g.model, nil)
	end
end

---------------------------------------------------------------------------------------------- the Scarecrow
-- true = he holds still this frame (someone is looking at him); also places his decoys and swaps with them
local decoysFor: Model? = nil
function CM.chaseHold(g, G, now: number, _thrp: BasePart?, hoverY: number): boolean
	local a = g.def.ability
	if a.kind ~= "scareSwap" then return false end
	-- his decoys, once per monster
	if decoysFor ~= g.model then
		decoysFor = g.model
		g.nextSwap = now + a.cd
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
	local watched = false
	local head = (g.model:FindFirstChild("Head") or g.hrp) :: BasePart
	for _, p in H.matchPlayers() do
		local h = H.hrpOf(p)
		if h then
			local to = head.Position - (h.Position + Vector3.new(0, 1.5, 0))
			if to.Magnitude < a.range and H.flat(h.CFrame.LookVector):Dot(H.flat(to)) > a.cone and sees(g, h.Position + Vector3.new(0, 1.5, 0), head.Position) then
				watched = true
				break
			end
		end
	end
	if g.model:GetAttribute("Watched") ~= watched then g.model:SetAttribute("Watched", watched) end
	-- every so often: he swaps places with one of his decoys (a puff of straw at both)
	if now >= (g.nextSwap or 0) then
		g.nextSwap = now + a.cd * rng:NextNumber(0.8, 1.3)
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
			local h = H.hrpOf(p)
			if h and G.slowPlayer then G.slowPlayer(p, floodSlow, 0.6) end
		end
	end
end

function CM.clear()
	floodUntil = 0
	decoysFor = nil
	H.fx("FloodEnd")
end

local _ = Players
return CM
