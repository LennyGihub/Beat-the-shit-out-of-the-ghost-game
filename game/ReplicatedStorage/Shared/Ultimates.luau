--!strict
-- 50 ultimates (lobby shop). Each = a timed buff + activation actions run by the server.
-- buff: damage/knock/throw/speed multipliers, lifesteal (fraction), explode (radius of explosive punches),
--   burnOnHit (fire dps added per hit), staminaFree, comboLock (combo never drops, +2 per hit), onePunch (next hit x20).
-- acts: shock {r,d,k} | pulses {n,r,d,k,gap} | strike {style=lightning|meteor|holy|nuke, n, d, gap} | freeze {t}
--   timestop {t, mult} | launch {h, d} | vortex {t, r} | barrage {n} | burn {dps, t} | slow {mult, t} | heal {hp}
--   stamina {} | giant {scale, t} | pull {}
--   any action: wait = seconds after the cast beat, atGhost = centred on the monster (shock)
-- castTime: the wind-up. The buff starts at once; the actions go off castTime later, when the cast animation
-- (Client/Viewmodel CASTS, Client/UltFx) lands its hit.
export type Ult = { id: string, name: string, rarity: number, price: number, color: Color3, desc: string, dur: number, buff: { [string]: any }, acts: { { [string]: any } } }

local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local function u(id, name, rarity, price, color, dur, desc, buff, acts): Ult
	return { id = id, name = name, rarity = rarity, price = price, color = color, dur = dur, desc = desc, buff = buff, acts = acts }
end

