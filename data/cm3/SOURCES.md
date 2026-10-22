# Sources des données du CM 3

## boites_aglp1_2020_2024.csv

- **Contenu** : nombre de boîtes d'analogues du GLP-1 (code ATC A10BJ) remboursées par l'ensemble des régimes de l'Assurance Maladie, délivrées en pharmacie de ville, tous prescripteurs (ville et hôpital), par produit et par année, de 2020 à 2024, et base de remboursement correspondante. En date de remboursement. Une ligne par (année, produit) : `annee`, `produit` (nom commercial), `boites`, `base_remboursement` (euros, somme sur toutes les présentations du produit, arrondie au centime).
- **Colonnes lues** : « Nombre de boites remboursées » (colonne 11) et « Base de remboursement » (colonne 10) de la feuille `MedicAM_AAAA_tous_presc`.
- **Transformation pour les figures** (dans `R/cm3.R`, pas dans le CSV) : `fig-boites` somme les boîtes par produit (Byetta et Bydureon regroupés en « Autres ») ; `fig-prix-ozempic` calcule un prix moyen par boîte d'Ozempic = `base_remboursement / boites`, toutes doses (0,25, 0,5 et 1 mg) confondues. Résultat : 79,99 € (2020), 80,08 € (2021), 80,59 € (2022), 78,92 € (2023), 77,82 € (2024).
- **Source** : Assurance Maladie, Medic'AM, fichiers annuels « par type de prescripteur », feuille `MedicAM_AAAA_tous_presc` (colonne « Nombre de boites remboursées »).
  - Fiche du jeu de données : https://www.data.gouv.fr/datasets/536999d3a3a729239d20533a (dernière modification affichée : 31/03/2026).
  - Fichiers : `https://www.assurance-maladie.ameli.fr/sites/default/files/` suivi de
    `2020_medic-am-par-type-de-prescripteur_cumul-annuel.zip`,
    `2021_medic-am-par-type-de-prescripteur_cumul-annuel.zip`,
    `2022-medic-am-par-type-de-prescripteur_serie-annuelle.zip`,
    `2023-medic-am-par-type-de-prescripteur_serie-annuelle.zip`,
    `2024-medic-am-par-type-de-prescripteur_serie-annuelle.zip` (édition 2024 : février 2025).
- **Téléchargement** : 21/10/2026, par `data/cm3/extraire_medicam.R` (à relancer depuis la racine du projet pour reconstruire le CSV). Colonne `base_remboursement` ajoutée le 21/10/2026 par une nouvelle exécution du script : les colonnes `annee`, `produit`, `boites` sont restées identiques à l'extraction précédente (vérifié par `diff`).
- **Contrôle** : les totaux « prescriptions de ville » (feuille `presc_ville`) recoupent le tableau 1 de P. Lhotellier, thèse de médecine, Université de Lille, 17/12/2025 (https://pepite-depot.univ-lille.fr/LIBRE/Th_Medecine/2025/2025ULILM502.pdf) : Ozempic 2 409 998 boîtes en 2023 et 3 041 638 en 2024 dans les deux sources.
- **Limites** :
  - délivrances en pharmacie de ville seulement (les médicaments délivrés aux patients hospitalisés ne sont pas comptés) ;
  - boîtes **remboursées** : un usage non remboursé (achat sans prise en charge) n'apparaît pas ;
  - on observe des boîtes délivrées, pas la demande : pendant une pénurie, la quantité délivrée est plafonnée par l'offre ;
  - le prix moyen par boîte est une moyenne pondérée par les doses délivrées : il peut bouger si la répartition entre 0,25, 0,5 et 1 mg change, même à tarifs inchangés ; la documentation Medic'AM (onglet « lisez-moi ») ne précise pas si la base inclut l'honoraire de dispensation, d'où la formulation « tarif sur lequel l'Assurance maladie calcule son remboursement » dans la page ;
  - 2019 écarté : Trulicity et Victoza n'y portent pas le code A10BJ ;
  - 2025 non repris : sur data.gouv.fr, la ressource « 2e semestre 2025 » pointe vers le même fichier que le 1er semestre (constat du 21/10/2026).
