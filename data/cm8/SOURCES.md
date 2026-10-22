# Données du CM 8

Sauf mention contraire, les séries viennent de l'API de diffusion d'Eurostat (format JSON), **téléchargées le 21/10/2026**. Les trois fichiers des sections « ajoutés le 22/10/2026 », en fin de page, ont été téléchargés le 22/10/2026 ; l'un vient de la base AMECO de la Commission européenne. Racine des requêtes : `https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/`. Code pays de la Grèce chez Eurostat : `EL`.

## `grece_2008_2025.csv`

Une ligne par année, de 2008 à 2025. Case vide = valeur absente de l'extraction (pas de taux de chômage 15-74 ans pour 2008 dans `une_rt_a` ; série pauvreté changée en 2015, voir plus bas).

| Colonne | Contenu | Jeu de données et filtre | Mise à jour Eurostat |
|---|---|---|---|
| `pib_reel` | PIB en volume, Md€, prix chaînés de 2010 | `nama_10_gdp?geo=EL&unit=CLV10_MEUR&na_item=B1GQ` | 21/10/2026 (2024 et 2025 provisoires) |
| `pib_valeur` | PIB en valeur, Md€ courants | `nama_10_gdp?geo=EL&unit=CP_MEUR&na_item=B1GQ` | 21/10/2026 (2024 et 2025 provisoires) |
| `chomage` | Taux de chômage, 15-74 ans, % de la population active | `une_rt_a?geo=EL&age=Y15-74&sex=T&unit=PC_ACT` | 10/09/2026 |
| `chomage_15_24` | Idem, 15-24 ans | `une_rt_a?…&age=Y15-24&sex=T` | 10/09/2026 |
| `chomage_femmes`, `chomage_hommes` | Idem, 15-74 ans, femmes et hommes | `une_rt_a?…&age=Y15-74&sex=F` (puis `M`) | 10/09/2026 |
| `chomage_zone_euro` | Taux de chômage de la zone euro (20 pays), 15-74 ans | `une_rt_a?geo=EA20&age=Y15-74&sex=T&unit=PC_ACT` | 10/09/2026 |
| `dette` | Dette publique brute (au sens de Maastricht), % du PIB | `gov_10dd_edpt1?geo=EL&unit=PC_GDP&sector=S13&na_item=GD` | 21/10/2026 |
| `solde` | Capacité (+) ou besoin (−) de financement des administrations publiques, % du PIB | idem, `na_item=B9` | 21/10/2026 |
| `interets` | Intérêts versés par les administrations publiques, % du PIB | idem, `na_item=D41PAY` | 21/10/2026 |
| `pauvrete_ue2020` | Personnes en risque de pauvreté ou d'exclusion sociale, % de la population (définition « Europe 2020 », 2008-2020) | `ilc_peps01?geo=EL&age=TOTAL&sex=T&unit=PC` | 28/10/2025 |
| `pauvrete_ue2030` | Idem, définition « Europe 2030 » (2015-2025) | `ilc_peps01n?geo=EL&age=TOTAL&sex=T&unit=PC` | 20/10/2026 |

**Traitement** : PIB converti de millions en milliards d'euros et arrondi à 0,1 Md€ ; autres valeurs telles que publiées. Les calculs (indice 100 en 2008, dette en Md€ = ratio × PIB en valeur, taux d'intérêt apparent = intérêts / dette de l'année précédente, solde primaire = solde + intérêts) sont faits dans `R/cm8.R`.

**Attention** :
- les deux séries de pauvreté ont des définitions différentes : ne pas les raccorder ;
- le solde de 2013 (−13,6 %, contre −3,8 % en 2014) semble gonflé par des opérations ponctuelles : la base AMECO les chiffre à environ 8,6 points de PIB potentiel, sans en donner la nature (voir `grece_solde_primaire_corrige_2006_2025.csv` plus bas) ; leur nature (soutien aux banques ?) reste à vérifier dans les notes de notification d'Eurostat avant tout commentaire en cours, donc la page ne l'utilise pas ;
- Eurostat révise ses séries : la note du Trésor du 03/11/2025 donne 150 % pour la dette de 2024, la série téléchargée ici 153,5 %.

## `grece_chomage_repartition.csv`

Taux de chômage, 15-74 ans, % de la population active, en 2008, 2013 et 2025.

| `groupe` | Contenu | Jeu de données et filtre | Mise à jour Eurostat |
|---|---|---|---|
| `region` | Trois régions NUTS 2 : Attique (`EL30`, Athènes), Égée méridionale (`EL42`, îles touristiques), Macédoine-Occidentale (`EL53`) | `lfst_r_lfu3rt?geo=EL30&geo=EL42&geo=EL53&age=Y15-74&sex=T&unit=PC&isced11=TOTAL` | 10/09/2026 |
| `diplome` | Niveau de diplôme : inférieur au lycée (`ED0-2`) et supérieur (`ED5-8`), Grèce entière | `lfsa_urgaed?geo=EL&age=Y15-74&sex=T&unit=PC&isced11=ED0-2&isced11=ED5-8` | 10/09/2026 |
| `diplome_total` | Total de ce même tableau, 2013 seulement (sert à la note des légendes) | `lfsa_urgaed?geo=EL&age=Y15-74&sex=T&unit=PC&isced11=TOTAL&time=2013` (vérifié le 22/10/2026) | 10/09/2026 |

