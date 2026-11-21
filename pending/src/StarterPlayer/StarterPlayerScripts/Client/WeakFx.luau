--!strict
-- WEAK, LIFTED, THROWN on the client (Config.Weak, Server/Ghost.weaken / lift / throwMonster). A x5 combo wears the
-- monster out: this draws it on every screen and says what to do.
--   * while it is WEAK: a pulsing gold outline on it (seen through walls) and a tag over its head: WEAK! + the lift key
--     (Client/GhostAnim slumps it and circles stars round its head; Client/Input lifts it with the lift key)
--   * Fx GhostWeak (pos, by): a heavy thud, a gold shock ring on the floor, and the banner WEAK! / LIFT IT
--   * Fx GhostLifted (pos, by), GhostBreakFree (pos, by: "IT BROKE FREE" for the one who held it), GhostWeakEnd (pos)
--   * Fx MonsterSlam (pos, dmg, by): the thrown monster lands: a crash, dust, a shake by distance, "SLAM!" for the thrower
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Grunge = require(script.Parent.Grunge)
local Platform = require(script.Parent.Platform)
local Sfx = require(script.Parent.Sfx)

local WeakFx = {}
local lp = Players.LocalPlayer
local GOLD = Color3.fromRGB(255, 205, 60)
local Fx: any = nil
local HUD: any = nil

WeakFx.KINDS = { "GhostWeak", "GhostWeakEnd", "GhostLifted", "GhostBreakFree", "MonsterSlam" }
local mine: { [string]: boolean } = {}
for _, k in WeakFx.KINDS do mine[k] = true end
function WeakFx.handles(kind: string): boolean return mine[kind] == true end

local function monster(): Model?
	local g = workspace:FindFirstChild("Ghost")
	return (g and g:IsA("Model")) and g or nil
end

-- a flat gold ring on the floor that grows and fades (this screen's own part)
local function ring(pos: Vector3, r0: number, r1: number, life: number)
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Material = Enum.Material.Neon; p.Color = GOLD; p.Transparency = 0.3
	p.Shape = Enum.PartType.Cylinder
	p.Size = Vector3.new(0.15, r0 * 2, r0 * 2)
	local fr = workspace:Raycast(pos + Vector3.new(0, 2, 0), Vector3.new(0, -14, 0))
	local y = fr and fr.Position.Y + 0.1 or pos.Y - 3
	p.CFrame = CFrame.new(pos.X, y, pos.Z) * CFrame.Angles(0, 0, math.pi / 2)
	p.Parent = workspace.CurrentCamera
	TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.15, r1 * 2, r1 * 2), Transparency = 1 }):Play()
	Debris:AddItem(p, life + 0.1)
end

-- a burst of dust where the thrown monster lands
local function dust(pos: Vector3, n: number)
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
	pe.Color = ColorSequence.new(Color3.fromRGB(150, 135, 115), Color3.fromRGB(70, 60, 50))
	pe.Size = NumberSequence.new(2, 7)
	pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
	pe.Lifetime = NumberRange.new(0.8, 1.5)
	pe.Speed = NumberRange.new(10, 24)
	pe.SpreadAngle = Vector2.new(180, 60)
	pe.Drag = 3
	pe.Rate = 0
	pe.Parent = a
	pe:Emit(n)
	Debris:AddItem(a, 2)
end

local function liftLabel(): string
	if Platform.mode() == "touch" then return "TAP LIFT" end
	return Platform.label("Lift") .. " LIFT IT"
end

