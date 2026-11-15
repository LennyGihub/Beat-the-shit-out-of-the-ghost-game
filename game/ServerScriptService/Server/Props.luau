-- Small low-poly 3D props for shop items (built from parts, tinted by rarity). Origin = bottom centre.
local Props = {}
local M = Enum.Material

local function p(m: Model, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?): BasePart
	local part = Instance.new("Part")
	part.Name = name; part.Size = size; part.CFrame = cf; part.Color = color
	part.Material = mat or M.SmoothPlastic
	if shape then part.Shape = shape end
	part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = true
	part.Parent = m
	return part
end
local CYL = Enum.PartType.Cylinder
local BALL = Enum.PartType.Ball
local UP = CFrame.Angles(0, 0, math.pi / 2)

local builders = {}
function builders.knuckles(m, c)
	p(m, "Bar", Vector3.new(1.6, 0.35, 0.3), CFrame.new(0, 0.9, 0), c, M.Metal)
	for i = -1.5, 1.5 do p(m, "Ring", Vector3.new(0.25, 0.45, 0.45), CFrame.new(i * 0.42, 1.25, 0) * UP, c, M.Metal, CYL) end
	p(m, "Grip", Vector3.new(1.4, 0.3, 0.3), CFrame.new(0, 0.5, 0), c:Lerp(Color3.new(0, 0, 0), 0.3), M.Metal)
end
function builders.tape(m, c)
	p(m, "Roll", Vector3.new(0.6, 1.2, 1.2), CFrame.new(0, 0.7, 0) * UP, c:Lerp(Color3.new(1, 1, 1), 0.4), M.Fabric, CYL)
	p(m, "Hole", Vector3.new(0.62, 0.5, 0.5), CFrame.new(0, 0.7, 0) * UP, Color3.fromRGB(30, 25, 20), M.SmoothPlastic, CYL)
	p(m, "Strip", Vector3.new(0.5, 0.05, 1.2), CFrame.new(0, 0.08, 0.9), Color3.fromRGB(150, 20, 20), M.Fabric)
end
function builders.can(m, c)
	p(m, "Can", Vector3.new(1.4, 0.8, 0.8), CFrame.new(0, 0.7, 0) * UP, c, M.Metal, CYL)
	p(m, "Top", Vector3.new(0.06, 0.7, 0.7), CFrame.new(0, 1.42, 0) * UP, Color3.fromRGB(180, 180, 180), M.Metal, CYL)
end
function builders.jacket(m, c)
	p(m, "Body", Vector3.new(1.6, 1.6, 0.5), CFrame.new(0, 0.85, 0), c, M.Leather)
	p(m, "SleeveL", Vector3.new(0.45, 1.4, 0.45), CFrame.new(-1.0, 0.85, 0) * CFrame.Angles(0, 0, 0.2), c, M.Leather)
	p(m, "SleeveR", Vector3.new(0.45, 1.4, 0.45), CFrame.new(1.0, 0.85, 0) * CFrame.Angles(0, 0, -0.2), c, M.Leather)
	p(m, "Collar", Vector3.new(1.0, 0.3, 0.55), CFrame.new(0, 1.7, 0), Color3.fromRGB(210, 200, 180), M.Fabric)
end
function builders.charm(m, c)
	p(m, "Chain", Vector3.new(0.1, 1.2, 0.1), CFrame.new(0, 1.3, 0), Color3.fromRGB(150, 140, 120), M.Metal)
	p(m, "Charm", Vector3.new(0.2, 1, 1), CFrame.new(0, 0.6, 0) * UP, c, M.Metal, CYL)
end
function builders.boots(m, c)
	for _, x in { -0.4, 0.4 } do
		p(m, "Shaft", Vector3.new(0.6, 1.1, 0.6), CFrame.new(x, 0.75, 0.2), c, M.Leather)
		p(m, "Foot", Vector3.new(0.6, 0.4, 1.3), CFrame.new(x, 0.2, -0.15), c:Lerp(Color3.new(0, 0, 0), 0.25), M.Leather)
	end
end
function builders.pills(m, c)
	p(m, "Bottle", Vector3.new(1.2, 0.8, 0.8), CFrame.new(0, 0.6, 0) * UP, c, M.SmoothPlastic, CYL)
	p(m, "Cap", Vector3.new(0.3, 0.85, 0.85), CFrame.new(0, 1.35, 0) * UP, Color3.fromRGB(230, 230, 225), M.SmoothPlastic, CYL)
	for i = 1, 3 do p(m, "Pill", Vector3.new(0.3, 0.3, 0.3), CFrame.new(0.6 + i * 0.1, 0.15, -0.4 + i * 0.2), Color3.fromRGB(240, 240, 235), M.SmoothPlastic, BALL) end
end
function builders.gloves(m, c)
	for _, x in { -0.45, 0.45 } do
		p(m, "Palm", Vector3.new(0.7, 0.9, 0.3), CFrame.new(x, 0.7, 0) * CFrame.Angles(0, 0, x * 0.4), c, M.Leather)
		p(m, "Fingers", Vector3.new(0.7, 0.5, 0.3), CFrame.new(x * 1.25, 1.3, 0) * CFrame.Angles(0, 0, x * 0.4), c, M.Leather)
	end
