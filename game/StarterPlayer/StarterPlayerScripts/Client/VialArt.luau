--!strict
-- The picture of a jar of ectoplasm / a potion (Shared/Forms vials), for the sellers' panel (Client/SellerUI) and the
-- offline-opening widget (Client/OfflineOpen): its image (Forms.icons) when it has one, otherwise a little jar /
-- bottle drawn with frames (glass, the glowing contents, a lid for a jar, a cork for a potion).
-- VialArt.draw(parent, vial, props, dim) -> a Frame laid out by props (Position, Size, AnchorPoint, ZIndex...);
-- its child "Goo" is the contents (recolour / animate it) when the vial is drawn.
local RS = game:GetService("ReplicatedStorage")
local Forms = require(RS.Shared.Forms)

local VialArt = {}

local function fr(parent: Instance, props: { [string]: any }): Frame
	local f = Instance.new("Frame")
	f.BorderSizePixel = 0
	for k, v in props do (f :: any)[k] = v end
	f.Parent = parent
	return f
end

function VialArt.icon(v: Forms.Vial): string
	local icons = (Forms :: any).icons
	return icons and icons[v.id] or ""
end

function VialArt.draw(parent: Instance, v: Forms.Vial, props: { [string]: any }, dim: boolean?): Frame
	local z = props.ZIndex or 1
	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1; box.BorderSizePixel = 0
	for k, val in props do (box :: any)[k] = val end
	box.Name = "Vial"
	box.Parent = parent
	local img = VialArt.icon(v)
	if img ~= "" then
		local il = Instance.new("ImageLabel")
		il.Name = "Image"; il.BackgroundTransparency = 1; il.Image = img; il.ScaleType = Enum.ScaleType.Fit
		il.Size = UDim2.fromScale(1, 1); il.ZIndex = z + 1; il.ImageTransparency = dim and 0.6 or 0
		il.Parent = box
		return box
	end
	local jar = fr(box, { Name = "Jar", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromScale(0.62, 0.95), Rotation = -6, ZIndex = z + 1 })
	local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = 0.72; ar.Parent = jar
	local glass = fr(jar, { Name = "Glass", BackgroundTransparency = 0.55, BackgroundColor3 = Color3.fromRGB(200, 225, 215), Position = UDim2.fromScale(0.05, 0.18),
		Size = UDim2.fromScale(0.9, 0.8), ZIndex = z + 1 })
	local gc = Instance.new("UICorner"); gc.CornerRadius = UDim.new(0.18, 0); gc.Parent = glass
	local goo = fr(jar, { Name = "Goo", BackgroundTransparency = dim and 0.6 or 0, BackgroundColor3 = v.color, Position = UDim2.fromScale(0.14, 0.38),
		Size = UDim2.fromScale(0.72, 0.54), ZIndex = z + 2 })
	local gc2 = Instance.new("UICorner"); gc2.CornerRadius = UDim.new(0.2, 0); gc2.Parent = goo
	fr(jar, { Name = "Shine", BackgroundTransparency = 0.5, BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.fromScale(0.18, 0.26),
		Size = UDim2.fromScale(0.1, 0.55), ZIndex = z + 3 })
	if v.kind == "stim" then
		fr(jar, { Name = "Lid", BackgroundColor3 = Color3.fromRGB(70, 66, 60), Position = UDim2.fromScale(0, 0.06), Size = UDim2.fromScale(1, 0.15), ZIndex = z + 3 })
	else
		fr(jar, { Name = "Cork", BackgroundColor3 = Color3.fromRGB(150, 110, 70), Position = UDim2.fromScale(0.35, 0), Size = UDim2.fromScale(0.3, 0.2), ZIndex = z + 3 })
	end
	return box
end

return VialArt
