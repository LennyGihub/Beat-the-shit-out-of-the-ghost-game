--!strict
-- 50 physical items sold at run events (bought with RUN cash, lost when the run ends). Held in a 5-slot hotbar.
-- kind:   melee  (swing; dmg, knock, cd, range, stamina)       gun   (hitscan; dmg, knock, cd, range, pellets, spread)
--         throw  (projectile; dmg, radius, knock)             spray (hold; dps, range, cone)
--         use    (on yourself: heal, stamina, brut, speed, speedT, shield, ward)   trap (placed; stun, dmg)
-- uses:   swings / ammo / throws / fuel ticks (0.1 s each) / charges.
-- fx (on the ghost): burn {dps,t,color} bleed {dps,t} slow {mult,t} stun t  freeze t  pull (true)
--         lightning dmg  lifesteal frac  vuln {mult,t}  push (spray knock per tick)
-- shape:  3D look (Props.weapon / Viewmodel), color = main tint.
export type Item = { id: string, name: string, rarity: number, price: number, kind: string, shape: string, color: Color3, desc: string, uses: number, [string]: any }

local RARITY = {
	{ name = "COMMON", color = Color3.fromRGB(200, 196, 186), weight = 42 },
	{ name = "UNCOMMON", color = Color3.fromRGB(110, 200, 90), weight = 28 },
	{ name = "RARE", color = Color3.fromRGB(80, 150, 240), weight = 16 },
	{ name = "EPIC", color = Color3.fromRGB(190, 90, 240), weight = 10 },
	{ name = "LEGENDARY", color = Color3.fromRGB(255, 170, 40), weight = 4 },
}
local function C(r, g, b) return Color3.fromRGB(r, g, b) end
local function I(t: { [string]: any }): Item return t :: any end
local RED, ICE, HOLY, FIRE = C(150, 10, 10), C(150, 210, 255), C(255, 240, 170), C(255, 110, 30)

