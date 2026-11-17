--!strict
-- SandboxUI: the buttons of the sandbox (Server/Sandbox), shown while the player attribute Sandbox is set.
-- LEAVE (grey, top middle of the screen) goes back to the park; ULTIMATES opens the shop to pick another ultimate
-- to try. In the house the mouse is locked on the crosshair, so both also have a key (L and U; on a controller
-- X and D-pad up: no prompt uses X inside the sandbox) written on the button; on a phone they are tapped.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Settings = require(script.Parent.Settings)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local leaveBtn: TextButton
local ultBtn: TextButton
local openShop: (() -> ())? = nil
local shopOpen = false
local lastLeave = 0

local GREY = Color3.fromRGB(104, 102, 100)
local DARK = Color3.fromRGB(38, 31, 27)
local LEAVE_KEY, ULT_KEY = Enum.KeyCode.L, Enum.KeyCode.U

local function inSandbox(): boolean return lp:GetAttribute("Sandbox") == true end

-- a key the player gave to another action in Settings is not ours any more (the button still works by tap / click)
local function free(key: Enum.KeyCode): boolean
	for action in Settings.DEFAULT_BINDS do
		if Settings.input(action) == key then return false end
	end
	return true
end

local function button(text: string, props: { [string]: any }, color: Color3, seed: number): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.BackgroundTransparency = 1; b.Text = ""
	for k, v in props do (b :: any)[k] = v end
	b.Parent = gui
	Grunge.brush(b, { Name = "Brush", Size = UDim2.fromScale(1, 1), ZIndex = 5 }, color, seed, 12)
	Grunge.text(b, { Name = "Label", Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.62), ZIndex = 8 })
	local min = Instance.new("UISizeConstraint"); min.MinSize = Vector2.new(120, 40); min.Parent = b
	local sc = Instance.new("UIScale"); sc.Parent = b
	b.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1.05 }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.12), { Scale = 1 }):Play() end)
	return b
end

local function leave()
	if not inSandbox() or os.clock() - lastLeave < 0.6 then return end
	lastLeave = os.clock()
	Sfx.play("Click")
	local r = Remotes:WaitForChild("Sandbox", 5) :: RemoteEvent?
	if r then r:FireServer("leave") end
end

local function ultimates()
	if not inSandbox() or shopOpen then return end
	Sfx.play("Click")
	if openShop then openShop() end
end

local function refresh()
	gui.Enabled = inSandbox() and not shopOpen
	local mode = Platform.mode()
	local leaveKey, ultKey = "", ""
	if mode == "gamepad" then
		leaveKey, ultKey = "  [X]", "  [D-PAD UP]"
	elseif mode ~= "touch" then
		leaveKey = free(LEAVE_KEY) and "  [L]" or ""
		ultKey = free(ULT_KEY) and "  [U]" or ""
	end
	local l1 = leaveBtn:FindFirstChild("Label") :: TextLabel
	local l2 = ultBtn:FindFirstChild("Label") :: TextLabel
	l1.Text = "LEAVE" .. leaveKey
	l2.Text = "ULTIMATES" .. ultKey
end

-- the shop covers the top of the screen: the buttons step aside while it is open
function UI.setShopOpen(open: boolean)
	shopOpen = open
	if gui then refresh() end
end

function UI.init(shop: () -> ())
	openShop = shop
	gui = Instance.new("ScreenGui")
	gui.Name = "SandboxUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Enabled = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	-- under the monster's health bar (top centre), in the place of a run's objective line
	leaveBtn = button("LEAVE", { Name = "Leave", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 104), Size = UDim2.fromScale(0.13, 0.055), Rotation = -1 }, GREY, 611)
	ultBtn = button("ULTIMATES", { Name = "Ultimates", AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0.575, 0, 0, 108), Size = UDim2.fromScale(0.12, 0.045), Rotation = 1 }, DARK, 617)
	leaveBtn.Activated:Connect(leave)
	ultBtn.Activated:Connect(ultimates)
	UIS.InputBegan:Connect(function(input: InputObject, typing: boolean)
		if typing or shopOpen or not inSandbox() or UIS:GetFocusedTextBox() then return end
		local k = input.KeyCode
		if (k == LEAVE_KEY and free(LEAVE_KEY)) or k == Enum.KeyCode.ButtonX then
			leave()
		elseif (k == ULT_KEY and free(ULT_KEY)) or k == Enum.KeyCode.DPadUp then
			ultimates()
		end
	end)
	lp:GetAttributeChangedSignal("Sandbox"):Connect(refresh)
	Platform.changed:Connect(refresh)
	Settings.changed:Connect(function(k) if k == "binds" then refresh() end end)
	refresh()
end

return UI
