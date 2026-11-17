--!strict
-- Fires on wooden surfaces. Fire items (burning bat, flare gun, molotov, flamethrower) set the wood they hit
-- burning: layered flame particles + embers + smoke, a flickering light and a crackle. The wood scorches black,
-- the fire spreads a little, burns the ghost and anyone standing in it, then burns out.
-- Fire.flames() is also used for the ghost when she burns. Fire.clear() removes every fire and the scorch marks.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Sounds = require(RS.Shared.Sounds)
local Config = require(RS.Shared.Config)
local Remotes = require(script.Parent.Remotes)

local Fire = {}
local WOOD = { [Enum.Material.Wood] = true, [Enum.Material.WoodPlanks] = true }
local MAX_FIRES = 16
local LIFE = 14
local FIRE_COLOR = Color3.fromRGB(255, 120, 30)
local rng = Random.new()

type FireRec = { spot: BasePart, part: BasePart, born: number, untilT: number, nextSpread: number, gen: number, light: PointLight?, scale: number, by: Player?, wild: boolean? }
local fires = {} :: { FireRec }
local scorched = {} :: { [BasePart]: Color3 }

local function seq(...): NumberSequence
	local pts, args = {}, { ... }
	for i = 1, #args, 2 do table.insert(pts, NumberSequenceKeypoint.new(args[i], args[i + 1])) end
	return NumberSequence.new(pts)
end
local FLAME_COLORS = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 180)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 180, 50)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(240, 90, 20)), ColorSequenceKeypoint.new(0.85, Color3.fromRGB(150, 40, 15)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 30, 25)) })

-- realistic flames on a part (they come out of its whole volume) or an attachment; s = size
-- BLEEDING on a body: heavy dark-red drops that fall (no glow, no flames), with a spurt now and then
function Fire.blood(parent: Instance, s: number): { Instance }
	local out = {}
	local function emitter(props: { [string]: any })
		local e = Instance.new("ParticleEmitter")
		e.Texture = "rbxasset://textures/particles/smoke_main.dds"
		e.LightEmission = 0; e.LightInfluence = 0.4
		e.Color = ColorSequence.new(Color3.fromRGB(170, 6, 10), Color3.fromRGB(80, 0, 4))
		e.Rotation = NumberRange.new(0, 360)
		for k, v in props do (e :: any)[k] = v end
		e.Parent = parent
		table.insert(out, e)
	end
	-- drops running off it and falling to the floor
	emitter({ Size = seq(0, 0.28 * s, 0.6, 0.22 * s, 1, 0.1 * s), Transparency = seq(0, 0, 0.8, 0.05, 1, 1), Lifetime = NumberRange.new(0.7, 1.1), Rate = 34,
		Speed = NumberRange.new(1 * s, 4 * s), Acceleration = Vector3.new(0, -42, 0), SpreadAngle = Vector2.new(180, 180), Drag = 0.5 })
	-- spurts
	emitter({ Size = seq(0, 0.2 * s, 1, 0.34 * s), Transparency = seq(0, 0, 0.7, 0.1, 1, 1), Lifetime = NumberRange.new(0.35, 0.6), Rate = 16,
		Speed = NumberRange.new(9 * s, 15 * s), Acceleration = Vector3.new(0, -50, 0), SpreadAngle = Vector2.new(55, 55), EmissionDirection = Enum.NormalId.Front })
	-- a thin red mist round the wound
	emitter({ Size = seq(0, 0.8 * s, 1, 1.8 * s), Transparency = seq(0, 0.75, 1, 1), Lifetime = NumberRange.new(0.4, 0.7), Rate = 8,
		Speed = NumberRange.new(0.5, 2), SpreadAngle = Vector2.new(180, 180), Color = ColorSequence.new(Color3.fromRGB(120, 0, 6)) })
	return out
end

