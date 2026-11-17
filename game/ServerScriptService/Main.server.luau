-- Server entry. A reserved server is a match (everyone fights); any other server (and Studio) is the lobby.
local Players = game:GetService("Players")
-- first thing: no automatic spawn (it could drop a joining player at the house's MatchSpawn before the lobby
-- code below has set where they belong)
Players.CharacterAutoLoads = false
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
local Run = require(Server.Run)
local Inventory = require(Server.Inventory)
local Lobby = require(Server.Lobby)
local UltRunner = require(Server.UltRunner)
local MapLoader = require(Server.MapLoader)
local Admin = require(Server.Admin)
local Friends = require(Server.Friends)
local Monetization = require(Server.Monetization)
local Leaderboards = require(Server.Leaderboards)
local Quests = require(Server.Quests)
local Vip = require(Server.Vip)
local Sandbox = require(Server.Sandbox)

local isMatchServer = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
Run.mode = isMatchServer and "Match" or "Lobby"
-- shows in the live server's F9 console: which kind of server this is
print(string.format("[Main] %s server (PrivateServerId=%q, PrivateServerOwnerId=%d)", Run.mode, game.PrivateServerId, game.PrivateServerOwnerId))

Data.start()
Furniture.init()
MapLoader.init()
Combat.start()
UltRunner.start()
Inventory.start()
Run.start()
Sandbox.start() -- after Run.start: it takes over the monster's death while a sandbox is on
Lobby.start()
Admin.start()
Friends.start()
Monetization.start()
Vip.start()
Quests.start()
Leaderboards.start(Run.mode == "Lobby") -- the lobby's global leaderboards (kills, highest wave, money)

local expected = 1
local firstJoin = nil :: number?
local configured = false
local function onPlayer(p: Player)
	if Run.mode == "Match" then
		Run.addToMatch(p)
		local jd = p:GetJoinData()
		local td = jd and jd.TeleportData
		if type(td) == "table" and tonumber(td.size) then expected = math.max(expected, math.clamp(tonumber(td.size) :: number, 1, 4)) end
		-- the party picked a map + difficulty on the lobby pad
		if not configured and not Run.running() then
			configured = true
			Run.configure(type(td) == "table" and type(td.map) == "string" and td.map or nil, type(td) == "table" and type(td.diff) == "string" and td.diff or nil,
				not (type(td) == "table" and td.ff == false)) -- the lobby switched friendly fire off
		end
	else
		-- a lobby player is never in a run; a failure here must not stop the character from loading below
		local ok, err = pcall(Run.removeFromMatch, p)
		if not ok then warn("[Main] removeFromMatch failed for " .. p.Name .. ": " .. tostring(err)) end
	end
	-- CharacterAutoLoads is off (so the spawn location is set first): respawn 4 s after dying
	p.CharacterAdded:Connect(function(ch)
		-- lobby servers: a player who isn't in a run always stands in the lobby park, never in the house
		if Run.mode == "Lobby" then
			task.defer(function()
				local hrp = ch:WaitForChild("HumanoidRootPart", 5) :: BasePart?
				local sp = workspace:FindFirstChild("LobbySpawn") :: BasePart?
				if hrp and sp and ch.Parent and not p:GetAttribute("InMatch") and (hrp.Position - sp.Position).Magnitude > 150 then
					warn("[Main] " .. p.Name .. " spawned outside the lobby: moved back to the park")
					ch:PivotTo(sp.CFrame + Vector3.new(math.random(-6, 6), 4, math.random(-6, 6)))
				end
			end)
		end
		local hum = ch:WaitForChild("Humanoid") :: Humanoid
		hum.Died:Once(function()
			local wait = Run.onDied(p) -- the revive window can keep the body down longer
			task.delay(wait, function() if p.Parent and p.Character == ch then p:LoadCharacter() end end)
		end)
	end)
	p:LoadCharacter()
	Data.load(p)
	Quests.setup(p)
	if Run.mode == "Match" then
		firstJoin = firstJoin or os.clock()
		-- start when the whole party has arrived (or after 15 s)
		task.spawn(function()
			while not Run.running() do
				if #Run.matchPlayers() >= expected or os.clock() - (firstJoin :: number) > 15 then
					Run.startFight()
					break
				end
				task.wait(0.5)
			end
		end)
	end
end
Players.PlayerAdded:Connect(onPlayer)
for _, p in Players:GetPlayers() do task.spawn(onPlayer, p) end
