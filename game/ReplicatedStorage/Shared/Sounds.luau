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
	-- to change one, put another audio id here. Volume 1.6: these recordings are much quieter than the sound effects
	-- (at 0.5 the fight drowned them out); the MUSIC slider in the settings still scales them.
	Music_Woman = { ids = { 94597327890629 }, volume = 1.6 }, -- Ghost Stalker
	Music_Woman_E = { ids = { 109753218180637 }, volume = 1.6 }, -- Wailing Walls (the Violet Widow)
	Music_Demon = { ids = { 1837853076 }, volume = 1.6 }, -- See You In Hell
	Music_Demon_E = { ids = { 1837246602 }, volume = 1.6 }, -- Demonic Torment (the Demon Lord: metal, like Black Plague)
	Music_Pirate = { ids = { 1842925663 }, volume = 1.6 }, -- Pirate Battle
	Music_Pirate_E = { ids = { 1835322563 }, volume = 1.6 }, -- Pirate King
	Music_Animatronic = { ids = { 1837432993 }, volume = 1.6 }, -- Freak Circus
	Music_Animatronic_E = { ids = { 9044887799 }, volume = 1.6 }, -- Psycho Clown
	Music_Titan = { ids = { 9039352479 }, volume = 1.6 }, -- The Heroic Battle of Giants
	Music_Titan_E = { ids = { 9039352746 }, volume = 1.6 }, -- The Fall of the Titans
	Music_Goblin = { ids = { 1841594035 }, volume = 1.6 }, -- Mischievous Elves (sneaky, not epic)
	Music_Goblin_E = { ids = { 1839900676 }, volume = 1.6 }, -- In the Hall of the Mountain King
	Music_Caller = { ids = { 1837463370 }, volume = 1.6 }, -- Catching a Killer
	Music_Caller_E = { ids = { 117622854482826 }, volume = 1.6 }, -- Maniac (underscore)
	Music_Conqueror = { ids = { 9039352752 }, volume = 1.6 }, -- Soul Conqueror
	Music_Conqueror_E = { ids = { 1844309360 }, volume = 1.6 }, -- Requiem: Dies Irae
	Music_Rat = { ids = { 1837247400 }, volume = 1.6 }, -- The Speed of Light (the Sewer Rat: speed metal, like Black Plague)
	Music_Rat_E = { ids = { 1837318901 }, volume = 1.6 }, -- Black Plague
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
}
