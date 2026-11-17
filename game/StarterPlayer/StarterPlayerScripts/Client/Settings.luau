--!strict
-- Player settings: sound volume, music volume, particle amount and keyboard keybinds.
-- Loaded from the server (player attribute "Settings", JSON) and saved back through Remotes.SaveSettings.
-- Every sound plays through one of two SoundGroups in SoundService: "SFX" or "Music".
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local Platform = require(script.Parent.Platform)

local Settings = {}
local lp = Players.LocalPlayer
local changed = Instance.new("BindableEvent")
Settings.changed = changed.Event -- (key: "sfx" | "music" | "binds" | "hideKeys" | "fx")

-- PARTICLES (for low-end computers): how many particles the effects make. "medium" is the default.
--   keep  = share of the flying wall chunks / small furniture bits this client shows (the others are removed here only)
--   scale = share of particles in bursts (Settings.fxCount) and in continuous emitters (fire, auras...)
Settings.FX_LEVELS = { "low", "medium", "high" }
local FX = { low = { keep = 0.25, scale = 0.3 }, medium = { keep = 0.6, scale = 0.6 }, high = { keep = 1, scale = 1 } }

-- rebindable keyboard actions, in the order the Settings panel lists them
Settings.ACTIONS = {
	{ id = "Punch", name = "HIT / USE ITEM" },
	{ id = "Block", name = "BLOCK (HOLD)" },
	{ id = "Lift", name = "LIFT / THROW" },
	{ id = "Ultimate", name = "ULTIMATE" },
	{ id = "Sprint", name = "SPRINT" },
	{ id = "Drop", name = "DROP ITEM" },
	{ id = "Use", name = "INTERACT / BUY" },
	{ id = "Settings", name = "SETTINGS" },
	{ id = "SwapUlt", name = "SWAP ULTIMATE" }, -- Double Ultimate pass
	{ id = "Hints", name = "CONTROLS PANEL" }, -- show / hide the small controls reminder (KeyHints)
}
Settings.DEFAULT_BINDS = { Punch = "MouseButton1", Block = "MouseButton2", Lift = "E", Ultimate = "Q", Sprint = "LeftShift", Drop = "X", Use = "F", Settings = "P", SwapUlt = "R", Hints = "H" }
local MUSIC = { FightMusic = true }

-- hideKeys = the small controls reminder (KeyHints) was hidden with H
local state = { sfx = 1, music = 1, binds = table.clone(Settings.DEFAULT_BINDS), hideKeys = false, fx = "medium" }
local dirty = false -- changed here and not loaded over since

local function group(name: string): SoundGroup
	local g = SoundService:FindFirstChild(name)
	if not g then
		local ng = Instance.new("SoundGroup")
		ng.Name = name
		ng.Volume = 1
		ng.Parent = SoundService
		g = ng
	end
	return g :: SoundGroup
end
local sfxGroup, musicGroup = group("SFX"), group("Music")

-- the group a named sound (Shared/Sounds) plays in
function Settings.group(soundName: string): SoundGroup
	return (MUSIC[soundName] or string.sub(soundName, 1, 6) == "Music_") and musicGroup or sfxGroup
end

local function apply()
	sfxGroup.Volume = state.sfx
	musicGroup.Volume = state.music
end

function Settings.get(key: string): any return (state :: any)[key] end

-- the input bound to an action: an Enum.KeyCode or an Enum.UserInputType (mouse buttons)
function Settings.input(action: string): EnumItem
	local name = state.binds[action] or Settings.DEFAULT_BINDS[action]
	if name == "MouseButton1" or name == "MouseButton2" or name == "MouseButton3" then return (Enum.UserInputType :: any)[name] end
	local ok, k = pcall(function() return (Enum.KeyCode :: any)[name] end)
	return ok and k or Enum.KeyCode.Unknown
end

local SHORT = {
	MouseButton1 = "LEFT CLICK", MouseButton2 = "RIGHT CLICK", MouseButton3 = "MIDDLE CLICK", LeftShift = "SHIFT", RightShift = "R-SHIFT",
	LeftControl = "CTRL", RightControl = "R-CTRL", LeftAlt = "ALT", RightAlt = "R-ALT", Space = "SPACE", Tab = "TAB", Return = "ENTER",
	Backspace = "BKSP", CapsLock = "CAPS", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8",
	Nine = "9", Zero = "0",
}
function Settings.keyName(action: string): string
	local name = state.binds[action] or Settings.DEFAULT_BINDS[action] or "?"
	return SHORT[name] or string.upper(name)
end
Platform.keyName = Settings.keyName

-- save shortly after the last change (sliders send many changes)
local saveToken = 0
local function save()
	dirty = true
	saveToken += 1
	local my = saveToken
	task.delay(0.8, function()
		if my ~= saveToken then return end
		RS:WaitForChild("Remotes"):WaitForChild("SaveSettings"):FireServer(state)
	end)
end

