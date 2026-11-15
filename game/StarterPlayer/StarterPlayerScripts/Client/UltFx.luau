-- Client visuals for ultimates: coloured shockwaves, lightning, meteors, holy beams, nukes, ice, time stop.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Sfx = require(script.Parent.Sfx)

local UltFx = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local Fx -- set by init (shake / kick)
local HUD
local rng = Random.new()

local function neon(size: Vector3, cf: CFrame, color: Color3, t: number?, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Material = Enum.Material.Neon; p.Color = color; p.Size = size; p.CFrame = cf; p.Transparency = t or 0
	if shape then p.Shape = shape end
	p.Parent = workspace.Terrain
	return p
end

local function near(pos: Vector3, amount: number, range: number)
	local d = (cam.CFrame.Position - pos).Magnitude
	if d < range and Fx then Fx.shake(amount * (1 - d / range)) end
end

function UltFx.shock(center: Vector3, r: number, color: Color3)
	local ring = neon(Vector3.new(0.6, 2, 2), CFrame.new(center - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.pi / 2), color, 0.15, Enum.PartType.Cylinder)
	TweenService:Create(ring, TweenInfo.new(0.55, Enum.EasingStyle.Quad), { Size = Vector3.new(0.6, r * 2, r * 2), Transparency = 1 }):Play()
	Debris:AddItem(ring, 0.6)
	local dome = neon(Vector3.one * 3, CFrame.new(center), color, 0.4, Enum.PartType.Ball)
	TweenService:Create(dome, TweenInfo.new(0.4), { Size = Vector3.one * r, Transparency = 1 }):Play()
	Debris:AddItem(dome, 0.45)
	Sfx.at("PunchHeavy", center, { PlaybackSpeed = 0.5, Volume = 1.1 })
	near(center, 0.5 + r / 100, r * 2.5)
end

local function bolt(to: Vector3, color: Color3)
	local from = to + Vector3.new(rng:NextNumber(-8, 8), 70, rng:NextNumber(-8, 8))
	local pts = { from }
	for i = 1, 6 do
		local a = i / 7
		table.insert(pts, from:Lerp(to, a) + Vector3.new(rng:NextNumber(-3, 3), 0, rng:NextNumber(-3, 3)))
	end
	table.insert(pts, to)
	for i = 1, #pts - 1 do
		local a, b = pts[i], pts[i + 1]
		local seg = neon(Vector3.new(0.5, 0.5, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), color:Lerp(Color3.new(1, 1, 1), 0.5))
		TweenService:Create(seg, TweenInfo.new(0.25), { Transparency = 1 }):Play()
		Debris:AddItem(seg, 0.3)
	end
	local flash = neon(Vector3.one * 6, CFrame.new(to), Color3.new(1, 1, 1), 0.2, Enum.PartType.Ball)
	local l = Instance.new("PointLight"); l.Range = 50; l.Brightness = 5; l.Color = color; l.Parent = flash
	TweenService:Create(flash, TweenInfo.new(0.2), { Size = Vector3.one * 12, Transparency = 1 }):Play()
	Debris:AddItem(flash, 0.25)
	Sfx.at("Explosion", to, { PlaybackSpeed = 1.8, Volume = 0.6 })
	near(to, 0.35, 60)
end

local function meteor(to: Vector3, color: Color3, size: number, dur: number)
	local from = to + Vector3.new(rng:NextNumber(-40, 40), 120, rng:NextNumber(-40, 40))
	local rock = neon(Vector3.one * size, CFrame.new(from), color, 0, Enum.PartType.Ball)
	rock.Material = Enum.Material.CrackedLava
	local f = Instance.new("Fire"); f.Size = size * 2; f.Heat = 20; f.Parent = rock
	local l = Instance.new("PointLight"); l.Range = size * 8; l.Brightness = 3; l.Color = color; l.Parent = rock
	TweenService:Create(rock, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = to }):Play()
	task.delay(dur, function()
		rock:Destroy()
		local boom = neon(Vector3.one * size, CFrame.new(to), Color3.fromRGB(255, 200, 80), 0.1, Enum.PartType.Ball)
		TweenService:Create(boom, TweenInfo.new(0.5), { Size = Vector3.one * size * 6, Transparency = 1 }):Play()
		Debris:AddItem(boom, 0.55)
		Sfx.at("Explosion", to, { Volume = math.min(1.6, 0.6 + size / 10) })
		near(to, math.min(1.2, 0.3 + size / 15), 80 + size * 5)
	end)
