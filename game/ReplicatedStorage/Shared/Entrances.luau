--!strict
-- ENTRANCES: every monster comes into the house with its own short cinematic (Client/Entrance plays the camera,
-- the effects and the name card; Client/EntrancePose moves the monster's body). This table is how long each one
-- lasts: the server keeps the monster in its "Spawn" state for that long (it cannot be hurt and does not move or
-- attack), then the fight starts. An evolved monster uses its base monster's entrance, in its own colours.
local TIME: { [string]: number } = {
	Woman = 5.0, -- rises out of the floor in a pool of mist, then screams
	Demon = 5.0, -- a burning circle, a pillar of fire, he stands up in it and roars
	Pirate = 5.0, -- walks out of the sea fog, bangs his cutlass on his shield, raises it
	Animatronic = 5.6, -- lights out, a music box, a spotlight: showtime (the Golden Bear snaps his fingers)
	Titan = 5.0, -- comes down through the ceiling and lands on one fist
	Goblin = 4.8, -- smoke puffs all over the room, a somersault out of the last one
	Caller = 5.4, -- the phone rings in the dark; each flash of light shows him closer
	Conqueror = 5.6, -- a portal tears open and he walks out of it, fist raised
	Rat = 4.8, -- the floor bulges and cracks, he bursts out of it and shrieks
	Knight = 6.2, -- breathing behind a wall; his blade burns a doorway through it and he steps out
	-- Camp Hollowmere
	Antlered = 5.2, -- crawls upside down along the rafters, drops, flips upright on landing and bellows
	LakeWitch = 5.4, -- rises out of a pool of black water, whirls her hook overhead and slams it down
	Counselor = 5.2, -- the room goes dark, his torch catches, held by his burned face; a ring of fire and a scream
	Scarecrow = 5.6, -- hangs on his pole with crows on his arms; his head snaps up, the crows burst off, he drops
	-- the Moonlight Carnival
	Clown = 5.2, -- a jack-in-the-box plays its tune and shakes; POP: he springs out of it on a coil, confetti, ta-da
	Strongman = 5.0, -- crouched over a giant barbell: he lifts it over his head, roars, and drops it (a shockwave)
	Fortune = 5.4, -- a crystal ball glows on a little table in the dark, her eyes in it; she fades in behind it, cards fly
	Ringmaster = 5.6, -- one spotlight in the dark: head bowed, then arms wide, the whip cracks, the crowd roars, lights
}
return {
	time = TIME,
	plain = 2.2, -- no entrance (the sandbox's training dummy): the old fade-in
	of = function(id: string): number return TIME[id] or 2.2 end,
}
