--!strict
-- YOU DIED + REVIVE: when you die in a run the server opens a revive window (Fx "ReviveOffer"); this shows the
-- countdown and a REVIVE button that prompts the REVIVE Developer Product (ReplicatedStorage attribute ReviveProductId).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local ReviveUI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local timer: TextLabel
local btn: TextButton
local price: number? = nil

local function productId(): number return tonumber(RS:GetAttribute("ReviveProductId")) or 0 end

function ReviveUI.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "ReviveUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 40; gui.Enabled = false
	gui.Parent = lp:WaitForChild("PlayerGui")
	local dim = Grunge.frame(gui, { BackgroundTransparency = 0.45, BackgroundColor3 = Color3.fromRGB(40, 0, 0), Size = UDim2.fromScale(1, 1) })
	dim.ZIndex = 1
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.55), Size = UDim2.fromScale(0.4, 0.36), Rotation = -1.5 }, 61)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 2.2; ar.Parent = panel
	Grunge.text(panel, { Text = "YOU DIED", Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.04), Size = UDim2.fromScale(0.9, 0.3), TextColor3 = Color3.fromRGB(220, 40, 30), ZIndex = 10 })
	timer = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.36), Size = UDim2.fromScale(0.9, 0.13), ZIndex = 10 })
	btn = Instance.new("TextButton")
	btn.AutoButtonColor = true; btn.BorderSizePixel = 0; btn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
	btn.Font = Grunge.FONT; btn.TextScaled = true; btn.TextColor3 = Grunge.PAPER; btn.TextStrokeTransparency = 0.3; btn.Text = "REVIVE"
	btn.Position = UDim2.fromScale(0.2, 0.56); btn.Size = UDim2.fromScale(0.6, 0.3); btn.ZIndex = 12; btn.Rotation = 1; btn.Modal = true
	btn.Parent = panel
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 4; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = btn
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.12, 0); pad.PaddingBottom = UDim.new(0.12, 0); pad.Parent = btn
	btn.Activated:Connect(function()
		Sfx.play("Click")
		local id = productId()
		if id > 0 then
			Remotes.Revive:FireServer("prompt") -- keeps the window open while paying
			MarketplaceService:PromptProductPurchase(lp, id)
		elseif lp:GetAttribute("IsAdmin") then
			RS.Remotes:WaitForChild("Admin"):InvokeServer("revive")
		end
	end)
	task.spawn(function()
		local id = productId()
		if id > 0 then
			local ok, info = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product) end)
			if ok and info and info.PriceInRobux then price = info.PriceInRobux end
		end
	end)
	-- live countdown from the server's deadline
	game:GetService("RunService").RenderStepped:Connect(function()
		if not gui.Enabled then return end
		local untilT = lp:GetAttribute("ReviveUntil")
		if type(untilT) ~= "number" then gui.Enabled = false; return end
		local left = math.max(0, math.ceil(untilT - workspace:GetServerTimeNow()))
		timer.Text = "THE RUN ENDS IN " .. left .. " - COME BACK WHERE YOU FELL?"
	end)
end

function ReviveUI.handle(kind: string, ...)
	if kind == "ReviveOffer" then
		local id = productId()
		btn.Text = id > 0 and ("REVIVE  R$ " .. tostring(price or "?")) or (lp:GetAttribute("IsAdmin") and "REVIVE (ADMIN)" or "REVIVE - SOON")
		gui.Enabled = true
		local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		s.Parent = panel; s.Scale = 0.6
		TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	elseif kind == "Revived" then
		gui.Enabled = false
		Sfx.play("Ultimate", { PlaybackSpeed = 1.3, Volume = 0.7 })
	end
end

return ReviveUI
