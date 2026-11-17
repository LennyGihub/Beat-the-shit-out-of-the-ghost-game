--!strict
-- Chat tags (every client tags the messages it shows): a red [DEV] in front of the staff's messages (player
-- attribute Dev, set by Server/Admin) and a gold [VIP] for VIP Game Pass owners (player attribute VIP, set by
-- Monetization). The same titles are on the lobby name tags (Client/NameTags).
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local Vip = {}

function Vip.init()
	TextChatService.OnIncomingMessage = function(message: TextChatMessage)
		local props = Instance.new("TextChatMessageProperties")
		local src = message.TextSource
		local from = src and Players:GetPlayerByUserId(src.UserId)
		if from and message.PrefixText ~= "" then
			local tags = ""
			if from:GetAttribute("Dev") == true then tags ..= "<font color='#E63C2D'>[DEV]</font> " end
			if from:GetAttribute("VIP") == true then tags ..= "<font color='#FFCD3C'>[VIP]</font> " end
			if tags ~= "" then props.PrefixText = tags .. message.PrefixText end
		end
		return props
	end
end

return Vip
