--!strict
-- GLOBAL LEADERBOARDS in the lobby park (three boards in workspace.Lobby.Leaderboards, tools/build/lobby_night.luau):
-- the top 10 of every player ever for KILLS (monsters beaten), HIGHEST WAVE (the furthest wave beaten in a run) and
-- MONEY (cash). Each one is an OrderedDataStore; every server writes its players' scores (every 2 min and when they
-- leave, only when they changed), lobby servers read the tops every 2 min and draw them on the boards.
-- Studio has no DataStores: the boards then show the players in the server, so they can be checked.
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Data = require(script.Parent.Data)

local Leaderboards = {}
type Board = { id: string, title: string, unit: string, color: Color3, value: (d: any) -> number }
local BOARDS: { Board } = {
	{ id = "Kills", title = "TOP KILLERS", unit = "KILLS", color = Color3.fromRGB(230, 70, 50), value = function(d) return d.Kills or 0 end },
	{ id = "Wave", title = "HIGHEST WAVE", unit = "WAVE", color = Color3.fromRGB(240, 180, 60),
		value = function(d) return math.max(0, (d.GhostLevel or 1) - 1) end }, -- GhostLevel = the furthest wave beaten + 1
	{ id = "Cash", title = "RICHEST", unit = "$", color = Color3.fromRGB(130, 220, 100), value = function(d) return d.Cash or 0 end },
}
local REFRESH = 120
local STUDIO = RunService:IsStudio()
local stores = {} :: { [string]: OrderedDataStore }
if not STUDIO then
	for _, b in BOARDS do
		local ok, s = pcall(function() return DSS:GetOrderedDataStore("LB_" .. b.id .. "_v1") end)
		if ok then stores[b.id] = s end
	end
end
local written = {} :: { [Player]: { [string]: number } }

-- write a player's scores (only the ones that changed since the last write)
local function write(p: Player)
	local d = Data.get(p)
	if not d or not Data.loaded(p) then return end
	local last = written[p] or {}
	written[p] = last
	for _, b in BOARDS do
		local v = math.floor(b.value(d))
		local s = stores[b.id]
		if s and last[b.id] ~= v and v > 0 then
			local ok = pcall(function() s:SetAsync("u_" .. p.UserId, v) end)
			if ok then last[b.id] = v end
		end
	end
end

-- names of the people on the boards (cached)
local names = {} :: { [number]: string }
local function nameOf(id: number): string
	if names[id] then return names[id] end
	local p = Players:GetPlayerByUserId(id)
	if p then names[id] = p.DisplayName; return p.DisplayName end
	local ok, n = pcall(function() return Players:GetNameFromUserIdAsync(id) end)
	names[id] = ok and n or "???"
	return names[id]
end

local function fmt(n: number): string
	if n >= 1e9 then return string.format("%.1fB", n / 1e9) end
	if n >= 1e6 then return string.format("%.1fM", n / 1e6) end
	if n >= 1e4 then return string.format("%.1fK", n / 1e3) end
	return tostring(n)
end

