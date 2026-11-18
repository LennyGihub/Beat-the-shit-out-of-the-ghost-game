--!strict
-- The two sellers of FORMS in the park (Shared/Forms): DOC MERCY's ectoplasm jars and MOTHER MOTH's potions.
-- Their stalls are workspace.Lobby.Sellers.DocMercy / .MotherMoth (tools/build/sellers.luau), each with a "Prompt"
-- part: the prompt opens the client's seller panel (Fx "OpenSeller", kind). Remotes.Forms:
--   ("buy", vialId)  -> level + cash checked, the form is rolled HERE (never by the client), added to the collection
--                       and saved; worn at once if no form of that kind was worn yet. The client then plays the
--                       first-person jar / drink (Fx "FormRolled": kind, vialId, formId, isNew, worn, prevId).
--   ("equip", formId) -> wear a form you own (Fx "FormEquipped").
-- Combat.stat reads the worn forms (health, stamina, damage, knockback).
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Forms = require(RS.Shared.Forms)
local Levels = require(RS.Shared.Levels)
local Remotes = require(script.Parent.Remotes)
local Data = require(script.Parent.Data)
local Combat = require(script.Parent.Combat)

local M = {}
local rng = Random.new()
local lastBuy = {} :: { [Player]: number }
local BUY_GAP = 6 -- seconds between two buys (the cinematic plays in between)
local REACH = 40 -- studs from the seller a buy is accepted from

local function sellerPart(kind: string): BasePart?
	local lobby = workspace:FindFirstChild("Lobby")
	local f = lobby and lobby:FindFirstChild("Sellers")
	local m = f and f:FindFirstChild(kind == "stim" and "DocMercy" or "MotherMoth")
	return m and m:FindFirstChild("Prompt", true) :: BasePart?
end

local function toast(p: Player, text: string, good: boolean?)
	Remotes.Fx:FireClient(p, "FormResult", good == true, text)
end

local function buy(p: Player, vialId: any)
	local v = type(vialId) == "string" and Forms.vialById[vialId] or nil
	if not v then return end
	if p:GetAttribute("InMatch") then return end
	if os.clock() - (lastBuy[p] or 0) < BUY_GAP then return end
	local level = (Levels.of(p:GetAttribute("XP") or 0))
	if level < v.level then toast(p, v.name .. " NEEDS LEVEL " .. v.level); return end
	-- (the seller's stall must be near: a buy is made at the counter)
	local at = sellerPart(v.kind)
	local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if at and hrp and (hrp.Position - at.Position).Magnitude > REACH then return end
	if not Data.spend(p, v.price) then toast(p, "NOT ENOUGH CASH FOR " .. v.name); return end
	lastBuy[p] = os.clock()
	local fm = Forms.roll(v, rng)
	local prev = Data.formOf(p, v.kind)
	local isNew = Data.addForm(p, fm.id)
	-- nothing worn yet: wear it now; otherwise the player picks (EQUIP / KEEP on the reveal card)
	local worn = prev == nil
	if worn then Data.equipForm(p, fm.id) end
	task.spawn(Data.save, p)
	Combat.refreshHealth(p)
	Remotes.Fx:FireClient(p, "FormRolled", v.kind, v.id, fm.id, isNew, worn, prev or "")
end

local function equip(p: Player, id: any)
	local fm = type(id) == "string" and Forms.byId[id] or nil
	if not fm or not Data.ownsForm(p, fm.id) then return end
	if Data.equipForm(p, fm.id) then
		Combat.refreshHealth(p)
		Remotes.Fx:FireClient(p, "FormEquipped", fm.kind, fm.id)
	end
end

function M.start()
	Remotes.Forms.OnServerEvent:Connect(function(p, action, a)
		if action == "buy" then buy(p, a)
		elseif action == "equip" then equip(p, a) end
	end)
	Players.PlayerRemoving:Connect(function(p) lastBuy[p] = nil end)
	-- the prompts on the two stalls (they may be built after the server started: look for a while)
	task.spawn(function()
		local done = {} :: { [string]: boolean }
		for _ = 1, 30 do
			for _, kind in { "stim", "potion" } do
				local part = not done[kind] and sellerPart(kind) or nil
				if part then
					done[kind] = true
					local s = Forms.SELLER[kind]
					local pp = Instance.new("ProximityPrompt")
					pp.ActionText = kind == "stim" and "Buy ectoplasm" or "Buy a potion"
					pp.ObjectText = kind == "stim" and "Doc Mercy" or "Mother Moth"
					pp.HoldDuration = 0; pp.MaxActivationDistance = 13; pp.RequiresLineOfSight = false
					pp.KeyboardKeyCode = Enum.KeyCode.F
					pp.Style = Enum.ProximityPromptStyle.Custom
					pp.Parent = part
					pp.Triggered:Connect(function(p)
						if not p:GetAttribute("InMatch") then Remotes.Fx:FireClient(p, "OpenSeller", kind) end
					end)
					local _ = s
				end
			end
			if done.stim and done.potion then break end
			task.wait(2)
		end
	end)
end

return M
