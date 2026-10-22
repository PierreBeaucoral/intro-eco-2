# cm1.R · graphiques du CM 1 (crise d'Ormuz, prix des carburants),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm1.qmd sont définies ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.

# ---------------------------------------------------------------------------
# 1. Le marché fictif de l'exemple chiffré (Exemple 2 de la page)
#    Q en millions de litres par jour, P en euros par litre.
#    Demande peu élastique : Qd = 134 - 20 P
#    Offre avant le choc   : Qo = 66 + 20 P
#    Offre après le choc   : Qo' = 46 + 20 P (20 de moins à chaque prix)
#    Demande élastique (comparaison) : Qd = 202 - 60 P
# ---------------------------------------------------------------------------
marche_cm1 <- list(
  d_a = 134, d_b = 20,     # demande peu élastique
  de_a = 202, de_b = 60,   # demande élastique
  o_a = 66, o_b = 20,      # offre
  choc = 20                # baisse de la quantité offerte à chaque prix
)

#' Équilibre d'une demande Q = a - b P et d'une offre Q = c + s P
#' @return liste (p, q)
equilibre_lineaire <- function(a, b, c, s) {
  p <- (a - c) / (b + s)
  list(p = p, q = a - b * p)
}

eq_avant   <- equilibre_lineaire(marche_cm1$d_a, marche_cm1$d_b, marche_cm1$o_a, marche_cm1$o_b)
eq_apres   <- equilibre_lineaire(marche_cm1$d_a, marche_cm1$d_b, marche_cm1$o_a - marche_cm1$choc, marche_cm1$o_b)
eq_avant_e <- equilibre_lineaire(marche_cm1$de_a, marche_cm1$de_b, marche_cm1$o_a, marche_cm1$o_b)
eq_apres_e <- equilibre_lineaire(marche_cm1$de_a, marche_cm1$de_b, marche_cm1$o_a - marche_cm1$choc, marche_cm1$o_b)

#' Variation en pourcentage de x0 à x1
var_pct <- function(x0, x1) 100 * (x1 - x0) / x0

# ---------------------------------------------------------------------------
# 2. Graphique théorique : choc d'offre négatif (O -> O')
# ---------------------------------------------------------------------------

