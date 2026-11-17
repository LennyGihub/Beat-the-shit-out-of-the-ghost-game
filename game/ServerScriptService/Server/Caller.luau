--!strict
-- THE CALLER (Shared/Monsters "Caller"): a masked killer with a knife. Two things live here:
--
--   * AMBUSH (his ability, kind = "ambush"; Abilities hands try / step / interrupt / clear over, like the Goblin's
--     loot). He disappears and SITS DOWN IN A CORNER of a room (a real corner: a wall at his back and one at his
--     side, nothing standing in it), far from the players and out of their sight, as if asleep. A phone starts
--     ringing on one of the map's telephone tables (<map>.PhoneSpots, built by tools/build/maps/phones.luau; the
--     clients outline it in yellow and point an arrow at it: Client/CallerMarks). Whoever answers gets a call
--     (Client/CallerUI): he talks them into going somewhere, and that somewhere is the room he sits in. He never
--     gives the exact spot: only what stands in that room ("upstairs, by the piano") - and when he names it, the
--     room is outlined for every player. Not answering changes nothing for him.
--       - a player LOOKS at him (he is in front of them, in plain sight, for a moment): he wakes, gets up and
--         rushes them. No extra damage: he fights as usual, only faster for a few seconds (ability.rush);
--       - a player comes INTO HIS ROOM WITHOUT LOOKING at him (or right next to him): he is up and on them from
--         behind, a stab for extra damage (ability.dmg);
--       - a player hits him while he sits or gets up: that hit does ability.bonus times its damage
--         (Caller.onHit, called by Ghost.hit);
--       - nobody comes for ability.hide seconds: he leaves his corner and hunts again.
--   * FLANKING (def.flank; Ghost's chase asks Caller.flankGoal): he doesn't run straight at a player who is facing
--     him, he goes round to their back (not while he rushes).
-- Studio test hook: player attribute DebugAnswer (any new value) answers the ringing phone for that player.
local RunService = game:GetService("RunService")
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)

local Caller = {}
local H: any = nil -- Abilities' helpers: setPhase, start, finish, hover, flat, warded, hrpOf, matchPlayers, fx, dmgScale
function Caller.init(h) H = h end
local rng = Random.new()

local RING = "rbxassetid://9117304268" -- an old hand-crank telephone (Creator Store, Pro Sound Effects)
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
type Phone = { model: Model, base: BasePart, prompt: ProximityPrompt, ring: Sound, at: Vector3, conns: { RBXScriptConnection } }
local phone: Phone? = nil

local function removePhone()
	local ph = phone
	phone = nil
	if ph then
		for _, c in ph.conns do c:Disconnect() end
		if ph.model.Parent then ph.model:Destroy() end
	end
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

-- One of the map's telephone tables: not next to a player, not next to his corner, on the target's floor if
-- possible, a fair walk away. (A map without tables: on the floor, a little way from the player.)
local function phoneSpot(g, target: BasePart, hide: Vector3): CFrame
	local live = workspace:FindFirstChild("Mansion")
	local spots = live and live:FindFirstChild("PhoneSpots")
	local best: CFrame?, bestScore = nil, -math.huge
	if spots then
		for _, m in spots:GetChildren() do
			local top = m:FindFirstChild("Top")
			if top and top:IsA("BasePart") then
				local at = top.Position + Vector3.new(0, top.Size.Y / 2 + 0.06, 0)
				local d = (at - target.Position).Magnitude
				local fromHim = (at - hide).Magnitude
				local sameFloor = math.abs((at.Y - 3.2) - (target.Position.Y - 3)) < 6
				local score = -math.abs(d - 40) * 0.4 + (sameFloor and 14 or 0) + math.min(fromHim, 45) * 0.4 + rng:NextNumber(0, 16)
				if d < 12 then score -= 60 end
				if fromHim < 22 then score -= 80 end
				if score > bestScore then
					best, bestScore = CFrame.new(at) * top.CFrame.Rotation, score
				end
			end
		end
	end
	if best then return best end
	local a = rng:NextNumber(0, math.pi * 2)
	local at = target.Position + Vector3.new(math.cos(a) * 16, 0, math.sin(a) * 16)
	local floor = workspace:Raycast(at + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0), g.rp)
	return CFrame.new(floor and floor.Position or (target.Position - Vector3.new(0, 3, 0)))
