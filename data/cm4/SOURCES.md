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
