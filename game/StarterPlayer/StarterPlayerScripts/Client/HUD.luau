-- Fight HUD (grunge): health / stamina / brutality bottom right, ghost health top centre.
-- Plus small transient bits: combo counter, lift hint, banners, cash outside of fights.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(RS.Shared.Config)
local Grunge = require(script.Parent.Grunge)

local HUD = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local health, stamina, brut, ghostBar
local ghostRoot: Frame
local comboLabel: TextLabel
local comboWord: TextLabel
local hint: TextLabel
local objective: TextLabel
local cashLabel: TextLabel
local ultLabel: TextLabel
local banner: Frame
local bannerTitle: TextLabel
local bannerSub: TextLabel
local vignette: Frame
local crosshair: Frame

function HUD.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "GrungeHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- bottom-right player bars
	local br = Grunge.frame(gui, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -24), Size = UDim2.fromScale(0.36, 0.3) })
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 2.4; ar.Parent = br
	health = Grunge.bar(br, { size = UDim2.fromScale(1, 0.24), pos = UDim2.fromScale(0, 0.12), color = Color3.fromRGB(150, 18, 20), label = "HEALTH", rot = -1.2, seed = 11 })
	stamina = Grunge.bar(br, { size = UDim2.fromScale(0.86, 0.15), pos = UDim2.fromScale(0.14, 0.5), color = Color3.fromRGB(196, 176, 64), label = "STAMINA", rot = 0.8, seed = 23, slices = 26 })
	brut = Grunge.bar(br, { size = UDim2.fromScale(0.94, 0.19), pos = UDim2.fromScale(0.06, 0.78), color = Color3.fromRGB(230, 96, 20), label = "BRUTALITY", rot = -0.6, seed = 37 })
	ultLabel = Grunge.text(br, {
		Text = "PRESS Q", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(0, -6, 0.86, 0), Size = UDim2.fromScale(0.34, 0.2),
		TextColor3 = Color3.fromRGB(255, 120, 40), Rotation = -6, Visible = false, ZIndex = 8,
	})

	-- top-centre ghost health
	ghostRoot = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 26), Size = UDim2.fromScale(0.44, 0.09), Visible = false })
	local gar = Instance.new("UIAspectRatioConstraint"); gar.AspectRatio = 9; gar.Parent = ghostRoot
	Grunge.text(ghostRoot, { Text = "THE WOMAN IN THE HOUSE", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.8, 0.42), TextColor3 = Color3.fromRGB(200, 225, 228), ZIndex = 7 })
	ghostBar = Grunge.bar(ghostRoot, { size = UDim2.fromScale(1, 0.42), pos = UDim2.fromScale(0, 0.5), color = Color3.fromRGB(150, 205, 210), rot = 0.4, seed = 51, slices = 40 })

	-- crosshair + transient labels
	crosshair = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BackgroundTransparency = 0.25, BackgroundColor3 = Grunge.PAPER })
	local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = crosshair
	comboLabel = Grunge.text(gui, { Text = "", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.56, 0, 0.42, 0), Size = UDim2.fromScale(0.12, 0.1), TextColor3 = Color3.fromRGB(230, 40, 30), Rotation = -8, Visible = false })
	comboWord = Grunge.text(gui, { Text = "", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.565, 0, 0.5, 0), Size = UDim2.fromScale(0.16, 0.06), TextColor3 = Grunge.PAPER, Rotation = -4, Visible = false })
	hint = Grunge.text(gui, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.53, 0), Size = UDim2.fromScale(0.2, 0.035), Visible = false })
	objective = Grunge.text(gui, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 24, 0, 24), Size = UDim2.fromScale(0.3, 0.04), TextXAlignment = Enum.TextXAlignment.Left, Visible = false })
	cashLabel = Grunge.text(gui, { Text = "$0", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24, 0, 20), Size = UDim2.fromScale(0.14, 0.06), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 220, 110), Rotation = 2, Visible = false })

	-- banner (intro / victory / shop)
	banner = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.33), Size = UDim2.fromScale(0.6, 0.2), Visible = false, ZIndex = 20 })
	Grunge.splat(banner, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1.1, 1.8), ImageColor3 = Color3.fromRGB(110, 8, 8), ImageTransparency = 0.3, ZIndex = 20 })
	bannerTitle = Grunge.text(banner, { Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(1, 0.62), TextColor3 = Grunge.PAPER, ZIndex = 21 })
	bannerSub = Grunge.text(banner, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.64), Size = UDim2.fromScale(0.8, 0.32), TextColor3 = Color3.fromRGB(150, 220, 110), Rotation = -2, ZIndex = 21 })

	-- red vignette (damage / ultimate)
	vignette = Grunge.frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(160, 0, 0), BackgroundTransparency = 1, ZIndex = 0 })

	RunService.RenderStepped:Connect(HUD.update)
