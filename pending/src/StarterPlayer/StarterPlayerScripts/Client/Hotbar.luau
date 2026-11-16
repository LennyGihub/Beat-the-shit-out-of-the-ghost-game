-- Run hotbar: 5 item slots (keys 1-5 / L1-R1 / tap a slot, same key again = fists, drop key = drop), item use + its first-person feel.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Items = require(RS.Shared.Items)
local Grunge = require(script.Parent.Grunge)
local VM = require(script.Parent.Viewmodel)
local Sfx = require(script.Parent.Sfx)
local SawAudio = require(script.Parent.SawAudio)
local Platform = require(script.Parent.Platform)
local Remotes = RS:WaitForChild("Remotes")

local Hotbar = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local SLOTS = 5
local slots = {} :: { { id: string, uses: number }? }
local sel = 0
local frames = {} :: { any }
local root: Frame
local lastUse = {} :: { [string]: number }
local spraying = false
local sprayEmitter: ParticleEmitter? = nil
local sprayAtt: Attachment? = nil
-- flashlight: a light cone + real spot light instead of smoke; blowers: a vacuum loop
local beamEnd: Attachment? = nil
local beam: Beam? = nil
local core: Beam? = nil
local spot: SpotLight? = nil
local vacSound: Sound? = nil
-- the flamethrower's voice: a pitched-up fire loop (the hiss) over a low engine loop (the roar)
local flameHiss: Sound? = nil
local flameRoar: Sound? = nil
local FIRE_COLORS = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 245, 190)), ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 170, 40)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(230, 70, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 30, 25)) })

local function parse()
	slots = {}
	local i = 0
	for chunk in string.gmatch((lp:GetAttribute("Inv") or "") .. ",", "([^,]*),") do
		i += 1
		if i > SLOTS then break end
		local id, uses = string.match(chunk, "^([^:]+):(%-?%d+)$")
		slots[i] = id and { id = id, uses = tonumber(uses) :: number } or nil
	end
	sel = lp:GetAttribute("Sel") or 0
end

function Hotbar.current(): any
	local s = slots[sel]
	return s and Items.byId[s.id] or nil
end

local function refresh()
	parse()
	local any = false
	for n = 1, SLOTS do
		local f = frames[n]
		local s = slots[n]
		local it = s and Items.byId[s.id]
		if it then
			any = true
			local rar = Items.rarity[it.rarity]
			f.name.Text = string.upper(it.name)
			f.uses.Text = it.kind == "spray" and (math.ceil(s.uses / 10) .. "s") or ("x" .. s.uses)
			f.edge.BackgroundColor3 = rar.color
			f.box.BackgroundTransparency = 0.15
		else
			f.name.Text = ""; f.uses.Text = ""
			f.edge.BackgroundColor3 = Color3.fromRGB(60, 54, 50)
			f.box.BackgroundTransparency = 0.5
		end
		local on = n == sel and it ~= nil
		f.box.Rotation = on and -3 or (n % 2 == 0 and 1 or -1)
		f.mark.Visible = on
		f.scale.Scale = on and 1.12 or 1
	end
	root.Visible = any and lp:GetAttribute("InMatch") == true
	VM.setItem(Hotbar.current())
end

function Hotbar.select(n: number)
	if n == sel or not slots[n] then n = 0 end
	Remotes.Select:FireServer(n)
	Sfx.play("Click", { Volume = 0.3 })
end

-- controller L1 / R1: the previous / next filled slot (past the last one = fists)
function Hotbar.cycle(dir: number)
	local n = sel
	for _ = 1, SLOTS + 1 do
		n = (n + dir) % (SLOTS + 1)
		if n == 0 or slots[n] then break end
	end
	if n ~= sel then
		Remotes.Select:FireServer(n)
		Sfx.play("Click", { Volume = 0.3 })
	end
end

function Hotbar.drop()
	if sel > 0 and slots[sel] then Remotes.Drop:FireServer(sel) end
end

