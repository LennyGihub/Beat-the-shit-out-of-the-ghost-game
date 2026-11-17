--!strict
-- UltKit: the building blocks of the ultimates' effects. Everything is made of plain blocks (PS2 look: flat
-- colours, hard edges, faceted rings and bursts, no soft sprites).
-- It runs on its own clock, so a Studio test can slow or freeze the effects to photograph them:
--   player attribute DebugUltScale = time scale (0 = frozen), DebugUltFreezeAt = seconds after the next cast
--   (or, with DebugUltMarkOn = "act", after the first server effect of that cast: see UltFx).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Kit = {}
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local rng = Random.new()
local STUDIO = RunService:IsStudio()
local folder: Folder
local clock = 0
local markT = -1 -- fx time of the last cast (DebugUltFreezeAt counts from it)
local shakeFn: ((number) -> ())? = nil

type Tween = { inst: Instance, t0: number, dur: number, from: { [string]: any }, to: { [string]: any }, ease: (number) -> number, done: (() -> ())? }
type Chunk = { p: BasePart, pos: Vector3, rot: CFrame, v: Vector3, w: Vector3, t0: number, life: number, size: Vector3, g: number,
	floor: number?, drag: number, tr: number, shrink: boolean }
type Loop = { t0: number, dur: number, fn: (a: number, dt: number, t: number) -> boolean? }
local tweens: { Tween } = {}
local chunks: { Chunk } = {}
local loops: { Loop } = {}
local timers: { { at: number, fn: () -> () } } = {}

Kit.rng = rng
Kit.ease = {
	lin = function(a: number): number return a end,
	out = function(a: number): number return 1 - (1 - a) * (1 - a) end,
	out3 = function(a: number): number return 1 - (1 - a) ^ 3 end,
	inq = function(a: number): number return a * a end,
	in3 = function(a: number): number return a * a * a end,
	io = function(a: number): number return a * a * (3 - 2 * a) end,
	back = function(a: number): number local b = a - 1; return 1 + 2.70158 * b * b * b + 1.70158 * b * b end,
}
local E = Kit.ease

-- the effects' own time (seconds); everything in the kit is scheduled on it
function Kit.now(): number return clock end
function Kit.mark() markT = clock end
function Kit.unmark() markT = -1 end
-- Studio: the clock stands still (DebugUltFreezeAt reached)
function Kit.frozen(): boolean
	local fz = STUDIO and lp:GetAttribute("DebugUltFreezeAt")
	return type(fz) == "number" and markT >= 0 and clock >= markT + fz - 1e-4
end
function Kit.rand(a: number, b: number): number return rng:NextNumber(a, b) end

local function lerp(a: any, b: any, f: number): any
	if type(a) == "number" then return a + (b - a) * f end
	return a:Lerp(b, f)
end

