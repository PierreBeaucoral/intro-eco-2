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
