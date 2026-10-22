# extraire_medicam_mensuel.R · construit trois CSV de data/cm3/ à partir des
# fichiers bruts téléchargés le 22/10/2026 (URL et SHA-256 dans data/cm3/SOURCES.md).
# Les fichiers bruts (environ 210 Mo) ne sont pas versionnés : ils sont lus, sans
# être modifiés, dans _drafts/donnees/cm3/brut/ (medicam_xls/, openmedic/, cms/).
#
#   boites_aglp1_mensuel_2022_2026.csv    boîtes remboursées par produit et par mois, 2022-01 à 2026-06
#   part_remboursee_aglp1_2025.csv        base de remboursement et montant remboursé, 2025, par produit
#   patients_ozempic_fr_us_2020_2024.csv  patients sous Ozempic, France (Open Medic) et
#                                         États-Unis (Medicare Part D), 2020-2024
#
# Usage, depuis la racine du projet : Rscript data/cm3/extraire_medicam_mensuel.R
# Le script n'est pas appelé par la page de cours, qui lit seulement les CSV.

library(readxl)

brut <- here::here("_drafts/donnees/cm3/brut")
sortie <- here::here("data/cm3")

# ---------------------------------------------------------------------------
# 1. Medic'AM, séries mensuelles (feuille « tous_presc »), 9 semestres
#    Colonnes par mois : Base de remboursement, Nombre de boites remboursées,
#    Montant remboursé (dans cet ordre, vérifié ci-dessous).
# ---------------------------------------------------------------------------
fichiers <- list.files(file.path(brut, "medicam_xls"), pattern = "serie-mensuelle[.]xls$", full.names = TRUE)
stopifnot(length(fichiers) == 9)

#' Base, boîtes et montant remboursé par produit et par mois (aGLP-1, Wegovy, Mounjaro)
lire_semestre <- function(xls) {
  feuille <- grep("tous_presc", excel_sheets(xls), value = TRUE)
  stopifnot(length(feuille) == 1)
  x <- read_excel(xls, sheet = feuille, col_types = "text")
  stopifnot(names(x)[3] == "PRODUIT", grepl("ATC", names(x)[6]))
  x <- x[grepl("^A10BJ", x[[6]]) | grepl("^(WEGOVY|MOUNJARO)", x[[3]]), ]
  cols <- grep("^Base de remboursement", names(x))
  stopifnot(length(cols) == 6)
  do.call(rbind, lapply(cols, function(j) {
    stopifnot(grepl("^Nombre de boites", names(x)[j + 1]), grepl("^Montant rembours", names(x)[j + 2]))
    mois <- regmatches(names(x)[j], regexpr("[0-9]{4}-[0-9]{2}", names(x)[j]))
    somme <- function(k) tapply(as.numeric(x[[k]]), x[[3]], sum, na.rm = TRUE)
    b <- somme(j); n <- somme(j + 1); r <- somme(j + 2)
    data.frame(mois = mois, produit = names(n), boites = as.integer(n),
               base_remboursement = round(as.numeric(b), 2), montant_rembourse = round(as.numeric(r), 2))
  }))
}
m <- do.call(rbind, lapply(fichiers, lire_semestre))
m <- m[order(m$mois, m$produit), ]
stopifnot(!anyDuplicated(m[c("mois", "produit")]), length(unique(m$mois)) == 54)

utils::write.csv(m[c("mois", "produit", "boites")], file.path(sortie, "boites_aglp1_mensuel_2022_2026.csv"), row.names = FALSE)

m25 <- m[substr(m$mois, 1, 4) == "2025" & m$produit %in% c("OZEMPIC", "TRULICITY", "VICTOZA"), ]
g2 <- aggregate(cbind(boites, base_remboursement, montant_rembourse) ~ produit, m25, sum)
stopifnot(nrow(g2) == 3, all(table(m25$produit) == 12))
utils::write.csv(g2, file.path(sortie, "part_remboursee_aglp1_2025.csv"), row.names = FALSE)

