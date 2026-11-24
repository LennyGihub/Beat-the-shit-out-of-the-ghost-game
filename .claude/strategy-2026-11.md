# Roblox strategy (learned 2026-11-24 from the user's "STRATEGIE-ROBLOX.md", dated 2026-11-18)

The full French original (with its sources and tags) is `.claude/reference/STRATEGIE-ROBLOX-2026-11-18.md` (a private
deal between partners was removed from that public copy). It was written for the user's wider plan: several games
built on one shared, invisible base, each visibly different. Its tags: [P] official Roblox page / SEC filing,
[mesure] measured on Roblox's public APIs, [calc] computed, [S] secondary source, [H] the author's judgement,
[?] unknown. Only [P] / [mesure] numbers should decide a spend. Section numbers below (§) point into the original.
Where it differs from this game's own rules, THIS GAME'S RULES WIN: no Roblox AI generation for models / scenes /
textures (the strategy lists Studio's generators as an option), Studio is the source of truth, the grunge UI style
stays.

## The platform (§0, §2) [P unless marked]
- Not growing: Q3 2026 138 M DAU (-9 % y/y), ~34 bn hours (-15 %), bookings $1.7 bn (-12 %), Q4 bookings forecast
  -10 % to -15 %. A new game takes attention from other games; the algorithm rewards 28-day retention.
- Age-checked DAU: 34 % under 13, 37 % 13-17, 29 % 18+. >80 % of the top 100 used AI tools; ~40 % of the weekly
  top 100 recommended games are under 3 months old; >70 % of the top 100 by Robux spent bought Sponsored ads.
- Popular != profitable: Roblox's public "Top Earning" sort (Robux spent over 7 days; entry: >= 5,000 DAU or top
  10 %) had Steal An Egg #1 in players (~14.5 M DAU) but #4 in spending, Bloodlines (~51 K DAU) #9 [mesure 18/11].
  Top 10 spenders: median age 36 months; 29 of the top 30 are owned by groups; but 33 % of the 97 listed are under
  6 months old (new games enter from the bottom). Deep genres dominate spending (top 30: 8 action RPGs, 3 tower
  defense, 3 battlegrounds, 3 incremental, 3 "one vs all" survival...). Roblox itself says RPG / strategy / puzzle /
  shooter are under-supplied for older players.
- Other public sorts as radars: Up-and-Coming (< 28 days, growth), Top Trending, Top Revisited (a public RETENTION
  ranking: mostly old deep games), Fun with Friends (time in friend groups). Clones of a rising format appear in
  1-2 weeks.
- Weekly events give 5-30x spikes for 1-4 hours but do NOT raise the next day's average; almost every top game
  updates weekly, Friday or Saturday 14:00-20:00 UTC [mesure].
