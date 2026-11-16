--!strict
-- Which controls the player is using right now (keyboard / gamepad / touch), button names for hints, and
-- controller navigation of the menus: a registered menu that is open gets its first button selected
-- (the stick / d-pad moves between buttons, A presses) and B closes it.
-- Studio test hook: player attribute DebugPlatform = "keyboard" | "gamepad" | "touch" forces a mode.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Platform = {}
local lp = Players.LocalPlayer
local changed = Instance.new("BindableEvent")
Platform.changed = changed.Event

local GAMEPAD = {
	[Enum.UserInputType.Gamepad1] = true, [Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true, [Enum.UserInputType.Gamepad4] = true,
}
local KEYBOARD = {
	[Enum.UserInputType.Keyboard] = true, [Enum.UserInputType.MouseButton1] = true, [Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true, [Enum.UserInputType.MouseMovement] = true, [Enum.UserInputType.MouseWheel] = true,
}

local function initialMode(): string
	if UIS.GamepadEnabled and not UIS.KeyboardEnabled and not UIS.TouchEnabled then return "gamepad" end
	if UIS.TouchEnabled and not UIS.KeyboardEnabled then return "touch" end
	return "keyboard"
end
local mode = initialMode()

function Platform.mode(): string
	if RunService:IsStudio() then
		local d = lp:GetAttribute("DebugPlatform")
		if d == "keyboard" or d == "gamepad" or d == "touch" then return d end
	end
	return mode
end

local function setMode(m: string)
	if m == mode then return end
	mode = m
	changed:Fire(Platform.mode())
end

-- controller buttons for each action (fixed)
Platform.PAD = {
	Punch = "R2", Lift = "L2", Ultimate = "Y", Sprint = "L3", Drop = "D-PAD DOWN", Use = "X", Settings = "D-PAD LEFT",
	Swap = "L1 / R1", Play = "D-PAD UP",
}
-- touch buttons (TouchControls) for each action
Platform.TOUCH = { Punch = "HIT", Lift = "LIFT", Ultimate = "ULT", Sprint = "RUN", Drop = "DROP", Use = "TAP", Settings = "SETTINGS", Swap = "TAP A SLOT" }

-- keyboard key names are filled in by Settings (rebindable)
Platform.keyName = function(_action: string): string return "?" end

-- "[E]" / "[L2]" / "LIFT" for hints
function Platform.label(action: string): string
	local m = Platform.mode()
	if m == "gamepad" then return "[" .. (Platform.PAD[action] or action) .. "]" end
	if m == "touch" then return Platform.TOUCH[action] or action end
	return "[" .. Platform.keyName(action) .. "]"
end

-- MENUS ------------------------------------------------------------------------------------------------
type Menu = { root: GuiObject, close: (() -> ())?, order: number }
local menus = {} :: { Menu }
local counter = 0

local function shown(o: Instance?): boolean
	while o do
		if o:IsA("GuiObject") and not o.Visible then return false end
		if o:IsA("LayerCollector") then return (o :: LayerCollector).Enabled end
		o = o.Parent
	end
	return false
end

-- register a menu window (root) and how to close it (B on a controller)
function Platform.menu(root: GuiObject, close: (() -> ())?)
	counter += 1
	table.insert(menus, { root = root, close = close, order = counter })
end

local function openMenu(): Menu?
	local best: Menu? = nil
	for _, m in menus do
		if m.root.Parent and shown(m.root) then
			-- the one drawn on top (DisplayOrder), then the latest opened
			local gui = m.root:FindFirstAncestorOfClass("ScreenGui")
			local d = gui and gui.DisplayOrder or 0
			local bd = best and (best.root:FindFirstAncestorOfClass("ScreenGui") :: ScreenGui?)
			if not best or d > (bd and bd.DisplayOrder or 0) or (d == (bd and bd.DisplayOrder or 0) and (m.root:GetAttribute("OpenedAt") or 0) >= (best.root:GetAttribute("OpenedAt") or 0)) then
				best = m
			end
		end
	end
	return best
end
Platform.openMenu = function(): boolean return openMenu() ~= nil end

local function firstButton(root: GuiObject): GuiObject?
	local best, bx, by = nil, math.huge, math.huge
	for _, d in root:GetDescendants() do
		if d:IsA("GuiButton") and d.Selectable and shown(d) and d.AbsoluteSize.X > 4 then
			local p = d.AbsolutePosition
			-- top-most row first (rows within 12 px count as one), then left-most
			if p.Y < by - 12 or (math.abs(p.Y - by) <= 12 and p.X < bx) then best, bx, by = d, p.X, p.Y end
		end
	end
	return best
end

local wasOpen: Menu? = nil
local function navStep()
	local m = openMenu()
	if Platform.mode() ~= "gamepad" then
		wasOpen = m
		return
	end
	local sel = GuiService.SelectedObject
	if m then
		if not sel or not sel:IsDescendantOf(m.root) or not shown(sel) then
			GuiService.SelectedObject = firstButton(m.root)
		end
	elseif wasOpen and sel then
		GuiService.SelectedObject = nil -- the menu closed: give the stick back to the character
	end
	wasOpen = m
end

function Platform.init()
	UIS.LastInputTypeChanged:Connect(function(t)
		if GAMEPAD[t] then setMode("gamepad")
		elseif t == Enum.UserInputType.Touch then setMode("touch")
		elseif KEYBOARD[t] then setMode("keyboard") end
	end)
	lp:GetAttributeChangedSignal("DebugPlatform"):Connect(function() changed:Fire(Platform.mode()) end)
	UIS.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonB then
			local m = openMenu()
			if m and m.close then m.close() end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.15)
			navStep()
		end
	end)
end

return Platform
