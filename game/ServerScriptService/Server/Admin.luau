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
local Guard = require(script.Parent.Guard)
local Staff = require(script.Parent.Staff)

local Admin = {}

-- the admin panel can be bought: Game Pass id in the ReplicatedStorage attribute AdminPassId (0 = not set up)
local MarketplaceService = game:GetService("MarketplaceService")
local passOwners = {} :: { [Player]: boolean }
local function passId(): number return tonumber(RS:GetAttribute("AdminPassId")) or 0 end

-- full admins: anyone in Studio and the staff (Server/Staff: the owner, its id list and the ReplicatedStorage
-- attribute AdminUserIds). Pass owners are "bought" admins (see WORLD below).
local function isFullAdmin(p: Player): boolean
	return RunService:IsStudio() or Staff.isDev(p)
end
local function isAdmin(p: Player): boolean
	return isFullAdmin(p) or passOwners[p] == true
end

-- commands that change the game for everyone: a bought admin can only use them while playing alone
local WORLD = { start = true, next = true, killghost = true, monster = true, boss = true, event = true, endrun = true, bring = true, ragdoll = true }

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

local HELP = "daily reset|welcome|sample|<n> | notify | cash <n> | xp <n> | ref <userId>|done | camp all|reset|<n> | trips reset|empty|<n> | form <id>|all|off|tutorial | code reset|<code> | tutorial reset | notes reset | offline finish | offline pity <h> | trade bot | runcash <n> | give <item> | clearitems | ult <id> | allults | allmaps | heal | brut | god | start [map] [diff] | "
	.. "revive | money2 | glock | vip | doubleult | secondchance | next | killghost | bring | ragdoll [power] | monster <id|off> | boss <id> [tier 1-3] | evolved on|off|<tier> | event plane|van|train | leave | endrun"

local CMD: { [string]: (p: Player, a: string?, b: string?) -> (boolean, string) } = {}

CMD.help = function() return true, HELP end
-- XP for the player's level (the sellers' better vials need levels)
CMD.xp = function(p, a)
	local n = tonumber(a) or 500
	local before, after = Data.addXP(p, n)
	return true, "+" .. n .. " XP (level " .. before .. " -> " .. after .. ")"
end
-- the campaign: "camp all" clears every building, "camp reset" wipes the progress, "camp <n>" clears the first n
CMD.camp = function(p, a)
	local Campaign = require(game:GetService("ReplicatedStorage").Shared.Campaign)
	local d = Data.get(p)
	if not d then return false, "No save" end
	if a == "reset" then
		d.Campaign = {}
		Data.refresh(p)
		return true, "Campaign progress wiped"
	end
	local n = a == "all" and 99 or (tonumber(a) or 99)
	local k = 0
	for _, m in Campaign.list do
		for _, st in m.stages do
			if k < n then Data.clearStage(p, st.id, 2); k += 1 end
		end
	end
	local before, after = Data.mapLevel(p) -- (a cleared map brings the level its jars / potions need)
	return true, k .. " building(s) cleared" .. (after > before and (" - level " .. before .. " -> " .. after) or "")
end

-- forms: "form <id>" gives that form and wears it, "form all" gives every form, "form off" wears none (to look at them)
CMD.form = function(p, a)
	local Forms = require(game:GetService("ReplicatedStorage").Shared.Forms)
	if a == "all" then
		for _, fm in Forms.list do Data.addForm(p, fm.id) end
		return true, #Forms.list .. " forms given"
	end
	if a == "tutorial" then
		-- (the jars / potions tutorial again: not done, starter cash again, no form owned)
		local d = Data.get(p)
		if not d then return false, "No save" end
		d.FormTut = false; d.FormTutCash = false; d.Forms = {}; d.FormN = {}; d.FormStim = nil; d.FormPotion = nil
		Data.refresh(p)
		Combat.refreshHealth(p)
		return true, "Forms wiped, the jars / potions tutorial will start"
	end
	if a == "off" then
		local d = Data.get(p)
		if not d then return false, "No save" end
		d.FormStim = nil; d.FormPotion = nil
		Data.refresh(p)
		Combat.refreshHealth(p)
		return true, "No form worn"
	end
	local fm = nil
	if a then
		for _, x in Forms.list do
			if string.lower(x.id) == string.lower(a) then fm = x end
		end
		if not fm then fm = find(Forms.list, a) end
	end
	if not fm then return false, "Usage: form <id> | form all" end
	Data.addForm(p, fm.id)
	Data.equipForm(p, fm.id)
	Combat.refreshHealth(p)
	return true, "Wearing " .. fm.name .. " (" .. Forms.rarity[fm.rarity].name .. ")"
