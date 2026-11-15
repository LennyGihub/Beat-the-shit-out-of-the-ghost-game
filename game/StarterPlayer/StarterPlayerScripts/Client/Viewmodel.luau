-- First-person fists: guard pose, alternating jabs, hooks on high combos, carry pose, ultimate glow.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local VM = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local model: Model
local arms = {} :: { [string]: { fist: BasePart, arm: BasePart, sleeve: BasePart, brass: BasePart } }
local punches = {} :: { { side: string, t0: number, kind: string, dur: number } }
local nextSide = "R"
local lastCamCF = cam.CFrame
local sway = Vector2.zero
local bobT = 0
local carryAlpha = 0
local shakeOff = CFrame.new()
local skinColor = Color3.fromRGB(120, 88, 70)

local function mk(name: string, size: Vector3, color: Color3, mat: Enum.Material?): BasePart
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color; p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	p.Parent = model
	return p
end

function VM.init()
	model = Instance.new("Model")
	model.Name = "Viewmodel"
	model.Parent = cam
	local skin = Color3.fromRGB(120, 88, 70)
	for _, side in { "L", "R" } do
		arms[side] = {
			fist = mk(side .. "Fist", Vector3.new(0.44, 0.42, 0.5), skin),
			arm = mk(side .. "Arm", Vector3.new(0.34, 0.34, 1.7), skin),
			sleeve = mk(side .. "Sleeve", Vector3.new(0.46, 0.46, 1.2), Color3.fromRGB(46, 42, 40), Enum.Material.Fabric),
			brass = mk(side .. "Brass", Vector3.new(0.48, 0.12, 0.16), Color3.fromRGB(200, 160, 70), Enum.Material.Metal),
		}
	end
	local function useSkin(ch: Model)
		local bc = ch:WaitForChild("Body Colors", 5) :: BodyColors?
		local hand = ch:WaitForChild("RightHand", 5) :: BasePart?
		local c = (bc and bc.RightArmColor3) or (hand and hand.Color) or skin
		skinColor = c:Lerp(Color3.new(0, 0, 0), 0.35) -- darker so it does not blow out under the lamps
		for _, a in arms do a.arm.Color = skinColor end
	end
	if lp.Character then task.spawn(useSkin, lp.Character) end
	lp.CharacterAdded:Connect(function(ch) task.spawn(useSkin, ch) end)
	RunService:BindToRenderStep("Viewmodel", Enum.RenderPriority.Camera.Value + 2, VM.update)
end

function VM.punch(combo: number)
	local side = nextSide
	nextSide = side == "R" and "L" or "R"
	local kind = (combo >= 5 and combo % 3 == 0) and "hook" or ((combo >= 8 and combo % 4 == 0) and "upper" or "jab")
	table.insert(punches, { side = side, t0 = os.clock(), kind = kind, dur = kind == "jab" and 0.22 or 0.3 })
end

function VM.slam()
	table.insert(punches, { side = "R", t0 = os.clock(), kind = "slam", dur = 0.45 })
	table.insert(punches, { side = "L", t0 = os.clock(), kind = "slam", dur = 0.45 })
end

function VM.setShake(cf: CFrame) shakeOff = cf end

local function punchOffset(side: string, now: number): CFrame
	local out = CFrame.new()
	for i = #punches, 1, -1 do
		local p = punches[i]
		local a = (now - p.t0) / p.dur
		if a >= 1 then
			table.remove(punches, i)
		elseif p.side == side then
			local ext = a < 0.28 and (a / 0.28) or (1 - (a - 0.28) / 0.72) ^ 2
			ext = math.sin(ext * math.pi / 2)
			local sx = side == "R" and -1 or 1
			if p.kind == "jab" then
				out = CFrame.new(sx * 0.75 * ext, 0.35 * ext, -1.9 * ext) * CFrame.Angles(0, sx * 0.25 * ext, 0)
			elseif p.kind == "hook" then
				out = CFrame.new(sx * 1.4 * ext, 0.45 * ext, -1.2 * ext) * CFrame.Angles(0, sx * 1.1 * ext, sx * -0.6 * ext)
			elseif p.kind == "upper" then
				out = CFrame.new(sx * 0.7 * ext, 1.1 * ext, -1.4 * ext) * CFrame.Angles(1.0 * ext, 0, 0)
			else -- slam (ultimate)
				out = CFrame.new(sx * 0.4 * ext, -0.6 * ext + (1 - ext) * 1.2, -1.6 * ext) * CFrame.Angles(-0.9 * ext, 0, 0)
			end
		end
	end
	return out
end

function VM.update(dt: number)
	local ch = lp.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	local firstPerson = (cam.CFrame.Position - cam.Focus.Position).Magnitude < 1.5
	local show = hum ~= nil and hum.Health > 0 and firstPerson
	for _, a in arms do for _, p in a do (p :: BasePart).LocalTransparencyModifier = show and 0 or 1 end end
	if not show then lastCamCF = cam.CFrame; return end
	local now = os.clock()
	-- sway from camera turning, bob from walking
	local rx, ry = (lastCamCF:ToObjectSpace(cam.CFrame)):ToOrientation()
	lastCamCF = cam.CFrame
	sway = sway:Lerp(Vector2.new(math.clamp(ry, -0.2, 0.2), math.clamp(rx, -0.2, 0.2)), math.min(1, dt * 10))
	local moving = hum and hum.MoveDirection.Magnitude > 0.1
	if moving then bobT += dt * (hum.WalkSpeed / 2.2) end
	local bob = moving and CFrame.new(math.sin(bobT) * 0.07, math.abs(math.cos(bobT)) * 0.08, 0) or CFrame.new()
	local carrying = lp:GetAttribute("Carrying") == true
	carryAlpha += ((carrying and 1 or 0) - carryAlpha) * math.min(1, dt * 10)
	local ult = lp:GetAttribute("UltActive") == true
	local jitter = ult and CFrame.new(math.random() * 0.03, math.random() * 0.03, 0) or CFrame.new()
	local base = cam.CFrame * shakeOff * bob * jitter * CFrame.new(-sway.X * 1.2, sway.Y * 1.2, 0)
	local hasBrass = string.find(lp:GetAttribute("Owned") or "", "BrassKnuckles") ~= nil
	for side, a in arms do
		local sx = side == "R" and 1 or -1
		local guard = CFrame.new(sx * 0.62, -0.62 + (side == "L" and -0.04 or 0), -1.5) * CFrame.Angles(0.22, sx * -0.14, sx * -0.25)
		local carry = CFrame.new(sx * 0.7, -2.6, -1.2) * CFrame.Angles(0.6, 0, sx * -0.15) -- arms drop out of view while lifting
		local pose = guard:Lerp(carry, carryAlpha)
		local fistCF = base * pose * punchOffset(side, now)
		a.fist.CFrame = fistCF
		a.arm.CFrame = fistCF * CFrame.new(0, -0.04, 1.05)
		a.sleeve.CFrame = fistCF * CFrame.new(0, -0.04, 2.0)
		a.brass.CFrame = fistCF * CFrame.new(0, 0.1, -0.22)
		a.brass.LocalTransparencyModifier = hasBrass and 0 or 1
		a.fist.Material = ult and Enum.Material.Neon or Enum.Material.SmoothPlastic
		a.fist.Color = ult and Color3.fromRGB(255, 70, 30) or skinColor
	end
end

return VM
