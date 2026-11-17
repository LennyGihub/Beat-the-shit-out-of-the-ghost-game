-- Client entry: first-person camera, HUD, fists, ghost animation, effects, input, ultimate shop, plane crash.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local Client = script.Parent:WaitForChild("Client")

-- third person in the lobby, first person in a run
local shopOpen = false
local function camMode()
	local fp = lp:GetAttribute("InMatch") == true and not shopOpen and not lp:GetAttribute("Spectating")
	lp.CameraMode = fp and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
	if not fp then lp.CameraMaxZoomDistance = 14; lp.CameraMinZoomDistance = 6 else lp.CameraMinZoomDistance = 0.5 end
end
camMode()
lp:GetAttributeChangedSignal("InMatch"):Connect(camMode)
lp:GetAttributeChangedSignal("Spectating"):Connect(camMode) -- spectating a teammate: third person
workspace.CurrentCamera.FieldOfView = 74
local Remotes = RS:WaitForChild("Remotes")

local Platform = require(Client.Platform)
local Settings = require(Client.Settings)
local SettingsUI = require(Client.SettingsUI)
local HUD = require(Client.HUD)
local VM = require(Client.Viewmodel)
local GA = require(Client.GhostAnim)
local Fx = require(Client.Fx)
local Input = require(Client.Input)
local UltShop = require(Client.UltShopUI)
local QuestUI = require(Client.QuestUI)
local PlaneFx = require(Client.PlaneFx)
local EventFx = require(Client.EventFx)
local Prompts = require(Client.Prompts)
local Hotbar = require(Client.Hotbar)
local MonsterFx = require(Client.MonsterFx)
local RoomPickUI = require(Client.RoomPickUI)
local ThirdPersonItems = require(Client.ThirdPersonItems)
local AdminPanel = require(Client.AdminPanel)
local SawAudio = require(Client.SawAudio)
local LobbyUI = require(Client.LobbyUI)
local ReviveUI = require(Client.ReviveUI)
local Spectate = require(Client.Spectate)
local KeyHints = require(Client.KeyHints)
local CrewAnim = require(Client.CrewAnim)
local Vip = require(Client.Vip)
local CallerUI = require(Client.CallerUI)
local SandboxUI = require(Client.SandboxUI)

Platform.init()
Settings.init()
HUD.init()
VM.init()
GA.init()
Fx.init()
-- settings window (volumes, keybinds): blocks punching while open, its CLOSE button frees the mouse
SettingsUI.init(function(open) Input.setShopOpen(open) end)
Input.init()
PlaneFx.init(Fx)
EventFx.init(Fx)
Prompts.init()
Hotbar.init()
MonsterFx.init(Fx, HUD, require(Client.Sfx))
RoomPickUI.init()
ThirdPersonItems.init()
SawAudio.init()
-- admin panel (admins only): blocks punching while open; the panel frees the mouse itself
AdminPanel.init(function(open) Input.setShopOpen(open) end)
UltShop.init(function(open)
	Input.setShopOpen(open)
	shopOpen = open
	camMode()
	SandboxUI.setShopOpen(open)
end)
SandboxUI.init(function() UltShop.open() end) -- the sandbox's LEAVE and ULTIMATES buttons
ReviveUI.init()
Spectate.init()
KeyHints.init() -- the small controls reminder (H hides it)
CrewAnim.init() -- the Burning Captain's little skeletons run
Vip.init() -- VIP pass: chat tag, the VIP cabin's door
CallerUI.init() -- the Caller's phone call
-- lobby screen: PLAY (create / join lobbies) and SHOP buttons, friend booster
QuestUI.init(function(open)
	Input.setShopOpen(open)
	shopOpen = open
	camMode()
end)
LobbyUI.init(function() UltShop.open() end, function(open) Input.setShopOpen(open) end, function() QuestUI.open() end, QuestUI.claimable, QuestUI.changed)
Input.openPlay = LobbyUI.togglePlay

