# Données du CM 4

## `loyers_ipch_2015_2025.csv`

- **Contenu** : indice des prix à la consommation harmonisé (IPCH), poste « loyers effectifs du logement » (COICOP CP041), moyenne annuelle, base 100 en 2015. Une ligne par année, de 2015 à 2025.
  - `annee` ;
  - `France`, `Allemagne`, `Zone_euro` (zone euro dans sa composition évolutive, code `EA`).
- **Source** : Eurostat, jeu `prc_hicp_aind` (unité `INX_A_AVG`), mis à jour par Eurostat le 06/02/2026.
  - Requête : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hicp_aind?format=JSON&lang=EN&geo=FR&geo=DE&geo=EA&coicop=CP041&unit=INX_A_AVG&sinceTimePeriod=2015&untilTimePeriod=2025
- **Téléchargé le** : 21/10/2026 (SHA-256 de la réponse JSON : `7fb8c27bc8da3e09c24dacbaaff8085b9a0eaa340438431de1a2e3f55b2ecbcc`).
- **Traitement** : aucun ; valeurs recopiées telles quelles depuis le JSON.
- **Attention** : c'est un indice d'évolution, pas un niveau en €/m². Il couvre tous les loyers (secteur libre et social, zones encadrées ou non) : aucune lecture causale de l'effet de l'encadrement.
- **Utilisé par** : `R/cm4.R` (`loyers_ipch_cm4`, `graphe_loyers_europe()`).

## `taux_effort_insee_2023.csv`

- **Contenu** : taux d'effort médian des locataires en 2023, en %, selon le quart (quartile) de niveau de vie : 1 = moins que le 1er quartile (les 25 % les plus modestes), 4 = plus que le 3e quartile (les 25 % les plus aisés). Taux net des aides au logement ; dépenses = loyer, charges locatives, eau, énergie, assurance habitation.
  - Ensemble : secteur libre 29,6 % ; secteur social 26,6 % (non repris dans le fichier, cités dans `R/cm4.R`).
- **Source** : Insee, *France, portrait social*, édition 2025, fiche « Logement », Insee Références, 18/11/2025 (enquête SRCV 2024, revenus et dépenses 2023). https://www.insee.fr/fr/statistiques/8612550
- **Consulté le** : 21/10/2026. Saisie manuelle depuis le tableau de la fiche.
- **Utilisé par** : `R/cm4.R` (`taux_effort_cm4`, `graphe_taux_effort()`).

## `construction_parc_insee_2000_2025.csv`

- **Contenu** : logements mis en chantier rapportés au parc existant, France hors Mayotte. Une ligne par année, de 2000 à 2025.
  - `annee` ;
  - `logements_commences` : logements commencés dans l'année (cumul sur douze mois à fin décembre), estimations en date réelle, données brutes ;
  - `parc_milliers` : nombre total de logements au 1^er^ janvier de l'année, en milliers ; 2024 et 2025 provisoires (statut `P`) ;
  - `commences_pct_parc` = 100 × `logements_commences` / (1 000 × `parc_milliers`), arrondi à deux décimales.
- **Source** : Insee, Banque de données macroéconomiques (BDM), API SDMX publique.
  - Logements commencés : série `001718270` (données SDES, Sit@del2), dernière mise à jour 29/09/2026. Page : https://www.insee.fr/fr/statistiques/serie/001718270 ; requête : https://bdm.insee.fr/series/sdmx/data/SERIES_BDM/001718270
  - Parc de logements : série `001791241` (jeu `PARC-LOGEMENTS`), dernière mise à jour 30/09/2026. Page : https://www.insee.fr/fr/metadonnees/source/serie/s1350 ; requête : https://bdm.insee.fr/series/sdmx/data/PARC-LOGEMENTS
- **Téléchargé le** : 22/10/2026.
  - `insee_bdm_001718270.xml` : SHA-256 `1e5267838a477fd7eb4ec769089ea1ac8beed926984fb38457544e80a34011f6` ;
  - `insee_bdm_PARC-LOGEMENTS.xml` : SHA-256 `96f3a5adc980d6123653d688cdbf3b41fec91cf15d8ed18a1b39d757952d33f8`.
  - Les fichiers bruts et le script d'extraction sont dans `_drafts/donnees/cm4/` (`brut/`, `extraction.R`).
