--!strict
-- The ghost goes limp and flies: a strong hit (heavy item, punch combo) turns her rig into a floppy ragdoll
-- that tumbles across the room and smashes straight through the inside walls (never the outside ones). Walls break into chunks and come back
-- for the next ghost (Ragdoll.restoreWalls). Not realistic on purpose, just funny.
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

local Ragdoll = {}
Ragdoll.MIN_KNOCK = 70 -- knockback needed to knock her out (sledgehammer, golf club, combos...)

local GROUP = "Ragdoll"
pcall(function() PhysicsService:RegisterCollisionGroup(GROUP) end)
pcall(function()
	PhysicsService:CollisionGroupSetCollidable(GROUP, GROUP, false)
	PhysicsService:CollisionGroupSetCollidable(GROUP, "Players", false)
	PhysicsService:CollisionGroupSetCollidable(GROUP, "Carried", false)
end)

-- only the INTERIOR walls break (every map has Structure.Interior); the outside walls, floors, stairs,
-- roof and railings stay solid and she bounces off them
local BREAKABLE = { Interior = true }
local broken = {} :: { { part: BasePart, parent: Instance } }
local pieces = {} :: { BasePart } -- the cut-up walls around holes (removed on restore)
local rng = Random.new()

-- Studio-only photo hook (thumbnails): ReplicatedStorage attribute DebugFreeze = seconds. That long after a
-- knock-out or a wall smash, the ghost and the flying rubble stop in mid-air; clearing the attribute lets them go.
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local frozen = {} :: { BasePart }
local function freezeLater(parts: { BasePart }, attr: string?)
	local t = RunService:IsStudio() and RS:GetAttribute(attr or "DebugFreeze")
	if type(t) ~= "number" then return end
	task.delay(t, function()
		for _, p in parts do
			if p.Parent and not p.Anchored then
				p.Anchored = true
				table.insert(frozen, p)
			end
		end
	end)
end
if RunService:IsStudio() then
	RS:GetAttributeChangedSignal("DebugFreeze"):Connect(function()
		if RS:GetAttribute("DebugFreeze") == nil then
			for _, p in frozen do if p.Parent then p.Anchored = false end end
			table.clear(frozen)
		end
	end)
end

local function structure(): Instance?
	local m = workspace:FindFirstChild("Mansion")
	return m and m:FindFirstChild("Structure")
end

local function breakable(p: BasePart, st: Instance): boolean
	-- a map can mark pieces breakable itself (the ship's upper decks: monsters crash through them)
	if p:GetAttribute("Breakable") then return true end
	local node: Instance? = p
	while node and node.Parent ~= st do node = node.Parent end -- the top folder inside Structure
	if not node or not BREAKABLE[node.Name] then return false end
	-- horizontal slabs are floors / ceilings
	local s = p.Size
	return not (s.Y <= 1.6 and math.min(s.X, s.Z) > 4)
end

-- punch a hole where she goes through: every interior wall layer (plaster, wainscot, rail...) in a box
-- from the floor to just above her body, ~6 studs wide. The part is cut into the pieces around the hole;
-- only the hole's volume flies off as chunks. Everything is put back by restoreWalls.
local HOLE_W = 6
local function chunks(cf: CFrame, size: Vector3, src: BasePart, push: Vector3)
	local made = {} :: { BasePart }
	local nx = math.clamp(math.round(size.X / 2), 1, 4)
	local ny = math.clamp(math.round(size.Y / 2), 1, 5)
	local nz = math.clamp(math.round(size.Z / 2), 1, 4)
	local cs = Vector3.new(size.X / nx, size.Y / ny, size.Z / nz)
	for ix = 0, nx - 1 do
		for iy = 0, ny - 1 do
			for iz = 0, nz - 1 do
				local off = Vector3.new((ix + 0.5) * cs.X - size.X / 2, (iy + 0.5) * cs.Y - size.Y / 2, (iz + 0.5) * cs.Z - size.Z / 2)
				local c = Instance.new("Part")
				c.Size = cs * 0.95
				c.CFrame = cf * CFrame.new(off) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(-0.3, 0.3), rng:NextNumber(-0.3, 0.3))
				c.Color = src.Color; c.Material = src.Material
				c.TopSurface = Enum.SurfaceType.Smooth; c.BottomSurface = Enum.SurfaceType.Smooth
				c.CollisionGroup = "Debris"; c.CanQuery = false; c.CanTouch = false
				c.Parent = workspace
				c.AssemblyLinearVelocity = push * rng:NextNumber(20, 50) + Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(0, 1), rng:NextNumber(-1, 1)) * 18
				c.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-8, 8), rng:NextNumber(-8, 8), rng:NextNumber(-8, 8))
				Debris:AddItem(c, rng:NextNumber(6, 9))
				table.insert(made, c)
			end
		end
	end
	freezeLater(made)