function Fire.flames(parent: Instance, s: number): { Instance }
	local out = {}
	local function emitter(props: { [string]: any })
		local e = Instance.new("ParticleEmitter")
		e.LightInfluence = 0; e.EmissionDirection = Enum.NormalId.Top
		e.Rotation = NumberRange.new(0, 360)
		for k, v in props do (e :: any)[k] = v end
		e.Parent = parent
		table.insert(out, e)
	end
	-- main tongues of fire
	emitter({ Texture = "rbxasset://textures/particles/fire_main.dds", Color = FLAME_COLORS, LightEmission = 1,
		Size = seq(0, 1.1 * s, 0.35, 2.2 * s, 1, 0.3 * s), Transparency = seq(0, 0.3, 0.5, 0.35, 1, 1),
		Lifetime = NumberRange.new(0.5, 0.95), Rate = 32, Speed = NumberRange.new(2.5 * s, 5 * s),
		Acceleration = Vector3.new(0, 7 * s, 0), SpreadAngle = Vector2.new(14, 14), RotSpeed = NumberRange.new(-90, 90) })
	-- bright core at the base
	emitter({ Texture = "rbxasset://textures/particles/fire_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 250, 215), Color3.fromRGB(255, 170, 60)),
		LightEmission = 1, Size = seq(0, 0.8 * s, 0.4, 1.2 * s, 1, 0), Transparency = seq(0, 0.2, 1, 1),
		Lifetime = NumberRange.new(0.25, 0.45), Rate = 24, Speed = NumberRange.new(1.5 * s, 3 * s), SpreadAngle = Vector2.new(8, 8) })
	-- embers
	emitter({ Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 190, 80), Color3.fromRGB(255, 80, 20)),
		LightEmission = 1, Size = seq(0, 0.18 * s, 1, 0), Lifetime = NumberRange.new(0.9, 2), Rate = 7,
		Speed = NumberRange.new(4 * s, 9 * s), Acceleration = Vector3.new(0, 4, 0), SpreadAngle = Vector2.new(35, 35), RotSpeed = NumberRange.new(-200, 200) })
	-- smoke
	emitter({ Texture = "rbxasset://textures/particles/smoke_main.dds", Color = ColorSequence.new(Color3.fromRGB(55, 50, 46), Color3.fromRGB(30, 28, 26)),
		LightEmission = 0, Size = seq(0, 1.8 * s, 1, 6.5 * s), Transparency = seq(0, 0.65, 0.4, 0.7, 1, 1),
		Lifetime = NumberRange.new(2.5, 4), Rate = 4, Speed = NumberRange.new(2.5 * s, 4.5 * s), Acceleration = Vector3.new(0, 2.5, 0),
		SpreadAngle = Vector2.new(20, 20), RotSpeed = NumberRange.new(-30, 30) })
	return out
end

-- every wooden part of the house (walls, floors, furniture)
local function woodParts(): { BasePart }
	local m = workspace:FindFirstChild("Mansion")
	local out = {}
	if not m then return out end
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") and WOOD[d.Material] and d.Transparency < 1 then table.insert(out, d) end
	end
	return out
end

local function closestPoint(p: BasePart, pos: Vector3): Vector3
	local l = p.CFrame:PointToObjectSpace(pos)
	local h = p.Size / 2
	return p.CFrame:PointToWorldSpace(Vector3.new(math.clamp(l.X, -h.X, h.X), math.clamp(l.Y, -h.Y, h.Y), math.clamp(l.Z, -h.Z, h.Z)))
end

local function burningNear(pos: Vector3, r: number): boolean
	for _, f in fires do if (f.spot.Position - pos).Magnitude < r then return true end end
	return false
end

local function start(part: BasePart, at: Vector3, s: number, gen: number, by: Player?)
	if #fires >= MAX_FIRES or burningNear(at, 3.2 * s) then return end
	local spot = Instance.new("Part")
	spot.Name = "FireSpot"
	spot.Anchored = true; spot.CanCollide = false; spot.CanQuery = false; spot.CanTouch = false; spot.CastShadow = false
	spot.Transparency = 1
	spot.Size = Vector3.new(2.6 * s, 0.4, 2.6 * s)
	spot.CFrame = CFrame.new(at + Vector3.new(0, 0.3, 0))
	spot.Parent = workspace
	Fire.flames(spot, s)
	local light = Instance.new("PointLight")
	light.Color = FIRE_COLOR; light.Range = 16 * s; light.Brightness = 2.5; light.Shadows = true
	light.Parent = spot
	local snd = Instance.new("Sound")
	snd.SoundId = "rbxassetid://" .. Sounds.FireLoop.ids[1]; snd.Volume = Sounds.FireLoop.volume; snd.Looped = true
	snd.RollOffMinDistance = 8; snd.RollOffMaxDistance = 70
	snd.Parent = spot
	snd:Play()
	-- the wood chars
	if not scorched[part] then
		scorched[part] = part.Color
		part.Color = part.Color:Lerp(Color3.fromRGB(20, 14, 10), 0.55)
	end
	local now = os.clock()
	table.insert(fires, { spot = spot, part = part, born = now, untilT = now + LIFE * rng:NextNumber(0.8, 1.2), nextSpread = now + 3,
		gen = gen, light = light, scale = s, by = by })
