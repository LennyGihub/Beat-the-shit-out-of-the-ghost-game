--!strict
-- FORMS: what the two sellers in the park sell. DOC MERCY (a struck-off ghost doctor, an old ambulance) sells jars
-- of ECTOPLASM (ghost goo): you open one, the goo crawls over your fists and up your arms and gives a FIST form
-- (more punch damage, more knockback). MOTHER MOTH (a witch, a hut by the pond) sells POTIONS: drunk, they give a
-- BODY form (more health, more stamina). You never know which form a jar / bottle gives: each one rolls one at
-- random, with its own odds by rarity: they are CHEAP, and the rare forms are very rare (open a lot of them).
-- OPEN OFFLINE: a jar / potion can also be put to open by itself (Forms.OFFLINE: a few minutes each, one after the
-- other, a queue per kind), even while you are in a run or not playing; 24 h of offline opening in total makes the
-- next offline result RARE or better (Server/Forms, Client/OfflineOpen).
-- SETS: every campaign map (Shared/Campaign) brings its own 4 jars and 4 potions, and its own forms in all 6
-- rarities (stronger map after map). A set is for sale once its map is open; in a set, the better jars / potions
-- also need a player level.
-- (Nothing here may look like real drugs, syringes or alcohol: Roblox moderation, see CLAUDE.md. The kind "stim" is
-- only the internal name of Doc Mercy's side.)
-- A form you got is yours for good (saved: Server/Data "Forms"); one fist form and one body form are worn at a time
-- (player attributes FormStim / FormPotion), the rest wait in the collection. Server/Forms rolls, saves and applies
-- them (Combat.stat); Client/FormCine plays the first-person jar / drink and shows what you got.
export type Form = { id: string, kind: string, set: string, name: string, rarity: number, color: Color3, desc: string,
	dmg: number?, knock: number?, hp: number?, sta: number? }
export type Vial = { id: string, kind: string, set: string, tier: number, name: string, level: number, price: number, odds: { number }, color: Color3, desc: string }

local function C(r, g, b) return Color3.fromRGB(r, g, b) end

local RARITY = {
	{ name = "COMMON", color = C(200, 196, 186) },
	{ name = "UNCOMMON", color = C(110, 200, 90) },
	{ name = "RARE", color = C(80, 150, 240) },
	{ name = "EPIC", color = C(190, 90, 240) },
	{ name = "LEGENDARY", color = C(255, 170, 40) },
	{ name = "MYTHIC", color = C(255, 60, 60) },
}

local SET = "Camp" -- (the set the forms below belong to, until it is changed)
local function f(t: { [string]: any }): Form
	t.set = t.set or SET
	return t :: any
end

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
-- MOONLIGHT CARNIVAL (map 2): stronger at every rarity
SET = "Carnival"
for _, x in {
	-- fist forms
	f({ id = "ClownKnuckles", kind = "stim", name = "CLOWN KNUCKLES", rarity = 1, color = C(240, 90, 90), dmg = 0.1, knock = 0.1,
		desc = "Your knuckles go red and shiny, like a clown's nose." }),
	f({ id = "TicketPunch", kind = "stim", name = "TICKET PUNCH", rarity = 1, color = C(240, 200, 120), dmg = 0.08, knock = 0.16,
		desc = "Every hit leaves a little hole." }),
	f({ id = "StrongGrip", kind = "stim", name = "STRONGMAN GRIP", rarity = 2, color = C(200, 160, 110), dmg = 0.2, knock = 0.12,
		desc = "You could bend a horseshoe. You probably shouldn't." }),
	f({ id = "WhackAMole", kind = "stim", name = "WHACK-A-MOLE", rarity = 2, color = C(150, 200, 90), dmg = 0.12, knock = 0.32,
		desc = "Whatever pops up goes straight back down." }),
	f({ id = "RingOfFire", kind = "stim", name = "RING OF FIRE", rarity = 3, color = C(255, 120, 40), dmg = 0.3, knock = 0.24,
		desc = "Sparks fly off your fists like a circus hoop." }),
	f({ id = "HighStriker", kind = "stim", name = "HIGH STRIKER", rarity = 3, color = C(230, 60, 60), dmg = 0.2, knock = 0.55,
		desc = "DING. Every punch rings the bell." }),
	f({ id = "LionTamer", kind = "stim", name = "LION TAMER", rarity = 4, color = C(255, 170, 60), dmg = 0.48, knock = 0.36,
		desc = "The ghosts back off when you raise your fist." }),
	f({ id = "Cannonball", kind = "stim", name = "CANNONBALL", rarity = 4, color = C(80, 80, 96), dmg = 0.32, knock = 0.8,
		desc = "They fly across the room like a stunt act." }),
	f({ id = "MirrorFists", kind = "stim", name = "MIRROR FISTS", rarity = 5, color = C(200, 230, 255), dmg = 0.66, knock = 0.62,
		desc = "Your fists shine like glass. Every hit lands twice." }),
	f({ id = "GreatZambini", kind = "stim", name = "THE GREAT ZAMBINI", rarity = 5, color = C(170, 80, 240), dmg = 0.85, knock = 0.45,
		desc = "A magician's hands. Now you see them, now they hurt." }),
	f({ id = "LastShow", kind = "stim", name = "THE LAST SHOW", rarity = 6, color = C(255, 40, 70), dmg = 1.1, knock = 1.05,
		desc = "The lights go down. The crowd goes quiet. You go on." }),
	-- body forms
	f({ id = "CandyHeart", kind = "potion", name = "CANDY HEART", rarity = 1, color = C(255, 140, 200), hp = 0.12, sta = 0.08,
		desc = "Sweet and sticky, and it keeps you going." }),
	f({ id = "SpringStep", kind = "potion", name = "SPRING STEP", rarity = 1, color = C(150, 230, 200), hp = 0.06, sta = 0.18,
		desc = "There's a bounce in your step now." }),
	f({ id = "StiltWalker", kind = "potion", name = "STILT WALKER", rarity = 2, color = C(200, 170, 120), hp = 0.24, sta = 0.1,
		desc = "You feel tall. Ghosts look up at you." }),
	f({ id = "Acrobat", kind = "potion", name = "ACROBAT", rarity = 2, color = C(120, 200, 255), hp = 0.1, sta = 0.34,
		desc = "You could run the high wire all night." }),
	f({ id = "IronBelly", kind = "potion", name = "IRON BELLY", rarity = 3, color = C(150, 150, 165), hp = 0.38, sta = 0.2,
		desc = "Punch me in the stomach. Go on." }),
	f({ id = "Trapeze", kind = "potion", name = "TRAPEZE", rarity = 3, color = C(240, 200, 90), hp = 0.18, sta = 0.52,
		desc = "You never touch the ground for long." }),
	f({ id = "StrongmanBody", kind = "potion", name = "STRONGMAN", rarity = 4, color = C(210, 120, 80), hp = 0.58, sta = 0.3,
		desc = "Big arms, big chest, big moustache (optional)." }),
	f({ id = "HumanCannon", kind = "potion", name = "HUMAN CANNONBALL", rarity = 4, color = C(230, 60, 50), hp = 0.32, sta = 0.78,
		desc = "Fired across the tent and still standing." }),
	f({ id = "FortuneFavour", kind = "potion", name = "FORTUNE'S FAVOUR", rarity = 5, color = C(190, 100, 255), hp = 0.78, sta = 0.56,
		desc = "The cards say you live. The cards are never wrong." }),
	f({ id = "FireEater", kind = "potion", name = "FIRE EATER", rarity = 5, color = C(255, 110, 30), hp = 0.56, sta = 0.82,
		desc = "Hot breath, hot blood, no stopping." }),
	f({ id = "Encore", kind = "potion", name = "ENCORE", rarity = 6, color = C(255, 215, 90), hp = 1.15, sta = 0.98,
		desc = "Whatever happens, you come back for one more." }),
} do table.insert(List, x) end
-- BLACKWATER HARBOR (map 3): stronger again at every rarity
SET = "Harbor"
for _, x in {
	-- fist forms
	f({ id = "SaltKnuckles", kind = "stim", name = "SALT KNUCKLES", rarity = 1, color = C(220, 230, 235), dmg = 0.16, knock = 0.14,
		desc = "Sea salt crusts over your knuckles. It stings them, not you." }),
	f({ id = "Barnacle", kind = "stim", name = "BARNACLE FISTS", rarity = 1, color = C(150, 140, 120), dmg = 0.12, knock = 0.24,
		desc = "Shells grow over your hands. Hard as rock." }),
	f({ id = "Harpoon", kind = "stim", name = "HARPOON", rarity = 2, color = C(170, 190, 200), dmg = 0.3, knock = 0.18,
		desc = "Every punch goes straight through, like a barbed spear." }),
	f({ id = "RiptideFists", kind = "stim", name = "RIPTIDE", rarity = 2, color = C(60, 160, 200), dmg = 0.18, knock = 0.46,
		desc = "Your hits pull them under and throw them out." }),
	f({ id = "Anchorhand", kind = "stim", name = "ANCHORHAND", rarity = 3, color = C(90, 96, 110), dmg = 0.42, knock = 0.34,
		desc = "Your fists weigh a ton. They drop like anchors." }),
	f({ id = "Stormfist", kind = "stim", name = "STORMFIST", rarity = 3, color = C(120, 170, 255), dmg = 0.3, knock = 0.75,
		desc = "Thunder rolls every time you swing." }),
	f({ id = "KrakenGrip", kind = "stim", name = "KRAKEN GRIP", rarity = 4, color = C(130, 60, 160), dmg = 0.66, knock = 0.5,
		desc = "Your arms feel like they have more than one elbow." }),
	f({ id = "Tidebreaker", kind = "stim", name = "TIDEBREAKER", rarity = 4, color = C(40, 120, 220), dmg = 0.45, knock = 1.1,
		desc = "You punch the sea back where it came from." }),
	f({ id = "LighthouseFist", kind = "stim", name = "LIGHTHOUSE FISTS", rarity = 5, color = C(255, 236, 150), dmg = 0.9, knock = 0.85,
		desc = "Your fists burn like the lamp at the top of the tower." }),
	f({ id = "DeepFists", kind = "stim", name = "FISTS OF THE DEEP", rarity = 5, color = C(30, 200, 180), dmg = 1.15, knock = 0.6,
		desc = "Cold, dark and heavy. Things down there don't feel pain." }),
	f({ id = "DrownedKing", kind = "stim", name = "THE DROWNED KING", rarity = 6, color = C(40, 255, 200), dmg = 1.5, knock = 1.4,
		desc = "The sea gave you its crown. It wants something back." }),
	-- body forms
	f({ id = "SeaLegs", kind = "potion", name = "SEA LEGS", rarity = 1, color = C(110, 180, 220), hp = 0.18, sta = 0.12,
		desc = "Nothing knocks you over. Not even a wave." }),
	f({ id = "Brine", kind = "potion", name = "BRINE BLOOD", rarity = 1, color = C(160, 200, 170), hp = 0.1, sta = 0.26,
		desc = "Salt water in your veins. You never get tired." }),
	f({ id = "Oilskin", kind = "potion", name = "OILSKIN", rarity = 2, color = C(220, 190, 60), hp = 0.34, sta = 0.14,
		desc = "The rain runs off you. So do the claws." }),
	f({ id = "Gills", kind = "potion", name = "GILLS", rarity = 2, color = C(80, 200, 170), hp = 0.16, sta = 0.48,
		desc = "You breathe easier than ever. Don't look at your neck." }),
	f({ id = "Ironclad", kind = "potion", name = "IRONCLAD", rarity = 3, color = C(130, 140, 150), hp = 0.54, sta = 0.28,
		desc = "Plated like an old warship." }),
	f({ id = "Galeforce", kind = "potion", name = "GALEFORCE", rarity = 3, color = C(180, 220, 255), hp = 0.26, sta = 0.74,
		desc = "You move like the wind off the sea." }),
	f({ id = "Leviathan", kind = "potion", name = "LEVIATHAN", rarity = 4, color = C(40, 110, 140), hp = 0.82, sta = 0.42,
		desc = "Huge, slow to anger, impossible to sink." }),
	f({ id = "StormRider", kind = "potion", name = "STORM RIDER", rarity = 4, color = C(150, 120, 255), hp = 0.46, sta = 1.1,
		desc = "The storm carries you. It never sets you down." }),
	f({ id = "Lighthouse", kind = "potion", name = "THE LIGHTHOUSE", rarity = 5, color = C(255, 230, 140), hp = 1.1, sta = 0.8,
		desc = "A light inside you that the dark can't put out." }),
	f({ id = "Undertow", kind = "potion", name = "UNDERTOW", rarity = 5, color = C(20, 160, 170), hp = 0.8, sta = 1.15,
		desc = "Whatever pulls at you, you pull back harder." }),
	f({ id = "BlackTide", kind = "potion", name = "THE BLACK TIDE", rarity = 6, color = C(60, 255, 220), hp = 1.6, sta = 1.4,
		desc = "The harbor's whole black sea, in one body." }),
} do table.insert(List, x) end

-- odds = weights for rarity 1..6, in % (the rare ones are very rare: the jars are cheap, open lots of them)
local ODDS = {
	{ 78, 18, 3.4, 0.5, 0.09, 0.01 },
	{ 60, 28, 9, 2.5, 0.45, 0.05 },
	{ 42, 33, 17, 6.5, 1.3, 0.2 },
	{ 25, 33, 25, 13, 3.5, 0.5 },
}
local function V(set: string, tier: number, t: { [string]: any }): Vial
	t.set = set; t.odds = ODDS[tier]; t.tier = tier
	return t :: any
end
local Vials: { Vial } = {
	-- CAMP HOLLOWMERE
	V("Camp", 1, { id = "PaleEcto", kind = "stim", name = "PALE ECTOPLASM", level = 1, price = 5, color = C(200, 240, 170), desc = "Scraped off a haunted wall." }),
	V("Camp", 2, { id = "GreenEcto", kind = "stim", name = "FRESH ECTOPLASM", level = 3, price = 12, color = C(110, 220, 90), desc = "Still warm. Still moving." }),
	V("Camp", 3, { id = "VioletEcto", kind = "stim", name = "POLTERGEIST GOO", level = 6, price = 25, color = C(190, 90, 240), desc = "It knocks on the glass from the inside." }),
	V("Camp", 4, { id = "RedEcto", kind = "stim", name = "BANSHEE GOO", level = 10, price = 50, color = C(255, 60, 60), desc = "It screams when you open the jar." }),
	V("Camp", 1, { id = "MurkyPotion", kind = "potion", name = "MURKY POTION", level = 1, price = 5, color = C(150, 170, 90), desc = "Pond water and a good spell." }),
	V("Camp", 2, { id = "MoonPotion", kind = "potion", name = "MOONLIT POTION", level = 3, price = 12, color = C(150, 190, 240), desc = "Made under a full moon. She says." }),
	V("Camp", 3, { id = "HexPotion", kind = "potion", name = "HEX POTION", level = 6, price = 25, color = C(200, 70, 200), desc = "It moves in the bottle when you don't look." }),
	V("Camp", 4, { id = "CauldronPotion", kind = "potion", name = "BLACK CAULDRON", level = 10, price = 50, color = C(255, 60, 60), desc = "From the bottom of her oldest pot." }),
	-- MOONLIGHT CARNIVAL (open once Camp Hollowmere is cleared)
	V("Carnival", 1, { id = "CandyEcto", kind = "stim", name = "CANDY GOO", level = 11, price = 15, color = C(255, 140, 200), desc = "Off the candy floss machine. It still spins." }),
	V("Carnival", 2, { id = "PaintEcto", kind = "stim", name = "GREASEPAINT GOO", level = 12, price = 35, color = C(240, 236, 228), desc = "Off a clown's face. Don't ask which clown." }),
	V("Carnival", 3, { id = "MirrorEcto", kind = "stim", name = "MIRROR GOO", level = 14, price = 75, color = C(190, 220, 240), desc = "Your reflection moves before you do." }),
	V("Carnival", 4, { id = "BigTopEcto", kind = "stim", name = "BIG TOP GOO", level = 16, price = 150, color = C(230, 40, 60), desc = "From under the ring. The crowd still cheers in it." }),
	V("Carnival", 1, { id = "CaramelPotion", kind = "potion", name = "CARAMEL POTION", level = 11, price = 15, color = C(220, 150, 60), desc = "Toffee apples, boiled down to a spell." }),
	V("Carnival", 2, { id = "FortunePotion", kind = "potion", name = "FORTUNE POTION", level = 12, price = 35, color = C(170, 90, 240), desc = "Madame Fortune's recipe. She wasn't using it." }),
	V("Carnival", 3, { id = "CarouselPotion", kind = "potion", name = "CAROUSEL POTION", level = 14, price = 75, color = C(90, 210, 200), desc = "Everything spins, then you feel great." }),
	V("Carnival", 4, { id = "MidnightPotion", kind = "potion", name = "MIDNIGHT SHOW", level = 16, price = 150, color = C(255, 200, 80), desc = "Brewed in the Big Top after closing time." }),
	-- BLACKWATER HARBOR (open once the Moonlight Carnival is cleared)
	V("Harbor", 1, { id = "SaltEcto", kind = "stim", name = "SEA FOAM GOO", level = 17, price = 40, color = C(220, 236, 240), desc = "Scooped off the harbor wall at high tide." }),
	V("Harbor", 2, { id = "NetEcto", kind = "stim", name = "NET GOO", level = 18, price = 90, color = C(150, 190, 120), desc = "Wrung out of a fishing net that pulled up something wrong." }),
	V("Harbor", 3, { id = "LampEcto", kind = "stim", name = "LAMP OIL GOO", level = 20, price = 180, color = C(255, 220, 110), desc = "From the lighthouse lamp. It still glows." }),
	V("Harbor", 4, { id = "AbyssEcto", kind = "stim", name = "ABYSS GOO", level = 22, price = 360, color = C(40, 255, 200), desc = "From the bottom of the harbor. Nobody has been down there twice." }),
	V("Harbor", 1, { id = "SeawaterPotion", kind = "potion", name = "SEAWATER POTION", level = 17, price = 40, color = C(80, 160, 210), desc = "Salt, kelp and a whisper of a spell." }),
	V("Harbor", 2, { id = "StormPotion", kind = "potion", name = "STORM POTION", level = 18, price = 90, color = C(150, 120, 255), desc = "Bottled in a storm. It still thunders." }),
	V("Harbor", 3, { id = "PearlPotion", kind = "potion", name = "PEARL POTION", level = 20, price = 180, color = C(236, 230, 250), desc = "A black pearl dissolved in moonlight." }),
	V("Harbor", 4, { id = "TidePotion", kind = "potion", name = "BLACK TIDE BREW", level = 22, price = 360, color = C(30, 220, 190), desc = "The whole harbor boiled down to one bottle." }),
}
-- the sets in order (the campaign maps that have one)
local SETS = { "Camp", "Carnival", "Harbor" }

local byId: { [string]: Form } = {}
for _, x in List do byId[x.id] = x end
local vialById: { [string]: Vial } = {}
for _, v in Vials do vialById[v.id] = v end

local Forms = { list = List, byId = byId, vials = Vials, vialById = vialById, rarity = RARITY, sets = SETS }

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

local function setIndex(set: string): number return table.find(SETS, set) or 99 end

-- OPEN OFFLINE (Server/Forms): seconds one jar / potion takes by its tier (1..4), how many can wait in a kind's queue,
-- and the total opening time after which the next offline result is RARE or better (rarity 3+)
Forms.OFFLINE = { times = { 180, 360, 600, 900 }, maxQueue = 200, pity = 24 * 3600, pityRarity = 3 }
function Forms.openTime(v: Vial): number return Forms.OFFLINE.times[v.tier] or 600 end

-- the level the set's best jar / potion needs (clearing that map brings a player to it: Server/Data.mapLevel)
function Forms.topLevel(set: string): number
	local n = 0
	for _, v in Vials do if v.set == set then n = math.max(n, v.level) end end
	return n
end

-- every form of a kind (set = only that set's), sorted by set, then rarity
function Forms.ofKind(kind: string, set: string?): { Form }
	local out = {}
	for _, x in List do if x.kind == kind and (set == nil or x.set == set) then table.insert(out, x) end end
	table.sort(out, function(a, b)
		if a.set ~= b.set then return setIndex(a.set) < setIndex(b.set) end
		if a.rarity ~= b.rarity then return a.rarity < b.rarity end
		return a.name < b.name
	end)
	return out
end

-- the jars / potions of a kind (set = only that set's)
function Forms.vialsOf(kind: string, set: string?): { Vial }
	local out = {}
	for _, v in Vials do if v.kind == kind and (set == nil or v.set == set) then table.insert(out, v) end end
	return out
end

-- the odds (0..1) of each rarity for a vial: { [rarity] = chance }, only rarities its set has for its kind
function Forms.chances(v: Vial): { [number]: number }
	local has = {} :: { [number]: boolean }
	for _, x in List do if x.kind == v.kind and x.set == v.set then has[x.rarity] = true end end
	local total = 0
	for r, w in v.odds do if has[r] then total += w end end
	local out = {}
	for r, w in v.odds do if has[r] and w > 0 then out[r] = w / total end end
	return out
end

-- a random form out of a vial (server only). minRarity: only that rarity or better (the offline 24 h guarantee),
-- with the vial's own odds between them
function Forms.roll(v: Vial, rng: Random, minRarity: number?): Form
	local ch = Forms.chances(v)
	if minRarity and minRarity > 1 then
		local t = 0
		for r, c in ch do if r >= minRarity then t += c end end
		if t > 0 then
			local out = {}
			for r, c in ch do if r >= minRarity then out[r] = c / t end end
			ch = out
		end
	end
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
	for _, fm in List do if fm.kind == v.kind and fm.set == v.set and fm.rarity == rarity then table.insert(pool, fm) end end
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

-- a chance (0..1) as text: "18%", "3.4%", "0.05%"
function Forms.pct(c: number): string
	if c >= 0.1 then return tostring(math.floor(c * 100 + 0.5)) .. "%" end
	if c >= 0.01 then return tostring(math.floor(c * 1000 + 0.5) / 10) .. "%" end
	return tostring(math.floor(c * 10000 + 0.5) / 100) .. "%"
end

-- a rough "how good" score (to compare two forms of the same kind)
function Forms.power(fm: Form?): number
	if not fm then return 0 end
	return (fm.dmg or 0) + (fm.knock or 0) + (fm.hp or 0) + (fm.sta or 0)
end

return Forms
