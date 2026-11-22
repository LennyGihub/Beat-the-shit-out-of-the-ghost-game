--!strict
-- Creates the RemoteEvents in ReplicatedStorage.Remotes (clients WaitForChild them).
local RS = game:GetService("ReplicatedStorage")
local folder = RS:FindFirstChild("Remotes") or Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = RS
local R: { [string]: RemoteEvent } = {}
for _, n in { "Punch", "Ultimate", "Grab", "Throw", "Sprint", "Buy", "NextGhost", "Fx", "BuyUlt", "EquipUlt", "ReturnLobby", "Use", "Select", "Drop", "RoomPick", "BuyMap", "Party", "Revive", "SaveSettings", "Charge", "Block", "Quest", "SwapUlt", "Sandbox", "Platform", "Tutorial", "Forms", "Stage", "Trade", "Codes", "FreeCam", "PatchNotes" } do
	local e = folder:FindFirstChild(n) :: RemoteEvent?
	if not e then
		local ne = Instance.new("RemoteEvent")
		ne.Name = n
		ne.Parent = folder
		e = ne
	end
	R[n] = e :: RemoteEvent
end
return R
