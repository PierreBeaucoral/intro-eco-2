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

## `depenses_biens_quintiles_us_2023_2024.csv`

- **Contenu** : moyennes annuelles par « consumer unit » (ménage au sens du BLS), en dollars courants, 2023 et 2024, pour l'ensemble et pour chaque quintile de revenu avant impôt (12 lignes).
  - `annee`, `groupe` (`ensemble`, `Q1` à `Q5`) ;
  - `revenu_avant_impot` (INCBEFTX), `revenu_apres_impot` (INCAFTTX, `NA` en 2024 : le BLS « is unable to produce […] estimates of after-tax income in the 2024 tables », communiqué du 19/12/2025), `depense_totale` (TOTALEXP) ;
  - six postes de biens : `alimentation_domicile` (FOODHOME), `boissons_alcoolisees` (ALCBEVG), `produits_entretien` (HKPGSUPP), `meubles_equipement_logement` (HHFURNSH), `habillement` (APPAREL, « apparel and services »), `achats_vehicules` (VEHPURCH, dépense nette), et leur somme `biens_total` ;
  - ratios en %, arrondis à une décimale : `depense_pct_rev_apres`, `depense_pct_rev_avant`, `biens_pct_rev_apres` (colonne tracée, 2023), `biens_pct_rev_avant`, `biens_pct_depense`.
- **Source** : Bureau of Labor Statistics (BLS), Consumer Expenditure Surveys, tableaux « Quintiles of income before taxes », diffusés par l'API publique v2. Séries `CXU<poste>LB01<groupe>M` : `LB0101` = ensemble, `LB0102` à `LB0106` = quintiles 1 à 5.
  - API : `POST https://api.bls.gov/publicAPI/v2/timeseries/data/` avec `{"seriesid":[…],"startyear":"2023","endyear":"2025"}` (trois requêtes de 24 séries ; aucune donnée 2025 publiée au 23/10/2026).
  - Page des tableaux : https://www.bls.gov/cex/tables.htm (les fichiers XLSX n'ont pas pu être téléchargés : bls.gov répond 403 aux clients non navigateurs).
- **Téléchargé le** : 23/10/2026. SHA-256 des réponses JSON : `bls_api_cex_quintiles_part1.json` `6d674f7d86e9f43c64359607bd425c4ee97cbf3e0edd52c76faec8665e8742a9` ; `bls_api_cex_quintiles_part2.json` `d6c021fd1e6b6385dc0e600d5fd081f065e2210acf89ce9cff71aaf2addfeec8` ; `bls_api_cex_quintiles_part3.json` `459109d6e8f5fe228451a4ce72eaa5280f10f10b19c03dd8236edd3ea2c4cd72` (conservées dans `_drafts/donnees/cm9-revenu/brut/`).
- **Traitement** : somme des six postes et ratios, rien d'autre (`data/cm9/preparer_revenu.R`, à relancer depuis la racine du projet ; vérifié le 23/10/2026 : sortie identique octet pour octet au CSV). La série `GASOIL`, demandée aussi, renvoie des valeurs aberrantes (1 ou 2 $) : écartée. Contrôle : les dépenses moyennes 2024 (78 535 ; 35 046 ; 50 054 ; 66 900 ; 89 972 ; 150 342 $) sont celles du tableau C du communiqué du 19/12/2025 (https://www.bls.gov/news.release/cesan.nr0.htm, lu le 23/10/2026) ; le script s'arrête sinon.
- **Limites** : la liste des « biens » est un choix de l'auteur, et tous ne sont pas importés ; les achats de véhicules varient beaucoup d'une année à l'autre ; le revenu du premier quintile est sous-estimé (FAQ du BLS, questions 41 et 43, https://www.bls.gov/cex/csxfaqs.htm, lue le 23/10/2026), ce qui grossit son ratio ; les quintiles sont définis sur le revenu avant impôt.
- **Utilisé par** : `R/cm9.R`, section 11 a (`cex_cm9`, `biens_q_cm9`, `graphe_biens_revenu()`) ; figure `fig-biens-revenu-quintiles` de `cours/cm9.qmd` et diapo de répartition par revenu de `slides/cm9.qmd`.

## `cout_droits_deciles_yale_2026.csv`

