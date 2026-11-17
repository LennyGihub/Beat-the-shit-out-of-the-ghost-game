--!strict
-- VIP Game Pass (player attribute VIP, set by Monetization): a gold "[VIP] name" over the owner's head in place of
-- Roblox's own name tag. The other perks live elsewhere: +20% run cash in Run (Config.Vip.CashBonus), the chat tag
-- in Client/Vip.
local Players = game:GetService("Players")

local Vip = {}
local GOLD = Color3.fromRGB(255, 205, 60)
local DEFAULT_NAME_DISTANCE = 100

local function dress(p: Player)
	local ch = p.Character
	if not ch then return end
	local head = ch:WaitForChild("Head", 5)
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not head or not hum or p.Character ~= ch then return end
	local old = head:FindFirstChild("VipName")
	if not p:GetAttribute("VIP") then
		if old then
			old:Destroy()
			hum.NameDisplayDistance = DEFAULT_NAME_DISTANCE
		end
		return
	end
	if old then return end
	hum.NameDisplayDistance = 0 -- Roblox's white name off (the health bar over the head stays)
	local bb = Instance.new("BillboardGui")
	bb.Name = "VipName"
	bb.Size = UDim2.new(9, 0, 1.25, 0)
	bb.StudsOffsetWorldSpace = Vector3.new(0, 2.4, 0)
	bb.MaxDistance = 90
	bb.LightInfluence = 0
	bb.PlayerToHideFrom = p -- not in your own face in first person
	bb.ResetOnSpawn = false
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.PermanentMarker
	t.TextScaled = true
	t.Text = "[VIP] " .. p.DisplayName
	t.TextColor3 = GOLD
	t.TextStrokeColor3 = Color3.fromRGB(40, 26, 4)
	t.TextStrokeTransparency = 0
	t.Parent = bb
	bb.Parent = head
end

function Vip.start()
	local function onPlayer(p: Player)
		p.CharacterAdded:Connect(function() task.spawn(dress, p) end)
		p:GetAttributeChangedSignal("VIP"):Connect(function() task.spawn(dress, p) end)
		task.spawn(dress, p)
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in Players:GetPlayers() do onPlayer(p) end
end

return Vip
