--!strict
-- THE TUTORIAL's steps, in order (Server/Tutorial runs them, Client/TutorialUI shows them). It is a real fight
-- with the Woman (Ghost.tutorial): she comes at you and swings, then stops for a few seconds and takes the hits.
-- A new player is put straight into it when they first join; it lasts about 30 seconds.
--   kind  = what the server waits for:
--     hits    `goal` hits on her (any)
--     charged `goal` fully charged hits
--     blocked `goal` of her hits blocked
--     ult     the ultimate fired and over (the brutality bar is filled for it; she can be beaten now)
--     end     nothing to do: shown for a few seconds, then back to the park
--     (also understood: walk, block, sprint, throw, item, info - the old lessons)
--   pause = the seconds she waits between two swings in this step (nil: she does not attack); first = the seconds
--   before her first swing of the step.
--   title = the card's heading; task = the one thing to do now; why = what it is for.
--   {Punch} {Block} {Sprint} {Lift} {Throw} {Ultimate} {Slot} {Next} are replaced on the client by the player's own
--   key, controller button or touch button. taskCarry = the task once the furniture is in the hands;
--   taskTouch = the task on touch controls, where it differs.
export type Step = {
	id: string, kind: string, goal: number, title: string, task: string, why: string,
	taskCarry: string?, taskTouch: string?, give: string?, pause: number?, first: number?,
}

local Steps: { Step } = {
	{ id = "hits", kind = "hits", goal = 5, title = "ATTACK", pause = 5, first = 4,
		task = "HIT HER 5 TIMES  {Punch}",
		why = "Hits in a row are a COMBO: each one hits harder. After each swing she stops for a moment: that is your chance." },
	{ id = "charged", kind = "charged", goal = 1, title = "CHARGED ATTACK", pause = 5, first = 3,
		task = "HOLD {Punch} UNTIL THE CHARGE IS FULL, THEN LET GO",
		why = "A full charge hits 2.5 times harder and can knock a monster out. A knocked-out monster cannot fight back." },
	{ id = "block", kind = "blocked", goal = 2, title = "BLOCK", pause = 2.2, first = 1.2,
		task = "WHEN SHE RAISES HER CLAWS, HOLD {Block}  -  BLOCK 2 HITS",
		why = "Face her: a blocked hit does no damage but costs STAMINA, the yellow bar. With none left, your guard breaks." },
	{ id = "ult", kind = "ult", goal = 1, title = "ULTIMATE",
		task = "YOUR BRUTALITY BAR IS FULL: FINISH HER  {Ultimate}",
		why = "Every hit fills the BRUTALITY bar. Full, it fires your ULTIMATE. More ultimates are sold in the lobby." },
	{ id = "ready", kind = "end", goal = 1, title = "YOU ARE READY",
		task = "PRESS PLAY IN THE PARK TO START A REAL RUN",
		why = "In a run the monsters come one after another, each one stronger. Every run pays CASH and XP." },
}

return { steps = Steps }
