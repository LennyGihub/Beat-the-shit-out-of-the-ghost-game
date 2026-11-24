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
	-- (in the park the camera zooms out very far: the user, 2026-11-22; third person in a house - a shop open,
	-- spectating - stays close, the walls would be in the way)
	if not fp then
		lp.CameraMaxZoomDistance = lp:GetAttribute("InMatch") == true and 14 or 400
		lp.CameraMinZoomDistance = 6
	else lp.CameraMinZoomDistance = 0.5 end
end
camMode()
lp:GetAttributeChangedSignal("InMatch"):Connect(camMode)
lp:GetAttributeChangedSignal("Spectating"):Connect(camMode) -- spectating a teammate: third person
lp:GetAttributeChangedSignal("InMatch"):Connect(function()
	if not lp:GetAttribute("InMatch") then
		local tr = script.Parent:FindFirstChild("Client") and script.Parent.Client:FindFirstChild("TrainRide")
		if tr then (require(tr) :: any).reset() end
	end
end)
workspace.CurrentCamera.FieldOfView = 74
local Remotes = RS:WaitForChild("Remotes")

local Platform = require(Client.Platform)
local LockOn = require(Client.LockOn)
local Settings = require(Client.Settings)
local Loading = require(game:GetService("ReplicatedFirst"):WaitForChild("Loading"))
game:GetService("TeleportService").TeleportInitFailed:Connect(function(p)
	if p == Players.LocalPlayer then task.spawn(Loading.hide) end
end)
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
local Cursor = require(Client.Cursor) -- the FREE MOUSE key (Left Alt): frees the mouse in first person
local CrewAnim = require(Client.CrewAnim)
local Vip = require(Client.Vip)
local NameTags = require(Client.NameTags)
local TutorialUI = require(Client.TutorialUI)
local Intro = require(Client.Intro)
local LevelUI = require(Client.LevelUI)
local CallerUI = require(Client.CallerUI)
local CallerMarks = require(Client.CallerMarks)
local SandboxUI = require(Client.SandboxUI)
local BestiaryUI = require(Client.BestiaryUI)
local Entrance = require(Client.Entrance)
local TrainRide = require(Client.TrainRide) -- every trip to a map's building goes by train
local StageUI = require(Client.StageUI) -- a cleared building's result screen
local SellerUI = require(Client.SellerUI) -- Doc Mercy's ectoplasm, Mother Moth's potions
local FormCine = require(Client.FormCine) -- the first-person ectoplasm jar / potion
local FormLook = require(Client.FormLook) -- worn forms on every character
local OfflineOpen = require(Client.OfflineOpen) -- jars / potions opening by themselves (bottom middle)
local FormTutorial = require(Client.FormTutorial) -- after the intro: how to get jars and potions
local CampFx = require(Client.CampFx) -- Camp Hollowmere's monsters' moves (rafter drop, hook, flood, torch, straw)
local CarnivalFx = require(Client.CarnivalFx) -- the Moonlight Carnival's monsters' moves (crates, shockwave, curse, whip)
local HarborFx = require(Client.HarborFx) -- Blackwater Harbor's monsters' moves (ink, dive, beam, flash, net, anchor)
local AbbeyFx = require(Client.AbbeyFx) -- the Ashen Abbey's monsters' moves (veil, hymn, hands, coffin, bell, toll)
local MoonFx = require(Client.MoonFx) -- the Black Moon's monsters' moves (breach, jetpack, acid, brood, missiles, overload)
local FxTier = require(Client.FxTier) -- the further the map, the bigger the effects
local WeakFx = require(Client.WeakFx) -- a x5 combo: the monster goes WEAK (lift it, throw it)
local TradeUI = require(Client.TradeUI) -- trading cash, jar forms and potion forms with other players
local CodesUI = require(Client.CodesUI) -- the lobby's CODES window (redeemable codes: Server/Codes)
local ShareUI = require(Client.ShareUI) -- the lobby's INVITE window + SHARE THIS after big moments (Server/Share)
local DailyUI = require(Client.DailyUI) -- the lobby's DAILY window: login streak, welcome jar, free samples (Server/Daily)
local FreeCam = require(Client.FreeCam) -- admins: SHIFT + C free camera
local PatchNotesUI = require(Client.PatchNotesUI) -- WHAT'S NEW: the patch notes (Shared/PatchNotes)

Platform.init()
-- the server is told which controls this player uses: touch players reach further, lift from far and face a weaker
-- monster (Server/Mobile)
do
	local remote = Remotes:WaitForChild("Platform") :: RemoteEvent
	local function report() remote:FireServer(Platform.mode()) end
	Platform.changed:Connect(report)
	report()
