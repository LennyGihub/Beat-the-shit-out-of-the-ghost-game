--!strict
-- ENTRANCES: every monster comes into the house with its own short cinematic (Client/Entrance plays the camera,
-- the effects and the name card; Client/EntrancePose moves the monster's body). This table is how long each one
-- lasts: the server keeps the monster in its "Spawn" state for that long (it cannot be hurt and does not move or
-- attack), then the fight starts. An evolved monster uses its base monster's entrance, in its own colours.
local TIME: { [string]: number } = {
	Woman = 5.0, -- rises out of the floor in a pool of mist, then screams
	Demon = 5.0, -- a burning circle, a pillar of fire, he stands up in it and roars
	Pirate = 5.0, -- back turned in the sea fog, turns round on the spot, bangs his cutlass on his shield, raises it
	Animatronic = 5.6, -- lights out, a music box, a spotlight: showtime (the Golden Bear snaps his fingers)
	Titan = 5.0, -- comes down through the ceiling and lands on one fist
	Goblin = 4.8, -- smoke puffs all over the room, a somersault out of the last one
	Caller = 5.4, -- the phone rings in the dark; each flash of light shows him somewhere else (never closer)
	Conqueror = 5.6, -- a portal tears open behind him, he takes shape in front of it, stamps, fist raised
	Rat = 4.8, -- the floor bulges and cracks, he bursts out of it and shrieks
	Knight = 6.2, -- breathing behind a wall; his blade burns a doorway through it and he steps out
	-- Camp Hollowmere
	Antlered = 5.2, -- hangs upside down from the rafters right above, drops, flips upright on landing and bellows
	LakeWitch = 5.4, -- rises out of a pool of black water, whirls her hook overhead and slams it down
	Counselor = 5.2, -- the room goes dark, his torch catches, held by his burned face; a ring of fire and a scream
	Scarecrow = 5.6, -- hangs on his pole with crows on his arms; his head snaps up, the crows burst off, he drops
	-- the Moonlight Carnival
	Clown = 5.2, -- a jack-in-the-box plays its tune and shakes; POP: he springs out of it on a coil, confetti, ta-da
	Strongman = 5.0, -- crouched over a giant barbell: he lifts it over his head, roars, and drops it (a shockwave)
	Fortune = 5.4, -- a crystal ball glows on a little table in the dark, her eyes in it; she fades in behind it, cards fly
	Ringmaster = 5.6, -- one spotlight in the dark: head bowed, then arms wide, the whip cracks, the crowd roars, lights
	-- Blackwater Harbor (Client/Entrance plays a fitting entrance of another monster for each)
	DeepOne = 5.4, -- rises out of a pool of black water and slams down (the Lake Witch's)
	Keeper = 5.2, -- the room goes dark, his lamp catches, held up by his face; a flare (the Counselor's)
	Netman = 5.0, -- back turned in the sea fog, turns round and bangs his fists together (the Pirate's)
	-- the Ashen Abbey and the Black Moon (Client/Entrance: own effects on a borrowed body motion)
	Nun = 5.0, -- candles light round a black pool; she rises out of it under the window light and screams (the Woman's rise)
	Gravedigger = 4.8, -- a headstone topples, he claws out of the grave on all fours and rears up (the Rat's burst)
	Ringer = 5.0, -- the bells toll above; he drops out of the tower onto one fist and the floor rings (the Giant's fall)
	Astronaut = 5.6, -- klaxon; the airlock behind him opens in a burst of fog, a jetpack hop, he raises his fist
	Specimen = 5.2, -- slime drips from the ceiling; it hangs up there upside down, drops in acid and screeches (the Antlered One's)
	Sentinel = 5.6, -- powered down in the dark; its red eye flickers on, sparks, a scanning fan, arms wide (the Ringmaster's)
}
return {
	time = TIME,
	plain = 2.2, -- no entrance (the sandbox's training dummy): the old fade-in
	of = function(id: string): number return TIME[id] or 2.2 end,
}
