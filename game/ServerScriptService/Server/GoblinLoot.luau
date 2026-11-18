-- The Goblin's special ("steal"): he snatches the item out of a player's hands and turns it on them.
-- Abilities.luau delegates the ability here. Hits do much less damage than the item does to a monster,
-- but the knockback and the ragdoll are the same ones the item gives a monster (Ghost.hit / Ragdoll rules).
-- He drops the item when he is knocked out (ragdoll) or dies: it goes back to its owner with the uses left.
-- Inventory injects G.hasItem / G.takeItem / G.giveItem; Combat injects G.hitPlayer / G.damagePlayer / G.rootPlayer.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Items = require(RS.Shared.Items)
local ItemModels = require(RS.Shared.ItemModels)
local Remotes = require(script.Parent.Remotes)
local Furniture = require(script.Parent.Furniture)
local Ragdoll = require(script.Parent.Ragdoll)
local Fury = require(script.Parent.Fury)

local Loot = {}
local rng = Random.new()
local DMG = 0.3 -- his hits do 30% of the item's damage
local MIN_KNOCK = 70 -- = Ragdoll.MIN_KNOCK: this much knockback knocks you out like it knocks a monster out
local GRAVITY = 55 -- thrown items fall like the players' throws (Inventory)
local SCALE = 1.9 -- the item in his big hand
local KNOCK_BOOST = 1.5 -- his hits knock harder than the item knocks a monster...
local FLY_BOOST = 1.4 -- ...and you fly faster
local WALL_SPEED = 28 -- flying faster than this into an inside wall = straight through it
local flying = {} :: { [Player]: number } -- players he just sent flying (until when)
local lobs = {} :: { { part: BasePart, pos: Vector3, vel: Vector3, it: any, t0: number, g: any } }

-- helpers from Abilities (setPhase, start, finish, hover, flat, warded, hrpOf, matchPlayers, fx)
local H: any = nil
function Loot.init(h) H = h end

local function upper(s: string): string return string.upper(s) end

local function toast(p: Player?, msg: string)
	if p and p.Parent then Remotes.Fx:FireClient(p, "Toast", msg) end
end

-- the knockback a hit of strength `knock` gives a monster, as a player fling: (velocity, ragdoll seconds)
local function knockVel(dir: Vector3, knock: number): (Vector3, number)
	local flat = H.flat(dir)
	if knock >= MIN_KNOCK then
		return flat * math.clamp(knock * 0.75, 55, 115) + Vector3.new(0, 26 + knock * 0.1, 0), 2.2
	end
	return flat * knock + Vector3.new(0, math.min(knock * 0.15, 18), 0), math.clamp(knock / 45, 0.4, 1.1)
end

-- the inside walls in the way of a flying player break, so they go through them (outside walls never break)
local function smashAhead(g, from: Vector3, vel: Vector3, dist: number): boolean
	local flat = Vector3.new(vel.X, 0, vel.Z)
	if flat.Magnitude < WALL_SPEED then return false end
	local r = workspace:Raycast(from, flat.Unit * dist, g.rp)
	if r and r.Normal.Y < 0.6 and Ragdoll.breakWalls(r.Position, flat, 7, 4) > 0 then
		Remotes.Fx:FireAllClients("WallSmash", r.Position, flat.Magnitude)
		return true
	end
	return false
end