- Measure tool (in the user's other repo): `python -I .claude/skills/roblox-market-intel/scripts/game_intel.py
  top-earning 20 | charts 10 | snapshot <id>`; public sorts: `https://apis.roblox.com/explore-api/v1/get-sort-content
  ?sessionId=<uuid>&sortId=<top-earning|up-and-coming|top-trending|top-revisited|fun-with-friends>&device=computer&country=all`.

## How Roblox distributes games (§3) [P]
- Recommended For You counts ONLY players who came organically from RFY (per-user averages: a small game is not
  disadvantaged). Ads, friends, search, social traffic do not count in the ranking but can speed up being noticed.
- 28-day window (since 2026-06-15): day 1, days 2-7, days 8-28; first-session signals act at once.
- Most important signals: play-through rate after an impression, first-play bounce (< 60 s and 61-180 s), play
  days per user, playtime per user (capped at 60 min / player / game / day). Important: intentional co-play days
  (join, invites, private servers), qualified sessions, spend days, Robux spent. No published weights.
- Reduced exposure: gift / money titles, misleading metadata, no custom thumbnail, NON-UNIQUE games (metadata and
  place file close to an existing game: not prioritised; this also applies between the user's own games),
  safety violations.
- KIDS AND SELECT (`production/publishing/kids-and-select`): a NEW game starts in a trial open only to age-checked
  16+ accounts, and reaches Kids / Select accounts only after 250 unique plays by "highly engaged" players (age
  check + a minimum purchase on Roblox in the last 60 days + time in the game) within 60 days; it needs a refundable
  one-time fee or a Roblox Plus / Premium subscription. Ads Manager has an objective "Qualify for Kids and Select".
  -> Relevant to Beat the Ghost's small traffic: until it qualifies, only 16+ players can be shown it.
- Signal -> design table (§3.4): honest thumbnail promising the loop; first action without reading; a reason to
  come back tomorrow; several short sessions count as much as long ones; invites / private servers / group bonus;
  purchase moments on different days; a price ladder.

## Game design (§4)
- Roblox's own loop definition: minute-to-minute interaction, the most repeated set of actions, the progression
  engine. Four horizons [H]: micro (seconds), core (3-10 min, ends on a visible gain), meta (sessions: collection,
  zones, rarity), return (days: stock, crops, events) - "the player can say what they will do tomorrow".
- First session [P/H]: 0-10 s in the loop's first action, what the thumbnail promised; 10-60 s a first gain + an
  obvious next step; 1-3 min a full loop + first upgrade; 3-5 min short / mid / long goals visible; "fun in 5 minutes
  or less"; hints only to players who struggle, shown once; no text walls.
- Retention diagnosis [P]: weak D1 + high bounce = onboarding / performance / thumbnail mismatch; weak D7 =
  progression dries up or is unclear; weak D30 = no endgame (social, trading, groups, competition, collections,
  an update every 2-4 weeks, a big one every 2-3 months). Roblox publishes no universal %; the dashboard compares
  with similar games (needs >= 100 DAU).
- Paid randomness rules (`paid-random-items`) [P]: every outcome and its % shown, total exactly 100 %, applies to
  currencies bought with Robux and indirect keys / rerolls; luck / pity effects shown in numbers; no "nothing"
  outcome; read `PolicyService:GetPolicyInfoForPlayerAsync()` `ArePaidRandomItemsRestricted` and offer a compliant
  path (free path, fixed order, direct purchase at expected value, hidden). Maths [calc]: expected pulls 1/p, median
  ~0.693/p; at p = 1 %, 37 % still have nothing after 100 pulls; hard pity at N: mean (1-(1-p)^N)/p. Don't design for
  compulsion (young audience, Roblox pulled Steal An Egg for hours, regulation tightening).
- Social: "users become content for each other: solo games struggle"; a launch needs a loop playable alone + a co-op
  multiplier; filmable 10-30 s moments; a "hide the UI" option for creators [P].
- Live ops [P]: an update every 2 weeks to a month, < 3 weeks of effort each, on EXISTING systems; content as data;
  fixed calendar; limited items that leave with the update.
- Shop [P]: soft + hard currency; never require Robux for a mission; contextual purchase moments, no stacked pop-ups;
  starter pack in the first minutes but not on the very first load; season pass ~10 tiers / ~1 month, free + paid
  tracks; balance sources and sinks before each event; test prices with Experiments.
- Pitfalls: meme-bound games, clone waves, perceived pay pressure in social games, event currency inflation, long
  tutorials, unsustainable cadence, algorithm dependence (reports of 400-500 CCU falling to ~100 after June 2026 [S]).

## Money (§5) [P unless marked]
- Creator keeps 70 % of Robux spent; DevEx $0.0038 / Robux (30,000 Robux = $114 minimum); US 18+ rate $0.0054 for
  purchases by verified US adults ONLY if the game is 100 % R15 (since 2026-06-08). ~21 cents of each player dollar
  reach the creator (~30 cents at the 18+ rate) [calc, Robux ~$0.0125 [S]].
- Platform averages [calc]: $0.134 bookings and $0.032 DevEx per player-day (pulled up by the biggest games).
  Ceiling table: 1,000 DAU at 100 % of the average ~ $950 / month DevEx, at 10 % ~ $95.
- Ads pay back only if DevEx per play (active days A x monetisation fraction f x $0.032) > cost per play
  ($0.0073-$0.0187 in 2025 [S]; $0.008 for Plays per Roblox 2025-08-05 [P]); 2026 costs unknown. Roblox's rule:
  get D1 / D7 to similar games' level BEFORE paying for acquisition.
- Levers with exact conditions: Roblox Plus bonus up to 750 Robux per new subscriber (`PromptRobloxSubscriptionPurchase`,
  check `HasRobloxSubscription` server side; Roblox pays the member discount); Audience Expansion 35 % of a new /
  returning (60+ days) user's first $100 over 60 days via share link / direct link / exact-name search, if >= 10 min
  that day and the game averages >= 100 DAU for 60 days; daily engagement reward 5 Robux per Active Spender per day;
  rewarded video from 2,000 unique visitors / month (13+, ID-verified); paid private servers; selling models / plugins
  for dollars at 100 % of net; regional pricing on by default (never hard-code prices: read them through
  MarketplaceService).
- Pass ladders of the top earners [mesure 18/11]: mass games 2 cheap passes (Steal An Egg 299-467: x2 money, x2
  growth); deep games 4-23 passes, top tier 800-8,000 Robux (Tower Defense Simulator 23 passes 55-7,999; AoT
  Revolution 12 passes 79-4,149; Bloodlines 13 passes 149-999). Developer product sales are invisible from outside.
- Monetise in two steps (S6): before launch only economy telemetry + a reviewed ProcessReceipt skeleton; after the
  first retention proof 2-3 simple passes, then a ladder (consumables, expression, season pass, subscription); Plus
  prompt after a success moment; rewarded video at 2,000 visitors / month.

## Technique (§6) [P]
- Server decides money, damage, inventory, rolls, rewards; validate every remote argument (type, bounds, NaN), rate
  limit (token bucket); purchases only through one idempotent ProcessReceipt (PurchaseGranted after the save).
- Data stores: name / key / scope 50 chars, value 4 MB, per key 25 MB/min read 4 MB/min write; budget reads
  300 + 40 x CCU / min, writes 300 + 20 x CCU / min (UpdateAsync uses both); queue 30; storage 500 MB + 1 MB per user.
  MemoryStore: 64 KB + 1.2 KB x players; 1,000 + 120 x players requests / min; one sorted map / queue <= 1 M items,
  100 MB, one partition (~30,000 units / min). MessagingService: 1 KB messages, 600 + 240 x players / min per server.
- Performance: 60 fps = 16.67 ms a frame; event-driven code; don't put everything in ReplicatedStorage; test on a
  modest reference phone; streaming on; passive income = timestamp + rate computed on demand, not a loop per pet;
  `--!native` only for heavy pure functions (client: Android only).
- Analytics: <= 100 custom events (prefer one event with custom fields), <= 10 funnels, economy events by
  source / sink; dashboards: Home Recommendations, Audience Reach (Kids and Select progress), retention by source.
- ConfigService (<= 1,000 configs, change without republishing) and Experiments (2 variants + control, 3 custom
  metrics) for prices, amounts, hint timing. Feature Packages (missions, season pass, bundles, engagement rewards)
  exist, partly beta.

## Strategies S1-S12 (§7) and stop rules (§9)
S1 invisible engine, visible game (side-by-side page test); S2 target 16+ first (new games are 16+ anyway; deep
genres; 18+ rate); S3 a portfolio of 3-4-week experiments with stop rules; S4 calibrate with a small ad test
($50-150) before any budget, read retention BY acquisition source, aim for ~100 DAU to unlock benchmarks; S5 creator
partnerships aimed at people NOT yet on Roblox (Audience Expansion pays for those), share links per partner, a
filmable moment + hide-UI; S6 two-step monetisation; S7 weekly ritual, content as data; S8 a Roblox group (29 / 30 top
earners; Steal An Egg's group = ~41 % of its players and launched the next game; check the rules before rewarding
joins / likes); S9 tooling as speed (telemetry day 1, configs, off-Studio tests, daily chart radar); S10 apply to
Standout Games (hand-picked "new" games: deep mechanics, distinct look, under-served genre, console + mobile, R15,
events, trailer, localisation); S11 sell the base as a kit; S12 don'ts (clone metadata, meme games, rewarded feeds,
gift titles, hidden odds, ads-only growth, monetising before retention, pay-to-win in social games, unreviewed money
code, testing on production data stores, unaudited Toolbox models, an unsustainable cadence).
Gates [H]: G0 days 0-12 internal tests (3 outside testers finish the first loop unaided); G1 days 13-20 bounce, PTR,
onboarding, D1 on calibration traffic (2 rounds of fixes, else stop); G2 days 21-28 D7, play days, first purchases,
co-play; G3 day 29+ spend per active player, conversion, real acquisition cost: raise acquisition only if D1 and D7
hold and the §5.2 maths is positive. Never raise ads to rescue weak retention.

## Blind spots the author lists (§10)
Spending rank is not an amount; game age = creation date, not the last rework; badge-based DAU is an inference;
RFY weights unknown; 2026 ad costs unknown; "16+ first" rests on indirect evidence; the "variants" case is confounded
(the second game launched with the first one's audience); creator income base rates are secondary sources; the
"Claude solves about one Luau task in two at the first try" line has no found source (treat as a caution).
