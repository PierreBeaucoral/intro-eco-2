# Données du CM 2

## `droit_consommation_tabac.csv`

- **Contenu** : recettes du droit de consommation sur les tabacs (somme de l'accise proportionnelle et de l'accise spécifique, hors TVA), France continentale (hors Corse), de 1991 à 2025. Une ligne par année.
  - `annee` : année civile ;
  - `courant_mds` : montant en milliards d'euros courants (colonne (1) du tableau) ;
  - `indice_prix` : indice annuel des prix utilisé par l'auteure (colonne (3) ; il vaut 100 en 2001).
- **Source** : C. Hill, *Impact de l'augmentation des prix sur la consommation de tabac*, ex-Institut Gustave Roussy, 2026, chapitre 6, tableau 6 (p. 68).
  - PDF : https://www.gustaveroussy.fr/sites/default/files/impact_prix_consommation_tabac_2026.pdf
- **Téléchargé et lu le** : 21/10/2026 (texte extrait avec `pdftotext -layout`, valeurs recopiées à la main puis relues).
- **Traitement** : aucun. Le montant en euros constants (prix de 2001) est recalculé dans `R/cm2.R` comme `courant_mds * 100 / indice_prix`, la formule de la colonne (1)*100/(3) du tableau ; il redonne les valeurs publiées à l'arrondi près.
- **Utilisé par** : `R/cm2.R` (`recettes_cm2`, `graphe_recettes_tabac()`), donc `cours/cm2.qmd` et `slides/cm2.qmd`.
- **Attention** :
  - le texte du chapitre 6 dit que le montant a « presque quadruplé » de 1991 à 2020 en euros courants ; le tableau donne 3,26 puis 14,35 Md€, soit un facteur 4,4. La page de cours s'en tient au tableau ;
  - de 2020 à 2025, le tableau donne −11,2 % en euros courants et −22,8 % en euros constants (le texte dit −22 %) ;
  - ce sont les seules recettes d'accise : la TVA sur le tabac n'est pas comprise.

## `consommation_tabac_insee.csv`

- **Contenu** : prix, volume et valeur de la dépense de consommation finale des ménages (hors entrepreneurs individuels) en produits à base de tabac, France entière, 2000 à 2025, et indice général des prix à la consommation harmonisé (IPCH) de la France. Une ligne par année.
  - `annee` : année civile ;
  - `prix_indice_2020` : indice de prix chaîné, base 100 en 2020 (Insee, série **011782481**) ;
  - `volume_meur2020` : dépense en volume, en millions d'euros de 2020, prix chaînés (Insee, série **011782482**) ;
  - `depense_meur_courants` : dépense en millions d'euros courants (Insee, série **011782483**) ;
  - `ihpc_ensemble_2015` : IPCH ensemble, indice moyen annuel, base 100 en 2015 (Eurostat, `prc_hicp_aind`, `coicop = CP00`, `geo = FR`, `unit = INX_A_AVG`).
- **Sources** :
  - Insee, comptes nationaux annuels base 2020, mise à jour du 29/05/2026. Pages des séries : https://www.insee.fr/fr/statistiques/serie/011782481 , https://www.insee.fr/fr/statistiques/serie/011782482 , https://www.insee.fr/fr/statistiques/serie/011782483 . Téléchargement par l'API SDMX de la BDM : https://bdm.insee.fr/series/sdmx/data/SERIES_BDM/011782482+011782481+011782483
  - Eurostat, « IPCH - données annuelles (indice moyen et taux de variation) », jeu `prc_hicp_aind`, mis à jour le 06/02/2026. Page : https://ec.europa.eu/eurostat/databrowser/view/prc_hicp_aind/default/table . Téléchargement : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hicp_aind?format=JSON&geo=FR&unit=INX_A_AVG&coicop=CP022&coicop=CP00&lang=fr
