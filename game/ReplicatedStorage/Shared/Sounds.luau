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
	Music_Woman = { ids = { 94597327890629 }, volume = 1.6 }, -- Ghost Stalker
	Music_Woman_E = { ids = { 109753218180637 }, volume = 1.6 }, -- Wailing Walls (the Violet Widow)
	Music_Demon = { ids = { 1837853076 }, volume = 1.6 }, -- See You In Hell
	Music_Demon_E = { ids = { 1837246602 }, volume = 1.6 }, -- Demonic Torment (the Demon Lord: metal, like Black Plague)
	Music_Pirate = { ids = { 1845219835 }, volume = 1.6 }, -- Pirate Chase (2:03; Pirate Battle was 1:11)
	Music_Pirate_E = { ids = { 1835322563 }, volume = 1.6 }, -- Pirate King
	Music_Animatronic = { ids = { 1837432993 }, volume = 1.6 }, -- Freak Circus
	Music_Animatronic_E = { ids = { 9044887799 }, volume = 1.6 }, -- Psycho Clown
	Music_Titan = { ids = { 9039352479 }, volume = 1.6 }, -- The Heroic Battle of Giants
	-- Camp Hollowmere's monsters (licensed production music)
	Music_Antlered = { ids = { 9046674561 }, volume = 1.4 }, -- Taiko Thunderstorm ALT. 1 (war drums for the hunt, 2:27)
	Music_LakeWitch = { ids = { 1837840805 }, volume = 1.4 }, -- Vanquish the Darkness (Mus) (dark epic orchestra, 2:53)
	Music_Counselor = { ids = { 9038254416 }, volume = 1.3 }, -- Fight Hard or Die (metal for the burning slasher, 3:34)
	Music_Scarecrow = { ids = { 1839538604 }, volume = 1.4 }, -- Menacing Forces (trailer action for the cornfield chase, 2:41)
	Music_Clown = { ids = { 1847690202 }, volume = 1.6 }, -- Evil Clown Clan A (2:40)
	Music_Strongman = { ids = { 1837078128 }, volume = 1.5 }, -- Brutal Power (2:14)
	Music_Fortune = { ids = { 1836697907 }, volume = 1.6 }, -- Theatre Macabre (2:18)
	Music_Ringmaster = { ids = { 1845844372 }, volume = 1.5 }, -- Dark Circus A (2:21)
	Music_Titan_E = { ids = { 9039352746 }, volume = 1.6 }, -- The Fall of the Titans
	-- Blackwater Harbor
	Music_DeepOne = { ids = { 1837865409 }, volume = 1.4 }, -- Paving the Road to Hell (dark hybrid action, 2:28)
	Music_Keeper = { ids = { 1838617255 }, volume = 1.4 }, -- Final Destruction (trailer action, 2:19)
	Music_Netman = { ids = { 9038254566 }, volume = 1.3 }, -- Metal Storm Breaks (metal, 3:16)
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
	Music_Goblin = { ids = { 1841594035 }, volume = 1.6 }, -- Mischievous Elves (sneaky, not epic)
	Music_Goblin_E = { ids = { 1839900676 }, volume = 1.6 }, -- In the Hall of the Mountain King
	Music_Caller = { ids = { 1837463370 }, volume = 1.6 }, -- Catching a Killer
	Music_Caller_E = { ids = { 117622854482826 }, volume = 1.6 }, -- Maniac (underscore)
	Music_Conqueror = { ids = { 9039352752 }, volume = 1.6 }, -- Soul Conqueror
	Music_Conqueror_E = { ids = { 1844309360 }, volume = 1.6 }, -- Requiem: Dies Irae
	Music_Rat = { ids = { 1837247400 }, volume = 1.6 }, -- The Speed of Light (the Sewer Rat: speed metal, like Black Plague)
	Music_Rat_E = { ids = { 1837318901 }, volume = 1.6 }, -- Black Plague
	-- the intro's way out (Client/Intro): Black Plague gives way to this once she is beaten
	IntroOutro = { ids = { 9039353950 }, volume = 1.6 }, -- Strength of Will (Cezame Original Scores)
	Music_Knight = { ids = { 9044584201 }, volume = 1.6 }, -- Evil Overlord (the Void Knight)
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
