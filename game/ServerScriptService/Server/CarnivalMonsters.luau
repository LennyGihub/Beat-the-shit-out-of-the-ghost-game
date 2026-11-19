--!strict
-- THE MOONLIGHT CARNIVAL's four new monsters' special moves (Shared/Monsters; models: tools/build/carnival_monsters.luau;
-- client: Client/CarnivalFx). Abilities hands try / step / interrupt / tick / clear over, like Server/CampMonsters.
-- Every monster has a MOVESET: the moves whose conditions are met are candidates, the one used last is left out when
-- another fits, and the shared cooldown (ability.cd) keeps plain swipes and lunges between them. The move is ab.move;
-- every phase has its own name (Client/GhostAnim poses by Ability + AbilityPhase).
--   POP THE CLOWN (popClown):
--     crate     he ducks out of sight (hide), crates rattle round you - the nearest one to you is him (lurk) - and he
--               bursts out of it (pop): everyone close is thrown; then he laughs (laugh): the time to hit him
--     balloons  he blows (blow), and balloon copies of himself float at you: they pop when they touch you or get hit
--               (Abilities' mirror clones, kind "balloon")
--   THE STRONGMAN (strongman):
--     rip       he grabs the nearest bench / ride part (fetch), lifts it overhead (lift, aim) and hurls it (throw)
--     slam      he leaps (leap), comes down (fall) and a shockwave rolls out along the floor (slam): jump over it
--   MADAME FORTUNE (fortune):
--     curse     hands up (conjure), a violet orb floats after you (orb; walls stop it): caught = CURSED (blurred, the
--               controls reversed: player attribute Cursed, Client/CarnivalFx) until someone SMASHES HER CRYSTAL BALL
--               (a prompt on it; the building's CrystalBall part, or one put down for her); smashed, she shrieks,
--               stunned (shriek), and the ball comes back after a while
--     cards     a fan of tarot cards thrown at you (deal, throw)
--   THE RINGMASTER (ringmaster):
--     whip      a red line on the floor (wind), the lash along it (lash): whoever it catches is pulled in to him
--     crowd     he cracks the whip overhead (crack): mannequins in the stands come alive and come for you (the
--               building's Mannequins, else mannequins rising round you; they burst when hit or when they reach you)
local Players = game:GetService("Players")
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)
local Events = require(script.Parent.Events)

local CM = {}
local H: any = nil -- Abilities' helpers
function CM.init(h) H = h end
local rng = Random.new()

CM.KINDS = { popClown = true, strongman = true, fortune = true, ringmaster = true }

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
local function fxFolder(): Folder
	local f = workspace:FindFirstChild("CarnivalFx") :: Folder?
	if not f then
		local nf = Instance.new("Folder"); nf.Name = "CarnivalFx"; nf.Parent = workspace
		f = nf
	end
	return f :: Folder
end
local function ball(name: string, size: number, color: Color3, at: Vector3): Part
	local p = Instance.new("Part")
	p.Name = name; p.Shape = Enum.PartType.Ball; p.Size = Vector3.one * size; p.Color = color; p.Material = Enum.Material.Neon
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Position = at; p.Parent = fxFolder()
	return p
end
-- hit every match player (not warded) within r of pos (flat distance, about the same height), once per `hit`
local function hitAround(g, G, pos: Vector3, r: number, hit: { [Player]: boolean }?, dmg: number, power: number, up: number, kind: string, ragT: number?)
	for _, p in H.matchPlayers() do
		local h = H.hrpOf(p)
		if h and not H.warded(p) and not (hit and hit[p]) then
			local off = h.Position - pos
			if Vector3.new(off.X, 0, off.Z).Magnitude < r and math.abs(off.Y) < 8 then
				if hit then hit[p] = true end
				G.hitPlayer(p, nil, dmg * H.dmgScale(g), H.flat(off) * power + Vector3.new(0, up, 0), kind, true, ragT or 1.2)
			end
		end
	end
end

---------------------------------------------------------------------------------------------- MADAME FORTUNE'S BALL
-- the curse lasts until the ball is smashed (or CURSE_MAX at most)
local CURSE_MAX = 28
local cursed = {} :: { [Player]: number }
local ballState: { part: BasePart?, own: boolean, broken: boolean, back: number, model: Model?, G: any } = { part = nil, own = false, broken = false, back = 0, model = nil, G = nil }

local function curse(p: Player, on: boolean)
	if on then
		cursed[p] = os.clock() + CURSE_MAX
		p:SetAttribute("Cursed", true)
	else
		cursed[p] = nil
		p:SetAttribute("Cursed", nil)
	end
end
local function clearCurses()
	for p in cursed do curse(p, false) end
	for _, p in Players:GetPlayers() do if p:GetAttribute("Cursed") then p:SetAttribute("Cursed", nil) end end
end

-- smashed: every curse ends, she shrieks (stunned), the ball comes back later
local function smashBall(G)
	local b = ballState.part
	if not b or ballState.broken then return end
	ballState.broken = true
	ballState.back = os.clock() + 22
	b.Transparency = 1
	for _, d in b:GetDescendants() do if d:IsA("BasePart") then d.LocalTransparencyModifier = 1; d.Transparency = 1 end end
	local pp = b:FindFirstChildOfClass("ProximityPrompt")
	if pp then pp.Enabled = false end
	local l = b:FindFirstChildOfClass("PointLight")
	if l then l.Enabled = false end
	b:SetAttribute("Mark", "") -- (no marker while it is in pieces: Client/CallerMarks)
	H.fx("BallSmash", b.Position)
	clearCurses()
	local g = G.current
	if g and g.def.ability.kind == "fortune" and g.state ~= "Dead" then
		if g.ab then CM.interrupt(g); g.ab = nil end
		H.start(g, G, "shriek", 3.2, { move = "shriek" })
	end
end

-- the ball for this fight: the building's own CrystalBall part, else one put down near her
local function armBall(g, G)
	ballState.G = G
	if ballState.model == g.model then return end
	ballState.model = g.model
	if ballState.own and ballState.part then ballState.part:Destroy() end
	ballState.part, ballState.own, ballState.broken = nil, false, false
	local m = live()
	local b = m and m:FindFirstChild("CrystalBall", true) :: BasePart?
	if not b then
		local at = floorBelow(g, g.hrp.Position + g.hrp.CFrame.LookVector * -10)
		local nb = ball("CrystalBall", 2.2, Color3.fromRGB(190, 140, 255), at + Vector3.new(0, 1.2, 0))
		nb.Transparency = 0.25
		b = nb
		ballState.own = true
	end
	local part = b :: BasePart
	ballState.part = part
	part.Transparency = ballState.own and 0.25 or part.Transparency
	if not part:FindFirstChildOfClass("PointLight") then
		local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(190, 120, 255); l.Range = 16; l.Brightness = 1.4; l.Parent = part
	end
	local pp = part:FindFirstChildOfClass("ProximityPrompt") or Events.prompt(part, "Smash", "Madame Fortune's crystal ball", 0.3)
	pp.Enabled = true
	pp.MaxActivationDistance = 9
	-- (always shown: an item's "Take" prompt nearby, on the same key, would hide it otherwise)
	pp.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	-- the players are shown where it is (Client/CallerMarks: an outline through the walls and an arrow)
	game:GetService("CollectionService"):AddTag(part, "MarkTarget")
	part:SetAttribute("Mark", "CRYSTAL BALL")
	part:SetAttribute("MarkColor", Color3.fromRGB(200, 130, 255))
	if not part:GetAttribute("Armed") then
		part:SetAttribute("Armed", true)
		pp.Triggered:Connect(function(p: Player)
			if p:GetAttribute("InMatch") then smashBall(G) end
		end)
	end
end

-- a punch or a swing that reaches the crystal ball smashes it (Abilities.hitClone asks this for every hit)
function CM.hitBall(from: Vector3, dir: Vector3, range: number): boolean
	local b = ballState.part
	if not b or ballState.broken or not b.Parent or not ballState.G then return false end
	local to = b.Position - from
	local d = to.Magnitude
	if d > range + 2.5 then return false end
	if d > 3 and to.Unit:Dot(dir.Unit) < 0.45 then return false end
	smashBall(ballState.G)
	return true
end

---------------------------------------------------------------------------------------------- choosing a move
local function candidates(g, a, thrp: BasePart, dist: number): { string }
	local out = {}
	local k = a.kind
	local hand = g.hrp.Position + Vector3.new(0, 2, 0)
	local inSight = sees(g, hand, thrp.Position)
	local clones = #H.clones()
	if k == "popClown" then
		if dist >= a.crate.min then table.insert(out, "crate") end
		if clones == 0 and dist <= a.balloons.max then table.insert(out, "balloons") end
	elseif k == "strongman" then
		if dist <= a.rip.max then table.insert(out, "rip") end
		if dist <= a.slam.max then table.insert(out, "slam") end
	elseif k == "fortune" then
		local target = Players:GetPlayerFromCharacter(thrp.Parent :: Instance)
		if dist <= a.curse.max and inSight and not (target and target:GetAttribute("Cursed")) then table.insert(out, "curse") end
		if dist >= a.cards.min and dist <= a.cards.max and inSight then table.insert(out, "cards") end
	elseif k == "ringmaster" then
		if dist >= a.whip.min and dist <= a.whip.max and inSight then table.insert(out, "whip") end
		if clones == 0 and dist <= a.crowd.max then table.insert(out, "crowd") end
	end
	return out
end

local function begin(g, G, move: string, a, target: Player, thrp: BasePart)
	g.lastMove = move
	if move == "crate" then
		H.start(g, G, "hide", 0.5, { move = move, victim = target })
		H.fx("ClownHide", g.model)
	elseif move == "balloons" then
		H.start(g, G, "blow", a.balloons.wind, { move = move, victim = target })
		H.fx("ClownBlow", g.model, a.balloons.wind)
	elseif move == "rip" then
		local list = Furniture.nearest(g.hrp.Position, a.rip.reach, 1)
		local obj = list[1]
		if not obj then
			-- nothing near: he tears a piece up out of the floor in front of him
			obj = Furniture.conjure(CFrame.new(floorBelow(g, g.hrp.Position + g.hrp.CFrame.LookVector * 6)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0))
		end
		if not obj then return end
		H.start(g, G, "fetch", 1.6, { move = move, victim = target, obj = obj })
		H.fx("StrongGrunt", g.model)
	elseif move == "slam" then
		local to = H.flat(thrp.Position - g.hrp.Position)
		local land = floorBelow(g, g.hrp.Position + to * math.min(10, (thrp.Position - g.hrp.Position).Magnitude * 0.4))
		H.start(g, G, "leap", a.slam.leap, { move = move, victim = target, land = land, y0 = g.hrp.Position.Y })
		H.fx("SlamWarn", land, a.slam.radius, a.slam.leap + 0.35)
	elseif move == "curse" then
		H.start(g, G, "conjure", a.curse.wind, { move = move, victim = target })
		H.fx("CurseWind", g.model, a.curse.wind)
	elseif move == "cards" then
		H.start(g, G, "deal", a.cards.wind, { move = move, victim = target })
		H.fx("CardsWind", g.model, a.cards.wind)
	elseif move == "whip" then
		local dir = H.flat(thrp.Position - g.hrp.Position)
		H.start(g, G, "wind", a.whip.wind, { move = move, victim = target, dir = dir, hit = {} })
		H.fx("WhipLine", floorBelow(g, g.hrp.Position), dir, a.whip.max, a.whip.wind)
	elseif move == "crowd" then
		H.start(g, G, "crack", a.crowd.wind, { move = move, victim = target })
		H.fx("WhipCrackUp", g.model, a.crowd.wind)
	end
end

function CM.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	if H.warded(target) then return false end
	if a.kind == "fortune" then armBall(g, G) end
	local list = candidates(g, a, thrp, dist)
	if #list == 0 then return false end
	if #list > 1 and g.lastMove then
		for i = #list, 1, -1 do if list[i] == g.lastMove then table.remove(list, i) end end
	end
	begin(g, G, list[rng:NextInteger(1, #list)], a, target, thrp)
	return g.ab ~= nil
end

---------------------------------------------------------------------------------------------- POP THE CLOWN
local function crateSpots(g, near: Vector3): { Vector3 }
	-- the building's crates (folder PopCrates: parts), the three nearest to the target; else three spots round it
	local out = {}
	local m = live()
	local f = m and m:FindFirstChild("PopCrates")
	if f then
		local all = {}
		for _, c in f:GetChildren() do
			if c:IsA("BasePart") then table.insert(all, c.Position) end
		end
		table.sort(all, function(x, y) return (x - near).Magnitude < (y - near).Magnitude end)
		for i = 1, math.min(3, #all) do table.insert(out, all[i]) end
	end
	if #out == 0 then
		local a0 = rng:NextNumber(0, math.pi * 2)
		for i = 0, 2 do
			local a = a0 + i * 2.1
			table.insert(out, floorBelow(g, near + Vector3.new(math.cos(a), 0, math.sin(a)) * (i == 0 and 6 or 11)) + Vector3.new(0, 1.5, 0))
		end
	end
	return out
end

local function stepClown(g, G, ab, a, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	if ab.move == "crate" then
		local c = a.crate
		if ab.phase == "hide" then
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then
				g.model:SetAttribute("Vanish", true)
				local spots = crateSpots(g, vh and vh.Position or pos)
				ab.spots = spots
				ab.real = spots[1]
				H.setPhase(g, "lurk", c.lurk)
				H.fx("CrateRattle", spots, 1, c.lurk)
			end
		elseif ab.phase == "lurk" then
			g.lv.VectorVelocity = Vector3.zero
			if now >= ab.untilT then
				local spot = ab.real :: Vector3
				local fl = floorBelow(g, spot)
				g.model:PivotTo(CFrame.new(fl + Vector3.new(0, g.hover, 0)) * g.model:GetPivot().Rotation)
				g.model:SetAttribute("Vanish", false)
				hitAround(g, G, fl, c.radius, nil, c.dmg, c.power, 48, "crate", 1.4)
				H.fx("CratePop", fl, c.radius)
				if vh then face(g, vh.Position) end
				H.setPhase(g, "laugh", c.laugh)
			end
		else
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then H.finish(g, G, 0.3) end
		end
	else -- balloons
		local b = a.balloons
		g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
		if vh then face(g, vh.Position) end
		if ab.phase == "blow" and now >= ab.untilT then
			local pts = {}
			for i = 1, b.count do
				local ang = (i / b.count) * math.pi * 2 + rng:NextNumber(-0.3, 0.3)
				local p = pos + Vector3.new(math.cos(ang), 0, math.sin(ang)) * rng:NextNumber(5, 9)
				table.insert(pts, floorBelow(g, p) + Vector3.new(0, g.hover * b.scale + 1.2, 0))
			end
			H.spawnClones(g, pts, b.life, b.dmg * H.dmgScale(g), b.speed, { scale = b.scale, kind = "balloon", delay = 0.5 })
			H.setPhase(g, "release", 0.5)
		elseif ab.phase == "release" and now >= ab.untilT then
			H.finish(g, G, 0.3)
		end
	end
end

---------------------------------------------------------------------------------------------- THE STRONGMAN
local function heldAt(g): CFrame
	return g.hrp.CFrame * CFrame.new(0, 8.5, -0.6)
end
local function grab(obj: Model)
	obj:SetAttribute("CarriedBy", -1)
	for _, p in obj:GetDescendants() do
		if p:IsA("BasePart") then p.CanCollide = false; p.CanTouch = false; p.CollisionGroup = "Carried" end
	end
	local prim = obj.PrimaryPart
	if prim then prim.Anchored = true end
end

local function stepStrongman(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number, target: Player?)
	if ab.move == "rip" then
		local r = a.rip
		local obj = ab.obj :: Model
		if not obj or not obj.Parent or obj:GetAttribute("Broken") then H.finish(g, G, 0.3); return end
		if ab.phase == "fetch" then
			-- he goes for it (it is yanked to him if he can't reach it in time)
			local op = obj:GetPivot().Position
			local to = Vector3.new(op.X - pos.X, 0, op.Z - pos.Z)
			face(g, op)
			if to.Magnitude > 5 and now < ab.untilT then
				g.lv.VectorVelocity = H.hover(g, hoverY, to.Unit * r.run)
			else
				grab(obj)
				ab.from = obj:GetPivot()
				ab.t0 = now
				H.fx("StrongLift", g.model, obj)
				H.setPhase(g, "lift", r.lift)
			end
		elseif ab.phase == "lift" or ab.phase == "aim" then
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if vh then face(g, vh.Position) end
			local f = math.clamp((now - ab.t0) / r.lift, 0, 1)
			f = f * f * (3 - 2 * f)
			local hold = heldAt(g)
			local p = (ab.from :: CFrame).Position:Lerp(hold.Position, f)
			local shake = ab.phase == "aim" and Vector3.new(rng:NextNumber(-0.15, 0.15), rng:NextNumber(-0.15, 0.15), 0) or Vector3.zero
			obj:PivotTo(CFrame.new(p + shake) * (ab.from :: CFrame).Rotation:Lerp(hold.Rotation, f))
			if ab.phase == "lift" and now >= ab.untilT then
				H.setPhase(g, "aim", r.aim)
			elseif ab.phase == "aim" and now >= ab.untilT then
				if target then H.hurl(g, obj, target, r.speed, r.dmg * H.dmgScale(g)) else H.ungrip(obj) end
				ab.obj = nil
				H.fx("StrongThrow", g.model)
				H.setPhase(g, "throw", 0.5)
			end
		else
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			if now >= ab.untilT then H.finish(g, G, 0.4) end
		end
	else -- slam
		local s = a.slam
		local land = ab.land :: Vector3
		if ab.phase == "leap" then
			-- up, drifting over the spot
			local f = 1 - math.max(0, ab.untilT - now) / s.leap
			local want = ab.y0 + math.sin(math.min(1, f) * math.pi * 0.5) * s.height
			local d = Vector3.new(land.X - pos.X, 0, land.Z - pos.Z)
			g.lv.VectorVelocity = Vector3.new(d.X * 3, (want - pos.Y) * 10, d.Z * 3)
			if now >= ab.untilT then H.setPhase(g, "fall", 0.6) end
		elseif ab.phase == "fall" then
			local d = Vector3.new(land.X - pos.X, 0, land.Z - pos.Z)
			g.lv.VectorVelocity = Vector3.new(d.X * 6, -140, d.Z * 6)
			if pos.Y <= land.Y + g.hover + 0.6 or now >= ab.untilT then
				ab.wave = { t0 = now, hit = {} }
				hitAround(g, G, land, 5, ab.wave.hit, s.dmg, s.power, 40, "slam", 1.3)
				for _, m in Furniture.near(land, 8) do Furniture.smash(m, H.flat(m:GetPivot().Position - land) * 50 + Vector3.new(0, 40, 0), 90) end
				H.fx("Shockwave", land, s.radius, s.radius / s.wave)
				H.setPhase(g, "slam", s.radius / s.wave + 0.3)
			end
		else
			-- the ring rolls out along the floor: whoever is on the floor when it passes is thrown (jump over it)
			g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
			local w = ab.wave
			local r = (now - w.t0) * s.wave
			for _, p in H.matchPlayers() do
				local h = H.hrpOf(p)
				if h and not w.hit[p] and not H.warded(p) then
					local off = h.Position - land
					local fd = Vector3.new(off.X, 0, off.Z).Magnitude
					local onFloor = off.Y < 4.2 -- (a player's root stands ~3 over the floor; a jump lifts it)
					if onFloor and fd > r - 3 and fd < r + 0.8 then
						w.hit[p] = true
						G.hitPlayer(p, nil, s.dmg * 0.7 * H.dmgScale(g), H.flat(off) * s.power * 0.7 + Vector3.new(0, 42, 0), "shockwave", true, 1.1)
					end
				end
			end
			if now >= ab.untilT then H.finish(g, G, 0.3) end
		end
	end
end

---------------------------------------------------------------------------------------------- MADAME FORTUNE
local function stepFortune(g, G, ab, a, dt: number, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.move == "shriek" then
		if now >= ab.untilT then H.finish(g, G, 0.3) end
		return
	end
	if vh then face(g, vh.Position) end
	if ab.move == "curse" then
		local c = a.curse
		if ab.phase == "conjure" and now >= ab.untilT then
			local from = pos + Vector3.new(0, 3, 0) + g.hrp.CFrame.LookVector * 1.5
			ab.orb = ball("CurseOrb", 1.6, Color3.fromRGB(190, 90, 255), from)
			local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(190, 90, 255); l.Range = 14; l.Brightness = 2; l.Parent = ab.orb
			ab.vel = (vh and (vh.Position - from).Unit or g.hrp.CFrame.LookVector) * c.speed
			H.setPhase(g, "orb", c.life)
			H.fx("CurseOrb", ab.orb)
		elseif ab.phase == "orb" then
			local orb = ab.orb :: Part
			-- it turns after its target (slowly: you can outrun the turn)
			if vh then
				local want = (vh.Position - orb.Position).Unit * c.speed
				ab.vel = (ab.vel :: Vector3):Lerp(want, math.min(1, dt * c.turn))
			end
			local step = (ab.vel :: Vector3) * dt
			local hitWall = workspace:Raycast(orb.Position, step, g.rp)
			local np = orb.Position + step
			orb.Position = np
			local caught: Player? = nil
			for _, p in H.matchPlayers() do
				local h = H.hrpOf(p)
				if h and not H.warded(p) and (h.Position - np).Magnitude < 3.2 then caught = p; break end
			end
			if caught then
				curse(caught, true)
				G.damagePlayer(caught, c.dmg * H.dmgScale(g), 10, np)
				Remotes.Fx:FireClient(caught, "Toast", "CURSED! SMASH HER CRYSTAL BALL", false)
				H.fx("CurseHit", np)
			end
			if caught or hitWall or now >= ab.untilT then
				if not caught then H.fx("CurseFizzle", np) end
				orb:Destroy()
				ab.orb = nil
				H.finish(g, G, 0.4)
			end
		end
	else -- cards
		local c = a.cards
		if ab.phase == "deal" and now >= ab.untilT then
			local from = pos + Vector3.new(0, 2.2, 0)
			local aim = vh and H.flat(vh.Position - from) or H.flat(g.hrp.CFrame.LookVector)
			ab.cards = {}
			for i = 1, c.count do
				local ang = (i - (c.count + 1) / 2) * c.spread
				local dir = (CFrame.Angles(0, ang, 0) * aim) :: Vector3
				local p = Instance.new("Part")
				p.Name = "Card"; p.Size = Vector3.new(1.4, 0.08, 2); p.Color = Color3.fromRGB(236, 226, 196); p.Material = Enum.Material.SmoothPlastic
				p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
				p.CFrame = CFrame.lookAt(from, from + dir); p.Parent = fxFolder()
				local back = Instance.new("Part")
				back.Name = "CardBack"; back.Size = Vector3.new(1.0, 0.1, 1.5); back.Color = Color3.fromRGB(150, 50, 200); back.Material = Enum.Material.Neon
				back.Anchored = true; back.CanCollide = false; back.CanQuery = false; back.CanTouch = false; back.CFrame = p.CFrame; back.Parent = p
				table.insert(ab.cards, { part = p, back = back, dir = dir, hit = {}, done = false })
			end
			H.fx("CardsThrow", from)
			H.setPhase(g, "throw", c.life)
		elseif ab.phase == "throw" then
			local alive = 0
			for _, cd in ab.cards do
				if not cd.done then
					local p = cd.part :: Part
					local step = cd.dir * c.speed * dt
					if workspace:Raycast(p.Position, step, g.rp) then
						cd.done = true
						p:Destroy()
					else
						local np = p.Position + step
						local cf = CFrame.lookAt(np, np + cd.dir) * CFrame.Angles(0, 0, now * 20)
						p.CFrame = cf
						cd.back.CFrame = cf * CFrame.new(0, 0.02, 0)
						alive += 1
						for _, pl in H.matchPlayers() do
							local h = H.hrpOf(pl)
							if h and not cd.hit[pl] and not H.warded(pl) and (h.Position - np).Magnitude < 2.8 then
								cd.hit[pl] = true
								G.hitPlayer(pl, nil, c.dmg * H.dmgScale(g), cd.dir * c.power + Vector3.new(0, 10, 0), "card", true, 0.6)
							end
						end
					end
				end
			end
			if alive == 0 or now >= ab.untilT then
				for _, cd in ab.cards do if cd.part.Parent then cd.part:Destroy() end end
				ab.cards = nil
				H.finish(g, G, 0.4)
			end
		end
	end
end

---------------------------------------------------------------------------------------------- THE RINGMASTER
-- a mannequin brought to life: plain white parts, no face (it goes after you like a mirror clone)
local function mannequin(cf: CFrame): Model
	local m = Instance.new("Model")
	m.Name = "Mannequin"
	local W = Color3.fromRGB(222, 214, 200)
	local function P(name: string, size: Vector3, rel: CFrame, color: Color3?)
		local p = Instance.new("Part")
		p.Name = name; p.Size = size; p.CFrame = cf * rel; p.Color = color or W; p.Material = Enum.Material.SmoothPlastic; p.Reflectance = 0.08
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
		p.Parent = m
		return p
	end
	local torso = P("UpperTorso", Vector3.new(1.9, 2.2, 1.0), CFrame.new(0, 1.3, 0))
	P("LowerTorso", Vector3.new(1.6, 1.0, 0.9), CFrame.new(0, -0.3, 0))
	P("Head", Vector3.new(1.0, 1.3, 1.0), CFrame.new(0, 3.1, 0))
	P("Neck", Vector3.new(0.4, 0.5, 0.4), CFrame.new(0, 2.5, 0))
	for _, s in { -1, 1 } do
		P("Arm", Vector3.new(0.5, 2.6, 0.5), CFrame.new(s * 1.25, 1.0, -0.6) * CFrame.Angles(1.3, 0, s * 0.15))
		P("Leg", Vector3.new(0.6, 3.0, 0.6), CFrame.new(s * 0.45, -2.3, 0))
		P("Joint", Vector3.one * 0.55, CFrame.new(s * 1.25, 2.1, 0), Color3.fromRGB(150, 140, 126))
	end
	P("Seam", Vector3.new(1.95, 0.12, 1.05), CFrame.new(0, 0.3, 0), Color3.fromRGB(150, 140, 126))
	m.PrimaryPart = torso
	m.Parent = workspace
	return m
end

local function stepRingmaster(g, G, ab, a, now: number, pos: Vector3, vh: BasePart?, hoverY: number)
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.move == "whip" then
		local w = a.whip
		local dir = ab.dir :: Vector3
		face(g, pos + dir * 10)
		if ab.phase == "wind" and now >= ab.untilT then
			-- the lash: whoever stands on the line is caught and pulled in to him
			local from = pos
			for _, p in H.matchPlayers() do
				local h = H.hrpOf(p)
				if h and not H.warded(p) then
					local off = h.Position - from
					local along = off:Dot(dir)
					local side = (Vector3.new(off.X, 0, off.Z) - dir * along).Magnitude
					if along > 0 and along < w.max and side < w.width and math.abs(off.Y) < 7 then
						local pull = -dir * math.clamp(along * 2.2, 30, 90) + Vector3.new(0, 22, 0)
						G.hitPlayer(p, nil, w.dmg * H.dmgScale(g), pull, "whip", true, 0.9)
					end
				end
			end
			H.fx("WhipCrack", g.model, from, dir, w.max)
			H.setPhase(g, "lash", 0.45)
		elseif ab.phase == "lash" and now >= ab.untilT then
			H.finish(g, G, 0.3)
		end
	else -- crowd
		local c = a.crowd
		if vh then face(g, vh.Position) end
		if ab.phase == "crack" and now >= ab.untilT then
			-- the mannequins: the building's own (in the stands), else they rise out of the floor round the target
			local spots = {} :: { CFrame }
			local m = live()
			local f = m and m:FindFirstChild("Mannequins")
			if f then
				local sleeping = {}
				for _, mm in f:GetChildren() do
					if mm:IsA("Model") and not mm:GetAttribute("Awake") then table.insert(sleeping, mm) end
				end
				for i = #sleeping, 2, -1 do
					local j = rng:NextInteger(1, i)
					sleeping[i], sleeping[j] = sleeping[j], sleeping[i]
				end
				for i = 1, math.min(c.count, #sleeping) do
					local mm = sleeping[i]
					mm:SetAttribute("Awake", true)
					table.insert(spots, mm:GetPivot())
					for _, d in mm:GetDescendants() do if d:IsA("BasePart") then d.Transparency = 1 end end
				end
			end
			while #spots < c.count do
				local ang = rng:NextNumber(0, math.pi * 2)
				local at = floorBelow(g, (vh and vh.Position or pos) + Vector3.new(math.cos(ang), 0, math.sin(ang)) * rng:NextNumber(10, 16))
				table.insert(spots, CFrame.new(at + Vector3.new(0, 3.9, 0)))
			end
			local list = H.clones()
			for _, cf in spots do
				local mm = mannequin(CFrame.new(cf.Position))
				mm:SetAttribute("Clone", true)
				table.insert(list, { model = mm, untilT = now + c.life, from = now + 0.7, speed = c.speed, dmg = c.dmg * H.dmgScale(g), hover = 5.1, kind = "mannequin" })
				H.fx("CloneSpawn", cf.Position, "mannequin")
			end
			H.fx("CrowdCheer", pos)
			H.setPhase(g, "bow", 0.8)
		elseif ab.phase == "bow" and now >= ab.untilT then
			H.finish(g, G, 0.3)
		end
	end
end

---------------------------------------------------------------------------------------------- step / interrupt / tick / clear
function CM.step(g, G, dt: number, now: number, target: Player?, _thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	local victim = ab.victim :: Player?
	local vh = victim and H.hrpOf(victim) or nil
	local k = a.kind
	if k == "popClown" then stepClown(g, G, ab, a, now, pos, vh, hoverY)
	elseif k == "strongman" then stepStrongman(g, G, ab, a, dt, now, pos, vh, hoverY, victim or target)
	elseif k == "fortune" then stepFortune(g, G, ab, a, dt, now, pos, vh, hoverY)
	elseif k == "ringmaster" then stepRingmaster(g, G, ab, a, now, pos, vh, hoverY)
	else H.finish(g, G, 0.3) end
end

function CM.interrupt(g)
	local ab = g.ab
	if not ab then return end
	if ab.move == "crate" then g.model:SetAttribute("Vanish", false) end
	if ab.move == "rip" and ab.obj then H.ungrip(ab.obj); ab.obj = nil end
	if ab.orb then (ab.orb :: Part):Destroy(); ab.orb = nil end
	if ab.cards then
		for _, cd in ab.cards do if cd.part.Parent then cd.part:Destroy() end end
		ab.cards = nil
	end
end

-- every frame: the curses wear off (CURSE_MAX), the crystal ball comes back
function CM.tick(G, now: number)
	for p, untilT in cursed do
		if now > untilT or not p.Parent or not p:GetAttribute("InMatch") then curse(p, false) end
	end
	local g = G.current
	if next(cursed) and not (g and g.def.ability.kind == "fortune" and g.state ~= "Dead") then clearCurses() end
	local b = ballState.part
	-- (the marker only while she fights)
	if b and b:GetAttribute("Mark") ~= "" and not (g and g.def.ability.kind == "fortune" and g.state ~= "Dead") then b:SetAttribute("Mark", "") end
	if b and ballState.broken and now >= ballState.back then
		ballState.broken = false
		b.Transparency = ballState.own and 0.25 or 0.15
		for _, d in b:GetDescendants() do if d:IsA("BasePart") then d.Transparency = 0 end end
		local pp = b:FindFirstChildOfClass("ProximityPrompt")
		if pp then pp.Enabled = true end
		local l = b:FindFirstChildOfClass("PointLight")
		if l then l.Enabled = true end
		if g and g.def.ability.kind == "fortune" and g.state ~= "Dead" then b:SetAttribute("Mark", "CRYSTAL BALL") end
		H.fx("BallReform", b.Position)
	end
end

function CM.clear()
	clearCurses()
	if ballState.part then ballState.part:SetAttribute("Mark", "") end
	if ballState.own and ballState.part then ballState.part:Destroy() end
	ballState.part, ballState.own, ballState.broken, ballState.model = nil, false, false, nil
	local f = workspace:FindFirstChild("CarnivalFx")
	if f then f:ClearAllChildren() end
end

return CM
