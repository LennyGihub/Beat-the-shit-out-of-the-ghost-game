-- Lobby: standing on a room pad shows the room's map + difficulty. The leader (first on the pad)
-- cycles them with the arrows (only maps they own); everyone else just sees the pick.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Maps = require(RS.Shared.Maps)
local Grunge = require(script.Parent.Grunge)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local UI = {}
local lp = Players.LocalPlayer
local gui: ScreenGui
local panel: Frame
local mapName: TextLabel
local mapDesc: TextLabel
local diffName: TextLabel
local who: TextLabel
local arrows = {} :: { TextButton }
local room: Instance? = nil

local function ownedMaps(): { string }
	local owned = {}
	for id in string.gmatch(lp:GetAttribute("Owned") or "", "[^,]+") do owned[id] = true end
	local out = {}
	for _, m in Maps.list do
		if m.id == "Mansion" or owned["Map_" .. m.id] then table.insert(out, m.id) end
	end
	return out
end

local function roomModel(): Instance?
	local name = lp:GetAttribute("QueueRoom")
	local lobby = workspace:FindFirstChild("Lobby")
	local rooms = lobby and lobby:FindFirstChild("Rooms")
	return type(name) == "string" and rooms and rooms:FindFirstChild(name) or nil
end

local function isLeader(): boolean
	return room ~= nil and (room :: Instance):GetAttribute("Leader") == lp.UserId
end

local function refresh()
	room = roomModel()
	gui.Enabled = room ~= nil and not lp:GetAttribute("InMatch")
	if not room then return end
	local m = Maps.byId[room:GetAttribute("Map") or "Mansion"] or Maps.byId.Mansion
	local d = Maps.diffById[room:GetAttribute("Diff") or "Normal"] or Maps.diffById.Normal
	mapName.Text = string.upper(m.name)
	mapName.TextColor3 = m.color:Lerp(Grunge.PAPER, 0.4)
	mapDesc.Text = m.desc
	diffName.Text = d.name .. "   " .. d.desc
	diffName.TextColor3 = d.color
	local lead = isLeader()
	for _, a in arrows do a.Visible = lead end
	who.Text = lead and "YOU PICK THE MAP AND DIFFICULTY  (BUY MORE MAPS AT THE HOODED DEALER)" or "THE ROOM LEADER PICKS THE MAP"
end

local function send(mapId: string, diffId: string)
	if not room then return end
	Sfx.play("Click")
	Remotes.RoomPick:FireServer(room.Name, mapId, diffId)
end

local function cycleMap(step: number)
	if not room then return end
	local list = ownedMaps()
	local cur = table.find(list, room:GetAttribute("Map") or "Mansion") or 1
	local nxt = list[((cur - 1 + step) % #list) + 1]
	send(nxt, room:GetAttribute("Diff") or "Normal")
end

local function cycleDiff(step: number)
	if not room then return end
	local ids = {}
	for _, d in Maps.difficulties do table.insert(ids, d.id) end
	local cur = table.find(ids, room:GetAttribute("Diff") or "Normal") or 2
	send(room:GetAttribute("Map") or "Mansion", ids[((cur - 1 + step) % #ids) + 1])
end

local function arrow(parent: Instance, text: string, x: number, y: number, fn: () -> ())
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true; b.BorderSizePixel = 0; b.BackgroundColor3 = Color3.fromRGB(120, 24, 20)
	b.Font = Grunge.FONT; b.Text = text; b.TextScaled = true; b.TextColor3 = Grunge.PAPER
	b.AnchorPoint = Vector2.new(0.5, 0.5); b.Position = UDim2.fromScale(x, y); b.Size = UDim2.fromScale(0.07, 0.22); b.ZIndex = 12
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 1; ar.Parent = b
	local st = Instance.new("UIStroke"); st.Color = Grunge.INK; st.Thickness = 3; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Parent = b
	b.Parent = parent
	b.MouseButton1Click:Connect(fn)
	table.insert(arrows, b)
	return b
end

function UI.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "RoomPick"; gui.ResetOnSpawn = false; gui.Enabled = false
	gui.Parent = lp:WaitForChild("PlayerGui")
	panel = Grunge.panel(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromScale(0.5, 0.22) }, 33)
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 3.6; ar.Parent = panel
	Grunge.text(panel, { Text = "MAP", Font = Grunge.TYPE, Position = UDim2.fromScale(0.12, 0.05), Size = UDim2.fromScale(0.2, 0.13), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 10 })
	mapName = Grunge.text(panel, { Text = "", Font = Grunge.HORROR, Position = UDim2.fromScale(0.12, 0.15), Size = UDim2.fromScale(0.76, 0.24), ZIndex = 10 })
	mapDesc = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.12, 0.39), Size = UDim2.fromScale(0.76, 0.11), TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 10 })
	Grunge.text(panel, { Text = "DIFFICULTY", Font = Grunge.TYPE, Position = UDim2.fromScale(0.12, 0.53), Size = UDim2.fromScale(0.3, 0.11), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 180, 160), ZIndex = 10 })
	diffName = Grunge.text(panel, { Text = "", Position = UDim2.fromScale(0.12, 0.63), Size = UDim2.fromScale(0.76, 0.17), ZIndex = 10 })
	who = Grunge.text(panel, { Text = "", Font = Grunge.TYPE, Position = UDim2.fromScale(0.05, 0.84), Size = UDim2.fromScale(0.9, 0.1), TextColor3 = Color3.fromRGB(150, 140, 120), ZIndex = 10 })
	arrow(panel, "<", 0.06, 0.3, function() cycleMap(-1) end)
	arrow(panel, ">", 0.94, 0.3, function() cycleMap(1) end)
	arrow(panel, "<", 0.06, 0.7, function() cycleDiff(-1) end)
	arrow(panel, ">", 0.94, 0.7, function() cycleDiff(1) end)
	lp:GetAttributeChangedSignal("QueueRoom"):Connect(refresh)
	lp:GetAttributeChangedSignal("InMatch"):Connect(refresh)
	lp:GetAttributeChangedSignal("Owned"):Connect(refresh)
	task.spawn(function()
		while true do
			task.wait(0.25)
			if room or gui.Enabled then refresh() end
		end
	end)
	refresh()
end

return UI
