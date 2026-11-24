--!strict
-- INVITE + SHARE (2026-11-24, Server/Share): the lobby's INVITE button opens this window.
--   INVITE FRIENDS = Roblox's friend invite (SocialService:PromptGameInvite) and SHARE A LINK = a share link
--   (Remotes.Share "link": the server opens the share sheet). Both carry LaunchData "ref:<my UserId>": a friend who
--   has never played, joins with it and plays 10 minutes earns me Share.reward(level) cash (5 a day at most).
-- MOMENTS: at big moments (a boss knocked out, a building cleared, an EPIC+ form, a badge) a screenshot of the scene
--   (no UI) is taken and a small SHARE THIS card shows for 9 s at the right edge; pressing it opens the share sheet
--   with the picture and the same "ref:" link (CaptureService:PromptShareCapture). At most one every 40 s, never during
--   the intro.
-- Studio hooks (player attributes): DebugInvite = true opens the window; DebugMoment = "<label>" takes a moment now.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SocialService = game:GetService("SocialService")
local CaptureService = game:GetService("CaptureService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local TEAL = Color3.fromRGB(30, 120, 140)
local MUTED = Color3.fromRGB(190, 180, 160)

local PLAY_MIN, DAILY = 10, 5 -- (Server/Share: PLAY / DAILY)
local function reward(level: number): number return 100 + 25 * math.clamp(math.floor(level), 1, 200) end
local function launchData(): string return "ref:" .. lp.UserId end

local gui: ScreenGui
local panel: Frame
local status: TextLabel
local rewardText: TextLabel
local card: Frame
local cardImg: ImageLabel
local cardText: TextLabel
local onToggle: ((boolean) -> ())? = nil
local seedN = 400
local lastMoment = -math.huge
local momentId: string? = nil
local momentSeq = 0

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	seedN += 1
	local z = props.ZIndex or 1
	local col = props.BackgroundColor3 or GREEN
	props.BackgroundColor3 = nil
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, col, seedN, 12)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.62),
		ZIndex = z + 3, Rotation = (seedN % 3 - 1) * 0.8 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.06 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	b.MouseButton1Down:Connect(function() sc.Scale = 0.94 end)
	b.MouseButton1Up:Connect(function() sc.Scale = 1 end)
	return b
end

local function say(text: string, color: Color3)
	if not status then return end
	status.Text = text
	status.TextColor3 = color
end

-- INVITE FRIENDS: Roblox's own friend picker (with my "ref:" so a new friend counts for the reward)
local inviting = false
local function invite()
	if inviting then return end
	inviting = true
	task.spawn(function()
		local okCan, can = pcall(function() return SocialService:CanSendGameInviteAsync(lp) end)
		if okCan and can then
			local ok = pcall(function()
				local opt = Instance.new("ExperienceInviteOptions")
				opt.LaunchData = launchData()
				opt.PromptMessage = "Beat the ghosts with me!"
				SocialService:PromptGameInvite(lp, opt)
			end)
			say(ok and "PICK THE FRIENDS TO INVITE" or "INVITES DON'T WORK HERE - TRY SHARE A LINK", ok and MUTED or Color3.fromRGB(230, 90, 70))
		else
			say("YOU CAN'T SEND INVITES HERE - TRY SHARE A LINK", Color3.fromRGB(230, 90, 70))
		end
		task.wait(1)
		inviting = false
	end)
end

local function shareLink()
	(Remotes:WaitForChild("Share") :: RemoteEvent):FireServer("link")
	say("OPENING THE SHARE SHEET...", MUTED)
end

local function refreshReward()
	if rewardText then
		local cash = reward(tonumber(lp:GetAttribute("Level")) or 1)
		rewardText.Text = "+$" .. cash .. " FOR YOU"
	end
end

function UI.close()
	if panel and panel.Visible then
		panel.Visible = false
		if onToggle then onToggle(false) end
	end
end

function UI.open()
	if not panel or lp:GetAttribute("InMatch") or panel.Visible then return end
	status.Text = ""
	refreshReward()
	panel.Visible = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end
