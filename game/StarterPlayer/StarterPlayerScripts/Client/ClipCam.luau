--!strict
-- CLIP CAMERA + BOT (2026-11-24, TikTok week 1; STUDIO ONLY). The clip maker (roblox-mcp-bridge/clipper.js, run on
-- the PC next to the bridge) films the game with it. Player attribute ClipShot = JSON (nil / "" = off: the camera,
-- UI, music and body come back):
--   { cam = "game" | "fps" | "orbit" | "follow", subject = "monster" | "player", radius, height, lookY, speed, fov,
--     bot = "none" | "fight" | "ult" | "strut", hideUI = true, music = false }
--   cam game  : the game keeps its camera (an entrance cinematic, an ultimate's own shots)
--       fps   : first person aimed by script (at the monster, or at what the bot reaches for); the fists show
--       orbit : turns round the subject (radius, height, speed in degrees a second), looking lookY above its feet
--       follow: behind and above the player, looking at the monster
--   bot  fight: walks up, hit combos, charged hits, throws furniture, lifts + throws the WEAK monster, the ultimate
--               when its bar is full - all through the game's own controls (Input.act), so the fists animate
--        ult  : hits until the bar is full, then the ultimate (the sandbox refills it)
--        strut: walks round in a circle and jumps (a giant form copies every move)
-- ClipCalib = true covers the whole game picture in magenta until it goes false: the editor finds the picture inside
-- the recorded Studio window by it, and the clip starts right after it.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Config = require(RS.Shared.Config)

local ClipCam = {}
local lp = Players.LocalPlayer
local rng = Random.new()

type Shot = { cam: string?, subject: string?, radius: number?, height: number?, lookY: number?, speed: number?, fov: number?,
	bot: string?, hideUI: boolean?, music: boolean? }

local shot: Shot? = nil
local token = 0
local aimAt: Vector3? = nil -- what the fps camera looks at (nil = the monster)
local angle = 0
local camCF: CFrame? = nil
local hidden = {} :: { [ScreenGui]: boolean }
local hiddenCore = false
local musicWas: number? = nil
local autoRotate: boolean? = nil
-- ScreenGuis that stay on (cinematics, the calibration frame)
local KEEP = { CineBars = true, EntranceCine = true, ClipCalib = true, TrainCard = true, TrainBlack = true, Jumpscare = true }

local function hrpOf(m: Model?): BasePart?
	if not m then return nil end
	return (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart) :: BasePart?
end
local function monster(): Model?
	local g = workspace:FindFirstChild("Ghost")
	return (g and g:IsA("Model")) and g or nil
end
local function me(): (Humanoid?, BasePart?)
	local ch = lp.Character
	if not ch then return nil, nil end
	return ch:FindFirstChildOfClass("Humanoid"), ch:FindFirstChild("HumanoidRootPart") :: BasePart?
end
local function act(a: string)
	local ok, Input = pcall(function() return require(script.Parent.Input) :: any end)
	if ok and Input.act then Input.act(a) end
end

-- UI ---------------------------------------------------------------------------------------------------------------
local function hideUI(on: boolean)
	local pg = lp:FindFirstChildOfClass("PlayerGui")
	if on then
		if pg then
			for _, g in pg:GetChildren() do
				if g:IsA("ScreenGui") and g.Enabled and not KEEP[g.Name] then hidden[g] = true; g.Enabled = false end
			end
		end
		if not hiddenCore then
			hiddenCore = true
			pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
			pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
		end
	else
		for g in hidden do if g.Parent then g.Enabled = true end end
		table.clear(hidden)
		if hiddenCore then
			hiddenCore = false
			pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
			pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
			pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false) end) -- (the game draws its own)
		end
	end
end

