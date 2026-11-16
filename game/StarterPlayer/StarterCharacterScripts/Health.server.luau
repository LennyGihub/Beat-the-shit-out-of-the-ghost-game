--!strict
-- Replaces Roblox's default Health script: regenerates 1% of max health per second, but not for
-- Config.Fury.RegenPause seconds after a monster hit you (Fury.cap sets the player attribute LastMonsterHit),
-- so a monster's damage sticks during a fight and you heal back between fights.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)

local ch = script.Parent
local hum = ch:WaitForChild("Humanoid") :: Humanoid
local player = Players:GetPlayerFromCharacter(ch)
local RATE, STEP = 0.01, 1

while hum.Parent and hum.Health > 0 do
	task.wait(STEP)
	local last = player and player:GetAttribute("LastMonsterHit")
	local paused = type(last) == "number" and os.clock() - last < Config.Fury.RegenPause
	if not paused and hum.Health > 0 and hum.Health < hum.MaxHealth then
		hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * RATE * STEP)
	end
end
