-- On-screen buttons for phones and tablets during a run: HIT (hold = keep hitting / spraying), LIFT / THROW,
-- ULT (lights up when the brutality bar is full), RUN (toggle) and DROP (when holding an item).
-- They sit left of and above Roblox's jump button, scaled to the screen. Shown only in touch mode.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local TC = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local buttons = {} :: { [string]: { root: TextButton, base: Vector2, size: number, stroke: UIStroke, label: TextLabel } }
local running = false

type Handlers = { punch: (down: boolean) -> (), lift: () -> (), ult: () -> (), sprint: (on: boolean) -> (), drop: () -> () }

local function make(id: string, text: string, size: number, base: Vector2, color: Color3, onDown: () -> (), onUp: (() -> ())?)
	local b = Instance.new("TextButton")
	b.Name = id; b.Text = ""; b.AutoButtonColor = false; b.BorderSizePixel = 0
	b.BackgroundColor3 = color; b.BackgroundTransparency = 0.25; b.AnchorPoint = Vector2.new(0.5, 0.5)
	b.Parent = gui
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = b
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 4; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	local label = Grunge.text(b, { Text = text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.78, 0.4), Rotation = -4 })
	b.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			b.BackgroundTransparency = 0.05
			onDown()
		end
	end)
	b.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			b.BackgroundTransparency = 0.25
			if onUp then onUp() end
		end
	end)
	buttons[id] = { root = b, base = base, size = size, stroke = st, label = label }
end

local function layout()
	local vp = workspace.CurrentCamera.ViewportSize
	local s = math.clamp(math.min(vp.X, vp.Y) / 620, 0.55, 1.15)
	for _, b in buttons do
		b.root.Size = UDim2.fromOffset(b.size * s, b.size * s)
		b.root.Position = UDim2.new(1, b.base.X * s, 1, b.base.Y * s)
	end
end

function TC.isOn(): boolean return gui ~= nil and gui.Enabled end

function TC.init(h: Handlers)
	gui = Instance.new("ScreenGui")
	gui.Name = "TouchControls"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 4; gui.Enabled = false
	gui.Parent = lp:WaitForChild("PlayerGui")
	local DARKRED, DARK = Color3.fromRGB(120, 18, 16), Color3.fromRGB(40, 34, 30)
	make("Hit", "HIT", 124, Vector2.new(-300, -150), DARKRED, function() h.punch(true) end, function() h.punch(false) end)
	make("Lift", "LIFT", 88, Vector2.new(-190, -300), DARK, h.lift)
	make("Ult", "ULT", 88, Vector2.new(-320, -300), DARK, h.ult)
	make("Run", "RUN", 78, Vector2.new(-440, -120), DARK, function()
		running = not running
		h.sprint(running)
	end)
	make("Drop", "DROP", 66, Vector2.new(-440, -240), DARK, h.drop)
	layout()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
	local function refresh()
		local on = Platform.mode() == "touch" and lp:GetAttribute("InMatch") == true
		gui.Enabled = on
		if not on and running then running = false; h.sprint(false) end
	end
	refresh()
	Platform.changed:Connect(refresh)
	lp:GetAttributeChangedSignal("InMatch"):Connect(refresh)
	RunService.Heartbeat:Connect(function()
		if not gui.Enabled then return end
		local ready = (lp:GetAttribute("Brutality") or 0) >= Config.Brutality.Max and not lp:GetAttribute("UltActive")
		local ult = buttons.Ult
		ult.root.BackgroundColor3 = ready and Color3.fromRGB(230, 96, 20) or Color3.fromRGB(40, 34, 30)
		ult.stroke.Color = ready and Color3.fromRGB(255, 200, 90) or Grunge.INK
		buttons.Run.root.BackgroundColor3 = running and Color3.fromRGB(196, 176, 64) or Color3.fromRGB(40, 34, 30)
		buttons.Lift.label.Text = lp:GetAttribute("Carrying") and "THROW" or "LIFT"
		buttons.Drop.root.Visible = (lp:GetAttribute("Sel") or 0) > 0
	end)
end

return TC
