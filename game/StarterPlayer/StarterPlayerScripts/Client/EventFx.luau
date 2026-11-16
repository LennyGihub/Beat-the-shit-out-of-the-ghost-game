-- Client cinematics for the van and train events (the plane lives in PlaneFx; shared pieces in CineKit).
-- VAN: races out of the trees weaving, headlights on, wheels spinning and dust flying; the brakes are gone, it
--   fishtails leaving skid marks and slams nose-first into the house front (planks, glass, a hubcap rolling off).
-- TRAIN: comes down the line from the right, lamp on, smoking; the locomotive jumps the rails, ploughs a furrow and
--   rolls onto its side while the wagons jackknife behind it one after the other.
-- The copies stay until the server's real wrecks appear (CineKit.handOff). Timings: Shared/Config.Events.
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Config = require(RS.Shared.Config)
local Sfx = require(script.Parent.Sfx)
local Kit = require(script.Parent.CineKit)

local EventFx = {}
local rng = Kit.rng
local WOOD = { Color3.fromRGB(110, 82, 56), Color3.fromRGB(84, 62, 46), Color3.fromRGB(140, 110, 80) }
local SCRAP = { Color3.fromRGB(70, 70, 74), Color3.fromRGB(40, 40, 42), Color3.fromRGB(120, 40, 30) }
local lastVan: CFrame? = nil

