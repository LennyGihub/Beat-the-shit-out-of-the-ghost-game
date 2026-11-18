--!strict
-- THE TUTORIAL (server). It runs in the sandbox (Server/Sandbox: the house of the first map in the lobby's own
-- server, the Woman standing still), one step at a time (Shared/Tutorial): this module watches what the player
-- really does and moves on when the step's goal is met. The client (Client/TutorialUI) shows the card.
--   Remotes.Tutorial: "start" (the lobby's popup or its HOW TO PLAY button), "skip" (the popup's NO THANKS: never
--   asked again), "next" (an info card read).
--   Player attributes: Tutorial = true while in it, TutorialStep = the step's number (#steps + 1 = finished),
--   TutorialProg = progress on it (hits, seconds...), TutorialDone = the number of the step just completed,
--   TutorialSlot = the hotbar slot of the weapon handed out.
--   Saved (Server/Data): the tutorial was offered once (player attribute TutorialSeen): the popup is not shown again.
-- What the player did comes from: Quests.watch (hits, fully charged hits, furniture thrown into her), the Sprint
-- remote, and the player's own attributes (Blocking, UltActive, Sel).
-- Lobby servers only (ReplicatedStorage attribute TutorialOn: the clients offer it there and nowhere else).
-- Leaving: the sandbox's LEAVE (key / button) ends it like any sandbox; this module notices and tidies up.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Remotes = require(script.Parent.Remotes)
local Sandbox = require(script.Parent.Sandbox)
local Combat = require(script.Parent.Combat)
local Ghost = require(script.Parent.Ghost)
local Quests = require(script.Parent.Quests)
local Inventory = require(script.Parent.Inventory)
local Data = require(script.Parent.Data)
local Steps = require(RS.Shared.Tutorial).steps

local Tutorial = {}
type State = { step: number, prog: number, sprinting: boolean, nextAt: number?, entering: boolean }
local runs = {} :: { [Player]: State }
local lastAsk = {} :: { [Player]: number }
local DONE_PAUSE = 1.3 -- seconds the finished step stays on screen (DONE) before the next one

local function setStep(p: Player, s: State, n: number)
	s.step = n
	s.prog = 0
	s.nextAt = nil
	p:SetAttribute("TutorialProg", 0)
	p:SetAttribute("TutorialStep", n)
	local def = Steps[n]
	if not def then return end
	if def.give then
		Inventory.give(p, def.give)
		p:SetAttribute("TutorialSlot", p:GetAttribute("Sel")) -- (give selects the new item's slot)
		Inventory.select(p, 0) -- ...but the lesson is to take it in the hand
	end
	if def.kind == "ult" then
		Combat.endUltimate(p)
		Combat.fillBrutality(p)
	end
end

local function stop(p: Player)
	runs[p] = nil
	if p.Parent then
		p:SetAttribute("Tutorial", nil)
		p:SetAttribute("TutorialStep", nil)
		p:SetAttribute("TutorialProg", nil)
		p:SetAttribute("TutorialDone", nil)
		p:SetAttribute("TutorialSlot", nil)
	end
end

-- the step's goal is met: DONE for a moment, then the next one
local function complete(p: Player, s: State)
	if s.nextAt then return end
	s.nextAt = os.clock() + DONE_PAUSE
	p:SetAttribute("TutorialDone", s.step)
end

local function progress(p: Player, s: State, value: number)
	local def = Steps[s.step]
	if not def or s.nextAt then return end
	s.prog = value
	p:SetAttribute("TutorialProg", math.floor(math.min(value, def.goal) * 10 + 0.5) / 10)
	if value >= def.goal then complete(p, s) end
end

local function finish(p: Player)
	stop(p)
	Remotes.Fx:FireClient(p, "Toast", "TUTORIAL DONE - PRESS PLAY TO FIGHT FOR REAL", true)
	Sandbox.leave(p)
end

local function start(p: Player)
	if runs[p] or p:GetAttribute("InMatch") then return end
	Data.setTutorialSeen(p)
	local s: State = { step = 0, prog = 0, sprinting = false, entering = true }
	runs[p] = s
	Sandbox.enter(p, nil, true) -- (waits while the house is sent to the player)
	if runs[p] ~= s then return end
	s.entering = false
	if not p.Parent or not p:GetAttribute("Sandbox") then -- the house is in use, or the player is down
		stop(p)
		return
	end
	p:SetAttribute("Tutorial", true)
	Combat.clearBrutality(p) -- the bar fills with the player's own hits here (Combat: no free refill in the tutorial)
	setStep(p, s, 1)
end

-- isLobby: the tutorial only exists on lobby servers (the sandbox's house); the clients read TutorialOn
function Tutorial.start(isLobby: boolean)
	RS:SetAttribute("TutorialOn", isLobby)
	Remotes.Tutorial.OnServerEvent:Connect(function(p: Player, action: any)
		local now = os.clock()
		if now - (lastAsk[p] or 0) < 0.3 then return end
		lastAsk[p] = now
		if action == "start" then
			start(p)
		elseif action == "skip" then
			Data.setTutorialSeen(p)
		elseif action == "next" then
			local s = runs[p]
			local def = s and Steps[s.step]
			if s and def and def.kind == "info" and not s.nextAt then
				-- (no DONE pause on a card that was only read)
				if s.step >= #Steps then finish(p) else setStep(p, s, s.step + 1) end
			end
		end
	end)
	Remotes.Sprint.OnServerEvent:Connect(function(p: Player, on: any)
		local s = runs[p]
		if s then s.sprinting = on == true end
	end)
	-- hits, charged hits and thrown furniture, as the game itself counts them (in the sandbox they count for nothing else)
	Quests.watch = function(p: Player, stat: string, _n: number)
		local s = runs[p]
		local def = s and Steps[s.step]
		if not s or not def or s.nextAt then return end
		if stat == "hits" then
			if def.kind == "hits" then
				progress(p, s, s.prog + 1)
			elseif def.kind == "item" and (p:GetAttribute("Sel") or 0) == p:GetAttribute("TutorialSlot") then
				progress(p, s, s.prog + 1)
			end
		elseif stat == "charged" and def.kind == "charged" then
			progress(p, s, s.prog + 1)
		elseif stat == "throws" and def.kind == "throw" then
			progress(p, s, s.prog + 1)
		end
	end
	Players.PlayerRemoving:Connect(function(p)
		runs[p] = nil
		lastAsk[p] = nil
	end)
	RunService.Heartbeat:Connect(function(dt: number)
		local now = os.clock()
		for p, s in runs do
			if s.entering then continue end
			if not p.Parent or not p:GetAttribute("Sandbox") then -- left with LEAVE, or the sandbox closed
				stop(p)
				continue
			end
			if s.nextAt then
				if now >= s.nextAt then
					if s.step >= #Steps then finish(p) else setStep(p, s, s.step + 1) end
				end
				continue
			end
			local def = Steps[s.step]
			if not def then continue end
			local ch = p.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
			if def.kind == "walk" then
				local g = Ghost.current
				if g and hrp and Ghost.alive() and (g.hrp.Position - hrp.Position).Magnitude <= def.goal then progress(p, s, def.goal) end
			elseif def.kind == "block" then
				if p:GetAttribute("Blocking") == true then progress(p, s, s.prog + dt) end
			elseif def.kind == "sprint" then
				if s.sprinting and hum and hum.MoveDirection.Magnitude > 0.1 then progress(p, s, s.prog + dt) end
			elseif def.kind == "ult" then
				if p:GetAttribute("UltActive") == true then progress(p, s, 1) end
			end
		end
	end)
end

return Tutorial
