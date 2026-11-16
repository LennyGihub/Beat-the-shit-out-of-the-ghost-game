-- Client effects: camera shake, impact flashes and particles, smash dust, wall slams, claw slashes,
-- jumpscare, ultimate shockwave, intro/victory banners, music, outdoor exposure.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Config = require(RS.Shared.Config)
local Sfx = require(script.Parent.Sfx)
local SawAudio = require(script.Parent.SawAudio)
local HUD = require(script.Parent.HUD)
local VM = require(script.Parent.Viewmodel)
local GA = require(script.Parent.GhostAnim)
local Grunge = require(script.Parent.Grunge)
local UltFx = require(script.Parent.UltFx)
local Ultimates = require(RS.Shared.Ultimates)
local Items = require(RS.Shared.Items)

local lastItemSfx = {} :: { [string]: number }
local Fx = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local trauma = 0
local fovKick = 0
local baseFov = 74
local ambience: Sound? = nil
local music: Sound? = nil
local rng = Random.new()
local blur: BlurEffect
local grade: ColorCorrectionEffect
local slashGui: ScreenGui

function Fx.shake(amount: number) trauma = math.min(1.2, trauma + amount) end
function Fx.kick(amount: number) fovKick = math.max(fovKick, amount) end

local function flashBall(pos: Vector3, color: Color3, size: number, life: number)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Size = Vector3.one * size * 0.4
	p.Position = pos
	p.Transparency = 0.1
	p.Parent = workspace.Terrain
	TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * size, Transparency = 1 }):Play()
	Debris:AddItem(p, life + 0.05)
end

local function burst(pos: Vector3, color: Color3, count: number, speed: number, size: number, texture: string?)
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = texture or "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(color)
	pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, size * 2.2) })
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	pe.Speed = NumberRange.new(speed * 0.4, speed)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Lifetime = NumberRange.new(0.4, 1.1)
	pe.Drag = 4
	pe.Acceleration = Vector3.new(0, -6, 0)
	pe.Rate = 0
	pe.Parent = a
	pe:Emit(count)
	Debris:AddItem(a, 2)
end

local function slash()
	for i = 1, 3 do
		local f = Grunge.frame(slashGui, {
			BackgroundTransparency = 0.05, BackgroundColor3 = Color3.fromRGB(120, 0, 0), AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.42 + i * 0.06, 0.5), Size = UDim2.new(0, 10, 0.9, 0), Rotation = 28 + rng:NextNumber(-4, 4),
		})
		TweenService:Create(f, TweenInfo.new(1.2), { BackgroundTransparency = 1 }):Play()
		Debris:AddItem(f, 1.3)
	end
end

local function jumpscare()
	Sfx.play("Jumpscare", { Volume = 0.3 })
	Fx.shake(1.2)
	Fx.kick(-22)
	HUD.flash(Color3.new(1, 1, 1), 0.9)
	blur.Size = 24
	grade.Contrast = 0.8
	grade.Saturation = -1
	TweenService:Create(blur, TweenInfo.new(1.2), { Size = 0 }):Play()
	TweenService:Create(grade, TweenInfo.new(1.4), { Contrast = 0, Saturation = 0 }):Play()
	task.delay(0.12, function() HUD.flash(Color3.new(0, 0, 0), 0.95) end)
	task.delay(0.24, function() HUD.flash(Color3.fromRGB(140, 0, 0), 0.7) end)
end

local function setMusic(fight: boolean)
	if fight then
		if not music then music = Sfx.loop("FightMusic") end
	else
		if music then
			local m = music
			music = nil
			TweenService:Create(m, TweenInfo.new(2), { Volume = 0 }):Play()
			task.delay(2.1, function() m:Destroy() end)
		end
	end
end

