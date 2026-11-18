--!strict
-- FORMS: what the two sellers in the park sell. DOC MERCY (a struck-off ghost doctor, an old ambulance) sells jars
-- of ECTOPLASM (ghost goo): you open one, the goo crawls over your fists and up your arms and gives a FIST form
-- (more punch damage, more knockback). MOTHER MOTH (a witch, a hut by the pond) sells POTIONS: drunk, they give a
-- BODY form (more health, more stamina). You never know which form a jar / bottle gives: each one rolls one at
-- random, with its own odds by rarity, and the better ones need a higher player level.
-- (Nothing here may look like real drugs, syringes or alcohol: Roblox moderation, see CLAUDE.md. The kind "stim" is
-- only the internal name of Doc Mercy's side.)
-- A form you got is yours for good (saved: Server/Data "Forms"); one fist form and one body form are worn at a time
-- (player attributes FormStim / FormPotion), the rest wait in the collection. Server/Forms rolls, saves and applies
-- them (Combat.stat); Client/FormCine plays the first-person jar / drink and shows what you got.
export type Form = { id: string, kind: string, name: string, rarity: number, color: Color3, desc: string,
	dmg: number?, knock: number?, hp: number?, sta: number? }
export type Vial = { id: string, kind: string, name: string, level: number, price: number, odds: { number }, color: Color3, desc: string }

local function C(r, g, b) return Color3.fromRGB(r, g, b) end

local RARITY = {
	{ name = "COMMON", color = C(200, 196, 186) },
	{ name = "UNCOMMON", color = C(110, 200, 90) },
	{ name = "RARE", color = C(80, 150, 240) },
	{ name = "EPIC", color = C(190, 90, 240) },
	{ name = "LEGENDARY", color = C(255, 170, 40) },
	{ name = "MYTHIC", color = C(255, 60, 60) },
}

local function f(t: { [string]: any }): Form return t :: any end

-- dmg / knock / hp / sta = the bonus (0.12 = +12%)
local List: { Form } = {
	-- DOC MERCY'S ECTOPLASM: fist forms (punch damage, knockback; also melee weapons and thrown furniture)
	f({ id = "GhostGrip", kind = "stim", name = "GHOST GRIP", rarity = 1, color = C(200, 240, 170), dmg = 0.06, knock = 0.06,
		desc = "Pale goo under your nails. Ghosts can feel your punches now." }),
	f({ id = "Bruiser", kind = "stim", name = "BRUISER", rarity = 1, color = C(190, 100, 70), dmg = 0.04, knock = 0.12,
		desc = "The goo sets hard over your knuckles." }),
	f({ id = "IronKnuckles", kind = "stim", name = "IRON KNUCKLES", rarity = 2, color = C(160, 180, 200), dmg = 0.12, knock = 0.08,
		desc = "The skin over your fists turns grey and hard." }),
	f({ id = "Poltergeist", kind = "stim", name = "POLTERGEIST", rarity = 2, color = C(236, 140, 50), dmg = 0.06, knock = 0.22,
		desc = "Whatever you hit goes flying, like the house threw it." }),
	f({ id = "Bonebreaker", kind = "stim", name = "BONEBREAKER", rarity = 3, color = C(238, 230, 205), dmg = 0.2, knock = 0.15,
		desc = "You can hear things crack when you hit them." }),
	f({ id = "Piledriver", kind = "stim", name = "PILEDRIVER", rarity = 3, color = C(70, 120, 240), dmg = 0.12, knock = 0.35,
		desc = "Your arms work like pistons." }),
	f({ id = "Berserker", kind = "stim", name = "BERSERKER", rarity = 4, color = C(225, 30, 30), dmg = 0.32, knock = 0.24,
		desc = "Red veins, red eyes, red everything." }),
	f({ id = "WreckingBall", kind = "stim", name = "WRECKING BALL", rarity = 4, color = C(170, 70, 230), dmg = 0.2, knock = 0.55,
		desc = "Ghosts go through walls. Yours, now." }),
	f({ id = "Juggernaut", kind = "stim", name = "JUGGERNAUT", rarity = 5, color = C(255, 190, 50), dmg = 0.45, knock = 0.55,
		desc = "Nothing stops you. Nothing stands up again." }),
	f({ id = "Banshee", kind = "stim", name = "BANSHEE FISTS", rarity = 5, color = C(60, 230, 255), dmg = 0.6, knock = 0.35,
		desc = "Your punches scream when they land." }),
	f({ id = "BlackHand", kind = "stim", name = "THE BLACK HAND", rarity = 6, color = C(255, 36, 36), dmg = 0.75, knock = 0.75,
		desc = "Your arms go black to the elbow. The doc won't look at you." }),
	-- MOTHER MOTH'S POTIONS: body forms (max health, max stamina and its refill)
	f({ id = "WarmBlood", kind = "potion", name = "WARM BLOOD", rarity = 1, color = C(225, 120, 120), hp = 0.08, sta = 0.05,
		desc = "A warmth spreads from your chest." }),
	f({ id = "SecondWind", kind = "potion", name = "SECOND WIND", rarity = 1, color = C(170, 230, 160), hp = 0.04, sta = 0.12,
		desc = "You breathe like you just woke up." }),
	f({ id = "ThickSkin", kind = "potion", name = "THICK SKIN", rarity = 2, color = C(160, 170, 80), hp = 0.16, sta = 0.06,
		desc = "Your skin goes tough as old leather." }),
	f({ id = "DeepLungs", kind = "potion", name = "DEEP LUNGS", rarity = 2, color = C(90, 205, 205), hp = 0.06, sta = 0.22,
		desc = "One breath lasts a whole fight." }),
	f({ id = "Oakheart", kind = "potion", name = "OAKHEART", rarity = 3, color = C(100, 170, 60), hp = 0.26, sta = 0.14,
		desc = "Roots wrap round your heart and hold it steady." }),
	f({ id = "Mothwing", kind = "potion", name = "MOTHWING", rarity = 3, color = C(196, 176, 245), hp = 0.12, sta = 0.36,
		desc = "You feel light. Moths follow you around." }),
	f({ id = "Trollblood", kind = "potion", name = "TROLLBLOOD", rarity = 4, color = C(120, 150, 60), hp = 0.4, sta = 0.2,
		desc = "Cuts close while you watch." }),
	f({ id = "Nightrunner", kind = "potion", name = "NIGHTRUNNER", rarity = 4, color = C(100, 90, 235), hp = 0.2, sta = 0.56,
		desc = "You could run all night. You might have to." }),
	f({ id = "Undying", kind = "potion", name = "UNDYING", rarity = 5, color = C(255, 220, 140), hp = 0.55, sta = 0.4,
		desc = "Death knocks. You don't answer." }),
	f({ id = "Hexblood", kind = "potion", name = "HEXBLOOD", rarity = 5, color = C(215, 60, 210), hp = 0.4, sta = 0.6,
		desc = "Her own blood, she says. Don't ask whose before that." }),
	f({ id = "OldMoon", kind = "potion", name = "THE OLD MOON", rarity = 6, color = C(228, 234, 255), hp = 0.8, sta = 0.7,
		desc = "Your eyes go silver. The ghosts can see it, and they're scared." }),
}

-- odds = weights for rarity 1..6 (they don't have to add up to 100)
local Vials: { Vial } = {
	{ id = "PaleEcto", kind = "stim", name = "PALE ECTOPLASM", level = 1, price = 120, odds = { 70, 25, 5, 0, 0, 0 }, color = C(200, 240, 170),
		desc = "Scraped off a haunted wall." },
	{ id = "GreenEcto", kind = "stim", name = "FRESH ECTOPLASM", level = 6, price = 450, odds = { 38, 38, 19, 5, 0, 0 }, color = C(110, 220, 90),
		desc = "Still warm. Still moving." },
	{ id = "VioletEcto", kind = "stim", name = "POLTERGEIST GOO", level = 12, price = 1400, odds = { 12, 33, 33, 18, 4, 0 }, color = C(190, 90, 240),
		desc = "It knocks on the glass from the inside." },
	{ id = "RedEcto", kind = "stim", name = "BANSHEE GOO", level = 20, price = 4000, odds = { 0, 16, 38, 30, 13, 3 }, color = C(255, 60, 60),
		desc = "It screams when you open the jar." },
	{ id = "MurkyPotion", kind = "potion", name = "MURKY POTION", level = 1, price = 120, odds = { 70, 25, 5, 0, 0, 0 }, color = C(150, 170, 90),
		desc = "Pond water and a good spell." },
	{ id = "MoonPotion", kind = "potion", name = "MOONLIT POTION", level = 6, price = 450, odds = { 38, 38, 19, 5, 0, 0 }, color = C(150, 190, 240),
		desc = "Made under a full moon. She says." },
	{ id = "HexPotion", kind = "potion", name = "HEX POTION", level = 12, price = 1400, odds = { 12, 33, 33, 18, 4, 0 }, color = C(200, 70, 200),
		desc = "It moves in the bottle when you don't look." },
	{ id = "CauldronPotion", kind = "potion", name = "BLACK CAULDRON", level = 20, price = 4000, odds = { 0, 16, 38, 30, 13, 3 }, color = C(255, 60, 60),
		desc = "From the bottom of her oldest pot." },
}

local byId: { [string]: Form } = {}
for _, x in List do byId[x.id] = x end
local vialById: { [string]: Vial } = {}
for _, v in Vials do vialById[v.id] = v end

local Forms = { list = List, byId = byId, vials = Vials, vialById = vialById, rarity = RARITY }

-- the jars' / bottles' pictures (tools/make_image.py --style ps2; PNGs in the game-art repo, icons/vial_*.png)
Forms.icons = {
	-- (Doc Mercy's jars: no picture until the user has looked at one; the panel shows a block of the jar's colour)
	MurkyPotion = "rbxassetid://96874923160586",
	MoonPotion = "rbxassetid://91578214849877",
	HexPotion = "rbxassetid://91850411021675",
	CauldronPotion = "rbxassetid://93882232318616",
} :: { [string]: string }

Forms.SELLER = {
	stim = { name = "DOC MERCY", what = "ECTOPLASM", verb = "OPEN" },
	potion = { name = "MOTHER MOTH", what = "POTIONS", verb = "DRINK" },
}

function Forms.ofKind(kind: string): { Form }
	local out = {}
	for _, x in List do if x.kind == kind then table.insert(out, x) end end
	table.sort(out, function(a, b) if a.rarity ~= b.rarity then return a.rarity < b.rarity end return a.name < b.name end)
	return out
end

function Forms.vialsOf(kind: string): { Vial }
	local out = {}
	for _, v in Vials do if v.kind == kind then table.insert(out, v) end end
	return out
end

-- the odds (0..1) of each rarity for a vial: { [rarity] = chance }, only rarities that exist for its kind
function Forms.chances(v: Vial): { [number]: number }
	local has = {} :: { [number]: boolean }
	for _, x in List do if x.kind == v.kind then has[x.rarity] = true end end
	local total = 0
	for r, w in v.odds do if has[r] then total += w end end
	local out = {}
	for r, w in v.odds do if has[r] and w > 0 then out[r] = w / total end end
	return out
end

-- a random form out of a vial (server only)
function Forms.roll(v: Vial, rng: Random): Form
	local ch = Forms.chances(v)
	local x = rng:NextNumber()
	local rarity = 1
	local acc = 0
	for r = 1, #RARITY do
		local c = ch[r]
		if c then
			acc += c
			rarity = r
			if x <= acc then break end
		end
	end
	local pool = {}
	for _, fm in List do if fm.kind == v.kind and fm.rarity == rarity then table.insert(pool, fm) end end
	return pool[rng:NextInteger(1, #pool)]
end

-- the lines shown for a form: { "+12% PUNCH DAMAGE", ... }
function Forms.lines(fm: Form): { string }
	local out = {}
	local function pct(n: number?): string return "+" .. math.floor((n or 0) * 100 + 0.5) .. "%" end
	if fm.kind == "stim" then
		table.insert(out, pct(fm.dmg) .. " PUNCH DAMAGE")
		table.insert(out, pct(fm.knock) .. " KNOCKBACK")
	else
		table.insert(out, pct(fm.hp) .. " MAX HEALTH")
		table.insert(out, pct(fm.sta) .. " STAMINA")
	end
	return out
end

-- a rough "how good" score (to compare two forms of the same kind)
function Forms.power(fm: Form?): number
	if not fm then return 0 end
	return (fm.dmg or 0) + (fm.knock or 0) + (fm.hp or 0) + (fm.sta or 0)
end

return Forms
