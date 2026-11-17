--!strict
-- The Caller's phone call (server: Server/Caller, Fx event "CallerCall"): the player who picked the ringing phone
-- up gets his voice as lines of text at the bottom of the screen, one after the other, with a low distorted
-- whisper under each, in a panel painted like the fight's bars. What he says names the room he sits in (never the
-- exact spot); the room itself is then outlined by Client/CallerMarks.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)

local CallerUI = {}
local lp = Players.LocalPlayer
local panel: Frame
local who: TextLabel
local text: TextLabel
local token = 0
local bars = {} :: { Frame }
local talking = false

function CallerUI.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "CallerCall"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 3
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	-- painted like the fight's bars: a ragged ink brush stroke over a blood splat, his name on a red stroke (the
	-- way a monster's name sits on its health bar), his words typed underneath
	panel = Grunge.brush(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.43, 0, 0.8, 0), Size = UDim2.fromScale(0.44, 0.15),
		Rotation = -0.6, Visible = false, ZIndex = 2 }, Color3.fromRGB(24, 19, 17), 77, 34, false)
	local lim = Instance.new("UISizeConstraint"); lim.MinSize = Vector2.new(400, 96); lim.MaxSize = Vector2.new(760, 150); lim.Parent = panel
	Grunge.splat(panel, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.82, 0.5), Size = UDim2.fromScale(0.55, 2.4),
		ImageColor3 = Color3.fromRGB(80, 10, 10), ImageTransparency = 0.45, ZIndex = 1, Rotation = 24 })
	local tag = Grunge.brush(panel, { Position = UDim2.new(0, 10, 0, -12), Size = UDim2.new(0.44, 0, 0.36, 0), Rotation = -1.6, ZIndex = 3 },
		Color3.fromRGB(150, 18, 20), 78, 14, false)
	who = Grunge.text(tag, { Text = "UNKNOWN CALLER", Font = Grunge.HORROR, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.78), TextColor3 = Grunge.PAPER, ZIndex = 5 })
	-- the line is open: three bars that jump while he talks
	for k = 0, 2 do
		local b = Grunge.frame(panel, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(230, 60, 50), AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(1, -54 + k * 12, 0.3, 0), Size = UDim2.new(0, 6, 0.1, 0), Rotation = 2, ZIndex = 5 })
		table.insert(bars, b)
	end
	text = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.new(0, 22, 0.36, 0), Size = UDim2.new(1, -44, 0.54, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, ZIndex = 5 })
	local tc = Instance.new("UITextSizeConstraint"); tc.MaxTextSize = 22; tc.Parent = text
	game:GetService("RunService").Heartbeat:Connect(function()
		if not panel.Visible then return end
		local t = os.clock()
		for k, b in bars do
			local h = talking and (0.08 + math.abs(math.sin(t * (7 + k * 2.3) + k)) * 0.2) or 0.04
			b.Size = UDim2.new(0, 6, h, 0)
		end
	end)
end

-- lines = what he says; each stays `lineTime` seconds, typed out letter by letter
function CallerUI.call(lines: { string }, lineTime: number?)
	if type(lines) ~= "table" then return end
	token += 1
	local my = token
	local per = lineTime or 2.6
	panel.Visible = true
	talking = true
	Sfx.play("Click", { PlaybackSpeed = 0.7 })
	task.spawn(function()
		for _, line in lines do
			if my ~= token then return end
			Sfx.play("GhostWhisper", { PlaybackSpeed = 0.45, Volume = 0.9 })
			local typing = math.min(per * 0.55, #line * 0.03)
			local t0 = os.clock()
			while my == token and os.clock() - t0 < typing do
				text.Text = string.sub(line, 1, math.floor(#line * (os.clock() - t0) / typing))
				task.wait()
			end
			if my ~= token then return end
			text.Text = line
			task.wait(per - typing)
		end
		if my ~= token then return end
		talking = false
		text.Text = "...click."
		who.Text = "LINE DEAD"
		Sfx.play("Click", { PlaybackSpeed = 0.5 })
		task.wait(1.2)
		if my ~= token then return end
		panel.Visible = false
		who.Text = "UNKNOWN CALLER"
	end)
end

return CallerUI
