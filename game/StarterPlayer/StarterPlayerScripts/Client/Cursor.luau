--!strict
-- FREE MOUSE: in first person (a run) the mouse is locked to the middle of the screen. The FREE MOUSE key (Settings
-- action "Cursor", Left Alt by default, rebindable) frees it, to click anything on the screen (the stage result's
-- buttons, the sandbox's LEAVE...), and locks it again on the next press. It locks again by itself when the
-- player leaves first person. A screen can also keep it free while it is shown: Cursor.hold(name, true / false).
-- (How: a visible GuiButton with Modal = true frees the mouse in first person, like the panels' CLOSE buttons.)
-- Studio test hook: player attribute DebugFreeMouse = true / false sets it.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Settings = require(script.Parent.Settings)

local Cursor = {}
local lp = Players.LocalPlayer
local btn: TextButton? = nil
local toggled = false
local holds: { [string]: boolean } = {}

local function update()
	local b = btn
	if not b then return end
	local free = toggled
	for _, on in holds do if on then free = true end end
	b.Visible = free
	lp:SetAttribute("MouseFree", free) -- (for the controls reminder and tests)
end

-- is the mouse freed (by the key or a screen)?
function Cursor.isFree(): boolean
	local b = btn
	return b ~= nil and b.Visible
end
function Cursor.hold(name: string, on: boolean)
	holds[name] = if on then true else nil
	update()
end
function Cursor.toggle()
	toggled = not toggled
	update()
end

function Cursor.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "FreeMouse"; gui.ResetOnSpawn = false; gui.DisplayOrder = -10
	gui.Parent = lp:WaitForChild("PlayerGui")
	local b = Instance.new("TextButton")
	b.Name = "Modal"; b.Modal = true; b.Text = ""; b.BackgroundTransparency = 1; b.Size = UDim2.fromScale(0, 0)
	b.Selectable = false; b.Visible = false
	b.Parent = gui
	btn = b
	-- out of first person (the lobby, spectating): the key's choice is dropped, locked again next run
	lp:GetPropertyChangedSignal("CameraMode"):Connect(function()
		if lp.CameraMode ~= Enum.CameraMode.LockFirstPerson and toggled then
			toggled = false
			update()
		end
	end)
	UIS.InputBegan:Connect(function(input, _processed)
		if UIS:GetFocusedTextBox() then return end
		local key = Settings.input("Cursor")
		if (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == key) or input.UserInputType == key then Cursor.toggle() end
	end)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugFreeMouse"):Connect(function()
			local v = lp:GetAttribute("DebugFreeMouse")
			if type(v) == "boolean" and v ~= toggled then Cursor.toggle() end
		end)
	end
	update()
end

return Cursor
