# Making good game loops for Roblox games

Learned from a Gemini report the user shared (2026-11-18, about a merge simulator, "Patate Merge"). The numbers
below are that report's claims (it cites GameAnalytics' 2026 Roblox Benchmark Report); they were not checked.

## The loops

- **Core loop** (seconds to a minute): one action the player repeats, and each turn of it feeds the next. Merge-sim
  example: spawn tier N → merge two N into one N+1 (more passive income) → spend it on upgrades → spawn better → … with
  rare **mutations** to collect on the way (Normal x1, Golden x3, Crystal x10). The game's whole coherence lives in
  these rules: N + N → N+1, capacity, income per second, exponential costs.
- **Progression loop** (minutes to hours): upgrades that speed the core loop up. Each upgrade has a level L and costs
  `math.floor(BaseCost * GrowthRate ^ L)`. Merge-sim upgrades: better spawn tier, shorter spawn interval, more grid
  slots, an income multiplier, auto-merge speed. Plan the number of tiers up front (that report used 25 tiers for v1).
- **Prestige / rebirth loop** (hours to days): it resets the run but pays something permanent: rebirth currency from
  lifetime earnings, above a minimum threshold. It **keeps** the permanent multipliers and the **collection** (codex of
  everything discovered). The collection is a goal in itself: record each first discovery and celebrate it.
- **Long-term loop** (D7 to D30): deep endgame systems, seasonal live-ops events, an economy with no exploit. Secondary
  and social ideas: a server-wide timed event (a "Golden Rain" every 15 minutes that multiplies mutation chances),
  helpers or pets that do the core action automatically, gifts between players.

## Retention (the report's numbers)

- The median Roblox game keeps 10.3 % of players on day 1 (D1), 1.6 % on D7 and 0.5 % on D30. The top quarter to tenth
  reach 12.9–15.9 % on D1; the best 1 % reach 4.7 % on D30.
- **D1 is decided in the first 2 minutes (the FTUE)**: a player who doesn't feel immediate, smooth, rewarding progress
  leaves and never comes back. So: a tutorial that drives the first loop by itself, with a light/arrow pointing at the
  exact thing to do until they do it (merge sim: a beam from the plot to the player, an arrow between the first two
  items until the first merge), then a reward that celebrates the first unlock.
- Roblox's recommendations reward **retention together with deliberate monetization**, not retention alone. Spending is
  very concentrated: the report says the top 1 % of paying players spend $86.36, over 4x the 95th percentile.
- 55 % of players play on a touch screen at least sometimes, so the loop has to work on mobile: big touch targets,
  CoreUISafeInsets, no camera rotation while dragging, at most about 100 particles per second on phones.

## Building it

- The loop's maths are **pure functions** with no Workspace dependency (state in, new state out): canSpawn, canMerge,
  executeMerge, total income per second, cost, can-afford, rebirth reward, number formatting (1.25K, 3.40M, 1.10B,
  5.00T, 1.00aa, safe against NaN, negatives and math.huge). Then a test can simulate 1,000 turns of the loop and every
  upgrade level in milliseconds and check there is no NaN, no infinity and no economy exploit.
- The server owns the loop: a 1 Hz tick credits passive income and runs the auto-spawn timer; every action is a remote
  request that the server validates and applies, then it sends the player a state delta, plays the effect and updates
  leaderstats. The client only asks and displays.
- The HUD always shows the loop: the currency, income per second, how full the capacity is (slots X / Y), one big
  central action button with its cost, and quick buttons for Upgrades, Codex, Rebirth and Shop.
- Monetization plugs into the loop and speeds it up rather than replacing it. Game passes: auto-merge, x2 income, a VIP
  plot, faster spawns. Developer products: currency packs, "fill the grid now", a crate of rare items with its odds shown
  before buying (70 / 25 / 5 %), hidden where PolicyService says paid random items are restricted.
- **Measure the loop**: an onboarding funnel (AnalyticsService.LogOnboardingFunnelStepEvent: joined and got a plot,
  first spawn, first merge, first upgrade, tier 5 reached) shows where new players drop; economy events
  (LogEconomyEvent) log every source and sink of each currency.
