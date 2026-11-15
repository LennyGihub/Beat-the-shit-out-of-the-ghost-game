--!strict
-- Chainsaw sounds.
-- Your own saw (2D): pull-start when you select it, idle engine loop while it's in your hands, a rev-up when
-- you pull the trigger, the cutting loop while you hold it (crossfades with the idle), and a grind when the
-- chain bites. Other players' saws (3D, on their saw model): idle loop, cutting loop while they swing.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Sounds = require(RS.Shared.Sounds)

local SawAudio = {}
local lp = Players.LocalPlayer
local rng = Random.new()

local holding = false
local startedAt = 0
local lastUse = 0
local lastHit = 0
local idle: Sound? = nil
local cut: Sound? = nil

local function sound(name: string, parent: Instance, volume: number?, looped: boolean?): Sound
	local def = Sounds[name]
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = "rbxassetid://" .. def.ids[rng:NextInteger(1, #def.ids)]
	s.Volume = volume or def.volume
	s.Looped = looped == true
	s.Parent = parent
	return s
end

local function oneShot(name: string, props: { [string]: any }?)
	local s = sound(name, SoundService)
	if props then for k, v in props do (s :: any)[k] = v end end
	s:Play()
	s.Ended:Once(function() s:Destroy() end)
	task.delay(10, function() if s.Parent then s:Destroy() end end)
end

-- the item in the player's selected hotbar slot (attributes Inv + Sel, set by the server)
local function selectedId(p: Player): string?
	local sel = p:GetAttribute("Sel") or 0
	if sel <= 0 or not p:GetAttribute("InMatch") then return nil end
	local n = 0
	for entry in string.gmatch((p:GetAttribute("Inv") or "") .. ",", "([^,]*),") do
		n += 1
		if n == sel then return string.match(entry, "^([^:]+)") end
	end
	return nil
end

-- Hotbar calls this on every chainsaw tick while the trigger is held
function SawAudio.used()
	local now = os.clock()
	if now - lastUse > 0.35 then
		oneShot("SawRevUp", { PlaybackSpeed = 0.95 + rng:NextNumber() * 0.1 })
	end
	lastUse = now
end

-- Fx calls this when your saw connects
function SawAudio.hit()
	local now = os.clock()
	if now - lastHit < 0.2 then return end
	lastHit = now
	oneShot("SawHit", { PlaybackSpeed = 0.85 + rng:NextNumber() * 0.3 })
end

local function stopOwn()
	holding = false
	for _, s in { idle, cut } do
		local snd = s :: Sound?
		if snd then
			task.spawn(function()
				local v0 = snd.Volume
				for i = 1, 10 do snd.Volume = v0 * (1 - i / 10); task.wait(0.03) end
				snd:Destroy()
			end)
		end
	end
	idle, cut = nil, nil
end

local function step(dt: number)
	local ch = lp.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local has = selectedId(lp) == "Chainsaw" and hum ~= nil and hum.Health > 0
	local now = os.clock()
	if has and not holding then
		holding = true
		startedAt = now
		oneShot("SawStart")
		idle = sound("SawIdle", SoundService, 0, true)
		cut = sound("SawCut", SoundService, 0, true)
		;(idle :: Sound):Play()
		;(cut :: Sound):Play()
	elseif not has and holding then
		stopOwn()
	end
	if holding and idle and cut then
		local cutting = now - lastUse < 0.22
		local warm = now - startedAt > 1.8 -- the idle comes in once the pull-start has caught
		local k = math.min(1, dt * 12)
		local ti = cutting and 0.12 or (warm and Sounds.SawIdle.volume or 0)
		local tc = cutting and Sounds.SawCut.volume or 0
		idle.Volume += (ti - idle.Volume) * k
		cut.Volume += (tc - cut.Volume) * k
		cut.PlaybackSpeed = 1 + math.sin(now * 7) * 0.025 + (cutting and rng:NextNumber() * 0.02 or 0)
	end
end

-- 3D loops for another player's saw model; returns an update function (cutting = they swung recently)
function SawAudio.attach(model: Model): (cutting: boolean) -> ()
	local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if not root then return function(_c) end end
	local a = sound("SawIdle", root, 0, true)
	local c = sound("SawCut", root, 0, true)
	for _, s in { a, c } do
		s.RollOffMode = Enum.RollOffMode.InverseTapered
		s.RollOffMinDistance = 8
		s.RollOffMaxDistance = 120
		s:Play()
	end
	return function(cutting: boolean)
		a.Volume = cutting and 0.1 or Sounds.SawIdle.volume * 0.8
		c.Volume = cutting and Sounds.SawCut.volume or 0
	end
end

function SawAudio.init()
	RunService.RenderStepped:Connect(step)
	if RunService:IsStudio() then
		-- Studio test hook: player attribute DebugSawCut = seconds of "trigger held"
		lp:GetAttributeChangedSignal("DebugSawCut"):Connect(function()
			local t = lp:GetAttribute("DebugSawCut")
			if type(t) ~= "number" then return end
			task.spawn(function()
				local t0 = os.clock()
				while os.clock() - t0 < t do SawAudio.used(); task.wait(0.09) end
			end)
		end)
	end
end

return SawAudio
