--!strict
-- The monsters: the Woman (always ghost 1), the Red Demon, the Pirate and the Goblin (rare). pick() falls back to the Woman.
-- template = model name in ServerStorage.Monsters (the Woman uses ServerStorage.GhostTemplate).
-- hp/speed/dmg/reward multiply the level-based values in Config.Ghost / Config.Reward.
-- hover = root height above the floor (floaters ~4.6, walkers = their hip height).
-- ability = what the Abilities module runs (cd = seconds between uses).
-- objTaken = damage multiplier for thrown objects (furniture, thrown items); 1 if left out.
-- secret = shown as a mystery (bestiary, badges, rarity 4); it is in the normal rotation like every other monster.
-- smasher = every last swipe of a combo launches you through the inside walls (like an enraged / evolved monster);
-- smash = how hard.
-- noStagger = never staggered or stunned, only knocked out (the Flayed Giant).
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
		hp = 1.6, speed = 1.04, dmg = 1.3, reward = 1.8, hover = 0, walker = true, scale = 1, solid = false,
		reach = 1.6, -- long arms: attacks from further away
		-- too big to be pushed around: a hit that does not knock him out never staggers him, and stuns (taser, freezing
		-- ultimates, the leaf blower) do nothing. A knockout blow still ragdolls him (Ghost.hit / Ghost.freeze).
		noStagger = true,
		wallBreaker = true, -- too big for the doors: smashes through the inside walls in his way
		-- grabs you; with another player standing he carries you over and swings you into them twice, then throws you
		-- wind = the telegraphed reach before the grab (red ring on the floor = range + 3)
		ability = { kind = "titanGrab", cd = 7.5, range = 15, wind = 1.15, swingRange = 60, swingReach = 13, carrySpeed = 26, dmg = 26, swingDmg = 20, power = 120 },
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
	-- CAMP HOLLOWMERE (Shared/Campaign; hand-built: tools/build/camp_monsters.luau; moves: Server/CampMonsters)
	-- THE ANTLERED ONE (the Bunkhouse): tall, thin, a deer skull with antlers. rafterDrop: he climbs into the rafters
	-- (climb), follows you from up there (lurk at lurkSpeed), a red ring warns where he comes down (warn), he
	-- drops (radius / dmg / power), then he is dazed (daze) - hit him then. charge: head down (wind, a red lane), a
	-- straight charge (speed for `time`): gored and thrown, inside walls burst; an outside wall stops him, his
	-- antlers stuck in it for `stuck` seconds.
	m({ id = "Antlered", name = "The Antlered One", title = "THE ANTLERED ONE", rarity = 1, template = "Antlered", color = C(214, 204, 176),
		hp = 1.0, speed = 0.95, dmg = 0.9, reward = 1.2, hover = 7.2, walker = true, scale = 1, solid = false, reach = 1.35,
		ability = { kind = "rafterDrop", cd = 9, min = 10, climb = 0.9, lurk = 2.4, lurkSpeed = 26, warn = 1.0, radius = 8, dmg = 30, power = 70, daze = 2.4,
			charge = { min = 14, max = 60, wind = 0.95, speed = 72, time = 1.1, dmg = 26, power = 95, stuck = 2.6 } },
		desc = "Too tall for the cabins. He climbs into the rafters and drops on you, or lowers his antlers and charges through the walls. Watch for the red marks; lure his charge into an outside wall and his antlers get stuck." }),
	-- THE LAKE WITCH (the Boathouse): a drowned woman with a hook on a chain. hookPull: the hook is thrown (walls stop
	-- it); whoever it catches is dragged into the water (pull) and held under (dmg). Every floodEvery-th move she
	-- floods the floor for `flood` seconds: everyone in the water is slowed to floodSlow. grasp: black water wells up
	-- under you (warn), then drowned hands grab everyone still in it (rooted for `hold`, dmg).
	m({ id = "LakeWitch", name = "The Lake Witch", title = "THE LAKE WITCH", rarity = 1, template = "LakeWitch", color = C(120, 200, 190),
		hp = 1.05, speed = 1.0, dmg = 0.95, reward = 1.3, hover = 5.35, walker = true, scale = 1, solid = false,
		ability = { kind = "hookPull", cd = 7, min = 8, max = 55, wind = 0.8, hookSpeed = 95, pull = 1.3, pullSpeed = 34, dmg = 24, floodEvery = 3, flood = 7, floodSlow = 0.6,
			grasp = { max = 50, warn = 1.15, radius = 7, hold = 1.8, dmg = 14 } },
		desc = "She walks out of the lake with a hook on a chain. Get behind something when she draws it back, or she drags you under. Step out of the black water before the hands come up, and keep moving when the lake rises." }),
	-- THE BURNED COUNSELOR (the Mess Hall): charred, a burning torch. firebrand: he lobs the torch where you stand and
	-- the wood catches fire (the wildfire system, Server/Fire); fire never hurts him (fireImmune). run: a scream, then
	-- he runs at you (speed, turning at `turn`), a trail of fire behind him; a wall or `time` stops him, panting.
	m({ id = "Counselor", name = "The Burned Counselor", title = "THE BURNED COUNSELOR", rarity = 1, template = "Counselor", color = C(255, 120, 40),
		hp = 1.15, speed = 1.0, dmg = 1.05, reward = 1.4, hover = 5.4, walker = true, scale = 1, solid = false, fireImmune = true,
		ability = { kind = "firebrand", cd = 7, min = 10, max = 60, wind = 0.7, flight = 1.0, radius = 7, fires = 4, dmg = 14,
			run = { min = 10, max = 50, wind = 0.85, speed = 40, time = 2.4, turn = 2.2, fireEvery = 5, dmg = 22, power = 70, pant = 1.9 } },
		desc = "Lights out was his job once. Now he throws his torch and the cabin goes up in flames, or screams and runs you down with a trail of fire behind him. Sidestep the run, then hit him while he gets his breath back." }),
	-- THE SCARECROW (the Barn): scareSwap: copies of him stand all over the barn (decoys at the barn's ScarecrowSpots,
	-- punching one bursts it); he does not move while ANY player looks at him (cone / range), and swaps places with
	-- a decoy every `swapEvery` seconds. crows: they gather on him, then burst at you in a cone (pecks, blinded for
	-- `blind`: a blinded player can't hold him still); stare at him over `stare` seconds and he sends them anyway.
	-- sickle: thrown like a boomerang, out past you and back.
	m({ id = "Scarecrow", name = "The Scarecrow", title = "THE SCARECROW", rarity = 1, template = "Scarecrow", color = C(214, 182, 96),
		hp = 0.9, speed = 1.45, dmg = 1.1, reward = 1.5, hover = 5.45, walker = true, scale = 1, solid = false,
		ability = { kind = "scareSwap", cd = 8, decoys = 8, cone = 0.55, range = 80, swapEvery = 11,
			crows = { range = 34, cone = 0.75, wind = 0.9, time = 1.6, dps = 14, blind = 3.0, stare = 3.2 },
			sickle = { min = 10, max = 50, wind = 0.7, flight = 0.7, dmg = 18, power = 45 } },
		desc = "One of the scarecrows in the barn is him. He only moves when nobody is looking, and then he moves fast. He throws his sickle from far off, and if you stare too long his crows come for your eyes." }),
	-- THE MOONLIGHT CARNIVAL (Shared/Campaign; hand-built: tools/build/carnival_monsters.luau; moves: Server/CarnivalMonsters)
	-- POP THE CLOWN (the Funhouse): crate - hides, the crates round you rattle, he bursts out of the one nearest you
	-- (radius / dmg / power), then laughs (laugh); balloons - balloon copies of himself float at you and pop.
	m({ id = "Clown", name = "Pop the Clown", title = "POP THE CLOWN", rarity = 1, template = "Clown", color = C(240, 90, 90),
		hp = 1.0, speed = 1.15, dmg = 0.95, reward = 1.4, hover = 5.2, walker = true, scale = 1, solid = false,
		ability = { kind = "popClown", cd = 8, crate = { min = 8, lurk = 1.5, radius = 9, dmg = 26, power = 70, laugh = 1.4 },
			balloons = { max = 70, wind = 1.2, count = 5, scale = 0.8, life = 14, dmg = 12, speed = 12 } },
		desc = "He hides, and the crates round you start to rattle: he bursts out of the one nearest you. Punch his balloon copies before they reach you." }),
	-- THE STRONGMAN (the Carousel): rip - grabs the nearest bench / ride part, lifts it, hurls it; slam - leaps, lands,
	-- a shockwave rolls out along the floor (radius at `wave` studs/s): jump over it.
	m({ id = "Strongman", name = "The Strongman", title = "THE STRONGMAN", rarity = 1, template = "Strongman", color = C(210, 120, 80),
		hp = 1.35, speed = 0.9, dmg = 1.2, reward = 1.5, hover = 6.15, walker = true, scale = 1, solid = false, reach = 1.3,
		ability = { kind = "strongman", cd = 8, rip = { max = 75, reach = 35, run = 28, lift = 0.7, aim = 0.4, speed = 100, dmg = 26 },
			slam = { max = 45, leap = 0.75, height = 14, radius = 42, wave = 34, dmg = 28, power = 70 } },
		desc = "He tears the benches and the ride horses out of the floor and throws them. When he jumps, you jump too: the shockwave rolls along the floor." }),
	-- MADAME FORTUNE (the Hall of Mirrors): curse - a homing orb; caught = cursed (blur, reversed controls) until her
	-- crystal ball is smashed (then she shrieks, stunned); cards - a fan of tarot cards.
	m({ id = "Fortune", name = "Madame Fortune", title = "MADAME FORTUNE", rarity = 1, template = "Fortune", color = C(190, 100, 255),
		hp = 1.05, speed = 1.0, dmg = 1.0, reward = 1.5, hover = 6.05, walker = false, scale = 1, solid = false,
		ability = { kind = "fortune", cd = 8, curse = { max = 70, wind = 0.9, speed = 30, turn = 1.6, life = 4, dmg = 8 },
			cards = { min = 8, max = 60, wind = 0.6, count = 5, spread = 0.18, speed = 70, life = 1.2, dmg = 11, power = 30 } },
		desc = "Her violet orb curses you: the world blurs and your controls turn back to front. Smash her crystal ball to break every curse - she screams." }),
	-- THE RINGMASTER (the Big Top): whip - a red line, the lash pulls whoever it catches in to him; crowd - the whip
	-- cracks overhead and the mannequins in the stands come alive (count, for `life` seconds).
	m({ id = "Ringmaster", name = "The Ringmaster", title = "THE RINGMASTER", rarity = 1, template = "Ringmaster", color = C(200, 30, 40),
		hp = 1.3, speed = 1.05, dmg = 1.1, reward = 1.6, hover = 6.25, walker = true, scale = 1, solid = false,
		ability = { kind = "ringmaster", cd = 9, whip = { min = 8, max = 34, wind = 0.65, width = 3.2, dmg = 18 },
			crowd = { max = 90, wind = 1.0, count = 4, life = 16, speed = 13, dmg = 12 } },
		desc = "The show must go on. His whip pulls you in, and when it cracks overhead the mannequins in the stands come down for you." }),
	-- BLACKWATER HARBOR (Server/HarborMonsters; models: tools/build/harbor_monsters.luau)
	-- THE DEEP ONE (the Fish Market): ink - a blob of ink spat at you (INKED: black ink over your screen); dive - he
	-- sinks into the floor, a ripple follows you, stops, and he bursts up out of it (get out of the ring), then gasps.
	m({ id = "DeepOne", name = "The Deep One", title = "THE DEEP ONE", rarity = 1, template = "DeepOne", color = C(90, 190, 160),
		hp = 1.3, speed = 1.05, dmg = 1.1, reward = 1.7, hover = 4.85, walker = true, scale = 1.15, solid = false,
		ability = { kind = "deepOne", cd = 7.5, ink = { min = 9, max = 60, wind = 0.75, speed = 52, radius = 4.2, life = 2.2, dmg = 14, blind = 4 },
			dive = { max = 75, sink = 0.7, swim = 1.7, rise = 0.65, radius = 8, dmg = 26, power = 28, up = 62, gasp = 1.3 } },
		desc = "It spits black ink in your eyes. When it sinks into the floor, a ripple follows you: when it stops, run." }),
	-- THE KEEPER (the Lighthouse): beam - his lantern's beam sweeps the room (burns and slows; walls and cover stop
	-- it); flash - the lamp goes white hot: whoever is looking at him is blinded, and he lunges at them.
	m({ id = "Keeper", name = "The Keeper", title = "THE KEEPER", rarity = 1, template = "Keeper", color = C(255, 220, 120),
		hp = 1.35, speed = 1.0, dmg = 1.15, reward = 1.7, hover = 5.05, walker = true, scale = 1.15, solid = false,
		ability = { kind = "keeper", cd = 8, beam = { max = 80, raise = 0.85, sweep = 2.6, arc = 1.1, width = 0.14, tick = 0.3, dmg = 7, slow = 0.5 },
			flash = { max = 70, charge = 1.1, blind = 2.6, dot = 0.55, lunge = 0.9, speed = 62, dmg = 24 } },
		desc = "His lamp still turns. Hide from the beam behind something solid - and when the lamp goes white, LOOK AWAY." }),
	-- THE NETMAN (the Net Loft): net - a weighted net thrown at you (held in place, hurt); anchor - he whirls his
	-- anchor round him on its chain along the floor: jump over it, or stay right under him.
	m({ id = "Netman", name = "The Netman", title = "THE NETMAN", rarity = 1, template = "Netman", color = C(200, 100, 60),
		hp = 1.5, speed = 0.95, dmg = 1.25, reward = 1.8, hover = 5.45, walker = true, scale = 1.15, solid = false, reach = 1.25,
		ability = { kind = "netman", cd = 8, net = { min = 8, max = 55, wind = 0.65, speed = 58, radius = 4, life = 1.6, hold = 2.2, dmg = 12 },
			anchor = { max = 20, wind = 0.85, spin = 1.6, turns = 1.5, radius = 15, dmg = 26, power = 55 } },
		desc = "He nets you where you stand, then swings his anchor round the room. Jump it - or hug him." }),
	-- THE SEWER RAT (hand-built: tools/build/rat.luau): a rat the size of a car. ratRush = two moves (Server/Abilities):
	-- the CHARGE (wind seconds of warning along a red line, then dashSpeed studs/s in a straight line for dashTime
	-- seconds: furniture, inside walls and players in the way are all sent flying, and he is dizzy for a moment after)
	-- and the BURROW (he digs into the floor in `dig` seconds, travels under it at underSpeed toward you, the floor
	-- cracks for `warn` seconds and he bursts out: popDmg and a launch for anyone within popRadius).
	m({ id = "Rat", name = "The Sewer Rat", title = "THE SEWER RAT", rarity = 2, template = "Rat", color = C(124, 108, 92),
		hp = 1.35, speed = 1.12, dmg = 1.15, reward = 1.7, hover = 0, walker = true, scale = 1, solid = true,
		reach = 1.2,
		ability = { kind = "ratRush", cd = 6.5, wind = 0.9, dashSpeed = 112, dashTime = 0.95, dashDmg = 30, dashPower = 150, dizzy = 1.3,
			dig = 0.75, underSpeed = 42, underTime = 3.4, warn = 0.55, popDmg = 28, popUp = 80, popRadius = 7, far = 26 },
		desc = "A rat the size of a car. It charges in a straight line through furniture and walls, or digs under the floor and bursts out under your feet: never stand still." }),
	-- THE VOID KNIGHT (hand-built: tools/build/knight.luau; Server/Knight): a black-armoured lord with a red energy
	-- blade. saber = every swing cuts the inside walls and the furniture in front of him, and (wallBreaker) he cuts
	-- his way through the walls instead of using a door. forcePush: he reaches out (wind seconds), lifts a player
	-- he can see `lift` studs off the floor, holds them `hold` seconds and throws them into the walls at `power`.
	-- min / max = from how far he tries it. Out of his sight, or knocking him back, breaks it.
	m({ id = "Knight", name = "The Void Knight", title = "THE VOID KNIGHT", rarity = 2, template = "Knight", color = C(235, 40, 34),
		hp = 1.4, speed = 0.92, dmg = 1.3, reward = 1.8, hover = 0, walker = true, scale = 1, solid = false,
		reach = 1.35, wallBreaker = true, saber = true,
		ability = { kind = "forcePush", cd = 8, min = 9, max = 62, wind = 1.0, hold = 0.9, lift = 7, power = 150, dmg = 24 },
		desc = "A black-armoured lord with a red blade that cuts through every wall. He reaches out, lifts you off the floor without touching you and throws you into the walls: stay out of his sight." }),
	-- THE SECRET ONE: a huge purple warlord with a golden gauntlet. Slow on his feet, so he steps through a portal
	-- and comes out behind you (warp: from `min` studs away, `wind` seconds of warning); his fist sends you through
	-- the walls, and he punches his own way through them rather than use a door.
	m({ id = "Conqueror", name = "The Conqueror", title = "THE CONQUEROR", rarity = 4, secret = true, template = "Conqueror", color = C(150, 104, 190),
		hp = 1.5, speed = 0.8, dmg = 1.3, reward = 2.5, hover = 0, walker = true, scale = 1, solid = false,
		reach = 1.25, wallBreaker = true, smasher = true, smash = 1.5,
		ability = { kind = "warp", cd = 9, min = 20, wind = 0.9 },
		desc = "A warlord from somewhere else. Slow, but he steps out of a portal behind you, and one punch sends you through the walls." }),
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
	for _, d in List do if d.rarity == rar and d.id ~= last and not (d :: any).secret then table.insert(pool, d) end end
	if #pool == 0 then return byId.Woman end
	return pool[rng:NextInteger(1, #pool)]
end

-- EVOLVED monsters: every 3rd ghost is an evolved variant of one of the monsters above (same id, same voice and
-- animations; Server/Evolved.luau dresses the model and runs the extra power). Twice the health, faster, and every
-- swipe launches you through the walls. title = its name; power = the extra ability (Evolved.luau); pay = x its
-- cash (on top of the x2 every evolved monster pays); the other fields override the base monster's.
local EVO: { [string]: { [string]: any } } = {
	Woman = { title = "THE VIOLET WIDOW", color = C(170, 90, 230), scale = 1.1,
		-- ring = how far from you she and her doubles appear, spread = degrees between two of them (all in front of you),
		-- pause = seconds they stand there before they come
		power = { kind = "doubles", cd = 13, n = 3, t = 14, dmg = 10, ring = 17, spread = 26, pause = 1 },
		desc = "Purple and wrong. She splits into doubles: only one of them is real." },
	Demon = { title = "THE DEMON LORD", color = C(150, 20, 16), scale = 1.3, reach = 1.3,
		ability = { kind = "levitateThrow", cd = 6, range = 75, lift = 1.4, aim = 0.5, speed = 100, dmg = 18, count = 3 },
		desc = "Bigger, with a sceptre. He lifts several pieces of furniture at once and throws them all." },
	-- soloFlings: alone against him, he only sends you flying through the walls this many times in the whole fight
	-- (his punch and his weapon swings; after that they hurt but you keep your feet). In a team: no limit.
	Goblin = { title = "THE GOBLIN KING", color = C(34, 92, 44), scale = 1.15, solid = false, wallBreaker = true, soloFlings = 2,
		power = { kind = "armed", weapons = { "BaseballBat", "FryingPan", "Crowbar", "LeadPipe", "Shovel", "SpikedBat", "Machete", "FireAxe" } },
		desc = "Fat, forest green, and already armed. He punches through the walls to get to you." },
	Pirate = { title = "THE BURNING CAPTAIN", color = C(255, 90, 30), scale = 1.1, pay = 2, -- pays double (x4 the Pirate's reward)
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
		power = { kind = "shotgun", cd = 10, wind = 2.2, gap = 1.8, shots = 2, dmg = 46, range = 95, power = 70, min = 5 }, -- wind/gap: time to take cover
		desc = "The same mask, red now, and a shotgun. Two shots, and each one blows your cover away." },
	-- gold armour and a helmet; everything the Conqueror does, plus the gauntlet's beam: it turns after you slowly
	-- (turn = degrees per second, sweep = studs per second, so you can always outrun it), cuts through furniture and inside walls, and burns for `dps` while you stand in it
	Conqueror = { title = "THE GOLDEN CONQUEROR", color = C(232, 186, 70), scale = 1.1,
		-- turn = degrees a second at most, sweep = studs a second at most where you stand (slower than walking)
		power = { kind = "laser", cd = 13, wind = 1.5, t = 6, range = 140, turn = 16, sweep = 10, dps = 42, width = 3 },
		desc = "In his golden war armour. The gauntlet fires a slow purple beam that cuts through the house: never stand in it." },
	-- bloated and green, a rusty crown on its head: it charges twice in a row and comes up from the floor faster
	Rat = { title = "THE PLAGUE KING", color = C(120, 176, 66), scale = 1.2, reach = 1.3,
		ability = { kind = "ratRush", cd = 5.5, wind = 0.75, dashSpeed = 126, dashTime = 0.95, dashDmg = 34, dashPower = 165, dizzy = 1.1, dashes = 2,
			dig = 0.6, underSpeed = 52, underTime = 3.4, warn = 0.45, popDmg = 34, popUp = 88, popRadius = 9, far = 24 },
		desc = "Bloated, green, crowned. It charges twice in a row and comes up through the floor before you have stopped running." },
	-- his grip comes sooner, holds shorter and throws harder
	Knight = { title = "THE HOLLOW EMPEROR", color = C(190, 90, 255), scale = 1.12, reach = 1.45,
		ability = { kind = "forcePush", cd = 5.5, min = 8, max = 75, wind = 0.8, hold = 0.7, lift = 8, power = 185, dmg = 32 },
		desc = "The armour is cracked and violet light pours out of it. His grip comes faster and throws harder, and no wall slows him down." },
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
	d.reward = base.reward * 2 * (e.pay or 1)
	d.rarity = (base :: any).secret and 4 or 3
	evoCache[key] = d
	return d
end
-- every 3rd ghost is evolved
local function isEvolvedWave(wave: number): boolean return wave >= 3 and wave % 3 == 0 end

-- WHO COMES NEXT: a run meets EVERY monster once before any of them comes again (the Conqueror too, with the same
-- odds as the others), picked evenly among the ones it hasn't met yet; once all have come, `seen` starts over. The
-- ones in `avoid` (the last two you fought) never come, even when a new round starts. The run keeps one `seen` set
-- for the normal ghosts and one for the evolved ones. (`_weighted` is no longer used: rarity doesn't change the odds.)
local function pickFresh(seen: { [string]: boolean }, avoid: { string? }, rng: Random, _weighted: boolean?): Monster
	local function pool(): { Monster }
		local out = {}
		for _, d in List do
			if not seen[d.id] and d.id ~= avoid[1] and d.id ~= avoid[2] then table.insert(out, d) end
		end
		return out
	end
	local list = pool()
	if #list == 0 then
		-- every monster has come (or only the last two are left): a new round
		table.clear(seen)
		list = pool()
	end
	if #list == 0 then return byId.Woman end
	local choice = list[rng:NextInteger(1, #list)]
	seen[choice.id] = true
	return choice
end

return { list = List, byId = byId, rarity = RARITY, pick = pick, pickFresh = pickFresh, evolved = evolved, isEvolvedWave = isEvolvedWave, evo = EVO }
