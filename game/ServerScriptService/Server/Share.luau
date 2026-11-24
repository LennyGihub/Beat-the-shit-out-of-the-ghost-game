--!strict
-- INVITES + SHARE LINKS (2026-11-24, the business guide: Roblox pays the creator 35% of what a new player spends in
-- their first 60 days when they came through a share link; the lobby's INVITE button, Client/ShareUI).
--   Remotes.Share ("link"): Roblox's share sheet with a share link (SocialService:PromptLinkSharingAsync, server
--     only). The friend invite itself is client side (SocialService:PromptGameInvite). Both carry LaunchData
--     "ref:<inviter's UserId>", and so do the moments shared from Client/ShareUI (CaptureService).
--   THE REWARD: a player whose save is BRAND NEW and who joined with someone's "ref:" (Player:GetJoinData) is linked
--     to them (Data `Ref` = { by, t, done }); once they have played 10 minutes (counted across servers in that
--     save), the inviter earns a reward: a counter in the "Referrals" DataStore (key "r_<id>", UpdateAsync only), told
--     to their server with MessagingService. The inviter's server claims it (on join, on that message, every 5 min):
--     at most DAILY a UTC day, the rest waits for the next day. Reward = Share.reward(level) cash.
--   Alt-account farming is capped by DAILY and the 10 minutes of real play.
-- Studio: no DataStore / messaging; admin `ref <userId>` links you as if you had joined with that id's link (the
-- 10 minutes then count as usual; `ref done` finishes them now) - Server/Admin.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local DSS = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local SocialService = game:GetService("SocialService")
local RunService = game:GetService("RunService")
local Remotes = require(script.Parent.Remotes)
local Guard = require(script.Parent.Guard)
local Data = require(script.Parent.Data)
local Analytics = require(script.Parent.Analytics)

local Share = {}

Share.PLAY = 600 -- seconds a new player must play
Share.DAILY = 5 -- rewards an inviter can claim a UTC day
-- cash for one friend: grows with the inviter's level (level 1: $125, 10: $350, 30: $850)
function Share.reward(level: number): number return 100 + 25 * math.clamp(math.floor(level), 1, 200) end

local STUDIO = RunService:IsStudio()
local TOPIC = "Referral"
local okStore, store = pcall(function() return DSS:GetDataStore("Referrals_v1") end)
local lastLink: { [Player]: number } = {}

local function toast(p: Player, text: string, good: boolean?)
	Remotes.Fx:FireClient(p, "Toast", text, good)
end

local function today(): number return math.floor(os.time() / 86400) end

-- the inviter collects what is waiting for them
local function claim(p: Player)
	if STUDIO or not okStore or not Data.loaded(p) then return end
	local got = 0
	local ok, err = pcall(function()
		store:UpdateAsync("r_" .. p.UserId, function(rec: any)
			got = 0
			if type(rec) ~= "table" then return nil end
			local n = math.max(0, math.floor(tonumber(rec.n) or 0))
			if n == 0 then return nil end
			local d = today()
			local used = (rec.day == d) and math.max(0, math.floor(tonumber(rec.used) or 0)) or 0
			got = math.min(n, Share.DAILY - used)
			if got <= 0 then got = 0; return nil end
			return { n = n - got, day = d, used = used + got }
		end)
	end)
	if not ok then warn("[Share] claim failed: " .. tostring(err)); return end
	if got <= 0 or not p.Parent then return end
	local each = Share.reward(tonumber(p:GetAttribute("Level")) or 1)
	Data.addCash(p, each * got, "Referral", "Friend")
	task.spawn(Data.save, p)
	Analytics.custom(p, "ReferralReward", got)
	toast(p, (got == 1 and "A FRIEND YOU INVITED" or (got .. " FRIENDS YOU INVITED")) .. " PLAYED 10 MINUTES: +$" .. (each * got), true)
	Remotes.Fx:FireClient(p, "ShareReward", got, each * got)
end