end

local comboShownAt = 0
local WORDS = { [4] = "BRUTAL!", [7] = "SAVAGE!", [10] = "MERCILESS!", [14] = "INHUMAN!", [20] = "EXORCISED!!" }
function HUD.combo(n: number, ult: boolean)
	if n < 2 then return end
	comboShownAt = os.clock()
	comboLabel.Text = "x" .. n
	comboLabel.Visible = true
	comboLabel.TextColor3 = ult and Color3.fromRGB(255, 140, 40) or Color3.fromRGB(230, 40 + math.max(0, 60 - n * 4), 30)
	comboLabel.Rotation = math.random(-14, -2)
	local s = Instance.new("UIScale"); s.Scale = 1.8 + math.min(n, 12) * 0.08; s.Parent = comboLabel
	TweenService:Create(s, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	task.delay(0.2, function() s:Destroy() end)
	local best
	for k, w in WORDS do if n >= k and (not best or k > best) then best = k end end
	if best and WORDS[best] and n == best then
		comboWord.Text = WORDS[best]
		comboWord.Visible = true
	end
end

function HUD.hint(text: string?)
	hint.Visible = text ~= nil and text ~= ""
	hint.Text = text or ""
end

function HUD.flash(color: Color3, amount: number)
	vignette.BackgroundColor3 = color
	vignette.BackgroundTransparency = 1 - amount
	TweenService:Create(vignette, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
end

function HUD.banner(title: string, sub: string?, dur: number?)
	bannerTitle.Text = title
	bannerSub.Text = sub or ""
	banner.Visible = true
	local s = banner:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = banner
	s.Scale = 1.6
	TweenService:Create(s, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	local token = os.clock()
	banner:SetAttribute("Token", token)
	task.delay(dur or 3.5, function()
		if banner:GetAttribute("Token") == token then banner.Visible = false end
	end)
end

function HUD.setVisible(on: boolean) gui.Enabled = on end

function HUD.update(dt: number)
	local ch = lp.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if hum then health:set(hum.Health / math.max(1, hum.MaxHealth), dt) end
	stamina:set((lp:GetAttribute("Stamina") or 100) / Config.Stamina.Max, dt)
	local b = (lp:GetAttribute("Brutality") or 0) / Config.Brutality.Max
	brut:set(b, dt)
	local ultOn = lp:GetAttribute("UltActive") == true
	local full = b >= 0.999 and not ultOn
	local t = os.clock()
	if ultOn then
		brut:color(Color3.fromRGB(255, 40 + math.floor(math.abs(math.sin(t * 9)) * 80), 20))
		if vignette.BackgroundTransparency > 0.86 then
			vignette.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
			vignette.BackgroundTransparency = 0.86
		end
	elseif full then
		brut:color(Color3.fromRGB(255, 120 + math.floor(math.abs(math.sin(t * 6)) * 100), 30))
	else
		brut:color(Color3.fromRGB(230, 96, 20))
	end
	ultLabel.Visible = full
	if full then ultLabel.Rotation = -6 + math.sin(t * 10) * 3 end

	local g = workspace:FindFirstChild("Ghost")
	local roundState = RS:GetAttribute("RoundState")
	if g and g:GetAttribute("MaxHP") and g:GetAttribute("State") ~= "Dead" then
		ghostRoot.Visible = true
		ghostBar:set((g:GetAttribute("HP") or 0) / g:GetAttribute("MaxHP"), dt)
	elseif g and g:GetAttribute("State") == "Dead" then
		ghostBar:set(0, dt)
	else
		ghostRoot.Visible = false
	end
	if comboLabel.Visible and t - comboShownAt > 1.6 then comboLabel.Visible = false; comboWord.Visible = false end
	local obj = RS:GetAttribute("Objective") or ""
	objective.Text = obj
	objective.Visible = obj ~= ""
	local showCash = roundState ~= "Fight" and roundState ~= "Intro"
	cashLabel.Visible = showCash
	cashLabel.Text = "$" .. tostring(lp:GetAttribute("Cash") or 0)
end

return HUD
