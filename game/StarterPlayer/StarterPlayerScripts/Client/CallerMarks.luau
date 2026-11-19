--!strict
-- What the players are shown during the Caller's ambush (Server/Caller):
--   * THE RINGING PHONE (workspace.CallerPhone while its attribute Ringing is true): a yellow outline you can see
--     through the walls, and a yellow arrow. While the phone is out of view the arrow sits on a ring round the
--     middle of the screen and points the way to turn; once the phone is in view it hangs over it, pointing down.
--     Under the arrow: PHONE and how far it is.
--   * THE ROOM HE SITS IN (Fx "CallerRoom": box CFrame, size, seconds; "CallerRoomOff"): that room's walls
--     outlined in yellow and filled with a fainter, see-through yellow, visible through the whole house. It
--     shows when he names the room on the phone - the room, never his corner.
--   * ANY MARKED THING (CollectionService tag "MarkTarget" with a non-empty attribute Mark = its name, MarkColor):
--     the same outline (its colour) and arrow, e.g. Madame Fortune's CRYSTAL BALL while it is whole
--     (Server/CarnivalMonsters). The ringing phone goes first.
-- Only in a run (a player in the park gets nothing).
-- Studio test hook: player attribute DebugRoomMark = CFrame (see init).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Grunge = require(script.Parent.Grunge)

local Marks = {}
local lp = Players.LocalPlayer
local YELLOW = Color3.fromRGB(255, 214, 60)

local gui: ScreenGui
local arrow: Frame
local label: TextLabel
local phone: Model? = nil
local phoneGlow: Highlight? = nil
local markGlow: Highlight? = nil
local room: Model? = nil
local roomUntil = 0

-- a block arrow pointing up (the frame is turned to point anywhere): yellow over a wider ink copy of itself
local function buildArrow(parent: Instance): Frame
	local a = Instance.new("Frame")
	a.Name = "PhoneArrow"; a.BackgroundTransparency = 1; a.Size = UDim2.fromOffset(52, 52); a.AnchorPoint = Vector2.new(0.5, 0.5); a.Visible = false
	local function bar(w: number, h: number, x: number, y: number, rot: number, color: Color3, z: number)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0; f.BackgroundColor3 = color; f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Size = UDim2.fromOffset(w, h); f.Position = UDim2.new(0.5, x, 0.5, y); f.Rotation = rot; f.ZIndex = z
		f.Parent = a
	end
	for _, layer in { { Grunge.INK, 6, 1 }, { YELLOW, 0, 2 } } do
		local color, grow, z = layer[1] :: Color3, layer[2] :: number, layer[3] :: number
		bar(10 + grow, 26 + grow, 0, 8, 0, color, z) -- shaft
		bar(10 + grow, 28 + grow, -9, -8, 45, color, z) -- head, left stroke
		bar(10 + grow, 28 + grow, 9, -8, -45, color, z) -- head, right stroke
	end
	a.Parent = parent
	return a
end

local function setPhone(m: Model?)
	if phoneGlow then phoneGlow:Destroy(); phoneGlow = nil end
	phone = m
end

local clearRoom: () -> ()