end

local function carve(p: BasePart, holeCF: CFrame, holeSize: Vector3, push: Vector3): boolean
	local S = p.Size
	-- the hole box in the part's own space (walls are axis-aligned, maybe turned 90 degrees)
	local c = p.CFrame:PointToObjectSpace(holeCF.Position)
	local h = p.CFrame:VectorToObjectSpace(holeSize)
	h = Vector3.new(math.abs(h.X), math.abs(h.Y), math.abs(h.Z)) / 2
	local lo = Vector3.new(math.max(-S.X / 2, c.X - h.X), math.max(-S.Y / 2, c.Y - h.Y), math.max(-S.Z / 2, c.Z - h.Z))
	local hi = Vector3.new(math.min(S.X / 2, c.X + h.X), math.min(S.Y / 2, c.Y + h.Y), math.min(S.Z / 2, c.Z + h.Z))
	if hi.X - lo.X < 0.05 or hi.Y - lo.Y < 0.05 or hi.Z - lo.Z < 0.05 then return false end
	-- the hole goes all the way through the wall's thin axis
	local thinX = S.X <= S.Z
	if thinX then lo = Vector3.new(-S.X / 2, lo.Y, lo.Z); hi = Vector3.new(S.X / 2, hi.Y, hi.Z)
	else lo = Vector3.new(lo.X, lo.Y, -S.Z / 2); hi = Vector3.new(hi.X, hi.Y, S.Z / 2) end
	local function piece(a0: Vector3, a1: Vector3)
		local size = a1 - a0
		if size.X < 0.05 or size.Y < 0.05 or size.Z < 0.05 then return end
		local q = p:Clone()
		q.Size = size
		q.CFrame = p.CFrame * CFrame.new((a0 + a1) / 2)
		q:SetAttribute("CarvedPiece", true)
		q.Parent = p.Parent
		table.insert(pieces, q)
	end
	-- the long horizontal axis is the one that is not thin
	if thinX then
		piece(Vector3.new(-S.X / 2, -S.Y / 2, -S.Z / 2), Vector3.new(S.X / 2, S.Y / 2, lo.Z)) -- one side
		piece(Vector3.new(-S.X / 2, -S.Y / 2, hi.Z), Vector3.new(S.X / 2, S.Y / 2, S.Z / 2)) -- other side
		piece(Vector3.new(-S.X / 2, hi.Y, lo.Z), Vector3.new(S.X / 2, S.Y / 2, hi.Z)) -- above
		piece(Vector3.new(-S.X / 2, -S.Y / 2, lo.Z), Vector3.new(S.X / 2, lo.Y, hi.Z)) -- below
	else
		piece(Vector3.new(-S.X / 2, -S.Y / 2, -S.Z / 2), Vector3.new(lo.X, S.Y / 2, S.Z / 2))
		piece(Vector3.new(hi.X, -S.Y / 2, -S.Z / 2), Vector3.new(S.X / 2, S.Y / 2, S.Z / 2))
		piece(Vector3.new(lo.X, hi.Y, -S.Z / 2), Vector3.new(hi.X, S.Y / 2, S.Z / 2))
		piece(Vector3.new(lo.X, -S.Y / 2, -S.Z / 2), Vector3.new(hi.X, lo.Y, S.Z / 2))
	end
	chunks(p.CFrame * CFrame.new((lo + hi) / 2), hi - lo, p, push)
	-- an original wall is kept to put back later; a piece of an earlier hole is just removed
	if p:GetAttribute("CarvedPiece") then
		local i = table.find(pieces, p)
		if i then table.remove(pieces, i) end
		p:Destroy()
	else
		table.insert(broken, { part = p, parent = p.Parent :: Instance })
		p.Parent = nil
	end
	return true
