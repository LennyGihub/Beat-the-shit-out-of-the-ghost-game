-- Run hotbar: 5 item slots (keys 1-5, same key again = fists, X = drop), item use + its first-person feel.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Items = require(RS.Shared.Items)
local Grunge = require(script.Parent.Grunge)
local VM = require(script.Parent.Viewmodel)
local Sfx = require(script.Parent.Sfx)
local Remotes = RS:WaitForChild("Remotes")

local Hotbar = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local SLOTS = 5
local slots = {} :: { { id: string, uses: number }? }
local sel = 0
local frames = {} :: { any }
local root: Frame
local lastUse = {} :: { [string]: number }
local spraying = false
local sprayEmitter: ParticleEmitter? = nil
local sprayAtt: Attachment? = nil

local function parse()
	slots = {}
	local i = 0
	for chunk in string.gmatch((lp:GetAttribute("Inv") or "") .. ",", "([^,]*),") do
		i += 1
		if i > SLOTS then break end
		local id, uses = string.match(chunk, "^([^:]+):(%-?%d+)$")
		slots[i] = id and { id = id, uses = tonumber(uses) :: number } or nil
	end
	sel = lp:GetAttribute("Sel") or 0
end

function Hotbar.current(): any
	local s = slots[sel]
	return s and Items.byId[s.id] or nil
end

local function refresh()
	parse()
	local any = false
	for n = 1, SLOTS do
		local f = frames[n]
		local s = slots[n]
		local it = s and Items.byId[s.id]
		if it then
			any = true
			local rar = Items.rarity[it.rarity]
			f.name.Text = string.upper(it.name)
			f.uses.Text = it.kind == "spray" and (math.ceil(s.uses / 10) .. "s") or ("x" .. s.uses)
			f.edge.BackgroundColor3 = rar.color
			f.box.BackgroundTransparency = 0.15
		else
			f.name.Text = ""; f.uses.Text = ""
			f.edge.BackgroundColor3 = Color3.fromRGB(60, 54, 50)
			f.box.BackgroundTransparency = 0.5
		end
		local on = n == sel and it ~= nil
		f.box.Rotation = on and -3 or (n % 2 == 0 and 1 or -1)
		f.mark.Visible = on
		f.scale.Scale = on and 1.12 or 1
	end
	root.Visible = any and lp:GetAttribute("InMatch") == true
	VM.setItem(Hotbar.current())
end

function Hotbar.select(n: number)
	if n == sel or not slots[n] then n = 0 end
	Remotes.Select:FireServer(n)
	Sfx.play("Click", { Volume = 0.3 })
end

-- left click / hold with an item in hand. Returns true if an item handled it.
function Hotbar.primary(): boolean
	local it = Hotbar.current()
	if not it or not lp:GetAttribute("InMatch") then return false end
	if it.kind == "spray" then return true end -- handled while held (see update)
	local now = os.clock()
	local cd = it.cd or 0.6
	if now - (lastUse[it.id] or 0) < cd then return true end
	lastUse[it.id] = now
	if it.kind == "melee" then
		VM.swing(it.cd < 0.15)
		Sfx.play("Whoosh", { PlaybackSpeed = 0.7 + math.random() * 0.3 })
	elseif it.kind == "gun" then
		VM.recoil(it.knock > 50 and 1.6 or 1)
	elseif it.kind == "throw" or it.kind == "trap" then
		VM.toss()
		Sfx.play("Whoosh", { PlaybackSpeed = 0.6 })
	elseif it.kind == "use" then
		VM.toss()
	end
	Remotes.Use:FireServer(sel, cam.CFrame.LookVector)
	return true
end