end
LockOn.init() -- phones: the LOCK button keeps the view on the monster
Settings.init()
require(Client.Translate).init() -- the player's language for the texts built with numbers (Client/Translate)
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
Cursor.init()
CrewAnim.init() -- the Burning Captain's little skeletons run
Vip.init() -- chat tags: DEV (staff) and VIP
NameTags.init() -- the lobby's name tags (name plate + DEV / VIP titles, level and its title)
LevelUI.init() -- your own level in the lobby's corner
CallerUI.init() -- the Caller's phone call
CallerMarks.init() -- his ringing phone (outline + arrow) and the outline of the room he sits in
require(Client.WorldSpin).init() -- the lighthouse's turning beams (and anything else with a Spin attribute)
TrainRide.init(Fx, HUD)
SellerUI.init()
FormCine.init(Fx, HUD)
FormLook.init(function() return FormCine.busy() end) -- (your own look hides during the jar / potion cinematic)
OfflineOpen.init(function() return FormCine.busy() end)
FormTutorial.init(SellerUI, FormCine, Intro, LobbyUI)
CampFx.init(Fx)
WeakFx.init(Fx, HUD)
CarnivalFx.init(Fx)
HarborFx.init(Fx, HUD)
AbbeyFx.init(Fx, HUD)
MoonFx.init(Fx, HUD)
FxTier.init(Fx, HUD)
-- lobby screen: PLAY (create / join lobbies) and SHOP buttons, friend booster
QuestUI.init(function(open)
	Input.setShopOpen(open)
	shopOpen = open
	camMode()
end)
-- long-term goals: the bestiary (monsters beaten) and the badges
BestiaryUI.init(function(open)
	Input.setShopOpen(open)
	shopOpen = open
	camMode()
end)
Entrance.init(Fx, HUD) -- each monster's entrance cinematic
LobbyUI.init(function() UltShop.open() end, function(open) Input.setShopOpen(open) end, function() QuestUI.open() end, QuestUI.claimable, QuestUI.changed,
	function() BestiaryUI.open() end, function() TradeUI.openPicker() end, function() CodesUI.open() end, function() ShareUI.open() end)
