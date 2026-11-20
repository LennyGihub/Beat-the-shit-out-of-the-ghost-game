--!strict
-- THE JARS AND POTIONS TUTORIAL: right after the intro (Client/Intro), in the park: how to get stronger with FORMS
-- (Shared/Forms). It always says exactly what to do next, from what the player is doing (no NEXT buttons):
--   STEP 1  DOC MERCY'S JAR      walk to her (an arrow at the screen's edge or over her stall, a sparkling guide line
--                                along the ground, her stall outlined) -> PRESS F TO TALK -> PRESS OPEN on the Pale
--                                Ectoplasm (a bouncing arrow and a ring ON the button) -> watch, PRESS OK
--   STEP 2  MOTHER MOTH'S POTION the same for her hut and the Murky Potion
--   STEP 3  a tip (OPEN OFFLINE!, X10 / X100, the later maps' jars), GOT IT or it closes by itself
-- Wrong panel open: CLOSE IT. It starts for a player in the park who has never done it and owns no form yet (player
-- attribute FormTutDone, Server/Data), gives $20 of starter cash once (Remotes.Forms "tutorial" "start") and is saved
-- as done at the end or on SKIP ("tutorial" "done"). Studio hook: player attribute DebugFormTut = true starts it.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Forms = require(RS.Shared.Forms)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Platform = require(script.Parent.Platform)
local Remotes = RS:WaitForChild("Remotes")

local FT = {}
local lp = Players.LocalPlayer
local GOLD = Color3.fromRGB(255, 214, 60)
local NEAR = 13 -- studs from the stall's counter where its prompt shows

local SellerUI: any = nil
local FormCine: any = nil
local Intro: any = nil
local running = false

type Stage = { kind: string, seller: string, who: string, vial: string, vialName: string, verb: string, why: string }
local STAGES: { Stage } = {
	{ kind = "stim", seller = "DocMercy", who = "DOC MERCY", vial = "PaleEcto", vialName = "PALE ECTOPLASM", verb = "OPEN",
		why = "HER JARS OF ECTOPLASM GIVE YOUR FISTS A FORM: MORE PUNCH DAMAGE, MORE KNOCKBACK" },
	{ kind = "potion", seller = "MotherMoth", who = "MOTHER MOTH", vial = "MurkyPotion", vialName = "MURKY POTION", verb = "DRINK",
		why = "HER POTIONS GIVE YOUR BODY A FORM: MORE HEALTH, MORE STAMINA" },
}

local function owns(kind: string): boolean
	return (lp:GetAttribute(kind == "stim" and "FormStim" or "FormPotion") or "") ~= ""
end
-- how many of this kind wait in the offline queue (player attribute "Offline", Server/Forms)
local function queued(kind: string): number
	local ok, t = pcall(function() return game:GetService("HttpService"):JSONDecode(lp:GetAttribute("Offline") or "{}") end)
	local k = ok and type(t) == "table" and t[kind]
	return (type(k) == "table" and type(k.q) == "table") and #k.q or 0
end
local function talkKey(): string
	local m = Platform.mode()
	if m == "touch" then return "TAP THE TALK BUTTON" end
	if m == "gamepad" then return "PRESS X" end
	return "PRESS F"
end
local function sellerModel(name: string): Model?
	local lobby = workspace:FindFirstChild("Lobby")
	local f = lobby and lobby:FindFirstChild("Sellers")
	local m = f and f:FindFirstChild(name)
	return (m and m:IsA("Model")) and m or nil
end

-- an arrow made of frames, pointing UP (turn the holder to point anywhere)
local function arrowShape(parent: Instance, z: number): Frame
	local a = Instance.new("Frame")
	a.BackgroundTransparency = 1; a.Size = UDim2.fromScale(1, 1); a.ZIndex = z; a.Parent = parent
	local function fr(pos: UDim2, size: UDim2, rot: number, color: Color3, zz: number)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0; f.BackgroundColor3 = color; f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = pos; f.Size = size; f.Rotation = rot; f.ZIndex = zz; f.Parent = a
	end
	for _, layer in { { Grunge.INK, 1.3, z }, { GOLD, 1, z + 1 } } do
		local c, k, zz = layer[1] :: Color3, layer[2] :: number, layer[3] :: number
		fr(UDim2.fromScale(0.5, 0.66), UDim2.fromScale(0.28 * k, 0.5 * k), 0, c, zz)
		fr(UDim2.fromScale(0.5, 0.36), UDim2.fromScale(0.48 * k, 0.48 * k), 45, c, zz)
	end
	return a
end

function FT.running(): boolean return running end

function FT.play()
	if running then return end
	running = true
	;(Remotes :: any).Forms:FireServer("tutorial", "start")
	local pg = lp:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "FormTutorial"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 8
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = pg
	-- THE COACH BOX (top centre, above the sellers' panel): the step, what to do, why
	local box = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.008), Size = UDim2.fromScale(0.62, 0.104), ZIndex = 2, Rotation = -0.4 },
		Color3.fromRGB(21, 17, 15), 71, 3, false)
	local border = Instance.new("UIStroke"); border.Color = GOLD; border.Thickness = 3; border.Parent = box
	local stepT = Grunge.text(box, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.025, 0.05), Size = UDim2.fromScale(0.5, 0.22), TextColor3 = GOLD,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5 })
	local doT = Grunge.text(box, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.025, 0.25), Size = UDim2.fromScale(0.82, 0.44), TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5 })
	-- (the distance has its own label at a fixed text size: as you walk only the number changes, nothing else moves)
	local distT = Grunge.text(box, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.86, 0.27), Size = UDim2.fromScale(0.25, 0.4),
		TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Right, TextScaled = false, ZIndex = 5 })
	local function sizeDist() distT.TextSize = math.max(14, math.floor(box.AbsoluteSize.Y * 0.3)) end
	box:GetPropertyChangedSignal("AbsoluteSize"):Connect(sizeDist)
	sizeDist()
	local whyT = Grunge.text(box, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.025, 0.7), Size = UDim2.fromScale(0.95, 0.24), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(200, 190, 170), ZIndex = 5 })
	local skip = Instance.new("TextButton")
	skip.AutoButtonColor = false; skip.BackgroundTransparency = 1; skip.Text = ""; skip.AnchorPoint = Vector2.new(1, 0)
	skip.Position = UDim2.fromScale(0.985, 0.08); skip.Size = UDim2.fromScale(0.11, 0.36); skip.ZIndex = 6; skip.Parent = box
	Grunge.brush(skip, { Size = UDim2.fromScale(1, 1), ZIndex = 6 }, Color3.fromRGB(60, 50, 44), 72, 10, false)
	Grunge.text(skip, { Text = "SKIP", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.8, 0.7), ZIndex = 8 })
	local got = Instance.new("TextButton")
	got.AutoButtonColor = false; got.BackgroundTransparency = 1; got.Text = ""; got.AnchorPoint = Vector2.new(1, 1)
	got.Position = UDim2.fromScale(0.985, 0.94); got.Size = UDim2.fromScale(0.13, 0.4); got.ZIndex = 6; got.Visible = false; got.Parent = box
	Grunge.brush(got, { Size = UDim2.fromScale(1, 1), ZIndex = 6 }, Color3.fromRGB(62, 118, 40), 73, 10, false)
	Grunge.text(got, { Text = "GOT IT", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.8, 0.7), ZIndex = 8 })
	local bsc = Instance.new("UIScale"); bsc.Parent = box

	-- THE SCREEN ARROW: at the edge pointing the way while the stall is off screen, over it (pointing down) once in view
	local sArrow = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(56, 56), Visible = false, ZIndex = 10 })
	arrowShape(sArrow, 10)
	local sLabel = Grunge.text(gui, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(240, 26), TextColor3 = GOLD, Visible = false, ZIndex = 12 })
	sLabel.TextScaled = false; sLabel.TextSize = 22
	-- THE GUIDE LINE along the ground, from you to the stall (a sparkling gold beam)
	local lineA0 = Instance.new("Attachment")
	local lineA1 = Instance.new("Attachment")
	local beam = Instance.new("Beam")
	beam.Attachment0 = lineA0; beam.Attachment1 = lineA1; beam.FaceCamera = true; beam.Width0 = 0.9; beam.Width1 = 0.9; beam.Segments = 20
	beam.Texture = "rbxasset://textures/particles/sparkles_main.dds"; beam.TextureMode = Enum.TextureMode.Wrap; beam.TextureLength = 2; beam.TextureSpeed = -1.4
	beam.LightEmission = 1; beam.LightInfluence = 0; beam.Color = ColorSequence.new(GOLD); beam.Transparency = NumberSequence.new(0.1, 0.35); beam.Enabled = false
	local holder = Instance.new("Part")
	holder.Name = "FormTutLine"; holder.Anchored = true; holder.CanCollide = false; holder.CanQuery = false; holder.CanTouch = false; holder.Transparency = 1
	holder.Size = Vector3.one * 0.2; holder.Parent = workspace
	lineA1.Parent = holder
	beam.Parent = holder
	-- (under the sparkles: a solid glowing core, so the line reads at any distance)
	local core = Instance.new("Beam")
	core.Attachment0 = lineA0; core.Attachment1 = lineA1; core.FaceCamera = true; core.Width0 = 0.35; core.Width1 = 0.35; core.Segments = 20
	core.LightEmission = 1; core.LightInfluence = 0; core.Color = ColorSequence.new(GOLD); core.Transparency = NumberSequence.new(0.15, 0.45); core.Enabled = false
	core.Parent = holder
	beam:GetPropertyChangedSignal("Enabled"):Connect(function() core.Enabled = beam.Enabled end)
	-- the stall's outline
	local glow: Highlight? = nil
	-- the ring and the arrow ON the button to press (children of the button: always exactly on it)
	local btnRing: Frame? = nil
	local btnArrow: Frame? = nil
	local ringOn: GuiObject? = nil
	local function clearBtn()
		if btnRing then btnRing:Destroy(); btnRing = nil end
		if btnArrow then btnArrow:Destroy(); btnArrow = nil end
		ringOn = nil
	end
	local function markButton(b: GuiObject?)
		if b == ringOn then return end
		clearBtn()
		if not b then return end
		ringOn = b
		local r = Instance.new("Frame")
		r.Name = "TutRing"; r.BackgroundTransparency = 1; r.AnchorPoint = Vector2.new(0.5, 0.5); r.Position = UDim2.fromScale(0.5, 0.5)
		r.Size = UDim2.new(1, 16, 1, 16); r.ZIndex = 30; r.Parent = b
		local st = Instance.new("UIStroke"); st.Color = GOLD; st.Thickness = 4; st.Parent = r
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = r
		btnRing = r
		local a = Instance.new("Frame")
		a.Name = "TutArrow"; a.BackgroundTransparency = 1; a.AnchorPoint = Vector2.new(0.5, 1); a.Position = UDim2.new(0.5, 0, 0, -10)
		a.Size = UDim2.fromOffset(46, 46); a.Rotation = 180; a.ZIndex = 30; a.Parent = b
		arrowShape(a, 31)
		btnArrow = a
	end

	local finished = false
	local function finish()
		if finished then return end
		finished = true
		running = false
		;(Remotes :: any).Forms:FireServer("tutorial", "done")
		if glow then glow:Destroy() end
		clearBtn()
		holder:Destroy(); lineA0:Destroy()
		TweenService:Create(bsc, TweenInfo.new(0.25), { Scale = 0 }):Play()
		task.delay(0.3, function() gui:Destroy() end)
	end
	skip.Activated:Connect(function() Sfx.play("Click"); finish() end)
	got.Activated:Connect(function() Sfx.play("Click"); finish() end)

	-- dist = studs to the stall (its own label); the box only pops when the thing to do changes (no sound: the user
	-- found the sound on every step weird, 2026-11-20)
	local lastDo = ""
	local lastDist = -1
	local function say(step: string, todo: string, why: string, dist: number?)
		if stepT.Text ~= step then stepT.Text = step end
		if whyT.Text ~= why then whyT.Text = why end
		local dd = dist or -1
		if dd ~= lastDist then
			lastDist = dd
			distT.Text = dist and (dd .. " STUDS") or ""
			doT.Size = UDim2.fromScale(dist and 0.6 or 0.82, 0.44)
		end
		if todo ~= lastDo then
			lastDo = todo
			doT.Text = todo
			bsc.Scale = 0.9
			TweenService:Create(bsc, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		end
	end

	local stage = 1
	local tipAt = 0
	task.spawn(function()
		while not finished do
			local now = os.clock()
			local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
			local away = lp:GetAttribute("InMatch") == true
			box.Visible = not away
			border.Transparency = 0.15 + (math.sin(now * 5) * 0.5 + 0.5) * 0.5
			local target: BasePart? = nil -- (the stall to walk to)
			local button: GuiObject? = nil -- (the button to press)
			local st = STAGES[stage]
			if st then
				-- this stage is done once its form is owned and the cinematic is over
				if owns(st.kind) and not FormCine.busy() then
					stage += 1
					if stage > #STAGES then tipAt = now end
				else
					local m = sellerModel(st.seller)
					local prompt = m and (m:FindFirstChild("Prompt", true) :: BasePart?)
					local stepName = "GET STRONGER  -  STEP " .. stage .. " / 3"
					local openKind = SellerUI.kind()
					if FormCine.busy() then
						say(stepName, "WATCH WHAT YOU GET - THEN PRESS OK", st.why)
					elseif openKind == st.kind then
						local b = SellerUI.openButton(st.vial)
						button = b
						if b and queued(st.kind) > 0 then
							-- (they pressed OPEN OFFLINE: that one counts too, or open one now)
							say(stepName, "PRESS " .. st.verb .. " ON THE " .. st.vialName, "YOURS IS OPENING OFFLINE (BOTTOM OF THE SCREEN) - " .. st.verb .. " ONE NOW TO SEE IT RIGHT AWAY")
						elseif b then
							say(stepName, "PRESS " .. st.verb .. " ON THE " .. st.vialName, "THE ARROW SHOWS THE BUTTON. EVERY ONE GIVES A RANDOM FORM - THE RARE ONES ARE RARE")
						else
							say(stepName, "PRESS THE CAMP HOLLOWMERE TAB, THEN " .. st.verb, st.why)
						end
					elseif openKind ~= nil or Platform.windowOpen() then
						-- (another stall's panel or a lobby window: PLAY, SHOP...)
						say(stepName, "CLOSE THIS PANEL - " .. st.who .. " SELLS WHAT YOU NEED", st.why)
					elseif prompt and hrp and (hrp.Position - prompt.Position).Magnitude <= NEAR then
						target = prompt
						say(stepName, talkKey() .. " TO TALK TO " .. st.who, st.why)
					else
						target = prompt
						local d = (prompt and hrp) and math.floor((hrp.Position - prompt.Position).Magnitude) or 0
						say(stepName, "WALK TO " .. st.who, "FOLLOW THE ARROW AND THE GOLD LINE.  " .. st.why, d)
					end
					-- the stall's outline
					if m and (not glow or glow.Adornee ~= m) then
						if glow then glow:Destroy() end
						local h = Instance.new("Highlight")
						h.Adornee = m; h.FillTransparency = 0.85; h.FillColor = GOLD; h.OutlineColor = GOLD; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						h.Parent = gui
						glow = h
					end
				end
			end
			if not STAGES[stage] then
				-- THE TIP, then done
				if glow then glow:Destroy(); glow = nil end
				got.Visible = true
				say("YOU'RE STRONGER - AND EVERYONE CAN SEE IT", "OPEN OFFLINE! OPENS THEM BY ITSELF, EVEN WHILE YOU FIGHT",
					"X10 / X100 OPEN LOTS AT ONCE.  THE NEXT MAPS SELL STRONGER JARS AND POTIONS.  YOUR FORMS SHOW ON YOUR BODY AND FISTS.")
				if now - tipAt > 12 then finish(); break end
			end
			if glow then glow.OutlineTransparency = 0.1 + (math.sin(now * 5) * 0.5 + 0.5) * 0.4; glow.Enabled = not away and SellerUI.kind() == nil and not Platform.windowOpen() end
			-- the ring and the arrow on the button
			markButton(button)
			if btnArrow then btnArrow.Position = UDim2.new(0.5, 0, 0, -10 - math.abs(math.sin(now * 5)) * 10) end
			if btnRing then
				local s = btnRing:FindFirstChildOfClass("UIStroke")
				if s then s.Transparency = math.sin(now * 6) * 0.3 + 0.3 end
			end
			-- the guide line and the screen arrow to the stall
			local showWay = target ~= nil and hrp ~= nil and not away and SellerUI.kind() == nil and not FormCine.busy()
			beam.Enabled = showWay
			sArrow.Visible = showWay; sLabel.Visible = showWay
			if showWay and target and hrp then
				if lineA0.Parent ~= hrp then lineA0.Parent = hrp end
				lineA0.Position = Vector3.new(0, -2.6, 0)
				holder.Position = target.Position - Vector3.new(0, 2, 0)
				local cam = workspace.CurrentCamera
				local vp = cam.ViewportSize
				local at = target.Position + Vector3.new(0, 7, 0)
				local v = cam:WorldToViewportPoint(at)
				local margin = 70
				local x, y, rot
				if v.Z > 0 and v.X > margin and v.X < vp.X - margin and v.Y > margin + 90 and v.Y < vp.Y - margin then
					x, y, rot = v.X, v.Y - math.abs(math.sin(now * 5)) * 14, 180
				else
					local rel = cam.CFrame:PointToObjectSpace(at)
					local dir = Vector2.new(rel.X, -rel.Y)
					dir = dir.Magnitude > 0.001 and dir.Unit or Vector2.new(0, 1)
					local r = math.min(vp.X, vp.Y) * 0.36 + math.sin(now * 5) * 6
					x, y = vp.X / 2 + dir.X * r, vp.Y / 2 + dir.Y * r
					rot = math.deg(math.atan2(dir.X, -dir.Y))
				end
				sArrow.Position = UDim2.fromOffset(x, y); sArrow.Rotation = rot
				sLabel.Text = STAGES[stage] and STAGES[stage].who or ""
				sLabel.Position = UDim2.fromOffset(x, y + (rot == 180 and -46 or 44))
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
			task.wait(1.5)
			if not running and lp:GetAttribute("FormTutDone") == false and lp:GetAttribute("TutorialSeen") == true
				and not lp:GetAttribute("InMatch") and not (Intro and Intro.running()) and (lp:GetAttribute("Forms") or "") == ""
				and lp:GetAttribute("IntroPhase") ~= "arrive" then
				task.wait(1.5) -- (a moment in the park first)
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
