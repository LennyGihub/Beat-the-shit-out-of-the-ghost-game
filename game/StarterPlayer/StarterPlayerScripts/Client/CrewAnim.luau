--!strict
-- The Burning Captain's little skeletons (server: Abilities.spawnClones; models named "GhostClone" with the
-- attribute Crew): they hop out of him and run at you, legs going like mad, cutlass over the head, each one out of
-- step with the others. Runs on every client, like GhostAnim. A knocked-out one (Ragdoll.toss switched its joints
-- off) is left to the physics.
local RunService = game:GetService("RunService")

local CrewAnim = {}
local A = CFrame.Angles
type Mini = { joints: { [string]: Motor6D }, phase: number, born: number, conn: RBXScriptConnection }
local minis = {} :: { [Model]: Mini }
local rng = Random.new()

local function add(m: Instance)
	if not m:IsA("Model") or m.Name ~= "GhostClone" or not m:GetAttribute("Crew") or minis[m] then return end
	local joints = {} :: { [string]: Motor6D }
	local function joint(d: Instance)
		if d:IsA("Motor6D") then joints[d.Name] = d end
	end
	for _, d in m:GetDescendants() do joint(d) end
	-- with streaming on, parts can reach this client after the model
	minis[m] = { joints = joints, phase = rng:NextNumber(0, 6.28), born = os.clock(), conn = m.DescendantAdded:Connect(joint) }
end

local function update()
	local t = os.clock()
	for m, mi in minis do
		if not m.Parent then
			mi.conn:Disconnect()
			minis[m] = nil
			continue
		end
		local J = mi.joints
		local root = J.Root or J.RootJoint
		if root and not root.Enabled then continue end -- knocked out: limp
		local size = m:GetScale()
		local ph = t * 17 + mi.phase
		local s, c = math.sin(ph), math.cos(ph)
		local pose = {
			RightHip = A(s * 1.05, 0, 0), LeftHip = A(-s * 1.05, 0, 0),
			RightKnee = A(-0.25 - math.max(0, math.sin(ph + 1.2)) * 1.2, 0, 0), LeftKnee = A(-0.25 - math.max(0, -math.sin(ph + 1.2)) * 1.2, 0, 0),
			RightAnkle = A(0.2, 0, 0), LeftAnkle = A(0.2, 0, 0),
			-- cutlass waved over the head, shield arm pumping
			RightShoulder = A(2.5 + c * 0.35, 0, 0.25 + s * 0.2), RightElbow = A(0.3 + s * 0.25, 0, 0),
			LeftShoulder = A(s * 0.9 + 0.3, 0, -0.15), LeftElbow = A(0.9, 0, 0),
			Waist = A(0.32, -s * 0.2, 0),
			Neck = A(-0.25, math.sin(t * 4 + mi.phase) * 0.35, s * 0.12),
			Root = A(0.12, 0, s * 0.1) * CFrame.new(0, math.abs(s) * 0.4 * size, 0),
		}
		-- the hop out of the Captain: knees tucked, up and down again
		local hop = (t - mi.born) / 0.4
		if hop < 1 then
			local up = math.sin(hop * math.pi)
			pose.Root = A(-0.3 * up, 0, 0) * CFrame.new(0, up * 3.2 * size, 0)
			pose.RightHip = A(1.2 * up, 0, 0); pose.LeftHip = A(1.0 * up, 0, 0)
			pose.RightKnee = A(-1.5 * up, 0, 0); pose.LeftKnee = A(-1.5 * up, 0, 0)
		end
		for name, cf in pose do
			local j = J[name]
			if j then j.Transform = cf end
		end
		if J.RootJoint and not J.Root then J.RootJoint.Transform = pose.Root end
	end
end

function CrewAnim.init()
	for _, m in workspace:GetChildren() do add(m) end
	workspace.ChildAdded:Connect(add)
	RunService:BindToRenderStep("CrewAnim", Enum.RenderPriority.Character.Value + 2, update)
end

return CrewAnim
