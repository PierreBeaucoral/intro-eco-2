# Données du CM 7

Téléchargées le **21/10/2026** par curl (les quatre derniers fichiers le 22/10/2026). À rafraîchir après le flash d'octobre (04/11/2026), après la réunion de la BCE des 28-29/10/2026, puis en janvier 2027.

## `taux_bce_2019_2026.csv`

- **Contenu** : taux directeurs de la BCE, en %, à chaque date de changement (date d'effet), du 18/09/2019 au 16/09/2026 (21 lignes).
  - `date` : date d'effet du nouveau taux (AAAA-MM-JJ) ;
  - `depot` : taux de la facilité de dépôt (série `FM.B.U2.EUR.4F.KR.DFR.LEV`) ;
  - `refinancement` : taux des opérations principales de refinancement (série `FM.B.U2.EUR.4F.KR.MRR_FR.LEV`) ;
  - `pret_marginal` : taux de la facilité de prêt marginal (série `FM.B.U2.EUR.4F.KR.MLFR.LEV`, ajoutée le 22/10/2026 : 2,90 % depuis le 16/09/2026).
- **Source** : BCE, Data Portal.
  - https://data-api.ecb.europa.eu/service/data/FM/B.U2.EUR.4F.KR.DFR.LEV?startPeriod=2019-01-01&format=csvdata (SHA-256 : `81dadedd9d988f060afdde115a2ef163cc24204e82323d4472f924e24ed21c18`)
  - https://data-api.ecb.europa.eu/service/data/FM/B.U2.EUR.4F.KR.MRR_FR.LEV?startPeriod=2019-01-01&format=csvdata (SHA-256 : `77ba4f26589d1a92884a47d432697b4b3d9297f93d78debafcbac560f7b965dd`)
  - https://data-api.ecb.europa.eu/service/data/FM/B.U2.EUR.4F.KR.MLFR.LEV?startPeriod=2019-01-01&format=csvdata (téléchargée le 22/10/2026 ; SHA-256 : `af37fa7a35d8506446afd36381de8c34fa2ba9cc68e7b8aaeab7ebdb0bb60ddd`)
  - Contrôle : tableau « Key ECB interest rates », https://www.ecb.europa.eu/stats/policy_and_exchange_rates/key_ecb_interest_rates/html/index.en.html
- **Traitement** : colonnes `TIME_PERIOD` et `OBS_VALUE` seulement ; les trois séries ont les mêmes 21 dates. Le prolongement en escalier jusqu'au 21/10/2026 se fait dans `R/cm7.R`.

## `ipch_2021_2026.csv`

- **Contenu** : inflation mesurée par l'IPCH, taux de variation sur un an (en %), chaque mois de janvier 2021 à septembre 2026 (format long, 621 lignes).
  - `mois` : AAAA-MM ;
  - `zone` : `EA` (zone euro à composition changeante ; 21 pays depuis l'entrée de la Bulgarie le 01/01/2026), `DE`, `FR`, `ES`, `IT` ;
  - `serie` : `ensemble` (indice total, 5 zones) ; `energie`, `hors_energie`, `alimentation` (alimentation, alcool et tabac) et `hors_energie_alimentation` (indice hors énergie, alimentation, alcool et tabac), zone euro seulement ;
  - `inflation` : en %.
- **Source** : Eurostat, jeu de données `prc_hicp_minr` (« HICP - ECOICOP ver.2 - indices and rates of change, monthly data »), unité `RCH_A`, mis à jour le 16/10/2026. Codes `coicop18` : `TOTAL`, `NRG`, `TOT_X_NRG`, `FOOD`, `TOT_X_NRG_FOOD`.
  - https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hicp_minr?geo=EA&geo=DE&geo=FR&geo=ES&geo=IT&coicop18=TOTAL&unit=RCH_A&sinceTimePeriod=2021-01 (SHA-256 de la réponse JSON : `fec5a455ffd12d1fc7b6ec007e14a692f418f7a6c61b779f6d051ca0273f2bd8`)
  - https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hicp_minr?geo=EA&coicop18=NRG&coicop18=TOT_X_NRG&unit=RCH_A&sinceTimePeriod=2021-01 (SHA-256 : `afa0fea9a3ea79d3d53bb00bbc2abe4258bd552e423bcc9453b1f06e480f5084`)
  - https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hicp_minr?geo=EA&coicop18=TOT_X_NRG_FOOD&coicop18=FOOD&unit=RCH_A&sinceTimePeriod=2021-01 (SHA-256 : `a3d5dc4f13b1e34faf9d0e911ef732ce910be661cabf2fadbd443aa987c6f7b9` ; ajouté le 21/10/2026 : alimentation 13,1 % et hors énergie et alimentation 5,0 % en octobre 2022 ; 1,3 % et 2,5 % en septembre 2026)
- **Pourquoi ce jeu et pas `prc_hicp_manr`** : l'ancien jeu (COICOP 1) est arrêté à décembre 2025 (« LAST UPDATE 06/02/26 »). Le nouveau couvre 2021-2026 sans trou et redonne les chiffres du communiqué Eurostat du 16/10/2026 (zone euro 3,8 %, Allemagne 3,3 %, France 3,4 %, Espagne 5,0 %, Italie 4,2 % en septembre 2026 ; énergie 18,9 %, hors énergie 2,3 %) et les pics de 2022-2023 (zone euro 10,6 % et Allemagne 11,6 % en octobre 2022 ; France 7,3 % en février 2023).
- **Attention** : de petits écarts avec l'ancien jeu sont possibles (décembre 2025, zone euro : 2,0 % ici, 1,9 % dans `prc_hicp_manr`). Le communiqué du 16/10/2026 sert de contrôle.
- **Utilisé par** : `R/cm7.R` (`ipch_cm7`, `graphe_taux_inflation()`, `graphe_inflation_diffusion()`), donc `cours/cm7.qmd` et `slides/cm7.qmd`.

## `taux_credit_habitat_fr_2021_2026.csv`

- **Contenu** : coût moyen des nouveaux crédits à l'habitat accordés aux ménages en France, en % par an, chaque mois de janvier 2021 à août 2026 (dernier mois publié au 21/10/2026 ; 68 lignes).
  - `mois` : AAAA-MM ;
  - `taux` : en %.
- **Source** : BCE, Data Portal, statistiques des taux d'intérêt des institutions financières monétaires (MIR), série `MIR.M.FR.B.A2C.AM.R.A.2250.EUR.N` (« Cost of borrowing for households for house purchase », France, nouveaux crédits, taux annualisé convenu / taux effectif au sens étroit). Téléchargée le **21/10/2026**.
  - https://data-api.ecb.europa.eu/service/data/MIR/M.FR.B.A2C.AM.R.A.2250.EUR.N?startPeriod=2021-01&format=csvdata (SHA-256 du fichier brut le 21/10/2026 : `a75c05e88b46b5f9455eb41fa3a2406578b99d79ac2d2b186cb90769e0a10e73`). L'empreinte porte sur tout le CSV, dont les colonnes de métadonnées peuvent changer d'un téléchargement à l'autre : le 22/10/2026, elle vaut `5d30186f9230f07c6639caac35d9c215429e5096d38e3762d79e8302e227116c`, mais les 68 couples `TIME_PERIOD`, `OBS_VALUE` sont identiques à ceux du fichier de données. Le contrôle qui compte est la comparaison de ces deux colonnes.
- **Traitement** : colonnes `TIME_PERIOD` et `OBS_VALUE` seulement, renommées `mois` et `taux` ; toutes les observations ont le statut `A` (normal).
- **Attention** : la série « entreprises » correspondante (`MIR.M.FR.B.A2I.AM.R.A.2240.EUR.N`) donne 1,40 % en juillet 2021 et 4,58 % en juillet 2023, et non les 1,08 % et 4,42 % que la page cite d'après Picault et Burietz (*The Conversation*, 04/10/2026), qui utilisent une autre mesure : ne pas mêler les deux.
- **Utilisé par** : `R/cm7.R` (`credit_habitat_cm7`, `graphe_credit_habitat()`), donc `cours/cm7.qmd`.

## `prix_petrole_gaz_2021_2026.csv`

- **Contenu** : prix mensuels moyens du pétrole et du gaz européen, de janvier 2021 à septembre 2026 (69 lignes).
  - `mois` : AAAA-MM ;
  - `brent_usd_baril` : pétrole Brent, en dollars par baril ;
  - `gaz_usd_mmbtu` : gaz naturel, Europe (TTF), en dollars par million de BTU ;
  - `usd_par_eur` : dollars pour un euro, moyenne du mois ;
  - `brent_eur_baril` = `brent_usd_baril / usd_par_eur`, arrondi à 0,1 ;
  - `gaz_eur_mwh` = `gaz_usd_mmbtu / 0,293071 / usd_par_eur` (1 MMBtu = 0,293071 MWh), arrondi à 0,1.
- **Sources** (téléchargées le **22/10/2026** par curl) :
  - Banque mondiale, *Commodity Price Data (Pink Sheet)*, « Monthly prices », mis à jour le 02/10/2026 ; page : https://www.worldbank.org/en/research/commodity-markets ; fichier : https://thedocs.worldbank.org/en/doc/74e8be41ceb20fa0da750cda2f6b9e4e-0050012026/related/CMO-Historical-Data-Monthly.xlsx (SHA-256 : `ea1c350827878ea3bbe30e3cda16a13fd3bd5b409b8458940dc94a36b5a33154`). Séries « Crude oil, Brent » ($/bbl) et « Natural gas, Europe » ($/mmbtu) ; onglet « Description » : gaz Europe « from April 2015, Netherlands Title Transfer Facility (TTF) ».
  - BCE, Data Portal, taux de change `EXR.M.USD.EUR.SP00.A` (moyenne mensuelle) : https://data-api.ecb.europa.eu/service/data/EXR/M.USD.EUR.SP00.A?startPeriod=2021-01&format=csvdata (SHA-256 : `f234cbd022945c6821bbae9cff53825f13f8ddfe9695b23396bd827a75ad676c`).
  - Contrôle (Brent) : EIA, « Europe Brent Spot Price FOB », série `RBRTE`, https://www.eia.gov/dnav/pet/hist_xls/RBRTEm.xls (SHA-256 : `5881bc058aa7d641dc41ef254f6991e101c952e112284f0eb5a994514b401cb7`) : 122,71 $ (juin 2022), 117,29 $ (avril 2026), 114,16 $ (septembre 2026), contre 120,1 $, 120,4 $ et 116,8 $ ici ; écarts de 1 à 3 % (fournisseurs de cotation différents), même profil.
  - Contrôle (gaz et conversion) : Insee, *Note de conjoncture*, « Énergie et matières premières », 24/03/2026 (SHA-256 du PDF : `2e027b3bb8a3045c0b198786b9b77831301bfdeae19f01e7ebda0643e27a05d9`) : « 46,8 €/MWh au premier trimestre » 2025, retrouvé ici.
- **Traitement** : colonnes Brent et gaz de l'onglet « Monthly Prices », fusionnées par mois avec le taux de change, par `data/cm7/preparer_2026-10-22.R` (à relancer depuis la racine du projet ; vérifié le 22/10/2026 : sortie identique octet pour octet au CSV).
- **Attention** : une édition antérieure du fichier (`…-0050012025/…`) s'arrête à décembre 2025 ; c'est l'édition `0050012026`, liée depuis la page de la Banque mondiale, qui couvre 2026. Ce sont des prix de gros, pas des prix payés par les ménages. À rafraîchir à la mise à jour de début novembre du Pink Sheet.
- **Utilisé par** : `R/cm7.R` (`petrole_gaz_cm7`, `graphe_petrole_gaz()`), donc `cours/cm7.qmd` et `slides/cm7.qmd`.

## `salaires_negocies_inflation_2021_2026.csv`

- **Contenu** : par trimestre, du premier trimestre 2021 au deuxième trimestre 2026 (22 lignes).
  - `trimestre` : AAAA-QN ;
  - `salaires_negocies` : croissance sur un an de l'indicateur des salaires négociés, zone euro, en % ;
  - `inflation` : moyenne des trois taux mensuels d'inflation IPCH sur un an du trimestre, zone euro, en %, arrondie à 0,01.
- **Sources** (téléchargées le **22/10/2026** par curl) :
  - BCE, Data Portal, `INW.Q.U2.N.INWR.000000.4F0.GY.IX` (« Negotiated wages », zone euro à composition changeante, taux de variation annuel, ni CVS ni CJO) : https://data-api.ecb.europa.eu/service/data/INW/Q.U2.N.INWR.000000.4F0.GY.IX?startPeriod=2019-Q1&format=csvdata (SHA-256 : `30d45e793b8718596c48e4da6dc850729d353ba8353357f8d2ec8bc9c981cd7f`) ; toutes les observations au statut `A`.
  - Eurostat, `prc_hicp_minr` (`EA`, `TOTAL`, `RCH_A`) : https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hicp_minr?geo=EA&coicop18=TOTAL&unit=RCH_A&sinceTimePeriod=2021-01 (SHA-256 : `5ccce9a562fd2e6263889e53a3e5140f70d6260a780258842e0dcbe5a50f90ca`) ; les 69 mois sont identiques à ceux de `ipch_2021_2026.csv`.
  - Contrôle : BCE, déclaration de politique monétaire du 10/09/2026, « Wages do not show a material response to the energy shock at this stage » (SHA-256 de la page enregistrée : `ed871e79278e7de6c99431bfa392b68fa4cb8f48f5464d35af45f08cf0334ff5`).
- **Traitement** : seuls les trimestres complets (trois mois d'IPCH) sont gardés ; le troisième trimestre 2026 manque côté salaires ; construit par `data/cm7/preparer_2026-10-22.R` (à relancer depuis la racine du projet ; vérifié le 22/10/2026 : sortie identique octet pour octet au CSV). `R/cm7.R` recoupe la colonne `inflation` avec la moyenne trimestrielle de `ipch_2021_2026.csv`.
- **Attention** : la série des salaires négociés est heurtée en 2024-2025 (primes ponctuelles, notamment en Allemagne). À rafraîchir à la publication du troisième trimestre 2026.
- **Utilisé par** : `R/cm7.R` (`salaires_cm7`, `graphe_salaires_inflation()`), donc `cours/cm7.qmd` et `slides/cm7.qmd`.

## `anticipations_inflation_2022_2026.csv`

- **Contenu** : anticipations d'inflation dans la zone euro, format long (124 lignes).
  - `date` : AAAA-MM-15 (mois de l'enquête ; pour le SPF, premier mois du trimestre, quand le questionnaire est envoyé) ;
  - `serie` : `menages_12_mois`, `menages_3_ans` (enquête sur les anticipations des consommateurs, CES, médiane pondérée, d'avril 2022 à août 2026) ; `previsionnistes_long_terme` (enquête auprès des prévisionnistes professionnels, SPF, moyenne des prévisions ponctuelles à cinq ans, arrondie à 0,01, du deuxième trimestre 2022 au troisième trimestre 2026) ;
  - `valeur` : en %.
- **Sources** (téléchargées le **22/10/2026** par curl) :
  - BCE, Data Portal, Consumer Expectations Survey, `CES.M.Z18.ALL.T.C1120.NUM_VAR.WM` (12 mois) et `CES.M.Z18.ALL.T.C1220.NUM_VAR.WM` (3 ans) : https://data-api.ecb.europa.eu/service/data/CES/M.Z18.ALL.T.C1120+C1220.NUM_VAR.WM?startPeriod=2020-01&format=csvdata (SHA-256 : `28acf677263d2728ef09e6cd4961a67992ebfb93fb49354ab1260e2fbfbe2846`). `Z18` = 11 pays (DE, IT, ES, FR, NL, BE, FI, AT, GR, PT, IE) ; codes vérifiés dans la liste `CL_CES_VARIABLE`.
  - BCE, Data Portal, Survey of Professional Forecasters, `SPF.Q.U2.HICP.POINT.LT.Q.AVG` : https://data-api.ecb.europa.eu/service/data/SPF/Q.U2.HICP.POINT.LT.Q.AVG?startPeriod=2019-Q1&format=csvdata (SHA-256 : `2b9130df66b52933d53ac77f23172c80bf15e968a5468ec5b494bf356b49f6ae`).
  - Contrôle : BCE, déclaration de politique monétaire du 10/09/2026, « most measures of longer-term inflation expectations stand at around 2 per cent » (SHA-256 de la page enregistrée : `ed871e79278e7de6c99431bfa392b68fa4cb8f48f5464d35af45f08cf0334ff5`).
- **Traitement** : CES : colonnes `TIME_PERIOD`, `CES_VARIABLE` et `OBS_VALUE` ; SPF : à partir du deuxième trimestre 2022, date au 15 du premier mois du trimestre ; construit par `data/cm7/preparer_2026-10-22.R` (à relancer depuis la racine du projet ; vérifié le 22/10/2026 : sortie identique octet pour octet au CSV).
- **Attention** : la série CES zone euro commence en avril 2022 ; les horizons SPF à 12 et 24 mois glissants ne sont pas publiés dans le Data Portal (erreur 404). Les ménages attendent 2,9 % à trois ans en août 2026 : l'ancrage « autour de 2 % » de la BCE ne vaut pas pour eux. À rafraîchir après le SPF du quatrième trimestre 2026 et la CES de septembre.
- **Utilisé par** : `R/cm7.R` (`anticipations_cm7`, `anticipation_mois()`, `graphe_anticipations()`), donc `cours/cm7.qmd` et `slides/cm7.qmd`.

## `inflation_pays_2026-09.csv`

- **Contenu** : inflation IPCH sur un an en septembre 2026 dans les 21 pays de la zone euro et dans la zone euro (22 lignes), triée par inflation croissante.
  - `geo` : code Eurostat (`EL` pour la Grèce ; `EA` pour la zone euro à composition changeante, 21 pays depuis le 01/01/2026) ;
  - `pays` : nom en français ;
  - `inflation` : en % ;
  - `taux_depot` : 2,50 %, taux de la facilité de dépôt en vigueur depuis le 16/09/2026 (repris de `taux_bce_2019_2026.csv`) ;
  - `taux_reel` : `taux_depot − inflation`, arrondi à 0,1 (taux réel ex post).
- **Source** : Eurostat, jeu de données `prc_hicp_minr`, unité `RCH_A`, `coicop18=TOTAL`, mis à jour le 16/10/2026, téléchargé le **22/10/2026** par curl.
  - https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hicp_minr?coicop18=TOTAL&unit=RCH_A&time=2026-09&geo=EA&geo=AT&geo=BE&geo=BG&geo=CY&geo=DE&geo=EE&geo=EL&geo=ES&geo=FI&geo=FR&geo=HR&geo=IE&geo=IT&geo=LT&geo=LU&geo=LV&geo=MT&geo=NL&geo=PT&geo=SI&geo=SK (SHA-256 de la réponse JSON : `6238da22e87c93706364a8b3adee9859d622d6fdb16b856e092e50c9fb9653c1`)
  - Contrôle : communiqué Eurostat du 16/10/2026, https://ec.europa.eu/eurostat/web/products-euro-indicators/w/2-16102026-ap ; zone euro, Allemagne, France, Espagne et Italie identiques à `ipch_2021_2026.csv` (vérifié dans `R/cm7.R`).
- **Traitement** : lecture JSON-stat ; aucune valeur signalée provisoire ou estimée (`status` vide) ; construit par `data/cm7/preparer_2026-10-22.R` (à relancer depuis la racine du projet ; vérifié le 22/10/2026 : sortie identique octet pour octet au CSV).
- **Attention** : à rafraîchir après l'IPCH d'octobre (flash le 04/11/2026, chiffres définitifs mi-novembre).
- **Utilisé par** : `R/cm7.R` (`inflation_pays_cm7`, `graphe_inflation_pays()`), donc `cours/cm7.qmd` et `slides/cm7.qmd`.
