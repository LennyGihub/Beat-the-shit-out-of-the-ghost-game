-- Run inventory: 5 hotbar slots of physical items (bought with run cash, gone when the run ends) and item use.
-- Kinds: melee swing, gun hitscan, throw projectile, spray cone (held), use on self, trap on the floor.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Items = require(RS.Shared.Items)
local Remotes = require(script.Parent.Remotes)
local Ghost = require(script.Parent.Ghost)
local Combat = require(script.Parent.Combat)
local Furniture = require(script.Parent.Furniture)

local Inventory = {}
local SLOTS = 5
local inv = {} :: { [Player]: { slots: { any }, sel: number, last: { [string]: number } } }
local projectiles = {} :: { any }
local traps = {} :: { any }
local rng = Random.new()
local FIRE = Color3.fromRGB(255, 110, 30)
local BLOOD = Color3.fromRGB(150, 10, 10)

local function get(p: Player)
	local i = inv[p]
	if not i then
		i = { slots = {}, sel = 0, last = {} }
		inv[p] = i
	end
	return i
end

local function publish(p: Player)
	local i = get(p)
	local parts = {}
	for n = 1, SLOTS do
		local s = i.slots[n]
		parts[n] = s and (s.id .. ":" .. s.uses) or ""
	end
	p:SetAttribute("Inv", table.concat(parts, ","))
	p:SetAttribute("Sel", i.sel)
end

function Inventory.clear(p: Player)
	inv[p] = { slots = {}, sel = 0, last = {} }
	publish(p)
end

-- add an item (stacks uses onto the same item). false = no free slot
function Inventory.give(p: Player, id: string): boolean
	local it = Items.byId[id]
	if not it then return false end
	local i = get(p)
	for n = 1, SLOTS do
		local s = i.slots[n]
		if s and s.id == id then s.uses += it.uses; publish(p); return true end
	end
	for n = 1, SLOTS do
		if not i.slots[n] then
			i.slots[n] = { id = id, uses = it.uses }
			i.sel = n
			publish(p)
			return true
		end
	end
	return false
end

local function consume(p: Player, n: number, amount: number?)
	local i = get(p)
	local s = i.slots[n]
	if not s then return end
	s.uses -= (amount or 1)
	if s.uses <= 0 then
		i.slots[n] = nil
		if i.sel == n then i.sel = 0 end
		Remotes.Fx:FireClient(p, "ItemBroke", s.id)
	end
	publish(p)
end

local function alive(p: Player): (Humanoid?, BasePart?, BasePart?)
	local ch = p.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	local head = ch and ch:FindFirstChild("Head") :: BasePart?
	if hum and hum.Health > 0 and hrp then return hum, hrp, head or hrp end
	return nil, nil, nil
end

local function ghostAlive()
	local g = Ghost.current
	return g and Ghost.alive() and g.state ~= "Spawn" and g or nil
end

-- item effects on the ghost
local function applyFx(p: Player, it, dmg: number, dir: Vector3)
	local fx = it.fx
	if not fx or not ghostAlive() then return end
	if fx.bleed then Ghost.burn(fx.bleed.dps, fx.bleed.t, BLOOD, p) end
	if fx.burn then Ghost.burn(fx.burn.dps, fx.burn.t, fx.burn.color or FIRE, p) end
	if fx.slow then Ghost.slow(fx.slow.mult, fx.slow.t) end
	if fx.stun then Ghost.freeze(fx.stun) end
	if fx.freeze then
		Ghost.freeze(fx.freeze)
		Remotes.Fx:FireAllClients("UltFreeze", Ghost.current.hrp.Position, fx.freeze)
	end
	if fx.vuln then
		Ghost.vuln(fx.vuln.mult, fx.vuln.t)
		Remotes.Fx:FireAllClients("Toast", "SHE IS CURSED: DOUBLE DAMAGE")
	end
	if fx.lifesteal then Combat.heal(p, dmg * fx.lifesteal) end
	if fx.lightning then
		local g = Ghost.current
		Remotes.Fx:FireAllClients("UltStrike", "lightning", g.hrp.Position, it.glow or Color3.fromRGB(170, 210, 255))
		Ghost.damage(fx.lightning, p)
	end
	if fx.pull then
		local _, hrp = alive(p)
		local g = Ghost.current
		if hrp and g then
			local to = hrp.Position - g.hrp.Position
			Ghost.shove(Vector3.new(to.X, 0, to.Z).Unit * math.min(110, to.Magnitude * 3.2))
		end
	end
end