function Settings.set(key: string, value: number)
	if key ~= "sfx" and key ~= "music" then return end
	value = math.clamp(math.floor(value * 20 + 0.5) / 20, 0, 1)
	if (state :: any)[key] == value then return end
	;(state :: any)[key] = value
	apply()
	changed:Fire(key)
	save()
end

-- on / off settings ("hideKeys")
function Settings.setFlag(key: string, on: boolean)
	if key ~= "hideKeys" or (state :: any)[key] == on then return end
	;(state :: any)[key] = on
	changed:Fire(key)
	save()
end

-- particle amount: "low" | "medium" | "high"
function Settings.setFx(level: string)
	if not FX[level] or state.fx == level then return end
	state.fx = level
	changed:Fire("fx")
	save()
end
-- how many particles a burst of n should make at the current setting (at least 1)
function Settings.fxCount(n: number): number
	return math.max(1, math.round(n * FX[state.fx].scale))
end
function Settings.fxScale(): number return FX[state.fx].scale end

-- bind an action to a key / mouse button name; an action already on that key gets this action's old key
function Settings.bind(action: string, inputName: string)
	local old = state.binds[action]
	for other, k in state.binds do
		if other ~= action and k == inputName then state.binds[other] = old end
	end
	state.binds[action] = inputName
	changed:Fire("binds")
	save()
end

function Settings.reset()
	state.binds = table.clone(Settings.DEFAULT_BINDS)
	state.sfx, state.music = 1, 1
	state.fx = "medium"
	apply()
	changed:Fire("binds"); changed:Fire("sfx"); changed:Fire("music"); changed:Fire("fx")
	save()
end

local function load()
	if dirty then return end
	local raw = lp:GetAttribute("Settings")
	if type(raw) ~= "string" then return end
	local ok, s = pcall(function() return HttpService:JSONDecode(raw) end)
	if not ok or type(s) ~= "table" then return end
	state.sfx = math.clamp(tonumber(s.sfx) or 1, 0, 1)
	state.music = math.clamp(tonumber(s.music) or 1, 0, 1)
	state.binds = table.clone(Settings.DEFAULT_BINDS)
	if type(s.binds) == "table" then
		for a, k in s.binds do if Settings.DEFAULT_BINDS[a] and type(k) == "string" then state.binds[a] = k end end
	end
	state.hideKeys = s.hideKeys == true
	state.fx = (type(s.fx) == "string" and FX[s.fx]) and s.fx or "medium"
	apply()
	changed:Fire("binds"); changed:Fire("sfx"); changed:Fire("music"); changed:Fire("hideKeys"); changed:Fire("fx")
end

function Settings.init()
	apply()
	load()
	lp:GetAttributeChangedSignal("Settings"):Connect(load)
	-- sounds the server plays (monster roars, fire, wrecks...) go in the SFX group too
	local function claim(d: Instance)
		if d:IsA("Sound") and not d.SoundGroup then d.SoundGroup = sfxGroup end
	end
	for _, d in workspace:GetDescendants() do claim(d) end
	workspace.DescendantAdded:Connect(claim)

	-- PARTICLES: continuous emitters are scaled when they appear (and rescaled when the setting changes; an emitter
	-- a script switched off with Rate = 0 stays off). Attribute FxQ = the scale applied to it.
	local emitters = setmetatable({}, { __mode = "k" }) :: any
	local function scaleEmitter(pe: ParticleEmitter, to: number)
		local was = pe:GetAttribute("FxQ")
		local from = type(was) == "number" and was or 1
		if from == to then return end
		pe.Rate = pe.Rate / from * to
		pe:SetAttribute("FxQ", to)
	end
	local function onEmitter(d: Instance)
		if d:IsA("ParticleEmitter") then
			emitters[d] = true
			-- scripts usually set Rate right after parenting: scale on the next frame
			task.defer(function() if d.Parent then scaleEmitter(d, Settings.fxScale()) end end)
		end
	end
	-- debris: wall chunks (server Ragdoll, folder WallChunks) and the small bits of smashed furniture (folder
	-- Debris) are thinned out on this client only
	local function onDebris(d: Instance)
		if not d:IsA("BasePart") then return end
		local keep = FX[state.fx].keep
		if keep >= 1 then return end
		if d.Parent and d.Parent.Name == "Debris" and d.Size.Magnitude > 2.5 then return end -- big furniture pieces stay
		if math.random() > keep then d:Destroy() end
	end
	local function watchFolder(name: string)
		local function hook(f: Instance)
			if f.Name == name and f:IsA("Folder") then f.ChildAdded:Connect(onDebris) end
		end
		local f = workspace:FindFirstChild(name)
		if f then hook(f) end
		workspace.ChildAdded:Connect(hook)
	end
	for _, d in workspace:GetDescendants() do onEmitter(d) end
	workspace.DescendantAdded:Connect(onEmitter)
	watchFolder("WallChunks")
	watchFolder("Debris")
	changed.Event:Connect(function(k)
		if k ~= "fx" then return end
		local to = Settings.fxScale()
		for pe in emitters do if pe.Parent then scaleEmitter(pe, to) end end
	end)
end

return Settings
