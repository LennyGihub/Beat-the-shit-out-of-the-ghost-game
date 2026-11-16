--!strict
-- Admin panel (server side): one RemoteFunction Remotes.Admin(line) that runs a text command.
-- Admins = anyone in Studio, the game's owner (or rank 255 of the owning group), and the user ids listed
-- in the ReplicatedStorage attribute AdminUserIds ("123,456"). The IsAdmin player attribute only shows the
-- panel on the client; every command checks isAdmin again here.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Items = require(RS.Shared.Items)
local Ultimates = require(RS.Shared.Ultimates)
local Monsters = require(RS.Shared.Monsters)
local Maps = require(RS.Shared.Maps)
local Data = require(script.Parent.Data)
local Combat = require(script.Parent.Combat)
local Inventory = require(script.Parent.Inventory)
local Ghost = require(script.Parent.Ghost)
local Run = require(script.Parent.Run)
local Remotes = require(script.Parent.Remotes) -- creates the Remotes folder

local Admin = {}

-- the admin panel can be bought: Game Pass id in the ReplicatedStorage attribute AdminPassId (0 = not set up)
local MarketplaceService = game:GetService("MarketplaceService")
local passOwners = {} :: { [Player]: boolean }
local function passId(): number return tonumber(RS:GetAttribute("AdminPassId")) or 0 end

-- full admins: Studio, the owner, AdminUserIds. Pass owners are "bought" admins (see WORLD below).
local function isFullAdmin(p: Player): boolean
	if RunService:IsStudio() then return true end
	if game.CreatorType == Enum.CreatorType.User and p.UserId == game.CreatorId then return true end
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, rank = pcall(function() return p:GetRankInGroup(game.CreatorId) end)
		if ok and rank >= 255 then return true end
	end
	local list = RS:GetAttribute("AdminUserIds")
	if type(list) == "string" then
		for id in string.gmatch(list, "%d+") do if tonumber(id) == p.UserId then return true end end
	end
	return false
end
local function isAdmin(p: Player): boolean
	return isFullAdmin(p) or passOwners[p] == true
end

-- commands that change the game for everyone: a bought admin can only use them while playing alone
local WORLD = { start = true, next = true, killghost = true, monster = true, event = true, endrun = true, bring = true, ragdoll = true }

-- 500, 25k, 2m, 1b
local function num(s: string?): number?
	if not s then return nil end
	local n, suf = string.match(string.lower(s), "^(%-?[%d%.]+)([kmb]?)$")
	local v = tonumber(n)
	if not v then return nil end
	local mult = ({ k = 1e3, m = 1e6, b = 1e9 } :: any)[suf] or 1
	return math.floor(v * mult)
end

-- case-insensitive lookup by id or name (also partial: "chain" -> Chainsaw)
local function find(list: { any }, word: string?): any
	if not word or word == "" then return nil end
	local w = string.lower(word)
	for _, x in list do if string.lower(x.id) == w then return x end end
	for _, x in list do if string.lower(x.name) == w then return x end end
	for _, x in list do
		if string.find(string.lower(x.id), w, 1, true) or string.find(string.lower(x.name), w, 1, true) then return x end
	end
	return nil
end

local HELP = "cash <n> | runcash <n> | give <item> | clearitems | ult <id> | allults | allmaps | heal | brut | god | start [map] [diff] | "
	.. "next | killghost | bring | ragdoll [power] | monster <id|off> | event plane|van|train | leave | endrun"

local CMD: { [string]: (p: Player, a: string?, b: string?) -> (boolean, string) } = {}

CMD.help = function() return true, HELP end

CMD.cash = function(p, a)
	local n = num(a) or 0
	if n == 0 then return false, "Usage: cash 10k" end
	Data.addCash(p, n)
	return true, "+" .. n .. " cash (now " .. tostring(p:GetAttribute("Cash")) .. ")"
end

