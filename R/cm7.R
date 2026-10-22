# cm7.R · graphiques du CM 7 (BCE, inflation, taux réel),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, police_cours, theme_cours).
#
# Les valeurs de cours/cm7.qmd issues des données de data/cm7/ (taux de la BCE,
# IPCH, crédits à l'habitat) et les calculs qui en découlent sont lus ou calculés
# ici, puis vérifiés par les stopifnot() en fin de fichier. Les chiffres cités
# d'après d'autres sources (contribution de l'énergie, projections de la BCE,
# Insee, livret A, The Conversation) ne sont pas dans ces données : leur source
# et leur date sont données dans la page, là où ils apparaissent.

# ---------------------------------------------------------------------------
# 1. Données (provenance : data/cm7/SOURCES.md, téléchargées le 21/10/2026)
# ---------------------------------------------------------------------------
taux_bce_cm7 <- utils::read.csv(here::here("data/cm7/taux_bce_2019_2026.csv"))
taux_bce_cm7$date <- as.Date(taux_bce_cm7$date)
ipch_cm7 <- utils::read.csv(here::here("data/cm7/ipch_2021_2026.csv"))
# Coût des nouveaux crédits à l'habitat des ménages, France, mensuel (BCE, MIR)
credit_habitat_cm7 <- utils::read.csv(here::here("data/cm7/taux_credit_habitat_fr_2021_2026.csv"))
date_arret_cm7 <- as.Date("2026-10-21")   # faits arrêtés au 21/10/2026

#' Taux de dépôt (ou de refinancement, ou de prêt marginal) en vigueur à une date donnée.
#' La série BCE ne donne que les dates de changement : on prend le dernier
#' changement intervenu au plus tard ce jour-là.
taux_en_vigueur <- function(jour, taux = "depot") {
  d <- taux_bce_cm7[taux_bce_cm7$date <= as.Date(jour), ]
  utils::tail(d[[taux]], 1)
}

#' Inflation IPCH sur un an (%) pour un mois « AAAA-MM », une zone, une série.
inflation_mois <- function(mois, zone = "EA", serie = "ensemble") {
  x <- ipch_cm7$inflation[ipch_cm7$mois == mois & ipch_cm7$zone == zone & ipch_cm7$serie == serie]
  stopifnot(length(x) == 1)
  x
}

#' Relation de Fisher approchée : taux réel ≈ taux nominal − inflation.
#' Avec l'inflation observée, c'est un taux réel « ex post ».
taux_reel <- function(i, infl) i - infl

#' Arrondi à une décimale, 0,05 vers le haut en valeur absolue (−9,85 → −9,9).
#' Le 1e-9 compense l'écriture binaire (0,75 − 10,6 vaut −9,8499… en machine).
arrondi1 <- function(x) round(x + sign(x) * 1e-9, 1)

#' Règle de Taylor (1993), forme usuelle :
#' i = taux réel neutre + π + 0,5 × (π − cible) + 0,5 × écart de production.
#' Avec les valeurs de Taylor (neutre 2 %, cible 2 %), i = 1 + 1,5 π + 0,5 × écart.
taux_taylor <- function(infl, ecart = 0, cible = 2, neutre = 2) {
  neutre + infl + 0.5 * (infl - cible) + 0.5 * ecart
}

# ---------------------------------------------------------------------------
# 2. Graphique de données : taux de dépôt de la BCE et inflation, 2021-2026
# ---------------------------------------------------------------------------

