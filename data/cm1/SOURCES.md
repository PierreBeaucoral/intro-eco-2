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

## Prix hors taxes (sans fichier, codés dans `R/cm1.R`)

- **Contenu** : prix hors taxes en France, en euros pour 1 000 litres, aux deux seules dates du tableau « Du baril à la pompe » de la page (23/02/2026 et 12/10/2026). Quatre valeurs, trop peu pour un CSV : elles sont écrites en dur dans `R/cm1.R`.
  - `ht_euro95` : Euro-super 95, colonne `FR_price_wo_tax_euro95` : 735,025 (23/02) et 1 153,317 (12/10) ;
  - `ht_gazole` : gazole, colonne `FR_price_wo_tax_diesel` : 767,267 (23/02) et 1 332,708 (12/10).
- **Source** : même fichier historique du *Weekly Oil Bulletin* que ci-dessus, feuille « Prices wo taxes ».
- **Lu le** : 21/10/2026 (Euro-super 95) ; relu le 22/10/2026 pour les deux carburants sur le fichier republié (SHA-256 `7e019a27fe2df6f324ec7a7c551b98142713fbee32aa7a030906101ffc22b2fd`), valeurs identiques.
- **Traitement** : arrondi à trois décimales. L'accise et la TVA se déduisent dans `R/cm1.R` (TVA = TTC ÷ 6 ; accise = TTC − hors taxes − TVA).
- **Utilisé par** : `R/cm1.R` (`decompose_pompe()` et ses `stopifnot()`), donc le tableau `@tbl-baril-pompe` de `cours/cm1.qmd` et la diapo correspondante de `slides/cm1.qmd`.

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

## `brut_et_ht_fr_2026.csv`

- **Contenu** : prix du pétrole brut et prix hors taxes des carburants en France, en euros par litre, une ligne par semaine, du 05/01/2026 au 12/10/2026 (41 semaines).
  - `date` : date du bulletin (lundi), au format AAAA-MM-JJ ;
  - `brut` : Brent converti en € par litre, soit Brent ($ par baril) ÷ (dollars pour 1 euro) ÷ 158,987 L par baril, en moyenne sur les jours de cotation communs aux deux séries entre le lundi précédent (J − 7) et la veille du bulletin (J − 1) ;
  - `essence_ht` : Euro-super 95 hors taxes (colonne `FR_price_wo_tax_euro95` ÷ 1 000) ;
  - `gazole_ht` : gazole hors taxes (colonne `FR_price_wo_tax_diesel` ÷ 1 000).
- **Sources** :
  - Commission européenne, *Weekly Oil Bulletin*, fichier historique, feuille « Prices wo taxes ». Page : https://energy.ec.europa.eu/data-and-analysis/weekly-oil-bulletin_en · Fichier : https://energy.ec.europa.eu/document/download/906e60ca-8b6a-44e7-8589-652854d2fd3f_en?filename=Weekly_Oil_Bulletin_Prices_History_maticni_4web.xlsx
  - EIA, « Europe Brent Spot Price FOB », série RBRTE. Page : https://www.eia.gov/dnav/pet/hist/LeafHandler.ashx?n=PET&s=RBRTE&f=D · Fichier : https://www.eia.gov/dnav/pet/hist_xls/RBRTEd.xls (feuille « Data 1 », dernière cotation au 20/10/2026).
  - BCE, taux de référence euro-dollar, série `EXR.D.USD.EUR.SP00.A`. Page : https://data.ecb.europa.eu/data/datasets/EXR · Requête : https://data-api.ecb.europa.eu/service/data/EXR/D.USD.EUR.SP00.A?startPeriod=2025-12-01&format=csvdata (du 01/12/2025 au 22/10/2026).
- **Téléchargé le** : 22/10/2026. SHA-256 des fichiers bruts :
  - xlsx du *Weekly Oil Bulletin* : `7e019a27fe2df6f324ec7a7c551b98142713fbee32aa7a030906101ffc22b2fd` (le fichier republié noté plus haut) ;
  - xls de l'EIA : `4c59848741cf3075eeef6e12a7527135643e4e333a4a8b0123514193bcf0d685` (identique à celui du 21/10/2026) ;
  - csv de la BCE : `7507420fdfda9aed2d1be73a24c479d94b63db333f4961fc747d9cd1df6a1824`.
- **Traitement** : `_drafts/donnees/cm1/preparation.R`, section B ; valeurs arrondies à trois décimales. Les écarts hors taxes − brut se calculent dans `R/cm1.R`.
- **Utilisé par** : `R/cm1.R` (`brut_ht_cm1`, `ecart_brut()`, `graphe_gazole_brut()`), donc `cours/cm1.qmd` (@fig-gazole-brut) et `slides/cm1.qmd`.
- **Attention** : la conversion en € par litre et la moyenne sur la semaine précédente sont des choix de l'auteur. L'écart hors taxes − brut n'est pas une marge de raffinage : il comprend aussi les biocarburants incorporés, le transport, les stocks et la marge de distribution, et un litre de brut ne donne pas un litre de gazole.

## `menages_exposes_territoire.csv`