# Contrôle 1 : somme des 12 mois de 2022 à 2024 = fichier annuel déjà validé (data/cm3)
annuel <- utils::read.csv(here::here("data/cm3/boites_aglp1_2020_2024.csv"))
m$annee <- as.integer(substr(m$mois, 1, 4))
s <- aggregate(boites ~ annee + produit, m[m$annee %in% 2022:2024, ], sum)
ctl <- merge(s, annuel, by = c("annee", "produit"), suffixes = c("_mensuel", "_annuel"))
stopifnot(nrow(ctl) == 15, all(ctl$boites_mensuel == ctl$boites_annuel))
cat("Contrôle 1 (Medic'AM mensuel = annuel, 2022-2024, 15 couples année-produit) : OK\n")

# ---------------------------------------------------------------------------
# 2. Open Medic (Assurance Maladie), fichiers NB_AAAA_atc5 : patients (nbc),
#    boîtes, base (BSE) et montant remboursé (REM) par substance (ATC5).
#    A10BJ06 = sémaglutide = Ozempic seul en France de 2020 à 2025 (Wegovy
#    remboursé depuis juin 2026 seulement ; seul OZEMPIC porte A10BJ06 dans Medic'AM 2025).
# ---------------------------------------------------------------------------
lire_open_medic <- function(annee) {
  f <- file.path(brut, "openmedic", sprintf("NB_%d_atc5.CSV.gz", annee))
  x <- utils::read.csv2(gzfile(f, encoding = "latin1"), colClasses = "character")
  names(x) <- toupper(names(x))
  x <- x[x$ATC5 == "A10BJ06", ]
  stopifnot(nrow(x) == 1)
  num <- function(v) as.numeric(gsub(",", ".", gsub(".", "", v, fixed = TRUE)))
  data.frame(annee = annee, patients = as.integer(x$NBC), boites = as.integer(x$BOITES),
             base = num(x$BSE), rembourse = num(x$REM))
}
om <- do.call(rbind, lapply(2020:2025, lire_open_medic))
print(om)

# Contrôle 2 : Open Medic 2025 et Medic'AM 2025 (somme des 12 mois) pour Ozempic
oz25 <- g2[g2$produit == "OZEMPIC", ]
cat(sprintf("Contrôle 2 : boîtes d'Ozempic 2025, Medic'AM %d, Open Medic %d (écart %.2f %%)\n",
            oz25$boites, om$boites[om$annee == 2025], 100 * (oz25$boites / om$boites[om$annee == 2025] - 1)))
cat(sprintf("            part remboursée 2025, Medic'AM %.1f %%, Open Medic %.1f %%\n",
            100 * oz25$montant_rembourse / oz25$base_remboursement,
            100 * om$rembourse[om$annee == 2025] / om$base[om$annee == 2025]))

# ---------------------------------------------------------------------------
# 3. CMS, Medicare Part D Spending by Drug (DY2024) : bénéficiaires d'Ozempic
#    (Tot_Benes_AAAA), ligne « Overall » (tous fabricants).
# ---------------------------------------------------------------------------
cms <- utils::read.csv(file.path(brut, "cms", "DSD_PTD_RY26_P04_V10_DY24_BGM.csv"), colClasses = "character")
oz <- cms[cms$Brnd_Name == "Ozempic" & cms$Mftr_Name == "Overall", ]
stopifnot(nrow(oz) == 1)
us <- data.frame(annee = 2020:2024, patients = as.integer(unlist(oz[paste0("Tot_Benes_", 2020:2024)])),
                 ordonnances = as.integer(round(as.numeric(unlist(oz[paste0("Tot_Clms_", 2020:2024)])))))
print(us)

g3 <- rbind(
  data.frame(annee = 2020:2024, pays = "France", patients = om$patients[om$annee %in% 2020:2024],
             source = "Assurance Maladie, Open Medic (A10BJ06, nbc)"),
  data.frame(annee = 2020:2024, pays = "États-Unis (Medicare)", patients = us$patients,
             source = "CMS, Medicare Part D Spending by Drug (Ozempic, Tot_Benes)")
)
stopifnot(!anyNA(g3$patients))
utils::write.csv(g3, file.path(sortie, "patients_ozempic_fr_us_2020_2024.csv"), row.names = FALSE, fileEncoding = "UTF-8")
