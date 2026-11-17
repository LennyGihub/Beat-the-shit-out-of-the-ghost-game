--!strict
-- THE CALLER (Shared/Monsters "Caller"): a masked killer with a knife. Two things live here:
--
--   * AMBUSH (his ability, kind = "ambush"; Abilities hands try / step / interrupt / clear over, like the Goblin's
--     loot). He disappears and hides in a corner of the house, far from the players and out of their sight. An old
--     phone starts ringing on a table somewhere. Whoever answers gets a call (Client/CallerUI): he talks them into
--     going somewhere, and that somewhere is the room he hides in. He never gives the exact spot: only what
--     stands in that room ("upstairs, by the piano"). Not answering changes nothing for him: the players just get
--     no hint of where the trap is.
--       - a player walks into it (close to him, in his sight) without having hit him: he lunges and
--         stabs for extra damage (ability.dmg);
--       - a player finds him and hits him first: that hit does ability.bonus times its damage and he is staggered
--         (Caller.onHit, called by Ghost.hit);
--       - nobody comes for ability.hide seconds: he leaves his corner and hunts again.
--   * FLANKING (def.flank; Ghost's chase asks Caller.flankGoal): he doesn't run straight at a player who is facing
--     him, he goes round to their back.
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)

local Caller = {}
local H: any = nil -- Abilities' helpers: setPhase, start, finish, hover, flat, warded, hrpOf, matchPlayers, fx, dmgScale
function Caller.init(h) H = h end
local rng = Random.new()

local RING = "rbxassetid://9117304268" -- an old hand-crank telephone (Creator Store, Pro Sound Effects)
-- furniture a phone can stand on
local TABLES = { SideTable = true, Desk = true, Counter = true, CoffeeTable = true, KitchenTable = true, ReadingTable = true,
	DiningTable = true, Nightstand = true, Dresser = true }
-- what he says on the phone: a lie to bring them to him. {place} = the room he hides in, told by what stands in it
local CALLS = {
	{ "Hello?  ...  Don't hang up.", "Someone left a bag of cash {place}. I can see it from where I am.", "Go and take it. I'll wait." },
	{ "You sound out of breath.", "There is one place in this house where it can't reach you: {place}.", "Run." },
	{ "Do you like scary stories?", "This one ends {place}.", "Come and see how." },
	{ "I'm not the one you should be afraid of.", "Your friend is hurt. They're lying {place}, asking for you.", "Hurry. They don't have long." },
	{ "Still alive? Good. I like the ones who last.", "There is a way out of this house. Look {place}. Nobody ever does.", "Trust me." },
}
-- how he names a room: by a piece of furniture (the rarest kind he can see from his corner is the best clue;
-- with nothing in sight, the nearest notable piece on his floor)
local THINGS = {
	Piano = "the piano", PoolTable = "the pool table", Bathtub = "a bathtub", Toilet = "the toilet", Sink = "a sink",
	Bed = "a bed", Crib = "the crib", Stove = "the stove", IceBox = "the ice box", Counter = "a kitchen counter",
	KitchenTable = "the kitchen table", DiningTable = "the long dining table", TV = "the television", Sofa = "a sofa",
	Wardrobe = "a wardrobe", Dresser = "a dresser", Desk = "a writing desk", ReadingTable = "the reading table",
	Bookshelf = "bookshelves", GrandfatherClock = "a grandfather clock", Globe = "a globe", Bust = "a stone bust",
	ToyChest = "a toy chest", RockingChair = "a rocking chair", StandingMirror = "a tall mirror", Armchair = "armchairs",
	Barrel = "barrels", Crate = "crates", Cabinet = "a cabinet", CoffeeTable = "a low table", Nightstand = "a nightstand", Bench = "a bench",
}
local LINE_TIME = 2.6 -- seconds a line stays up (Client/CallerUI uses the same)

-- THE PHONE -------------------------------------------------------------------------------------------------
type Phone = { model: Model, base: BasePart, prompt: ProximityPrompt, ring: Sound, on: Model?, at: Vector3 }
local phone: Phone? = nil

