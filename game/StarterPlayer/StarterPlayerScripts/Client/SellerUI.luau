--!strict
-- The sellers' panel (Fx "OpenSeller" kind: "stim" = DOC MERCY's ectoplasm, "potion" = MOTHER MOTH; Shared/Forms).
-- Left: the four jars / potions (picture, price, the odds of every rarity, LEVEL n when still locked, OPEN / DRINK). Right: the
-- form you WEAR and the COLLECTION (every form of that kind: the ones you got, WEAR buttons; the others ???).
-- Buying sends Remotes.Forms "buy"; the server rolls it and the first-person cinematic plays (Client/FormCine),
-- then this panel comes back. OPEN OFFLINE! (Remotes.Forms "offline") puts it in the queue that opens by itself, a few
-- minutes each (Client/OfflineOpen shows it at the bottom of the screen); the line under the jars shows that queue and
-- the 24 h RARE+ guarantee. Closes when you walk away.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Forms = require(RS.Shared.Forms)
local Levels = require(RS.Shared.Levels)
local Campaign = require(RS.Shared.Campaign)
local HttpService = game:GetService("HttpService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Translate = require(script.Parent.Translate)
local Sfx = require(script.Parent.Sfx)
local VialArt = require(script.Parent.VialArt)
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local titleT: TextLabel
local subT: TextLabel
local cashT: TextLabel
local statusT: TextLabel
local offlineT: TextLabel
local vialFrame: Frame
local wornFrame: Frame
local list: ScrollingFrame
local collT: TextLabel
local kindOpen: string? = nil
local waiting = false
local DARK = Color3.fromRGB(38, 31, 27)
local GREEN = Color3.fromRGB(62, 118, 40)
local LOCKED = Color3.fromRGB(22, 18, 16)
local ACCENT = { stim = Color3.fromRGB(120, 200, 90), potion = Color3.fromRGB(190, 120, 240) }
local seedN = 700

-- the offline queues (player attribute "Offline", JSON from Server/Forms)
local function offlineState(): any
	local ok, t = pcall(function() return HttpService:JSONDecode(lp:GetAttribute("Offline") or "{}") end)
	return ok and type(t) == "table" and t or {}
end
-- "3 MIN" / "15 MIN"
local function mins(sec: number): string return math.floor(sec / 60 + 0.5) .. " MIN" end
-- the line under the jars: this kind's queue and the RARE+ guarantee (finished opening time + the running ones)
local function offlineLine(kind: string): string
	local o = offlineState()
	local now = workspace:GetServerTimeNow()
	local pity = tonumber(o.pity) or 0
	local q = 0
	for _, k in { "stim", "potion" } do
		local st = o[k]
		if type(st) == "table" and type(st.q) == "table" and #st.q > 0 then
			local v = Forms.vialById[st.q[1]]
			if v then pity += math.clamp(now - (tonumber(st.t) or now), 0, Forms.openTime(v)) end
			if k == kind then q = #st.q end
		end
	end
	local left = math.max(0, Forms.OFFLINE.pity - pity)
	local what = kind == "stim" and "JAR" or "POTION"
	return (q > 0 and ("OPENING OFFLINE: " .. q .. " " .. what .. (q > 1 and "S" or "")) or ("OPEN OFFLINE: A FEW MINUTES EACH, EVEN WHEN YOU'RE AWAY"))
		.. "   -   RARE+ GUARANTEED AFTER " .. Campaign.clock(left) .. " MORE OPENING"
end

local function button(parent: Instance, text: string, props: { [string]: any }, color: Color3): TextButton
	seedN += 1
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local z = props.ZIndex or 1
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = z }, color, seedN, 12)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.88, 0.6), ZIndex = z + 3 })
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.06 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	return b
end

local function owned(): { [string]: boolean }
	local o = {}
	for id in string.gmatch(lp:GetAttribute("Forms") or "", "[^,]+") do o[id] = true end
	return o