function Fx.handle(kind: string, ...)
	local args = { ... }
	if kind == "Hit" then
		local pos, combo, dmg, isUlt, by = args[1], args[2], args[3], args[4], args[5]
		local mine = by == lp
		GA.flash(isUlt and 1 or 0.85)
		flashBall(pos, isUlt and Color3.fromRGB(255, 80, 30) or Color3.fromRGB(230, 245, 245), 3 + math.min(combo, 14) * 0.5, 0.18)
		burst(pos, Color3.fromRGB(190, 225, 230), 10 + combo * 2, 18 + combo * 2, 0.5)
		local heavy = combo >= 5 or isUlt
		Sfx.at(heavy and "PunchHeavy" or "PunchLight", pos, { PlaybackSpeed = math.max(0.75, 1.15 - combo * 0.03), Volume = 0.8 + math.min(combo, 10) * 0.05 })
		if combo % 3 == 0 then Sfx.at(Sfx.voice("Hurt"), pos, { PlaybackSpeed = rng:NextNumber(0.9, 1.15) }) end
		if mine then
			Fx.shake(0.18 + math.min(combo, 15) * 0.045 + (isUlt and 0.3 or 0))
			Fx.kick(2 + math.min(combo, 12) * 0.6)
			HUD.combo(combo, isUlt)
			if heavy then HUD.flash(isUlt and Color3.fromRGB(200, 40, 0) or Color3.fromRGB(255, 255, 255), isUlt and 0.35 or 0.12) end
		end
	elseif kind == "Smash" then
		local pos, size, k = args[1], args[2], args[3]
		Sfx.at("WoodBreak", pos, { PlaybackSpeed = rng:NextNumber(0.85, 1.1), Volume = 1 })
		if k == "Cabinet" or k == "StandingMirror" or k == "TV" or k == "Sink" then Sfx.at("Glass", pos) end
		burst(pos, Color3.fromRGB(120, 100, 80), 18, 20, 1.2)
		local d = (cam.CFrame.Position - pos).Magnitude
		if d < 40 then Fx.shake(0.25 * (1 - d / 40) + 0.05) end
	elseif kind == "WallSmash" then
		-- she smashed through a wall
		local pos, speed = args[1], args[2]
		Sfx.at("WoodBreak", pos, { Volume = 1.3, PlaybackSpeed = 0.8 + math.random() * 0.3 })
		Sfx.at("Crash", pos, { Volume = 1, PlaybackSpeed = 1.1 })
		burst(pos, Color3.fromRGB(190, 175, 150), 45, 35, 1.8)
		local d = (cam.CFrame.Position - pos).Magnitude
		if d < 80 then Fx.shake(math.clamp(speed / 100, 0.3, 1) * (1 - d / 80)) end
	elseif kind == "GhostRagdoll" then
		-- knocked out: a silly yelp and a big shake
		Sfx.at(Sfx.voice("Hurt"), args[1], { Volume = 1.2, PlaybackSpeed = Sfx.voice("Hurt") == "GhostHurt" and 1.5 or 1.1 })
		Sfx.at("PunchHeavy", args[1], { Volume = 1.2, PlaybackSpeed = 0.7 })
		Fx.shake(0.5)
	elseif kind == "WallSlam" then
		local pos, speed = args[1], args[2]
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.6, Volume = 1.2 })
		burst(pos, Color3.fromRGB(170, 160, 140), 30, 25, 1.6)
		local d = (cam.CFrame.Position - pos).Magnitude
		if d < 60 then Fx.shake(math.clamp(speed / 120, 0.2, 0.9) * (1 - d / 60)) end
	elseif kind == "Clawed" then
		local dir = args[1]
		Sfx.play(Sfx.voice("Claw"), { Volume = 0.7, PlaybackSpeed = Sfx.voice("Claw") == "GhostScream" and 1.2 or 1 })
		Sfx.play("PunchLight", { PlaybackSpeed = 0.7 })
		slash()
		HUD.flash(Color3.fromRGB(150, 0, 0), 0.5)
		Fx.shake(0.6)
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and typeof(dir) == "Vector3" then hrp.AssemblyLinearVelocity = dir * 55 + Vector3.new(0, 22, 0) end
	elseif kind == "Fling" then
		-- thrown across the room (a monster grab, or another player's throw): tumble, then get back up
		local vel, t, byName, label = args[1], args[2], args[3], args[4]
		local ch = lp.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hrp and hum and typeof(vel) == "Vector3" then
			hum:ChangeState(Enum.HumanoidStateType.FallingDown)
			hrp.AssemblyLinearVelocity = vel
			hrp.AssemblyAngularVelocity = Vector3.new(rng:NextNumber(-8, 8), rng:NextNumber(-4, 4), rng:NextNumber(-8, 8))
			-- hold the launch speed for a moment so floor friction can't eat it (a real throw across the room)
			local att = Instance.new("Attachment"); att.Parent = hrp
			local lv = Instance.new("LinearVelocity")
			lv.Attachment0 = att; lv.RelativeTo = Enum.ActuatorRelativeTo.World; lv.MaxForce = 1e6
			lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.VectorVelocity = vel; lv.Parent = hrp
			local t0 = os.clock()
			local conn
			conn = RunService.Heartbeat:Connect(function()
				local e = os.clock() - t0
				if e > 0.28 or not lv.Parent then
					conn:Disconnect(); lv:Destroy(); att:Destroy()
					return
				end
				lv.VectorVelocity = vel + Vector3.new(0, -workspace.Gravity * e, 0)
			end)
			task.delay(typeof(t) == "number" and t or 1, function()
				if hum.Parent and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
			end)
			-- the Goblin's hits: the camera is glued to your tumbling head, you lose all sense of direction
			if label == "goblin" then Fx.headCam(ch, (typeof(t) == "number" and t or 1) + 0.35) end
		end
		Sfx.play("PunchHeavy", { PlaybackSpeed = 0.7 })
		HUD.flash(Color3.fromRGB(150, 0, 0), 0.4)
		Fx.shake(0.8)
		if type(byName) == "string" and byName ~= "" then HUD.toast(string.upper(byName) .. " HIT YOU") end
	elseif kind == "PlayerHit" then
		local pos, dmg, by = args[1], args[2], args[3]
		flashBall(pos, Color3.fromRGB(255, 90, 60), 3, 0.18)
		burst(pos, Color3.fromRGB(150, 20, 20), 14, 18, 0.5)
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.9 })
		if by == lp then Fx.kick(4); HUD.toast("HIT A TEAMMATE  -" .. math.floor(dmg or 0)) end
	elseif kind == "Jumpscare" then
		jumpscare()
	elseif kind == "GhostScream" then
		Sfx.at("GhostScream", args[1], { Volume = 0.3 })
	elseif kind == "GhostWindUp" then
		local w = Sfx.voice("WindUp")
		Sfx.at(w, args[1], { PlaybackSpeed = w == "GhostWail" and 1.4 or 1, Volume = 0.8 })
	elseif kind == "GhostVanish" then
		Sfx.at("GhostWhisper", args[1], { Volume = 0.8 })
	elseif kind == "GhostSpawn" then
		local v = Sfx.voice("Spawn", args[2])
		Sfx.at(v, args[1], { Volume = 1.2, PlaybackSpeed = v == "GhostScream" and 0.8 or 1 })
		Fx.shake(0.4)
		setMusic(true)
	elseif kind == "GhostDeath" then
		local pos = args[1]
		Sfx.play(Sfx.voice("Death"), { Volume = 1.2 })
		burst(pos, Color3.fromRGB(210, 240, 245), 120, 30, 1.4)
		flashBall(pos, Color3.new(1, 1, 1), 26, 0.9)
		Fx.shake(0.9)
		setMusic(false)
	elseif kind == "Ultimate" then
		local pos, by, ultId = args[1], args[2], args[3]
		local u = Ultimates.byId[ultId or "Rage"]
		local ucolor = u and u.color or Color3.fromRGB(255, 60, 20)
		Sfx.at("Ultimate", pos, { Volume = 1.3 })
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.5, Volume = 1.3 })
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Cylinder; ring.Material = Enum.Material.Neon; ring.Color = ucolor
		ring.Anchored = true; ring.CanCollide = false; ring.CanQuery = false; ring.CanTouch = false
		ring.Size = Vector3.new(0.6, 2, 2); ring.CFrame = CFrame.new(pos - Vector3.new(0, 2.6, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		ring.Transparency = 0.2; ring.Parent = workspace.Terrain
		TweenService:Create(ring, TweenInfo.new(0.6, Enum.EasingStyle.Quad), { Size = Vector3.new(0.6, Config.Brutality.UltShockRadius * 2, Config.Brutality.UltShockRadius * 2), Transparency = 1 }):Play()
		Debris:AddItem(ring, 0.7)
		burst(pos, ucolor, 60, 40, 1.2)
		if by == lp then
			VM.slam()
			Fx.shake(1)
			Fx.kick(18)
			HUD.flash(ucolor, 0.6)
			HUD.banner(u and string.upper(u.name) or "UNLEASHED", "", 1.8)
		end
	elseif kind == "UltShock" then
		UltFx.shock(args[1], args[2], args[3])
	elseif kind == "UltStrike" then
		UltFx.strike(args[1], args[2], args[3])
	elseif kind == "UltFreeze" then
		UltFx.freeze(args[1], args[2])
	elseif kind == "TimeStop" then
		UltFx.timeStop(args[1])
	elseif kind == "TimeResume" then
		UltFx.timeResume(args[1], args[2])
	elseif kind == "OnePunch" then
		UltFx.onePunch(args[1], args[2])
	elseif kind == "BuyResult" then
		local ok, name, at = args[1], args[2], args[3]
		HUD.toast(ok and ("BOUGHT " .. name) or name, ok)
		if ok then
			Sfx.play("Cash")
			if typeof(at) == "Vector3" then burst(at + Vector3.new(0, 1.5, 0), Color3.fromRGB(150, 220, 110), 24, 10, 0.5) end
		end
	elseif kind == "Tracer" then
		local from, ends, color, by = args[1], args[2], args[3], args[4]
		for _, to in ends do
			local len = (to - from).Magnitude
			local o = from + (to - from).Unit * 2
			local tr = Instance.new("Part")
			tr.Anchored = true; tr.CanCollide = false; tr.CanQuery = false; tr.CanTouch = false; tr.CastShadow = false
			tr.Material = Enum.Material.Neon; tr.Color = color; tr.Size = Vector3.new(0.12, 0.12, math.max(0.5, len - 2))
			tr.CFrame = CFrame.lookAt((o + to) / 2, to); tr.Parent = workspace.Terrain
			TweenService:Create(tr, TweenInfo.new(0.12), { Transparency = 1 }):Play()
			Debris:AddItem(tr, 0.15)
		end
		local sfx = Items.byId[args[5] or ""] and Items.byId[args[5]].sfx
		if sfx and sfx.use then
			Sfx.at(sfx.use, from, { PlaybackSpeed = sfx.speed or 1 })
			if sfx.after then task.delay(0.4, function() Sfx.at(sfx.after, from) end) end
		else
			Sfx.at("PunchHeavy", from, { PlaybackSpeed = 1.6, Volume = 0.7 })
		end
		if by == lp then Fx.shake(0.15); Fx.kick(3) end
	elseif kind == "ItemBoom" then
		local pos, radius, color, loud = args[1], args[2], args[3], args[4]
		flashBall(pos, color, radius * 1.6, 0.35)
		burst(pos, color, 20 + radius * 2, 15 + radius, 1)
		Sfx.at(loud and "Explosion" or "PunchHeavy", pos, { Volume = loud and 1.2 or 0.9, PlaybackSpeed = loud and 1 or 0.8 })
		local d = (cam.CFrame.Position - pos).Magnitude
		if d < 60 then Fx.shake((loud and 0.7 or 0.3) * (1 - d / 60)) end
	elseif kind == "TrapSnap" then
		Sfx.at("PunchHeavy", args[1], { PlaybackSpeed = 1.3, Volume = 1.2 })
		burst(args[1], Color3.fromRGB(150, 150, 150), 14, 10, 0.5)
	elseif kind == "ItemSwing" then
		local by, id, hit = args[1], args[2], args[3]
		local sfx = Items.byId[id] and Items.byId[id].sfx
		local head = by and by.Character and by.Character:FindFirstChild("Head") :: BasePart?
		-- the item's own sounds: swing (others hear it in 3D; yours plays from the Hotbar) and hit
		if sfx and head then
			if sfx.use and by ~= lp then Sfx.at(sfx.use, head.Position, { PlaybackSpeed = sfx.speed or 1 }) end
			if sfx.hit and hit then
				local key = tostring(by.UserId) .. sfx.hit
				local now = os.clock()
				if now - (lastItemSfx[key] or 0) >= (sfx.every or 0.15) then
					lastItemSfx[key] = now
					if by == lp then Sfx.play(sfx.hit, { PlaybackSpeed = (sfx.speed or 1) * (0.95 + math.random() * 0.1) })
					else Sfx.at(sfx.hit, head.Position, { PlaybackSpeed = sfx.speed or 1 }) end
				end
			end
		end
		if by ~= lp and (id == "Chainsaw" or (sfx and sfx.use)) then
			-- their saw's own 3D engine loop covers it (ThirdPersonItems + SawAudio)
		elseif by ~= lp and by and by.Character and by.Character:FindFirstChild("Head") then
			Sfx.at("Whoosh", by.Character.Head.Position, { PlaybackSpeed = 0.8 })
		elseif by == lp and hit then
			-- the swing connected: hit-stop, a heavier shake for heavy weapons, sparks at the weapon's end
			local it = Items.byId[id]
			local heavy = it ~= nil and (it.knock or 0) >= 60
			VM.impact(heavy)
			if id == "Chainsaw" then SawAudio.hit() end
			Fx.shake(heavy and 0.45 or 0.22)
			Fx.kick(heavy and 6 or 3)
			local tip = VM.itemTip()
			if tip then burst(tip, Color3.fromRGB(255, 220, 160), heavy and 18 or 10, 14, 0.25, "rbxasset://textures/particles/sparkles_main.dds") end
		end
	elseif kind == "ItemBroke" then
		HUD.toast("YOUR " .. string.upper(args[1]) .. " IS SPENT")
	elseif kind == "ItemUsed" then
		Sfx.play("Cash", { PlaybackSpeed = 1.6, Volume = 0.5 })
	elseif kind == "RunOver" then
		local reason, cash, k = args[1], args[2], args[3]
		HUD.banner(reason == "died" and "YOU DIED" or "RUN OVER", "+$" .. tostring(cash) .. "  (" .. tostring(k) .. " GHOSTS)", 5)
		Sfx.play("Cash")
	elseif kind == "Toast" then
		HUD.toast(args[1])
	elseif kind == "BackInLobby" then
		HUD.banner("BACK IN THE PARK", "", 2.5)
	elseif kind == "Lift" then
		Sfx.at("PunchLight", args[1], { PlaybackSpeed = 0.5, Volume = 0.6 })
	elseif kind == "Throw" then
		Sfx.at("Whoosh", args[1], { PlaybackSpeed = 0.7, Volume = 1 })
		if args[2] == lp then Fx.kick(6) end
	elseif kind == "Tired" then
		HUD.flash(Color3.fromRGB(120, 110, 40), 0.25)
	elseif kind == "Intro" then
		-- args: ghost number, monster title, rarity
		local rar = args[3] or 0
		local tag = rar == 3 and "LEGENDARY - " or (rar == 2 and "RARE - " or "")
		HUD.banner(args[2] or "SHE IS IN THE HOUSE", tag .. "GHOST " .. tostring(args[1]), 4)
		Sfx.play("GhostWhisper", { Volume = 1 })
	elseif kind == "Victory" then
		HUD.banner("GHOST DESTROYED", "+$" .. tostring(args[1]) .. " RUN CASH", 4)
		Sfx.play("Cash")
		setMusic(false)
	elseif kind == "ShopReady" then
		local k = args[1]
		local title = k == "van" and "A VAN SMASHED INTO THE HOUSE" or (k == "train" and "THE TRAIN JUMPED THE RAILS" or "SOMEONE SURVIVED THE CRASH")
		HUD.banner(title, "SHOP OPEN - RUN CASH ONLY", 4)
	end
end

local PRESETS = {
	inside = { ClockTime = 19.1, Brightness = 1.4, Exposure = 0, Ambient = Color3.fromRGB(30, 27, 25), Outdoor = Color3.fromRGB(105, 110, 138),
		AtmDensity = 0.12, AtmColor = Color3.fromRGB(58, 60, 78), AtmDecay = Color3.fromRGB(36, 36, 50), AtmHaze = 0.6, AtmGlare = 0,
		Tint = Color3.fromRGB(255, 240, 226), Sat = -0.38, Contrast = 0.22 },
	lobby = { ClockTime = 19.6, Brightness = 1.0, Exposure = -0.2, Ambient = Color3.fromRGB(35, 38, 30), Outdoor = Color3.fromRGB(90, 95, 80),
		AtmDensity = 0.42, AtmColor = Color3.fromRGB(168, 166, 122), AtmDecay = Color3.fromRGB(96, 98, 70), AtmHaze = 2.4, AtmGlare = 0.8,
		Tint = Color3.fromRGB(230, 238, 200), Sat = -0.25, Contrast = 0.2 },
}
PRESETS.yard = table.clone(PRESETS.inside)
PRESETS.yard.Exposure = 0.35
PRESETS.yard.AtmDensity = 0.42
PRESETS.yard.AtmColor = Color3.fromRGB(26, 28, 32)
PRESETS.yard.AtmDecay = Color3.fromRGB(14, 14, 18)
PRESETS.yard.AtmHaze = 1.3
local currentZone = ""
local Maps = require(RS.Shared.Maps)
function Fx.applyZone(zone: string, dt: number)
	local p = PRESETS[zone]
	-- each map has its own interior look (tint, ambient, grade)
	if zone == "inside" then
		local m = Maps.byId[RS:GetAttribute("MapId") or "Mansion"]
		if m and m.id ~= "Mansion" then
			p = table.clone(p)
			for k, v in m.light do p[k] = v end
		end
	end
	local a = zone == currentZone and math.min(1, dt * 2) or 1
	currentZone = zone
	local atm = Lighting:FindFirstChildOfClass("Atmosphere")
	local cc = Lighting:FindFirstChild("PS2Grade") :: ColorCorrectionEffect?
	Lighting.ClockTime = p.ClockTime
	Lighting.Brightness = p.Brightness
	Lighting.Ambient = p.Ambient
	Lighting.OutdoorAmbient = p.Outdoor
	Lighting.ExposureCompensation += (p.Exposure - Lighting.ExposureCompensation) * a
	if atm then
		atm.Density = p.AtmDensity; atm.Color = p.AtmColor; atm.Decay = p.AtmDecay; atm.Haze = p.AtmHaze; atm.Glare = p.AtmGlare
	end
	if cc then cc.TintColor = p.Tint; cc.Saturation = p.Sat; cc.Contrast = p.Contrast end
end

-- the camera follows the head (position AND rotation) for `dur` seconds, then eases back to normal
local headCamUntil, headCamBound = 0, false
function Fx.headCam(ch: Model, dur: number)
	local head = ch:FindFirstChild("Head") :: BasePart?
	if not head then return end
	headCamUntil = math.max(headCamUntil, os.clock() + dur)
	if headCamBound then return end
	headCamBound = true
	local t0, blend = os.clock(), 0
	local roll = (rng:NextNumber() < 0.5 and -1 or 1) * rng:NextNumber(2.5, 4) -- extra spin, rad/s
	RunService:BindToRenderStep("GoblinHeadCam", Enum.RenderPriority.Camera.Value + 1, function(dt)
		local now = os.clock()
		local on = now < headCamUntil and head.Parent ~= nil
		blend = on and math.min(1, blend + dt * 10) or math.max(0, blend - dt * 2.5)
		if blend <= 0 and not on then
			RunService:UnbindFromRenderStep("GoblinHeadCam")
			headCamBound = false
			return
		end
		if head.Parent then
			local want = head.CFrame * CFrame.new(0, 0.3, -0.2) * CFrame.Angles(0, 0, (now - t0) * roll)
			cam.CFrame = cam.CFrame:Lerp(want, blend)
		end
	end)
end

function Fx.init()
	blur = Instance.new("BlurEffect"); blur.Size = 0; blur.Parent = Lighting
	grade = Instance.new("ColorCorrectionEffect"); grade.Name = "FxGrade"; grade.Parent = Lighting
	slashGui = Instance.new("ScreenGui"); slashGui.Name = "Slashes"; slashGui.IgnoreGuiInset = true; slashGui.ResetOnSpawn = false
	slashGui.Parent = lp:WaitForChild("PlayerGui")
	ambience = Sfx.loop("Ambience")
	UltFx.init(Fx, HUD)
	RunService:BindToRenderStep("FxShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
		trauma = math.max(0, trauma - dt * 1.6)
		local s = trauma * trauma
		local t = os.clock() * 40
		local off = CFrame.Angles(math.noise(t, 1) * 0.06 * s, math.noise(t, 2) * 0.06 * s, math.noise(t, 3) * 0.08 * s)
			* CFrame.new(math.noise(t, 4) * 0.5 * s, math.noise(t, 5) * 0.5 * s, 0)
		cam.CFrame = cam.CFrame * off
		VM.setShake(CFrame.new())
		fovKick += (0 - fovKick) * math.min(1, dt * 8)
		cam.FieldOfView = baseFov + fovKick
		-- zone lighting: green park fog (lobby), dark PS2 interior (house), brighter yard outside
		local pos = cam.CFrame.Position
		local zone = pos.Z > 600 and "lobby" or ((pos.X > Config.House.Min.X and pos.X < Config.House.Max.X and pos.Z > Config.House.Min.Z and pos.Z < Config.House.Max.Z and pos.Y < 45) and "inside" or "yard")
		Fx.applyZone(zone, dt)
		if ambience then ambience.Volume = zone == "inside" and 0.45 or (zone == "lobby" and 0.35 or 0.15) end
	end)
end

return Fx
