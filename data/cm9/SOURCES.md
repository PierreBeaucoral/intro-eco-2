# Données du CM 9

## `recettes_douane_us.csv`

- **Contenu** : recettes douanières mensuelles du gouvernement fédéral américain, en milliards de dollars courants (Md$), d'octobre 2024 à septembre 2026 (24 mois, soit les exercices budgétaires 2025 et 2026, qui vont d'octobre à septembre).
  - `date` : dernier jour du mois (AAAA-MM-JJ) ;
  - `brut` : recettes brutes du mois (colonne `current_month_gross_rcpt_amt`) ;
  - `net` : recettes nettes des remboursements (colonne `current_month_net_rcpt_amt`). Elles deviennent négatives de mai à juillet 2026, quand les remboursements des droits annulés par la Cour suprême dépassent les droits perçus.
- **Source** : Département du Trésor des États-Unis, Bureau of the Fiscal Service, *Monthly Treasury Statement*, table 4 (« Receipts of the U.S. Government »), ligne « Customs Duties ».
  - API : https://api.fiscaldata.treasury.gov/services/api/fiscal_service/v1/accounting/mts/mts_table_4?filter=classification_desc:eq:Customs%20Duties,record_date:gte:2024-10-01&sort=record_date&page%5Bsize%5D=100
- **Téléchargé le** : 21/10/2026 (SHA-256 de la réponse JSON : `be4f602f757601d41004145e6a4f656252d690dfcb9dd8ac7ef9b71a9918f834`).
- **Traitement** : montants en dollars divisés par 10⁹ et arrondis à trois décimales. Aucune autre transformation.
- **Totaux par exercice** (calculés dans `R/cm9.R`) : brut 202,4 Md$ (2025) et 317,8 Md$ (2026) ; net 194,9 Md$ et 173,2 Md$.

## `commerce_ue_usa.csv`

- **Contenu** : échanges de biens de l'UE à 27 avec les États-Unis, en milliards d'euros (Md€), 2023 à 2025.
  - `exportations` : exportations de l'UE vers les États-Unis (indicateur `MIO_EXP_VAL`) ;
  - `importations` : importations de l'UE depuis les États-Unis (indicateur `MIO_IMP_VAL`).
- **Source** : Eurostat, jeu `ext_lt_maineu` (« Commerce extra-UE par partenaire »), partenaire `US`, produit `TOTAL`, déclarant `EU27_2020`. Jeu mis à jour le 16/10/2026.
  - API : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/ext_lt_maineu?format=JSON&lang=fr&partner=US&sitc06=TOTAL&indic_et=MIO_EXP_VAL&indic_et=MIO_IMP_VAL&time=2023&time=2024&time=2025&geo=EU27_2020
- **Téléchargé le** : 21/10/2026 (SHA-256 de la réponse JSON : `305fe40faa64f9e87c7e9e8d1fe7651010e6e697c61924cd1b5f3127fc7ba9c7`).
- **Traitement** : millions d'euros divisés par 1 000 et arrondis à une décimale. Le solde (exportations − importations) est calculé dans `R/cm9.R`.

## `prix_import_conso_us.csv`

- **Contenu** : deux indices de prix mensuels des États-Unis, de janvier 2024 à septembre 2026 (33 mois).
  - `date` : premier jour du mois (AAAA-MM-JJ) ;
  - `prix_import` : indice des prix à l'importation, tous biens hors carburants (série `EIUIREXFUELS`, base 100 en 2000, non corrigé des variations saisonnières). Les prix de ces indices excluent les droits de douane (« The prices for the items used to calculate the Import/Export Price Indexes exclude duties », BLS, https://www.bls.gov/mxp/questions-and-answers.htm, ouvert le 21/10/2026) ;
  - `prix_conso_biens` : indice des prix à la consommation, biens hors alimentation et énergie, toutes zones urbaines (série `CUSR0000SACL1E`, base 100 en 1982-1984, corrigé des variations saisonnières).
  - Octobre 2025 vaut `NA` pour les deux séries : le BLS indique « Data unavailable due to the 2025 lapse in appropriations ».
- **Source** : Bureau of Labor Statistics (BLS), API publique v2.
  - API : `POST https://api.bls.gov/publicAPI/v2/timeseries/data/` avec `{"seriesid":["EIUIREXFUELS","CUSR0000SACL1E"],"startyear":"2024","endyear":"2026"}`
  - (FRED, qui diffuse les mêmes séries, était en maintenance le 21/10/2026.)
- **Téléchargé le** : 21/10/2026 (SHA-256 de la réponse JSON : `bab89370fde31256b18dafb2a58ef973afe615546eab4a300caf3564749d5dfa`). La valeur d'août 2026 de `EIUIREXFUELS` est marquée « révisée ».
- **Traitement** : valeurs recopiées telles quelles. La base 100 en janvier 2025 et les variations citées dans la page (0,0 % et +1,0 % de janvier à septembre 2025, −0,6 % de janvier à septembre 2024 pour les biens de consommation, +5,2 % de décembre 2025 à septembre 2026 pour les importations) sont calculées dans `R/cm9.R`.