- **Traitement** : valeurs de décembre de la série `001718270` (total de l'année), fusion avec le parc par année, calcul du ratio. Aucune saisie manuelle.
- **Recoupement** : parc au 1^er^ janvier 2025, 38 380 milliers ; Insee Focus n° 359, 17/09/2025 : « la France hors Mayotte compte 38,4 millions de logements ».
- **Attention** : millésime actuel du SDES (méthode d'estimation en date réelle révisée en 2025) ; des publications plus anciennes donnent des niveaux de mises en chantier plus élevés. Les mises en chantier comprennent logements sociaux et maisons de propriétaires occupants, et le parc comprend résidences secondaires et logements vacants : c'est un ordre de grandeur du rapport flux / stock, pas l'offre locative privée. Le creux de 2023-2025 tient surtout à la hausse des taux d'intérêt, pas à l'encadrement.
- **Utilisé par** : `R/cm4.R` (`construction_cm4`, `graphe_construction_parc()`), donc `cours/cm4.qmd` et `slides/cm4.qmd`.

## `salaire_minimum_median_ocde_2000_2025.csv`

- **Contenu** : salaire minimum brut en % du salaire médian brut des salariés à temps plein. Une ligne par année, de 2000 à 2025.
  - `annee` ;
  - `France` ;
  - `Allemagne` : vide avant 2015 (pas de salaire minimum légal) ;
  - `Etats_Unis` : salaire minimum fédéral.
- **Source** : OCDE, Data Explorer, « Minimum relative to average wages of full-time workers », dataflow `OECD.ELS.SAE,DSD_EARNINGS@MIN2AVE,1.0`, mesure `MR_WG_FT`, unité `PT_WG_A_SAL_FT`, agrégation `MEDIAN`.
  - Page : https://data-explorer.oecd.org/ (rechercher « Minimum relative to average wages »).
  - Requête : https://sdmx.oecd.org/public/rest/data/OECD.ELS.SAE,DSD_EARNINGS@MIN2AVE,1.0/.MR_WG_FT....MEDIAN.?startPeriod=2000&format=csvfilewithlabels
- **Téléchargé le** : 22/10/2026. `oecd_MIN2AVE_median_tous_pays.csv` (tous les pays de l'OCDE disponibles) : SHA-256 `1971c50d165860d6940304eb50a2db01723a603e18587963e6d9bfeb8c1a761c`.
- **Traitement** : filtre FRA, DEU, USA ; passage en format large ; arrondi à 0,1. Script : `_drafts/donnees/cm4/extraction.R`.
- **Recoupement** : États-Unis 2025, 24,1 % ; reconstruit avec le BLS (série LEU0252881500, salaire hebdomadaire médian 2025 de 1 204 $) : 7,25 $ × 40 h / 1 204 $ = 24,09 %.
- **Attention** : la série s'arrête en 2025 ; le SMIC de 12,31 € du 01/06/2026, cité dans la page, n'y figure pas. Le chiffre américain est le minimum fédéral : beaucoup d'États ont un minimum plus élevé.
- **Utilisé par** : `R/cm4.R` (`smic_median_cm4`, `graphe_salaire_minimum()`), donc `cours/cm4.qmd` et `slides/cm4.qmd`.

## `locataires_eurostat_2025.csv`

- **Contenu** : part de la population locataire de son logement en 2025, en % des personnes. Une ligne par zone : Allemagne (`DE`), Union européenne à 27 (`EU27_2020`), France (`FR`).
  - `code`, `zone` ;
  - `locataires_prix_marche` : loyer au prix du marché (`RENT_MKT`) ;
  - `locataires_prix_reduit` : loyer réduit ou logement gratuit (`RENT_FR`) ;
  - `locataires_total` : ensemble des locataires (`RENT`).
- **Source** : Eurostat, EU-SILC, « Distribution of population by tenure status, type of household and income group », jeu `ilc_lvho02` (unité `PC`, `hhcomp=TOTAL`, `rskpovth=TOTAL`), mis à jour par Eurostat le 20/10/2026.
  - Page : https://ec.europa.eu/eurostat/databrowser/view/ilc_lvho02/default/table
  - Requête : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/ilc_lvho02?format=JSON&lang=EN&geo=FR&geo=DE&geo=EU27_2020&sinceTimePeriod=2025
- **Téléchargé le** : 22/10/2026. `eurostat_ilc_lvho02_FR_DE_EU.json` : SHA-256 `060de984271061be5fdfb2eb02625b8f04032fd51029deb47873411971c48226`.
- **Traitement** : aucun ; valeurs lues dans le JSON par `_drafts/donnees/cm4/extraction.R`, qui vérifie que marché + réduit = total (à 0,1 près).
- **Attention** : personnes, pas ménages. Les catégories d'Eurostat ne coïncident pas avec le secteur libre et le secteur social de l'Insee : pour la France, « loyer réduit ou gratuit » (22,2 %) regroupe le logement social et les personnes logées gratuitement, et l'Insee compte 23,1 % de ménages locataires d'un bailleur privé en 2025 (série BDM `001791252`), contre 16,4 % de personnes « au prix du marché » chez Eurostat.
- **Utilisé par** : `R/cm4.R` (`locataires_cm4`, `graphe_locataires()`), donc `cours/cm4.qmd` et `slides/cm4.qmd`.

## `surcharge_logement_france_eurostat_2025.csv`

- **Contenu** : taux de surcharge des coûts du logement en France en 2025, selon le statut d'occupation : part des personnes vivant dans un ménage dont les coûts du logement, nets des aides, dépassent 40 % du revenu disponible. Une ligne par statut.
  - `code` : `RENT_MKT` (locataires, loyer au prix du marché), `RENT_FR` (locataires, loyer réduit ou gratuit), `TOTAL` (ensemble de la population), `OWN_L` (propriétaires avec emprunt), `OWN_NL` (propriétaires sans emprunt) ;
  - `statut` : libellé en français ;
  - `surcharge_pct` : en %.
- **Source** : Eurostat, EU-SILC, « Housing cost overburden rate by tenure status », jeu `ilc_lvho07c` (unité `PC`), mis à jour par Eurostat le 20/10/2026.
  - Page : https://ec.europa.eu/eurostat/databrowser/view/ilc_lvho07c/default/table
  - Requête : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/ilc_lvho07c?format=JSON&lang=EN&geo=FR&sinceTimePeriod=2010
- **Téléchargé le** : 22/10/2026. `eurostat_ilc_lvho07c_FR.json` (France, 2010-2025) : SHA-256 `929d5276db4c1a92997525552601158f0d500d17e25ed318af9708a25a057198`.
- **Traitement** : aucun ; valeurs de 2025 lues dans le JSON par `_drafts/donnees/cm4/extraction.R`.
- **Attention** : seuil de 40 % du revenu, à ne pas confondre avec le taux d'effort médian de l'Insee (29,6 % dans le secteur libre, fichier `taux_effort_insee_2023.csv`) : deux indicateurs différents, sur des sources et des années différentes.
- **Utilisé par** : `R/cm4.R` (`surcharge_cm4`, `graphe_surcharge()`), donc `cours/cm4.qmd` et `slides/cm4.qmd`.
