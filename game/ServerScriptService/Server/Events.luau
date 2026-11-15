-- Run events (a shop appears after a ghost dies): plane crash in the yard, van smashing into the house,
-- train derailing on the tracks. The wreck holds a shop with 6 rolled items; it lasts for the next 3 ghosts.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Items = require(RS.Shared.Items)
local ItemModels = require(RS.Shared.ItemModels)
local Remotes = require(script.Parent.Remotes)

local Events = {}
Events.onBuy = nil :: ((p: Player, id: string, at: Vector3) -> ())?
Events.onLeave = nil :: ((p: Player) -> ())?
Events.KINDS = { "plane", "van", "train" }
local rng = Random.new()
local FIRE = Color3.fromRGB(255, 130, 60)

local function models(): Folder return RS:WaitForChild("EventModels") :: Folder end

local function anchorAll(m: Instance)
	for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.Anchored = true end end
end

local function burn(part: BasePart?, size: number)
	if not part then return end
	local f = Instance.new("Fire"); f.Size = size; f.Heat = 12; f.Parent = part
	local sm = Instance.new("Smoke"); sm.Color = Color3.fromRGB(40, 38, 36); sm.Opacity = 0.35; sm.RiseVelocity = 8; sm.Size = size * 0.7; sm.Parent = part
	local l = Instance.new("PointLight"); l.Color = FIRE; l.Range = 30; l.Brightness = 0.9; l.Parent = part
end

function Events.prompt(parent: Instance, action: string, object: string, hold: number?, key: Enum.KeyCode?): ProximityPrompt
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = action; pp.ObjectText = object; pp.HoldDuration = hold or 0
	pp.MaxActivationDistance = 11; pp.RequiresLineOfSight = false
	pp.KeyboardKeyCode = key or Enum.KeyCode.F
	pp.Style = Enum.ProximityPromptStyle.Custom
	pp.Parent = parent
	return pp
end