-- melee hit sounds: played on the swing's impact frame, only if the server confirms the hit
-- (its answer normally arrives before the impact frame; a late answer plays at once)
local pendingHit: { id: string, impact: number, confirmed: boolean, played: boolean }? = nil
local function playHit(id: string)
	local it = Items.byId[id]
	local sfx = it and it.sfx
	if sfx and sfx.hit then Sfx.play(sfx.hit, { PlaybackSpeed = (sfx.speed or 1) * (0.95 + math.random() * 0.1) }) end
end
function Hotbar.confirmHit(id: string)
	local p = pendingHit
	if not p or p.id ~= id or p.played then return end
	p.confirmed = true
	local late = os.clock() - p.impact
	if late >= 0 and late < 0.4 then p.played = true; playHit(id) end
end

-- left click / hold with an item in hand. Returns true if an item handled it.
-- charge (0..1): a charged melee swing released from a hold (Input / Charge.luau)
function Hotbar.primary(charge: number?): boolean
	local it = Hotbar.current()
	if not it or not lp:GetAttribute("InMatch") then return false end
	if it.kind == "spray" then return true end -- handled while held (see update)
	local now = os.clock()
	local cd = it.cd or 0.6
	if now - (lastUse[it.id] or 0) < cd then return true end
	lastUse[it.id] = now
	VM.use()
	if it.id == "Chainsaw" then
		SawAudio.used() -- engine revs instead of a whoosh per tick
	elseif it.kind == "melee" and it.sfx and it.sfx.use then
		Sfx.play(it.sfx.use, { PlaybackSpeed = 0.95 + math.random() * 0.1 })
	elseif it.kind == "melee" then
		Sfx.play("Whoosh", { PlaybackSpeed = (it.cd > 0.6 and 0.55 or 0.75) + math.random() * 0.25 })
	elseif it.kind == "throw" or it.kind == "trap" then
		Sfx.play("Whoosh", { PlaybackSpeed = 0.6 })
	end
	if it.kind == "melee" and it.id ~= "Chainsaw" and it.sfx and it.sfx.hit then
		local p = { id = it.id, impact = now + VM.impactTime(), confirmed = false, played = false }
		pendingHit = p
		task.delay(VM.impactTime(), function()
			if p.confirmed and not p.played then p.played = true; playHit(p.id) end
		end)
	end
	if charge and charge > 0 then Sfx.play("Whoosh", { PlaybackSpeed = 0.45 - charge * 0.1, Volume = 1 + charge * 0.5 }) end
	Remotes.Use:FireServer(sel, cam.CFrame.LookVector, charge)
	return true
end

