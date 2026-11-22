--!strict
-- ADMIN FREECAM (2026-11-22, the user: "if the admin press Shift + C he can be in freecam"). Only for players the
-- server marked IsAdmin (Server/Admin). SHIFT + C turns it on / off:
--   WASD move, E / SPACE up, Q / CTRL down, hold RIGHT MOUSE to look around, the WHEEL changes the speed, hold
--   SHIFT to go 4x faster, SHIFT + V hides / shows every UI (clean shots), SHIFT + C back to the normal camera.
-- While it is on the character stands still (its movement keys are taken here; Roblox's controls are switched off
-- when its PlayerModule is there) and the game's own keys (punch, block, lift, ultimate...) are off (Input.setShopOpen).
-- The server streams the world round the camera to this player (Remotes.FreeCam "focus": ReplicationFocus), so far
-- places are there too; "off" gives the focus back to the character.
-- In a fight the first-person fists are hidden while it is on.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local FC = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Remotes = RS:WaitForChild("Remotes")
local setInputOff: ((boolean) -> ())? = nil

local on = false
local pos = Vector3.zero
local yaw, pitch = 0, 0
local vel = Vector3.zero
local speed = 40 -- studs a second (the wheel changes it)
local held = {} :: { [string]: boolean }
local looking = false
local lastFocus = 0
local hint: ScreenGui? = nil
local hintText: TextLabel? = nil
local uiHidden = false
local hiddenGuis = {} :: { ScreenGui }
local hiddenCore = {} :: { Enum.CoreGuiType }
local controls: any = nil
-- (what the freecam hid in a fight's first-person view, and how it was: put back when it ends)
local vmLtm = {} :: { [BasePart]: number }
local vmOff = {} :: { [Instance]: boolean }

local KEYS = {
	[Enum.KeyCode.W] = "f", [Enum.KeyCode.Up] = "f", [Enum.KeyCode.S] = "b", [Enum.KeyCode.Down] = "b",
	[Enum.KeyCode.A] = "l", [Enum.KeyCode.Left] = "l", [Enum.KeyCode.D] = "r", [Enum.KeyCode.Right] = "r",
	[Enum.KeyCode.E] = "u", [Enum.KeyCode.Space] = "u", [Enum.KeyCode.Q] = "d", [Enum.KeyCode.LeftControl] = "d",
} :: { [Enum.KeyCode]: string }

local function shiftDown(): boolean
	return UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)
end

local function playerControls(): any
	if controls then return controls end
	local ps = lp:FindFirstChild("PlayerScripts")
	local pm = ps and ps:FindFirstChild("PlayerModule")
	if pm and pm:IsA("ModuleScript") then
		pcall(function() controls = (require(pm) :: any):GetControls() end)
	end
	return controls
end

local function refreshHint()
	if hintText then
		hintText.Text = string.format("FREECAM   SPEED %d   -   WASD MOVE   E / Q UP / DOWN   RIGHT MOUSE LOOK   WHEEL SPEED   SHIFT FAST   SHIFT+V HIDE UI   SHIFT+C EXIT", math.floor(speed + 0.5))
	end
end

local function makeHint()
	if hint then return end
	local g = Instance.new("ScreenGui")
	g.Name = "FreeCamUI"; g.ResetOnSpawn = false; g.IgnoreGuiInset = true; g.DisplayOrder = 90
	local t = Instance.new("TextLabel")
	t.BackgroundColor3 = Color3.new(0, 0, 0); t.BackgroundTransparency = 0.45; t.BorderSizePixel = 0
	t.AnchorPoint = Vector2.new(0.5, 1); t.Position = UDim2.new(0.5, 0, 1, -10); t.Size = UDim2.new(0.7, 0, 0, 24)
	t.Font = Enum.Font.SpecialElite; t.TextScaled = true; t.TextColor3 = Color3.fromRGB(232, 222, 200)
	t.Parent = g
	g.Parent = lp:WaitForChild("PlayerGui")
	hint, hintText = g, t
	refreshHint()
