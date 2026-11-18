-- Fight HUD (grunge): health / stamina / brutality bottom right, ghost health top centre.
-- Plus small transient bits: combo counter, lift hint, banners, cash outside of fights.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Config = require(RS.Shared.Config)
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Ultimates = require(RS.Shared.Ultimates)

local HUD = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local health, stamina, brut, ghostBar
local ghostRoot: Frame
local ghostTitle: TextLabel
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
local barsRoot: Frame
local ultName: TextLabel
local marker: Frame
local markerText: TextLabel
local arrow: Frame
local toast: TextLabel
local objSplat: ImageLabel

function HUD.init()
	-- the game draws its own health bar: Roblox's default one (top right) would cover the run cash
	pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false) end)
	gui = Instance.new("ScreenGui")
	gui.Name = "GrungeHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- bottom-right player bars
	local br = Grunge.frame(gui, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -24, 1, -24), Size = UDim2.fromScale(0.36, 0.3) })
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 2.4; ar.Parent = br
	barsRoot = br
	health = Grunge.bar(br, { size = UDim2.fromScale(1, 0.24), pos = UDim2.fromScale(0, 0.12), color = Color3.fromRGB(150, 18, 20), label = "HEALTH", rot = -1.2, seed = 11 })
	stamina = Grunge.bar(br, { size = UDim2.fromScale(0.86, 0.15), pos = UDim2.fromScale(0.14, 0.5), color = Color3.fromRGB(196, 176, 64), label = "STAMINA", rot = 0.8, seed = 23, slices = 26 })
	brut = Grunge.bar(br, { size = UDim2.fromScale(0.94, 0.19), pos = UDim2.fromScale(0.06, 0.78), color = Color3.fromRGB(230, 96, 20), label = "BRUTALITY", rot = -0.6, seed = 37 })
	ultLabel = Grunge.text(br, {
		Text = "PRESS Q", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(0, -6, 0.86, 0), Size = UDim2.fromScale(0.34, 0.2),
		TextColor3 = Color3.fromRGB(255, 120, 40), Rotation = -6, Visible = false, ZIndex = 8,
	})

	-- phones: the bars go top-left, out of the way of the thumb buttons (TouchControls)
	local function layoutBars()
		if Platform.mode() == "touch" then
			br.AnchorPoint = Vector2.new(0, 0); br.Position = UDim2.new(0, 16, 0.2, 0); br.Size = UDim2.fromScale(0.28, 0.24)
		else
			br.AnchorPoint = Vector2.new(1, 1); br.Position = UDim2.new(1, -24, 1, -24); br.Size = UDim2.fromScale(0.36, 0.3)
		end
	end
	layoutBars()
	Platform.changed:Connect(layoutBars)

	ultName = Grunge.text(br, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -4, 1.0, 0), Size = UDim2.fromScale(0.9, 0.11), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(255, 150, 80), ZIndex = 8 })

	-- top-centre ghost health
	ghostRoot = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 26), Size = UDim2.fromScale(0.44, 0.09), Visible = false })
	local gar = Instance.new("UIAspectRatioConstraint"); gar.AspectRatio = 9; gar.Parent = ghostRoot
	ghostTitle = Grunge.text(ghostRoot, { Text = "THE WOMAN IN THE HOUSE", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromScale(0.8, 0.42), TextColor3 = Color3.fromRGB(200, 225, 228), ZIndex = 7 })
	ghostBar = Grunge.bar(ghostRoot, { size = UDim2.fromScale(1, 0.42), pos = UDim2.fromScale(0, 0.5), color = Color3.fromRGB(150, 205, 210), rot = 0.4, seed = 51, slices = 40 })

	-- crosshair + transient labels
	crosshair = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BackgroundTransparency = 0.25, BackgroundColor3 = Grunge.PAPER })
	local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = crosshair
	comboLabel = Grunge.text(gui, { Text = "", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.56, 0, 0.42, 0), Size = UDim2.fromScale(0.12, 0.1), TextColor3 = Color3.fromRGB(230, 40, 30), Rotation = -8, Visible = false })
	comboWord = Grunge.text(gui, { Text = "", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.565, 0, 0.5, 0), Size = UDim2.fromScale(0.16, 0.06), TextColor3 = Grunge.PAPER, Rotation = -4, Visible = false })
	hint = Grunge.text(gui, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.53, 0), Size = UDim2.fromScale(0.2, 0.035), Visible = false })
	-- objective: big hand-drawn line under the Roblox top bar (centre), with a splatter behind it
	objSplat = Grunge.splat(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 118), Size = UDim2.fromScale(0.46, 0.16), ImageColor3 = Color3.fromRGB(100, 8, 8), ImageTransparency = 0.35, Visible = false })
	objective = Grunge.text(gui, { Text = "", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 118), Size = UDim2.fromScale(0.5, 0.075), TextColor3 = Grunge.PAPER, Rotation = -1.5, Visible = false, ZIndex = 3 })
	-- waypoint marker (on-screen label) and edge arrow (off-screen)
	marker = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(170, 64), Visible = false })
	markerText = Grunge.text(marker, { Text = "", Size = UDim2.fromScale(1, 0.55), TextColor3 = Color3.fromRGB(255, 210, 120) })
	for _, rot in { 35, -35 } do
		Grunge.frame(marker, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 210, 120), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, rot > 0 and -7 or 7, 0.8, 0), Size = UDim2.fromOffset(20, 5), Rotation = rot })
	end
	arrow = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(110, 110), Visible = false })
	for _, rot in { 40, -40 } do
		Grunge.frame(arrow, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 210, 120), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 8, 0.5, rot > 0 and -17 or 17), Size = UDim2.fromOffset(62, 14), Rotation = rot })
		Grunge.frame(arrow, { BackgroundTransparency = 0, BackgroundColor3 = Grunge.INK, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 10, 0.5, rot > 0 and -15 or 15), Size = UDim2.fromOffset(66, 18), Rotation = rot, ZIndex = 0 })
	end
	toast = Grunge.text(gui, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.86, 0), Size = UDim2.fromScale(0.5, 0.045), Visible = false, ZIndex = 30 })
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