end

-- the player picked it up: his lie, with the room he is in worked into it (never the exact spot); when he names
-- the room, it is outlined for everybody in the run
local function answer(ph: Phone, g, p: Player)
	local ab = g.ab
	if phone ~= ph or not ab or ab.kind ~= "ambush" or ab.answered or not p:GetAttribute("InMatch") then return end
	ab.answered = p
	ph.ring:Stop()
	ph.prompt.Enabled = false
	ph.model:SetAttribute("Ringing", false)
	local place = placeHint(g, ab.hide)
	local lines, hintAt = {}, 1
	for i, line in CALLS[rng:NextInteger(1, #CALLS)] do
		if string.find(line, "{place}", 1, true) then hintAt = i end
		table.insert(lines, (string.gsub(line, "{place}", place)))
	end
	Remotes.Fx:FireClient(p, "CallerCall", lines, LINE_TIME)
	for _, o in H.matchPlayers() do
		if o ~= p then Remotes.Fx:FireClient(o, "Toast", string.upper(p.DisplayName) .. " PICKED UP THE PHONE") end
	end
	task.delay((hintAt - 1) * LINE_TIME + 1.4, function()
		if g.ab ~= ab or ab.phase ~= "hide" or not ab.roomCF then return end
		for _, o in H.matchPlayers() do
			Remotes.Fx:FireClient(o, "CallerRoom", ab.roomCF, ab.roomSize, math.max(4, ab.untilT - os.clock()))
		end
	end)
end

local function spawnPhone(g, target: BasePart, hide: Vector3)
	removePhone()
	local cf = phoneSpot(g, target, hide)
	local m, base = buildPhone(cf)
	local ring = Instance.new("Sound")
	ring.Name = "Ring"; ring.SoundId = RING; ring.Looped = true; ring.Volume = 1.6
	ring.RollOffMode = Enum.RollOffMode.InverseTapered; ring.RollOffMinDistance = 14; ring.RollOffMaxDistance = 190
	ring.Parent = base
	local pp = Instance.new("ProximityPrompt")
	pp.Style = Enum.ProximityPromptStyle.Custom -- the game's own prompt (Client/Prompts), not Roblox's bubble
	pp.ActionText = "Answer"; pp.ObjectText = "The phone"; pp.KeyboardKeyCode = Enum.KeyCode.F
	pp.HoldDuration = 0.4; pp.MaxActivationDistance = 10; pp.RequiresLineOfSight = false
	pp.Parent = base
	m:SetAttribute("Ringing", true) -- Client/CallerMarks: yellow outline + the arrow, while this is true
	m.Parent = workspace
	ring:Play()
	local ph: Phone = { model = m, base = base, prompt = pp, ring = ring, at = cf.Position, conns = {} }
	phone = ph
	pp.Triggered:Connect(function(p: Player) answer(ph, g, p) end)
	if RunService:IsStudio() then
		for _, p in H.matchPlayers() do
			table.insert(ph.conns, p:GetAttributeChangedSignal("DebugAnswer"):Connect(function() answer(ph, g, p) end))
		end
	end
end

-- HIS CORNER ------------------------------------------------------------------------------------------------
local WALL_NEAR, SIT_OFF = 6.5, 2 -- a wall this close on two sides makes a corner; he sits this far from both

-- A corner to sit in, on the target's floor: a wall at his back and one at his side, nothing standing in it, open
-- floor in front, far from every player and out of their sight. Returns where he sits (root height), a point in
-- front of him (he faces out of the corner) and the floor's height.
local function hideSpot(g, G, target: BasePart): (Vector3?, Vector3?, number?)
	local B = G.houseBounds()
	local under = workspace:Raycast(target.Position, Vector3.new(0, -14, 0), g.rp)
	if not under then return nil, nil, nil end
	local floorY = under.Position.Y
	local players = {}
	for _, p in H.matchPlayers() do
		local hrp = H.hrpOf(p)
		if hrp then table.insert(players, hrp.Position) end
	end
	local fp = OverlapParams.new()
	fp.FilterType = Enum.RaycastFilterType.Include
	local ff = Furniture.folder()
	fp.FilterDescendantsInstances = { ff or workspace.Terrain }
	local best: Vector3?, bestInto: Vector3?, bestScore = nil, nil, -math.huge
	for _, minDist in { 26, 17 } do
		for x = B.min.X + 4, B.max.X - 4, 4 do
			for z = B.min.Z + 4, B.max.Z - 4, 4 do
				local f = workspace:Raycast(Vector3.new(x, floorY + 6, z), Vector3.new(0, -9, 0), g.rp)
				if f and f.Normal.Y > 0.9 and math.abs(f.Position.Y - floorY) < 1.5 then
					local c = f.Position + Vector3.new(0, 4, 0)
					-- the nearest wall along X and along Z
					local wx: number?, sx = nil, 0
					local wz: number?, sz = nil, 0
					for _, sg in { 1, -1 } do
						local rx = workspace:Raycast(c, Vector3.new(sg * WALL_NEAR, 0, 0), g.rp)
						if rx and math.abs(rx.Normal.X) > 0.9 and (not wx or rx.Distance < math.abs((wx :: number) - x)) then wx, sx = rx.Position.X, sg end
						local rz = workspace:Raycast(c, Vector3.new(0, 0, sg * WALL_NEAR), g.rp)
						if rz and math.abs(rz.Normal.Z) > 0.9 and (not wz or rz.Distance < math.abs((wz :: number) - z)) then wz, sz = rz.Position.Z, sg end
					end
					if wx and wz then
						local sit = Vector3.new(wx - sx * SIT_OFF, f.Position.Y, wz - sz * SIT_OFF)
						local chest = sit + Vector3.new(0, 3, 0)
						local into = Vector3.new(-sx, 0, -sz).Unit
						local f2 = workspace:Raycast(sit + Vector3.new(0, 3, 0), Vector3.new(0, -5, 0), g.rp)
						-- still a corner from where he sits (both walls really there), a floor under him, head room,
						-- open floor ahead, nothing standing in the corner
						if f2 and math.abs(f2.Position.Y - f.Position.Y) < 0.6
							and workspace:Raycast(chest, Vector3.new(sx * (SIT_OFF + 1.5), 0, 0), g.rp)
							and workspace:Raycast(chest, Vector3.new(0, 0, sz * (SIT_OFF + 1.5)), g.rp)
							and not workspace:Raycast(sit + Vector3.new(0, 0.5, 0), Vector3.new(0, 8, 0), g.rp)
							and not workspace:Raycast(chest, into * 9, g.rp)
							and #workspace:GetPartBoundsInBox(CFrame.new(sit + Vector3.new(0, 2.6, 0)), Vector3.new(4.2, 5, 4.2), fp) == 0 then
							local near, seen = math.huge, false
							for _, pp in players do
								near = math.min(near, (pp - sit).Magnitude)
								if not workspace:Raycast(chest, pp - chest, g.rp) then seen = true; break end
							end
							if not seen and near >= minDist then
								local ahead = workspace:Raycast(chest, into * 30, g.rp)
								local score = math.min(ahead and ahead.Distance or 30, 24) * 0.4 - math.abs(near - 42) * 0.25 + rng:NextNumber(0, 10)
								if score > bestScore then best, bestInto, bestScore = sit + Vector3.new(0, g.hover, 0), into, score end
							end
						end
					end
				end
			end
		end
		if best then break end
	end
	if not best or not bestInto then return nil, nil, nil end
	return best, best + bestInto * 6, floorY
end

-- The room round his corner, as a box: how far the walls are along +X -X +Z -Z. Each side is the median of a fan
-- of rays, so a doorway (rays that run on into the next room) or a railing does not decide it.
local function roomBox(g, G, hide: Vector3, floorY: number): (CFrame, Vector3)
	local B = G.houseBounds()
	local c = Vector3.new(hide.X, floorY + 4, hide.Z)
	local function reach(dir: Vector3): number
		local lat = Vector3.new(-dir.Z, 0, dir.X)
		local ds = {}
		for _, h in { 0, 5 } do
			local o0 = c + Vector3.new(0, h, 0)
			for _, k in { -7, -3.5, 0, 3.5, 7 } do
				if k == 0 or not workspace:Raycast(o0, lat * k, g.rp) then
					local r = workspace:Raycast(o0 + lat * k, dir * 120, g.rp)
					table.insert(ds, r and r.Distance or 120)
				end
			end
		end
		table.sort(ds)
		return ds[math.max(1, math.ceil(#ds / 2))]
	end
	local x1 = math.max(c.X - reach(-Vector3.xAxis), B.min.X)
	local x2 = math.min(c.X + reach(Vector3.xAxis), B.max.X)
	local z1 = math.max(c.Z - reach(-Vector3.zAxis), B.min.Z)
	local z2 = math.min(c.Z + reach(Vector3.zAxis), B.max.Z)
	local up = workspace:Raycast(c, Vector3.new(0, 40, 0), g.rp)
	local h = math.clamp((up and up.Distance or 16) + 4, 8, 20)
	return CFrame.new((x1 + x2) / 2, floorY + h / 2, (z1 + z2) / 2), Vector3.new(math.max(x2 - x1, 4), h, math.max(z2 - z1, 4))
end

local function cleanup(g)
	removePhone()
	H.fx("CallerRoomOff")
	if g.model then
		g.model:SetAttribute("Hiding", false)
		g.model:SetAttribute("Vanish", false)
	end
end

-- ABILITY ---------------------------------------------------------------------------------------------------
function Caller.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	g.ambushReady = g.ambushReady or (now + (a.first or 10)) -- he fights for a while before his first ambush
	if now < g.ambushReady or H.warded(target) then return false end
	local hide, face, floorY = hideSpot(g, G, thrp)
	if not hide then
		g.ambushReady = now + 4 -- no free corner right now: look again soon
		return false
	end
	H.start(g, G, "vanish", 0.9, { hide = hide, lure = face, floorY = floorY, victimHrp = thrp, seen = {} })
	g.model:SetAttribute("Vanish", true)
	Remotes.Fx:FireAllClients("GhostVanish", g.hrp.Position)
	for _, p in H.matchPlayers() do Remotes.Fx:FireClient(p, "Toast", "HE'S GONE QUIET...  A PHONE IS RINGING SOMEWHERE") end
	return true
end

-- he stays exactly where he sits
local function hold(g, ab, pos: Vector3)
	g.lv.VectorVelocity = Vector3.new((ab.hide.X - pos.X) * 4, (ab.hide.Y - pos.Y) * 4, (ab.hide.Z - pos.Z) * 4)
end

function Caller.step(g, G, dt: number, now: number, target: Player?, thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	local pos = g.hrp.Position
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	if ab.phase == "vanish" then
		if now < ab.untilT then return end
		-- into his corner, sitting, facing out of it
		local face = Vector3.new(ab.lure.X, ab.hide.Y, ab.lure.Z)
		local cf = (face - ab.hide).Magnitude > 0.5 and CFrame.lookAt(ab.hide, face) or CFrame.new(ab.hide)
		g.model:PivotTo(cf)
		g.ao.CFrame = cf.Rotation
		g.hrp.AssemblyLinearVelocity = Vector3.zero
		g.hrp.AssemblyAngularVelocity = Vector3.zero
		g.path = nil
		g.model:SetAttribute("Hiding", true)
		g.model:SetAttribute("Vanish", false)
		ab.roomCF, ab.roomSize = roomBox(g, G, ab.hide, ab.floorY)
		local ringFor = (ab.victimHrp and ab.victimHrp.Parent) and ab.victimHrp or thrp
		if ringFor then spawnPhone(g, ringFor, ab.hide) end
		ab.nextBreath = now + 3
		H.setPhase(g, "hide", a.hide or 30)
	elseif ab.phase == "hide" then
		hold(g, ab, pos)
		-- a slow breath now and then: the only sound he makes (Client: quiet, at his corner)
		if now >= ab.nextBreath then
			ab.nextBreath = now + rng:NextNumber(3.5, 5.5)
			H.fx("AmbushBreath", pos)
		end
		local head = Vector3.new(pos.X, ab.floorY + 2.6, pos.Z) -- he sits: his head is low
		local half = ab.roomSize / 2
		local looker: Player? = nil
		local intruder: Player?, intruderD = nil, math.huge
		for _, p in H.matchPlayers() do
			local hrp = H.hrpOf(p)
			if hrp and not H.warded(p) then
				local to = hrp.Position - pos
				local d = to.Magnitude
				local clear = not workspace:Raycast(head, hrp.Position - head, g.rp)
				-- LOOKING at him: he is in front of them and in plain sight (in first person the body turns with the view)
				local looking = clear and d < (a.wake or 45) and H.flat(hrp.CFrame.LookVector):Dot(H.flat(-to)) > 0.5
				if looking then
					ab.seen[p] = ab.seen[p] or now
					if now - ab.seen[p] >= (a.notice or 0.25) then looker = looker or p end
				else
					ab.seen[p] = nil
					-- in his room (or on top of him) with their eyes somewhere else
					local l = ab.roomCF:PointToObjectSpace(hrp.Position)
					local inRoom = math.abs(l.X) < half.X - 0.5 and math.abs(l.Z) < half.Z - 0.5 and math.abs(hrp.Position.Y - 3 - ab.floorY) < 6
					if (d < 5 or (inRoom and clear and d < (a.enter or 34))) and d < intruderD then intruder, intruderD = p, d end
				end
			end
		end
		if looker then
			-- seen: he wakes and gets up. No trap: he just comes at them
			ab.victim = looker
			removePhone()
			g.model:SetAttribute("Hiding", false)
			H.fx("CallerRoomOff")
			H.fx("AmbushWake", pos)
			Remotes.Fx:FireClient(looker, "Toast", "HE SAW YOU LOOKING - HERE HE COMES", false)
			H.setPhase(g, "wake", a.rise or 0.7)
			return
		end
		if intruder then
			ab.victim = intruder
			ab.springAt = now + (a.react or 0.4)
			H.fx("AmbushBreath", pos)
			H.setPhase(g, "spring", (a.react or 0.4) + 0.1)
			return
		end
		if now >= ab.untilT then
			-- nobody came: he gives the corner up and goes hunting again
			cleanup(g)
			H.finish(g, G, 0.2)
		end
	elseif ab.phase == "wake" then
		-- getting up, eyes on whoever found him
		hold(g, ab, pos)
		local vh = ab.victim and H.hrpOf(ab.victim)
		if vh then
			local to = Vector3.new(vh.Position.X - pos.X, 0, vh.Position.Z - pos.Z)
			if to.Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(Vector3.zero, to) end
		end
		if now >= ab.untilT then
			cleanup(g)
			g.rushUntil = now + (a.rush or 4) -- Ghost's chase: faster, straight at them (no flanking, no stalking)
			H.finish(g, G, 0.1)
		end
	elseif ab.phase == "spring" then
		-- they never looked: a heartbeat, then he is off the floor
		hold(g, ab, pos)
		local vh = ab.victim and H.hrpOf(ab.victim)
		if vh then
			local to = Vector3.new(vh.Position.X - pos.X, 0, vh.Position.Z - pos.Z)
			if to.Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(Vector3.zero, to) end
		end
		if now >= ab.springAt then
			removePhone()
			g.model:SetAttribute("Hiding", false)
			H.fx("CallerRoomOff")
			Remotes.Fx:FireAllClients("AmbushStrike", g.model)
			if ab.victim then Remotes.Fx:FireClient(ab.victim, "Toast", "BEHIND YOU!", false) end
			-- long enough to cross the room
			local far = vh and (vh.Position - pos).Magnitude or 10
			H.setPhase(g, "strike", math.clamp(far / (a.lunge or 70) + 0.4, 0.55, 1.1))
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

-- Ghost.hit asks: is this the hit that caught him on the floor (sitting or getting up)? Returns the damage
-- multiplier (1 = no).
function Caller.onHit(g, by: Player?): number
	local ab = g.ab
	if not ab or ab.kind ~= "ambush" or (ab.phase ~= "hide" and ab.phase ~= "spring" and ab.phase ~= "wake") or ab.found then return 1 end
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
	if dist < 7 or dist > 28 or (g.rushUntil and now < g.rushUntil) then return tp end
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
