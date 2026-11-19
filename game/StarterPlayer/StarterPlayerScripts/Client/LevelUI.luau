--!strict
-- YOUR LEVEL, in the lobby's top right corner under your cash: LV n and its title (Shared/Levels, in the title's
-- colour), and a bar of the XP into the next level. Other players see it over your head (Client/NameTags). Hidden
-- in a run and while a lobby window is open. Player attributes (Server/Data): XP, Level.
-- Under it: the TRAIN TICKETS left (Campaign.TRIPS; TripsLeft / TripsReset) and when they come back.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Levels = require(RS.Shared.Levels)
local Campaign = require(RS.Shared.Campaign)
local TicketShop = require(script.Parent.TicketShop)

local LevelUI = {}
local lp = Players.LocalPlayer

function LevelUI.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "LevelUI"; gui.ResetOnSpawn = false; gui.DisplayOrder = 3
	gui.Parent = lp:WaitForChild("PlayerGui")
	local box = Grunge.frame(gui, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -22, 0.06, 26), Size = UDim2.fromScale(0.2, 0.07), Visible = false, ZIndex = 2 })
	local min = Instance.new("UISizeConstraint"); min.MinSize = Vector2.new(190, 46); min.Parent = box
	local lv = Grunge.text(box, { Text = "LV 1", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.fromScale(0.3, 0.56),
		TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Grunge.PAPER, Rotation = 1, ZIndex = 4 })
	local ttl = Grunge.text(box, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.7, 0.08), Size = UDim2.fromScale(0.7, 0.44),
		TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4 })
	local track = Grunge.brush(box, { Position = UDim2.fromScale(0.02, 0.6), Size = UDim2.fromScale(0.98, 0.2), ZIndex = 3 }, Color3.fromRGB(58, 50, 44), 51, 22, false)
	local fill = Grunge.brush(track, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.006, 0.5), Size = UDim2.fromScale(0.01, 0.7), ZIndex = 5 },
		Color3.fromRGB(110, 200, 90), 53, 22, false)
	local xpText = Grunge.text(box, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0.8), Size = UDim2.fromScale(0.6, 0.22),
		TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 4 })

	local tickets = Grunge.text(box, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 1.06), Size = UDim2.fromScale(1.3, 0.3),
		TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4 })
	local refill = Instance.new("TextButton")
	refill.AutoButtonColor = false; refill.BackgroundTransparency = 1; refill.Text = ""; refill.AnchorPoint = Vector2.new(1, 0)
	refill.Position = UDim2.fromScale(1, 1.4); refill.Size = UDim2.fromScale(0.7, 0.5); refill.ZIndex = 4; refill.Visible = false; refill.Parent = box
	Grunge.brush(refill, { Size = UDim2.fromScale(1, 1), ZIndex = 4 }, Color3.fromRGB(190, 40, 120), 57, 10, false)
	local refillT = Grunge.text(refill, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.92, 0.7), ZIndex = 6 })
	refill.Activated:Connect(function() TicketShop.buy() end)
	task.spawn(function()
		while true do
			local now = workspace:GetServerTimeNow()
			local left = Campaign.ticketsLeft(lp:GetAttribute("TripsLeft"), lp:GetAttribute("TripsReset"), now)
			local reset = tonumber(lp:GetAttribute("TripsReset")) or 0
			local max = Campaign.TRIPS.max
			tickets.Text = "TRAIN TICKETS " .. left .. " / " .. max .. ((left < max and reset > now) and ("  -  REFILL IN " .. Campaign.clock(reset - now)) or "")
			tickets.TextColor3 = left > 0 and Color3.fromRGB(150, 200, 255) or Color3.fromRGB(255, 110, 80)
			-- (the refill button while a ticket is used, once the product exists)
			refill.Visible = left < max and TicketShop.ready() and Campaign.TRIPS.enabled
			tickets.Visible = Campaign.TRIPS.enabled
			if refill.Visible then refillT.Text = TicketShop.label(true) end
			task.wait(1)
		end
	end)
	local shown = -1
	local function update()
		local xp = lp:GetAttribute("XP")
		box.Visible = type(xp) == "number" and not lp:GetAttribute("InMatch") and not Platform.windowOpen()
		if type(xp) ~= "number" then return end
		local level, into, need = Levels.of(xp)
		local name, color = Levels.title(level)
		lv.Text = "LV " .. level
		ttl.Text = name
		ttl.TextColor3 = color
		xpText.Text = into .. " / " .. need .. " XP"
		local f = math.clamp(into / need, 0.01, 1)
		if f ~= shown then
			TweenService:Create(fill, TweenInfo.new(shown < 0 and 0 or 0.4), { Size = UDim2.fromScale(f * 0.988, 0.7) }):Play()
			shown = f
		end
	end
	for _, a in { "XP", "InMatch" } do lp:GetAttributeChangedSignal(a):Connect(update) end
	Platform.windowChanged:Connect(update)
	update()
end

return LevelUI