local function removePhone()
	local ph = phone
	phone = nil
	if ph and ph.model.Parent then ph.model:Destroy() end
end
-- "upstairs, in the room with the piano" / "downstairs, not far from a grandfather clock": the floor he is on and
-- a piece of furniture that tells the room. Never the spot itself.
local function placeHint(g, hide: Vector3): string
	local feet = hide.Y - g.hover
	local f = Furniture.folder()
	local total = {} :: { [string]: number }
	local inSight = {} :: { [string]: boolean }
	local nearest = {} :: { [string]: number } -- kind -> distance, same floor, any wall in between
	local lowest = feet
	local chest = Vector3.new(hide.X, feet + 4, hide.Z)
	if f then
		for _, m in f:GetChildren() do
			if m:IsA("Model") and Furniture.isValid(m) then
				local kind = tostring(m:GetAttribute("Kind") or m.Name)
				total[kind] = (total[kind] or 0) + 1
				local cf, size = m:GetBoundingBox()
				lowest = math.min(lowest, cf.Position.Y - size.Y / 2)
				local to = cf.Position - chest
				if THINGS[kind] and math.abs(cf.Position.Y - chest.Y) < 7 then
					if to.Magnitude < 22 then
						local r = workspace:Raycast(chest, to, g.rp)
						if not r or r.Distance > to.Magnitude - 3 then inSight[kind] = true end
					end
					if to.Magnitude < 45 then nearest[kind] = math.min(nearest[kind] or math.huge, to.Magnitude) end
				end
			end
		end
	end
	local floor = feet > lowest + 8 and "upstairs" or "downstairs"
	-- in his room: the rarest kind there
	local best: string?, bestN = nil, math.huge
	for kind in inSight do
		local n = total[kind] + rng:NextNumber(0, 0.5)
		if n < bestN then best, bestN = kind, n end
	end
	if best then return floor .. ", in the room with " .. THINGS[best] end
	-- nothing stands in his corner: the closest piece, common kinds counted as further away
	for kind, d in nearest do
		local n = d + math.min(total[kind], 12) * 1.5
		if n < bestN then best, bestN = kind, n end
	end
	if best then return floor .. ", not far from " .. THINGS[best] end
	return floor .. ", in the emptiest corner you can find"
end

-- an old black rotary phone, about a stud and a half wide
local function buildPhone(cf: CFrame): (Model, BasePart)
	local m = Instance.new("Model")
	m.Name = "CallerPhone"
	local BLACK, IVORY, BRASS = Color3.fromRGB(22, 20, 20), Color3.fromRGB(226, 216, 190), Color3.fromRGB(170, 130, 60)
	local function part(name: string, size: Vector3, rel: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): Part
		local p = Instance.new("Part")
		p.Name = name; p.Size = size; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
		if shape then p.Shape = shape end
		p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
		p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
		p.CFrame = cf * rel
		p.Parent = m
		return p
	end
	local base = part("Base", Vector3.new(1.7, 0.5, 1.3), CFrame.new(0, 0.25, 0), BLACK)
	part("Slope", Vector3.new(1.5, 0.45, 0.9), CFrame.new(0, 0.6, 0.1) * CFrame.Angles(0.35, 0, 0), BLACK)
	part("Dial", Vector3.new(0.12, 0.8, 0.8), CFrame.new(0, 0.72, -0.2) * CFrame.Angles(0.35, 0, math.pi / 2), IVORY, nil, Enum.PartType.Cylinder)
	part("DialHub", Vector3.new(0.16, 0.3, 0.3), CFrame.new(0, 0.74, -0.2) * CFrame.Angles(0.35, 0, math.pi / 2), BRASS, Enum.Material.Metal, Enum.PartType.Cylinder)
	for _, sx in { -1, 1 } do
		part("Cradle", Vector3.new(0.18, 0.45, 0.5), CFrame.new(sx * 0.6, 0.95, 0.35), BLACK)
		part("Earpiece", Vector3.new(0.5, 0.36, 0.5), CFrame.new(sx * 0.85, 1.15, 0.35), BLACK)
	end
	part("Handset", Vector3.new(1.9, 0.26, 0.34), CFrame.new(0, 1.3, 0.35), BLACK)
	local lamp = part("Lamp", Vector3.new(0.16, 0.16, 0.16), CFrame.new(0.6, 0.55, -0.55), Color3.fromRGB(255, 60, 40), Enum.Material.Neon, Enum.PartType.Ball)
	local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 70, 40); l.Range = 9; l.Brightness = 1.2; l.Shadows = false; l.Parent = lamp
	m.PrimaryPart = base
	return m, base
