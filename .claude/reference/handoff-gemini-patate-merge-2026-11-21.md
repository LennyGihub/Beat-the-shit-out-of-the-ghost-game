<!-- Copie stockée dans le dépôt public du jeu le 2026-11-24 : la note d'archive sur un autre projet (étude de marché d'une autre activité) a été raccourcie. Le reste est le texte d'origine. Ce handoff concerne le jeu « Patate Merge » (dépôt jeu-1-patate), pas Beat the Ghost. -->

# HANDOFF COMPLET GEMINI — Prompt Engineering & Développement Roblox « Patate Merge » (`jeu-1-patate`)

**Date du handoff :** 21 novembre 2026  
**Objet :** Transfert intégral et sans perte de contexte vers une nouvelle conversation Gemini.  
**Instruction pour le prochain Gemini :** Lis intégralement ce document avant de répondre. Il contient ton rôle exact, le socle méthodologique de prompt engineering actif, les données vérifiées du marché Roblox, le game design complet de *Patate Merge*, l'état d'avancement réel dans Claude Code (le Prompt 01 est déjà exécuté), l'intégralité des Prompts 02 à 10, ainsi que les points exacts à trancher avant d'envoyer le Prompt 02.

---

## 1. Rôle de Gemini & Protocole de Collaboration avec l'Utilisateur

1. **Rôle verrouillé :** Expert en Prompt Engineering (optimisation multi-modèles Gemini / Claude / Claude Code) et Architecte Technique / Débuggeur externe pour les projets de l'utilisateur.
2. **Standard d'exigence :** Raisonnement et explications de précision chirurgicale, honnêteté brute (signaler systématiquement les angles morts, contredire quand nécessaire, ne jamais flatter ni cacher un risque technique).
3. **Contrainte centrale côté utilisateur :** L'utilisateur travaille seul avec **Claude Code** sur un **forfait Claude Pro au quota limité**, tandis que ses comptes Google AI Pro (Gemini) servent d'atelier de conception, d'optimisation de prompts et d'audit/débogage externe pour économiser au maximum ses tokens Claude Pro.

### Protocole Opérationnel « Gate & Clear » (Travail avec Claude Code)
* **Quand l'utilisateur envoie les retours de Claude Code à Gemini :**
  * **Ne pas envoyer** si la phase passe les tests locaux (`luau-analyze.exe` / `luau.exe`), se déploie proprement (`tools/deploy_luau.py`) et réussit le test visuel de 2 minutes dans Studio.
  * **Envoyer impérativement** :
    1. Si Claude Code échoue après **1 seule tentative** de correction d'un bug (stopper Claude immédiatement, copier l'erreur de console — attention au décalage de ligne de $+1$ sur `tools/studio.py` — et le fichier `.luau` dans Gemini pour obtenir un patch chirurgical).
    2. Pour l'audit externe `critical` des 4 phases critiques : **Prompt 04** (DataStore), **Prompt 08** (Trading Anti-Dupe), **Prompt 09** (Patate Market) et **Prompt 10** (`ProcessReceipt` / Monétisation).
