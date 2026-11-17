-- Lobby night pass (Edit, standalone: python3 tools/studio.py luau Edit tools/build/lobby_night.luau), after lobby_remake.
--   1 the VIP cabin goes (the VIP pass keeps its other perks)
--   2 darker: the moon fill lights and the lamp posts are turned down (Client/Fx PRESETS.lobby darkens the sky)
--   3 nothing to see outside the park: two rows of tall pines just outside the fence, dark ground under them and a
--     black backdrop behind (it fades into the fog)
--   4 the HALL OF FAME where the cabin stood: three leaderboards (Kills, Wave, Cash) in Lobby.Leaderboards; the server
--     draws them on each board's "Screen" part (Server/Leaderboards)
--   5 Ravenhill Asylum (ServerStorage.Maps.Asylum) is darker: its lights at 65% (from their first brightness)
-- Re-running replaces what it built.
local SS = game:GetService("ServerStorage")
local L = workspace:WaitForChild("Lobby")
local CX, CZ = 0, 1000
local M = Enum.Material
local rng = Random.new(777)
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, solid: boolean?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Anchored = true; p.Size = size; p.CFrame = cf; p.Color = color; p.Material = mat
	p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
	if not solid then p.CanCollide = false; p.CanQuery = false; p.CanTouch = false end
	p.Parent = parent
	return p
end
for _, n in { "VipCabin", "Edge", "Leaderboards" } do
	local o = L:FindFirstChild(n)
	if o then o:Destroy() end
end

-- 2 DARKER ----------------------------------------------------------------------------------------------
for _, c in L:GetChildren() do
	if c.Name == "FillLight" then
		local l = c:FindFirstChildOfClass("PointLight")
		if l then l.Brightness = 0.22; l.Range = 50 end
	elseif c.Name == "LampPost" then
		for _, d in c:GetDescendants() do
			if d:IsA("PointLight") then d.Brightness = 1.4; d.Range = 30 end
		end
	end
end

