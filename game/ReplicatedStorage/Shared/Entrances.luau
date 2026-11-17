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
}
return {
	time = TIME,
	plain = 2.2, -- no entrance (the sandbox's training dummy): the old fade-in
	of = function(id: string): number return TIME[id] or 2.2 end,
}
