--!strict
-- Charged attacks (fists and melee weapons), client side. Input calls begin() when the hit button goes down on a
-- weapon that can charge (the tap itself still hits at once), release() when it comes up. Charging starts after
-- max(Config.Charge.MinHold, weapon cooldown) and fills in Config.Charge.Full seconds. While charging: a power bar
-- under the crosshair, the arms pull back and tremble (VM.setCharge), a click when it is full.
-- The server re-checks the charge against its own clock (Combat.validCharge).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.Shared.Config)
local Grunge = require(script.Parent.Grunge)
local VM = require(script.Parent.Viewmodel)
local Sfx = require(script.Parent.Sfx)

local CH = Config.Charge
local Charge = {}
local lp = Players.LocalPlayer

local active = false
local startAt = 0 -- os.clock() when charging begins (after the minimum hold)
local key: string? = nil -- what is being charged ("fist" or the item id): switching weapon cancels
local full = false
local shown = 0 -- the arms' pull-back, eased toward the level

local gui: ScreenGui? = nil
local root: Frame? = nil
local bar: any = nil

local COLD = Color3.fromRGB(230, 200, 120)
local HOT = Color3.fromRGB(235, 70, 20)

local function build()
	local g = Instance.new("ScreenGui")
	g.Name = "ChargeBar"; g.ResetOnSpawn = false; g.IgnoreGuiInset = true; g.DisplayOrder = 6
	g.Parent = lp:WaitForChild("PlayerGui")
	local r = Instance.new("Frame")
	r.BackgroundTransparency = 1; r.AnchorPoint = Vector2.new(0.5, 0)
	r.Position = UDim2.new(0.5, 0, 0.5, 26); r.Size = UDim2.fromOffset(120, 14); r.Visible = false
	r.Parent = g
	bar = Grunge.bar(r, { size = UDim2.fromScale(1, 1), pos = UDim2.fromScale(0, 0), color = COLD, rot = -1, seed = 61, slices = 16 })
	bar:set(0, 1)
	gui, root = g, r
end

-- the current charge, 0..1
function Charge.level(): number
	if not active then return 0 end
	return math.clamp((os.clock() - startAt) / CH.Full, 0, 1)
end

function Charge.active(): boolean return active end
function Charge.key(): string? return key end

-- start holding: charging begins after `delay` seconds (max(MinHold, weapon cooldown))
function Charge.begin(what: string, delay: number)
	if not gui then build() end
	active = true
	key = what
	full = false
	startAt = os.clock() + math.max(CH.MinHold, delay)
end

function Charge.cancel()
	active = false
	key = nil
end

-- the button came up: returns the charge to throw (0 = it was just a tap, nothing extra to do)
function Charge.release(): number
	local c = Charge.level()
	Charge.cancel()
	return c >= CH.MinRelease and c or 0
end

function Charge.update(dt: number)
	local c = Charge.level()
	shown += (c - shown) * math.min(1, dt * (c > shown and 10 or 18))
	VM.setCharge(shown)
	if c > 0 and not full and c >= 1 then
		full = true
		Sfx.play("Click", { PlaybackSpeed = 0.7, Volume = 1 })
	end
	if root and bar then
		local r = root :: Frame
		r.Visible = c > 0
		if c > 0 then
			bar:set(c, dt)
			-- the bar heats up, and shakes when full
			bar:color(COLD:Lerp(HOT, c))
			r.Position = full and UDim2.new(0.5, math.random(-2, 2), 0.5, 26 + math.random(-1, 1)) or UDim2.new(0.5, 0, 0.5, 26)
		end
	end
end

return Charge