local function setMusic(on: boolean)
	local g = SoundService:FindFirstChild("Music")
	if not g or not g:IsA("SoundGroup") then return end
	if not on then
		if musicWas == nil then musicWas = g.Volume end
		g.Volume = 0
	elseif musicWas ~= nil then
		g.Volume = musicWas
		musicWas = nil
	end
end

-- the calibration frame
local calib: ScreenGui? = nil
local function setCalib(on: boolean)
	if on and not calib then
		local g = Instance.new("ScreenGui")
		g.Name = "ClipCalib"; g.IgnoreGuiInset = true; g.DisplayOrder = 10000; g.ResetOnSpawn = false
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0; f.BackgroundColor3 = Color3.fromRGB(255, 0, 255); f.Size = UDim2.fromScale(1, 1)
		f.Parent = g
		g.Parent = lp:WaitForChild("PlayerGui")
		calib = g
	elseif not on and calib then
		calib:Destroy()
		calib = nil
	end
end

-- CAMERA -------------------------------------------------------------------------------------------------------------
local function setBody(visible: boolean)
	local ch = lp.Character
	if ch then
		for _, d in ch:GetDescendants() do
			if d:IsA("BasePart") then d.LocalTransparencyModifier = visible and 0 or 1 end
		end
	end
end
local function setViewmodel(visible: boolean)
	local vm = workspace.CurrentCamera:FindFirstChild("Viewmodel")
	if not vm or visible then return end -- (shown: Client/Viewmodel draws it as usual)
	for _, d in vm:GetDescendants() do
		if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
	end
end

-- late in the frame: UI hidden, the body shown / hidden, the fists brought in toward the middle (fps)
local function lateStep()
	local s = shot
	if not s then return end
	local mode = s.cam or "game"
	if mode == "fps" then
		setBody(false)
		-- the vertical 9:16 crop keeps only the middle quarter of a wide picture: the fists (Client/Viewmodel puts them
		-- at about 36% / 64% of the width) are drawn closer to the middle so they stay in the clip
		local cam = workspace.CurrentCamera
		local vm = cam:FindFirstChild("Viewmodel")
		if vm then
			local cf = cam.CFrame
			for _, d in vm:GetDescendants() do
				if d:IsA("BasePart") then
					local rel = cf:ToObjectSpace(d.CFrame)
					d.CFrame = cf * (CFrame.new(rel.X * 0.36, rel.Y * 0.8 - 0.06, rel.Z) * rel.Rotation)
				end
			end
		end
	elseif mode == "orbit" or mode == "follow" then
		setBody(true); setViewmodel(false)
	end
	if s.hideUI ~= false then
		-- new ScreenGuis made during the shot (a toast, a banner) are hidden too, except the cinematic ones
		local pg = lp:FindFirstChildOfClass("PlayerGui")
		if pg then
			for _, g in pg:GetChildren() do
				if g:IsA("ScreenGui") and g.Enabled and not KEEP[g.Name] and g.Name ~= "WindowDim" then hidden[g] = true; g.Enabled = false end
			end
		end
	end
end

