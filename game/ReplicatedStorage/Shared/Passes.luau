--!strict
-- The Robux Game Passes, in the order the shop shows them. Each one is bought once and kept forever.
--   key   = its shop card (picture: Shared/ShopArt)
--   id    = the ReplicatedStorage attribute that holds the Game Pass id (0 = not on sale yet: the shop shows SOON)
--   own   = the player attribute the server sets to true for an owner (the clients only read it)
--   toast = shown when it is bought in game
-- The server checks ownership in Server/Monetization (the Admin Panel pass: Server/Admin, admin = true).
export type Pass = { key: string, name: string, desc: string, color: Color3, id: string, own: string, toast: string, admin: boolean? }

local function C(r: number, g: number, b: number): Color3 return Color3.fromRGB(r, g, b) end

local List: { Pass } = {
	{ key = "pass_money2", name = "2X Money", desc = "Forever: every run pays double.", color = C(240, 200, 60),
		id = "Money2PassId", own = "Money2", toast = "2X MONEY UNLOCKED - every run pays double" },
	{ key = "pass_doubleult", name = "Double Ultimate", desc = "Forever: equip two ultimates and switch between them in a fight.", color = C(255, 120, 40),
		id = "DoubleUltPassId", own = "DoubleUlt", toast = "DOUBLE ULTIMATE UNLOCKED - pick a second ultimate at the dealer" },
	{ key = "pass_vip", name = "VIP", desc = "Forever: VIP chat tag, gold name and +20% cash.", color = C(255, 205, 60),
		id = "VipPassId", own = "VIP", toast = "VIP UNLOCKED - gold name and +20% cash" },
	{ key = "pass_second", name = "Second Chance", desc = "Forever: one free revive in every run.", color = C(230, 60, 60),
		id = "SecondChancePassId", own = "SecondChance", toast = "SECOND CHANCE UNLOCKED - one free revive in every run" },
	{ key = "pass_glock", name = "Glock 18", desc = "Forever: a full-auto Glock 18 in your hotbar every run.", color = C(200, 200, 205),
		id = "GlockPassId", own = "GlockPass", toast = "GLOCK 18 UNLOCKED - it is in your hotbar every run" },
	{ key = "pass_admin", name = "Admin Panel", desc = "Every cheat, forever: cash, items, ultimates, maps, god mode. Opens with F2.", color = C(120, 230, 120),
		id = "AdminPassId", own = "IsAdmin", toast = "ADMIN PANEL UNLOCKED - press F2", admin = true },
}

local byOwn: { [string]: Pass } = {}
for _, p in List do byOwn[p.own] = p end

return { list = List, byOwn = byOwn }
