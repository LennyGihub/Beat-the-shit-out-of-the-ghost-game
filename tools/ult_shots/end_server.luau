-- template filled in by run.sh (DIST): stops the running ultimate and holds the monster DIST studs in front
local RS = game:GetService("ReplicatedStorage")
local p = game.Players:GetPlayers()[1]
p:SetAttribute("DebugUltEnd", os.clock())
local hrp = p.Character.HumanoidRootPart
RS:SetAttribute("DebugFreezeGhost", true)
RS:SetAttribute("DebugGhostGod", true)
local look = hrp.CFrame.LookVector
look = Vector3.new(look.X, 0, look.Z).Unit
local at = hrp.Position + look * DIST
RS:SetAttribute("DebugGhostAt", CFrame.lookAt(at + Vector3.new(0, 1.5, 0), Vector3.new(hrp.Position.X, at.Y + 1.5, hrp.Position.Z)))
return "ok"
