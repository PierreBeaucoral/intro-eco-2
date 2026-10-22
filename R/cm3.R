# cm3.R · graphiques du CM 3 (pénurie d'Ozempic, prix administré, rationnement),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm3.qmd sont définies ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.

# ---------------------------------------------------------------------------
# 1. Le marché fictif de l'exemple chiffré (Exemple 1 de la page)
#    Q en milliers de boîtes par mois, P en euros par boîte. Exemple fictif :
#    le prix fixé de 75 € arrondit les 76,58 € réels (BDPM, consulté le 21/10/2026).
#    Demande avant le choc    : Q = 115 - 0,2 P   (100 à 75 €)
#    Demande après le choc D' : Q = 175 - 0,2 P   (60 de plus à chaque prix)
#    Offre de court terme     : Q = 92,5 + 0,1 P  (presque verticale, 100 à 75 €)
#    Offre de long terme      : Q = 55 + 0,6 P    (élastique, 100 à 75 €)
# ---------------------------------------------------------------------------
marche_cm3 <- list(
  d_a = 115, d_b = 0.2,      # demande avant le choc : Q = d_a - d_b P
  choc = 60,                 # hausse de la quantité demandée à chaque prix
  oc_a = 92.5, oc_s = 0.1,   # offre de court terme : Q = oc_a + oc_s P
  ol_a = 55, ol_s = 0.6,     # offre de long terme  : Q = ol_a + ol_s P
  prix_fixe = 75             # prix administré (€ par boîte)
)

#' Équilibre d'une demande Q = a - b P et d'une offre Q = c + s P
#' @return liste (p, q)
equilibre_cm3 <- function(a, b, c, s) {
  p <- (a - c) / (b + s)
  list(p = p, q = a - b * p)
}

#' Quantité demandée (avant ou après le choc) et quantité offerte (court ou long terme) au prix p
qd_cm3 <- function(p, apres = TRUE) marche_cm3$d_a + apres * marche_cm3$choc - marche_cm3$d_b * p
qo_cm3 <- function(p, long_terme = FALSE) {
  if (long_terme) marche_cm3$ol_a + marche_cm3$ol_s * p else marche_cm3$oc_a + marche_cm3$oc_s * p
}

eq_initial   <- equilibre_cm3(marche_cm3$d_a, marche_cm3$d_b, marche_cm3$oc_a, marche_cm3$oc_s)
eq_libre_ct  <- equilibre_cm3(marche_cm3$d_a + marche_cm3$choc, marche_cm3$d_b, marche_cm3$oc_a, marche_cm3$oc_s)
eq_libre_lt  <- equilibre_cm3(marche_cm3$d_a + marche_cm3$choc, marche_cm3$d_b, marche_cm3$ol_a, marche_cm3$ol_s)
penurie_cm3  <- qd_cm3(marche_cm3$prix_fixe) - qo_cm3(marche_cm3$prix_fixe)

#' Variation en pourcentage de x0 à x1
var_pct_cm3 <- function(x0, x1) 100 * (x1 - x0) / x0

# ---------------------------------------------------------------------------
# 2. Exemple 2 : qui reçoit les 100 000 boîtes ? (patients fictifs, en milliers)
#    160 milliers de demandes au prix fixé, 100 milliers de boîtes disponibles.
# ---------------------------------------------------------------------------
patients_cm3 <- c(
  deja_traites = 80,         # diabétiques déjà sous traitement (renouvellements)
  nouveaux_atherome = 20,    # nouveaux diabétiques avec maladie athéromateuse avérée
  nouveaux_autres = 30,      # autres nouveaux diabétiques
  hors_indication = 30       # demandes pour perdre du poids (usage hors indication)
)

#' Répartition des boîtes selon une règle de rationnement
#' @param regle "file" (premier arrivé, premier servi, arrivées au hasard) ou
#'   "priorite" (déjà traités, puis nouveaux avec maladie athéromateuse, puis les autres)
#' @param boites nombre de boîtes disponibles
#' @return vecteur nommé : boîtes reçues par groupe (en moyenne pour la file)
rationner_cm3 <- function(regle = c("file", "priorite"), boites = qo_cm3(marche_cm3$prix_fixe)) {
  regle <- match.arg(regle)
  if (regle == "file") return(patients_cm3 * boites / sum(patients_cm3))
  recu <- pmin(patients_cm3, pmax(0, boites - c(0, utils::head(cumsum(patients_cm3), -1))))
  recu[c("nouveaux_autres", "hors_indication")] <- 0   # règle ANSM : ces initiations ne sont pas servies
  recu
}

# ---------------------------------------------------------------------------
# 3. Graphique théorique : choc de demande sous un prix fixé (pénurie)
# ---------------------------------------------------------------------------