local List: { Item } = {
	-- MELEE ------------------------------------------------------------------
	I({ id = "BaseballBat", name = "Baseball Bat", rarity = 1, price = 90, kind = "melee", shape = "bat", color = C(170, 130, 85), desc = "Solid swings, good knockback.", uses = 40, dmg = 9, knock = 34, cd = 0.42, range = 10, stamina = 6 }),
	I({ id = "FryingPan", name = "Frying Pan", rarity = 1, price = 80, kind = "melee", shape = "pan", color = C(50, 50, 52), desc = "BONG. Big knockback.", uses = 40, dmg = 7, knock = 48, cd = 0.4, range = 9, stamina = 6, sound = "pan" }),
	I({ id = "Crowbar", name = "Crowbar", rarity = 1, price = 100, kind = "melee", shape = "crowbar", color = C(140, 30, 26), desc = "Fast and reliable.", uses = 55, dmg = 9, knock = 24, cd = 0.34, range = 10, stamina = 5 }),
	I({ id = "LeadPipe", name = "Lead Pipe", rarity = 1, price = 90, kind = "melee", shape = "pipe", color = C(120, 120, 125), desc = "Heavy pipe, heavy hits.", uses = 45, dmg = 10, knock = 30, cd = 0.44, range = 10, stamina = 6 }),
	I({ id = "Shovel", name = "Rusty Shovel", rarity = 2, price = 170, kind = "melee", shape = "shovel", color = C(120, 90, 60), desc = "Long reach, flat face.", uses = 45, dmg = 12, knock = 38, cd = 0.5, range = 12, stamina = 7 }),
	I({ id = "GolfClub", name = "Golf Club", rarity = 2, price = 180, kind = "melee", shape = "golf", color = C(190, 190, 195), desc = "FORE! Launches her far.", uses = 35, dmg = 10, knock = 75, cd = 0.55, range = 11, stamina = 7 }),
	I({ id = "Machete", name = "Machete", rarity = 2, price = 200, kind = "melee", shape = "machete", color = C(200, 200, 205), desc = "Fast cuts that make her bleed.", uses = 50, dmg = 12, knock = 14, cd = 0.32, range = 10, stamina = 5, fx = { bleed = { dps = 3, t = 4 } } }),
	I({ id = "SpikedBat", name = "Spiked Bat", rarity = 2, price = 220, kind = "melee", shape = "spikedbat", color = C(150, 110, 70), desc = "Nails in a bat. Bleeds.", uses = 40, dmg = 13, knock = 32, cd = 0.45, range = 10, stamina = 6, fx = { bleed = { dps = 4, t = 4 } } }),
	I({ id = "FireAxe", name = "Fire Axe", rarity = 3, price = 320, kind = "melee", shape = "axe", color = C(190, 30, 25), desc = "Huge chops.", uses = 40, dmg = 20, knock = 30, cd = 0.58, range = 11, stamina = 8 }),
	I({ id = "Sledgehammer", name = "Sledgehammer", rarity = 3, price = 380, kind = "melee", shape = "sledge", color = C(80, 80, 85), desc = "Slow. Sends her through walls.", uses = 30, dmg = 26, knock = 110, cd = 0.9, range = 11, stamina = 12 }),
	I({ id = "Katana", name = "Katana", rarity = 3, price = 400, kind = "melee", shape = "katana", color = C(220, 225, 230), desc = "Lightning-fast slashes.", uses = 70, dmg = 15, knock = 16, cd = 0.25, range = 11, stamina = 4, fx = { bleed = { dps = 3, t = 3 } } }),
	I({ id = "HolyCross", name = "Holy Cross", rarity = 3, price = 360, kind = "melee", shape = "cross", color = C(220, 200, 120), desc = "Every hit stuns her briefly.", uses = 35, dmg = 12, knock = 24, cd = 0.45, range = 9, stamina = 6, fx = { stun = 0.45 } }),
	I({ id = "Chainsaw", name = "Chainsaw", rarity = 4, price = 600, kind = "melee", shape = "chainsaw", color = C(230, 150, 30), desc = "Hold to shred. Bleeds hard.", uses = 220, dmg = 4.2, knock = 3, cd = 0.09, range = 9, stamina = 0.8, fx = { bleed = { dps = 6, t = 2 } }, sound = "saw" }),
	I({ id = "BurningBat", name = "Burning Bat", rarity = 4, price = 560, kind = "melee", shape = "bat", color = C(255, 110, 30), desc = "Sets her on fire.", uses = 40, dmg = 15, knock = 36, cd = 0.42, range = 10, stamina = 6, fx = { burn = { dps = 8, t = 4 } }, glow = FIRE }),
	I({ id = "FrostPickaxe", name = "Frost Pickaxe", rarity = 4, price = 620, kind = "melee", shape = "pickaxe", color = ICE, desc = "Hits slow her to a crawl.", uses = 40, dmg = 16, knock = 22, cd = 0.48, range = 10, stamina = 7, fx = { slow = { mult = 0.35, t = 3 } }, glow = ICE }),
	I({ id = "StormHammer", name = "Storm Hammer", rarity = 5, price = 950, kind = "melee", shape = "warhammer", color = C(170, 210, 255), desc = "Every hit calls lightning.", uses = 30, dmg = 30, knock = 140, cd = 0.75, range = 11, stamina = 10, fx = { lightning = 20 }, glow = C(170, 210, 255) }),
	I({ id = "DemonBlade", name = "Demon Blade", rarity = 5, price = 1000, kind = "melee", shape = "katana", color = C(160, 20, 30), desc = "Heals you 20% of damage.", uses = 60, dmg = 24, knock = 24, cd = 0.3, range = 11, stamina = 4, fx = { lifesteal = 0.2, bleed = { dps = 5, t = 3 } }, glow = C(255, 30, 40) }),
	-- GUNS -------------------------------------------------------------------
	I({ id = "NailGun", name = "Nail Gun", rarity = 1, price = 120, kind = "gun", shape = "nailgun", color = C(230, 180, 40), desc = "Rapid nails. Hold to fire.", uses = 60, dmg = 3.5, knock = 6, cd = 0.12, range = 45, pellets = 1, spread = 0.02 }),
	I({ id = "Taser", name = "Taser", rarity = 1, price = 140, kind = "gun", shape = "taser", color = C(240, 220, 40), desc = "Stuns her for 1.2 s.", uses = 6, dmg = 4, knock = 0, cd = 0.8, range = 20, pellets = 1, spread = 0, fx = { stun = 1.2 }, tracer = C(150, 200, 255) }),
	I({ id = "PotatoCannon", name = "Potato Cannon", rarity = 1, price = 130, kind = "gun", shape = "cannon", color = C(150, 120, 80), desc = "Huge thump, huge knockback.", uses = 8, dmg = 12, knock = 80, cd = 1.0, range = 50, pellets = 1, spread = 0.01 }),
	I({ id = "SaltShotgun", name = "Rock-Salt Shotgun", rarity = 2, price = 240, kind = "gun", shape = "shotgun", color = C(90, 60, 40), desc = "6 salt pellets. Ghosts hate salt.", uses = 12, dmg = 3.5, knock = 9, cd = 0.9, range = 32, pellets = 6, spread = 0.09 }),
	I({ id = "FlareGun", name = "Flare Gun", rarity = 2, price = 220, kind = "gun", shape = "pistol", color = C(230, 70, 30), desc = "Sets her ablaze.", uses = 5, dmg = 10, knock = 20, cd = 1.1, range = 60, pellets = 1, spread = 0.01, fx = { burn = { dps = 10, t = 5 } }, tracer = FIRE }),
	I({ id = "SilverRevolver", name = "Silver Revolver", rarity = 3, price = 420, kind = "gun", shape = "pistol", color = C(210, 210, 220), desc = "Silver bullets. Big damage.", uses = 6, dmg = 24, knock = 32, cd = 0.55, range = 70, pellets = 1, spread = 0.005 }),
	I({ id = "StakeCrossbow", name = "Stake Crossbow", rarity = 3, price = 450, kind = "gun", shape = "crossbow", color = C(110, 80, 50), desc = "Pins her in place.", uses = 8, dmg = 28, knock = 10, cd = 0.9, range = 60, pellets = 1, spread = 0, fx = { stun = 0.9 }, tracer = C(150, 110, 70) }),
	I({ id = "HarpoonGun", name = "Harpoon Gun", rarity = 4, price = 650, kind = "gun", shape = "harpoon", color = C(70, 90, 110), desc = "Reels her straight to your fists.", uses = 4, dmg = 22, knock = 0, cd = 1.4, range = 60, pellets = 1, spread = 0, fx = { pull = true }, tracer = C(200, 200, 200) }),
	-- THROWABLES -------------------------------------------------------------
	I({ id = "Brick", name = "Brick", rarity = 1, price = 80, kind = "throw", shape = "brick", color = C(150, 70, 50), desc = "A brick. To the face.", uses = 5, dmg = 12, radius = 4, knock = 45 }),
	I({ id = "ThrowingKnives", name = "Throwing Knives", rarity = 1, price = 110, kind = "throw", shape = "knife", color = C(200, 200, 205), desc = "10 knives that bleed.", uses = 10, dmg = 8, radius = 3.5, knock = 6, fx = { bleed = { dps = 3, t = 4 } } }),
	I({ id = "Firecrackers", name = "Firecrackers", rarity = 1, price = 100, kind = "throw", shape = "firecracker", color = C(210, 40, 30), desc = "Bang bang: stuns 1 s.", uses = 4, dmg = 5, radius = 10, knock = 20, fx = { stun = 1 }, boom = true }),
	I({ id = "StinkBomb", name = "Stink Bomb", rarity = 1, price = 90, kind = "throw", shape = "grenade", color = C(110, 140, 50), desc = "Green cloud: slows and hurts.", uses = 3, dmg = 4, radius = 12, knock = 0, fx = { slow = { mult = 0.5, t = 6 }, burn = { dps = 4, t = 6, color = C(120, 170, 40) } } }),
	I({ id = "Molotov", name = "Molotov", rarity = 2, price = 200, kind = "throw", shape = "bottle", color = C(120, 160, 60), desc = "Burns her for 6 s.", uses = 3, dmg = 6, radius = 10, knock = 10, fx = { burn = { dps = 12, t = 6 } }, boom = true }),
	I({ id = "SaltBomb", name = "Salt Bomb", rarity = 2, price = 190, kind = "throw", shape = "pouch", color = C(230, 230, 225), desc = "Slows her to 30% for 6 s.", uses = 3, dmg = 6, radius = 14, knock = 0, fx = { slow = { mult = 0.3, t = 6 } } }),
	I({ id = "BowlingBall", name = "Bowling Ball", rarity = 2, price = 230, kind = "throw", shape = "ball", color = C(40, 60, 140), desc = "STRIKE. Massive knockback.", uses = 3, dmg = 20, radius = 5, knock = 130 }),
	I({ id = "HolyWaterGrenade", name = "Holy Water Grenade", rarity = 3, price = 400, kind = "throw", shape = "grenade", color = HOLY, desc = "Freezes her for 2.5 s.", uses = 3, dmg = 30, radius = 12, knock = 40, fx = { freeze = 2.5 }, boom = true }),
	I({ id = "PipeBomb", name = "Pipe Bomb", rarity = 4, price = 620, kind = "throw", shape = "pipebomb", color = C(110, 110, 115), desc = "Huge blast, wrecks the room.", uses = 2, dmg = 60, radius = 18, knock = 160, boom = true, smash = true }),
	I({ id = "CursedDoll", name = "Cursed Doll", rarity = 5, price = 900, kind = "throw", shape = "doll", color = C(200, 170, 150), desc = "She takes double damage for 10 s.", uses = 1, dmg = 10, radius = 8, knock = 10, fx = { vuln = { mult = 2, t = 10 } } }),
	-- SPRAYS (hold) ----------------------------------------------------------
	I({ id = "LeafBlower", name = "Leaf Blower", rarity = 1, price = 120, kind = "spray", shape = "blower", color = C(220, 100, 30), desc = "Blow her across the room.", uses = 120, dps = 2, range = 20, cone = 0.85, fx = { push = 18 }, particle = C(200, 190, 160) }),
	I({ id = "PepperSpray", name = "Pepper Spray", rarity = 1, price = 100, kind = "spray", shape = "can", color = C(200, 40, 30), desc = "Burns her eyes, slows her.", uses = 60, dps = 6, range = 12, cone = 0.88, fx = { slow = { mult = 0.6, t = 1 } }, particle = C(230, 120, 60) }),
	I({ id = "FireExtinguisher", name = "Fire Extinguisher", rarity = 2, price = 220, kind = "spray", shape = "extinguisher", color = C(200, 25, 25), desc = "Cold cloud: almost freezes her.", uses = 100, dps = 3, range = 16, cone = 0.85, fx = { slow = { mult = 0.25, t = 1.2 } }, particle = C(235, 240, 245) }),
	I({ id = "UVFlashlight", name = "UV Flashlight", rarity = 3, price = 380, kind = "spray", shape = "flashlight", color = C(150, 80, 255), desc = "Ghosts hate UV. Burns and slows.", uses = 150, dps = 10, range = 30, cone = 0.93, fx = { slow = { mult = 0.6, t = 0.6 } }, particle = C(170, 90, 255) }),
	I({ id = "ShopVac", name = "Shop Vac", rarity = 3, price = 420, kind = "spray", shape = "vacuum", color = C(240, 200, 40), desc = "Sucks her toward you.", uses = 100, dps = 3, range = 26, cone = 0.88, fx = { push = -16 }, particle = C(200, 200, 200) }),
	I({ id = "Flamethrower", name = "Flamethrower", rarity = 4, price = 700, kind = "spray", shape = "flamethrower", color = C(120, 120, 60), desc = "A river of fire.", uses = 80, dps = 22, range = 18, cone = 0.85, fx = { burn = { dps = 10, t = 2 } }, particle = FIRE }),
	-- CONSUMABLES (on you) ---------------------------------------------------
	I({ id = "Medkit", name = "Medkit", rarity = 1, price = 120, kind = "use", shape = "medkit", color = C(230, 230, 225), desc = "Heal 50.", uses = 1, heal = 50 }),
	I({ id = "Painkillers", name = "Painkillers", rarity = 1, price = 90, kind = "use", shape = "pills", color = C(240, 140, 40), desc = "Heal 25. Two doses.", uses = 2, heal = 25 }),
	I({ id = "EnergyDrink", name = "Energy Drink", rarity = 1, price = 80, kind = "use", shape = "can", color = C(60, 200, 80), desc = "Full stamina, +30% speed 8 s.", uses = 1, stamina = true, speed = 1.3, speedT = 8 }),
	I({ id = "Adrenaline", name = "Adrenaline Shot", rarity = 2, price = 200, kind = "use", shape = "syringe", color = C(220, 60, 60), desc = "+50% speed 10 s, heal 20.", uses = 1, heal = 20, speed = 1.5, speedT = 10 }),
	I({ id = "KevlarVest", name = "Kevlar Vest", rarity = 2, price = 240, kind = "use", shape = "vest", color = C(60, 70, 60), desc = "Absorbs the next 60 damage.", uses = 1, shield = 60 }),
	I({ id = "RageSerum", name = "Rage Serum", rarity = 3, price = 450, kind = "use", shape = "syringe", color = C(255, 80, 20), desc = "Instantly fills your brutality.", uses = 1, brut = true }),
	I({ id = "Talisman", name = "Paper Talisman", rarity = 3, price = 350, kind = "use", shape = "talisman", color = C(230, 210, 150), desc = "She can't scare or claw you for 20 s.", uses = 1, ward = 20 }),
	I({ id = "PocketWatch", name = "Cursed Pocket Watch", rarity = 5, price = 1000, kind = "use", shape = "watch", color = C(210, 170, 60), desc = "Stops her in time for 6 s.", uses = 1, ghostFreeze = 6 }),
	-- TRAP -------------------------------------------------------------------
	I({ id = "BearTrap", name = "Bear Trap", rarity = 2, price = 210, kind = "trap", shape = "beartrap", color = C(90, 85, 80), desc = "Place it; she gets stuck 3 s.", uses = 2, stun = 3, dmg = 15 }),
}