end

-- set fire to the wood near `pos`: up to `count` fires on the closest wooden surfaces within `radius`.
-- force = burn even if there is no wood there (a molotov burns on any floor)
function Fire.ignite(pos: Vector3, radius: number, by: Player?, count: number?, force: boolean?)
	local list = {}
	for _, p in woodParts() do
		local c = closestPoint(p, pos)
		local d = (c - pos).Magnitude
		if d <= radius then table.insert(list, { p = p, c = c, d = d }) end
	end
	table.sort(list, function(a, b) return a.d < b.d end)
	local n = 0
	for _, e in list do
		if n >= (count or 1) then break end
		local before = #fires
		start(e.p, e.c, 1.25, 0, by)
		if #fires > before then n += 1 end
	end
	if n == 0 and force then
		local r = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -12, 0))
		if r and r.Instance:IsA("BasePart") then start(r.Instance, r.Position, 1.25, 0, by) end
	end
end

-- WILDFIRE (the flamethrower, Config.Wildfire) ------------------------------------------------------------
local W = Config.Wildfire
local wildUntil = 0 -- it keeps spreading until then
local wildCount = 0
local wildSeq = 0
local wildAnnounced = false
local function setWildCount(n: number)
	if n ~= wildCount then
		wildCount = n
		RS:SetAttribute("WildFires", n) -- the clients' fire roar and heat glow follow it (Client/Fx)
	end
end
local function houseParams(): RaycastParams
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { workspace:FindFirstChild("Mansion") or workspace.Terrain }
	return rp
end
-- big flames for the wildfire: taller and brighter than a normal fire, lighter on particles (there are many)
local function wildFlames(spot: BasePart, s: number, smoke: boolean)
	local function emitter(props: { [string]: any })
		local e = Instance.new("ParticleEmitter")
		e.LightInfluence = 0; e.EmissionDirection = Enum.NormalId.Top; e.Rotation = NumberRange.new(0, 360)
		for k, v in props do (e :: any)[k] = v end
		e.Parent = spot
	end
	emitter({ Texture = "rbxasset://textures/particles/fire_main.dds", Color = FLAME_COLORS, LightEmission = 0.9,
		Size = seq(0, 1.5 * s, 0.3, 3.1 * s, 1, 0.5 * s), Transparency = seq(0, 0.3, 0.5, 0.4, 1, 1),
		Lifetime = NumberRange.new(0.7, 1.3), Rate = 26, Speed = NumberRange.new(4 * s, 8 * s),
		Acceleration = Vector3.new(0, 9 * s, 0), SpreadAngle = Vector2.new(16, 16), RotSpeed = NumberRange.new(-90, 90) })
	emitter({ Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 200, 90), Color3.fromRGB(255, 80, 20)),
		LightEmission = 1, Size = seq(0, 0.22 * s, 1, 0), Lifetime = NumberRange.new(1.2, 2.6), Rate = 6,
		Speed = NumberRange.new(6 * s, 13 * s), Acceleration = Vector3.new(0, 5, 0), SpreadAngle = Vector2.new(40, 40), RotSpeed = NumberRange.new(-200, 200) })
	if smoke then
		emitter({ Texture = "rbxasset://textures/particles/smoke_main.dds", Color = ColorSequence.new(Color3.fromRGB(50, 44, 40), Color3.fromRGB(24, 22, 20)),
			LightEmission = 0, Size = seq(0, 2.4 * s, 1, 9 * s), Transparency = seq(0, 0.6, 0.4, 0.7, 1, 1),
			Lifetime = NumberRange.new(3, 4.5), Rate = 3, Speed = NumberRange.new(3 * s, 5 * s), Acceleration = Vector3.new(0, 2.5, 0),
			SpreadAngle = Vector2.new(22, 22), RotSpeed = NumberRange.new(-30, 30) })
	end
