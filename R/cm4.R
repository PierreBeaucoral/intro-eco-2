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
#' @param aires si FALSE, ne montre que la pénurie (diapos : construction pas à pas)
#' @param base_size 16 (page) ou 24 (diapos)
graphe_plafond <- function(aires = TRUE, base_size = 16) {
  b <- bilan_lt_cm4
  pmax <- marche_cm4$plafond
  q <- seq(0, 175, length.out = 60)
  d <- data.frame(q = q, demande = prix_demande_cm4(q), offre = q / marche_cm4$lt_b)
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  alerte <- couleurs_eco[["alerte"]]
  g <- ggplot(d, aes(q))
  if (aires) {
    g <- g +
      annotate("rect", xmin = 0, xmax = b$qo, ymin = pmax, ymax = b$p_eq,
               fill = couleurs_eco[["demande"]], alpha = 0.18) +
      annotate("polygon", x = c(b$qo, b$qo, b$q_eq), y = c(pmax, b$pd, b$p_eq),
               fill = alerte, alpha = 0.35) +
      annotate("text", x = b$qo / 2, y = (pmax + b$p_eq) / 2, label = "transfert",
               family = police_cours, size = taille * 0.9, colour = couleurs_eco[["demande"]]) +
      annotate("text", x = b$qo + 12, y = 1650, label = "perte sèche",
               family = police_cours, size = taille * 0.9, colour = alerte, hjust = 0) +
      annotate("segment", x = b$qo + 14, xend = b$qo + 7, y = 1610, yend = 1060,
               colour = alerte, linewidth = 0.5,
               arrow = grid::arrow(length = grid::unit(0.18, "cm"), type = "closed"))
  }
  g +
    annotate("segment", x = c(b$qo, b$q_eq, b$qd, 0), xend = c(b$qo, b$q_eq, b$qd, b$q_eq),
             y = c(0, 0, 0, b$p_eq), yend = c(b$pd, b$p_eq, pmax, b$p_eq),
             linetype = "22", colour = neutre) +
    annotate("segment", x = 0, xend = 175, y = pmax, yend = pmax,
             colour = couleurs_eco[["equilibre"]], linewidth = 0.8) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    annotate("segment", x = b$qo, xend = b$qd, y = pmax, yend = pmax,
             colour = alerte, linewidth = 1.8) +
    annotate("text", x = (b$qo + b$qd) / 2, y = pmax - 110, label = "pénurie",
             colour = alerte, family = police_cours, size = taille) +
    annotate("text", x = 174, y = pmax + 80, label = "plafond", hjust = 1,
             family = police_cours, size = taille * 0.9) +
    annotate("point", x = b$q_eq, y = b$p_eq, size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = b$q_eq + 7, y = b$p_eq - 70, label = "E", family = police_cours, size = taille) +
    annotate("text", x = c(158, 163), y = c(260, 1790), label = c("D", "O"),
             colour = couleurs_eco[c("demande", "offre")], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(b$qo, b$q_eq, b$qd), labels = c("Qo", "Q*", "Qd")) +
    scale_y_continuous(breaks = c(pmax, b$p_eq), labels = c("Pmax", "P*")) +
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
graphe_court_long <- function(base_size = 16) {
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
    geom_polygon(data = tri, aes(q, p), fill = couleurs_eco[["alerte"]], alpha = 0.35) +
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
graphe_plancher <- function(base_size = 16) {
  pl <- plancher_cm4
  q <- seq(0, 20, length.out = 41)
  d <- data.frame(q = q, demande = pl$d_a - q, offre = q)
  taille <- base_size / 3
  alerte <- couleurs_eco[["alerte"]]
  ggplot(d, aes(q)) +
    annotate("polygon", x = c(pl$qd, pl$qd, pl$q_eq), y = c(pl$pmin, pl$qd, pl$q_eq),   # offre P = Q : prix d'offre en Qd = Qd
             fill = alerte, alpha = 0.35) +
    annotate("segment", x = c(pl$qd, pl$q_eq, pl$qo, 0), xend = c(pl$qd, pl$q_eq, pl$qo, pl$q_eq),
             y = c(0, 0, 0, pl$q_eq), yend = c(pl$pmin, pl$q_eq, pl$pmin, pl$q_eq),
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    annotate("segment", x = 0, xend = 20, y = pl$pmin, yend = pl$pmin,
             colour = couleurs_eco[["equilibre"]], linewidth = 0.8) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    annotate("segment", x = pl$qd, xend = pl$qo, y = pl$pmin, yend = pl$pmin,
             colour = alerte, linewidth = 1.8) +
    annotate("text", x = (pl$qd + pl$qo) / 2, y = pl$pmin + 1.1, label = "excès d’offre",
             colour = alerte, family = police_cours, size = taille) +
    annotate("text", x = 19.8, y = pl$pmin - 0.8, label = "plancher", hjust = 1,
             family = police_cours, size = taille * 0.9) +
    annotate("point", x = pl$q_eq, y = pl$q_eq, size = 3) +
    annotate("text", x = c(18.5, 18.5), y = c(3, 19.6), label = c("D", "O"),
             colour = couleurs_eco[c("demande", "offre")], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(pl$qd, pl$q_eq, pl$qo), labels = c("Qd", "Q*", "Qo")) +
    scale_y_continuous(breaks = c(pl$q_eq, pl$pmin), labels = c("P*", "Pmin")) +
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

# ---------------------------------------------------------------------------
# 7. Vérifications : chaque chiffre annoncé dans cours/cm4.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# Exemple 1 : équilibre (identique à court et à long terme)
stopifnot(
  proche(bilan_lt_cm4$p_eq, 1000), proche(bilan_lt_cm4$q_eq, 100),
  proche(bilan_ct_cm4$p_eq, 1000), proche(bilan_ct_cm4$q_eq, 100),
  proche(100 * (1000 - marche_cm4$plafond) / 1000, 20)              # plafond 20 % sous P*
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
  proche(taux_effort("Secteur social", 1), 30.3)
)
