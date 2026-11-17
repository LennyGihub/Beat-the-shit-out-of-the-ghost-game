--!strict
-- The Caller's phone call (server: Server/Caller, Fx event "CallerCall"): the player who picked the ringing phone
-- up gets his voice as lines of text at the bottom of the screen, one after the other, with a low distorted
-- whisper under each. What he says names the room he is hiding in (never the exact spot); nothing is marked.
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

function CallerUI.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "CallerCall"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 3
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.43, 0, 0.8, 0), Size = UDim2.fromScale(0.42, 0.13),
		BackgroundTransparency = 0.25, BackgroundColor3 = Grunge.INK, Rotation = -0.6, Visible = false })
	local lim = Instance.new("UISizeConstraint"); lim.MinSize = Vector2.new(380, 84); lim.MaxSize = Vector2.new(720, 130); lim.Parent = panel
	Grunge.frame(panel, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(150, 18, 20), Size = UDim2.new(0, 5, 1, 0) })
	who = Grunge.text(panel, { Text = "UNKNOWN CALLER", Font = Grunge.HORROR, Position = UDim2.new(0, 18, 0.08, 0), Size = UDim2.new(0.6, -18, 0.3, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(230, 60, 50) })
	local wc = Instance.new("UITextSizeConstraint"); wc.MaxTextSize = 24; wc.Parent = who
	text = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.new(0, 18, 0.42, 0), Size = UDim2.new(1, -36, 0.5, 0),
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true })
	local tc = Instance.new("UITextSizeConstraint"); tc.MaxTextSize = 22; tc.Parent = text
end

-- lines = what he says; each stays `lineTime` seconds, typed out letter by letter
function CallerUI.call(lines: { string }, lineTime: number?)
	if type(lines) ~= "table" then return end
	token += 1
	local my = token
	local per = lineTime or 2.6
	panel.Visible = true
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