CMD.runcash = function(p, a)
	local n = num(a) or 0
	if n == 0 then return false, "Usage: runcash 5k" end
	if not p:GetAttribute("InMatch") then return false, "Run cash only exists during a run (start one first)" end
	p:SetAttribute("RunCash", (p:GetAttribute("RunCash") or 0) + n)
	return true, "+" .. n .. " run cash"
end

CMD.give = function(p, a)
	local it = find(Items.list, a)
	if not it then return false, "No item called '" .. tostring(a) .. "'" end
	if not p:GetAttribute("InMatch") then return false, "Items only work during a run (press START RUN first)" end
	if not Inventory.give(p, it.id) then return false, "Hotbar full (CLEAR ITEMS first)" end
	return true, "Gave " .. it.name
end

CMD.clearitems = function(p)
	Inventory.clear(p)
	return true, "Hotbar cleared"
end

CMD.ult = function(p, a)
	local u = find(Ultimates.list, a)
	if not u then return false, "No ultimate called '" .. tostring(a) .. "'" end
	Data.ownUlt(p, u.id)
	Data.equipUlt(p, u.id)
	Combat.fillBrutality(p)
	return true, "Equipped " .. u.name .. " (brutality full, press Q)"
end

CMD.allults = function(p)
	for _, u in Ultimates.list do Data.ownUlt(p, u.id) end
	return true, "Unlocked all " .. #Ultimates.list .. " ultimates"
end

CMD.allmaps = function(p)
	for _, m in Maps.list do if m.price > 0 then Data.own(p, "Map_" .. m.id) end end
	return true, "Unlocked all maps"
end

CMD.heal = function(p)
	local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = hum.MaxHealth end
	Combat.refillStamina(p)
	return true, "Healed + full stamina"
end

CMD.brut = function(p)
	Combat.fillBrutality(p)
	return true, "Brutality full (press Q)"
end

CMD.god = function(p)
	local on = not p:GetAttribute("AdminGod")
	p:SetAttribute("AdminGod", on)
	return true, "God mode " .. (on and "ON" or "OFF")
end

CMD.start = function(p, a, b)
	if Run.running() then return false, "A run is already going (END RUN first)" end
	local map = a and find(Maps.list, a)
	local diff = b and find(Maps.difficulties, b)
	Run.beginMatch({ p }, map and map.id or Maps.default, diff and diff.id or Maps.defaultDiff)
	return true, "Run started on " .. (map and map.name or "The Mansion") .. " (" .. (diff and diff.name or "Normal") .. ")"
end

CMD.next = function()
	if not Run.running() then return false, "No run going" end
	Ghost.despawn()
	task.spawn(Run.startFight)
	return true, "Next ghost coming"
end

CMD.killghost = function(p)
	if not Ghost.alive() then return false, "No ghost alive" end
	Ghost.damage(1e9, p)
	return true, "Ghost killed"
end

-- pull the ghost 8 studs in front of you
CMD.bring = function(p)
	if not Ghost.alive() then return false, "No ghost alive" end
	local head = p.Character and p.Character:FindFirstChild("Head") :: BasePart?
	if not head then return false, "No character" end
	local look = Vector3.new(head.CFrame.LookVector.X, 0, head.CFrame.LookVector.Z).Unit
	local at = head.Position + look * 8
	Ghost.current.model:PivotTo(CFrame.lookAt(at, head.Position))
	return true, "Ghost brought in front of you"
end

-- knock her out with a huge hit toward where you look (ragdoll + wall smash test)
CMD.ragdoll = function(p, a)
	if not Ghost.alive() then return false, "No ghost alive" end
	local g = Ghost.current
	local head = p.Character and p.Character:FindFirstChild("Head") :: BasePart?
	local look = head and Vector3.new(head.CFrame.LookVector.X, 0, head.CFrame.LookVector.Z) or Vector3.new(0, 0, -1)
	Ghost.hit(p, look.Magnitude > 0.01 and look.Unit or Vector3.new(0, 0, -1), num(a) or 150, 1)
	return true, "BONK! She is flying"
end

