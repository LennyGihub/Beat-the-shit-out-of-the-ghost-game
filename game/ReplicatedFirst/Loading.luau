--!strict
-- LOADING SCREEN: one full-screen card used everywhere the player waits.
--   * joining the game (ReplicatedFirst/LoadingBoot: replaces Roblox's default screen, waits for the place, the
--     character, and on a match server for the run to take the player in);
--   * teleporting to a match or back to the lobby (Loading.teleport: shown here, handed to TeleportService so it
--     stays up during the teleport, and picked up again on arrival by LoadingBoot);
--   * a run starting on this same server (Studio): Loading.teleport too, hidden once the player is InMatch.
-- The house at night (art: game-art/art/loading_mansion.png), the title, a status line, a progress bar and a tip
-- that changes every few seconds. No emoji, no text in the picture.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Loading = {}
local BG = "rbxassetid://86088724716074"
local INK = Color3.fromRGB(16, 12, 10)
local PAPER = Color3.fromRGB(232, 222, 200)
local EMBER = Color3.fromRGB(255, 110, 60)

Loading.TIPS = {
	"Throw furniture at it: heavy pieces hit harder than your fists.",
	"A charged punch breaks a monster's armour when it is enraged.",
	"Monsters can't be stopped once they start a special move. Get out of the way instead.",
	"The Party Bear's lights-out hunt ends as soon as you land a hit on him.",
	"Walk sideways out of the Golden Conqueror's beam: it turns slower than you can run.",
	"The shop gets new items after every ghost. The wreck itself changes every 3 ghosts.",
	"Every 3rd ghost is a boss variant: twice the health, and a power of its own.",
	"Block (hold) right before a swipe to take far less damage.",
	"Smash a monster through a wall: the slam hurts it.",
	"Dead teammates come back when the wave is over. Stay alive for them.",
	"Low on frames? Set PARTICLES to LOW in the settings.",
	"Time Stop freezes the monster and everything it sent out. The damage lands all at once.",
	"When the phone rings, the Caller is hiding somewhere in the house.",
	"Run cash buys items in the shop; real cash buys ultimates in the lobby.",
}

local gui: ScreenGui? = nil
local parts: { [string]: any } = {}
local shownAt = 0
local token = 0

local function N(class: string, props: { [string]: any }, parent: Instance?): any
	local i = Instance.new(class)
	for k, v in props do (i :: any)[k] = v end
	if parent then i.Parent = parent end
	return i
end

-- build the card (also used as the teleport GUI, so it must work on its own)
function Loading.build(): ScreenGui
	local g = N("ScreenGui", { Name = "LoadingScreen", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = true })
	local root = N("Frame", { Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundColor3 = INK, BorderSizePixel = 0 }, g)
	N("ImageLabel", { Name = "Art", Image = BG, ScaleType = Enum.ScaleType.Crop, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(200, 190, 185), ZIndex = 1 }, root)
	-- dark at the bottom and the sides, so the text reads on the picture
	local shade = N("Frame", { Name = "Shade", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 2 }, root)
	N("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(0.5, 0.65),
		NumberSequenceKeypoint.new(1, 0.05) }) }, shade)
	local title = N("TextLabel", { Name = "Title", Text = "BEAT THE GHOST", Font = Enum.Font.Creepster, TextScaled = true, TextColor3 = EMBER,
		TextStrokeColor3 = INK, TextStrokeTransparency = 0, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.08), Size = UDim2.fromScale(0.8, 0.16), ZIndex = 5 }, root)
	N("UITextSizeConstraint", { MaxTextSize = 110 }, title)
	local status = N("TextLabel", { Name = "Status", Text = "LOADING...", Font = Enum.Font.PermanentMarker, TextScaled = true, TextColor3 = PAPER,
		TextStrokeColor3 = INK, TextStrokeTransparency = 0.2, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.8), Size = UDim2.fromScale(0.7, 0.06), ZIndex = 5 }, root)
	N("UITextSizeConstraint", { MaxTextSize = 40 }, status)
	local bar = N("Frame", { Name = "Bar", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.82), Size = UDim2.fromScale(0.5, 0.018),
		BackgroundColor3 = Color3.fromRGB(30, 22, 18), BorderSizePixel = 0, ZIndex = 5 }, root)
	N("UIStroke", { Color = INK, Thickness = 3 }, bar)
	local fill = N("Frame", { Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.fromRGB(230, 96, 20), BorderSizePixel = 0, ZIndex = 6 }, bar)
	N("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(150, 20, 18), Color3.fromRGB(255, 140, 50)) }, fill)
	local tip = N("TextLabel", { Name = "Tip", Text = "", Font = Enum.Font.SpecialElite, TextScaled = true, TextWrapped = true, TextColor3 = Color3.fromRGB(200, 188, 170),
		TextStrokeColor3 = INK, TextStrokeTransparency = 0.4, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.86), Size = UDim2.fromScale(0.7, 0.07), ZIndex = 5 }, root)
	N("UITextSizeConstraint", { MaxTextSize = 26 }, tip)
	return g