end

-- smash the walls where she hits (or where something explodes): returns how many wall pieces were cut.
-- width = hole size across (default 6), up = how far above `pos` it reaches (default 3.5)
function Ragdoll.breakWalls(pos: Vector3, vel: Vector3, width: number?, up: number?): number
	local st = structure()
	if not st then return 0 end
	-- from well below her (down to the floor) to a bit above her
	local w = width or HOLE_W
	local bottom, top = pos.Y - 12, pos.Y + (up or 3.5)
	local holeCF = CFrame.new(pos.X, (bottom + top) / 2, pos.Z)
	local holeSize = Vector3.new(w, top - bottom, w)
	local push = vel.Magnitude > 1 and vel.Unit or Vector3.new(0, 0.6, 0)
	local hmin, hmax = holeCF.Position - holeSize / 2, holeCF.Position + holeSize / 2
	-- every interior part whose box overlaps the hole (not a spatial query: the wainscot and rails have
	-- CanQuery off, so queries would miss them and leave the bottom of the wall standing)
	local hits = {}
	for _, p in st:GetDescendants() do
		if p:IsA("BasePart") then
			local half = p.CFrame:VectorToWorldSpace(p.Size / 2)
			half = Vector3.new(math.abs(half.X), math.abs(half.Y), math.abs(half.Z))
			local c = p.Position
			if c.X - half.X < hmax.X and c.X + half.X > hmin.X and c.Y - half.Y < hmax.Y and c.Y + half.Y > hmin.Y
				and c.Z - half.Z < hmax.Z and c.Z + half.Z > hmin.Z and breakable(p, st) then
				table.insert(hits, p)
			end
		end
	end
	local n = 0
	for _, p in hits do
		if p.Parent and carve(p, holeCF, holeSize, push) then n += 1 end
	end
	return n
end

-- put every broken wall back (next ghost, end of the run, map change)
function Ragdoll.restoreWalls()
	for _, q in pieces do q:Destroy() end
	table.clear(pieces)
	for i = #broken, 1, -1 do
		local b = broken[i]
		if b.parent and b.parent.Parent then b.part.Parent = b.parent end
	end
	table.clear(broken)
end

