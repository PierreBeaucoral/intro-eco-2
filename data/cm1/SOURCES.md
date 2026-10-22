# Données du CM 1

## `prix_pompe_fr_2026.csv`

- **Contenu** : prix à la pompe en France, toutes taxes comprises, moyennes nationales hebdomadaires, en euros pour 1 000 litres. Une ligne par semaine, du 05/01/2026 au 12/10/2026 (41 semaines).
  - `date` : date de relevé du bulletin (lundi), au format AAAA-MM-JJ ;
  - `essence` : Euro-super 95 (colonne `FR_price_with_tax_euro95`) ;
  - `gazole` : gazole (colonne `FR_price_with_tax_diesel`).
- **Source** : Commission européenne, *Weekly Oil Bulletin*, fichier historique « Weekly_Oil_Bulletin_Prices_History_maticni_4web.xlsx », feuille « Prices with taxes ».
  - Page : https://energy.ec.europa.eu/data-and-analysis/weekly-oil-bulletin_en
  - Fichier : https://energy.ec.europa.eu/document/download/906e60ca-8b6a-44e7-8589-652854d2fd3f_en?filename=Weekly_Oil_Bulletin_Prices_History_maticni_4web.xlsx
- **Téléchargé le** : 21/10/2026 (SHA-256 du fichier xlsx : `03a95c7a42ab4dfc4dd2841b3995e7f7517de5b96f7ef31c1519e3a07ec12753`).
- **Mise à jour du fichier en ligne** (vérifiée le 21/10/2026) : le fichier xlsx a été republié depuis le téléchargement, avec une semaine de plus (19/10/2026 : Euro-super 95 à 2 228,88 €, gazole à 2 345,84 € pour 1 000 L ; nouveau SHA-256 commençant par `7e019a27`). Les 41 valeurs de 2026 jusqu'au 12/10 sont identiques à celles du CSV. Le cours garde l'arrêt au 12/10/2026, annoncé dans la page.
- **Traitement** : lignes de 2026 seulement, dates Excel converties, valeurs arrondies à deux décimales. Aucune autre transformation. La conversion en €/L (division par 1 000) se fait dans `R/cm1.R`.
- **Utilisé par** : `R/cm1.R` (`prix_pompe_cm1`, `graphe_prix_pompe()`), donc `cours/cm1.qmd` et `slides/cm1.qmd`.
- **Attention** : ce sont des moyennes pondérées, pas des relevés de station ; elles diffèrent un peu des chiffres journaliers de la presse ou du SDES.

## `brent_eia_2025_2026.csv`

- **Contenu** : prix du Brent au comptant (« Europe Brent Spot Price FOB »), en dollars par baril, une ligne par jour de cotation, du 02/01/2025 au 14/10/2026 (452 lignes).
  - `date` : jour de cotation, au format AAAA-MM-JJ ;
  - `brent` : prix en $ par baril.
- **Source** : U.S. Energy Information Administration (EIA), série RBRTE (identique à la série FRED DCOILBRENTEU).
  - Page : https://www.eia.gov/dnav/pet/hist/LeafHandler.ashx?n=PET&s=RBRTE&f=D
  - Fichier : https://www.eia.gov/dnav/pet/hist_xls/RBRTEd.xls (feuille « Data 1 »)
- **Téléchargé le** : 21/10/2026 (SHA-256 du fichier xls : `4c59848741cf3075eeef6e12a7527135643e4e333a4a8b0123514193bcf0d685`). Le fichier en ligne allait jusqu'au 20/10/2026.
- **Traitement** : lignes du 01/01/2025 au 14/10/2026 seulement (date d'arrêt « pétrole » de la page), valeurs arrondies à deux décimales. Aucune autre transformation. 2025 ne sert qu'à la moyenne annuelle (69,14 $), calculée dans `R/cm1.R`.
- **Utilisé par** : `R/cm1.R` (`brent_cm1`, `graphe_brent()`), donc `cours/cm1.qmd`.
- **Attention** : prix au comptant, plus haut que les contrats à terme cités par la presse (par exemple 102 $ pour décembre début octobre 2026).

## `livraisons_carburants_fr.csv`

- **Contenu** : livraisons intérieures brutes observées de carburants routiers en France, en milliers de tonnes, une ligne par mois, de janvier 2025 à juillet 2026 (19 mois ; août 2026 n'est pas encore publié).
  - `mois` : AAAA-MM ;
  - `gazole_routier` : code SIEC `O46711` (Road diesel) ;
  - `essence` : code SIEC `O4652` (Motor gasoline, part de biocarburant incorporée comprise).
- **Source** : Eurostat, jeu de données `nrg_cb_oilm` (« Oil and petroleum products supply, transformation and consumption - monthly data »), bilan `GID_OBS` (« Gross inland deliveries - observed »), unité `THS_T`, mise à jour Eurostat du 09/10/2026.
  - Page : https://ec.europa.eu/eurostat/databrowser/view/nrg_cb_oilm/default/table
  - Requête : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/nrg_cb_oilm?geo=FR&nrg_bal=GID_OBS&sinceTimePeriod=2024-01&lang=EN
- **Téléchargé le** : 21/10/2026 (SHA-256 de la réponse JSON : `055c78e55df25bce504a314d76607940fcda05399b3cd21959221a3e5ce22b21`).
- **Traitement** : extraction des deux codes SIEC, mois de 2025 et 2026 seulement, valeurs reprises telles quelles. La somme des deux colonnes, la conversion en millions de tonnes et les variations sur un an (−6,0 % en janvier-février 2026, −4,9 % de mars à juillet 2026) se calculent dans `R/cm1.R`.
- **Utilisé par** : `R/cm1.R` (`livraisons_cm1`, `var_livraisons()`, `graphe_livraisons()`), donc `cours/cm1.qmd`.
- **Attention** : ce sont des livraisons (sorties de dépôts vers les stations et les gros clients), pas des ventes à la pompe : elles comprennent les variations de stocks et dépendent du nombre de jours ouvrés du mois. Les chiffres récents peuvent être révisés.
