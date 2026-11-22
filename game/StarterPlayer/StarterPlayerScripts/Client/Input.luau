-- Controls: click = punch (or throw while carrying), E = lift / throw furniture (or the WEAK monster: a x5 combo), Q = ultimate, Shift = sprint, X = drop,
-- R = swap ultimate (Double Ultimate pass), P = settings (keyboard keys are rebindable in Settings). Controller: R2 / L2 / Y / L3, L1-R1 items, D-pad down drop,
-- D-pad left settings, D-pad up PLAY in the lobby. Phones: TouchControls buttons.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local CS = game:GetService("CollectionService")
local Config = require(RS.Shared.Config)
local Remotes = RS:WaitForChild("Remotes")
local VM = require(script.Parent.Viewmodel)
local HUD = require(script.Parent.HUD)
local Sfx = require(script.Parent.Sfx)
local Hotbar = require(script.Parent.Hotbar)
local Platform = require(script.Parent.Platform)
local Settings = require(script.Parent.Settings)
local SettingsUI = require(script.Parent.SettingsUI)
local TouchControls = require(script.Parent.TouchControls)
local Charge = require(script.Parent.Charge)

local Input = {}
Input.openPlay = nil :: (() -> ())? -- set by ClientMain (lobby PLAY window)
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local lastPunch = 0
local sprinting = false
local shopOpen = false
local lastHint = 0

function Input.setShopOpen(on: boolean) shopOpen = on end

local function look(): Vector3 return cam.CFrame.LookVector end

-- furniture you are looking at (or right in front of you). On touch controls: from far away (Config.Mobile.LiftRange,
-- checked again by the server), and roughly looking at it is enough.
local function aimedFurniture(): Model?
	local f = workspace:FindFirstChild("Mansion") and workspace.Mansion:FindFirstChild("Furniture")
	if not f then return nil end
	local mobile = Platform.mode() == "touch"
	local reach = mobile and Config.Mobile.LiftRange or Config.Carry.Range
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { f }
	local r = workspace:Raycast(cam.CFrame.Position, look() * (reach + 2), rp)
	local function modelOf(p: Instance): Model?
		local m: Instance? = p
		while m and m.Parent ~= f do m = m.Parent end
		return m :: Model?
	end
	if r then
		local m = modelOf(r.Instance)
		if m and CS:HasTag(m, "Furniture") and not m:GetAttribute("CarriedBy") then return m end
	end
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return nil end
	local best, bestD = nil, 7
	-- touch: else the piece nearest to the middle of the screen, up to the far reach, with nothing of the house in
	-- the way
	local far, farDot = nil, 0.86
	local structure = workspace.Mansion:FindFirstChild("Structure")
	local sp: RaycastParams? = nil
	if mobile and structure then
		sp = RaycastParams.new()
		sp.FilterType = Enum.RaycastFilterType.Include
		sp.FilterDescendantsInstances = { structure }
	end
	local eye = cam.CFrame.Position
	for _, m in f:GetChildren() do
		if m:IsA("Model") and CS:HasTag(m, "Furniture") and not m:GetAttribute("CarriedBy") then
			local c = m:GetBoundingBox().Position
			local to = c - hrp.Position
			local d = Vector3.new(to.X, 0, to.Z).Magnitude
			if d < bestD and look():Dot(to.Unit) > 0.3 then best, bestD = m, d end
			if mobile and to.Magnitude <= reach then
				local fromEye = c - eye
				local dot = fromEye.Magnitude > 0.5 and look():Dot(fromEye.Unit) or 0
				if dot > farDot and not (sp and workspace:Raycast(eye, fromEye, sp)) then far, farDot = m, dot end
			end
		end
	end
	return best or far
end

-- the monster, when it is WEAK (a x5 combo: Config.Weak) and close enough to lift (the server checks again)
local function weakMonster(): Model?
	local g = workspace:FindFirstChild("Ghost")
	if not g or not g:IsA("Model") or g:GetAttribute("State") ~= "Weak" then return nil end
	local r = g:FindFirstChild("HumanoidRootPart") :: BasePart?
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not r or not hrp then return nil end
	local reach = (Platform.mode() == "touch" and Config.Mobile.LiftRange or Config.Carry.Range) + 4
	if (r.Position - hrp.Position).Magnitude > reach then return nil end
	return g
end

local triggerHeld = false -- the hit button / key / trigger is held down (keep hitting, keep spraying)

local function setHeld(on: boolean)
	triggerHeld = on
	Hotbar.touchHold = on
end

