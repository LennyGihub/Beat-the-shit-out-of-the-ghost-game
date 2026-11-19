--!strict
-- THE JARS AND POTIONS TUTORIAL: right after the intro (Client/Intro), in the park, how to get stronger with FORMS
-- (Shared/Forms). It follows what the player does, no NEXT buttons:
--   1. GO SEE DOC MERCY        - an arrow over her stall (seen from anywhere in the park) and its outline; done when
--                                her panel opens
--   2. OPEN A JAR              - the OPEN button of her cheapest jar glows; done when a fist form is owned (after the
--                                first-person cinematic)
--   3. GO SEE MOTHER MOTH      - the same for her hut
--   4. DRINK A POTION          - done when a body form is owned
--   5. A tip: OPEN OFFLINE! / X10 / X100, then it closes by itself
-- It starts for a player in the park who has never done it and owns no form yet (player attribute FormTutDone,
-- Server/Data), gives $20 of starter cash once (Remotes.Forms "tutorial" "start") and is saved as done at the end or
-- on SKIP ("tutorial" "done"). Studio hook: player attribute DebugFormTut = true starts it.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Forms = require(RS.Shared.Forms)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local FT = {}
local lp = Players.LocalPlayer
local GOLD = Color3.fromRGB(255, 214, 60)

type Step = { text: string, sub: string, seller: string?, vial: string?, done: () -> boolean, hold: number? }

local SellerUI: any = nil
local FormCine: any = nil
local Intro: any = nil
local running = false

local function owns(kind: string): boolean
	return (lp:GetAttribute(kind == "stim" and "FormStim" or "FormPotion") or "") ~= ""
end

local STEPS: { Step } = {
	{ text = "GET STRONGER: GO SEE DOC MERCY", sub = "HER JARS OF ECTOPLASM GIVE YOUR FISTS A FORM: MORE DAMAGE, MORE KNOCKBACK", seller = "DocMercy",
		done = function() return SellerUI.kind() == "stim" or owns("stim") end },
	{ text = "OPEN A JAR OF ECTOPLASM", sub = "PRESS OPEN ON THE PALE ECTOPLASM - EVERY JAR GIVES A RANDOM FORM, THE RARE ONES ARE RARE", vial = "PaleEcto",
		done = function() return owns("stim") and not FormCine.busy() end },
	{ text = "NOW YOUR BODY: GO SEE MOTHER MOTH", sub = "HER POTIONS GIVE YOUR BODY A FORM: MORE HEALTH, MORE STAMINA", seller = "MotherMoth",
		done = function() return SellerUI.kind() == "potion" or owns("potion") end },
	{ text = "DRINK A POTION", sub = "PRESS DRINK ON THE MURKY POTION", vial = "MurkyPotion",
		done = function() return owns("potion") and not FormCine.busy() end },
	{ text = "YOU'RE STRONGER - AND EVERYONE CAN SEE IT", sub = "OPEN OFFLINE! OPENS THEM BY ITSELF, EVEN WHILE YOU FIGHT OR ARE AWAY.  X10 / X100 OPEN LOTS AT ONCE. THE LATER MAPS NEED THE LATER JARS.",
		done = function() return false end, hold = 9 },
}

-- an arrow made of frames, pointing down
local function arrowShape(parent: Instance): Frame
	local a = Instance.new("Frame")
	a.BackgroundTransparency = 1; a.Size = UDim2.fromScale(1, 1); a.Parent = parent
	local function fr(pos: UDim2, size: UDim2, rot: number, color: Color3, z: number)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0; f.BackgroundColor3 = color; f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = pos; f.Size = size; f.Rotation = rot; f.ZIndex = z; f.Parent = a
	end
	for _, layer in { { Grunge.INK, 1.25, 1 }, { GOLD, 1, 2 } } do
		local c, k, z = layer[1] :: Color3, layer[2] :: number, layer[3] :: number
		fr(UDim2.fromScale(0.5, 0.32), UDim2.fromScale(0.26 * k, 0.5 * k), 0, c, z)
		fr(UDim2.fromScale(0.5, 0.66), UDim2.fromScale(0.5 * k, 0.5 * k), 45, c, z)
	end
	return a