local function setSpray(on: boolean, it)
	spraying = on
	VM.setSpraying(on)
	if on and it then
		if not sprayAtt then
			sprayAtt = Instance.new("Attachment"); sprayAtt.Parent = workspace.Terrain
			local pe = Instance.new("ParticleEmitter")
			pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
			pe.Speed = NumberRange.new(30, 45); pe.SpreadAngle = Vector2.new(10, 10); pe.Lifetime = NumberRange.new(0.35, 0.55)
			pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 3) })
			pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
			pe.Rate = 70; pe.LightEmission = 0.4; pe.Parent = sprayAtt
			sprayEmitter = pe
		end
		local pe = sprayEmitter :: ParticleEmitter
		local reach = it.range or 18 -- the spray visibly reaches as far as it hits
		pe.Speed = NumberRange.new(reach * 1.7, reach * 2.5)
		local fire = it.id == "Flamethrower"
		-- real flames for the flamethrower, smoke-like puffs for the others
		pe.Texture = fire and "rbxasset://textures/particles/fire_main.dds" or "rbxasset://textures/particles/smoke_main.dds"
		pe.Color = fire and FIRE_COLORS or ColorSequence.new(it.particle or Color3.new(1, 1, 1))
		pe.LightEmission = fire and 1 or 0.3
		pe.Size = fire and NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(0.5, 3.2), NumberSequenceKeypoint.new(1, 5) })
			or NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 3) })
		pe.RotSpeed = NumberRange.new(-120, 120); pe.Rotation = NumberRange.new(0, 360)
		pe.Rate = fire and 110 or 70
		if it.id == "UVFlashlight" then
			-- a light beam, not smoke
			pe.Enabled = false
			if not beam then
				beamEnd = Instance.new("Attachment"); (beamEnd :: Attachment).Parent = workspace.Terrain
				local b = Instance.new("Beam")
				b.Attachment0 = sprayAtt; b.Attachment1 = beamEnd
				b.FaceCamera = true; b.LightEmission = 1; b.LightInfluence = 0; b.Segments = 1
				b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.6, 0.72), NumberSequenceKeypoint.new(1, 0.95) })
				b.Parent = workspace.Terrain
				beam = b
				-- a brighter, narrow core inside the cone
				local c = b:Clone()
				c.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(0.7, 0.6), NumberSequenceKeypoint.new(1, 0.9) })
				c.Parent = workspace.Terrain
				core = c
				local s = Instance.new("SpotLight")
				s.Face = Enum.NormalId.Top; s.Angle = 38; s.Brightness = 14; s.Shadows = true
				s.Parent = sprayAtt
				spot = s
			end
			local b, s = beam :: Beam, spot :: SpotLight
			b.Color = ColorSequence.new(it.color); b.Width0 = 0.7; b.Width1 = reach * 0.5
			b.Enabled = true
			local c = core :: Beam
			c.Color = ColorSequence.new(it.color:Lerp(Color3.new(1, 1, 1), 0.45)); c.Width0 = 0.3; c.Width1 = reach * 0.16
			c.Enabled = true
			s.Color = it.color; s.Range = reach * 1.3; s.Enabled = true
		else
			pe.Enabled = true
			if beam then beam.Enabled = false end
			if core then core.Enabled = false end
			if spot then spot.Enabled = false end
		end
		-- the flamethrower: a whump when it lights, then a hissing roar for as long as the trigger is held
		if fire and not flameHiss then
			Sfx.play("Whoosh", { PlaybackSpeed = 0.55, Volume = 1.6 })
			Sfx.play("Breaker", { PlaybackSpeed = 1.6, Volume = 0.5 })
			flameHiss = Sfx.loop("Flamethrower", { PlaybackSpeed = 1.9, Volume = 1.5 })
			flameRoar = Sfx.loop("PlaneEngine", { PlaybackSpeed = 0.5, Volume = 0.4 })
		end
		-- wind items sound like a vacuum
		if (it.id == "LeafBlower" or it.id == "ShopVac") and not vacSound then
			vacSound = Sfx.loop("Vacuum", { PlaybackSpeed = it.id == "LeafBlower" and 1.15 or 0.95 })
		end
	else
		if sprayEmitter then sprayEmitter.Enabled = false end
		if beam then beam.Enabled = false end
		if core then core.Enabled = false end
		if spot then spot.Enabled = false end
		if vacSound then vacSound:Destroy(); vacSound = nil end
		if flameHiss then
			flameHiss:Destroy(); flameHiss = nil
			if flameRoar then flameRoar:Destroy(); flameRoar = nil end
			Sfx.play("Whoosh", { PlaybackSpeed = 1.2, Volume = 0.6 }) -- the flame cuts out
		end
	end
end

local function update()
	local it = Hotbar.current()
	-- touchHold = the hit input is held (mouse / key / R2 / the HIT button, set by Input)
	local holding = Hotbar.touchHold == true
		or (RunService:IsStudio() and lp:GetAttribute("DebugSpray") == true) -- Studio test hook: hold the trigger
	local aiming = UIS.MouseBehavior == Enum.MouseBehavior.LockCenter or Platform.mode() ~= "keyboard" or lp:GetAttribute("DebugSpray") == true
	if it and it.kind == "spray" and holding and lp:GetAttribute("InMatch") and aiming then
		setSpray(true, it)
		local tip = VM.itemTip()
		if sprayAtt and tip then sprayAtt.WorldCFrame = CFrame.lookAt(tip, tip + cam.CFrame.LookVector) * CFrame.Angles(-math.pi / 2, 0, 0) end
		if beamEnd and tip then
			-- the beam stops at the first wall
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Exclude
			rp.FilterDescendantsInstances = { lp.Character, cam }
			local r = workspace:Raycast(tip, cam.CFrame.LookVector * (it.range or 30), rp)
			beamEnd.WorldPosition = r and r.Position or (tip + cam.CFrame.LookVector * (it.range or 30))
		end
		local now = os.clock()
		if now - (lastUse[it.id] or 0) >= 0.1 then
			lastUse[it.id] = now
			Remotes.Use:FireServer(sel, cam.CFrame.LookVector)
		end
	elseif spraying then
		setSpray(false)
	end
