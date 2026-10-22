# preparer_2026-10-22.R · CM 7 : construit quatre CSV de data/cm7/ à partir des fichiers bruts
#   inflation_pays_2026-09.csv, prix_petrole_gaz_2021_2026.csv,
#   salaires_negocies_inflation_2021_2026.csv, anticipations_inflation_2022_2026.csv
#
# Fichiers bruts (téléchargés le 22/10/2026 par curl ; adresses et SHA-256 dans data/cm7/SOURCES.md),
# à placer dans un même dossier sous ces noms :
#   eurostat_prc_hicp_minr_TOTAL_EA21_2026-09.json  Eurostat, 21 pays + EA, septembre 2026
#   CMO-Historical-Data-Monthly.xlsx                 Banque mondiale, Pink Sheet (édition 0050012026)
#   exr_M_USD_EUR.csv                                BCE, EXR.M.USD.EUR.SP00.A
#   inw_U2_q.csv                                     BCE, INW.Q.U2.N.INWR.000000.4F0.GY.IX
#   eurostat_prc_hicp_minr_TOTAL_EA_2021-2026.json   Eurostat, zone euro, depuis 2021-01
#   ces_Z18_C1120_C1220_WM.csv                       BCE, CES (12 mois et 3 ans)
#   spf_hicp_lt.csv                                  BCE, SPF.Q.U2.HICP.POINT.LT.Q.AVG
# Les bruts ne sont pas versionnés (copie locale : _drafts/donnees/cm7/brut/).
#
# Usage, depuis la racine du projet :
#   Rscript data/cm7/preparer_2026-10-22.R [dossier_brut] [dossier_sortie]
# Par défaut : _drafts/donnees/cm7/brut et data/cm7. La page de cours ne l'appelle pas ;
# elle lit seulement les CSV.

library(readxl)
library(jsonlite)

args <- commandArgs(TRUE)
brut <- if (length(args) >= 1) args[1] else here::here("_drafts/donnees/cm7/brut")
dossier <- if (length(args) >= 2) args[2] else here::here("data/cm7")

#' Lit une réponse JSON-stat de l'API Eurostat à une seule dimension variable
#' (geo ou time) et renvoie un data.frame code / valeur.
lire_eurostat <- function(fichier, dim) {
  j <- fromJSON(fichier)
  idx <- unlist(j$dimension[[dim]]$category$index)
  codes <- names(sort(idx))
  val <- rep(NA_real_, length(codes))
  v <- unlist(j$value)
  val[as.integer(names(v)) + 1] <- v
  stopifnot(length(j$status) == 0)   # aucune valeur provisoire ou estimée signalée
  data.frame(code = codes, valeur = val)
}

