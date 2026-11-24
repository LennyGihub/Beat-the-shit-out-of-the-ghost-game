-- PERFORMANCE PASS (Edit, standalone; 2026-11-24, the business guide's mobile budgets):
--   python3 tools/studio.py luau Edit tools/build/perf_pass.luau             -> REPORT only (changes nothing)
--   (printf 'APPLY = true\n'; cat tools/build/perf_pass.luau) > /tmp/p.luau && python3 tools/studio.py luau Edit /tmp/p.luau
-- Looks at every map / world / the lobby: workspace (Lobby, Grounds, the live map), ServerStorage.Maps.*,
-- ServerStorage.Worlds.*, ServerStorage.GroundsAway, ReplicatedStorage.Intro.
-- APPLY changes only what can't alter gameplay:
--   1. CastShadow off on small decoration (CanCollide off, largest side < 3 studs) and on every Neon part (lights).
--   2. CollisionFidelity Box on PURE decoration MeshParts / Unions (CanCollide, CanQuery and CanTouch all off: no
--      raycast, touch or physics ever uses their exact shape, but its collision geometry still sits in memory).
--   3. Workspace.EnableSLIMAvatars = true (lighter avatars: the guide reports -93% triangles, -60% memory).
-- It REPORTS (never changes): the streaming settings next to the guide's values, shadow-casting lights per map,
-- particle emitters, parts / draw-call suspects (distinct MeshIds) per container. Streaming changes can break client
-- code that expects parts to be there, so they wait for a decision + a playtest.
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local APPLY = (APPLY == true) -- (a line `APPLY = true` before the script)

local function roots(): { { name: string, inst: Instance } }
	local out = {}
	for _, n in { "Lobby", "Grounds", "Mansion" } do
		local x = workspace:FindFirstChild(n)
		if x then table.insert(out, { name = "workspace." .. n, inst = x }) end
	end
	for _, folder in { "Maps", "Worlds", "GroundsAway" } do
		local f = SS:FindFirstChild(folder)
		if f then
			for _, c in f:GetChildren() do table.insert(out, { name = folder .. "." .. c.Name, inst = c }) end
		end
	end
	local intro = RS:FindFirstChild("Intro")
	if intro then table.insert(out, { name = "ReplicatedStorage.Intro", inst = intro }) end
	return out
end

local lines = {}
local function say(s: string) table.insert(lines, s) end

local tot = { parts = 0, shadowOff = 0, boxed = 0, lights = 0, shadowLights = 0, emitters = 0 }
for _, r in roots() do
	local parts, smallShadow, neonShadow, fidelity, lightsN, shadowL, emit = 0, 0, 0, 0, 0, 0, 0
	local meshIds = {} :: { [string]: boolean }
	local nMesh = 0
	for _, d in r.inst:GetDescendants() do
		if d:IsA("BasePart") then
			parts += 1
			local decor = not d.CanCollide
			local big = math.max(d.Size.X, d.Size.Y, d.Size.Z)
			if d.CastShadow and ((decor and big < 3) or d.Material == Enum.Material.Neon) then
				if d.Material == Enum.Material.Neon then neonShadow += 1 else smallShadow += 1 end
				if APPLY then d.CastShadow = false end
			end
			if (d:IsA("MeshPart") or d:IsA("UnionOperation")) and decor and not d.CanQuery and not d.CanTouch then
				local ok, fid = pcall(function() return (d :: any).CollisionFidelity end)
				if ok and fid ~= Enum.CollisionFidelity.Box then
					fidelity += 1
					if APPLY then pcall(function() (d :: any).CollisionFidelity = Enum.CollisionFidelity.Box end) end
				end
			end
			if d:IsA("MeshPart") then
				local id = d.MeshId
				if id ~= "" and not meshIds[id] then meshIds[id] = true; nMesh += 1 end
			end
		elseif d:IsA("Light") then
			lightsN += 1
			if (d :: any).Shadows then shadowL += 1 end
		elseif d:IsA("ParticleEmitter") then
			emit += 1
		end
	end
	tot.parts += parts; tot.shadowOff += smallShadow + neonShadow; tot.boxed += fidelity
	tot.lights += lightsN; tot.shadowLights += shadowL; tot.emitters += emit
	say(("%-34s parts %5d | shadows off: %4d small decor + %3d neon | box collision: %3d | lights %3d (%d with shadows) | emitters %3d | distinct meshes %d")
		:format(r.name, parts, smallShadow, neonShadow, fidelity, lightsN, shadowL, emit, nMesh))
end

local function prop(name: string): string
	local ok, v = pcall(function() return (workspace :: any)[name] end)
	return ok and tostring(v) or "(n/a)"
end
say("")
say("STREAMING (now -> the guide): StreamingEnabled " .. prop("StreamingEnabled") .. " -> true | ModelStreamingBehavior " .. prop("ModelStreamingBehavior")
	.. " -> Improved | StreamingIntegrityMode " .. prop("StreamingIntegrityMode") .. " -> PauseOutsideLoadedArea | StreamOutBehavior "
	.. prop("StreamOutBehavior") .. " -> Opportunistic | MinRadius " .. prop("StreamingMinRadius") .. " -> 64 | TargetRadius " .. prop("StreamingTargetRadius") .. " -> 1024")
say("SLIM avatars: " .. prop("EnableSLIMAvatars") .. (APPLY and " -> true" or " (APPLY sets it true)"))
if APPLY then pcall(function() (workspace :: any).EnableSLIMAvatars = true end) end
say(("TOTAL: %d parts, %d shadows %s, %d decor meshes %s, %d lights (%d cast shadows: the guide says at most 2 per room), %d emitters")
	:format(tot.parts, tot.shadowOff, APPLY and "turned off" or "to turn off", tot.boxed, APPLY and "boxed" or "to box", tot.lights, tot.shadowLights, tot.emitters))
say(APPLY and "APPLIED. Save the place (File > Save) and re-run without APPLY to check: the counts to change should be 0." or "REPORT ONLY (nothing changed).")
return table.concat(lines, "\n")