-- the new player reached 10 minutes: one reward for their inviter
local function credit(by: number, newcomer: Player)
	Analytics.custom(newcomer, "ReferralQualified", 1)
	if STUDIO then
		print("[Share] (Studio) " .. newcomer.Name .. " played " .. Share.PLAY .. " s: " .. by .. " would get a reward")
		local inviter = Players:GetPlayerByUserId(by)
		if inviter then
			local each = Share.reward(tonumber(inviter:GetAttribute("Level")) or 1)
			Data.addCash(inviter, each, "Referral", "Friend")
			toast(inviter, "A FRIEND YOU INVITED PLAYED 10 MINUTES: +$" .. each, true)
			Remotes.Fx:FireClient(inviter, "ShareReward", 1, each)
		end
		return
	end
	if not okStore then return end
	local ok, err = pcall(function()
		store:UpdateAsync("r_" .. by, function(rec: any)
			rec = type(rec) == "table" and rec or {}
			rec.n = math.min(1000, math.max(0, math.floor(tonumber(rec.n) or 0)) + 1)
			return rec
		end)
	end)
	if not ok then warn("[Share] credit failed: " .. tostring(err)); return end
	pcall(function() MessagingService:PublishAsync(TOPIC, by) end)
	local here = Players:GetPlayerByUserId(by)
	if here then task.spawn(claim, here) end
end

-- right after Data.load: link a brand-new save to whoever invited them
function Share.setup(p: Player)
	local d = Data.get(p) :: any
	if not d then return end
	if Data.isNew(p) and d.Ref == nil then
		local ok, join = pcall(function() return p:GetJoinData() end)
		local launch = ok and type(join) == "table" and join.LaunchData
		local by = type(launch) == "string" and tonumber(string.match(launch, "^ref:(%d+)$")) or nil
		if by and by ~= p.UserId and by > 0 then
			d.Ref = { by = by, t = 0, done = false }
			Analytics.custom(p, "JoinedByInvite", 1)
			local inviter = Players:GetPlayerByUserId(by)
			toast(p, "WELCOME! " .. (inviter and string.upper(inviter.Name) or "A FRIEND") .. " INVITED YOU", true)
		end
	end
	task.delay(8, claim, p)
end

-- admin / Studio: link (or finish) by hand
function Share.debugLink(p: Player, by: number?)
	local d = Data.get(p) :: any
	if not d then return end
	if by then d.Ref = { by = by, t = 0, done = false }
	elseif d.Ref and not d.Ref.done then d.Ref.t = Share.PLAY end
end

function Share.start()
	Remotes.Share.OnServerEvent:Connect(function(p: Player, what: any) if not Guard.ok(p, "Share") then return end
		if what ~= "link" then return end
		if os.clock() - (lastLink[p] or 0) < 4 then return end
		lastLink[p] = os.clock()
		task.spawn(function()
			local ok, err = pcall(function()
				SocialService:PromptLinkSharingAsync(p, { LaunchData = "ref:" .. p.UserId })
			end)
			if not ok then
				warn("[Share] link failed: " .. tostring(err))
				toast(p, "SHARE LINKS DON'T WORK HERE - TRY INVITE FRIENDS")
			else
				Analytics.custom(p, "ShareLink", 1)
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(p) lastLink[p] = nil end)
	-- someone's friend reached 10 minutes in another server
	if not STUDIO then
		pcall(function()
			MessagingService:SubscribeAsync(TOPIC, function(msg)
				local id = tonumber(msg.Data)
				local p = id and Players:GetPlayerByUserId(id)
				if p then task.spawn(claim, p) end
			end)
		end)
	end
	-- play time of linked newcomers (counted in their save), and a slow fallback claim for everyone
	task.spawn(function()
		local STEP = 15
		local sinceClaim = 0
		while true do
			task.wait(STEP)
			sinceClaim += STEP
			for _, p in Players:GetPlayers() do
				local d = Data.get(p) :: any
				local r = d and d.Ref
				if r and not r.done and (Data.loaded(p) or STUDIO) then
					r.t += STEP
					if r.t >= Share.PLAY then
						r.done = true
						task.spawn(Data.save, p)
						task.spawn(credit, r.by, p)
					end
				end
				if sinceClaim >= 300 then task.spawn(claim, p) end
			end
			if sinceClaim >= 300 then sinceClaim = 0 end
		end
	end)
end

return Share
