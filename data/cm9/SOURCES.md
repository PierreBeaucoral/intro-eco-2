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

## Utilisation

`R/cm9.R` lit les trois fichiers (`recettes_cm9`, `commerce_cm9`, `prix_cm9`), trace `graphe_recettes_douane()` et `graphe_prix_import()` et vérifie par `stopifnot()` chaque chiffre cité dans `cours/cm9.qmd`.
