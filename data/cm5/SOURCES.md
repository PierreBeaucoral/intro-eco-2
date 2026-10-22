# Données du CM 5

## `IA124.xlsx` (fichier brut, non modifié)

- **Source** : Insee, J. Garson, C. Malgouyres, M. Tô, C. Trevien, « Les ZFE renforcent le verdissement du parc automobile et contribuent au recul de ses émissions polluantes », *Insee Analyses* n° 124, 27/08/2026.
  - Page : https://www.insee.fr/fr/statistiques/9031856
  - Fichier : https://www.insee.fr/fr/statistiques/fichier/9031856/IA124.xlsx
- **Téléchargé le** : 21/10/2026 (SHA-256 : `e1f86db800a1de49ed34d03a68f0b716a806ff64b1ef567a045e16180de397e3`).
- **Contenu** : cinq feuilles (Sommaire, Figure 1 à Figure 4). Données sous-jacentes : SDES, RSVERO ; Citepa, OMINEA.

## `insee_ia124_fig4_emissions.csv`

- **Contenu** : feuille « Figure 4 », plage A6:F8. Effets des ZFE sur les émissions polluantes des voitures particulières, entre trois ans avant et deux ans après la mise en place de la ZFE. Une ligne par polluant (NOx, PM2,5, CO2).
  - `variation_observee` : variation observée, en % ;
  - `variation_contrefactuelle` : variation estimée sans ZFE, en % ;
  - `ic_bas`, `ic_haut` : bornes de l'intervalle de confiance de la variation contrefactuelle, en % ;
  - `effet_points` : effet de la ZFE publié par l'Insee, en points de pourcentage.
- **Champ** : intercommunalités des ZFE mises en place jusqu'en 2023, applicables aux voitures particulières ; les trois ZFE de 2023 (Nice, Grenoble, Toulouse) sont exclues de cette figure (note de l'Insee).
- **Traitement** : noms de colonnes et de polluants raccourcis, valeurs arrondies à une décimale. Aucune autre transformation.
- **Attention** : l'effet publié n'est pas toujours égal, au dixième près, à la différence des deux colonnes arrondies (PM2,5 : −1,4 publié, −1,5 par différence ; CO2 : −1,7 publié, −1,8 par différence). La page de cours cite l'effet publié.

## `insee_ia124_fig3_parc.csv`

- **Contenu** : feuille « Figure 3 », plage A6:G10. Effets des ZFE sur le parc de voitures, par catégorie Crit'Air, même fenêtre de cinq ans.
  - `vehicules_avant` : nombre de véhicules trois ans avant la ZFE ;
  - autres colonnes : comme ci-dessus ; `effet_points` vide = « ns », non significatif.
- **Champ** : intercommunalités des ZFE mises en place jusqu'en 2023, applicables aux voitures particulières.
- **Traitement** : comme ci-dessus ; « ns » remplacé par une case vide.

## `IP2125.xlsx` (fichier brut, non modifié)

- **Source** : Insee, E. Lenzi, K. Masson, V. Mora, « Les dépenses de carburant pèsent davantage sur le budget des ménages ruraux », *Insee Première* n° 2125, 08/09/2026.
  - Page : https://www.insee.fr/fr/statistiques/9037833
  - Fichier : https://www.insee.fr/fr/statistiques/fichier/9037833/IP2125.xlsx
- **Téléchargé le** : 21/10/2026 (SHA-256 : `970ec70329e14bc162795d5d86b2a88c5934f226f3cd6b8217e4db9925ee7000`).
- **Contenu** : onze feuilles (Sommaire, Figures 1 à 3, Figure encadré 2, Tableaux complémentaires 1 à 6). Données sous-jacentes : Insee, Fidéli 2022 ; SDES, RSVERO.

## `insee_ip2125_tc3_exposition.csv`

