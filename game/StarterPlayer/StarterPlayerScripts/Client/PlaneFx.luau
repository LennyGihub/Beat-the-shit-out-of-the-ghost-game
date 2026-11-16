-- Plane crash cinematic (shared pieces in CineKit): the plane comes in low with one engine on fire and a long trail
-- of black smoke, wings rocking; it hits the yard, bounces once, then slides in a ground loop ploughing a furrow
-- (dirt, sparks, torn-off panels) and comes to rest exactly where the server's wreck appears. Then it blows up.
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Sfx = require(script.Parent.Sfx)
local Kit = require(script.Parent.CineKit)

local PlaneFx = {}
local rng = Kit.rng
local SCRAP = { Color3.fromRGB(190, 190, 195), Color3.fromRGB(120, 124, 130), Color3.fromRGB(150, 40, 34) }

local function bezier(a: Vector3, b: Vector3, c: Vector3, t: number): Vector3
	return a:Lerp(b, t):Lerp(b:Lerp(c, t), t)
end

-- land, from: as before; rest = the wreck's final CFrame (sent by the server)
function PlaneFx.crash(land: Vector3, from: Vector3, rest: CFrame?)
	local rig = Kit.rig(Kit.model("PlaneModel"), { Prop = "z", Spinner = "z" })
	if not rig then return end
	local final = rest or CFrame.new(land + Vector3.new(0, 2.2, 0))
	-- it flies in 35 degrees off its final heading, touches down 60 studs short and swings round as it slides
	local headF = Kit.flat(final.LookVector)
	local head = (CFrame.Angles(0, math.rad(-35), 0) * headF)
	local side = head:Cross(Vector3.yAxis)
	local belly = final.Position.Y
	local touch = Vector3.new(final.Position.X, belly, final.Position.Z) - head * 60
	local start = touch - head * 480 + Vector3.new(0, 210, 0) + side * 70
	local mid = touch - head * 170 + Vector3.new(0, 70, 0) + side * 8 -- high over the treetops, then a steep final drop
	local yaw0 = math.atan2(-head.X, -head.Z)
	local yawF = math.atan2(-headF.X, -headF.Z)
	local dyaw = (yawF - yaw0 + math.pi) % (2 * math.pi) - math.pi
	local _, pitchF, rollF = 0, math.rad(-9), math.rad(7)

	-- left engine on fire, a long smoke trail
	local eng = rig.part("EngineL")
	if eng then
		Kit.emitter(eng, { Color = ColorSequence.new(Color3.fromRGB(24, 22, 20)), Size = NumberSequence.new(3, 14), Transparency = NumberSequence.new(0.25, 1),
			Rate = 80, Speed = NumberRange.new(2, 6), Lifetime = NumberRange.new(2.5, 4), SpreadAngle = Vector2.new(20, 20) })
		Kit.emitter(eng, { Texture = "rbxasset://textures/particles/fire_main.dds", Color = ColorSequence.new(Color3.fromRGB(255, 170, 60), Color3.fromRGB(220, 60, 20)),
			LightEmission = 0.8, Size = NumberSequence.new(4, 1), Transparency = NumberSequence.new(0.1, 1), Rate = 60, Speed = NumberRange.new(4, 10),
			Lifetime = NumberRange.new(0.3, 0.6), SpreadAngle = Vector2.new(30, 30) })
		local l = Instance.new("PointLight"); l.Color = Color3.fromRGB(255, 130, 50); l.Range = 50; l.Brightness = 3; l.Parent = eng
	end
	local engine = Sfx.loop("PlaneEngine", { Volume = 1.2, PlaybackSpeed = 0.9 })
	local dur = Config.eventTime("PlaneTime")
	local A_TOUCH, A_HOP = 0.6, 0.72 -- first contact, second (the slide starts)
	-- the shot: from the yard just in front of the house, off to one side of where it will stop
	local camAt = Vector3.new(math.clamp(final.Position.X + (final.Position.X > 0 and -34 or 34), -52, 52), 5.5, 77)
	Kit.shot(function() return camAt end, function() return rig.model.Parent and rig.cf.Position or nil end, dur + 2.6, 34)
	local touched, slid, passed = false, false, false
	local lastFurrow: Vector3? = nil
	Kit.play(dur, function(a, dt, now)
		local cf: CFrame
		if a < A_TOUCH then
			-- the approach: nose along the flight path, wings rocking as the pilot fights it
			local t = (a / A_TOUCH) ^ 0.9
			local pos = bezier(start, mid, touch, t)
			local ahead = bezier(start, mid, touch, math.min(1, t + 0.01))
			if t > 0.99 then ahead = pos + (touch - mid).Unit end
			local rock = math.rad(20) * math.sin(now * 2.3) + math.rad(7) * math.sin(now * 5.1)
			cf = CFrame.lookAt(pos, ahead) * CFrame.Angles(math.rad(3), 0, rock * (1 - t * 0.6))
			rig.turn("Prop", dt * 40); rig.turn("Spinner", dt * 40)
		else
			-- on the ground: one bounce, then the slide; it yaws round to where it stops and settles on a wing
			local g = (a - A_TOUCH) / (1 - A_TOUCH)
			local k = 1 - (1 - g) ^ 2.4
			local base = touch:Lerp(Vector3.new(final.Position.X, belly, final.Position.Z), k)
			local hop = a < A_HOP and math.sin((a - A_TOUCH) / (A_HOP - A_TOUCH) * math.pi) * 5.5 or 0
			local swing = 1 - (1 - math.clamp((a - A_HOP) / (1 - A_HOP), 0, 1)) ^ 2
			local shudder = (1 - g) * math.sin(now * 38) * 0.02
			cf = CFrame.new(base + Vector3.new(0, hop, 0)) * CFrame.Angles(0, yaw0 + dyaw * swing, 0)
				* CFrame.Angles(pitchF * g + (a < A_HOP and math.rad(6) * math.sin(g * 20) or 0) + shudder, 0, rollF * swing + math.rad(14) * math.sin(g * math.pi) * (1 - g))
			rig.turn("Prop", dt * 40 * (1 - g)); rig.turn("Spinner", dt * 40 * (1 - g))
			local nose = (cf * CFrame.new(0, -2, -14)).Position
			if not touched then
				touched = true
				Sfx.at("Crash", base, { Volume = 1.5, PlaybackSpeed = 0.7, RollOffMaxDistance = 500 })
				Kit.dust(base, 12, 40)
				Kit.sparks(base, 40)
				Kit.debris(base, 8, SCRAP, Enum.Material.Metal, head, 60, 1.5)
				Kit.shake(0.6 * Kit.near(base, 260))
			end
			if a >= A_HOP then
				if not slid then
					slid = true
					Sfx.at("Crash", base, { Volume = 1.6, PlaybackSpeed = 0.55, RollOffMaxDistance = 500 })
					Sfx.at("WoodBreak", base, { Volume = 1.3, PlaybackSpeed = 0.5 })
					Kit.debris(base, 10, SCRAP, Enum.Material.Metal, head, 50, 1.8) -- torn-off panels
					Kit.dust(base, 14, 40)
					Kit.shake(0.8 * Kit.near(base, 260))
				end
				-- ploughing: dirt thrown up at the nose, sparks under the belly, the furrow behind
				if g < 0.92 then
					if rng:NextNumber() < 0.6 then Kit.dust(nose, 7, 5) end
					if rng:NextNumber() < 0.5 then Kit.sparks(base, 8) end
					Kit.shake(0.02 * Kit.near(base, 220))
				end
				if lastFurrow and (base - lastFurrow).Magnitude > 3 then
					Kit.mark(base, base - lastFurrow, (base - lastFurrow).Magnitude + 1.5, 7, Color3.fromRGB(44, 34, 26))
					lastFurrow = base
				elseif not lastFurrow then
					lastFurrow = base
				end
			end
		end
		rig.place(cf)
		if engine then engine.PlaybackSpeed = (a < A_TOUCH and 0.9 + a * 0.9 or 1.3 * (1 - (a - A_TOUCH))) + math.sin(now * 30) * 0.04 end
		-- it roars past: a whoosh when it is closest
		if not passed and Kit.near(cf.Position, 150) > 0.35 then
			passed = true
			Sfx.play("Whoosh", { PlaybackSpeed = 0.5, Volume = 2 })
			Kit.shake(0.35)
		end
	end, function()
		if engine then engine:Destroy() end
		rig.place(final)
		Kit.handOff(rig, "PlaneWreck", 2)
	end)
end

function PlaneFx.impact(land: Vector3)
	local at = land + Vector3.new(0, 4, 0)
	Kit.boom(at, 60)
	Kit.debris(at, 18, SCRAP, Enum.Material.Metal, Vector3.new(0, 0.6, 0), 70, 1.6)
	Kit.dust(land, 14, 50)
end

function PlaneFx.init(fx) Kit.init(fx) end

return PlaneFx