- **Contenu** : coût annuel des droits de douane américains en vigueur par décile de revenu (1 à 10, et `Total`), en valeur positive, arrondi à trois décimales.
  - `decile` ;
  - `pct_revenu_presub`, `pct_revenu_postsub` : en % du revenu après impôts et transferts (projection 2027 du CBO), avant et après substitution des achats (report vers d'autres fournisseurs) ; la colonne tracée est `pct_revenu_postsub` ;
  - `usd_presub`, `usd_postsub` : en dollars de 2025 par ménage.
- **Source** : The Budget Lab at Yale, « The State of U.S. Tariffs », outil interactif, onglet « Projected Effects: Default Scenario », figure 4 « Household Cost of Tariffs by Income Decile » (source citée par l'outil : « GTAP v7 [Corong et al. (2017)], The Budget Lab analysis »). Mise à jour du 24/08/2026 (version de données `2026082411`), droit en vigueur (« current law »).
  - Page : https://budgetlab.yale.edu/research/state-us-tariffs
  - Fichier : https://interactives.budgetlab.yale.edu/tools/state-of-tariffs/data/default-scenario/distribution/data.csv
  - Contexte : `…/data/default-scenario/summary-statistics/data.csv` et `…/data/manifest.json` (méthodologie, date de version).
- **Téléchargé le** : 23/10/2026. SHA-256 : `ybl_default-scenario_distribution.csv` `701924fd26b81a27ffb6b77d5e680ea000168a5c74f61c1ea5d1fd355d8bb15b` ; `ybl_default-scenario_summary-statistics.csv` `115d05ae36160f95fcf470aae237418d22ced846f5c0965c75a569935fbda4b4` ; `ybl_state-of-tariffs_manifest_2026082411.json` `069fd64dd3968e09d80f6f0f01cc2c47fa2beac2abda412bab965b81d863391b` ; page `ybl_state-us-tariffs.html` `883f6373f63780baed63f833c9b9ae0893452cb2d79a88062d160c48f1e8b2e3` (conservés dans `_drafts/donnees/cm9-revenu/brut/`).
- **Traitement** : passage du format long au format large et changement de signe (le fichier note les pertes en négatif), rien d'autre (`data/cm9/preparer_revenu.R` ; vérifié le 23/10/2026 : sortie identique octet pour octet au CSV).
- **Limites** : estimation faite avant coup par un modèle (prix entrées-sorties et GTAP), pas une mesure ; répercussion des droits sur les prix payés par les acheteurs américains supposée, atténuée seulement par le dollar ; coût « ultime », après ajustement des prix ; la source ne dit pas sur quel revenu sont définis les déciles ; les montants changent à chaque mise à jour, d'où la date citée.
- **Utilisé par** : `R/cm9.R`, section 11 b (`ybl_cm9`, `ybl_d_cm9`, `graphe_cout_droits_deciles()`) ; figure `fig-cout-droits-deciles` de `cours/cm9.qmd` et diapo « En part du revenu, les droits pèsent trois fois plus sur les ménages modestes » de `slides/cm9.qmd`.

## `hausse_impot_droits_quintiles_tpc_2026.csv`

- **Contenu** : 9 lignes. `groupe` (libellé d'origine : cinq quintiles, puis 80-90, 90-95, 95-99 et 1 % les plus aisés) ; `hausse_taux_moyen_pts` : hausse du taux moyen d'imposition fédérale due aux droits annoncés du 20/01/2025 au 08/09/2026, en points de revenu monétaire élargi (« expanded cash income », un revenu avant impôt), 2026. La charge est répartie selon le revenu, et non selon la consommation.
- **Source** : Tax Policy Center (Urban-Brookings), R. McClelland et J. Wong, « TPC Tariff Tracker », 11/09/2026, figure 3, graphique Datawrapper `UATS7`, version 41 (tableau T26-0148).
  - Page : https://taxpolicycenter.org/features/tracking-trump-tariffs (lue dans le navigateur le 23/10/2026 : le site passe par une vérification Cloudflare qui bloque curl).
  - Fichier : https://datawrapper.dwcdn.net/UATS7/41/dataset.csv. La version 1, appelée par la page, redirige vers la 41 dans le navigateur ; `…/UATS7/1/dataset.csv` renvoie d'anciens chiffres.
- **Téléchargé le** : 23/10/2026. SHA-256 du fichier brut `tpc_datawrapper_UATS7_v41_dataset.csv` : `2cd3b89eecf9a5c9c639fa59a0d349397df04049b58e4a1c79751aa8e4177964` (conservé dans `_drafts/donnees/cm9-revenu/brut/`).
- **Traitement** : suppression de la ligne vide de séparation (`data/cm9/preparer_revenu.R` ; vérifié le 23/10/2026 : sortie identique octet pour octet au CSV).
- **Utilisé par** : `R/cm9.R`, section 11 c (`tpc_cm9`, vérification des 0,8 et 0,6 point cités dans le texte) ; pas de figure.

**Documents lus dans le navigateur, non enregistrés** (protection anti-robots du site), qui ont servi à la recherche mais ne sont pas cités dans la page : Congressional Budget Office, « Budgetary and Economic Effects of Increases in Tariffs Implemented Between January 6 and May 13, 2025 », 04/06/2025, https://www.cbo.gov/publication/61389 (PDF de 259 537 octets ; SHA-256 calculé dans le navigateur sur les octets servis : `548c4669c186b3d3c8fba14f2487d9c1d9607849e55518cb5b3ce132a2eb5894`) ; Tax Policy Center, Holtzblatt, McClelland et Wong, « Offsetting Families' Tariff Burdens through Refundable Tax Credits », juin 2026 (PDF de 2 449 141 octets ; SHA-256 calculé dans le navigateur : `9c48af485c885876f9cac6ba07de6057e5ff5291908b56019f2f7aef425167b4`). Détails : `quality_reports/donnees/cm9-revenu.md`.

## Utilisation

`R/cm9.R` lit les dix fichiers (`recettes_cm9`, `commerce_cm9`, `prix_cm9`, `effectif_cm9`, `part_douane_cm9`, `export_cm9`, `chine_cm9`, `cex_cm9`, `ybl_cm9`, `tpc_cm9`), trace `graphe_recettes_douane()`, `graphe_prix_import()`, `graphe_droit_effectif()`, `graphe_part_douane()`, `graphe_export_ue_usa()`, `graphe_chine_emploi()`, `graphe_biens_revenu()` et `graphe_cout_droits_deciles()`, et vérifie par `stopifnot()` chaque chiffre cité dans `cours/cm9.qmd`. `data/cm9/preparer_revenu.R` reconstruit les trois derniers CSV à partir des fichiers bruts ; ni la page ni les diapos ne l'appellent.
