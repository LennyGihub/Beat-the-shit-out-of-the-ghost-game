--!strict
-- MEDICAL SUPPLIES lying in the house. Every time a monster comes (Run.startFight), one medical item (an item that
-- heals: Shared/Items, `heal`) is put down somewhere in the house: on the floor, in a free spot, away from the
-- players. It glows green, so it can be found in the dark; whoever reaches it takes it for free (a prompt). At most
-- Config.Supplies.Max lie around at once; they are all cleared when the run ends (Run.endMatch).
-- Not in the sandbox / the tutorial (those never go through Run.startFight).
-- THE MAP'S OWN ITEM SPOTS: a map with a folder ItemSpots (parts with attribute Tier 1..3, Secret = in a secret
-- room; tools/build/maps/camp_items.luau) gets an item on every spot when a stage starts (Run.startStage, a new roll
-- each time): tier 1 common things, tier 2 better ones, tier 3 the best (Server/Secrets' rooms). The glow under an
-- item has its rarity's colour. Such a map gets no random medical item per monster: its spots replace them.
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Items = require(RS.Shared.Items)
local ItemModels = require(RS.Shared.ItemModels)
local Remotes = require(script.Parent.Remotes)
local MapLoader = require(script.Parent.MapLoader)
local Inventory = require(script.Parent.Inventory)
local Events = require(script.Parent.Events)

local Supplies = {}
local S = Config.Supplies
local rng = Random.new()
local lying = {} :: { Model }
local placed = {} :: { Model } -- (the map's spots)
local GREEN = Color3.fromRGB(90, 225, 110)
-- the item rarities each spot tier rolls (Shared/Items rarity 1..5)
local TIERS = { { 1, 2 }, { 2, 3 }, { 4, 5 } }
-- never put down at a spot: the pill bottle (Roblox moderation: nothing that reads as drugs, see CLAUDE.md)
local SKIP = { Painkillers = true } :: { [string]: boolean }

local function spotsFolder(): Instance?
	local live = workspace:FindFirstChild("Mansion")
	return live and live:FindFirstChild("ItemSpots")
end

-- one medical item: the common ones come more often than the rare ones
function Supplies.pick(avoid: { [string]: boolean }?): any
	local pool, total = {}, 0
	for _, it in Items.list do
		if it.heal and not it.exclusive and not (avoid and avoid[it.id]) then
			local w = it.rarity <= 1 and 3 or 1
			table.insert(pool, { it = it, w = w })
			total += w
		end
	end
	if #pool == 0 then
		if avoid then return Supplies.pick(nil) end
		return nil
	end
	local x = rng:NextNumber(0, total)
	for _, e in pool do
		x -= e.w
		if x <= 0 then return e.it end
	end
	return pool[#pool].it
end

local function alive(): number
	for i = #lying, 1, -1 do
		if not lying[i].Parent then table.remove(lying, i) end
	end
	return #lying
end

-- players = where the players stand (it is put down away from them). Returns true if one was put down.
function Supplies.spawn(players: { Vector3 }): boolean
	if spotsFolder() then return false end -- (the map has its own item spots)
	if alive() >= S.Max then return false end
	local it = Supplies.pick()
	if not it then return false end
	-- a free spot on a floor of the house (the monsters' own spot search): it comes back 4.6 studs above the floor
	local at = MapLoader.randomGhostSpawn(players, S.MinDist) - Vector3.new(0, 4.6, 0)
	for _, m in lying do
		if (m:GetPivot().Position - at).Magnitude < 12 then return false end -- (not two in one spot)
	end
	table.insert(lying, Supplies.put(it, at, GREEN, false))
	return true
end

-- an item lying on the floor at `at` (floor height), a glow ring under it, a prompt to take it
function Supplies.put(it: any, at: Vector3, color: Color3, secret: boolean): Model
	local m = ItemModels.build(it.shape, it.color, it.glow, it.id)
	m.Name = "Supply_" .. it.id
	m:PivotTo(CFrame.new(at) * CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0))
	-- sit it on the floor (the models' pivot is at the grip, not the bottom)
	local bcf, bsz = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + Vector3.new(0, at.Y + 0.15 - (bcf.Position.Y - bsz.Y / 2), 0))
	local glow = Instance.new("Part")
	glow.Name = "Glow"; glow.Anchored = true; glow.CanCollide = false; glow.CanQuery = false; glow.CanTouch = false; glow.CastShadow = false
	glow.Shape = Enum.PartType.Cylinder; glow.Size = Vector3.new(0.08, secret and 4 or 3, secret and 4 or 3); glow.Color = color; glow.Material = Enum.Material.Neon
	glow.Transparency = 0.45; glow.CFrame = CFrame.new(at + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	glow.Parent = m
	local light = Instance.new("PointLight"); light.Color = color; light.Range = secret and 18 or 12; light.Brightness = secret and 2 or 1.1; light.Parent = glow
	if secret then
		local sp = Instance.new("ParticleEmitter")
		sp.Texture = "rbxasset://textures/particles/sparkles_main.dds"; sp.Color = ColorSequence.new(color); sp.LightEmission = 1
		sp.Size = NumberSequence.new(0.25, 0); sp.Lifetime = NumberRange.new(0.8, 1.4); sp.Rate = 5; sp.Speed = NumberRange.new(0.5, 1.5)
		sp.SpreadAngle = Vector2.new(30, 30); sp.EmissionDirection = Enum.NormalId.Right; sp.Parent = glow
	end
	local pp = Events.prompt(glow, "Take", it.name .. "  -  " .. it.desc, 0.25)
	pp.Triggered:Connect(function(p: Player)
		if not m.Parent or not p:GetAttribute("InMatch") then return end
		if Inventory.give(p, it.id) then
			m:Destroy()
			Remotes.Fx:FireClient(p, "Toast", (secret and "SECRET FIND: " or "YOU FOUND ") .. string.upper(it.name), true)
		else
			Remotes.Fx:FireClient(p, "Toast", "YOUR HOTBAR IS FULL - DROP SOMETHING FIRST")
		end
	end)
	m.Parent = workspace
	return m
end

-- an item for a spot tier: rarer ones less often
function Supplies.pickTier(tier: number): any
	local t = TIERS[math.clamp(tier, 1, #TIERS)]
	local pool, total = {}, 0
	for _, it in Items.list do
		if it.rarity >= t[1] and it.rarity <= t[2] and not it.exclusive and not SKIP[it.id] then
			local w = t[2] - it.rarity + 1
			table.insert(pool, { it = it, w = w })
			total += w
		end
	end
	local x = rng:NextNumber(0, total)
	for _, e in pool do
		x -= e.w
		if x <= 0 then return e.it end
	end
	return pool[#pool] and pool[#pool].it
end

-- every spot of the map gets its item (Run.startStage). Returns how many.
function Supplies.placeMap(): number
	for _, m in placed do m:Destroy() end
	placed = {}
	local f = spotsFolder()
	if not f then return 0 end
	for _, s in f:GetChildren() do
		if s:IsA("BasePart") then
			local tier = tonumber(s:GetAttribute("Tier")) or 1
			local fixed = s:GetAttribute("Item")
			local it = (type(fixed) == "string" and Items.byId[fixed]) or Supplies.pickTier(tier)
			if it then
				local secret = s:GetAttribute("Secret") == true
				local color = secret and Color3.fromRGB(255, 200, 70) or Items.rarity[math.clamp(it.rarity, 1, #Items.rarity)].color
				table.insert(placed, Supplies.put(it, s.Position - Vector3.new(0, 0.1, 0), color, secret))
			end
		end
	end
	return #placed
end

function Supplies.clear()
	for _, m in lying do m:Destroy() end
	lying = {}
	for _, m in placed do m:Destroy() end
	placed = {}
end

return Supplies
