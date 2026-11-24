--!strict
-- LONG-TERM GOALS, server side: the bestiary and the badges (definitions: Shared/Badges).
-- * Bestiary.record(p, monsterId, evolved, nightmare): a player beat a monster. Counts it in their save
--   (Data: Bestiary[key], key = id or id .. "_E"), tells the client about a first-time entry, then checks the badges.
-- * Bestiary.check(p): unlocks every badge whose goal is reached: pays its cash once, fires Fx "BadgeUnlocked" and
--   gives the real Roblox badge when one is set up (Badge.robloxId > 0).
-- * Bestiary.start(lobby): in the lobby, builds one posed, anchored display copy of every monster and every evolved
--   form in ReplicatedStorage.BestiaryModels (named by key) for the BESTIARY panel's 3D view.
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local BadgeService = game:GetService("BadgeService")
local Badges = require(RS.Shared.Badges)
local Monsters = require(RS.Shared.Monsters)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Analytics = require(script.Parent.Analytics)
local Evolved = require(script.Parent.Evolved)

local Bestiary = {}

function Bestiary.check(p: Player)
	local d = Data.get(p) :: any
	if not d then return end
	local changed = false
	for _, badge in Badges.list do
		if not d.Badges[badge.id] and Badges.value(badge.stat, d.Bestiary, d.Kills, d.GhostLevel - 1, d.Nightmare) >= badge.goal then
			d.Badges[badge.id] = true
			d.Cash += badge.reward
			Analytics.cash(p, "Source", badge.reward, d.Cash, "Badge", badge.id)
			changed = true
			Remotes.Fx:FireClient(p, "BadgeUnlocked", badge.id)
			if badge.robloxId > 0 then
				task.spawn(function()
					local ok, err = pcall(function() BadgeService:AwardBadge(p.UserId, badge.robloxId) end)
					if not ok then warn("[Bestiary] AwardBadge " .. badge.id .. ": " .. tostring(err)) end
				end)
			end
		end
	end
	if changed then
		Data.refresh(p)
		task.spawn(Data.save, p)
	end
end

function Bestiary.record(p: Player, monsterId: string, evolved: boolean, nightmare: boolean)
	local d = Data.get(p) :: any
	if not d then return end
	local key = monsterId .. (evolved and "_E" or "")
	local entry = Badges.entryByKey[key]
	if not entry then return end
	local before = d.Bestiary[key] or 0
	d.Bestiary[key] = before + 1
	if nightmare then d.Nightmare += 1 end
	if before == 0 then
		Remotes.Fx:FireClient(p, "BestiaryNew", key)
	elseif Badges.stars(before + 1) > Badges.stars(before) then
		Remotes.Fx:FireClient(p, "Toast", entry.title .. " - MASTERY " .. string.rep("I", Badges.stars(before + 1)), true)
	end
	Data.refresh(p)
	Bestiary.check(p)
end

-- a save just loaded: badges earned before they existed (old kills, old best wave) are given now
function Bestiary.setup(p: Player)
	task.delay(3, function()
		if p.Parent then Bestiary.check(p) end
	end)
end

-- the display pose (joint -> rotation, baked into the copy): standing, one arm half raised, looking at you
local A = CFrame.Angles
local POSE: { [string]: CFrame } = {
	Waist = A(0.1, 0.18, 0), Neck = A(-0.1, -0.22, 0.05),
	RightShoulder = A(0.75, 0, 0.3), RightElbow = A(0.9, 0, 0), RightWrist = A(0.2, 0, 0),
	LeftShoulder = A(0.3, 0, -0.28), LeftElbow = A(0.45, 0, 0),
	RightHip = A(0.08, 0, 0.07), LeftHip = A(-0.06, 0, -0.07),
}
local KEEP = { "BasePart", "DataModelMesh", "Decal", "Texture", "SurfaceAppearance", "Model", "Folder", "Accoutrement" }

local function display(key: string, def: any): Model?
	local folder = SS:FindFirstChild("Monsters")
	local tpl = (folder and folder:FindFirstChild(def.template)) or SS:FindFirstChild("GhostTemplate")
	if not tpl or not tpl:IsA("Model") then return nil end
	local m = tpl:Clone()
	m.Name = "BestiaryBake"
	if def.evolved then Evolved.dress(m, def) end
	local hrp = m:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then m:Destroy(); return nil end
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = d == hrp
			d.CanCollide = false; d.CanTouch = false; d.CanQuery = false; d.Massless = d ~= hrp
		elseif d:IsA("Humanoid") then
			d.EvaluateStateMachine = false
		elseif d:IsA("LuaSourceContainer") then
			d:Destroy()
		end
	end
	-- posed in the world (far under the map) so everything welded to the body follows its joints, then frozen
	m:PivotTo(CFrame.new(0, -400, 0))
	m.Parent = workspace
	for _, d in m:GetDescendants() do
		if d:IsA("Motor6D") and POSE[d.Name] then d.C0 = d.C0 * POSE[d.Name] end
	end
	task.wait(0.15)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then d.Anchored = true end
	end
	for _, d in m:GetDescendants() do
		local keep = false
		for _, c in KEEP do if d:IsA(c) then keep = true; break end end
		if not keep then d:Destroy() end
	end
	hrp.Transparency = 1
	m.Name = key
	return m
end

function Bestiary.start(lobby: boolean)
	if not lobby then return end
	local folder = Instance.new("Folder")
	folder.Name = "BestiaryModels"
	folder.Parent = RS
	task.spawn(function()
		for _, e in Badges.entries do
			local def: any = e.evolved and Monsters.evolved(e.id, 1) or Monsters.byId[e.id]
			local ok, res = pcall(display, e.key, def)
			if ok and res then
				(res :: Model).Parent = folder
			elseif not ok then
				warn("[Bestiary] display model " .. e.key .. ": " .. tostring(res))
			end
		end
		folder:SetAttribute("Ready", true)
	end)
end

return Bestiary