-- The room (box cf / size), for `seconds`: its WALLS light up - a yellow outline round them and a fainter,
-- see-through yellow fill, visible through the whole house (doorways and windows stay open).
-- How: a Highlight (always on top) only draws on solid parts here, and anything see-through that stands behind a
-- wall is not drawn at all (panels, adornments, SurfaceGuis: all tried). So every wall piece on the edge of the
-- room gets a solid copy a little smaller than itself, hidden INSIDE the real wall, and the Highlight is put on
-- those copies. A copy goes when its wall is smashed.
local roomSrc = {} :: { [BasePart]: BasePart } -- copy -> the wall it sits in
function Marks.room(cf: CFrame, size: Vector3, seconds: number?)
	if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" or not lp:GetAttribute("InMatch") then return end
	clearRoom()
	local live = workspace:FindFirstChild("Mansion")
	local structure = live and live:FindFirstChild("Structure")
	if not structure then return end
	local m = Instance.new("Model")
	m.Name = "CallerRoomMark"
	m:SetAttribute("Box", cf); m:SetAttribute("BoxSize", size)
	local c, half = cf.Position, size / 2
	local OUT, IN = 1.7, 1.2 -- a wall's body lies just outside the room's faces; things further in are not walls
	local y1, y2 = c.Y - half.Y, c.Y + half.Y
	table.clear(roomSrc)
	for _, p in structure:GetDescendants() do
		if p:IsA("BasePart") and p.CanCollide and p.Transparency < 0.3 and p.Size.Y >= 3 then
			local r, u = p.CFrame.RightVector, p.CFrame.UpVector
			if math.abs(u.Y) > 0.999 and (math.abs(r.X) > 0.999 or math.abs(r.Z) > 0.999) then
				local alongX = math.abs(r.X) > 0.5
				local sx, sz = alongX and p.Size.X or p.Size.Z, alongX and p.Size.Z or p.Size.X
				local thin = math.min(sx, sz)
				if thin >= 0.9 and thin <= 3.3 then
					local x1, x2 = math.max(p.Position.X - sx / 2, c.X - half.X - OUT), math.min(p.Position.X + sx / 2, c.X + half.X + OUT)
					local z1, z2 = math.max(p.Position.Z - sz / 2, c.Z - half.Z - OUT), math.min(p.Position.Z + sz / 2, c.Z + half.Z + OUT)
					local b1, b2 = math.max(p.Position.Y - p.Size.Y / 2, y1), math.min(p.Position.Y + p.Size.Y / 2, y2)
					if x2 - x1 > 0.5 and z2 - z1 > 0.5 and b2 - b1 > 1 then
						local mx, mz = (x1 + x2) / 2, (z1 + z2) / 2
						local inside = mx > c.X - half.X + IN and mx < c.X + half.X - IN and mz > c.Z - half.Z + IN and mz < c.Z + half.Z - IN
						if not inside then
							local q = Instance.new("Part")
							q.Name = "Wall"; q.Anchored = true; q.CanCollide = false; q.CanQuery = false; q.CanTouch = false; q.CastShadow = false
							q.Material = Enum.Material.SmoothPlastic; q.Color = YELLOW
							q.Size = Vector3.new(math.max((x2 - x1) - (sx <= sz and 0.3 or 0.12), 0.2), b2 - b1 - 0.12, math.max((z2 - z1) - (sz < sx and 0.3 or 0.12), 0.2))
							q.CFrame = CFrame.new(mx, (b1 + b2) / 2, mz)
							q.Parent = m
							roomSrc[q] = p
						end
					end
				end
			end
		end
	end
	local h = Instance.new("Highlight")
	h.Adornee = m; h.FillColor = YELLOW; h.FillTransparency = 0.8; h.OutlineColor = YELLOW; h.OutlineTransparency = 0
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = m
	m.Parent = workspace
	room = m
	roomUntil = os.clock() + math.clamp(seconds or 20, 3, 60)
end

clearRoom = function()
	if room then room:Destroy(); room = nil end
	table.clear(roomSrc)
end

function Marks.roomOff() clearRoom() end