-- What the server tells EVERYONE about a fight in the house. The sandbox runs in the lobby's own server, so a
-- player standing in the park (not InMatch) gets these too: they are dropped there (no screams, shakes, flashes
-- or fight music for somebody else's training).
local FIGHT = {} :: { [string]: boolean }
for _, k in { "WallSmash", "GhostVanish", "ItemSwing", "Hit", "GoblinUse", "WallSlam", "UltFreeze", "Snap", "ItemBoom", "UltStrike", "UltShock",
	"TrapSnap", "Tracer", "TitanHeal", "TitanEat", "TimeStop", "PlayerHit", "LaserEnd", "GoblinDrop", "GhostWindUp", "GhostScream", "Ultimate",
	"UltFling", "TimeResume", "Throw", "Tased", "SnapWind", "Smash", "ShotgunPump", "ShotgunFire", "ShotgunAim", "ShieldBlock", "RoarWind", "Roar",
	"OnePunch", "LungeWind", "Lunge", "Lift", "LaserWind", "LaserBeam", "HouseOnFire", "GoblinSteal", "GhostSpawn", "GhostRagdoll", "GhostDeath",
	"FurySmash", "FuryArmor", "Enraged", "CounterWind", "ChargedHit", "AmbushStrike", "AbilityWind" } do
	FIGHT[k] = true
end

Remotes.Fx.OnClientEvent:Connect(function(kind: string, ...)
	if FIGHT[kind] and not lp:GetAttribute("InMatch") then return end
	if kind == "OpenUltShop" then
		UltShop.open()
	elseif kind == "UltResult" then
		UltShop.result(...)
	elseif kind == "PlaneCrash" then
		PlaneFx.crash(...)
	elseif kind == "PlaneImpact" then
		PlaneFx.impact(...)
	elseif kind == "VanCrash" or kind == "VanImpact" or kind == "TrainCrash" or kind == "TrainImpact" then
		EventFx.handle(kind, ...)
	elseif kind == "Fling" then
		MonsterFx.release() -- thrown out of a monster's hand
		Fx.handle(kind, ...)
	elseif kind == "ItemSwing" then
		local by = ...
		if by ~= Players.LocalPlayer then ThirdPersonItems.swing(by) end
		local _, id, hit = ...
		if by == Players.LocalPlayer and hit then Hotbar.confirmHit(id) end -- melee hit sound (Hotbar)
		Fx.handle(kind, ...)
	elseif kind == "ReviveOffer" or kind == "Revived" then
		ReviveUI.handle(kind, ...)
		if kind == "Revived" then Fx.handle("Toast", "BACK FROM THE DEAD") end
	elseif kind == "OpenQuests" then
		QuestUI.open()
	elseif kind == "BackFromSpectate" then
		Fx.handle("Toast", "YOU'RE BACK - THE WAVE IS OVER", true)
	elseif kind == "CallerCall" then
		CallerUI.call(...)
	elseif kind == "PartyInvite" then
		LobbyUI.invite(...)
	elseif MonsterFx.handles(kind) then
		MonsterFx.handle(kind, ...)
	else
		Fx.handle(kind, ...)
	end
end)

-- Studio-only test hook: player attribute DebugCam = CFrame puts the camera there (nil = normal camera)
if game:GetService("RunService"):IsStudio() then
	-- held every frame (other tools may reset the camera type)
	game:GetService("RunService"):BindToRenderStep("DebugCam", Enum.RenderPriority.Camera.Value + 1, function()
		local cf = lp:GetAttribute("DebugCam")
		if typeof(cf) == "CFrame" then
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = cf
			-- DebugCamFP = true: first-person shot (the hands show), else a free camera (hands hidden)
			cam.Focus = lp:GetAttribute("DebugCamFP") and cf or cf * CFrame.new(0, 0, -20)
		end
	end)
	lp:GetAttributeChangedSignal("DebugCam"):Connect(function()
		if typeof(lp:GetAttribute("DebugCam")) ~= "CFrame" then workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end
	end)
end