#' Taux de dépôt (escalier) et inflation de la zone euro (ligne), de janvier
#' 2021 au 21/10/2026. Deux segments rouges matérialisent le taux réel ex post
#' (écart entre les deux courbes) en octobre 2022 (son point le plus bas) et en
#' septembre 2026.
graphe_taux_inflation <- function(base_size = 16) {
  debut <- as.Date("2021-01-01")
  depot <- escalier_depot(debut)   # défini plus bas, appelé seulement à l'exécution
  infl <- subset(ipch_cm7, zone == "EA" & serie == "ensemble")
  infl$date <- as.Date(paste0(infl$mois, "-15"))   # point placé au milieu du mois
  serie_taux <- "Taux de dépôt de la BCE"
  serie_infl <- "Inflation (IPCH, zone euro, sur un an)"
  couleurs <- stats::setNames(unname(couleurs_eco[c("demande", "offre")]), c(serie_taux, serie_infl))
  # écarts commentés dans le texte (taux réel ex post)
  ecarts <- data.frame(
    date = as.Date(c("2022-10-15", "2026-09-15")),
    bas  = c(taux_en_vigueur("2022-10-31"), taux_en_vigueur("2026-09-30")),
    haut = c(inflation_mois("2022-10"), inflation_mois("2026-09"))
  )
  reel <- sub("-", "−", format(arrondi1(taux_reel(ecarts$bas, ecarts$haut)), decimal.mark = ",",
                               drop0trailing = TRUE), fixed = TRUE)
  ecarts$lab <- paste0("taux réel\n", c("oct. 2022", "sept. 2026"), " :\n≈ ", reel, " %")
  ecarts$x_lab <- as.Date(c("2021-01-15", "2026-09-30")); ecarts$y_lab <- c(10.8, 10.2)
  taille <- base_size / 3.4
  ggplot() +
    annotate("segment", x = debut, xend = date_arret_cm7, y = 2, yend = 2,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    annotate("text", x = as.Date("2023-10-01"), y = 1.1, label = "cible : 2 %", hjust = 0,
             family = police_cours, size = taille, colour = couleurs_eco[["neutre"]]) +
    geom_segment(data = ecarts, aes(x = date, xend = date, y = bas, yend = haut),
                 colour = couleurs_eco[["alerte"]], linewidth = 1.3) +
    geom_text(data = ecarts, aes(x = x_lab, y = y_lab, label = lab),
              hjust = c(0, 1), vjust = 1, family = police_cours, size = taille, colour = couleurs_eco[["alerte"]],
              lineheight = 0.9) +
    geom_line(data = infl, aes(date, inflation, colour = serie_infl), linewidth = 1.2) +
    geom_step(data = depot, aes(date, depot, colour = serie_taux), linewidth = 1.2) +
    scale_colour_manual(values = couleurs, breaks = c(serie_infl, serie_taux)) +
    scale_x_date(breaks = as.Date(paste0(2021:2026, "-01-01")), date_labels = "%Y") +
    scale_y_continuous(breaks = seq(0, 10, 2), labels = function(x) paste0(x, " %")) +
    coord_cartesian(ylim = c(-1, 11)) +
    labs(x = NULL, y = NULL,
         caption = "Sources : BCE (taux de dépôt) ; Eurostat (inflation).\nConsultés le 21/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)),
          legend.direction = "vertical")
}

#' Escalier du taux de dépôt de janvier 2021 au jour d'arrêt (partagé par les
#' graphiques de données) : valeur au 01/01/2021, chaque changement, puis
#' prolongement jusqu'au 21/10/2026.
escalier_depot <- function(debut = as.Date("2021-01-01")) {
  chg <- taux_bce_cm7[taux_bce_cm7$date > debut, c("date", "depot")]
  rbind(data.frame(date = debut, depot = taux_en_vigueur(debut)), chg,
        data.frame(date = date_arret_cm7, depot = utils::tail(chg$depot, 1)))
}

# ---------------------------------------------------------------------------
# 2 bis. Graphique de données : la transmission aux taux des crédits
# ---------------------------------------------------------------------------

#' Taux de dépôt de la BCE (escalier) et coût moyen des nouveaux crédits à
#' l'habitat des ménages en France (ligne mensuelle), 2021-2026. Montre l'étape 1
#' de la transmission : les banques répercutent la hausse, avec retard, et la
#' baisse de 2024-2025 en partie seulement.
graphe_credit_habitat <- function(base_size = 16) {
  depot <- escalier_depot()
  cred <- credit_habitat_cm7
  cred$date <- as.Date(paste0(cred$mois, "-15"))   # point au milieu du mois
  serie_taux <- "Taux de dépôt de la BCE"
  serie_cred <- "Taux des nouveaux crédits à l'habitat (France)"
  couleurs <- stats::setNames(unname(couleurs_eco[c("demande", "offre")]), c(serie_taux, serie_cred))
  ggplot() +
    geom_step(data = depot, aes(date, depot, colour = serie_taux), linewidth = 1.2) +
    geom_line(data = cred, aes(date, taux, colour = serie_cred), linewidth = 1.2) +
    scale_colour_manual(values = couleurs, breaks = c(serie_cred, serie_taux)) +
    scale_x_date(breaks = as.Date(paste0(2021:2026, "-01-01")), date_labels = "%Y") +
    scale_y_continuous(breaks = 0:4, labels = function(x) paste0(x, " %")) +
    coord_cartesian(ylim = c(-0.8, 4.3)) +
    labs(x = NULL, y = NULL,
         caption = "Sources : BCE (taux de dépôt ; statistiques des taux d'intérêt bancaires, MIR).\nConsultés le 21/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)),
          legend.direction = "vertical")
}

# ---------------------------------------------------------------------------
# 2 ter. Graphique de données : inflation totale et inflation hors énergie
# ---------------------------------------------------------------------------

#' Inflation de la zone euro (IPCH, sur un an), 2021-2026 : ensemble, hors
#' énergie, hors énergie et alimentation. Si les courbes « hors » montent, le
#' choc s'est diffusé au reste des prix (effets de second tour).
graphe_inflation_diffusion <- function(base_size = 16) {
  noms <- c(ensemble = "Ensemble",
            hors_energie = "Hors énergie",
            hors_energie_alimentation = "Hors énergie et alimentation")
  d <- subset(ipch_cm7, zone == "EA" & serie %in% names(noms))
  d$serie <- factor(noms[d$serie], levels = unname(noms))
  d$date <- as.Date(paste0(d$mois, "-15"))
  couleurs <- stats::setNames(unname(couleurs_eco[c("offre", "demande", "equilibre")]), unname(noms))
  taille <- base_size / 3.4
  ggplot(d, aes(date, inflation, colour = serie)) +
    annotate("segment", x = min(d$date), xend = max(d$date), y = 2, yend = 2,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    annotate("text", x = as.Date("2022-09-01"), y = 1.4, label = "cible : 2 %", hjust = 0,   # zone libre sous les courbes
             family = police_cours, size = taille, colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.2) +
    scale_colour_manual(values = couleurs) +
    scale_x_date(breaks = as.Date(paste0(2021:2026, "-01-01")), date_labels = "%Y") +
    scale_y_continuous(breaks = seq(0, 10, 2), labels = function(x) paste0(x, " %")) +
    coord_cartesian(ylim = c(0, 11)) +
    labs(x = NULL, y = NULL,
         caption = "Source : Eurostat, IPCH (prc_hicp_minr), zone euro.\nConsulté le 21/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)),
          legend.direction = "vertical")
}

# ---------------------------------------------------------------------------
# 3. Graphique théorique : choc d'offre agrégé, puis hausse des taux
#    Demande agrégée D : P = 12 − Q ; offre agrégée O : P = Q.
#    Choc énergétique : O′ : P = Q + 4. Hausse des taux : D′ : P = 10 − Q.
#    E = (6 ; 6), E′ = (4 ; 8), E″ = (3 ; 7). Axes sans graduations chiffrées.
# ---------------------------------------------------------------------------
eq_cm7 <- list(
  E   = c(q = 6, p = 6),   # 12 − Q = Q
  E1  = c(q = 4, p = 8),   # 12 − Q = Q + 4
  E2  = c(q = 3, p = 7)    # 10 − Q = Q + 4
)

#' Offre et demande agrégées. etape = 1 : choc d'offre seul (O → O′) ;
#' etape = 2 : on ajoute la hausse des taux (D → D′).
graphe_offre_demande_agregees <- function(etape = 2, base_size = 16) {
  q <- seq(0, 10, length.out = 60)
  d <- data.frame(q = q, D = 12 - q, D2 = 10 - q, O = q, O2 = q + 4)
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  pts <- if (etape == 1) eq_cm7[c("E", "E1")] else eq_cm7
  px <- vapply(pts, `[[`, numeric(1), "q"); py <- vapply(pts, `[[`, numeric(1), "p")
  g <- ggplot(d, aes(q)) +
    annotate("segment", x = px, xend = px, y = 0, yend = py, linetype = "22", colour = neutre) +
    annotate("segment", x = 0, xend = px, y = py, yend = py, linetype = "22", colour = neutre) +
    geom_line(aes(y = D), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = O), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    geom_line(aes(y = O2), colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22") +
    annotate("segment", x = 9.6, xend = 6.4, y = 10.3, yend = 10.3, colour = couleurs_eco[["offre"]],
             linewidth = 0.7, arrow = grid::arrow(length = grid::unit(0.25, "cm"), type = "closed")) +
    annotate("text", x = c(10.3, 6.6, 1.3), y = c(9.9, 11.6, 11.6), label = c("O", "O′", "D"),
             colour = couleurs_eco[c("offre", "offre", "demande")], family = police_cours, size = taille)
  if (etape == 2) {
    g <- g +
      geom_line(aes(y = D2), colour = couleurs_eco[["demande"]], linewidth = 1.4, linetype = "22") +
      annotate("segment", x = 8.75, xend = 7.5, y = 2.9, yend = 2.9, colour = couleurs_eco[["demande"]],
               linewidth = 0.7, arrow = grid::arrow(length = grid::unit(0.25, "cm"), type = "closed")) +
      annotate("text", x = 9.9, y = 1.2, label = "D′", colour = couleurs_eco[["demande"]],
               family = police_cours, size = taille)
  }
  noms <- c(E = "E", E1 = "E′", E2 = "E″")[names(pts)]
  lab_x <- c(E = "Q*", E1 = "Q*′", E2 = "Q*″")[names(pts)]
  lab_y <- c(E = "P*", E1 = "P*′", E2 = "P*″")[names(pts)]
  g +
    annotate("point", x = px, y = py, size = 3, colour = couleurs_eco[["equilibre"]]) +
    # E″ se place à droite du point, dans l'angle libre entre O′ et D′ (au-dessus, il chevauche D′ ou P*′)
    annotate("text", x = px + c(0, 0, 0.6)[seq_along(px)], y = py + c(0.75, 0.75, 0)[seq_along(px)],
             label = noms, family = police_cours, size = taille) +
    scale_x_continuous(breaks = px, labels = lab_x) +
    scale_y_continuous(breaks = py, labels = lab_y) +
    coord_cartesian(xlim = c(0, 10.5), ylim = c(0, 12.2), expand = FALSE, clip = "off") +
    labs(x = "Production Q", y = "Niveau général des prix P") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 4. Graphique de l'exemple : la règle de Taylor
#    Graduations chiffrées assumées : la figure illustre l'exemple chiffré.
#    Deux points observés (BCE) pour montrer l'écart à la règle.
# ---------------------------------------------------------------------------

#' Taux conseillé par la règle de Taylor (écart de production nul) et droite
#' « taux réel nul » (i = π), pour une inflation de 0 à 11 %.
graphe_taylor <- function(base_size = 16) {
  infl <- seq(0, 11, length.out = 50)
  d <- data.frame(infl = infl, taylor = taux_taylor(infl), nul = infl)
  exemple <- data.frame(infl = c(2, 4), i = taux_taylor(c(2, 4)))
  bce <- data.frame(infl = c(inflation_mois("2022-10"), inflation_mois("2026-09")),
                    i  = c(taux_en_vigueur("2022-10-31"), taux_en_vigueur("2026-09-30")),
                    lab = c("BCE, oct. 2022", "BCE, sept. 2026"))
  taille <- base_size / 3.4
  ggplot(d, aes(infl)) +
    geom_line(aes(y = nul), colour = couleurs_eco[["neutre"]], linewidth = 1, linetype = "22") +
    geom_line(aes(y = taylor), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    annotate("segment", x = exemple$infl, xend = exemple$infl, y = 0, yend = exemple$i,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    annotate("segment", x = 0, xend = exemple$infl, y = exemple$i, yend = exemple$i,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    annotate("point", x = exemple$infl, y = exemple$i, size = 3, colour = couleurs_eco[["equilibre"]]) +
    geom_point(data = bce, aes(infl, i), shape = 17, size = 3.2, colour = couleurs_eco[["alerte"]]) +
    geom_text(data = bce, aes(infl + c(0, 0.35), i + c(1.4, 0), label = lab), hjust = c(1, 0),
              family = police_cours, size = taille, colour = couleurs_eco[["alerte"]]) +
    annotate("text", x = c(6.3, 10.8), y = c(12.5, 7), hjust = 1,
             label = c("règle de Taylor", "taux réel nul (i = π)"),
             colour = couleurs_eco[c("demande", "neutre")], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(0, 2, 4, 6, 8, 10), labels = function(x) paste0(x, " %")) +
    scale_y_continuous(breaks = c(0, 4, 7, 10, 15), labels = function(x) paste0(x, " %")) +
    coord_cartesian(xlim = c(0, 11.3), ylim = c(0, 18), expand = FALSE, clip = "off") +
    labs(x = "Inflation π", y = "Taux directeur i") +
    theme_cours(base_size = base_size) +
    theme(axis.text = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 5. Vérifications : chaque chiffre annoncé dans cours/cm7.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# Taux de dépôt de la BCE (BCE, Data Portal)
stopifnot(
  nrow(taux_bce_cm7) == 21, !anyNA(taux_bce_cm7),
  proche(taux_en_vigueur("2022-07-26"), -0.50),                 # −0,50 % depuis le 18/09/2019
  proche(taux_en_vigueur("2022-07-27"), 0),
  proche(taux_en_vigueur("2023-09-20"), 4), proche(taux_en_vigueur("2023-09-20", "refinancement"), 4.5),
  proche(taux_en_vigueur("2025-06-11"), 2), proche(taux_en_vigueur("2026-06-16"), 2),   # inchangé de juin 2025 à juin 2026
  proche(taux_en_vigueur("2026-06-17"), 2.25), proche(taux_en_vigueur("2026-09-16"), 2.5),
  proche(taux_en_vigueur("2026-09-16", "refinancement"), 2.65),
  proche(taux_en_vigueur("2026-09-16", "pret_marginal"), 2.9),
  proche(taux_en_vigueur("2026-09-16") - taux_en_vigueur("2026-06-16"), 0.5),   # +0,50 point en 2026
  proche(taux_en_vigueur("2022-10-31"), 0.75), proche(taux_en_vigueur("2022-11-02"), 1.5)
)
# Deux hausses avant fin octobre 2022 (27/07 et 14/09)
stopifnot(nrow(subset(taux_bce_cm7, date >= as.Date("2022-07-27") & date <= as.Date("2022-10-31"))) == 2)
# Dix hausses du 27/07/2022 au 20/09/2023, +450 points de base au total
hausses_2022_2023 <- subset(taux_bce_cm7, date >= as.Date("2022-07-27") & date <= as.Date("2023-09-20"))
stopifnot(nrow(hausses_2022_2023) == 10, all(diff(c(-0.5, hausses_2022_2023$depot)) > 0),
          proche((taux_en_vigueur("2023-09-20") - taux_en_vigueur("2022-07-26")) * 100, 450))
# Inflation IPCH (Eurostat, prc_hicp_minr)
stopifnot(
  proche(inflation_mois("2026-09"), 3.8), proche(inflation_mois("2025-09"), 2.2),
  proche(inflation_mois("2026-08"), 3.2),
  proche(inflation_mois("2026-05"), 3.2), proche(inflation_mois("2022-06"), 8.6),
  proche(inflation_mois("2022-10"), 10.6), proche(inflation_mois("2022-11"), 10.1),
  proche(inflation_mois("2023-10"), 2.9),
  proche(max(subset(ipch_cm7, zone == "EA" & serie == "ensemble")$inflation), 10.6),
  proche(inflation_mois("2022-10", "DE"), 11.6),
  proche(max(subset(ipch_cm7, zone == "DE" & serie == "ensemble")$inflation), 11.6),
  proche(inflation_mois("2022-10", "FR"), 7.1),
  proche(max(subset(ipch_cm7, zone == "FR" & serie == "ensemble")$inflation), 7.3),
  proche(inflation_mois("2023-02", "FR"), 7.3),
  proche(inflation_mois("2026-09", "DE"), 3.3), proche(inflation_mois("2026-09", "FR"), 3.4),
  proche(inflation_mois("2026-09", "ES"), 5.0), proche(inflation_mois("2026-09", "IT"), 4.2),
  proche(inflation_mois("2022-10", "EA", "energie"), 41.5),
  proche(inflation_mois("2022-10", "EA", "hors_energie"), 6.9),
  proche(inflation_mois("2026-09", "EA", "energie"), 18.9),
  proche(inflation_mois("2026-09", "EA", "hors_energie"), 2.3),
  proche(inflation_mois("2022-10", "EA", "alimentation"), 13.1),
  proche(inflation_mois("2026-09", "EA", "alimentation"), 1.3),
  proche(inflation_mois("2022-10", "EA", "hors_energie_alimentation"), 5.0),
  proche(inflation_mois("2026-09", "EA", "hors_energie_alimentation"), 2.5)
)
# Diffusion (@fig-inflation-diffusion) : pic de l'ensemble en octobre 2022, des
# indices « hors » en mars 2023 ; en 2026, hors énergie et alimentation entre 2,2 et 2,6 %
ea_serie <- function(s) subset(ipch_cm7, zone == "EA" & serie == s)
stopifnot(
  ea_serie("ensemble")$mois[which.max(ea_serie("ensemble")$inflation)] == "2022-10",
  ea_serie("hors_energie")$mois[which.max(ea_serie("hors_energie")$inflation)] == "2023-03",
  proche(max(ea_serie("hors_energie")$inflation), 7.9),
  ea_serie("hors_energie_alimentation")$mois[which.max(ea_serie("hors_energie_alimentation")$inflation)] == "2023-03",
  proche(max(ea_serie("hors_energie_alimentation")$inflation), 5.7),
  proche(range(subset(ea_serie("hors_energie_alimentation"), mois >= "2026-01")$inflation), c(2.2, 2.6)),
  nrow(subset(ea_serie("hors_energie_alimentation"), mois >= "2026-01")) == 9
)
# Crédits à l'habitat, France (@fig-credit-habitat) : 1,1 % en décembre 2021,
# point haut 3,6 % en décembre 2023 (trois mois après la dernière hausse du 20/09/2023),
# 3,0 % en décembre 2025 (taux de dépôt à 2 %), 3,2 % en août 2026 (dernier mois connu)
credit_mois <- function(m) credit_habitat_cm7$taux[credit_habitat_cm7$mois == m]
stopifnot(
  nrow(credit_habitat_cm7) == 68, !anyNA(credit_habitat_cm7),
  utils::tail(credit_habitat_cm7$mois, 1) == "2026-08",
  proche(round(credit_mois("2021-12"), 1), 1.1),
  credit_habitat_cm7$mois[which.max(credit_habitat_cm7$taux)] == "2023-12",
  proche(credit_mois("2023-12"), 3.6),
  proche(round(credit_mois("2025-12"), 1), 3.0), proche(taux_en_vigueur("2025-12-31"), 2),
  proche(round(credit_mois("2026-08"), 1), 3.2)
)
# fig-alt : crédit sous le taux de dépôt (fin de mois) de février 2023 à fin 2024 seulement
fin_mois_cred <- seq(as.Date("2021-02-01"), by = "month", length.out = nrow(credit_habitat_cm7)) - 1
sous_depot <- credit_habitat_cm7$mois[credit_habitat_cm7$taux < vapply(fin_mois_cred, taux_en_vigueur, numeric(1))]
stopifnot(min(sous_depot) == "2023-02", max(sous_depot) == "2024-11")
# Relation de Fisher : exemple chiffré (nombres ronds) et cas réels (taux réel ex post)
stopifnot(
  proche(taux_reel(4, 10), -6), proche(taux_reel(4, 2), 2),
  proche(10000 * 1.04, 10400), proche(10000 * 1.10, 11000), proche(10000 * 1.02, 10200),
  proche((10400 - 11000) / 10000 * 100, -6), proche((10400 - 10200) / 10000 * 100, 2),
  proche(round((1.04 / 1.10 - 1) * 100, 1), -5.5),               # valeur exacte, proche de −6
  proche(taux_reel(taux_en_vigueur("2022-10-31"), inflation_mois("2022-10")), -9.85),
  proche(arrondi1(taux_reel(taux_en_vigueur("2022-10-31"), inflation_mois("2022-10"))), -9.9),   # « environ −9,9 % »
  proche(arrondi1(taux_reel(taux_en_vigueur("2026-09-30"), inflation_mois("2026-09"))), -1.3),
  proche(taux_reel(taux_en_vigueur("2023-10-15"), inflation_mois("2023-10")), 1.1),
  proche(taux_reel(taux_en_vigueur("2026-09-30"), inflation_mois("2026-09")), -1.3),
  proche(taux_reel(2.5, inflation_mois("2026-09", "ES")), -2.5),
  proche(taux_reel(2.5, inflation_mois("2026-09", "DE")), -0.8),
  proche(taux_reel(2.5, inflation_mois("2026-09", "FR")), -0.9),
  proche(taux_reel(2.5, inflation_mois("2026-09", "IT")), -1.7),
  proche(1.7 - 3.1, -1.4)    # calcul seul : livret A (Service-public.fr) et IPC France (Insee), hors données
)
# Taux réel ex post mensuel (taux de dépôt en fin de mois − inflation du mois) :
# point bas en octobre 2022 sur 2021-2026 ; premier mois positif après juillet 2022 : octobre 2023
infl_ea <- subset(ipch_cm7, zone == "EA" & serie == "ensemble")
fin_mois <- seq(as.Date(paste0(infl_ea$mois[1], "-01")), by = "month", length.out = nrow(infl_ea) + 1)[-1] - 1
reel_mensuel <- vapply(fin_mois, taux_en_vigueur, numeric(1)) - infl_ea$inflation
stopifnot(infl_ea$mois[which.min(reel_mensuel)] == "2022-10",
          infl_ea$mois[infl_ea$mois > "2022-07" & reel_mensuel > 0][1] == "2023-10")
# Règle de Taylor : exemple (2 % puis 4 % d'inflation) et ordres de grandeur cités
stopifnot(
  proche(taux_taylor(2), 4), proche(taux_taylor(4), 7),
  proche(taux_reel(taux_taylor(2), 2), 2), proche(taux_reel(taux_taylor(4), 4), 3),
  proche(taux_taylor(4, ecart = -2), 6),
  proche(taux_taylor(7), 11.5), proche(round(taux_taylor(10.6), 1), 16.9),
  proche(taux_taylor(4) - taux_taylor(2), 3),
  proche(round(taux_taylor(3.8), 1), 6.7), proche(taux_taylor(2.3), 4.45)
)
# Théorie quantitative en taux de croissance (approximation), nombres fictifs : 10 % de monnaie, 2 % de production
stopifnot(proche(10 + 0 - 2, 8))
# Graphique théorique : équilibres annoncés
stopifnot(
  proche(12 - eq_cm7$E[["q"]], eq_cm7$E[["p"]]), proche(eq_cm7$E[["q"]], eq_cm7$E[["p"]]),
  proche(12 - eq_cm7$E1[["q"]], eq_cm7$E1[["p"]]), proche(eq_cm7$E1[["q"]] + 4, eq_cm7$E1[["p"]]),
  proche(10 - eq_cm7$E2[["q"]], eq_cm7$E2[["p"]]), proche(eq_cm7$E2[["q"]] + 4, eq_cm7$E2[["p"]]),
  eq_cm7$E2[["p"]] < eq_cm7$E1[["p"]], eq_cm7$E2[["q"]] < eq_cm7$E1[["q"]]
)
