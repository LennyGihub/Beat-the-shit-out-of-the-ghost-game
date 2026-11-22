--!strict
-- The result screen of a cleared building (Fx "StageClear", Server/Run.stageCleared), built around the NEXT GOAL:
-- the building's name and CLEARED, cash and XP, the XP bar to the next level, the map's buildings (cleared ones
-- lit), "NEXT: THE BOATHOUSE", a new vial unlocked at the sellers, then the buttons: NEXT BUILDING (the train takes
-- the whole party there), FIGHT AGAIN (same building), BACK TO THE PARK (only you). Remotes.Stage sends the pick.
-- A map's LAST building (info.final, Campaign.isLast) shows only BACK TO THE PARK: the next map starts from the park.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Campaign = require(RS.Shared.Campaign)
local Maps = require(RS.Shared.Maps)
local Levels = require(RS.Shared.Levels)
local Forms = require(RS.Shared.Forms)
local Grunge = require(script.Parent.Grunge)
local TicketShop = require(script.Parent.TicketShop)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui? = nil
local RED = Color3.fromRGB(150, 18, 20)
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local GOLD = Color3.fromRGB(255, 200, 90)
local repickFn: (() -> ())? = nil -- (the open result screen: the server refused a pick, pick again)

local function button(parent: Instance, text: string, props: { [string]: any }, color: Color3, seed: number): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local z = props.ZIndex or 1
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, color, seed, 12)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.88, 0.6), ZIndex = z + 3 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.06 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	return b
end

-- the server refused the pick (no train ticket): the buttons work again
function UI.repick()
	if repickFn then repickFn() end
end

function UI.close()
	if gui then gui:Destroy(); gui = nil end
end