end
local function level(): number return (Levels.of(lp:GetAttribute("XP") or 0)) end
-- the player's campaign progress (player attribute Campaign, JSON)
local function progress(): { [string]: number }
	local ok, t = pcall(function() return HttpService:JSONDecode(lp:GetAttribute("Campaign") or "{}") end)
	return Campaign.clean(ok and t or {})
end
local function setOpen(set: string): boolean return Campaign.mapOpen(progress(), set) end
-- the map before a set's map (what to clear to open it)
local function before(set: string): string
	for i, m in Campaign.list do
		if m.id == set then return i > 1 and Campaign.list[i - 1].name or "" end
	end
	return ""
end
local setShown = "Camp" -- the set tab showing
local mult = 1 -- x1 / x10 / x100 (the switch in the header)
local multBtns = {} :: { [number]: TextButton }
local multiPop: Frame? = nil
local openBtns = {} :: { [string]: TextButton } -- vial id -> its OPEN button (Client/FormTutorial rings it)
local tabs = {} :: { [string]: TextButton }

local function clear(f: Instance) for _, c in f:GetChildren() do if c:IsA("GuiObject") then c:Destroy() end end end

local function refresh()
	local kind = kindOpen
	if not kind or not panel then return end
	local seller = Forms.SELLER[kind]
	titleT.Text = seller.name
	subT.Text = kind == "stim" and "ECTOPLASM  -  FIST FORMS: PUNCH DAMAGE AND KNOCKBACK" or "POTIONS  -  BODY FORMS: HEALTH AND STAMINA"
	subT.TextColor3 = ACCENT[kind]
	cashT.Text = "$" .. tostring(lp:GetAttribute("Cash") or 0)
	local lvl = level()
	local cash = lp:GetAttribute("Cash") or 0
	-- THE SET TABS (one per map that has a set)
	for _, set in Forms.sets do
		local t = tabs[set]
		if t then
			local on = set == setShown
			local open = setOpen(set)
			local lab = t:FindFirstChild("Label") :: TextLabel?
			if lab then
				lab.Text = (Campaign.mapById[set] and Campaign.mapById[set].name or set) .. (open and "" or "  (LOCKED)")
				lab.TextColor3 = on and Color3.fromRGB(255, 236, 200) or (open and Color3.fromRGB(190, 180, 160) or Color3.fromRGB(120, 110, 100))
			end
			local br = t:FindFirstChild("Brush")
			if br then Grunge.paint(br, on and ACCENT[kind]:Lerp(Color3.new(0, 0, 0), 0.45) or Color3.fromRGB(40, 33, 29)) end
		end
	end
	for m, mb in multBtns do
		local br = mb:FindFirstChild("Brush")
		if br then Grunge.paint(br, m == mult and ACCENT[kind]:Lerp(Color3.new(0, 0, 0), 0.35) or Color3.fromRGB(40, 33, 29)) end
	end
	local mapLocked = not setOpen(setShown)
	-- VIALS
	clear(vialFrame)
	for i, v in Forms.vialsOf(kind, setShown) do
		local locked = mapLocked or lvl < v.level
		seedN += 3
		local card = Grunge.brush(vialFrame, { LayoutOrder = i, ZIndex = 11 }, locked and LOCKED or Color3.fromRGB(30, 24, 21), seedN, 16, false)
		VialArt.draw(card, v, { Position = UDim2.fromScale(0.03, 0.08), Size = UDim2.fromScale(0.32, 0.68), ZIndex = 11 }, locked)
		Grunge.text(card, { Text = v.name, Font = Grunge.FONT, Position = UDim2.fromScale(0.37, 0.06), Size = UDim2.fromScale(0.6, 0.17),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = locked and Color3.fromRGB(120, 110, 100) or v.color, ZIndex = 13 })
		Grunge.text(card, { Text = v.desc, Font = Grunge.TYPE, Position = UDim2.fromScale(0.37, 0.24), Size = UDim2.fromScale(0.6, 0.2), TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = Color3.fromRGB(180, 170, 150), ZIndex = 13 })
		-- the odds: a chip per rarity
		local odds = Grunge.frame(card, { Position = UDim2.fromScale(0.37, 0.47), Size = UDim2.fromScale(0.6, 0.14), ZIndex = 13 })
		local ol = Instance.new("UIListLayout"); ol.FillDirection = Enum.FillDirection.Horizontal; ol.Padding = UDim.new(0.02, 0); ol.SortOrder = Enum.SortOrder.LayoutOrder; ol.Parent = odds
		local ch = Forms.chances(v)
		for r = 1, #Forms.rarity do
			local c = ch[r]
			if c then
				local rr = Forms.rarity[r]
				Grunge.text(odds, { Text = string.sub(rr.name, 1, 1) .. " " .. Forms.pct(c),
					Font = Grunge.TYPE, Size = UDim2.fromScale(0.155, 1), TextColor3 = rr.color, LayoutOrder = r, ZIndex = 14 })
			end
		end
		if locked then
			Grunge.text(card, { Text = mapLocked and ("CLEAR " .. before(setShown)) or ("LEVEL " .. v.level), Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.66, 0.8), Size = UDim2.fromScale(0.58, 0.2), TextColor3 = Color3.fromRGB(255, 150, 80), Rotation = -3, ZIndex = 14 })
		else
			local cost = v.price * mult
			local can = cash >= cost
			local b = button(card, Forms.SELLER[kind].verb .. (mult > 1 and (" x" .. mult) or "") .. "  $" .. cost, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.53, 0.81),
				Size = UDim2.fromScale(0.31, 0.26), ZIndex = 14, Rotation = -1 }, can and GREEN or DARK)
			-- OPEN OFFLINE!: into the queue that opens by itself
			Grunge.text(card, { Text = "OFFLINE: " .. mins(Forms.openTime(v)) .. (mult > 1 and " EACH" or ""), Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.84, 0.68),
				Size = UDim2.fromScale(0.28, 0.07), TextColor3 = Color3.fromRGB(150, 200, 255), ZIndex = 14 })
			local ob = button(card, mult > 1 and ("OFFLINE x" .. mult) or "OPEN OFFLINE!", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.84, 0.81),
				Size = UDim2.fromScale(0.29, 0.26), ZIndex = 14, Rotation = 1 }, can and Color3.fromRGB(46, 84, 140) or DARK)
			local n = mult
			openBtns[v.id] = b
			ob.Activated:Connect(function()
				if (lp:GetAttribute("Cash") or 0) < v.price * n then
					Sfx.play("Click"); statusT.Text = "NOT ENOUGH CASH - BEAT THE BUILDINGS TO EARN MORE"
					return
				end
				Sfx.play("Click")
				;(Remotes :: any).Forms:FireServer("offline", v.id, n)
			end)
			b.Activated:Connect(function()
				if waiting then return end
				if (lp:GetAttribute("Cash") or 0) < v.price * n then
					Sfx.play("Click"); statusT.Text = "NOT ENOUGH CASH - BEAT THE BUILDINGS TO EARN MORE"
					return
				end
				Sfx.play("Click")
				waiting = true
				if n > 1 then
					statusT.Text = (kind == "stim" and "THE DOC OPENS " or "SHE POURS ") .. n .. (kind == "stim" and " JARS..." or " POTIONS...")
				else
					statusT.Text = kind == "stim" and "THE DOC HANDS YOU A JAR..." or "SHE POURS IT OUT OF THE POT..."
				end
				;(Remotes :: any).Forms:FireServer("buy", v.id, n)
				task.delay(n > 1 and 2.5 or 4, function() waiting = false end)
			end)
		end
	end
	-- WORN
	clear(wornFrame)
	local wornId = lp:GetAttribute(kind == "stim" and "FormStim" or "FormPotion") or ""
	local wf = Forms.byId[wornId]
	Grunge.text(wornFrame, { Text = "YOU WEAR", Font = Grunge.TYPE, Size = UDim2.fromScale(1, 0.22), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(170, 160, 145), ZIndex = 12 })
	Grunge.text(wornFrame, { Text = wf and wf.name or "NOTHING YET", Font = Grunge.HORROR, Position = UDim2.fromScale(0, 0.2), Size = UDim2.fromScale(1, 0.42),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = wf and wf.color or Color3.fromRGB(120, 110, 100), ZIndex = 12 })
	Grunge.text(wornFrame, { Text = wf and table.concat(Forms.lines(wf), "   ") or (kind == "stim" and "OPEN A JAR OF ECTOPLASM TO GET A FIST FORM" or "DRINK A POTION TO GET A BODY FORM"),
		Font = Grunge.TYPE, Position = UDim2.fromScale(0, 0.66), Size = UDim2.fromScale(1, 0.26), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = wf and Color3.fromRGB(150, 220, 110) or Color3.fromRGB(150, 140, 125), ZIndex = 12 })
	-- COLLECTION
	clear(list)
	local own = owned()
	local all = Forms.ofKind(kind, setShown)
	local n = 0
	for i, fm in all do
		local has = own[fm.id] == true
		if has then n += 1 end
		local rr = Forms.rarity[fm.rarity]
		seedN += 1
		local row = Grunge.brush(list, { Size = UDim2.new(1, -8, 0, 46), LayoutOrder = i, ZIndex = 11 }, Color3.fromRGB(30, 24, 21), seedN, 18, false)
		Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = rr.color, Position = UDim2.new(0, 4, 0.14, 0), Size = UDim2.new(0, 5, 0.72, 0), ZIndex = 12 })
		Grunge.text(row, { Text = has and fm.name or "???", Font = Grunge.FONT, Position = UDim2.new(0, 14, 0.06, 0), Size = UDim2.new(0.62, 0, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = has and fm.color or Color3.fromRGB(110, 100, 92), ZIndex = 12 })
		Grunge.text(row, { Text = has and table.concat(Forms.lines(fm), "  ") or rr.name, Font = Grunge.TYPE, Position = UDim2.new(0, 14, 0.56, 0), Size = UDim2.new(0.62, 0, 0.36, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = has and Color3.fromRGB(190, 180, 160) or rr.color, ZIndex = 12 })
		if has then
			local isWorn = fm.id == wornId
			local b = button(row, isWorn and "WORN" or "WEAR", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0.28, 0, 0.74, 0), ZIndex = 13 },
				isWorn and DARK or GREEN)
			b.Activated:Connect(function()
				if isWorn then return end
				Sfx.play("Click")
				;(Remotes :: any).Forms:FireServer("equip", fm.id)
			end)
		end
	end
	-- the EXCLUSIVE forms you own of this kind (a code's: in no jar / potion), at the top of every tab
	for i, fm in Forms.exclusives(kind) do
		if own[fm.id] ~= true then continue end
		local rr = Forms.rarityOf(fm)
		seedN += 1
		local row = Grunge.brush(list, { Size = UDim2.new(1, -8, 0, 46), LayoutOrder = -100 + i, ZIndex = 11 }, Color3.fromRGB(24, 30, 38), seedN, 18, false)
		Grunge.frame(row, { BackgroundTransparency = 0, BackgroundColor3 = rr.color, Position = UDim2.new(0, 4, 0.14, 0), Size = UDim2.new(0, 5, 0.72, 0), ZIndex = 12 })
		Grunge.text(row, { Text = fm.name, Font = Grunge.FONT, Position = UDim2.new(0, 14, 0.06, 0), Size = UDim2.new(0.62, 0, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = fm.color, ZIndex = 12 })
		Grunge.text(row, { Text = rr.name .. "  " .. table.concat(Forms.lines(fm), "  "), Font = Grunge.TYPE, Position = UDim2.new(0, 14, 0.56, 0), Size = UDim2.new(0.62, 0, 0.36, 0),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 12 })
		local isWorn = fm.id == wornId
		local b = button(row, isWorn and "WORN" or "WEAR", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0.28, 0, 0.74, 0), ZIndex = 13 },
			isWorn and DARK or GREEN)
		b.Activated:Connect(function()
			if isWorn then return end
			Sfx.play("Click")
			;(Remotes :: any).Forms:FireServer("equip", fm.id)
		end)
	end
	collT.Text = "COLLECTION  " .. n .. " / " .. #all .. "  (" .. (Campaign.mapById[setShown] and Campaign.mapById[setShown].name or setShown) .. ")"