-- one stolen-item hit on a player (dmgMul scales the item's damage, e.g. pellets)
local function strike(g, G, p: Player, dir: Vector3, it, dmgMul: number?, knockMul: number?)
	local hrp = H.hrpOf(p)
	if not hrp or H.warded(p) then return end
	local dmg = (it.dmg or 0) * DMG * (g.dmgMult or 1) * (dmgMul or 1)
	local knock = (it.knock or 0) * (knockMul or 1) * KNOCK_BOOST
	if knock < 10 or not Fury.canFling(g) then
		-- almost no knockback (nail gun, taser...), or the Goblin King has used up his flings on a lone player
		-- (Fury.canFling): it hurts, no tumble
		G.damagePlayer(p, dmg)
		Remotes.Fx:FireAllClients("PlayerHit", hrp.Position, dmg, nil, "goblin")
	else
		local vel, t = knockVel(dir, knock)
		local h = Vector3.new(vel.X, 0, vel.Z) * FLY_BOOST
		if h.Magnitude > 160 then h = h.Unit * 160 end
		vel = h + Vector3.new(0, vel.Y, 0)
		-- break the wall behind them right away (the flight is simulated on their client, a bit later)
		smashAhead(g, hrp.Position, vel, math.clamp(h.Magnitude * 0.7, 8, 70))
		flying[p] = os.clock() + t + 0.6
		Fury.flung(g)
		G.hitPlayer(p, nil, dmg, vel, "goblin", true, t)
	end
	local fx = it.fx
	if fx then
		local stun = fx.stun or fx.freeze
		if stun and G.rootPlayer then G.rootPlayer(p, stun * 0.5) end
	end
end

local function hand(g): BasePart
	return (g.model:FindFirstChild("RightHand") or g.hrp) :: BasePart
end

-- where shots / sprays come out: the item's Tip, else his hand
local function muzzle(g): Vector3
	local m = g.model:FindFirstChild("Loot")
	local tip = m and m:FindFirstChild("Tip", true) :: BasePart?
	return tip and tip.Position or hand(g).Position
end

-- the stolen item in his right hand (points along the arm: forward when he aims)
local function attach(g, it)
	local old = g.model:FindFirstChild("Loot")
	if old then old:Destroy() end
	local h = hand(g)
	local m = ItemModels.build(it.shape, it.color, it.glow, it.id)
	m.Name = "Loot"
	m:ScaleTo(SCALE)
	m:PivotTo(h.CFrame * CFrame.new(0, -0.45, -0.1) * CFrame.Angles(-math.pi / 2, 0, 0))
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = false; d.Massless = true; d.CanCollide = false; d.CanTouch = false; d.CanQuery = false
			local w = Instance.new("WeldConstraint"); w.Part0 = h; w.Part1 = d; w.Parent = d
		end
	end
	m.Parent = g.model
end

local function detach(g)
	local m = g.model and g.model:FindFirstChild("Loot")
	if m then m:Destroy() end
	if g.model then g.model:SetAttribute("Loot", "") end
	g.loot = nil
end

-- an item he can't fight with (medkit, energy drink...): he uses it on himself right away
local function selfUse(g, G, it, victim: Player)
	local name = upper(it.name)
	local gain = (it.heal or 0) * 4 + (it.shield or 0) * 3
	if gain > 0 then
		g.hp = math.min(g.maxHp, g.hp + gain)
		g.model:SetAttribute("HP", g.hp)
	end
	if it.speed or it.stamina or it.brut then
		local mult = it.speed or 1.3
		local base = g.baseSpeedMult or g.speedMult
		g.baseSpeedMult = base
		g.speedMult = base * mult
		task.delay(it.speedT or 8, function()
			if g.baseSpeedMult then g.speedMult = g.baseSpeedMult end
		end)
	end
	if it.ghostFreeze then
		for _, p in H.matchPlayers() do G.rootPlayer(p, 2.5) end
	end
	toast(victim, "THE GOBLIN USED YOUR " .. name .. " ON HIMSELF!")
end

local function grab(g, G, victim: Player, id: string, uses: number)
	local it = Items.byId[id]
	if not it then return end
	Remotes.Fx:FireAllClients("GoblinSteal", hand(g).Position, victim, id)
	for _, p in H.matchPlayers() do
		if p ~= victim then toast(p, "THE GOBLIN STOLE " .. upper(victim.DisplayName) .. "'S " .. upper(it.name)) end
	end
	if it.kind == "use" then
		selfUse(g, G, it, victim)
		return
	end
	toast(victim, "THE GOBLIN STOLE YOUR " .. upper(it.name) .. "! HIT HIM HARD TO GET IT BACK")
	g.loot = { id = id, it = it, uses = uses, owner = victim, nextUse = os.clock() + 0.8 }
	g.model:SetAttribute("Loot", id)
	attach(g, it)
end

-- the Goblin King pulls a weapon of his own out of his sack (no owner: nothing to give back)
function Loot.arm(g, id: string, uses: number?)
	local it = Items.byId[id]
	if not it or g.loot then return end
	g.loot = { id = id, it = it, uses = uses or 12, owner = nil, nextUse = os.clock() + 1.5 }
	g.model:SetAttribute("Loot", id)
	attach(g, it)
	for _, p in H.matchPlayers() do toast(p, "THE GOBLIN KING PULLS OUT A " .. upper(it.name)) end
end

-- one use of the stolen item; at 0 it breaks
local function spend(g, n: number?)
	local L = g.loot
	if not L then return end
	L.uses -= (n or 1)
	if L.uses <= 0 then
		Remotes.Fx:FireAllClients("GoblinDrop", hand(g).Position, L.id, true)
		toast(L.owner, "THE GOBLIN BROKE YOUR " .. upper(L.it.name))
		detach(g)
	end
end

-- knocked out / killed / gone: the item flies back to its owner with the uses it has left
function Loot.drop(g, G)
	local L = g.loot
	if not L then return end
	local at = hand(g).Position
	detach(g)
	Remotes.Fx:FireAllClients("GoblinDrop", at, L.id, false)
	local p = L.owner
	if p and p.Parent and p:GetAttribute("InMatch") and G.giveItem and G.giveItem(p, L.id, L.uses) then
		toast(p, "YOU GOT YOUR " .. upper(L.it.name) .. " BACK!")
	end
end

local function useDone(g, G)
	local L = g.loot
	H.finish(g, G, 0.35)
	g.nextAbility = os.clock() + 0.2 -- the item's own cooldown (L.nextUse) decides
	if L then L.nextUse = os.clock() + math.max((L.it.cd or 0.6) * 3, 1.1) end
end

local function clearLine(g, from: Vector3, to: Vector3): boolean
	return workspace:Raycast(from, to - from, g.rp) == nil
end

-- start using the stolen item on the target (true = started)
local function useStart(g, G, now: number, target: Player, thrp: BasePart, dist: number): boolean
	local L = g.loot
	if now < L.nextUse or H.warded(target) then return false end
	local it = L.it
	local k = it.kind
	if k == "melee" then
		if dist > (it.range or 10) + 3 then return false end
		H.start(g, G, "swingWind", (it.cd or 0.5) >= 0.6 and 0.55 or 0.4, { victim = target })
	elseif k == "gun" then
		if dist > math.min(it.range or 50, 60) or not clearLine(g, muzzle(g), thrp.Position) then return false end
		H.start(g, G, "aim", 0.55, { victim = target, shots = (it.cd or 1) < 0.3 and 5 or 1, fired = 0, nextShot = 0 })
	elseif k == "throw" or k == "trap" then
		if dist > 55 then return false end
		H.start(g, G, "throwWind", 0.5, { victim = target })
	elseif k == "spray" then
		if dist > (it.range or 16) + 2 then return false end
		H.start(g, G, "spray", 1.6, { victim = target, nextTick = 0, nextPush = 0 })
		Remotes.Fx:FireAllClients("GoblinUse", g.model, L.id, "spray", 1.6)
	else
		return false
	end
	return true
end

-- called from Abilities.try in Chase
function Loot.try(g, G, now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	if g.loot then return useStart(g, G, now, target, thrp, dist) end
	if dist > (a.range or 10) or H.warded(target) or not G.hasItem or not G.hasItem(target) then return false end
	H.start(g, G, "reach", 0.5, { victim = target })
	H.fx("AbilityWind", g.hrp.Position, "steal")
	return true
end

-- a gun shot (several pellets): pellets that pass near a player hit them
local function shoot(g, G, it, aim: Vector3)
	local o = muzzle(g)
	local base = (aim - o).Unit
	local ends, hits = {}, {} :: { [Player]: number }
	for _ = 1, (it.pellets or 1) do
		local sp = (it.spread or 0.01) + 0.025 -- he is a worse shot than you
		local d = (base + Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1)) * sp).Unit
		local range = it.range or 50
		local endPt = o + d * range
		local wall = workspace:Raycast(o, d * range, g.rp)
		if wall then endPt = wall.Position end
		local len = (endPt - o).Magnitude
		local best, bestT = nil, math.huge
		for _, p in H.matchPlayers() do
			local hrp = H.hrpOf(p)
			if hrp then
				local rel = hrp.Position - o
				local t = rel:Dot(d)
				if t > 0 and t <= len + 1 and (rel - d * t).Magnitude < 2.6 and t < bestT then best, bestT = p, t end
			end
		end
		if best then
			hits[best] = (hits[best] or 0) + 1
			endPt = o + d * bestT
		end
		table.insert(ends, endPt)
	end
	Remotes.Fx:FireAllClients("Tracer", o, ends, it.tracer or Color3.fromRGB(255, 230, 160), nil, it.id)
	for p, n in hits do strike(g, G, p, base, it, n, math.sqrt(n)) end