function WeakFx.handle(kind: string, ...)
	local args = { ... }
	local pos = args[1]
	if typeof(pos) ~= "Vector3" then return end
	if kind == "GhostWeak" then
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.42, Volume = 1.3 })
		Sfx.at("Crash", pos, { PlaybackSpeed = 0.55, Volume = 0.7 })
		ring(pos, 1, 16, 0.6)
		task.delay(0.12, function() ring(pos, 1, 10, 0.5) end)
		if Fx then Fx.shake(0.35) end
		if HUD and lp:GetAttribute("InMatch") then HUD.banner("WEAK!", liftLabel() .. "  -  THEN THROW IT", 2.2) end
	elseif kind == "GhostLifted" then
		Sfx.at("Whoosh", pos, { PlaybackSpeed = 0.5, Volume = 0.9 })
		if args[2] == lp and Fx then Fx.kick(4) end
	elseif kind == "GhostBreakFree" then
		local g = monster()
		Sfx.at(Sfx.voice("WindUp", g and g:GetAttribute("MonsterId") or nil), pos, { Volume = 1.2 })
		if Fx then Fx.shake(0.3) end
		if args[2] == lp and HUD then HUD.toast("IT BROKE FREE - THROW IT FASTER", false) end
	elseif kind == "GhostWeakEnd" then
		Sfx.at("Whoosh", pos, { PlaybackSpeed = 0.8, Volume = 0.5 })
	elseif kind == "MonsterSlam" then
		Sfx.at("Crash", pos, { PlaybackSpeed = 0.7, Volume = 1.5 })
		Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.5, Volume = 1.2 })
		dust(pos, 40)
		ring(pos, 2, 20, 0.7)
		local d = (workspace.CurrentCamera.CFrame.Position - pos).Magnitude
		if Fx then Fx.shake(math.clamp(1.3 - d / 50, 0.2, 1.3)) end
		if args[3] == lp then
			if Fx then Fx.kick(8) end
			local dmg = tonumber(args[2]) or 0
			if HUD then HUD.toast("SLAM!  " .. math.floor(dmg + 0.5) .. " DAMAGE", true) end
		end
	end
end

-- while it is WEAK: the gold outline (through walls) and the tag over its head
local glow: Highlight? = nil
local tag: BillboardGui? = nil
local tagSub: TextLabel? = nil
local function clear()
	if glow then glow:Destroy(); glow = nil end
	if tag then tag:Destroy(); tag = nil; tagSub = nil end
end
function WeakFx.init(fx: any, hud: any)
	Fx = fx; HUD = hud
	RunService.Heartbeat:Connect(function()
		local g = monster()
		local weak = g ~= nil and g:GetAttribute("State") == "Weak"
		if not weak or not g then clear(); return end
		local m = g :: Model
		if not glow or glow.Adornee ~= m then
			clear()
			local h = Instance.new("Highlight")
			h.Name = "WeakGlow"
			h.Adornee = m
			h.FillColor = GOLD; h.OutlineColor = GOLD
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = workspace.CurrentCamera
			glow = h
			local head = (m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")) :: BasePart?
			if head then
				local b = Instance.new("BillboardGui")
				b.Name = "WeakTag"
				b.Adornee = head
				b.AlwaysOnTop = true
				b.Size = UDim2.fromOffset(220, 70)
				b.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
				b.LightInfluence = 0
				b.MaxDistance = 140
				b.ResetOnSpawn = false
				b.Parent = lp:WaitForChild("PlayerGui")
				Grunge.text(b, { Text = "WEAK!", Font = Grunge.HORROR, Size = UDim2.fromScale(1, 0.62), TextColor3 = GOLD, TextStrokeTransparency = 0 })
				tagSub = Grunge.text(b, { Text = "", Font = Grunge.FONT, Position = UDim2.fromScale(0, 0.62), Size = UDim2.fromScale(1, 0.38), TextStrokeTransparency = 0 })
				tag = b
			end
		end
		local k = math.sin(os.clock() * 7) * 0.5 + 0.5
		if glow then
			glow.FillTransparency = 0.62 + 0.25 * k
			glow.OutlineTransparency = 0.1 * k
		end
		if tag then tag.Enabled = lp:GetAttribute("InMatch") == true end
		if tagSub then tagSub.Text = liftLabel() end
	end)
end

return WeakFx
