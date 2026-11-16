-- Controls: click = punch (or throw while carrying), E = lift / throw furniture, Q = ultimate, Shift = sprint, X = drop,
-- P = settings (keyboard keys are rebindable in Settings). Controller: R2 / L2 / Y / L3, L1-R1 items, D-pad down drop,
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

-- furniture you are looking at (or right in front of you)
local function aimedFurniture(): Model?
	local f = workspace:FindFirstChild("Mansion") and workspace.Mansion:FindFirstChild("Furniture")
	if not f then return nil end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { f }
	local r = workspace:Raycast(cam.CFrame.Position, look() * (Config.Carry.Range + 2), rp)
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
	for _, m in f:GetChildren() do
		if m:IsA("Model") and CS:HasTag(m, "Furniture") and not m:GetAttribute("CarriedBy") then
			local c = m:GetBoundingBox().Position
			local to = c - hrp.Position
			local d = Vector3.new(to.X, 0, to.Z).Magnitude
			if d < bestD and look():Dot(to.Unit) > 0.3 then best, bestD = m, d end
		end
	end
	return best
end

local function punch()
	if shopOpen then return end
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	if lp:GetAttribute("Carrying") then
		Remotes.Throw:FireServer(look())
		VM.slam()
		return
	end
	if Hotbar.primary() then return end
	local now = os.clock()
	if now - lastPunch < Config.Punch.Cooldown then return end
	if (lp:GetAttribute("Stamina") or 100) < Config.Punch.StaminaCost then
		HUD.flash(Color3.fromRGB(120, 110, 40), 0.2)
		return
	end
	lastPunch = now
	VM.punch((lp:GetAttribute("Combo") or 0) + 1)
	Sfx.play("Whoosh", { PlaybackSpeed = 0.9 + math.random() * 0.3 })
	Remotes.Punch:FireServer(look())
end

local function grab()
	if shopOpen then return end
	if lp:GetAttribute("Carrying") then
		Remotes.Throw:FireServer(look())
		VM.slam()
		return
	end
	local m = aimedFurniture()
	if m then Remotes.Grab:FireServer(m) end
end

local function ult()
	if (lp:GetAttribute("Brutality") or 0) >= Config.Brutality.Max and not lp:GetAttribute("UltActive") then
		Remotes.Ultimate:FireServer()
	end
end

local function setSprint(on: boolean)
	if on == sprinting then return end
	sprinting = on
	Remotes.Sprint:FireServer(on)
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

local ACTIONS = { "Punch", "Grab", "Ultimate", "Sprint", "Drop", "Settings", "SwapPrev", "SwapNext", "Play" }
local triggerHeld = false -- the hit button / key / trigger is held down (keep hitting, keep spraying)

local function setHeld(on: boolean)
	triggerHeld = on
	Hotbar.touchHold = on
end

-- (re)bind every action: keyboard keys from Settings, fixed controller buttons
local function bindAll()
	for _, a in ACTIONS do CAS:UnbindAction(a) end
	CAS:BindAction("Punch", function(_, st)
		if st == Enum.UserInputState.Begin then setHeld(true); punch()
		elseif st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then setHeld(false) end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Punch"), Enum.KeyCode.ButtonR2)
	CAS:BindAction("Grab", function(_, st)
		if st == Enum.UserInputState.Begin then grab() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Lift"), Enum.KeyCode.ButtonL2)
	CAS:BindAction("Ultimate", function(_, st)
		if st == Enum.UserInputState.Begin then ult() end
		return Enum.ContextActionResult.Pass
	end, false, Settings.input("Ultimate"), Enum.KeyCode.ButtonY)
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
		punch = function(down: boolean) setHeld(down); if down then punch() end end,
		lift = grab, ult = ult, sprint = setSprint,
		drop = function() if lp:GetAttribute("InMatch") then Hotbar.drop() end end,
	})
	-- hold to keep hitting (mouse, key, trigger or the HIT button)
	RunService.Heartbeat:Connect(function()
		if shopOpen then setHeld(false) end
		local mouseLocked = UIS.MouseBehavior == Enum.MouseBehavior.LockCenter or Platform.mode() ~= "keyboard"
		if triggerHeld and lp:GetAttribute("InMatch") and not lp:GetAttribute("Carrying") and not shopOpen and mouseLocked then
			punch()
		end
		local now = os.clock()
		if now - lastHint < 0.15 then return end
		lastHint = now
		local m = not shopOpen and not lp:GetAttribute("Carrying") and aimedFurniture()
		HUD.hint(liftHint(m and string.upper(m:GetAttribute("Kind") or m.Name) or nil))
	end)
end

return Input
