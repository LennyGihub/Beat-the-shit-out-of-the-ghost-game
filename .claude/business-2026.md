# Running a Roblox game as a business (2026)

Learned from a French expert guide the user shared on 2026-11-23 ("Le business des jeux Roblox vibe-codés en 2026").
The numbers are that guide's claims (Roblox filings, RDC 2026, GameAnalytics, Naavik, DevForum...); they were not
checked. Read this before planning an update's monetization, retention, marketing, performance or compliance work.
Game-loop design itself is in `.claude/game-loops.md`.

**Where this game's own rules win over the guide**: Studio stays the source of truth (the guide prefers Rojo + Git);
no Roblox AI generation for models, scenes or textures (the guide praises Cube 3D / generate_mesh / Texture Generator);
touch targets stay >= 50 px (the guide says 44); no emoji.

## 1. The market

- 2025 was a boom (bookings $6.8B, +55%; Grow a Garden 22M CCU, Steal a Brainrot ~25M, 99 Nights ~14M). 2026 is
  calmer: Q3 2026 138M DAU (-9% a year), but the audience is older (18+ = 27% of verified users) and more
  international (France +12%, Japan +33%, India +37% DAU; Asia-Pacific 29.5% of DAU).
- Speed beats age: half of 2025's revenue came from games launched in 2025; most spending growth was outside the
  Top 10. 44% of the top 1,000 creators use AI agents.
- Two strategies: short-lived trend games ("brainrot": cash grabs that fade fast) versus lasting games updated every
  week (tycoons, simulators, co-op). Only the lasting kind builds retention and resale value. This game is the second
  kind: keep shipping weekly.
- Extreme power law: the median DevEx creator earns ~$1,500 a year; the top 1,000 average $1.4M.

## 2. Working with AI agents (what applies here)

- AI writes code that passes tests but has no fun in it: in Roblox's own study a prompt-built obby scored 98/100 on
  code, 100% on playtests, 31/100 on game design (0 on progression, replayability, agency, hook). Game design,
  retention and distribution are where the money is decided, not code.
- Agents lose the thread after ~20 hours on one project: keep CLAUDE.md rules with the *why*, small batches of 1-5
  related tasks, test before each commit, the smallest safe diff, never refactor what wasn't asked, check callers
  before deleting anything. Before a session: a named save point in Studio (File > Save to Roblox with Notes).
