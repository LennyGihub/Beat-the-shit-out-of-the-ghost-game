-- Server entry. A reserved server is a match (everyone fights); any other server (and Studio) is the lobby.
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local Server = script.Parent:WaitForChild("Server")

for _, g in { "Players", "Debris", "Carried", "Thrown" } do
	pcall(function() PhysicsService:RegisterCollisionGroup(g) end)
end
PhysicsService:CollisionGroupSetCollidable("Debris", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Carried", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Carried", "Debris", false)
PhysicsService:CollisionGroupSetCollidable("Carried", "Default", false)
PhysicsService:CollisionGroupSetCollidable("Carried", "Thrown", false)
PhysicsService:CollisionGroupSetCollidable("Thrown", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Thrown", "Debris", false)

local Data = require(Server.Data)
local Furniture = require(Server.Furniture)
local Combat = require(Server.Combat)
local Round = require(Server.Round)
local Lobby = require(Server.Lobby)
local UltRunner = require(Server.UltRunner)

local isMatchServer = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
Round.mode = isMatchServer and "Match" or "Lobby"
Players.CharacterAutoLoads = false

Data.start()
Furniture.init()
Combat.start()
UltRunner.start()
Round.start()
Lobby.start()

local expected = 1
local firstJoin = nil :: number?
local function onPlayer(p: Player)
	if Round.mode == "Match" then
		Round.addToMatch(p)
		local jd = p:GetJoinData()
		local td = jd and jd.TeleportData
		if type(td) == "table" and tonumber(td.size) then expected = math.max(expected, math.clamp(tonumber(td.size) :: number, 1, 4)) end
	else
		Round.removeFromMatch(p)
	end
	-- CharacterAutoLoads is off (so the spawn location is set first): respawn 4 s after dying
	p.CharacterAdded:Connect(function(ch)
		local hum = ch:WaitForChild("Humanoid") :: Humanoid
		hum.Died:Once(function()
			task.delay(4, function() if p.Parent and p.Character == ch then p:LoadCharacter() end end)
		end)
	end)
	p:LoadCharacter()
	Data.load(p)
	if Round.mode == "Match" then
		firstJoin = firstJoin or os.clock()
		-- start when the whole party has arrived (or after 15 s)
		task.spawn(function()
			while not Round.running() do
				if #Round.matchPlayers() >= expected or os.clock() - (firstJoin :: number) > 15 then
					Round.startFight()
					break
				end
				task.wait(0.5)
			end
		end)
	end
end
Players.PlayerAdded:Connect(onPlayer)
for _, p in Players:GetPlayers() do task.spawn(onPlayer, p) end
