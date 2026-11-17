--!strict
-- The monsters: the Woman (always ghost 1), the Red Demon, the Pirate and the Goblin (rare). pick() falls back to the Woman.
-- template = model name in ServerStorage.Monsters (the Woman uses ServerStorage.GhostTemplate).
-- hp/speed/dmg/reward multiply the level-based values in Config.Ghost / Config.Reward.
-- hover = root height above the floor (floaters ~4.6, walkers = their hip height).
-- ability = what the Abilities module runs (cd = seconds between uses).
-- objTaken = damage multiplier for thrown objects (furniture, thrown items); 1 if left out.
-- secret = never in the normal rotation: any ghost after the first has SECRET_CHANCE to be it instead (rarity 4).
-- smasher = every last swipe of a combo launches you through the inside walls (like an enraged / evolved monster);
-- smash = how hard.
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
		ability = { kind = "levitateThrow", cd = 6.5, range = 70, lift = 1.3, aim = 0.45, speed = 95, dmg = 22 }, -- speed: the thrown piece (studs/s)
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
	m({ id = "Titan", name = "The Flayed Giant", title = "THE FLAYED GIANT", rarity = 2, template = "Titan", color = C(170, 58, 44),
		hp = 1.6, speed = 0.82, dmg = 1.3, reward = 1.8, hover = 0, walker = true, scale = 1, solid = false,
		reach = 1.6, -- long arms: attacks from further away
		wallBreaker = true, -- too big for the doors: smashes through the inside walls in his way
		-- grabs you; with another player standing he carries you over and swings you into them twice, then throws you
		ability = { kind = "titanGrab", cd = 7.5, range = 15, swingRange = 60, swingReach = 13, carrySpeed = 26, dmg = 26, swingDmg = 20, power = 120 },
		desc = "A skinless giant, steaming. He grabs you and throws you, or uses you as a club on your friends." }),
	m({ id = "Goblin", name = "The Goblin", title = "THE GOBLIN", rarity = 2, template = "Goblin", color = C(110, 190, 60),
		hp = 1.25, speed = 1.08, dmg = 1, reward = 1.6, hover = 0, walker = true, scale = 1, solid = true,
		ability = { kind = "steal", cd = 6, range = 11 }, -- grabs the item in your hands, then uses it on you
		desc = "Steals the item in your hands and uses it against you. Knock him out to get it back." }),
	-- a masked killer with a knife: quick, goes round to your back (flank), stabs fast (atk = attack cooldown
	-- multiplier). His ambush (Server/Caller): he sits down in a corner, a phone rings, the call hints at the room he
	-- is in. Look at him = he wakes and rushes (rush seconds, no extra damage); come into his room without looking
	-- = a stab from behind for dmg; hit him while he sits or gets up = that hit x bonus. first = seconds before his
	-- first ambush, hide = how long he waits, wake = from how far a look wakes him, enter = how deep into his room
	-- an unseeing player sets him off, react = the moment he needs to get off the floor, rise = to stand up.
	m({ id = "Caller", name = "The Caller", title = "THE CALLER", rarity = 2, template = "Caller", color = C(232, 230, 222),
		hp = 0.9, speed = 1.25, dmg = 0.8, reward = 1.7, hover = 0, walker = true, scale = 1, solid = true,
		atk = 0.7, flank = true,
		ability = { kind = "ambush", cd = 30, first = 10, hide = 30, wake = 45, enter = 34, react = 0.45, rise = 0.7, rush = 4, dmg = 46, bonus = 2.5, lunge = 70 },
		desc = "A masked killer with a knife. He sits in a corner and phones you to lure you in: walk in without seeing him and he stabs you in the back. Spot him and he just comes at you." }),
	-- THE SECRET ONE: a huge purple warlord with a golden gauntlet. Slow on his feet, so he steps through a portal
	-- and comes out behind you (warp: from `min` studs away, `wind` seconds of warning); his fist sends you through
	-- the walls, and he punches his own way through them rather than use a door.
	m({ id = "Conqueror", name = "The Conqueror", title = "THE CONQUEROR", rarity = 4, secret = true, template = "Conqueror", color = C(150, 104, 190),
		hp = 1.5, speed = 0.8, dmg = 1.3, reward = 2.5, hover = 0, walker = true, scale = 1, solid = false,
		reach = 1.25, wallBreaker = true, smasher = true, smash = 1.5,
		ability = { kind = "warp", cd = 9, min = 20, wind = 0.9 },
		desc = "A warlord from somewhere else. Slow, but he steps out of a portal behind you, and one punch sends you through the walls." }),
}
-- chance that a ghost (after the first) is the secret monster: far below any other monster's
local SECRET_CHANCE = 0.03

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
	for _, d in List do if d.rarity == rar and d.id ~= last and not (d :: any).secret then table.insert(pool, d) end end
	if #pool == 0 then return byId.Woman end
	return pool[rng:NextInteger(1, #pool)]
end

-- EVOLVED monsters: every 3rd ghost is an evolved variant of one of the monsters above (same id, same voice and
-- animations; Server/Evolved.luau dresses the model and runs the extra power). Twice the health, faster, and every
-- swipe launches you through the walls. title = its name; power = the extra ability (Evolved.luau); the other
-- fields override the base monster's.
local EVO: { [string]: { [string]: any } } = {
	Woman = { title = "THE VIOLET WIDOW", color = C(170, 90, 230), scale = 1.1,
		-- ring = how far from you she and her doubles appear, spread = degrees between two of them (all in front of you),
		-- pause = seconds they stand there before they come
		power = { kind = "doubles", cd = 13, n = 3, t = 14, dmg = 10, ring = 17, spread = 26, pause = 1 },
		desc = "Purple and wrong. She splits into doubles: only one of them is real." },
	Demon = { title = "THE DEMON LORD", color = C(150, 20, 16), scale = 1.3, reach = 1.3,
		ability = { kind = "levitateThrow", cd = 6, range = 75, lift = 1.4, aim = 0.5, speed = 100, dmg = 18, count = 3 },
		desc = "Bigger, with a sceptre. He lifts several pieces of furniture at once and throws them all." },
	Goblin = { title = "THE GOBLIN KING", color = C(34, 92, 44), scale = 1.15, solid = false, wallBreaker = true,
		power = { kind = "armed", weapons = { "BaseballBat", "FryingPan", "Crowbar", "LeadPipe", "Shovel", "SpikedBat", "Machete", "FireAxe" } },
		desc = "Fat, forest green, and already armed. He punches through the walls to get to you." },
	Pirate = { title = "THE BURNING CAPTAIN", color = C(255, 90, 30), scale = 1.1,
		-- his crew jumps out of him and runs at you: one hit sends them flying, and they barely scratch (dmg)
		power = { kind = "army", cd = 15, n = 5, t = 14, dmg = 3, size = 0.42, speed = 17 },
		desc = "A skeleton on fire. He throws an army of little skeletons at you." },
	Animatronic = { title = "THE GOLDEN BEAR", color = C(240, 200, 70), scale = 1.08,
		power = { kind = "snap", cd = 9, min = 9, max = 70, wind = 0.75, dmg = 18, wall = 118, up = 105 },
		desc = "Golden. He snaps his fingers and you fly into the wall or up into the ceiling: break his line of sight." },
	-- soaked in blood, and he brought a 12 gauge: he aims (wind), fires, pumps (gap) and fires again. Cover takes
	-- a shot once: furniture is blown apart, an inside wall gets a hole in it. His ambush is quicker and hits harder.
	Caller = { title = "THE LAST CALL", color = C(170, 16, 20), scale = 1.06,
		ability = { kind = "ambush", cd = 30, first = 8, hide = 26, wake = 45, enter = 38, react = 0.3, rise = 0.55, rush = 5, dmg = 58, bonus = 2.5, lunge = 82 },
		power = { kind = "shotgun", cd = 10, wind = 1.2, gap = 1.0, shots = 2, dmg = 46, range = 95, power = 70, min = 5 },
		desc = "The same mask, red now, and a shotgun. Two shots, and each one blows your cover away." },
	-- gold armour and a helmet; everything the Conqueror does, plus the gauntlet's beam: it turns after you slowly
	-- (turn = degrees per second, sweep = studs per second, so you can always outrun it), cuts through furniture and inside walls, and burns for `dps` while you stand in it
	Conqueror = { title = "THE GOLDEN CONQUEROR", color = C(232, 186, 70), scale = 1.1,
		-- turn = degrees a second at most, sweep = studs a second at most where you stand (slower than walking)
		power = { kind = "laser", cd = 13, wind = 1.5, t = 6, range = 140, turn = 16, sweep = 10, dps = 42, width = 3 },
		desc = "In his golden war armour. The gauntlet fires a slow purple beam that cuts through the house: never stand in it." },
	Titan = { title = "THE BONE GIANT", color = C(226, 214, 190), scale = 1.08,
		power = { kind = "eat", cd = 10, below = 0.85, range = 17, t = 1.5, heal = 0.07, wallHeal = 0.04 },
		desc = "More bone than flesh. He eats the furniture and the walls to heal: hit him while he chews." },
}
-- tier 1 = the first evolved monster of a run (kept beatable), then they ramp up
local EVO_TIER = {
	{ hp = 2, speed = 1.1, dmg = 1.0, atk = 0.85, smash = 1.2 },
	{ hp = 2, speed = 1.16, dmg = 1.15, atk = 0.75, smash = 1.3 },
	{ hp = 2.2, speed = 1.22, dmg = 1.3, atk = 0.68, smash = 1.4 },
}
local evoCache: { [string]: Monster } = {}
local function evolved(id: string, tier: number): Monster
	local t = math.clamp(tier, 1, #EVO_TIER)
	local key = id .. t
	if evoCache[key] then return evoCache[key] end
	local base = byId[id] or byId.Woman
	local e = EVO[base.id]
	local T = EVO_TIER[t]
	local d = table.clone(base) :: any
	for k, v in e do if k ~= "power" then d[k] = v end end
	d.name = e.title
	d.evolved = true
	d.tier = t
	d.power = e.power
	d.hp = base.hp * T.hp
	d.speed = base.speed * T.speed
	d.dmg = base.dmg * T.dmg
	d.atk = T.atk * ((base :: any).atk or 1) -- attack / ability cooldown multiplier
	d.smash = math.max(T.smash, (base :: any).smash or 0) -- how much harder its punch launches you
	d.reward = base.reward * 2
	d.rarity = (base :: any).secret and 4 or 3
	evoCache[key] = d
	return d
end
-- every 3rd ghost is evolved
local function isEvolvedWave(wave: number): boolean return wave >= 3 and wave % 3 == 0 end

-- NO MONSTER TWICE: a run keeps a set of the monsters it has already met (`seen`, one for the normal ones and one
-- for the evolved ones). A monster is only picked again once every one of them has come (the set then starts over).
-- `avoid` = ids that must not come right now (the previous ghost), when anything else is left.
-- weighted = rarer monsters come later on average (normal ghosts); evolved ones are picked evenly.
local WEIGHT = { [0] = 60, [1] = 30, [2] = 15 }
local function pickFresh(seen: { [string]: boolean }, avoid: { string? }, rng: Random, weighted: boolean): Monster
	local function pool(): { Monster }
		local out = {}
		for _, d in List do
			if not seen[d.id] and d.id ~= avoid[1] and d.id ~= avoid[2] and not (d :: any).secret then table.insert(out, d) end
		end
		return out
	end
	local list = pool()
	if #list == 0 then
		-- everyone has come (or only the one to avoid is left): start the set over
		table.clear(seen)
		list = pool()
	end
	if #list == 0 then list = { byId.Woman } end
	local total = 0
	for _, d in list do total += weighted and (WEIGHT[d.rarity] or 15) or 1 end
	local x = rng:NextNumber(0, total)
	local choice = list[#list]
	for _, d in list do
		x -= weighted and (WEIGHT[d.rarity] or 15) or 1
		if x <= 0 then choice = d; break end
	end
	seen[choice.id] = true
	return choice
end

-- the secret monster, when this ghost is one (roll once per ghost)
local function secretRoll(rng: Random): Monster?
	if rng:NextNumber() >= SECRET_CHANCE then return nil end
	for _, d in List do if (d :: any).secret then return d end end
	return nil
end

return { list = List, byId = byId, rarity = RARITY, pick = pick, pickFresh = pickFresh, evolved = evolved, isEvolvedWave = isEvolvedWave, evo = EVO,
	secretRoll = secretRoll, secretChance = SECRET_CHANCE }
