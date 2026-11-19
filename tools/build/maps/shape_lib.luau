-- SHAPE LIB (2026-11-19, the user: "every building is the same house"): give each building its own shape.
-- Prepend after lib2 + furn_lib + maplib (and before the map's own lib):
--   cat tools/build/lib2.luau tools/build/furn_lib.luau tools/build/maplib.luau tools/build/maps/shape_lib.luau \
--       tools/build/maps/camp_lib.luau tools/build/maps/camp_barn.luau
-- What it adds:
--   wallL      a wall along ANY line (x1,z1)->(x2,z2) with windows / doors (maplib's `wall` only runs along x or z)
--   ring       the corners of a regular n-gon / ellipse whose FRONT edge faces +Z (the yard) centred on x = 0
--   polyFloor  a convex polygon floor (strips along x); polyWalls = the outside walls round a polygon
--   tri        a triangle of any shape (two wedges): roofs, gables, domes
--   extrude    a roof profile (z, y points) run along x: gable, A-frame, gambrel, saltbox, barrel - with gable ends
--   coneRoof / domeRoof over a polygon, spire (a thin cone), tower (an n-sided prism)
--   shell2     like maplib's `shell` but its footprint, height, roof and entrance are the building's own; no shared
--              porch, no floodlights (each building lights its own front)
--   footprint  invisible boxes over a non-box floor (MAP.Footprint: Server/Ghost brings a monster back inside)
-- Rules kept from the old shell: the front door is at x = 0 on the front (z ~ 59), the ground floor is y = 2 (F1),
-- the outside walls of the fight space are in Structure.Exterior (Ghost.houseBounds measures them: towers and roofs
-- go elsewhere), and the yard is z > 52.

---------------------------------------------------------------- a wall along any line
-- the frame of a wall from (x1, z1) to (x2, z2): local -Z runs along it, +X is the right-hand side
local function segCF(x1: number, z1: number, x2: number, z2: number): (CFrame, number)
	local a, bb = Vector3.new(x1, 0, z1), Vector3.new(x2, 0, z2)
	return CFrame.lookAt(a, bb), (bb - a).Magnitude
end
-- a box in a wall frame: s along (from the start), y up, d across (+ = right)
local function boxW(m, name, cf, s1, y1, d1, s2, y2, d2, sty, o)
	return part(m, name, Vector3.new(math.max(0.05, math.abs(d2 - d1)), math.max(0.05, math.abs(y2 - y1)), math.max(0.05, math.abs(s2 - s1))),
		cf * CFrame.new((d1 + d2) / 2, (y1 + y2) / 2, -(s1 + s2) / 2), sty, o)
end

local function openingL(m, cf, op, y0, th)
	local o1, o2 = op.c - op.w / 2, op.c + op.w / 2
	local d, TR = th / 2 + 0.6, 0.6
	local trim = op.trim or T.trim
	if op.kind ~= "hole" then
		boxW(m, "Frame", cf, o1 - TR, y0 + op.b, -d, o1, y0 + op.t + TR, d, trim)
		boxW(m, "Frame", cf, o2, y0 + op.b, -d, o2 + TR, y0 + op.t + TR, d, trim)
		boxW(m, "Frame", cf, o1 - TR, y0 + op.t, -d, o2 + TR, y0 + op.t + TR, d, trim)
	end
	if op.kind == "window" then
		boxW(m, "Sill", cf, o1 - 1, y0 + op.b - 0.4, -(d + 0.3), o2 + 1, y0 + op.b, d + 0.3, trim)
		boxW(m, "Glass", cf, o1, y0 + op.b, -0.1, o2, y0 + op.t, 0.1, op.glass or T.glass, { t = 0.35 })
		if not op.plain then
			boxW(m, "Mullion", cf, op.c - 0.2, y0 + op.b, -0.25, op.c + 0.2, y0 + op.t, 0.25, trim, DECO)
			local yy = y0 + op.b + (op.t - op.b) * 0.5
			boxW(m, "Mullion", cf, o1, yy - 0.2, -0.25, o2, yy + 0.2, 0.25, trim, DECO)
		end
	elseif op.kind == "double" then
		local inward, leafW = op.inward or 1, op.w / 2 - 0.1
		for _, hs in { { o1, o1 + 0.5 }, { o2 - 0.5, o2 } } do
			local d1, d2 = inward * (th / 2), inward * (th / 2 + leafW)
			boxW(m, "DoorLeaf", cf, hs[1], y0 + 0.05, math.min(d1, d2), hs[2], y0 + op.t - 0.1, math.max(d1, d2), T.door or T.wainscot)
		end
	end
end

-- style = { core, th, skins = { { side = +1|-1, s } }, wain = { sides } } (maplib's EXT / INT). ops: { c = distance
-- along from the start (or f = fraction of the length), w, b, t, kind = "window"|"open"|"double"|"hole" }
local function wallL(parent, name, x1, z1, x2, z2, y0, h, ops, style)
	local m = model(parent, name)
	local cf, len = segCF(x1, z1, x2, z2)
	local th = style.th
	local list = {}
	for _, op in ops or {} do
		local c = table.clone(op)
		if c.f then c.c = c.f * len end
		table.insert(list, c)
	end
	table.sort(list, function(p, q) return p.c < q.c end)
	local function seg(s1, s2, b1, b2)
		if s2 - s1 < 0.01 or b2 - b1 < 0.01 then return end
		boxW(m, "Wall", cf, s1, y0 + b1, -th / 2, s2, y0 + b2, th / 2, style.core)
		for _, sk in style.skins do
			local d1, d2 = sk.side * th / 2, sk.side * (th / 2 + 0.25)
			boxW(m, "Skin", cf, s1, y0 + b1, math.min(d1, d2), s2, y0 + b2, math.max(d1, d2), sk.s)
		end
		if b1 == 0 and style.wain then
			for _, side in style.wain do
				local base = th / 2 + 0.25
				local top = math.min(b2, T.wainH or 4.5)
				local d1, d2 = side * base, side * (base + 0.25)
				boxW(m, "Wainscot", cf, s1, y0, math.min(d1, d2), s2, y0 + top, math.max(d1, d2), T.wainscot, DECO)
			end
		end
	end
	local cur = 0
	for _, op in list do
		local o1, o2 = op.c - op.w / 2, op.c + op.w / 2
		seg(cur, o1, 0, h); seg(o1, o2, 0, op.b); seg(o1, o2, op.t, h)
		cur = o2
		openingL(m, cf, op, y0, th)
	end
	seg(cur, len, 0, h)
	return m, cf, len
end

---------------------------------------------------------------- polygons
-- n corners of an ellipse (rx across, rz deep) round (cx, cz), turned so that the FIRST edge (corner 1 -> 2) is the
-- front one, centred on x = cx and facing +Z
local RINGINFO = setmetatable({}, { __mode = "k" }) :: any
local function ring(cx: number, cz: number, rx: number, rz: number, n: number): { { number } }
	-- corners at angles pi/2 - pi/n + k * 2pi/n (x = cos, z = sin): the first edge is centred on +Z
	local pts = {}
	for k = 0, n - 1 do
		local a = math.pi / 2 - math.pi / n + k * 2 * math.pi / n
		table.insert(pts, { cx + rx * math.cos(a), cz + rz * math.sin(a) })
	end
	RINGINFO[pts] = { cx = cx, cz = cz, rx = rx, rz = rz, n = n }
	return pts
end

local function centroid(pts): Vector3
	local x, z = 0, 0
	for _, p in pts do x += p[1]; z += p[2] end
	return Vector3.new(x / #pts, 0, z / #pts)
end

-- the x range of a convex polygon at depth z (nil if z misses it)
local function spanAt(pts, z: number): (number?, number?)
	local lo, hi = math.huge, -math.huge
	for i, p in pts do
		local q = pts[i % #pts + 1]
		local z1, z2 = p[2], q[2]
		if (z >= math.min(z1, z2) - 1e-6) and (z <= math.max(z1, z2) + 1e-6) then
			if math.abs(z2 - z1) < 1e-6 then
				lo = math.min(lo, p[1], q[1]); hi = math.max(hi, p[1], q[1])
			else
				local x = p[1] + (q[1] - p[1]) * (z - z1) / (z2 - z1)
				lo = math.min(lo, x); hi = math.max(hi, x)
			end
		end
	end
	if lo > hi then return nil, nil end
	return lo, hi
end

-- a convex polygon slab from y1 to y2 in strips `step` deep along z. grow > 0: the strips reach that far past the
-- edges (a foundation under the walls); grow < 0: they stay that far inside (a floor inside the walls)
local function polyFloor(m, name, pts, y1, y2, sty, step, grow, o)
	step = step or 2
	grow = grow or 0
	local z0, z1 = math.huge, -math.huge
	for _, p in pts do z0 = math.min(z0, p[2]); z1 = math.max(z1, p[2]) end
	local first = nil
	local z = z0 - math.max(grow, 0)
	while z < z1 + math.max(grow, 0) - 0.01 do
		local zb = math.min(z + step, z1 + math.max(grow, 0))
		local l1, h1 = spanAt(pts, math.clamp(z, z0, z1))
		local l2, h2 = spanAt(pts, math.clamp(zb, z0, z1))
		local lm, hm = spanAt(pts, math.clamp((z + zb) / 2, z0, z1))
		if l1 and l2 and lm then
			local lo, hi
			if grow >= 0 then lo, hi = math.min(l1, l2, lm) - grow, math.max(h1, h2, hm) + grow
			else lo, hi = math.max(l1, l2, lm) - grow, math.min(h1, h2, hm) + grow end
			if hi - lo > 0.2 then
				local p = box(m, name, lo, y1, z, hi, y2, zb, sty, o)
				first = first or p
			end
		end
		z = zb
	end
	return first
end

-- the outside walls round a polygon: ops[i] = the openings of edge i (corner i -> i + 1); a post at every corner
-- covers the joint. style(inward) gives the wall style (EXT). Returns the model.
local function polyWalls(parent, pts, y0, h, ops, style, postSty, postW)
	local c = centroid(pts)
	for i, p in pts do
		local q = pts[i % #pts + 1]
		local cf = segCF(p[1], p[2], q[1], q[2])
		local l = cf:PointToObjectSpace(c)
		wallL(parent, "Wall" .. i, p[1], p[2], q[1], q[2], y0, h, ops and ops[i] or {}, style(l.X > 0 and 1 or -1))
		local pw = postW or 2.6
		box(parent, "CornerPost", p[1] - pw / 2, y0, p[2] - pw / 2, p[1] + pw / 2, y0 + h, p[2] + pw / 2, postSty or T.trim)
	end
	return parent
end

-- the floor of a polygon building, its foundation and its footprint (for Server/Ghost)
local function footprint(pts)
	local fp = MAP:FindFirstChild("Footprint")
	if not fp then fp = Instance.new("Folder"); fp.Name = "Footprint"; fp.Parent = MAP end
	polyFloor(fp, "Foot", pts, 0, 1, st(M.SmoothPlastic, nil, Color3.new(1, 0, 1)), 4, -1.4,
		{ deco = true, t = 1, noShadow = true })
end

---------------------------------------------------------------- triangles
-- triangle a, b, c (Vector3) as two wedges, `th` thick (centred on the plane)
local function tri(parent, name, a: Vector3, bb: Vector3, c: Vector3, sty, th, o)
	th = th or 1
	local ab, ac, bc = bb - a, c - a, c - bb
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	if abd > acd and abd > bcd then c, a = a, c elseif acd > bcd and acd > abd then a, bb = bb, a end
	ab, ac, bc = bb - a, c - a, c - bb
	if ac:Cross(ab).Magnitude < 1e-4 then return end
	local right = ac:Cross(ab).Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit
	local height = math.abs(ab:Dot(up))
	local l1, l2 = math.abs(ab:Dot(back)), math.abs(ac:Dot(back))
	local function wedge(size, cf)
		if size.Y < 0.05 or size.Z < 0.05 then return end
		local w = Instance.new("WedgePart")
		w.Name = name; w.Anchored = true; w.Size = size; w.CFrame = cf
		w.Color = sty.color; w.Material = sty.mat
		if sty.mv then w.MaterialVariant = sty.mv end
		w.TopSurface = Enum.SurfaceType.Smooth; w.BottomSurface = Enum.SurfaceType.Smooth
		if o then
			if o.t then w.Transparency = o.t end
			if o.deco then w.CanCollide = false; w.CanQuery = false; w.CanTouch = false end
			if o.noShadow then w.CastShadow = false end
		end
		w.Parent = parent
	end
	wedge(Vector3.new(th, height, l1), CFrame.fromMatrix((a + bb) / 2, right, up, back))
	wedge(Vector3.new(th, height, l2), CFrame.fromMatrix((a + c) / 2, -right, up, -back))
end
local function quad(parent, name, a, bb, c, d, sty, th, o)
	tri(parent, name, a, bb, c, sty, th, o)
	tri(parent, name, a, c, d, sty, th, o)
end

---------------------------------------------------------------- roofs
-- a flat panel from p to q (Vector3) run `len` along the unit axis e (centred on the p-q line's middle), th thick
local function panel(parent, name, p: Vector3, q: Vector3, e: Vector3, len: number, sty, th, o)
	local d = q - p
	local segLen = d.Magnitude
	if segLen < 0.05 then return end
	d = d / segLen
	local n = d:Cross(e)
	return part(parent, name, Vector3.new(len, th or 1.2, segLen), CFrame.fromMatrix((p + q) / 2, e, n, d), sty, o)
end

-- a roof profile (a list of { u, y } across the building, eave to eave) extruded from a1 to a2: along x (u = z,
-- o.axis = "x", the default) or along z (u = x, o.axis = "z": the gables face the front and the back). The gable
-- ends are filled (o.ends = style, false = open) at o.endsAt (default: 1 stud inside a1 and a2, the middle of the end
-- walls), from o.endProf (the profile without its overhang). o.th = thickness, o.over = overhang past a1 / a2.
-- Panels go in `parent`, the gable ends in o.endParent (they are wall: Structure).
local function extrude(parent, a1: number, a2: number, prof, sty, o)
	o = o or {}
	local th, over = o.th or 1.2, o.over or 1.5
	local alongZ = o.axis == "z"
	local e = alongZ and Vector3.new(0, 0, 1) or Vector3.new(1, 0, 0)
	local function P(u: number, y: number, a: number): Vector3
		if alongZ then return Vector3.new(u, y, a) end
		return Vector3.new(a, y, u)
	end
	local c, len = (a1 + a2) / 2, (a2 - a1) + over * 2
	for i = 1, #prof - 1 do
		local p, q = prof[i], prof[i + 1]
		panel(parent, o.name or "RoofPanel", P(p[1], p[2], c), P(q[1], q[2], c), e, len, sty, th, o.panelO)
	end
	if o.ends ~= false then
		local ep = o.endParent or parent
		local ep2 = o.endProf or prof
		local base = math.min(ep2[1][2], ep2[#ep2][2])
		local uA, uB = ep2[1][1], ep2[#ep2][1]
		for _, a in o.endsAt or { a1 + 1, a2 - 1 } do
			-- fan from the middle of the base line (fine for convex profiles: gable, gambrel, A-frame, barrel)
			local mid = P((uA + uB) / 2, base, a)
			for i = 1, #ep2 - 1 do
				local p, q = ep2[i], ep2[i + 1]
				tri(ep, "Gable", mid, P(p[1], p[2], a), P(q[1], q[2], a), o.ends or T.ext, 2)
			end
		end
	end
end

-- a hip roof over a box: four slopes up to a ridge along x (the short ends slope too)
local function hipRoof(parent, x0: number, x1: number, z0: number, z1: number, top: number, rise: number, over: number, sty, th: number?)
	local hz = (z1 - z0) / 2
	local cz = (z0 + z1) / 2
	local inset = math.min(hz, (x1 - x0) / 2 - 1)
	local k = rise / hz
	local yE = top - over * k
	local A = Vector3.new(x0 - over, yE, z1 + over)
	local B = Vector3.new(x1 + over, yE, z1 + over)
	local C = Vector3.new(x1 + over, yE, z0 - over)
	local D = Vector3.new(x0 - over, yE, z0 - over)
	local R1 = Vector3.new(x0 + inset, top + rise, cz)
	local R2 = Vector3.new(x1 - inset, top + rise, cz)
	quad(parent, "RoofPanel", A, B, R2, R1, sty, th or 1.2)
	quad(parent, "RoofPanel", C, D, R1, R2, sty, th or 1.2)
	tri(parent, "RoofPanel", D, A, R1, sty, th or 1.2)
	tri(parent, "RoofPanel", B, C, R2, sty, th or 1.2)
	return R1, R2
end

-- common profiles (z from front +Z to back -Z), the eaves at y = top on z = +-hz
local function gableProf(hz: number, top: number, rise: number, over: number?)
	over = over or 3
	local k = rise / hz
	return { { hz + over, top - k * over }, { 0, top + rise }, { -hz - over, top - k * over } }
end
local function gambrelProf(hz: number, top: number, low: number, high: number, over: number?)
	-- low: rise of the steep lower slope (it comes in 30% of the half-width), high: the rise of the upper one
	over = over or 2
	local kz = hz * 0.32
	return { { hz + over, top - over * low / kz }, { hz - kz, top + low }, { 0, top + low + high }, { -(hz - kz), top + low }, { -hz - over, top - over * low / kz } }
end
local function arcProf(hz: number, top: number, rise: number, n: number)
	-- a barrel vault: an elliptic arc from z = hz to -hz, `rise` above the eaves
	local pr = {}
	for k = 0, n do
		local a = math.pi * k / n
		table.insert(pr, { hz * math.cos(a), top + rise * math.sin(a) })
	end
	return pr
end

-- a cone over a polygon (corners at y = base, pushed `over` outward) to the apex
local function coneRoof(parent, pts, base: number, apex: Vector3, sty, over: number?, th: number?, stripe)
	local c = centroid(pts)
	over = over or 3
	local n = #pts
	for i, p in pts do
		local q = pts[i % n + 1]
		local function out(pt)
			local v = Vector3.new(pt[1], 0, pt[2]) - c
			local u = v.Magnitude > 0 and v.Unit or Vector3.zero
			local s = (apex.Y - base) / math.max(1, v.Magnitude) -- (the eave drops along the slope)
			return Vector3.new(pt[1], base, pt[2]) + u * over - Vector3.new(0, over * s, 0)
		end
		tri(parent, "RoofPanel", out(p), out(q), apex, (stripe and i % 2 == 0) and stripe or sty, th or 1)
	end
end

-- a dome over a polygon of n corners on a circle-ish base: `rings` bands up to the top (radius from the corners)
local function domeRoof(parent, cx: number, cz: number, base: number, rx: number, rz: number, h: number, n: number, rings: number, sty, th: number?, band)
	local rot = math.pi / 2 - math.pi / n
	local function P(k, j)
		local phi = (j / rings) * math.pi / 2
		local a = rot + k * 2 * math.pi / n
		return Vector3.new(cx + rx * math.cos(phi) * math.cos(a), base + h * math.sin(phi), cz + rz * math.cos(phi) * math.sin(a))
	end
	for j = 0, rings - 1 do
		for k = 0, n - 1 do
			local a, bb, c, d = P(k, j), P(k + 1, j), P(k + 1, j + 1), P(k, j + 1)
			local s = (band and j % 2 == 1) and band or sty
			if j == rings - 1 then tri(parent, "Dome", a, bb, c, s, th or 1) else quad(parent, "Dome", a, bb, c, d, s, th or 1) end
		end
	end
end

-- an n-sided prism (a tower, a silo, a chimney stack): radius r round (cx, cz) from y0 to y1
local function prism(parent, name, cx: number, cz: number, r: number, y0: number, y1: number, n: number, sty, o)
	local side = 2 * r * math.tan(math.pi / n) + 0.1
	for k = 0, n - 1 do
		local a = k * 2 * math.pi / n
		local cf = CFrame.new(cx, (y0 + y1) / 2, cz) * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -r + 0.5)
		part(parent, name, Vector3.new(side, y1 - y0, 1), cf, sty, o)
	end
end
-- a pointed spire (a thin cone) of n sides
local function spire(parent, cx: number, cz: number, r: number, y0: number, h: number, n: number, sty, o)
	local pts = {}
	for k = 0, n - 1 do
		local a = k * 2 * math.pi / n
		table.insert(pts, Vector3.new(cx + r * math.cos(a), y0, cz + r * math.sin(a)))
	end
	local apex = Vector3.new(cx, y0 + h, cz)
	for k = 1, n do tri(parent, "Spire", pts[k], pts[k % n + 1], apex, sty, 0.6, o) end
end

---------------------------------------------------------------- the new shell
-- o = {
--   x0, x1, z0, z1   a box footprint (default -80, 80, -60, 60: the old one), OR
--   poly             a list of corners (ring(...)): edge 1 is the front, centred on x = 0
--   H                wall height (one storey) / two = true (two storeys of 21 like the old shell)
--   front1 / back1 / left1 / right1 (box) = window centres; win = { w, b, t }; ops = per-edge openings (poly)
--   door = { w = 10, t = 15, kind = "double" | "open" }   the front door at x = 0
--   roof = "none" | "flat" | "gable" | "aframe" | "gambrel" | "barrel" | "cone" | "dome"  + rise / low / high / apex
--   roofStyle, stripe (every other cone panel), ceiling = false (no flat ceiling: the roof is seen from inside)
--   steps = false (no entry steps), found = foundation height above the ground (2)
-- }
-- Returns the wall top (y). Leaves SHAPE.pts (the footprint corners) and SHAPE.top.
local SHAPE = {}
local function shell2(o)
	local H = o.H or 20
	local top = o.two and 44 or (F1 + H)
	local roofSty = o.roofStyle or T.roof
	local ext = model(STR, "Exterior")
	local rf = model(STR, "Roof")
	local win = o.win or {}
	local function W(list) return wins(list, win.w, win.b, win.t) end
	local door = o.door or {}
	local dw, dt = door.w or 10, door.t or 15
	local pts
	if o.poly then
		pts = o.poly
		polyFloor(STR, "Foundation", pts, 0, 2, T.found or T.stone, 3, 1.2)
		local gf = polyFloor(STR, "Floor", pts, 1.9, 2.05, T.floor, 2, -0.6)
		if gf then gf.Name = "GroundFloor" end
		local ops = table.clone(o.ops or {})
		local first = table.clone(ops[1] or {})
		local p, q = pts[1], pts[2]
		local len = math.sqrt((q[1] - p[1]) ^ 2 + (q[2] - p[2]) ^ 2)
		local inw = segCF(p[1], p[2], q[1], q[2]):PointToObjectSpace(centroid(pts)).X > 0 and 1 or -1
		table.insert(first, { c = len / 2, w = dw, b = 0, t = dt, kind = door.kind or "double", inward = inw })
		ops[1] = first
		polyWalls(ext, pts, F1, H, ops, EXT, o.postStyle, o.postW)
		if o.two then
			polyWalls(ext, pts, F2, 21, o.ops2 or {}, EXT, o.postStyle, o.postW)
		end
		footprint(pts)
	else
		local x0, x1, z0, z1 = o.x0 or -80, o.x1 or 80, o.z0 or -60, o.z1 or 60
		pts = { { x1, z1 }, { x0, z1 }, { x0, z0 }, { x1, z0 } }
		box(STR, "Foundation", x0 - 1, 0, z0 - 1, x1 + 1, 2, z1 + 1, T.found or T.stone)
		box(STR, "GroundFloor", x0 + 2, 1.9, z0 + 2, x1 - 2, 2.05, z1 - 2, T.floor)
		local f1 = W(o.front1 or {})
		table.insert(f1, { c = 0, w = dw, b = 0, t = dt, kind = door.kind or "double", inward = -1 })
		wall(ext, "Front1", "x", z1 - 1, x0, x1, F1, H, f1, EXT(-1))
		wall(ext, "Back1", "x", z0 + 1, x0, x1, F1, H, o.backOps or W(o.back1 or {}), EXT(1))
		wall(ext, "Left1", "z", x0 + 1, z0 + 2, z1 - 2, F1, H, o.leftOps or W(o.left1 or {}), EXT(1))
		wall(ext, "Right1", "z", x1 - 1, z0 + 2, z1 - 2, F1, H, o.rightOps or W(o.right1 or {}), EXT(-1))
		if o.two then
			wall(ext, "Front2", "x", z1 - 1, x0, x1, F2, 21, W(o.front2 or {}), EXT(-1))
			wall(ext, "Back2", "x", z0 + 1, x0, x1, F2, 21, W(o.back2 or {}), EXT(1))
			wall(ext, "Left2", "z", x0 + 1, z0 + 2, z1 - 2, F2, 21, W(o.left2 or {}), EXT(1))
			wall(ext, "Right2", "z", x1 - 1, z0 + 2, z1 - 2, F2, 21, W(o.right2 or {}), EXT(-1))
		end
		local pw = o.postW or 3.2
		for _, xz in { { x0 + 1, z0 + 1 }, { x1 - 1, z0 + 1 }, { x0 + 1, z1 - 1 }, { x1 - 1, z1 - 1 } } do
			box(ext, "CornerPost", xz[1] - pw / 2, 2, xz[2] - pw / 2, xz[1] + pw / 2, top, xz[2] + pw / 2, o.postStyle or T.trim)
		end
		if o.ceiling ~= false then box(STR, "Ceiling", x0 + 2, top - 1, z0 + 2, x1 - 2, top, z1 - 2, T.ceiling or T.beam) end
		-- the roof
		local hz, cz = (z1 - z0) / 2, (z0 + z1) / 2
		-- (o.ridge = "z": the ridge runs front to back and the gables face the yard and the back)
		local alongZ = o.ridge == "z"
		local half = alongZ and (x1 - x0) / 2 or hz
		local cc = alongZ and (x0 + x1) / 2 or cz
		local a1, a2 = alongZ and z0 or x0, alongZ and z1 or x1
		local axis = alongZ and "z" or "x"
		local function shift(prof) for _, p in prof do p[1] += cc end return prof end
		local r = o.roof or "gable"
		local endSty = o.gableStyle or T.ext
		if r == "flat" then
			box(rf, "RoofSlab", x0 - 1, top, z0 - 1, x1 + 1, top + 1.2, z1 + 1, roofSty)
		elseif r == "hip" then
			hipRoof(rf, x0, x1, z0, z1, top, o.rise or hz * 0.5, o.over or 3, roofSty)
		elseif r == "gable" or r == "aframe" then
			-- (an A-frame: low long walls, the roof climbs steeply to a high ridge)
			local rise = o.rise or (r == "aframe" and half * 1.2 or half * 0.45)
			local over = o.over or (r == "aframe" and 4 or 3)
			extrude(rf, a1, a2, shift(gableProf(half, top, rise, over)), roofSty,
				{ axis = axis, ends = endSty, endParent = STR, over = o.endOver or 2, endProf = shift(gableProf(half, top, rise, 0)) })
		elseif r == "gambrel" then
			local low, high = o.low or half * 0.55, o.high or half * 0.25
			extrude(rf, a1, a2, shift(gambrelProf(half, top, low, high, o.over)), roofSty,
				{ axis = axis, ends = endSty, endParent = STR, over = o.endOver or 2, endProf = shift(gambrelProf(half, top, low, high, 0)) })
		elseif r == "barrel" then
			extrude(rf, a1, a2, shift(arcProf(half + 1, top, o.rise or half * 0.6, o.n or 10)), roofSty,
				{ axis = axis, ends = endSty, endParent = STR, over = o.endOver or 1 })
		end
	end
	if o.poly then
		local r = o.roof or "cone"
		if r == "cone" then
			local c = centroid(pts)
			coneRoof(rf, pts, top, Vector3.new(c.X, top + (o.rise or 40), c.Z), roofSty, o.over or 3, 1, o.stripe)
		elseif r == "dome" then
			local P = RINGINFO[pts] or {}
			local cx, cz, rx, rz = P.cx or 0, P.cz or 0, P.rx or 58, P.rz or 58
			domeRoof(rf, cx, cz, top, rx + 0.6, rz + 0.6, o.rise or rx * 0.7, #pts, o.rings or 5, roofSty, 1, o.stripe)
		elseif r == "flat" then
			polyFloor(rf, "RoofSlab", pts, top, top + 1.2, roofSty, 3, 1)
		end
		if o.ceiling == true then polyFloor(STR, "Ceiling", pts, top - 1, top, T.ceiling or T.beam, 3, -0.5) end
	end
	-- the steps up to the door (the ground is y 0, the floor y 2)
	if o.steps ~= false then
		local fz = o.poly and math.max(pts[1][2], pts[2][2]) or (o.z1 or 60)
		local sty = o.stepStyle or T.porch or T.floor
		box(STR, "Step", -dw / 2 - 2, 0, fz, dw / 2 + 2, 1.35, fz + 2.5, sty)
		box(STR, "Step", -dw / 2 - 2, 0, fz + 2.5, dw / 2 + 2, 0.7, fz + 5, sty)
	end
	SHAPE.pts, SHAPE.top = pts, top
	return top
end

-- a light washing a facade from the ground (each building lights its own front)
local function washLight(x: number, z: number, aim: Vector3, color: Color3?, range: number?, bright: number?)
	local fl = box(DEC, "Floodlight", x - 0.7, 0.1, z - 0.5, x + 0.7, 0.9, z + 0.5, T.iron, DECO)
	local sp = Instance.new("SpotLight"); sp.Face = Enum.NormalId.Back; sp.Angle = 70; sp.Range = range or 48; sp.Brightness = bright or 1.6
	sp.Color = color or Color3.fromRGB(200, 205, 230); sp.Parent = fl
	fl.CFrame = CFrame.lookAt(fl.Position, aim) * CFrame.Angles(0, math.pi, 0)
	return fl
end

-- the yard beside a building that is narrower than the old box: a barrier along z = zf from x = +-a to +-95 (the
-- yard's side walls) so nobody walks round to the sides or the back (the run counts the house box as "inside").
-- deco(parent, x1, x2, z) draws what it looks like (a fence, a hedge, a wall); the barrier itself is invisible.
local function sideBarrier(a: number, zf: number, deco)
	local bm = model(DEC, "SideBarrier")
	for _, s in { -1, 1 } do
		local x1, x2 = s * a, s * 96
		part(bm, "Block", Vector3.new(math.abs(x2 - x1), 40, 1.6), CFrame.new((x1 + x2) / 2, 20, zf), st(M.SmoothPlastic, nil, Color3.new()),
			{ t = 1, noShadow = true })
		if deco then deco(bm, math.min(x1, x2), math.max(x1, x2), zf) end
	end
	for _, p in bm:GetChildren() do if p.Name == "Block" then p.CanCollide = true; p.CanQuery = false; p.CanTouch = false end end
	return bm
end