- **Téléchargé le** : 21/10/2026.
- **Traitement** : valeurs recopiées telles quelles (années 2000 à 2025 ; les séries Insee commencent en 1999). La figure (`graphe_conso_tabac()` dans `R/cm2.R`) ramène chaque série Insee à 100 en 2000. L'IPCH ne sert qu'aux calculs du texte (hausse générale des prix de 59 %, prix réel du tabac × 2,9, dépense réelle +3 % de 2000 à 2025).
- **Utilisé par** : `R/cm2.R` (`conso_cm2`, `conso_rapport()`, `graphe_conso_tabac()`), donc `cours/cm2.qmd` (figure `fig-conso-tabac`) et éventuellement `slides/cm2.qmd`.
- **Attention** :
  - le volume couvre **tous** les produits du tabac (cigarettes, tabac à rouler, cigares…) et n'est pas rapporté à la population : il ne se compare pas directement aux ventes de cigarettes par adulte de Hill (2026), qui donne « ventes divisées par 2,6 » de 2006 à 2025 (avec ces données-ci : quantités divisées par 2,0 et prix réel × 2,0 sur 2006-2025) ;
  - la dépense en euros courants égale le prix multiplié par le volume à 0,5 % près (arrondis de l'Insee), ce que vérifie un `stopifnot()` ;
  - au passage, le tableau 1.1 de Hill (2026) donne pour 2023 des ventes de cigarettes (37,0 milliards) en net rebond entre 2022 (31,7) et 2024 (25,5), que les comptes nationaux ne montrent pas (volume en baisse de 7 % en 2023) : probable coquille du rapport, sans effet sur la page, qui ne cite pas ce chiffre.

## `cigarettes_tabac_rouler_hill.csv`

- **Contenu** : ventes annuelles de cigarettes manufacturées et de tabac à rouler dans le réseau des buralistes, en milliers de tonnes, France métropolitaine, de 2000 à 2025. Une ligne par année.
  - `annee` : année civile ;
  - `cigarettes_kt` : colonne « Cigarettes manufacturées (milliers de tonnes) » ;
  - `tabac_rouler_kt` : colonne « Tabac en paquet, à rouler (milliers de tonnes) » ;
  - `suspect` : `TRUE` pour 2023 seulement (voir « Attention »).
- **Source** : C. Hill, *Impact de l'augmentation des prix sur la consommation de tabac*, ex-Institut Gustave Roussy, 2026, tableau 1.1 (p. 11-13).
  - PDF : https://www.gustaveroussy.fr/sites/default/files/impact_prix_consommation_tabac_2026.pdf
- **Téléchargé et lu le** : 22/10/2026 (SHA-256 du fichier PDF : `f46cc6be1f46c143d70f4c18a6ee1c1819309a90b2e02ee3f48da1699a83155e` ; copie brute dans `_drafts/donnees/cm2/brut/`). Texte extrait avec `pdftotext -layout`, valeurs recopiées à la main puis vérifiées par `_drafts/donnees/cm2/extraction.R`.
- **Traitement** : aucun dans le CSV. La figure (`graphe_cigarettes_rouler()` dans `R/cm2.R`) ramène chaque série à 100 en 2000 et ne trace pas 2023.
- **Utilisé par** : `R/cm2.R` (`rouler_cm2`, `indice_rouler()`, `graphe_cigarettes_rouler()`), donc `cours/cm2.qmd` (figure `fig-cigarettes-rouler`) et `slides/cm2.qmd`.
- **Attention** :
  - la ligne 2023 (29,6 kt de cigarettes et 6,7 kt de tabac à rouler) rebondit par rapport à 2022 (25,4 et 6,3), alors que l'OFDT montre une baisse continue des ventes totales (40 314 t en 2022, 37 120 t en 2023, 32 846 t en 2024) : probable coquille, déjà signalée plus haut pour `consommation_tabac_insee.csv` ;
  - Hill compte 0,8 g de tabac par cigarette depuis 2001 (1 g en 1980, puis une baisse linéaire), l'OFDT 1 g : les tonnages de cigarettes diffèrent d'environ 25 % entre les deux sources (2025 : 18,7 kt × 1,25 = 23,4 kt, contre 23 326 t pour l'OFDT) ;
  - le tabac à rouler n'est distingué du tabac à pipe que depuis 1990 (note b du tableau).

## `prix_tabac_europe_eurostat.csv`

- **Contenu** : indices de niveau des prix (UE à 27 = 100) pour 9 pays et l'UE. Une ligne par pays.
  - `code`, `pays` : code géographique Eurostat et nom ;
  - `pli_tabac_2025`, `pli_tabac_2024` : poste « Tabac » (`ppp_cat18 = A010203`) en 2025 et en 2024 ;
  - `pli_ensemble_2025` : consommation individuelle effective (`A01`) en 2025, pour situer le niveau général des prix.
- **Source** : Eurostat, « Purchasing power parities, price level indices, nominal and real expenditures by analytical categories - based on COICOP 2018 », jeu `prc_ppp_ind_1`, indicateur `PLI_EU27_2020`, mis à jour le 09/07/2026.
  - Page : https://ec.europa.eu/eurostat/databrowser/view/prc_ppp_ind_1/default/table
  - Téléchargement : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_ppp_ind_1?format=JSON&lang=fr&indic_ppp=PLI_EU27_2020&ppp_cat18=A010203&ppp_cat18=A01
- **Téléchargé le** : 22/10/2026 (SHA-256 de la réponse JSON : `ce6bb3b3e5f388ca3566581a28cad61043550c68692e99ee6cef805c1de24f58` ; copie brute dans `_drafts/donnees/cm2/brut/`).
- **Traitement** : sélection de 10 zones géographiques par `_drafts/donnees/cm2/extraction.R`, sans autre calcul. Les rapports entre pays (France ÷ Espagne = 2,35) se calculent dans `R/cm2.R`.
- **Utilisé par** : `R/cm2.R` (`prix_europe_cm2`, `pli_tabac()`, `graphe_prix_europe()`), donc `cours/cm2.qmd` (figure `fig-prix-europe`) et `slides/cm2.qmd`.
- **Attention** :
  - c'est un indice de niveau des prix de l'**ensemble des produits du tabac**, pas le prix d'un paquet ; il compare des prix en euros (convertis au taux de change pour la Suisse), sans correction de pouvoir d'achat ;
  - dans ce jeu, le poste tabac ne commence qu'en 2022 ; l'ancien jeu `prc_ppp_ind` (COICOP 1999, poste `A010202`) va de 1995 à 2024 ;
  - le Royaume-Uni et Andorre ne figurent pas dans le jeu.

## `ventes_frontaliers_ofdt.csv`

- **Contenu** : variation cumulée depuis 2017 des volumes de tabac vendus dans le réseau des buralistes, en %, selon que le département est frontalier ou non. France continentale, une ligne par année de 2017 à 2025.
  - `annee` : année civile ;
  - `frontaliers` : variation en % par rapport à 2017, départements frontaliers ;
  - `non_frontaliers` : idem, départements non frontaliers.
- **Source** : M.-A. Douchet, *Tabagisme et arrêt du tabac en 2025*, OFDT, mai 2026, graphique 2, p. 4 (données DGDDI, exploitation OFDT).
  - Page : https://www.ofdt.fr/publication/2026/tabagisme-et-arret-du-tabac-en-2025-2681
  - PDF : https://www.ofdt.fr/sites/ofdt/files/2026-05/note-bilan-tabac-2026.pdf
- **Téléchargé et lu le** : 22/10/2026 (SHA-256 du fichier PDF : `08a3aea54bdd63e3fff0ce9c0487542fa87a9c473ffc8d36fd8f2fce2f14bff7` ; copie brute dans `_drafts/donnees/cm2/brut/`). Étiquettes du graphique extraites avec `pdftotext -layout` ; l'attribution de chaque valeur à son année et à sa série a été contrôlée par les coordonnées (`pdftotext -bbox`) : chaque année porte deux étiquettes, la plus basse est celle des départements frontaliers, conformément au texte (« – 50,3 % » contre « – 43,6 % » en 2025).
- **Traitement** : aucun dans le CSV. `R/cm2.R` trace 100 + la variation, soit un indice base 100 en 2017.
- **Utilisé par** : `R/cm2.R` (`frontaliers_cm2`, `graphe_ventes_frontaliers()`), donc `cours/cm2.qmd` (figure `fig-ventes-frontaliers`) et `slides/cm2.qmd`.
- **Attention** :
  - l'OFDT ne publie pas les volumes en tonnes par groupe de départements, seulement ces taux, et aucun fichier tableur ;
  - de 2024 à 2025, les indices arrondis donnent −7,3 % (frontaliers) et −8,4 % (non frontaliers) ; le texte de l'OFDT (p. 3) donne −7,3 % et −8,3 % : écart d'arrondi sur les variations cumulées.

## `fumeurs_par_sexe_hill.csv`

- **Contenu** : part des fumeurs réguliers, en % des adultes, par sexe, pour chaque enquête de 1953 à 2024. Une ligne par enquête.
  - `annee` : année de l'enquête ;
  - `hommes_pct`, `femmes_pct` : lignes (1) et (4) du tableau ;
  - `enquete` : organisme commanditaire (SEITA, INSEE, INPES, Santé publique France).
- **Source** : C. Hill (2026), tableau 2.1, p. 34, même fichier PDF que `cigarettes_tabac_rouler_hill.csv` (même URL, même SHA-256).
- **Téléchargé et lu le** : 22/10/2026 (`pdftotext -layout`, valeurs recopiées à la main puis vérifiées par `_drafts/donnees/cm2/extraction.R`).
- **Traitement** : aucun.
- **Utilisé par** : `R/cm2.R` (`fumeurs_cm2`, `fumeurs_annee()`, `graphe_fumeurs_sexe()`), donc `cours/cm2.qmd` (figure `fig-fumeurs-sexe`) et `slides/cm2.qmd`.
- **Attention** :
  - les enquêtes changent de champ et de définition au fil du temps ; depuis 2017 (Santé publique France), les valeurs sont celles du tabagisme quotidien des 18-75 ans et coïncident avec le graphique 4 de l'OFDT (2026) ;
  - il n'y a pas d'enquête entre 1953 et 1980 ;
  - pour 2014, le tableau donne 32,9 % (hommes) et 24,4 % (femmes), soit environ 28,5 % en moyenne pondérée : plus que les « environ 25 % en 2014 » cités dans la page d'après *La finance pour tous* (l'OFDT situe les 25 % en 2021). Corrigé le 22/10/2026 : la page et la diapo d'ouverture donnent désormais « environ 25 % en 2021 à 18 % en 2024 » (Santé publique France, citée par l'OFDT, 2026, p. 13).
