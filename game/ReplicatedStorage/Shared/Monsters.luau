--!strict
-- The monsters. Only the Woman is left (the 9 extra monsters were removed); pick() falls back to her.
-- template = model name in ServerStorage.Monsters (the Woman uses ServerStorage.GhostTemplate).
-- hp/speed/dmg/reward multiply the level-based values in Config.Ghost / Config.Reward.
-- hover = root height above the floor (floaters ~4.6, walkers = their hip height).
-- ability = what the Abilities module runs (cd = seconds between uses).
export type Monster = {
	id: string, name: string, title: string, rarity: number, template: string, color: Color3,
	hp: number, speed: number, dmg: number, reward: number, hover: number, walker: boolean, scale: number,
	ability: { kind: string, cd: number, [string]: any }, desc: string,
}

local RARITY = {
	{ name = "COMMON", color = Color3.fromRGB(200, 196, 186), weight = 60 },
	{ name = "RARE", color = Color3.fromRGB(80, 150, 240), weight = 30 },
	{ name = "LEGENDARY", color = Color3.fromRGB(255, 170, 40), weight = 10 },
}

local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local function m(t: { [string]: any }): Monster return t :: any end

local List: { Monster } = {
	m({ id = "Woman", name = "The Woman", title = "THE WOMAN IN THE HOUSE", rarity = 0, template = "GhostTemplate", color = C(150, 200, 210),
		hp = 1, speed = 1, dmg = 1, reward = 1, hover = 4.6, walker = false, scale = 1,
		ability = { kind = "scare", cd = 18 }, desc = "Vanishes and screams in your face." }),
}

local byId: { [string]: Monster } = {}
for _, d in List do byId[d.id] = d end

-- ghost 1 = the Woman; then weighted by rarity, never the same monster twice in a row
local function pick(wave: number, last: string?, rng: Random): Monster
	if wave <= 1 then return byId.Woman end
	local total = 0
	for _, r in RARITY do total += r.weight end
	local x, rar = rng:NextNumber(0, total), 1
	for i, r in RARITY do
		x -= r.weight
		if x <= 0 then rar = i; break end
	end
	local pool = {}
	for _, d in List do if d.rarity == rar and d.id ~= last then table.insert(pool, d) end end
	if #pool == 0 then return byId.Woman end
	return pool[rng:NextInteger(1, #pool)]
end

return { list = List, byId = byId, rarity = RARITY, pick = pick }