-- one board's screen: a title and 10 rows (rank, name, score)
local function screen(model: Model, b: Board): { TextLabel }?
	local part = model:FindFirstChild("Screen", true) :: BasePart?
	if not part then return nil end
	local old = part:FindFirstChild("Board") if old then old:Destroy() end
	local sg = Instance.new("SurfaceGui")
	sg.Name = "Board"; sg.Face = Enum.NormalId.Front; sg.CanvasSize = Vector2.new(500, 620); sg.LightInfluence = 0; sg.Brightness = 1.1
	sg.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize; sg.Parent = part
	local bg = Instance.new("Frame"); bg.Size = UDim2.fromScale(1, 1); bg.BackgroundColor3 = Color3.fromRGB(18, 14, 12); bg.BorderSizePixel = 0; bg.Parent = sg
	local function label(text: string, y: number, h: number, font: Enum.Font, color: Color3, xa: Enum.TextXAlignment?, x: number?, w: number?): TextLabel
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1; l.Text = text; l.Font = font; l.TextScaled = true; l.TextColor3 = color
		l.TextStrokeTransparency = 0.4; l.TextStrokeColor3 = Color3.fromRGB(10, 8, 6)
		l.Position = UDim2.fromScale(x or 0.04, y); l.Size = UDim2.fromScale(w or 0.92, h); l.TextXAlignment = xa or Enum.TextXAlignment.Center
		l.Parent = bg
		return l
	end
	label(b.title, 0.02, 0.12, Enum.Font.Creepster, b.color)
	local line = Instance.new("Frame"); line.BackgroundColor3 = b.color; line.BorderSizePixel = 0
	line.Position = UDim2.fromScale(0.06, 0.15); line.Size = UDim2.fromScale(0.88, 0.006); line.Parent = bg
	local rows = {}
	for i = 1, 10 do
		local y = 0.17 + (i - 1) * 0.081
		local col = i == 1 and Color3.fromRGB(255, 210, 90) or (i <= 3 and Color3.fromRGB(225, 215, 195) or Color3.fromRGB(180, 170, 152))
		label(i .. ".", y, 0.07, Enum.Font.PermanentMarker, col, Enum.TextXAlignment.Left, 0.05, 0.1)
		local nm = label("---", y, 0.07, Enum.Font.SpecialElite, col, Enum.TextXAlignment.Left, 0.16, 0.52)
		local sc = label("", y, 0.07, Enum.Font.PermanentMarker, b.color, Enum.TextXAlignment.Right, 0.66, 0.3)
		table.insert(rows, nm); table.insert(rows, sc)
	end
	return rows
end

local function draw(rows: { TextLabel }, b: Board, list: { { name: string, v: number } })
	for i = 1, 10 do
		local e = list[i]
		rows[i * 2 - 1].Text = e and e.name or "---"
		rows[i * 2].Text = e and ((b.unit == "$" and "$" or "") .. fmt(e.v)) or ""
	end
end

-- the top 10 of one board
local function top(b: Board): { { name: string, v: number } }
	local out = {}
	local s = stores[b.id]
	if s then
		local ok, page = pcall(function() return s:GetSortedAsync(false, 10) end)
		if ok and page then
			for _, e in page:GetCurrentPage() do
				local id = tonumber(string.match(e.key, "^u_(%d+)$"))
				if id then table.insert(out, { name = nameOf(id), v = e.value }) end
			end
		end
	else
		-- Studio: the players in this server
		for _, p in Players:GetPlayers() do
			local d = Data.get(p)
			if d then table.insert(out, { name = p.DisplayName, v = math.floor(b.value(d)) }) end
		end
		table.sort(out, function(x, y) return x.v > y.v end)
	end
	return out
end

function Leaderboards.start(isLobby: boolean)
	Players.PlayerRemoving:Connect(function(p)
		write(p)
		written[p] = nil
	end)
	-- every server writes its players' scores
	task.spawn(function()
		while true do
			task.wait(REFRESH)
			for _, p in Players:GetPlayers() do task.spawn(write, p) end
		end
	end)
	if not isLobby then return end
	-- lobby servers draw the boards
	task.spawn(function()
		local lobby = workspace:WaitForChild("Lobby", 30)
		local folder = lobby and lobby:WaitForChild("Leaderboards", 30)
		if not folder then warn("[Leaderboards] no Lobby.Leaderboards in the workspace"); return end
		local screens = {} :: { [string]: { TextLabel } }
		for _, b in BOARDS do
			local m = folder:FindFirstChild("Board_" .. b.id) :: Model?
			local rows = m and screen(m, b)
			if rows then screens[b.id] = rows end
		end
		task.wait(STUDIO and 3 or 8) -- (the first players' saves load meanwhile)
		while true do
			for _, b in BOARDS do
				local rows = screens[b.id]
				if rows then draw(rows, b, top(b)) end
			end
			task.wait(STUDIO and 15 or REFRESH)
		end
	end)
end

return Leaderboards
