-- Server entry: collision groups, data, furniture, combat, rounds.
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

Data.start()
Furniture.init()
Combat.start()
Round.start()

local function onPlayer(p: Player)
	Data.load(p)
	Round.onPlayerReady()
end
Players.PlayerAdded:Connect(onPlayer)
for _, p in Players:GetPlayers() do task.spawn(onPlayer, p) end
