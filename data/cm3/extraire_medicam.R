# extraire_medicam.R · construit data/cm3/boites_aglp1_2020_2024.csv
#
# Source : Assurance Maladie, Medic'AM, fichiers annuels 2020 à 2024
# (médicaments remboursés par tous les régimes, délivrés en pharmacie de ville,
# feuille « tous prescripteurs », en date de remboursement).
# Liste des fichiers : https://www.data.gouv.fr/datasets/536999d3a3a729239d20533a
#
# On garde les analogues du GLP-1 (code ATC commençant par A10BJ) et on somme,
# par produit et par année, le nombre de boîtes remboursées et la base de
# remboursement (en euros, toutes présentations du produit confondues). Le fichier 2019 n'est
# pas repris : Trulicity et Victoza n'y portent pas le code A10BJ, la série
# serait incomplète.
#
# Usage, depuis la racine du projet (réseau nécessaire, environ 15 Mo) :
#   Rscript data/cm3/extraire_medicam.R
# Le script n'est pas appelé par la page de cours, qui lit seulement le CSV.

library(readxl)

base <- "https://www.assurance-maladie.ameli.fr/sites/default/files/"
fichiers <- c(
  `2020` = "2020_medic-am-par-type-de-prescripteur_cumul-annuel.zip",
  `2021` = "2021_medic-am-par-type-de-prescripteur_cumul-annuel.zip",
  `2022` = "2022-medic-am-par-type-de-prescripteur_serie-annuelle.zip",
  `2023` = "2023-medic-am-par-type-de-prescripteur_serie-annuelle.zip",
  `2024` = "2024-medic-am-par-type-de-prescripteur_serie-annuelle.zip"
)

#' Boîtes d'aGLP-1 remboursées et base de remboursement une année donnée, par produit
#' @param annee année (texte), @param zip nom du fichier sur le site de l'Assurance Maladie
boites_annee <- function(annee, zip) {
  dossier <- file.path(tempdir(), annee)
  dir.create(dossier, showWarnings = FALSE, recursive = TRUE)
  archive <- file.path(dossier, zip)
  utils::download.file(paste0(base, zip), archive, mode = "wb", quiet = TRUE)
  xls <- utils::unzip(archive, exdir = dossier)
  xls <- xls[grepl("[.]xls$", xls)][1]
  feuille <- grep("tous_presc", excel_sheets(xls), value = TRUE)[1]
  x <- read_excel(xls, sheet = feuille, col_types = "text")
  # colonnes : 3 = PRODUIT, 6 = code ATC, 10 = base de remboursement,
  # 11 = nombre de boîtes remboursées
  x <- x[grepl("^A10BJ", x[[6]]), ]
  stopifnot(nrow(x) > 0, grepl("^Base de remboursement", names(x)[10]),
            grepl("^Nombre de boites", names(x)[11]))
  agg <- tapply(as.numeric(x[[11]]), x[[3]], sum)
  base <- tapply(as.numeric(x[[10]]), x[[3]], sum)
  data.frame(annee = as.integer(annee), produit = names(agg), boites = as.integer(agg),
             base_remboursement = round(as.numeric(base[names(agg)]), 2))
}

boites <- do.call(rbind, Map(boites_annee, names(fichiers), fichiers))
boites <- boites[order(boites$annee, boites$produit), ]
utils::write.csv(boites, file.path("data", "cm3", "boites_aglp1_2020_2024.csv"), row.names = FALSE)
print(boites)
