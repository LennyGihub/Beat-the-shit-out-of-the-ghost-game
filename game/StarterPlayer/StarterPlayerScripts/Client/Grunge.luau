-- Hand-drawn grunge UI pieces: ragged brush-stroke bars, sketchy pen outlines, splatters, marker text.
local Grunge = {}
Grunge.FONT = Enum.Font.PermanentMarker
Grunge.HORROR = Enum.Font.Creepster
Grunge.TYPE = Enum.Font.SpecialElite
Grunge.SPLAT = "rbxassetid://17364186033"
Grunge.SCRATCH = "rbxassetid://137193904844524"
Grunge.INK = Color3.fromRGB(16, 12, 10)
Grunge.PAPER = Color3.fromRGB(232, 222, 200)

local function frame(parent: Instance, props: { [string]: any }): Frame
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	f.BackgroundTransparency = 1
	for k, v in props do (f :: any)[k] = v end
	f.Parent = parent
	return f
end
Grunge.frame = frame

function Grunge.text(parent: Instance, props: { [string]: any }): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Font = Grunge.FONT
	t.TextColor3 = Grunge.PAPER
	t.TextStrokeColor3 = Grunge.INK
	t.TextStrokeTransparency = 0.2
	t.TextScaled = true
	for k, v in props do (t :: any)[k] = v end
	t.Parent = parent
	return t
end

function Grunge.splat(parent: Instance, props: { [string]: any }): ImageLabel
	local i = Instance.new("ImageLabel")
	i.BackgroundTransparency = 1
	i.Image = Grunge.SPLAT
	i.ScaleType = Enum.ScaleType.Fit
	for k, v in props do (i :: any)[k] = v end
	i.Parent = parent
	return i
end

-- ragged stroke made of thin rotated slices (looks like a dry brush)
local function stroke(parent: Instance, n: number, color: Color3, seed: number, minH: number, z: number): { Frame }
	local rng = Random.new(seed)
	local out = {}
	for i = 0, n - 1 do
		local edge = (i == 0 or i == n - 1) and 0.75 or ((i == 1 or i == n - 2) and 0.9 or 1)
		local h = rng:NextNumber(minH, 1) * edge
		local f = frame(parent, {
			BackgroundTransparency = 0,
			BackgroundColor3 = color:Lerp(Color3.new(0, 0, 0), rng:NextNumber(0, 0.18)),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(i / n, 0, 0.5 + rng:NextNumber(-0.06, 0.06), 0),
			Size = UDim2.new(1 / n + 0.004, 0, h, 0),
			Rotation = rng:NextNumber(-2.5, 2.5),
			ZIndex = z,
		})
		f:SetAttribute("W", 1 / n + 0.004)
		table.insert(out, f)
	end
	return out
end

-- pen-sketch outline: a few slightly crooked lines around a box
local function sketch(parent: Instance, seed: number, z: number)
	local rng = Random.new(seed)
	for _, y in { 0, 1 } do
		for k = 1, 2 do
			frame(parent, {
				BackgroundTransparency = k == 1 and 0 or 0.45,
				BackgroundColor3 = Grunge.INK,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5 + rng:NextNumber(-0.01, 0.01), 0, y + rng:NextNumber(-0.08, 0.08), 0),
				Size = UDim2.new(1.02 + rng:NextNumber(0, 0.02), 0, 0, k == 1 and 3 or 2),
				Rotation = rng:NextNumber(-0.9, 0.9),
				ZIndex = z,
			})
		end
	end
	for _, x in { 0, 1 } do
		frame(parent, {
			BackgroundTransparency = 0,
			BackgroundColor3 = Grunge.INK,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(x + rng:NextNumber(-0.006, 0.006), 0, 0.5, 0),
			Size = UDim2.new(0, 3, 1.08, 0),
			Rotation = rng:NextNumber(-6, 6),
			ZIndex = z,
		})
	end
end

