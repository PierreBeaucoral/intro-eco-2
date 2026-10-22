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

## Utilisation

- `R/cm5.R` (`effets_zfe_cm5`, `parc_zfe_cm5`, `carburant_cm5` ; `graphe_effet_zfe()`, `graphe_parc_zfe()`, `graphe_carburant()`), donc `cours/cm5.qmd` (figures `fig-effet-zfe`, `fig-parc-zfe`, `fig-carburant`) et `slides/cm5.qmd`.
- La feuille Figure 3 sert aussi de document candidat pour le TD 5.
