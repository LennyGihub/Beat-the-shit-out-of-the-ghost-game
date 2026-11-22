--!strict
-- THE FORM CINEMATIC (first person): what plays when you buy a jar from Doc Mercy or a potion from Mother Moth (Fx "FormRolled",
-- Server/Forms rolled the form). Your own blocky arms (the fight's first-person hands: dark sleeve, skin, fist):
--   ECTOPLASM (Doc Mercy; internal kind "stim"): the left hand holds the jar up, the right twists its lid off (a
--           hiss, a puff of glowing goo), the goo climbs out by itself, leaps onto your right fist and crawls up the
--           arm, the jar drops; the heart pounds faster, veins of the form's colour light up the arms, a bone
--           cracks, both fists come up - BURST.
--   POTION: the right hand brings the bottle up, the left pulls the cork (a puff of coloured smoke), you tip it back
--           and gulp it down (the view tilts up), drop it; the air ripples, mist rises off your arms, the veins
--           light up from the wrists - BURST.
-- Then the REVEAL: rarity, the form's name in its colour, what it does, NEW! or ALREADY YOURS, and WEAR IT / KEEP
-- (if another form of that kind was worn) or OK. Higher rarities shake harder and hold the change longer.
-- The player is anchored, their body hidden and the camera scripted while it plays (it never runs in a fight).
-- A CODE's form (Server/Codes, Fx "CodeReward") plays it too, with no vial (a jar of the form's own colour, no seller).
-- Studio test hooks (player attributes): DebugFormCine = "<formId>" plays it for that form (no buy, nothing saved);
-- DebugFormFreeze = seconds into the cinematic at which it stops (photos); DebugFormPick = "wear" | "keep" | "ok".
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Forms = require(RS.Shared.Forms)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local FC = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local A = CFrame.Angles
local C = CFrame.new
local Fx: any = nil
local HUD: any = nil
local playing = false
FC.onDone = nil :: (() -> ())?

function FC.init(fx, hud) Fx = fx; HUD = hud end
function FC.busy(): boolean return playing end

local function ss(x: number): number x = math.clamp(x, 0, 1); return x * x * (3 - 2 * x) end
local function seg(t: number, a: number, b: number): number return math.clamp((t - a) / (b - a), 0, 1) end
local function back(x: number): number -- (overshoots a little, like Back easing)
	x = math.clamp(x, 0, 1)
	local c = 1.7
	return 1 + (c + 1) * (x - 1) ^ 3 + c * (x - 1) ^ 2
end
local function lerpCF(a: CFrame, b: CFrame, k: number): CFrame return a:Lerp(b, k) end