local List: { Ult } = {
	-- COMMON
	u("Rage", "Rage Shockwave", 1, 0, C(255, 70, 30), 10, "A shockwave, then x2.2 damage for 10 s.", { damage = 2.2, knock = 1.8, throw = 2 }, { { type = "shock", r = 24, d = 30, k = 140 } }),
	u("GroundPound", "Ground Pound", 1, 300, C(200, 150, 90), 8, "Slam the floor: big shockwave, then heavy hits.", { damage = 1.8, knock = 1.6 }, { { type = "shock", r = 32, d = 40, k = 160 } }),
	u("HeavyHands", "Heavy Hands", 1, 350, C(160, 160, 170), 12, "x2 damage and x2.4 knockback for 12 s.", { damage = 2.0, knock = 2.4 }, {}),
	u("SecondWind", "Second Wind", 1, 400, C(120, 230, 140), 10, "Heal 60, full stamina, faster and harder.", { damage = 1.6, speed = 1.3 }, { { type = "heal", hp = 60 }, { type = "stamina" } }),
	u("SkyUppercut", "Sky Uppercut", 1, 420, C(140, 200, 255), 8, "Launch her into the ceiling, slam her down.", { damage = 1.7 }, { { type = "launch", h = 40, d = 50 } }),
	u("TableFlipper", "Table Flipper", 1, 380, C(170, 120, 70), 10, "4 pieces of furniture fly at her; throws x2.5.", { throw = 2.5 }, { { type = "barrage", n = 4 } }),
	u("HotHead", "Hot Head", 1, 450, C(255, 120, 30), 8, "Set her on fire; your punches burn.", { damage = 1.8, burnOnHit = 2 }, { { type = "burn", dps = 8, t = 6 } }),
	u("BrainFreeze", "Brain Freeze", 1, 450, C(150, 220, 255), 8, "Freeze her for 3 s.", { damage = 1.8 }, { { type = "freeze", t = 3 } }),
	u("StreetSweeper", "Street Sweeper", 1, 500, C(220, 200, 120), 8, "Huge knockback wave that clears the room.", { knock = 2.5 }, { { type = "shock", r = 40, d = 20, k = 220 } }),
	u("Caffeine", "Caffeine Overdose", 1, 500, C(150, 100, 60), 12, "Free punches, x1.5 speed for 12 s.", { damage = 1.6, speed = 1.5, staminaFree = true }, { { type = "stamina" } }),
	-- UNCOMMON
	u("ThunderFist", "Thunder Fist", 2, 900, C(150, 200, 255), 10, "5 lightning bolts, explosive punches.", { damage = 2.0, explode = 8 }, { { type = "strike", style = "lightning", n = 5, d = 18, gap = 0.3 } }),
	u("MeteorPunch", "Meteor Punch", 2, 1000, C(255, 110, 40), 8, "3 meteors crash onto her.", { damage = 2.0 }, { { type = "strike", style = "meteor", n = 3, d = 30, gap = 0.5 } }),
	u("ExplodingFists", "Exploding Fists", 2, 1100, C(255, 150, 50), 10, "Every punch explodes.", { damage = 2.0, explode = 10 }, {}),
	u("VampireRush", "Vampire Rush", 2, 1100, C(170, 20, 40), 12, "Heal 35% of your damage.", { damage = 1.8, lifesteal = 0.35 }, {}),
	u("Frostbite", "Frostbite", 2, 1200, C(120, 200, 255), 10, "Freeze 4 s and frost-burn.", { damage = 1.9 }, { { type = "freeze", t = 4 }, { type = "burn", dps = 6, t = 5, color = C(120, 200, 255) } }),
	u("Poltergeist", "Poltergeist", 2, 1200, C(190, 170, 255), 8, "8 pieces of furniture hunt her down.", { throw = 2 }, { { type = "barrage", n = 8 } }),
	u("Bulldozer", "Bulldozer", 2, 1000, C(230, 190, 60), 10, "x3 knockback, x1.4 speed, shockwave.", { knock = 3, speed = 1.4 }, { { type = "shock", r = 20, d = 25, k = 150 } }),
	u("Hellfire", "Hellfire", 2, 1300, C(255, 80, 20), 8, "Ring of fire, she burns hard.", { damage = 1.8 }, { { type = "shock", r = 22, d = 20, k = 120 }, { type = "burn", dps = 15, t = 8 } }),
	u("BulletTime", "Bullet Time", 2, 1400, C(230, 230, 230), 8, "She moves at 20% speed.", { damage = 2.0 }, { { type = "slow", mult = 0.2, t = 8 } }),
	u("GiantMode", "Giant Mode", 2, 1500, C(255, 200, 120), 10, "You grow huge for 10 s.", { damage = 2.2, knock = 2 }, { { type = "giant", scale = 1.8, t = 10 } }),
	-- RARE
	u("BlackHole", "Black Hole", 3, 2000, C(120, 40, 200), 8, "A black hole drags every piece of furniture into her.", { damage = 2.0 }, { { type = "vortex", t = 6, r = 40 } }),
	u("Thunderstorm", "Thunderstorm", 3, 2200, C(170, 210, 255), 10, "12 lightning bolts.", { damage = 2.0 }, { { type = "strike", style = "lightning", n = 12, d = 15, gap = 0.35 } }),
	u("MeteorShower", "Meteor Shower", 3, 2400, C(255, 120, 40), 10, "10 meteors rain on her.", { damage = 1.8 }, { { type = "strike", style = "meteor", n = 10, d = 22, gap = 0.4 } }),
	u("IceAge", "Ice Age", 3, 2500, C(160, 230, 255), 10, "Frozen 6 s, ice shockwave.", { damage = 2.3 }, { { type = "freeze", t = 6 }, { type = "shock", r = 35, d = 30, k = 60 } }),
	u("FurnitureTornado", "Furniture Tornado", 3, 2600, C(200, 170, 120), 10, "A tornado of furniture spins into her.", { throw = 2.5 }, { { type = "vortex", t = 8, r = 50 }, { type = "barrage", n = 6 } }),
	u("Inferno", "Inferno", 3, 2700, C(255, 90, 20), 10, "Massive burn, explosive punches.", { damage = 2.0, explode = 12 }, { { type = "burn", dps = 25, t = 10 } }),
	u("TimeStop", "Time Stop", 3, 3000, C(230, 220, 120), 8, "Time stops 5 s. All damage lands at once x1.5.", { damage = 2.5 }, { { type = "timestop", t = 5, mult = 1.5 } }),
	u("OrbitalUppercut", "Orbital Uppercut", 3, 2800, C(150, 180, 255), 8, "Uppercut to the roof and back.", { damage = 2.0 }, { { type = "launch", h = 90, d = 120 } }),
	u("BloodMoon", "Blood Moon", 3, 3200, C(200, 20, 30), 14, "Heal 50% of damage, x2.4 damage.", { damage = 2.4, knock = 2, lifesteal = 0.5 }, {}),
	u("HolySmite", "Holy Smite", 3, 3500, C(255, 240, 160), 10, "6 holy beams and holy fire.", { damage = 1.8 }, { { type = "strike", style = "holy", n = 6, d = 30, gap = 0.4 }, { type = "burn", dps = 10, t = 6, color = C(255, 240, 160) } }),
	-- EPIC
	u("Armageddon", "Armageddon", 4, 4500, C(255, 90, 30), 12, "15 meteors and a giant shockwave.", { damage = 2.2 }, { { type = "shock", r = 40, d = 40, k = 180 }, { type = "strike", style = "meteor", n = 15, d = 25, gap = 0.3 } }),
	u("WrathOfZeus", "Wrath of Zeus", 4, 5000, C(180, 220, 255), 12, "20 lightning bolts, explosive punches.", { damage = 2.2, explode = 10 }, { { type = "strike", style = "lightning", n = 20, d = 18, gap = 0.25 } }),
	u("Singularity", "Singularity", 4, 5500, C(90, 20, 160), 12, "Time stops while a huge black hole eats the house.", { damage = 2.2 }, { { type = "timestop", t = 3, mult = 1.4 }, { type = "vortex", t = 10, r = 60 } }),
	u("TitanForm", "Titan Form", 4, 6000, C(255, 210, 140), 14, "You become a titan: x3 damage.", { damage = 3, knock = 3 }, { { type = "giant", scale = 2.5, t = 14 } }),
	u("ReversePossession", "Reverse Possession", 4, 5200, C(160, 255, 200), 10, "She is frozen while 10 pieces of furniture pound her.", { throw = 2.5 }, { { type = "freeze", t = 5 }, { type = "barrage", n = 10 } }),
	u("DragonFist", "Dragon Fist", 4, 6200, C(255, 60, 20), 10, "Fire meteors and dragon burns.", { damage = 2.5, burnOnHit = 4 }, { { type = "burn", dps = 30, t = 10 }, { type = "strike", style = "meteor", n = 5, d = 30, gap = 0.4 } }),
	u("AbsoluteZero", "Absolute Zero", 4, 6500, C(200, 245, 255), 12, "Frozen 8 s, colossal ice wave.", { damage = 2.4 }, { { type = "freeze", t = 8 }, { type = "shock", r = 50, d = 50, k = 80 } }),
	u("Earthquake", "Earthquake", 4, 5800, C(160, 120, 80), 10, "Three massive quakes.", { damage = 2.0, knock = 2 }, { { type = "pulses", n = 3, r = 45, d = 35, k = 180, gap = 1.0 } }),
	u("BerserkGod", "Berserk God", 4, 7000, C(255, 40, 40), 16, "x3 damage, lifesteal, speed for 16 s.", { damage = 3, knock = 2.5, speed = 1.6, lifesteal = 0.3 }, {}),
	u("FurnitureApocalypse", "Furniture Apocalypse", 4, 6800, C(220, 160, 90), 10, "20 pieces of furniture launched at her.", { throw = 3 }, { { type = "barrage", n = 20 } }),
	-- LEGENDARY
	u("GrandExorcism", "Grand Exorcism", 5, 10000, C(255, 250, 200), 12, "10 holy beams, frozen, burning with light.", { damage = 2.5 }, { { type = "freeze", t = 4 }, { type = "strike", style = "holy", n = 10, d = 45, gap = 0.3 }, { type = "burn", dps = 20, t = 8, color = C(255, 250, 200) } }),
	u("Supernova", "Supernova", 5, 11000, C(255, 220, 120), 10, "Explode like a star. The whole floor goes flying.", { damage = 2.5, knock = 3 }, { { type = "shock", r = 80, d = 150, k = 250 } }),
	u("EventHorizon", "Event Horizon", 5, 12000, C(60, 0, 120), 14, "Time stops, then a black hole swallows everything.", { damage = 2.5 }, { { type = "timestop", t = 4, mult = 1.6 }, { type = "vortex", t = 12, r = 80 } }),
	u("GodMode", "God Mode", 5, 13000, C(255, 255, 255), 20, "x4 damage, lifesteal, free punches, speed for 20 s.", { damage = 4, knock = 3, lifesteal = 0.5, speed = 1.6, staminaFree = true }, { { type = "heal", hp = 999 } }),
	u("Ragnarok", "Ragnarok", 5, 14000, C(255, 140, 60), 14, "25 lightning bolts and 10 meteors.", { damage = 2.5 }, { { type = "shock", r = 30, d = 40, k = 160 }, { type = "strike", style = "lightning", n = 25, d = 15, gap = 0.2 }, { type = "strike", style = "meteor", n = 10, d = 25, gap = 0.5 } }),
	u("HouseCollapse", "House Collapse", 5, 12500, C(180, 140, 100), 10, "Every piece of furniture nearby is hurled at her.", { throw = 3 }, { { type = "barrage", n = 40 } }),
	u("Colossus", "Colossus", 5, 15000, C(255, 180, 100), 15, "Grow to a colossus: x4 damage.", { damage = 4, knock = 4 }, { { type = "giant", scale = 3.2, t = 15 }, { type = "shock", r = 40, d = 60, k = 200 } }),
	u("InfiniteCombo", "Infinite Combo", 5, 14500, C(255, 60, 200), 15, "Your combo never drops and climbs x2 per hit.", { damage = 3, comboLock = true }, { { type = "timestop", t = 3, mult = 1.3 } }),
	u("GhostNuke", "Ghost Nuke", 5, 18000, C(255, 255, 160), 10, "Call in a nuke.", { damage = 2 }, { { type = "strike", style = "nuke", n = 1, d = 250, gap = 0 }, { type = "shock", r = 100, d = 0, k = 300, wait = 1.6, atGhost = true } }),
	u("OnePunch", "One Punch", 5, 20000, C(255, 230, 0), 10, "Your next punch deals x20 damage.", { knock = 5, onePunch = true }, {}),
}

local byId: { [string]: Ult } = {}
for _, x in List do byId[x.id] = x end
-- economy: ultimates cost 3x their listed price so unlocking them takes longer
for _, u in List do u.price *= 3 end
return { list = List, byId = byId, default = "Rage", castTime = 0.4 }