local function setSpray(on: boolean, it)
	spraying = on
	if on and it then
		if not sprayAtt then
			sprayAtt = Instance.new("Attachment"); sprayAtt.Parent = workspace.Terrain
			local pe = Instance.new("ParticleEmitter")
			pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
			pe.Speed = NumberRange.new(30, 45); pe.SpreadAngle = Vector2.new(10, 10); pe.Lifetime = NumberRange.new(0.35, 0.55)
			pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 3) })
			pe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
			pe.Rate = 70; pe.LightEmission = 0.4; pe.Parent = sprayAtt
			sprayEmitter = pe
		end
		local pe = sprayEmitter :: ParticleEmitter
		pe.Color = ColorSequence.new(it.particle or Color3.new(1, 1, 1))
		pe.LightEmission = it.id == "Flamethrower" and 1 or 0.3
		pe.Enabled = true
	elseif sprayEmitter then
		sprayEmitter.Enabled = false
	end
end

local function update()
	local it = Hotbar.current()
	local holding = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Hotbar.touchHold == true
	if it and it.kind == "spray" and holding and lp:GetAttribute("InMatch") and UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then
		setSpray(true, it)
		local tip = VM.itemTip()
		if sprayAtt and tip then sprayAtt.WorldCFrame = CFrame.lookAt(tip, tip + cam.CFrame.LookVector) * CFrame.Angles(-math.pi / 2, 0, 0) end
		local now = os.clock()
		if now - (lastUse[it.id] or 0) >= 0.1 then
			lastUse[it.id] = now
			Remotes.Use:FireServer(sel, cam.CFrame.LookVector)
		end
	elseif spraying then
		setSpray(false)
	end
end

function Hotbar.init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Hotbar"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
	gui.Parent = lp:WaitForChild("PlayerGui")
	root = Grunge.frame(gui, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.fromScale(0.36, 0.1), Visible = false })
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 5.6; ar.Parent = root
	local list = Instance.new("UIListLayout"); list.FillDirection = Enum.FillDirection.Horizontal; list.Padding = UDim.new(0.012, 0)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center; list.Parent = root
	for n = 1, SLOTS do
		local holder = Grunge.frame(root, { Size = UDim2.fromScale(0.19, 1), LayoutOrder = n })
		local box = Grunge.frame(holder, { BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(24, 19, 16), Size = UDim2.fromScale(1, 1) })
		local stroke = Instance.new("UIStroke"); stroke.Color = Grunge.INK; stroke.Thickness = 3; stroke.Parent = box
		local edge = Grunge.frame(box, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(60, 54, 50), Size = UDim2.new(1, 0, 0, 5), Position = UDim2.new(0, 0, 1, -5) })
		local num = Grunge.text(box, { Text = tostring(n), Position = UDim2.fromScale(0.05, 0.02), Size = UDim2.fromScale(0.3, 0.3), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(200, 190, 170) })
		local name = Grunge.text(box, { Text = "", Font = Grunge.FONT, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.92, 0.36) })
		local uses = Grunge.text(box, { Text = "", Font = Grunge.TYPE, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(0.95, 0, 0.92, -4), Size = UDim2.fromScale(0.5, 0.26), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 220, 110) })
		local mark = Grunge.frame(box, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(190, 25, 20), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -4), Size = UDim2.new(0.6, 0, 0, 6), Rotation = -3, Visible = false })
		local scale = Instance.new("UIScale"); scale.Parent = holder
		local _ = num
		frames[n] = { box = box, edge = edge, name = name, uses = uses, mark = mark, scale = scale }
	end
	Grunge.text(root, { Text = "[1-5] SWAP   [X] DROP", Font = Grunge.TYPE, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 2), Size = UDim2.fromScale(0.6, 0.22), TextColor3 = Color3.fromRGB(170, 160, 145) })
	lp:GetAttributeChangedSignal("Inv"):Connect(refresh)
	lp:GetAttributeChangedSignal("Sel"):Connect(refresh)
	lp:GetAttributeChangedSignal("InMatch"):Connect(refresh)
	refresh()
	local keys = { [Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5 }
	UIS.InputBegan:Connect(function(input, processed)
		if processed or not lp:GetAttribute("InMatch") then return end
		local n = keys[input.KeyCode]
		if n then Hotbar.select(n)
		elseif input.KeyCode == Enum.KeyCode.X and sel > 0 then Remotes.Drop:FireServer(sel) end
	end)
	RunService.Heartbeat:Connect(update)
end

return Hotbar