CMD.monster = function(_p, a)
	if a == "off" or a == "random" then
		RS:SetAttribute("AdminMonster", nil)
		return true, "Monsters are random again"
	end
	local m = find(Monsters.list, a)
	if not m then return false, "No monster called '" .. tostring(a) .. "'" end
	RS:SetAttribute("AdminMonster", m.id)
	if Run.running() then
		Ghost.despawn()
		task.spawn(Run.startFight)
		return true, m.name .. " is coming now (and every ghost until 'monster off')"
	end
	return true, "Next ghost will be " .. m.name .. " (start a run)"
end

CMD.event = function(_p, a)
	local k = string.lower(a or "")
	if k ~= "plane" and k ~= "van" and k ~= "train" then return false, "Usage: event plane|van|train" end
	if not Run.running() then return false, "Start a run first" end
	Run.adminEvent(k)
	return true, string.upper(k) .. " event spawned outside"
end

CMD.leave = function(p)
	if not p:GetAttribute("InMatch") then return false, "You are not in a run" end
	Run.leave(p, "left")
	return true, "Left the run (paid out)"
end

CMD.endrun = function(p)
	for _, q in Run.matchPlayers() do Run.leave(q, "left") end
	Run.endMatch()
	return true, "Run ended"
end

local ALIAS = { money = "cash", item = "give", heal = "heal", ghost = "monster", kill = "killghost", stop = "endrun", ["end"] = "endrun", ults = "allults", maps = "allmaps" }

function Admin.run(p: Player, line: string): (boolean, string)
	local words = {}
	for w in string.gmatch(line, "%S+") do table.insert(words, w) end
	local c = string.lower(words[1] or "help")
	c = ALIAS[c] or c
	local f = CMD[c]
	if not f then return false, "Unknown command '" .. c .. "'. " .. HELP end
	if WORLD[c] and not isFullAdmin(p) then
		if c == "start" then return false, "Use the PLAY button to start a run" end
		local others = 0
		for _, q in Run.matchPlayers() do if q ~= p then others += 1 end end
		if others > 0 or not p:GetAttribute("InMatch") then return false, "That one only works when you play alone" end
	end
	local ok, a, b = pcall(f, p, words[2], words[3])
	if not ok then
		warn("[Admin] " .. tostring(a))
		return false, "Error: " .. tostring(a)
	end
	return a, b
end

function Admin.start()
	local folder = RS:WaitForChild("Remotes")
	local rf = folder:FindFirstChild("Admin") :: RemoteFunction?
	if not rf then
		local n = Instance.new("RemoteFunction")
		n.Name = "Admin"
		n.Parent = folder
		rf = n
	end
	local last = {} :: { [Player]: number }
	;(rf :: RemoteFunction).OnServerInvoke = function(p: Player, line: any)
		if not isAdmin(p) then return false, "Not an admin" end
		if type(line) ~= "string" or #line > 200 then return false, "Bad command" end
		if os.clock() - (last[p] or 0) < 0.1 then return false, "Slow down" end
		last[p] = os.clock()
		local ok, msg = Admin.run(p, line)
		print("[Admin] " .. p.Name .. " > " .. line .. " -> " .. msg)
		return ok, msg
	end
	local function onPlayer(p: Player)
		p:SetAttribute("IsAdmin", isFullAdmin(p))
		task.spawn(function()
			local id = passId()
			if id > 0 then
				local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(p.UserId, id) end)
				if ok and owns then passOwners[p] = true; p:SetAttribute("IsAdmin", true) end
			end
		end)
	end
	-- bought in game: the panel appears right away
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, id, bought)
		if bought and id == passId() then
			passOwners[p] = true
			p:SetAttribute("IsAdmin", true)
			Remotes.Fx:FireClient(p, "Toast", "ADMIN PANEL UNLOCKED - press F2")
		end
	end)
	Players.PlayerAdded:Connect(onPlayer)
	for _, p in Players:GetPlayers() do onPlayer(p) end
	Players.PlayerRemoving:Connect(function(p) last[p] = nil; passOwners[p] = nil end)
end

return Admin