function HUD.toast(text: string, good: boolean?)
	toast.Text = string.upper(text)
	toast.TextColor3 = good == false and Color3.fromRGB(240, 80, 60) or (good and Color3.fromRGB(150, 220, 110) or Grunge.PAPER)
	toast.Visible = true
	local token = os.clock()
	toast:SetAttribute("T", token)
	task.delay(2.6, function() if toast:GetAttribute("T") == token then toast.Visible = false end end)
end

local cam = workspace.CurrentCamera
local function updateWaypoint()
	local wp = RS:GetAttribute("Waypoint")
	if typeof(wp) ~= "Vector3" or not lp:GetAttribute("InMatch") then
		marker.Visible = false; arrow.Visible = false
		return
	end
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local dist = hrp and math.floor((hrp.Position - wp).Magnitude) or 0
	local sp, onScreen = cam:WorldToViewportPoint(wp)
	local vs = cam.ViewportSize
	if onScreen and sp.Z > 0 then
		marker.Visible = true; arrow.Visible = false
		marker.Position = UDim2.fromOffset(sp.X, sp.Y)
		markerText.Text = (RS:GetAttribute("WaypointLabel") or "") .. "  " .. dist .. "m"
	else
		marker.Visible = false; arrow.Visible = true
		local dir = Vector2.new(sp.X - vs.X / 2, sp.Y - vs.Y / 2)
		if sp.Z < 0 then dir = -dir end
		if dir.Magnitude < 1 then dir = Vector2.new(0, 1) end
		dir = dir.Unit
		local edge = Vector2.new(vs.X / 2, vs.Y / 2) + dir * math.min(vs.X, vs.Y) * 0.4
		arrow.Position = UDim2.fromOffset(edge.X, edge.Y)
		arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X))
	end
end