local function useMelee(p: Player, n: number, it, dir: Vector3)
	if not Combat.useStamina(p, it.stamina) then return end
	consume(p, n)
	local _, _, head = alive(p)
	if head and Ghost.hitClone(head.Position, dir, it.range) then
		Remotes.Fx:FireAllClients("ItemSwing", p, it.id, true)
		return
	end
	local hitPos = Combat.tryHit(p, dir, it.range)
	Remotes.Fx:FireAllClients("ItemSwing", p, it.id, hitPos ~= nil)
	if hitPos then
		local dmg = Combat.registerHit(p, dir, hitPos, it.dmg, it.knock, math.max(1, it.knock / 5), it.cd >= 0.2 and 1 or 0)
		applyFx(p, it, dmg, dir)
	end
end

-- distance from a point to a ray (and how far along it)
local function rayDist(o: Vector3, d: Vector3, pt: Vector3): (number, number)
	local t = (pt - o):Dot(d)
	return (pt - (o + d * t)).Magnitude, t
end

local function structure(): RaycastParams
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	local m = workspace:FindFirstChild("Mansion")
	rp.FilterDescendantsInstances = { m and m:FindFirstChild("Structure") or workspace.Terrain }
	return rp
end

local function useGun(p: Player, n: number, it, dir: Vector3)
	local _, _, head = alive(p)
	if not head then return end
	consume(p, n)
	local o = (head :: BasePart).Position
	local g = ghostAlive()
	local total, hits = 0, 0
	local endPoints = {}
	for _ = 1, it.pellets do
		local d = (dir + Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)) * it.spread).Unit
		local endPt = o + d * it.range
		local wall = workspace:Raycast(o, d * it.range, structure())
		if wall then endPt = wall.Position end
		if g then
			for _, name in { "UpperTorso", "Head", "HumanoidRootPart", "LowerTorso" } do
				local part = g.model:FindFirstChild(name) :: BasePart?
				if part then
					local dist, t = rayDist(o, d, part.Position)
					if dist < 2.6 and t > 0 and t <= (endPt - o).Magnitude + 1 then
						hits += 1
						total += it.dmg
						endPt = o + d * t
						break
					end
				end
			end
		end
		table.insert(endPoints, endPt)
	end
	Remotes.Fx:FireAllClients("Tracer", o, endPoints, it.tracer or Color3.fromRGB(255, 230, 160), p, it.id)
	if hits > 0 and g then
		local dmg = Combat.registerHit(p, dir, g.hrp.Position, total, it.knock * math.sqrt(hits), 2, 1)
		applyFx(p, it, dmg, dir)
	end
end

local function explode(p: Player, it, pos: Vector3, direct: Player?)
	Remotes.Fx:FireAllClients("ItemBoom", pos, it.radius, it.color, it.boom == true, it.id)
	-- PvP: the player it hit takes the full hit, others caught in a blast take part of it (never the thrower)
	for _, other in Players:GetPlayers() do
		if other ~= p and other:GetAttribute("InMatch") then
			local _, ohrp = alive(other)
			if ohrp then
				local d = (ohrp.Position - pos).Magnitude
				local inBlast = (it.boom or it.smash) and d <= it.radius
				if other == direct or inBlast then
					local f = other == direct and 1 or math.clamp(1 - d / (it.radius + 1), 0.3, 1) * 0.7
					local away = ohrp.Position - pos
					away = Vector3.new(away.X, 0, away.Z)
					Combat.hitPlayer(other, p, it.dmg * Combat.PVP_MULT * f, (away.Magnitude > 0.1 and away.Unit or Vector3.new(0, 0, 1)) * (40 + it.knock * 0.3), it.name)
				end
			end
		end
	end
	local g = ghostAlive()
	if g and (g.hrp.Position - pos).Magnitude <= it.radius + 3 then
		local dir = g.hrp.Position - pos
		dir = Vector3.new(dir.X, 0, dir.Z)
		if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, 1) end
		local dmg = Combat.registerHit(p, dir.Unit, g.hrp.Position, it.dmg, it.knock, 2, 1)
		applyFx(p, it, dmg, dir.Unit)
	end
	if it.smash or it.boom then
		for _, f in Furniture.near(pos, it.smash and it.radius or it.radius * 0.5) do
			local c = f:GetBoundingBox().Position
			Furniture.smash(f, (c - pos).Unit * 70 + Vector3.new(0, 30, 0), 80)
		end
	end
end