end

-- runs while the "steal" ability is active (Abilities.step)
function Loot.step(g, G, dt: number, now: number, target: Player?, thrp: BasePart?, hoverY: number)
	local ab = g.ab
	local pos = g.hrp.Position
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	local vh = ab.victim and H.hrpOf(ab.victim)
	local aimAt = vh and vh.Position or (thrp and thrp.Position)
	if aimAt and ab.phase ~= "laugh" then
		local f = Vector3.new(aimAt.X, pos.Y, aimAt.Z)
		if (f - pos).Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(pos, f).Rotation end
	end
	local L = g.loot
	local ph = ab.phase
	if ph == "reach" then
		if now >= ab.untilT then
			if vh and (vh.Position - pos).Magnitude <= (g.def.ability.range or 10) + 3.5 and not H.warded(ab.victim) and G.takeItem then
				local id, uses = G.takeItem(ab.victim)
				if id then
					grab(g, G, ab.victim, id, uses)
					H.setPhase(g, "laugh", 0.9)
					return
				end
			end
			H.finish(g, G, 0.5) -- missed
		end
	elseif ph == "laugh" then
		if now >= ab.untilT then
			H.finish(g, G, 0.2)
			g.nextAbility = now + 0.3
			if g.loot then g.loot.nextUse = now + 0.6 end
		end
	elseif not L then
		H.finish(g, G, 0.3) -- the item broke mid-use
	elseif ph == "swingWind" then
		if now >= ab.untilT then
			H.setPhase(g, "swing", 0.35)
			local it = L.it
			local reach = (it.range or 10) + 3.5
			local look = H.flat(g.hrp.CFrame.LookVector)
			local hitAny = false
			for _, p in H.matchPlayers() do
				local hrp = H.hrpOf(p)
				if hrp then
					local to = hrp.Position - pos
					if to.Magnitude <= reach and H.flat(to):Dot(look) > 0.2 then
						strike(g, G, p, to, it)
						hitAny = true
					end
				end
			end
			Remotes.Fx:FireAllClients("GoblinUse", g.model, L.id, hitAny and "hit" or "swing", 0)
			spend(g, math.max(1, math.floor(0.4 / math.max(it.cd or 0.4, 0.05)))) -- the chainsaw eats fuel fast
		end
	elseif ph == "swing" then
		if now >= ab.untilT then useDone(g, G) end
	elseif ph == "aim" then
		if now >= ab.untilT then H.setPhase(g, "fire", ab.shots * 0.13 + 0.25) end
	elseif ph == "fire" then
		if ab.fired < ab.shots and now >= ab.nextShot and L then
			ab.fired += 1
			ab.nextShot = now + 0.13
			local aim = (vh and vh.Position) or (pos + g.hrp.CFrame.LookVector * 30)
			shoot(g, G, L.it, aim)
			spend(g)
		end
		if now >= ab.untilT then useDone(g, G) end
	elseif ph == "throwWind" then
		if now >= ab.untilT then
			H.setPhase(g, "throw", 0.35)
			local it = L.it
			local from = hand(g).Position + Vector3.new(0, 1.5, 0)
			local to = (vh and vh.Position - Vector3.new(0, 1.5, 0)) or (pos + g.hrp.CFrame.LookVector * 25)
			local T = math.clamp((to - from).Magnitude / 75, 0.3, 0.85)
			local vel = (to - from) / T + Vector3.new(0, 0.5 * GRAVITY * T, 0)
			local proj = Instance.new("Part")
			proj.Name = "GoblinThrown_" .. it.id
			proj.Size = it.shape == "ball" and Vector3.one * 2.4 or Vector3.new(1, 1, 1.7)
			proj.Shape = it.shape == "ball" and Enum.PartType.Ball or Enum.PartType.Block
			proj.Color = it.color; proj.Material = Enum.Material.SmoothPlastic
			proj.Anchored = true; proj.CanCollide = false; proj.CanQuery = false; proj.CanTouch = false
			proj.CFrame = CFrame.new(from)
			proj.Parent = workspace
			table.insert(lobs, { part = proj, pos = from, vel = vel, it = it, t0 = now, g = g })
			Remotes.Fx:FireAllClients("GoblinUse", g.model, L.id, "throw", 0)
			spend(g)
		end
	elseif ph == "throw" then
		if now >= ab.untilT then useDone(g, G) end
	elseif ph == "spray" then
		local it = L.it
		if now >= ab.nextTick then
			ab.nextTick = now + 0.1
			local o = muzzle(g)
			local look = g.hrp.CFrame.LookVector
			for _, p in H.matchPlayers() do
				local hrp = H.hrpOf(p)
				if hrp and not H.warded(p) then
					local to = hrp.Position - o
					if to.Magnitude <= (it.range or 16) + 2 and look:Dot(to.Unit) >= 0.75 and clearLine(g, o, hrp.Position) then
						G.damagePlayer(p, (it.dps or 3) * 0.1 * DMG * (g.dmgMult or 1))
						local push = it.fx and it.fx.push
						if push and now >= ab.nextPush then
							-- leaf blower / shop vac: the same push it gives a monster (pull for the vac)
							ab.nextPush = now + 0.35
							G.hitPlayer(p, nil, 0, H.flat(to) * push * 3 + Vector3.new(0, 10, 0), "goblin", true, 0.45)
						end
						local stun = it.fx and (it.fx.stun or it.fx.freeze)
						if stun and G.rootPlayer then G.rootPlayer(p, 0.3) end
					end
				end
			end
			spend(g)
		end
		if now >= ab.untilT then useDone(g, G) end
	else
		H.finish(g, G, 0.2)
	end
