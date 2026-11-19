--!strict
-- SECRET ROOMS: a map can hide rooms behind things that open (folder Secrets in the map: one Model per hidden door;
-- tools/build/maps/camp_items.luau). In a door model the parts named Panel move by the model's attribute Slide
-- (a Vector3) in 1.2 s and stop blocking; the part named Trigger carries the prompt (attributes Action, Object). The
-- prompt is only seen up close, so a room has to be found: its door looks like the wall / the shelf / the hay round
-- it, with a small clue (scrape marks on the floor, one bale sitting out). Inside lies a tier-3 item (Server/Supplies).
-- Armed when a stage starts (Run.startStage): the map is a fresh copy every time, so the doors are shut again.
local TweenService = game:GetService("TweenService")
local Remotes = require(script.Parent.Remotes)
local Events = require(script.Parent.Events)

local Secrets = {}
-- every door armed so far: its moving parts where they were shut, and its prompt
type Door = { parts: { { p: BasePart, cf: CFrame, collide: boolean } }, pp: ProximityPrompt, opened: boolean }
local doors = {} :: { [Instance]: Door }

local function shut(d: Door)
	d.opened = false
	d.pp.Enabled = true
	for _, e in d.parts do
		e.p.CFrame = e.cf
		e.p.CanCollide = e.collide
		e.p.CanQuery = e.collide
	end
end

-- (a replay of the same building keeps the map loaded: its doors are shut again here)
function Secrets.arm()
	for inst in doors do if not inst.Parent then doors[inst] = nil end end
	local live = workspace:FindFirstChild("Mansion")
	local f = live and live:FindFirstChild("Secrets")
	if not f then return end
	for _, door in f:GetChildren() do
		local known = doors[door]
		if known then shut(known); continue end
		local trig = door:FindFirstChild("Trigger", true)
		if not (trig and trig:IsA("BasePart")) then continue end
		local act, obj = door:GetAttribute("Action"), door:GetAttribute("Object")
		local pp = Events.prompt(trig, type(act) == "string" and act or "Push", type(obj) == "string" and obj or "", 0.8)
		pp.MaxActivationDistance = 6
		pp.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow -- (an item's prompt nearby must not hide it)
		local d: Door = { parts = {}, pp = pp, opened = false }
		for _, x in door:GetDescendants() do
			if x:IsA("BasePart") and x.Name == "Panel" then table.insert(d.parts, { p = x, cf = x.CFrame, collide = x.CanCollide }) end
		end
		doors[door] = d
		pp.Triggered:Connect(function(p: Player)
			if d.opened or not p:GetAttribute("InMatch") then return end
			d.opened = true
			pp.Enabled = false
			local slide = door:GetAttribute("Slide")
			local by = typeof(slide) == "Vector3" and slide or Vector3.new(0, -8.2, 0)
			for _, e in d.parts do
				e.p.CanCollide = false
				e.p.CanQuery = false
				TweenService:Create(e.p, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { CFrame = e.cf + by }):Play()
			end
			Remotes.Fx:FireAllClients("SecretOpen", trig.Position)
			Remotes.Fx:FireClient(p, "Toast", "YOU FOUND A SECRET ROOM!", true)
		end)
	end
end

return Secrets