end
-- one wildfire at a point on a floor (normal up) or a wall (a tall sheet of flame against it)
local function startWild(part: BasePart, at: Vector3, normal: Vector3, by: Player?): boolean
	if wildCount >= W.Max then return false end
	for _, f in fires do
		if f.wild and (f.spot.Position - at).Magnitude < 4.6 then return false end
	end
	-- a clearing around every player: it never lights right on top of someone (flames in your face hide everything)
	for _, p in Players:GetPlayers() do
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and (hrp.Position - at).Magnitude < W.Clear then return false end
	end
	wildSeq += 1
	local s = rng:NextNumber(1.3, 2.1)
	local onWall = normal.Y < 0.5
	local spot = Instance.new("Part")
	spot.Name = "WildFire"
	spot.Anchored = true; spot.CanCollide = false; spot.CanQuery = false; spot.CanTouch = false; spot.CastShadow = false
	spot.Transparency = 1
	if onWall then
		local flat = Vector3.new(normal.X, 0, normal.Z)
		flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, 1)
		spot.Size = Vector3.new(3.4 * s, 4.5, 0.5)
		spot.CFrame = CFrame.lookAt(at + flat * 0.5, at + flat * 2)
	else
		spot.Size = Vector3.new(3 * s, 0.4, 3 * s)
		spot.CFrame = CFrame.new(at + Vector3.new(0, 0.3, 0))
	end
	spot.Parent = workspace
	wildFlames(spot, s, wildSeq % 3 == 0)
	local light: PointLight? = nil
	if wildSeq % 2 == 0 then -- every other one lights the room (no shadows: there are many)
		local l = Instance.new("PointLight")
		l.Color = FIRE_COLOR; l.Range = 16 * s; l.Brightness = 1.1; l.Shadows = false
		l.Parent = spot
		light = l
	end
	if wildSeq % 5 == 1 then
		local snd = Instance.new("Sound")
		snd.SoundId = "rbxassetid://" .. Sounds.FireLoop.ids[1]; snd.Volume = Sounds.FireLoop.volume * 1.3; snd.Looped = true
		snd.PlaybackSpeed = rng:NextNumber(0.8, 1.1); snd.RollOffMinDistance = 10; snd.RollOffMaxDistance = 90
		snd.Parent = spot
		snd:Play()
	end
	-- it chars what it burns (not the huge slabs: a whole floor would turn black at once)
	if not scorched[part] and part.Size.Magnitude < 40 then
		scorched[part] = part.Color
		part.Color = part.Color:Lerp(Color3.fromRGB(20, 14, 10), 0.55)
	end
	local now = os.clock()
	table.insert(fires, { spot = spot, part = part, born = now, untilT = now + rng:NextNumber(W.LifeMin, W.LifeMax),
		nextSpread = now + rng:NextNumber(W.SpreadMin, W.SpreadMax), gen = 0, light = light, scale = s, by = by, wild = true })
	setWildCount(wildCount + 1)
	if wildCount >= 14 and not wildAnnounced then
		wildAnnounced = true
		Remotes.Fx:FireAllClients("HouseOnFire")
	end
	return true
end
-- a wildfire tries to spread: across the floor, up a wall it meets, through that wall, or up to the next floor
local function spreadWild(f: FireRec, rp: RaycastParams)
	local a = rng:NextNumber(0, math.pi * 2)
	local dir = Vector3.new(math.cos(a), 0, math.sin(a))
	local dist = rng:NextNumber(5, 9.5)
	local from = f.spot.Position + Vector3.new(0, 2.6, 0)
	if rng:NextNumber() < 0.07 then
		-- up through the ceiling to the floor above
		local up = workspace:Raycast(from, Vector3.new(0, 30, 0), rp)
		if up then
			local down = workspace:Raycast(up.Position + Vector3.new(dir.X * 2, 5, dir.Z * 2), Vector3.new(0, -7, 0), rp)
			if down and down.Normal.Y > 0.7 and down.Instance:IsA("BasePart") then startWild(down.Instance, down.Position, down.Normal, f.by) end
		end
		return
	end
	local wall = workspace:Raycast(from, dir * dist, rp)
	if wall and wall.Normal.Y < 0.5 and wall.Instance:IsA("BasePart") then
		-- up the wall
		startWild(wall.Instance, wall.Position + Vector3.new(0, rng:NextNumber(-1.5, 5), 0), wall.Normal, f.by)
		if rng:NextNumber() < 0.3 then
			-- and through it, onto the floor of the next room
			local down = workspace:Raycast(wall.Position + dir * 3 + Vector3.new(0, 1, 0), Vector3.new(0, -16, 0), rp)
			if down and down.Normal.Y > 0.7 and down.Instance:IsA("BasePart") then startWild(down.Instance, down.Position, down.Normal, f.by) end
		end
	else
		local down = workspace:Raycast(from + dir * dist, Vector3.new(0, -16, 0), rp)
		if down and down.Normal.Y > 0.7 and down.Instance:IsA("BasePart") then startWild(down.Instance, down.Position, down.Normal, f.by) end
	end
