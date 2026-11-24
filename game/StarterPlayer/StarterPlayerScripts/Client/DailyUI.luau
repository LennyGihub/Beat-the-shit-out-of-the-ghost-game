--!strict
-- THE DAILY WINDOW (the lobby's DAILY bar, Client/LobbyUI; 2026-11-24, week 1 of the retention plan), drawn in the
-- game's grunge style like CODES: the LOGIN STREAK's week as 7 tiles (claimed / today / to come; day 7 = an EPIC+
-- jar or potion), CLAIM (Remotes.Daily "claim"), the shield, the road to day 30 (THIRTY NIGHTS), the WELCOME JAR's
-- countdown (OPEN IT when its time is up: Remotes.Daily "welcome") and today's FREE SAMPLES at the two sellers.
-- Rules: Shared/Daily. State: player attribute "Daily" (JSON from Server/Daily). Rewards play the jar / potion
-- cinematic (Fx "DailyReward" in ClientMain: this window closes first).
-- Opens BY ITSELF once a session when a reward waits, in the park, once nothing else is on (tutorial done, the jars /
-- potions tutorial done, no window, no cinematic). The DAILY bar's line and "!" badge follow it (LobbyUI.daily).
-- Studio hooks (player attributes): DebugDaily = true opens it, false closes it; DebugDailyAct = "claim" | "welcome"
-- presses that button (set it to something else first to press it again).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local LobbyUI = require(script.Parent.LobbyUI)
local Daily = require(RS.Shared.Daily)
local Forms = require(RS.Shared.Forms)
local Remotes = RS:WaitForChild("Remotes")
local DailyRemote = Remotes:WaitForChild("Daily") :: RemoteEvent

local UI = {}
local lp = Players.LocalPlayer
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local GOLD = Color3.fromRGB(230, 170, 40)
local MUTED = Color3.fromRGB(190, 180, 160)
local PURPLE = Color3.fromRGB(110, 50, 150)

local gui: ScreenGui
local panel: Frame
local onToggle: ((boolean) -> ())? = nil
local seedN = 700
type Tile = { root: Frame, day: TextLabel, what: TextLabel, state: TextLabel }
local tiles = {} :: { Tile }
local streakT: TextLabel
local shieldT: TextLabel
local d30T: TextLabel
local claimBtn: TextButton
local welcomeT: TextLabel
local welcomeBtn: TextButton
local sampleT: TextLabel
local autoShown = false
local asked = false -- (the notifications question: once a session at most)
local busyFn: (() -> boolean)? = nil

-- PUSH NOTIFICATIONS (Server/Notify plans them, tools/notify/send.py sends them): after a reward, once the cinematic is
-- over, Roblox's own "turn on notifications?" prompt (only if Roblox says it may be shown: 13+, not already on)
local function askNotifications()
	if asked then return end
	asked = true
	task.spawn(function()
		local t = os.clock()
		repeat task.wait(1) until os.clock() - t > 60 or not (busyFn and busyFn())
		task.wait(1.5)
		local ENS = game:GetService("ExperienceNotificationService")
		local ok, can = pcall(function() return ENS:CanPromptOptInAsync() end)
		if ok and can then pcall(function() ENS:PromptOptIn() end) end
	end)
end

type St = { s: number, next: number, shield: boolean, w: number, wg: boolean, fs: boolean, fp: boolean, best: number, x30: boolean, day: number, level: number, set: string }
local function st(): St?
	local raw = lp:GetAttribute("Daily")
	if type(raw) ~= "string" then return nil end
	local ok, t = pcall(function() return HttpService:JSONDecode(raw) end)
	return ok and t or nil
end

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
local function setButton(b: TextButton, text: string, color: Color3)
	(b:FindFirstChild("Label") :: TextLabel).Text = text
	local br = b:FindFirstChild("Brush")
	if br then Grunge.paint(br, color) end
end

local function clock(sec: number): string
	sec = math.max(0, math.floor(sec))
	local h, m = sec // 3600, (sec % 3600) // 60
	if h > 0 then return h .. "H " .. string.format("%02d", m) .. "M" end
	return m .. "M " .. string.format("%02d", sec % 60) .. "S"
end

-- the reward's name for a tile: the real jar / potion of the best set ("PALE ECTOPLASM"), or cash
local function rewardText(r: Daily.Reward, s: St): (string, Color3)
	if r.cash then return "$" .. Daily.cash(r.cash, s.level), Color3.fromRGB(150, 220, 110) end
	local best: Forms.Vial? = nil
	for _, v in Forms.vialsOf(r.kind or "stim", s.set) do
		if v.tier <= (r.tier or 1) and (not best or v.tier > best.tier) then best = v end
	end
	local name = best and best.name or Daily.label(r, s.level)
	if r.min and r.min >= 4 then return "EPIC+ " .. name, Color3.fromRGB(200, 120, 255) end
	return name, best and best.color or Grunge.PAPER
end

-- is there something to take right now (a streak day, or the welcome jar)
local function ready(s: St?): boolean
	if not s then return false end
	return s.next > 0 or (s.w > 0 and not s.wg and workspace:GetServerTimeNow() >= s.w)
end

local function refresh()
	local s = st()
	-- the lobby bar's line + badge
	local sub = "LOGIN REWARDS"
	if s then
		if s.next > 0 then sub = "CLAIM DAY " .. s.next .. "!"
		elseif s.s > 0 then sub = "STREAK: " .. s.s .. (s.s == 1 and " DAY" or " DAYS") end
	end
	LobbyUI.daily(UI.open, sub, ready(s))
	if not panel or not s then return end
	local now = workspace:GetServerTimeNow()
	-- the week shown: the one of today's claim, else the one of the last claimed day
	local focus = s.next > 0 and s.next or math.max(1, s.s)
	local first = ((focus - 1) // Daily.WEEK) * Daily.WEEK + 1
	for i, t in tiles do
		local n = first + i - 1
		local r = Daily.reward(n)
		local text, col = rewardText(r, s)
		t.day.Text = "DAY " .. n
		t.what.Text = text
		t.what.TextColor3 = col
		local claimed = (s.next > 0 and n < s.next) or (s.next == 0 and n <= s.s)
		local today = s.next > 0 and n == s.next
		local br = t.root:FindFirstChild("Brush")
		if br then Grunge.paint(br, today and Color3.fromRGB(120, 90, 20) or (claimed and Color3.fromRGB(30, 60, 26) or (i == Daily.WEEK and PURPLE:Lerp(DARK, 0.4) or DARK))) end
		t.state.Text = claimed and "CLAIMED" or (today and "TODAY!" or (s.next == 0 and n == s.s + 1 and "TOMORROW" or ""))
		t.state.TextColor3 = claimed and Color3.fromRGB(150, 220, 110) or GOLD
	end
	local cur = s.s
	streakT.Text = "STREAK: " .. cur .. (cur == 1 and " DAY" or " DAYS") .. "     BEST: " .. s.best
	shieldT.Text = s.shield and "SHIELD READY: ONE MISSED DAY IS FORGIVEN" or "SHIELD USED THIS WEEK: DON'T MISS A DAY"
	shieldT.TextColor3 = s.shield and Color3.fromRGB(150, 200, 255) or Color3.fromRGB(255, 140, 90)
	d30T.Text = s.x30 and "THIRTY NIGHTS IS YOURS" or ("DAY " .. Daily.DAY30 .. ": THIRTY NIGHTS, AN EXCLUSIVE FORM  (" .. math.min(cur, Daily.DAY30) .. " / " .. Daily.DAY30 .. ")")
	if s.next > 0 then
		setButton(claimBtn, "CLAIM DAY " .. s.next, GREEN)
	else
		setButton(claimBtn, "NEXT REWARD IN " .. clock(Daily.untilTomorrow(now)), DARK)
	end
	-- the welcome jar
	if s.wg then
		welcomeT.Text = "WELCOME JAR: OPENED"
		welcomeBtn.Visible = false
	elseif s.w > 0 and now >= s.w then
		welcomeT.Text = "WELCOME JAR: READY!"
		welcomeBtn.Visible = true
	elseif s.w > 0 then
		welcomeT.Text = "WELCOME JAR (RARE OR BETTER) OPENS IN " .. clock(s.w - now)
		welcomeBtn.Visible = false
	else
		welcomeT.Text = "WELCOME JAR: FINISH THE TUTORIAL"
		welcomeBtn.Visible = false
	end
	sampleT.Text = "FREE TODAY:  JAR AT DOC MERCY - " .. (s.fs and "READY" or "TAKEN") .. "     POTION AT MOTHER MOTH - " .. (s.fp and "READY" or "TAKEN")
	sampleT.TextColor3 = (s.fs or s.fp) and Color3.fromRGB(150, 220, 110) or MUTED
end

function UI.close()
	if panel and panel.Visible then
		panel.Visible = false
		if onToggle then onToggle(false) end
	end
end
function UI.open()
	if not panel or lp:GetAttribute("InMatch") then return end
	if panel.Visible then return end
	refresh()
	panel.Visible = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	if onToggle then onToggle(true) end
end
function UI.isOpen(): boolean return panel ~= nil and panel.Visible end

local function claim()
	local s = st()
	if not s or s.next <= 0 then Sfx.play("Click", { PlaybackSpeed = 0.7 }); return end
	Sfx.play("Cash")
	DailyRemote:FireServer("claim")
	askNotifications()
end
local function openWelcome()
	Sfx.play("Cash")
	DailyRemote:FireServer("welcome")
	askNotifications()
end

-- isBusy: something else is on screen (a cinematic, the intro, a seller...) - the window doesn't open by itself then
function UI.init(toggled: ((boolean) -> ())?, isBusy: (() -> boolean)?)
	onToggle = toggled
	busyFn = isBusy
	gui = Instance.new("ScreenGui")
	gui.Name = "DailyUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")

	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.62, 0.66), Visible = false, ZIndex = 10 },
		Color3.fromRGB(21, 17, 15), 97, 6, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 1.75; par.Parent = panel
	Grunge.text(panel, { Text = "DAILY REWARDS", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.035), Size = UDim2.fromScale(0.5, 0.11), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1, ZIndex = 12 })
	local tb = Grunge.bar(panel, { size = UDim2.fromScale(0.3, 0.025), pos = UDim2.fromScale(0.04, 0.15), color = GOLD, rot = 0.5, seed = 98, slices = 24, outline = false })
	tb.root.ZIndex = 11
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.045), Size = UDim2.fromScale(0.15, 0.09), BackgroundColor3 = DARK, ZIndex = 13, Rotation = 1.2 })
	close.Activated:Connect(function() Sfx.play("Click"); UI.close() end)
	Platform.menu(panel, UI.close)
	streakT = Grunge.text(panel, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.04, 0.2), Size = UDim2.fromScale(0.6, 0.065), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = GOLD, Rotation = -0.5, ZIndex = 12 })
	shieldT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.27), Size = UDim2.fromScale(0.6, 0.042), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

	-- the week: 7 tiles in a row
	local row = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.35), Size = UDim2.fromScale(0.92, 0.27), ZIndex = 11 })
	local rl = Instance.new("UIListLayout"); rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0.012, 0); rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Parent = row
	for i = 1, Daily.WEEK do
		seedN += 3
		local f = Grunge.frame(row, { LayoutOrder = i, Size = UDim2.fromScale((1 - 0.012 * (Daily.WEEK - 1)) / Daily.WEEK, 1), ZIndex = 12 })
		Grunge.brush(f, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = 12 }, DARK, seedN, 8)
		local day = Grunge.text(f, { Text = "DAY " .. i, Position = UDim2.fromScale(0.08, 0.06), Size = UDim2.fromScale(0.84, 0.2), ZIndex = 15, Rotation = (i % 2 == 0) and 1 or -1 })
		local what = Grunge.text(f, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.06, 0.32), Size = UDim2.fromScale(0.88, 0.36), ZIndex = 15 })
		-- (one line at most half its height: "$125" no bigger than a jar's name)
		local cap = Instance.new("UITextSizeConstraint"); cap.Parent = what
		local function fit() cap.MaxTextSize = math.max(8, math.floor(what.AbsoluteSize.Y * 0.42)) end
		what:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit); fit()
		local stt = Grunge.text(f, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.06, 0.74), Size = UDim2.fromScale(0.88, 0.18), ZIndex = 15, TextColor3 = GOLD })
		tiles[i] = { root = f, day = day, what = what, state = stt }
	end

	claimBtn = button(panel, "CLAIM", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.645), Size = UDim2.fromScale(0.42, 0.11), BackgroundColor3 = GREEN, ZIndex = 13, Rotation = -0.8 })
	claimBtn.Activated:Connect(claim)
	d30T = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.775), Size = UDim2.fromScale(0.92, 0.045), ZIndex = 12, TextColor3 = Color3.fromRGB(255, 196, 70) })
	welcomeT = Grunge.text(panel, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.04, 0.84), Size = UDim2.fromScale(0.62, 0.055), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(150, 200, 255), ZIndex = 12 })
	welcomeBtn = button(panel, "OPEN IT", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.825), Size = UDim2.fromScale(0.22, 0.085), BackgroundColor3 = Color3.fromRGB(40, 90, 160), ZIndex = 13, Visible = false })
	welcomeBtn.Activated:Connect(openWelcome)
	sampleT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.915), Size = UDim2.fromScale(0.92, 0.045), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

	-- the welcome jar just started its 20 hours: a good moment to offer the reminder
	local hadWelcome = (st() or {} :: any).w
	lp:GetAttributeChangedSignal("Daily"):Connect(function()
		refresh()
		local s = st()
		if s and (hadWelcome == 0 or hadWelcome == nil) and s.w > 0 and not s.wg then askNotifications() end
		hadWelcome = s and s.w or hadWelcome
	end)
	lp:GetAttributeChangedSignal("InMatch"):Connect(function() if lp:GetAttribute("InMatch") then UI.close() end end)
	refresh()
	-- the clocks tick; the lobby badge follows the welcome jar's time
	task.spawn(function()
		while true do
			task.wait(1)
			refresh()
		end
	end)
	-- opens by itself once a session when something waits (and nothing else is on screen)
	task.spawn(function()
		local calm = 0
		while not autoShown do
			task.wait(0.5)
			local s = st()
			local ok = ready(s) and lp:GetAttribute("TutorialSeen") == true
				and (lp:GetAttribute("FormTutDone") == true or (lp:GetAttribute("Forms") or "") ~= "") -- (not during the jars / potions tutorial)
				and not lp:GetAttribute("InMatch") and (lp:GetAttribute("IntroPhase") == nil or lp:GetAttribute("IntroPhase") == "done")
				and not Platform.windowOpen() and not (isBusy and isBusy())
			calm = ok and calm + 0.5 or 0
			if calm >= 2.5 then
				autoShown = true
				UI.open()
			end
		end
	end)

	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugDaily"):Connect(function()
			if lp:GetAttribute("DebugDaily") == true then UI.open() else UI.close() end
		end)
		lp:GetAttributeChangedSignal("DebugDailyAct"):Connect(function()
			local a = lp:GetAttribute("DebugDailyAct")
			if a == "claim" then claim() elseif a == "welcome" then openWelcome() end
		end)
	end
end

return UI
