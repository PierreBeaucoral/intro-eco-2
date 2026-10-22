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

## boites_aglp1_mensuel_2022_2026.csv

- **Contenu** : nombre de boîtes remboursées par l'ensemble des régimes, délivrées en pharmacie de ville, tous prescripteurs, par produit et par mois (en date de remboursement), de janvier 2022 à juin 2026, pour les produits de code ATC `A10BJ` (Bydureon, Byetta, Ozempic, Trulicity, Victoza, Liraglutide Sun, Wegovy) et Mounjaro. Une ligne par (mois, produit) : `mois` (AAAA-MM), `produit` (nom commercial, tel qu'écrit par Medic'AM), `boites`.
- **Colonnes lues** : colonne 3 (`PRODUIT`), colonne 6 (code ATC) et colonnes « Nombre de boites remboursées AAAA-MM » de la feuille `MedicAM_AAAAmois_tous_presc`.
- **Transformation pour la figure** (dans `R/cm3.R`, section 5 ter, pas dans le CSV) : somme mensuelle de tous les produits **sauf** Wegovy (`WEGOVY FLEXT`, `WEGOVY FLEXTOUCH`) et Mounjaro, présents seulement en juin 2026 (Wegovy remboursé dans l'obésité, Mounjaro dans l'obésité et le diabète de type 2, depuis le 15/06/2026) : le champ reste celui de `fig-boites`. Résultat : 682 314 boîtes en octobre 2023, 593 468 en septembre 2024, entre 556 910 et 682 314 par mois d'octobre 2023 à septembre 2024, 959 502 en juin 2026.
- **Source** : Assurance Maladie, Medic'AM, « par type de prescripteur », série mensuelle.
  - Fiche du jeu de données : https://www.data.gouv.fr/datasets/536999d3a3a729239d20533a
  - Fichiers : `https://www.assurance-maladie.ameli.fr/sites/default/files/` suivi de
    `2022-01-a-06_medic-am-par-type-de-prescripteur_serie-mensuelle_0.zip`, puis
    `AAAA-01-a-06_…_serie-mensuelle.zip` et `AAAA-07-a-12_…_serie-mensuelle.zip` de 2022-07 à 2025-07,
    `2026-01-a-06_medic-am-par-type-de-prescripteur_serie-mensuelle.zip` (xls daté du 27/08/2026).
  - Les fichiers `2025-07-a-12` et `2026-01-a-06` ne sont pas référencés sur data.gouv.fr ; ils ont été trouvés sur le site de l'Assurance Maladie en suivant le motif de nom de fichier (réponse HTTP 200).