function UI.isOpen(): boolean return panel ~= nil and panel.Visible end

-- Fx "ShareReward" (the server's toast says how much)
function UI.reward(_n: number, _cash: number)
	Sfx.play("Cash", { PlaybackSpeed = 1.1, Volume = 0.8 })
end

-- MOMENTS ------------------------------------------------------------------------------------------------------------
local function hideCard(seq: number)
	if seq ~= momentSeq or not card then return end
	TweenService:Create(card, TweenInfo.new(0.25), { Position = UDim2.new(1, 20, 0.62, 0) }):Play()
	task.delay(0.3, function() if seq == momentSeq then card.Visible = false; momentId = nil end end)
end

local function shareMoment()
	local id = momentId
	if not id then return end
	momentSeq += 1
	hideCard(momentSeq)
	local function onOk() end
	local function onNo() end
	local ok = pcall(function() CaptureService:PromptShareCapture(Content.fromUri(id), launchData(), onOk, onNo) end)
	if not ok then
		ok = pcall(function() CaptureService:PromptShareCapture(id :: any, launchData(), onOk, onNo) end)
	end
	if not ok then warn("[ShareUI] this device can't share the picture") end
end

-- a big moment: a picture of the scene (no UI) and a SHARE THIS card
function UI.moment(label: string)
	if not card then return end
	local phase = lp:GetAttribute("IntroPhase")
	if phase ~= nil and phase ~= "done" then return end -- (never during the intro)
	if os.clock() - lastMoment < 40 then return end
	lastMoment = os.clock()
	momentSeq += 1
	local seq = momentSeq
	task.delay(0.15, function()
		local ok = pcall(function()
			CaptureService:CaptureScreenshot(function(contentId: string)
				if seq ~= momentSeq then return end
				momentId = contentId
				cardImg.Image = contentId
				cardText.Text = string.upper(label)
				card.Position = UDim2.new(1, 20, 0.62, 0)
				card.Visible = true
				TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Position = UDim2.new(1, -16, 0.62, 0) }):Play()
				task.delay(9, hideCard, seq)
			end)
		end)
		if not ok then lastMoment = -math.huge end -- (no capture here: try again next time)
	end)
end

-- Fx GhostDeath: a BOSS (evolved monster) knocked out is a moment
function UI.ghostDeath()
	if not lp:GetAttribute("InMatch") then return end
	local m = workspace:FindFirstChild("Ghost")
	if m and m:GetAttribute("Evolved") == true then
		UI.moment(tostring(m:GetAttribute("MonsterName") or "THE BOSS") .. " DOWN!")
	end
end

