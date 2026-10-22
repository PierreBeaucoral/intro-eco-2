# cm4.R · graphiques du CM 4 (encadrement des loyers ; le SMIC en miroir),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm4.qmd sont définies ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.
# Notation (guide § 6, à valider) : Pmax = prix plafond, Pmin = prix plancher,
# Qo et Qd = quantités offerte et demandée au prix réglementé.

# ---------------------------------------------------------------------------
# 1. Le marché fictif de l'exemple chiffré (Exemple 1 de la page)
#    Q en milliers de logements, P = loyer mensuel en euros.
#    Demande                         : Qd = 200 - 0,1 P   (soit P = 2 000 - 10 Q)
#    Offre de long terme (élastique) : Qo = 0,1 P         (soit P = 10 Q)
#    Offre de court terme (rigide)   : Qo = 80 + 0,02 P
#    Plafond                         : Pmax = 800 €
#    Une aire en (milliers de logements x euros par mois) se lit en milliers
#    d'euros par mois : 4 000 = 4 millions d'euros par mois.
# ---------------------------------------------------------------------------
marche_cm4 <- list(
  d_a = 200, d_b = 0.1,         # demande
  lt_a = 0, lt_b = 0.1,         # offre de long terme
  ct_a = 80, ct_b = 0.02,       # offre de court terme
  plafond = 800
)

#' Prix que les locataires sont prêts à payer pour le q-ième logement (demande inverse)
prix_demande_cm4 <- function(q) (marche_cm4$d_a - q) / marche_cm4$d_b

#' Bilan d'un prix plafond sur un marché à demande et offre linéaires.
#' Hypothèse : les logements restants vont aux locataires qui les valorisent le
#' plus (cas le plus favorable ; sinon la perte est plus grande).
#' @param a,b offre Qo = a + b P
#' @return liste : équilibre (p_eq, q_eq), quantités au plafond (qo, qd),
#'   pénurie, prix de demande du dernier logement loué (pd), transfert des
#'   bailleurs vers les locataires logés, perte sèche, variations de surplus
bilan_plafond_cm4 <- function(a, b, pmax = marche_cm4$plafond) {
  p_eq <- (marche_cm4$d_a - a) / (marche_cm4$d_b + b)
  q_eq <- marche_cm4$d_a - marche_cm4$d_b * p_eq
  qo <- a + b * pmax
  qd <- marche_cm4$d_a - marche_cm4$d_b * pmax
  pd <- prix_demande_cm4(qo)
  transfert <- (p_eq - pmax) * qo
  perte <- 0.5 * (q_eq - qo) * (pd - pmax)   # triangle : offre et demande linéaires
  p0 <- prix_demande_cm4(0)                   # prix au-delà duquel plus personne ne loue
  sc_avant <- 0.5 * q_eq * (p0 - p_eq)
  sc_apres <- 0.5 * qo * (p0 - pd) + qo * (pd - pmax)
  list(p_eq = p_eq, q_eq = q_eq, qo = qo, qd = qd, penurie = qd - qo, pd = pd,
       transfert = transfert, perte = perte,
       delta_sc = sc_apres - sc_avant)
}

bilan_lt_cm4 <- bilan_plafond_cm4(marche_cm4$lt_a, marche_cm4$lt_b)
bilan_ct_cm4 <- bilan_plafond_cm4(marche_cm4$ct_a, marche_cm4$ct_b)

# Surplus des bailleurs à long terme (offre P = 10 Q, qui part de l'origine) :
# avant = 1/2 x 100 x 1 000 ; après = 1/2 x 80 x 800.
sp_avant_lt_cm4 <- 0.5 * bilan_lt_cm4$q_eq * bilan_lt_cm4$p_eq
sp_apres_lt_cm4 <- 0.5 * bilan_lt_cm4$qo * marche_cm4$plafond
sc_avant_lt_cm4 <- 0.5 * bilan_lt_cm4$q_eq * (prix_demande_cm4(0) - bilan_lt_cm4$p_eq)

# ---------------------------------------------------------------------------
# 2. Graphique théorique : prix plafond contraignant
# ---------------------------------------------------------------------------