end
-- codes (Server/Codes): "code reset" forgets your used codes and takes the code forms back, "code <code>" redeems one
-- INVITES (Server/Share): link yourself to <userId> as if you had joined with their link; `ref done` = your 10 minutes are up
CMD.ref = function(p, a)
	local Share = require(script.Parent.Share)
	if a == "done" then Share.debugLink(p, nil); return true, "your play time is now " .. Share.PLAY .. " s (the reward goes within 15 s)" end
	local id = tonumber(a)
	if not id then return false, "Usage: ref <userId> | ref done" end
	Share.debugLink(p, id)
	return true, "linked to " .. id .. ": after " .. Share.PLAY .. " s of play they get their reward"
end
CMD.code = function(p, a, b)
	local Codes = require(script.Parent.Codes)
	if a == "reset" then return true, Codes.reset(p) end
	if not a then return false, "Usage: code reset | code <code>" end
	return Codes.redeem(p, a .. (b and (" " .. b) or ""), true)
end
-- "daily reset | welcome | sample | shield | miss <days> | <n>": the login streak (Server/Daily). <n> = as if day n was
-- claimed yesterday (claim again for day n+1); welcome = the welcome jar ready now; sample = today's free samples back
CMD.daily = function(p, a, b)
	local Daily = require(script.Parent.Daily)
	local n = tonumber(a)
	if n then return true, Daily.admin(p, "streak", n) end
	if a == "miss" then return true, Daily.admin(p, "miss", tonumber(b) or 1) end
	if a == "reset" or a == "welcome" or a == "sample" or a == "shield" then return true, Daily.admin(p, a) end
	return false, "Usage: daily reset | welcome | sample | shield | miss <days> | <n>"
end
-- "notify": the push notifications that would be planned if you left now (Server/Notify; Studio: NotifyLog)
CMD.notify = function(p)
	return true, require(script.Parent.Notify).debug(p)