end
function builders.cross(m, c)
	p(m, "V", Vector3.new(0.3, 1.8, 0.2), CFrame.new(0, 0.9, 0), c, M.Metal)
	p(m, "H", Vector3.new(1.1, 0.3, 0.2), CFrame.new(0, 1.3, 0), c, M.Metal)
end
function builders.pouch(m, c)
	p(m, "Bag", Vector3.new(1.3, 1.2, 1.3), CFrame.new(0, 0.6, 0), c, M.Fabric, BALL)
	p(m, "Tie", Vector3.new(0.5, 0.3, 0.5), CFrame.new(0, 1.25, 0), Color3.fromRGB(80, 60, 40), M.Fabric)
end
function builders.syringe(m, c)
	p(m, "Barrel", Vector3.new(1.4, 0.4, 0.4), CFrame.new(0, 0.3, 0), c, M.Glass, CYL).Transparency = 0.3
	p(m, "Needle", Vector3.new(0.8, 0.08, 0.08), CFrame.new(1.1, 0.3, 0), Color3.fromRGB(200, 200, 200), M.Metal, CYL)
	p(m, "Plunger", Vector3.new(0.6, 0.15, 0.15), CFrame.new(-1, 0.3, 0), Color3.fromRGB(230, 230, 230), M.SmoothPlastic, CYL)
end
function builders.skull(m, c)
	p(m, "Skull", Vector3.new(1.2, 1.2, 1.3), CFrame.new(0, 0.75, 0), c:Lerp(Color3.fromRGB(230, 220, 200), 0.5), M.SmoothPlastic, BALL)
	p(m, "Jaw", Vector3.new(0.8, 0.4, 0.8), CFrame.new(0, 0.2, -0.15), c:Lerp(Color3.fromRGB(230, 220, 200), 0.5), M.SmoothPlastic)
	for _, x in { -0.25, 0.25 } do p(m, "Eye", Vector3.new(0.3, 0.3, 0.2), CFrame.new(x, 0.85, -0.58), Color3.fromRGB(10, 8, 8), M.SmoothPlastic) end
end
function builders.bottle(m, c)
	p(m, "Body", Vector3.new(1.2, 0.9, 0.9), CFrame.new(0, 0.6, 0) * UP, c, M.Glass, CYL).Transparency = 0.2
	p(m, "Neck", Vector3.new(0.6, 0.35, 0.35), CFrame.new(0, 1.45, 0) * UP, c, M.Glass, CYL)
	p(m, "Cork", Vector3.new(0.25, 0.3, 0.3), CFrame.new(0, 1.8, 0) * UP, Color3.fromRGB(150, 110, 70), M.Wood, CYL)
end
function builders.mask(m, c)
	p(m, "Face", Vector3.new(1.3, 1.6, 0.3), CFrame.new(0, 0.9, 0), c, M.SmoothPlastic)
	for _, x in { -0.3, 0.3 } do p(m, "Eye", Vector3.new(0.35, 0.2, 0.32), CFrame.new(x, 1.1, -0.02), Color3.fromRGB(10, 8, 8), M.SmoothPlastic) end
	p(m, "Mouth", Vector3.new(0.7, 0.15, 0.32), CFrame.new(0, 0.5, -0.02), Color3.fromRGB(10, 8, 8), M.SmoothPlastic)
	for _, x in { -0.5, 0.5 } do p(m, "Horn", Vector3.new(0.2, 0.7, 0.2), CFrame.new(x, 1.9, 0) * CFrame.Angles(0, 0, -x * 0.6), Color3.fromRGB(40, 30, 25), M.SmoothPlastic) end
end
function builders.book(m, c)
	p(m, "Cover", Vector3.new(1.2, 0.35, 1.6), CFrame.new(0, 0.2, 0), c, M.Leather)
	p(m, "Pages", Vector3.new(1.1, 0.28, 1.5), CFrame.new(0.05, 0.2, 0), Color3.fromRGB(230, 220, 190), M.SmoothPlastic)
	p(m, "Mark", Vector3.new(0.1, 0.05, 0.6), CFrame.new(0, 0.39, 0), Color3.fromRGB(220, 200, 120), M.Metal)
end

function Props.build(kind: string, color: Color3, rarity: number): Model
	local m = Instance.new("Model")
	m.Name = "Prop"
	local base = p(m, "Base", Vector3.new(0.2, 2.2, 2.2), CFrame.new(0, -0.1, 0) * UP, color:Lerp(Color3.new(0, 0, 0), 0.35), M.SmoothPlastic, CYL)
	local f = builders[kind] or builders.charm
	f(m, color)
	m.PrimaryPart = base
	local l = Instance.new("PointLight"); l.Color = color; l.Range = 4 + rarity; l.Brightness = 0.25 + rarity * 0.08; l.Parent = base
	if rarity >= 5 then
		local s = Instance.new("Sparkles"); s.SparkleColor = color; s.Parent = base
	end
	return m
end

return Props
