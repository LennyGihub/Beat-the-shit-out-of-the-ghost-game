--!strict
-- MEDICAL SUPPLIES lying in the house. Every time a monster comes (Run.startFight), one medical item (an item that
-- heals: Shared/Items, `heal`) is put down somewhere in the house: on the floor, in a free spot, away from the
-- players. It glows green, so it can be found in the dark; whoever reaches it takes it for free (a prompt). At most
-- Config.Supplies.Max lie around at once; they are all cleared when the run ends (Run.endMatch).
-- Not in the sandbox / the tutorial (those never go through Run.startFight).
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
local GREEN = Color3.fromRGB(90, 225, 110)

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
	if alive() >= S.Max then return false end
	local it = Supplies.pick()
	if not it then return false end
	-- a free spot on a floor of the house (the monsters' own spot search): it comes back 4.6 studs above the floor
	local at = MapLoader.randomGhostSpawn(players, S.MinDist) - Vector3.new(0, 4.6, 0)
	for _, m in lying do
		if (m:GetPivot().Position - at).Magnitude < 12 then return false end -- (not two in one spot)
	end
	local m = ItemModels.build(it.shape, it.color, it.glow, it.id)
	m.Name = "Supply_" .. it.id
	m:PivotTo(CFrame.new(at) * CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0))
	-- sit it on the floor (the models' pivot is at the grip, not the bottom)
	local bcf, bsz = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + Vector3.new(0, at.Y + 0.15 - (bcf.Position.Y - bsz.Y / 2), 0))
	local glow = Instance.new("Part")
	glow.Name = "Glow"; glow.Anchored = true; glow.CanCollide = false; glow.CanQuery = false; glow.CanTouch = false; glow.CastShadow = false
	glow.Shape = Enum.PartType.Cylinder; glow.Size = Vector3.new(0.08, 3, 3); glow.Color = GREEN; glow.Material = Enum.Material.Neon
	glow.Transparency = 0.45; glow.CFrame = CFrame.new(at + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	glow.Parent = m
	local light = Instance.new("PointLight"); light.Color = GREEN; light.Range = 14; light.Brightness = 1.4; light.Parent = glow
	local pp = Events.prompt(glow, "Take", it.name .. "  -  " .. it.desc, 0.25)
	pp.Triggered:Connect(function(p: Player)
		if not m.Parent or not p:GetAttribute("InMatch") then return end
		if Inventory.give(p, it.id) then
			m:Destroy()
			Remotes.Fx:FireClient(p, "Toast", "YOU FOUND " .. string.upper(it.name), true)
		else
			Remotes.Fx:FireClient(p, "Toast", "YOUR HOTBAR IS FULL - DROP SOMETHING FIRST")
		end
	end)
	m.Parent = workspace
	table.insert(lying, m)
	return true
end

function Supplies.clear()
	for _, m in lying do m:Destroy() end
	lying = {}
end

return Supplies
