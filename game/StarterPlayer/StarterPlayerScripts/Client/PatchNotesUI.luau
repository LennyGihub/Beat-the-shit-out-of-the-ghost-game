--!strict
-- WHAT'S NEW (2026-11-22, the user: "add in the game a patch note that shows everything new since the last update"):
-- the patch notes window (Shared/PatchNotes). It opens BY ITSELF once per update for a player whose save saw older
-- notes (player attribute NotesV below PatchNotes.version; Server/Data), in the park, once nothing else is on: the
-- tutorial done, no READY screen, no intro, no cinematic, no other window. Closing it (GOT IT / CLOSE) tells the
-- server (Remotes.PatchNotes "seen"). The WHAT'S NEW button under the lobby's header line opens it any time (a red
-- dot on it until read); it takes HOW TO PLAY's place, which only shows before the tutorial is played.
-- Studio test hook: player attribute DebugNotes = true opens it, false closes it. Admin: "notes reset".
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PatchNotes = require(RS.Shared.PatchNotes)
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local TAGS = { NEW = Color3.fromRGB(62, 118, 40), CHANGED = Color3.fromRGB(176, 130, 30), FIXED = Color3.fromRGB(40, 110, 120) } :: { [string]: Color3 }

local gui: ScreenGui
local panel: Frame
local btn: TextButton
local dot: Frame
local onToggle: ((boolean) -> ())? = nil
local busy: (() -> boolean)? = nil
local seedN = 400
local autoDone = false

local function unread(): boolean
	return (tonumber(lp:GetAttribute("NotesV")) or PatchNotes.version) < PatchNotes.version
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
	return b
end

local function refreshButton()
	if not btn then return end
	btn.Visible = RS:GetAttribute("TutorialOn") == true and lp:GetAttribute("TutorialSeen") == true and not lp:GetAttribute("InMatch")
		and not Platform.windowOpen() and not (panel and panel.Visible)
	dot.Visible = unread()
end

function UI.isOpen(): boolean return panel ~= nil and panel.Visible end

function UI.close()
	if not panel or not panel.Visible then return end
	panel.Visible = false
	if unread() then (Remotes :: any).PatchNotes:FireServer("seen") end
	if onToggle then onToggle(false) end
	refreshButton()
end

function UI.open()
	if not panel or panel.Visible or lp:GetAttribute("InMatch") then return end
	autoDone = true
	panel.Visible = true
	panel:SetAttribute("OpenedAt", os.clock())
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	Sfx.play("Click")
	if onToggle then onToggle(true) end
	refreshButton()
end

-- the text sizes follow the screen (the rows grow with their text)
local bodies = {} :: { TextLabel }
local heads = {} :: { TextLabel }
local sections = {} :: { TextLabel }
local function fitText()
	local h = workspace.CurrentCamera.ViewportSize.Y
	local body = math.clamp(math.floor(h / 42), 12, 22)
	for _, t in bodies do t.TextSize = body end
	for _, t in heads do t.TextSize = math.floor(body * 1.35) end
	for _, t in sections do t.TextSize = math.floor(body * 1.9) end
end

