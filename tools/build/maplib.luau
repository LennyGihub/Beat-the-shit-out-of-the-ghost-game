-- Map builder library (Edit mode). Prepend lib2 + furn_lib + maplib, then one maps/<id>.luau:
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/hospital.luau > /tmp/run.luau
-- Every map is built into ServerStorage.Maps.<id> on the Mansion's footprint (x -80..80, z -60..60, front door at
-- z = 59 facing the yard, ground floor y = 2, upper floor y = 23) so the run, events, yard and door prompt all fit.
-- Folders: Structure (walls/floors, raycast by the ghost), Furniture (carryable), Decor, Lights, GhostSpawns.
local SSm = game:GetService("ServerStorage")
local MAP, STR, DEC, LIT, GSP
local F1, F2 = 2, 23

-- start a map: fresh model in ServerStorage.Maps, theme materials into T (used by the wall/opening code below)
local function beginMap(id: string, theme)
	local maps = SSm:FindFirstChild("Maps") or Instance.new("Folder")
	maps.Name = "Maps"; maps.Parent = SSm
	-- (the old map stays until endMap: a build that fails half way leaves the stored one as it was)
	MAP = Instance.new("Model"); MAP.Name = id
	STR = model(MAP, "Structure"); DEC = model(MAP, "Decor"); LIT = model(MAP, "Lights")
	FURN = model(MAP, "Furniture")
	GSP = Instance.new("Folder"); GSP.Name = "GhostSpawns"; GSP.Parent = MAP
	for k, v in theme do T[k] = v end
	MAP:SetAttribute("MapId", id)
	MAP:SetAttribute("SpawnInside", Vector3.new(0, 5, 46))
	return MAP
end

local function endMap()
	local old = SSm.Maps:FindFirstChild(MAP.Name); if old and old ~= MAP then old:Destroy() end
	MAP.Parent = SSm.Maps
	local n = 0
	for _, d in MAP:GetDescendants() do if d:IsA("BasePart") then n += 1 end end
	return MAP.Name .. " parts: " .. n
end

local function gspawn(x, y, z)
	local p = Instance.new("Part"); p.Name = "Spawn"; p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
	p.Transparency = 1; p.Size = Vector3.one; p.Position = Vector3.new(x, y + 4.6, z); p.Parent = GSP
end

-- a floor rectangle the furnish / detail passes leave empty (a corridor, a gallery walk, the foot of a stair):
-- an invisible marker part in MAP.KeepClear, no collision, never hit by a ray
local function keepClear(x1, z1, x2, z2, y)
	local kc = MAP:FindFirstChild("KeepClear")
	if not kc then kc = Instance.new("Folder"); kc.Name = "KeepClear"; kc.Parent = MAP end
	local p = Instance.new("Part"); p.Name = "Zone"; p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
	p.Transparency = 1; p.CastShadow = false
	p.Size = Vector3.new(math.abs(x2 - x1), 8, math.abs(z2 - z1)); p.Position = Vector3.new((x1 + x2) / 2, y + 4, (z1 + z2) / 2)
	p.Parent = kc
end