#' Choc d'offre sur un marché à demande peu élastique.
#' La géométrie est celle de l'exemple chiffré, mais les axes ne portent que
#' P*, P*', Q*, Q*' (graphique théorique, sans graduations chiffrées).
#' @param penurie si TRUE, montre l'écart entre demande et offre au prix initial
#' @param base_size 16 (page) ou 24 (diapos)
#' @param etape construction pas à pas pour les diapos : 1 = équilibre initial
#'   (D, O, E) ; 2 = ajoute le choc (O′, flèche, pénurie) ; 3 = figure complète
#'   (E′, P*′, Q*′), identique à celle de la page (valeur par défaut)
graphe_choc_offre <- function(penurie = TRUE, base_size = 16, etape = 3) {
  q <- seq(70, 120, length.out = 60)
  d <- data.frame(q = q,
                  demande = (marche_cm1$d_a - q) / marche_cm1$d_b,
                  offre   = (q - marche_cm1$o_a) / marche_cm1$o_b,
                  offre2  = (q - (marche_cm1$o_a - marche_cm1$choc)) / marche_cm1$o_b)
  p0 <- eq_avant$p; q0 <- eq_avant$q; p1 <- eq_apres$p; q1 <- eq_apres$q
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  i_eq <- if (etape >= 3) 1:2 else 1           # E seul, ou E et E′
  i_tir <- if (etape >= 3) 1:4 else 1:2        # tirets vers P*, Q* (puis P*′, Q*′)
  i_lab <- if (etape >= 2) 1:3 else 1:2        # D, O (puis O′)
  g <- ggplot(d, aes(q)) +
    annotate("segment", x = c(q0, 70, q1, 70)[i_tir], xend = c(q0, q0, q1, q1)[i_tir],
             y = c(1.2, p0, 1.2, p1)[i_tir], yend = c(p0, p0, p1, p1)[i_tir],
             linetype = "22", colour = neutre) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    geom_line(aes(y = offre2), colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22") +
    # flèche du déplacement de l'offre, vers la gauche, de O vers O′ ; placée
    # au-dessus de E′ pour ne pas toucher son étiquette
    annotate("segment", x = 115, xend = 96, y = 2.45, yend = 2.45,
             colour = couleurs_eco[["offre"]], linewidth = 0.7,
             arrow = grid::arrow(length = grid::unit(0.25, "cm"), type = "closed"))
  if (penurie && etape >= 2) {
    q_o2_p0 <- marche_cm1$o_a - marche_cm1$choc + marche_cm1$o_b * p0   # quantité offerte après le choc, au prix initial
    g <- g +
      annotate("segment", x = q_o2_p0, xend = q0, y = p0, yend = p0,
               colour = couleurs_eco[["alerte"]], linewidth = 1.6) +
      annotate("text", x = (q_o2_p0 + q0) / 2, y = p0 - 0.09, label = "pénurie",
               colour = couleurs_eco[["alerte"]], family = police_cours, size = taille)
  }
  g +
    annotate("point", x = c(q0, q1)[i_eq], y = c(p0, p1)[i_eq], size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = c(q0 + 2.2, q1 + 2.4)[i_eq], y = c(p0 - 0.06, p1 + 0.06)[i_eq], label = c("E", "E′")[i_eq],
             family = police_cours, size = taille) +
    annotate("text", x = c(81, 117.5, 103)[i_lab], y = c(2.95, 2.75, 2.95)[i_lab], label = c("D", "O", "O′")[i_lab],
             colour = couleurs_eco[c("demande", "offre", "offre")][i_lab], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(q1, q0)[3 - rev(i_eq)], labels = c("Q*′", "Q*")[3 - rev(i_eq)]) +
    scale_y_continuous(breaks = c(p0, p1)[i_eq], labels = c("P*", "P*′")[i_eq]) +
    coord_cartesian(xlim = c(70, 120), ylim = c(1.2, 3.1), expand = FALSE, clip = "on") +   # les courbes s'arrêtent au cadre
    labs(x = "Quantité Q", y = "Prix P") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 3. Graphique théorique : même choc, deux demandes d'élasticité différente
# ---------------------------------------------------------------------------

#' Deux panneaux : demande peu élastique (à gauche) et élastique (à droite),
#' même offre O, même choc O -> O'. Les points reprennent les valeurs de
#' l'exemple chiffré : graduations chiffrées assumées, car la figure illustre
#' l'exemple 2. L'équilibre initial, commun aux deux panneaux (1,70 € ; 100),
#' est gradué sur les axes ; le nouvel équilibre de chaque panneau (2,20 € et
#' 90 ; 1,95 € et 85) est écrit dans son propre panneau, au pied des tirets.
#' @param etape construction pas à pas pour les diapos : 1 = équilibre initial
#'   commun (D, O, E) ; 2 = figure complète (O′, nouveaux équilibres), identique
#'   à celle de la page (valeur par défaut)
graphe_elasticite <- function(base_size = 16, etape = 2) {
  q <- seq(70, 120, length.out = 60)
  panneaux <- c("A. Peu élastique", "B. Élastique")
  d <- rbind(
    data.frame(panneau = panneaux[1], q = q, demande = (marche_cm1$d_a - q) / marche_cm1$d_b),
    data.frame(panneau = panneaux[2], q = q, demande = (marche_cm1$de_a - q) / marche_cm1$de_b)
  )
  d$offre  <- (d$q - marche_cm1$o_a) / marche_cm1$o_b
  d$offre2 <- (d$q - (marche_cm1$o_a - marche_cm1$choc)) / marche_cm1$o_b
  d$panneau <- factor(d$panneau, levels = panneaux)
  pts <- data.frame(panneau = factor(panneaux[c(1, 1, 2, 2)], levels = panneaux),
                    q = c(eq_avant$q, eq_apres$q, eq_avant_e$q, eq_apres_e$q),
                    p = c(eq_avant$p, eq_apres$p, eq_avant_e$p, eq_apres_e$p))
  # valeurs du nouvel équilibre, propres à chaque panneau : le prix sous le
  # tiret horizontal (bord gauche), la quantité à gauche du tiret vertical (bas)
  apres <- pts[c(2, 4), ]
  fmt <- function(x) format(x, decimal.mark = ",", nsmall = 2)
  valeurs <- rbind(
    data.frame(panneau = apres$panneau, q = 70.6, p = apres$p - 0.03,
               lab = fmt(apres$p), hjust = 0, vjust = 1),
    data.frame(panneau = apres$panneau, q = apres$q - 0.8, p = 1.23,
               lab = as.character(apres$q), hjust = 1, vjust = 0)
  )
  etiquettes <- data.frame(
    panneau = factor(panneaux[c(1, 1, 1, 2, 2, 2)], levels = panneaux),
    q = c(110, 117.5, 101, 117, 117.5, 101), p = c(1.38, 2.75, 2.95, 1.55, 2.75, 2.95),
    lab = c("D", "O", "O′", "D", "O", "O′"),
    col = unname(couleurs_eco[c("demande", "offre", "offre", "demande", "offre", "offre")])
  )
  if (etape < 2) {                              # ni O′, ni nouvel équilibre
    pts <- pts[c(1, 3), ]
    valeurs <- valeurs[0, ]
    etiquettes <- etiquettes[etiquettes$lab != "O′", ]
  }
  g <- ggplot(d, aes(q)) +
    geom_segment(data = pts, aes(x = q, xend = q, y = 1.2, yend = p),
                 linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_segment(data = pts, aes(x = 70, xend = q, y = p, yend = p),
                 linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    geom_line(aes(y = offre2), colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22")
  g +
    geom_point(data = pts, aes(y = p), size = 2.6, colour = couleurs_eco[["equilibre"]]) +
    geom_text(data = etiquettes, aes(x = q, y = p, label = lab, colour = col),
              family = police_cours, size = base_size / 3) +
    geom_text(data = valeurs, aes(x = q, y = p, label = lab, hjust = hjust, vjust = vjust),
              colour = couleurs_eco[["neutre"]], family = police_cours, size = base_size / 3.6) +
    scale_colour_identity() +
    facet_wrap(~panneau, nrow = 1) +
    scale_x_continuous(breaks = 100, labels = "100") +
    scale_y_continuous(breaks = 1.70, labels = "1,70") +
    coord_cartesian(xlim = c(70, 120), ylim = c(1.2, 3.1), expand = FALSE, clip = "on") +   # les courbes s'arrêtent au cadre
    labs(x = "Quantité Q (millions de litres par jour)", y = "Prix P (€/L)") +
    theme_cours(base_size = base_size) +
    theme(strip.text = element_text(family = police_cours, hjust = 0, size = rel(0.85)),
          panel.spacing = grid::unit(1.5, "lines"),
          axis.text.x = element_text(size = rel(0.8)), axis.text.y = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 4. Graphique de l'exemple 1 : l'offre comme escalier de coûts marginaux
#    Quatre producteurs fictifs (Golfe, X, Y, Z ; pas de lettre D, réservée
#    à la demande), 10 millions de barils par jour (Mb/j) chacun.
#    La demande de court terme est supposée fixe à 25 Mb/j (simplification).
#    25 tombe au milieu d'une marche, avant comme après le choc : l'équilibre
#    est unique. À 30 (un bord de marche), tout prix entre deux marches
#    conviendrait.
#    Graduations chiffrées assumées : la figure illustre l'exemple chiffré.
# ---------------------------------------------------------------------------
producteurs_cm1 <- data.frame(
  nom = c("Golfe", "X", "Y", "Z"),
  cm  = c(20, 40, 60, 80),   # coût marginal, $ par baril
  capacite = 10              # Mb/j
)
demande_fixe_cm1 <- 25

#' Prix d'équilibre quand la demande est fixe : coût marginal du dernier
#' producteur nécessaire pour servir la demande (producteurs classés par Cm).
#' Renvoie NA si la capacité totale ne suffit pas (le prix n'est alors plus
#' fixé par un coût : il monte jusqu'à rationner la demande).
prix_cout_marginal <- function(cm, capacite, demande) {
  cm <- sort(cm)
  cumul <- cumsum(rep_len(capacite, length(cm)))
  cm[which(cumul >= demande)[1]]
}
prix_cm_avant <- prix_cout_marginal(producteurs_cm1$cm, 10, demande_fixe_cm1)
prix_cm_apres <- prix_cout_marginal(producteurs_cm1$cm[-1], 10, demande_fixe_cm1)

#' Escalier d'offre avant (trait plein) et après le blocage du producteur du
#' Golfe (tirets) ; demande verticale à 25 Mb/j.
#' @param etape construction pas à pas pour les diapos : 1 = avant le choc
#'   (O, D, prix de 60 $) ; 2 = figure complète (O′, 80 $), identique à la page
graphe_cout_marginal <- function(base_size = 16, etape = 2) {
  escalier <- function(cm) {
    x <- c(0, cumsum(rep(10, length(cm))))
    data.frame(x = x, y = c(cm, utils::tail(cm, 1)))
  }
  avant <- escalier(producteurs_cm1$cm)
  apres <- escalier(producteurs_cm1$cm[-1])
  taille <- base_size / 3
  i_px <- if (etape >= 2) 1:2 else 1           # prix avant (60 $), puis après (80 $)
  i_lab <- if (etape >= 2) 1:3 else 1:2        # D, O (puis O′)
  g <- ggplot() +
    annotate("segment", x = 0, xend = demande_fixe_cm1, y = c(prix_cm_avant, prix_cm_apres)[i_px],
             yend = c(prix_cm_avant, prix_cm_apres)[i_px], linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_step(data = avant, aes(x, y), colour = couleurs_eco[["offre"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    geom_step(data = apres, aes(x, y), colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22")
  g +
    annotate("segment", x = demande_fixe_cm1, xend = demande_fixe_cm1, y = 0, yend = 95,
             colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    annotate("point", x = demande_fixe_cm1, y = c(prix_cm_avant, prix_cm_apres)[i_px], size = 3) +
    # étiquettes des courbes, puis des producteurs (sous chaque marche de O)
    annotate("text", x = c(26.5, 41, 1)[i_lab],
             y = c(95, 84, 46)[i_lab],
             label = c("D", "O", "O′")[i_lab],
             colour = couleurs_eco[c("demande", "offre", "offre")][i_lab],
             family = police_cours, size = taille, hjust = 0) +
    annotate("text", x = c(1, 13.5, 20.8, 33.5), y = c(14, 34, 54, 74),
             label = producteurs_cm1$nom, colour = couleurs_eco[["neutre"]],
             family = police_cours, size = taille * 0.85, hjust = 0) +
    scale_x_continuous(breaks = c(10, 20, 25, 30, 40), labels = c("10", "20", "25", "30", "40")) +
    scale_y_continuous(breaks = c(20, 40, 60, 80), labels = c("20", "40", "60", "80")) +
    coord_cartesian(xlim = c(0, 45), ylim = c(0, 100), expand = FALSE, clip = "off") +
    labs(x = "Quantité Q (Mb/j)", y = "Prix P ($ par baril)") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 5. Graphique de données : prix à la pompe en France, 2026
#    Commission européenne, Weekly Oil Bulletin, prix TTC, moyennes nationales
#    hebdomadaires, en euros pour 1 000 litres (feuille « Prices with taxes »).
#    Fichier et provenance : data/cm1/prix_pompe_fr_2026.csv et data/cm1/SOURCES.md
#    (téléchargé le 21/10/2026, 41 semaines du 05/01 au 12/10/2026).
# ---------------------------------------------------------------------------
prix_pompe_cm1 <- utils::read.csv(here::here("data/cm1/prix_pompe_fr_2026.csv"))
prix_pompe_cm1$date <- as.Date(prix_pompe_cm1$date)

#' Prix (€ pour 1 000 L) d'un carburant à une date du bulletin
prix_semaine <- function(carburant, jour) {
  prix_pompe_cm1[[carburant]][prix_pompe_cm1$date == as.Date(jour)]
}

#' Prix à la pompe (€/L) de l'Euro-super 95 et du gazole, chaque semaine du 05/01 au 12/10/2026.
graphe_prix_pompe <- function(base_size = 16) {
  d <- rbind(
    data.frame(date = prix_pompe_cm1$date, serie = "Euro-super 95", prix = prix_pompe_cm1$essence / 1000),
    data.frame(date = prix_pompe_cm1$date, serie = "Gazole", prix = prix_pompe_cm1$gazole / 1000)
  )
  mois <- as.Date(paste0("2026-", sprintf("%02d", 1:10), "-01"))
  noms_mois <- c("janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.")
  if (base_size > 16) noms_mois[c(FALSE, TRUE)] <- ""   # diapos : un mois sur deux, sinon les noms se chevauchent
  ggplot(d, aes(date, prix, colour = serie)) +
    annotate("segment", x = as.Date("2026-02-28"), xend = as.Date("2026-02-28"), y = 1.55, yend = 2.45,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    annotate("text", x = as.Date("2026-03-03"), y = 2.45, label = "28 février : fermeture d’Ormuz",
             hjust = 0, vjust = 1, family = police_cours, size = base_size / 3.4, colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.2) +
    scale_colour_manual(values = ordre_series[1:2]) +
    scale_x_date(breaks = mois, labels = noms_mois) +
    scale_y_continuous(labels = function(x) format(x, decimal.mark = ",", nsmall = 2)) +
    coord_cartesian(ylim = c(1.55, 2.45)) +
    labs(x = NULL, y = "Prix TTC (€ par litre)",
         caption = "Source : Commission européenne, Weekly Oil Bulletin\n(consulté le 21/10/2026).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 bis. Graphique de données : le Brent au comptant, 2026
#    EIA, « Europe Brent Spot Price FOB », dollars par baril, jours ouvrés.
#    Fichier et provenance : data/cm1/brent_eia_2025_2026.csv et data/cm1/SOURCES.md
#    (téléchargé le 21/10/2026 ; arrêt au 14/10/2026, date d'arrêt de la page).
#    2025 ne sert qu'à la moyenne annuelle tracée en repère.
# ---------------------------------------------------------------------------
brent_cm1 <- utils::read.csv(here::here("data/cm1/brent_eia_2025_2026.csv"))
brent_cm1$date <- as.Date(brent_cm1$date)
brent_moy_2025 <- mean(brent_cm1$brent[format(brent_cm1$date, "%Y") == "2025"])

#' Brent ($ par baril) à une date de cotation
brent_jour <- function(jour) brent_cm1$brent[brent_cm1$date == as.Date(jour)]

#' Brent quotidien du 02/01 au 14/10/2026, avec la moyenne 2025 en tirets
#' et la fermeture d'Ormuz (28/02) en repère vertical.
graphe_brent <- function(base_size = 16) {
  d <- subset(brent_cm1, date >= as.Date("2026-01-01"))
  mois <- as.Date(paste0("2026-", sprintf("%02d", 1:10), "-01"))
  noms_mois <- c("janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.")
  if (base_size > 16) noms_mois[c(FALSE, TRUE)] <- ""   # diapos : un mois sur deux
  neutre <- couleurs_eco[["neutre"]]
  ggplot(d, aes(date, brent)) +
    annotate("segment", x = min(d$date), xend = max(d$date), y = brent_moy_2025, yend = brent_moy_2025,
             linetype = "22", colour = neutre) +
    annotate("text", x = as.Date("2026-03-10"), y = brent_moy_2025 - 3,
             label = "moyenne 2025 : 69 $", hjust = 0, vjust = 1,
             family = police_cours, size = base_size / 3.4, colour = neutre) +
    annotate("segment", x = as.Date("2026-02-28"), xend = as.Date("2026-02-28"), y = 55, yend = 152,
             linetype = "22", colour = neutre) +
    annotate("text", x = as.Date("2026-03-03"), y = 152, label = "28 février : fermeture d’Ormuz",
             hjust = 0, vjust = 1, family = police_cours, size = base_size / 3.4, colour = neutre) +
    geom_line(colour = couleurs_eco[["offre"]], linewidth = 1) +
    scale_x_date(breaks = mois, labels = noms_mois) +
    coord_cartesian(ylim = c(55, 152)) +
    labs(x = NULL, y = "Brent ($ par baril)",
         caption = "Source : EIA, Europe Brent Spot Price FOB, cours quotidien\n(consulté le 21/10/2026).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 ter. Graphique de données : livraisons de carburants routiers en France
#    Eurostat, nrg_cb_oilm (données mensuelles, « Gross inland deliveries -
#    observed », GID_OBS), milliers de tonnes : gazole routier (O46711) +
#    essence moteur (O4652). Janvier 2025 à juillet 2026 (dernier mois publié).
#    Fichier et provenance : data/cm1/livraisons_carburants_fr.csv et data/cm1/SOURCES.md.
#    Des livraisons, pas des litres passés à la pompe : elles comprennent les
#    variations de stocks des stations et des clients.
# ---------------------------------------------------------------------------
livraisons_cm1 <- utils::read.csv(here::here("data/cm1/livraisons_carburants_fr.csv"))
livraisons_cm1$annee <- substr(livraisons_cm1$mois, 1, 4)
livraisons_cm1$num_mois <- as.integer(substr(livraisons_cm1$mois, 6, 7))
livraisons_cm1$total <- livraisons_cm1$gazole_routier + livraisons_cm1$essence

#' Variation (%) des livraisons totales de 2026 sur 2025, pour les mois donnés
var_livraisons <- function(mois) {
  tot <- function(a) sum(livraisons_cm1$total[livraisons_cm1$annee == a & livraisons_cm1$num_mois %in% mois])
  var_pct(tot("2025"), tot("2026"))
}

#' Livraisons mensuelles (gazole routier + essence), 2025 et 2026 superposées
#' mois par mois, en millions de tonnes ; repère vertical entre février et mars.
graphe_livraisons <- function(base_size = 16) {
  d <- data.frame(mois = livraisons_cm1$num_mois, annee = livraisons_cm1$annee,
                  total = livraisons_cm1$total / 1000)
  noms_mois <- c("janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc.")
  if (base_size > 16) noms_mois[c(FALSE, TRUE)] <- ""   # diapos : un mois sur deux
  neutre <- couleurs_eco[["neutre"]]
  ggplot(d, aes(mois, total, colour = annee)) +
    annotate("segment", x = 2.5, xend = 2.5, y = 3.0, yend = 4.3, linetype = "22", colour = neutre) +
    annotate("text", x = 2.6, y = 4.3, label = "fermeture d’Ormuz", hjust = 0, vjust = 1,
             family = police_cours, size = base_size / 3.4, colour = neutre) +
    geom_line(linewidth = 1.2) +
    geom_point(size = base_size / 8) +
    scale_colour_manual(values = c("2025" = couleurs_eco[["neutre"]], "2026" = couleurs_eco[["demande"]])) +
    scale_x_continuous(breaks = 1:12, labels = noms_mois) +
    scale_y_continuous(labels = function(x) format(x, decimal.mark = ",", nsmall = 1)) +
    coord_cartesian(ylim = c(3.0, 4.3)) +
    labs(x = NULL, y = "Millions de tonnes",
         caption = "Source : Eurostat (nrg_cb_oilm), gazole routier et essence\n(consulté le 21/10/2026).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 6. Vérifications : chaque chiffre annoncé dans cours/cm1.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# Exemple 2 : demande peu élastique
stopifnot(
  proche(eq_avant$p, 1.70), proche(eq_avant$q, 100),
  proche(eq_apres$p, 2.20), proche(eq_apres$q, 90),
  proche(marche_cm1$o_a - marche_cm1$choc + marche_cm1$o_b * 1.70, 80),                     # offre après choc au prix initial
  proche(round(var_pct(eq_avant$p, eq_apres$p), 1), 29.4),        # +29,4 % sur le prix
  proche(var_pct(eq_avant$q, eq_apres$q), -10),                   # -10 % sur la quantité
  proche(round(var_pct(eq_avant$q, eq_apres$q) / var_pct(eq_avant$p, eq_apres$p), 2), -0.34)
)
# Exemple 2 : demande élastique (comparaison)
stopifnot(
  proche(eq_avant_e$p, 1.70), proche(eq_avant_e$q, 100),
  proche(eq_apres_e$p, 1.95), proche(eq_apres_e$q, 85),
  proche(round(var_pct(eq_avant_e$p, eq_apres_e$p), 1), 14.7),
  proche(var_pct(eq_avant_e$q, eq_apres_e$q), -15)
)
# Exemple 1 : escalier des coûts marginaux
stopifnot(proche(prix_cm_avant, 60), proche(prix_cm_apres, 80),
          proche(round(var_pct(prix_cm_avant, prix_cm_apres), 1), 33.3),
          # demande hors des bords de marche : sinon l'équilibre est indéterminé
          !demande_fixe_cm1 %in% seq(10, 40, 10),
          proche(prix_cm_avant - 40, 20), proche(prix_cm_apres - 40, 40),   # gain de X par baril
          is.na(prix_cout_marginal(producteurs_cm1$cm[-1], 10, 35)))        # capacités saturées : plus de coût marginal qui fixe le prix
# Données Weekly Oil Bulletin : +29,3 % (essence ; et non 29,4 % comme dans ressources/cm1.md)
# et +41,1 % (gazole) du 23/02 au 12/10/2026 ; valeurs citées dans le fig-alt
stopifnot(
  nrow(prix_pompe_cm1) == 41, !anyNA(prix_pompe_cm1),
  proche(round(var_pct(prix_semaine("essence", "2026-02-23"), prix_semaine("essence", "2026-10-12")), 1), 29.3),
  proche(round(var_pct(prix_semaine("gazole", "2026-02-23"), prix_semaine("gazole", "2026-10-12")), 1), 41.1),
  prix_semaine("gazole", "2026-02-23") < prix_semaine("essence", "2026-02-23"),
  prix_semaine("gazole", "2026-03-09") > prix_semaine("essence", "2026-03-09"),
  prix_semaine("gazole", "2026-07-13") < prix_semaine("essence", "2026-07-13"),
  all(with(subset(prix_pompe_cm1, date >= as.Date("2026-07-20")), gazole > essence)),
  proche(round(prix_semaine("essence", "2026-05-25") / 1000, 2), 2.11),
  proche(round(max(prix_pompe_cm1$essence) / 1000, 2), 2.22),
  proche(round(prix_semaine("gazole", "2026-04-13") / 1000, 2), 2.31),
  proche(round(prix_semaine("essence", "2026-07-06") / 1000, 2), 1.92),
  proche(round(prix_semaine("gazole", "2026-07-06") / 1000, 2), 1.86),
  proche(round(max(prix_pompe_cm1$gazole) / 1000, 2), 2.38)
)
# Recettes de l'État au 30/09/2026 (The Conversation, 13/10/2026) : +798 M€ de TVA
# et -1 180 M€ d'accises donnent bien environ -383 M€ (écart d'arrondi de la source)
stopifnot(abs((798 - 1180) - (-383)) <= 2)
# Élasticité de l'Insee appliquée au cas : e = -0,3 et +40 % de prix donnent -12 % de quantité,
# et une dépense multipliée par 1,40 x 0,88 = 1,232, soit environ +23 %
stopifnot(proche(-0.3 * 40, -12), proche(round(1.40 * 0.88, 2), 1.23))
# Brent (EIA) : chiffres du texte et de la @fig-brent
stopifnot(
  max(brent_cm1$date) == as.Date("2026-10-14"), !anyNA(brent_cm1$brent),
  brent_moy_2025 < 70, proche(round(brent_moy_2025), 69),                 # « moins de 70 $ en 2025 », « moyenne 2025 : 69 $ »
  proche(brent_jour("2026-02-26"), 71.66), proche(brent_jour("2026-03-20"), 118.42),
  proche(brent_jour("2026-10-14"), 126.55),
  proche(max(brent_cm1$brent), 138.21), brent_jour("2026-04-07") == max(brent_cm1$brent),   # plus haut : 7 avril
  brent_jour("2026-04-07") / brent_jour("2026-02-26") > 1.9, as.numeric(as.Date("2026-04-07") - as.Date("2026-02-26")) <= 42,   # « double presque en six semaines »
  all(brent_cm1$brent[brent_cm1$date >= as.Date("2026-07-01") & brent_cm1$date <= as.Date("2026-07-03")] < 70),
  all(brent_cm1$brent[brent_cm1$date >= as.Date("2026-10-02")] > 125), brent_jour("2026-10-01") < 125   # « au-dessus de 125 $ depuis le 2 octobre »
)
# Livraisons (Eurostat) : -6,0 % en janvier-février, -4,9 % de mars à juillet 2026 sur un an
stopifnot(
  nrow(livraisons_cm1) == 19, !anyNA(livraisons_cm1),
  max(livraisons_cm1$mois) == "2026-07",
  proche(round(var_livraisons(1:2), 1), -6.0),
  proche(round(var_livraisons(3:7), 1), -4.9),
  # « jusqu'à 40 % de plus » : plus haut du gazole de mars à juillet (13/04) rapporté au 23/02
  proche(round(var_pct(prix_semaine("gazole", "2026-02-23"),
                       max(prix_pompe_cm1$gazole[prix_pompe_cm1$date >= as.Date("2026-03-01") &
                                                 prix_pompe_cm1$date <= as.Date("2026-07-31")]))), 40)
)

# ---------------------------------------------------------------------------
# 7. Schéma « du baril à la pompe » (tableau @tbl-baril-pompe de la page)
#    Euro-super 95, France, euros pour 1 000 L. TTC : prix_pompe_cm1 ; hors taxes :
#    Weekly Oil Bulletin, feuille « Prices wo taxes », colonne FR_price_wo_tax_euro95
#    (valeurs lues le 21/10/2026, aux deux dates du texte). La TVA est le taux normal
#    de 20 % (TTC / 6) ; l'accise est le solde TTC - hors taxes - TVA.
# ---------------------------------------------------------------------------
ht_euro95 <- c("2026-02-23" = 735.025, "2026-10-12" = 1153.317)

#' Décomposition (€/L) du prix TTC de l'Euro-super 95 à une date : hors taxes, accise, TVA
decompose_pompe <- function(jour) {
  ttc <- prix_semaine("essence", jour)
  ht  <- unname(ht_euro95[jour])
  tva <- ttc / 6
  c(ht = ht, accise = ttc - ht - tva, tva = tva, ttc = ttc) / 1000
}

# Les chiffres du tableau : l'accise ne bouge pas (0,690 €/L aux deux dates),
# 0,418 € des 0,502 € de hausse (83 %) viennent du hors-taxes, 0,084 € de la TVA
stopifnot(
  proche(round(decompose_pompe("2026-02-23")[["accise"]], 3), 0.690),
  proche(round(decompose_pompe("2026-10-12")[["accise"]], 3), 0.690),
  proche(round(decompose_pompe("2026-02-23")[["ht"]], 3), 0.735),
  proche(round(decompose_pompe("2026-10-12")[["ht"]], 3), 1.153),
  proche(round(decompose_pompe("2026-02-23")[["tva"]], 3), 0.285),
  proche(round(decompose_pompe("2026-10-12")[["tva"]], 3), 0.369),
  proche(round(decompose_pompe("2026-02-23")[["ttc"]], 2), 1.71),
  proche(round(decompose_pompe("2026-10-12")[["ttc"]], 2), 2.21),
  proche(round(100 * (decompose_pompe("2026-10-12")[["ht"]] - decompose_pompe("2026-02-23")[["ht"]]) /
                 (decompose_pompe("2026-10-12")[["ttc"]] - decompose_pompe("2026-02-23")[["ttc"]])), 83)
)

# Gazole : même calcul, pour la phrase « la part du hors-taxes […] est la même (83 %) ».
# Hors taxes : Weekly Oil Bulletin, feuille « Prices wo taxes », colonne
# FR_price_wo_tax_diesel (valeurs relues le 22/10/2026, voir data/cm1/SOURCES.md).
ht_gazole <- c("2026-02-23" = 767.267, "2026-10-12" = 1332.708)
stopifnot(
  proche(round(100 * diff(ht_gazole) /
                 (prix_semaine("gazole", "2026-10-12") - prix_semaine("gazole", "2026-02-23"))), 83),
  # « la TVA l'amplifie de 20 % » : hausse de TVA = 20 % de la hausse hors taxes (essence)
  proche(round((decompose_pompe("2026-10-12")[["tva"]] - decompose_pompe("2026-02-23")[["tva"]]) /
                 diff(ht_euro95 / 1000), 2), 0.20)
)

# ---------------------------------------------------------------------------
# 8. Vérifications complémentaires : chiffres des légendes, des fig-alt et du TD 1
#    qui n'étaient pas couverts plus haut
# ---------------------------------------------------------------------------
# Prix à la pompe (Weekly Oil Bulletin)
stopifnot(
  proche(round(prix_semaine("gazole", "2026-02-23") / 1000, 2), 1.65),      # gazole avant la guerre
  proche(round(prix_semaine("gazole", "2026-10-12") / 1000, 2), 2.33),      # gazole au 12/10
  proche(round(prix_semaine("essence", "2026-04-13") / 1000, 2), 2.04),     # essence mi-avril (Cusset, TD doc 1)
  proche(round(prix_semaine("essence", "2026-09-21") / 1000, 2), 2.22),     # TD doc 1
  proche(round(prix_semaine("gazole", "2026-09-21") / 1000, 2), 2.38),      # TD doc 1
  # croisements de juin : de justesse dessous le 1er, à égalité les 8 et 15, franchement dessous du 22/06 au 13/07
  prix_semaine("gazole", "2026-06-01") < prix_semaine("essence", "2026-06-01"),
  all(abs(sapply(c("2026-06-08", "2026-06-15"), function(j)
    prix_semaine("gazole", j) - prix_semaine("essence", j))) < 10),        # moins de 1 centime d'écart
  all(with(subset(prix_pompe_cm1, date >= as.Date("2026-06-22") & date <= as.Date("2026-07-13")),
           gazole < essence))
)
# Brent (EIA) : fig-alt et légende
stopifnot(
  identical(round(range(brent_cm1$brent[brent_cm1$date >= as.Date("2026-01-01") &
                                          brent_cm1$date < as.Date("2026-02-28")])), c(61, 73)),
  proche(brent_jour("2026-07-23"), 105.32), proche(brent_jour("2026-09-15"), 130.80),
  proche(brent_jour("2026-10-02"), 135.51),
  brent_jour("2026-09-02") < 100,
  all(brent_cm1$brent[brent_cm1$date >= as.Date("2026-09-03")] > 100)      # « au-dessus de 100 $ à partir du 3 septembre »
)
# Livraisons (Eurostat) : fig-alt
stopifnot(
  identical(round(range(livraisons_cm1$total[livraisons_cm1$annee == "2025"]) / 1000, 1), c(3.3, 4.1)),
  proche(round(livraisons_cm1$total[livraisons_cm1$mois == "2026-05"] / 1000, 1), 3.2),
  proche(round(livraisons_cm1$total[livraisons_cm1$mois == "2025-05"] / 1000, 1), 3.6)
)
