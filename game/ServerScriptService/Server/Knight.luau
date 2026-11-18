--!strict
-- THE VOID KNIGHT (Shared/Monsters "Knight"): a black-armoured lord with a red energy blade. Two things:
--
--   * THE BLADE (def.saber; Server/Ghost): it cuts everything. Every swing slices the inside walls and the furniture
--     in front of him (Ghost's claw), and he never uses a door: he cuts his way through the walls (wallBreaker,
--     Ghost's chase). The clients draw the glowing cuts (Fx "SaberSwing" / "SaberCut", Client/MonsterFx).
--   * THE GRIP (his ability, kind = "forcePush"; Abilities hands try / step / interrupt over, like the Caller's):
--     he stops, reaches out with his open left hand (phase "wind": ability.wind seconds, the air ripples toward his
--     palm); a player he can SEE is then lifted off the floor and held in the air (phase "hold": ability.hold
--     seconds, rings of force run from his hand to them), and thrown into the walls (phase "push": Fury.launch, so
--     the inside walls on the way break). Ways out, all told to the victim: get behind a wall before the wind-up
--     ends (he needs to see you), or knock him back while he reaches or holds (Abilities.interrupt drops the victim).
local Remotes = require(script.Parent.Remotes)
local Fury = require(script.Parent.Fury)

local Knight = {}
local H: any = nil -- Abilities' helpers: setPhase, start, finish, hover, flat, warded, hrpOf, matchPlayers, fx, dmgScale
function Knight.init(h) H = h end

-- nothing of the house between his head and the player
local function sees(g, thrp: BasePart): boolean
	local head = (g.model:FindFirstChild("Head") or g.hrp) :: BasePart
	local to = thrp.Position - head.Position
	local r = workspace:Raycast(head.Position, to, g.rp)
	return r == nil or (r.Position - head.Position).Magnitude > to.Magnitude - 2.5
end

local function face(g, at: Vector3)
	local d = H.flat(at - g.hrp.Position)
	if d.Magnitude > 0.1 then g.ao.CFrame = CFrame.lookAt(Vector3.zero, d) end
end

function Knight.try(g, G, _now: number, a, target: Player, thrp: BasePart, dist: number): boolean
	if dist < a.min or dist > a.max or H.warded(target) or Fury.inGrace(target) then return false end
	if not sees(g, thrp) then return false end
	local wind = a.wind * (g.enraged and 0.85 or 1)
	H.start(g, G, "wind", wind, { victim = target })
	Remotes.Fx:FireAllClients("ForceWind", g.model, target, wind)
	return true
end

function Knight.step(g, G, _dt: number, now: number, _target: Player?, _thrp: BasePart?, hoverY: number)
	local ab, a = g.ab, g.def.ability
	g.lv.VectorVelocity = H.hover(g, hoverY, Vector3.zero)
	local victim = ab.victim :: Player
	local vh = H.hrpOf(victim)
	if vh then face(g, vh.Position) end
	if now < ab.untilT then return end
	if ab.phase == "wind" then
		if vh and victim.Parent and not H.warded(victim) and sees(g, vh) then
			-- lifted and held: nothing else may hit them meanwhile
			Fury.downed(victim, a.hold + 0.4)
			H.setPhase(g, "hold", a.hold)
			Remotes.Fx:FireClient(victim, "ForceHold", a.hold, a.lift)
			Remotes.Fx:FireAllClients("ForceGrab", g.model, victim, a.hold, a.lift)
		else
			Remotes.Fx:FireAllClients("ForceMiss", g.model, victim)
			H.finish(g, G, 0.6)
		end
	elseif ab.phase == "hold" then
		if vh and victim.Parent then
			-- thrown away from him, into (and through) the walls
			local dir = H.flat(vh.Position - g.hrp.Position)
			if dir.Magnitude < 0.1 then dir = g.hrp.CFrame.LookVector end
			Remotes.Fx:FireAllClients("ForcePush", g.model, vh.Position, dir)
			Fury.launch(g, G, victim, dir * a.power + Vector3.new(0, 24, 0), a.dmg * H.dmgScale(g), 1.5, "force")
		end
		H.setPhase(g, "push", 0.45)
	else
		H.finish(g, G, 0.5)
	end
end

-- knocked back while he reaches or holds: the victim drops
function Knight.interrupt(g)
	local ab = g.ab
	if ab and ab.victim and (ab.phase == "wind" or ab.phase == "hold") then
		Remotes.Fx:FireClient(ab.victim, "Released")
		Remotes.Fx:FireAllClients("ForceMiss", g.model, ab.victim, true)
	end
end

return Knight