end

-- a table top for the phone: not next to a player, not next to his corner, on the target's floor if possible
local function phoneSpot(g, target: BasePart, hide: Vector3): (CFrame, Model?)
	local f = Furniture.folder()
	local best: CFrame?, bestOn: Model?, bestScore = nil, nil, -math.huge
	if f then
		for _, m in f:GetChildren() do
			if m:IsA("Model") and TABLES[tostring(m:GetAttribute("Kind") or m.Name)] and Furniture.isValid(m) and not m:GetAttribute("CarriedBy") then
				local cf, size = m:GetBoundingBox()
				local top = cf.Position + Vector3.new(0, size.Y / 2, 0)
				local d = (top - target.Position).Magnitude
				local up = cf.UpVector.Y
				if up > 0.9 and d > 12 and (top - hide).Magnitude > 20 then
					local sameFloor = math.abs((top.Y - 5) - (target.Position.Y - 3)) < 6
					local score = -math.abs(d - 32) + (sameFloor and 25 or 0) + rng:NextNumber(0, 12)
					if score > bestScore then
						best = CFrame.new(top) * CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0)
						bestOn, bestScore = m, score
					end
				end
			end
		end
	end
	if best then return best, bestOn end
	-- no table left standing: on the floor, a little way from the player
	local a = rng:NextNumber(0, math.pi * 2)
	local at = target.Position + Vector3.new(math.cos(a) * 16, 0, math.sin(a) * 16)
	local floor = workspace:Raycast(at + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), g.rp)
	return CFrame.new(floor and floor.Position or (target.Position - Vector3.new(0, 3, 0))), nil
end

