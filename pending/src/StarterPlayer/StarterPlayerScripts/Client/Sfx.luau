-- Sound helper: 2D sounds, 3D sounds at a position, and loops.
local SoundService = game:GetService("SoundService")
local RS = game:GetService("ReplicatedStorage")
local Sounds = require(RS.Shared.Sounds)
local Settings = require(script.Parent.Settings) -- SFX / Music volume groups
local Sfx = {}
local rng = Random.new()

local function make(name: string, parent: Instance, props: { [string]: any }?): Sound?
	local def = Sounds[name]
	if not def then return nil end
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. def.ids[rng:NextInteger(1, #def.ids)]
	s.Volume = def.volume
	s.SoundGroup = Settings.group(name)
	if props then for k, v in props do (s :: any)[k] = v end end
	s.Parent = parent
	return s
end

-- each monster's own voice: Sfx.voice("Hurt") = the current monster's hurt sound
-- roles: Spawn, WindUp (about to attack), Claw (you got hit), Hurt, Death
local VOICES = {
	Woman = { Spawn = "GhostScream", WindUp = "GhostWail", Claw = "GhostScream", Hurt = "GhostHurt", Death = "GhostDeath" },
	Demon = { Spawn = "DemonSpawn", WindUp = "DemonGrowl", Claw = "DemonGrowl", Hurt = "DemonHurt", Death = "DemonDeath" },
	Pirate = { Spawn = "PirateSpawn", WindUp = "PirateSwing", Claw = "DemonHit", Hurt = "PirateHurt", Death = "PirateDeath" },
	Titan = { Spawn = "DemonRoar", WindUp = "DemonGrowl", Claw = "DemonHit", Hurt = "DemonHurt", Death = "DemonDeath" },
	Animatronic = { Spawn = "AnimSpawn", WindUp = "AnimGrowl", Claw = "AnimGrowl", Hurt = "AnimHurt", Death = "AnimDeath" },
	Goblin = { Spawn = "GoblinSpawn", WindUp = "GoblinGrowl", Claw = "GoblinCackle", Hurt = "GoblinHurt", Death = "GoblinDeath" },
	Conqueror = { Spawn = "DemonRoar", WindUp = "DemonGrowl", Claw = "DemonHit", Hurt = "DemonHurt", Death = "DemonDeath" },
}
local lastMonster = "Woman"
function Sfx.voice(role: string, monsterId: string?): string
	local g = workspace:FindFirstChild("Ghost")
	local id = monsterId or (g and g:GetAttribute("MonsterId")) or lastMonster
	lastMonster = id
	local v = VOICES[id] or VOICES.Woman
	return v[role] or VOICES.Woman[role]
end

function Sfx.play(name: string, props: { [string]: any }?): Sound?
	local s = make(name, SoundService, props)
	if s then
		s:Play()
		s.Ended:Once(function() s:Destroy() end)
		task.delay(20, function() if s.Parent and not s.Looped then s:Destroy() end end)
	end
	return s
end

function Sfx.at(name: string, pos: Vector3, props: { [string]: any }?): Sound?
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local s = make(name, a, props)
	if s then
		s.RollOffMaxDistance = 220
		s.RollOffMinDistance = 12
		s:Play()
	end
	task.delay(12, function() a:Destroy() end)
	return s
end

function Sfx.loop(name: string, props: { [string]: any }?): Sound?
	local s = make(name, SoundService, props)
	if s then s.Looped = true; s:Play() end
	return s
end

return Sfx
