--!strict
-- VIP Game Pass on the client (the server sets the player attribute VIP): a gold [VIP] tag in front of an owner's
-- chat messages (every client tags them). (The VIP cabin in the park is gone: tools/build/lobby_night.luau.)
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local Vip = {}

function Vip.init()
	TextChatService.OnIncomingMessage = function(message: TextChatMessage)
		local props = Instance.new("TextChatMessageProperties")
		local src = message.TextSource
		local from = src and Players:GetPlayerByUserId(src.UserId)
		if from and from:GetAttribute("VIP") == true and message.PrefixText ~= "" then
			props.PrefixText = "<font color='#FFCD3C'>[VIP]</font> " .. message.PrefixText
		end
		return props
	end
end

return Vip
