--!strict
-- Quest definitions (server tracks them in Server/Quests, the lobby QUESTS panel shows them).
-- stat = the counter the game bumps (Quests.add / Quests.max on the server):
--   kills (monsters knocked out), hits (punches and melee hits that land), charged (fully charged hits),
--   blocks (attacks blocked), throws (furniture/items thrown into a monster), runs (runs finished),
--   buys (items bought in event shops), wave (highest monster level knocked out in one run, a max),
--   combo (highest combo, a max), kill_<MonsterId> (that monster knocked out), nightmare (kills on NIGHTMARE),
--   maps / ults (how many the player owns: read from the save, not counted).
-- DAILY: 3 are picked per player per day (UTC). ACHIEVEMENTS: permanent, claimed once.
export type Quest = { id: string, name: string, text: string, stat: string, goal: number, reward: number }

local function q(id: string, name: string, text: string, stat: string, goal: number, reward: number): Quest
	return { id = id, name = name, text = text, stat = stat, goal = goal, reward = reward }
end

local DAILY: { Quest } = {
	q("d_kills", "MONSTER MASH", "Knock out 5 monsters", "kills", 5, 300),
	q("d_hits", "HEAVY HANDS", "Land 60 hits", "hits", 60, 250),
	q("d_charged", "WIND UP", "Land 5 fully charged hits", "charged", 5, 250),
	q("d_blocks", "IRON GUARD", "Block 10 attacks", "blocks", 10, 250),
	q("d_throws", "FURNITURE TOSS", "Hit monsters with 8 thrown objects", "throws", 8, 300),
	q("d_runs", "NIGHT SHIFT", "Finish 2 runs", "runs", 2, 300),
	q("d_wave", "STAYING ALIVE", "Knock out a level 5 monster", "wave", 5, 400),
	q("d_buys", "SHOPPING SPREE", "Buy 2 items in event shops", "buys", 2, 200),
}

local ACHIEVEMENTS: { Quest } = {
	q("a_first", "FIRST BLOOD", "Knock out your first monster", "kills", 1, 200),
	q("a_kills50", "GHOST BUSTER", "Knock out 50 monsters", "kills", 50, 1500),
	q("a_kills250", "EXTERMINATOR", "Knock out 250 monsters", "kills", 250, 5000),
	q("a_demon", "DEMON SLAYER", "Knock out the Red Demon", "kill_Demon", 1, 500),
	q("a_pirate", "WALK THE PLANK", "Knock out the Pirate", "kill_Pirate", 1, 500),
	q("a_goblin", "GOBLIN GRABBER", "Knock out the Goblin", "kill_Goblin", 1, 500),
	q("a_bear", "LIGHTS ON", "Knock out the Party Bear", "kill_Animatronic", 1, 800),
	q("a_combo", "COMBO KING", "Reach a 20 hit combo", "combo", 20, 800),
	q("a_blocks", "IRON WALL", "Block 100 attacks", "blocks", 100, 1000),
	q("a_throws", "HEAVY LIFTER", "Hit monsters with 100 thrown objects", "throws", 100, 1000),
	q("a_wave", "SURVIVOR", "Knock out a level 10 monster", "wave", 10, 1500),
	q("a_nightmare", "NO FEAR", "Knock out a monster on NIGHTMARE", "nightmare", 1, 2000),
	q("a_maps", "EXPLORER", "Own 5 maps", "maps", 5, 1000),
	q("a_ults", "COLLECTOR", "Own 10 ultimates", "ults", 10, 1500),
}

local byId: { [string]: Quest } = {}
for _, x in DAILY do byId[x.id] = x end
for _, x in ACHIEVEMENTS do byId[x.id] = x end

-- max-type stats keep the best value instead of adding up
local MAX_STATS = { wave = true, combo = true }

return { daily = DAILY, achievements = ACHIEVEMENTS, byId = byId, maxStats = MAX_STATS, dailyCount = 3 }
