# cm5.R · graphiques du CM 5 (ZFE, externalités, qui paie la transition automobile),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm5.qmd sont définies ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.
#
# Notation (guide § 6) : D demande, Cm coût marginal privé, Cms coût marginal social,
# t taxe unitaire, P*, Q* équilibre de marché. Notation proposée (signalée dans le
# rapport) : Dm dommage marginal (Cms = Cm + Dm), Q° quantité socialement optimale.

# ---------------------------------------------------------------------------
# 1. Le marché fictif de l'exemple 1 (trajets en voiture ancienne dans la zone)
#    Q en milliers de trajets par jour, P en euros par trajet.
#    Demande (bénéfice marginal du trajet) : P = 12 - Q
#    Coût marginal privé (carburant, usure) : Cm = 4, constant
#    Dommage marginal (pollution subie par les riverains) : Dm = 2, constant
# ---------------------------------------------------------------------------
marche_cm5 <- list(d_a = 12, cm = 4, dm = 2)

#' Quantité demandée quand le coût par trajet vaut p (demande P = a - Q)
quantite_demandee <- function(p, a = marche_cm5$d_a) a - p

ex_cm5 <- within(list(), {
  cms        <- marche_cm5$cm + marche_cm5$dm                  # 6 €
  q_marche   <- quantite_demandee(marche_cm5$cm)               # Q* = 8
  q_optimum  <- quantite_demandee(cms)                         # Q° = 6
  perte      <- 0.5 * (q_marche - q_optimum) * marche_cm5$dm   # perte sèche = 2 (milliers d'€)
  t          <- marche_cm5$dm                                  # taxe pigouvienne = Dm = 2 €
  recette    <- t * q_optimum                                  # 12 (milliers d'€ par jour)
  evite      <- marche_cm5$dm * (q_marche - q_optimum)         # pollution évitée = 4
  perte_cond <- 0.5 * (q_marche - q_optimum) * (cms - marche_cm5$cm)  # surplus perdu par les conducteurs = 2
  subvention <- marche_cm5$dm * (q_marche - q_optimum)         # 2 € par trajet évité x 2 = 4
  # norme mal ciblée : elle écarte 2 000 trajets valant en moyenne 10 € (trajets 1 000 à 3 000)
  valeur_ecartee <- marche_cm5$d_a - 2                         # valeur moyenne = 12 - 2 = 10 €
  perte_norme    <- (q_marche - q_optimum) * (valeur_ecartee - marche_cm5$cm)   # 12
  bilan_norme    <- evite - perte_norme                        # -8
})

# ---------------------------------------------------------------------------
# 2. Graphique théorique : coût privé, coût social, perte sèche, taxe
# ---------------------------------------------------------------------------