local function useThrow(p: Player, n: number, it, dir: Vector3)
	local _, _, head = alive(p)
	if not head then return end
	consume(p, n)
	local proj = Instance.new("Part")
	proj.Name = "Thrown_" .. it.id
	proj.Size = it.shape == "ball" and Vector3.one * 1.4 or Vector3.new(0.6, 0.6, 1)
	proj.Shape = it.shape == "ball" and Enum.PartType.Ball or Enum.PartType.Block
	proj.Color = it.color
	proj.Material = Enum.Material.SmoothPlastic
	proj.Anchored = true; proj.CanCollide = false; proj.CanQuery = false; proj.CanTouch = false
	local o = (head :: BasePart).Position + dir * 2
	proj.CFrame = CFrame.new(o)
	proj.Parent = workspace
	table.insert(projectiles, { part = proj, pos = o, vel = dir * 95 + Vector3.new(0, 14, 0), it = it, by = p, t0 = os.clock() })
	Remotes.Fx:FireAllClients("ItemSwing", p, it.id, false)
end

local function useSpray(p: Player, n: number, it, dir: Vector3)
	local _, _, head = alive(p)
	if not head then return end
	consume(p, n)
	local g = ghostAlive()
	if not g then return end
	local o = (head :: BasePart).Position
	local to = g.hrp.Position - o
	if to.Magnitude > it.range or dir:Dot(to.Unit) < it.cone then return end
	if workspace:Raycast(o, to, structure()) then return end
	Ghost.damage(it.dps * 0.1, p)
	local fx = it.fx or {}
	if fx.push then
		local flat = Vector3.new(to.X, 0, to.Z).Unit
		Ghost.shove(flat * fx.push * 3)
	end
	if fx.burn then Ghost.burn(fx.burn.dps, 0.6, FIRE, p) end
	if fx.slow then Ghost.slow(fx.slow.mult, fx.slow.t) end
	local s = Combat.state(p)
	if os.clock() - (s.lastSprayHit or 0) > 0.5 then
		s.lastSprayHit = os.clock()
		Remotes.Fx:FireAllClients("Hit", g.hrp.Position, 1, it.dps * 0.5, false, p)
	end
end

local function useSelf(p: Player, n: number, it)
	local hum = alive(p)
	if not hum then return end
	consume(p, n)
	if it.heal then Combat.heal(p, it.heal) end
	if it.stamina then Combat.refillStamina(p) end
	if it.speed then Combat.speedBuff(p, it.speed, it.speedT or 8) end
	if it.shield then Combat.addShield(p, it.shield) end
	if it.brut then Combat.fillBrutality(p) end
	if it.ward then
		p:SetAttribute("Warded", true)
		task.delay(it.ward, function() if p.Parent then p:SetAttribute("Warded", false) end end)
	end
	if it.ghostFreeze and ghostAlive() then
		Ghost.timeStop(it.ghostFreeze, 1.3)
		Remotes.Fx:FireAllClients("TimeStop", it.ghostFreeze)
	end
	Remotes.Fx:FireClient(p, "ItemUsed", it.id)
end

