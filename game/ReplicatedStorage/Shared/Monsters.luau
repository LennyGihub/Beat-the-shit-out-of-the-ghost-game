--!strict
-- The monsters: the Woman (always ghost 1), the Red Demon, the Pirate and the Goblin (rare). pick() falls back to the Woman.
-- template = model name in ServerStorage.Monsters (the Woman uses ServerStorage.GhostTemplate).
-- hp/speed/dmg/reward multiply the level-based values in Config.Ghost / Config.Reward.
-- hover = root height above the floor (floaters ~4.6, walkers = their hip height).
-- ability = what the Abilities module runs (cd = seconds between uses).
-- objTaken = damage multiplier for thrown objects (furniture, thrown items); 1 if left out.
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
	m({ id = "Demon", name = "The Red Demon", title = "THE RED DEMON", rarity = 1, template = "Demon", color = C(200, 40, 30),
		hp = 1.15, speed = 0.95, dmg = 1.3, reward = 1.5, hover = 0, walker = true, scale = 1, solid = true, -- solid: no walking through walls
		objTaken = 1.25, -- furniture and thrown items hurt him more
		ability = { kind = "levitateThrow", cd = 6.5, range = 70, lift = 1.3, aim = 0.45, power = 150, dmg = 22 },
		desc = "Lifts the furniture with his mind and hurls it at you." }),
	m({ id = "Pirate", name = "The Pirate", title = "THE PIRATE", rarity = 1, template = "Pirate", color = C(226, 214, 186),
		hp = 1.1, speed = 1.05, dmg = 1.2, reward = 1.5, hover = 0, walker = true, scale = 1, solid = true,
		objTaken = 1.25, -- furniture and thrown items hurt him more (his shield only halves them, see Ghost.hit)
		-- shield bash: braces (shield up, blocks hits from the front), then rushes you and sends you flying into the walls
		ability = { kind = "shieldBash", cd = 5.5, min = 7, max = 45, brace = 0.7, speed = 72, power = 135, dmg = 14, wallDmg = 16 },
		desc = "A skeleton with a cutlass and a shield. His shield bash throws you into the walls; his raised shield blocks hits." }),
	m({ id = "Animatronic", name = "The Party Bear", title = "THE PARTY BEAR", rarity = 2, template = "Animatronic", color = C(104, 78, 56),
		hp = 1.3, speed = 1.0, dmg = 1.25, reward = 1.6, hover = 0, walker = true, scale = 1, solid = true,
		-- kills every light in the house and stalks you in the dark (only its eyes glow); reaching you = a jumpscare and a heavy hit
		ability = { kind = "blackout", cd = 14, t = 10, dmg = 30, speed = 15, lightsOut = true },
		desc = "A rotting party-mascot bear. It shuts every light off and hunts you in the dark: only its eyes glow." }),
	m({ id = "Goblin", name = "The Goblin", title = "THE GOBLIN", rarity = 2, template = "Goblin", color = C(110, 190, 60),
		hp = 1.25, speed = 1.08, dmg = 1, reward = 1.6, hover = 0, walker = true, scale = 1, solid = true,
		ability = { kind = "steal", cd = 6, range = 11 }, -- grabs the item in your hands, then uses it on you
		desc = "Steals the item in your hands and uses it against you. Knock him out to get it back." }),
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