local function build()
	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.5, 0.8), Visible = false, ZIndex = 10 },
		Color3.fromRGB(21, 17, 15), 97, 7, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 0.95; par.Parent = panel
	Grunge.text(panel, { Text = "WHAT'S NEW", Font = Grunge.HORROR, Position = UDim2.fromScale(0.06, 0.03), Size = UDim2.fromScale(0.6, 0.1), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1, ZIndex = 12 })
	local tb = Grunge.bar(panel, { size = UDim2.fromScale(0.42, 0.022), pos = UDim2.fromScale(0.06, 0.13), color = Color3.fromRGB(150, 18, 20), rot = 0.5, seed = 98, slices = 26, outline = false })
	tb.root.ZIndex = 11
	Grunge.text(panel, { Text = PatchNotes.title .. "  -  EVERYTHING NEW SINCE THE LAST UPDATE", Font = Grunge.TYPE, TextColor3 = Color3.fromRGB(242, 200, 60), Position = UDim2.fromScale(0.06, 0.16),
		Size = UDim2.fromScale(0.88, 0.045), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.95, 0.035), Size = UDim2.fromScale(0.24, 0.075), BackgroundColor3 = DARK, ZIndex = 13, Rotation = 1.2 })
	close.Activated:Connect(function() Sfx.play("Click"); UI.close() end)
	Platform.menu(panel, UI.close)
	-- the list
	local list = Instance.new("ScrollingFrame")
	list.BackgroundColor3 = Color3.fromRGB(12, 10, 9); list.BackgroundTransparency = 0.35; list.BorderSizePixel = 0
	list.Position = UDim2.fromScale(0.06, 0.23); list.Size = UDim2.fromScale(0.88, 0.6); list.ZIndex = 11
	list.ScrollBarThickness = 6; list.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(); list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.Parent = panel
	local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 14); pad.PaddingTop = UDim.new(0, 10); pad.PaddingBottom = UDim.new(0, 10); pad.Parent = list
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 14); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = list
	for i, e in PatchNotes.entries do
		if e.section then
			-- a heading: the section's name over a red brush line
			local sec = Instance.new("Frame")
			sec.BackgroundTransparency = 1; sec.BorderSizePixel = 0; sec.Size = UDim2.new(1, 0, 0, 0); sec.AutomaticSize = Enum.AutomaticSize.Y
			sec.LayoutOrder = i; sec.ZIndex = 12; sec.Parent = list
			local sp = Instance.new("UIPadding"); sp.PaddingTop = UDim.new(0, i > 1 and 12 or 0); sp.PaddingBottom = UDim.new(0, 6); sp.Parent = sec
			local t = Grunge.text(sec, { Text = e.section, Font = Grunge.HORROR, TextScaled = false, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.new(),
				TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 110, 60), ZIndex = 13 })
			table.insert(sections, t)
			local line = Grunge.frame(sec, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 2), Size = UDim2.new(0.55, 0, 0, 3), BackgroundTransparency = 0,
				BackgroundColor3 = Color3.fromRGB(150, 18, 20), ZIndex = 12 })
			local _ = line
			continue
		end
		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1; row.BorderSizePixel = 0; row.Size = UDim2.new(1, 0, 0, 0); row.AutomaticSize = Enum.AutomaticSize.Y
		row.LayoutOrder = i; row.ZIndex = 12; row.Parent = list
		local rl = Instance.new("UIListLayout"); rl.Padding = UDim.new(0, 4); rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Parent = row
		-- the tag + the title on one line
		local head = Instance.new("Frame")
		head.BackgroundTransparency = 1; head.BorderSizePixel = 0; head.Size = UDim2.new(1, 0, 0, 0); head.AutomaticSize = Enum.AutomaticSize.Y
		head.LayoutOrder = 1; head.ZIndex = 12; head.Parent = row
		local hl = Instance.new("UIListLayout"); hl.FillDirection = Enum.FillDirection.Horizontal; hl.Padding = UDim.new(0, 10); hl.VerticalAlignment = Enum.VerticalAlignment.Center
		hl.SortOrder = Enum.SortOrder.LayoutOrder; hl.Parent = head
		local tag = Instance.new("TextLabel")
		tag.BackgroundColor3 = TAGS[e.tag or "NEW"] or GREEN; tag.BorderSizePixel = 0; tag.Font = Grunge.FONT; tag.Text = e.tag or "NEW"; tag.TextColor3 = Grunge.PAPER
		tag.TextStrokeTransparency = 0.3; tag.TextStrokeColor3 = Grunge.INK; tag.AutomaticSize = Enum.AutomaticSize.XY; tag.Size = UDim2.new(); tag.LayoutOrder = 1; tag.ZIndex = 13
		local tp = Instance.new("UIPadding"); tp.PaddingLeft = UDim.new(0, 8); tp.PaddingRight = UDim.new(0, 8); tp.PaddingTop = UDim.new(0, 2); tp.PaddingBottom = UDim.new(0, 2); tp.Parent = tag
		tag.Parent = head
		table.insert(bodies, tag)
		local title = Grunge.text(head, { Text = e.title or "", Font = Grunge.FONT, TextScaled = false, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.new(),
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, ZIndex = 13 })
		table.insert(heads, title)
		local body = Grunge.text(row, { Text = e.text or "", Font = Grunge.TYPE, TextScaled = false, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = Color3.fromRGB(210, 200, 180), LayoutOrder = 2, ZIndex = 13 })
		table.insert(bodies, body)
	end
	fitText()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitText)
	local ok = button(panel, "GOT IT!", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.86), Size = UDim2.fromScale(0.4, 0.095), BackgroundColor3 = GREEN, ZIndex = 13, Rotation = -0.8 })
	ok.Activated:Connect(function() Sfx.play("Click"); UI.close() end)