* **Pièges formellement interdits :**
  * **Jamais** demander à Claude Code de « prendre du recul et peaufiner » sans bug précis (provoque du *scope creep*, des régressions et double la consommation du quota Claude Pro).
  * **Jamais** enchaîner directement au Prompt $N+1$ si la phase $N$ présente un défaut (Claude Code ne remet pas en cause une étape précédente tant qu'elle ne crashe pas ; effet boule de neige).
* **Boucle obligatoire entre chaque prompt :**
  1. Exécution du Prompt $N$ dans Claude Code (qui intègre sa propre porte de validation automatique `GATE N`).
  2. Vérification humaine de 2 minutes dans Roblox Studio.
  3. Décision binaire : si défaut $\rightarrow$ patcher la phase $N$ ; si validé $\rightarrow$ lancer `tools/save_game.sh` (export Studio, carte, commit, push — indispensable car `/rewind` dans Claude Code n'annule pas les modifications faites dans Studio via MCP).
  4. Taper `/clear` (ou `/compact`) dans Claude Code pour repartir sur un contexte léger, puis coller le Prompt $N+1$.

---

## 2. Socle Méthodologique de Prompt Engineering (Verrouillé)

* **Architecture Cognitive Gemini (Amont / Volume & Recherche) :** Biais de primauté (rôle et règles critiques en tête), *Grounding Context* factuel strict + protocole de *fallback* (expliciter la méthodologie d'estimation si une donnée est non publique), exemples *Few-Shot* calibrés, et *Prompt Chaining* séquentiel pour éviter la compression des sorties.
* **Interopérabilité Claude & Claude Code (Aval / Stratégie & Exécution Critique) :** Structuration en balises XML sémantiques, longs corpus documentaires en haut et directives en bas, isolement du raisonnement (`<thinking>` ou `ultrathink`), directives exclusivement affirmatives, variables modulaires et portes de validation déterministes (`GATE`) intégrées dans chaque prompt.
* **Techniques Avancées Déployables :** *Step-Back Prompting*, *Tree-of-Thoughts*, *Reflexion & Auto-Critique (Constitutional Verification)*, *Structured Outputs* (JSON / XML / Markdown strict).

*(Note d'archive — Projet 1 clos dans cette conversation : une étude de marché pour une autre activité, déjà livrée ; détails retirés de cette copie publique.)*

---

## 3. Contexte Marché, Plateforme & Technique Roblox (Synthèse de `STRATEGIE-ROBLOX.md` — 18 nov. 2026)

### 3.1 Situation de la Plateforme & Distribution (Données officielles `[P]` et mesures `[mesure]`)
* **Macro T3 2026 (SEC 8-K du 2026-10-29) `[P]` :** 138 M DAU ($-9\%$ YoY, $+12\%$ QoQ), $\approx 34$ Md heures ($-15\%$ YoY), $1,7$ Md\$ de réservations ($-12\%$ YoY), DevEx $403$ M\$ ($-6\%$ YoY), prévision T4 réservations $-10\%$ à $-15\%$. $64\%$ des DAU contrôlés en âge ($34\%$ $<13$ ans, $37\%$ $13\text{--}17$ ans, $29\%$ $18+$ ans). $>80\%$ du top 100 utilise des outils IA ; $\approx 40\%$ du top 100 hebdomadaire RFY a $<3$ mois ; $>70\%$ du top 100 Top Earning fait de la pub Sponsored.
* **Rentabilité vs Popularité (`Top Earning` sur 7 jours) `[mesure 18/11]` :** Seuil officiel d'entrée $\ge 5\,000$ DAU (ou top $10\%$). Dans le top 10, le DAU varie d'un facteur $\approx 280$ (Bloodlines $\approx 51$ K DAU n°9 vs Steal An Egg $\approx 14,5$ M DAU n°4). $29/30$ propriétaires sont des groupes. $33\%$ du top 97 a $<6$ mois.
* **Algorithme « Recommended For You » (RFY) `[P]` :**
  * Seuls les joueurs arrivés **organiquement depuis RFY** comptent dans le classement (moyennes par utilisateur ; pub, amis, recherche et réseaux sociaux ne comptent pas dans le classement, mais peuvent accélérer la prise en compte).
  * Fenêtre de **28 jours** (J1, J2–7, J8–28).
  * **Signaux n°1 :** Taux de lancement (PTR), rebond de première session ($<60$ s et $61\text{--}180$ s, négatif), jours de jeu par joueur, temps de jeu (plafonné à $60$ min/joueur/jour/jeu).
  * **Signaux importants :** Co-jeu intentionnel, sessions qualifiées, jours de dépense, Robux dépensés.
* **Deux Barrières Critiques `[P]` :**
  1. **Kids and Select :** Un jeu neuf est uniquement montré aux comptes **$16+$ contrôlés** jusqu'à atteindre **250 lectures uniques de joueurs « très engagés » sur 60 jours** (contrôle d'âge + achat minimal dans les 60 jours + temps passé ; exige frais remboursables ou abonnement Plus/Premium).
  2. **Jeux non uniques :** Les jeux dont les métadonnées et le fichier de place ressemblent à un jeu existant perdent leur priorité RFY/recherche. Pour le futur programme de variantes de l'utilisateur : **moteur commun invisible, jeu visiblement différent**.

### 3.2 Économie, Monétisation & Réglementation `[P]`
* **Part créateur & DevEx :** $70\%$ des Robux dépensés ($30\%$ frais Marketplace). DevEx standard : $0,0038\text{ \$/Robux}$ (seuil $30\,000$ Robux $= 114\text{ \$}$).
* **Taux 18+ américain :** **$0,0054\text{ \$/Robux}$** ($+42\%$) pour les achats d'adultes US vérifiés **uniquement si le jeu est 100 % R15** (un seul accès possible à R6 disqualifie le jeu ; contrôle continu).
* **Économie unitaire `[calc]` :** $\approx 21$ cents par dollar dépensé arrivent au créateur ($\approx 30$ cents au taux 18+ US). Moyenne plateforme : $0,134\text{ \$}$ réservations/joueur-jour, $0,032\text{ \$}$ DevEx/joueur-jour.
* **Leviers vérifiés `[P]` :**
  * **Roblox Plus :** Remise joueur payée par Roblox ; prime jusqu'à $750$ Robux/nouvel abonné via `PromptRobloxSubscriptionPurchase` (blocage 60j).
  * **Audience Expansion (Creator Rewards) :** $35\%$ des $100$ premiers dollars sur 60 jours pour un nouvel utilisateur / retour 60j attribué par lien (exige $\ge 10$ min jour 1 et moyenne $\ge 100$ DAU pendant 60 jours).
  * **Vidéo récompensée :** Dès $2\,000$ visiteurs uniques/mois ($13+$ ID vérifié).
  * **Tarification régionale :** Activée par défaut ; **ne jamais coder les prix Robux en dur** (toujours lire via `MarketplaceService`).
* **Objets aléatoires payants (`paid-random-items`) `[P]` :** Afficher toutes les probabilités numériques (total exact $100\%$), aucun résultat « rien », chiffrer l'effet des boosts de chance/pitié, lire `PolicyService:GetPolicyInfoForPlayerAsync()` (`ArePaidRandomItemsRestricted`) et fournir une alternative conforme. **Tout produit Robux qui accélère indirectement des tirages de mutation (livraisons, vitesse de spawn, luck) doit passer cette revue de conformité.**

### 3.3 Limites Techniques, Règles du Dépôt & Chaîne d'Outils Locale
* **Statut de `jeu-1-patate` :** Test des capacités de Claude Code, hors du futur programme de variantes `shared/` (ne pas le forcer dans `shared/`).
* **Chaîne d'outils locale existante (`STRATEGIE-ROBLOX.md` §6.7) :**
  * Roblox Studio est la source de vérité ; Claude Code agit via le serveur MCP officiel de Studio et les scripts locaux : `tools/studio.py` (état, Play, Stop, console — **attention : numéros de ligne d'erreur décalés de $+1$**, scripts Edit/Server/Client, capture), `tools/deploy_luau.py` (syntaxe, détection de conflit, envoi uniquement en mode Edit), `tools/export_studio.py`, `tools/save_game.sh` (export, carte, commit, push).
  * Tests hors-Studio disponibles via `~/.cache/luau/luau.exe` et `~/.cache/luau/luau-analyze.exe` (les modules purs reçoivent leur source aléatoire en paramètre car `Random.new`/`Instance`/`game` n'existent pas hors Studio).
* **Règles strictes du dépôt (`.claude/roblox-rules.md`) :**
  * `--!strict` partout, `task.*`, modules entiers et petits, **pas de `_G`**, suffixe `_Studio` pour les DataStores en test.
  * Mobile d'abord : `Scale` (pas `Offset`), `TextScaled` + `UITextSizeConstraint`, `ResetOnSpawn = false`, `CoreUISafeInsets`, **pas d'émoji dans l'interface du jeu**.
  * R15 Only (paramètres avatar du projet).
  * Sécurité : validation de tous les arguments de `RemoteEvent` (`typeof`, bornes, rejet `NaN`/`math.huge`, rate-limiting token bucket) ; `ProcessReceipt` unique et idempotent par `PurchaseId` ; jamais de `PromptProductPurchaseFinished` côté serveur.
* **Quotas Cloud `[P]` :**
  * DataStore : nom/clé/portée $50$ car., valeur $4$ Mo, débit clé $25$ Mo/min lecture / $4$ Mo/min écriture, budget $300 + 40 \times \text{CCU}$ lectures/min et $300 + 20 \times \text{CCU}$ écritures/min (`UpdateAsync` consomme les deux), file max $30$ requêtes.
  * MemoryStore : $64\text{ Ko} + 1,2\text{ Ko} \times \text{joueurs}$ ; $1\,000 + 120 \times \text{joueurs}$ req/min.
  * Performance : budget 60 FPS $= 16,67$ ms/image, Instance Streaming activé, `UnreliableRemoteEvent` pour flux éphémères, télémétrie `AnalyticsService` (`LogOnboardingFunnelStepEvent`, événements d'économie sources/puits, max 100 événements perso, max 10 entonnoirs).

---

## 4. Game Design Exact de « Patate Merge » (`jeu-1-patate`)

*(Distillé depuis `PATATE_MERGE_10_PROMPTS_MCP.md` et corrigé/structuré avec l'utilisateur. Les prompts de ChatGPT ont été rejetés car ils interdisaient l'architecture propre, Rojo/dépôt/modules et manquaient de portes de validation.)*

1. **Espace & Cercle Vertical 2D :**
   * Bases Roblox 3D ouvertes et visitables par les autres joueurs (6 à 8 emplacements) autour d'une place centrale dédiée au **Patate Market**.
   * Sur le mur du fond de chaque base : un **grand cercle vertical en 2D** (`SurfaceGui`), inspiré en composition de `reference/reference_cercle.png` (sans copier aucun asset ni personnage), avec un grand compteur **SCORE** directement dessous.
   * Direction artistique cartoon Roblox lisible. **Important :** L'utilisateur créera tous les vrais sprites 2D et modèles 3D **à la toute fin**, une fois tout l'aspect technique finalisé. Tout le jeu doit donc reposer sur une architecture **Placeholder-First & Swap-Ready** centralisée dans un registre unique (`PotatoVisualRegistry.luau`).
2. **Boucle de Fusion 100 % Automatique :**
   * Les patates apparaissent automatiquement dans le cercle 2D, rebondissent/se déplacent en 2D et **fusionnent automatiquement** par paires de même niveau.
   * Zéro clic de placement, zéro manche, zéro défaite, zéro obby/combat/rebirth.
   * **Règle anti-blocage absolue :** Le cercle ne se bloque **jamais** s'il est plein. Gestion automatique d'une file de réserve (`OverflowQueue`) sans perte ni double gain ; lorsque la forme max est atteinte, stockage sûr en réserve et poursuite de la production.
   * **Formes :** 12 à 18 formes évolutives drôles/absurdes (fixé à **15** par défaut dans le Prompt 02, à confirmer).
3. **Séparation Étanche des 3 Ressources :**
   * **Score :** Gagné **uniquement** par les fusions dans le cercle. Permanent, jamais dépensé, jamais échangé, jamais donné par achat ou trade.
   * **Patacash :** Produit **uniquement** par les patates **exposées sur les vitrines/socles 3D** de la base. Sert à acheter les améliorations de base, les décors/personnalisations et les **livraisons spéciales garanties** (contenu exact connu avant achat, zéro lootbox cachée).
   * **Diamants :** 3e monnaie indépendante dédiée au **commerce entre joueurs** (Trading direct + Patate Market). Gagnée par objectifs quotidiens / paliers Patatedex (ni conversion Patacash, ni vitrines, ni vente en Robux au lancement).
4. **Propriété, Inventaire & Patatedex :**
   * Chaque patate appartient réellement au joueur ; impossible qu'elle existe simultanément dans la machine, la réserve, une vitrine, un trade et un stand Market.
   * **Patatedex permanent** (même après vente ou fusion), distinguant « découverte par fusion » vs « obtenue via échange » (une patate reçue par échange/achat ne donne jamais de Score).
5. **Mutations & Voix IA (Signature Virale) :**
   * **Mutations (`Golden`, `Rainbow`, `Lightning`) :** Simples effets visuels superposés au skin normal (1 mutation principale max par patate, pas d'héritage automatique). Tirage RNG **strictement en ligne** lors d'une fusion.
   * **Auto-protection par défaut (`isLocked = true`)** contre la fusion automatique.
   * **Double choix stratégique :** Exposée en vitrine = multiplie le Patacash/s ; déverrouillée et sacrifiée en fusion = multiplie le Score ponctuel de cette fusion (si 2 mutées fusionnent, on applique le **meilleur** multiplicateur `math.max`, jamais le produit).
   * **Voix synthétique (`AudioTextToSpeech`) :** Annonce théâtrale lors de la première découverte d'une forme rare ou d'une mutation très rare (titre animé, effets, option mute/volume, pas de spam à chaque fusion, sans bloquer l'économie).
6. **Progression Hors-Ligne :**
   * Rendement réduit à **25 %**, plafonné à **6 heures** ($21\,600$ s), calculé une seule fois côté serveur à la reconnexion. **Zéro mutation hors-ligne**, zéro Diamant hors-ligne.
7. **Trading Direct & Patate Market :**
   * **Trading direct :** Tous niveaux autorisés, patates d'inventaire + Diamants, réinitialisation des confirmations sur toute modification + délai de sécurité anti-scam, commit atomique anti-dupe, annulation propre sur déconnexion.
   * **Patate Market :** Inspiré de *PETS GO!* uniquement sur 3 piliers : stands physiques 3D, recherche/filtrage (forme, niveau, mutation, prix), monnaie d'échange Diamants. Prix fixes au lancement, commission de marché configurable ($5\%$ en test), achat atomique anti-price-baiting et anti-double-achat. Marché local serveur fiable d'abord (interserveurs désactivé tant que la cohérence multi-serveurs n'est pas prouvée).
8. **Monétisation Prudente & Recette Finale :**
   * Cosmétiques / thèmes / passes de confort (jamais de Score ni Diamants ; revue stricte `paid-random-items` + `PolicyService` pour tout accélérateur indirect de mutation ; pas de faux IDs de passes/produits).
   * Télémétrie exploitable (`AnalyticsService`) + option « masquer l'interface » pour créateurs vidéo + conformité 100 % R15.

---

## 5. État Exact d'Avancement dans Claude Code

* **Prompt 01 : DÉJÀ EXÉCUTÉ par Claude Code.**
  * Ce Prompt 01 (issu de la première génération) n'avait aucune logique de gameplay erronée : il a uniquement posé la colonne vertébrale technique propre :
    * `src/shared/core/Loader.luau` (démarrage en 2 phases : `Init` synchrone sans yield, puis `Start` asynchrone),
    * `src/shared/util/Trove.luau` & `Signal.luau` (compatibles `Workspace.SignalBehavior = Deferred`),
    * `Main.server.luau` & `Main.local.luau` (points d'entrée uniques),
    * Validation locale `--!strict` + chaîne MCP/Studio.
* **Prompt 02 à 10 : PAS ENCORE LANCÉS.**
* **Intégration :** Tous les services de *Patate Merge* des Prompts 02 à 10 se branchent directement sur le `Loader.luau` et `Trove.luau` créés au Prompt 01.

### Points d'Harmonisation Détectés (À vérifier/ajuster avant de lancer les Prompts 02–10)
1. **Règle Zéro Émoji en UI (`.claude/roblox-rules.md`) :** Dans le texte du Prompt 06 ci-dessous figure `🔒 Protégée` — le remplacer par une icône UI vectorielle ou du texte pur `[PROTEGEE]` avant envoi à Claude Code.
2. **Règle R15 Only & Analytics (`STRATEGIE-ROBLOX.md`) :** Ajouter explicitement dans les Prompts 02/10 la vérification `Avatar = R15 Only` (pour le taux DevEx 18+ US), l'instrumentation `AnalyticsService` (`LogOnboardingFunnelStepEvent` + événements d'économie sources/puits) et le bouton « Masquer l'UI » pour créateurs TikTok/YouTube.
3. **Conformité `paid-random-items` dans le Prompt 10 :** Le Prompt 10 ci-dessous liste `LuckyMutationPass` et `FastCircleSpawnPass` — rappeler fermement à Claude de **ne pas activer** de boost de chance ni d'accélérateur de mutations payant au lancement sans revue `PolicyService` (`ArePaidRandomItemsRestricted`) et sans IDs réels créés par l'utilisateur (conformément au brief d'origine), et de toujours lire les prix via `MarketplaceService` (tarification régionale).
4. **Commission de marché ($5\%$) dans le Prompt 09 :** Le brief initial prévoyait une commission configurable de $5\%$ (paramètre de test) sur les ventes du Patate Market (puits de Diamants anti-inflation) ; à confirmer avec l'utilisateur si on l'intègre directement au Prompt 09.
5. **Fusions ordinaires hors-ligne dans le Prompt 07 :** Notre Prompt 07 actuel limite le hors-ligne au seul **Patacash des vitrines** ($25\%$, plafond 6h, zéro mutation) pour maximiser la sécurité. Le brief initial évoquait aussi la simulation des fusions ordinaires hors-ligne à $25\%$ (sans mutation). À trancher avec l'utilisateur.

---

## 6. Intégralité des Prompts 02 à 10 (Verbatim)

### PROMPT 02 / 10 — Pont Architectural, Catalogue des 15 Patates (Placeholders Procéduraux), Bases 3D Ouvertes et Cercle Vertical 2D

~~~text
ultrathink
Nous passons à l'Étape 2/10 de « Patate Merge » (`jeu-1-patate`). Conserve intégralement l'architecture créée au Prompt 1 (`Loader.luau` en 2 phases `Init`/`Start`, `Trove.luau`, `Signal.luau`, `Main.server.luau`, `Main.local.luau` et `Workspace.SignalBehavior = Deferred`). Nous branchons maintenant le vrai cœur visuel et spatial de « Patate Merge » sur ce socle. Be ambitious sur la propreté modulaire et la fluidité à 60 FPS.

### 1. Règles Fondamentales du Game Design & des Visuels Placeholders
- **Pas de grille 3D manuelle** : Le jeu repose sur des **bases 3D ouvertes** attribuées aux joueurs autour d'une place centrale. Au fond de chaque base se dresse un **grand mur portant un Cercle Vertical en 2D** (`SurfaceGui`) avec l'afficheur **SCORE** juste en dessous.
- **Visuels Placeholders Swap-Ready** : Les sprites 2D et modèles 3D définitifs seront importés à la toute fin du projet. Tu dois isoler tous les visuels dans un registre unique (`PotatoVisualRegistry.luau`) qui génère des **placeholders procéduraux ultra-lisibles** (couleurs distinctes, `UICorner`, `UIStroke`, `UIGradient`, numéro de palier `Lv.1` à `Lv.15` et nom) dès qu'aucun `AssetId` n'est renseigné.
- **Séparation Stricte des 3 Ressources** :
  1. `Score` : Gagné UNIQUEMENT par les fusions dans le cercle. Permanent, jamais dépensé, jamais échangé.
  2. `Patacash` : Produit UNIQUEMENT par les patates exposées sur les **vitrines/socles 3D** de la base.
  3. `Diamants` : 3e monnaie indépendante réservée au Trading et au Patate Market.

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/domain/PotatoCatalog.luau` (gelé par `table.freeze`) :
   - Définit les **15 formes évolutives de Patates** (Niveau 1 : *Patate Terre* jusqu'au Niveau 15 : *Patate Cosmique Souveraine*) avec : `level: number`, `id: string`, `displayName: string`, `mergeScoreReward: number`, `showcasePatacashPerSec: number`, `radius2D: number` (rayon normalisé dans le cercle 2D), `baseColor: Color3`, `rarityTier: string`.
   - Définit les **3 Mutations** (`None`, `Golden`, `Rainbow`, `Lightning`) avec leur probabilité de tirage en ligne, leur multiplicateur de `Patacash/s` en vitrine (ex: x1, x3, x8, x20) et leur multiplicateur de `Score` ponctuel non cumulatif en cas de sacrifice lors d'une fusion (ex: x1, x2.5, x6, x15).
2. `src/shared/domain/PotatoVisualRegistry.luau` :
   - Table de correspondance `{[number]: { sprite2DAssetId: string, model3DName: string, primaryColor: Color3, accentColor: Color3, label: string }}`.
   - Fonction `create2DPotatoNode(level: number, mutation: string): Frame` : construit un disque 2D procédural propre (`UIAspectRatioConstraint = 1`, `UICorner = 1`, contour `UIStroke` spécifique à la mutation, texte du niveau et nom court) ou affiche l'`ImageLabel` si `sprite2DAssetId ~= ""`.
   - Fonction `create3DShowcaseModel(level: number, mutation: string): Model` : construit un modèle 3D procédural propre (forme géométrique/patate stylisée + aura/matériau de mutation + `BillboardGui` affichant le nom, la mutation et le taux de `Patacash/s`) prêt à être posé sur un socle 3D.
3. `src/server/services/BasePlotService.luau` (enregistré dans `Loader.luau`) :
   - Génère au démarrage (`Init`) 6 bases 3D ouvertes disposées harmonieusement autour d'une place centrale (qui accueillera plus tard le Patate Market).
   - Chaque base comprend :
     - Un sol délimité ouvert, une pancarte au nom du joueur, et un point de spawn.
     - Sur le mur du fond : un panneau vertical portant la `SurfaceGui` du **Cercle Vertical 2D** (`CanvasSize = Vector2.new(800, 800)`, `SizingMode = Enum.SurfaceGuiSizingMode.FixedSize` pour une netteté constante) et, juste en dessous, le grand panneau d'affichage **SCORE : 0**.
     - Dans la cour de la base : une rangée de **8 Socles / Vitrines 3D** (`Showcases`, dont 3 débloqués par défaut et 5 verrouillés à acheter en Patacash).
   - Assigne une base libre à chaque joueur sur `Players.PlayerAdded` (et joueurs déjà présents), pose `player:SetAttribute("PlotId", plotId)`, et nettoie la base sur `Players.PlayerRemoving` via `Trove`.
4. `src/shared/domain/CircleKinematics2D.luau` & `src/client/controllers/CircleDisplayController.luau` :
   - Mathématique 2D pure en coordonnées normalisées `[-1, 1]` à l'intérieur du cercle unité (x^2 + y^2 <= (1 - r)^2).
   - Gère le mouvement continu, la gravité douce ou dérive rebondissante et le rebond élastique parfait contre la paroi circulaire du grand cercle vertical à 60 FPS (`RunService.RenderStepped`), en recyclant les `Frame` 2D via un pool d'objets UI.
5. `tests/domain/CatalogAndKinematics.spec.luau` :
   - Test unitaire hors-Studio vérifiant : (a) la croissance strictement monotone de `mergeScoreReward` et `showcasePatacashPerSec` sur les 15 niveaux, (b) qu'une patate rebondissant pendant 1 000 pas de simulation dans `CircleKinematics2D` reste toujours strictement à l'intérieur du rayon du cercle (d <= 1 - r) sans jamais produire `NaN`.

### 3. Déploiement & Porte de Validation Déterministe (GATE 2)
1. Exécute les vérifications locales (analyse statique/types `--!strict` + tests unitaires `CatalogAndKinematics.spec.luau`). Exigence : 0 erreur, 100 % des tests passés.
2. Déploie dans Studio (`python3 tools/deploy_luau.py` ou outil de synchronisation actif).
3. Lance un playtest via `python3 tools/studio.py` (ou MCP `start_stop_play` avec `studio_id`). Vérifie que : (a) le joueur apparaît devant sa base 3D ouverte assignée, (b) le grand cercle vertical 2D et l'afficheur SCORE sous le cercle sont clairement visibles sur le mur du fond, (c) des patates de test rebondissent de façon fluide à l'intérieur du cercle 2D sans en sortir, (d) `get_console_output` affiche 0 erreur. Prends un `screen_capture` face au mur du fond de la base.
~~~

### PROMPT 03 / 10 — Moteur de Fusion 100 % Automatique en Cercle, File de Réserve Sans Blocage et Compteur de Score

~~~text
ultrathink
Nous passons à l'Étape 3/10 de « Patate Merge ». Nous implémentons le moteur serveur-autoritaire de **fusion 100 % automatique et continue** dans le cercle vertical 2D, la file d'attente anti-blocage (`OverflowQueue`) et la comptabilisation exclusive du **Score**. Be ambitious sur l'exactitude mathématique (zéro perte de patate, zéro double gain).

### 1. Règles Métier Inviolables de la Boucle de Cercle
- **Fusions 100 % Automatiques** : Les patates apparaissent automatiquement dans le cercle à intervalle régulier (`spawnInterval`), se déplacent et rebondissent en 2D. Dès que deux patates de **même niveau** (L < 15) et **non protégées** entrent en contact (ou après un temps de convergence maximal dans le cercle), elles fusionnent automatiquement en une patate de niveau L + 1 sans aucun clic de placement ni système de manches.
- **Zéro Blocage Quand le Cercle est Plein (`OverflowQueue`)** : Si le nombre d'entités actives simultanées dans le cercle atteint `maxCircleCapacity` (ex: 12 patates simultanées), le jeu ne doit **jamais se bloquer ni perdre de patate** :
  1. Le serveur tente d'abord une **fusion prioritaire instantanée** parmi deux patates de même niveau déjà présentes dans le cercle pour libérer une place.
  2. Si aucune paire n'est fusionnable dans le cercle, la nouvelle patate générée est placée dans une **File de Réserve Sûre (`reserveQueue`)** affichée par un badge `Réserve : +N` au bord du cercle, et s'insère automatiquement dès qu'une fusion ou une mise en inventaire/vitrine libère un emplacement.
- **Unicité du Score** : Chaque fusion réussie vers le niveau L + 1 crédite exactement `PotatoCatalog[L + 1].mergeScoreReward` au **Score** du joueur. Aucune autre action du jeu ne doit jamais ajouter ni retirer du Score.

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/domain/AutoMergeEngine.luau` :
   - État pur du cercle d'un joueur : `activeUnits: {[string]: CirclePotatoUnit}`, `reserveQueue: {QueuedPotato}`, `maxCircleCapacity: number`, `spawnLevel: number`, `spawnInterval: number`, `mergeSpeedMultiplier: number`, `totalScore: number`, `totalMerges: number`.
   - Fonctions pures et déterministes :
     - `tickSpawner(state, dt: number): SpawnOutcome` (gère l'apparition ou l'envoi en `reserveQueue` + le dépilage automatique de la réserve dès qu'une place se libère).
     - `stepAutoMerges(state, dt: number): {MergeEvent}` (détecte les collisions/paires de même niveau éligibles à la fusion, consomme exactement les deux unités sources — rendant mathématiquement impossible toute double fusion d'une même unité dans la même trame —, crée l'unité L + 1 au point d'impact, ajoute le gain de `Score` et retourne la liste des événements de fusion).
2. `src/server/services/CircleMergeService.luau` (enregistré dans `Loader.luau`) :
   - Exécute la simulation autoritaire du cercle de chaque joueur connecté, synchronise les apparitions et fusions vers le client par paquets deltas compacts, et met à jour en temps réel l'afficheur **SCORE** sous le cercle vertical ainsi que `player.leaderstats.Score`.
3. `src/client/controllers/CircleDisplayController.luau` (mise à jour) :
   - Anime l'attraction magnétique finale et le flash/rebond 2D lorsque deux patates fusionnent dans le cercle vertical, affiche un texte flottant `+Score` au point de fusion, et met à jour le badge `Réserve : +N` et le compteur `Actives : X / Y`.
4. `tests/domain/AutoMergeEngine.spec.luau` :
   - Tests unitaires hors-Studio prouvant :
     - Qu'une unité engagée dans une fusion ne peut jamais fusionner deux fois (verrou d'unicité d'UID).
     - Que si le cercle est plein avec des niveaux tous différents (`Lv.1, Lv.2, Lv.3...`), 50 apparitions supplémentaires vont dans `reserveQueue` sans erreur, et se vident proprement sans perte ni doublon dès que des fusions se débloquent.
     - Que le `totalScore` correspond exactement à la somme mathématique des fusions effectuées.

### 3. Déploiement & Porte de Validation Déterministe (GATE 3)
1. Exécute l'analyse statique `--!strict` et la suite de tests `AutoMergeEngine.spec.luau` hors-Studio. Exigence : 0 erreur, 100 % des tests verts.
2. Déploie dans Studio et lance un playtest (`tools/studio.py` / MCP).
3. Simule un débit d'apparition accéléré pendant 10 secondes pour saturer volontairement le cercle : vérifie que les fusions s'enchaînent automatiquement, que la réserve absorbe le surplus sans jamais bloquer le cercle, que le compteur **SCORE** sous le cercle grimpe exactement du montant des fusions, et que `get_console_output` affiche 0 erreur.
~~~

### PROMPT 04 / 10 — Inventaire, Vitrines 3D Productrices de Patacash, Patatedex et Persistance Crash-Proof (`_Studio` DataStore)

~~~text
ultrathink
Nous passons à l'Étape 4/10 de « Patate Merge ». Nous connectons le cercle de fusion à l'**Inventaire**, aux **Vitrines/Socles 3D** de la base (seule source de **Patacash**), au **Patatedex** (collection) et à la sauvegarde serveur robuste avec séparation automatique `_Studio` / Production. Be ambitious sur l'intégrité des données.

### 1. Règles Métier : Vitrines Patacash, Inventaire & Patatedex
- **Collecte & Équipement en Vitrine 3D** : Les patates créées ou extraites du cercle rejoignent le stock du joueur (ou peuvent être envoyées directement sur un socle libre). Le joueur dispose de **Socles / Vitrines 3D** dans sa base.
- **Unicité du Patacash** : **Seules les patates exposées sur les vitrines 3D de la base produisent du `Patacash` par seconde** (`Patacash/s`). Une patate qui tourne encore dans le cercle 2D ou qui dort dans l'inventaire produit `0 Patacash/s`.
- **Bouton « Équiper les Meilleures » (`EquipBest`)** : Place automatiquement sur les socles 3D débloqués du joueur ses patates ayant le plus haut rendement `Patacash/s` (en tenant compte du niveau et de la mutation) et met à jour instantanément les modèles 3D posés sur les socles de la base.
- **Patatedex** : Enregistre chaque niveau de patate (1 à 15) et chaque variante de mutation découverte au moins une fois par le joueur.

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/domain/ProfileSchema.luau` & `src/server/data/Migrate.luau` :
   - Schéma versionné (`SCHEMA_VERSION = 1`) contenant :
     - `score: number` (permanent)
     - `patacash: number`
     - `diamonds: number`
     - `circleState: SerializedCircleState` (patates actives dans le cercle + file de réserve)
     - `inventory: {[string]: PotatoItem}` (`uid`, `level`, `mutation`, `isLocked`, `createdAt`)
     - `showcases: { maxUnlockedSlots: number, equippedUids: {[number]: string} }`
     - `upgrades: {[string]: number}`
     - `patatedex: { discoveredLevels: {[number]: boolean}, discoveredMutations: {[string]: boolean}, claimedMilestones: {[string]: boolean} }`
     - `dailyObjectives: SerializedDailyState`
     - `processedReceipts: {string}`
     - `lastOnlineTimestamp: number`
   - Fonction pure `Migrate.reconcile(rawData)` garantissant la compatibilité ascendante sans perte.
2. `src/server/services/DataService.luau` (enregistré dans `Loader.luau`) :
   - Utilise un suffixe de DataStore dynamique : si `RunService:IsStudio()` est vrai, utilise `"PatateMerge_Profile_v1_Studio"` (avec fallback transparent sur un `MockDataStore` en mémoire si l'accès API Studio est désactivé), sinon `"PatateMerge_Profile_v1_Prod"`.
   - Verrouillage de session via `UpdateAsync`, refus strict d'écraser un profil si le chargement initial a échoué (`player:GetAttribute("DataLoaded") == false`), sauvegarde automatique périodique, sauvegarde sur `PlayerRemoving` et sauvegarde parallèle dans `game:BindToClose()`.
3. `src/server/services/ShowcaseService.luau` (enregistré dans `Loader.luau`) :
   - Gère l'exposition des patates sur les socles 3D de la base du joueur (`equipToShowcase`, `unequipFromShowcase`, `equipBestShowcases`).
   - Instancie/recycle les modèles 3D issus de `PotatoVisualRegistry.create3DShowcaseModel` sur les socles physiques de la base avec un `BillboardGui` indiquant `Lv.X — +Y Patacash/s`.
   - Boucle serveur 1 Hz créditant exactement la somme des `Patacash/s` des socles occupés au solde `patacash` du joueur et mettant à jour `leaderstats.Patacash`.
4. `src/client/controllers/InventoryAndDexController.luau` :
   - Interface claire ouvrable depuis le HUD pour consulter son Inventaire (équiper/retirer d'une vitrine, bouton « Équiper les Meilleures ») et son **Patatedex** (grille des 15 formes avec silhouettes verrouillées/déverrouillées).
5. `tests/domain/ShowcaseAndData.spec.luau` :
   - Tests unitaires hors-Studio vérifiant : (a) que seules les patates équipées dans `showcases.equippedUids` contribuent au calcul de `Patacash/s`, (b) qu'une même patate (`uid`) ne peut jamais être équipée sur deux socles à la fois, (c) que `equipBest` sélectionne mathématiquement la combinaison optimale, (d) que `Migrate.reconcile` préserve 100 % des données d'un profil existant.

### 3. Déploiement & Porte de Validation Déterministe (GATE 4)
1. Passe l'analyse statique `--!strict` et les tests unitaires hors-Studio.
2. Déploie dans Studio et lance un playtest (`tools/studio.py` / MCP).
3. Vérifie sur le serveur que : (a) lorsque les socles 3D sont vides, le gain de Patacash/s est de `0`, (b) dès que `equipBestShowcases` est appelé après quelques fusions, les modèles 3D apparaissent sur les socles de la base et le compteur `Patacash` augmente chaque seconde du montant exact affiché, (c) le Patatedex marque bien les niveaux fusionnés comme découverts, (d) un cycle de sauvegarde/rechargement conserve intégralement le Score, le Patacash, le cercle, l'inventaire et les vitrines, avec 0 erreur console.
~~~

### PROMPT 05 / 10 — Pare-Feu Réseau Zéro-Trust, Boutique Patacash (Améliorations, Décors & Livraisons Spéciales Garanties)

~~~text
ultrathink
Nous passons à l'Étape 5/10 de « Patate Merge ». Nous verrouillons la couche réseau Zéro-Trust (`Guards` + `NetRouter`) et nous implémentons toutes les dépenses de **Patacash** : Améliorations de base, Décors évolutifs et **Livraisons Spéciales Garanties** (sans aucune lootbox aléatoire). Be ambitious sur la sécurité anti-exploit.

### 1. Règles Métier de la Boutique Patacash
- **Zéro Confiance Client** : Le client n'envoie jamais un prix, un niveau ou une quantité de monnaie. Il envoie uniquement l'identifiant stable de l'action (`upgradeId`, `deliveryTierId`, `decorId`).
- **3 Puits de Dépense en Patacash (`Patacash Sinks`)** :
  1. **Améliorations de Base (`BaseUpgrades`)** :
     - `SpawnSpeed` (réduit l'intervalle d'apparition dans le cercle)
     - `BaseSpawnLevel` (augmente le niveau initial des patates qui apparaissent dans le cercle)
     - `CircleCapacity` (augmente le nombre maximal de patates simultanées dans le cercle 2D)
     - `CircleBounceMergeSpeed` (accélère la vitesse de déplacement et de rencontre dans le cercle)
     - `UnlockShowcaseSlot` (débloque les socles de vitrines 3D supplémentaires de 4 à 8 dans la base)
  2. **Livraisons Spéciales Garanties (`GuaranteedDeliveries`)** :
     - Permet d'acheter en Patacash une livraison **100 % déterministe et garantie** d'une patate d'un niveau précis (ex: Livraison Patate Lv.4, Lv.6, Lv.8 — plafonné à `highestDiscoveredLevel - 1` pour préserver le plaisir de la découverte par fusion) qui arrive directement dans le cercle (ou la réserve) avec une animation de caisse de livraison. **Aucune boîte surprise aléatoire n'est utilisée ici.**
  3. **Décors de Base (`BaseDecors`)** :
     - Améliorations esthétiques de la base 3D achetables en Patacash (éclairage néon du cercle, tapis/dallage de base, bordures dorées des vitrines).

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/network/Guards.luau` & `src/server/network/NetRouter.luau` :
   - Création programmatique des `RemoteEvent` dans `ReplicatedStorage.Remotes` (aucune `RemoteFunction` serveur-vers-client).
   - Validation systématique des types (`typeof`), rejet de `NaN`/`math.huge` (`v == v and math.abs(v) ~= math.huge`), bornes entières, listes blanches d'identifiants et limiteur de débit (*token-bucket rate limiter*) par joueur nettoyé sur `PlayerRemoving`.
2. `src/shared/domain/PatacashShopConfig.luau` (gelé par `table.freeze`) :
   - Formules de coûts exponentiels propres pour chaque amélioration, table des Livraisons Garanties et catalogue des Décors.
3. `src/server/services/PatacashShopService.luau` (enregistré dans `Loader.luau`) :
   - Traite de manière atomique les achats d'améliorations, de livraisons garanties et de décors.
   - Met immédiatement à jour les paramètres du cercle (`CircleMergeService`), débloque physiquement les nouveaux socles 3D (`ShowcaseService`) ou applique les décors sur la base (`BasePlotService`).
4. `src/client/controllers/ShopUiController.luau` :
   - Panneau de boutique fluide divisé en 3 onglets (`Améliorations`, `Livraisons Garanties`, `Décors de Base`) affichant clairement le niveau actuel, l'effet exact du prochain niveau et le coût en Patacash.
5. `tests/domain/ShopAndSecurity.spec.luau` :
   - Tests unitaires hors-Studio vérifiant : (a) le rejet de 100 % des charges utiles malformées (`NaN`, `nil`, types invalides, IDs inconnus, flood de requêtes) par `Guards` et `NetRouter`, (b) l'exactitude des transactions d'achat et l'impossibilité d'acheter une livraison d'un niveau non autorisé ou avec un solde insuffisant.

### 3. Déploiement & Porte de Validation Déterministe (GATE 5)
1. Passe l'analyse statique `--!strict` et la suite de tests `ShopAndSecurity.spec.luau`.
2. Déploie dans Studio et lance un playtest (`tools/studio.py` / MCP).
3. Exécute un test automatisé qui : (a) envoie des paquets corrompus (`NaN`, ID inexistant, spam de 40 appels) depuis le client et vérifie que le serveur les rejette avec 0 erreur, (b) achète une amélioration `UnlockShowcaseSlot` et une `Livraison Garantie` avec du Patacash, vérifie que le nouveau socle 3D apparaît dans la base et que la patate livrée rejoint le cercle, avec 0 erreur dans `get_console_output`.
~~~

### PROMPT 06 / 10 — Mutations En Ligne (*Golden, Rainbow, Lightning*), Auto-Protection & Voix Synthétique IA (`AudioTextToSpeech`)

~~~text
ultrathink
Nous passons à l'Étape 6/10 de « Patate Merge ». Nous implémentons le système de **Mutations rares en ligne** (*Golden*, *Rainbow*, *Lightning*), leur **auto-protection par défaut**, leur **double utilité** (Vitrine Patacash vs Sacrifice Score) et la **Signature Vocale Synthétique (`AudioTextToSpeech`)** lors des découvertes rares. Be ambitious sur la mise en scène et la fiabilité des règles de mutation.

### 1. Règles Métier des Mutations & de la Signature Vocale
- **Tirage RNG Strictement En Ligne** : Lorsqu'une fusion se produit dans le cercle d'un joueur connecté, le serveur effectue un tirage RNG pour déterminer si la nouvelle patate obtient une surcouche de mutation : `Golden`, `Rainbow` ou `Lightning` (aucune mutation ne peut jamais être générée par le calcul hors-ligne).
- **Auto-Protection par Défaut (`isLocked = true`)** :
  - Dès qu'une patate mutée (*Golden*, *Rainbow* ou *Lightning*) apparaît par fusion, elle est **automatiquement verrouillée (`isLocked = true`)** et extraite/protégée pour qu'elle ne puisse **jamais être consommée accidentellement** par une fusion automatique suivante.
  - Le joueur peut librement activer ou désactiver le cadenas (`ToggleLockPotato`) depuis son inventaire ou l'interface du cercle.
- **Double Utilité Stratégique** :
  1. **Exposée sur une Vitrine 3D** : La patate mutée multiplie sa production de **Patacash/s** par le multiplicateur de sa mutation (`Golden` x3, `Rainbow` x8, `Lightning` x20).
  2. **Sacrifiée volontairement dans une Fusion** (uniquement si le joueur a déverrouillé son cadenas `isLocked = false`) : Lorsque deux patates fusionnent et qu'au moins l'une d'elles porte une mutation, la fusion accorde un **multiplicateur ponctuel non cumulatif de Score** (si les deux sont mutées, seul le meilleur multiplicateur des deux s'applique — jamais de multiplication croisée abusive).
- **Annonce Vocale Synthétique Théâtrale (`AudioTextToSpeech`)** :
  - Lorsqu'un joueur découvre pour la **première fois** dans son Patatedex une forme de haut niveau (Lv.8+) ou une combinaison rare `[Forme + Mutation]`, le serveur notifie le client qui déclenche une **annonce vocale synthétique théâtrale** via l'objet natif Roblox `AudioTextToSpeech` câblé par un `Wire` vers `AudioEmitter` / `AudioDeviceOutput` (avec bandeau visuel de célébration à l'écran et *ducking* temporaire de la musique de fond).

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/domain/MutationEngine.luau` :
   - Tirage pondéré pur `rollOnlineMutation(rng: Random, baseChanceBoost: number?): string`.
   - Règle d'auto-verrouillage `shouldAutoProtect(mutation: string): boolean` (`true` pour `Golden`, `Rainbow`, `Lightning`).
   - Calcul du gain de Score de fusion avec règle du **maximum non cumulatif** : `computeMergeScore(targetLevel: number, mutationA: string, mutationB: string): number` (utilise `math.max(multA, multB)`, jamais `multA * multB`).
2. `src/client/controllers/VoiceAndAudioController.luau` (enregistré dans `Loader.luau`) :
   - Configure le graphe audio moderne sous `SoundService` (`DefaultListenerLocation = Enum.ListenerLocation.Camera`, `AudioDeviceOutput`, bus `AudioFader` pour Musique/SFX).
   - Crée et câble un composant `AudioTextToSpeech` -> `Wire` -> `AudioDeviceOutput` (en encapsulant les appels dans `pcall` avec secours textuel/SFX au cas où la synthèse vocale est limitée ou indisponible localement).
   - Lors d'un événement `FirstRareDiscovery`, configure `audioTts.Text` (ex: *"Incroyable ! Première découverte : Patate Royale Arc-en-Ciel !"*), `VoiceId = "1"` ou `"2"`, ajuste `Pitch` et `Speed`, et appelle `audioTts:Play()` avec un cooldown anti-spam pour ne jamais superposer deux voix.
3. Mise à jour de `CircleMergeService.luau`, `ShowcaseService.luau` et de l'UI d'Inventaire :
   - Affichage du badge de cadenas (`[Protégée]` sans émoji) sur les patates mutées, bouton de verrouillage/déverrouillage, et affichage clair du multiplicateur Patacash/s vs bonus de Score en cas de sacrifice.
4. `tests/domain/MutationEngine.spec.luau` :
   - Tests unitaires hors-Studio prouvant : (a) que toute patate mutée naît avec `isLocked == true` et que `AutoMergeEngine` refuse de fusionner une patate tant que `isLocked == true`, (b) que la fusion d'une patate `Golden` (x2.5) et d'une `Rainbow` (x6) déverrouillées applique exactement `x6` au Score (non cumulatif) et jamais `x15`.

### 3. Déploiement & Porte de Validation Déterministe (GATE 6)
1. Passe l'analyse statique `--!strict` et la suite `MutationEngine.spec.luau` hors-Studio.
2. Déploie dans Studio et lance un playtest (`tools/studio.py` / MCP).
3. Force côté serveur une fusion générant une patate `Rainbow` pour la première fois : vérifie que (a) la patate est automatiquement verrouillée (`isLocked == true`) et ne fusionne pas toute seule, (b) exposée en vitrine 3D, elle multiplie bien le Patacash/s par 8, (c) l'événement de première découverte déclenche le bandeau et le graphe `AudioTextToSpeech` (avec `Wire.Connected == true`), (d) une fois déverrouillée manuellement et fusionnée, elle applique le bonus de Score non cumulatif, avec 0 erreur console.
~~~

### PROMPT 07 / 10 — Progression Hors-Ligne (25 % / Plafond 6h / Zéro Mutation) & Économie des Diamants (Objectifs Quotidiens)

~~~text
ultrathink
Nous passons à l'Étape 7/10 de « Patate Merge ». Nous implémentons le calcul serveur de la **progression hors-ligne strictement encadrée** (25 % pendant 6h max, zéro mutation) et l'économie de la 3e ressource indépendante : les **Diamants** gagnés par les **Objectifs Quotidiens** et le **Patatedex**. Be ambitious sur la clarté de l'interface de retour en jeu et l'étanchéité entre les 3 monnaies.

### 1. Règles Métier : Hors-Ligne & Diamants
- **Progression Hors-Ligne Strictement Encadrée** :
  - Calculée **une seule fois côté serveur** lors du chargement du profil à la connexion à partir de `deltaSeconds = math.clamp(now - profile.lastOnlineTimestamp, 0, 21600)` (plafond strict de **6 heures = 21 600 secondes**).
  - Le gain hors-ligne porte **exclusivement sur le Patacash produit par les vitrines 3D exposées** au moment de la déconnexion, avec un rendement réduit à **25 %** : `Gain = math.floor(PatacashPerSec_vitrines * deltaSeconds * 0.25)`.
  - **Zéro mutation hors-ligne, zéro fusion de Score hors-ligne, zéro Diamant hors-ligne.**
  - Si `deltaSeconds >= 60` et `Gain > 0`, affiche au joueur une fenêtre d'accueil « Bon retour ! » résumant la durée prise en compte (max 6h) et le Patacash récolté par ses vitrines.
- **Économie des Diamants (3e Monnaie Indépendante)** :
  - Les **Diamants** ne sont **jamais** produits par les vitrines 3D et ne sont **pas achetables en Robux au lancement**.
  - Ils s'obtiennent uniquement en accomplissant :
    1. **3 Objectifs Quotidiens** renouvelés toutes les 24h (ex: *Réaliser 50 fusions dans le cercle*, *Découvrir ou exposer une patate mutée*, *Améliorer 3 fois sa base en Patacash*) + un bonus de complétion des 3 objectifs.
    2. **Les Paliers de Collection du Patatedex** (récompense unique en Diamants à chaque nouveau palier de patate ou de mutation enregistré).

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/domain/OfflineAndDailyMath.luau` :
   - Fonction pure `computeOfflinePatacash(showcasePatacashPerSec: number, lastTimestamp: number, currentTimestamp: number): { elapsedCapped: number, patacashEarned: number, mutationsRolled: number }` (`mutationsRolled` vaut toujours `0`).
   - Générateur déterministe des 3 objectifs quotidiens par `dayIndex = math.floor(currentTimestamp / 86400)` et fonctions pures d'incrémentation et de réclamation (`claimObjectiveReward`, `claimPatatedexMilestone`).
2. `src/server/services/ProgressionService.luau` (enregistré dans `Loader.luau`) :
   - Exécute le calcul hors-ligne à la connexion du joueur, crédite le Patacash, met à jour `lastOnlineTimestamp` immédiatement (pour rendre impossible tout exploit de reconnexion en boucle), et envoie `NotifyOfflineSummary` au client.
   - Écoute les événements de fusion, de mutation et d'achat pour faire progresser les objectifs quotidiens et créditer les **Diamants** lors de la réclamation (`RequestClaimDailyObjective`, `RequestClaimDexMilestone`).
3. `src/client/controllers/WelcomeAndObjectivesUiController.luau` :
   - Fenêtre modale « Rapport Hors-Ligne (Max 6h à 25 %) » et panneau « Objectifs Quotidiens & Récompenses Diamants » avec barres de progression et compteur de Diamants dans le HUD.
4. `tests/domain/OfflineAndDaily.spec.luau` :
   - Tests unitaires hors-Studio prouvant : (a) qu'une absence de 24 heures est strictement plafonnée à 6 heures (21 600 s) à 25 % du taux des vitrines et génère 0 mutation et 0 Score, (b) qu'une horloge négative ou `< 60 s` donne `0`, (c) qu'un objectif quotidien complété ne peut jamais être réclamé deux fois dans la même journée.

### 3. Déploiement & Porte de Validation Déterministe (GATE 7)
1. Passe l'analyse statique `--!strict` et la suite `OfflineAndDaily.spec.luau` hors-Studio.
2. Déploie dans Studio et lance un playtest (`tools/studio.py` / MCP).
3. Simule côté serveur un profil dont `lastOnlineTimestamp` remonte à 10 heures avec des vitrines produisant `100 Patacash/s` : vérifie que le joueur reçoit exactement `100 * 21600 * 0.25 = 540 000 Patacash`, 0 mutation, que la popup « Bon retour ! » s'affiche, et que la validation d'un objectif quotidien crédite bien les **Diamants** dans le HUD et `leaderstats.Diamonds`, avec 0 erreur console.
~~~

### PROMPT 08 / 10 — Système de Trading Direct Anti-Dupe (Patates & Diamants)

~~~text
ultrathink
Nous passons à l'Étape 8/10 de « Patate Merge ». Nous implémentons le système de **Trading Direct entre joueurs** (échange de Patates d'inventaire et de **Diamants** uniquement), doté d'une machine à états transactionnelle atomique côté serveur rendant toute duplication (*dupe*) ou arnaque de dernière seconde mathématiquement impossible. Be ambitious sur la sécurité transactionnelle.

### 1. Règles Métier et Sécurité Anti-Dupe du Trading
- **Actifs Échangeables** : Uniquement des **Patates de l'inventaire** (jusqu'à 4 patates par joueur par échange) et des **Diamants** (taxe de transaction de 0 % en échange direct ou configurable). Le **Score** et le **Patacash** ne peuvent **jamais** être échangés.
- **Conditions d'Éligibilité d'une Patate** :
  - Une patate verrouillée par l'auto-protection mutation (`isLocked == true`) ou actuellement posée sur une vitrine 3D (`isEquippedInShowcase == true`) ne peut pas être placée dans un échange tant que le joueur ne l'a pas retirée de sa vitrine et déverrouillée.
- **Machine à États Transactionnelle à Double Verrou (`Draft -> Ready -> Confirm -> Committed/Aborted`)** :
  1. Tant que l'échange est ouvert, les patates placées dans l'offre sont marquées en **réservation temporaire (`reservedInSessionId`)** sur le serveur : elles ne peuvent être ni équipées en vitrine, ni fusionnées, ni mises en vente au Market.
  2. **Règle Anti-Scam** : Si l'un des deux joueurs ajoute/retire une patate ou modifie son montant de Diamants, les statuts `Ready` et `Confirm` des **deux** joueurs retombent immédiatement à `false`, et un compte à rebours de sécurité de **3 secondes** bloque le bouton final `Confirmer`.
  3. **Commit Atomique & Verrou Mutex** : Lorsque les deux joueurs ont validé `Confirm` sur le même `offerStateHash`, le serveur vérifie une dernière fois en une seule section critique sans aucun `yield` (`task.wait` interdit pendant le swap en mémoire) que les deux joueurs sont présents, que leurs profils sont chargés, qu'ils possèdent toujours chaque `uid` et le solde de Diamants, puis transfère les `uid` et les Diamants simultanément entre les deux tables de profils et met à jour le Patatedex du receveur.
  4. Si un joueur se déconnecte à n'importe quelle microseconde avant le commit atomique, la session est annulée (`Aborted`) et toutes les réservations sont libérées sans aucune perte ni duplication.

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/domain/TradeSessionMachine.luau` :
   - Machine à états pure et déterministe gérant le cycle de vie d'une session d'échange, le calcul de `offerStateHash`, la réinitialisation des confirmations sur modification, et l'exécution atomique du transfert en mémoire.
2. `src/server/services/TradeService.luau` (enregistré dans `Loader.luau`) :
   - Gère les demandes d'échange (`RequestSendTradeInvite`, `RequestRespondTradeInvite`, `RequestUpdateTradeOffer`, `RequestSetTradeReady`, `RequestConfirmTrade`, `RequestCancelTrade`) via `NetRouter` avec rate-limiting et cooldown entre deux invitations.
   - Nettoie instantanément toute session active si l'un des deux joueurs déclenche `Players.PlayerRemoving`.
3. `src/client/controllers/TradeUiController.luau` :
   - Bouton HUD « Échanges » listant les joueurs du serveur (avec interrupteur « Accepter les demandes : Oui / Non »).
   - Fenêtre d'échange côte-à-côte affichant les emplacements de patates (niveau, mutation, Patacash/s), le champ de Diamants, le compte à rebours anti-arnaque de 3 secondes après toute modification et les boutons `Prêt` puis `Confirmer l'Échange`.
4. `tests/domain/TradeAntiDupe.spec.luau` :
   - Tests unitaires hors-Studio éprouvant :
     - La conservation stricte de la masse monétaire et des UIDs : avant et après 100 échanges aléatoires ou annulés, le nombre total de patates (chaque `uid` unique) et la somme des Diamants des deux joueurs restent strictement invariants.
     - La réinitialisation automatique de `Ready`/`Confirm` dès qu'un joueur modifie 1 Diamant ou 1 patate.
     - Le rejet immédiat d'une patate verrouillée (`isLocked == true`), équipée en vitrine, ou d'un `offerStateHash` obsolète.

### 3. Déploiement & Porte de Validation Déterministe (GATE 8)
1. Passe l'analyse statique `--!strict` et la suite `TradeAntiDupe.spec.luau` hors-Studio.
2. Déploie dans Studio et lance un playtest (`tools/studio.py` / MCP).
3. Exécute sur le serveur une simulation de session d'échange complète entre deux profils (ainsi qu'une tentative de modification de dernière seconde et une déconnexion simulée en plein échange) : vérifie que le transfert valide échange exactement les patates et les Diamants, que la tentative de modification réinitialise les verrous, et que la déconnexion annule tout sans duplication ni erreur console.
~~~

### PROMPT 09 / 10 — Patate Market (Stands Physiques 3D, Filtres de Recherche *PETS GO!* & Achat en Diamants)

~~~text
ultrathink
Nous passons à l'Étape 9/10 de « Patate Merge ». Nous construisons le **Patate Market** sur la place centrale du monde 3D : des stands physiques revendicables par les joueurs pour vendre leurs patates en **Diamants**, accompagnés de l'interface globale de recherche et de filtrage inspirée de *PETS GO!* (stands, filtres par forme/mutation/prix et monnaie d'échange Diamants). Be ambitious sur l'ergonomie des filtres et l'atomicité des achats.

### 1. Règles Métier du Patate Market
- **Stands Physiques 3D sur la Place Centrale** :
  - La place centrale située entre les bases des joueurs comporte **6 Stands de Marché 3D** dotés d'un `ProximityPrompt` « Revendiquer ce Stand » (ou attribution automatique à la demande).
  - Un joueur peut exposer jusqu'à **6 patates en vente simultanément** sur son stand, chacune avec un prix fixé librement en **Diamants** (entier positif borné entre `1` et `1 000 000`).
  - Une patate mise en vente sur le stand est retirée des vitrines Patacash et marquée `listedOnStand = true` : elle ne peut pas être échangée en Trading direct ni fusionnée tant qu'elle est en vente sur le stand.
- **Interface Globale de Recherche & Filtres (Inspiration *PETS GO!*)** :
  - Accessible depuis n'importe où via le bouton HUD « Patate Market » ou en inspectant un stand.
  - Permet de parcourir toutes les patates mises en vente par les joueurs présents dans le serveur avec **3 filtres combinables en temps réel** :
    1. **Filtre par Forme / Niveau** (Tous, ou Niveau précis `Lv.1` à `Lv.15`, ou recherche textuelle par nom).
    2. **Filtre par Mutation** (`Toutes`, `Sans Mutation`, `Golden`, `Rainbow`, `Lightning`).
    3. **Tri & Filtre par Prix en Diamants** (Prix croissant, Prix décroissant, Niveau décroissant, et filtre « Uniquement ce que je peux payer avec mes Diamants »).
  - Chaque carte d'offre propose deux boutons : **« Voir le Stand »** (téléporte ou guide le joueur devant le stand 3D du vendeur) et **« Acheter (X Diamants) »** (achat atomique instantané).
- **Transaction Atomique Serveur** :
  - Lorsqu'un acheteur clique sur « Acheter », le serveur vérifie le `listingId` et le `expectedPrice` (pour éviter qu'un vendeur ne change le prix au moment du clic), débite les Diamants de l'acheteur, crédite le vendeur, transfère l'`uid` de la patate dans l'inventaire de l'acheteur, met à jour le stand 3D et le Patatedex de l'acheteur en une seule opération atomique sans yield. Si le vendeur quitte le serveur, son stand est immédiatement vidé et ses patates restent dans son inventaire sauvegardé.

### 2. Modules à Implémenter sur Disque (`--!strict` partout)
1. `src/shared/domain/MarketIndex.luau` :
   - Moteur pur de gestion des annonces (`createListing`, `removeListing`, `executePurchase`, `queryListings(listings, filterCriteria)`).
2. `src/server/services/PatateMarketService.luau` (enregistré dans `Loader.luau`) :
   - Génère les 6 stands 3D sur la place centrale au démarrage, gère la revendication de stand, la mise en vente, le retrait, l'achat atomique et la libération sur `PlayerRemoving`.
   - Diffuse les mises à jour du registre des offres aux clients connectés.
3. `src/client/controllers/MarketUiController.luau` :
   - Interface de gestion de son propre stand (« Mettre en vente une patate + Choix du prix en Diamants ») et annuaire global « Patate Market » avec barre de filtres instantanés (Niveau, Mutation, Prix max, Tri) et cartes visuelles générées via `PotatoVisualRegistry`.
4. `tests/domain/MarketIndex.spec.luau` :
   - Tests unitaires hors-Studio vérifiant : (a) l'exactitude du filtrage combiné (ex: trouver uniquement les patates `Rainbow` de niveau >= 8 coûtant <= 500 Diamants, triées par prix croissant), (b) la protection contre le *price-baiting* (l'achat échoue si le prix de l'annonce a changé entre l'affichage client et le clic), (c) l'impossibilité pour deux acheteurs simultanés d'acheter la même annonce (`listingId`).

### 3. Déploiement & Porte de Validation Déterministe (GATE 9)
1. Passe l'analyse statique `--!strict` et la suite `MarketIndex.spec.luau` hors-Studio.
2. Déploie dans Studio et lance un playtest (`tools/studio.py` / MCP).
3. Simule côté serveur la revendication d'un stand 3D, la mise en vente de 3 patates (dont une `Golden` et une `Lightning`) à différents prix en Diamants, exécute une requête filtrée, puis simule l'achat par un second profil (et une tentative de double achat concurrent) : vérifie que le stand 3D se met à jour, que les Diamants et la patate sont transférés une seule fois, et que `get_console_output` affiche 0 erreur. Prends un `screen_capture` de la place centrale du Patate Market.
~~~

### PROMPT 10 / 10 — Ergonomie Mobile/PC, Monétisation Idempotente (`ProcessReceipt`), Optimisation 60 FPS & Audit Final de Release

~~~text
ultrathink
Nous passons à l'Étape 10/10 (Finale) de « Patate Merge ». Nous finalisons l'ergonomie responsive Mobile/PC (`CoreUISafeInsets`, `ResetOnSpawn = false`), la monétisation serveur-autoritaire (`ProcessReceipt` idempotent sans jamais vendre de Score ni de Diamants), l'optimisation de rendu à 60 FPS (*distance culling* des cercles 2D distants) et l'audit complet de release. Be ambitious : livre un jeu prêt pour la production.

### 1. Monétisation Légale, Équilibrée & Idempotente (`src/server/services/MonetizationService.luau`)
- **Respect Strict de l'Économie** : Aucun produit Robux ne vend jamais de **Score** ni de **Diamants**.
- **Catalogue Robux (`src/shared/domain/RobuxCatalog.luau`)** :
  - **Game Passes** : `DoublePatacashPass` (x2 production Patacash des vitrines 3D), `FastCircleSpawnPass` (-30 % intervalle d'apparition dans le cercle), `LuckyMutationPass` (augmente la chance de mutation en ligne lors des fusions), `ExtraShowcaseSlotsPass` (+2 socles de vitrines 3D spéciaux).
  - **Developer Products** : Packs de Patacash adaptés à la production actuelle du joueur et Livraison Spéciale Garantie Instantanée.
- **`MarketplaceService.ProcessReceipt` Unique & Idempotent** :
  - Vérifie que le profil du joueur est chargé (`NotProcessedYet` sinon).
  - Vérifie si `receiptInfo.PurchaseId` est déjà présent dans `profile.processedReceipts` (retourne `PurchaseGranted` sans recréditer si déjà traité).
  - Accorde l'achat dans un `pcall`, enregistre le `PurchaseId` dans la file circulaire bornée (100 entrées) et sauvegarde avant de retourner `PurchaseGranted`.
  - Vérifie `PolicyService:GetPolicyInfoForPlayerAsync(player)` pour garantir la conformité régionale de tous les éléments affichés.

### 2. Finition UI Mobile/PC & Optimisation 60 FPS (`src/client/controllers/UiPolishAndPerfController.luau`)
1. **Standards UI 2026** :
   - Vérifie que chaque `ScreenGui` possède `ResetOnSpawn = false` et `ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets`.
   - Adaptation responsive (`AbsoluteSize.X < 700` sur mobile vs PC), `AutomaticCanvasSize = Enum.AutomaticSize.Y` sur toutes les listes défilantes, et annulation systématique du tween précédent (`activeTween:Cancel()`) avant toute ouverture/fermeture de fenêtre pour éviter tout panneau invisible bloquant les clics.
   - Guide visuel des **2 premières minutes (FTUE)** : à la toute première session (`score == 0`), affiche une indication claire devant le cercle vertical 2D (*« Tes patates fusionnent toutes seules et augmentent ton SCORE ! »*), puis guide le joueur vers sa première vitrine 3D (*« Expose tes meilleures patates sur les socles pour produire du PATACASH ! »*).
2. **Optimisation 60 FPS des Cercles 2D Multi-Joueurs (`Distance Throttling`)** :
   - Sur le client, le cercle vertical 2D de la base du joueur local est simulé et rafraîchi à **60 FPS**.
   - Les cercles verticaux 2D des bases des autres joueurs situés à plus de 90 studs sont rafraîchis à fréquence réduite (15 FPS) ou mis en veille visuelle au-delà de 200 studs afin de garantir un Frame Time constant sur mobile.

### 3. Suite d'Audit Final (`src/server/testkit/ReleaseAudit.luau`) & Porte de Release (GATE 10)
1. Crée et exécute `ReleaseAudit.runAll()` qui vérifie automatiquement :
   - **Intégrité Architecturale** : 100 % des modules en `--!strict`, 0 erreur d'analyse statique, 100 % des suites de tests unitaires hors-Studio (Étapes 1 à 9) au vert.
   - **Intégrité Économique** : Le Score ne dépend que des fusions ; le Patacash ne dépend que des vitrines 3D ; les Diamants ne dépendent que des objectifs/Patatedex et servent au Trading/Market ; `ProcessReceipt` est idempotent sur un double appel avec le même `PurchaseId`.
   - **Performance (Frame Gate 60 FPS)** : Sous charge maximale (cercle plein en fusion continue + 8 vitrines 3D occupées + stand Market actif + ouvertures rapides de menus), mesure `RunService.Heartbeat` pendant 300 trames : exige `p95 <= 20.0 ms` et `max <= 33.3 ms`.
   - **Zéro Fuite Mémoire** : Après déconnexion d'un joueur, sa base, son stand Market, ses sessions de trade et ses entrées mémoire sont intégralement nettoyés (`nil`).
2. Lance `python3 tools/deploy_luau.py`, exécute le playtest final via `python3 tools/studio.py`, capture les écrans finaux (`screen_capture` du Cercle 2D + Score, des Vitrines 3D Patacash, du Patate Market et des menus Inventaire/Trading), vérifie `0 erreur` et `0 warning` non résolu dans `get_console_output`, puis résume le rapport de validation final.
~~~

---

## 7. Questions de Cadrage en Suspens (À Reprendre au Démarrage de la Prochaine Session)

L'utilisateur n'a pas encore répondu aux 4 questions ci-dessous (ni aux 3 micro-ajustements optionnels) avant de coller le Prompt 02 dans Claude Code :

1. **Arborescence réelle du Prompt 01 :** Quels fichiers exacts Claude Code a-t-il créés lors du Prompt 01 dans le dépôt `jeu-1-patate` (ex: bien sous `src/shared/core/Loader.luau`, `Trove.luau`, `Signal.luau`, ou une autre structure attendue par `tools/deploy_luau.py`) ?
2. **Nombre de formes de patates :** Confirmer les **15 formes évolutives** (milieu de la fourchette 12–18) ou injecter une liste personnalisée.
3. **Transition Cercle 2D $\leftrightarrow$ Inventaire / Vitrines 3D :**
   * *Option A (Fluide) :* Copie/disponibilité automatique vers l'inventaire ou prélèvement libre.
   * *Option B (Extraction physique) :* Retrait explicite d'une patate du cercle (ou extraction auto des mutées / max level) vers l'inventaire pour conserver une propriété stricte sans doublon.
4. **Capacité serveur :** **6 joueurs/serveur** (6 bases + 6 stands) ou **8 joueurs/serveur** ?
5. **Micro-décisions d'harmonisation (Prompts 07, 09, 10) :**
   * *Hors-ligne (Prompt 07) :* Patacash des vitrines uniquement à $25\%$ / 6h, ou aussi simulation des fusions ordinaires hors-ligne (sans mutation) ?
   * *Patate Market (Prompt 09) :* Activer la commission configurable de $5\%$ (puits de Diamants) dès le départ ?
   * *Monétisation (Prompt 10) :* Retirer `LuckyMutationPass` et `FastCircleSpawnPass` du lancement (pour rester 100 % cosmétique/confort et éviter tout risque `paid-random-items` au lancement) + intégrer la télémétrie `AnalyticsService`, l'option « Masquer l'UI » et la vérification `100 % R15` ?