-- 6 items, rarer ones less likely, no duplicates
function Events.rollStock(n: number): { any }
	local total = 0
	for _, r in Items.rarity do total += r.weight end
	local picked, out, tries = {}, {}, 0
	while #out < n and tries < 300 do
		tries += 1
		local x, rar = rng:NextNumber(0, total), 1
		for i, r in Items.rarity do
			x -= r.weight
			if x <= 0 then rar = i; break end
		end
		local pool = {}
		for _, it in Items.list do if it.rarity == rar and not picked[it.id] then table.insert(pool, it) end end
		if #pool > 0 then
			local it = pool[rng:NextInteger(1, #pool)]
			picked[it.id] = true
			table.insert(out, it)
		end
	end
	table.sort(out, function(a, b) return a.rarity > b.rarity end)
	return out
end

local function label(parent: BasePart, it, high: boolean)
	local rar = Items.rarity[it.rarity]
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(150, 58); bb.StudsOffset = Vector3.new(0, high and 2.6 or 1.6, 0); bb.MaxDistance = 20
	bb.Parent = parent
	local function t(text: string, y: number, h: number, color: Color3, font: Enum.Font)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1; l.Size = UDim2.new(1, 0, h, 0); l.Position = UDim2.new(0, 0, y, 0)
		l.Text = text; l.TextScaled = true; l.Font = font; l.TextColor3 = color
		l.TextStrokeTransparency = 0.2; l.TextStrokeColor3 = Color3.fromRGB(14, 10, 8); l.Parent = bb
	end
	t(rar.name, 0, 0.26, rar.color, Enum.Font.SpecialElite)
	t(string.upper(it.name), 0.26, 0.4, Color3.fromRGB(235, 225, 205), Enum.Font.PermanentMarker)
	t("$" .. it.price, 0.66, 0.34, Color3.fromRGB(150, 220, 110), Enum.Font.PermanentMarker)
end

-- a slot marked Ground (van) sits on the ground behind the wreck: find the real ground under it, level
local function groundCF(slot: Attachment, shop: Instance): CFrame
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = { shop }
	local pos = slot.WorldPosition
	local r = workspace:Raycast(pos + Vector3.new(0, 8, 0), Vector3.new(0, -20, 0), rp)
	local y = r and r.Position.Y or pos.Y
	local look = slot.WorldCFrame.LookVector
	local yaw = math.atan2(-look.X, -look.Z)
	return CFrame.new(pos.X, y, pos.Z) * CFrame.Angles(0, yaw, 0)
end

-- an old blanket on the ground under the ground items
local function tarp(shop: Instance, cfs: { CFrame })
	if #cfs == 0 then return end
	local c = Vector3.zero
	for _, cf in cfs do c += cf.Position end
	c /= #cfs
	local t = Instance.new("Part")
	t.Name = "Tarp"; t.Anchored = true; t.CanCollide = false; t.CanQuery = false; t.CanTouch = false
	t.Size = Vector3.new(9.5, 0.12, 4.2); t.Material = Enum.Material.Fabric; t.Color = Color3.fromRGB(70, 74, 60)
	t.CFrame = CFrame.new(c + Vector3.new(0, 0.07, 0)) * cfs[1].Rotation * CFrame.Angles(0, math.rad(rng:NextNumber(-4, 4)), 0)
	t.Parent = shop
end

-- put the stock on the shop's Slot1..6 attachments
local function stock(shop: Instance, list: { any })
	local groundSpots = {}
	for i, it in list do
		local slot = shop:FindFirstChild("Slot" .. i, true) :: Attachment?
		if slot then
			local m = ItemModels.build(it.shape, it.color, it.glow, it.id)
			m.Name = "Item_" .. it.id
			local lie = ItemModels.isLong(it.shape)
			local onGround = slot:GetAttribute("Ground") == true
			local base = onGround and groundCF(slot, shop) or slot.WorldCFrame
			if onGround then table.insert(groundSpots, base) end
			-- long items lie along the shelf (models extend toward -Z), short ones stand on it
			local cf = lie and base * CFrame.new(0, 0.35, 0) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0, 0, 1.6)
				or base * CFrame.new(0, 0.15, 0) * CFrame.Angles(0, math.rad(rng:NextNumber(-30, 30)), 0)
			m:PivotTo(cf)
			-- sit it on the shelf / ground (meshes have their pivot at the grip, not the bottom)
			local bcf, bsz = m:GetBoundingBox()
			m:PivotTo(m:GetPivot() + Vector3.new(0, base.Position.Y + 0.12 - (bcf.Position.Y - bsz.Y / 2), 0))
			m.Parent = shop
			-- rarity glow under the item
			local r = Items.rarity[it.rarity]
			local glowPart = Instance.new("Part")
			glowPart.Name = "RarityGlow"; glowPart.Anchored = true; glowPart.CanCollide = false; glowPart.CanQuery = false
			glowPart.Shape = Enum.PartType.Cylinder; glowPart.Size = Vector3.new(0.08, 2, 2); glowPart.Color = r.color; glowPart.Material = Enum.Material.Neon
			glowPart.Transparency = 0.55; glowPart.CFrame = base * CFrame.new(0, onGround and 0.16 or 0.05, 0) * CFrame.Angles(0, 0, math.pi / 2)
			glowPart.Parent = m
			local promptPart = glowPart
			label(promptPart, it, i > 3)
			local pp = Events.prompt(promptPart, "Buy  $" .. it.price, it.name .. "  -  " .. it.desc, 0.3)
			local at = base.Position
			pp.Triggered:Connect(function(p) if Events.onBuy then Events.onBuy(p, it.id, at) end end)
		end
	end
	tarp(shop, groundSpots)
end

local function vendor(cf: CFrame, line: string, ev)
	local tpl = SS:FindFirstChild("PilotLying") :: Model?
	if not tpl then return end
	local v = tpl:Clone()
	v:PivotTo(cf)
	local bb = v:FindFirstChildWhichIsA("BillboardGui", true)
	local lbl = bb and bb:FindFirstChildOfClass("TextLabel")
	if lbl then lbl.Text = line end
	v.Parent = workspace
	table.insert(ev.models, v)
	local torso = v:FindFirstChild("Torso") :: BasePart?
	if torso then
		local pp = Events.prompt(torso, "Leave the run", "Cash out to the lobby", 1.5, Enum.KeyCode.R)
		pp.Triggered:Connect(function(p) if Events.onLeave then Events.onLeave(p) end end)
	end
end

local function fx(kind: string, ...)
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("InMatch") then Remotes.Fx:FireClient(p, kind, ...) end
	end
end

-- PLANE: dives into the yard; the pilot's market stall stands next to the wreck
local function plane(ev, trigger: Vector3)
	local land = Vector3.new(rng:NextNumber(-55, 55), 0, rng:NextNumber(98, 122))
	fx("PlaneCrash", land, trigger)
	task.wait(4.2)
	local w = (RS:FindFirstChild("PlaneModel") :: Model):Clone()
	w.Name = "PlaneWreck"
	local yaw = CFrame.lookAt(land, Vector3.new(trigger.X, land.Y, trigger.Z)).Rotation
	w:PivotTo(CFrame.new(land + Vector3.new(0, 2.2, 0)) * yaw * CFrame.Angles(0, math.rad(70), 0) * CFrame.Angles(math.rad(-9), 0, math.rad(7)))
	anchorAll(w)
	for _, n in { "EngineL", "EngineR", "Body" } do burn(w:FindFirstChild(n, true) :: BasePart?, n == "Body" and 9 or 6) end
	w.Parent = workspace
	table.insert(ev.models, w)
	fx("PlaneImpact", land)
	task.wait(1.5)
	local stand = (SS:FindFirstChild("StandTemplate") :: Model):Clone()
	local dir = Vector3.new(trigger.X - land.X, 0, trigger.Z - land.Z)
	dir = dir.Magnitude > 1 and dir.Unit or Vector3.new(0, 0, -1)
	local spot = land + dir * 24 + dir:Cross(Vector3.yAxis) * 4
	stand:PivotTo(CFrame.lookAt(Vector3.new(spot.X, 0, spot.Z), Vector3.new(trigger.X, 0, trigger.Z)))
	stand.Parent = workspace
	table.insert(ev.models, stand)
	stock(stand, ev.stock)
	vendor(stand:GetPivot() * CFrame.new(-7.5, 0, 1.5) * CFrame.Angles(0, math.rad(-25), 0), "\"ugh... my leg... the stuff's on the table. cash first.\"", ev)
	ev.shopPos = (stand:GetPivot() * CFrame.new(0, 4, 0)).Position
	ev.label = "PILOT'S STAND"
end

-- VAN: comes out of the trees and smashes nose-first into the front of the house; shop in the open back
Events.VAN_CF = CFrame.new(44, 0, 67) * CFrame.Angles(0, math.rad(14), 0)
local function van(ev)
	fx("VanCrash", Events.VAN_CF)
	task.wait(2.7)
	local v = (models():FindFirstChild("Van") :: Model):Clone()
	v:PivotTo(Events.VAN_CF * CFrame.Angles(math.rad(-4), 0, math.rad(3)))
	anchorAll(v)
	burn(v:FindFirstChild("Hood", true) :: BasePart?, 6)
	v.Parent = workspace
	table.insert(ev.models, v)
	fx("VanImpact", (Events.VAN_CF * CFrame.new(0, 3, -8)).Position)
	task.wait(1)
	stock(v, ev.stock)
	vendor(Events.VAN_CF * CFrame.new(6.5, 0, 9) * CFrame.Angles(0, math.rad(60), 0), "\"lost the brakes... bought a lot of junk though. wanna see?\"", ev)
	ev.shopPos = (Events.VAN_CF * CFrame.new(0, 4, 9)).Position
	ev.label = "VAN SHOP"
end

-- TRAIN: races along the tracks, jumps the rails; the second wagon is the shop (side door toward the house)
-- cars are built along Z (front = -Z); the tracks run along +X at z = 150, so yaw -90 deg puts them on the rails.
-- The shop wagon's open side is its local -X, which then faces the house.
local ONRAILS = CFrame.Angles(0, -math.pi / 2, 0)
Events.TRAIN_Z = 150
Events.TRAIN_CF = {
	loco = CFrame.new(-38, 0, 152) * ONRAILS * CFrame.Angles(0, math.rad(-12), 0) * CFrame.new(0, 2.6, 0) * CFrame.Angles(0, 0, math.rad(80)),
	w1 = CFrame.new(-10, 0, 147) * ONRAILS * CFrame.Angles(0, math.rad(26), math.rad(-5)),
	w2 = CFrame.new(18, 0, 148) * ONRAILS * CFrame.Angles(0, math.rad(-5), 0),
}
local function train(ev)
	local T = Events.TRAIN_CF
	fx("TrainCrash", T.loco, T.w1, T.w2)
	task.wait(4)
	local f = models()
	local loco = (f:FindFirstChild("TrainLoco") :: Model):Clone(); loco:PivotTo(T.loco)
	local w1 = (f:FindFirstChild("TrainWagon") :: Model):Clone(); w1:PivotTo(T.w1)
	local w2 = (f:FindFirstChild("TrainShopWagon") :: Model):Clone(); w2:PivotTo(T.w2)
	for _, m in { loco, w1, w2 } do anchorAll(m); m.Parent = workspace; table.insert(ev.models, m) end
	burn(loco:FindFirstChild("Boiler", true) :: BasePart?, 9)
	burn(w1:FindFirstChild("Body", true) :: BasePart?, 5)
	fx("TrainImpact", T.loco.Position)
	task.wait(1)
	stock(w2, ev.stock)
	vendor(T.w2 * CFrame.new(-9, 0, 9) * CFrame.Angles(0, math.rad(70), 0), "\"conductor... ugh... the wagon's open. everything must go.\"", ev)
	ev.shopPos = (T.w2 * CFrame.new(-7, 4, 0)).Position
	ev.label = "TRAIN SHOP"
end

-- start an event (yields through its cinematic). kind = "plane" | "van" | "train"
function Events.spawn(kind: string, trigger: Vector3)
	local ev = { kind = kind, models = {}, stock = Events.rollStock(6), shopPos = trigger, label = "SHOP" }
	if kind == "van" then van(ev) elseif kind == "train" then train(ev) else plane(ev, trigger) end
	return ev
end

function Events.despawn(ev)
	if not ev then return end
	for _, m in ev.models do m:Destroy() end
	ev.models = {}
end

return Events