end

function FT.running(): boolean return running end

function FT.play()
	if running then return end
	running = true
	;(Remotes :: any).Forms:FireServer("tutorial", "start")
	local gui = Instance.new("ScreenGui")
	gui.Name = "FormTutorial"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 8
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	-- the coach box (top centre, above the sellers' panel)
	local box = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.012), Size = UDim2.fromScale(0.56, 0.095), ZIndex = 2, Rotation = -0.5 },
		Color3.fromRGB(21, 17, 15), 71, 3, false)
	local title = Grunge.text(box, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.03, 0.06), Size = UDim2.fromScale(0.66, 0.52), TextColor3 = GOLD,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5 })
	local sub = Grunge.text(box, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.03, 0.58), Size = UDim2.fromScale(0.94, 0.34), TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, ZIndex = 5 })
	local count = Grunge.text(box, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.83, 0.08), Size = UDim2.fromScale(0.1, 0.36),
		TextColor3 = Color3.fromRGB(170, 160, 145), ZIndex = 5 })
	local skip = Instance.new("TextButton")
	skip.AutoButtonColor = false; skip.BackgroundTransparency = 1; skip.Text = ""; skip.AnchorPoint = Vector2.new(1, 0)
	skip.Position = UDim2.fromScale(0.985, 0.08); skip.Size = UDim2.fromScale(0.13, 0.4); skip.ZIndex = 6; skip.Parent = box
	Grunge.brush(skip, { Size = UDim2.fromScale(1, 1), ZIndex = 6 }, Color3.fromRGB(60, 50, 44), 72, 10, false)
	Grunge.text(skip, { Text = "SKIP", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.8, 0.7), ZIndex = 8 })
	local bsc = Instance.new("UIScale"); bsc.Parent = box
	-- the ring round a button in the sellers' panel
	local ring = Grunge.frame(gui, { Visible = false, ZIndex = 20, BackgroundTransparency = 1 })
	local rs = Instance.new("UIStroke"); rs.Color = GOLD; rs.Thickness = 4; rs.Parent = ring
	local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 8); rc.Parent = ring
	-- the arrow over a stall (always on top, seen from the whole park) and the stall's outline
	local bb = Instance.new("BillboardGui")
	bb.Name = "FormTutArrow"; bb.AlwaysOnTop = true; bb.Size = UDim2.fromOffset(70, 110); bb.StudsOffsetWorldSpace = Vector3.new(0, 9, 0)
	bb.LightInfluence = 0; bb.MaxDistance = 1000; bb.Enabled = false; bb.ResetOnSpawn = false
	bb.Parent = lp:WaitForChild("PlayerGui") -- (a 3D billboard does not draw inside a ScreenGui)
	local arrowHolder = Instance.new("Frame"); arrowHolder.BackgroundTransparency = 1; arrowHolder.Size = UDim2.fromOffset(70, 70); arrowHolder.Position = UDim2.fromOffset(0, 36); arrowHolder.Parent = bb
	arrowShape(arrowHolder)
	local bbText = Grunge.text(bb, { Text = "", Font = Grunge.FONT, Size = UDim2.fromOffset(70, 30), TextColor3 = GOLD })
	bbText.TextScaled = false; bbText.TextSize = 18; bbText.Size = UDim2.fromOffset(200, 30); bbText.Position = UDim2.fromOffset(-65, 0)
	local glow: Highlight? = nil

	local finished = false
	local function finish()
		if finished then return end
		finished = true
		running = false
		;(Remotes :: any).Forms:FireServer("tutorial", "done")
		if glow then glow:Destroy() end
		TweenService:Create(bsc, TweenInfo.new(0.25), { Scale = 0 }):Play()
		task.delay(0.3, function() gui:Destroy(); bb:Destroy() end)
	end
	skip.Activated:Connect(function() Sfx.play("Click"); finish() end)

	local function sellerModel(name: string): Model?
		local lobby = workspace:FindFirstChild("Lobby")
		local f = lobby and lobby:FindFirstChild("Sellers")
		local m = f and f:FindFirstChild(name)
		return (m and m:IsA("Model")) and m or nil
	end

	local i = 1
	local shownAt = os.clock()
	local function show(n: number)
		local st = STEPS[n]
		title.Text = st.text
		sub.Text = st.sub
		count.Text = n .. " / " .. #STEPS
		shownAt = os.clock()
		bsc.Scale = 0.7
		TweenService:Create(bsc, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		if n > 1 then Sfx.play("FormMagic", { Volume = 0.5 }) end
	end
	show(1)
	task.spawn(function()
		while not finished do
			local st = STEPS[i]
			local now = os.clock()
			-- hidden in a run / during the cinematic (the tutorial waits)
			local away = lp:GetAttribute("InMatch") == true
			box.Visible = not away and not FormCine.busy()
			-- the arrow and the outline over the stall to walk to
			local m = st.seller and sellerModel(st.seller) or nil
			local target = m and (m:FindFirstChild("Prompt", true) :: BasePart?)
			bb.Adornee = target
			bb.Enabled = target ~= nil and not away and not SellerUI.isOpen()
			arrowHolder.Position = UDim2.fromOffset(0, 36 + math.abs(math.sin(now * 4)) * 10)
			bbText.Text = st.seller == "DocMercy" and "DOC MERCY" or (st.seller == "MotherMoth" and "MOTHER MOTH" or "")
			if m and (not glow or glow.Adornee ~= m) then
				if glow then glow:Destroy() end
				local h = Instance.new("Highlight")
				h.Adornee = m; h.FillTransparency = 1; h.OutlineColor = GOLD; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = gui
				glow = h
			elseif not m and glow then
				glow:Destroy(); glow = nil
			end
			if glow then glow.OutlineTransparency = 0.2 + (math.sin(now * 5) * 0.5 + 0.5) * 0.5 end
			-- the ring round the OPEN button
			local btn = st.vial and SellerUI.openButton(st.vial) or nil
			if btn and btn.AbsoluteSize.X > 0 then
				ring.Visible = true
				local pad = 6 + math.abs(math.sin(now * 5)) * 4
				ring.Position = UDim2.fromOffset(btn.AbsolutePosition.X - pad, btn.AbsolutePosition.Y - pad)
				ring.Size = UDim2.fromOffset(btn.AbsoluteSize.X + pad * 2, btn.AbsoluteSize.Y + pad * 2)
				rs.Transparency = math.sin(now * 6) * 0.3 + 0.3
			else
				ring.Visible = false
			end
			-- next step
			if (st.hold and now - shownAt > st.hold) then
				finish()
				break
			elseif not st.hold and st.done() and now - shownAt > 0.6 then
				i += 1
				if i > #STEPS then finish(); break end
				show(i)
			end
			task.wait(1 / 30)
		end
	end)
end

function FT.init(sellerUI: any, formCine: any, intro: any)
	SellerUI = sellerUI; FormCine = formCine; Intro = intro
	-- start: in the park, after the intro, never done, no form owned yet
	task.spawn(function()
		while true do
			task.wait(2)
			if not running and lp:GetAttribute("FormTutDone") == false and lp:GetAttribute("TutorialSeen") == true
				and not lp:GetAttribute("InMatch") and not (Intro and Intro.running()) and (lp:GetAttribute("Forms") or "") == ""
				and lp:GetAttribute("IntroPhase") ~= "arrive" then
				task.wait(2.5) -- (a moment in the park first)
				if not lp:GetAttribute("InMatch") and not (Intro and Intro.running()) then FT.play() end
			end
		end
	end)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugFormTut"):Connect(function()
			if lp:GetAttribute("DebugFormTut") == true then FT.play() end
		end)
	end
	local _ = Forms
end

return FT
