--!strict
-- Sound ids (free Creator Store audio). Several ids = pick one at random.
return {
	PunchLight = { ids = { 9113565276 }, volume = 0.9 },
	PunchHeavy = { ids = { 118091370487168 }, volume = 1 },
	Whoosh = { ids = { 111254855668531 }, volume = 0.5 },
	-- the Void Knight's blade (Roblox's licensed "Pro Sound Effects" library): a constant buzzing low synth tone is
	-- its hum (looped on the blade; its pitch bends on every swing, Client/MonsterFx), a deep airy swish on top
	SaberHum = { ids = { 9119852202 }, volume = 0.55 },
	SaberSwish = { ids = { 9120733055 }, volume = 1 },
	-- the Void Knight's breathing through his mask (a slow bag breath, slowed and muffled: Client/Entrance,
	-- Client/MonsterFx) and the blade burning through a wall (his entrance). Pro Sound Effects library.
	KnightBreath = { ids = { 9113073910 }, volume = 1 }, -- Air Regulator Scuba Tank 2 (Pro Sound Effects): a breath through a scuba regulator, cut into inhale + exhale by Client/MaskBreath
	SaberBurn = { ids = { 9119992534 }, volume = 0.8 },
	WoodBreak = { ids = { 9120801590, 9120957493 }, volume = 1 },
	-- the intro (Client/Intro): the old TV, the front door, the storm (Pro Sound Effects)
	TvStatic = { ids = { 9126097291 }, volume = 0.5 },
	TvHum = { ids = { 9114245635 }, volume = 0.3 },
	DoorCreak = { ids = { 9120838740 }, volume = 1 },
	Thunder = { ids = { 9120018172 }, volume = 0.9 },
	-- the night train that brings the player to the park at the intro's end (Client/Intro; Pro Sound Effects)
	TrainWhistle = { ids = { 9119627875 }, volume = 1 }, -- Steam Train Whistle Single Blows Airy 1
	TrainRoll = { ids = { 9114301354 }, volume = 0.8 }, -- Elevated Subway Train 1 (the rumble on the rails)
	TrainSteam = { ids = { 9120252795 }, volume = 0.9 }, -- Train Steam 1
	TrainClank = { ids = { 9114534119 }, volume = 0.8 }, -- Freight Train Couple 1
	TrainDoor = { ids = { 9116495722 }, volume = 0.7 }, -- Medium Pressure Air Release 2
	Glass = { ids = { 9114592102 }, volume = 0.8 },
	GhostScream = { ids = { 9114567451, 136111643195187 }, volume = 1 },
	GhostWail = { ids = { 129823359634605 }, volume = 0.7 },
	GhostWhisper = { ids = { 9114228691 }, volume = 0.6 },
	GhostHurt = { ids = { 93232280469148, 9114397739 }, volume = 0.7 },
	GhostDeath = { ids = { 6820337405 }, volume = 1 },
	Jumpscare = { ids = { 139162107746216 }, volume = 1 },
	Ambience = { ids = { 96727522170625 }, volume = 0.45 },
	FightMusic = { ids = { 110184030258486 }, volume = 1.1 }, -- the fallback (a monster with no track of its own)
	-- FIGHT MUSIC: one track per monster and one per evolved form (Music_<MonsterId> / Music_<MonsterId>_E), started
	-- by that monster's entrance (Client/Fx setMusic). All from the Creator Store's licensed library (APM Music);
	-- to change one, put another audio id here (at least 1:30 long: a short one loops too often in a fight; the tracks
	-- under 1:30 were replaced on 2026-11-19). Volume 1.6: these recordings are much quieter than the sound effects
	-- (at 0.5 the fight drowned them out); the MUSIC slider in the settings still scales them.
	-- ROCK (2026-11-21, the user: "5 music (rock prefered) that get progressively louder and louder for each monster of
	-- the map"): every campaign building has a rock / metal track, each map going from its lightest on the first building
	-- to its heaviest on the boss, and louder too (volume 1.3 on building 1 .. 1.7 on the boss, 1.8 for its phase 2). All
	-- licensed APM albums (Fuzz Machine, Epic Metal, Speed Metal, Death Metal, Nu Metal, Cezame Action Sport Metal), picked
	-- by album / genre / title: nobody had listened to them in the game yet. The endless-only forms (Music_Woman / _E,
	-- Music_Rat_E, Music_Knight_E, Music_Titan_E) kept theirs.
	Music_Woman = { ids = { 94597327890629 }, volume = 1.6 }, -- Ghost Stalker
	Music_Woman_E = { ids = { 109753218180637 }, volume = 1.6 }, -- Wailing Walls (the Violet Widow)
	Music_Demon = { ids = { 1837318958 }, volume = 1.7 }, -- Divine Curse, Death Metal (death metal, 2:05) - Abbey 5
	Music_Demon_E = { ids = { 1837318773 }, volume = 1.8 }, -- Soldier of Death, Death Metal (death metal, 4:18) - Abbey 5, phase 2
	Music_Pirate = { ids = { 1837247052 }, volume = 1.7 }, -- Sword and Shield, Epic Metal (epic metal, 2:49) - Harbor 5
	Music_Pirate_E = { ids = { 1837247400 }, volume = 1.8 }, -- The Speed of Light, Speed Metal (speed metal, 3:25) - Harbor 5, phase 2
	Music_Animatronic = { ids = { 1837247094 }, volume = 1.7 }, -- Machine Gun Toy, Epic Metal (epic metal, 4:10) - Carnival 6
	Music_Animatronic_E = { ids = { 1837247692 }, volume = 1.8 }, -- Chain Reaction, Speed Metal (speed metal, 3:38) - Carnival 6, phase 2
	Music_Titan = { ids = { 1837318812 }, volume = 1.6 }, -- Repulsion, Death Metal (death metal, 3:05) - Abbey 4
	-- Camp Hollowmere's monsters (licensed production music)
	Music_Antlered = { ids = { 1845844557 }, volume = 1.3 }, -- Avalanche Addict A, Fuzz Machine (classic / stoner rock, 1:54) - Camp 1
	Music_LakeWitch = { ids = { 1845844667 }, volume = 1.4 }, -- Breaking Bones A, Fuzz Machine (gothic rock, 2:12) - Camp 2
	Music_Counselor = { ids = { 1845844753 }, volume = 1.5 }, -- Deep Earth Grinder A, Fuzz Machine (heavy metal, 2:08) - Camp 3
	Music_Scarecrow = { ids = { 9038254416 }, volume = 1.6 }, -- Fight Hard or Die, Cezame Metal Factory (metal, 3:34) - Camp 4
	Music_Clown = { ids = { 1837246882 }, volume = 1.5 }, -- Dysteria, Epic Metal (epic metal, 3:51) - Carnival 4
	Music_Strongman = { ids = { 1837246678 }, volume = 1.45 }, -- Fighting Heart, Epic Metal (epic metal, 3:11) - Carnival 3
	Music_Fortune = { ids = { 1837247811 }, volume = 1.35 }, -- Lucid Dream, Nu Metal (nu metal, 4:22) - Carnival 2
	Music_Ringmaster = { ids = { 1845844372 }, volume = 1.3 }, -- Dark Circus A, Fuzz Machine (heavy metal, 2:21) - Carnival 1
	Music_Titan_E = { ids = { 9039352746 }, volume = 1.6 }, -- The Fall of the Titans
	-- Blackwater Harbor
	Music_DeepOne = { ids = { 1845844491 }, volume = 1.3 }, -- Ominous Doom A, Fuzz Machine (doom metal, 2:08) - Harbor 1
	Music_Keeper = { ids = { 1837247131 }, volume = 1.5 }, -- Down in the Maelstrom, Epic Metal (epic metal, 2:47) - Harbor 3
	Music_Netman = { ids = { 9038254566 }, volume = 1.6 }, -- Metal Storm Breaks, Cezame Metal Factory (metal, 3:16) - Harbor 4
	-- MONSTER VOICES (Client/Sfx VOICES): each monster since Camp Hollowmere has its own (Pro Sound Effects; speed = its pitch)
	V_Antlered_Spawn = { ids = { 9120048117 }, volume = 1.4, speed = 0.75 },
	V_Antlered_WindUp = { ids = { 9113630346 }, volume = 1.3, speed = 0.8 },
	V_Antlered_Claw = { ids = { 9113629973 }, volume = 1.1 },
	V_Antlered_Hurt = { ids = { 9116298078 }, volume = 1.2, speed = 0.85 },
	V_Antlered_Death = { ids = { 9116308659 }, volume = 1.4, speed = 0.7 },
	V_LakeWitch_Spawn = { ids = { 9113985970 }, volume = 1.2, speed = 0.8 },
	V_LakeWitch_WindUp = { ids = { 9113991846 }, volume = 1.2, speed = 0.8 },
	V_LakeWitch_Claw = { ids = { 9113985848 }, volume = 1 },
	V_LakeWitch_Hurt = { ids = { 9113985971 }, volume = 1.1 },
	V_LakeWitch_Death = { ids = { 9113986097 }, volume = 1.3, speed = 0.75 },
	V_Counselor_Spawn = { ids = { 9125652443 }, volume = 1.3, speed = 0.85 },
	V_Counselor_WindUp = { ids = { 9114029889 }, volume = 1.2, speed = 0.9 },
	V_Counselor_Claw = { ids = { 9125652949 }, volume = 1 },
	V_Counselor_Hurt = { ids = { 9125651373 }, volume = 1.1 },
	V_Counselor_Death = { ids = { 9125652666 }, volume = 1.3, speed = 0.8 },
	V_Scarecrow_Spawn = { ids = { 9125476001 }, volume = 1.3, speed = 0.8 },
	V_Scarecrow_WindUp = { ids = { 9118066001 }, volume = 1.1, speed = 0.9 },
	V_Scarecrow_Claw = { ids = { 9118066003 }, volume = 1 },
	V_Scarecrow_Hurt = { ids = { 9113989720 }, volume = 1.2, speed = 0.9 },
	V_Scarecrow_Death = { ids = { 9113989909 }, volume = 1.3, speed = 0.7 },
	V_Clown_Spawn = { ids = { 9116239333 }, volume = 1.2, speed = 1.25 },
	V_Clown_WindUp = { ids = { 9116452494 }, volume = 1.1, speed = 1.2 },
	V_Clown_Claw = { ids = { 9120415601 }, volume = 0.9 },
	V_Clown_Hurt = { ids = { 9116452672 }, volume = 1.1, speed = 1.3 },
	V_Clown_Death = { ids = { 9116239157 }, volume = 1.3, speed = 0.6 },
	V_Strongman_Spawn = { ids = { 9114628818 }, volume = 1.4 },
	V_Strongman_WindUp = { ids = { 9114628321 }, volume = 1.3 },
	V_Strongman_Claw = { ids = { 9114627550 }, volume = 1.1 },
	V_Strongman_Hurt = { ids = { 9116308567 }, volume = 1.2, speed = 0.9 },
	V_Strongman_Death = { ids = { 9114630281 }, volume = 1.4, speed = 0.8 },
	V_Fortune_Spawn = { ids = { 9113986096 }, volume = 1.2, speed = 1.1 },
	V_Fortune_WindUp = { ids = { 9114397934 }, volume = 1.1, speed = 0.7 },
	V_Fortune_Claw = { ids = { 9114398138 }, volume = 1, speed = 0.8 },
	V_Fortune_Hurt = { ids = { 9113986330 }, volume = 1.1 },
	V_Fortune_Death = { ids = { 9113985837 }, volume = 1.3, speed = 0.7 },
	V_Ringmaster_Spawn = { ids = { 9116239118 }, volume = 1.2 },
	V_Ringmaster_WindUp = { ids = { 9116239130 }, volume = 1.1 },
	V_Ringmaster_Claw = { ids = { 9116239313 }, volume = 1 },
	V_Ringmaster_Hurt = { ids = { 9118910037 }, volume = 1.1 },
	V_Ringmaster_Death = { ids = { 9125652963 }, volume = 1.3, speed = 0.7 },
	V_DeepOne_Spawn = { ids = { 9113987603 }, volume = 1.4, speed = 1.1 },
	V_DeepOne_WindUp = { ids = { 9125558386 }, volume = 1.3, speed = 0.8 },
	V_DeepOne_Claw = { ids = { 9113980480 }, volume = 1.1 },
	V_DeepOne_Hurt = { ids = { 9113980319 }, volume = 1.2, speed = 1.2 },
	V_DeepOne_Death = { ids = { 9113980512 }, volume = 1.4, speed = 0.8 },
	V_Keeper_Spawn = { ids = { 9125652139 }, volume = 1.3, speed = 0.6 },
	V_Keeper_WindUp = { ids = { 9114029789 }, volume = 1.2, speed = 0.8 },
	V_Keeper_Claw = { ids = { 9114624345 }, volume = 1.1, speed = 0.6 },
	V_Keeper_Hurt = { ids = { 9125651115 }, volume = 1.2, speed = 0.7 },
	V_Keeper_Death = { ids = { 9114029889 }, volume = 1.3, speed = 0.6 },
	V_Netman_Spawn = { ids = { 9114629612 }, volume = 1.4, speed = 0.85 },
	V_Netman_WindUp = { ids = { 9120789029 }, volume = 1.2, speed = 0.6 },
	V_Netman_Claw = { ids = { 9114628357 }, volume = 1.1 },
	V_Netman_Hurt = { ids = { 9114628598 }, volume = 1.2 },
	V_Netman_Death = { ids = { 9114628113 }, volume = 1.4, speed = 0.7 },
	-- THE ASHEN ABBEY + THE BLACK MOON (2026-11-19): MUSIC (licensed production library, instrumental, all checked: load OK; backup id in the comment)
	Music_Nun = { ids = { 1837247756 }, volume = 1.3 }, -- Lost In Eternity, Nu Metal (nu metal, 4:26) - Abbey 1
	Music_Gravedigger = { ids = { 1837247012 }, volume = 1.4 }, -- Soulbound Crypt, Epic Metal (epic metal, 4:08) - Abbey 2
	Music_Ringer = { ids = { 1837246729 }, volume = 1.5 }, -- Occult Forces, Epic Metal (epic metal, 3:25) - Abbey 3
	Music_Astronaut = { ids = { 1837247825 }, volume = 1.3 }, -- Exoplanet, Nu Metal (nu metal, 3:45) - Moon 1
	Music_Specimen = { ids = { 1837247773 }, volume = 1.4 }, -- Black Hole, Nu Metal (nu metal, 2:17) - Moon 2
	Music_Sentinel = { ids = { 1845844255 }, volume = 1.5 }, -- Artificial Armageddon A, Fuzz Machine (industrial metal, 3:20) - Moon 3

	-- MONSTER VOICES (Pro Sound Effects)
	V_Nun_Spawn = { ids = { 9114569607 }, volume = 1.3, speed = 0.95 }, -- Ghastly Screams 15 (4.3 s)
	V_Nun_WindUp = { ids = { 9113997021 }, volume = 1.2, speed = 0.85 }, -- Cries Whimpers 20 (2.1 s, a sob)
	V_Nun_Claw = { ids = { 9118843973 }, volume = 1.1 }, -- Screams Individual Females Shrill 5 (0.6 s)
	V_Nun_Hurt = { ids = { 9113985969 }, volume = 1.2 }, -- Creature Scream Piercing Pain Female 4 (1.2 s)
	V_Nun_Death = { ids = { 9118155003 }, volume = 1.3, speed = 0.85 }, -- Reverby Shriek Long Series Tonal Screams 1 (6.3 s)
	V_Gravedigger_Spawn = { ids = { 9114038256 }, volume = 1.3, speed = 0.85 }, -- Demon Scream By Pained Screeches Wheezing 2 (4.4 s)
	V_Gravedigger_WindUp = { ids = { 9114571613 }, volume = 1.2, speed = 0.7 }, -- Ghost Giggle Breathy Creepy Possessed 10 (2.5 s; slowed = raspy chuckle)
	V_Gravedigger_Claw = { ids = { 9116451739 }, volume = 1.1, speed = 0.8 }, -- Male Grunts Two Men Fighting 3 (0.7 s, effort grunt)
	V_Gravedigger_Hurt = { ids = { 9114558163 }, volume = 1.2, speed = 0.85 }, -- Gasp Wheeze 4 (1.1 s)
	V_Gravedigger_Death = { ids = { 9114038117 }, volume = 1.3, speed = 0.8 }, -- Demon Scream By Pained Screeches Wheezing 1 (5.3 s)
	V_Ringer_Spawn = { ids = { 9114630102 }, volume = 1.4, speed = 0.8 }, -- Goliath Vocal Deep Growling Voice 43 (4.5 s)
	V_Ringer_WindUp = { ids = { 9113636490 }, volume = 1.3, speed = 0.85 }, -- Bull Monster Groan 1 (1.1 s)
	V_Ringer_Claw = { ids = { 9114627787 }, volume = 1.1, speed = 0.9 }, -- Goliath Vocal Deep Growling Voice 8 (1.2 s)
	V_Ringer_Hurt = { ids = { 9116454942 }, volume = 1.2, speed = 0.7 }, -- Male Screams In Pain Injury Yells Agony 2 (3.6 s)
	V_Ringer_Death = { ids = { 9114037509 }, volume = 1.4, speed = 0.7 }, -- Demon Scream 1 (7.5 s)
	V_Astronaut_Spawn = { ids = { 9125713501 }, volume = 1.3, speed = 0.9 }, -- Nightmare Yelling Bursts Of Distorted Scream (5.8 s)
	V_Astronaut_WindUp = { ids = { 9113073789 }, volume = 1.2, speed = 0.9 }, -- Air Regulator Scuba Tank 1 (3.0 s, helmet breath)
	V_Astronaut_Claw = { ids = { 9125833628 }, volume = 1.1 }, -- Robot Vocal Sci-Fi Tortured Vocalizations 5 (0.5 s)
	V_Astronaut_Hurt = { ids = { 9118504521 }, volume = 1.2, speed = 0.95 }, -- Robot Vocal Sci-Fi Tortured Vocalizations 3 (1.9 s)
	V_Astronaut_Death = { ids = { 9125714014 }, volume = 1.3, speed = 0.85 }, -- Nightmare Yelling Bursts Of Distorted Vocals (8.9 s)
	V_Specimen_Spawn = { ids = { 9113090127 }, volume = 1.3 }, -- Alien Creature 1 (4.0 s)
	V_Specimen_WindUp = { ids = { 9114854828 }, volume = 1.2 }, -- Hydra Wet Throaty Hissing 1 (2.5 s)
	V_Specimen_Claw = { ids = { 9125474505 }, volume = 1.1, speed = 1.1 }, -- Creature Screech Pterodactyl Vocals Screams (0.8 s)
	V_Specimen_Hurt = { ids = { 9118850866 }, volume = 1.2 }, -- Screechy Screaming Suck Swelling Shrieks 2 (2.4 s)
	V_Specimen_Death = { ids = { 9118850613 }, volume = 1.3, speed = 0.8 }, -- Screechy Screaming Suck Swelling Shrieks 1 (2.5 s)
	V_Sentinel_Spawn = { ids = { 9125849482 }, volume = 1.4, speed = 0.8 }, -- Robot Voice Aggressive Growls Snarl Breathy (4.9 s)
	V_Sentinel_WindUp = { ids = { 9118329245 }, volume = 1.2, speed = 0.9 }, -- Robot Servo 6 (2.1 s)
	V_Sentinel_Claw = { ids = { 9125823639 }, volume = 1.1 }, -- Robot Screams Intense Short Screeching Blast (2.4 s)
	V_Sentinel_Hurt = { ids = { 9118993118 }, volume = 1.2 }, -- Servo Pig Motor Burst Robot Death 1 (1.5 s)
	V_Sentinel_Death = { ids = { 9118996235 }, volume = 1.3, speed = 0.75 }, -- Servo Pig Motor Burst Robot Death 7 (3.3 s)

	-- SFX (Pro Sound Effects)
	BellToll = { ids = { 9113804189 }, volume = 1.2 }, -- Church Bell Single Hits Double At Head 3 (7.8 s) | alt 9114352428 Evil Church Bell Twisted Bent (8.2 s)
	HandBell = { ids = { 9113584742 }, volume = 1.0 }, -- Brass Hand Bell 1 (6.6 s)
	Choir = { ids = { 9113802331 }, volume = 1.1 }, -- Choral Wind Exhale Breath Eerie 2 (5.2 s) | alt 9113124268 Angel Wails 12 (4.8 s), 9125693888 Monk Vocal Sting Deep Guttural Reverberant 1 (7.2 s)
	OrganSting = { ids = { 9113036512 }, volume = 1.1 }, -- Accordion Discord Various Long Notes 1 (4.4 s; PSE has no pipe organ, this reed chord is the closest)
	ShovelDig = { ids = { 9119120449 }, volume = 1.0 }, -- Shovel Dirt 1 (2.8 s)
	BoneRattle = { ids = { 9126238383 }, volume = 1.0 }, -- Wood Clatter Drop Wood Boards Clattery (2.7 s) | alt 9119034324 Shaker Pod South American Instrument 1 (1.1 s, dry rattle)
	CoffinCreak = { ids = { 9120881074 }, volume = 1.1 }, -- Wood Groan Creak Opening Wood Chest Coffin 5 (3.0 s)
	Airlock = { ids = { 9125975959 }, volume = 1.1 }, -- Spaceship Doors Air Release Some With Suck (3.9 s)
	Jetpack = { ids = { 9120006280 }, volume = 1.0 }, -- Thruster Blast 1 (1.5 s)
	Klaxon = { ids = { 9118805665 }, volume = 0.9 }, -- Sci Fi Alarm Buzzy Whining Klaxon 2 (1.7 s)
	MissileLaunch = { ids = { 9126009951 }, volume = 1.1 }, -- Super Animal Rocket By Hissing Jet Whooshes (1.5 s) | alt 9117089697 New Super Missile Pass Bys 1 (4.9 s)
	ElectricArc = { ids = { 9114237487 }, volume = 1.0 }, -- Electric Arcing 4 (3.4 s)
	AcidSizzle = { ids = { 9119991629 }, volume = 1.0 }, -- Termite Sprays Acid Hissing Bursts 1 (2.6 s)
	AlienScreech = { ids = { 9113090147 }, volume = 1.2 }, -- Alien Creature 2 (1.9 s)
	RobotServo = { ids = { 9118329008 }, volume = 1.0 }, -- Robot Servo 1 (2.2 s)
	Music_Goblin = { ids = { 1837246932 }, volume = 1.6 }, -- Troll, Epic Metal (epic metal, 3:44) - Carnival 5
	Music_Goblin_E = { ids = { 1837246806 }, volume = 1.7 }, -- Soul Banger, Epic Metal (epic metal, 3:43) - Carnival 5, phase 2
	Music_Caller = { ids = { 9038254696 }, volume = 1.7 }, -- Get Ready for the Onslaught, Cezame Metal Factory (metalcore, 3:26) - Camp 5
	Music_Caller_E = { ids = { 9038254571 }, volume = 1.8 }, -- From Alpha to Omega, Cezame Metal Factory (heavy metal climax, 3:45) - Camp 5, phase 2
	Music_Conqueror = { ids = { 1837247591 }, volume = 1.7 }, -- Extreme Speed, Speed Metal (speed metal, 3:48) - Moon 5
	Music_Conqueror_E = { ids = { 1837318901 }, volume = 1.8 }, -- Black Plague, Death Metal (death metal, 3:30; the intro's song comes back for the last fight) - Moon 5, phase 2
	Music_Rat = { ids = { 1837246665 }, volume = 1.4 }, -- Infectious, Epic Metal (epic metal, 3:33) - Harbor 2
	Music_Rat_E = { ids = { 1837318901 }, volume = 1.6 }, -- Black Plague
	-- the intro's way out (Client/Intro): Black Plague gives way to this once she is beaten
	IntroOutro = { ids = { 9039353950 }, volume = 1.6 }, -- Strength of Will (Cezame Original Scores)
	Music_Knight = { ids = { 1837247146 }, volume = 1.6 }, -- Parallel World, Epic Metal (epic metal, 3:53) - Moon 4
	Music_Knight_E = { ids = { 80139755347360 }, volume = 1.6 }, -- Litany of Shadows (the Hollow Emperor)
	-- the Sewer Rat's voice (real rat squeals, slowed down: speed) and its digging
	RatSpawn = { ids = { 9118053340 }, volume = 1, speed = 0.55 },
	RatSqueal = { ids = { 9118055004, 9118053340 }, volume = 1, speed = 0.7 },
	RatHurt = { ids = { 9118058248, 9118057950, 9118057636 }, volume = 0.9, speed = 0.7 },
	RatDeath = { ids = { 9118053340 }, volume = 1, speed = 0.4 },
	Dig = { ids = { 9114084427 }, volume = 1 },
	-- the Golden Bear snaps his fingers (Client/MonsterFx "Snap", and his entrance)
	FingerSnap = { ids = { 9114427575 }, volume = 1 },
	Ultimate = { ids = { 1848248007 }, volume = 1 },
	PlaneEngine = { ids = { 86789153907970 }, volume = 1 },
	Explosion = { ids = { 136415610645234 }, volume = 1 },
	Crash = { ids = { 9113966908 }, volume = 1 },
	Cash = { ids = { 1319346243 }, volume = 0.8 },
	Click = { ids = { 88442833509532 }, volume = 0.6 },
	-- chainsaw (SawAudio): pull-start on select, idle loop, rev-up on trigger, cutting loop, chain biting
	SawStart = { ids = { 139992012387391 }, volume = 0.4 },
	SawIdle = { ids = { 129562586053031 }, volume = 0.18 },
	SawRevUp = { ids = { 117323411492774 }, volume = 0.25 },
	SawCut = { ids = { 115269891686710 }, volume = 0.32 },
	SawHit = { ids = { 133850299035625 }, volume = 0.35 },
	-- item sounds (Items.sfx): hit = when it connects, use = when you swing / fire
	Bonk = { ids = { 124963990860864 }, volume = 1 },
	PanHit = { ids = { 106153836670499 }, volume = 1 },
	PipeFall = { ids = { 139562015239082 }, volume = 0.8 },
	DemonSwing = { ids = { 140180249061198 }, volume = 0.7 },
	DemonHit = { ids = { 140277245983305 }, volume = 0.9 },
	NailShot = { ids = { 9117053526 }, volume = 0.8 },
	ShotgunShot = { ids = { 113543931016554 }, volume = 1 },
	ShotgunPump = { ids = { 113837896417526 }, volume = 0.8 },
	CannonShot = { ids = { 75759053218900 }, volume = 1 },
	Vacuum = { ids = { 109052160967104 }, volume = 0.55 },
	GlockShot = { ids = { 139943212269145 }, volume = 0.6 },
	GlockEquip = { ids = { 3606135620 }, volume = 0.8 }, -- leaf blower / shop vac loop
	FireLoop = { ids = { 9079463756 }, volume = 0.7 }, -- burning wood crackle
	-- the flamethrower's hiss (played pitched up, over PlaneEngine pitched down: Client/Hotbar). Its own entry so a
	-- real flamethrower recording can be dropped in here later.
	Flamethrower = { ids = { 9079463756 }, volume = 1 },
	-- the taser on a monster (Client/Fx "Tased"): the first snap, then fast pitched clicks = the crackle. Own entries
	-- so real electric recordings can be dropped in here later.
	TaserZap = { ids = { 9116617140 }, volume = 1 },
	TaserTick = { ids = { 9116617140 }, volume = 0.6 },
	DemonRoar = { ids = { 136542763428450 }, volume = 1 },
	DemonLaugh = { ids = { 6841094848 }, volume = 1 },
	Telekinesis = { ids = { 7935048120 }, volume = 0.9 },
	-- monster voices (Roblox SFX library; Sfx.voice picks the current monster's)
	DemonSpawn = { ids = { 9116299488, 9113980319 }, volume = 1 },
	DemonGrowl = { ids = { 9114628357, 9114628321 }, volume = 1 },
	DemonHurt = { ids = { 9114628818, 9113971531 }, volume = 0.9 },
	DemonDeath = { ids = { 9113985445 }, volume = 1 },
	GoblinSpawn = { ids = { 9114624343 }, volume = 1 },
	GoblinGrowl = { ids = { 9114625030, 9114624510 }, volume = 1 },
	GoblinHurt = { ids = { 9114625192, 9114624507 }, volume = 0.9 },
	GoblinDeath = { ids = { 9114624129 }, volume = 1 },
	GoblinCackle = { ids = { 9114625189 }, volume = 1 },
	PirateSpawn = { ids = { 96613418930760, 127423594846774 }, volume = 1 },
	PirateSwing = { ids = { 101266427032050 }, volume = 0.9 },
	PirateHurt = { ids = { 101736510694103, 9126253838 }, volume = 0.9 },
	PirateDeath = { ids = { 109913671094159 }, volume = 1 },
	ShieldBlock = { ids = { 9119072660, 9119072674 }, volume = 1 },
	AnimSpawn = { ids = { 9114583503 }, volume = 1 },
	AnimGrowl = { ids = { 9125842589, 9125841223 }, volume = 1 },
	AnimHurt = { ids = { 9116541944, 9118941667 }, volume = 0.9 },
	AnimDeath = { ids = { 9125861915 }, volume = 1 },
	MusicBox = { ids = { 9117043866 }, volume = 0.7 },
	Breaker = { ids = { 9116617140 }, volume = 1 },
	-- the Caller's phone (the ring itself is a Sound on the phone, Server/Caller)
	PhoneRing = { ids = { 9117304268 }, volume = 1 },
	-- FORMS (Client/FormCine, the first-person ectoplasm jar / potion; "Pro Sound Effects"): a low thump played twice
	-- is the heartbeat, a wet squish (the goo), a hiss (the jar's lid), the cork, gulps, rising power-ups, a growly
	-- magic whoosh (the potion), bone cracks and a knuckle crack (the goo), an electric burst (the reveal)
	FormThump = { ids = { 9113042060 }, volume = 1 },
	FormSquish = { ids = { 9119990452 }, volume = 0.7 },
	FormHiss = { ids = { 9117895638 }, volume = 0.45 },
	FormCork = { ids = { 9113943660 }, volume = 0.9 },
	FormGulp = { ids = { 9114172296 }, volume = 0.9 },
	FormRise = { ids = { 9117297453 }, volume = 0.6 },
	FormRise2 = { ids = { 9119816710 }, volume = 0.6 },
	FormMagic = { ids = { 9125645227 }, volume = 0.7 },
	FormCrack = { ids = { 9113542363, 9119559518 }, volume = 0.8 },
	FormKnuckle = { ids = { 9116202331 }, volume = 1 },
	FormZap = { ids = { 9116274975 }, volume = 0.6 },
	Cauldron = { ids = { 9120305560 }, volume = 0.35 },
	-- Camp Hollowmere's monsters' moves (Client/CampFx; Pro Sound Effects): the Scarecrow's crows (a raven's caw, a
	-- sudden burst of birds), the Lake Witch's black water bubbling, the Antlered One's snort before his charge,
	-- the Scarecrow's sickle drawn along its blade
	CrowCaw = { ids = { 9118067220, 9118066001, 9118066003, 9118066302 }, volume = 0.8 },
	CrowFlock = { ids = { 9125738421 }, volume = 0.9 },
	Bubbles = { ids = { 9120310416, 9120310477 }, volume = 0.8 },
	BullSnort = { ids = { 9113634952 }, volume = 1 },
	BladeScrape = { ids = { 9113453649 }, volume = 0.8 },
	-- the Moonlight Carnival's monsters (Client/CarnivalFx; Pro Sound Effects): balloons popping, the Ringmaster's whip,
	-- Madame Fortune's crystal ball breaking, the ghost crowd in the stands, a laugh, a heavy landing, a magic burst
	BalloonPop = { ids = { 9113263649, 9113263647, 9113263454 }, volume = 0.9 },
	WhipCrack = { ids = { 9113612888, 9120663217 }, volume = 1 },
	GlassBreak = { ids = { 9114591515 }, volume = 1 },
	Crowd = { ids = { 9120974911 }, volume = 0.7 },
	EvilLaugh = { ids = { 9116239118, 9116239130 }, volume = 0.9 },
	HeavyImpact = { ids = { 9118617342 }, volume = 1 },
	MagicBurst = { ids = { 9116384485 }, volume = 0.8 },
}
