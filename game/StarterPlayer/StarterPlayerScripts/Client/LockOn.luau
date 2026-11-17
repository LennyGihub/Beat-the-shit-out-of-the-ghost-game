--!strict
-- Lock-on for phones and tablets: while it is on, the first-person camera keeps turning to the monster, so the
-- right thumb stays on the buttons instead of dragging the view. The LOCK button (TouchControls) switches it.
--
-- It only steers the LOOK DIRECTION, one step before Roblox's own camera update: the camera script then builds
-- the frame from that direction as usual (head position, pitch limits, the character turning with the view), and
-- the shake and the hands land on top of it like always.
--
-- It lets go, stays switched on and picks the monster up again by itself, while there is nothing fair to aim at
-- (no monster, a knocked-out one, a vanished / hiding / shadow one, decoy doubles in the room) and while something
-- else has the camera (cutscenes, shops, spectating, being dead). Leaving the run switches it off.
--
-- Studio test hook: player attribute DebugLock = true / false switches it (with DebugPlatform = "touch").
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Platform = require(script.Parent.Platform)

local LockOn = {}
local lp = Players.LocalPlayer

local TURN = 12 -- how fast the view swings to the monster (1/s; ~0.2 s to get there)
local MAX_PITCH = math.sin(math.rad(72)) -- never look straight up / down at a monster overhead or underfoot
local MIN_DIST = 1.5 -- standing inside the monster: leave the view alone

local on = false
local tracking = false -- on AND steering the camera right now
local decoys = {} :: { [Instance]: boolean } -- copies of the monster (not the Captain's crew): the lock would give the real one away

local function isDecoy(c: Instance): boolean
	return c.Name == "GhostClone" and c:GetAttribute("Crew") ~= true
end

-- the point to look at (nil = nothing to lock on right now)
local function target(): Vector3?
	local g = workspace:FindFirstChild("Ghost")
	if not g or not g:IsA("Model") then return nil end
	if g:GetAttribute("State") == "Dead" or g:GetAttribute("Vanish") or g:GetAttribute("Hiding") or g:GetAttribute("Shadow") then return nil end
	if next(decoys) ~= nil then return nil end
	local root = g:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then return nil end
	return root.Position
end

local function step(dt: number)
	tracking = false
	if not on then return end
	-- a run in first person only (the shops and spectating are third person), with the touch buttons on screen
	if Platform.mode() ~= "touch" or lp.CameraMode ~= Enum.CameraMode.LockFirstPerson then return end
	local cam = workspace.CurrentCamera
	if not cam or cam.CameraType ~= Enum.CameraType.Custom then return end -- a cutscene has the camera
	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local at = target()
	if not at then return end
	local eye = cam.CFrame.Position
	local to = at - eye
	if to.Magnitude < MIN_DIST then return end
	local dir = to.Unit
	if math.abs(dir.Y) > MAX_PITCH then
		local flat = Vector3.new(dir.X, 0, dir.Z)
		if flat.Magnitude < 1e-3 then return end
		dir = flat.Unit * math.sqrt(1 - MAX_PITCH * MAX_PITCH) + Vector3.new(0, math.sign(dir.Y) * MAX_PITCH, 0)
	end
	local now = CFrame.lookAt(eye, eye + cam.CFrame.LookVector)
	cam.CFrame = now:Lerp(CFrame.lookAt(eye, eye + dir), 1 - math.exp(-dt * TURN))
	tracking = true
end

function LockOn.isOn(): boolean return on end
-- switched on and following the monster this frame (false while it waits for something to aim at)
function LockOn.tracking(): boolean return tracking end

function LockOn.set(v: boolean)
	on = v
	if not v then tracking = false end
end

function LockOn.toggle() LockOn.set(not on) end

function LockOn.init()
	for _, c in workspace:GetChildren() do if isDecoy(c) then decoys[c] = true end end
	workspace.ChildAdded:Connect(function(c) if isDecoy(c) then decoys[c] = true end end)
	workspace.ChildRemoved:Connect(function(c) decoys[c] = nil end)
	lp:GetAttributeChangedSignal("InMatch"):Connect(function()
		if not lp:GetAttribute("InMatch") then LockOn.set(false) end
	end)
	RunService:BindToRenderStep("LockOn", Enum.RenderPriority.Camera.Value - 1, step)
	if RunService:IsStudio() then
		lp:GetAttributeChangedSignal("DebugLock"):Connect(function() LockOn.set(lp:GetAttribute("DebugLock") == true) end)
	end
end

return LockOn
