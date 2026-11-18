--!strict
-- What a worn FORM looks like on a character (Shared/Forms; player attributes FormStim / FormPotion), drawn by
-- every client for every player: a FIST form = small embers of its colour rising off both hands (a faint glow on
-- the fists from EPIC up); a BODY form = a thin mist of its colour drifting up off the chest. Kept tiny (a few
-- particles a second, nothing on "low" effects). Your own first-person view in a fight shows none of it (the
-- hands are the viewmodel's there).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Forms = require(RS.Shared.Forms)
local Settings = require(script.Parent.Settings)

local FL = {}
local lp = Players.LocalPlayer
local TAG = "FormFx"

local function clearOn(ch: Model)
	for _, d in ch:GetDescendants() do
		if d.Name == TAG then d:Destroy() end
	end
end

local function lowFx(): boolean
	local ok, v = pcall(function() return (Settings :: any).get and (Settings :: any).get("fx") end)
	return ok and v == "low"
end

local function emitter(parent: Instance, color: Color3, kind: string, rarity: number)
	local e = Instance.new("ParticleEmitter")
	e.Name = TAG
	e.Texture = kind == "stim" and "rbxasset://textures/particles/sparkles_main.dds" or "rbxasset://textures/particles/smoke_main.dds"
	e.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.3), color)
	e.LightEmission = kind == "stim" and 1 or 0.5
	e.LightInfluence = 0
	if kind == "stim" then
		e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.22), NumberSequenceKeypoint.new(1, 0) })
		e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
		e.Lifetime = NumberRange.new(0.5, 0.8)
		e.Speed = NumberRange.new(1.5, 3)
		e.Rate = 2 + rarity * 0.6
		e.SpreadAngle = Vector2.new(25, 25)
		e.Acceleration = Vector3.new(0, 3, 0)
	else
		e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1.6) })
		e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(0.4, 0.75), NumberSequenceKeypoint.new(1, 1) })
		e.Lifetime = NumberRange.new(1.4, 2)
		e.Speed = NumberRange.new(0.6, 1.2)
		e.Rate = 1.5 + rarity * 0.4
		e.SpreadAngle = Vector2.new(40, 40)
		e.Acceleration = Vector3.new(0, 1.2, 0)
		e.RotSpeed = NumberRange.new(-40, 40)
	end
	e.EmissionDirection = Enum.NormalId.Top
	e.Parent = parent
end

local function apply(p: Player)
	local ch = p.Character
	if not ch then return end
	clearOn(ch)
	-- (your own body in a fight: first person, nothing)
	if p == lp and lp:GetAttribute("InMatch") and not lp:GetAttribute("Spectating") then return end
	if lowFx() then return end
	local stim = Forms.byId[p:GetAttribute("FormStim") or ""]
	if stim then
		for _, n in { "RightHand", "LeftHand", "Right Arm", "Left Arm" } do
			local hand = ch:FindFirstChild(n)
			if hand and hand:IsA("BasePart") then
				emitter(hand, stim.color, "stim", stim.rarity)
				if stim.rarity >= 4 then
					local l = Instance.new("PointLight")
					l.Name = TAG; l.Color = stim.color; l.Range = 4 + stim.rarity; l.Brightness = 0.8; l.Shadows = false
					l.Parent = hand
				end
			end
		end
	end
	local pot = Forms.byId[p:GetAttribute("FormPotion") or ""]
	if pot then
		local torso = ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
		if torso and torso:IsA("BasePart") then emitter(torso, pot.color, "potion", pot.rarity) end
	end
end

local function watch(p: Player)
	for _, a in { "FormStim", "FormPotion" } do
		p:GetAttributeChangedSignal(a):Connect(function() apply(p) end)
	end
	p.CharacterAdded:Connect(function(ch)
		ch:WaitForChild("HumanoidRootPart", 5)
		task.wait(0.5)
		apply(p)
	end)
	if p.Character then task.spawn(apply, p) end
end

function FL.init()
	for _, p in Players:GetPlayers() do watch(p) end
	Players.PlayerAdded:Connect(watch)
	lp:GetAttributeChangedSignal("InMatch"):Connect(function() apply(lp) end)
	lp:GetAttributeChangedSignal("Spectating"):Connect(function() apply(lp) end)
end
FL.refresh = apply

return FL