-- charge (0..1) = a charged punch thrown on release (Charge.luau); nil = a normal tap
local function punch(charge: number?)
	if shopOpen then return end
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	if lp:GetAttribute("Carrying") then
		Remotes.Throw:FireServer(look())
		VM.slam()
		return
	end
	if Hotbar.primary(charge) then return end
	local now = os.clock()
	if now - lastPunch < Config.Punch.Cooldown then return end
	local c = charge or 0
	if (lp:GetAttribute("Stamina") or 100) < Config.Punch.StaminaCost * (1 + c * Config.Charge.StaminaBonus) then
		HUD.flash(Color3.fromRGB(120, 110, 40), 0.2)
		return
	end
	lastPunch = now
	VM.punch((lp:GetAttribute("Combo") or 0) + 1)
	if c > 0 then
		Sfx.play("Whoosh", { PlaybackSpeed = 0.55 - c * 0.15, Volume = 1 + c * 0.5 })
	else
		Sfx.play("Whoosh", { PlaybackSpeed = 0.9 + math.random() * 0.3 })
	end
	Remotes.Punch:FireServer(look(), charge)
end

-- what the hit button charges right now: "fist" or a melee item's id (+ its cooldown); nil = can't charge
-- (guns, sprays, throwables, the chainsaw keep hold-to-repeat)
local function chargeable(): (string?, number)
	if not lp:GetAttribute("InMatch") or lp:GetAttribute("Carrying") or shopOpen then return nil, 0 end
	local it = Hotbar.current()
	if not it then return "fist", Config.Punch.Cooldown end
	if it.kind == "melee" and it.id ~= "Chainsaw" and (it.cd or 0.6) >= 0.2 then return it.id, it.cd or 0.6 end
	return nil, 0
end

local function setSprint(on: boolean)
	if on == sprinting then return end
	sprinting = on
	Remotes.Sprint:FireServer(on)
end

-- hit button down / up. Fists and melee weapons hit on RELEASE: a tap = a normal hit, holding charges it (the
-- server is told when the button went down, to check the charge). Guns, sprays and throwables fire on press.
local function hitDown()
	if lp:GetAttribute("Blocking") then return end
	local k = chargeable()
	if k then
		setHeld(true)
		Charge.begin(k, 0)
		Remotes.Charge:FireServer()
		return
	end
	setHeld(true)
	punch()
end
local function hitUp()
	setHeld(false)
	if not Charge.active() then return end
	local k = Charge.key()
	local c = Charge.release()
	if k == chargeable() and not lp:GetAttribute("Blocking") then punch(c > 0 and c or nil) end
end

-- block (hold right click / B / the BLOCK button): the server decides (stamina, guard break); held = keep asking
local blockHeld = false
local lastBlockAsk = 0
local function setBlock(on: boolean)
	blockHeld = on
	lastBlockAsk = os.clock()
	if on then Charge.cancel(); setSprint(false) end
	Remotes.Block:FireServer(on)
end

local function grab()
	if shopOpen then return end
	if lp:GetAttribute("Carrying") then
		Remotes.Throw:FireServer(look())
		VM.slam()
		return
	end
	-- the WEAK monster first (a x5 combo), then the furniture you look at
	local wm = weakMonster()
	if wm then Remotes.Grab:FireServer(wm); return end
	local m = aimedFurniture()
	if m then Remotes.Grab:FireServer(m) end
end

local function ult()
	if (lp:GetAttribute("Brutality") or 0) >= Config.Brutality.Max and not lp:GetAttribute("UltActive") then
		Remotes.Ultimate:FireServer()
	end
end


-- Double Ultimate pass: the spare ultimate becomes the one that fires
local function swapUlt()
	if shopOpen or not lp:GetAttribute("DoubleUlt") or (lp:GetAttribute("EquippedUlt2") or "") == "" then return end
	if lp:GetAttribute("UltActive") then return end
	Remotes:WaitForChild("SwapUlt"):FireServer()
end

-- the hint under the crosshair, in the player's controls
local function liftHint(name: string?): string?
	local m = Platform.mode()
	if lp:GetAttribute("Carrying") then
		if m == "touch" then return "TAP THROW" end
		if m == "gamepad" then return "[R2 / L2]  THROW IT" end
		return "[" .. Settings.keyName("Punch") .. " / " .. Settings.keyName("Lift") .. "]  THROW IT"
	end
	if not name then return nil end
	if m == "touch" then return "TAP LIFT:  " .. name end
	return Platform.label("Lift") .. "  LIFT " .. name
end

local ACTIONS = { "Punch", "Block", "Grab", "Ultimate", "SwapUlt", "Sprint", "Drop", "Settings", "SwapPrev", "SwapNext", "Play" }