-- right after Roblox's own camera, before Client/Viewmodel (it reads the camera to place the fists, and shows them
-- only when the camera's focus is at the camera: first person)
local function step(dt: number)
	local s = shot
	if not s then return end
	local mode = s.cam or "game"
	if mode == "game" then return end
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = s.fov or (mode == "fps" and 80 or 60)
	local hum, hrp = me()
	local g = monster()
	local gr = hrpOf(g)
	local want: CFrame? = nil
	if mode == "fps" and hrp then
		local ch = lp.Character :: Model
		local head = ch:FindFirstChild("Head") :: BasePart?
		local eye = (head and head.Position or hrp.Position + Vector3.new(0, 1.5, 0)) + Vector3.new(0, 0.15, 0)
		local target = aimAt or (gr and gr.Position + Vector3.new(0, 0.8, 0)) or (eye + hrp.CFrame.LookVector * 10)
		want = CFrame.lookAt(eye, target)
		-- the body faces where the camera looks (the server reads the punch direction from it too)
		local flat = Vector3.new(target.X, hrp.Position.Y, target.Z)
		if (flat - hrp.Position).Magnitude > 0.5 then hrp.CFrame = CFrame.lookAt(hrp.Position, flat) end
	elseif mode == "orbit" then
		local subj = (s.subject == "monster" and gr) or hrp
		if subj then
			angle += math.rad(s.speed or 14) * dt
			local r, h = s.radius or 16, s.height or 5
			local c = subj.Position
			want = CFrame.lookAt(c + Vector3.new(math.cos(angle) * r, h, math.sin(angle) * r), c + Vector3.new(0, s.lookY or 2, 0))
		end
	elseif mode == "follow" and hrp then
		local target = gr and gr.Position or (hrp.Position + hrp.CFrame.LookVector * 10)
		local flat = Vector3.new(target.X - hrp.Position.X, 0, target.Z - hrp.Position.Z)
		local dir = flat.Magnitude > 0.1 and flat.Unit or hrp.CFrame.LookVector
		want = CFrame.lookAt(hrp.Position - dir * (s.radius or 9) + Vector3.new(0, s.height or 4, 0), target + Vector3.new(0, 1, 0))
	end
	if want then
		-- smooth, like a hand-held camera operator (fps turns faster)
		local k = 1 - math.exp(-dt * (mode == "fps" and 9 or 4))
		camCF = camCF and (camCF :: CFrame):Lerp(want, k) or want
		cam.CFrame = camCF :: CFrame
		-- (Client/Viewmodel shows the fists only when the focus is at the camera: first person)
		cam.Focus = mode == "fps" and cam.CFrame or CFrame.new((want :: CFrame).Position + (want :: CFrame).LookVector * 12)
	end
	local _ = hum
end

-- BOT ----------------------------------------------------------------------------------------------------------------
local function alive(t: number): boolean return token == t and shot ~= nil end
local function tap() act("down"); task.wait(0.05); act("up") end
local function brutFull(): boolean return (tonumber(lp:GetAttribute("Brutality")) or 0) >= Config.Brutality.Max and not lp:GetAttribute("UltActive") end

-- walk to a point until close (or out of time)
local function walkTo(t: number, p: Vector3, near: number, maxT: number)
	local hum, hrp = me()
	if not hum or not hrp then return end
	local t0 = os.clock()
	while alive(t) and os.clock() - t0 < maxT do
		local _, h = me()
		if not h then return end
		local d = Vector3.new(p.X - h.Position.X, 0, p.Z - h.Position.Z)
		if d.Magnitude <= near then break end
		hum:MoveTo(h.Position + d.Unit * math.min(d.Magnitude, 8))
		task.wait(0.12)
	end
	local _, h2 = me()
	if h2 then hum:MoveTo(h2.Position) end
end

local function nearestFurniture(from: Vector3, maxD: number): Model?
	local m = workspace:FindFirstChild("Mansion")
	local f = m and m:FindFirstChild("Furniture")
	if not f then return nil end
	local best, bd = nil, maxD
	for _, c in f:GetChildren() do
		if c:IsA("Model") then
			local ok, pivot = pcall(function() return c:GetPivot().Position end)
			local d = ok and (pivot - from).Magnitude or math.huge
			if d < bd then best, bd = c, d end
		end
	end
	return best
end