-- VAN ----------------------------------------------------------------------------
function EventFx.van(final: CFrame)
	local rig = Kit.rig(Kit.model("Van"), { Wheel = "x" })
	if not rig then return end
	lastVan = final
	local wreck = final * CFrame.Angles(math.rad(-4), 0, math.rad(3)) -- how the server's wreck sits
	-- its path in the final spot's own space: 170 studs out, weaving, straight into the wall (front = -Z)
	local function path(a: number): Vector3
		return Vector3.new(9 * math.sin(a * math.pi * 1.6) * (1 - a) ^ 1.2, 0, 170 * (1 - a ^ 1.25))
	end
	for _, d in rig.model:GetDescendants() do
		if d:IsA("BasePart") and d.Name == "Headlight" then
			d.Material = Enum.Material.Neon; d.Color = Color3.fromRGB(255, 244, 200)
			local l = Instance.new("SpotLight"); l.Face = Enum.NormalId.Front; l.Range = 60; l.Angle = 55; l.Brightness = 2.5; l.Color = d.Color; l.Parent = d
		elseif d:IsA("BasePart") and d.Name == "Wheel" then
			Kit.emitter(d, { Color = ColorSequence.new(Color3.fromRGB(120, 104, 84)), Size = NumberSequence.new(1.2, 4), Transparency = NumberSequence.new(0.5, 1),
				Rate = 22, Speed = NumberRange.new(2, 6), Lifetime = NumberRange.new(0.6, 1.2), SpreadAngle = Vector2.new(40, 40), Acceleration = Vector3.new(0, 2, 0) })
		end
	end
	local engine = Sfx.loop("PlaneEngine", { PlaybackSpeed = 1.5, Volume = 1 })
	local dur = Config.eventTime("VanTime")
	-- the shot: low in the yard beside its path (on the side of the yard's middle); it roars past and hits the house
	local camAt = (final * CFrame.new(final.Position.X > 0 and -17 or 17, 3.2, 36)).Position
	Kit.shot(function() return camAt end, function() return rig.model.Parent and (rig.cf * CFrame.new(0, 3, 0)).Position or nil end, dur + Config.eventTime("VanSettle") + 1.6, 40)
	local lastMark: Vector3? = nil
	local skidding = false
	Kit.play(dur, function(a, dt, now)
		local a1 = math.min(a, 0.99)
		local p, ahead = path(a1), path(a1 + 0.01)
		if a >= 0.99 then p = path(a) end
		local fish = math.sin(now * 11) * 0.16 * math.clamp((a - 0.55) / 0.25, 0, 1) * (1 - a) ^ 0.6
		local bounce = math.abs(math.sin(now * 16)) * 0.22 * (1 - a * 0.5)
		local dir = ahead - path(a1)
		local cf = final * CFrame.lookAt(p, p + dir) * CFrame.Angles(0, fish, 0)
			* CFrame.new(0, bounce, 0) * CFrame.Angles(a > 0.7 and -0.05 or 0.02, 0, -fish * 0.6 + math.sin(now * 9) * 0.02)
		rig.place(cf)
		local speed = 170 * 1.25 * a ^ 0.25 / dur
		rig.turn("Wheel", -speed * dt)
		if engine then engine.PlaybackSpeed = 1.4 + a * 0.9 end
		-- no brakes: the back end swings out and the tyres leave marks
		if a > 0.55 then
			if not skidding then
				skidding = true
				Sfx.at("Whoosh", cf.Position, { PlaybackSpeed = 0.55, Volume = 1.6 })
			end
			local rear = (cf * CFrame.new(0, 0, 6)).Position
			if lastMark and (rear - lastMark).Magnitude > 2 then
				for _, sx in { -3.1, 3.1 } do
					local w = (cf * CFrame.new(sx, 0, 6)).Position
					Kit.mark(w, rear - lastMark, (rear - lastMark).Magnitude + 0.4, 0.9)
				end
				lastMark = rear
			elseif not lastMark then
				lastMark = rear
			end
		end
	end, function()
		-- the hit: the nose dips, it bounces back off the wall and settles the way the wreck sits
		if engine then engine:Destroy() end
		local t0 = os.clock()
		Kit.play(Config.eventTime("VanSettle"), function(_, _, now)
			local t = now - t0
			local dip = math.rad(-11) * math.exp(-8 * t) * math.cos(14 * t)
			local back = 1.1 * math.sin(math.min(t / Config.eventTime("VanSettle"), 1) * math.pi) * math.exp(-4 * t)
			rig.place(wreck * CFrame.new(0, 0, back) * CFrame.Angles(dip, 0, math.rad(4) * math.exp(-6 * t) * math.sin(20 * t)))
		end, function()
			rig.place(wreck)
			Kit.handOff(rig, "Van", 2)
		end)
	end)
end
local function vanImpact(pos: Vector3)
	Kit.boom(pos, 30)
	local f = lastVan
	local out = f and f.ZVector or Vector3.new(0, 0, 1) -- back toward the yard
	Kit.debris(pos, 16, WOOD, Enum.Material.WoodPlanks, out, 42, 1.3)
	Kit.debris(pos, 8, { Color3.fromRGB(200, 215, 225) }, Enum.Material.Glass, out, 34, 0.5)
	Kit.dust(pos, 7, 30)
	Sfx.at("WoodBreak", pos, { Volume = 1.6, PlaybackSpeed = 0.8 })
	Sfx.at("Glass", pos, { Volume = 1.2 })
	if f then
		-- a hubcap rolls off across the yard
		local cap = Instance.new("Part")
		cap.Shape = Enum.PartType.Cylinder; cap.Size = Vector3.new(0.25, 1.9, 1.9); cap.Material = Enum.Material.Metal; cap.Color = Color3.fromRGB(190, 190, 195)
		cap.CanQuery = false; cap.CanTouch = false
		cap.CFrame = f * CFrame.new(4.2, 1.1, -6)
		cap.Parent = workspace.Terrain
		cap.AssemblyLinearVelocity = (f.XVector * 0.4 + f.ZVector) * 30
		cap.AssemblyAngularVelocity = f.XVector * 28
		Debris:AddItem(cap, 9)
	end
end

-- TRAIN --------------------------------------------------------------------------
local RAIL_Z = 150
function EventFx.train(locoCF: CFrame, w1CF: CFrame, w2CF: CFrame)
	local ONRAILS = CFrame.Angles(0, -math.pi / 2, 0)
	-- name, final pose, upright-on-the-rails rotation, how much closer to the loco it rides (couplings stretch on
	-- the way off), when it leaves the rails, hop height
	local cars = {
		{ rig = Kit.rig(Kit.model("TrainLoco"), { Wheel = "x" }), final = locoCF, rail = ONRAILS * CFrame.Angles(0, math.pi, 0), gap = 0, off = 0.6, hop = 2.6, name = "TrainLoco" },
		{ rig = Kit.rig(Kit.model("TrainWagon"), { Wheel = "x" }), final = w1CF, rail = ONRAILS, gap = -7, off = 0.66, hop = 1.3, name = "TrainWagon" },
		{ rig = Kit.rig(Kit.model("TrainShopWagon"), { Wheel = "x" }), final = w2CF, rail = ONRAILS, gap = -15.5, off = 0.72, hop = 0.5, name = "TrainShopWagon" },
	}
	local loco = cars[1].rig
	if not loco then return end
	local chimney, lamp = loco.part("Chimney"), loco.part("Lamp")
	local smoke = chimney and Kit.emitter(chimney, { Color = ColorSequence.new(Color3.fromRGB(46, 44, 42)), Size = NumberSequence.new(2, 9), Transparency = NumberSequence.new(0.3, 1),
		Rate = 45, Speed = NumberRange.new(10, 16), Lifetime = NumberRange.new(1.2, 2.2), EmissionDirection = Enum.NormalId.Right, SpreadAngle = Vector2.new(14, 14), Drag = 1 })
	if lamp then
		lamp.Material = Enum.Material.Neon; lamp.Color = Color3.fromRGB(255, 240, 190)
		local l = Instance.new("PointLight"); l.Range = 40; l.Brightness = 2; l.Color = lamp.Color; l.Parent = lamp
	end
	local engine = Sfx.loop("PlaneEngine", { PlaybackSpeed = 0.5, Volume = 1.3 })
	local dur = Config.eventTime("TrainTime")
	local L = 330 -- studs of track it covers
	-- the shot: beside the line, a little past where the locomotive ends up: it comes straight at the camera
	local camAt = Vector3.new(locoCF.Position.X - 26, 4.5, RAIL_Z - 19)
	Kit.shot(function() return camAt end, function() return loco.model.Parent and (loco.cf * CFrame.new(0, 4, 0)).Position or nil end, dur + 2, 38)
	-- along the track: steady speed, then braking hard through the gravel once it is off the rails
	local function along(a: number): number
		if a < 0.6 then return 0.82 * a / 0.6 end
		local b = (a - 0.6) / 0.4
		return 0.82 + 0.18 * (1 - (1 - b) ^ 2.2)
	end
	local derailed = {} :: { [number]: boolean }
	local lastGouge = {} :: { [number]: Vector3 }
	local lastE = 0
	Kit.play(dur, function(a, dt, now)
		local e = along(a)
		local speed = (e - lastE) * L / math.max(dt, 1 / 240)
		lastE = e
		local sb = math.clamp((a - 0.6) / 0.4, 0, 1)
		local spread = 1 - (1 - sb) ^ 2
		for i, c in cars do
			local rig = c.rig
			if rig then
				local fpos = c.final.Position
				local x = fpos.X + L * (1 - e) + c.gap * (1 - spread)
				local b = math.clamp((a - c.off) / (1 - c.off), 0, 1)
				local w = 1 - (1 - b) ^ 3
				local hop = math.sin(b * math.pi) * c.hop * (1 - b * 0.5)
				local rattle = math.sin(now * 30 + i) * 0.08 * (1 - w)
				local pos = Vector3.new(x, fpos.Y * w + hop + rattle, RAIL_Z + (fpos.Z - RAIL_Z) * w)
				local rot = c.rail:Lerp(c.final.Rotation, w)
				local wob = math.sin(b * math.pi) * (1 - b)
				if i == 1 then rot *= CFrame.Angles(0, 0, wob * 0.35) -- rolls past its side, then drops back
				elseif i == 2 then rot *= CFrame.Angles(0, wob * 0.3, 0) -- jackknifes
				else rot *= CFrame.Angles(0, 0, math.sin(b * math.pi * 3) * (1 - b) * 0.08) end -- rocks on its springs
				rig.place(CFrame.new(pos) * rot)
				rig.turn("Wheel", -speed * dt * (1 - w))
				if b > 0 and not derailed[i] then
					-- this one leaves the rails: sleepers and gravel fly
					derailed[i] = true
					Sfx.at("Crash", pos, { Volume = 1.3, PlaybackSpeed = 0.8 + i * 0.12, RollOffMaxDistance = 400 })
					Sfx.at("WoodBreak", pos, { Volume = 1.4, PlaybackSpeed = 0.7 })
					Kit.debris(pos, i == 1 and 14 or 7, WOOD, Enum.Material.Wood, Vector3.new(-1, 0, 0), 46, 1.4)
					Kit.dust(pos, 8, 26)
					Kit.shake(0.5 * Kit.near(pos, 220))
				end
				if b > 0 and b < 0.85 then
					-- ploughing through the ground: sparks, dirt and a furrow behind it
					if rng:NextNumber() < 0.5 then Kit.sparks(pos + Vector3.new(0, 0.6, 0), 6) end
					if rng:NextNumber() < 0.35 then Kit.dust(pos, 5, 4) end
					local g = lastGouge[i]
					if g and (pos - g).Magnitude > 3 then
						Kit.mark(pos, pos - g, (pos - g).Magnitude + 1, i == 1 and 5 or 3.5, Color3.fromRGB(46, 36, 28))
						lastGouge[i] = pos
					elseif not g then
						lastGouge[i] = pos
					end
				end
			end
		end
		if engine then engine.PlaybackSpeed = 0.5 + a * 0.35 end
		if smoke and a > 0.75 then smoke.Rate = 12 end
		-- the ground rumbles as it comes
		Kit.shake(0.012 * Kit.near(loco.cf.Position, 170))
	end, function()
		if engine then engine:Destroy() end
		for _, c in cars do
			if c.rig then
				c.rig.place(c.final)
				Kit.handOff(c.rig, c.name, 2)
			end
		end
	end)
end
local function trainImpact(pos: Vector3)
	Kit.boom(pos, 50)
	Kit.debris(pos, 14, SCRAP, Enum.Material.Metal, Vector3.new(0, 0.3, -1), 50, 1.4)
	Kit.dust(pos, 10, 40)
end

function EventFx.handle(kind: string, ...)
	local args = { ... }
	if kind == "VanCrash" then EventFx.van(args[1])
	elseif kind == "VanImpact" then vanImpact(args[1])
	elseif kind == "TrainCrash" then EventFx.train(args[1], args[2], args[3])
	elseif kind == "TrainImpact" then trainImpact(args[1])
	end
end

function EventFx.init(fx) Kit.init(fx) end

return EventFx
