--!strict
-- Robux: the Game Passes (Shared/Passes: 2X MONEY, DOUBLE ULTIMATE, VIP, SECOND CHANCE, GLOCK 18; each has its id in
-- a ReplicatedStorage attribute), the REVIVE Developer Product (attribute ReviveProductId) and the cash packs
-- (Config.CashPacks, attributes CashPack1Id..), the TRAIN TICKETS refill (TripsProductId: all 5 tickets back).
-- 0 = not set up yet (the shop shows SOON). The only ProcessReceipt of
-- the game lives here.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Remotes = require(script.Parent.Remotes)
local Guard = require(script.Parent.Guard)
local Run = require(script.Parent.Run)
local Inventory = require(script.Parent.Inventory)
local Data = require(script.Parent.Data)
local Analytics = require(script.Parent.Analytics)
local Config = require(RS.Shared.Config)
local Passes = require(RS.Shared.Passes)

local Monetization = {}
local granted = {} :: { [string]: boolean } -- PurchaseId -> done (this server)

local function id(attr: string): number return tonumber(RS:GetAttribute(attr)) or 0 end

-- This game's Game Pass and Developer Product ids (creator dashboard). They are written to the ReplicatedStorage
-- attributes when this module loads (before any module starts); an attribute already set to another id wins.
-- 0 = not made yet (the shop shows SOON).
local IDS: { [string]: number } = {
	Money2PassId = 0,
	DoubleUltPassId = 2092401025,
	VipPassId = 2093960947,
	SecondChancePassId = 2094074958,
	GlockPassId = 2092275006,
	AdminPassId = 2092449017,
	ReviveProductId = 3732932320,
	CashPack1Id = 3732931910, -- 1000
	CashPack2Id = 3732931994, -- 2500
	CashPack3Id = 3732932046, -- 6000
	CashPack4Id = 3732932132, -- 15000
	TripsProductId = 0, -- TRAIN TICKETS: all 5 back at once (Developer Product; 0 until it is made in the Creator Hub)
}
for attr, default in IDS do
	if id(attr) <= 0 then RS:SetAttribute(attr, default) end
end

-- Game Passes (Shared/Passes): the owner gets the pass's player attribute. The Admin Panel pass is Server/Admin's.
local function checkPass(p: Player)
	for _, pass in Passes.list do
		local passId = id(pass.id)
		if passId > 0 and not pass.admin then
			local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(p.UserId, passId) end)
			if ok and owns and p.Parent then p:SetAttribute(pass.own, true) end
		end
	end
end

function Monetization.start()
	for _, pass in Passes.list do
		if RS:GetAttribute(pass.id) == nil then RS:SetAttribute(pass.id, 0) end
	end
	if RS:GetAttribute("ReviveProductId") == nil then RS:SetAttribute("ReviveProductId", 0) end
	if RS:GetAttribute("TripsProductId") == nil then RS:SetAttribute("TripsProductId", 0) end
	for _, pack in Config.CashPacks do
		if RS:GetAttribute(pack.attr) == nil then RS:SetAttribute(pack.attr, 0) end
	end
	Players.PlayerAdded:Connect(function(p) task.spawn(checkPass, p) end)
	for _, p in Players:GetPlayers() do task.spawn(checkPass, p) end
	-- bought in game: it works at once, no rejoin. The "bought" flag of this event comes from the player's own
	-- client, so it is only a hint: the pass is given once Roblox itself says the player owns it (its ownership
	-- cache is refreshed when this event fires; a few tries in case it lags).
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, passId, bought)
		if not bought then return end
		for _, pass in Passes.list do
			if not pass.admin and id(pass.id) > 0 and passId == id(pass.id) and not p:GetAttribute(pass.own) then
				for try = 1, 4 do
					local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(p.UserId, passId) end)
					if not p.Parent then return end
					if ok and owns then
						p:SetAttribute(pass.own, true)
						Analytics.custom(p, "PassBought", 1, pass.name)
						if pass.own == "GlockPass" and p:GetAttribute("InMatch") then Inventory.give(p, "Glock18") end
						Remotes.Fx:FireClient(p, "Toast", pass.toast, true)
						return
					end
					task.wait(2 * try)
				end
				warn("[Monetization] " .. p.Name .. " reported buying " .. pass.name .. " but Roblox does not list it (yet)")
				return
			end
		end
	end)
	MarketplaceService.ProcessReceipt = function(info)
		if granted[info.PurchaseId] then return Enum.ProductPurchaseDecision.PurchaseGranted end
		local p = Players:GetPlayerByUserId(info.PlayerId)
		if not p then return Enum.ProductPurchaseDecision.NotProcessedYet end
		-- cash packs: granted only once it is saved with the purchase id (never twice, even across servers)
		for _, pack in Config.CashPacks do
			if id(pack.attr) > 0 and info.ProductId == id(pack.attr) then
				local res = Data.grantCashReceipt(p, info.PurchaseId, pack.cash)
				if res == "wait" then return Enum.ProductPurchaseDecision.NotProcessedYet end
				granted[info.PurchaseId] = true
				if res == "saved" then Remotes.Fx:FireClient(p, "Toast", "+$" .. pack.cash .. " CASH - thanks for the support!") end
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		-- train tickets: all back, granted only once it is saved with the purchase id
		if id("TripsProductId") > 0 and info.ProductId == id("TripsProductId") then
			local res = Data.grantTripsReceipt(p, info.PurchaseId)
			if res == "wait" then return Enum.ProductPurchaseDecision.NotProcessedYet end
			granted[info.PurchaseId] = true
			if res == "saved" then Remotes.Fx:FireClient(p, "Toast", "TRAIN TICKETS REFILLED - ALL ABOARD!", true) end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		if info.ProductId == id("ReviveProductId") then
			granted[info.PurchaseId] = true
			Analytics.custom(p, "ReviveBought", 1)
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
	Remotes.Revive.OnServerEvent:Connect(function(p, what) if not Guard.ok(p, "Revive") then return end
		if what == "prompt" then Run.extendRevive(p, 30) -- more time while the purchase dialog is open
		elseif what == "lobby" then Run.giveUp(p)
		elseif what == "watch" then Run.watch(p) end
	end)
end

return Monetization
