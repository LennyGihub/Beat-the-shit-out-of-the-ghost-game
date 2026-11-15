-- Other players' held items: the item they selected (attributes Inv + Sel) sits in their right hand,
-- and it swings when they use it (Fx "ItemSwing"). Purely visual, built on this client only.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Items = require(RS.Shared.Items)
local ItemModels = require(RS.Shared.ItemModels)

local TP = {}
local lp = Players.LocalPlayer
local shown = {} :: { [Player]: { id: string, model: Model, swingT: number } }
local folder: Folder

local function selectedId(p: Player): string?
	local sel = p:GetAttribute("Sel") or 0
	if sel <= 0 or not p:GetAttribute("InMatch") then return nil end
	local n = 0
	for entry in string.gmatch((p:GetAttribute("Inv") or "") .. ",", "([^,]*),") do
		n += 1
		if n == sel then
			local id = string.match(entry, "^([^:]+)")
			return id
		end
	end
	return nil
end

local function clear(p: Player)
	local s = shown[p]
	if s then s.model:Destroy(); shown[p] = nil end
end

function TP.swing(p: Player)
	local s = shown[p]
	if s then s.swingT = os.clock() end
end

local function step()
	local now = os.clock()
	for _, p in Players:GetPlayers() do
		if p ~= lp then
			local id = selectedId(p)
			local ch = p.Character
			local hand = ch and ch:FindFirstChild("RightHand") :: BasePart?
			local s = shown[p]
			if not id or not hand then
				clear(p)
			else
				if not s or s.id ~= id then
					clear(p)
					local it = Items.byId[id]
					if it then
						local m = ItemModels.build(it.shape, it.color, it.glow, it.id)
						m:ScaleTo(m:GetScale() * 0.85)
						m.Parent = folder
						s = { id = id, model = m, swingT = 0 }
						shown[p] = s
					end
				end
				if s then
					-- swing: a quick downward arc over 0.3 s
					local a = math.clamp((now - s.swingT) / 0.3, 0, 1)
					local arc = a < 1 and math.sin(a * math.pi) or 0
					s.model:PivotTo(hand.CFrame * CFrame.new(0, -0.35, -0.1) * CFrame.Angles(math.rad(25) - arc * 1.6, 0, 0))
				end
			end
		end
	end
	for p in shown do if not p.Parent then clear(p) end end
end

function TP.init()
	folder = Instance.new("Folder")
	folder.Name = "OtherPlayersItems"
	folder.Parent = workspace
	RunService.RenderStepped:Connect(step)
end

return TP
