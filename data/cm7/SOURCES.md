# Données du CM 7

Téléchargées le **21/10/2026** par curl. À rafraîchir après le flash d'octobre (04/11/2026), après la réunion de la BCE des 28-29/10/2026, puis en janvier 2027.

## `taux_bce_2019_2026.csv`

- **Contenu** : taux directeurs de la BCE, en %, à chaque date de changement (date d'effet), du 18/09/2019 au 16/09/2026 (21 lignes).
  - `date` : date d'effet du nouveau taux (AAAA-MM-JJ) ;
  - `depot` : taux de la facilité de dépôt (série `FM.B.U2.EUR.4F.KR.DFR.LEV`) ;
  - `refinancement` : taux des opérations principales de refinancement (série `FM.B.U2.EUR.4F.KR.MRR_FR.LEV`).
- **Source** : BCE, Data Portal.
  - https://data-api.ecb.europa.eu/service/data/FM/B.U2.EUR.4F.KR.DFR.LEV?startPeriod=2019-01-01&format=csvdata (SHA-256 : `81dadedd9d988f060afdde115a2ef163cc24204e82323d4472f924e24ed21c18`)
  - https://data-api.ecb.europa.eu/service/data/FM/B.U2.EUR.4F.KR.MRR_FR.LEV?startPeriod=2019-01-01&format=csvdata (SHA-256 : `77ba4f26589d1a92884a47d432697b4b3d9297f93d78debafcbac560f7b965dd`)
  - Contrôle : tableau « Key ECB interest rates », https://www.ecb.europa.eu/stats/policy_and_exchange_rates/key_ecb_interest_rates/html/index.en.html
- **Traitement** : colonnes `TIME_PERIOD` et `OBS_VALUE` seulement ; les deux séries ont les mêmes dates. Le prolongement en escalier jusqu'au 21/10/2026 se fait dans `R/cm7.R`.

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
  - https://data-api.ecb.europa.eu/service/data/MIR/M.FR.B.A2C.AM.R.A.2250.EUR.N?startPeriod=2021-01&format=csvdata (SHA-256 : `a75c05e88b46b5f9455eb41fa3a2406578b99d79ac2d2b186cb90769e0a10e73`)
- **Traitement** : colonnes `TIME_PERIOD` et `OBS_VALUE` seulement, renommées `mois` et `taux` ; toutes les observations ont le statut `A` (normal).
- **Attention** : la série « entreprises » correspondante (`MIR.M.FR.B.A2I.AM.R.A.2240.EUR.N`) donne 1,40 % en juillet 2021 et 4,58 % en juillet 2023, et non les 1,08 % et 4,42 % que la page cite d'après Picault et Burietz (*The Conversation*, 04/10/2026), qui utilisent une autre mesure : ne pas mêler les deux.
- **Utilisé par** : `R/cm7.R` (`credit_habitat_cm7`, `graphe_credit_habitat()`), donc `cours/cm7.qmd`.
