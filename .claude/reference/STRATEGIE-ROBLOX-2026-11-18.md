<!-- Copie stockée dans le dépôt public du jeu le 2026-11-24 : les détails d'un accord privé entre associés ont été retirés (remplacés par « [accord privé, retiré de la copie publique] »). Le reste est le texte d'origine. -->

# Stratégie Roblox : marché, mécanique de la plateforme, technique et plan d'action

Version du 2026-11-18. Relevés Roblox du 2026-11-18 (entre 00:51 et 01:30 UTC), lettre aux actionnaires du T3 2026, pages officielles du dépôt `Roblox/creator-docs` (date du dernier commit indiquée), mesures du 2026-11-16 (voir `.claude/skills/roblox-expert/references/measured-data-2026-11.md`).

**Étiquettes.** **[P]** source officielle lue en entier (page Roblox, dépôt SEC) · **[mesure]** relevé direct sur les API publiques de Roblox (date indiquée) · **[calc]** mon calcul sur des chiffres cités · **[S]** source secondaire (presse, tracker, blog) · **[H]** jugement de ma part, non sourcé · **[?]** non vérifié ou inconnu.
Aucun chiffre n'est donné sans l'une de ces étiquettes. Un chiffre [S] ou [H] ne doit pas décider d'une dépense.

**Comment lire.** 5 minutes : §0 puis §9. 30 minutes : §0 à §3 et §7. Pour construire : §6 et §8. Les angles morts sont au §10.

---

## 0. L'essentiel