end

-- busyFn: true while something else owns the screen (a cinematic, the intro...)
function UI.init(toggled: ((boolean) -> ())?, busyFn: (() -> boolean)?)
	onToggle = toggled
	busy = busyFn
	gui = Instance.new("ScreenGui")
	gui.Name = "PatchNotesUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 9
	gui.Parent = lp:WaitForChild("PlayerGui")
	build()
	-- WHAT'S NEW under the lobby's header line (HOW TO PLAY's place: that one is only there before the tutorial)
	btn = Instance.new("TextButton")
	btn.AutoButtonColor = false; btn.BorderSizePixel = 0; btn.BackgroundTransparency = 1; btn.Text = ""
	btn.AnchorPoint = Vector2.new(0.5, 0); btn.Position = UDim2.new(0.5, 0, 0.04, 126); btn.Size = UDim2.fromScale(0.1, 0.042)
	btn.Rotation = -1; btn.Visible = false; btn.ZIndex = 4; btn.Parent = gui
	Grunge.brush(btn, { Size = UDim2.fromScale(1, 1), ZIndex = 4 }, DARK, 81, 12, false)
	Grunge.text(btn, { Text = "WHAT'S NEW", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.88, 0.6), ZIndex = 7 })
	local bmin = Instance.new("UISizeConstraint"); bmin.MinSize = Vector2.new(118, 30); bmin.Parent = btn
	local sc = Instance.new("UIScale"); sc.Parent = btn
	btn.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.05 }):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	btn.Activated:Connect(function() Sfx.play("Click"); UI.open() end)
	dot = Grunge.frame(btn, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.97, 0.12), Size = UDim2.fromScale(0.16, 0.6), BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(200, 30, 24), ZIndex = 8, Visible = false })
	local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0.5, 0); dc.Parent = dot
	local dar = Instance.new("UIAspectRatioConstraint"); dar.AspectRatio = 1; dar.Parent = dot
	local dst = Instance.new("UIStroke"); dst.Color = Grunge.INK; dst.Thickness = 2; dst.Parent = dot
	for _, a in { "TutorialSeen", "InMatch", "NotesV" } do lp:GetAttributeChangedSignal(a):Connect(refreshButton) end
	RS:GetAttributeChangedSignal("TutorialOn"):Connect(refreshButton)
	Platform.windowChanged:Connect(refreshButton)
	lp:GetAttributeChangedSignal("InMatch"):Connect(function() if lp:GetAttribute("InMatch") then UI.close() end end)
	refreshButton()
	-- BY ITSELF once: unread notes, in the park, nothing else on the screen for 2 s in a row
	task.spawn(function()
		local freeSince: number? = nil
		while not autoDone do
			task.wait(0.5)
			local pg = lp:FindFirstChild("PlayerGui")
			local free = unread() and RS:GetAttribute("TutorialOn") == true and lp:GetAttribute("TutorialSeen") == true
				and not lp:GetAttribute("InMatch") and not lp:GetAttribute("Boarding") and not Platform.windowOpen() and not (busy and busy())
				and not (pg and pg:FindFirstChild("ReadyUI")) and lp.Character ~= nil
			if free then
				freeSince = freeSince or os.clock()
				if os.clock() - (freeSince :: number) >= 2 then UI.open() end
			else
				freeSince = nil
			end
		end
	end)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugNotes"):Connect(function()
			if lp:GetAttribute("DebugNotes") == true then UI.open() else UI.close() end
		end)
	end
end

return UI