local function botFight(t: number, ultOnly: boolean)
	while alive(t) do
		local g = monster()
		local gr = hrpOf(g)
		local hum, hrp = me()
		local state = g and g:GetAttribute("State")
		if not g or not gr or not hum or not hrp or state == "Spawn" or state == "Dead" then task.wait(0.2); continue end
		aimAt = nil
		local d = Vector3.new(gr.Position.X - hrp.Position.X, 0, gr.Position.Z - hrp.Position.Z)
		if d.Magnitude > 6.5 then
			hum:MoveTo(gr.Position - d.Unit * 4.5)
			task.wait(0.15)
			continue
		end
		hum:MoveTo(hrp.Position)
		local r = rng:NextNumber()
		if brutFull() and (ultOnly or r < 0.6) then
			act("ult")
			task.wait(3.5)
		elseif state == "Weak" and not ultOnly then
			-- lift the weak monster over the head, walk a few steps, throw it
			act("grab")
			task.wait(1.1)
			tap()
			task.wait(1.6)
		elseif ultOnly or r < 0.55 then
			for _ = 1, 5 do
				if not alive(t) then break end
				tap()
				task.wait(0.36)
			end
			task.wait(0.25)
		elseif r < 0.8 then
			act("down"); task.wait(1.1); act("up")
			task.wait(0.6)
		else
			-- throw the nearest furniture at it
			local f = nearestFurniture(hrp.Position, 28)
			if f then
				walkTo(t, f:GetPivot().Position, 5.5, 2.5)
				aimAt = f:GetPivot().Position
				task.wait(0.35)
				act("grab")
				task.wait(0.7)
				aimAt = nil
				local g2 = hrpOf(monster())
				if g2 then walkTo(t, g2.Position, 11, 2) end
				task.wait(0.3)
				tap()
				task.wait(1.2)
			else
				tap(); task.wait(0.4)
			end
		end
	end
	aimAt = nil
end

local function botStrut(t: number)
	local hum, hrp = me()
	if not hum or not hrp then return end
	local c = hrp.Position
	local a = 0
	local lastJump = os.clock()
	while alive(t) do
		a += 0.5
		hum:MoveTo(c + Vector3.new(math.cos(a) * 9, 0, math.sin(a) * 9))
		if os.clock() - lastJump > 2.6 then hum.Jump = true; lastJump = os.clock() end
		task.wait(0.35)
	end
	local _, h = me()
	if h then hum:MoveTo(h.Position) end
end

-- ON / OFF -----------------------------------------------------------------------------------------------------------
local function stop()
	token += 1
	shot = nil
	aimAt = nil
	camCF = nil
	RunService:UnbindFromRenderStep("ClipCam")
	RunService:UnbindFromRenderStep("ClipCamLate")
	hideUI(false)
	setMusic(true)
	setBody(true)
	local hum = me()
	if hum and autoRotate ~= nil then hum.AutoRotate = autoRotate end
	autoRotate = nil
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end

local function start(s: Shot)
	stop()
	token += 1
	local t = token
	shot = s
	angle = rng:NextNumber(0, math.pi * 2)
	if s.hideUI ~= false then hideUI(true) end
	if s.music == false or s.music == nil then setMusic(false) end
	local hum = me()
	if hum and s.cam == "fps" then autoRotate = hum.AutoRotate; hum.AutoRotate = false end
	RunService:BindToRenderStep("ClipCam", Enum.RenderPriority.Camera.Value + 1, step)
	RunService:BindToRenderStep("ClipCamLate", Enum.RenderPriority.Last.Value + 10, lateStep)
	if s.bot == "fight" then task.spawn(botFight, t, false)
	elseif s.bot == "ult" then task.spawn(botFight, t, true)
	elseif s.bot == "strut" then task.spawn(botStrut, t) end
end

function ClipCam.init()
	if not RunService:IsStudio() then return end
	lp:GetAttributeChangedSignal("ClipShot"):Connect(function()
		local raw = lp:GetAttribute("ClipShot")
		if type(raw) ~= "string" or raw == "" then stop(); return end
		local ok, s = pcall(function() return HttpService:JSONDecode(raw) end)
		if ok and type(s) == "table" then start(s :: Shot) else stop() end
	end)
	lp:GetAttributeChangedSignal("ClipCalib"):Connect(function() setCalib(lp:GetAttribute("ClipCalib") == true) end)
end

return ClipCam
