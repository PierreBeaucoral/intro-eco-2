# Données du CM 6

Données téléchargées le **21/10/2026**, sauf les quatre dernières fiches (**22/10/2026**). Utilisées par `R/cm6.R`, donc par `cours/cm6.qmd` et `slides/cm6.qmd`.

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

## `bce_titres_reserves.csv`

- **Contenu** : encours en milliards d'euros, Eurosystème, dernière situation hebdomadaire de chaque mois (vendredi), de janvier 2007 au 16/10/2026 (238 lignes ; octobre 2026 = situation au 16/10).
  - `date` : AAAA-MM-JJ, vendredi de la semaine ISO de la situation ;
  - `titres_md` : titres détenus à des fins de politique monétaire (actif, poste 7.1, série `ILM.W.U2.C.A070100.U2.EUR`) ; vide avant juillet 2009 (poste inexistant) ;
  - `reserves_md` : comptes courants des établissements de crédit (passif 2.1, `ILM.W.U2.C.L020100.U2.EUR`) + facilité de dépôt (passif 2.2, `ILM.W.U2.C.L020200.U2.EUR`) ;
  - `billets_md` : billets en circulation (passif 1, `ILM.W.U2.C.L010000.Z5.EUR`).
- **Source** : BCE, Data Portal, jeu ILM (bilan hebdomadaire consolidé de l'Eurosystème), API SDMX, format CSV, par exemple
  `https://data-api.ecb.europa.eu/service/data/ILM/W.U2.C.A070100.U2.EUR?format=csvdata&startPeriod=2007-01-01` (même forme pour les trois autres clés).
- **Téléchargé le** : 22/10/2026.
- **SHA-256 des fichiers bruts** : A070100 `8841f230a896a5f21e05f0d8b60e07e8bbfe7ae55b3a3bf98342591f826f938e` ; L010000 `08e3c2e843364091198715317bcff183594bf7f6e4668459d0191a06da911a17` ; L020100 `3c5b94f761e2f81fa32ce4e23eb68cfe19fdb58e488f66cbdb18be746cac533e` ; L020200 `54429d1a4e7a23955ec9c01dcc704bd2f7d665a9db5e2b719e7f357ddaa7f6ad`.
- **Traitement** : semaine ISO convertie en date du vendredi ; dernière semaine de chaque mois ; millions d'euros divisés par 1 000, arrondis à 0,1 ; réserves = somme des deux postes du passif. Toutes les observations ont le statut `A`. Fichiers bruts et script de préparation : `_drafts/donnees/cm6/` (`brut/`, `preparation.R`).
- **Contrôle** : la situation au 16/10/2026 redonne exactement le communiqué « Consolidated financial statement of the Eurosystem as at 16 October 2026 » (20/10/2026), https://www.ecb.europa.eu/press/annual-reports-financial-statements/wfs/2026/html/ecb.fst261020.en.html : billets 1 632 509 M€, comptes courants 328 775 M€, facilité de dépôt 1 962 190 M€, titres de politique monétaire 3 310 940 M€.
- **Attention** : les billets du bilan (1 632,5 Md€ au 16/10/2026, tous les billets émis, données brutes) ne sont pas les « billets et pièces » de M3 (1 617 Md€ en août 2026, détenus par les résidents non bancaires, données corrigées) de `encours_aout2026.csv`.
- **Mise à jour** : chaque semaine (communiqué le mardi).
- **Utilisé par** : `graphe_bce_titres()` (figure `fig-bce-titres`).

## `depots_banques_us_2023.csv`

- **Contenu** : dépôts en milliards de dollars, données corrigées des variations saisonnières, chaque mercredi du 04/01/2023 au 28/06/2023 (26 lignes).
  - `date` : AAAA-MM-JJ (mercredi) ;
  - `grandes_md_usd` : 25 plus grandes banques commerciales de droit américain, classées par actif intérieur au dernier rapport trimestriel (`DPSLCBW027SBOG`) ;
  - `petites_md_usd` : toutes les autres banques commerciales de droit américain (`DPSSCBW027SBOG`).
- **Source** : Board of Governors of the Federal Reserve System, statistique H.8 « Assets and Liabilities of Commercial Banks in the United States », via FRED (Federal Reserve Bank of St. Louis) : `https://fred.stlouisfed.org/graph/fredgraph.csv?id=DPSSCBW027SBOG&cosd=2022-07-01&coed=2023-12-31` (même forme pour `DPSLCBW027SBOG`). Pages : https://www.federalreserve.gov/releases/h8/current/ et https://fred.stlouisfed.org/series/DPSSCBW027SBOG.
- **Téléchargé le** : 22/10/2026.
- **SHA-256 des fichiers bruts** : grandes `172f16727f4b28f0979120b6d59e5e3e9313d1c05625ebeecc714e86c7b16dca` ; petites `f2464d7a4c3734d0d660ba18d07f32b1d40ebdd85b35bf969735bec0065bc006`.
- **Traitement** : fusion par date, restriction à janvier-juin 2023, arrondi à 0,1. L'indice (base 100 = 08/03/2023) est calculé dans `R/cm6.R`.
- **Contrôle** : le communiqué H.8 du 24/03/2023 (https://www.federalreserve.gov/releases/h8/20230324/, tables 6 et 8, ligne « Deposits », CVS) donnait, pour la semaine du 15/03/2023 : petites banques 5 575,9 → 5 455,9 Md$ (−2,2 %), grandes 10 673,4 → 10 740,0 Md$ (+0,6 %). Le millésime actuel donne −149,3 Md$ (−2,9 %) et +53,5 Md$ (+0,5 %) : niveaux révisés (calage sur les comptes trimestriels, reclassement annuel des 25 plus grandes), même sens et même ordre de grandeur.
- **Attention (classement)** : selon l'avis aux utilisateurs du communiqué H.8 du 31/03/2023 (https://www.federalreserve.gov/releases/h8/20230331/), les données de la semaine du 15/03/2023 ont été révisées pour changer la façon dont les banques-relais de la FDIC (Silicon Valley Bridge Bank, Signature Bridge Bank) sont intégrées aux données des petites banques : les banques-relais sont donc comptées parmi les « autres banques ». Le groupe où figuraient SVB et Signature avant leur fermeture n'est pas vérifié ; une partie de la baisse des « autres banques » peut venir des deux banques en faillite elles-mêmes.
- **Mise à jour** : chaque semaine (le vendredi) ; la période 2023 reste révisable.
- **Utilisé par** : `graphe_depots_us()` (figure `fig-depots-us`).

## `findex_mobile_money_regions.csv`

- **Contenu** : part des adultes de 15 ans et plus ayant un compte de mobile money, en %, années d'enquête 2014, 2017, 2021, 2024 (10 lignes).
  - `zone` : `SSA` (Afrique subsaharienne hors pays à revenu élevé), `WLD` (monde), `KOR` (Corée) et `BRA` (Brésil), ces deux derniers pour 2024 seulement (contrôle de la légende, non tracés) ;
  - `annee` ;
  - `part_adultes_pct` : arrondi à 0,1.
- **Source** : Banque mondiale, Global Findex Database 2025 (source 28 de l'API, mise à jour du 06/10/2025), indicateur `mobileaccount.t.d` « Mobile money account (% age 15+) », API v2 : `https://api.worldbank.org/v2/country/WLD;SSA;LMY;LIC;SAS;LAC/indicator/mobileaccount.t.d?source=28&format=json&per_page=1000`. Page : https://www.worldbank.org/en/publication/globalfindex.
- **Téléchargé le** : 22/10/2026.
- **SHA-256 du fichier brut** : `842d10d4cdb620932b0fd4051d461408cb163f677c99724665a1a1e1f94aebcc`.
- **Traitement** : zones `SSA` et `WLD`, valeurs non vides, arrondi à 0,1. Ajout le 22/10/2026 de `KOR` et `BRA` (2024) : même indicateur, `https://api.worldbank.org/v2/country/KOR;BRA/indicator/mobileaccount.t.d?source=28&format=json&per_page=100` (SHA-256 du brut `3bdef0d2931d09b5eea6c04e2fb38200af9e30a947b8323b4f9a1b62f8112aed`), valeurs brutes 60,10 et 58,17.
- **Contrôle** : le même jeu donne 78,7 % d'adultes ayant un compte (tous types, `account.t.d`, monde, 2024), conforme au « 79% of adults globally now have an account » de la page Findex 2025.
- **Attention** : une part d'adultes, pas un nombre de comptes ; l'indicateur compte aussi certains portefeuilles numériques hors d'Afrique (Corée 60 %, Brésil 58 % en 2024).
- **Mise à jour** : prochaine enquête Findex.
- **Utilisé par** : `graphe_findex_regions()` (figure `fig-findex-regions`).

## `findex_mobile_money_genre.csv`

- **Contenu** : part des femmes et des hommes de 15 ans et plus ayant un compte de mobile money, en %, pays à revenu faible ou intermédiaire (`LMY`), 2021 et 2024 (2 lignes) : `zone`, `annee`, `femmes_pct`, `hommes_pct` (arrondis à 0,1).
- **Source** : Banque mondiale, Global Findex Database 2025, indicateurs `mobileaccount.t.d.1` (femmes) et `mobileaccount.t.d.2` (hommes), même API que ci-dessus (`.../indicator/mobileaccount.t.d.1?source=28&format=json&per_page=1000`).
- **Téléchargé le** : 22/10/2026.
- **SHA-256 des fichiers bruts** : femmes `e74fa8b33ede6f2c1a261f217f9d4fe3de5fe770a1360a2d47cf48a1c6c461bd` ; hommes `a0be6aeaf0016d290acf9f3fcee0216e47137da4c8ae148574d91eb649a64628`.
- **Traitement** : fusion femmes / hommes, zone `LMY`, années 2021 et 2024, arrondi à 0,1.
- **Contrôle** : écart relatif 2021 = 1 − 10,5 / 15,0 = 30 %, repris sur la page. Écart relatif 2024 = 1 − 14,6 / 22,1 = 33,9 %, arrondi à 34 % sur la page et les diapos (seule source citée dans le texte courant depuis le 22/10/2026). La GSMA (2026) donne **36 %** pour 2024 : champ ou pondération différents, non vérifié ; mentionné seulement dans la légende et les notes.
- **Utilisé par** : `graphe_findex_genre()` (figure `fig-findex-genre`).
