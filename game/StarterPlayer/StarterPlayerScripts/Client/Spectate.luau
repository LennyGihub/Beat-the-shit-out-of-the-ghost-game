--!strict
-- Spectating (team runs): when you die while teammates still fight, the server sets your Spectating attribute; the
-- camera follows a living teammate (third person) until the wave's monster is knocked out and you are respawned.
-- A bar at the bottom says who you watch; NEXT switches teammate, LEAVE RUN takes your payout and goes to the lobby.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local Spectate = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local label: TextLabel
local watching: Player? = nil
local pick = 0

local function alive(p: Player): Humanoid?
	if p == lp or not p:GetAttribute("InMatch") or p:GetAttribute("Spectating") then return nil end
	local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	return (hum and hum.Health > 0) and hum or nil
end

local function teammates(): { Player }
	local out = {}
	for _, p in Players:GetPlayers() do if alive(p) then table.insert(out, p) end end
	table.sort(out, function(a, b) return a.UserId < b.UserId end)
	return out
end

local function choose()
	local list = teammates()
	if #list == 0 then watching = nil; return end
	pick = (pick - 1) % #list + 1
	watching = list[pick]
end

local function button(parent: Instance, text: string, props: { [string]: any }): TextButton
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true; b.BorderSizePixel = 0; b.BackgroundColor3 = Color3.fromRGB(45, 40, 36)
	b.Font = Grunge.FONT; b.Text = text; b.TextScaled = true; b.TextColor3 = Grunge.PAPER; b.TextStrokeTransparency = 0.3
	for k, v in props do (b :: any)[k] = v end
	b.Parent = parent
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0.16, 0); pad.PaddingBottom = UDim.new(0.16, 0); pad.Parent = b
	return b
end

function Spectate.active(): boolean return lp:GetAttribute("Spectating") == true end

function Spectate.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "Spectate"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 30; gui.Enabled = false
	gui.Parent = lp:WaitForChild("PlayerGui")
	local bar = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromScale(0.5, 0.11), Rotation = -0.5 }, 71)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 7; ar.Parent = bar
	label = Grunge.text(bar, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0.03, 0.1), Size = UDim2.fromScale(0.6, 0.5), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Grunge.PAPER, ZIndex = 10 })
	Grunge.text(bar, { Text = "YOU'RE BACK WHEN THIS MONSTER IS KNOCKED OUT", Font = Grunge.TYPE, Position = UDim2.fromScale(0.03, 0.6), Size = UDim2.fromScale(0.6, 0.3), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 10 })
	local nextBtn = button(bar, "NEXT", { Position = UDim2.fromScale(0.66, 0.2), Size = UDim2.fromScale(0.14, 0.6), ZIndex = 11 })
	nextBtn.Activated:Connect(function() Sfx.play("Click"); pick += 1; choose() end)
	local leave = button(bar, "LEAVE RUN", { Position = UDim2.fromScale(0.82, 0.2), Size = UDim2.fromScale(0.16, 0.6), ZIndex = 11, BackgroundColor3 = Color3.fromRGB(120, 24, 20) })
	leave.Activated:Connect(function() Sfx.play("Click"); Remotes.ReturnLobby:FireServer() end)
	-- the camera follows the watched teammate; the bar hides while the death screen (revive offer) is up
	RunService:BindToRenderStep("Spectate", Enum.RenderPriority.Camera.Value - 1, function()
		local on = Spectate.active()
		local deathScreen = type(lp:GetAttribute("ReviveUntil")) == "number"
		gui.Enabled = on and not deathScreen
		if not on then watching = nil; return end
		if not (watching and alive(watching)) then choose() end
		local cam = workspace.CurrentCamera
		local hum = watching and alive(watching)
		if hum then
			if cam.CameraSubject ~= hum then cam.CameraSubject = hum end
			cam.CameraType = Enum.CameraType.Custom
			label.Text = "SPECTATING " .. string.upper((watching :: Player).DisplayName)
		else
			label.Text = "SPECTATING"
		end
	end)
end

return Spectate
