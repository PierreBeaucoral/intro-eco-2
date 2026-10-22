# extraire_wegovy_mounjaro.R · CSV de l'encadré « méthode » du CM 3 (Wegovy et Mounjaro, 2026)
#
# Fichiers bruts téléchargés le 22/10/2026 (URL et SHA-256 dans data/cm3/SOURCES.md),
# non versionnés (environ 80 Mo). Lit seulement, sans les exécuter ni les modifier,
# les fichiers de _drafts/donnees/cm3-wegovy/brut/ :
#   brut/medicam_xls/  Medic'AM mensuel, Assurance Maladie (2025-07 à 2026-08)
#   brut/bdpm/         Base de données publique des médicaments, fichiers du 22/10/2026
# et écrit dans data/cm3/ :
#   boites_wegovy_mounjaro_ozempic_mensuel.csv  boîtes remboursées par mois : Wegovy, Mounjaro,
#                                               Ozempic (2025-07 à 2026-08)
#   prix_boite_wegovy.csv                       prix d'une boîte : prix fixés au 15/06/2026 (JO)
#                                               et indemnité d'accès précoce
#
# Usage, depuis la racine du projet : Rscript data/cm3/extraire_wegovy_mounjaro.R
# Le script n'est pas appelé par la page de cours, qui lit seulement les CSV.

library(readxl)

dossier <- here::here("data/cm3")
brut <- here::here("_drafts/donnees/cm3-wegovy/brut")

# ---------------------------------------------------------------------------
# 1. Medic'AM mensuel, feuille « tous_presc » (tous prescripteurs, pharmacies de ville,
#    en date de remboursement). Par mois, trois colonnes dans cet ordre : base de
#    remboursement, nombre de boîtes remboursées, montant remboursé (vérifié).
#    Produits : WEGOVY FLEXT et WEGOVY FLEXTOUCH (regroupés en Wegovy), MOUNJARO, OZEMPIC.
# ---------------------------------------------------------------------------
fichiers <- list.files(file.path(brut, "medicam_xls"), pattern = "serie-mensuelle[.]xls$", full.names = TRUE)
stopifnot(length(fichiers) == 3)

#' Boîtes remboursées par produit et par mois dans un fichier semestriel (ou bimestriel) Medic'AM
lire_medicam <- function(xls) {
  feuille <- grep("tous_presc", excel_sheets(xls), value = TRUE)
  stopifnot(length(feuille) == 1)
  x <- read_excel(xls, sheet = feuille, col_types = "text")
  stopifnot(names(x)[1] == "CIP13", names(x)[3] == "PRODUIT")
  x <- x[grepl("^(WEGOVY|MOUNJARO|OZEMPIC)", x[[3]]), ]
  x$produit <- tools::toTitleCase(tolower(sub(" .*", "", x[[3]])))
  cols <- grep("^Nombre de boites", names(x))
  stopifnot(length(cols) >= 2, all(grepl("^Base de remboursement", names(x)[cols - 1])))
  do.call(rbind, lapply(cols, function(j) {
    mois <- regmatches(names(x)[j], regexpr("[0-9]{4}-[0-9]{2}", names(x)[j]))
    n <- tapply(as.numeric(x[[j]]), x$produit, sum, na.rm = TRUE)
    data.frame(mois = mois, produit = names(n), boites = as.integer(n))
  }))
}
g1 <- do.call(rbind, lapply(fichiers, lire_medicam))
g1 <- g1[order(g1$produit, g1$mois), ]
stopifnot(!anyDuplicated(g1[c("mois", "produit")]),
          setequal(unique(g1$mois), format(seq(as.Date("2025-07-01"), as.Date("2026-08-01"), "month"), "%Y-%m")))
# Wegovy et Mounjaro n'apparaissent qu'à partir de janvier 2026 (lignes à 0 jusqu'en mai)
stopifnot(all(g1$boites[g1$produit != "Ozempic" & g1$mois < "2026-06"] == 0),
          all(g1$boites[g1$produit != "Ozempic" & g1$mois >= "2026-06"] > 0))