function UI.show(info: { [string]: any })
	UI.close()
	local st = Campaign.stage(info.stage)
	if not st then return end
	local mp = Campaign.mapById[st.map]
	local d = Maps.diffById[info.diff] or Maps.diffById.Normal
	local g = Instance.new("ScreenGui")
	g.Name = "StageClear"; g.IgnoreGuiInset = true; g.DisplayOrder = 30; g.ResetOnSpawn = false
	g.Parent = lp:WaitForChild("PlayerGui")
	gui = g
	local dim = Grunge.frame(g, { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 1 })
	TweenService:Create(dim, TweenInfo.new(0.4), { BackgroundTransparency = 0.45 }):Play()
	local panel = Grunge.slab(g, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.56, 0.78), ZIndex = 2 },
		Color3.fromRGB(21, 17, 15), 71, 7, false)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1.25; ar.Parent = panel
	local psc = Instance.new("UIScale"); psc.Scale = 0.7; psc.Parent = panel
	TweenService:Create(psc, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	-- title
	Grunge.text(panel, { Text = mp.name, Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.03), Size = UDim2.fromScale(0.6, 0.045),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = mp.color, ZIndex = 5 })
	Grunge.text(panel, { Text = st.name, Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.075), Size = UDim2.fromScale(0.7, 0.12),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(235, 50, 35), ZIndex = 5, Rotation = -1 })
	local stamp = Grunge.text(panel, { Text = "CLEARED", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.8, 0.13),
		Size = UDim2.fromScale(0.32, 0.1), TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 6, Rotation = -8 })
	local ssc = Instance.new("UIScale"); ssc.Scale = 2.4; ssc.Parent = stamp
	task.delay(0.35, function()
		TweenService:Create(ssc, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
		Sfx.play("PunchHeavy", { Volume = 0.9, PlaybackSpeed = 0.6 })
	end)
	Grunge.text(panel, { Text = d.name .. (info.first and "   -   FIRST CLEAR!" or ""), Font = Grunge.FONT, Position = UDim2.fromScale(0.05, 0.2),
		Size = UDim2.fromScale(0.7, 0.045), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = info.first and GOLD or d.color, ZIndex = 5 })
	-- cash, XP and the level bar
	local cash = tonumber(info.cash) or 0
	local xp = tonumber(info.xp) or 0
	local cashT = Grunge.text(panel, { Text = "+$0", Font = Grunge.FONT, Position = UDim2.fromScale(0.05, 0.27), Size = UDim2.fromScale(0.4, 0.08),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 5 })
	Grunge.text(panel, { Text = "+" .. xp .. " XP", Font = Grunge.FONT, Position = UDim2.fromScale(0.5, 0.27), Size = UDim2.fromScale(0.45, 0.08),
		TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 200, 255), ZIndex = 5 })
	task.spawn(function()
		local t0 = os.clock()
		while gui == g and os.clock() - t0 < 1.0 do
			cashT.Text = "+$" .. math.floor(cash * math.clamp((os.clock() - t0) / 0.9, 0, 1))
			RunService.Heartbeat:Wait()
		end
		cashT.Text = "+$" .. cash
		if gui == g then Sfx.play("Cash") end
	end)
	local level, into, need = Levels.of(lp:GetAttribute("XP") or 0)
	local title = Levels.title(level)
	local before, after = tonumber(info.before) or level, tonumber(info.after) or level
	Grunge.text(panel, { Text = "LEVEL " .. level .. "  -  " .. title .. (after > before and "   LEVEL UP!" or ""), Font = Grunge.TYPE,
		Position = UDim2.fromScale(0.05, 0.36), Size = UDim2.fromScale(0.9, 0.04), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = after > before and GOLD or Grunge.PAPER, ZIndex = 5 })
	local bar = Grunge.bar(panel, { size = UDim2.fromScale(0.9, 0.04), pos = UDim2.fromScale(0.05, 0.41), color = Color3.fromRGB(80, 140, 230), rot = -0.4, seed = 91, slices = 30, outline = false })
	bar.root.ZIndex = 5
	bar:set(0)
	task.delay(0.5, function() if gui == g then bar:set(into / math.max(1, need)) end end)
	-- the map's buildings: cleared ones lit, this one marked
	local prog = Campaign.clean((function()
		local ok, t = pcall(function() return game:GetService("HttpService"):JSONDecode(lp:GetAttribute("Campaign") or "{}") end)
		return ok and t or {}
	end)())
	Grunge.text(panel, { Text = "BUILDINGS  " .. tostring(info.done or 0) .. " / " .. tostring(info.total or #mp.stages), Font = Grunge.FONT,
		Position = UDim2.fromScale(0.05, 0.49), Size = UDim2.fromScale(0.5, 0.045), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5 })
	local row = Grunge.frame(panel, { Position = UDim2.fromScale(0.05, 0.545), Size = UDim2.fromScale(0.9, 0.07), ZIndex = 5 })
	local rl = Instance.new("UIListLayout"); rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0.012, 0); rl.Parent = row
	for i, s in mp.stages do
		local cleared = (prog[s.id] or 0) > 0
		local chip = Grunge.brush(row, { Size = UDim2.fromScale(1 / #mp.stages - 0.012, 1), LayoutOrder = i, ZIndex = 6 },
			s.id == st.id and RED or (cleared and Color3.fromRGB(70, 110, 50) or Color3.fromRGB(30, 25, 22)), 120 + i, 10, false)
		Grunge.text(chip, { Text = (string.gsub(s.name, "^THE ", "")), Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.5), TextTransparency = cleared and 0 or 0.5, ZIndex = 8 })
	end
	-- the next goal
	local goalText = ""
	local nxt = info.nextId and Campaign.stage(info.nextId)
	local final = info.final == true
	local nextMap = info.nextMap and Campaign.mapById[info.nextMap]
	if final then
		goalText = mp.name .. " CLEARED!  " .. (nextMap and ("NEXT MAP: " .. nextMap.name .. " - TAKE THE TRAIN IN THE PARK")
			or "REPLAY IT ON A HARDER DIFFICULTY")
	elseif info.mapDone and not nxt then
		goalText = mp.name .. " CLEARED!  THE NEXT MAP IS COMING SOON - REPLAY IT ON A HARDER DIFFICULTY"
	elseif nxt then
		goalText = "NEXT: " .. nxt.name .. (nxt.map ~= st.map and ("  (" .. Campaign.mapById[nxt.map].name .. ")") or "")
	end
	Grunge.text(panel, { Text = goalText, Font = Grunge.FONT, Position = UDim2.fromScale(0.05, 0.635), Size = UDim2.fromScale(0.9, 0.05),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 150, 80), ZIndex = 5 })
	-- a better jar / potion opened at the sellers with this level (in a set whose map is open), or a whole new set
	-- with the next map
	local newText, newColor = nil, Grunge.PAPER
	for _, v in Forms.vials do
		if v.level > before and v.level <= after and Campaign.mapOpen(prog, v.set) then
			newText, newColor = "NEW AT " .. Forms.SELLER[v.kind].name .. ": " .. v.name, v.color
		end
	end
	local newMap = nextMap or (nxt and nxt.map ~= st.map and Campaign.mapById[nxt.map]) or nil
	if newMap and table.find(Forms.sets, newMap.id) then
		newText = "NEW AT THE SELLERS: " .. newMap.name .. " JARS AND POTIONS"
		newColor = newMap.color
	end
	if newText then
		Grunge.text(panel, { Text = newText, Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.69), Size = UDim2.fromScale(0.9, 0.04),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = newColor, ZIndex = 5 })
	end
	-- buttons (NEXT / AGAIN need a train ticket: Campaign.TRIPS)
	local picked = false
	local function tickets(): number
		return Campaign.ticketsLeft(lp:GetAttribute("TripsLeft"), lp:GetAttribute("TripsReset"), workspace:GetServerTimeNow())
	end
	local function pick(choice: string)
		if picked then return end
		if choice ~= "lobby" and tickets() <= 0 then Sfx.play("Click", { PlaybackSpeed = 0.6 }); return end
		picked = true
		Sfx.play("Click")
		;(Remotes :: any).Stage:FireServer(choice)
		if choice == "lobby" then UI.close() end
	end
	local x = 0.05
	if final then
		-- the map is done: back to the park only (one big button)
		local park = button(panel, "BACK TO THE PARK", { Position = UDim2.fromScale(0.2, 0.765), Size = UDim2.fromScale(0.6, 0.12), ZIndex = 8, Rotation = -1, Modal = true }, GREEN, 133)
		park.Name = "ParkBtn"
		park.Activated:Connect(function() pick("lobby") end)
	end
	if nxt and not final then
		local b = button(panel, "NEXT BUILDING", { Position = UDim2.fromScale(x, 0.77), Size = UDim2.fromScale(0.34, 0.11), ZIndex = 8, Rotation = -1.5 }, GREEN, 131)
		b.Name = "NextBtn"
		b.Activated:Connect(function() pick("next") end)
		x += 0.36
	end
	if not final then
		local again = button(panel, "FIGHT AGAIN", { Position = UDim2.fromScale(x, 0.775), Size = UDim2.fromScale(0.27, 0.1), ZIndex = 8, Rotation = 1 }, nxt and DARK or GREEN, 132)
		again.Name = "AgainBtn"
		again.Activated:Connect(function() pick("again") end)
		x += 0.29
		-- (Modal: the mouse is free while this screen is up, even in first person)
		local park = button(panel, "THE PARK", { Position = UDim2.fromScale(x, 0.78), Size = UDim2.fromScale(0.95 - x, 0.095), ZIndex = 8, Modal = true }, DARK, 133)
		park.Activated:Connect(function() pick("lobby") end)
	end
	local timer = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.9), Size = UDim2.fromScale(0.9, 0.04),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(170, 160, 145), ZIndex = 5 })
	local ticketT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.733), Size = UDim2.fromScale(0.9, 0.033),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5 })
	local untilT = os.clock() + (tonumber(info.choice) or 60)
	repickFn = function() picked = false end
	-- (no ticket left: the TRAIN TICKETS product in place of NEXT / AGAIN)
	local refillB = button(panel, TicketShop.label(), { Position = UDim2.fromScale(0.05, 0.77), Size = UDim2.fromScale(0.62, 0.11), ZIndex = 8, Rotation = -1, Visible = false },
		Color3.fromRGB(190, 40, 120), 134)
	refillB.Activated:Connect(function() Sfx.play("Click"); TicketShop.buy() end)
	task.spawn(function()
		while gui == g do
			local secs = math.max(0, math.ceil(untilT - os.clock()))
			if final then
				timer.Text = "BACK TO THE PARK IN " .. secs
			else
				timer.Text = picked and "WAITING FOR THE TRAIN..." or ("BACK TO THE PARK IN " .. secs .. "  -  ANYONE CAN PICK THE NEXT TRIP")
			end
			local left = tickets()
			if left > 0 then
				ticketT.Text = "TRAIN TICKETS  " .. left .. " / " .. Campaign.TRIPS.max .. "  -  A TRIP USES ONE"
				ticketT.TextColor3 = Color3.fromRGB(150, 200, 255)
			else
				ticketT.Text = "NO TRAIN TICKETS LEFT  -  " .. Campaign.TRIPS.max .. " MORE IN " .. Campaign.clock((tonumber(lp:GetAttribute("TripsReset")) or 0) - workspace:GetServerTimeNow())
				ticketT.TextColor3 = Color3.fromRGB(255, 110, 80)
			end
			for _, b in { panel:FindFirstChild("NextBtn"), panel:FindFirstChild("AgainBtn") } do
				if b then (b :: GuiObject).Visible = left > 0 end
			end
			refillB.Visible = left <= 0 and not final
			ticketT.Visible = Campaign.TRIPS.enabled and not final
			local lbl = refillB:FindFirstChild("Label") :: TextLabel?
			if lbl and refillB.Visible then lbl.Text = TicketShop.label() end
			task.wait(0.25)
		end
	end)
	-- Studio test hook: player attribute DebugStagePick = "next" | "again" | "lobby" presses that button
	if RunService:IsStudio() then
		local c: RBXScriptConnection
		c = lp:GetAttributeChangedSignal("DebugStagePick"):Connect(function()
			if gui ~= g then c:Disconnect(); return end
			local v = lp:GetAttribute("DebugStagePick")
			if type(v) == "string" then pick(v) end
		end)
	end
end

return UI