- Roblox Studio's MCP server reaches every open Studio window: close other places while an agent works.
- Only install editor extensions from verified publishers (a fake "Anthropic.claude-code" extension showed up on
  Cursor's marketplace in October 2026); read any community SKILL.md before using it.

## 3. Code, network, saves, security

- Knit is archived (no typed autocompletion, no Parallel Luau): plain `--!strict` ModuleScripts grouped by feature.
  Roact is deprecated.
- **Saves**: ProfileStore (successor of ProfileService) with **session locking**: UpdateAsync alone does not stop items
  being duplicated across servers (leave server A and join B before A has saved). Autosave ~300 s. Keys `User_{id}`
  (right-to-be-forgotten requests). BindToClose + pcall always. Quotas: per experience 300 + CCU x 40 reads/min and
  300 + CCU x 20 writes/min; per server 60 + players x 40 /min; 4 MB per key; don't pre-compress (Roblox compresses).
- **Robux purchases**: ProcessReceipt never returns PurchaseGranted before the save write is confirmed; remember the
  PurchaseIds already given inside the profile.
- **Network**: UnreliableRemoteEvent only for visual / throwaway data, 1,000 bytes max after compression (anything
  bigger is dropped silently). ~500 requests/s per client shared per remote type; aim under 25-50 KB/s per client.
  Never `RemoteFunction:InvokeClient()` (a client can hang the server thread forever). Blink (IDL over buffers) and
  Replica are the 2026 standard libraries if networking ever becomes a bottleneck.
- **Server Authority** (full release 2026-07-09): `Workspace.AuthorityMode = Server` with client prediction and
  rollback kills speed hacks, teleports and noclip. Trap: plain Luau variables are not restored on rollback; synced
  state must live in Attributes on predicted instances, and input must be read with `InputAction:GetState()`. A big
  migration: only if cheating becomes a real problem.
- **Security**: everything replicated to the client can be extracted and decompiled, so client-side anti-cheat and
  hiding code in LocalScripts protect nothing. The client sends an intent (an id, an action), never a fact (price,
  damage, amount, reward). Every OnServerEvent: check types, `math.isfinite(x)` on numbers (NaN / inf corrupt saves),
  bounds, distances, and a per-UserId token-bucket rate limit cleared on PlayerRemoving. Movement checks: rubber-band
  and a decaying suspicion score, not instant kicks (mobile players lag).

## 4. Retention (D1 / D7 / D30)

- Medians even among big games: D1 10.3%, D7 1.6%, D30 0.5%. Top 10%: D1 12.9-15.9%, D7 above 8%, D30 ~4.7% (top 1%).
  The median player opens Roblox 3 times a day for 22.4 min in total; 19+ minute sessions are where hits and big
  spenders appear.
- **D1 = the first 30-120 seconds**: straight into the gameplay, guidance without text (glowing trails on the floor,
  bouncing arrows, highlights), a first tangible win within a minute, no menu or shop blocking the screen.
- **D7 = depth**: timers on several scales (minutes / hours / days: shop restocks, offline progress shown on return,
  rebirths, unlockable classes); every currency source balanced by a sink that scales with the power curve (Grow a
  Garden had to re-price a seed from 21 billion to 200 trillion: inflation).
- **D30 = social + live ops**: roles that need each other, revives, visible competition (leaderboards), trading, and a
  weekly rhythm of limited events / "admin abuse" shows that bring everyone back at the same time.
- New concepts: MAYA (most advanced yet acceptable): a structure Roblox players already know + one strong twist
  (Dead Rails = Build a Boat + a dusty trip, in a zombie Wild West).
- Level design: discovery in four beats (safe intro, development, twist, conclusion); guide with sight lines, light and
  rewards, not text; every failure must feel like the player's mistake, never a collision bug; systemic variety
  (weather, rare mutations, procedural bits) makes the clips people share.

## 5. UI and mobile

- 44% of players use both mobile and PC, 11.5% mobile only, 40.8% PC only, 3.7% console; up to 68% of sessions are on
  mobile. Usable screen after notches, Roblox's bar and the thumbs: ~55% on a phone (80% tablet, 95% PC). Design for
  the phone first.
- Critical HUD (goal, money, health, progress) in the top third, placed with `GuiService:GetInsetArea()`; text >= 16 px;
  contrast >= 4.5:1; every button has default / hover / pressed / locked / loading states and a double-tap debounce.
- `UserInputService.PreferredInput` detects the active device live (tablet + Bluetooth gamepad); set
  `GuiObject.Selectable` + `SelectionOrder` so the gamepad can navigate.
- Native UI Styling (StyleSheet / StyleRule / StyleLink, `$tokens`, StyleDerive, `@StyleQuery` like CSS media queries,
  native transitions) is the 2026 base for responsive layouts and seasonal themes.
- Localization: turn on Auto-Localization at launch; scripted strings through one translator module
  (`LocalizationService:GetTranslatorForPlayerAsync()` in pcall).
- A co-op game must be fully understandable without text chat (pings, emotes, visual markers): chat now needs a face
  age check (6 age bands, under-9s get no chat), and social links show only on the game page to verified 13+.

## 6. 3D, light, audio, performance

- Reused free Creator Store models hurt click-through and can get a game flagged as not unique. Unoptimised meshes
  crash Android phones with under 2-3 GB of RAM within a minute.
- Unified Lighting (`LightingStyle` Realistic / Soft + `PrioritizeLightingQuality`) replaced `Lighting.Technology`.
- Guard rails for effects: Atmosphere.Density <= 0.35; Bloom Threshold >= 0.5 and Intensity <= 0.5; DOF NearIntensity
  0; Ambient RGB sum >= 15; at most 2 shadow-casting lights per room; no Glare indoors; CastShadow off on small and
  moving props.
- Budgets: under 500 scene draw calls (Ctrl+Shift+F2); reuse the same MeshId + SurfaceAppearance and vary `.Color`;
  turn Unions into MeshParts; stop particles at a distance. MeshPart cap 20,000 triangles. Decorations:
  `CollisionFidelity = Box` (collision geometry stays in memory even with CanCollide off), CanTouch / CanQuery off.
  `Workspace.EnableSLIMAvatars` (-93% avatar triangles, -60% memory).
- Streaming: StreamingEnabled, ModelStreamingBehavior Improved, StreamingIntegrityMode PauseOutsideLoadedArea,
  StreamOutBehavior Opportunistic, MinRadius 64, TargetRadius 1024. Hollow out voxel terrain (+15..48 FPS reported),
  avoid big terrain water, few Persistent models.
- Audio: the Audio API graph (AudioPlayer -> AudioEmitter / AudioDeviceOutput) over the old Sound object. Verified
  creators get 2,000 free audio uploads per 30 days (7 min max each). AI music is a legal risk: the uploader must
  indemnify Roblox. Suno caps downloads and is being sued, Udio blocks downloads; if ever needed, Stable Audio 3.0
  (licensed training data, commercial rights) or ElevenLabs Music (not "Studio Games" below its Enterprise plan). This
  game already uses Roblox's licensed APM / Pro Sound Effects library: keep doing that.

## 7. Money

- Roblox keeps 30% of every in-game sale (you get floor(price x 0.7): price = ceil(target / 0.7)). After the Robux
  purchase price and the DevEx rate, the creator keeps ~21-26 cents per dollar the player spends.
- DevEx: 30,000 earned Robux minimum, one cash-out per month. Standard rate $0.0038 per Robux. **US 18+ rate $0.0054
  (+42%)** on Developer Products, Game Passes, Subscriptions, Private Servers and Paid Access bought by verified US
  adults, **only if 100% of active play uses R15 avatars** (or custom rigs of 15+ parts, or no visible avatar): any
  option to switch to R6 disqualifies the game.
- Spending is very concentrated: 3.8% of players ever buy; median ARPPU per game $0.70 ($55 at p99); the top 1% of
  payers spend $86, over 4x the 95th percentile. Repeatable Developer Products + a ladder of 4-6 Game Passes
  (25 to 1,000+ R$), then:
  - **Subscriptions** (up to 50 per game): in local currency ($2.99-14.99) the creator gets 70% the first month and
    100% of the Robux value from the second (a $5 sub = 500 R$/month): the best yield on the platform.
  - **Creator Rewards** (replaced engagement payouts 2025-07-24): Daily Engagement Reward = 5 R$/day per active spender
    (>= $9.99 in 60 days) who plays >= 10 min with the game in their first 3 of the day. **Audience Expansion Reward =
    35% of the first $100 a new or returning (60+ days away) user spends anywhere on Roblox for 60 days, when they came
    through a Share Link, direct link or name search** and played >= 10 min (game needs >= 100 average DAU).
  - **Roblox Plus** ($4.99/month, replaced Premium for new subscribers 2026-04-30): Roblox pays its 10-20% member
    discounts (you keep 70% of the full price: read prices with `MarketplaceService:GetProductInfoAsync`, never hard
    code them); 250 R$/month for 3 months for each Plus subscription started from your game
    (`PromptRobloxSubscriptionPurchase`).
  - **Rewarded video ads** (Google, opt-in, 6-30 s, >90% completion): 20-27% of games using them got over 10% of
    revenue from them. Turn on "Exclude likely spenders". Needs a 13+ ID-verified account with 2FA and >= 2,000 unique
    visitors a month.
  - **Regional pricing** (+17% payers in Mexico, +26% Brazil, +52% Philippines in Roblox's tests); selling your own UGC
    avatar items in the game (70% total); licensed brands via License Manager (10-25% share).
- Order matters: no aggressive paywall on day 1. Fix retention first, then rework prices (an operator reports +120% to
  +1,038% payer conversion and up to +220% ARPDAU from that). Under 5-10k DAU a game is a lab at a loss or break-even;
  real profit starts between 10k and 50k DAU.

## 8. Discovery and marketing

- Growth is one chain: discovery -> first traffic -> retention -> monetization -> A/B optimisation. One weak link
  breaks it. Most AI-built games fail on distribution, not building.
- **Recommended For You** ranks only on players who came organically from it (paid / external traffic just gets the
  game into the pool). Since June 2026 QPTR is gone; the 8 signals:
  - most important: play-through rate, **first-play bounce rate** (players leaving in < 60 s and 61-180 s), play days
    per user (D1, D2-7, D8-28), playtime per user (capped at 60 min a day);
  - important: intentional co-play days (coming back to play with friends), qualified play sessions, spend days and
    Robux spent per user (D1, D2-7, D8-28).
- Penalties: no custom thumbnail (not eligible at all); titles / descriptions promising money or giveaways; thumbnail
  not matching the gameplay; non-unique games (too close to an existing game's files or metadata).
- Thumbnail Personalization: 2-5 thumbnails at 1920x1080; Roblox moves impressions hourly to the best one per age
  group (+8.5% qualified conversion on average, up to +50%). There is no A/B test for the square icon (512x512): test
  icon ideas as a thumbnail or in a small Ads Manager campaign first.
- **Roblox Moments** (short-video feed, all US users since RDC 2026): its JOIN button drops a viewer into your server
  in < 3 s. Feed it with the **Captures API** at the game's emotional peaks.
- TikTok / Shorts / YouTubers are still the strongest spark (Dead Rails went to 600k CCU after one 2M-view video).
  Use Share Links on every outside link (that is what pays the 35% Audience Expansion Reward).
- **Ads Manager** (used by 70%+ of the top 100 games): an ignition switch for the algorithm. Respect the 24 h learning
  phase; pay by card ($1 = 1 ad credit), never with Robux (bad rate, and it spends your US 18+ Robux first).
- Measure: `AnalyticsService` on the server (`LogOnboardingFunnelStepEvent` with steps that only go up, so exploiters
  can't fake them; `LogEconomyEvent` for every source and sink). A/B tests with ConfigService + Experiments: it runs
  on the server, so pass the variant to clients through Player attributes, always have safe defaults; results are
  rarely significant under 1,000 DAU.

## 9. Compliance, IP, tax, selling

- **Paid random items**: since June 2026 PEGI rates any new EU game with paid random items (gacha, eggs, wheels,
  odds boosters) PEGI 16 minimum; Belgium bans them. Any randomness bought with Robux, **or with a currency that can
  be bought with Robux**, must check `PolicyService:GetPolicyInfoForPlayerAsync()` on the server: when
  `ArePaidRandomItemsRestricted` is true, offer a direct purchase, a disclosed fixed order, or a free path instead;
  check `IsPaidItemTradingAllowed` before letting such items be traded.
- **AI and copyright** (US: Thaler v. Perlmutter, Copyright Office 2025): prompting alone does not make you an author.
  What protects the game: human creative input that can be shown (design decisions, Git history, the reworked code),
  business AI accounts that don't train on your input (don't paste economy tables or anti-cheat into consumer AI
  tools), AI clauses in every freelancer contract. Without that a buyer can't get IP warranties. Don't send DMCA notices
  for things you may not own (DMCA 512(f) liability).
- **Tax for a creator living in France** (general information: have an accountant confirm):
  - Since 2026-11-01 Roblox is the merchant of record and DevEx payments are **royalties** for the US. US-source income
    is withheld up to 30% by default (24% backup withholding on everything if tax info is missing), which erases the
    US 18+ bonus. Fix: Creator Hub > Finances > Taxes, a **W-8BEN** (individual / micro-entrepreneur) or **W-8BEN-E**
    (SASU / SARL) with the French tax id, claiming **article 12(1) (Royalties)** of the France-US treaty = 0%. Roblox
    sends a 1042-S each year.
  - VAT: Roblox is a US business, so invoices are outside French VAT ("TVA non applicable, art. 259-1 du CGI", plus
    art. 293 B under the franchise); no monthly DES for a US client.
  - Micro-BNC: ceiling EUR 83,600 (2026-2028), URSSAF 25.6% of gross turnover (27.8% with the flat tax option).
    SASU at corporate tax deducts every real cost (ads, AI subscriptions, freelancers, accounting) before 15% (up to
    EUR 42,500 profit) then 25%; dividends then pay the 31.4% flat tax. Switch to a SASU once projected yearly revenue
    passes ~EUR 40-60k or ads + freelancers exceed 20-25% of revenue.
- Publish under a **Roblox Group** (team payouts without a second 30% cut).
- **Selling the game**: native ownership transfer since Dec 2024; buyers (Voldex, Do Big Studios, Gamefam, Splitting
  Point, GameForge) pay 4-6x yearly profit or revenue for durable hits, half or less for middling ones; asset sales
  closed in 1-2 months with 2-3 month earnouts. Steady games sell better than spikes.
- Coming next: Roblox Everywhere (Roblox games as standalone PC executables on outside stores), instant browser play,
  the Roblox Card (2027).

## 10. Execution plan (the guide's four phases)

1. **Days 1-14, architecture + playable prototype**: Group, Git, MCP, CLAUDE.md, saves with session lock, R15 only,
   streaming set up, < 500 draw calls on a modest Android phone; familiar loop + one twist.
2. **Weeks 3-6, FTUE + retention** ($100-500 of card-paid ads): AnalyticsService on every step of the first 180 s,
   3-5 personalised thumbnails. Don't move on until the < 60 s bounce is under control and D1 nears 13-16% with
   15-19+ minute sessions.
3. **Months 2-6, monetization + virality** (10k-50k DAU): passes, products, a local-currency subscription, regional
   pricing, Roblox Plus, rewarded video (exclude likely spenders), PolicyService; a weekly live-ops calendar, Captures
   for Moments, TikTok / Shorts clips through Share Links, first ConfigService A/B tests.
4. **Month 6+, studio + tax + exit**: SASU, W-8BEN-E (art. 12), IP / AI clauses with every contractor, clean Git
   history.

## Where Beat the Ghost stands (checked in the code on 2026-11-23; nothing changed yet)

The user said "don't modify the game yet": this is a list for future updates, to propose, not to do unasked.

- **Paid random items, the biggest gap**: jars and potions roll a random form with in-game cash, and cash is sold for
  Robux (Config.CashPacks, Server/Monetization). By the rule above that is paid randomness, and forms can be traded
  (Server/Trade). There is no PolicyService call anywhere in the game. Needs an `ArePaidRandomItemsRestricted`
  path (cash packs hidden, or a fixed disclosed order / free path for jars and potions) and an
  `IsPaidItemTradingAllowed` check in trading. The odds are already shown in the seller panel (good).
- **R15 for the US 18+ DevEx rate**: the scripts don't force a rig; Client/FormLook still handles R6 limbs. Check the
  place's Game Settings > Avatar is R15 only (needs Studio). Since 2026-11-24 Main warns + logs analytics `R6Avatar`
  (RS attribute R6Seen) when anyone spawns as R6.
- **Saves**: Server/Data writes a whole snapshot with UpdateAsync, no session lock. With trading and form copies,
  a server hop before the old server's save could duplicate forms or cash. Worth a session lock (ProfileStore-style)
  before trading gets busy. Cash-pack and train-ticket receipts are already correct (granted only after a saved
  write, PurchaseIds kept in the save).
- **Analytics**: DONE 2026-11-24 (Server/Analytics: onboarding funnel, campaign progression, every cash change,
  first-minute custom events).
- **Monetization not used yet**: subscriptions, rewarded video ads, Roblox Plus prompt, regional pricing (Creator Hub
  setting), selling UGC items. Money2PassId and TripsProductId are still 0. Prices are read with `GetProductInfo`
  (UltShopUI, ReviveUI): the guide names `GetProductInfoAsync`.
- **Virality**: DONE 2026-11-24 (Server/Share + Client/ShareUI: INVITE button, share links, the 10-minute friend
  reward, SHARE THIS after a boss / a cleared building / an EPIC+ form). Not yet: video clips, the Moon giant rising.
- **First 60 seconds**: a new player starts on an all-black READY screen, then the intro. MEASURED since 2026-11-24
  (ReadySeconds, QuitBeforeReady, OnboardingQuit, IntroSkipped): change the screen only once the numbers say so.
- **Live ops**: no weekly event rhythm yet; codes and patch notes exist and can carry one.
- **Daily return**: DONE 2026-11-24 (week 1: login streak + shield + day 30 form, welcome jar, free daily samples, push
  notifications planned in game and sent by GitHub Actions once the user sets up the API key and notification strings).
- **Security**: DONE 2026-11-24 (Server/Guard on all 31 handlers; NaN holes fixed in Inventory.onUse, Tutorial
  spawn, the party size).
- **Performance**: phones start on LOW particles (Client/Settings); `tools/build/perf_pass.luau` APPLIED 2026-11-24
  (29,085 shadows off, 564 decor meshes boxed); streaming already had the guide's values. SLIM avatars and the
  avatar type can only be set by the user in Studio (scripts lack the capability).
- **Languages**: Client/Translate + tools/localization; the user still has to switch on automatic capture +
  translation and upload `patterns.csv`.
- **Controller**: fights and windows already worked; SELECT now reaches the lobby column (2026-11-24).
