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
	dmg: number?, knock: number?, hp: number?, sta: number?, exclusive: boolean?, color2: Color3? }
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

-- dmg / knock / hp / sta = the bonus (0.12 = +12%, 2.5 = x3.5)
-- BALANCE (2026-11-21, the user: "the legendary form of a map makes the map really easy"): a map's forms are sized
-- to its monsters (Campaign map hp / dmg x their levels: on average Camp 1, Carnival x3.2 health / x2.2 damage,
-- Harbor x7.2 / x3.9, Abbey x13.4 / x6.1, Moon x23.3 / x9.1 of Camp's). Fist forms: punch damage = that health
-- need x (COMMON 1.1, UNCOMMON 1.3, RARE 1.55, EPIC 1.9, LEGENDARY 2.5, MYTHIC 3.3); body forms: max health = the
-- damage need x the same. So a COMMON makes its map about as hard as Camp is with no form, a LEGENDARY makes it
-- far easier (its monsters fall in 40% of the time, you take 2.5x the hits), and the next map needs its own forms.
-- Of the two forms of a rarity, the knockback / stamina one gets 78% of the other's damage / health bonus.
-- (Knockback and stamina did not change: knockback does not need to grow, and Combat.guard's block cost shrinks
-- with the body form's health.)
local List: { Form } = {
	-- DOC MERCY'S ECTOPLASM: fist forms (punch damage, knockback; also melee weapons and thrown furniture)
	f({ id = "GhostGrip", kind = "stim", name = "GHOST GRIP", rarity = 1, color = C(200, 240, 170), dmg = 0.1, knock = 0.06,
		desc = "Pale goo under your nails. Ghosts can feel your punches now." }),
	f({ id = "Bruiser", kind = "stim", name = "BRUISER", rarity = 1, color = C(190, 100, 70), dmg = 0.08, knock = 0.12,
		desc = "The goo sets hard over your knuckles." }),
	f({ id = "IronKnuckles", kind = "stim", name = "IRON KNUCKLES", rarity = 2, color = C(160, 180, 200), dmg = 0.3, knock = 0.08,
		desc = "The skin over your fists turns grey and hard." }),
	f({ id = "Poltergeist", kind = "stim", name = "POLTERGEIST", rarity = 2, color = C(236, 140, 50), dmg = 0.23, knock = 0.22,
		desc = "Whatever you hit goes flying, like the house threw it." }),
	f({ id = "Bonebreaker", kind = "stim", name = "BONEBREAKER", rarity = 3, color = C(238, 230, 205), dmg = 0.55, knock = 0.15,
		desc = "You can hear things crack when you hit them." }),
	f({ id = "Piledriver", kind = "stim", name = "PILEDRIVER", rarity = 3, color = C(70, 120, 240), dmg = 0.43, knock = 0.35,
		desc = "Your arms work like pistons." }),
	f({ id = "Berserker", kind = "stim", name = "BERSERKER", rarity = 4, color = C(225, 30, 30), dmg = 0.9, knock = 0.24,
		desc = "Red veins, red eyes, red everything." }),
	f({ id = "WreckingBall", kind = "stim", name = "WRECKING BALL", rarity = 4, color = C(170, 70, 230), dmg = 0.7, knock = 0.55,
		desc = "Ghosts go through walls. Yours, now." }),
	f({ id = "Juggernaut", kind = "stim", name = "JUGGERNAUT", rarity = 5, color = C(255, 190, 50), dmg = 1.15, knock = 0.55,
		desc = "Nothing stops you. Nothing stands up again." }),
	f({ id = "Banshee", kind = "stim", name = "BANSHEE FISTS", rarity = 5, color = C(60, 230, 255), dmg = 1.5, knock = 0.35,
		desc = "Your punches scream when they land." }),
	f({ id = "BlackHand", kind = "stim", name = "THE BLACK HAND", rarity = 6, color = C(255, 36, 36), dmg = 2.3, knock = 0.75,
		desc = "Your arms go black to the elbow. The doc won't look at you." }),
	-- MOTHER MOTH'S POTIONS: body forms (max health, max stamina and its refill)
	f({ id = "WarmBlood", kind = "potion", name = "WARM BLOOD", rarity = 1, color = C(225, 120, 120), hp = 0.1, sta = 0.05,
		desc = "A warmth spreads from your chest." }),
	f({ id = "SecondWind", kind = "potion", name = "SECOND WIND", rarity = 1, color = C(170, 230, 160), hp = 0.08, sta = 0.12,
		desc = "You breathe like you just woke up." }),
	f({ id = "ThickSkin", kind = "potion", name = "THICK SKIN", rarity = 2, color = C(160, 170, 80), hp = 0.3, sta = 0.06,
		desc = "Your skin goes tough as old leather." }),
	f({ id = "DeepLungs", kind = "potion", name = "DEEP LUNGS", rarity = 2, color = C(90, 205, 205), hp = 0.23, sta = 0.22,
		desc = "One breath lasts a whole fight." }),
	f({ id = "Oakheart", kind = "potion", name = "OAKHEART", rarity = 3, color = C(100, 170, 60), hp = 0.55, sta = 0.14,
		desc = "Roots wrap round your heart and hold it steady." }),
	f({ id = "Mothwing", kind = "potion", name = "MOTHWING", rarity = 3, color = C(196, 176, 245), hp = 0.43, sta = 0.36,
		desc = "You feel light. Moths follow you around." }),
	f({ id = "Trollblood", kind = "potion", name = "TROLLBLOOD", rarity = 4, color = C(120, 150, 60), hp = 0.9, sta = 0.2,
		desc = "Cuts close while you watch." }),
	f({ id = "Nightrunner", kind = "potion", name = "NIGHTRUNNER", rarity = 4, color = C(100, 90, 235), hp = 0.7, sta = 0.56,
		desc = "You could run all night. You might have to." }),
	f({ id = "Undying", kind = "potion", name = "UNDYING", rarity = 5, color = C(255, 220, 140), hp = 1.5, sta = 0.4,
		desc = "Death knocks. You don't answer." }),
	f({ id = "Hexblood", kind = "potion", name = "HEXBLOOD", rarity = 5, color = C(215, 60, 210), hp = 1.15, sta = 0.6,
		desc = "Her own blood, she says. Don't ask whose before that." }),
	f({ id = "OldMoon", kind = "potion", name = "THE OLD MOON", rarity = 6, color = C(228, 234, 255), hp = 2.3, sta = 0.7,
		desc = "Your eyes go silver. The ghosts can see it, and they're scared." }),
}
-- MOONLIGHT CARNIVAL (map 2): stronger at every rarity
SET = "Carnival"
for _, x in {
	-- fist forms
	f({ id = "ClownKnuckles", kind = "stim", name = "CLOWN KNUCKLES", rarity = 1, color = C(240, 90, 90), dmg = 2.55, knock = 0.1,
		desc = "Your knuckles go red and shiny, like a clown's nose." }),
	f({ id = "TicketPunch", kind = "stim", name = "TICKET PUNCH", rarity = 1, color = C(240, 200, 120), dmg = 2, knock = 0.16,
		desc = "Every hit leaves a little hole." }),
	f({ id = "StrongGrip", kind = "stim", name = "STRONGMAN GRIP", rarity = 2, color = C(200, 160, 110), dmg = 3.2, knock = 0.12,
		desc = "You could bend a horseshoe. You probably shouldn't." }),
	f({ id = "WhackAMole", kind = "stim", name = "WHACK-A-MOLE", rarity = 2, color = C(150, 200, 90), dmg = 2.5, knock = 0.32,
		desc = "Whatever pops up goes straight back down." }),
	f({ id = "RingOfFire", kind = "stim", name = "RING OF FIRE", rarity = 3, color = C(255, 120, 40), dmg = 4, knock = 0.24,
		desc = "Sparks fly off your fists like a circus hoop." }),
	f({ id = "HighStriker", kind = "stim", name = "HIGH STRIKER", rarity = 3, color = C(230, 60, 60), dmg = 3.1, knock = 0.55,
		desc = "DING. Every punch rings the bell." }),
	f({ id = "LionTamer", kind = "stim", name = "LION TAMER", rarity = 4, color = C(255, 170, 60), dmg = 5.1, knock = 0.36,
		desc = "The ghosts back off when you raise your fist." }),
	f({ id = "Cannonball", kind = "stim", name = "CANNONBALL", rarity = 4, color = C(80, 80, 96), dmg = 4, knock = 0.8,
		desc = "They fly across the room like a stunt act." }),
	f({ id = "MirrorFists", kind = "stim", name = "MIRROR FISTS", rarity = 5, color = C(200, 230, 255), dmg = 5.5, knock = 0.62,
		desc = "Your fists shine like glass. Every hit lands twice." }),
	f({ id = "GreatZambini", kind = "stim", name = "THE GREAT ZAMBINI", rarity = 5, color = C(170, 80, 240), dmg = 7.05, knock = 0.45,
		desc = "A magician's hands. Now you see them, now they hurt." }),
	f({ id = "LastShow", kind = "stim", name = "THE LAST SHOW", rarity = 6, color = C(255, 40, 70), dmg = 9.65, knock = 1.05,
		desc = "The lights go down. The crowd goes quiet. You go on." }),
	-- body forms
	f({ id = "CandyHeart", kind = "potion", name = "CANDY HEART", rarity = 1, color = C(255, 140, 200), hp = 1.4, sta = 0.08,
		desc = "Sweet and sticky, and it keeps you going." }),
	f({ id = "SpringStep", kind = "potion", name = "SPRING STEP", rarity = 1, color = C(150, 230, 200), hp = 1.1, sta = 0.18,
		desc = "There's a bounce in your step now." }),
	f({ id = "StiltWalker", kind = "potion", name = "STILT WALKER", rarity = 2, color = C(200, 170, 120), hp = 1.85, sta = 0.1,
		desc = "You feel tall. Ghosts look up at you." }),
	f({ id = "Acrobat", kind = "potion", name = "ACROBAT", rarity = 2, color = C(120, 200, 255), hp = 1.45, sta = 0.34,
		desc = "You could run the high wire all night." }),
	f({ id = "IronBelly", kind = "potion", name = "IRON BELLY", rarity = 3, color = C(150, 150, 165), hp = 2.4, sta = 0.2,
		desc = "Punch me in the stomach. Go on." }),
	f({ id = "Trapeze", kind = "potion", name = "TRAPEZE", rarity = 3, color = C(240, 200, 90), hp = 1.85, sta = 0.52,
		desc = "You never touch the ground for long." }),
	f({ id = "StrongmanBody", kind = "potion", name = "STRONGMAN", rarity = 4, color = C(210, 120, 80), hp = 3.15, sta = 0.3,
		desc = "Big arms, big chest, big moustache (optional)." }),
	f({ id = "HumanCannon", kind = "potion", name = "HUMAN CANNONBALL", rarity = 4, color = C(230, 60, 50), hp = 2.45, sta = 0.78,
		desc = "Fired across the tent and still standing." }),
	f({ id = "FortuneFavour", kind = "potion", name = "FORTUNE'S FAVOUR", rarity = 5, color = C(190, 100, 255), hp = 4.45, sta = 0.56,
		desc = "The cards say you live. The cards are never wrong." }),
	f({ id = "FireEater", kind = "potion", name = "FIRE EATER", rarity = 5, color = C(255, 110, 30), hp = 3.5, sta = 0.82,
		desc = "Hot breath, hot blood, no stopping." }),
	f({ id = "Encore", kind = "potion", name = "ENCORE", rarity = 6, color = C(255, 215, 90), hp = 6.2, sta = 0.98,
		desc = "Whatever happens, you come back for one more." }),
} do table.insert(List, x) end
-- BLACKWATER HARBOR (map 3): stronger again at every rarity
SET = "Harbor"
for _, x in {
	-- fist forms
	f({ id = "SaltKnuckles", kind = "stim", name = "SALT KNUCKLES", rarity = 1, color = C(220, 230, 235), dmg = 6.95, knock = 0.14,
		desc = "Sea salt crusts over your knuckles. It stings them, not you." }),
	f({ id = "Barnacle", kind = "stim", name = "BARNACLE FISTS", rarity = 1, color = C(150, 140, 120), dmg = 5.4, knock = 0.24,
		desc = "Shells grow over your hands. Hard as rock." }),
	f({ id = "Harpoon", kind = "stim", name = "HARPOON", rarity = 2, color = C(170, 190, 200), dmg = 8.35, knock = 0.18,
		desc = "Every punch goes straight through, like a barbed spear." }),
	f({ id = "RiptideFists", kind = "stim", name = "RIPTIDE", rarity = 2, color = C(60, 160, 200), dmg = 6.55, knock = 0.46,
		desc = "Your hits pull them under and throw them out." }),
	f({ id = "Anchorhand", kind = "stim", name = "ANCHORHAND", rarity = 3, color = C(90, 96, 110), dmg = 10, knock = 0.34,
		desc = "Your fists weigh a ton. They drop like anchors." }),
	f({ id = "Stormfist", kind = "stim", name = "STORMFIST", rarity = 3, color = C(120, 170, 255), dmg = 7.95, knock = 0.75,
		desc = "Thunder rolls every time you swing." }),
	f({ id = "KrakenGrip", kind = "stim", name = "KRAKEN GRIP", rarity = 4, color = C(130, 60, 160), dmg = 12.5, knock = 0.5,
		desc = "Your arms feel like they have more than one elbow." }),
	f({ id = "Tidebreaker", kind = "stim", name = "TIDEBREAKER", rarity = 4, color = C(40, 120, 220), dmg = 9.9, knock = 1.1,
		desc = "You punch the sea back where it came from." }),
	f({ id = "LighthouseFist", kind = "stim", name = "LIGHTHOUSE FISTS", rarity = 5, color = C(255, 236, 150), dmg = 13.5, knock = 0.85,
		desc = "Your fists burn like the lamp at the top of the tower." }),
	f({ id = "DeepFists", kind = "stim", name = "FISTS OF THE DEEP", rarity = 5, color = C(30, 200, 180), dmg = 17, knock = 0.6,
		desc = "Cold, dark and heavy. Things down there don't feel pain." }),
	f({ id = "DrownedKing", kind = "stim", name = "THE DROWNED KING", rarity = 6, color = C(40, 255, 200), dmg = 23, knock = 1.4,
		desc = "The sea gave you its crown. It wants something back." }),
	-- body forms
	f({ id = "SeaLegs", kind = "potion", name = "SEA LEGS", rarity = 1, color = C(110, 180, 220), hp = 3.25, sta = 0.12,
		desc = "Nothing knocks you over. Not even a wave." }),
	f({ id = "Brine", kind = "potion", name = "BRINE BLOOD", rarity = 1, color = C(160, 200, 170), hp = 2.55, sta = 0.26,
		desc = "Salt water in your veins. You never get tired." }),
	f({ id = "Oilskin", kind = "potion", name = "OILSKIN", rarity = 2, color = C(220, 190, 60), hp = 4.05, sta = 0.14,
		desc = "The rain runs off you. So do the claws." }),
	f({ id = "Gills", kind = "potion", name = "GILLS", rarity = 2, color = C(80, 200, 170), hp = 3.15, sta = 0.48,
		desc = "You breathe easier than ever. Don't look at your neck." }),
	f({ id = "Ironclad", kind = "potion", name = "IRONCLAD", rarity = 3, color = C(130, 140, 150), hp = 5, sta = 0.28,
		desc = "Plated like an old warship." }),
	f({ id = "Galeforce", kind = "potion", name = "GALEFORCE", rarity = 3, color = C(180, 220, 255), hp = 3.9, sta = 0.74,
		desc = "You move like the wind off the sea." }),
	f({ id = "Leviathan", kind = "potion", name = "LEVIATHAN", rarity = 4, color = C(40, 110, 140), hp = 6.35, sta = 0.42,
		desc = "Huge, slow to anger, impossible to sink." }),
	f({ id = "StormRider", kind = "potion", name = "STORM RIDER", rarity = 4, color = C(150, 120, 255), hp = 4.95, sta = 1.1,
		desc = "The storm carries you. It never sets you down." }),
	f({ id = "Lighthouse", kind = "potion", name = "THE LIGHTHOUSE", rarity = 5, color = C(255, 230, 140), hp = 8.7, sta = 0.8,
		desc = "A light inside you that the dark can't put out." }),
	f({ id = "Undertow", kind = "potion", name = "UNDERTOW", rarity = 5, color = C(20, 160, 170), hp = 6.8, sta = 1.15,
		desc = "Whatever pulls at you, you pull back harder." }),
	f({ id = "BlackTide", kind = "potion", name = "THE BLACK TIDE", rarity = 6, color = C(60, 255, 220), hp = 12, sta = 1.4,
		desc = "The harbor's whole black sea, in one body." }),
} do table.insert(List, x) end

-- THE ASHEN ABBEY (map 4): stronger again at every rarity
SET = "Abbey"
for _, x in {
	f({ id = "AshKnuckles", kind = "stim", name = "ASH KNUCKLES", rarity = 1, color = C(170, 160, 150), dmg = 14, knock = 0.19,
		desc = "Grey ash cakes your knuckles. It's still warm." }),
	f({ id = "RosaryFists", kind = "stim", name = "ROSARY FISTS", rarity = 1, color = C(200, 180, 120), dmg = 10.5, knock = 0.32,
		desc = "Beads wound round your hands. They click when you punch." }),
	f({ id = "IronPenance", kind = "stim", name = "IRON PENANCE", rarity = 2, color = C(110, 110, 120), dmg = 16.5, knock = 0.24,
		desc = "A spiked iron band round each wrist. It hurts them more than you." }),
	f({ id = "BellClapper", kind = "stim", name = "BELL CLAPPER", rarity = 2, color = C(210, 160, 70), dmg = 13, knock = 0.62,
		desc = "Every punch rings out like the great bell." }),
	f({ id = "GraveDirt", kind = "stim", name = "GRAVE DIRT", rarity = 3, color = C(110, 90, 70), dmg = 20, knock = 0.45,
		desc = "Black earth under your nails, from somewhere very deep." }),
	f({ id = "Gargoyle", kind = "stim", name = "GARGOYLE", rarity = 3, color = C(140, 140, 150), dmg = 15.5, knock = 1.0,
		desc = "Your fists turn to stone and drop like gargoyles off a roof." }),
	f({ id = "Hellforged", kind = "stim", name = "HELLFORGED", rarity = 4, color = C(255, 110, 40), dmg = 24.5, knock = 0.68,
		desc = "Your arms glow like iron in a forge." }),
	f({ id = "Exorcist", kind = "stim", name = "THE EXORCIST", rarity = 4, color = C(240, 240, 255), dmg = 19, knock = 1.45,
		desc = "Whatever you hit leaves the room. Fast." }),
	f({ id = "SaintsWrath", kind = "stim", name = "SAINT'S WRATH", rarity = 5, color = C(255, 230, 150), dmg = 25.5, knock = 1.15,
		desc = "Holy fire to the elbow. The ghosts scream before you hit them." }),
	f({ id = "Brimstone", kind = "stim", name = "BRIMSTONE", rarity = 5, color = C(255, 70, 30), dmg = 32.5, knock = 0.82,
		desc = "Smoke pours off your fists. It smells of the pit." }),
	f({ id = "TheFallen", kind = "stim", name = "THE FALLEN", rarity = 6, color = C(255, 40, 30), dmg = 43.5, knock = 1.9,
		desc = "Black wings of ash open from your arms when you swing." }),
	f({ id = "BlessedWater", kind = "potion", name = "BLESSED WATER", rarity = 1, color = C(170, 210, 255), hp = 5.65, sta = 0.16,
		desc = "Cold and clean. The ghosts don't like how you smell now." }),
	f({ id = "Vespers", kind = "potion", name = "VESPERS", rarity = 1, color = C(200, 170, 230), hp = 4.4, sta = 0.35,
		desc = "You could pray all night. You could run all night." }),
	f({ id = "Chainmail", kind = "potion", name = "CHAINMAIL", rarity = 2, color = C(150, 155, 165), hp = 6.85, sta = 0.2,
		desc = "Your skin feels like a coat of rings." }),
	f({ id = "Pilgrim", kind = "potion", name = "PILGRIM", rarity = 2, color = C(190, 160, 110), hp = 5.35, sta = 0.64,
		desc = "A thousand miles on foot, and still not tired." }),
	f({ id = "RelicBones", kind = "potion", name = "RELIC BONES", rarity = 3, color = C(230, 220, 190), hp = 8.35, sta = 0.38,
		desc = "Your bones go hard as a saint's in a glass box." }),
	f({ id = "ChoirLungs", kind = "potion", name = "CHOIR LUNGS", rarity = 3, color = C(170, 200, 255), hp = 6.55, sta = 0.98,
		desc = "One breath holds a whole hymn." }),
	f({ id = "StoneSaint", kind = "potion", name = "STONE SAINT", rarity = 4, color = C(160, 160, 170), hp = 10.5, sta = 0.56,
		desc = "Like the statues in the nave. Nothing moves you." }),
	f({ id = "Hellrunner", kind = "potion", name = "HELLRUNNER", rarity = 4, color = C(255, 90, 40), hp = 8.2, sta = 1.48,
		desc = "Run through fire. Keep running." }),
	f({ id = "Martyr", kind = "potion", name = "MARTYR", rarity = 5, color = C(255, 220, 160), hp = 14, sta = 1.08,
		desc = "They can hurt you. They can't stop you." }),
	f({ id = "Ashborn", kind = "potion", name = "ASHBORN", rarity = 5, color = C(200, 100, 60), hp = 11, sta = 1.55,
		desc = "Burned down, and you got back up out of the ash." }),
	f({ id = "Archangel", kind = "potion", name = "THE ARCHANGEL", rarity = 6, color = C(255, 245, 210), hp = 19, sta = 1.88,
		desc = "White wings of light, and eyes like the sun." }),
} do table.insert(List, x) end
-- THE BLACK MOON (map 5): the strongest forms
SET = "Moon"
for _, x in {
	f({ id = "MoonDust", kind = "stim", name = "MOON DUST", rarity = 1, color = C(190, 190, 200), dmg = 24.5, knock = 0.25,
		desc = "Grey dust that never quite settles. Neither do they." }),
	f({ id = "ZeroG", kind = "stim", name = "ZERO-G", rarity = 1, color = C(150, 200, 255), dmg = 19, knock = 0.42,
		desc = "Whatever you hit floats away." }),
	f({ id = "Titanium", kind = "stim", name = "TITANIUM", rarity = 2, color = C(170, 180, 195), dmg = 29.5, knock = 0.31,
		desc = "Light, cold and harder than anything on Earth." }),
	f({ id = "Thruster", kind = "stim", name = "THRUSTER", rarity = 2, color = C(120, 190, 255), dmg = 23, knock = 0.81,
		desc = "A little rocket in each punch." }),
	f({ id = "PlasmaFists", kind = "stim", name = "PLASMA FISTS", rarity = 3, color = C(90, 220, 255), dmg = 35, knock = 0.59,
		desc = "Blue fire with no smoke." }),
	f({ id = "GravityWell", kind = "stim", name = "GRAVITY WELL", rarity = 3, color = C(140, 100, 230), dmg = 27.5, knock = 1.3,
		desc = "Things fall toward your fists. Then away. Hard." }),
	f({ id = "Supernova", kind = "stim", name = "SUPERNOVA", rarity = 4, color = C(255, 200, 90), dmg = 43.5, knock = 0.88,
		desc = "A star going out in every swing." }),
	f({ id = "Railgun", kind = "stim", name = "RAILGUN", rarity = 4, color = C(120, 255, 220), dmg = 33.5, knock = 1.88,
		desc = "They're through the wall before the sound arrives." }),
	f({ id = "EventHorizon", kind = "stim", name = "EVENT HORIZON", rarity = 5, color = C(180, 120, 255), dmg = 44.5, knock = 1.5,
		desc = "Light bends round your knuckles." }),
	f({ id = "DarkMatter", kind = "stim", name = "DARK MATTER", rarity = 5, color = C(70, 50, 120), dmg = 57, knock = 1.07,
		desc = "You can't see it. They can feel it." }),
	f({ id = "BlackMoonFist", kind = "stim", name = "THE BLACK MOON", rarity = 6, color = C(200, 160, 255), dmg = 76, knock = 2.47,
		desc = "Your fists go dark and cold, and the stars go out behind them." }),
	f({ id = "Oxygen", kind = "potion", name = "OXYGEN", rarity = 1, color = C(200, 240, 255), hp = 9, sta = 0.21,
		desc = "Fresh air, bottled. You breathe easy." }),
	f({ id = "Starlight", kind = "potion", name = "STARLIGHT", rarity = 1, color = C(255, 245, 200), hp = 7, sta = 0.46,
		desc = "A faint glow under your skin. It keeps you going." }),
	f({ id = "Spacesuit", kind = "potion", name = "SPACESUIT", rarity = 2, color = C(230, 230, 235), hp = 11, sta = 0.26,
		desc = "Padded, sealed, hard to puncture." }),
	f({ id = "Orbit", kind = "potion", name = "ORBIT", rarity = 2, color = C(120, 170, 255), hp = 8.45, sta = 0.83,
		desc = "Round and round, and you never slow down." }),
	f({ id = "Crater", kind = "potion", name = "CRATER", rarity = 3, color = C(150, 140, 130), hp = 13, sta = 0.49,
		desc = "You take the hit like the moon takes a meteor." }),
	f({ id = "Comet", kind = "potion", name = "COMET", rarity = 3, color = C(150, 230, 255), hp = 10, sta = 1.27,
		desc = "A long bright tail behind you when you run." }),
	f({ id = "Asteroid", kind = "potion", name = "ASTEROID", rarity = 4, color = C(120, 110, 100), hp = 16.5, sta = 0.73,
		desc = "A lump of iron and rock that won't stop." }),
	f({ id = "SolarWind", kind = "potion", name = "SOLAR WIND", rarity = 4, color = C(255, 210, 120), hp = 12.5, sta = 1.92,
		desc = "It blows you along faster than anything can follow." }),
	f({ id = "Nebula", kind = "potion", name = "NEBULA", rarity = 5, color = C(220, 120, 255), hp = 21.5, sta = 1.4,
		desc = "A whole cloud of stars being born in you." }),
	f({ id = "Pulsar", kind = "potion", name = "PULSAR", rarity = 5, color = C(120, 220, 255), hp = 17, sta = 2.0,
		desc = "Your heart beats like a dead star: fast and forever." }),
	f({ id = "TheVoid", kind = "potion", name = "THE VOID", rarity = 6, color = C(160, 120, 255), hp = 29, sta = 2.44,
		desc = "Nothing can hurt nothing." }),
} do table.insert(List, x) end

-- EXCLUSIVE FORMS: in no jar and no potion; only a CODE gives one (Server/Codes, the lobby's CODES button). Each has
-- its own look (Client/FormExclusive) on top of its rarity's, shows as EXCLUSIVE (Forms.rarityOf) and can't be traded.
SET = "Exclusive"
for _, x in {
	-- code ALPHA TESTER (2026-11-22, the user): a fist form with the Camp LEGENDARY jar's buff (BANSHEE FISTS: +150% /
	-- +35%) and a body form with the Camp LEGENDARY potion's (UNDYING: +150% / +40%); a holographic glitch look (red /
	-- cyan split images, pixels, scan lines, the colour drifting: Client/FormExclusive)
	f({ id = "AlphaGlitch", kind = "stim", name = "ALPHA GLITCH", rarity = 5, exclusive = true, color = C(70, 235, 255), color2 = C(255, 60, 210),
		dmg = 1.5, knock = 0.35, desc = "For the ones who played before the game was finished. Some of its bugs came with you." }),
	f({ id = "AlphaHolo", kind = "potion", name = "ALPHA HOLOGRAM", rarity = 5, exclusive = true, color = C(170, 110, 255), color2 = C(70, 235, 255),
		hp = 1.5, sta = 0.4, desc = "Half of you isn't really there. The ghosts keep hitting that half." }),
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
	-- THE ASHEN ABBEY (open once Blackwater Harbor is cleared)
	V("Abbey", 1, { id = "AshEcto", kind = "stim", name = "ASH GOO", level = 23, price = 90, color = C(190, 170, 150), desc = "Scraped off the cloister floor. It glows like an ember." }),
	V("Abbey", 2, { id = "RelicEcto", kind = "stim", name = "RELIC GOO", level = 24, price = 200, color = C(230, 200, 120), desc = "Out of a saint's reliquary. Don't tell the abbot." }),
	V("Abbey", 3, { id = "BellEcto", kind = "stim", name = "BELL GOO", level = 26, price = 400, color = C(210, 150, 60), desc = "From inside the great bell. It still hums." }),
	V("Abbey", 4, { id = "HellEcto", kind = "stim", name = "HELLFIRE GOO", level = 28, price = 800, color = C(255, 70, 30), desc = "From the crack in the nave. It's hot to the touch." }),
	V("Abbey", 1, { id = "CandlePotion", kind = "potion", name = "CANDLE POTION", level = 23, price = 90, color = C(255, 220, 150), desc = "Wax, smoke and a whispered prayer." }),
	V("Abbey", 2, { id = "ChoirPotion", kind = "potion", name = "CHOIR POTION", level = 24, price = 200, color = C(180, 200, 255), desc = "It sings quietly in the bottle." }),
	V("Abbey", 3, { id = "CryptPotion", kind = "potion", name = "CRYPT POTION", level = 26, price = 400, color = C(140, 170, 120), desc = "Brewed from the dust of old tombs." }),
	V("Abbey", 4, { id = "AngelPotion", kind = "potion", name = "ARCHANGEL BREW", level = 28, price = 800, color = C(255, 245, 210), desc = "A single white feather floats in it." }),
	-- THE BLACK MOON (open once the Ashen Abbey is cleared)
	V("Moon", 1, { id = "DustEcto", kind = "stim", name = "MOON DUST GOO", level = 29, price = 200, color = C(200, 200, 210), desc = "Scooped off the base's windows. It floats a little." }),
	V("Moon", 2, { id = "LabEcto", kind = "stim", name = "LAB GOO", level = 30, price = 450, color = C(140, 255, 120), desc = "Out of a broken specimen tank. It twitches." }),
	V("Moon", 3, { id = "ReactorEcto", kind = "stim", name = "REACTOR GOO", level = 32, price = 900, color = C(90, 220, 255), desc = "It glows blue and makes your teeth buzz." }),
	V("Moon", 4, { id = "VoidEcto", kind = "stim", name = "VOID GOO", level = 34, price = 1800, color = C(170, 110, 255), desc = "From the other side of the black gate." }),
	V("Moon", 1, { id = "OxygenPotion", kind = "potion", name = "OXYGEN POTION", level = 29, price = 200, color = C(200, 240, 255), desc = "Bubbles that never pop." }),
	V("Moon", 2, { id = "StardustPotion", kind = "potion", name = "STARDUST POTION", level = 30, price = 450, color = C(255, 240, 180), desc = "Swept up off the observation deck." }),
	V("Moon", 3, { id = "CometPotion", kind = "potion", name = "COMET POTION", level = 32, price = 900, color = C(150, 230, 255), desc = "It leaves a bright trail when you shake it." }),
	V("Moon", 4, { id = "BlackMoonPotion", kind = "potion", name = "BLACK MOON BREW", level = 34, price = 1800, color = C(200, 160, 255), desc = "Dark as the far side, and just as cold." }),
}
-- the sets in order (the campaign maps that have one)
local SETS = { "Camp", "Carnival", "Harbor", "Abbey", "Moon" }

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

-- the rarity line of a form: its rarity, or EXCLUSIVE (a code's form)
local EXCLUSIVE = { name = "EXCLUSIVE", color = C(70, 235, 255) }
function Forms.rarityOf(fm: Form): { name: string, color: Color3 }
	if fm.exclusive then return EXCLUSIVE end
	return RARITY[fm.rarity]
end

-- the exclusive forms of a kind (none is in a jar / potion)
function Forms.exclusives(kind: string): { Form }
	local out = {}
	for _, x in List do if x.exclusive and x.kind == kind then table.insert(out, x) end end
	return out
end

-- a bonus as text: "+12%" below double, then a multiplier: "x2.5", "x58"
function Forms.bonusText(n: number?): string
	local b = n or 0
	if b < 1 then return "+" .. math.floor(b * 100 + 0.5) .. "%" end
	local m = 1 + b
	if m >= 10 then return "x" .. math.floor(m + 0.5) end
	local t = string.format("%.1f", m)
	return "x" .. (string.gsub(t, "%.0$", ""))
end

-- the lines shown for a form: { "+12% PUNCH DAMAGE", "x58 MAX HEALTH", ... }
function Forms.lines(fm: Form): { string }
	local out = {}
	local pct = Forms.bonusText
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
