# How the user works with Gemini, and the "Patate Merge" project (learned 2026-11-24)

From the user's Gemini handoff dated 2026-11-21. The full French original is
`.claude/reference/handoff-gemini-patate-merge-2026-11-21.md` (a note about an unrelated project was shortened in
that public copy). It is about ANOTHER game, "Patate Merge" (repo `jeu-1-patate`), not Beat the Ghost.

## The user's setup
- The user works alone with Claude Code on a Claude Pro plan with a LIMITED quota, and uses Gemini (Google AI Pro)
  as a design workshop, prompt optimiser and outside reviewer / debugger to save Claude tokens. So: be economical
  (whole modules, few round trips, no re-reading), and keep answers easy to paste into Gemini.
- Gemini's role there: prompt engineering expert + outside technical architect / debugger; blunt honesty (flag
  blind spots, contradict when needed, never flatter or hide a risk).

## "Gate & Clear" protocol (how the user drives Claude Code)
- Each prompt N ends with its own deterministic validation gate (GATE N: static checks + off-Studio tests + deploy +
  a playtest with console check + screenshot). Then a 2-minute human check in Studio.
- If phase N is fine: `tools/save_game.sh` (needed because /rewind does not undo what MCP did in Studio), then
  /clear (or /compact) and paste prompt N+1. If it has a defect: fix N first; never chain N+1 on a defective N.
- The user sends work to Gemini when Claude Code fails after ONE fix attempt on a bug (stop, copy the console error -
  remember tools/studio.py error lines are off by +1 - and the .luau file, get a surgical patch), and for outside
  "critical" audits of data stores, trading anti-dupe, the market and ProcessReceipt / monetisation.
- Forbidden: asking Claude Code to "step back and polish" without a precise bug (scope creep, regressions, double
  quota). For Claude sessions this means: when a fix fails, say so plainly with the error and the file so the user
  can take it to Gemini; never widen the scope on your own.
- Prompt style the user uses for Claude: XML-tagged structure, long reference material first and directives last,
  isolated reasoning ("ultrathink"), affirmative directives only, modular variables, GATE checks in every prompt,
  structured outputs.

## Patate Merge (jeu-1-patate), for reference only
- A test of Claude Code's abilities, kept OUT of the user's future shared-base "variants" program.
- Design: 6-8 open 3D player bases around a central market; on each base's back wall a big vertical 2D circle
  (SurfaceGui) where potatoes spawn, bounce and MERGE AUTOMATICALLY in pairs of the same level (no clicks, no rounds,
  no defeat), a SCORE counter under it; an overflow reserve queue so the circle never blocks; 15 potato forms
  (placeholder visuals through one PotatoVisualRegistry, real art at the very end). Three sealed resources: Score
  (merges only, never spent / traded / bought), Patacash (only potatoes displayed on 3D showcase pedestals produce
  it; buys base upgrades, decor, guaranteed deliveries with known contents - no loot boxes), Diamonds (only from 3
  daily objectives + Patatedex milestones; used for direct trading and the Patate Market; not sold for Robux at
  launch). Mutations Golden / Rainbow / Lightning rolled online only, auto-locked, either shown (x3 / x8 / x20
  Patacash) or sacrificed in a merge (best multiplier, math.max, never multiplied); a synthetic voice
  (AudioTextToSpeech) announces first rare discoveries. Offline: 25 % of showcase Patacash, capped at 6 h, no
  mutations, no Diamonds. Trading with a reset-on-change + 3 s anti-scam lock and an atomic commit; a PETS GO!-style
  market (physical stalls, filters, fixed Diamond prices, optional 5 % fee, anti price-baiting). Monetisation:
  cosmetics / comfort passes, never Score or Diamonds, PolicyService review for anything that speeds mutations,
  prices read from MarketplaceService, R15 only, analytics, a hide-UI button for video creators.
- State on 2026-11-21: Prompt 01 done (Loader.luau with Init / Start phases, Trove, Signal, Main entry points);
  Prompts 02-10 written (verbatim in the reference file) but not run. Open questions before Prompt 02: the real file
  tree from Prompt 01, 15 forms or another list, circle <-> inventory transfer (automatic vs explicit extraction),
  6 or 8 players per server, offline merges or showcase Patacash only, the 5 % market fee from the start. Harmonise
  before sending: no emoji ("[PROTEGEE]" instead of a padlock emoji in Prompt 06), add R15 / analytics / hide-UI to
  Prompts 02 / 10, no paid luck or mutation boost at launch without the PolicyService review and real product ids.
