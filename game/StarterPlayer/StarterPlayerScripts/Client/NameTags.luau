--!strict
-- LOBBY NAME TAGS: over every player standing in the lobby (not InMatch), the game's own name tag in place of
-- Roblox's white name (the server turns that one off there: Server/Vip): the display name in marker on a dark
-- painted plate, like the HUD, and above it the player's titles as small painted stamps:
--   DEV (red)  = the staff (player attribute Dev, set by Server/Admin)
--   VIP (gold) = VIP Game Pass owners (player attribute VIP, set by Server/Monetization); their name is gold too
-- In a run the tag is gone (Roblox's name / the VIP's gold name there, see Server/Vip).
-- Everything is sized in scale, so the tag shrinks cleanly with distance.
local Players = game:GetService("Players")
local Grunge = require(script.Parent.Grunge)

local NameTags = {}
local lp = Players.LocalPlayer
local tags = {} :: { [Player]: BillboardGui }

local GOLD = Color3.fromRGB(255, 205, 60)
type Title = { attr: string, text: string, paint: Color3, ink: Color3, stroke: number }
local TITLES: { Title } = {
	{ attr = "Dev", text = "DEV", paint = Color3.fromRGB(190, 30, 24), ink = Grunge.PAPER, stroke = 0.2 },
	{ attr = "VIP", text = "VIP", paint = Color3.fromRGB(235, 185, 50), ink = Grunge.INK, stroke = 1 },
}
local CHIP_W, CHIP_GAP = 0.25, 0.04

local function build(p: Player, head: BasePart): BillboardGui
	local seed = p.UserId % 89 + 1
	local bb = Instance.new("BillboardGui")
	bb.Name = "NameTag_" .. p.Name
	bb.Adornee = head
	bb.Size = UDim2.fromScale(6.4, 2.3) -- studs
	bb.StudsOffsetWorldSpace = Vector3.new(0, 2.55, 0)
	bb.MaxDistance = 85
	bb.LightInfluence = 0
	bb.ResetOnSpawn = false
	bb.ZIndexBehavior = Enum.ZIndexBehavior.Global
	-- titles: painted stamps side by side over the plate
	local mine = {} :: { Title }
	for _, t in TITLES do if p:GetAttribute(t.attr) == true then table.insert(mine, t) end end
	local total = #mine * CHIP_W + (#mine - 1) * CHIP_GAP
	for i, t in mine do
		local x = 0.5 - total / 2 + (i - 1) * (CHIP_W + CHIP_GAP)
		local chip = Grunge.brush(bb, {
			Position = UDim2.fromScale(x, 0.04), Size = UDim2.fromScale(CHIP_W, 0.36), Rotation = i % 2 == 1 and -4 or 3, ZIndex = 6,
		}, t.paint, seed + i * 7, 9, false)
		Grunge.text(chip, {
			Text = t.text, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.8, 0.86),
			TextColor3 = t.ink, TextStrokeTransparency = t.stroke, ZIndex = 8,
		})
	end
	-- the name plate, as wide as the name: a blood splat, a torn strip of paper, a dark brush stroke over it (the
	-- paper shows as a ragged edge), the name in marker. No Grunge pen outline: those lines are in pixels, too heavy
	-- on a far-away tag.
	local w = math.clamp(0.3 + (utf8.len(p.DisplayName) or 10) * 0.046, 0.5, 0.94)
	local plate = Grunge.frame(bb, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.44), Size = UDim2.fromScale(w, 0.52), Rotation = -1.2, ZIndex = 2 })
	Grunge.splat(plate, {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.52, 0.5), Size = UDim2.fromScale(1.15, 2.2),
		ImageColor3 = Color3.fromRGB(90, 12, 12), ImageTransparency = 0.5, Rotation = seed * 4, ZIndex = 1,
	})
	Grunge.brush(plate, { Size = UDim2.fromScale(1, 1), ZIndex = 3 }, Color3.fromRGB(205, 195, 172), seed + 3, 14, false)
	Grunge.brush(plate, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.975, 0.82), ZIndex = 4 },
		Color3.fromRGB(26, 20, 18), seed, 14, false)
	Grunge.text(plate, {
		Text = p.DisplayName, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.88, 0.7),
		TextColor3 = p:GetAttribute("VIP") == true and GOLD or Grunge.PAPER, TextStrokeTransparency = 0, ZIndex = 7,
	})
	bb.Parent = lp:WaitForChild("PlayerGui")
	return bb
end

local function refresh(p: Player)
	local old = tags[p]
	if old then old:Destroy(); tags[p] = nil end
	local ch = p.Character
	if not ch or not p.Parent or p:GetAttribute("InMatch") == true then return end
	local head = ch:FindFirstChild("Head")
	if head and head:IsA("BasePart") then tags[p] = build(p, head) end
end

local function onPlayer(p: Player)
	p.CharacterAdded:Connect(function(ch)
		ch:WaitForChild("Head", 10)
		if p.Character == ch then refresh(p) end
	end)
	for _, a in { "InMatch", "VIP", "Dev" } do
		p:GetAttributeChangedSignal(a):Connect(function() refresh(p) end)
	end
	p:GetPropertyChangedSignal("DisplayName"):Connect(function() refresh(p) end)
	refresh(p)
end

function NameTags.init()
	Players.PlayerAdded:Connect(onPlayer)
	Players.PlayerRemoving:Connect(function(p)
		local t = tags[p]
		if t then t:Destroy(); tags[p] = nil end
	end)
	for _, p in Players:GetPlayers() do task.spawn(onPlayer, p) end
end

return NameTags