- **Contenu** : 5 lignes (4 types d'intercommunalité et l'ensemble).
  - `territoire` : libellé Insee ;
  - `part_prix_2021` : part des ménages motorisés « particulièrement exposés » (plus d'un mois de revenu par an consacré au carburant) aux prix constatés en 2021, en % ;
  - `part_prix_2026` : même part si le litre avait coûté 2,0 € (essence) et 2,2 € (gazole), niveaux que l'Insee présente comme ceux du printemps 2026, à revenus et kilomètres de 2021, en %.
- **Source** : Insee, E. Lenzi, K. Masson, V. Mora, *Insee Première* n° 2125, 08/09/2026, tableau complémentaire 3 (colonnes 3 et 4). Champ : France hors Mayotte, ménages véhiculés en logement ordinaire, à revenu positif ; sources Insee (Fidéli 2022) et SDES (RSVERO).
  - Page : https://www.insee.fr/fr/statistiques/9037833
  - Fichier : https://www.insee.fr/fr/statistiques/fichier/9037833/IP2125.xlsx
- **Téléchargé le** : 22/10/2026 (SHA-256 du fichier xlsx : `970ec70329e14bc162795d5d86b2a88c5934f226f3cd6b8217e4db9925ee7000`).
- **Traitement** : `_drafts/donnees/cm1/preparation.R`, section C ; valeurs reprises telles quelles.
- **Utilisé par** : `R/cm1.R` (`menages_exposes_cm1`, `graphe_menages_exposes()`), donc `cours/cm1.qmd` (@fig-menages-exposes) et `slides/cm1.qmd`.
- **Attention** : c'est une simulation de l'Insee : seuls les prix changent entre les deux colonnes.

## `elasticite_par_consommation.csv`

- **Contenu** : 5 lignes.
  - `groupe` : quart de consommation passée de carburant (1er = plus petits consommateurs), plus « Ensemble » ;
  - `elasticite` : élasticité-prix moyenne de court terme ;
  - `borne_inf`, `borne_sup` : intervalle de confiance à 95 % (vides pour l'ensemble).
- **Source** : Insee, *Insee Analyses* n° 86, 06/07/2023 : figure 3c pour les quarts, tableau complémentaire 2 pour l'ensemble (« −0,40 (0,08) », avec variable instrumentale, même méthode que la figure 3c). Données : Crédit Mutuel Alliance Fédérale (paiements par carte, septembre 2021 à janvier 2023), calculs Insee.
  - Page : https://www.insee.fr/fr/statistiques/7645853
  - Fichier : https://www.insee.fr/fr/statistiques/fichier/7645853/donnees_insee_analyses_n86.xlsx
- **Téléchargé le** : 22/10/2026 (SHA-256 du fichier xlsx : `d97188116a7cceac0d338aaf3f11347afeea546ac13bf374c86ac22953066acb`).
- **Traitement** : `_drafts/donnees/cm1/preparation.R`, section D ; valeurs reprises telles quelles.
- **Utilisé par** : `R/cm1.R` (`elasticite_conso_cm1`, `graphe_elasticite_usage()`), donc `cours/cm1.qmd` (@fig-elasticite-usage) et `slides/cm1.qmd`.
- **Attention** : la ligne « Lecture » de la figure 3c dans le fichier de l'Insee parle du « quart des consommateurs aux plus hauts revenus », alors que la figure porte sur la consommation passée : coquille de l'Insee, copiée de la figure 3a. Le titre de la feuille et le tableau complémentaire 2 confirment qu'il s'agit des quarts de consommation.

## `prix_pompe_ttc_fr_2005_2026.csv`

- **Contenu** : prix à la pompe en France, toutes taxes comprises, moyennes nationales hebdomadaires, en euros courants par litre, du 03/01/2005 au 12/10/2026 (1 088 semaines).
  - `date` : date du bulletin, au format AAAA-MM-JJ ;
  - `essence` : Euro-super 95 (colonne `FR_price_with_tax_euro95` ÷ 1 000) ;
  - `gazole` : gazole (colonne `FR_price_with_tax_diesel` ÷ 1 000).
- **Source** : Commission européenne, *Weekly Oil Bulletin*, même fichier historique que `prix_pompe_fr_2026.csv` (version republiée), feuille « Prices with taxes ».
  - Page : https://energy.ec.europa.eu/data-and-analysis/weekly-oil-bulletin_en
  - Fichier : https://energy.ec.europa.eu/document/download/906e60ca-8b6a-44e7-8589-652854d2fd3f_en?filename=Weekly_Oil_Bulletin_Prices_History_maticni_4web.xlsx
- **Téléchargé le** : 22/10/2026 (SHA-256 du fichier xlsx : `7e019a27fe2df6f324ec7a7c551b98142713fbee32aa7a030906101ffc22b2fd`).
- **Traitement** : `_drafts/donnees/cm1/preparation.R`, section A ; lignes jusqu'au 12/10/2026 (date d'arrêt de la page), valeurs arrondies à trois décimales. Les 41 semaines de 2026 sont celles de `prix_pompe_fr_2026.csv`, à l'arrondi près (vérifié dans `R/cm1.R`).
- **Utilisé par** : `R/cm1.R` (`prix_pompe_long_cm1`, `record_gazole()`, `graphe_prix_pompe_long()`), donc `cours/cm1.qmd` (@fig-pompe-2005) et `slides/cm1.qmd`.
- **Attention** : euros courants, non corrigés de l'inflation ; 49 semaines manquent, autour du 1er janvier. Les chutes du gazole des semaines du 04/04/2022 (−0,23 €) et du 05/09/2022 (−0,17 €) tombent aux paliers de la remise à la pompe de 2022 ; la façon dont le bulletin intègre cette remise reste à confirmer dans sa note méthodologique.
