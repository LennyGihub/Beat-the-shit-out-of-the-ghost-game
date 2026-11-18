--!strict
-- THE VOID KNIGHT'S BREATHING through his mask: a long deep INHALE, a pause, a long deep EXHALE, a pause, over and
-- over. Both halves are cut live out of one licensed recording of a breath through a scuba regulator (Pro Sound
-- Effects "Air Regulator Scuba Tank 2", Shared/Sounds KnightBreath): its long high hiss is the inhale (the demand
-- valve), its lower breath out is the exhale (the exhaust valve). Each half is slowed down (deeper and longer), the
-- exhale is brought up to the inhale's strength and given a faint valve flutter, and both get a tight helmet echo.
--   MaskBreath.start(parent, volume, opts?) -> stop()   (parent = a part: a 3D sound on it; else heard everywhere)
local RS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Sounds = require(RS.Shared.Sounds)
local Settings = require(script.Parent.Settings)

local MaskBreath = {}
-- the halves in the recording (seconds) and how much each is slowed
local IN0, IN1, IN_SPEED = 0.15, 3.25, 0.9 -- 3.1 s of hiss -> 3.4 s
local EX0, EX1, EX_SPEED = 3.5, 5.95, 0.8 -- 2.45 s -> 3.1 s
local EX_GAIN = 3.5 -- the exhale is about a third as loud as the inhale in the recording (PlaybackLoudness 71 vs 227)
local PAUSE_IN, PAUSE_OUT = 0.45, 0.9 -- after the inhale, after the exhale

export type Opts = { once: boolean?, rollMin: number?, rollMax: number? }

local function sound(parent: Instance, inhale: boolean, opts: Opts): Sound
	local def = Sounds.KnightBreath
	local s = Instance.new("Sound")
	s.Name = inhale and "BreathIn" or "BreathOut"
	s.SoundId = "rbxassetid://" .. def.ids[1]
	s.Volume = 0
	s.SoundGroup = Settings.group("KnightBreath")
	if parent:IsA("BasePart") or parent:IsA("Attachment") then
		s.RollOffMode = Enum.RollOffMode.InverseTapered
		s.RollOffMinDistance = opts.rollMin or 25
		s.RollOffMaxDistance = opts.rollMax or 140
	end
	local eq = Instance.new("EqualizerSoundEffect")
	if inhale then
		eq.LowGain = -2; eq.MidGain = 2; eq.HighGain = -1
	else
		eq.LowGain = 5; eq.MidGain = 3; eq.HighGain = -4
		local tr = Instance.new("TremoloSoundEffect") -- the exhaust valve fluttering
		tr.Frequency = 24; tr.Depth = 0.25; tr.Duty = 0.5; tr.Priority = 2; tr.Parent = s
	end
	eq.Priority = 1; eq.Parent = s
	local fl = Instance.new("FlangeSoundEffect") -- the hollow, tubey mask
	fl.Depth = 0.35; fl.Mix = 0.3; fl.Rate = 0.12; fl.Priority = 3; fl.Parent = s
	local rv = Instance.new("ReverbSoundEffect") -- inside a helmet
	rv.DecayTime = 0.25; rv.Density = 0.9; rv.Diffusion = 0.6; rv.DryLevel = 0; rv.WetLevel = -9; rv.Priority = 4; rv.Parent = s
	s.Parent = parent
	return s
end

-- one half: from t0 to t1 of the recording, faded in and out
local function half(s: Sound, t0: number, t1: number, speed: number, vol: number, alive: () -> boolean)
	if not alive() then return end
	s.PlaybackSpeed = speed
	s.TimePosition = t0
	s.Volume = 0
	s:Play()
	TweenService:Create(s, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Volume = vol }):Play()
	local dur = (t1 - t0) / speed
	local t = 0
	while t < dur - 0.3 and alive() do t += task.wait() end
	if not s.Parent then return end
	TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Volume = 0 }):Play()
	task.wait(0.3)
	if s.Parent then s:Stop() end
end

local function pause(t: number, alive: () -> boolean)
	local e = 0
	while e < t and alive() do e += task.wait() end
end

-- start breathing (on `parent`, or everywhere); returns a function that stops it. opts.once = one breath only
function MaskBreath.start(parent: Instance?, volume: number, opts: Opts?): () -> ()
	local o: Opts = opts or {}
	local where: Instance = parent or SoundService
	local inS, exS = sound(where, true, o), sound(where, false, o)
	local on = true
	local function alive(): boolean
		return on and inS.Parent ~= nil and exS.Parent ~= nil and (parent == nil or parent.Parent ~= nil)
	end
	task.spawn(function()
		local t0 = os.clock()
		while not (inS.IsLoaded and exS.IsLoaded) and os.clock() - t0 < 4 and alive() do task.wait() end
		repeat
			half(inS, IN0, IN1, IN_SPEED, volume, alive)
			pause(PAUSE_IN, alive)
			half(exS, EX0, EX1, EX_SPEED, math.min(10, volume * EX_GAIN), alive)
			if o.once then break end
			pause(PAUSE_OUT, alive)
		until not alive()
		inS:Destroy(); exS:Destroy()
	end)
	return function()
		on = false
	end
end

-- how long one breath lasts (inhale + pause + exhale), for timing a cinematic around it
MaskBreath.LENGTH = (IN1 - IN0) / IN_SPEED + PAUSE_IN + (EX1 - EX0) / EX_SPEED

return MaskBreath