local function step()
	local now = os.clock()
	local inMatch = lp:GetAttribute("InMatch") == true
	-- the room
	if room then
		if now > roomUntil or not inMatch then
			clearRoom()
		else
			-- the fill breathes a little, always fainter than the outline; a smashed wall takes its copy with it
			local h = room:FindFirstChildOfClass("Highlight")
			if h then h.FillTransparency = 0.76 + (math.sin(now * 3) * 0.5 + 0.5) * 0.1 end
			for q, src in roomSrc do
				if not src.Parent or not src:IsDescendantOf(workspace) then q:Destroy(); roomSrc[q] = nil end
			end
		end
	end
	-- the phone
	local ph = phone
	if ph and not ph.Parent then setPhone(nil); ph = nil end
	local base = ph and ph:FindFirstChild("Base") :: BasePart?
	local ringing = ph ~= nil and base ~= nil and inMatch and ph:GetAttribute("Ringing") == true
	-- (no phone ringing: a marked thing, if there is one)
	local mark: BasePart? = nil
	if not ringing and inMatch then
		for _, t in CollectionService:GetTagged("MarkTarget") do
			if t:IsA("BasePart") and t:IsDescendantOf(workspace) and (t:GetAttribute("Mark") or "") ~= "" then mark = t; break end
		end
	end
	if markGlow and (not mark or markGlow.Adornee ~= mark) then markGlow:Destroy(); markGlow = nil end
	if not ringing or not ph or not base then
		if phoneGlow then phoneGlow:Destroy(); phoneGlow = nil end
		if not mark then
			arrow.Visible = false; label.Visible = false
			return
		end
	end
	local target: BasePart
	local name = "PHONE"
	if ringing and ph and base then
		target = base
		if not phoneGlow then
			local h = Instance.new("Highlight")
			h.Name = "RingGlow"; h.Adornee = ph; h.FillColor = YELLOW; h.OutlineColor = YELLOW; h.OutlineTransparency = 0
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = ph
			phoneGlow = h
		end
		(phoneGlow :: Highlight).FillTransparency = 0.55 + (math.sin(now * 9) * 0.5 + 0.5) * 0.4 -- it flickers like the bell
	else
		local mk = mark :: BasePart
		target = mk
		name = tostring(mk:GetAttribute("Mark"))
		if not markGlow then
			local c = mk:GetAttribute("MarkColor")
			local col = typeof(c) == "Color3" and c or YELLOW
			local h = Instance.new("Highlight")
			h.Name = "MarkGlow"; h.Adornee = mk; h.FillColor = col; h.OutlineColor = col; h.OutlineTransparency = 0
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = mk
			markGlow = h
		end
		(markGlow :: Highlight).FillTransparency = 0.45 + (math.sin(now * 4) * 0.5 + 0.5) * 0.35
	end
	local cam = workspace.CurrentCamera
	local vp = cam.ViewportSize
	local at = target.Position + Vector3.new(0, 1.3, 0)
	local v = cam:WorldToViewportPoint(at)
	local margin = 80
	local x, y, rot
	if v.Z > 0 and v.X > margin and v.X < vp.X - margin and v.Y > margin + 50 and v.Y < vp.Y - margin then
		x, y, rot = v.X, v.Y - 62 - math.abs(math.sin(now * 5)) * 12, 180 -- in view: over it, pointing down, bobbing
	else
		local rel = cam.CFrame:PointToObjectSpace(at)
		local dir = Vector2.new(rel.X, -rel.Y)
		dir = dir.Magnitude > 0.001 and dir.Unit or Vector2.new(0, 1)
		local r = math.min(vp.X, vp.Y) * 0.34 + math.sin(now * 5) * 6
		x, y = vp.X / 2 + dir.X * r, vp.Y / 2 + dir.Y * r
		rot = math.deg(math.atan2(dir.X, -dir.Y))
	end
	arrow.Position = UDim2.fromOffset(x, y); arrow.Rotation = rot; arrow.Visible = true
	local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local dist = hrp and (hrp.Position - target.Position).Magnitude or (cam.CFrame.Position - target.Position).Magnitude
	label.Text = name .. "  " .. tostring(math.floor(dist + 0.5))
	label.Position = UDim2.fromOffset(x, y + (rot == 180 and -44 or 40)); label.Visible = true
end

function Marks.init()
	gui = Instance.new("ScreenGui")
	gui.Name = "CallerMarks"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 2
	gui.Parent = lp:WaitForChild("PlayerGui")
	arrow = buildArrow(gui)
	label = Grunge.text(gui, { Text = "PHONE", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(220, 24), TextColor3 = YELLOW, Visible = false })
	label.TextScaled = false; label.TextSize = 20
	local function watch(c: Instance)
		if c.Name == "CallerPhone" and c:IsA("Model") then setPhone(c) end
	end
	for _, c in workspace:GetChildren() do watch(c) end
	workspace.ChildAdded:Connect(watch)
	RunService:BindToRenderStep("CallerMarks", Enum.RenderPriority.Camera.Value + 3, step)
	if RunService:IsStudio() then
		-- Studio test hook: player attribute DebugRoomMark = CFrame marks the walls round a 40 x 16 x 40 box there for 30 s
		lp:GetAttributeChangedSignal("DebugRoomMark"):Connect(function()
			local cf = lp:GetAttribute("DebugRoomMark")
			if typeof(cf) == "CFrame" then Marks.room(cf, Vector3.new(40, 16, 40), 30) else Marks.roomOff() end
		end)
	end
end

return Marks
