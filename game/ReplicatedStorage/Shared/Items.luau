--!strict
-- Shop catalog. Stats multiply together when a player owns several items.
-- damage/knock/throw/stamina/brutality are multipliers, health adds max HP, armor multiplies damage taken.
export type Item = { id: string, name: string, price: number, desc: string, stats: { [string]: number } }
local Items: { Item } = {
	{ id = "BrassKnuckles", name = "Brass Knuckles", price = 150, desc = "+25% punch damage", stats = { damage = 1.25 } },
	{ id = "HandWraps", name = "Bloody Hand Wraps", price = 120, desc = "+25% knockback", stats = { knock = 1.25 } },
	{ id = "EnergyDrink", name = "Expired Energy Drink", price = 100, desc = "+35% stamina regen", stats = { stamina = 1.35 } },
	{ id = "PaddedJacket", name = "Padded Pilot Jacket", price = 220, desc = "+40 max health, -15% damage taken", stats = { health = 40, armor = 0.85 } },
	{ id = "RagePills", name = "Rage Pills", price = 260, desc = "+40% brutality gain", stats = { brutality = 1.4 } },
	{ id = "WorkGloves", name = "Mover's Gloves", price = 180, desc = "+35% throw force and throw damage", stats = { throw = 1.35 } },
}
local byId: { [string]: Item } = {}
for _, it in Items do byId[it.id] = it end
return { list = Items, byId = byId }
