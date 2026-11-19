--!strict
-- WORLD SPIN (2026-11-19): turns the decoration that should move - the lighthouse's lamp beams, a ride's crown -
-- on each client only (nothing is sent over the network). Any Model or BasePart under the loaded map
-- (workspace.Mansion) or the map's world (workspace.Grounds.World) with the attribute Spin = degrees a second turns
-- round the y axis through its pivot. The list is refreshed every 2 s (maps and worlds come and go); far ones
-- (over 600 studs from the camera) are left still.
local RunService = game:GetService("RunService")
local WorldSpin = {}

type Item = { obj: Instance, base: CFrame, speed: number }
local items: { Item } = {}
local seen: { [Instance]: boolean } = {}

local function scan()
	local roots = {} :: { Instance }
	local m = workspace:FindFirstChild("Mansion")
	if m then table.insert(roots, m) end
	local g = workspace:FindFirstChild("Grounds")
	local w = g and g:FindFirstChild("World")
	if w then table.insert(roots, w) end
	-- drop the ones that are gone
	local keep = {} :: { Item }
	local now = {} :: { [Instance]: boolean }
	for _, it in items do
		if it.obj.Parent and it.obj:IsDescendantOf(workspace) then table.insert(keep, it); now[it.obj] = true end
	end
	items, seen = keep, now
	for _, r in roots do
		for _, d in r:GetDescendants() do
			local sp = d:GetAttribute("Spin")
			if type(sp) == "number" and not seen[d] and (d:IsA("Model") or d:IsA("BasePart")) then
				local base = d:IsA("Model") and (d :: Model):GetPivot() or (d :: BasePart).CFrame
				table.insert(items, { obj = d, base = base, speed = math.rad(sp) })
				seen[d] = true
			end
		end
	end
end

function WorldSpin.init()
	task.spawn(function()
		while true do
			pcall(scan)
			task.wait(2)
		end
	end)
	local t = 0
	RunService.RenderStepped:Connect(function(dt)
		t += dt
		if #items == 0 then return end
		local cam = workspace.CurrentCamera
		local cp = cam and cam.CFrame.Position or Vector3.zero
		for _, it in items do
			if (it.base.Position - cp).Magnitude < 600 then
				local cf = it.base * CFrame.Angles(0, t * it.speed, 0)
				if it.obj:IsA("Model") then (it.obj :: Model):PivotTo(cf) else (it.obj :: BasePart).CFrame = cf end
			end
		end
	end)
end

return WorldSpin
