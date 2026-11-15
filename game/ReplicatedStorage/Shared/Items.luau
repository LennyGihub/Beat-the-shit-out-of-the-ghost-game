--!strict
-- Plane-shop catalog: 50 permanent upgrades in 5 rarities. The pilot's stand rolls a random stock each crash.
-- Stats: multipliers (damage, knock, stamina regen, throw, brutality, speed, staminaCost, ultDuration, cash, combo, reach, armor = damage taken)
-- or additive (health = max HP, lifesteal = fraction of punch damage healed).
export type Item = { id: string, name: string, rarity: number, price: number, desc: string, kind: string, stats: { [string]: number } }

local RARITY = {
	{ name = "COMMON", color = Color3.fromRGB(200, 196, 186), weight = 45 },
	{ name = "UNCOMMON", color = Color3.fromRGB(110, 200, 90), weight = 28 },
	{ name = "RARE", color = Color3.fromRGB(80, 150, 240), weight = 15 },
	{ name = "EPIC", color = Color3.fromRGB(190, 90, 240), weight = 9 },
	{ name = "LEGENDARY", color = Color3.fromRGB(255, 170, 40), weight = 3 },
}

local function it(id, name, rarity, price, kind, desc, stats): Item
	return { id = id, name = name, rarity = rarity, price = price, kind = kind, desc = desc, stats = stats }
end

