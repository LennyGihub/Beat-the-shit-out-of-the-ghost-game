--!strict
-- Robux: the 2X MONEY Game Pass (ReplicatedStorage attribute Money2PassId) and the REVIVE Developer Product
-- (attribute ReviveProductId). 0 = not set up yet (the shop shows SOON). The only ProcessReceipt of the game lives here.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Remotes = require(script.Parent.Remotes)
local Run = require(script.Parent.Run)
local Inventory = require(script.Parent.Inventory)

local Monetization = {}
local granted = {} :: { [string]: boolean } -- PurchaseId -> done (this server)

local function id(attr: string): number return tonumber(RS:GetAttribute(attr)) or 0 end

-- Game Passes: id attribute -> player attribute it unlocks
local PASSES = { Money2PassId = "Money2", GlockPassId = "GlockPass" }
local function checkPass(p: Player)
	for attr, flag in PASSES do
		local pass = id(attr)
		if pass > 0 then
			local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(p.UserId, pass) end)
			if ok and owns then p:SetAttribute(flag, true) end
		end
	end
end

function Monetization.start()
	for _, a in { "Money2PassId", "ReviveProductId", "GlockPassId" } do
		if RS:GetAttribute(a) == nil then RS:SetAttribute(a, 0) end
	end
	Players.PlayerAdded:Connect(function(p) task.spawn(checkPass, p) end)
	for _, p in Players:GetPlayers() do task.spawn(checkPass, p) end
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, pass, bought)
		if bought and pass == id("Money2PassId") then
			p:SetAttribute("Money2", true)
			Remotes.Fx:FireClient(p, "Toast", "2X MONEY UNLOCKED - every run pays double")
		elseif bought and pass == id("GlockPassId") then
			p:SetAttribute("GlockPass", true)
			if p:GetAttribute("InMatch") then Inventory.give(p, "Glock18") end
			Remotes.Fx:FireClient(p, "Toast", "GLOCK 18 UNLOCKED - it is in your hotbar every run")
		end
	end)
	MarketplaceService.ProcessReceipt = function(info)
		if granted[info.PurchaseId] then return Enum.ProductPurchaseDecision.PurchaseGranted end
		local p = Players:GetPlayerByUserId(info.PlayerId)
		if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end
		if info.ProductId == id("ReviveProductId") then
			granted[info.PurchaseId] = true
			if not Run.revive(p) then
				-- the death window closed while paying: keep it for the next death
				p:SetAttribute("SpareRevives", (p:GetAttribute("SpareRevives") or 0) + 1)
				Remotes.Fx:FireClient(p, "Toast", "REVIVE SAVED - it is used automatically next time you die")
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- the client opened the purchase prompt: give them time to pay before the run ends
	Remotes.Revive.OnServerEvent:Connect(function(p, what)
		if what == "prompt" then Run.extendRevive(p, 30) end
	end)
end

return Monetization
