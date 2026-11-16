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
	Stamina = { Max = 100, Regen = 26, RegenDelay = 0.7, ThrowCost = 12, SprintPerSecond = 14 },
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
	Player = { WalkSpeed = 17, SprintSpeed = 26, MaxHealth = 100 },
	Ghost = {
		BaseHP = 400,
		HPPerLevel = 180,
		Speed = 12,
		SpeedPerLevel = 1.3,
		AttackRange = 8,
		WindUp = 0.6,
		SwipeReach = 11,
		SwipeDamage = 12,
		SwipeDamagePerLevel = 2.5,
		AttackCooldown = 1.4,
		ScareMin = 14,
		ScareMax = 24,
		ScareDamage = 8,
		ScareStaminaDrain = 45,
		HoverHeight = 4.6, -- root height above the floor
		FurnitureHitDamagePerWeight = 4,
		WallSlamFactor = 0.12,
	},
	Reward = { Base = 200, PerLevel = 120 }, -- RUN cash per ghost (spent on items, lost after the run)
	Payout = { PerKill = 40, PerLevel = 18, DamageDiv = 30 }, -- real cash paid when you die or leave the run (x difficulty reward)
	BreakTime = 40, -- seconds between ghosts (or start early at the front door)
	EventLife = 3, -- an event's shop stays for the next 3 ghosts
	Yard = { Min = Vector3.new(-95, -5, 60), Max = Vector3.new(95, 80, 165) },
	SpawnInside = Vector3.new(0, 5, 46),
	OutsideZ = 64, -- crossing this (out the front porch) counts as outside
	House = { Min = Vector3.new(-80, -5, -60), Max = Vector3.new(80, 80, 60) },
}
return Config