---------------------------------------------------------------- walls (same as the Mansion's)
local function mapS(along, fixed, s, y, d) if along == "x" then return s, y, fixed + d end return fixed + d, y, s end
local function boxS(m, name, along, fixed, s1, y1, d1, s2, y2, d2, sty, o)
	local x1, yy1, z1 = mapS(along, fixed, s1, y1, d1)
	local x2, yy2, z2 = mapS(along, fixed, s2, y2, d2)
	return box(m, name, x1, yy1, z1, x2, yy2, z2, sty, o)
end

local function opening(m, along, fixed, op, y0, th)
	local o1, o2 = op.c - op.w / 2, op.c + op.w / 2
	local d, TR = th / 2 + 0.6, 0.6
	boxS(m, "Frame", along, fixed, o1 - TR, y0 + op.b, -d, o1, y0 + op.t + TR, d, T.trim)
	boxS(m, "Frame", along, fixed, o2, y0 + op.b, -d, o2 + TR, y0 + op.t + TR, d, T.trim)
	boxS(m, "Frame", along, fixed, o1 - TR, y0 + op.t, -d, o2 + TR, y0 + op.t + TR, d, T.trim)
	if op.kind == "window" then
		boxS(m, "Sill", along, fixed, o1 - 1, y0 + op.b - 0.4, -(d + 0.3), o2 + 1, y0 + op.b, d + 0.3, T.trim)
		boxS(m, "Glass", along, fixed, o1, y0 + op.b, -0.1, o2, y0 + op.t, 0.1, T.glass, { t = 0.35 })
		if T.bars then
			for x = o1 + 0.8, o2 - 0.4, 1.2 do boxS(m, "Bar", along, fixed, x - 0.12, y0 + op.b, -0.4, x + 0.12, y0 + op.t, -0.15, T.iron, DECO) end
		else
			boxS(m, "Mullion", along, fixed, op.c - 0.2, y0 + op.b, -0.25, op.c + 0.2, y0 + op.t, 0.25, T.trim, DECO)
			local yy = y0 + op.b + (op.t - op.b) * 0.5
			boxS(m, "Mullion", along, fixed, o1, yy - 0.2, -0.25, o2, yy + 0.2, 0.25, T.trim, DECO)
		end
	elseif op.kind == "double" then
		local inward, leafW = op.inward, op.w / 2 - 0.1
		for _, hs in { { o1, o1 + 0.5 }, { o2 - 0.5, o2 } } do
			local d1, d2 = inward * (th / 2), inward * (th / 2 + leafW)
			boxS(m, "DoorLeaf", along, fixed, hs[1], y0 + 0.05, math.min(d1, d2), hs[2], y0 + op.t - 0.1, math.max(d1, d2), T.door or T.wainscot)
		end
	end
end

local function wall(parent, name, along, fixed, a1, a2, y0, h, ops, style)
	local m = model(parent, name)
	local th = style.th
	table.sort(ops, function(p, q) return p.c < q.c end)
	local skinSide = {}
	for _, sk in style.skins do skinSide[sk.side] = true end
	local function seg(s1, s2, b1, b2)
		if s2 - s1 < 0.01 or b2 - b1 < 0.01 then return end
		boxS(m, "Wall", along, fixed, s1, y0 + b1, -th / 2, s2, y0 + b2, th / 2, style.core)
		for _, sk in style.skins do
			local d1, d2 = sk.side * th / 2, sk.side * (th / 2 + 0.25)
			boxS(m, "Skin", along, fixed, s1, y0 + b1, math.min(d1, d2), s2, y0 + b2, math.max(d1, d2), sk.s)
		end
		if b1 == 0 and style.wain then
			for _, side in style.wain do
				local base = th / 2 + (skinSide[side] and 0.25 or 0)
				local top = math.min(b2, T.wainH or 4.5)
				local d1, d2 = side * base, side * (base + 0.25)
				boxS(m, "Wainscot", along, fixed, s1, y0, math.min(d1, d2), s2, y0 + top, math.max(d1, d2), T.wainscot, DECO)
			end
		end
	end
	local cur = a1
	for _, op in ops do
		local o1, o2 = op.c - op.w / 2, op.c + op.w / 2
		seg(cur, o1, 0, h); seg(o1, o2, 0, op.b); seg(o1, o2, op.t, h)
		cur = o2
		opening(m, along, fixed, op, y0, th)
	end
	seg(cur, a2, 0, h)
	return m
end

local function EXT(inward) return { core = T.ext, th = 2, skins = { { side = inward, s = T.inner } }, wain = T.wain and { inward } or nil } end
local function INT() return { core = T.inner, th = 1.2, skins = {}, wain = T.wain and { 1, -1 } or nil } end
local function win(c, w, bb, tt) return { c = c, w = w or 6, b = bb or 4, t = tt or 14, kind = "window" } end
local function dr(c, w, t) return { c = c, w = w or 6, b = 0, t = t or 12, kind = "open" } end
local function wins(list, w, bb, tt) local r = {} for _, c in list do table.insert(r, win(c, w, bb, tt)) end return r end

---------------------------------------------------------------- shell
-- o: { two = bool (upper floor), H = storey height (20, or the full height of a one-storey hall),
--      front1/front2/back1/back2/left1/left2/right1/right2 = window centre lists, roof = "gable"|"flat", porch = fn? }
local function shell(o)
	local H = o.H or 20
	local top = o.two and 44 or (F1 + H)
	box(STR, "Foundation", -81, 0, -61, 81, 2, 61, T.found or T.stone)
	box(STR, "GroundFloor", -78, 1.9, -58, 78, 2.05, 58, T.floor)
	local ext = model(STR, "Exterior")
	local f1 = wins(o.front1 or { -22, 22, -48, -66, 48, 66 }, o.winW, o.winB, o.winT)
	table.insert(f1, { c = 0, w = 10, b = 0, t = 15, kind = "double", inward = -1 })
	wall(ext, "Front1", "x", 59, -80, 80, F1, H, f1, EXT(-1))
	wall(ext, "Back1", "x", -59, -80, 80, F1, H, wins(o.back1 or { -60, -30, 0, 30, 60 }, o.winW, o.winB, o.winT), EXT(1))
	wall(ext, "Left1", "z", -79, -58, 58, F1, H, wins(o.left1 or { 40, 10, -20, -45 }, o.winW, o.winB, o.winT), EXT(1))
	wall(ext, "Right1", "z", 79, -58, 58, F1, H, wins(o.right1 or { 40, 10, -20, -45 }, o.winW, o.winB, o.winT), EXT(-1))
	if o.two then
		wall(ext, "Front2", "x", 59, -80, 80, F2, 20, wins(o.front2 or { -66, -48, -22, 0, 22, 48, 66 }), EXT(-1))
		wall(ext, "Back2", "x", -59, -80, 80, F2, 20, wins(o.back2 or { -60, -30, 0, 30, 60 }), EXT(1))
		wall(ext, "Left2", "z", -79, -58, 58, F2, 20, wins(o.left2 or { 40, 10, -20, -45 }), EXT(1))
		wall(ext, "Right2", "z", 79, -58, 58, F2, 20, wins(o.right2 or { 40, 10, -20, -45 }), EXT(-1))
		box(ext, "Band", -80.4, 22, 58, 80.4, 23, 60.4, T.trim)
	end
	for _, xz in { { -79, -59 }, { 79, -59 }, { -79, 59 }, { 79, 59 } } do
		box(ext, "CornerPost", xz[1] - 1.6, 2, xz[2] - 1.6, xz[1] + 1.6, top, xz[2] + 1.6, T.trim)
	end
	box(STR, "Ceiling", -78, top - 1, -58, 78, top, 58, T.ceiling or T.beam)
	-- roof
	local rf = model(STR, "Roof")
	if o.roof == "flat" then
		box(rf, "RoofSlab", -81, top, -61, 81, top + 1.2, 61, T.roof)
		for _, z in { -61, 60 } do box(rf, "Parapet", -81, top + 1.2, z, 81, top + 4, z + 1, T.ext) end
		for _, x in { -81, 80 } do box(rf, "Parapet", x, top + 1.2, -61, x + 1, top + 4, 61, T.ext) end
	else
		local s = o.pitch or 0.45
		local a = math.atan(s)
		local span = 63
		for _, sg in { 1, -1 } do
			local midZ = span / 2
			local midY = top + s * (60 - midZ)
			local n = Vector3.new(0, math.cos(a), math.sin(a))
			part(rf, "RoofPanel", Vector3.new(166, 1.2, span / math.cos(a)), CFrame.new(0, midY + 0.6 * n.Y, sg * (midZ + 0.6 * n.Z)) * CFrame.Angles(sg * a, 0, 0), T.roof)
			box(rf, "Fascia", -83, top - 2.4, sg * 63 - 0.3, 83, top - 0.8, sg * 63 + 0.3, T.trim)
		end
		local peak = top + s * 60
		box(rf, "RidgeCap", -83.5, peak - 1, -1.4, 83.5, peak + 0.6, 1.4, T.trim)
		for _, x in { -79, 79 } do
			local k, step = 0, 1.2
			while top + step * k < peak - 0.5 do
				local hw = 60 - (step * k) / s
				box(rf, "Gable", x - 1, top + step * k, -hw, x + 1, top + step * (k + 1), hw, T.ext)
				k += 1
			end
		end
	end
	-- porch: the deck is the same on every map (the run's front door prompt and exit beacon sit there)
	local po = model(STR, "Porch")
	box(po, "Deck", -16, 1, 60, 16, 2.05, 72, T.porch or T.floor)
	box(po, "Step", -8, 0, 72, 8, 1.35, 74, T.porch or T.floor)
	box(po, "Step", -8, 0, 74, 8, 0.7, 76, T.porch or T.floor)
	if o.porch ~= "none" then
		for _, x in { -15, 15 } do cyl(po, CFrame.new(x, 9, 71), "Column", 1.6, 14, 0, 0, 0, T.trim) end
		box(po, "PorchRoof", -17, 16, 60.4, 17, 17, 73, T.roof)
		box(po, "PorchBeam", -17, 15, 70.2, 17, 16, 71.8, T.trim)
	end
	-- porch lanterns + two floodlights washing the facade (the yard is dark)
	for _, x in { -7.5, 7.5 } do
		local lm = model(po, "Lantern")
		box(lm, "Cage", x - 0.6, 10, 60.5, x + 0.6, 11.6, 61.7, T.iron, { t = 0.3, deco = true })
		local g = box(lm, "Glow", x - 0.35, 10.2, 60.75, x + 0.35, 11.4, 61.45, st(M.Neon, nil, T.lanternColor or Color3.fromRGB(255, 190, 120)), DECO)
		light(g, 22, 1.4, T.lanternColor)
	end
	for _, x in { -50, 50 } do
		local fl = box(po, "Floodlight", x - 0.8, 0.2, 74, x + 0.8, 1.2, 75, T.iron, DECO)
		local sp = Instance.new("SpotLight"); sp.Face = Enum.NormalId.Back; sp.Angle = 70; sp.Range = 45; sp.Brightness = 1.6
		sp.Color = T.floodColor or Color3.fromRGB(200, 205, 230); sp.Parent = fl
		fl.CFrame = CFrame.lookAt(fl.Position, Vector3.new(x * 0.6, 22, 60)) * CFrame.Angles(0, math.pi, 0)
	end
	return top
end

-- upper floor slab pieces
local function slab(x1, z1, x2, z2) box(STR, "Slab", x1, 22, z1, x2, 23, z2, T.floor2 or T.floor) end

-- straight stair from F1 up to F2 along -Z (x1..x2 wide, starting at zStart); 21 steps of 1.5
local function stairs(x1, x2, zStart)
	local stc = model(STR, "Stairs")
	for i = 1, 21 do
		local zA, zB = zStart - (i - 1) * 1.5, zStart - i * 1.5
		box(stc, "Step", x1, F1, zB, x2, F1 + i, zA, T.stairs or T.floor)
		box(stc, "Nosing", x1, F1 + i - 0.2, zA - 0.3, x2, F1 + i + 0.05, zA + 0.15, T.trim, DECO)
	end
	local th = math.atan(21 / 31.5)
	for _, x in { x1 - 0.3, x2 + 0.3 } do
		part(stc, "Handrail", Vector3.new(0.4, 0.4, math.sqrt(31.5 ^ 2 + 21 ^ 2)), CFrame.new(x, F1 + 14.6, zStart - 15.75) * CFrame.Angles(th, 0, 0), T.trim, DECO)
	end
end

---------------------------------------------------------------- stair kit
-- Proper staircases (blocky PS2 style): solid steps with nosings, a guard on every open side (a solid half wall
-- with a cap = S.kind "parapet", or stringer + balusters + handrail = "balusters"), chunky end posts, a handrail
-- on the wall sides, and guards round the opening in the upper floor. maps/stairs.luau (the stair pass) puts them
-- into the maps; `stairs` above is the old plain flight the map files still call (the pass replaces it).
-- S = { step = style, trim = style, wall = style, kind = "parapet" | "balusters" }
local RISE, TREAD, GUARD_H = 1, 1.5, 3.5

-- n treads rising along cf's -Z. cf = the foot of the first riser (centre of the width, at the floor it starts
-- from); the steps are solid down to `down` studs below cf.
local function flight(m, cf, w, n, S, down)
	for i = 1, n do
		local h = i * RISE + down
		b(m, cf, "Step", w, h, TREAD, 0, i * RISE - h / 2, -(i - 0.5) * TREAD, S.step)
		b(m, cf, "Nosing", w + 0.02, 0.22, 0.5, 0, i * RISE - 0.08, -(i - 1) * TREAD + 0.1, S.trim, DECO)
	end
end

-- an end post standing on `p` (a point on the walking surface)
local function newel(m, p, S, sink)
	sink = sink or 0.2
	local body = S.kind == "parapet" and S.wall or S.trim
	part(m, "Newel", Vector3.new(1, GUARD_H + 0.9 + sink, 1), CFrame.new(p + Vector3.new(0, (GUARD_H + 0.9 - sink) / 2, 0)), body)
	part(m, "NewelCap", Vector3.new(1.4, 0.4, 1.4), CFrame.new(p + Vector3.new(0, GUARD_H + 1.1, 0)), S.trim)
end

-- a guard along the straight run a -> b. a and b are points on the walking surface: on a flight, the line through
-- the tread nosings (the guard then also covers the step ends below that line).
local function guard(m, a, bb, S)
	local d = bb - a
	local len = d.Magnitude
	if len < 0.1 then return end
	local flat = Vector3.new(d.X, 0, d.Z)
	local cosA = flat.Magnitude / len
	local sloped = cosA < 0.999
	local mid = (a + bb) / 2
	local cf = CFrame.lookAt(mid, mid + d)
	if S.kind == "parapet" then
		local below = sloped and 1.15 or 0
		part(m, "Parapet", Vector3.new(0.7, (GUARD_H + below) * cosA, len), cf * CFrame.new(0, (GUARD_H - below) / 2 * cosA, 0), S.wall)
		part(m, "Handrail", Vector3.new(1.05, 0.32, len + 0.1), cf * CFrame.new(0, (GUARD_H + 0.16) * cosA, 0), S.trim)
	else
		local below = sloped and 1.2 or 0
		part(m, "Stringer", Vector3.new(0.5, (below + 0.4) * cosA, len), cf * CFrame.new(0, (0.4 - below) / 2 * cosA, 0), S.trim)
		part(m, "Handrail", Vector3.new(0.7, 0.45, len + 0.1), cf * CFrame.new(0, GUARD_H * cosA, 0), S.trim)
		part(m, "MidRail", Vector3.new(0.3, 0.3, len), cf * CFrame.new(0, GUARD_H * 0.5 * cosA, 0), S.trim)
		local n = math.max(1, math.floor(flat.Magnitude / 1.5 + 0.5))
		local yaw = CFrame.lookAt(Vector3.zero, flat.Unit)
		for i = 1, n - 1 do
			local p = a + d * (i / n)
			part(m, "Baluster", Vector3.new(0.32, GUARD_H, 0.32), CFrame.new(p + Vector3.new(0, GUARD_H / 2 + 0.1, 0)) * yaw, S.trim, DECO)
		end
	end
end

-- a handrail on a wall along a -> b (nosing line), `out` = unit vector from the wall into the stair
local function wallRail(m, a, bb, S, out)
	local d = bb - a
	local len = d.Magnitude
	local cosA = Vector3.new(d.X, 0, d.Z).Magnitude / len
	local mid = (a + bb) / 2 + out * 0.5
	local cf = CFrame.lookAt(mid, mid + d)
	part(m, "Handrail", Vector3.new(0.4, 0.4, len), cf * CFrame.new(0, 3.1 * cosA, 0), S.trim, DECO)
	for _, t in { 0.06, 0.5, 0.94 } do
		local p = a + d * t + Vector3.new(0, 3.1 - 0.35, 0)
		part(m, "Bracket", Vector3.new(0.25, 0.5, 0.25), CFrame.new(p + out * 0.5), S.trim, DECO)
		part(m, "Bracket", Vector3.new(0.25, 0.25, 0.55), CFrame.lookAt(p + out * 0.25 + Vector3.new(0, -0.2, 0), p + out), S.trim, DECO)
	end
end

-- A HALF-TURN STAIR in its own well: flight 1 up to a landing at the far end, flight 2 back to the upper floor.
-- o.cf = the middle of the well's entry edge on the lower floor, looking INTO the well; o.W = well width, o.L = its
-- length (21); o.mir = 1: flight 1 on the right (looking in), -1: on the left. The upper floor is 21 above.
-- o.low / o.up = which sides are OPEN (no wall) on the lower / upper floor: a = flight 1's side, b = flight 2's
-- side, e = the far end. Returns the model and the opening to cut in the upper floor { x1, z1, x2, z2 }.
local function dogleg(parent, o)
	local m = model(parent, "Stairs")
	local cf, W, L, mir, S = o.cf, o.W, o.L or 21, o.mir or 1, o.S
	local low, up = o.low or {}, o.up or {}
	local TOP = 21
	local fw = (W - 0.7) / 2 -- flight 1; flight 2 is 0.7 wider and carries the guard between the two
	local w2 = W - fw
	local uA, uB = mir * W / 2, -mir * W / 2
	local uS = mir * (W / 2 - fw - 0.35)
	local function P(u, y, s) return (cf * CFrame.new(u, y, -s)).Position end
	local function V(u, s) return cf:VectorToWorldSpace(Vector3.new(u, 0, -s)) end
	flight(m, cf * CFrame.new(mir * (W / 2 - fw / 2), 0, -TREAD), fw, 9, S, 0)
	b(m, cf, "Landing", W, 10, L - 15, 0, 5, -(15 + (L - 15) / 2), S.step)
	flight(m, cf * CFrame.new(-mir * (W / 2 - w2 / 2), 10, -15) * CFrame.Angles(0, math.pi, 0), w2, 10, S, 10)
	-- the solid under flight 2 and the landing is faced like a wall (S.wall, a skirting of S.wain) wherever it shows
	local function face(u, out, skirt)
		for j = 1, 10 do b(m, cf, "Facing", 0.12, 10 + j, TREAD, u + out * 0.06, (10 + j) / 2, -(15 - (j - 0.5) * TREAD), S.wall, DECO) end
		b(m, cf, "Facing", 0.12, 10, L - 15, u + out * 0.06, 5, -(15 + (L - 15) / 2), S.wall, DECO)
		if skirt then
			b(m, cf, "Wainscot", 0.14, 4.5, L, u + out * 0.19, 2.25, -L / 2, S.wain or S.trim, DECO)
			b(m, cf, "Skirting", 0.2, 0.9, L, u + out * 0.3, 0.45, -L / 2, S.trim, DECO)
		end
	end
	face(uS + mir * 0.35, mir, false)
	if low.b then
		face(uB, -mir, true)
		-- its end toward the room
		local uc = -mir * (W / 2 - w2 / 2)
		b(m, cf, "Facing", w2 + 0.24, 20, 0.12, uc - mir * 0.12, 10, 0.06, S.wall, DECO)
		b(m, cf, "Wainscot", w2 + 0.4, 4.5, 0.14, uc - mir * 0.2, 2.25, 0.19, S.wain or S.trim, DECO)
		b(m, cf, "Skirting", w2 + 0.5, 0.9, 0.2, uc - mir * 0.25, 0.45, 0.3, S.trim, DECO)
	end
	-- between the flights
	guard(m, P(uS, 11, 15), P(uS, TOP, 0), S)
	newel(m, P(uS, 10, 15.2), S)
	newel(m, P(uS, TOP, -0.35), S, 1.4)
	-- flight 1's outer side and the landing beside it
	local ia = uA - mir * 0.35
	if low.a then
		guard(m, P(ia, 1, 1.5), P(ia, 10, 15), S)
		guard(m, P(ia, 10, 15), P(ia, 10, L), S)
		newel(m, P(ia, 0, 1.1), S)
		newel(m, P(ia, 10, 15), S, 1.3)
	else
		wallRail(m, P(uA, 1, 1.5), P(uA, 10, 15), S, V(-mir, 0).Unit)
	end
	-- flight 2's outer side
	local ib = uB + mir * 0.2 -- its outer face a hair proud of the facing below
	if low.b then
		guard(m, P(ib, 11, 15), P(ib, TOP, 0), S)
		guard(m, P(ib, 10, 15), P(ib, 10, L), S)
		newel(m, P(ib, 10, 15), S, 1.3)
	else
		wallRail(m, P(uB, 11, 15), P(uB, TOP, 0), S, V(mir, 0).Unit)
	end
	if low.e then guard(m, P(uB, 10, L - 0.35), P(uA, 10, L - 0.35), S) end
	-- the opening in the upper floor: over flight 1's lane at the entry edge, and every open side
	guard(m, P(uS, TOP, -0.35), P(uA, TOP, -0.35), S)
	if up.a then
		guard(m, P(uA + mir * 0.35, TOP, -0.35), P(uA + mir * 0.35, TOP, L + (up.e and 0.35 or 0)), S)
		newel(m, P(uA + mir * 0.35, TOP, -0.35), S)
	else
		newel(m, P(uA - mir * 0.6, TOP, -0.35), S)
	end
	if up.b then
		guard(m, P(uB - mir * 0.35, TOP, 0), P(uB - mir * 0.35, TOP, L + (up.e and 0.35 or 0)), S)
		newel(m, P(uB - mir * 0.35, TOP, -0.1), S)
	end
	if up.e then
		guard(m, P(uB - (up.b and mir * 0.35 or 0), TOP, L + 0.35), P(uA + (up.a and mir * 0.35 or 0), TOP, L + 0.35), S)
		if up.b then newel(m, P(uB - mir * 0.35, TOP, L + 0.35), S) end
		if up.a then newel(m, P(uA + mir * 0.35, TOP, L + 0.35), S) end
	end
	local c1, c2 = P(-W / 2, 0, 0), P(W / 2, 0, L)
	return m, { math.min(c1.X, c2.X), math.min(c1.Z, c2.Z), math.max(c1.X, c2.X), math.max(c1.Z, c2.Z) }
end

-- A STRAIGHT GRAND STAIR with a landing half way: 10 treads, a landing, 10 treads (36 studs long, 21 up).
-- o.cf = the foot (centre of the width), looking up the stair; o.w = width. Guards on both sides.
local function grandStair(parent, o)
	local m = model(parent, "Stairs")
	local cf, w, S = o.cf, o.w, o.S
	local LD = o.landing or 6
	local function P(u, y, s) return (cf * CFrame.new(u, y, -s)).Position end
	flight(m, cf, w, 10, S, 0)
	b(m, cf, "Landing", w, 10, LD, 0, 5, -(15 + LD / 2), S.step)
	flight(m, cf * CFrame.new(0, 10, -(15 + LD)), w, 10, S, 10)
	for _, sx in { -1, 1 } do
		-- the sides of the solid are panelled (S.wain), not left in the tread's material
		local fu = sx * (w / 2 + 0.06)
		for i = 1, 10 do
			b(m, cf, "Facing", 0.12, i, TREAD, fu, i / 2, -(i - 0.5) * TREAD, S.wain or S.wall, DECO)
			b(m, cf, "Facing", 0.12, 10 + i, TREAD, fu, (10 + i) / 2, -(15 + LD + (i - 0.5) * TREAD), S.wain or S.wall, DECO)
		end
		b(m, cf, "Facing", 0.12, 10, LD, fu, 5, -(15 + LD / 2), S.wain or S.wall, DECO)
		b(m, cf, "Skirting", 0.2, 0.9, 30 + LD, sx * (w / 2 + 0.2), 0.45, -(30 + LD) / 2, S.trim, DECO)
		local u = sx * (w / 2 - 0.2)
		guard(m, P(u, 1, 0), P(u, 10, 13.5), S)
		guard(m, P(u, 10, 13.5), P(u, 10, 15 + LD), S)
		guard(m, P(u, 11, 15 + LD), P(u, 21, 30 + LD), S)
		newel(m, P(u, 0, -0.4), S)
		newel(m, P(u, 10, 13.5), S, 1.3)
		newel(m, P(u, 10, 15 + LD), S, 1.3)
		newel(m, P(u, 21, 30 + LD + 0.4), S, 1.4)
	end
	if o.runner then -- a carpet runner down the middle
		local rw = w * 0.5
		for i = 1, 10 do
			b(m, cf, "Runner", rw, 0.08, TREAD + 0.05, 0, i * RISE + 0.04, -(i - 0.5) * TREAD, o.runner, DECO)
			b(m, cf * CFrame.new(0, 10, -(15 + LD)), "Runner", rw, 0.08, TREAD + 0.05, 0, i * RISE + 0.04, -(i - 0.5) * TREAD, o.runner, DECO)
		end
		b(m, cf, "Runner", rw, 0.08, LD, 0, 10.04, -(15 + LD / 2), o.runner, DECO)
	end
	return m
end

-- a railing along a balcony edge (along "x" or "z")
local function railing(along, fixed, a1, a2, y)
	local rl = model(STR, "Railing")
	if along == "x" then
		box(rl, "Rail", a1, y + 3.4, fixed - 0.3, a2, y + 3.9, fixed + 0.3, T.trim)
		for x = a1, a2, 1.4 do box(rl, "Baluster", x - 0.15, y, fixed - 0.15, x + 0.15, y + 3.4, fixed + 0.15, T.trim, DECO) end
	else
		box(rl, "Rail", fixed - 0.3, y + 3.4, a1, fixed + 0.3, y + 3.9, a2, T.trim)
		for z = a1, a2, 1.4 do box(rl, "Baluster", fixed - 0.15, y, z - 0.15, fixed + 0.15, y + 3.4, z + 0.15, T.trim, DECO) end
	end
end

---------------------------------------------------------------- lights
local function fluoro(x, y, z, color)
	local m = model(LIT, "Fluorescent")
	local cf = CFrame.new(x, y, z)
	b(m, cf, "Housing", 2.4, 0.4, 7, 0, -0.2, 0, T.iron, DECO)
	local g = b(m, cf, "Tube", 1.6, 0.3, 6.4, 0, -0.5, 0, st(M.Neon, nil, color or Color3.fromRGB(220, 245, 230)), DECO)
	local l = light(g, 30, 1.2, color or Color3.fromRGB(200, 240, 225))
	l:SetAttribute("Flicker", true)
end
local function bulb(x, y, z, len, color)
	local m = model(LIT, "Bulb")
	local cf = CFrame.new(x, y, z)
	cyl(m, cf, "Cord", 0.15, len, 0, -len / 2, 0, T.iron, DECO)
	cyl(m, cf, "Shade", 2, 1, 0, -len - 0.4, 0, T.lampShade or T.iron, DECO)
	local g = ball(m, cf, "Glow", 0.7, 0, -len - 0.9, 0, st(M.Neon, nil, color or Color3.fromRGB(255, 200, 140)), DECO)
	light(g, 30, 1.3, color)
end
local function sconce(x, y, z, face, color)
	local m = model(LIT, "Sconce")
	local cf = at(x, y, z, face)
	b(m, cf, "Plate", 0.9, 1.4, 0.2, 0, 0, 0.1, T.brass, DECO)
	cyl(m, cf, "Shade", 1.1, 1, 0, 0.4, -0.7, T.lampShade or T.shade, DECO)
	local g = ball(m, cf, "Bulb", 0.45, 0, 0.3, -0.7, st(M.Neon, nil, color or Color3.fromRGB(255, 190, 120)), DECO)
	light(g, 18, 1.1, color)
end
local function candles(x, y, z)
	local m = model(LIT, "Candles")
	local cf = CFrame.new(x, y, z)
	cyl(m, cf, "Stand", 0.4, 4, 0, 2, 0, T.brass, DECO)
	b(m, cf, "Foot", 1.4, 0.3, 1.4, 0, 0.15, 0, T.brass, DECO)
	for i = -1, 1 do
		cyl(m, cf, "Candle", 0.35, 1, i * 0.7, 4.5, 0, st(M.SmoothPlastic, nil, Color3.fromRGB(235, 225, 200)), DECO)
		ball(m, cf, "Flame", 0.3, i * 0.7, 5.15, 0, T.glow, DECO)
	end
	local g = ball(m, cf, "Core", 0.3, 0, 5.2, 0, T.glow, { t = 1, deco = true })
	light(g, 22, 1, Color3.fromRGB(255, 170, 90))
end

---------------------------------------------------------------- decor
local function sign(parent, text, cf, w, h, bg, fg, font, face, pps)
	local p = part(parent, "Sign", Vector3.new(w, h, 0.4), cf, bg, DECO)
	local sg = Instance.new("SurfaceGui"); sg.Face = face or Enum.NormalId.Front; sg.LightInfluence = 0.2
	sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; sg.PixelsPerStud = pps or 12; sg.Brightness = 1.5; sg.Parent = p
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Size = UDim2.fromScale(1, 1); t.TextScaled = true
	t.Font = font or Enum.Font.SpecialElite; t.Text = text; t.TextColor3 = fg; t.TextStrokeTransparency = 0.5; t.Parent = sg
	return p
end
-- a flat poster / painting on a wall (face = which way it looks)
local function poster(x, y, z, face, w, h, color, frame)
	local m = model(DEC, "Poster")
	local cf = at(x, y, z, face)
	if frame then b(m, cf, "Frame", w + 0.8, h + 0.8, 0.3, 0, 0, 0.15, frame, DECO) end
	b(m, cf, "Canvas", w, h, 0.1, 0, 0, -0.05, st(M.SmoothPlastic, nil, color), DECO)
	return m
end
local function rug(x1, z1, x2, z2, y, s, border)
	if border then box(DEC, "RugBorder", x1 - 0.6, y, z1 - 0.6, x2 + 0.6, y + 0.1, z2 + 0.6, border, DECO) end
	box(DEC, "Rug", x1, y + 0.05, z1, x2, y + 0.16, z2, s, DECO)
end
local function blood(x, y, z, r)
	local p = part(DEC, "Blood", Vector3.new(0.05, r * 2, r * 2.4), CFrame.new(x, y + 0.08, z) * CFrame.Angles(0, math.random() * 6, math.pi / 2),
		st(M.SmoothPlastic, nil, Color3.fromRGB(70, 6, 6)), { shape = Enum.PartType.Cylinder, deco = true, t = 0.15 })
	return p
end

---------------------------------------------------------------- new furniture
local Steel = st(M.Metal, nil, Color3.fromRGB(170, 172, 176))
local Rust = st(M.CorrodedMetal, nil, Color3.fromRGB(120, 90, 70))
local Sheet = st(M.Fabric, nil, Color3.fromRGB(215, 218, 210))
local G2 = {}
function G2.hospitalBed(cf, iron)
	local fr = iron and Rust or Steel
	local m = new("HospitalBed")
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do b(m, cf, "Leg", 0.3, 2, 0.3, sx * 1.8, 1, sz * 3.6, fr) end end
	b(m, cf, "Frame", 4, 0.4, 8, 0, 2.1, 0, fr)
	b(m, cf, "Mattress", 3.6, 0.8, 7.4, 0, 2.7, 0, Sheet)
	b(m, cf, "Pillow", 2.6, 0.5, 1.4, 0, 3.3, 3, Sheet)
	b(m, cf, "Head", 4, 3.6, 0.3, 0, 3.2, 4, fr)
	b(m, cf, "Foot", 4, 2.4, 0.3, 0, 2.6, -4, fr)
	for _, sx in { -1, 1 } do b(m, cf, "Rail", 0.15, 0.15, 4, sx * 2, 3.6, 1, fr, DECO) end
	return finalize(m, 4, "HospitalBed")
end
function G2.gurney(cf)
	local m = new("Gurney")
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do
		b(m, cf, "Leg", 0.2, 2.6, 0.2, sx * 1.2, 1.5, sz * 2.8, Steel)
		ball(m, cf, "Wheel", 0.4, sx * 1.2, 0.2, sz * 2.8, Blk, DECO)
	end end
	b(m, cf, "Top", 2.8, 0.3, 6.6, 0, 2.9, 0, Steel)
	b(m, cf, "Sheet", 2.6, 0.3, 6.2, 0, 3.15, 0, Sheet)
	b(m, cf, "Body", 1.4, 0.7, 4.4, 0, 3.6, -0.6, Sheet, DECO)
	return finalize(m, 3, "Gurney")
end
function G2.wheelchair(cf)
	local m = new("Wheelchair")
	b(m, cf, "Seat", 2, 0.25, 2, 0, 2.1, 0, st(M.Fabric, nil, Color3.fromRGB(40, 40, 44)))
	b(m, cf, "Back", 2, 2.2, 0.2, 0, 3.3, 1, st(M.Fabric, nil, Color3.fromRGB(40, 40, 44)))
	for _, sx in { -1.2, 1.2 } do
		cyl(m, cf, "Wheel", 2.8, 0.2, sx, 1.4, 0.4, Steel).CFrame = cf * CFrame.new(sx, 1.4, 0.4)
		b(m, cf, "Arm", 0.2, 0.2, 1.8, sx * 0.85, 3, 0, Steel, DECO)
	end
	b(m, cf, "Footrest", 1.6, 0.15, 0.8, 0, 0.6, -1.3, Steel, DECO)
	return finalize(m, 2, "Wheelchair")
end
function G2.locker(cf, color)
	local m = new("Locker")
	local s = st(M.Metal, nil, color or Color3.fromRGB(70, 90, 110))
	b(m, cf, "Body", 2.4, 7.5, 2.2, 0, 3.75, 0, s)
	b(m, cf, "Door", 2.1, 7, 0.1, 0, 3.75, -1.12, s, DECO)
	for i = 0, 3 do b(m, cf, "Vent", 1.2, 0.12, 0.1, 0, 6.6 - i * 0.3, -1.2, Blk, DECO) end
	b(m, cf, "Handle", 0.2, 0.7, 0.2, 0.7, 3.8, -1.25, Steel, DECO)
	return finalize(m, 3, "Locker")
end
function G2.schoolDesk(cf)
	local m = new("SchoolDesk")
	local top = st(M.Wood, nil, Color3.fromRGB(160, 120, 80))
	for _, sx in { -1, 1 } do b(m, cf, "Leg", 0.2, 2.6, 0.2, sx * 1.4, 1.3, -0.5, Steel) end
	b(m, cf, "Top", 3.2, 0.25, 2, 0, 2.7, -0.5, top)
	b(m, cf, "Seat", 2.2, 0.2, 1.6, 0, 1.6, 1.3, top)
	b(m, cf, "SeatBack", 2.2, 1.4, 0.2, 0, 2.4, 2.1, top)
	for _, sx in { -1, 1 } do b(m, cf, "SeatLeg", 0.15, 1.6, 0.15, sx * 0.9, 0.8, 1.3, Steel) end
	return finalize(m, 1.5, "SchoolDesk")
end
function G2.pew(cf, w)
	w = w or 12
	local m = new("Pew")
	local s = Wd.dark
	b(m, cf, "Seat", w, 0.4, 2.2, 0, 1.9, 0, s)
	b(m, cf, "Back", w, 2.8, 0.3, 0, 3.3, 1, s)
	for _, x in { -w / 2 + 0.2, w / 2 - 0.2 } do b(m, cf, "End", 0.4, 4.4, 2.6, x, 2.2, 0.2, s) end
	return finalize(m, 4, "Pew")
end
function G2.altar(cf)
	local m = new("Altar")
	b(m, cf, "Block", 8, 3.6, 3, 0, 1.8, 0, T.stone)
	b(m, cf, "Cloth", 8.4, 0.2, 3.4, 0, 3.7, 0, st(M.Fabric, nil, Color3.fromRGB(110, 20, 24)))
	b(m, cf, "ClothFront", 4, 2.6, 0.1, 0, 2.5, -1.75, st(M.Fabric, nil, Color3.fromRGB(110, 20, 24)), DECO)
	b(m, cf, "Cross", 0.4, 3, 0.4, 0, 5.3, 0.5, T.brass, DECO)
	b(m, cf, "CrossBar", 1.6, 0.4, 0.4, 0, 5.9, 0.5, T.brass, DECO)
	return finalize(m, 6, "Altar")
end
function G2.coffin(cf, open)
	local m = new("Coffin")
	local s = st(M.Wood, nil, Color3.fromRGB(60, 34, 26))
	b(m, cf, "Box", 3, 2, 7.5, 0, 2.6, 0, s)
	b(m, cf, "Lining", 2.5, 0.2, 7, 0, 3.55, 0, st(M.Fabric, nil, Color3.fromRGB(170, 30, 40)), DECO)
	if open then
		b(m, cf, "Lid", 3, 0.3, 3.8, 0, 4.9, 1.7, s).CFrame = cf * CFrame.new(1.7, 4.4, 1.7) * CFrame.Angles(0, 0, -1.2)
	else
		b(m, cf, "Lid", 3.1, 0.3, 7.6, 0, 3.75, 0, s)
	end
	for _, z in { -3, 3 } do b(m, cf, "Handle", 3.3, 0.2, 0.3, 0, 2.6, z, T.brass, DECO) end
	b(m, cf, "Trestle", 2.4, 1.6, 6, 0, 0.8, 0, Wd.mid)
	return finalize(m, 4, "Coffin")
end
function G2.steelTable(cf)
	local m = new("SteelTable")
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do b(m, cf, "Leg", 0.3, 3, 0.3, sx * 1.4, 1.5, sz * 3, Steel) end end
	b(m, cf, "Top", 3.4, 0.25, 7, 0, 3.1, 0, Steel)
	b(m, cf, "Drain", 0.6, 0.1, 0.6, 0, 3.25, -3, Blk, DECO)
	return finalize(m, 3, "SteelTable")
end
function G2.bunk(cf)
	local m = new("Bunk")
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do b(m, cf, "Post", 0.3, 7, 0.3, sx * 1.6, 3.5, sz * 3.6, Rust) end end
	for _, y in { 1.8, 5 } do
		b(m, cf, "Frame", 3.4, 0.3, 7.4, 0, y, 0, Rust)
		b(m, cf, "Mattress", 3, 0.6, 7, 0, y + 0.45, 0, st(M.Fabric, nil, Color3.fromRGB(110, 120, 100)))
	end
	return finalize(m, 4, "Bunk")
end
function G2.vending(cf, color)
	local m = new("VendingMachine")
	b(m, cf, "Body", 4, 8, 3, 0, 4, 0, st(M.SmoothPlastic, nil, color or Color3.fromRGB(160, 30, 30)))
	local g = b(m, cf, "Window", 2.6, 5, 0.1, -0.4, 4.8, -1.55, st(M.Neon, nil, Color3.fromRGB(200, 220, 255)), { deco = true, t = 0.4 })
	light(g, 14, 0.7, Color3.fromRGB(200, 220, 255))
	b(m, cf, "Slot", 0.8, 1.4, 0.1, 1.5, 4.4, -1.55, Blk, DECO)
	return finalize(m, 5, "VendingMachine")
end
function G2.hay(cf)
	local m = new("HayBale")
	b(m, cf, "Bale", 4, 2.4, 2.6, 0, 1.2, 0, st(M.Grass, nil, Color3.fromRGB(200, 170, 90)))
	for _, x in { -1.2, 1.2 } do b(m, cf, "Twine", 0.15, 2.5, 2.7, x, 1.2, 0, st(M.Fabric, nil, Color3.fromRGB(120, 90, 50)), DECO) end
	return finalize(m, 2, "HayBale")
end
function G2.workbench(cf, w)
	w = w or 8
	local m = new("Workbench")
	for _, sx in { -1, 1 } do for _, sz in { -1, 1 } do b(m, cf, "Leg", 0.5, 3.4, 0.5, sx * (w / 2 - 0.4), 1.7, sz * 1.2, Wd.dark) end end
	b(m, cf, "Top", w, 0.4, 3, 0, 3.6, 0, Wd.plank)
	b(m, cf, "Shelf", w - 0.6, 0.3, 2.6, 0, 1, 0, Wd.plank)
	for i = 1, 3 do b(m, cf, "Tool", rng:NextNumber(0.3, 0.8), 0.25, rng:NextNumber(1, 2), rng:NextNumber(-w / 2 + 1, w / 2 - 1), 3.95, rng:NextNumber(-0.8, 0.8), Steel, DECO) end
	return finalize(m, 4, "Workbench")
end
-- a doll (decor or on shelves): porcelain head, dress, glassy black eyes
local function doll(parent, cf, scale, dress)
	local s = scale or 1
	b(parent, cf, "DollDress", 0.9 * s, 1.2 * s, 0.7 * s, 0, 0.6 * s, 0, st(M.Fabric, nil, dress or Color3.fromRGB(150, 60, 80)), DECO)
	ball(parent, cf, "DollHead", 0.8 * s, 0, 1.6 * s, 0, Por, DECO)
	for _, x in { -0.16, 0.16 } do ball(parent, cf, "DollEye", 0.16 * s, x * s, 1.65 * s, -0.36 * s, Blk, DECO) end
	b(parent, cf, "DollHair", 0.85 * s, 0.35 * s, 0.85 * s, 0, 1.95 * s, 0.05 * s, st(M.SmoothPlastic, nil, Color3.fromRGB(60, 36, 20)), DECO)
end
function G2.dollShelf(cf)
	local m = new("DollShelf")
	b(m, cf, "Back", 7, 8, 0.3, 0, 4, 0.85, Wd.mid)
	for i = 0, 3 do
		local y = 0.4 + i * 2.4
		b(m, cf, "Shelf", 7, 0.25, 1.8, 0, y, 0, Wd.mid)
		if i < 3 then for x = -2.6, 2.6, 1.3 do doll(m, cf * CFrame.new(x, y + 0.12, 0), 0.75, Color3.fromHSV(rng:NextNumber(), 0.5, 0.6)) end end
	end
	for _, x in { -3.4, 3.4 } do b(m, cf, "Side", 0.3, 8, 1.8, x, 4, 0, Wd.mid) end
	return finalize(m, 3, "DollShelf")
end
function G2.luggageCart(cf)
	local m = new("LuggageCart")
	b(m, cf, "Base", 3, 0.3, 5, 0, 0.8, 0, T.brass)
	for _, sz in { -1, 1 } do for _, sx in { -1, 1 } do ball(m, cf, "Wheel", 0.6, sx * 1.2, 0.3, sz * 2, Blk, DECO) end end
	part(m, "Arch", Vector3.new(0.3, 6, 0.3), cf * CFrame.new(-1.4, 3.9, 0), T.brass)
	part(m, "Arch", Vector3.new(0.3, 6, 0.3), cf * CFrame.new(1.4, 3.9, 0), T.brass)
	b(m, cf, "Top", 3.1, 0.3, 0.3, 0, 6.9, 0, T.brass)
	b(m, cf, "Suitcase", 2.4, 1.6, 1.2, 0, 1.75, -1.4, st(M.Leather, nil, Color3.fromRGB(90, 50, 34)))
	b(m, cf, "Suitcase", 2, 1.4, 1, 0, 1.65, 1.2, st(M.Leather, nil, Color3.fromRGB(50, 60, 80)))
	return finalize(m, 3, "LuggageCart")
end
function G2.confessional(cf)
	local m = new("Confessional")
	b(m, cf, "Booth", 7, 9, 4, 0, 4.5, 0, Wd.dark)
	b(m, cf, "Roof", 7.6, 0.6, 4.6, 0, 9.3, 0, Wd.dark)
	for _, x in { -1.8, 1.8 } do b(m, cf, "Curtain", 2.6, 7, 0.1, x, 3.6, -2.05, st(M.Fabric, nil, Color3.fromRGB(100, 20, 26)), DECO) end
	return finalize(m, 7, "Confessional")
end