end
-- "notes reset": the patch notes count as not read (WHAT'S NEW opens by itself again)
CMD.notes = function(p, a)
	if a ~= "reset" then return false, "Usage: notes reset" end
	Data.resetNotes(p)
	return true, "Patch notes reset: WHAT'S NEW opens again"
end
-- "tutorial reset": the current tutorial counts as not seen (the READY screen comes back on the next join)
CMD.tutorial = function(p, a)
	if a ~= "reset" then return false, "Usage: tutorial reset" end
	Data.resetTutorial(p)
	return true, "Tutorial reset: rejoin to get the READY screen and the intro"
end
-- trading: "trade bot" opens a trade with a test partner (Studio only, Server/Trade)
CMD.trade = function(p, a)
	if a ~= "bot" then return false, "Usage: trade bot" end
	return require(script.Parent.Trade).bot(p)
end
-- train tickets: "trips reset" (all 5 back), "trips empty" (none left), "trips <n>" (n left)
CMD.trips = function(p, a)
	local Campaign = require(game:GetService("ReplicatedStorage").Shared.Campaign)
	local max = Campaign.TRIPS.max
	local left = a == "reset" and max or (a == "empty" and 0 or tonumber(a))
	if not left then return false, "Usage: trips reset | empty | <n left>" end
	Data.setTrips(p, max - math.clamp(math.floor(left), 0, max))
	local l, reset = Data.tripsLeft(p)
	return true, l .. " / " .. max .. " train tickets" .. (reset > 0 and (" (back in " .. Campaign.clock(reset - os.time()) .. ")") or "")
end
-- offline opening: "offline finish" (everything in the queues is done now), "offline pity <hours>" (opening time
-- counted towards the RARE+ guarantee)
CMD.offline = function(p, a, b)
	local Forms = require(game:GetService("ReplicatedStorage").Shared.Forms)
	local o = Data.offline(p)
	if not o then return false, "No save" end
	if a == "finish" then
		local n = 0
		for _, kind in { "stim", "potion" } do
			local k = o[kind]
			local total = 0
			for _, id in k.q do
				local v = Forms.vialById[id]
				total += v and Forms.openTime(v) or 0
			end
			if #k.q > 0 then k.t = os.time() - total - 1; n += #k.q end
		end
		return true, n .. " jar(s) / potion(s) finish now"
	elseif a == "pity" then
		local h = tonumber(b) or 23.99
		o.pity = math.floor(h * 3600)
		return true, "Offline opening counted: " .. h .. " h (RARE+ at " .. (Forms.OFFLINE.pity / 3600) .. " h)"
	end
	return false, "Usage: offline finish | offline pity <hours>"
end

CMD.cash = function(p, a)
	local n = num(a) or 0
	if n == 0 then return false, "Usage: cash 10k" end
	Data.addCash(p, n, "Admin")
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
	Combat.endUltimate(p) -- a running ultimate stops, so the new one can be tried right away
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

CMD.revive = function(p)
	if Run.revive(p) then return true, "Revived" end
	return false, "You are not dead in a run"
end

CMD.glock = function(p)
	local on = not p:GetAttribute("GlockPass")
	p:SetAttribute("GlockPass", on)
	if on and p:GetAttribute("InMatch") then Inventory.give(p, "Glock18") end
	return true, "Glock 18 pass " .. (on and "ON" or "OFF") .. " (this session)"
end

CMD.money2 = function(p)
	local on = not p:GetAttribute("Money2")
	p:SetAttribute("Money2", on)
	return true, "2X money " .. (on and "ON" or "OFF") .. " (this session)"
end

-- the other passes, for this session (testing them without buying)
for cmd, attr in { vip = "VIP", doubleult = "DoubleUlt", secondchance = "SecondChance" } do
	CMD[cmd] = function(p)
		local on = not p:GetAttribute(attr)
		p:SetAttribute(attr, on)
		return true, attr .. " pass " .. (on and "ON" or "OFF") .. " (this session)"
	end
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

-- the monster goes WEAK now, as after a x5 combo (Config.Weak; its cooldown is skipped): lift it (E), throw it
CMD.weak = function(p)
	local g = Ghost.current
	if not g or not Ghost.alive() then return false, "No ghost alive" end
	g.weakReady = 0
	if Ghost.weaken(p) then return true, "The monster is WEAK: lift it (E) and throw it" end
	return false, "It can't go weak right now (state " .. tostring(g.state) .. ")"
end

-- evolved on | off | <tier 1-3>: every ghost is an EVOLVED monster (combine with 'monster <id>')
CMD.evolved = function(_p, a)
	if a == "off" then
		RS:SetAttribute("AdminEvolved", nil)
		return true, "Evolved monsters only every 3rd ghost again"
	end
	RS:SetAttribute("AdminEvolved", tonumber(a) or true)
	if Run.running() then
		Ghost.despawn()
		task.spawn(Run.startFight)
		return true, "An evolved monster is coming now (and every ghost until 'evolved off')"
	end
	return true, "Every ghost will be evolved (start a run)"
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

-- boss <id> [tier 1-3]: the BOSS VARIANT (evolved form) of that monster comes now, once; the ghosts after it are
-- picked as usual. The id can also be the boss's own name ("golden conqueror", "captain").
CMD.boss = function(_p, a, b)
	local m = find(Monsters.list, a)
	if not m then
		local bosses = {}
		for id, e in Monsters.evo do table.insert(bosses, { id = id, name = e.title }) end
		local hit = find(bosses, a)
		m = hit and Monsters.byId[hit.id]
	end
	if not m then return false, "Usage: boss <monster> [tier 1-3]  (no monster called '" .. tostring(a) .. "')" end
	if not Monsters.evo[m.id] then return false, m.name .. " has no boss variant" end
	local tier = math.clamp(math.floor(tonumber(b) or 1), 1, 3)
	RS:SetAttribute("AdminBossOnce", m.id .. ":" .. tier)
	local title = Monsters.evolved(m.id, tier).name
	if Run.running() then
		Ghost.despawn()
		task.spawn(Run.startFight)
		return true, title .. " (tier " .. tier .. ") is coming now"
	end
	return true, "The first ghost will be " .. title .. " (tier " .. tier .. ") - start a run"
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

local ALIAS = { variant = "boss", evo = "boss", money = "cash", item = "give", heal = "heal", ghost = "monster", kill = "killghost", stop = "endrun", ["end"] = "endrun", ults = "allults", maps = "allmaps" }

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
	-- FREECAM (Client/FreeCam, SHIFT + C): the world round an admin's free camera is streamed to them (ReplicationFocus
	-- on an invisible anchored part there); "off" gives the focus back to their character
	local camFocus = {} :: { [Player]: BasePart }
	local camLast = {} :: { [Player]: number }
	local function camOff(p: Player)
		local part = camFocus[p]
		camFocus[p] = nil
		camLast[p] = nil
		if p.Parent then p.ReplicationFocus = nil end
		if part then part:Destroy() end
	end
	Remotes.FreeCam.OnServerEvent:Connect(function(p: Player, action: any, pos: any) if not Guard.ok(p, "FreeCam") then return end
		if action == "off" then camOff(p); return end
		if action ~= "focus" or not isAdmin(p) or typeof(pos) ~= "Vector3" then return end
		if pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z or pos.Magnitude > 1e5 then return end
		if os.clock() - (camLast[p] or 0) < 0.25 then return end
		camLast[p] = os.clock()
		local part = camFocus[p]
		if not part or not part.Parent then
			local folder = workspace:FindFirstChild("FreeCamFocus") or Instance.new("Folder")
			folder.Name = "FreeCamFocus"; folder.Parent = workspace
			local np = Instance.new("Part")
			np.Name = tostring(p.UserId); np.Anchored = true; np.CanCollide = false; np.CanQuery = false; np.CanTouch = false
			np.Transparency = 1; np.Size = Vector3.one; np.CastShadow = false
			np.Parent = folder
			camFocus[p] = np
			part = np
		end
		;(part :: BasePart).Position = pos
		p.ReplicationFocus = part
	end)
	Players.PlayerRemoving:Connect(camOff)
	-- the patch notes were read (Client/PatchNotesUI closed WHAT'S NEW)
	Remotes.PatchNotes.OnServerEvent:Connect(function(p: Player, action: any) if not Guard.ok(p, "PatchNotes") then return end
		if action == "seen" then Data.notesSeen(p) end
	end)
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
	if RunService:IsStudio() then
		-- Studio test hook: ReplicatedStorage attribute DebugAdmin = "<command line>" runs that admin command as the
		-- first player (a server test script can then drive a playtest without a client script); the answer is put in
		-- DebugAdminResult. Append " #n" to run the same line again.
		RS:GetAttributeChangedSignal("DebugAdmin"):Connect(function()
			local line = RS:GetAttribute("DebugAdmin")
			local p = Players:GetPlayers()[1]
			if type(line) == "string" and line ~= "" and p then
				local ok, msg = Admin.run(p, (string.gsub(line, "%s*#.*$", "")))
				RS:SetAttribute("DebugAdminResult", tostring(ok) .. ": " .. tostring(msg))
			end
		end)
		-- Studio photo hooks (thumbnails): DebugGhostAt = CFrame puts the ghost there,
		-- DebugKnock = Vector3 hits her that way (its length = knock power)
		RS:GetAttributeChangedSignal("DebugGhostAt"):Connect(function()
			local cf = RS:GetAttribute("DebugGhostAt")
			if typeof(cf) == "CFrame" and Ghost.alive() then Ghost.current.model:PivotTo(cf) end
		end)
		RS:GetAttributeChangedSignal("DebugKnock"):Connect(function()
			local v = RS:GetAttribute("DebugKnock")
			if typeof(v) == "Vector3" and Ghost.alive() then Ghost.hit(nil, v.Unit, v.Magnitude, 1) end
		end)
		-- DebugGhostHP = fraction 0..1: sets the monster's health (then a tiny hit, so enrage checks run)
		RS:GetAttributeChangedSignal("DebugGhostHP"):Connect(function()
			local f = RS:GetAttribute("DebugGhostHP")
			local g = Ghost.current
			if type(f) == "number" and g and Ghost.alive() then
				g.hp = math.clamp(f, 0.01, 1) * g.maxHp + 0.01
				Ghost.damage(0.01, nil)
			end
		end)
	end
	local function onPlayer(p: Player)
		p:SetAttribute("IsAdmin", isFullAdmin(p))
		p:SetAttribute("Dev", Staff.isDev(p)) -- the DEV title (lobby name tag, chat tag)
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
