--!strict
-- Fires on wooden surfaces. Fire items (burning bat, flare gun, molotov, flamethrower) set the wood they hit
-- burning: layered flame particles + embers + smoke, a flickering light and a crackle. The wood scorches black,
-- the fire spreads a little, burns the ghost and anyone standing in it, then burns out.
-- Fire.flames() is also used for the ghost when she burns. Fire.clear() removes every fire and the scorch marks.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Sounds = require(RS.Shared.Sounds)

local Fire = {}
local WOOD = { [Enum.Material.Wood] = true, [Enum.Material.WoodPlanks] = true }
local MAX_FIRES = 16
local LIFE = 14
local FIRE_COLOR = Color3.fromRGB(255, 120, 30)
local rng = Random.new()

type FireRec = { spot: BasePart, part: BasePart, born: number, untilT: number, nextSpread: number, gen: number, light: PointLight, scale: number, by: Player? }
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

-- put every fire out and clean the scorch marks (next ghost / end of the run)
function Fire.clear()
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
	for i = #fires, 1, -1 do
		local f = fires[i]
		local left = f.untilT - now
		if left <= 0 or not f.spot.Parent then
			f.spot:Destroy()
			table.remove(fires, i)
			continue
		end
		-- flicker, and die down at the end
		local fade = math.clamp(left / 3, 0, 1)
		f.light.Brightness = (2 + math.noise(now * 6, i) * 1.6) * fade
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
				if hrp and p:GetAttribute("InMatch") and (hrp.Position - pos).Magnitude < 3.2 then Combat.damagePlayer(p, 2, nil, Vector3.zero) end -- burning floor: not blockable
			end
		end
	end
end)

return Fire