end

function UI.close()
	if panel and panel.Visible then panel.Visible = false end
	kindOpen = nil
end
function UI.isOpen(): boolean return panel ~= nil and panel.Visible end
function UI.kind(): string? return panel ~= nil and panel.Visible and kindOpen or nil end
-- the OPEN button of a vial while the panel shows it (nil otherwise)
function UI.openButton(vialId: string): TextButton?
	local b = openBtns[vialId]
	return (b and b.Parent and panel.Visible) and b or nil
end

function UI.open(kind: string)
	if lp:GetAttribute("InMatch") or not Forms.SELLER[kind] then return end
	kindOpen = kind
	if multiPop then multiPop:Destroy(); multiPop = nil end
	-- the furthest map that is open (its goods are the newest)
	setShown = Forms.sets[1]
	for _, set in Forms.sets do if setOpen(set) then setShown = set end end
	statusT.Text = ""
	waiting = false
	refresh()
	panel.Visible = true
	local s = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = panel; s.Scale = 0.7
	TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end

-- X10 / X100 opened (Fx "FormMulti": kind, vialId, results { form, new }, bestId, worn, prevId): a results screen
-- over the panel: how many of each rarity, the new forms, the best one (WEAR IT if it isn't worn)
function UI.multi(kind: string, vialId: string, results: any, bestId: string, worn: boolean, prevId: string)
	waiting = false
	if not panel or type(results) ~= "table" then return end
	if multiPop then multiPop:Destroy() end
	local v = Forms.vialById[vialId]
	local best = Forms.byId[bestId]
	local pop = Grunge.slab(panel, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.78, 0.7), ZIndex = 40, Rotation = -0.6 },
		Color3.fromRGB(16, 13, 12), 91, 6, false)
	multiPop = pop
	local sc = Instance.new("UIScale"); sc.Scale = 0.6; sc.Parent = pop
	TweenService:Create(sc, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	Grunge.text(pop, { Text = #results .. " x " .. (v and v.name or "?"), Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.04), Size = UDim2.fromScale(0.9, 0.12),
		TextColor3 = v and v.color or Grunge.PAPER, ZIndex = 43 })
	-- the count of each rarity, ticking up
	local counts = {} :: { [number]: number }
	local newList = {} :: { string }
	for _, r in results do
		local fm = Forms.byId[r.form]
		if fm then
			counts[fm.rarity] = (counts[fm.rarity] or 0) + 1
			if r.new then table.insert(newList, fm.name) end
		end
	end
	local row = Grunge.frame(pop, { Position = UDim2.fromScale(0.05, 0.19), Size = UDim2.fromScale(0.9, 0.17), ZIndex = 42 })
	local rl = Instance.new("UIListLayout"); rl.FillDirection = Enum.FillDirection.Horizontal; rl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rl.Padding = UDim.new(0.015, 0); rl.SortOrder = Enum.SortOrder.LayoutOrder; rl.Parent = row
	local labels = {} :: { { t: TextLabel, n: number, name: string } }
	for r = 1, #Forms.rarity do
		local n = counts[r] or 0
		if n > 0 then
			local rr = Forms.rarity[r]
			local chip = Grunge.brush(row, { Size = UDim2.fromScale(0.155, 1), LayoutOrder = r, ZIndex = 43 }, Color3.fromRGB(32, 26, 22), 300 + r, 10, false)
			local t = Grunge.text(chip, { Text = "0", Font = Grunge.FONT, Position = UDim2.fromScale(0.05, 0.02), Size = UDim2.fromScale(0.9, 0.6), TextColor3 = rr.color, ZIndex = 45 })
			Grunge.text(chip, { Text = rr.name, Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.62), Size = UDim2.fromScale(0.9, 0.32), TextColor3 = rr.color, ZIndex = 45 })
			table.insert(labels, { t = t, n = n, name = rr.name })
		end
	end
	task.spawn(function()
		local t0 = os.clock()
		while pop.Parent and os.clock() - t0 < 0.9 do
			local k = math.clamp((os.clock() - t0) / 0.8, 0, 1)
			for _, l in labels do l.t.Text = tostring(math.floor(l.n * k + 0.5)) end
			task.wait()
		end
		for _, l in labels do l.t.Text = tostring(l.n) end
	end)
	-- the best one
	if best then
		local rr = Forms.rarity[best.rarity]
		Grunge.text(pop, { Text = "BEST: " .. rr.name, Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.4), Size = UDim2.fromScale(0.9, 0.06), TextColor3 = rr.color, ZIndex = 43 })
		local bn = Grunge.text(pop, { Text = best.name, Font = Grunge.HORROR, Position = UDim2.fromScale(0.05, 0.46), Size = UDim2.fromScale(0.9, 0.13), TextColor3 = best.color, ZIndex = 43, Rotation = -1.5 })
		local bs = Instance.new("UIScale"); bs.Scale = 2; bs.Parent = bn
		task.delay(0.9, function()
			TweenService:Create(bs, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
			Sfx.play(best.rarity >= 3 and "MagicBurst" or "FormMagic", { Volume = 0.8 })
		end)
		Grunge.text(pop, { Text = table.concat(Forms.lines(best), "   "), Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.6), Size = UDim2.fromScale(0.9, 0.055),
			TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 43 })
	end
	Grunge.text(pop, { Text = #newList > 0 and ("NEW: " .. table.concat(newList, ", ")) or "NOTHING NEW THIS TIME", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.67),
		Size = UDim2.fromScale(0.9, 0.07), TextWrapped = true, TextColor3 = #newList > 0 and Color3.fromRGB(255, 215, 90) or Color3.fromRGB(160, 150, 135), ZIndex = 43 })
	-- WEAR IT (the best, when it isn't the worn one) / OK
	local wornNow = lp:GetAttribute(kind == "stim" and "FormStim" or "FormPotion")
	local function close() if multiPop == pop then multiPop = nil end pop:Destroy() end
	if best and wornNow ~= best.id then
		local w = button(pop, "WEAR " .. best.name, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.32, 0.86), Size = UDim2.fromScale(0.4, 0.13), ZIndex = 44, Rotation = -1 }, GREEN)
		w.Activated:Connect(function() Sfx.play("Click"); (Remotes :: any).Forms:FireServer("equip", best.id); close() end)
	end
	local ok = button(pop, worn and "WORN - OK" or "OK", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((best and wornNow ~= best.id) and 0.72 or 0.5, 0.86),
		Size = UDim2.fromScale(0.28, 0.13), ZIndex = 44, Rotation = 1 }, DARK)
	ok.Activated:Connect(function() Sfx.play("Click"); close() end)
	statusT.Text = ""
	local _ = prevId