end

function Hotbar.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Hotbar"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
	gui.Parent = lp:WaitForChild("PlayerGui")
	root = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromScale(0.36, 0.1), Visible = false })
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 5.6; ar.Parent = root
	local list = Instance.new("UIListLayout"); list.FillDirection = Enum.FillDirection.Horizontal; list.Padding = UDim.new(0.012, 0)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center; list.Parent = root
	for n = 1, SLOTS do
		local holder = Grunge.frame(root, { Size = UDim2.fromScale(0.19, 1), LayoutOrder = n })
		local box = Grunge.frame(holder, { BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(24, 19, 16), Size = UDim2.fromScale(1, 1) })
		local stroke = Instance.new("UIStroke"); stroke.Color = Grunge.INK; stroke.Thickness = 3; stroke.Parent = box
		local edge = Grunge.frame(box, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(60, 54, 50), Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5) })
		local num = Grunge.text(box, { Text = tostring(n), Position = UDim2.fromScale(0.05, 0.02), Size = UDim2.fromScale(0.3, 0.3), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 190, 170) })
		local name = Grunge.text(box, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.92, 0.36) })
		local uses = Grunge.text(box, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(0.95, 0, 0.92, -4), Size = UDim2.fromScale(0.5, 0.26), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 220, 110) })
		local mark = Grunge.frame(box, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(190, 25, 20), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -4), Size = UDim2.new(0.6, 0, 0, 6), Rotation = -3, Visible = false })
		local scale = Instance.new("UIScale"); scale.Parent = holder
		-- tap a slot to hold that item (phones; also clickable when the mouse is free)
		local tap = Instance.new("TextButton")
		tap.Text = ""; tap.BackgroundTransparency = 1; tap.Size = UDim2.fromScale(1, 1); tap.ZIndex = 10; tap.Selectable = false
		tap.Parent = holder
		tap.Activated:Connect(function() Hotbar.select(n) end)
		local _ = num
		frames[n] = { box = box, edge = edge, name = name, uses = uses, mark = mark, scale = scale }
	end
	local help = Grunge.text(root, { Text = "[1-5] SWAP   [X] DROP", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 2), Size = UDim2.fromScale(0.6, 0.22), TextColor3 = Color3.fromRGB(170, 160, 145) })
	local function helpText()
		local m = Platform.mode()
		help.Text = m == "gamepad" and "[L1 / R1] SWAP   [D-PAD DOWN] DROP" or (m == "touch" and "TAP A SLOT TO SWAP" or ("[1-5] SWAP   " .. Platform.label("Drop") .. " DROP"))
	end
	helpText()
	Platform.changed:Connect(helpText)
	Hotbar.refreshHelp = helpText
	lp:GetAttributeChangedSignal("Inv"):Connect(refresh)
	lp:GetAttributeChangedSignal("Sel"):Connect(refresh)
	lp:GetAttributeChangedSignal("InMatch"):Connect(refresh)
	refresh()
	local keys = { [Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5 }
	UIS.InputBegan:Connect(function(input, processed)
		if processed or not lp:GetAttribute("InMatch") then return end
		local n = keys[input.KeyCode]
		if n then Hotbar.select(n) end -- drop is a rebindable action in Input
	end)
	RunService.Heartbeat:Connect(update)
	if RunService:IsStudio() then -- Studio test hook: changing player attribute DebugUse = one click with the held item
		lp:GetAttributeChangedSignal("DebugUse"):Connect(function() Hotbar.primary() end)
	end
end

return Hotbar
