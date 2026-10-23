# preparer_revenu.R · CM 9, « Par revenu » : construit trois CSV de data/cm9/ à partir des
# fichiers bruts (téléchargés le 23/10/2026, jamais modifiés ; adresses et SHA-256 dans
# data/cm9/SOURCES.md) :
#   depenses_biens_quintiles_us_2023_2024.csv  BLS, Consumer Expenditure Surveys
#   cout_droits_deciles_yale_2026.csv          Yale Budget Lab, « The State of U.S. Tariffs »
#   hausse_impot_droits_quintiles_tpc_2026.csv Tax Policy Center, « TPC Tariff Tracker »
# Fichiers bruts attendus dans un même dossier, sous ces noms :
#   bls_api_cex_quintiles_part1.json à part3.json, ybl_default-scenario_distribution.csv,
#   tpc_datawrapper_UATS7_v41_dataset.csv
# Les bruts ne sont pas versionnés (copie locale : _drafts/donnees/cm9-revenu/brut/).
#
# Usage, depuis la racine du projet :
#   Rscript data/cm9/preparer_revenu.R [dossier_brut] [dossier_sortie]
# Par défaut : _drafts/donnees/cm9-revenu/brut et data/cm9. La page de cours et les diapos
# ne l'appellent pas ; R/cm9.R lit seulement les CSV.

args <- commandArgs(TRUE)
brut <- if (length(args) >= 1) args[1] else here::here("_drafts/donnees/cm9-revenu/brut")
dossier <- if (length(args) >= 2) args[2] else here::here("data/cm9")

# ---------------------------------------------------------------------------
# 1. BLS, Consumer Expenditure Surveys (CE), quintiles de revenu avant impôt, 2023-2024.
#    Séries CXU<poste>LB01<groupe>M : LB0101 = ensemble, LB0102 à LB0106 = quintiles 1 à 5
#    (contrôle ci-dessous contre le communiqué du 19/12/2025, tableau C).
# ---------------------------------------------------------------------------
series <- do.call(rbind, lapply(sprintf("bls_api_cex_quintiles_part%d.json", 1:3), function(f) {
  r <- jsonlite::fromJSON(file.path(brut, f), simplifyVector = FALSE)
  stopifnot(r$status == "REQUEST_SUCCEEDED")
  do.call(rbind, lapply(r$Results$series, function(s) {
    if (length(s$data) == 0) return(NULL)
    data.frame(id = s$seriesID,
               annee = vapply(s$data, function(d) as.integer(d$year), 1L),
               valeur = vapply(s$data, function(d) as.numeric(d$value), 1))
  }))
}))
series$poste <- sub("^CXU(.*)LB01..M$", "\\1", series$id)
series$groupe <- as.integer(sub("^.*LB01(..)M$", "\\1", series$id)) - 1L   # 0 = ensemble, 1..5 = quintiles
# GASOIL renvoie des valeurs aberrantes (1 ou 2 $) : ce n'est pas le code de l'essence ; écarté.
postes <- c("INCBEFTX", "INCAFTTX", "TOTALEXP", "FOODHOME", "ALCBEVG", "HKPGSUPP",
            "HHFURNSH", "APPAREL", "VEHPURCH")
series <- series[series$poste %in% postes, ]
large <- reshape(series[, c("annee", "groupe", "poste", "valeur")], direction = "wide",
                 idvar = c("annee", "groupe"), timevar = "poste")
names(large) <- sub("^valeur\\.", "", names(large))
large <- large[order(large$annee, large$groupe), ]

biens <- c("FOODHOME", "ALCBEVG", "HKPGSUPP", "HHFURNSH", "APPAREL", "VEHPURCH")
cex <- data.frame(
  annee = large$annee,
  groupe = ifelse(large$groupe == 0, "ensemble", paste0("Q", large$groupe)),
  revenu_avant_impot = large$INCBEFTX,
  revenu_apres_impot = large$INCAFTTX,          # NA en 2024 : le BLS ne l'a pas produit
  depense_totale = large$TOTALEXP,
  alimentation_domicile = large$FOODHOME,
  boissons_alcoolisees = large$ALCBEVG,
  produits_entretien = large$HKPGSUPP,
  meubles_equipement_logement = large$HHFURNSH,
  habillement = large$APPAREL,
  achats_vehicules = large$VEHPURCH,
  biens_total = rowSums(large[, biens])
)
cex$depense_pct_rev_apres <- round(100 * cex$depense_totale / cex$revenu_apres_impot, 1)
cex$depense_pct_rev_avant <- round(100 * cex$depense_totale / cex$revenu_avant_impot, 1)
cex$biens_pct_rev_apres <- round(100 * cex$biens_total / cex$revenu_apres_impot, 1)
cex$biens_pct_rev_avant <- round(100 * cex$biens_total / cex$revenu_avant_impot, 1)
cex$biens_pct_depense <- round(100 * cex$biens_total / cex$depense_totale, 1)

# Contrôle : dépenses moyennes 2024 du communiqué BLS du 19/12/2025 (tableau C).
stopifnot(isTRUE(all.equal(cex$depense_totale[cex$annee == 2024],
                    c(78535, 35046, 50054, 66900, 89972, 150342))))
stopifnot(nrow(cex) == 12, all(!is.na(cex$revenu_apres_impot[cex$annee == 2023])))
utils::write.csv(cex, file.path(dossier, "depenses_biens_quintiles_us_2023_2024.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# 2. Yale Budget Lab, « The State of U.S. Tariffs », scénario par défaut (droit en vigueur),
#    mise à jour du 24/08/2026 : coût des droits par décile de revenu.
# ---------------------------------------------------------------------------
y <- utils::read.csv(file.path(brut, "ybl_default-scenario_distribution.csv"))
y$col <- paste0(ifelse(y$basis == "2025 dollars", "usd", "pct_revenu"), "_", y$substitution)
ybl <- reshape(y[, c("category", "col", "value")], direction = "wide",
               idvar = "category", timevar = "col")
names(ybl) <- sub("^value\\.", "", names(ybl))
names(ybl)[1] <- "decile"
ybl[-1] <- lapply(ybl[-1], function(v) round(-v, 3))   # coût positif (le fichier note une perte, < 0)
stopifnot(nrow(ybl) == 11, ybl$decile[11] == "Total")
utils::write.csv(ybl, file.path(dossier, "cout_droits_deciles_yale_2026.csv"), row.names = FALSE)

# ---------------------------------------------------------------------------
# 3. Tax Policy Center, figure 3 du « TPC Tariff Tracker » (Datawrapper UATS7, version 41),
#    tableau T26-0148 : hausse du taux moyen d'imposition fédérale, en points, 2026.
# ---------------------------------------------------------------------------
t <- utils::read.csv(file.path(brut, "tpc_datawrapper_UATS7_v41_dataset.csv"), check.names = FALSE)
t <- t[trimws(t[[1]]) != "", ]
tpc <- data.frame(groupe = t[[1]], hausse_taux_moyen_pts = t[[2]])
stopifnot(nrow(tpc) == 9)
utils::write.csv(tpc, file.path(dossier, "hausse_impot_droits_quintiles_tpc_2026.csv"), row.names = FALSE)

print(cex[, c("annee", "groupe", "depense_pct_rev_apres", "depense_pct_rev_avant",
              "biens_pct_rev_apres", "biens_pct_rev_avant", "biens_pct_depense")])
print(ybl)
