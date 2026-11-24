--!strict
-- MOBILE PLAYERS (phones / tablets: touch controls). Aiming and moving with thumbs is much harder, so (Config.Mobile):
--   - their punches, melee weapons, sprays and shotguns reach much further and need far less aim,
--   - they lift furniture from far away,
--   - the monster of a run with mobile players in it is much weaker (less health, less damage, slower).
-- Each client reports the controls it is using (Remotes.Platform, sent by ClientMain whenever they change); the
-- player attribute Mobile is true while that is "touch". A phone with a controller or a keyboard plugged in plays
-- like everyone else.
-- Studio test hook: ReplicatedStorage attribute DebugMobileShare = 0..1 (the share of the run's players on mobile).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.Shared.Config)
local Remotes = require(script.Parent.Remotes)
local Guard = require(script.Parent.Guard)

local Mobile = {}
local M = Config.Mobile

function Mobile.is(p: Player): boolean return p:GetAttribute("Mobile") == true end

-- how far this player's hits reach (x the weapon's range)
function Mobile.reach(p: Player): number return Mobile.is(p) and M.Reach or 1 end

-- how well a hit must be aimed (dot of the look direction and the direction to the monster; lower = easier)
function Mobile.cone(p: Player, base: number): number
	return Mobile.is(p) and math.min(base, M.ConeDot) or base
end

-- from how far this player lifts furniture (studs)
function Mobile.liftRange(p: Player): number return Mobile.is(p) and M.LiftRange or Config.Carry.Range end

-- the share (0..1) of the run's players who are on mobile
function Mobile.share(): number
	local dbg = RunService:IsStudio() and RS:GetAttribute("DebugMobileShare")
	if type(dbg) == "number" then return math.clamp(dbg, 0, 1) end
	local n, mobile = 0, 0
	for _, p in Players:GetPlayers() do
		if p:GetAttribute("InMatch") then
			n += 1
			if Mobile.is(p) then mobile += 1 end
		end
	end
	return n > 0 and mobile / n or 0
end

-- what the next monster's health, damage and speed are multiplied by. One mobile player in the team already gives
-- MixedShare of the full effect; a team of mobile players only gets all of it.
function Mobile.ease(): { hp: number, dmg: number, speed: number }
	local share = Mobile.share()
	local f = share > 0 and (M.MixedShare + (1 - M.MixedShare) * share) or 0
	return { hp = 1 + (M.MonsterHp - 1) * f, dmg = 1 + (M.MonsterDmg - 1) * f, speed = 1 + (M.MonsterSpeed - 1) * f }
end

function Mobile.start()
	local last = {} :: { [Player]: number }
	Remotes.Platform.OnServerEvent:Connect(function(p, mode) if not Guard.ok(p, "Platform") then return end
		if os.clock() - (last[p] or 0) < 0.5 then return end
		last[p] = os.clock()
		p:SetAttribute("Mobile", mode == "touch")
	end)
	Players.PlayerRemoving:Connect(function(p) last[p] = nil end)
end

return Mobile