#' Plafond Pmax sous P* : pénurie (Qd - Qo), transfert des bailleurs vers les
#' locataires logés (rectangle bleu) et perte sèche (triangle rouge).
#' Géométrie de l'exemple de long terme, mais axes sans graduations chiffrées.
#' @param aires si FALSE, ne montre que la pénurie (équivaut à etape = 2)
#' @param base_size 16 (page) ou 24 (diapos)
#' @param etape construction pas à pas pour les diapos : 1 = équilibre initial
#'   (D, O, E) ; 2 = ajoute le plafond, Qo, Qd et la pénurie ; 3 = ajoute le
#'   rectangle de transfert ; 4 = ajoute la perte sèche, figure de la page (défaut)
graphe_plafond <- function(aires = TRUE, base_size = 16, etape = 4) {
  if (!aires) etape <- min(etape, 2)
  b <- bilan_lt_cm4
  pmax <- marche_cm4$plafond
  q <- seq(0, 175, length.out = 60)
  d <- data.frame(q = q, demande = prix_demande_cm4(q), offre = q / marche_cm4$lt_b)
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  alerte <- couleurs_eco[["alerte"]]
  i_tir <- if (etape >= 2) 1:4 else c(2, 4)    # tirets vers Q* et P* (puis Qo, Qd)
  i_x <- if (etape >= 2) 1:3 else 2            # graduations Q* (puis Qo, Qd)
  i_y <- if (etape >= 2) 1:2 else 2            # graduations P* (puis Pmax)
  g <- ggplot(d, aes(q))
  if (etape >= 3) g <- g +
    annotate("rect", xmin = 0, xmax = b$qo, ymin = pmax, ymax = b$p_eq,
             fill = couleurs_eco[["demande"]], alpha = 0.18)
  if (etape >= 4) g <- g +
    annotate("polygon", x = c(b$qo, b$qo, b$q_eq), y = c(pmax, b$pd, b$p_eq),
             fill = alerte, alpha = 0.35)
  if (etape >= 3) g <- g +
    annotate("text", x = b$qo / 2, y = (pmax + b$p_eq) / 2, label = "transfert",
             family = police_cours, size = taille * 0.9, colour = couleurs_eco[["demande"]])
  if (etape >= 4) g <- g +
    annotate("text", x = b$qo + 12, y = 1650, label = "perte sèche",
             family = police_cours, size = taille * 0.9, colour = alerte, hjust = 0) +
    annotate("segment", x = b$qo + 14, xend = b$qo + 7, y = 1610, yend = 1060,
             colour = alerte, linewidth = 0.5,
             arrow = grid::arrow(length = grid::unit(0.18, "cm"), type = "closed"))
  g <- g +
    annotate("segment", x = c(b$qo, b$q_eq, b$qd, 0)[i_tir], xend = c(b$qo, b$q_eq, b$qd, b$q_eq)[i_tir],
             y = c(0, 0, 0, b$p_eq)[i_tir], yend = c(b$pd, b$p_eq, pmax, b$p_eq)[i_tir],
             linetype = "22", colour = neutre)
  if (etape >= 2) g <- g +
    annotate("segment", x = 0, xend = 175, y = pmax, yend = pmax,
             colour = couleurs_eco[["equilibre"]], linewidth = 0.8)
  g <- g +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    annotate("segment", x = b$qo, xend = b$qd, y = pmax, yend = pmax,
             colour = alerte, linewidth = 1.8) +
    annotate("text", x = (b$qo + b$qd) / 2, y = pmax - 110, label = "pénurie",
             colour = alerte, family = police_cours, size = taille) +
    annotate("text", x = 174, y = pmax + 80, label = "plafond", hjust = 1,
             family = police_cours, size = taille * 0.9)
  g +
    annotate("point", x = b$q_eq, y = b$p_eq, size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = b$q_eq + 7, y = b$p_eq - 70, label = "E", family = police_cours, size = taille) +
    annotate("text", x = c(158, 163), y = c(260, 1790), label = c("D", "O"),
             colour = couleurs_eco[c("demande", "offre")], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(b$qo, b$q_eq, b$qd)[i_x], labels = c("Qo", "Q*", "Qd")[i_x]) +
    scale_y_continuous(breaks = c(pmax, b$p_eq)[i_y], labels = c("Pmax", "P*")[i_y]) +
    coord_cartesian(xlim = c(0, 175), ylim = c(0, 2100), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q (logements loués)", y = "Prix P (loyer)") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 3. Graphique de l'exemple : même plafond, court terme et long terme
# ---------------------------------------------------------------------------

#' Deux panneaux : offre rigide (court terme, à gauche) et offre élastique
#' (long terme, à droite), même demande, même plafond de 800 €.
#' Graduations chiffrées assumées : la figure illustre l'exemple chiffré.
#' @param etape diapos : 1 = pénurie seule ; 2 = ajoute les triangles de perte
#'   sèche, figure de la page (défaut)
graphe_court_long <- function(base_size = 16, etape = 2) {
  panneaux <- c("A. Court terme : offre rigide", "B. Long terme : offre élastique")
  if (base_size > 16) panneaux <- c("A. Court terme", "B. Long terme")   # diapos : titres courts
  q <- seq(70, 130, length.out = 61)
  d <- rbind(
    data.frame(panneau = panneaux[1], q = q, offre = (q - marche_cm4$ct_a) / marche_cm4$ct_b),
    data.frame(panneau = panneaux[2], q = q, offre = (q - marche_cm4$lt_a) / marche_cm4$lt_b)
  )
  d$demande <- prix_demande_cm4(d$q)
  d$panneau <- factor(d$panneau, levels = panneaux)
  bl <- list(bilan_ct_cm4, bilan_lt_cm4)
  pmax <- marche_cm4$plafond
  tri <- do.call(rbind, lapply(1:2, function(i) data.frame(
    panneau = factor(panneaux[i], levels = panneaux),
    q = c(bl[[i]]$qo, bl[[i]]$qo, bl[[i]]$q_eq), p = c(pmax, bl[[i]]$pd, bl[[i]]$p_eq))))
  pen <- data.frame(panneau = factor(panneaux, levels = panneaux),
                    qo = sapply(bl, `[[`, "qo"), qd = sapply(bl, `[[`, "qd"))
  etiq <- data.frame(
    panneau = factor(panneaux[c(1, 1, 1, 2, 2, 2)], levels = panneaux),
    q = c(124, 111, 82, 124, 127, 87), p = c(680, 1330, 740, 680, 1330, 740),
    lab = c("D", "O", "Qo = 96", "D", "O", "Qo = 80"),
    col = unname(couleurs_eco[c("demande", "offre", "alerte", "demande", "offre", "alerte")]))
  ggplot(d, aes(q)) +
    annotate("segment", x = 70, xend = 130, y = pmax, yend = pmax,
             colour = couleurs_eco[["equilibre"]], linewidth = 0.8) +
    (if (etape >= 2) geom_polygon(data = tri, aes(q, p), fill = couleurs_eco[["alerte"]], alpha = 0.35)) +
    geom_segment(data = pen, aes(x = qo, xend = qd, y = pmax, yend = pmax),
                 colour = couleurs_eco[["alerte"]], linewidth = 1.6) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    annotate("point", x = 100, y = 1000, size = 2.6) +
    geom_text(data = etiq, aes(q, p, label = lab, colour = col), family = police_cours,
              size = base_size / 3.4) +
    scale_colour_identity() +
    facet_wrap(~panneau, nrow = 1) +
    scale_x_continuous(breaks = c(80, 100, 120)) +
    scale_y_continuous(breaks = c(800, 1000, 1200), labels = c("800", "1 000", "1 200")) +
    coord_cartesian(xlim = c(70, 130), ylim = c(600, 1400), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q (milliers de logements)", y = "Loyer P (€ par mois)") +
    theme_cours(base_size = base_size) +
    theme(strip.text = element_text(family = police_cours, hjust = 0, size = rel(0.8)),
          panel.spacing = grid::unit(1.5, "lines"),
          axis.text = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 4. Graphique théorique : le miroir, un prix plancher (SMIC)
#    Géométrie fictive : demande de travail P = 20 - Q, offre de travail P = Q,
#    plancher Pmin = 13 (au-dessus de P* = 10).
# ---------------------------------------------------------------------------
plancher_cm4 <- list(pmin = 13, d_a = 20)
plancher_cm4$q_eq <- plancher_cm4$d_a / 2
plancher_cm4$qd <- plancher_cm4$d_a - plancher_cm4$pmin   # heures demandées par les employeurs
plancher_cm4$qo <- plancher_cm4$pmin                      # heures offertes par les travailleurs

#' Prix plancher au-dessus de P* sur un marché du travail : excès d'offre
#' (Qo - Qd, chômage au sens du modèle) et perte sèche. Sans graduations chiffrées.
#' @param etape diapos : 1 = équilibre (D, O, P*, Q*) ; 2 = ajoute le plancher,
#'   Qd, Qo et l'excès d'offre ; 3 = ajoute la perte sèche, figure de la page (défaut)
graphe_plancher <- function(base_size = 16, etape = 3) {
  pl <- plancher_cm4
  q <- seq(0, 20, length.out = 41)
  d <- data.frame(q = q, demande = pl$d_a - q, offre = q)
  taille <- base_size / 3
  alerte <- couleurs_eco[["alerte"]]
  i_tir <- if (etape >= 2) 1:4 else c(2, 4)    # tirets vers Q* et P* (puis Qd, Qo)
  i_x <- if (etape >= 2) 1:3 else 2            # graduations Q* (puis Qd, Qo)
  i_y <- if (etape >= 2) 1:2 else 1            # graduations P* (puis Pmin)
  g <- ggplot(d, aes(q))
  if (etape >= 3) g <- g +
    annotate("polygon", x = c(pl$qd, pl$qd, pl$q_eq), y = c(pl$pmin, pl$qd, pl$q_eq),   # offre P = Q : prix d'offre en Qd = Qd
             fill = alerte, alpha = 0.35)
  g <- g +
    annotate("segment", x = c(pl$qd, pl$q_eq, pl$qo, 0)[i_tir], xend = c(pl$qd, pl$q_eq, pl$qo, pl$q_eq)[i_tir],
             y = c(0, 0, 0, pl$q_eq)[i_tir], yend = c(pl$pmin, pl$q_eq, pl$pmin, pl$q_eq)[i_tir],
             linetype = "22", colour = couleurs_eco[["neutre"]])
  if (etape >= 2) g <- g +
    annotate("segment", x = 0, xend = 20, y = pl$pmin, yend = pl$pmin,
             colour = couleurs_eco[["equilibre"]], linewidth = 0.8)
  g <- g +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    annotate("segment", x = pl$qd, xend = pl$qo, y = pl$pmin, yend = pl$pmin,
             colour = alerte, linewidth = 1.8) +
    annotate("text", x = (pl$qd + pl$qo) / 2, y = pl$pmin + 1.1, label = "excès d’offre",
             colour = alerte, family = police_cours, size = taille) +
    annotate("text", x = 19.8, y = pl$pmin - 0.8, label = "plancher", hjust = 1,
             family = police_cours, size = taille * 0.9)
  g +
    annotate("point", x = pl$q_eq, y = pl$q_eq, size = 3) +
    annotate("text", x = c(18.5, 18.5), y = c(3, 19.6), label = c("D", "O"),
             colour = couleurs_eco[c("demande", "offre")], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(pl$qd, pl$q_eq, pl$qo)[i_x], labels = c("Qd", "Q*", "Qo")[i_x]) +
    scale_y_continuous(breaks = c(pl$q_eq, pl$pmin)[i_y], labels = c("P*", "Pmin")[i_y]) +
    coord_cartesian(xlim = c(0, 20), ylim = c(0, 21), expand = FALSE, clip = "on") +
    labs(x = "Quantité de travail Q (heures)", y = "Salaire horaire P") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 5. Graphique de données : loyers effectifs, France, Allemagne, zone euro
#    Eurostat, prc_hicp_aind, CP041, base 100 en 2015 ; data/cm4/SOURCES.md
# ---------------------------------------------------------------------------
loyers_ipch_cm4 <- utils::read.csv(here::here("data/cm4/loyers_ipch_2015_2025.csv"))

#' Hausse (%) d'une série de l'indice entre 2015 et 2025
hausse_loyers_cm4 <- function(pays) {
  x <- loyers_ipch_cm4[[pays]]
  100 * (x[loyers_ipch_cm4$annee == 2025] / x[loyers_ipch_cm4$annee == 2015] - 1)
}

#' Indice des loyers effectifs (2015 = 100), trois séries, 2015-2025
graphe_loyers_europe <- function(base_size = 16) {
  noms <- c(France = "France", Allemagne = "Allemagne", Zone_euro = "Zone euro")
  d <- do.call(rbind, lapply(names(noms), function(n)
    data.frame(annee = loyers_ipch_cm4$annee, serie = noms[[n]], indice = loyers_ipch_cm4[[n]])))
  d$serie <- factor(d$serie, levels = unname(noms))
  ggplot(d, aes(annee, indice, colour = serie)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 1.6) +
    scale_colour_manual(values = unname(couleurs_eco[c("demande", "offre", "neutre")])) +
    scale_x_continuous(breaks = seq(2015, 2025, 2)) +
    scale_y_continuous(breaks = seq(100, 120, 5)) +
    coord_cartesian(ylim = c(98, 121)) +
    labs(x = NULL, y = "Indice (2015 = 100)",
         caption = "Source : Eurostat, IPCH, loyers effectifs (prc_hicp_aind),\nconsulté le 21/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 6. Graphique de données : taux d'effort des locataires selon le niveau de vie
#    Insee, France, portrait social 2025 (données 2023) ; data/cm4/SOURCES.md
# ---------------------------------------------------------------------------
taux_effort_cm4 <- utils::read.csv(here::here("data/cm4/taux_effort_insee_2023.csv"))
taux_effort_ensemble_cm4 <- c(libre = 29.6, social = 26.6)   # « Ensemble », même tableau

#' Taux d'effort médian (%) d'un secteur pour un quart de niveau de vie
taux_effort <- function(secteur, quart) {
  taux_effort_cm4$taux_effort[taux_effort_cm4$secteur == secteur & taux_effort_cm4$quart == quart]
}

#' Barres groupées : taux d'effort médian par quart de niveau de vie, secteur libre et social
graphe_taux_effort <- function(base_size = 16) {
  d <- taux_effort_cm4
  quarts <- c("25 % les plus\nmodestes", "2ᵉ quart", "3ᵉ quart", "25 % les plus\naisés")
  d$quart_lib <- factor(quarts[d$quart], levels = quarts)
  ggplot(d, aes(quart_lib, taux_effort, fill = secteur)) +
    geom_col(position = position_dodge(width = 0.8), width = 0.75) +
    geom_text(aes(label = format(taux_effort, decimal.mark = ",", nsmall = 1)),
              position = position_dodge(width = 0.8), vjust = -0.4,
              family = police_cours, size = base_size / 4.2, colour = couleurs_eco[["equilibre"]]) +
    scale_fill_manual(values = ordre_series[1:2]) +
    scale_y_continuous(breaks = seq(0, 40, 10), labels = function(x) paste0(x, " %")) +
    coord_cartesian(ylim = c(0, 47)) +
    labs(x = "Quart de niveau de vie", y = "Taux d’effort médian",
         caption = "Source : Insee, France, portrait social, 18/11/2025\n(enquête SRCV 2024, données 2023).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)),
          axis.text.x = element_text(size = rel(0.8)))
}

#' Nombre au format français (virgule décimale, espace des milliers)
virgule_cm4 <- function(x, d = 1) formatC(x, format = "f", digits = d, decimal.mark = ",", big.mark = " ")

# ---------------------------------------------------------------------------
# 6 bis. Graphique de données : logements mis en chantier en % du parc
#    Insee, BDM : logements commencés (série 001718270, données SDES) et parc
#    au 1er janvier (série 001791241), France hors Mayotte, 2000-2025.
#    Fichier et provenance : data/cm4/construction_parc_insee_2000_2025.csv et
#    data/cm4/SOURCES.md. Un ordre de grandeur flux / stock, pas l'offre
#    locative privée (le parc comprend résidences secondaires et logements vacants).
# ---------------------------------------------------------------------------
construction_cm4 <- utils::read.csv(here::here("data/cm4/construction_parc_insee_2000_2025.csv"))

#' Logements commencés dans l'année, en % du parc au 1er janvier, 2000-2025 ;
#' étiquettes sur le maximum (2006) et la dernière année (2025).
graphe_construction_parc <- function(base_size = 16) {
  d <- construction_cm4
  reperes <- d[d$annee %in% c(2006, 2025), ]
  ggplot(d, aes(annee, commences_pct_parc)) +
    geom_line(linewidth = 1.2, colour = couleurs_eco[["offre"]]) +
    geom_point(size = base_size / 9, colour = couleurs_eco[["offre"]]) +
    geom_text(data = reperes, aes(label = paste0(virgule_cm4(commences_pct_parc, 2), " %\nen ", annee)),
              vjust = c(-0.35, 1.35), family = police_cours, size = base_size / 3.4,
              lineheight = 0.9, colour = couleurs_eco[["equilibre"]]) +
    scale_x_continuous(breaks = seq(2000, 2025, 5)) +
    scale_y_continuous(breaks = seq(0, 2, 0.5), labels = function(x) paste0(virgule_cm4(x), " %")) +
    coord_cartesian(ylim = c(0, 2.05), clip = "off") +
    labs(x = NULL, y = "Logements mis en chantier,\nen % du parc existant",
         caption = "Source : Insee, BDM, logements commencés (données SDES)\net parc de logements ; consulté le 22/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)), plot.caption.position = "plot",
          plot.margin = margin(10, 24, 8, 8))   # place pour l'étiquette de 2025
}

# ---------------------------------------------------------------------------
# 6 ter. Graphique de données : salaire minimum en % du salaire médian
#    OCDE, DSD_EARNINGS@MIN2AVE, MR_WG_FT, agrégation MEDIAN : France,
#    Allemagne (depuis 2015) et États-Unis (minimum fédéral), 2000-2025.
#    Fichier et provenance : data/cm4/salaire_minimum_median_ocde_2000_2025.csv
#    et data/cm4/SOURCES.md.
# ---------------------------------------------------------------------------
smic_median_cm4 <- utils::read.csv(here::here("data/cm4/salaire_minimum_median_ocde_2000_2025.csv"))

#' Salaire minimum relatif (%) d'un pays une année donnée
smic_median <- function(pays, annee) smic_median_cm4[[pays]][smic_median_cm4$annee == annee]

#' Trois courbes, étiquetées en bout de trait avec la valeur de 2025
graphe_salaire_minimum <- function(base_size = 16) {
  noms <- c(France = "France", Allemagne = "Allemagne", Etats_Unis = "États-Unis")
  d <- do.call(rbind, lapply(names(noms), function(n)
    data.frame(annee = smic_median_cm4$annee, serie = noms[[n]], ratio = smic_median_cm4[[n]])))
  d <- d[!is.na(d$ratio), ]
  d$serie <- factor(d$serie, levels = unname(noms))
  fin <- d[d$annee == 2025, ]
  ggplot(d, aes(annee, ratio, colour = serie)) +
    geom_line(linewidth = 1.2) +
    geom_point(size = base_size / 10) +
    geom_text(data = fin, aes(label = paste0(serie, " : ", virgule_cm4(ratio), " %")),
              hjust = 0, nudge_x = 0.7, family = police_cours, size = base_size / 3.4) +
    scale_colour_manual(values = unname(couleurs_eco[c("demande", "offre", "neutre")])) +
    scale_x_continuous(breaks = seq(2000, 2025, if (base_size > 16) 10 else 5), expand = expansion(mult = c(0.02, 0))) +
    scale_y_continuous(breaks = seq(0, 70, 10), labels = function(x) paste0(x, " %")) +
    coord_cartesian(xlim = c(2000, 2025.5), ylim = c(0, 72), clip = "off") +
    labs(x = NULL, y = "Salaire minimum brut,\nen % du salaire médian",
         caption = "Source : OCDE, salaire minimum relatif au salaire médian\ndes salariés à temps plein ; consulté le 22/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", plot.caption = element_text(margin = margin(t = 10)),
          plot.caption.position = "plot",
          # marge droite pour les étiquettes de fin de trait (≈ « États-Unis : 24,1 % »)
          plot.margin = margin(10, base_size * 9, 8, 8))
}

# ---------------------------------------------------------------------------
# 6 quater. Graphique de données : part de la population locataire, 2025
#    Eurostat, EU-SILC, ilc_lvho02 : Allemagne, UE à 27, France, en % des
#    personnes. Fichier et provenance : data/cm4/locataires_eurostat_2025.csv et
#    data/cm4/SOURCES.md. Catégories d'Eurostat, pas secteur libre / social de l'Insee.
# ---------------------------------------------------------------------------
locataires_cm4 <- utils::read.csv(here::here("data/cm4/locataires_eurostat_2025.csv"))

#' Barres horizontales empilées : loyer au prix du marché (bleu) et loyer
#' réduit ou gratuit (gris), total en bout de barre.
graphe_locataires <- function(base_size = 16) {
  loc <- locataires_cm4
  loc$zone <- factor(loc$zone, levels = rev(loc$zone))
  d <- rbind(
    data.frame(zone = loc$zone, type = "marche", part = loc$locataires_prix_marche, debut = 0),
    data.frame(zone = loc$zone, type = "reduit", part = loc$locataires_prix_reduit,
               debut = loc$locataires_prix_marche)
  )
  d$type <- factor(d$type, levels = c("reduit", "marche"))
  taille <- base_size / 3.4
  # diapos : pas d'étiquette dans un segment trop court (6,0 % en Allemagne, 10,7 % dans l'UE),
  # le total la donne
  d$etiquette <- ifelse(base_size <= 16 | d$part >= 12, virgule_cm4(d$part), "")
  haut <- locataires_cm4[1, ]  # barre du haut : les annotations de légende se placent au-dessus
  ggplot(d, aes(part, zone, fill = type)) +
    geom_col(width = 0.65) +
    geom_text(aes(x = debut + part / 2, label = etiquette), family = police_cours,
              size = taille, colour = "white") +
    geom_text(data = loc, aes(x = locataires_total + 2.5, y = zone,
                              label = paste0("total ", virgule_cm4(locataires_total), " %")),
              inherit.aes = FALSE, hjust = 0, family = police_cours, size = taille) +
    annotate("text", x = c(haut$locataires_prix_marche / 2,
                           haut$locataires_prix_marche + haut$locataires_prix_reduit / 2), y = 3.48, label = c("loyer au prix du marché", "loyer réduit"),
             hjust = c(1, 0.5), vjust = 0, family = police_cours, size = taille,
             colour = unname(couleurs_eco[c("demande", "neutre")])) +
    scale_fill_manual(values = unname(couleurs_eco[c("neutre", "demande")])) +
    scale_x_continuous(breaks = seq(0, 60, if (base_size > 16) 20 else 10), labels = function(x) paste0(x, " %")) +
    coord_cartesian(xlim = c(0, if (base_size > 16) 76 else 68), ylim = c(0.6, 3.6), clip = "off") +
    labs(x = "Part de la population qui loue son logement (2025)", y = NULL,
         caption = "Source : Eurostat, EU-SILC, statut d'occupation (ilc_lvho02),\n2025 ; consulté le 22/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", plot.caption = element_text(margin = margin(t = 10)),
          plot.caption.position = "plot", panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          axis.line.x = element_blank())
}

# ---------------------------------------------------------------------------
# 6 quinquies. Graphique de données : surcharge des coûts du logement selon
#    le statut d'occupation, France, 2025
#    Eurostat, EU-SILC, ilc_lvho07c : part des personnes dont les coûts du
#    logement, nets des aides, dépassent 40 % du revenu disponible du ménage.
#    Fichier et provenance : data/cm4/surcharge_logement_france_eurostat_2025.csv
#    et data/cm4/SOURCES.md. Indicateur différent du taux d'effort médian (section 6).
# ---------------------------------------------------------------------------
surcharge_cm4 <- utils::read.csv(here::here("data/cm4/surcharge_logement_france_eurostat_2025.csv"))

#' Taux de surcharge (%) pour un code de statut Eurostat
surcharge <- function(code) surcharge_cm4$surcharge_pct[surcharge_cm4$code == code]

#' Barres horizontales, une par statut ; locataires au prix du marché en rouge
graphe_surcharge <- function(base_size = 16) {
  d <- surcharge_cm4
  d$statut <- factor(d$statut, levels = rev(d$statut))
  d$couleur <- ifelse(d$code == "RENT_MKT", couleurs_eco[["alerte"]], couleurs_eco[["neutre"]])
  ggplot(d, aes(surcharge_pct, statut)) +
    geom_col(aes(fill = couleur), width = 0.65) +
    geom_text(aes(label = paste0(virgule_cm4(surcharge_pct), " %")), hjust = 0, nudge_x = 0.4,
              family = police_cours, size = base_size / 3.4) +
    scale_fill_identity() +
    scale_x_continuous(breaks = seq(0, 20, if (base_size > 16) 10 else 5), labels = function(x) paste0(x, " %")) +
    coord_cartesian(xlim = c(0, 23)) +
    labs(x = "Part des personnes dont le logement coûte\nplus de 40 % du revenu disponible", y = NULL,
         caption = "Source : Eurostat, EU-SILC (ilc_lvho07c), France, 2025 ;\nconsulté le 22/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)), plot.caption.position = "plot",
          panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          axis.line.x = element_blank(), axis.title.x = element_text(size = rel(0.8)),
          axis.text.y = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 7. Vérifications : chaque chiffre annoncé dans cours/cm4.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# Exemple 1 : équilibre (identique à court et à long terme)
stopifnot(
  proche(bilan_lt_cm4$p_eq, 1000), proche(bilan_lt_cm4$q_eq, 100),
  proche(bilan_ct_cm4$p_eq, 1000), proche(bilan_ct_cm4$q_eq, 100),
  proche(100 * (bilan_lt_cm4$p_eq - marche_cm4$plafond) / bilan_lt_cm4$p_eq, 20)  # plafond 20 % sous P*
)
# Exemple 1 : long terme
stopifnot(
  proche(bilan_lt_cm4$qo, 80), proche(bilan_lt_cm4$qd, 120), proche(bilan_lt_cm4$penurie, 40),
  proche(bilan_lt_cm4$pd, 1200),
  proche(bilan_lt_cm4$transfert, 16000),                            # 16 M€ par mois
  proche(bilan_lt_cm4$perte, 4000),                                 # 4 M€ par mois
  proche(sc_avant_lt_cm4, 50000), proche(sp_avant_lt_cm4, 50000),
  proche(sp_apres_lt_cm4, 32000),
  proche(bilan_lt_cm4$delta_sc, 14000),                             # locataires : +14 M€
  proche(sp_apres_lt_cm4 - sp_avant_lt_cm4, -18000),                # bailleurs : -18 M€
  proche(bilan_lt_cm4$delta_sc + (sp_apres_lt_cm4 - sp_avant_lt_cm4), -bilan_lt_cm4$perte),
  proche(bilan_lt_cm4$transfert - 0.5 * 20 * (1200 - 1000), 14000)  # gain = transfert - part de la perte
)
# Exemple 1 : court terme
stopifnot(
  proche(bilan_ct_cm4$qo, 96), proche(bilan_ct_cm4$qd, 120), proche(bilan_ct_cm4$penurie, 24),
  proche(bilan_ct_cm4$pd, 1040),
  proche(bilan_ct_cm4$transfert, 19200),                            # 19,2 M€ par mois
  proche(bilan_ct_cm4$perte, 480),                                  # 0,48 M€ par mois
  proche(round(bilan_lt_cm4$perte / bilan_ct_cm4$perte, 1), 8.3)    # environ 8 fois plus
)
# Prix plancher : excès d'offre au-dessus de P*
stopifnot(proche(plancher_cm4$q_eq, 10), plancher_cm4$qd < plancher_cm4$q_eq,
          plancher_cm4$qo > plancher_cm4$q_eq)
# SMIC au 01/06/2026 : 12,31 € brut de l'heure, 1 867,02 € brut par mois (35 h)
stopifnot(proche(round(12.31 * 35 * 52 / 12, 2), 1867.02))
# Eurostat : hausses 2015-2025 citées dans la page
stopifnot(
  nrow(loyers_ipch_cm4) == 11, !anyNA(loyers_ipch_cm4),
  proche(hausse_loyers_cm4("France"), 9.72, 1e-6),
  proche(hausse_loyers_cm4("Allemagne"), 17.9, 1e-6),
  proche(hausse_loyers_cm4("Zone_euro"), 18.85, 1e-6)
)
# Insee : taux d'effort (secteur libre ~ deux fois plus élevé pour les 25 % les plus modestes)
stopifnot(
  nrow(taux_effort_cm4) == 8,
  proche(taux_effort("Secteur libre", 1), 42.3), proche(taux_effort("Secteur libre", 4), 21.6),
  proche(round(taux_effort("Secteur libre", 1) / taux_effort("Secteur libre", 4), 1), 2),
  proche(taux_effort("Secteur social", 1), 30.3),
  proche(taux_effort_ensemble_cm4[["libre"]], 29.6)                 # accroche : 29,6 %
)
# Insee : mises en chantier en % du parc (maximum en 2006, 2025 ; parc 2025 recoupé
# par Insee Focus n° 359 : 38,4 millions de logements)
stopifnot(
  nrow(construction_cm4) == 26, !anyNA(construction_cm4),
  proche(max(construction_cm4$commences_pct_parc), 1.55),
  construction_cm4$annee[which.max(construction_cm4$commences_pct_parc)] == 2006,
  proche(construction_cm4$commences_pct_parc[construction_cm4$annee == 2025], 0.69),
  proche(min(construction_cm4$commences_pct_parc), 0.68),
  proche(round(construction_cm4$parc_milliers[construction_cm4$annee == 2025] / 1000, 1), 38.4),
  proche(round(100 * construction_cm4$logements_commences / (1000 * construction_cm4$parc_milliers), 2),
         construction_cm4$commences_pct_parc)
)
# OCDE : salaire minimum en % du médian, 2025 (États-Unis recoupé par le BLS : 24,09 %)
stopifnot(
  proche(smic_median("France", 2025), 62.5), proche(smic_median("Allemagne", 2025), 49.6),
  proche(smic_median("Etats_Unis", 2025), 24.1), is.na(smic_median("Allemagne", 2014)),
  proche(round(smic_median("France", 2025) / smic_median("Etats_Unis", 2025), 1), 2.6)  # environ deux fois et demie
)
# Eurostat : locataires 2025 (marché + réduit = total ; Allemagne 52,8 % recoupé)
stopifnot(
  all(abs(locataires_cm4$locataires_prix_marche + locataires_cm4$locataires_prix_reduit -
            locataires_cm4$locataires_total) < 0.11),
  proche(locataires_cm4$locataires_prix_marche[locataires_cm4$code == "DE"], 46.8),
  proche(locataires_cm4$locataires_total[locataires_cm4$code == "DE"], 52.8),
  proche(locataires_cm4$locataires_prix_marche[locataires_cm4$code == "FR"], 16.4),
  proche(locataires_cm4$locataires_prix_reduit[locataires_cm4$code == "FR"], 22.2)
)
# Eurostat : surcharge des coûts du logement, France 2025
stopifnot(
  nrow(surcharge_cm4) == 5,
  proche(surcharge("RENT_MKT"), 18.7), proche(surcharge("TOTAL"), 6.4),
  proche(surcharge("OWN_L"), 1.1), proche(surcharge("OWN_NL"), 1.6)
)