end

-- SHIFT + V: every UI off (and Roblox's own: chat, player list...), then back exactly as it was
local function setUiHidden(v: boolean)
	if v == uiHidden then return end
	uiHidden = v
	if v then
		hiddenGuis, hiddenCore = {}, {}
		for _, g in lp:WaitForChild("PlayerGui"):GetChildren() do
			if g:IsA("ScreenGui") and g.Enabled then g.Enabled = false; table.insert(hiddenGuis, g) end
		end
		for _, t in Enum.CoreGuiType:GetEnumItems() do
			if t ~= Enum.CoreGuiType.All then
				local ok, was = pcall(function() return StarterGui:GetCoreGuiEnabled(t) end)
				if ok and was then pcall(function() StarterGui:SetCoreGuiEnabled(t, false) end); table.insert(hiddenCore, t) end
			end
		end
	else
		for _, g in hiddenGuis do if g.Parent and not g.Enabled then g.Enabled = true end end
		for _, t in hiddenCore do pcall(function() StarterGui:SetCoreGuiEnabled(t, true) end) end
		hiddenGuis, hiddenCore = {}, {}
	end
end

local function bindKeys()
	local codes = {}
	for k in KEYS do table.insert(codes, k) end
	CAS:BindActionAtPriority("FreeCamMove", function(_, state, input)
		local dir = KEYS[input.KeyCode]
		if dir then held[dir] = state == Enum.UserInputState.Begin or state == Enum.UserInputState.Change end
		return Enum.ContextActionResult.Sink
	end, false, 4000, table.unpack(codes))
	CAS:BindActionAtPriority("FreeCamWheel", function(_, state, input)
		if state == Enum.UserInputState.Change then
			speed = math.clamp(speed * (input.Position.Z > 0 and 1.25 or 0.8), 2, 1000)
			refreshHint()
		end
		return Enum.ContextActionResult.Sink
	end, false, 4000, Enum.UserInputType.MouseWheel)
	CAS:BindActionAtPriority("FreeCamLook", function(_, state)
		looking = state == Enum.UserInputState.Begin
		return Enum.ContextActionResult.Sink
	end, false, 4000, Enum.UserInputType.MouseButton2)
end

local function unbindKeys()
	CAS:UnbindAction("FreeCamMove")
	CAS:UnbindAction("FreeCamWheel")
	CAS:UnbindAction("FreeCamLook")
	held = {}
	looking = false
end

local function step(dt: number)
	if not on then return end
	-- look
	if looking then
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		local d = UIS:GetMouseDelta()
		yaw -= d.X * 0.0045
		pitch = math.clamp(pitch - d.Y * 0.0045, -1.45, 1.45)
	else
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
	local rot = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)
	-- move (smoothed), relative to where the camera looks; up / down straight up
	local mv = Vector3.zero
	if held.f then mv += rot.LookVector end
	if held.b then mv -= rot.LookVector end
	if held.r then mv += rot.RightVector end
	if held.l then mv -= rot.RightVector end
	if held.u then mv += Vector3.yAxis end
	if held.d then mv -= Vector3.yAxis end
	if mv.Magnitude > 0 then mv = mv.Unit end
	local want = mv * speed * (shiftDown() and 4 or 1)
	vel = vel:Lerp(want, 1 - math.exp(-dt * 9))
	pos += vel * dt
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = CFrame.new(pos) * rot
	-- (the focus a little ahead: detail and sound round the view, and Roblox's camera does not hide the character)
	cam.Focus = cam.CFrame * CFrame.new(0, 0, -20)
	-- a fight's first-person fists stay out of the view
	local vm = cam:FindFirstChild("Viewmodel")
	if vm then
		for _, d in vm:GetDescendants() do
			if d:IsA("BasePart") then
				if vmLtm[d] == nil then vmLtm[d] = d.LocalTransparencyModifier end
				d.LocalTransparencyModifier = 1
			elseif d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("Trail") then
				if (d :: any).Enabled then vmOff[d] = true; (d :: any).Enabled = false end
			end
		end
	end
	-- the server streams the world round the camera
	if os.clock() - lastFocus > 0.4 then
		lastFocus = os.clock()
		;(Remotes :: any).FreeCam:FireServer("focus", pos)
	end
end

function FC.set(v: boolean)
	if v == on then return end
	if v and lp:GetAttribute("IsAdmin") ~= true then return end
	on = v
	if v then
		local cf = cam.CFrame
		pos = cf.Position
		local lv = cf.LookVector
		yaw = math.atan2(-lv.X, -lv.Z)
		pitch = math.asin(math.clamp(lv.Y, -1, 1))
		vel = Vector3.zero
		local c = playerControls()
		if c then pcall(function() c:Disable() end) end
		if setInputOff then setInputOff(true) end
		bindKeys()
		makeHint()
		if hint then hint.Enabled = true end
		RunService:BindToRenderStep("FreeCam", Enum.RenderPriority.Last.Value, step)
	else
		RunService:UnbindFromRenderStep("FreeCam")
		unbindKeys()
		for part, v in vmLtm do if part.Parent then part.LocalTransparencyModifier = v end end
		for inst in vmOff do if inst.Parent then (inst :: any).Enabled = true end end
		vmLtm, vmOff = {}, {}
		setUiHidden(false)
		if hint then hint.Enabled = false end
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		cam.CameraType = Enum.CameraType.Custom
		local ch = lp.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then cam.CameraSubject = hum end
		local c = playerControls()
		if c then pcall(function() c:Enable() end) end
		if setInputOff then setInputOff(false) end
		;(Remotes :: any).FreeCam:FireServer("off")
	end
end
function FC.isOn(): boolean return on end

-- inputOff(true / false): the game's own keys off while the freecam is on (ClientMain passes Input.setShopOpen)
function FC.init(inputOff: ((boolean) -> ())?)
	setInputOff = inputOff
	UIS.InputBegan:Connect(function(input, processed)
		if input.KeyCode ~= Enum.KeyCode.C and input.KeyCode ~= Enum.KeyCode.V then return end
		if UIS:GetFocusedTextBox() or not shiftDown() then return end
		if lp:GetAttribute("IsAdmin") ~= true then return end
		if input.KeyCode == Enum.KeyCode.C then
			FC.set(not on)
		elseif on then
			setUiHidden(not uiHidden)
		end
		local _ = processed
	end)
	-- (the character died / came back: the freecam stays where it was; it ends if admin rights go away)
	lp:GetAttributeChangedSignal("IsAdmin"):Connect(function()
		if lp:GetAttribute("IsAdmin") ~= true and on then FC.set(false) end
	end)
	-- Studio test hooks (player attributes): DebugFreeCam = true / false turns it on / off; DebugFreeCamKeys = the
	-- directions held ("f" "b" "l" "r" "u" "d", e.g. "fu"); DebugFreeCamHideUI = true / false; DebugFreeCamLook =
	-- Vector2 (yaw, pitch) in degrees
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugFreeCam"):Connect(function() FC.set(lp:GetAttribute("DebugFreeCam") == true) end)
		lp:GetAttributeChangedSignal("DebugFreeCamKeys"):Connect(function()
			local v = lp:GetAttribute("DebugFreeCamKeys")
			held = {}
			if type(v) == "string" then for c in string.gmatch(v, "%a") do held[c] = true end end
		end)
		lp:GetAttributeChangedSignal("DebugFreeCamHideUI"):Connect(function()
			if on then setUiHidden(lp:GetAttribute("DebugFreeCamHideUI") == true) end
		end)
		lp:GetAttributeChangedSignal("DebugFreeCamLook"):Connect(function()
			local v = lp:GetAttribute("DebugFreeCamLook")
			if typeof(v) == "Vector2" then yaw, pitch = math.rad(v.X), math.rad(v.Y) end
		end)
	end
end

return FC
