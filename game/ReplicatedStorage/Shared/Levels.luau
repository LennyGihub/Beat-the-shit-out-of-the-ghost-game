--!strict
-- PLAYER LEVELS: every run pays XP (Server/Run, when the run ends: Levels.runXP), saved as the player's total XP
-- (Server/Data). The level comes from the total; every 5 levels comes a new TITLE. Both are shown over the
-- player's head in the lobby (Client/NameTags) and, for the player themselves, in the lobby's corner
-- (Client/LevelUI). Player attributes (Server/Data): XP (total), Level.
local Levels = {}

-- XP to go from level n to n + 1: 100, 150, 200... (level 5 after ~5 runs, level 10 after ~20)
function Levels.need(level: number): number
	return 100 + (level - 1) * 50
end

Levels.MAX = 200

-- the level for a total of XP, the XP already into that level and the XP the next level needs
function Levels.of(xp: number): (number, number, number)
	local level, left = 1, math.max(0, math.floor(xp))
	while level < Levels.MAX and left >= Levels.need(level) do
		left -= Levels.need(level)
		level += 1
	end
	return level, left, Levels.need(level)
end

-- the total XP a level starts at (level 1 = 0)
function Levels.total(level: number): number
	local n = 0
	for l = 1, math.clamp(math.floor(level), 1, Levels.MAX) - 1 do n += Levels.need(l) end
	return n
end

-- the titles, one every 5 levels (the last one stays after level 100)
local TITLES: { { at: number, name: string, color: Color3 } } = {
	{ at = 1, name = "FRESH MEAT", color = Color3.fromRGB(190, 182, 168) },
	{ at = 5, name = "GHOST PUNCHER", color = Color3.fromRGB(232, 224, 205) },
	{ at = 10, name = "HOUSE BRAWLER", color = Color3.fromRGB(140, 210, 110) },
	{ at = 15, name = "SPOOK SMASHER", color = Color3.fromRGB(110, 210, 190) },
	{ at = 20, name = "HAUNT HUNTER", color = Color3.fromRGB(110, 170, 240) },
	{ at = 25, name = "EXORCIST", color = Color3.fromRGB(150, 130, 245) },
	{ at = 30, name = "GRAVE KEEPER", color = Color3.fromRGB(190, 120, 240) },
	{ at = 35, name = "NIGHT STALKER", color = Color3.fromRGB(230, 110, 200) },
	{ at = 40, name = "BONE CRUSHER", color = Color3.fromRGB(245, 150, 80) },
	{ at = 45, name = "DEMON SLAYER", color = Color3.fromRGB(240, 90, 60) },
	{ at = 50, name = "NIGHTMARE WALKER", color = Color3.fromRGB(230, 45, 45) },
	{ at = 55, name = "SOUL TAKER", color = Color3.fromRGB(120, 230, 255) },
	{ at = 60, name = "PHANTOM KILLER", color = Color3.fromRGB(170, 255, 220) },
	{ at = 65, name = "CRYPT LORD", color = Color3.fromRGB(200, 160, 255) },
	{ at = 70, name = "DOOM BRINGER", color = Color3.fromRGB(255, 120, 120) },
	{ at = 75, name = "THE UNHAUNTED", color = Color3.fromRGB(255, 255, 255) },
	{ at = 80, name = "GHOST REAPER", color = Color3.fromRGB(255, 215, 90) },
	{ at = 85, name = "TERROR OF THE DEAD", color = Color3.fromRGB(255, 170, 40) },
	{ at = 90, name = "KING OF THE NIGHT", color = Color3.fromRGB(255, 200, 60) },
	{ at = 95, name = "LEGEND OF THE HOUSE", color = Color3.fromRGB(255, 230, 120) },
	{ at = 100, name = "BEAT THE GHOST", color = Color3.fromRGB(255, 240, 160) },
}

-- the title of a level, its colour, and whether this level is the one that gives it (a level-up to a new title)
function Levels.title(level: number): (string, Color3, boolean)
	local best = TITLES[1]
	for _, t in TITLES do
		if level >= t.at then best = t end
	end
	return best.name, best.color, best.at == level and level > 1
end

-- the XP a finished run pays: something for playing, more for each monster beaten and for the damage dealt, times
-- the difficulty. Nothing for a run without a single hit (no XP for standing still).
local DIFF = { Easy = 0.75, Normal = 1, Hard = 1.4, Nightmare = 2 } :: { [string]: number }
function Levels.diffMult(diffId: string): number return DIFF[diffId] or 1 end
function Levels.runXP(kills: number, damage: number, diffId: string): number
	if kills <= 0 and damage <= 0 then return 0 end
	local base = 20 + kills * 30 + math.min(damage / 40, 400)
	return math.floor(base * (DIFF[diffId] or 1))
end

return Levels