utils::write.csv(g1, file.path(dossier, "boites_wegovy_mounjaro_ozempic_mensuel.csv"), row.names = FALSE)
print(stats::reshape(g1, idvar = "mois", timevar = "produit", direction = "wide"))

# ---------------------------------------------------------------------------
# 2. Prix d'une boîte (prix public TTC hors honoraire de dispensation)
#    - prix fixés à compter du 15/06/2026 : avis relatifs aux prix, JORF n° 0123 du
#      28/05/2026, textes 101 (Wegovy) et 103 (Mounjaro), recopiés ci-dessous et
#      contrôlés contre la BDPM (colonne « prix sans honoraire » de CIS_CIP_bdpm.txt) ;
#    - Ozempic 1 mg : BDPM (même fichier) ;
#    - indemnité maximale d'accès précoce de Wegovy, fixée par le laboratoire :
#      431,41 € TTC par stylo (376 € HT), HAS, avis économique CEESP du 15/07/2025, p. 12.
# ---------------------------------------------------------------------------
jo <- c(`3400930258620` = 146.91,   # Wegovy 0,25 mg
        `3400930258637` = 146.91,   # Wegovy 0,5 mg
        `3400930258644` = 146.91,   # Wegovy 1 mg
        `3400930260241` = 169.31,   # Wegovy 1,7 mg
        `3400930258668` = 195.10,   # Wegovy 2,4 mg
        `3400930292907` = 176.10,   # Mounjaro 2,5 mg : prix le plus bas (cité dans le cours, pas dans le CSV)
        `3400930292952` = 433.80)   # Mounjaro 12,5 mg : prix le plus haut (idem ; JO, texte 103)
bdpm <- utils::read.delim(file.path(brut, "bdpm", "CIS_CIP_bdpm.txt"), header = FALSE, quote = "",
                          colClasses = "character", fileEncoding = "UTF-8")
prix_bdpm <- function(cip) as.numeric(sub(",", ".", bdpm$V10[bdpm$V7 == cip]))
stopifnot(all(abs(sapply(names(jo), prix_bdpm) - jo) < 0.005))
cat("Contrôle : prix du JO du 28/05/2026 = prix de la BDPM du 22/10/2026 (7 présentations) : OK\n")
# « de 176,10 à 433,80 € pour Mounjaro » (cours/cm3.qmd) : bornes des 6 présentations du JO, texte 103
mounjaro <- c("3400930292907", "3400930292914", "3400930292938", "3400930292945", "3400930292952", "3400930292976")
stopifnot(isTRUE(all.equal(range(sapply(mounjaro, prix_bdpm)), c(176.10, 433.80))))
cat("Contrôle : prix de Mounjaro de 176,10 à 433,80 € (6 présentations, BDPM) : OK\n")

g2 <- data.frame(
  presentation = c("Wegovy, accès précoce", "Wegovy 2,4 mg", "Wegovy 0,25 à 1 mg", "Ozempic 1 mg"),
  prix = c(431.41, jo[["3400930258668"]], jo[["3400930258644"]], prix_bdpm("3400930151105")),
  fixe_par = c("laboratoire", "État (CEPS)", "État (CEPS)", "État (CEPS)"),
  periode = c("2022-2023", "depuis le 15/06/2026", "depuis le 15/06/2026", "en vigueur au 22/10/2026"),
  source = c("HAS, avis économique CEESP du 15/07/2025 (indemnité maximale d'accès précoce, par stylo)",
             "JORF n° 0123 du 28/05/2026, texte 101 ; BDPM 22/10/2026",
             "JORF n° 0123 du 28/05/2026, texte 101 ; BDPM 22/10/2026",
             "BDPM 22/10/2026 (CIP 3400930151105)")
)
stopifnot(abs(g2$prix[4] - 76.58) < 0.005)   # chiffre déjà cité dans cours/cm3.qmd
utils::write.csv(g2, file.path(dossier, "prix_boite_wegovy.csv"), row.names = FALSE, fileEncoding = "UTF-8")
print(g2[1:4])
