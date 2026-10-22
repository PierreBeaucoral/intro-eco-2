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