end

-- a buy went wrong (Fx "FormResult")
function UI.result(good: boolean, text: string)
	waiting = false
	if statusT then statusT.Text = Translate.auto(string.upper(text)) end
	if not good then Sfx.play("Click", { PlaybackSpeed = 0.6 }) end
end

-- the buy went through: the cinematic plays (then the panel comes back)
function UI.rolled(): string?
	local k = kindOpen
	UI.close()
	waiting = false
	return k
end

function UI.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "SellerUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 6
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.slab(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.7, 0.82), Visible = false, ZIndex = 8 },
		Color3.fromRGB(21, 17, 15), 77, 6, false)
	local par = Instance.new("UIAspectRatioConstraint"); par.AspectRatio = 1.5; par.Parent = panel
	titleT = Grunge.text(panel, { Text = "", Font = Grunge.HORROR, Position = UDim2.fromScale(0.04, 0.025), Size = UDim2.fromScale(0.5, 0.095), TextXAlignment = Enum.TextXAlignment.Left,
		Rotation = -1, ZIndex = 11, TextColor3 = Color3.fromRGB(235, 50, 35) })
	subT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.12), Size = UDim2.fromScale(0.6, 0.04), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	cashT = Grunge.text(panel, { Text = "$0", AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.78, 0.03), Size = UDim2.fromScale(0.22, 0.07), TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 11, Rotation = 2 })
	local close = button(panel, "CLOSE", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(0.96, 0.03), Size = UDim2.fromScale(0.15, 0.065), ZIndex = 12, Rotation = 1.5, Modal = true }, DARK)
	close.Activated:Connect(function() Sfx.play("Click"); UI.close() end)
	Platform.menu(panel, function() UI.close() end)
	-- X1 / X10 / X100: how many the buttons open at once
	for i, m in { 1, 10, 100 } do
		local mb = button(panel, "x" .. m, { Position = UDim2.fromScale(0.66 + (i - 1) * 0.1, 0.112), Size = UDim2.fromScale(0.09, 0.05), ZIndex = 12, Rotation = i == 2 and 1 or -1 }, DARK)
		mb.Activated:Connect(function()
			Sfx.play("Click")
			mult = m
			refresh()
		end)
		multBtns[m] = mb
	end
	-- one tab per map with a set (each map brings 4 new jars and 4 new potions)
	for i, set in Forms.sets do
		local tw = math.min(0.27, 0.56 / #Forms.sets - 0.012) -- (the tabs share the left half: the right is the worn form)
		local t = button(panel, set, { Position = UDim2.fromScale(0.04 + (i - 1) * (tw + 0.012), 0.172), Size = UDim2.fromScale(tw, 0.058), ZIndex = 12, Rotation = (i % 2 == 0) and 1 or -1 }, DARK)
		local lab = t:FindFirstChild("Label") :: TextLabel?
		if lab then lab.Font = Grunge.TYPE end
		t.Activated:Connect(function()
			Sfx.play("Click")
			setShown = set
			refresh()
		end)
		tabs[set] = t
	end
	vialFrame = Grunge.frame(panel, { Position = UDim2.fromScale(0.04, 0.24), Size = UDim2.fromScale(0.56, 0.64), ZIndex = 10 })
	local grid = Instance.new("UIGridLayout"); grid.CellSize = UDim2.fromScale(0.49, 0.485); grid.CellPadding = UDim2.fromScale(0.02, 0.03)
	grid.SortOrder = Enum.SortOrder.LayoutOrder; grid.Parent = vialFrame
	statusT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.895), Size = UDim2.fromScale(0.56, 0.04), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(255, 150, 80), ZIndex = 11 })
	offlineT = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.04, 0.938), Size = UDim2.fromScale(0.43, 0.032), TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Color3.fromRGB(150, 200, 255), ZIndex = 11 })
	-- CANCEL QUEUE (this kind's offline queue, all of it refunded): the first tap shows the refund, a second one within 3 s cancels
	local cancelB = button(panel, "CANCEL QUEUE", { Name = "CancelQueue", Position = UDim2.fromScale(0.48, 0.93), Size = UDim2.fromScale(0.12, 0.046), ZIndex = 12, Visible = false },
		Color3.fromRGB(150, 32, 26))
	local cancelL = cancelB:FindFirstChild("Label") :: TextLabel
	cancelL.Font = Grunge.TYPE
	local confirmUntil = 0
	local function queued(kind: string): ({ string })
		local st = offlineState()[kind]
		return (type(st) == "table" and type(st.q) == "table") and st.q or {}
	end
	local function updateCancel()
		local q = kindOpen and queued(kindOpen) or {}
		cancelB.Visible = #q > 0
		if os.clock() >= confirmUntil then cancelL.Text = "CANCEL QUEUE" end
	end
	cancelB.Activated:Connect(function()
		if not kindOpen then return end
		Sfx.play("Click")
		if os.clock() < confirmUntil then
			confirmUntil = 0
			;(Remotes :: any).Forms:FireServer("cancel", kindOpen)
		else
			local n = 0
			for _, id in queued(kindOpen) do local v = Forms.vialById[id]; if v then n += v.price end end
			confirmUntil = os.clock() + 3
			cancelL.Text = "REFUND $" .. n .. "?"
			task.delay(3.05, updateCancel)
		end
	end)
	lp:GetAttributeChangedSignal("Offline"):Connect(updateCancel)
	task.spawn(function()
		while true do
			if panel.Visible and kindOpen then offlineT.Text = offlineLine(kindOpen); updateCancel() end
			task.wait(1)
		end
	end)
	-- worn + collection
	wornFrame = Grunge.frame(panel, { Position = UDim2.fromScale(0.63, 0.18), Size = UDim2.fromScale(0.33, 0.17), ZIndex = 10 })
	collT = Grunge.text(panel, { Text = "COLLECTION", Font = Grunge.FONT, Position = UDim2.fromScale(0.63, 0.37), Size = UDim2.fromScale(0.33, 0.045),
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11 })
	list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1; list.BorderSizePixel = 0; list.Position = UDim2.fromScale(0.63, 0.43); list.Size = UDim2.fromScale(0.33, 0.52)
	list.ScrollBarThickness = 5; list.ScrollBarImageColor3 = Color3.fromRGB(150, 30, 26); list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(); list.ZIndex = 10; list.Parent = panel
	local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 4); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = list
	for _, a in { "Cash", "XP", "Forms", "FormStim", "FormPotion", "Offline" } do
		lp:GetAttributeChangedSignal(a):Connect(function() if panel.Visible then refresh() end end)
	end
	-- walking away closes it
	RunService.Heartbeat:Connect(function()
		if not panel.Visible or not kindOpen then return end
		local lobby = workspace:FindFirstChild("Lobby")
		local f = lobby and lobby:FindFirstChild("Sellers")
		local m = f and f:FindFirstChild(kindOpen == "stim" and "DocMercy" or "MotherMoth")
		local p = m and m:FindFirstChild("Prompt", true) :: BasePart?
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if lp:GetAttribute("InMatch") or (p and hrp and (hrp.Position - p.Position).Magnitude > 22) then UI.close() end
	end)
	-- Studio test hook: player attribute DebugSeller = "stim" | "potion" opens that panel ("" closes it)
	if RunService:IsStudio() then
		-- DebugSellerMult = 1 | 10 | 100 sets the switch
		lp:GetAttributeChangedSignal("DebugSellerMult"):Connect(function()
			local m = lp:GetAttribute("DebugSellerMult")
			if m == 1 or m == 10 or m == 100 then mult = m; refresh() end
		end)
		lp:GetAttributeChangedSignal("DebugSeller"):Connect(function()
			local k = lp:GetAttribute("DebugSeller")
			if k == "stim" or k == "potion" then UI.open(k) else UI.close() end
		end)
	end
end

return UI