-- (re)bind every action: keyboard keys from Settings, fixed controller buttons
local function bindAll()
	for _, a in ACTIONS do CAS:UnbindAction(a) end
	CAS:BindAction("Punch", function(_, st)
		if st == Enum.UserInputState.Begin then hitDown()
		elseif st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then hitUp() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Punch"), Enum.KeyCode.ButtonR2)
	CAS:BindAction("Block", function(_, st)
		if st == Enum.UserInputState.Begin then
			if lp:GetAttribute("InMatch") and not shopOpen then setBlock(true) end
		elseif st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then
			if blockHeld then setBlock(false) end
		end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Block"), Enum.KeyCode.ButtonB)
	CAS:BindAction("Grab", function(_, st)
		if st == Enum.UserInputState.Begin then grab() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Lift"), Enum.KeyCode.ButtonL2)
	CAS:BindAction("Ultimate", function(_, st)
		if st == Enum.UserInputState.Begin then ult() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Ultimate"), Enum.KeyCode.ButtonY)
	CAS:BindAction("SwapUlt", function(_, st)
		if st == Enum.UserInputState.Begin and not UIS:GetFocusedTextBox() then swapUlt() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("SwapUlt"), Enum.KeyCode.ButtonR3)
	CAS:BindAction("Sprint", function(_, st)
		setSprint(st == Enum.UserInputState.Begin)
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Sprint"), Enum.KeyCode.ButtonL3)
	CAS:BindAction("Drop", function(_, st)
		if st == Enum.UserInputState.Begin and lp:GetAttribute("InMatch") and not shopOpen then Hotbar.drop() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Drop"), Enum.KeyCode.DPadDown)
	CAS:BindAction("Settings", function(_, st)
		if st == Enum.UserInputState.Begin and not UIS:GetFocusedTextBox() then SettingsUI.toggle() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Settings"), Enum.KeyCode.DPadLeft)
	CAS:BindAction("SwapPrev", function(_, st)
		if st == Enum.UserInputState.Begin and lp:GetAttribute("InMatch") and not shopOpen then Hotbar.cycle(-1) end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.ButtonL1)
	CAS:BindAction("SwapNext", function(_, st)
		if st == Enum.UserInputState.Begin and lp:GetAttribute("InMatch") and not shopOpen then Hotbar.cycle(1) end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.ButtonR1)
	CAS:BindAction("Play", function(_, st)
		if st == Enum.UserInputState.Begin and not lp:GetAttribute("InMatch") and Input.openPlay then Input.openPlay() end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.DPadUp)
end

-- ProximityPrompts that use F (shops, dealer, lobby doors) follow the INTERACT keybind
local function promptKey(pp: ProximityPrompt)
	local orig = pp:GetAttribute("OrigKey")
	if not orig then
		orig = pp.KeyboardKeyCode.Name
		pp:SetAttribute("OrigKey", orig)
	end
	if orig == "F" then
		local k = Settings.input("Use")
		if typeof(k) == "EnumItem" and k.EnumType == Enum.KeyCode then pp.KeyboardKeyCode = k :: Enum.KeyCode end
	end
end
local function allPrompts()
	for _, d in workspace:GetDescendants() do if d:IsA("ProximityPrompt") then promptKey(d) end end
end

function Input.init()
	bindAll()
	Settings.changed:Connect(function(k) if k == "binds" then bindAll(); allPrompts() end end)
	allPrompts()
	workspace.DescendantAdded:Connect(function(d) if d:IsA("ProximityPrompt") then promptKey(d) end end)
	TouchControls.init({
		punch = function(down: boolean) if down then hitDown() else hitUp() end end,
		block = function(down: boolean) if down then setBlock(true) elseif blockHeld then setBlock(false) end end,
		lift = grab, ult = ult, swap = swapUlt, sprint = setSprint,
		drop = function() if lp:GetAttribute("InMatch") then Hotbar.drop() end end,
	})
	if RunService:IsStudio() then
		-- Studio test hook: player attribute DebugHit = true presses the hit button, false releases it
		lp:GetAttributeChangedSignal("DebugHit"):Connect(function()
			if lp:GetAttribute("DebugHit") then hitDown() else hitUp() end
		end)
		-- DebugBlock = true / false: hold / release block
		lp:GetAttributeChangedSignal("DebugBlock"):Connect(function()
			setBlock(lp:GetAttribute("DebugBlock") == true)
		end)
	end
	-- hold to keep hitting (mouse, key, trigger or the HIT button) with guns/sprays; fists and melee charge instead
	RunService.Heartbeat:Connect(function(dt)
		if shopOpen then setHeld(false) end
		if Charge.active() then
			-- switched weapon, picked something up, opened a shop or died: the charge is lost
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			if Charge.key() ~= chargeable() or not hum or hum.Health <= 0 then Charge.cancel() end
		end
		Charge.update(dt)
		-- still holding block after a guard break: ask again (the server refuses until the break is over)
		if blockHeld and not lp:GetAttribute("Blocking") and os.clock() - lastBlockAsk > 0.5 then
			if lp:GetAttribute("InMatch") and not shopOpen then lastBlockAsk = os.clock(); Remotes.Block:FireServer(true) end
		end
		local mouseLocked = UIS.MouseBehavior == Enum.MouseBehavior.LockCenter or Platform.mode() ~= "keyboard"
		if triggerHeld and not Charge.active() and lp:GetAttribute("InMatch") and not lp:GetAttribute("Carrying") and not shopOpen and mouseLocked then
			punch()
		end
		local now = os.clock()
		if now - lastHint < 0.15 then return end
		lastHint = now
		local wm = not shopOpen and not lp:GetAttribute("Carrying") and weakMonster()
		local m = not wm and not shopOpen and not lp:GetAttribute("Carrying") and aimedFurniture()
		HUD.hint(liftHint(wm and "THE MONSTER!" or (m and string.upper(m:GetAttribute("Kind") or m.Name) or nil)))
	end)
end

return Input