1. **La plateforme ne grandit plus.** T3 2026 : joueurs par jour 138 M (-9 % sur un an), heures de jeu près de 34 Md (-15 %), réservations 1,7 Md$ (-12 %), réservations du T4 prévues à -10 % à -15 % [P, 8-K du 2026-10-29]. Aucune marée montante : un jeu neuf prend de l'attention à d'autres jeux, et l'algorithme récompense la rétention sur 28 jours.
2. **Popularité n'est pas rentabilité, et Roblox publie le classement qui le montre.** Le tri « Top Earning » (Robux dépensés sur 7 jours) place Steal An Egg n° 1 en joueurs (≈ 14,5 M par jour) mais n° 4 en dépenses, et Bloodlines (≈ 51 K joueurs par jour) n° 9 [mesure 18/11]. Dans le même top 10, le nombre de joueurs par jour varie d'un facteur ≈ 280.
3. **Les jeux qui gagnent le plus sont profonds et plutôt anciens ; les jeux neufs entrent surtout par le bas.** Top 10 des dépenses : âge médian 36 mois, 3 jeux de plus de 5 ans, 2 jeux de moins de 6 mois. Sur les 30 premiers : 8 Action RPG, 3 tower defense, 29 propriétaires sur 30 sont des groupes (studios) [mesure 18/11]. Mais 33 % des 97 jeux du classement ont moins de 6 mois : un jeu neuf peut y entrer (critère officiel : au moins 5 000 joueurs par jour, ou les 10 % supérieurs) [P + mesure 18/11].
4. **Le seul moteur de croissance durable est organique, et il est étroit.** Les signaux de recommandation ne comptent que les joueurs arrivés par « Recommended For You » ; la publicité, les amis, la recherche ne comptent pas, mais ils peuvent accélérer la prise en compte du jeu [P]. La priorité est la sortie rapide au premier lancement, le taux de lancement, les jours de jeu sur 28 jours.
5. **Deux barrières que la plupart des analyses oublient.** Un jeu neuf n'est montré qu'aux 16 ans et plus jusqu'à 250 joueurs « très engagés » sur 60 jours [P]. Et les jeux dont les métadonnées et le fichier de place ressemblent à un jeu existant ne sont plus priorisés [P]. Le programme « une base, beaucoup de variantes » doit donc produire des jeux **visiblement différents**.
6. **Économie : le créateur garde 70 % des Robux dépensés, DevEx à 0,0038 $ par Robux, 0,0054 $ pour les achats d'adultes américains vérifiés si le jeu est 100 % R15** [P]. À 80 Robux par dollar [S], environ 21 cents (30 cents au taux 18+) du dollar dépensé par un joueur arrivent au créateur [calc].
7. **Des leviers sous-exploités, vérifiés sur les pages officielles :** prime Roblox Plus (jusqu'à 750 Robux par nouvel abonné), Audience Expansion (35 % des 100 premiers dollars d'achats d'un nouveau joueur), vidéo récompensée (à partir de 2 000 visiteurs uniques par mois), vente de modèles et plugins en dollars à 100 % du net, Feature Packages officiels (missions, passe de saison, bundles, récompenses d'engagement) [P].
8. **Stratégie recommandée pour ton cas** (détail au §7) : un moteur commun invisible (données, économie, boutique, événements, télémétrie, configuration) et, par jeu, une boucle de gameplay, un sujet et une direction artistique distincts ; cibler d'abord les 16 ans et plus ; un portefeuille d'expériences de 3 à 4 semaines avec des règles d'arrêt chiffrées ; un test publicitaire de calibrage avant tout budget ; un rituel de mise à jour hebdomadaire ; la télémétrie dès le premier jour.
9. **Ce qui peut me faire me tromper** (§10) : le rang en dépenses n'est pas un montant, l'âge du jeu est sa date de création et non de refonte, la pondération des signaux de recommandation est inconnue, les coûts publicitaires 2026 sont inconnus, et les preuves en faveur des variantes viennent d'un éditeur qui possédait déjà une audience.
10. **Prochaines actions** (§11) : trancher 6 décisions (brief du premier jeu, budget publicitaire de test, temps par semaine, partenaires créateurs, structure de groupe, cible d'audience), puis 4 semaines d'une expérience instrumentée.

---

## 1. Ton cas : faits, contraintes, hypothèses

Source : Doc « ÉTAT Roblox » (mis à jour le 2026-11-18), `AGENTS.md`, `CLAUDE.md`.

| Fait | Conséquence stratégique |
|---|---|
| Objectif : publier tes propres jeux Roblox, déclinés en variantes d'une base de code commune, et en tirer un revenu | La base commune est l'actif. Elle doit être invisible pour la règle sur les copies (§3.2) et riche en systèmes réutilisables (§6.2) |
| Les variantes en série sont à toi à 100 % [accord privé, retiré de la copie publique] | Structure de groupe à décider (§7, S8) |
| Studio est la source de vérité ; Claude Code écrit via le serveur MCP de Studio ; GitHub garde un export en lecture seule | Les tests passent par Studio (Play, scripts client, capture, console) ; les modules sans API Roblox se testent hors de Studio (§6.7) |
| Aucune source de joueurs ; partenariats YouTube et TikTok à l'étude | Acquisition : §3.5 et §7 (S4, S5) |
| Concept du premier jeu : question ouverte | Ce document fournit une **grille de choix**, pas un concept (§8) |
| `patate-merge` est un test des capacités de Claude, hors du programme de variantes (mémoire du 2026-11-16) | Ne pas le forcer dans `shared/` ni dans la feuille de route des variantes |
| Les meilleures IA réussissent « environ une tâche Luau sur deux du premier coup » (ÉTAT) [?, source non retrouvée] | Tests automatiques, petits modules, revue du code qui touche à l'argent (§6.7) |
| Forfait Pro, quota limité | Outils en ligne de commande, modules entiers, peu d'allers-retours |

**Hypothèses que je fais** (à corriger si fausses) : travail seul avec Claude Code ; budget publicitaire faible et incertain ; capacité de production d'un premier jeu jouable en 2 à 3 semaines ; pas d'équipe artistique, donc dépendance aux outils de génération de Studio et à des assets vérifiés ; audience cible non décidée.

---

## 2. Le marché au 2026-11-18

### 2.1 La plateforme (lettre T3 2026, SEC 8-K du 2026-10-29, pièce 99.1) [P]

| Mesure | T3 2026 | Variation |
|---|---|---|
| Utilisateurs actifs par jour | 138 M | -9 % sur un an, +12 % sur le trimestre |
| Heures de jeu | près de 34 Md | -15 % sur un an, +17 % sur le trimestre |
| Réservations | 1,7 Md$ | -12 % sur un an (au-dessus de la fourchette haute de la prévision) |
| Revenu | 1,6 Md$ | +16 % sur un an |
| Frais DevEx | 403 M$ | -6 % sur un an |
| Prévision T4 | revenu +4 % à +12 % ; réservations -10 % à -15 % | |

Roblox présente aussi la base de deux ans : joueurs par jour +55 %, heures +63 %. Les deux lectures sont vraies : forte croissance sur deux ans, recul sur un an.
Autres faits du même document : 64 % des joueurs par jour ont fait un contrôle d'âge (34 % de moins de 13 ans, 37 % de 13 à 17 ans, 29 % de 18 ans et plus parmi les contrôlés) ; plus de 80 % du top 100 (par heures) a utilisé des outils d'IA le mois dernier ; environ 40 % du top 100 hebdomadaire de recommandation a moins de 3 mois ; plus de 70 % du top 100 par Robux dépensés a fait de la publicité Sponsored.
Relu le 16/11 dans la même lettre [P, non rouvert le 18/11] : 30 M de payeurs uniques par mois (-16 % sur un an), réservations par payeur +5 %, Roblox Plus lancé en avril 2026 (les abonnés jouent 2 fois plus et dépensent 7 fois plus de Robux), plus de 20 % des jeux avec vidéo récompensée tirent plus de 10 % de leurs gains de la publicité.

### 2.2 Popularité : qui a les joueurs [mesure 16/11, inférence sur badges]

| Jeu | Joueurs par jour | Part de nouveaux joueurs | Minutes par joueur et par jour |
|---|---|---|---|
| Steal An Egg | ≈ 14,5 M (≈ 10 % de Roblox) | 7,2 % | ≈ 70 |
| Blox Fruits | ≈ 4,2 M | n/d | ≈ 93 |
| Murder Mystery 2 | ≈ 3,2 M | n/d | ≈ 51 |
| RIVALS | ≈ 3,2 M | 9,6 % | ≈ 54 |
| 99 Nights in the Forest | ≈ 2,4 M | n/d | ≈ 74 |
| Break and Steal an Egg | ≈ 1,4 M | 12,2 % | ≈ 83 |
| +1 Speed Keyboard Escape | ≈ 0,7 M | 27,7 % | ≈ 38 |

La méthode (taux d'obtention des badges) n'est pas documentée par Roblox ; elle a été validée sur 44 badges d'un même jeu (tous cohérents à ±0,05 %). C'est une inférence solide, pas une donnée officielle.

### 2.3 Rentabilité : le classement officiel des dépenses [mesure 18/11, 00:51 UTC]

Définition officielle du tri : jeux classés par Robux dépensés sur les 7 derniers jours, limités aux jeux avec au moins 5 000 joueurs par jour, ou dans les 10 % supérieurs en joueurs, ou parmi les 30 plus joués [P]. Aucun montant n'est publié, seulement l'ordre. Les filtres ordinateur, téléphone et tablette donnent le même ordre ; la console en donne un autre.

| Rang | Jeu | Famille (genre Roblox) | Création | En ligne (instantané) | Joueurs par jour (badges) |
|---|---|---|---|---|---|
| 1 | RIVALS | Shooter | 2024-05 | 116 K | ≈ 3,2 M (16/11) |
| 2 | Anime Adventures | Tower defense | 2021-12 | 61 K | n/d |
| 3 | Blox Fruits | Action RPG | 2019-01 | 186 K | ≈ 4,2 M (16/11) |
| 4 | Steal An Egg | Simulation / tycoon | 2026-07 | 432 K | ≈ 14,5 M (16/11) |
| 5 | STAND OUT | Action RPG | 2025-07 | 36 K | ≈ 636 K |
| 6 | Attack on Titan Revolution | Action RPG | 2023-05 | 39 K | ≈ 524 K |
| 7 | Throw Food For Animals | Simulation / tycoon | 2026-09 | 192 K | n/d |
| 8 | Adopt Me! | Jeu de rôle, élevage | 2017-07 | 240 K | n/d |
| 9 | Bloodlines | Action RPG | 2020-08 | 6 K | ≈ 51 K |
| 10 | Practical Basketball | Sport | 2025-04 | 58 K | ≈ 379 K |
| 11 à 20 | Fisch, Tower Defense Simulator, Blade Ball, King Legacy, Pet Simulator 99, Project Slayers 2, Murder Mystery 2 (n° 17), Beyond Nen, Forsaken, Sol's RNG | | | | |

Autres jeux cités ailleurs : 99 Nights in the Forest n° 54, Brookhaven RP n° 66, Steal a Brainrot n° 79 ; +1 Speed Keyboard Escape n'est pas dans les 97 premiers.

**Lectures de ce relevé :**
- **Le seuil d'entrée est bas, le plafond est haut.** Médiane de joueurs en ligne par tranche de rang : 1 à 10 : 89 K ; 11 à 30 : 21 K ; 31 à 60 : 15 K ; 61 à 97 : 5,6 K [mesure 18/11]. Pour figurer dans la liste, le critère officiel est d'avoir au moins 5 000 joueurs par jour (ou d'être dans les 10 % supérieurs) ; le rang dépend ensuite des Robux dépensés.
- **Le classement se renouvelle.** 32 jeux sur 97 (33 %) ont moins de 6 mois, 36 sur 97 moins de 12 mois. Sur les 30 premiers : 5 de moins de 6 mois (Steal An Egg, Throw Food, FERAL, Tap Simulator REBORN, Cameraman Tower Defense), 7 de moins de 12 mois. C'est cohérent avec les 40 % du top 100 de recommandation créés dans les 3 derniers mois [P].
- **L'intensité de monétisation varie énormément.** Joueurs par jour des jeux du top 10 : de ≈ 51 K (Bloodlines) à ≈ 14,5 M (Steal An Egg), soit ≈ 280 fois. Les gros volumes à faible dépense par joueur (Steal An Egg : 2 passes à 299 et 467 Robux) coexistent avec des jeux de niche à forte dépense par joueur [calc sur mesure].
- **Les genres profonds dominent les dépenses.** Sur les 30 premiers : 8 Action RPG, 3 tower defense, 3 combat en arène (battlegrounds), 3 simulateurs incrémentaux, 3 « un contre tous » (survie), 2 tycoons, 2 shooters, 2 sports. 29 propriétaires sur 30 sont des groupes [mesure 18/11]. Roblox écrit lui-même que les RPG, la stratégie, les puzzles et les shooters sont fortement sous-représentés malgré une forte demande des tranches d'âge plus élevées [P : `creator-programs/standout-games`, 2026-08-25].
- Cela ne dit rien du profit : le classement mesure des Robux dépensés par les joueurs, pas ce qui reste au créateur ni les coûts.

### 2.4 Les autres classements publics de Roblox, lus comme des radars [mesure 18/11]

| Classement (définition officielle) | Ce qu'il montre | Relevé |
|---|---|---|
| **Up-and-Coming** : jeux publiés depuis moins de 28 jours, triés par croissance d'utilisateurs | Les formats neufs qui montent | 97 jeux ; médiane 5,7 K en ligne ; dominés par simulateurs incrémentaux (15), tycoons (10), simulations physiques (8), combat en arène (7), véhicules (6). 8 sur 97 sont déjà dans le top des dépenses (rangs 23 à 97) |
| **Top Trending** : plus forte hausse relative des joueurs par jour sur la semaine | Les départs de fusée | Médiane d'âge 32 jours ; 18 sur 98 dans le top des dépenses |
| **Top Revisited** : part des joueurs qui reviennent après une semaine | Un classement de rétention publié par Roblox | Médiane d'âge 1 019 jours ; 55 jeux sur 85 ont plus de 2 ans ; 28 sur 85 sont dans le top des dépenses ; médiane 2,5 K en ligne ; dominé par Action RPG (10), simulateurs incrémentaux (12), combat en arène (10), tower defense (8). Bloodlines est n° 1 |
| **Fun with Friends** : part du temps passé en groupes d'amis | Le co-jeu | 24 sur 89 dans le top des dépenses ; Brookhaven n° 12 |

**Ce que j'en tire** [H, appuyé sur ces relevés] :
- La rétention d'une semaine est un attribut des jeux profonds et anciens ; les jeux neufs qui montent vite sont presque tous des boucles simples. Les deux populations se rejoignent peu : seulement 8 % des nouveaux jeux qui montent sont déjà dans le top des dépenses, contre 33 % des jeux à forte rétention.
- Les clones apparaissent en 1 à 2 semaines : « Throw a Seed », variante de la famille Throw Food, a 10 jours et 14 K joueurs en ligne alors que Throw Food en a 190 K.
- Reproduire la mesure : `python -I .claude/skills/roblox-market-intel/scripts/game_intel.py charts 10` et `... top-earning 20`.

### 2.5 Cycles de vie [mesure 16/11 sauf mention]

- **Steal An Egg** : lancé le 2026-07-25 ; 3 semaines lentes (≈ 140 K joueurs en ligne en moyenne mi-août) ; +156 % puis +190 % en deux semaines ; semaine de pic le 14/09 (1,97 M en moyenne) ; depuis, -11,6 % par semaine. Signes de fatigue : favoris pour 1 000 visites de 1,86 à 0,70, votes positifs de 93,6 % à 88 %.
- **Throw Food For Animals** : de 13 K à 285 K joueurs en ligne en moyenne hebdomadaire en 3 semaines ; même propriétaire que Steal An Egg.
- **+1 Speed Keyboard Escape** : -93 % en 13 semaines malgré des pics du samedi 20 à 30 fois la moyenne.
- **Événements hebdomadaires** : pics de 5 à 30 fois pendant 1 à 4 heures, **sans hausse de la moyenne du lendemain**. Ils entretiennent l'habitude et la visibilité ; ils ne réparent pas un noyau en déclin.
- **Rythme** : presque tous les jeux du top publient chaque semaine, le vendredi ou le samedi entre 14 h et 20 h UTC (Blox Fruits excepté).
- Presse [S] : Steal a Brainrot -45 % en septembre ; 99 Nights -35 % ; Murder Mystery 2 -61 % après son événement d'été.

### 2.6 Qui construit les succès

- Le propriétaire de Steal An Egg et de Throw Food est le même compte, qui a lancé 7 petits jeux de mars à juin 2026 (12 M à 106 M de visites chacun) avant le jeu à 11,4 Md de visites, et tient des rôles dans 146 groupes [mesure 16/11, API des groupes]. Les deux succès partagent un même squelette (« stat à entraîner qui ouvre des zones » × « collectibles aléatoires » × « revenu passif à la base »), avec des sujets et des mécaniques de lancer différents.
- Le groupe de Steal An Egg compte 118,9 M de membres (≈ 41 % de ses joueurs uniques) parce que rejoindre le groupe donne de la vitesse [mesure 16/11].
- **Lecture** [H] : c'est la meilleure preuve en faveur d'un programme « squelette commun, sujets différents », mais elle est confondue avec une audience déjà possédée. Le deuxième jeu est parti avec les membres du premier.

### 2.7 Concentration, clones, risques [S, à ne pas citer sans rouvrir les sources]

- Revenus des créateurs : médiane DevEx ≈ 1 500 $, moyenne du top 10 ≈ 65,7 M$ [S : deux articles, erreur 403 à l'ouverture].
- Clones : 105 jeux « Steal a ___ » dont un seul concentre 92 % des joueurs [S, rowatcher.com, extrait de recherche non ouvert].
- Réglementation : 49 M$ de règlements avec des États américains sur la sécurité des mineurs au T3 [S, via résumé de la lettre] ; objets aléatoires payants réglementés (Australie, Belgique, Pays-Bas, Royaume-Uni, Brésil) [P] ; Steal An Egg retiré 3 à 4 heures le 2026-08-24 après la polémique sur son fil de vidéos [S] ; règle du 2026-08-25 retirant de Kids and Select les jeux à flux récompensé [P].

---

## 3. Comment Roblox distribue les jeux, et ce que cela impose

### 3.1 Le classement « Recommended For You » (RFY) [P : `discovery` 2026-11-07, `discovery-faq` 2026-10-24, newsroom 2026-06-15]

- Deux étages : récupération de nombreux candidats, puis classement personnalisé jusqu'à ≈ 100 jeux par joueur.
- **Les signaux ne comptent que les joueurs arrivés organiquement depuis RFY**, en moyennes par utilisateur : un petit jeu n'est pas désavantagé. Engagement, monétisation et rétention des joueurs venus de la publicité, de la curation, des amis, de la recherche ou des réseaux sociaux ne comptent pas à l'étape de classement.
- Fenêtre de 28 jours depuis l'annonce du 2026-06-15 (7 jours avant), en trois périodes : jour 1, jours 2 à 7, jours 8 à 28. Les jeux neufs ne sont pas retenus jusqu'au jour 28 : les signaux de première session agissent tout de suite.
- Signaux, par importance : **les plus importants** : taux de lancement après affichage ; taux de rebond du premier jeu (négatif) ; jours de jeu par joueur ; temps de jeu par joueur (plafonné à 60 minutes par joueur, par jeu et par jour). **Importants** : jours de co-jeu intentionnel (join, invitations, serveurs privés) ; sessions qualifiées ; jours de dépense ; Robux dépensés. Aucune pondération chiffrée publiée ; Roblox indique qu'elle devient dynamique et personnalisée.
- Roblox récompense « la rétention, le co-jeu et la dépense » et décote les jeux qui gagnent l'attention avec des miniatures accrocheuses sans valeur durable.
- Un signal fort sur un seul axe (rétention ou monétisation) donne des impressions ; les deux ensemble donnent la distribution la plus large.
- Exposition réduite : titre qui met en avant des cadeaux ou de l'argent, métadonnées trompeuses, jeux non uniques, miniature personnalisée absente, violations de sécurité ; une bannière « exposition réduite » apparaît dans le tableau de bord.

### 3.2 Deux règles qui encadrent un programme de variantes [P]

- **Jeux non uniques** : les jeux dont les métadonnées et le fichier de place ressemblent de près à des jeux existants ne sont plus priorisés dans les recommandations et peuvent être moins bien classés en recherche. Entre jeux indiscernables, Roblox met en avant celui qui a ajouté le premier les métadonnées ou le fichier de place uniques, pas le plus ancien. Cela s'applique aussi à tes propres jeux entre eux [H : la page dit « jeux existants sur Roblox »].
- **Portée Kids and Select** [`production/publishing/kids-and-select`, 2026-11-11] : un jeu neuf commence en phase d'essai ouverte aux seuls comptes de 16 ans et plus contrôlés. Il devient accessible aux comptes Kids et Select après **250 lectures uniques de joueurs « très engagés »** (contrôle d'âge fait, achat minimal sur Roblox dans les 60 derniers jours, temps passé dans ton jeu) **sur une fenêtre de 60 jours**. Cela demande des frais uniques remboursables ou un abonnement Roblox Plus ou Premium ; qui n'y est pas prêt reste sur l'audience 16+. Le gestionnaire de publicité propose un objectif « Qualify for Kids and Select » (coût par lecture plus élevé, budget dédié conseillé) [P : `ads-manager`, 2026-11-17].

### 3.3 Les autres surfaces

Recherche (sémantique), Continue Playing, Friends, Sponsored, Standout Games (sélection manuelle de jeux « nouveaux », voir §7 S10), événements d'expérience, classements (§2.4), notifications, page du jeu (événements, passes, jeux similaires). Les signaux venus de ces surfaces peuvent accélérer la prise en compte par RFY sans compter dans son classement. Saisonnalité : pic hebdomadaire le samedi ; été, rentrée, fêtes.

### 3.4 Traduire chaque signal en conception et en mesure

| Signal RFY | Levier de conception | À instrumenter |
|---|---|---|
| Taux de lancement | Miniature et titre honnêtes qui promettent la boucle en un verbe et un objet ; miniature personnalisée obligatoire ; personnalisation de miniature testée par Roblox [P] | Impressions, lancements par source, par miniature |
| Rebond du premier jeu (moins de 60 s, 61 à 180 s) | Premier geste sans lecture ; temps de chargement court ; performance sur appareil modeste ; apparition directement dans la boucle | Étapes d'entonnoir de la première session |
| Jours de jeu par joueur | Raison de revenir demain : horloge courte (stock qui tourne, culture hors ligne, minuteries), quêtes quotidiennes, progression qui ne punit pas l'absence | Jours actifs par cohorte, D1, D7, D30 |
| Temps de jeu par joueur (plafond 60 min/jour) | Ne pas viser les marathons : plusieurs sessions courtes comptent autant | Minutes par joueur et par jour |
| Co-jeu intentionnel | Invitations, serveurs privés, bonus de groupe, objectifs coopératifs | Jours de co-jeu, taille des groupes |
| Sessions qualifiées | Éviter les clics accidentels et les départs rapides | Sessions de plus de N minutes |
| Jours de dépense | Plusieurs moments d'achat sur des jours différents (offre du jour, boutique tournante, événement), pas un seul mur | Jours avec achat par payeur |
| Robux dépensés | Échelle de prix (petit, moyen, gros), conversion avant revenu par payeur | Taux de conversion, revenu par payeur actif |

### 3.5 Acquisition : ce qui compte pour RFY et ce qui ne compte pas

1. **Organique RFY** : la seule source qui nourrit le classement. Elle se déclenche si la première session et la rétention sont bonnes.
2. **Publicité Roblox** (Ads Manager) : ne compte pas dans le classement RFY, mais « les signaux d'autres sources peuvent accélérer la prise en compte » [P]. Objectifs : Plays (trafic initial, tests de nouvelles idées), Earnings (joueurs susceptibles de dépenser), Qualify for Kids and Select. Facturation au coût par lecture (CPP). **Repères de coût** : moyenne d'environ 0,008 $ par lecture pour l'objectif Plays selon Roblox au 2025-08-05 [P : DevForum] ; des chiffres de novembre 2025 de 0,0073 $ (Plays), 0,0113 $ (rétention), 0,011 $ (réactivation), 0,0187 $ (nouveaux utilisateurs) [S : résumé de recherche d'une source Roblox, non vérifié]. **Aucun chiffre 2026 n'a été trouvé** [?]. Règle de Roblox : amener D1 et D7 au niveau des jeux similaires avant d'augmenter l'acquisition payante [P].
3. **Partenariats de créateurs** : Roblox et YouTube sont les deux plateformes principales de beaucoup de joueurs [P]. Les mécaniques qui se filment font la promotion (voir §4.6). Le programme officiel **Audience Expansion** paie 35 % des 100 premiers dollars d'achats effectués dans les 60 jours par un **nouvel** utilisateur de Roblox, ou un utilisateur de retour après 60 jours d'absence, attribué à un lien de partage, un lien direct ou une recherche du nom exact ; condition : au moins 10 minutes de jeu le jour même et **une moyenne d'au moins 100 joueurs par jour pendant 60 jours après** ; les membres du programme Video Stars peuvent aussi percevoir ces récompenses [P : `creator-rewards`, 2026-10-15].
4. **Boucles de croissance dans le jeu** : récompense pour rejoindre le groupe, aimer, mettre en favori (Steal An Egg donne 10 000 de vitesse [S]). Je n'ai trouvé aucune règle officielle qui l'interdit ni qui l'autorise [?] : à vérifier dans les règles de la communauté avant de copier.
5. **Hors plateforme** : Discord, TikTok, YouTube ; tarifs d'influenceurs d'un guide de fournisseur (micro 500 à 2 000 $, moyen 5 000 à 10 000 $) [S, non vérifié].
6. **Roblox Everywhere** (applications autonomes) : première phase prévue au premier semestre 2027 [P, lettre T3].

---

## 4. Conception de jeu : boucles, première session, rétention

### 4.1 La boucle : définition officielle et cadre de travail

- **Définition Roblox** [P : `production/game-design/core-loops`, 2026-10-13] : trois parties : (1) l'interaction de minute en minute, (2) l'ensemble d'actions le plus répété, (3) le moteur de progression, sans lequel le jeu est « répétitif, ennuyeux et superficiel ».
- **Cadre de travail à quatre horizons** [H] : à utiliser comme liste de vérification, pas comme définition de Roblox.

| Horizon | Durée | Ce qu'il faut concevoir | Test |
|---|---|---|---|
| Micro | secondes | Une action avec retour immédiat (son, nombre qui s'envole, effet) | Un joueur répète le geste sans récompense payante |
| Cœur | 3 à 10 min | Un cycle complet qui finit sur un gain visible | Il sait nommer ce qu'il vient de gagner |
| Méta | plusieurs sessions | Collection, zones, rareté, prestige, classement | Il peut nommer son objectif de la semaine |
| Retour | plusieurs jours | Horloge de retour (stock, cultures, événements, saisons) | **Il peut dire ce qu'il fera demain** ; sinon la fenêtre jours 2 à 7 est perdue |

### 4.2 La première session [P pour les repères officiels, H pour les durées]

| Temps | Objectif | Appui |
|---|---|---|
| 0 à 10 s | Apparaître dans la première action de la boucle ; ce que l'on voit = ce que promet la miniature | Taux de lancement et rebond sont les signaux n° 1 |
| 10 à 60 s | Premier gain avec retour visible et prochaine étape évidente | « Moment de joie après la première boucle » [P] |
| 1 à 3 min | Une boucle complète, premier achat d'amélioration | Le rebond entre 61 et 180 s est pénalisé |
| 3 à 5 min | Objectifs court, moyen et long visibles ; premier cadeau de départ | Plaisir de jeu en 5 minutes ou moins [P : `production/analytics/retention`, 2026-10-13] |
| Fin de l'accueil | Un point haut conçu (animation, effet) et une raison de revenir demain | [P] |

Techniques officielles : flèches et traces dans le monde, aides au bon moment affichées une fois aux seuls joueurs en difficulté (exemple : à 11 s quand la plupart agissent en 10 s), pas de murs de texte, retour sur chaque action. Mesurer par entonnoir et tester les corrections avec Experiments.

### 4.3 Les familles de jeux, évaluées pour ton cas

Colonnes « coût », « risque de clones », « déclin » : jugement [H] fondé sur les relevés des §2.3 à 2.5. Je ne propose pas de concept de jeu ; ce tableau compare des **squelettes**.

| Famille | Exemples (rang en dépenses) | Dépense par joueur | Coût de production en solo | Risque de clones | Déclin observé |
|---|---|---|---|---|---|
| A. Stat à entraîner × collectibles × revenu passif | Steal An Egg (4), Throw Food (7), Tap Simulator REBORN (27) | Faible par joueur, volume immense (2 passes) | Faible à moyen : les systèmes sont simples, le contenu est de la donnée | Très élevé (« Throw a Seed » a 14 K joueurs à 10 jours) | Rapide : -11,6 %/semaine, -45 %/mois |
| B. Action RPG de progression | Blox Fruits (3), STAND OUT (5), AoT Revolution (6), Bloodlines (9) | Élevée : 6 à 19 passes, paliers supérieurs de 800 à 4 149 Robux | Élevé : combat, contenu, équilibrage | Moyen | Lent ; top de rétention |
| C. Compétitif à cosmétiques | RIVALS (1), Practical Basketball (10), Blade Ball (13), Forsaken (19) | Élevée, sans avantage payant (cosmétiques, caisses, passe de saison) | Élevé : réseau, anti-triche, appariement | Moyen | Lent si l'échelle de compétences tient |
| D. Tower defense à unités à collectionner | Anime Adventures (2), Tower Defense Simulator (12), Cameraman TD (30) | Élevée : Tower Defense Simulator a 23 passes de 55 à 7 999 Robux ; Anime Adventures n° 2 avec 61 K joueurs en ligne | Moyen à élevé ; très piloté par des données (unités, vagues, cartes) | Moyen à élevé ; Cameraman TD (83 jours) est n° 30 en dépenses et n° 10 en rétention | Lent |
| E. Incrémental / hasard | Sol's RNG (20), Pet Simulator 99 (15) | Moyenne | Faible | Très élevé (15 des 97 nouveaux jeux qui montent) | Moyen |
| F. Survie coopérative | 99 Nights (54), Forsaken (19), FERAL (23) | Moyenne | Moyen à élevé | Moyen | Rapide pour les jeux à structure finie (-35 %/mois) |
| G. Bac à sable / jeu de rôle | Brookhaven (66), Adopt Me (8), Dress To Impress (34) | Faible (Brookhaven n° 66 avec 299 K joueurs en ligne) | Élevé en contenu | Faible | Très lent |

**Ce qui en ressort pour un programme de variantes** [H] :
- **A, D et E** partagent le plus de systèmes avec une base commune : économie à deux monnaies, collection avec raretés, boutique, événements, entonnoir d'accueil, configuration. La boucle de minute en minute et le sujet sont ce qui change d'un jeu à l'autre.
- **D (tower defense)** est la famille où la dépense par joueur élevée, la rétention publique élevée et un squelette piloté par des données se rejoignent. C'est la première famille que j'évaluerais pour la grille du §8.
- **A** est la porte d'entrée la plus rapide mais la plus encombrée ; elle ne donne un avantage que par la vitesse, la finition et un sujet vraiment distinct.
- **B et C** exigent des mois de contenu ou d'infrastructure ; à n'envisager qu'après un premier retour de l'expérience.

### 4.4 La rétention : diagnostic officiel [P]

| Symptôme | Cause probable | Correction |
|---|---|---|
| D1 faible, rebond élevé | Accueil, performance, décalage avec la miniature | Analyse d'entonnoir, accueil plus court, métadonnées exactes, test sur mobile modeste |
| D7 faible | La progression se tarit ou n'est pas claire | Objectifs courts et moyens, variété, courbe de difficulté |
| D30 faible | Pas de fin de jeu | Social (échanges, groupes, compétition), collections, mise à jour toutes les 2 à 4 semaines, grosse mise à jour tous les 2 à 3 mois |

Les genres à D30 naturellement faible ne sont pas pénalisés : un jeu fini est viable si D1 et jours 2 à 7 sont forts. Les repères « D1 30 à 40 %, conversion payante 2 à 5 % » circulent sur des blogs [S, méthode inconnue] ; Roblox ne publie pas de pourcentage universel. Le tableau de bord compare ton jeu à des jeux similaires (affichage en bande du 50e au 90e centile pour au moins une métrique de Creator Rewards [P]), ce qui vaut mieux qu'un chiffre inventé.

### 4.5 Aléatoire et probabilités : règles et mathématiques

Règles officielles [P : `paid-random-items`, 2026-07-07 ; DevForum du 2026-05-26 lu le 16/11] : indiquer tous les résultats possibles et leurs probabilités numériques en pourcentage, total exactement 100 % ; vaut pour les monnaies achetées avec des Robux et les clés ou relances indirectes ; les effets des boosts de chance ou de pitié doivent être affichés en chiffres et les probabilités mises à jour ; aucun résultat « rien » ; lire `PolicyService:GetPolicyInfoForPlayerAsync()` et son champ `ArePaidRandomItemsRestricted`, et prévoir une alternative conforme (voie gratuite, ordre non aléatoire, achat direct au prix de l'espérance, masquage). Violation : retrait possible.

Mathématiques [calc] (p = probabilité par tirage) : tirages attendus 1/p, médiane ≈ 0,693/p. À p = 1 %, 37 % des joueurs n'ont rien obtenu après 100 tirages et 5 % après 300 : c'est la source de départs et de plaintes. Une pitié dure à N tirages ramène la moyenne à (1-(1-p)^N)/p (63,4 tirages pour p = 1 % et N = 100). Deux dimensions aléatoires indépendantes se multiplient (Steal An Egg : base × mutation × taille) : le haut de la distribution est mince par construction, donc les revenus se concentrent chez quelques joueurs ; prévoir des puits. Calculer l'espérance de gain par tirage de chaque nouvel objet d'événement (exemple de Roblox : un objet à 0,1 % de 1 000 G ajoute ≈ 1 G à une moyenne de 14 G).

Principes de conception [H] : chaque tirage rapporte quelque chose ; afficher les chiffres tôt ; pitié affichée ; voie gratuite à côté de la voie payante ; stock tournant à horloge commune (Blox Fruits : 4 h et 2 h) plutôt que minuteries individuelles ; monnaie d'événement séparée avec puits de fermeture ; cooldowns ; échanges protégés contre les arnaques. **Ne pas concevoir pour la compulsion** : le public est en grande partie jeune, Roblox a retiré Steal An Egg quelques heures et durci ses règles, et la réglementation avance [S/P, §2.7].

### 4.6 Le social et ce qui se filme

Roblox est un lieu de rencontre : « les utilisateurs deviennent du contenu les uns pour les autres, c'est pourquoi les jeux solo peinent à construire une audience » [P]. Un lancement a besoin d'une boucle jouable seul (un serveur vide tue un lancement [H]) et d'un multiplicateur de co-jeu (signal RFY). Mécaniques qui se filment seules : enjeu humain sur ce que l'on porte (vol d'œuf, 10 à 30 secondes de tension), révélation d'un tirage rare, panique coopérative (99 Nights). Prévoir une option « masquer l'interface » pour les créateurs de contenu [P]. Serveurs de 5 à 8 joueurs pour les boucles à enjeu entre joueurs, plus grands pour la coopération ou le bac à sable [S/H].

### 4.7 Opérations en direct

[P : `production/game-design/liveops-essentials`, lu le 16/11] Cadence d'une mise à jour toutes les 2 semaines à 1 mois, **moins de 3 semaines d'effort chacune, sur des systèmes existants** (un nouveau système fait une extension, insoutenable) ; contenu artistique en priorité (familiers, cartes, recolorations, quêtes) ; calendrier fixe ; ne promettre que ce qui peut sortir. Pratique de l'industrie mesurée : jour fixe (vendredi ou samedi), session en direct avant la mise à jour, objets limités qui partent avec la mise à jour, annonce à compte à rebours [mesure 16/11]. Le contenu doit être de la donnée : une mise à jour hebdomadaire n'est soutenable que si ajouter un biome, un boss ou des familiers ne demande pas de code [H].

### 4.8 Boutique et économie de jeu [P]

Deux monnaies (douce gagnée, dure achetée en Robux) ; ne jamais exiger de Robux pour une mission ; moments d'achat contextuels (pendant le jeu, avant, au salon, écran de chargement, fenêtre modale) en évitant d'empiler les fenêtres ; l'achat de Robux prend des secondes, donc proposer quand le jeu peut s'arrêter ; pack de départ dans les premières minutes mais pas au tout premier chargement ; passe de saison d'environ 10 paliers sur environ un mois avec 1 semaine de pause, pistes gratuite et payante, dernière récompense retirée ensuite, double expérience la dernière semaine ; équilibrer sources et puits avant chaque événement ; tester les prix avec Experiments.

### 4.9 Pièges observés

Jeux liés à un mème qui déclinent avec lui ; vagues de clones qui compressent la fenêtre ; perception de pression à payer dans les jeux sociaux ; inflation de monnaie d'événement ; tutoriels trop longs ; épuisement d'une cadence intenable ; dépendance à l'algorithme (chutes de 400 à 500 joueurs en ligne à environ 100 rapportées après le changement de juin 2026 [S, réponses du DevForum]).

---

## 5. Économie et monétisation

### 5.1 Règles d'argent vérifiées [P, lues en entier le 2026-11-18]

| Règle | Contenu | Page, dernier commit |
|---|---|---|
| Part du créateur | 70 % des Robux dépensés en passes et developer products, 30 % de frais Marketplace | `get-started/monetization`, 2026-07-07 |
| DevEx standard | 0,0038 $ par Robux gagné ; 114 $ pour 30 000 ; avant le 2025-09-05 à 10 h PT : 0,0035 | `production/monetization/developer-exchange`, 2026-07-07 |
| Conditions DevEx | 13 ans minimum ; 30 000 Robux gagnés ; e-mail vérifié ; compte du portail DevEx ; formulaire W-9 ou W-8 ; respect des conditions d'utilisation. Pas de Premium dans la liste | idem |
| Taux 18+ américain | 0,0054 $ pour les achats de passes, developer products, abonnements et serveurs privés faits par des Américains de 18 ans et plus vérifiés ; **le jeu doit être 100 % R15** (un accès possible à R6 disqualifie le jeu) ; contrôle automatique continu ; en vigueur le 2026-06-08 | `production/monetization/18-plus-devex-rate`, 2026-08-25 ; 8-K |
| Creator Rewards, engagement | 5 Robux par jour et par « Active Spender » (au moins 9,99 $ d'achats dans les 60 derniers jours) qui joue 10 minutes ou plus, si ton jeu est l'un de ses trois premiers lancés ce jour-là | `creator-rewards`, 2026-10-15 |
| Creator Rewards, Audience Expansion | 35 % des 100 premiers dollars d'achats d'un nouvel utilisateur ou d'un utilisateur de retour attribué à ton jeu, sur 60 jours ; il faut 100 joueurs par jour de moyenne pendant 60 jours après | idem |
| Roblox Plus | Remise de 10 % puis 20 % dès le 3e mois, **payée par Roblox** (ton gain par achat ne baisse pas) ; prime de **250 Robux par mois pendant les 3 premiers mois consécutifs, jusqu'à 750 Robux par nouvel abonné** amené depuis ton jeu avec `PromptRobloxSubscriptionPurchase` (blocage de 60 jours) ; jusqu'à 100 Robux par abonné et par mois pour 60 minutes en serveur privé payant ; 10 % sur les transferts de Robux envoyés dans ton jeu | `production/monetization/roblox-plus`, 2026-07-14 |
| Vidéo récompensée | Publicité en plein écran de 6 à 30 secondes qui donne une récompense ; conditions : 13 ans et plus, compte vérifié par pièce d'identité, jeu public avec **au moins 2 000 visiteurs uniques par mois** | `production/promotion/rewarded-video-ads`, 2026-11-13 |
| Publicités immersives | Revenus en Robux à l'impression, à la vidéo vue 15 s ou à la téléportation ; paiement le 25 du mois suivant | `production/monetization/immersive-ads` |
| Vente en dollars | Modèles et plugins vendus en dollars : 100 % du net, seuls impôts et frais de paiement déduits, hors frais de plateforme et taux DevEx ; compte vendeur via Stripe | `production/creator-store`, 2026-10-13 |
| Objets aléatoires payants | Voir §4.5 | `production/monetization/paid-random-items`, 2026-07-07 |

### 5.2 Économie unitaire [calc ; hypothèses signalées]

- **Prix du Robux** : environ 0,0125 $ au tarif standard (400 Robux pour 4,99 $) [S : guides tiers ; achat en application moins avantageux ; non vérifié sur page Roblox]. D'où 80 Robux par dollar dépensé.
- **Part qui arrive au créateur** : 80 × 70 % = 56 Robux ; × 0,0038 = **0,213 $** par dollar dépensé (≈ 21 %) ; × 0,0054 = **0,302 $** (≈ 30 %) pour un achat américain 18+ en jeu R15. Le taux 18+ vaut +42 % par Robux, mais ne concerne que ces achats.
- **Contrôle sur la plateforme** : frais DevEx 403 M$ pour 1,7 Md$ de réservations au T3 = 23,7 % [calc sur P].
- **Seuil de premier retrait** : 30 000 Robux gagnés = 114 $, soit ≈ 536 $ de dépenses de joueurs au taux standard.
- **Valeur d'un joueur-jour moyen sur Roblox** : 1 697 M$ de réservations ÷ (138 M × 92 jours) = **0,134 $ de réservations par joueur-jour** ; 403 M$ de DevEx ÷ la même base = **0,032 $ de DevEx par joueur-jour** [calc]. C'est une **moyenne tirée vers le haut par les plus gros jeux** : la plupart des jeux sont en dessous [H].

| Joueurs par jour | Monétisation = 100 % de la moyenne | 30 % | 10 % | 3 % |
|---|---|---|---|---|
| 1 000 | ≈ 950 $ / mois | ≈ 285 $ | ≈ 95 $ | ≈ 29 $ |
| 10 000 | ≈ 9 500 $ / mois | ≈ 2 850 $ | ≈ 950 $ | ≈ 285 $ |

Montants en dollars DevEx avant impôts et coûts. Ce tableau donne un **ordre de grandeur de plafond**, pas une prévision.

- **Rentabilité d'une publicité** : si un lecteur acquis donne A jours actifs en moyenne et que ton jeu monétise à une fraction f de la moyenne de plateforme, le gain DevEx par lecture est A × f × 0,032 $. Il couvre le coût par lecture (0,0073 à 0,0187 $) si f ≥ 0,23 à 0,59 / A, en supposant 1 lecture = 1 nouveau joueur (cas le plus favorable).

| Jours actifs par joueur acquis | f minimal (CPP 0,0073 $) | f minimal (CPP 0,0187 $) |
|---|---|---|
| 1 | 23 % | 59 % |
| 2 | 12 % | 29 % |
| 5 | 5 % | 12 % |

Lecture : une publicité ne paie que si le jeu monétise déjà à une part notable de la moyenne et retient plusieurs jours. D'où la règle de Roblox : D1 et D7 d'abord, acquisition payante ensuite. Les CPP de 2026 et la part de lectures qui deviennent des joueurs distincts sont **inconnus** [?] : le premier test publicitaire sert à les mesurer.

### 5.3 Ce que vendent les jeux qui rapportent (échelles de passes) [mesure 18/11, passes uniquement]

| Jeu (rang en dépenses) | Passes | Prix min / médian / max (Robux) | Plus chères |
|---|---|---|---|
| Steal An Egg (4) | 2 | 299 à 467 | x2 argent, x2 vitesse de croissance |
| Throw Food (7) | 2 | 99 à 149 | x2 entraînement, x2 argent |
| RIVALS (1) | 9 | 59 à 1 425 | paquets de cosmétiques |
| Anime Adventures (2) | 5 | 99 / 299 / 1 299 | « Shiny Hunter » 1 299, afficher toutes les unités 699 |
| STAND OUT (5) | 6 | 80 / 250 / 800 | serveurs privés 800, « Builder » 800 |
| AoT Revolution (6) | 12 | 79 / 449 / 4 149 | « Ymir's Blessing » 4 149, « Family Bag » 1 649 |
| Bloodlines (9) | 13 | 149 / 399 / 999 | couleur de chakra 999, extension de banque 749 |
| Practical Basketball (10) | 11 | 190 / 299 / 899 | saison 1 899, VIP 799 |
| Fisch (11) | 9 | 99 / 239 / 499 | confort : vendre/évaluer partout |
| Tower Defense Simulator (12) | 23 | 55 / 450 / 7 999 | « Sandbox Plus+ » 7 999 |
| Beyond Nen (18) | 19 | 99 / 299 / 1 599 | objets de combat |
| Sol's RNG (20) | 7 | 40 / 100 / 499 | passe de saison 499 |
| Forsaken (19) | 4 | 189 / 349 / 599 | VIP 599 |
| Blade Ball (13) | 4 | 112 / 240 / 240 | VIP, double pièces |

**Lecture** : les jeux de masse rapides (A) ont peu de passes bon marché et gagnent par le volume ; les jeux profonds (B, C, D) ont de 4 à 23 passes, le plus souvent 9 ou plus, et un palier supérieur de 800 à 8 000 Robux pour la plupart (exceptions : Sol's RNG, Forsaken, Blade Ball), avec une échelle de confort et d'expression. **Limite** : les ventes de developer products (consommables, caisses) sont invisibles de l'extérieur ; l'échelle de passes est une vue partielle.

### 5.4 Leviers supplémentaires, avec leurs conditions exactes

| Levier | Valeur indicative | Condition | Pour ton cas |
|---|---|---|---|
| Prime Roblox Plus | jusqu'à 750 Robux (≈ 2,85 $ DevEx) par nouvel abonné [calc] | Prompt depuis le jeu à des joueurs engagés ; vérifier `HasRobloxSubscription` côté serveur avant récompense ; blocage 60 jours | Faible coût de mise en œuvre ; à placer après un moment de réussite, jamais au premier chargement |
| Audience Expansion | jusqu'à 35 $ par joueur attribué (35 % de 100 $, plafond théorique) [calc] ; conversion en Robux non précisée [?] | Nouvel utilisateur de Roblox ou de retour après 60 jours, lien de partage ; 100 joueurs par jour de moyenne pendant 60 jours | Le seul levier qui paie une acquisition **hors** Roblox : à brancher sur les partenariats TikTok et YouTube |
| Engagement quotidien | 5 Robux (≈ 0,019 $) par Active Spender et par jour | 10 minutes ; l'un des 3 premiers jeux du jour | Complément, pas un modèle |
| Vidéo récompensée | non publié [?] | 2 000 visiteurs uniques par mois ; ≥ 13 ans ; pièce d'identité | Première recette possible pour un jeu à faible conversion ; plus de 20 % des jeux qui l'utilisent en tirent plus de 10 % de leurs gains [P, lettre T3 lue le 16/11] |
| Serveurs privés payants | jusqu'à 100 Robux par abonné Plus et par mois | 60 minutes en serveur privé | Marginal ; utile si le jeu est un lieu où des groupes d'amis s'installent |
| Vente de modèles et plugins en dollars | 100 % du net | Compte vendeur Stripe ; catégorie « Gameplay » existante | Piste hors jeu : la base commune peut devenir un produit (§7 S11) |
| Tarification régionale | +4 à +10 % de dépense moyenne selon Roblox | Activée par défaut pour les jeux neufs ; ne jamais coder les prix en dur ; tests de prix : ≈ 60 000 transactions sur 30 jours [P, lu le 16/11] | Lire les prix par `MarketplaceService`, jamais en dur |

### 5.5 Structure juridique et financière

Les jeux de groupe suivent le même taux DevEx ; les versements uniques et récurrents entre membres respectent le taux 18+ et la gestion des revenus de groupe [P : 18-plus]. 29 des 30 premiers du classement des dépenses appartiennent à un groupe [mesure 18/11]. Les récompenses Creator Rewards sont versées en Robux gagnés avec 60 jours de blocage et suivent les conditions DevEx. Ads Manager accepte les jeux de groupe, un compte publicitaire par groupe, et la conversion de Robux en crédits publicitaires (irréversible, 13 ans et plus) [P : `ads-manager`].

---

## 6. Technique : la plateforme vue de l'ingénieur

Toutes les limites chiffrées ci-dessous viennent des pages officielles citées (dernier commit indiqué), sauf mention.

### 6.1 Frontière client-serveur et sécurité [P : `scripting/security/*`, 2026-07 à 2026-11]

- **Principe** : concevoir pour que la triche soit impossible ou sans intérêt, plutôt que de la détecter après coup (exemple de Roblox : ne plus donner de points pour tuer un joueur qui vient d'apparaître).
- **Le serveur décide** de l'argent, des dégâts, de l'inventaire, des tirages et des récompenses ; le client demande.
- **Valider chaque argument de RemoteEvent et RemoteFunction** : contexte et permission, type et structure, valeurs (bornes), et le piège des `NaN`. Limiter le débit (exemple officiel : seau à jetons). Sécuriser aussi `ProximityPrompt`, `ClickDetector`, `DragDetector`.
- **Achats** : toute validation et toute attribution côté serveur via `ProcessReceipt` ; ne jamais se fier à un signal client comme `PromptProductPurchaseFinished`. Un seul rappel `ProcessReceipt` pour le jeu ; attribution idempotente par `PurchaseId` ; ne renvoyer `PurchaseGranted` qu'après sauvegarde réussie [P-local + règle du dépôt].
- **Magasins de données** : jamais d'accès depuis le client ; manipulation des clés traitée dans la page de sécurité.
- **Jeux d'argent et d'objets rares** : journaliser (joueur, œuf, résultat, boosts actifs) pour les litiges ; tirages sur le serveur avec un générateur à graine auditable [H].
- **Jeux de vol ou de combat** : ne jamais faire confiance aux positions du client pour résoudre un vol ; vérifier la proximité et les délais côté serveur [H].
- **Cadre du dépôt** (`.claude/roblox-rules.md`) : `--!strict`, `task.*`, modules entiers et petits, pas de `_G`, suffixe `_Studio` pour les magasins de données en test.

### 6.2 Architecture de la base commune (proposition [H])

Couches, de la plus stable à la plus changeante :

1. **Noyau** (identique pour tous les jeux) : données du joueur, économie (monnaies, sources, puits), passerelle des remotes (validation, débit), achats et `ProcessReceipt`, configuration, télémétrie, minuteries serveur.
2. **Fonctionnalités** (activables par jeu) : boutique, quêtes et missions, passe de saison, bundles, collection et raretés, tirages avec cotes affichées, événements hebdomadaires, classements, échanges, serveurs privés.
3. **Contenu** (données, pas du code) : définitions d'unités, d'objets, de zones, de vagues, de tables de gains dans des `ModuleScript` ou des configurations ; une mise à jour hebdomadaire = de la donnée.
4. **Habillage** (spécifique au jeu) : monde, direction artistique, sons, interface, titre, miniatures, boucle de minute en minute.

**Règle de visibilité** : la règle sur les jeux non uniques porte sur les **métadonnées et le fichier de place** (§3.2). Les couches 1 à 3 sont invisibles pour un joueur ; ce sont les couches 3 et 4 qui doivent différer nettement entre deux jeux de ton portefeuille (monde, sujet, art, nom, miniature, mécanique de risque).

**Outils officiels à évaluer** (à décider avec toi, car chacun ajoute une dépendance) :
- **Feature Packages** (missions, passe de saison, bundles, récompenses d'engagement) : fonctions prêtes avec code serveur, interface par défaut et analyses d'entonnoir ; il faut aussi le paquet « Core » ; déposés dans `ReplicatedStorage` ; configurés dans des `ModuleScript` ; la page des missions indique « bêta » [P : `resources/feature-packages/*`, 2026-07 à 2026-08]. Gain : moins de code à écrire. Risque : bêta, comportement imposé, conformité à valider.
- **Packages** (conversion d'un modèle en paquet réutilisable, mise à jour automatique, historique de versions) [P : `projects/assets/packages`, 2026-10-14] : adaptés à l'interface et aux assets partagés. Le flux actuel `deploy_luau.py` reste préférable pour le code, car il est scriptable, vérifie la syntaxe et détecte les conflits avec Studio.
- **ConfigService** (jusqu'à 1 000 configurations actives, valeurs modifiables sans republier, ciblage par joueur) et **Experiments** (jusqu'à deux variantes plus un témoin, jusqu'à 3 métriques personnalisées) [P : `production/configs` 2026-08-20, `production/experiments` 2026-11-17] : pour régler prix, quantités, minutage d'indices.

### 6.3 Données et quotas [P : `cloud-services/data-stores/*`, 2026-08 à 2026-10]

**Limites des magasins de données standard :**

| Élément | Limite |
|---|---|
| Nom de magasin, clé, portée | 50 caractères chacun |
| Valeur d'une clé | 4 194 304 caractères |
| Débit par clé (toutes les instances) | lecture 25 Mo/min ; écriture 4 Mo/min (arrondi au Ko supérieur par requête) |
| Budget de l'expérience, lectures | 300 + 40 × joueurs simultanés par minute |
| Budget de l'expérience, écritures | 300 + 20 × joueurs simultanés par minute |
| `UpdateAsync` | consomme **à la fois** un budget de lecture et un d'écriture |
| Files d'attente | 30 requêtes par file ; au-delà, erreurs 301 à 306 (requête abandonnée) |
| Stockage de l'expérience | 500 Mo + 1 Mo × nombre d'utilisateurs ayant déjà rejoint le jeu (taille compressée, dernière version seulement) |
| Open Cloud | partage le même budget que le jeu |

**Budgets calculés** [calc] : 50 joueurs simultanés → 2 300 lectures et 1 300 écritures par minute ; 200 → 8 300 et 4 300 ; 1 000 → 40 300 et 20 300 ; 5 000 → 200 300 et 100 300.

**Bonnes pratiques officielles** : peu de magasins, une ou quelques clés par joueur, motifs de clés statiques avec préfixes ; garder une copie en mémoire du serveur et sauvegarder périodiquement, au départ du joueur, à l'arrêt du serveur et aux points critiques ; étaler les requêtes récurrentes ; `pcall` avec réessais à reculs exponentiels et gigue, nombre et délais plafonnés ; préférer `UpdateAsync` à `SetAsync` ; fragmenter les clés chaudes ; supprimer les données de test ; prévoir le traitement du droit à l'effacement (jeunes utilisateurs).
**Test dans Studio** : l'accès aux magasins est désactivé par défaut, et lorsqu'il est activé il touche les **mêmes magasins** que la production : utiliser un nom de magasin distinct en Studio (règle du dépôt).
**Données qui se modifient souvent** (stock global, classements) : une clé unique écrite par tous les serveurs dépasse vite le débit par clé ; utiliser MemoryStore ou fragmenter.

**MemoryStore** [P : `cloud-services/memory-stores/index`, 2026-10-22] : mémoire = 64 Ko + 1,2 Ko × joueurs ; budget de requêtes = 1 000 + 120 × joueurs par minute ; une table triée ou une file : 1 000 000 d'éléments et 100 Mo au maximum ; limite par partition d'environ 30 000 unités de requête par minute (estimation que Roblox peut changer ; les tables de hachage se répartissent, les tables triées et les files restent sur une partition) ; éviction par durée de vie. À 1 000 joueurs, le quota mémoire n'est que d'environ 1,26 Mo : à réserver aux petits objets (stock, files, annonces).
**MessagingService** [P-local] : sujet de 1 à 80 caractères, message de 1 kilo-octet, par serveur 600 + 240 × joueurs par minute à l'émission : à réserver aux annonces globales et aux événements, pas au flux de données.
**Téléportation** : `TeleportService` et serveurs réservés pour séparer des lieux ou des événements ; un grand lieu peut être découpé, ce qui réduit le temps de connexion initial mais ajoute un temps de téléportation [P : `performance-optimization/design`, 2026-11-10].

### 6.4 Performance et réseau [P : `performance-optimization/*`, `workspace/streaming/*`, `luau/native-code-gen`]

- **Budget d'image** : 60 images par seconde = 16,67 ms. Préférer le code événementiel au calcul à chaque image ; fractionner les calculs longs (exemple officiel : 5 ms par image) ; Luau parallèle pour le calcul pur ; déconnecter les connexions inutiles ; ne pas tout mettre dans `ReplicatedStorage` (le client charge tout ce qui s'y trouve) : utiliser `ServerStorage` pour ce que le client n'a pas besoin de voir.
- **Appareils modestes** : les mobiles ont des limites de mémoire sévères et plantent en cas de dépassement ; choisir un appareil de référence et tester dessus pendant tout le développement ; l'émulateur de Studio n'est pas fiable pour la mémoire. L'exemple de Roblox (moins de 1 000 appels de dessin et 1 000 000 de triangles) vaut pour **son** appareil de référence, pas comme budget universel ; il n'existe pas de budget chiffré officiel de pièces ou d'instances [?].
- **Instance streaming** : activé par défaut pour les nouveaux lieux ; améliore le temps de connexion, la mémoire et la fréquence d'images ; `StreamingTargetRadius`, `StreamingMinRadius`, `StreamOutBehavior` (par défaut `LowMemory`) ; modèles SLIM pour les foules.
- **Réseau** : répliquer au changement, pas à chaque image ; charges utiles minimales (l'objet acheté, pas l'inventaire) ; effets et animations côté client, le serveur ne gère que l'état qui décide du résultat ; `UnreliableRemoteEvent` pour les effets éphémères ou les données qui changent en continu (non garanti, non ordonné) ; surveiller `ProcessPackets` [P + P-local].
- **Boucles de familiers et de revenus passifs** : stocker un horodatage et un taux, calculer à la demande, plutôt qu'une boucle par familier et par seconde (principal poste CPU des jeux de familiers) [H].
- **Code natif** : `--!native` en tête de script ou attribut `@native` par fonction ; pris en charge pour les scripts serveur et les scripts client **sur Android** seulement, à ce jour [P : 2026-11-03] ; à réserver aux fonctions de calcul intensif, après mesure.
- **Temps de connexion** : un chargement long est lui-même un rebond de première session ; alléger `ReplicatedFirst`, limiter `PreloadAsync`, proposer d'ignorer le chargement, différer les interfaces non ouvertes.
- **Textures** : la mémoire croît avec le nombre de pixels (1024² = 4 fois 512²) ; les matériaux intégrés consomment bien moins que des textures personnalisées ; convertir les assets en paquets pour éviter les doublons.

### 6.5 Télémétrie et expériences [P : `production/analytics/*`, 2026-07 à 2026-10]

- **Événements personnalisés** : jusqu'à 100 par jeu ; préférer **un événement avec des champs personnalisés** à plusieurs noms d'événements (limite de cardinalité plus stricte sur les noms) ; les graphiques se remplissent en 24 heures.
- **Entonnoirs** : jusqu'à 10 par jeu ; `AnalyticsService:LogOnboardingFunnelStepEvent` pour l'accueil ; l'étape enregistrée d'un joueur expire après 180 jours sans événement.
- **Événements d'économie** : sources et puits typés (par exemple achat contre Robux, récompense minutée) pour le tableau de bord d'économie : plus gros puits, plus grosses sources, solde moyen.
- **Spécification minimale à écrire avant le premier prototype** [H] : étapes d'accueil (arrivée, première action, premier gain, première amélioration, fin de l'accueil), jours actifs, durée de session, sources et puits de chaque monnaie, vues de la boutique, tentatives d'achat, achats réussis, tirages, abandons juste après un échec, invitations de groupe, vues des cotes.
- **Tableaux de bord de Roblox à lire** : Home Recommendations (signaux RFY), Audience Reach (progression vers Kids and Select), rétention D1, D7, D30, benchmarks par jeux similaires (jeux de comparaison d'au moins 100 joueurs par jour), rétention par source d'acquisition.

### 6.6 Plateformes, interface et publication

- **Mobile d'abord** : la majorité des joueurs est sur mobile, beaucoup sur appareils modestes ; interface en échelle (Scale) et non en décalage (Offset), `TextScaled` avec `UITextSizeConstraint`, icônes plutôt que texte pour les jeunes lecteurs [P + règle du dépôt]. Pas d'émoji dans l'interface du jeu (règle du dépôt).
- **R15 uniquement** pour le taux 18+ : Paramètres d'avatar du projet → « R15 Only » ; animations en R15 ; surveiller que les systèmes d'avatar personnalisés respectent la règle [P].
- **Publication** : miniature personnalisée obligatoire pour les impressions sur Home ; questionnaire de classification de contenu ; titre sans cadeau en tête ; bande-annonce et localisation recommandées pour Standout Games [P].
- **Studio et assets** : Studio expose des outils de génération (maillage, texture, matériau, scène, avatar) via le serveur MCP [P : liste des outils, 2026-11-17] ; tout asset de la Toolbox est vérifié avant usage (chercher `require(` suivi d'un nombre, `getfenv`, `loadstring`) ; supprimer les scripts des modèles gratuits.

### 6.7 Chaîne de travail Claude Code, Studio et GitHub

Ce qui existe : passerelle locale (démarrée par le serveur MCP de la session), `tools/studio.py` (état, Play, Stop, console, scripts Edit/Server/Client, capture), `tools/deploy_luau.py` (vérification de syntaxe, détection de conflit avec le dernier export, envoi), `tools/export_studio.py`, `tools/save_game.sh` (export, carte, commit, push). Particularités : numéros de ligne d'erreur décalés de +1 ; envoi uniquement en mode Edit ; refus d'envoi si Studio a changé depuis l'export.
Propositions [H] :
- **Séparer le code pur du code Roblox.** Les modules sans API Roblox (mathématiques d'économie, cotes, tables de gains, simulation de tirages, calcul de progression) peuvent se tester hors de Studio avec les binaires Luau que l'outil de déploiement télécharge déjà dans `~/.cache/luau` : `luau.exe` exécute un script, `luau-analyze.exe` en vérifie les types. Vérifié le 2026-11-18 : une simulation de 200 000 séries à p = 1 % tourne hors Studio et donne une moyenne de 100,3 tirages, une médiane de 70 et 36,8 % de joueurs sans succès après 100 tirages, ce qui confirme les formules du §4.5. Limite : les globales propres à Roblox (`Random.new`, `Instance`, `game`) n'existent pas hors de Studio ; un module pur reçoit donc sa source aléatoire en paramètre. Ces tests sont le meilleur remède à « une tâche sur deux du premier coup » : un test qui échoue vite, sans consommer de session Studio.
- **Les modules qui touchent l'argent ou les données** (achats, `ProcessReceipt`, sauvegarde, échanges, tirages payants) passent par l'agent `critical`, avec test des chemins d'échec (coupure, double appel, remboursement).
- **Test dans Studio** : Play, scripts client qui simulent les parcours, console, capture ; `TestService` existe dans la référence moteur [P-local], à évaluer pour des tests automatisés dans Studio.
- **Mesure externe quotidienne** : une capture quotidienne des classements publics (§2.4) dans un fichier daté, pour détecter tôt les squelettes qui montent. L'outil `charts` le permet déjà en une commande.

---

## 7. Stratégies pour ton cas

Chaque stratégie : pourquoi (preuve), comment, coût, risque, critère de réussite. Les numéros S1 à S12 sont réutilisés au §11.

**S1. Moteur invisible, jeu visible.**
Pourquoi : la règle sur les jeux non uniques [P] menace un programme de variantes qui se ressemblent ; le meilleur exemple de réutilisation d'un squelette (Steal An Egg puis Throw Food) a changé le sujet, la mécanique de lancer et la taille des serveurs (7 puis 5 joueurs) [mesure].
Comment : mutualiser le noyau, les fonctionnalités et le format de contenu (§6.2) ; imposer entre deux jeux du portefeuille des différences de monde, de sujet, d'art, de nom, de miniature et de mécanique de risque. Test : montrer côte à côte les pages de deux jeux à un tiers ; s'il les confond, ils sont trop proches.
Coût : conception initiale de la base. Risque : confondre « configuration différente » et « jeu différent ».

**S2. Cibler les 16 ans et plus d'abord, puis ouvrir aux plus jeunes.**
Pourquoi : un jeu neuf est de toute façon 16+ au départ (§3.2) ; les genres profonds, à forte rétention publique et à forte dépense par joueur, visent des joueurs plus âgés ; Roblox dit lui-même que RPG, stratégie, puzzle et shooter manquent malgré une forte demande des tranches plus âgées [P] ; le taux 18+ américain vaut +42 % par Robux ; 29 % des utilisateurs contrôlés ont 18 ans et plus [P].
Comment : concevoir la première version pour des joueurs de 16 ans et plus (R15 uniquement, interaction sociale, profondeur) ; viser Kids et Select ensuite, par l'objectif publicitaire dédié si nécessaire.
Coût : renonce au volume des jeux pour enfants. Risque : audience plus petite à lancer ; le gain de 42 % ne vaut que pour les achats d'adultes américains vérifiés.

**S3. Portefeuille d'expériences à règles d'arrêt.**
Pourquoi : le taux de base est proche de zéro pour un jeu isolé [S] ; le propriétaire de Steal An Egg a lancé 7 petits jeux avant le succès [mesure] ; 33 % du classement des dépenses a moins de 6 mois [mesure].
Comment : cycle de 3 à 4 semaines par expérience ; paliers G0 à G3 du §9 ; une expérience en file dès qu'une autre atteint son premier pic ; journal des décisions dans le Doc ÉTAT.
Coût : travail soutenu, quota de Claude. Risque : épuisement, dispersion ; tuer trop tôt ou trop tard.

**S4. Lancement mesuré : calibrer avant de dépenser.**
Pourquoi : les CPP 2026 sont inconnus [?] ; une publicité ne paie que si le jeu monétise et retient (§5.2) ; les benchmarks de Roblox demandent des jeux d'au moins 100 joueurs par jour ; les signaux des joueurs venus de la publicité ne comptent pas dans RFY [P].
Comment : un petit budget de test (exemple : 50 à 150 $, soit environ 2 700 à 20 500 lectures aux CPP de 0,0073 à 0,0187 $ [calc]) pour mesurer le vrai CPP, la part de lectures devenues joueurs, D1 et le rebond ; viser environ 100 joueurs par jour pour obtenir les benchmarks (≈ 1 à 6 $ par jour pour 100 à 300 lectures par jour [calc]) ; lire la rétention **par source d'acquisition**.
Coût : le budget de test (décision n° 2, §11). Risque : confondre le trafic payant avec le signal organique.

**S5. Partenariats de créateurs alignés sur les primes de Roblox.**
Pourquoi : Roblox et YouTube sont les deux plateformes principales de beaucoup de joueurs [P] ; Audience Expansion paie des nouveaux joueurs de Roblox attribués par lien de partage, et les membres Video Stars peuvent percevoir ces récompenses [P].
Comment : cibler des publics qui ne sont pas encore sur Roblox (TikTok, YouTube hors Roblox) ; prévoir dans le jeu un moment qui se filme et l'option « masquer l'interface » ; liens de partage suivis par partenaire ; vérifier avec Roblox les conditions réelles avant de promettre un partage de gains [?].
Coût : à négocier ; tarifs de l'industrie non vérifiés [S]. Risque : la prime ne couvre que les nouveaux utilisateurs et exige 100 joueurs par jour de moyenne pendant 60 jours.

**S6. Monétisation en deux temps.**
Pourquoi : Steal An Egg a ajouté ses deux passes 9 jours après le lancement et a baissé leur prix pendant son week-end record [mesure] ; les gros gagnants ont des échelles plus profondes [§5.3] ; les jours de dépense et les Robux dépensés sont des signaux RFY.
Comment : avant le lancement, seulement la télémétrie d'économie et le squelette `ProcessReceipt` (sous revue `critical`) ; après les premières preuves de rétention, 2 à 3 passes simples, puis une échelle (consommables, expression, passe de saison, abonnement) ; prompt Plus après un moment de réussite ; vidéo récompensée dès 2 000 visiteurs uniques par mois ; tests de prix par Configs et Experiments.
Coût : faible au départ. Risque : monétiser avant la rétention ; pression à payer perçue comme excessive.

**S7. Rituel hebdomadaire et contenu en données.**
Pourquoi : tous les jeux du top, Blox Fruits excepté, publient chaque semaine, le vendredi ou le samedi entre 14 h et 20 h UTC [mesure] ; Roblox recommande moins de 3 semaines d'effort par mise à jour, sur des systèmes existants [P] ; les pics d'événements ne relèvent pas le lendemain mais entretiennent l'habitude [mesure].
Comment : un calendrier fixe, annoncé dans les événements d'expérience ; chaque mise à jour = une zone, un boss ou des familiers en données ; événement en direct avant la mise à jour ; objets limités qui partent avec elle.
Risque : promesses non tenues ; ne pas attendre de croissance des événements.

**S8. Structure de groupe et audience possédée.**
Pourquoi : 29 des 30 premiers en dépenses appartiennent à un groupe ; le groupe de Steal An Egg regroupe ≈ 41 % de ses joueurs uniques et a servi de lancement pour le jeu suivant [mesure] ; un accord privé [retiré de la copie publique] et la revente éventuelle d'un jeu sont des questions ouvertes de ton Doc ; les jeux de groupe suivent les mêmes taux DevEx et permettent des versements récurrents entre membres [P].
Comment : un groupe par jeu ou un groupe studio ; décider en fonction de la revente et du partage [accord privé] ; mettre l'invitation au groupe dans l'accueil ; vérifier la règle sur les récompenses pour rejoindre ou aimer avant de copier [?].
Risque : récompense pour un j'aime peut être sanctionnée [?] ; un groupe unique mélange les audiences de jeux différents.

**S9. La technique comme avantage de vitesse.**
Pourquoi : les jeux neufs qui montent sont copiés en 1 à 2 semaines [mesure] ; une chaîne qui mesure et corrige vite vaut plus qu'un gros contenu.
Comment : télémétrie dès le jour 1 (§6.5) ; configurations modifiables sans republier ; tests hors Studio des modules purs ; radar quotidien des classements publics ; évaluer les Feature Packages contre l'écriture maison (§6.2).
Risque : surinvestir dans l'outillage avant d'avoir un jeu.

**S10. Chercher la curation pour les jeux vraiment nouveaux.**
Pourquoi : Standout Games est une rubrique de Home choisie à la main pour des jeux « nouveaux » (mécaniques profondes, style visuel distinctif, genre sous-représenté) ; candidatures ouvertes ; recommandations : optimisation console et mobile, rigs R15, événements d'expérience, bande-annonce, localisation [P : 2026-08-25].
Comment : concevoir au moins une expérience du portefeuille pour ce critère ; préparer vidéo de gameplay et bande-annonce.
Risque : la sélection est discrétionnaire ; ne pas en faire la seule voie.

**S11. Revenus hors jeu : vendre la base.**
Pourquoi : la vente de modèles et plugins en dollars paie 100 % du net, hors frais de plateforme et hors taux DevEx (qui laisse ≈ 21 % du dollar du joueur) [P] ; une catégorie « Gameplay » existe.
Comment : quand le noyau est stable, publier un kit limité (économie, boutique, missions) avec une version gratuite pour la visibilité. Demande et prix du marché **inconnus** [?] : test à petite échelle.
Risque : support, concurrence des Feature Packages gratuits de Roblox.

**S12. Ce qu'il ne faut pas faire.**
Cloner un jeu viral avec les mêmes métadonnées (règle sur les copies) ; bâtir sur un mème ; flux de contenu récompensé, titres à cadeaux, cotes cachées ; croissance uniquement par publicité ; monétiser avant la rétention ; avantage payant dans un jeu social ; laisser du code qui touche l'argent sans revue ni test des échecs ; tester contre les magasins de données de production ; insérer des modèles de la Toolbox sans les auditer ; tenir une cadence qu'on ne peut pas soutenir.

---

## 8. Grille de décision pour choisir la base (sans concept proposé)

### 8.1 Barrières (réussite ou échec)

| N° | Barrière | Question |
|---|---|---|
| B1 | Audience | Le plan couvre-t-il la phase d'essai 16+ et les 250 joueurs très engagés sur 60 jours ? |
| B2 | Unicité | Deux jeux du portefeuille sont-ils indiscernables côté métadonnées et fichier de place ? |
| B3 | Politique | Cotes affichées, repli sans hasard, aucun flux récompensé, aucun titre à cadeau ? |
| B4 | R15 | Si on vise les adultes américains : le jeu est-il 100 % R15 ? |
| B5 | Film | Existe-t-il un moment de 10 à 30 secondes qui se filme seul ? |
| B6 | Cadence | Qu'est-ce qui sort chaque semaine, en moins de 3 semaines d'effort, sur des systèmes existants ? |

### 8.2 Notation (0 à 5 par critère, à remplir par toi ou avec moi, une fois le brief donné)

| Critère | Question | Poids suggéré [H] |
|---|---|---|
| Accroche | Un enfant ou un adolescent comprend-il le jeu en 5 secondes de vidéo ? | 15 % |
| Boucle sans monétisation | La boucle est-elle amusante sans récompense payante ? | 15 % |
| Progression | Objectifs court, moyen, long visibles ? Fin de jeu ? | 15 % |
| Social et viral | Des situations se partagent-elles seules ? Co-jeu naturel ? | 10 % |
| Dépense par joueur | La famille a-t-elle des preuves de dépense élevée (§2.3, §5.3) ? | 15 % |
| Coût en solo | Combien de semaines pour un premier jeu jouable, avec Claude Code ? | 15 % |
| Risque de clones | Combien de variantes existent déjà, et à quelle vitesse ? | 10 % |
| Déclin | Courbe de vie attendue de la famille (§2.5) | 5 % |

### 8.3 Premier tri des familles [H, à discuter]

| Famille | Barrières | Points forts | Points faibles | Rôle possible |
|---|---|---|---|---|
| D. Tower defense | Compatible B1 à B4 | Dépense par joueur élevée, rétention publique élevée, squelette piloté par données, entrée récente prouvée (Cameraman TD) | Contenu d'unités à produire, IP à choisir | Candidate n° 1 pour le premier jeu du programme |
| A. Stat × collectibles × passif | B3 à surveiller (cotes) | Vitesse de production, bien compris | Saturé, déclin rapide, dépense par joueur faible | Laboratoire à court terme, à lancer seulement avec un sujet et une mécanique vraiment distincts |
| E. Incrémental / hasard | B3 | Très bon marché | Très saturé, faible différenciation | Prototypes d'apprentissage de la base |
| B. Action RPG | Compatible | Dépense et rétention élevées | Mois de contenu | Plus tard, quand la base est mûre |
| C. Compétitif | Compatible | Dépense élevée sans avantage payant | Réseau, anti-triche, appariement | Hors de portée d'un premier cycle |

---

## 9. Règles d'arrêt et métriques

**Principe** : comparer aux benchmarks de Roblox (jeux similaires, calculés avec des jeux d'au moins 100 joueurs par jour), pas à un pourcentage universel. Les seuils ci-dessous sont mes propositions [H].

| Palier | Moment | Ce qu'on lit | Décision |
|---|---|---|---|
| G0 | Jours 0 à 12 | Parties de test internes : boucle de minute en minute amusante sans récompense ; tutoriel inutile ; temps de connexion | Passer si 3 testeurs extérieurs finissent la première boucle sans aide |
| G1 | Jours 13 à 20 | Rebond du premier jeu, taux de lancement, étapes d'accueil, D1, sur un trafic de calibrage | Continuer si rebond et D1 ne sont pas sous les jeux similaires ; sinon 2 tours de corrections puis arrêt |
| G2 | Jours 21 à 28 | D7, jours de jeu par joueur, sessions par jour, premiers achats, co-jeu | Continuer si D7 et jours de jeu sont au moins au niveau des jeux similaires ; sinon arrêt ou pivot |
| G3 | Jour 29 et suivants | Dépense par joueur actif, conversion, courbe hebdomadaire, coût d'acquisition réel | Augmenter l'acquisition seulement si D1 et D7 tiennent et si la rentabilité estimée au §5.2 est positive |

Autres règles : une expérience ne dépasse pas 4 semaines pour sa première version ; une nouvelle expérience s'ouvre dès que la précédente atteint son premier pic ; chaque décision est écrite avec sa date dans le Doc ÉTAT ; ne jamais augmenter la publicité pour sauver une rétention faible.

---

## 10. Angles morts et remises en question

1. **Le rang en dépenses n'est pas un montant.** Je classe des Robux dépensés sur 7 jours dans un relevé unique (un mardi, 00:51 UTC), sans les coûts ni la part du créateur. Les rangs bougent chaque jour.
2. **L'âge est la date de création de l'univers**, pas de la dernière refonte. Un vieux jeu refondu paraît plus ancien qu'il n'est.
3. **Mon propre biais passé** : mon étude du 16/11 classait les jeux par joueurs simultanés et non par dépenses, et affirmait que le revenu est invisible (corrigé dans le skill). Quatre de mes dix jeux sont au 54e rang ou plus bas en dépenses.
4. **Les joueurs par jour par badges ne sont pas une donnée Roblox** ; la méthode est cohérente mais non documentée.
5. **Les pondérations des signaux RFY sont inconnues et dynamiques.** Mon tableau §3.4 donne des leviers, pas des poids.
6. **Les coûts de publicité 2026 sont inconnus.** Le calcul du §5.2 dépend de la moyenne de plateforme (dominée par les gros jeux) et d'un CPP de 2025.
7. **La thèse « 16 ans et plus d'abord » repose sur des indices indirects** (composition des classements, texte de Standout Games, taux 18+). Les jeux pour enfants dominent le volume.
8. **La thèse « variantes d'une base » est soutenue par un cas confondu** : le deuxième jeu est parti avec l'audience du premier. Sans audience, le même squelette peut ne pas décoller.
9. **Les taux de base de revenus des créateurs viennent de sources secondaires non rouvertes** (médiane ≈ 1 500 $). Ils peuvent être faux dans un sens ou dans l'autre.
10. **La phrase « une tâche Luau sur deux du premier coup » de ton Doc n'a pas de source retrouvée.** Elle justifie des tests, mais le chiffre est à traiter comme une règle de prudence.
11. **Politique et réglementation changent vite** : cotes, flux récompensés, contrôles d'âge, sécurité des mineurs. Le retrait de Steal An Egg le prouve.
12. **La chaîne Claude Code ↔ Studio a un point unique de défaillance** (la passerelle et Studio ouvert) : prévoir des sauvegardes régulières (`save_game.sh`) et vérifier le lieu avant d'écrire.
13. **Anciennes conclusions que je retire** : « le revenu est invisible de l'extérieur » (le classement est public) ; « Steal An Egg est le jeu fait par IA de la lettre T3 » (c'est Break and Steal an Egg, corrigé le 16/11).

---

## 11. Plan des 30 jours

### 11.1 Décisions à trancher par toi (rien ne démarre sans elles)

1. **Brief du premier jeu** : famille retenue (§8.3), sujet, ton, public. Je ne propose pas de concept avant.
2. **Budget publicitaire de test** (0 $ est une réponse valable ; sinon un montant plafonné).
3. **Temps hebdomadaire disponible** et rythme de revue.
4. **Partenaires créateurs** : qui, quel public, quelles conditions (§7 S5).
5. **Structure de groupe** : un groupe par jeu ou un groupe studio ; traitement de l'accord privé (§7 S8).
6. **Cible d'audience** : 16 ans et plus d'abord, ou autre (§7 S2).

### 11.2 Calendrier

| Période | Claude | Toi |
|---|---|---|
| Jours 1 à 3 | Spécification de télémétrie ; squelette du noyau : données, économie, passerelle des remotes, configuration ; tests hors Studio des modules purs | Les 6 décisions |
| Jours 4 à 12 | Prototype de la boucle de minute en minute ; accueil minimal ; tests dans Studio ; revue `critical` du squelette d'achat | Parties de test avec 3 personnes ; miniatures et titre |
| Jours 13 à 16 | Publication, questionnaire de contenu, R15 uniquement si cible adultes américains, miniature personnalisée, page du jeu | Budget de test, création du groupe, ouverture de la page |
| Jours 17 à 28 | Corrections par l'entonnoir ; première mise à jour hebdomadaire ; mesures G1 et G2 | Partenaires créateurs ; lecture des tableaux de bord |
| Jour 29 | Rapport de décision : continuer, pivoter ou arrêter, avec les chiffres | Décision |

### 11.3 Livrables à demander à Claude (tâches ponctuelles)

- Étendre l'outil de mesure pour archiver chaque jour les classements publics dans un fichier daté.
- Écrire le noyau (§6.2) en modules entiers, avec un jeu de tests pour les mathématiques d'économie et de tirages.
- Préparer la spécification de télémétrie et la liste d'événements du premier jeu.
- Évaluer les Feature Packages (Missions, Passe de saison, Bundles, Récompenses d'engagement) contre une version maison, avec ton accord avant toute insertion.

---

## Annexe A. Commandes de mesure (depuis la racine du dépôt)

```bash
python -I .claude/skills/roblox-market-intel/scripts/game_intel.py top-earning 20
python -I .claude/skills/roblox-market-intel/scripts/game_intel.py charts 10
python -I .claude/skills/roblox-market-intel/scripts/game_intel.py snapshot <placeId|universeId> [...]
python -I .claude/skills/roblox-market-intel/scripts/game_intel.py sample 20 <placeId|universeId> [...]
```

## Annexe B. Glossaire des métriques

- **DAU** : joueurs actifs par jour. **CCU** : joueurs simultanés (instantané ou moyenne).
- **PTR** : taux de lancement après affichage. **Rebond du premier jeu** : part des joueurs qui quittent pendant les premières minutes (négatif).
- **D1, D7, D30** : part des nouveaux joueurs qui reviennent au jour 1, 7, 30.
- **Joueurs-jours** : joueurs actifs × jours.
- **ARPDAU** : revenu moyen par joueur actif et par jour ; **ARPPU** : par payeur ; **conversion** : part des joueurs actifs qui paient.
- **CPP** : coût par lecture (une session démarrée) de la publicité.
- **Robux gagnés (Earned Robux)** : Robux issus de ventes, convertibles par DevEx.

## Annexe C. Sources

- Lettre aux actionnaires du T3 2026, SEC 8-K du 2026-10-29, pièce 99.1 : https://www.sec.gov/Archives/edgar/data/1315098/000162828026068235/ex991-q32026earningsshar.htm
- Roblox newsroom, 2026-06-15 : https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox
- DevForum, annonce RFY (trouvée par recherche, non ouverte) : https://devforum.roblox.com/t/recommended-for-you-algorithm-improvements-that-better-value-long-term-retention/4684575
- DevForum, benchmarks de coût par lecture, 2025-08-05 : https://devforum.roblox.com/t/ads-manager-updates-acquire-new-users-continuous-campaigns-and-more/3862159
- Pages Creator Hub (préfixe https://create.roblox.com/docs/) : `get-started/monetization`, `production/monetization/developer-exchange`, `production/monetization/18-plus-devex-rate`, `production/monetization/roblox-plus`, `production/monetization/paid-random-items`, `production/monetization/immersive-ads`, `creator-rewards`, `discovery`, `production/publishing/kids-and-select`, `production/promotion/ads-manager`, `production/promotion/rewarded-video-ads`, `production/creator-store`, `creator-programs/standout-games`, `production/analytics/analytics-dashboard`, `production/analytics/retention`, `production/analytics/custom-events`, `production/analytics/funnel-events`, `production/analytics/economy-events`, `production/configs`, `production/experiments`, `production/game-design/core-loops`, `cloud-services/data-stores/error-codes-and-limits`, `cloud-services/data-stores/best-practices`, `cloud-services/memory-stores`, `cloud-services/cross-server-messaging`, `performance-optimization`, `workspace/streaming`, `luau/native-code-gen`, `scripting/security/*`, `resources/feature-packages/*`, `projects/assets/packages`
- Classements publics : `https://apis.roblox.com/explore-api/v1/get-sort-content?sessionId=<uuid>&sortId=<top-earning|up-and-coming|top-trending|top-revisited|fun-with-friends>&device=computer&country=all`
- Prix du Robux [S] : https://rowatcher.com/news/robux-prices-bundles-2026-guide
- Clones « Steal a ___ » [S, non ouvert] : https://rowatcher.com/news/105-games-cloned-steal-a-one-holds-92-of-the-players
- Base de connaissances du dépôt : `.claude/skills/roblox-expert/` (références : marché, découverte, économie, aléatoire, optimisation, croissance, cas, étude du top 10, données mesurées) et `.claude/skills/roblox-expert/references/market-analysis-corrected-2026-11-18.md`.

## Annexe D. Registre des chiffres non vérifiés

| Chiffre | Statut |
|---|---|
| Prix du Robux 0,0125 $ | [S], à confirmer sur une page Roblox |
| CPP 2026 | [?] aucun chiffre trouvé ; 2025 : [P] 0,008 $ (Plays), [S] 0,0073 à 0,0187 $ |
| Part de lectures qui deviennent des joueurs distincts | [?] |
| Médiane DevEx ≈ 1 500 $, moyenne du top 10 ≈ 65,7 M$ | [S], rouvrir les sources |
| 105 clones « Steal a ___ », un à 92 % | [S], non ouvert |
| Tarifs d'influenceurs | [S], non vérifié |
| « Une tâche Luau sur deux du premier coup » | [?], source non retrouvée |
| Règle sur les récompenses pour aimer, mettre en favori, rejoindre un groupe | [?] |
| Valeur d'une vidéo récompensée | [?] non publiée |
| Conversion en Robux de l'Audience Expansion | [?] non précisée |
| Budget chiffré de pièces, d'instances, de mémoire mobile | [?] non publié par Roblox |