-- 3 THE EDGE ---------------------------------------------------------------------------------------------
local E = Instance.new("Model"); E.Name = "Edge"; E.Parent = L
part(E, "EdgeGround", Vector3.new(440, 1, 440), CFrame.new(CX, -0.7, CZ), rgb(24, 28, 22), M.Mud)
local PINE = { rgb(20, 40, 32), rgb(18, 34, 28), rgb(24, 44, 34) }
local BARK = rgb(44, 34, 28)
local function farPine(x: number, z: number, s: number)
	local m = Instance.new("Model"); m.Name = "Pine"; m.Parent = E
	local base = CFrame.new(CX + x, 0, CZ + z) * CFrame.Angles(0, rng:NextNumber(0, 6.28), 0)
	local H = rng:NextNumber(44, 58) * s
	part(m, "Trunk", Vector3.new(2.4 * s, H * 0.6, 2.4 * s), base * CFrame.new(0, H * 0.3, 0), BARK, M.Wood)
	for i = 0, 3 do
		local f = i / 3
		local w = (13 - 9 * f) * s
		part(m, "Needles", Vector3.new(w, 3 * s, w), base * CFrame.new(0, H * 0.32 + (H * 0.62) * f, 0) * CFrame.Angles(0, f * 1.3, 0), PINE[rng:NextInteger(1, #PINE)], M.Sand)
	end
	part(m, "Top", Vector3.new(1.8 * s, 6 * s, 1.8 * s), base * CFrame.new(0, H + 2 * s, 0), PINE[1], M.Sand)
	for _, p in m:GetDescendants() do if p:IsA("BasePart") then p.CastShadow = false end end
end
-- a square ring of trees at half-size d (from the park's centre), `step` apart
local function ring(d0: number, d1: number, step: number, s0: number, s1: number)
	for side = 0, 3 do
		local t = -d1
		while t <= d1 do
			local d = rng:NextNumber(d0, d1)
			local a = t + rng:NextNumber(-step * 0.3, step * 0.3)
			local x, z
			if side == 0 then x, z = a, -d elseif side == 1 then x, z = a, d elseif side == 2 then x, z = -d, a else x, z = d, a end
			farPine(x, z, rng:NextNumber(s0, s1))
			t += step
		end
	end
end
ring(143, 152, 10, 1.1, 1.45)
ring(158, 172, 13, 1.5, 2)
-- the black backdrop behind the trees
for i, d in { { 0, -188, 380, 2 }, { 0, 188, 380, 2 }, { -188, 0, 2, 380 }, { 188, 0, 2, 380 } } do
	local w = part(E, "Backdrop", Vector3.new(d[3], 140, d[4]), CFrame.new(CX + d[1], 69, CZ + d[2]), rgb(6, 8, 12), M.SmoothPlastic)
	w.CastShadow = false
end

-- 4 HALL OF FAME ------------------------------------------------------------------------------------------
local HX = 110 -- where the VIP cabin stood (its boards face the park, toward -X)
for _, t in L:WaitForChild("Forest"):GetDescendants() do
	if t:IsA("Model") and t.Parent and t.Parent:IsA("Model") and t.Parent.Name == "HandTrees" then
		local p = t:GetPivot().Position
		if p.X > CX + HX - 10 and p.X < CX + HX + 12 and p.Z > CZ - 30 and p.Z < CZ + 30 then t:Destroy() end
	end
end
local LB = Instance.new("Model"); LB.Name = "Leaderboards"; LB.Parent = L
local WOOD, DARK, IRON = rgb(74, 54, 40), rgb(36, 28, 24), rgb(52, 50, 48)
local WARM = rgb(255, 180, 100)
local function board(id: string, z: number)
	local m = Instance.new("Model"); m.Name = "Board_" .. id; m.Parent = LB
	local pos = Vector3.new(CX + HX, 0, CZ + z)
	local cf = CFrame.lookAt(pos, pos + Vector3.new(-1, 0, 0)) -- front (-Z) toward the park
	for _, x in { -4.7, 4.7 } do part(m, "Post", Vector3.new(0.7, 14, 0.7), cf * CFrame.new(x, 7, 0), WOOD, M.Wood, true) end
	part(m, "Panel", Vector3.new(9, 11, 0.6), cf * CFrame.new(0, 8, 0.1), DARK, M.Wood, true)
	local sc = part(m, "Screen", Vector3.new(8, 9.92, 0.1), cf * CFrame.new(0, 8, -0.25), rgb(18, 14, 12), M.SmoothPlastic)
	sc.CastShadow = false
	part(m, "Roof", Vector3.new(10.6, 0.5, 2.8), cf * CFrame.new(0, 14.2, -0.2) * CFrame.Angles(math.rad(-12), 0, 0), rgb(60, 40, 32), M.WoodPlanks)
	for _, y in { 2.4, 13.6 } do part(m, "Trim", Vector3.new(9.4, 0.4, 0.8), cf * CFrame.new(0, y, 0), WOOD, M.Wood) end
	local lan = part(m, "Lantern", Vector3.new(0.7, 0.9, 0.7), cf * CFrame.new(0, 13.2, -1.1), WARM, M.Neon)
	part(m, "Hook", Vector3.new(0.15, 0.6, 0.15), cf * CFrame.new(0, 13.8, -1.1), IRON, M.Metal)
	local l = Instance.new("PointLight"); l.Color = WARM; l.Range = 12; l.Brightness = 0.9; l.Parent = lan
	m.PrimaryPart = sc
end
board("Kills", -14)
board("Wave", 0)
board("Cash", 14)
-- the sign over the middle board
local spos = Vector3.new(CX + HX + 0.3, 0, CZ)
local scf = CFrame.lookAt(spos, spos + Vector3.new(-1, 0, 0))
local sign = part(LB, "HallSign", Vector3.new(14, 2.4, 0.4), scf * CFrame.new(0, 16.6, 0), WOOD, M.WoodPlanks)
for _, x in { -5, 5 } do part(LB, "SignChain", Vector3.new(0.15, 2.2, 0.15), scf * CFrame.new(x, 15.2, 0), IRON, M.Metal) end
local sg = Instance.new("SurfaceGui"); sg.Face = Enum.NormalId.Front; sg.CanvasSize = Vector2.new(700, 120); sg.LightInfluence = 0; sg.Brightness = 1; sg.Parent = sign
local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 1); t.Font = Enum.Font.Creepster; t.TextScaled = true
t.Text = "HALL OF FAME"; t.TextColor3 = rgb(240, 190, 90); t.TextStrokeTransparency = 0.3; t.Parent = sg

-- 5 THE ASYLUM, DARKER -------------------------------------------------------------------------------------
local asylum = SS:FindFirstChild("Maps") and SS.Maps:FindFirstChild("Asylum")
local dimmed = 0
if asylum then
	for _, d in asylum:GetDescendants() do
		if d:IsA("Light") then
			local base = d:GetAttribute("BaseBrightness")
			if type(base) ~= "number" then base = d.Brightness; d:SetAttribute("BaseBrightness", base) end
			d.Brightness = base * 0.65
			dimmed += 1
		end
	end
end
local n = 0
for _ in E:GetDescendants() do n += 1 end
return string.format("VIP cabin gone, edge built (%d instances), 3 leaderboards, %d asylum lights dimmed", n, dimmed)