function HUD.update(dt: number)
	local inMatch = lp:GetAttribute("InMatch") == true
	local ch = lp.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if hum then health:set(hum.Health / math.max(1, hum.MaxHealth), dt) end
	stamina:set((lp:GetAttribute("Stamina") or 100) / math.max(1, lp:GetAttribute("StaminaMax") or Config.Stamina.Max), dt) -- (a body form raises the max)
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
	ultLabel.Visible = full and Platform.mode() ~= "touch" -- phones: the ULT button lights up instead
	if full then ultLabel.Text = "PRESS " .. string.sub(Platform.label("Ultimate"), 2, -2) end
	if full then ultLabel.Rotation = -6 + math.sin(t * 10) * 3 end

	local g = workspace:FindFirstChild("Ghost")
	local roundState = RS:GetAttribute("RoundState")
	if not inMatch then
		ghostRoot.Visible = false
	elseif g and g:GetAttribute("MaxHP") and g:GetAttribute("State") ~= "Dead" then
		ghostRoot.Visible = true
		ghostBar:set((g:GetAttribute("HP") or 0) / g:GetAttribute("MaxHP"), dt)
		-- monster name, tinted by rarity (rare blue, legendary gold, secret purple)
		local rar = g:GetAttribute("Rarity") or 0
		local mad = g:GetAttribute("Enraged") == true
		ghostTitle.Text = (g:GetAttribute("Evolved") and "EVOLVED: " or "") .. (g:GetAttribute("MonsterName") or "THE WOMAN IN THE HOUSE") .. (mad and " - ENRAGED" or "") .. (g:GetAttribute("Bleeding") and " - BLEEDING" or "")
		ghostTitle.TextColor3 = mad and Color3.fromRGB(255, 70, 40) or rar == 4 and Color3.fromRGB(200, 130, 255) or rar == 3 and Color3.fromRGB(255, 190, 70) or (rar == 2 and Color3.fromRGB(120, 175, 255) or Color3.fromRGB(200, 225, 228))
	elseif g and g:GetAttribute("State") == "Dead" then
		ghostBar:set(0, dt)
	else
		ghostRoot.Visible = false
	end
	if comboLabel.Visible and t - comboShownAt > 1.6 then comboLabel.Visible = false; comboWord.Visible = false end
	local obj = inMatch and (RS:GetAttribute("Objective") or "") or ""
	if not inMatch then
		local q = lp:GetAttribute("QueueRoom")
		obj = q and "WAITING FOR PLAYERS..." or (lp:GetAttribute("PartyId") and "IN A LOBBY - THE HOST PRESSES START" or "PRESS PLAY OR STEP ON A ROOM PAD")
		if Platform.windowOpen() then obj = "" end -- a window is open: no line of text behind (or sticking out above) it
	end
	objective.Text = obj
	objective.Visible = obj ~= ""
	objSplat.Visible = objective.Visible
	if obj == "GO OUTSIDE" then
		objective.TextColor3 = Color3.fromRGB(255, 200 + math.floor(math.sin(t * 6) * 40), 90)
		objective.Rotation = -1.5 + math.sin(t * 4) * 1.5
	else
		objective.TextColor3 = Grunge.PAPER
	end
	barsRoot.Visible = inMatch
	crosshair.Visible = inMatch
	-- the sandbox fires the ultimate on trial, not the equipped one
	local trial = lp:GetAttribute("Sandbox") and lp:GetAttribute("TrialUlt")
	local u = Ultimates.byId[type(trial) == "string" and trial or lp:GetAttribute("EquippedUlt") or "Rage"]
	local line = u and (((trial and not lp:GetAttribute("Tutorial")) and "TRYING: " or "ULT: ") .. string.upper(u.name)) or ""
	-- Double Ultimate pass: the spare one and the key that switches to it
	local u2 = not trial and lp:GetAttribute("DoubleUlt") and Ultimates.byId[lp:GetAttribute("EquippedUlt2") or ""]
	if u2 and line ~= "" then line ..= "   |   " .. Platform.label("SwapUlt") .. " " .. string.upper(u2.name) end
	ultName.Text = line
	updateWaypoint()
	local showCash = not inMatch or (roundState ~= "Fight" and roundState ~= "Intro")
	cashLabel.Visible = showCash
	if inMatch then
		cashLabel.Text = lp:GetAttribute("Tutorial") and "TUTORIAL" or lp:GetAttribute("Sandbox") and "SANDBOX" or ("RUN $" .. tostring(lp:GetAttribute("RunCash") or 0))
		cashLabel.Visible = true
	else
		cashLabel.Text = "$" .. tostring(lp:GetAttribute("Cash") or 0)
	end
	local sh = lp:GetAttribute("Shield") or 0
	health.label.Text = sh > 0 and ("HEALTH  +" .. sh .. " ARMOR") or "HEALTH"
end

return HUD