end
-- the flamethrower hit a surface: the wildfire starts there and keeps spreading for a while after the last squirt
function Fire.wildfire(part: BasePart, at: Vector3, normal: Vector3, by: Player?)
	wildUntil = os.clock() + W.Campaign
	startWild(part, at, normal, by)
end

-- put every fire out and clean the scorch marks (next ghost / end of the run)
function Fire.clear()
	wildUntil = 0
	wildAnnounced = false
	setWildCount(0)
	for _, f in fires do f.spot:Destroy() end
	table.clear(fires)
	for p, c in scorched do if p.Parent then p.Color = c end end
	table.clear(scorched)
end

local lastBurn = 0
RunService.Heartbeat:Connect(function()
	if #fires == 0 then return end
	local now = os.clock()
	local doBurn = now - lastBurn > 0.5
	if doBurn then lastBurn = now end
	local Ghost = require(script.Parent.Ghost) :: any
	local Combat = require(script.Parent.Combat) :: any
	local rpWild: RaycastParams? = nil
	local wildNearGhost = false
	local wildBy: Player? = nil
	local gNow = Ghost.current
	local gPos: Vector3? = (gNow and Ghost.alive() and gNow.hrp) and gNow.hrp.Position or nil
	for i = #fires, 1, -1 do
		local f = fires[i]
		local left = f.untilT - now
		if left <= 0 or not f.spot.Parent then
			f.spot:Destroy()
			table.remove(fires, i)
			if f.wild then setWildCount(math.max(0, wildCount - 1)) end
			continue
		end
		if f.wild then
			-- the wildfire: dies down at the end, spreads while the campaign lasts, burns only the monster
			if left < 3 then
				for _, e in f.spot:GetChildren() do if e:IsA("ParticleEmitter") then e.Rate = e.Rate * 0.99 end end
				if f.light then f.light.Brightness = 1.1 * math.clamp(left / 3, 0, 1) end
			end
			if now > f.nextSpread and now < wildUntil then
				f.nextSpread = now + rng:NextNumber(W.SpreadMin, W.SpreadMax)
				rpWild = rpWild or houseParams()
				spreadWild(f, rpWild :: RaycastParams)
			end
			if doBurn and gPos and (gPos - f.spot.Position).Magnitude < W.Radius then
				wildNearGhost = true
				wildBy = wildBy or f.by
			end
			continue
		end
		-- flicker, and die down at the end
		local fade = math.clamp(left / 3, 0, 1)
		if f.light then f.light.Brightness = (2 + math.noise(now * 6, i) * 1.6) * fade end
		if left < 3 then
			for _, e in f.spot:GetChildren() do if e:IsA("ParticleEmitter") then e.Rate = e.Rate * 0.995 end end
		end
		-- spread to nearby wood
		if now > f.nextSpread then
			f.nextSpread = now + rng:NextNumber(2.5, 4)
			if f.gen < 3 and rng:NextNumber() < 0.4 then
				local dir = Vector3.new(rng:NextNumber(-1, 1), 0, rng:NextNumber(-1, 1))
				if dir.Magnitude > 0.1 then
					local to = f.spot.Position + dir.Unit * rng:NextNumber(3.5, 6)
					for _, p in woodParts() do
						local c = closestPoint(p, to)
						if (c - to).Magnitude < 2.5 then start(p, c, 1.25, f.gen + 1, f.by); break end
					end
				end
			end
		end
		-- whatever stands in the fire burns
		if doBurn then
			local pos = f.spot.Position
			local g = Ghost.current
			if g and Ghost.alive() and g.hrp and (g.hrp.Position - pos).Magnitude < 5.5 then
				Ghost.burn(7, 1.2, FIRE_COLOR, f.by)
			end
			for _, p in Players:GetPlayers() do
				local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
				-- burning floor: not blockable. Friendly fire off: a fire a player lit only burns that player
				if hrp and p:GetAttribute("InMatch") and (hrp.Position - pos).Magnitude < 3.2 and (f.by == nil or f.by == p or Combat.friendlyFire()) then
					Combat.damagePlayer(p, 2, nil, Vector3.zero)
				end
			end
		end
	end
	-- standing anywhere in the wildfire burns the monster at one steady rate (however many fires are around it)
	if wildNearGhost then Ghost.burn(W.Dps, 0.6, FIRE_COLOR, wildBy) end
end)

return Fire
