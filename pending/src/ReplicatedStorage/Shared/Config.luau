--!strict
-- All gameplay tuning in one place (server and client read it).
local Config = {
	Punch = {
		Cooldown = 0.24, -- seconds between punches
		Range = 10, -- studs from the head to the ghost
		ConeDot = 0.4, -- how much the punch must point at the ghost (1 = exactly)
		StaminaCost = 7,
		BaseDamage = 5,
		ComboWindow = 1.5, -- next hit within this keeps the combo going
		ComboDamageStep = 0.24, -- +24% damage for every combo step: every punch hits harder
		MaxComboScale = 5,
		BaseKnock = 20, -- knockback speed of the first punch
		KnockPerCombo = 8,
		MaxKnock = 280, -- items knock harder (Items KNOCK_MULT)
	},
	-- charged attacks (fists and melee weapons): the hit is thrown when the button is released: a tap = a normal hit,
	-- holding longer charges it. charge = (held - MinHold) / Full, from 0 to 1.
	Charge = {
		MinHold = 0.25, -- seconds of holding before charging starts (a tap never charges)
		Full = 1.0, -- seconds of charging to reach full power
		MinRelease = 0.15, -- a release below this charge throws nothing (it was just a tap)
		DamageBonus = 1.5, -- full charge: damage x(1 + 1.5) = x2.5
		KnockBonus = 1.0, -- full charge: knockback x2 (big enough to knock monsters out)
		StaminaBonus = 1.5, -- full charge costs x2.5 stamina
	},
	Stamina = { Max = 200, Regen = 52, RegenDelay = 0.7, ThrowCost = 12, SprintPerSecond = 14 }, -- twice the old 100 (same refill time)
	-- blocking (hold right click): hits from the front do Damage x, cost Cost + hit x PerDamage stamina; out of stamina =
	-- guard break (full hit, no blocking for BreakTime). No attacking, no sprinting, slower walk and no stamina regen.
	Block = { Damage = 0.25, Knock = 0.35, Cost = 6, PerDamage = 0.6, FrontDot = 0.15, WalkMult = 0.55, BreakTime = 1.5 },
	Brutality = {
		Max = 100,
		PerHit = 4,
		PerCombo = 1.1,
		ThrowHit = 16,
		UltDuration = 10,
		UltDamageMult = 2.2,
		UltKnockMult = 1.8,
		UltThrowMult = 2.0,
		UltShockRadius = 24,
		UltShockDamage = 30,
	},
	Carry = {
		Range = 11,
		ThrowSpeed = 100,
		ThrowUp = 10,
		BaseDamage = 10,
		DamagePerWeight = 7,
		SlowPerWeight = 1.4,
	},
	Player = { WalkSpeed = 17, SprintSpeed = 26, MaxHealth = 300 },
	-- a second monster hit within Window seconds knocks you down (ragdoll for Time seconds); blocked hits don't count
	Knockdown = { Window = 4, Time = 1.6, Speed = 45, Lift = 22 },
	Ghost = {
		BaseHP = 400,
		HPPerLevel = 180,
		Speed = 12,
		SpeedPerLevel = 1.3,
		AttackRange = 8,
		WindUp = 0.6,
		SwipeReach = 11,
		SwipeDamage = 16,
		SwipeDamagePerLevel = 3,
		AttackCooldown = 1.1,
		ScareMin = 14,
		ScareMax = 24,
		ScareDamage = 8,
		ScareStaminaDrain = 45,
		HoverHeight = 4.6, -- root height above the floor
		FurnitureHitDamagePerWeight = 4,
		WallSlamFactor = 0.12,
	},
	-- FURY (Server/Fury.luau): every monster fights back. Pressure from your hits -> a telegraphed ROAR that throws
	-- you away; LUNGE from mid range; swipe COMBOS; ENRAGED below half HP. Fairness: Grace seconds of no melee after
	-- a monster throws you, and at most BurstCap of your max health lost to a monster within BurstWindow seconds.
	Fury = {
		PressureMax = 8, -- counted hits (drains PressureDecay per second) before it roars
		EnragedPressureMax = 6,
		PressureDecay = 0.6,
		ArmorPressure = 3, -- from this much pressure it swipes back through your punches (armoured wind-up; block it!)
		ArmorBreakKnock = 140, -- the armour (roar, swipe-back) only breaks to a charged hit or a blow this heavy
		KnockoutPressure = 3, -- a hit that knocks it out counts this much
		HitSpacing = 0.12, -- rapid-fire hits closer than this don't count
		WakeRoar = 5, -- getting up from a knock-out with this much pressure left: it roars
		RoarWind = 0.65, -- telegraph; small hits don't stop it, a knock-out hit does
		RoarRadius = 17,
		RoarDamage = 0.6, -- x its swipe damage
		RoarPush = 62,
		RoarRag = 0.9,
		LungeMin = 12, LungeMax = 36, LungeCd = { 5, 7.5 },
		LungeWind = 0.5, LungeSpeed = 78, LungeTime = 0.45, LungeHitR = 6,
		LungeDamage = 1.15, -- x its swipe damage
		Combo = 2, EnragedCombo = 1, ComboWindUp = 0.32,
		-- enraged: every swipe is a SMASH PUNCH that launches you through the inside walls
		SmashSpeed = 115, SmashUp = 30, SmashTime = 1.6, SmashDamage = 1.25, SmashReach = 45,
		EnrageAt = 0.5, EnrageSpeed = 1.2, EnrageCooldown = 0.7,
		Grace = 1.3,
		RegenPause = 6, -- no health regen for this long after a monster hits you (StarterCharacterScripts.Health)
		BurstCap = 0.4, BurstWindow = 3,
	},
	-- more players = a stronger monster: each extra player adds this much (2 players = x1.55 health, 4 = x2.65)
	Scaling = { HpPerPlayer = 0.55, DmgPerPlayer = 0.1, SpeedPerPlayer = 0.05, CooldownPerPlayer = 0.06 },
	-- Robux cash packs (Developer Products): attr = the ReplicatedStorage attribute holding the product id
	-- (0 = not set up yet: the shop shows SOON). A good run pays ~1800-2600 cash, maps cost 1200-3200.
	CashPacks = {
		{ attr = "CashPack1Id", cash = 1000, name = "POCKET CHANGE" },
		{ attr = "CashPack2Id", cash = 2500, name = "BAG OF CASH" },
		{ attr = "CashPack3Id", cash = 6000, name = "BRIEFCASE" },
		{ attr = "CashPack4Id", cash = 15000, name = "VAULT" },
	},
	Reward = { Base = 200, PerLevel = 120 }, -- RUN cash per ghost (spent on items, lost after the run)
	Payout = { PerKill = 55, PerLevel = 22, DamageDiv = 30 }, -- real cash paid when you die or leave the run (x difficulty reward)
	-- WILDFIRE (the flamethrower): what it sets alight keeps spreading through the whole house: across floors, up the
	-- walls, through doorways and walls, up to the next floor. It burns the MONSTER only (players walk through it).
	-- Max fires at once, each fire's life, seconds between a fire's spread tries, how long it keeps spreading after
	-- the last squirt of the flamethrower, damage per second to a monster within Radius of any of it.
	Wildfire = { Max = 70, LifeMin = 16, LifeMax = 24, SpreadMin = 0.45, SpreadMax = 1.0, Campaign = 22, Dps = 14, Radius = 6.5 },
	-- EXPLOSIVE BARRELS (red, in every map; a Furniture model with the attribute Explosive): they blow up when they
	-- break (thrown at something, the monster knocked into them, a shockwave): inside walls open, furniture near
	-- them flies (other barrels chain), the monster is blasted and set alight, players too close are thrown.
	Barrel = { Radius = 17, Damage = 60, Knock = 135, PlayerRadius = 10, PlayerDamage = 18, FireRadius = 6 },
	-- event cinematics (Client EventFx / PlaneFx play them, Server Events waits for them): seconds until the crash
	Events = { PlaneTime = 5, VanTime = 3.2, VanSettle = 0.6, TrainTime = 4.6 },
	-- (read them with Config.eventTime(name): in Studio the ReplicatedStorage attribute DebugEventSlow = n plays them n times slower)
	BreakTime = 40, -- seconds between ghosts (or start early at the front door)
	EventLife = 3, -- an event's shop stays for the next 3 ghosts
	Yard = { Min = Vector3.new(-95, -5, 60), Max = Vector3.new(95, 80, 165) },
	SpawnInside = Vector3.new(0, 5, 46),
	OutsideZ = 64, -- crossing this (out the front porch) counts as outside
	House = { Min = Vector3.new(-80, -5, -60), Max = Vector3.new(80, 80, 60) },
}
function Config.eventTime(name: string): number
	local slow = game:GetService("RunService"):IsStudio() and game:GetService("ReplicatedStorage"):GetAttribute("DebugEventSlow")
	return (Config.Events :: any)[name] * (type(slow) == "number" and slow or 1)
end
return Config
