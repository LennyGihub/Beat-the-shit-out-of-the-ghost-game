--!strict
-- YOU DIED + REVIVE: when you die in a run the server opens a revive window (Fx "ReviveOffer" window, team); this shows
-- the countdown and a REVIVE button that prompts the REVIVE Developer Product (ReplicatedStorage attribute
-- ReviveProductId). Team run (teammates still fighting): the second button is WATCH (spectate, back next wave);
-- last one standing: GO TO LOBBY. Without a product (and not admin) there is no REVIVE button, just the countdown.
-- An admin revives for free. ReviveUI.buy() is also the REVIVE button of the spectator bar (Client/Spectate).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local ReviveUI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local timer: TextLabel
local btn: TextButton
local price: number? = nil
local team = false
local lobbyBtn: TextButton

local function productId(): number return tonumber(RS:GetAttribute("ReviveProductId")) or 0 end

-- this player has a way to come back now: the REVIVE product is on sale, or they are an admin (free)
function ReviveUI.canRevive(): boolean
	return productId() > 0 or lp:GetAttribute("IsAdmin") == true
end
-- revive now: free for an admin, the Robux prompt for everyone else
function ReviveUI.buy()
	local id = productId()
	if lp:GetAttribute("IsAdmin") then
		task.spawn(function() RS.Remotes:WaitForChild("Admin"):InvokeServer("revive") end)
	elseif id > 0 then
		Remotes.Revive:FireServer("prompt") -- keeps the window open while paying
		MarketplaceService:PromptProductPurchase(lp, id)
	end
end
function ReviveUI.label(): string
	if lp:GetAttribute("IsAdmin") then return "REVIVE (ADMIN)" end
	return productId() > 0 and ("REVIVE  R$ " .. tostring(price or "?")) or "REVIVE - SOON"
end

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
	btn.Position = UDim2.fromScale(0.06, 0.56); btn.Size = UDim2.fromScale(0.5, 0.3); btn.ZIndex = 12; btn.Rotation = 1; btn.Modal = true
	btn.Parent = panel
	Platform.menu(panel, nil) -- a controller lands on REVIVE
	-- or give up: back to the lobby now (paid out like a normal death)
	local lobby = Instance.new("TextButton")
	lobby.AutoButtonColor = true; lobby.BorderSizePixel = 0; lobby.BackgroundColor3 = Color3.fromRGB(45, 40, 36)
	lobby.Font = Grunge.FONT; lobby.TextScaled = true; lobby.TextColor3 = Grunge.PAPER; lobby.TextStrokeTransparency = 0.3; lobby.Text = "GO TO LOBBY"
	lobby.Position = UDim2.fromScale(0.62, 0.6); lobby.Size = UDim2.fromScale(0.32, 0.22); lobby.ZIndex = 12; lobby.Rotation = -1
	lobby.Parent = panel
	local ls = Instance.new("UIStroke"); ls.Color = Grunge.INK; ls.Thickness = 4; ls.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; ls.Parent = lobby
	local lpd = Instance.new("UIPadding"); lpd.PaddingTop = UDim.new(0.16, 0); lpd.PaddingBottom = UDim.new(0.16, 0); lpd.Parent = lobby
	lobbyBtn = lobby
	lobby.Activated:Connect(function()
		Sfx.play("Click")
		gui.Enabled = false
		Remotes.Revive:FireServer(team and "watch" or "lobby")
	end)
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 4; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = btn
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.12, 0); pad.PaddingBottom = UDim.new(0.12, 0); pad.Parent = btn
	btn.Activated:Connect(function()
		Sfx.play("Click")
		ReviveUI.buy()
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
		if team then
			timer.Text = btn.Visible and ("REVIVE NOW (" .. left .. ") OR WATCH YOUR TEAM - BACK FREE NEXT WAVE") or "WATCH YOUR TEAM - BACK FREE NEXT WAVE"
		else
			timer.Text = btn.Visible and ("THE RUN ENDS IN " .. left .. " - COME BACK WHERE YOU FELL?") or ("THE RUN ENDS IN " .. left)
		end
	end)
end

function ReviveUI.handle(kind: string, ...)
	if kind == "ReviveOffer" then
		local _, isTeam = ...
		team = isTeam == true
		btn.Text = ReviveUI.label()
		btn.Visible = ReviveUI.canRevive()
		lobbyBtn.Text = team and "WATCH" or "GO TO LOBBY"
		lobbyBtn.Position = btn.Visible and UDim2.fromScale(0.62, 0.6) or UDim2.fromScale(0.3, 0.58)
		lobbyBtn.Size = btn.Visible and UDim2.fromScale(0.32, 0.22) or UDim2.fromScale(0.4, 0.26)
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