-- Creates a grunge bar. Returns an object with :set(fraction) and the root frame.
function Grunge.bar(parent: Instance, o: { size: UDim2, pos: UDim2, anchor: Vector2?, color: Color3, label: string?, rot: number?, seed: number?, slices: number?, labelSide: string? })
	local seed = o.seed or 1
	local n = o.slices or 30
	local root = frame(parent, { Size = o.size, Position = o.pos, AnchorPoint = o.anchor or Vector2.zero, Rotation = o.rot or 0 })
	Grunge.splat(root, {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.55, 0.5), Size = UDim2.fromScale(1.25, 2.6),
		ImageColor3 = Color3.fromRGB(70, 10, 10), ImageTransparency = 0.55, ZIndex = 1, Rotation = Random.new(seed):NextNumber(-12, 12),
	})
	local back = frame(root, { Size = UDim2.fromScale(1, 1), ZIndex = 2 })
	stroke(back, n, Color3.fromRGB(26, 20, 18), seed, 0.8, 2)
	local inner = frame(root, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.975, 0.72), ZIndex = 3 })
	local trail = stroke(inner, n, Color3.fromRGB(240, 230, 215), seed + 7, 0.7, 3)
	local fill = stroke(inner, n, o.color, seed + 3, 0.62, 4)
	-- scratches on the fill
	local rng = Random.new(seed + 11)
	for i = 1, 6 do
		frame(inner, {
			BackgroundTransparency = 0.55, BackgroundColor3 = Grunge.INK, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(rng:NextNumber(0.05, 0.95), rng:NextNumber(0.25, 0.75)),
			Size = UDim2.new(0, rng:NextInteger(10, 26), 0, 2), Rotation = rng:NextNumber(-35, 35), ZIndex = 5,
		})
	end
	sketch(root, seed + 5, 6)
	local label
	if o.label then
		label = Grunge.text(root, {
			Text = o.label, AnchorPoint = o.labelSide == "right" and Vector2.new(1, 1) or Vector2.new(0, 1),
			Position = o.labelSide == "right" and UDim2.new(1, -4, 0, 4) or UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0.5, 0, 0.75, 0), TextXAlignment = o.labelSide == "right" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
			Rotation = -2.5, ZIndex = 7,
		})
	end

	local obj = { root = root, label = label, fillSlices = fill, value = 1, trailValue = 1 }
	local function apply(slices: { Frame }, f: number)
		for i, s in slices do
			local a, b = (i - 1) / n, i / n
			local w = s:GetAttribute("W") :: number
			if f >= b then
				s.Visible = true; s.Size = UDim2.new(w, 0, s.Size.Y.Scale, 0)
			elseif f > a then
				s.Visible = true; s.Size = UDim2.new(w * (f - a) / (b - a), 0, s.Size.Y.Scale, 0)
			else
				s.Visible = false
			end
		end
	end
	function obj.set(_, f: number, dt: number?)
		f = math.clamp(f, 0, 1)
		local step = dt or 1 / 60
		obj.value += (f - obj.value) * math.min(1, step * 14)
		if f < obj.trailValue then
			obj.trailValue = math.max(f, obj.trailValue - step * 0.35)
		else
			obj.trailValue = obj.value
		end
		apply(fill, obj.value)
		apply(trail, obj.trailValue)
	end
	function obj.color(_, c: Color3)
		for _, s in fill do s.BackgroundColor3 = c end
	end
	return obj
end

-- grunge panel (for the shop): dark paper with sketchy border and a splatter
function Grunge.panel(parent: Instance, props: { [string]: any }, seed: number?): Frame
	local p = frame(parent, props)
	local rng = Random.new(seed or 3)
	local bg = frame(p, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.08, BackgroundColor3 = Color3.fromRGB(28, 22, 19), ZIndex = (props.ZIndex or 1) })
	Grunge.splat(p, {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(rng:NextNumber(0.2, 0.8), rng:NextNumber(0.2, 0.8)), Size = UDim2.fromScale(0.9, 0.9),
		ImageColor3 = Color3.fromRGB(90, 14, 14), ImageTransparency = 0.7, ZIndex = (props.ZIndex or 1) + 1, Rotation = rng:NextNumber(0, 360),
	})
	local sc = Instance.new("ImageLabel")
	sc.BackgroundTransparency = 1; sc.Image = Grunge.SCRATCH; sc.ImageTransparency = 0.8; sc.Size = UDim2.fromScale(1, 1)
	sc.ScaleType = Enum.ScaleType.Crop; sc.ZIndex = (props.ZIndex or 1) + 1; sc.Parent = p
	sketch(p, (seed or 3) + 1, (props.ZIndex or 1) + 2)
	return p
end

return Grunge