-- Neon blooms: a bright neon cube near the camera turns into a soft blob. Small pieces (debris, auras, the
-- wind-up's cubes) are dimmed to mid tones so they keep their hard edges; big flashes stay bright on purpose.
function Kit.dim(c: Color3, k: number?): Color3
	-- pale colours bloom the most: push the colour toward its pure hue, then cap how bright it looks
	local h, s, v = c:ToHSV()
	if s > 0.08 then c = Color3.fromHSV(h, math.max(s, 0.6), v) end
	local m = c.R * 0.3 + c.G * 0.59 + c.B * 0.11
	local cap: number = k or 0.36
	return m > cap and Color3.new(c.R * cap / m, c.G * cap / m, c.B * cap / m) or c
end

-- PARTS ------------------------------------------------------------------------------------------------
local function setup(p: BasePart, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, tr: number?)
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.CastShadow = false
	-- neon is capped a little under full brightness so even the big flashes keep their facets
	p.Material = mat or Enum.Material.Neon; p.Color = mat == nil and Kit.dim(color, 0.5) or color
	p.Size = size; p.CFrame = cf; p.Transparency = tr or 0
	p.Parent = folder
end
function Kit.part(size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, tr: number?): Part
	local p = Instance.new("Part")
	setup(p, size, cf, color, mat, tr)
	return p
end
function Kit.wedge(size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, tr: number?): WedgePart
	local p = Instance.new("WedgePart")
	setup(p, size, cf, color, mat, tr)
	return p
end

-- SCHEDULING -------------------------------------------------------------------------------------------
function Kit.after(t: number, fn: () -> ()) table.insert(timers, { at = clock + t, fn = fn }) end
function Kit.kill(inst: Instance, t: number) Kit.after(t, function() inst:Destroy() end) end
-- fn(a, dt, t) every frame for dur seconds (a = 0..1, the last call has a = 1); return false to stop early
function Kit.loop(dur: number, fn: (a: number, dt: number, t: number) -> boolean?)
	table.insert(loops, { t0 = clock, dur = math.max(dur, 1e-3), fn = fn })
end
function Kit.tween(inst: Instance, dur: number, to: { [string]: any }, ease: ((number) -> number)?, done: (() -> ())?)
	local from = {}
	for k in to do from[k] = (inst :: any)[k] end
	table.insert(tweens, { inst = inst, t0 = clock, dur = math.max(dur, 1e-3), from = from, to = to, ease = ease or E.out, done = done })
end
-- wait, fade out, destroy
function Kit.fade(p: BasePart, wait: number, dur: number)
	Kit.after(wait, function()
		if p.Parent then Kit.tween(p, dur, { Transparency = 1 }, E.lin, function() p:Destroy() end) end
	end)
end

-- WORLD ------------------------------------------------------------------------------------------------
-- the floor under a point (furniture, characters, the monster and see-through parts don't count)
local function probe(pos: Vector3, dir: Vector3): RaycastResult?
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	local ex: { Instance } = { folder, cam }
	for _, p in Players:GetPlayers() do if p.Character then table.insert(ex, p.Character) end end
	local g = workspace:FindFirstChild("Ghost")
	if g then table.insert(ex, g) end
	for _ = 1, 6 do
		rp.FilterDescendantsInstances = ex
		local r = workspace:Raycast(pos, dir, rp)
		if not r then return nil end
		local inst = r.Instance
		local furn = inst:FindFirstAncestor("Furniture")
		if furn or not inst.CanCollide or inst.Transparency >= 0.95 then
			table.insert(ex, furn or inst)
		else
			return r
		end
	end
	return nil
end
function Kit.floor(pos: Vector3, down: number?): Vector3
	local r = probe(pos + Vector3.new(0, 1.5, 0), Vector3.new(0, -(down or 40), 0))
	return r and r.Position or (pos - Vector3.new(0, 3, 0))
end
-- height of the ceiling above a point (pos.Y + max when there is none)
function Kit.ceiling(pos: Vector3, max: number): number
	local r = probe(pos, Vector3.new(0, max, 0))
	return r and r.Position.Y or (pos.Y + max)
end

function Kit.setShake(fn: (number) -> ()) shakeFn = fn end
-- camera shake that fades with distance
function Kit.near(pos: Vector3, amount: number, range: number)
	local d = (cam.CFrame.Position - pos).Magnitude
	if d < range and shakeFn then shakeFn(amount * (1 - d / range)) end
end
function Kit.dist(pos: Vector3): number return (cam.CFrame.Position - pos).Magnitude end

function Kit.light(pos: Vector3, color: Color3, range: number, bright: number, life: number)
	local a = Instance.new("Attachment")
	a.WorldPosition = pos
	a.Parent = workspace.Terrain
	local l = Instance.new("PointLight")
	l.Color = color; l.Range = math.min(range, 60); l.Brightness = bright; l.Shadows = false
	l.Parent = a
	Kit.tween(l, life, { Brightness = 0 }, E.inq, function() a:Destroy() end)
end

-- SHAPES -----------------------------------------------------------------------------------------------
-- loose cubes thrown from a point (simulated here: no physics). o: color | colors, smin, smax, speed, up, life, g,
-- drag, mat, tr, spread (start offset), spreadY, dir + cone (aimed), floor (true = bounce on the floor), slab, keep
function Kit.chunks(pos: Vector3, n: number, o: { [string]: any })
	if #chunks > 450 then n = math.ceil(n / 3) end
	local colors: { Color3 } = o.colors or { o.color or Color3.new(1, 1, 1) }
	local smin: number = o.smin or 0.3
	local smax: number = o.smax or smin
	local speed: number, up: number = o.speed or 20, o.up or 20
	local floorY: number? = nil
	if o.floor == true then floorY = Kit.floor(pos).Y elseif type(o.floor) == "number" then floorY = o.floor end
	for _ = 1, n do
		local s = rng:NextNumber(smin, smax)
		local size = o.slab and Vector3.new(s, s * 0.3, s * 1.7) or Vector3.one * s
		local at = pos
		if o.spread then
			at += Vector3.new(rng:NextNumber(-1, 1) * o.spread, rng:NextNumber(0, 1) * (o.spreadY or 0), rng:NextNumber(-1, 1) * o.spread)
		end
		local v: Vector3
		if o.dir then
			v = ((o.dir :: Vector3) + rng:NextUnitVector() * (o.cone or 0.3)).Unit * speed * rng:NextNumber(0.5, 1)
				+ Vector3.new(0, up * rng:NextNumber(0.3, 1), 0)
		else
			local a, k = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0.35, 1)
			v = Vector3.new(math.cos(a) * speed * k, up * rng:NextNumber(0.4, 1), math.sin(a) * speed * k)
		end
		local rot = CFrame.Angles(rng:NextNumber(0, 6.3), rng:NextNumber(0, 6.3), rng:NextNumber(0, 6.3))
		local tr: number = o.tr or 0
		local col = colors[rng:NextInteger(1, #colors)]
		local p = Kit.part(size, CFrame.new(at) * rot, (o.mat == nil and o.bright ~= true) and Kit.dim(col) or col, o.mat, tr)
		table.insert(chunks, { p = p, pos = at, rot = rot, v = v, w = rng:NextUnitVector() * rng:NextNumber(2, 9) * (o.spin or 1), t0 = clock,
			life = (o.life or 1) * rng:NextNumber(0.7, 1.15), size = size, g = o.g or 80, floor = floorY, drag = o.drag or 0, tr = tr,
			shrink = o.keep ~= true })
	end
end

-- a faceted burst: three cubes turned against each other that swell and fade (the low-poly "explosion ball")
-- o: color1 (end colour), tr (start transparency), ease, mat, spin, n (cubes), hold (fraction before the fade)
function Kit.poly(pos: Vector3, s0: number, s1: number, color: Color3, dur: number, o: { [string]: any }?)
	local opt: { [string]: any } = o or {}
	-- a big burst that would start round the camera is not drawn (the caster's own shockwave, seen in first person)
	local d = Kit.dist(pos)
	if (s1 > 8 and d < 5) or (s1 > 2.5 and d < 4) then return end
	local n: number = opt.n or 3
	local tr0: number = opt.tr or 0.1
	local ease = opt.ease or E.out3
	local hold: number = opt.hold or 0.15
	local spin: number = opt.spin or 1.5
	local parts: { Part } = {}
	local rots = { CFrame.new(), CFrame.Angles(math.pi / 4, math.pi / 4, 0), CFrame.Angles(0, math.pi / 4, math.pi / 4), CFrame.Angles(math.pi / 4, 0, math.pi / 4) }
	local tilt = CFrame.Angles(rng:NextNumber(0, 1.5), rng:NextNumber(0, 1.5), 0)
	if opt.mat == nil then
		color = Kit.dim(color, 0.5)
		if opt.color1 then opt = table.clone(opt); opt.color1 = Kit.dim(opt.color1, 0.5) end
	end
	for i = 1, n do parts[i] = Kit.part(Vector3.one * s0, CFrame.new(pos) * tilt * rots[i], color, opt.mat, tr0) end
	Kit.loop(dur, function(a)
		local s = s0 + (s1 - s0) * ease(a)
		local f = math.clamp((a - hold) / (1 - hold), 0, 1)
		for i, p in parts do
			p.Size = Vector3.one * s * (1 - (i - 1) * 0.06)
			p.CFrame = CFrame.new(pos) * tilt * CFrame.Angles(0, a * spin, a * spin * 0.5) * rots[i]
			p.Transparency = tr0 + (1 - tr0) * f
			if opt.color1 then p.Color = color:Lerp(opt.color1, a) end
		end
		if a >= 1 then for _, p in parts do p:Destroy() end end
		return nil
	end)
end

-- a ring of blocks that grows (or shrinks) from r0 to r1: the segmented shockwave. `at` = a point (flat ring on
-- the ground) or a CFrame (the ring lies in its XZ plane). o: r0, r1, n, h, h1, w, color, color1, dur, mat, tr,
-- fill (1 = closed ring), ease, spin (rad over the whole life), hold, lift (true = blocks stand ON the plane)
function Kit.ring(at: Vector3 | CFrame, o: { [string]: any })
	local cf0: CFrame = typeof(at) == "Vector3" and CFrame.new(at :: Vector3) or at :: CFrame
	local n: number = o.n or 16
	local r0: number, r1: number = o.r0 or 1, o.r1 or 10
	if r1 > r0 and r1 > 6 and Kit.dist(cf0.Position) < 5 then r0 = math.max(r0, 5) end -- starts beyond the camera
	local h0: number = o.h or 1
	local h1: number = o.h1 or h0
	local w: number = o.w or 0.8
	local tr0: number = o.tr or 0
	local fill: number = o.fill or 1
	local ease = o.ease or E.out
	local hold: number = o.hold or 0.35
	local spin: number = o.spin or 0
	local color: Color3 = o.mat == nil and Kit.dim(o.color, 0.5) or o.color
	local color1: Color3? = (o.color1 and o.mat == nil) and Kit.dim(o.color1, 0.5) or o.color1
	local lift = o.lift ~= false
	local parts: { Part } = {}
	for i = 1, n do parts[i] = Kit.part(Vector3.one, cf0, color, o.mat, tr0) end
	local k = 2 * math.tan(math.pi / n) * fill
	Kit.loop(o.dur or 0.5, function(a)
		local e = ease(a)
		local r = r0 + (r1 - r0) * e
		local h = h0 + (h1 - h0) * e
		local f = math.clamp((a - hold) / (1 - hold), 0, 1)
		for i, p in parts do
			p.Size = Vector3.new(math.max(0.05, r * k), h, w)
			p.CFrame = cf0 * CFrame.Angles(0, i / n * math.pi * 2 + spin * a, 0) * CFrame.new(0, lift and h / 2 or 0, -r)
			p.Transparency = tr0 + (1 - tr0) * f
			if color1 then p.Color = color:Lerp(color1, a) end
		end
		if a >= 1 then for _, p in parts do p:Destroy() end end
		return nil
	end)
end

-- jagged cracks on the floor, running out from a point; glow = a hot core that cools first
function Kit.cracks(center: Vector3, r: number, n: number, glow: Color3?, life: number?)
	local keep: number = life or 4
	for i = 1, n do
		local ang = (i + rng:NextNumber(-0.3, 0.3)) / n * math.pi * 2
		local at = center
		local segs = 3
		for j = 1, segs do
			ang += rng:NextNumber(-0.55, 0.55)
			local len = r / segs * rng:NextNumber(0.7, 1.2)
			local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
			local mid = at + dir * len / 2
			local wd = 0.5 - j * 0.11
			local cf = CFrame.lookAt(mid + Vector3.new(0, 0.06, 0), mid + Vector3.new(0, 0.06, 0) + dir)
			Kit.after((j - 1) * 0.04, function()
				local p = Kit.part(Vector3.new(wd, 0.1, len + 0.2), cf, Color3.fromRGB(18, 15, 14), Enum.Material.SmoothPlastic)
				Kit.fade(p, keep, 1)
				if glow then
					local gl = Kit.part(Vector3.new(wd * 0.5, 0.08, len + 0.1), cf + Vector3.new(0, 0.04, 0), glow)
					Kit.fade(gl, 0.5, 1.1)
				end
			end)
			at += dir * len
		end
	end
end

-- a pillar of light on a point: two square columns turned 45 degrees (eight-sided), widening and fading
function Kit.column(base: Vector3, w0: number, w1: number, h: number, color: Color3, dur: number, tr: number?, hold: number?)
	local t0: number = tr or 0.2
	local hd: number = hold or 0.3
	-- a pillar round the camera would only wash the screen out (the caster's own, seen in first person)
	local c = cam.CFrame.Position
	if Vector3.new(c.X - base.X, 0, c.Z - base.Z).Magnitude < w1 * 0.75 + 0.6 and c.Y > base.Y - 1 and c.Y < base.Y + h then return end
	local a1 = Kit.part(Vector3.new(w0, h, w0), CFrame.new(base + Vector3.new(0, h / 2, 0)), color, nil, t0)
	local a2 = Kit.part(Vector3.new(w0, h, w0), CFrame.new(base + Vector3.new(0, h / 2, 0)) * CFrame.Angles(0, math.pi / 4, 0), color, nil, t0)
	Kit.loop(dur, function(a)
		local w = w0 + (w1 - w0) * E.out3(math.min(1, a / 0.35))
		local f = math.clamp((a - hd) / (1 - hd), 0, 1)
		if f > 0 then w *= 1 - f * 0.85 end
		a1.Size = Vector3.new(w, h, w); a2.Size = a1.Size
		a1.Transparency = t0 + (1 - t0) * f; a2.Transparency = a1.Transparency
		if a >= 1 then a1:Destroy(); a2:Destroy() end
		return nil
	end)
end

-- spikes / slabs that shoot out of the floor in a ring and lean outward. o: r, n, h, w, color | colors, mat, tr,
-- tilt (rad), life, crystal (square crystal turned 45 degrees), shatter (burst into shards instead of sinking),
-- stagger, jitter
function Kit.spikes(center: Vector3, o: { [string]: any })
	local n: number = o.n or 8
	local colors: { Color3 } = o.colors or { o.color }
	local phase = rng:NextNumber(0, 6.3)
	for i = 1, n do
		local ang = phase + i / n * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
		local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
		local r = (o.r or 6) * (1 + rng:NextNumber(-1, 1) * (o.jitter or 0.15))
		local hh = (o.h or 4) * rng:NextNumber(0.6, 1.25)
		local ww = (o.w or 1.2) * rng:NextNumber(0.7, 1.2)
		local pos = center + dir * r
		local stand = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(-(o.tilt or 0.4) * rng:NextNumber(0.6, 1.3), 0, 0)
		local twist = o.crystal and CFrame.Angles(0, math.pi / 4, 0) or CFrame.Angles(0, rng:NextNumber(-0.3, 0.3), 0)
		local up = stand * CFrame.new(0, hh / 2 - 0.4, 0) * twist
		local down = stand * CFrame.new(0, -hh / 2 - 0.2, 0) * twist
		local color = colors[rng:NextInteger(1, #colors)]
		Kit.after((o.stagger or 0) * rng:NextNumber(0, 1), function()
			local p = Kit.part(Vector3.new(ww, hh, o.crystal and ww or ww * 0.6), down, color, o.mat or Enum.Material.SmoothPlastic, o.tr)
			Kit.tween(p, 0.16, { CFrame = up }, E.back)
			Kit.after((o.life or 2) * rng:NextNumber(0.85, 1.1), function()
				if not p.Parent then return end
				if o.shatter then
					Kit.chunks(p.Position, 4, { color = color, mat = o.mat, tr = o.tr, smin = ww * 0.3, smax = ww * 0.6, speed = 12, up = 14, life = 0.8, slab = true })
					p:Destroy()
				else
					Kit.tween(p, 0.45, { CFrame = down }, E.inq, function() p:Destroy() end)
				end
			end)
		end)
	end
end

-- a thin beam between two points (lightning segments, speed lines)
function Kit.line(a: Vector3, b: Vector3, w: number, color: Color3, tr: number?): Part
	return Kit.part(Vector3.new(w, w, (b - a).Magnitude + w * 0.5), CFrame.lookAt((a + b) / 2, b), color, nil, tr)
end

-- cubes that fly IN to a point from all round (charging up). follow = a function giving the target each frame
function Kit.gather(target: () -> Vector3, n: number, radius: number, dur: number, colors: { Color3 }, size: number?)
	for _ = 1, n do
		local off = rng:NextUnitVector() * radius * rng:NextNumber(0.6, 1)
		off = Vector3.new(off.X, math.abs(off.Y) * 0.7, off.Z)
		local s: number = (size or 0.45) * rng:NextNumber(0.6, 1.3)
		local wait = rng:NextNumber(0, dur * 0.45)
		local p = Kit.part(Vector3.one * s, CFrame.new(target() + off), Kit.dim(colors[rng:NextInteger(1, #colors)]), nil, 1)
		local swirl = rng:NextNumber(1.5, 3.5) * (rng:NextNumber() < 0.5 and -1 or 1)
		Kit.after(wait, function()
			Kit.loop(dur - wait, function(a)
				local e = a * a
				local o2 = CFrame.Angles(0, swirl * e, 0) * (off * (1 - e))
				local at = target() + o2
				p.CFrame = CFrame.new(at) * CFrame.Angles(a * 6, a * 4, 0)
				p.Size = Vector3.one * s * (1 - e * 0.7) * math.clamp(Kit.dist(at) / 9, 0.3, 1) -- small near the camera
				p.Transparency = math.max(0, 0.6 - a * 3)
				if a >= 1 then p:Destroy() end
				return nil
			end)
		end)
	end
end

-- THE CLOCK --------------------------------------------------------------------------------------------
local function step(rdt: number)
	local scale = 1
	local dt = math.min(rdt, 0.1)
	if STUDIO then
		local s = lp:GetAttribute("DebugUltScale")
		if type(s) == "number" then scale = s end
		dt *= scale
		local fz = lp:GetAttribute("DebugUltFreezeAt")
		if type(fz) == "number" and markT >= 0 then dt = math.clamp(markT + fz - clock, 0, dt) end
	end
	if dt <= 0 then return end
	clock += dt
	for i = #timers, 1, -1 do
		local t = timers[i]
		if clock >= t.at then
			table.remove(timers, i)
			task.spawn(t.fn)
		end
	end
	for i = #tweens, 1, -1 do
		local t = tweens[i]
		if not t.inst.Parent then table.remove(tweens, i); continue end
		local a = math.min(1, (clock - t.t0) / t.dur)
		local e = t.ease(a)
		for k, to in t.to do (t.inst :: any)[k] = lerp(t.from[k], to, e) end
		if a >= 1 then
			table.remove(tweens, i)
			if t.done then task.spawn(t.done) end
		end
	end
	for i = #loops, 1, -1 do
		local l = loops[i]
		local el = clock - l.t0
		local a = math.min(1, el / l.dur)
		local ok, res = pcall(l.fn, a, dt, el)
		if not ok then warn("[UltKit] " .. tostring(res)) end
		if a >= 1 or not ok or res == false then table.remove(loops, i) end
	end
	for i = #chunks, 1, -1 do
		local c = chunks[i]
		local a = (clock - c.t0) / c.life
		if a >= 1 or not c.p.Parent then
			c.p:Destroy()
			table.remove(chunks, i)
			continue
		end
		c.v = c.v * math.max(0, 1 - c.drag * dt) - Vector3.new(0, c.g * dt, 0)
		c.pos += c.v * dt
		if c.floor and c.pos.Y < c.floor + c.size.Y / 2 and c.v.Y < 0 then
			c.pos = Vector3.new(c.pos.X, c.floor + c.size.Y / 2, c.pos.Z)
			c.v = Vector3.new(c.v.X * 0.55, -c.v.Y * 0.35, c.v.Z * 0.55)
			c.w *= 0.5
		end
		c.rot = c.rot * CFrame.Angles(c.w.X * dt, c.w.Y * dt, c.w.Z * dt)
		c.p.CFrame = CFrame.new(c.pos) * c.rot
		if a > 0.6 then
			local f = (a - 0.6) / 0.4
			if c.shrink then c.p.Size = c.size * (1 - f * 0.9) else c.p.Transparency = c.tr + (1 - c.tr) * f end
		end
	end
end

function Kit.init()
	if folder then return end
	folder = Instance.new("Folder")
	folder.Name = "UltFx"
	folder.Parent = workspace
	RunService:BindToRenderStep("UltKit", Enum.RenderPriority.Camera.Value - 1, step)
end
function Kit.folder(): Folder return folder end
function Kit.count(): number return #folder:GetChildren() end

return Kit