## `droit_effectif_us_1929_2025.csv`

- **Contenu** : droit de douane effectif des États-Unis, annuel, 1929-2025 (97 lignes, années civiles).
  - `annee` ;
  - `droits_md` : droits de douane perçus par l'État fédéral, en Md$ courants (BEA, comptes nationaux, NIPA table 3.5, « Customs duties ») ;
  - `importations_md` : importations de biens, en Md$ courants (NIPA table 1.1.5, « Imports of goods ») ;
  - `taux_effectif_pct` : 100 × droits ÷ importations, arrondi à deux décimales.
  - Ce « droit effectif » (droits perçus ÷ valeur importée) n'est pas le droit moyen cité dans la page (Guimbard : 4,9 %, 24,2 %, environ 15 %) : il est plus bas, car les achats se détournent des produits les plus taxés, certains produits sont exemptés et les droits sont versés avec retard. Les comptes nationaux comptent les droits perçus, sans déduire les remboursements.
- **Source** : Bureau of Economic Analysis (BEA), comptes nationaux (NIPA), diffusés par FRED (Federal Reserve Bank of St. Louis), séries `B235RC1A027NBEA` et `A255RC1A027NBEA`, mises à jour le 30/09/2026.
  - Pages : https://fred.stlouisfed.org/series/B235RC1A027NBEA et https://fred.stlouisfed.org/series/A255RC1A027NBEA
  - Fichiers : https://fred.stlouisfed.org/graph/fredgraph.csv?id=B235RC1A027NBEA et https://fred.stlouisfed.org/graph/fredgraph.csv?id=A255RC1A027NBEA
- **Téléchargé le** : 22/10/2026. SHA-256 des fichiers bruts : `fred_B235RC1A027NBEA.csv` `fbc5229fa6dc7b542a0ec9c522d7e0b09aee7c5bb0f50d9a0ed0709126cad6e1` ; `fred_A255RC1A027NBEA.csv` `d09efd620f16da0165d6fcb9621a28e432f7d3e657343f0510411a6c1b4772ba` (conservés dans `_drafts/donnees/cm9/brut/`).
- **Traitement** : fusion par année, ratio (script `_drafts/donnees/cm9/preparation.R`). Aucune autre transformation.
- **Utilisé par** : `R/cm9.R`, section 7 a (`effectif_cm9`, `graphe_droit_effectif()`) ; figure `fig-droit-effectif` de `cours/cm9.qmd` et diapo correspondante de `slides/cm9.qmd`.

## `part_douane_impots_federaux_1929_2025.csv`

- **Contenu** : part des droits de douane dans les impôts de l'État fédéral américain, annuel, 1929-2025 (97 lignes, années civiles).
  - `annee` ;
  - `droits_md` : droits de douane perçus, en Md$ courants (même série que `droit_effectif_us_1929_2025.csv`) ;
  - `impots_federaux_md` : impôts courants de l'État fédéral (« Federal government current tax receipts »), en Md$ courants, sans les cotisations sociales ;
  - `part_douane_pct` : 100 × droits ÷ impôts, arrondi à deux décimales.
- **Source** : BEA, comptes nationaux (NIPA), via FRED, séries `B235RC1A027NBEA` (voir la fiche précédente) et `W006RC1A027NBEA`, mises à jour le 30/09/2026.
  - Page : https://fred.stlouisfed.org/series/W006RC1A027NBEA
  - Fichier : https://fred.stlouisfed.org/graph/fredgraph.csv?id=W006RC1A027NBEA
- **Téléchargé le** : 22/10/2026. SHA-256 du fichier brut `fred_W006RC1A027NBEA.csv` : `ccb0c71516716c6da8826a01183c04c6d3791cb355384689d92e439db73f47bc` (et `fred_B235RC1A027NBEA.csv`, voir plus haut).
- **Traitement** : fusion par année, ratio (`_drafts/donnees/cm9/preparation.R`).
- **Utilisé par** : `R/cm9.R`, section 7 b (`part_douane_cm9`, `graphe_part_douane()`) ; figure `fig-part-douane-impots` de `cours/cm9.qmd` et diapo correspondante de `slides/cm9.qmd`.

## `export_ue_usa_mensuel_2023_2026.csv`

