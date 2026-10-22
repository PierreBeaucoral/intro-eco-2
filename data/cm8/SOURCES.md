# Données du CM 8

Toutes les séries viennent de l'API de diffusion d'Eurostat (format JSON), **téléchargées le 21/10/2026**. Racine des requêtes : `https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/`. Code pays de la Grèce chez Eurostat : `EL`.

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
- le solde de 2013 (−13,6 %, contre −3,8 % en 2014) semble gonflé par des opérations ponctuelles (soutien aux banques ?) ; non vérifié dans les notes d'Eurostat, donc la page ne l'utilise pas ;
- Eurostat révise ses séries : la note du Trésor du 03/11/2025 donne 150 % pour la dette de 2024, la série téléchargée ici 153,5 %.

## `grece_chomage_repartition.csv`

Taux de chômage, 15-74 ans, % de la population active, en 2008, 2013 et 2025.

| `groupe` | Contenu | Jeu de données et filtre | Mise à jour Eurostat |
|---|---|---|---|
| `region` | Trois régions NUTS 2 : Attique (`EL30`, Athènes), Égée méridionale (`EL42`, îles touristiques), Macédoine-Occidentale (`EL53`) | `lfst_r_lfu3rt?geo=EL30&geo=EL42&geo=EL53&age=Y15-74&sex=T&unit=PC&isced11=TOTAL` | 10/09/2026 |
| `diplome` | Niveau de diplôme : inférieur au lycée (`ED0-2`) et supérieur (`ED5-8`), Grèce entière | `lfsa_urgaed?geo=EL&age=Y15-74&sex=T&unit=PC&isced11=ED0-2&isced11=ED5-8` | 10/09/2026 |

La série par diplôme vient d'un autre tableau que `une_rt_a` : son total diffère un peu (27,5 % en 2013 au lieu de 27,8 %).

## `taux_longs_2008_2025.csv`

Taux d'intérêt des obligations d'État à dix ans (critère de convergence de l'UEM), moyenne annuelle, en %, Grèce (`EL`) et Allemagne (`DE`), 2008-2025.

| Colonne | Contenu | Jeu de données et filtre | Mise à jour Eurostat |
|---|---|---|---|
| `grece`, `allemagne` | Rendement des emprunts d'État à long terme (environ 10 ans), moyenne annuelle, % | `irt_lt_mcby_a?geo=EL&geo=DE&sinceTimePeriod=2007` (`int_rt=MCBY`) | 25/02/2026 |

**Téléchargé le 21/10/2026.** **Traitement** : années 2008 à 2025 conservées, valeurs arrondies à 0,01 point (seules 2025 en avaient plus). Ce sont des moyennes annuelles, pas des valeurs de fin d'année.

**Utilisé par** : `R/cm8.R` (`grece_cm8`, `repartition_cm8`, `taux_cm8`, `graphe_grece()`, `graphe_taux_longs()`, `graphe_chomage_groupes()`, vérifications `stopifnot()`), donc `cours/cm8.qmd` et `slides/cm8.qmd`.
