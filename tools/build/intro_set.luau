-- THE INTRO'S PIECES (Edit, standalone: python3 tools/studio.py luau Edit tools/build/intro_set.luau), into
-- ReplicatedStorage.Intro for Client/Intro (the intro happens in the Mansion's TV room; these are the client's own):
--   Woman  a copy of the Woman (ServerStorage.GhostTemplate): her root anchored, nothing collides. She is the one who
--          comes out of the TV; the real monster takes her place when she lunges.
--   Rift   a jagged purple crack across the night sky (hand-built Neon parts), placed over the house at the end.
-- Re-running replaces them.
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local rng = Random.new(31)
local old = RS:FindFirstChild("Intro")
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = "Intro"

-- THE WOMAN
local src = SS:FindFirstChild("GhostTemplate")
local nWoman = 0
if src then
	local w = src:Clone()
	w.Name = "Woman"
	for _, d in w:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = d.Name == "HumanoidRootPart"
			d.CanCollide = false; d.CanQuery = false; d.CanTouch = false
			nWoman += 1
		elseif d:IsA("LuaSourceContainer") then
			d:Destroy()
		end
	end
	w.Parent = root
end

-- THE RIFT: about 150 studs across (along X), around its own origin
local rift = Instance.new("Model")
rift.Name = "Rift"
local function part(name: string, size: Vector3, cf: CFrame, color: Color3, tr: number): Part
	local p = Instance.new("Part")
	p.Name = name; p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
	p.CastShadow = false; p.Material = Enum.Material.Neon; p.Color = color; p.Transparency = tr
	p.Size = size; p.CFrame = cf; p.Parent = rift
	return p
end
local x, y = -75, 0
local first: Part? = nil
while x < 75 do
	local nx = x + rng:NextNumber(7, 12)
	local ny = y + rng:NextNumber(-9, 9)
	local a, b = Vector3.new(x, y, 0), Vector3.new(nx, ny, rng:NextNumber(-3, 3))
	local mid, len = (a + b) / 2, (b - a).Magnitude
	local c = part("Crack", Vector3.new(1.4, 1.4, len), CFrame.lookAt(mid, b), Color3.fromRGB(215, 140, 255), 0)
	part("Halo", Vector3.new(5, 5, len), CFrame.lookAt(mid, b), Color3.fromRGB(130, 40, 210), 0.72)
	-- a few short splinters off the main crack
	if rng:NextNumber() < 0.6 then
		local s0 = a:Lerp(b, 0.5)
		local s1 = s0 + Vector3.new(rng:NextNumber(-4, 4), rng:NextNumber(5, 11) * (rng:NextNumber() < 0.5 and -1 or 1), 0)
		part("Splinter", Vector3.new(0.6, 0.6, (s1 - s0).Magnitude), CFrame.lookAt((s0 + s1) / 2, s1), Color3.fromRGB(200, 120, 255), 0.1)
	end
	first = first or c
	x, y = nx, ny
end
if first then
	local l = Instance.new("PointLight"); l.Name = "RiftLight"; l.Color = Color3.fromRGB(170, 80, 255); l.Range = 60; l.Brightness = 3; l.Parent = first
end
rift.PrimaryPart = first
rift.Parent = root

root.Parent = RS
local n = 0
for _, d in rift:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
return string.format("ReplicatedStorage.Intro: Woman %d parts, Rift %d parts", nWoman, n)
