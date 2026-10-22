# Données du CM 10

## `co2_nord_sud.csv`

- **Contenu** : une ligne par entité (États-Unis, Union européenne à 27, Chine, Inde, Afrique, France, Nigeria, Monde).
  - `entite` : nom français ; `entite_owid` : nom de l'entité dans les fichiers Our World in Data ;
  - `co2_cumule_1750_2024_t` : émissions cumulées de CO₂ de 1750 à 2024, en tonnes (CO₂ fossile et industriel, hors changement d'usage des sols) ;
  - `co2_par_hab_1990_t`, `co2_par_hab_2024_t` : émissions annuelles de CO₂ par habitant, en tonnes, en 1990 et en 2024 (même champ ; émissions territoriales, hors aviation et transport maritime internationaux) ;
  - `population_2023` : population en 2023 (dernière année du fichier de population).
- **Sources** (fichiers CSV téléchargés le 21/10/2026) :
  - « Cumulative CO₂ emissions », Global Carbon Budget (2025), traitement Our World in Data, mis à jour le 13/11/2025 : https://ourworldindata.org/grapher/cumulative-co-emissions.csv?v=1&csvType=full (SHA-256 `58151d4d7e77bfeb9695b40a0716f322cb20b09beafc41652a684c4f7d25e7bd`) ;
  - « Annual CO₂ emissions (per capita) », Global Carbon Budget (2025) et population (sources diverses, 2024), traitement Our World in Data, mis à jour le 13/11/2025 : https://ourworldindata.org/grapher/co-emissions-per-capita.csv?v=1&csvType=full (SHA-256 `11a3a3531e4d814f96c5b6ce1ce4888be554cab5a48fe1394ba72f1b590e976e`) ;
  - « Population (historical) », HYDE (2023), Gapminder (2022), Nations unies, World Population Prospects (2024), traitement Our World in Data, mis à jour le 15/07/2024 : https://ourworldindata.org/grapher/population.csv?v=1&csvType=full (SHA-256 `6e72d4ffe8f0e940df60c90b13c8ad6eda85043b995b244e8b3e20b1e833b541`).
- **Traitement** : sélection des huit entités et des années 1990, 2023 et 2024 ; par habitant arrondi à deux décimales ; aucune autre transformation. Les parts mondiales (en %) sont calculées dans `R/cm10.R`.
- **Utilisé par** : `R/cm10.R` (`co2_cm10`, `graphe_parts_co2()`), donc `cours/cm10.qmd` (et `slides/cm10.qmd`).
- **Attention** :
  - la France fait partie de l'Union européenne à 27 : les deux lignes ne s'additionnent pas ;
  - la population est celle de 2023, les émissions s'arrêtent en 2024 : l'écart d'un an ne change pas les ordres de grandeur ;
  - ces chiffres de CO₂ territorial ne sont pas comparables à l'empreinte carbone de l'Insee (tous gaz à effet de serre, importations comprises).

## `co2_par_hab_1990_2024.csv`

- **Contenu** : une ligne par entité et par année, de 1990 à 2024 (6 entités × 35 ans = 210 lignes) : États-Unis, Union européenne à 27, Chine, Inde, Afrique, Monde.
  - `entite` : nom français ; `entite_owid` : nom de l'entité chez Our World in Data ; `annee` ;
  - `co2_par_hab_t` : émissions annuelles de CO₂ par habitant, en tonnes (CO₂ fossile et industriel, émissions territoriales, hors changement d'usage des sols et hors aviation et transport maritime internationaux).
- **Source** (téléchargée le 21/10/2026) : « Annual CO₂ emissions (per capita) », Global Carbon Budget (2025) et population (sources diverses, 2024), traitement Our World in Data, mis à jour le 13/11/2025 : https://ourworldindata.org/grapher/co-emissions-per-capita.csv?v=1&csvType=full (SHA-256 `11a3a3531e4d814f96c5b6ce1ce4888be554cab5a48fe1394ba72f1b590e976e`, identique au fichier utilisé pour `co2_nord_sud.csv`).
- **Traitement** : sélection des six entités et des années 1990 à 2024 ; noms traduits ; valeurs arrondies à deux décimales ; aucune autre transformation. Les valeurs de 1990 et 2024 sont identiques à celles de `co2_nord_sud.csv` (vérifié par `stopifnot()` dans `R/cm10.R`).
- **Utilisé par** : `R/cm10.R` (`flux_cm10`, `graphe_flux_co2()`), donc `cours/cm10.qmd` (@fig-flux-co2).

## `empreinte_carbone_france_1990_2025.csv`

- **Contenu** : une ligne par année, de 1990 à 2025 (36 lignes), France.
  - `annee` ;
  - `emissions_t_hab` : émissions de gaz à effet de serre des unités résidentes, en tonnes équivalent CO₂ par habitant (colonne « Émissions totales de GES ») ;
  - `empreinte_t_hab` : empreinte carbone (émissions liées à la demande finale intérieure, importations comprises), en tonnes équivalent CO₂ par habitant (colonne « Empreinte GES totale ») ;
  - `emissions_mt`, `empreinte_mt` : les mêmes, en millions de tonnes équivalent CO₂ (milliers de tonnes de la source ÷ 1 000) ;
  - `importees_mt` : émissions importées, en millions de tonnes équivalent CO₂ (onglet « Figure 3 », entiers).
- **Source** (fichier XLSX téléchargé le 22/10/2026) : Insee et SDES, *Insee Première* n° 2130, « Émissions de gaz à effet de serre et empreinte carbone de la France en 2025 – Après deux années de baisse, l'empreinte diminue à peine » (M. Grenier, S. Larrieu, M. Baude), 13/10/2026, onglets « Tableau complémentaire 2 – Émissions et empreinte GES de la France depuis 1990 » et « Figure 3 ».
  - Page : https://www.insee.fr/fr/statistiques/9074153?sommaire=8071406
  - Fichier : https://www.insee.fr/fr/statistiques/fichier/9074153/ip2130.xlsx (SHA-256 `bd4c5a6f2919cbb55ecb4b4ae3d5f779e40be2751829c84cdff31714463fc2ad`).
- **Traitement** : extraction des colonnes par position, après contrôle des en-têtes ; valeurs par habitant arrondies à 0,1 t comme dans la source ; aucune autre transformation (script de préparation : `_drafts/donnees/cm10/preparer_csv.R`, fichier brut : `_drafts/donnees/cm10/brut/insee_ip2130.xlsx`).
- **Utilisé par** : `R/cm10.R` (`empreinte_cm10`, `graphe_empreinte_france()`), donc `cours/cm10.qmd` (@fig-empreinte-france) et `slides/cm10.qmd`.
- **Attention** :
  - tous gaz à effet de serre (CO₂, CH₄, N₂O, gaz fluorés), pas seulement le CO₂ : ces chiffres ne se comparent pas à ceux de `co2_par_hab_1990_2024.csv` ;
  - les « émissions » sont celles des unités résidentes (format des comptes d'émissions atmosphériques), qui incluent une partie des transports aériens et maritimes à l'étranger : ce n'est pas l'inventaire territorial ;
  - série révisée par rapport au Rapport ODD 2024 de l'Insee cité dans la page (2023 : 8,6 t d'empreinte et 6,0 t d'émissions par habitant ici, contre 9,4 t et 5,9 t) ; estimation fondée depuis 2024 sur les tableaux entrées-sorties internationaux Figaro d'Eurostat ;
  - 2025 provisoire ; 1990-2009 rétropolé à partir de 2010 ;
  - l'onglet « Tableau complémentaire 2 » indique le champ « France métropolitaine », l'onglet « Figure 3 » le champ « France » ; les totaux d'empreinte en Mt sont identiques dans les deux onglets (contrôlé dans le script de préparation).

## `budget_carbone_mondial_1960_2024.csv`

- **Contenu** : une ligne par année, de 1960 à 2024 (65 lignes), monde, en milliards de tonnes de CO₂ par an (GtCO₂).
  - `annee` ;
  - `emissions_gtco2` : émissions de CO₂ fossile et industriel, nettes du puits de carbonatation du ciment, plus émissions liées au changement d'usage des sols ;
  - `hausse_atmosphere_gtco2` : croissance du stock de CO₂ dans l'atmosphère (mesurée, NOAA/ESRL et Scripps) ;
  - `puits_ocean_gtco2`, `puits_terres_gtco2` : CO₂ absorbé par les océans et par la végétation et les sols.
- **Source** (fichier XLSX téléchargé le 22/10/2026) : Global Carbon Project, *Global Carbon Budget 2025*, supplément de données v1.0, ICOS Carbon Portal, DOI 10.18160/GCP-2025, licence CC BY 4.0, fichier `Global_Carbon_Budget_2025_v1.0.xlsx`, onglet « Global Carbon Budget ». Article : P. Friedlingstein et al., *Earth System Science Data*, 18, p. 3211-3288, 2026.
  - Page : https://meta.icos-cp.eu/objects/qSjPBsV1drZnYdH-yCJMmkGn
  - Fichier : https://data.icos-cp.eu/objects/qSjPBsV1drZnYdH-yCJMmkGn (SHA-256 `a928cf06c57576b66761d1fec8224c9a41a781eb63442afc03ba902858dd64a9`).
- **Traitement** : onglet lu à partir de la ligne 22, en-têtes contrôlés ; GtC convertis en GtCO₂ (× 3,664, comme l'indique l'onglet) ; arrondi à 0,01 ; 1959 écarté (script : `_drafts/donnees/cm10/preparer_csv.R`, brut : `_drafts/donnees/cm10/brut/Global_Carbon_Budget_2025_v1.0.xlsx`). Les moyennes par décennie sont calculées dans `R/cm10.R`.
- **Utilisé par** : `R/cm10.R` (`budget_cm10`, `graphe_co2_reste_air()`), donc `cours/cm10.qmd` (@fig-co2-reste-air) et `slides/cm10.qmd`.
- **Attention** :
  - la différence entre émissions et hausse du stock n'est pas exactement la somme des deux puits : elle contient aussi le « déséquilibre budgétaire » du Global Carbon Project (écart non expliqué, important dans les années 1960, quasi nul en 2015-2024) ;
  - la hausse annuelle du stock varie fortement d'une année à l'autre (El Niño) : en 2024, 29,0 GtCO₂ pour 42,4 émises ; d'où les moyennes par décennie.

## `financement_climat_2016_2024.csv`

- **Contenu** : une ligne par année, de 2016 à 2024 (9 lignes), en milliards de dollars courants.
  - `annee` ;
  - `total_mds_usd` : financement climat fourni et mobilisé par les pays développés pour les pays en développement (ligne « Grand Total (1+2+3+4) » : public bilatéral, public multilatéral attribué aux pays développés, crédits à l'exportation, finance privée mobilisée) ;
  - `public_et_credits_export_mds_usd` : sous-total public et crédits à l'exportation (ligne « Subtotal (1+2+3) »), non tracé.
- **Source** (tableau HTML lu le 22/10/2026) : OCDE, *Climate Finance Provided and Mobilised by Developed Countries in 2013-2024*, publié le 21/05/2026, chapitre « Key trends », Table 1.
  - Page : https://www.oecd.org/en/publications/2026/05/climate-finance-provided-and-mobilised-by-developed-countries-in-2013-2024_532c847f/full-report/component-2.html
  - Pas de fichier tableur diffusé : les cellules du tableau ont été recopiées sans retouche dans `_drafts/donnees/cm10/brut/ocde_table1_financement_climat_2013_2024.tsv` (SHA-256 `bc66440318395f9677748154d3dc70fdb3ec447b94fb1ac18a9d5ca0e25c626c`), avec un en-tête qui en donne l'origine.
- **Traitement** : sélection des deux lignes de total ; 2013-2015 écartés (l'OCDE signale une rupture de série sur la finance privée en 2015 : les totaux de 2013-2014 et de 2016-2024 ne sont pas directement comparables) ; aucune autre transformation.
- **Utilisé par** : `R/cm10.R` (`finance_cm10`, `graphe_financement_climat()`), donc `cours/cm10.qmd` (@fig-financement-climat) et `slides/cm10.qmd`.
- **Attention** :
  - dollars courants, non corrigés de l'inflation ;
  - la part multilatérale et la finance privée sont « attribuées » aux pays développés par l'OCDE selon des clés de répartition ;
  - la série mesure l'objectif de 100 milliards ; le périmètre comptable exact de l'objectif de Bakou (300 milliards) n'est pas décrit dans cette source : la comparaison donne un ordre de grandeur.
