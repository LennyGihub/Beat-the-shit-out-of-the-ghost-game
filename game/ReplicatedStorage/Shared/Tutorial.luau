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
	id: string, kind: string, goal: number, title: string, task: string, why: string?,
	taskCarry: string?, taskTouch: string?, give: string?, pause: number?, first: number?,
}

-- (short on purpose: one line to read per step, the count on the bar; why = an optional second line)
local Steps: { Step } = {
	{ id = "hits", kind = "hits", goal = 5, title = "ATTACK", pause = 5, first = 4,
		task = "HIT HER  {Punch}" },
	{ id = "charged", kind = "charged", goal = 1, title = "CHARGED ATTACK", pause = 5, first = 3,
		task = "HOLD {Punch}, LET GO WHEN FULL" },
	{ id = "block", kind = "blocked", goal = 2, title = "BLOCK", pause = 2.2, first = 1.2,
		task = "HOLD {Block} WHEN SHE SWINGS" },
	{ id = "ult", kind = "ult", goal = 1, title = "ULTIMATE",
		task = "FINISH HER  {Ultimate}" },
	{ id = "ready", kind = "end", goal = 1, title = "YOU ARE READY",
		task = "PRESS PLAY TO START A RUN" },
}

return { steps = Steps }