#' Externalité négative sur le marché des trajets.
#' Cm (ambre, trait plein) et Cms = Cm + Dm (ambre, tirets) ; la demande D (azur).
#' Sans taxe : le marché s'arrête en Q* (E), l'optimum est Q° (E°), la perte sèche
#' est le triangle rouge. Avec taxe (taxe = TRUE) : le coût payé par le conducteur
#' monte de t = Dm, la quantité tombe à Q° et le rectangle gris est la recette.
#' Axes étiquetés P*, P* + Dm, Q°, Q* (graphique théorique, sans graduations).
#' @param taxe si TRUE, montre la recette de la taxe au lieu de la perte sèche
#' @param base_size 16 (page) ou 24 (diapos)
#' @param etape construction pas à pas pour les diapos : 1 = marché seul (D, Cm,
#'   E, Q*) ; 2 = ajoute le coût social (Cms, Dm, E°, Q°) ; 3 = figure complète
#'   (perte sèche, ou recette si taxe = TRUE), identique à la page (défaut)
graphe_externalite <- function(taxe = FALSE, base_size = 16, etape = 3) {
  a <- marche_cm5$d_a; cm <- marche_cm5$cm; cms <- ex_cm5$cms
  q0 <- ex_cm5$q_optimum; q1 <- ex_cm5$q_marche
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  d <- data.frame(q = seq(0, 11, length.out = 50))
  d$demande <- a - d$q
  i_q <- if (etape >= 2) 1:2 else 2            # Q° et Q* (étape 1 : Q* seul)
  i_e <- if (etape >= 2) 1:2 else 1            # E (puis E°)
  i_lab <- if (etape >= 2) 1:3 else 1:2        # D, Cm (puis Cms)
  g <- ggplot(d, aes(q))
  if (etape < 3) {
    # pas encore d'aire : ni perte sèche, ni recette
  } else if (taxe) {
    g <- g +
      annotate("rect", xmin = 0, xmax = q0, ymin = cm, ymax = cms, fill = neutre, alpha = 0.25) +
      annotate("text", x = q0 / 2, y = (cm + cms) / 2, label = "recette = t × Q°",
               family = police_cours, size = taille)
  } else {
    g <- g +
      annotate("polygon", x = c(q0, q1, q1), y = c(cms, cms, cm),
               fill = couleurs_eco[["alerte"]], alpha = 0.35) +
      annotate("text", x = q1 + 0.15, y = cms + 0.55, label = "perte sèche", hjust = 0,
               colour = couleurs_eco[["alerte"]], family = police_cours, size = taille)
  }
  g <- g +
    annotate("segment", x = c(q0, q1)[i_q], xend = c(q0, q1)[i_q], y = c(0, 0)[i_q], yend = c(cms, cm)[i_q],
             linetype = "22", colour = neutre) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    annotate("segment", x = 0, xend = 11, y = cm, yend = cm,
             colour = couleurs_eco[["offre"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    annotate("segment", x = 0, xend = 11, y = cms, yend = cms,
             colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22") +
    # accolade du dommage marginal : écart vertical entre Cm et Cms
    annotate("segment", x = 10.2, xend = 10.2, y = cm + 0.1, yend = cms - 0.1,
             colour = couleurs_eco[["alerte"]], linewidth = 0.7,
             arrow = grid::arrow(length = grid::unit(0.18, "cm"), ends = "both", type = "closed")) +
    annotate("text", x = 10.45, y = (cm + cms) / 2, label = if (taxe) "t = Dm" else "Dm",
             hjust = 0, colour = couleurs_eco[["alerte"]], family = police_cours, size = taille)
  g +
    annotate("point", x = c(q1, q0)[i_e], y = c(cm, cms)[i_e], size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = c(q1 + 0.35, q0 + 0.1)[i_e], y = c(cm - 0.45, cms + 0.5)[i_e], label = c("E", "E°")[i_e],
             family = police_cours, size = taille) +
    annotate("text", x = c(1.4, 11.4, 11.4)[i_lab], y = c(11.6, cm, cms)[i_lab], label = c("D", "Cm", "Cms")[i_lab],
             hjust = c(0.5, 0, 0)[i_lab], colour = couleurs_eco[c("demande", "offre", "offre")][i_lab],
             family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(q0, q1)[i_q], labels = c("Q°", "Q*")[i_q]) +
    scale_y_continuous(breaks = c(cm, cms)[i_e], labels = c("P*", "P* + Dm")[i_e]) +
    coord_cartesian(xlim = c(0, 12.6), ylim = c(0, 12.5), expand = FALSE, clip = "off") +
    labs(x = "Trajets en voiture ancienne Q", y = "Coût ou bénéfice par trajet P") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 3. Exemple 2 : prix ou quantité quand on ignore la demande (Weitzman)
#    Même Cm = 4 et même cible : t = 2 ou norme de 6 milliers de trajets.
#    Demande basse : P = 11 - Q ; demande haute : P = 13 - Q (moyenne : 12 - Q).
# ---------------------------------------------------------------------------
weitzman_cm5 <- within(list(d_bas = 11, d_haut = 13, norme = 6), {
  q_taxe     <- c(bas = d_bas, haut = d_haut) - (marche_cm5$cm + marche_cm5$dm)   # 5 et 7
  q_marche   <- c(bas = d_bas, haut = d_haut) - marche_cm5$cm                     # 7 et 9 : la norme mord
  cout_norme <- c(bas = d_bas, haut = d_haut) - norme - marche_cm5$cm            # 1 et 3 € par trajet
  # erreur de la norme si Dm est constant : |norme - Q°| milliers de trajets, chacun perdant
  # en moyenne la moitié de l'écart de prix (pente 1) : triangle ½ × 1 × 1 = 0,5 millier d'€
  perte_norme <- 0.5 * abs(norme - q_taxe)^2                                       # 0,5 et 0,5
})

#' Deux panneaux, deux demandes possibles (D, puis D′ en tirets).
#' A. Taxe : le coût par trajet est fixé à Cm + t ; la quantité varie de 5 à 7.
#' B. Norme : la quantité est fixée à 6 ; la valeur du dernier trajet permis varie
#'    de 5 à 7 €, soit un coût implicite de 1 à 3 € au-dessus de Cm.
#' Graduations chiffrées assumées : la figure illustre l'exemple 2.
#' @param etape construction pas à pas pour les diapos : 1 = les deux demandes
#'   et Cm ; 2 = ajoute la taxe (panneau A) ; 3 = figure complète avec la norme
#'   (panneau B), identique à la page (défaut)
graphe_weitzman <- function(base_size = 16, etape = 3) {
  w <- weitzman_cm5; cm <- marche_cm5$cm; prix_taxe <- cm + marche_cm5$dm
  panneaux <- c("A. Taxe : le prix est fixé", "B. Norme : la quantité est fixée")
  fp <- function(x) factor(x, levels = panneaux)
  q <- seq(2, 10, length.out = 40)
  d <- rbind(data.frame(panneau = fp(panneaux[1]), q = q),
             data.frame(panneau = fp(panneaux[2]), q = q))
  d$bas <- w$d_bas - d$q
  d$haut <- w$d_haut - d$q
  pts <- data.frame(panneau = fp(panneaux[c(1, 1, 2, 2)]),
                    q = c(w$q_taxe, w$norme, w$norme),
                    p = c(prix_taxe, prix_taxe, w$d_bas - w$norme, w$d_haut - w$norme))
  # écart rouge : la quantité incertaine (A), le coût incertain (B)
  ecart <- data.frame(panneau = fp(panneaux), x = c(w$q_taxe[["bas"]], 2.25),
                      xend = c(w$q_taxe[["haut"]], 2.25),
                      y = c(2.25, w$d_bas - w$norme), yend = c(2.25, w$d_haut - w$norme))
  etiq <- data.frame(
    panneau = fp(panneaux[c(1, 1, 1, 1, 2, 2, 2, 2, 1, 2)]),
    q = c(2.5, 4.3, 9.9, 2.1, 2.5, 4.3, 2.1, 6.15, 6, 2.45),
    p = c(8, 9.5, prix_taxe + 0.35, cm - 0.35, 8, 9.5, cm - 0.35, 9.6, 2.65, 4.6),
    lab = c("D", "D′", "Cm + t", "Cm", "D", "D′", "Cm", "norme", "quantité incertaine", "coût incertain"),
    col = unname(couleurs_eco[c("demande", "demande", "offre", "offre", "demande", "demande",
                                "offre", "equilibre", "alerte", "alerte")]),
    hj = c(0.5, 0.5, 1, 0, 0.5, 0.5, 0, 0, 0.5, 0)
  )
  if (etape < 3) {                              # instrument montré : aucun, puis la taxe (A)
    vis <- panneaux[seq_len(etape - 1)]
    pts <- pts[pts$panneau %in% vis, ]
    ecart <- ecart[ecart$panneau %in% vis, ]
    etiq <- etiq[if (etape == 1) c(1, 2, 4:7) else c(1:7, 9), ]
  }
  g <- ggplot(d, aes(q)) +
    geom_line(aes(y = bas), colour = couleurs_eco[["demande"]], linewidth = 1.3) +
    geom_line(aes(y = haut), colour = couleurs_eco[["demande"]], linewidth = 1.3, linetype = "22") +
    geom_segment(data = data.frame(panneau = fp(panneaux), x = 2, xend = 10, y = cm),
                 aes(x = x, xend = xend, y = y, yend = y),
                 colour = couleurs_eco[["offre"]], linewidth = 1.1)
  if (etape >= 2) g <- g +
    geom_segment(data = data.frame(panneau = fp(panneaux[1]), x = 2, xend = 10, y = prix_taxe),
                 aes(x = x, xend = xend, y = y, yend = y),
                 colour = couleurs_eco[["offre"]], linewidth = 1.3, linetype = "22")
  if (etape >= 3) g <- g +
    geom_segment(data = data.frame(panneau = fp(panneaux[2]), x = w$norme, y = 2, yend = 10),
                 aes(x = x, xend = x, y = y, yend = yend),
                 colour = couleurs_eco[["equilibre"]], linewidth = 1.1)
  g +
    geom_segment(data = ecart, aes(x = x, xend = xend, y = y, yend = yend),
                 colour = couleurs_eco[["alerte"]], linewidth = 1.8) +
    geom_point(data = pts, aes(y = p), size = 2.6, colour = couleurs_eco[["equilibre"]]) +
    geom_text(data = etiq, aes(x = q, y = p, label = lab, colour = col, hjust = hj),
              family = police_cours, size = base_size / 3.4) +
    scale_colour_identity() +
    facet_wrap(~panneau, nrow = 1) +
    scale_x_continuous(breaks = if (etape >= 2) c(5, 6, 7) else 6) +      # étape 1 : la cible et Cm seules
    scale_y_continuous(breaks = if (etape >= 2) c(4, 5, 6, 7) else 4) +
    coord_cartesian(xlim = c(2, 10), ylim = c(2, 10), expand = FALSE, clip = "on") +   # les courbes s'arrêtent au cadre
    labs(x = "Trajets Q (milliers par jour)", y = "€ par trajet") +
    theme_cours(base_size = base_size) +
    theme(strip.text = element_text(family = police_cours, hjust = 0, size = rel(0.85)),
          panel.spacing = grid::unit(1.5, "lines"),
          axis.text = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 4. Données : effet propre des ZFE (Insee Analyses n° 124, 27/08/2026)
#    Voir data/cm5/SOURCES.md.
# ---------------------------------------------------------------------------
effets_zfe_cm5 <- read.csv(here::here("data/cm5/insee_ia124_fig4_emissions.csv"))
parc_zfe_cm5   <- read.csv(here::here("data/cm5/insee_ia124_fig3_parc.csv"))

#' Format français : virgule décimale, vrai signe moins
fr_num <- function(x) sub("-", "−", format(x, decimal.mark = ",", nsmall = 1, trim = TRUE))

#' Barres horizontales : variation observée des émissions (avec ZFE, azur) et
#' variation estimée sans ZFE (gris), avec l'intervalle de confiance de cette
#' estimation ; à droite, l'effet propre publié par l'Insee.
#' @param etape pour les diapos : 1 = variation observée seule (l'avant-après) ;
#'   2 = figure complète avec le contrefactuel et l'effet propre (défaut)
graphe_effet_zfe <- function(base_size = 16, etape = 2) {
  e <- effets_zfe_cm5
  noms <- c(NOx = "Oxydes d'azote (NOx)", "PM2,5" = "Particules fines (PM2,5)", CO2 = "Dioxyde de carbone (CO₂)")
  e$nom <- factor(noms[e$polluant], levels = rev(noms))
  series <- c("Observé, avec ZFE", "Estimé sans ZFE (contrefactuel)")
  long <- rbind(
    data.frame(nom = e$nom, serie = series[1], valeur = e$variation_observee, bas = NA, haut = NA),
    data.frame(nom = e$nom, serie = series[2], valeur = e$variation_contrefactuelle, bas = e$ic_bas, haut = e$ic_haut)
  )
  long$serie <- factor(long$serie, levels = rev(series))   # observé en haut de chaque groupe
  if (etape < 2) long <- long[long$serie == series[1], ]   # l'avant-après seul
  dodge <- position_dodge(width = 0.8)
  g <- ggplot(long, aes(x = valeur, y = nom, fill = serie)) +
    geom_col(position = dodge, width = 0.75) +
    geom_errorbar(aes(xmin = bas, xmax = haut), position = dodge, width = 0.3,
                  colour = couleurs_eco[["equilibre"]], linewidth = 0.5, na.rm = TRUE) +
    geom_text(aes(x = pmin(valeur, bas, na.rm = TRUE) - 0.8, label = paste0(fr_num(valeur), " %")),
              position = dodge, hjust = 1, family = police_cours, size = base_size / 3.6)
  if (etape >= 2) g <- g +
    annotate("text", x = 1.5, y = as.numeric(e$nom), hjust = 0, family = police_cours,
             size = base_size / 3.6, colour = couleurs_eco[["alerte"]],
             label = paste0("effet : ", fr_num(e$effet_points), " pt"))
  g +
    geom_vline(xintercept = 0, colour = couleurs_eco[["equilibre"]], linewidth = 0.5) +
    scale_fill_manual(values = setNames(c(couleurs_eco[["demande"]],
                                         scales::alpha(couleurs_eco[["neutre"]], 0.5)), series),
                      breaks = series) +
    scale_x_continuous(breaks = seq(-40, 0, 10), labels = function(x) sub("-", "\u2212", x),
                       limits = c(-50, 19), expand = c(0, 0)) +
    labs(x = "Variation des émissions des voitures sur cinq ans (%)", y = NULL,
         caption = "Source : Insee, Insee Analyses n° 124, 27/08/2026\n(données SDES, RSVERO ; Citepa, OMINEA).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = scales::alpha(couleurs_eco[["neutre"]], 0.4), linewidth = 0.4),
          axis.line.x = element_blank(), axis.text.x = element_text(size = rel(0.8)),
          axis.text.y = element_text(size = rel(0.85)))
}

#' Signe explicite (+ ou vrai signe moins) et virgule décimale, pour les effets en points
fr_signe <- function(x) paste0(ifelse(x > 0, "+", ""), fr_num(x))

#' Parc de voitures par vignette Crit'Air (Insee Analyses n° 124, figure 3) :
#' variation observée sur cinq ans dans les intercommunalités à ZFE (azur) et
#' variation estimée sans ZFE (gris, avec son intervalle de confiance).
#' L'effet propre est écrit sous le nom de chaque vignette (« non significatif »
#' quand l'Insee publie « ns ») : les valeurs vont de −64 % à +88 %, il n'y a pas
#' de place à droite des barres comme dans graphe_effet_zfe().
#' @param base_size 16 (page) ou 24 (diapos)
graphe_parc_zfe <- function(base_size = 16) {
  p <- parc_zfe_cm5
  noms <- c("1 et électrique" = "Crit'Air 1 et électriques", "2" = "Crit'Air 2", "3" = "Crit'Air 3",
            "4" = "Crit'Air 4", "5 et non classé" = "Crit'Air 5 et non classées")
  effet <- ifelse(is.na(p$effet_points), "effet non significatif",
                  paste0("effet ", fr_signe(p$effet_points), " pt"))
  etiq <- paste0(noms[p$critair], "\n", effet)
  p$nom <- factor(etiq, levels = rev(etiq))                 # Crit'Air 1 en haut
  series <- c("Observé, avec ZFE", "Estimé sans ZFE (contrefactuel)")
  long <- rbind(
    data.frame(nom = p$nom, serie = series[1], valeur = p$variation_observee, bas = NA, haut = NA),
    data.frame(nom = p$nom, serie = series[2], valeur = p$variation_contrefactuelle, bas = p$ic_bas, haut = p$ic_haut)
  )
  long$serie <- factor(long$serie, levels = rev(series))   # observé en haut de chaque groupe
  # étiquette au bout de la barre (ou de l'intervalle), du côté du signe
  long$x_etiq <- ifelse(long$valeur >= 0, pmax(long$valeur, long$haut, na.rm = TRUE) + 2,
                        pmin(long$valeur, long$bas, na.rm = TRUE) - 2)
  long$hj <- ifelse(long$valeur >= 0, 0, 1)
  dodge <- position_dodge(width = 0.8)
  ggplot(long, aes(x = valeur, y = nom, fill = serie)) +
    geom_col(position = dodge, width = 0.75) +
    geom_errorbar(aes(xmin = bas, xmax = haut), position = dodge, width = 0.3,
                  colour = couleurs_eco[["equilibre"]], linewidth = 0.5, na.rm = TRUE) +
    geom_text(aes(x = x_etiq, label = paste0(fr_num(valeur), " %"), hjust = hj),
              position = dodge, family = police_cours, size = base_size / 4) +
    geom_vline(xintercept = 0, colour = couleurs_eco[["equilibre"]], linewidth = 0.5) +
    scale_fill_manual(values = setNames(c(couleurs_eco[["demande"]],
                                         scales::alpha(couleurs_eco[["neutre"]], 0.5)), series),
                      breaks = series) +
    scale_x_continuous(breaks = seq(-60, 80, 20), labels = function(x) sub("-", "−", x),
                       limits = c(-95, 112), expand = c(0, 0)) +
    labs(x = "Variation du nombre de voitures sur cinq ans (%)", y = NULL,
         caption = "Source : Insee, Insee Analyses n° 124, 27/08/2026\n(données SDES, RSVERO).") +
    guides(fill = guide_legend(ncol = 1)) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = scales::alpha(couleurs_eco[["neutre"]], 0.4), linewidth = 0.4),
          axis.line.x = element_blank(), axis.text.x = element_text(size = rel(0.8)),
          axis.title.x = element_text(size = rel(0.85)),
          axis.text.y = element_text(size = rel(0.7), hjust = 0, lineheight = 0.85),
          plot.caption = element_text(margin = margin(t = 8)))
}

# ---------------------------------------------------------------------------
# 4 bis. Données : exposition des ménages au prix du carburant
#    (Insee Première n° 2125, 08/09/2026, tableau complémentaire 3). Voir data/cm5/SOURCES.md.
#    « Particulièrement exposé » : le ménage consacre plus d'un mois de revenu
#    par an au carburant. Champ : ménages qui ont une voiture.
# ---------------------------------------------------------------------------
carburant_cm5 <- read.csv(here::here("data/cm5/insee_ip2125_tc3_exposition.csv"))

#' Part des ménages qui ont une voiture et consacrent plus d'un mois de revenu
#' au carburant, en ville, à la campagne et en moyenne : aux prix de 2021
#' (azur) et aux prix du printemps 2026 appliqués à 2021 (ambre ; scénario de
#' l'Insee, revenus et kilomètres inchangés).
#' @param base_size 16 (page) ou 24 (diapos)
#' @param etape pour les diapos : 1 = prix de 2021 seuls ; 2 = figure complète
#'   avec les prix du printemps 2026, identique à la page (défaut)
graphe_carburant <- function(base_size = 16, etape = 2) {
  noms <- c("Intercommunalités urbaines" = "Urbain", "Intercommunalités rurales" = "Rural",
            "Ensemble" = "Ensemble")
  e <- carburant_cm5[carburant_cm5$type_interco %in% names(noms), ]
  e$nom <- factor(noms[e$type_interco], levels = rev(noms))
  series <- c("Aux prix moyens de 2021", "Aux prix du printemps 2026")   # 2,0 €/l essence, 2,2 €/l gazole
  long <- rbind(data.frame(nom = e$nom, serie = series[1], valeur = e$part_exposes_prix_2021),
                data.frame(nom = e$nom, serie = series[2], valeur = e$part_exposes_prix_2026))
  long$serie <- factor(long$serie, levels = rev(series))   # 2021 en haut de chaque groupe
  if (etape < 2) long <- long[long$serie == series[1], ]   # prix de 2021 seuls
  dodge <- position_dodge(width = 0.8)
  ggplot(long, aes(x = valeur, y = nom, fill = serie)) +
    geom_col(position = dodge, width = 0.75) +
    geom_text(aes(x = valeur + 0.6, label = paste0(fr_num(valeur), " %")), position = dodge,
              hjust = 0, family = police_cours, size = base_size / 3.6) +
    scale_fill_manual(values = setNames(unname(couleurs_eco[c("demande", "offre")]), series),
                      breaks = series) +
    scale_x_continuous(breaks = seq(0, 30, 10), limits = c(0, 36), expand = c(0, 0)) +
    labs(x = "Ménages avec voiture très exposés au prix du carburant (%)", y = NULL,
         caption = "Source : Insee, Insee Première n° 2125, 08/09/2026\n(données Fidéli 2022 ; SDES, RSVERO).") +
    guides(fill = guide_legend(ncol = 1)) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = scales::alpha(couleurs_eco[["neutre"]], 0.4), linewidth = 0.4),
          axis.line.x = element_blank(), axis.text.x = element_text(size = rel(0.8)),
          axis.title.x = element_text(size = rel(0.85)),
          axis.text.y = element_text(size = rel(0.9)),
          plot.caption = element_text(margin = margin(t = 8)))
}

# ---------------------------------------------------------------------------
# 5. Vérifications : chaque chiffre du texte
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-9) all(abs(x - y) < tol)
stopifnot(
  # Exemple 1
  proche(unlist(ex_cm5[c("cms", "q_marche", "q_optimum", "perte", "t", "recette", "evite",
                         "perte_cond", "subvention", "valeur_ecartee", "perte_norme", "bilan_norme")]),
         c(6, 8, 6, 2, 2, 12, 4, 2, 4, 10, 12, -8)),
  proche(ex_cm5$evite - ex_cm5$perte_cond, ex_cm5$perte),   # gain net de la taxe = perte sèche supprimée
  proche(marche_cm5$dm * c(ex_cm5$q_marche, ex_cm5$q_optimum), c(16, 12)),   # pollution subie : sans rien, à l'optimum
  proche(ex_cm5$recette, marche_cm5$dm * ex_cm5$q_optimum),                  # recette = dommage restant
  # Exemple 2
  proche(weitzman_cm5$q_taxe, c(5, 7)), proche(weitzman_cm5$q_marche, c(7, 9)),
  all(weitzman_cm5$q_marche > weitzman_cm5$norme),
  proche(weitzman_cm5$cout_norme, c(1, 3)),
  proche(weitzman_cm5$perte_norme, c(0.5, 0.5)),                             # 500 € par jour
  # Exemple 3 (effet propre, chiffres fictifs) : −39 − (−34) = −5 points
  proche((61 - 100) - (66 - 100), -5),
  proche(mean(c(weitzman_cm5$d_bas, weitzman_cm5$d_haut)), marche_cm5$d_a),
  # Insee, émissions : NOx exact ; PM2,5 et CO2 au dixième près (arrondis de l'Insee)
  nrow(effets_zfe_cm5) == 3,
  proche(effets_zfe_cm5$variation_observee, c(-38.9, -31.1, -10.0)),
  proche(effets_zfe_cm5$effet_points, c(-4.6, -1.4, -1.7)),
  proche(effets_zfe_cm5$variation_observee - effets_zfe_cm5$variation_contrefactuelle,
         effets_zfe_cm5$effet_points, tol = 0.15),
  all(effets_zfe_cm5$variation_observee < effets_zfe_cm5$ic_bas),   # observé hors de l'intervalle : effet net
  # Insee, parc : Crit'Air 1 et E, 3 ; Crit'Air 5 dans l'intervalle (non significatif)
  proche(parc_zfe_cm5$variation_observee[c(1, 3)], c(88.4, -34.5)),
  proche(parc_zfe_cm5$variation_contrefactuelle[c(1, 3)], c(82.6, -30.0)),
  with(parc_zfe_cm5[1:4, ], proche(variation_observee - variation_contrefactuelle, effet_points, tol = 0.05)),
  is.na(parc_zfe_cm5$effet_points[5]),
  parc_zfe_cm5$variation_observee[5] > parc_zfe_cm5$ic_bas[5],
  parc_zfe_cm5$variation_observee[5] < parc_zfe_cm5$ic_haut[5],
  # Crit'Air 5 et non classées : 223 400 sur 3,6 millions, environ 6 % du parc de départ
  parc_zfe_cm5$vehicules_avant[5] == 223400,
  round(sum(parc_zfe_cm5$vehicules_avant) / 1e6, 1) == 3.6,
  round(100 * parc_zfe_cm5$vehicules_avant[5] / sum(parc_zfe_cm5$vehicules_avant)) == 6,
  # Figure du parc : Crit'Air 5 observé −64,1 %, dans l'intervalle du contrefactuel
  proche(parc_zfe_cm5$variation_observee[5], -64.1),
  # Insee Première n° 2125 : 13,5 % (rural) contre 9,0 % (urbain) en 2021 ;
  # 29,0 % contre 18,8 % aux prix du printemps 2026 ; écart de 4,5 puis 10,2 points ; 22,4 % en moyenne
  nrow(carburant_cm5) == 7,
  with(carburant_cm5, proche(part_exposes_prix_2021[c(4, 1, 7)], c(13.5, 9.0, 10.6))),
  with(carburant_cm5, proche(part_exposes_prix_2026[c(4, 1, 7)], c(29.0, 18.8, 22.4))),
  with(carburant_cm5, proche(c(part_exposes_prix_2021[4] - part_exposes_prix_2021[1],
                               part_exposes_prix_2026[4] - part_exposes_prix_2026[1]), c(4.5, 10.2))),
  # « la part des ménages très exposés double à peu près partout » : rapport entre 1,9 et 2,2
  # dans chacun des sept types d'intercommunalité (de 1,97 en rural non périurbain à 2,18)
  with(carburant_cm5, all(part_exposes_prix_2026 / part_exposes_prix_2021 > 1.9 &
                          part_exposes_prix_2026 / part_exposes_prix_2021 < 2.2))
)