TradeUI.init(function(open) Input.setShopOpen(open) end)
CodesUI.init(function(open) Input.setShopOpen(open) end)
ShareUI.init(function(open) Input.setShopOpen(open) end)
-- the login streak / welcome jar / free samples window (the lobby's DAILY bar; opens by itself when a reward waits)
DailyUI.init(function(open) Input.setShopOpen(open) end, function() return FormCine.busy() end)
-- an EPIC+ form's reveal is a moment worth sharing (Client/ShareUI)
FormCine.onReveal = function(fm: any)
	if type(fm) == "table" and (tonumber(fm.rarity) or 0) >= 4 then ShareUI.moment(tostring(fm.name) .. "!") end
end
FreeCam.init(function(off) Input.setShopOpen(off) end)
PatchNotesUI.init(function(open) Input.setShopOpen(open) end, function()
	return FormCine.busy() or Intro.running() or Loading.isShown() or FreeCam.isOn()
end)
Input.openPlay = LobbyUI.togglePlay
Intro.init(Fx, HUD) -- the new player's intro (the TV, the Woman, the frozen lessons, the way out)
TutorialUI.init() -- starts it on the first join; HOW TO PLAY in the lobby

-- What the server tells EVERYONE about a fight in the house. The sandbox runs in the lobby's own server, so a
-- player standing in the park (not InMatch) gets these too: they are dropped there (no screams, shakes, flashes
-- or fight music for somebody else's training).
local FIGHT = {} :: { [string]: boolean }
for _, k in { "ForceWind", "ForceGrab", "ForceHold", "ForcePush", "ForceMiss", "SaberCut", "SaberSwing", "WallSmash", "GhostVanish", "ItemSwing", "Hit", "GoblinUse", "WallSlam", "UltFreeze", "Snap", "ItemBoom", "UltStrike", "UltShock",
	"TrapSnap", "Tracer", "TitanHeal", "TitanEat", "TimeStop", "PlayerHit", "LaserEnd", "GoblinDrop", "GhostWindUp", "GhostScream", "Ultimate",
	"UltFling", "TimeResume", "Throw", "Tased", "SnapWind", "Smash", "ShotgunPump", "ShotgunFire", "ShotgunAim", "ShieldBlock", "RoarWind", "Roar",
	"OnePunch", "LungeWind", "Lunge", "Lift", "LaserWind", "LaserBeam", "HouseOnFire", "GoblinSteal", "GhostSpawn", "GhostRagdoll", "GhostDeath",
	"FurySmash", "FuryArmor", "Enraged", "CounterWind", "ChargedHit", "AmbushStrike", "AbilityWind", "Entrance", "DemonSummon", "RatDashWarn", "RatDash", "RatDizzy", "RatDig", "RatTrail", "RatWarn", "RatErupt" } do
	FIGHT[k] = true
end

for _, k in CampFx.KINDS do FIGHT[k] = true end -- (Camp Hollowmere's monsters' moves: fight-only too)
for _, k in WeakFx.KINDS do FIGHT[k] = true end
for _, k in CarnivalFx.KINDS do FIGHT[k] = true end
for _, k in HarborFx.KINDS do FIGHT[k] = true end
for _, k in AbbeyFx.KINDS do FIGHT[k] = true end
for _, k in MoonFx.KINDS do FIGHT[k] = true end

local codeQueue, codeTurn = 0, 0 -- (a code's forms: their cinematics play one after the other)
Remotes.Fx.OnClientEvent:Connect(function(kind: string, ...)
	if FIGHT[kind] and not lp:GetAttribute("InMatch") then return end
	if kind == "Released" then CampFx.released() end -- (the Lake Witch's pull stops too)
	if kind == "GhostDeath" then ShareUI.ghostDeath() end -- (a boss knocked out: SHARE THIS)
	if kind == "Teleporting" then
		Loading.teleport(...) -- the loading screen (ReplicatedFirst/Loading)
	elseif kind == "TeleportFailed" then
		task.spawn(Loading.hide)
	elseif kind == "OpenUltShop" then
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
	elseif kind == "OpenBestiary" then
		BestiaryUI.open()
	elseif kind == "BadgeUnlocked" then
		BestiaryUI.unlocked(...)
	elseif kind == "BestiaryNew" then
		BestiaryUI.discovered(...)
	elseif kind == "Entrance" then
		Entrance.play(...)
	elseif kind == "BackFromSpectate" then
		Fx.handle("Toast", "YOU'RE BACK - THE WAVE IS OVER", true)
	elseif kind == "CallerCall" then
		CallerUI.call(...)
	elseif kind == "CallerRoom" then
		CallerMarks.room(...)
	elseif kind == "CallerRoomOff" then
		CallerMarks.roomOff()
	elseif kind == "PartyInvite" then
		LobbyUI.invite(...)
	elseif kind == "OpenPlay" then
		LobbyUI.openPlay()
	elseif kind == "TrainDepart" then
		StageUI.close()
		task.spawn(TrainRide.depart, ...)
	elseif kind == "TrainArrive" then
		StageUI.close()
		task.spawn(TrainRide.arrive, ...)
	elseif kind == "StageClear" then
		StageUI.show(...)
		local info = ...
		local st = type(info) == "table" and require(RS.Shared.Campaign).stage(info.stage)
		if st then ShareUI.moment(st.name .. " CLEARED") end
	elseif kind == "ShareReward" then
		ShareUI.reward(...)
	elseif kind == "OpenSeller" then
		if not FormCine.busy() then SellerUI.open(...) end
	elseif kind == "FormResult" then
		SellerUI.result(...)
	elseif kind == "FormRolled" then
		-- the vial was bought: the first-person cinematic, then the seller's panel again
		local args = table.pack(...)
		local k = SellerUI.rolled()
		FormCine.onDone = function() if k and not lp:GetAttribute("InMatch") then SellerUI.open(k) end end
		task.spawn(FormCine.play, args[1], args[2], args[3], args[4], args[5], args[6])
	elseif kind == "CodeResult" then
		CodesUI.result(...)
	elseif kind == "CodeReward" or kind == "DailyReward" then
		-- a code gave a form: the jar / potion cinematic (no seller, no vial), then WEAR IT / KEEP. A code giving two
		-- forms: the second one plays when the first is over (in the order they came).
		-- DailyReward (Server/Daily: a streak day, the welcome jar): the same, with its jar / potion (kind, vialId, ...)
		local args = table.pack(...)
		if kind == "CodeReward" then args = table.pack(args[1], "", args[2], args[3], args[4], args[5]) end
		CodesUI.close()
		SellerUI.close()
		DailyUI.close()
		codeQueue += 1
		local my = codeQueue
		task.spawn(function()
			while codeTurn < my - 1 or FormCine.busy() do task.wait(0.2) end
			task.wait(codeTurn > 0 and 0.4 or 0)
			FormCine.onDone = nil
			codeTurn = my
			FormCine.play(args[1], args[2], args[3], args[4], args[5], args[6])
		end)
	elseif kind == "FormMulti" then
		SellerUI.multi(...)
	elseif kind == "OfflineDone" then
		OfflineOpen.done(...)
	elseif kind == "StageRepick" then
		StageUI.repick()
	elseif kind == "FormEquipped" then
		local Forms = require(RS.Shared.Forms)
		local fm = Forms.byId[select(2, ...)]
		if fm then Fx.handle("Toast", "NOW WEARING " .. fm.name, true) end
	elseif WeakFx.handles(kind) then
		WeakFx.handle(kind, ...)
	elseif CampFx.handles(kind) then
		CampFx.handle(kind, ...)
	elseif CarnivalFx.handles(kind) then
		CarnivalFx.handle(kind, ...)
	elseif HarborFx.handles(kind) then
		HarborFx.handle(kind, ...)
	elseif AbbeyFx.handles(kind) then
		AbbeyFx.handle(kind, ...)
	elseif MoonFx.handles(kind) then
		MoonFx.handle(kind, ...)
	elseif MonsterFx.handles(kind) then
		MonsterFx.handle(kind, ...)
	else
		Fx.handle(kind, ...)
	end
	-- the further the campaign map, the bigger the effects (Client/FxTier adds its layer on top)
	local ok, err = pcall(FxTier.on, kind, ...)
	if not ok then warn("[FxTier] " .. tostring(err)) end
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