-- limp: joints become ball sockets, the body collides with the world and tumbles
function Ragdoll.start(g, vel: Vector3)
	local m = g.model :: Model
	g.rag = { sockets = {}, saved = {}, lastBreak = 0, still = 0 }
	g.lv.Enabled = false
	g.ao.Enabled = false
	for _, d in m:GetDescendants() do
		if d:IsA("Motor6D") and d.Part0 and d.Part1 then
			local a0 = Instance.new("Attachment"); a0.Name = "RagA0"; a0.CFrame = d.C0; a0.Parent = d.Part0
			local a1 = Instance.new("Attachment"); a1.Name = "RagA1"; a1.CFrame = d.C1; a1.Parent = d.Part1
			local bs = Instance.new("BallSocketConstraint")
			bs.Attachment0 = a0; bs.Attachment1 = a1
			bs.LimitsEnabled = true; bs.UpperAngle = 85; bs.TwistLimitsEnabled = false
			bs.Parent = d.Part1
			table.insert(g.rag.sockets, bs); table.insert(g.rag.sockets, a0); table.insert(g.rag.sockets, a1)
			d.Enabled = false
			-- the limbs collide with the world while she flops around
			local p1 = d.Part1 :: BasePart
			g.rag.saved[p1] = { p1.CanCollide, p1.Massless, p1.CollisionGroup }
			p1.CanCollide = true; p1.Massless = false; p1.CollisionGroup = GROUP
		end
	end
	local hrp = g.hrp :: BasePart
	g.rag.saved[hrp] = { hrp.CanCollide, hrp.Massless, hrp.CollisionGroup }
	hrp.CanCollide = false; hrp.CollisionGroup = GROUP
	local body = {} :: { BasePart }
	for _, d in m:GetDescendants() do if d:IsA("BasePart") then table.insert(body, d) end end
	freezeLater(body, "DebugFreezeBody")
	-- launch every body part (they are separate assemblies now) + a silly spin
	local spin = Vector3.new(rng:NextNumber(-14, 14), rng:NextNumber(-10, 10), rng:NextNumber(-14, 14))
	for p in g.rag.saved do
		pcall(function() (p :: BasePart):SetNetworkOwner(nil) end)
		;(p :: BasePart).AssemblyLinearVelocity = vel + Vector3.new(rng:NextNumber(-4, 4), rng:NextNumber(-2, 4), rng:NextNumber(-4, 4))
		;(p :: BasePart).AssemblyAngularVelocity = spin
	end
end