end

-- a thrown stolen item lands
local function land(lb, at: Vector3, direct: Player?)
	local it = lb.it
	local g = lb.g
	local G = lb.G
	Remotes.Fx:FireAllClients("ItemBoom", at, it.radius or 4, it.color, it.boom == true, it.id)
	for _, p in H.matchPlayers() do
		local hrp = H.hrpOf(p)
		if hrp then
			local d = (hrp.Position - at).Magnitude
			local r = (it.radius or 4) + 1.5
			if p == direct or d <= r then
				local f = p == direct and 1 or math.clamp(1 - d / (r + 1), 0.4, 1)
				local away = hrp.Position - at
				if Vector3.new(away.X, 0, away.Z).Magnitude < 0.3 then away = lb.vel end
				if it.kind == "trap" then
					if G.rootPlayer then G.rootPlayer(p, (it.stun or 3) * 0.5) end
					G.damagePlayer(p, (it.dmg or 10) * DMG * (g.dmgMult or 1))
					Remotes.Fx:FireAllClients("TrapSnap", hrp.Position)
				else
					strike(g, G, p, away, it, f, f)
				end
			end
		end
	end
	if it.smash or it.boom then
		for _, fm in Furniture.near(at, it.smash and (it.radius or 8) or (it.radius or 8) * 0.5) do
			local c = fm:GetBoundingBox().Position
			Furniture.smash(fm, (c - at).Unit * 70 + Vector3.new(0, 30, 0), 80)
		end
	end