- **Contenu** : feuille « Tableau complémentaire 3 », plage A4:D10. Ménages « particulièrement exposés » au prix des carburants (ils consacrent plus d'un mois de revenu par an au carburant), par type d'intercommunalité, en 2021. Champ : France hors Mayotte, ménages qui ont une voiture, en logement ordinaire, à revenu positif.
  - `type_interco` : type d'intercommunalité (libellé de l'Insee) ; `niveau` : « agrégat » (urbain, rural), « détail » (sous-catégories) ou « ensemble » (ajouté par nous) ;
  - `part_exposes_prix_2021` : part des ménages exposés aux prix moyens constatés en 2021, en % (colonne D) ;
  - `part_exposes_prix_2026` : part des ménages exposés si le litre avait coûté 2,0 € (essence) et 2,2 € (gazole) en 2021, en % (colonne C). La page de l'Insee présente ces prix comme « les niveaux observés au printemps 2026 », à revenus et comportements inchangés ;
  - `nb_exposes_prix_2026` : nombre de ménages exposés dans ce scénario (colonne B).
- **Traitement** : noms de colonnes raccourcis, colonne `niveau` ajoutée, colonnes E et F (répartitions) non reprises ; valeurs déjà publiées à une décimale. Conformité au fichier brut vérifiée par script le 21/10/2026.

## `eurostat_env_air_emis_FR.csv` (fichier brut, non modifié)

- **Source** : Eurostat, *Air pollutants by source sector (source: EEA)*, jeu `env_air_emis`. Ce sont les données de l'inventaire national transmis par la France (Citepa) au titre de la convention sur la pollution atmosphérique transfrontière (CLRTAP).
  - Page : https://ec.europa.eu/eurostat/databrowser/view/env_air_emis/default/table
  - Fichier (API SDMX 2.1, CSV) : https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/env_air_emis/A..NOX+PM2_5.NFR1A3B1+NFR_TOT_NAT.FR?format=SDMX-CSV&compressed=false