end

local function grab(g: ScreenGui)
	local root = g:FindFirstChild("Root") :: Frame
	parts = {
		root = root,
		title = root:FindFirstChild("Title"),
		status = root:FindFirstChild("Status"),
		fill = (root:FindFirstChild("Bar") :: Frame):FindFirstChild("Fill"),
		tip = root:FindFirstChild("Tip"),
	}
end

local function playerGui(): PlayerGui?
	local lp = Players.LocalPlayer
	return lp and lp:FindFirstChildOfClass("PlayerGui") or (lp and lp:WaitForChild("PlayerGui", 10) :: PlayerGui?)
end

-- show the card (adopt = a GUI that came with a teleport, reused as it is)
function Loading.show(status: string?, adopt: ScreenGui?)
	token += 1 -- (cancels a hide that is waiting)
	if not gui then
		gui = adopt or Loading.build()
		grab(gui :: ScreenGui)
		local pg = playerGui()
		if pg then (gui :: ScreenGui).Parent = pg end
		shownAt = os.clock()
		-- the tips change every 4.5 s; the title flickers like a dying bulb (both stop when this card goes)
		local g = gui
		task.spawn(function()
			local i = math.random(1, #Loading.TIPS)
			while gui == g do
				parts.tip.Text = "TIP:  " .. Loading.TIPS[i]
				i = i % #Loading.TIPS + 1
				task.wait(4.5)
			end
		end)
		task.spawn(function()
			while gui == g do
				parts.title.TextTransparency = math.random() < 0.08 and 0.6 or 0
				task.wait(0.09)
			end
		end)
	end
	local root = parts.root :: Frame
	root.BackgroundTransparency = 0
	for _, d in root:GetDescendants() do
		if d:IsA("TextLabel") then d.TextTransparency = 0; d.TextStrokeTransparency = d.Name == "Tip" and 0.4 or 0.1 end
	end
	if status then parts.status.Text = status end
end

function Loading.status(text: string) if gui then parts.status.Text = text end end
function Loading.progress(x: number)
	if not gui then return end
	TweenService:Create(parts.fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(math.clamp(x, 0, 1), 1) }):Play()
end
function Loading.isShown(): boolean return gui ~= nil end

-- fade out and remove (minShown = keep it up at least that long, so it never just blinks)
function Loading.hide(minShown: number?)
	local g = gui
	if not g then return end
	token += 1
	local my = token
	local wait = (minShown or 0) - (os.clock() - shownAt)
	if wait > 0 then task.wait(wait) end
	if token ~= my or gui ~= g then return end
	Loading.progress(1)
	local info = TweenInfo.new(0.6)
	for _, d in g:GetDescendants() do
		if d:IsA("Frame") then TweenService:Create(d, info, { BackgroundTransparency = 1 }):Play()
		elseif d:IsA("ImageLabel") then TweenService:Create(d, info, { ImageTransparency = 1 }):Play()
		elseif d:IsA("TextLabel") then TweenService:Create(d, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		elseif d:IsA("UIStroke") then TweenService:Create(d, info, { Transparency = 1 }):Play() end
	end
	task.wait(0.65)
	if gui == g then
		g:Destroy()
		gui = nil
	end
end

-- TELEPORTING (to a match, or back to the lobby): the card comes up now and travels with the player.
-- On this same server (Studio runs) it goes again once the player is in the run (12 s at most); a real teleport
-- that never happens gives up after 25 s (a failed one also hides it: TeleportFailed / TeleportInitFailed).
function Loading.teleport(status: string?)
	Loading.show(status or "TELEPORTING...")
	Loading.progress(0.15)
	local lp = Players.LocalPlayer
	if not RunService:IsStudio() and gui then
		pcall(function() game:GetService("TeleportService"):SetTeleportGui(Loading.build()) end)
	end
	local my = token
	task.spawn(function()
		local t0 = os.clock()
		local was = lp:GetAttribute("InMatch") == true
		while token == my and os.clock() - t0 < (RunService:IsStudio() and 12 or 25) do
			Loading.progress(math.min(0.9, 0.15 + (os.clock() - t0) / 8))
			-- (a real teleport takes the player away; only a run on this same server ends it here)
			if RunService:IsStudio() and (lp:GetAttribute("InMatch") == true) ~= was then break end
			task.wait(0.2)
		end
		if token == my then Loading.hide(1.5) end
	end)
end

return Loading