#' Choc de demande D -> D' quand le prix reste fixé à son niveau initial P*.
#' Géométrie de l'exemple 1 (offre de court terme presque verticale), mais les
#' axes ne portent que P*, P*' et Q* (graphique théorique).
#' @param prix_libre si TRUE, montre l'équilibre E' qu'atteindrait un prix libre
#' @param base_size 16 (page) ou 24 (diapos)
#' @param etape construction pas à pas pour les diapos : 1 = équilibre initial
#'   (D, O, E) ; 2 = ajoute le choc (D′, flèche) ; 3 = ajoute la pénurie (trait
#'   rouge) ; 4 = figure complète (E′ si prix_libre), identique à la page (défaut)
graphe_penurie <- function(prix_libre = TRUE, base_size = 16, etape = 4) {
  q <- seq(60, 190, length.out = 80)
  d <- data.frame(q = q,
                  demande  = (marche_cm3$d_a - q) / marche_cm3$d_b,
                  demande2 = (marche_cm3$d_a + marche_cm3$choc - q) / marche_cm3$d_b,
                  offre    = (q - marche_cm3$oc_a) / marche_cm3$oc_s)
  p0 <- marche_cm3$prix_fixe; q0 <- eq_initial$q
  q_dem <- qd_cm3(p0)
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  i_lab <- if (etape >= 2) 1:3 else c(1, 3)   # D, O (puis D′)
  g <- ggplot(d, aes(q)) +
    annotate("segment", x = c(q0, 60), xend = c(q0, if (etape >= 2) q_dem else q0), y = c(0, p0), yend = c(p0, p0),
             linetype = "22", colour = neutre) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    geom_line(aes(y = demande2), colour = couleurs_eco[["demande"]], linewidth = 1.4, linetype = "22")
  g <- g + geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    # flèche du déplacement de la demande, vers la droite
    annotate("segment", x = 90, xend = 140, y = 210, yend = 210,
             colour = couleurs_eco[["demande"]], linewidth = 0.7,
             arrow = grid::arrow(length = grid::unit(0.25, "cm"), type = "closed"))
  if (etape >= 3) g <- g +
    # la pénurie au prix fixé : de l'offre à la nouvelle demande
    annotate("segment", x = q0, xend = q_dem, y = p0, yend = p0,
             colour = couleurs_eco[["alerte"]], linewidth = 1.8) +
    annotate("text", x = (q0 + q_dem) / 2, y = p0 - 22, label = "pénurie",
             colour = couleurs_eco[["alerte"]], family = police_cours, size = taille)
  g <- g +
    annotate("text", x = 61, y = p0 + 16, label = "prix fixé", hjust = 0,
             colour = neutre, family = police_cours, size = taille * 0.85) +
    annotate("point", x = q0, y = p0, size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = q0 - 7, y = p0 + 16, label = "E", family = police_cours, size = taille)
  breaks_y <- p0; labels_y <- "P*"
  if (prix_libre && etape >= 4) {
    p1 <- eq_libre_ct$p; q1 <- eq_libre_ct$q
    g <- g +
      annotate("segment", x = 60, xend = q1, y = p1, yend = p1, linetype = "22", colour = neutre) +
      annotate("point", x = q1, y = p1, size = 3, shape = 21, fill = "white",
               colour = couleurs_eco[["equilibre"]], stroke = 1.2) +
      annotate("text", x = q1 + 7, y = p1 + 14, label = "E′ (prix libre)", hjust = 0,
               family = police_cours, size = taille * 0.85)
    breaks_y <- c(p0, p1); labels_y <- c("P*", "P*′")
  }
  g +
    annotate("text", x = c(68, 172, 122)[i_lab], y = c(200, 62, 330)[i_lab], label = c("D", "D′", "O")[i_lab],
             colour = couleurs_eco[c("demande", "demande", "offre")][i_lab], family = police_cours, size = taille) +
    scale_x_continuous(breaks = q0, labels = "Q*") +
    scale_y_continuous(breaks = breaks_y, labels = labels_y) +
    coord_cartesian(xlim = c(60, 190), ylim = c(0, 350), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q", y = "Prix P") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 4. Graphique de l'exemple 1 : même choc, offre rigide ou élastique
#    Graduations chiffrées assumées : la figure illustre l'exemple chiffré.
# ---------------------------------------------------------------------------

#' Deux panneaux : offre de court terme presque verticale (A) et offre de long
#' terme élastique (B). Même demande D -> D', même prix fixé de 75 €.
#' Point plein : prix fixé (E) ; point creux : équilibre si le prix était libre.
#' @param etape construction pas à pas pour les diapos : 1 = prix fixé et pénurie
#'   seulement ; 2 = ajoute l'équilibre libre du panneau A ; 3 = figure complète,
#'   identique à la page (défaut)
graphe_rigidite <- function(base_size = 16, etape = 3) {
  q <- seq(60, 190, length.out = 80)
  panneaux <- c("A. Offre rigide", "B. Offre plus élastique")
  courbes <- rbind(
    data.frame(panneau = panneaux[1], q = q, offre = (q - marche_cm3$oc_a) / marche_cm3$oc_s),
    data.frame(panneau = panneaux[2], q = q, offre = (q - marche_cm3$ol_a) / marche_cm3$ol_s)
  )
  courbes$demande  <- (marche_cm3$d_a - courbes$q) / marche_cm3$d_b
  courbes$demande2 <- (marche_cm3$d_a + marche_cm3$choc - courbes$q) / marche_cm3$d_b
  courbes$panneau <- factor(courbes$panneau, levels = panneaux)
  p0 <- marche_cm3$prix_fixe
  libres <- data.frame(panneau = factor(panneaux, levels = panneaux),
                       q = c(eq_libre_ct$q, eq_libre_lt$q), p = c(eq_libre_ct$p, eq_libre_lt$p))
  if (etape < 3) libres <- libres[seq_len(etape - 1), , drop = FALSE]   # aucun, puis A seul
  fixe <- data.frame(panneau = factor(panneaux, levels = panneaux), q = eq_initial$q, p = p0,
                     q_dem = qd_cm3(p0))
  etiquettes <- data.frame(
    panneau = factor(panneaux[c(1, 1, 1, 2, 2, 2)], levels = panneaux),
    # « O » posé à droite de l'offre (A) et au-dessus d'elle (B), pour ne pas toucher la courbe
    q = c(68, 174, 135, 68, 174, 172), p = c(200, 62, 330, 200, 62, 255),
    lab = c("D", "D′", "O", "D", "D′", "O"),
    col = unname(couleurs_eco[c("demande", "demande", "offre", "demande", "demande", "offre")])
  )
  neutre <- couleurs_eco[["neutre"]]
  ggplot(courbes, aes(q)) +
    geom_segment(data = libres, aes(x = q, xend = q, y = 0, yend = p), linetype = "22", colour = neutre) +
    geom_segment(data = libres, aes(x = 60, xend = q, y = p, yend = p), linetype = "22", colour = neutre) +
    geom_segment(data = fixe, aes(x = 60, xend = q, y = p, yend = p), linetype = "22", colour = neutre) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = demande2), colour = couleurs_eco[["demande"]], linewidth = 1.4, linetype = "22") +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    geom_segment(data = fixe, aes(x = q, xend = q_dem, y = p, yend = p),
                 colour = couleurs_eco[["alerte"]], linewidth = 1.6) +
    geom_point(data = fixe, aes(y = p), size = 2.6, colour = couleurs_eco[["equilibre"]]) +
    geom_point(data = libres, aes(y = p), size = 2.6, shape = 21, fill = "white",
               colour = couleurs_eco[["equilibre"]], stroke = 1.1) +
    geom_text(data = etiquettes, aes(x = q, y = p, label = lab, colour = col),
              family = police_cours, size = base_size / 3) +
    scale_colour_identity() +
    facet_wrap(~panneau, nrow = 1) +
    # 100 et 160 bornent la pénurie ; 120 et 145 : quantités des équilibres libres (A, B)
    scale_x_continuous(breaks = c(100, 120, 145, 160)) +
    scale_y_continuous(breaks = c(75, 150, 275)) +
    coord_cartesian(xlim = c(60, 190), ylim = c(0, 350), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q (milliers de boîtes par mois)", y = "Prix P (€ par boîte)") +
    theme_cours(base_size = base_size) +
    theme(strip.text = element_text(family = police_cours, hjust = 0, size = rel(0.85)),
          panel.spacing = grid::unit(1.5, "lines"),
          axis.text.x = element_text(size = rel(if (base_size > 16) 0.55 else 0.75)), axis.text.y = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 5. Graphique de données : boîtes d'aGLP-1 remboursées, 2020-2024
#    Assurance Maladie, Medic'AM, pharmacies de ville, tous prescripteurs.
#    Fichier et provenance : data/cm3/boites_aglp1_2020_2024.csv et data/cm3/SOURCES.md
#    (téléchargé le 21/10/2026).
# ---------------------------------------------------------------------------
boites_cm3 <- utils::read.csv(here::here("data/cm3/boites_aglp1_2020_2024.csv"))
boites_cm3$groupe <- ifelse(boites_cm3$produit %in% c("OZEMPIC", "TRULICITY", "VICTOZA"),
                            tools::toTitleCase(tolower(boites_cm3$produit)), "Autres")
total_cm3 <- tapply(boites_cm3$boites, boites_cm3$annee, sum)

#' Boîtes remboursées (en millions) d'un groupe de produits une année donnée
boites_groupe <- function(groupe, annee) {
  sum(boites_cm3$boites[boites_cm3$groupe == groupe & boites_cm3$annee == annee]) / 1e6
}

#' Barres empilées : boîtes d'analogues du GLP-1 remboursées par an et par produit, 2020-2024.
graphe_boites_aglp1 <- function(base_size = 16) {
  d <- aggregate(boites ~ annee + groupe, boites_cm3, sum)
  d$groupe <- factor(d$groupe, levels = c("Autres", "Victoza", "Trulicity", "Ozempic"))
  totaux <- data.frame(annee = as.integer(names(total_cm3)), total = as.numeric(total_cm3) / 1e6)
  virgule <- function(x, n = 1) formatC(x, format = "f", digits = n, decimal.mark = ",")
  ggplot(d, aes(factor(annee), boites / 1e6, fill = groupe)) +
    geom_col(width = 0.65) +
    geom_text(data = totaux, aes(factor(annee), total, label = virgule(total, 2)), inherit.aes = FALSE,
              vjust = -0.5, family = police_cours, size = base_size / 3.4, colour = couleurs_eco[["equilibre"]]) +
    scale_fill_manual(values = c(Ozempic = ordre_series[1], Trulicity = ordre_series[2],
                                 Victoza = ordre_series[3], Autres = ordre_series[4]),
                      breaks = c("Ozempic", "Trulicity", "Victoza", "Autres")) +
    scale_y_continuous(labels = function(x) virgule(x, 0), limits = c(0, 8.8), expand = c(0, 0)) +
    labs(x = NULL, y = "Boîtes (millions)",
         caption = paste("Source : Assurance Maladie, Medic'AM (téléchargé le 21/10/2026).",
                         "Pharmacies de ville, tous prescripteurs.",
                         "« Autres » : Byetta et Bydureon.", sep = "\n")) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 bis. Graphique de données : prix et quantité d'Ozempic, 2020-2024
#    Même fichier Medic'AM. Prix moyen d'une boîte = base de remboursement
#    totale / boîtes remboursées, toutes présentations (0,25, 0,5 et 1 mg).
# ---------------------------------------------------------------------------
ozempic_cm3 <- boites_cm3[boites_cm3$produit == "OZEMPIC", c("annee", "boites", "base_remboursement")]
ozempic_cm3$prix <- ozempic_cm3$base_remboursement / ozempic_cm3$boites

#' Trajectoire prix-quantité observée d'Ozempic : un point par année, relié au suivant.
#' Les points ne dessinent ni une offre ni une demande : ce sont des couples
#' (quantité vendue, prix) observés chaque année. L'axe des prix part de 0 pour
#' ne pas grossir des écarts de quelques euros.
graphe_prix_ozempic <- function(base_size = 16) {
  d <- ozempic_cm3[order(ozempic_cm3$annee), ]
  d$q <- d$boites / 1e6
  bleu <- couleurs_eco[["demande"]]   # Ozempic en azur, comme dans graphe_boites_aglp1()
  ggplot(d, aes(q, prix)) +
    geom_path(colour = bleu, linewidth = 0.8) +   # ordre des années : les étiquettes suffisent
    geom_point(colour = bleu, size = 2.8) +
    geom_text(aes(label = annee), vjust = -1.1, family = police_cours, size = base_size / 3.4,
              colour = couleurs_eco[["equilibre"]]) +
    scale_x_continuous(limits = c(0, 4), breaks = 0:4, expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), expand = c(0, 0)) +
    labs(x = "Boîtes d'Ozempic remboursées (millions)", y = "Prix moyen (€ par boîte)",
         caption = paste("Source : Assurance Maladie, Medic'AM,",
                         "téléchargé le 21/10/2026. Pharmacies de ville.",
                         "Prix moyen : base de remboursement / boîtes.", sep = "\n")) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

#' Nombre en français : virgule décimale, espace pour les milliers (sections 5 ter à 5 septies)
virgule_cm3 <- function(x, n = 0) formatC(x, format = "f", digits = n, decimal.mark = ",", big.mark = " ")

#' Légende de source sous le graphique, sur la page seulement : dans les diapos
#' (base_size > 16), la source est donnée par la ligne .wp-source de la diapo,
#' pour ne pas la répéter et garder la hauteur du graphique
legende_cm3 <- function(lignes, base_size = 16) {
  if (base_size > 16) NULL else paste(lignes, collapse = "\n")
}

# ---------------------------------------------------------------------------
# 5 ter. Graphique de données : boîtes d'aGLP-1 du diabète remboursées chaque mois,
#    janvier 2022 à juin 2026 (dernier mois du fichier semestriel 2026-01-a-06).
#    Assurance Maladie, Medic'AM mensuel, pharmacies de ville, tous prescripteurs.
#    Fichier et provenance : data/cm3/boites_aglp1_mensuel_2022_2026.csv et
#    data/cm3/SOURCES.md (téléchargé le 22/10/2026). Wegovy (obésité) et Mounjaro
#    (obésité et diabète de type 2), remboursés depuis le 15/06/2026, sont exclus :
#    même champ que fig-boites.
# ---------------------------------------------------------------------------
mensuel_cm3 <- utils::read.csv(here::here("data/cm3/boites_aglp1_mensuel_2022_2026.csv"))
mensuel_cm3 <- aggregate(boites ~ mois, mensuel_cm3[!grepl("^(WEGOVY|MOUNJARO)", mensuel_cm3$produit), ], sum)
mensuel_cm3$date <- as.Date(paste0(mensuel_cm3$mois, "-01"))

#' Somme des boîtes mensuelles du mois `debut` au mois `fin` inclus (AAAA-MM)
boites_periode <- function(debut, fin) sum(mensuel_cm3$boites[mensuel_cm3$mois >= debut & mensuel_cm3$mois <= fin])

#' Courbe mensuelle du total, avec une bande rouge pâle pour la pénurie
#' (de décembre 2023 au 05/06/2025, d'après l'ANSM) ; dernier point étiqueté.
graphe_boites_mois <- function(base_size = 16) {
  taille <- base_size / 3.4
  fin <- mensuel_cm3[nrow(mensuel_cm3), ]
  ggplot(mensuel_cm3, aes(date, boites / 1e3)) +
    annotate("rect", xmin = as.Date("2023-12-01"), xmax = as.Date("2025-06-05"), ymin = 0, ymax = Inf,
             fill = couleurs_eco[["alerte"]], alpha = 0.08) +
    annotate("text", x = as.Date("2024-09-01"), y = 1040, label = "pénurie : nouveaux traitements\nlimités par l'ANSM",
             family = police_cours, size = taille, colour = couleurs_eco[["alerte"]], lineheight = 0.9) +
    geom_line(colour = couleurs_eco[["demande"]], linewidth = 0.9) +
    annotate("text", x = fin$date + 25, y = fin$boites / 1e3, label = virgule_cm3(fin$boites / 1e3),
             hjust = 0, family = police_cours, size = taille, colour = couleurs_eco[["demande"]]) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y",
                 expand = expansion(mult = c(0.01, if (base_size > 16) 0.1 else 0.07))) +
    scale_y_continuous(limits = c(0, if (base_size > 16) 1180 else 1120), breaks = seq(0, 1000, 200), labels = virgule_cm3, expand = c(0, 0)) +
    labs(x = NULL, y = if (base_size > 16) "Boîtes par mois (milliers)" else "Boîtes remboursées par mois (milliers)",
         caption = legende_cm3(c("Source : Assurance Maladie, Medic'AM mensuel (téléchargé le 22/10/2026).",
                         "Analogues du GLP-1 du diabète, pharmacies de ville.",
                         "Zone rouge : de décembre 2023 au 05/06/2025 (ANSM)."), base_size)) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 quater. Graphique de données : part de la base de remboursement payée par
#    l'Assurance maladie, Ozempic, Trulicity et Victoza, année 2025 (somme des 12 mois).
#    Medic'AM mensuel : « Montant remboursé » / « Base de remboursement ».
#    Fichier et provenance : data/cm3/part_remboursee_aglp1_2025.csv et data/cm3/SOURCES.md.
# ---------------------------------------------------------------------------
part_cm3 <- utils::read.csv(here::here("data/cm3/part_remboursee_aglp1_2025.csv"))
part_cm3$part <- 100 * part_cm3$montant_rembourse / part_cm3$base_remboursement
part_cm3$produit <- factor(tools::toTitleCase(tolower(part_cm3$produit)), levels = c("Victoza", "Trulicity", "Ozempic"))

#' Barres horizontales empilées : part payée par l'Assurance maladie (azur) et reste (gris)
graphe_part_remboursee <- function(base_size = 16) {
  taille <- base_size / 3.4
  d <- rbind(data.frame(produit = part_cm3$produit, qui = "am", part = part_cm3$part),
             data.frame(produit = part_cm3$produit, qui = "reste", part = 100 - part_cm3$part))
  d$qui <- factor(d$qui, levels = c("reste", "am"))
  ggplot(d, aes(part, produit, fill = qui)) +
    geom_col(width = 0.6) +
    geom_text(data = part_cm3, aes(x = part / 2, y = produit, label = paste(virgule_cm3(part, 1), "%")),
              inherit.aes = FALSE, family = police_cours, size = taille, colour = "white") +
    annotate("text", x = 50, y = 3.48, label = "payé par l'Assurance maladie", family = police_cours,
             size = taille, colour = couleurs_eco[["demande"]]) +
    annotate("text", x = 100.5, y = 3.48, label = "reste", hjust = 1, family = police_cours,
             size = taille, colour = couleurs_eco[["neutre"]]) +
    scale_fill_manual(values = c(am = couleurs_eco[["demande"]], reste = "#D1D5DB")) +
    scale_x_continuous(limits = c(0, 101), breaks = seq(0, 100, 25), expand = c(0, 0)) +
    labs(x = "Part de la base de remboursement (%)", y = NULL,
         caption = legende_cm3(c("Source : Assurance Maladie, Medic'AM mensuel, année 2025",
                         "(téléchargé le 22/10/2026). Montant remboursé / base de remboursement."), base_size)) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          axis.line.x = element_blank(), plot.margin = margin(10, 22, 8, 8),
          plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 quinquies. Graphique de données : patients sous Ozempic, France et États-Unis
#    (Medicare Part D), 2020-2024, en indice (2020 = 100).
#    France : Open Medic (A10BJ06, nombre de consommants) ; États-Unis : CMS,
#    Medicare Part D Spending by Drug (Tot_Benes). Champs différents : on compare
#    des croissances, pas des niveaux.
#    Fichier et provenance : data/cm3/patients_ozempic_fr_us_2020_2024.csv et data/cm3/SOURCES.md.
# ---------------------------------------------------------------------------
patients_fr_us_cm3 <- utils::read.csv(here::here("data/cm3/patients_ozempic_fr_us_2020_2024.csv"), encoding = "UTF-8")
base_2020_cm3 <- with(patients_fr_us_cm3[patients_fr_us_cm3$annee == 2020, ], setNames(patients, pays))
patients_fr_us_cm3$indice <- 100 * patients_fr_us_cm3$patients / base_2020_cm3[patients_fr_us_cm3$pays]

#' Deux courbes en indice, étiquetées en bout de trait avec le coefficient multiplicateur
graphe_patients_fr_us <- function(base_size = 16) {
  taille <- base_size / 3.4
  fins <- patients_fr_us_cm3[patients_fr_us_cm3$annee == 2024, ]
  fins$label <- paste0(ifelse(fins$pays == "France", "France", "États-Unis\n(Medicare)"),
                       " : × ", virgule_cm3(fins$indice / 100, 1))
  ggplot(patients_fr_us_cm3, aes(annee, indice, colour = pays)) +
    geom_hline(yintercept = 100, colour = couleurs_eco[["neutre"]], linetype = "22", linewidth = 0.4) +
    geom_line(linewidth = 1) +
    geom_point(size = base_size / 7) +
    geom_text(data = fins, aes(label = label), hjust = 0, nudge_x = 0.12, family = police_cours,
              size = taille, lineheight = 0.9) +
    scale_colour_manual(values = c(France = couleurs_eco[["demande"]], `États-Unis (Medicare)` = couleurs_eco[["offre"]])) +
    scale_x_continuous(breaks = 2020:2024, limits = c(2020, if (base_size > 16) 2026.2 else 2025.4)) +
    scale_y_continuous(limits = c(0, 800), breaks = seq(0, 800, 200), labels = virgule_cm3, expand = c(0, 0)) +
    labs(x = NULL, y = if (base_size > 16) "Patients (indice, 2020 = 100)" else "Patients sous Ozempic (indice, 2020 = 100)",
         caption = legende_cm3(c("Sources : Assurance Maladie, Open Medic (patients remboursés) ;",
                         "CMS, Medicare Part D Spending by Drug (bénéficiaires).",
                         "Téléchargé le 22/10/2026. États-Unis : Medicare Part D seulement."), base_size)) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 sexies. Graphique de données (encadré méthode) : prix d'une boîte de Wegovy,
#    en euros TTC hors honoraire. Indemnité d'accès précoce fixée par le
#    laboratoire (HAS, avis CEESP du 15/07/2025) contre prix fixés par l'État à
#    compter du 15/06/2026 (avis de prix, JORF du 28/05/2026 ; BDPM du 22/10/2026),
#    et Ozempic 1 mg pour rappel.
#    Fichier et provenance : data/cm3/prix_boite_wegovy.csv et data/cm3/SOURCES.md.
# ---------------------------------------------------------------------------
prix_wegovy_cm3 <- utils::read.csv(here::here("data/cm3/prix_boite_wegovy.csv"), fileEncoding = "UTF-8")
# Étiquettes et couleurs associées par présentation (pas par rang de ligne du CSV)
etiquettes_wegovy <- c(`Wegovy, accès précoce` = "Wegovy, accès précoce\n(laboratoire, 2022-2023)",
                       `Wegovy 2,4 mg` = "Wegovy 2,4 mg\n(État, 15/06/2026)",
                       `Wegovy 0,25 à 1 mg` = "Wegovy 0,25 à 1 mg\n(État, 15/06/2026)",
                       `Ozempic 1 mg` = "Ozempic 1 mg\n(État, rappel)")
couleurs_wegovy <- c(`Wegovy, accès précoce` = "alerte", `Wegovy 2,4 mg` = "demande",
                     `Wegovy 0,25 à 1 mg` = "demande", `Ozempic 1 mg` = "neutre")
stopifnot(setequal(prix_wegovy_cm3$presentation, names(etiquettes_wegovy)))
prix_wegovy_cm3$etiquette <- factor(etiquettes_wegovy[prix_wegovy_cm3$presentation], levels = rev(etiquettes_wegovy))
prix_wegovy_cm3$couleur <- unname(couleurs_eco[couleurs_wegovy[prix_wegovy_cm3$presentation]])
prix_w <- setNames(prix_wegovy_cm3$prix, prix_wegovy_cm3$presentation)

#' Barres horizontales : un prix par boîte, valeur en bout de barre ; rouge = prix
#' du laboratoire, azur = prix fixés par l'État, gris = rappel d'Ozempic
graphe_prix_wegovy <- function(base_size = 16) {
  ggplot(prix_wegovy_cm3, aes(prix, etiquette)) +
    geom_col(aes(fill = I(couleur)), width = 0.6) +
    geom_text(aes(label = paste(virgule_cm3(prix, 2), "€")), hjust = -0.1,
              family = police_cours, size = base_size / 3.4, colour = couleurs_eco[["equilibre"]]) +
    scale_x_continuous(limits = c(0, 500), breaks = seq(0, 500, 100), expand = c(0, 0)) +
    coord_cartesian(clip = "off") +
    labs(x = "Prix d'une boîte (€ TTC)", y = NULL,
         caption = legende_cm3(c("Sources : JORF du 28/05/2026 (avis de prix) ; BDPM (22/10/2026) ;",
                         "HAS, avis CEESP du 15/07/2025 (indemnité d'accès précoce)."), base_size)) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          axis.line.x = element_blank(), axis.line.y = element_blank(),
          plot.caption.position = "plot", plot.margin = margin(10, 60, 8, 8),
          plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 septies. Graphique de données (encadré méthode) : boîtes de Wegovy et de
#    Mounjaro remboursées chaque mois, janvier à août 2026 (dernier mois publié).
#    Medic'AM mensuel. Le zéro de janvier à mai n'est pas une absence de ventes :
#    les ventes sans remboursement (possibles depuis 2024) n'y figurent pas.
#    Mounjaro mêle obésité et diabète de type 2 (arrêté du 10/06/2026).
#    Ozempic n'est pas tracé (il écraserait l'échelle) : cité dans le fig-cap.
#    Fichier et provenance : data/cm3/boites_wegovy_mounjaro_ozempic_mensuel.csv et data/cm3/SOURCES.md.
# ---------------------------------------------------------------------------
glp1_2026_cm3 <- utils::read.csv(here::here("data/cm3/boites_wegovy_mounjaro_ozempic_mensuel.csv"))
wegovy_cm3 <- glp1_2026_cm3[glp1_2026_cm3$produit %in% c("Wegovy", "Mounjaro") & glp1_2026_cm3$mois >= "2026-01", ]
wegovy_cm3$date <- as.Date(paste0(wegovy_cm3$mois, "-15"))   # milieu du mois : le point de juin tombe sur le 15/06
remboursement_wegovy <- as.Date("2026-06-15")

#' Boîtes remboursées par mois, en milliers : zéro jusqu'en mai, puis hausse après le 15 juin.
#' Le trait est coupé entre mai et juin : un segment du 15/05 au 15/06 suggérerait
#' des boîtes remboursées fin mai.
graphe_boites_wegovy <- function(base_size = 16) {
  taille <- base_size / 3.4
  fin <- wegovy_cm3[wegovy_cm3$mois == max(wegovy_cm3$mois), ]
  ggplot(wegovy_cm3, aes(date, boites / 1e3, colour = produit)) +
    geom_vline(xintercept = remboursement_wegovy, linetype = "dashed", colour = couleurs_eco[["neutre"]]) +
    annotate("text", x = remboursement_wegovy - 6, y = 78, label = "remboursement\nà 65 % (15/06)", hjust = 1,
             lineheight = 0.9, family = police_cours, size = taille, colour = couleurs_eco[["neutre"]]) +
    geom_line(aes(group = interaction(produit, mois >= "2026-06")), linewidth = 0.9) +
    geom_point(size = base_size / 8) +
    geom_text(data = fin, aes(label = paste0(produit, "\n", virgule_cm3(boites / 1e3, 1))),
              hjust = 0, nudge_x = 7, lineheight = 0.9, family = police_cours, size = taille) +
    scale_colour_manual(values = c(Mounjaro = couleurs_eco[["offre"]], Wegovy = couleurs_eco[["demande"]])) +
    scale_x_date(breaks = seq(as.Date("2026-01-15"), as.Date("2026-08-15"), "month"),
                 labels = c("janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août"),
                 expand = expansion(mult = c(0.02, if (base_size > 16) 0.27 else 0.16))) +
    scale_y_continuous(limits = c(0, 85), breaks = seq(0, 80, 20), labels = virgule_cm3, expand = c(0, 0)) +
    labs(x = "Mois de remboursement (2026)",
         y = if (base_size > 16) "Boîtes (milliers par mois)" else "Boîtes remboursées (milliers par mois)",
         caption = legende_cm3(c("Source : Assurance Maladie, Medic'AM mensuel (téléchargé le 22/10/2026).",
                         "Pharmacies de ville, tous prescripteurs. Juin : 15 jours de remboursement."), base_size)) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", plot.caption = element_text(margin = margin(t = 10)),
          axis.text.x = element_text(size = rel(if (base_size > 16) 0.8 else 1)))
}

# ---------------------------------------------------------------------------
# 6. Vérifications : chaque chiffre annoncé dans cours/cm3.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# Exemple 1 : marché fictif
stopifnot(
  proche(eq_initial$p, 75), proche(eq_initial$q, 100),                         # E : 75 €, 100
  proche(qo_cm3(75, long_terme = TRUE), 100),                                  # à 75 €, même l'offre de long terme reste à 100 : seul O -> O' referme la pénurie
  proche(qd_cm3(75), 160), proche(qo_cm3(75), 100), proche(penurie_cm3, 60),   # pénurie de 60
  proche(100 * penurie_cm3 / qd_cm3(75), 37.5),                                # 37,5 % des demandes non servies
  # tableau de l'exemple : D, D' et O de court terme aux prix 75, 125, 175, 225, 275
  all(proche(qd_cm3(seq(75, 275, 50), apres = FALSE), c(100, 90, 80, 70, 60))),
  all(proche(qd_cm3(seq(75, 275, 50)), c(160, 150, 140, 130, 120))),
  all(proche(qo_cm3(seq(75, 275, 50)), c(100, 105, 110, 115, 120))),
  proche(eq_libre_ct$p, 275), proche(eq_libre_ct$q, 120),                      # prix libre, court terme
  proche(round(var_pct_cm3(75, 275)), 267), proche(var_pct_cm3(100, 120), 20),
  proche(eq_libre_ct$q - 100, 20), proche(qd_cm3(75) - eq_libre_ct$q, 40),     # +20 produites, 40 exclues
  proche(eq_libre_lt$p, 150), proche(eq_libre_lt$q, 145),                      # prix libre, long terme
  proche(var_pct_cm3(75, 150), 100), proche(var_pct_cm3(100, 145), 45),
  proche(qd_cm3(75) - eq_libre_lt$q, 15),                                      # 15 exclues
  # élasticité-prix de la demande entre 75 € et 125 € : -10 % / +66,7 % = -0,15
  proche(round(var_pct_cm3(100, 90) / var_pct_cm3(75, 125), 2), -0.15)
)
# Exemple 2 : règles de rationnement
file_cm3 <- rationner_cm3("file"); prio_cm3 <- rationner_cm3("priorite")
stopifnot(
  sum(patients_cm3) == qd_cm3(75), proche(sum(file_cm3), 100), proche(sum(prio_cm3), 100),
  proche(file_cm3[["deja_traites"]], 50), proche(file_cm3[["hors_indication"]], 18.75),
  proche(file_cm3[["nouveaux_atherome"]], 12.5),
  proche(prio_cm3[["deja_traites"]], 80), proche(prio_cm3[["nouveaux_atherome"]], 20),
  proche(prio_cm3[["hors_indication"]], 0), proche(prio_cm3[["nouveaux_autres"]], 0)
)
# Données Medic'AM : totaux annuels et variations citées dans le texte et le fig-cap
stopifnot(
  nrow(boites_cm3) == 25, !anyNA(boites_cm3$boites),
  total_cm3[["2022"]] == 6248150, total_cm3[["2023"]] == 7481028, total_cm3[["2024"]] == 7488154,
  proche(round(var_pct_cm3(total_cm3[["2022"]], total_cm3[["2023"]]), 1), 19.7),
  proche(round(var_pct_cm3(total_cm3[["2023"]], total_cm3[["2024"]]), 1), 0.1),
  proche(round(boites_groupe("Ozempic", 2020), 2), 0.75), proche(round(boites_groupe("Ozempic", 2024), 2), 3.64),
  proche(round(var_pct_cm3(boites_groupe("Ozempic", 2023), boites_groupe("Ozempic", 2024)), 1), 24.6),
  proche(round(var_pct_cm3(boites_groupe("Trulicity", 2023), boites_groupe("Trulicity", 2024)), 1), -7.7),
  proche(round(var_pct_cm3(boites_groupe("Victoza", 2023), boites_groupe("Victoza", 2024)), 1), -49.8),
  proche(round(total_cm3[["2020"]] / 1e6, 2), 4.29)
)
# Données Medic'AM : prix moyen d'une boîte d'Ozempic (texte et fig-cap de fig-prix-ozempic)
prix_oz <- setNames(ozempic_cm3$prix, ozempic_cm3$annee)
stopifnot(
  nrow(ozempic_cm3) == 5, !anyNA(ozempic_cm3$base_remboursement),
  proche(round(prix_oz[["2020"]], 1), 80.0), proche(round(prix_oz[["2024"]], 1), 77.8),
  all(prix_oz > 77 & prix_oz < 81),                                            # « entre 77 et 81 € chaque année »
  proche(round(var_pct_cm3(prix_oz[["2020"]], prix_oz[["2024"]]), 1), -2.7),   # prix : -2,7 %
  proche(round(boites_groupe("Ozempic", 2024) / boites_groupe("Ozempic", 2020), 1), 4.9), # boîtes x 4,9
  all(proche(round(sapply(2021:2023, boites_groupe, groupe = "Ozempic"), 2), c(1.39, 2.03, 2.92)))  # fig-alt
)
# Recette mensuelle du vendeur dans l'exemple 1 (milliers de boîtes x € = milliers d'euros)
stopifnot(proche(eq_initial$q * marche_cm3$prix_fixe, 7500), proche(eq_libre_ct$q * eq_libre_ct$p, 33000))
# Medic'AM mensuel (fig-boites-mois) : valeurs du texte et du fig-cap
mois_cm3 <- setNames(mensuel_cm3$boites, mensuel_cm3$mois)
plateau_cm3 <- mensuel_cm3$boites[mensuel_cm3$mois >= "2023-10" & mensuel_cm3$mois <= "2024-09"]
stopifnot(
  nrow(mensuel_cm3) == 54,
  mois_cm3[["2023-10"]] == 682314, mois_cm3[["2024-09"]] == 593468, mois_cm3[["2026-06"]] == 959502,
  min(plateau_cm3) == 556910, max(plateau_cm3) == 682314,                      # « entre 557 000 et 682 000 »
  boites_periode("2024-01", "2024-12") == total_cm3[["2024"]],                # mensuel = annuel (7 488 154)
  proche(round(boites_periode("2022-10", "2023-09") / 1e6, 2), 7.18),
  proche(round(boites_periode("2023-10", "2024-09") / 1e6, 2), 7.46),
  proche(round(boites_periode("2024-10", "2025-09") / 1e6, 2), 8.43),
  proche(round(var_pct_cm3(boites_periode("2022-10", "2023-09"), boites_periode("2023-10", "2024-09")), 1), 3.8),
  proche(round(var_pct_cm3(boites_periode("2023-10", "2024-09"), boites_periode("2024-10", "2025-09")), 1), 13.1)
)
# Medic'AM 2025 (fig-part-remboursee) : part payée par l'Assurance maladie
part_oz <- setNames(part_cm3$part, as.character(part_cm3$produit))
stopifnot(
  proche(round(part_oz[["Ozempic"]], 1), 95.7), proche(round(part_oz[["Trulicity"]], 1), 98.4),
  proche(round(part_oz[["Ozempic"]], 2), 95.74),                              # fig-cap : 95,74 € et 4,26 €
  proche(round(part_oz[["Victoza"]], 1), 98.2)
)
# Open Medic et CMS (fig-patients-fr-us) : coefficients multiplicateurs 2020-2024
indice_2024 <- setNames(patients_fr_us_cm3$indice[patients_fr_us_cm3$annee == 2024],
                        patients_fr_us_cm3$pays[patients_fr_us_cm3$annee == 2024])
stopifnot(
  nrow(patients_fr_us_cm3) == 10, !anyNA(patients_fr_us_cm3$patients),
  proche(round(indice_2024[["France"]] / 100, 1), 4.5), proche(round(indice_2024[["États-Unis (Medicare)"]] / 100, 1), 7.2)
)
# Encadré méthode (fig-prix-wegovy, fig-boites-wegovy) : prix et boîtes de 2026
stopifnot(
  nrow(prix_wegovy_cm3) == 4, nrow(wegovy_cm3) == 16,
  proche(prix_w[["Wegovy, accès précoce"]], 431.41), proche(prix_w[["Wegovy 2,4 mg"]], 195.10),
  proche(prix_w[["Wegovy 0,25 à 1 mg"]], 146.91), proche(prix_w[["Ozempic 1 mg"]], 76.58),
  proche(round(prix_w[["Wegovy, accès précoce"]] / prix_w[["Wegovy 2,4 mg"]], 1), 2.2),       # « 2,2 à 2,9 fois »
  proche(round(prix_w[["Wegovy, accès précoce"]] / prix_w[["Wegovy 0,25 à 1 mg"]], 1), 2.9),
  all(wegovy_cm3$boites[wegovy_cm3$mois < "2026-06"] == 0),                   # zéro de janvier à mai
  wegovy_cm3$boites[wegovy_cm3$produit == "Wegovy" & wegovy_cm3$mois == "2026-08"] == 20416,
  wegovy_cm3$boites[wegovy_cm3$produit == "Mounjaro" & wegovy_cm3$mois == "2026-08"] == 70996,
  glp1_2026_cm3$boites[glp1_2026_cm3$produit == "Ozempic" & glp1_2026_cm3$mois == "2026-08"] == 483620
)
