--!strict
-- WHERE THE CALLER SITS DOWN (Server/Caller's ambush). Pure geometry: no game state, nothing required, so it can be
-- run on a map in Studio's Edit mode to see where he would go.
--
-- A spot is a place on the target's floor where he can sit out of the way: a wall at his back, a floor under him,
-- head room, open floor in front, nothing standing there. A CORNER (a wall at his back and one at his side) is the
-- best kind; a free stretch of WALL is the other. (Most corners of a furnished house have something standing in
-- them: with corners alone the Mansion's ground floor had three places left, two of them in the fireplace room,
-- and he sat in that room three times out of four.)
--
-- How one is picked (Spots.find):
--   1. every spot far enough from every player and out of their sight,
--   2. grouped by ROOM (the box of walls round it, Spots.roomBox),
--   3. a room is drawn, every room as likely as the next whatever its size - except the rooms he sat in lately
--      (`recent`: his last hiding places, newest first), which are very unlikely,
--   4. in that room: a corner if it has one, else the best stretch of wall.
local Spots = {}

export type Spot = { sit: Vector3, into: Vector3, corner: boolean, ahead: number }
export type Query = {
	rp: RaycastParams, -- the house's structure
	furniture: Instance?, -- the furniture folder (a spot with furniture standing in it is not free)
	min: Vector3, max: Vector3, -- the house's bounds
	floorY: number, -- the floor he hides on
	players: { Vector3 }, -- where the players are
	recent: { Vector3 }, -- his last hiding places, newest first
	rng: Random,
}

local WALL_NEAR, SIT_OFF = 6.5, 2 -- a wall this close counts; he sits this far from it
local MIN_DIST = { 26, 17 } -- at least this far from every player (the second: when nothing is free further away)
local RECENT_WEIGHT = { 0.03, 0.2, 0.5 } -- how likely a room he used 1, 2, 3 hides ago is, next to a fresh one (1)

-- The room round a point, as a box: how far the walls are along +X -X +Z -Z. Each side is the median of a fan of
-- rays, so a doorway (rays that run on into the next room) or a railing does not decide it.
function Spots.roomBox(rp: RaycastParams, bmin: Vector3, bmax: Vector3, at: Vector3, floorY: number): (CFrame, Vector3)
	local c = Vector3.new(at.X, floorY + 4, at.Z)
	local function reach(dir: Vector3): number
		local lat = Vector3.new(-dir.Z, 0, dir.X)
		local ds = {}
		for _, h in { 0, 5 } do
			local o0 = c + Vector3.new(0, h, 0)
			for _, k in { -7, -3.5, 0, 3.5, 7 } do
				if k == 0 or not workspace:Raycast(o0, lat * k, rp) then
					local r = workspace:Raycast(o0 + lat * k, dir * 120, rp)
					table.insert(ds, r and r.Distance or 120)
				end
			end
		end
		table.sort(ds)
		return ds[math.max(1, math.ceil(#ds / 2))]
	end
	local x1 = math.max(c.X - reach(-Vector3.xAxis), bmin.X)
	local x2 = math.min(c.X + reach(Vector3.xAxis), bmax.X)
	local z1 = math.max(c.Z - reach(-Vector3.zAxis), bmin.Z)
	local z2 = math.min(c.Z + reach(Vector3.zAxis), bmax.Z)
	local up = workspace:Raycast(c, Vector3.new(0, 40, 0), rp)
	local h = math.clamp((up and up.Distance or 16) + 4, 8, 20)
	return CFrame.new((x1 + x2) / 2, floorY + h / 2, (z1 + z2) / 2), Vector3.new(math.max(x2 - x1, 4), h, math.max(z2 - z1, 4))
end

-- every free spot on this floor (the players are not looked at here)
function Spots.scan(q: Query): { Spot }
	local rp = q.rp
	local fp = OverlapParams.new()
	fp.FilterType = Enum.RaycastFilterType.Include
	fp.FilterDescendantsInstances = { q.furniture or workspace.Terrain }
	local out, seen = {}, {} :: { [string]: boolean }
	-- a place to sit: the same floor under him, head room, open floor ahead, nothing standing there
	local function free(sit: Vector3, into: Vector3, fy: number): boolean
		local chest = sit + Vector3.new(0, 3, 0)
		local f2 = workspace:Raycast(chest, Vector3.new(0, -5, 0), rp)
		return f2 ~= nil and math.abs(f2.Position.Y - fy) < 0.6
			and not workspace:Raycast(sit + Vector3.new(0, 0.5, 0), Vector3.new(0, 8, 0), rp)
			and not workspace:Raycast(chest, into * 9, rp)
			and #workspace:GetPartBoundsInBox(CFrame.new(sit + Vector3.new(0, 2.6, 0)), Vector3.new(4.2, 5, 4.2), fp) == 0
	end
	local function add(sit: Vector3, into: Vector3, corner: boolean)
		local key = string.format("%d,%d,%s", math.floor(sit.X / 2 + 0.5), math.floor(sit.Z / 2 + 0.5), corner and "c" or "w")
		if seen[key] then return end
		seen[key] = true
		local ahead = workspace:Raycast(sit + Vector3.new(0, 3, 0), into * 30, rp)
		table.insert(out, { sit = sit, into = into, corner = corner, ahead = math.min(ahead and ahead.Distance or 30, 24) })
	end
	-- a wall along this axis really stands behind him: also 2 studs to his left and right (not a door frame or a post)
	local function backed(chest: Vector3, toWall: Vector3): boolean
		local lat = Vector3.new(-toWall.Z, 0, toWall.X).Unit * 2.2
		local d = toWall.Unit * (SIT_OFF + 1.5)
		return workspace:Raycast(chest, d, rp) ~= nil and workspace:Raycast(chest + lat, d, rp) ~= nil and workspace:Raycast(chest - lat, d, rp) ~= nil
	end
	for x = q.min.X + 4, q.max.X - 4, 4 do
		for z = q.min.Z + 4, q.max.Z - 4, 4 do
			local f = workspace:Raycast(Vector3.new(x, q.floorY + 6, z), Vector3.new(0, -9, 0), rp)
			if f and f.Normal.Y > 0.9 and math.abs(f.Position.Y - q.floorY) < 1.5 then
				local fy = f.Position.Y
				local c = f.Position + Vector3.new(0, 4, 0)
				-- the nearest wall along X and along Z
				local wx: number?, sx = nil, 0
				local wz: number?, sz = nil, 0
				for _, sg in { 1, -1 } do
					local rx = workspace:Raycast(c, Vector3.new(sg * WALL_NEAR, 0, 0), rp)
					if rx and math.abs(rx.Normal.X) > 0.9 and (not wx or rx.Distance < math.abs((wx :: number) - x)) then wx, sx = rx.Position.X, sg end
					local rz = workspace:Raycast(c, Vector3.new(0, 0, sg * WALL_NEAR), rp)
					if rz and math.abs(rz.Normal.Z) > 0.9 and (not wz or rz.Distance < math.abs((wz :: number) - z)) then wz, sz = rz.Position.Z, sg end
				end
				if wx and wz then
					-- a corner: both walls really there from where he sits
					local sit = Vector3.new(wx - sx * SIT_OFF, fy, wz - sz * SIT_OFF)
					local chest = sit + Vector3.new(0, 3, 0)
					local into = Vector3.new(-sx, 0, -sz).Unit
					if workspace:Raycast(chest, Vector3.new(sx * (SIT_OFF + 1.5), 0, 0), rp)
						and workspace:Raycast(chest, Vector3.new(0, 0, sz * (SIT_OFF + 1.5)), rp)
						and free(sit, into, fy) then
						add(sit, into, true)
					end
				end
				if wx then
					local sit = Vector3.new(wx - sx * SIT_OFF, fy, z)
					local into = Vector3.new(-sx, 0, 0)
					if backed(sit + Vector3.new(0, 3, 0), Vector3.new(sx, 0, 0)) and free(sit, into, fy) then add(sit, into, false) end
				end
				if wz then
					local sit = Vector3.new(x, fy, wz - sz * SIT_OFF)
					local into = Vector3.new(0, 0, -sz)
					if backed(sit + Vector3.new(0, 3, 0), Vector3.new(0, 0, sz)) and free(sit, into, fy) then add(sit, into, false) end
				end
			end
		end
	end
	return out
end

local function inBox(cf: CFrame, size: Vector3, p: Vector3, margin: number): boolean
	return math.abs(p.X - cf.Position.X) <= size.X / 2 + margin and math.abs(p.Z - cf.Position.Z) <= size.Z / 2 + margin
		and math.abs(p.Y - cf.Position.Y) <= size.Y / 2 + 3
end

-- Where he sits now: the spot and the box of its room. nil = nowhere free right now.
function Spots.find(q: Query): (Spot?, CFrame?, Vector3?)
	local all = Spots.scan(q)
	for _, minDist in MIN_DIST do
		-- 1. far from every player and out of their sight
		local ok = {} :: { { spot: Spot, near: number } }
		for _, s in all do
			local chest = s.sit + Vector3.new(0, 3, 0)
			local near, seen = math.huge, false
			for _, pp in q.players do
				near = math.min(near, (pp - s.sit).Magnitude)
				if not workspace:Raycast(chest, pp - chest, q.rp) then seen = true; break end
			end
			if not seen and near >= minDist then table.insert(ok, { spot = s, near = near }) end
		end
		if #ok > 0 then
			-- 2. by room
			local rooms = {} :: { { cf: CFrame, size: Vector3, list: { { spot: Spot, near: number } } } }
			for _, e in ok do
				local room = nil
				for _, r in rooms do
					if inBox(r.cf, r.size, e.spot.sit, 0.5) then room = r; break end
				end
				if not room then
					local cf, size = Spots.roomBox(q.rp, q.min, q.max, e.spot.sit, q.floorY)
					room = { cf = cf, size = size, list = {} }
					table.insert(rooms, room)
				end
				table.insert(room.list, e)
			end
			-- 3. draw a room: all alike, the ones he used lately very unlikely
			local weights, total = {}, 0
			for i, r in rooms do
				local w = 1
				for k, at in q.recent do
					if RECENT_WEIGHT[k] and inBox(r.cf, r.size, at, 1) then w = math.min(w, RECENT_WEIGHT[k]) end
				end
				weights[i] = w
				total += w
			end
			local x = q.rng:NextNumber(0, total)
			local room = rooms[#rooms]
			for i, r in rooms do
				x -= weights[i]
				if x <= 0 then room = r; break end
			end
			-- 4. the best spot of that room: a corner first, open floor in front, about 40 studs from the players
			local best, bestScore = nil :: Spot?, -math.huge
			for _, e in room.list do
				local score = (e.spot.corner and 14 or 0) + e.spot.ahead * 0.4 - math.abs(e.near - 42) * 0.25 + q.rng:NextNumber(0, 10)
				if score > bestScore then best, bestScore = e.spot, score end
			end
			return best, room.cf, room.size
		end
	end
	return nil, nil, nil
end

return Spots