La série par diplôme vient d'un autre tableau que `une_rt_a` : son total diffère un peu (27,5 % en 2013 au lieu de 27,8 %).

## `taux_longs_2008_2025.csv`

Taux d'intérêt des obligations d'État à dix ans (critère de convergence de l'UEM), moyenne annuelle, en %, Grèce (`EL`) et Allemagne (`DE`), 2008-2025.

| Colonne | Contenu | Jeu de données et filtre | Mise à jour Eurostat |
|---|---|---|---|
| `grece`, `allemagne` | Rendement des emprunts d'État à long terme (environ 10 ans), moyenne annuelle, % | `irt_lt_mcby_a?geo=EL&geo=DE&sinceTimePeriod=2007` (`int_rt=MCBY`) | 25/02/2026 |

**Téléchargé le 21/10/2026.** **Traitement** : années 2008 à 2025 conservées, valeurs arrondies à 0,01 point (seules 2025 en avaient plus). Ce sont des moyennes annuelles, pas des valeurs de fin d'année.

**Utilisé par** : `R/cm8.R` (`grece_cm8`, `repartition_cm8`, `taux_cm8`, `graphe_grece()`, `graphe_taux_longs()`, `graphe_chomage_groupes()`, vérifications `stopifnot()`), donc `cours/cm8.qmd` et `slides/cm8.qmd`.

## `grece_dette_instruments_2007_2025.csv` (ajouté le 22/10/2026)

- **Contenu** : dette publique brute des administrations publiques grecques (au sens de Maastricht), par instrument, en Md€, encours au 31 décembre (valeur du 4e trimestre), une ligne par année de 2007 à 2025.
  - `annee` ;
  - `dette_totale` : dette brute, tous instruments (`na_item=GD`) ;
  - `titres` : titres de dette, obligations et bons du Trésor (`na_item=F3`) ;
  - `prets` : crédits, c'est-à-dire prêts (`na_item=F4`).
- **Source** : Eurostat, jeu de données `gov_10q_ggdebt` (« Quarterly government debt »), secteur `S13`, unité `MIO_EUR`, mise à jour Eurostat du 21/10/2026.
  - Page : https://ec.europa.eu/eurostat/databrowser/view/gov_10q_ggdebt/default/table
  - Requête : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/gov_10q_ggdebt?geo=EL&sector=S13&unit=MIO_EUR&sinceTimePeriod=2007-Q1
- **Téléchargé le** : 22/10/2026 (SHA-256 de la réponse JSON : `59285697f57d358838900fa238f43c39758b693151e53366cea0d4d3f9e1e8ef`).
- **Traitement** : trimestre `Q4` seulement, valeurs converties de millions en milliards d'euros et arrondies à 0,1 Md€. La différence `dette_totale − titres − prets` correspond aux dépôts et monnaie (`F2`, 1 à 8 Md€), non tracés. La dette totale ne s'écarte pas de plus de 1 Md€ de la dette annuelle calculée dans `R/cm8.R` (ratio × PIB en valeur) pour 2010, 2013 et 2025 (vérifié par `stopifnot()`).
- **Contrôle** : Eurostat, `gov_10dd_ggd` (dette par secteur créancier, mise à jour du 05/06/2026), https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/gov_10dd_ggd?geo=EL (extraction du 22/10/2026, SHA-256 `f66582fe5e63dbe3c055ba551eca4b48b5ea1fe09459210bf7b8c87238954fad`) : en 2025, 252 743 M€ des 257 165 M€ de prêts sont dus à des non-résidents (`S2`), et les titres valent 98 000,3 M€ (98 001 M€ dans `gov_10q_ggdebt`). Ce fichier n'est pas rangé ici : seuls ces chiffres sont cités, dans la légende de la figure.
- **Utilisé par** : `R/cm8.R` (`instruments_cm8`, `graphe_dette_instruments()`, vérifications `stopifnot()`), donc `cours/cm8.qmd` (`fig-dette-instruments`) et `slides/cm8.qmd`.
- **Attention** : la série distingue l'instrument (titre ou prêt), pas le prêteur ; la ventilation par créancier (`gov_10dd_ggd`) ne commence qu'en 2020. La chute des titres en 2012 mêle la décote de 53,5 %, l'échange contre de nouveaux titres et le rachat de décembre 2012 : ce n'est pas le seul montant annulé.

## `grece_solde_primaire_corrige_2006_2025.csv` (ajouté le 22/10/2026)

- **Contenu** : solde primaire des administrations publiques grecques (solde hors intérêts, procédure de déficit excessif), une ligne par année de 2006 à 2025. Case vide (`NA`) = valeur absente (solde structurel avant 2010).
  - `annee` ;
  - `solde_primaire` : solde primaire observé, % du PIB (variable AMECO `UBLGIE`) ;
  - `solde_primaire_corrige` : solde primaire corrigé de la composante cyclique, ajustement fondé sur le PIB potentiel, % du PIB potentiel (`UBLGBP`) ;
  - `solde_primaire_structurel` : solde primaire structurel, corrigé du cycle **et** des mesures ponctuelles, % du PIB potentiel, depuis 2010 (`UBLGBPS`).
- **Source** : Commission européenne (DG ECFIN), base AMECO, édition des prévisions du printemps 2026 (mise en ligne le 21/05/2026, note de version du 03/06/2026 ; prochaine mise à jour annoncée pour le 17/11/2026).
  - Page : https://economy-finance.ec.europa.eu/economic-research-and-databases/economic-databases/ameco-database_en
  - Requêtes (une par variable, `UBLGIE`, `UBLGBP`, `UBLGBPS`) : https://ec.europa.eu/economy_finance/ameco/wq/series?fullVariable=1.0.319.0.UBLGBP&countries=GRC&years=2006,…,2027&Lastyear=0&Yearorder=ASC
- **Téléchargé le** : 22/10/2026 (SHA-256 des trois réponses HTML : `UBLGIE` `8e6e3698680142177d2cf80a6b1f6bcaf893bf60f6fb3630793979b29b846212` ; `UBLGBP` `d13ab690882f2e4f44022fec422d3b8aef0b34cb30d7992ebc4a605e64a360c1` ; `UBLGBPS` `a86d9277e2c6451d4374fe6c1a3605158948c0ef7752f02740cf5339a0135758`).
- **Traitement** : lecture du tableau HTML renvoyé par l'interface AMECO (une colonne « 0 » vide en tête, ignorée) ; valeurs arrondies à 0,01 point ; 2026 et 2027 (prévisions) exclues.
- **Utilisé par** : `R/cm8.R` (`solde_corrige_cm8`, `graphe_solde_corrige()`, vérifications `stopifnot()`), donc `cours/cm8.qmd` (`fig-solde-corrige`) et `slides/cm8.qmd`.
- **Attention** :
  - le solde corrigé repose sur une estimation du PIB potentiel, elle-même révisée : c'est une mesure, pas une observation ; les deux soldes n'ont pas le même dénominateur ;
  - édition du printemps 2026, antérieure à la notification d'octobre 2026 utilisée dans `grece_2008_2025.csv` : solde primaire de 2025 de 4,88 % ici, contre 2,0 + 3,1 = 5,1 % chez Eurostat ; 2010 concorde (−5,3 %) ;
  - en 2013, le solde structurel (+8,83 %) dépasse le solde corrigé (+0,22 %) d'environ 8,6 points de PIB potentiel : ce sont des mesures ponctuelles, dont AMECO ne donne pas la nature (voir la remarque sur le solde de 2013 plus haut, toujours non vérifiée).

## `grece_soldes_demographiques_2000_2025.csv` (ajouté le 22/10/2026)

- **Contenu** : soldes démographiques de la Grèce, en personnes, une ligne par année de 2000 à 2025.
  - `annee` ;
  - `solde_migratoire` : solde migratoire, y compris ajustement statistique (`indic_de=CNMIGRAT`) ;
  - `solde_naturel` : naissances moins décès (`indic_de=NATGROW`).
- **Source** : Eurostat, jeu de données `demo_gind` (« Population change - demographic balance and crude rates at national level »), mise à jour Eurostat du 30/09/2026 (2025 : estimé et provisoire pour le solde migratoire, provisoire pour le solde naturel).
  - Page : https://ec.europa.eu/eurostat/databrowser/view/demo_gind/default/table
  - Requête : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/demo_gind?geo=EL&indic_de=CNMIGRAT&indic_de=CNMIGRATRT&indic_de=NATGROW&sinceTimePeriod=2000 (`CNMIGRATRT`, taux pour 1 000 habitants, téléchargé en contrôle, non gardé)
- **Téléchargé le** : 22/10/2026 (SHA-256 de la réponse JSON : `963188765f4840ce5157d98eba5fb7d165b5f990f98d0190dfe89897217d253f`).
- **Traitement** : aucun, valeurs telles que publiées. La division par 1 000 (graphique) et le cumul 2010-2017 (−282 633) se font dans `R/cm8.R`.
- **Utilisé par** : `R/cm8.R` (`demo_cm8`, `graphe_soldes_demographiques()`, vérifications `stopifnot()`), donc `cours/cm8.qmd` (`fig-soldes-demographiques`) et `slides/cm8.qmd`.
- **Attention** : `CNMIGRAT` est calculé par différence (variation de la population moins solde naturel) ; il absorbe les corrections des recensements (2011, 2021) : le chiffre de 2021 (−35 140) est à vérifier auprès d'ELSTAT avant d'être commenté.
