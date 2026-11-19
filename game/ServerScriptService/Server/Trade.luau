--!strict
-- TRADING (2026-11-19, the user: "add trading inside the game where you can trade money, jars and potions"): two
-- players in the lobby park swap CASH and FORMS (the fist forms out of Doc Mercy's ectoplasm jars and the body forms
-- out of Mother Moth's potions, Shared/Forms). Forms now count their copies (Server/Data FormN): a form rolled twice
-- is a second copy you can trade away and still keep one.
-- Remotes.Trade (client -> server):
--   ("request", userId)          ask a player in this server (both in the park, not in a run, not trading)
--   ("answer", userId, yes)      accept / decline a request (requests last REQUEST_LIFE seconds)
--   ("offer", { cash = n, forms = { [formId] = copies } })  my whole offer (checked against what I own)
--   ("ready", true|false)        lock in / unlock my side
--   ("cancel")                   end the trade
-- Server -> client (Remotes.Trade): ("request", fromUserId, fromName), ("state", view), ("closed", text, done).
-- Anti-scam: every change of an offer unreadies BOTH sides and locks READY for LOCK seconds; when both are ready a
-- FINAL countdown runs, and the swap only happens if nothing changed. At the swap everything is checked again
-- (cash and copies still owned, both still in the park, both saves loaded) and done in one go, then both are saved.
-- Studio only: admin "trade bot" opens a trade with a TRADE BOT (it offers cash and a form, readies after you).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Forms = require(RS.Shared.Forms)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Combat = require(script.Parent.Combat)

local Trade = {}

local REQUEST_LIFE = 20 -- seconds a request waits for an answer
local LOCK = 3 -- seconds READY stays locked after an offer changed
local FINAL = 3 -- seconds between "both ready" and the swap
local MAX_FORMS = 12 -- different forms in one side's offer
local MAX_CASH = 1e12

type Side = { p: Player?, name: string, userId: number, cash: number, forms: { [string]: number }, ready: boolean,
	bot: { cash: number, forms: { [string]: number } }? }
type Session = { a: Side, b: Side, lockUntil: number, final: number, token: number, closed: boolean }

local sessions = {} :: { [Player]: Session }
local requests = {} :: { [Player]: { [Player]: number } } -- target -> asker -> expiry (os.clock)
local lastAsk = {} :: { [Player]: number }
local lastOffer = {} :: { [Player]: { t: number, n: number } }
local rng = Random.new()

local function now(): number return workspace:GetServerTimeNow() end
local function toast(p: Player, text: string, good: boolean?)
	Remotes.Fx:FireClient(p, "Toast", text, good == true)
end

-- a player who can trade right now (in the park, save loaded)
local function canTrade(p: Player): (boolean, string?)
	if not p.Parent then return false, "LEFT THE GAME" end
	if p:GetAttribute("InMatch") then return false, "IS IN A FIGHT" end
	if not Data.get(p) then return false, "IS STILL LOADING" end
	-- (a save that failed to load is not written back: trading with it could copy things)
	if not Data.loaded(p) and not RunService:IsStudio() then return false, "HAS NO SAVE RIGHT NOW" end
	if p:GetAttribute("Boarding") then return false, "IS BOARDING THE TRAIN" end
	return true, nil
end

local function other(s: Session, p: Player): (Side, Side)
	if s.a.p == p then return s.a, s.b end
	return s.b, s.a
end

-- what one side can see: its own offer, the partner's offer, the timers
local function view(s: Session, me: Side, them: Side): any
	return {
		partner = them.name, partnerId = them.userId,
		me = { cash = me.cash, forms = me.forms, ready = me.ready },
		them = { cash = them.cash, forms = them.forms, ready = them.ready },
		lock = s.lockUntil, final = s.final, bot = them.bot ~= nil,
	}
end

local function push(s: Session)
	if s.closed then return end
	if s.a.p then Remotes.Trade:FireClient(s.a.p, "state", view(s, s.a, s.b)) end
	if s.b.p then Remotes.Trade:FireClient(s.b.p, "state", view(s, s.b, s.a)) end
end

local function close(s: Session, text: string, done: boolean?)
	if s.closed then return end
	s.closed = true
	for _, side in { s.a, s.b } do
		local p = side.p
		if p then
			if sessions[p] == s then sessions[p] = nil end
			p:SetAttribute("Trading", nil)
			if p.Parent then Remotes.Trade:FireClient(p, "closed", text, done == true) end
		end
	end
end

-- what a side owns (a real player's save, or the bot's pockets)
local function cashOf(side: Side): number
	if side.bot then return side.bot.cash end
	local d = side.p and Data.get(side.p)
	return d and d.Cash or 0
end
local function countOf(side: Side, id: string): number
	if side.bot then return side.bot.forms[id] or 0 end
	return side.p and Data.formCount(side.p, id) or 0
end

-- check an offer against what the side owns; returns the cleaned offer or nil + why
local function clean(side: Side, cash: any, forms: any): ({ cash: number, forms: { [string]: number } }?, string?)
	local c = tonumber(cash) or 0
	if c ~= c then c = 0 end
	c = math.clamp(math.floor(c), 0, MAX_CASH)
	if c > cashOf(side) then return nil, "YOU DON'T HAVE $" .. c end
	local out = {} :: { [string]: number }
	local n = 0
	if type(forms) == "table" then
		for id, k in forms do
			if type(id) ~= "string" or not Forms.byId[id] then continue end
			local copies = tonumber(k) or 0
			if copies ~= copies then continue end
			copies = math.floor(copies)
			if copies < 1 then continue end
			if copies > countOf(side, id) then return nil, "YOU DON'T HAVE " .. copies .. " x " .. Forms.byId[id].name end
			n += 1
			if n > MAX_FORMS then return nil, "AT MOST " .. MAX_FORMS .. " DIFFERENT FORMS IN ONE TRADE" end
			out[id] = copies
		end
	end
	return { cash = c, forms = out }, nil
end

-- THE SWAP: everything checked again, then moved in one go
local function execute(s: Session)
	if s.closed then return end
	for _, side in { s.a, s.b } do
		if side.p then
			local ok, why = canTrade(side.p)
			if not ok then close(s, string.upper(side.name) .. " " .. (why or "CAN'T TRADE")); return end
		end
		local c = clean(side, side.cash, side.forms)
		if not c then close(s, "TRADE CANCELLED: " .. string.upper(side.name) .. " NO LONGER HAS WHAT THEY OFFERED"); return end
	end
	-- (the checks passed: from here on nothing yields)
	local function move(from: Side, to: Side)
		if from.cash > 0 then
			if from.bot then from.bot.cash -= from.cash
			elseif from.p then (Data.get(from.p) :: any).Cash -= from.cash end
			if to.bot then to.bot.cash += from.cash
			elseif to.p then (Data.get(to.p) :: any).Cash += from.cash end
		end
		for id, n in from.forms do
			if from.bot then from.bot.forms[id] = (from.bot.forms[id] or 0) - n
			elseif from.p then Data.takeForm(from.p, id, n, false) end
			if to.bot then to.bot.forms[id] = (to.bot.forms[id] or 0) + n
			elseif to.p then Data.giveForm(to.p, id, n, false) end
		end
	end
	move(s.a, s.b)
	move(s.b, s.a)
	local summary = {}
	for _, side in { s.a, s.b } do
		local n = 0
		for _, k in side.forms do n += k end
		table.insert(summary, string.format("%s: $%d + %d form%s", side.name, side.cash, n, n == 1 and "" or "s"))
	end
	print("[Trade] done - " .. table.concat(summary, " | "))
	for _, side in { s.a, s.b } do
		local p = side.p
		if p then
			Data.refresh(p)
			Combat.refreshHealth(p)
			task.spawn(Data.save, p)
		end
	end
	close(s, "TRADE DONE!", true)
end

local function changed(s: Session)
	s.a.ready = false; s.b.ready = false
	s.final = 0
	s.token += 1
	s.lockUntil = now() + LOCK
	push(s)
end

local function botThink(s: Session)
	-- the Studio test partner: ready a moment after you, once READY unlocks
	local bot = s.a.bot and s.a or (s.b.bot and s.b or nil)
	local human = bot == s.a and s.b or s.a
	if not bot or bot.ready or not human.ready then return end
	local tok = s.token
	task.delay(math.max(0.8, s.lockUntil - now() + 0.2), function()
		if s.closed or s.token ~= tok or not human.ready or bot.ready then return end
		bot.ready = true
		Trade.bothReady(s)
	end)
end

function Trade.bothReady(s: Session)
	push(s)
	if not (s.a.ready and s.b.ready) then
		botThink(s)
		return
	end
	s.final = now() + FINAL
	s.token += 1
	local tok = s.token
	push(s)
	task.delay(FINAL, function()
		if not s.closed and s.token == tok and s.a.ready and s.b.ready then execute(s) end
	end)
end

local function open(a: Player, b: Player?, bot: boolean?)
	local function side(p: Player?): Side
		return { p = p, name = p and p.DisplayName or "TRADE BOT", userId = p and p.UserId or 0, cash = 0, forms = {}, ready = false }
	end
	local s: Session = { a = side(a), b = side(b), lockUntil = now() + LOCK, final = 0, token = 0, closed = false }
	if bot then
		-- the bot's pockets: some cash and three random forms of the first set; it offers $250 and one form
		local pockets = { cash = 5000, forms = {} :: { [string]: number } }
		local pool = {}
		for _, fm in Forms.list do if fm.set == "Camp" and fm.rarity <= 3 then table.insert(pool, fm.id) end end
		for _ = 1, 3 do local id = pool[rng:NextInteger(1, #pool)]; pockets.forms[id] = (pockets.forms[id] or 0) + 1 end
		s.b.bot = pockets
		s.b.cash = 250
		local first = next(pockets.forms)
		if first then s.b.forms[first] = 1 end
	end
	sessions[a] = s
	a:SetAttribute("Trading", true)
	if b then sessions[b] = s; b:SetAttribute("Trading", true) end
	push(s)
end

local function request(p: Player, userId: any)
	local target = type(userId) == "number" and Players:GetPlayerByUserId(userId) or nil
	if not target or target == p then return end
	if os.clock() - (lastAsk[p] or 0) < 2 then return end
	lastAsk[p] = os.clock()
	local ok, why = canTrade(p)
	if not ok then toast(p, "YOU CAN'T TRADE RIGHT NOW"); return end
	if sessions[p] then toast(p, "FINISH YOUR TRADE FIRST"); return end
	ok, why = canTrade(target)
	if not ok then toast(p, string.upper(target.DisplayName) .. " " .. (why or "CAN'T TRADE")); return end
	if sessions[target] then toast(p, string.upper(target.DisplayName) .. " IS ALREADY TRADING"); return end
	-- they asked you first: that's a yes
	local mine = requests[p]
	if mine and mine[target] and mine[target] > os.clock() then
		mine[target] = nil
		open(target, p)
		return
	end
	requests[target] = requests[target] or {}
	;(requests[target] :: any)[p] = os.clock() + REQUEST_LIFE
	Remotes.Trade:FireClient(target, "request", p.UserId, p.DisplayName)
	toast(p, "TRADE REQUEST SENT TO " .. string.upper(target.DisplayName), true)
end

local function answer(p: Player, userId: any, yes: any)
	local asker = type(userId) == "number" and Players:GetPlayerByUserId(userId) or nil
	local mine = requests[p]
	if not asker or not mine or not mine[asker] then return end
	local live = mine[asker] > os.clock()
	mine[asker] = nil
	if not live then toast(p, "THAT REQUEST RAN OUT"); return end
	if yes ~= true then
		toast(asker, string.upper(p.DisplayName) .. " SAID NO TO THE TRADE")
		return
	end
	for _, x in { p, asker } do
		local ok, why = canTrade(x)
		if not ok then toast(p, string.upper(x.DisplayName) .. " " .. (why or "CAN'T TRADE")); return end
		if sessions[x] then toast(p, string.upper(x.DisplayName) .. " IS ALREADY TRADING"); return end
	end
	open(asker, p)
end

local function offer(p: Player, t: any)
	local s = sessions[p]
	if not s or s.closed or type(t) ~= "table" then return end
	-- (at most 12 changes a second)
	local lo = lastOffer[p]
	if not lo or os.clock() - lo.t > 1 then lo = { t = os.clock(), n = 0 }; lastOffer[p] = lo end
	lo.n += 1
	if lo.n > 12 then return end
	local me = other(s, p)
	local c, why = clean(me, t.cash, t.forms)
	if not c then toast(p, why or "CAN'T OFFER THAT"); push(s); return end
	me.cash = c.cash
	me.forms = c.forms
	changed(s)
end

local function ready(p: Player, on: any)
	local s = sessions[p]
	if not s or s.closed then return end
	local me = other(s, p)
	if on == true then
		if now() < s.lockUntil then push(s); return end
		local c = clean(me, me.cash, me.forms)
		if not c then toast(p, "YOU NO LONGER HAVE WHAT YOU OFFERED"); return end
		me.ready = true
	else
		me.ready = false
		s.final = 0
		s.token += 1
	end
	Trade.bothReady(s)
end

function Trade.start()
	Remotes.Trade.OnServerEvent:Connect(function(p, action, a, b)
		if action == "request" then request(p, a)
		elseif action == "answer" then answer(p, a, b)
		elseif action == "offer" then offer(p, a)
		elseif action == "ready" then ready(p, a)
		elseif action == "cancel" then
			local s = sessions[p]
			if s then
				local _, them = other(s, p)
				close(s, string.upper(p.DisplayName) .. " CANCELLED THE TRADE")
				local _ = them
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(p)
		local s = sessions[p]
		if s then close(s, string.upper(p.DisplayName) .. " LEFT THE GAME") end
		requests[p] = nil; lastAsk[p] = nil; lastOffer[p] = nil
		for _, m in requests do m[p] = nil end
	end)
	-- a trade ends when one of them goes into a fight / boards the train / leaves
	task.spawn(function()
		while true do
			task.wait(1)
			local seen = {} :: { [Session]: boolean }
			for _, s in sessions do
				if seen[s] or s.closed then continue end
				seen[s] = true
				for _, side in { s.a, s.b } do
					if side.p then
						local ok, why = canTrade(side.p)
						if not ok then close(s, string.upper(side.name) .. " " .. (why or "CAN'T TRADE")); break end
					end
				end
			end
		end
	end)
end

-- Studio test partner (admin "trade bot")
function Trade.bot(p: Player): (boolean, string)
	if not RunService:IsStudio() then return false, "The trade bot is for Studio only" end
	if sessions[p] then return false, "Already trading" end
	open(p, nil, true)
	return true, "Trading with the TRADE BOT (it readies after you)"
end

return Trade