- **Téléchargement** : 22/10/2026, par `curl` ; extraction par `data/cm3/extraire_medicam_mensuel.R` (à relancer depuis la racine du projet ; il reconstruit à l'identique ce CSV, `part_remboursee_aglp1_2025.csv` et `patients_ozempic_fr_us_2020_2024.csv`, vérifié par `cmp` le 22/10/2026). Les fichiers bruts (environ 210 Mo, non versionnés) sont conservés dans `_drafts/donnees/cm3/brut/` ; rapport `quality_reports/donnees/cm3-propositions.md`.
- **SHA-256 des fichiers bruts** (zip) :
  - `2022-01-a-06…_0.zip` : `8111bb88ac4d85f02043246f14b00c1976a2b832910acd7ed9bf885d7bbe8b0f`
  - `2022-07-a-12…` : `6ba708775c030eb95f6af4e81907d6f0698fd910c4eda27eac2b7501feba7f8b`
  - `2023-01-a-06…` : `55163d86cd6e9de1c429401e98727e75c3cd3b19a9391c13d5293ed39f1d40b7`
  - `2023-07-a-12…` : `24c1bc7f5967291b78a7f85a83707b4e26674a606f709c4302613abf8e2d1c05`
  - `2024-01-a-06…` : `97626aa9053f66237d7e252e0c2d87980e694bd6bab4f731195db658eab9d6a1`
  - `2024-07-a-12…` : `f733568a44462283dc6537e6954efc3e5543020d6d153ca204ec9ddc4e5e47c3`
  - `2025-01-a-06…` : `f4ebe04e8103ecb874ae9417514f0be222704471037493197498749933e00c03`
  - `2025-07-a-12…` : `163a6148487954db5f6da7be1413f6de02efcfc53cd8207005dd3e4b2732027d`
  - `2026-01-a-06…` : `e8d0f2c35b19035b6711e0394037f5424eb78b04384b1f07df5408e6b378d118`
- **Contrôle** : pour 2022, 2023 et 2024, la somme des 12 mois égale exactement, pour les 15 couples (année, produit), le nombre de boîtes de `boites_aglp1_2020_2024.csv` ; le total 2024 recalculé (7 488 154) est vérifié par `stopifnot()` dans `R/cm3.R`.
- **Limites** : les mêmes que `boites_aglp1_2020_2024.csv` (ville seulement ; boîtes remboursées seulement ; quantité vendue, pas demande). Séries mensuelles bruitées (jours ouvrés). Une présentation d'Ozempic de huit doses est autorisée depuis le 16/05/2025 : si elle est diffusée, le nombre de boîtes sous-estime la hausse du nombre de doses après mi-2025.
- **Utilisé par** : `R/cm3.R` (`graphe_boites_mois()`), `cours/cm3.qmd` (`fig-boites-mois`), `slides/cm3.qmd`.

## part_remboursee_aglp1_2025.csv

- **Contenu** : pour Ozempic, Trulicity et Victoza, année 2025 (somme des 12 mois) : `produit`, `boites`, `base_remboursement` (euros), `montant_rembourse` (euros). Pharmacies de ville, tous régimes, tous prescripteurs.
- **Colonnes lues** : « Base de remboursement AAAA-MM », « Nombre de boites remboursées AAAA-MM », « Montant remboursé AAAA-MM » (trois colonnes consécutives par mois, ordre vérifié par `stopifnot()` dans le script d'extraction), feuille `MedicAM_2025mois_tous_presc`.
- **Transformation pour la figure** (dans `R/cm3.R`, section 5 quater) : part payée par l'Assurance maladie = `montant_rembourse / base_remboursement`. Résultat : Ozempic 95,7 %, Trulicity 98,4 %, Victoza 98,2 %.
- **Source** : Assurance Maladie, Medic'AM mensuel, mêmes fichiers que `boites_aglp1_mensuel_2022_2026.csv` (`2025-01-a-06…` et `2025-07-a-12…`), https://www.data.gouv.fr/datasets/536999d3a3a729239d20533a
- **Téléchargement** : 22/10/2026 ; extraction par `data/cm3/extraire_medicam_mensuel.R`.
- **SHA-256 des fichiers bruts** : `2025-01-a-06…` : `f4ebe04e8103ecb874ae9417514f0be222704471037493197498749933e00c03` ; `2025-07-a-12…` : `163a6148487954db5f6da7be1413f6de02efcfc53cd8207005dd3e4b2732027d`.
- **Contrôle** : Open Medic 2025 (`NB_2025_atc5`, A10BJ06), publication distincte de l'Assurance Maladie : montant remboursé / base = 348 097 704,55 / 363 593 842,61 = 95,7 %, identique ; 4 677 641 boîtes contre 4 678 420 dans Medic'AM (écart de 0,02 %).
- **Limites** : l'onglet « lisez-moi » ne définit pas le « montant remboursé » ; on l'interprète comme la part payée par l'Assurance maladie obligatoire, le reste allant au patient ou à sa complémentaire. La source ne dit pas qui paie le reste, ni pourquoi le taux observé dépasse le taux de remboursement de 30 % d'Ozempic (BDPM).
- **Utilisé par** : `R/cm3.R` (`graphe_part_remboursee()`), `cours/cm3.qmd` (`fig-part-remboursee`), `slides/cm3.qmd`.

## patients_ozempic_fr_us_2020_2024.csv

- **Contenu** : nombre de patients sous Ozempic par an, 2020-2024. Une ligne par (année, pays) : `annee`, `pays` (« France », « États-Unis (Medicare) »), `patients`, `source`.
- **Colonnes lues** :
  - France : Open Medic, fichiers `NB_AAAA_atc5.CSV.gz` (séparateur `;`, décimales à virgule, latin-1), ligne `ATC5 = A10BJ06` (sémaglutide, Ozempic seul en France de 2020 à 2025), colonne `nbc` (nombre de consommants : patients ayant eu au moins un remboursement dans l'année) ;
  - États-Unis : CMS, `DSD_PTD_RY26_P04_V10_DY24_BGM.csv`, ligne `Brnd_Name = Ozempic`, `Mftr_Name = Overall`, colonnes `Tot_Benes_2020` à `Tot_Benes_2024` (bénéficiaires distincts).
- **Transformation pour la figure** (dans `R/cm3.R`, section 5 quinquies) : indice = 100 × patients de l'année / patients de 2020, par pays. Résultat 2024 : France 452,2 (× 4,5 : de 98 461 à 445 242) ; Medicare 724,1 (× 7,2 : de 269 663 à 1 952 637).
- **Sources** :
  - Assurance Maladie, Open Medic : https://www.data.gouv.fr/datasets/566e964188ee3875beaf0bf5 ; page de téléchargement `https://open-data-assurance-maladie.ameli.fr/medicaments/download2.php?Dir_Rep=AAAA_ATC5` (lien à jeton généré par la page) ;
  - CMS, *Medicare Part D Spending by Drug* (DY2024, mis à jour le 25/06/2026) : https://data.cms.gov/summary-statistics-on-use-and-payments/medicare-medicaid-spending-by-drug/medicare-part-d-spending-by-drug ; fichier https://data.cms.gov/sites/default/files/2026-06/98218f98-166c-4723-8438-c344a4ef96a6/DSD_PTD_RY26_P04_V10_DY24_BGM.csv
- **Téléchargement** : 22/10/2026 ; extraction par `data/cm3/extraire_medicam_mensuel.R` (fichiers bruts non versionnés dans `_drafts/donnees/cm3/brut/`).
- **SHA-256 des fichiers bruts** :
  - `NB_2020_atc5.CSV.gz` : `e5e87b94db0c4299437911b8eec696075bd8e0991a80a3146e5c81d692bf06f6`
  - `NB_2021_atc5.CSV.gz` : `4bbe801966642f5208748b906e01043be16ed33e1b391c0d5eedbaa52bbe1b42`
  - `NB_2022_atc5.CSV.gz` : `75cb6779a81b20ebda6e7c519a7e47f75d40c9beea83f6c7b2fde247de0266e5`
  - `NB_2023_atc5.CSV.gz` : `0d22ddf0dc8b93b602b1d65465b2c1520103b6915fd178df550ad27b88d414cc`
  - `NB_2024_atc5.CSV.gz` : `22caac0361f0112322a7d7f7e5bc11ef9d0c82311fc5612104fd4e76ce4758e9`
  - `DSD_PTD_RY26_P04_V10_DY24_BGM.csv` : `5dcc9d7bd7d7f88d9f6b24485c06d961ed6d70f9aa6deffa50dd47a6854c2a55`
- **Contrôle** : boîtes d'Ozempic d'Open Medic contre `boites_aglp1_2020_2024.csv` : 748 052 en 2020 (0,75 million) ; 3 642 446 contre 3 643 180 en 2024 (écart de 0,02 %). Le nombre d'ordonnances Medicare (`Tot_Clms`) suit la même tendance (de 1 204 138 en 2020 à 10 417 182 en 2024).
- **Limites** : champs différents (patients remboursés en ville en France, bénéficiaires de Medicare Part D aux États-Unis, une partie seulement des patients américains) : l'indice compare des croissances, pas des niveaux.
- **Utilisé par** : `R/cm3.R` (`graphe_patients_fr_us()`), `cours/cm3.qmd` (`fig-patients-fr-us`), `slides/cm3.qmd`.

## boites_wegovy_mounjaro_ozempic_mensuel.csv

- **Contenu** : nombre de boîtes remboursées par l'ensemble des régimes, délivrées en pharmacie de ville, tous prescripteurs, par mois (date de remboursement) et par produit : Wegovy (WEGOVY FLEXT et WEGOVY FLEXTOUCH, 6 présentations), Mounjaro (6 présentations), Ozempic (5 présentations). Colonnes : `mois` (AAAA-MM), `produit`, `boites`. Ozempic de 2025-07 à 2026-08 ; Wegovy et Mounjaro de 2026-01 à 2026-08 (lignes à 0 de janvier à mai).
- **Colonnes lues** : colonne 3 (`PRODUIT`, premier mot) et colonnes « Nombre de boites remboursées AAAA-MM » de la feuille `MedicAM_2025mois_tous_presc` ou `MedicAM_2026mois_tous_presc`, sommées par produit.
- **Transformation pour la figure** (dans `R/cm3.R`, section 5 septies) : Wegovy et Mounjaro seulement, janvier à août 2026, en milliers ; point placé au 15 du mois. Août 2026 : 20 416 boîtes de Wegovy, 70 996 de Mounjaro, 483 620 d'Ozempic (cité dans le fig-cap).
- **Source** : Assurance Maladie, Medic'AM, fichiers mensuels « par type de prescripteur ».
  - Page : https://www.assurance-maladie.ameli.fr/etudes-et-donnees/medicaments-type-prescripteur-medicam
  - Fichiers : `https://www.assurance-maladie.ameli.fr/sites/default/files/` suivi de
    `2025-07-a-12_medic-am-par-type-de-prescripteur_serie-mensuelle.zip`,
    `2026-01-a-06_medic-am-par-type-de-prescripteur_serie-mensuelle.zip`,
    `2026-07-a-08_medic-am-par-type-de-prescripteur_serie-mensuelle.zip` (édition d'octobre 2026, pas encore sur data.gouv.fr au 22/10/2026).
- **Téléchargement** : 22/10/2026, par `curl` ; extraction par `data/cm3/extraire_wegovy_mounjaro.R` (reconstruit à l'identique ce CSV et `prix_boite_wegovy.csv`, vérifié par `cmp` le 22/10/2026 ; fichiers bruts non versionnés dans `_drafts/donnees/cm3-wegovy/brut/` ; rapport `quality_reports/donnees/cm3-wegovy-mounjaro.md`).
- **SHA-256 des fichiers bruts** (zip) :
  - `2025-07-a-12…` : `163a6148487954db5f6da7be1413f6de02efcfc53cd8207005dd3e4b2732027d`
  - `2026-01-a-06…` : `e8d0f2c35b19035b6711e0394037f5424eb78b04384b1f07df5408e6b378d118`
  - `2026-07-a-08…` : `429f6f9104b50463ff6fcc67e77b3a829dac88a609a7bd3f3537a10c745e4b19`
- **Contrôle** : le fichier `2026-01-a-06` est identique (même SHA-256) à celui de `boites_aglp1_mensuel_2022_2026.csv`, et ses chiffres de juin 2026 pour Wegovy (4 825 + 408 = 5 233) et Mounjaro (14 488) y sont les mêmes.
- **Limites** :
  - boîtes **remboursées** seulement : les ventes sans remboursement (seules possibles avant le 15/06/2026 : Wegovy commercialisé depuis le 25/09/2024, Mounjaro depuis le 06/11/2024, selon la BDPM) n'y figurent pas. Le zéro de janvier à mai n'est donc pas une absence de ventes ;
  - juin ne compte que 15 jours de remboursement ;
  - Mounjaro est remboursable dans l'obésité **et** dans le diabète de type 2 depuis le 15/06/2026 (arrêté du 10/06/2026) : Medic'AM ne sépare pas les indications ;
  - pharmacies de ville seulement ; des boîtes, pas des patients.
- **Utilisé par** : `R/cm3.R` (`graphe_boites_wegovy()`), `cours/cm3.qmd` (`fig-boites-wegovy`, encadré méthode), `slides/cm3.qmd`.

## prix_boite_wegovy.csv

- **Contenu** : prix d'une boîte (un stylo), en euros TTC hors honoraire de dispensation, pour quatre présentations : Wegovy en accès précoce (indemnité maximale fixée par le laboratoire, 2022-2023), Wegovy 2,4 mg et Wegovy 0,25 à 1 mg (prix fixés à compter du 15/06/2026), Ozempic 1 mg (prix en vigueur). Colonnes : `presentation`, `prix`, `fixe_par`, `periode`, `source`.
- **Colonnes lues** : JO, colonne « PPTTC » des avis de prix ; BDPM, colonne 10 de `CIS_CIP_bdpm.txt` (prix sans honoraire) pour les CIP 3400930258620, 3400930258637, 3400930258644, 3400930260241, 3400930258668, 3400930292907 et 3400930151105 ; HAS, tableau « Indemnité maximale d'ATU », p. 12 de l'avis CEESP.
- **Transformation pour la figure** (dans `R/cm3.R`, section 5 sexies) : aucune (barres). Rapports cités dans le fig-cap : 431,41 / 195,10 = 2,2 et 431,41 / 146,91 = 2,9.
- **Sources** :
  - Légifrance, JORF n° 0123 du 28/05/2026, avis relatif aux prix, texte 101 (Wegovy) : https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000054144866 ; texte 103 (Mounjaro) : https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000054144870 ;
  - Base de données publique des médicaments, fichiers téléchargeables : https://base-donnees-publique.medicaments.gouv.fr/telechargement ;
  - HAS, Wegovy, avis économique de la CEESP du 15/07/2025 : https://www.has-sante.fr/upload/docs/application/pdf/2025-10/wegovy_15072025_avis_economique_ceesp_881.pdf
- **Téléchargement** : 22/10/2026. Légifrance refusant `curl` (erreur 403), les textes ont été lus dans un navigateur automatisé et leur texte affiché enregistré tel quel (`_drafts/donnees/cm3-wegovy/brut/jo/`, non versionné) ; extraction par `data/cm3/extraire_wegovy_mounjaro.R`.
- **SHA-256 des fichiers bruts** :
  - `CIS_CIP_bdpm.txt` : `1657d28a8a5bfce878cdba6a3d5b17f6a6e472eb2aedf64877fe7e3736886f29`
  - `wegovy_15072025_avis_economique_ceesp_881.pdf` : `39721d476f0b581f13267395be32c2ff238c7f66d380bcb459045bd97108950b`
  - `JORFTEXT000054144866_avis_prix_wegovy.txt` (capture) : `74a781f2c318d5bb187f4ae2c829242fe7a4dc1d22442bc8cd9821d5fa624dcd`
  - `JORFTEXT000054144870_avis_prix_mounjaro.txt` (capture) : `18b752962bdd250fe3c5b647af233e8b1e92e2e38382ea943c056fd9bd517743`
- **Contrôle** : prix du JO = prix de la BDPM pour 7 présentations, et bornes de Mounjaro (`stopifnot()` du script d'extraction) ; Ozempic 1 mg = 76,58 €, chiffre déjà cité dans la page.
- **Limites** : l'indemnité d'accès précoce n'est pas le prix en pharmacie de 2024-2026 : c'est le prix fixé par le laboratoire et payé par l'Assurance maladie pendant l'accès précoce (un seul prix par stylo, quel que soit le dosage). Aucune source officielle ne publie le prix pratiqué en pharmacie entre fin 2024 et le 15/06/2026. Les avis de prix du 28/05/2026 restent en vigueur : les arrêtés du 10/06/2026 (JORF n° 0136 du 12/06/2026) n'ont remplacé que les arrêtés d'inscription.
- **Utilisé par** : `R/cm3.R` (`graphe_prix_wegovy()`), `cours/cm3.qmd` (`fig-prix-wegovy`, encadré méthode), `slides/cm3.qmd`.

## Chiffres de l'encadré méthode cités sans CSV

Ces chiffres sont cités dans `cours/cm3.qmd` (encadré « Méthode », Wegovy et Mounjaro) et dans les notes de `slides/cm3.qmd`, sans être tracés : ils ne figurent dans aucun CSV et ne sont pas contrôlés par `R/cm3.R`.

- **Prix de Mounjaro, de 176,10 à 433,80 € la boîte** (prix public TTC hors honoraire, à compter du 15/06/2026) : 176,10 € pour 2,5 mg ; 433,80 € pour 12,5 mg et 15 mg. Source : Légifrance, JORF n° 0123 du 28/05/2026, avis relatif aux prix, texte 103, https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000054144870 (capture du 22/10/2026, SHA-256 ci-dessus). Contrôle : les deux bornes sont celles des 6 présentations de Mounjaro dans la BDPM du 22/10/2026 (`CIS_CIP_bdpm.txt`, colonne 10), vérifiées par `stopifnot()` dans `data/cm3/extraire_wegovy_mounjaro.R`.
- **Entre 1 et 2,1 millions de patients** remplissant les critères du remboursement (IMC ≥ 40, ou ≥ 35 avec une comorbidité) : « cette population élargie est estimée entre 1 000 000 et 2 100 000 patients », HAS, avis du collège n° 2025.0075/AC/SEM du 18/12/2025, p. 2-3, https://www.has-sante.fr/upload/docs/application/pdf/2026-01/ac.2025_0075_sem-ct_eval586_version-post-dc-18-12-2025_vd.pdf (fichier conservé dans `_drafts/donnees/cm3-wegovy/brut/has/ac_2025_0075_sem.pdf`).
- **Environ 40 000 chirurgies de l'obésité en 2022** : « environ 40 000 patients ont eu recours à la chirurgie bariatrique en 2022 », même avis de la HAS (remarque « A noter », après l'estimation de population).
- **Environ un million de personnes** (déclaration de la ministre chargée de la Santé) : Vidal, 28/05/2026, https://www.vidal.fr/actualites/37848-mounjaro-et-wegovy-couteront-une-centaine-de-millions-d-euros-aux-finances-publiques-en-annee-pleine-stephanie-rist.html
- Détail et citations : `quality_reports/donnees/cm3-wegovy-mounjaro.md`, question 4.
