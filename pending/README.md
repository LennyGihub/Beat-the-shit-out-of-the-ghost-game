# Pending: the ultimates' new animations (not all of it is in Studio yet)

`pending/src/` holds the whole rework of the 50 ultimates' animations (12 scripts, same layout as `game/`).
The Studio bridge stopped mid-session on 2026-11-17: the ngrok account hit its monthly bandwidth cap
(`403 ERR_NGROK_725`), so the last fixes could not be pushed and `tools/save_game.sh` could not run.

## What Studio has

Everything here was deployed and playtested EXCEPT the last edits to these three, which are only syntax-checked:

- `ServerScriptService/Server/Combat.luau`: `Combat.endUltimate` (new), the giant stops growing if its ultimate is ended.
- `ServerScriptService/Server/Admin.luau`: the admin command `ult <id>` ends a running ultimate first.
- `StarterPlayer/StarterPlayerScripts/Client/UltFx.luau`: Exploding Fists' pops keep their distance in the caster's own view.

Studio was left in a running playtest: stop it before deploying.

## When the bridge is back

```bash
python3 tools/studio.py stop
```

```bash
python3 tools/deploy_luau.py --root pending/src
```

```bash
tools/save_game.sh "game: every ultimate has its own cast animation and blocky effects"
```

Then delete `pending/`.

## Still to look at in a playtest

27 of the 50 ultimates were cast in the playtest, with no script errors. Photographed and checked: all 20
first-person hand animations, the third-person poses, the wind-up, the shockwave styles (Rage, Ground Pound,
Street Sweeper, Hellfire, Ice Age, Earthquake, Supernova), lightning, the meteor's target, the holy beam, the nuke,
the ice prison, the time stop clock, the black hole.

Ran without errors but not yet looked at from outside: the uppercut's trail and landing, Heavy Hands' iron blocks,
furniture streaks, the burn, heal and stamina effects, the giant's growth, the auras.

Never ran (written and syntax-checked only): the tornado (Furniture Tornado), Bullet Time (bullets, slow-motion
frames), Blood Moon's moon, Exploding Fists' pops, Berserk God's arcs, God Mode's pillar and halo, the One Punch
hit, time resuming after a time stop. The other uncast ultimates reuse effects that did run, with other numbers.

`tools/ult_shots/` has the scripts that take those pictures (see `run.sh`).
