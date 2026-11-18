--!strict
-- THE TUTORIAL (server side of Client/Intro, a new player's first minute). It happens in the house of the first map
-- (the Mansion, in the lobby's own server: Server/Sandbox), in its TV room. The client plays the cinematic (the
-- Woman coming out of the TV is the client's own copy of her); from the moment she lunges, the Woman is the real
-- monster (Ghost.tutorial: she only goes for players in the tutorial, never takes them under 40% health, and waits
-- between her swings), so the lessons and the short fight after them use the game itself: blocking, punching,
-- lifting and throwing the armchair, the ultimate, knock-outs and wall smashes.
--   Remotes.Tutorial (from the player in it, in this order):
--     "seen"    it started (saved: it never starts by itself again; Server/Data)     "skip" = the same
--     "enter"   into the house, in front of the TV room's armchair (player attribute IntroHouse = true / false)
--     "spawn"   (position) the real Woman, where the client's copy of her is, held with her claws up just
--               before they come down (the first lesson: blocking them)
--     "windup"  she comes at the player and is held with her claws up, just before they come down
--     "hold"    she is held where she is              "release"  she goes on (model attribute Held)
--     "ult"     the player's brutality bar is filled; until "fight" the ultimate only STUNS her (Ghost.tutorial
--               stunOnly: no ragdoll, no flying body, she stays dazed in front of the player)
--     "fight"   the short fight: she swings, waits, swings again, and can be beaten
--     "exit"    she goes; the player is put inside the front door (player attribute IntroExit = true)
--     "done"    back to the park (the sandbox's way out)
-- Player attribute Tutorial = true while in it (Combat: never under 40% health, never knocked down).
-- Lobby servers only (ReplicatedStorage attribute TutorialOn: the clients start it there and nowhere else).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Sandbox = require(script.Parent.Sandbox)
local Ghost = require(script.Parent.Ghost)
local Combat = require(script.Parent.Combat)
local Furniture = require(script.Parent.Furniture)
local Inventory = require(script.Parent.Inventory)

local Tutorial = {}
local inIntro = {} :: { [Player]: boolean }
local LESSON_HP = 0.35 -- her health never goes under this share before the fight
local SEAT_BACK = 22 -- the armchair this far from the TV
local propOf = {} :: { [Player]: Model }

-- the TV room: the TV and the armchair facing it (Client/Intro finds them the same way). Look it up again after
-- Furniture.reset(): that replaces the whole Furniture folder with a fresh copy.
local function tvRoom(): (Model?, Model?)
	local m = workspace:FindFirstChild("Mansion")
	local f = m and m:FindFirstChild("Furniture")
	local tv = f and f:FindFirstChild("TV")
	if not f or not tv or not tv:IsA("Model") then return nil, nil end
	local best, bestD = nil :: Model?, math.huge
	for _, c in f:GetChildren() do
		if c.Name == "Armchair" and c:IsA("Model") then
			local d = (c:GetPivot().Position - tv:GetPivot().Position).Magnitude
			if d < bestD then best, bestD = c, d end
		end
	end
	return tv, best
end

-- where the player stands up in front of the armchair, facing the TV
local function standSpot(tv: Model, chair: Model): CFrame
	local cf, size = chair:GetBoundingBox()
	local floorY = cf.Position.Y - size.Y / 2
	local to = tv:GetPivot().Position - cf.Position
	to = Vector3.new(to.X, 0, to.Z).Unit
	local p = Vector3.new(cf.Position.X, floorY + 3, cf.Position.Z) + to * 2.8
	return CFrame.lookAt(p, p + to)
end

local function tutorialFight(): any
	return Ghost.tutorial
end

local function stop(p: Player)
	inIntro[p] = nil
	local prop = propOf[p]
	propOf[p] = nil
	if prop and prop.Parent then prop:SetAttribute("IntroProp", nil) end
	if p.Parent then
		p:SetAttribute("Tutorial", nil)
		p:SetAttribute("IntroHouse", nil)
		p:SetAttribute("IntroExit", nil)
	end
	if next(inIntro) == nil then
		Ghost.tutorial = nil
		Sandbox.holdDummy = false
		Ghost.passive = Sandbox.active()
	end
end

local function enter(p: Player)
	if inIntro[p] or p:GetAttribute("InMatch") then return end
	Data.setTutorialSeen(p)
	inIntro[p] = true
	Sandbox.holdDummy = true
	Sandbox.enter(p, nil, true, true) -- (waits while the house is sent to the player; no still dummy)
	if not inIntro[p] then return end
	if not p.Parent or not p:GetAttribute("Sandbox") then
		stop(p)
		if p.Parent then p:SetAttribute("IntroHouse", false) end
		return
	end
	-- the room as it should be, nobody else's Woman in it
	if Ghost.current then Ghost.despawn() end
	Furniture.reset()
	-- (the furniture is a fresh copy now: the TV and the armchair are looked up in it)
	local tv, chair = tvRoom()
	if not tv or not chair then
		stop(p)
		Sandbox.leave(p)
		if p.Parent then p:SetAttribute("IntroHouse", false) end
		return
	end
	-- the armchair far back from the TV, facing it: the whole scene in view, room for her to crawl out (back next
	-- reset, like all the furniture)
	local tvCF = tv:GetPivot()
	local look = Vector3.new(tvCF.LookVector.X, 0, tvCF.LookVector.Z).Unit
	local at = Vector3.new(tvCF.Position.X, chair:GetPivot().Position.Y, tvCF.Position.Z) + look * SEAT_BACK
	chair:PivotTo(CFrame.lookAt(at, at - look))
	chair:SetAttribute("IntroSeat", true) -- (Client/Intro's camera sits in this one: now farther than other armchairs)
	-- it is also what the LIFT and THROW lessons pick up and throw at her (model attribute IntroProp)
	chair:SetAttribute("IntroProp", true)
	propOf[p] = chair
	local spot = standSpot(tv, chair)
	pcall(function() p:RequestStreamAroundAsync(spot.Position, 5) end)
	local c = p.Character
	if c then c:PivotTo(spot) end
	p:SetAttribute("Tutorial", true)
	Combat.clearBrutality(p)
	Inventory.select(p, 0) -- (bare fists for the lessons, whatever is in the hotbar)
	p:SetAttribute("IntroHouse", true)
end

local function spawnHer(p: Player, pos: any)
	local tv = tvRoom()
	if typeof(pos) ~= "Vector3" or not tv or (pos - tv:GetPivot().Position).Magnitude > 40 then return end
	Ghost.passive = false
	Ghost.spawn(1, pos, "Woman")
	Ghost.tutorial = { pause = math.huge, nextAt = math.huge, minHp = LESSON_HP, held = true, holdWindup = false }
	local g = Ghost.current
	if not g then return end
	-- straight into her swing, facing the player, held just before the claws come down: the client's frozen
	-- BLOCK lesson lets it go
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp then
		local to = Vector3.new(hrp.Position.X, pos.Y, hrp.Position.Z)
		if (to - pos).Magnitude > 0.1 then
			g.model:PivotTo(CFrame.lookAt(pos, to))
			g.ao.CFrame = CFrame.lookAt(pos, to).Rotation
		end
	end
	g.comboLeft = 0
	Ghost.setState(g, "WindUp", 0.3)
	g.pauseFrom = os.clock()
	g.model:SetAttribute("Held", true)
end

local function hold(on: boolean)
	local T = tutorialFight()
	local g = Ghost.current
	if not T or not g then return end
	T.held = on
	if on then g.pauseFrom = g.pauseFrom or os.clock() end
	g.model:SetAttribute("Held", on)
end

local function frontDoor(): CFrame?
	local m = workspace:FindFirstChild("Mansion")
	local st = m and m:FindFirstChild("Structure")
	local front = st and st:FindFirstChild("Front1", true)
	if not front then return nil end
	local sum, n = Vector3.zero, 0
	for _, d in front:GetDescendants() do
		if d:IsA("BasePart") and d.Name == "DoorLeaf" then sum += d.Position; n += 1 end
	end
	if n == 0 then return nil end
	local at = sum / n
	local out = Vector3.new(at.X, 0, at.Z).Unit -- (the house's middle is the origin: outward)
	local p = Vector3.new(at.X, at.Y - 4.5, at.Z) - out * 7
	return CFrame.lookAt(p, p + out)
end

function Tutorial.start(isLobby: boolean)
	RS:SetAttribute("TutorialOn", isLobby)
	Remotes.Tutorial.OnServerEvent:Connect(function(p: Player, action: any, arg: any)
		-- (no rate limit: the steps come in quick pairs, and each one only acts in its own moment)
		if action == "seen" or action == "skip" then
			Data.setTutorialSeen(p)
			return
		elseif action == "enter" then
			if isLobby then enter(p) end
			return
		end
		if not inIntro[p] then
			-- (an intro that never came into the house still ends in the park)
			if action == "done" then Data.setTutorialSeen(p) end
			return
		end
		local T = tutorialFight()
		if action == "spawn" then
			spawnHer(p, arg)
		elseif action == "windup" and T then
			T.nextAt = 0
			T.pause = math.huge
			T.holdWindup = true
		elseif action == "hold" then
			hold(true)
		elseif action == "release" then
			hold(false)
		elseif action == "ult" then
			Combat.endUltimate(p)
			Combat.fillBrutality(p)
			if T then T.stunOnly = true end -- (this one ultimate stuns her: no ragdoll)
		elseif action == "fight" and T then
			hold(false)
			T.pause = 3.2
			T.nextAt = os.clock() + 2.2
			T.minHp = 0
			T.holdWindup = false
			T.stunOnly = nil
		elseif action == "exit" then
			if Ghost.current then Ghost.despawn() end
			local at = frontDoor()
			local c = p.Character
			if at and c then
				pcall(function() p:RequestStreamAroundAsync(at.Position, 5) end)
				if p.Character == c and c.Parent then c:PivotTo(at) end
			end
			p:SetAttribute("IntroExit", true)
		elseif action == "done" then
			Data.setTutorialSeen(p)
			stop(p)
			Sandbox.leave(p)
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		if inIntro[p] then stop(p) end
	end)
end

return Tutorial