local function spawnPhone(g, target: BasePart, hide: Vector3)
	removePhone()
	local cf, on = phoneSpot(g, target, hide)
	local m, base = buildPhone(cf)
	local ring = Instance.new("Sound")
	ring.Name = "Ring"; ring.SoundId = RING; ring.Looped = true; ring.Volume = 1.6
	ring.RollOffMode = Enum.RollOffMode.InverseTapered; ring.RollOffMinDistance = 14; ring.RollOffMaxDistance = 190
	ring.Parent = base
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = "Answer"; pp.ObjectText = "Ringing phone"; pp.KeyboardKeyCode = Enum.KeyCode.F
	pp.HoldDuration = 0.4; pp.MaxActivationDistance = 10; pp.RequiresLineOfSight = false
	pp.Parent = base
	m.Parent = workspace
	ring:Play()
	local ph: Phone = { model = m, base = base, prompt = pp, ring = ring, on = on, at = cf.Position }
	phone = ph
	pp.Triggered:Connect(function(p: Player)
		local ab = g.ab
		if phone ~= ph or not ab or ab.kind ~= "ambush" or ab.answered or not p:GetAttribute("InMatch") then return end
		ab.answered = p
		ring:Stop()
		pp.Enabled = false
		-- his lie, with the room he is in worked into it (never the exact spot)
		local place = placeHint(g, ab.hide)
		local lines = {}
		for _, line in CALLS[rng:NextInteger(1, #CALLS)] do
			table.insert(lines, (string.gsub(line, "{place}", place)))
		end
		Remotes.Fx:FireClient(p, "CallerCall", lines, LINE_TIME)
		for _, o in H.matchPlayers() do
			if o ~= p then Remotes.Fx:FireClient(o, "Toast", string.upper(p.DisplayName) .. " PICKED UP THE PHONE") end
		end
	end)
end

-- the table it stood on was thrown or smashed: the phone drops to the floor and keeps ringing
local function watchPhone()
	local ph = phone
	if not ph or not ph.on or not ph.base.Anchored then return end
	local on = ph.on
	local gone = on.Parent == nil
	if not gone then
		local cf, size = on:GetBoundingBox()
		gone = (cf.Position + Vector3.new(0, size.Y / 2, 0) - ph.at).Magnitude > 1.5
	end
	if gone then
		ph.on = nil
		for _, d in ph.model:GetChildren() do
			if d:IsA("BasePart") and d ~= ph.base then
				d.Anchored = false; d.Massless = true
				local w = Instance.new("WeldConstraint"); w.Part0 = ph.base; w.Part1 = d; w.Parent = d
			end
		end
		ph.base.CanCollide = true
		ph.base.Anchored = false
	end
end

-- HIS CORNER ------------------------------------------------------------------------------------------------
-- A place to hide on the target's floor: far from every player, out of their sight, with walls close on two
-- sides when there is such a place. Returns where he stands (root height) and the open spot in front of it.
local function hideSpot(g, G, target: BasePart): (Vector3?, Vector3?)
	local B = G.houseBounds()
	local under = workspace:Raycast(target.Position, Vector3.new(0, -14, 0), g.rp)
	if not under then return nil, nil end
	local floorY = under.Position.Y
	local players = {}
	for _, p in H.matchPlayers() do
		local hrp = H.hrpOf(p)
		if hrp then table.insert(players, hrp.Position) end
	end
	local best: Vector3?, bestScore = nil, -math.huge
	for _, minDist in { 26, 17 } do
		for x = B.min.X + 5, B.max.X - 5, 5 do
			for z = B.min.Z + 5, B.max.Z - 5, 5 do
				local f = workspace:Raycast(Vector3.new(x, floorY + 6, z), Vector3.new(0, -9, 0), g.rp)
				if f and f.Normal.Y > 0.9 and math.abs(f.Position.Y - floorY) < 1.5 then
					local pos = f.Position + Vector3.new(0, g.hover, 0)
					local chest = f.Position + Vector3.new(0, 4, 0)
					local near, seen = math.huge, false
					for _, pp in players do
						near = math.min(near, (pp - pos).Magnitude)
						if not workspace:Raycast(chest, pp - chest, g.rp) then seen = true; break end
					end
					-- head room, and not standing in a wall
					if not seen and near >= minDist and not workspace:Raycast(f.Position + Vector3.new(0, 0.5, 0), Vector3.new(0, 8, 0), g.rp) then
						-- a corner of a room, not a gap between walls: something at his back and one side, and
						-- open floor in front of him (the players need room to come at him, or round him)
						local walls, open = 0, 0
						for i = 0, 7 do
							local a = i * math.pi / 4
							local r = workspace:Raycast(chest, Vector3.new(math.cos(a), 0, math.sin(a)) * 14, g.rp)
							local free = r and r.Distance or 14
							if free < 5 then walls += 1 end
							if free >= 11 then open += 1 end
						end
						if walls >= 1 and walls <= 5 and open >= 2 then
							local score = math.min(walls, 4) * 6 + open * 2 - math.abs(near - 42) * 0.25 + rng:NextNumber(0, 8)
							if score > bestScore then best, bestScore = pos, score end
						end
					end
				end
			end
		end
		if best then break end
	end
	if not best then return nil, nil end
	-- the open ground in front of him: that is where the call sends them
	local chest = best - Vector3.new(0, g.hover - 4, 0)
	local lure, room = best, 0
	for i = 0, 15 do
		local a = i * math.pi / 8
		local dir = Vector3.new(math.cos(a), 0, math.sin(a))
		local r = workspace:Raycast(chest, dir * 14, g.rp)
		local free = r and r.Distance or 14
		if free > room then
			room = free
			lure = best + dir * math.min(free - 2, 9)
		end
	end
	local lf = workspace:Raycast(lure, Vector3.new(0, -(g.hover + 6), 0), g.rp)
	return best, lf and (lf.Position + Vector3.new(0, 2.5, 0)) or lure
end

local function cleanup(g)
	removePhone()
	if g.model then
		g.model:SetAttribute("Hiding", false)
		g.model:SetAttribute("Vanish", false)
	end
end

-- ABILITY ---------------------------------------------------------------------------------------------------
function Caller.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	g.ambushReady = g.ambushReady or (now + (a.first or 10)) -- he fights for a while before his first ambush
	if now < g.ambushReady or H.warded(target) then return false end
	local hide, lure = hideSpot(g, G, thrp)
	if not hide then
		g.ambushReady = now + 4 -- nowhere to hide right now: look again soon
		return false
	end
	H.start(g, G, "vanish", 0.9, { hide = hide, lure = lure, victimHrp = thrp })
	g.model:SetAttribute("Vanish", true)
	Remotes.Fx:FireAllClients("GhostVanish", g.hrp.Position)
	for _, p in H.matchPlayers() do Remotes.Fx:FireClient(p, "Toast", "HE'S GONE QUIET...  A PHONE IS RINGING SOMEWHERE") end
	return true
end

function Caller.step(g, G, dt: number, now: number, target: Player?, thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.phase == "vanish" then
		if now < ab.untilT then return end
		-- into his corner, crouched, facing the open ground he will send them to
		local face = Vector3.new(ab.lure.X, ab.hide.Y, ab.lure.Z)
		local cf = (face - ab.hide).Magnitude > 0.5 and CFrame.lookAt(ab.hide, face) or CFrame.new(ab.hide)
		g.model:PivotTo(cf)
		g.ao.CFrame = cf.Rotation
		g.hrp.AssemblyLinearVelocity = Vector3.zero
		g.hrp.AssemblyAngularVelocity = Vector3.zero
		g.path = nil
		g.model:SetAttribute("Hiding", true)
		g.model:SetAttribute("Vanish", false)
		local ringFor = (ab.victimHrp and ab.victimHrp.Parent) and ab.victimHrp or thrp
		if ringFor then spawnPhone(g, ringFor, ab.hide) end
		ab.nextBreath = now + 3
		H.setPhase(g, "hide", a.hide or 30)
	elseif ab.phase == "hide" then
		-- he stays exactly where he hid
		g.lv.VectorVelocity = Vector3.new((ab.hide.X - pos.X) * 4, (ab.hide.Y - pos.Y) * 4, (ab.hide.Z - pos.Z) * 4)
		watchPhone()
		-- a breath now and then: the only sound he makes (Client: quiet, at his corner)
		if now >= ab.nextBreath then
			ab.nextBreath = now + rng:NextNumber(3.5, 5.5)
			H.fx("AmbushBreath", pos)
		end
		-- somebody walked into it? He watches the open ground in front of him: anyone who comes close there springs
		-- the trap (outside what he can see, only when they are right on top of him). He needs a moment to spring
		-- (a.react), and a fist reaches a little further than his trigger: a player who has seen him and comes in
		-- swinging lands the first hit, one who walks in unaware gets the knife.
		local chest = pos + Vector3.new(0, 1, 0)
		local look = H.flat(g.hrp.CFrame.LookVector)
		for _, p in H.matchPlayers() do
			local hrp = H.hrpOf(p)
			if hrp and not H.warded(p) then
				local to = hrp.Position - pos
				local d = to.Magnitude
				local inView = look:Dot(H.flat(to)) > 0.2
				if d < 4.5 or (d < (a.trigger or 9) and inView and not workspace:Raycast(chest, hrp.Position - chest, g.rp)) then
					ab.victim = p
					ab.springAt = now + (a.react or 0.4)
					H.fx("AmbushBreath", pos)
					H.setPhase(g, "spring", (a.react or 0.4) + 0.1)
					return
				end
			end
		end
		if now >= ab.untilT then
			-- nobody came: he gives the corner up and goes hunting again
			cleanup(g)
			H.finish(g, G, 0.2)
		end
	elseif ab.phase == "spring" then
		-- he has seen them: a heartbeat, then he is out of his corner
		g.lv.VectorVelocity = Vector3.new((ab.hide.X - pos.X) * 4, (ab.hide.Y - pos.Y) * 4, (ab.hide.Z - pos.Z) * 4)
		local vh = ab.victim and H.hrpOf(ab.victim)
		if vh then
			local to = Vector3.new(vh.Position.X - pos.X, 0, vh.Position.Z - pos.Z)
			if to.Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(Vector3.zero, to) end
		end
		if now >= ab.springAt then
			removePhone()
			g.model:SetAttribute("Hiding", false)
			Remotes.Fx:FireAllClients("AmbushStrike", g.model)
			if ab.victim then Remotes.Fx:FireClient(ab.victim, "Toast", "IT WAS A TRAP!", false) end
			H.setPhase(g, "strike", 0.55)
		end
	elseif ab.phase == "strike" then
		local vh = ab.victim and H.hrpOf(ab.victim)
		if vh then
			local to = Vector3.new(vh.Position.X - pos.X, 0, vh.Position.Z - pos.Z)
			if to.Magnitude > 0.1 then
				g.ao.CFrame = CFrame.lookAt(Vector3.zero, to)
				g.lv.VectorVelocity = H.hover(g, hoverY, to.Unit * (a.lunge or 70))
			end
			if to.Magnitude < 5.5 and math.abs(vh.Position.Y - pos.Y) < 9 then
				G.hitPlayer(ab.victim, nil, (a.dmg or 46) * H.dmgScale(g), H.flat(to) * 55 + Vector3.new(0, 22, 0), "ambush", true, 1.4)
				H.fx("AmbushStab", vh.Position)
				cleanup(g)
				H.finish(g, G, 0.7)
				return
			end
		end
		if now >= ab.untilT then
			cleanup(g)
			H.finish(g, G, 0.5) -- they got out of the way
		end
	else
		cleanup(g)
		H.finish(g, G, 0.2)
	end
end

-- Ghost.hit asks: is this the hit that found him in his corner? Returns the damage multiplier (1 = no).
function Caller.onHit(g, by: Player?): number
	local ab = g.ab
	if not ab or ab.kind ~= "ambush" or (ab.phase ~= "hide" and ab.phase ~= "spring") or ab.found then return 1 end
	ab.found = true
	local bonus = g.def.ability.bonus or 2.5
	H.fx("AmbushFound", g.hrp.Position)
	if by then Remotes.Fx:FireClient(by, "Toast", "YOU GOT HIM FIRST - x" .. tostring(bonus) .. " DAMAGE", true) end
	return bonus
end

-- cut short (knocked back, found, frozen) or over
function Caller.interrupt(g) cleanup(g) end
function Caller.clear()
	removePhone()
end

-- FLANKING --------------------------------------------------------------------------------------------------
-- Where his chase heads for: straight at a player who has their back to him, round to the back of one who is
-- facing him (a point beside and behind them, on the side he is already on).
function Caller.flankGoal(g, thrp: BasePart, dist: number, now: number): Vector3
	local tp = thrp.Position
	if dist < 7 or dist > 28 then return tp end
	local look = H.flat(thrp.CFrame.LookVector)
	local from = H.flat(g.hrp.Position - tp)
	if look:Dot(from) < -0.15 then return tp end -- already behind them
	local perp = Vector3.new(-look.Z, 0, look.X)
	if not g.flankSide or now > (g.flankUntil or 0) then
		g.flankSide = perp:Dot(from) >= 0 and 1 or -1
		g.flankUntil = now + 2.5
	end
	local goal = tp + (perp * g.flankSide * 0.85 - look * 0.55).Unit * 8
	-- not through a wall: then just come straight
	if workspace:Raycast(tp, goal - tp, g.rp) then return tp end
	return goal
end

return Caller