end

-- every frame (Abilities.tick): thrown stolen items in flight
function Loot.tick(G, dt: number, now: number)
	-- players he sent flying: walls further along their path break too
	for p, untilT in flying do
		local hrp = H.hrpOf(p)
		local g = G.current
		if now > untilT or not hrp or not g then
			flying[p] = nil
		else
			smashAhead(g, hrp.Position, hrp.AssemblyLinearVelocity, 9)
		end
	end
	for i = #lobs, 1, -1 do
		local lb = lobs[i]
		lb.G = G
		local old = lb.pos
		lb.vel += Vector3.new(0, -GRAVITY * dt, 0)
		local new = old + lb.vel * dt
		local hit = workspace:Raycast(old, new - old, lb.g.rp)
		local at: Vector3? = hit and hit.Position or nil
		local direct: Player? = nil
		for _, p in H.matchPlayers() do
			local hrp = H.hrpOf(p)
			if hrp and (hrp.Position - new).Magnitude < 3.4 then direct = p; at = new; break end
		end
		if not at and now - lb.t0 > 3 then at = new end
		if at then
			lb.part:Destroy()
			table.remove(lobs, i)
			land(lb, at, direct)
		else
			lb.pos = new
			lb.part.CFrame = CFrame.lookAt(new, new + lb.vel) * CFrame.Angles(now * 12, 0, 0)
		end
	end
end

function Loot.clear()
	flying = {}
	for _, lb in lobs do if lb.part.Parent then lb.part:Destroy() end end
	lobs = {}
end

return Loot