-- GLOCK 18 (Robux Game Pass, GlockPassId): never sold at the events; owners start every run with it. Full auto.
table.insert(List, I({ id = "Glock18", name = "Glock 18", rarity = 5, price = 0, kind = "gun", shape = "glock", color = C(38, 38, 40),
	desc = "Full auto. Yours in every run.", uses = 999, dmg = 4, knock = 6, cd = 0.07, range = 55, pellets = 1, spread = 0.025, exclusive = true }))

-- tuning on top of the values above: way more reach and knockback for every item
local RANGE_MULT = { melee = 1.7, gun = 1.5, spray = 1.6 }
local KNOCK_MULT = 1.8
for _, it in List do
	if it.range and RANGE_MULT[it.kind] then it.range *= RANGE_MULT[it.kind] end
	if it.knock and it.knock > 0 then it.knock *= KNOCK_MULT end
end

local byId: { [string]: Item } = {}
for _, it in List do byId[it.id] = it end
-- item sounds (names in Shared/Sounds): hit = plays when it connects, use = when you swing / fire,
-- after = a second sound a moment later (pump), every = minimum seconds between two hit sounds, speed = pitch
local SFX = {
	BaseballBat = { hit = "Bonk" },
	FryingPan = { hit = "PanHit" },
	LeadPipe = { hit = "PipeFall", every = 1.2 },
	DemonBlade = { use = "DemonSwing", hit = "DemonHit" },
	NailGun = { use = "NailShot" },
	SaltShotgun = { use = "ShotgunShot", after = "ShotgunPump" },
	PotatoCannon = { use = "CannonShot", speed = 0.8 },
	Glock18 = { use = "GlockShot" },
}
for id, s in SFX do if byId[id] then byId[id].sfx = s end end
return { list = List, byId = byId, rarity = RARITY }