-- PARTS (local, in the camera)
local model: Model? = nil
local function mk(name: string, size: Vector3, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Parent = model
	return p
end

type Arm = { fist: BasePart, arm: BasePart, sleeve: BasePart, thumb: BasePart, veins: { BasePart }, light: PointLight }
local function newArm(side: string, skin: Color3): Arm
	local a: Arm = {
		fist = mk(side .. "Fist", Vector3.new(0.44, 0.42, 0.5), skin),
		arm = mk(side .. "Arm", Vector3.new(0.34, 0.34, 1.7), skin),
		sleeve = mk(side .. "Sleeve", Vector3.new(0.46, 0.46, 1.2), Color3.fromRGB(46, 42, 40), Enum.Material.Fabric),
		thumb = mk(side .. "Thumb", Vector3.new(0.14, 0.14, 0.3), skin),
		veins = {},
		light = Instance.new("PointLight"),
	}
	a.light.Range = 0; a.light.Brightness = 2; a.light.Shadows = false; a.light.Parent = a.fist
	for i = 1, 16 do
		local v = mk(side .. "Vein", Vector3.new(0.035, 0.03, 0.1), Color3.new(1, 1, 1), Enum.Material.Neon)
		v.Transparency = 1
		a.veins[i] = v
	end
	return a
end
-- fistCF = the fist in camera space; the forearm runs back from it (+Z), the sleeve behind that
local function placeArm(a: Arm, fistCF: CFrame, base: CFrame, thumbOut: number?)
	a.fist.CFrame = base * fistCF
	a.arm.CFrame = base * fistCF * C(0, 0, 0.25 + 0.85)
	a.sleeve.CFrame = base * fistCF * C(0, 0, 1.95 - 0.2 + 0.6)
	a.thumb.CFrame = base * fistCF * C((thumbOut or 0) * 0.2, 0.2, -0.12) * A(-0.4, 0, 0)
end

-- the VEINS: segments on the forearm's top face (arm-local: x across, z along, from the elbow +Z to the wrist -Z),
-- each grows from its start once the spread reaches it. from = where they start (z), speed = studs per second
type VSeg = { a: Vector3, b: Vector3, d: number }
local function veinLayout(seed: number, fromZ: number): { VSeg }
	local rng = Random.new(seed)
	local out = {} :: { VSeg }
	local y = 0.172
	-- the main vein, zigzagging along the arm
	local pts = {}
	for z = 0.8, -0.8, -0.22 do table.insert(pts, Vector3.new(rng:NextNumber(-0.05, 0.05), y, z)) end
	for i = 1, #pts - 1 do
		local a, b = pts[i], pts[i + 1]
		table.insert(out, { a = a, b = b, d = math.min(math.abs(a.Z - fromZ), math.abs(b.Z - fromZ)) })
		-- branches off every other joint
		if i % 2 == 0 then
			local s = (i % 4 == 0) and 1 or -1
			local e = a + Vector3.new(s * rng:NextNumber(0.08, 0.13), 0, rng:NextNumber(-0.22, 0.22))
			e = Vector3.new(math.clamp(e.X, -0.15, 0.15), y, math.clamp(e.Z, -0.82, 0.82))
			table.insert(out, { a = a, b = e, d = math.abs(a.Z - fromZ) + 0.1 })
		end
	end
	table.sort(out, function(p, q) return p.d < q.d end)
	return out
end
local function placeVeins(a: Arm, layout: { VSeg }, spread: number, color: Color3, glow: number)
	local armCF = a.arm.CFrame
	for i, v in a.veins do
		local sgm = layout[i]
		if not sgm then v.Transparency = 1; continue end
		local k = math.clamp((spread - sgm.d) / 0.18, 0, 1)
		if k <= 0 then v.Transparency = 1; continue end
		local pa = sgm.a
		local pb = sgm.a + (sgm.b - sgm.a) * k
		local len = (pb - pa).Magnitude
		if len < 0.01 then v.Transparency = 1; continue end
		local mid = (pa + pb) / 2
		v.Size = Vector3.new(0.04, 0.03, len + 0.03)
		v.CFrame = armCF * CFrame.lookAt(mid, pb)
		v.Color = color:Lerp(Color3.new(1, 1, 1), 0.15 * glow)
		v.Transparency = 0.05
	end
end

-- embers rising round a fist once the form is in
local function embers(list: { BasePart }, fist: BasePart, color: Color3, now: number, on: number)
	for i, p in list do
		if on <= 0 then p.Transparency = 1; continue end
		local ph = (now * 1.3 + i / #list) % 1
		local sd = i * 2.1
		p.Size = Vector3.one * 0.12 * (1.2 - ph)
		p.CFrame = CFrame.new(fist.Position + fist.CFrame:VectorToWorldSpace(Vector3.new(math.sin(sd + now) * 0.3, 0.15 + ph * 0.9, math.cos(sd + now) * 0.3)))
			* A(now * 3 + i, now * 2, 0)
		p.Color = color:Lerp(Color3.new(1, 1, 1), (1 - ph) * 0.35)
		p.Transparency = 1 - on * (1 - ph * 0.7)
	end
end

-- the ITEMS
type Item = { root: CFrame, parts: { { p: BasePart, off: CFrame } }, liquid: BasePart, liquidFull: Vector3, liquidOff: CFrame, column: boolean?, cork: BasePart? }
-- Doc Mercy's jar of ectoplasm: glass, a screw lid ("cork" here: it comes off), the glowing goo, a label. +Y is up.
local function jar(liquidColor: Color3): Item
	local it: Item = { root = CFrame.new(), parts = {}, liquid = nil :: any, liquidFull = Vector3.new(0.4, 0.46, 0.4), liquidOff = C(0, -0.03, 0), column = true, cork = nil }
	local function add(p: BasePart, off: CFrame) table.insert(it.parts, { p = p, off = off }) return p end
	local body = add(mk("Jar", Vector3.new(0.48, 0.56, 0.48), Color3.fromRGB(210, 228, 220), Enum.Material.Glass), C(0, 0, 0))
	body.Transparency = 0.5
	it.liquid = add(mk("Goo", it.liquidFull, liquidColor, Enum.Material.Neon), it.liquidOff)
	it.liquid.Transparency = 0.12
	it.cork = add(mk("Lid", Vector3.new(0.52, 0.12, 0.52), Color3.fromRGB(70, 66, 60), Enum.Material.Metal), C(0, 0.33, 0))
	add(mk("Label", Vector3.new(0.34, 0.2, 0.02), Color3.fromRGB(214, 200, 160), Enum.Material.SmoothPlastic), C(0, 0.02, -0.25))
	add(mk("LabelMark", Vector3.new(0.14, 0.06, 0.01), Color3.fromRGB(140, 30, 26), Enum.Material.SmoothPlastic), C(0, 0.04, -0.262))
	return it
end
local function bottle(liquidColor: Color3): Item
	local it: Item = { root = CFrame.new(), parts = {}, liquid = nil :: any, liquidFull = Vector3.new(0.48, 0.48, 0.48), liquidOff = C(0, -0.02, 0), column = nil, cork = nil }
	local function add(p: BasePart, off: CFrame) table.insert(it.parts, { p = p, off = off }) return p end
	-- the neck points up (+Y)
	local body = add(mk("Body", Vector3.new(0.58, 0.58, 0.58), Color3.fromRGB(200, 220, 210), Enum.Material.Glass, Enum.PartType.Ball), C(0, 0, 0))
	body.Transparency = 0.4
	it.liquid = add(mk("Liquid", it.liquidFull, liquidColor, Enum.Material.Neon, Enum.PartType.Ball), it.liquidOff)
	it.liquid.Transparency = 0.12
	local neck = add(mk("Neck", Vector3.new(0.15, 0.3, 0.15), Color3.fromRGB(200, 220, 210), Enum.Material.Glass), C(0, 0.38, 0))
	neck.Transparency = 0.4
	add(mk("Lip", Vector3.new(0.2, 0.05, 0.2), Color3.fromRGB(180, 200, 190), Enum.Material.Glass), C(0, 0.52, 0))
	it.cork = add(mk("Cork", Vector3.new(0.15, 0.16, 0.15), Color3.fromRGB(150, 110, 70), Enum.Material.Wood), C(0, 0.6, 0))
	add(mk("Label", Vector3.new(0.3, 0.2, 0.02), Color3.fromRGB(214, 200, 160), Enum.Material.SmoothPlastic), C(0, -0.02, -0.29))
	add(mk("String", Vector3.new(0.17, 0.03, 0.17), Color3.fromRGB(120, 70, 40), Enum.Material.Fabric), C(0, 0.46, 0))
	return it
end
-- place an item: root = its frame in the camera; liquidK = how much is left (1..0)
local function placeItem(it: Item, base: CFrame, root: CFrame, liquidK: number, corkCF: CFrame?)
	for _, e in it.parts do
		local off = e.off
		if e.p == it.cork and corkCF then
			e.p.CFrame = base * corkCF
			continue
		end
		if e.p == it.liquid then
			local k = math.max(0.02, liquidK)
			if it.column then
				-- (the jar: the goo's level drops toward the bottom)
				e.p.Size = Vector3.new(it.liquidFull.X, it.liquidFull.Y * k, it.liquidFull.Z)
				off = it.liquidOff * C(0, -it.liquidFull.Y * (1 - k) / 2, 0)
			else
				e.p.Size = it.liquidFull * (0.35 + 0.65 * k)
				off = it.liquidOff * C(0, -0.12 * (1 - k), 0)
			end
			e.p.Transparency = liquidK <= 0.02 and 1 or 0.12
		end
		e.p.CFrame = base * root * off
	end
end
local function hideItem(it: Item)
	for _, e in it.parts do e.p.Transparency = 1 end
end

-- SCREEN: letterbox, colour pulses at the edges, the reveal card
local gui: ScreenGui? = nil
local edges = {} :: { Frame }
local flash: Frame? = nil
local function buildGui(color: Color3)
	local g = Instance.new("ScreenGui")
	g.Name = "FormCine"; g.IgnoreGuiInset = true; g.DisplayOrder = 35; g.ResetOnSpawn = false
	g.Parent = lp:WaitForChild("PlayerGui")
	gui = g
	for _, top in { true, false } do
		local b = Grunge.frame(g, { Name = "Bar", BackgroundTransparency = 0, BackgroundColor3 = Color3.new(0, 0, 0), AnchorPoint = Vector2.new(0, top and 1 or 0),
			Position = UDim2.fromScale(0, top and 0 or 1), Size = UDim2.fromScale(1, 0.11), ZIndex = 20 })
		TweenService:Create(b, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Position = UDim2.fromScale(0, top and 0.11 or 0.89) }):Play()
	end
	table.clear(edges)
	for i, rot in { 0, 90, 180, 270 } do
		local f = Grunge.frame(g, { BackgroundTransparency = 0, BackgroundColor3 = color, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(i == 2 and 0.92 or (i == 4 and 0.08 or 0.5), i == 1 and 0.08 or (i == 3 and 0.92 or 0.5)),
			Size = (i % 2 == 1) and UDim2.fromScale(1.2, 0.3) or UDim2.fromScale(0.3, 1.2), ZIndex = 5 })
		local gr = Instance.new("UIGradient")
		gr.Rotation = rot + 90
		gr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
		gr.Parent = f
		f.BackgroundTransparency = 1
		edges[i] = f
	end
	flash = Grunge.frame(g, { BackgroundTransparency = 1, BackgroundColor3 = color, Size = UDim2.fromScale(1, 1), ZIndex = 6 })
	local blk = Grunge.frame(g, { Name = "Black", BackgroundTransparency = 0, BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 30 })
	TweenService:Create(blk, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
end
local function pulseEdges(amount: number)
	for _, f in edges do f.BackgroundTransparency = 1 - math.clamp(amount, 0, 0.85) end
end
local function doFlash(amount: number, t: number)
	local f = flash
	if not f then return end
	f.BackgroundTransparency = 1 - amount
	TweenService:Create(f, TweenInfo.new(t), { BackgroundTransparency = 1 }):Play()
end

-- the REVEAL card; returns when a button is pressed: "wear" | "keep" | "ok"
local function reveal(fm: Forms.Form, isNew: boolean, worn: boolean, prevId: string): string
	local g = gui :: ScreenGui
	local rar = Forms.rarityOf(fm)
	local card = Grunge.slab(g, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1.4, 0.47), Size = UDim2.fromScale(0.36, 0.56), ZIndex = 22 },
		Color3.fromRGB(21, 17, 15), 60 + fm.rarity, 6, false)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 0.95; ar.Parent = card
	TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back), { Position = UDim2.fromScale(0.95, 0.47) }):Play()
	Grunge.brush(card, { Position = UDim2.fromScale(0.06, 0.05), Size = UDim2.fromScale(0.55, 0.09), ZIndex = 23 }, rar.color:Lerp(Color3.new(0, 0, 0), 0.35), 88, 12, false)
	Grunge.text(card, { Text = rar.name .. " " .. (fm.kind == "stim" and "FIST FORM" or "BODY FORM"), Font = Grunge.TYPE, Position = UDim2.fromScale(0.08, 0.055),
		Size = UDim2.fromScale(0.52, 0.08), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 25 })
	local name = Grunge.text(card, { Text = fm.name, Font = Grunge.HORROR, Position = UDim2.fromScale(0.06, 0.16), Size = UDim2.fromScale(0.88, 0.17),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = fm.color, ZIndex = 25, Rotation = -1.5 })
	local nsc = Instance.new("UIScale"); nsc.Scale = 1.8; nsc.Parent = name
	TweenService:Create(nsc, TweenInfo.new(0.4, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	for i, line in Forms.lines(fm) do
		Grunge.text(card, { Text = line, Font = Grunge.FONT, Position = UDim2.fromScale(0.06, 0.34 + (i - 1) * 0.09), Size = UDim2.fromScale(0.88, 0.08),
			TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(150, 220, 110), ZIndex = 25 })
	end
	Grunge.text(card, { Text = fm.desc, Font = Grunge.TYPE, Position = UDim2.fromScale(0.06, 0.53), Size = UDim2.fromScale(0.88, 0.12), TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = Color3.fromRGB(200, 190, 170), ZIndex = 25 })
	local stamp = Grunge.text(card, { Text = isNew and "NEW!" or "ALREADY YOURS", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.8, 0.1),
		Size = UDim2.fromScale(isNew and 0.3 or 0.42, 0.1), TextColor3 = isNew and Color3.fromRGB(255, 210, 80) or Color3.fromRGB(180, 170, 150), Rotation = 10, ZIndex = 26 })
	local ssc = Instance.new("UIScale"); ssc.Scale = 2.5; ssc.Parent = stamp
	task.delay(0.5, function() TweenService:Create(ssc, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play() end)
	-- the buttons
	local picked: string? = nil
	local function btn(text: string, x: number, w: number, color: Color3, choice: string, seed: number)
		local b = Instance.new("TextButton")
		b.AutoButtonColor = false; b.BackgroundTransparency = 1; b.Text = ""; b.BorderSizePixel = 0
		b.Position = UDim2.fromScale(x, 0.72); b.Size = UDim2.fromScale(w, 0.16); b.ZIndex = 26; b.Parent = card
		Grunge.brush(b, { Size = UDim2.fromScale(1, 1), ZIndex = 26 }, color, seed, 12)
		Grunge.text(b, { Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.88, 0.55), ZIndex = 29 })
		b.Activated:Connect(function() if not picked then Sfx.play("Click"); picked = choice end end)
	end
	local prev = Forms.byId[prevId]
	local choosing = not worn and prev ~= nil and prev.id ~= fm.id
	if choosing then
		btn("WEAR IT", 0.05, 0.42, Color3.fromRGB(62, 118, 40), "wear", 140)
		btn("KEEP " .. (prev :: Forms.Form).name, 0.5, 0.46, Color3.fromRGB(38, 31, 27), "keep", 141)
	else
		btn(worn and "WEAR IT!" or "OK", 0.25, 0.5, Color3.fromRGB(62, 118, 40), "ok", 142)
	end
	if choosing then
		Grunge.text(card, { Text = "NOW: " .. (prev :: Forms.Form).name .. "  (" .. table.concat(Forms.lines(prev :: Forms.Form), ", ") .. ")", Font = Grunge.TYPE,
			Position = UDim2.fromScale(0.06, 0.9), Size = UDim2.fromScale(0.88, 0.05), TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color3.fromRGB(170, 160, 145), ZIndex = 25 })
	end
	local conn: RBXScriptConnection? = nil
	if RunService:IsStudio() then
		conn = lp:GetAttributeChangedSignal("DebugFormPick"):Connect(function()
			local v = lp:GetAttribute("DebugFormPick")
			if type(v) == "string" then picked = v end
		end)
	end
	local t0 = os.clock()
	while not picked do
		task.wait(0.05)
		if os.clock() - t0 > 45 then picked = choosing and "keep" or "ok" end
	end
	if conn then conn:Disconnect() end
	return picked :: string
end

-- play it. kind "stim" | "potion"; worn = the server already put it on (nothing was worn before)
function FC.play(kind: string, vialId: string, formId: string, isNew: boolean, worn: boolean, prevId: string, test: boolean?)
	local fm = Forms.byId[formId]
	if playing or not fm then return end
	local ch = lp.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not ch or not hrp then return end
	playing = true
	local v = Forms.vialById[vialId]
	local liquidColor = v and v.color or fm.color
	local color = fm.color
	local rarity = fm.rarity
	local big = rarity >= 4
	local hold = big and (rarity >= 5 and 1.0 or 0.5) or 0 -- (a longer build-up for the rare ones)
	-- face the seller (a code's reward: no vial, no seller: you stay facing where you were)
	local lobby = v and workspace:FindFirstChild("Lobby")
	local sellers = lobby and lobby:FindFirstChild("Sellers")
	local sm = sellers and sellers:FindFirstChild(kind == "stim" and "DocMercy" or "MotherMoth")
	local sp = sm and sm:FindFirstChild("Prompt", true) :: BasePart?
	local look = hrp.CFrame.LookVector
	if sp then
		local d = (sp.Position - hrp.Position) * Vector3.new(1, 0, 1)
		if d.Magnitude > 0.5 then look = d.Unit end
	end
	hrp.Anchored = true
	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
	local head = ch:FindFirstChild("Head") :: BasePart?
	local eyeY = head and (head.Position.Y - hrp.Position.Y + 0.15) or 1.6
	local eye = hrp.Position + Vector3.new(0, eyeY, 0)
	-- the arms in the character's own skin colour (darker, like the fight's hands)
	local bc = ch:FindFirstChildOfClass("BodyColors")
	local skin = ((bc and bc.RightArmColor3) or Color3.fromRGB(120, 88, 70)):Lerp(Color3.new(0, 0, 0), 0.35)
	local m = Instance.new("Model"); m.Name = "FormCineRig"; m.Parent = cam
	model = m
	local L, R = newArm("L", skin), newArm("R", skin)
	local item = kind == "stim" and jar(liquidColor) or bottle(liquidColor)
	local coat = mk("GooCoat", Vector3.new(0.52, 0.5, 0.58), liquidColor, Enum.Material.Neon); coat.Transparency = 1
	local emL, emR = {} :: { BasePart }, {} :: { BasePart }
	for i = 1, 7 do
		table.insert(emL, mk("Ember", Vector3.one * 0.1, color, Enum.Material.Neon)); emL[i].Transparency = 1
		table.insert(emR, mk("Ember", Vector3.one * 0.1, color, Enum.Material.Neon)); emR[i].Transparency = 1
	end
	local drop = mk("Drop", Vector3.one * 0.06, liquidColor, Enum.Material.Neon, Enum.PartType.Ball); drop.Transparency = 1
	local veinsL = veinLayout(11, -0.8)
	local veinsR = veinLayout(23, -0.8)
	-- the world around: the HUD off, a colour grade and a blur that pulse
	if HUD then HUD.setVisible(false) end
	if Fx then Fx.cineFov = 70 end
	local cc = Instance.new("ColorCorrectionEffect"); cc.Name = "FormCC"; cc.Parent = Lighting
	local blur = Instance.new("BlurEffect"); blur.Name = "FormBlur"; blur.Size = 0; blur.Parent = Lighting
	buildGui(color)
	local fovBase = 70
	local fovKick = 0
	local shakeAmt = 0
	local pitch = -0.3 -- (looking down at your arms)
	local t0 = os.clock()
	local freezeAt = RunService:IsStudio() and tonumber(lp:GetAttribute("DebugFormFreeze")) or nil
	local beats = {} :: { number }
	-- the timeline (seconds): stim / potion
	local T = kind == "stim"
		and { up = 0.9, twist = 1.5, pop = 1.65, rise = 2.15, leap = 2.55, drop = 2.8, change = 2.8, burst = 4.6 + hold }
		or { up = 0.9, cork = 1.35, drink = 1.7, drunk = 3.3, away = 3.7, change = 3.7, burst = 5.1 + hold }
	if kind == "stim" then beats = { 2.95, 3.5, 3.95, 4.3 } else beats = { 3.9, 4.5, 4.95 } end
	if hold > 0 then table.insert(beats, beats[#beats] + hold * 0.5); table.insert(beats, beats[#beats] + hold * 0.35) end
	local fired = {} :: { [string]: boolean }
	local function once(key: string, at: number, t: number, fn: () -> ())
		if not fired[key] and t >= at then fired[key] = true; fn() end
	end
	local doneT: number? = nil
	local spreadL, spreadR = -1, -1
	local burstK = 0
	local tremor = 0
	local stopped = false
	RunService:BindToRenderStep("FormCine", Enum.RenderPriority.Camera.Value + 3, function()
		if stopped then return end
		local now = os.clock()
		local t = now - t0
		if freezeAt and t > freezeAt then t = freezeAt; t0 = now - freezeAt end
		-- sounds and beats
		if kind == "stim" then
			once("twist1", T.up + 0.1, t, function() Sfx.play("Click", { PlaybackSpeed = 0.7, Volume = 0.6 }) end)
			once("twist2", T.up + 0.35, t, function() Sfx.play("Click", { PlaybackSpeed = 0.75, Volume = 0.6 }) end)
			once("pop", T.pop - 0.02, t, function() Sfx.play("FormCork"); Sfx.play("FormHiss"); fovKick = -3 end)
			once("ooze", T.pop + 0.15, t, function() Sfx.play("FormSquish", { PlaybackSpeed = 0.8 }) end)
			once("splat", T.leap, t, function() Sfx.play("FormSquish"); if Fx then Fx.shake(0.14) end; fovKick = -5 end)
			once("glass", T.drop + 0.4, t, function() Sfx.play("Glass", { Volume = 0.5, PlaybackSpeed = 1.2 }) end)
			once("rise", T.change, t, function() Sfx.play("FormRise") end)
			once("crack", T.change + 0.85, t, function() Sfx.play("FormCrack"); if Fx then Fx.shake(0.2) end end)
			once("knuckle", T.burst - 0.35, t, function() Sfx.play("FormKnuckle") end)
		else
			once("cork", T.cork - 0.05, t, function() Sfx.play("FormCork") end)
			once("gulp", T.drink + 0.3, t, function() Sfx.play("FormGulp") end)
			once("glass", T.away + 0.35, t, function() Sfx.play("Glass", { Volume = 0.5, PlaybackSpeed = 1.2 }) end)
			once("magic", T.change, t, function() Sfx.play("FormMagic") end)
			once("rise", T.change + 0.4, t, function() Sfx.play("FormRise2") end)
		end
		for i, b in beats do
			once("beat" .. i, b, t, function()
				Sfx.play("FormThump", { PlaybackSpeed = kind == "stim" and 0.8 or 0.62, Volume = 0.7 + i * 0.08 })
				task.delay(0.16, function() Sfx.play("FormThump", { PlaybackSpeed = kind == "stim" and 0.95 or 0.72, Volume = 0.5 }) end)
				fovKick = -5 - i
				pulseEdges(0.35 + i * 0.08)
				if Fx then Fx.shake(0.05 + i * 0.03) end
			end)
		end
		once("burst", T.burst, t, function()
			Sfx.play("FormZap"); Sfx.play("PunchHeavy", { Volume = 1, PlaybackSpeed = 0.5 })
			if rarity >= 5 then Sfx.play("Thunder", { Volume = 0.8, PlaybackSpeed = 1.1 }) end
			doFlash(rarity >= 5 and 0.85 or 0.6, 0.8)
			fovKick = 14
			if Fx then Fx.shake(0.35 + rarity * 0.07) end
			pulseEdges(0.8)
		end)
		fovKick += (0 - fovKick) * math.min(1, 6 / 60)
		for _, f in edges do f.BackgroundTransparency = math.min(1, f.BackgroundTransparency + 0.012) end
		-- the camera: at the eyes, looking down at the arms (up while you drink)
		local wantPitch = -0.3
		if kind == "potion" then
			local up = ss(seg(t, T.drink, T.drink + 0.5)) * (1 - ss(seg(t, T.drunk, T.away)))
			wantPitch = -0.3 + up * 0.75
		end
		if t > T.burst then wantPitch = -0.18 end
		pitch += (wantPitch - pitch) * 0.12
		tremor = (t > T.change and t < T.burst + 0.2) and (0.3 + 0.7 * seg(t, T.change, T.burst)) * (big and 1.4 or 1) or 0
		shakeAmt = tremor * 0.012
		local base = CFrame.lookAt(eye, eye + look) * A(pitch, 0, 0)
			* C((math.random() - 0.5) * shakeAmt, (math.random() - 0.5) * shakeAmt, 0)
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = base
		cam.Focus = base * C(0, 0, -30)
		if Fx then Fx.cineFov = fovBase + fovKick end
		for _, d in ch:GetDescendants() do
			if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
		end
		-- the arms (camera space)
		local tr = function(n: number): CFrame
			return C(math.sin(now * 47 + n) * 0.012 * tremor, math.cos(now * 53 + n) * 0.012 * tremor, 0)
		end
		local liquidK = 1
		local guardL = C(-0.42, -0.55, -1.5) * A(0.25, 0.15, 0.08)
		local guardR = C(0.42, -0.55, -1.5) * A(0.25, -0.15, -0.08)
		local burstUp = ss(seg(t, T.burst - 0.45, T.burst))
		if kind == "stim" then
			-- the left hand holds the jar up in front of you
			local lIn = C(-0.6, -1.5, -1.2) * A(0.4, 0.4, 0)
			local lHome = C(-0.12, -0.62, -1.5) * A(0.12, 0.2, 0)
			local lCF = lerpCF(lIn, lHome, ss(seg(t, 0, T.up)))
			local jarHome = lHome * C(0, 0.46, -0.05)
			-- it drops the jar, goes down, then comes back up as a fist for the burst
			local dropK = seg(t, T.drop, T.drop + 0.6)
			lCF = lerpCF(lCF, C(-0.5, -1.3, -1.2), ss(seg(t, T.drop + 0.1, T.drop + 0.5)))
			lCF = lerpCF(lCF, guardL, ss(seg(t, T.change + 0.9, T.burst))) * tr(1)
			placeArm(L, lCF, base, 1)
			-- the right hand: on the lid, twists it, the lid pops off; then it waits over the jar's mouth
			local rIn = C(0.8, -1.4, -1.1) * A(0.4, -0.4, 0)
			local rLid = jarHome * C(0.1, 0.52, 0.02) * A(0, 0, -0.25)
			local twist = seg(t, T.up, T.twist)
			local rCF = lerpCF(rIn, rLid, ss(seg(t, 0.15, T.up))) * A(0, math.sin(twist * math.pi * 4) * 0.25, 0)
			local popK = ss(seg(t, T.twist, T.pop + 0.25))
			local rReady = jarHome * C(0.06, 0.75, -0.02) * A(-0.35, 0, -0.15)
			rCF = lerpCF(rCF, rCF * C(0.18, 0.12, 0), popK)
			rCF = lerpCF(rCF, rReady, ss(seg(t, T.pop + 0.2, T.rise)))
			-- the goo on the fist: it clenches, shakes, then comes up into the guard
			local clench = ss(seg(t, T.leap, T.leap + 0.5))
			rCF = rCF * C(0, clench * 0.05, 0) * A(-clench * 0.15, 0, 0)
			rCF = lerpCF(rCF, guardR, ss(seg(t, T.leap + 0.6, T.burst))) * tr(2)
			placeArm(R, rCF, base, -1)
			-- the lid: turns with the hand, then flies off up and to the right
			local lidCF: CFrame? = nil
			if t > T.up then
				local lid0 = jarHome * C(0, 0.33, 0) * A(0, -twist * math.pi * 3, 0)
				local fly = seg(t, T.pop - 0.05, T.pop + 0.6)
				lidCF = lid0 * C(0.9 * fly, 1.2 * fly - 0.9 * fly * fly, -0.2 * fly) * A(fly * 5, fly * 2, fly * 3)
				if fly >= 1 then lidCF = C(0, -50, 0) end
			end
			-- the jar: the goo's level drops while it climbs out; then the jar falls
			liquidK = 1 - 0.75 * ss(seg(t, T.pop, T.leap))
			local jarCF = jarHome
			if dropK > 0 then jarCF = jarHome * C(0.15 * dropK, -1.8 * dropK * dropK, 0.1 * dropK) * A(dropK * 2.2, 0, dropK * 1.4) end
			if dropK < 1 then placeItem(item, base, jarCF, liquidK, lidCF) else hideItem(item) end
			-- the goo itself: a blob rising out of the mouth, wobbling, then it leaps onto the right fist
			local riseK = seg(t, T.pop, T.rise)
			local leapK = seg(t, T.rise, T.leap)
			if riseK > 0 and leapK < 1 then
				local mouth = jarHome * C(0, 0.32 + 0.3 * ss(riseK), 0)
				local blobCF = mouth
				-- (it flies to the fist, in camera space)
				if leapK > 0 then blobCF = mouth:Lerp(base:Inverse() * R.fist.CFrame, ss(leapK)) end
				local wob = 1 + math.sin(now * 22) * 0.12
				drop.Size = Vector3.new(0.34 * wob, 0.3 / wob, 0.34 * wob) * (0.35 + 0.65 * riseK)
				drop.CFrame = base * blobCF
				drop.Color = liquidColor
				drop.Transparency = 0.1
			else
				drop.Transparency = 1
			end
			-- once it lands: the fist is coated in it, fading as it soaks in
			if t >= T.leap then
				coat.CFrame = R.fist.CFrame
				coat.Transparency = 0.25 + 0.6 * seg(t, T.leap + 0.3, T.burst + 0.3)
			else
				coat.Transparency = 1
			end
			spreadR = t > T.leap and (t - T.leap) * (big and 0.6 or 0.8) or -1
			spreadL = t > T.change + 0.9 and (t - T.change - 0.9) * 1.2 or -1
		else
			-- the bottle in the right hand, the left pulls the cork
			local rIn = C(0.7, -1.4, -1.1)
			local rHold = C(0.36, -0.48, -1.35) * A(0.1, -0.15, 0)
			local rCF = lerpCF(rIn, rHold, ss(seg(t, 0, T.up)))
			-- drinking: the bottle comes to the mouth, tipped toward you
			local drinkK = ss(seg(t, T.drink - 0.2, T.drink + 0.4))
			local rDrink = C(0.08, -0.32, -0.72) * A(1.2, 0, 0.15)
			rCF = lerpCF(rCF, rDrink, drinkK)
			local awayK = ss(seg(t, T.drunk, T.away))
			rCF = lerpCF(rCF, C(0.7, -1.6, -1.0) * A(0.6, 0, 0.8), awayK)
			rCF = lerpCF(rCF, guardR, ss(seg(t, T.change + 0.4, T.burst))) * tr(2)
			liquidK = 1 - ss(seg(t, T.drink + 0.2, T.drunk))
			local bCF = rCF * C(0, 0.2, -0.05) -- (upright in the fist, the neck up)
			-- the cork: the left hand pinches it and pulls it out
			local lIn = C(-0.9, -1.3, -1.1)
			local corkAt = rHold * C(0, 0.8, -0.05)
			local lPinch = corkAt * C(-0.18, 0.05, 0.12) * A(0, 0, -0.5)
			local lCF = lerpCF(lIn, lPinch, ss(seg(t, 0.3, T.cork - 0.15)))
			local pull = ss(seg(t, T.cork - 0.15, T.cork + 0.1))
			lCF = lCF * C(-0.25 * pull, 0.2 * pull, 0)
			lCF = lerpCF(lCF, C(-0.9, -1.5, -1.0), ss(seg(t, T.cork + 0.2, T.cork + 0.55)))
			lCF = lerpCF(lCF, guardL, ss(seg(t, T.change + 0.4, T.burst))) * tr(1)
			placeArm(L, lCF, base, 1)
			placeArm(R, rCF, base, -1)
			local corkCF: CFrame? = nil
			if pull > 0 then corkCF = lCF * C(0.18, -0.05, -0.12) end
			if awayK < 1 then placeItem(item, base, bCF, liquidK, corkCF) else hideItem(item) end
			if t > T.cork + 0.55 and item.cork then item.cork.Transparency = 1 end
			-- a puff of coloured smoke out of the neck
			local pk = seg(t, T.cork, T.cork + 0.6)
			if pk > 0 and pk < 1 then
				drop.Transparency = 0.3 + pk * 0.7
				drop.Size = Vector3.one * (0.15 + pk * 0.5)
				drop.CFrame = base * corkAt * C(0, 0.1 + pk * 0.4, 0)
				drop.Color = liquidColor
			else
				drop.Transparency = 1
			end
			-- the air ripples while it takes hold
			blur.Size = t > T.change and (t < T.burst + 0.3) and (4 + math.sin(t * 9) * 3) * (1 - seg(t, T.burst, T.burst + 0.3)) or 0
			spreadL = t > T.change + 0.2 and (t - T.change - 0.2) * 1.1 or -1
			spreadR = spreadL - 0.1
		end
		-- veins, glow, embers, colour grade
		local glow = burstUp
		placeVeins(L, veinsL, spreadL, color, glow)
		placeVeins(R, veinsR, spreadR, color, glow)
		local formOn = ss(seg(t, T.change + 0.3, T.burst))
		for _, a in { L, R } do
			a.light.Color = color
			a.light.Range = 6 * formOn
			a.light.Brightness = 1.5 + burstK * 3
			-- (the skin takes a little of the form's colour)
			local tint = skin:Lerp(color, (0.12 + (big and 0.12 or 0)) * formOn)
			a.fist.Color = tint; a.arm.Color = tint; a.thumb.Color = tint
		end
		burstK = math.max(0, 1 - seg(t, T.burst, T.burst + 0.6)) * (t >= T.burst and 1 or 0)
		embers(emL, L.fist, color, now, seg(t, T.burst - 0.2, T.burst + 0.2))
		embers(emR, R.fist, color, now, seg(t, T.burst - 0.2, T.burst + 0.2))
		cc.TintColor = Color3.new(1, 1, 1):Lerp(color, 0.25 * formOn * (0.6 + 0.4 * math.sin(t * 5)) + 0.35 * burstK)
		cc.Contrast = 0.1 * formOn
		cc.Saturation = -0.1 + 0.25 * formOn
		if not doneT and t >= T.burst + 0.4 then doneT = t end
	end)
	-- wait for the burst, then the card
	while not doneT do task.wait(0.05) end
	local pick = reveal(fm, isNew, worn, prevId)
	if pick == "wear" and not test then (Remotes :: any).Forms:FireServer("equip", fm.id) end
	-- out: black, everything back
	local g = gui
	if g then
		local blk = g:FindFirstChild("Black") :: Frame?
		if blk then TweenService:Create(blk, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play() end
	end
	task.wait(0.35)
	stopped = true
	RunService:UnbindFromRenderStep("FormCine")
	m:Destroy(); model = nil
	cc:Destroy(); blur:Destroy()
	hrp.Anchored = false
	for _, d in ch:GetDescendants() do
		if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then d.LocalTransparencyModifier = 0 end
	end
	cam.CameraType = Enum.CameraType.Custom
	if Fx then Fx.cineFov = nil end
	if HUD then HUD.setVisible(true) end
	if g then
		local blk = g:FindFirstChild("Black") :: Frame?
		for _, c in g:GetChildren() do if c ~= blk then c:Destroy() end end
		if blk then TweenService:Create(blk, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play() end
		task.delay(0.45, function() g:Destroy() end)
	end
	gui = nil
	playing = false
	if FC.onDone then task.spawn(FC.onDone :: () -> ()) end
end

if RunService:IsStudio() then
	lp:GetAttributeChangedSignal("DebugFormCine"):Connect(function()
		local id = lp:GetAttribute("DebugFormCine")
		local fm = type(id) == "string" and Forms.byId[id] or nil
		if not fm then return end
		local vial = Forms.vialsOf(fm.kind, fm.set)[math.clamp(fm.rarity - 1, 1, 4)]
		task.spawn(FC.play, fm.kind, vial.id, fm.id, true, false, lp:GetAttribute(fm.kind == "stim" and "FormStim" or "FormPotion") or "", true)
	end)
end

return FC
