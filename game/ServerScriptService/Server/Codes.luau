--!strict
-- REDEEMABLE CODES (2026-11-22, the user: "add redeemable codes to the game"). The lobby's CODES button
-- (Client/CodesUI) sends Remotes.Codes ("redeem", text); the code is checked HERE (the list never goes to the client).
-- A code is typed any way: case, spaces and dashes don't count ("alpha tester" = "ALPHA-TESTER" = "ALPHATESTER").
-- Each player can use each code once (saved: Data "Codes"). A code gives FORMS (Shared/Forms, exclusive ones: in
-- no jar / potion, can't be traded), cash, or both; each form plays its first-person jar / potion cinematic on the
-- client, one after the other (Fx "CodeReward": kind, formId, isNew, worn, prevId; Client/FormCine, then WEAR IT /
-- KEEP). A code typed again after forms were added to it gives the ones the player doesn't have yet (no cash again).
-- Answers: Fx "CodeResult" (ok, message). Codes are redeemed in the park only (not in a fight) and only once the save
-- has loaded (else the reward could not be kept); a player typing wrong codes again and again is slowed down.
-- Admin: "code reset" forgets your used codes and takes the code forms back (to test again), "code <text>" redeems.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Forms = require(RS.Shared.Forms)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Combat = require(script.Parent.Combat)

local M = {}

export type Code = { forms: { string }?, cash: number?, ends: number? }
-- key = the code without spaces / dashes, in capitals. ends = unix time after which it no longer works (nil = never)
local CODES: { [string]: Code } = {
	-- the first code: ALPHA GLITCH (fist) + ALPHA HOLOGRAM (body), exclusive, the Camp LEGENDARY jar's / potion's buffs
	-- (the body form was added the same day: players who had used the code get it by typing it again)
	ALPHATESTER = { forms = { "AlphaGlitch", "AlphaHolo" } },
}
M.CODES = CODES

local GAP = 1.2 -- seconds between two tries
local WRONG_MAX = 6 -- wrong codes in a row before a pause
local WRONG_PAUSE = 30 -- seconds of that pause
local last = {} :: { [Player]: number }
local wrong = {} :: { [Player]: { n: number, untilT: number } }

function M.normalize(text: string): string
	return (string.gsub(string.upper(text), "[^%w]", ""))
end

local function answer(p: Player, ok: boolean, msg: string)
	Remotes.Fx:FireClient(p, "CodeResult", ok, msg)
end

-- redeem a code for a player. Returns ok, message (also sent to the client). force = admin (no wait, no park check)
function M.redeem(p: Player, text: any, force: boolean?): (boolean, string)
	if type(text) ~= "string" or #text > 60 then return false, "" end
	local now = os.clock()
	if not force then
		if now - (last[p] or 0) < GAP then return false, "" end
		last[p] = now
		local w = wrong[p]
		if w and now < w.untilT then
			local msg = "TOO MANY WRONG CODES - WAIT " .. math.ceil(w.untilT - now) .. " S"
			answer(p, false, msg)
			return false, msg
		end
		if p:GetAttribute("InMatch") then
			answer(p, false, "REDEEM CODES IN THE PARK")
			return false, "in a fight"
		end
	end
	local key = M.normalize(text)
	if key == "" then answer(p, false, "TYPE A CODE FIRST"); return false, "empty" end
	local c = CODES[key]
	if not c or (c.ends and os.time() > c.ends) then
		local w = wrong[p] or { n = 0, untilT = 0 }
		w.n += 1
		if w.n >= WRONG_MAX then w.n = 0; w.untilT = now + WRONG_PAUSE end
		wrong[p] = w
		local msg = c and "THIS CODE HAS EXPIRED" or "THAT CODE DOESN'T EXIST"
		answer(p, false, msg)
		return false, msg
	end
	wrong[p] = nil
	-- (a save that did not load is never written: the reward would be lost when they leave)
	if not Data.loaded(p) and not RunService:IsStudio() then
		answer(p, false, "YOUR SAVE DIDN'T LOAD - REJOIN AND TRY AGAIN")
		return false, "save not loaded"
	end
	if not Data.get(p) then return false, "no save" end
	local again = Data.codeUsed(p, key)
	-- (used before: only the forms added to the code since, if any)
	local give = {} :: { Forms.Form }
	for _, id in c.forms or {} do
		local fm = Forms.byId[id]
		if fm and not (again and Data.ownsForm(p, id)) then table.insert(give, fm) end
	end
	if again and #give == 0 then
		answer(p, false, "YOU ALREADY USED THIS CODE")
		return false, "already used"
	end
	Data.useCode(p, key)
	local got = {}
	if not again and c.cash and c.cash > 0 then
		Data.addCash(p, c.cash)
		table.insert(got, "$" .. c.cash)
	end
	for _, fm in give do
		local prev = Data.formOf(p, fm.kind)
		local isNew = not Data.ownsForm(p, fm.id)
		if isNew then Data.addForm(p, fm.id) end -- (an exclusive form: never a second copy)
		local worn = prev == nil
		if worn then Data.equipForm(p, fm.id) end
		table.insert(got, fm.name)
		Remotes.Fx:FireClient(p, "CodeReward", fm.kind, fm.id, isNew, worn, prev or "")
	end
	Combat.refreshHealth(p)
	task.spawn(Data.save, p)
	local msg = (again and "CODE UPDATED!" or "CODE REDEEMED!") .. (#got > 0 and (" YOU GOT " .. table.concat(got, " + ")) or "")
	answer(p, true, msg)
	print("[Codes] " .. p.Name .. " redeemed " .. key)
	return true, msg
end

-- admin "code reset": forget the codes used and take the code forms back
function M.reset(p: Player): string
	local d = Data.get(p)
	if not d then return "No save" end
	local n = 0
	for _ in d.Codes do n += 1 end
	d.Codes = {}
	local took = 0
	for _, c in CODES do
		for _, id in c.forms or {} do
			if Data.ownsForm(p, id) then
				Data.takeForm(p, id, Data.formCount(p, id), true)
				took += 1
			end
		end
	end
	Data.refresh(p)
	Combat.refreshHealth(p)
	return n .. " used code(s) forgotten, " .. took .. " code form(s) taken back"
end

function M.start()
	Remotes.Codes.OnServerEvent:Connect(function(p, action, text)
		if action == "redeem" then
			local ok, err = pcall(M.redeem, p, text)
			if not ok then
				warn("[Codes] " .. tostring(err))
				answer(p, false, "SOMETHING WENT WRONG - TRY AGAIN")
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(p) last[p] = nil; wrong[p] = nil end)
end

return M