# ---------------------------------------------------------------------------
# P1. Inflation de septembre 2026 dans les 21 pays de la zone euro
# ---------------------------------------------------------------------------
noms_pays <- c(
  EA = "Zone euro", AT = "Autriche", BE = "Belgique", BG = "Bulgarie", CY = "Chypre",
  DE = "Allemagne", EE = "Estonie", EL = "Grèce", ES = "Espagne", FI = "Finlande",
  FR = "France", HR = "Croatie", IE = "Irlande", IT = "Italie", LT = "Lituanie",
  LU = "Luxembourg", LV = "Lettonie", MT = "Malte", NL = "Pays-Bas", PT = "Portugal",
  SI = "Slovénie", SK = "Slovaquie"
)
p1 <- lire_eurostat(file.path(brut, "eurostat_prc_hicp_minr_TOTAL_EA21_2026-09.json"), "geo")
names(p1) <- c("geo", "inflation")
p1$pays <- noms_pays[p1$geo]
p1$taux_depot <- 2.50                          # en vigueur depuis le 16/09/2026 (data/cm7)
p1$taux_reel <- round(p1$taux_depot - p1$inflation, 1)
p1 <- p1[order(p1$inflation), c("geo", "pays", "inflation", "taux_depot", "taux_reel")]
stopifnot(nrow(p1) == 22, !anyNA(p1))
write.csv(p1, file.path(dossier, "inflation_pays_2026-09.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# P2. Prix du pétrole (Brent) et du gaz européen (TTF), en euros, 2021-2026
# ---------------------------------------------------------------------------
cmo <- suppressMessages(read_excel(file.path(brut, "CMO-Historical-Data-Monthly.xlsx"),
                                   sheet = "Monthly Prices", col_names = FALSE))
stopifnot(cmo[[3]][5] == "Crude oil, Brent", cmo[[9]][5] == "Natural gas, Europe",
          cmo[[3]][6] == "($/bbl)", cmo[[9]][6] == "($/mmbtu)")
cmo <- data.frame(mois = sub("M", "-", cmo[[1]]), brent_usd_baril = suppressWarnings(as.numeric(cmo[[3]])),
                  gaz_usd_mmbtu = suppressWarnings(as.numeric(cmo[[9]])))
cmo <- subset(cmo, grepl("^202[1-6]-", mois))
exr <- read.csv(file.path(brut, "exr_M_USD_EUR.csv"))[, c("TIME_PERIOD", "OBS_VALUE")]
names(exr) <- c("mois", "usd_par_eur")
p2 <- merge(cmo, exr, by = "mois")
mwh_par_mmbtu <- 0.293071                      # 1 MMBtu = 0,293071 MWh
p2$brent_eur_baril <- round(p2$brent_usd_baril / p2$usd_par_eur, 1)
p2$gaz_eur_mwh <- round(p2$gaz_usd_mmbtu / mwh_par_mmbtu / p2$usd_par_eur, 1)
p2$usd_par_eur <- round(p2$usd_par_eur, 4)
stopifnot(nrow(p2) == 69, !anyNA(p2), utils::tail(p2$mois, 1) == "2026-09")
write.csv(p2, file.path(dossier, "prix_petrole_gaz_2021_2026.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# P3. Salaires négociés et inflation, zone euro, par trimestre, 2021-2026
# ---------------------------------------------------------------------------
inw <- read.csv(file.path(brut, "inw_U2_q.csv"))[, c("TIME_PERIOD", "OBS_VALUE")]
names(inw) <- c("trimestre", "salaires_negocies")
ipch <- lire_eurostat(file.path(brut, "eurostat_prc_hicp_minr_TOTAL_EA_2021-2026.json"), "time")
ipch$trimestre <- paste0(substr(ipch$code, 1, 4), "-Q", (as.integer(substr(ipch$code, 6, 7)) + 2) %/% 3)
n_mois <- tapply(ipch$valeur, ipch$trimestre, length)
infl_t <- tapply(ipch$valeur, ipch$trimestre, mean)
infl_t <- data.frame(trimestre = names(infl_t), inflation = round(as.numeric(infl_t), 2))[n_mois == 3, ]
p3 <- merge(subset(inw, trimestre >= "2021-Q1"), infl_t, by = "trimestre")
stopifnot(nrow(p3) == 22, !anyNA(p3), utils::tail(p3$trimestre, 1) == "2026-Q2")
write.csv(p3, file.path(dossier, "salaires_negocies_inflation_2021_2026.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# P4. Anticipations d'inflation : ménages (CES) et prévisionnistes (SPF)
# ---------------------------------------------------------------------------
ces <- read.csv(file.path(brut, "ces_Z18_C1120_C1220_WM.csv"))
ces <- data.frame(date = paste0(ces$TIME_PERIOD, "-15"),
                  serie = c(C1120 = "menages_12_mois", C1220 = "menages_3_ans")[ces$CES_VARIABLE],
                  valeur = ces$OBS_VALUE)
spf <- read.csv(file.path(brut, "spf_hicp_lt.csv"))[, c("TIME_PERIOD", "OBS_VALUE")]
# Le questionnaire du trimestre T est envoyé au premier mois du trimestre : point au 15 de ce mois.
mois_q <- c(Q1 = "01", Q2 = "04", Q3 = "07", Q4 = "10")[substr(spf$TIME_PERIOD, 6, 7)]
spf <- data.frame(date = paste0(substr(spf$TIME_PERIOD, 1, 4), "-", mois_q, "-15"),
                  serie = "previsionnistes_long_terme", valeur = round(spf$OBS_VALUE, 2))
p4 <- rbind(ces, subset(spf, date >= "2022-04-01"))
stopifnot(!anyNA(p4), length(unique(p4$serie)) == 3)
write.csv(p4, file.path(dossier, "anticipations_inflation_2022_2026.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# Contrôles : recoupements avec cours/cm7.qmd et data/cm7/ipch_2021_2026.csv
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol
infl <- stats::setNames(p1$inflation, p1$geo)
stopifnot(proche(infl[["EA"]], 3.8), proche(infl[["DE"]], 3.3), proche(infl[["FR"]], 3.4),
          proche(infl[["ES"]], 5.0), proche(infl[["IT"]], 4.2))           # page, § « Un seul taux »
projet <- read.csv(here::here("data/cm7/ipch_2021_2026.csv"))
projet <- subset(projet, zone == "EA" & serie == "ensemble")
stopifnot(identical(projet$mois, ipch$code), all(proche(projet$inflation, ipch$valeur)))
cat("Contrôles passés.\n")
