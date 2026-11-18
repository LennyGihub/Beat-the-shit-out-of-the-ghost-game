--!strict
-- THE TUTORIAL's steps, in order (Server/Tutorial runs them, Client/TutorialUI shows them).
--   kind  = what the server waits for:
--     walk    come within `goal` studs of the Woman
--     hits    `goal` hits on her (any)
--     charged `goal` fully charged hits
--     block   `goal` seconds of blocking
--     sprint  `goal` seconds of running
--     throw   `goal` pieces of furniture thrown into her
--     item    `goal` hits with the weapon the step hands out (`give`)
--     ult     the ultimate fired (the brutality bar is filled for it)
--     info    nothing to do: the player reads and goes on (NEXT)
--   title = the card's heading; task = the one thing to do now; why = what it is for.
--   {Punch} {Block} {Sprint} {Lift} {Throw} {Ultimate} {Slot} {Next} are replaced on the client by the player's own
--   key, controller button or touch button. taskCarry = the task once the furniture is in the hands;
--   taskTouch = the task on touch controls, where it differs.
export type Step = {
	id: string, kind: string, goal: number, title: string, task: string, why: string,
	taskCarry: string?, taskTouch: string?, give: string?,
}

local Steps: { Step } = {
	{ id = "walk", kind = "walk", goal = 16, title = "MEET THE WOMAN",
		task = "WALK UP TO HER",
		why = "She is the first monster of every run. For this lesson she stands still. In a real run she hunts you." },
	{ id = "hits", kind = "hits", goal = 5, title = "PUNCH",
		task = "HIT HER 5 TIMES  {Punch}",
		why = "Hits in a row are a COMBO: each one hits harder than the last." },
	{ id = "charged", kind = "charged", goal = 1, title = "CHARGED HIT",
		task = "HOLD {Punch} UNTIL THE CHARGE IS FULL, THEN LET GO",
		why = "A full charge hits 2.5 times harder and can knock a monster out. A knocked-out monster cannot fight back." },
	{ id = "block", kind = "block", goal = 1.2, title = "BLOCK",
		task = "HOLD {Block} FOR A MOMENT",
		why = "A blocked hit from the front does a quarter of the damage, but it costs stamina. With no stamina left your guard breaks." },
	{ id = "sprint", kind = "sprint", goal = 1.5, title = "RUN",
		task = "RUN: HOLD {Sprint} WHILE YOU MOVE", taskTouch = "RUN: TAP {Sprint} AND MOVE",
		why = "Running, hitting and blocking all use STAMINA, the yellow bar. It comes back when you stop." },
	{ id = "throw", kind = "throw", goal = 1, title = "FURNITURE",
		task = "LOOK AT A PIECE OF FURNITURE AND LIFT IT  {Lift}", taskCarry = "NOW THROW IT AT HER  {Throw}",
		why = "Everything in the house is a weapon. The heavier it is, the harder it hits, and the slower you walk with it." },
	{ id = "item", kind = "item", goal = 3, title = "WEAPONS", give = "BaseballBat",
		task = "TAKE THE BAT IN YOUR HAND {Slot} AND HIT HER 3 TIMES",
		why = "In a run, wrecks crash near the house: they are shops. Weapons are bought there with RUN CASH, and they wear out." },
	{ id = "ult", kind = "ult", goal = 1, title = "ULTIMATE",
		task = "THE BRUTALITY BAR IS FULL: FIRE YOUR ULTIMATE  {Ultimate}",
		why = "Every hit fills the BRUTALITY bar. Other ultimates are sold at the SHOP in the lobby." },
	{ id = "run", kind = "info", goal = 1, title = "A RUN",
		task = "THE MONSTERS COME ONE AFTER ANOTHER, EACH ONE STRONGER",
		why = "Beating a monster pays RUN CASH. Every third monster is an EVOLVED boss with a new power." },
	{ id = "down", kind = "info", goal = 1, title = "GOING DOWN",
		task = "WITH TEAMMATES STILL STANDING, YOU WATCH THEM AND COME BACK WHEN THE MONSTER IS KNOCKED OUT",
		why = "When your run ends, your kills and your damage are paid in CASH. Cash buys ultimates and maps." },
	{ id = "lobby", kind = "info", goal = 1, title = "THE LOBBY",
		task = "PRESS PLAY TO OPEN OR JOIN A LOBBY, OR STEP ON A ROOM PAD IN THE PARK",
		why = "SHOP: ultimates and maps. QUESTS: cash every day. BESTIARY: the monsters you have beaten." },
}

return { steps = Steps }
