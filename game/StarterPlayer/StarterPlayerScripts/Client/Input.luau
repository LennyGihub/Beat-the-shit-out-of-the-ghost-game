-- Controls: click = punch (or throw while carrying), E = lift / throw furniture, Q = ultimate, Shift = sprint.
-- Mobile gets on-screen buttons through ContextActionService.
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

local Input = {}
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

function Input.init()
	CAS:BindAction("Punch", function(_, st, input)
		if input and input.UserInputType == Enum.UserInputType.Touch then Hotbar.touchHold = st == Enum.UserInputState.Begin end
		if st == Enum.UserInputState.Begin then punch() end
		return Enum.ContextActionResult.Pass
	end, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	CAS:BindAction("Grab", function(_, st)
		if st == Enum.UserInputState.Begin then grab() end
		return Enum.ContextActionResult.Pass
	end, true, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
	CAS:BindAction("Ultimate", function(_, st)
		if st == Enum.UserInputState.Begin then ult() end
		return Enum.ContextActionResult.Pass
	end, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonY)
	CAS:BindAction("Sprint", function(_, st)
		setSprint(st == Enum.UserInputState.Begin)
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
	CAS:SetTitle("Punch", "HIT"); CAS:SetTitle("Grab", "LIFT"); CAS:SetTitle("Ultimate", "ULT")
	CAS:SetPosition("Punch", UDim2.new(1, -140, 1, -150))
	CAS:SetPosition("Grab", UDim2.new(1, -220, 1, -110))
	CAS:SetPosition("Ultimate", UDim2.new(1, -150, 1, -230))
	-- hold mouse button to keep punching
	RunService.Heartbeat:Connect(function()
		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not lp:GetAttribute("Carrying") and not shopOpen and UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
			punch()
		end
		local now = os.clock()
		if now - lastHint < 0.15 then return end
		lastHint = now
		if lp:GetAttribute("Carrying") then
			HUD.hint("[CLICK / E]  THROW IT")
		else
			local m = not shopOpen and aimedFurniture()
			HUD.hint(m and ("[E]  LIFT " .. string.upper(m:GetAttribute("Kind") or m.Name)) or nil)
		end
	end)
end

return Input
