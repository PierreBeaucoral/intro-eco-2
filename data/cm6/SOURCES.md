# Données du CM 6

Toutes les données ont été téléchargées le **21/10/2026**. Utilisées par `R/cm6.R`, donc par `cours/cm6.qmd` et `slides/cm6.qmd`.

## `m3_credits_zone_euro.csv`

- **Contenu** : taux de croissance annuels (en %), zone euro (composition variable), données mensuelles corrigées des variations saisonnières, de janvier 2019 à août 2026 (92 mois ; août 2026 provisoire).
  - `mois` : AAAA-MM ;
  - `m3` : agrégat monétaire M3 (série `BSI.M.U2.Y.V.M30.X.I.U2.2300.Z01.A`) ;
  - `credits_menages` : prêts ajustés aux ménages accordés par les IFM (série `BSI.M.U2.Y.U.A20T.A.I.U2.2250.Z01.A`) ;
  - `credits_snf` : prêts ajustés aux sociétés non financières accordés par les IFM (série `BSI.M.U2.Y.U.A20T.A.I.U2.2240.Z01.A`).
- **Source** : BCE, Data Portal, API SDMX, format CSV, par exemple
  `https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M30.X.I.U2.2300.Z01.A?format=csvdata&startPeriod=2019-01`.
- **SHA-256 des fichiers bruts** : M3 `eb0f9c6dd7da59adf608887fb043a2777b0145c212d4cf07b079c42a19c357c8` ; ménages `bec4b0fb812184b280d8df086cfcbd56691c7eff816b4c4b67b175c80006b57f` ; SNF `4531929504663d414eafb635c7a0b680f9b66ad0d3aa1fdccefb7fcd78fd697a`.
- **Traitement** : fusion des trois séries par mois, valeurs arrondies à deux décimales. Aucune autre transformation.
- **Contrôle** : les derniers points (M3 3,5 %, ménages 3,1 %, SNF 4,2 % en août 2026) sont ceux du communiqué de la BCE « Monetary developments in the euro area: August 2026 », 25/09/2026, https://www.ecb.europa.eu/press/stats/md/html/ecb.md2608~406f8d243d.en.html.
- **Mise à jour** : chaque mois (communiqué vers le 25 du mois suivant).

## `encours_aout2026.csv`

- **Contenu** : encours en milliards d'euros (arrondis), zone euro, août 2026, corrigés des variations saisonnières : billets et pièces en circulation, M1, M2, M3.
- **Source** : BCE, Data Portal, séries `BSI.M.U2.Y.V.L10.X.1.U2.2300.Z01.E`, `BSI.M.U2.Y.V.M10.X.1.U2.2300.Z01.E`, `BSI.M.U2.Y.V.M20.X.1.U2.2300.Z01.E`, `BSI.M.U2.Y.V.M30.X.1.U2.2300.Z01.E` (même API, unité : millions d'euros, divisés par 1 000 et arrondis), par exemple
  `https://data-api.ecb.europa.eu/service/data/BSI/M.U2.Y.V.M20.X.1.U2.2300.Z01.E?format=csvdata&startPeriod=2026-06`. Valeurs brutes d'août 2026 (M€) : 1 616 848 ; 11 293 328 ; 16 447 405 ; 17 646 463. La ligne M2 a été ajoutée le 21/10/2026 (même téléchargement, même date).
- **Utilisé pour** : la part des billets et pièces dans M3 (1 617 ÷ 17 646 ≈ 9 %) et la figure de la composition de M3 (`graphe_composition_m3()`), qui calcule par différence : dépôts à vue = M1 − billets et pièces (9 676) ; dépôts d'épargne à court terme = M2 − M1 (5 154) ; titres à court terme = M3 − M2 (1 199). Parts arrondies de M3 : 9 %, 55 %, 29 %, 7 %.

## `svb_table1.csv`

- **Contenu** : quatre lignes de la Table 1 « Peer comparison, 2022:Q4 » (en %) : SVB Financial Group et moyenne pondérée des grandes banques américaines (plus de 100 Md$ d'actifs, hors LISCC). Libellés traduits.
- **Source** : Board of Governors of the Federal Reserve System, *Review of the Federal Reserve's Supervision and Regulation of Silicon Valley Bank*, 28/04/2023, p. 23, https://www.federalreserve.gov/publications/files/svb-review-20230428.pdf (PDF ouvert et texte extrait le 21/10/2026).
- **Traitement** : saisie à la main. Lignes non reprises : dépôts en % du passif (89 et 82), ratio de fonds propres CET1 (12 et 10).