end

local function beam(to: Vector3, color: Color3)
	local col = neon(Vector3.new(1, 80, 1), CFrame.new(to + Vector3.new(0, 40, 0)), color, 0.1)
	local l = Instance.new("PointLight"); l.Range = 40; l.Brightness = 4; l.Color = color; l.Parent = col
	TweenService:Create(col, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Size = Vector3.new(7, 80, 7) }):Play()
	task.delay(0.35, function()
		TweenService:Create(col, TweenInfo.new(0.4), { Size = Vector3.new(0.2, 80, 0.2), Transparency = 1 }):Play()
	end)
	Debris:AddItem(col, 0.8)
	Sfx.at("Ultimate", to, { PlaybackSpeed = 1.5, Volume = 0.7 })
	near(to, 0.3, 50)
end

function UltFx.strike(style: string, pos: Vector3, color: Color3)
	if style == "lightning" then bolt(pos, color)
	elseif style == "meteor" then meteor(pos, color, 4, 0.7)
	elseif style == "holy" then beam(pos, color)
	elseif style == "nuke" then
		meteor(pos, color, 14, 1.6)
		task.delay(1.6, function()
			if HUD then HUD.flash(Color3.new(1, 1, 0.85), 1) end
			if Fx then Fx.shake(1.3); Fx.kick(25) end
		end)
	end
end

function UltFx.freeze(gpos: Vector3, t: number)
	local g = workspace:FindFirstChild("Ghost")
	local ice = neon(Vector3.new(5.5, 12, 4.5), CFrame.new(gpos + Vector3.new(0, 0.5, 0)), Color3.fromRGB(170, 225, 255), 0.45)
	ice.Material = Enum.Material.Ice
	Sfx.at("Glass", gpos, { PlaybackSpeed = 0.6 })
	local t0 = os.clock()
	task.spawn(function()
		while os.clock() - t0 < t and g and g.Parent and g:GetAttribute("Frozen") do
			local hrp = g:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then ice.CFrame = hrp.CFrame * CFrame.new(0, 0.5, 0) end
			task.wait()
		end
		ice:Destroy()
		Sfx.at("Glass", gpos)
	end)
end

local tsGrade: ColorCorrectionEffect? = nil
function UltFx.timeStop(t: number)
	if not tsGrade then
		tsGrade = Instance.new("ColorCorrectionEffect"); tsGrade.Name = "TimeStop"; tsGrade.Parent = Lighting
	end
	local g = tsGrade :: ColorCorrectionEffect
	g.Saturation = -1; g.TintColor = Color3.fromRGB(220, 215, 255); g.Contrast = 0.3
	Sfx.play("Ultimate", { PlaybackSpeed = 0.4, Volume = 1.2 })
	if HUD then HUD.banner("TIME STOPS", "", t * 0.6) end
	task.delay(t, function()
		TweenService:Create(g, TweenInfo.new(0.4), { Saturation = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1) }):Play()
	end)
end

function UltFx.timeResume(pos: Vector3, stored: number)
	local b = neon(Vector3.one * 4, CFrame.new(pos), Color3.fromRGB(255, 240, 160), 0, Enum.PartType.Ball)
	TweenService:Create(b, TweenInfo.new(0.6), { Size = Vector3.one * (16 + math.min(stored, 400) * 0.08), Transparency = 1 }):Play()
	Debris:AddItem(b, 0.65)
	Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.45, Volume = 1.5 })
	near(pos, 1.1, 100)
	if HUD then HUD.banner(tostring(math.floor(stored)) .. " DAMAGE", "TIME RESUMES", 2) end
end

function UltFx.onePunch(pos: Vector3, by: Player)
	if HUD then HUD.flash(Color3.new(1, 1, 1), 1) end
	local b = neon(Vector3.one * 4, CFrame.new(pos), Color3.fromRGB(255, 230, 0), 0, Enum.PartType.Ball)
	TweenService:Create(b, TweenInfo.new(0.7), { Size = Vector3.one * 50, Transparency = 1 }):Play()
	Debris:AddItem(b, 0.75)
	Sfx.at("PunchHeavy", pos, { PlaybackSpeed = 0.35, Volume = 1.8 })
	if Fx then Fx.shake(1.3); Fx.kick(30) end
	if by == lp and HUD then HUD.banner("ONE PUNCH", "", 2) end
end

function UltFx.init(fx, hud) Fx = fx; HUD = hud end

return UltFx
