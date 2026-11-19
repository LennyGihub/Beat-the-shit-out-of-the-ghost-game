--!strict
-- TRAIN TICKETS for Robux: the Developer Product that gives all 5 tickets back (ReplicatedStorage attribute
-- TripsProductId, Server/Monetization grants it). The refill buttons (Client/LobbyUI's no-ticket message,
-- Client/StageUI, Client/LevelUI's corner) show TicketShop.label() and call TicketShop.buy(). Id 0 = not made yet:
-- the buttons say SOON and nothing is prompted.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local TS = {}
local lp = Players.LocalPlayer
local price: number? = nil
local fetching = false

local function pid(): number return tonumber(RS:GetAttribute("TripsProductId")) or 0 end

function TS.ready(): boolean return pid() > 0 end

-- "REFILL 5 TICKETS  R$ 49" (the live price, fetched once), or SOON while the product isn't made
function TS.label(short: boolean?): string
	local id = pid()
	if id <= 0 then return short and "REFILL: SOON" or "REFILL TICKETS - SOON" end
	if not price and not fetching then
		fetching = true
		task.spawn(function()
			local ok, info = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product) end)
			if ok and info and info.PriceInRobux then price = info.PriceInRobux end
			fetching = false
		end)
	end
	return (short and "REFILL  R$ " or "REFILL 5 TICKETS  R$ ") .. tostring(price or "?")
end

-- the purchase prompt (false: the product isn't made yet)
function TS.buy(): boolean
	local id = pid()
	if id <= 0 then return false end
	MarketplaceService:PromptProductPurchase(lp, id)
	return true
end

return TS