local Items: { Item } = {
	-- COMMON
	it("RustyKnuckles", "Rusty Knuckles", 1, 90, "knuckles", "+10% punch damage", { damage = 1.10 }),
	it("HandTape", "Cheap Hand Tape", 1, 80, "tape", "+10% knockback", { knock = 1.10 }),
	it("FlatSoda", "Flat Soda", 1, 80, "can", "+15% stamina regen", { stamina = 1.15 }),
	it("ThickHoodie", "Thick Hoodie", 1, 100, "jacket", "+15 max health", { health = 15 }),
	it("SweatBand", "Sweat Band", 1, 90, "tape", "-8% stamina per punch", { staminaCost = 0.92 }),
	it("LuckyPenny", "Lucky Penny", 1, 100, "charm", "+8% ghost cash", { cash = 1.08 }),
	it("OldSneakers", "Old Sneakers", 1, 110, "boots", "+6% move speed", { speed = 1.06 }),
	it("Aspirin", "Aspirin", 1, 100, "pills", "+10% brutality gain", { brutality = 1.10 }),
	it("GardenGloves", "Garden Gloves", 1, 90, "gloves", "+12% throw force", { throw = 1.12 }),
	it("PlasticRosary", "Plastic Rosary", 1, 120, "cross", "-5% damage taken", { armor = 0.95 }),
	-- UNCOMMON
	it("BrassKnuckles", "Brass Knuckles", 2, 220, "knuckles", "+20% punch damage", { damage = 1.20 }),
	it("BloodyWraps", "Bloody Hand Wraps", 2, 200, "tape", "+22% knockback", { knock = 1.22 }),
	it("EnergyDrink", "Expired Energy Drink", 2, 180, "can", "+30% stamina regen", { stamina = 1.30 }),
	it("BikerJacket", "Biker Jacket", 2, 260, "jacket", "+30 max health, -6% damage taken", { health = 30, armor = 0.94 }),
	it("ChalkBag", "Chalk Bag", 2, 200, "pouch", "+25% combo time", { combo = 1.25 }),
	it("RabbitFoot", "Rabbit's Foot", 2, 240, "charm", "+15% ghost cash", { cash = 1.15 }),
	it("RunningShoes", "Running Shoes", 2, 230, "boots", "+12% move speed", { speed = 1.12 }),
	it("Painkillers", "Painkillers", 2, 210, "pills", "+20% brutality gain", { brutality = 1.20 }),
	it("MoversGloves", "Mover's Gloves", 2, 220, "gloves", "+25% throw force", { throw = 1.25 }),
	it("SilverCross", "Silver Cross", 2, 280, "cross", "-12% damage taken", { armor = 0.88 }),
	-- RARE
	it("SpikedKnuckles", "Spiked Knuckles", 3, 420, "knuckles", "+30% damage, +8% knockback", { damage = 1.30, knock = 1.08 }),
	it("SteelToeBoots", "Steel-Toe Boots", 3, 380, "boots", "+10% speed, +15% knockback", { speed = 1.10, knock = 1.15 }),
	it("AdrenalineShot", "Adrenaline Shot", 3, 450, "syringe", "+45% stamina regen, -12% stamina per punch", { stamina = 1.45, staminaCost = 0.88 }),
	it("PilotVest", "Padded Pilot Vest", 3, 480, "jacket", "+45 max health, -10% damage taken", { health = 45, armor = 0.90 }),
	it("VampireFang", "Vampire Fang", 3, 520, "skull", "Heal 4% of punch damage", { lifesteal = 0.04 }),
	it("GoldTooth", "Gold Tooth", 3, 400, "charm", "+30% ghost cash", { cash = 1.30 }),
	it("RagePills", "Rage Pills", 3, 460, "pills", "+35% brutality gain", { brutality = 1.35 }),
	it("ForkliftGloves", "Forklift Gloves", 3, 440, "gloves", "+40% throw force", { throw = 1.40 }),
	it("HolyWater", "Holy Water Flask", 3, 500, "bottle", "+18% damage, -8% damage taken", { damage = 1.18, armor = 0.92 }),
	it("ExtendoSleeves", "Extendo Sleeves", 3, 360, "jacket", "+20% punch reach", { reach = 1.20 }),
	-- EPIC
	it("IronFists", "Cast-Iron Fists", 4, 750, "knuckles", "+45% punch damage", { damage = 1.45 }),
	it("DemonWraps", "Demon Wraps", 4, 780, "tape", "+40% knockback, +15% damage", { knock = 1.40, damage = 1.15 }),
	it("MarathonHeart", "Marathon Heart", 4, 700, "skull", "+70% stamina regen, -20% stamina per punch", { stamina = 1.70, staminaCost = 0.80 }),
	it("RiotArmor", "Riot Armor", 4, 850, "jacket", "+70 max health, -18% damage taken", { health = 70, armor = 0.82 }),
	it("BloodChalice", "Blood Chalice", 4, 880, "bottle", "Heal 8% of punch damage", { lifesteal = 0.08 }),
	it("CursedCoin", "Cursed Coin", 4, 650, "charm", "+50% ghost cash", { cash = 1.50 }),
	it("BerserkerMask", "Berserker Mask", 4, 820, "mask", "+55% brutality gain, +20% ultimate time", { brutality = 1.55, ultDuration = 1.20 }),
	it("TitanGloves", "Titan Gloves", 4, 790, "gloves", "+60% throw force, +8% speed", { throw = 1.60, speed = 1.08 }),
	it("ExorcistBible", "Exorcist's Bible", 4, 900, "book", "+25% damage, -12% damage taken, +20 health", { damage = 1.25, armor = 0.88, health = 20 }),
	it("FightManual", "Street Fighting Manual", 4, 720, "book", "+60% combo time, +10% damage", { combo = 1.60, damage = 1.10 }),
	-- LEGENDARY
	it("FistsOfGod", "Fists of God", 5, 1600, "knuckles", "+80% punch damage", { damage = 1.80 }),
	it("WreckingWraps", "Wrecking Ball Wraps", 5, 1400, "tape", "+80% knockback, +20% throw", { knock = 1.80, throw = 1.20 }),
	it("InfiniteLungs", "Infinite Lungs", 5, 1300, "syringe", "+120% stamina regen, -35% stamina per punch", { stamina = 2.20, staminaCost = 0.65 }),
	it("GhostHideCoat", "Ghost-Hide Coat", 5, 1700, "jacket", "+120 max health, -30% damage taken", { health = 120, armor = 0.70 }),
	it("VampireCrown", "Vampire Lord's Crown", 5, 1800, "mask", "Heal 15% of punch damage", { lifesteal = 0.15 }),
	it("MidasHand", "Midas Hand", 5, 1200, "gloves", "+100% ghost cash", { cash = 2.0 }),
	it("HeartOfRage", "Heart of Rage", 5, 1500, "skull", "+90% brutality gain, +40% ultimate time", { brutality = 1.90, ultDuration = 1.40 }),
	it("HerculesBelt", "Hercules Belt", 5, 1550, "pouch", "+100% throw force, +20% damage", { throw = 2.0, damage = 1.20 }),
	it("SaintsRosary", "Saint's Rosary", 5, 1750, "cross", "+35% damage, -20% damage taken, +40 health", { damage = 1.35, armor = 0.80, health = 40 }),
	it("SpeedDemon", "Speed Demon Sneakers", 5, 1250, "boots", "+30% speed, -25% stamina per punch", { speed = 1.30, staminaCost = 0.75 }),
}

local byId: { [string]: Item } = {}
for _, i in Items do byId[i.id] = i end

-- additive stats; everything else multiplies
local ADD = { health = true, lifesteal = true }

return { list = Items, byId = byId, rarity = RARITY, additive = ADD }