- **Contenu** : exportations mensuelles de biens de l'UE à 27 vers les États-Unis, de janvier 2023 à août 2026 (44 mois), en Md€.
  - `date` : premier jour du mois (AAAA-MM-JJ) ;
  - `export_brut_md` : valeur brute (indicateur `TRD_VAL`, millions d'euros ÷ 1 000) ;
  - `export_cvs_md` : valeur corrigée des variations saisonnières et des jours ouvrables (CVS-CJO, indicateur `TRD_VAL_SCA`, millions d'euros ÷ 1 000). C'est la série tracée.
- **Source** : Eurostat, jeu `ext_st_eu27_2020sitc` (« EU27 (from 2020) trade by SITC product group »), flux `EXP`, partenaire `US`, produit `TOTAL`, déclarant `EU27_2020`. Jeu mis à jour le 16/10/2026.
  - API : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/ext_st_eu27_2020sitc?format=JSON&lang=fr&partner=US&sitc06=TOTAL&geo=EU27_2020&stk_flow=EXP&stk_flow=IMP&indic_et=TRD_VAL&indic_et=TRD_VAL_SCA&sinceTimePeriod=2023-01
  - Navigateur : https://ec.europa.eu/eurostat/databrowser/view/ext_st_eu27_2020sitc/default/table?lang=fr
- **Téléchargé le** : 22/10/2026 (SHA-256 de la réponse JSON `eurostat_ext_st_eu27_2020sitc_US.json` : `794a311c071e7be56fc9e0b3962c720ce3cbcc8b40a315e5d6242f100f4ffb45`). La réponse contient aussi les importations (`IMP`), non utilisées.
- **Traitement** : décodage JSON-stat, division par 1 000, arrondi à trois décimales (`_drafts/donnees/cm9/preparation.R`). Les sommes des douze mois bruts redonnent exactement les exportations annuelles de `commerce_ue_usa.csv` (505,9, 535,6 et 554,7 Md€ en 2023, 2024 et 2025), ce que vérifie `R/cm9.R`.
- **Utilisé par** : `R/cm9.R`, section 8 (`export_cm9`, `graphe_export_ue_usa()`) ; figure `fig-export-ue-usa` de `cours/cm9.qmd` et diapo correspondante de `slides/cm9.qmd`.

## `chine_emploi_industriel_us_1990_2025.csv`

- **Contenu** : 1990-2025, années complètes (36 lignes).
  - `annee` ;
  - `part_chine_pct` : 100 × somme des douze mois des importations de biens des États-Unis depuis la Chine ÷ somme des douze mois des importations de biens depuis le monde (base douanière, non corrigées des variations saisonnières, millions de dollars) ;
  - `emploi_industrie_millions` : moyenne des douze mois de l'emploi salarié dans l'industrie manufacturière (corrigé des variations saisonnières, milliers ÷ 1 000).
- **Sources** :
  - Census Bureau, *U.S. International Trade in Goods and Services*, séries diffusées par FRED : `IMPCH` (importations de biens depuis la Chine) et `IMP0015` (depuis le monde). Pages : https://fred.stlouisfed.org/series/IMPCH et https://fred.stlouisfed.org/series/IMP0015 ; fichiers : https://fred.stlouisfed.org/graph/fredgraph.csv?id=IMPCH et https://fred.stlouisfed.org/graph/fredgraph.csv?id=IMP0015.
  - Bureau of Labor Statistics (BLS), Current Employment Statistics, série `CES3000000001` (« All employees, manufacturing »). API : `POST https://api.bls.gov/publicAPI/v2/timeseries/data/` avec `{"seriesid":["CES3000000001"],"startyear":"1990","endyear":"1999"}`, puis 2000-2009, 2010-2019 et 2020-2026 (quatre requêtes, l'API sans clé limitant la période).
- **Téléchargé le** : 22/10/2026. SHA-256 des fichiers bruts : `fred_IMPCH.csv` `bdd85d94af97fc8c332d0bb3a80a40c66f1e49bd8ae03f421da68eb1fd7feb65` ; `fred_IMP0015.csv` `542bfb2f934545a7ec671c9464eab3758719f4a3f3e4e925610bb99dd5d41033` ; `bls_CES3000000001_1990_1999.json` `4adfa9ed1b45eca6c594bb9a888e5b64b67f8d265883c29147e7533b97c28cb5` ; `bls_CES3000000001_2000_2009.json` `0cc39378b36a096d82fed91da199e5288202ed9a17cf9aa4748a60874bd3ebe2` ; `bls_CES3000000001_2010_2019.json` `e0bbeb9fefc1895637ca514e4b84eac6b1b5df00652cb2ba1b3f2d23671a70bf` ; `bls_CES3000000001_2020_2026.json` `59ae6d90ba31f46dd9f0eff303bb30e5f76d0c0509d30971fb00a36634875150`.
- **Traitement** : sommes et moyennes annuelles ; `_drafts/donnees/cm9/preparation.R` vérifie que chaque année 1990-2025 a bien douze mois dans les deux sources.
- **Utilisé par** : `R/cm9.R`, section 9 (`chine_cm9`, `graphe_chine_emploi()`) ; figure `fig-chine-emploi` de `cours/cm9.qmd` et diapo correspondante de `slides/cm9.qmd`.

## Utilisation

`R/cm9.R` lit les sept fichiers (`recettes_cm9`, `commerce_cm9`, `prix_cm9`, `effectif_cm9`, `part_douane_cm9`, `export_cm9`, `chine_cm9`), trace `graphe_recettes_douane()`, `graphe_prix_import()`, `graphe_droit_effectif()`, `graphe_part_douane()`, `graphe_export_ue_usa()` et `graphe_chine_emploi()`, et vérifie par `stopifnot()` chaque chiffre cité dans `cours/cm9.qmd`.