function UI.init(toggled: ((boolean) -> ())?)
	onToggle = toggled
	gui = Instance.new("ScreenGui")
	gui.Name = "ShareUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- THE INVITE WINDOW
	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.42, 0.5), Visible = false, ZIndex = 10 },
		Color3.fromRGB(21, 17, 15), 491, 5, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 1.45; par.Parent = panel
	Grunge.text(panel, { Text = "INVITE", Font = Grunge.HORROR, Position = UDim2.fromScale(0.06, 0.04), Size = UDim2.fromScale(0.5, 0.15), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1, ZIndex = 12 })
	local tb = Grunge.bar(panel, { size = UDim2.fromScale(0.34, 0.035), pos = UDim2.fromScale(0.06, 0.19), color = TEAL, rot = 0.5, seed = 492, slices = 24, outline = false })
	tb.root.ZIndex = 11
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.95, 0.05), Size = UDim2.fromScale(0.22, 0.12), BackgroundColor3 = DARK, ZIndex = 13, Rotation = 1.2 })
	close.Activated:Connect(function() Sfx.play("Click"); UI.close() end)
	Platform.menu(panel, UI.close)

	Grunge.text(panel, { Text = "BRING A FRIEND WHO HAS NEVER PLAYED. WHEN THEY HAVE PLAYED " .. PLAY_MIN .. " MINUTES:", Font = Grunge.TYPE, TextColor3 = MUTED,
		Position = UDim2.fromScale(0.06, 0.25), Size = UDim2.fromScale(0.88, 0.07), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
	rewardText = Grunge.text(panel, { Text = "", Font = Grunge.FONT, TextColor3 = Color3.fromRGB(150, 230, 110), Position = UDim2.fromScale(0.06, 0.33),
		Size = UDim2.fromScale(0.88, 0.13), ZIndex = 12, Rotation = -0.6 })
	Grunge.text(panel, { Text = "(UP TO " .. DAILY .. " FRIENDS A DAY. THE MORE YOUR LEVEL, THE MORE CASH)", Font = Grunge.TYPE, TextColor3 = Color3.fromRGB(130, 120, 108),
		Position = UDim2.fromScale(0.06, 0.47), Size = UDim2.fromScale(0.88, 0.06), ZIndex = 12 })

	local inv = button(panel, "INVITE FRIENDS", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.28, 0.58), Size = UDim2.fromScale(0.42, 0.16), BackgroundColor3 = GREEN, ZIndex = 13, Rotation = -0.8 })
	inv.Activated:Connect(function() Sfx.play("Click"); invite() end)
	local link = button(panel, "SHARE A LINK", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.72, 0.58), Size = UDim2.fromScale(0.42, 0.16), BackgroundColor3 = TEAL, ZIndex = 13, Rotation = 0.8 })
	link.Activated:Connect(function() Sfx.play("Click"); shareLink() end)
	status = Grunge.text(panel, { Text = "", Font = Grunge.FONT, TextColor3 = MUTED, Position = UDim2.fromScale(0.06, 0.8), Size = UDim2.fromScale(0.88, 0.08), ZIndex = 12 })
	Grunge.text(panel, { Text = "SHARE THIS POPS UP AFTER YOUR BIGGEST MOMENTS TOO", Font = Grunge.TYPE, TextColor3 = Color3.fromRGB(130, 120, 108),
		Position = UDim2.fromScale(0.06, 0.9), Size = UDim2.fromScale(0.88, 0.055), ZIndex = 12 })

	-- THE MOMENT CARD (right edge)
	card = Grunge.slab(gui, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 20, 0.62, 0), Size = UDim2.fromScale(0.16, 0.2), Visible = false, ZIndex = 20 },
		Color3.fromRGB(21, 17, 15), 493, 4, false)
	local car = Instance.new("UIAspectRatioConstraint"); car.AspectRatio = 1.2; car.Parent = card
	cardImg = Instance.new("ImageLabel")
	cardImg.BackgroundTransparency = 1; cardImg.ScaleType = Enum.ScaleType.Crop
	cardImg.Position = UDim2.fromScale(0.06, 0.06); cardImg.Size = UDim2.fromScale(0.88, 0.5); cardImg.ZIndex = 21
	cardImg.Parent = card
	cardText = Grunge.text(card, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.06, 0.58), Size = UDim2.fromScale(0.88, 0.12), ZIndex = 22 })
	local shareBtn = button(card, "SHARE THIS", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.73), Size = UDim2.fromScale(0.8, 0.22), BackgroundColor3 = TEAL, ZIndex = 23 })
	shareBtn.Activated:Connect(function() Sfx.play("Click"); shareMoment() end)

	lp:GetAttributeChangedSignal("InMatch"):Connect(function() if lp:GetAttribute("InMatch") then UI.close() end end)
	lp:GetAttributeChangedSignal("Level"):Connect(refreshReward)

	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugInvite"):Connect(function()
			if lp:GetAttribute("DebugInvite") then UI.open() else UI.close() end
		end)
		lp:GetAttributeChangedSignal("DebugMoment"):Connect(function()
			local l = lp:GetAttribute("DebugMoment")
			if type(l) == "string" and l ~= "" then lastMoment = -math.huge; UI.moment(l) end
		end)
	end
end

return UI