-- a loose copy of a monster (the Burning Captain's little skeletons) goes limp and flies: the same floppy joints
-- as the big ones, but nothing is kept to stand it back up and it never breaks a wall. The caller removes the model.
function Ragdoll.toss(m: Model, vel: Vector3)
	local root = m:FindFirstChild("HumanoidRootPart")
	for _, d in m:GetDescendants() do
		if d:IsA("Motor6D") then
			local p0, p1 = d.Part0, d.Part1
			if p0 and p1 then
				local a0 = Instance.new("Attachment"); a0.CFrame = d.C0; a0.Parent = p0
				local a1 = Instance.new("Attachment"); a1.CFrame = d.C1; a1.Parent = p1
				local bs = Instance.new("BallSocketConstraint")
				bs.Attachment0 = a0; bs.Attachment1 = a1
				bs.LimitsEnabled = true; bs.UpperAngle = 85; bs.TwistLimitsEnabled = false
				bs.Parent = p1
			end
			d.Enabled = false
		end
	end
	local body = {} :: { BasePart }
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = false; d.Massless = false
			d.CanCollide = d ~= root
			d.CollisionGroup = GROUP
			table.insert(body, d)
		end
	end
	local spin = Vector3.new(rng:NextNumber(-16, 16), rng:NextNumber(-10, 10), rng:NextNumber(-16, 16))
	for _, p in body do
		pcall(function() p:SetNetworkOwner(nil) end)
		p.AssemblyLinearVelocity = vel + Vector3.new(rng:NextNumber(-4, 4), rng:NextNumber(-2, 4), rng:NextNumber(-4, 4))
		p.AssemblyAngularVelocity = spin
	end
	freezeLater(body, "DebugFreezeBody")
end

-- hit her again while she is down: she flies again (juggle)
function Ragdoll.kick(g, vel: Vector3)
	if not g.rag then return end
	for p in g.rag.saved do
		(p :: BasePart).AssemblyLinearVelocity = vel + Vector3.new(rng:NextNumber(-4, 4), rng:NextNumber(0, 6), rng:NextNumber(-4, 4))
	end
	g.rag.still = 0
end

-- per frame while ragdolled. Returns true when she should get back up.
function Ragdoll.step(g, dt: number, onWall: (pos: Vector3, speed: number) -> ()): boolean
	local r = g.rag
	if not r then return true end
	local torso = (g.model:FindFirstChild("UpperTorso") or g.hrp) :: BasePart
	local v = torso.AssemblyLinearVelocity
	local speed = v.Magnitude
	local now = os.clock()
	-- smash the inside walls right in front of her before she touches them, so she flies through
	-- (a box test, not a raycast: rays skip the wainscot and rails, which have CanQuery off)
	if speed > 14 and now - r.lastBreak > 0.05 then
		r.lastBreak = now
		local ahead = torso.Position + v.Unit * math.clamp(speed * dt * 2 + 1.5, 1.5, 4)
		if Ragdoll.breakWalls(ahead, v) > 0 then
			onWall(ahead, speed)
			for p in r.saved do (p :: BasePart).AssemblyLinearVelocity *= 0.88 end -- she keeps flying through the hole
		end
	end
	-- sweep every frame from the torso, head and hips along the flight: a fast body covers several studs per
	-- frame, so a short look-ahead let her slam into a wall from far away without breaking it (or slip through
	-- a thin one). Inside walls in the way break; outside walls / stairs bounce her back instead.
	local st = structure()
	if st and speed > 14 then
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Include
		rp.FilterDescendantsInstances = { st }
		local dir = v.Unit
		local reach = speed * dt * 3 + 2.5
		for _, n in { "UpperTorso", "Head", "LowerTorso" } do
			local part = g.model:FindFirstChild(n) :: BasePart?
			local hit = part and workspace:Raycast(part.Position, dir * reach, rp)
			-- walls, ceilings, and breakable floors hit on a hard landing
			local floorHit = hit and hit.Normal.Y >= 0.6 and hit.Instance:GetAttribute("Breakable") and v.Y < -35
			if hit and (hit.Normal.Y < 0.6 or floorHit) then
				if breakable(hit.Instance :: BasePart, st) then
					if now - r.lastBreak > 0.03 then
						r.lastBreak = now
						if Ragdoll.breakWalls(hit.Position + dir * 0.6, v) > 0 then
							onWall(hit.Position, speed)
							for p in r.saved do (p :: BasePart).AssemblyLinearVelocity *= 0.88 end
						end
					end
				elseif -dir:Dot(hit.Normal) > 0.2 and hit.Distance <= speed * dt * 1.5 + 1.6 then -- about to touch it
					local nrm = hit.Normal
					for p in r.saved do
						local bp = p :: BasePart
						local pv = bp.AssemblyLinearVelocity
						local into = pv:Dot(nrm)
						if into < 0 then bp.AssemblyLinearVelocity = pv - nrm * into * 1.35 end
					end
				end
				break
			end
		end
	end
	r.still = speed < 5 and r.still + dt or 0
	return (now - g.stateStart > 1.2 and r.still > 0.5) or now > g.stateUntil or torso.Position.Y < -40
end

-- back on her feet: joints rigid again, she floats up and goes back to hunting
function Ragdoll.stop(g)
	local r = g.rag
	if not r then return end
	for _, i in r.sockets do i:Destroy() end
	for p, s in r.saved do
		local bp = p :: BasePart
		bp.CanCollide = s[1]; bp.Massless = s[2]; bp.CollisionGroup = s[3]
	end
	for _, d in g.model:GetDescendants() do if d:IsA("Motor6D") then d.Enabled = true end end
	g.rag = nil
	local hrp = g.hrp :: BasePart
	local torso = g.model:FindFirstChild("UpperTorso") :: BasePart?
	local at = torso and torso.Position or hrp.Position
	if at.Y < -40 then at = Vector3.new(0, 10, 0) end
	local look = hrp.CFrame.LookVector
	look = Vector3.new(look.X, 0, look.Z)
	look = look.Magnitude > 0.1 and look.Unit or Vector3.new(0, 0, -1)
	g.model:PivotTo(CFrame.lookAt(at, at + look))
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	g.ao.CFrame = CFrame.lookAt(Vector3.zero, look)
	g.lv.VectorVelocity = Vector3.zero
	g.lv.Enabled = true
	g.ao.Enabled = true
end

return Ragdoll