- **Téléchargé le** : 22/10/2026 (SHA-256 : `55175a12f579211b2faefe8386bc361b583fc9db3e76770839468584e6f1a69a`).
- **Contenu** : France, tonnes, NOx (1987-2024) et PM2,5 (1990-2024), secteurs `NFR1A3B1` (voitures particulières, gaz d'échappement) et `NFR_TOT_NAT` (total national, non utilisé). Mise à jour Eurostat : 07/09/2026.

## `eurostat_emissions_voitures_fr_1990_2024.csv`

- **Contenu** : émissions des voitures particulières en France, une ligne par polluant et par année, 1990-2024 (70 lignes).
  - `annee` ; `polluant` : `NOX` (oxydes d'azote) ou `PM2_5` (particules fines) ;
  - `tonnes` : émissions de l'année, en tonnes ;
  - `indice_1990` : émissions rapportées à 1990, base 100, arrondi à une décimale.
- **Source** : fichier brut ci-dessus (`eurostat_env_air_emis_FR.csv`), téléchargé le 22/10/2026 (SHA-256 : `55175a12f579211b2faefe8386bc361b583fc9db3e76770839468584e6f1a69a`).
- **Champ** : France, voitures particulières, émissions à l'échappement (NFR 1A3bi). L'usure des pneus, des freins et des routes relève d'un autre poste (NFR 1A3bvi), non repris.
- **Traitement** : filtre `NFR1A3B1` et années ≥ 1990 ; calcul de l'indice. Aucune autre transformation (script de préparation conservé hors du dépôt, `_drafts/donnees/cm5/preparer.R`).
- **Utilisé par** : `R/cm5.R` (`emissions_cm5`, `var_emissions()`, `graphe_emissions_voitures()`), donc `cours/cm5.qmd` (figure `fig-emissions-voitures`) et `slides/cm5.qmd`.
- **Attention** : les variations nationales des PM2,5 d'échappement (−52,7 % de 2016 à 2021) sont bien plus fortes que le contrefactuel « sans ZFE » de l'Insee pour les PM2,5 (−29,6 %) ; les champs diffèrent sans doute (usure non comprise ici). Ne pas afficher les deux chiffres côte à côte sans vérification dans le document de travail Insee n° 2026-12.

## `sdes_parc_critair_fr_2011_2026.csv`

- **Contenu** : parc de voitures particulières en France au 1^er^ janvier, par groupe de vignettes Crit'Air, de 2011 à 2026 (48 lignes).
  - `annee` (parc au 1^er^ janvier) ; `groupe` : `E_1` (électriques et Crit'Air 1), `2` (Crit'Air 2), `3_plus` (Crit'Air 3, 4, 5 et non classées) ;
  - `voitures` : nombre de voitures du groupe ; `total` : toutes voitures, vignette « Inconnu » comprise ;
  - `part` : `voitures / total`, en %, arrondi à une décimale.
- **Source** : SDES (ministère de la Transition écologique), *Parc de véhicules routiers*, fichier « Données sur le parc de véhicules au niveau communal », millésime 2026-06 (diffusé le 10/07/2026).
  - Page : https://www.statistiques.developpement-durable.gouv.fr/catalogue?page=datafile&datafileRid=1582861b-e042-4490-9161-6429d8229703 (fiche data.gouv : https://www.data.gouv.fr/datasets/parc-de-vehicules-routiers)
  - Fichier (API DiDo, filtré sur les voitures particulières) : https://data.statistiques.developpement-durable.gouv.fr/dido/api/v1/datafiles/1582861b-e042-4490-9161-6429d8229703/csv?millesime=2026-06&CATEGORIE=eq:VP&withColumnName=true&withColumnDescription=false&withColumnUnit=false
- **Téléchargé le** : 22/10/2026 (SHA-256 du fichier brut : `031f53114cc205ea9cb05d9508ced16e0bec2b7937960cdab81cdb1b51b81e44` ; 86 Mo, 786 703 lignes, non versionné à cause de sa taille : le retélécharger à l'URL ci-dessus).
- **Champ** : France (toutes communes, y compris code commune inconnu), voitures particulières (catégorie VP), particuliers et professionnels.
- **Traitement** : somme nationale des parcs communaux ; vignette « Inconnu » (moins de 1 000 voitures par an) comptée dans le total mais pas représentée. Aucune autre transformation.
- **Utilisé par** : `R/cm5.R` (`parc_critair_cm5`, `part_critair()`, `graphe_parc_critair()`), donc `cours/cm5.qmd` (figure `fig-parc-critair`) et `slides/cm5.qmd`.
- **Attention** : données révisables plusieurs années, 2026 provisoire. La vignette est attribuée rétrospectivement (motorisation, date de première immatriculation), y compris avant la création de Crit'Air (2016). Champ national, agglomérations à ZFE comprises : ce n'est pas un contrefactuel. Recoupement : parc au 1^er^ janvier 2026 de 39 947 297 voitures, E 3,5 %, Crit'Air 1 38,0 %, Crit'Air 2 34,2 %, Crit'Air 3 et plus 24,3 %, identiques au dixième aux chiffres publiés par le SDES (lus dans un extrait de recherche, la page étant en maintenance le 22/10/2026). Au niveau national, les Crit'Air 5 et non classées pèsent 16,5 % du parc en 2016 : ne pas confondre avec les « environ 6 % » du parc des ZFE de l'Insee (champ différent).
- **Bizarrerie** : l'API décrit la colonne `PARC_2026` comme « parc au 1er janvier 2025_1 » ; les totaux recoupent bien le parc publié au 1^er^ janvier 2026.

## `wob_prix_carburants_fr_2019_2026.csv`

- **Contenu** : prix à la pompe en France, toutes taxes comprises, une ligne par semaine (lundi de référence), du 07/01/2019 au 19/10/2026.
  - `date` : AAAA-MM-JJ ;
  - `sp95` : Euro-super 95 (colonne `FR_price_with_tax_euro95`) ; `gazole` : gazole (colonne `FR_price_with_tax_diesel`) ; en € par litre (valeur du fichier, en € pour 1 000 litres, divisée par 1 000).
- **Source** : Commission européenne, DG Énergie, *Weekly Oil Bulletin*, fichier historique, feuille « Prices with taxes ».
  - Page : https://energy.ec.europa.eu/data-and-analysis/weekly-oil-bulletin_en
  - Fichier : https://energy.ec.europa.eu/document/download/906e60ca-8b6a-44e7-8589-652854d2fd3f_en?filename=Weekly_Oil_Bulletin_Prices_History_maticni_4web.xlsx
- **Téléchargé le** : 22/10/2026 (SHA-256 du fichier xlsx : `7e019a27fe2df6f324ec7a7c551b98142713fbee32aa7a030906101ffc22b2fd`, même version que celle relue pour le CM 1 ; 4,5 Mo, non versionné ici).
- **Champ** : France, prix moyens à la pompe communiqués par l'État à la Commission.
- **Traitement** : colonnes repérées par leur nom, dates Excel converties, semaines depuis le 01/01/2019, division par 1 000. Aucune autre transformation. Les moyennes du printemps 2026 (13 semaines du 23/03 au 15/06 : 2,04 € le sans plomb 95, 2,14 € le gazole) se calculent dans `R/cm5.R`.
- **Utilisé par** : `R/cm5.R` (`prix_carburants_cm5`, `prix_printemps()`, `graphe_prix_carburants()`), donc `cours/cm5.qmd` (figure `fig-prix-carburants`) et `slides/cm5.qmd`.
- **Attention** : moyennes pondérées, pas des relevés de station. Avant de comparer 2022 et 2026, vérifier si les prix 2022 du bulletin intègrent la remise à la pompe d'avril à décembre 2022.

## `eurostat_sdg_11_52.csv` (fichier brut, non modifié)

- **Source** : Eurostat, *Premature deaths due to exposure to fine particulate matter (PM2.5)*, jeu `sdg_11_52` (source : Agence européenne pour l'environnement, AEE).
  - Page : https://ec.europa.eu/eurostat/databrowser/view/sdg_11_52/default/table
  - Fichier (API SDMX 2.1, CSV) : https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/sdg_11_52/?format=SDMX-CSV&compressed=false
- **Téléchargé le** : 22/10/2026 (SHA-256 : `26c8d6cfc83a6a244af12dd553ff32a73aece28ffeaabf988041b485a99362eb`).
- **Contenu** : tous pays, unités `NR` (nombre) et `RT` (taux pour 100 000 habitants), 2005 et 2007-2023. Mise à jour Eurostat : 09/12/2025.

## `eurostat_deces_pm25_fr_2005_2023.csv`

- **Contenu** : une ligne par année, 2005 et 2007-2023 (pas d'estimation pour 2006).
  - `annee` ; `deces` : décès prématurés attribuables à l'exposition de long terme aux PM2,5, en nombre.
- **Source** : fichier brut ci-dessus (`eurostat_sdg_11_52.csv`), téléchargé le 22/10/2026 (SHA-256 : `26c8d6cfc83a6a244af12dd553ff32a73aece28ffeaabf988041b485a99362eb`).
- **Champ** : France ; toutes sources de PM2,5 confondues, pas seulement l'automobile.
- **Traitement** : filtre `geo = FR`, `unit = NR`. Aucune autre transformation.
- **Utilisé par** : `R/cm5.R` (`deces_pm25_cm5`, `graphe_deces_pm25()`), donc `cours/cm5.qmd` (figure `fig-deces-pm25`) et `slides/cm5.qmd`.
- **Attention** : série heurtée (2014 : 22 279 ; 2015 : 27 834), sensible à la météorologie et aux révisions de méthode de l'AEE. Recoupement : AEE, *Air pollution country fact sheets 2025*, France, « 14,741 (95% CI: 11,201-16,477) attributable deaths in 2023 » (lu le 22/10/2026), identique. Selon l'AEE, ses estimations ne sont pas comparables à celles de Santé publique France : ne pas mélanger les deux sources.

## Utilisation

- `R/cm5.R` (`effets_zfe_cm5`, `parc_zfe_cm5`, `carburant_cm5` ; `graphe_effet_zfe()`, `graphe_parc_zfe()`, `graphe_carburant()`), donc `cours/cm5.qmd` (figures `fig-effet-zfe`, `fig-parc-zfe`, `fig-carburant`) et `slides/cm5.qmd`.
- `R/cm5.R` (`deces_pm25_cm5`, `emissions_cm5`, `parc_critair_cm5`, `prix_carburants_cm5` ; `graphe_deces_pm25()`, `graphe_emissions_voitures()`, `graphe_parc_critair()`, `graphe_prix_carburants()`), donc `cours/cm5.qmd` (figures `fig-deces-pm25`, `fig-emissions-voitures`, `fig-parc-critair`, `fig-prix-carburants`) et `slides/cm5.qmd`.
- La feuille Figure 3 sert aussi de document candidat pour le TD 5.
