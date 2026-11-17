-- Third-person cast poses (UltPose): NAMES = "slam", "sweep", ... (up to 6), FREEZE = the moment of the pose (0..1),
-- HOLD = seconds the row of copies of your character stays posed (take the screenshot meanwhile, from a second
-- shell: the poses live in this script's own copy of UltPose and end with it).
local lp = game.Players.LocalPlayer
local Client = lp.PlayerScripts:WaitForChild("Client")
local Pose = require(Client.UltPose)
Pose.init()
local names = { NAMES }
local ch = lp.Character
ch.Archivable = true
local hrp = ch.HumanoidRootPart
local look = hrp.CFrame.LookVector
look = Vector3.new(look.X, 0, look.Z).Unit
local right = look:Cross(Vector3.yAxis)
local old = workspace:FindFirstChild("PoseDummies")
if old then old:Destroy() end
local folder = Instance.new("Folder"); folder.Name = "PoseDummies"; folder.Parent = workspace
local base = hrp.Position + look * 11
local list = {}
for i, name in names do
	local d = ch:Clone()
	for _, x in d:GetDescendants() do
		if x:IsA("LuaSourceContainer") then x:Destroy() end
		if x:IsA("BasePart") then x.LocalTransparencyModifier = 0; x.Anchored = x.Name == "HumanoidRootPart" end
	end
	d.Name = name
	d.Parent = folder
	d:PivotTo(CFrame.lookAt(base + right * ((i - (#names + 1) / 2) * 4.2), base + right * ((i - (#names + 1) / 2) * 4.2) - look))
	list[i] = d
end
task.wait(0.3)
for i, name in names do Pose.play(list[i], name, FREEZE) end
lp:SetAttribute("DebugCamFP", nil)
lp:SetAttribute("DebugCam", CFrame.lookAt(base - look * 9.5 + Vector3.new(0, 2.5, 0), base + Vector3.new(0, 0.3, 0)))
task.wait(HOLD)
folder:Destroy()
lp:SetAttribute("DebugCam", nil)
return "posed " .. #list
