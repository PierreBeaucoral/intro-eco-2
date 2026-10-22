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
graphe_penurie <- function(prix_libre = TRUE, base_size = 16) {
  q <- seq(60, 190, length.out = 80)
  d <- data.frame(q = q,
                  demande  = (marche_cm3$d_a - q) / marche_cm3$d_b,
                  demande2 = (marche_cm3$d_a + marche_cm3$choc - q) / marche_cm3$d_b,
                  offre    = (q - marche_cm3$oc_a) / marche_cm3$oc_s)
  p0 <- marche_cm3$prix_fixe; q0 <- eq_initial$q
  q_dem <- qd_cm3(p0)
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  g <- ggplot(d, aes(q)) +
    annotate("segment", x = c(q0, 60), xend = c(q0, q_dem), y = c(0, p0), yend = c(p0, p0),
             linetype = "22", colour = neutre) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = demande2), colour = couleurs_eco[["demande"]], linewidth = 1.4, linetype = "22") +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    # flèche du déplacement de la demande, vers la droite
    annotate("segment", x = 90, xend = 140, y = 210, yend = 210,
             colour = couleurs_eco[["demande"]], linewidth = 0.7,
             arrow = grid::arrow(length = grid::unit(0.25, "cm"), type = "closed")) +
    # la pénurie au prix fixé : de l'offre à la nouvelle demande
    annotate("segment", x = q0, xend = q_dem, y = p0, yend = p0,
             colour = couleurs_eco[["alerte"]], linewidth = 1.8) +
    annotate("text", x = (q0 + q_dem) / 2, y = p0 - 22, label = "pénurie",
             colour = couleurs_eco[["alerte"]], family = police_cours, size = taille) +
    annotate("text", x = 61, y = p0 + 16, label = "prix fixé", hjust = 0,
             colour = neutre, family = police_cours, size = taille * 0.85) +
    annotate("point", x = q0, y = p0, size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = q0 - 7, y = p0 + 16, label = "E", family = police_cours, size = taille)
  breaks_y <- p0; labels_y <- "P*"
  if (prix_libre) {
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
    annotate("text", x = c(68, 172, 122), y = c(200, 62, 330), label = c("D", "D′", "O"),
             colour = couleurs_eco[c("demande", "demande", "offre")], family = police_cours, size = taille) +
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
graphe_rigidite <- function(base_size = 16) {
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
