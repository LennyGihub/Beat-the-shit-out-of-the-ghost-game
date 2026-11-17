--!strict
-- VIP Game Pass on the client (the server sets the player attribute VIP):
--   * a gold [VIP] tag in front of an owner's chat messages (every client tags them);
--   * the VIP cabin in the park: its door (CollectionService tag "VipDoor") lets owners walk through, and shows
--     everyone else a prompt that opens the pass purchase. There is nothing to steal in there, so the door is only
--     held shut on each player's own screen.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local HUD = require(script.Parent.HUD)

local Vip = {}
local lp = Players.LocalPlayer
local TAG = "VipDoor"
local wired = {} :: { [Instance]: boolean }

local function isVip(): boolean return lp:GetAttribute("VIP") == true end

local function door(d: Instance)
	if not d:IsA("BasePart") then return end
	local vip = isVip()
	d.CanCollide = not vip
	d.LocalTransparencyModifier = vip and 0.8 or 0 -- owners see it standing open
	local pp = d:FindFirstChildOfClass("ProximityPrompt")
	if pp then
		pp.Enabled = not vip
		if not wired[pp] then
			wired[pp] = true
			pp.Triggered:Connect(function()
				if isVip() then return end
				local id = tonumber(RS:GetAttribute("VipPassId")) or 0
				if id > 0 then
					MarketplaceService:PromptGamePassPurchase(lp, id)
				else
					HUD.toast("VIP is not on sale yet")
				end
			end)
			pp.Destroying:Connect(function() wired[pp] = nil end)
		end
	end
end

local function doors()
	for _, d in CollectionService:GetTagged(TAG) do door(d) end
end

function Vip.init()
	-- chat tag
	TextChatService.OnIncomingMessage = function(message: TextChatMessage)
		local props = Instance.new("TextChatMessageProperties")
		local src = message.TextSource
		local from = src and Players:GetPlayerByUserId(src.UserId)
		if from and from:GetAttribute("VIP") == true and message.PrefixText ~= "" then
			props.PrefixText = "<font color='#FFCD3C'>[VIP]</font> " .. message.PrefixText
		end
		return props
	end
	-- the cabin door (it can reach this client late, or again, with streaming)
	CollectionService:GetInstanceAddedSignal(TAG):Connect(function(d)
		door(d)
		d.ChildAdded:Connect(function() door(d) end)
	end)
	for _, d in CollectionService:GetTagged(TAG) do
		d.ChildAdded:Connect(function() door(d) end)
	end
	doors()
	lp:GetAttributeChangedSignal("VIP"):Connect(doors)
end

return Vip
