-- template filled in by run.sh (ULTID, FREEZE, WAIT, CAM, MARK)
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes")
local lp = game.Players.LocalPlayer
-- flush whatever the last cast left frozen
lp:SetAttribute("DebugUltFreezeAt", nil)
lp:SetAttribute("DebugUltScale", 30)
task.wait(0.5)
lp:SetAttribute("DebugUltScale", nil)
local hrp = lp.Character.HumanoidRootPart
local look = hrp.CFrame.LookVector
look = Vector3.new(look.X, 0, look.Z).Unit
local right = look:Cross(Vector3.yAxis)
local mode = "CAM"
local g = workspace:FindFirstChild("Ghost")
local gpos = g and g:GetPivot().Position or (hrp.Position + look * 16)
if mode == "fp" then
	lp:SetAttribute("DebugCam", nil)
else
	-- a free camera: the direction round the scene with the most room, looking at the caster and the ghost
	local mid = mode == "close" and (hrp.Position + Vector3.new(0, 1.5, 0)) or ((hrp.Position + gpos) / 2 + Vector3.new(0, 2, 0))
	local want = mode == "close" and 9 or (mode == "far" and 46 or 27)
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { workspace.Mansion.Structure }
	local best, bestD = nil, -1
	for i = 0, 23 do
		local a = i / 24 * math.pi * 2
		for _, pitch in (mode == "close" and { 0.15 } or { 0.3, 0.5 }) do
			local dir = Vector3.new(math.cos(a) * math.cos(pitch), math.sin(pitch), math.sin(a) * math.cos(pitch))
			local r = workspace:Raycast(mid, dir * want, rp)
			local d = r and (r.Position - mid).Magnitude or want
			-- prefer seeing the caster from the front / side, not through the ghost
			local score = d + (mode == "close" and dir:Dot(look) * 3 or -math.abs(dir:Dot(look)) * 4)
			if score > bestD then bestD = score; best = mid + dir * math.max(4, math.min(d * 0.72, d - 3)) end
		end
	end
	lp:SetAttribute("DebugCamFP", nil)
	lp:SetAttribute("DebugCam", CFrame.lookAt(best, mid))
end
local _, msg = Remotes.Admin:InvokeServer("ult ULTID")
lp:SetAttribute("DebugUltMarkOn", "MARK")
lp:SetAttribute("DebugUltFreezeAt", FREEZE)
task.wait(0.2)
Remotes.Ultimate:FireServer()
task.wait(WAIT)
return tostring(msg) .. " | active=" .. tostring(lp:GetAttribute("UltActive")) .. " fxparts=" .. #workspace.UltFx:GetChildren()