local function useTrap(p: Player, n: number, it)
	local _, hrp = alive(p)
	if not hrp then return end
	local r = workspace:Raycast(hrp.Position, Vector3.new(0, -8, 0), structure())
	local floor = r and r.Position or (hrp.Position - Vector3.new(0, 3, 0))
	consume(p, n)
	local trap = Instance.new("Model"); trap.Name = "BearTrap"
	local base = Instance.new("Part")
	base.Size = Vector3.new(3, 0.3, 3); base.Shape = Enum.PartType.Cylinder
	base.CFrame = CFrame.new(floor + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	base.Size = Vector3.new(0.3, 3, 3); base.Color = it.color; base.Material = Enum.Material.Metal
	base.Anchored = true; base.CanCollide = false; base.Parent = trap
	for k = 0, 7 do
		local t = Instance.new("Part")
		t.Size = Vector3.new(0.15, 0.6, 0.15); t.Color = Color3.fromRGB(200, 200, 200); t.Material = Enum.Material.Metal
		t.CFrame = CFrame.new(floor) * CFrame.Angles(0, k * math.pi / 4, 0) * CFrame.new(0, 0.5, 1.3)
		t.Anchored = true; t.CanCollide = false; t.Parent = trap
	end
	trap.Parent = workspace
	table.insert(traps, { model = trap, pos = floor, it = it, by = p })
	Remotes.Fx:FireAllClients("ItemSwing", p, it.id, false)
end

local function onUse(p: Player, slot: any, look: any)
	if type(slot) ~= "number" or typeof(look) ~= "Vector3" or look.Magnitude < 0.5 or look.Magnitude > 2 or look.X ~= look.X then return end
	if not p:GetAttribute("InMatch") or p:GetAttribute("Carrying") then return end
	local i = get(p)
	local s = i.slots[slot]
	if not s then return end
	local it = Items.byId[s.id]
	if not it then return end
	local now = os.clock()
	local cd = it.kind == "spray" and 0.1 or (it.cd or 0.6)
	if now - (i.last[s.id] or 0) < cd * 0.8 then return end
	i.last[s.id] = now
	local dir = look.Unit
	if it.kind == "melee" then useMelee(p, slot, it, dir)
	elseif it.kind == "gun" then useGun(p, slot, it, dir)
	elseif it.kind == "throw" then useThrow(p, slot, it, dir)
	elseif it.kind == "spray" then useSpray(p, slot, it, dir)
	elseif it.kind == "use" then useSelf(p, slot, it)
	elseif it.kind == "trap" then useTrap(p, slot, it)
	end
end

local function step(dt: number)
	-- projectiles
	local rp = structure()
	local mansion = workspace:FindFirstChild("Mansion")
	local f = mansion and mansion:FindFirstChild("Furniture")
	if f then rp.FilterDescendantsInstances = { mansion.Structure, f, workspace:FindFirstChild("Baseplate") } end
	for k = #projectiles, 1, -1 do
		local pr = projectiles[k]
		local g = ghostAlive()
		local old = pr.pos
		pr.vel += Vector3.new(0, -55 * dt, 0)
		local new = old + pr.vel * dt
		local hit = workspace:Raycast(old, new - old, rp)
		local boomAt: Vector3? = nil
		if hit then boomAt = hit.Position end
		if g and (g.hrp.Position - new).Magnitude < 4 then boomAt = new end
		-- PvP: a thrown item that reaches another player hits them
		local victim = os.clock() - pr.t0 > 0.08 and Combat.playerNear(new, 3.2, pr.by) or nil
		if victim then boomAt = new end
		if os.clock() - pr.t0 > 4 then boomAt = new end
		if boomAt then
			pr.part:Destroy()
			table.remove(projectiles, k)
			if pr.by.Parent then explode(pr.by, pr.it, boomAt, victim) end
		else
			pr.pos = new
			pr.part.CFrame = CFrame.lookAt(new, new + pr.vel) * CFrame.Angles(os.clock() * 12, 0, 0)
		end
	end
	-- traps
	local g = ghostAlive()
	for k = #traps, 1, -1 do
		local t = traps[k]
		if not t.model.Parent then
			table.remove(traps, k)
		elseif g then
			local gp = g.hrp.Position
			if Vector3.new(gp.X - t.pos.X, 0, gp.Z - t.pos.Z).Magnitude < 5 and math.abs(gp.Y - t.pos.Y) < 9 then
				Ghost.freeze(t.it.stun)
				Ghost.damage(t.it.dmg, t.by)
				Remotes.Fx:FireAllClients("TrapSnap", t.pos)
				Remotes.Fx:FireAllClients("UltFreeze", gp, t.it.stun)
				t.model:Destroy()
				table.remove(traps, k)
			end
		end
	end
end

function Inventory.clearWorld()
	for _, pr in projectiles do pr.part:Destroy() end
	projectiles = {}
	for _, t in traps do t.model:Destroy() end
	traps = {}
end

function Inventory.start()
	Remotes.Use.OnServerEvent:Connect(onUse)
	Remotes.Select.OnServerEvent:Connect(function(p, n)
		if type(n) ~= "number" then return end
		local i = get(p)
		n = math.floor(n)
		if n == 0 or (n >= 1 and n <= SLOTS and i.slots[n]) then i.sel = n; publish(p) end
	end)
	Remotes.Drop.OnServerEvent:Connect(function(p, n)
		if type(n) ~= "number" then return end
		local i = get(p)
		if i.slots[n] then
			i.slots[n] = nil
			if i.sel == n then i.sel = 0 end
			publish(p)
		end
	end)
	Players.PlayerRemoving:Connect(function(p) inv[p] = nil end)
	if RunService:IsStudio() then
		-- Studio test hook: set player attribute DebugGive = "<ItemId>" from a server test script
		local function hook(p: Player)
			p:GetAttributeChangedSignal("DebugGive"):Connect(function()
				local id = p:GetAttribute("DebugGive")
				if type(id) == "string" then Inventory.give(p, (string.gsub(id, "#.*", ""))) end
			end)
		end
		Players.PlayerAdded:Connect(hook)
		for _, p in Players:GetPlayers() do hook(p) end
	end
	RunService.Heartbeat:Connect(step)
end

return Inventory
